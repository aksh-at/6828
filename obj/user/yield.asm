
obj/user/yield.debug:     file format elf32-i386


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
  80002c:	e8 6d 00 00 00       	call   80009e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 08 40 80 00       	mov    0x804008,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	89 44 24 04          	mov    %eax,0x4(%esp)
  800046:	c7 04 24 20 26 80 00 	movl   $0x802620,(%esp)
  80004d:	e8 50 01 00 00       	call   8001a2 <cprintf>
	for (i = 0; i < 5; i++) {
  800052:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800057:	e8 68 0b 00 00       	call   800bc4 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005c:	a1 08 40 80 00       	mov    0x804008,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800061:	8b 40 48             	mov    0x48(%eax),%eax
  800064:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800068:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006c:	c7 04 24 40 26 80 00 	movl   $0x802640,(%esp)
  800073:	e8 2a 01 00 00       	call   8001a2 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800078:	83 c3 01             	add    $0x1,%ebx
  80007b:	83 fb 05             	cmp    $0x5,%ebx
  80007e:	75 d7                	jne    800057 <umain+0x24>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  800080:	a1 08 40 80 00       	mov    0x804008,%eax
  800085:	8b 40 48             	mov    0x48(%eax),%eax
  800088:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008c:	c7 04 24 6c 26 80 00 	movl   $0x80266c,(%esp)
  800093:	e8 0a 01 00 00       	call   8001a2 <cprintf>
}
  800098:	83 c4 14             	add    $0x14,%esp
  80009b:	5b                   	pop    %ebx
  80009c:	5d                   	pop    %ebp
  80009d:	c3                   	ret    

0080009e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	56                   	push   %esi
  8000a2:	53                   	push   %ebx
  8000a3:	83 ec 10             	sub    $0x10,%esp
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ac:	e8 f4 0a 00 00       	call   800ba5 <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x30>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000d2:	89 1c 24             	mov    %ebx,(%esp)
  8000d5:	e8 59 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000da:	e8 07 00 00 00       	call   8000e6 <exit>
}
  8000df:	83 c4 10             	add    $0x10,%esp
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5d                   	pop    %ebp
  8000e5:	c3                   	ret    

008000e6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000ec:	e8 f9 0f 00 00       	call   8010ea <close_all>
	sys_env_destroy(0);
  8000f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f8:	e8 56 0a 00 00       	call   800b53 <sys_env_destroy>
}
  8000fd:	c9                   	leave  
  8000fe:	c3                   	ret    

008000ff <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	53                   	push   %ebx
  800103:	83 ec 14             	sub    $0x14,%esp
  800106:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800109:	8b 13                	mov    (%ebx),%edx
  80010b:	8d 42 01             	lea    0x1(%edx),%eax
  80010e:	89 03                	mov    %eax,(%ebx)
  800110:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800113:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800117:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011c:	75 19                	jne    800137 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80011e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800125:	00 
  800126:	8d 43 08             	lea    0x8(%ebx),%eax
  800129:	89 04 24             	mov    %eax,(%esp)
  80012c:	e8 e5 09 00 00       	call   800b16 <sys_cputs>
		b->idx = 0;
  800131:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800137:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013b:	83 c4 14             	add    $0x14,%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5d                   	pop    %ebp
  800140:	c3                   	ret    

00800141 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80014a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800151:	00 00 00 
	b.cnt = 0;
  800154:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800161:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800165:	8b 45 08             	mov    0x8(%ebp),%eax
  800168:	89 44 24 08          	mov    %eax,0x8(%esp)
  80016c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800172:	89 44 24 04          	mov    %eax,0x4(%esp)
  800176:	c7 04 24 ff 00 80 00 	movl   $0x8000ff,(%esp)
  80017d:	e8 ac 01 00 00       	call   80032e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800182:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800188:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800192:	89 04 24             	mov    %eax,(%esp)
  800195:	e8 7c 09 00 00       	call   800b16 <sys_cputs>

	return b.cnt;
}
  80019a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a0:	c9                   	leave  
  8001a1:	c3                   	ret    

008001a2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a2:	55                   	push   %ebp
  8001a3:	89 e5                	mov    %esp,%ebp
  8001a5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001af:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b2:	89 04 24             	mov    %eax,(%esp)
  8001b5:	e8 87 ff ff ff       	call   800141 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    
  8001bc:	66 90                	xchg   %ax,%ax
  8001be:	66 90                	xchg   %ax,%ax

008001c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	57                   	push   %edi
  8001c4:	56                   	push   %esi
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 3c             	sub    $0x3c,%esp
  8001c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001cc:	89 d7                	mov    %edx,%edi
  8001ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d7:	89 c3                	mov    %eax,%ebx
  8001d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001df:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001ed:	39 d9                	cmp    %ebx,%ecx
  8001ef:	72 05                	jb     8001f6 <printnum+0x36>
  8001f1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001f4:	77 69                	ja     80025f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001f9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8001fd:	83 ee 01             	sub    $0x1,%esi
  800200:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800204:	89 44 24 08          	mov    %eax,0x8(%esp)
  800208:	8b 44 24 08          	mov    0x8(%esp),%eax
  80020c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800210:	89 c3                	mov    %eax,%ebx
  800212:	89 d6                	mov    %edx,%esi
  800214:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800217:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80021a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80021e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800222:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800225:	89 04 24             	mov    %eax,(%esp)
  800228:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80022b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022f:	e8 4c 21 00 00       	call   802380 <__udivdi3>
  800234:	89 d9                	mov    %ebx,%ecx
  800236:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80023a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80023e:	89 04 24             	mov    %eax,(%esp)
  800241:	89 54 24 04          	mov    %edx,0x4(%esp)
  800245:	89 fa                	mov    %edi,%edx
  800247:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80024a:	e8 71 ff ff ff       	call   8001c0 <printnum>
  80024f:	eb 1b                	jmp    80026c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800251:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800255:	8b 45 18             	mov    0x18(%ebp),%eax
  800258:	89 04 24             	mov    %eax,(%esp)
  80025b:	ff d3                	call   *%ebx
  80025d:	eb 03                	jmp    800262 <printnum+0xa2>
  80025f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800262:	83 ee 01             	sub    $0x1,%esi
  800265:	85 f6                	test   %esi,%esi
  800267:	7f e8                	jg     800251 <printnum+0x91>
  800269:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80026c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800270:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800274:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800277:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80027a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80027e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800282:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800285:	89 04 24             	mov    %eax,(%esp)
  800288:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80028b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028f:	e8 1c 22 00 00       	call   8024b0 <__umoddi3>
  800294:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800298:	0f be 80 95 26 80 00 	movsbl 0x802695(%eax),%eax
  80029f:	89 04 24             	mov    %eax,(%esp)
  8002a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002a5:	ff d0                	call   *%eax
}
  8002a7:	83 c4 3c             	add    $0x3c,%esp
  8002aa:	5b                   	pop    %ebx
  8002ab:	5e                   	pop    %esi
  8002ac:	5f                   	pop    %edi
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    

008002af <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b2:	83 fa 01             	cmp    $0x1,%edx
  8002b5:	7e 0e                	jle    8002c5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b7:	8b 10                	mov    (%eax),%edx
  8002b9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002bc:	89 08                	mov    %ecx,(%eax)
  8002be:	8b 02                	mov    (%edx),%eax
  8002c0:	8b 52 04             	mov    0x4(%edx),%edx
  8002c3:	eb 22                	jmp    8002e7 <getuint+0x38>
	else if (lflag)
  8002c5:	85 d2                	test   %edx,%edx
  8002c7:	74 10                	je     8002d9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c9:	8b 10                	mov    (%eax),%edx
  8002cb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ce:	89 08                	mov    %ecx,(%eax)
  8002d0:	8b 02                	mov    (%edx),%eax
  8002d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d7:	eb 0e                	jmp    8002e7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d9:	8b 10                	mov    (%eax),%edx
  8002db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002de:	89 08                	mov    %ecx,(%eax)
  8002e0:	8b 02                	mov    (%edx),%eax
  8002e2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    

008002e9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
  8002ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ef:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f3:	8b 10                	mov    (%eax),%edx
  8002f5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f8:	73 0a                	jae    800304 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002fa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002fd:	89 08                	mov    %ecx,(%eax)
  8002ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800302:	88 02                	mov    %al,(%edx)
}
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80030c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800313:	8b 45 10             	mov    0x10(%ebp),%eax
  800316:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80031d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800321:	8b 45 08             	mov    0x8(%ebp),%eax
  800324:	89 04 24             	mov    %eax,(%esp)
  800327:	e8 02 00 00 00       	call   80032e <vprintfmt>
	va_end(ap);
}
  80032c:	c9                   	leave  
  80032d:	c3                   	ret    

0080032e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	57                   	push   %edi
  800332:	56                   	push   %esi
  800333:	53                   	push   %ebx
  800334:	83 ec 3c             	sub    $0x3c,%esp
  800337:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80033a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80033d:	eb 14                	jmp    800353 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80033f:	85 c0                	test   %eax,%eax
  800341:	0f 84 b3 03 00 00    	je     8006fa <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800347:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80034b:	89 04 24             	mov    %eax,(%esp)
  80034e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800351:	89 f3                	mov    %esi,%ebx
  800353:	8d 73 01             	lea    0x1(%ebx),%esi
  800356:	0f b6 03             	movzbl (%ebx),%eax
  800359:	83 f8 25             	cmp    $0x25,%eax
  80035c:	75 e1                	jne    80033f <vprintfmt+0x11>
  80035e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800362:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800369:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800370:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800377:	ba 00 00 00 00       	mov    $0x0,%edx
  80037c:	eb 1d                	jmp    80039b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800380:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800384:	eb 15                	jmp    80039b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800386:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800388:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80038c:	eb 0d                	jmp    80039b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80038e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800391:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800394:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80039e:	0f b6 0e             	movzbl (%esi),%ecx
  8003a1:	0f b6 c1             	movzbl %cl,%eax
  8003a4:	83 e9 23             	sub    $0x23,%ecx
  8003a7:	80 f9 55             	cmp    $0x55,%cl
  8003aa:	0f 87 2a 03 00 00    	ja     8006da <vprintfmt+0x3ac>
  8003b0:	0f b6 c9             	movzbl %cl,%ecx
  8003b3:	ff 24 8d e0 27 80 00 	jmp    *0x8027e0(,%ecx,4)
  8003ba:	89 de                	mov    %ebx,%esi
  8003bc:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c1:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003c4:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8003c8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003cb:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003ce:	83 fb 09             	cmp    $0x9,%ebx
  8003d1:	77 36                	ja     800409 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d3:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d6:	eb e9                	jmp    8003c1 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003db:	8d 48 04             	lea    0x4(%eax),%ecx
  8003de:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e1:	8b 00                	mov    (%eax),%eax
  8003e3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e8:	eb 22                	jmp    80040c <vprintfmt+0xde>
  8003ea:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8003ed:	85 c9                	test   %ecx,%ecx
  8003ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f4:	0f 49 c1             	cmovns %ecx,%eax
  8003f7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	89 de                	mov    %ebx,%esi
  8003fc:	eb 9d                	jmp    80039b <vprintfmt+0x6d>
  8003fe:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800400:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800407:	eb 92                	jmp    80039b <vprintfmt+0x6d>
  800409:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80040c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800410:	79 89                	jns    80039b <vprintfmt+0x6d>
  800412:	e9 77 ff ff ff       	jmp    80038e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800417:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80041c:	e9 7a ff ff ff       	jmp    80039b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800421:	8b 45 14             	mov    0x14(%ebp),%eax
  800424:	8d 50 04             	lea    0x4(%eax),%edx
  800427:	89 55 14             	mov    %edx,0x14(%ebp)
  80042a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80042e:	8b 00                	mov    (%eax),%eax
  800430:	89 04 24             	mov    %eax,(%esp)
  800433:	ff 55 08             	call   *0x8(%ebp)
			break;
  800436:	e9 18 ff ff ff       	jmp    800353 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80043b:	8b 45 14             	mov    0x14(%ebp),%eax
  80043e:	8d 50 04             	lea    0x4(%eax),%edx
  800441:	89 55 14             	mov    %edx,0x14(%ebp)
  800444:	8b 00                	mov    (%eax),%eax
  800446:	99                   	cltd   
  800447:	31 d0                	xor    %edx,%eax
  800449:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044b:	83 f8 0f             	cmp    $0xf,%eax
  80044e:	7f 0b                	jg     80045b <vprintfmt+0x12d>
  800450:	8b 14 85 40 29 80 00 	mov    0x802940(,%eax,4),%edx
  800457:	85 d2                	test   %edx,%edx
  800459:	75 20                	jne    80047b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80045b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80045f:	c7 44 24 08 ad 26 80 	movl   $0x8026ad,0x8(%esp)
  800466:	00 
  800467:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80046b:	8b 45 08             	mov    0x8(%ebp),%eax
  80046e:	89 04 24             	mov    %eax,(%esp)
  800471:	e8 90 fe ff ff       	call   800306 <printfmt>
  800476:	e9 d8 fe ff ff       	jmp    800353 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80047b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80047f:	c7 44 24 08 75 2a 80 	movl   $0x802a75,0x8(%esp)
  800486:	00 
  800487:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80048b:	8b 45 08             	mov    0x8(%ebp),%eax
  80048e:	89 04 24             	mov    %eax,(%esp)
  800491:	e8 70 fe ff ff       	call   800306 <printfmt>
  800496:	e9 b8 fe ff ff       	jmp    800353 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80049e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004a1:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a7:	8d 50 04             	lea    0x4(%eax),%edx
  8004aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ad:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004af:	85 f6                	test   %esi,%esi
  8004b1:	b8 a6 26 80 00       	mov    $0x8026a6,%eax
  8004b6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8004b9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004bd:	0f 84 97 00 00 00    	je     80055a <vprintfmt+0x22c>
  8004c3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8004c7:	0f 8e 9b 00 00 00    	jle    800568 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004d1:	89 34 24             	mov    %esi,(%esp)
  8004d4:	e8 cf 02 00 00       	call   8007a8 <strnlen>
  8004d9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004dc:	29 c2                	sub    %eax,%edx
  8004de:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8004e1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004e8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8004eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ee:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004f1:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f3:	eb 0f                	jmp    800504 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8004f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004fc:	89 04 24             	mov    %eax,(%esp)
  8004ff:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800501:	83 eb 01             	sub    $0x1,%ebx
  800504:	85 db                	test   %ebx,%ebx
  800506:	7f ed                	jg     8004f5 <vprintfmt+0x1c7>
  800508:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80050b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80050e:	85 d2                	test   %edx,%edx
  800510:	b8 00 00 00 00       	mov    $0x0,%eax
  800515:	0f 49 c2             	cmovns %edx,%eax
  800518:	29 c2                	sub    %eax,%edx
  80051a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80051d:	89 d7                	mov    %edx,%edi
  80051f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800522:	eb 50                	jmp    800574 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800524:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800528:	74 1e                	je     800548 <vprintfmt+0x21a>
  80052a:	0f be d2             	movsbl %dl,%edx
  80052d:	83 ea 20             	sub    $0x20,%edx
  800530:	83 fa 5e             	cmp    $0x5e,%edx
  800533:	76 13                	jbe    800548 <vprintfmt+0x21a>
					putch('?', putdat);
  800535:	8b 45 0c             	mov    0xc(%ebp),%eax
  800538:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800543:	ff 55 08             	call   *0x8(%ebp)
  800546:	eb 0d                	jmp    800555 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800548:	8b 55 0c             	mov    0xc(%ebp),%edx
  80054b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80054f:	89 04 24             	mov    %eax,(%esp)
  800552:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800555:	83 ef 01             	sub    $0x1,%edi
  800558:	eb 1a                	jmp    800574 <vprintfmt+0x246>
  80055a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80055d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800560:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800563:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800566:	eb 0c                	jmp    800574 <vprintfmt+0x246>
  800568:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80056b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80056e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800571:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800574:	83 c6 01             	add    $0x1,%esi
  800577:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80057b:	0f be c2             	movsbl %dl,%eax
  80057e:	85 c0                	test   %eax,%eax
  800580:	74 27                	je     8005a9 <vprintfmt+0x27b>
  800582:	85 db                	test   %ebx,%ebx
  800584:	78 9e                	js     800524 <vprintfmt+0x1f6>
  800586:	83 eb 01             	sub    $0x1,%ebx
  800589:	79 99                	jns    800524 <vprintfmt+0x1f6>
  80058b:	89 f8                	mov    %edi,%eax
  80058d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800590:	8b 75 08             	mov    0x8(%ebp),%esi
  800593:	89 c3                	mov    %eax,%ebx
  800595:	eb 1a                	jmp    8005b1 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800597:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80059b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005a2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a4:	83 eb 01             	sub    $0x1,%ebx
  8005a7:	eb 08                	jmp    8005b1 <vprintfmt+0x283>
  8005a9:	89 fb                	mov    %edi,%ebx
  8005ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ae:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005b1:	85 db                	test   %ebx,%ebx
  8005b3:	7f e2                	jg     800597 <vprintfmt+0x269>
  8005b5:	89 75 08             	mov    %esi,0x8(%ebp)
  8005b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005bb:	e9 93 fd ff ff       	jmp    800353 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c0:	83 fa 01             	cmp    $0x1,%edx
  8005c3:	7e 16                	jle    8005db <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	8d 50 08             	lea    0x8(%eax),%edx
  8005cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ce:	8b 50 04             	mov    0x4(%eax),%edx
  8005d1:	8b 00                	mov    (%eax),%eax
  8005d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005d9:	eb 32                	jmp    80060d <vprintfmt+0x2df>
	else if (lflag)
  8005db:	85 d2                	test   %edx,%edx
  8005dd:	74 18                	je     8005f7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8d 50 04             	lea    0x4(%eax),%edx
  8005e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e8:	8b 30                	mov    (%eax),%esi
  8005ea:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005ed:	89 f0                	mov    %esi,%eax
  8005ef:	c1 f8 1f             	sar    $0x1f,%eax
  8005f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005f5:	eb 16                	jmp    80060d <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8d 50 04             	lea    0x4(%eax),%edx
  8005fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800600:	8b 30                	mov    (%eax),%esi
  800602:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800605:	89 f0                	mov    %esi,%eax
  800607:	c1 f8 1f             	sar    $0x1f,%eax
  80060a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80060d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800610:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800613:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800618:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80061c:	0f 89 80 00 00 00    	jns    8006a2 <vprintfmt+0x374>
				putch('-', putdat);
  800622:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800626:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80062d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800630:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800633:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800636:	f7 d8                	neg    %eax
  800638:	83 d2 00             	adc    $0x0,%edx
  80063b:	f7 da                	neg    %edx
			}
			base = 10;
  80063d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800642:	eb 5e                	jmp    8006a2 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800644:	8d 45 14             	lea    0x14(%ebp),%eax
  800647:	e8 63 fc ff ff       	call   8002af <getuint>
			base = 10;
  80064c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800651:	eb 4f                	jmp    8006a2 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800653:	8d 45 14             	lea    0x14(%ebp),%eax
  800656:	e8 54 fc ff ff       	call   8002af <getuint>
			base = 8;
  80065b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800660:	eb 40                	jmp    8006a2 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800662:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800666:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80066d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800670:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800674:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80067b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8d 50 04             	lea    0x4(%eax),%edx
  800684:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800687:	8b 00                	mov    (%eax),%eax
  800689:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80068e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800693:	eb 0d                	jmp    8006a2 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800695:	8d 45 14             	lea    0x14(%ebp),%eax
  800698:	e8 12 fc ff ff       	call   8002af <getuint>
			base = 16;
  80069d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a2:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8006a6:	89 74 24 10          	mov    %esi,0x10(%esp)
  8006aa:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006ad:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006b1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006b5:	89 04 24             	mov    %eax,(%esp)
  8006b8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006bc:	89 fa                	mov    %edi,%edx
  8006be:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c1:	e8 fa fa ff ff       	call   8001c0 <printnum>
			break;
  8006c6:	e9 88 fc ff ff       	jmp    800353 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006cb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006cf:	89 04 24             	mov    %eax,(%esp)
  8006d2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006d5:	e9 79 fc ff ff       	jmp    800353 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006de:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006e5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e8:	89 f3                	mov    %esi,%ebx
  8006ea:	eb 03                	jmp    8006ef <vprintfmt+0x3c1>
  8006ec:	83 eb 01             	sub    $0x1,%ebx
  8006ef:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006f3:	75 f7                	jne    8006ec <vprintfmt+0x3be>
  8006f5:	e9 59 fc ff ff       	jmp    800353 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8006fa:	83 c4 3c             	add    $0x3c,%esp
  8006fd:	5b                   	pop    %ebx
  8006fe:	5e                   	pop    %esi
  8006ff:	5f                   	pop    %edi
  800700:	5d                   	pop    %ebp
  800701:	c3                   	ret    

00800702 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
  800705:	83 ec 28             	sub    $0x28,%esp
  800708:	8b 45 08             	mov    0x8(%ebp),%eax
  80070b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80070e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800711:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800715:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800718:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80071f:	85 c0                	test   %eax,%eax
  800721:	74 30                	je     800753 <vsnprintf+0x51>
  800723:	85 d2                	test   %edx,%edx
  800725:	7e 2c                	jle    800753 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800727:	8b 45 14             	mov    0x14(%ebp),%eax
  80072a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80072e:	8b 45 10             	mov    0x10(%ebp),%eax
  800731:	89 44 24 08          	mov    %eax,0x8(%esp)
  800735:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800738:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073c:	c7 04 24 e9 02 80 00 	movl   $0x8002e9,(%esp)
  800743:	e8 e6 fb ff ff       	call   80032e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800748:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80074b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80074e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800751:	eb 05                	jmp    800758 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800753:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800758:	c9                   	leave  
  800759:	c3                   	ret    

0080075a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800760:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800763:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800767:	8b 45 10             	mov    0x10(%ebp),%eax
  80076a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80076e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800771:	89 44 24 04          	mov    %eax,0x4(%esp)
  800775:	8b 45 08             	mov    0x8(%ebp),%eax
  800778:	89 04 24             	mov    %eax,(%esp)
  80077b:	e8 82 ff ff ff       	call   800702 <vsnprintf>
	va_end(ap);

	return rc;
}
  800780:	c9                   	leave  
  800781:	c3                   	ret    
  800782:	66 90                	xchg   %ax,%ax
  800784:	66 90                	xchg   %ax,%ax
  800786:	66 90                	xchg   %ax,%ax
  800788:	66 90                	xchg   %ax,%ax
  80078a:	66 90                	xchg   %ax,%ax
  80078c:	66 90                	xchg   %ax,%ax
  80078e:	66 90                	xchg   %ax,%ax

00800790 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800796:	b8 00 00 00 00       	mov    $0x0,%eax
  80079b:	eb 03                	jmp    8007a0 <strlen+0x10>
		n++;
  80079d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a4:	75 f7                	jne    80079d <strlen+0xd>
		n++;
	return n;
}
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ae:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b6:	eb 03                	jmp    8007bb <strnlen+0x13>
		n++;
  8007b8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bb:	39 d0                	cmp    %edx,%eax
  8007bd:	74 06                	je     8007c5 <strnlen+0x1d>
  8007bf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007c3:	75 f3                	jne    8007b8 <strnlen+0x10>
		n++;
	return n;
}
  8007c5:	5d                   	pop    %ebp
  8007c6:	c3                   	ret    

008007c7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	53                   	push   %ebx
  8007cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d1:	89 c2                	mov    %eax,%edx
  8007d3:	83 c2 01             	add    $0x1,%edx
  8007d6:	83 c1 01             	add    $0x1,%ecx
  8007d9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007dd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007e0:	84 db                	test   %bl,%bl
  8007e2:	75 ef                	jne    8007d3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007e4:	5b                   	pop    %ebx
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	53                   	push   %ebx
  8007eb:	83 ec 08             	sub    $0x8,%esp
  8007ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f1:	89 1c 24             	mov    %ebx,(%esp)
  8007f4:	e8 97 ff ff ff       	call   800790 <strlen>
	strcpy(dst + len, src);
  8007f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800800:	01 d8                	add    %ebx,%eax
  800802:	89 04 24             	mov    %eax,(%esp)
  800805:	e8 bd ff ff ff       	call   8007c7 <strcpy>
	return dst;
}
  80080a:	89 d8                	mov    %ebx,%eax
  80080c:	83 c4 08             	add    $0x8,%esp
  80080f:	5b                   	pop    %ebx
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	56                   	push   %esi
  800816:	53                   	push   %ebx
  800817:	8b 75 08             	mov    0x8(%ebp),%esi
  80081a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081d:	89 f3                	mov    %esi,%ebx
  80081f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800822:	89 f2                	mov    %esi,%edx
  800824:	eb 0f                	jmp    800835 <strncpy+0x23>
		*dst++ = *src;
  800826:	83 c2 01             	add    $0x1,%edx
  800829:	0f b6 01             	movzbl (%ecx),%eax
  80082c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80082f:	80 39 01             	cmpb   $0x1,(%ecx)
  800832:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800835:	39 da                	cmp    %ebx,%edx
  800837:	75 ed                	jne    800826 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800839:	89 f0                	mov    %esi,%eax
  80083b:	5b                   	pop    %ebx
  80083c:	5e                   	pop    %esi
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	56                   	push   %esi
  800843:	53                   	push   %ebx
  800844:	8b 75 08             	mov    0x8(%ebp),%esi
  800847:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80084d:	89 f0                	mov    %esi,%eax
  80084f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800853:	85 c9                	test   %ecx,%ecx
  800855:	75 0b                	jne    800862 <strlcpy+0x23>
  800857:	eb 1d                	jmp    800876 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800859:	83 c0 01             	add    $0x1,%eax
  80085c:	83 c2 01             	add    $0x1,%edx
  80085f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800862:	39 d8                	cmp    %ebx,%eax
  800864:	74 0b                	je     800871 <strlcpy+0x32>
  800866:	0f b6 0a             	movzbl (%edx),%ecx
  800869:	84 c9                	test   %cl,%cl
  80086b:	75 ec                	jne    800859 <strlcpy+0x1a>
  80086d:	89 c2                	mov    %eax,%edx
  80086f:	eb 02                	jmp    800873 <strlcpy+0x34>
  800871:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800873:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800876:	29 f0                	sub    %esi,%eax
}
  800878:	5b                   	pop    %ebx
  800879:	5e                   	pop    %esi
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800882:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800885:	eb 06                	jmp    80088d <strcmp+0x11>
		p++, q++;
  800887:	83 c1 01             	add    $0x1,%ecx
  80088a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80088d:	0f b6 01             	movzbl (%ecx),%eax
  800890:	84 c0                	test   %al,%al
  800892:	74 04                	je     800898 <strcmp+0x1c>
  800894:	3a 02                	cmp    (%edx),%al
  800896:	74 ef                	je     800887 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800898:	0f b6 c0             	movzbl %al,%eax
  80089b:	0f b6 12             	movzbl (%edx),%edx
  80089e:	29 d0                	sub    %edx,%eax
}
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	53                   	push   %ebx
  8008a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ac:	89 c3                	mov    %eax,%ebx
  8008ae:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b1:	eb 06                	jmp    8008b9 <strncmp+0x17>
		n--, p++, q++;
  8008b3:	83 c0 01             	add    $0x1,%eax
  8008b6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008b9:	39 d8                	cmp    %ebx,%eax
  8008bb:	74 15                	je     8008d2 <strncmp+0x30>
  8008bd:	0f b6 08             	movzbl (%eax),%ecx
  8008c0:	84 c9                	test   %cl,%cl
  8008c2:	74 04                	je     8008c8 <strncmp+0x26>
  8008c4:	3a 0a                	cmp    (%edx),%cl
  8008c6:	74 eb                	je     8008b3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c8:	0f b6 00             	movzbl (%eax),%eax
  8008cb:	0f b6 12             	movzbl (%edx),%edx
  8008ce:	29 d0                	sub    %edx,%eax
  8008d0:	eb 05                	jmp    8008d7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008d2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008d7:	5b                   	pop    %ebx
  8008d8:	5d                   	pop    %ebp
  8008d9:	c3                   	ret    

008008da <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e4:	eb 07                	jmp    8008ed <strchr+0x13>
		if (*s == c)
  8008e6:	38 ca                	cmp    %cl,%dl
  8008e8:	74 0f                	je     8008f9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ea:	83 c0 01             	add    $0x1,%eax
  8008ed:	0f b6 10             	movzbl (%eax),%edx
  8008f0:	84 d2                	test   %dl,%dl
  8008f2:	75 f2                	jne    8008e6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800905:	eb 07                	jmp    80090e <strfind+0x13>
		if (*s == c)
  800907:	38 ca                	cmp    %cl,%dl
  800909:	74 0a                	je     800915 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80090b:	83 c0 01             	add    $0x1,%eax
  80090e:	0f b6 10             	movzbl (%eax),%edx
  800911:	84 d2                	test   %dl,%dl
  800913:	75 f2                	jne    800907 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	57                   	push   %edi
  80091b:	56                   	push   %esi
  80091c:	53                   	push   %ebx
  80091d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800920:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800923:	85 c9                	test   %ecx,%ecx
  800925:	74 36                	je     80095d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800927:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80092d:	75 28                	jne    800957 <memset+0x40>
  80092f:	f6 c1 03             	test   $0x3,%cl
  800932:	75 23                	jne    800957 <memset+0x40>
		c &= 0xFF;
  800934:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800938:	89 d3                	mov    %edx,%ebx
  80093a:	c1 e3 08             	shl    $0x8,%ebx
  80093d:	89 d6                	mov    %edx,%esi
  80093f:	c1 e6 18             	shl    $0x18,%esi
  800942:	89 d0                	mov    %edx,%eax
  800944:	c1 e0 10             	shl    $0x10,%eax
  800947:	09 f0                	or     %esi,%eax
  800949:	09 c2                	or     %eax,%edx
  80094b:	89 d0                	mov    %edx,%eax
  80094d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80094f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800952:	fc                   	cld    
  800953:	f3 ab                	rep stos %eax,%es:(%edi)
  800955:	eb 06                	jmp    80095d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800957:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095a:	fc                   	cld    
  80095b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80095d:	89 f8                	mov    %edi,%eax
  80095f:	5b                   	pop    %ebx
  800960:	5e                   	pop    %esi
  800961:	5f                   	pop    %edi
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	57                   	push   %edi
  800968:	56                   	push   %esi
  800969:	8b 45 08             	mov    0x8(%ebp),%eax
  80096c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800972:	39 c6                	cmp    %eax,%esi
  800974:	73 35                	jae    8009ab <memmove+0x47>
  800976:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800979:	39 d0                	cmp    %edx,%eax
  80097b:	73 2e                	jae    8009ab <memmove+0x47>
		s += n;
		d += n;
  80097d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800980:	89 d6                	mov    %edx,%esi
  800982:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800984:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80098a:	75 13                	jne    80099f <memmove+0x3b>
  80098c:	f6 c1 03             	test   $0x3,%cl
  80098f:	75 0e                	jne    80099f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800991:	83 ef 04             	sub    $0x4,%edi
  800994:	8d 72 fc             	lea    -0x4(%edx),%esi
  800997:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80099a:	fd                   	std    
  80099b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099d:	eb 09                	jmp    8009a8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80099f:	83 ef 01             	sub    $0x1,%edi
  8009a2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a5:	fd                   	std    
  8009a6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a8:	fc                   	cld    
  8009a9:	eb 1d                	jmp    8009c8 <memmove+0x64>
  8009ab:	89 f2                	mov    %esi,%edx
  8009ad:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009af:	f6 c2 03             	test   $0x3,%dl
  8009b2:	75 0f                	jne    8009c3 <memmove+0x5f>
  8009b4:	f6 c1 03             	test   $0x3,%cl
  8009b7:	75 0a                	jne    8009c3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009b9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009bc:	89 c7                	mov    %eax,%edi
  8009be:	fc                   	cld    
  8009bf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c1:	eb 05                	jmp    8009c8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c3:	89 c7                	mov    %eax,%edi
  8009c5:	fc                   	cld    
  8009c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c8:	5e                   	pop    %esi
  8009c9:	5f                   	pop    %edi
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	89 04 24             	mov    %eax,(%esp)
  8009e6:	e8 79 ff ff ff       	call   800964 <memmove>
}
  8009eb:	c9                   	leave  
  8009ec:	c3                   	ret    

008009ed <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	56                   	push   %esi
  8009f1:	53                   	push   %ebx
  8009f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009f8:	89 d6                	mov    %edx,%esi
  8009fa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009fd:	eb 1a                	jmp    800a19 <memcmp+0x2c>
		if (*s1 != *s2)
  8009ff:	0f b6 02             	movzbl (%edx),%eax
  800a02:	0f b6 19             	movzbl (%ecx),%ebx
  800a05:	38 d8                	cmp    %bl,%al
  800a07:	74 0a                	je     800a13 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a09:	0f b6 c0             	movzbl %al,%eax
  800a0c:	0f b6 db             	movzbl %bl,%ebx
  800a0f:	29 d8                	sub    %ebx,%eax
  800a11:	eb 0f                	jmp    800a22 <memcmp+0x35>
		s1++, s2++;
  800a13:	83 c2 01             	add    $0x1,%edx
  800a16:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a19:	39 f2                	cmp    %esi,%edx
  800a1b:	75 e2                	jne    8009ff <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a22:	5b                   	pop    %ebx
  800a23:	5e                   	pop    %esi
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a2f:	89 c2                	mov    %eax,%edx
  800a31:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a34:	eb 07                	jmp    800a3d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a36:	38 08                	cmp    %cl,(%eax)
  800a38:	74 07                	je     800a41 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a3a:	83 c0 01             	add    $0x1,%eax
  800a3d:	39 d0                	cmp    %edx,%eax
  800a3f:	72 f5                	jb     800a36 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    

00800a43 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	57                   	push   %edi
  800a47:	56                   	push   %esi
  800a48:	53                   	push   %ebx
  800a49:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4f:	eb 03                	jmp    800a54 <strtol+0x11>
		s++;
  800a51:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a54:	0f b6 0a             	movzbl (%edx),%ecx
  800a57:	80 f9 09             	cmp    $0x9,%cl
  800a5a:	74 f5                	je     800a51 <strtol+0xe>
  800a5c:	80 f9 20             	cmp    $0x20,%cl
  800a5f:	74 f0                	je     800a51 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a61:	80 f9 2b             	cmp    $0x2b,%cl
  800a64:	75 0a                	jne    800a70 <strtol+0x2d>
		s++;
  800a66:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a69:	bf 00 00 00 00       	mov    $0x0,%edi
  800a6e:	eb 11                	jmp    800a81 <strtol+0x3e>
  800a70:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a75:	80 f9 2d             	cmp    $0x2d,%cl
  800a78:	75 07                	jne    800a81 <strtol+0x3e>
		s++, neg = 1;
  800a7a:	8d 52 01             	lea    0x1(%edx),%edx
  800a7d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a81:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800a86:	75 15                	jne    800a9d <strtol+0x5a>
  800a88:	80 3a 30             	cmpb   $0x30,(%edx)
  800a8b:	75 10                	jne    800a9d <strtol+0x5a>
  800a8d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a91:	75 0a                	jne    800a9d <strtol+0x5a>
		s += 2, base = 16;
  800a93:	83 c2 02             	add    $0x2,%edx
  800a96:	b8 10 00 00 00       	mov    $0x10,%eax
  800a9b:	eb 10                	jmp    800aad <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800a9d:	85 c0                	test   %eax,%eax
  800a9f:	75 0c                	jne    800aad <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa3:	80 3a 30             	cmpb   $0x30,(%edx)
  800aa6:	75 05                	jne    800aad <strtol+0x6a>
		s++, base = 8;
  800aa8:	83 c2 01             	add    $0x1,%edx
  800aab:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800aad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ab2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ab5:	0f b6 0a             	movzbl (%edx),%ecx
  800ab8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800abb:	89 f0                	mov    %esi,%eax
  800abd:	3c 09                	cmp    $0x9,%al
  800abf:	77 08                	ja     800ac9 <strtol+0x86>
			dig = *s - '0';
  800ac1:	0f be c9             	movsbl %cl,%ecx
  800ac4:	83 e9 30             	sub    $0x30,%ecx
  800ac7:	eb 20                	jmp    800ae9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800ac9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800acc:	89 f0                	mov    %esi,%eax
  800ace:	3c 19                	cmp    $0x19,%al
  800ad0:	77 08                	ja     800ada <strtol+0x97>
			dig = *s - 'a' + 10;
  800ad2:	0f be c9             	movsbl %cl,%ecx
  800ad5:	83 e9 57             	sub    $0x57,%ecx
  800ad8:	eb 0f                	jmp    800ae9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800ada:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800add:	89 f0                	mov    %esi,%eax
  800adf:	3c 19                	cmp    $0x19,%al
  800ae1:	77 16                	ja     800af9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800ae3:	0f be c9             	movsbl %cl,%ecx
  800ae6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ae9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800aec:	7d 0f                	jge    800afd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800aee:	83 c2 01             	add    $0x1,%edx
  800af1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800af5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800af7:	eb bc                	jmp    800ab5 <strtol+0x72>
  800af9:	89 d8                	mov    %ebx,%eax
  800afb:	eb 02                	jmp    800aff <strtol+0xbc>
  800afd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800aff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b03:	74 05                	je     800b0a <strtol+0xc7>
		*endptr = (char *) s;
  800b05:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b08:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b0a:	f7 d8                	neg    %eax
  800b0c:	85 ff                	test   %edi,%edi
  800b0e:	0f 44 c3             	cmove  %ebx,%eax
}
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5f                   	pop    %edi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	57                   	push   %edi
  800b1a:	56                   	push   %esi
  800b1b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b24:	8b 55 08             	mov    0x8(%ebp),%edx
  800b27:	89 c3                	mov    %eax,%ebx
  800b29:	89 c7                	mov    %eax,%edi
  800b2b:	89 c6                	mov    %eax,%esi
  800b2d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b2f:	5b                   	pop    %ebx
  800b30:	5e                   	pop    %esi
  800b31:	5f                   	pop    %edi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b44:	89 d1                	mov    %edx,%ecx
  800b46:	89 d3                	mov    %edx,%ebx
  800b48:	89 d7                	mov    %edx,%edi
  800b4a:	89 d6                	mov    %edx,%esi
  800b4c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b4e:	5b                   	pop    %ebx
  800b4f:	5e                   	pop    %esi
  800b50:	5f                   	pop    %edi
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    

00800b53 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	57                   	push   %edi
  800b57:	56                   	push   %esi
  800b58:	53                   	push   %ebx
  800b59:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b61:	b8 03 00 00 00       	mov    $0x3,%eax
  800b66:	8b 55 08             	mov    0x8(%ebp),%edx
  800b69:	89 cb                	mov    %ecx,%ebx
  800b6b:	89 cf                	mov    %ecx,%edi
  800b6d:	89 ce                	mov    %ecx,%esi
  800b6f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b71:	85 c0                	test   %eax,%eax
  800b73:	7e 28                	jle    800b9d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b75:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b79:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b80:	00 
  800b81:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  800b88:	00 
  800b89:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b90:	00 
  800b91:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  800b98:	e8 29 16 00 00       	call   8021c6 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b9d:	83 c4 2c             	add    $0x2c,%esp
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	57                   	push   %edi
  800ba9:	56                   	push   %esi
  800baa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bab:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb0:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb5:	89 d1                	mov    %edx,%ecx
  800bb7:	89 d3                	mov    %edx,%ebx
  800bb9:	89 d7                	mov    %edx,%edi
  800bbb:	89 d6                	mov    %edx,%esi
  800bbd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <sys_yield>:

void
sys_yield(void)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bca:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bd4:	89 d1                	mov    %edx,%ecx
  800bd6:	89 d3                	mov    %edx,%ebx
  800bd8:	89 d7                	mov    %edx,%edi
  800bda:	89 d6                	mov    %edx,%esi
  800bdc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bec:	be 00 00 00 00       	mov    $0x0,%esi
  800bf1:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bff:	89 f7                	mov    %esi,%edi
  800c01:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c03:	85 c0                	test   %eax,%eax
  800c05:	7e 28                	jle    800c2f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c07:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c0b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c12:	00 
  800c13:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  800c1a:	00 
  800c1b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c22:	00 
  800c23:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  800c2a:	e8 97 15 00 00       	call   8021c6 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c2f:	83 c4 2c             	add    $0x2c,%esp
  800c32:	5b                   	pop    %ebx
  800c33:	5e                   	pop    %esi
  800c34:	5f                   	pop    %edi
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
  800c3d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c40:	b8 05 00 00 00       	mov    $0x5,%eax
  800c45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c48:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c51:	8b 75 18             	mov    0x18(%ebp),%esi
  800c54:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c56:	85 c0                	test   %eax,%eax
  800c58:	7e 28                	jle    800c82 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c5e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c65:	00 
  800c66:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  800c6d:	00 
  800c6e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c75:	00 
  800c76:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  800c7d:	e8 44 15 00 00       	call   8021c6 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c82:	83 c4 2c             	add    $0x2c,%esp
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c98:	b8 06 00 00 00       	mov    $0x6,%eax
  800c9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca3:	89 df                	mov    %ebx,%edi
  800ca5:	89 de                	mov    %ebx,%esi
  800ca7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca9:	85 c0                	test   %eax,%eax
  800cab:	7e 28                	jle    800cd5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cad:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cb1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cb8:	00 
  800cb9:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  800cc0:	00 
  800cc1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc8:	00 
  800cc9:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  800cd0:	e8 f1 14 00 00       	call   8021c6 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cd5:	83 c4 2c             	add    $0x2c,%esp
  800cd8:	5b                   	pop    %ebx
  800cd9:	5e                   	pop    %esi
  800cda:	5f                   	pop    %edi
  800cdb:	5d                   	pop    %ebp
  800cdc:	c3                   	ret    

00800cdd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	57                   	push   %edi
  800ce1:	56                   	push   %esi
  800ce2:	53                   	push   %ebx
  800ce3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ceb:	b8 08 00 00 00       	mov    $0x8,%eax
  800cf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf6:	89 df                	mov    %ebx,%edi
  800cf8:	89 de                	mov    %ebx,%esi
  800cfa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfc:	85 c0                	test   %eax,%eax
  800cfe:	7e 28                	jle    800d28 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d00:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d04:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d0b:	00 
  800d0c:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  800d13:	00 
  800d14:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d1b:	00 
  800d1c:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  800d23:	e8 9e 14 00 00       	call   8021c6 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d28:	83 c4 2c             	add    $0x2c,%esp
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
  800d36:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d39:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3e:	b8 09 00 00 00       	mov    $0x9,%eax
  800d43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d46:	8b 55 08             	mov    0x8(%ebp),%edx
  800d49:	89 df                	mov    %ebx,%edi
  800d4b:	89 de                	mov    %ebx,%esi
  800d4d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	7e 28                	jle    800d7b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d53:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d57:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d5e:	00 
  800d5f:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  800d66:	00 
  800d67:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d6e:	00 
  800d6f:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  800d76:	e8 4b 14 00 00       	call   8021c6 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d7b:	83 c4 2c             	add    $0x2c,%esp
  800d7e:	5b                   	pop    %ebx
  800d7f:	5e                   	pop    %esi
  800d80:	5f                   	pop    %edi
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    

00800d83 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	57                   	push   %edi
  800d87:	56                   	push   %esi
  800d88:	53                   	push   %ebx
  800d89:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d91:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d99:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9c:	89 df                	mov    %ebx,%edi
  800d9e:	89 de                	mov    %ebx,%esi
  800da0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da2:	85 c0                	test   %eax,%eax
  800da4:	7e 28                	jle    800dce <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800daa:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800db1:	00 
  800db2:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  800db9:	00 
  800dba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc1:	00 
  800dc2:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  800dc9:	e8 f8 13 00 00       	call   8021c6 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dce:	83 c4 2c             	add    $0x2c,%esp
  800dd1:	5b                   	pop    %ebx
  800dd2:	5e                   	pop    %esi
  800dd3:	5f                   	pop    %edi
  800dd4:	5d                   	pop    %ebp
  800dd5:	c3                   	ret    

00800dd6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
  800dd9:	57                   	push   %edi
  800dda:	56                   	push   %esi
  800ddb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddc:	be 00 00 00 00       	mov    $0x0,%esi
  800de1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800de6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800def:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800df4:	5b                   	pop    %ebx
  800df5:	5e                   	pop    %esi
  800df6:	5f                   	pop    %edi
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    

00800df9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	57                   	push   %edi
  800dfd:	56                   	push   %esi
  800dfe:	53                   	push   %ebx
  800dff:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e07:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0f:	89 cb                	mov    %ecx,%ebx
  800e11:	89 cf                	mov    %ecx,%edi
  800e13:	89 ce                	mov    %ecx,%esi
  800e15:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e17:	85 c0                	test   %eax,%eax
  800e19:	7e 28                	jle    800e43 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e26:	00 
  800e27:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  800e2e:	00 
  800e2f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e36:	00 
  800e37:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  800e3e:	e8 83 13 00 00       	call   8021c6 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e43:	83 c4 2c             	add    $0x2c,%esp
  800e46:	5b                   	pop    %ebx
  800e47:	5e                   	pop    %esi
  800e48:	5f                   	pop    %edi
  800e49:	5d                   	pop    %ebp
  800e4a:	c3                   	ret    

00800e4b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	57                   	push   %edi
  800e4f:	56                   	push   %esi
  800e50:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e51:	ba 00 00 00 00       	mov    $0x0,%edx
  800e56:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e5b:	89 d1                	mov    %edx,%ecx
  800e5d:	89 d3                	mov    %edx,%ebx
  800e5f:	89 d7                	mov    %edx,%edi
  800e61:	89 d6                	mov    %edx,%esi
  800e63:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e65:	5b                   	pop    %ebx
  800e66:	5e                   	pop    %esi
  800e67:	5f                   	pop    %edi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    

00800e6a <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	57                   	push   %edi
  800e6e:	56                   	push   %esi
  800e6f:	53                   	push   %ebx
  800e70:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e78:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e80:	8b 55 08             	mov    0x8(%ebp),%edx
  800e83:	89 df                	mov    %ebx,%edi
  800e85:	89 de                	mov    %ebx,%esi
  800e87:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e89:	85 c0                	test   %eax,%eax
  800e8b:	7e 28                	jle    800eb5 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e91:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800e98:	00 
  800e99:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  800ea0:	00 
  800ea1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea8:	00 
  800ea9:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  800eb0:	e8 11 13 00 00       	call   8021c6 <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  800eb5:	83 c4 2c             	add    $0x2c,%esp
  800eb8:	5b                   	pop    %ebx
  800eb9:	5e                   	pop    %esi
  800eba:	5f                   	pop    %edi
  800ebb:	5d                   	pop    %ebp
  800ebc:	c3                   	ret    

00800ebd <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	57                   	push   %edi
  800ec1:	56                   	push   %esi
  800ec2:	53                   	push   %ebx
  800ec3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ecb:	b8 10 00 00 00       	mov    $0x10,%eax
  800ed0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed6:	89 df                	mov    %ebx,%edi
  800ed8:	89 de                	mov    %ebx,%esi
  800eda:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800edc:	85 c0                	test   %eax,%eax
  800ede:	7e 28                	jle    800f08 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee4:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  800eeb:	00 
  800eec:	c7 44 24 08 9f 29 80 	movl   $0x80299f,0x8(%esp)
  800ef3:	00 
  800ef4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800efb:	00 
  800efc:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  800f03:	e8 be 12 00 00       	call   8021c6 <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  800f08:	83 c4 2c             	add    $0x2c,%esp
  800f0b:	5b                   	pop    %ebx
  800f0c:	5e                   	pop    %esi
  800f0d:	5f                   	pop    %edi
  800f0e:	5d                   	pop    %ebp
  800f0f:	c3                   	ret    

00800f10 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f13:	8b 45 08             	mov    0x8(%ebp),%eax
  800f16:	05 00 00 00 30       	add    $0x30000000,%eax
  800f1b:	c1 e8 0c             	shr    $0xc,%eax
}
  800f1e:	5d                   	pop    %ebp
  800f1f:	c3                   	ret    

00800f20 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f23:	8b 45 08             	mov    0x8(%ebp),%eax
  800f26:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800f2b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f30:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f35:	5d                   	pop    %ebp
  800f36:	c3                   	ret    

00800f37 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f37:	55                   	push   %ebp
  800f38:	89 e5                	mov    %esp,%ebp
  800f3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f3d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f42:	89 c2                	mov    %eax,%edx
  800f44:	c1 ea 16             	shr    $0x16,%edx
  800f47:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f4e:	f6 c2 01             	test   $0x1,%dl
  800f51:	74 11                	je     800f64 <fd_alloc+0x2d>
  800f53:	89 c2                	mov    %eax,%edx
  800f55:	c1 ea 0c             	shr    $0xc,%edx
  800f58:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f5f:	f6 c2 01             	test   $0x1,%dl
  800f62:	75 09                	jne    800f6d <fd_alloc+0x36>
			*fd_store = fd;
  800f64:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f66:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6b:	eb 17                	jmp    800f84 <fd_alloc+0x4d>
  800f6d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f72:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f77:	75 c9                	jne    800f42 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f79:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f7f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f84:	5d                   	pop    %ebp
  800f85:	c3                   	ret    

00800f86 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f8c:	83 f8 1f             	cmp    $0x1f,%eax
  800f8f:	77 36                	ja     800fc7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f91:	c1 e0 0c             	shl    $0xc,%eax
  800f94:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f99:	89 c2                	mov    %eax,%edx
  800f9b:	c1 ea 16             	shr    $0x16,%edx
  800f9e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fa5:	f6 c2 01             	test   $0x1,%dl
  800fa8:	74 24                	je     800fce <fd_lookup+0x48>
  800faa:	89 c2                	mov    %eax,%edx
  800fac:	c1 ea 0c             	shr    $0xc,%edx
  800faf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fb6:	f6 c2 01             	test   $0x1,%dl
  800fb9:	74 1a                	je     800fd5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fbb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fbe:	89 02                	mov    %eax,(%edx)
	return 0;
  800fc0:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc5:	eb 13                	jmp    800fda <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fc7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fcc:	eb 0c                	jmp    800fda <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fd3:	eb 05                	jmp    800fda <fd_lookup+0x54>
  800fd5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fda:	5d                   	pop    %ebp
  800fdb:	c3                   	ret    

00800fdc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 18             	sub    $0x18,%esp
  800fe2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800fe5:	ba 00 00 00 00       	mov    $0x0,%edx
  800fea:	eb 13                	jmp    800fff <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  800fec:	39 08                	cmp    %ecx,(%eax)
  800fee:	75 0c                	jne    800ffc <dev_lookup+0x20>
			*dev = devtab[i];
  800ff0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff3:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ff5:	b8 00 00 00 00       	mov    $0x0,%eax
  800ffa:	eb 38                	jmp    801034 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ffc:	83 c2 01             	add    $0x1,%edx
  800fff:	8b 04 95 48 2a 80 00 	mov    0x802a48(,%edx,4),%eax
  801006:	85 c0                	test   %eax,%eax
  801008:	75 e2                	jne    800fec <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80100a:	a1 08 40 80 00       	mov    0x804008,%eax
  80100f:	8b 40 48             	mov    0x48(%eax),%eax
  801012:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801016:	89 44 24 04          	mov    %eax,0x4(%esp)
  80101a:	c7 04 24 cc 29 80 00 	movl   $0x8029cc,(%esp)
  801021:	e8 7c f1 ff ff       	call   8001a2 <cprintf>
	*dev = 0;
  801026:	8b 45 0c             	mov    0xc(%ebp),%eax
  801029:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80102f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801034:	c9                   	leave  
  801035:	c3                   	ret    

00801036 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	56                   	push   %esi
  80103a:	53                   	push   %ebx
  80103b:	83 ec 20             	sub    $0x20,%esp
  80103e:	8b 75 08             	mov    0x8(%ebp),%esi
  801041:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801044:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801047:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80104b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801051:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801054:	89 04 24             	mov    %eax,(%esp)
  801057:	e8 2a ff ff ff       	call   800f86 <fd_lookup>
  80105c:	85 c0                	test   %eax,%eax
  80105e:	78 05                	js     801065 <fd_close+0x2f>
	    || fd != fd2)
  801060:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801063:	74 0c                	je     801071 <fd_close+0x3b>
		return (must_exist ? r : 0);
  801065:	84 db                	test   %bl,%bl
  801067:	ba 00 00 00 00       	mov    $0x0,%edx
  80106c:	0f 44 c2             	cmove  %edx,%eax
  80106f:	eb 3f                	jmp    8010b0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801071:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801074:	89 44 24 04          	mov    %eax,0x4(%esp)
  801078:	8b 06                	mov    (%esi),%eax
  80107a:	89 04 24             	mov    %eax,(%esp)
  80107d:	e8 5a ff ff ff       	call   800fdc <dev_lookup>
  801082:	89 c3                	mov    %eax,%ebx
  801084:	85 c0                	test   %eax,%eax
  801086:	78 16                	js     80109e <fd_close+0x68>
		if (dev->dev_close)
  801088:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80108b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80108e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801093:	85 c0                	test   %eax,%eax
  801095:	74 07                	je     80109e <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801097:	89 34 24             	mov    %esi,(%esp)
  80109a:	ff d0                	call   *%eax
  80109c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80109e:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010a9:	e8 dc fb ff ff       	call   800c8a <sys_page_unmap>
	return r;
  8010ae:	89 d8                	mov    %ebx,%eax
}
  8010b0:	83 c4 20             	add    $0x20,%esp
  8010b3:	5b                   	pop    %ebx
  8010b4:	5e                   	pop    %esi
  8010b5:	5d                   	pop    %ebp
  8010b6:	c3                   	ret    

008010b7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c7:	89 04 24             	mov    %eax,(%esp)
  8010ca:	e8 b7 fe ff ff       	call   800f86 <fd_lookup>
  8010cf:	89 c2                	mov    %eax,%edx
  8010d1:	85 d2                	test   %edx,%edx
  8010d3:	78 13                	js     8010e8 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8010d5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010dc:	00 
  8010dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010e0:	89 04 24             	mov    %eax,(%esp)
  8010e3:	e8 4e ff ff ff       	call   801036 <fd_close>
}
  8010e8:	c9                   	leave  
  8010e9:	c3                   	ret    

008010ea <close_all>:

void
close_all(void)
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	53                   	push   %ebx
  8010ee:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010f1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010f6:	89 1c 24             	mov    %ebx,(%esp)
  8010f9:	e8 b9 ff ff ff       	call   8010b7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010fe:	83 c3 01             	add    $0x1,%ebx
  801101:	83 fb 20             	cmp    $0x20,%ebx
  801104:	75 f0                	jne    8010f6 <close_all+0xc>
		close(i);
}
  801106:	83 c4 14             	add    $0x14,%esp
  801109:	5b                   	pop    %ebx
  80110a:	5d                   	pop    %ebp
  80110b:	c3                   	ret    

0080110c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
  80110f:	57                   	push   %edi
  801110:	56                   	push   %esi
  801111:	53                   	push   %ebx
  801112:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801115:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801118:	89 44 24 04          	mov    %eax,0x4(%esp)
  80111c:	8b 45 08             	mov    0x8(%ebp),%eax
  80111f:	89 04 24             	mov    %eax,(%esp)
  801122:	e8 5f fe ff ff       	call   800f86 <fd_lookup>
  801127:	89 c2                	mov    %eax,%edx
  801129:	85 d2                	test   %edx,%edx
  80112b:	0f 88 e1 00 00 00    	js     801212 <dup+0x106>
		return r;
	close(newfdnum);
  801131:	8b 45 0c             	mov    0xc(%ebp),%eax
  801134:	89 04 24             	mov    %eax,(%esp)
  801137:	e8 7b ff ff ff       	call   8010b7 <close>

	newfd = INDEX2FD(newfdnum);
  80113c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80113f:	c1 e3 0c             	shl    $0xc,%ebx
  801142:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801148:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80114b:	89 04 24             	mov    %eax,(%esp)
  80114e:	e8 cd fd ff ff       	call   800f20 <fd2data>
  801153:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801155:	89 1c 24             	mov    %ebx,(%esp)
  801158:	e8 c3 fd ff ff       	call   800f20 <fd2data>
  80115d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80115f:	89 f0                	mov    %esi,%eax
  801161:	c1 e8 16             	shr    $0x16,%eax
  801164:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80116b:	a8 01                	test   $0x1,%al
  80116d:	74 43                	je     8011b2 <dup+0xa6>
  80116f:	89 f0                	mov    %esi,%eax
  801171:	c1 e8 0c             	shr    $0xc,%eax
  801174:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80117b:	f6 c2 01             	test   $0x1,%dl
  80117e:	74 32                	je     8011b2 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801180:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801187:	25 07 0e 00 00       	and    $0xe07,%eax
  80118c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801190:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801194:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80119b:	00 
  80119c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011a7:	e8 8b fa ff ff       	call   800c37 <sys_page_map>
  8011ac:	89 c6                	mov    %eax,%esi
  8011ae:	85 c0                	test   %eax,%eax
  8011b0:	78 3e                	js     8011f0 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011b5:	89 c2                	mov    %eax,%edx
  8011b7:	c1 ea 0c             	shr    $0xc,%edx
  8011ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011c1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8011c7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011cf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011d6:	00 
  8011d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011e2:	e8 50 fa ff ff       	call   800c37 <sys_page_map>
  8011e7:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8011e9:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011ec:	85 f6                	test   %esi,%esi
  8011ee:	79 22                	jns    801212 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011fb:	e8 8a fa ff ff       	call   800c8a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801200:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801204:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80120b:	e8 7a fa ff ff       	call   800c8a <sys_page_unmap>
	return r;
  801210:	89 f0                	mov    %esi,%eax
}
  801212:	83 c4 3c             	add    $0x3c,%esp
  801215:	5b                   	pop    %ebx
  801216:	5e                   	pop    %esi
  801217:	5f                   	pop    %edi
  801218:	5d                   	pop    %ebp
  801219:	c3                   	ret    

0080121a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	53                   	push   %ebx
  80121e:	83 ec 24             	sub    $0x24,%esp
  801221:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801224:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801227:	89 44 24 04          	mov    %eax,0x4(%esp)
  80122b:	89 1c 24             	mov    %ebx,(%esp)
  80122e:	e8 53 fd ff ff       	call   800f86 <fd_lookup>
  801233:	89 c2                	mov    %eax,%edx
  801235:	85 d2                	test   %edx,%edx
  801237:	78 6d                	js     8012a6 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801239:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801240:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801243:	8b 00                	mov    (%eax),%eax
  801245:	89 04 24             	mov    %eax,(%esp)
  801248:	e8 8f fd ff ff       	call   800fdc <dev_lookup>
  80124d:	85 c0                	test   %eax,%eax
  80124f:	78 55                	js     8012a6 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801251:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801254:	8b 50 08             	mov    0x8(%eax),%edx
  801257:	83 e2 03             	and    $0x3,%edx
  80125a:	83 fa 01             	cmp    $0x1,%edx
  80125d:	75 23                	jne    801282 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80125f:	a1 08 40 80 00       	mov    0x804008,%eax
  801264:	8b 40 48             	mov    0x48(%eax),%eax
  801267:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80126b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80126f:	c7 04 24 0d 2a 80 00 	movl   $0x802a0d,(%esp)
  801276:	e8 27 ef ff ff       	call   8001a2 <cprintf>
		return -E_INVAL;
  80127b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801280:	eb 24                	jmp    8012a6 <read+0x8c>
	}
	if (!dev->dev_read)
  801282:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801285:	8b 52 08             	mov    0x8(%edx),%edx
  801288:	85 d2                	test   %edx,%edx
  80128a:	74 15                	je     8012a1 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80128c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80128f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801293:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801296:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80129a:	89 04 24             	mov    %eax,(%esp)
  80129d:	ff d2                	call   *%edx
  80129f:	eb 05                	jmp    8012a6 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012a1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8012a6:	83 c4 24             	add    $0x24,%esp
  8012a9:	5b                   	pop    %ebx
  8012aa:	5d                   	pop    %ebp
  8012ab:	c3                   	ret    

008012ac <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	57                   	push   %edi
  8012b0:	56                   	push   %esi
  8012b1:	53                   	push   %ebx
  8012b2:	83 ec 1c             	sub    $0x1c,%esp
  8012b5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012b8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012c0:	eb 23                	jmp    8012e5 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012c2:	89 f0                	mov    %esi,%eax
  8012c4:	29 d8                	sub    %ebx,%eax
  8012c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012ca:	89 d8                	mov    %ebx,%eax
  8012cc:	03 45 0c             	add    0xc(%ebp),%eax
  8012cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d3:	89 3c 24             	mov    %edi,(%esp)
  8012d6:	e8 3f ff ff ff       	call   80121a <read>
		if (m < 0)
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	78 10                	js     8012ef <readn+0x43>
			return m;
		if (m == 0)
  8012df:	85 c0                	test   %eax,%eax
  8012e1:	74 0a                	je     8012ed <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012e3:	01 c3                	add    %eax,%ebx
  8012e5:	39 f3                	cmp    %esi,%ebx
  8012e7:	72 d9                	jb     8012c2 <readn+0x16>
  8012e9:	89 d8                	mov    %ebx,%eax
  8012eb:	eb 02                	jmp    8012ef <readn+0x43>
  8012ed:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8012ef:	83 c4 1c             	add    $0x1c,%esp
  8012f2:	5b                   	pop    %ebx
  8012f3:	5e                   	pop    %esi
  8012f4:	5f                   	pop    %edi
  8012f5:	5d                   	pop    %ebp
  8012f6:	c3                   	ret    

008012f7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012f7:	55                   	push   %ebp
  8012f8:	89 e5                	mov    %esp,%ebp
  8012fa:	53                   	push   %ebx
  8012fb:	83 ec 24             	sub    $0x24,%esp
  8012fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801301:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801304:	89 44 24 04          	mov    %eax,0x4(%esp)
  801308:	89 1c 24             	mov    %ebx,(%esp)
  80130b:	e8 76 fc ff ff       	call   800f86 <fd_lookup>
  801310:	89 c2                	mov    %eax,%edx
  801312:	85 d2                	test   %edx,%edx
  801314:	78 68                	js     80137e <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801316:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801319:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801320:	8b 00                	mov    (%eax),%eax
  801322:	89 04 24             	mov    %eax,(%esp)
  801325:	e8 b2 fc ff ff       	call   800fdc <dev_lookup>
  80132a:	85 c0                	test   %eax,%eax
  80132c:	78 50                	js     80137e <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80132e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801331:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801335:	75 23                	jne    80135a <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801337:	a1 08 40 80 00       	mov    0x804008,%eax
  80133c:	8b 40 48             	mov    0x48(%eax),%eax
  80133f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801343:	89 44 24 04          	mov    %eax,0x4(%esp)
  801347:	c7 04 24 29 2a 80 00 	movl   $0x802a29,(%esp)
  80134e:	e8 4f ee ff ff       	call   8001a2 <cprintf>
		return -E_INVAL;
  801353:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801358:	eb 24                	jmp    80137e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80135a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80135d:	8b 52 0c             	mov    0xc(%edx),%edx
  801360:	85 d2                	test   %edx,%edx
  801362:	74 15                	je     801379 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801364:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801367:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80136b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80136e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801372:	89 04 24             	mov    %eax,(%esp)
  801375:	ff d2                	call   *%edx
  801377:	eb 05                	jmp    80137e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801379:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80137e:	83 c4 24             	add    $0x24,%esp
  801381:	5b                   	pop    %ebx
  801382:	5d                   	pop    %ebp
  801383:	c3                   	ret    

00801384 <seek>:

int
seek(int fdnum, off_t offset)
{
  801384:	55                   	push   %ebp
  801385:	89 e5                	mov    %esp,%ebp
  801387:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80138a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80138d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801391:	8b 45 08             	mov    0x8(%ebp),%eax
  801394:	89 04 24             	mov    %eax,(%esp)
  801397:	e8 ea fb ff ff       	call   800f86 <fd_lookup>
  80139c:	85 c0                	test   %eax,%eax
  80139e:	78 0e                	js     8013ae <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8013a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013a6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013ae:	c9                   	leave  
  8013af:	c3                   	ret    

008013b0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
  8013b3:	53                   	push   %ebx
  8013b4:	83 ec 24             	sub    $0x24,%esp
  8013b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c1:	89 1c 24             	mov    %ebx,(%esp)
  8013c4:	e8 bd fb ff ff       	call   800f86 <fd_lookup>
  8013c9:	89 c2                	mov    %eax,%edx
  8013cb:	85 d2                	test   %edx,%edx
  8013cd:	78 61                	js     801430 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d9:	8b 00                	mov    (%eax),%eax
  8013db:	89 04 24             	mov    %eax,(%esp)
  8013de:	e8 f9 fb ff ff       	call   800fdc <dev_lookup>
  8013e3:	85 c0                	test   %eax,%eax
  8013e5:	78 49                	js     801430 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013ee:	75 23                	jne    801413 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013f0:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013f5:	8b 40 48             	mov    0x48(%eax),%eax
  8013f8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801400:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  801407:	e8 96 ed ff ff       	call   8001a2 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80140c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801411:	eb 1d                	jmp    801430 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801413:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801416:	8b 52 18             	mov    0x18(%edx),%edx
  801419:	85 d2                	test   %edx,%edx
  80141b:	74 0e                	je     80142b <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80141d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801420:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801424:	89 04 24             	mov    %eax,(%esp)
  801427:	ff d2                	call   *%edx
  801429:	eb 05                	jmp    801430 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80142b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801430:	83 c4 24             	add    $0x24,%esp
  801433:	5b                   	pop    %ebx
  801434:	5d                   	pop    %ebp
  801435:	c3                   	ret    

00801436 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801436:	55                   	push   %ebp
  801437:	89 e5                	mov    %esp,%ebp
  801439:	53                   	push   %ebx
  80143a:	83 ec 24             	sub    $0x24,%esp
  80143d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801440:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801443:	89 44 24 04          	mov    %eax,0x4(%esp)
  801447:	8b 45 08             	mov    0x8(%ebp),%eax
  80144a:	89 04 24             	mov    %eax,(%esp)
  80144d:	e8 34 fb ff ff       	call   800f86 <fd_lookup>
  801452:	89 c2                	mov    %eax,%edx
  801454:	85 d2                	test   %edx,%edx
  801456:	78 52                	js     8014aa <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801458:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80145b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80145f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801462:	8b 00                	mov    (%eax),%eax
  801464:	89 04 24             	mov    %eax,(%esp)
  801467:	e8 70 fb ff ff       	call   800fdc <dev_lookup>
  80146c:	85 c0                	test   %eax,%eax
  80146e:	78 3a                	js     8014aa <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801470:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801473:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801477:	74 2c                	je     8014a5 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801479:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80147c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801483:	00 00 00 
	stat->st_isdir = 0;
  801486:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80148d:	00 00 00 
	stat->st_dev = dev;
  801490:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801496:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80149a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80149d:	89 14 24             	mov    %edx,(%esp)
  8014a0:	ff 50 14             	call   *0x14(%eax)
  8014a3:	eb 05                	jmp    8014aa <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8014a5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8014aa:	83 c4 24             	add    $0x24,%esp
  8014ad:	5b                   	pop    %ebx
  8014ae:	5d                   	pop    %ebp
  8014af:	c3                   	ret    

008014b0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
  8014b3:	56                   	push   %esi
  8014b4:	53                   	push   %ebx
  8014b5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014bf:	00 
  8014c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c3:	89 04 24             	mov    %eax,(%esp)
  8014c6:	e8 28 02 00 00       	call   8016f3 <open>
  8014cb:	89 c3                	mov    %eax,%ebx
  8014cd:	85 db                	test   %ebx,%ebx
  8014cf:	78 1b                	js     8014ec <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8014d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d8:	89 1c 24             	mov    %ebx,(%esp)
  8014db:	e8 56 ff ff ff       	call   801436 <fstat>
  8014e0:	89 c6                	mov    %eax,%esi
	close(fd);
  8014e2:	89 1c 24             	mov    %ebx,(%esp)
  8014e5:	e8 cd fb ff ff       	call   8010b7 <close>
	return r;
  8014ea:	89 f0                	mov    %esi,%eax
}
  8014ec:	83 c4 10             	add    $0x10,%esp
  8014ef:	5b                   	pop    %ebx
  8014f0:	5e                   	pop    %esi
  8014f1:	5d                   	pop    %ebp
  8014f2:	c3                   	ret    

008014f3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014f3:	55                   	push   %ebp
  8014f4:	89 e5                	mov    %esp,%ebp
  8014f6:	56                   	push   %esi
  8014f7:	53                   	push   %ebx
  8014f8:	83 ec 10             	sub    $0x10,%esp
  8014fb:	89 c6                	mov    %eax,%esi
  8014fd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014ff:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801506:	75 11                	jne    801519 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801508:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80150f:	e8 f1 0d 00 00       	call   802305 <ipc_find_env>
  801514:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801519:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801520:	00 
  801521:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801528:	00 
  801529:	89 74 24 04          	mov    %esi,0x4(%esp)
  80152d:	a1 00 40 80 00       	mov    0x804000,%eax
  801532:	89 04 24             	mov    %eax,(%esp)
  801535:	e8 60 0d 00 00       	call   80229a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80153a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801541:	00 
  801542:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801546:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80154d:	e8 ce 0c 00 00       	call   802220 <ipc_recv>
}
  801552:	83 c4 10             	add    $0x10,%esp
  801555:	5b                   	pop    %ebx
  801556:	5e                   	pop    %esi
  801557:	5d                   	pop    %ebp
  801558:	c3                   	ret    

00801559 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801559:	55                   	push   %ebp
  80155a:	89 e5                	mov    %esp,%ebp
  80155c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80155f:	8b 45 08             	mov    0x8(%ebp),%eax
  801562:	8b 40 0c             	mov    0xc(%eax),%eax
  801565:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80156a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80156d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801572:	ba 00 00 00 00       	mov    $0x0,%edx
  801577:	b8 02 00 00 00       	mov    $0x2,%eax
  80157c:	e8 72 ff ff ff       	call   8014f3 <fsipc>
}
  801581:	c9                   	leave  
  801582:	c3                   	ret    

00801583 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801583:	55                   	push   %ebp
  801584:	89 e5                	mov    %esp,%ebp
  801586:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801589:	8b 45 08             	mov    0x8(%ebp),%eax
  80158c:	8b 40 0c             	mov    0xc(%eax),%eax
  80158f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801594:	ba 00 00 00 00       	mov    $0x0,%edx
  801599:	b8 06 00 00 00       	mov    $0x6,%eax
  80159e:	e8 50 ff ff ff       	call   8014f3 <fsipc>
}
  8015a3:	c9                   	leave  
  8015a4:	c3                   	ret    

008015a5 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	53                   	push   %ebx
  8015a9:	83 ec 14             	sub    $0x14,%esp
  8015ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015af:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8015b5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8015bf:	b8 05 00 00 00       	mov    $0x5,%eax
  8015c4:	e8 2a ff ff ff       	call   8014f3 <fsipc>
  8015c9:	89 c2                	mov    %eax,%edx
  8015cb:	85 d2                	test   %edx,%edx
  8015cd:	78 2b                	js     8015fa <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015cf:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015d6:	00 
  8015d7:	89 1c 24             	mov    %ebx,(%esp)
  8015da:	e8 e8 f1 ff ff       	call   8007c7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015df:	a1 80 50 80 00       	mov    0x805080,%eax
  8015e4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015ea:	a1 84 50 80 00       	mov    0x805084,%eax
  8015ef:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015fa:	83 c4 14             	add    $0x14,%esp
  8015fd:	5b                   	pop    %ebx
  8015fe:	5d                   	pop    %ebp
  8015ff:	c3                   	ret    

00801600 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	83 ec 18             	sub    $0x18,%esp
  801606:	8b 45 10             	mov    0x10(%ebp),%eax
  801609:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80160e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801613:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801616:	8b 55 08             	mov    0x8(%ebp),%edx
  801619:	8b 52 0c             	mov    0xc(%edx),%edx
  80161c:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801622:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801627:	89 44 24 08          	mov    %eax,0x8(%esp)
  80162b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80162e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801632:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801639:	e8 26 f3 ff ff       	call   800964 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  80163e:	ba 00 00 00 00       	mov    $0x0,%edx
  801643:	b8 04 00 00 00       	mov    $0x4,%eax
  801648:	e8 a6 fe ff ff       	call   8014f3 <fsipc>
}
  80164d:	c9                   	leave  
  80164e:	c3                   	ret    

0080164f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80164f:	55                   	push   %ebp
  801650:	89 e5                	mov    %esp,%ebp
  801652:	56                   	push   %esi
  801653:	53                   	push   %ebx
  801654:	83 ec 10             	sub    $0x10,%esp
  801657:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80165a:	8b 45 08             	mov    0x8(%ebp),%eax
  80165d:	8b 40 0c             	mov    0xc(%eax),%eax
  801660:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801665:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80166b:	ba 00 00 00 00       	mov    $0x0,%edx
  801670:	b8 03 00 00 00       	mov    $0x3,%eax
  801675:	e8 79 fe ff ff       	call   8014f3 <fsipc>
  80167a:	89 c3                	mov    %eax,%ebx
  80167c:	85 c0                	test   %eax,%eax
  80167e:	78 6a                	js     8016ea <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801680:	39 c6                	cmp    %eax,%esi
  801682:	73 24                	jae    8016a8 <devfile_read+0x59>
  801684:	c7 44 24 0c 5c 2a 80 	movl   $0x802a5c,0xc(%esp)
  80168b:	00 
  80168c:	c7 44 24 08 63 2a 80 	movl   $0x802a63,0x8(%esp)
  801693:	00 
  801694:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80169b:	00 
  80169c:	c7 04 24 78 2a 80 00 	movl   $0x802a78,(%esp)
  8016a3:	e8 1e 0b 00 00       	call   8021c6 <_panic>
	assert(r <= PGSIZE);
  8016a8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016ad:	7e 24                	jle    8016d3 <devfile_read+0x84>
  8016af:	c7 44 24 0c 83 2a 80 	movl   $0x802a83,0xc(%esp)
  8016b6:	00 
  8016b7:	c7 44 24 08 63 2a 80 	movl   $0x802a63,0x8(%esp)
  8016be:	00 
  8016bf:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8016c6:	00 
  8016c7:	c7 04 24 78 2a 80 00 	movl   $0x802a78,(%esp)
  8016ce:	e8 f3 0a 00 00       	call   8021c6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8016d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016d7:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8016de:	00 
  8016df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e2:	89 04 24             	mov    %eax,(%esp)
  8016e5:	e8 7a f2 ff ff       	call   800964 <memmove>
	return r;
}
  8016ea:	89 d8                	mov    %ebx,%eax
  8016ec:	83 c4 10             	add    $0x10,%esp
  8016ef:	5b                   	pop    %ebx
  8016f0:	5e                   	pop    %esi
  8016f1:	5d                   	pop    %ebp
  8016f2:	c3                   	ret    

008016f3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	53                   	push   %ebx
  8016f7:	83 ec 24             	sub    $0x24,%esp
  8016fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016fd:	89 1c 24             	mov    %ebx,(%esp)
  801700:	e8 8b f0 ff ff       	call   800790 <strlen>
  801705:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80170a:	7f 60                	jg     80176c <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80170c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80170f:	89 04 24             	mov    %eax,(%esp)
  801712:	e8 20 f8 ff ff       	call   800f37 <fd_alloc>
  801717:	89 c2                	mov    %eax,%edx
  801719:	85 d2                	test   %edx,%edx
  80171b:	78 54                	js     801771 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80171d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801721:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801728:	e8 9a f0 ff ff       	call   8007c7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80172d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801730:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801735:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801738:	b8 01 00 00 00       	mov    $0x1,%eax
  80173d:	e8 b1 fd ff ff       	call   8014f3 <fsipc>
  801742:	89 c3                	mov    %eax,%ebx
  801744:	85 c0                	test   %eax,%eax
  801746:	79 17                	jns    80175f <open+0x6c>
		fd_close(fd, 0);
  801748:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80174f:	00 
  801750:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801753:	89 04 24             	mov    %eax,(%esp)
  801756:	e8 db f8 ff ff       	call   801036 <fd_close>
		return r;
  80175b:	89 d8                	mov    %ebx,%eax
  80175d:	eb 12                	jmp    801771 <open+0x7e>
	}

	return fd2num(fd);
  80175f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801762:	89 04 24             	mov    %eax,(%esp)
  801765:	e8 a6 f7 ff ff       	call   800f10 <fd2num>
  80176a:	eb 05                	jmp    801771 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80176c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801771:	83 c4 24             	add    $0x24,%esp
  801774:	5b                   	pop    %ebx
  801775:	5d                   	pop    %ebp
  801776:	c3                   	ret    

00801777 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801777:	55                   	push   %ebp
  801778:	89 e5                	mov    %esp,%ebp
  80177a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80177d:	ba 00 00 00 00       	mov    $0x0,%edx
  801782:	b8 08 00 00 00       	mov    $0x8,%eax
  801787:	e8 67 fd ff ff       	call   8014f3 <fsipc>
}
  80178c:	c9                   	leave  
  80178d:	c3                   	ret    
  80178e:	66 90                	xchg   %ax,%ax

00801790 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801796:	c7 44 24 04 8f 2a 80 	movl   $0x802a8f,0x4(%esp)
  80179d:	00 
  80179e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a1:	89 04 24             	mov    %eax,(%esp)
  8017a4:	e8 1e f0 ff ff       	call   8007c7 <strcpy>
	return 0;
}
  8017a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ae:	c9                   	leave  
  8017af:	c3                   	ret    

008017b0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	53                   	push   %ebx
  8017b4:	83 ec 14             	sub    $0x14,%esp
  8017b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8017ba:	89 1c 24             	mov    %ebx,(%esp)
  8017bd:	e8 7b 0b 00 00       	call   80233d <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8017c2:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8017c7:	83 f8 01             	cmp    $0x1,%eax
  8017ca:	75 0d                	jne    8017d9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  8017cc:	8b 43 0c             	mov    0xc(%ebx),%eax
  8017cf:	89 04 24             	mov    %eax,(%esp)
  8017d2:	e8 29 03 00 00       	call   801b00 <nsipc_close>
  8017d7:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  8017d9:	89 d0                	mov    %edx,%eax
  8017db:	83 c4 14             	add    $0x14,%esp
  8017de:	5b                   	pop    %ebx
  8017df:	5d                   	pop    %ebp
  8017e0:	c3                   	ret    

008017e1 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8017e1:	55                   	push   %ebp
  8017e2:	89 e5                	mov    %esp,%ebp
  8017e4:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8017e7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8017ee:	00 
  8017ef:	8b 45 10             	mov    0x10(%ebp),%eax
  8017f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801800:	8b 40 0c             	mov    0xc(%eax),%eax
  801803:	89 04 24             	mov    %eax,(%esp)
  801806:	e8 f0 03 00 00       	call   801bfb <nsipc_send>
}
  80180b:	c9                   	leave  
  80180c:	c3                   	ret    

0080180d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
  801810:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801813:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80181a:	00 
  80181b:	8b 45 10             	mov    0x10(%ebp),%eax
  80181e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801822:	8b 45 0c             	mov    0xc(%ebp),%eax
  801825:	89 44 24 04          	mov    %eax,0x4(%esp)
  801829:	8b 45 08             	mov    0x8(%ebp),%eax
  80182c:	8b 40 0c             	mov    0xc(%eax),%eax
  80182f:	89 04 24             	mov    %eax,(%esp)
  801832:	e8 44 03 00 00       	call   801b7b <nsipc_recv>
}
  801837:	c9                   	leave  
  801838:	c3                   	ret    

00801839 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801839:	55                   	push   %ebp
  80183a:	89 e5                	mov    %esp,%ebp
  80183c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80183f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801842:	89 54 24 04          	mov    %edx,0x4(%esp)
  801846:	89 04 24             	mov    %eax,(%esp)
  801849:	e8 38 f7 ff ff       	call   800f86 <fd_lookup>
  80184e:	85 c0                	test   %eax,%eax
  801850:	78 17                	js     801869 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801852:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801855:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80185b:	39 08                	cmp    %ecx,(%eax)
  80185d:	75 05                	jne    801864 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80185f:	8b 40 0c             	mov    0xc(%eax),%eax
  801862:	eb 05                	jmp    801869 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801864:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801869:	c9                   	leave  
  80186a:	c3                   	ret    

0080186b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80186b:	55                   	push   %ebp
  80186c:	89 e5                	mov    %esp,%ebp
  80186e:	56                   	push   %esi
  80186f:	53                   	push   %ebx
  801870:	83 ec 20             	sub    $0x20,%esp
  801873:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801875:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801878:	89 04 24             	mov    %eax,(%esp)
  80187b:	e8 b7 f6 ff ff       	call   800f37 <fd_alloc>
  801880:	89 c3                	mov    %eax,%ebx
  801882:	85 c0                	test   %eax,%eax
  801884:	78 21                	js     8018a7 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801886:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80188d:	00 
  80188e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801891:	89 44 24 04          	mov    %eax,0x4(%esp)
  801895:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80189c:	e8 42 f3 ff ff       	call   800be3 <sys_page_alloc>
  8018a1:	89 c3                	mov    %eax,%ebx
  8018a3:	85 c0                	test   %eax,%eax
  8018a5:	79 0c                	jns    8018b3 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  8018a7:	89 34 24             	mov    %esi,(%esp)
  8018aa:	e8 51 02 00 00       	call   801b00 <nsipc_close>
		return r;
  8018af:	89 d8                	mov    %ebx,%eax
  8018b1:	eb 20                	jmp    8018d3 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8018b3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018bc:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8018be:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c1:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  8018c8:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  8018cb:	89 14 24             	mov    %edx,(%esp)
  8018ce:	e8 3d f6 ff ff       	call   800f10 <fd2num>
}
  8018d3:	83 c4 20             	add    $0x20,%esp
  8018d6:	5b                   	pop    %ebx
  8018d7:	5e                   	pop    %esi
  8018d8:	5d                   	pop    %ebp
  8018d9:	c3                   	ret    

008018da <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8018da:	55                   	push   %ebp
  8018db:	89 e5                	mov    %esp,%ebp
  8018dd:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e3:	e8 51 ff ff ff       	call   801839 <fd2sockid>
		return r;
  8018e8:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018ea:	85 c0                	test   %eax,%eax
  8018ec:	78 23                	js     801911 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8018ee:	8b 55 10             	mov    0x10(%ebp),%edx
  8018f1:	89 54 24 08          	mov    %edx,0x8(%esp)
  8018f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018fc:	89 04 24             	mov    %eax,(%esp)
  8018ff:	e8 45 01 00 00       	call   801a49 <nsipc_accept>
		return r;
  801904:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801906:	85 c0                	test   %eax,%eax
  801908:	78 07                	js     801911 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  80190a:	e8 5c ff ff ff       	call   80186b <alloc_sockfd>
  80190f:	89 c1                	mov    %eax,%ecx
}
  801911:	89 c8                	mov    %ecx,%eax
  801913:	c9                   	leave  
  801914:	c3                   	ret    

00801915 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801915:	55                   	push   %ebp
  801916:	89 e5                	mov    %esp,%ebp
  801918:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80191b:	8b 45 08             	mov    0x8(%ebp),%eax
  80191e:	e8 16 ff ff ff       	call   801839 <fd2sockid>
  801923:	89 c2                	mov    %eax,%edx
  801925:	85 d2                	test   %edx,%edx
  801927:	78 16                	js     80193f <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  801929:	8b 45 10             	mov    0x10(%ebp),%eax
  80192c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801930:	8b 45 0c             	mov    0xc(%ebp),%eax
  801933:	89 44 24 04          	mov    %eax,0x4(%esp)
  801937:	89 14 24             	mov    %edx,(%esp)
  80193a:	e8 60 01 00 00       	call   801a9f <nsipc_bind>
}
  80193f:	c9                   	leave  
  801940:	c3                   	ret    

00801941 <shutdown>:

int
shutdown(int s, int how)
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801947:	8b 45 08             	mov    0x8(%ebp),%eax
  80194a:	e8 ea fe ff ff       	call   801839 <fd2sockid>
  80194f:	89 c2                	mov    %eax,%edx
  801951:	85 d2                	test   %edx,%edx
  801953:	78 0f                	js     801964 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801955:	8b 45 0c             	mov    0xc(%ebp),%eax
  801958:	89 44 24 04          	mov    %eax,0x4(%esp)
  80195c:	89 14 24             	mov    %edx,(%esp)
  80195f:	e8 7a 01 00 00       	call   801ade <nsipc_shutdown>
}
  801964:	c9                   	leave  
  801965:	c3                   	ret    

00801966 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80196c:	8b 45 08             	mov    0x8(%ebp),%eax
  80196f:	e8 c5 fe ff ff       	call   801839 <fd2sockid>
  801974:	89 c2                	mov    %eax,%edx
  801976:	85 d2                	test   %edx,%edx
  801978:	78 16                	js     801990 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  80197a:	8b 45 10             	mov    0x10(%ebp),%eax
  80197d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801981:	8b 45 0c             	mov    0xc(%ebp),%eax
  801984:	89 44 24 04          	mov    %eax,0x4(%esp)
  801988:	89 14 24             	mov    %edx,(%esp)
  80198b:	e8 8a 01 00 00       	call   801b1a <nsipc_connect>
}
  801990:	c9                   	leave  
  801991:	c3                   	ret    

00801992 <listen>:

int
listen(int s, int backlog)
{
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801998:	8b 45 08             	mov    0x8(%ebp),%eax
  80199b:	e8 99 fe ff ff       	call   801839 <fd2sockid>
  8019a0:	89 c2                	mov    %eax,%edx
  8019a2:	85 d2                	test   %edx,%edx
  8019a4:	78 0f                	js     8019b5 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  8019a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ad:	89 14 24             	mov    %edx,(%esp)
  8019b0:	e8 a4 01 00 00       	call   801b59 <nsipc_listen>
}
  8019b5:	c9                   	leave  
  8019b6:	c3                   	ret    

008019b7 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8019b7:	55                   	push   %ebp
  8019b8:	89 e5                	mov    %esp,%ebp
  8019ba:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8019bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8019c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ce:	89 04 24             	mov    %eax,(%esp)
  8019d1:	e8 98 02 00 00       	call   801c6e <nsipc_socket>
  8019d6:	89 c2                	mov    %eax,%edx
  8019d8:	85 d2                	test   %edx,%edx
  8019da:	78 05                	js     8019e1 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  8019dc:	e8 8a fe ff ff       	call   80186b <alloc_sockfd>
}
  8019e1:	c9                   	leave  
  8019e2:	c3                   	ret    

008019e3 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8019e3:	55                   	push   %ebp
  8019e4:	89 e5                	mov    %esp,%ebp
  8019e6:	53                   	push   %ebx
  8019e7:	83 ec 14             	sub    $0x14,%esp
  8019ea:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8019ec:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8019f3:	75 11                	jne    801a06 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8019f5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8019fc:	e8 04 09 00 00       	call   802305 <ipc_find_env>
  801a01:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801a06:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a0d:	00 
  801a0e:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801a15:	00 
  801a16:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a1a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a1f:	89 04 24             	mov    %eax,(%esp)
  801a22:	e8 73 08 00 00       	call   80229a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801a27:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a2e:	00 
  801a2f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a36:	00 
  801a37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a3e:	e8 dd 07 00 00       	call   802220 <ipc_recv>
}
  801a43:	83 c4 14             	add    $0x14,%esp
  801a46:	5b                   	pop    %ebx
  801a47:	5d                   	pop    %ebp
  801a48:	c3                   	ret    

00801a49 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a49:	55                   	push   %ebp
  801a4a:	89 e5                	mov    %esp,%ebp
  801a4c:	56                   	push   %esi
  801a4d:	53                   	push   %ebx
  801a4e:	83 ec 10             	sub    $0x10,%esp
  801a51:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801a54:	8b 45 08             	mov    0x8(%ebp),%eax
  801a57:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801a5c:	8b 06                	mov    (%esi),%eax
  801a5e:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801a63:	b8 01 00 00 00       	mov    $0x1,%eax
  801a68:	e8 76 ff ff ff       	call   8019e3 <nsipc>
  801a6d:	89 c3                	mov    %eax,%ebx
  801a6f:	85 c0                	test   %eax,%eax
  801a71:	78 23                	js     801a96 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801a73:	a1 10 60 80 00       	mov    0x806010,%eax
  801a78:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a7c:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801a83:	00 
  801a84:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a87:	89 04 24             	mov    %eax,(%esp)
  801a8a:	e8 d5 ee ff ff       	call   800964 <memmove>
		*addrlen = ret->ret_addrlen;
  801a8f:	a1 10 60 80 00       	mov    0x806010,%eax
  801a94:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801a96:	89 d8                	mov    %ebx,%eax
  801a98:	83 c4 10             	add    $0x10,%esp
  801a9b:	5b                   	pop    %ebx
  801a9c:	5e                   	pop    %esi
  801a9d:	5d                   	pop    %ebp
  801a9e:	c3                   	ret    

00801a9f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a9f:	55                   	push   %ebp
  801aa0:	89 e5                	mov    %esp,%ebp
  801aa2:	53                   	push   %ebx
  801aa3:	83 ec 14             	sub    $0x14,%esp
  801aa6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801aa9:	8b 45 08             	mov    0x8(%ebp),%eax
  801aac:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801ab1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ab5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801abc:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801ac3:	e8 9c ee ff ff       	call   800964 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801ac8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801ace:	b8 02 00 00 00       	mov    $0x2,%eax
  801ad3:	e8 0b ff ff ff       	call   8019e3 <nsipc>
}
  801ad8:	83 c4 14             	add    $0x14,%esp
  801adb:	5b                   	pop    %ebx
  801adc:	5d                   	pop    %ebp
  801add:	c3                   	ret    

00801ade <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801aec:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aef:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801af4:	b8 03 00 00 00       	mov    $0x3,%eax
  801af9:	e8 e5 fe ff ff       	call   8019e3 <nsipc>
}
  801afe:	c9                   	leave  
  801aff:	c3                   	ret    

00801b00 <nsipc_close>:

int
nsipc_close(int s)
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b06:	8b 45 08             	mov    0x8(%ebp),%eax
  801b09:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801b0e:	b8 04 00 00 00       	mov    $0x4,%eax
  801b13:	e8 cb fe ff ff       	call   8019e3 <nsipc>
}
  801b18:	c9                   	leave  
  801b19:	c3                   	ret    

00801b1a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b1a:	55                   	push   %ebp
  801b1b:	89 e5                	mov    %esp,%ebp
  801b1d:	53                   	push   %ebx
  801b1e:	83 ec 14             	sub    $0x14,%esp
  801b21:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b24:	8b 45 08             	mov    0x8(%ebp),%eax
  801b27:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801b2c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b30:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b33:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b37:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801b3e:	e8 21 ee ff ff       	call   800964 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801b43:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801b49:	b8 05 00 00 00       	mov    $0x5,%eax
  801b4e:	e8 90 fe ff ff       	call   8019e3 <nsipc>
}
  801b53:	83 c4 14             	add    $0x14,%esp
  801b56:	5b                   	pop    %ebx
  801b57:	5d                   	pop    %ebp
  801b58:	c3                   	ret    

00801b59 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801b59:	55                   	push   %ebp
  801b5a:	89 e5                	mov    %esp,%ebp
  801b5c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801b5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b62:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801b67:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b6a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801b6f:	b8 06 00 00 00       	mov    $0x6,%eax
  801b74:	e8 6a fe ff ff       	call   8019e3 <nsipc>
}
  801b79:	c9                   	leave  
  801b7a:	c3                   	ret    

00801b7b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	56                   	push   %esi
  801b7f:	53                   	push   %ebx
  801b80:	83 ec 10             	sub    $0x10,%esp
  801b83:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801b86:	8b 45 08             	mov    0x8(%ebp),%eax
  801b89:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801b8e:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801b94:	8b 45 14             	mov    0x14(%ebp),%eax
  801b97:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801b9c:	b8 07 00 00 00       	mov    $0x7,%eax
  801ba1:	e8 3d fe ff ff       	call   8019e3 <nsipc>
  801ba6:	89 c3                	mov    %eax,%ebx
  801ba8:	85 c0                	test   %eax,%eax
  801baa:	78 46                	js     801bf2 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801bac:	39 f0                	cmp    %esi,%eax
  801bae:	7f 07                	jg     801bb7 <nsipc_recv+0x3c>
  801bb0:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801bb5:	7e 24                	jle    801bdb <nsipc_recv+0x60>
  801bb7:	c7 44 24 0c 9b 2a 80 	movl   $0x802a9b,0xc(%esp)
  801bbe:	00 
  801bbf:	c7 44 24 08 63 2a 80 	movl   $0x802a63,0x8(%esp)
  801bc6:	00 
  801bc7:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801bce:	00 
  801bcf:	c7 04 24 b0 2a 80 00 	movl   $0x802ab0,(%esp)
  801bd6:	e8 eb 05 00 00       	call   8021c6 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801bdb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bdf:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801be6:	00 
  801be7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bea:	89 04 24             	mov    %eax,(%esp)
  801bed:	e8 72 ed ff ff       	call   800964 <memmove>
	}

	return r;
}
  801bf2:	89 d8                	mov    %ebx,%eax
  801bf4:	83 c4 10             	add    $0x10,%esp
  801bf7:	5b                   	pop    %ebx
  801bf8:	5e                   	pop    %esi
  801bf9:	5d                   	pop    %ebp
  801bfa:	c3                   	ret    

00801bfb <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	53                   	push   %ebx
  801bff:	83 ec 14             	sub    $0x14,%esp
  801c02:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c05:	8b 45 08             	mov    0x8(%ebp),%eax
  801c08:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801c0d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c13:	7e 24                	jle    801c39 <nsipc_send+0x3e>
  801c15:	c7 44 24 0c bc 2a 80 	movl   $0x802abc,0xc(%esp)
  801c1c:	00 
  801c1d:	c7 44 24 08 63 2a 80 	movl   $0x802a63,0x8(%esp)
  801c24:	00 
  801c25:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801c2c:	00 
  801c2d:	c7 04 24 b0 2a 80 00 	movl   $0x802ab0,(%esp)
  801c34:	e8 8d 05 00 00       	call   8021c6 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c40:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c44:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801c4b:	e8 14 ed ff ff       	call   800964 <memmove>
	nsipcbuf.send.req_size = size;
  801c50:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801c56:	8b 45 14             	mov    0x14(%ebp),%eax
  801c59:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801c5e:	b8 08 00 00 00       	mov    $0x8,%eax
  801c63:	e8 7b fd ff ff       	call   8019e3 <nsipc>
}
  801c68:	83 c4 14             	add    $0x14,%esp
  801c6b:	5b                   	pop    %ebx
  801c6c:	5d                   	pop    %ebp
  801c6d:	c3                   	ret    

00801c6e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801c6e:	55                   	push   %ebp
  801c6f:	89 e5                	mov    %esp,%ebp
  801c71:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c74:	8b 45 08             	mov    0x8(%ebp),%eax
  801c77:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801c7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c7f:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801c84:	8b 45 10             	mov    0x10(%ebp),%eax
  801c87:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801c8c:	b8 09 00 00 00       	mov    $0x9,%eax
  801c91:	e8 4d fd ff ff       	call   8019e3 <nsipc>
}
  801c96:	c9                   	leave  
  801c97:	c3                   	ret    

00801c98 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c98:	55                   	push   %ebp
  801c99:	89 e5                	mov    %esp,%ebp
  801c9b:	56                   	push   %esi
  801c9c:	53                   	push   %ebx
  801c9d:	83 ec 10             	sub    $0x10,%esp
  801ca0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ca3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca6:	89 04 24             	mov    %eax,(%esp)
  801ca9:	e8 72 f2 ff ff       	call   800f20 <fd2data>
  801cae:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cb0:	c7 44 24 04 c8 2a 80 	movl   $0x802ac8,0x4(%esp)
  801cb7:	00 
  801cb8:	89 1c 24             	mov    %ebx,(%esp)
  801cbb:	e8 07 eb ff ff       	call   8007c7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cc0:	8b 46 04             	mov    0x4(%esi),%eax
  801cc3:	2b 06                	sub    (%esi),%eax
  801cc5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ccb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cd2:	00 00 00 
	stat->st_dev = &devpipe;
  801cd5:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801cdc:	30 80 00 
	return 0;
}
  801cdf:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce4:	83 c4 10             	add    $0x10,%esp
  801ce7:	5b                   	pop    %ebx
  801ce8:	5e                   	pop    %esi
  801ce9:	5d                   	pop    %ebp
  801cea:	c3                   	ret    

00801ceb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ceb:	55                   	push   %ebp
  801cec:	89 e5                	mov    %esp,%ebp
  801cee:	53                   	push   %ebx
  801cef:	83 ec 14             	sub    $0x14,%esp
  801cf2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cf5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cf9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d00:	e8 85 ef ff ff       	call   800c8a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d05:	89 1c 24             	mov    %ebx,(%esp)
  801d08:	e8 13 f2 ff ff       	call   800f20 <fd2data>
  801d0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d11:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d18:	e8 6d ef ff ff       	call   800c8a <sys_page_unmap>
}
  801d1d:	83 c4 14             	add    $0x14,%esp
  801d20:	5b                   	pop    %ebx
  801d21:	5d                   	pop    %ebp
  801d22:	c3                   	ret    

00801d23 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d23:	55                   	push   %ebp
  801d24:	89 e5                	mov    %esp,%ebp
  801d26:	57                   	push   %edi
  801d27:	56                   	push   %esi
  801d28:	53                   	push   %ebx
  801d29:	83 ec 2c             	sub    $0x2c,%esp
  801d2c:	89 c6                	mov    %eax,%esi
  801d2e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d31:	a1 08 40 80 00       	mov    0x804008,%eax
  801d36:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d39:	89 34 24             	mov    %esi,(%esp)
  801d3c:	e8 fc 05 00 00       	call   80233d <pageref>
  801d41:	89 c7                	mov    %eax,%edi
  801d43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d46:	89 04 24             	mov    %eax,(%esp)
  801d49:	e8 ef 05 00 00       	call   80233d <pageref>
  801d4e:	39 c7                	cmp    %eax,%edi
  801d50:	0f 94 c2             	sete   %dl
  801d53:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801d56:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801d5c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801d5f:	39 fb                	cmp    %edi,%ebx
  801d61:	74 21                	je     801d84 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801d63:	84 d2                	test   %dl,%dl
  801d65:	74 ca                	je     801d31 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d67:	8b 51 58             	mov    0x58(%ecx),%edx
  801d6a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d6e:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d72:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d76:	c7 04 24 cf 2a 80 00 	movl   $0x802acf,(%esp)
  801d7d:	e8 20 e4 ff ff       	call   8001a2 <cprintf>
  801d82:	eb ad                	jmp    801d31 <_pipeisclosed+0xe>
	}
}
  801d84:	83 c4 2c             	add    $0x2c,%esp
  801d87:	5b                   	pop    %ebx
  801d88:	5e                   	pop    %esi
  801d89:	5f                   	pop    %edi
  801d8a:	5d                   	pop    %ebp
  801d8b:	c3                   	ret    

00801d8c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	57                   	push   %edi
  801d90:	56                   	push   %esi
  801d91:	53                   	push   %ebx
  801d92:	83 ec 1c             	sub    $0x1c,%esp
  801d95:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d98:	89 34 24             	mov    %esi,(%esp)
  801d9b:	e8 80 f1 ff ff       	call   800f20 <fd2data>
  801da0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801da2:	bf 00 00 00 00       	mov    $0x0,%edi
  801da7:	eb 45                	jmp    801dee <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801da9:	89 da                	mov    %ebx,%edx
  801dab:	89 f0                	mov    %esi,%eax
  801dad:	e8 71 ff ff ff       	call   801d23 <_pipeisclosed>
  801db2:	85 c0                	test   %eax,%eax
  801db4:	75 41                	jne    801df7 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801db6:	e8 09 ee ff ff       	call   800bc4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801dbb:	8b 43 04             	mov    0x4(%ebx),%eax
  801dbe:	8b 0b                	mov    (%ebx),%ecx
  801dc0:	8d 51 20             	lea    0x20(%ecx),%edx
  801dc3:	39 d0                	cmp    %edx,%eax
  801dc5:	73 e2                	jae    801da9 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801dc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dca:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801dce:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801dd1:	99                   	cltd   
  801dd2:	c1 ea 1b             	shr    $0x1b,%edx
  801dd5:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801dd8:	83 e1 1f             	and    $0x1f,%ecx
  801ddb:	29 d1                	sub    %edx,%ecx
  801ddd:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801de1:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801de5:	83 c0 01             	add    $0x1,%eax
  801de8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801deb:	83 c7 01             	add    $0x1,%edi
  801dee:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801df1:	75 c8                	jne    801dbb <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801df3:	89 f8                	mov    %edi,%eax
  801df5:	eb 05                	jmp    801dfc <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801df7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801dfc:	83 c4 1c             	add    $0x1c,%esp
  801dff:	5b                   	pop    %ebx
  801e00:	5e                   	pop    %esi
  801e01:	5f                   	pop    %edi
  801e02:	5d                   	pop    %ebp
  801e03:	c3                   	ret    

00801e04 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e04:	55                   	push   %ebp
  801e05:	89 e5                	mov    %esp,%ebp
  801e07:	57                   	push   %edi
  801e08:	56                   	push   %esi
  801e09:	53                   	push   %ebx
  801e0a:	83 ec 1c             	sub    $0x1c,%esp
  801e0d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e10:	89 3c 24             	mov    %edi,(%esp)
  801e13:	e8 08 f1 ff ff       	call   800f20 <fd2data>
  801e18:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e1a:	be 00 00 00 00       	mov    $0x0,%esi
  801e1f:	eb 3d                	jmp    801e5e <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e21:	85 f6                	test   %esi,%esi
  801e23:	74 04                	je     801e29 <devpipe_read+0x25>
				return i;
  801e25:	89 f0                	mov    %esi,%eax
  801e27:	eb 43                	jmp    801e6c <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e29:	89 da                	mov    %ebx,%edx
  801e2b:	89 f8                	mov    %edi,%eax
  801e2d:	e8 f1 fe ff ff       	call   801d23 <_pipeisclosed>
  801e32:	85 c0                	test   %eax,%eax
  801e34:	75 31                	jne    801e67 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e36:	e8 89 ed ff ff       	call   800bc4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e3b:	8b 03                	mov    (%ebx),%eax
  801e3d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e40:	74 df                	je     801e21 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e42:	99                   	cltd   
  801e43:	c1 ea 1b             	shr    $0x1b,%edx
  801e46:	01 d0                	add    %edx,%eax
  801e48:	83 e0 1f             	and    $0x1f,%eax
  801e4b:	29 d0                	sub    %edx,%eax
  801e4d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e55:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801e58:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e5b:	83 c6 01             	add    $0x1,%esi
  801e5e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e61:	75 d8                	jne    801e3b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e63:	89 f0                	mov    %esi,%eax
  801e65:	eb 05                	jmp    801e6c <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e67:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e6c:	83 c4 1c             	add    $0x1c,%esp
  801e6f:	5b                   	pop    %ebx
  801e70:	5e                   	pop    %esi
  801e71:	5f                   	pop    %edi
  801e72:	5d                   	pop    %ebp
  801e73:	c3                   	ret    

00801e74 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e74:	55                   	push   %ebp
  801e75:	89 e5                	mov    %esp,%ebp
  801e77:	56                   	push   %esi
  801e78:	53                   	push   %ebx
  801e79:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e7f:	89 04 24             	mov    %eax,(%esp)
  801e82:	e8 b0 f0 ff ff       	call   800f37 <fd_alloc>
  801e87:	89 c2                	mov    %eax,%edx
  801e89:	85 d2                	test   %edx,%edx
  801e8b:	0f 88 4d 01 00 00    	js     801fde <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e91:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e98:	00 
  801e99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ea0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ea7:	e8 37 ed ff ff       	call   800be3 <sys_page_alloc>
  801eac:	89 c2                	mov    %eax,%edx
  801eae:	85 d2                	test   %edx,%edx
  801eb0:	0f 88 28 01 00 00    	js     801fde <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801eb6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801eb9:	89 04 24             	mov    %eax,(%esp)
  801ebc:	e8 76 f0 ff ff       	call   800f37 <fd_alloc>
  801ec1:	89 c3                	mov    %eax,%ebx
  801ec3:	85 c0                	test   %eax,%eax
  801ec5:	0f 88 fe 00 00 00    	js     801fc9 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ecb:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ed2:	00 
  801ed3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ed6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eda:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ee1:	e8 fd ec ff ff       	call   800be3 <sys_page_alloc>
  801ee6:	89 c3                	mov    %eax,%ebx
  801ee8:	85 c0                	test   %eax,%eax
  801eea:	0f 88 d9 00 00 00    	js     801fc9 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ef0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef3:	89 04 24             	mov    %eax,(%esp)
  801ef6:	e8 25 f0 ff ff       	call   800f20 <fd2data>
  801efb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801efd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f04:	00 
  801f05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f10:	e8 ce ec ff ff       	call   800be3 <sys_page_alloc>
  801f15:	89 c3                	mov    %eax,%ebx
  801f17:	85 c0                	test   %eax,%eax
  801f19:	0f 88 97 00 00 00    	js     801fb6 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f22:	89 04 24             	mov    %eax,(%esp)
  801f25:	e8 f6 ef ff ff       	call   800f20 <fd2data>
  801f2a:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801f31:	00 
  801f32:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f36:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f3d:	00 
  801f3e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f42:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f49:	e8 e9 ec ff ff       	call   800c37 <sys_page_map>
  801f4e:	89 c3                	mov    %eax,%ebx
  801f50:	85 c0                	test   %eax,%eax
  801f52:	78 52                	js     801fa6 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f54:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f5d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f62:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f69:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f72:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f74:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f77:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f81:	89 04 24             	mov    %eax,(%esp)
  801f84:	e8 87 ef ff ff       	call   800f10 <fd2num>
  801f89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f8c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f91:	89 04 24             	mov    %eax,(%esp)
  801f94:	e8 77 ef ff ff       	call   800f10 <fd2num>
  801f99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f9c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa4:	eb 38                	jmp    801fde <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  801fa6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801faa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fb1:	e8 d4 ec ff ff       	call   800c8a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801fb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fb9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fbd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fc4:	e8 c1 ec ff ff       	call   800c8a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801fc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fcc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fd7:	e8 ae ec ff ff       	call   800c8a <sys_page_unmap>
  801fdc:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801fde:	83 c4 30             	add    $0x30,%esp
  801fe1:	5b                   	pop    %ebx
  801fe2:	5e                   	pop    %esi
  801fe3:	5d                   	pop    %ebp
  801fe4:	c3                   	ret    

00801fe5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801fe5:	55                   	push   %ebp
  801fe6:	89 e5                	mov    %esp,%ebp
  801fe8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801feb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fee:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ff2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff5:	89 04 24             	mov    %eax,(%esp)
  801ff8:	e8 89 ef ff ff       	call   800f86 <fd_lookup>
  801ffd:	89 c2                	mov    %eax,%edx
  801fff:	85 d2                	test   %edx,%edx
  802001:	78 15                	js     802018 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802003:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802006:	89 04 24             	mov    %eax,(%esp)
  802009:	e8 12 ef ff ff       	call   800f20 <fd2data>
	return _pipeisclosed(fd, p);
  80200e:	89 c2                	mov    %eax,%edx
  802010:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802013:	e8 0b fd ff ff       	call   801d23 <_pipeisclosed>
}
  802018:	c9                   	leave  
  802019:	c3                   	ret    
  80201a:	66 90                	xchg   %ax,%ax
  80201c:	66 90                	xchg   %ax,%ax
  80201e:	66 90                	xchg   %ax,%ax

00802020 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802023:	b8 00 00 00 00       	mov    $0x0,%eax
  802028:	5d                   	pop    %ebp
  802029:	c3                   	ret    

0080202a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80202a:	55                   	push   %ebp
  80202b:	89 e5                	mov    %esp,%ebp
  80202d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802030:	c7 44 24 04 e7 2a 80 	movl   $0x802ae7,0x4(%esp)
  802037:	00 
  802038:	8b 45 0c             	mov    0xc(%ebp),%eax
  80203b:	89 04 24             	mov    %eax,(%esp)
  80203e:	e8 84 e7 ff ff       	call   8007c7 <strcpy>
	return 0;
}
  802043:	b8 00 00 00 00       	mov    $0x0,%eax
  802048:	c9                   	leave  
  802049:	c3                   	ret    

0080204a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80204a:	55                   	push   %ebp
  80204b:	89 e5                	mov    %esp,%ebp
  80204d:	57                   	push   %edi
  80204e:	56                   	push   %esi
  80204f:	53                   	push   %ebx
  802050:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802056:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80205b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802061:	eb 31                	jmp    802094 <devcons_write+0x4a>
		m = n - tot;
  802063:	8b 75 10             	mov    0x10(%ebp),%esi
  802066:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802068:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80206b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802070:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802073:	89 74 24 08          	mov    %esi,0x8(%esp)
  802077:	03 45 0c             	add    0xc(%ebp),%eax
  80207a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80207e:	89 3c 24             	mov    %edi,(%esp)
  802081:	e8 de e8 ff ff       	call   800964 <memmove>
		sys_cputs(buf, m);
  802086:	89 74 24 04          	mov    %esi,0x4(%esp)
  80208a:	89 3c 24             	mov    %edi,(%esp)
  80208d:	e8 84 ea ff ff       	call   800b16 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802092:	01 f3                	add    %esi,%ebx
  802094:	89 d8                	mov    %ebx,%eax
  802096:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802099:	72 c8                	jb     802063 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80209b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8020a1:	5b                   	pop    %ebx
  8020a2:	5e                   	pop    %esi
  8020a3:	5f                   	pop    %edi
  8020a4:	5d                   	pop    %ebp
  8020a5:	c3                   	ret    

008020a6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020a6:	55                   	push   %ebp
  8020a7:	89 e5                	mov    %esp,%ebp
  8020a9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8020ac:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8020b1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020b5:	75 07                	jne    8020be <devcons_read+0x18>
  8020b7:	eb 2a                	jmp    8020e3 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8020b9:	e8 06 eb ff ff       	call   800bc4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8020be:	66 90                	xchg   %ax,%ax
  8020c0:	e8 6f ea ff ff       	call   800b34 <sys_cgetc>
  8020c5:	85 c0                	test   %eax,%eax
  8020c7:	74 f0                	je     8020b9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8020c9:	85 c0                	test   %eax,%eax
  8020cb:	78 16                	js     8020e3 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8020cd:	83 f8 04             	cmp    $0x4,%eax
  8020d0:	74 0c                	je     8020de <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  8020d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020d5:	88 02                	mov    %al,(%edx)
	return 1;
  8020d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8020dc:	eb 05                	jmp    8020e3 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020de:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020e3:	c9                   	leave  
  8020e4:	c3                   	ret    

008020e5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020e5:	55                   	push   %ebp
  8020e6:	89 e5                	mov    %esp,%ebp
  8020e8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8020eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ee:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020f1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8020f8:	00 
  8020f9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020fc:	89 04 24             	mov    %eax,(%esp)
  8020ff:	e8 12 ea ff ff       	call   800b16 <sys_cputs>
}
  802104:	c9                   	leave  
  802105:	c3                   	ret    

00802106 <getchar>:

int
getchar(void)
{
  802106:	55                   	push   %ebp
  802107:	89 e5                	mov    %esp,%ebp
  802109:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80210c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802113:	00 
  802114:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802117:	89 44 24 04          	mov    %eax,0x4(%esp)
  80211b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802122:	e8 f3 f0 ff ff       	call   80121a <read>
	if (r < 0)
  802127:	85 c0                	test   %eax,%eax
  802129:	78 0f                	js     80213a <getchar+0x34>
		return r;
	if (r < 1)
  80212b:	85 c0                	test   %eax,%eax
  80212d:	7e 06                	jle    802135 <getchar+0x2f>
		return -E_EOF;
	return c;
  80212f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802133:	eb 05                	jmp    80213a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802135:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80213a:	c9                   	leave  
  80213b:	c3                   	ret    

0080213c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80213c:	55                   	push   %ebp
  80213d:	89 e5                	mov    %esp,%ebp
  80213f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802142:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802145:	89 44 24 04          	mov    %eax,0x4(%esp)
  802149:	8b 45 08             	mov    0x8(%ebp),%eax
  80214c:	89 04 24             	mov    %eax,(%esp)
  80214f:	e8 32 ee ff ff       	call   800f86 <fd_lookup>
  802154:	85 c0                	test   %eax,%eax
  802156:	78 11                	js     802169 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802158:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80215b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802161:	39 10                	cmp    %edx,(%eax)
  802163:	0f 94 c0             	sete   %al
  802166:	0f b6 c0             	movzbl %al,%eax
}
  802169:	c9                   	leave  
  80216a:	c3                   	ret    

0080216b <opencons>:

int
opencons(void)
{
  80216b:	55                   	push   %ebp
  80216c:	89 e5                	mov    %esp,%ebp
  80216e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802171:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802174:	89 04 24             	mov    %eax,(%esp)
  802177:	e8 bb ed ff ff       	call   800f37 <fd_alloc>
		return r;
  80217c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80217e:	85 c0                	test   %eax,%eax
  802180:	78 40                	js     8021c2 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802182:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802189:	00 
  80218a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80218d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802191:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802198:	e8 46 ea ff ff       	call   800be3 <sys_page_alloc>
		return r;
  80219d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80219f:	85 c0                	test   %eax,%eax
  8021a1:	78 1f                	js     8021c2 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021a3:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ac:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021b8:	89 04 24             	mov    %eax,(%esp)
  8021bb:	e8 50 ed ff ff       	call   800f10 <fd2num>
  8021c0:	89 c2                	mov    %eax,%edx
}
  8021c2:	89 d0                	mov    %edx,%eax
  8021c4:	c9                   	leave  
  8021c5:	c3                   	ret    

008021c6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8021c6:	55                   	push   %ebp
  8021c7:	89 e5                	mov    %esp,%ebp
  8021c9:	56                   	push   %esi
  8021ca:	53                   	push   %ebx
  8021cb:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8021ce:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8021d1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8021d7:	e8 c9 e9 ff ff       	call   800ba5 <sys_getenvid>
  8021dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021df:	89 54 24 10          	mov    %edx,0x10(%esp)
  8021e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8021e6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021ea:	89 74 24 08          	mov    %esi,0x8(%esp)
  8021ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021f2:	c7 04 24 f4 2a 80 00 	movl   $0x802af4,(%esp)
  8021f9:	e8 a4 df ff ff       	call   8001a2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8021fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802202:	8b 45 10             	mov    0x10(%ebp),%eax
  802205:	89 04 24             	mov    %eax,(%esp)
  802208:	e8 34 df ff ff       	call   800141 <vcprintf>
	cprintf("\n");
  80220d:	c7 04 24 e0 2a 80 00 	movl   $0x802ae0,(%esp)
  802214:	e8 89 df ff ff       	call   8001a2 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802219:	cc                   	int3   
  80221a:	eb fd                	jmp    802219 <_panic+0x53>
  80221c:	66 90                	xchg   %ax,%ax
  80221e:	66 90                	xchg   %ax,%ax

00802220 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802220:	55                   	push   %ebp
  802221:	89 e5                	mov    %esp,%ebp
  802223:	56                   	push   %esi
  802224:	53                   	push   %ebx
  802225:	83 ec 10             	sub    $0x10,%esp
  802228:	8b 75 08             	mov    0x8(%ebp),%esi
  80222b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80222e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  802231:	85 c0                	test   %eax,%eax
  802233:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802238:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  80223b:	89 04 24             	mov    %eax,(%esp)
  80223e:	e8 b6 eb ff ff       	call   800df9 <sys_ipc_recv>

	if(ret < 0) {
  802243:	85 c0                	test   %eax,%eax
  802245:	79 16                	jns    80225d <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  802247:	85 f6                	test   %esi,%esi
  802249:	74 06                	je     802251 <ipc_recv+0x31>
  80224b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  802251:	85 db                	test   %ebx,%ebx
  802253:	74 3e                	je     802293 <ipc_recv+0x73>
  802255:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80225b:	eb 36                	jmp    802293 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  80225d:	e8 43 e9 ff ff       	call   800ba5 <sys_getenvid>
  802262:	25 ff 03 00 00       	and    $0x3ff,%eax
  802267:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80226a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80226f:	a3 08 40 80 00       	mov    %eax,0x804008

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802274:	85 f6                	test   %esi,%esi
  802276:	74 05                	je     80227d <ipc_recv+0x5d>
  802278:	8b 40 74             	mov    0x74(%eax),%eax
  80227b:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80227d:	85 db                	test   %ebx,%ebx
  80227f:	74 0a                	je     80228b <ipc_recv+0x6b>
  802281:	a1 08 40 80 00       	mov    0x804008,%eax
  802286:	8b 40 78             	mov    0x78(%eax),%eax
  802289:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  80228b:	a1 08 40 80 00       	mov    0x804008,%eax
  802290:	8b 40 70             	mov    0x70(%eax),%eax
}
  802293:	83 c4 10             	add    $0x10,%esp
  802296:	5b                   	pop    %ebx
  802297:	5e                   	pop    %esi
  802298:	5d                   	pop    %ebp
  802299:	c3                   	ret    

0080229a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80229a:	55                   	push   %ebp
  80229b:	89 e5                	mov    %esp,%ebp
  80229d:	57                   	push   %edi
  80229e:	56                   	push   %esi
  80229f:	53                   	push   %ebx
  8022a0:	83 ec 1c             	sub    $0x1c,%esp
  8022a3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022a6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  8022ac:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  8022ae:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8022b3:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  8022b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8022b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022bd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022c5:	89 3c 24             	mov    %edi,(%esp)
  8022c8:	e8 09 eb ff ff       	call   800dd6 <sys_ipc_try_send>

		if(ret >= 0) break;
  8022cd:	85 c0                	test   %eax,%eax
  8022cf:	79 2c                	jns    8022fd <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  8022d1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022d4:	74 20                	je     8022f6 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  8022d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022da:	c7 44 24 08 18 2b 80 	movl   $0x802b18,0x8(%esp)
  8022e1:	00 
  8022e2:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8022e9:	00 
  8022ea:	c7 04 24 48 2b 80 00 	movl   $0x802b48,(%esp)
  8022f1:	e8 d0 fe ff ff       	call   8021c6 <_panic>
		}
		sys_yield();
  8022f6:	e8 c9 e8 ff ff       	call   800bc4 <sys_yield>
	}
  8022fb:	eb b9                	jmp    8022b6 <ipc_send+0x1c>
}
  8022fd:	83 c4 1c             	add    $0x1c,%esp
  802300:	5b                   	pop    %ebx
  802301:	5e                   	pop    %esi
  802302:	5f                   	pop    %edi
  802303:	5d                   	pop    %ebp
  802304:	c3                   	ret    

00802305 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802305:	55                   	push   %ebp
  802306:	89 e5                	mov    %esp,%ebp
  802308:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80230b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802310:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802313:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802319:	8b 52 50             	mov    0x50(%edx),%edx
  80231c:	39 ca                	cmp    %ecx,%edx
  80231e:	75 0d                	jne    80232d <ipc_find_env+0x28>
			return envs[i].env_id;
  802320:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802323:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802328:	8b 40 40             	mov    0x40(%eax),%eax
  80232b:	eb 0e                	jmp    80233b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80232d:	83 c0 01             	add    $0x1,%eax
  802330:	3d 00 04 00 00       	cmp    $0x400,%eax
  802335:	75 d9                	jne    802310 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802337:	66 b8 00 00          	mov    $0x0,%ax
}
  80233b:	5d                   	pop    %ebp
  80233c:	c3                   	ret    

0080233d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80233d:	55                   	push   %ebp
  80233e:	89 e5                	mov    %esp,%ebp
  802340:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802343:	89 d0                	mov    %edx,%eax
  802345:	c1 e8 16             	shr    $0x16,%eax
  802348:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80234f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802354:	f6 c1 01             	test   $0x1,%cl
  802357:	74 1d                	je     802376 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802359:	c1 ea 0c             	shr    $0xc,%edx
  80235c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802363:	f6 c2 01             	test   $0x1,%dl
  802366:	74 0e                	je     802376 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802368:	c1 ea 0c             	shr    $0xc,%edx
  80236b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802372:	ef 
  802373:	0f b7 c0             	movzwl %ax,%eax
}
  802376:	5d                   	pop    %ebp
  802377:	c3                   	ret    
  802378:	66 90                	xchg   %ax,%ax
  80237a:	66 90                	xchg   %ax,%ax
  80237c:	66 90                	xchg   %ax,%ax
  80237e:	66 90                	xchg   %ax,%ax

00802380 <__udivdi3>:
  802380:	55                   	push   %ebp
  802381:	57                   	push   %edi
  802382:	56                   	push   %esi
  802383:	83 ec 0c             	sub    $0xc,%esp
  802386:	8b 44 24 28          	mov    0x28(%esp),%eax
  80238a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80238e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802392:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802396:	85 c0                	test   %eax,%eax
  802398:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80239c:	89 ea                	mov    %ebp,%edx
  80239e:	89 0c 24             	mov    %ecx,(%esp)
  8023a1:	75 2d                	jne    8023d0 <__udivdi3+0x50>
  8023a3:	39 e9                	cmp    %ebp,%ecx
  8023a5:	77 61                	ja     802408 <__udivdi3+0x88>
  8023a7:	85 c9                	test   %ecx,%ecx
  8023a9:	89 ce                	mov    %ecx,%esi
  8023ab:	75 0b                	jne    8023b8 <__udivdi3+0x38>
  8023ad:	b8 01 00 00 00       	mov    $0x1,%eax
  8023b2:	31 d2                	xor    %edx,%edx
  8023b4:	f7 f1                	div    %ecx
  8023b6:	89 c6                	mov    %eax,%esi
  8023b8:	31 d2                	xor    %edx,%edx
  8023ba:	89 e8                	mov    %ebp,%eax
  8023bc:	f7 f6                	div    %esi
  8023be:	89 c5                	mov    %eax,%ebp
  8023c0:	89 f8                	mov    %edi,%eax
  8023c2:	f7 f6                	div    %esi
  8023c4:	89 ea                	mov    %ebp,%edx
  8023c6:	83 c4 0c             	add    $0xc,%esp
  8023c9:	5e                   	pop    %esi
  8023ca:	5f                   	pop    %edi
  8023cb:	5d                   	pop    %ebp
  8023cc:	c3                   	ret    
  8023cd:	8d 76 00             	lea    0x0(%esi),%esi
  8023d0:	39 e8                	cmp    %ebp,%eax
  8023d2:	77 24                	ja     8023f8 <__udivdi3+0x78>
  8023d4:	0f bd e8             	bsr    %eax,%ebp
  8023d7:	83 f5 1f             	xor    $0x1f,%ebp
  8023da:	75 3c                	jne    802418 <__udivdi3+0x98>
  8023dc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8023e0:	39 34 24             	cmp    %esi,(%esp)
  8023e3:	0f 86 9f 00 00 00    	jbe    802488 <__udivdi3+0x108>
  8023e9:	39 d0                	cmp    %edx,%eax
  8023eb:	0f 82 97 00 00 00    	jb     802488 <__udivdi3+0x108>
  8023f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023f8:	31 d2                	xor    %edx,%edx
  8023fa:	31 c0                	xor    %eax,%eax
  8023fc:	83 c4 0c             	add    $0xc,%esp
  8023ff:	5e                   	pop    %esi
  802400:	5f                   	pop    %edi
  802401:	5d                   	pop    %ebp
  802402:	c3                   	ret    
  802403:	90                   	nop
  802404:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802408:	89 f8                	mov    %edi,%eax
  80240a:	f7 f1                	div    %ecx
  80240c:	31 d2                	xor    %edx,%edx
  80240e:	83 c4 0c             	add    $0xc,%esp
  802411:	5e                   	pop    %esi
  802412:	5f                   	pop    %edi
  802413:	5d                   	pop    %ebp
  802414:	c3                   	ret    
  802415:	8d 76 00             	lea    0x0(%esi),%esi
  802418:	89 e9                	mov    %ebp,%ecx
  80241a:	8b 3c 24             	mov    (%esp),%edi
  80241d:	d3 e0                	shl    %cl,%eax
  80241f:	89 c6                	mov    %eax,%esi
  802421:	b8 20 00 00 00       	mov    $0x20,%eax
  802426:	29 e8                	sub    %ebp,%eax
  802428:	89 c1                	mov    %eax,%ecx
  80242a:	d3 ef                	shr    %cl,%edi
  80242c:	89 e9                	mov    %ebp,%ecx
  80242e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802432:	8b 3c 24             	mov    (%esp),%edi
  802435:	09 74 24 08          	or     %esi,0x8(%esp)
  802439:	89 d6                	mov    %edx,%esi
  80243b:	d3 e7                	shl    %cl,%edi
  80243d:	89 c1                	mov    %eax,%ecx
  80243f:	89 3c 24             	mov    %edi,(%esp)
  802442:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802446:	d3 ee                	shr    %cl,%esi
  802448:	89 e9                	mov    %ebp,%ecx
  80244a:	d3 e2                	shl    %cl,%edx
  80244c:	89 c1                	mov    %eax,%ecx
  80244e:	d3 ef                	shr    %cl,%edi
  802450:	09 d7                	or     %edx,%edi
  802452:	89 f2                	mov    %esi,%edx
  802454:	89 f8                	mov    %edi,%eax
  802456:	f7 74 24 08          	divl   0x8(%esp)
  80245a:	89 d6                	mov    %edx,%esi
  80245c:	89 c7                	mov    %eax,%edi
  80245e:	f7 24 24             	mull   (%esp)
  802461:	39 d6                	cmp    %edx,%esi
  802463:	89 14 24             	mov    %edx,(%esp)
  802466:	72 30                	jb     802498 <__udivdi3+0x118>
  802468:	8b 54 24 04          	mov    0x4(%esp),%edx
  80246c:	89 e9                	mov    %ebp,%ecx
  80246e:	d3 e2                	shl    %cl,%edx
  802470:	39 c2                	cmp    %eax,%edx
  802472:	73 05                	jae    802479 <__udivdi3+0xf9>
  802474:	3b 34 24             	cmp    (%esp),%esi
  802477:	74 1f                	je     802498 <__udivdi3+0x118>
  802479:	89 f8                	mov    %edi,%eax
  80247b:	31 d2                	xor    %edx,%edx
  80247d:	e9 7a ff ff ff       	jmp    8023fc <__udivdi3+0x7c>
  802482:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802488:	31 d2                	xor    %edx,%edx
  80248a:	b8 01 00 00 00       	mov    $0x1,%eax
  80248f:	e9 68 ff ff ff       	jmp    8023fc <__udivdi3+0x7c>
  802494:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802498:	8d 47 ff             	lea    -0x1(%edi),%eax
  80249b:	31 d2                	xor    %edx,%edx
  80249d:	83 c4 0c             	add    $0xc,%esp
  8024a0:	5e                   	pop    %esi
  8024a1:	5f                   	pop    %edi
  8024a2:	5d                   	pop    %ebp
  8024a3:	c3                   	ret    
  8024a4:	66 90                	xchg   %ax,%ax
  8024a6:	66 90                	xchg   %ax,%ax
  8024a8:	66 90                	xchg   %ax,%ax
  8024aa:	66 90                	xchg   %ax,%ax
  8024ac:	66 90                	xchg   %ax,%ax
  8024ae:	66 90                	xchg   %ax,%ax

008024b0 <__umoddi3>:
  8024b0:	55                   	push   %ebp
  8024b1:	57                   	push   %edi
  8024b2:	56                   	push   %esi
  8024b3:	83 ec 14             	sub    $0x14,%esp
  8024b6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8024ba:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8024be:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8024c2:	89 c7                	mov    %eax,%edi
  8024c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024c8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8024cc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8024d0:	89 34 24             	mov    %esi,(%esp)
  8024d3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024d7:	85 c0                	test   %eax,%eax
  8024d9:	89 c2                	mov    %eax,%edx
  8024db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024df:	75 17                	jne    8024f8 <__umoddi3+0x48>
  8024e1:	39 fe                	cmp    %edi,%esi
  8024e3:	76 4b                	jbe    802530 <__umoddi3+0x80>
  8024e5:	89 c8                	mov    %ecx,%eax
  8024e7:	89 fa                	mov    %edi,%edx
  8024e9:	f7 f6                	div    %esi
  8024eb:	89 d0                	mov    %edx,%eax
  8024ed:	31 d2                	xor    %edx,%edx
  8024ef:	83 c4 14             	add    $0x14,%esp
  8024f2:	5e                   	pop    %esi
  8024f3:	5f                   	pop    %edi
  8024f4:	5d                   	pop    %ebp
  8024f5:	c3                   	ret    
  8024f6:	66 90                	xchg   %ax,%ax
  8024f8:	39 f8                	cmp    %edi,%eax
  8024fa:	77 54                	ja     802550 <__umoddi3+0xa0>
  8024fc:	0f bd e8             	bsr    %eax,%ebp
  8024ff:	83 f5 1f             	xor    $0x1f,%ebp
  802502:	75 5c                	jne    802560 <__umoddi3+0xb0>
  802504:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802508:	39 3c 24             	cmp    %edi,(%esp)
  80250b:	0f 87 e7 00 00 00    	ja     8025f8 <__umoddi3+0x148>
  802511:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802515:	29 f1                	sub    %esi,%ecx
  802517:	19 c7                	sbb    %eax,%edi
  802519:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80251d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802521:	8b 44 24 08          	mov    0x8(%esp),%eax
  802525:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802529:	83 c4 14             	add    $0x14,%esp
  80252c:	5e                   	pop    %esi
  80252d:	5f                   	pop    %edi
  80252e:	5d                   	pop    %ebp
  80252f:	c3                   	ret    
  802530:	85 f6                	test   %esi,%esi
  802532:	89 f5                	mov    %esi,%ebp
  802534:	75 0b                	jne    802541 <__umoddi3+0x91>
  802536:	b8 01 00 00 00       	mov    $0x1,%eax
  80253b:	31 d2                	xor    %edx,%edx
  80253d:	f7 f6                	div    %esi
  80253f:	89 c5                	mov    %eax,%ebp
  802541:	8b 44 24 04          	mov    0x4(%esp),%eax
  802545:	31 d2                	xor    %edx,%edx
  802547:	f7 f5                	div    %ebp
  802549:	89 c8                	mov    %ecx,%eax
  80254b:	f7 f5                	div    %ebp
  80254d:	eb 9c                	jmp    8024eb <__umoddi3+0x3b>
  80254f:	90                   	nop
  802550:	89 c8                	mov    %ecx,%eax
  802552:	89 fa                	mov    %edi,%edx
  802554:	83 c4 14             	add    $0x14,%esp
  802557:	5e                   	pop    %esi
  802558:	5f                   	pop    %edi
  802559:	5d                   	pop    %ebp
  80255a:	c3                   	ret    
  80255b:	90                   	nop
  80255c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802560:	8b 04 24             	mov    (%esp),%eax
  802563:	be 20 00 00 00       	mov    $0x20,%esi
  802568:	89 e9                	mov    %ebp,%ecx
  80256a:	29 ee                	sub    %ebp,%esi
  80256c:	d3 e2                	shl    %cl,%edx
  80256e:	89 f1                	mov    %esi,%ecx
  802570:	d3 e8                	shr    %cl,%eax
  802572:	89 e9                	mov    %ebp,%ecx
  802574:	89 44 24 04          	mov    %eax,0x4(%esp)
  802578:	8b 04 24             	mov    (%esp),%eax
  80257b:	09 54 24 04          	or     %edx,0x4(%esp)
  80257f:	89 fa                	mov    %edi,%edx
  802581:	d3 e0                	shl    %cl,%eax
  802583:	89 f1                	mov    %esi,%ecx
  802585:	89 44 24 08          	mov    %eax,0x8(%esp)
  802589:	8b 44 24 10          	mov    0x10(%esp),%eax
  80258d:	d3 ea                	shr    %cl,%edx
  80258f:	89 e9                	mov    %ebp,%ecx
  802591:	d3 e7                	shl    %cl,%edi
  802593:	89 f1                	mov    %esi,%ecx
  802595:	d3 e8                	shr    %cl,%eax
  802597:	89 e9                	mov    %ebp,%ecx
  802599:	09 f8                	or     %edi,%eax
  80259b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80259f:	f7 74 24 04          	divl   0x4(%esp)
  8025a3:	d3 e7                	shl    %cl,%edi
  8025a5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8025a9:	89 d7                	mov    %edx,%edi
  8025ab:	f7 64 24 08          	mull   0x8(%esp)
  8025af:	39 d7                	cmp    %edx,%edi
  8025b1:	89 c1                	mov    %eax,%ecx
  8025b3:	89 14 24             	mov    %edx,(%esp)
  8025b6:	72 2c                	jb     8025e4 <__umoddi3+0x134>
  8025b8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8025bc:	72 22                	jb     8025e0 <__umoddi3+0x130>
  8025be:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8025c2:	29 c8                	sub    %ecx,%eax
  8025c4:	19 d7                	sbb    %edx,%edi
  8025c6:	89 e9                	mov    %ebp,%ecx
  8025c8:	89 fa                	mov    %edi,%edx
  8025ca:	d3 e8                	shr    %cl,%eax
  8025cc:	89 f1                	mov    %esi,%ecx
  8025ce:	d3 e2                	shl    %cl,%edx
  8025d0:	89 e9                	mov    %ebp,%ecx
  8025d2:	d3 ef                	shr    %cl,%edi
  8025d4:	09 d0                	or     %edx,%eax
  8025d6:	89 fa                	mov    %edi,%edx
  8025d8:	83 c4 14             	add    $0x14,%esp
  8025db:	5e                   	pop    %esi
  8025dc:	5f                   	pop    %edi
  8025dd:	5d                   	pop    %ebp
  8025de:	c3                   	ret    
  8025df:	90                   	nop
  8025e0:	39 d7                	cmp    %edx,%edi
  8025e2:	75 da                	jne    8025be <__umoddi3+0x10e>
  8025e4:	8b 14 24             	mov    (%esp),%edx
  8025e7:	89 c1                	mov    %eax,%ecx
  8025e9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8025ed:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8025f1:	eb cb                	jmp    8025be <__umoddi3+0x10e>
  8025f3:	90                   	nop
  8025f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025f8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8025fc:	0f 82 0f ff ff ff    	jb     802511 <__umoddi3+0x61>
  802602:	e9 1a ff ff ff       	jmp    802521 <__umoddi3+0x71>
