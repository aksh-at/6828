
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 8e 00 00 00       	call   8000bf <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	53                   	push   %ebx
  800044:	83 ec 14             	sub    $0x14,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  800047:	c7 04 24 c0 29 80 00 	movl   $0x8029c0,(%esp)
  80004e:	e8 70 01 00 00       	call   8001c3 <cprintf>
	if ((env = fork()) == 0) {
  800053:	e8 dc 0f 00 00       	call   801034 <fork>
  800058:	89 c3                	mov    %eax,%ebx
  80005a:	85 c0                	test   %eax,%eax
  80005c:	75 0e                	jne    80006c <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  80005e:	c7 04 24 38 2a 80 00 	movl   $0x802a38,(%esp)
  800065:	e8 59 01 00 00       	call   8001c3 <cprintf>
  80006a:	eb fe                	jmp    80006a <umain+0x2a>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  80006c:	c7 04 24 e8 29 80 00 	movl   $0x8029e8,(%esp)
  800073:	e8 4b 01 00 00       	call   8001c3 <cprintf>
	sys_yield();
  800078:	e8 67 0b 00 00       	call   800be4 <sys_yield>
	sys_yield();
  80007d:	e8 62 0b 00 00       	call   800be4 <sys_yield>
	sys_yield();
  800082:	e8 5d 0b 00 00       	call   800be4 <sys_yield>
	sys_yield();
  800087:	e8 58 0b 00 00       	call   800be4 <sys_yield>
	sys_yield();
  80008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800090:	e8 4f 0b 00 00       	call   800be4 <sys_yield>
	sys_yield();
  800095:	e8 4a 0b 00 00       	call   800be4 <sys_yield>
	sys_yield();
  80009a:	e8 45 0b 00 00       	call   800be4 <sys_yield>
	sys_yield();
  80009f:	90                   	nop
  8000a0:	e8 3f 0b 00 00       	call   800be4 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  8000a5:	c7 04 24 10 2a 80 00 	movl   $0x802a10,(%esp)
  8000ac:	e8 12 01 00 00       	call   8001c3 <cprintf>
	sys_env_destroy(env);
  8000b1:	89 1c 24             	mov    %ebx,(%esp)
  8000b4:	e8 ba 0a 00 00       	call   800b73 <sys_env_destroy>
}
  8000b9:	83 c4 14             	add    $0x14,%esp
  8000bc:	5b                   	pop    %ebx
  8000bd:	5d                   	pop    %ebp
  8000be:	c3                   	ret    

008000bf <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	56                   	push   %esi
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 10             	sub    $0x10,%esp
  8000c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ca:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  8000cd:	e8 f3 0a 00 00       	call   800bc5 <sys_getenvid>
  8000d2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000da:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000df:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e4:	85 db                	test   %ebx,%ebx
  8000e6:	7e 07                	jle    8000ef <libmain+0x30>
		binaryname = argv[0];
  8000e8:	8b 06                	mov    (%esi),%eax
  8000ea:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000f3:	89 1c 24             	mov    %ebx,(%esp)
  8000f6:	e8 45 ff ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  8000fb:	e8 07 00 00 00       	call   800107 <exit>
}
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	5b                   	pop    %ebx
  800104:	5e                   	pop    %esi
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80010d:	e8 08 13 00 00       	call   80141a <close_all>
	sys_env_destroy(0);
  800112:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800119:	e8 55 0a 00 00       	call   800b73 <sys_env_destroy>
}
  80011e:	c9                   	leave  
  80011f:	c3                   	ret    

00800120 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	53                   	push   %ebx
  800124:	83 ec 14             	sub    $0x14,%esp
  800127:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012a:	8b 13                	mov    (%ebx),%edx
  80012c:	8d 42 01             	lea    0x1(%edx),%eax
  80012f:	89 03                	mov    %eax,(%ebx)
  800131:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800134:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800138:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013d:	75 19                	jne    800158 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80013f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800146:	00 
  800147:	8d 43 08             	lea    0x8(%ebx),%eax
  80014a:	89 04 24             	mov    %eax,(%esp)
  80014d:	e8 e4 09 00 00       	call   800b36 <sys_cputs>
		b->idx = 0;
  800152:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800158:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015c:	83 c4 14             	add    $0x14,%esp
  80015f:	5b                   	pop    %ebx
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80016b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800172:	00 00 00 
	b.cnt = 0;
  800175:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800182:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800186:	8b 45 08             	mov    0x8(%ebp),%eax
  800189:	89 44 24 08          	mov    %eax,0x8(%esp)
  80018d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800193:	89 44 24 04          	mov    %eax,0x4(%esp)
  800197:	c7 04 24 20 01 80 00 	movl   $0x800120,(%esp)
  80019e:	e8 ab 01 00 00       	call   80034e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ad:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b3:	89 04 24             	mov    %eax,(%esp)
  8001b6:	e8 7b 09 00 00       	call   800b36 <sys_cputs>

	return b.cnt;
}
  8001bb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c1:	c9                   	leave  
  8001c2:	c3                   	ret    

008001c3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c3:	55                   	push   %ebp
  8001c4:	89 e5                	mov    %esp,%ebp
  8001c6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001c9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d3:	89 04 24             	mov    %eax,(%esp)
  8001d6:	e8 87 ff ff ff       	call   800162 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001db:	c9                   	leave  
  8001dc:	c3                   	ret    
  8001dd:	66 90                	xchg   %ax,%ax
  8001df:	90                   	nop

008001e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 3c             	sub    $0x3c,%esp
  8001e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001ec:	89 d7                	mov    %edx,%edi
  8001ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f7:	89 c3                	mov    %eax,%ebx
  8001f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ff:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800202:	b9 00 00 00 00       	mov    $0x0,%ecx
  800207:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80020a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80020d:	39 d9                	cmp    %ebx,%ecx
  80020f:	72 05                	jb     800216 <printnum+0x36>
  800211:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800214:	77 69                	ja     80027f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800216:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800219:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80021d:	83 ee 01             	sub    $0x1,%esi
  800220:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800224:	89 44 24 08          	mov    %eax,0x8(%esp)
  800228:	8b 44 24 08          	mov    0x8(%esp),%eax
  80022c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800230:	89 c3                	mov    %eax,%ebx
  800232:	89 d6                	mov    %edx,%esi
  800234:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800237:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80023a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80023e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800242:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800245:	89 04 24             	mov    %eax,(%esp)
  800248:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80024b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024f:	e8 cc 24 00 00       	call   802720 <__udivdi3>
  800254:	89 d9                	mov    %ebx,%ecx
  800256:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80025a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80025e:	89 04 24             	mov    %eax,(%esp)
  800261:	89 54 24 04          	mov    %edx,0x4(%esp)
  800265:	89 fa                	mov    %edi,%edx
  800267:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80026a:	e8 71 ff ff ff       	call   8001e0 <printnum>
  80026f:	eb 1b                	jmp    80028c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800271:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800275:	8b 45 18             	mov    0x18(%ebp),%eax
  800278:	89 04 24             	mov    %eax,(%esp)
  80027b:	ff d3                	call   *%ebx
  80027d:	eb 03                	jmp    800282 <printnum+0xa2>
  80027f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800282:	83 ee 01             	sub    $0x1,%esi
  800285:	85 f6                	test   %esi,%esi
  800287:	7f e8                	jg     800271 <printnum+0x91>
  800289:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800290:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800294:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800297:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80029a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80029e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002a5:	89 04 24             	mov    %eax,(%esp)
  8002a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002af:	e8 9c 25 00 00       	call   802850 <__umoddi3>
  8002b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b8:	0f be 80 60 2a 80 00 	movsbl 0x802a60(%eax),%eax
  8002bf:	89 04 24             	mov    %eax,(%esp)
  8002c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002c5:	ff d0                	call   *%eax
}
  8002c7:	83 c4 3c             	add    $0x3c,%esp
  8002ca:	5b                   	pop    %ebx
  8002cb:	5e                   	pop    %esi
  8002cc:	5f                   	pop    %edi
  8002cd:	5d                   	pop    %ebp
  8002ce:	c3                   	ret    

008002cf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d2:	83 fa 01             	cmp    $0x1,%edx
  8002d5:	7e 0e                	jle    8002e5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002d7:	8b 10                	mov    (%eax),%edx
  8002d9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002dc:	89 08                	mov    %ecx,(%eax)
  8002de:	8b 02                	mov    (%edx),%eax
  8002e0:	8b 52 04             	mov    0x4(%edx),%edx
  8002e3:	eb 22                	jmp    800307 <getuint+0x38>
	else if (lflag)
  8002e5:	85 d2                	test   %edx,%edx
  8002e7:	74 10                	je     8002f9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e9:	8b 10                	mov    (%eax),%edx
  8002eb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ee:	89 08                	mov    %ecx,(%eax)
  8002f0:	8b 02                	mov    (%edx),%eax
  8002f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f7:	eb 0e                	jmp    800307 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f9:	8b 10                	mov    (%eax),%edx
  8002fb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fe:	89 08                	mov    %ecx,(%eax)
  800300:	8b 02                	mov    (%edx),%eax
  800302:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800307:	5d                   	pop    %ebp
  800308:	c3                   	ret    

00800309 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
  80030c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80030f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800313:	8b 10                	mov    (%eax),%edx
  800315:	3b 50 04             	cmp    0x4(%eax),%edx
  800318:	73 0a                	jae    800324 <sprintputch+0x1b>
		*b->buf++ = ch;
  80031a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80031d:	89 08                	mov    %ecx,(%eax)
  80031f:	8b 45 08             	mov    0x8(%ebp),%eax
  800322:	88 02                	mov    %al,(%edx)
}
  800324:	5d                   	pop    %ebp
  800325:	c3                   	ret    

00800326 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
  800329:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80032c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80032f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800333:	8b 45 10             	mov    0x10(%ebp),%eax
  800336:	89 44 24 08          	mov    %eax,0x8(%esp)
  80033a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80033d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800341:	8b 45 08             	mov    0x8(%ebp),%eax
  800344:	89 04 24             	mov    %eax,(%esp)
  800347:	e8 02 00 00 00       	call   80034e <vprintfmt>
	va_end(ap);
}
  80034c:	c9                   	leave  
  80034d:	c3                   	ret    

0080034e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  800351:	57                   	push   %edi
  800352:	56                   	push   %esi
  800353:	53                   	push   %ebx
  800354:	83 ec 3c             	sub    $0x3c,%esp
  800357:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80035a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80035d:	eb 14                	jmp    800373 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80035f:	85 c0                	test   %eax,%eax
  800361:	0f 84 b3 03 00 00    	je     80071a <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800367:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80036b:	89 04 24             	mov    %eax,(%esp)
  80036e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800371:	89 f3                	mov    %esi,%ebx
  800373:	8d 73 01             	lea    0x1(%ebx),%esi
  800376:	0f b6 03             	movzbl (%ebx),%eax
  800379:	83 f8 25             	cmp    $0x25,%eax
  80037c:	75 e1                	jne    80035f <vprintfmt+0x11>
  80037e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800382:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800389:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800390:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800397:	ba 00 00 00 00       	mov    $0x0,%edx
  80039c:	eb 1d                	jmp    8003bb <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003a4:	eb 15                	jmp    8003bb <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003ac:	eb 0d                	jmp    8003bb <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003ae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003b4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bb:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003be:	0f b6 0e             	movzbl (%esi),%ecx
  8003c1:	0f b6 c1             	movzbl %cl,%eax
  8003c4:	83 e9 23             	sub    $0x23,%ecx
  8003c7:	80 f9 55             	cmp    $0x55,%cl
  8003ca:	0f 87 2a 03 00 00    	ja     8006fa <vprintfmt+0x3ac>
  8003d0:	0f b6 c9             	movzbl %cl,%ecx
  8003d3:	ff 24 8d a0 2b 80 00 	jmp    *0x802ba0(,%ecx,4)
  8003da:	89 de                	mov    %ebx,%esi
  8003dc:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003e1:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003e4:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8003e8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003eb:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003ee:	83 fb 09             	cmp    $0x9,%ebx
  8003f1:	77 36                	ja     800429 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f3:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003f6:	eb e9                	jmp    8003e1 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fb:	8d 48 04             	lea    0x4(%eax),%ecx
  8003fe:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800401:	8b 00                	mov    (%eax),%eax
  800403:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800406:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800408:	eb 22                	jmp    80042c <vprintfmt+0xde>
  80040a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80040d:	85 c9                	test   %ecx,%ecx
  80040f:	b8 00 00 00 00       	mov    $0x0,%eax
  800414:	0f 49 c1             	cmovns %ecx,%eax
  800417:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	89 de                	mov    %ebx,%esi
  80041c:	eb 9d                	jmp    8003bb <vprintfmt+0x6d>
  80041e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800420:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800427:	eb 92                	jmp    8003bb <vprintfmt+0x6d>
  800429:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80042c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800430:	79 89                	jns    8003bb <vprintfmt+0x6d>
  800432:	e9 77 ff ff ff       	jmp    8003ae <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800437:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80043c:	e9 7a ff ff ff       	jmp    8003bb <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800441:	8b 45 14             	mov    0x14(%ebp),%eax
  800444:	8d 50 04             	lea    0x4(%eax),%edx
  800447:	89 55 14             	mov    %edx,0x14(%ebp)
  80044a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80044e:	8b 00                	mov    (%eax),%eax
  800450:	89 04 24             	mov    %eax,(%esp)
  800453:	ff 55 08             	call   *0x8(%ebp)
			break;
  800456:	e9 18 ff ff ff       	jmp    800373 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045b:	8b 45 14             	mov    0x14(%ebp),%eax
  80045e:	8d 50 04             	lea    0x4(%eax),%edx
  800461:	89 55 14             	mov    %edx,0x14(%ebp)
  800464:	8b 00                	mov    (%eax),%eax
  800466:	99                   	cltd   
  800467:	31 d0                	xor    %edx,%eax
  800469:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80046b:	83 f8 0f             	cmp    $0xf,%eax
  80046e:	7f 0b                	jg     80047b <vprintfmt+0x12d>
  800470:	8b 14 85 00 2d 80 00 	mov    0x802d00(,%eax,4),%edx
  800477:	85 d2                	test   %edx,%edx
  800479:	75 20                	jne    80049b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80047b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80047f:	c7 44 24 08 78 2a 80 	movl   $0x802a78,0x8(%esp)
  800486:	00 
  800487:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80048b:	8b 45 08             	mov    0x8(%ebp),%eax
  80048e:	89 04 24             	mov    %eax,(%esp)
  800491:	e8 90 fe ff ff       	call   800326 <printfmt>
  800496:	e9 d8 fe ff ff       	jmp    800373 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80049b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80049f:	c7 44 24 08 ad 2e 80 	movl   $0x802ead,0x8(%esp)
  8004a6:	00 
  8004a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ae:	89 04 24             	mov    %eax,(%esp)
  8004b1:	e8 70 fe ff ff       	call   800326 <printfmt>
  8004b6:	e9 b8 fe ff ff       	jmp    800373 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004be:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c7:	8d 50 04             	lea    0x4(%eax),%edx
  8004ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cd:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004cf:	85 f6                	test   %esi,%esi
  8004d1:	b8 71 2a 80 00       	mov    $0x802a71,%eax
  8004d6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8004d9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004dd:	0f 84 97 00 00 00    	je     80057a <vprintfmt+0x22c>
  8004e3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8004e7:	0f 8e 9b 00 00 00    	jle    800588 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ed:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004f1:	89 34 24             	mov    %esi,(%esp)
  8004f4:	e8 cf 02 00 00       	call   8007c8 <strnlen>
  8004f9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004fc:	29 c2                	sub    %eax,%edx
  8004fe:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800501:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800505:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800508:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80050b:	8b 75 08             	mov    0x8(%ebp),%esi
  80050e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800511:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800513:	eb 0f                	jmp    800524 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800515:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800519:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80051c:	89 04 24             	mov    %eax,(%esp)
  80051f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800521:	83 eb 01             	sub    $0x1,%ebx
  800524:	85 db                	test   %ebx,%ebx
  800526:	7f ed                	jg     800515 <vprintfmt+0x1c7>
  800528:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80052b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80052e:	85 d2                	test   %edx,%edx
  800530:	b8 00 00 00 00       	mov    $0x0,%eax
  800535:	0f 49 c2             	cmovns %edx,%eax
  800538:	29 c2                	sub    %eax,%edx
  80053a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80053d:	89 d7                	mov    %edx,%edi
  80053f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800542:	eb 50                	jmp    800594 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800544:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800548:	74 1e                	je     800568 <vprintfmt+0x21a>
  80054a:	0f be d2             	movsbl %dl,%edx
  80054d:	83 ea 20             	sub    $0x20,%edx
  800550:	83 fa 5e             	cmp    $0x5e,%edx
  800553:	76 13                	jbe    800568 <vprintfmt+0x21a>
					putch('?', putdat);
  800555:	8b 45 0c             	mov    0xc(%ebp),%eax
  800558:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800563:	ff 55 08             	call   *0x8(%ebp)
  800566:	eb 0d                	jmp    800575 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800568:	8b 55 0c             	mov    0xc(%ebp),%edx
  80056b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80056f:	89 04 24             	mov    %eax,(%esp)
  800572:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800575:	83 ef 01             	sub    $0x1,%edi
  800578:	eb 1a                	jmp    800594 <vprintfmt+0x246>
  80057a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80057d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800580:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800583:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800586:	eb 0c                	jmp    800594 <vprintfmt+0x246>
  800588:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80058b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80058e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800591:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800594:	83 c6 01             	add    $0x1,%esi
  800597:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80059b:	0f be c2             	movsbl %dl,%eax
  80059e:	85 c0                	test   %eax,%eax
  8005a0:	74 27                	je     8005c9 <vprintfmt+0x27b>
  8005a2:	85 db                	test   %ebx,%ebx
  8005a4:	78 9e                	js     800544 <vprintfmt+0x1f6>
  8005a6:	83 eb 01             	sub    $0x1,%ebx
  8005a9:	79 99                	jns    800544 <vprintfmt+0x1f6>
  8005ab:	89 f8                	mov    %edi,%eax
  8005ad:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b3:	89 c3                	mov    %eax,%ebx
  8005b5:	eb 1a                	jmp    8005d1 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005bb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005c2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c4:	83 eb 01             	sub    $0x1,%ebx
  8005c7:	eb 08                	jmp    8005d1 <vprintfmt+0x283>
  8005c9:	89 fb                	mov    %edi,%ebx
  8005cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ce:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005d1:	85 db                	test   %ebx,%ebx
  8005d3:	7f e2                	jg     8005b7 <vprintfmt+0x269>
  8005d5:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005db:	e9 93 fd ff ff       	jmp    800373 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e0:	83 fa 01             	cmp    $0x1,%edx
  8005e3:	7e 16                	jle    8005fb <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8d 50 08             	lea    0x8(%eax),%edx
  8005eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ee:	8b 50 04             	mov    0x4(%eax),%edx
  8005f1:	8b 00                	mov    (%eax),%eax
  8005f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005f6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005f9:	eb 32                	jmp    80062d <vprintfmt+0x2df>
	else if (lflag)
  8005fb:	85 d2                	test   %edx,%edx
  8005fd:	74 18                	je     800617 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8d 50 04             	lea    0x4(%eax),%edx
  800605:	89 55 14             	mov    %edx,0x14(%ebp)
  800608:	8b 30                	mov    (%eax),%esi
  80060a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80060d:	89 f0                	mov    %esi,%eax
  80060f:	c1 f8 1f             	sar    $0x1f,%eax
  800612:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800615:	eb 16                	jmp    80062d <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8d 50 04             	lea    0x4(%eax),%edx
  80061d:	89 55 14             	mov    %edx,0x14(%ebp)
  800620:	8b 30                	mov    (%eax),%esi
  800622:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800625:	89 f0                	mov    %esi,%eax
  800627:	c1 f8 1f             	sar    $0x1f,%eax
  80062a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80062d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800630:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800633:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800638:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80063c:	0f 89 80 00 00 00    	jns    8006c2 <vprintfmt+0x374>
				putch('-', putdat);
  800642:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800646:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80064d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800650:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800653:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800656:	f7 d8                	neg    %eax
  800658:	83 d2 00             	adc    $0x0,%edx
  80065b:	f7 da                	neg    %edx
			}
			base = 10;
  80065d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800662:	eb 5e                	jmp    8006c2 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800664:	8d 45 14             	lea    0x14(%ebp),%eax
  800667:	e8 63 fc ff ff       	call   8002cf <getuint>
			base = 10;
  80066c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800671:	eb 4f                	jmp    8006c2 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800673:	8d 45 14             	lea    0x14(%ebp),%eax
  800676:	e8 54 fc ff ff       	call   8002cf <getuint>
			base = 8;
  80067b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800680:	eb 40                	jmp    8006c2 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800682:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800686:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80068d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800690:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800694:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80069b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80069e:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a1:	8d 50 04             	lea    0x4(%eax),%edx
  8006a4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a7:	8b 00                	mov    (%eax),%eax
  8006a9:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ae:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006b3:	eb 0d                	jmp    8006c2 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b8:	e8 12 fc ff ff       	call   8002cf <getuint>
			base = 16;
  8006bd:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c2:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8006c6:	89 74 24 10          	mov    %esi,0x10(%esp)
  8006ca:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006cd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006d1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006d5:	89 04 24             	mov    %eax,(%esp)
  8006d8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006dc:	89 fa                	mov    %edi,%edx
  8006de:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e1:	e8 fa fa ff ff       	call   8001e0 <printnum>
			break;
  8006e6:	e9 88 fc ff ff       	jmp    800373 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006eb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ef:	89 04 24             	mov    %eax,(%esp)
  8006f2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006f5:	e9 79 fc ff ff       	jmp    800373 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006fe:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800705:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800708:	89 f3                	mov    %esi,%ebx
  80070a:	eb 03                	jmp    80070f <vprintfmt+0x3c1>
  80070c:	83 eb 01             	sub    $0x1,%ebx
  80070f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800713:	75 f7                	jne    80070c <vprintfmt+0x3be>
  800715:	e9 59 fc ff ff       	jmp    800373 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  80071a:	83 c4 3c             	add    $0x3c,%esp
  80071d:	5b                   	pop    %ebx
  80071e:	5e                   	pop    %esi
  80071f:	5f                   	pop    %edi
  800720:	5d                   	pop    %ebp
  800721:	c3                   	ret    

00800722 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	83 ec 28             	sub    $0x28,%esp
  800728:	8b 45 08             	mov    0x8(%ebp),%eax
  80072b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80072e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800731:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800735:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800738:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80073f:	85 c0                	test   %eax,%eax
  800741:	74 30                	je     800773 <vsnprintf+0x51>
  800743:	85 d2                	test   %edx,%edx
  800745:	7e 2c                	jle    800773 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800747:	8b 45 14             	mov    0x14(%ebp),%eax
  80074a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80074e:	8b 45 10             	mov    0x10(%ebp),%eax
  800751:	89 44 24 08          	mov    %eax,0x8(%esp)
  800755:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800758:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075c:	c7 04 24 09 03 80 00 	movl   $0x800309,(%esp)
  800763:	e8 e6 fb ff ff       	call   80034e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800768:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80076b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80076e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800771:	eb 05                	jmp    800778 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800773:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800778:	c9                   	leave  
  800779:	c3                   	ret    

0080077a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800780:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800783:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800787:	8b 45 10             	mov    0x10(%ebp),%eax
  80078a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80078e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800791:	89 44 24 04          	mov    %eax,0x4(%esp)
  800795:	8b 45 08             	mov    0x8(%ebp),%eax
  800798:	89 04 24             	mov    %eax,(%esp)
  80079b:	e8 82 ff ff ff       	call   800722 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a0:	c9                   	leave  
  8007a1:	c3                   	ret    
  8007a2:	66 90                	xchg   %ax,%ax
  8007a4:	66 90                	xchg   %ax,%ax
  8007a6:	66 90                	xchg   %ax,%ax
  8007a8:	66 90                	xchg   %ax,%ax
  8007aa:	66 90                	xchg   %ax,%ax
  8007ac:	66 90                	xchg   %ax,%ax
  8007ae:	66 90                	xchg   %ax,%ax

008007b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bb:	eb 03                	jmp    8007c0 <strlen+0x10>
		n++;
  8007bd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c4:	75 f7                	jne    8007bd <strlen+0xd>
		n++;
	return n;
}
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ce:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d6:	eb 03                	jmp    8007db <strnlen+0x13>
		n++;
  8007d8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007db:	39 d0                	cmp    %edx,%eax
  8007dd:	74 06                	je     8007e5 <strnlen+0x1d>
  8007df:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007e3:	75 f3                	jne    8007d8 <strnlen+0x10>
		n++;
	return n;
}
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	53                   	push   %ebx
  8007eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f1:	89 c2                	mov    %eax,%edx
  8007f3:	83 c2 01             	add    $0x1,%edx
  8007f6:	83 c1 01             	add    $0x1,%ecx
  8007f9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007fd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800800:	84 db                	test   %bl,%bl
  800802:	75 ef                	jne    8007f3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800804:	5b                   	pop    %ebx
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	53                   	push   %ebx
  80080b:	83 ec 08             	sub    $0x8,%esp
  80080e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800811:	89 1c 24             	mov    %ebx,(%esp)
  800814:	e8 97 ff ff ff       	call   8007b0 <strlen>
	strcpy(dst + len, src);
  800819:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800820:	01 d8                	add    %ebx,%eax
  800822:	89 04 24             	mov    %eax,(%esp)
  800825:	e8 bd ff ff ff       	call   8007e7 <strcpy>
	return dst;
}
  80082a:	89 d8                	mov    %ebx,%eax
  80082c:	83 c4 08             	add    $0x8,%esp
  80082f:	5b                   	pop    %ebx
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	56                   	push   %esi
  800836:	53                   	push   %ebx
  800837:	8b 75 08             	mov    0x8(%ebp),%esi
  80083a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083d:	89 f3                	mov    %esi,%ebx
  80083f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800842:	89 f2                	mov    %esi,%edx
  800844:	eb 0f                	jmp    800855 <strncpy+0x23>
		*dst++ = *src;
  800846:	83 c2 01             	add    $0x1,%edx
  800849:	0f b6 01             	movzbl (%ecx),%eax
  80084c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80084f:	80 39 01             	cmpb   $0x1,(%ecx)
  800852:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800855:	39 da                	cmp    %ebx,%edx
  800857:	75 ed                	jne    800846 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800859:	89 f0                	mov    %esi,%eax
  80085b:	5b                   	pop    %ebx
  80085c:	5e                   	pop    %esi
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	56                   	push   %esi
  800863:	53                   	push   %ebx
  800864:	8b 75 08             	mov    0x8(%ebp),%esi
  800867:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80086d:	89 f0                	mov    %esi,%eax
  80086f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800873:	85 c9                	test   %ecx,%ecx
  800875:	75 0b                	jne    800882 <strlcpy+0x23>
  800877:	eb 1d                	jmp    800896 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800879:	83 c0 01             	add    $0x1,%eax
  80087c:	83 c2 01             	add    $0x1,%edx
  80087f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800882:	39 d8                	cmp    %ebx,%eax
  800884:	74 0b                	je     800891 <strlcpy+0x32>
  800886:	0f b6 0a             	movzbl (%edx),%ecx
  800889:	84 c9                	test   %cl,%cl
  80088b:	75 ec                	jne    800879 <strlcpy+0x1a>
  80088d:	89 c2                	mov    %eax,%edx
  80088f:	eb 02                	jmp    800893 <strlcpy+0x34>
  800891:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800893:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800896:	29 f0                	sub    %esi,%eax
}
  800898:	5b                   	pop    %ebx
  800899:	5e                   	pop    %esi
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a5:	eb 06                	jmp    8008ad <strcmp+0x11>
		p++, q++;
  8008a7:	83 c1 01             	add    $0x1,%ecx
  8008aa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ad:	0f b6 01             	movzbl (%ecx),%eax
  8008b0:	84 c0                	test   %al,%al
  8008b2:	74 04                	je     8008b8 <strcmp+0x1c>
  8008b4:	3a 02                	cmp    (%edx),%al
  8008b6:	74 ef                	je     8008a7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b8:	0f b6 c0             	movzbl %al,%eax
  8008bb:	0f b6 12             	movzbl (%edx),%edx
  8008be:	29 d0                	sub    %edx,%eax
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	53                   	push   %ebx
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cc:	89 c3                	mov    %eax,%ebx
  8008ce:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d1:	eb 06                	jmp    8008d9 <strncmp+0x17>
		n--, p++, q++;
  8008d3:	83 c0 01             	add    $0x1,%eax
  8008d6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d9:	39 d8                	cmp    %ebx,%eax
  8008db:	74 15                	je     8008f2 <strncmp+0x30>
  8008dd:	0f b6 08             	movzbl (%eax),%ecx
  8008e0:	84 c9                	test   %cl,%cl
  8008e2:	74 04                	je     8008e8 <strncmp+0x26>
  8008e4:	3a 0a                	cmp    (%edx),%cl
  8008e6:	74 eb                	je     8008d3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e8:	0f b6 00             	movzbl (%eax),%eax
  8008eb:	0f b6 12             	movzbl (%edx),%edx
  8008ee:	29 d0                	sub    %edx,%eax
  8008f0:	eb 05                	jmp    8008f7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f7:	5b                   	pop    %ebx
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800904:	eb 07                	jmp    80090d <strchr+0x13>
		if (*s == c)
  800906:	38 ca                	cmp    %cl,%dl
  800908:	74 0f                	je     800919 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80090a:	83 c0 01             	add    $0x1,%eax
  80090d:	0f b6 10             	movzbl (%eax),%edx
  800910:	84 d2                	test   %dl,%dl
  800912:	75 f2                	jne    800906 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800914:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800925:	eb 07                	jmp    80092e <strfind+0x13>
		if (*s == c)
  800927:	38 ca                	cmp    %cl,%dl
  800929:	74 0a                	je     800935 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80092b:	83 c0 01             	add    $0x1,%eax
  80092e:	0f b6 10             	movzbl (%eax),%edx
  800931:	84 d2                	test   %dl,%dl
  800933:	75 f2                	jne    800927 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	57                   	push   %edi
  80093b:	56                   	push   %esi
  80093c:	53                   	push   %ebx
  80093d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800940:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800943:	85 c9                	test   %ecx,%ecx
  800945:	74 36                	je     80097d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800947:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094d:	75 28                	jne    800977 <memset+0x40>
  80094f:	f6 c1 03             	test   $0x3,%cl
  800952:	75 23                	jne    800977 <memset+0x40>
		c &= 0xFF;
  800954:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800958:	89 d3                	mov    %edx,%ebx
  80095a:	c1 e3 08             	shl    $0x8,%ebx
  80095d:	89 d6                	mov    %edx,%esi
  80095f:	c1 e6 18             	shl    $0x18,%esi
  800962:	89 d0                	mov    %edx,%eax
  800964:	c1 e0 10             	shl    $0x10,%eax
  800967:	09 f0                	or     %esi,%eax
  800969:	09 c2                	or     %eax,%edx
  80096b:	89 d0                	mov    %edx,%eax
  80096d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80096f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800972:	fc                   	cld    
  800973:	f3 ab                	rep stos %eax,%es:(%edi)
  800975:	eb 06                	jmp    80097d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800977:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097a:	fc                   	cld    
  80097b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097d:	89 f8                	mov    %edi,%eax
  80097f:	5b                   	pop    %ebx
  800980:	5e                   	pop    %esi
  800981:	5f                   	pop    %edi
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	57                   	push   %edi
  800988:	56                   	push   %esi
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800992:	39 c6                	cmp    %eax,%esi
  800994:	73 35                	jae    8009cb <memmove+0x47>
  800996:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800999:	39 d0                	cmp    %edx,%eax
  80099b:	73 2e                	jae    8009cb <memmove+0x47>
		s += n;
		d += n;
  80099d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009a0:	89 d6                	mov    %edx,%esi
  8009a2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009aa:	75 13                	jne    8009bf <memmove+0x3b>
  8009ac:	f6 c1 03             	test   $0x3,%cl
  8009af:	75 0e                	jne    8009bf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b1:	83 ef 04             	sub    $0x4,%edi
  8009b4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009ba:	fd                   	std    
  8009bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bd:	eb 09                	jmp    8009c8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009bf:	83 ef 01             	sub    $0x1,%edi
  8009c2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c5:	fd                   	std    
  8009c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c8:	fc                   	cld    
  8009c9:	eb 1d                	jmp    8009e8 <memmove+0x64>
  8009cb:	89 f2                	mov    %esi,%edx
  8009cd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cf:	f6 c2 03             	test   $0x3,%dl
  8009d2:	75 0f                	jne    8009e3 <memmove+0x5f>
  8009d4:	f6 c1 03             	test   $0x3,%cl
  8009d7:	75 0a                	jne    8009e3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009d9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009dc:	89 c7                	mov    %eax,%edi
  8009de:	fc                   	cld    
  8009df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e1:	eb 05                	jmp    8009e8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e3:	89 c7                	mov    %eax,%edi
  8009e5:	fc                   	cld    
  8009e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e8:	5e                   	pop    %esi
  8009e9:	5f                   	pop    %edi
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	89 04 24             	mov    %eax,(%esp)
  800a06:	e8 79 ff ff ff       	call   800984 <memmove>
}
  800a0b:	c9                   	leave  
  800a0c:	c3                   	ret    

00800a0d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	56                   	push   %esi
  800a11:	53                   	push   %ebx
  800a12:	8b 55 08             	mov    0x8(%ebp),%edx
  800a15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a18:	89 d6                	mov    %edx,%esi
  800a1a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1d:	eb 1a                	jmp    800a39 <memcmp+0x2c>
		if (*s1 != *s2)
  800a1f:	0f b6 02             	movzbl (%edx),%eax
  800a22:	0f b6 19             	movzbl (%ecx),%ebx
  800a25:	38 d8                	cmp    %bl,%al
  800a27:	74 0a                	je     800a33 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a29:	0f b6 c0             	movzbl %al,%eax
  800a2c:	0f b6 db             	movzbl %bl,%ebx
  800a2f:	29 d8                	sub    %ebx,%eax
  800a31:	eb 0f                	jmp    800a42 <memcmp+0x35>
		s1++, s2++;
  800a33:	83 c2 01             	add    $0x1,%edx
  800a36:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a39:	39 f2                	cmp    %esi,%edx
  800a3b:	75 e2                	jne    800a1f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a4f:	89 c2                	mov    %eax,%edx
  800a51:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a54:	eb 07                	jmp    800a5d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a56:	38 08                	cmp    %cl,(%eax)
  800a58:	74 07                	je     800a61 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5a:	83 c0 01             	add    $0x1,%eax
  800a5d:	39 d0                	cmp    %edx,%eax
  800a5f:	72 f5                	jb     800a56 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	57                   	push   %edi
  800a67:	56                   	push   %esi
  800a68:	53                   	push   %ebx
  800a69:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6f:	eb 03                	jmp    800a74 <strtol+0x11>
		s++;
  800a71:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a74:	0f b6 0a             	movzbl (%edx),%ecx
  800a77:	80 f9 09             	cmp    $0x9,%cl
  800a7a:	74 f5                	je     800a71 <strtol+0xe>
  800a7c:	80 f9 20             	cmp    $0x20,%cl
  800a7f:	74 f0                	je     800a71 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a81:	80 f9 2b             	cmp    $0x2b,%cl
  800a84:	75 0a                	jne    800a90 <strtol+0x2d>
		s++;
  800a86:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a89:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8e:	eb 11                	jmp    800aa1 <strtol+0x3e>
  800a90:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a95:	80 f9 2d             	cmp    $0x2d,%cl
  800a98:	75 07                	jne    800aa1 <strtol+0x3e>
		s++, neg = 1;
  800a9a:	8d 52 01             	lea    0x1(%edx),%edx
  800a9d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800aa6:	75 15                	jne    800abd <strtol+0x5a>
  800aa8:	80 3a 30             	cmpb   $0x30,(%edx)
  800aab:	75 10                	jne    800abd <strtol+0x5a>
  800aad:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ab1:	75 0a                	jne    800abd <strtol+0x5a>
		s += 2, base = 16;
  800ab3:	83 c2 02             	add    $0x2,%edx
  800ab6:	b8 10 00 00 00       	mov    $0x10,%eax
  800abb:	eb 10                	jmp    800acd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800abd:	85 c0                	test   %eax,%eax
  800abf:	75 0c                	jne    800acd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ac1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac3:	80 3a 30             	cmpb   $0x30,(%edx)
  800ac6:	75 05                	jne    800acd <strtol+0x6a>
		s++, base = 8;
  800ac8:	83 c2 01             	add    $0x1,%edx
  800acb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800acd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ad2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad5:	0f b6 0a             	movzbl (%edx),%ecx
  800ad8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800adb:	89 f0                	mov    %esi,%eax
  800add:	3c 09                	cmp    $0x9,%al
  800adf:	77 08                	ja     800ae9 <strtol+0x86>
			dig = *s - '0';
  800ae1:	0f be c9             	movsbl %cl,%ecx
  800ae4:	83 e9 30             	sub    $0x30,%ecx
  800ae7:	eb 20                	jmp    800b09 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800ae9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800aec:	89 f0                	mov    %esi,%eax
  800aee:	3c 19                	cmp    $0x19,%al
  800af0:	77 08                	ja     800afa <strtol+0x97>
			dig = *s - 'a' + 10;
  800af2:	0f be c9             	movsbl %cl,%ecx
  800af5:	83 e9 57             	sub    $0x57,%ecx
  800af8:	eb 0f                	jmp    800b09 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800afa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800afd:	89 f0                	mov    %esi,%eax
  800aff:	3c 19                	cmp    $0x19,%al
  800b01:	77 16                	ja     800b19 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800b03:	0f be c9             	movsbl %cl,%ecx
  800b06:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b09:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b0c:	7d 0f                	jge    800b1d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800b0e:	83 c2 01             	add    $0x1,%edx
  800b11:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800b15:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800b17:	eb bc                	jmp    800ad5 <strtol+0x72>
  800b19:	89 d8                	mov    %ebx,%eax
  800b1b:	eb 02                	jmp    800b1f <strtol+0xbc>
  800b1d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800b1f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b23:	74 05                	je     800b2a <strtol+0xc7>
		*endptr = (char *) s;
  800b25:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b28:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b2a:	f7 d8                	neg    %eax
  800b2c:	85 ff                	test   %edi,%edi
  800b2e:	0f 44 c3             	cmove  %ebx,%eax
}
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5f                   	pop    %edi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    

00800b36 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	57                   	push   %edi
  800b3a:	56                   	push   %esi
  800b3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b44:	8b 55 08             	mov    0x8(%ebp),%edx
  800b47:	89 c3                	mov    %eax,%ebx
  800b49:	89 c7                	mov    %eax,%edi
  800b4b:	89 c6                	mov    %eax,%esi
  800b4d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4f:	5b                   	pop    %ebx
  800b50:	5e                   	pop    %esi
  800b51:	5f                   	pop    %edi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	57                   	push   %edi
  800b58:	56                   	push   %esi
  800b59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b64:	89 d1                	mov    %edx,%ecx
  800b66:	89 d3                	mov    %edx,%ebx
  800b68:	89 d7                	mov    %edx,%edi
  800b6a:	89 d6                	mov    %edx,%esi
  800b6c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5f                   	pop    %edi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	57                   	push   %edi
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
  800b79:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b81:	b8 03 00 00 00       	mov    $0x3,%eax
  800b86:	8b 55 08             	mov    0x8(%ebp),%edx
  800b89:	89 cb                	mov    %ecx,%ebx
  800b8b:	89 cf                	mov    %ecx,%edi
  800b8d:	89 ce                	mov    %ecx,%esi
  800b8f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b91:	85 c0                	test   %eax,%eax
  800b93:	7e 28                	jle    800bbd <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b95:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b99:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ba0:	00 
  800ba1:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  800ba8:	00 
  800ba9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bb0:	00 
  800bb1:	c7 04 24 7c 2d 80 00 	movl   $0x802d7c,(%esp)
  800bb8:	e8 39 19 00 00       	call   8024f6 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bbd:	83 c4 2c             	add    $0x2c,%esp
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcb:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd0:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd5:	89 d1                	mov    %edx,%ecx
  800bd7:	89 d3                	mov    %edx,%ebx
  800bd9:	89 d7                	mov    %edx,%edi
  800bdb:	89 d6                	mov    %edx,%esi
  800bdd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <sys_yield>:

void
sys_yield(void)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bea:	ba 00 00 00 00       	mov    $0x0,%edx
  800bef:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bf4:	89 d1                	mov    %edx,%ecx
  800bf6:	89 d3                	mov    %edx,%ebx
  800bf8:	89 d7                	mov    %edx,%edi
  800bfa:	89 d6                	mov    %edx,%esi
  800bfc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0c:	be 00 00 00 00       	mov    $0x0,%esi
  800c11:	b8 04 00 00 00       	mov    $0x4,%eax
  800c16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1f:	89 f7                	mov    %esi,%edi
  800c21:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c23:	85 c0                	test   %eax,%eax
  800c25:	7e 28                	jle    800c4f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c27:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c2b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c32:	00 
  800c33:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  800c3a:	00 
  800c3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c42:	00 
  800c43:	c7 04 24 7c 2d 80 00 	movl   $0x802d7c,(%esp)
  800c4a:	e8 a7 18 00 00       	call   8024f6 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c4f:	83 c4 2c             	add    $0x2c,%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c60:	b8 05 00 00 00       	mov    $0x5,%eax
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c71:	8b 75 18             	mov    0x18(%ebp),%esi
  800c74:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c76:	85 c0                	test   %eax,%eax
  800c78:	7e 28                	jle    800ca2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c85:	00 
  800c86:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  800c8d:	00 
  800c8e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c95:	00 
  800c96:	c7 04 24 7c 2d 80 00 	movl   $0x802d7c,(%esp)
  800c9d:	e8 54 18 00 00       	call   8024f6 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ca2:	83 c4 2c             	add    $0x2c,%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
  800cb0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb8:	b8 06 00 00 00       	mov    $0x6,%eax
  800cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc3:	89 df                	mov    %ebx,%edi
  800cc5:	89 de                	mov    %ebx,%esi
  800cc7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	7e 28                	jle    800cf5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cd8:	00 
  800cd9:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  800ce0:	00 
  800ce1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce8:	00 
  800ce9:	c7 04 24 7c 2d 80 00 	movl   $0x802d7c,(%esp)
  800cf0:	e8 01 18 00 00       	call   8024f6 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf5:	83 c4 2c             	add    $0x2c,%esp
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    

00800cfd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	57                   	push   %edi
  800d01:	56                   	push   %esi
  800d02:	53                   	push   %ebx
  800d03:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d13:	8b 55 08             	mov    0x8(%ebp),%edx
  800d16:	89 df                	mov    %ebx,%edi
  800d18:	89 de                	mov    %ebx,%esi
  800d1a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	7e 28                	jle    800d48 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d20:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d24:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d2b:	00 
  800d2c:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  800d33:	00 
  800d34:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3b:	00 
  800d3c:	c7 04 24 7c 2d 80 00 	movl   $0x802d7c,(%esp)
  800d43:	e8 ae 17 00 00       	call   8024f6 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d48:	83 c4 2c             	add    $0x2c,%esp
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
  800d56:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d59:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5e:	b8 09 00 00 00       	mov    $0x9,%eax
  800d63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d66:	8b 55 08             	mov    0x8(%ebp),%edx
  800d69:	89 df                	mov    %ebx,%edi
  800d6b:	89 de                	mov    %ebx,%esi
  800d6d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6f:	85 c0                	test   %eax,%eax
  800d71:	7e 28                	jle    800d9b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d73:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d77:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d7e:	00 
  800d7f:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  800d86:	00 
  800d87:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8e:	00 
  800d8f:	c7 04 24 7c 2d 80 00 	movl   $0x802d7c,(%esp)
  800d96:	e8 5b 17 00 00       	call   8024f6 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d9b:	83 c4 2c             	add    $0x2c,%esp
  800d9e:	5b                   	pop    %ebx
  800d9f:	5e                   	pop    %esi
  800da0:	5f                   	pop    %edi
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	57                   	push   %edi
  800da7:	56                   	push   %esi
  800da8:	53                   	push   %ebx
  800da9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dac:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800db6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbc:	89 df                	mov    %ebx,%edi
  800dbe:	89 de                	mov    %ebx,%esi
  800dc0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	7e 28                	jle    800dee <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dca:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800dd1:	00 
  800dd2:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  800dd9:	00 
  800dda:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de1:	00 
  800de2:	c7 04 24 7c 2d 80 00 	movl   $0x802d7c,(%esp)
  800de9:	e8 08 17 00 00       	call   8024f6 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dee:	83 c4 2c             	add    $0x2c,%esp
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	57                   	push   %edi
  800dfa:	56                   	push   %esi
  800dfb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfc:	be 00 00 00 00       	mov    $0x0,%esi
  800e01:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e12:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e14:	5b                   	pop    %ebx
  800e15:	5e                   	pop    %esi
  800e16:	5f                   	pop    %edi
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    

00800e19 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	57                   	push   %edi
  800e1d:	56                   	push   %esi
  800e1e:	53                   	push   %ebx
  800e1f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e22:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e27:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2f:	89 cb                	mov    %ecx,%ebx
  800e31:	89 cf                	mov    %ecx,%edi
  800e33:	89 ce                	mov    %ecx,%esi
  800e35:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e37:	85 c0                	test   %eax,%eax
  800e39:	7e 28                	jle    800e63 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e46:	00 
  800e47:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  800e4e:	00 
  800e4f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e56:	00 
  800e57:	c7 04 24 7c 2d 80 00 	movl   $0x802d7c,(%esp)
  800e5e:	e8 93 16 00 00       	call   8024f6 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e63:	83 c4 2c             	add    $0x2c,%esp
  800e66:	5b                   	pop    %ebx
  800e67:	5e                   	pop    %esi
  800e68:	5f                   	pop    %edi
  800e69:	5d                   	pop    %ebp
  800e6a:	c3                   	ret    

00800e6b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	57                   	push   %edi
  800e6f:	56                   	push   %esi
  800e70:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e71:	ba 00 00 00 00       	mov    $0x0,%edx
  800e76:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e7b:	89 d1                	mov    %edx,%ecx
  800e7d:	89 d3                	mov    %edx,%ebx
  800e7f:	89 d7                	mov    %edx,%edi
  800e81:	89 d6                	mov    %edx,%esi
  800e83:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e85:	5b                   	pop    %ebx
  800e86:	5e                   	pop    %esi
  800e87:	5f                   	pop    %edi
  800e88:	5d                   	pop    %ebp
  800e89:	c3                   	ret    

00800e8a <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  800e8a:	55                   	push   %ebp
  800e8b:	89 e5                	mov    %esp,%ebp
  800e8d:	57                   	push   %edi
  800e8e:	56                   	push   %esi
  800e8f:	53                   	push   %ebx
  800e90:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e98:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea3:	89 df                	mov    %ebx,%edi
  800ea5:	89 de                	mov    %ebx,%esi
  800ea7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea9:	85 c0                	test   %eax,%eax
  800eab:	7e 28                	jle    800ed5 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ead:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb1:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800eb8:	00 
  800eb9:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  800ec0:	00 
  800ec1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec8:	00 
  800ec9:	c7 04 24 7c 2d 80 00 	movl   $0x802d7c,(%esp)
  800ed0:	e8 21 16 00 00       	call   8024f6 <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  800ed5:	83 c4 2c             	add    $0x2c,%esp
  800ed8:	5b                   	pop    %ebx
  800ed9:	5e                   	pop    %esi
  800eda:	5f                   	pop    %edi
  800edb:	5d                   	pop    %ebp
  800edc:	c3                   	ret    

00800edd <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	57                   	push   %edi
  800ee1:	56                   	push   %esi
  800ee2:	53                   	push   %ebx
  800ee3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eeb:	b8 10 00 00 00       	mov    $0x10,%eax
  800ef0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef6:	89 df                	mov    %ebx,%edi
  800ef8:	89 de                	mov    %ebx,%esi
  800efa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800efc:	85 c0                	test   %eax,%eax
  800efe:	7e 28                	jle    800f28 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f00:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f04:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  800f0b:	00 
  800f0c:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  800f13:	00 
  800f14:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f1b:	00 
  800f1c:	c7 04 24 7c 2d 80 00 	movl   $0x802d7c,(%esp)
  800f23:	e8 ce 15 00 00       	call   8024f6 <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  800f28:	83 c4 2c             	add    $0x2c,%esp
  800f2b:	5b                   	pop    %ebx
  800f2c:	5e                   	pop    %esi
  800f2d:	5f                   	pop    %edi
  800f2e:	5d                   	pop    %ebp
  800f2f:	c3                   	ret    

00800f30 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	56                   	push   %esi
  800f34:	53                   	push   %ebx
  800f35:	83 ec 20             	sub    $0x20,%esp
  800f38:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f3b:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if(!(err & FEC_WR)) {
  800f3d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f41:	75 20                	jne    800f63 <pgfault+0x33>
		panic("0x%x Not a write", addr);
  800f43:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800f47:	c7 44 24 08 8a 2d 80 	movl   $0x802d8a,0x8(%esp)
  800f4e:	00 
  800f4f:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800f56:	00 
  800f57:	c7 04 24 9b 2d 80 00 	movl   $0x802d9b,(%esp)
  800f5e:	e8 93 15 00 00       	call   8024f6 <_panic>
	}

	if(!(uvpt[PGNUM(addr)] & PTE_COW)) {
  800f63:	89 f0                	mov    %esi,%eax
  800f65:	c1 e8 0c             	shr    $0xc,%eax
  800f68:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f6f:	f6 c4 08             	test   $0x8,%ah
  800f72:	75 1c                	jne    800f90 <pgfault+0x60>
		panic("Not a COW page");
  800f74:	c7 44 24 08 a6 2d 80 	movl   $0x802da6,0x8(%esp)
  800f7b:	00 
  800f7c:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800f83:	00 
  800f84:	c7 04 24 9b 2d 80 00 	movl   $0x802d9b,(%esp)
  800f8b:	e8 66 15 00 00       	call   8024f6 <_panic>

	// Allocate a new page, map it at a temporary location (PFTEMP), // copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	envid_t envid = sys_getenvid();
  800f90:	e8 30 fc ff ff       	call   800bc5 <sys_getenvid>
  800f95:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, PFTEMP, PTE_W | PTE_U | PTE_P);
  800f97:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f9e:	00 
  800f9f:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fa6:	00 
  800fa7:	89 04 24             	mov    %eax,(%esp)
  800faa:	e8 54 fc ff ff       	call   800c03 <sys_page_alloc>
	if(r < 0) {
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	79 1c                	jns    800fcf <pgfault+0x9f>
		panic("couldn't allocate page");
  800fb3:	c7 44 24 08 b5 2d 80 	movl   $0x802db5,0x8(%esp)
  800fba:	00 
  800fbb:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  800fc2:	00 
  800fc3:	c7 04 24 9b 2d 80 00 	movl   $0x802d9b,(%esp)
  800fca:	e8 27 15 00 00       	call   8024f6 <_panic>
	}

	memmove(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800fcf:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  800fd5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800fdc:	00 
  800fdd:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fe1:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800fe8:	e8 97 f9 ff ff       	call   800984 <memmove>

	r = sys_page_map(envid, PFTEMP, envid, ROUNDDOWN(addr,PGSIZE), PTE_P | PTE_U | PTE_W);
  800fed:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800ff4:	00 
  800ff5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ff9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ffd:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801004:	00 
  801005:	89 1c 24             	mov    %ebx,(%esp)
  801008:	e8 4a fc ff ff       	call   800c57 <sys_page_map>
	if(r < 0) {
  80100d:	85 c0                	test   %eax,%eax
  80100f:	79 1c                	jns    80102d <pgfault+0xfd>
		panic("couldn't map page");
  801011:	c7 44 24 08 cc 2d 80 	movl   $0x802dcc,0x8(%esp)
  801018:	00 
  801019:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  801020:	00 
  801021:	c7 04 24 9b 2d 80 00 	movl   $0x802d9b,(%esp)
  801028:	e8 c9 14 00 00       	call   8024f6 <_panic>
	}
}
  80102d:	83 c4 20             	add    $0x20,%esp
  801030:	5b                   	pop    %ebx
  801031:	5e                   	pop    %esi
  801032:	5d                   	pop    %ebp
  801033:	c3                   	ret    

00801034 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	57                   	push   %edi
  801038:	56                   	push   %esi
  801039:	53                   	push   %ebx
  80103a:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envid;
	uintptr_t addr;
	int r = 0;

	set_pgfault_handler(pgfault);
  80103d:	c7 04 24 30 0f 80 00 	movl   $0x800f30,(%esp)
  801044:	e8 03 15 00 00       	call   80254c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801049:	b8 07 00 00 00       	mov    $0x7,%eax
  80104e:	cd 30                	int    $0x30
  801050:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801053:	89 45 d8             	mov    %eax,-0x28(%ebp)

	envid = sys_exofork();
	if(envid == 0) {
  801056:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80105d:	bf 00 00 00 00       	mov    $0x0,%edi
  801062:	85 c0                	test   %eax,%eax
  801064:	75 21                	jne    801087 <fork+0x53>
		thisenv = &envs[ENVX(sys_getenvid())];
  801066:	e8 5a fb ff ff       	call   800bc5 <sys_getenvid>
  80106b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801070:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801073:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801078:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  80107d:	b8 00 00 00 00       	mov    $0x0,%eax
  801082:	e9 8d 01 00 00       	jmp    801214 <fork+0x1e0>
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
  801087:	89 f8                	mov    %edi,%eax
  801089:	c1 e8 16             	shr    $0x16,%eax
  80108c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801093:	85 c0                	test   %eax,%eax
  801095:	0f 84 02 01 00 00    	je     80119d <fork+0x169>
  80109b:	89 fa                	mov    %edi,%edx
  80109d:	c1 ea 0c             	shr    $0xc,%edx
  8010a0:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	0f 84 ee 00 00 00    	je     80119d <fork+0x169>
//
static int
duppage(envid_t envid, unsigned pn)
{

	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P)) return 0;
  8010af:	89 d6                	mov    %edx,%esi
  8010b1:	c1 e6 0c             	shl    $0xc,%esi
  8010b4:	89 f0                	mov    %esi,%eax
  8010b6:	c1 e8 16             	shr    $0x16,%eax
  8010b9:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8010c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c5:	f6 c1 01             	test   $0x1,%cl
  8010c8:	0f 84 cc 00 00 00    	je     80119a <fork+0x166>

	int all_perms = PTE_U | PTE_P | PTE_AVAIL | PTE_W | PTE_COW;
	int orig_perms = uvpt[pn] & all_perms;
  8010ce:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  8010d5:	89 d8                	mov    %ebx,%eax
  8010d7:	25 07 0e 00 00       	and    $0xe07,%eax
  8010dc:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if(!(orig_perms & PTE_P)) return 0;
  8010df:	89 d8                	mov    %ebx,%eax
  8010e1:	83 e0 01             	and    $0x1,%eax
  8010e4:	0f 84 b0 00 00 00    	je     80119a <fork+0x166>

	int r = 0;
	envid_t curenvid = sys_getenvid();
  8010ea:	e8 d6 fa ff ff       	call   800bc5 <sys_getenvid>
  8010ef:	89 45 dc             	mov    %eax,-0x24(%ebp)


	if(orig_perms & PTE_SHARE) {
  8010f2:	f7 45 e0 00 04 00 00 	testl  $0x400,-0x20(%ebp)
  8010f9:	74 28                	je     801123 <fork+0xef>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms & PTE_SYSCALL));
  8010fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010fe:	25 07 0e 00 00       	and    $0xe07,%eax
  801103:	89 44 24 10          	mov    %eax,0x10(%esp)
  801107:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80110b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80110e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801112:	89 74 24 04          	mov    %esi,0x4(%esp)
  801116:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801119:	89 04 24             	mov    %eax,(%esp)
  80111c:	e8 36 fb ff ff       	call   800c57 <sys_page_map>
  801121:	eb 77                	jmp    80119a <fork+0x166>

	} else if(((orig_perms) & PTE_COW) || (orig_perms & PTE_W) ) {
  801123:	f7 c3 02 08 00 00    	test   $0x802,%ebx
  801129:	74 4e                	je     801179 <fork+0x145>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  80112b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80112e:	25 fd f7 ff ff       	and    $0xfffff7fd,%eax
  801133:	80 cc 08             	or     $0x8,%ah
  801136:	89 c3                	mov    %eax,%ebx
  801138:	89 44 24 10          	mov    %eax,0x10(%esp)
  80113c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801140:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801143:	89 44 24 08          	mov    %eax,0x8(%esp)
  801147:	89 74 24 04          	mov    %esi,0x4(%esp)
  80114b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80114e:	89 04 24             	mov    %eax,(%esp)
  801151:	e8 01 fb ff ff       	call   800c57 <sys_page_map>
  801156:	89 45 e0             	mov    %eax,-0x20(%ebp)

		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), curenvid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  801159:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80115d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801161:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801164:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801168:	89 74 24 04          	mov    %esi,0x4(%esp)
  80116c:	89 0c 24             	mov    %ecx,(%esp)
  80116f:	e8 e3 fa ff ff       	call   800c57 <sys_page_map>
  801174:	03 45 e0             	add    -0x20(%ebp),%eax
  801177:	eb 21                	jmp    80119a <fork+0x166>

	} else {
		r = sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), orig_perms);
  801179:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80117c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801180:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801184:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801187:	89 44 24 08          	mov    %eax,0x8(%esp)
  80118b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80118f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801192:	89 04 24             	mov    %eax,(%esp)
  801195:	e8 bd fa ff ff       	call   800c57 <sys_page_map>
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
  80119a:	01 45 e4             	add    %eax,-0x1c(%ebp)
	if(envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
  80119d:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8011a3:	81 ff 00 f0 bf ee    	cmp    $0xeebff000,%edi
  8011a9:	0f 85 d8 fe ff ff    	jne    801087 <fork+0x53>
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
		}
	}

	r+=sys_page_alloc(envid, (void*)UXSTACKTOP - PGSIZE, PTE_P|PTE_U|PTE_W);
  8011af:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011b6:	00 
  8011b7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011be:	ee 
  8011bf:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8011c2:	89 34 24             	mov    %esi,(%esp)
  8011c5:	e8 39 fa ff ff       	call   800c03 <sys_page_alloc>
  8011ca:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8011cd:	01 c3                	add    %eax,%ebx
	r+=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8011cf:	c7 44 24 04 99 25 80 	movl   $0x802599,0x4(%esp)
  8011d6:	00 
  8011d7:	89 34 24             	mov    %esi,(%esp)
  8011da:	e8 c4 fb ff ff       	call   800da3 <sys_env_set_pgfault_upcall>
  8011df:	01 c3                	add    %eax,%ebx
	r+= sys_env_set_status(envid, ENV_RUNNABLE);
  8011e1:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8011e8:	00 
  8011e9:	89 34 24             	mov    %esi,(%esp)
  8011ec:	e8 0c fb ff ff       	call   800cfd <sys_env_set_status>

	if(r<0) {
  8011f1:	01 d8                	add    %ebx,%eax
  8011f3:	79 1c                	jns    801211 <fork+0x1dd>
	 panic("fork failed!");
  8011f5:	c7 44 24 08 de 2d 80 	movl   $0x802dde,0x8(%esp)
  8011fc:	00 
  8011fd:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  801204:	00 
  801205:	c7 04 24 9b 2d 80 00 	movl   $0x802d9b,(%esp)
  80120c:	e8 e5 12 00 00       	call   8024f6 <_panic>
	}

	return envid;
  801211:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  801214:	83 c4 3c             	add    $0x3c,%esp
  801217:	5b                   	pop    %ebx
  801218:	5e                   	pop    %esi
  801219:	5f                   	pop    %edi
  80121a:	5d                   	pop    %ebp
  80121b:	c3                   	ret    

0080121c <sfork>:

// Challenge!
int
sfork(void)
{
  80121c:	55                   	push   %ebp
  80121d:	89 e5                	mov    %esp,%ebp
  80121f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801222:	c7 44 24 08 eb 2d 80 	movl   $0x802deb,0x8(%esp)
  801229:	00 
  80122a:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
  801231:	00 
  801232:	c7 04 24 9b 2d 80 00 	movl   $0x802d9b,(%esp)
  801239:	e8 b8 12 00 00       	call   8024f6 <_panic>
  80123e:	66 90                	xchg   %ax,%ax

00801240 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801243:	8b 45 08             	mov    0x8(%ebp),%eax
  801246:	05 00 00 00 30       	add    $0x30000000,%eax
  80124b:	c1 e8 0c             	shr    $0xc,%eax
}
  80124e:	5d                   	pop    %ebp
  80124f:	c3                   	ret    

00801250 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801253:	8b 45 08             	mov    0x8(%ebp),%eax
  801256:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80125b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801260:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801265:	5d                   	pop    %ebp
  801266:	c3                   	ret    

00801267 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801267:	55                   	push   %ebp
  801268:	89 e5                	mov    %esp,%ebp
  80126a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80126d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801272:	89 c2                	mov    %eax,%edx
  801274:	c1 ea 16             	shr    $0x16,%edx
  801277:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80127e:	f6 c2 01             	test   $0x1,%dl
  801281:	74 11                	je     801294 <fd_alloc+0x2d>
  801283:	89 c2                	mov    %eax,%edx
  801285:	c1 ea 0c             	shr    $0xc,%edx
  801288:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80128f:	f6 c2 01             	test   $0x1,%dl
  801292:	75 09                	jne    80129d <fd_alloc+0x36>
			*fd_store = fd;
  801294:	89 01                	mov    %eax,(%ecx)
			return 0;
  801296:	b8 00 00 00 00       	mov    $0x0,%eax
  80129b:	eb 17                	jmp    8012b4 <fd_alloc+0x4d>
  80129d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012a2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012a7:	75 c9                	jne    801272 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012a9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012af:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012b4:	5d                   	pop    %ebp
  8012b5:	c3                   	ret    

008012b6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012b6:	55                   	push   %ebp
  8012b7:	89 e5                	mov    %esp,%ebp
  8012b9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012bc:	83 f8 1f             	cmp    $0x1f,%eax
  8012bf:	77 36                	ja     8012f7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012c1:	c1 e0 0c             	shl    $0xc,%eax
  8012c4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012c9:	89 c2                	mov    %eax,%edx
  8012cb:	c1 ea 16             	shr    $0x16,%edx
  8012ce:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012d5:	f6 c2 01             	test   $0x1,%dl
  8012d8:	74 24                	je     8012fe <fd_lookup+0x48>
  8012da:	89 c2                	mov    %eax,%edx
  8012dc:	c1 ea 0c             	shr    $0xc,%edx
  8012df:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012e6:	f6 c2 01             	test   $0x1,%dl
  8012e9:	74 1a                	je     801305 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ee:	89 02                	mov    %eax,(%edx)
	return 0;
  8012f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f5:	eb 13                	jmp    80130a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012fc:	eb 0c                	jmp    80130a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801303:	eb 05                	jmp    80130a <fd_lookup+0x54>
  801305:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80130a:	5d                   	pop    %ebp
  80130b:	c3                   	ret    

0080130c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80130c:	55                   	push   %ebp
  80130d:	89 e5                	mov    %esp,%ebp
  80130f:	83 ec 18             	sub    $0x18,%esp
  801312:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801315:	ba 00 00 00 00       	mov    $0x0,%edx
  80131a:	eb 13                	jmp    80132f <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  80131c:	39 08                	cmp    %ecx,(%eax)
  80131e:	75 0c                	jne    80132c <dev_lookup+0x20>
			*dev = devtab[i];
  801320:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801323:	89 01                	mov    %eax,(%ecx)
			return 0;
  801325:	b8 00 00 00 00       	mov    $0x0,%eax
  80132a:	eb 38                	jmp    801364 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80132c:	83 c2 01             	add    $0x1,%edx
  80132f:	8b 04 95 80 2e 80 00 	mov    0x802e80(,%edx,4),%eax
  801336:	85 c0                	test   %eax,%eax
  801338:	75 e2                	jne    80131c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80133a:	a1 08 40 80 00       	mov    0x804008,%eax
  80133f:	8b 40 48             	mov    0x48(%eax),%eax
  801342:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801346:	89 44 24 04          	mov    %eax,0x4(%esp)
  80134a:	c7 04 24 04 2e 80 00 	movl   $0x802e04,(%esp)
  801351:	e8 6d ee ff ff       	call   8001c3 <cprintf>
	*dev = 0;
  801356:	8b 45 0c             	mov    0xc(%ebp),%eax
  801359:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80135f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801364:	c9                   	leave  
  801365:	c3                   	ret    

00801366 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801366:	55                   	push   %ebp
  801367:	89 e5                	mov    %esp,%ebp
  801369:	56                   	push   %esi
  80136a:	53                   	push   %ebx
  80136b:	83 ec 20             	sub    $0x20,%esp
  80136e:	8b 75 08             	mov    0x8(%ebp),%esi
  801371:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801374:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801377:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80137b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801381:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801384:	89 04 24             	mov    %eax,(%esp)
  801387:	e8 2a ff ff ff       	call   8012b6 <fd_lookup>
  80138c:	85 c0                	test   %eax,%eax
  80138e:	78 05                	js     801395 <fd_close+0x2f>
	    || fd != fd2)
  801390:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801393:	74 0c                	je     8013a1 <fd_close+0x3b>
		return (must_exist ? r : 0);
  801395:	84 db                	test   %bl,%bl
  801397:	ba 00 00 00 00       	mov    $0x0,%edx
  80139c:	0f 44 c2             	cmove  %edx,%eax
  80139f:	eb 3f                	jmp    8013e0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a8:	8b 06                	mov    (%esi),%eax
  8013aa:	89 04 24             	mov    %eax,(%esp)
  8013ad:	e8 5a ff ff ff       	call   80130c <dev_lookup>
  8013b2:	89 c3                	mov    %eax,%ebx
  8013b4:	85 c0                	test   %eax,%eax
  8013b6:	78 16                	js     8013ce <fd_close+0x68>
		if (dev->dev_close)
  8013b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013bb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013be:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013c3:	85 c0                	test   %eax,%eax
  8013c5:	74 07                	je     8013ce <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8013c7:	89 34 24             	mov    %esi,(%esp)
  8013ca:	ff d0                	call   *%eax
  8013cc:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013d9:	e8 cc f8 ff ff       	call   800caa <sys_page_unmap>
	return r;
  8013de:	89 d8                	mov    %ebx,%eax
}
  8013e0:	83 c4 20             	add    $0x20,%esp
  8013e3:	5b                   	pop    %ebx
  8013e4:	5e                   	pop    %esi
  8013e5:	5d                   	pop    %ebp
  8013e6:	c3                   	ret    

008013e7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013e7:	55                   	push   %ebp
  8013e8:	89 e5                	mov    %esp,%ebp
  8013ea:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f7:	89 04 24             	mov    %eax,(%esp)
  8013fa:	e8 b7 fe ff ff       	call   8012b6 <fd_lookup>
  8013ff:	89 c2                	mov    %eax,%edx
  801401:	85 d2                	test   %edx,%edx
  801403:	78 13                	js     801418 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801405:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80140c:	00 
  80140d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801410:	89 04 24             	mov    %eax,(%esp)
  801413:	e8 4e ff ff ff       	call   801366 <fd_close>
}
  801418:	c9                   	leave  
  801419:	c3                   	ret    

0080141a <close_all>:

void
close_all(void)
{
  80141a:	55                   	push   %ebp
  80141b:	89 e5                	mov    %esp,%ebp
  80141d:	53                   	push   %ebx
  80141e:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801421:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801426:	89 1c 24             	mov    %ebx,(%esp)
  801429:	e8 b9 ff ff ff       	call   8013e7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80142e:	83 c3 01             	add    $0x1,%ebx
  801431:	83 fb 20             	cmp    $0x20,%ebx
  801434:	75 f0                	jne    801426 <close_all+0xc>
		close(i);
}
  801436:	83 c4 14             	add    $0x14,%esp
  801439:	5b                   	pop    %ebx
  80143a:	5d                   	pop    %ebp
  80143b:	c3                   	ret    

0080143c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	57                   	push   %edi
  801440:	56                   	push   %esi
  801441:	53                   	push   %ebx
  801442:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801445:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801448:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144c:	8b 45 08             	mov    0x8(%ebp),%eax
  80144f:	89 04 24             	mov    %eax,(%esp)
  801452:	e8 5f fe ff ff       	call   8012b6 <fd_lookup>
  801457:	89 c2                	mov    %eax,%edx
  801459:	85 d2                	test   %edx,%edx
  80145b:	0f 88 e1 00 00 00    	js     801542 <dup+0x106>
		return r;
	close(newfdnum);
  801461:	8b 45 0c             	mov    0xc(%ebp),%eax
  801464:	89 04 24             	mov    %eax,(%esp)
  801467:	e8 7b ff ff ff       	call   8013e7 <close>

	newfd = INDEX2FD(newfdnum);
  80146c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80146f:	c1 e3 0c             	shl    $0xc,%ebx
  801472:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801478:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80147b:	89 04 24             	mov    %eax,(%esp)
  80147e:	e8 cd fd ff ff       	call   801250 <fd2data>
  801483:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801485:	89 1c 24             	mov    %ebx,(%esp)
  801488:	e8 c3 fd ff ff       	call   801250 <fd2data>
  80148d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80148f:	89 f0                	mov    %esi,%eax
  801491:	c1 e8 16             	shr    $0x16,%eax
  801494:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80149b:	a8 01                	test   $0x1,%al
  80149d:	74 43                	je     8014e2 <dup+0xa6>
  80149f:	89 f0                	mov    %esi,%eax
  8014a1:	c1 e8 0c             	shr    $0xc,%eax
  8014a4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014ab:	f6 c2 01             	test   $0x1,%dl
  8014ae:	74 32                	je     8014e2 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014b0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014b7:	25 07 0e 00 00       	and    $0xe07,%eax
  8014bc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014c0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014cb:	00 
  8014cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014d7:	e8 7b f7 ff ff       	call   800c57 <sys_page_map>
  8014dc:	89 c6                	mov    %eax,%esi
  8014de:	85 c0                	test   %eax,%eax
  8014e0:	78 3e                	js     801520 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014e5:	89 c2                	mov    %eax,%edx
  8014e7:	c1 ea 0c             	shr    $0xc,%edx
  8014ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014f1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8014f7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8014fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8014ff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801506:	00 
  801507:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801512:	e8 40 f7 ff ff       	call   800c57 <sys_page_map>
  801517:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801519:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80151c:	85 f6                	test   %esi,%esi
  80151e:	79 22                	jns    801542 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801520:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801524:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80152b:	e8 7a f7 ff ff       	call   800caa <sys_page_unmap>
	sys_page_unmap(0, nva);
  801530:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801534:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80153b:	e8 6a f7 ff ff       	call   800caa <sys_page_unmap>
	return r;
  801540:	89 f0                	mov    %esi,%eax
}
  801542:	83 c4 3c             	add    $0x3c,%esp
  801545:	5b                   	pop    %ebx
  801546:	5e                   	pop    %esi
  801547:	5f                   	pop    %edi
  801548:	5d                   	pop    %ebp
  801549:	c3                   	ret    

0080154a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	53                   	push   %ebx
  80154e:	83 ec 24             	sub    $0x24,%esp
  801551:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801554:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801557:	89 44 24 04          	mov    %eax,0x4(%esp)
  80155b:	89 1c 24             	mov    %ebx,(%esp)
  80155e:	e8 53 fd ff ff       	call   8012b6 <fd_lookup>
  801563:	89 c2                	mov    %eax,%edx
  801565:	85 d2                	test   %edx,%edx
  801567:	78 6d                	js     8015d6 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801569:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801570:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801573:	8b 00                	mov    (%eax),%eax
  801575:	89 04 24             	mov    %eax,(%esp)
  801578:	e8 8f fd ff ff       	call   80130c <dev_lookup>
  80157d:	85 c0                	test   %eax,%eax
  80157f:	78 55                	js     8015d6 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801581:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801584:	8b 50 08             	mov    0x8(%eax),%edx
  801587:	83 e2 03             	and    $0x3,%edx
  80158a:	83 fa 01             	cmp    $0x1,%edx
  80158d:	75 23                	jne    8015b2 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80158f:	a1 08 40 80 00       	mov    0x804008,%eax
  801594:	8b 40 48             	mov    0x48(%eax),%eax
  801597:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80159b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80159f:	c7 04 24 45 2e 80 00 	movl   $0x802e45,(%esp)
  8015a6:	e8 18 ec ff ff       	call   8001c3 <cprintf>
		return -E_INVAL;
  8015ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015b0:	eb 24                	jmp    8015d6 <read+0x8c>
	}
	if (!dev->dev_read)
  8015b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b5:	8b 52 08             	mov    0x8(%edx),%edx
  8015b8:	85 d2                	test   %edx,%edx
  8015ba:	74 15                	je     8015d1 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015bf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015c6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015ca:	89 04 24             	mov    %eax,(%esp)
  8015cd:	ff d2                	call   *%edx
  8015cf:	eb 05                	jmp    8015d6 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015d1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8015d6:	83 c4 24             	add    $0x24,%esp
  8015d9:	5b                   	pop    %ebx
  8015da:	5d                   	pop    %ebp
  8015db:	c3                   	ret    

008015dc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015dc:	55                   	push   %ebp
  8015dd:	89 e5                	mov    %esp,%ebp
  8015df:	57                   	push   %edi
  8015e0:	56                   	push   %esi
  8015e1:	53                   	push   %ebx
  8015e2:	83 ec 1c             	sub    $0x1c,%esp
  8015e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015e8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015f0:	eb 23                	jmp    801615 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015f2:	89 f0                	mov    %esi,%eax
  8015f4:	29 d8                	sub    %ebx,%eax
  8015f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015fa:	89 d8                	mov    %ebx,%eax
  8015fc:	03 45 0c             	add    0xc(%ebp),%eax
  8015ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801603:	89 3c 24             	mov    %edi,(%esp)
  801606:	e8 3f ff ff ff       	call   80154a <read>
		if (m < 0)
  80160b:	85 c0                	test   %eax,%eax
  80160d:	78 10                	js     80161f <readn+0x43>
			return m;
		if (m == 0)
  80160f:	85 c0                	test   %eax,%eax
  801611:	74 0a                	je     80161d <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801613:	01 c3                	add    %eax,%ebx
  801615:	39 f3                	cmp    %esi,%ebx
  801617:	72 d9                	jb     8015f2 <readn+0x16>
  801619:	89 d8                	mov    %ebx,%eax
  80161b:	eb 02                	jmp    80161f <readn+0x43>
  80161d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80161f:	83 c4 1c             	add    $0x1c,%esp
  801622:	5b                   	pop    %ebx
  801623:	5e                   	pop    %esi
  801624:	5f                   	pop    %edi
  801625:	5d                   	pop    %ebp
  801626:	c3                   	ret    

00801627 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801627:	55                   	push   %ebp
  801628:	89 e5                	mov    %esp,%ebp
  80162a:	53                   	push   %ebx
  80162b:	83 ec 24             	sub    $0x24,%esp
  80162e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801631:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801634:	89 44 24 04          	mov    %eax,0x4(%esp)
  801638:	89 1c 24             	mov    %ebx,(%esp)
  80163b:	e8 76 fc ff ff       	call   8012b6 <fd_lookup>
  801640:	89 c2                	mov    %eax,%edx
  801642:	85 d2                	test   %edx,%edx
  801644:	78 68                	js     8016ae <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801646:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801649:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801650:	8b 00                	mov    (%eax),%eax
  801652:	89 04 24             	mov    %eax,(%esp)
  801655:	e8 b2 fc ff ff       	call   80130c <dev_lookup>
  80165a:	85 c0                	test   %eax,%eax
  80165c:	78 50                	js     8016ae <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80165e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801661:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801665:	75 23                	jne    80168a <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801667:	a1 08 40 80 00       	mov    0x804008,%eax
  80166c:	8b 40 48             	mov    0x48(%eax),%eax
  80166f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801673:	89 44 24 04          	mov    %eax,0x4(%esp)
  801677:	c7 04 24 61 2e 80 00 	movl   $0x802e61,(%esp)
  80167e:	e8 40 eb ff ff       	call   8001c3 <cprintf>
		return -E_INVAL;
  801683:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801688:	eb 24                	jmp    8016ae <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80168a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80168d:	8b 52 0c             	mov    0xc(%edx),%edx
  801690:	85 d2                	test   %edx,%edx
  801692:	74 15                	je     8016a9 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801694:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801697:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80169b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80169e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016a2:	89 04 24             	mov    %eax,(%esp)
  8016a5:	ff d2                	call   *%edx
  8016a7:	eb 05                	jmp    8016ae <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016a9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8016ae:	83 c4 24             	add    $0x24,%esp
  8016b1:	5b                   	pop    %ebx
  8016b2:	5d                   	pop    %ebp
  8016b3:	c3                   	ret    

008016b4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016ba:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c4:	89 04 24             	mov    %eax,(%esp)
  8016c7:	e8 ea fb ff ff       	call   8012b6 <fd_lookup>
  8016cc:	85 c0                	test   %eax,%eax
  8016ce:	78 0e                	js     8016de <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8016d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016d6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016de:	c9                   	leave  
  8016df:	c3                   	ret    

008016e0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	53                   	push   %ebx
  8016e4:	83 ec 24             	sub    $0x24,%esp
  8016e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f1:	89 1c 24             	mov    %ebx,(%esp)
  8016f4:	e8 bd fb ff ff       	call   8012b6 <fd_lookup>
  8016f9:	89 c2                	mov    %eax,%edx
  8016fb:	85 d2                	test   %edx,%edx
  8016fd:	78 61                	js     801760 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801702:	89 44 24 04          	mov    %eax,0x4(%esp)
  801706:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801709:	8b 00                	mov    (%eax),%eax
  80170b:	89 04 24             	mov    %eax,(%esp)
  80170e:	e8 f9 fb ff ff       	call   80130c <dev_lookup>
  801713:	85 c0                	test   %eax,%eax
  801715:	78 49                	js     801760 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801717:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80171a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80171e:	75 23                	jne    801743 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801720:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801725:	8b 40 48             	mov    0x48(%eax),%eax
  801728:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80172c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801730:	c7 04 24 24 2e 80 00 	movl   $0x802e24,(%esp)
  801737:	e8 87 ea ff ff       	call   8001c3 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80173c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801741:	eb 1d                	jmp    801760 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801743:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801746:	8b 52 18             	mov    0x18(%edx),%edx
  801749:	85 d2                	test   %edx,%edx
  80174b:	74 0e                	je     80175b <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80174d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801750:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801754:	89 04 24             	mov    %eax,(%esp)
  801757:	ff d2                	call   *%edx
  801759:	eb 05                	jmp    801760 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80175b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801760:	83 c4 24             	add    $0x24,%esp
  801763:	5b                   	pop    %ebx
  801764:	5d                   	pop    %ebp
  801765:	c3                   	ret    

00801766 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801766:	55                   	push   %ebp
  801767:	89 e5                	mov    %esp,%ebp
  801769:	53                   	push   %ebx
  80176a:	83 ec 24             	sub    $0x24,%esp
  80176d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801770:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801773:	89 44 24 04          	mov    %eax,0x4(%esp)
  801777:	8b 45 08             	mov    0x8(%ebp),%eax
  80177a:	89 04 24             	mov    %eax,(%esp)
  80177d:	e8 34 fb ff ff       	call   8012b6 <fd_lookup>
  801782:	89 c2                	mov    %eax,%edx
  801784:	85 d2                	test   %edx,%edx
  801786:	78 52                	js     8017da <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801788:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80178b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801792:	8b 00                	mov    (%eax),%eax
  801794:	89 04 24             	mov    %eax,(%esp)
  801797:	e8 70 fb ff ff       	call   80130c <dev_lookup>
  80179c:	85 c0                	test   %eax,%eax
  80179e:	78 3a                	js     8017da <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8017a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017a7:	74 2c                	je     8017d5 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017a9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017ac:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017b3:	00 00 00 
	stat->st_isdir = 0;
  8017b6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017bd:	00 00 00 
	stat->st_dev = dev;
  8017c0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017ca:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017cd:	89 14 24             	mov    %edx,(%esp)
  8017d0:	ff 50 14             	call   *0x14(%eax)
  8017d3:	eb 05                	jmp    8017da <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017d5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017da:	83 c4 24             	add    $0x24,%esp
  8017dd:	5b                   	pop    %ebx
  8017de:	5d                   	pop    %ebp
  8017df:	c3                   	ret    

008017e0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	56                   	push   %esi
  8017e4:	53                   	push   %ebx
  8017e5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017e8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017ef:	00 
  8017f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f3:	89 04 24             	mov    %eax,(%esp)
  8017f6:	e8 28 02 00 00       	call   801a23 <open>
  8017fb:	89 c3                	mov    %eax,%ebx
  8017fd:	85 db                	test   %ebx,%ebx
  8017ff:	78 1b                	js     80181c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801801:	8b 45 0c             	mov    0xc(%ebp),%eax
  801804:	89 44 24 04          	mov    %eax,0x4(%esp)
  801808:	89 1c 24             	mov    %ebx,(%esp)
  80180b:	e8 56 ff ff ff       	call   801766 <fstat>
  801810:	89 c6                	mov    %eax,%esi
	close(fd);
  801812:	89 1c 24             	mov    %ebx,(%esp)
  801815:	e8 cd fb ff ff       	call   8013e7 <close>
	return r;
  80181a:	89 f0                	mov    %esi,%eax
}
  80181c:	83 c4 10             	add    $0x10,%esp
  80181f:	5b                   	pop    %ebx
  801820:	5e                   	pop    %esi
  801821:	5d                   	pop    %ebp
  801822:	c3                   	ret    

00801823 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	56                   	push   %esi
  801827:	53                   	push   %ebx
  801828:	83 ec 10             	sub    $0x10,%esp
  80182b:	89 c6                	mov    %eax,%esi
  80182d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80182f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801836:	75 11                	jne    801849 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801838:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80183f:	e8 61 0e 00 00       	call   8026a5 <ipc_find_env>
  801844:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801849:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801850:	00 
  801851:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801858:	00 
  801859:	89 74 24 04          	mov    %esi,0x4(%esp)
  80185d:	a1 00 40 80 00       	mov    0x804000,%eax
  801862:	89 04 24             	mov    %eax,(%esp)
  801865:	e8 d0 0d 00 00       	call   80263a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80186a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801871:	00 
  801872:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801876:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80187d:	e8 3e 0d 00 00       	call   8025c0 <ipc_recv>
}
  801882:	83 c4 10             	add    $0x10,%esp
  801885:	5b                   	pop    %ebx
  801886:	5e                   	pop    %esi
  801887:	5d                   	pop    %ebp
  801888:	c3                   	ret    

00801889 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801889:	55                   	push   %ebp
  80188a:	89 e5                	mov    %esp,%ebp
  80188c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80188f:	8b 45 08             	mov    0x8(%ebp),%eax
  801892:	8b 40 0c             	mov    0xc(%eax),%eax
  801895:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80189a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80189d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a7:	b8 02 00 00 00       	mov    $0x2,%eax
  8018ac:	e8 72 ff ff ff       	call   801823 <fsipc>
}
  8018b1:	c9                   	leave  
  8018b2:	c3                   	ret    

008018b3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8018bf:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c9:	b8 06 00 00 00       	mov    $0x6,%eax
  8018ce:	e8 50 ff ff ff       	call   801823 <fsipc>
}
  8018d3:	c9                   	leave  
  8018d4:	c3                   	ret    

008018d5 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018d5:	55                   	push   %ebp
  8018d6:	89 e5                	mov    %esp,%ebp
  8018d8:	53                   	push   %ebx
  8018d9:	83 ec 14             	sub    $0x14,%esp
  8018dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018df:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ef:	b8 05 00 00 00       	mov    $0x5,%eax
  8018f4:	e8 2a ff ff ff       	call   801823 <fsipc>
  8018f9:	89 c2                	mov    %eax,%edx
  8018fb:	85 d2                	test   %edx,%edx
  8018fd:	78 2b                	js     80192a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018ff:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801906:	00 
  801907:	89 1c 24             	mov    %ebx,(%esp)
  80190a:	e8 d8 ee ff ff       	call   8007e7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80190f:	a1 80 50 80 00       	mov    0x805080,%eax
  801914:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80191a:	a1 84 50 80 00       	mov    0x805084,%eax
  80191f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801925:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80192a:	83 c4 14             	add    $0x14,%esp
  80192d:	5b                   	pop    %ebx
  80192e:	5d                   	pop    %ebp
  80192f:	c3                   	ret    

00801930 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	83 ec 18             	sub    $0x18,%esp
  801936:	8b 45 10             	mov    0x10(%ebp),%eax
  801939:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80193e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801943:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801946:	8b 55 08             	mov    0x8(%ebp),%edx
  801949:	8b 52 0c             	mov    0xc(%edx),%edx
  80194c:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801952:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801957:	89 44 24 08          	mov    %eax,0x8(%esp)
  80195b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80195e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801962:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801969:	e8 16 f0 ff ff       	call   800984 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  80196e:	ba 00 00 00 00       	mov    $0x0,%edx
  801973:	b8 04 00 00 00       	mov    $0x4,%eax
  801978:	e8 a6 fe ff ff       	call   801823 <fsipc>
}
  80197d:	c9                   	leave  
  80197e:	c3                   	ret    

0080197f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80197f:	55                   	push   %ebp
  801980:	89 e5                	mov    %esp,%ebp
  801982:	56                   	push   %esi
  801983:	53                   	push   %ebx
  801984:	83 ec 10             	sub    $0x10,%esp
  801987:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80198a:	8b 45 08             	mov    0x8(%ebp),%eax
  80198d:	8b 40 0c             	mov    0xc(%eax),%eax
  801990:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801995:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80199b:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a0:	b8 03 00 00 00       	mov    $0x3,%eax
  8019a5:	e8 79 fe ff ff       	call   801823 <fsipc>
  8019aa:	89 c3                	mov    %eax,%ebx
  8019ac:	85 c0                	test   %eax,%eax
  8019ae:	78 6a                	js     801a1a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8019b0:	39 c6                	cmp    %eax,%esi
  8019b2:	73 24                	jae    8019d8 <devfile_read+0x59>
  8019b4:	c7 44 24 0c 94 2e 80 	movl   $0x802e94,0xc(%esp)
  8019bb:	00 
  8019bc:	c7 44 24 08 9b 2e 80 	movl   $0x802e9b,0x8(%esp)
  8019c3:	00 
  8019c4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8019cb:	00 
  8019cc:	c7 04 24 b0 2e 80 00 	movl   $0x802eb0,(%esp)
  8019d3:	e8 1e 0b 00 00       	call   8024f6 <_panic>
	assert(r <= PGSIZE);
  8019d8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019dd:	7e 24                	jle    801a03 <devfile_read+0x84>
  8019df:	c7 44 24 0c bb 2e 80 	movl   $0x802ebb,0xc(%esp)
  8019e6:	00 
  8019e7:	c7 44 24 08 9b 2e 80 	movl   $0x802e9b,0x8(%esp)
  8019ee:	00 
  8019ef:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8019f6:	00 
  8019f7:	c7 04 24 b0 2e 80 00 	movl   $0x802eb0,(%esp)
  8019fe:	e8 f3 0a 00 00       	call   8024f6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a03:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a07:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a0e:	00 
  801a0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a12:	89 04 24             	mov    %eax,(%esp)
  801a15:	e8 6a ef ff ff       	call   800984 <memmove>
	return r;
}
  801a1a:	89 d8                	mov    %ebx,%eax
  801a1c:	83 c4 10             	add    $0x10,%esp
  801a1f:	5b                   	pop    %ebx
  801a20:	5e                   	pop    %esi
  801a21:	5d                   	pop    %ebp
  801a22:	c3                   	ret    

00801a23 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a23:	55                   	push   %ebp
  801a24:	89 e5                	mov    %esp,%ebp
  801a26:	53                   	push   %ebx
  801a27:	83 ec 24             	sub    $0x24,%esp
  801a2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a2d:	89 1c 24             	mov    %ebx,(%esp)
  801a30:	e8 7b ed ff ff       	call   8007b0 <strlen>
  801a35:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a3a:	7f 60                	jg     801a9c <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a3c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a3f:	89 04 24             	mov    %eax,(%esp)
  801a42:	e8 20 f8 ff ff       	call   801267 <fd_alloc>
  801a47:	89 c2                	mov    %eax,%edx
  801a49:	85 d2                	test   %edx,%edx
  801a4b:	78 54                	js     801aa1 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a4d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a51:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a58:	e8 8a ed ff ff       	call   8007e7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a60:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a65:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a68:	b8 01 00 00 00       	mov    $0x1,%eax
  801a6d:	e8 b1 fd ff ff       	call   801823 <fsipc>
  801a72:	89 c3                	mov    %eax,%ebx
  801a74:	85 c0                	test   %eax,%eax
  801a76:	79 17                	jns    801a8f <open+0x6c>
		fd_close(fd, 0);
  801a78:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a7f:	00 
  801a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a83:	89 04 24             	mov    %eax,(%esp)
  801a86:	e8 db f8 ff ff       	call   801366 <fd_close>
		return r;
  801a8b:	89 d8                	mov    %ebx,%eax
  801a8d:	eb 12                	jmp    801aa1 <open+0x7e>
	}

	return fd2num(fd);
  801a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a92:	89 04 24             	mov    %eax,(%esp)
  801a95:	e8 a6 f7 ff ff       	call   801240 <fd2num>
  801a9a:	eb 05                	jmp    801aa1 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a9c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801aa1:	83 c4 24             	add    $0x24,%esp
  801aa4:	5b                   	pop    %ebx
  801aa5:	5d                   	pop    %ebp
  801aa6:	c3                   	ret    

00801aa7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801aa7:	55                   	push   %ebp
  801aa8:	89 e5                	mov    %esp,%ebp
  801aaa:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801aad:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab2:	b8 08 00 00 00       	mov    $0x8,%eax
  801ab7:	e8 67 fd ff ff       	call   801823 <fsipc>
}
  801abc:	c9                   	leave  
  801abd:	c3                   	ret    
  801abe:	66 90                	xchg   %ax,%ax

00801ac0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801ac6:	c7 44 24 04 c7 2e 80 	movl   $0x802ec7,0x4(%esp)
  801acd:	00 
  801ace:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ad1:	89 04 24             	mov    %eax,(%esp)
  801ad4:	e8 0e ed ff ff       	call   8007e7 <strcpy>
	return 0;
}
  801ad9:	b8 00 00 00 00       	mov    $0x0,%eax
  801ade:	c9                   	leave  
  801adf:	c3                   	ret    

00801ae0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	53                   	push   %ebx
  801ae4:	83 ec 14             	sub    $0x14,%esp
  801ae7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801aea:	89 1c 24             	mov    %ebx,(%esp)
  801aed:	e8 eb 0b 00 00       	call   8026dd <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801af2:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801af7:	83 f8 01             	cmp    $0x1,%eax
  801afa:	75 0d                	jne    801b09 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801afc:	8b 43 0c             	mov    0xc(%ebx),%eax
  801aff:	89 04 24             	mov    %eax,(%esp)
  801b02:	e8 29 03 00 00       	call   801e30 <nsipc_close>
  801b07:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  801b09:	89 d0                	mov    %edx,%eax
  801b0b:	83 c4 14             	add    $0x14,%esp
  801b0e:	5b                   	pop    %ebx
  801b0f:	5d                   	pop    %ebp
  801b10:	c3                   	ret    

00801b11 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b11:	55                   	push   %ebp
  801b12:	89 e5                	mov    %esp,%ebp
  801b14:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b17:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801b1e:	00 
  801b1f:	8b 45 10             	mov    0x10(%ebp),%eax
  801b22:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b26:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b29:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b30:	8b 40 0c             	mov    0xc(%eax),%eax
  801b33:	89 04 24             	mov    %eax,(%esp)
  801b36:	e8 f0 03 00 00       	call   801f2b <nsipc_send>
}
  801b3b:	c9                   	leave  
  801b3c:	c3                   	ret    

00801b3d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b43:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801b4a:	00 
  801b4b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b4e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b52:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b55:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b59:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5c:	8b 40 0c             	mov    0xc(%eax),%eax
  801b5f:	89 04 24             	mov    %eax,(%esp)
  801b62:	e8 44 03 00 00       	call   801eab <nsipc_recv>
}
  801b67:	c9                   	leave  
  801b68:	c3                   	ret    

00801b69 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b6f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b72:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b76:	89 04 24             	mov    %eax,(%esp)
  801b79:	e8 38 f7 ff ff       	call   8012b6 <fd_lookup>
  801b7e:	85 c0                	test   %eax,%eax
  801b80:	78 17                	js     801b99 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b85:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801b8b:	39 08                	cmp    %ecx,(%eax)
  801b8d:	75 05                	jne    801b94 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b8f:	8b 40 0c             	mov    0xc(%eax),%eax
  801b92:	eb 05                	jmp    801b99 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b94:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b99:	c9                   	leave  
  801b9a:	c3                   	ret    

00801b9b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	56                   	push   %esi
  801b9f:	53                   	push   %ebx
  801ba0:	83 ec 20             	sub    $0x20,%esp
  801ba3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801ba5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba8:	89 04 24             	mov    %eax,(%esp)
  801bab:	e8 b7 f6 ff ff       	call   801267 <fd_alloc>
  801bb0:	89 c3                	mov    %eax,%ebx
  801bb2:	85 c0                	test   %eax,%eax
  801bb4:	78 21                	js     801bd7 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801bb6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bbd:	00 
  801bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bcc:	e8 32 f0 ff ff       	call   800c03 <sys_page_alloc>
  801bd1:	89 c3                	mov    %eax,%ebx
  801bd3:	85 c0                	test   %eax,%eax
  801bd5:	79 0c                	jns    801be3 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  801bd7:	89 34 24             	mov    %esi,(%esp)
  801bda:	e8 51 02 00 00       	call   801e30 <nsipc_close>
		return r;
  801bdf:	89 d8                	mov    %ebx,%eax
  801be1:	eb 20                	jmp    801c03 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801be3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bec:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801bee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bf1:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801bf8:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801bfb:	89 14 24             	mov    %edx,(%esp)
  801bfe:	e8 3d f6 ff ff       	call   801240 <fd2num>
}
  801c03:	83 c4 20             	add    $0x20,%esp
  801c06:	5b                   	pop    %ebx
  801c07:	5e                   	pop    %esi
  801c08:	5d                   	pop    %ebp
  801c09:	c3                   	ret    

00801c0a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
  801c0d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c10:	8b 45 08             	mov    0x8(%ebp),%eax
  801c13:	e8 51 ff ff ff       	call   801b69 <fd2sockid>
		return r;
  801c18:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c1a:	85 c0                	test   %eax,%eax
  801c1c:	78 23                	js     801c41 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c1e:	8b 55 10             	mov    0x10(%ebp),%edx
  801c21:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c25:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c28:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c2c:	89 04 24             	mov    %eax,(%esp)
  801c2f:	e8 45 01 00 00       	call   801d79 <nsipc_accept>
		return r;
  801c34:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c36:	85 c0                	test   %eax,%eax
  801c38:	78 07                	js     801c41 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  801c3a:	e8 5c ff ff ff       	call   801b9b <alloc_sockfd>
  801c3f:	89 c1                	mov    %eax,%ecx
}
  801c41:	89 c8                	mov    %ecx,%eax
  801c43:	c9                   	leave  
  801c44:	c3                   	ret    

00801c45 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c45:	55                   	push   %ebp
  801c46:	89 e5                	mov    %esp,%ebp
  801c48:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4e:	e8 16 ff ff ff       	call   801b69 <fd2sockid>
  801c53:	89 c2                	mov    %eax,%edx
  801c55:	85 d2                	test   %edx,%edx
  801c57:	78 16                	js     801c6f <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  801c59:	8b 45 10             	mov    0x10(%ebp),%eax
  801c5c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c63:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c67:	89 14 24             	mov    %edx,(%esp)
  801c6a:	e8 60 01 00 00       	call   801dcf <nsipc_bind>
}
  801c6f:	c9                   	leave  
  801c70:	c3                   	ret    

00801c71 <shutdown>:

int
shutdown(int s, int how)
{
  801c71:	55                   	push   %ebp
  801c72:	89 e5                	mov    %esp,%ebp
  801c74:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c77:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7a:	e8 ea fe ff ff       	call   801b69 <fd2sockid>
  801c7f:	89 c2                	mov    %eax,%edx
  801c81:	85 d2                	test   %edx,%edx
  801c83:	78 0f                	js     801c94 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801c85:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c88:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c8c:	89 14 24             	mov    %edx,(%esp)
  801c8f:	e8 7a 01 00 00       	call   801e0e <nsipc_shutdown>
}
  801c94:	c9                   	leave  
  801c95:	c3                   	ret    

00801c96 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c96:	55                   	push   %ebp
  801c97:	89 e5                	mov    %esp,%ebp
  801c99:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9f:	e8 c5 fe ff ff       	call   801b69 <fd2sockid>
  801ca4:	89 c2                	mov    %eax,%edx
  801ca6:	85 d2                	test   %edx,%edx
  801ca8:	78 16                	js     801cc0 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  801caa:	8b 45 10             	mov    0x10(%ebp),%eax
  801cad:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cb1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cb8:	89 14 24             	mov    %edx,(%esp)
  801cbb:	e8 8a 01 00 00       	call   801e4a <nsipc_connect>
}
  801cc0:	c9                   	leave  
  801cc1:	c3                   	ret    

00801cc2 <listen>:

int
listen(int s, int backlog)
{
  801cc2:	55                   	push   %ebp
  801cc3:	89 e5                	mov    %esp,%ebp
  801cc5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccb:	e8 99 fe ff ff       	call   801b69 <fd2sockid>
  801cd0:	89 c2                	mov    %eax,%edx
  801cd2:	85 d2                	test   %edx,%edx
  801cd4:	78 0f                	js     801ce5 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801cd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cdd:	89 14 24             	mov    %edx,(%esp)
  801ce0:	e8 a4 01 00 00       	call   801e89 <nsipc_listen>
}
  801ce5:	c9                   	leave  
  801ce6:	c3                   	ret    

00801ce7 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801ce7:	55                   	push   %ebp
  801ce8:	89 e5                	mov    %esp,%ebp
  801cea:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801ced:	8b 45 10             	mov    0x10(%ebp),%eax
  801cf0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cf4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfe:	89 04 24             	mov    %eax,(%esp)
  801d01:	e8 98 02 00 00       	call   801f9e <nsipc_socket>
  801d06:	89 c2                	mov    %eax,%edx
  801d08:	85 d2                	test   %edx,%edx
  801d0a:	78 05                	js     801d11 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  801d0c:	e8 8a fe ff ff       	call   801b9b <alloc_sockfd>
}
  801d11:	c9                   	leave  
  801d12:	c3                   	ret    

00801d13 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	53                   	push   %ebx
  801d17:	83 ec 14             	sub    $0x14,%esp
  801d1a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d1c:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801d23:	75 11                	jne    801d36 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d25:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801d2c:	e8 74 09 00 00       	call   8026a5 <ipc_find_env>
  801d31:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d36:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d3d:	00 
  801d3e:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801d45:	00 
  801d46:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d4a:	a1 04 40 80 00       	mov    0x804004,%eax
  801d4f:	89 04 24             	mov    %eax,(%esp)
  801d52:	e8 e3 08 00 00       	call   80263a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d57:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d5e:	00 
  801d5f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d66:	00 
  801d67:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d6e:	e8 4d 08 00 00       	call   8025c0 <ipc_recv>
}
  801d73:	83 c4 14             	add    $0x14,%esp
  801d76:	5b                   	pop    %ebx
  801d77:	5d                   	pop    %ebp
  801d78:	c3                   	ret    

00801d79 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d79:	55                   	push   %ebp
  801d7a:	89 e5                	mov    %esp,%ebp
  801d7c:	56                   	push   %esi
  801d7d:	53                   	push   %ebx
  801d7e:	83 ec 10             	sub    $0x10,%esp
  801d81:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d84:	8b 45 08             	mov    0x8(%ebp),%eax
  801d87:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d8c:	8b 06                	mov    (%esi),%eax
  801d8e:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d93:	b8 01 00 00 00       	mov    $0x1,%eax
  801d98:	e8 76 ff ff ff       	call   801d13 <nsipc>
  801d9d:	89 c3                	mov    %eax,%ebx
  801d9f:	85 c0                	test   %eax,%eax
  801da1:	78 23                	js     801dc6 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801da3:	a1 10 60 80 00       	mov    0x806010,%eax
  801da8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dac:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801db3:	00 
  801db4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801db7:	89 04 24             	mov    %eax,(%esp)
  801dba:	e8 c5 eb ff ff       	call   800984 <memmove>
		*addrlen = ret->ret_addrlen;
  801dbf:	a1 10 60 80 00       	mov    0x806010,%eax
  801dc4:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801dc6:	89 d8                	mov    %ebx,%eax
  801dc8:	83 c4 10             	add    $0x10,%esp
  801dcb:	5b                   	pop    %ebx
  801dcc:	5e                   	pop    %esi
  801dcd:	5d                   	pop    %ebp
  801dce:	c3                   	ret    

00801dcf <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801dcf:	55                   	push   %ebp
  801dd0:	89 e5                	mov    %esp,%ebp
  801dd2:	53                   	push   %ebx
  801dd3:	83 ec 14             	sub    $0x14,%esp
  801dd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddc:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801de1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801de5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dec:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801df3:	e8 8c eb ff ff       	call   800984 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801df8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801dfe:	b8 02 00 00 00       	mov    $0x2,%eax
  801e03:	e8 0b ff ff ff       	call   801d13 <nsipc>
}
  801e08:	83 c4 14             	add    $0x14,%esp
  801e0b:	5b                   	pop    %ebx
  801e0c:	5d                   	pop    %ebp
  801e0d:	c3                   	ret    

00801e0e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e0e:	55                   	push   %ebp
  801e0f:	89 e5                	mov    %esp,%ebp
  801e11:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e14:	8b 45 08             	mov    0x8(%ebp),%eax
  801e17:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e1f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e24:	b8 03 00 00 00       	mov    $0x3,%eax
  801e29:	e8 e5 fe ff ff       	call   801d13 <nsipc>
}
  801e2e:	c9                   	leave  
  801e2f:	c3                   	ret    

00801e30 <nsipc_close>:

int
nsipc_close(int s)
{
  801e30:	55                   	push   %ebp
  801e31:	89 e5                	mov    %esp,%ebp
  801e33:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e36:	8b 45 08             	mov    0x8(%ebp),%eax
  801e39:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801e3e:	b8 04 00 00 00       	mov    $0x4,%eax
  801e43:	e8 cb fe ff ff       	call   801d13 <nsipc>
}
  801e48:	c9                   	leave  
  801e49:	c3                   	ret    

00801e4a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e4a:	55                   	push   %ebp
  801e4b:	89 e5                	mov    %esp,%ebp
  801e4d:	53                   	push   %ebx
  801e4e:	83 ec 14             	sub    $0x14,%esp
  801e51:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801e54:	8b 45 08             	mov    0x8(%ebp),%eax
  801e57:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801e5c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e63:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e67:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801e6e:	e8 11 eb ff ff       	call   800984 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e73:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801e79:	b8 05 00 00 00       	mov    $0x5,%eax
  801e7e:	e8 90 fe ff ff       	call   801d13 <nsipc>
}
  801e83:	83 c4 14             	add    $0x14,%esp
  801e86:	5b                   	pop    %ebx
  801e87:	5d                   	pop    %ebp
  801e88:	c3                   	ret    

00801e89 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e89:	55                   	push   %ebp
  801e8a:	89 e5                	mov    %esp,%ebp
  801e8c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e92:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801e97:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e9a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801e9f:	b8 06 00 00 00       	mov    $0x6,%eax
  801ea4:	e8 6a fe ff ff       	call   801d13 <nsipc>
}
  801ea9:	c9                   	leave  
  801eaa:	c3                   	ret    

00801eab <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801eab:	55                   	push   %ebp
  801eac:	89 e5                	mov    %esp,%ebp
  801eae:	56                   	push   %esi
  801eaf:	53                   	push   %ebx
  801eb0:	83 ec 10             	sub    $0x10,%esp
  801eb3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801eb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801ebe:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801ec4:	8b 45 14             	mov    0x14(%ebp),%eax
  801ec7:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ecc:	b8 07 00 00 00       	mov    $0x7,%eax
  801ed1:	e8 3d fe ff ff       	call   801d13 <nsipc>
  801ed6:	89 c3                	mov    %eax,%ebx
  801ed8:	85 c0                	test   %eax,%eax
  801eda:	78 46                	js     801f22 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801edc:	39 f0                	cmp    %esi,%eax
  801ede:	7f 07                	jg     801ee7 <nsipc_recv+0x3c>
  801ee0:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801ee5:	7e 24                	jle    801f0b <nsipc_recv+0x60>
  801ee7:	c7 44 24 0c d3 2e 80 	movl   $0x802ed3,0xc(%esp)
  801eee:	00 
  801eef:	c7 44 24 08 9b 2e 80 	movl   $0x802e9b,0x8(%esp)
  801ef6:	00 
  801ef7:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801efe:	00 
  801eff:	c7 04 24 e8 2e 80 00 	movl   $0x802ee8,(%esp)
  801f06:	e8 eb 05 00 00       	call   8024f6 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f0b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f0f:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801f16:	00 
  801f17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f1a:	89 04 24             	mov    %eax,(%esp)
  801f1d:	e8 62 ea ff ff       	call   800984 <memmove>
	}

	return r;
}
  801f22:	89 d8                	mov    %ebx,%eax
  801f24:	83 c4 10             	add    $0x10,%esp
  801f27:	5b                   	pop    %ebx
  801f28:	5e                   	pop    %esi
  801f29:	5d                   	pop    %ebp
  801f2a:	c3                   	ret    

00801f2b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f2b:	55                   	push   %ebp
  801f2c:	89 e5                	mov    %esp,%ebp
  801f2e:	53                   	push   %ebx
  801f2f:	83 ec 14             	sub    $0x14,%esp
  801f32:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801f35:	8b 45 08             	mov    0x8(%ebp),%eax
  801f38:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801f3d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801f43:	7e 24                	jle    801f69 <nsipc_send+0x3e>
  801f45:	c7 44 24 0c f4 2e 80 	movl   $0x802ef4,0xc(%esp)
  801f4c:	00 
  801f4d:	c7 44 24 08 9b 2e 80 	movl   $0x802e9b,0x8(%esp)
  801f54:	00 
  801f55:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801f5c:	00 
  801f5d:	c7 04 24 e8 2e 80 00 	movl   $0x802ee8,(%esp)
  801f64:	e8 8d 05 00 00       	call   8024f6 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801f69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f70:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f74:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801f7b:	e8 04 ea ff ff       	call   800984 <memmove>
	nsipcbuf.send.req_size = size;
  801f80:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801f86:	8b 45 14             	mov    0x14(%ebp),%eax
  801f89:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801f8e:	b8 08 00 00 00       	mov    $0x8,%eax
  801f93:	e8 7b fd ff ff       	call   801d13 <nsipc>
}
  801f98:	83 c4 14             	add    $0x14,%esp
  801f9b:	5b                   	pop    %ebx
  801f9c:	5d                   	pop    %ebp
  801f9d:	c3                   	ret    

00801f9e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f9e:	55                   	push   %ebp
  801f9f:	89 e5                	mov    %esp,%ebp
  801fa1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801fa4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801fac:	8b 45 0c             	mov    0xc(%ebp),%eax
  801faf:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801fb4:	8b 45 10             	mov    0x10(%ebp),%eax
  801fb7:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801fbc:	b8 09 00 00 00       	mov    $0x9,%eax
  801fc1:	e8 4d fd ff ff       	call   801d13 <nsipc>
}
  801fc6:	c9                   	leave  
  801fc7:	c3                   	ret    

00801fc8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
  801fcb:	56                   	push   %esi
  801fcc:	53                   	push   %ebx
  801fcd:	83 ec 10             	sub    $0x10,%esp
  801fd0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801fd3:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd6:	89 04 24             	mov    %eax,(%esp)
  801fd9:	e8 72 f2 ff ff       	call   801250 <fd2data>
  801fde:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801fe0:	c7 44 24 04 00 2f 80 	movl   $0x802f00,0x4(%esp)
  801fe7:	00 
  801fe8:	89 1c 24             	mov    %ebx,(%esp)
  801feb:	e8 f7 e7 ff ff       	call   8007e7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ff0:	8b 46 04             	mov    0x4(%esi),%eax
  801ff3:	2b 06                	sub    (%esi),%eax
  801ff5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ffb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802002:	00 00 00 
	stat->st_dev = &devpipe;
  802005:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80200c:	30 80 00 
	return 0;
}
  80200f:	b8 00 00 00 00       	mov    $0x0,%eax
  802014:	83 c4 10             	add    $0x10,%esp
  802017:	5b                   	pop    %ebx
  802018:	5e                   	pop    %esi
  802019:	5d                   	pop    %ebp
  80201a:	c3                   	ret    

0080201b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80201b:	55                   	push   %ebp
  80201c:	89 e5                	mov    %esp,%ebp
  80201e:	53                   	push   %ebx
  80201f:	83 ec 14             	sub    $0x14,%esp
  802022:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802025:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802029:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802030:	e8 75 ec ff ff       	call   800caa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802035:	89 1c 24             	mov    %ebx,(%esp)
  802038:	e8 13 f2 ff ff       	call   801250 <fd2data>
  80203d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802041:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802048:	e8 5d ec ff ff       	call   800caa <sys_page_unmap>
}
  80204d:	83 c4 14             	add    $0x14,%esp
  802050:	5b                   	pop    %ebx
  802051:	5d                   	pop    %ebp
  802052:	c3                   	ret    

00802053 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802053:	55                   	push   %ebp
  802054:	89 e5                	mov    %esp,%ebp
  802056:	57                   	push   %edi
  802057:	56                   	push   %esi
  802058:	53                   	push   %ebx
  802059:	83 ec 2c             	sub    $0x2c,%esp
  80205c:	89 c6                	mov    %eax,%esi
  80205e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802061:	a1 08 40 80 00       	mov    0x804008,%eax
  802066:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802069:	89 34 24             	mov    %esi,(%esp)
  80206c:	e8 6c 06 00 00       	call   8026dd <pageref>
  802071:	89 c7                	mov    %eax,%edi
  802073:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802076:	89 04 24             	mov    %eax,(%esp)
  802079:	e8 5f 06 00 00       	call   8026dd <pageref>
  80207e:	39 c7                	cmp    %eax,%edi
  802080:	0f 94 c2             	sete   %dl
  802083:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  802086:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  80208c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  80208f:	39 fb                	cmp    %edi,%ebx
  802091:	74 21                	je     8020b4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802093:	84 d2                	test   %dl,%dl
  802095:	74 ca                	je     802061 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802097:	8b 51 58             	mov    0x58(%ecx),%edx
  80209a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80209e:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020a2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020a6:	c7 04 24 07 2f 80 00 	movl   $0x802f07,(%esp)
  8020ad:	e8 11 e1 ff ff       	call   8001c3 <cprintf>
  8020b2:	eb ad                	jmp    802061 <_pipeisclosed+0xe>
	}
}
  8020b4:	83 c4 2c             	add    $0x2c,%esp
  8020b7:	5b                   	pop    %ebx
  8020b8:	5e                   	pop    %esi
  8020b9:	5f                   	pop    %edi
  8020ba:	5d                   	pop    %ebp
  8020bb:	c3                   	ret    

008020bc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020bc:	55                   	push   %ebp
  8020bd:	89 e5                	mov    %esp,%ebp
  8020bf:	57                   	push   %edi
  8020c0:	56                   	push   %esi
  8020c1:	53                   	push   %ebx
  8020c2:	83 ec 1c             	sub    $0x1c,%esp
  8020c5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8020c8:	89 34 24             	mov    %esi,(%esp)
  8020cb:	e8 80 f1 ff ff       	call   801250 <fd2data>
  8020d0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020d2:	bf 00 00 00 00       	mov    $0x0,%edi
  8020d7:	eb 45                	jmp    80211e <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8020d9:	89 da                	mov    %ebx,%edx
  8020db:	89 f0                	mov    %esi,%eax
  8020dd:	e8 71 ff ff ff       	call   802053 <_pipeisclosed>
  8020e2:	85 c0                	test   %eax,%eax
  8020e4:	75 41                	jne    802127 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8020e6:	e8 f9 ea ff ff       	call   800be4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8020eb:	8b 43 04             	mov    0x4(%ebx),%eax
  8020ee:	8b 0b                	mov    (%ebx),%ecx
  8020f0:	8d 51 20             	lea    0x20(%ecx),%edx
  8020f3:	39 d0                	cmp    %edx,%eax
  8020f5:	73 e2                	jae    8020d9 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8020f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020fa:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8020fe:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802101:	99                   	cltd   
  802102:	c1 ea 1b             	shr    $0x1b,%edx
  802105:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802108:	83 e1 1f             	and    $0x1f,%ecx
  80210b:	29 d1                	sub    %edx,%ecx
  80210d:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  802111:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  802115:	83 c0 01             	add    $0x1,%eax
  802118:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80211b:	83 c7 01             	add    $0x1,%edi
  80211e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802121:	75 c8                	jne    8020eb <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802123:	89 f8                	mov    %edi,%eax
  802125:	eb 05                	jmp    80212c <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802127:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80212c:	83 c4 1c             	add    $0x1c,%esp
  80212f:	5b                   	pop    %ebx
  802130:	5e                   	pop    %esi
  802131:	5f                   	pop    %edi
  802132:	5d                   	pop    %ebp
  802133:	c3                   	ret    

00802134 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802134:	55                   	push   %ebp
  802135:	89 e5                	mov    %esp,%ebp
  802137:	57                   	push   %edi
  802138:	56                   	push   %esi
  802139:	53                   	push   %ebx
  80213a:	83 ec 1c             	sub    $0x1c,%esp
  80213d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802140:	89 3c 24             	mov    %edi,(%esp)
  802143:	e8 08 f1 ff ff       	call   801250 <fd2data>
  802148:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80214a:	be 00 00 00 00       	mov    $0x0,%esi
  80214f:	eb 3d                	jmp    80218e <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802151:	85 f6                	test   %esi,%esi
  802153:	74 04                	je     802159 <devpipe_read+0x25>
				return i;
  802155:	89 f0                	mov    %esi,%eax
  802157:	eb 43                	jmp    80219c <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802159:	89 da                	mov    %ebx,%edx
  80215b:	89 f8                	mov    %edi,%eax
  80215d:	e8 f1 fe ff ff       	call   802053 <_pipeisclosed>
  802162:	85 c0                	test   %eax,%eax
  802164:	75 31                	jne    802197 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802166:	e8 79 ea ff ff       	call   800be4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80216b:	8b 03                	mov    (%ebx),%eax
  80216d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802170:	74 df                	je     802151 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802172:	99                   	cltd   
  802173:	c1 ea 1b             	shr    $0x1b,%edx
  802176:	01 d0                	add    %edx,%eax
  802178:	83 e0 1f             	and    $0x1f,%eax
  80217b:	29 d0                	sub    %edx,%eax
  80217d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802182:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802185:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802188:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80218b:	83 c6 01             	add    $0x1,%esi
  80218e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802191:	75 d8                	jne    80216b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802193:	89 f0                	mov    %esi,%eax
  802195:	eb 05                	jmp    80219c <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802197:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80219c:	83 c4 1c             	add    $0x1c,%esp
  80219f:	5b                   	pop    %ebx
  8021a0:	5e                   	pop    %esi
  8021a1:	5f                   	pop    %edi
  8021a2:	5d                   	pop    %ebp
  8021a3:	c3                   	ret    

008021a4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8021a4:	55                   	push   %ebp
  8021a5:	89 e5                	mov    %esp,%ebp
  8021a7:	56                   	push   %esi
  8021a8:	53                   	push   %ebx
  8021a9:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8021ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021af:	89 04 24             	mov    %eax,(%esp)
  8021b2:	e8 b0 f0 ff ff       	call   801267 <fd_alloc>
  8021b7:	89 c2                	mov    %eax,%edx
  8021b9:	85 d2                	test   %edx,%edx
  8021bb:	0f 88 4d 01 00 00    	js     80230e <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021c1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021c8:	00 
  8021c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021d7:	e8 27 ea ff ff       	call   800c03 <sys_page_alloc>
  8021dc:	89 c2                	mov    %eax,%edx
  8021de:	85 d2                	test   %edx,%edx
  8021e0:	0f 88 28 01 00 00    	js     80230e <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8021e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021e9:	89 04 24             	mov    %eax,(%esp)
  8021ec:	e8 76 f0 ff ff       	call   801267 <fd_alloc>
  8021f1:	89 c3                	mov    %eax,%ebx
  8021f3:	85 c0                	test   %eax,%eax
  8021f5:	0f 88 fe 00 00 00    	js     8022f9 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021fb:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802202:	00 
  802203:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802206:	89 44 24 04          	mov    %eax,0x4(%esp)
  80220a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802211:	e8 ed e9 ff ff       	call   800c03 <sys_page_alloc>
  802216:	89 c3                	mov    %eax,%ebx
  802218:	85 c0                	test   %eax,%eax
  80221a:	0f 88 d9 00 00 00    	js     8022f9 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802220:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802223:	89 04 24             	mov    %eax,(%esp)
  802226:	e8 25 f0 ff ff       	call   801250 <fd2data>
  80222b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80222d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802234:	00 
  802235:	89 44 24 04          	mov    %eax,0x4(%esp)
  802239:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802240:	e8 be e9 ff ff       	call   800c03 <sys_page_alloc>
  802245:	89 c3                	mov    %eax,%ebx
  802247:	85 c0                	test   %eax,%eax
  802249:	0f 88 97 00 00 00    	js     8022e6 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80224f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802252:	89 04 24             	mov    %eax,(%esp)
  802255:	e8 f6 ef ff ff       	call   801250 <fd2data>
  80225a:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802261:	00 
  802262:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802266:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80226d:	00 
  80226e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802272:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802279:	e8 d9 e9 ff ff       	call   800c57 <sys_page_map>
  80227e:	89 c3                	mov    %eax,%ebx
  802280:	85 c0                	test   %eax,%eax
  802282:	78 52                	js     8022d6 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802284:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80228a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80228d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80228f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802292:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802299:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80229f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022a2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8022a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022a7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8022ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b1:	89 04 24             	mov    %eax,(%esp)
  8022b4:	e8 87 ef ff ff       	call   801240 <fd2num>
  8022b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022bc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8022be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022c1:	89 04 24             	mov    %eax,(%esp)
  8022c4:	e8 77 ef ff ff       	call   801240 <fd2num>
  8022c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022cc:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8022cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8022d4:	eb 38                	jmp    80230e <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  8022d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022e1:	e8 c4 e9 ff ff       	call   800caa <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8022e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022f4:	e8 b1 e9 ff ff       	call   800caa <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8022f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  802300:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802307:	e8 9e e9 ff ff       	call   800caa <sys_page_unmap>
  80230c:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  80230e:	83 c4 30             	add    $0x30,%esp
  802311:	5b                   	pop    %ebx
  802312:	5e                   	pop    %esi
  802313:	5d                   	pop    %ebp
  802314:	c3                   	ret    

00802315 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802315:	55                   	push   %ebp
  802316:	89 e5                	mov    %esp,%ebp
  802318:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80231b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80231e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802322:	8b 45 08             	mov    0x8(%ebp),%eax
  802325:	89 04 24             	mov    %eax,(%esp)
  802328:	e8 89 ef ff ff       	call   8012b6 <fd_lookup>
  80232d:	89 c2                	mov    %eax,%edx
  80232f:	85 d2                	test   %edx,%edx
  802331:	78 15                	js     802348 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802333:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802336:	89 04 24             	mov    %eax,(%esp)
  802339:	e8 12 ef ff ff       	call   801250 <fd2data>
	return _pipeisclosed(fd, p);
  80233e:	89 c2                	mov    %eax,%edx
  802340:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802343:	e8 0b fd ff ff       	call   802053 <_pipeisclosed>
}
  802348:	c9                   	leave  
  802349:	c3                   	ret    
  80234a:	66 90                	xchg   %ax,%ax
  80234c:	66 90                	xchg   %ax,%ax
  80234e:	66 90                	xchg   %ax,%ax

00802350 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802350:	55                   	push   %ebp
  802351:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802353:	b8 00 00 00 00       	mov    $0x0,%eax
  802358:	5d                   	pop    %ebp
  802359:	c3                   	ret    

0080235a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80235a:	55                   	push   %ebp
  80235b:	89 e5                	mov    %esp,%ebp
  80235d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802360:	c7 44 24 04 1f 2f 80 	movl   $0x802f1f,0x4(%esp)
  802367:	00 
  802368:	8b 45 0c             	mov    0xc(%ebp),%eax
  80236b:	89 04 24             	mov    %eax,(%esp)
  80236e:	e8 74 e4 ff ff       	call   8007e7 <strcpy>
	return 0;
}
  802373:	b8 00 00 00 00       	mov    $0x0,%eax
  802378:	c9                   	leave  
  802379:	c3                   	ret    

0080237a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80237a:	55                   	push   %ebp
  80237b:	89 e5                	mov    %esp,%ebp
  80237d:	57                   	push   %edi
  80237e:	56                   	push   %esi
  80237f:	53                   	push   %ebx
  802380:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802386:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80238b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802391:	eb 31                	jmp    8023c4 <devcons_write+0x4a>
		m = n - tot;
  802393:	8b 75 10             	mov    0x10(%ebp),%esi
  802396:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802398:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80239b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8023a0:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023a3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8023a7:	03 45 0c             	add    0xc(%ebp),%eax
  8023aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023ae:	89 3c 24             	mov    %edi,(%esp)
  8023b1:	e8 ce e5 ff ff       	call   800984 <memmove>
		sys_cputs(buf, m);
  8023b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023ba:	89 3c 24             	mov    %edi,(%esp)
  8023bd:	e8 74 e7 ff ff       	call   800b36 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023c2:	01 f3                	add    %esi,%ebx
  8023c4:	89 d8                	mov    %ebx,%eax
  8023c6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8023c9:	72 c8                	jb     802393 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8023cb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8023d1:	5b                   	pop    %ebx
  8023d2:	5e                   	pop    %esi
  8023d3:	5f                   	pop    %edi
  8023d4:	5d                   	pop    %ebp
  8023d5:	c3                   	ret    

008023d6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8023d6:	55                   	push   %ebp
  8023d7:	89 e5                	mov    %esp,%ebp
  8023d9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8023dc:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8023e1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023e5:	75 07                	jne    8023ee <devcons_read+0x18>
  8023e7:	eb 2a                	jmp    802413 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8023e9:	e8 f6 e7 ff ff       	call   800be4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8023ee:	66 90                	xchg   %ax,%ax
  8023f0:	e8 5f e7 ff ff       	call   800b54 <sys_cgetc>
  8023f5:	85 c0                	test   %eax,%eax
  8023f7:	74 f0                	je     8023e9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8023f9:	85 c0                	test   %eax,%eax
  8023fb:	78 16                	js     802413 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8023fd:	83 f8 04             	cmp    $0x4,%eax
  802400:	74 0c                	je     80240e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802402:	8b 55 0c             	mov    0xc(%ebp),%edx
  802405:	88 02                	mov    %al,(%edx)
	return 1;
  802407:	b8 01 00 00 00       	mov    $0x1,%eax
  80240c:	eb 05                	jmp    802413 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80240e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802413:	c9                   	leave  
  802414:	c3                   	ret    

00802415 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802415:	55                   	push   %ebp
  802416:	89 e5                	mov    %esp,%ebp
  802418:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80241b:	8b 45 08             	mov    0x8(%ebp),%eax
  80241e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802421:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802428:	00 
  802429:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80242c:	89 04 24             	mov    %eax,(%esp)
  80242f:	e8 02 e7 ff ff       	call   800b36 <sys_cputs>
}
  802434:	c9                   	leave  
  802435:	c3                   	ret    

00802436 <getchar>:

int
getchar(void)
{
  802436:	55                   	push   %ebp
  802437:	89 e5                	mov    %esp,%ebp
  802439:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80243c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802443:	00 
  802444:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802447:	89 44 24 04          	mov    %eax,0x4(%esp)
  80244b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802452:	e8 f3 f0 ff ff       	call   80154a <read>
	if (r < 0)
  802457:	85 c0                	test   %eax,%eax
  802459:	78 0f                	js     80246a <getchar+0x34>
		return r;
	if (r < 1)
  80245b:	85 c0                	test   %eax,%eax
  80245d:	7e 06                	jle    802465 <getchar+0x2f>
		return -E_EOF;
	return c;
  80245f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802463:	eb 05                	jmp    80246a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802465:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80246a:	c9                   	leave  
  80246b:	c3                   	ret    

0080246c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80246c:	55                   	push   %ebp
  80246d:	89 e5                	mov    %esp,%ebp
  80246f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802472:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802475:	89 44 24 04          	mov    %eax,0x4(%esp)
  802479:	8b 45 08             	mov    0x8(%ebp),%eax
  80247c:	89 04 24             	mov    %eax,(%esp)
  80247f:	e8 32 ee ff ff       	call   8012b6 <fd_lookup>
  802484:	85 c0                	test   %eax,%eax
  802486:	78 11                	js     802499 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802488:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80248b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802491:	39 10                	cmp    %edx,(%eax)
  802493:	0f 94 c0             	sete   %al
  802496:	0f b6 c0             	movzbl %al,%eax
}
  802499:	c9                   	leave  
  80249a:	c3                   	ret    

0080249b <opencons>:

int
opencons(void)
{
  80249b:	55                   	push   %ebp
  80249c:	89 e5                	mov    %esp,%ebp
  80249e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024a4:	89 04 24             	mov    %eax,(%esp)
  8024a7:	e8 bb ed ff ff       	call   801267 <fd_alloc>
		return r;
  8024ac:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024ae:	85 c0                	test   %eax,%eax
  8024b0:	78 40                	js     8024f2 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024b2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8024b9:	00 
  8024ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024c8:	e8 36 e7 ff ff       	call   800c03 <sys_page_alloc>
		return r;
  8024cd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024cf:	85 c0                	test   %eax,%eax
  8024d1:	78 1f                	js     8024f2 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8024d3:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8024d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024dc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8024de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024e1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8024e8:	89 04 24             	mov    %eax,(%esp)
  8024eb:	e8 50 ed ff ff       	call   801240 <fd2num>
  8024f0:	89 c2                	mov    %eax,%edx
}
  8024f2:	89 d0                	mov    %edx,%eax
  8024f4:	c9                   	leave  
  8024f5:	c3                   	ret    

008024f6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8024f6:	55                   	push   %ebp
  8024f7:	89 e5                	mov    %esp,%ebp
  8024f9:	56                   	push   %esi
  8024fa:	53                   	push   %ebx
  8024fb:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8024fe:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802501:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802507:	e8 b9 e6 ff ff       	call   800bc5 <sys_getenvid>
  80250c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80250f:	89 54 24 10          	mov    %edx,0x10(%esp)
  802513:	8b 55 08             	mov    0x8(%ebp),%edx
  802516:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80251a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80251e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802522:	c7 04 24 2c 2f 80 00 	movl   $0x802f2c,(%esp)
  802529:	e8 95 dc ff ff       	call   8001c3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80252e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802532:	8b 45 10             	mov    0x10(%ebp),%eax
  802535:	89 04 24             	mov    %eax,(%esp)
  802538:	e8 25 dc ff ff       	call   800162 <vcprintf>
	cprintf("\n");
  80253d:	c7 04 24 54 2a 80 00 	movl   $0x802a54,(%esp)
  802544:	e8 7a dc ff ff       	call   8001c3 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802549:	cc                   	int3   
  80254a:	eb fd                	jmp    802549 <_panic+0x53>

0080254c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80254c:	55                   	push   %ebp
  80254d:	89 e5                	mov    %esp,%ebp
  80254f:	53                   	push   %ebx
  802550:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  802553:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80255a:	75 2f                	jne    80258b <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  80255c:	e8 64 e6 ff ff       	call   800bc5 <sys_getenvid>
  802561:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P);
  802563:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80256a:	00 
  80256b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802572:	ee 
  802573:	89 04 24             	mov    %eax,(%esp)
  802576:	e8 88 e6 ff ff       	call   800c03 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *)_pgfault_upcall);
  80257b:	c7 44 24 04 99 25 80 	movl   $0x802599,0x4(%esp)
  802582:	00 
  802583:	89 1c 24             	mov    %ebx,(%esp)
  802586:	e8 18 e8 ff ff       	call   800da3 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80258b:	8b 45 08             	mov    0x8(%ebp),%eax
  80258e:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802593:	83 c4 14             	add    $0x14,%esp
  802596:	5b                   	pop    %ebx
  802597:	5d                   	pop    %ebp
  802598:	c3                   	ret    

00802599 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802599:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80259a:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80259f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8025a1:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	// 0x30(%esp) points to trap-time stack pointer
	// 0x28(%esp) points to trap-time eip
	subl $4, 0x30(%esp)
  8025a4:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax 
  8025a9:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebp
  8025ad:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %ebp, (%eax)
  8025b1:	89 28                	mov    %ebp,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8025b3:	83 c4 08             	add    $0x8,%esp
	popal
  8025b6:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp //pop eip - we already stored it
  8025b7:	83 c4 04             	add    $0x4,%esp
	popfl
  8025ba:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8025bb:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8025bc:	c3                   	ret    
  8025bd:	66 90                	xchg   %ax,%ax
  8025bf:	90                   	nop

008025c0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8025c0:	55                   	push   %ebp
  8025c1:	89 e5                	mov    %esp,%ebp
  8025c3:	56                   	push   %esi
  8025c4:	53                   	push   %ebx
  8025c5:	83 ec 10             	sub    $0x10,%esp
  8025c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8025cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  8025d1:	85 c0                	test   %eax,%eax
  8025d3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8025d8:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  8025db:	89 04 24             	mov    %eax,(%esp)
  8025de:	e8 36 e8 ff ff       	call   800e19 <sys_ipc_recv>

	if(ret < 0) {
  8025e3:	85 c0                	test   %eax,%eax
  8025e5:	79 16                	jns    8025fd <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  8025e7:	85 f6                	test   %esi,%esi
  8025e9:	74 06                	je     8025f1 <ipc_recv+0x31>
  8025eb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  8025f1:	85 db                	test   %ebx,%ebx
  8025f3:	74 3e                	je     802633 <ipc_recv+0x73>
  8025f5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8025fb:	eb 36                	jmp    802633 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  8025fd:	e8 c3 e5 ff ff       	call   800bc5 <sys_getenvid>
  802602:	25 ff 03 00 00       	and    $0x3ff,%eax
  802607:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80260a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80260f:	a3 08 40 80 00       	mov    %eax,0x804008

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802614:	85 f6                	test   %esi,%esi
  802616:	74 05                	je     80261d <ipc_recv+0x5d>
  802618:	8b 40 74             	mov    0x74(%eax),%eax
  80261b:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80261d:	85 db                	test   %ebx,%ebx
  80261f:	74 0a                	je     80262b <ipc_recv+0x6b>
  802621:	a1 08 40 80 00       	mov    0x804008,%eax
  802626:	8b 40 78             	mov    0x78(%eax),%eax
  802629:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  80262b:	a1 08 40 80 00       	mov    0x804008,%eax
  802630:	8b 40 70             	mov    0x70(%eax),%eax
}
  802633:	83 c4 10             	add    $0x10,%esp
  802636:	5b                   	pop    %ebx
  802637:	5e                   	pop    %esi
  802638:	5d                   	pop    %ebp
  802639:	c3                   	ret    

0080263a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80263a:	55                   	push   %ebp
  80263b:	89 e5                	mov    %esp,%ebp
  80263d:	57                   	push   %edi
  80263e:	56                   	push   %esi
  80263f:	53                   	push   %ebx
  802640:	83 ec 1c             	sub    $0x1c,%esp
  802643:	8b 7d 08             	mov    0x8(%ebp),%edi
  802646:	8b 75 0c             	mov    0xc(%ebp),%esi
  802649:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  80264c:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  80264e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802653:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  802656:	8b 45 14             	mov    0x14(%ebp),%eax
  802659:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80265d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802661:	89 74 24 04          	mov    %esi,0x4(%esp)
  802665:	89 3c 24             	mov    %edi,(%esp)
  802668:	e8 89 e7 ff ff       	call   800df6 <sys_ipc_try_send>

		if(ret >= 0) break;
  80266d:	85 c0                	test   %eax,%eax
  80266f:	79 2c                	jns    80269d <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  802671:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802674:	74 20                	je     802696 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  802676:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80267a:	c7 44 24 08 50 2f 80 	movl   $0x802f50,0x8(%esp)
  802681:	00 
  802682:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  802689:	00 
  80268a:	c7 04 24 80 2f 80 00 	movl   $0x802f80,(%esp)
  802691:	e8 60 fe ff ff       	call   8024f6 <_panic>
		}
		sys_yield();
  802696:	e8 49 e5 ff ff       	call   800be4 <sys_yield>
	}
  80269b:	eb b9                	jmp    802656 <ipc_send+0x1c>
}
  80269d:	83 c4 1c             	add    $0x1c,%esp
  8026a0:	5b                   	pop    %ebx
  8026a1:	5e                   	pop    %esi
  8026a2:	5f                   	pop    %edi
  8026a3:	5d                   	pop    %ebp
  8026a4:	c3                   	ret    

008026a5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8026a5:	55                   	push   %ebp
  8026a6:	89 e5                	mov    %esp,%ebp
  8026a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8026ab:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8026b0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8026b3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8026b9:	8b 52 50             	mov    0x50(%edx),%edx
  8026bc:	39 ca                	cmp    %ecx,%edx
  8026be:	75 0d                	jne    8026cd <ipc_find_env+0x28>
			return envs[i].env_id;
  8026c0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8026c3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8026c8:	8b 40 40             	mov    0x40(%eax),%eax
  8026cb:	eb 0e                	jmp    8026db <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8026cd:	83 c0 01             	add    $0x1,%eax
  8026d0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8026d5:	75 d9                	jne    8026b0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8026d7:	66 b8 00 00          	mov    $0x0,%ax
}
  8026db:	5d                   	pop    %ebp
  8026dc:	c3                   	ret    

008026dd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8026dd:	55                   	push   %ebp
  8026de:	89 e5                	mov    %esp,%ebp
  8026e0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026e3:	89 d0                	mov    %edx,%eax
  8026e5:	c1 e8 16             	shr    $0x16,%eax
  8026e8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8026ef:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026f4:	f6 c1 01             	test   $0x1,%cl
  8026f7:	74 1d                	je     802716 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8026f9:	c1 ea 0c             	shr    $0xc,%edx
  8026fc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802703:	f6 c2 01             	test   $0x1,%dl
  802706:	74 0e                	je     802716 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802708:	c1 ea 0c             	shr    $0xc,%edx
  80270b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802712:	ef 
  802713:	0f b7 c0             	movzwl %ax,%eax
}
  802716:	5d                   	pop    %ebp
  802717:	c3                   	ret    
  802718:	66 90                	xchg   %ax,%ax
  80271a:	66 90                	xchg   %ax,%ax
  80271c:	66 90                	xchg   %ax,%ax
  80271e:	66 90                	xchg   %ax,%ax

00802720 <__udivdi3>:
  802720:	55                   	push   %ebp
  802721:	57                   	push   %edi
  802722:	56                   	push   %esi
  802723:	83 ec 0c             	sub    $0xc,%esp
  802726:	8b 44 24 28          	mov    0x28(%esp),%eax
  80272a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80272e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802732:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802736:	85 c0                	test   %eax,%eax
  802738:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80273c:	89 ea                	mov    %ebp,%edx
  80273e:	89 0c 24             	mov    %ecx,(%esp)
  802741:	75 2d                	jne    802770 <__udivdi3+0x50>
  802743:	39 e9                	cmp    %ebp,%ecx
  802745:	77 61                	ja     8027a8 <__udivdi3+0x88>
  802747:	85 c9                	test   %ecx,%ecx
  802749:	89 ce                	mov    %ecx,%esi
  80274b:	75 0b                	jne    802758 <__udivdi3+0x38>
  80274d:	b8 01 00 00 00       	mov    $0x1,%eax
  802752:	31 d2                	xor    %edx,%edx
  802754:	f7 f1                	div    %ecx
  802756:	89 c6                	mov    %eax,%esi
  802758:	31 d2                	xor    %edx,%edx
  80275a:	89 e8                	mov    %ebp,%eax
  80275c:	f7 f6                	div    %esi
  80275e:	89 c5                	mov    %eax,%ebp
  802760:	89 f8                	mov    %edi,%eax
  802762:	f7 f6                	div    %esi
  802764:	89 ea                	mov    %ebp,%edx
  802766:	83 c4 0c             	add    $0xc,%esp
  802769:	5e                   	pop    %esi
  80276a:	5f                   	pop    %edi
  80276b:	5d                   	pop    %ebp
  80276c:	c3                   	ret    
  80276d:	8d 76 00             	lea    0x0(%esi),%esi
  802770:	39 e8                	cmp    %ebp,%eax
  802772:	77 24                	ja     802798 <__udivdi3+0x78>
  802774:	0f bd e8             	bsr    %eax,%ebp
  802777:	83 f5 1f             	xor    $0x1f,%ebp
  80277a:	75 3c                	jne    8027b8 <__udivdi3+0x98>
  80277c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802780:	39 34 24             	cmp    %esi,(%esp)
  802783:	0f 86 9f 00 00 00    	jbe    802828 <__udivdi3+0x108>
  802789:	39 d0                	cmp    %edx,%eax
  80278b:	0f 82 97 00 00 00    	jb     802828 <__udivdi3+0x108>
  802791:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802798:	31 d2                	xor    %edx,%edx
  80279a:	31 c0                	xor    %eax,%eax
  80279c:	83 c4 0c             	add    $0xc,%esp
  80279f:	5e                   	pop    %esi
  8027a0:	5f                   	pop    %edi
  8027a1:	5d                   	pop    %ebp
  8027a2:	c3                   	ret    
  8027a3:	90                   	nop
  8027a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027a8:	89 f8                	mov    %edi,%eax
  8027aa:	f7 f1                	div    %ecx
  8027ac:	31 d2                	xor    %edx,%edx
  8027ae:	83 c4 0c             	add    $0xc,%esp
  8027b1:	5e                   	pop    %esi
  8027b2:	5f                   	pop    %edi
  8027b3:	5d                   	pop    %ebp
  8027b4:	c3                   	ret    
  8027b5:	8d 76 00             	lea    0x0(%esi),%esi
  8027b8:	89 e9                	mov    %ebp,%ecx
  8027ba:	8b 3c 24             	mov    (%esp),%edi
  8027bd:	d3 e0                	shl    %cl,%eax
  8027bf:	89 c6                	mov    %eax,%esi
  8027c1:	b8 20 00 00 00       	mov    $0x20,%eax
  8027c6:	29 e8                	sub    %ebp,%eax
  8027c8:	89 c1                	mov    %eax,%ecx
  8027ca:	d3 ef                	shr    %cl,%edi
  8027cc:	89 e9                	mov    %ebp,%ecx
  8027ce:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8027d2:	8b 3c 24             	mov    (%esp),%edi
  8027d5:	09 74 24 08          	or     %esi,0x8(%esp)
  8027d9:	89 d6                	mov    %edx,%esi
  8027db:	d3 e7                	shl    %cl,%edi
  8027dd:	89 c1                	mov    %eax,%ecx
  8027df:	89 3c 24             	mov    %edi,(%esp)
  8027e2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8027e6:	d3 ee                	shr    %cl,%esi
  8027e8:	89 e9                	mov    %ebp,%ecx
  8027ea:	d3 e2                	shl    %cl,%edx
  8027ec:	89 c1                	mov    %eax,%ecx
  8027ee:	d3 ef                	shr    %cl,%edi
  8027f0:	09 d7                	or     %edx,%edi
  8027f2:	89 f2                	mov    %esi,%edx
  8027f4:	89 f8                	mov    %edi,%eax
  8027f6:	f7 74 24 08          	divl   0x8(%esp)
  8027fa:	89 d6                	mov    %edx,%esi
  8027fc:	89 c7                	mov    %eax,%edi
  8027fe:	f7 24 24             	mull   (%esp)
  802801:	39 d6                	cmp    %edx,%esi
  802803:	89 14 24             	mov    %edx,(%esp)
  802806:	72 30                	jb     802838 <__udivdi3+0x118>
  802808:	8b 54 24 04          	mov    0x4(%esp),%edx
  80280c:	89 e9                	mov    %ebp,%ecx
  80280e:	d3 e2                	shl    %cl,%edx
  802810:	39 c2                	cmp    %eax,%edx
  802812:	73 05                	jae    802819 <__udivdi3+0xf9>
  802814:	3b 34 24             	cmp    (%esp),%esi
  802817:	74 1f                	je     802838 <__udivdi3+0x118>
  802819:	89 f8                	mov    %edi,%eax
  80281b:	31 d2                	xor    %edx,%edx
  80281d:	e9 7a ff ff ff       	jmp    80279c <__udivdi3+0x7c>
  802822:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802828:	31 d2                	xor    %edx,%edx
  80282a:	b8 01 00 00 00       	mov    $0x1,%eax
  80282f:	e9 68 ff ff ff       	jmp    80279c <__udivdi3+0x7c>
  802834:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802838:	8d 47 ff             	lea    -0x1(%edi),%eax
  80283b:	31 d2                	xor    %edx,%edx
  80283d:	83 c4 0c             	add    $0xc,%esp
  802840:	5e                   	pop    %esi
  802841:	5f                   	pop    %edi
  802842:	5d                   	pop    %ebp
  802843:	c3                   	ret    
  802844:	66 90                	xchg   %ax,%ax
  802846:	66 90                	xchg   %ax,%ax
  802848:	66 90                	xchg   %ax,%ax
  80284a:	66 90                	xchg   %ax,%ax
  80284c:	66 90                	xchg   %ax,%ax
  80284e:	66 90                	xchg   %ax,%ax

00802850 <__umoddi3>:
  802850:	55                   	push   %ebp
  802851:	57                   	push   %edi
  802852:	56                   	push   %esi
  802853:	83 ec 14             	sub    $0x14,%esp
  802856:	8b 44 24 28          	mov    0x28(%esp),%eax
  80285a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80285e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802862:	89 c7                	mov    %eax,%edi
  802864:	89 44 24 04          	mov    %eax,0x4(%esp)
  802868:	8b 44 24 30          	mov    0x30(%esp),%eax
  80286c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802870:	89 34 24             	mov    %esi,(%esp)
  802873:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802877:	85 c0                	test   %eax,%eax
  802879:	89 c2                	mov    %eax,%edx
  80287b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80287f:	75 17                	jne    802898 <__umoddi3+0x48>
  802881:	39 fe                	cmp    %edi,%esi
  802883:	76 4b                	jbe    8028d0 <__umoddi3+0x80>
  802885:	89 c8                	mov    %ecx,%eax
  802887:	89 fa                	mov    %edi,%edx
  802889:	f7 f6                	div    %esi
  80288b:	89 d0                	mov    %edx,%eax
  80288d:	31 d2                	xor    %edx,%edx
  80288f:	83 c4 14             	add    $0x14,%esp
  802892:	5e                   	pop    %esi
  802893:	5f                   	pop    %edi
  802894:	5d                   	pop    %ebp
  802895:	c3                   	ret    
  802896:	66 90                	xchg   %ax,%ax
  802898:	39 f8                	cmp    %edi,%eax
  80289a:	77 54                	ja     8028f0 <__umoddi3+0xa0>
  80289c:	0f bd e8             	bsr    %eax,%ebp
  80289f:	83 f5 1f             	xor    $0x1f,%ebp
  8028a2:	75 5c                	jne    802900 <__umoddi3+0xb0>
  8028a4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8028a8:	39 3c 24             	cmp    %edi,(%esp)
  8028ab:	0f 87 e7 00 00 00    	ja     802998 <__umoddi3+0x148>
  8028b1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8028b5:	29 f1                	sub    %esi,%ecx
  8028b7:	19 c7                	sbb    %eax,%edi
  8028b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028bd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8028c1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8028c5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8028c9:	83 c4 14             	add    $0x14,%esp
  8028cc:	5e                   	pop    %esi
  8028cd:	5f                   	pop    %edi
  8028ce:	5d                   	pop    %ebp
  8028cf:	c3                   	ret    
  8028d0:	85 f6                	test   %esi,%esi
  8028d2:	89 f5                	mov    %esi,%ebp
  8028d4:	75 0b                	jne    8028e1 <__umoddi3+0x91>
  8028d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8028db:	31 d2                	xor    %edx,%edx
  8028dd:	f7 f6                	div    %esi
  8028df:	89 c5                	mov    %eax,%ebp
  8028e1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8028e5:	31 d2                	xor    %edx,%edx
  8028e7:	f7 f5                	div    %ebp
  8028e9:	89 c8                	mov    %ecx,%eax
  8028eb:	f7 f5                	div    %ebp
  8028ed:	eb 9c                	jmp    80288b <__umoddi3+0x3b>
  8028ef:	90                   	nop
  8028f0:	89 c8                	mov    %ecx,%eax
  8028f2:	89 fa                	mov    %edi,%edx
  8028f4:	83 c4 14             	add    $0x14,%esp
  8028f7:	5e                   	pop    %esi
  8028f8:	5f                   	pop    %edi
  8028f9:	5d                   	pop    %ebp
  8028fa:	c3                   	ret    
  8028fb:	90                   	nop
  8028fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802900:	8b 04 24             	mov    (%esp),%eax
  802903:	be 20 00 00 00       	mov    $0x20,%esi
  802908:	89 e9                	mov    %ebp,%ecx
  80290a:	29 ee                	sub    %ebp,%esi
  80290c:	d3 e2                	shl    %cl,%edx
  80290e:	89 f1                	mov    %esi,%ecx
  802910:	d3 e8                	shr    %cl,%eax
  802912:	89 e9                	mov    %ebp,%ecx
  802914:	89 44 24 04          	mov    %eax,0x4(%esp)
  802918:	8b 04 24             	mov    (%esp),%eax
  80291b:	09 54 24 04          	or     %edx,0x4(%esp)
  80291f:	89 fa                	mov    %edi,%edx
  802921:	d3 e0                	shl    %cl,%eax
  802923:	89 f1                	mov    %esi,%ecx
  802925:	89 44 24 08          	mov    %eax,0x8(%esp)
  802929:	8b 44 24 10          	mov    0x10(%esp),%eax
  80292d:	d3 ea                	shr    %cl,%edx
  80292f:	89 e9                	mov    %ebp,%ecx
  802931:	d3 e7                	shl    %cl,%edi
  802933:	89 f1                	mov    %esi,%ecx
  802935:	d3 e8                	shr    %cl,%eax
  802937:	89 e9                	mov    %ebp,%ecx
  802939:	09 f8                	or     %edi,%eax
  80293b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80293f:	f7 74 24 04          	divl   0x4(%esp)
  802943:	d3 e7                	shl    %cl,%edi
  802945:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802949:	89 d7                	mov    %edx,%edi
  80294b:	f7 64 24 08          	mull   0x8(%esp)
  80294f:	39 d7                	cmp    %edx,%edi
  802951:	89 c1                	mov    %eax,%ecx
  802953:	89 14 24             	mov    %edx,(%esp)
  802956:	72 2c                	jb     802984 <__umoddi3+0x134>
  802958:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80295c:	72 22                	jb     802980 <__umoddi3+0x130>
  80295e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802962:	29 c8                	sub    %ecx,%eax
  802964:	19 d7                	sbb    %edx,%edi
  802966:	89 e9                	mov    %ebp,%ecx
  802968:	89 fa                	mov    %edi,%edx
  80296a:	d3 e8                	shr    %cl,%eax
  80296c:	89 f1                	mov    %esi,%ecx
  80296e:	d3 e2                	shl    %cl,%edx
  802970:	89 e9                	mov    %ebp,%ecx
  802972:	d3 ef                	shr    %cl,%edi
  802974:	09 d0                	or     %edx,%eax
  802976:	89 fa                	mov    %edi,%edx
  802978:	83 c4 14             	add    $0x14,%esp
  80297b:	5e                   	pop    %esi
  80297c:	5f                   	pop    %edi
  80297d:	5d                   	pop    %ebp
  80297e:	c3                   	ret    
  80297f:	90                   	nop
  802980:	39 d7                	cmp    %edx,%edi
  802982:	75 da                	jne    80295e <__umoddi3+0x10e>
  802984:	8b 14 24             	mov    (%esp),%edx
  802987:	89 c1                	mov    %eax,%ecx
  802989:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80298d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802991:	eb cb                	jmp    80295e <__umoddi3+0x10e>
  802993:	90                   	nop
  802994:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802998:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80299c:	0f 82 0f ff ff ff    	jb     8028b1 <__umoddi3+0x61>
  8029a2:	e9 1a ff ff ff       	jmp    8028c1 <__umoddi3+0x71>
