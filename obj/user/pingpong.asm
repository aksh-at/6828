
obj/user/pingpong.debug:     file format elf32-i386


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
  80002c:	e8 ca 00 00 00       	call   8000fb <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 33 10 00 00       	call   801074 <fork>
  800041:	89 c3                	mov    %eax,%ebx
  800043:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800046:	85 c0                	test   %eax,%eax
  800048:	75 05                	jne    80004f <umain+0x1c>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80004a:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80004d:	eb 3e                	jmp    80008d <umain+0x5a>
{
	envid_t who;

	if ((who = fork()) != 0) {
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004f:	e8 b1 0b 00 00       	call   800c05 <sys_getenvid>
  800054:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 00 2a 80 00 	movl   $0x802a00,(%esp)
  800063:	e8 97 01 00 00       	call   8001ff <cprintf>
		ipc_send(who, 0, 0, 0);
  800068:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006f:	00 
  800070:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800077:	00 
  800078:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007f:	00 
  800080:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800083:	89 04 24             	mov    %eax,(%esp)
  800086:	e8 6f 12 00 00       	call   8012fa <ipc_send>
  80008b:	eb bd                	jmp    80004a <umain+0x17>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80008d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800094:	00 
  800095:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009c:	00 
  80009d:	89 34 24             	mov    %esi,(%esp)
  8000a0:	e8 db 11 00 00       	call   801280 <ipc_recv>
  8000a5:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000aa:	e8 56 0b 00 00       	call   800c05 <sys_getenvid>
  8000af:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000b3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000bb:	c7 04 24 16 2a 80 00 	movl   $0x802a16,(%esp)
  8000c2:	e8 38 01 00 00       	call   8001ff <cprintf>
		if (i == 10)
  8000c7:	83 fb 0a             	cmp    $0xa,%ebx
  8000ca:	74 27                	je     8000f3 <umain+0xc0>
			return;
		i++;
  8000cc:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000cf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d6:	00 
  8000d7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000de:	00 
  8000df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e6:	89 04 24             	mov    %eax,(%esp)
  8000e9:	e8 0c 12 00 00       	call   8012fa <ipc_send>
		if (i == 10)
  8000ee:	83 fb 0a             	cmp    $0xa,%ebx
  8000f1:	75 9a                	jne    80008d <umain+0x5a>
			return;
	}

}
  8000f3:	83 c4 2c             	add    $0x2c,%esp
  8000f6:	5b                   	pop    %ebx
  8000f7:	5e                   	pop    %esi
  8000f8:	5f                   	pop    %edi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	56                   	push   %esi
  8000ff:	53                   	push   %ebx
  800100:	83 ec 10             	sub    $0x10,%esp
  800103:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800106:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  800109:	e8 f7 0a 00 00       	call   800c05 <sys_getenvid>
  80010e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800113:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800116:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011b:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800120:	85 db                	test   %ebx,%ebx
  800122:	7e 07                	jle    80012b <libmain+0x30>
		binaryname = argv[0];
  800124:	8b 06                	mov    (%esi),%eax
  800126:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80012f:	89 1c 24             	mov    %ebx,(%esp)
  800132:	e8 fc fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800137:	e8 07 00 00 00       	call   800143 <exit>
}
  80013c:	83 c4 10             	add    $0x10,%esp
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800149:	e8 2c 14 00 00       	call   80157a <close_all>
	sys_env_destroy(0);
  80014e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800155:	e8 59 0a 00 00       	call   800bb3 <sys_env_destroy>
}
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	53                   	push   %ebx
  800160:	83 ec 14             	sub    $0x14,%esp
  800163:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800166:	8b 13                	mov    (%ebx),%edx
  800168:	8d 42 01             	lea    0x1(%edx),%eax
  80016b:	89 03                	mov    %eax,(%ebx)
  80016d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800170:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800174:	3d ff 00 00 00       	cmp    $0xff,%eax
  800179:	75 19                	jne    800194 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80017b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800182:	00 
  800183:	8d 43 08             	lea    0x8(%ebx),%eax
  800186:	89 04 24             	mov    %eax,(%esp)
  800189:	e8 e8 09 00 00       	call   800b76 <sys_cputs>
		b->idx = 0;
  80018e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800194:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800198:	83 c4 14             	add    $0x14,%esp
  80019b:	5b                   	pop    %ebx
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001a7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ae:	00 00 00 
	b.cnt = 0;
  8001b1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d3:	c7 04 24 5c 01 80 00 	movl   $0x80015c,(%esp)
  8001da:	e8 af 01 00 00       	call   80038e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001df:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ef:	89 04 24             	mov    %eax,(%esp)
  8001f2:	e8 7f 09 00 00       	call   800b76 <sys_cputs>

	return b.cnt;
}
  8001f7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fd:	c9                   	leave  
  8001fe:	c3                   	ret    

008001ff <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800205:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800208:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020c:	8b 45 08             	mov    0x8(%ebp),%eax
  80020f:	89 04 24             	mov    %eax,(%esp)
  800212:	e8 87 ff ff ff       	call   80019e <vcprintf>
	va_end(ap);

	return cnt;
}
  800217:	c9                   	leave  
  800218:	c3                   	ret    
  800219:	66 90                	xchg   %ax,%ax
  80021b:	66 90                	xchg   %ax,%ax
  80021d:	66 90                	xchg   %ax,%ax
  80021f:	90                   	nop

00800220 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 3c             	sub    $0x3c,%esp
  800229:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80022c:	89 d7                	mov    %edx,%edi
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800234:	8b 45 0c             	mov    0xc(%ebp),%eax
  800237:	89 c3                	mov    %eax,%ebx
  800239:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80023c:	8b 45 10             	mov    0x10(%ebp),%eax
  80023f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800242:	b9 00 00 00 00       	mov    $0x0,%ecx
  800247:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80024d:	39 d9                	cmp    %ebx,%ecx
  80024f:	72 05                	jb     800256 <printnum+0x36>
  800251:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800254:	77 69                	ja     8002bf <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800256:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800259:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80025d:	83 ee 01             	sub    $0x1,%esi
  800260:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800264:	89 44 24 08          	mov    %eax,0x8(%esp)
  800268:	8b 44 24 08          	mov    0x8(%esp),%eax
  80026c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800270:	89 c3                	mov    %eax,%ebx
  800272:	89 d6                	mov    %edx,%esi
  800274:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800277:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80027a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80027e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800282:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800285:	89 04 24             	mov    %eax,(%esp)
  800288:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80028b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028f:	e8 cc 24 00 00       	call   802760 <__udivdi3>
  800294:	89 d9                	mov    %ebx,%ecx
  800296:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80029a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80029e:	89 04 24             	mov    %eax,(%esp)
  8002a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002a5:	89 fa                	mov    %edi,%edx
  8002a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002aa:	e8 71 ff ff ff       	call   800220 <printnum>
  8002af:	eb 1b                	jmp    8002cc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b5:	8b 45 18             	mov    0x18(%ebp),%eax
  8002b8:	89 04 24             	mov    %eax,(%esp)
  8002bb:	ff d3                	call   *%ebx
  8002bd:	eb 03                	jmp    8002c2 <printnum+0xa2>
  8002bf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002c2:	83 ee 01             	sub    $0x1,%esi
  8002c5:	85 f6                	test   %esi,%esi
  8002c7:	7f e8                	jg     8002b1 <printnum+0x91>
  8002c9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002d0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002de:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002e5:	89 04 24             	mov    %eax,(%esp)
  8002e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ef:	e8 9c 25 00 00       	call   802890 <__umoddi3>
  8002f4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f8:	0f be 80 33 2a 80 00 	movsbl 0x802a33(%eax),%eax
  8002ff:	89 04 24             	mov    %eax,(%esp)
  800302:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800305:	ff d0                	call   *%eax
}
  800307:	83 c4 3c             	add    $0x3c,%esp
  80030a:	5b                   	pop    %ebx
  80030b:	5e                   	pop    %esi
  80030c:	5f                   	pop    %edi
  80030d:	5d                   	pop    %ebp
  80030e:	c3                   	ret    

0080030f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800312:	83 fa 01             	cmp    $0x1,%edx
  800315:	7e 0e                	jle    800325 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800317:	8b 10                	mov    (%eax),%edx
  800319:	8d 4a 08             	lea    0x8(%edx),%ecx
  80031c:	89 08                	mov    %ecx,(%eax)
  80031e:	8b 02                	mov    (%edx),%eax
  800320:	8b 52 04             	mov    0x4(%edx),%edx
  800323:	eb 22                	jmp    800347 <getuint+0x38>
	else if (lflag)
  800325:	85 d2                	test   %edx,%edx
  800327:	74 10                	je     800339 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800329:	8b 10                	mov    (%eax),%edx
  80032b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032e:	89 08                	mov    %ecx,(%eax)
  800330:	8b 02                	mov    (%edx),%eax
  800332:	ba 00 00 00 00       	mov    $0x0,%edx
  800337:	eb 0e                	jmp    800347 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800339:	8b 10                	mov    (%eax),%edx
  80033b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80033e:	89 08                	mov    %ecx,(%eax)
  800340:	8b 02                	mov    (%edx),%eax
  800342:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800347:	5d                   	pop    %ebp
  800348:	c3                   	ret    

00800349 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800349:	55                   	push   %ebp
  80034a:	89 e5                	mov    %esp,%ebp
  80034c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80034f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800353:	8b 10                	mov    (%eax),%edx
  800355:	3b 50 04             	cmp    0x4(%eax),%edx
  800358:	73 0a                	jae    800364 <sprintputch+0x1b>
		*b->buf++ = ch;
  80035a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80035d:	89 08                	mov    %ecx,(%eax)
  80035f:	8b 45 08             	mov    0x8(%ebp),%eax
  800362:	88 02                	mov    %al,(%edx)
}
  800364:	5d                   	pop    %ebp
  800365:	c3                   	ret    

00800366 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
  800369:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80036c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80036f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800373:	8b 45 10             	mov    0x10(%ebp),%eax
  800376:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80037d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800381:	8b 45 08             	mov    0x8(%ebp),%eax
  800384:	89 04 24             	mov    %eax,(%esp)
  800387:	e8 02 00 00 00       	call   80038e <vprintfmt>
	va_end(ap);
}
  80038c:	c9                   	leave  
  80038d:	c3                   	ret    

0080038e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	57                   	push   %edi
  800392:	56                   	push   %esi
  800393:	53                   	push   %ebx
  800394:	83 ec 3c             	sub    $0x3c,%esp
  800397:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80039a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80039d:	eb 14                	jmp    8003b3 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80039f:	85 c0                	test   %eax,%eax
  8003a1:	0f 84 b3 03 00 00    	je     80075a <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  8003a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003ab:	89 04 24             	mov    %eax,(%esp)
  8003ae:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003b1:	89 f3                	mov    %esi,%ebx
  8003b3:	8d 73 01             	lea    0x1(%ebx),%esi
  8003b6:	0f b6 03             	movzbl (%ebx),%eax
  8003b9:	83 f8 25             	cmp    $0x25,%eax
  8003bc:	75 e1                	jne    80039f <vprintfmt+0x11>
  8003be:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003c2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003c9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003d0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8003d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003dc:	eb 1d                	jmp    8003fb <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003e0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003e4:	eb 15                	jmp    8003fb <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003ec:	eb 0d                	jmp    8003fb <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003ee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003f4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fb:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003fe:	0f b6 0e             	movzbl (%esi),%ecx
  800401:	0f b6 c1             	movzbl %cl,%eax
  800404:	83 e9 23             	sub    $0x23,%ecx
  800407:	80 f9 55             	cmp    $0x55,%cl
  80040a:	0f 87 2a 03 00 00    	ja     80073a <vprintfmt+0x3ac>
  800410:	0f b6 c9             	movzbl %cl,%ecx
  800413:	ff 24 8d 80 2b 80 00 	jmp    *0x802b80(,%ecx,4)
  80041a:	89 de                	mov    %ebx,%esi
  80041c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800421:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800424:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800428:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80042b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80042e:	83 fb 09             	cmp    $0x9,%ebx
  800431:	77 36                	ja     800469 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800433:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800436:	eb e9                	jmp    800421 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800438:	8b 45 14             	mov    0x14(%ebp),%eax
  80043b:	8d 48 04             	lea    0x4(%eax),%ecx
  80043e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800441:	8b 00                	mov    (%eax),%eax
  800443:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800446:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800448:	eb 22                	jmp    80046c <vprintfmt+0xde>
  80044a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80044d:	85 c9                	test   %ecx,%ecx
  80044f:	b8 00 00 00 00       	mov    $0x0,%eax
  800454:	0f 49 c1             	cmovns %ecx,%eax
  800457:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045a:	89 de                	mov    %ebx,%esi
  80045c:	eb 9d                	jmp    8003fb <vprintfmt+0x6d>
  80045e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800460:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800467:	eb 92                	jmp    8003fb <vprintfmt+0x6d>
  800469:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80046c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800470:	79 89                	jns    8003fb <vprintfmt+0x6d>
  800472:	e9 77 ff ff ff       	jmp    8003ee <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800477:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80047c:	e9 7a ff ff ff       	jmp    8003fb <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800481:	8b 45 14             	mov    0x14(%ebp),%eax
  800484:	8d 50 04             	lea    0x4(%eax),%edx
  800487:	89 55 14             	mov    %edx,0x14(%ebp)
  80048a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80048e:	8b 00                	mov    (%eax),%eax
  800490:	89 04 24             	mov    %eax,(%esp)
  800493:	ff 55 08             	call   *0x8(%ebp)
			break;
  800496:	e9 18 ff ff ff       	jmp    8003b3 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80049b:	8b 45 14             	mov    0x14(%ebp),%eax
  80049e:	8d 50 04             	lea    0x4(%eax),%edx
  8004a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a4:	8b 00                	mov    (%eax),%eax
  8004a6:	99                   	cltd   
  8004a7:	31 d0                	xor    %edx,%eax
  8004a9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ab:	83 f8 0f             	cmp    $0xf,%eax
  8004ae:	7f 0b                	jg     8004bb <vprintfmt+0x12d>
  8004b0:	8b 14 85 e0 2c 80 00 	mov    0x802ce0(,%eax,4),%edx
  8004b7:	85 d2                	test   %edx,%edx
  8004b9:	75 20                	jne    8004db <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  8004bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004bf:	c7 44 24 08 4b 2a 80 	movl   $0x802a4b,0x8(%esp)
  8004c6:	00 
  8004c7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ce:	89 04 24             	mov    %eax,(%esp)
  8004d1:	e8 90 fe ff ff       	call   800366 <printfmt>
  8004d6:	e9 d8 fe ff ff       	jmp    8003b3 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8004db:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004df:	c7 44 24 08 c9 2e 80 	movl   $0x802ec9,0x8(%esp)
  8004e6:	00 
  8004e7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ee:	89 04 24             	mov    %eax,(%esp)
  8004f1:	e8 70 fe ff ff       	call   800366 <printfmt>
  8004f6:	e9 b8 fe ff ff       	jmp    8003b3 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800501:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800504:	8b 45 14             	mov    0x14(%ebp),%eax
  800507:	8d 50 04             	lea    0x4(%eax),%edx
  80050a:	89 55 14             	mov    %edx,0x14(%ebp)
  80050d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80050f:	85 f6                	test   %esi,%esi
  800511:	b8 44 2a 80 00       	mov    $0x802a44,%eax
  800516:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800519:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80051d:	0f 84 97 00 00 00    	je     8005ba <vprintfmt+0x22c>
  800523:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800527:	0f 8e 9b 00 00 00    	jle    8005c8 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80052d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800531:	89 34 24             	mov    %esi,(%esp)
  800534:	e8 cf 02 00 00       	call   800808 <strnlen>
  800539:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80053c:	29 c2                	sub    %eax,%edx
  80053e:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800541:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800545:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800548:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80054b:	8b 75 08             	mov    0x8(%ebp),%esi
  80054e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800551:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800553:	eb 0f                	jmp    800564 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800555:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800559:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80055c:	89 04 24             	mov    %eax,(%esp)
  80055f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800561:	83 eb 01             	sub    $0x1,%ebx
  800564:	85 db                	test   %ebx,%ebx
  800566:	7f ed                	jg     800555 <vprintfmt+0x1c7>
  800568:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80056b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80056e:	85 d2                	test   %edx,%edx
  800570:	b8 00 00 00 00       	mov    $0x0,%eax
  800575:	0f 49 c2             	cmovns %edx,%eax
  800578:	29 c2                	sub    %eax,%edx
  80057a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80057d:	89 d7                	mov    %edx,%edi
  80057f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800582:	eb 50                	jmp    8005d4 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800584:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800588:	74 1e                	je     8005a8 <vprintfmt+0x21a>
  80058a:	0f be d2             	movsbl %dl,%edx
  80058d:	83 ea 20             	sub    $0x20,%edx
  800590:	83 fa 5e             	cmp    $0x5e,%edx
  800593:	76 13                	jbe    8005a8 <vprintfmt+0x21a>
					putch('?', putdat);
  800595:	8b 45 0c             	mov    0xc(%ebp),%eax
  800598:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005a3:	ff 55 08             	call   *0x8(%ebp)
  8005a6:	eb 0d                	jmp    8005b5 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8005a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005ab:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005af:	89 04 24             	mov    %eax,(%esp)
  8005b2:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b5:	83 ef 01             	sub    $0x1,%edi
  8005b8:	eb 1a                	jmp    8005d4 <vprintfmt+0x246>
  8005ba:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005bd:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005c0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005c3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005c6:	eb 0c                	jmp    8005d4 <vprintfmt+0x246>
  8005c8:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005cb:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005ce:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005d1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005d4:	83 c6 01             	add    $0x1,%esi
  8005d7:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  8005db:	0f be c2             	movsbl %dl,%eax
  8005de:	85 c0                	test   %eax,%eax
  8005e0:	74 27                	je     800609 <vprintfmt+0x27b>
  8005e2:	85 db                	test   %ebx,%ebx
  8005e4:	78 9e                	js     800584 <vprintfmt+0x1f6>
  8005e6:	83 eb 01             	sub    $0x1,%ebx
  8005e9:	79 99                	jns    800584 <vprintfmt+0x1f6>
  8005eb:	89 f8                	mov    %edi,%eax
  8005ed:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005f3:	89 c3                	mov    %eax,%ebx
  8005f5:	eb 1a                	jmp    800611 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005f7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005fb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800602:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800604:	83 eb 01             	sub    $0x1,%ebx
  800607:	eb 08                	jmp    800611 <vprintfmt+0x283>
  800609:	89 fb                	mov    %edi,%ebx
  80060b:	8b 75 08             	mov    0x8(%ebp),%esi
  80060e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800611:	85 db                	test   %ebx,%ebx
  800613:	7f e2                	jg     8005f7 <vprintfmt+0x269>
  800615:	89 75 08             	mov    %esi,0x8(%ebp)
  800618:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80061b:	e9 93 fd ff ff       	jmp    8003b3 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800620:	83 fa 01             	cmp    $0x1,%edx
  800623:	7e 16                	jle    80063b <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8d 50 08             	lea    0x8(%eax),%edx
  80062b:	89 55 14             	mov    %edx,0x14(%ebp)
  80062e:	8b 50 04             	mov    0x4(%eax),%edx
  800631:	8b 00                	mov    (%eax),%eax
  800633:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800636:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800639:	eb 32                	jmp    80066d <vprintfmt+0x2df>
	else if (lflag)
  80063b:	85 d2                	test   %edx,%edx
  80063d:	74 18                	je     800657 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8d 50 04             	lea    0x4(%eax),%edx
  800645:	89 55 14             	mov    %edx,0x14(%ebp)
  800648:	8b 30                	mov    (%eax),%esi
  80064a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80064d:	89 f0                	mov    %esi,%eax
  80064f:	c1 f8 1f             	sar    $0x1f,%eax
  800652:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800655:	eb 16                	jmp    80066d <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8d 50 04             	lea    0x4(%eax),%edx
  80065d:	89 55 14             	mov    %edx,0x14(%ebp)
  800660:	8b 30                	mov    (%eax),%esi
  800662:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800665:	89 f0                	mov    %esi,%eax
  800667:	c1 f8 1f             	sar    $0x1f,%eax
  80066a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80066d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800670:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800673:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800678:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80067c:	0f 89 80 00 00 00    	jns    800702 <vprintfmt+0x374>
				putch('-', putdat);
  800682:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800686:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80068d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800690:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800693:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800696:	f7 d8                	neg    %eax
  800698:	83 d2 00             	adc    $0x0,%edx
  80069b:	f7 da                	neg    %edx
			}
			base = 10;
  80069d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006a2:	eb 5e                	jmp    800702 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006a4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a7:	e8 63 fc ff ff       	call   80030f <getuint>
			base = 10;
  8006ac:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006b1:	eb 4f                	jmp    800702 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8006b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b6:	e8 54 fc ff ff       	call   80030f <getuint>
			base = 8;
  8006bb:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006c0:	eb 40                	jmp    800702 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  8006c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006c6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006cd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006d0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006d4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006db:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006de:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e1:	8d 50 04             	lea    0x4(%eax),%edx
  8006e4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006e7:	8b 00                	mov    (%eax),%eax
  8006e9:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ee:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006f3:	eb 0d                	jmp    800702 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006f5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f8:	e8 12 fc ff ff       	call   80030f <getuint>
			base = 16;
  8006fd:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800702:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800706:	89 74 24 10          	mov    %esi,0x10(%esp)
  80070a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80070d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800711:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800715:	89 04 24             	mov    %eax,(%esp)
  800718:	89 54 24 04          	mov    %edx,0x4(%esp)
  80071c:	89 fa                	mov    %edi,%edx
  80071e:	8b 45 08             	mov    0x8(%ebp),%eax
  800721:	e8 fa fa ff ff       	call   800220 <printnum>
			break;
  800726:	e9 88 fc ff ff       	jmp    8003b3 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80072b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80072f:	89 04 24             	mov    %eax,(%esp)
  800732:	ff 55 08             	call   *0x8(%ebp)
			break;
  800735:	e9 79 fc ff ff       	jmp    8003b3 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80073a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80073e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800745:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800748:	89 f3                	mov    %esi,%ebx
  80074a:	eb 03                	jmp    80074f <vprintfmt+0x3c1>
  80074c:	83 eb 01             	sub    $0x1,%ebx
  80074f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800753:	75 f7                	jne    80074c <vprintfmt+0x3be>
  800755:	e9 59 fc ff ff       	jmp    8003b3 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  80075a:	83 c4 3c             	add    $0x3c,%esp
  80075d:	5b                   	pop    %ebx
  80075e:	5e                   	pop    %esi
  80075f:	5f                   	pop    %edi
  800760:	5d                   	pop    %ebp
  800761:	c3                   	ret    

00800762 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800762:	55                   	push   %ebp
  800763:	89 e5                	mov    %esp,%ebp
  800765:	83 ec 28             	sub    $0x28,%esp
  800768:	8b 45 08             	mov    0x8(%ebp),%eax
  80076b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80076e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800771:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800775:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800778:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80077f:	85 c0                	test   %eax,%eax
  800781:	74 30                	je     8007b3 <vsnprintf+0x51>
  800783:	85 d2                	test   %edx,%edx
  800785:	7e 2c                	jle    8007b3 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800787:	8b 45 14             	mov    0x14(%ebp),%eax
  80078a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80078e:	8b 45 10             	mov    0x10(%ebp),%eax
  800791:	89 44 24 08          	mov    %eax,0x8(%esp)
  800795:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800798:	89 44 24 04          	mov    %eax,0x4(%esp)
  80079c:	c7 04 24 49 03 80 00 	movl   $0x800349,(%esp)
  8007a3:	e8 e6 fb ff ff       	call   80038e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ab:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b1:	eb 05                	jmp    8007b8 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007b8:	c9                   	leave  
  8007b9:	c3                   	ret    

008007ba <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d8:	89 04 24             	mov    %eax,(%esp)
  8007db:	e8 82 ff ff ff       	call   800762 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e0:	c9                   	leave  
  8007e1:	c3                   	ret    
  8007e2:	66 90                	xchg   %ax,%ax
  8007e4:	66 90                	xchg   %ax,%ax
  8007e6:	66 90                	xchg   %ax,%ax
  8007e8:	66 90                	xchg   %ax,%ax
  8007ea:	66 90                	xchg   %ax,%ax
  8007ec:	66 90                	xchg   %ax,%ax
  8007ee:	66 90                	xchg   %ax,%ax

008007f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fb:	eb 03                	jmp    800800 <strlen+0x10>
		n++;
  8007fd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800800:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800804:	75 f7                	jne    8007fd <strlen+0xd>
		n++;
	return n;
}
  800806:	5d                   	pop    %ebp
  800807:	c3                   	ret    

00800808 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800811:	b8 00 00 00 00       	mov    $0x0,%eax
  800816:	eb 03                	jmp    80081b <strnlen+0x13>
		n++;
  800818:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081b:	39 d0                	cmp    %edx,%eax
  80081d:	74 06                	je     800825 <strnlen+0x1d>
  80081f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800823:	75 f3                	jne    800818 <strnlen+0x10>
		n++;
	return n;
}
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	53                   	push   %ebx
  80082b:	8b 45 08             	mov    0x8(%ebp),%eax
  80082e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800831:	89 c2                	mov    %eax,%edx
  800833:	83 c2 01             	add    $0x1,%edx
  800836:	83 c1 01             	add    $0x1,%ecx
  800839:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80083d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800840:	84 db                	test   %bl,%bl
  800842:	75 ef                	jne    800833 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800844:	5b                   	pop    %ebx
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	53                   	push   %ebx
  80084b:	83 ec 08             	sub    $0x8,%esp
  80084e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800851:	89 1c 24             	mov    %ebx,(%esp)
  800854:	e8 97 ff ff ff       	call   8007f0 <strlen>
	strcpy(dst + len, src);
  800859:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800860:	01 d8                	add    %ebx,%eax
  800862:	89 04 24             	mov    %eax,(%esp)
  800865:	e8 bd ff ff ff       	call   800827 <strcpy>
	return dst;
}
  80086a:	89 d8                	mov    %ebx,%eax
  80086c:	83 c4 08             	add    $0x8,%esp
  80086f:	5b                   	pop    %ebx
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	56                   	push   %esi
  800876:	53                   	push   %ebx
  800877:	8b 75 08             	mov    0x8(%ebp),%esi
  80087a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087d:	89 f3                	mov    %esi,%ebx
  80087f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800882:	89 f2                	mov    %esi,%edx
  800884:	eb 0f                	jmp    800895 <strncpy+0x23>
		*dst++ = *src;
  800886:	83 c2 01             	add    $0x1,%edx
  800889:	0f b6 01             	movzbl (%ecx),%eax
  80088c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80088f:	80 39 01             	cmpb   $0x1,(%ecx)
  800892:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800895:	39 da                	cmp    %ebx,%edx
  800897:	75 ed                	jne    800886 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800899:	89 f0                	mov    %esi,%eax
  80089b:	5b                   	pop    %ebx
  80089c:	5e                   	pop    %esi
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	56                   	push   %esi
  8008a3:	53                   	push   %ebx
  8008a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008ad:	89 f0                	mov    %esi,%eax
  8008af:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b3:	85 c9                	test   %ecx,%ecx
  8008b5:	75 0b                	jne    8008c2 <strlcpy+0x23>
  8008b7:	eb 1d                	jmp    8008d6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008b9:	83 c0 01             	add    $0x1,%eax
  8008bc:	83 c2 01             	add    $0x1,%edx
  8008bf:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008c2:	39 d8                	cmp    %ebx,%eax
  8008c4:	74 0b                	je     8008d1 <strlcpy+0x32>
  8008c6:	0f b6 0a             	movzbl (%edx),%ecx
  8008c9:	84 c9                	test   %cl,%cl
  8008cb:	75 ec                	jne    8008b9 <strlcpy+0x1a>
  8008cd:	89 c2                	mov    %eax,%edx
  8008cf:	eb 02                	jmp    8008d3 <strlcpy+0x34>
  8008d1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008d3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008d6:	29 f0                	sub    %esi,%eax
}
  8008d8:	5b                   	pop    %ebx
  8008d9:	5e                   	pop    %esi
  8008da:	5d                   	pop    %ebp
  8008db:	c3                   	ret    

008008dc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e5:	eb 06                	jmp    8008ed <strcmp+0x11>
		p++, q++;
  8008e7:	83 c1 01             	add    $0x1,%ecx
  8008ea:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ed:	0f b6 01             	movzbl (%ecx),%eax
  8008f0:	84 c0                	test   %al,%al
  8008f2:	74 04                	je     8008f8 <strcmp+0x1c>
  8008f4:	3a 02                	cmp    (%edx),%al
  8008f6:	74 ef                	je     8008e7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f8:	0f b6 c0             	movzbl %al,%eax
  8008fb:	0f b6 12             	movzbl (%edx),%edx
  8008fe:	29 d0                	sub    %edx,%eax
}
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	53                   	push   %ebx
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090c:	89 c3                	mov    %eax,%ebx
  80090e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800911:	eb 06                	jmp    800919 <strncmp+0x17>
		n--, p++, q++;
  800913:	83 c0 01             	add    $0x1,%eax
  800916:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800919:	39 d8                	cmp    %ebx,%eax
  80091b:	74 15                	je     800932 <strncmp+0x30>
  80091d:	0f b6 08             	movzbl (%eax),%ecx
  800920:	84 c9                	test   %cl,%cl
  800922:	74 04                	je     800928 <strncmp+0x26>
  800924:	3a 0a                	cmp    (%edx),%cl
  800926:	74 eb                	je     800913 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800928:	0f b6 00             	movzbl (%eax),%eax
  80092b:	0f b6 12             	movzbl (%edx),%edx
  80092e:	29 d0                	sub    %edx,%eax
  800930:	eb 05                	jmp    800937 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800932:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800937:	5b                   	pop    %ebx
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800944:	eb 07                	jmp    80094d <strchr+0x13>
		if (*s == c)
  800946:	38 ca                	cmp    %cl,%dl
  800948:	74 0f                	je     800959 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80094a:	83 c0 01             	add    $0x1,%eax
  80094d:	0f b6 10             	movzbl (%eax),%edx
  800950:	84 d2                	test   %dl,%dl
  800952:	75 f2                	jne    800946 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800954:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800965:	eb 07                	jmp    80096e <strfind+0x13>
		if (*s == c)
  800967:	38 ca                	cmp    %cl,%dl
  800969:	74 0a                	je     800975 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80096b:	83 c0 01             	add    $0x1,%eax
  80096e:	0f b6 10             	movzbl (%eax),%edx
  800971:	84 d2                	test   %dl,%dl
  800973:	75 f2                	jne    800967 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	57                   	push   %edi
  80097b:	56                   	push   %esi
  80097c:	53                   	push   %ebx
  80097d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800980:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800983:	85 c9                	test   %ecx,%ecx
  800985:	74 36                	je     8009bd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800987:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80098d:	75 28                	jne    8009b7 <memset+0x40>
  80098f:	f6 c1 03             	test   $0x3,%cl
  800992:	75 23                	jne    8009b7 <memset+0x40>
		c &= 0xFF;
  800994:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800998:	89 d3                	mov    %edx,%ebx
  80099a:	c1 e3 08             	shl    $0x8,%ebx
  80099d:	89 d6                	mov    %edx,%esi
  80099f:	c1 e6 18             	shl    $0x18,%esi
  8009a2:	89 d0                	mov    %edx,%eax
  8009a4:	c1 e0 10             	shl    $0x10,%eax
  8009a7:	09 f0                	or     %esi,%eax
  8009a9:	09 c2                	or     %eax,%edx
  8009ab:	89 d0                	mov    %edx,%eax
  8009ad:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009af:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009b2:	fc                   	cld    
  8009b3:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b5:	eb 06                	jmp    8009bd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ba:	fc                   	cld    
  8009bb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009bd:	89 f8                	mov    %edi,%eax
  8009bf:	5b                   	pop    %ebx
  8009c0:	5e                   	pop    %esi
  8009c1:	5f                   	pop    %edi
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    

008009c4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	57                   	push   %edi
  8009c8:	56                   	push   %esi
  8009c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d2:	39 c6                	cmp    %eax,%esi
  8009d4:	73 35                	jae    800a0b <memmove+0x47>
  8009d6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009d9:	39 d0                	cmp    %edx,%eax
  8009db:	73 2e                	jae    800a0b <memmove+0x47>
		s += n;
		d += n;
  8009dd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009e0:	89 d6                	mov    %edx,%esi
  8009e2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ea:	75 13                	jne    8009ff <memmove+0x3b>
  8009ec:	f6 c1 03             	test   $0x3,%cl
  8009ef:	75 0e                	jne    8009ff <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009f1:	83 ef 04             	sub    $0x4,%edi
  8009f4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009f7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009fa:	fd                   	std    
  8009fb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009fd:	eb 09                	jmp    800a08 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ff:	83 ef 01             	sub    $0x1,%edi
  800a02:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a05:	fd                   	std    
  800a06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a08:	fc                   	cld    
  800a09:	eb 1d                	jmp    800a28 <memmove+0x64>
  800a0b:	89 f2                	mov    %esi,%edx
  800a0d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0f:	f6 c2 03             	test   $0x3,%dl
  800a12:	75 0f                	jne    800a23 <memmove+0x5f>
  800a14:	f6 c1 03             	test   $0x3,%cl
  800a17:	75 0a                	jne    800a23 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a19:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a1c:	89 c7                	mov    %eax,%edi
  800a1e:	fc                   	cld    
  800a1f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a21:	eb 05                	jmp    800a28 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a23:	89 c7                	mov    %eax,%edi
  800a25:	fc                   	cld    
  800a26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a28:	5e                   	pop    %esi
  800a29:	5f                   	pop    %edi
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a32:	8b 45 10             	mov    0x10(%ebp),%eax
  800a35:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a40:	8b 45 08             	mov    0x8(%ebp),%eax
  800a43:	89 04 24             	mov    %eax,(%esp)
  800a46:	e8 79 ff ff ff       	call   8009c4 <memmove>
}
  800a4b:	c9                   	leave  
  800a4c:	c3                   	ret    

00800a4d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	56                   	push   %esi
  800a51:	53                   	push   %ebx
  800a52:	8b 55 08             	mov    0x8(%ebp),%edx
  800a55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a58:	89 d6                	mov    %edx,%esi
  800a5a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a5d:	eb 1a                	jmp    800a79 <memcmp+0x2c>
		if (*s1 != *s2)
  800a5f:	0f b6 02             	movzbl (%edx),%eax
  800a62:	0f b6 19             	movzbl (%ecx),%ebx
  800a65:	38 d8                	cmp    %bl,%al
  800a67:	74 0a                	je     800a73 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a69:	0f b6 c0             	movzbl %al,%eax
  800a6c:	0f b6 db             	movzbl %bl,%ebx
  800a6f:	29 d8                	sub    %ebx,%eax
  800a71:	eb 0f                	jmp    800a82 <memcmp+0x35>
		s1++, s2++;
  800a73:	83 c2 01             	add    $0x1,%edx
  800a76:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a79:	39 f2                	cmp    %esi,%edx
  800a7b:	75 e2                	jne    800a5f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a82:	5b                   	pop    %ebx
  800a83:	5e                   	pop    %esi
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a8f:	89 c2                	mov    %eax,%edx
  800a91:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a94:	eb 07                	jmp    800a9d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a96:	38 08                	cmp    %cl,(%eax)
  800a98:	74 07                	je     800aa1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a9a:	83 c0 01             	add    $0x1,%eax
  800a9d:	39 d0                	cmp    %edx,%eax
  800a9f:	72 f5                	jb     800a96 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	57                   	push   %edi
  800aa7:	56                   	push   %esi
  800aa8:	53                   	push   %ebx
  800aa9:	8b 55 08             	mov    0x8(%ebp),%edx
  800aac:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aaf:	eb 03                	jmp    800ab4 <strtol+0x11>
		s++;
  800ab1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab4:	0f b6 0a             	movzbl (%edx),%ecx
  800ab7:	80 f9 09             	cmp    $0x9,%cl
  800aba:	74 f5                	je     800ab1 <strtol+0xe>
  800abc:	80 f9 20             	cmp    $0x20,%cl
  800abf:	74 f0                	je     800ab1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ac1:	80 f9 2b             	cmp    $0x2b,%cl
  800ac4:	75 0a                	jne    800ad0 <strtol+0x2d>
		s++;
  800ac6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac9:	bf 00 00 00 00       	mov    $0x0,%edi
  800ace:	eb 11                	jmp    800ae1 <strtol+0x3e>
  800ad0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ad5:	80 f9 2d             	cmp    $0x2d,%cl
  800ad8:	75 07                	jne    800ae1 <strtol+0x3e>
		s++, neg = 1;
  800ada:	8d 52 01             	lea    0x1(%edx),%edx
  800add:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ae1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800ae6:	75 15                	jne    800afd <strtol+0x5a>
  800ae8:	80 3a 30             	cmpb   $0x30,(%edx)
  800aeb:	75 10                	jne    800afd <strtol+0x5a>
  800aed:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800af1:	75 0a                	jne    800afd <strtol+0x5a>
		s += 2, base = 16;
  800af3:	83 c2 02             	add    $0x2,%edx
  800af6:	b8 10 00 00 00       	mov    $0x10,%eax
  800afb:	eb 10                	jmp    800b0d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800afd:	85 c0                	test   %eax,%eax
  800aff:	75 0c                	jne    800b0d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b01:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b03:	80 3a 30             	cmpb   $0x30,(%edx)
  800b06:	75 05                	jne    800b0d <strtol+0x6a>
		s++, base = 8;
  800b08:	83 c2 01             	add    $0x1,%edx
  800b0b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800b0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b12:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b15:	0f b6 0a             	movzbl (%edx),%ecx
  800b18:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b1b:	89 f0                	mov    %esi,%eax
  800b1d:	3c 09                	cmp    $0x9,%al
  800b1f:	77 08                	ja     800b29 <strtol+0x86>
			dig = *s - '0';
  800b21:	0f be c9             	movsbl %cl,%ecx
  800b24:	83 e9 30             	sub    $0x30,%ecx
  800b27:	eb 20                	jmp    800b49 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b29:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b2c:	89 f0                	mov    %esi,%eax
  800b2e:	3c 19                	cmp    $0x19,%al
  800b30:	77 08                	ja     800b3a <strtol+0x97>
			dig = *s - 'a' + 10;
  800b32:	0f be c9             	movsbl %cl,%ecx
  800b35:	83 e9 57             	sub    $0x57,%ecx
  800b38:	eb 0f                	jmp    800b49 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800b3a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b3d:	89 f0                	mov    %esi,%eax
  800b3f:	3c 19                	cmp    $0x19,%al
  800b41:	77 16                	ja     800b59 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800b43:	0f be c9             	movsbl %cl,%ecx
  800b46:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b49:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b4c:	7d 0f                	jge    800b5d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800b4e:	83 c2 01             	add    $0x1,%edx
  800b51:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800b55:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800b57:	eb bc                	jmp    800b15 <strtol+0x72>
  800b59:	89 d8                	mov    %ebx,%eax
  800b5b:	eb 02                	jmp    800b5f <strtol+0xbc>
  800b5d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800b5f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b63:	74 05                	je     800b6a <strtol+0xc7>
		*endptr = (char *) s;
  800b65:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b68:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b6a:	f7 d8                	neg    %eax
  800b6c:	85 ff                	test   %edi,%edi
  800b6e:	0f 44 c3             	cmove  %ebx,%eax
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	89 c3                	mov    %eax,%ebx
  800b89:	89 c7                	mov    %eax,%edi
  800b8b:	89 c6                	mov    %eax,%esi
  800b8d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b8f:	5b                   	pop    %ebx
  800b90:	5e                   	pop    %esi
  800b91:	5f                   	pop    %edi
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9f:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba4:	89 d1                	mov    %edx,%ecx
  800ba6:	89 d3                	mov    %edx,%ebx
  800ba8:	89 d7                	mov    %edx,%edi
  800baa:	89 d6                	mov    %edx,%esi
  800bac:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	57                   	push   %edi
  800bb7:	56                   	push   %esi
  800bb8:	53                   	push   %ebx
  800bb9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc1:	b8 03 00 00 00       	mov    $0x3,%eax
  800bc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc9:	89 cb                	mov    %ecx,%ebx
  800bcb:	89 cf                	mov    %ecx,%edi
  800bcd:	89 ce                	mov    %ecx,%esi
  800bcf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd1:	85 c0                	test   %eax,%eax
  800bd3:	7e 28                	jle    800bfd <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bd9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800be0:	00 
  800be1:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  800be8:	00 
  800be9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bf0:	00 
  800bf1:	c7 04 24 5c 2d 80 00 	movl   $0x802d5c,(%esp)
  800bf8:	e8 59 1a 00 00       	call   802656 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bfd:	83 c4 2c             	add    $0x2c,%esp
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c10:	b8 02 00 00 00       	mov    $0x2,%eax
  800c15:	89 d1                	mov    %edx,%ecx
  800c17:	89 d3                	mov    %edx,%ebx
  800c19:	89 d7                	mov    %edx,%edi
  800c1b:	89 d6                	mov    %edx,%esi
  800c1d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c1f:	5b                   	pop    %ebx
  800c20:	5e                   	pop    %esi
  800c21:	5f                   	pop    %edi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <sys_yield>:

void
sys_yield(void)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	57                   	push   %edi
  800c28:	56                   	push   %esi
  800c29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c34:	89 d1                	mov    %edx,%ecx
  800c36:	89 d3                	mov    %edx,%ebx
  800c38:	89 d7                	mov    %edx,%edi
  800c3a:	89 d6                	mov    %edx,%esi
  800c3c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4c:	be 00 00 00 00       	mov    $0x0,%esi
  800c51:	b8 04 00 00 00       	mov    $0x4,%eax
  800c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5f:	89 f7                	mov    %esi,%edi
  800c61:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c63:	85 c0                	test   %eax,%eax
  800c65:	7e 28                	jle    800c8f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c67:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c6b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c72:	00 
  800c73:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  800c7a:	00 
  800c7b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c82:	00 
  800c83:	c7 04 24 5c 2d 80 00 	movl   $0x802d5c,(%esp)
  800c8a:	e8 c7 19 00 00       	call   802656 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c8f:	83 c4 2c             	add    $0x2c,%esp
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ca5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cae:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb1:	8b 75 18             	mov    0x18(%ebp),%esi
  800cb4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb6:	85 c0                	test   %eax,%eax
  800cb8:	7e 28                	jle    800ce2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cba:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cbe:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cc5:	00 
  800cc6:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  800ccd:	00 
  800cce:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd5:	00 
  800cd6:	c7 04 24 5c 2d 80 00 	movl   $0x802d5c,(%esp)
  800cdd:	e8 74 19 00 00       	call   802656 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ce2:	83 c4 2c             	add    $0x2c,%esp
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
  800cf0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf8:	b8 06 00 00 00       	mov    $0x6,%eax
  800cfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d00:	8b 55 08             	mov    0x8(%ebp),%edx
  800d03:	89 df                	mov    %ebx,%edi
  800d05:	89 de                	mov    %ebx,%esi
  800d07:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	7e 28                	jle    800d35 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d11:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d18:	00 
  800d19:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  800d20:	00 
  800d21:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d28:	00 
  800d29:	c7 04 24 5c 2d 80 00 	movl   $0x802d5c,(%esp)
  800d30:	e8 21 19 00 00       	call   802656 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d35:	83 c4 2c             	add    $0x2c,%esp
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	57                   	push   %edi
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
  800d43:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d53:	8b 55 08             	mov    0x8(%ebp),%edx
  800d56:	89 df                	mov    %ebx,%edi
  800d58:	89 de                	mov    %ebx,%esi
  800d5a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5c:	85 c0                	test   %eax,%eax
  800d5e:	7e 28                	jle    800d88 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d60:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d64:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d6b:	00 
  800d6c:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  800d73:	00 
  800d74:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d7b:	00 
  800d7c:	c7 04 24 5c 2d 80 00 	movl   $0x802d5c,(%esp)
  800d83:	e8 ce 18 00 00       	call   802656 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d88:	83 c4 2c             	add    $0x2c,%esp
  800d8b:	5b                   	pop    %ebx
  800d8c:	5e                   	pop    %esi
  800d8d:	5f                   	pop    %edi
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	57                   	push   %edi
  800d94:	56                   	push   %esi
  800d95:	53                   	push   %ebx
  800d96:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d99:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9e:	b8 09 00 00 00       	mov    $0x9,%eax
  800da3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da6:	8b 55 08             	mov    0x8(%ebp),%edx
  800da9:	89 df                	mov    %ebx,%edi
  800dab:	89 de                	mov    %ebx,%esi
  800dad:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800daf:	85 c0                	test   %eax,%eax
  800db1:	7e 28                	jle    800ddb <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dbe:	00 
  800dbf:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  800dc6:	00 
  800dc7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dce:	00 
  800dcf:	c7 04 24 5c 2d 80 00 	movl   $0x802d5c,(%esp)
  800dd6:	e8 7b 18 00 00       	call   802656 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ddb:	83 c4 2c             	add    $0x2c,%esp
  800dde:	5b                   	pop    %ebx
  800ddf:	5e                   	pop    %esi
  800de0:	5f                   	pop    %edi
  800de1:	5d                   	pop    %ebp
  800de2:	c3                   	ret    

00800de3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de3:	55                   	push   %ebp
  800de4:	89 e5                	mov    %esp,%ebp
  800de6:	57                   	push   %edi
  800de7:	56                   	push   %esi
  800de8:	53                   	push   %ebx
  800de9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dec:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800df6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfc:	89 df                	mov    %ebx,%edi
  800dfe:	89 de                	mov    %ebx,%esi
  800e00:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e02:	85 c0                	test   %eax,%eax
  800e04:	7e 28                	jle    800e2e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e06:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e0a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e11:	00 
  800e12:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  800e19:	00 
  800e1a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e21:	00 
  800e22:	c7 04 24 5c 2d 80 00 	movl   $0x802d5c,(%esp)
  800e29:	e8 28 18 00 00       	call   802656 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e2e:	83 c4 2c             	add    $0x2c,%esp
  800e31:	5b                   	pop    %ebx
  800e32:	5e                   	pop    %esi
  800e33:	5f                   	pop    %edi
  800e34:	5d                   	pop    %ebp
  800e35:	c3                   	ret    

00800e36 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e36:	55                   	push   %ebp
  800e37:	89 e5                	mov    %esp,%ebp
  800e39:	57                   	push   %edi
  800e3a:	56                   	push   %esi
  800e3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3c:	be 00 00 00 00       	mov    $0x0,%esi
  800e41:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e49:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e4f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e52:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e54:	5b                   	pop    %ebx
  800e55:	5e                   	pop    %esi
  800e56:	5f                   	pop    %edi
  800e57:	5d                   	pop    %ebp
  800e58:	c3                   	ret    

00800e59 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e59:	55                   	push   %ebp
  800e5a:	89 e5                	mov    %esp,%ebp
  800e5c:	57                   	push   %edi
  800e5d:	56                   	push   %esi
  800e5e:	53                   	push   %ebx
  800e5f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e62:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e67:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6f:	89 cb                	mov    %ecx,%ebx
  800e71:	89 cf                	mov    %ecx,%edi
  800e73:	89 ce                	mov    %ecx,%esi
  800e75:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e77:	85 c0                	test   %eax,%eax
  800e79:	7e 28                	jle    800ea3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e86:	00 
  800e87:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  800e8e:	00 
  800e8f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e96:	00 
  800e97:	c7 04 24 5c 2d 80 00 	movl   $0x802d5c,(%esp)
  800e9e:	e8 b3 17 00 00       	call   802656 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ea3:	83 c4 2c             	add    $0x2c,%esp
  800ea6:	5b                   	pop    %ebx
  800ea7:	5e                   	pop    %esi
  800ea8:	5f                   	pop    %edi
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	57                   	push   %edi
  800eaf:	56                   	push   %esi
  800eb0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb1:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb6:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ebb:	89 d1                	mov    %edx,%ecx
  800ebd:	89 d3                	mov    %edx,%ebx
  800ebf:	89 d7                	mov    %edx,%edi
  800ec1:	89 d6                	mov    %edx,%esi
  800ec3:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ec5:	5b                   	pop    %ebx
  800ec6:	5e                   	pop    %esi
  800ec7:	5f                   	pop    %edi
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    

00800eca <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	57                   	push   %edi
  800ece:	56                   	push   %esi
  800ecf:	53                   	push   %ebx
  800ed0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed8:	b8 0f 00 00 00       	mov    $0xf,%eax
  800edd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee3:	89 df                	mov    %ebx,%edi
  800ee5:	89 de                	mov    %ebx,%esi
  800ee7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee9:	85 c0                	test   %eax,%eax
  800eeb:	7e 28                	jle    800f15 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eed:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ef1:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800ef8:	00 
  800ef9:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  800f00:	00 
  800f01:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f08:	00 
  800f09:	c7 04 24 5c 2d 80 00 	movl   $0x802d5c,(%esp)
  800f10:	e8 41 17 00 00       	call   802656 <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  800f15:	83 c4 2c             	add    $0x2c,%esp
  800f18:	5b                   	pop    %ebx
  800f19:	5e                   	pop    %esi
  800f1a:	5f                   	pop    %edi
  800f1b:	5d                   	pop    %ebp
  800f1c:	c3                   	ret    

00800f1d <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  800f1d:	55                   	push   %ebp
  800f1e:	89 e5                	mov    %esp,%ebp
  800f20:	57                   	push   %edi
  800f21:	56                   	push   %esi
  800f22:	53                   	push   %ebx
  800f23:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f26:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f2b:	b8 10 00 00 00       	mov    $0x10,%eax
  800f30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f33:	8b 55 08             	mov    0x8(%ebp),%edx
  800f36:	89 df                	mov    %ebx,%edi
  800f38:	89 de                	mov    %ebx,%esi
  800f3a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f3c:	85 c0                	test   %eax,%eax
  800f3e:	7e 28                	jle    800f68 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f40:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f44:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  800f4b:	00 
  800f4c:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  800f53:	00 
  800f54:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f5b:	00 
  800f5c:	c7 04 24 5c 2d 80 00 	movl   $0x802d5c,(%esp)
  800f63:	e8 ee 16 00 00       	call   802656 <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  800f68:	83 c4 2c             	add    $0x2c,%esp
  800f6b:	5b                   	pop    %ebx
  800f6c:	5e                   	pop    %esi
  800f6d:	5f                   	pop    %edi
  800f6e:	5d                   	pop    %ebp
  800f6f:	c3                   	ret    

00800f70 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	56                   	push   %esi
  800f74:	53                   	push   %ebx
  800f75:	83 ec 20             	sub    $0x20,%esp
  800f78:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f7b:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if(!(err & FEC_WR)) {
  800f7d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f81:	75 20                	jne    800fa3 <pgfault+0x33>
		panic("0x%x Not a write", addr);
  800f83:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800f87:	c7 44 24 08 6a 2d 80 	movl   $0x802d6a,0x8(%esp)
  800f8e:	00 
  800f8f:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800f96:	00 
  800f97:	c7 04 24 7b 2d 80 00 	movl   $0x802d7b,(%esp)
  800f9e:	e8 b3 16 00 00       	call   802656 <_panic>
	}

	if(!(uvpt[PGNUM(addr)] & PTE_COW)) {
  800fa3:	89 f0                	mov    %esi,%eax
  800fa5:	c1 e8 0c             	shr    $0xc,%eax
  800fa8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800faf:	f6 c4 08             	test   $0x8,%ah
  800fb2:	75 1c                	jne    800fd0 <pgfault+0x60>
		panic("Not a COW page");
  800fb4:	c7 44 24 08 86 2d 80 	movl   $0x802d86,0x8(%esp)
  800fbb:	00 
  800fbc:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800fc3:	00 
  800fc4:	c7 04 24 7b 2d 80 00 	movl   $0x802d7b,(%esp)
  800fcb:	e8 86 16 00 00       	call   802656 <_panic>

	// Allocate a new page, map it at a temporary location (PFTEMP), // copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	envid_t envid = sys_getenvid();
  800fd0:	e8 30 fc ff ff       	call   800c05 <sys_getenvid>
  800fd5:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, PFTEMP, PTE_W | PTE_U | PTE_P);
  800fd7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fde:	00 
  800fdf:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fe6:	00 
  800fe7:	89 04 24             	mov    %eax,(%esp)
  800fea:	e8 54 fc ff ff       	call   800c43 <sys_page_alloc>
	if(r < 0) {
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	79 1c                	jns    80100f <pgfault+0x9f>
		panic("couldn't allocate page");
  800ff3:	c7 44 24 08 95 2d 80 	movl   $0x802d95,0x8(%esp)
  800ffa:	00 
  800ffb:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801002:	00 
  801003:	c7 04 24 7b 2d 80 00 	movl   $0x802d7b,(%esp)
  80100a:	e8 47 16 00 00       	call   802656 <_panic>
	}

	memmove(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  80100f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  801015:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80101c:	00 
  80101d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801021:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801028:	e8 97 f9 ff ff       	call   8009c4 <memmove>

	r = sys_page_map(envid, PFTEMP, envid, ROUNDDOWN(addr,PGSIZE), PTE_P | PTE_U | PTE_W);
  80102d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801034:	00 
  801035:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801039:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80103d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801044:	00 
  801045:	89 1c 24             	mov    %ebx,(%esp)
  801048:	e8 4a fc ff ff       	call   800c97 <sys_page_map>
	if(r < 0) {
  80104d:	85 c0                	test   %eax,%eax
  80104f:	79 1c                	jns    80106d <pgfault+0xfd>
		panic("couldn't map page");
  801051:	c7 44 24 08 ac 2d 80 	movl   $0x802dac,0x8(%esp)
  801058:	00 
  801059:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  801060:	00 
  801061:	c7 04 24 7b 2d 80 00 	movl   $0x802d7b,(%esp)
  801068:	e8 e9 15 00 00       	call   802656 <_panic>
	}
}
  80106d:	83 c4 20             	add    $0x20,%esp
  801070:	5b                   	pop    %ebx
  801071:	5e                   	pop    %esi
  801072:	5d                   	pop    %ebp
  801073:	c3                   	ret    

00801074 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	57                   	push   %edi
  801078:	56                   	push   %esi
  801079:	53                   	push   %ebx
  80107a:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envid;
	uintptr_t addr;
	int r = 0;

	set_pgfault_handler(pgfault);
  80107d:	c7 04 24 70 0f 80 00 	movl   $0x800f70,(%esp)
  801084:	e8 23 16 00 00       	call   8026ac <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801089:	b8 07 00 00 00       	mov    $0x7,%eax
  80108e:	cd 30                	int    $0x30
  801090:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801093:	89 45 d8             	mov    %eax,-0x28(%ebp)

	envid = sys_exofork();
	if(envid == 0) {
  801096:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80109d:	bf 00 00 00 00       	mov    $0x0,%edi
  8010a2:	85 c0                	test   %eax,%eax
  8010a4:	75 21                	jne    8010c7 <fork+0x53>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010a6:	e8 5a fb ff ff       	call   800c05 <sys_getenvid>
  8010ab:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010b0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010b3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010b8:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  8010bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c2:	e9 8d 01 00 00       	jmp    801254 <fork+0x1e0>
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
  8010c7:	89 f8                	mov    %edi,%eax
  8010c9:	c1 e8 16             	shr    $0x16,%eax
  8010cc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010d3:	85 c0                	test   %eax,%eax
  8010d5:	0f 84 02 01 00 00    	je     8011dd <fork+0x169>
  8010db:	89 fa                	mov    %edi,%edx
  8010dd:	c1 ea 0c             	shr    $0xc,%edx
  8010e0:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	0f 84 ee 00 00 00    	je     8011dd <fork+0x169>
//
static int
duppage(envid_t envid, unsigned pn)
{

	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P)) return 0;
  8010ef:	89 d6                	mov    %edx,%esi
  8010f1:	c1 e6 0c             	shl    $0xc,%esi
  8010f4:	89 f0                	mov    %esi,%eax
  8010f6:	c1 e8 16             	shr    $0x16,%eax
  8010f9:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  801100:	b8 00 00 00 00       	mov    $0x0,%eax
  801105:	f6 c1 01             	test   $0x1,%cl
  801108:	0f 84 cc 00 00 00    	je     8011da <fork+0x166>

	int all_perms = PTE_U | PTE_P | PTE_AVAIL | PTE_W | PTE_COW;
	int orig_perms = uvpt[pn] & all_perms;
  80110e:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  801115:	89 d8                	mov    %ebx,%eax
  801117:	25 07 0e 00 00       	and    $0xe07,%eax
  80111c:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if(!(orig_perms & PTE_P)) return 0;
  80111f:	89 d8                	mov    %ebx,%eax
  801121:	83 e0 01             	and    $0x1,%eax
  801124:	0f 84 b0 00 00 00    	je     8011da <fork+0x166>

	int r = 0;
	envid_t curenvid = sys_getenvid();
  80112a:	e8 d6 fa ff ff       	call   800c05 <sys_getenvid>
  80112f:	89 45 dc             	mov    %eax,-0x24(%ebp)


	if(orig_perms & PTE_SHARE) {
  801132:	f7 45 e0 00 04 00 00 	testl  $0x400,-0x20(%ebp)
  801139:	74 28                	je     801163 <fork+0xef>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms & PTE_SYSCALL));
  80113b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80113e:	25 07 0e 00 00       	and    $0xe07,%eax
  801143:	89 44 24 10          	mov    %eax,0x10(%esp)
  801147:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80114b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80114e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801152:	89 74 24 04          	mov    %esi,0x4(%esp)
  801156:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801159:	89 04 24             	mov    %eax,(%esp)
  80115c:	e8 36 fb ff ff       	call   800c97 <sys_page_map>
  801161:	eb 77                	jmp    8011da <fork+0x166>

	} else if(((orig_perms) & PTE_COW) || (orig_perms & PTE_W) ) {
  801163:	f7 c3 02 08 00 00    	test   $0x802,%ebx
  801169:	74 4e                	je     8011b9 <fork+0x145>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  80116b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80116e:	25 fd f7 ff ff       	and    $0xfffff7fd,%eax
  801173:	80 cc 08             	or     $0x8,%ah
  801176:	89 c3                	mov    %eax,%ebx
  801178:	89 44 24 10          	mov    %eax,0x10(%esp)
  80117c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801180:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801183:	89 44 24 08          	mov    %eax,0x8(%esp)
  801187:	89 74 24 04          	mov    %esi,0x4(%esp)
  80118b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80118e:	89 04 24             	mov    %eax,(%esp)
  801191:	e8 01 fb ff ff       	call   800c97 <sys_page_map>
  801196:	89 45 e0             	mov    %eax,-0x20(%ebp)

		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), curenvid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  801199:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80119d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011a1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8011a4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011a8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011ac:	89 0c 24             	mov    %ecx,(%esp)
  8011af:	e8 e3 fa ff ff       	call   800c97 <sys_page_map>
  8011b4:	03 45 e0             	add    -0x20(%ebp),%eax
  8011b7:	eb 21                	jmp    8011da <fork+0x166>

	} else {
		r = sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), orig_perms);
  8011b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011bc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011c0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011c4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8011c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011cb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011d2:	89 04 24             	mov    %eax,(%esp)
  8011d5:	e8 bd fa ff ff       	call   800c97 <sys_page_map>
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
  8011da:	01 45 e4             	add    %eax,-0x1c(%ebp)
	if(envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
  8011dd:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8011e3:	81 ff 00 f0 bf ee    	cmp    $0xeebff000,%edi
  8011e9:	0f 85 d8 fe ff ff    	jne    8010c7 <fork+0x53>
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
		}
	}

	r+=sys_page_alloc(envid, (void*)UXSTACKTOP - PGSIZE, PTE_P|PTE_U|PTE_W);
  8011ef:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011f6:	00 
  8011f7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011fe:	ee 
  8011ff:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801202:	89 34 24             	mov    %esi,(%esp)
  801205:	e8 39 fa ff ff       	call   800c43 <sys_page_alloc>
  80120a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80120d:	01 c3                	add    %eax,%ebx
	r+=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80120f:	c7 44 24 04 f9 26 80 	movl   $0x8026f9,0x4(%esp)
  801216:	00 
  801217:	89 34 24             	mov    %esi,(%esp)
  80121a:	e8 c4 fb ff ff       	call   800de3 <sys_env_set_pgfault_upcall>
  80121f:	01 c3                	add    %eax,%ebx
	r+= sys_env_set_status(envid, ENV_RUNNABLE);
  801221:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801228:	00 
  801229:	89 34 24             	mov    %esi,(%esp)
  80122c:	e8 0c fb ff ff       	call   800d3d <sys_env_set_status>

	if(r<0) {
  801231:	01 d8                	add    %ebx,%eax
  801233:	79 1c                	jns    801251 <fork+0x1dd>
	 panic("fork failed!");
  801235:	c7 44 24 08 be 2d 80 	movl   $0x802dbe,0x8(%esp)
  80123c:	00 
  80123d:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  801244:	00 
  801245:	c7 04 24 7b 2d 80 00 	movl   $0x802d7b,(%esp)
  80124c:	e8 05 14 00 00       	call   802656 <_panic>
	}

	return envid;
  801251:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  801254:	83 c4 3c             	add    $0x3c,%esp
  801257:	5b                   	pop    %ebx
  801258:	5e                   	pop    %esi
  801259:	5f                   	pop    %edi
  80125a:	5d                   	pop    %ebp
  80125b:	c3                   	ret    

0080125c <sfork>:

// Challenge!
int
sfork(void)
{
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
  80125f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801262:	c7 44 24 08 cb 2d 80 	movl   $0x802dcb,0x8(%esp)
  801269:	00 
  80126a:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
  801271:	00 
  801272:	c7 04 24 7b 2d 80 00 	movl   $0x802d7b,(%esp)
  801279:	e8 d8 13 00 00       	call   802656 <_panic>
  80127e:	66 90                	xchg   %ax,%ax

00801280 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	56                   	push   %esi
  801284:	53                   	push   %ebx
  801285:	83 ec 10             	sub    $0x10,%esp
  801288:	8b 75 08             	mov    0x8(%ebp),%esi
  80128b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80128e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  801291:	85 c0                	test   %eax,%eax
  801293:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801298:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  80129b:	89 04 24             	mov    %eax,(%esp)
  80129e:	e8 b6 fb ff ff       	call   800e59 <sys_ipc_recv>

	if(ret < 0) {
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	79 16                	jns    8012bd <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  8012a7:	85 f6                	test   %esi,%esi
  8012a9:	74 06                	je     8012b1 <ipc_recv+0x31>
  8012ab:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  8012b1:	85 db                	test   %ebx,%ebx
  8012b3:	74 3e                	je     8012f3 <ipc_recv+0x73>
  8012b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8012bb:	eb 36                	jmp    8012f3 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  8012bd:	e8 43 f9 ff ff       	call   800c05 <sys_getenvid>
  8012c2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8012c7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012ca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012cf:	a3 08 40 80 00       	mov    %eax,0x804008

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8012d4:	85 f6                	test   %esi,%esi
  8012d6:	74 05                	je     8012dd <ipc_recv+0x5d>
  8012d8:	8b 40 74             	mov    0x74(%eax),%eax
  8012db:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8012dd:	85 db                	test   %ebx,%ebx
  8012df:	74 0a                	je     8012eb <ipc_recv+0x6b>
  8012e1:	a1 08 40 80 00       	mov    0x804008,%eax
  8012e6:	8b 40 78             	mov    0x78(%eax),%eax
  8012e9:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  8012eb:	a1 08 40 80 00       	mov    0x804008,%eax
  8012f0:	8b 40 70             	mov    0x70(%eax),%eax
}
  8012f3:	83 c4 10             	add    $0x10,%esp
  8012f6:	5b                   	pop    %ebx
  8012f7:	5e                   	pop    %esi
  8012f8:	5d                   	pop    %ebp
  8012f9:	c3                   	ret    

008012fa <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
  8012fd:	57                   	push   %edi
  8012fe:	56                   	push   %esi
  8012ff:	53                   	push   %ebx
  801300:	83 ec 1c             	sub    $0x1c,%esp
  801303:	8b 7d 08             	mov    0x8(%ebp),%edi
  801306:	8b 75 0c             	mov    0xc(%ebp),%esi
  801309:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  80130c:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  80130e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801313:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  801316:	8b 45 14             	mov    0x14(%ebp),%eax
  801319:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80131d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801321:	89 74 24 04          	mov    %esi,0x4(%esp)
  801325:	89 3c 24             	mov    %edi,(%esp)
  801328:	e8 09 fb ff ff       	call   800e36 <sys_ipc_try_send>

		if(ret >= 0) break;
  80132d:	85 c0                	test   %eax,%eax
  80132f:	79 2c                	jns    80135d <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  801331:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801334:	74 20                	je     801356 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  801336:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80133a:	c7 44 24 08 e4 2d 80 	movl   $0x802de4,0x8(%esp)
  801341:	00 
  801342:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801349:	00 
  80134a:	c7 04 24 14 2e 80 00 	movl   $0x802e14,(%esp)
  801351:	e8 00 13 00 00       	call   802656 <_panic>
		}
		sys_yield();
  801356:	e8 c9 f8 ff ff       	call   800c24 <sys_yield>
	}
  80135b:	eb b9                	jmp    801316 <ipc_send+0x1c>
}
  80135d:	83 c4 1c             	add    $0x1c,%esp
  801360:	5b                   	pop    %ebx
  801361:	5e                   	pop    %esi
  801362:	5f                   	pop    %edi
  801363:	5d                   	pop    %ebp
  801364:	c3                   	ret    

00801365 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801365:	55                   	push   %ebp
  801366:	89 e5                	mov    %esp,%ebp
  801368:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80136b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801370:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801373:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801379:	8b 52 50             	mov    0x50(%edx),%edx
  80137c:	39 ca                	cmp    %ecx,%edx
  80137e:	75 0d                	jne    80138d <ipc_find_env+0x28>
			return envs[i].env_id;
  801380:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801383:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801388:	8b 40 40             	mov    0x40(%eax),%eax
  80138b:	eb 0e                	jmp    80139b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80138d:	83 c0 01             	add    $0x1,%eax
  801390:	3d 00 04 00 00       	cmp    $0x400,%eax
  801395:	75 d9                	jne    801370 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801397:	66 b8 00 00          	mov    $0x0,%ax
}
  80139b:	5d                   	pop    %ebp
  80139c:	c3                   	ret    
  80139d:	66 90                	xchg   %ax,%ax
  80139f:	90                   	nop

008013a0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013a0:	55                   	push   %ebp
  8013a1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a6:	05 00 00 00 30       	add    $0x30000000,%eax
  8013ab:	c1 e8 0c             	shr    $0xc,%eax
}
  8013ae:	5d                   	pop    %ebp
  8013af:	c3                   	ret    

008013b0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8013bb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013c0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013c5:	5d                   	pop    %ebp
  8013c6:	c3                   	ret    

008013c7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013c7:	55                   	push   %ebp
  8013c8:	89 e5                	mov    %esp,%ebp
  8013ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013cd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013d2:	89 c2                	mov    %eax,%edx
  8013d4:	c1 ea 16             	shr    $0x16,%edx
  8013d7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013de:	f6 c2 01             	test   $0x1,%dl
  8013e1:	74 11                	je     8013f4 <fd_alloc+0x2d>
  8013e3:	89 c2                	mov    %eax,%edx
  8013e5:	c1 ea 0c             	shr    $0xc,%edx
  8013e8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013ef:	f6 c2 01             	test   $0x1,%dl
  8013f2:	75 09                	jne    8013fd <fd_alloc+0x36>
			*fd_store = fd;
  8013f4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8013fb:	eb 17                	jmp    801414 <fd_alloc+0x4d>
  8013fd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801402:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801407:	75 c9                	jne    8013d2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801409:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80140f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801414:	5d                   	pop    %ebp
  801415:	c3                   	ret    

00801416 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80141c:	83 f8 1f             	cmp    $0x1f,%eax
  80141f:	77 36                	ja     801457 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801421:	c1 e0 0c             	shl    $0xc,%eax
  801424:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801429:	89 c2                	mov    %eax,%edx
  80142b:	c1 ea 16             	shr    $0x16,%edx
  80142e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801435:	f6 c2 01             	test   $0x1,%dl
  801438:	74 24                	je     80145e <fd_lookup+0x48>
  80143a:	89 c2                	mov    %eax,%edx
  80143c:	c1 ea 0c             	shr    $0xc,%edx
  80143f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801446:	f6 c2 01             	test   $0x1,%dl
  801449:	74 1a                	je     801465 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80144b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80144e:	89 02                	mov    %eax,(%edx)
	return 0;
  801450:	b8 00 00 00 00       	mov    $0x0,%eax
  801455:	eb 13                	jmp    80146a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801457:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80145c:	eb 0c                	jmp    80146a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80145e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801463:	eb 05                	jmp    80146a <fd_lookup+0x54>
  801465:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80146a:	5d                   	pop    %ebp
  80146b:	c3                   	ret    

0080146c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80146c:	55                   	push   %ebp
  80146d:	89 e5                	mov    %esp,%ebp
  80146f:	83 ec 18             	sub    $0x18,%esp
  801472:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801475:	ba 00 00 00 00       	mov    $0x0,%edx
  80147a:	eb 13                	jmp    80148f <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  80147c:	39 08                	cmp    %ecx,(%eax)
  80147e:	75 0c                	jne    80148c <dev_lookup+0x20>
			*dev = devtab[i];
  801480:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801483:	89 01                	mov    %eax,(%ecx)
			return 0;
  801485:	b8 00 00 00 00       	mov    $0x0,%eax
  80148a:	eb 38                	jmp    8014c4 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80148c:	83 c2 01             	add    $0x1,%edx
  80148f:	8b 04 95 9c 2e 80 00 	mov    0x802e9c(,%edx,4),%eax
  801496:	85 c0                	test   %eax,%eax
  801498:	75 e2                	jne    80147c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80149a:	a1 08 40 80 00       	mov    0x804008,%eax
  80149f:	8b 40 48             	mov    0x48(%eax),%eax
  8014a2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014aa:	c7 04 24 20 2e 80 00 	movl   $0x802e20,(%esp)
  8014b1:	e8 49 ed ff ff       	call   8001ff <cprintf>
	*dev = 0;
  8014b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014c4:	c9                   	leave  
  8014c5:	c3                   	ret    

008014c6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014c6:	55                   	push   %ebp
  8014c7:	89 e5                	mov    %esp,%ebp
  8014c9:	56                   	push   %esi
  8014ca:	53                   	push   %ebx
  8014cb:	83 ec 20             	sub    $0x20,%esp
  8014ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8014d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d7:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014db:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014e1:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014e4:	89 04 24             	mov    %eax,(%esp)
  8014e7:	e8 2a ff ff ff       	call   801416 <fd_lookup>
  8014ec:	85 c0                	test   %eax,%eax
  8014ee:	78 05                	js     8014f5 <fd_close+0x2f>
	    || fd != fd2)
  8014f0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014f3:	74 0c                	je     801501 <fd_close+0x3b>
		return (must_exist ? r : 0);
  8014f5:	84 db                	test   %bl,%bl
  8014f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fc:	0f 44 c2             	cmove  %edx,%eax
  8014ff:	eb 3f                	jmp    801540 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801501:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801504:	89 44 24 04          	mov    %eax,0x4(%esp)
  801508:	8b 06                	mov    (%esi),%eax
  80150a:	89 04 24             	mov    %eax,(%esp)
  80150d:	e8 5a ff ff ff       	call   80146c <dev_lookup>
  801512:	89 c3                	mov    %eax,%ebx
  801514:	85 c0                	test   %eax,%eax
  801516:	78 16                	js     80152e <fd_close+0x68>
		if (dev->dev_close)
  801518:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80151e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801523:	85 c0                	test   %eax,%eax
  801525:	74 07                	je     80152e <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801527:	89 34 24             	mov    %esi,(%esp)
  80152a:	ff d0                	call   *%eax
  80152c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80152e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801532:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801539:	e8 ac f7 ff ff       	call   800cea <sys_page_unmap>
	return r;
  80153e:	89 d8                	mov    %ebx,%eax
}
  801540:	83 c4 20             	add    $0x20,%esp
  801543:	5b                   	pop    %ebx
  801544:	5e                   	pop    %esi
  801545:	5d                   	pop    %ebp
  801546:	c3                   	ret    

00801547 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801547:	55                   	push   %ebp
  801548:	89 e5                	mov    %esp,%ebp
  80154a:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80154d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801550:	89 44 24 04          	mov    %eax,0x4(%esp)
  801554:	8b 45 08             	mov    0x8(%ebp),%eax
  801557:	89 04 24             	mov    %eax,(%esp)
  80155a:	e8 b7 fe ff ff       	call   801416 <fd_lookup>
  80155f:	89 c2                	mov    %eax,%edx
  801561:	85 d2                	test   %edx,%edx
  801563:	78 13                	js     801578 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801565:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80156c:	00 
  80156d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801570:	89 04 24             	mov    %eax,(%esp)
  801573:	e8 4e ff ff ff       	call   8014c6 <fd_close>
}
  801578:	c9                   	leave  
  801579:	c3                   	ret    

0080157a <close_all>:

void
close_all(void)
{
  80157a:	55                   	push   %ebp
  80157b:	89 e5                	mov    %esp,%ebp
  80157d:	53                   	push   %ebx
  80157e:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801581:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801586:	89 1c 24             	mov    %ebx,(%esp)
  801589:	e8 b9 ff ff ff       	call   801547 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80158e:	83 c3 01             	add    $0x1,%ebx
  801591:	83 fb 20             	cmp    $0x20,%ebx
  801594:	75 f0                	jne    801586 <close_all+0xc>
		close(i);
}
  801596:	83 c4 14             	add    $0x14,%esp
  801599:	5b                   	pop    %ebx
  80159a:	5d                   	pop    %ebp
  80159b:	c3                   	ret    

0080159c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80159c:	55                   	push   %ebp
  80159d:	89 e5                	mov    %esp,%ebp
  80159f:	57                   	push   %edi
  8015a0:	56                   	push   %esi
  8015a1:	53                   	push   %ebx
  8015a2:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015a5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8015af:	89 04 24             	mov    %eax,(%esp)
  8015b2:	e8 5f fe ff ff       	call   801416 <fd_lookup>
  8015b7:	89 c2                	mov    %eax,%edx
  8015b9:	85 d2                	test   %edx,%edx
  8015bb:	0f 88 e1 00 00 00    	js     8016a2 <dup+0x106>
		return r;
	close(newfdnum);
  8015c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c4:	89 04 24             	mov    %eax,(%esp)
  8015c7:	e8 7b ff ff ff       	call   801547 <close>

	newfd = INDEX2FD(newfdnum);
  8015cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015cf:	c1 e3 0c             	shl    $0xc,%ebx
  8015d2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015db:	89 04 24             	mov    %eax,(%esp)
  8015de:	e8 cd fd ff ff       	call   8013b0 <fd2data>
  8015e3:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8015e5:	89 1c 24             	mov    %ebx,(%esp)
  8015e8:	e8 c3 fd ff ff       	call   8013b0 <fd2data>
  8015ed:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015ef:	89 f0                	mov    %esi,%eax
  8015f1:	c1 e8 16             	shr    $0x16,%eax
  8015f4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015fb:	a8 01                	test   $0x1,%al
  8015fd:	74 43                	je     801642 <dup+0xa6>
  8015ff:	89 f0                	mov    %esi,%eax
  801601:	c1 e8 0c             	shr    $0xc,%eax
  801604:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80160b:	f6 c2 01             	test   $0x1,%dl
  80160e:	74 32                	je     801642 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801610:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801617:	25 07 0e 00 00       	and    $0xe07,%eax
  80161c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801620:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801624:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80162b:	00 
  80162c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801630:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801637:	e8 5b f6 ff ff       	call   800c97 <sys_page_map>
  80163c:	89 c6                	mov    %eax,%esi
  80163e:	85 c0                	test   %eax,%eax
  801640:	78 3e                	js     801680 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801642:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801645:	89 c2                	mov    %eax,%edx
  801647:	c1 ea 0c             	shr    $0xc,%edx
  80164a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801651:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801657:	89 54 24 10          	mov    %edx,0x10(%esp)
  80165b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80165f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801666:	00 
  801667:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801672:	e8 20 f6 ff ff       	call   800c97 <sys_page_map>
  801677:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801679:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80167c:	85 f6                	test   %esi,%esi
  80167e:	79 22                	jns    8016a2 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801680:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801684:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80168b:	e8 5a f6 ff ff       	call   800cea <sys_page_unmap>
	sys_page_unmap(0, nva);
  801690:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801694:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80169b:	e8 4a f6 ff ff       	call   800cea <sys_page_unmap>
	return r;
  8016a0:	89 f0                	mov    %esi,%eax
}
  8016a2:	83 c4 3c             	add    $0x3c,%esp
  8016a5:	5b                   	pop    %ebx
  8016a6:	5e                   	pop    %esi
  8016a7:	5f                   	pop    %edi
  8016a8:	5d                   	pop    %ebp
  8016a9:	c3                   	ret    

008016aa <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	53                   	push   %ebx
  8016ae:	83 ec 24             	sub    $0x24,%esp
  8016b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016bb:	89 1c 24             	mov    %ebx,(%esp)
  8016be:	e8 53 fd ff ff       	call   801416 <fd_lookup>
  8016c3:	89 c2                	mov    %eax,%edx
  8016c5:	85 d2                	test   %edx,%edx
  8016c7:	78 6d                	js     801736 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d3:	8b 00                	mov    (%eax),%eax
  8016d5:	89 04 24             	mov    %eax,(%esp)
  8016d8:	e8 8f fd ff ff       	call   80146c <dev_lookup>
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	78 55                	js     801736 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e4:	8b 50 08             	mov    0x8(%eax),%edx
  8016e7:	83 e2 03             	and    $0x3,%edx
  8016ea:	83 fa 01             	cmp    $0x1,%edx
  8016ed:	75 23                	jne    801712 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016ef:	a1 08 40 80 00       	mov    0x804008,%eax
  8016f4:	8b 40 48             	mov    0x48(%eax),%eax
  8016f7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ff:	c7 04 24 61 2e 80 00 	movl   $0x802e61,(%esp)
  801706:	e8 f4 ea ff ff       	call   8001ff <cprintf>
		return -E_INVAL;
  80170b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801710:	eb 24                	jmp    801736 <read+0x8c>
	}
	if (!dev->dev_read)
  801712:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801715:	8b 52 08             	mov    0x8(%edx),%edx
  801718:	85 d2                	test   %edx,%edx
  80171a:	74 15                	je     801731 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80171c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80171f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801723:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801726:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80172a:	89 04 24             	mov    %eax,(%esp)
  80172d:	ff d2                	call   *%edx
  80172f:	eb 05                	jmp    801736 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801731:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801736:	83 c4 24             	add    $0x24,%esp
  801739:	5b                   	pop    %ebx
  80173a:	5d                   	pop    %ebp
  80173b:	c3                   	ret    

0080173c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	57                   	push   %edi
  801740:	56                   	push   %esi
  801741:	53                   	push   %ebx
  801742:	83 ec 1c             	sub    $0x1c,%esp
  801745:	8b 7d 08             	mov    0x8(%ebp),%edi
  801748:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80174b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801750:	eb 23                	jmp    801775 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801752:	89 f0                	mov    %esi,%eax
  801754:	29 d8                	sub    %ebx,%eax
  801756:	89 44 24 08          	mov    %eax,0x8(%esp)
  80175a:	89 d8                	mov    %ebx,%eax
  80175c:	03 45 0c             	add    0xc(%ebp),%eax
  80175f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801763:	89 3c 24             	mov    %edi,(%esp)
  801766:	e8 3f ff ff ff       	call   8016aa <read>
		if (m < 0)
  80176b:	85 c0                	test   %eax,%eax
  80176d:	78 10                	js     80177f <readn+0x43>
			return m;
		if (m == 0)
  80176f:	85 c0                	test   %eax,%eax
  801771:	74 0a                	je     80177d <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801773:	01 c3                	add    %eax,%ebx
  801775:	39 f3                	cmp    %esi,%ebx
  801777:	72 d9                	jb     801752 <readn+0x16>
  801779:	89 d8                	mov    %ebx,%eax
  80177b:	eb 02                	jmp    80177f <readn+0x43>
  80177d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80177f:	83 c4 1c             	add    $0x1c,%esp
  801782:	5b                   	pop    %ebx
  801783:	5e                   	pop    %esi
  801784:	5f                   	pop    %edi
  801785:	5d                   	pop    %ebp
  801786:	c3                   	ret    

00801787 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	53                   	push   %ebx
  80178b:	83 ec 24             	sub    $0x24,%esp
  80178e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801791:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801794:	89 44 24 04          	mov    %eax,0x4(%esp)
  801798:	89 1c 24             	mov    %ebx,(%esp)
  80179b:	e8 76 fc ff ff       	call   801416 <fd_lookup>
  8017a0:	89 c2                	mov    %eax,%edx
  8017a2:	85 d2                	test   %edx,%edx
  8017a4:	78 68                	js     80180e <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b0:	8b 00                	mov    (%eax),%eax
  8017b2:	89 04 24             	mov    %eax,(%esp)
  8017b5:	e8 b2 fc ff ff       	call   80146c <dev_lookup>
  8017ba:	85 c0                	test   %eax,%eax
  8017bc:	78 50                	js     80180e <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017c5:	75 23                	jne    8017ea <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017c7:	a1 08 40 80 00       	mov    0x804008,%eax
  8017cc:	8b 40 48             	mov    0x48(%eax),%eax
  8017cf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d7:	c7 04 24 7d 2e 80 00 	movl   $0x802e7d,(%esp)
  8017de:	e8 1c ea ff ff       	call   8001ff <cprintf>
		return -E_INVAL;
  8017e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017e8:	eb 24                	jmp    80180e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ed:	8b 52 0c             	mov    0xc(%edx),%edx
  8017f0:	85 d2                	test   %edx,%edx
  8017f2:	74 15                	je     801809 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017f4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017f7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017fe:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801802:	89 04 24             	mov    %eax,(%esp)
  801805:	ff d2                	call   *%edx
  801807:	eb 05                	jmp    80180e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801809:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80180e:	83 c4 24             	add    $0x24,%esp
  801811:	5b                   	pop    %ebx
  801812:	5d                   	pop    %ebp
  801813:	c3                   	ret    

00801814 <seek>:

int
seek(int fdnum, off_t offset)
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80181a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80181d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801821:	8b 45 08             	mov    0x8(%ebp),%eax
  801824:	89 04 24             	mov    %eax,(%esp)
  801827:	e8 ea fb ff ff       	call   801416 <fd_lookup>
  80182c:	85 c0                	test   %eax,%eax
  80182e:	78 0e                	js     80183e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801830:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801833:	8b 55 0c             	mov    0xc(%ebp),%edx
  801836:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801839:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80183e:	c9                   	leave  
  80183f:	c3                   	ret    

00801840 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	53                   	push   %ebx
  801844:	83 ec 24             	sub    $0x24,%esp
  801847:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80184a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80184d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801851:	89 1c 24             	mov    %ebx,(%esp)
  801854:	e8 bd fb ff ff       	call   801416 <fd_lookup>
  801859:	89 c2                	mov    %eax,%edx
  80185b:	85 d2                	test   %edx,%edx
  80185d:	78 61                	js     8018c0 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80185f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801862:	89 44 24 04          	mov    %eax,0x4(%esp)
  801866:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801869:	8b 00                	mov    (%eax),%eax
  80186b:	89 04 24             	mov    %eax,(%esp)
  80186e:	e8 f9 fb ff ff       	call   80146c <dev_lookup>
  801873:	85 c0                	test   %eax,%eax
  801875:	78 49                	js     8018c0 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801877:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80187a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80187e:	75 23                	jne    8018a3 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801880:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801885:	8b 40 48             	mov    0x48(%eax),%eax
  801888:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80188c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801890:	c7 04 24 40 2e 80 00 	movl   $0x802e40,(%esp)
  801897:	e8 63 e9 ff ff       	call   8001ff <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80189c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018a1:	eb 1d                	jmp    8018c0 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8018a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018a6:	8b 52 18             	mov    0x18(%edx),%edx
  8018a9:	85 d2                	test   %edx,%edx
  8018ab:	74 0e                	je     8018bb <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018b0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018b4:	89 04 24             	mov    %eax,(%esp)
  8018b7:	ff d2                	call   *%edx
  8018b9:	eb 05                	jmp    8018c0 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018bb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8018c0:	83 c4 24             	add    $0x24,%esp
  8018c3:	5b                   	pop    %ebx
  8018c4:	5d                   	pop    %ebp
  8018c5:	c3                   	ret    

008018c6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018c6:	55                   	push   %ebp
  8018c7:	89 e5                	mov    %esp,%ebp
  8018c9:	53                   	push   %ebx
  8018ca:	83 ec 24             	sub    $0x24,%esp
  8018cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018da:	89 04 24             	mov    %eax,(%esp)
  8018dd:	e8 34 fb ff ff       	call   801416 <fd_lookup>
  8018e2:	89 c2                	mov    %eax,%edx
  8018e4:	85 d2                	test   %edx,%edx
  8018e6:	78 52                	js     80193a <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f2:	8b 00                	mov    (%eax),%eax
  8018f4:	89 04 24             	mov    %eax,(%esp)
  8018f7:	e8 70 fb ff ff       	call   80146c <dev_lookup>
  8018fc:	85 c0                	test   %eax,%eax
  8018fe:	78 3a                	js     80193a <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801900:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801903:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801907:	74 2c                	je     801935 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801909:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80190c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801913:	00 00 00 
	stat->st_isdir = 0;
  801916:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80191d:	00 00 00 
	stat->st_dev = dev;
  801920:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801926:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80192a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80192d:	89 14 24             	mov    %edx,(%esp)
  801930:	ff 50 14             	call   *0x14(%eax)
  801933:	eb 05                	jmp    80193a <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801935:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80193a:	83 c4 24             	add    $0x24,%esp
  80193d:	5b                   	pop    %ebx
  80193e:	5d                   	pop    %ebp
  80193f:	c3                   	ret    

00801940 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	56                   	push   %esi
  801944:	53                   	push   %ebx
  801945:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801948:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80194f:	00 
  801950:	8b 45 08             	mov    0x8(%ebp),%eax
  801953:	89 04 24             	mov    %eax,(%esp)
  801956:	e8 28 02 00 00       	call   801b83 <open>
  80195b:	89 c3                	mov    %eax,%ebx
  80195d:	85 db                	test   %ebx,%ebx
  80195f:	78 1b                	js     80197c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801961:	8b 45 0c             	mov    0xc(%ebp),%eax
  801964:	89 44 24 04          	mov    %eax,0x4(%esp)
  801968:	89 1c 24             	mov    %ebx,(%esp)
  80196b:	e8 56 ff ff ff       	call   8018c6 <fstat>
  801970:	89 c6                	mov    %eax,%esi
	close(fd);
  801972:	89 1c 24             	mov    %ebx,(%esp)
  801975:	e8 cd fb ff ff       	call   801547 <close>
	return r;
  80197a:	89 f0                	mov    %esi,%eax
}
  80197c:	83 c4 10             	add    $0x10,%esp
  80197f:	5b                   	pop    %ebx
  801980:	5e                   	pop    %esi
  801981:	5d                   	pop    %ebp
  801982:	c3                   	ret    

00801983 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801983:	55                   	push   %ebp
  801984:	89 e5                	mov    %esp,%ebp
  801986:	56                   	push   %esi
  801987:	53                   	push   %ebx
  801988:	83 ec 10             	sub    $0x10,%esp
  80198b:	89 c6                	mov    %eax,%esi
  80198d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80198f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801996:	75 11                	jne    8019a9 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801998:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80199f:	e8 c1 f9 ff ff       	call   801365 <ipc_find_env>
  8019a4:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019a9:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8019b0:	00 
  8019b1:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8019b8:	00 
  8019b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019bd:	a1 00 40 80 00       	mov    0x804000,%eax
  8019c2:	89 04 24             	mov    %eax,(%esp)
  8019c5:	e8 30 f9 ff ff       	call   8012fa <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019ca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019d1:	00 
  8019d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019dd:	e8 9e f8 ff ff       	call   801280 <ipc_recv>
}
  8019e2:	83 c4 10             	add    $0x10,%esp
  8019e5:	5b                   	pop    %ebx
  8019e6:	5e                   	pop    %esi
  8019e7:	5d                   	pop    %ebp
  8019e8:	c3                   	ret    

008019e9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8019f5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019fd:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a02:	ba 00 00 00 00       	mov    $0x0,%edx
  801a07:	b8 02 00 00 00       	mov    $0x2,%eax
  801a0c:	e8 72 ff ff ff       	call   801983 <fsipc>
}
  801a11:	c9                   	leave  
  801a12:	c3                   	ret    

00801a13 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a19:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1c:	8b 40 0c             	mov    0xc(%eax),%eax
  801a1f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a24:	ba 00 00 00 00       	mov    $0x0,%edx
  801a29:	b8 06 00 00 00       	mov    $0x6,%eax
  801a2e:	e8 50 ff ff ff       	call   801983 <fsipc>
}
  801a33:	c9                   	leave  
  801a34:	c3                   	ret    

00801a35 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	53                   	push   %ebx
  801a39:	83 ec 14             	sub    $0x14,%esp
  801a3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a42:	8b 40 0c             	mov    0xc(%eax),%eax
  801a45:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a4a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a4f:	b8 05 00 00 00       	mov    $0x5,%eax
  801a54:	e8 2a ff ff ff       	call   801983 <fsipc>
  801a59:	89 c2                	mov    %eax,%edx
  801a5b:	85 d2                	test   %edx,%edx
  801a5d:	78 2b                	js     801a8a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a5f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a66:	00 
  801a67:	89 1c 24             	mov    %ebx,(%esp)
  801a6a:	e8 b8 ed ff ff       	call   800827 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a6f:	a1 80 50 80 00       	mov    0x805080,%eax
  801a74:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a7a:	a1 84 50 80 00       	mov    0x805084,%eax
  801a7f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a85:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a8a:	83 c4 14             	add    $0x14,%esp
  801a8d:	5b                   	pop    %ebx
  801a8e:	5d                   	pop    %ebp
  801a8f:	c3                   	ret    

00801a90 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	83 ec 18             	sub    $0x18,%esp
  801a96:	8b 45 10             	mov    0x10(%ebp),%eax
  801a99:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a9e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801aa3:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801aa6:	8b 55 08             	mov    0x8(%ebp),%edx
  801aa9:	8b 52 0c             	mov    0xc(%edx),%edx
  801aac:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801ab2:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801ab7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801abb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801abe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac2:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801ac9:	e8 f6 ee ff ff       	call   8009c4 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  801ace:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad3:	b8 04 00 00 00       	mov    $0x4,%eax
  801ad8:	e8 a6 fe ff ff       	call   801983 <fsipc>
}
  801add:	c9                   	leave  
  801ade:	c3                   	ret    

00801adf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	56                   	push   %esi
  801ae3:	53                   	push   %ebx
  801ae4:	83 ec 10             	sub    $0x10,%esp
  801ae7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801aea:	8b 45 08             	mov    0x8(%ebp),%eax
  801aed:	8b 40 0c             	mov    0xc(%eax),%eax
  801af0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801af5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801afb:	ba 00 00 00 00       	mov    $0x0,%edx
  801b00:	b8 03 00 00 00       	mov    $0x3,%eax
  801b05:	e8 79 fe ff ff       	call   801983 <fsipc>
  801b0a:	89 c3                	mov    %eax,%ebx
  801b0c:	85 c0                	test   %eax,%eax
  801b0e:	78 6a                	js     801b7a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801b10:	39 c6                	cmp    %eax,%esi
  801b12:	73 24                	jae    801b38 <devfile_read+0x59>
  801b14:	c7 44 24 0c b0 2e 80 	movl   $0x802eb0,0xc(%esp)
  801b1b:	00 
  801b1c:	c7 44 24 08 b7 2e 80 	movl   $0x802eb7,0x8(%esp)
  801b23:	00 
  801b24:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801b2b:	00 
  801b2c:	c7 04 24 cc 2e 80 00 	movl   $0x802ecc,(%esp)
  801b33:	e8 1e 0b 00 00       	call   802656 <_panic>
	assert(r <= PGSIZE);
  801b38:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b3d:	7e 24                	jle    801b63 <devfile_read+0x84>
  801b3f:	c7 44 24 0c d7 2e 80 	movl   $0x802ed7,0xc(%esp)
  801b46:	00 
  801b47:	c7 44 24 08 b7 2e 80 	movl   $0x802eb7,0x8(%esp)
  801b4e:	00 
  801b4f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801b56:	00 
  801b57:	c7 04 24 cc 2e 80 00 	movl   $0x802ecc,(%esp)
  801b5e:	e8 f3 0a 00 00       	call   802656 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b63:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b67:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b6e:	00 
  801b6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b72:	89 04 24             	mov    %eax,(%esp)
  801b75:	e8 4a ee ff ff       	call   8009c4 <memmove>
	return r;
}
  801b7a:	89 d8                	mov    %ebx,%eax
  801b7c:	83 c4 10             	add    $0x10,%esp
  801b7f:	5b                   	pop    %ebx
  801b80:	5e                   	pop    %esi
  801b81:	5d                   	pop    %ebp
  801b82:	c3                   	ret    

00801b83 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b83:	55                   	push   %ebp
  801b84:	89 e5                	mov    %esp,%ebp
  801b86:	53                   	push   %ebx
  801b87:	83 ec 24             	sub    $0x24,%esp
  801b8a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b8d:	89 1c 24             	mov    %ebx,(%esp)
  801b90:	e8 5b ec ff ff       	call   8007f0 <strlen>
  801b95:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b9a:	7f 60                	jg     801bfc <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b9f:	89 04 24             	mov    %eax,(%esp)
  801ba2:	e8 20 f8 ff ff       	call   8013c7 <fd_alloc>
  801ba7:	89 c2                	mov    %eax,%edx
  801ba9:	85 d2                	test   %edx,%edx
  801bab:	78 54                	js     801c01 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bb1:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801bb8:	e8 6a ec ff ff       	call   800827 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bbd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc0:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bc8:	b8 01 00 00 00       	mov    $0x1,%eax
  801bcd:	e8 b1 fd ff ff       	call   801983 <fsipc>
  801bd2:	89 c3                	mov    %eax,%ebx
  801bd4:	85 c0                	test   %eax,%eax
  801bd6:	79 17                	jns    801bef <open+0x6c>
		fd_close(fd, 0);
  801bd8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bdf:	00 
  801be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be3:	89 04 24             	mov    %eax,(%esp)
  801be6:	e8 db f8 ff ff       	call   8014c6 <fd_close>
		return r;
  801beb:	89 d8                	mov    %ebx,%eax
  801bed:	eb 12                	jmp    801c01 <open+0x7e>
	}

	return fd2num(fd);
  801bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf2:	89 04 24             	mov    %eax,(%esp)
  801bf5:	e8 a6 f7 ff ff       	call   8013a0 <fd2num>
  801bfa:	eb 05                	jmp    801c01 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bfc:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c01:	83 c4 24             	add    $0x24,%esp
  801c04:	5b                   	pop    %ebx
  801c05:	5d                   	pop    %ebp
  801c06:	c3                   	ret    

00801c07 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c07:	55                   	push   %ebp
  801c08:	89 e5                	mov    %esp,%ebp
  801c0a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c0d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c12:	b8 08 00 00 00       	mov    $0x8,%eax
  801c17:	e8 67 fd ff ff       	call   801983 <fsipc>
}
  801c1c:	c9                   	leave  
  801c1d:	c3                   	ret    
  801c1e:	66 90                	xchg   %ax,%ax

00801c20 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801c26:	c7 44 24 04 e3 2e 80 	movl   $0x802ee3,0x4(%esp)
  801c2d:	00 
  801c2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c31:	89 04 24             	mov    %eax,(%esp)
  801c34:	e8 ee eb ff ff       	call   800827 <strcpy>
	return 0;
}
  801c39:	b8 00 00 00 00       	mov    $0x0,%eax
  801c3e:	c9                   	leave  
  801c3f:	c3                   	ret    

00801c40 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	53                   	push   %ebx
  801c44:	83 ec 14             	sub    $0x14,%esp
  801c47:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c4a:	89 1c 24             	mov    %ebx,(%esp)
  801c4d:	e8 cb 0a 00 00       	call   80271d <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801c52:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801c57:	83 f8 01             	cmp    $0x1,%eax
  801c5a:	75 0d                	jne    801c69 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801c5c:	8b 43 0c             	mov    0xc(%ebx),%eax
  801c5f:	89 04 24             	mov    %eax,(%esp)
  801c62:	e8 29 03 00 00       	call   801f90 <nsipc_close>
  801c67:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  801c69:	89 d0                	mov    %edx,%eax
  801c6b:	83 c4 14             	add    $0x14,%esp
  801c6e:	5b                   	pop    %ebx
  801c6f:	5d                   	pop    %ebp
  801c70:	c3                   	ret    

00801c71 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801c71:	55                   	push   %ebp
  801c72:	89 e5                	mov    %esp,%ebp
  801c74:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c77:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801c7e:	00 
  801c7f:	8b 45 10             	mov    0x10(%ebp),%eax
  801c82:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c86:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c89:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c90:	8b 40 0c             	mov    0xc(%eax),%eax
  801c93:	89 04 24             	mov    %eax,(%esp)
  801c96:	e8 f0 03 00 00       	call   80208b <nsipc_send>
}
  801c9b:	c9                   	leave  
  801c9c:	c3                   	ret    

00801c9d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801c9d:	55                   	push   %ebp
  801c9e:	89 e5                	mov    %esp,%ebp
  801ca0:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ca3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801caa:	00 
  801cab:	8b 45 10             	mov    0x10(%ebp),%eax
  801cae:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cb9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbc:	8b 40 0c             	mov    0xc(%eax),%eax
  801cbf:	89 04 24             	mov    %eax,(%esp)
  801cc2:	e8 44 03 00 00       	call   80200b <nsipc_recv>
}
  801cc7:	c9                   	leave  
  801cc8:	c3                   	ret    

00801cc9 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801cc9:	55                   	push   %ebp
  801cca:	89 e5                	mov    %esp,%ebp
  801ccc:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801ccf:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801cd2:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cd6:	89 04 24             	mov    %eax,(%esp)
  801cd9:	e8 38 f7 ff ff       	call   801416 <fd_lookup>
  801cde:	85 c0                	test   %eax,%eax
  801ce0:	78 17                	js     801cf9 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce5:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801ceb:	39 08                	cmp    %ecx,(%eax)
  801ced:	75 05                	jne    801cf4 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801cef:	8b 40 0c             	mov    0xc(%eax),%eax
  801cf2:	eb 05                	jmp    801cf9 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801cf4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801cf9:	c9                   	leave  
  801cfa:	c3                   	ret    

00801cfb <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	56                   	push   %esi
  801cff:	53                   	push   %ebx
  801d00:	83 ec 20             	sub    $0x20,%esp
  801d03:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801d05:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d08:	89 04 24             	mov    %eax,(%esp)
  801d0b:	e8 b7 f6 ff ff       	call   8013c7 <fd_alloc>
  801d10:	89 c3                	mov    %eax,%ebx
  801d12:	85 c0                	test   %eax,%eax
  801d14:	78 21                	js     801d37 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d16:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d1d:	00 
  801d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d21:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d2c:	e8 12 ef ff ff       	call   800c43 <sys_page_alloc>
  801d31:	89 c3                	mov    %eax,%ebx
  801d33:	85 c0                	test   %eax,%eax
  801d35:	79 0c                	jns    801d43 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  801d37:	89 34 24             	mov    %esi,(%esp)
  801d3a:	e8 51 02 00 00       	call   801f90 <nsipc_close>
		return r;
  801d3f:	89 d8                	mov    %ebx,%eax
  801d41:	eb 20                	jmp    801d63 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d43:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d4e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d51:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801d58:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801d5b:	89 14 24             	mov    %edx,(%esp)
  801d5e:	e8 3d f6 ff ff       	call   8013a0 <fd2num>
}
  801d63:	83 c4 20             	add    $0x20,%esp
  801d66:	5b                   	pop    %ebx
  801d67:	5e                   	pop    %esi
  801d68:	5d                   	pop    %ebp
  801d69:	c3                   	ret    

00801d6a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d6a:	55                   	push   %ebp
  801d6b:	89 e5                	mov    %esp,%ebp
  801d6d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d70:	8b 45 08             	mov    0x8(%ebp),%eax
  801d73:	e8 51 ff ff ff       	call   801cc9 <fd2sockid>
		return r;
  801d78:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d7a:	85 c0                	test   %eax,%eax
  801d7c:	78 23                	js     801da1 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d7e:	8b 55 10             	mov    0x10(%ebp),%edx
  801d81:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d85:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d88:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d8c:	89 04 24             	mov    %eax,(%esp)
  801d8f:	e8 45 01 00 00       	call   801ed9 <nsipc_accept>
		return r;
  801d94:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d96:	85 c0                	test   %eax,%eax
  801d98:	78 07                	js     801da1 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  801d9a:	e8 5c ff ff ff       	call   801cfb <alloc_sockfd>
  801d9f:	89 c1                	mov    %eax,%ecx
}
  801da1:	89 c8                	mov    %ecx,%eax
  801da3:	c9                   	leave  
  801da4:	c3                   	ret    

00801da5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801da5:	55                   	push   %ebp
  801da6:	89 e5                	mov    %esp,%ebp
  801da8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dab:	8b 45 08             	mov    0x8(%ebp),%eax
  801dae:	e8 16 ff ff ff       	call   801cc9 <fd2sockid>
  801db3:	89 c2                	mov    %eax,%edx
  801db5:	85 d2                	test   %edx,%edx
  801db7:	78 16                	js     801dcf <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  801db9:	8b 45 10             	mov    0x10(%ebp),%eax
  801dbc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dc0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dc7:	89 14 24             	mov    %edx,(%esp)
  801dca:	e8 60 01 00 00       	call   801f2f <nsipc_bind>
}
  801dcf:	c9                   	leave  
  801dd0:	c3                   	ret    

00801dd1 <shutdown>:

int
shutdown(int s, int how)
{
  801dd1:	55                   	push   %ebp
  801dd2:	89 e5                	mov    %esp,%ebp
  801dd4:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dd7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dda:	e8 ea fe ff ff       	call   801cc9 <fd2sockid>
  801ddf:	89 c2                	mov    %eax,%edx
  801de1:	85 d2                	test   %edx,%edx
  801de3:	78 0f                	js     801df4 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801de5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dec:	89 14 24             	mov    %edx,(%esp)
  801def:	e8 7a 01 00 00       	call   801f6e <nsipc_shutdown>
}
  801df4:	c9                   	leave  
  801df5:	c3                   	ret    

00801df6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801df6:	55                   	push   %ebp
  801df7:	89 e5                	mov    %esp,%ebp
  801df9:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dfc:	8b 45 08             	mov    0x8(%ebp),%eax
  801dff:	e8 c5 fe ff ff       	call   801cc9 <fd2sockid>
  801e04:	89 c2                	mov    %eax,%edx
  801e06:	85 d2                	test   %edx,%edx
  801e08:	78 16                	js     801e20 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  801e0a:	8b 45 10             	mov    0x10(%ebp),%eax
  801e0d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e11:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e14:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e18:	89 14 24             	mov    %edx,(%esp)
  801e1b:	e8 8a 01 00 00       	call   801faa <nsipc_connect>
}
  801e20:	c9                   	leave  
  801e21:	c3                   	ret    

00801e22 <listen>:

int
listen(int s, int backlog)
{
  801e22:	55                   	push   %ebp
  801e23:	89 e5                	mov    %esp,%ebp
  801e25:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e28:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2b:	e8 99 fe ff ff       	call   801cc9 <fd2sockid>
  801e30:	89 c2                	mov    %eax,%edx
  801e32:	85 d2                	test   %edx,%edx
  801e34:	78 0f                	js     801e45 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801e36:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e39:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e3d:	89 14 24             	mov    %edx,(%esp)
  801e40:	e8 a4 01 00 00       	call   801fe9 <nsipc_listen>
}
  801e45:	c9                   	leave  
  801e46:	c3                   	ret    

00801e47 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e47:	55                   	push   %ebp
  801e48:	89 e5                	mov    %esp,%ebp
  801e4a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e4d:	8b 45 10             	mov    0x10(%ebp),%eax
  801e50:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e54:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e57:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5e:	89 04 24             	mov    %eax,(%esp)
  801e61:	e8 98 02 00 00       	call   8020fe <nsipc_socket>
  801e66:	89 c2                	mov    %eax,%edx
  801e68:	85 d2                	test   %edx,%edx
  801e6a:	78 05                	js     801e71 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  801e6c:	e8 8a fe ff ff       	call   801cfb <alloc_sockfd>
}
  801e71:	c9                   	leave  
  801e72:	c3                   	ret    

00801e73 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e73:	55                   	push   %ebp
  801e74:	89 e5                	mov    %esp,%ebp
  801e76:	53                   	push   %ebx
  801e77:	83 ec 14             	sub    $0x14,%esp
  801e7a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801e7c:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801e83:	75 11                	jne    801e96 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e85:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801e8c:	e8 d4 f4 ff ff       	call   801365 <ipc_find_env>
  801e91:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801e96:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801e9d:	00 
  801e9e:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801ea5:	00 
  801ea6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801eaa:	a1 04 40 80 00       	mov    0x804004,%eax
  801eaf:	89 04 24             	mov    %eax,(%esp)
  801eb2:	e8 43 f4 ff ff       	call   8012fa <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801eb7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ebe:	00 
  801ebf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ec6:	00 
  801ec7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ece:	e8 ad f3 ff ff       	call   801280 <ipc_recv>
}
  801ed3:	83 c4 14             	add    $0x14,%esp
  801ed6:	5b                   	pop    %ebx
  801ed7:	5d                   	pop    %ebp
  801ed8:	c3                   	ret    

00801ed9 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	56                   	push   %esi
  801edd:	53                   	push   %ebx
  801ede:	83 ec 10             	sub    $0x10,%esp
  801ee1:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ee4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801eec:	8b 06                	mov    (%esi),%eax
  801eee:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ef3:	b8 01 00 00 00       	mov    $0x1,%eax
  801ef8:	e8 76 ff ff ff       	call   801e73 <nsipc>
  801efd:	89 c3                	mov    %eax,%ebx
  801eff:	85 c0                	test   %eax,%eax
  801f01:	78 23                	js     801f26 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f03:	a1 10 60 80 00       	mov    0x806010,%eax
  801f08:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f0c:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801f13:	00 
  801f14:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f17:	89 04 24             	mov    %eax,(%esp)
  801f1a:	e8 a5 ea ff ff       	call   8009c4 <memmove>
		*addrlen = ret->ret_addrlen;
  801f1f:	a1 10 60 80 00       	mov    0x806010,%eax
  801f24:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801f26:	89 d8                	mov    %ebx,%eax
  801f28:	83 c4 10             	add    $0x10,%esp
  801f2b:	5b                   	pop    %ebx
  801f2c:	5e                   	pop    %esi
  801f2d:	5d                   	pop    %ebp
  801f2e:	c3                   	ret    

00801f2f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f2f:	55                   	push   %ebp
  801f30:	89 e5                	mov    %esp,%ebp
  801f32:	53                   	push   %ebx
  801f33:	83 ec 14             	sub    $0x14,%esp
  801f36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f39:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f41:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f45:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f48:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f4c:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801f53:	e8 6c ea ff ff       	call   8009c4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f58:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801f5e:	b8 02 00 00 00       	mov    $0x2,%eax
  801f63:	e8 0b ff ff ff       	call   801e73 <nsipc>
}
  801f68:	83 c4 14             	add    $0x14,%esp
  801f6b:	5b                   	pop    %ebx
  801f6c:	5d                   	pop    %ebp
  801f6d:	c3                   	ret    

00801f6e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f6e:	55                   	push   %ebp
  801f6f:	89 e5                	mov    %esp,%ebp
  801f71:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f74:	8b 45 08             	mov    0x8(%ebp),%eax
  801f77:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801f7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f7f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801f84:	b8 03 00 00 00       	mov    $0x3,%eax
  801f89:	e8 e5 fe ff ff       	call   801e73 <nsipc>
}
  801f8e:	c9                   	leave  
  801f8f:	c3                   	ret    

00801f90 <nsipc_close>:

int
nsipc_close(int s)
{
  801f90:	55                   	push   %ebp
  801f91:	89 e5                	mov    %esp,%ebp
  801f93:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801f96:	8b 45 08             	mov    0x8(%ebp),%eax
  801f99:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801f9e:	b8 04 00 00 00       	mov    $0x4,%eax
  801fa3:	e8 cb fe ff ff       	call   801e73 <nsipc>
}
  801fa8:	c9                   	leave  
  801fa9:	c3                   	ret    

00801faa <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801faa:	55                   	push   %ebp
  801fab:	89 e5                	mov    %esp,%ebp
  801fad:	53                   	push   %ebx
  801fae:	83 ec 14             	sub    $0x14,%esp
  801fb1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801fb4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb7:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801fbc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fc0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fc7:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801fce:	e8 f1 e9 ff ff       	call   8009c4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801fd3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801fd9:	b8 05 00 00 00       	mov    $0x5,%eax
  801fde:	e8 90 fe ff ff       	call   801e73 <nsipc>
}
  801fe3:	83 c4 14             	add    $0x14,%esp
  801fe6:	5b                   	pop    %ebx
  801fe7:	5d                   	pop    %ebp
  801fe8:	c3                   	ret    

00801fe9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801fe9:	55                   	push   %ebp
  801fea:	89 e5                	mov    %esp,%ebp
  801fec:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801fef:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801ff7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ffa:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801fff:	b8 06 00 00 00       	mov    $0x6,%eax
  802004:	e8 6a fe ff ff       	call   801e73 <nsipc>
}
  802009:	c9                   	leave  
  80200a:	c3                   	ret    

0080200b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80200b:	55                   	push   %ebp
  80200c:	89 e5                	mov    %esp,%ebp
  80200e:	56                   	push   %esi
  80200f:	53                   	push   %ebx
  802010:	83 ec 10             	sub    $0x10,%esp
  802013:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802016:	8b 45 08             	mov    0x8(%ebp),%eax
  802019:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80201e:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  802024:	8b 45 14             	mov    0x14(%ebp),%eax
  802027:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80202c:	b8 07 00 00 00       	mov    $0x7,%eax
  802031:	e8 3d fe ff ff       	call   801e73 <nsipc>
  802036:	89 c3                	mov    %eax,%ebx
  802038:	85 c0                	test   %eax,%eax
  80203a:	78 46                	js     802082 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  80203c:	39 f0                	cmp    %esi,%eax
  80203e:	7f 07                	jg     802047 <nsipc_recv+0x3c>
  802040:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802045:	7e 24                	jle    80206b <nsipc_recv+0x60>
  802047:	c7 44 24 0c ef 2e 80 	movl   $0x802eef,0xc(%esp)
  80204e:	00 
  80204f:	c7 44 24 08 b7 2e 80 	movl   $0x802eb7,0x8(%esp)
  802056:	00 
  802057:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80205e:	00 
  80205f:	c7 04 24 04 2f 80 00 	movl   $0x802f04,(%esp)
  802066:	e8 eb 05 00 00       	call   802656 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80206b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80206f:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802076:	00 
  802077:	8b 45 0c             	mov    0xc(%ebp),%eax
  80207a:	89 04 24             	mov    %eax,(%esp)
  80207d:	e8 42 e9 ff ff       	call   8009c4 <memmove>
	}

	return r;
}
  802082:	89 d8                	mov    %ebx,%eax
  802084:	83 c4 10             	add    $0x10,%esp
  802087:	5b                   	pop    %ebx
  802088:	5e                   	pop    %esi
  802089:	5d                   	pop    %ebp
  80208a:	c3                   	ret    

0080208b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80208b:	55                   	push   %ebp
  80208c:	89 e5                	mov    %esp,%ebp
  80208e:	53                   	push   %ebx
  80208f:	83 ec 14             	sub    $0x14,%esp
  802092:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802095:	8b 45 08             	mov    0x8(%ebp),%eax
  802098:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80209d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8020a3:	7e 24                	jle    8020c9 <nsipc_send+0x3e>
  8020a5:	c7 44 24 0c 10 2f 80 	movl   $0x802f10,0xc(%esp)
  8020ac:	00 
  8020ad:	c7 44 24 08 b7 2e 80 	movl   $0x802eb7,0x8(%esp)
  8020b4:	00 
  8020b5:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8020bc:	00 
  8020bd:	c7 04 24 04 2f 80 00 	movl   $0x802f04,(%esp)
  8020c4:	e8 8d 05 00 00       	call   802656 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8020c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d4:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  8020db:	e8 e4 e8 ff ff       	call   8009c4 <memmove>
	nsipcbuf.send.req_size = size;
  8020e0:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8020e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8020e9:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8020ee:	b8 08 00 00 00       	mov    $0x8,%eax
  8020f3:	e8 7b fd ff ff       	call   801e73 <nsipc>
}
  8020f8:	83 c4 14             	add    $0x14,%esp
  8020fb:	5b                   	pop    %ebx
  8020fc:	5d                   	pop    %ebp
  8020fd:	c3                   	ret    

008020fe <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8020fe:	55                   	push   %ebp
  8020ff:	89 e5                	mov    %esp,%ebp
  802101:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802104:	8b 45 08             	mov    0x8(%ebp),%eax
  802107:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80210c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80210f:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802114:	8b 45 10             	mov    0x10(%ebp),%eax
  802117:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80211c:	b8 09 00 00 00       	mov    $0x9,%eax
  802121:	e8 4d fd ff ff       	call   801e73 <nsipc>
}
  802126:	c9                   	leave  
  802127:	c3                   	ret    

00802128 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802128:	55                   	push   %ebp
  802129:	89 e5                	mov    %esp,%ebp
  80212b:	56                   	push   %esi
  80212c:	53                   	push   %ebx
  80212d:	83 ec 10             	sub    $0x10,%esp
  802130:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802133:	8b 45 08             	mov    0x8(%ebp),%eax
  802136:	89 04 24             	mov    %eax,(%esp)
  802139:	e8 72 f2 ff ff       	call   8013b0 <fd2data>
  80213e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802140:	c7 44 24 04 1c 2f 80 	movl   $0x802f1c,0x4(%esp)
  802147:	00 
  802148:	89 1c 24             	mov    %ebx,(%esp)
  80214b:	e8 d7 e6 ff ff       	call   800827 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802150:	8b 46 04             	mov    0x4(%esi),%eax
  802153:	2b 06                	sub    (%esi),%eax
  802155:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80215b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802162:	00 00 00 
	stat->st_dev = &devpipe;
  802165:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80216c:	30 80 00 
	return 0;
}
  80216f:	b8 00 00 00 00       	mov    $0x0,%eax
  802174:	83 c4 10             	add    $0x10,%esp
  802177:	5b                   	pop    %ebx
  802178:	5e                   	pop    %esi
  802179:	5d                   	pop    %ebp
  80217a:	c3                   	ret    

0080217b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80217b:	55                   	push   %ebp
  80217c:	89 e5                	mov    %esp,%ebp
  80217e:	53                   	push   %ebx
  80217f:	83 ec 14             	sub    $0x14,%esp
  802182:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802185:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802189:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802190:	e8 55 eb ff ff       	call   800cea <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802195:	89 1c 24             	mov    %ebx,(%esp)
  802198:	e8 13 f2 ff ff       	call   8013b0 <fd2data>
  80219d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021a8:	e8 3d eb ff ff       	call   800cea <sys_page_unmap>
}
  8021ad:	83 c4 14             	add    $0x14,%esp
  8021b0:	5b                   	pop    %ebx
  8021b1:	5d                   	pop    %ebp
  8021b2:	c3                   	ret    

008021b3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8021b3:	55                   	push   %ebp
  8021b4:	89 e5                	mov    %esp,%ebp
  8021b6:	57                   	push   %edi
  8021b7:	56                   	push   %esi
  8021b8:	53                   	push   %ebx
  8021b9:	83 ec 2c             	sub    $0x2c,%esp
  8021bc:	89 c6                	mov    %eax,%esi
  8021be:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8021c1:	a1 08 40 80 00       	mov    0x804008,%eax
  8021c6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8021c9:	89 34 24             	mov    %esi,(%esp)
  8021cc:	e8 4c 05 00 00       	call   80271d <pageref>
  8021d1:	89 c7                	mov    %eax,%edi
  8021d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021d6:	89 04 24             	mov    %eax,(%esp)
  8021d9:	e8 3f 05 00 00       	call   80271d <pageref>
  8021de:	39 c7                	cmp    %eax,%edi
  8021e0:	0f 94 c2             	sete   %dl
  8021e3:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8021e6:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  8021ec:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8021ef:	39 fb                	cmp    %edi,%ebx
  8021f1:	74 21                	je     802214 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8021f3:	84 d2                	test   %dl,%dl
  8021f5:	74 ca                	je     8021c1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8021f7:	8b 51 58             	mov    0x58(%ecx),%edx
  8021fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021fe:	89 54 24 08          	mov    %edx,0x8(%esp)
  802202:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802206:	c7 04 24 23 2f 80 00 	movl   $0x802f23,(%esp)
  80220d:	e8 ed df ff ff       	call   8001ff <cprintf>
  802212:	eb ad                	jmp    8021c1 <_pipeisclosed+0xe>
	}
}
  802214:	83 c4 2c             	add    $0x2c,%esp
  802217:	5b                   	pop    %ebx
  802218:	5e                   	pop    %esi
  802219:	5f                   	pop    %edi
  80221a:	5d                   	pop    %ebp
  80221b:	c3                   	ret    

0080221c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80221c:	55                   	push   %ebp
  80221d:	89 e5                	mov    %esp,%ebp
  80221f:	57                   	push   %edi
  802220:	56                   	push   %esi
  802221:	53                   	push   %ebx
  802222:	83 ec 1c             	sub    $0x1c,%esp
  802225:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802228:	89 34 24             	mov    %esi,(%esp)
  80222b:	e8 80 f1 ff ff       	call   8013b0 <fd2data>
  802230:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802232:	bf 00 00 00 00       	mov    $0x0,%edi
  802237:	eb 45                	jmp    80227e <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802239:	89 da                	mov    %ebx,%edx
  80223b:	89 f0                	mov    %esi,%eax
  80223d:	e8 71 ff ff ff       	call   8021b3 <_pipeisclosed>
  802242:	85 c0                	test   %eax,%eax
  802244:	75 41                	jne    802287 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802246:	e8 d9 e9 ff ff       	call   800c24 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80224b:	8b 43 04             	mov    0x4(%ebx),%eax
  80224e:	8b 0b                	mov    (%ebx),%ecx
  802250:	8d 51 20             	lea    0x20(%ecx),%edx
  802253:	39 d0                	cmp    %edx,%eax
  802255:	73 e2                	jae    802239 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802257:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80225a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80225e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802261:	99                   	cltd   
  802262:	c1 ea 1b             	shr    $0x1b,%edx
  802265:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802268:	83 e1 1f             	and    $0x1f,%ecx
  80226b:	29 d1                	sub    %edx,%ecx
  80226d:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  802271:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  802275:	83 c0 01             	add    $0x1,%eax
  802278:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80227b:	83 c7 01             	add    $0x1,%edi
  80227e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802281:	75 c8                	jne    80224b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802283:	89 f8                	mov    %edi,%eax
  802285:	eb 05                	jmp    80228c <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802287:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80228c:	83 c4 1c             	add    $0x1c,%esp
  80228f:	5b                   	pop    %ebx
  802290:	5e                   	pop    %esi
  802291:	5f                   	pop    %edi
  802292:	5d                   	pop    %ebp
  802293:	c3                   	ret    

00802294 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802294:	55                   	push   %ebp
  802295:	89 e5                	mov    %esp,%ebp
  802297:	57                   	push   %edi
  802298:	56                   	push   %esi
  802299:	53                   	push   %ebx
  80229a:	83 ec 1c             	sub    $0x1c,%esp
  80229d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8022a0:	89 3c 24             	mov    %edi,(%esp)
  8022a3:	e8 08 f1 ff ff       	call   8013b0 <fd2data>
  8022a8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022aa:	be 00 00 00 00       	mov    $0x0,%esi
  8022af:	eb 3d                	jmp    8022ee <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8022b1:	85 f6                	test   %esi,%esi
  8022b3:	74 04                	je     8022b9 <devpipe_read+0x25>
				return i;
  8022b5:	89 f0                	mov    %esi,%eax
  8022b7:	eb 43                	jmp    8022fc <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8022b9:	89 da                	mov    %ebx,%edx
  8022bb:	89 f8                	mov    %edi,%eax
  8022bd:	e8 f1 fe ff ff       	call   8021b3 <_pipeisclosed>
  8022c2:	85 c0                	test   %eax,%eax
  8022c4:	75 31                	jne    8022f7 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8022c6:	e8 59 e9 ff ff       	call   800c24 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8022cb:	8b 03                	mov    (%ebx),%eax
  8022cd:	3b 43 04             	cmp    0x4(%ebx),%eax
  8022d0:	74 df                	je     8022b1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8022d2:	99                   	cltd   
  8022d3:	c1 ea 1b             	shr    $0x1b,%edx
  8022d6:	01 d0                	add    %edx,%eax
  8022d8:	83 e0 1f             	and    $0x1f,%eax
  8022db:	29 d0                	sub    %edx,%eax
  8022dd:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8022e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022e5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8022e8:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022eb:	83 c6 01             	add    $0x1,%esi
  8022ee:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022f1:	75 d8                	jne    8022cb <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8022f3:	89 f0                	mov    %esi,%eax
  8022f5:	eb 05                	jmp    8022fc <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022f7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8022fc:	83 c4 1c             	add    $0x1c,%esp
  8022ff:	5b                   	pop    %ebx
  802300:	5e                   	pop    %esi
  802301:	5f                   	pop    %edi
  802302:	5d                   	pop    %ebp
  802303:	c3                   	ret    

00802304 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802304:	55                   	push   %ebp
  802305:	89 e5                	mov    %esp,%ebp
  802307:	56                   	push   %esi
  802308:	53                   	push   %ebx
  802309:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80230c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80230f:	89 04 24             	mov    %eax,(%esp)
  802312:	e8 b0 f0 ff ff       	call   8013c7 <fd_alloc>
  802317:	89 c2                	mov    %eax,%edx
  802319:	85 d2                	test   %edx,%edx
  80231b:	0f 88 4d 01 00 00    	js     80246e <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802321:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802328:	00 
  802329:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80232c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802330:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802337:	e8 07 e9 ff ff       	call   800c43 <sys_page_alloc>
  80233c:	89 c2                	mov    %eax,%edx
  80233e:	85 d2                	test   %edx,%edx
  802340:	0f 88 28 01 00 00    	js     80246e <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802346:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802349:	89 04 24             	mov    %eax,(%esp)
  80234c:	e8 76 f0 ff ff       	call   8013c7 <fd_alloc>
  802351:	89 c3                	mov    %eax,%ebx
  802353:	85 c0                	test   %eax,%eax
  802355:	0f 88 fe 00 00 00    	js     802459 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80235b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802362:	00 
  802363:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802366:	89 44 24 04          	mov    %eax,0x4(%esp)
  80236a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802371:	e8 cd e8 ff ff       	call   800c43 <sys_page_alloc>
  802376:	89 c3                	mov    %eax,%ebx
  802378:	85 c0                	test   %eax,%eax
  80237a:	0f 88 d9 00 00 00    	js     802459 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802380:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802383:	89 04 24             	mov    %eax,(%esp)
  802386:	e8 25 f0 ff ff       	call   8013b0 <fd2data>
  80238b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80238d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802394:	00 
  802395:	89 44 24 04          	mov    %eax,0x4(%esp)
  802399:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023a0:	e8 9e e8 ff ff       	call   800c43 <sys_page_alloc>
  8023a5:	89 c3                	mov    %eax,%ebx
  8023a7:	85 c0                	test   %eax,%eax
  8023a9:	0f 88 97 00 00 00    	js     802446 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023b2:	89 04 24             	mov    %eax,(%esp)
  8023b5:	e8 f6 ef ff ff       	call   8013b0 <fd2data>
  8023ba:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8023c1:	00 
  8023c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023c6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8023cd:	00 
  8023ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023d9:	e8 b9 e8 ff ff       	call   800c97 <sys_page_map>
  8023de:	89 c3                	mov    %eax,%ebx
  8023e0:	85 c0                	test   %eax,%eax
  8023e2:	78 52                	js     802436 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8023e4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8023ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ed:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8023ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023f2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8023f9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8023ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802402:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802404:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802407:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80240e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802411:	89 04 24             	mov    %eax,(%esp)
  802414:	e8 87 ef ff ff       	call   8013a0 <fd2num>
  802419:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80241c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80241e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802421:	89 04 24             	mov    %eax,(%esp)
  802424:	e8 77 ef ff ff       	call   8013a0 <fd2num>
  802429:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80242c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80242f:	b8 00 00 00 00       	mov    $0x0,%eax
  802434:	eb 38                	jmp    80246e <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  802436:	89 74 24 04          	mov    %esi,0x4(%esp)
  80243a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802441:	e8 a4 e8 ff ff       	call   800cea <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802446:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802449:	89 44 24 04          	mov    %eax,0x4(%esp)
  80244d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802454:	e8 91 e8 ff ff       	call   800cea <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802459:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80245c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802460:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802467:	e8 7e e8 ff ff       	call   800cea <sys_page_unmap>
  80246c:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  80246e:	83 c4 30             	add    $0x30,%esp
  802471:	5b                   	pop    %ebx
  802472:	5e                   	pop    %esi
  802473:	5d                   	pop    %ebp
  802474:	c3                   	ret    

00802475 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802475:	55                   	push   %ebp
  802476:	89 e5                	mov    %esp,%ebp
  802478:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80247b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80247e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802482:	8b 45 08             	mov    0x8(%ebp),%eax
  802485:	89 04 24             	mov    %eax,(%esp)
  802488:	e8 89 ef ff ff       	call   801416 <fd_lookup>
  80248d:	89 c2                	mov    %eax,%edx
  80248f:	85 d2                	test   %edx,%edx
  802491:	78 15                	js     8024a8 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802493:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802496:	89 04 24             	mov    %eax,(%esp)
  802499:	e8 12 ef ff ff       	call   8013b0 <fd2data>
	return _pipeisclosed(fd, p);
  80249e:	89 c2                	mov    %eax,%edx
  8024a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024a3:	e8 0b fd ff ff       	call   8021b3 <_pipeisclosed>
}
  8024a8:	c9                   	leave  
  8024a9:	c3                   	ret    
  8024aa:	66 90                	xchg   %ax,%ax
  8024ac:	66 90                	xchg   %ax,%ax
  8024ae:	66 90                	xchg   %ax,%ax

008024b0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8024b0:	55                   	push   %ebp
  8024b1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8024b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8024b8:	5d                   	pop    %ebp
  8024b9:	c3                   	ret    

008024ba <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8024ba:	55                   	push   %ebp
  8024bb:	89 e5                	mov    %esp,%ebp
  8024bd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8024c0:	c7 44 24 04 3b 2f 80 	movl   $0x802f3b,0x4(%esp)
  8024c7:	00 
  8024c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024cb:	89 04 24             	mov    %eax,(%esp)
  8024ce:	e8 54 e3 ff ff       	call   800827 <strcpy>
	return 0;
}
  8024d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8024d8:	c9                   	leave  
  8024d9:	c3                   	ret    

008024da <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8024da:	55                   	push   %ebp
  8024db:	89 e5                	mov    %esp,%ebp
  8024dd:	57                   	push   %edi
  8024de:	56                   	push   %esi
  8024df:	53                   	push   %ebx
  8024e0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024e6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8024eb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024f1:	eb 31                	jmp    802524 <devcons_write+0x4a>
		m = n - tot;
  8024f3:	8b 75 10             	mov    0x10(%ebp),%esi
  8024f6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8024f8:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8024fb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802500:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802503:	89 74 24 08          	mov    %esi,0x8(%esp)
  802507:	03 45 0c             	add    0xc(%ebp),%eax
  80250a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80250e:	89 3c 24             	mov    %edi,(%esp)
  802511:	e8 ae e4 ff ff       	call   8009c4 <memmove>
		sys_cputs(buf, m);
  802516:	89 74 24 04          	mov    %esi,0x4(%esp)
  80251a:	89 3c 24             	mov    %edi,(%esp)
  80251d:	e8 54 e6 ff ff       	call   800b76 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802522:	01 f3                	add    %esi,%ebx
  802524:	89 d8                	mov    %ebx,%eax
  802526:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802529:	72 c8                	jb     8024f3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80252b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802531:	5b                   	pop    %ebx
  802532:	5e                   	pop    %esi
  802533:	5f                   	pop    %edi
  802534:	5d                   	pop    %ebp
  802535:	c3                   	ret    

00802536 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802536:	55                   	push   %ebp
  802537:	89 e5                	mov    %esp,%ebp
  802539:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80253c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802541:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802545:	75 07                	jne    80254e <devcons_read+0x18>
  802547:	eb 2a                	jmp    802573 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802549:	e8 d6 e6 ff ff       	call   800c24 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80254e:	66 90                	xchg   %ax,%ax
  802550:	e8 3f e6 ff ff       	call   800b94 <sys_cgetc>
  802555:	85 c0                	test   %eax,%eax
  802557:	74 f0                	je     802549 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802559:	85 c0                	test   %eax,%eax
  80255b:	78 16                	js     802573 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80255d:	83 f8 04             	cmp    $0x4,%eax
  802560:	74 0c                	je     80256e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802562:	8b 55 0c             	mov    0xc(%ebp),%edx
  802565:	88 02                	mov    %al,(%edx)
	return 1;
  802567:	b8 01 00 00 00       	mov    $0x1,%eax
  80256c:	eb 05                	jmp    802573 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80256e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802573:	c9                   	leave  
  802574:	c3                   	ret    

00802575 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802575:	55                   	push   %ebp
  802576:	89 e5                	mov    %esp,%ebp
  802578:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80257b:	8b 45 08             	mov    0x8(%ebp),%eax
  80257e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802581:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802588:	00 
  802589:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80258c:	89 04 24             	mov    %eax,(%esp)
  80258f:	e8 e2 e5 ff ff       	call   800b76 <sys_cputs>
}
  802594:	c9                   	leave  
  802595:	c3                   	ret    

00802596 <getchar>:

int
getchar(void)
{
  802596:	55                   	push   %ebp
  802597:	89 e5                	mov    %esp,%ebp
  802599:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80259c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8025a3:	00 
  8025a4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8025a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025b2:	e8 f3 f0 ff ff       	call   8016aa <read>
	if (r < 0)
  8025b7:	85 c0                	test   %eax,%eax
  8025b9:	78 0f                	js     8025ca <getchar+0x34>
		return r;
	if (r < 1)
  8025bb:	85 c0                	test   %eax,%eax
  8025bd:	7e 06                	jle    8025c5 <getchar+0x2f>
		return -E_EOF;
	return c;
  8025bf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8025c3:	eb 05                	jmp    8025ca <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8025c5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8025ca:	c9                   	leave  
  8025cb:	c3                   	ret    

008025cc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8025cc:	55                   	push   %ebp
  8025cd:	89 e5                	mov    %esp,%ebp
  8025cf:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8025dc:	89 04 24             	mov    %eax,(%esp)
  8025df:	e8 32 ee ff ff       	call   801416 <fd_lookup>
  8025e4:	85 c0                	test   %eax,%eax
  8025e6:	78 11                	js     8025f9 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8025e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025eb:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8025f1:	39 10                	cmp    %edx,(%eax)
  8025f3:	0f 94 c0             	sete   %al
  8025f6:	0f b6 c0             	movzbl %al,%eax
}
  8025f9:	c9                   	leave  
  8025fa:	c3                   	ret    

008025fb <opencons>:

int
opencons(void)
{
  8025fb:	55                   	push   %ebp
  8025fc:	89 e5                	mov    %esp,%ebp
  8025fe:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802601:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802604:	89 04 24             	mov    %eax,(%esp)
  802607:	e8 bb ed ff ff       	call   8013c7 <fd_alloc>
		return r;
  80260c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80260e:	85 c0                	test   %eax,%eax
  802610:	78 40                	js     802652 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802612:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802619:	00 
  80261a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80261d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802621:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802628:	e8 16 e6 ff ff       	call   800c43 <sys_page_alloc>
		return r;
  80262d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80262f:	85 c0                	test   %eax,%eax
  802631:	78 1f                	js     802652 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802633:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802639:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80263c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80263e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802641:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802648:	89 04 24             	mov    %eax,(%esp)
  80264b:	e8 50 ed ff ff       	call   8013a0 <fd2num>
  802650:	89 c2                	mov    %eax,%edx
}
  802652:	89 d0                	mov    %edx,%eax
  802654:	c9                   	leave  
  802655:	c3                   	ret    

00802656 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802656:	55                   	push   %ebp
  802657:	89 e5                	mov    %esp,%ebp
  802659:	56                   	push   %esi
  80265a:	53                   	push   %ebx
  80265b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80265e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802661:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802667:	e8 99 e5 ff ff       	call   800c05 <sys_getenvid>
  80266c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80266f:	89 54 24 10          	mov    %edx,0x10(%esp)
  802673:	8b 55 08             	mov    0x8(%ebp),%edx
  802676:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80267a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80267e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802682:	c7 04 24 48 2f 80 00 	movl   $0x802f48,(%esp)
  802689:	e8 71 db ff ff       	call   8001ff <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80268e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802692:	8b 45 10             	mov    0x10(%ebp),%eax
  802695:	89 04 24             	mov    %eax,(%esp)
  802698:	e8 01 db ff ff       	call   80019e <vcprintf>
	cprintf("\n");
  80269d:	c7 04 24 34 2f 80 00 	movl   $0x802f34,(%esp)
  8026a4:	e8 56 db ff ff       	call   8001ff <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8026a9:	cc                   	int3   
  8026aa:	eb fd                	jmp    8026a9 <_panic+0x53>

008026ac <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8026ac:	55                   	push   %ebp
  8026ad:	89 e5                	mov    %esp,%ebp
  8026af:	53                   	push   %ebx
  8026b0:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  8026b3:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8026ba:	75 2f                	jne    8026eb <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  8026bc:	e8 44 e5 ff ff       	call   800c05 <sys_getenvid>
  8026c1:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P);
  8026c3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8026ca:	00 
  8026cb:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8026d2:	ee 
  8026d3:	89 04 24             	mov    %eax,(%esp)
  8026d6:	e8 68 e5 ff ff       	call   800c43 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *)_pgfault_upcall);
  8026db:	c7 44 24 04 f9 26 80 	movl   $0x8026f9,0x4(%esp)
  8026e2:	00 
  8026e3:	89 1c 24             	mov    %ebx,(%esp)
  8026e6:	e8 f8 e6 ff ff       	call   800de3 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8026eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8026ee:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8026f3:	83 c4 14             	add    $0x14,%esp
  8026f6:	5b                   	pop    %ebx
  8026f7:	5d                   	pop    %ebp
  8026f8:	c3                   	ret    

008026f9 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8026f9:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8026fa:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8026ff:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802701:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	// 0x30(%esp) points to trap-time stack pointer
	// 0x28(%esp) points to trap-time eip
	subl $4, 0x30(%esp)
  802704:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax 
  802709:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebp
  80270d:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %ebp, (%eax)
  802711:	89 28                	mov    %ebp,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  802713:	83 c4 08             	add    $0x8,%esp
	popal
  802716:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp //pop eip - we already stored it
  802717:	83 c4 04             	add    $0x4,%esp
	popfl
  80271a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80271b:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80271c:	c3                   	ret    

0080271d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80271d:	55                   	push   %ebp
  80271e:	89 e5                	mov    %esp,%ebp
  802720:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802723:	89 d0                	mov    %edx,%eax
  802725:	c1 e8 16             	shr    $0x16,%eax
  802728:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80272f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802734:	f6 c1 01             	test   $0x1,%cl
  802737:	74 1d                	je     802756 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802739:	c1 ea 0c             	shr    $0xc,%edx
  80273c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802743:	f6 c2 01             	test   $0x1,%dl
  802746:	74 0e                	je     802756 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802748:	c1 ea 0c             	shr    $0xc,%edx
  80274b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802752:	ef 
  802753:	0f b7 c0             	movzwl %ax,%eax
}
  802756:	5d                   	pop    %ebp
  802757:	c3                   	ret    
  802758:	66 90                	xchg   %ax,%ax
  80275a:	66 90                	xchg   %ax,%ax
  80275c:	66 90                	xchg   %ax,%ax
  80275e:	66 90                	xchg   %ax,%ax

00802760 <__udivdi3>:
  802760:	55                   	push   %ebp
  802761:	57                   	push   %edi
  802762:	56                   	push   %esi
  802763:	83 ec 0c             	sub    $0xc,%esp
  802766:	8b 44 24 28          	mov    0x28(%esp),%eax
  80276a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80276e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802772:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802776:	85 c0                	test   %eax,%eax
  802778:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80277c:	89 ea                	mov    %ebp,%edx
  80277e:	89 0c 24             	mov    %ecx,(%esp)
  802781:	75 2d                	jne    8027b0 <__udivdi3+0x50>
  802783:	39 e9                	cmp    %ebp,%ecx
  802785:	77 61                	ja     8027e8 <__udivdi3+0x88>
  802787:	85 c9                	test   %ecx,%ecx
  802789:	89 ce                	mov    %ecx,%esi
  80278b:	75 0b                	jne    802798 <__udivdi3+0x38>
  80278d:	b8 01 00 00 00       	mov    $0x1,%eax
  802792:	31 d2                	xor    %edx,%edx
  802794:	f7 f1                	div    %ecx
  802796:	89 c6                	mov    %eax,%esi
  802798:	31 d2                	xor    %edx,%edx
  80279a:	89 e8                	mov    %ebp,%eax
  80279c:	f7 f6                	div    %esi
  80279e:	89 c5                	mov    %eax,%ebp
  8027a0:	89 f8                	mov    %edi,%eax
  8027a2:	f7 f6                	div    %esi
  8027a4:	89 ea                	mov    %ebp,%edx
  8027a6:	83 c4 0c             	add    $0xc,%esp
  8027a9:	5e                   	pop    %esi
  8027aa:	5f                   	pop    %edi
  8027ab:	5d                   	pop    %ebp
  8027ac:	c3                   	ret    
  8027ad:	8d 76 00             	lea    0x0(%esi),%esi
  8027b0:	39 e8                	cmp    %ebp,%eax
  8027b2:	77 24                	ja     8027d8 <__udivdi3+0x78>
  8027b4:	0f bd e8             	bsr    %eax,%ebp
  8027b7:	83 f5 1f             	xor    $0x1f,%ebp
  8027ba:	75 3c                	jne    8027f8 <__udivdi3+0x98>
  8027bc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8027c0:	39 34 24             	cmp    %esi,(%esp)
  8027c3:	0f 86 9f 00 00 00    	jbe    802868 <__udivdi3+0x108>
  8027c9:	39 d0                	cmp    %edx,%eax
  8027cb:	0f 82 97 00 00 00    	jb     802868 <__udivdi3+0x108>
  8027d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027d8:	31 d2                	xor    %edx,%edx
  8027da:	31 c0                	xor    %eax,%eax
  8027dc:	83 c4 0c             	add    $0xc,%esp
  8027df:	5e                   	pop    %esi
  8027e0:	5f                   	pop    %edi
  8027e1:	5d                   	pop    %ebp
  8027e2:	c3                   	ret    
  8027e3:	90                   	nop
  8027e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027e8:	89 f8                	mov    %edi,%eax
  8027ea:	f7 f1                	div    %ecx
  8027ec:	31 d2                	xor    %edx,%edx
  8027ee:	83 c4 0c             	add    $0xc,%esp
  8027f1:	5e                   	pop    %esi
  8027f2:	5f                   	pop    %edi
  8027f3:	5d                   	pop    %ebp
  8027f4:	c3                   	ret    
  8027f5:	8d 76 00             	lea    0x0(%esi),%esi
  8027f8:	89 e9                	mov    %ebp,%ecx
  8027fa:	8b 3c 24             	mov    (%esp),%edi
  8027fd:	d3 e0                	shl    %cl,%eax
  8027ff:	89 c6                	mov    %eax,%esi
  802801:	b8 20 00 00 00       	mov    $0x20,%eax
  802806:	29 e8                	sub    %ebp,%eax
  802808:	89 c1                	mov    %eax,%ecx
  80280a:	d3 ef                	shr    %cl,%edi
  80280c:	89 e9                	mov    %ebp,%ecx
  80280e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802812:	8b 3c 24             	mov    (%esp),%edi
  802815:	09 74 24 08          	or     %esi,0x8(%esp)
  802819:	89 d6                	mov    %edx,%esi
  80281b:	d3 e7                	shl    %cl,%edi
  80281d:	89 c1                	mov    %eax,%ecx
  80281f:	89 3c 24             	mov    %edi,(%esp)
  802822:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802826:	d3 ee                	shr    %cl,%esi
  802828:	89 e9                	mov    %ebp,%ecx
  80282a:	d3 e2                	shl    %cl,%edx
  80282c:	89 c1                	mov    %eax,%ecx
  80282e:	d3 ef                	shr    %cl,%edi
  802830:	09 d7                	or     %edx,%edi
  802832:	89 f2                	mov    %esi,%edx
  802834:	89 f8                	mov    %edi,%eax
  802836:	f7 74 24 08          	divl   0x8(%esp)
  80283a:	89 d6                	mov    %edx,%esi
  80283c:	89 c7                	mov    %eax,%edi
  80283e:	f7 24 24             	mull   (%esp)
  802841:	39 d6                	cmp    %edx,%esi
  802843:	89 14 24             	mov    %edx,(%esp)
  802846:	72 30                	jb     802878 <__udivdi3+0x118>
  802848:	8b 54 24 04          	mov    0x4(%esp),%edx
  80284c:	89 e9                	mov    %ebp,%ecx
  80284e:	d3 e2                	shl    %cl,%edx
  802850:	39 c2                	cmp    %eax,%edx
  802852:	73 05                	jae    802859 <__udivdi3+0xf9>
  802854:	3b 34 24             	cmp    (%esp),%esi
  802857:	74 1f                	je     802878 <__udivdi3+0x118>
  802859:	89 f8                	mov    %edi,%eax
  80285b:	31 d2                	xor    %edx,%edx
  80285d:	e9 7a ff ff ff       	jmp    8027dc <__udivdi3+0x7c>
  802862:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802868:	31 d2                	xor    %edx,%edx
  80286a:	b8 01 00 00 00       	mov    $0x1,%eax
  80286f:	e9 68 ff ff ff       	jmp    8027dc <__udivdi3+0x7c>
  802874:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802878:	8d 47 ff             	lea    -0x1(%edi),%eax
  80287b:	31 d2                	xor    %edx,%edx
  80287d:	83 c4 0c             	add    $0xc,%esp
  802880:	5e                   	pop    %esi
  802881:	5f                   	pop    %edi
  802882:	5d                   	pop    %ebp
  802883:	c3                   	ret    
  802884:	66 90                	xchg   %ax,%ax
  802886:	66 90                	xchg   %ax,%ax
  802888:	66 90                	xchg   %ax,%ax
  80288a:	66 90                	xchg   %ax,%ax
  80288c:	66 90                	xchg   %ax,%ax
  80288e:	66 90                	xchg   %ax,%ax

00802890 <__umoddi3>:
  802890:	55                   	push   %ebp
  802891:	57                   	push   %edi
  802892:	56                   	push   %esi
  802893:	83 ec 14             	sub    $0x14,%esp
  802896:	8b 44 24 28          	mov    0x28(%esp),%eax
  80289a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80289e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8028a2:	89 c7                	mov    %eax,%edi
  8028a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028a8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8028ac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8028b0:	89 34 24             	mov    %esi,(%esp)
  8028b3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028b7:	85 c0                	test   %eax,%eax
  8028b9:	89 c2                	mov    %eax,%edx
  8028bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8028bf:	75 17                	jne    8028d8 <__umoddi3+0x48>
  8028c1:	39 fe                	cmp    %edi,%esi
  8028c3:	76 4b                	jbe    802910 <__umoddi3+0x80>
  8028c5:	89 c8                	mov    %ecx,%eax
  8028c7:	89 fa                	mov    %edi,%edx
  8028c9:	f7 f6                	div    %esi
  8028cb:	89 d0                	mov    %edx,%eax
  8028cd:	31 d2                	xor    %edx,%edx
  8028cf:	83 c4 14             	add    $0x14,%esp
  8028d2:	5e                   	pop    %esi
  8028d3:	5f                   	pop    %edi
  8028d4:	5d                   	pop    %ebp
  8028d5:	c3                   	ret    
  8028d6:	66 90                	xchg   %ax,%ax
  8028d8:	39 f8                	cmp    %edi,%eax
  8028da:	77 54                	ja     802930 <__umoddi3+0xa0>
  8028dc:	0f bd e8             	bsr    %eax,%ebp
  8028df:	83 f5 1f             	xor    $0x1f,%ebp
  8028e2:	75 5c                	jne    802940 <__umoddi3+0xb0>
  8028e4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8028e8:	39 3c 24             	cmp    %edi,(%esp)
  8028eb:	0f 87 e7 00 00 00    	ja     8029d8 <__umoddi3+0x148>
  8028f1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8028f5:	29 f1                	sub    %esi,%ecx
  8028f7:	19 c7                	sbb    %eax,%edi
  8028f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028fd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802901:	8b 44 24 08          	mov    0x8(%esp),%eax
  802905:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802909:	83 c4 14             	add    $0x14,%esp
  80290c:	5e                   	pop    %esi
  80290d:	5f                   	pop    %edi
  80290e:	5d                   	pop    %ebp
  80290f:	c3                   	ret    
  802910:	85 f6                	test   %esi,%esi
  802912:	89 f5                	mov    %esi,%ebp
  802914:	75 0b                	jne    802921 <__umoddi3+0x91>
  802916:	b8 01 00 00 00       	mov    $0x1,%eax
  80291b:	31 d2                	xor    %edx,%edx
  80291d:	f7 f6                	div    %esi
  80291f:	89 c5                	mov    %eax,%ebp
  802921:	8b 44 24 04          	mov    0x4(%esp),%eax
  802925:	31 d2                	xor    %edx,%edx
  802927:	f7 f5                	div    %ebp
  802929:	89 c8                	mov    %ecx,%eax
  80292b:	f7 f5                	div    %ebp
  80292d:	eb 9c                	jmp    8028cb <__umoddi3+0x3b>
  80292f:	90                   	nop
  802930:	89 c8                	mov    %ecx,%eax
  802932:	89 fa                	mov    %edi,%edx
  802934:	83 c4 14             	add    $0x14,%esp
  802937:	5e                   	pop    %esi
  802938:	5f                   	pop    %edi
  802939:	5d                   	pop    %ebp
  80293a:	c3                   	ret    
  80293b:	90                   	nop
  80293c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802940:	8b 04 24             	mov    (%esp),%eax
  802943:	be 20 00 00 00       	mov    $0x20,%esi
  802948:	89 e9                	mov    %ebp,%ecx
  80294a:	29 ee                	sub    %ebp,%esi
  80294c:	d3 e2                	shl    %cl,%edx
  80294e:	89 f1                	mov    %esi,%ecx
  802950:	d3 e8                	shr    %cl,%eax
  802952:	89 e9                	mov    %ebp,%ecx
  802954:	89 44 24 04          	mov    %eax,0x4(%esp)
  802958:	8b 04 24             	mov    (%esp),%eax
  80295b:	09 54 24 04          	or     %edx,0x4(%esp)
  80295f:	89 fa                	mov    %edi,%edx
  802961:	d3 e0                	shl    %cl,%eax
  802963:	89 f1                	mov    %esi,%ecx
  802965:	89 44 24 08          	mov    %eax,0x8(%esp)
  802969:	8b 44 24 10          	mov    0x10(%esp),%eax
  80296d:	d3 ea                	shr    %cl,%edx
  80296f:	89 e9                	mov    %ebp,%ecx
  802971:	d3 e7                	shl    %cl,%edi
  802973:	89 f1                	mov    %esi,%ecx
  802975:	d3 e8                	shr    %cl,%eax
  802977:	89 e9                	mov    %ebp,%ecx
  802979:	09 f8                	or     %edi,%eax
  80297b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80297f:	f7 74 24 04          	divl   0x4(%esp)
  802983:	d3 e7                	shl    %cl,%edi
  802985:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802989:	89 d7                	mov    %edx,%edi
  80298b:	f7 64 24 08          	mull   0x8(%esp)
  80298f:	39 d7                	cmp    %edx,%edi
  802991:	89 c1                	mov    %eax,%ecx
  802993:	89 14 24             	mov    %edx,(%esp)
  802996:	72 2c                	jb     8029c4 <__umoddi3+0x134>
  802998:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80299c:	72 22                	jb     8029c0 <__umoddi3+0x130>
  80299e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8029a2:	29 c8                	sub    %ecx,%eax
  8029a4:	19 d7                	sbb    %edx,%edi
  8029a6:	89 e9                	mov    %ebp,%ecx
  8029a8:	89 fa                	mov    %edi,%edx
  8029aa:	d3 e8                	shr    %cl,%eax
  8029ac:	89 f1                	mov    %esi,%ecx
  8029ae:	d3 e2                	shl    %cl,%edx
  8029b0:	89 e9                	mov    %ebp,%ecx
  8029b2:	d3 ef                	shr    %cl,%edi
  8029b4:	09 d0                	or     %edx,%eax
  8029b6:	89 fa                	mov    %edi,%edx
  8029b8:	83 c4 14             	add    $0x14,%esp
  8029bb:	5e                   	pop    %esi
  8029bc:	5f                   	pop    %edi
  8029bd:	5d                   	pop    %ebp
  8029be:	c3                   	ret    
  8029bf:	90                   	nop
  8029c0:	39 d7                	cmp    %edx,%edi
  8029c2:	75 da                	jne    80299e <__umoddi3+0x10e>
  8029c4:	8b 14 24             	mov    (%esp),%edx
  8029c7:	89 c1                	mov    %eax,%ecx
  8029c9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8029cd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8029d1:	eb cb                	jmp    80299e <__umoddi3+0x10e>
  8029d3:	90                   	nop
  8029d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8029d8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8029dc:	0f 82 0f ff ff ff    	jb     8028f1 <__umoddi3+0x61>
  8029e2:	e9 1a ff ff ff       	jmp    802901 <__umoddi3+0x71>
