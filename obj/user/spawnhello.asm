
obj/user/spawnhello.debug:     file format elf32-i386


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
  80002c:	e8 62 00 00 00       	call   800093 <libmain>
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
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  800039:	a1 08 50 80 00       	mov    0x805008,%eax
  80003e:	8b 40 48             	mov    0x48(%eax),%eax
  800041:	89 44 24 04          	mov    %eax,0x4(%esp)
  800045:	c7 04 24 60 2c 80 00 	movl   $0x802c60,(%esp)
  80004c:	e8 9c 01 00 00       	call   8001ed <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  800051:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800058:	00 
  800059:	c7 44 24 04 7e 2c 80 	movl   $0x802c7e,0x4(%esp)
  800060:	00 
  800061:	c7 04 24 7e 2c 80 00 	movl   $0x802c7e,(%esp)
  800068:	e8 4a 1d 00 00       	call   801db7 <spawnl>
  80006d:	85 c0                	test   %eax,%eax
  80006f:	79 20                	jns    800091 <umain+0x5e>
		panic("spawn(hello) failed: %e", r);
  800071:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800075:	c7 44 24 08 84 2c 80 	movl   $0x802c84,0x8(%esp)
  80007c:	00 
  80007d:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  800084:	00 
  800085:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  80008c:	e8 63 00 00 00       	call   8000f4 <_panic>
}
  800091:	c9                   	leave  
  800092:	c3                   	ret    

00800093 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800093:	55                   	push   %ebp
  800094:	89 e5                	mov    %esp,%ebp
  800096:	56                   	push   %esi
  800097:	53                   	push   %ebx
  800098:	83 ec 10             	sub    $0x10,%esp
  80009b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80009e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  8000a1:	e8 4f 0b 00 00       	call   800bf5 <sys_getenvid>
  8000a6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ab:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000ae:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b3:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b8:	85 db                	test   %ebx,%ebx
  8000ba:	7e 07                	jle    8000c3 <libmain+0x30>
		binaryname = argv[0];
  8000bc:	8b 06                	mov    (%esi),%eax
  8000be:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  8000c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000c7:	89 1c 24             	mov    %ebx,(%esp)
  8000ca:	e8 64 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000cf:	e8 07 00 00 00       	call   8000db <exit>
}
  8000d4:	83 c4 10             	add    $0x10,%esp
  8000d7:	5b                   	pop    %ebx
  8000d8:	5e                   	pop    %esi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000e1:	e8 54 10 00 00       	call   80113a <close_all>
	sys_env_destroy(0);
  8000e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ed:	e8 b1 0a 00 00       	call   800ba3 <sys_env_destroy>
}
  8000f2:	c9                   	leave  
  8000f3:	c3                   	ret    

008000f4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8000fc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8000ff:	8b 35 00 40 80 00    	mov    0x804000,%esi
  800105:	e8 eb 0a 00 00       	call   800bf5 <sys_getenvid>
  80010a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80010d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800111:	8b 55 08             	mov    0x8(%ebp),%edx
  800114:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800118:	89 74 24 08          	mov    %esi,0x8(%esp)
  80011c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800120:	c7 04 24 b8 2c 80 00 	movl   $0x802cb8,(%esp)
  800127:	e8 c1 00 00 00       	call   8001ed <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80012c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800130:	8b 45 10             	mov    0x10(%ebp),%eax
  800133:	89 04 24             	mov    %eax,(%esp)
  800136:	e8 51 00 00 00       	call   80018c <vcprintf>
	cprintf("\n");
  80013b:	c7 04 24 e7 31 80 00 	movl   $0x8031e7,(%esp)
  800142:	e8 a6 00 00 00       	call   8001ed <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800147:	cc                   	int3   
  800148:	eb fd                	jmp    800147 <_panic+0x53>

0080014a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80014a:	55                   	push   %ebp
  80014b:	89 e5                	mov    %esp,%ebp
  80014d:	53                   	push   %ebx
  80014e:	83 ec 14             	sub    $0x14,%esp
  800151:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800154:	8b 13                	mov    (%ebx),%edx
  800156:	8d 42 01             	lea    0x1(%edx),%eax
  800159:	89 03                	mov    %eax,(%ebx)
  80015b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80015e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800162:	3d ff 00 00 00       	cmp    $0xff,%eax
  800167:	75 19                	jne    800182 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800169:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800170:	00 
  800171:	8d 43 08             	lea    0x8(%ebx),%eax
  800174:	89 04 24             	mov    %eax,(%esp)
  800177:	e8 ea 09 00 00       	call   800b66 <sys_cputs>
		b->idx = 0;
  80017c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800182:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800186:	83 c4 14             	add    $0x14,%esp
  800189:	5b                   	pop    %ebx
  80018a:	5d                   	pop    %ebp
  80018b:	c3                   	ret    

0080018c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800195:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80019c:	00 00 00 
	b.cnt = 0;
  80019f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001a6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c1:	c7 04 24 4a 01 80 00 	movl   $0x80014a,(%esp)
  8001c8:	e8 b1 01 00 00       	call   80037e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001cd:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001dd:	89 04 24             	mov    %eax,(%esp)
  8001e0:	e8 81 09 00 00       	call   800b66 <sys_cputs>

	return b.cnt;
}
  8001e5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001eb:	c9                   	leave  
  8001ec:	c3                   	ret    

008001ed <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fd:	89 04 24             	mov    %eax,(%esp)
  800200:	e8 87 ff ff ff       	call   80018c <vcprintf>
	va_end(ap);

	return cnt;
}
  800205:	c9                   	leave  
  800206:	c3                   	ret    
  800207:	66 90                	xchg   %ax,%ax
  800209:	66 90                	xchg   %ax,%ax
  80020b:	66 90                	xchg   %ax,%ax
  80020d:	66 90                	xchg   %ax,%ax
  80020f:	90                   	nop

00800210 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	57                   	push   %edi
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	83 ec 3c             	sub    $0x3c,%esp
  800219:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80021c:	89 d7                	mov    %edx,%edi
  80021e:	8b 45 08             	mov    0x8(%ebp),%eax
  800221:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800224:	8b 45 0c             	mov    0xc(%ebp),%eax
  800227:	89 c3                	mov    %eax,%ebx
  800229:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80022c:	8b 45 10             	mov    0x10(%ebp),%eax
  80022f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800232:	b9 00 00 00 00       	mov    $0x0,%ecx
  800237:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80023d:	39 d9                	cmp    %ebx,%ecx
  80023f:	72 05                	jb     800246 <printnum+0x36>
  800241:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800244:	77 69                	ja     8002af <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800246:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800249:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80024d:	83 ee 01             	sub    $0x1,%esi
  800250:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800254:	89 44 24 08          	mov    %eax,0x8(%esp)
  800258:	8b 44 24 08          	mov    0x8(%esp),%eax
  80025c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800260:	89 c3                	mov    %eax,%ebx
  800262:	89 d6                	mov    %edx,%esi
  800264:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800267:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80026a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80026e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800272:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800275:	89 04 24             	mov    %eax,(%esp)
  800278:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80027b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027f:	e8 4c 27 00 00       	call   8029d0 <__udivdi3>
  800284:	89 d9                	mov    %ebx,%ecx
  800286:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80028a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80028e:	89 04 24             	mov    %eax,(%esp)
  800291:	89 54 24 04          	mov    %edx,0x4(%esp)
  800295:	89 fa                	mov    %edi,%edx
  800297:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80029a:	e8 71 ff ff ff       	call   800210 <printnum>
  80029f:	eb 1b                	jmp    8002bc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a5:	8b 45 18             	mov    0x18(%ebp),%eax
  8002a8:	89 04 24             	mov    %eax,(%esp)
  8002ab:	ff d3                	call   *%ebx
  8002ad:	eb 03                	jmp    8002b2 <printnum+0xa2>
  8002af:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b2:	83 ee 01             	sub    $0x1,%esi
  8002b5:	85 f6                	test   %esi,%esi
  8002b7:	7f e8                	jg     8002a1 <printnum+0x91>
  8002b9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002bc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002c0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002c4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002c7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d5:	89 04 24             	mov    %eax,(%esp)
  8002d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002df:	e8 1c 28 00 00       	call   802b00 <__umoddi3>
  8002e4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e8:	0f be 80 db 2c 80 00 	movsbl 0x802cdb(%eax),%eax
  8002ef:	89 04 24             	mov    %eax,(%esp)
  8002f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002f5:	ff d0                	call   *%eax
}
  8002f7:	83 c4 3c             	add    $0x3c,%esp
  8002fa:	5b                   	pop    %ebx
  8002fb:	5e                   	pop    %esi
  8002fc:	5f                   	pop    %edi
  8002fd:	5d                   	pop    %ebp
  8002fe:	c3                   	ret    

008002ff <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800302:	83 fa 01             	cmp    $0x1,%edx
  800305:	7e 0e                	jle    800315 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800307:	8b 10                	mov    (%eax),%edx
  800309:	8d 4a 08             	lea    0x8(%edx),%ecx
  80030c:	89 08                	mov    %ecx,(%eax)
  80030e:	8b 02                	mov    (%edx),%eax
  800310:	8b 52 04             	mov    0x4(%edx),%edx
  800313:	eb 22                	jmp    800337 <getuint+0x38>
	else if (lflag)
  800315:	85 d2                	test   %edx,%edx
  800317:	74 10                	je     800329 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800319:	8b 10                	mov    (%eax),%edx
  80031b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031e:	89 08                	mov    %ecx,(%eax)
  800320:	8b 02                	mov    (%edx),%eax
  800322:	ba 00 00 00 00       	mov    $0x0,%edx
  800327:	eb 0e                	jmp    800337 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800329:	8b 10                	mov    (%eax),%edx
  80032b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032e:	89 08                	mov    %ecx,(%eax)
  800330:	8b 02                	mov    (%edx),%eax
  800332:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800337:	5d                   	pop    %ebp
  800338:	c3                   	ret    

00800339 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80033f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800343:	8b 10                	mov    (%eax),%edx
  800345:	3b 50 04             	cmp    0x4(%eax),%edx
  800348:	73 0a                	jae    800354 <sprintputch+0x1b>
		*b->buf++ = ch;
  80034a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80034d:	89 08                	mov    %ecx,(%eax)
  80034f:	8b 45 08             	mov    0x8(%ebp),%eax
  800352:	88 02                	mov    %al,(%edx)
}
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    

00800356 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
  800359:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80035c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80035f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800363:	8b 45 10             	mov    0x10(%ebp),%eax
  800366:	89 44 24 08          	mov    %eax,0x8(%esp)
  80036a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80036d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800371:	8b 45 08             	mov    0x8(%ebp),%eax
  800374:	89 04 24             	mov    %eax,(%esp)
  800377:	e8 02 00 00 00       	call   80037e <vprintfmt>
	va_end(ap);
}
  80037c:	c9                   	leave  
  80037d:	c3                   	ret    

0080037e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	57                   	push   %edi
  800382:	56                   	push   %esi
  800383:	53                   	push   %ebx
  800384:	83 ec 3c             	sub    $0x3c,%esp
  800387:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80038a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80038d:	eb 14                	jmp    8003a3 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80038f:	85 c0                	test   %eax,%eax
  800391:	0f 84 b3 03 00 00    	je     80074a <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800397:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80039b:	89 04 24             	mov    %eax,(%esp)
  80039e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a1:	89 f3                	mov    %esi,%ebx
  8003a3:	8d 73 01             	lea    0x1(%ebx),%esi
  8003a6:	0f b6 03             	movzbl (%ebx),%eax
  8003a9:	83 f8 25             	cmp    $0x25,%eax
  8003ac:	75 e1                	jne    80038f <vprintfmt+0x11>
  8003ae:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003b2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003b9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003c0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8003c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003cc:	eb 1d                	jmp    8003eb <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003d0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003d4:	eb 15                	jmp    8003eb <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003d8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003dc:	eb 0d                	jmp    8003eb <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003e1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003e4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003eb:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003ee:	0f b6 0e             	movzbl (%esi),%ecx
  8003f1:	0f b6 c1             	movzbl %cl,%eax
  8003f4:	83 e9 23             	sub    $0x23,%ecx
  8003f7:	80 f9 55             	cmp    $0x55,%cl
  8003fa:	0f 87 2a 03 00 00    	ja     80072a <vprintfmt+0x3ac>
  800400:	0f b6 c9             	movzbl %cl,%ecx
  800403:	ff 24 8d 20 2e 80 00 	jmp    *0x802e20(,%ecx,4)
  80040a:	89 de                	mov    %ebx,%esi
  80040c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800411:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800414:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800418:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80041b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80041e:	83 fb 09             	cmp    $0x9,%ebx
  800421:	77 36                	ja     800459 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800423:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800426:	eb e9                	jmp    800411 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	8d 48 04             	lea    0x4(%eax),%ecx
  80042e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800431:	8b 00                	mov    (%eax),%eax
  800433:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800436:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800438:	eb 22                	jmp    80045c <vprintfmt+0xde>
  80043a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80043d:	85 c9                	test   %ecx,%ecx
  80043f:	b8 00 00 00 00       	mov    $0x0,%eax
  800444:	0f 49 c1             	cmovns %ecx,%eax
  800447:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044a:	89 de                	mov    %ebx,%esi
  80044c:	eb 9d                	jmp    8003eb <vprintfmt+0x6d>
  80044e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800450:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800457:	eb 92                	jmp    8003eb <vprintfmt+0x6d>
  800459:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80045c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800460:	79 89                	jns    8003eb <vprintfmt+0x6d>
  800462:	e9 77 ff ff ff       	jmp    8003de <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800467:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80046c:	e9 7a ff ff ff       	jmp    8003eb <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800471:	8b 45 14             	mov    0x14(%ebp),%eax
  800474:	8d 50 04             	lea    0x4(%eax),%edx
  800477:	89 55 14             	mov    %edx,0x14(%ebp)
  80047a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80047e:	8b 00                	mov    (%eax),%eax
  800480:	89 04 24             	mov    %eax,(%esp)
  800483:	ff 55 08             	call   *0x8(%ebp)
			break;
  800486:	e9 18 ff ff ff       	jmp    8003a3 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80048b:	8b 45 14             	mov    0x14(%ebp),%eax
  80048e:	8d 50 04             	lea    0x4(%eax),%edx
  800491:	89 55 14             	mov    %edx,0x14(%ebp)
  800494:	8b 00                	mov    (%eax),%eax
  800496:	99                   	cltd   
  800497:	31 d0                	xor    %edx,%eax
  800499:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049b:	83 f8 0f             	cmp    $0xf,%eax
  80049e:	7f 0b                	jg     8004ab <vprintfmt+0x12d>
  8004a0:	8b 14 85 80 2f 80 00 	mov    0x802f80(,%eax,4),%edx
  8004a7:	85 d2                	test   %edx,%edx
  8004a9:	75 20                	jne    8004cb <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  8004ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004af:	c7 44 24 08 f3 2c 80 	movl   $0x802cf3,0x8(%esp)
  8004b6:	00 
  8004b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8004be:	89 04 24             	mov    %eax,(%esp)
  8004c1:	e8 90 fe ff ff       	call   800356 <printfmt>
  8004c6:	e9 d8 fe ff ff       	jmp    8003a3 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8004cb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004cf:	c7 44 24 08 b5 30 80 	movl   $0x8030b5,0x8(%esp)
  8004d6:	00 
  8004d7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004db:	8b 45 08             	mov    0x8(%ebp),%eax
  8004de:	89 04 24             	mov    %eax,(%esp)
  8004e1:	e8 70 fe ff ff       	call   800356 <printfmt>
  8004e6:	e9 b8 fe ff ff       	jmp    8003a3 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004eb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004f1:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f7:	8d 50 04             	lea    0x4(%eax),%edx
  8004fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fd:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004ff:	85 f6                	test   %esi,%esi
  800501:	b8 ec 2c 80 00       	mov    $0x802cec,%eax
  800506:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800509:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80050d:	0f 84 97 00 00 00    	je     8005aa <vprintfmt+0x22c>
  800513:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800517:	0f 8e 9b 00 00 00    	jle    8005b8 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80051d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800521:	89 34 24             	mov    %esi,(%esp)
  800524:	e8 cf 02 00 00       	call   8007f8 <strnlen>
  800529:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80052c:	29 c2                	sub    %eax,%edx
  80052e:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800531:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800535:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800538:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80053b:	8b 75 08             	mov    0x8(%ebp),%esi
  80053e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800541:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800543:	eb 0f                	jmp    800554 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800545:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800549:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80054c:	89 04 24             	mov    %eax,(%esp)
  80054f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800551:	83 eb 01             	sub    $0x1,%ebx
  800554:	85 db                	test   %ebx,%ebx
  800556:	7f ed                	jg     800545 <vprintfmt+0x1c7>
  800558:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80055b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80055e:	85 d2                	test   %edx,%edx
  800560:	b8 00 00 00 00       	mov    $0x0,%eax
  800565:	0f 49 c2             	cmovns %edx,%eax
  800568:	29 c2                	sub    %eax,%edx
  80056a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80056d:	89 d7                	mov    %edx,%edi
  80056f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800572:	eb 50                	jmp    8005c4 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800574:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800578:	74 1e                	je     800598 <vprintfmt+0x21a>
  80057a:	0f be d2             	movsbl %dl,%edx
  80057d:	83 ea 20             	sub    $0x20,%edx
  800580:	83 fa 5e             	cmp    $0x5e,%edx
  800583:	76 13                	jbe    800598 <vprintfmt+0x21a>
					putch('?', putdat);
  800585:	8b 45 0c             	mov    0xc(%ebp),%eax
  800588:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800593:	ff 55 08             	call   *0x8(%ebp)
  800596:	eb 0d                	jmp    8005a5 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800598:	8b 55 0c             	mov    0xc(%ebp),%edx
  80059b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80059f:	89 04 24             	mov    %eax,(%esp)
  8005a2:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a5:	83 ef 01             	sub    $0x1,%edi
  8005a8:	eb 1a                	jmp    8005c4 <vprintfmt+0x246>
  8005aa:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005ad:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005b0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005b3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005b6:	eb 0c                	jmp    8005c4 <vprintfmt+0x246>
  8005b8:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005bb:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005be:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005c1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005c4:	83 c6 01             	add    $0x1,%esi
  8005c7:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  8005cb:	0f be c2             	movsbl %dl,%eax
  8005ce:	85 c0                	test   %eax,%eax
  8005d0:	74 27                	je     8005f9 <vprintfmt+0x27b>
  8005d2:	85 db                	test   %ebx,%ebx
  8005d4:	78 9e                	js     800574 <vprintfmt+0x1f6>
  8005d6:	83 eb 01             	sub    $0x1,%ebx
  8005d9:	79 99                	jns    800574 <vprintfmt+0x1f6>
  8005db:	89 f8                	mov    %edi,%eax
  8005dd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e3:	89 c3                	mov    %eax,%ebx
  8005e5:	eb 1a                	jmp    800601 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005e7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005eb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005f2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005f4:	83 eb 01             	sub    $0x1,%ebx
  8005f7:	eb 08                	jmp    800601 <vprintfmt+0x283>
  8005f9:	89 fb                	mov    %edi,%ebx
  8005fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8005fe:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800601:	85 db                	test   %ebx,%ebx
  800603:	7f e2                	jg     8005e7 <vprintfmt+0x269>
  800605:	89 75 08             	mov    %esi,0x8(%ebp)
  800608:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80060b:	e9 93 fd ff ff       	jmp    8003a3 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800610:	83 fa 01             	cmp    $0x1,%edx
  800613:	7e 16                	jle    80062b <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8d 50 08             	lea    0x8(%eax),%edx
  80061b:	89 55 14             	mov    %edx,0x14(%ebp)
  80061e:	8b 50 04             	mov    0x4(%eax),%edx
  800621:	8b 00                	mov    (%eax),%eax
  800623:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800626:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800629:	eb 32                	jmp    80065d <vprintfmt+0x2df>
	else if (lflag)
  80062b:	85 d2                	test   %edx,%edx
  80062d:	74 18                	je     800647 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8d 50 04             	lea    0x4(%eax),%edx
  800635:	89 55 14             	mov    %edx,0x14(%ebp)
  800638:	8b 30                	mov    (%eax),%esi
  80063a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80063d:	89 f0                	mov    %esi,%eax
  80063f:	c1 f8 1f             	sar    $0x1f,%eax
  800642:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800645:	eb 16                	jmp    80065d <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	8d 50 04             	lea    0x4(%eax),%edx
  80064d:	89 55 14             	mov    %edx,0x14(%ebp)
  800650:	8b 30                	mov    (%eax),%esi
  800652:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800655:	89 f0                	mov    %esi,%eax
  800657:	c1 f8 1f             	sar    $0x1f,%eax
  80065a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80065d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800660:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800663:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800668:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80066c:	0f 89 80 00 00 00    	jns    8006f2 <vprintfmt+0x374>
				putch('-', putdat);
  800672:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800676:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80067d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800680:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800683:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800686:	f7 d8                	neg    %eax
  800688:	83 d2 00             	adc    $0x0,%edx
  80068b:	f7 da                	neg    %edx
			}
			base = 10;
  80068d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800692:	eb 5e                	jmp    8006f2 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800694:	8d 45 14             	lea    0x14(%ebp),%eax
  800697:	e8 63 fc ff ff       	call   8002ff <getuint>
			base = 10;
  80069c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006a1:	eb 4f                	jmp    8006f2 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8006a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a6:	e8 54 fc ff ff       	call   8002ff <getuint>
			base = 8;
  8006ab:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006b0:	eb 40                	jmp    8006f2 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  8006b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006b6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006bd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006c4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006cb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8d 50 04             	lea    0x4(%eax),%edx
  8006d4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006d7:	8b 00                	mov    (%eax),%eax
  8006d9:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006de:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006e3:	eb 0d                	jmp    8006f2 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e8:	e8 12 fc ff ff       	call   8002ff <getuint>
			base = 16;
  8006ed:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f2:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8006f6:	89 74 24 10          	mov    %esi,0x10(%esp)
  8006fa:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006fd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800701:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800705:	89 04 24             	mov    %eax,(%esp)
  800708:	89 54 24 04          	mov    %edx,0x4(%esp)
  80070c:	89 fa                	mov    %edi,%edx
  80070e:	8b 45 08             	mov    0x8(%ebp),%eax
  800711:	e8 fa fa ff ff       	call   800210 <printnum>
			break;
  800716:	e9 88 fc ff ff       	jmp    8003a3 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80071f:	89 04 24             	mov    %eax,(%esp)
  800722:	ff 55 08             	call   *0x8(%ebp)
			break;
  800725:	e9 79 fc ff ff       	jmp    8003a3 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80072e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800735:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800738:	89 f3                	mov    %esi,%ebx
  80073a:	eb 03                	jmp    80073f <vprintfmt+0x3c1>
  80073c:	83 eb 01             	sub    $0x1,%ebx
  80073f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800743:	75 f7                	jne    80073c <vprintfmt+0x3be>
  800745:	e9 59 fc ff ff       	jmp    8003a3 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  80074a:	83 c4 3c             	add    $0x3c,%esp
  80074d:	5b                   	pop    %ebx
  80074e:	5e                   	pop    %esi
  80074f:	5f                   	pop    %edi
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	83 ec 28             	sub    $0x28,%esp
  800758:	8b 45 08             	mov    0x8(%ebp),%eax
  80075b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800761:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800765:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800768:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076f:	85 c0                	test   %eax,%eax
  800771:	74 30                	je     8007a3 <vsnprintf+0x51>
  800773:	85 d2                	test   %edx,%edx
  800775:	7e 2c                	jle    8007a3 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800777:	8b 45 14             	mov    0x14(%ebp),%eax
  80077a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80077e:	8b 45 10             	mov    0x10(%ebp),%eax
  800781:	89 44 24 08          	mov    %eax,0x8(%esp)
  800785:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800788:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078c:	c7 04 24 39 03 80 00 	movl   $0x800339,(%esp)
  800793:	e8 e6 fb ff ff       	call   80037e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800798:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a1:	eb 05                	jmp    8007a8 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007a8:	c9                   	leave  
  8007a9:	c3                   	ret    

008007aa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c8:	89 04 24             	mov    %eax,(%esp)
  8007cb:	e8 82 ff ff ff       	call   800752 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d0:	c9                   	leave  
  8007d1:	c3                   	ret    
  8007d2:	66 90                	xchg   %ax,%ax
  8007d4:	66 90                	xchg   %ax,%ax
  8007d6:	66 90                	xchg   %ax,%ax
  8007d8:	66 90                	xchg   %ax,%ax
  8007da:	66 90                	xchg   %ax,%ax
  8007dc:	66 90                	xchg   %ax,%ax
  8007de:	66 90                	xchg   %ax,%ax

008007e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007eb:	eb 03                	jmp    8007f0 <strlen+0x10>
		n++;
  8007ed:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f4:	75 f7                	jne    8007ed <strlen+0xd>
		n++;
	return n;
}
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800801:	b8 00 00 00 00       	mov    $0x0,%eax
  800806:	eb 03                	jmp    80080b <strnlen+0x13>
		n++;
  800808:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080b:	39 d0                	cmp    %edx,%eax
  80080d:	74 06                	je     800815 <strnlen+0x1d>
  80080f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800813:	75 f3                	jne    800808 <strnlen+0x10>
		n++;
	return n;
}
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	53                   	push   %ebx
  80081b:	8b 45 08             	mov    0x8(%ebp),%eax
  80081e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800821:	89 c2                	mov    %eax,%edx
  800823:	83 c2 01             	add    $0x1,%edx
  800826:	83 c1 01             	add    $0x1,%ecx
  800829:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80082d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800830:	84 db                	test   %bl,%bl
  800832:	75 ef                	jne    800823 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800834:	5b                   	pop    %ebx
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	53                   	push   %ebx
  80083b:	83 ec 08             	sub    $0x8,%esp
  80083e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800841:	89 1c 24             	mov    %ebx,(%esp)
  800844:	e8 97 ff ff ff       	call   8007e0 <strlen>
	strcpy(dst + len, src);
  800849:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800850:	01 d8                	add    %ebx,%eax
  800852:	89 04 24             	mov    %eax,(%esp)
  800855:	e8 bd ff ff ff       	call   800817 <strcpy>
	return dst;
}
  80085a:	89 d8                	mov    %ebx,%eax
  80085c:	83 c4 08             	add    $0x8,%esp
  80085f:	5b                   	pop    %ebx
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	56                   	push   %esi
  800866:	53                   	push   %ebx
  800867:	8b 75 08             	mov    0x8(%ebp),%esi
  80086a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086d:	89 f3                	mov    %esi,%ebx
  80086f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800872:	89 f2                	mov    %esi,%edx
  800874:	eb 0f                	jmp    800885 <strncpy+0x23>
		*dst++ = *src;
  800876:	83 c2 01             	add    $0x1,%edx
  800879:	0f b6 01             	movzbl (%ecx),%eax
  80087c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80087f:	80 39 01             	cmpb   $0x1,(%ecx)
  800882:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800885:	39 da                	cmp    %ebx,%edx
  800887:	75 ed                	jne    800876 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800889:	89 f0                	mov    %esi,%eax
  80088b:	5b                   	pop    %ebx
  80088c:	5e                   	pop    %esi
  80088d:	5d                   	pop    %ebp
  80088e:	c3                   	ret    

0080088f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	56                   	push   %esi
  800893:	53                   	push   %ebx
  800894:	8b 75 08             	mov    0x8(%ebp),%esi
  800897:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80089d:	89 f0                	mov    %esi,%eax
  80089f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a3:	85 c9                	test   %ecx,%ecx
  8008a5:	75 0b                	jne    8008b2 <strlcpy+0x23>
  8008a7:	eb 1d                	jmp    8008c6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a9:	83 c0 01             	add    $0x1,%eax
  8008ac:	83 c2 01             	add    $0x1,%edx
  8008af:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008b2:	39 d8                	cmp    %ebx,%eax
  8008b4:	74 0b                	je     8008c1 <strlcpy+0x32>
  8008b6:	0f b6 0a             	movzbl (%edx),%ecx
  8008b9:	84 c9                	test   %cl,%cl
  8008bb:	75 ec                	jne    8008a9 <strlcpy+0x1a>
  8008bd:	89 c2                	mov    %eax,%edx
  8008bf:	eb 02                	jmp    8008c3 <strlcpy+0x34>
  8008c1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008c3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008c6:	29 f0                	sub    %esi,%eax
}
  8008c8:	5b                   	pop    %ebx
  8008c9:	5e                   	pop    %esi
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d5:	eb 06                	jmp    8008dd <strcmp+0x11>
		p++, q++;
  8008d7:	83 c1 01             	add    $0x1,%ecx
  8008da:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008dd:	0f b6 01             	movzbl (%ecx),%eax
  8008e0:	84 c0                	test   %al,%al
  8008e2:	74 04                	je     8008e8 <strcmp+0x1c>
  8008e4:	3a 02                	cmp    (%edx),%al
  8008e6:	74 ef                	je     8008d7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e8:	0f b6 c0             	movzbl %al,%eax
  8008eb:	0f b6 12             	movzbl (%edx),%edx
  8008ee:	29 d0                	sub    %edx,%eax
}
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	53                   	push   %ebx
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fc:	89 c3                	mov    %eax,%ebx
  8008fe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800901:	eb 06                	jmp    800909 <strncmp+0x17>
		n--, p++, q++;
  800903:	83 c0 01             	add    $0x1,%eax
  800906:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800909:	39 d8                	cmp    %ebx,%eax
  80090b:	74 15                	je     800922 <strncmp+0x30>
  80090d:	0f b6 08             	movzbl (%eax),%ecx
  800910:	84 c9                	test   %cl,%cl
  800912:	74 04                	je     800918 <strncmp+0x26>
  800914:	3a 0a                	cmp    (%edx),%cl
  800916:	74 eb                	je     800903 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800918:	0f b6 00             	movzbl (%eax),%eax
  80091b:	0f b6 12             	movzbl (%edx),%edx
  80091e:	29 d0                	sub    %edx,%eax
  800920:	eb 05                	jmp    800927 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800922:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800927:	5b                   	pop    %ebx
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800934:	eb 07                	jmp    80093d <strchr+0x13>
		if (*s == c)
  800936:	38 ca                	cmp    %cl,%dl
  800938:	74 0f                	je     800949 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80093a:	83 c0 01             	add    $0x1,%eax
  80093d:	0f b6 10             	movzbl (%eax),%edx
  800940:	84 d2                	test   %dl,%dl
  800942:	75 f2                	jne    800936 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800944:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800955:	eb 07                	jmp    80095e <strfind+0x13>
		if (*s == c)
  800957:	38 ca                	cmp    %cl,%dl
  800959:	74 0a                	je     800965 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80095b:	83 c0 01             	add    $0x1,%eax
  80095e:	0f b6 10             	movzbl (%eax),%edx
  800961:	84 d2                	test   %dl,%dl
  800963:	75 f2                	jne    800957 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	57                   	push   %edi
  80096b:	56                   	push   %esi
  80096c:	53                   	push   %ebx
  80096d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800970:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800973:	85 c9                	test   %ecx,%ecx
  800975:	74 36                	je     8009ad <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800977:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80097d:	75 28                	jne    8009a7 <memset+0x40>
  80097f:	f6 c1 03             	test   $0x3,%cl
  800982:	75 23                	jne    8009a7 <memset+0x40>
		c &= 0xFF;
  800984:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800988:	89 d3                	mov    %edx,%ebx
  80098a:	c1 e3 08             	shl    $0x8,%ebx
  80098d:	89 d6                	mov    %edx,%esi
  80098f:	c1 e6 18             	shl    $0x18,%esi
  800992:	89 d0                	mov    %edx,%eax
  800994:	c1 e0 10             	shl    $0x10,%eax
  800997:	09 f0                	or     %esi,%eax
  800999:	09 c2                	or     %eax,%edx
  80099b:	89 d0                	mov    %edx,%eax
  80099d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80099f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009a2:	fc                   	cld    
  8009a3:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a5:	eb 06                	jmp    8009ad <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009aa:	fc                   	cld    
  8009ab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ad:	89 f8                	mov    %edi,%eax
  8009af:	5b                   	pop    %ebx
  8009b0:	5e                   	pop    %esi
  8009b1:	5f                   	pop    %edi
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	57                   	push   %edi
  8009b8:	56                   	push   %esi
  8009b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009c2:	39 c6                	cmp    %eax,%esi
  8009c4:	73 35                	jae    8009fb <memmove+0x47>
  8009c6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c9:	39 d0                	cmp    %edx,%eax
  8009cb:	73 2e                	jae    8009fb <memmove+0x47>
		s += n;
		d += n;
  8009cd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009d0:	89 d6                	mov    %edx,%esi
  8009d2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009da:	75 13                	jne    8009ef <memmove+0x3b>
  8009dc:	f6 c1 03             	test   $0x3,%cl
  8009df:	75 0e                	jne    8009ef <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009e1:	83 ef 04             	sub    $0x4,%edi
  8009e4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009ea:	fd                   	std    
  8009eb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ed:	eb 09                	jmp    8009f8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ef:	83 ef 01             	sub    $0x1,%edi
  8009f2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009f5:	fd                   	std    
  8009f6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009f8:	fc                   	cld    
  8009f9:	eb 1d                	jmp    800a18 <memmove+0x64>
  8009fb:	89 f2                	mov    %esi,%edx
  8009fd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ff:	f6 c2 03             	test   $0x3,%dl
  800a02:	75 0f                	jne    800a13 <memmove+0x5f>
  800a04:	f6 c1 03             	test   $0x3,%cl
  800a07:	75 0a                	jne    800a13 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a09:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a0c:	89 c7                	mov    %eax,%edi
  800a0e:	fc                   	cld    
  800a0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a11:	eb 05                	jmp    800a18 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a13:	89 c7                	mov    %eax,%edi
  800a15:	fc                   	cld    
  800a16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a18:	5e                   	pop    %esi
  800a19:	5f                   	pop    %edi
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a22:	8b 45 10             	mov    0x10(%ebp),%eax
  800a25:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a30:	8b 45 08             	mov    0x8(%ebp),%eax
  800a33:	89 04 24             	mov    %eax,(%esp)
  800a36:	e8 79 ff ff ff       	call   8009b4 <memmove>
}
  800a3b:	c9                   	leave  
  800a3c:	c3                   	ret    

00800a3d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	56                   	push   %esi
  800a41:	53                   	push   %ebx
  800a42:	8b 55 08             	mov    0x8(%ebp),%edx
  800a45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a48:	89 d6                	mov    %edx,%esi
  800a4a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4d:	eb 1a                	jmp    800a69 <memcmp+0x2c>
		if (*s1 != *s2)
  800a4f:	0f b6 02             	movzbl (%edx),%eax
  800a52:	0f b6 19             	movzbl (%ecx),%ebx
  800a55:	38 d8                	cmp    %bl,%al
  800a57:	74 0a                	je     800a63 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a59:	0f b6 c0             	movzbl %al,%eax
  800a5c:	0f b6 db             	movzbl %bl,%ebx
  800a5f:	29 d8                	sub    %ebx,%eax
  800a61:	eb 0f                	jmp    800a72 <memcmp+0x35>
		s1++, s2++;
  800a63:	83 c2 01             	add    $0x1,%edx
  800a66:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a69:	39 f2                	cmp    %esi,%edx
  800a6b:	75 e2                	jne    800a4f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a72:	5b                   	pop    %ebx
  800a73:	5e                   	pop    %esi
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a7f:	89 c2                	mov    %eax,%edx
  800a81:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a84:	eb 07                	jmp    800a8d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a86:	38 08                	cmp    %cl,(%eax)
  800a88:	74 07                	je     800a91 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a8a:	83 c0 01             	add    $0x1,%eax
  800a8d:	39 d0                	cmp    %edx,%eax
  800a8f:	72 f5                	jb     800a86 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	57                   	push   %edi
  800a97:	56                   	push   %esi
  800a98:	53                   	push   %ebx
  800a99:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a9f:	eb 03                	jmp    800aa4 <strtol+0x11>
		s++;
  800aa1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa4:	0f b6 0a             	movzbl (%edx),%ecx
  800aa7:	80 f9 09             	cmp    $0x9,%cl
  800aaa:	74 f5                	je     800aa1 <strtol+0xe>
  800aac:	80 f9 20             	cmp    $0x20,%cl
  800aaf:	74 f0                	je     800aa1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ab1:	80 f9 2b             	cmp    $0x2b,%cl
  800ab4:	75 0a                	jne    800ac0 <strtol+0x2d>
		s++;
  800ab6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ab9:	bf 00 00 00 00       	mov    $0x0,%edi
  800abe:	eb 11                	jmp    800ad1 <strtol+0x3e>
  800ac0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ac5:	80 f9 2d             	cmp    $0x2d,%cl
  800ac8:	75 07                	jne    800ad1 <strtol+0x3e>
		s++, neg = 1;
  800aca:	8d 52 01             	lea    0x1(%edx),%edx
  800acd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800ad6:	75 15                	jne    800aed <strtol+0x5a>
  800ad8:	80 3a 30             	cmpb   $0x30,(%edx)
  800adb:	75 10                	jne    800aed <strtol+0x5a>
  800add:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ae1:	75 0a                	jne    800aed <strtol+0x5a>
		s += 2, base = 16;
  800ae3:	83 c2 02             	add    $0x2,%edx
  800ae6:	b8 10 00 00 00       	mov    $0x10,%eax
  800aeb:	eb 10                	jmp    800afd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800aed:	85 c0                	test   %eax,%eax
  800aef:	75 0c                	jne    800afd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800af1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af3:	80 3a 30             	cmpb   $0x30,(%edx)
  800af6:	75 05                	jne    800afd <strtol+0x6a>
		s++, base = 8;
  800af8:	83 c2 01             	add    $0x1,%edx
  800afb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800afd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b02:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b05:	0f b6 0a             	movzbl (%edx),%ecx
  800b08:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b0b:	89 f0                	mov    %esi,%eax
  800b0d:	3c 09                	cmp    $0x9,%al
  800b0f:	77 08                	ja     800b19 <strtol+0x86>
			dig = *s - '0';
  800b11:	0f be c9             	movsbl %cl,%ecx
  800b14:	83 e9 30             	sub    $0x30,%ecx
  800b17:	eb 20                	jmp    800b39 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b19:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b1c:	89 f0                	mov    %esi,%eax
  800b1e:	3c 19                	cmp    $0x19,%al
  800b20:	77 08                	ja     800b2a <strtol+0x97>
			dig = *s - 'a' + 10;
  800b22:	0f be c9             	movsbl %cl,%ecx
  800b25:	83 e9 57             	sub    $0x57,%ecx
  800b28:	eb 0f                	jmp    800b39 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800b2a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b2d:	89 f0                	mov    %esi,%eax
  800b2f:	3c 19                	cmp    $0x19,%al
  800b31:	77 16                	ja     800b49 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800b33:	0f be c9             	movsbl %cl,%ecx
  800b36:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b39:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b3c:	7d 0f                	jge    800b4d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800b3e:	83 c2 01             	add    $0x1,%edx
  800b41:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800b45:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800b47:	eb bc                	jmp    800b05 <strtol+0x72>
  800b49:	89 d8                	mov    %ebx,%eax
  800b4b:	eb 02                	jmp    800b4f <strtol+0xbc>
  800b4d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800b4f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b53:	74 05                	je     800b5a <strtol+0xc7>
		*endptr = (char *) s;
  800b55:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b58:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b5a:	f7 d8                	neg    %eax
  800b5c:	85 ff                	test   %edi,%edi
  800b5e:	0f 44 c3             	cmove  %ebx,%eax
}
  800b61:	5b                   	pop    %ebx
  800b62:	5e                   	pop    %esi
  800b63:	5f                   	pop    %edi
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b74:	8b 55 08             	mov    0x8(%ebp),%edx
  800b77:	89 c3                	mov    %eax,%ebx
  800b79:	89 c7                	mov    %eax,%edi
  800b7b:	89 c6                	mov    %eax,%esi
  800b7d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b7f:	5b                   	pop    %ebx
  800b80:	5e                   	pop    %esi
  800b81:	5f                   	pop    %edi
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	57                   	push   %edi
  800b88:	56                   	push   %esi
  800b89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b94:	89 d1                	mov    %edx,%ecx
  800b96:	89 d3                	mov    %edx,%ebx
  800b98:	89 d7                	mov    %edx,%edi
  800b9a:	89 d6                	mov    %edx,%esi
  800b9c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	57                   	push   %edi
  800ba7:	56                   	push   %esi
  800ba8:	53                   	push   %ebx
  800ba9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bac:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bb1:	b8 03 00 00 00       	mov    $0x3,%eax
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb9:	89 cb                	mov    %ecx,%ebx
  800bbb:	89 cf                	mov    %ecx,%edi
  800bbd:	89 ce                	mov    %ecx,%esi
  800bbf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc1:	85 c0                	test   %eax,%eax
  800bc3:	7e 28                	jle    800bed <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bc9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bd0:	00 
  800bd1:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  800bd8:	00 
  800bd9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800be0:	00 
  800be1:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  800be8:	e8 07 f5 ff ff       	call   8000f4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bed:	83 c4 2c             	add    $0x2c,%esp
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800c00:	b8 02 00 00 00       	mov    $0x2,%eax
  800c05:	89 d1                	mov    %edx,%ecx
  800c07:	89 d3                	mov    %edx,%ebx
  800c09:	89 d7                	mov    %edx,%edi
  800c0b:	89 d6                	mov    %edx,%esi
  800c0d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <sys_yield>:

void
sys_yield(void)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c24:	89 d1                	mov    %edx,%ecx
  800c26:	89 d3                	mov    %edx,%ebx
  800c28:	89 d7                	mov    %edx,%edi
  800c2a:	89 d6                	mov    %edx,%esi
  800c2c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3c:	be 00 00 00 00       	mov    $0x0,%esi
  800c41:	b8 04 00 00 00       	mov    $0x4,%eax
  800c46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4f:	89 f7                	mov    %esi,%edi
  800c51:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c53:	85 c0                	test   %eax,%eax
  800c55:	7e 28                	jle    800c7f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c57:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c5b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c62:	00 
  800c63:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  800c6a:	00 
  800c6b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c72:	00 
  800c73:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  800c7a:	e8 75 f4 ff ff       	call   8000f4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c7f:	83 c4 2c             	add    $0x2c,%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c90:	b8 05 00 00 00       	mov    $0x5,%eax
  800c95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca1:	8b 75 18             	mov    0x18(%ebp),%esi
  800ca4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca6:	85 c0                	test   %eax,%eax
  800ca8:	7e 28                	jle    800cd2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800caa:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cae:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cb5:	00 
  800cb6:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  800cbd:	00 
  800cbe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc5:	00 
  800cc6:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  800ccd:	e8 22 f4 ff ff       	call   8000f4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cd2:	83 c4 2c             	add    $0x2c,%esp
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
  800ce0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce8:	b8 06 00 00 00       	mov    $0x6,%eax
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	89 df                	mov    %ebx,%edi
  800cf5:	89 de                	mov    %ebx,%esi
  800cf7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	7e 28                	jle    800d25 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d01:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d08:	00 
  800d09:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  800d10:	00 
  800d11:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d18:	00 
  800d19:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  800d20:	e8 cf f3 ff ff       	call   8000f4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d25:	83 c4 2c             	add    $0x2c,%esp
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    

00800d2d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	57                   	push   %edi
  800d31:	56                   	push   %esi
  800d32:	53                   	push   %ebx
  800d33:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d36:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d43:	8b 55 08             	mov    0x8(%ebp),%edx
  800d46:	89 df                	mov    %ebx,%edi
  800d48:	89 de                	mov    %ebx,%esi
  800d4a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d4c:	85 c0                	test   %eax,%eax
  800d4e:	7e 28                	jle    800d78 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d50:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d54:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d5b:	00 
  800d5c:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  800d63:	00 
  800d64:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d6b:	00 
  800d6c:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  800d73:	e8 7c f3 ff ff       	call   8000f4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d78:	83 c4 2c             	add    $0x2c,%esp
  800d7b:	5b                   	pop    %ebx
  800d7c:	5e                   	pop    %esi
  800d7d:	5f                   	pop    %edi
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    

00800d80 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	57                   	push   %edi
  800d84:	56                   	push   %esi
  800d85:	53                   	push   %ebx
  800d86:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d89:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8e:	b8 09 00 00 00       	mov    $0x9,%eax
  800d93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d96:	8b 55 08             	mov    0x8(%ebp),%edx
  800d99:	89 df                	mov    %ebx,%edi
  800d9b:	89 de                	mov    %ebx,%esi
  800d9d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d9f:	85 c0                	test   %eax,%eax
  800da1:	7e 28                	jle    800dcb <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dae:	00 
  800daf:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  800db6:	00 
  800db7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dbe:	00 
  800dbf:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  800dc6:	e8 29 f3 ff ff       	call   8000f4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dcb:	83 c4 2c             	add    $0x2c,%esp
  800dce:	5b                   	pop    %ebx
  800dcf:	5e                   	pop    %esi
  800dd0:	5f                   	pop    %edi
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	57                   	push   %edi
  800dd7:	56                   	push   %esi
  800dd8:	53                   	push   %ebx
  800dd9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800de6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dec:	89 df                	mov    %ebx,%edi
  800dee:	89 de                	mov    %ebx,%esi
  800df0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800df2:	85 c0                	test   %eax,%eax
  800df4:	7e 28                	jle    800e1e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dfa:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e01:	00 
  800e02:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  800e09:	00 
  800e0a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e11:	00 
  800e12:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  800e19:	e8 d6 f2 ff ff       	call   8000f4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e1e:	83 c4 2c             	add    $0x2c,%esp
  800e21:	5b                   	pop    %ebx
  800e22:	5e                   	pop    %esi
  800e23:	5f                   	pop    %edi
  800e24:	5d                   	pop    %ebp
  800e25:	c3                   	ret    

00800e26 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	57                   	push   %edi
  800e2a:	56                   	push   %esi
  800e2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2c:	be 00 00 00 00       	mov    $0x0,%esi
  800e31:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e39:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e42:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	57                   	push   %edi
  800e4d:	56                   	push   %esi
  800e4e:	53                   	push   %ebx
  800e4f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e52:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e57:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5f:	89 cb                	mov    %ecx,%ebx
  800e61:	89 cf                	mov    %ecx,%edi
  800e63:	89 ce                	mov    %ecx,%esi
  800e65:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e67:	85 c0                	test   %eax,%eax
  800e69:	7e 28                	jle    800e93 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e6f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e76:	00 
  800e77:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  800e7e:	00 
  800e7f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e86:	00 
  800e87:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  800e8e:	e8 61 f2 ff ff       	call   8000f4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e93:	83 c4 2c             	add    $0x2c,%esp
  800e96:	5b                   	pop    %ebx
  800e97:	5e                   	pop    %esi
  800e98:	5f                   	pop    %edi
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    

00800e9b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	57                   	push   %edi
  800e9f:	56                   	push   %esi
  800ea0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea6:	b8 0e 00 00 00       	mov    $0xe,%eax
  800eab:	89 d1                	mov    %edx,%ecx
  800ead:	89 d3                	mov    %edx,%ebx
  800eaf:	89 d7                	mov    %edx,%edi
  800eb1:	89 d6                	mov    %edx,%esi
  800eb3:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800eb5:	5b                   	pop    %ebx
  800eb6:	5e                   	pop    %esi
  800eb7:	5f                   	pop    %edi
  800eb8:	5d                   	pop    %ebp
  800eb9:	c3                   	ret    

00800eba <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	57                   	push   %edi
  800ebe:	56                   	push   %esi
  800ebf:	53                   	push   %ebx
  800ec0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec8:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ecd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed3:	89 df                	mov    %ebx,%edi
  800ed5:	89 de                	mov    %ebx,%esi
  800ed7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	7e 28                	jle    800f05 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800edd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee1:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800ee8:	00 
  800ee9:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  800ef0:	00 
  800ef1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef8:	00 
  800ef9:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  800f00:	e8 ef f1 ff ff       	call   8000f4 <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  800f05:	83 c4 2c             	add    $0x2c,%esp
  800f08:	5b                   	pop    %ebx
  800f09:	5e                   	pop    %esi
  800f0a:	5f                   	pop    %edi
  800f0b:	5d                   	pop    %ebp
  800f0c:	c3                   	ret    

00800f0d <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	57                   	push   %edi
  800f11:	56                   	push   %esi
  800f12:	53                   	push   %ebx
  800f13:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f1b:	b8 10 00 00 00       	mov    $0x10,%eax
  800f20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f23:	8b 55 08             	mov    0x8(%ebp),%edx
  800f26:	89 df                	mov    %ebx,%edi
  800f28:	89 de                	mov    %ebx,%esi
  800f2a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	7e 28                	jle    800f58 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f30:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f34:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  800f3b:	00 
  800f3c:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  800f43:	00 
  800f44:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f4b:	00 
  800f4c:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  800f53:	e8 9c f1 ff ff       	call   8000f4 <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  800f58:	83 c4 2c             	add    $0x2c,%esp
  800f5b:	5b                   	pop    %ebx
  800f5c:	5e                   	pop    %esi
  800f5d:	5f                   	pop    %edi
  800f5e:	5d                   	pop    %ebp
  800f5f:	c3                   	ret    

00800f60 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f63:	8b 45 08             	mov    0x8(%ebp),%eax
  800f66:	05 00 00 00 30       	add    $0x30000000,%eax
  800f6b:	c1 e8 0c             	shr    $0xc,%eax
}
  800f6e:	5d                   	pop    %ebp
  800f6f:	c3                   	ret    

00800f70 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f73:	8b 45 08             	mov    0x8(%ebp),%eax
  800f76:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800f7b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f80:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    

00800f87 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f8d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f92:	89 c2                	mov    %eax,%edx
  800f94:	c1 ea 16             	shr    $0x16,%edx
  800f97:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f9e:	f6 c2 01             	test   $0x1,%dl
  800fa1:	74 11                	je     800fb4 <fd_alloc+0x2d>
  800fa3:	89 c2                	mov    %eax,%edx
  800fa5:	c1 ea 0c             	shr    $0xc,%edx
  800fa8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800faf:	f6 c2 01             	test   $0x1,%dl
  800fb2:	75 09                	jne    800fbd <fd_alloc+0x36>
			*fd_store = fd;
  800fb4:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fbb:	eb 17                	jmp    800fd4 <fd_alloc+0x4d>
  800fbd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800fc2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800fc7:	75 c9                	jne    800f92 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800fc9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800fcf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fd4:	5d                   	pop    %ebp
  800fd5:	c3                   	ret    

00800fd6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fdc:	83 f8 1f             	cmp    $0x1f,%eax
  800fdf:	77 36                	ja     801017 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fe1:	c1 e0 0c             	shl    $0xc,%eax
  800fe4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fe9:	89 c2                	mov    %eax,%edx
  800feb:	c1 ea 16             	shr    $0x16,%edx
  800fee:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ff5:	f6 c2 01             	test   $0x1,%dl
  800ff8:	74 24                	je     80101e <fd_lookup+0x48>
  800ffa:	89 c2                	mov    %eax,%edx
  800ffc:	c1 ea 0c             	shr    $0xc,%edx
  800fff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801006:	f6 c2 01             	test   $0x1,%dl
  801009:	74 1a                	je     801025 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80100b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80100e:	89 02                	mov    %eax,(%edx)
	return 0;
  801010:	b8 00 00 00 00       	mov    $0x0,%eax
  801015:	eb 13                	jmp    80102a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801017:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80101c:	eb 0c                	jmp    80102a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80101e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801023:	eb 05                	jmp    80102a <fd_lookup+0x54>
  801025:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80102a:	5d                   	pop    %ebp
  80102b:	c3                   	ret    

0080102c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	83 ec 18             	sub    $0x18,%esp
  801032:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801035:	ba 00 00 00 00       	mov    $0x0,%edx
  80103a:	eb 13                	jmp    80104f <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  80103c:	39 08                	cmp    %ecx,(%eax)
  80103e:	75 0c                	jne    80104c <dev_lookup+0x20>
			*dev = devtab[i];
  801040:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801043:	89 01                	mov    %eax,(%ecx)
			return 0;
  801045:	b8 00 00 00 00       	mov    $0x0,%eax
  80104a:	eb 38                	jmp    801084 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80104c:	83 c2 01             	add    $0x1,%edx
  80104f:	8b 04 95 88 30 80 00 	mov    0x803088(,%edx,4),%eax
  801056:	85 c0                	test   %eax,%eax
  801058:	75 e2                	jne    80103c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80105a:	a1 08 50 80 00       	mov    0x805008,%eax
  80105f:	8b 40 48             	mov    0x48(%eax),%eax
  801062:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80106a:	c7 04 24 0c 30 80 00 	movl   $0x80300c,(%esp)
  801071:	e8 77 f1 ff ff       	call   8001ed <cprintf>
	*dev = 0;
  801076:	8b 45 0c             	mov    0xc(%ebp),%eax
  801079:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80107f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801084:	c9                   	leave  
  801085:	c3                   	ret    

00801086 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	56                   	push   %esi
  80108a:	53                   	push   %ebx
  80108b:	83 ec 20             	sub    $0x20,%esp
  80108e:	8b 75 08             	mov    0x8(%ebp),%esi
  801091:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801094:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801097:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80109b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8010a1:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010a4:	89 04 24             	mov    %eax,(%esp)
  8010a7:	e8 2a ff ff ff       	call   800fd6 <fd_lookup>
  8010ac:	85 c0                	test   %eax,%eax
  8010ae:	78 05                	js     8010b5 <fd_close+0x2f>
	    || fd != fd2)
  8010b0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8010b3:	74 0c                	je     8010c1 <fd_close+0x3b>
		return (must_exist ? r : 0);
  8010b5:	84 db                	test   %bl,%bl
  8010b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8010bc:	0f 44 c2             	cmove  %edx,%eax
  8010bf:	eb 3f                	jmp    801100 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c8:	8b 06                	mov    (%esi),%eax
  8010ca:	89 04 24             	mov    %eax,(%esp)
  8010cd:	e8 5a ff ff ff       	call   80102c <dev_lookup>
  8010d2:	89 c3                	mov    %eax,%ebx
  8010d4:	85 c0                	test   %eax,%eax
  8010d6:	78 16                	js     8010ee <fd_close+0x68>
		if (dev->dev_close)
  8010d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010db:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8010de:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	74 07                	je     8010ee <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8010e7:	89 34 24             	mov    %esi,(%esp)
  8010ea:	ff d0                	call   *%eax
  8010ec:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010ee:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010f9:	e8 dc fb ff ff       	call   800cda <sys_page_unmap>
	return r;
  8010fe:	89 d8                	mov    %ebx,%eax
}
  801100:	83 c4 20             	add    $0x20,%esp
  801103:	5b                   	pop    %ebx
  801104:	5e                   	pop    %esi
  801105:	5d                   	pop    %ebp
  801106:	c3                   	ret    

00801107 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80110d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801110:	89 44 24 04          	mov    %eax,0x4(%esp)
  801114:	8b 45 08             	mov    0x8(%ebp),%eax
  801117:	89 04 24             	mov    %eax,(%esp)
  80111a:	e8 b7 fe ff ff       	call   800fd6 <fd_lookup>
  80111f:	89 c2                	mov    %eax,%edx
  801121:	85 d2                	test   %edx,%edx
  801123:	78 13                	js     801138 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801125:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80112c:	00 
  80112d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801130:	89 04 24             	mov    %eax,(%esp)
  801133:	e8 4e ff ff ff       	call   801086 <fd_close>
}
  801138:	c9                   	leave  
  801139:	c3                   	ret    

0080113a <close_all>:

void
close_all(void)
{
  80113a:	55                   	push   %ebp
  80113b:	89 e5                	mov    %esp,%ebp
  80113d:	53                   	push   %ebx
  80113e:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801141:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801146:	89 1c 24             	mov    %ebx,(%esp)
  801149:	e8 b9 ff ff ff       	call   801107 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80114e:	83 c3 01             	add    $0x1,%ebx
  801151:	83 fb 20             	cmp    $0x20,%ebx
  801154:	75 f0                	jne    801146 <close_all+0xc>
		close(i);
}
  801156:	83 c4 14             	add    $0x14,%esp
  801159:	5b                   	pop    %ebx
  80115a:	5d                   	pop    %ebp
  80115b:	c3                   	ret    

0080115c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	57                   	push   %edi
  801160:	56                   	push   %esi
  801161:	53                   	push   %ebx
  801162:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801165:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801168:	89 44 24 04          	mov    %eax,0x4(%esp)
  80116c:	8b 45 08             	mov    0x8(%ebp),%eax
  80116f:	89 04 24             	mov    %eax,(%esp)
  801172:	e8 5f fe ff ff       	call   800fd6 <fd_lookup>
  801177:	89 c2                	mov    %eax,%edx
  801179:	85 d2                	test   %edx,%edx
  80117b:	0f 88 e1 00 00 00    	js     801262 <dup+0x106>
		return r;
	close(newfdnum);
  801181:	8b 45 0c             	mov    0xc(%ebp),%eax
  801184:	89 04 24             	mov    %eax,(%esp)
  801187:	e8 7b ff ff ff       	call   801107 <close>

	newfd = INDEX2FD(newfdnum);
  80118c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80118f:	c1 e3 0c             	shl    $0xc,%ebx
  801192:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801198:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80119b:	89 04 24             	mov    %eax,(%esp)
  80119e:	e8 cd fd ff ff       	call   800f70 <fd2data>
  8011a3:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8011a5:	89 1c 24             	mov    %ebx,(%esp)
  8011a8:	e8 c3 fd ff ff       	call   800f70 <fd2data>
  8011ad:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011af:	89 f0                	mov    %esi,%eax
  8011b1:	c1 e8 16             	shr    $0x16,%eax
  8011b4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011bb:	a8 01                	test   $0x1,%al
  8011bd:	74 43                	je     801202 <dup+0xa6>
  8011bf:	89 f0                	mov    %esi,%eax
  8011c1:	c1 e8 0c             	shr    $0xc,%eax
  8011c4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011cb:	f6 c2 01             	test   $0x1,%dl
  8011ce:	74 32                	je     801202 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011d0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011d7:	25 07 0e 00 00       	and    $0xe07,%eax
  8011dc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011e0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011e4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011eb:	00 
  8011ec:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011f7:	e8 8b fa ff ff       	call   800c87 <sys_page_map>
  8011fc:	89 c6                	mov    %eax,%esi
  8011fe:	85 c0                	test   %eax,%eax
  801200:	78 3e                	js     801240 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801202:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801205:	89 c2                	mov    %eax,%edx
  801207:	c1 ea 0c             	shr    $0xc,%edx
  80120a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801211:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801217:	89 54 24 10          	mov    %edx,0x10(%esp)
  80121b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80121f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801226:	00 
  801227:	89 44 24 04          	mov    %eax,0x4(%esp)
  80122b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801232:	e8 50 fa ff ff       	call   800c87 <sys_page_map>
  801237:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801239:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80123c:	85 f6                	test   %esi,%esi
  80123e:	79 22                	jns    801262 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801240:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801244:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80124b:	e8 8a fa ff ff       	call   800cda <sys_page_unmap>
	sys_page_unmap(0, nva);
  801250:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801254:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80125b:	e8 7a fa ff ff       	call   800cda <sys_page_unmap>
	return r;
  801260:	89 f0                	mov    %esi,%eax
}
  801262:	83 c4 3c             	add    $0x3c,%esp
  801265:	5b                   	pop    %ebx
  801266:	5e                   	pop    %esi
  801267:	5f                   	pop    %edi
  801268:	5d                   	pop    %ebp
  801269:	c3                   	ret    

0080126a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	53                   	push   %ebx
  80126e:	83 ec 24             	sub    $0x24,%esp
  801271:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801274:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801277:	89 44 24 04          	mov    %eax,0x4(%esp)
  80127b:	89 1c 24             	mov    %ebx,(%esp)
  80127e:	e8 53 fd ff ff       	call   800fd6 <fd_lookup>
  801283:	89 c2                	mov    %eax,%edx
  801285:	85 d2                	test   %edx,%edx
  801287:	78 6d                	js     8012f6 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801289:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801290:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801293:	8b 00                	mov    (%eax),%eax
  801295:	89 04 24             	mov    %eax,(%esp)
  801298:	e8 8f fd ff ff       	call   80102c <dev_lookup>
  80129d:	85 c0                	test   %eax,%eax
  80129f:	78 55                	js     8012f6 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8012a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a4:	8b 50 08             	mov    0x8(%eax),%edx
  8012a7:	83 e2 03             	and    $0x3,%edx
  8012aa:	83 fa 01             	cmp    $0x1,%edx
  8012ad:	75 23                	jne    8012d2 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012af:	a1 08 50 80 00       	mov    0x805008,%eax
  8012b4:	8b 40 48             	mov    0x48(%eax),%eax
  8012b7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012bf:	c7 04 24 4d 30 80 00 	movl   $0x80304d,(%esp)
  8012c6:	e8 22 ef ff ff       	call   8001ed <cprintf>
		return -E_INVAL;
  8012cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d0:	eb 24                	jmp    8012f6 <read+0x8c>
	}
	if (!dev->dev_read)
  8012d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012d5:	8b 52 08             	mov    0x8(%edx),%edx
  8012d8:	85 d2                	test   %edx,%edx
  8012da:	74 15                	je     8012f1 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012df:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012ea:	89 04 24             	mov    %eax,(%esp)
  8012ed:	ff d2                	call   *%edx
  8012ef:	eb 05                	jmp    8012f6 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012f1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8012f6:	83 c4 24             	add    $0x24,%esp
  8012f9:	5b                   	pop    %ebx
  8012fa:	5d                   	pop    %ebp
  8012fb:	c3                   	ret    

008012fc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	57                   	push   %edi
  801300:	56                   	push   %esi
  801301:	53                   	push   %ebx
  801302:	83 ec 1c             	sub    $0x1c,%esp
  801305:	8b 7d 08             	mov    0x8(%ebp),%edi
  801308:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80130b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801310:	eb 23                	jmp    801335 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801312:	89 f0                	mov    %esi,%eax
  801314:	29 d8                	sub    %ebx,%eax
  801316:	89 44 24 08          	mov    %eax,0x8(%esp)
  80131a:	89 d8                	mov    %ebx,%eax
  80131c:	03 45 0c             	add    0xc(%ebp),%eax
  80131f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801323:	89 3c 24             	mov    %edi,(%esp)
  801326:	e8 3f ff ff ff       	call   80126a <read>
		if (m < 0)
  80132b:	85 c0                	test   %eax,%eax
  80132d:	78 10                	js     80133f <readn+0x43>
			return m;
		if (m == 0)
  80132f:	85 c0                	test   %eax,%eax
  801331:	74 0a                	je     80133d <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801333:	01 c3                	add    %eax,%ebx
  801335:	39 f3                	cmp    %esi,%ebx
  801337:	72 d9                	jb     801312 <readn+0x16>
  801339:	89 d8                	mov    %ebx,%eax
  80133b:	eb 02                	jmp    80133f <readn+0x43>
  80133d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80133f:	83 c4 1c             	add    $0x1c,%esp
  801342:	5b                   	pop    %ebx
  801343:	5e                   	pop    %esi
  801344:	5f                   	pop    %edi
  801345:	5d                   	pop    %ebp
  801346:	c3                   	ret    

00801347 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801347:	55                   	push   %ebp
  801348:	89 e5                	mov    %esp,%ebp
  80134a:	53                   	push   %ebx
  80134b:	83 ec 24             	sub    $0x24,%esp
  80134e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801351:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801354:	89 44 24 04          	mov    %eax,0x4(%esp)
  801358:	89 1c 24             	mov    %ebx,(%esp)
  80135b:	e8 76 fc ff ff       	call   800fd6 <fd_lookup>
  801360:	89 c2                	mov    %eax,%edx
  801362:	85 d2                	test   %edx,%edx
  801364:	78 68                	js     8013ce <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801366:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801369:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801370:	8b 00                	mov    (%eax),%eax
  801372:	89 04 24             	mov    %eax,(%esp)
  801375:	e8 b2 fc ff ff       	call   80102c <dev_lookup>
  80137a:	85 c0                	test   %eax,%eax
  80137c:	78 50                	js     8013ce <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80137e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801381:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801385:	75 23                	jne    8013aa <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801387:	a1 08 50 80 00       	mov    0x805008,%eax
  80138c:	8b 40 48             	mov    0x48(%eax),%eax
  80138f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801393:	89 44 24 04          	mov    %eax,0x4(%esp)
  801397:	c7 04 24 69 30 80 00 	movl   $0x803069,(%esp)
  80139e:	e8 4a ee ff ff       	call   8001ed <cprintf>
		return -E_INVAL;
  8013a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013a8:	eb 24                	jmp    8013ce <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013ad:	8b 52 0c             	mov    0xc(%edx),%edx
  8013b0:	85 d2                	test   %edx,%edx
  8013b2:	74 15                	je     8013c9 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013b7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013be:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013c2:	89 04 24             	mov    %eax,(%esp)
  8013c5:	ff d2                	call   *%edx
  8013c7:	eb 05                	jmp    8013ce <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8013c9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8013ce:	83 c4 24             	add    $0x24,%esp
  8013d1:	5b                   	pop    %ebx
  8013d2:	5d                   	pop    %ebp
  8013d3:	c3                   	ret    

008013d4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8013d4:	55                   	push   %ebp
  8013d5:	89 e5                	mov    %esp,%ebp
  8013d7:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013da:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e4:	89 04 24             	mov    %eax,(%esp)
  8013e7:	e8 ea fb ff ff       	call   800fd6 <fd_lookup>
  8013ec:	85 c0                	test   %eax,%eax
  8013ee:	78 0e                	js     8013fe <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8013f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013f6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013fe:	c9                   	leave  
  8013ff:	c3                   	ret    

00801400 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
  801403:	53                   	push   %ebx
  801404:	83 ec 24             	sub    $0x24,%esp
  801407:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80140a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80140d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801411:	89 1c 24             	mov    %ebx,(%esp)
  801414:	e8 bd fb ff ff       	call   800fd6 <fd_lookup>
  801419:	89 c2                	mov    %eax,%edx
  80141b:	85 d2                	test   %edx,%edx
  80141d:	78 61                	js     801480 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80141f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801422:	89 44 24 04          	mov    %eax,0x4(%esp)
  801426:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801429:	8b 00                	mov    (%eax),%eax
  80142b:	89 04 24             	mov    %eax,(%esp)
  80142e:	e8 f9 fb ff ff       	call   80102c <dev_lookup>
  801433:	85 c0                	test   %eax,%eax
  801435:	78 49                	js     801480 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801437:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80143e:	75 23                	jne    801463 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801440:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801445:	8b 40 48             	mov    0x48(%eax),%eax
  801448:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80144c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801450:	c7 04 24 2c 30 80 00 	movl   $0x80302c,(%esp)
  801457:	e8 91 ed ff ff       	call   8001ed <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80145c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801461:	eb 1d                	jmp    801480 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801463:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801466:	8b 52 18             	mov    0x18(%edx),%edx
  801469:	85 d2                	test   %edx,%edx
  80146b:	74 0e                	je     80147b <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80146d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801470:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801474:	89 04 24             	mov    %eax,(%esp)
  801477:	ff d2                	call   *%edx
  801479:	eb 05                	jmp    801480 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80147b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801480:	83 c4 24             	add    $0x24,%esp
  801483:	5b                   	pop    %ebx
  801484:	5d                   	pop    %ebp
  801485:	c3                   	ret    

00801486 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801486:	55                   	push   %ebp
  801487:	89 e5                	mov    %esp,%ebp
  801489:	53                   	push   %ebx
  80148a:	83 ec 24             	sub    $0x24,%esp
  80148d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801490:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801493:	89 44 24 04          	mov    %eax,0x4(%esp)
  801497:	8b 45 08             	mov    0x8(%ebp),%eax
  80149a:	89 04 24             	mov    %eax,(%esp)
  80149d:	e8 34 fb ff ff       	call   800fd6 <fd_lookup>
  8014a2:	89 c2                	mov    %eax,%edx
  8014a4:	85 d2                	test   %edx,%edx
  8014a6:	78 52                	js     8014fa <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b2:	8b 00                	mov    (%eax),%eax
  8014b4:	89 04 24             	mov    %eax,(%esp)
  8014b7:	e8 70 fb ff ff       	call   80102c <dev_lookup>
  8014bc:	85 c0                	test   %eax,%eax
  8014be:	78 3a                	js     8014fa <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8014c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014c7:	74 2c                	je     8014f5 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014c9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014cc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014d3:	00 00 00 
	stat->st_isdir = 0;
  8014d6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014dd:	00 00 00 
	stat->st_dev = dev;
  8014e0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014ed:	89 14 24             	mov    %edx,(%esp)
  8014f0:	ff 50 14             	call   *0x14(%eax)
  8014f3:	eb 05                	jmp    8014fa <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8014f5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8014fa:	83 c4 24             	add    $0x24,%esp
  8014fd:	5b                   	pop    %ebx
  8014fe:	5d                   	pop    %ebp
  8014ff:	c3                   	ret    

00801500 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
  801503:	56                   	push   %esi
  801504:	53                   	push   %ebx
  801505:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801508:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80150f:	00 
  801510:	8b 45 08             	mov    0x8(%ebp),%eax
  801513:	89 04 24             	mov    %eax,(%esp)
  801516:	e8 28 02 00 00       	call   801743 <open>
  80151b:	89 c3                	mov    %eax,%ebx
  80151d:	85 db                	test   %ebx,%ebx
  80151f:	78 1b                	js     80153c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801521:	8b 45 0c             	mov    0xc(%ebp),%eax
  801524:	89 44 24 04          	mov    %eax,0x4(%esp)
  801528:	89 1c 24             	mov    %ebx,(%esp)
  80152b:	e8 56 ff ff ff       	call   801486 <fstat>
  801530:	89 c6                	mov    %eax,%esi
	close(fd);
  801532:	89 1c 24             	mov    %ebx,(%esp)
  801535:	e8 cd fb ff ff       	call   801107 <close>
	return r;
  80153a:	89 f0                	mov    %esi,%eax
}
  80153c:	83 c4 10             	add    $0x10,%esp
  80153f:	5b                   	pop    %ebx
  801540:	5e                   	pop    %esi
  801541:	5d                   	pop    %ebp
  801542:	c3                   	ret    

00801543 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801543:	55                   	push   %ebp
  801544:	89 e5                	mov    %esp,%ebp
  801546:	56                   	push   %esi
  801547:	53                   	push   %ebx
  801548:	83 ec 10             	sub    $0x10,%esp
  80154b:	89 c6                	mov    %eax,%esi
  80154d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80154f:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801556:	75 11                	jne    801569 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801558:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80155f:	e8 f1 13 00 00       	call   802955 <ipc_find_env>
  801564:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801569:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801570:	00 
  801571:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801578:	00 
  801579:	89 74 24 04          	mov    %esi,0x4(%esp)
  80157d:	a1 00 50 80 00       	mov    0x805000,%eax
  801582:	89 04 24             	mov    %eax,(%esp)
  801585:	e8 60 13 00 00       	call   8028ea <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80158a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801591:	00 
  801592:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801596:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80159d:	e8 ce 12 00 00       	call   802870 <ipc_recv>
}
  8015a2:	83 c4 10             	add    $0x10,%esp
  8015a5:	5b                   	pop    %ebx
  8015a6:	5e                   	pop    %esi
  8015a7:	5d                   	pop    %ebp
  8015a8:	c3                   	ret    

008015a9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015a9:	55                   	push   %ebp
  8015aa:	89 e5                	mov    %esp,%ebp
  8015ac:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015af:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8015b5:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8015ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015bd:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8015c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c7:	b8 02 00 00 00       	mov    $0x2,%eax
  8015cc:	e8 72 ff ff ff       	call   801543 <fsipc>
}
  8015d1:	c9                   	leave  
  8015d2:	c3                   	ret    

008015d3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8015d3:	55                   	push   %ebp
  8015d4:	89 e5                	mov    %esp,%ebp
  8015d6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015dc:	8b 40 0c             	mov    0xc(%eax),%eax
  8015df:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8015e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e9:	b8 06 00 00 00       	mov    $0x6,%eax
  8015ee:	e8 50 ff ff ff       	call   801543 <fsipc>
}
  8015f3:	c9                   	leave  
  8015f4:	c3                   	ret    

008015f5 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015f5:	55                   	push   %ebp
  8015f6:	89 e5                	mov    %esp,%ebp
  8015f8:	53                   	push   %ebx
  8015f9:	83 ec 14             	sub    $0x14,%esp
  8015fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801602:	8b 40 0c             	mov    0xc(%eax),%eax
  801605:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80160a:	ba 00 00 00 00       	mov    $0x0,%edx
  80160f:	b8 05 00 00 00       	mov    $0x5,%eax
  801614:	e8 2a ff ff ff       	call   801543 <fsipc>
  801619:	89 c2                	mov    %eax,%edx
  80161b:	85 d2                	test   %edx,%edx
  80161d:	78 2b                	js     80164a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80161f:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801626:	00 
  801627:	89 1c 24             	mov    %ebx,(%esp)
  80162a:	e8 e8 f1 ff ff       	call   800817 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80162f:	a1 80 60 80 00       	mov    0x806080,%eax
  801634:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80163a:	a1 84 60 80 00       	mov    0x806084,%eax
  80163f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801645:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80164a:	83 c4 14             	add    $0x14,%esp
  80164d:	5b                   	pop    %ebx
  80164e:	5d                   	pop    %ebp
  80164f:	c3                   	ret    

00801650 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
  801653:	83 ec 18             	sub    $0x18,%esp
  801656:	8b 45 10             	mov    0x10(%ebp),%eax
  801659:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80165e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801663:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801666:	8b 55 08             	mov    0x8(%ebp),%edx
  801669:	8b 52 0c             	mov    0xc(%edx),%edx
  80166c:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801672:	a3 04 60 80 00       	mov    %eax,0x806004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801677:	89 44 24 08          	mov    %eax,0x8(%esp)
  80167b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80167e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801682:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801689:	e8 26 f3 ff ff       	call   8009b4 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  80168e:	ba 00 00 00 00       	mov    $0x0,%edx
  801693:	b8 04 00 00 00       	mov    $0x4,%eax
  801698:	e8 a6 fe ff ff       	call   801543 <fsipc>
}
  80169d:	c9                   	leave  
  80169e:	c3                   	ret    

0080169f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	56                   	push   %esi
  8016a3:	53                   	push   %ebx
  8016a4:	83 ec 10             	sub    $0x10,%esp
  8016a7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b0:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8016b5:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c0:	b8 03 00 00 00       	mov    $0x3,%eax
  8016c5:	e8 79 fe ff ff       	call   801543 <fsipc>
  8016ca:	89 c3                	mov    %eax,%ebx
  8016cc:	85 c0                	test   %eax,%eax
  8016ce:	78 6a                	js     80173a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8016d0:	39 c6                	cmp    %eax,%esi
  8016d2:	73 24                	jae    8016f8 <devfile_read+0x59>
  8016d4:	c7 44 24 0c 9c 30 80 	movl   $0x80309c,0xc(%esp)
  8016db:	00 
  8016dc:	c7 44 24 08 a3 30 80 	movl   $0x8030a3,0x8(%esp)
  8016e3:	00 
  8016e4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8016eb:	00 
  8016ec:	c7 04 24 b8 30 80 00 	movl   $0x8030b8,(%esp)
  8016f3:	e8 fc e9 ff ff       	call   8000f4 <_panic>
	assert(r <= PGSIZE);
  8016f8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016fd:	7e 24                	jle    801723 <devfile_read+0x84>
  8016ff:	c7 44 24 0c c3 30 80 	movl   $0x8030c3,0xc(%esp)
  801706:	00 
  801707:	c7 44 24 08 a3 30 80 	movl   $0x8030a3,0x8(%esp)
  80170e:	00 
  80170f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801716:	00 
  801717:	c7 04 24 b8 30 80 00 	movl   $0x8030b8,(%esp)
  80171e:	e8 d1 e9 ff ff       	call   8000f4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801723:	89 44 24 08          	mov    %eax,0x8(%esp)
  801727:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80172e:	00 
  80172f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801732:	89 04 24             	mov    %eax,(%esp)
  801735:	e8 7a f2 ff ff       	call   8009b4 <memmove>
	return r;
}
  80173a:	89 d8                	mov    %ebx,%eax
  80173c:	83 c4 10             	add    $0x10,%esp
  80173f:	5b                   	pop    %ebx
  801740:	5e                   	pop    %esi
  801741:	5d                   	pop    %ebp
  801742:	c3                   	ret    

00801743 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801743:	55                   	push   %ebp
  801744:	89 e5                	mov    %esp,%ebp
  801746:	53                   	push   %ebx
  801747:	83 ec 24             	sub    $0x24,%esp
  80174a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80174d:	89 1c 24             	mov    %ebx,(%esp)
  801750:	e8 8b f0 ff ff       	call   8007e0 <strlen>
  801755:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80175a:	7f 60                	jg     8017bc <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80175c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80175f:	89 04 24             	mov    %eax,(%esp)
  801762:	e8 20 f8 ff ff       	call   800f87 <fd_alloc>
  801767:	89 c2                	mov    %eax,%edx
  801769:	85 d2                	test   %edx,%edx
  80176b:	78 54                	js     8017c1 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80176d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801771:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801778:	e8 9a f0 ff ff       	call   800817 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80177d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801780:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801785:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801788:	b8 01 00 00 00       	mov    $0x1,%eax
  80178d:	e8 b1 fd ff ff       	call   801543 <fsipc>
  801792:	89 c3                	mov    %eax,%ebx
  801794:	85 c0                	test   %eax,%eax
  801796:	79 17                	jns    8017af <open+0x6c>
		fd_close(fd, 0);
  801798:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80179f:	00 
  8017a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a3:	89 04 24             	mov    %eax,(%esp)
  8017a6:	e8 db f8 ff ff       	call   801086 <fd_close>
		return r;
  8017ab:	89 d8                	mov    %ebx,%eax
  8017ad:	eb 12                	jmp    8017c1 <open+0x7e>
	}

	return fd2num(fd);
  8017af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b2:	89 04 24             	mov    %eax,(%esp)
  8017b5:	e8 a6 f7 ff ff       	call   800f60 <fd2num>
  8017ba:	eb 05                	jmp    8017c1 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017bc:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017c1:	83 c4 24             	add    $0x24,%esp
  8017c4:	5b                   	pop    %ebx
  8017c5:	5d                   	pop    %ebp
  8017c6:	c3                   	ret    

008017c7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d2:	b8 08 00 00 00       	mov    $0x8,%eax
  8017d7:	e8 67 fd ff ff       	call   801543 <fsipc>
}
  8017dc:	c9                   	leave  
  8017dd:	c3                   	ret    
  8017de:	66 90                	xchg   %ax,%ax

008017e0 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	57                   	push   %edi
  8017e4:	56                   	push   %esi
  8017e5:	53                   	push   %ebx
  8017e6:	81 ec 9c 02 00 00    	sub    $0x29c,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8017ec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017f3:	00 
  8017f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f7:	89 04 24             	mov    %eax,(%esp)
  8017fa:	e8 44 ff ff ff       	call   801743 <open>
  8017ff:	89 c2                	mov    %eax,%edx
  801801:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801807:	85 c0                	test   %eax,%eax
  801809:	0f 88 3e 05 00 00    	js     801d4d <spawn+0x56d>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80180f:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801816:	00 
  801817:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80181d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801821:	89 14 24             	mov    %edx,(%esp)
  801824:	e8 d3 fa ff ff       	call   8012fc <readn>
  801829:	3d 00 02 00 00       	cmp    $0x200,%eax
  80182e:	75 0c                	jne    80183c <spawn+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  801830:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801837:	45 4c 46 
  80183a:	74 36                	je     801872 <spawn+0x92>
		close(fd);
  80183c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801842:	89 04 24             	mov    %eax,(%esp)
  801845:	e8 bd f8 ff ff       	call   801107 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80184a:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801851:	46 
  801852:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801858:	89 44 24 04          	mov    %eax,0x4(%esp)
  80185c:	c7 04 24 cf 30 80 00 	movl   $0x8030cf,(%esp)
  801863:	e8 85 e9 ff ff       	call   8001ed <cprintf>
		return -E_NOT_EXEC;
  801868:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  80186d:	e9 3a 05 00 00       	jmp    801dac <spawn+0x5cc>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801872:	b8 07 00 00 00       	mov    $0x7,%eax
  801877:	cd 30                	int    $0x30
  801879:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80187f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801885:	85 c0                	test   %eax,%eax
  801887:	0f 88 c8 04 00 00    	js     801d55 <spawn+0x575>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80188d:	89 c6                	mov    %eax,%esi
  80188f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801895:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801898:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80189e:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8018a4:	b9 11 00 00 00       	mov    $0x11,%ecx
  8018a9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8018ab:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8018b1:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8018b7:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8018bc:	be 00 00 00 00       	mov    $0x0,%esi
  8018c1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8018c4:	eb 0f                	jmp    8018d5 <spawn+0xf5>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8018c6:	89 04 24             	mov    %eax,(%esp)
  8018c9:	e8 12 ef ff ff       	call   8007e0 <strlen>
  8018ce:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8018d2:	83 c3 01             	add    $0x1,%ebx
  8018d5:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8018dc:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	75 e3                	jne    8018c6 <spawn+0xe6>
  8018e3:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  8018e9:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8018ef:	bf 00 10 40 00       	mov    $0x401000,%edi
  8018f4:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8018f6:	89 fa                	mov    %edi,%edx
  8018f8:	83 e2 fc             	and    $0xfffffffc,%edx
  8018fb:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801902:	29 c2                	sub    %eax,%edx
  801904:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80190a:	8d 42 f8             	lea    -0x8(%edx),%eax
  80190d:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801912:	0f 86 4d 04 00 00    	jbe    801d65 <spawn+0x585>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801918:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80191f:	00 
  801920:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801927:	00 
  801928:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80192f:	e8 ff f2 ff ff       	call   800c33 <sys_page_alloc>
  801934:	85 c0                	test   %eax,%eax
  801936:	0f 88 70 04 00 00    	js     801dac <spawn+0x5cc>
  80193c:	be 00 00 00 00       	mov    $0x0,%esi
  801941:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801947:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80194a:	eb 30                	jmp    80197c <spawn+0x19c>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80194c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801952:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801958:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  80195b:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  80195e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801962:	89 3c 24             	mov    %edi,(%esp)
  801965:	e8 ad ee ff ff       	call   800817 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80196a:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  80196d:	89 04 24             	mov    %eax,(%esp)
  801970:	e8 6b ee ff ff       	call   8007e0 <strlen>
  801975:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801979:	83 c6 01             	add    $0x1,%esi
  80197c:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801982:	7f c8                	jg     80194c <spawn+0x16c>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801984:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80198a:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801990:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801997:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80199d:	74 24                	je     8019c3 <spawn+0x1e3>
  80199f:	c7 44 24 0c 44 31 80 	movl   $0x803144,0xc(%esp)
  8019a6:	00 
  8019a7:	c7 44 24 08 a3 30 80 	movl   $0x8030a3,0x8(%esp)
  8019ae:	00 
  8019af:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  8019b6:	00 
  8019b7:	c7 04 24 e9 30 80 00 	movl   $0x8030e9,(%esp)
  8019be:	e8 31 e7 ff ff       	call   8000f4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8019c3:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8019c9:	89 c8                	mov    %ecx,%eax
  8019cb:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8019d0:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  8019d3:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  8019d9:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8019dc:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  8019e2:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8019e8:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8019ef:	00 
  8019f0:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  8019f7:	ee 
  8019f8:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8019fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a02:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801a09:	00 
  801a0a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a11:	e8 71 f2 ff ff       	call   800c87 <sys_page_map>
  801a16:	89 c3                	mov    %eax,%ebx
  801a18:	85 c0                	test   %eax,%eax
  801a1a:	0f 88 76 03 00 00    	js     801d96 <spawn+0x5b6>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801a20:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801a27:	00 
  801a28:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a2f:	e8 a6 f2 ff ff       	call   800cda <sys_page_unmap>
  801a34:	89 c3                	mov    %eax,%ebx
  801a36:	85 c0                	test   %eax,%eax
  801a38:	0f 88 58 03 00 00    	js     801d96 <spawn+0x5b6>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801a3e:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801a44:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801a4b:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801a51:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801a58:	00 00 00 
  801a5b:	e9 b6 01 00 00       	jmp    801c16 <spawn+0x436>
		if (ph->p_type != ELF_PROG_LOAD)
  801a60:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801a66:	83 38 01             	cmpl   $0x1,(%eax)
  801a69:	0f 85 99 01 00 00    	jne    801c08 <spawn+0x428>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801a6f:	89 c2                	mov    %eax,%edx
  801a71:	8b 40 18             	mov    0x18(%eax),%eax
  801a74:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801a77:	83 f8 01             	cmp    $0x1,%eax
  801a7a:	19 c0                	sbb    %eax,%eax
  801a7c:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801a82:	83 a5 90 fd ff ff fe 	andl   $0xfffffffe,-0x270(%ebp)
  801a89:	83 85 90 fd ff ff 07 	addl   $0x7,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801a90:	89 d0                	mov    %edx,%eax
  801a92:	8b 52 04             	mov    0x4(%edx),%edx
  801a95:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  801a9b:	8b 50 10             	mov    0x10(%eax),%edx
  801a9e:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)
  801aa4:	8b 48 14             	mov    0x14(%eax),%ecx
  801aa7:	89 8d 8c fd ff ff    	mov    %ecx,-0x274(%ebp)
  801aad:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801ab0:	89 f0                	mov    %esi,%eax
  801ab2:	25 ff 0f 00 00       	and    $0xfff,%eax
  801ab7:	74 14                	je     801acd <spawn+0x2ed>
		va -= i;
  801ab9:	29 c6                	sub    %eax,%esi
		memsz += i;
  801abb:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  801ac1:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801ac7:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801acd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ad2:	e9 23 01 00 00       	jmp    801bfa <spawn+0x41a>
		if (i >= filesz) {
  801ad7:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801add:	77 2b                	ja     801b0a <spawn+0x32a>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801adf:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801ae5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ae9:	89 74 24 04          	mov    %esi,0x4(%esp)
  801aed:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801af3:	89 04 24             	mov    %eax,(%esp)
  801af6:	e8 38 f1 ff ff       	call   800c33 <sys_page_alloc>
  801afb:	85 c0                	test   %eax,%eax
  801afd:	0f 89 eb 00 00 00    	jns    801bee <spawn+0x40e>
  801b03:	89 c3                	mov    %eax,%ebx
  801b05:	e9 6c 02 00 00       	jmp    801d76 <spawn+0x596>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b0a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801b11:	00 
  801b12:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b19:	00 
  801b1a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b21:	e8 0d f1 ff ff       	call   800c33 <sys_page_alloc>
  801b26:	85 c0                	test   %eax,%eax
  801b28:	0f 88 3e 02 00 00    	js     801d6c <spawn+0x58c>
  801b2e:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801b34:	01 f8                	add    %edi,%eax
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b36:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b3a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b40:	89 04 24             	mov    %eax,(%esp)
  801b43:	e8 8c f8 ff ff       	call   8013d4 <seek>
  801b48:	85 c0                	test   %eax,%eax
  801b4a:	0f 88 20 02 00 00    	js     801d70 <spawn+0x590>
  801b50:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801b56:	29 f9                	sub    %edi,%ecx
  801b58:	89 c8                	mov    %ecx,%eax
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b5a:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
  801b60:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801b65:	0f 47 c1             	cmova  %ecx,%eax
  801b68:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b6c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b73:	00 
  801b74:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b7a:	89 04 24             	mov    %eax,(%esp)
  801b7d:	e8 7a f7 ff ff       	call   8012fc <readn>
  801b82:	85 c0                	test   %eax,%eax
  801b84:	0f 88 ea 01 00 00    	js     801d74 <spawn+0x594>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801b8a:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801b90:	89 44 24 10          	mov    %eax,0x10(%esp)
  801b94:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801b98:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801b9e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ba2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ba9:	00 
  801baa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bb1:	e8 d1 f0 ff ff       	call   800c87 <sys_page_map>
  801bb6:	85 c0                	test   %eax,%eax
  801bb8:	79 20                	jns    801bda <spawn+0x3fa>
				panic("spawn: sys_page_map data: %e", r);
  801bba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bbe:	c7 44 24 08 f5 30 80 	movl   $0x8030f5,0x8(%esp)
  801bc5:	00 
  801bc6:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  801bcd:	00 
  801bce:	c7 04 24 e9 30 80 00 	movl   $0x8030e9,(%esp)
  801bd5:	e8 1a e5 ff ff       	call   8000f4 <_panic>
			sys_page_unmap(0, UTEMP);
  801bda:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801be1:	00 
  801be2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801be9:	e8 ec f0 ff ff       	call   800cda <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801bee:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801bf4:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801bfa:	89 df                	mov    %ebx,%edi
  801bfc:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  801c02:	0f 87 cf fe ff ff    	ja     801ad7 <spawn+0x2f7>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c08:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801c0f:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801c16:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801c1d:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801c23:	0f 8c 37 fe ff ff    	jl     801a60 <spawn+0x280>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801c29:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801c2f:	89 04 24             	mov    %eax,(%esp)
  801c32:	e8 d0 f4 ff ff       	call   801107 <close>
// Copy the mappings for shared pages into the child address space.
static int
copy_shared_pages(envid_t child)
{
	uintptr_t addr;
	int r = 0;
  801c37:	be 00 00 00 00       	mov    $0x0,%esi

	for(addr = 0; addr < UTOP - PGSIZE; addr+=PGSIZE) {
  801c3c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)]) {
  801c41:	89 d8                	mov    %ebx,%eax
  801c43:	c1 e8 16             	shr    $0x16,%eax
  801c46:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c4d:	85 c0                	test   %eax,%eax
  801c4f:	74 4e                	je     801c9f <spawn+0x4bf>
  801c51:	89 d8                	mov    %ebx,%eax
  801c53:	c1 e8 0c             	shr    $0xc,%eax
  801c56:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801c5d:	85 d2                	test   %edx,%edx
  801c5f:	74 3e                	je     801c9f <spawn+0x4bf>
			if(uvpt[PGNUM(addr)] & PTE_SHARE) {
  801c61:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801c68:	f6 c6 04             	test   $0x4,%dh
  801c6b:	74 32                	je     801c9f <spawn+0x4bf>
				r += sys_page_map(sys_getenvid(), (void*)addr, child, (void*)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL);
  801c6d:	8b 3c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edi
  801c74:	e8 7c ef ff ff       	call   800bf5 <sys_getenvid>
  801c79:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  801c7f:	89 7c 24 10          	mov    %edi,0x10(%esp)
  801c83:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c87:	8b 95 84 fd ff ff    	mov    -0x27c(%ebp),%edx
  801c8d:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c91:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c95:	89 04 24             	mov    %eax,(%esp)
  801c98:	e8 ea ef ff ff       	call   800c87 <sys_page_map>
  801c9d:	01 c6                	add    %eax,%esi
copy_shared_pages(envid_t child)
{
	uintptr_t addr;
	int r = 0;

	for(addr = 0; addr < UTOP - PGSIZE; addr+=PGSIZE) {
  801c9f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801ca5:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801cab:	75 94                	jne    801c41 <spawn+0x461>
			if(uvpt[PGNUM(addr)] & PTE_SHARE) {
				r += sys_page_map(sys_getenvid(), (void*)addr, child, (void*)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL);
			}
		}
	}
	if(r<0) {
  801cad:	85 f6                	test   %esi,%esi
  801caf:	79 1c                	jns    801ccd <spawn+0x4ed>
		panic("Something went wrong in copy_shared_pages");
  801cb1:	c7 44 24 08 6c 31 80 	movl   $0x80316c,0x8(%esp)
  801cb8:	00 
  801cb9:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
  801cc0:	00 
  801cc1:	c7 04 24 e9 30 80 00 	movl   $0x8030e9,(%esp)
  801cc8:	e8 27 e4 ff ff       	call   8000f4 <_panic>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801ccd:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801cd4:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801cd7:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801cdd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ce1:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801ce7:	89 04 24             	mov    %eax,(%esp)
  801cea:	e8 91 f0 ff ff       	call   800d80 <sys_env_set_trapframe>
  801cef:	85 c0                	test   %eax,%eax
  801cf1:	79 20                	jns    801d13 <spawn+0x533>
		panic("sys_env_set_trapframe: %e", r);
  801cf3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cf7:	c7 44 24 08 12 31 80 	movl   $0x803112,0x8(%esp)
  801cfe:	00 
  801cff:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  801d06:	00 
  801d07:	c7 04 24 e9 30 80 00 	movl   $0x8030e9,(%esp)
  801d0e:	e8 e1 e3 ff ff       	call   8000f4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d13:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801d1a:	00 
  801d1b:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801d21:	89 04 24             	mov    %eax,(%esp)
  801d24:	e8 04 f0 ff ff       	call   800d2d <sys_env_set_status>
  801d29:	85 c0                	test   %eax,%eax
  801d2b:	79 30                	jns    801d5d <spawn+0x57d>
		panic("sys_env_set_status: %e", r);
  801d2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d31:	c7 44 24 08 2c 31 80 	movl   $0x80312c,0x8(%esp)
  801d38:	00 
  801d39:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  801d40:	00 
  801d41:	c7 04 24 e9 30 80 00 	movl   $0x8030e9,(%esp)
  801d48:	e8 a7 e3 ff ff       	call   8000f4 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801d4d:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801d53:	eb 57                	jmp    801dac <spawn+0x5cc>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801d55:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801d5b:	eb 4f                	jmp    801dac <spawn+0x5cc>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801d5d:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801d63:	eb 47                	jmp    801dac <spawn+0x5cc>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801d65:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  801d6a:	eb 40                	jmp    801dac <spawn+0x5cc>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d6c:	89 c3                	mov    %eax,%ebx
  801d6e:	eb 06                	jmp    801d76 <spawn+0x596>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801d70:	89 c3                	mov    %eax,%ebx
  801d72:	eb 02                	jmp    801d76 <spawn+0x596>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801d74:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801d76:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801d7c:	89 04 24             	mov    %eax,(%esp)
  801d7f:	e8 1f ee ff ff       	call   800ba3 <sys_env_destroy>
	close(fd);
  801d84:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801d8a:	89 04 24             	mov    %eax,(%esp)
  801d8d:	e8 75 f3 ff ff       	call   801107 <close>
	return r;
  801d92:	89 d8                	mov    %ebx,%eax
  801d94:	eb 16                	jmp    801dac <spawn+0x5cc>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801d96:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801d9d:	00 
  801d9e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801da5:	e8 30 ef ff ff       	call   800cda <sys_page_unmap>
  801daa:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801dac:	81 c4 9c 02 00 00    	add    $0x29c,%esp
  801db2:	5b                   	pop    %ebx
  801db3:	5e                   	pop    %esi
  801db4:	5f                   	pop    %edi
  801db5:	5d                   	pop    %ebp
  801db6:	c3                   	ret    

00801db7 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801db7:	55                   	push   %ebp
  801db8:	89 e5                	mov    %esp,%ebp
  801dba:	56                   	push   %esi
  801dbb:	53                   	push   %ebx
  801dbc:	83 ec 10             	sub    $0x10,%esp
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801dbf:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801dc2:	ba 00 00 00 00       	mov    $0x0,%edx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801dc7:	eb 03                	jmp    801dcc <spawnl+0x15>
		argc++;
  801dc9:	83 c2 01             	add    $0x1,%edx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801dcc:	83 c0 04             	add    $0x4,%eax
  801dcf:	83 78 fc 00          	cmpl   $0x0,-0x4(%eax)
  801dd3:	75 f4                	jne    801dc9 <spawnl+0x12>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801dd5:	8d 04 95 1a 00 00 00 	lea    0x1a(,%edx,4),%eax
  801ddc:	83 e0 f0             	and    $0xfffffff0,%eax
  801ddf:	29 c4                	sub    %eax,%esp
  801de1:	8d 44 24 0b          	lea    0xb(%esp),%eax
  801de5:	c1 e8 02             	shr    $0x2,%eax
  801de8:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
  801def:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801df1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801df4:	89 0c 85 00 00 00 00 	mov    %ecx,0x0(,%eax,4)
	argv[argc+1] = NULL;
  801dfb:	c7 44 96 04 00 00 00 	movl   $0x0,0x4(%esi,%edx,4)
  801e02:	00 

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e03:	b8 00 00 00 00       	mov    $0x0,%eax
  801e08:	eb 0a                	jmp    801e14 <spawnl+0x5d>
		argv[i+1] = va_arg(vl, const char *);
  801e0a:	83 c0 01             	add    $0x1,%eax
  801e0d:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801e11:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e14:	39 d0                	cmp    %edx,%eax
  801e16:	75 f2                	jne    801e0a <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801e18:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1f:	89 04 24             	mov    %eax,(%esp)
  801e22:	e8 b9 f9 ff ff       	call   8017e0 <spawn>
}
  801e27:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e2a:	5b                   	pop    %ebx
  801e2b:	5e                   	pop    %esi
  801e2c:	5d                   	pop    %ebp
  801e2d:	c3                   	ret    
  801e2e:	66 90                	xchg   %ax,%ax

00801e30 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801e30:	55                   	push   %ebp
  801e31:	89 e5                	mov    %esp,%ebp
  801e33:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801e36:	c7 44 24 04 96 31 80 	movl   $0x803196,0x4(%esp)
  801e3d:	00 
  801e3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e41:	89 04 24             	mov    %eax,(%esp)
  801e44:	e8 ce e9 ff ff       	call   800817 <strcpy>
	return 0;
}
  801e49:	b8 00 00 00 00       	mov    $0x0,%eax
  801e4e:	c9                   	leave  
  801e4f:	c3                   	ret    

00801e50 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801e50:	55                   	push   %ebp
  801e51:	89 e5                	mov    %esp,%ebp
  801e53:	53                   	push   %ebx
  801e54:	83 ec 14             	sub    $0x14,%esp
  801e57:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801e5a:	89 1c 24             	mov    %ebx,(%esp)
  801e5d:	e8 2b 0b 00 00       	call   80298d <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801e62:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801e67:	83 f8 01             	cmp    $0x1,%eax
  801e6a:	75 0d                	jne    801e79 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801e6c:	8b 43 0c             	mov    0xc(%ebx),%eax
  801e6f:	89 04 24             	mov    %eax,(%esp)
  801e72:	e8 29 03 00 00       	call   8021a0 <nsipc_close>
  801e77:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  801e79:	89 d0                	mov    %edx,%eax
  801e7b:	83 c4 14             	add    $0x14,%esp
  801e7e:	5b                   	pop    %ebx
  801e7f:	5d                   	pop    %ebp
  801e80:	c3                   	ret    

00801e81 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801e81:	55                   	push   %ebp
  801e82:	89 e5                	mov    %esp,%ebp
  801e84:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801e87:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801e8e:	00 
  801e8f:	8b 45 10             	mov    0x10(%ebp),%eax
  801e92:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e96:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e99:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea0:	8b 40 0c             	mov    0xc(%eax),%eax
  801ea3:	89 04 24             	mov    %eax,(%esp)
  801ea6:	e8 f0 03 00 00       	call   80229b <nsipc_send>
}
  801eab:	c9                   	leave  
  801eac:	c3                   	ret    

00801ead <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801ead:	55                   	push   %ebp
  801eae:	89 e5                	mov    %esp,%ebp
  801eb0:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801eb3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801eba:	00 
  801ebb:	8b 45 10             	mov    0x10(%ebp),%eax
  801ebe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ec2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ecc:	8b 40 0c             	mov    0xc(%eax),%eax
  801ecf:	89 04 24             	mov    %eax,(%esp)
  801ed2:	e8 44 03 00 00       	call   80221b <nsipc_recv>
}
  801ed7:	c9                   	leave  
  801ed8:	c3                   	ret    

00801ed9 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801edf:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ee2:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ee6:	89 04 24             	mov    %eax,(%esp)
  801ee9:	e8 e8 f0 ff ff       	call   800fd6 <fd_lookup>
  801eee:	85 c0                	test   %eax,%eax
  801ef0:	78 17                	js     801f09 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef5:	8b 0d 20 40 80 00    	mov    0x804020,%ecx
  801efb:	39 08                	cmp    %ecx,(%eax)
  801efd:	75 05                	jne    801f04 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801eff:	8b 40 0c             	mov    0xc(%eax),%eax
  801f02:	eb 05                	jmp    801f09 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801f04:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801f09:	c9                   	leave  
  801f0a:	c3                   	ret    

00801f0b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801f0b:	55                   	push   %ebp
  801f0c:	89 e5                	mov    %esp,%ebp
  801f0e:	56                   	push   %esi
  801f0f:	53                   	push   %ebx
  801f10:	83 ec 20             	sub    $0x20,%esp
  801f13:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801f15:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f18:	89 04 24             	mov    %eax,(%esp)
  801f1b:	e8 67 f0 ff ff       	call   800f87 <fd_alloc>
  801f20:	89 c3                	mov    %eax,%ebx
  801f22:	85 c0                	test   %eax,%eax
  801f24:	78 21                	js     801f47 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801f26:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f2d:	00 
  801f2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f31:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f3c:	e8 f2 ec ff ff       	call   800c33 <sys_page_alloc>
  801f41:	89 c3                	mov    %eax,%ebx
  801f43:	85 c0                	test   %eax,%eax
  801f45:	79 0c                	jns    801f53 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  801f47:	89 34 24             	mov    %esi,(%esp)
  801f4a:	e8 51 02 00 00       	call   8021a0 <nsipc_close>
		return r;
  801f4f:	89 d8                	mov    %ebx,%eax
  801f51:	eb 20                	jmp    801f73 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801f53:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801f59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f5c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801f5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f61:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801f68:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801f6b:	89 14 24             	mov    %edx,(%esp)
  801f6e:	e8 ed ef ff ff       	call   800f60 <fd2num>
}
  801f73:	83 c4 20             	add    $0x20,%esp
  801f76:	5b                   	pop    %ebx
  801f77:	5e                   	pop    %esi
  801f78:	5d                   	pop    %ebp
  801f79:	c3                   	ret    

00801f7a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f7a:	55                   	push   %ebp
  801f7b:	89 e5                	mov    %esp,%ebp
  801f7d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f80:	8b 45 08             	mov    0x8(%ebp),%eax
  801f83:	e8 51 ff ff ff       	call   801ed9 <fd2sockid>
		return r;
  801f88:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f8a:	85 c0                	test   %eax,%eax
  801f8c:	78 23                	js     801fb1 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801f8e:	8b 55 10             	mov    0x10(%ebp),%edx
  801f91:	89 54 24 08          	mov    %edx,0x8(%esp)
  801f95:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f98:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f9c:	89 04 24             	mov    %eax,(%esp)
  801f9f:	e8 45 01 00 00       	call   8020e9 <nsipc_accept>
		return r;
  801fa4:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801fa6:	85 c0                	test   %eax,%eax
  801fa8:	78 07                	js     801fb1 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  801faa:	e8 5c ff ff ff       	call   801f0b <alloc_sockfd>
  801faf:	89 c1                	mov    %eax,%ecx
}
  801fb1:	89 c8                	mov    %ecx,%eax
  801fb3:	c9                   	leave  
  801fb4:	c3                   	ret    

00801fb5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801fb5:	55                   	push   %ebp
  801fb6:	89 e5                	mov    %esp,%ebp
  801fb8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fbe:	e8 16 ff ff ff       	call   801ed9 <fd2sockid>
  801fc3:	89 c2                	mov    %eax,%edx
  801fc5:	85 d2                	test   %edx,%edx
  801fc7:	78 16                	js     801fdf <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  801fc9:	8b 45 10             	mov    0x10(%ebp),%eax
  801fcc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fd0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd7:	89 14 24             	mov    %edx,(%esp)
  801fda:	e8 60 01 00 00       	call   80213f <nsipc_bind>
}
  801fdf:	c9                   	leave  
  801fe0:	c3                   	ret    

00801fe1 <shutdown>:

int
shutdown(int s, int how)
{
  801fe1:	55                   	push   %ebp
  801fe2:	89 e5                	mov    %esp,%ebp
  801fe4:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fe7:	8b 45 08             	mov    0x8(%ebp),%eax
  801fea:	e8 ea fe ff ff       	call   801ed9 <fd2sockid>
  801fef:	89 c2                	mov    %eax,%edx
  801ff1:	85 d2                	test   %edx,%edx
  801ff3:	78 0f                	js     802004 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801ff5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ffc:	89 14 24             	mov    %edx,(%esp)
  801fff:	e8 7a 01 00 00       	call   80217e <nsipc_shutdown>
}
  802004:	c9                   	leave  
  802005:	c3                   	ret    

00802006 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802006:	55                   	push   %ebp
  802007:	89 e5                	mov    %esp,%ebp
  802009:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80200c:	8b 45 08             	mov    0x8(%ebp),%eax
  80200f:	e8 c5 fe ff ff       	call   801ed9 <fd2sockid>
  802014:	89 c2                	mov    %eax,%edx
  802016:	85 d2                	test   %edx,%edx
  802018:	78 16                	js     802030 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  80201a:	8b 45 10             	mov    0x10(%ebp),%eax
  80201d:	89 44 24 08          	mov    %eax,0x8(%esp)
  802021:	8b 45 0c             	mov    0xc(%ebp),%eax
  802024:	89 44 24 04          	mov    %eax,0x4(%esp)
  802028:	89 14 24             	mov    %edx,(%esp)
  80202b:	e8 8a 01 00 00       	call   8021ba <nsipc_connect>
}
  802030:	c9                   	leave  
  802031:	c3                   	ret    

00802032 <listen>:

int
listen(int s, int backlog)
{
  802032:	55                   	push   %ebp
  802033:	89 e5                	mov    %esp,%ebp
  802035:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802038:	8b 45 08             	mov    0x8(%ebp),%eax
  80203b:	e8 99 fe ff ff       	call   801ed9 <fd2sockid>
  802040:	89 c2                	mov    %eax,%edx
  802042:	85 d2                	test   %edx,%edx
  802044:	78 0f                	js     802055 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  802046:	8b 45 0c             	mov    0xc(%ebp),%eax
  802049:	89 44 24 04          	mov    %eax,0x4(%esp)
  80204d:	89 14 24             	mov    %edx,(%esp)
  802050:	e8 a4 01 00 00       	call   8021f9 <nsipc_listen>
}
  802055:	c9                   	leave  
  802056:	c3                   	ret    

00802057 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802057:	55                   	push   %ebp
  802058:	89 e5                	mov    %esp,%ebp
  80205a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80205d:	8b 45 10             	mov    0x10(%ebp),%eax
  802060:	89 44 24 08          	mov    %eax,0x8(%esp)
  802064:	8b 45 0c             	mov    0xc(%ebp),%eax
  802067:	89 44 24 04          	mov    %eax,0x4(%esp)
  80206b:	8b 45 08             	mov    0x8(%ebp),%eax
  80206e:	89 04 24             	mov    %eax,(%esp)
  802071:	e8 98 02 00 00       	call   80230e <nsipc_socket>
  802076:	89 c2                	mov    %eax,%edx
  802078:	85 d2                	test   %edx,%edx
  80207a:	78 05                	js     802081 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  80207c:	e8 8a fe ff ff       	call   801f0b <alloc_sockfd>
}
  802081:	c9                   	leave  
  802082:	c3                   	ret    

00802083 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802083:	55                   	push   %ebp
  802084:	89 e5                	mov    %esp,%ebp
  802086:	53                   	push   %ebx
  802087:	83 ec 14             	sub    $0x14,%esp
  80208a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80208c:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802093:	75 11                	jne    8020a6 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802095:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80209c:	e8 b4 08 00 00       	call   802955 <ipc_find_env>
  8020a1:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8020a6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8020ad:	00 
  8020ae:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  8020b5:	00 
  8020b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020ba:	a1 04 50 80 00       	mov    0x805004,%eax
  8020bf:	89 04 24             	mov    %eax,(%esp)
  8020c2:	e8 23 08 00 00       	call   8028ea <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8020c7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020ce:	00 
  8020cf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8020d6:	00 
  8020d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020de:	e8 8d 07 00 00       	call   802870 <ipc_recv>
}
  8020e3:	83 c4 14             	add    $0x14,%esp
  8020e6:	5b                   	pop    %ebx
  8020e7:	5d                   	pop    %ebp
  8020e8:	c3                   	ret    

008020e9 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8020e9:	55                   	push   %ebp
  8020ea:	89 e5                	mov    %esp,%ebp
  8020ec:	56                   	push   %esi
  8020ed:	53                   	push   %ebx
  8020ee:	83 ec 10             	sub    $0x10,%esp
  8020f1:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8020f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8020fc:	8b 06                	mov    (%esi),%eax
  8020fe:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802103:	b8 01 00 00 00       	mov    $0x1,%eax
  802108:	e8 76 ff ff ff       	call   802083 <nsipc>
  80210d:	89 c3                	mov    %eax,%ebx
  80210f:	85 c0                	test   %eax,%eax
  802111:	78 23                	js     802136 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802113:	a1 10 70 80 00       	mov    0x807010,%eax
  802118:	89 44 24 08          	mov    %eax,0x8(%esp)
  80211c:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802123:	00 
  802124:	8b 45 0c             	mov    0xc(%ebp),%eax
  802127:	89 04 24             	mov    %eax,(%esp)
  80212a:	e8 85 e8 ff ff       	call   8009b4 <memmove>
		*addrlen = ret->ret_addrlen;
  80212f:	a1 10 70 80 00       	mov    0x807010,%eax
  802134:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  802136:	89 d8                	mov    %ebx,%eax
  802138:	83 c4 10             	add    $0x10,%esp
  80213b:	5b                   	pop    %ebx
  80213c:	5e                   	pop    %esi
  80213d:	5d                   	pop    %ebp
  80213e:	c3                   	ret    

0080213f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80213f:	55                   	push   %ebp
  802140:	89 e5                	mov    %esp,%ebp
  802142:	53                   	push   %ebx
  802143:	83 ec 14             	sub    $0x14,%esp
  802146:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802149:	8b 45 08             	mov    0x8(%ebp),%eax
  80214c:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802151:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802155:	8b 45 0c             	mov    0xc(%ebp),%eax
  802158:	89 44 24 04          	mov    %eax,0x4(%esp)
  80215c:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802163:	e8 4c e8 ff ff       	call   8009b4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802168:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80216e:	b8 02 00 00 00       	mov    $0x2,%eax
  802173:	e8 0b ff ff ff       	call   802083 <nsipc>
}
  802178:	83 c4 14             	add    $0x14,%esp
  80217b:	5b                   	pop    %ebx
  80217c:	5d                   	pop    %ebp
  80217d:	c3                   	ret    

0080217e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80217e:	55                   	push   %ebp
  80217f:	89 e5                	mov    %esp,%ebp
  802181:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802184:	8b 45 08             	mov    0x8(%ebp),%eax
  802187:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80218c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80218f:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802194:	b8 03 00 00 00       	mov    $0x3,%eax
  802199:	e8 e5 fe ff ff       	call   802083 <nsipc>
}
  80219e:	c9                   	leave  
  80219f:	c3                   	ret    

008021a0 <nsipc_close>:

int
nsipc_close(int s)
{
  8021a0:	55                   	push   %ebp
  8021a1:	89 e5                	mov    %esp,%ebp
  8021a3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8021a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a9:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8021ae:	b8 04 00 00 00       	mov    $0x4,%eax
  8021b3:	e8 cb fe ff ff       	call   802083 <nsipc>
}
  8021b8:	c9                   	leave  
  8021b9:	c3                   	ret    

008021ba <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8021ba:	55                   	push   %ebp
  8021bb:	89 e5                	mov    %esp,%ebp
  8021bd:	53                   	push   %ebx
  8021be:	83 ec 14             	sub    $0x14,%esp
  8021c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8021c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8021c7:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8021cc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021d7:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8021de:	e8 d1 e7 ff ff       	call   8009b4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8021e3:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8021e9:	b8 05 00 00 00       	mov    $0x5,%eax
  8021ee:	e8 90 fe ff ff       	call   802083 <nsipc>
}
  8021f3:	83 c4 14             	add    $0x14,%esp
  8021f6:	5b                   	pop    %ebx
  8021f7:	5d                   	pop    %ebp
  8021f8:	c3                   	ret    

008021f9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8021f9:	55                   	push   %ebp
  8021fa:	89 e5                	mov    %esp,%ebp
  8021fc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8021ff:	8b 45 08             	mov    0x8(%ebp),%eax
  802202:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802207:	8b 45 0c             	mov    0xc(%ebp),%eax
  80220a:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  80220f:	b8 06 00 00 00       	mov    $0x6,%eax
  802214:	e8 6a fe ff ff       	call   802083 <nsipc>
}
  802219:	c9                   	leave  
  80221a:	c3                   	ret    

0080221b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80221b:	55                   	push   %ebp
  80221c:	89 e5                	mov    %esp,%ebp
  80221e:	56                   	push   %esi
  80221f:	53                   	push   %ebx
  802220:	83 ec 10             	sub    $0x10,%esp
  802223:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802226:	8b 45 08             	mov    0x8(%ebp),%eax
  802229:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  80222e:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802234:	8b 45 14             	mov    0x14(%ebp),%eax
  802237:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80223c:	b8 07 00 00 00       	mov    $0x7,%eax
  802241:	e8 3d fe ff ff       	call   802083 <nsipc>
  802246:	89 c3                	mov    %eax,%ebx
  802248:	85 c0                	test   %eax,%eax
  80224a:	78 46                	js     802292 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  80224c:	39 f0                	cmp    %esi,%eax
  80224e:	7f 07                	jg     802257 <nsipc_recv+0x3c>
  802250:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802255:	7e 24                	jle    80227b <nsipc_recv+0x60>
  802257:	c7 44 24 0c a2 31 80 	movl   $0x8031a2,0xc(%esp)
  80225e:	00 
  80225f:	c7 44 24 08 a3 30 80 	movl   $0x8030a3,0x8(%esp)
  802266:	00 
  802267:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80226e:	00 
  80226f:	c7 04 24 b7 31 80 00 	movl   $0x8031b7,(%esp)
  802276:	e8 79 de ff ff       	call   8000f4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80227b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80227f:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802286:	00 
  802287:	8b 45 0c             	mov    0xc(%ebp),%eax
  80228a:	89 04 24             	mov    %eax,(%esp)
  80228d:	e8 22 e7 ff ff       	call   8009b4 <memmove>
	}

	return r;
}
  802292:	89 d8                	mov    %ebx,%eax
  802294:	83 c4 10             	add    $0x10,%esp
  802297:	5b                   	pop    %ebx
  802298:	5e                   	pop    %esi
  802299:	5d                   	pop    %ebp
  80229a:	c3                   	ret    

0080229b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80229b:	55                   	push   %ebp
  80229c:	89 e5                	mov    %esp,%ebp
  80229e:	53                   	push   %ebx
  80229f:	83 ec 14             	sub    $0x14,%esp
  8022a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8022a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8022a8:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8022ad:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8022b3:	7e 24                	jle    8022d9 <nsipc_send+0x3e>
  8022b5:	c7 44 24 0c c3 31 80 	movl   $0x8031c3,0xc(%esp)
  8022bc:	00 
  8022bd:	c7 44 24 08 a3 30 80 	movl   $0x8030a3,0x8(%esp)
  8022c4:	00 
  8022c5:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8022cc:	00 
  8022cd:	c7 04 24 b7 31 80 00 	movl   $0x8031b7,(%esp)
  8022d4:	e8 1b de ff ff       	call   8000f4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8022d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022e4:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  8022eb:	e8 c4 e6 ff ff       	call   8009b4 <memmove>
	nsipcbuf.send.req_size = size;
  8022f0:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8022f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8022f9:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8022fe:	b8 08 00 00 00       	mov    $0x8,%eax
  802303:	e8 7b fd ff ff       	call   802083 <nsipc>
}
  802308:	83 c4 14             	add    $0x14,%esp
  80230b:	5b                   	pop    %ebx
  80230c:	5d                   	pop    %ebp
  80230d:	c3                   	ret    

0080230e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80230e:	55                   	push   %ebp
  80230f:	89 e5                	mov    %esp,%ebp
  802311:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802314:	8b 45 08             	mov    0x8(%ebp),%eax
  802317:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  80231c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80231f:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802324:	8b 45 10             	mov    0x10(%ebp),%eax
  802327:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  80232c:	b8 09 00 00 00       	mov    $0x9,%eax
  802331:	e8 4d fd ff ff       	call   802083 <nsipc>
}
  802336:	c9                   	leave  
  802337:	c3                   	ret    

00802338 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802338:	55                   	push   %ebp
  802339:	89 e5                	mov    %esp,%ebp
  80233b:	56                   	push   %esi
  80233c:	53                   	push   %ebx
  80233d:	83 ec 10             	sub    $0x10,%esp
  802340:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802343:	8b 45 08             	mov    0x8(%ebp),%eax
  802346:	89 04 24             	mov    %eax,(%esp)
  802349:	e8 22 ec ff ff       	call   800f70 <fd2data>
  80234e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802350:	c7 44 24 04 cf 31 80 	movl   $0x8031cf,0x4(%esp)
  802357:	00 
  802358:	89 1c 24             	mov    %ebx,(%esp)
  80235b:	e8 b7 e4 ff ff       	call   800817 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802360:	8b 46 04             	mov    0x4(%esi),%eax
  802363:	2b 06                	sub    (%esi),%eax
  802365:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80236b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802372:	00 00 00 
	stat->st_dev = &devpipe;
  802375:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  80237c:	40 80 00 
	return 0;
}
  80237f:	b8 00 00 00 00       	mov    $0x0,%eax
  802384:	83 c4 10             	add    $0x10,%esp
  802387:	5b                   	pop    %ebx
  802388:	5e                   	pop    %esi
  802389:	5d                   	pop    %ebp
  80238a:	c3                   	ret    

0080238b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80238b:	55                   	push   %ebp
  80238c:	89 e5                	mov    %esp,%ebp
  80238e:	53                   	push   %ebx
  80238f:	83 ec 14             	sub    $0x14,%esp
  802392:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802395:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802399:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023a0:	e8 35 e9 ff ff       	call   800cda <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8023a5:	89 1c 24             	mov    %ebx,(%esp)
  8023a8:	e8 c3 eb ff ff       	call   800f70 <fd2data>
  8023ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023b8:	e8 1d e9 ff ff       	call   800cda <sys_page_unmap>
}
  8023bd:	83 c4 14             	add    $0x14,%esp
  8023c0:	5b                   	pop    %ebx
  8023c1:	5d                   	pop    %ebp
  8023c2:	c3                   	ret    

008023c3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8023c3:	55                   	push   %ebp
  8023c4:	89 e5                	mov    %esp,%ebp
  8023c6:	57                   	push   %edi
  8023c7:	56                   	push   %esi
  8023c8:	53                   	push   %ebx
  8023c9:	83 ec 2c             	sub    $0x2c,%esp
  8023cc:	89 c6                	mov    %eax,%esi
  8023ce:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8023d1:	a1 08 50 80 00       	mov    0x805008,%eax
  8023d6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8023d9:	89 34 24             	mov    %esi,(%esp)
  8023dc:	e8 ac 05 00 00       	call   80298d <pageref>
  8023e1:	89 c7                	mov    %eax,%edi
  8023e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023e6:	89 04 24             	mov    %eax,(%esp)
  8023e9:	e8 9f 05 00 00       	call   80298d <pageref>
  8023ee:	39 c7                	cmp    %eax,%edi
  8023f0:	0f 94 c2             	sete   %dl
  8023f3:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8023f6:	8b 0d 08 50 80 00    	mov    0x805008,%ecx
  8023fc:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8023ff:	39 fb                	cmp    %edi,%ebx
  802401:	74 21                	je     802424 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802403:	84 d2                	test   %dl,%dl
  802405:	74 ca                	je     8023d1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802407:	8b 51 58             	mov    0x58(%ecx),%edx
  80240a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80240e:	89 54 24 08          	mov    %edx,0x8(%esp)
  802412:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802416:	c7 04 24 d6 31 80 00 	movl   $0x8031d6,(%esp)
  80241d:	e8 cb dd ff ff       	call   8001ed <cprintf>
  802422:	eb ad                	jmp    8023d1 <_pipeisclosed+0xe>
	}
}
  802424:	83 c4 2c             	add    $0x2c,%esp
  802427:	5b                   	pop    %ebx
  802428:	5e                   	pop    %esi
  802429:	5f                   	pop    %edi
  80242a:	5d                   	pop    %ebp
  80242b:	c3                   	ret    

0080242c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80242c:	55                   	push   %ebp
  80242d:	89 e5                	mov    %esp,%ebp
  80242f:	57                   	push   %edi
  802430:	56                   	push   %esi
  802431:	53                   	push   %ebx
  802432:	83 ec 1c             	sub    $0x1c,%esp
  802435:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802438:	89 34 24             	mov    %esi,(%esp)
  80243b:	e8 30 eb ff ff       	call   800f70 <fd2data>
  802440:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802442:	bf 00 00 00 00       	mov    $0x0,%edi
  802447:	eb 45                	jmp    80248e <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802449:	89 da                	mov    %ebx,%edx
  80244b:	89 f0                	mov    %esi,%eax
  80244d:	e8 71 ff ff ff       	call   8023c3 <_pipeisclosed>
  802452:	85 c0                	test   %eax,%eax
  802454:	75 41                	jne    802497 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802456:	e8 b9 e7 ff ff       	call   800c14 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80245b:	8b 43 04             	mov    0x4(%ebx),%eax
  80245e:	8b 0b                	mov    (%ebx),%ecx
  802460:	8d 51 20             	lea    0x20(%ecx),%edx
  802463:	39 d0                	cmp    %edx,%eax
  802465:	73 e2                	jae    802449 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802467:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80246a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80246e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802471:	99                   	cltd   
  802472:	c1 ea 1b             	shr    $0x1b,%edx
  802475:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802478:	83 e1 1f             	and    $0x1f,%ecx
  80247b:	29 d1                	sub    %edx,%ecx
  80247d:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  802481:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  802485:	83 c0 01             	add    $0x1,%eax
  802488:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80248b:	83 c7 01             	add    $0x1,%edi
  80248e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802491:	75 c8                	jne    80245b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802493:	89 f8                	mov    %edi,%eax
  802495:	eb 05                	jmp    80249c <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802497:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80249c:	83 c4 1c             	add    $0x1c,%esp
  80249f:	5b                   	pop    %ebx
  8024a0:	5e                   	pop    %esi
  8024a1:	5f                   	pop    %edi
  8024a2:	5d                   	pop    %ebp
  8024a3:	c3                   	ret    

008024a4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8024a4:	55                   	push   %ebp
  8024a5:	89 e5                	mov    %esp,%ebp
  8024a7:	57                   	push   %edi
  8024a8:	56                   	push   %esi
  8024a9:	53                   	push   %ebx
  8024aa:	83 ec 1c             	sub    $0x1c,%esp
  8024ad:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8024b0:	89 3c 24             	mov    %edi,(%esp)
  8024b3:	e8 b8 ea ff ff       	call   800f70 <fd2data>
  8024b8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024ba:	be 00 00 00 00       	mov    $0x0,%esi
  8024bf:	eb 3d                	jmp    8024fe <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8024c1:	85 f6                	test   %esi,%esi
  8024c3:	74 04                	je     8024c9 <devpipe_read+0x25>
				return i;
  8024c5:	89 f0                	mov    %esi,%eax
  8024c7:	eb 43                	jmp    80250c <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8024c9:	89 da                	mov    %ebx,%edx
  8024cb:	89 f8                	mov    %edi,%eax
  8024cd:	e8 f1 fe ff ff       	call   8023c3 <_pipeisclosed>
  8024d2:	85 c0                	test   %eax,%eax
  8024d4:	75 31                	jne    802507 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8024d6:	e8 39 e7 ff ff       	call   800c14 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8024db:	8b 03                	mov    (%ebx),%eax
  8024dd:	3b 43 04             	cmp    0x4(%ebx),%eax
  8024e0:	74 df                	je     8024c1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8024e2:	99                   	cltd   
  8024e3:	c1 ea 1b             	shr    $0x1b,%edx
  8024e6:	01 d0                	add    %edx,%eax
  8024e8:	83 e0 1f             	and    $0x1f,%eax
  8024eb:	29 d0                	sub    %edx,%eax
  8024ed:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8024f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024f5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8024f8:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024fb:	83 c6 01             	add    $0x1,%esi
  8024fe:	3b 75 10             	cmp    0x10(%ebp),%esi
  802501:	75 d8                	jne    8024db <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802503:	89 f0                	mov    %esi,%eax
  802505:	eb 05                	jmp    80250c <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802507:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80250c:	83 c4 1c             	add    $0x1c,%esp
  80250f:	5b                   	pop    %ebx
  802510:	5e                   	pop    %esi
  802511:	5f                   	pop    %edi
  802512:	5d                   	pop    %ebp
  802513:	c3                   	ret    

00802514 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802514:	55                   	push   %ebp
  802515:	89 e5                	mov    %esp,%ebp
  802517:	56                   	push   %esi
  802518:	53                   	push   %ebx
  802519:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80251c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80251f:	89 04 24             	mov    %eax,(%esp)
  802522:	e8 60 ea ff ff       	call   800f87 <fd_alloc>
  802527:	89 c2                	mov    %eax,%edx
  802529:	85 d2                	test   %edx,%edx
  80252b:	0f 88 4d 01 00 00    	js     80267e <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802531:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802538:	00 
  802539:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80253c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802540:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802547:	e8 e7 e6 ff ff       	call   800c33 <sys_page_alloc>
  80254c:	89 c2                	mov    %eax,%edx
  80254e:	85 d2                	test   %edx,%edx
  802550:	0f 88 28 01 00 00    	js     80267e <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802556:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802559:	89 04 24             	mov    %eax,(%esp)
  80255c:	e8 26 ea ff ff       	call   800f87 <fd_alloc>
  802561:	89 c3                	mov    %eax,%ebx
  802563:	85 c0                	test   %eax,%eax
  802565:	0f 88 fe 00 00 00    	js     802669 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80256b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802572:	00 
  802573:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802576:	89 44 24 04          	mov    %eax,0x4(%esp)
  80257a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802581:	e8 ad e6 ff ff       	call   800c33 <sys_page_alloc>
  802586:	89 c3                	mov    %eax,%ebx
  802588:	85 c0                	test   %eax,%eax
  80258a:	0f 88 d9 00 00 00    	js     802669 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802590:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802593:	89 04 24             	mov    %eax,(%esp)
  802596:	e8 d5 e9 ff ff       	call   800f70 <fd2data>
  80259b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80259d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8025a4:	00 
  8025a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025b0:	e8 7e e6 ff ff       	call   800c33 <sys_page_alloc>
  8025b5:	89 c3                	mov    %eax,%ebx
  8025b7:	85 c0                	test   %eax,%eax
  8025b9:	0f 88 97 00 00 00    	js     802656 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8025c2:	89 04 24             	mov    %eax,(%esp)
  8025c5:	e8 a6 e9 ff ff       	call   800f70 <fd2data>
  8025ca:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8025d1:	00 
  8025d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025d6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8025dd:	00 
  8025de:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025e9:	e8 99 e6 ff ff       	call   800c87 <sys_page_map>
  8025ee:	89 c3                	mov    %eax,%ebx
  8025f0:	85 c0                	test   %eax,%eax
  8025f2:	78 52                	js     802646 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8025f4:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8025fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025fd:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8025ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802602:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802609:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80260f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802612:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802614:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802617:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80261e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802621:	89 04 24             	mov    %eax,(%esp)
  802624:	e8 37 e9 ff ff       	call   800f60 <fd2num>
  802629:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80262c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80262e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802631:	89 04 24             	mov    %eax,(%esp)
  802634:	e8 27 e9 ff ff       	call   800f60 <fd2num>
  802639:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80263c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80263f:	b8 00 00 00 00       	mov    $0x0,%eax
  802644:	eb 38                	jmp    80267e <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  802646:	89 74 24 04          	mov    %esi,0x4(%esp)
  80264a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802651:	e8 84 e6 ff ff       	call   800cda <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802656:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802659:	89 44 24 04          	mov    %eax,0x4(%esp)
  80265d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802664:	e8 71 e6 ff ff       	call   800cda <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802669:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80266c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802670:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802677:	e8 5e e6 ff ff       	call   800cda <sys_page_unmap>
  80267c:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  80267e:	83 c4 30             	add    $0x30,%esp
  802681:	5b                   	pop    %ebx
  802682:	5e                   	pop    %esi
  802683:	5d                   	pop    %ebp
  802684:	c3                   	ret    

00802685 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802685:	55                   	push   %ebp
  802686:	89 e5                	mov    %esp,%ebp
  802688:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80268b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80268e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802692:	8b 45 08             	mov    0x8(%ebp),%eax
  802695:	89 04 24             	mov    %eax,(%esp)
  802698:	e8 39 e9 ff ff       	call   800fd6 <fd_lookup>
  80269d:	89 c2                	mov    %eax,%edx
  80269f:	85 d2                	test   %edx,%edx
  8026a1:	78 15                	js     8026b8 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8026a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026a6:	89 04 24             	mov    %eax,(%esp)
  8026a9:	e8 c2 e8 ff ff       	call   800f70 <fd2data>
	return _pipeisclosed(fd, p);
  8026ae:	89 c2                	mov    %eax,%edx
  8026b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026b3:	e8 0b fd ff ff       	call   8023c3 <_pipeisclosed>
}
  8026b8:	c9                   	leave  
  8026b9:	c3                   	ret    
  8026ba:	66 90                	xchg   %ax,%ax
  8026bc:	66 90                	xchg   %ax,%ax
  8026be:	66 90                	xchg   %ax,%ax

008026c0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8026c0:	55                   	push   %ebp
  8026c1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8026c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8026c8:	5d                   	pop    %ebp
  8026c9:	c3                   	ret    

008026ca <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8026ca:	55                   	push   %ebp
  8026cb:	89 e5                	mov    %esp,%ebp
  8026cd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8026d0:	c7 44 24 04 ee 31 80 	movl   $0x8031ee,0x4(%esp)
  8026d7:	00 
  8026d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026db:	89 04 24             	mov    %eax,(%esp)
  8026de:	e8 34 e1 ff ff       	call   800817 <strcpy>
	return 0;
}
  8026e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8026e8:	c9                   	leave  
  8026e9:	c3                   	ret    

008026ea <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8026ea:	55                   	push   %ebp
  8026eb:	89 e5                	mov    %esp,%ebp
  8026ed:	57                   	push   %edi
  8026ee:	56                   	push   %esi
  8026ef:	53                   	push   %ebx
  8026f0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8026f6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8026fb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802701:	eb 31                	jmp    802734 <devcons_write+0x4a>
		m = n - tot;
  802703:	8b 75 10             	mov    0x10(%ebp),%esi
  802706:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802708:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80270b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802710:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802713:	89 74 24 08          	mov    %esi,0x8(%esp)
  802717:	03 45 0c             	add    0xc(%ebp),%eax
  80271a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80271e:	89 3c 24             	mov    %edi,(%esp)
  802721:	e8 8e e2 ff ff       	call   8009b4 <memmove>
		sys_cputs(buf, m);
  802726:	89 74 24 04          	mov    %esi,0x4(%esp)
  80272a:	89 3c 24             	mov    %edi,(%esp)
  80272d:	e8 34 e4 ff ff       	call   800b66 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802732:	01 f3                	add    %esi,%ebx
  802734:	89 d8                	mov    %ebx,%eax
  802736:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802739:	72 c8                	jb     802703 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80273b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802741:	5b                   	pop    %ebx
  802742:	5e                   	pop    %esi
  802743:	5f                   	pop    %edi
  802744:	5d                   	pop    %ebp
  802745:	c3                   	ret    

00802746 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802746:	55                   	push   %ebp
  802747:	89 e5                	mov    %esp,%ebp
  802749:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80274c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802751:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802755:	75 07                	jne    80275e <devcons_read+0x18>
  802757:	eb 2a                	jmp    802783 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802759:	e8 b6 e4 ff ff       	call   800c14 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80275e:	66 90                	xchg   %ax,%ax
  802760:	e8 1f e4 ff ff       	call   800b84 <sys_cgetc>
  802765:	85 c0                	test   %eax,%eax
  802767:	74 f0                	je     802759 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802769:	85 c0                	test   %eax,%eax
  80276b:	78 16                	js     802783 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80276d:	83 f8 04             	cmp    $0x4,%eax
  802770:	74 0c                	je     80277e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802772:	8b 55 0c             	mov    0xc(%ebp),%edx
  802775:	88 02                	mov    %al,(%edx)
	return 1;
  802777:	b8 01 00 00 00       	mov    $0x1,%eax
  80277c:	eb 05                	jmp    802783 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80277e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802783:	c9                   	leave  
  802784:	c3                   	ret    

00802785 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802785:	55                   	push   %ebp
  802786:	89 e5                	mov    %esp,%ebp
  802788:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80278b:	8b 45 08             	mov    0x8(%ebp),%eax
  80278e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802791:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802798:	00 
  802799:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80279c:	89 04 24             	mov    %eax,(%esp)
  80279f:	e8 c2 e3 ff ff       	call   800b66 <sys_cputs>
}
  8027a4:	c9                   	leave  
  8027a5:	c3                   	ret    

008027a6 <getchar>:

int
getchar(void)
{
  8027a6:	55                   	push   %ebp
  8027a7:	89 e5                	mov    %esp,%ebp
  8027a9:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8027ac:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8027b3:	00 
  8027b4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8027b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027c2:	e8 a3 ea ff ff       	call   80126a <read>
	if (r < 0)
  8027c7:	85 c0                	test   %eax,%eax
  8027c9:	78 0f                	js     8027da <getchar+0x34>
		return r;
	if (r < 1)
  8027cb:	85 c0                	test   %eax,%eax
  8027cd:	7e 06                	jle    8027d5 <getchar+0x2f>
		return -E_EOF;
	return c;
  8027cf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8027d3:	eb 05                	jmp    8027da <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8027d5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8027da:	c9                   	leave  
  8027db:	c3                   	ret    

008027dc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8027dc:	55                   	push   %ebp
  8027dd:	89 e5                	mov    %esp,%ebp
  8027df:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8027e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8027e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8027ec:	89 04 24             	mov    %eax,(%esp)
  8027ef:	e8 e2 e7 ff ff       	call   800fd6 <fd_lookup>
  8027f4:	85 c0                	test   %eax,%eax
  8027f6:	78 11                	js     802809 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8027f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027fb:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802801:	39 10                	cmp    %edx,(%eax)
  802803:	0f 94 c0             	sete   %al
  802806:	0f b6 c0             	movzbl %al,%eax
}
  802809:	c9                   	leave  
  80280a:	c3                   	ret    

0080280b <opencons>:

int
opencons(void)
{
  80280b:	55                   	push   %ebp
  80280c:	89 e5                	mov    %esp,%ebp
  80280e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802811:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802814:	89 04 24             	mov    %eax,(%esp)
  802817:	e8 6b e7 ff ff       	call   800f87 <fd_alloc>
		return r;
  80281c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80281e:	85 c0                	test   %eax,%eax
  802820:	78 40                	js     802862 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802822:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802829:	00 
  80282a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80282d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802831:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802838:	e8 f6 e3 ff ff       	call   800c33 <sys_page_alloc>
		return r;
  80283d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80283f:	85 c0                	test   %eax,%eax
  802841:	78 1f                	js     802862 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802843:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802849:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80284c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80284e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802851:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802858:	89 04 24             	mov    %eax,(%esp)
  80285b:	e8 00 e7 ff ff       	call   800f60 <fd2num>
  802860:	89 c2                	mov    %eax,%edx
}
  802862:	89 d0                	mov    %edx,%eax
  802864:	c9                   	leave  
  802865:	c3                   	ret    
  802866:	66 90                	xchg   %ax,%ax
  802868:	66 90                	xchg   %ax,%ax
  80286a:	66 90                	xchg   %ax,%ax
  80286c:	66 90                	xchg   %ax,%ax
  80286e:	66 90                	xchg   %ax,%ax

00802870 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802870:	55                   	push   %ebp
  802871:	89 e5                	mov    %esp,%ebp
  802873:	56                   	push   %esi
  802874:	53                   	push   %ebx
  802875:	83 ec 10             	sub    $0x10,%esp
  802878:	8b 75 08             	mov    0x8(%ebp),%esi
  80287b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80287e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  802881:	85 c0                	test   %eax,%eax
  802883:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802888:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  80288b:	89 04 24             	mov    %eax,(%esp)
  80288e:	e8 b6 e5 ff ff       	call   800e49 <sys_ipc_recv>

	if(ret < 0) {
  802893:	85 c0                	test   %eax,%eax
  802895:	79 16                	jns    8028ad <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  802897:	85 f6                	test   %esi,%esi
  802899:	74 06                	je     8028a1 <ipc_recv+0x31>
  80289b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  8028a1:	85 db                	test   %ebx,%ebx
  8028a3:	74 3e                	je     8028e3 <ipc_recv+0x73>
  8028a5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8028ab:	eb 36                	jmp    8028e3 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  8028ad:	e8 43 e3 ff ff       	call   800bf5 <sys_getenvid>
  8028b2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8028b7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8028ba:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8028bf:	a3 08 50 80 00       	mov    %eax,0x805008

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8028c4:	85 f6                	test   %esi,%esi
  8028c6:	74 05                	je     8028cd <ipc_recv+0x5d>
  8028c8:	8b 40 74             	mov    0x74(%eax),%eax
  8028cb:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8028cd:	85 db                	test   %ebx,%ebx
  8028cf:	74 0a                	je     8028db <ipc_recv+0x6b>
  8028d1:	a1 08 50 80 00       	mov    0x805008,%eax
  8028d6:	8b 40 78             	mov    0x78(%eax),%eax
  8028d9:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  8028db:	a1 08 50 80 00       	mov    0x805008,%eax
  8028e0:	8b 40 70             	mov    0x70(%eax),%eax
}
  8028e3:	83 c4 10             	add    $0x10,%esp
  8028e6:	5b                   	pop    %ebx
  8028e7:	5e                   	pop    %esi
  8028e8:	5d                   	pop    %ebp
  8028e9:	c3                   	ret    

008028ea <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8028ea:	55                   	push   %ebp
  8028eb:	89 e5                	mov    %esp,%ebp
  8028ed:	57                   	push   %edi
  8028ee:	56                   	push   %esi
  8028ef:	53                   	push   %ebx
  8028f0:	83 ec 1c             	sub    $0x1c,%esp
  8028f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8028f6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8028f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  8028fc:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  8028fe:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802903:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  802906:	8b 45 14             	mov    0x14(%ebp),%eax
  802909:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80290d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802911:	89 74 24 04          	mov    %esi,0x4(%esp)
  802915:	89 3c 24             	mov    %edi,(%esp)
  802918:	e8 09 e5 ff ff       	call   800e26 <sys_ipc_try_send>

		if(ret >= 0) break;
  80291d:	85 c0                	test   %eax,%eax
  80291f:	79 2c                	jns    80294d <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  802921:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802924:	74 20                	je     802946 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  802926:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80292a:	c7 44 24 08 fc 31 80 	movl   $0x8031fc,0x8(%esp)
  802931:	00 
  802932:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  802939:	00 
  80293a:	c7 04 24 2c 32 80 00 	movl   $0x80322c,(%esp)
  802941:	e8 ae d7 ff ff       	call   8000f4 <_panic>
		}
		sys_yield();
  802946:	e8 c9 e2 ff ff       	call   800c14 <sys_yield>
	}
  80294b:	eb b9                	jmp    802906 <ipc_send+0x1c>
}
  80294d:	83 c4 1c             	add    $0x1c,%esp
  802950:	5b                   	pop    %ebx
  802951:	5e                   	pop    %esi
  802952:	5f                   	pop    %edi
  802953:	5d                   	pop    %ebp
  802954:	c3                   	ret    

00802955 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802955:	55                   	push   %ebp
  802956:	89 e5                	mov    %esp,%ebp
  802958:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80295b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802960:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802963:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802969:	8b 52 50             	mov    0x50(%edx),%edx
  80296c:	39 ca                	cmp    %ecx,%edx
  80296e:	75 0d                	jne    80297d <ipc_find_env+0x28>
			return envs[i].env_id;
  802970:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802973:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802978:	8b 40 40             	mov    0x40(%eax),%eax
  80297b:	eb 0e                	jmp    80298b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80297d:	83 c0 01             	add    $0x1,%eax
  802980:	3d 00 04 00 00       	cmp    $0x400,%eax
  802985:	75 d9                	jne    802960 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802987:	66 b8 00 00          	mov    $0x0,%ax
}
  80298b:	5d                   	pop    %ebp
  80298c:	c3                   	ret    

0080298d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80298d:	55                   	push   %ebp
  80298e:	89 e5                	mov    %esp,%ebp
  802990:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802993:	89 d0                	mov    %edx,%eax
  802995:	c1 e8 16             	shr    $0x16,%eax
  802998:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80299f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8029a4:	f6 c1 01             	test   $0x1,%cl
  8029a7:	74 1d                	je     8029c6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8029a9:	c1 ea 0c             	shr    $0xc,%edx
  8029ac:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8029b3:	f6 c2 01             	test   $0x1,%dl
  8029b6:	74 0e                	je     8029c6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8029b8:	c1 ea 0c             	shr    $0xc,%edx
  8029bb:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8029c2:	ef 
  8029c3:	0f b7 c0             	movzwl %ax,%eax
}
  8029c6:	5d                   	pop    %ebp
  8029c7:	c3                   	ret    
  8029c8:	66 90                	xchg   %ax,%ax
  8029ca:	66 90                	xchg   %ax,%ax
  8029cc:	66 90                	xchg   %ax,%ax
  8029ce:	66 90                	xchg   %ax,%ax

008029d0 <__udivdi3>:
  8029d0:	55                   	push   %ebp
  8029d1:	57                   	push   %edi
  8029d2:	56                   	push   %esi
  8029d3:	83 ec 0c             	sub    $0xc,%esp
  8029d6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8029da:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8029de:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8029e2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8029e6:	85 c0                	test   %eax,%eax
  8029e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8029ec:	89 ea                	mov    %ebp,%edx
  8029ee:	89 0c 24             	mov    %ecx,(%esp)
  8029f1:	75 2d                	jne    802a20 <__udivdi3+0x50>
  8029f3:	39 e9                	cmp    %ebp,%ecx
  8029f5:	77 61                	ja     802a58 <__udivdi3+0x88>
  8029f7:	85 c9                	test   %ecx,%ecx
  8029f9:	89 ce                	mov    %ecx,%esi
  8029fb:	75 0b                	jne    802a08 <__udivdi3+0x38>
  8029fd:	b8 01 00 00 00       	mov    $0x1,%eax
  802a02:	31 d2                	xor    %edx,%edx
  802a04:	f7 f1                	div    %ecx
  802a06:	89 c6                	mov    %eax,%esi
  802a08:	31 d2                	xor    %edx,%edx
  802a0a:	89 e8                	mov    %ebp,%eax
  802a0c:	f7 f6                	div    %esi
  802a0e:	89 c5                	mov    %eax,%ebp
  802a10:	89 f8                	mov    %edi,%eax
  802a12:	f7 f6                	div    %esi
  802a14:	89 ea                	mov    %ebp,%edx
  802a16:	83 c4 0c             	add    $0xc,%esp
  802a19:	5e                   	pop    %esi
  802a1a:	5f                   	pop    %edi
  802a1b:	5d                   	pop    %ebp
  802a1c:	c3                   	ret    
  802a1d:	8d 76 00             	lea    0x0(%esi),%esi
  802a20:	39 e8                	cmp    %ebp,%eax
  802a22:	77 24                	ja     802a48 <__udivdi3+0x78>
  802a24:	0f bd e8             	bsr    %eax,%ebp
  802a27:	83 f5 1f             	xor    $0x1f,%ebp
  802a2a:	75 3c                	jne    802a68 <__udivdi3+0x98>
  802a2c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802a30:	39 34 24             	cmp    %esi,(%esp)
  802a33:	0f 86 9f 00 00 00    	jbe    802ad8 <__udivdi3+0x108>
  802a39:	39 d0                	cmp    %edx,%eax
  802a3b:	0f 82 97 00 00 00    	jb     802ad8 <__udivdi3+0x108>
  802a41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a48:	31 d2                	xor    %edx,%edx
  802a4a:	31 c0                	xor    %eax,%eax
  802a4c:	83 c4 0c             	add    $0xc,%esp
  802a4f:	5e                   	pop    %esi
  802a50:	5f                   	pop    %edi
  802a51:	5d                   	pop    %ebp
  802a52:	c3                   	ret    
  802a53:	90                   	nop
  802a54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a58:	89 f8                	mov    %edi,%eax
  802a5a:	f7 f1                	div    %ecx
  802a5c:	31 d2                	xor    %edx,%edx
  802a5e:	83 c4 0c             	add    $0xc,%esp
  802a61:	5e                   	pop    %esi
  802a62:	5f                   	pop    %edi
  802a63:	5d                   	pop    %ebp
  802a64:	c3                   	ret    
  802a65:	8d 76 00             	lea    0x0(%esi),%esi
  802a68:	89 e9                	mov    %ebp,%ecx
  802a6a:	8b 3c 24             	mov    (%esp),%edi
  802a6d:	d3 e0                	shl    %cl,%eax
  802a6f:	89 c6                	mov    %eax,%esi
  802a71:	b8 20 00 00 00       	mov    $0x20,%eax
  802a76:	29 e8                	sub    %ebp,%eax
  802a78:	89 c1                	mov    %eax,%ecx
  802a7a:	d3 ef                	shr    %cl,%edi
  802a7c:	89 e9                	mov    %ebp,%ecx
  802a7e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802a82:	8b 3c 24             	mov    (%esp),%edi
  802a85:	09 74 24 08          	or     %esi,0x8(%esp)
  802a89:	89 d6                	mov    %edx,%esi
  802a8b:	d3 e7                	shl    %cl,%edi
  802a8d:	89 c1                	mov    %eax,%ecx
  802a8f:	89 3c 24             	mov    %edi,(%esp)
  802a92:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802a96:	d3 ee                	shr    %cl,%esi
  802a98:	89 e9                	mov    %ebp,%ecx
  802a9a:	d3 e2                	shl    %cl,%edx
  802a9c:	89 c1                	mov    %eax,%ecx
  802a9e:	d3 ef                	shr    %cl,%edi
  802aa0:	09 d7                	or     %edx,%edi
  802aa2:	89 f2                	mov    %esi,%edx
  802aa4:	89 f8                	mov    %edi,%eax
  802aa6:	f7 74 24 08          	divl   0x8(%esp)
  802aaa:	89 d6                	mov    %edx,%esi
  802aac:	89 c7                	mov    %eax,%edi
  802aae:	f7 24 24             	mull   (%esp)
  802ab1:	39 d6                	cmp    %edx,%esi
  802ab3:	89 14 24             	mov    %edx,(%esp)
  802ab6:	72 30                	jb     802ae8 <__udivdi3+0x118>
  802ab8:	8b 54 24 04          	mov    0x4(%esp),%edx
  802abc:	89 e9                	mov    %ebp,%ecx
  802abe:	d3 e2                	shl    %cl,%edx
  802ac0:	39 c2                	cmp    %eax,%edx
  802ac2:	73 05                	jae    802ac9 <__udivdi3+0xf9>
  802ac4:	3b 34 24             	cmp    (%esp),%esi
  802ac7:	74 1f                	je     802ae8 <__udivdi3+0x118>
  802ac9:	89 f8                	mov    %edi,%eax
  802acb:	31 d2                	xor    %edx,%edx
  802acd:	e9 7a ff ff ff       	jmp    802a4c <__udivdi3+0x7c>
  802ad2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802ad8:	31 d2                	xor    %edx,%edx
  802ada:	b8 01 00 00 00       	mov    $0x1,%eax
  802adf:	e9 68 ff ff ff       	jmp    802a4c <__udivdi3+0x7c>
  802ae4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ae8:	8d 47 ff             	lea    -0x1(%edi),%eax
  802aeb:	31 d2                	xor    %edx,%edx
  802aed:	83 c4 0c             	add    $0xc,%esp
  802af0:	5e                   	pop    %esi
  802af1:	5f                   	pop    %edi
  802af2:	5d                   	pop    %ebp
  802af3:	c3                   	ret    
  802af4:	66 90                	xchg   %ax,%ax
  802af6:	66 90                	xchg   %ax,%ax
  802af8:	66 90                	xchg   %ax,%ax
  802afa:	66 90                	xchg   %ax,%ax
  802afc:	66 90                	xchg   %ax,%ax
  802afe:	66 90                	xchg   %ax,%ax

00802b00 <__umoddi3>:
  802b00:	55                   	push   %ebp
  802b01:	57                   	push   %edi
  802b02:	56                   	push   %esi
  802b03:	83 ec 14             	sub    $0x14,%esp
  802b06:	8b 44 24 28          	mov    0x28(%esp),%eax
  802b0a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802b0e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802b12:	89 c7                	mov    %eax,%edi
  802b14:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b18:	8b 44 24 30          	mov    0x30(%esp),%eax
  802b1c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802b20:	89 34 24             	mov    %esi,(%esp)
  802b23:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802b27:	85 c0                	test   %eax,%eax
  802b29:	89 c2                	mov    %eax,%edx
  802b2b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802b2f:	75 17                	jne    802b48 <__umoddi3+0x48>
  802b31:	39 fe                	cmp    %edi,%esi
  802b33:	76 4b                	jbe    802b80 <__umoddi3+0x80>
  802b35:	89 c8                	mov    %ecx,%eax
  802b37:	89 fa                	mov    %edi,%edx
  802b39:	f7 f6                	div    %esi
  802b3b:	89 d0                	mov    %edx,%eax
  802b3d:	31 d2                	xor    %edx,%edx
  802b3f:	83 c4 14             	add    $0x14,%esp
  802b42:	5e                   	pop    %esi
  802b43:	5f                   	pop    %edi
  802b44:	5d                   	pop    %ebp
  802b45:	c3                   	ret    
  802b46:	66 90                	xchg   %ax,%ax
  802b48:	39 f8                	cmp    %edi,%eax
  802b4a:	77 54                	ja     802ba0 <__umoddi3+0xa0>
  802b4c:	0f bd e8             	bsr    %eax,%ebp
  802b4f:	83 f5 1f             	xor    $0x1f,%ebp
  802b52:	75 5c                	jne    802bb0 <__umoddi3+0xb0>
  802b54:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802b58:	39 3c 24             	cmp    %edi,(%esp)
  802b5b:	0f 87 e7 00 00 00    	ja     802c48 <__umoddi3+0x148>
  802b61:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802b65:	29 f1                	sub    %esi,%ecx
  802b67:	19 c7                	sbb    %eax,%edi
  802b69:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802b6d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802b71:	8b 44 24 08          	mov    0x8(%esp),%eax
  802b75:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802b79:	83 c4 14             	add    $0x14,%esp
  802b7c:	5e                   	pop    %esi
  802b7d:	5f                   	pop    %edi
  802b7e:	5d                   	pop    %ebp
  802b7f:	c3                   	ret    
  802b80:	85 f6                	test   %esi,%esi
  802b82:	89 f5                	mov    %esi,%ebp
  802b84:	75 0b                	jne    802b91 <__umoddi3+0x91>
  802b86:	b8 01 00 00 00       	mov    $0x1,%eax
  802b8b:	31 d2                	xor    %edx,%edx
  802b8d:	f7 f6                	div    %esi
  802b8f:	89 c5                	mov    %eax,%ebp
  802b91:	8b 44 24 04          	mov    0x4(%esp),%eax
  802b95:	31 d2                	xor    %edx,%edx
  802b97:	f7 f5                	div    %ebp
  802b99:	89 c8                	mov    %ecx,%eax
  802b9b:	f7 f5                	div    %ebp
  802b9d:	eb 9c                	jmp    802b3b <__umoddi3+0x3b>
  802b9f:	90                   	nop
  802ba0:	89 c8                	mov    %ecx,%eax
  802ba2:	89 fa                	mov    %edi,%edx
  802ba4:	83 c4 14             	add    $0x14,%esp
  802ba7:	5e                   	pop    %esi
  802ba8:	5f                   	pop    %edi
  802ba9:	5d                   	pop    %ebp
  802baa:	c3                   	ret    
  802bab:	90                   	nop
  802bac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802bb0:	8b 04 24             	mov    (%esp),%eax
  802bb3:	be 20 00 00 00       	mov    $0x20,%esi
  802bb8:	89 e9                	mov    %ebp,%ecx
  802bba:	29 ee                	sub    %ebp,%esi
  802bbc:	d3 e2                	shl    %cl,%edx
  802bbe:	89 f1                	mov    %esi,%ecx
  802bc0:	d3 e8                	shr    %cl,%eax
  802bc2:	89 e9                	mov    %ebp,%ecx
  802bc4:	89 44 24 04          	mov    %eax,0x4(%esp)
  802bc8:	8b 04 24             	mov    (%esp),%eax
  802bcb:	09 54 24 04          	or     %edx,0x4(%esp)
  802bcf:	89 fa                	mov    %edi,%edx
  802bd1:	d3 e0                	shl    %cl,%eax
  802bd3:	89 f1                	mov    %esi,%ecx
  802bd5:	89 44 24 08          	mov    %eax,0x8(%esp)
  802bd9:	8b 44 24 10          	mov    0x10(%esp),%eax
  802bdd:	d3 ea                	shr    %cl,%edx
  802bdf:	89 e9                	mov    %ebp,%ecx
  802be1:	d3 e7                	shl    %cl,%edi
  802be3:	89 f1                	mov    %esi,%ecx
  802be5:	d3 e8                	shr    %cl,%eax
  802be7:	89 e9                	mov    %ebp,%ecx
  802be9:	09 f8                	or     %edi,%eax
  802beb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  802bef:	f7 74 24 04          	divl   0x4(%esp)
  802bf3:	d3 e7                	shl    %cl,%edi
  802bf5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802bf9:	89 d7                	mov    %edx,%edi
  802bfb:	f7 64 24 08          	mull   0x8(%esp)
  802bff:	39 d7                	cmp    %edx,%edi
  802c01:	89 c1                	mov    %eax,%ecx
  802c03:	89 14 24             	mov    %edx,(%esp)
  802c06:	72 2c                	jb     802c34 <__umoddi3+0x134>
  802c08:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  802c0c:	72 22                	jb     802c30 <__umoddi3+0x130>
  802c0e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802c12:	29 c8                	sub    %ecx,%eax
  802c14:	19 d7                	sbb    %edx,%edi
  802c16:	89 e9                	mov    %ebp,%ecx
  802c18:	89 fa                	mov    %edi,%edx
  802c1a:	d3 e8                	shr    %cl,%eax
  802c1c:	89 f1                	mov    %esi,%ecx
  802c1e:	d3 e2                	shl    %cl,%edx
  802c20:	89 e9                	mov    %ebp,%ecx
  802c22:	d3 ef                	shr    %cl,%edi
  802c24:	09 d0                	or     %edx,%eax
  802c26:	89 fa                	mov    %edi,%edx
  802c28:	83 c4 14             	add    $0x14,%esp
  802c2b:	5e                   	pop    %esi
  802c2c:	5f                   	pop    %edi
  802c2d:	5d                   	pop    %ebp
  802c2e:	c3                   	ret    
  802c2f:	90                   	nop
  802c30:	39 d7                	cmp    %edx,%edi
  802c32:	75 da                	jne    802c0e <__umoddi3+0x10e>
  802c34:	8b 14 24             	mov    (%esp),%edx
  802c37:	89 c1                	mov    %eax,%ecx
  802c39:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  802c3d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802c41:	eb cb                	jmp    802c0e <__umoddi3+0x10e>
  802c43:	90                   	nop
  802c44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802c48:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  802c4c:	0f 82 0f ff ff ff    	jb     802b61 <__umoddi3+0x61>
  802c52:	e9 1a ff ff ff       	jmp    802b71 <__umoddi3+0x71>
