
obj/user/faultreadkernel.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800039:	a1 00 00 10 f0       	mov    0xf0100000,%eax
  80003e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800042:	c7 04 24 c0 25 80 00 	movl   $0x8025c0,(%esp)
  800049:	e8 06 01 00 00       	call   800154 <cprintf>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	56                   	push   %esi
  800054:	53                   	push   %ebx
  800055:	83 ec 10             	sub    $0x10,%esp
  800058:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  80005e:	e8 f2 0a 00 00       	call   800b55 <sys_getenvid>
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800070:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800075:	85 db                	test   %ebx,%ebx
  800077:	7e 07                	jle    800080 <libmain+0x30>
		binaryname = argv[0];
  800079:	8b 06                	mov    (%esi),%eax
  80007b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800080:	89 74 24 04          	mov    %esi,0x4(%esp)
  800084:	89 1c 24             	mov    %ebx,(%esp)
  800087:	e8 a7 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008c:	e8 07 00 00 00       	call   800098 <exit>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	5b                   	pop    %ebx
  800095:	5e                   	pop    %esi
  800096:	5d                   	pop    %ebp
  800097:	c3                   	ret    

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80009e:	e8 f7 0f 00 00       	call   80109a <close_all>
	sys_env_destroy(0);
  8000a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000aa:	e8 54 0a 00 00       	call   800b03 <sys_env_destroy>
}
  8000af:	c9                   	leave  
  8000b0:	c3                   	ret    

008000b1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b1:	55                   	push   %ebp
  8000b2:	89 e5                	mov    %esp,%ebp
  8000b4:	53                   	push   %ebx
  8000b5:	83 ec 14             	sub    $0x14,%esp
  8000b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000bb:	8b 13                	mov    (%ebx),%edx
  8000bd:	8d 42 01             	lea    0x1(%edx),%eax
  8000c0:	89 03                	mov    %eax,(%ebx)
  8000c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ce:	75 19                	jne    8000e9 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000d0:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000d7:	00 
  8000d8:	8d 43 08             	lea    0x8(%ebx),%eax
  8000db:	89 04 24             	mov    %eax,(%esp)
  8000de:	e8 e3 09 00 00       	call   800ac6 <sys_cputs>
		b->idx = 0;
  8000e3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000e9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000ed:	83 c4 14             	add    $0x14,%esp
  8000f0:	5b                   	pop    %ebx
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000fc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800103:	00 00 00 
	b.cnt = 0;
  800106:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80010d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800110:	8b 45 0c             	mov    0xc(%ebp),%eax
  800113:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800117:	8b 45 08             	mov    0x8(%ebp),%eax
  80011a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80011e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800124:	89 44 24 04          	mov    %eax,0x4(%esp)
  800128:	c7 04 24 b1 00 80 00 	movl   $0x8000b1,(%esp)
  80012f:	e8 aa 01 00 00       	call   8002de <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800134:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80013a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800144:	89 04 24             	mov    %eax,(%esp)
  800147:	e8 7a 09 00 00       	call   800ac6 <sys_cputs>

	return b.cnt;
}
  80014c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800152:	c9                   	leave  
  800153:	c3                   	ret    

00800154 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80015a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800161:	8b 45 08             	mov    0x8(%ebp),%eax
  800164:	89 04 24             	mov    %eax,(%esp)
  800167:	e8 87 ff ff ff       	call   8000f3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80016c:	c9                   	leave  
  80016d:	c3                   	ret    
  80016e:	66 90                	xchg   %ax,%ax

00800170 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 3c             	sub    $0x3c,%esp
  800179:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80017c:	89 d7                	mov    %edx,%edi
  80017e:	8b 45 08             	mov    0x8(%ebp),%eax
  800181:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800184:	8b 45 0c             	mov    0xc(%ebp),%eax
  800187:	89 c3                	mov    %eax,%ebx
  800189:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80018c:	8b 45 10             	mov    0x10(%ebp),%eax
  80018f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800192:	b9 00 00 00 00       	mov    $0x0,%ecx
  800197:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80019d:	39 d9                	cmp    %ebx,%ecx
  80019f:	72 05                	jb     8001a6 <printnum+0x36>
  8001a1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001a4:	77 69                	ja     80020f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001a9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8001ad:	83 ee 01             	sub    $0x1,%esi
  8001b0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001bc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001c0:	89 c3                	mov    %eax,%ebx
  8001c2:	89 d6                	mov    %edx,%esi
  8001c4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001c7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8001ca:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001ce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8001d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001d5:	89 04 24             	mov    %eax,(%esp)
  8001d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8001db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001df:	e8 4c 21 00 00       	call   802330 <__udivdi3>
  8001e4:	89 d9                	mov    %ebx,%ecx
  8001e6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8001ea:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001ee:	89 04 24             	mov    %eax,(%esp)
  8001f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001f5:	89 fa                	mov    %edi,%edx
  8001f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001fa:	e8 71 ff ff ff       	call   800170 <printnum>
  8001ff:	eb 1b                	jmp    80021c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800201:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800205:	8b 45 18             	mov    0x18(%ebp),%eax
  800208:	89 04 24             	mov    %eax,(%esp)
  80020b:	ff d3                	call   *%ebx
  80020d:	eb 03                	jmp    800212 <printnum+0xa2>
  80020f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800212:	83 ee 01             	sub    $0x1,%esi
  800215:	85 f6                	test   %esi,%esi
  800217:	7f e8                	jg     800201 <printnum+0x91>
  800219:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800220:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800224:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800227:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80022a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800232:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800235:	89 04 24             	mov    %eax,(%esp)
  800238:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80023b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023f:	e8 1c 22 00 00       	call   802460 <__umoddi3>
  800244:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800248:	0f be 80 f1 25 80 00 	movsbl 0x8025f1(%eax),%eax
  80024f:	89 04 24             	mov    %eax,(%esp)
  800252:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800255:	ff d0                	call   *%eax
}
  800257:	83 c4 3c             	add    $0x3c,%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800262:	83 fa 01             	cmp    $0x1,%edx
  800265:	7e 0e                	jle    800275 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800267:	8b 10                	mov    (%eax),%edx
  800269:	8d 4a 08             	lea    0x8(%edx),%ecx
  80026c:	89 08                	mov    %ecx,(%eax)
  80026e:	8b 02                	mov    (%edx),%eax
  800270:	8b 52 04             	mov    0x4(%edx),%edx
  800273:	eb 22                	jmp    800297 <getuint+0x38>
	else if (lflag)
  800275:	85 d2                	test   %edx,%edx
  800277:	74 10                	je     800289 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800279:	8b 10                	mov    (%eax),%edx
  80027b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027e:	89 08                	mov    %ecx,(%eax)
  800280:	8b 02                	mov    (%edx),%eax
  800282:	ba 00 00 00 00       	mov    $0x0,%edx
  800287:	eb 0e                	jmp    800297 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800289:	8b 10                	mov    (%eax),%edx
  80028b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028e:	89 08                	mov    %ecx,(%eax)
  800290:	8b 02                	mov    (%edx),%eax
  800292:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800297:	5d                   	pop    %ebp
  800298:	c3                   	ret    

00800299 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80029f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a3:	8b 10                	mov    (%eax),%edx
  8002a5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a8:	73 0a                	jae    8002b4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002aa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ad:	89 08                	mov    %ecx,(%eax)
  8002af:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b2:	88 02                	mov    %al,(%edx)
}
  8002b4:	5d                   	pop    %ebp
  8002b5:	c3                   	ret    

008002b6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002bc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d4:	89 04 24             	mov    %eax,(%esp)
  8002d7:	e8 02 00 00 00       	call   8002de <vprintfmt>
	va_end(ap);
}
  8002dc:	c9                   	leave  
  8002dd:	c3                   	ret    

008002de <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	57                   	push   %edi
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
  8002e4:	83 ec 3c             	sub    $0x3c,%esp
  8002e7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002ed:	eb 14                	jmp    800303 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ef:	85 c0                	test   %eax,%eax
  8002f1:	0f 84 b3 03 00 00    	je     8006aa <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  8002f7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002fb:	89 04 24             	mov    %eax,(%esp)
  8002fe:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800301:	89 f3                	mov    %esi,%ebx
  800303:	8d 73 01             	lea    0x1(%ebx),%esi
  800306:	0f b6 03             	movzbl (%ebx),%eax
  800309:	83 f8 25             	cmp    $0x25,%eax
  80030c:	75 e1                	jne    8002ef <vprintfmt+0x11>
  80030e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800312:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800319:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800320:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800327:	ba 00 00 00 00       	mov    $0x0,%edx
  80032c:	eb 1d                	jmp    80034b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800330:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800334:	eb 15                	jmp    80034b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800336:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800338:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80033c:	eb 0d                	jmp    80034b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80033e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800341:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800344:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80034e:	0f b6 0e             	movzbl (%esi),%ecx
  800351:	0f b6 c1             	movzbl %cl,%eax
  800354:	83 e9 23             	sub    $0x23,%ecx
  800357:	80 f9 55             	cmp    $0x55,%cl
  80035a:	0f 87 2a 03 00 00    	ja     80068a <vprintfmt+0x3ac>
  800360:	0f b6 c9             	movzbl %cl,%ecx
  800363:	ff 24 8d 40 27 80 00 	jmp    *0x802740(,%ecx,4)
  80036a:	89 de                	mov    %ebx,%esi
  80036c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800371:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800374:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800378:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80037b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80037e:	83 fb 09             	cmp    $0x9,%ebx
  800381:	77 36                	ja     8003b9 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800383:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800386:	eb e9                	jmp    800371 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800388:	8b 45 14             	mov    0x14(%ebp),%eax
  80038b:	8d 48 04             	lea    0x4(%eax),%ecx
  80038e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800391:	8b 00                	mov    (%eax),%eax
  800393:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800398:	eb 22                	jmp    8003bc <vprintfmt+0xde>
  80039a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80039d:	85 c9                	test   %ecx,%ecx
  80039f:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a4:	0f 49 c1             	cmovns %ecx,%eax
  8003a7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	89 de                	mov    %ebx,%esi
  8003ac:	eb 9d                	jmp    80034b <vprintfmt+0x6d>
  8003ae:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003b0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003b7:	eb 92                	jmp    80034b <vprintfmt+0x6d>
  8003b9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8003bc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8003c0:	79 89                	jns    80034b <vprintfmt+0x6d>
  8003c2:	e9 77 ff ff ff       	jmp    80033e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003cc:	e9 7a ff ff ff       	jmp    80034b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d4:	8d 50 04             	lea    0x4(%eax),%edx
  8003d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003de:	8b 00                	mov    (%eax),%eax
  8003e0:	89 04 24             	mov    %eax,(%esp)
  8003e3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003e6:	e9 18 ff ff ff       	jmp    800303 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ee:	8d 50 04             	lea    0x4(%eax),%edx
  8003f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f4:	8b 00                	mov    (%eax),%eax
  8003f6:	99                   	cltd   
  8003f7:	31 d0                	xor    %edx,%eax
  8003f9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003fb:	83 f8 0f             	cmp    $0xf,%eax
  8003fe:	7f 0b                	jg     80040b <vprintfmt+0x12d>
  800400:	8b 14 85 a0 28 80 00 	mov    0x8028a0(,%eax,4),%edx
  800407:	85 d2                	test   %edx,%edx
  800409:	75 20                	jne    80042b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80040b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80040f:	c7 44 24 08 09 26 80 	movl   $0x802609,0x8(%esp)
  800416:	00 
  800417:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80041b:	8b 45 08             	mov    0x8(%ebp),%eax
  80041e:	89 04 24             	mov    %eax,(%esp)
  800421:	e8 90 fe ff ff       	call   8002b6 <printfmt>
  800426:	e9 d8 fe ff ff       	jmp    800303 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80042b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80042f:	c7 44 24 08 d5 29 80 	movl   $0x8029d5,0x8(%esp)
  800436:	00 
  800437:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80043b:	8b 45 08             	mov    0x8(%ebp),%eax
  80043e:	89 04 24             	mov    %eax,(%esp)
  800441:	e8 70 fe ff ff       	call   8002b6 <printfmt>
  800446:	e9 b8 fe ff ff       	jmp    800303 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80044e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800451:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800454:	8b 45 14             	mov    0x14(%ebp),%eax
  800457:	8d 50 04             	lea    0x4(%eax),%edx
  80045a:	89 55 14             	mov    %edx,0x14(%ebp)
  80045d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80045f:	85 f6                	test   %esi,%esi
  800461:	b8 02 26 80 00       	mov    $0x802602,%eax
  800466:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800469:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80046d:	0f 84 97 00 00 00    	je     80050a <vprintfmt+0x22c>
  800473:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800477:	0f 8e 9b 00 00 00    	jle    800518 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80047d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800481:	89 34 24             	mov    %esi,(%esp)
  800484:	e8 cf 02 00 00       	call   800758 <strnlen>
  800489:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80048c:	29 c2                	sub    %eax,%edx
  80048e:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800491:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800495:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800498:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80049b:	8b 75 08             	mov    0x8(%ebp),%esi
  80049e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004a1:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a3:	eb 0f                	jmp    8004b4 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8004a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004ac:	89 04 24             	mov    %eax,(%esp)
  8004af:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b1:	83 eb 01             	sub    $0x1,%ebx
  8004b4:	85 db                	test   %ebx,%ebx
  8004b6:	7f ed                	jg     8004a5 <vprintfmt+0x1c7>
  8004b8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004bb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004be:	85 d2                	test   %edx,%edx
  8004c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c5:	0f 49 c2             	cmovns %edx,%eax
  8004c8:	29 c2                	sub    %eax,%edx
  8004ca:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8004cd:	89 d7                	mov    %edx,%edi
  8004cf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8004d2:	eb 50                	jmp    800524 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004d4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d8:	74 1e                	je     8004f8 <vprintfmt+0x21a>
  8004da:	0f be d2             	movsbl %dl,%edx
  8004dd:	83 ea 20             	sub    $0x20,%edx
  8004e0:	83 fa 5e             	cmp    $0x5e,%edx
  8004e3:	76 13                	jbe    8004f8 <vprintfmt+0x21a>
					putch('?', putdat);
  8004e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ec:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004f3:	ff 55 08             	call   *0x8(%ebp)
  8004f6:	eb 0d                	jmp    800505 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8004f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004fb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004ff:	89 04 24             	mov    %eax,(%esp)
  800502:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800505:	83 ef 01             	sub    $0x1,%edi
  800508:	eb 1a                	jmp    800524 <vprintfmt+0x246>
  80050a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80050d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800510:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800513:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800516:	eb 0c                	jmp    800524 <vprintfmt+0x246>
  800518:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80051b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80051e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800521:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800524:	83 c6 01             	add    $0x1,%esi
  800527:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80052b:	0f be c2             	movsbl %dl,%eax
  80052e:	85 c0                	test   %eax,%eax
  800530:	74 27                	je     800559 <vprintfmt+0x27b>
  800532:	85 db                	test   %ebx,%ebx
  800534:	78 9e                	js     8004d4 <vprintfmt+0x1f6>
  800536:	83 eb 01             	sub    $0x1,%ebx
  800539:	79 99                	jns    8004d4 <vprintfmt+0x1f6>
  80053b:	89 f8                	mov    %edi,%eax
  80053d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800540:	8b 75 08             	mov    0x8(%ebp),%esi
  800543:	89 c3                	mov    %eax,%ebx
  800545:	eb 1a                	jmp    800561 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800547:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80054b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800552:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800554:	83 eb 01             	sub    $0x1,%ebx
  800557:	eb 08                	jmp    800561 <vprintfmt+0x283>
  800559:	89 fb                	mov    %edi,%ebx
  80055b:	8b 75 08             	mov    0x8(%ebp),%esi
  80055e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800561:	85 db                	test   %ebx,%ebx
  800563:	7f e2                	jg     800547 <vprintfmt+0x269>
  800565:	89 75 08             	mov    %esi,0x8(%ebp)
  800568:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80056b:	e9 93 fd ff ff       	jmp    800303 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800570:	83 fa 01             	cmp    $0x1,%edx
  800573:	7e 16                	jle    80058b <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800575:	8b 45 14             	mov    0x14(%ebp),%eax
  800578:	8d 50 08             	lea    0x8(%eax),%edx
  80057b:	89 55 14             	mov    %edx,0x14(%ebp)
  80057e:	8b 50 04             	mov    0x4(%eax),%edx
  800581:	8b 00                	mov    (%eax),%eax
  800583:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800586:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800589:	eb 32                	jmp    8005bd <vprintfmt+0x2df>
	else if (lflag)
  80058b:	85 d2                	test   %edx,%edx
  80058d:	74 18                	je     8005a7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  80058f:	8b 45 14             	mov    0x14(%ebp),%eax
  800592:	8d 50 04             	lea    0x4(%eax),%edx
  800595:	89 55 14             	mov    %edx,0x14(%ebp)
  800598:	8b 30                	mov    (%eax),%esi
  80059a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80059d:	89 f0                	mov    %esi,%eax
  80059f:	c1 f8 1f             	sar    $0x1f,%eax
  8005a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005a5:	eb 16                	jmp    8005bd <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8005a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005aa:	8d 50 04             	lea    0x4(%eax),%edx
  8005ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b0:	8b 30                	mov    (%eax),%esi
  8005b2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005b5:	89 f0                	mov    %esi,%eax
  8005b7:	c1 f8 1f             	sar    $0x1f,%eax
  8005ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005cc:	0f 89 80 00 00 00    	jns    800652 <vprintfmt+0x374>
				putch('-', putdat);
  8005d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005dd:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e6:	f7 d8                	neg    %eax
  8005e8:	83 d2 00             	adc    $0x0,%edx
  8005eb:	f7 da                	neg    %edx
			}
			base = 10;
  8005ed:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005f2:	eb 5e                	jmp    800652 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005f4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f7:	e8 63 fc ff ff       	call   80025f <getuint>
			base = 10;
  8005fc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800601:	eb 4f                	jmp    800652 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800603:	8d 45 14             	lea    0x14(%ebp),%eax
  800606:	e8 54 fc ff ff       	call   80025f <getuint>
			base = 8;
  80060b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800610:	eb 40                	jmp    800652 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800612:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800616:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80061d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800620:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800624:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80062b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8d 50 04             	lea    0x4(%eax),%edx
  800634:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800637:	8b 00                	mov    (%eax),%eax
  800639:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80063e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800643:	eb 0d                	jmp    800652 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800645:	8d 45 14             	lea    0x14(%ebp),%eax
  800648:	e8 12 fc ff ff       	call   80025f <getuint>
			base = 16;
  80064d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800652:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800656:	89 74 24 10          	mov    %esi,0x10(%esp)
  80065a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80065d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800661:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800665:	89 04 24             	mov    %eax,(%esp)
  800668:	89 54 24 04          	mov    %edx,0x4(%esp)
  80066c:	89 fa                	mov    %edi,%edx
  80066e:	8b 45 08             	mov    0x8(%ebp),%eax
  800671:	e8 fa fa ff ff       	call   800170 <printnum>
			break;
  800676:	e9 88 fc ff ff       	jmp    800303 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80067b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80067f:	89 04 24             	mov    %eax,(%esp)
  800682:	ff 55 08             	call   *0x8(%ebp)
			break;
  800685:	e9 79 fc ff ff       	jmp    800303 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80068a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80068e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800695:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800698:	89 f3                	mov    %esi,%ebx
  80069a:	eb 03                	jmp    80069f <vprintfmt+0x3c1>
  80069c:	83 eb 01             	sub    $0x1,%ebx
  80069f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006a3:	75 f7                	jne    80069c <vprintfmt+0x3be>
  8006a5:	e9 59 fc ff ff       	jmp    800303 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8006aa:	83 c4 3c             	add    $0x3c,%esp
  8006ad:	5b                   	pop    %ebx
  8006ae:	5e                   	pop    %esi
  8006af:	5f                   	pop    %edi
  8006b0:	5d                   	pop    %ebp
  8006b1:	c3                   	ret    

008006b2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b2:	55                   	push   %ebp
  8006b3:	89 e5                	mov    %esp,%ebp
  8006b5:	83 ec 28             	sub    $0x28,%esp
  8006b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006be:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	74 30                	je     800703 <vsnprintf+0x51>
  8006d3:	85 d2                	test   %edx,%edx
  8006d5:	7e 2c                	jle    800703 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006de:	8b 45 10             	mov    0x10(%ebp),%eax
  8006e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ec:	c7 04 24 99 02 80 00 	movl   $0x800299,(%esp)
  8006f3:	e8 e6 fb ff ff       	call   8002de <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006fb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800701:	eb 05                	jmp    800708 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800703:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800708:	c9                   	leave  
  800709:	c3                   	ret    

0080070a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800710:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800713:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800717:	8b 45 10             	mov    0x10(%ebp),%eax
  80071a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80071e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800721:	89 44 24 04          	mov    %eax,0x4(%esp)
  800725:	8b 45 08             	mov    0x8(%ebp),%eax
  800728:	89 04 24             	mov    %eax,(%esp)
  80072b:	e8 82 ff ff ff       	call   8006b2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800730:	c9                   	leave  
  800731:	c3                   	ret    
  800732:	66 90                	xchg   %ax,%ax
  800734:	66 90                	xchg   %ax,%ax
  800736:	66 90                	xchg   %ax,%ax
  800738:	66 90                	xchg   %ax,%ax
  80073a:	66 90                	xchg   %ax,%ax
  80073c:	66 90                	xchg   %ax,%ax
  80073e:	66 90                	xchg   %ax,%ax

00800740 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800746:	b8 00 00 00 00       	mov    $0x0,%eax
  80074b:	eb 03                	jmp    800750 <strlen+0x10>
		n++;
  80074d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800750:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800754:	75 f7                	jne    80074d <strlen+0xd>
		n++;
	return n;
}
  800756:	5d                   	pop    %ebp
  800757:	c3                   	ret    

00800758 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800761:	b8 00 00 00 00       	mov    $0x0,%eax
  800766:	eb 03                	jmp    80076b <strnlen+0x13>
		n++;
  800768:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076b:	39 d0                	cmp    %edx,%eax
  80076d:	74 06                	je     800775 <strnlen+0x1d>
  80076f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800773:	75 f3                	jne    800768 <strnlen+0x10>
		n++;
	return n;
}
  800775:	5d                   	pop    %ebp
  800776:	c3                   	ret    

00800777 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	53                   	push   %ebx
  80077b:	8b 45 08             	mov    0x8(%ebp),%eax
  80077e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800781:	89 c2                	mov    %eax,%edx
  800783:	83 c2 01             	add    $0x1,%edx
  800786:	83 c1 01             	add    $0x1,%ecx
  800789:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80078d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800790:	84 db                	test   %bl,%bl
  800792:	75 ef                	jne    800783 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800794:	5b                   	pop    %ebx
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	53                   	push   %ebx
  80079b:	83 ec 08             	sub    $0x8,%esp
  80079e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a1:	89 1c 24             	mov    %ebx,(%esp)
  8007a4:	e8 97 ff ff ff       	call   800740 <strlen>
	strcpy(dst + len, src);
  8007a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007b0:	01 d8                	add    %ebx,%eax
  8007b2:	89 04 24             	mov    %eax,(%esp)
  8007b5:	e8 bd ff ff ff       	call   800777 <strcpy>
	return dst;
}
  8007ba:	89 d8                	mov    %ebx,%eax
  8007bc:	83 c4 08             	add    $0x8,%esp
  8007bf:	5b                   	pop    %ebx
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	56                   	push   %esi
  8007c6:	53                   	push   %ebx
  8007c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007cd:	89 f3                	mov    %esi,%ebx
  8007cf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d2:	89 f2                	mov    %esi,%edx
  8007d4:	eb 0f                	jmp    8007e5 <strncpy+0x23>
		*dst++ = *src;
  8007d6:	83 c2 01             	add    $0x1,%edx
  8007d9:	0f b6 01             	movzbl (%ecx),%eax
  8007dc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007df:	80 39 01             	cmpb   $0x1,(%ecx)
  8007e2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e5:	39 da                	cmp    %ebx,%edx
  8007e7:	75 ed                	jne    8007d6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e9:	89 f0                	mov    %esi,%eax
  8007eb:	5b                   	pop    %ebx
  8007ec:	5e                   	pop    %esi
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	56                   	push   %esi
  8007f3:	53                   	push   %ebx
  8007f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007fd:	89 f0                	mov    %esi,%eax
  8007ff:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800803:	85 c9                	test   %ecx,%ecx
  800805:	75 0b                	jne    800812 <strlcpy+0x23>
  800807:	eb 1d                	jmp    800826 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800809:	83 c0 01             	add    $0x1,%eax
  80080c:	83 c2 01             	add    $0x1,%edx
  80080f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800812:	39 d8                	cmp    %ebx,%eax
  800814:	74 0b                	je     800821 <strlcpy+0x32>
  800816:	0f b6 0a             	movzbl (%edx),%ecx
  800819:	84 c9                	test   %cl,%cl
  80081b:	75 ec                	jne    800809 <strlcpy+0x1a>
  80081d:	89 c2                	mov    %eax,%edx
  80081f:	eb 02                	jmp    800823 <strlcpy+0x34>
  800821:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800823:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800826:	29 f0                	sub    %esi,%eax
}
  800828:	5b                   	pop    %ebx
  800829:	5e                   	pop    %esi
  80082a:	5d                   	pop    %ebp
  80082b:	c3                   	ret    

0080082c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800832:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800835:	eb 06                	jmp    80083d <strcmp+0x11>
		p++, q++;
  800837:	83 c1 01             	add    $0x1,%ecx
  80083a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80083d:	0f b6 01             	movzbl (%ecx),%eax
  800840:	84 c0                	test   %al,%al
  800842:	74 04                	je     800848 <strcmp+0x1c>
  800844:	3a 02                	cmp    (%edx),%al
  800846:	74 ef                	je     800837 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800848:	0f b6 c0             	movzbl %al,%eax
  80084b:	0f b6 12             	movzbl (%edx),%edx
  80084e:	29 d0                	sub    %edx,%eax
}
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	53                   	push   %ebx
  800856:	8b 45 08             	mov    0x8(%ebp),%eax
  800859:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085c:	89 c3                	mov    %eax,%ebx
  80085e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800861:	eb 06                	jmp    800869 <strncmp+0x17>
		n--, p++, q++;
  800863:	83 c0 01             	add    $0x1,%eax
  800866:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800869:	39 d8                	cmp    %ebx,%eax
  80086b:	74 15                	je     800882 <strncmp+0x30>
  80086d:	0f b6 08             	movzbl (%eax),%ecx
  800870:	84 c9                	test   %cl,%cl
  800872:	74 04                	je     800878 <strncmp+0x26>
  800874:	3a 0a                	cmp    (%edx),%cl
  800876:	74 eb                	je     800863 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800878:	0f b6 00             	movzbl (%eax),%eax
  80087b:	0f b6 12             	movzbl (%edx),%edx
  80087e:	29 d0                	sub    %edx,%eax
  800880:	eb 05                	jmp    800887 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800882:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800887:	5b                   	pop    %ebx
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800894:	eb 07                	jmp    80089d <strchr+0x13>
		if (*s == c)
  800896:	38 ca                	cmp    %cl,%dl
  800898:	74 0f                	je     8008a9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80089a:	83 c0 01             	add    $0x1,%eax
  80089d:	0f b6 10             	movzbl (%eax),%edx
  8008a0:	84 d2                	test   %dl,%dl
  8008a2:	75 f2                	jne    800896 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b5:	eb 07                	jmp    8008be <strfind+0x13>
		if (*s == c)
  8008b7:	38 ca                	cmp    %cl,%dl
  8008b9:	74 0a                	je     8008c5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008bb:	83 c0 01             	add    $0x1,%eax
  8008be:	0f b6 10             	movzbl (%eax),%edx
  8008c1:	84 d2                	test   %dl,%dl
  8008c3:	75 f2                	jne    8008b7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	57                   	push   %edi
  8008cb:	56                   	push   %esi
  8008cc:	53                   	push   %ebx
  8008cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d3:	85 c9                	test   %ecx,%ecx
  8008d5:	74 36                	je     80090d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008dd:	75 28                	jne    800907 <memset+0x40>
  8008df:	f6 c1 03             	test   $0x3,%cl
  8008e2:	75 23                	jne    800907 <memset+0x40>
		c &= 0xFF;
  8008e4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e8:	89 d3                	mov    %edx,%ebx
  8008ea:	c1 e3 08             	shl    $0x8,%ebx
  8008ed:	89 d6                	mov    %edx,%esi
  8008ef:	c1 e6 18             	shl    $0x18,%esi
  8008f2:	89 d0                	mov    %edx,%eax
  8008f4:	c1 e0 10             	shl    $0x10,%eax
  8008f7:	09 f0                	or     %esi,%eax
  8008f9:	09 c2                	or     %eax,%edx
  8008fb:	89 d0                	mov    %edx,%eax
  8008fd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008ff:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800902:	fc                   	cld    
  800903:	f3 ab                	rep stos %eax,%es:(%edi)
  800905:	eb 06                	jmp    80090d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800907:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090a:	fc                   	cld    
  80090b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80090d:	89 f8                	mov    %edi,%eax
  80090f:	5b                   	pop    %ebx
  800910:	5e                   	pop    %esi
  800911:	5f                   	pop    %edi
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	57                   	push   %edi
  800918:	56                   	push   %esi
  800919:	8b 45 08             	mov    0x8(%ebp),%eax
  80091c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800922:	39 c6                	cmp    %eax,%esi
  800924:	73 35                	jae    80095b <memmove+0x47>
  800926:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800929:	39 d0                	cmp    %edx,%eax
  80092b:	73 2e                	jae    80095b <memmove+0x47>
		s += n;
		d += n;
  80092d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800930:	89 d6                	mov    %edx,%esi
  800932:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800934:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80093a:	75 13                	jne    80094f <memmove+0x3b>
  80093c:	f6 c1 03             	test   $0x3,%cl
  80093f:	75 0e                	jne    80094f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800941:	83 ef 04             	sub    $0x4,%edi
  800944:	8d 72 fc             	lea    -0x4(%edx),%esi
  800947:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80094a:	fd                   	std    
  80094b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094d:	eb 09                	jmp    800958 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80094f:	83 ef 01             	sub    $0x1,%edi
  800952:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800955:	fd                   	std    
  800956:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800958:	fc                   	cld    
  800959:	eb 1d                	jmp    800978 <memmove+0x64>
  80095b:	89 f2                	mov    %esi,%edx
  80095d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095f:	f6 c2 03             	test   $0x3,%dl
  800962:	75 0f                	jne    800973 <memmove+0x5f>
  800964:	f6 c1 03             	test   $0x3,%cl
  800967:	75 0a                	jne    800973 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800969:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80096c:	89 c7                	mov    %eax,%edi
  80096e:	fc                   	cld    
  80096f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800971:	eb 05                	jmp    800978 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800973:	89 c7                	mov    %eax,%edi
  800975:	fc                   	cld    
  800976:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800978:	5e                   	pop    %esi
  800979:	5f                   	pop    %edi
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800982:	8b 45 10             	mov    0x10(%ebp),%eax
  800985:	89 44 24 08          	mov    %eax,0x8(%esp)
  800989:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	89 04 24             	mov    %eax,(%esp)
  800996:	e8 79 ff ff ff       	call   800914 <memmove>
}
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    

0080099d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	56                   	push   %esi
  8009a1:	53                   	push   %ebx
  8009a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a8:	89 d6                	mov    %edx,%esi
  8009aa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ad:	eb 1a                	jmp    8009c9 <memcmp+0x2c>
		if (*s1 != *s2)
  8009af:	0f b6 02             	movzbl (%edx),%eax
  8009b2:	0f b6 19             	movzbl (%ecx),%ebx
  8009b5:	38 d8                	cmp    %bl,%al
  8009b7:	74 0a                	je     8009c3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009b9:	0f b6 c0             	movzbl %al,%eax
  8009bc:	0f b6 db             	movzbl %bl,%ebx
  8009bf:	29 d8                	sub    %ebx,%eax
  8009c1:	eb 0f                	jmp    8009d2 <memcmp+0x35>
		s1++, s2++;
  8009c3:	83 c2 01             	add    $0x1,%edx
  8009c6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c9:	39 f2                	cmp    %esi,%edx
  8009cb:	75 e2                	jne    8009af <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d2:	5b                   	pop    %ebx
  8009d3:	5e                   	pop    %esi
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009df:	89 c2                	mov    %eax,%edx
  8009e1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009e4:	eb 07                	jmp    8009ed <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e6:	38 08                	cmp    %cl,(%eax)
  8009e8:	74 07                	je     8009f1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ea:	83 c0 01             	add    $0x1,%eax
  8009ed:	39 d0                	cmp    %edx,%eax
  8009ef:	72 f5                	jb     8009e6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009f1:	5d                   	pop    %ebp
  8009f2:	c3                   	ret    

008009f3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	57                   	push   %edi
  8009f7:	56                   	push   %esi
  8009f8:	53                   	push   %ebx
  8009f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8009fc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ff:	eb 03                	jmp    800a04 <strtol+0x11>
		s++;
  800a01:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a04:	0f b6 0a             	movzbl (%edx),%ecx
  800a07:	80 f9 09             	cmp    $0x9,%cl
  800a0a:	74 f5                	je     800a01 <strtol+0xe>
  800a0c:	80 f9 20             	cmp    $0x20,%cl
  800a0f:	74 f0                	je     800a01 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a11:	80 f9 2b             	cmp    $0x2b,%cl
  800a14:	75 0a                	jne    800a20 <strtol+0x2d>
		s++;
  800a16:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a19:	bf 00 00 00 00       	mov    $0x0,%edi
  800a1e:	eb 11                	jmp    800a31 <strtol+0x3e>
  800a20:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a25:	80 f9 2d             	cmp    $0x2d,%cl
  800a28:	75 07                	jne    800a31 <strtol+0x3e>
		s++, neg = 1;
  800a2a:	8d 52 01             	lea    0x1(%edx),%edx
  800a2d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a31:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800a36:	75 15                	jne    800a4d <strtol+0x5a>
  800a38:	80 3a 30             	cmpb   $0x30,(%edx)
  800a3b:	75 10                	jne    800a4d <strtol+0x5a>
  800a3d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a41:	75 0a                	jne    800a4d <strtol+0x5a>
		s += 2, base = 16;
  800a43:	83 c2 02             	add    $0x2,%edx
  800a46:	b8 10 00 00 00       	mov    $0x10,%eax
  800a4b:	eb 10                	jmp    800a5d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800a4d:	85 c0                	test   %eax,%eax
  800a4f:	75 0c                	jne    800a5d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a51:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a53:	80 3a 30             	cmpb   $0x30,(%edx)
  800a56:	75 05                	jne    800a5d <strtol+0x6a>
		s++, base = 8;
  800a58:	83 c2 01             	add    $0x1,%edx
  800a5b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800a5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a62:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a65:	0f b6 0a             	movzbl (%edx),%ecx
  800a68:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800a6b:	89 f0                	mov    %esi,%eax
  800a6d:	3c 09                	cmp    $0x9,%al
  800a6f:	77 08                	ja     800a79 <strtol+0x86>
			dig = *s - '0';
  800a71:	0f be c9             	movsbl %cl,%ecx
  800a74:	83 e9 30             	sub    $0x30,%ecx
  800a77:	eb 20                	jmp    800a99 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800a79:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800a7c:	89 f0                	mov    %esi,%eax
  800a7e:	3c 19                	cmp    $0x19,%al
  800a80:	77 08                	ja     800a8a <strtol+0x97>
			dig = *s - 'a' + 10;
  800a82:	0f be c9             	movsbl %cl,%ecx
  800a85:	83 e9 57             	sub    $0x57,%ecx
  800a88:	eb 0f                	jmp    800a99 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800a8a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800a8d:	89 f0                	mov    %esi,%eax
  800a8f:	3c 19                	cmp    $0x19,%al
  800a91:	77 16                	ja     800aa9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800a93:	0f be c9             	movsbl %cl,%ecx
  800a96:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a99:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800a9c:	7d 0f                	jge    800aad <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800a9e:	83 c2 01             	add    $0x1,%edx
  800aa1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800aa5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800aa7:	eb bc                	jmp    800a65 <strtol+0x72>
  800aa9:	89 d8                	mov    %ebx,%eax
  800aab:	eb 02                	jmp    800aaf <strtol+0xbc>
  800aad:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800aaf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab3:	74 05                	je     800aba <strtol+0xc7>
		*endptr = (char *) s;
  800ab5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800aba:	f7 d8                	neg    %eax
  800abc:	85 ff                	test   %edi,%edi
  800abe:	0f 44 c3             	cmove  %ebx,%eax
}
  800ac1:	5b                   	pop    %ebx
  800ac2:	5e                   	pop    %esi
  800ac3:	5f                   	pop    %edi
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	57                   	push   %edi
  800aca:	56                   	push   %esi
  800acb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad7:	89 c3                	mov    %eax,%ebx
  800ad9:	89 c7                	mov    %eax,%edi
  800adb:	89 c6                	mov    %eax,%esi
  800add:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800adf:	5b                   	pop    %ebx
  800ae0:	5e                   	pop    %esi
  800ae1:	5f                   	pop    %edi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	57                   	push   %edi
  800ae8:	56                   	push   %esi
  800ae9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aea:	ba 00 00 00 00       	mov    $0x0,%edx
  800aef:	b8 01 00 00 00       	mov    $0x1,%eax
  800af4:	89 d1                	mov    %edx,%ecx
  800af6:	89 d3                	mov    %edx,%ebx
  800af8:	89 d7                	mov    %edx,%edi
  800afa:	89 d6                	mov    %edx,%esi
  800afc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800afe:	5b                   	pop    %ebx
  800aff:	5e                   	pop    %esi
  800b00:	5f                   	pop    %edi
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	57                   	push   %edi
  800b07:	56                   	push   %esi
  800b08:	53                   	push   %ebx
  800b09:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b11:	b8 03 00 00 00       	mov    $0x3,%eax
  800b16:	8b 55 08             	mov    0x8(%ebp),%edx
  800b19:	89 cb                	mov    %ecx,%ebx
  800b1b:	89 cf                	mov    %ecx,%edi
  800b1d:	89 ce                	mov    %ecx,%esi
  800b1f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b21:	85 c0                	test   %eax,%eax
  800b23:	7e 28                	jle    800b4d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b25:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b29:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b30:	00 
  800b31:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800b38:	00 
  800b39:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b40:	00 
  800b41:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800b48:	e8 29 16 00 00       	call   802176 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b4d:	83 c4 2c             	add    $0x2c,%esp
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5f                   	pop    %edi
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	57                   	push   %edi
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b60:	b8 02 00 00 00       	mov    $0x2,%eax
  800b65:	89 d1                	mov    %edx,%ecx
  800b67:	89 d3                	mov    %edx,%ebx
  800b69:	89 d7                	mov    %edx,%edi
  800b6b:	89 d6                	mov    %edx,%esi
  800b6d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <sys_yield>:

void
sys_yield(void)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	57                   	push   %edi
  800b78:	56                   	push   %esi
  800b79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b84:	89 d1                	mov    %edx,%ecx
  800b86:	89 d3                	mov    %edx,%ebx
  800b88:	89 d7                	mov    %edx,%edi
  800b8a:	89 d6                	mov    %edx,%esi
  800b8c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b8e:	5b                   	pop    %ebx
  800b8f:	5e                   	pop    %esi
  800b90:	5f                   	pop    %edi
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	57                   	push   %edi
  800b97:	56                   	push   %esi
  800b98:	53                   	push   %ebx
  800b99:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9c:	be 00 00 00 00       	mov    $0x0,%esi
  800ba1:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800baf:	89 f7                	mov    %esi,%edi
  800bb1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb3:	85 c0                	test   %eax,%eax
  800bb5:	7e 28                	jle    800bdf <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bbb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bc2:	00 
  800bc3:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800bca:	00 
  800bcb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bd2:	00 
  800bd3:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800bda:	e8 97 15 00 00       	call   802176 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bdf:	83 c4 2c             	add    $0x2c,%esp
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5f                   	pop    %edi
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	57                   	push   %edi
  800beb:	56                   	push   %esi
  800bec:	53                   	push   %ebx
  800bed:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf0:	b8 05 00 00 00       	mov    $0x5,%eax
  800bf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bfe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c01:	8b 75 18             	mov    0x18(%ebp),%esi
  800c04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c06:	85 c0                	test   %eax,%eax
  800c08:	7e 28                	jle    800c32 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c0e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c15:	00 
  800c16:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800c1d:	00 
  800c1e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c25:	00 
  800c26:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800c2d:	e8 44 15 00 00       	call   802176 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c32:	83 c4 2c             	add    $0x2c,%esp
  800c35:	5b                   	pop    %ebx
  800c36:	5e                   	pop    %esi
  800c37:	5f                   	pop    %edi
  800c38:	5d                   	pop    %ebp
  800c39:	c3                   	ret    

00800c3a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	57                   	push   %edi
  800c3e:	56                   	push   %esi
  800c3f:	53                   	push   %ebx
  800c40:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c48:	b8 06 00 00 00       	mov    $0x6,%eax
  800c4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c50:	8b 55 08             	mov    0x8(%ebp),%edx
  800c53:	89 df                	mov    %ebx,%edi
  800c55:	89 de                	mov    %ebx,%esi
  800c57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c59:	85 c0                	test   %eax,%eax
  800c5b:	7e 28                	jle    800c85 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c61:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c68:	00 
  800c69:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800c70:	00 
  800c71:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c78:	00 
  800c79:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800c80:	e8 f1 14 00 00       	call   802176 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c85:	83 c4 2c             	add    $0x2c,%esp
  800c88:	5b                   	pop    %ebx
  800c89:	5e                   	pop    %esi
  800c8a:	5f                   	pop    %edi
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	57                   	push   %edi
  800c91:	56                   	push   %esi
  800c92:	53                   	push   %ebx
  800c93:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9b:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca6:	89 df                	mov    %ebx,%edi
  800ca8:	89 de                	mov    %ebx,%esi
  800caa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cac:	85 c0                	test   %eax,%eax
  800cae:	7e 28                	jle    800cd8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cb4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800cbb:	00 
  800cbc:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800cc3:	00 
  800cc4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ccb:	00 
  800ccc:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800cd3:	e8 9e 14 00 00       	call   802176 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cd8:	83 c4 2c             	add    $0x2c,%esp
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	57                   	push   %edi
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
  800ce6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cee:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf9:	89 df                	mov    %ebx,%edi
  800cfb:	89 de                	mov    %ebx,%esi
  800cfd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cff:	85 c0                	test   %eax,%eax
  800d01:	7e 28                	jle    800d2b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d03:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d07:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d0e:	00 
  800d0f:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800d16:	00 
  800d17:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d1e:	00 
  800d1f:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800d26:	e8 4b 14 00 00       	call   802176 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d2b:	83 c4 2c             	add    $0x2c,%esp
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	57                   	push   %edi
  800d37:	56                   	push   %esi
  800d38:	53                   	push   %ebx
  800d39:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d41:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d49:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4c:	89 df                	mov    %ebx,%edi
  800d4e:	89 de                	mov    %ebx,%esi
  800d50:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d52:	85 c0                	test   %eax,%eax
  800d54:	7e 28                	jle    800d7e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d56:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d61:	00 
  800d62:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800d69:	00 
  800d6a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d71:	00 
  800d72:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800d79:	e8 f8 13 00 00       	call   802176 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d7e:	83 c4 2c             	add    $0x2c,%esp
  800d81:	5b                   	pop    %ebx
  800d82:	5e                   	pop    %esi
  800d83:	5f                   	pop    %edi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    

00800d86 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	57                   	push   %edi
  800d8a:	56                   	push   %esi
  800d8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8c:	be 00 00 00 00       	mov    $0x0,%esi
  800d91:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d99:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	57                   	push   %edi
  800dad:	56                   	push   %esi
  800dae:	53                   	push   %ebx
  800daf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbf:	89 cb                	mov    %ecx,%ebx
  800dc1:	89 cf                	mov    %ecx,%edi
  800dc3:	89 ce                	mov    %ecx,%esi
  800dc5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc7:	85 c0                	test   %eax,%eax
  800dc9:	7e 28                	jle    800df3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dcf:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800dd6:	00 
  800dd7:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800dde:	00 
  800ddf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de6:	00 
  800de7:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800dee:	e8 83 13 00 00       	call   802176 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800df3:	83 c4 2c             	add    $0x2c,%esp
  800df6:	5b                   	pop    %ebx
  800df7:	5e                   	pop    %esi
  800df8:	5f                   	pop    %edi
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	57                   	push   %edi
  800dff:	56                   	push   %esi
  800e00:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e01:	ba 00 00 00 00       	mov    $0x0,%edx
  800e06:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e0b:	89 d1                	mov    %edx,%ecx
  800e0d:	89 d3                	mov    %edx,%ebx
  800e0f:	89 d7                	mov    %edx,%edi
  800e11:	89 d6                	mov    %edx,%esi
  800e13:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5f                   	pop    %edi
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    

00800e1a <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  800e1a:	55                   	push   %ebp
  800e1b:	89 e5                	mov    %esp,%ebp
  800e1d:	57                   	push   %edi
  800e1e:	56                   	push   %esi
  800e1f:	53                   	push   %ebx
  800e20:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e23:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e28:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e30:	8b 55 08             	mov    0x8(%ebp),%edx
  800e33:	89 df                	mov    %ebx,%edi
  800e35:	89 de                	mov    %ebx,%esi
  800e37:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e39:	85 c0                	test   %eax,%eax
  800e3b:	7e 28                	jle    800e65 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e41:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800e48:	00 
  800e49:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800e50:	00 
  800e51:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e58:	00 
  800e59:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800e60:	e8 11 13 00 00       	call   802176 <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  800e65:	83 c4 2c             	add    $0x2c,%esp
  800e68:	5b                   	pop    %ebx
  800e69:	5e                   	pop    %esi
  800e6a:	5f                   	pop    %edi
  800e6b:	5d                   	pop    %ebp
  800e6c:	c3                   	ret    

00800e6d <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  800e6d:	55                   	push   %ebp
  800e6e:	89 e5                	mov    %esp,%ebp
  800e70:	57                   	push   %edi
  800e71:	56                   	push   %esi
  800e72:	53                   	push   %ebx
  800e73:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7b:	b8 10 00 00 00       	mov    $0x10,%eax
  800e80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e83:	8b 55 08             	mov    0x8(%ebp),%edx
  800e86:	89 df                	mov    %ebx,%edi
  800e88:	89 de                	mov    %ebx,%esi
  800e8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e8c:	85 c0                	test   %eax,%eax
  800e8e:	7e 28                	jle    800eb8 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e90:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e94:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  800e9b:	00 
  800e9c:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800ea3:	00 
  800ea4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eab:	00 
  800eac:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800eb3:	e8 be 12 00 00       	call   802176 <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  800eb8:	83 c4 2c             	add    $0x2c,%esp
  800ebb:	5b                   	pop    %ebx
  800ebc:	5e                   	pop    %esi
  800ebd:	5f                   	pop    %edi
  800ebe:	5d                   	pop    %ebp
  800ebf:	c3                   	ret    

00800ec0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ec0:	55                   	push   %ebp
  800ec1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ec3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec6:	05 00 00 00 30       	add    $0x30000000,%eax
  800ecb:	c1 e8 0c             	shr    $0xc,%eax
}
  800ece:	5d                   	pop    %ebp
  800ecf:	c3                   	ret    

00800ed0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ed3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800edb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ee0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    

00800ee7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eed:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ef2:	89 c2                	mov    %eax,%edx
  800ef4:	c1 ea 16             	shr    $0x16,%edx
  800ef7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800efe:	f6 c2 01             	test   $0x1,%dl
  800f01:	74 11                	je     800f14 <fd_alloc+0x2d>
  800f03:	89 c2                	mov    %eax,%edx
  800f05:	c1 ea 0c             	shr    $0xc,%edx
  800f08:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f0f:	f6 c2 01             	test   $0x1,%dl
  800f12:	75 09                	jne    800f1d <fd_alloc+0x36>
			*fd_store = fd;
  800f14:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f16:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1b:	eb 17                	jmp    800f34 <fd_alloc+0x4d>
  800f1d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f22:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f27:	75 c9                	jne    800ef2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f29:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f2f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f34:	5d                   	pop    %ebp
  800f35:	c3                   	ret    

00800f36 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f3c:	83 f8 1f             	cmp    $0x1f,%eax
  800f3f:	77 36                	ja     800f77 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f41:	c1 e0 0c             	shl    $0xc,%eax
  800f44:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f49:	89 c2                	mov    %eax,%edx
  800f4b:	c1 ea 16             	shr    $0x16,%edx
  800f4e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f55:	f6 c2 01             	test   $0x1,%dl
  800f58:	74 24                	je     800f7e <fd_lookup+0x48>
  800f5a:	89 c2                	mov    %eax,%edx
  800f5c:	c1 ea 0c             	shr    $0xc,%edx
  800f5f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f66:	f6 c2 01             	test   $0x1,%dl
  800f69:	74 1a                	je     800f85 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f6e:	89 02                	mov    %eax,(%edx)
	return 0;
  800f70:	b8 00 00 00 00       	mov    $0x0,%eax
  800f75:	eb 13                	jmp    800f8a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f77:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f7c:	eb 0c                	jmp    800f8a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f7e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f83:	eb 05                	jmp    800f8a <fd_lookup+0x54>
  800f85:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f8a:	5d                   	pop    %ebp
  800f8b:	c3                   	ret    

00800f8c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	83 ec 18             	sub    $0x18,%esp
  800f92:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800f95:	ba 00 00 00 00       	mov    $0x0,%edx
  800f9a:	eb 13                	jmp    800faf <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  800f9c:	39 08                	cmp    %ecx,(%eax)
  800f9e:	75 0c                	jne    800fac <dev_lookup+0x20>
			*dev = devtab[i];
  800fa0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa3:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fa5:	b8 00 00 00 00       	mov    $0x0,%eax
  800faa:	eb 38                	jmp    800fe4 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fac:	83 c2 01             	add    $0x1,%edx
  800faf:	8b 04 95 a8 29 80 00 	mov    0x8029a8(,%edx,4),%eax
  800fb6:	85 c0                	test   %eax,%eax
  800fb8:	75 e2                	jne    800f9c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fba:	a1 08 40 80 00       	mov    0x804008,%eax
  800fbf:	8b 40 48             	mov    0x48(%eax),%eax
  800fc2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fca:	c7 04 24 2c 29 80 00 	movl   $0x80292c,(%esp)
  800fd1:	e8 7e f1 ff ff       	call   800154 <cprintf>
	*dev = 0;
  800fd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fdf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fe4:	c9                   	leave  
  800fe5:	c3                   	ret    

00800fe6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fe6:	55                   	push   %ebp
  800fe7:	89 e5                	mov    %esp,%ebp
  800fe9:	56                   	push   %esi
  800fea:	53                   	push   %ebx
  800feb:	83 ec 20             	sub    $0x20,%esp
  800fee:	8b 75 08             	mov    0x8(%ebp),%esi
  800ff1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ff4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff7:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ffb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801001:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801004:	89 04 24             	mov    %eax,(%esp)
  801007:	e8 2a ff ff ff       	call   800f36 <fd_lookup>
  80100c:	85 c0                	test   %eax,%eax
  80100e:	78 05                	js     801015 <fd_close+0x2f>
	    || fd != fd2)
  801010:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801013:	74 0c                	je     801021 <fd_close+0x3b>
		return (must_exist ? r : 0);
  801015:	84 db                	test   %bl,%bl
  801017:	ba 00 00 00 00       	mov    $0x0,%edx
  80101c:	0f 44 c2             	cmove  %edx,%eax
  80101f:	eb 3f                	jmp    801060 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801021:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801024:	89 44 24 04          	mov    %eax,0x4(%esp)
  801028:	8b 06                	mov    (%esi),%eax
  80102a:	89 04 24             	mov    %eax,(%esp)
  80102d:	e8 5a ff ff ff       	call   800f8c <dev_lookup>
  801032:	89 c3                	mov    %eax,%ebx
  801034:	85 c0                	test   %eax,%eax
  801036:	78 16                	js     80104e <fd_close+0x68>
		if (dev->dev_close)
  801038:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80103b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80103e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801043:	85 c0                	test   %eax,%eax
  801045:	74 07                	je     80104e <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801047:	89 34 24             	mov    %esi,(%esp)
  80104a:	ff d0                	call   *%eax
  80104c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80104e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801052:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801059:	e8 dc fb ff ff       	call   800c3a <sys_page_unmap>
	return r;
  80105e:	89 d8                	mov    %ebx,%eax
}
  801060:	83 c4 20             	add    $0x20,%esp
  801063:	5b                   	pop    %ebx
  801064:	5e                   	pop    %esi
  801065:	5d                   	pop    %ebp
  801066:	c3                   	ret    

00801067 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801067:	55                   	push   %ebp
  801068:	89 e5                	mov    %esp,%ebp
  80106a:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80106d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801070:	89 44 24 04          	mov    %eax,0x4(%esp)
  801074:	8b 45 08             	mov    0x8(%ebp),%eax
  801077:	89 04 24             	mov    %eax,(%esp)
  80107a:	e8 b7 fe ff ff       	call   800f36 <fd_lookup>
  80107f:	89 c2                	mov    %eax,%edx
  801081:	85 d2                	test   %edx,%edx
  801083:	78 13                	js     801098 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801085:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80108c:	00 
  80108d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801090:	89 04 24             	mov    %eax,(%esp)
  801093:	e8 4e ff ff ff       	call   800fe6 <fd_close>
}
  801098:	c9                   	leave  
  801099:	c3                   	ret    

0080109a <close_all>:

void
close_all(void)
{
  80109a:	55                   	push   %ebp
  80109b:	89 e5                	mov    %esp,%ebp
  80109d:	53                   	push   %ebx
  80109e:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010a1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010a6:	89 1c 24             	mov    %ebx,(%esp)
  8010a9:	e8 b9 ff ff ff       	call   801067 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010ae:	83 c3 01             	add    $0x1,%ebx
  8010b1:	83 fb 20             	cmp    $0x20,%ebx
  8010b4:	75 f0                	jne    8010a6 <close_all+0xc>
		close(i);
}
  8010b6:	83 c4 14             	add    $0x14,%esp
  8010b9:	5b                   	pop    %ebx
  8010ba:	5d                   	pop    %ebp
  8010bb:	c3                   	ret    

008010bc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	57                   	push   %edi
  8010c0:	56                   	push   %esi
  8010c1:	53                   	push   %ebx
  8010c2:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010c5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cf:	89 04 24             	mov    %eax,(%esp)
  8010d2:	e8 5f fe ff ff       	call   800f36 <fd_lookup>
  8010d7:	89 c2                	mov    %eax,%edx
  8010d9:	85 d2                	test   %edx,%edx
  8010db:	0f 88 e1 00 00 00    	js     8011c2 <dup+0x106>
		return r;
	close(newfdnum);
  8010e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010e4:	89 04 24             	mov    %eax,(%esp)
  8010e7:	e8 7b ff ff ff       	call   801067 <close>

	newfd = INDEX2FD(newfdnum);
  8010ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8010ef:	c1 e3 0c             	shl    $0xc,%ebx
  8010f2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010fb:	89 04 24             	mov    %eax,(%esp)
  8010fe:	e8 cd fd ff ff       	call   800ed0 <fd2data>
  801103:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801105:	89 1c 24             	mov    %ebx,(%esp)
  801108:	e8 c3 fd ff ff       	call   800ed0 <fd2data>
  80110d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80110f:	89 f0                	mov    %esi,%eax
  801111:	c1 e8 16             	shr    $0x16,%eax
  801114:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80111b:	a8 01                	test   $0x1,%al
  80111d:	74 43                	je     801162 <dup+0xa6>
  80111f:	89 f0                	mov    %esi,%eax
  801121:	c1 e8 0c             	shr    $0xc,%eax
  801124:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80112b:	f6 c2 01             	test   $0x1,%dl
  80112e:	74 32                	je     801162 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801130:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801137:	25 07 0e 00 00       	and    $0xe07,%eax
  80113c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801140:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801144:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80114b:	00 
  80114c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801150:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801157:	e8 8b fa ff ff       	call   800be7 <sys_page_map>
  80115c:	89 c6                	mov    %eax,%esi
  80115e:	85 c0                	test   %eax,%eax
  801160:	78 3e                	js     8011a0 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801162:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801165:	89 c2                	mov    %eax,%edx
  801167:	c1 ea 0c             	shr    $0xc,%edx
  80116a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801171:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801177:	89 54 24 10          	mov    %edx,0x10(%esp)
  80117b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80117f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801186:	00 
  801187:	89 44 24 04          	mov    %eax,0x4(%esp)
  80118b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801192:	e8 50 fa ff ff       	call   800be7 <sys_page_map>
  801197:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801199:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80119c:	85 f6                	test   %esi,%esi
  80119e:	79 22                	jns    8011c2 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011ab:	e8 8a fa ff ff       	call   800c3a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011b0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011bb:	e8 7a fa ff ff       	call   800c3a <sys_page_unmap>
	return r;
  8011c0:	89 f0                	mov    %esi,%eax
}
  8011c2:	83 c4 3c             	add    $0x3c,%esp
  8011c5:	5b                   	pop    %ebx
  8011c6:	5e                   	pop    %esi
  8011c7:	5f                   	pop    %edi
  8011c8:	5d                   	pop    %ebp
  8011c9:	c3                   	ret    

008011ca <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011ca:	55                   	push   %ebp
  8011cb:	89 e5                	mov    %esp,%ebp
  8011cd:	53                   	push   %ebx
  8011ce:	83 ec 24             	sub    $0x24,%esp
  8011d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011db:	89 1c 24             	mov    %ebx,(%esp)
  8011de:	e8 53 fd ff ff       	call   800f36 <fd_lookup>
  8011e3:	89 c2                	mov    %eax,%edx
  8011e5:	85 d2                	test   %edx,%edx
  8011e7:	78 6d                	js     801256 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f3:	8b 00                	mov    (%eax),%eax
  8011f5:	89 04 24             	mov    %eax,(%esp)
  8011f8:	e8 8f fd ff ff       	call   800f8c <dev_lookup>
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	78 55                	js     801256 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801201:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801204:	8b 50 08             	mov    0x8(%eax),%edx
  801207:	83 e2 03             	and    $0x3,%edx
  80120a:	83 fa 01             	cmp    $0x1,%edx
  80120d:	75 23                	jne    801232 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80120f:	a1 08 40 80 00       	mov    0x804008,%eax
  801214:	8b 40 48             	mov    0x48(%eax),%eax
  801217:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80121b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80121f:	c7 04 24 6d 29 80 00 	movl   $0x80296d,(%esp)
  801226:	e8 29 ef ff ff       	call   800154 <cprintf>
		return -E_INVAL;
  80122b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801230:	eb 24                	jmp    801256 <read+0x8c>
	}
	if (!dev->dev_read)
  801232:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801235:	8b 52 08             	mov    0x8(%edx),%edx
  801238:	85 d2                	test   %edx,%edx
  80123a:	74 15                	je     801251 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80123c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80123f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801243:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801246:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80124a:	89 04 24             	mov    %eax,(%esp)
  80124d:	ff d2                	call   *%edx
  80124f:	eb 05                	jmp    801256 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801251:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801256:	83 c4 24             	add    $0x24,%esp
  801259:	5b                   	pop    %ebx
  80125a:	5d                   	pop    %ebp
  80125b:	c3                   	ret    

0080125c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
  80125f:	57                   	push   %edi
  801260:	56                   	push   %esi
  801261:	53                   	push   %ebx
  801262:	83 ec 1c             	sub    $0x1c,%esp
  801265:	8b 7d 08             	mov    0x8(%ebp),%edi
  801268:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80126b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801270:	eb 23                	jmp    801295 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801272:	89 f0                	mov    %esi,%eax
  801274:	29 d8                	sub    %ebx,%eax
  801276:	89 44 24 08          	mov    %eax,0x8(%esp)
  80127a:	89 d8                	mov    %ebx,%eax
  80127c:	03 45 0c             	add    0xc(%ebp),%eax
  80127f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801283:	89 3c 24             	mov    %edi,(%esp)
  801286:	e8 3f ff ff ff       	call   8011ca <read>
		if (m < 0)
  80128b:	85 c0                	test   %eax,%eax
  80128d:	78 10                	js     80129f <readn+0x43>
			return m;
		if (m == 0)
  80128f:	85 c0                	test   %eax,%eax
  801291:	74 0a                	je     80129d <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801293:	01 c3                	add    %eax,%ebx
  801295:	39 f3                	cmp    %esi,%ebx
  801297:	72 d9                	jb     801272 <readn+0x16>
  801299:	89 d8                	mov    %ebx,%eax
  80129b:	eb 02                	jmp    80129f <readn+0x43>
  80129d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80129f:	83 c4 1c             	add    $0x1c,%esp
  8012a2:	5b                   	pop    %ebx
  8012a3:	5e                   	pop    %esi
  8012a4:	5f                   	pop    %edi
  8012a5:	5d                   	pop    %ebp
  8012a6:	c3                   	ret    

008012a7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012a7:	55                   	push   %ebp
  8012a8:	89 e5                	mov    %esp,%ebp
  8012aa:	53                   	push   %ebx
  8012ab:	83 ec 24             	sub    $0x24,%esp
  8012ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b8:	89 1c 24             	mov    %ebx,(%esp)
  8012bb:	e8 76 fc ff ff       	call   800f36 <fd_lookup>
  8012c0:	89 c2                	mov    %eax,%edx
  8012c2:	85 d2                	test   %edx,%edx
  8012c4:	78 68                	js     80132e <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d0:	8b 00                	mov    (%eax),%eax
  8012d2:	89 04 24             	mov    %eax,(%esp)
  8012d5:	e8 b2 fc ff ff       	call   800f8c <dev_lookup>
  8012da:	85 c0                	test   %eax,%eax
  8012dc:	78 50                	js     80132e <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012e5:	75 23                	jne    80130a <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012e7:	a1 08 40 80 00       	mov    0x804008,%eax
  8012ec:	8b 40 48             	mov    0x48(%eax),%eax
  8012ef:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f7:	c7 04 24 89 29 80 00 	movl   $0x802989,(%esp)
  8012fe:	e8 51 ee ff ff       	call   800154 <cprintf>
		return -E_INVAL;
  801303:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801308:	eb 24                	jmp    80132e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80130a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80130d:	8b 52 0c             	mov    0xc(%edx),%edx
  801310:	85 d2                	test   %edx,%edx
  801312:	74 15                	je     801329 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801314:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801317:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80131b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80131e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801322:	89 04 24             	mov    %eax,(%esp)
  801325:	ff d2                	call   *%edx
  801327:	eb 05                	jmp    80132e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801329:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80132e:	83 c4 24             	add    $0x24,%esp
  801331:	5b                   	pop    %ebx
  801332:	5d                   	pop    %ebp
  801333:	c3                   	ret    

00801334 <seek>:

int
seek(int fdnum, off_t offset)
{
  801334:	55                   	push   %ebp
  801335:	89 e5                	mov    %esp,%ebp
  801337:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80133a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80133d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801341:	8b 45 08             	mov    0x8(%ebp),%eax
  801344:	89 04 24             	mov    %eax,(%esp)
  801347:	e8 ea fb ff ff       	call   800f36 <fd_lookup>
  80134c:	85 c0                	test   %eax,%eax
  80134e:	78 0e                	js     80135e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801350:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801353:	8b 55 0c             	mov    0xc(%ebp),%edx
  801356:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801359:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80135e:	c9                   	leave  
  80135f:	c3                   	ret    

00801360 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
  801363:	53                   	push   %ebx
  801364:	83 ec 24             	sub    $0x24,%esp
  801367:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80136a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80136d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801371:	89 1c 24             	mov    %ebx,(%esp)
  801374:	e8 bd fb ff ff       	call   800f36 <fd_lookup>
  801379:	89 c2                	mov    %eax,%edx
  80137b:	85 d2                	test   %edx,%edx
  80137d:	78 61                	js     8013e0 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80137f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801382:	89 44 24 04          	mov    %eax,0x4(%esp)
  801386:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801389:	8b 00                	mov    (%eax),%eax
  80138b:	89 04 24             	mov    %eax,(%esp)
  80138e:	e8 f9 fb ff ff       	call   800f8c <dev_lookup>
  801393:	85 c0                	test   %eax,%eax
  801395:	78 49                	js     8013e0 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801397:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80139e:	75 23                	jne    8013c3 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013a0:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013a5:	8b 40 48             	mov    0x48(%eax),%eax
  8013a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b0:	c7 04 24 4c 29 80 00 	movl   $0x80294c,(%esp)
  8013b7:	e8 98 ed ff ff       	call   800154 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013c1:	eb 1d                	jmp    8013e0 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8013c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013c6:	8b 52 18             	mov    0x18(%edx),%edx
  8013c9:	85 d2                	test   %edx,%edx
  8013cb:	74 0e                	je     8013db <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013d0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013d4:	89 04 24             	mov    %eax,(%esp)
  8013d7:	ff d2                	call   *%edx
  8013d9:	eb 05                	jmp    8013e0 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013db:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8013e0:	83 c4 24             	add    $0x24,%esp
  8013e3:	5b                   	pop    %ebx
  8013e4:	5d                   	pop    %ebp
  8013e5:	c3                   	ret    

008013e6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
  8013e9:	53                   	push   %ebx
  8013ea:	83 ec 24             	sub    $0x24,%esp
  8013ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fa:	89 04 24             	mov    %eax,(%esp)
  8013fd:	e8 34 fb ff ff       	call   800f36 <fd_lookup>
  801402:	89 c2                	mov    %eax,%edx
  801404:	85 d2                	test   %edx,%edx
  801406:	78 52                	js     80145a <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801408:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80140b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801412:	8b 00                	mov    (%eax),%eax
  801414:	89 04 24             	mov    %eax,(%esp)
  801417:	e8 70 fb ff ff       	call   800f8c <dev_lookup>
  80141c:	85 c0                	test   %eax,%eax
  80141e:	78 3a                	js     80145a <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801420:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801423:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801427:	74 2c                	je     801455 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801429:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80142c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801433:	00 00 00 
	stat->st_isdir = 0;
  801436:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80143d:	00 00 00 
	stat->st_dev = dev;
  801440:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801446:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80144a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80144d:	89 14 24             	mov    %edx,(%esp)
  801450:	ff 50 14             	call   *0x14(%eax)
  801453:	eb 05                	jmp    80145a <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801455:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80145a:	83 c4 24             	add    $0x24,%esp
  80145d:	5b                   	pop    %ebx
  80145e:	5d                   	pop    %ebp
  80145f:	c3                   	ret    

00801460 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	56                   	push   %esi
  801464:	53                   	push   %ebx
  801465:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801468:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80146f:	00 
  801470:	8b 45 08             	mov    0x8(%ebp),%eax
  801473:	89 04 24             	mov    %eax,(%esp)
  801476:	e8 28 02 00 00       	call   8016a3 <open>
  80147b:	89 c3                	mov    %eax,%ebx
  80147d:	85 db                	test   %ebx,%ebx
  80147f:	78 1b                	js     80149c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801481:	8b 45 0c             	mov    0xc(%ebp),%eax
  801484:	89 44 24 04          	mov    %eax,0x4(%esp)
  801488:	89 1c 24             	mov    %ebx,(%esp)
  80148b:	e8 56 ff ff ff       	call   8013e6 <fstat>
  801490:	89 c6                	mov    %eax,%esi
	close(fd);
  801492:	89 1c 24             	mov    %ebx,(%esp)
  801495:	e8 cd fb ff ff       	call   801067 <close>
	return r;
  80149a:	89 f0                	mov    %esi,%eax
}
  80149c:	83 c4 10             	add    $0x10,%esp
  80149f:	5b                   	pop    %ebx
  8014a0:	5e                   	pop    %esi
  8014a1:	5d                   	pop    %ebp
  8014a2:	c3                   	ret    

008014a3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	56                   	push   %esi
  8014a7:	53                   	push   %ebx
  8014a8:	83 ec 10             	sub    $0x10,%esp
  8014ab:	89 c6                	mov    %eax,%esi
  8014ad:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014af:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014b6:	75 11                	jne    8014c9 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014b8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8014bf:	e8 f1 0d 00 00       	call   8022b5 <ipc_find_env>
  8014c4:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014c9:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8014d0:	00 
  8014d1:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8014d8:	00 
  8014d9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014dd:	a1 00 40 80 00       	mov    0x804000,%eax
  8014e2:	89 04 24             	mov    %eax,(%esp)
  8014e5:	e8 60 0d 00 00       	call   80224a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014ea:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014f1:	00 
  8014f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014fd:	e8 ce 0c 00 00       	call   8021d0 <ipc_recv>
}
  801502:	83 c4 10             	add    $0x10,%esp
  801505:	5b                   	pop    %ebx
  801506:	5e                   	pop    %esi
  801507:	5d                   	pop    %ebp
  801508:	c3                   	ret    

00801509 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801509:	55                   	push   %ebp
  80150a:	89 e5                	mov    %esp,%ebp
  80150c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80150f:	8b 45 08             	mov    0x8(%ebp),%eax
  801512:	8b 40 0c             	mov    0xc(%eax),%eax
  801515:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80151a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80151d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801522:	ba 00 00 00 00       	mov    $0x0,%edx
  801527:	b8 02 00 00 00       	mov    $0x2,%eax
  80152c:	e8 72 ff ff ff       	call   8014a3 <fsipc>
}
  801531:	c9                   	leave  
  801532:	c3                   	ret    

00801533 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801533:	55                   	push   %ebp
  801534:	89 e5                	mov    %esp,%ebp
  801536:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801539:	8b 45 08             	mov    0x8(%ebp),%eax
  80153c:	8b 40 0c             	mov    0xc(%eax),%eax
  80153f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801544:	ba 00 00 00 00       	mov    $0x0,%edx
  801549:	b8 06 00 00 00       	mov    $0x6,%eax
  80154e:	e8 50 ff ff ff       	call   8014a3 <fsipc>
}
  801553:	c9                   	leave  
  801554:	c3                   	ret    

00801555 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801555:	55                   	push   %ebp
  801556:	89 e5                	mov    %esp,%ebp
  801558:	53                   	push   %ebx
  801559:	83 ec 14             	sub    $0x14,%esp
  80155c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80155f:	8b 45 08             	mov    0x8(%ebp),%eax
  801562:	8b 40 0c             	mov    0xc(%eax),%eax
  801565:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80156a:	ba 00 00 00 00       	mov    $0x0,%edx
  80156f:	b8 05 00 00 00       	mov    $0x5,%eax
  801574:	e8 2a ff ff ff       	call   8014a3 <fsipc>
  801579:	89 c2                	mov    %eax,%edx
  80157b:	85 d2                	test   %edx,%edx
  80157d:	78 2b                	js     8015aa <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80157f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801586:	00 
  801587:	89 1c 24             	mov    %ebx,(%esp)
  80158a:	e8 e8 f1 ff ff       	call   800777 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80158f:	a1 80 50 80 00       	mov    0x805080,%eax
  801594:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80159a:	a1 84 50 80 00       	mov    0x805084,%eax
  80159f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015aa:	83 c4 14             	add    $0x14,%esp
  8015ad:	5b                   	pop    %ebx
  8015ae:	5d                   	pop    %ebp
  8015af:	c3                   	ret    

008015b0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015b0:	55                   	push   %ebp
  8015b1:	89 e5                	mov    %esp,%ebp
  8015b3:	83 ec 18             	sub    $0x18,%esp
  8015b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8015b9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8015be:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8015c3:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8015c9:	8b 52 0c             	mov    0xc(%edx),%edx
  8015cc:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8015d2:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  8015d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e2:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8015e9:	e8 26 f3 ff ff       	call   800914 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  8015ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f3:	b8 04 00 00 00       	mov    $0x4,%eax
  8015f8:	e8 a6 fe ff ff       	call   8014a3 <fsipc>
}
  8015fd:	c9                   	leave  
  8015fe:	c3                   	ret    

008015ff <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	56                   	push   %esi
  801603:	53                   	push   %ebx
  801604:	83 ec 10             	sub    $0x10,%esp
  801607:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80160a:	8b 45 08             	mov    0x8(%ebp),%eax
  80160d:	8b 40 0c             	mov    0xc(%eax),%eax
  801610:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801615:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80161b:	ba 00 00 00 00       	mov    $0x0,%edx
  801620:	b8 03 00 00 00       	mov    $0x3,%eax
  801625:	e8 79 fe ff ff       	call   8014a3 <fsipc>
  80162a:	89 c3                	mov    %eax,%ebx
  80162c:	85 c0                	test   %eax,%eax
  80162e:	78 6a                	js     80169a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801630:	39 c6                	cmp    %eax,%esi
  801632:	73 24                	jae    801658 <devfile_read+0x59>
  801634:	c7 44 24 0c bc 29 80 	movl   $0x8029bc,0xc(%esp)
  80163b:	00 
  80163c:	c7 44 24 08 c3 29 80 	movl   $0x8029c3,0x8(%esp)
  801643:	00 
  801644:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80164b:	00 
  80164c:	c7 04 24 d8 29 80 00 	movl   $0x8029d8,(%esp)
  801653:	e8 1e 0b 00 00       	call   802176 <_panic>
	assert(r <= PGSIZE);
  801658:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80165d:	7e 24                	jle    801683 <devfile_read+0x84>
  80165f:	c7 44 24 0c e3 29 80 	movl   $0x8029e3,0xc(%esp)
  801666:	00 
  801667:	c7 44 24 08 c3 29 80 	movl   $0x8029c3,0x8(%esp)
  80166e:	00 
  80166f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801676:	00 
  801677:	c7 04 24 d8 29 80 00 	movl   $0x8029d8,(%esp)
  80167e:	e8 f3 0a 00 00       	call   802176 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801683:	89 44 24 08          	mov    %eax,0x8(%esp)
  801687:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80168e:	00 
  80168f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801692:	89 04 24             	mov    %eax,(%esp)
  801695:	e8 7a f2 ff ff       	call   800914 <memmove>
	return r;
}
  80169a:	89 d8                	mov    %ebx,%eax
  80169c:	83 c4 10             	add    $0x10,%esp
  80169f:	5b                   	pop    %ebx
  8016a0:	5e                   	pop    %esi
  8016a1:	5d                   	pop    %ebp
  8016a2:	c3                   	ret    

008016a3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016a3:	55                   	push   %ebp
  8016a4:	89 e5                	mov    %esp,%ebp
  8016a6:	53                   	push   %ebx
  8016a7:	83 ec 24             	sub    $0x24,%esp
  8016aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016ad:	89 1c 24             	mov    %ebx,(%esp)
  8016b0:	e8 8b f0 ff ff       	call   800740 <strlen>
  8016b5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016ba:	7f 60                	jg     80171c <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016bf:	89 04 24             	mov    %eax,(%esp)
  8016c2:	e8 20 f8 ff ff       	call   800ee7 <fd_alloc>
  8016c7:	89 c2                	mov    %eax,%edx
  8016c9:	85 d2                	test   %edx,%edx
  8016cb:	78 54                	js     801721 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016d1:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8016d8:	e8 9a f0 ff ff       	call   800777 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e0:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e8:	b8 01 00 00 00       	mov    $0x1,%eax
  8016ed:	e8 b1 fd ff ff       	call   8014a3 <fsipc>
  8016f2:	89 c3                	mov    %eax,%ebx
  8016f4:	85 c0                	test   %eax,%eax
  8016f6:	79 17                	jns    80170f <open+0x6c>
		fd_close(fd, 0);
  8016f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016ff:	00 
  801700:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801703:	89 04 24             	mov    %eax,(%esp)
  801706:	e8 db f8 ff ff       	call   800fe6 <fd_close>
		return r;
  80170b:	89 d8                	mov    %ebx,%eax
  80170d:	eb 12                	jmp    801721 <open+0x7e>
	}

	return fd2num(fd);
  80170f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801712:	89 04 24             	mov    %eax,(%esp)
  801715:	e8 a6 f7 ff ff       	call   800ec0 <fd2num>
  80171a:	eb 05                	jmp    801721 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80171c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801721:	83 c4 24             	add    $0x24,%esp
  801724:	5b                   	pop    %ebx
  801725:	5d                   	pop    %ebp
  801726:	c3                   	ret    

00801727 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80172d:	ba 00 00 00 00       	mov    $0x0,%edx
  801732:	b8 08 00 00 00       	mov    $0x8,%eax
  801737:	e8 67 fd ff ff       	call   8014a3 <fsipc>
}
  80173c:	c9                   	leave  
  80173d:	c3                   	ret    
  80173e:	66 90                	xchg   %ax,%ax

00801740 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801746:	c7 44 24 04 ef 29 80 	movl   $0x8029ef,0x4(%esp)
  80174d:	00 
  80174e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801751:	89 04 24             	mov    %eax,(%esp)
  801754:	e8 1e f0 ff ff       	call   800777 <strcpy>
	return 0;
}
  801759:	b8 00 00 00 00       	mov    $0x0,%eax
  80175e:	c9                   	leave  
  80175f:	c3                   	ret    

00801760 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801760:	55                   	push   %ebp
  801761:	89 e5                	mov    %esp,%ebp
  801763:	53                   	push   %ebx
  801764:	83 ec 14             	sub    $0x14,%esp
  801767:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80176a:	89 1c 24             	mov    %ebx,(%esp)
  80176d:	e8 7b 0b 00 00       	call   8022ed <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801772:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801777:	83 f8 01             	cmp    $0x1,%eax
  80177a:	75 0d                	jne    801789 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80177c:	8b 43 0c             	mov    0xc(%ebx),%eax
  80177f:	89 04 24             	mov    %eax,(%esp)
  801782:	e8 29 03 00 00       	call   801ab0 <nsipc_close>
  801787:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  801789:	89 d0                	mov    %edx,%eax
  80178b:	83 c4 14             	add    $0x14,%esp
  80178e:	5b                   	pop    %ebx
  80178f:	5d                   	pop    %ebp
  801790:	c3                   	ret    

00801791 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801791:	55                   	push   %ebp
  801792:	89 e5                	mov    %esp,%ebp
  801794:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801797:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80179e:	00 
  80179f:	8b 45 10             	mov    0x10(%ebp),%eax
  8017a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b3:	89 04 24             	mov    %eax,(%esp)
  8017b6:	e8 f0 03 00 00       	call   801bab <nsipc_send>
}
  8017bb:	c9                   	leave  
  8017bc:	c3                   	ret    

008017bd <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8017c3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8017ca:	00 
  8017cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8017ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017dc:	8b 40 0c             	mov    0xc(%eax),%eax
  8017df:	89 04 24             	mov    %eax,(%esp)
  8017e2:	e8 44 03 00 00       	call   801b2b <nsipc_recv>
}
  8017e7:	c9                   	leave  
  8017e8:	c3                   	ret    

008017e9 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8017ef:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8017f2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017f6:	89 04 24             	mov    %eax,(%esp)
  8017f9:	e8 38 f7 ff ff       	call   800f36 <fd_lookup>
  8017fe:	85 c0                	test   %eax,%eax
  801800:	78 17                	js     801819 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801802:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801805:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80180b:	39 08                	cmp    %ecx,(%eax)
  80180d:	75 05                	jne    801814 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80180f:	8b 40 0c             	mov    0xc(%eax),%eax
  801812:	eb 05                	jmp    801819 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801814:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801819:	c9                   	leave  
  80181a:	c3                   	ret    

0080181b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	56                   	push   %esi
  80181f:	53                   	push   %ebx
  801820:	83 ec 20             	sub    $0x20,%esp
  801823:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801825:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801828:	89 04 24             	mov    %eax,(%esp)
  80182b:	e8 b7 f6 ff ff       	call   800ee7 <fd_alloc>
  801830:	89 c3                	mov    %eax,%ebx
  801832:	85 c0                	test   %eax,%eax
  801834:	78 21                	js     801857 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801836:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80183d:	00 
  80183e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801841:	89 44 24 04          	mov    %eax,0x4(%esp)
  801845:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80184c:	e8 42 f3 ff ff       	call   800b93 <sys_page_alloc>
  801851:	89 c3                	mov    %eax,%ebx
  801853:	85 c0                	test   %eax,%eax
  801855:	79 0c                	jns    801863 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  801857:	89 34 24             	mov    %esi,(%esp)
  80185a:	e8 51 02 00 00       	call   801ab0 <nsipc_close>
		return r;
  80185f:	89 d8                	mov    %ebx,%eax
  801861:	eb 20                	jmp    801883 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801863:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801869:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80186c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80186e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801871:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801878:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  80187b:	89 14 24             	mov    %edx,(%esp)
  80187e:	e8 3d f6 ff ff       	call   800ec0 <fd2num>
}
  801883:	83 c4 20             	add    $0x20,%esp
  801886:	5b                   	pop    %ebx
  801887:	5e                   	pop    %esi
  801888:	5d                   	pop    %ebp
  801889:	c3                   	ret    

0080188a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801890:	8b 45 08             	mov    0x8(%ebp),%eax
  801893:	e8 51 ff ff ff       	call   8017e9 <fd2sockid>
		return r;
  801898:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80189a:	85 c0                	test   %eax,%eax
  80189c:	78 23                	js     8018c1 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80189e:	8b 55 10             	mov    0x10(%ebp),%edx
  8018a1:	89 54 24 08          	mov    %edx,0x8(%esp)
  8018a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018a8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018ac:	89 04 24             	mov    %eax,(%esp)
  8018af:	e8 45 01 00 00       	call   8019f9 <nsipc_accept>
		return r;
  8018b4:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8018b6:	85 c0                	test   %eax,%eax
  8018b8:	78 07                	js     8018c1 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  8018ba:	e8 5c ff ff ff       	call   80181b <alloc_sockfd>
  8018bf:	89 c1                	mov    %eax,%ecx
}
  8018c1:	89 c8                	mov    %ecx,%eax
  8018c3:	c9                   	leave  
  8018c4:	c3                   	ret    

008018c5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ce:	e8 16 ff ff ff       	call   8017e9 <fd2sockid>
  8018d3:	89 c2                	mov    %eax,%edx
  8018d5:	85 d2                	test   %edx,%edx
  8018d7:	78 16                	js     8018ef <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  8018d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8018dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e7:	89 14 24             	mov    %edx,(%esp)
  8018ea:	e8 60 01 00 00       	call   801a4f <nsipc_bind>
}
  8018ef:	c9                   	leave  
  8018f0:	c3                   	ret    

008018f1 <shutdown>:

int
shutdown(int s, int how)
{
  8018f1:	55                   	push   %ebp
  8018f2:	89 e5                	mov    %esp,%ebp
  8018f4:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fa:	e8 ea fe ff ff       	call   8017e9 <fd2sockid>
  8018ff:	89 c2                	mov    %eax,%edx
  801901:	85 d2                	test   %edx,%edx
  801903:	78 0f                	js     801914 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801905:	8b 45 0c             	mov    0xc(%ebp),%eax
  801908:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190c:	89 14 24             	mov    %edx,(%esp)
  80190f:	e8 7a 01 00 00       	call   801a8e <nsipc_shutdown>
}
  801914:	c9                   	leave  
  801915:	c3                   	ret    

00801916 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80191c:	8b 45 08             	mov    0x8(%ebp),%eax
  80191f:	e8 c5 fe ff ff       	call   8017e9 <fd2sockid>
  801924:	89 c2                	mov    %eax,%edx
  801926:	85 d2                	test   %edx,%edx
  801928:	78 16                	js     801940 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  80192a:	8b 45 10             	mov    0x10(%ebp),%eax
  80192d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801931:	8b 45 0c             	mov    0xc(%ebp),%eax
  801934:	89 44 24 04          	mov    %eax,0x4(%esp)
  801938:	89 14 24             	mov    %edx,(%esp)
  80193b:	e8 8a 01 00 00       	call   801aca <nsipc_connect>
}
  801940:	c9                   	leave  
  801941:	c3                   	ret    

00801942 <listen>:

int
listen(int s, int backlog)
{
  801942:	55                   	push   %ebp
  801943:	89 e5                	mov    %esp,%ebp
  801945:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801948:	8b 45 08             	mov    0x8(%ebp),%eax
  80194b:	e8 99 fe ff ff       	call   8017e9 <fd2sockid>
  801950:	89 c2                	mov    %eax,%edx
  801952:	85 d2                	test   %edx,%edx
  801954:	78 0f                	js     801965 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801956:	8b 45 0c             	mov    0xc(%ebp),%eax
  801959:	89 44 24 04          	mov    %eax,0x4(%esp)
  80195d:	89 14 24             	mov    %edx,(%esp)
  801960:	e8 a4 01 00 00       	call   801b09 <nsipc_listen>
}
  801965:	c9                   	leave  
  801966:	c3                   	ret    

00801967 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801967:	55                   	push   %ebp
  801968:	89 e5                	mov    %esp,%ebp
  80196a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80196d:	8b 45 10             	mov    0x10(%ebp),%eax
  801970:	89 44 24 08          	mov    %eax,0x8(%esp)
  801974:	8b 45 0c             	mov    0xc(%ebp),%eax
  801977:	89 44 24 04          	mov    %eax,0x4(%esp)
  80197b:	8b 45 08             	mov    0x8(%ebp),%eax
  80197e:	89 04 24             	mov    %eax,(%esp)
  801981:	e8 98 02 00 00       	call   801c1e <nsipc_socket>
  801986:	89 c2                	mov    %eax,%edx
  801988:	85 d2                	test   %edx,%edx
  80198a:	78 05                	js     801991 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  80198c:	e8 8a fe ff ff       	call   80181b <alloc_sockfd>
}
  801991:	c9                   	leave  
  801992:	c3                   	ret    

00801993 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801993:	55                   	push   %ebp
  801994:	89 e5                	mov    %esp,%ebp
  801996:	53                   	push   %ebx
  801997:	83 ec 14             	sub    $0x14,%esp
  80199a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80199c:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8019a3:	75 11                	jne    8019b6 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8019a5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8019ac:	e8 04 09 00 00       	call   8022b5 <ipc_find_env>
  8019b1:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8019b6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8019bd:	00 
  8019be:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8019c5:	00 
  8019c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019ca:	a1 04 40 80 00       	mov    0x804004,%eax
  8019cf:	89 04 24             	mov    %eax,(%esp)
  8019d2:	e8 73 08 00 00       	call   80224a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8019d7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019de:	00 
  8019df:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019e6:	00 
  8019e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019ee:	e8 dd 07 00 00       	call   8021d0 <ipc_recv>
}
  8019f3:	83 c4 14             	add    $0x14,%esp
  8019f6:	5b                   	pop    %ebx
  8019f7:	5d                   	pop    %ebp
  8019f8:	c3                   	ret    

008019f9 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8019f9:	55                   	push   %ebp
  8019fa:	89 e5                	mov    %esp,%ebp
  8019fc:	56                   	push   %esi
  8019fd:	53                   	push   %ebx
  8019fe:	83 ec 10             	sub    $0x10,%esp
  801a01:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801a04:	8b 45 08             	mov    0x8(%ebp),%eax
  801a07:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801a0c:	8b 06                	mov    (%esi),%eax
  801a0e:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801a13:	b8 01 00 00 00       	mov    $0x1,%eax
  801a18:	e8 76 ff ff ff       	call   801993 <nsipc>
  801a1d:	89 c3                	mov    %eax,%ebx
  801a1f:	85 c0                	test   %eax,%eax
  801a21:	78 23                	js     801a46 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801a23:	a1 10 60 80 00       	mov    0x806010,%eax
  801a28:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a2c:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801a33:	00 
  801a34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a37:	89 04 24             	mov    %eax,(%esp)
  801a3a:	e8 d5 ee ff ff       	call   800914 <memmove>
		*addrlen = ret->ret_addrlen;
  801a3f:	a1 10 60 80 00       	mov    0x806010,%eax
  801a44:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801a46:	89 d8                	mov    %ebx,%eax
  801a48:	83 c4 10             	add    $0x10,%esp
  801a4b:	5b                   	pop    %ebx
  801a4c:	5e                   	pop    %esi
  801a4d:	5d                   	pop    %ebp
  801a4e:	c3                   	ret    

00801a4f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a4f:	55                   	push   %ebp
  801a50:	89 e5                	mov    %esp,%ebp
  801a52:	53                   	push   %ebx
  801a53:	83 ec 14             	sub    $0x14,%esp
  801a56:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801a59:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801a61:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a65:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a68:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a6c:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801a73:	e8 9c ee ff ff       	call   800914 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801a78:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801a7e:	b8 02 00 00 00       	mov    $0x2,%eax
  801a83:	e8 0b ff ff ff       	call   801993 <nsipc>
}
  801a88:	83 c4 14             	add    $0x14,%esp
  801a8b:	5b                   	pop    %ebx
  801a8c:	5d                   	pop    %ebp
  801a8d:	c3                   	ret    

00801a8e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801a8e:	55                   	push   %ebp
  801a8f:	89 e5                	mov    %esp,%ebp
  801a91:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801a94:	8b 45 08             	mov    0x8(%ebp),%eax
  801a97:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801a9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801aa4:	b8 03 00 00 00       	mov    $0x3,%eax
  801aa9:	e8 e5 fe ff ff       	call   801993 <nsipc>
}
  801aae:	c9                   	leave  
  801aaf:	c3                   	ret    

00801ab0 <nsipc_close>:

int
nsipc_close(int s)
{
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
  801ab3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ab6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab9:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801abe:	b8 04 00 00 00       	mov    $0x4,%eax
  801ac3:	e8 cb fe ff ff       	call   801993 <nsipc>
}
  801ac8:	c9                   	leave  
  801ac9:	c3                   	ret    

00801aca <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801aca:	55                   	push   %ebp
  801acb:	89 e5                	mov    %esp,%ebp
  801acd:	53                   	push   %ebx
  801ace:	83 ec 14             	sub    $0x14,%esp
  801ad1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad7:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801adc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ae0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae7:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801aee:	e8 21 ee ff ff       	call   800914 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801af3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801af9:	b8 05 00 00 00       	mov    $0x5,%eax
  801afe:	e8 90 fe ff ff       	call   801993 <nsipc>
}
  801b03:	83 c4 14             	add    $0x14,%esp
  801b06:	5b                   	pop    %ebx
  801b07:	5d                   	pop    %ebp
  801b08:	c3                   	ret    

00801b09 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801b09:	55                   	push   %ebp
  801b0a:	89 e5                	mov    %esp,%ebp
  801b0c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b12:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801b17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b1a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801b1f:	b8 06 00 00 00       	mov    $0x6,%eax
  801b24:	e8 6a fe ff ff       	call   801993 <nsipc>
}
  801b29:	c9                   	leave  
  801b2a:	c3                   	ret    

00801b2b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	56                   	push   %esi
  801b2f:	53                   	push   %ebx
  801b30:	83 ec 10             	sub    $0x10,%esp
  801b33:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801b36:	8b 45 08             	mov    0x8(%ebp),%eax
  801b39:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801b3e:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801b44:	8b 45 14             	mov    0x14(%ebp),%eax
  801b47:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801b4c:	b8 07 00 00 00       	mov    $0x7,%eax
  801b51:	e8 3d fe ff ff       	call   801993 <nsipc>
  801b56:	89 c3                	mov    %eax,%ebx
  801b58:	85 c0                	test   %eax,%eax
  801b5a:	78 46                	js     801ba2 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801b5c:	39 f0                	cmp    %esi,%eax
  801b5e:	7f 07                	jg     801b67 <nsipc_recv+0x3c>
  801b60:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801b65:	7e 24                	jle    801b8b <nsipc_recv+0x60>
  801b67:	c7 44 24 0c fb 29 80 	movl   $0x8029fb,0xc(%esp)
  801b6e:	00 
  801b6f:	c7 44 24 08 c3 29 80 	movl   $0x8029c3,0x8(%esp)
  801b76:	00 
  801b77:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801b7e:	00 
  801b7f:	c7 04 24 10 2a 80 00 	movl   $0x802a10,(%esp)
  801b86:	e8 eb 05 00 00       	call   802176 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801b8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b8f:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801b96:	00 
  801b97:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b9a:	89 04 24             	mov    %eax,(%esp)
  801b9d:	e8 72 ed ff ff       	call   800914 <memmove>
	}

	return r;
}
  801ba2:	89 d8                	mov    %ebx,%eax
  801ba4:	83 c4 10             	add    $0x10,%esp
  801ba7:	5b                   	pop    %ebx
  801ba8:	5e                   	pop    %esi
  801ba9:	5d                   	pop    %ebp
  801baa:	c3                   	ret    

00801bab <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	53                   	push   %ebx
  801baf:	83 ec 14             	sub    $0x14,%esp
  801bb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801bb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb8:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801bbd:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801bc3:	7e 24                	jle    801be9 <nsipc_send+0x3e>
  801bc5:	c7 44 24 0c 1c 2a 80 	movl   $0x802a1c,0xc(%esp)
  801bcc:	00 
  801bcd:	c7 44 24 08 c3 29 80 	movl   $0x8029c3,0x8(%esp)
  801bd4:	00 
  801bd5:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801bdc:	00 
  801bdd:	c7 04 24 10 2a 80 00 	movl   $0x802a10,(%esp)
  801be4:	e8 8d 05 00 00       	call   802176 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801be9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bed:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf4:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801bfb:	e8 14 ed ff ff       	call   800914 <memmove>
	nsipcbuf.send.req_size = size;
  801c00:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801c06:	8b 45 14             	mov    0x14(%ebp),%eax
  801c09:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801c0e:	b8 08 00 00 00       	mov    $0x8,%eax
  801c13:	e8 7b fd ff ff       	call   801993 <nsipc>
}
  801c18:	83 c4 14             	add    $0x14,%esp
  801c1b:	5b                   	pop    %ebx
  801c1c:	5d                   	pop    %ebp
  801c1d:	c3                   	ret    

00801c1e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801c1e:	55                   	push   %ebp
  801c1f:	89 e5                	mov    %esp,%ebp
  801c21:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c24:	8b 45 08             	mov    0x8(%ebp),%eax
  801c27:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801c2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c2f:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801c34:	8b 45 10             	mov    0x10(%ebp),%eax
  801c37:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801c3c:	b8 09 00 00 00       	mov    $0x9,%eax
  801c41:	e8 4d fd ff ff       	call   801993 <nsipc>
}
  801c46:	c9                   	leave  
  801c47:	c3                   	ret    

00801c48 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
  801c4b:	56                   	push   %esi
  801c4c:	53                   	push   %ebx
  801c4d:	83 ec 10             	sub    $0x10,%esp
  801c50:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c53:	8b 45 08             	mov    0x8(%ebp),%eax
  801c56:	89 04 24             	mov    %eax,(%esp)
  801c59:	e8 72 f2 ff ff       	call   800ed0 <fd2data>
  801c5e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c60:	c7 44 24 04 28 2a 80 	movl   $0x802a28,0x4(%esp)
  801c67:	00 
  801c68:	89 1c 24             	mov    %ebx,(%esp)
  801c6b:	e8 07 eb ff ff       	call   800777 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c70:	8b 46 04             	mov    0x4(%esi),%eax
  801c73:	2b 06                	sub    (%esi),%eax
  801c75:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c7b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c82:	00 00 00 
	stat->st_dev = &devpipe;
  801c85:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801c8c:	30 80 00 
	return 0;
}
  801c8f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c94:	83 c4 10             	add    $0x10,%esp
  801c97:	5b                   	pop    %ebx
  801c98:	5e                   	pop    %esi
  801c99:	5d                   	pop    %ebp
  801c9a:	c3                   	ret    

00801c9b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c9b:	55                   	push   %ebp
  801c9c:	89 e5                	mov    %esp,%ebp
  801c9e:	53                   	push   %ebx
  801c9f:	83 ec 14             	sub    $0x14,%esp
  801ca2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ca5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ca9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cb0:	e8 85 ef ff ff       	call   800c3a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cb5:	89 1c 24             	mov    %ebx,(%esp)
  801cb8:	e8 13 f2 ff ff       	call   800ed0 <fd2data>
  801cbd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cc8:	e8 6d ef ff ff       	call   800c3a <sys_page_unmap>
}
  801ccd:	83 c4 14             	add    $0x14,%esp
  801cd0:	5b                   	pop    %ebx
  801cd1:	5d                   	pop    %ebp
  801cd2:	c3                   	ret    

00801cd3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cd3:	55                   	push   %ebp
  801cd4:	89 e5                	mov    %esp,%ebp
  801cd6:	57                   	push   %edi
  801cd7:	56                   	push   %esi
  801cd8:	53                   	push   %ebx
  801cd9:	83 ec 2c             	sub    $0x2c,%esp
  801cdc:	89 c6                	mov    %eax,%esi
  801cde:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ce1:	a1 08 40 80 00       	mov    0x804008,%eax
  801ce6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ce9:	89 34 24             	mov    %esi,(%esp)
  801cec:	e8 fc 05 00 00       	call   8022ed <pageref>
  801cf1:	89 c7                	mov    %eax,%edi
  801cf3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cf6:	89 04 24             	mov    %eax,(%esp)
  801cf9:	e8 ef 05 00 00       	call   8022ed <pageref>
  801cfe:	39 c7                	cmp    %eax,%edi
  801d00:	0f 94 c2             	sete   %dl
  801d03:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801d06:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801d0c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801d0f:	39 fb                	cmp    %edi,%ebx
  801d11:	74 21                	je     801d34 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801d13:	84 d2                	test   %dl,%dl
  801d15:	74 ca                	je     801ce1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d17:	8b 51 58             	mov    0x58(%ecx),%edx
  801d1a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d1e:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d22:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d26:	c7 04 24 2f 2a 80 00 	movl   $0x802a2f,(%esp)
  801d2d:	e8 22 e4 ff ff       	call   800154 <cprintf>
  801d32:	eb ad                	jmp    801ce1 <_pipeisclosed+0xe>
	}
}
  801d34:	83 c4 2c             	add    $0x2c,%esp
  801d37:	5b                   	pop    %ebx
  801d38:	5e                   	pop    %esi
  801d39:	5f                   	pop    %edi
  801d3a:	5d                   	pop    %ebp
  801d3b:	c3                   	ret    

00801d3c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	57                   	push   %edi
  801d40:	56                   	push   %esi
  801d41:	53                   	push   %ebx
  801d42:	83 ec 1c             	sub    $0x1c,%esp
  801d45:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d48:	89 34 24             	mov    %esi,(%esp)
  801d4b:	e8 80 f1 ff ff       	call   800ed0 <fd2data>
  801d50:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d52:	bf 00 00 00 00       	mov    $0x0,%edi
  801d57:	eb 45                	jmp    801d9e <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d59:	89 da                	mov    %ebx,%edx
  801d5b:	89 f0                	mov    %esi,%eax
  801d5d:	e8 71 ff ff ff       	call   801cd3 <_pipeisclosed>
  801d62:	85 c0                	test   %eax,%eax
  801d64:	75 41                	jne    801da7 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d66:	e8 09 ee ff ff       	call   800b74 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d6b:	8b 43 04             	mov    0x4(%ebx),%eax
  801d6e:	8b 0b                	mov    (%ebx),%ecx
  801d70:	8d 51 20             	lea    0x20(%ecx),%edx
  801d73:	39 d0                	cmp    %edx,%eax
  801d75:	73 e2                	jae    801d59 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d7a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d7e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d81:	99                   	cltd   
  801d82:	c1 ea 1b             	shr    $0x1b,%edx
  801d85:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801d88:	83 e1 1f             	and    $0x1f,%ecx
  801d8b:	29 d1                	sub    %edx,%ecx
  801d8d:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801d91:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801d95:	83 c0 01             	add    $0x1,%eax
  801d98:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d9b:	83 c7 01             	add    $0x1,%edi
  801d9e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801da1:	75 c8                	jne    801d6b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801da3:	89 f8                	mov    %edi,%eax
  801da5:	eb 05                	jmp    801dac <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801da7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801dac:	83 c4 1c             	add    $0x1c,%esp
  801daf:	5b                   	pop    %ebx
  801db0:	5e                   	pop    %esi
  801db1:	5f                   	pop    %edi
  801db2:	5d                   	pop    %ebp
  801db3:	c3                   	ret    

00801db4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801db4:	55                   	push   %ebp
  801db5:	89 e5                	mov    %esp,%ebp
  801db7:	57                   	push   %edi
  801db8:	56                   	push   %esi
  801db9:	53                   	push   %ebx
  801dba:	83 ec 1c             	sub    $0x1c,%esp
  801dbd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801dc0:	89 3c 24             	mov    %edi,(%esp)
  801dc3:	e8 08 f1 ff ff       	call   800ed0 <fd2data>
  801dc8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dca:	be 00 00 00 00       	mov    $0x0,%esi
  801dcf:	eb 3d                	jmp    801e0e <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801dd1:	85 f6                	test   %esi,%esi
  801dd3:	74 04                	je     801dd9 <devpipe_read+0x25>
				return i;
  801dd5:	89 f0                	mov    %esi,%eax
  801dd7:	eb 43                	jmp    801e1c <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801dd9:	89 da                	mov    %ebx,%edx
  801ddb:	89 f8                	mov    %edi,%eax
  801ddd:	e8 f1 fe ff ff       	call   801cd3 <_pipeisclosed>
  801de2:	85 c0                	test   %eax,%eax
  801de4:	75 31                	jne    801e17 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801de6:	e8 89 ed ff ff       	call   800b74 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801deb:	8b 03                	mov    (%ebx),%eax
  801ded:	3b 43 04             	cmp    0x4(%ebx),%eax
  801df0:	74 df                	je     801dd1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801df2:	99                   	cltd   
  801df3:	c1 ea 1b             	shr    $0x1b,%edx
  801df6:	01 d0                	add    %edx,%eax
  801df8:	83 e0 1f             	and    $0x1f,%eax
  801dfb:	29 d0                	sub    %edx,%eax
  801dfd:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e05:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801e08:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e0b:	83 c6 01             	add    $0x1,%esi
  801e0e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e11:	75 d8                	jne    801deb <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e13:	89 f0                	mov    %esi,%eax
  801e15:	eb 05                	jmp    801e1c <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e17:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e1c:	83 c4 1c             	add    $0x1c,%esp
  801e1f:	5b                   	pop    %ebx
  801e20:	5e                   	pop    %esi
  801e21:	5f                   	pop    %edi
  801e22:	5d                   	pop    %ebp
  801e23:	c3                   	ret    

00801e24 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e24:	55                   	push   %ebp
  801e25:	89 e5                	mov    %esp,%ebp
  801e27:	56                   	push   %esi
  801e28:	53                   	push   %ebx
  801e29:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e2f:	89 04 24             	mov    %eax,(%esp)
  801e32:	e8 b0 f0 ff ff       	call   800ee7 <fd_alloc>
  801e37:	89 c2                	mov    %eax,%edx
  801e39:	85 d2                	test   %edx,%edx
  801e3b:	0f 88 4d 01 00 00    	js     801f8e <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e41:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e48:	00 
  801e49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e50:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e57:	e8 37 ed ff ff       	call   800b93 <sys_page_alloc>
  801e5c:	89 c2                	mov    %eax,%edx
  801e5e:	85 d2                	test   %edx,%edx
  801e60:	0f 88 28 01 00 00    	js     801f8e <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e66:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e69:	89 04 24             	mov    %eax,(%esp)
  801e6c:	e8 76 f0 ff ff       	call   800ee7 <fd_alloc>
  801e71:	89 c3                	mov    %eax,%ebx
  801e73:	85 c0                	test   %eax,%eax
  801e75:	0f 88 fe 00 00 00    	js     801f79 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e7b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e82:	00 
  801e83:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e86:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e8a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e91:	e8 fd ec ff ff       	call   800b93 <sys_page_alloc>
  801e96:	89 c3                	mov    %eax,%ebx
  801e98:	85 c0                	test   %eax,%eax
  801e9a:	0f 88 d9 00 00 00    	js     801f79 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea3:	89 04 24             	mov    %eax,(%esp)
  801ea6:	e8 25 f0 ff ff       	call   800ed0 <fd2data>
  801eab:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ead:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801eb4:	00 
  801eb5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ec0:	e8 ce ec ff ff       	call   800b93 <sys_page_alloc>
  801ec5:	89 c3                	mov    %eax,%ebx
  801ec7:	85 c0                	test   %eax,%eax
  801ec9:	0f 88 97 00 00 00    	js     801f66 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ecf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ed2:	89 04 24             	mov    %eax,(%esp)
  801ed5:	e8 f6 ef ff ff       	call   800ed0 <fd2data>
  801eda:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801ee1:	00 
  801ee2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ee6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801eed:	00 
  801eee:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ef2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ef9:	e8 e9 ec ff ff       	call   800be7 <sys_page_map>
  801efe:	89 c3                	mov    %eax,%ebx
  801f00:	85 c0                	test   %eax,%eax
  801f02:	78 52                	js     801f56 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f04:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f12:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f19:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f22:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f24:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f27:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f31:	89 04 24             	mov    %eax,(%esp)
  801f34:	e8 87 ef ff ff       	call   800ec0 <fd2num>
  801f39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f3c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f41:	89 04 24             	mov    %eax,(%esp)
  801f44:	e8 77 ef ff ff       	call   800ec0 <fd2num>
  801f49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f4c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f4f:	b8 00 00 00 00       	mov    $0x0,%eax
  801f54:	eb 38                	jmp    801f8e <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  801f56:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f5a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f61:	e8 d4 ec ff ff       	call   800c3a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801f66:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f69:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f6d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f74:	e8 c1 ec ff ff       	call   800c3a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f80:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f87:	e8 ae ec ff ff       	call   800c3a <sys_page_unmap>
  801f8c:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801f8e:	83 c4 30             	add    $0x30,%esp
  801f91:	5b                   	pop    %ebx
  801f92:	5e                   	pop    %esi
  801f93:	5d                   	pop    %ebp
  801f94:	c3                   	ret    

00801f95 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f95:	55                   	push   %ebp
  801f96:	89 e5                	mov    %esp,%ebp
  801f98:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa5:	89 04 24             	mov    %eax,(%esp)
  801fa8:	e8 89 ef ff ff       	call   800f36 <fd_lookup>
  801fad:	89 c2                	mov    %eax,%edx
  801faf:	85 d2                	test   %edx,%edx
  801fb1:	78 15                	js     801fc8 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb6:	89 04 24             	mov    %eax,(%esp)
  801fb9:	e8 12 ef ff ff       	call   800ed0 <fd2data>
	return _pipeisclosed(fd, p);
  801fbe:	89 c2                	mov    %eax,%edx
  801fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc3:	e8 0b fd ff ff       	call   801cd3 <_pipeisclosed>
}
  801fc8:	c9                   	leave  
  801fc9:	c3                   	ret    
  801fca:	66 90                	xchg   %ax,%ax
  801fcc:	66 90                	xchg   %ax,%ax
  801fce:	66 90                	xchg   %ax,%ax

00801fd0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fd0:	55                   	push   %ebp
  801fd1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fd3:	b8 00 00 00 00       	mov    $0x0,%eax
  801fd8:	5d                   	pop    %ebp
  801fd9:	c3                   	ret    

00801fda <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fda:	55                   	push   %ebp
  801fdb:	89 e5                	mov    %esp,%ebp
  801fdd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801fe0:	c7 44 24 04 47 2a 80 	movl   $0x802a47,0x4(%esp)
  801fe7:	00 
  801fe8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801feb:	89 04 24             	mov    %eax,(%esp)
  801fee:	e8 84 e7 ff ff       	call   800777 <strcpy>
	return 0;
}
  801ff3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff8:	c9                   	leave  
  801ff9:	c3                   	ret    

00801ffa <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ffa:	55                   	push   %ebp
  801ffb:	89 e5                	mov    %esp,%ebp
  801ffd:	57                   	push   %edi
  801ffe:	56                   	push   %esi
  801fff:	53                   	push   %ebx
  802000:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802006:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80200b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802011:	eb 31                	jmp    802044 <devcons_write+0x4a>
		m = n - tot;
  802013:	8b 75 10             	mov    0x10(%ebp),%esi
  802016:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802018:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80201b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802020:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802023:	89 74 24 08          	mov    %esi,0x8(%esp)
  802027:	03 45 0c             	add    0xc(%ebp),%eax
  80202a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80202e:	89 3c 24             	mov    %edi,(%esp)
  802031:	e8 de e8 ff ff       	call   800914 <memmove>
		sys_cputs(buf, m);
  802036:	89 74 24 04          	mov    %esi,0x4(%esp)
  80203a:	89 3c 24             	mov    %edi,(%esp)
  80203d:	e8 84 ea ff ff       	call   800ac6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802042:	01 f3                	add    %esi,%ebx
  802044:	89 d8                	mov    %ebx,%eax
  802046:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802049:	72 c8                	jb     802013 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80204b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802051:	5b                   	pop    %ebx
  802052:	5e                   	pop    %esi
  802053:	5f                   	pop    %edi
  802054:	5d                   	pop    %ebp
  802055:	c3                   	ret    

00802056 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802056:	55                   	push   %ebp
  802057:	89 e5                	mov    %esp,%ebp
  802059:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80205c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802061:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802065:	75 07                	jne    80206e <devcons_read+0x18>
  802067:	eb 2a                	jmp    802093 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802069:	e8 06 eb ff ff       	call   800b74 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80206e:	66 90                	xchg   %ax,%ax
  802070:	e8 6f ea ff ff       	call   800ae4 <sys_cgetc>
  802075:	85 c0                	test   %eax,%eax
  802077:	74 f0                	je     802069 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802079:	85 c0                	test   %eax,%eax
  80207b:	78 16                	js     802093 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80207d:	83 f8 04             	cmp    $0x4,%eax
  802080:	74 0c                	je     80208e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802082:	8b 55 0c             	mov    0xc(%ebp),%edx
  802085:	88 02                	mov    %al,(%edx)
	return 1;
  802087:	b8 01 00 00 00       	mov    $0x1,%eax
  80208c:	eb 05                	jmp    802093 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80208e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802093:	c9                   	leave  
  802094:	c3                   	ret    

00802095 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802095:	55                   	push   %ebp
  802096:	89 e5                	mov    %esp,%ebp
  802098:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80209b:	8b 45 08             	mov    0x8(%ebp),%eax
  80209e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020a1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8020a8:	00 
  8020a9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020ac:	89 04 24             	mov    %eax,(%esp)
  8020af:	e8 12 ea ff ff       	call   800ac6 <sys_cputs>
}
  8020b4:	c9                   	leave  
  8020b5:	c3                   	ret    

008020b6 <getchar>:

int
getchar(void)
{
  8020b6:	55                   	push   %ebp
  8020b7:	89 e5                	mov    %esp,%ebp
  8020b9:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020bc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8020c3:	00 
  8020c4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020d2:	e8 f3 f0 ff ff       	call   8011ca <read>
	if (r < 0)
  8020d7:	85 c0                	test   %eax,%eax
  8020d9:	78 0f                	js     8020ea <getchar+0x34>
		return r;
	if (r < 1)
  8020db:	85 c0                	test   %eax,%eax
  8020dd:	7e 06                	jle    8020e5 <getchar+0x2f>
		return -E_EOF;
	return c;
  8020df:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020e3:	eb 05                	jmp    8020ea <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020e5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020ea:	c9                   	leave  
  8020eb:	c3                   	ret    

008020ec <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020ec:	55                   	push   %ebp
  8020ed:	89 e5                	mov    %esp,%ebp
  8020ef:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8020fc:	89 04 24             	mov    %eax,(%esp)
  8020ff:	e8 32 ee ff ff       	call   800f36 <fd_lookup>
  802104:	85 c0                	test   %eax,%eax
  802106:	78 11                	js     802119 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802108:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80210b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802111:	39 10                	cmp    %edx,(%eax)
  802113:	0f 94 c0             	sete   %al
  802116:	0f b6 c0             	movzbl %al,%eax
}
  802119:	c9                   	leave  
  80211a:	c3                   	ret    

0080211b <opencons>:

int
opencons(void)
{
  80211b:	55                   	push   %ebp
  80211c:	89 e5                	mov    %esp,%ebp
  80211e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802121:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802124:	89 04 24             	mov    %eax,(%esp)
  802127:	e8 bb ed ff ff       	call   800ee7 <fd_alloc>
		return r;
  80212c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80212e:	85 c0                	test   %eax,%eax
  802130:	78 40                	js     802172 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802132:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802139:	00 
  80213a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802141:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802148:	e8 46 ea ff ff       	call   800b93 <sys_page_alloc>
		return r;
  80214d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80214f:	85 c0                	test   %eax,%eax
  802151:	78 1f                	js     802172 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802153:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802159:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80215c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80215e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802161:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802168:	89 04 24             	mov    %eax,(%esp)
  80216b:	e8 50 ed ff ff       	call   800ec0 <fd2num>
  802170:	89 c2                	mov    %eax,%edx
}
  802172:	89 d0                	mov    %edx,%eax
  802174:	c9                   	leave  
  802175:	c3                   	ret    

00802176 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802176:	55                   	push   %ebp
  802177:	89 e5                	mov    %esp,%ebp
  802179:	56                   	push   %esi
  80217a:	53                   	push   %ebx
  80217b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80217e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802181:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802187:	e8 c9 e9 ff ff       	call   800b55 <sys_getenvid>
  80218c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80218f:	89 54 24 10          	mov    %edx,0x10(%esp)
  802193:	8b 55 08             	mov    0x8(%ebp),%edx
  802196:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80219a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80219e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021a2:	c7 04 24 54 2a 80 00 	movl   $0x802a54,(%esp)
  8021a9:	e8 a6 df ff ff       	call   800154 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8021ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8021b5:	89 04 24             	mov    %eax,(%esp)
  8021b8:	e8 36 df ff ff       	call   8000f3 <vcprintf>
	cprintf("\n");
  8021bd:	c7 04 24 40 2a 80 00 	movl   $0x802a40,(%esp)
  8021c4:	e8 8b df ff ff       	call   800154 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8021c9:	cc                   	int3   
  8021ca:	eb fd                	jmp    8021c9 <_panic+0x53>
  8021cc:	66 90                	xchg   %ax,%ax
  8021ce:	66 90                	xchg   %ax,%ax

008021d0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021d0:	55                   	push   %ebp
  8021d1:	89 e5                	mov    %esp,%ebp
  8021d3:	56                   	push   %esi
  8021d4:	53                   	push   %ebx
  8021d5:	83 ec 10             	sub    $0x10,%esp
  8021d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8021db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021de:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  8021e1:	85 c0                	test   %eax,%eax
  8021e3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8021e8:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  8021eb:	89 04 24             	mov    %eax,(%esp)
  8021ee:	e8 b6 eb ff ff       	call   800da9 <sys_ipc_recv>

	if(ret < 0) {
  8021f3:	85 c0                	test   %eax,%eax
  8021f5:	79 16                	jns    80220d <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  8021f7:	85 f6                	test   %esi,%esi
  8021f9:	74 06                	je     802201 <ipc_recv+0x31>
  8021fb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  802201:	85 db                	test   %ebx,%ebx
  802203:	74 3e                	je     802243 <ipc_recv+0x73>
  802205:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80220b:	eb 36                	jmp    802243 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  80220d:	e8 43 e9 ff ff       	call   800b55 <sys_getenvid>
  802212:	25 ff 03 00 00       	and    $0x3ff,%eax
  802217:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80221a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80221f:	a3 08 40 80 00       	mov    %eax,0x804008

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802224:	85 f6                	test   %esi,%esi
  802226:	74 05                	je     80222d <ipc_recv+0x5d>
  802228:	8b 40 74             	mov    0x74(%eax),%eax
  80222b:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80222d:	85 db                	test   %ebx,%ebx
  80222f:	74 0a                	je     80223b <ipc_recv+0x6b>
  802231:	a1 08 40 80 00       	mov    0x804008,%eax
  802236:	8b 40 78             	mov    0x78(%eax),%eax
  802239:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  80223b:	a1 08 40 80 00       	mov    0x804008,%eax
  802240:	8b 40 70             	mov    0x70(%eax),%eax
}
  802243:	83 c4 10             	add    $0x10,%esp
  802246:	5b                   	pop    %ebx
  802247:	5e                   	pop    %esi
  802248:	5d                   	pop    %ebp
  802249:	c3                   	ret    

0080224a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80224a:	55                   	push   %ebp
  80224b:	89 e5                	mov    %esp,%ebp
  80224d:	57                   	push   %edi
  80224e:	56                   	push   %esi
  80224f:	53                   	push   %ebx
  802250:	83 ec 1c             	sub    $0x1c,%esp
  802253:	8b 7d 08             	mov    0x8(%ebp),%edi
  802256:	8b 75 0c             	mov    0xc(%ebp),%esi
  802259:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  80225c:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  80225e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802263:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  802266:	8b 45 14             	mov    0x14(%ebp),%eax
  802269:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80226d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802271:	89 74 24 04          	mov    %esi,0x4(%esp)
  802275:	89 3c 24             	mov    %edi,(%esp)
  802278:	e8 09 eb ff ff       	call   800d86 <sys_ipc_try_send>

		if(ret >= 0) break;
  80227d:	85 c0                	test   %eax,%eax
  80227f:	79 2c                	jns    8022ad <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  802281:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802284:	74 20                	je     8022a6 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  802286:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80228a:	c7 44 24 08 78 2a 80 	movl   $0x802a78,0x8(%esp)
  802291:	00 
  802292:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  802299:	00 
  80229a:	c7 04 24 a8 2a 80 00 	movl   $0x802aa8,(%esp)
  8022a1:	e8 d0 fe ff ff       	call   802176 <_panic>
		}
		sys_yield();
  8022a6:	e8 c9 e8 ff ff       	call   800b74 <sys_yield>
	}
  8022ab:	eb b9                	jmp    802266 <ipc_send+0x1c>
}
  8022ad:	83 c4 1c             	add    $0x1c,%esp
  8022b0:	5b                   	pop    %ebx
  8022b1:	5e                   	pop    %esi
  8022b2:	5f                   	pop    %edi
  8022b3:	5d                   	pop    %ebp
  8022b4:	c3                   	ret    

008022b5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022b5:	55                   	push   %ebp
  8022b6:	89 e5                	mov    %esp,%ebp
  8022b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022bb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022c0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8022c3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022c9:	8b 52 50             	mov    0x50(%edx),%edx
  8022cc:	39 ca                	cmp    %ecx,%edx
  8022ce:	75 0d                	jne    8022dd <ipc_find_env+0x28>
			return envs[i].env_id;
  8022d0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022d3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8022d8:	8b 40 40             	mov    0x40(%eax),%eax
  8022db:	eb 0e                	jmp    8022eb <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022dd:	83 c0 01             	add    $0x1,%eax
  8022e0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022e5:	75 d9                	jne    8022c0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022e7:	66 b8 00 00          	mov    $0x0,%ax
}
  8022eb:	5d                   	pop    %ebp
  8022ec:	c3                   	ret    

008022ed <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022ed:	55                   	push   %ebp
  8022ee:	89 e5                	mov    %esp,%ebp
  8022f0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022f3:	89 d0                	mov    %edx,%eax
  8022f5:	c1 e8 16             	shr    $0x16,%eax
  8022f8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8022ff:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802304:	f6 c1 01             	test   $0x1,%cl
  802307:	74 1d                	je     802326 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802309:	c1 ea 0c             	shr    $0xc,%edx
  80230c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802313:	f6 c2 01             	test   $0x1,%dl
  802316:	74 0e                	je     802326 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802318:	c1 ea 0c             	shr    $0xc,%edx
  80231b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802322:	ef 
  802323:	0f b7 c0             	movzwl %ax,%eax
}
  802326:	5d                   	pop    %ebp
  802327:	c3                   	ret    
  802328:	66 90                	xchg   %ax,%ax
  80232a:	66 90                	xchg   %ax,%ax
  80232c:	66 90                	xchg   %ax,%ax
  80232e:	66 90                	xchg   %ax,%ax

00802330 <__udivdi3>:
  802330:	55                   	push   %ebp
  802331:	57                   	push   %edi
  802332:	56                   	push   %esi
  802333:	83 ec 0c             	sub    $0xc,%esp
  802336:	8b 44 24 28          	mov    0x28(%esp),%eax
  80233a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80233e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802342:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802346:	85 c0                	test   %eax,%eax
  802348:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80234c:	89 ea                	mov    %ebp,%edx
  80234e:	89 0c 24             	mov    %ecx,(%esp)
  802351:	75 2d                	jne    802380 <__udivdi3+0x50>
  802353:	39 e9                	cmp    %ebp,%ecx
  802355:	77 61                	ja     8023b8 <__udivdi3+0x88>
  802357:	85 c9                	test   %ecx,%ecx
  802359:	89 ce                	mov    %ecx,%esi
  80235b:	75 0b                	jne    802368 <__udivdi3+0x38>
  80235d:	b8 01 00 00 00       	mov    $0x1,%eax
  802362:	31 d2                	xor    %edx,%edx
  802364:	f7 f1                	div    %ecx
  802366:	89 c6                	mov    %eax,%esi
  802368:	31 d2                	xor    %edx,%edx
  80236a:	89 e8                	mov    %ebp,%eax
  80236c:	f7 f6                	div    %esi
  80236e:	89 c5                	mov    %eax,%ebp
  802370:	89 f8                	mov    %edi,%eax
  802372:	f7 f6                	div    %esi
  802374:	89 ea                	mov    %ebp,%edx
  802376:	83 c4 0c             	add    $0xc,%esp
  802379:	5e                   	pop    %esi
  80237a:	5f                   	pop    %edi
  80237b:	5d                   	pop    %ebp
  80237c:	c3                   	ret    
  80237d:	8d 76 00             	lea    0x0(%esi),%esi
  802380:	39 e8                	cmp    %ebp,%eax
  802382:	77 24                	ja     8023a8 <__udivdi3+0x78>
  802384:	0f bd e8             	bsr    %eax,%ebp
  802387:	83 f5 1f             	xor    $0x1f,%ebp
  80238a:	75 3c                	jne    8023c8 <__udivdi3+0x98>
  80238c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802390:	39 34 24             	cmp    %esi,(%esp)
  802393:	0f 86 9f 00 00 00    	jbe    802438 <__udivdi3+0x108>
  802399:	39 d0                	cmp    %edx,%eax
  80239b:	0f 82 97 00 00 00    	jb     802438 <__udivdi3+0x108>
  8023a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023a8:	31 d2                	xor    %edx,%edx
  8023aa:	31 c0                	xor    %eax,%eax
  8023ac:	83 c4 0c             	add    $0xc,%esp
  8023af:	5e                   	pop    %esi
  8023b0:	5f                   	pop    %edi
  8023b1:	5d                   	pop    %ebp
  8023b2:	c3                   	ret    
  8023b3:	90                   	nop
  8023b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023b8:	89 f8                	mov    %edi,%eax
  8023ba:	f7 f1                	div    %ecx
  8023bc:	31 d2                	xor    %edx,%edx
  8023be:	83 c4 0c             	add    $0xc,%esp
  8023c1:	5e                   	pop    %esi
  8023c2:	5f                   	pop    %edi
  8023c3:	5d                   	pop    %ebp
  8023c4:	c3                   	ret    
  8023c5:	8d 76 00             	lea    0x0(%esi),%esi
  8023c8:	89 e9                	mov    %ebp,%ecx
  8023ca:	8b 3c 24             	mov    (%esp),%edi
  8023cd:	d3 e0                	shl    %cl,%eax
  8023cf:	89 c6                	mov    %eax,%esi
  8023d1:	b8 20 00 00 00       	mov    $0x20,%eax
  8023d6:	29 e8                	sub    %ebp,%eax
  8023d8:	89 c1                	mov    %eax,%ecx
  8023da:	d3 ef                	shr    %cl,%edi
  8023dc:	89 e9                	mov    %ebp,%ecx
  8023de:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8023e2:	8b 3c 24             	mov    (%esp),%edi
  8023e5:	09 74 24 08          	or     %esi,0x8(%esp)
  8023e9:	89 d6                	mov    %edx,%esi
  8023eb:	d3 e7                	shl    %cl,%edi
  8023ed:	89 c1                	mov    %eax,%ecx
  8023ef:	89 3c 24             	mov    %edi,(%esp)
  8023f2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8023f6:	d3 ee                	shr    %cl,%esi
  8023f8:	89 e9                	mov    %ebp,%ecx
  8023fa:	d3 e2                	shl    %cl,%edx
  8023fc:	89 c1                	mov    %eax,%ecx
  8023fe:	d3 ef                	shr    %cl,%edi
  802400:	09 d7                	or     %edx,%edi
  802402:	89 f2                	mov    %esi,%edx
  802404:	89 f8                	mov    %edi,%eax
  802406:	f7 74 24 08          	divl   0x8(%esp)
  80240a:	89 d6                	mov    %edx,%esi
  80240c:	89 c7                	mov    %eax,%edi
  80240e:	f7 24 24             	mull   (%esp)
  802411:	39 d6                	cmp    %edx,%esi
  802413:	89 14 24             	mov    %edx,(%esp)
  802416:	72 30                	jb     802448 <__udivdi3+0x118>
  802418:	8b 54 24 04          	mov    0x4(%esp),%edx
  80241c:	89 e9                	mov    %ebp,%ecx
  80241e:	d3 e2                	shl    %cl,%edx
  802420:	39 c2                	cmp    %eax,%edx
  802422:	73 05                	jae    802429 <__udivdi3+0xf9>
  802424:	3b 34 24             	cmp    (%esp),%esi
  802427:	74 1f                	je     802448 <__udivdi3+0x118>
  802429:	89 f8                	mov    %edi,%eax
  80242b:	31 d2                	xor    %edx,%edx
  80242d:	e9 7a ff ff ff       	jmp    8023ac <__udivdi3+0x7c>
  802432:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802438:	31 d2                	xor    %edx,%edx
  80243a:	b8 01 00 00 00       	mov    $0x1,%eax
  80243f:	e9 68 ff ff ff       	jmp    8023ac <__udivdi3+0x7c>
  802444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802448:	8d 47 ff             	lea    -0x1(%edi),%eax
  80244b:	31 d2                	xor    %edx,%edx
  80244d:	83 c4 0c             	add    $0xc,%esp
  802450:	5e                   	pop    %esi
  802451:	5f                   	pop    %edi
  802452:	5d                   	pop    %ebp
  802453:	c3                   	ret    
  802454:	66 90                	xchg   %ax,%ax
  802456:	66 90                	xchg   %ax,%ax
  802458:	66 90                	xchg   %ax,%ax
  80245a:	66 90                	xchg   %ax,%ax
  80245c:	66 90                	xchg   %ax,%ax
  80245e:	66 90                	xchg   %ax,%ax

00802460 <__umoddi3>:
  802460:	55                   	push   %ebp
  802461:	57                   	push   %edi
  802462:	56                   	push   %esi
  802463:	83 ec 14             	sub    $0x14,%esp
  802466:	8b 44 24 28          	mov    0x28(%esp),%eax
  80246a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80246e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802472:	89 c7                	mov    %eax,%edi
  802474:	89 44 24 04          	mov    %eax,0x4(%esp)
  802478:	8b 44 24 30          	mov    0x30(%esp),%eax
  80247c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802480:	89 34 24             	mov    %esi,(%esp)
  802483:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802487:	85 c0                	test   %eax,%eax
  802489:	89 c2                	mov    %eax,%edx
  80248b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80248f:	75 17                	jne    8024a8 <__umoddi3+0x48>
  802491:	39 fe                	cmp    %edi,%esi
  802493:	76 4b                	jbe    8024e0 <__umoddi3+0x80>
  802495:	89 c8                	mov    %ecx,%eax
  802497:	89 fa                	mov    %edi,%edx
  802499:	f7 f6                	div    %esi
  80249b:	89 d0                	mov    %edx,%eax
  80249d:	31 d2                	xor    %edx,%edx
  80249f:	83 c4 14             	add    $0x14,%esp
  8024a2:	5e                   	pop    %esi
  8024a3:	5f                   	pop    %edi
  8024a4:	5d                   	pop    %ebp
  8024a5:	c3                   	ret    
  8024a6:	66 90                	xchg   %ax,%ax
  8024a8:	39 f8                	cmp    %edi,%eax
  8024aa:	77 54                	ja     802500 <__umoddi3+0xa0>
  8024ac:	0f bd e8             	bsr    %eax,%ebp
  8024af:	83 f5 1f             	xor    $0x1f,%ebp
  8024b2:	75 5c                	jne    802510 <__umoddi3+0xb0>
  8024b4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8024b8:	39 3c 24             	cmp    %edi,(%esp)
  8024bb:	0f 87 e7 00 00 00    	ja     8025a8 <__umoddi3+0x148>
  8024c1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8024c5:	29 f1                	sub    %esi,%ecx
  8024c7:	19 c7                	sbb    %eax,%edi
  8024c9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024cd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024d1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024d5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8024d9:	83 c4 14             	add    $0x14,%esp
  8024dc:	5e                   	pop    %esi
  8024dd:	5f                   	pop    %edi
  8024de:	5d                   	pop    %ebp
  8024df:	c3                   	ret    
  8024e0:	85 f6                	test   %esi,%esi
  8024e2:	89 f5                	mov    %esi,%ebp
  8024e4:	75 0b                	jne    8024f1 <__umoddi3+0x91>
  8024e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024eb:	31 d2                	xor    %edx,%edx
  8024ed:	f7 f6                	div    %esi
  8024ef:	89 c5                	mov    %eax,%ebp
  8024f1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8024f5:	31 d2                	xor    %edx,%edx
  8024f7:	f7 f5                	div    %ebp
  8024f9:	89 c8                	mov    %ecx,%eax
  8024fb:	f7 f5                	div    %ebp
  8024fd:	eb 9c                	jmp    80249b <__umoddi3+0x3b>
  8024ff:	90                   	nop
  802500:	89 c8                	mov    %ecx,%eax
  802502:	89 fa                	mov    %edi,%edx
  802504:	83 c4 14             	add    $0x14,%esp
  802507:	5e                   	pop    %esi
  802508:	5f                   	pop    %edi
  802509:	5d                   	pop    %ebp
  80250a:	c3                   	ret    
  80250b:	90                   	nop
  80250c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802510:	8b 04 24             	mov    (%esp),%eax
  802513:	be 20 00 00 00       	mov    $0x20,%esi
  802518:	89 e9                	mov    %ebp,%ecx
  80251a:	29 ee                	sub    %ebp,%esi
  80251c:	d3 e2                	shl    %cl,%edx
  80251e:	89 f1                	mov    %esi,%ecx
  802520:	d3 e8                	shr    %cl,%eax
  802522:	89 e9                	mov    %ebp,%ecx
  802524:	89 44 24 04          	mov    %eax,0x4(%esp)
  802528:	8b 04 24             	mov    (%esp),%eax
  80252b:	09 54 24 04          	or     %edx,0x4(%esp)
  80252f:	89 fa                	mov    %edi,%edx
  802531:	d3 e0                	shl    %cl,%eax
  802533:	89 f1                	mov    %esi,%ecx
  802535:	89 44 24 08          	mov    %eax,0x8(%esp)
  802539:	8b 44 24 10          	mov    0x10(%esp),%eax
  80253d:	d3 ea                	shr    %cl,%edx
  80253f:	89 e9                	mov    %ebp,%ecx
  802541:	d3 e7                	shl    %cl,%edi
  802543:	89 f1                	mov    %esi,%ecx
  802545:	d3 e8                	shr    %cl,%eax
  802547:	89 e9                	mov    %ebp,%ecx
  802549:	09 f8                	or     %edi,%eax
  80254b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80254f:	f7 74 24 04          	divl   0x4(%esp)
  802553:	d3 e7                	shl    %cl,%edi
  802555:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802559:	89 d7                	mov    %edx,%edi
  80255b:	f7 64 24 08          	mull   0x8(%esp)
  80255f:	39 d7                	cmp    %edx,%edi
  802561:	89 c1                	mov    %eax,%ecx
  802563:	89 14 24             	mov    %edx,(%esp)
  802566:	72 2c                	jb     802594 <__umoddi3+0x134>
  802568:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80256c:	72 22                	jb     802590 <__umoddi3+0x130>
  80256e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802572:	29 c8                	sub    %ecx,%eax
  802574:	19 d7                	sbb    %edx,%edi
  802576:	89 e9                	mov    %ebp,%ecx
  802578:	89 fa                	mov    %edi,%edx
  80257a:	d3 e8                	shr    %cl,%eax
  80257c:	89 f1                	mov    %esi,%ecx
  80257e:	d3 e2                	shl    %cl,%edx
  802580:	89 e9                	mov    %ebp,%ecx
  802582:	d3 ef                	shr    %cl,%edi
  802584:	09 d0                	or     %edx,%eax
  802586:	89 fa                	mov    %edi,%edx
  802588:	83 c4 14             	add    $0x14,%esp
  80258b:	5e                   	pop    %esi
  80258c:	5f                   	pop    %edi
  80258d:	5d                   	pop    %ebp
  80258e:	c3                   	ret    
  80258f:	90                   	nop
  802590:	39 d7                	cmp    %edx,%edi
  802592:	75 da                	jne    80256e <__umoddi3+0x10e>
  802594:	8b 14 24             	mov    (%esp),%edx
  802597:	89 c1                	mov    %eax,%ecx
  802599:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80259d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8025a1:	eb cb                	jmp    80256e <__umoddi3+0x10e>
  8025a3:	90                   	nop
  8025a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025a8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8025ac:	0f 82 0f ff ff ff    	jb     8024c1 <__umoddi3+0x61>
  8025b2:	e9 1a ff ff ff       	jmp    8024d1 <__umoddi3+0x71>
