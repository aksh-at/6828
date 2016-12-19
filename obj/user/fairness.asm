
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 91 00 00 00       	call   8000c2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 20             	sub    $0x20,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 85 0b 00 00       	call   800bc5 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 08 40 80 00 7c 	cmpl   $0xeec0007c,0x804008
  800049:	00 c0 ee 
  80004c:	75 34                	jne    800082 <umain+0x4f>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800058:	00 
  800059:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800060:	00 
  800061:	89 34 24             	mov    %esi,(%esp)
  800064:	e8 c7 0e 00 00       	call   800f30 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  800069:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80006c:	89 54 24 08          	mov    %edx,0x8(%esp)
  800070:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800074:	c7 04 24 40 26 80 00 	movl   $0x802640,(%esp)
  80007b:	e8 46 01 00 00       	call   8001c6 <cprintf>
  800080:	eb cf                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800082:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800087:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008f:	c7 04 24 51 26 80 00 	movl   $0x802651,(%esp)
  800096:	e8 2b 01 00 00       	call   8001c6 <cprintf>
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80009b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  8000a0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000a7:	00 
  8000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000af:	00 
  8000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b7:	00 
  8000b8:	89 04 24             	mov    %eax,(%esp)
  8000bb:	e8 ea 0e 00 00       	call   800faa <ipc_send>
  8000c0:	eb d9                	jmp    80009b <umain+0x68>

008000c2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	56                   	push   %esi
  8000c6:	53                   	push   %ebx
  8000c7:	83 ec 10             	sub    $0x10,%esp
  8000ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000cd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  8000d0:	e8 f0 0a 00 00       	call   800bc5 <sys_getenvid>
  8000d5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000da:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000dd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e2:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e7:	85 db                	test   %ebx,%ebx
  8000e9:	7e 07                	jle    8000f2 <libmain+0x30>
		binaryname = argv[0];
  8000eb:	8b 06                	mov    (%esi),%eax
  8000ed:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000f6:	89 1c 24             	mov    %ebx,(%esp)
  8000f9:	e8 35 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000fe:	e8 07 00 00 00       	call   80010a <exit>
}
  800103:	83 c4 10             	add    $0x10,%esp
  800106:	5b                   	pop    %ebx
  800107:	5e                   	pop    %esi
  800108:	5d                   	pop    %ebp
  800109:	c3                   	ret    

0080010a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80010a:	55                   	push   %ebp
  80010b:	89 e5                	mov    %esp,%ebp
  80010d:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800110:	e8 15 11 00 00       	call   80122a <close_all>
	sys_env_destroy(0);
  800115:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80011c:	e8 52 0a 00 00       	call   800b73 <sys_env_destroy>
}
  800121:	c9                   	leave  
  800122:	c3                   	ret    

00800123 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	53                   	push   %ebx
  800127:	83 ec 14             	sub    $0x14,%esp
  80012a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012d:	8b 13                	mov    (%ebx),%edx
  80012f:	8d 42 01             	lea    0x1(%edx),%eax
  800132:	89 03                	mov    %eax,(%ebx)
  800134:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800137:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80013b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800140:	75 19                	jne    80015b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800142:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800149:	00 
  80014a:	8d 43 08             	lea    0x8(%ebx),%eax
  80014d:	89 04 24             	mov    %eax,(%esp)
  800150:	e8 e1 09 00 00       	call   800b36 <sys_cputs>
		b->idx = 0;
  800155:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80015b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015f:	83 c4 14             	add    $0x14,%esp
  800162:	5b                   	pop    %ebx
  800163:	5d                   	pop    %ebp
  800164:	c3                   	ret    

00800165 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80016e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800175:	00 00 00 
	b.cnt = 0;
  800178:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800182:	8b 45 0c             	mov    0xc(%ebp),%eax
  800185:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800189:	8b 45 08             	mov    0x8(%ebp),%eax
  80018c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800190:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800196:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019a:	c7 04 24 23 01 80 00 	movl   $0x800123,(%esp)
  8001a1:	e8 a8 01 00 00       	call   80034e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a6:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b6:	89 04 24             	mov    %eax,(%esp)
  8001b9:	e8 78 09 00 00       	call   800b36 <sys_cputs>

	return b.cnt;
}
  8001be:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c4:	c9                   	leave  
  8001c5:	c3                   	ret    

008001c6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001cc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d6:	89 04 24             	mov    %eax,(%esp)
  8001d9:	e8 87 ff ff ff       	call   800165 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

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
  80024f:	e8 4c 21 00 00       	call   8023a0 <__udivdi3>
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
  8002af:	e8 1c 22 00 00       	call   8024d0 <__umoddi3>
  8002b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b8:	0f be 80 72 26 80 00 	movsbl 0x802672(%eax),%eax
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
  8003d3:	ff 24 8d c0 27 80 00 	jmp    *0x8027c0(,%ecx,4)
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
  800470:	8b 14 85 20 29 80 00 	mov    0x802920(,%eax,4),%edx
  800477:	85 d2                	test   %edx,%edx
  800479:	75 20                	jne    80049b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80047b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80047f:	c7 44 24 08 8a 26 80 	movl   $0x80268a,0x8(%esp)
  800486:	00 
  800487:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80048b:	8b 45 08             	mov    0x8(%ebp),%eax
  80048e:	89 04 24             	mov    %eax,(%esp)
  800491:	e8 90 fe ff ff       	call   800326 <printfmt>
  800496:	e9 d8 fe ff ff       	jmp    800373 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80049b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80049f:	c7 44 24 08 91 2a 80 	movl   $0x802a91,0x8(%esp)
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
  8004d1:	b8 83 26 80 00       	mov    $0x802683,%eax
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
  800ba1:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800ba8:	00 
  800ba9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bb0:	00 
  800bb1:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800bb8:	e8 49 17 00 00       	call   802306 <_panic>

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
  800c33:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800c3a:	00 
  800c3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c42:	00 
  800c43:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800c4a:	e8 b7 16 00 00       	call   802306 <_panic>

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
  800c86:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800c8d:	00 
  800c8e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c95:	00 
  800c96:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800c9d:	e8 64 16 00 00       	call   802306 <_panic>

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
  800cd9:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800ce0:	00 
  800ce1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce8:	00 
  800ce9:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800cf0:	e8 11 16 00 00       	call   802306 <_panic>

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
  800d2c:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800d33:	00 
  800d34:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3b:	00 
  800d3c:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800d43:	e8 be 15 00 00       	call   802306 <_panic>

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
  800d7f:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800d86:	00 
  800d87:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8e:	00 
  800d8f:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800d96:	e8 6b 15 00 00       	call   802306 <_panic>

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
  800dd2:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800dd9:	00 
  800dda:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de1:	00 
  800de2:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800de9:	e8 18 15 00 00       	call   802306 <_panic>

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
  800e47:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800e4e:	00 
  800e4f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e56:	00 
  800e57:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800e5e:	e8 a3 14 00 00       	call   802306 <_panic>

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
  800eb9:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800ec0:	00 
  800ec1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec8:	00 
  800ec9:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800ed0:	e8 31 14 00 00       	call   802306 <_panic>

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
  800f0c:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800f13:	00 
  800f14:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f1b:	00 
  800f1c:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800f23:	e8 de 13 00 00       	call   802306 <_panic>

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

00800f30 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	56                   	push   %esi
  800f34:	53                   	push   %ebx
  800f35:	83 ec 10             	sub    $0x10,%esp
  800f38:	8b 75 08             	mov    0x8(%ebp),%esi
  800f3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  800f41:	85 c0                	test   %eax,%eax
  800f43:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800f48:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  800f4b:	89 04 24             	mov    %eax,(%esp)
  800f4e:	e8 c6 fe ff ff       	call   800e19 <sys_ipc_recv>

	if(ret < 0) {
  800f53:	85 c0                	test   %eax,%eax
  800f55:	79 16                	jns    800f6d <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  800f57:	85 f6                	test   %esi,%esi
  800f59:	74 06                	je     800f61 <ipc_recv+0x31>
  800f5b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  800f61:	85 db                	test   %ebx,%ebx
  800f63:	74 3e                	je     800fa3 <ipc_recv+0x73>
  800f65:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800f6b:	eb 36                	jmp    800fa3 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  800f6d:	e8 53 fc ff ff       	call   800bc5 <sys_getenvid>
  800f72:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f77:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f7a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f7f:	a3 08 40 80 00       	mov    %eax,0x804008

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  800f84:	85 f6                	test   %esi,%esi
  800f86:	74 05                	je     800f8d <ipc_recv+0x5d>
  800f88:	8b 40 74             	mov    0x74(%eax),%eax
  800f8b:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  800f8d:	85 db                	test   %ebx,%ebx
  800f8f:	74 0a                	je     800f9b <ipc_recv+0x6b>
  800f91:	a1 08 40 80 00       	mov    0x804008,%eax
  800f96:	8b 40 78             	mov    0x78(%eax),%eax
  800f99:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  800f9b:	a1 08 40 80 00       	mov    0x804008,%eax
  800fa0:	8b 40 70             	mov    0x70(%eax),%eax
}
  800fa3:	83 c4 10             	add    $0x10,%esp
  800fa6:	5b                   	pop    %ebx
  800fa7:	5e                   	pop    %esi
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    

00800faa <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	57                   	push   %edi
  800fae:	56                   	push   %esi
  800faf:	53                   	push   %ebx
  800fb0:	83 ec 1c             	sub    $0x1c,%esp
  800fb3:	8b 7d 08             	mov    0x8(%ebp),%edi
  800fb6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fb9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  800fbc:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  800fbe:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800fc3:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  800fc6:	8b 45 14             	mov    0x14(%ebp),%eax
  800fc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fcd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fd1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fd5:	89 3c 24             	mov    %edi,(%esp)
  800fd8:	e8 19 fe ff ff       	call   800df6 <sys_ipc_try_send>

		if(ret >= 0) break;
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	79 2c                	jns    80100d <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  800fe1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800fe4:	74 20                	je     801006 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  800fe6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fea:	c7 44 24 08 ac 29 80 	movl   $0x8029ac,0x8(%esp)
  800ff1:	00 
  800ff2:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  800ff9:	00 
  800ffa:	c7 04 24 dc 29 80 00 	movl   $0x8029dc,(%esp)
  801001:	e8 00 13 00 00       	call   802306 <_panic>
		}
		sys_yield();
  801006:	e8 d9 fb ff ff       	call   800be4 <sys_yield>
	}
  80100b:	eb b9                	jmp    800fc6 <ipc_send+0x1c>
}
  80100d:	83 c4 1c             	add    $0x1c,%esp
  801010:	5b                   	pop    %ebx
  801011:	5e                   	pop    %esi
  801012:	5f                   	pop    %edi
  801013:	5d                   	pop    %ebp
  801014:	c3                   	ret    

00801015 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80101b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801020:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801023:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801029:	8b 52 50             	mov    0x50(%edx),%edx
  80102c:	39 ca                	cmp    %ecx,%edx
  80102e:	75 0d                	jne    80103d <ipc_find_env+0x28>
			return envs[i].env_id;
  801030:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801033:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801038:	8b 40 40             	mov    0x40(%eax),%eax
  80103b:	eb 0e                	jmp    80104b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80103d:	83 c0 01             	add    $0x1,%eax
  801040:	3d 00 04 00 00       	cmp    $0x400,%eax
  801045:	75 d9                	jne    801020 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801047:	66 b8 00 00          	mov    $0x0,%ax
}
  80104b:	5d                   	pop    %ebp
  80104c:	c3                   	ret    
  80104d:	66 90                	xchg   %ax,%ax
  80104f:	90                   	nop

00801050 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801053:	8b 45 08             	mov    0x8(%ebp),%eax
  801056:	05 00 00 00 30       	add    $0x30000000,%eax
  80105b:	c1 e8 0c             	shr    $0xc,%eax
}
  80105e:	5d                   	pop    %ebp
  80105f:	c3                   	ret    

00801060 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801063:	8b 45 08             	mov    0x8(%ebp),%eax
  801066:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80106b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801070:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801075:	5d                   	pop    %ebp
  801076:	c3                   	ret    

00801077 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80107d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801082:	89 c2                	mov    %eax,%edx
  801084:	c1 ea 16             	shr    $0x16,%edx
  801087:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80108e:	f6 c2 01             	test   $0x1,%dl
  801091:	74 11                	je     8010a4 <fd_alloc+0x2d>
  801093:	89 c2                	mov    %eax,%edx
  801095:	c1 ea 0c             	shr    $0xc,%edx
  801098:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80109f:	f6 c2 01             	test   $0x1,%dl
  8010a2:	75 09                	jne    8010ad <fd_alloc+0x36>
			*fd_store = fd;
  8010a4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ab:	eb 17                	jmp    8010c4 <fd_alloc+0x4d>
  8010ad:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010b2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010b7:	75 c9                	jne    801082 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010b9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010bf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010c4:	5d                   	pop    %ebp
  8010c5:	c3                   	ret    

008010c6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010c6:	55                   	push   %ebp
  8010c7:	89 e5                	mov    %esp,%ebp
  8010c9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010cc:	83 f8 1f             	cmp    $0x1f,%eax
  8010cf:	77 36                	ja     801107 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010d1:	c1 e0 0c             	shl    $0xc,%eax
  8010d4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010d9:	89 c2                	mov    %eax,%edx
  8010db:	c1 ea 16             	shr    $0x16,%edx
  8010de:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010e5:	f6 c2 01             	test   $0x1,%dl
  8010e8:	74 24                	je     80110e <fd_lookup+0x48>
  8010ea:	89 c2                	mov    %eax,%edx
  8010ec:	c1 ea 0c             	shr    $0xc,%edx
  8010ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010f6:	f6 c2 01             	test   $0x1,%dl
  8010f9:	74 1a                	je     801115 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010fe:	89 02                	mov    %eax,(%edx)
	return 0;
  801100:	b8 00 00 00 00       	mov    $0x0,%eax
  801105:	eb 13                	jmp    80111a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801107:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80110c:	eb 0c                	jmp    80111a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80110e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801113:	eb 05                	jmp    80111a <fd_lookup+0x54>
  801115:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80111a:	5d                   	pop    %ebp
  80111b:	c3                   	ret    

0080111c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	83 ec 18             	sub    $0x18,%esp
  801122:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801125:	ba 00 00 00 00       	mov    $0x0,%edx
  80112a:	eb 13                	jmp    80113f <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  80112c:	39 08                	cmp    %ecx,(%eax)
  80112e:	75 0c                	jne    80113c <dev_lookup+0x20>
			*dev = devtab[i];
  801130:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801133:	89 01                	mov    %eax,(%ecx)
			return 0;
  801135:	b8 00 00 00 00       	mov    $0x0,%eax
  80113a:	eb 38                	jmp    801174 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80113c:	83 c2 01             	add    $0x1,%edx
  80113f:	8b 04 95 64 2a 80 00 	mov    0x802a64(,%edx,4),%eax
  801146:	85 c0                	test   %eax,%eax
  801148:	75 e2                	jne    80112c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80114a:	a1 08 40 80 00       	mov    0x804008,%eax
  80114f:	8b 40 48             	mov    0x48(%eax),%eax
  801152:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801156:	89 44 24 04          	mov    %eax,0x4(%esp)
  80115a:	c7 04 24 e8 29 80 00 	movl   $0x8029e8,(%esp)
  801161:	e8 60 f0 ff ff       	call   8001c6 <cprintf>
	*dev = 0;
  801166:	8b 45 0c             	mov    0xc(%ebp),%eax
  801169:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80116f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801174:	c9                   	leave  
  801175:	c3                   	ret    

00801176 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801176:	55                   	push   %ebp
  801177:	89 e5                	mov    %esp,%ebp
  801179:	56                   	push   %esi
  80117a:	53                   	push   %ebx
  80117b:	83 ec 20             	sub    $0x20,%esp
  80117e:	8b 75 08             	mov    0x8(%ebp),%esi
  801181:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801184:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801187:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80118b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801191:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801194:	89 04 24             	mov    %eax,(%esp)
  801197:	e8 2a ff ff ff       	call   8010c6 <fd_lookup>
  80119c:	85 c0                	test   %eax,%eax
  80119e:	78 05                	js     8011a5 <fd_close+0x2f>
	    || fd != fd2)
  8011a0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011a3:	74 0c                	je     8011b1 <fd_close+0x3b>
		return (must_exist ? r : 0);
  8011a5:	84 db                	test   %bl,%bl
  8011a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ac:	0f 44 c2             	cmove  %edx,%eax
  8011af:	eb 3f                	jmp    8011f0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b8:	8b 06                	mov    (%esi),%eax
  8011ba:	89 04 24             	mov    %eax,(%esp)
  8011bd:	e8 5a ff ff ff       	call   80111c <dev_lookup>
  8011c2:	89 c3                	mov    %eax,%ebx
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	78 16                	js     8011de <fd_close+0x68>
		if (dev->dev_close)
  8011c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011ce:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011d3:	85 c0                	test   %eax,%eax
  8011d5:	74 07                	je     8011de <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8011d7:	89 34 24             	mov    %esi,(%esp)
  8011da:	ff d0                	call   *%eax
  8011dc:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011de:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011e9:	e8 bc fa ff ff       	call   800caa <sys_page_unmap>
	return r;
  8011ee:	89 d8                	mov    %ebx,%eax
}
  8011f0:	83 c4 20             	add    $0x20,%esp
  8011f3:	5b                   	pop    %ebx
  8011f4:	5e                   	pop    %esi
  8011f5:	5d                   	pop    %ebp
  8011f6:	c3                   	ret    

008011f7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801200:	89 44 24 04          	mov    %eax,0x4(%esp)
  801204:	8b 45 08             	mov    0x8(%ebp),%eax
  801207:	89 04 24             	mov    %eax,(%esp)
  80120a:	e8 b7 fe ff ff       	call   8010c6 <fd_lookup>
  80120f:	89 c2                	mov    %eax,%edx
  801211:	85 d2                	test   %edx,%edx
  801213:	78 13                	js     801228 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801215:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80121c:	00 
  80121d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801220:	89 04 24             	mov    %eax,(%esp)
  801223:	e8 4e ff ff ff       	call   801176 <fd_close>
}
  801228:	c9                   	leave  
  801229:	c3                   	ret    

0080122a <close_all>:

void
close_all(void)
{
  80122a:	55                   	push   %ebp
  80122b:	89 e5                	mov    %esp,%ebp
  80122d:	53                   	push   %ebx
  80122e:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801231:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801236:	89 1c 24             	mov    %ebx,(%esp)
  801239:	e8 b9 ff ff ff       	call   8011f7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80123e:	83 c3 01             	add    $0x1,%ebx
  801241:	83 fb 20             	cmp    $0x20,%ebx
  801244:	75 f0                	jne    801236 <close_all+0xc>
		close(i);
}
  801246:	83 c4 14             	add    $0x14,%esp
  801249:	5b                   	pop    %ebx
  80124a:	5d                   	pop    %ebp
  80124b:	c3                   	ret    

0080124c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
  80124f:	57                   	push   %edi
  801250:	56                   	push   %esi
  801251:	53                   	push   %ebx
  801252:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801255:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801258:	89 44 24 04          	mov    %eax,0x4(%esp)
  80125c:	8b 45 08             	mov    0x8(%ebp),%eax
  80125f:	89 04 24             	mov    %eax,(%esp)
  801262:	e8 5f fe ff ff       	call   8010c6 <fd_lookup>
  801267:	89 c2                	mov    %eax,%edx
  801269:	85 d2                	test   %edx,%edx
  80126b:	0f 88 e1 00 00 00    	js     801352 <dup+0x106>
		return r;
	close(newfdnum);
  801271:	8b 45 0c             	mov    0xc(%ebp),%eax
  801274:	89 04 24             	mov    %eax,(%esp)
  801277:	e8 7b ff ff ff       	call   8011f7 <close>

	newfd = INDEX2FD(newfdnum);
  80127c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80127f:	c1 e3 0c             	shl    $0xc,%ebx
  801282:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801288:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80128b:	89 04 24             	mov    %eax,(%esp)
  80128e:	e8 cd fd ff ff       	call   801060 <fd2data>
  801293:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801295:	89 1c 24             	mov    %ebx,(%esp)
  801298:	e8 c3 fd ff ff       	call   801060 <fd2data>
  80129d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80129f:	89 f0                	mov    %esi,%eax
  8012a1:	c1 e8 16             	shr    $0x16,%eax
  8012a4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012ab:	a8 01                	test   $0x1,%al
  8012ad:	74 43                	je     8012f2 <dup+0xa6>
  8012af:	89 f0                	mov    %esi,%eax
  8012b1:	c1 e8 0c             	shr    $0xc,%eax
  8012b4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012bb:	f6 c2 01             	test   $0x1,%dl
  8012be:	74 32                	je     8012f2 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012c7:	25 07 0e 00 00       	and    $0xe07,%eax
  8012cc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012d0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012db:	00 
  8012dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012e7:	e8 6b f9 ff ff       	call   800c57 <sys_page_map>
  8012ec:	89 c6                	mov    %eax,%esi
  8012ee:	85 c0                	test   %eax,%eax
  8012f0:	78 3e                	js     801330 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012f5:	89 c2                	mov    %eax,%edx
  8012f7:	c1 ea 0c             	shr    $0xc,%edx
  8012fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801301:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801307:	89 54 24 10          	mov    %edx,0x10(%esp)
  80130b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80130f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801316:	00 
  801317:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801322:	e8 30 f9 ff ff       	call   800c57 <sys_page_map>
  801327:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801329:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80132c:	85 f6                	test   %esi,%esi
  80132e:	79 22                	jns    801352 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801330:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801334:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80133b:	e8 6a f9 ff ff       	call   800caa <sys_page_unmap>
	sys_page_unmap(0, nva);
  801340:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801344:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80134b:	e8 5a f9 ff ff       	call   800caa <sys_page_unmap>
	return r;
  801350:	89 f0                	mov    %esi,%eax
}
  801352:	83 c4 3c             	add    $0x3c,%esp
  801355:	5b                   	pop    %ebx
  801356:	5e                   	pop    %esi
  801357:	5f                   	pop    %edi
  801358:	5d                   	pop    %ebp
  801359:	c3                   	ret    

0080135a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80135a:	55                   	push   %ebp
  80135b:	89 e5                	mov    %esp,%ebp
  80135d:	53                   	push   %ebx
  80135e:	83 ec 24             	sub    $0x24,%esp
  801361:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801364:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801367:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136b:	89 1c 24             	mov    %ebx,(%esp)
  80136e:	e8 53 fd ff ff       	call   8010c6 <fd_lookup>
  801373:	89 c2                	mov    %eax,%edx
  801375:	85 d2                	test   %edx,%edx
  801377:	78 6d                	js     8013e6 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801379:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801380:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801383:	8b 00                	mov    (%eax),%eax
  801385:	89 04 24             	mov    %eax,(%esp)
  801388:	e8 8f fd ff ff       	call   80111c <dev_lookup>
  80138d:	85 c0                	test   %eax,%eax
  80138f:	78 55                	js     8013e6 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801391:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801394:	8b 50 08             	mov    0x8(%eax),%edx
  801397:	83 e2 03             	and    $0x3,%edx
  80139a:	83 fa 01             	cmp    $0x1,%edx
  80139d:	75 23                	jne    8013c2 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80139f:	a1 08 40 80 00       	mov    0x804008,%eax
  8013a4:	8b 40 48             	mov    0x48(%eax),%eax
  8013a7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013af:	c7 04 24 29 2a 80 00 	movl   $0x802a29,(%esp)
  8013b6:	e8 0b ee ff ff       	call   8001c6 <cprintf>
		return -E_INVAL;
  8013bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013c0:	eb 24                	jmp    8013e6 <read+0x8c>
	}
	if (!dev->dev_read)
  8013c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013c5:	8b 52 08             	mov    0x8(%edx),%edx
  8013c8:	85 d2                	test   %edx,%edx
  8013ca:	74 15                	je     8013e1 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013cf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013d6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013da:	89 04 24             	mov    %eax,(%esp)
  8013dd:	ff d2                	call   *%edx
  8013df:	eb 05                	jmp    8013e6 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013e1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8013e6:	83 c4 24             	add    $0x24,%esp
  8013e9:	5b                   	pop    %ebx
  8013ea:	5d                   	pop    %ebp
  8013eb:	c3                   	ret    

008013ec <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	57                   	push   %edi
  8013f0:	56                   	push   %esi
  8013f1:	53                   	push   %ebx
  8013f2:	83 ec 1c             	sub    $0x1c,%esp
  8013f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013f8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801400:	eb 23                	jmp    801425 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801402:	89 f0                	mov    %esi,%eax
  801404:	29 d8                	sub    %ebx,%eax
  801406:	89 44 24 08          	mov    %eax,0x8(%esp)
  80140a:	89 d8                	mov    %ebx,%eax
  80140c:	03 45 0c             	add    0xc(%ebp),%eax
  80140f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801413:	89 3c 24             	mov    %edi,(%esp)
  801416:	e8 3f ff ff ff       	call   80135a <read>
		if (m < 0)
  80141b:	85 c0                	test   %eax,%eax
  80141d:	78 10                	js     80142f <readn+0x43>
			return m;
		if (m == 0)
  80141f:	85 c0                	test   %eax,%eax
  801421:	74 0a                	je     80142d <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801423:	01 c3                	add    %eax,%ebx
  801425:	39 f3                	cmp    %esi,%ebx
  801427:	72 d9                	jb     801402 <readn+0x16>
  801429:	89 d8                	mov    %ebx,%eax
  80142b:	eb 02                	jmp    80142f <readn+0x43>
  80142d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80142f:	83 c4 1c             	add    $0x1c,%esp
  801432:	5b                   	pop    %ebx
  801433:	5e                   	pop    %esi
  801434:	5f                   	pop    %edi
  801435:	5d                   	pop    %ebp
  801436:	c3                   	ret    

00801437 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801437:	55                   	push   %ebp
  801438:	89 e5                	mov    %esp,%ebp
  80143a:	53                   	push   %ebx
  80143b:	83 ec 24             	sub    $0x24,%esp
  80143e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801441:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801444:	89 44 24 04          	mov    %eax,0x4(%esp)
  801448:	89 1c 24             	mov    %ebx,(%esp)
  80144b:	e8 76 fc ff ff       	call   8010c6 <fd_lookup>
  801450:	89 c2                	mov    %eax,%edx
  801452:	85 d2                	test   %edx,%edx
  801454:	78 68                	js     8014be <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801456:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801459:	89 44 24 04          	mov    %eax,0x4(%esp)
  80145d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801460:	8b 00                	mov    (%eax),%eax
  801462:	89 04 24             	mov    %eax,(%esp)
  801465:	e8 b2 fc ff ff       	call   80111c <dev_lookup>
  80146a:	85 c0                	test   %eax,%eax
  80146c:	78 50                	js     8014be <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80146e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801471:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801475:	75 23                	jne    80149a <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801477:	a1 08 40 80 00       	mov    0x804008,%eax
  80147c:	8b 40 48             	mov    0x48(%eax),%eax
  80147f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801483:	89 44 24 04          	mov    %eax,0x4(%esp)
  801487:	c7 04 24 45 2a 80 00 	movl   $0x802a45,(%esp)
  80148e:	e8 33 ed ff ff       	call   8001c6 <cprintf>
		return -E_INVAL;
  801493:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801498:	eb 24                	jmp    8014be <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80149a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80149d:	8b 52 0c             	mov    0xc(%edx),%edx
  8014a0:	85 d2                	test   %edx,%edx
  8014a2:	74 15                	je     8014b9 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014a7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014ae:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014b2:	89 04 24             	mov    %eax,(%esp)
  8014b5:	ff d2                	call   *%edx
  8014b7:	eb 05                	jmp    8014be <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014b9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8014be:	83 c4 24             	add    $0x24,%esp
  8014c1:	5b                   	pop    %ebx
  8014c2:	5d                   	pop    %ebp
  8014c3:	c3                   	ret    

008014c4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014c4:	55                   	push   %ebp
  8014c5:	89 e5                	mov    %esp,%ebp
  8014c7:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014ca:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d4:	89 04 24             	mov    %eax,(%esp)
  8014d7:	e8 ea fb ff ff       	call   8010c6 <fd_lookup>
  8014dc:	85 c0                	test   %eax,%eax
  8014de:	78 0e                	js     8014ee <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8014e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014e6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ee:	c9                   	leave  
  8014ef:	c3                   	ret    

008014f0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	53                   	push   %ebx
  8014f4:	83 ec 24             	sub    $0x24,%esp
  8014f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801501:	89 1c 24             	mov    %ebx,(%esp)
  801504:	e8 bd fb ff ff       	call   8010c6 <fd_lookup>
  801509:	89 c2                	mov    %eax,%edx
  80150b:	85 d2                	test   %edx,%edx
  80150d:	78 61                	js     801570 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801512:	89 44 24 04          	mov    %eax,0x4(%esp)
  801516:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801519:	8b 00                	mov    (%eax),%eax
  80151b:	89 04 24             	mov    %eax,(%esp)
  80151e:	e8 f9 fb ff ff       	call   80111c <dev_lookup>
  801523:	85 c0                	test   %eax,%eax
  801525:	78 49                	js     801570 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801527:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80152e:	75 23                	jne    801553 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801530:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801535:	8b 40 48             	mov    0x48(%eax),%eax
  801538:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80153c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801540:	c7 04 24 08 2a 80 00 	movl   $0x802a08,(%esp)
  801547:	e8 7a ec ff ff       	call   8001c6 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80154c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801551:	eb 1d                	jmp    801570 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801553:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801556:	8b 52 18             	mov    0x18(%edx),%edx
  801559:	85 d2                	test   %edx,%edx
  80155b:	74 0e                	je     80156b <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80155d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801560:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801564:	89 04 24             	mov    %eax,(%esp)
  801567:	ff d2                	call   *%edx
  801569:	eb 05                	jmp    801570 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80156b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801570:	83 c4 24             	add    $0x24,%esp
  801573:	5b                   	pop    %ebx
  801574:	5d                   	pop    %ebp
  801575:	c3                   	ret    

00801576 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801576:	55                   	push   %ebp
  801577:	89 e5                	mov    %esp,%ebp
  801579:	53                   	push   %ebx
  80157a:	83 ec 24             	sub    $0x24,%esp
  80157d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801580:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801583:	89 44 24 04          	mov    %eax,0x4(%esp)
  801587:	8b 45 08             	mov    0x8(%ebp),%eax
  80158a:	89 04 24             	mov    %eax,(%esp)
  80158d:	e8 34 fb ff ff       	call   8010c6 <fd_lookup>
  801592:	89 c2                	mov    %eax,%edx
  801594:	85 d2                	test   %edx,%edx
  801596:	78 52                	js     8015ea <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801598:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80159f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a2:	8b 00                	mov    (%eax),%eax
  8015a4:	89 04 24             	mov    %eax,(%esp)
  8015a7:	e8 70 fb ff ff       	call   80111c <dev_lookup>
  8015ac:	85 c0                	test   %eax,%eax
  8015ae:	78 3a                	js     8015ea <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8015b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015b7:	74 2c                	je     8015e5 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015b9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015bc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015c3:	00 00 00 
	stat->st_isdir = 0;
  8015c6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015cd:	00 00 00 
	stat->st_dev = dev;
  8015d0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015da:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015dd:	89 14 24             	mov    %edx,(%esp)
  8015e0:	ff 50 14             	call   *0x14(%eax)
  8015e3:	eb 05                	jmp    8015ea <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015e5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015ea:	83 c4 24             	add    $0x24,%esp
  8015ed:	5b                   	pop    %ebx
  8015ee:	5d                   	pop    %ebp
  8015ef:	c3                   	ret    

008015f0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	56                   	push   %esi
  8015f4:	53                   	push   %ebx
  8015f5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015ff:	00 
  801600:	8b 45 08             	mov    0x8(%ebp),%eax
  801603:	89 04 24             	mov    %eax,(%esp)
  801606:	e8 28 02 00 00       	call   801833 <open>
  80160b:	89 c3                	mov    %eax,%ebx
  80160d:	85 db                	test   %ebx,%ebx
  80160f:	78 1b                	js     80162c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801611:	8b 45 0c             	mov    0xc(%ebp),%eax
  801614:	89 44 24 04          	mov    %eax,0x4(%esp)
  801618:	89 1c 24             	mov    %ebx,(%esp)
  80161b:	e8 56 ff ff ff       	call   801576 <fstat>
  801620:	89 c6                	mov    %eax,%esi
	close(fd);
  801622:	89 1c 24             	mov    %ebx,(%esp)
  801625:	e8 cd fb ff ff       	call   8011f7 <close>
	return r;
  80162a:	89 f0                	mov    %esi,%eax
}
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	5b                   	pop    %ebx
  801630:	5e                   	pop    %esi
  801631:	5d                   	pop    %ebp
  801632:	c3                   	ret    

00801633 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801633:	55                   	push   %ebp
  801634:	89 e5                	mov    %esp,%ebp
  801636:	56                   	push   %esi
  801637:	53                   	push   %ebx
  801638:	83 ec 10             	sub    $0x10,%esp
  80163b:	89 c6                	mov    %eax,%esi
  80163d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80163f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801646:	75 11                	jne    801659 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801648:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80164f:	e8 c1 f9 ff ff       	call   801015 <ipc_find_env>
  801654:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801659:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801660:	00 
  801661:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801668:	00 
  801669:	89 74 24 04          	mov    %esi,0x4(%esp)
  80166d:	a1 00 40 80 00       	mov    0x804000,%eax
  801672:	89 04 24             	mov    %eax,(%esp)
  801675:	e8 30 f9 ff ff       	call   800faa <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80167a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801681:	00 
  801682:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801686:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80168d:	e8 9e f8 ff ff       	call   800f30 <ipc_recv>
}
  801692:	83 c4 10             	add    $0x10,%esp
  801695:	5b                   	pop    %ebx
  801696:	5e                   	pop    %esi
  801697:	5d                   	pop    %ebp
  801698:	c3                   	ret    

00801699 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801699:	55                   	push   %ebp
  80169a:	89 e5                	mov    %esp,%ebp
  80169c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80169f:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016ad:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b7:	b8 02 00 00 00       	mov    $0x2,%eax
  8016bc:	e8 72 ff ff ff       	call   801633 <fsipc>
}
  8016c1:	c9                   	leave  
  8016c2:	c3                   	ret    

008016c3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8016cf:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d9:	b8 06 00 00 00       	mov    $0x6,%eax
  8016de:	e8 50 ff ff ff       	call   801633 <fsipc>
}
  8016e3:	c9                   	leave  
  8016e4:	c3                   	ret    

008016e5 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016e5:	55                   	push   %ebp
  8016e6:	89 e5                	mov    %esp,%ebp
  8016e8:	53                   	push   %ebx
  8016e9:	83 ec 14             	sub    $0x14,%esp
  8016ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ff:	b8 05 00 00 00       	mov    $0x5,%eax
  801704:	e8 2a ff ff ff       	call   801633 <fsipc>
  801709:	89 c2                	mov    %eax,%edx
  80170b:	85 d2                	test   %edx,%edx
  80170d:	78 2b                	js     80173a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80170f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801716:	00 
  801717:	89 1c 24             	mov    %ebx,(%esp)
  80171a:	e8 c8 f0 ff ff       	call   8007e7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80171f:	a1 80 50 80 00       	mov    0x805080,%eax
  801724:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80172a:	a1 84 50 80 00       	mov    0x805084,%eax
  80172f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801735:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80173a:	83 c4 14             	add    $0x14,%esp
  80173d:	5b                   	pop    %ebx
  80173e:	5d                   	pop    %ebp
  80173f:	c3                   	ret    

00801740 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	83 ec 18             	sub    $0x18,%esp
  801746:	8b 45 10             	mov    0x10(%ebp),%eax
  801749:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80174e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801753:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801756:	8b 55 08             	mov    0x8(%ebp),%edx
  801759:	8b 52 0c             	mov    0xc(%edx),%edx
  80175c:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801762:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801767:	89 44 24 08          	mov    %eax,0x8(%esp)
  80176b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80176e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801772:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801779:	e8 06 f2 ff ff       	call   800984 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  80177e:	ba 00 00 00 00       	mov    $0x0,%edx
  801783:	b8 04 00 00 00       	mov    $0x4,%eax
  801788:	e8 a6 fe ff ff       	call   801633 <fsipc>
}
  80178d:	c9                   	leave  
  80178e:	c3                   	ret    

0080178f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80178f:	55                   	push   %ebp
  801790:	89 e5                	mov    %esp,%ebp
  801792:	56                   	push   %esi
  801793:	53                   	push   %ebx
  801794:	83 ec 10             	sub    $0x10,%esp
  801797:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80179a:	8b 45 08             	mov    0x8(%ebp),%eax
  80179d:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017a5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b0:	b8 03 00 00 00       	mov    $0x3,%eax
  8017b5:	e8 79 fe ff ff       	call   801633 <fsipc>
  8017ba:	89 c3                	mov    %eax,%ebx
  8017bc:	85 c0                	test   %eax,%eax
  8017be:	78 6a                	js     80182a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8017c0:	39 c6                	cmp    %eax,%esi
  8017c2:	73 24                	jae    8017e8 <devfile_read+0x59>
  8017c4:	c7 44 24 0c 78 2a 80 	movl   $0x802a78,0xc(%esp)
  8017cb:	00 
  8017cc:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  8017d3:	00 
  8017d4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8017db:	00 
  8017dc:	c7 04 24 94 2a 80 00 	movl   $0x802a94,(%esp)
  8017e3:	e8 1e 0b 00 00       	call   802306 <_panic>
	assert(r <= PGSIZE);
  8017e8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017ed:	7e 24                	jle    801813 <devfile_read+0x84>
  8017ef:	c7 44 24 0c 9f 2a 80 	movl   $0x802a9f,0xc(%esp)
  8017f6:	00 
  8017f7:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  8017fe:	00 
  8017ff:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801806:	00 
  801807:	c7 04 24 94 2a 80 00 	movl   $0x802a94,(%esp)
  80180e:	e8 f3 0a 00 00       	call   802306 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801813:	89 44 24 08          	mov    %eax,0x8(%esp)
  801817:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80181e:	00 
  80181f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801822:	89 04 24             	mov    %eax,(%esp)
  801825:	e8 5a f1 ff ff       	call   800984 <memmove>
	return r;
}
  80182a:	89 d8                	mov    %ebx,%eax
  80182c:	83 c4 10             	add    $0x10,%esp
  80182f:	5b                   	pop    %ebx
  801830:	5e                   	pop    %esi
  801831:	5d                   	pop    %ebp
  801832:	c3                   	ret    

00801833 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	53                   	push   %ebx
  801837:	83 ec 24             	sub    $0x24,%esp
  80183a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80183d:	89 1c 24             	mov    %ebx,(%esp)
  801840:	e8 6b ef ff ff       	call   8007b0 <strlen>
  801845:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80184a:	7f 60                	jg     8018ac <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80184c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184f:	89 04 24             	mov    %eax,(%esp)
  801852:	e8 20 f8 ff ff       	call   801077 <fd_alloc>
  801857:	89 c2                	mov    %eax,%edx
  801859:	85 d2                	test   %edx,%edx
  80185b:	78 54                	js     8018b1 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80185d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801861:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801868:	e8 7a ef ff ff       	call   8007e7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80186d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801870:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801875:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801878:	b8 01 00 00 00       	mov    $0x1,%eax
  80187d:	e8 b1 fd ff ff       	call   801633 <fsipc>
  801882:	89 c3                	mov    %eax,%ebx
  801884:	85 c0                	test   %eax,%eax
  801886:	79 17                	jns    80189f <open+0x6c>
		fd_close(fd, 0);
  801888:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80188f:	00 
  801890:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801893:	89 04 24             	mov    %eax,(%esp)
  801896:	e8 db f8 ff ff       	call   801176 <fd_close>
		return r;
  80189b:	89 d8                	mov    %ebx,%eax
  80189d:	eb 12                	jmp    8018b1 <open+0x7e>
	}

	return fd2num(fd);
  80189f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a2:	89 04 24             	mov    %eax,(%esp)
  8018a5:	e8 a6 f7 ff ff       	call   801050 <fd2num>
  8018aa:	eb 05                	jmp    8018b1 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018ac:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018b1:	83 c4 24             	add    $0x24,%esp
  8018b4:	5b                   	pop    %ebx
  8018b5:	5d                   	pop    %ebp
  8018b6:	c3                   	ret    

008018b7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018b7:	55                   	push   %ebp
  8018b8:	89 e5                	mov    %esp,%ebp
  8018ba:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c2:	b8 08 00 00 00       	mov    $0x8,%eax
  8018c7:	e8 67 fd ff ff       	call   801633 <fsipc>
}
  8018cc:	c9                   	leave  
  8018cd:	c3                   	ret    
  8018ce:	66 90                	xchg   %ax,%ax

008018d0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  8018d6:	c7 44 24 04 ab 2a 80 	movl   $0x802aab,0x4(%esp)
  8018dd:	00 
  8018de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e1:	89 04 24             	mov    %eax,(%esp)
  8018e4:	e8 fe ee ff ff       	call   8007e7 <strcpy>
	return 0;
}
  8018e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ee:	c9                   	leave  
  8018ef:	c3                   	ret    

008018f0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8018f0:	55                   	push   %ebp
  8018f1:	89 e5                	mov    %esp,%ebp
  8018f3:	53                   	push   %ebx
  8018f4:	83 ec 14             	sub    $0x14,%esp
  8018f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8018fa:	89 1c 24             	mov    %ebx,(%esp)
  8018fd:	e8 5a 0a 00 00       	call   80235c <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801902:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801907:	83 f8 01             	cmp    $0x1,%eax
  80190a:	75 0d                	jne    801919 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80190c:	8b 43 0c             	mov    0xc(%ebx),%eax
  80190f:	89 04 24             	mov    %eax,(%esp)
  801912:	e8 29 03 00 00       	call   801c40 <nsipc_close>
  801917:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  801919:	89 d0                	mov    %edx,%eax
  80191b:	83 c4 14             	add    $0x14,%esp
  80191e:	5b                   	pop    %ebx
  80191f:	5d                   	pop    %ebp
  801920:	c3                   	ret    

00801921 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801927:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80192e:	00 
  80192f:	8b 45 10             	mov    0x10(%ebp),%eax
  801932:	89 44 24 08          	mov    %eax,0x8(%esp)
  801936:	8b 45 0c             	mov    0xc(%ebp),%eax
  801939:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193d:	8b 45 08             	mov    0x8(%ebp),%eax
  801940:	8b 40 0c             	mov    0xc(%eax),%eax
  801943:	89 04 24             	mov    %eax,(%esp)
  801946:	e8 f0 03 00 00       	call   801d3b <nsipc_send>
}
  80194b:	c9                   	leave  
  80194c:	c3                   	ret    

0080194d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80194d:	55                   	push   %ebp
  80194e:	89 e5                	mov    %esp,%ebp
  801950:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801953:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80195a:	00 
  80195b:	8b 45 10             	mov    0x10(%ebp),%eax
  80195e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801962:	8b 45 0c             	mov    0xc(%ebp),%eax
  801965:	89 44 24 04          	mov    %eax,0x4(%esp)
  801969:	8b 45 08             	mov    0x8(%ebp),%eax
  80196c:	8b 40 0c             	mov    0xc(%eax),%eax
  80196f:	89 04 24             	mov    %eax,(%esp)
  801972:	e8 44 03 00 00       	call   801cbb <nsipc_recv>
}
  801977:	c9                   	leave  
  801978:	c3                   	ret    

00801979 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801979:	55                   	push   %ebp
  80197a:	89 e5                	mov    %esp,%ebp
  80197c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80197f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801982:	89 54 24 04          	mov    %edx,0x4(%esp)
  801986:	89 04 24             	mov    %eax,(%esp)
  801989:	e8 38 f7 ff ff       	call   8010c6 <fd_lookup>
  80198e:	85 c0                	test   %eax,%eax
  801990:	78 17                	js     8019a9 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801992:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801995:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80199b:	39 08                	cmp    %ecx,(%eax)
  80199d:	75 05                	jne    8019a4 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80199f:	8b 40 0c             	mov    0xc(%eax),%eax
  8019a2:	eb 05                	jmp    8019a9 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8019a4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8019a9:	c9                   	leave  
  8019aa:	c3                   	ret    

008019ab <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	56                   	push   %esi
  8019af:	53                   	push   %ebx
  8019b0:	83 ec 20             	sub    $0x20,%esp
  8019b3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8019b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b8:	89 04 24             	mov    %eax,(%esp)
  8019bb:	e8 b7 f6 ff ff       	call   801077 <fd_alloc>
  8019c0:	89 c3                	mov    %eax,%ebx
  8019c2:	85 c0                	test   %eax,%eax
  8019c4:	78 21                	js     8019e7 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8019c6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8019cd:	00 
  8019ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019dc:	e8 22 f2 ff ff       	call   800c03 <sys_page_alloc>
  8019e1:	89 c3                	mov    %eax,%ebx
  8019e3:	85 c0                	test   %eax,%eax
  8019e5:	79 0c                	jns    8019f3 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  8019e7:	89 34 24             	mov    %esi,(%esp)
  8019ea:	e8 51 02 00 00       	call   801c40 <nsipc_close>
		return r;
  8019ef:	89 d8                	mov    %ebx,%eax
  8019f1:	eb 20                	jmp    801a13 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8019f3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019fc:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8019fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a01:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801a08:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801a0b:	89 14 24             	mov    %edx,(%esp)
  801a0e:	e8 3d f6 ff ff       	call   801050 <fd2num>
}
  801a13:	83 c4 20             	add    $0x20,%esp
  801a16:	5b                   	pop    %ebx
  801a17:	5e                   	pop    %esi
  801a18:	5d                   	pop    %ebp
  801a19:	c3                   	ret    

00801a1a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a20:	8b 45 08             	mov    0x8(%ebp),%eax
  801a23:	e8 51 ff ff ff       	call   801979 <fd2sockid>
		return r;
  801a28:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a2a:	85 c0                	test   %eax,%eax
  801a2c:	78 23                	js     801a51 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a2e:	8b 55 10             	mov    0x10(%ebp),%edx
  801a31:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a35:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a38:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a3c:	89 04 24             	mov    %eax,(%esp)
  801a3f:	e8 45 01 00 00       	call   801b89 <nsipc_accept>
		return r;
  801a44:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a46:	85 c0                	test   %eax,%eax
  801a48:	78 07                	js     801a51 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  801a4a:	e8 5c ff ff ff       	call   8019ab <alloc_sockfd>
  801a4f:	89 c1                	mov    %eax,%ecx
}
  801a51:	89 c8                	mov    %ecx,%eax
  801a53:	c9                   	leave  
  801a54:	c3                   	ret    

00801a55 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a55:	55                   	push   %ebp
  801a56:	89 e5                	mov    %esp,%ebp
  801a58:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5e:	e8 16 ff ff ff       	call   801979 <fd2sockid>
  801a63:	89 c2                	mov    %eax,%edx
  801a65:	85 d2                	test   %edx,%edx
  801a67:	78 16                	js     801a7f <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  801a69:	8b 45 10             	mov    0x10(%ebp),%eax
  801a6c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a70:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a73:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a77:	89 14 24             	mov    %edx,(%esp)
  801a7a:	e8 60 01 00 00       	call   801bdf <nsipc_bind>
}
  801a7f:	c9                   	leave  
  801a80:	c3                   	ret    

00801a81 <shutdown>:

int
shutdown(int s, int how)
{
  801a81:	55                   	push   %ebp
  801a82:	89 e5                	mov    %esp,%ebp
  801a84:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a87:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8a:	e8 ea fe ff ff       	call   801979 <fd2sockid>
  801a8f:	89 c2                	mov    %eax,%edx
  801a91:	85 d2                	test   %edx,%edx
  801a93:	78 0f                	js     801aa4 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801a95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a98:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a9c:	89 14 24             	mov    %edx,(%esp)
  801a9f:	e8 7a 01 00 00       	call   801c1e <nsipc_shutdown>
}
  801aa4:	c9                   	leave  
  801aa5:	c3                   	ret    

00801aa6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801aa6:	55                   	push   %ebp
  801aa7:	89 e5                	mov    %esp,%ebp
  801aa9:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801aac:	8b 45 08             	mov    0x8(%ebp),%eax
  801aaf:	e8 c5 fe ff ff       	call   801979 <fd2sockid>
  801ab4:	89 c2                	mov    %eax,%edx
  801ab6:	85 d2                	test   %edx,%edx
  801ab8:	78 16                	js     801ad0 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  801aba:	8b 45 10             	mov    0x10(%ebp),%eax
  801abd:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ac1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac8:	89 14 24             	mov    %edx,(%esp)
  801acb:	e8 8a 01 00 00       	call   801c5a <nsipc_connect>
}
  801ad0:	c9                   	leave  
  801ad1:	c3                   	ret    

00801ad2 <listen>:

int
listen(int s, int backlog)
{
  801ad2:	55                   	push   %ebp
  801ad3:	89 e5                	mov    %esp,%ebp
  801ad5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  801adb:	e8 99 fe ff ff       	call   801979 <fd2sockid>
  801ae0:	89 c2                	mov    %eax,%edx
  801ae2:	85 d2                	test   %edx,%edx
  801ae4:	78 0f                	js     801af5 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801ae6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aed:	89 14 24             	mov    %edx,(%esp)
  801af0:	e8 a4 01 00 00       	call   801c99 <nsipc_listen>
}
  801af5:	c9                   	leave  
  801af6:	c3                   	ret    

00801af7 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801afd:	8b 45 10             	mov    0x10(%ebp),%eax
  801b00:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b04:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b07:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0e:	89 04 24             	mov    %eax,(%esp)
  801b11:	e8 98 02 00 00       	call   801dae <nsipc_socket>
  801b16:	89 c2                	mov    %eax,%edx
  801b18:	85 d2                	test   %edx,%edx
  801b1a:	78 05                	js     801b21 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  801b1c:	e8 8a fe ff ff       	call   8019ab <alloc_sockfd>
}
  801b21:	c9                   	leave  
  801b22:	c3                   	ret    

00801b23 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b23:	55                   	push   %ebp
  801b24:	89 e5                	mov    %esp,%ebp
  801b26:	53                   	push   %ebx
  801b27:	83 ec 14             	sub    $0x14,%esp
  801b2a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b2c:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801b33:	75 11                	jne    801b46 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b35:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801b3c:	e8 d4 f4 ff ff       	call   801015 <ipc_find_env>
  801b41:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b46:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b4d:	00 
  801b4e:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801b55:	00 
  801b56:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b5a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b5f:	89 04 24             	mov    %eax,(%esp)
  801b62:	e8 43 f4 ff ff       	call   800faa <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b67:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b6e:	00 
  801b6f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b76:	00 
  801b77:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b7e:	e8 ad f3 ff ff       	call   800f30 <ipc_recv>
}
  801b83:	83 c4 14             	add    $0x14,%esp
  801b86:	5b                   	pop    %ebx
  801b87:	5d                   	pop    %ebp
  801b88:	c3                   	ret    

00801b89 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b89:	55                   	push   %ebp
  801b8a:	89 e5                	mov    %esp,%ebp
  801b8c:	56                   	push   %esi
  801b8d:	53                   	push   %ebx
  801b8e:	83 ec 10             	sub    $0x10,%esp
  801b91:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801b94:	8b 45 08             	mov    0x8(%ebp),%eax
  801b97:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801b9c:	8b 06                	mov    (%esi),%eax
  801b9e:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ba3:	b8 01 00 00 00       	mov    $0x1,%eax
  801ba8:	e8 76 ff ff ff       	call   801b23 <nsipc>
  801bad:	89 c3                	mov    %eax,%ebx
  801baf:	85 c0                	test   %eax,%eax
  801bb1:	78 23                	js     801bd6 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801bb3:	a1 10 60 80 00       	mov    0x806010,%eax
  801bb8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bbc:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801bc3:	00 
  801bc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc7:	89 04 24             	mov    %eax,(%esp)
  801bca:	e8 b5 ed ff ff       	call   800984 <memmove>
		*addrlen = ret->ret_addrlen;
  801bcf:	a1 10 60 80 00       	mov    0x806010,%eax
  801bd4:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801bd6:	89 d8                	mov    %ebx,%eax
  801bd8:	83 c4 10             	add    $0x10,%esp
  801bdb:	5b                   	pop    %ebx
  801bdc:	5e                   	pop    %esi
  801bdd:	5d                   	pop    %ebp
  801bde:	c3                   	ret    

00801bdf <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	53                   	push   %ebx
  801be3:	83 ec 14             	sub    $0x14,%esp
  801be6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801be9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bec:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801bf1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bf5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bfc:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801c03:	e8 7c ed ff ff       	call   800984 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c08:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c0e:	b8 02 00 00 00       	mov    $0x2,%eax
  801c13:	e8 0b ff ff ff       	call   801b23 <nsipc>
}
  801c18:	83 c4 14             	add    $0x14,%esp
  801c1b:	5b                   	pop    %ebx
  801c1c:	5d                   	pop    %ebp
  801c1d:	c3                   	ret    

00801c1e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c1e:	55                   	push   %ebp
  801c1f:	89 e5                	mov    %esp,%ebp
  801c21:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c24:	8b 45 08             	mov    0x8(%ebp),%eax
  801c27:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c2f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c34:	b8 03 00 00 00       	mov    $0x3,%eax
  801c39:	e8 e5 fe ff ff       	call   801b23 <nsipc>
}
  801c3e:	c9                   	leave  
  801c3f:	c3                   	ret    

00801c40 <nsipc_close>:

int
nsipc_close(int s)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c46:	8b 45 08             	mov    0x8(%ebp),%eax
  801c49:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c4e:	b8 04 00 00 00       	mov    $0x4,%eax
  801c53:	e8 cb fe ff ff       	call   801b23 <nsipc>
}
  801c58:	c9                   	leave  
  801c59:	c3                   	ret    

00801c5a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c5a:	55                   	push   %ebp
  801c5b:	89 e5                	mov    %esp,%ebp
  801c5d:	53                   	push   %ebx
  801c5e:	83 ec 14             	sub    $0x14,%esp
  801c61:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c64:	8b 45 08             	mov    0x8(%ebp),%eax
  801c67:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c6c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c70:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c73:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c77:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801c7e:	e8 01 ed ff ff       	call   800984 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801c83:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801c89:	b8 05 00 00 00       	mov    $0x5,%eax
  801c8e:	e8 90 fe ff ff       	call   801b23 <nsipc>
}
  801c93:	83 c4 14             	add    $0x14,%esp
  801c96:	5b                   	pop    %ebx
  801c97:	5d                   	pop    %ebp
  801c98:	c3                   	ret    

00801c99 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801c99:	55                   	push   %ebp
  801c9a:	89 e5                	mov    %esp,%ebp
  801c9c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801ca7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801caa:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801caf:	b8 06 00 00 00       	mov    $0x6,%eax
  801cb4:	e8 6a fe ff ff       	call   801b23 <nsipc>
}
  801cb9:	c9                   	leave  
  801cba:	c3                   	ret    

00801cbb <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801cbb:	55                   	push   %ebp
  801cbc:	89 e5                	mov    %esp,%ebp
  801cbe:	56                   	push   %esi
  801cbf:	53                   	push   %ebx
  801cc0:	83 ec 10             	sub    $0x10,%esp
  801cc3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801cc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801cce:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801cd4:	8b 45 14             	mov    0x14(%ebp),%eax
  801cd7:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801cdc:	b8 07 00 00 00       	mov    $0x7,%eax
  801ce1:	e8 3d fe ff ff       	call   801b23 <nsipc>
  801ce6:	89 c3                	mov    %eax,%ebx
  801ce8:	85 c0                	test   %eax,%eax
  801cea:	78 46                	js     801d32 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801cec:	39 f0                	cmp    %esi,%eax
  801cee:	7f 07                	jg     801cf7 <nsipc_recv+0x3c>
  801cf0:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801cf5:	7e 24                	jle    801d1b <nsipc_recv+0x60>
  801cf7:	c7 44 24 0c b7 2a 80 	movl   $0x802ab7,0xc(%esp)
  801cfe:	00 
  801cff:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  801d06:	00 
  801d07:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801d0e:	00 
  801d0f:	c7 04 24 cc 2a 80 00 	movl   $0x802acc,(%esp)
  801d16:	e8 eb 05 00 00       	call   802306 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d1b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d1f:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801d26:	00 
  801d27:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d2a:	89 04 24             	mov    %eax,(%esp)
  801d2d:	e8 52 ec ff ff       	call   800984 <memmove>
	}

	return r;
}
  801d32:	89 d8                	mov    %ebx,%eax
  801d34:	83 c4 10             	add    $0x10,%esp
  801d37:	5b                   	pop    %ebx
  801d38:	5e                   	pop    %esi
  801d39:	5d                   	pop    %ebp
  801d3a:	c3                   	ret    

00801d3b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d3b:	55                   	push   %ebp
  801d3c:	89 e5                	mov    %esp,%ebp
  801d3e:	53                   	push   %ebx
  801d3f:	83 ec 14             	sub    $0x14,%esp
  801d42:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d45:	8b 45 08             	mov    0x8(%ebp),%eax
  801d48:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d4d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d53:	7e 24                	jle    801d79 <nsipc_send+0x3e>
  801d55:	c7 44 24 0c d8 2a 80 	movl   $0x802ad8,0xc(%esp)
  801d5c:	00 
  801d5d:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  801d64:	00 
  801d65:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801d6c:	00 
  801d6d:	c7 04 24 cc 2a 80 00 	movl   $0x802acc,(%esp)
  801d74:	e8 8d 05 00 00       	call   802306 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d80:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d84:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801d8b:	e8 f4 eb ff ff       	call   800984 <memmove>
	nsipcbuf.send.req_size = size;
  801d90:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801d96:	8b 45 14             	mov    0x14(%ebp),%eax
  801d99:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801d9e:	b8 08 00 00 00       	mov    $0x8,%eax
  801da3:	e8 7b fd ff ff       	call   801b23 <nsipc>
}
  801da8:	83 c4 14             	add    $0x14,%esp
  801dab:	5b                   	pop    %ebx
  801dac:	5d                   	pop    %ebp
  801dad:	c3                   	ret    

00801dae <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801dae:	55                   	push   %ebp
  801daf:	89 e5                	mov    %esp,%ebp
  801db1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801db4:	8b 45 08             	mov    0x8(%ebp),%eax
  801db7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801dbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dbf:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801dc4:	8b 45 10             	mov    0x10(%ebp),%eax
  801dc7:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801dcc:	b8 09 00 00 00       	mov    $0x9,%eax
  801dd1:	e8 4d fd ff ff       	call   801b23 <nsipc>
}
  801dd6:	c9                   	leave  
  801dd7:	c3                   	ret    

00801dd8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801dd8:	55                   	push   %ebp
  801dd9:	89 e5                	mov    %esp,%ebp
  801ddb:	56                   	push   %esi
  801ddc:	53                   	push   %ebx
  801ddd:	83 ec 10             	sub    $0x10,%esp
  801de0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801de3:	8b 45 08             	mov    0x8(%ebp),%eax
  801de6:	89 04 24             	mov    %eax,(%esp)
  801de9:	e8 72 f2 ff ff       	call   801060 <fd2data>
  801dee:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801df0:	c7 44 24 04 e4 2a 80 	movl   $0x802ae4,0x4(%esp)
  801df7:	00 
  801df8:	89 1c 24             	mov    %ebx,(%esp)
  801dfb:	e8 e7 e9 ff ff       	call   8007e7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e00:	8b 46 04             	mov    0x4(%esi),%eax
  801e03:	2b 06                	sub    (%esi),%eax
  801e05:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e0b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e12:	00 00 00 
	stat->st_dev = &devpipe;
  801e15:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e1c:	30 80 00 
	return 0;
}
  801e1f:	b8 00 00 00 00       	mov    $0x0,%eax
  801e24:	83 c4 10             	add    $0x10,%esp
  801e27:	5b                   	pop    %ebx
  801e28:	5e                   	pop    %esi
  801e29:	5d                   	pop    %ebp
  801e2a:	c3                   	ret    

00801e2b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e2b:	55                   	push   %ebp
  801e2c:	89 e5                	mov    %esp,%ebp
  801e2e:	53                   	push   %ebx
  801e2f:	83 ec 14             	sub    $0x14,%esp
  801e32:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e35:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e39:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e40:	e8 65 ee ff ff       	call   800caa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e45:	89 1c 24             	mov    %ebx,(%esp)
  801e48:	e8 13 f2 ff ff       	call   801060 <fd2data>
  801e4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e58:	e8 4d ee ff ff       	call   800caa <sys_page_unmap>
}
  801e5d:	83 c4 14             	add    $0x14,%esp
  801e60:	5b                   	pop    %ebx
  801e61:	5d                   	pop    %ebp
  801e62:	c3                   	ret    

00801e63 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e63:	55                   	push   %ebp
  801e64:	89 e5                	mov    %esp,%ebp
  801e66:	57                   	push   %edi
  801e67:	56                   	push   %esi
  801e68:	53                   	push   %ebx
  801e69:	83 ec 2c             	sub    $0x2c,%esp
  801e6c:	89 c6                	mov    %eax,%esi
  801e6e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e71:	a1 08 40 80 00       	mov    0x804008,%eax
  801e76:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e79:	89 34 24             	mov    %esi,(%esp)
  801e7c:	e8 db 04 00 00       	call   80235c <pageref>
  801e81:	89 c7                	mov    %eax,%edi
  801e83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e86:	89 04 24             	mov    %eax,(%esp)
  801e89:	e8 ce 04 00 00       	call   80235c <pageref>
  801e8e:	39 c7                	cmp    %eax,%edi
  801e90:	0f 94 c2             	sete   %dl
  801e93:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801e96:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801e9c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801e9f:	39 fb                	cmp    %edi,%ebx
  801ea1:	74 21                	je     801ec4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ea3:	84 d2                	test   %dl,%dl
  801ea5:	74 ca                	je     801e71 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ea7:	8b 51 58             	mov    0x58(%ecx),%edx
  801eaa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eae:	89 54 24 08          	mov    %edx,0x8(%esp)
  801eb2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801eb6:	c7 04 24 eb 2a 80 00 	movl   $0x802aeb,(%esp)
  801ebd:	e8 04 e3 ff ff       	call   8001c6 <cprintf>
  801ec2:	eb ad                	jmp    801e71 <_pipeisclosed+0xe>
	}
}
  801ec4:	83 c4 2c             	add    $0x2c,%esp
  801ec7:	5b                   	pop    %ebx
  801ec8:	5e                   	pop    %esi
  801ec9:	5f                   	pop    %edi
  801eca:	5d                   	pop    %ebp
  801ecb:	c3                   	ret    

00801ecc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ecc:	55                   	push   %ebp
  801ecd:	89 e5                	mov    %esp,%ebp
  801ecf:	57                   	push   %edi
  801ed0:	56                   	push   %esi
  801ed1:	53                   	push   %ebx
  801ed2:	83 ec 1c             	sub    $0x1c,%esp
  801ed5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ed8:	89 34 24             	mov    %esi,(%esp)
  801edb:	e8 80 f1 ff ff       	call   801060 <fd2data>
  801ee0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ee2:	bf 00 00 00 00       	mov    $0x0,%edi
  801ee7:	eb 45                	jmp    801f2e <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ee9:	89 da                	mov    %ebx,%edx
  801eeb:	89 f0                	mov    %esi,%eax
  801eed:	e8 71 ff ff ff       	call   801e63 <_pipeisclosed>
  801ef2:	85 c0                	test   %eax,%eax
  801ef4:	75 41                	jne    801f37 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ef6:	e8 e9 ec ff ff       	call   800be4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801efb:	8b 43 04             	mov    0x4(%ebx),%eax
  801efe:	8b 0b                	mov    (%ebx),%ecx
  801f00:	8d 51 20             	lea    0x20(%ecx),%edx
  801f03:	39 d0                	cmp    %edx,%eax
  801f05:	73 e2                	jae    801ee9 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f0a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f0e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f11:	99                   	cltd   
  801f12:	c1 ea 1b             	shr    $0x1b,%edx
  801f15:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801f18:	83 e1 1f             	and    $0x1f,%ecx
  801f1b:	29 d1                	sub    %edx,%ecx
  801f1d:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801f21:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801f25:	83 c0 01             	add    $0x1,%eax
  801f28:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f2b:	83 c7 01             	add    $0x1,%edi
  801f2e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f31:	75 c8                	jne    801efb <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f33:	89 f8                	mov    %edi,%eax
  801f35:	eb 05                	jmp    801f3c <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f37:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f3c:	83 c4 1c             	add    $0x1c,%esp
  801f3f:	5b                   	pop    %ebx
  801f40:	5e                   	pop    %esi
  801f41:	5f                   	pop    %edi
  801f42:	5d                   	pop    %ebp
  801f43:	c3                   	ret    

00801f44 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	57                   	push   %edi
  801f48:	56                   	push   %esi
  801f49:	53                   	push   %ebx
  801f4a:	83 ec 1c             	sub    $0x1c,%esp
  801f4d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f50:	89 3c 24             	mov    %edi,(%esp)
  801f53:	e8 08 f1 ff ff       	call   801060 <fd2data>
  801f58:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f5a:	be 00 00 00 00       	mov    $0x0,%esi
  801f5f:	eb 3d                	jmp    801f9e <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f61:	85 f6                	test   %esi,%esi
  801f63:	74 04                	je     801f69 <devpipe_read+0x25>
				return i;
  801f65:	89 f0                	mov    %esi,%eax
  801f67:	eb 43                	jmp    801fac <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f69:	89 da                	mov    %ebx,%edx
  801f6b:	89 f8                	mov    %edi,%eax
  801f6d:	e8 f1 fe ff ff       	call   801e63 <_pipeisclosed>
  801f72:	85 c0                	test   %eax,%eax
  801f74:	75 31                	jne    801fa7 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f76:	e8 69 ec ff ff       	call   800be4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f7b:	8b 03                	mov    (%ebx),%eax
  801f7d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f80:	74 df                	je     801f61 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f82:	99                   	cltd   
  801f83:	c1 ea 1b             	shr    $0x1b,%edx
  801f86:	01 d0                	add    %edx,%eax
  801f88:	83 e0 1f             	and    $0x1f,%eax
  801f8b:	29 d0                	sub    %edx,%eax
  801f8d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801f92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f95:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801f98:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f9b:	83 c6 01             	add    $0x1,%esi
  801f9e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fa1:	75 d8                	jne    801f7b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801fa3:	89 f0                	mov    %esi,%eax
  801fa5:	eb 05                	jmp    801fac <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fa7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801fac:	83 c4 1c             	add    $0x1c,%esp
  801faf:	5b                   	pop    %ebx
  801fb0:	5e                   	pop    %esi
  801fb1:	5f                   	pop    %edi
  801fb2:	5d                   	pop    %ebp
  801fb3:	c3                   	ret    

00801fb4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fb4:	55                   	push   %ebp
  801fb5:	89 e5                	mov    %esp,%ebp
  801fb7:	56                   	push   %esi
  801fb8:	53                   	push   %ebx
  801fb9:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fbf:	89 04 24             	mov    %eax,(%esp)
  801fc2:	e8 b0 f0 ff ff       	call   801077 <fd_alloc>
  801fc7:	89 c2                	mov    %eax,%edx
  801fc9:	85 d2                	test   %edx,%edx
  801fcb:	0f 88 4d 01 00 00    	js     80211e <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fd1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fd8:	00 
  801fd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fdc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fe7:	e8 17 ec ff ff       	call   800c03 <sys_page_alloc>
  801fec:	89 c2                	mov    %eax,%edx
  801fee:	85 d2                	test   %edx,%edx
  801ff0:	0f 88 28 01 00 00    	js     80211e <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ff6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ff9:	89 04 24             	mov    %eax,(%esp)
  801ffc:	e8 76 f0 ff ff       	call   801077 <fd_alloc>
  802001:	89 c3                	mov    %eax,%ebx
  802003:	85 c0                	test   %eax,%eax
  802005:	0f 88 fe 00 00 00    	js     802109 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80200b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802012:	00 
  802013:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802016:	89 44 24 04          	mov    %eax,0x4(%esp)
  80201a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802021:	e8 dd eb ff ff       	call   800c03 <sys_page_alloc>
  802026:	89 c3                	mov    %eax,%ebx
  802028:	85 c0                	test   %eax,%eax
  80202a:	0f 88 d9 00 00 00    	js     802109 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802030:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802033:	89 04 24             	mov    %eax,(%esp)
  802036:	e8 25 f0 ff ff       	call   801060 <fd2data>
  80203b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80203d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802044:	00 
  802045:	89 44 24 04          	mov    %eax,0x4(%esp)
  802049:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802050:	e8 ae eb ff ff       	call   800c03 <sys_page_alloc>
  802055:	89 c3                	mov    %eax,%ebx
  802057:	85 c0                	test   %eax,%eax
  802059:	0f 88 97 00 00 00    	js     8020f6 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80205f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802062:	89 04 24             	mov    %eax,(%esp)
  802065:	e8 f6 ef ff ff       	call   801060 <fd2data>
  80206a:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802071:	00 
  802072:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802076:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80207d:	00 
  80207e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802082:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802089:	e8 c9 eb ff ff       	call   800c57 <sys_page_map>
  80208e:	89 c3                	mov    %eax,%ebx
  802090:	85 c0                	test   %eax,%eax
  802092:	78 52                	js     8020e6 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802094:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80209a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80209d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80209f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020a9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020b2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020b7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c1:	89 04 24             	mov    %eax,(%esp)
  8020c4:	e8 87 ef ff ff       	call   801050 <fd2num>
  8020c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020cc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020d1:	89 04 24             	mov    %eax,(%esp)
  8020d4:	e8 77 ef ff ff       	call   801050 <fd2num>
  8020d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020dc:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020df:	b8 00 00 00 00       	mov    $0x0,%eax
  8020e4:	eb 38                	jmp    80211e <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  8020e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020f1:	e8 b4 eb ff ff       	call   800caa <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8020f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802104:	e8 a1 eb ff ff       	call   800caa <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802109:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80210c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802110:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802117:	e8 8e eb ff ff       	call   800caa <sys_page_unmap>
  80211c:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  80211e:	83 c4 30             	add    $0x30,%esp
  802121:	5b                   	pop    %ebx
  802122:	5e                   	pop    %esi
  802123:	5d                   	pop    %ebp
  802124:	c3                   	ret    

00802125 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802125:	55                   	push   %ebp
  802126:	89 e5                	mov    %esp,%ebp
  802128:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80212b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80212e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802132:	8b 45 08             	mov    0x8(%ebp),%eax
  802135:	89 04 24             	mov    %eax,(%esp)
  802138:	e8 89 ef ff ff       	call   8010c6 <fd_lookup>
  80213d:	89 c2                	mov    %eax,%edx
  80213f:	85 d2                	test   %edx,%edx
  802141:	78 15                	js     802158 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802143:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802146:	89 04 24             	mov    %eax,(%esp)
  802149:	e8 12 ef ff ff       	call   801060 <fd2data>
	return _pipeisclosed(fd, p);
  80214e:	89 c2                	mov    %eax,%edx
  802150:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802153:	e8 0b fd ff ff       	call   801e63 <_pipeisclosed>
}
  802158:	c9                   	leave  
  802159:	c3                   	ret    
  80215a:	66 90                	xchg   %ax,%ax
  80215c:	66 90                	xchg   %ax,%ax
  80215e:	66 90                	xchg   %ax,%ax

00802160 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802160:	55                   	push   %ebp
  802161:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802163:	b8 00 00 00 00       	mov    $0x0,%eax
  802168:	5d                   	pop    %ebp
  802169:	c3                   	ret    

0080216a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80216a:	55                   	push   %ebp
  80216b:	89 e5                	mov    %esp,%ebp
  80216d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802170:	c7 44 24 04 03 2b 80 	movl   $0x802b03,0x4(%esp)
  802177:	00 
  802178:	8b 45 0c             	mov    0xc(%ebp),%eax
  80217b:	89 04 24             	mov    %eax,(%esp)
  80217e:	e8 64 e6 ff ff       	call   8007e7 <strcpy>
	return 0;
}
  802183:	b8 00 00 00 00       	mov    $0x0,%eax
  802188:	c9                   	leave  
  802189:	c3                   	ret    

0080218a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80218a:	55                   	push   %ebp
  80218b:	89 e5                	mov    %esp,%ebp
  80218d:	57                   	push   %edi
  80218e:	56                   	push   %esi
  80218f:	53                   	push   %ebx
  802190:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802196:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80219b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021a1:	eb 31                	jmp    8021d4 <devcons_write+0x4a>
		m = n - tot;
  8021a3:	8b 75 10             	mov    0x10(%ebp),%esi
  8021a6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8021a8:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021ab:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8021b0:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021b3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8021b7:	03 45 0c             	add    0xc(%ebp),%eax
  8021ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021be:	89 3c 24             	mov    %edi,(%esp)
  8021c1:	e8 be e7 ff ff       	call   800984 <memmove>
		sys_cputs(buf, m);
  8021c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ca:	89 3c 24             	mov    %edi,(%esp)
  8021cd:	e8 64 e9 ff ff       	call   800b36 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021d2:	01 f3                	add    %esi,%ebx
  8021d4:	89 d8                	mov    %ebx,%eax
  8021d6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8021d9:	72 c8                	jb     8021a3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021db:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8021e1:	5b                   	pop    %ebx
  8021e2:	5e                   	pop    %esi
  8021e3:	5f                   	pop    %edi
  8021e4:	5d                   	pop    %ebp
  8021e5:	c3                   	ret    

008021e6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021e6:	55                   	push   %ebp
  8021e7:	89 e5                	mov    %esp,%ebp
  8021e9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8021ec:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8021f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021f5:	75 07                	jne    8021fe <devcons_read+0x18>
  8021f7:	eb 2a                	jmp    802223 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021f9:	e8 e6 e9 ff ff       	call   800be4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021fe:	66 90                	xchg   %ax,%ax
  802200:	e8 4f e9 ff ff       	call   800b54 <sys_cgetc>
  802205:	85 c0                	test   %eax,%eax
  802207:	74 f0                	je     8021f9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802209:	85 c0                	test   %eax,%eax
  80220b:	78 16                	js     802223 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80220d:	83 f8 04             	cmp    $0x4,%eax
  802210:	74 0c                	je     80221e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802212:	8b 55 0c             	mov    0xc(%ebp),%edx
  802215:	88 02                	mov    %al,(%edx)
	return 1;
  802217:	b8 01 00 00 00       	mov    $0x1,%eax
  80221c:	eb 05                	jmp    802223 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80221e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802223:	c9                   	leave  
  802224:	c3                   	ret    

00802225 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802225:	55                   	push   %ebp
  802226:	89 e5                	mov    %esp,%ebp
  802228:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80222b:	8b 45 08             	mov    0x8(%ebp),%eax
  80222e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802231:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802238:	00 
  802239:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80223c:	89 04 24             	mov    %eax,(%esp)
  80223f:	e8 f2 e8 ff ff       	call   800b36 <sys_cputs>
}
  802244:	c9                   	leave  
  802245:	c3                   	ret    

00802246 <getchar>:

int
getchar(void)
{
  802246:	55                   	push   %ebp
  802247:	89 e5                	mov    %esp,%ebp
  802249:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80224c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802253:	00 
  802254:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802257:	89 44 24 04          	mov    %eax,0x4(%esp)
  80225b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802262:	e8 f3 f0 ff ff       	call   80135a <read>
	if (r < 0)
  802267:	85 c0                	test   %eax,%eax
  802269:	78 0f                	js     80227a <getchar+0x34>
		return r;
	if (r < 1)
  80226b:	85 c0                	test   %eax,%eax
  80226d:	7e 06                	jle    802275 <getchar+0x2f>
		return -E_EOF;
	return c;
  80226f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802273:	eb 05                	jmp    80227a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802275:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80227a:	c9                   	leave  
  80227b:	c3                   	ret    

0080227c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80227c:	55                   	push   %ebp
  80227d:	89 e5                	mov    %esp,%ebp
  80227f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802282:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802285:	89 44 24 04          	mov    %eax,0x4(%esp)
  802289:	8b 45 08             	mov    0x8(%ebp),%eax
  80228c:	89 04 24             	mov    %eax,(%esp)
  80228f:	e8 32 ee ff ff       	call   8010c6 <fd_lookup>
  802294:	85 c0                	test   %eax,%eax
  802296:	78 11                	js     8022a9 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802298:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80229b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022a1:	39 10                	cmp    %edx,(%eax)
  8022a3:	0f 94 c0             	sete   %al
  8022a6:	0f b6 c0             	movzbl %al,%eax
}
  8022a9:	c9                   	leave  
  8022aa:	c3                   	ret    

008022ab <opencons>:

int
opencons(void)
{
  8022ab:	55                   	push   %ebp
  8022ac:	89 e5                	mov    %esp,%ebp
  8022ae:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022b4:	89 04 24             	mov    %eax,(%esp)
  8022b7:	e8 bb ed ff ff       	call   801077 <fd_alloc>
		return r;
  8022bc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022be:	85 c0                	test   %eax,%eax
  8022c0:	78 40                	js     802302 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022c2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022c9:	00 
  8022ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022d8:	e8 26 e9 ff ff       	call   800c03 <sys_page_alloc>
		return r;
  8022dd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022df:	85 c0                	test   %eax,%eax
  8022e1:	78 1f                	js     802302 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022e3:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ec:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022f1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022f8:	89 04 24             	mov    %eax,(%esp)
  8022fb:	e8 50 ed ff ff       	call   801050 <fd2num>
  802300:	89 c2                	mov    %eax,%edx
}
  802302:	89 d0                	mov    %edx,%eax
  802304:	c9                   	leave  
  802305:	c3                   	ret    

00802306 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802306:	55                   	push   %ebp
  802307:	89 e5                	mov    %esp,%ebp
  802309:	56                   	push   %esi
  80230a:	53                   	push   %ebx
  80230b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80230e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802311:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802317:	e8 a9 e8 ff ff       	call   800bc5 <sys_getenvid>
  80231c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80231f:	89 54 24 10          	mov    %edx,0x10(%esp)
  802323:	8b 55 08             	mov    0x8(%ebp),%edx
  802326:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80232a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80232e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802332:	c7 04 24 10 2b 80 00 	movl   $0x802b10,(%esp)
  802339:	e8 88 de ff ff       	call   8001c6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80233e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802342:	8b 45 10             	mov    0x10(%ebp),%eax
  802345:	89 04 24             	mov    %eax,(%esp)
  802348:	e8 18 de ff ff       	call   800165 <vcprintf>
	cprintf("\n");
  80234d:	c7 04 24 fc 2a 80 00 	movl   $0x802afc,(%esp)
  802354:	e8 6d de ff ff       	call   8001c6 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802359:	cc                   	int3   
  80235a:	eb fd                	jmp    802359 <_panic+0x53>

0080235c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80235c:	55                   	push   %ebp
  80235d:	89 e5                	mov    %esp,%ebp
  80235f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802362:	89 d0                	mov    %edx,%eax
  802364:	c1 e8 16             	shr    $0x16,%eax
  802367:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80236e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802373:	f6 c1 01             	test   $0x1,%cl
  802376:	74 1d                	je     802395 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802378:	c1 ea 0c             	shr    $0xc,%edx
  80237b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802382:	f6 c2 01             	test   $0x1,%dl
  802385:	74 0e                	je     802395 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802387:	c1 ea 0c             	shr    $0xc,%edx
  80238a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802391:	ef 
  802392:	0f b7 c0             	movzwl %ax,%eax
}
  802395:	5d                   	pop    %ebp
  802396:	c3                   	ret    
  802397:	66 90                	xchg   %ax,%ax
  802399:	66 90                	xchg   %ax,%ax
  80239b:	66 90                	xchg   %ax,%ax
  80239d:	66 90                	xchg   %ax,%ax
  80239f:	90                   	nop

008023a0 <__udivdi3>:
  8023a0:	55                   	push   %ebp
  8023a1:	57                   	push   %edi
  8023a2:	56                   	push   %esi
  8023a3:	83 ec 0c             	sub    $0xc,%esp
  8023a6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8023aa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8023ae:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8023b2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8023b6:	85 c0                	test   %eax,%eax
  8023b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8023bc:	89 ea                	mov    %ebp,%edx
  8023be:	89 0c 24             	mov    %ecx,(%esp)
  8023c1:	75 2d                	jne    8023f0 <__udivdi3+0x50>
  8023c3:	39 e9                	cmp    %ebp,%ecx
  8023c5:	77 61                	ja     802428 <__udivdi3+0x88>
  8023c7:	85 c9                	test   %ecx,%ecx
  8023c9:	89 ce                	mov    %ecx,%esi
  8023cb:	75 0b                	jne    8023d8 <__udivdi3+0x38>
  8023cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8023d2:	31 d2                	xor    %edx,%edx
  8023d4:	f7 f1                	div    %ecx
  8023d6:	89 c6                	mov    %eax,%esi
  8023d8:	31 d2                	xor    %edx,%edx
  8023da:	89 e8                	mov    %ebp,%eax
  8023dc:	f7 f6                	div    %esi
  8023de:	89 c5                	mov    %eax,%ebp
  8023e0:	89 f8                	mov    %edi,%eax
  8023e2:	f7 f6                	div    %esi
  8023e4:	89 ea                	mov    %ebp,%edx
  8023e6:	83 c4 0c             	add    $0xc,%esp
  8023e9:	5e                   	pop    %esi
  8023ea:	5f                   	pop    %edi
  8023eb:	5d                   	pop    %ebp
  8023ec:	c3                   	ret    
  8023ed:	8d 76 00             	lea    0x0(%esi),%esi
  8023f0:	39 e8                	cmp    %ebp,%eax
  8023f2:	77 24                	ja     802418 <__udivdi3+0x78>
  8023f4:	0f bd e8             	bsr    %eax,%ebp
  8023f7:	83 f5 1f             	xor    $0x1f,%ebp
  8023fa:	75 3c                	jne    802438 <__udivdi3+0x98>
  8023fc:	8b 74 24 04          	mov    0x4(%esp),%esi
  802400:	39 34 24             	cmp    %esi,(%esp)
  802403:	0f 86 9f 00 00 00    	jbe    8024a8 <__udivdi3+0x108>
  802409:	39 d0                	cmp    %edx,%eax
  80240b:	0f 82 97 00 00 00    	jb     8024a8 <__udivdi3+0x108>
  802411:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802418:	31 d2                	xor    %edx,%edx
  80241a:	31 c0                	xor    %eax,%eax
  80241c:	83 c4 0c             	add    $0xc,%esp
  80241f:	5e                   	pop    %esi
  802420:	5f                   	pop    %edi
  802421:	5d                   	pop    %ebp
  802422:	c3                   	ret    
  802423:	90                   	nop
  802424:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802428:	89 f8                	mov    %edi,%eax
  80242a:	f7 f1                	div    %ecx
  80242c:	31 d2                	xor    %edx,%edx
  80242e:	83 c4 0c             	add    $0xc,%esp
  802431:	5e                   	pop    %esi
  802432:	5f                   	pop    %edi
  802433:	5d                   	pop    %ebp
  802434:	c3                   	ret    
  802435:	8d 76 00             	lea    0x0(%esi),%esi
  802438:	89 e9                	mov    %ebp,%ecx
  80243a:	8b 3c 24             	mov    (%esp),%edi
  80243d:	d3 e0                	shl    %cl,%eax
  80243f:	89 c6                	mov    %eax,%esi
  802441:	b8 20 00 00 00       	mov    $0x20,%eax
  802446:	29 e8                	sub    %ebp,%eax
  802448:	89 c1                	mov    %eax,%ecx
  80244a:	d3 ef                	shr    %cl,%edi
  80244c:	89 e9                	mov    %ebp,%ecx
  80244e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802452:	8b 3c 24             	mov    (%esp),%edi
  802455:	09 74 24 08          	or     %esi,0x8(%esp)
  802459:	89 d6                	mov    %edx,%esi
  80245b:	d3 e7                	shl    %cl,%edi
  80245d:	89 c1                	mov    %eax,%ecx
  80245f:	89 3c 24             	mov    %edi,(%esp)
  802462:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802466:	d3 ee                	shr    %cl,%esi
  802468:	89 e9                	mov    %ebp,%ecx
  80246a:	d3 e2                	shl    %cl,%edx
  80246c:	89 c1                	mov    %eax,%ecx
  80246e:	d3 ef                	shr    %cl,%edi
  802470:	09 d7                	or     %edx,%edi
  802472:	89 f2                	mov    %esi,%edx
  802474:	89 f8                	mov    %edi,%eax
  802476:	f7 74 24 08          	divl   0x8(%esp)
  80247a:	89 d6                	mov    %edx,%esi
  80247c:	89 c7                	mov    %eax,%edi
  80247e:	f7 24 24             	mull   (%esp)
  802481:	39 d6                	cmp    %edx,%esi
  802483:	89 14 24             	mov    %edx,(%esp)
  802486:	72 30                	jb     8024b8 <__udivdi3+0x118>
  802488:	8b 54 24 04          	mov    0x4(%esp),%edx
  80248c:	89 e9                	mov    %ebp,%ecx
  80248e:	d3 e2                	shl    %cl,%edx
  802490:	39 c2                	cmp    %eax,%edx
  802492:	73 05                	jae    802499 <__udivdi3+0xf9>
  802494:	3b 34 24             	cmp    (%esp),%esi
  802497:	74 1f                	je     8024b8 <__udivdi3+0x118>
  802499:	89 f8                	mov    %edi,%eax
  80249b:	31 d2                	xor    %edx,%edx
  80249d:	e9 7a ff ff ff       	jmp    80241c <__udivdi3+0x7c>
  8024a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024a8:	31 d2                	xor    %edx,%edx
  8024aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8024af:	e9 68 ff ff ff       	jmp    80241c <__udivdi3+0x7c>
  8024b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024b8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8024bb:	31 d2                	xor    %edx,%edx
  8024bd:	83 c4 0c             	add    $0xc,%esp
  8024c0:	5e                   	pop    %esi
  8024c1:	5f                   	pop    %edi
  8024c2:	5d                   	pop    %ebp
  8024c3:	c3                   	ret    
  8024c4:	66 90                	xchg   %ax,%ax
  8024c6:	66 90                	xchg   %ax,%ax
  8024c8:	66 90                	xchg   %ax,%ax
  8024ca:	66 90                	xchg   %ax,%ax
  8024cc:	66 90                	xchg   %ax,%ax
  8024ce:	66 90                	xchg   %ax,%ax

008024d0 <__umoddi3>:
  8024d0:	55                   	push   %ebp
  8024d1:	57                   	push   %edi
  8024d2:	56                   	push   %esi
  8024d3:	83 ec 14             	sub    $0x14,%esp
  8024d6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8024da:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8024de:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8024e2:	89 c7                	mov    %eax,%edi
  8024e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024e8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8024ec:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8024f0:	89 34 24             	mov    %esi,(%esp)
  8024f3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024f7:	85 c0                	test   %eax,%eax
  8024f9:	89 c2                	mov    %eax,%edx
  8024fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024ff:	75 17                	jne    802518 <__umoddi3+0x48>
  802501:	39 fe                	cmp    %edi,%esi
  802503:	76 4b                	jbe    802550 <__umoddi3+0x80>
  802505:	89 c8                	mov    %ecx,%eax
  802507:	89 fa                	mov    %edi,%edx
  802509:	f7 f6                	div    %esi
  80250b:	89 d0                	mov    %edx,%eax
  80250d:	31 d2                	xor    %edx,%edx
  80250f:	83 c4 14             	add    $0x14,%esp
  802512:	5e                   	pop    %esi
  802513:	5f                   	pop    %edi
  802514:	5d                   	pop    %ebp
  802515:	c3                   	ret    
  802516:	66 90                	xchg   %ax,%ax
  802518:	39 f8                	cmp    %edi,%eax
  80251a:	77 54                	ja     802570 <__umoddi3+0xa0>
  80251c:	0f bd e8             	bsr    %eax,%ebp
  80251f:	83 f5 1f             	xor    $0x1f,%ebp
  802522:	75 5c                	jne    802580 <__umoddi3+0xb0>
  802524:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802528:	39 3c 24             	cmp    %edi,(%esp)
  80252b:	0f 87 e7 00 00 00    	ja     802618 <__umoddi3+0x148>
  802531:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802535:	29 f1                	sub    %esi,%ecx
  802537:	19 c7                	sbb    %eax,%edi
  802539:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80253d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802541:	8b 44 24 08          	mov    0x8(%esp),%eax
  802545:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802549:	83 c4 14             	add    $0x14,%esp
  80254c:	5e                   	pop    %esi
  80254d:	5f                   	pop    %edi
  80254e:	5d                   	pop    %ebp
  80254f:	c3                   	ret    
  802550:	85 f6                	test   %esi,%esi
  802552:	89 f5                	mov    %esi,%ebp
  802554:	75 0b                	jne    802561 <__umoddi3+0x91>
  802556:	b8 01 00 00 00       	mov    $0x1,%eax
  80255b:	31 d2                	xor    %edx,%edx
  80255d:	f7 f6                	div    %esi
  80255f:	89 c5                	mov    %eax,%ebp
  802561:	8b 44 24 04          	mov    0x4(%esp),%eax
  802565:	31 d2                	xor    %edx,%edx
  802567:	f7 f5                	div    %ebp
  802569:	89 c8                	mov    %ecx,%eax
  80256b:	f7 f5                	div    %ebp
  80256d:	eb 9c                	jmp    80250b <__umoddi3+0x3b>
  80256f:	90                   	nop
  802570:	89 c8                	mov    %ecx,%eax
  802572:	89 fa                	mov    %edi,%edx
  802574:	83 c4 14             	add    $0x14,%esp
  802577:	5e                   	pop    %esi
  802578:	5f                   	pop    %edi
  802579:	5d                   	pop    %ebp
  80257a:	c3                   	ret    
  80257b:	90                   	nop
  80257c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802580:	8b 04 24             	mov    (%esp),%eax
  802583:	be 20 00 00 00       	mov    $0x20,%esi
  802588:	89 e9                	mov    %ebp,%ecx
  80258a:	29 ee                	sub    %ebp,%esi
  80258c:	d3 e2                	shl    %cl,%edx
  80258e:	89 f1                	mov    %esi,%ecx
  802590:	d3 e8                	shr    %cl,%eax
  802592:	89 e9                	mov    %ebp,%ecx
  802594:	89 44 24 04          	mov    %eax,0x4(%esp)
  802598:	8b 04 24             	mov    (%esp),%eax
  80259b:	09 54 24 04          	or     %edx,0x4(%esp)
  80259f:	89 fa                	mov    %edi,%edx
  8025a1:	d3 e0                	shl    %cl,%eax
  8025a3:	89 f1                	mov    %esi,%ecx
  8025a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025a9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8025ad:	d3 ea                	shr    %cl,%edx
  8025af:	89 e9                	mov    %ebp,%ecx
  8025b1:	d3 e7                	shl    %cl,%edi
  8025b3:	89 f1                	mov    %esi,%ecx
  8025b5:	d3 e8                	shr    %cl,%eax
  8025b7:	89 e9                	mov    %ebp,%ecx
  8025b9:	09 f8                	or     %edi,%eax
  8025bb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8025bf:	f7 74 24 04          	divl   0x4(%esp)
  8025c3:	d3 e7                	shl    %cl,%edi
  8025c5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8025c9:	89 d7                	mov    %edx,%edi
  8025cb:	f7 64 24 08          	mull   0x8(%esp)
  8025cf:	39 d7                	cmp    %edx,%edi
  8025d1:	89 c1                	mov    %eax,%ecx
  8025d3:	89 14 24             	mov    %edx,(%esp)
  8025d6:	72 2c                	jb     802604 <__umoddi3+0x134>
  8025d8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8025dc:	72 22                	jb     802600 <__umoddi3+0x130>
  8025de:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8025e2:	29 c8                	sub    %ecx,%eax
  8025e4:	19 d7                	sbb    %edx,%edi
  8025e6:	89 e9                	mov    %ebp,%ecx
  8025e8:	89 fa                	mov    %edi,%edx
  8025ea:	d3 e8                	shr    %cl,%eax
  8025ec:	89 f1                	mov    %esi,%ecx
  8025ee:	d3 e2                	shl    %cl,%edx
  8025f0:	89 e9                	mov    %ebp,%ecx
  8025f2:	d3 ef                	shr    %cl,%edi
  8025f4:	09 d0                	or     %edx,%eax
  8025f6:	89 fa                	mov    %edi,%edx
  8025f8:	83 c4 14             	add    $0x14,%esp
  8025fb:	5e                   	pop    %esi
  8025fc:	5f                   	pop    %edi
  8025fd:	5d                   	pop    %ebp
  8025fe:	c3                   	ret    
  8025ff:	90                   	nop
  802600:	39 d7                	cmp    %edx,%edi
  802602:	75 da                	jne    8025de <__umoddi3+0x10e>
  802604:	8b 14 24             	mov    (%esp),%edx
  802607:	89 c1                	mov    %eax,%ecx
  802609:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80260d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802611:	eb cb                	jmp    8025de <__umoddi3+0x10e>
  802613:	90                   	nop
  802614:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802618:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80261c:	0f 82 0f ff ff ff    	jb     802531 <__umoddi3+0x61>
  802622:	e9 1a ff ff ff       	jmp    802541 <__umoddi3+0x71>
