
obj/user/pingpongs.debug:     file format elf32-i386


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
  80002c:	e8 16 01 00 00       	call   800147 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 3c             	sub    $0x3c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 6b 12 00 00       	call   8012ac <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 5e                	je     8000a6 <umain+0x73>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 0c 40 80 00    	mov    0x80400c,%ebx
  80004e:	e8 02 0c 00 00       	call   800c55 <sys_getenvid>
  800053:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800057:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005b:	c7 04 24 40 2a 80 00 	movl   $0x802a40,(%esp)
  800062:	e8 e4 01 00 00       	call   80024b <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800067:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006a:	e8 e6 0b 00 00       	call   800c55 <sys_getenvid>
  80006f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800073:	89 44 24 04          	mov    %eax,0x4(%esp)
  800077:	c7 04 24 5a 2a 80 00 	movl   $0x802a5a,(%esp)
  80007e:	e8 c8 01 00 00       	call   80024b <cprintf>
		ipc_send(who, 0, 0, 0);
  800083:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008a:	00 
  80008b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800092:	00 
  800093:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009a:	00 
  80009b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80009e:	89 04 24             	mov    %eax,(%esp)
  8000a1:	e8 a4 12 00 00       	call   80134a <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b5:	00 
  8000b6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 0f 12 00 00       	call   8012d0 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c1:	8b 1d 0c 40 80 00    	mov    0x80400c,%ebx
  8000c7:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000ca:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000cd:	a1 08 40 80 00       	mov    0x804008,%eax
  8000d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000d5:	e8 7b 0b 00 00       	call   800c55 <sys_getenvid>
  8000da:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8000de:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000e6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000e9:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f1:	c7 04 24 70 2a 80 00 	movl   $0x802a70,(%esp)
  8000f8:	e8 4e 01 00 00       	call   80024b <cprintf>
		if (val == 10)
  8000fd:	a1 08 40 80 00       	mov    0x804008,%eax
  800102:	83 f8 0a             	cmp    $0xa,%eax
  800105:	74 38                	je     80013f <umain+0x10c>
			return;
		++val;
  800107:	83 c0 01             	add    $0x1,%eax
  80010a:	a3 08 40 80 00       	mov    %eax,0x804008
		ipc_send(who, 0, 0, 0);
  80010f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800116:	00 
  800117:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800126:	00 
  800127:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012a:	89 04 24             	mov    %eax,(%esp)
  80012d:	e8 18 12 00 00       	call   80134a <ipc_send>
		if (val == 10)
  800132:	83 3d 08 40 80 00 0a 	cmpl   $0xa,0x804008
  800139:	0f 85 67 ff ff ff    	jne    8000a6 <umain+0x73>
			return;
	}

}
  80013f:	83 c4 3c             	add    $0x3c,%esp
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	56                   	push   %esi
  80014b:	53                   	push   %ebx
  80014c:	83 ec 10             	sub    $0x10,%esp
  80014f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800152:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  800155:	e8 fb 0a 00 00       	call   800c55 <sys_getenvid>
  80015a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80015f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800162:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800167:	a3 0c 40 80 00       	mov    %eax,0x80400c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80016c:	85 db                	test   %ebx,%ebx
  80016e:	7e 07                	jle    800177 <libmain+0x30>
		binaryname = argv[0];
  800170:	8b 06                	mov    (%esi),%eax
  800172:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800177:	89 74 24 04          	mov    %esi,0x4(%esp)
  80017b:	89 1c 24             	mov    %ebx,(%esp)
  80017e:	e8 b0 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800183:	e8 07 00 00 00       	call   80018f <exit>
}
  800188:	83 c4 10             	add    $0x10,%esp
  80018b:	5b                   	pop    %ebx
  80018c:	5e                   	pop    %esi
  80018d:	5d                   	pop    %ebp
  80018e:	c3                   	ret    

0080018f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80018f:	55                   	push   %ebp
  800190:	89 e5                	mov    %esp,%ebp
  800192:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800195:	e8 30 14 00 00       	call   8015ca <close_all>
	sys_env_destroy(0);
  80019a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001a1:	e8 5d 0a 00 00       	call   800c03 <sys_env_destroy>
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 14             	sub    $0x14,%esp
  8001af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b2:	8b 13                	mov    (%ebx),%edx
  8001b4:	8d 42 01             	lea    0x1(%edx),%eax
  8001b7:	89 03                	mov    %eax,(%ebx)
  8001b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001bc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001c0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c5:	75 19                	jne    8001e0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001c7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001ce:	00 
  8001cf:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d2:	89 04 24             	mov    %eax,(%esp)
  8001d5:	e8 ec 09 00 00       	call   800bc6 <sys_cputs>
		b->idx = 0;
  8001da:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e4:	83 c4 14             	add    $0x14,%esp
  8001e7:	5b                   	pop    %ebx
  8001e8:	5d                   	pop    %ebp
  8001e9:	c3                   	ret    

008001ea <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001fa:	00 00 00 
	b.cnt = 0;
  8001fd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800204:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800207:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80020e:	8b 45 08             	mov    0x8(%ebp),%eax
  800211:	89 44 24 08          	mov    %eax,0x8(%esp)
  800215:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021f:	c7 04 24 a8 01 80 00 	movl   $0x8001a8,(%esp)
  800226:	e8 b3 01 00 00       	call   8003de <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800231:	89 44 24 04          	mov    %eax,0x4(%esp)
  800235:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023b:	89 04 24             	mov    %eax,(%esp)
  80023e:	e8 83 09 00 00       	call   800bc6 <sys_cputs>

	return b.cnt;
}
  800243:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800249:	c9                   	leave  
  80024a:	c3                   	ret    

0080024b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800251:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800254:	89 44 24 04          	mov    %eax,0x4(%esp)
  800258:	8b 45 08             	mov    0x8(%ebp),%eax
  80025b:	89 04 24             	mov    %eax,(%esp)
  80025e:	e8 87 ff ff ff       	call   8001ea <vcprintf>
	va_end(ap);

	return cnt;
}
  800263:	c9                   	leave  
  800264:	c3                   	ret    
  800265:	66 90                	xchg   %ax,%ax
  800267:	66 90                	xchg   %ax,%ax
  800269:	66 90                	xchg   %ax,%ax
  80026b:	66 90                	xchg   %ax,%ax
  80026d:	66 90                	xchg   %ax,%ax
  80026f:	90                   	nop

00800270 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 3c             	sub    $0x3c,%esp
  800279:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80027c:	89 d7                	mov    %edx,%edi
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800284:	8b 45 0c             	mov    0xc(%ebp),%eax
  800287:	89 c3                	mov    %eax,%ebx
  800289:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80028c:	8b 45 10             	mov    0x10(%ebp),%eax
  80028f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800292:	b9 00 00 00 00       	mov    $0x0,%ecx
  800297:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80029a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80029d:	39 d9                	cmp    %ebx,%ecx
  80029f:	72 05                	jb     8002a6 <printnum+0x36>
  8002a1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002a4:	77 69                	ja     80030f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002a9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002ad:	83 ee 01             	sub    $0x1,%esi
  8002b0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002bc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002c0:	89 c3                	mov    %eax,%ebx
  8002c2:	89 d6                	mov    %edx,%esi
  8002c4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002c7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002ca:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002ce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d5:	89 04 24             	mov    %eax,(%esp)
  8002d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002df:	e8 cc 24 00 00       	call   8027b0 <__udivdi3>
  8002e4:	89 d9                	mov    %ebx,%ecx
  8002e6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002ea:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ee:	89 04 24             	mov    %eax,(%esp)
  8002f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f5:	89 fa                	mov    %edi,%edx
  8002f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002fa:	e8 71 ff ff ff       	call   800270 <printnum>
  8002ff:	eb 1b                	jmp    80031c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800301:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800305:	8b 45 18             	mov    0x18(%ebp),%eax
  800308:	89 04 24             	mov    %eax,(%esp)
  80030b:	ff d3                	call   *%ebx
  80030d:	eb 03                	jmp    800312 <printnum+0xa2>
  80030f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800312:	83 ee 01             	sub    $0x1,%esi
  800315:	85 f6                	test   %esi,%esi
  800317:	7f e8                	jg     800301 <printnum+0x91>
  800319:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800320:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800324:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800327:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80032a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80032e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800332:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800335:	89 04 24             	mov    %eax,(%esp)
  800338:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80033b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033f:	e8 9c 25 00 00       	call   8028e0 <__umoddi3>
  800344:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800348:	0f be 80 a0 2a 80 00 	movsbl 0x802aa0(%eax),%eax
  80034f:	89 04 24             	mov    %eax,(%esp)
  800352:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800355:	ff d0                	call   *%eax
}
  800357:	83 c4 3c             	add    $0x3c,%esp
  80035a:	5b                   	pop    %ebx
  80035b:	5e                   	pop    %esi
  80035c:	5f                   	pop    %edi
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    

0080035f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800362:	83 fa 01             	cmp    $0x1,%edx
  800365:	7e 0e                	jle    800375 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800367:	8b 10                	mov    (%eax),%edx
  800369:	8d 4a 08             	lea    0x8(%edx),%ecx
  80036c:	89 08                	mov    %ecx,(%eax)
  80036e:	8b 02                	mov    (%edx),%eax
  800370:	8b 52 04             	mov    0x4(%edx),%edx
  800373:	eb 22                	jmp    800397 <getuint+0x38>
	else if (lflag)
  800375:	85 d2                	test   %edx,%edx
  800377:	74 10                	je     800389 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 02                	mov    (%edx),%eax
  800382:	ba 00 00 00 00       	mov    $0x0,%edx
  800387:	eb 0e                	jmp    800397 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800389:	8b 10                	mov    (%eax),%edx
  80038b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80038e:	89 08                	mov    %ecx,(%eax)
  800390:	8b 02                	mov    (%edx),%eax
  800392:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800397:	5d                   	pop    %ebp
  800398:	c3                   	ret    

00800399 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80039f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003a3:	8b 10                	mov    (%eax),%edx
  8003a5:	3b 50 04             	cmp    0x4(%eax),%edx
  8003a8:	73 0a                	jae    8003b4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003aa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003ad:	89 08                	mov    %ecx,(%eax)
  8003af:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b2:	88 02                	mov    %al,(%edx)
}
  8003b4:	5d                   	pop    %ebp
  8003b5:	c3                   	ret    

008003b6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
  8003b9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003bc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d4:	89 04 24             	mov    %eax,(%esp)
  8003d7:	e8 02 00 00 00       	call   8003de <vprintfmt>
	va_end(ap);
}
  8003dc:	c9                   	leave  
  8003dd:	c3                   	ret    

008003de <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003de:	55                   	push   %ebp
  8003df:	89 e5                	mov    %esp,%ebp
  8003e1:	57                   	push   %edi
  8003e2:	56                   	push   %esi
  8003e3:	53                   	push   %ebx
  8003e4:	83 ec 3c             	sub    $0x3c,%esp
  8003e7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003ed:	eb 14                	jmp    800403 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003ef:	85 c0                	test   %eax,%eax
  8003f1:	0f 84 b3 03 00 00    	je     8007aa <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  8003f7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003fb:	89 04 24             	mov    %eax,(%esp)
  8003fe:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800401:	89 f3                	mov    %esi,%ebx
  800403:	8d 73 01             	lea    0x1(%ebx),%esi
  800406:	0f b6 03             	movzbl (%ebx),%eax
  800409:	83 f8 25             	cmp    $0x25,%eax
  80040c:	75 e1                	jne    8003ef <vprintfmt+0x11>
  80040e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800412:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800419:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800420:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800427:	ba 00 00 00 00       	mov    $0x0,%edx
  80042c:	eb 1d                	jmp    80044b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800430:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800434:	eb 15                	jmp    80044b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800436:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800438:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80043c:	eb 0d                	jmp    80044b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80043e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800441:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800444:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80044e:	0f b6 0e             	movzbl (%esi),%ecx
  800451:	0f b6 c1             	movzbl %cl,%eax
  800454:	83 e9 23             	sub    $0x23,%ecx
  800457:	80 f9 55             	cmp    $0x55,%cl
  80045a:	0f 87 2a 03 00 00    	ja     80078a <vprintfmt+0x3ac>
  800460:	0f b6 c9             	movzbl %cl,%ecx
  800463:	ff 24 8d e0 2b 80 00 	jmp    *0x802be0(,%ecx,4)
  80046a:	89 de                	mov    %ebx,%esi
  80046c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800471:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800474:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800478:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80047b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80047e:	83 fb 09             	cmp    $0x9,%ebx
  800481:	77 36                	ja     8004b9 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800483:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800486:	eb e9                	jmp    800471 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800488:	8b 45 14             	mov    0x14(%ebp),%eax
  80048b:	8d 48 04             	lea    0x4(%eax),%ecx
  80048e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800491:	8b 00                	mov    (%eax),%eax
  800493:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800496:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800498:	eb 22                	jmp    8004bc <vprintfmt+0xde>
  80049a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80049d:	85 c9                	test   %ecx,%ecx
  80049f:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a4:	0f 49 c1             	cmovns %ecx,%eax
  8004a7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004aa:	89 de                	mov    %ebx,%esi
  8004ac:	eb 9d                	jmp    80044b <vprintfmt+0x6d>
  8004ae:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004b0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004b7:	eb 92                	jmp    80044b <vprintfmt+0x6d>
  8004b9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8004bc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004c0:	79 89                	jns    80044b <vprintfmt+0x6d>
  8004c2:	e9 77 ff ff ff       	jmp    80043e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004c7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ca:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004cc:	e9 7a ff ff ff       	jmp    80044b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d4:	8d 50 04             	lea    0x4(%eax),%edx
  8004d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004de:	8b 00                	mov    (%eax),%eax
  8004e0:	89 04 24             	mov    %eax,(%esp)
  8004e3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004e6:	e9 18 ff ff ff       	jmp    800403 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ee:	8d 50 04             	lea    0x4(%eax),%edx
  8004f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f4:	8b 00                	mov    (%eax),%eax
  8004f6:	99                   	cltd   
  8004f7:	31 d0                	xor    %edx,%eax
  8004f9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004fb:	83 f8 0f             	cmp    $0xf,%eax
  8004fe:	7f 0b                	jg     80050b <vprintfmt+0x12d>
  800500:	8b 14 85 40 2d 80 00 	mov    0x802d40(,%eax,4),%edx
  800507:	85 d2                	test   %edx,%edx
  800509:	75 20                	jne    80052b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80050b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80050f:	c7 44 24 08 b8 2a 80 	movl   $0x802ab8,0x8(%esp)
  800516:	00 
  800517:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80051b:	8b 45 08             	mov    0x8(%ebp),%eax
  80051e:	89 04 24             	mov    %eax,(%esp)
  800521:	e8 90 fe ff ff       	call   8003b6 <printfmt>
  800526:	e9 d8 fe ff ff       	jmp    800403 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80052b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80052f:	c7 44 24 08 29 2f 80 	movl   $0x802f29,0x8(%esp)
  800536:	00 
  800537:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80053b:	8b 45 08             	mov    0x8(%ebp),%eax
  80053e:	89 04 24             	mov    %eax,(%esp)
  800541:	e8 70 fe ff ff       	call   8003b6 <printfmt>
  800546:	e9 b8 fe ff ff       	jmp    800403 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80054e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800551:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8d 50 04             	lea    0x4(%eax),%edx
  80055a:	89 55 14             	mov    %edx,0x14(%ebp)
  80055d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80055f:	85 f6                	test   %esi,%esi
  800561:	b8 b1 2a 80 00       	mov    $0x802ab1,%eax
  800566:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800569:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80056d:	0f 84 97 00 00 00    	je     80060a <vprintfmt+0x22c>
  800573:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800577:	0f 8e 9b 00 00 00    	jle    800618 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80057d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800581:	89 34 24             	mov    %esi,(%esp)
  800584:	e8 cf 02 00 00       	call   800858 <strnlen>
  800589:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80058c:	29 c2                	sub    %eax,%edx
  80058e:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800591:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800595:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800598:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80059b:	8b 75 08             	mov    0x8(%ebp),%esi
  80059e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005a1:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a3:	eb 0f                	jmp    8005b4 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8005a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005ac:	89 04 24             	mov    %eax,(%esp)
  8005af:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b1:	83 eb 01             	sub    $0x1,%ebx
  8005b4:	85 db                	test   %ebx,%ebx
  8005b6:	7f ed                	jg     8005a5 <vprintfmt+0x1c7>
  8005b8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005bb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005be:	85 d2                	test   %edx,%edx
  8005c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c5:	0f 49 c2             	cmovns %edx,%eax
  8005c8:	29 c2                	sub    %eax,%edx
  8005ca:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005cd:	89 d7                	mov    %edx,%edi
  8005cf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005d2:	eb 50                	jmp    800624 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005d4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d8:	74 1e                	je     8005f8 <vprintfmt+0x21a>
  8005da:	0f be d2             	movsbl %dl,%edx
  8005dd:	83 ea 20             	sub    $0x20,%edx
  8005e0:	83 fa 5e             	cmp    $0x5e,%edx
  8005e3:	76 13                	jbe    8005f8 <vprintfmt+0x21a>
					putch('?', putdat);
  8005e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ec:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005f3:	ff 55 08             	call   *0x8(%ebp)
  8005f6:	eb 0d                	jmp    800605 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8005f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005fb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005ff:	89 04 24             	mov    %eax,(%esp)
  800602:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800605:	83 ef 01             	sub    $0x1,%edi
  800608:	eb 1a                	jmp    800624 <vprintfmt+0x246>
  80060a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80060d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800610:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800613:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800616:	eb 0c                	jmp    800624 <vprintfmt+0x246>
  800618:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80061b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80061e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800621:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800624:	83 c6 01             	add    $0x1,%esi
  800627:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80062b:	0f be c2             	movsbl %dl,%eax
  80062e:	85 c0                	test   %eax,%eax
  800630:	74 27                	je     800659 <vprintfmt+0x27b>
  800632:	85 db                	test   %ebx,%ebx
  800634:	78 9e                	js     8005d4 <vprintfmt+0x1f6>
  800636:	83 eb 01             	sub    $0x1,%ebx
  800639:	79 99                	jns    8005d4 <vprintfmt+0x1f6>
  80063b:	89 f8                	mov    %edi,%eax
  80063d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800640:	8b 75 08             	mov    0x8(%ebp),%esi
  800643:	89 c3                	mov    %eax,%ebx
  800645:	eb 1a                	jmp    800661 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800647:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80064b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800652:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800654:	83 eb 01             	sub    $0x1,%ebx
  800657:	eb 08                	jmp    800661 <vprintfmt+0x283>
  800659:	89 fb                	mov    %edi,%ebx
  80065b:	8b 75 08             	mov    0x8(%ebp),%esi
  80065e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800661:	85 db                	test   %ebx,%ebx
  800663:	7f e2                	jg     800647 <vprintfmt+0x269>
  800665:	89 75 08             	mov    %esi,0x8(%ebp)
  800668:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80066b:	e9 93 fd ff ff       	jmp    800403 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800670:	83 fa 01             	cmp    $0x1,%edx
  800673:	7e 16                	jle    80068b <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8d 50 08             	lea    0x8(%eax),%edx
  80067b:	89 55 14             	mov    %edx,0x14(%ebp)
  80067e:	8b 50 04             	mov    0x4(%eax),%edx
  800681:	8b 00                	mov    (%eax),%eax
  800683:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800686:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800689:	eb 32                	jmp    8006bd <vprintfmt+0x2df>
	else if (lflag)
  80068b:	85 d2                	test   %edx,%edx
  80068d:	74 18                	je     8006a7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  80068f:	8b 45 14             	mov    0x14(%ebp),%eax
  800692:	8d 50 04             	lea    0x4(%eax),%edx
  800695:	89 55 14             	mov    %edx,0x14(%ebp)
  800698:	8b 30                	mov    (%eax),%esi
  80069a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80069d:	89 f0                	mov    %esi,%eax
  80069f:	c1 f8 1f             	sar    $0x1f,%eax
  8006a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006a5:	eb 16                	jmp    8006bd <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	8d 50 04             	lea    0x4(%eax),%edx
  8006ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b0:	8b 30                	mov    (%eax),%esi
  8006b2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006b5:	89 f0                	mov    %esi,%eax
  8006b7:	c1 f8 1f             	sar    $0x1f,%eax
  8006ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006c3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006c8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006cc:	0f 89 80 00 00 00    	jns    800752 <vprintfmt+0x374>
				putch('-', putdat);
  8006d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006d6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006dd:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006e6:	f7 d8                	neg    %eax
  8006e8:	83 d2 00             	adc    $0x0,%edx
  8006eb:	f7 da                	neg    %edx
			}
			base = 10;
  8006ed:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006f2:	eb 5e                	jmp    800752 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006f4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f7:	e8 63 fc ff ff       	call   80035f <getuint>
			base = 10;
  8006fc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800701:	eb 4f                	jmp    800752 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800703:	8d 45 14             	lea    0x14(%ebp),%eax
  800706:	e8 54 fc ff ff       	call   80035f <getuint>
			base = 8;
  80070b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800710:	eb 40                	jmp    800752 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800712:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800716:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80071d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800720:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800724:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80072b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80072e:	8b 45 14             	mov    0x14(%ebp),%eax
  800731:	8d 50 04             	lea    0x4(%eax),%edx
  800734:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800737:	8b 00                	mov    (%eax),%eax
  800739:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80073e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800743:	eb 0d                	jmp    800752 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800745:	8d 45 14             	lea    0x14(%ebp),%eax
  800748:	e8 12 fc ff ff       	call   80035f <getuint>
			base = 16;
  80074d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800752:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800756:	89 74 24 10          	mov    %esi,0x10(%esp)
  80075a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80075d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800761:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800765:	89 04 24             	mov    %eax,(%esp)
  800768:	89 54 24 04          	mov    %edx,0x4(%esp)
  80076c:	89 fa                	mov    %edi,%edx
  80076e:	8b 45 08             	mov    0x8(%ebp),%eax
  800771:	e8 fa fa ff ff       	call   800270 <printnum>
			break;
  800776:	e9 88 fc ff ff       	jmp    800403 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80077b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80077f:	89 04 24             	mov    %eax,(%esp)
  800782:	ff 55 08             	call   *0x8(%ebp)
			break;
  800785:	e9 79 fc ff ff       	jmp    800403 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80078a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80078e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800795:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800798:	89 f3                	mov    %esi,%ebx
  80079a:	eb 03                	jmp    80079f <vprintfmt+0x3c1>
  80079c:	83 eb 01             	sub    $0x1,%ebx
  80079f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007a3:	75 f7                	jne    80079c <vprintfmt+0x3be>
  8007a5:	e9 59 fc ff ff       	jmp    800403 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8007aa:	83 c4 3c             	add    $0x3c,%esp
  8007ad:	5b                   	pop    %ebx
  8007ae:	5e                   	pop    %esi
  8007af:	5f                   	pop    %edi
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	83 ec 28             	sub    $0x28,%esp
  8007b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007be:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007cf:	85 c0                	test   %eax,%eax
  8007d1:	74 30                	je     800803 <vsnprintf+0x51>
  8007d3:	85 d2                	test   %edx,%edx
  8007d5:	7e 2c                	jle    800803 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007de:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ec:	c7 04 24 99 03 80 00 	movl   $0x800399,(%esp)
  8007f3:	e8 e6 fb ff ff       	call   8003de <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007fb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800801:	eb 05                	jmp    800808 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800803:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800808:	c9                   	leave  
  800809:	c3                   	ret    

0080080a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800810:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800813:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800817:	8b 45 10             	mov    0x10(%ebp),%eax
  80081a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800821:	89 44 24 04          	mov    %eax,0x4(%esp)
  800825:	8b 45 08             	mov    0x8(%ebp),%eax
  800828:	89 04 24             	mov    %eax,(%esp)
  80082b:	e8 82 ff ff ff       	call   8007b2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800830:	c9                   	leave  
  800831:	c3                   	ret    
  800832:	66 90                	xchg   %ax,%ax
  800834:	66 90                	xchg   %ax,%ax
  800836:	66 90                	xchg   %ax,%ax
  800838:	66 90                	xchg   %ax,%ax
  80083a:	66 90                	xchg   %ax,%ax
  80083c:	66 90                	xchg   %ax,%ax
  80083e:	66 90                	xchg   %ax,%ax

00800840 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800846:	b8 00 00 00 00       	mov    $0x0,%eax
  80084b:	eb 03                	jmp    800850 <strlen+0x10>
		n++;
  80084d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800850:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800854:	75 f7                	jne    80084d <strlen+0xd>
		n++;
	return n;
}
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800861:	b8 00 00 00 00       	mov    $0x0,%eax
  800866:	eb 03                	jmp    80086b <strnlen+0x13>
		n++;
  800868:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80086b:	39 d0                	cmp    %edx,%eax
  80086d:	74 06                	je     800875 <strnlen+0x1d>
  80086f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800873:	75 f3                	jne    800868 <strnlen+0x10>
		n++;
	return n;
}
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	53                   	push   %ebx
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800881:	89 c2                	mov    %eax,%edx
  800883:	83 c2 01             	add    $0x1,%edx
  800886:	83 c1 01             	add    $0x1,%ecx
  800889:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80088d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800890:	84 db                	test   %bl,%bl
  800892:	75 ef                	jne    800883 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800894:	5b                   	pop    %ebx
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	53                   	push   %ebx
  80089b:	83 ec 08             	sub    $0x8,%esp
  80089e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008a1:	89 1c 24             	mov    %ebx,(%esp)
  8008a4:	e8 97 ff ff ff       	call   800840 <strlen>
	strcpy(dst + len, src);
  8008a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008b0:	01 d8                	add    %ebx,%eax
  8008b2:	89 04 24             	mov    %eax,(%esp)
  8008b5:	e8 bd ff ff ff       	call   800877 <strcpy>
	return dst;
}
  8008ba:	89 d8                	mov    %ebx,%eax
  8008bc:	83 c4 08             	add    $0x8,%esp
  8008bf:	5b                   	pop    %ebx
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	56                   	push   %esi
  8008c6:	53                   	push   %ebx
  8008c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008cd:	89 f3                	mov    %esi,%ebx
  8008cf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d2:	89 f2                	mov    %esi,%edx
  8008d4:	eb 0f                	jmp    8008e5 <strncpy+0x23>
		*dst++ = *src;
  8008d6:	83 c2 01             	add    $0x1,%edx
  8008d9:	0f b6 01             	movzbl (%ecx),%eax
  8008dc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008df:	80 39 01             	cmpb   $0x1,(%ecx)
  8008e2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e5:	39 da                	cmp    %ebx,%edx
  8008e7:	75 ed                	jne    8008d6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008e9:	89 f0                	mov    %esi,%eax
  8008eb:	5b                   	pop    %ebx
  8008ec:	5e                   	pop    %esi
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	56                   	push   %esi
  8008f3:	53                   	push   %ebx
  8008f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008fd:	89 f0                	mov    %esi,%eax
  8008ff:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800903:	85 c9                	test   %ecx,%ecx
  800905:	75 0b                	jne    800912 <strlcpy+0x23>
  800907:	eb 1d                	jmp    800926 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800909:	83 c0 01             	add    $0x1,%eax
  80090c:	83 c2 01             	add    $0x1,%edx
  80090f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800912:	39 d8                	cmp    %ebx,%eax
  800914:	74 0b                	je     800921 <strlcpy+0x32>
  800916:	0f b6 0a             	movzbl (%edx),%ecx
  800919:	84 c9                	test   %cl,%cl
  80091b:	75 ec                	jne    800909 <strlcpy+0x1a>
  80091d:	89 c2                	mov    %eax,%edx
  80091f:	eb 02                	jmp    800923 <strlcpy+0x34>
  800921:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800923:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800926:	29 f0                	sub    %esi,%eax
}
  800928:	5b                   	pop    %ebx
  800929:	5e                   	pop    %esi
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800932:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800935:	eb 06                	jmp    80093d <strcmp+0x11>
		p++, q++;
  800937:	83 c1 01             	add    $0x1,%ecx
  80093a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80093d:	0f b6 01             	movzbl (%ecx),%eax
  800940:	84 c0                	test   %al,%al
  800942:	74 04                	je     800948 <strcmp+0x1c>
  800944:	3a 02                	cmp    (%edx),%al
  800946:	74 ef                	je     800937 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800948:	0f b6 c0             	movzbl %al,%eax
  80094b:	0f b6 12             	movzbl (%edx),%edx
  80094e:	29 d0                	sub    %edx,%eax
}
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	53                   	push   %ebx
  800956:	8b 45 08             	mov    0x8(%ebp),%eax
  800959:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095c:	89 c3                	mov    %eax,%ebx
  80095e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800961:	eb 06                	jmp    800969 <strncmp+0x17>
		n--, p++, q++;
  800963:	83 c0 01             	add    $0x1,%eax
  800966:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800969:	39 d8                	cmp    %ebx,%eax
  80096b:	74 15                	je     800982 <strncmp+0x30>
  80096d:	0f b6 08             	movzbl (%eax),%ecx
  800970:	84 c9                	test   %cl,%cl
  800972:	74 04                	je     800978 <strncmp+0x26>
  800974:	3a 0a                	cmp    (%edx),%cl
  800976:	74 eb                	je     800963 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800978:	0f b6 00             	movzbl (%eax),%eax
  80097b:	0f b6 12             	movzbl (%edx),%edx
  80097e:	29 d0                	sub    %edx,%eax
  800980:	eb 05                	jmp    800987 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800982:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800987:	5b                   	pop    %ebx
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800994:	eb 07                	jmp    80099d <strchr+0x13>
		if (*s == c)
  800996:	38 ca                	cmp    %cl,%dl
  800998:	74 0f                	je     8009a9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80099a:	83 c0 01             	add    $0x1,%eax
  80099d:	0f b6 10             	movzbl (%eax),%edx
  8009a0:	84 d2                	test   %dl,%dl
  8009a2:	75 f2                	jne    800996 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b5:	eb 07                	jmp    8009be <strfind+0x13>
		if (*s == c)
  8009b7:	38 ca                	cmp    %cl,%dl
  8009b9:	74 0a                	je     8009c5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009bb:	83 c0 01             	add    $0x1,%eax
  8009be:	0f b6 10             	movzbl (%eax),%edx
  8009c1:	84 d2                	test   %dl,%dl
  8009c3:	75 f2                	jne    8009b7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	57                   	push   %edi
  8009cb:	56                   	push   %esi
  8009cc:	53                   	push   %ebx
  8009cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009d3:	85 c9                	test   %ecx,%ecx
  8009d5:	74 36                	je     800a0d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009d7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009dd:	75 28                	jne    800a07 <memset+0x40>
  8009df:	f6 c1 03             	test   $0x3,%cl
  8009e2:	75 23                	jne    800a07 <memset+0x40>
		c &= 0xFF;
  8009e4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009e8:	89 d3                	mov    %edx,%ebx
  8009ea:	c1 e3 08             	shl    $0x8,%ebx
  8009ed:	89 d6                	mov    %edx,%esi
  8009ef:	c1 e6 18             	shl    $0x18,%esi
  8009f2:	89 d0                	mov    %edx,%eax
  8009f4:	c1 e0 10             	shl    $0x10,%eax
  8009f7:	09 f0                	or     %esi,%eax
  8009f9:	09 c2                	or     %eax,%edx
  8009fb:	89 d0                	mov    %edx,%eax
  8009fd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009ff:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a02:	fc                   	cld    
  800a03:	f3 ab                	rep stos %eax,%es:(%edi)
  800a05:	eb 06                	jmp    800a0d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0a:	fc                   	cld    
  800a0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a0d:	89 f8                	mov    %edi,%eax
  800a0f:	5b                   	pop    %ebx
  800a10:	5e                   	pop    %esi
  800a11:	5f                   	pop    %edi
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	57                   	push   %edi
  800a18:	56                   	push   %esi
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a22:	39 c6                	cmp    %eax,%esi
  800a24:	73 35                	jae    800a5b <memmove+0x47>
  800a26:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a29:	39 d0                	cmp    %edx,%eax
  800a2b:	73 2e                	jae    800a5b <memmove+0x47>
		s += n;
		d += n;
  800a2d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a30:	89 d6                	mov    %edx,%esi
  800a32:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a34:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a3a:	75 13                	jne    800a4f <memmove+0x3b>
  800a3c:	f6 c1 03             	test   $0x3,%cl
  800a3f:	75 0e                	jne    800a4f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a41:	83 ef 04             	sub    $0x4,%edi
  800a44:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a47:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a4a:	fd                   	std    
  800a4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4d:	eb 09                	jmp    800a58 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a4f:	83 ef 01             	sub    $0x1,%edi
  800a52:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a55:	fd                   	std    
  800a56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a58:	fc                   	cld    
  800a59:	eb 1d                	jmp    800a78 <memmove+0x64>
  800a5b:	89 f2                	mov    %esi,%edx
  800a5d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5f:	f6 c2 03             	test   $0x3,%dl
  800a62:	75 0f                	jne    800a73 <memmove+0x5f>
  800a64:	f6 c1 03             	test   $0x3,%cl
  800a67:	75 0a                	jne    800a73 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a69:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a6c:	89 c7                	mov    %eax,%edi
  800a6e:	fc                   	cld    
  800a6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a71:	eb 05                	jmp    800a78 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a73:	89 c7                	mov    %eax,%edi
  800a75:	fc                   	cld    
  800a76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a78:	5e                   	pop    %esi
  800a79:	5f                   	pop    %edi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a82:	8b 45 10             	mov    0x10(%ebp),%eax
  800a85:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a90:	8b 45 08             	mov    0x8(%ebp),%eax
  800a93:	89 04 24             	mov    %eax,(%esp)
  800a96:	e8 79 ff ff ff       	call   800a14 <memmove>
}
  800a9b:	c9                   	leave  
  800a9c:	c3                   	ret    

00800a9d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	56                   	push   %esi
  800aa1:	53                   	push   %ebx
  800aa2:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa8:	89 d6                	mov    %edx,%esi
  800aaa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aad:	eb 1a                	jmp    800ac9 <memcmp+0x2c>
		if (*s1 != *s2)
  800aaf:	0f b6 02             	movzbl (%edx),%eax
  800ab2:	0f b6 19             	movzbl (%ecx),%ebx
  800ab5:	38 d8                	cmp    %bl,%al
  800ab7:	74 0a                	je     800ac3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ab9:	0f b6 c0             	movzbl %al,%eax
  800abc:	0f b6 db             	movzbl %bl,%ebx
  800abf:	29 d8                	sub    %ebx,%eax
  800ac1:	eb 0f                	jmp    800ad2 <memcmp+0x35>
		s1++, s2++;
  800ac3:	83 c2 01             	add    $0x1,%edx
  800ac6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac9:	39 f2                	cmp    %esi,%edx
  800acb:	75 e2                	jne    800aaf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800acd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  800adc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800adf:	89 c2                	mov    %eax,%edx
  800ae1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ae4:	eb 07                	jmp    800aed <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae6:	38 08                	cmp    %cl,(%eax)
  800ae8:	74 07                	je     800af1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aea:	83 c0 01             	add    $0x1,%eax
  800aed:	39 d0                	cmp    %edx,%eax
  800aef:	72 f5                	jb     800ae6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
  800af9:	8b 55 08             	mov    0x8(%ebp),%edx
  800afc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aff:	eb 03                	jmp    800b04 <strtol+0x11>
		s++;
  800b01:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b04:	0f b6 0a             	movzbl (%edx),%ecx
  800b07:	80 f9 09             	cmp    $0x9,%cl
  800b0a:	74 f5                	je     800b01 <strtol+0xe>
  800b0c:	80 f9 20             	cmp    $0x20,%cl
  800b0f:	74 f0                	je     800b01 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b11:	80 f9 2b             	cmp    $0x2b,%cl
  800b14:	75 0a                	jne    800b20 <strtol+0x2d>
		s++;
  800b16:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b19:	bf 00 00 00 00       	mov    $0x0,%edi
  800b1e:	eb 11                	jmp    800b31 <strtol+0x3e>
  800b20:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b25:	80 f9 2d             	cmp    $0x2d,%cl
  800b28:	75 07                	jne    800b31 <strtol+0x3e>
		s++, neg = 1;
  800b2a:	8d 52 01             	lea    0x1(%edx),%edx
  800b2d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b31:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b36:	75 15                	jne    800b4d <strtol+0x5a>
  800b38:	80 3a 30             	cmpb   $0x30,(%edx)
  800b3b:	75 10                	jne    800b4d <strtol+0x5a>
  800b3d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b41:	75 0a                	jne    800b4d <strtol+0x5a>
		s += 2, base = 16;
  800b43:	83 c2 02             	add    $0x2,%edx
  800b46:	b8 10 00 00 00       	mov    $0x10,%eax
  800b4b:	eb 10                	jmp    800b5d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	75 0c                	jne    800b5d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b51:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b53:	80 3a 30             	cmpb   $0x30,(%edx)
  800b56:	75 05                	jne    800b5d <strtol+0x6a>
		s++, base = 8;
  800b58:	83 c2 01             	add    $0x1,%edx
  800b5b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800b5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b62:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b65:	0f b6 0a             	movzbl (%edx),%ecx
  800b68:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b6b:	89 f0                	mov    %esi,%eax
  800b6d:	3c 09                	cmp    $0x9,%al
  800b6f:	77 08                	ja     800b79 <strtol+0x86>
			dig = *s - '0';
  800b71:	0f be c9             	movsbl %cl,%ecx
  800b74:	83 e9 30             	sub    $0x30,%ecx
  800b77:	eb 20                	jmp    800b99 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b79:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b7c:	89 f0                	mov    %esi,%eax
  800b7e:	3c 19                	cmp    $0x19,%al
  800b80:	77 08                	ja     800b8a <strtol+0x97>
			dig = *s - 'a' + 10;
  800b82:	0f be c9             	movsbl %cl,%ecx
  800b85:	83 e9 57             	sub    $0x57,%ecx
  800b88:	eb 0f                	jmp    800b99 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800b8a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b8d:	89 f0                	mov    %esi,%eax
  800b8f:	3c 19                	cmp    $0x19,%al
  800b91:	77 16                	ja     800ba9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800b93:	0f be c9             	movsbl %cl,%ecx
  800b96:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b99:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b9c:	7d 0f                	jge    800bad <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800b9e:	83 c2 01             	add    $0x1,%edx
  800ba1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800ba5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800ba7:	eb bc                	jmp    800b65 <strtol+0x72>
  800ba9:	89 d8                	mov    %ebx,%eax
  800bab:	eb 02                	jmp    800baf <strtol+0xbc>
  800bad:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800baf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bb3:	74 05                	je     800bba <strtol+0xc7>
		*endptr = (char *) s;
  800bb5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800bba:	f7 d8                	neg    %eax
  800bbc:	85 ff                	test   %edi,%edi
  800bbe:	0f 44 c3             	cmove  %ebx,%eax
}
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd7:	89 c3                	mov    %eax,%ebx
  800bd9:	89 c7                	mov    %eax,%edi
  800bdb:	89 c6                	mov    %eax,%esi
  800bdd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <sys_cgetc>:

int
sys_cgetc(void)
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
  800bef:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf4:	89 d1                	mov    %edx,%ecx
  800bf6:	89 d3                	mov    %edx,%ebx
  800bf8:	89 d7                	mov    %edx,%edi
  800bfa:	89 d6                	mov    %edx,%esi
  800bfc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800c0c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c11:	b8 03 00 00 00       	mov    $0x3,%eax
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	89 cb                	mov    %ecx,%ebx
  800c1b:	89 cf                	mov    %ecx,%edi
  800c1d:	89 ce                	mov    %ecx,%esi
  800c1f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c21:	85 c0                	test   %eax,%eax
  800c23:	7e 28                	jle    800c4d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c25:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c29:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c30:	00 
  800c31:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800c38:	00 
  800c39:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c40:	00 
  800c41:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800c48:	e8 59 1a 00 00       	call   8026a6 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c4d:	83 c4 2c             	add    $0x2c,%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c60:	b8 02 00 00 00       	mov    $0x2,%eax
  800c65:	89 d1                	mov    %edx,%ecx
  800c67:	89 d3                	mov    %edx,%ebx
  800c69:	89 d7                	mov    %edx,%edi
  800c6b:	89 d6                	mov    %edx,%esi
  800c6d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <sys_yield>:

void
sys_yield(void)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c84:	89 d1                	mov    %edx,%ecx
  800c86:	89 d3                	mov    %edx,%ebx
  800c88:	89 d7                	mov    %edx,%edi
  800c8a:	89 d6                	mov    %edx,%esi
  800c8c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9c:	be 00 00 00 00       	mov    $0x0,%esi
  800ca1:	b8 04 00 00 00       	mov    $0x4,%eax
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800caf:	89 f7                	mov    %esi,%edi
  800cb1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	7e 28                	jle    800cdf <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cbb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cc2:	00 
  800cc3:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800cca:	00 
  800ccb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd2:	00 
  800cd3:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800cda:	e8 c7 19 00 00       	call   8026a6 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cdf:	83 c4 2c             	add    $0x2c,%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf0:	b8 05 00 00 00       	mov    $0x5,%eax
  800cf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d01:	8b 75 18             	mov    0x18(%ebp),%esi
  800d04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d06:	85 c0                	test   %eax,%eax
  800d08:	7e 28                	jle    800d32 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d0e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d15:	00 
  800d16:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800d1d:	00 
  800d1e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d25:	00 
  800d26:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800d2d:	e8 74 19 00 00       	call   8026a6 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d32:	83 c4 2c             	add    $0x2c,%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	57                   	push   %edi
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
  800d40:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d48:	b8 06 00 00 00       	mov    $0x6,%eax
  800d4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d50:	8b 55 08             	mov    0x8(%ebp),%edx
  800d53:	89 df                	mov    %ebx,%edi
  800d55:	89 de                	mov    %ebx,%esi
  800d57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	7e 28                	jle    800d85 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d61:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d68:	00 
  800d69:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800d70:	00 
  800d71:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d78:	00 
  800d79:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800d80:	e8 21 19 00 00       	call   8026a6 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d85:	83 c4 2c             	add    $0x2c,%esp
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	57                   	push   %edi
  800d91:	56                   	push   %esi
  800d92:	53                   	push   %ebx
  800d93:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9b:	b8 08 00 00 00       	mov    $0x8,%eax
  800da0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da3:	8b 55 08             	mov    0x8(%ebp),%edx
  800da6:	89 df                	mov    %ebx,%edi
  800da8:	89 de                	mov    %ebx,%esi
  800daa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dac:	85 c0                	test   %eax,%eax
  800dae:	7e 28                	jle    800dd8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dbb:	00 
  800dbc:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800dc3:	00 
  800dc4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dcb:	00 
  800dcc:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800dd3:	e8 ce 18 00 00       	call   8026a6 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dd8:	83 c4 2c             	add    $0x2c,%esp
  800ddb:	5b                   	pop    %ebx
  800ddc:	5e                   	pop    %esi
  800ddd:	5f                   	pop    %edi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	57                   	push   %edi
  800de4:	56                   	push   %esi
  800de5:	53                   	push   %ebx
  800de6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dee:	b8 09 00 00 00       	mov    $0x9,%eax
  800df3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df6:	8b 55 08             	mov    0x8(%ebp),%edx
  800df9:	89 df                	mov    %ebx,%edi
  800dfb:	89 de                	mov    %ebx,%esi
  800dfd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dff:	85 c0                	test   %eax,%eax
  800e01:	7e 28                	jle    800e2b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e03:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e07:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e0e:	00 
  800e0f:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800e16:	00 
  800e17:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e1e:	00 
  800e1f:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800e26:	e8 7b 18 00 00       	call   8026a6 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e2b:	83 c4 2c             	add    $0x2c,%esp
  800e2e:	5b                   	pop    %ebx
  800e2f:	5e                   	pop    %esi
  800e30:	5f                   	pop    %edi
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    

00800e33 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	57                   	push   %edi
  800e37:	56                   	push   %esi
  800e38:	53                   	push   %ebx
  800e39:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e41:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e49:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4c:	89 df                	mov    %ebx,%edi
  800e4e:	89 de                	mov    %ebx,%esi
  800e50:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e52:	85 c0                	test   %eax,%eax
  800e54:	7e 28                	jle    800e7e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e56:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e5a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e61:	00 
  800e62:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800e69:	00 
  800e6a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e71:	00 
  800e72:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800e79:	e8 28 18 00 00       	call   8026a6 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e7e:	83 c4 2c             	add    $0x2c,%esp
  800e81:	5b                   	pop    %ebx
  800e82:	5e                   	pop    %esi
  800e83:	5f                   	pop    %edi
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	57                   	push   %edi
  800e8a:	56                   	push   %esi
  800e8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8c:	be 00 00 00 00       	mov    $0x0,%esi
  800e91:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e99:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ea2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	57                   	push   %edi
  800ead:	56                   	push   %esi
  800eae:	53                   	push   %ebx
  800eaf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ebc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebf:	89 cb                	mov    %ecx,%ebx
  800ec1:	89 cf                	mov    %ecx,%edi
  800ec3:	89 ce                	mov    %ecx,%esi
  800ec5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec7:	85 c0                	test   %eax,%eax
  800ec9:	7e 28                	jle    800ef3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ecb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ecf:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ed6:	00 
  800ed7:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800ede:	00 
  800edf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee6:	00 
  800ee7:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800eee:	e8 b3 17 00 00       	call   8026a6 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ef3:	83 c4 2c             	add    $0x2c,%esp
  800ef6:	5b                   	pop    %ebx
  800ef7:	5e                   	pop    %esi
  800ef8:	5f                   	pop    %edi
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	57                   	push   %edi
  800eff:	56                   	push   %esi
  800f00:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f01:	ba 00 00 00 00       	mov    $0x0,%edx
  800f06:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f0b:	89 d1                	mov    %edx,%ecx
  800f0d:	89 d3                	mov    %edx,%ebx
  800f0f:	89 d7                	mov    %edx,%edi
  800f11:	89 d6                	mov    %edx,%esi
  800f13:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f15:	5b                   	pop    %ebx
  800f16:	5e                   	pop    %esi
  800f17:	5f                   	pop    %edi
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    

00800f1a <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	57                   	push   %edi
  800f1e:	56                   	push   %esi
  800f1f:	53                   	push   %ebx
  800f20:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f23:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f28:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f30:	8b 55 08             	mov    0x8(%ebp),%edx
  800f33:	89 df                	mov    %ebx,%edi
  800f35:	89 de                	mov    %ebx,%esi
  800f37:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f39:	85 c0                	test   %eax,%eax
  800f3b:	7e 28                	jle    800f65 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f3d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f41:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800f48:	00 
  800f49:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800f50:	00 
  800f51:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f58:	00 
  800f59:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800f60:	e8 41 17 00 00       	call   8026a6 <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  800f65:	83 c4 2c             	add    $0x2c,%esp
  800f68:	5b                   	pop    %ebx
  800f69:	5e                   	pop    %esi
  800f6a:	5f                   	pop    %edi
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    

00800f6d <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	57                   	push   %edi
  800f71:	56                   	push   %esi
  800f72:	53                   	push   %ebx
  800f73:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f7b:	b8 10 00 00 00       	mov    $0x10,%eax
  800f80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f83:	8b 55 08             	mov    0x8(%ebp),%edx
  800f86:	89 df                	mov    %ebx,%edi
  800f88:	89 de                	mov    %ebx,%esi
  800f8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	7e 28                	jle    800fb8 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f90:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f94:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  800f9b:	00 
  800f9c:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800fa3:	00 
  800fa4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fab:	00 
  800fac:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800fb3:	e8 ee 16 00 00       	call   8026a6 <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  800fb8:	83 c4 2c             	add    $0x2c,%esp
  800fbb:	5b                   	pop    %ebx
  800fbc:	5e                   	pop    %esi
  800fbd:	5f                   	pop    %edi
  800fbe:	5d                   	pop    %ebp
  800fbf:	c3                   	ret    

00800fc0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	56                   	push   %esi
  800fc4:	53                   	push   %ebx
  800fc5:	83 ec 20             	sub    $0x20,%esp
  800fc8:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800fcb:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if(!(err & FEC_WR)) {
  800fcd:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fd1:	75 20                	jne    800ff3 <pgfault+0x33>
		panic("0x%x Not a write", addr);
  800fd3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800fd7:	c7 44 24 08 ca 2d 80 	movl   $0x802dca,0x8(%esp)
  800fde:	00 
  800fdf:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800fe6:	00 
  800fe7:	c7 04 24 db 2d 80 00 	movl   $0x802ddb,(%esp)
  800fee:	e8 b3 16 00 00       	call   8026a6 <_panic>
	}

	if(!(uvpt[PGNUM(addr)] & PTE_COW)) {
  800ff3:	89 f0                	mov    %esi,%eax
  800ff5:	c1 e8 0c             	shr    $0xc,%eax
  800ff8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fff:	f6 c4 08             	test   $0x8,%ah
  801002:	75 1c                	jne    801020 <pgfault+0x60>
		panic("Not a COW page");
  801004:	c7 44 24 08 e6 2d 80 	movl   $0x802de6,0x8(%esp)
  80100b:	00 
  80100c:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  801013:	00 
  801014:	c7 04 24 db 2d 80 00 	movl   $0x802ddb,(%esp)
  80101b:	e8 86 16 00 00       	call   8026a6 <_panic>

	// Allocate a new page, map it at a temporary location (PFTEMP), // copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	envid_t envid = sys_getenvid();
  801020:	e8 30 fc ff ff       	call   800c55 <sys_getenvid>
  801025:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, PFTEMP, PTE_W | PTE_U | PTE_P);
  801027:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80102e:	00 
  80102f:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801036:	00 
  801037:	89 04 24             	mov    %eax,(%esp)
  80103a:	e8 54 fc ff ff       	call   800c93 <sys_page_alloc>
	if(r < 0) {
  80103f:	85 c0                	test   %eax,%eax
  801041:	79 1c                	jns    80105f <pgfault+0x9f>
		panic("couldn't allocate page");
  801043:	c7 44 24 08 f5 2d 80 	movl   $0x802df5,0x8(%esp)
  80104a:	00 
  80104b:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801052:	00 
  801053:	c7 04 24 db 2d 80 00 	movl   $0x802ddb,(%esp)
  80105a:	e8 47 16 00 00       	call   8026a6 <_panic>
	}

	memmove(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  80105f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  801065:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80106c:	00 
  80106d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801071:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801078:	e8 97 f9 ff ff       	call   800a14 <memmove>

	r = sys_page_map(envid, PFTEMP, envid, ROUNDDOWN(addr,PGSIZE), PTE_P | PTE_U | PTE_W);
  80107d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801084:	00 
  801085:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801089:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80108d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801094:	00 
  801095:	89 1c 24             	mov    %ebx,(%esp)
  801098:	e8 4a fc ff ff       	call   800ce7 <sys_page_map>
	if(r < 0) {
  80109d:	85 c0                	test   %eax,%eax
  80109f:	79 1c                	jns    8010bd <pgfault+0xfd>
		panic("couldn't map page");
  8010a1:	c7 44 24 08 0c 2e 80 	movl   $0x802e0c,0x8(%esp)
  8010a8:	00 
  8010a9:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  8010b0:	00 
  8010b1:	c7 04 24 db 2d 80 00 	movl   $0x802ddb,(%esp)
  8010b8:	e8 e9 15 00 00       	call   8026a6 <_panic>
	}
}
  8010bd:	83 c4 20             	add    $0x20,%esp
  8010c0:	5b                   	pop    %ebx
  8010c1:	5e                   	pop    %esi
  8010c2:	5d                   	pop    %ebp
  8010c3:	c3                   	ret    

008010c4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	57                   	push   %edi
  8010c8:	56                   	push   %esi
  8010c9:	53                   	push   %ebx
  8010ca:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envid;
	uintptr_t addr;
	int r = 0;

	set_pgfault_handler(pgfault);
  8010cd:	c7 04 24 c0 0f 80 00 	movl   $0x800fc0,(%esp)
  8010d4:	e8 23 16 00 00       	call   8026fc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010d9:	b8 07 00 00 00       	mov    $0x7,%eax
  8010de:	cd 30                	int    $0x30
  8010e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8010e3:	89 45 d8             	mov    %eax,-0x28(%ebp)

	envid = sys_exofork();
	if(envid == 0) {
  8010e6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8010ed:	bf 00 00 00 00       	mov    $0x0,%edi
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	75 21                	jne    801117 <fork+0x53>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010f6:	e8 5a fb ff ff       	call   800c55 <sys_getenvid>
  8010fb:	25 ff 03 00 00       	and    $0x3ff,%eax
  801100:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801103:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801108:	a3 0c 40 80 00       	mov    %eax,0x80400c
		return 0;
  80110d:	b8 00 00 00 00       	mov    $0x0,%eax
  801112:	e9 8d 01 00 00       	jmp    8012a4 <fork+0x1e0>
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
  801117:	89 f8                	mov    %edi,%eax
  801119:	c1 e8 16             	shr    $0x16,%eax
  80111c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801123:	85 c0                	test   %eax,%eax
  801125:	0f 84 02 01 00 00    	je     80122d <fork+0x169>
  80112b:	89 fa                	mov    %edi,%edx
  80112d:	c1 ea 0c             	shr    $0xc,%edx
  801130:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801137:	85 c0                	test   %eax,%eax
  801139:	0f 84 ee 00 00 00    	je     80122d <fork+0x169>
//
static int
duppage(envid_t envid, unsigned pn)
{

	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P)) return 0;
  80113f:	89 d6                	mov    %edx,%esi
  801141:	c1 e6 0c             	shl    $0xc,%esi
  801144:	89 f0                	mov    %esi,%eax
  801146:	c1 e8 16             	shr    $0x16,%eax
  801149:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  801150:	b8 00 00 00 00       	mov    $0x0,%eax
  801155:	f6 c1 01             	test   $0x1,%cl
  801158:	0f 84 cc 00 00 00    	je     80122a <fork+0x166>

	int all_perms = PTE_U | PTE_P | PTE_AVAIL | PTE_W | PTE_COW;
	int orig_perms = uvpt[pn] & all_perms;
  80115e:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  801165:	89 d8                	mov    %ebx,%eax
  801167:	25 07 0e 00 00       	and    $0xe07,%eax
  80116c:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if(!(orig_perms & PTE_P)) return 0;
  80116f:	89 d8                	mov    %ebx,%eax
  801171:	83 e0 01             	and    $0x1,%eax
  801174:	0f 84 b0 00 00 00    	je     80122a <fork+0x166>

	int r = 0;
	envid_t curenvid = sys_getenvid();
  80117a:	e8 d6 fa ff ff       	call   800c55 <sys_getenvid>
  80117f:	89 45 dc             	mov    %eax,-0x24(%ebp)


	if(orig_perms & PTE_SHARE) {
  801182:	f7 45 e0 00 04 00 00 	testl  $0x400,-0x20(%ebp)
  801189:	74 28                	je     8011b3 <fork+0xef>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms & PTE_SYSCALL));
  80118b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80118e:	25 07 0e 00 00       	and    $0xe07,%eax
  801193:	89 44 24 10          	mov    %eax,0x10(%esp)
  801197:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80119b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80119e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011a6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011a9:	89 04 24             	mov    %eax,(%esp)
  8011ac:	e8 36 fb ff ff       	call   800ce7 <sys_page_map>
  8011b1:	eb 77                	jmp    80122a <fork+0x166>

	} else if(((orig_perms) & PTE_COW) || (orig_perms & PTE_W) ) {
  8011b3:	f7 c3 02 08 00 00    	test   $0x802,%ebx
  8011b9:	74 4e                	je     801209 <fork+0x145>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  8011bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011be:	25 fd f7 ff ff       	and    $0xfffff7fd,%eax
  8011c3:	80 cc 08             	or     $0x8,%ah
  8011c6:	89 c3                	mov    %eax,%ebx
  8011c8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011cc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8011d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011d7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011db:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011de:	89 04 24             	mov    %eax,(%esp)
  8011e1:	e8 01 fb ff ff       	call   800ce7 <sys_page_map>
  8011e6:	89 45 e0             	mov    %eax,-0x20(%ebp)

		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), curenvid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  8011e9:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8011ed:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011f1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8011f4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011fc:	89 0c 24             	mov    %ecx,(%esp)
  8011ff:	e8 e3 fa ff ff       	call   800ce7 <sys_page_map>
  801204:	03 45 e0             	add    -0x20(%ebp),%eax
  801207:	eb 21                	jmp    80122a <fork+0x166>

	} else {
		r = sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), orig_perms);
  801209:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80120c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801210:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801214:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801217:	89 44 24 08          	mov    %eax,0x8(%esp)
  80121b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80121f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801222:	89 04 24             	mov    %eax,(%esp)
  801225:	e8 bd fa ff ff       	call   800ce7 <sys_page_map>
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
  80122a:	01 45 e4             	add    %eax,-0x1c(%ebp)
	if(envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
  80122d:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801233:	81 ff 00 f0 bf ee    	cmp    $0xeebff000,%edi
  801239:	0f 85 d8 fe ff ff    	jne    801117 <fork+0x53>
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
		}
	}

	r+=sys_page_alloc(envid, (void*)UXSTACKTOP - PGSIZE, PTE_P|PTE_U|PTE_W);
  80123f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801246:	00 
  801247:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80124e:	ee 
  80124f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801252:	89 34 24             	mov    %esi,(%esp)
  801255:	e8 39 fa ff ff       	call   800c93 <sys_page_alloc>
  80125a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80125d:	01 c3                	add    %eax,%ebx
	r+=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80125f:	c7 44 24 04 49 27 80 	movl   $0x802749,0x4(%esp)
  801266:	00 
  801267:	89 34 24             	mov    %esi,(%esp)
  80126a:	e8 c4 fb ff ff       	call   800e33 <sys_env_set_pgfault_upcall>
  80126f:	01 c3                	add    %eax,%ebx
	r+= sys_env_set_status(envid, ENV_RUNNABLE);
  801271:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801278:	00 
  801279:	89 34 24             	mov    %esi,(%esp)
  80127c:	e8 0c fb ff ff       	call   800d8d <sys_env_set_status>

	if(r<0) {
  801281:	01 d8                	add    %ebx,%eax
  801283:	79 1c                	jns    8012a1 <fork+0x1dd>
	 panic("fork failed!");
  801285:	c7 44 24 08 1e 2e 80 	movl   $0x802e1e,0x8(%esp)
  80128c:	00 
  80128d:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  801294:	00 
  801295:	c7 04 24 db 2d 80 00 	movl   $0x802ddb,(%esp)
  80129c:	e8 05 14 00 00       	call   8026a6 <_panic>
	}

	return envid;
  8012a1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  8012a4:	83 c4 3c             	add    $0x3c,%esp
  8012a7:	5b                   	pop    %ebx
  8012a8:	5e                   	pop    %esi
  8012a9:	5f                   	pop    %edi
  8012aa:	5d                   	pop    %ebp
  8012ab:	c3                   	ret    

008012ac <sfork>:

// Challenge!
int
sfork(void)
{
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8012b2:	c7 44 24 08 2b 2e 80 	movl   $0x802e2b,0x8(%esp)
  8012b9:	00 
  8012ba:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
  8012c1:	00 
  8012c2:	c7 04 24 db 2d 80 00 	movl   $0x802ddb,(%esp)
  8012c9:	e8 d8 13 00 00       	call   8026a6 <_panic>
  8012ce:	66 90                	xchg   %ax,%ax

008012d0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012d0:	55                   	push   %ebp
  8012d1:	89 e5                	mov    %esp,%ebp
  8012d3:	56                   	push   %esi
  8012d4:	53                   	push   %ebx
  8012d5:	83 ec 10             	sub    $0x10,%esp
  8012d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8012db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012de:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  8012e1:	85 c0                	test   %eax,%eax
  8012e3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8012e8:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  8012eb:	89 04 24             	mov    %eax,(%esp)
  8012ee:	e8 b6 fb ff ff       	call   800ea9 <sys_ipc_recv>

	if(ret < 0) {
  8012f3:	85 c0                	test   %eax,%eax
  8012f5:	79 16                	jns    80130d <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  8012f7:	85 f6                	test   %esi,%esi
  8012f9:	74 06                	je     801301 <ipc_recv+0x31>
  8012fb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  801301:	85 db                	test   %ebx,%ebx
  801303:	74 3e                	je     801343 <ipc_recv+0x73>
  801305:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80130b:	eb 36                	jmp    801343 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  80130d:	e8 43 f9 ff ff       	call   800c55 <sys_getenvid>
  801312:	25 ff 03 00 00       	and    $0x3ff,%eax
  801317:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80131a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80131f:	a3 0c 40 80 00       	mov    %eax,0x80400c

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801324:	85 f6                	test   %esi,%esi
  801326:	74 05                	je     80132d <ipc_recv+0x5d>
  801328:	8b 40 74             	mov    0x74(%eax),%eax
  80132b:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80132d:	85 db                	test   %ebx,%ebx
  80132f:	74 0a                	je     80133b <ipc_recv+0x6b>
  801331:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801336:	8b 40 78             	mov    0x78(%eax),%eax
  801339:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  80133b:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801340:	8b 40 70             	mov    0x70(%eax),%eax
}
  801343:	83 c4 10             	add    $0x10,%esp
  801346:	5b                   	pop    %ebx
  801347:	5e                   	pop    %esi
  801348:	5d                   	pop    %ebp
  801349:	c3                   	ret    

0080134a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
  80134d:	57                   	push   %edi
  80134e:	56                   	push   %esi
  80134f:	53                   	push   %ebx
  801350:	83 ec 1c             	sub    $0x1c,%esp
  801353:	8b 7d 08             	mov    0x8(%ebp),%edi
  801356:	8b 75 0c             	mov    0xc(%ebp),%esi
  801359:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  80135c:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  80135e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801363:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  801366:	8b 45 14             	mov    0x14(%ebp),%eax
  801369:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80136d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801371:	89 74 24 04          	mov    %esi,0x4(%esp)
  801375:	89 3c 24             	mov    %edi,(%esp)
  801378:	e8 09 fb ff ff       	call   800e86 <sys_ipc_try_send>

		if(ret >= 0) break;
  80137d:	85 c0                	test   %eax,%eax
  80137f:	79 2c                	jns    8013ad <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  801381:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801384:	74 20                	je     8013a6 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  801386:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80138a:	c7 44 24 08 44 2e 80 	movl   $0x802e44,0x8(%esp)
  801391:	00 
  801392:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801399:	00 
  80139a:	c7 04 24 74 2e 80 00 	movl   $0x802e74,(%esp)
  8013a1:	e8 00 13 00 00       	call   8026a6 <_panic>
		}
		sys_yield();
  8013a6:	e8 c9 f8 ff ff       	call   800c74 <sys_yield>
	}
  8013ab:	eb b9                	jmp    801366 <ipc_send+0x1c>
}
  8013ad:	83 c4 1c             	add    $0x1c,%esp
  8013b0:	5b                   	pop    %ebx
  8013b1:	5e                   	pop    %esi
  8013b2:	5f                   	pop    %edi
  8013b3:	5d                   	pop    %ebp
  8013b4:	c3                   	ret    

008013b5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013b5:	55                   	push   %ebp
  8013b6:	89 e5                	mov    %esp,%ebp
  8013b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8013bb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8013c0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8013c3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013c9:	8b 52 50             	mov    0x50(%edx),%edx
  8013cc:	39 ca                	cmp    %ecx,%edx
  8013ce:	75 0d                	jne    8013dd <ipc_find_env+0x28>
			return envs[i].env_id;
  8013d0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8013d3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8013d8:	8b 40 40             	mov    0x40(%eax),%eax
  8013db:	eb 0e                	jmp    8013eb <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013dd:	83 c0 01             	add    $0x1,%eax
  8013e0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013e5:	75 d9                	jne    8013c0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8013e7:	66 b8 00 00          	mov    $0x0,%ax
}
  8013eb:	5d                   	pop    %ebp
  8013ec:	c3                   	ret    
  8013ed:	66 90                	xchg   %ax,%ax
  8013ef:	90                   	nop

008013f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013f0:	55                   	push   %ebp
  8013f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8013fb:	c1 e8 0c             	shr    $0xc,%eax
}
  8013fe:	5d                   	pop    %ebp
  8013ff:	c3                   	ret    

00801400 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801403:	8b 45 08             	mov    0x8(%ebp),%eax
  801406:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80140b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801410:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801415:	5d                   	pop    %ebp
  801416:	c3                   	ret    

00801417 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801417:	55                   	push   %ebp
  801418:	89 e5                	mov    %esp,%ebp
  80141a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80141d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801422:	89 c2                	mov    %eax,%edx
  801424:	c1 ea 16             	shr    $0x16,%edx
  801427:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80142e:	f6 c2 01             	test   $0x1,%dl
  801431:	74 11                	je     801444 <fd_alloc+0x2d>
  801433:	89 c2                	mov    %eax,%edx
  801435:	c1 ea 0c             	shr    $0xc,%edx
  801438:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80143f:	f6 c2 01             	test   $0x1,%dl
  801442:	75 09                	jne    80144d <fd_alloc+0x36>
			*fd_store = fd;
  801444:	89 01                	mov    %eax,(%ecx)
			return 0;
  801446:	b8 00 00 00 00       	mov    $0x0,%eax
  80144b:	eb 17                	jmp    801464 <fd_alloc+0x4d>
  80144d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801452:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801457:	75 c9                	jne    801422 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801459:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80145f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801464:	5d                   	pop    %ebp
  801465:	c3                   	ret    

00801466 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801466:	55                   	push   %ebp
  801467:	89 e5                	mov    %esp,%ebp
  801469:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80146c:	83 f8 1f             	cmp    $0x1f,%eax
  80146f:	77 36                	ja     8014a7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801471:	c1 e0 0c             	shl    $0xc,%eax
  801474:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801479:	89 c2                	mov    %eax,%edx
  80147b:	c1 ea 16             	shr    $0x16,%edx
  80147e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801485:	f6 c2 01             	test   $0x1,%dl
  801488:	74 24                	je     8014ae <fd_lookup+0x48>
  80148a:	89 c2                	mov    %eax,%edx
  80148c:	c1 ea 0c             	shr    $0xc,%edx
  80148f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801496:	f6 c2 01             	test   $0x1,%dl
  801499:	74 1a                	je     8014b5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80149b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80149e:	89 02                	mov    %eax,(%edx)
	return 0;
  8014a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8014a5:	eb 13                	jmp    8014ba <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014ac:	eb 0c                	jmp    8014ba <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014b3:	eb 05                	jmp    8014ba <fd_lookup+0x54>
  8014b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014ba:	5d                   	pop    %ebp
  8014bb:	c3                   	ret    

008014bc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	83 ec 18             	sub    $0x18,%esp
  8014c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8014c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ca:	eb 13                	jmp    8014df <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8014cc:	39 08                	cmp    %ecx,(%eax)
  8014ce:	75 0c                	jne    8014dc <dev_lookup+0x20>
			*dev = devtab[i];
  8014d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014d3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8014da:	eb 38                	jmp    801514 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014dc:	83 c2 01             	add    $0x1,%edx
  8014df:	8b 04 95 fc 2e 80 00 	mov    0x802efc(,%edx,4),%eax
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	75 e2                	jne    8014cc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014ea:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8014ef:	8b 40 48             	mov    0x48(%eax),%eax
  8014f2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014fa:	c7 04 24 80 2e 80 00 	movl   $0x802e80,(%esp)
  801501:	e8 45 ed ff ff       	call   80024b <cprintf>
	*dev = 0;
  801506:	8b 45 0c             	mov    0xc(%ebp),%eax
  801509:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80150f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801514:	c9                   	leave  
  801515:	c3                   	ret    

00801516 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	56                   	push   %esi
  80151a:	53                   	push   %ebx
  80151b:	83 ec 20             	sub    $0x20,%esp
  80151e:	8b 75 08             	mov    0x8(%ebp),%esi
  801521:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801524:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801527:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80152b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801531:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801534:	89 04 24             	mov    %eax,(%esp)
  801537:	e8 2a ff ff ff       	call   801466 <fd_lookup>
  80153c:	85 c0                	test   %eax,%eax
  80153e:	78 05                	js     801545 <fd_close+0x2f>
	    || fd != fd2)
  801540:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801543:	74 0c                	je     801551 <fd_close+0x3b>
		return (must_exist ? r : 0);
  801545:	84 db                	test   %bl,%bl
  801547:	ba 00 00 00 00       	mov    $0x0,%edx
  80154c:	0f 44 c2             	cmove  %edx,%eax
  80154f:	eb 3f                	jmp    801590 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801551:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801554:	89 44 24 04          	mov    %eax,0x4(%esp)
  801558:	8b 06                	mov    (%esi),%eax
  80155a:	89 04 24             	mov    %eax,(%esp)
  80155d:	e8 5a ff ff ff       	call   8014bc <dev_lookup>
  801562:	89 c3                	mov    %eax,%ebx
  801564:	85 c0                	test   %eax,%eax
  801566:	78 16                	js     80157e <fd_close+0x68>
		if (dev->dev_close)
  801568:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80156e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801573:	85 c0                	test   %eax,%eax
  801575:	74 07                	je     80157e <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801577:	89 34 24             	mov    %esi,(%esp)
  80157a:	ff d0                	call   *%eax
  80157c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80157e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801582:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801589:	e8 ac f7 ff ff       	call   800d3a <sys_page_unmap>
	return r;
  80158e:	89 d8                	mov    %ebx,%eax
}
  801590:	83 c4 20             	add    $0x20,%esp
  801593:	5b                   	pop    %ebx
  801594:	5e                   	pop    %esi
  801595:	5d                   	pop    %ebp
  801596:	c3                   	ret    

00801597 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801597:	55                   	push   %ebp
  801598:	89 e5                	mov    %esp,%ebp
  80159a:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80159d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a7:	89 04 24             	mov    %eax,(%esp)
  8015aa:	e8 b7 fe ff ff       	call   801466 <fd_lookup>
  8015af:	89 c2                	mov    %eax,%edx
  8015b1:	85 d2                	test   %edx,%edx
  8015b3:	78 13                	js     8015c8 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8015b5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8015bc:	00 
  8015bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c0:	89 04 24             	mov    %eax,(%esp)
  8015c3:	e8 4e ff ff ff       	call   801516 <fd_close>
}
  8015c8:	c9                   	leave  
  8015c9:	c3                   	ret    

008015ca <close_all>:

void
close_all(void)
{
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	53                   	push   %ebx
  8015ce:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015d1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015d6:	89 1c 24             	mov    %ebx,(%esp)
  8015d9:	e8 b9 ff ff ff       	call   801597 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015de:	83 c3 01             	add    $0x1,%ebx
  8015e1:	83 fb 20             	cmp    $0x20,%ebx
  8015e4:	75 f0                	jne    8015d6 <close_all+0xc>
		close(i);
}
  8015e6:	83 c4 14             	add    $0x14,%esp
  8015e9:	5b                   	pop    %ebx
  8015ea:	5d                   	pop    %ebp
  8015eb:	c3                   	ret    

008015ec <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	57                   	push   %edi
  8015f0:	56                   	push   %esi
  8015f1:	53                   	push   %ebx
  8015f2:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015f5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ff:	89 04 24             	mov    %eax,(%esp)
  801602:	e8 5f fe ff ff       	call   801466 <fd_lookup>
  801607:	89 c2                	mov    %eax,%edx
  801609:	85 d2                	test   %edx,%edx
  80160b:	0f 88 e1 00 00 00    	js     8016f2 <dup+0x106>
		return r;
	close(newfdnum);
  801611:	8b 45 0c             	mov    0xc(%ebp),%eax
  801614:	89 04 24             	mov    %eax,(%esp)
  801617:	e8 7b ff ff ff       	call   801597 <close>

	newfd = INDEX2FD(newfdnum);
  80161c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80161f:	c1 e3 0c             	shl    $0xc,%ebx
  801622:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801628:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80162b:	89 04 24             	mov    %eax,(%esp)
  80162e:	e8 cd fd ff ff       	call   801400 <fd2data>
  801633:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801635:	89 1c 24             	mov    %ebx,(%esp)
  801638:	e8 c3 fd ff ff       	call   801400 <fd2data>
  80163d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80163f:	89 f0                	mov    %esi,%eax
  801641:	c1 e8 16             	shr    $0x16,%eax
  801644:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80164b:	a8 01                	test   $0x1,%al
  80164d:	74 43                	je     801692 <dup+0xa6>
  80164f:	89 f0                	mov    %esi,%eax
  801651:	c1 e8 0c             	shr    $0xc,%eax
  801654:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80165b:	f6 c2 01             	test   $0x1,%dl
  80165e:	74 32                	je     801692 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801660:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801667:	25 07 0e 00 00       	and    $0xe07,%eax
  80166c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801670:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801674:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80167b:	00 
  80167c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801680:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801687:	e8 5b f6 ff ff       	call   800ce7 <sys_page_map>
  80168c:	89 c6                	mov    %eax,%esi
  80168e:	85 c0                	test   %eax,%eax
  801690:	78 3e                	js     8016d0 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801692:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801695:	89 c2                	mov    %eax,%edx
  801697:	c1 ea 0c             	shr    $0xc,%edx
  80169a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016a1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8016a7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8016ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8016af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016b6:	00 
  8016b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016c2:	e8 20 f6 ff ff       	call   800ce7 <sys_page_map>
  8016c7:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8016c9:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016cc:	85 f6                	test   %esi,%esi
  8016ce:	79 22                	jns    8016f2 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016db:	e8 5a f6 ff ff       	call   800d3a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016e0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8016e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016eb:	e8 4a f6 ff ff       	call   800d3a <sys_page_unmap>
	return r;
  8016f0:	89 f0                	mov    %esi,%eax
}
  8016f2:	83 c4 3c             	add    $0x3c,%esp
  8016f5:	5b                   	pop    %ebx
  8016f6:	5e                   	pop    %esi
  8016f7:	5f                   	pop    %edi
  8016f8:	5d                   	pop    %ebp
  8016f9:	c3                   	ret    

008016fa <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	53                   	push   %ebx
  8016fe:	83 ec 24             	sub    $0x24,%esp
  801701:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801704:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801707:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170b:	89 1c 24             	mov    %ebx,(%esp)
  80170e:	e8 53 fd ff ff       	call   801466 <fd_lookup>
  801713:	89 c2                	mov    %eax,%edx
  801715:	85 d2                	test   %edx,%edx
  801717:	78 6d                	js     801786 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801719:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80171c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801720:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801723:	8b 00                	mov    (%eax),%eax
  801725:	89 04 24             	mov    %eax,(%esp)
  801728:	e8 8f fd ff ff       	call   8014bc <dev_lookup>
  80172d:	85 c0                	test   %eax,%eax
  80172f:	78 55                	js     801786 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801731:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801734:	8b 50 08             	mov    0x8(%eax),%edx
  801737:	83 e2 03             	and    $0x3,%edx
  80173a:	83 fa 01             	cmp    $0x1,%edx
  80173d:	75 23                	jne    801762 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80173f:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801744:	8b 40 48             	mov    0x48(%eax),%eax
  801747:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80174b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80174f:	c7 04 24 c1 2e 80 00 	movl   $0x802ec1,(%esp)
  801756:	e8 f0 ea ff ff       	call   80024b <cprintf>
		return -E_INVAL;
  80175b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801760:	eb 24                	jmp    801786 <read+0x8c>
	}
	if (!dev->dev_read)
  801762:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801765:	8b 52 08             	mov    0x8(%edx),%edx
  801768:	85 d2                	test   %edx,%edx
  80176a:	74 15                	je     801781 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80176c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80176f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801773:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801776:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80177a:	89 04 24             	mov    %eax,(%esp)
  80177d:	ff d2                	call   *%edx
  80177f:	eb 05                	jmp    801786 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801781:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801786:	83 c4 24             	add    $0x24,%esp
  801789:	5b                   	pop    %ebx
  80178a:	5d                   	pop    %ebp
  80178b:	c3                   	ret    

0080178c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	57                   	push   %edi
  801790:	56                   	push   %esi
  801791:	53                   	push   %ebx
  801792:	83 ec 1c             	sub    $0x1c,%esp
  801795:	8b 7d 08             	mov    0x8(%ebp),%edi
  801798:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80179b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017a0:	eb 23                	jmp    8017c5 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017a2:	89 f0                	mov    %esi,%eax
  8017a4:	29 d8                	sub    %ebx,%eax
  8017a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017aa:	89 d8                	mov    %ebx,%eax
  8017ac:	03 45 0c             	add    0xc(%ebp),%eax
  8017af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b3:	89 3c 24             	mov    %edi,(%esp)
  8017b6:	e8 3f ff ff ff       	call   8016fa <read>
		if (m < 0)
  8017bb:	85 c0                	test   %eax,%eax
  8017bd:	78 10                	js     8017cf <readn+0x43>
			return m;
		if (m == 0)
  8017bf:	85 c0                	test   %eax,%eax
  8017c1:	74 0a                	je     8017cd <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017c3:	01 c3                	add    %eax,%ebx
  8017c5:	39 f3                	cmp    %esi,%ebx
  8017c7:	72 d9                	jb     8017a2 <readn+0x16>
  8017c9:	89 d8                	mov    %ebx,%eax
  8017cb:	eb 02                	jmp    8017cf <readn+0x43>
  8017cd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017cf:	83 c4 1c             	add    $0x1c,%esp
  8017d2:	5b                   	pop    %ebx
  8017d3:	5e                   	pop    %esi
  8017d4:	5f                   	pop    %edi
  8017d5:	5d                   	pop    %ebp
  8017d6:	c3                   	ret    

008017d7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017d7:	55                   	push   %ebp
  8017d8:	89 e5                	mov    %esp,%ebp
  8017da:	53                   	push   %ebx
  8017db:	83 ec 24             	sub    $0x24,%esp
  8017de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e8:	89 1c 24             	mov    %ebx,(%esp)
  8017eb:	e8 76 fc ff ff       	call   801466 <fd_lookup>
  8017f0:	89 c2                	mov    %eax,%edx
  8017f2:	85 d2                	test   %edx,%edx
  8017f4:	78 68                	js     80185e <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801800:	8b 00                	mov    (%eax),%eax
  801802:	89 04 24             	mov    %eax,(%esp)
  801805:	e8 b2 fc ff ff       	call   8014bc <dev_lookup>
  80180a:	85 c0                	test   %eax,%eax
  80180c:	78 50                	js     80185e <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80180e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801811:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801815:	75 23                	jne    80183a <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801817:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80181c:	8b 40 48             	mov    0x48(%eax),%eax
  80181f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801823:	89 44 24 04          	mov    %eax,0x4(%esp)
  801827:	c7 04 24 dd 2e 80 00 	movl   $0x802edd,(%esp)
  80182e:	e8 18 ea ff ff       	call   80024b <cprintf>
		return -E_INVAL;
  801833:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801838:	eb 24                	jmp    80185e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80183a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80183d:	8b 52 0c             	mov    0xc(%edx),%edx
  801840:	85 d2                	test   %edx,%edx
  801842:	74 15                	je     801859 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801844:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801847:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80184b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80184e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801852:	89 04 24             	mov    %eax,(%esp)
  801855:	ff d2                	call   *%edx
  801857:	eb 05                	jmp    80185e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801859:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80185e:	83 c4 24             	add    $0x24,%esp
  801861:	5b                   	pop    %ebx
  801862:	5d                   	pop    %ebp
  801863:	c3                   	ret    

00801864 <seek>:

int
seek(int fdnum, off_t offset)
{
  801864:	55                   	push   %ebp
  801865:	89 e5                	mov    %esp,%ebp
  801867:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80186a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80186d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801871:	8b 45 08             	mov    0x8(%ebp),%eax
  801874:	89 04 24             	mov    %eax,(%esp)
  801877:	e8 ea fb ff ff       	call   801466 <fd_lookup>
  80187c:	85 c0                	test   %eax,%eax
  80187e:	78 0e                	js     80188e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801880:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801883:	8b 55 0c             	mov    0xc(%ebp),%edx
  801886:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801889:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80188e:	c9                   	leave  
  80188f:	c3                   	ret    

00801890 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	53                   	push   %ebx
  801894:	83 ec 24             	sub    $0x24,%esp
  801897:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80189a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80189d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a1:	89 1c 24             	mov    %ebx,(%esp)
  8018a4:	e8 bd fb ff ff       	call   801466 <fd_lookup>
  8018a9:	89 c2                	mov    %eax,%edx
  8018ab:	85 d2                	test   %edx,%edx
  8018ad:	78 61                	js     801910 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b9:	8b 00                	mov    (%eax),%eax
  8018bb:	89 04 24             	mov    %eax,(%esp)
  8018be:	e8 f9 fb ff ff       	call   8014bc <dev_lookup>
  8018c3:	85 c0                	test   %eax,%eax
  8018c5:	78 49                	js     801910 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ca:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018ce:	75 23                	jne    8018f3 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018d0:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018d5:	8b 40 48             	mov    0x48(%eax),%eax
  8018d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e0:	c7 04 24 a0 2e 80 00 	movl   $0x802ea0,(%esp)
  8018e7:	e8 5f e9 ff ff       	call   80024b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018f1:	eb 1d                	jmp    801910 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8018f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018f6:	8b 52 18             	mov    0x18(%edx),%edx
  8018f9:	85 d2                	test   %edx,%edx
  8018fb:	74 0e                	je     80190b <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801900:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801904:	89 04 24             	mov    %eax,(%esp)
  801907:	ff d2                	call   *%edx
  801909:	eb 05                	jmp    801910 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80190b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801910:	83 c4 24             	add    $0x24,%esp
  801913:	5b                   	pop    %ebx
  801914:	5d                   	pop    %ebp
  801915:	c3                   	ret    

00801916 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	53                   	push   %ebx
  80191a:	83 ec 24             	sub    $0x24,%esp
  80191d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801920:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801923:	89 44 24 04          	mov    %eax,0x4(%esp)
  801927:	8b 45 08             	mov    0x8(%ebp),%eax
  80192a:	89 04 24             	mov    %eax,(%esp)
  80192d:	e8 34 fb ff ff       	call   801466 <fd_lookup>
  801932:	89 c2                	mov    %eax,%edx
  801934:	85 d2                	test   %edx,%edx
  801936:	78 52                	js     80198a <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801938:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801942:	8b 00                	mov    (%eax),%eax
  801944:	89 04 24             	mov    %eax,(%esp)
  801947:	e8 70 fb ff ff       	call   8014bc <dev_lookup>
  80194c:	85 c0                	test   %eax,%eax
  80194e:	78 3a                	js     80198a <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801950:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801953:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801957:	74 2c                	je     801985 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801959:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80195c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801963:	00 00 00 
	stat->st_isdir = 0;
  801966:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80196d:	00 00 00 
	stat->st_dev = dev;
  801970:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801976:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80197a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80197d:	89 14 24             	mov    %edx,(%esp)
  801980:	ff 50 14             	call   *0x14(%eax)
  801983:	eb 05                	jmp    80198a <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801985:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80198a:	83 c4 24             	add    $0x24,%esp
  80198d:	5b                   	pop    %ebx
  80198e:	5d                   	pop    %ebp
  80198f:	c3                   	ret    

00801990 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	56                   	push   %esi
  801994:	53                   	push   %ebx
  801995:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801998:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80199f:	00 
  8019a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a3:	89 04 24             	mov    %eax,(%esp)
  8019a6:	e8 28 02 00 00       	call   801bd3 <open>
  8019ab:	89 c3                	mov    %eax,%ebx
  8019ad:	85 db                	test   %ebx,%ebx
  8019af:	78 1b                	js     8019cc <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8019b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b8:	89 1c 24             	mov    %ebx,(%esp)
  8019bb:	e8 56 ff ff ff       	call   801916 <fstat>
  8019c0:	89 c6                	mov    %eax,%esi
	close(fd);
  8019c2:	89 1c 24             	mov    %ebx,(%esp)
  8019c5:	e8 cd fb ff ff       	call   801597 <close>
	return r;
  8019ca:	89 f0                	mov    %esi,%eax
}
  8019cc:	83 c4 10             	add    $0x10,%esp
  8019cf:	5b                   	pop    %ebx
  8019d0:	5e                   	pop    %esi
  8019d1:	5d                   	pop    %ebp
  8019d2:	c3                   	ret    

008019d3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019d3:	55                   	push   %ebp
  8019d4:	89 e5                	mov    %esp,%ebp
  8019d6:	56                   	push   %esi
  8019d7:	53                   	push   %ebx
  8019d8:	83 ec 10             	sub    $0x10,%esp
  8019db:	89 c6                	mov    %eax,%esi
  8019dd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019df:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019e6:	75 11                	jne    8019f9 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019e8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8019ef:	e8 c1 f9 ff ff       	call   8013b5 <ipc_find_env>
  8019f4:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019f9:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a00:	00 
  801a01:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801a08:	00 
  801a09:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a0d:	a1 00 40 80 00       	mov    0x804000,%eax
  801a12:	89 04 24             	mov    %eax,(%esp)
  801a15:	e8 30 f9 ff ff       	call   80134a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a1a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a21:	00 
  801a22:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a26:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a2d:	e8 9e f8 ff ff       	call   8012d0 <ipc_recv>
}
  801a32:	83 c4 10             	add    $0x10,%esp
  801a35:	5b                   	pop    %ebx
  801a36:	5e                   	pop    %esi
  801a37:	5d                   	pop    %ebp
  801a38:	c3                   	ret    

00801a39 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a42:	8b 40 0c             	mov    0xc(%eax),%eax
  801a45:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a4d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a52:	ba 00 00 00 00       	mov    $0x0,%edx
  801a57:	b8 02 00 00 00       	mov    $0x2,%eax
  801a5c:	e8 72 ff ff ff       	call   8019d3 <fsipc>
}
  801a61:	c9                   	leave  
  801a62:	c3                   	ret    

00801a63 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a63:	55                   	push   %ebp
  801a64:	89 e5                	mov    %esp,%ebp
  801a66:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a69:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6c:	8b 40 0c             	mov    0xc(%eax),%eax
  801a6f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a74:	ba 00 00 00 00       	mov    $0x0,%edx
  801a79:	b8 06 00 00 00       	mov    $0x6,%eax
  801a7e:	e8 50 ff ff ff       	call   8019d3 <fsipc>
}
  801a83:	c9                   	leave  
  801a84:	c3                   	ret    

00801a85 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a85:	55                   	push   %ebp
  801a86:	89 e5                	mov    %esp,%ebp
  801a88:	53                   	push   %ebx
  801a89:	83 ec 14             	sub    $0x14,%esp
  801a8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a92:	8b 40 0c             	mov    0xc(%eax),%eax
  801a95:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a9a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a9f:	b8 05 00 00 00       	mov    $0x5,%eax
  801aa4:	e8 2a ff ff ff       	call   8019d3 <fsipc>
  801aa9:	89 c2                	mov    %eax,%edx
  801aab:	85 d2                	test   %edx,%edx
  801aad:	78 2b                	js     801ada <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801aaf:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801ab6:	00 
  801ab7:	89 1c 24             	mov    %ebx,(%esp)
  801aba:	e8 b8 ed ff ff       	call   800877 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801abf:	a1 80 50 80 00       	mov    0x805080,%eax
  801ac4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801aca:	a1 84 50 80 00       	mov    0x805084,%eax
  801acf:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ad5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ada:	83 c4 14             	add    $0x14,%esp
  801add:	5b                   	pop    %ebx
  801ade:	5d                   	pop    %ebp
  801adf:	c3                   	ret    

00801ae0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	83 ec 18             	sub    $0x18,%esp
  801ae6:	8b 45 10             	mov    0x10(%ebp),%eax
  801ae9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801aee:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801af3:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801af6:	8b 55 08             	mov    0x8(%ebp),%edx
  801af9:	8b 52 0c             	mov    0xc(%edx),%edx
  801afc:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801b02:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801b07:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b12:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801b19:	e8 f6 ee ff ff       	call   800a14 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  801b1e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b23:	b8 04 00 00 00       	mov    $0x4,%eax
  801b28:	e8 a6 fe ff ff       	call   8019d3 <fsipc>
}
  801b2d:	c9                   	leave  
  801b2e:	c3                   	ret    

00801b2f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	56                   	push   %esi
  801b33:	53                   	push   %ebx
  801b34:	83 ec 10             	sub    $0x10,%esp
  801b37:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3d:	8b 40 0c             	mov    0xc(%eax),%eax
  801b40:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b45:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b4b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b50:	b8 03 00 00 00       	mov    $0x3,%eax
  801b55:	e8 79 fe ff ff       	call   8019d3 <fsipc>
  801b5a:	89 c3                	mov    %eax,%ebx
  801b5c:	85 c0                	test   %eax,%eax
  801b5e:	78 6a                	js     801bca <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801b60:	39 c6                	cmp    %eax,%esi
  801b62:	73 24                	jae    801b88 <devfile_read+0x59>
  801b64:	c7 44 24 0c 10 2f 80 	movl   $0x802f10,0xc(%esp)
  801b6b:	00 
  801b6c:	c7 44 24 08 17 2f 80 	movl   $0x802f17,0x8(%esp)
  801b73:	00 
  801b74:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801b7b:	00 
  801b7c:	c7 04 24 2c 2f 80 00 	movl   $0x802f2c,(%esp)
  801b83:	e8 1e 0b 00 00       	call   8026a6 <_panic>
	assert(r <= PGSIZE);
  801b88:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b8d:	7e 24                	jle    801bb3 <devfile_read+0x84>
  801b8f:	c7 44 24 0c 37 2f 80 	movl   $0x802f37,0xc(%esp)
  801b96:	00 
  801b97:	c7 44 24 08 17 2f 80 	movl   $0x802f17,0x8(%esp)
  801b9e:	00 
  801b9f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801ba6:	00 
  801ba7:	c7 04 24 2c 2f 80 00 	movl   $0x802f2c,(%esp)
  801bae:	e8 f3 0a 00 00       	call   8026a6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bb3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bb7:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801bbe:	00 
  801bbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc2:	89 04 24             	mov    %eax,(%esp)
  801bc5:	e8 4a ee ff ff       	call   800a14 <memmove>
	return r;
}
  801bca:	89 d8                	mov    %ebx,%eax
  801bcc:	83 c4 10             	add    $0x10,%esp
  801bcf:	5b                   	pop    %ebx
  801bd0:	5e                   	pop    %esi
  801bd1:	5d                   	pop    %ebp
  801bd2:	c3                   	ret    

00801bd3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bd3:	55                   	push   %ebp
  801bd4:	89 e5                	mov    %esp,%ebp
  801bd6:	53                   	push   %ebx
  801bd7:	83 ec 24             	sub    $0x24,%esp
  801bda:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bdd:	89 1c 24             	mov    %ebx,(%esp)
  801be0:	e8 5b ec ff ff       	call   800840 <strlen>
  801be5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bea:	7f 60                	jg     801c4c <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bef:	89 04 24             	mov    %eax,(%esp)
  801bf2:	e8 20 f8 ff ff       	call   801417 <fd_alloc>
  801bf7:	89 c2                	mov    %eax,%edx
  801bf9:	85 d2                	test   %edx,%edx
  801bfb:	78 54                	js     801c51 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bfd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c01:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801c08:	e8 6a ec ff ff       	call   800877 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c10:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c15:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c18:	b8 01 00 00 00       	mov    $0x1,%eax
  801c1d:	e8 b1 fd ff ff       	call   8019d3 <fsipc>
  801c22:	89 c3                	mov    %eax,%ebx
  801c24:	85 c0                	test   %eax,%eax
  801c26:	79 17                	jns    801c3f <open+0x6c>
		fd_close(fd, 0);
  801c28:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c2f:	00 
  801c30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c33:	89 04 24             	mov    %eax,(%esp)
  801c36:	e8 db f8 ff ff       	call   801516 <fd_close>
		return r;
  801c3b:	89 d8                	mov    %ebx,%eax
  801c3d:	eb 12                	jmp    801c51 <open+0x7e>
	}

	return fd2num(fd);
  801c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c42:	89 04 24             	mov    %eax,(%esp)
  801c45:	e8 a6 f7 ff ff       	call   8013f0 <fd2num>
  801c4a:	eb 05                	jmp    801c51 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c4c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c51:	83 c4 24             	add    $0x24,%esp
  801c54:	5b                   	pop    %ebx
  801c55:	5d                   	pop    %ebp
  801c56:	c3                   	ret    

00801c57 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c57:	55                   	push   %ebp
  801c58:	89 e5                	mov    %esp,%ebp
  801c5a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c5d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c62:	b8 08 00 00 00       	mov    $0x8,%eax
  801c67:	e8 67 fd ff ff       	call   8019d3 <fsipc>
}
  801c6c:	c9                   	leave  
  801c6d:	c3                   	ret    
  801c6e:	66 90                	xchg   %ax,%ax

00801c70 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
  801c73:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801c76:	c7 44 24 04 43 2f 80 	movl   $0x802f43,0x4(%esp)
  801c7d:	00 
  801c7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c81:	89 04 24             	mov    %eax,(%esp)
  801c84:	e8 ee eb ff ff       	call   800877 <strcpy>
	return 0;
}
  801c89:	b8 00 00 00 00       	mov    $0x0,%eax
  801c8e:	c9                   	leave  
  801c8f:	c3                   	ret    

00801c90 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c90:	55                   	push   %ebp
  801c91:	89 e5                	mov    %esp,%ebp
  801c93:	53                   	push   %ebx
  801c94:	83 ec 14             	sub    $0x14,%esp
  801c97:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c9a:	89 1c 24             	mov    %ebx,(%esp)
  801c9d:	e8 cb 0a 00 00       	call   80276d <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801ca2:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801ca7:	83 f8 01             	cmp    $0x1,%eax
  801caa:	75 0d                	jne    801cb9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801cac:	8b 43 0c             	mov    0xc(%ebx),%eax
  801caf:	89 04 24             	mov    %eax,(%esp)
  801cb2:	e8 29 03 00 00       	call   801fe0 <nsipc_close>
  801cb7:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  801cb9:	89 d0                	mov    %edx,%eax
  801cbb:	83 c4 14             	add    $0x14,%esp
  801cbe:	5b                   	pop    %ebx
  801cbf:	5d                   	pop    %ebp
  801cc0:	c3                   	ret    

00801cc1 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801cc1:	55                   	push   %ebp
  801cc2:	89 e5                	mov    %esp,%ebp
  801cc4:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801cc7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801cce:	00 
  801ccf:	8b 45 10             	mov    0x10(%ebp),%eax
  801cd2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cdd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce0:	8b 40 0c             	mov    0xc(%eax),%eax
  801ce3:	89 04 24             	mov    %eax,(%esp)
  801ce6:	e8 f0 03 00 00       	call   8020db <nsipc_send>
}
  801ceb:	c9                   	leave  
  801cec:	c3                   	ret    

00801ced <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801ced:	55                   	push   %ebp
  801cee:	89 e5                	mov    %esp,%ebp
  801cf0:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801cf3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801cfa:	00 
  801cfb:	8b 45 10             	mov    0x10(%ebp),%eax
  801cfe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d02:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d09:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0c:	8b 40 0c             	mov    0xc(%eax),%eax
  801d0f:	89 04 24             	mov    %eax,(%esp)
  801d12:	e8 44 03 00 00       	call   80205b <nsipc_recv>
}
  801d17:	c9                   	leave  
  801d18:	c3                   	ret    

00801d19 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d19:	55                   	push   %ebp
  801d1a:	89 e5                	mov    %esp,%ebp
  801d1c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d1f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d22:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d26:	89 04 24             	mov    %eax,(%esp)
  801d29:	e8 38 f7 ff ff       	call   801466 <fd_lookup>
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	78 17                	js     801d49 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d35:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801d3b:	39 08                	cmp    %ecx,(%eax)
  801d3d:	75 05                	jne    801d44 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d3f:	8b 40 0c             	mov    0xc(%eax),%eax
  801d42:	eb 05                	jmp    801d49 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d44:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d49:	c9                   	leave  
  801d4a:	c3                   	ret    

00801d4b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801d4b:	55                   	push   %ebp
  801d4c:	89 e5                	mov    %esp,%ebp
  801d4e:	56                   	push   %esi
  801d4f:	53                   	push   %ebx
  801d50:	83 ec 20             	sub    $0x20,%esp
  801d53:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801d55:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d58:	89 04 24             	mov    %eax,(%esp)
  801d5b:	e8 b7 f6 ff ff       	call   801417 <fd_alloc>
  801d60:	89 c3                	mov    %eax,%ebx
  801d62:	85 c0                	test   %eax,%eax
  801d64:	78 21                	js     801d87 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d66:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d6d:	00 
  801d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d71:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d75:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d7c:	e8 12 ef ff ff       	call   800c93 <sys_page_alloc>
  801d81:	89 c3                	mov    %eax,%ebx
  801d83:	85 c0                	test   %eax,%eax
  801d85:	79 0c                	jns    801d93 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  801d87:	89 34 24             	mov    %esi,(%esp)
  801d8a:	e8 51 02 00 00       	call   801fe0 <nsipc_close>
		return r;
  801d8f:	89 d8                	mov    %ebx,%eax
  801d91:	eb 20                	jmp    801db3 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d93:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801da1:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801da8:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801dab:	89 14 24             	mov    %edx,(%esp)
  801dae:	e8 3d f6 ff ff       	call   8013f0 <fd2num>
}
  801db3:	83 c4 20             	add    $0x20,%esp
  801db6:	5b                   	pop    %ebx
  801db7:	5e                   	pop    %esi
  801db8:	5d                   	pop    %ebp
  801db9:	c3                   	ret    

00801dba <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801dba:	55                   	push   %ebp
  801dbb:	89 e5                	mov    %esp,%ebp
  801dbd:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dc0:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc3:	e8 51 ff ff ff       	call   801d19 <fd2sockid>
		return r;
  801dc8:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dca:	85 c0                	test   %eax,%eax
  801dcc:	78 23                	js     801df1 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801dce:	8b 55 10             	mov    0x10(%ebp),%edx
  801dd1:	89 54 24 08          	mov    %edx,0x8(%esp)
  801dd5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dd8:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ddc:	89 04 24             	mov    %eax,(%esp)
  801ddf:	e8 45 01 00 00       	call   801f29 <nsipc_accept>
		return r;
  801de4:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801de6:	85 c0                	test   %eax,%eax
  801de8:	78 07                	js     801df1 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  801dea:	e8 5c ff ff ff       	call   801d4b <alloc_sockfd>
  801def:	89 c1                	mov    %eax,%ecx
}
  801df1:	89 c8                	mov    %ecx,%eax
  801df3:	c9                   	leave  
  801df4:	c3                   	ret    

00801df5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801df5:	55                   	push   %ebp
  801df6:	89 e5                	mov    %esp,%ebp
  801df8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfe:	e8 16 ff ff ff       	call   801d19 <fd2sockid>
  801e03:	89 c2                	mov    %eax,%edx
  801e05:	85 d2                	test   %edx,%edx
  801e07:	78 16                	js     801e1f <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  801e09:	8b 45 10             	mov    0x10(%ebp),%eax
  801e0c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e10:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e13:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e17:	89 14 24             	mov    %edx,(%esp)
  801e1a:	e8 60 01 00 00       	call   801f7f <nsipc_bind>
}
  801e1f:	c9                   	leave  
  801e20:	c3                   	ret    

00801e21 <shutdown>:

int
shutdown(int s, int how)
{
  801e21:	55                   	push   %ebp
  801e22:	89 e5                	mov    %esp,%ebp
  801e24:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e27:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2a:	e8 ea fe ff ff       	call   801d19 <fd2sockid>
  801e2f:	89 c2                	mov    %eax,%edx
  801e31:	85 d2                	test   %edx,%edx
  801e33:	78 0f                	js     801e44 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801e35:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e38:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e3c:	89 14 24             	mov    %edx,(%esp)
  801e3f:	e8 7a 01 00 00       	call   801fbe <nsipc_shutdown>
}
  801e44:	c9                   	leave  
  801e45:	c3                   	ret    

00801e46 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
  801e49:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4f:	e8 c5 fe ff ff       	call   801d19 <fd2sockid>
  801e54:	89 c2                	mov    %eax,%edx
  801e56:	85 d2                	test   %edx,%edx
  801e58:	78 16                	js     801e70 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  801e5a:	8b 45 10             	mov    0x10(%ebp),%eax
  801e5d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e61:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e64:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e68:	89 14 24             	mov    %edx,(%esp)
  801e6b:	e8 8a 01 00 00       	call   801ffa <nsipc_connect>
}
  801e70:	c9                   	leave  
  801e71:	c3                   	ret    

00801e72 <listen>:

int
listen(int s, int backlog)
{
  801e72:	55                   	push   %ebp
  801e73:	89 e5                	mov    %esp,%ebp
  801e75:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e78:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7b:	e8 99 fe ff ff       	call   801d19 <fd2sockid>
  801e80:	89 c2                	mov    %eax,%edx
  801e82:	85 d2                	test   %edx,%edx
  801e84:	78 0f                	js     801e95 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801e86:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e89:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e8d:	89 14 24             	mov    %edx,(%esp)
  801e90:	e8 a4 01 00 00       	call   802039 <nsipc_listen>
}
  801e95:	c9                   	leave  
  801e96:	c3                   	ret    

00801e97 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e97:	55                   	push   %ebp
  801e98:	89 e5                	mov    %esp,%ebp
  801e9a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e9d:	8b 45 10             	mov    0x10(%ebp),%eax
  801ea0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ea4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eab:	8b 45 08             	mov    0x8(%ebp),%eax
  801eae:	89 04 24             	mov    %eax,(%esp)
  801eb1:	e8 98 02 00 00       	call   80214e <nsipc_socket>
  801eb6:	89 c2                	mov    %eax,%edx
  801eb8:	85 d2                	test   %edx,%edx
  801eba:	78 05                	js     801ec1 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  801ebc:	e8 8a fe ff ff       	call   801d4b <alloc_sockfd>
}
  801ec1:	c9                   	leave  
  801ec2:	c3                   	ret    

00801ec3 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ec3:	55                   	push   %ebp
  801ec4:	89 e5                	mov    %esp,%ebp
  801ec6:	53                   	push   %ebx
  801ec7:	83 ec 14             	sub    $0x14,%esp
  801eca:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ecc:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801ed3:	75 11                	jne    801ee6 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801ed5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801edc:	e8 d4 f4 ff ff       	call   8013b5 <ipc_find_env>
  801ee1:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ee6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801eed:	00 
  801eee:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801ef5:	00 
  801ef6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801efa:	a1 04 40 80 00       	mov    0x804004,%eax
  801eff:	89 04 24             	mov    %eax,(%esp)
  801f02:	e8 43 f4 ff ff       	call   80134a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801f07:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f0e:	00 
  801f0f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f16:	00 
  801f17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f1e:	e8 ad f3 ff ff       	call   8012d0 <ipc_recv>
}
  801f23:	83 c4 14             	add    $0x14,%esp
  801f26:	5b                   	pop    %ebx
  801f27:	5d                   	pop    %ebp
  801f28:	c3                   	ret    

00801f29 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f29:	55                   	push   %ebp
  801f2a:	89 e5                	mov    %esp,%ebp
  801f2c:	56                   	push   %esi
  801f2d:	53                   	push   %ebx
  801f2e:	83 ec 10             	sub    $0x10,%esp
  801f31:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801f34:	8b 45 08             	mov    0x8(%ebp),%eax
  801f37:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801f3c:	8b 06                	mov    (%esi),%eax
  801f3e:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f43:	b8 01 00 00 00       	mov    $0x1,%eax
  801f48:	e8 76 ff ff ff       	call   801ec3 <nsipc>
  801f4d:	89 c3                	mov    %eax,%ebx
  801f4f:	85 c0                	test   %eax,%eax
  801f51:	78 23                	js     801f76 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f53:	a1 10 60 80 00       	mov    0x806010,%eax
  801f58:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f5c:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801f63:	00 
  801f64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f67:	89 04 24             	mov    %eax,(%esp)
  801f6a:	e8 a5 ea ff ff       	call   800a14 <memmove>
		*addrlen = ret->ret_addrlen;
  801f6f:	a1 10 60 80 00       	mov    0x806010,%eax
  801f74:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801f76:	89 d8                	mov    %ebx,%eax
  801f78:	83 c4 10             	add    $0x10,%esp
  801f7b:	5b                   	pop    %ebx
  801f7c:	5e                   	pop    %esi
  801f7d:	5d                   	pop    %ebp
  801f7e:	c3                   	ret    

00801f7f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f7f:	55                   	push   %ebp
  801f80:	89 e5                	mov    %esp,%ebp
  801f82:	53                   	push   %ebx
  801f83:	83 ec 14             	sub    $0x14,%esp
  801f86:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f89:	8b 45 08             	mov    0x8(%ebp),%eax
  801f8c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f91:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f98:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f9c:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801fa3:	e8 6c ea ff ff       	call   800a14 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801fa8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801fae:	b8 02 00 00 00       	mov    $0x2,%eax
  801fb3:	e8 0b ff ff ff       	call   801ec3 <nsipc>
}
  801fb8:	83 c4 14             	add    $0x14,%esp
  801fbb:	5b                   	pop    %ebx
  801fbc:	5d                   	pop    %ebp
  801fbd:	c3                   	ret    

00801fbe <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801fbe:	55                   	push   %ebp
  801fbf:	89 e5                	mov    %esp,%ebp
  801fc1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801fc4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801fcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fcf:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801fd4:	b8 03 00 00 00       	mov    $0x3,%eax
  801fd9:	e8 e5 fe ff ff       	call   801ec3 <nsipc>
}
  801fde:	c9                   	leave  
  801fdf:	c3                   	ret    

00801fe0 <nsipc_close>:

int
nsipc_close(int s)
{
  801fe0:	55                   	push   %ebp
  801fe1:	89 e5                	mov    %esp,%ebp
  801fe3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801fe6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe9:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801fee:	b8 04 00 00 00       	mov    $0x4,%eax
  801ff3:	e8 cb fe ff ff       	call   801ec3 <nsipc>
}
  801ff8:	c9                   	leave  
  801ff9:	c3                   	ret    

00801ffa <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ffa:	55                   	push   %ebp
  801ffb:	89 e5                	mov    %esp,%ebp
  801ffd:	53                   	push   %ebx
  801ffe:	83 ec 14             	sub    $0x14,%esp
  802001:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802004:	8b 45 08             	mov    0x8(%ebp),%eax
  802007:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80200c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802010:	8b 45 0c             	mov    0xc(%ebp),%eax
  802013:	89 44 24 04          	mov    %eax,0x4(%esp)
  802017:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  80201e:	e8 f1 e9 ff ff       	call   800a14 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802023:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  802029:	b8 05 00 00 00       	mov    $0x5,%eax
  80202e:	e8 90 fe ff ff       	call   801ec3 <nsipc>
}
  802033:	83 c4 14             	add    $0x14,%esp
  802036:	5b                   	pop    %ebx
  802037:	5d                   	pop    %ebp
  802038:	c3                   	ret    

00802039 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802039:	55                   	push   %ebp
  80203a:	89 e5                	mov    %esp,%ebp
  80203c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80203f:	8b 45 08             	mov    0x8(%ebp),%eax
  802042:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  802047:	8b 45 0c             	mov    0xc(%ebp),%eax
  80204a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80204f:	b8 06 00 00 00       	mov    $0x6,%eax
  802054:	e8 6a fe ff ff       	call   801ec3 <nsipc>
}
  802059:	c9                   	leave  
  80205a:	c3                   	ret    

0080205b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80205b:	55                   	push   %ebp
  80205c:	89 e5                	mov    %esp,%ebp
  80205e:	56                   	push   %esi
  80205f:	53                   	push   %ebx
  802060:	83 ec 10             	sub    $0x10,%esp
  802063:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802066:	8b 45 08             	mov    0x8(%ebp),%eax
  802069:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80206e:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  802074:	8b 45 14             	mov    0x14(%ebp),%eax
  802077:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80207c:	b8 07 00 00 00       	mov    $0x7,%eax
  802081:	e8 3d fe ff ff       	call   801ec3 <nsipc>
  802086:	89 c3                	mov    %eax,%ebx
  802088:	85 c0                	test   %eax,%eax
  80208a:	78 46                	js     8020d2 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  80208c:	39 f0                	cmp    %esi,%eax
  80208e:	7f 07                	jg     802097 <nsipc_recv+0x3c>
  802090:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802095:	7e 24                	jle    8020bb <nsipc_recv+0x60>
  802097:	c7 44 24 0c 4f 2f 80 	movl   $0x802f4f,0xc(%esp)
  80209e:	00 
  80209f:	c7 44 24 08 17 2f 80 	movl   $0x802f17,0x8(%esp)
  8020a6:	00 
  8020a7:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  8020ae:	00 
  8020af:	c7 04 24 64 2f 80 00 	movl   $0x802f64,(%esp)
  8020b6:	e8 eb 05 00 00       	call   8026a6 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8020bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020bf:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8020c6:	00 
  8020c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ca:	89 04 24             	mov    %eax,(%esp)
  8020cd:	e8 42 e9 ff ff       	call   800a14 <memmove>
	}

	return r;
}
  8020d2:	89 d8                	mov    %ebx,%eax
  8020d4:	83 c4 10             	add    $0x10,%esp
  8020d7:	5b                   	pop    %ebx
  8020d8:	5e                   	pop    %esi
  8020d9:	5d                   	pop    %ebp
  8020da:	c3                   	ret    

008020db <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8020db:	55                   	push   %ebp
  8020dc:	89 e5                	mov    %esp,%ebp
  8020de:	53                   	push   %ebx
  8020df:	83 ec 14             	sub    $0x14,%esp
  8020e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8020e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e8:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8020ed:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8020f3:	7e 24                	jle    802119 <nsipc_send+0x3e>
  8020f5:	c7 44 24 0c 70 2f 80 	movl   $0x802f70,0xc(%esp)
  8020fc:	00 
  8020fd:	c7 44 24 08 17 2f 80 	movl   $0x802f17,0x8(%esp)
  802104:	00 
  802105:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  80210c:	00 
  80210d:	c7 04 24 64 2f 80 00 	movl   $0x802f64,(%esp)
  802114:	e8 8d 05 00 00       	call   8026a6 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802119:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80211d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802120:	89 44 24 04          	mov    %eax,0x4(%esp)
  802124:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  80212b:	e8 e4 e8 ff ff       	call   800a14 <memmove>
	nsipcbuf.send.req_size = size;
  802130:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  802136:	8b 45 14             	mov    0x14(%ebp),%eax
  802139:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  80213e:	b8 08 00 00 00       	mov    $0x8,%eax
  802143:	e8 7b fd ff ff       	call   801ec3 <nsipc>
}
  802148:	83 c4 14             	add    $0x14,%esp
  80214b:	5b                   	pop    %ebx
  80214c:	5d                   	pop    %ebp
  80214d:	c3                   	ret    

0080214e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80214e:	55                   	push   %ebp
  80214f:	89 e5                	mov    %esp,%ebp
  802151:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802154:	8b 45 08             	mov    0x8(%ebp),%eax
  802157:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80215c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80215f:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802164:	8b 45 10             	mov    0x10(%ebp),%eax
  802167:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80216c:	b8 09 00 00 00       	mov    $0x9,%eax
  802171:	e8 4d fd ff ff       	call   801ec3 <nsipc>
}
  802176:	c9                   	leave  
  802177:	c3                   	ret    

00802178 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802178:	55                   	push   %ebp
  802179:	89 e5                	mov    %esp,%ebp
  80217b:	56                   	push   %esi
  80217c:	53                   	push   %ebx
  80217d:	83 ec 10             	sub    $0x10,%esp
  802180:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802183:	8b 45 08             	mov    0x8(%ebp),%eax
  802186:	89 04 24             	mov    %eax,(%esp)
  802189:	e8 72 f2 ff ff       	call   801400 <fd2data>
  80218e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802190:	c7 44 24 04 7c 2f 80 	movl   $0x802f7c,0x4(%esp)
  802197:	00 
  802198:	89 1c 24             	mov    %ebx,(%esp)
  80219b:	e8 d7 e6 ff ff       	call   800877 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8021a0:	8b 46 04             	mov    0x4(%esi),%eax
  8021a3:	2b 06                	sub    (%esi),%eax
  8021a5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8021ab:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8021b2:	00 00 00 
	stat->st_dev = &devpipe;
  8021b5:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8021bc:	30 80 00 
	return 0;
}
  8021bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8021c4:	83 c4 10             	add    $0x10,%esp
  8021c7:	5b                   	pop    %ebx
  8021c8:	5e                   	pop    %esi
  8021c9:	5d                   	pop    %ebp
  8021ca:	c3                   	ret    

008021cb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8021cb:	55                   	push   %ebp
  8021cc:	89 e5                	mov    %esp,%ebp
  8021ce:	53                   	push   %ebx
  8021cf:	83 ec 14             	sub    $0x14,%esp
  8021d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8021d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021e0:	e8 55 eb ff ff       	call   800d3a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8021e5:	89 1c 24             	mov    %ebx,(%esp)
  8021e8:	e8 13 f2 ff ff       	call   801400 <fd2data>
  8021ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021f8:	e8 3d eb ff ff       	call   800d3a <sys_page_unmap>
}
  8021fd:	83 c4 14             	add    $0x14,%esp
  802200:	5b                   	pop    %ebx
  802201:	5d                   	pop    %ebp
  802202:	c3                   	ret    

00802203 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802203:	55                   	push   %ebp
  802204:	89 e5                	mov    %esp,%ebp
  802206:	57                   	push   %edi
  802207:	56                   	push   %esi
  802208:	53                   	push   %ebx
  802209:	83 ec 2c             	sub    $0x2c,%esp
  80220c:	89 c6                	mov    %eax,%esi
  80220e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802211:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802216:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802219:	89 34 24             	mov    %esi,(%esp)
  80221c:	e8 4c 05 00 00       	call   80276d <pageref>
  802221:	89 c7                	mov    %eax,%edi
  802223:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802226:	89 04 24             	mov    %eax,(%esp)
  802229:	e8 3f 05 00 00       	call   80276d <pageref>
  80222e:	39 c7                	cmp    %eax,%edi
  802230:	0f 94 c2             	sete   %dl
  802233:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  802236:	8b 0d 0c 40 80 00    	mov    0x80400c,%ecx
  80223c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  80223f:	39 fb                	cmp    %edi,%ebx
  802241:	74 21                	je     802264 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802243:	84 d2                	test   %dl,%dl
  802245:	74 ca                	je     802211 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802247:	8b 51 58             	mov    0x58(%ecx),%edx
  80224a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80224e:	89 54 24 08          	mov    %edx,0x8(%esp)
  802252:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802256:	c7 04 24 83 2f 80 00 	movl   $0x802f83,(%esp)
  80225d:	e8 e9 df ff ff       	call   80024b <cprintf>
  802262:	eb ad                	jmp    802211 <_pipeisclosed+0xe>
	}
}
  802264:	83 c4 2c             	add    $0x2c,%esp
  802267:	5b                   	pop    %ebx
  802268:	5e                   	pop    %esi
  802269:	5f                   	pop    %edi
  80226a:	5d                   	pop    %ebp
  80226b:	c3                   	ret    

0080226c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80226c:	55                   	push   %ebp
  80226d:	89 e5                	mov    %esp,%ebp
  80226f:	57                   	push   %edi
  802270:	56                   	push   %esi
  802271:	53                   	push   %ebx
  802272:	83 ec 1c             	sub    $0x1c,%esp
  802275:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802278:	89 34 24             	mov    %esi,(%esp)
  80227b:	e8 80 f1 ff ff       	call   801400 <fd2data>
  802280:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802282:	bf 00 00 00 00       	mov    $0x0,%edi
  802287:	eb 45                	jmp    8022ce <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802289:	89 da                	mov    %ebx,%edx
  80228b:	89 f0                	mov    %esi,%eax
  80228d:	e8 71 ff ff ff       	call   802203 <_pipeisclosed>
  802292:	85 c0                	test   %eax,%eax
  802294:	75 41                	jne    8022d7 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802296:	e8 d9 e9 ff ff       	call   800c74 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80229b:	8b 43 04             	mov    0x4(%ebx),%eax
  80229e:	8b 0b                	mov    (%ebx),%ecx
  8022a0:	8d 51 20             	lea    0x20(%ecx),%edx
  8022a3:	39 d0                	cmp    %edx,%eax
  8022a5:	73 e2                	jae    802289 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8022a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022aa:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8022ae:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8022b1:	99                   	cltd   
  8022b2:	c1 ea 1b             	shr    $0x1b,%edx
  8022b5:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8022b8:	83 e1 1f             	and    $0x1f,%ecx
  8022bb:	29 d1                	sub    %edx,%ecx
  8022bd:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8022c1:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8022c5:	83 c0 01             	add    $0x1,%eax
  8022c8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022cb:	83 c7 01             	add    $0x1,%edi
  8022ce:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8022d1:	75 c8                	jne    80229b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8022d3:	89 f8                	mov    %edi,%eax
  8022d5:	eb 05                	jmp    8022dc <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022d7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8022dc:	83 c4 1c             	add    $0x1c,%esp
  8022df:	5b                   	pop    %ebx
  8022e0:	5e                   	pop    %esi
  8022e1:	5f                   	pop    %edi
  8022e2:	5d                   	pop    %ebp
  8022e3:	c3                   	ret    

008022e4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022e4:	55                   	push   %ebp
  8022e5:	89 e5                	mov    %esp,%ebp
  8022e7:	57                   	push   %edi
  8022e8:	56                   	push   %esi
  8022e9:	53                   	push   %ebx
  8022ea:	83 ec 1c             	sub    $0x1c,%esp
  8022ed:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8022f0:	89 3c 24             	mov    %edi,(%esp)
  8022f3:	e8 08 f1 ff ff       	call   801400 <fd2data>
  8022f8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022fa:	be 00 00 00 00       	mov    $0x0,%esi
  8022ff:	eb 3d                	jmp    80233e <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802301:	85 f6                	test   %esi,%esi
  802303:	74 04                	je     802309 <devpipe_read+0x25>
				return i;
  802305:	89 f0                	mov    %esi,%eax
  802307:	eb 43                	jmp    80234c <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802309:	89 da                	mov    %ebx,%edx
  80230b:	89 f8                	mov    %edi,%eax
  80230d:	e8 f1 fe ff ff       	call   802203 <_pipeisclosed>
  802312:	85 c0                	test   %eax,%eax
  802314:	75 31                	jne    802347 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802316:	e8 59 e9 ff ff       	call   800c74 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80231b:	8b 03                	mov    (%ebx),%eax
  80231d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802320:	74 df                	je     802301 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802322:	99                   	cltd   
  802323:	c1 ea 1b             	shr    $0x1b,%edx
  802326:	01 d0                	add    %edx,%eax
  802328:	83 e0 1f             	and    $0x1f,%eax
  80232b:	29 d0                	sub    %edx,%eax
  80232d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802332:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802335:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802338:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80233b:	83 c6 01             	add    $0x1,%esi
  80233e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802341:	75 d8                	jne    80231b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802343:	89 f0                	mov    %esi,%eax
  802345:	eb 05                	jmp    80234c <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802347:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80234c:	83 c4 1c             	add    $0x1c,%esp
  80234f:	5b                   	pop    %ebx
  802350:	5e                   	pop    %esi
  802351:	5f                   	pop    %edi
  802352:	5d                   	pop    %ebp
  802353:	c3                   	ret    

00802354 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802354:	55                   	push   %ebp
  802355:	89 e5                	mov    %esp,%ebp
  802357:	56                   	push   %esi
  802358:	53                   	push   %ebx
  802359:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80235c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80235f:	89 04 24             	mov    %eax,(%esp)
  802362:	e8 b0 f0 ff ff       	call   801417 <fd_alloc>
  802367:	89 c2                	mov    %eax,%edx
  802369:	85 d2                	test   %edx,%edx
  80236b:	0f 88 4d 01 00 00    	js     8024be <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802371:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802378:	00 
  802379:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80237c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802380:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802387:	e8 07 e9 ff ff       	call   800c93 <sys_page_alloc>
  80238c:	89 c2                	mov    %eax,%edx
  80238e:	85 d2                	test   %edx,%edx
  802390:	0f 88 28 01 00 00    	js     8024be <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802396:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802399:	89 04 24             	mov    %eax,(%esp)
  80239c:	e8 76 f0 ff ff       	call   801417 <fd_alloc>
  8023a1:	89 c3                	mov    %eax,%ebx
  8023a3:	85 c0                	test   %eax,%eax
  8023a5:	0f 88 fe 00 00 00    	js     8024a9 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023ab:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8023b2:	00 
  8023b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023c1:	e8 cd e8 ff ff       	call   800c93 <sys_page_alloc>
  8023c6:	89 c3                	mov    %eax,%ebx
  8023c8:	85 c0                	test   %eax,%eax
  8023ca:	0f 88 d9 00 00 00    	js     8024a9 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8023d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023d3:	89 04 24             	mov    %eax,(%esp)
  8023d6:	e8 25 f0 ff ff       	call   801400 <fd2data>
  8023db:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023dd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8023e4:	00 
  8023e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023f0:	e8 9e e8 ff ff       	call   800c93 <sys_page_alloc>
  8023f5:	89 c3                	mov    %eax,%ebx
  8023f7:	85 c0                	test   %eax,%eax
  8023f9:	0f 88 97 00 00 00    	js     802496 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802402:	89 04 24             	mov    %eax,(%esp)
  802405:	e8 f6 ef ff ff       	call   801400 <fd2data>
  80240a:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802411:	00 
  802412:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802416:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80241d:	00 
  80241e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802422:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802429:	e8 b9 e8 ff ff       	call   800ce7 <sys_page_map>
  80242e:	89 c3                	mov    %eax,%ebx
  802430:	85 c0                	test   %eax,%eax
  802432:	78 52                	js     802486 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802434:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80243a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80243d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80243f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802442:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802449:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80244f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802452:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802454:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802457:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80245e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802461:	89 04 24             	mov    %eax,(%esp)
  802464:	e8 87 ef ff ff       	call   8013f0 <fd2num>
  802469:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80246c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80246e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802471:	89 04 24             	mov    %eax,(%esp)
  802474:	e8 77 ef ff ff       	call   8013f0 <fd2num>
  802479:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80247c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80247f:	b8 00 00 00 00       	mov    $0x0,%eax
  802484:	eb 38                	jmp    8024be <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  802486:	89 74 24 04          	mov    %esi,0x4(%esp)
  80248a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802491:	e8 a4 e8 ff ff       	call   800d3a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802496:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802499:	89 44 24 04          	mov    %eax,0x4(%esp)
  80249d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024a4:	e8 91 e8 ff ff       	call   800d3a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8024a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024b7:	e8 7e e8 ff ff       	call   800d3a <sys_page_unmap>
  8024bc:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  8024be:	83 c4 30             	add    $0x30,%esp
  8024c1:	5b                   	pop    %ebx
  8024c2:	5e                   	pop    %esi
  8024c3:	5d                   	pop    %ebp
  8024c4:	c3                   	ret    

008024c5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8024c5:	55                   	push   %ebp
  8024c6:	89 e5                	mov    %esp,%ebp
  8024c8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8024d5:	89 04 24             	mov    %eax,(%esp)
  8024d8:	e8 89 ef ff ff       	call   801466 <fd_lookup>
  8024dd:	89 c2                	mov    %eax,%edx
  8024df:	85 d2                	test   %edx,%edx
  8024e1:	78 15                	js     8024f8 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8024e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024e6:	89 04 24             	mov    %eax,(%esp)
  8024e9:	e8 12 ef ff ff       	call   801400 <fd2data>
	return _pipeisclosed(fd, p);
  8024ee:	89 c2                	mov    %eax,%edx
  8024f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024f3:	e8 0b fd ff ff       	call   802203 <_pipeisclosed>
}
  8024f8:	c9                   	leave  
  8024f9:	c3                   	ret    
  8024fa:	66 90                	xchg   %ax,%ax
  8024fc:	66 90                	xchg   %ax,%ax
  8024fe:	66 90                	xchg   %ax,%ax

00802500 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802500:	55                   	push   %ebp
  802501:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802503:	b8 00 00 00 00       	mov    $0x0,%eax
  802508:	5d                   	pop    %ebp
  802509:	c3                   	ret    

0080250a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80250a:	55                   	push   %ebp
  80250b:	89 e5                	mov    %esp,%ebp
  80250d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802510:	c7 44 24 04 9b 2f 80 	movl   $0x802f9b,0x4(%esp)
  802517:	00 
  802518:	8b 45 0c             	mov    0xc(%ebp),%eax
  80251b:	89 04 24             	mov    %eax,(%esp)
  80251e:	e8 54 e3 ff ff       	call   800877 <strcpy>
	return 0;
}
  802523:	b8 00 00 00 00       	mov    $0x0,%eax
  802528:	c9                   	leave  
  802529:	c3                   	ret    

0080252a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80252a:	55                   	push   %ebp
  80252b:	89 e5                	mov    %esp,%ebp
  80252d:	57                   	push   %edi
  80252e:	56                   	push   %esi
  80252f:	53                   	push   %ebx
  802530:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802536:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80253b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802541:	eb 31                	jmp    802574 <devcons_write+0x4a>
		m = n - tot;
  802543:	8b 75 10             	mov    0x10(%ebp),%esi
  802546:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802548:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80254b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802550:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802553:	89 74 24 08          	mov    %esi,0x8(%esp)
  802557:	03 45 0c             	add    0xc(%ebp),%eax
  80255a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80255e:	89 3c 24             	mov    %edi,(%esp)
  802561:	e8 ae e4 ff ff       	call   800a14 <memmove>
		sys_cputs(buf, m);
  802566:	89 74 24 04          	mov    %esi,0x4(%esp)
  80256a:	89 3c 24             	mov    %edi,(%esp)
  80256d:	e8 54 e6 ff ff       	call   800bc6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802572:	01 f3                	add    %esi,%ebx
  802574:	89 d8                	mov    %ebx,%eax
  802576:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802579:	72 c8                	jb     802543 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80257b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802581:	5b                   	pop    %ebx
  802582:	5e                   	pop    %esi
  802583:	5f                   	pop    %edi
  802584:	5d                   	pop    %ebp
  802585:	c3                   	ret    

00802586 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802586:	55                   	push   %ebp
  802587:	89 e5                	mov    %esp,%ebp
  802589:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80258c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802591:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802595:	75 07                	jne    80259e <devcons_read+0x18>
  802597:	eb 2a                	jmp    8025c3 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802599:	e8 d6 e6 ff ff       	call   800c74 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80259e:	66 90                	xchg   %ax,%ax
  8025a0:	e8 3f e6 ff ff       	call   800be4 <sys_cgetc>
  8025a5:	85 c0                	test   %eax,%eax
  8025a7:	74 f0                	je     802599 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8025a9:	85 c0                	test   %eax,%eax
  8025ab:	78 16                	js     8025c3 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8025ad:	83 f8 04             	cmp    $0x4,%eax
  8025b0:	74 0c                	je     8025be <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  8025b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8025b5:	88 02                	mov    %al,(%edx)
	return 1;
  8025b7:	b8 01 00 00 00       	mov    $0x1,%eax
  8025bc:	eb 05                	jmp    8025c3 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8025be:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8025c3:	c9                   	leave  
  8025c4:	c3                   	ret    

008025c5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8025c5:	55                   	push   %ebp
  8025c6:	89 e5                	mov    %esp,%ebp
  8025c8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8025cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8025ce:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8025d1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8025d8:	00 
  8025d9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8025dc:	89 04 24             	mov    %eax,(%esp)
  8025df:	e8 e2 e5 ff ff       	call   800bc6 <sys_cputs>
}
  8025e4:	c9                   	leave  
  8025e5:	c3                   	ret    

008025e6 <getchar>:

int
getchar(void)
{
  8025e6:	55                   	push   %ebp
  8025e7:	89 e5                	mov    %esp,%ebp
  8025e9:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8025ec:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8025f3:	00 
  8025f4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8025f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802602:	e8 f3 f0 ff ff       	call   8016fa <read>
	if (r < 0)
  802607:	85 c0                	test   %eax,%eax
  802609:	78 0f                	js     80261a <getchar+0x34>
		return r;
	if (r < 1)
  80260b:	85 c0                	test   %eax,%eax
  80260d:	7e 06                	jle    802615 <getchar+0x2f>
		return -E_EOF;
	return c;
  80260f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802613:	eb 05                	jmp    80261a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802615:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80261a:	c9                   	leave  
  80261b:	c3                   	ret    

0080261c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80261c:	55                   	push   %ebp
  80261d:	89 e5                	mov    %esp,%ebp
  80261f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802622:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802625:	89 44 24 04          	mov    %eax,0x4(%esp)
  802629:	8b 45 08             	mov    0x8(%ebp),%eax
  80262c:	89 04 24             	mov    %eax,(%esp)
  80262f:	e8 32 ee ff ff       	call   801466 <fd_lookup>
  802634:	85 c0                	test   %eax,%eax
  802636:	78 11                	js     802649 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802638:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80263b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802641:	39 10                	cmp    %edx,(%eax)
  802643:	0f 94 c0             	sete   %al
  802646:	0f b6 c0             	movzbl %al,%eax
}
  802649:	c9                   	leave  
  80264a:	c3                   	ret    

0080264b <opencons>:

int
opencons(void)
{
  80264b:	55                   	push   %ebp
  80264c:	89 e5                	mov    %esp,%ebp
  80264e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802651:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802654:	89 04 24             	mov    %eax,(%esp)
  802657:	e8 bb ed ff ff       	call   801417 <fd_alloc>
		return r;
  80265c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80265e:	85 c0                	test   %eax,%eax
  802660:	78 40                	js     8026a2 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802662:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802669:	00 
  80266a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80266d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802671:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802678:	e8 16 e6 ff ff       	call   800c93 <sys_page_alloc>
		return r;
  80267d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80267f:	85 c0                	test   %eax,%eax
  802681:	78 1f                	js     8026a2 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802683:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802689:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80268c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80268e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802691:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802698:	89 04 24             	mov    %eax,(%esp)
  80269b:	e8 50 ed ff ff       	call   8013f0 <fd2num>
  8026a0:	89 c2                	mov    %eax,%edx
}
  8026a2:	89 d0                	mov    %edx,%eax
  8026a4:	c9                   	leave  
  8026a5:	c3                   	ret    

008026a6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8026a6:	55                   	push   %ebp
  8026a7:	89 e5                	mov    %esp,%ebp
  8026a9:	56                   	push   %esi
  8026aa:	53                   	push   %ebx
  8026ab:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8026ae:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8026b1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8026b7:	e8 99 e5 ff ff       	call   800c55 <sys_getenvid>
  8026bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8026bf:	89 54 24 10          	mov    %edx,0x10(%esp)
  8026c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8026c6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8026ca:	89 74 24 08          	mov    %esi,0x8(%esp)
  8026ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026d2:	c7 04 24 a8 2f 80 00 	movl   $0x802fa8,(%esp)
  8026d9:	e8 6d db ff ff       	call   80024b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8026de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8026e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8026e5:	89 04 24             	mov    %eax,(%esp)
  8026e8:	e8 fd da ff ff       	call   8001ea <vcprintf>
	cprintf("\n");
  8026ed:	c7 04 24 94 2f 80 00 	movl   $0x802f94,(%esp)
  8026f4:	e8 52 db ff ff       	call   80024b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8026f9:	cc                   	int3   
  8026fa:	eb fd                	jmp    8026f9 <_panic+0x53>

008026fc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8026fc:	55                   	push   %ebp
  8026fd:	89 e5                	mov    %esp,%ebp
  8026ff:	53                   	push   %ebx
  802700:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  802703:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80270a:	75 2f                	jne    80273b <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  80270c:	e8 44 e5 ff ff       	call   800c55 <sys_getenvid>
  802711:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P);
  802713:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80271a:	00 
  80271b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802722:	ee 
  802723:	89 04 24             	mov    %eax,(%esp)
  802726:	e8 68 e5 ff ff       	call   800c93 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *)_pgfault_upcall);
  80272b:	c7 44 24 04 49 27 80 	movl   $0x802749,0x4(%esp)
  802732:	00 
  802733:	89 1c 24             	mov    %ebx,(%esp)
  802736:	e8 f8 e6 ff ff       	call   800e33 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80273b:	8b 45 08             	mov    0x8(%ebp),%eax
  80273e:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802743:	83 c4 14             	add    $0x14,%esp
  802746:	5b                   	pop    %ebx
  802747:	5d                   	pop    %ebp
  802748:	c3                   	ret    

00802749 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802749:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80274a:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80274f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802751:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	// 0x30(%esp) points to trap-time stack pointer
	// 0x28(%esp) points to trap-time eip
	subl $4, 0x30(%esp)
  802754:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax 
  802759:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebp
  80275d:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %ebp, (%eax)
  802761:	89 28                	mov    %ebp,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  802763:	83 c4 08             	add    $0x8,%esp
	popal
  802766:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp //pop eip - we already stored it
  802767:	83 c4 04             	add    $0x4,%esp
	popfl
  80276a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80276b:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80276c:	c3                   	ret    

0080276d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80276d:	55                   	push   %ebp
  80276e:	89 e5                	mov    %esp,%ebp
  802770:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802773:	89 d0                	mov    %edx,%eax
  802775:	c1 e8 16             	shr    $0x16,%eax
  802778:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80277f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802784:	f6 c1 01             	test   $0x1,%cl
  802787:	74 1d                	je     8027a6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802789:	c1 ea 0c             	shr    $0xc,%edx
  80278c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802793:	f6 c2 01             	test   $0x1,%dl
  802796:	74 0e                	je     8027a6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802798:	c1 ea 0c             	shr    $0xc,%edx
  80279b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8027a2:	ef 
  8027a3:	0f b7 c0             	movzwl %ax,%eax
}
  8027a6:	5d                   	pop    %ebp
  8027a7:	c3                   	ret    
  8027a8:	66 90                	xchg   %ax,%ax
  8027aa:	66 90                	xchg   %ax,%ax
  8027ac:	66 90                	xchg   %ax,%ax
  8027ae:	66 90                	xchg   %ax,%ax

008027b0 <__udivdi3>:
  8027b0:	55                   	push   %ebp
  8027b1:	57                   	push   %edi
  8027b2:	56                   	push   %esi
  8027b3:	83 ec 0c             	sub    $0xc,%esp
  8027b6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8027ba:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8027be:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8027c2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8027c6:	85 c0                	test   %eax,%eax
  8027c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8027cc:	89 ea                	mov    %ebp,%edx
  8027ce:	89 0c 24             	mov    %ecx,(%esp)
  8027d1:	75 2d                	jne    802800 <__udivdi3+0x50>
  8027d3:	39 e9                	cmp    %ebp,%ecx
  8027d5:	77 61                	ja     802838 <__udivdi3+0x88>
  8027d7:	85 c9                	test   %ecx,%ecx
  8027d9:	89 ce                	mov    %ecx,%esi
  8027db:	75 0b                	jne    8027e8 <__udivdi3+0x38>
  8027dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8027e2:	31 d2                	xor    %edx,%edx
  8027e4:	f7 f1                	div    %ecx
  8027e6:	89 c6                	mov    %eax,%esi
  8027e8:	31 d2                	xor    %edx,%edx
  8027ea:	89 e8                	mov    %ebp,%eax
  8027ec:	f7 f6                	div    %esi
  8027ee:	89 c5                	mov    %eax,%ebp
  8027f0:	89 f8                	mov    %edi,%eax
  8027f2:	f7 f6                	div    %esi
  8027f4:	89 ea                	mov    %ebp,%edx
  8027f6:	83 c4 0c             	add    $0xc,%esp
  8027f9:	5e                   	pop    %esi
  8027fa:	5f                   	pop    %edi
  8027fb:	5d                   	pop    %ebp
  8027fc:	c3                   	ret    
  8027fd:	8d 76 00             	lea    0x0(%esi),%esi
  802800:	39 e8                	cmp    %ebp,%eax
  802802:	77 24                	ja     802828 <__udivdi3+0x78>
  802804:	0f bd e8             	bsr    %eax,%ebp
  802807:	83 f5 1f             	xor    $0x1f,%ebp
  80280a:	75 3c                	jne    802848 <__udivdi3+0x98>
  80280c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802810:	39 34 24             	cmp    %esi,(%esp)
  802813:	0f 86 9f 00 00 00    	jbe    8028b8 <__udivdi3+0x108>
  802819:	39 d0                	cmp    %edx,%eax
  80281b:	0f 82 97 00 00 00    	jb     8028b8 <__udivdi3+0x108>
  802821:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802828:	31 d2                	xor    %edx,%edx
  80282a:	31 c0                	xor    %eax,%eax
  80282c:	83 c4 0c             	add    $0xc,%esp
  80282f:	5e                   	pop    %esi
  802830:	5f                   	pop    %edi
  802831:	5d                   	pop    %ebp
  802832:	c3                   	ret    
  802833:	90                   	nop
  802834:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802838:	89 f8                	mov    %edi,%eax
  80283a:	f7 f1                	div    %ecx
  80283c:	31 d2                	xor    %edx,%edx
  80283e:	83 c4 0c             	add    $0xc,%esp
  802841:	5e                   	pop    %esi
  802842:	5f                   	pop    %edi
  802843:	5d                   	pop    %ebp
  802844:	c3                   	ret    
  802845:	8d 76 00             	lea    0x0(%esi),%esi
  802848:	89 e9                	mov    %ebp,%ecx
  80284a:	8b 3c 24             	mov    (%esp),%edi
  80284d:	d3 e0                	shl    %cl,%eax
  80284f:	89 c6                	mov    %eax,%esi
  802851:	b8 20 00 00 00       	mov    $0x20,%eax
  802856:	29 e8                	sub    %ebp,%eax
  802858:	89 c1                	mov    %eax,%ecx
  80285a:	d3 ef                	shr    %cl,%edi
  80285c:	89 e9                	mov    %ebp,%ecx
  80285e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802862:	8b 3c 24             	mov    (%esp),%edi
  802865:	09 74 24 08          	or     %esi,0x8(%esp)
  802869:	89 d6                	mov    %edx,%esi
  80286b:	d3 e7                	shl    %cl,%edi
  80286d:	89 c1                	mov    %eax,%ecx
  80286f:	89 3c 24             	mov    %edi,(%esp)
  802872:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802876:	d3 ee                	shr    %cl,%esi
  802878:	89 e9                	mov    %ebp,%ecx
  80287a:	d3 e2                	shl    %cl,%edx
  80287c:	89 c1                	mov    %eax,%ecx
  80287e:	d3 ef                	shr    %cl,%edi
  802880:	09 d7                	or     %edx,%edi
  802882:	89 f2                	mov    %esi,%edx
  802884:	89 f8                	mov    %edi,%eax
  802886:	f7 74 24 08          	divl   0x8(%esp)
  80288a:	89 d6                	mov    %edx,%esi
  80288c:	89 c7                	mov    %eax,%edi
  80288e:	f7 24 24             	mull   (%esp)
  802891:	39 d6                	cmp    %edx,%esi
  802893:	89 14 24             	mov    %edx,(%esp)
  802896:	72 30                	jb     8028c8 <__udivdi3+0x118>
  802898:	8b 54 24 04          	mov    0x4(%esp),%edx
  80289c:	89 e9                	mov    %ebp,%ecx
  80289e:	d3 e2                	shl    %cl,%edx
  8028a0:	39 c2                	cmp    %eax,%edx
  8028a2:	73 05                	jae    8028a9 <__udivdi3+0xf9>
  8028a4:	3b 34 24             	cmp    (%esp),%esi
  8028a7:	74 1f                	je     8028c8 <__udivdi3+0x118>
  8028a9:	89 f8                	mov    %edi,%eax
  8028ab:	31 d2                	xor    %edx,%edx
  8028ad:	e9 7a ff ff ff       	jmp    80282c <__udivdi3+0x7c>
  8028b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8028b8:	31 d2                	xor    %edx,%edx
  8028ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8028bf:	e9 68 ff ff ff       	jmp    80282c <__udivdi3+0x7c>
  8028c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028c8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8028cb:	31 d2                	xor    %edx,%edx
  8028cd:	83 c4 0c             	add    $0xc,%esp
  8028d0:	5e                   	pop    %esi
  8028d1:	5f                   	pop    %edi
  8028d2:	5d                   	pop    %ebp
  8028d3:	c3                   	ret    
  8028d4:	66 90                	xchg   %ax,%ax
  8028d6:	66 90                	xchg   %ax,%ax
  8028d8:	66 90                	xchg   %ax,%ax
  8028da:	66 90                	xchg   %ax,%ax
  8028dc:	66 90                	xchg   %ax,%ax
  8028de:	66 90                	xchg   %ax,%ax

008028e0 <__umoddi3>:
  8028e0:	55                   	push   %ebp
  8028e1:	57                   	push   %edi
  8028e2:	56                   	push   %esi
  8028e3:	83 ec 14             	sub    $0x14,%esp
  8028e6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8028ea:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8028ee:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8028f2:	89 c7                	mov    %eax,%edi
  8028f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028f8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8028fc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802900:	89 34 24             	mov    %esi,(%esp)
  802903:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802907:	85 c0                	test   %eax,%eax
  802909:	89 c2                	mov    %eax,%edx
  80290b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80290f:	75 17                	jne    802928 <__umoddi3+0x48>
  802911:	39 fe                	cmp    %edi,%esi
  802913:	76 4b                	jbe    802960 <__umoddi3+0x80>
  802915:	89 c8                	mov    %ecx,%eax
  802917:	89 fa                	mov    %edi,%edx
  802919:	f7 f6                	div    %esi
  80291b:	89 d0                	mov    %edx,%eax
  80291d:	31 d2                	xor    %edx,%edx
  80291f:	83 c4 14             	add    $0x14,%esp
  802922:	5e                   	pop    %esi
  802923:	5f                   	pop    %edi
  802924:	5d                   	pop    %ebp
  802925:	c3                   	ret    
  802926:	66 90                	xchg   %ax,%ax
  802928:	39 f8                	cmp    %edi,%eax
  80292a:	77 54                	ja     802980 <__umoddi3+0xa0>
  80292c:	0f bd e8             	bsr    %eax,%ebp
  80292f:	83 f5 1f             	xor    $0x1f,%ebp
  802932:	75 5c                	jne    802990 <__umoddi3+0xb0>
  802934:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802938:	39 3c 24             	cmp    %edi,(%esp)
  80293b:	0f 87 e7 00 00 00    	ja     802a28 <__umoddi3+0x148>
  802941:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802945:	29 f1                	sub    %esi,%ecx
  802947:	19 c7                	sbb    %eax,%edi
  802949:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80294d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802951:	8b 44 24 08          	mov    0x8(%esp),%eax
  802955:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802959:	83 c4 14             	add    $0x14,%esp
  80295c:	5e                   	pop    %esi
  80295d:	5f                   	pop    %edi
  80295e:	5d                   	pop    %ebp
  80295f:	c3                   	ret    
  802960:	85 f6                	test   %esi,%esi
  802962:	89 f5                	mov    %esi,%ebp
  802964:	75 0b                	jne    802971 <__umoddi3+0x91>
  802966:	b8 01 00 00 00       	mov    $0x1,%eax
  80296b:	31 d2                	xor    %edx,%edx
  80296d:	f7 f6                	div    %esi
  80296f:	89 c5                	mov    %eax,%ebp
  802971:	8b 44 24 04          	mov    0x4(%esp),%eax
  802975:	31 d2                	xor    %edx,%edx
  802977:	f7 f5                	div    %ebp
  802979:	89 c8                	mov    %ecx,%eax
  80297b:	f7 f5                	div    %ebp
  80297d:	eb 9c                	jmp    80291b <__umoddi3+0x3b>
  80297f:	90                   	nop
  802980:	89 c8                	mov    %ecx,%eax
  802982:	89 fa                	mov    %edi,%edx
  802984:	83 c4 14             	add    $0x14,%esp
  802987:	5e                   	pop    %esi
  802988:	5f                   	pop    %edi
  802989:	5d                   	pop    %ebp
  80298a:	c3                   	ret    
  80298b:	90                   	nop
  80298c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802990:	8b 04 24             	mov    (%esp),%eax
  802993:	be 20 00 00 00       	mov    $0x20,%esi
  802998:	89 e9                	mov    %ebp,%ecx
  80299a:	29 ee                	sub    %ebp,%esi
  80299c:	d3 e2                	shl    %cl,%edx
  80299e:	89 f1                	mov    %esi,%ecx
  8029a0:	d3 e8                	shr    %cl,%eax
  8029a2:	89 e9                	mov    %ebp,%ecx
  8029a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029a8:	8b 04 24             	mov    (%esp),%eax
  8029ab:	09 54 24 04          	or     %edx,0x4(%esp)
  8029af:	89 fa                	mov    %edi,%edx
  8029b1:	d3 e0                	shl    %cl,%eax
  8029b3:	89 f1                	mov    %esi,%ecx
  8029b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8029b9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8029bd:	d3 ea                	shr    %cl,%edx
  8029bf:	89 e9                	mov    %ebp,%ecx
  8029c1:	d3 e7                	shl    %cl,%edi
  8029c3:	89 f1                	mov    %esi,%ecx
  8029c5:	d3 e8                	shr    %cl,%eax
  8029c7:	89 e9                	mov    %ebp,%ecx
  8029c9:	09 f8                	or     %edi,%eax
  8029cb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8029cf:	f7 74 24 04          	divl   0x4(%esp)
  8029d3:	d3 e7                	shl    %cl,%edi
  8029d5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8029d9:	89 d7                	mov    %edx,%edi
  8029db:	f7 64 24 08          	mull   0x8(%esp)
  8029df:	39 d7                	cmp    %edx,%edi
  8029e1:	89 c1                	mov    %eax,%ecx
  8029e3:	89 14 24             	mov    %edx,(%esp)
  8029e6:	72 2c                	jb     802a14 <__umoddi3+0x134>
  8029e8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8029ec:	72 22                	jb     802a10 <__umoddi3+0x130>
  8029ee:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8029f2:	29 c8                	sub    %ecx,%eax
  8029f4:	19 d7                	sbb    %edx,%edi
  8029f6:	89 e9                	mov    %ebp,%ecx
  8029f8:	89 fa                	mov    %edi,%edx
  8029fa:	d3 e8                	shr    %cl,%eax
  8029fc:	89 f1                	mov    %esi,%ecx
  8029fe:	d3 e2                	shl    %cl,%edx
  802a00:	89 e9                	mov    %ebp,%ecx
  802a02:	d3 ef                	shr    %cl,%edi
  802a04:	09 d0                	or     %edx,%eax
  802a06:	89 fa                	mov    %edi,%edx
  802a08:	83 c4 14             	add    $0x14,%esp
  802a0b:	5e                   	pop    %esi
  802a0c:	5f                   	pop    %edi
  802a0d:	5d                   	pop    %ebp
  802a0e:	c3                   	ret    
  802a0f:	90                   	nop
  802a10:	39 d7                	cmp    %edx,%edi
  802a12:	75 da                	jne    8029ee <__umoddi3+0x10e>
  802a14:	8b 14 24             	mov    (%esp),%edx
  802a17:	89 c1                	mov    %eax,%ecx
  802a19:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  802a1d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802a21:	eb cb                	jmp    8029ee <__umoddi3+0x10e>
  802a23:	90                   	nop
  802a24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a28:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  802a2c:	0f 82 0f ff ff ff    	jb     802941 <__umoddi3+0x61>
  802a32:	e9 1a ff ff ff       	jmp    802951 <__umoddi3+0x71>
