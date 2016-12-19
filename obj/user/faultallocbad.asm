
obj/user/faultallocbad.debug:     file format elf32-i386


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
  80002c:	e8 af 00 00 00       	call   8000e0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800043:	c7 04 24 e0 26 80 00 	movl   $0x8026e0,(%esp)
  80004a:	e8 eb 01 00 00       	call   80023a <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800056:	00 
  800057:	89 d8                	mov    %ebx,%eax
  800059:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800062:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800069:	e8 15 0c 00 00       	call   800c83 <sys_page_alloc>
  80006e:	85 c0                	test   %eax,%eax
  800070:	79 24                	jns    800096 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800072:	89 44 24 10          	mov    %eax,0x10(%esp)
  800076:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007a:	c7 44 24 08 00 27 80 	movl   $0x802700,0x8(%esp)
  800081:	00 
  800082:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800089:	00 
  80008a:	c7 04 24 ea 26 80 00 	movl   $0x8026ea,(%esp)
  800091:	e8 ab 00 00 00       	call   800141 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800096:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009a:	c7 44 24 08 2c 27 80 	movl   $0x80272c,0x8(%esp)
  8000a1:	00 
  8000a2:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000a9:	00 
  8000aa:	89 1c 24             	mov    %ebx,(%esp)
  8000ad:	e8 48 07 00 00       	call   8007fa <snprintf>
}
  8000b2:	83 c4 24             	add    $0x24,%esp
  8000b5:	5b                   	pop    %ebx
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <umain>:

void
umain(int argc, char **argv)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  8000be:	c7 04 24 33 00 80 00 	movl   $0x800033,(%esp)
  8000c5:	e8 e6 0e 00 00       	call   800fb0 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000ca:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000d1:	00 
  8000d2:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000d9:	e8 d8 0a 00 00       	call   800bb6 <sys_cputs>
}
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 10             	sub    $0x10,%esp
  8000e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000eb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ee:	e8 52 0b 00 00       	call   800c45 <sys_getenvid>
  8000f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000fb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800100:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800105:	85 db                	test   %ebx,%ebx
  800107:	7e 07                	jle    800110 <libmain+0x30>
		binaryname = argv[0];
  800109:	8b 06                	mov    (%esi),%eax
  80010b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800110:	89 74 24 04          	mov    %esi,0x4(%esp)
  800114:	89 1c 24             	mov    %ebx,(%esp)
  800117:	e8 9c ff ff ff       	call   8000b8 <umain>

	// exit gracefully
	exit();
  80011c:	e8 07 00 00 00       	call   800128 <exit>
}
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	5b                   	pop    %ebx
  800125:	5e                   	pop    %esi
  800126:	5d                   	pop    %ebp
  800127:	c3                   	ret    

00800128 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80012e:	e8 d7 10 00 00       	call   80120a <close_all>
	sys_env_destroy(0);
  800133:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80013a:	e8 b4 0a 00 00       	call   800bf3 <sys_env_destroy>
}
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	56                   	push   %esi
  800145:	53                   	push   %ebx
  800146:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800149:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800152:	e8 ee 0a 00 00       	call   800c45 <sys_getenvid>
  800157:	8b 55 0c             	mov    0xc(%ebp),%edx
  80015a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80015e:	8b 55 08             	mov    0x8(%ebp),%edx
  800161:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800165:	89 74 24 08          	mov    %esi,0x8(%esp)
  800169:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016d:	c7 04 24 58 27 80 00 	movl   $0x802758,(%esp)
  800174:	e8 c1 00 00 00       	call   80023a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800179:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80017d:	8b 45 10             	mov    0x10(%ebp),%eax
  800180:	89 04 24             	mov    %eax,(%esp)
  800183:	e8 51 00 00 00       	call   8001d9 <vcprintf>
	cprintf("\n");
  800188:	c7 04 24 c0 2b 80 00 	movl   $0x802bc0,(%esp)
  80018f:	e8 a6 00 00 00       	call   80023a <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800194:	cc                   	int3   
  800195:	eb fd                	jmp    800194 <_panic+0x53>

00800197 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	53                   	push   %ebx
  80019b:	83 ec 14             	sub    $0x14,%esp
  80019e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a1:	8b 13                	mov    (%ebx),%edx
  8001a3:	8d 42 01             	lea    0x1(%edx),%eax
  8001a6:	89 03                	mov    %eax,(%ebx)
  8001a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ab:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001af:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b4:	75 19                	jne    8001cf <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001b6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001bd:	00 
  8001be:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c1:	89 04 24             	mov    %eax,(%esp)
  8001c4:	e8 ed 09 00 00       	call   800bb6 <sys_cputs>
		b->idx = 0;
  8001c9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001cf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d3:	83 c4 14             	add    $0x14,%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5d                   	pop    %ebp
  8001d8:	c3                   	ret    

008001d9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001e2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e9:	00 00 00 
	b.cnt = 0;
  8001ec:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800200:	89 44 24 08          	mov    %eax,0x8(%esp)
  800204:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020e:	c7 04 24 97 01 80 00 	movl   $0x800197,(%esp)
  800215:	e8 b4 01 00 00       	call   8003ce <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80021a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800220:	89 44 24 04          	mov    %eax,0x4(%esp)
  800224:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80022a:	89 04 24             	mov    %eax,(%esp)
  80022d:	e8 84 09 00 00       	call   800bb6 <sys_cputs>

	return b.cnt;
}
  800232:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800240:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800243:	89 44 24 04          	mov    %eax,0x4(%esp)
  800247:	8b 45 08             	mov    0x8(%ebp),%eax
  80024a:	89 04 24             	mov    %eax,(%esp)
  80024d:	e8 87 ff ff ff       	call   8001d9 <vcprintf>
	va_end(ap);

	return cnt;
}
  800252:	c9                   	leave  
  800253:	c3                   	ret    
  800254:	66 90                	xchg   %ax,%ax
  800256:	66 90                	xchg   %ax,%ax
  800258:	66 90                	xchg   %ax,%ax
  80025a:	66 90                	xchg   %ax,%ax
  80025c:	66 90                	xchg   %ax,%ax
  80025e:	66 90                	xchg   %ax,%ax

00800260 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	57                   	push   %edi
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
  800266:	83 ec 3c             	sub    $0x3c,%esp
  800269:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80026c:	89 d7                	mov    %edx,%edi
  80026e:	8b 45 08             	mov    0x8(%ebp),%eax
  800271:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800274:	8b 45 0c             	mov    0xc(%ebp),%eax
  800277:	89 c3                	mov    %eax,%ebx
  800279:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80027c:	8b 45 10             	mov    0x10(%ebp),%eax
  80027f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800282:	b9 00 00 00 00       	mov    $0x0,%ecx
  800287:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80028a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80028d:	39 d9                	cmp    %ebx,%ecx
  80028f:	72 05                	jb     800296 <printnum+0x36>
  800291:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800294:	77 69                	ja     8002ff <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800296:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800299:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80029d:	83 ee 01             	sub    $0x1,%esi
  8002a0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002ac:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002b0:	89 c3                	mov    %eax,%ebx
  8002b2:	89 d6                	mov    %edx,%esi
  8002b4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002b7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002ba:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002be:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c5:	89 04 24             	mov    %eax,(%esp)
  8002c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cf:	e8 7c 21 00 00       	call   802450 <__udivdi3>
  8002d4:	89 d9                	mov    %ebx,%ecx
  8002d6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002da:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002de:	89 04 24             	mov    %eax,(%esp)
  8002e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e5:	89 fa                	mov    %edi,%edx
  8002e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ea:	e8 71 ff ff ff       	call   800260 <printnum>
  8002ef:	eb 1b                	jmp    80030c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f5:	8b 45 18             	mov    0x18(%ebp),%eax
  8002f8:	89 04 24             	mov    %eax,(%esp)
  8002fb:	ff d3                	call   *%ebx
  8002fd:	eb 03                	jmp    800302 <printnum+0xa2>
  8002ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800302:	83 ee 01             	sub    $0x1,%esi
  800305:	85 f6                	test   %esi,%esi
  800307:	7f e8                	jg     8002f1 <printnum+0x91>
  800309:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800310:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800314:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800317:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80031a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800322:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800325:	89 04 24             	mov    %eax,(%esp)
  800328:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	e8 4c 22 00 00       	call   802580 <__umoddi3>
  800334:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800338:	0f be 80 7b 27 80 00 	movsbl 0x80277b(%eax),%eax
  80033f:	89 04 24             	mov    %eax,(%esp)
  800342:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800345:	ff d0                	call   *%eax
}
  800347:	83 c4 3c             	add    $0x3c,%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800352:	83 fa 01             	cmp    $0x1,%edx
  800355:	7e 0e                	jle    800365 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800357:	8b 10                	mov    (%eax),%edx
  800359:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035c:	89 08                	mov    %ecx,(%eax)
  80035e:	8b 02                	mov    (%edx),%eax
  800360:	8b 52 04             	mov    0x4(%edx),%edx
  800363:	eb 22                	jmp    800387 <getuint+0x38>
	else if (lflag)
  800365:	85 d2                	test   %edx,%edx
  800367:	74 10                	je     800379 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800369:	8b 10                	mov    (%eax),%edx
  80036b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036e:	89 08                	mov    %ecx,(%eax)
  800370:	8b 02                	mov    (%edx),%eax
  800372:	ba 00 00 00 00       	mov    $0x0,%edx
  800377:	eb 0e                	jmp    800387 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 02                	mov    (%edx),%eax
  800382:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800387:	5d                   	pop    %ebp
  800388:	c3                   	ret    

00800389 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80038f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800393:	8b 10                	mov    (%eax),%edx
  800395:	3b 50 04             	cmp    0x4(%eax),%edx
  800398:	73 0a                	jae    8003a4 <sprintputch+0x1b>
		*b->buf++ = ch;
  80039a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80039d:	89 08                	mov    %ecx,(%eax)
  80039f:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a2:	88 02                	mov    %al,(%edx)
}
  8003a4:	5d                   	pop    %ebp
  8003a5:	c3                   	ret    

008003a6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c4:	89 04 24             	mov    %eax,(%esp)
  8003c7:	e8 02 00 00 00       	call   8003ce <vprintfmt>
	va_end(ap);
}
  8003cc:	c9                   	leave  
  8003cd:	c3                   	ret    

008003ce <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ce:	55                   	push   %ebp
  8003cf:	89 e5                	mov    %esp,%ebp
  8003d1:	57                   	push   %edi
  8003d2:	56                   	push   %esi
  8003d3:	53                   	push   %ebx
  8003d4:	83 ec 3c             	sub    $0x3c,%esp
  8003d7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003dd:	eb 14                	jmp    8003f3 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003df:	85 c0                	test   %eax,%eax
  8003e1:	0f 84 b3 03 00 00    	je     80079a <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  8003e7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003eb:	89 04 24             	mov    %eax,(%esp)
  8003ee:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f1:	89 f3                	mov    %esi,%ebx
  8003f3:	8d 73 01             	lea    0x1(%ebx),%esi
  8003f6:	0f b6 03             	movzbl (%ebx),%eax
  8003f9:	83 f8 25             	cmp    $0x25,%eax
  8003fc:	75 e1                	jne    8003df <vprintfmt+0x11>
  8003fe:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800402:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800409:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800410:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800417:	ba 00 00 00 00       	mov    $0x0,%edx
  80041c:	eb 1d                	jmp    80043b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800420:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800424:	eb 15                	jmp    80043b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800428:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80042c:	eb 0d                	jmp    80043b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80042e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800431:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800434:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80043e:	0f b6 0e             	movzbl (%esi),%ecx
  800441:	0f b6 c1             	movzbl %cl,%eax
  800444:	83 e9 23             	sub    $0x23,%ecx
  800447:	80 f9 55             	cmp    $0x55,%cl
  80044a:	0f 87 2a 03 00 00    	ja     80077a <vprintfmt+0x3ac>
  800450:	0f b6 c9             	movzbl %cl,%ecx
  800453:	ff 24 8d c0 28 80 00 	jmp    *0x8028c0(,%ecx,4)
  80045a:	89 de                	mov    %ebx,%esi
  80045c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800461:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800464:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800468:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80046b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80046e:	83 fb 09             	cmp    $0x9,%ebx
  800471:	77 36                	ja     8004a9 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800473:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800476:	eb e9                	jmp    800461 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800478:	8b 45 14             	mov    0x14(%ebp),%eax
  80047b:	8d 48 04             	lea    0x4(%eax),%ecx
  80047e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800481:	8b 00                	mov    (%eax),%eax
  800483:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800488:	eb 22                	jmp    8004ac <vprintfmt+0xde>
  80048a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80048d:	85 c9                	test   %ecx,%ecx
  80048f:	b8 00 00 00 00       	mov    $0x0,%eax
  800494:	0f 49 c1             	cmovns %ecx,%eax
  800497:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049a:	89 de                	mov    %ebx,%esi
  80049c:	eb 9d                	jmp    80043b <vprintfmt+0x6d>
  80049e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004a0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004a7:	eb 92                	jmp    80043b <vprintfmt+0x6d>
  8004a9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8004ac:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004b0:	79 89                	jns    80043b <vprintfmt+0x6d>
  8004b2:	e9 77 ff ff ff       	jmp    80042e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004b7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004bc:	e9 7a ff ff ff       	jmp    80043b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c4:	8d 50 04             	lea    0x4(%eax),%edx
  8004c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ce:	8b 00                	mov    (%eax),%eax
  8004d0:	89 04 24             	mov    %eax,(%esp)
  8004d3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004d6:	e9 18 ff ff ff       	jmp    8003f3 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004db:	8b 45 14             	mov    0x14(%ebp),%eax
  8004de:	8d 50 04             	lea    0x4(%eax),%edx
  8004e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e4:	8b 00                	mov    (%eax),%eax
  8004e6:	99                   	cltd   
  8004e7:	31 d0                	xor    %edx,%eax
  8004e9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004eb:	83 f8 0f             	cmp    $0xf,%eax
  8004ee:	7f 0b                	jg     8004fb <vprintfmt+0x12d>
  8004f0:	8b 14 85 20 2a 80 00 	mov    0x802a20(,%eax,4),%edx
  8004f7:	85 d2                	test   %edx,%edx
  8004f9:	75 20                	jne    80051b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  8004fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004ff:	c7 44 24 08 93 27 80 	movl   $0x802793,0x8(%esp)
  800506:	00 
  800507:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80050b:	8b 45 08             	mov    0x8(%ebp),%eax
  80050e:	89 04 24             	mov    %eax,(%esp)
  800511:	e8 90 fe ff ff       	call   8003a6 <printfmt>
  800516:	e9 d8 fe ff ff       	jmp    8003f3 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80051b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80051f:	c7 44 24 08 55 2b 80 	movl   $0x802b55,0x8(%esp)
  800526:	00 
  800527:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80052b:	8b 45 08             	mov    0x8(%ebp),%eax
  80052e:	89 04 24             	mov    %eax,(%esp)
  800531:	e8 70 fe ff ff       	call   8003a6 <printfmt>
  800536:	e9 b8 fe ff ff       	jmp    8003f3 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80053e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800541:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800544:	8b 45 14             	mov    0x14(%ebp),%eax
  800547:	8d 50 04             	lea    0x4(%eax),%edx
  80054a:	89 55 14             	mov    %edx,0x14(%ebp)
  80054d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80054f:	85 f6                	test   %esi,%esi
  800551:	b8 8c 27 80 00       	mov    $0x80278c,%eax
  800556:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800559:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80055d:	0f 84 97 00 00 00    	je     8005fa <vprintfmt+0x22c>
  800563:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800567:	0f 8e 9b 00 00 00    	jle    800608 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80056d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800571:	89 34 24             	mov    %esi,(%esp)
  800574:	e8 cf 02 00 00       	call   800848 <strnlen>
  800579:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80057c:	29 c2                	sub    %eax,%edx
  80057e:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800581:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800585:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800588:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80058b:	8b 75 08             	mov    0x8(%ebp),%esi
  80058e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800591:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800593:	eb 0f                	jmp    8005a4 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800595:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800599:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80059c:	89 04 24             	mov    %eax,(%esp)
  80059f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a1:	83 eb 01             	sub    $0x1,%ebx
  8005a4:	85 db                	test   %ebx,%ebx
  8005a6:	7f ed                	jg     800595 <vprintfmt+0x1c7>
  8005a8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005ab:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005ae:	85 d2                	test   %edx,%edx
  8005b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b5:	0f 49 c2             	cmovns %edx,%eax
  8005b8:	29 c2                	sub    %eax,%edx
  8005ba:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005bd:	89 d7                	mov    %edx,%edi
  8005bf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005c2:	eb 50                	jmp    800614 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005c4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005c8:	74 1e                	je     8005e8 <vprintfmt+0x21a>
  8005ca:	0f be d2             	movsbl %dl,%edx
  8005cd:	83 ea 20             	sub    $0x20,%edx
  8005d0:	83 fa 5e             	cmp    $0x5e,%edx
  8005d3:	76 13                	jbe    8005e8 <vprintfmt+0x21a>
					putch('?', putdat);
  8005d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005dc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005e3:	ff 55 08             	call   *0x8(%ebp)
  8005e6:	eb 0d                	jmp    8005f5 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8005e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005ef:	89 04 24             	mov    %eax,(%esp)
  8005f2:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f5:	83 ef 01             	sub    $0x1,%edi
  8005f8:	eb 1a                	jmp    800614 <vprintfmt+0x246>
  8005fa:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005fd:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800600:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800603:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800606:	eb 0c                	jmp    800614 <vprintfmt+0x246>
  800608:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80060b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80060e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800611:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800614:	83 c6 01             	add    $0x1,%esi
  800617:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80061b:	0f be c2             	movsbl %dl,%eax
  80061e:	85 c0                	test   %eax,%eax
  800620:	74 27                	je     800649 <vprintfmt+0x27b>
  800622:	85 db                	test   %ebx,%ebx
  800624:	78 9e                	js     8005c4 <vprintfmt+0x1f6>
  800626:	83 eb 01             	sub    $0x1,%ebx
  800629:	79 99                	jns    8005c4 <vprintfmt+0x1f6>
  80062b:	89 f8                	mov    %edi,%eax
  80062d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800630:	8b 75 08             	mov    0x8(%ebp),%esi
  800633:	89 c3                	mov    %eax,%ebx
  800635:	eb 1a                	jmp    800651 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800637:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80063b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800642:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800644:	83 eb 01             	sub    $0x1,%ebx
  800647:	eb 08                	jmp    800651 <vprintfmt+0x283>
  800649:	89 fb                	mov    %edi,%ebx
  80064b:	8b 75 08             	mov    0x8(%ebp),%esi
  80064e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800651:	85 db                	test   %ebx,%ebx
  800653:	7f e2                	jg     800637 <vprintfmt+0x269>
  800655:	89 75 08             	mov    %esi,0x8(%ebp)
  800658:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80065b:	e9 93 fd ff ff       	jmp    8003f3 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800660:	83 fa 01             	cmp    $0x1,%edx
  800663:	7e 16                	jle    80067b <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8d 50 08             	lea    0x8(%eax),%edx
  80066b:	89 55 14             	mov    %edx,0x14(%ebp)
  80066e:	8b 50 04             	mov    0x4(%eax),%edx
  800671:	8b 00                	mov    (%eax),%eax
  800673:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800676:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800679:	eb 32                	jmp    8006ad <vprintfmt+0x2df>
	else if (lflag)
  80067b:	85 d2                	test   %edx,%edx
  80067d:	74 18                	je     800697 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  80067f:	8b 45 14             	mov    0x14(%ebp),%eax
  800682:	8d 50 04             	lea    0x4(%eax),%edx
  800685:	89 55 14             	mov    %edx,0x14(%ebp)
  800688:	8b 30                	mov    (%eax),%esi
  80068a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80068d:	89 f0                	mov    %esi,%eax
  80068f:	c1 f8 1f             	sar    $0x1f,%eax
  800692:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800695:	eb 16                	jmp    8006ad <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8d 50 04             	lea    0x4(%eax),%edx
  80069d:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a0:	8b 30                	mov    (%eax),%esi
  8006a2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006a5:	89 f0                	mov    %esi,%eax
  8006a7:	c1 f8 1f             	sar    $0x1f,%eax
  8006aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006b3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006b8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006bc:	0f 89 80 00 00 00    	jns    800742 <vprintfmt+0x374>
				putch('-', putdat);
  8006c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006c6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006cd:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006d3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006d6:	f7 d8                	neg    %eax
  8006d8:	83 d2 00             	adc    $0x0,%edx
  8006db:	f7 da                	neg    %edx
			}
			base = 10;
  8006dd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006e2:	eb 5e                	jmp    800742 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006e4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e7:	e8 63 fc ff ff       	call   80034f <getuint>
			base = 10;
  8006ec:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006f1:	eb 4f                	jmp    800742 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8006f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f6:	e8 54 fc ff ff       	call   80034f <getuint>
			base = 8;
  8006fb:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800700:	eb 40                	jmp    800742 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800702:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800706:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80070d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800710:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800714:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80071b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80071e:	8b 45 14             	mov    0x14(%ebp),%eax
  800721:	8d 50 04             	lea    0x4(%eax),%edx
  800724:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800727:	8b 00                	mov    (%eax),%eax
  800729:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80072e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800733:	eb 0d                	jmp    800742 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800735:	8d 45 14             	lea    0x14(%ebp),%eax
  800738:	e8 12 fc ff ff       	call   80034f <getuint>
			base = 16;
  80073d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800742:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800746:	89 74 24 10          	mov    %esi,0x10(%esp)
  80074a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80074d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800751:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800755:	89 04 24             	mov    %eax,(%esp)
  800758:	89 54 24 04          	mov    %edx,0x4(%esp)
  80075c:	89 fa                	mov    %edi,%edx
  80075e:	8b 45 08             	mov    0x8(%ebp),%eax
  800761:	e8 fa fa ff ff       	call   800260 <printnum>
			break;
  800766:	e9 88 fc ff ff       	jmp    8003f3 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80076b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80076f:	89 04 24             	mov    %eax,(%esp)
  800772:	ff 55 08             	call   *0x8(%ebp)
			break;
  800775:	e9 79 fc ff ff       	jmp    8003f3 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80077a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80077e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800785:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800788:	89 f3                	mov    %esi,%ebx
  80078a:	eb 03                	jmp    80078f <vprintfmt+0x3c1>
  80078c:	83 eb 01             	sub    $0x1,%ebx
  80078f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800793:	75 f7                	jne    80078c <vprintfmt+0x3be>
  800795:	e9 59 fc ff ff       	jmp    8003f3 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  80079a:	83 c4 3c             	add    $0x3c,%esp
  80079d:	5b                   	pop    %ebx
  80079e:	5e                   	pop    %esi
  80079f:	5f                   	pop    %edi
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	83 ec 28             	sub    $0x28,%esp
  8007a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007bf:	85 c0                	test   %eax,%eax
  8007c1:	74 30                	je     8007f3 <vsnprintf+0x51>
  8007c3:	85 d2                	test   %edx,%edx
  8007c5:	7e 2c                	jle    8007f3 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007dc:	c7 04 24 89 03 80 00 	movl   $0x800389,(%esp)
  8007e3:	e8 e6 fb ff ff       	call   8003ce <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007eb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f1:	eb 05                	jmp    8007f8 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007f8:	c9                   	leave  
  8007f9:	c3                   	ret    

008007fa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800800:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800803:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800807:	8b 45 10             	mov    0x10(%ebp),%eax
  80080a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800811:	89 44 24 04          	mov    %eax,0x4(%esp)
  800815:	8b 45 08             	mov    0x8(%ebp),%eax
  800818:	89 04 24             	mov    %eax,(%esp)
  80081b:	e8 82 ff ff ff       	call   8007a2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800820:	c9                   	leave  
  800821:	c3                   	ret    
  800822:	66 90                	xchg   %ax,%ax
  800824:	66 90                	xchg   %ax,%ax
  800826:	66 90                	xchg   %ax,%ax
  800828:	66 90                	xchg   %ax,%ax
  80082a:	66 90                	xchg   %ax,%ax
  80082c:	66 90                	xchg   %ax,%ax
  80082e:	66 90                	xchg   %ax,%ax

00800830 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800836:	b8 00 00 00 00       	mov    $0x0,%eax
  80083b:	eb 03                	jmp    800840 <strlen+0x10>
		n++;
  80083d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800840:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800844:	75 f7                	jne    80083d <strlen+0xd>
		n++;
	return n;
}
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800851:	b8 00 00 00 00       	mov    $0x0,%eax
  800856:	eb 03                	jmp    80085b <strnlen+0x13>
		n++;
  800858:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085b:	39 d0                	cmp    %edx,%eax
  80085d:	74 06                	je     800865 <strnlen+0x1d>
  80085f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800863:	75 f3                	jne    800858 <strnlen+0x10>
		n++;
	return n;
}
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	53                   	push   %ebx
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800871:	89 c2                	mov    %eax,%edx
  800873:	83 c2 01             	add    $0x1,%edx
  800876:	83 c1 01             	add    $0x1,%ecx
  800879:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80087d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800880:	84 db                	test   %bl,%bl
  800882:	75 ef                	jne    800873 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800884:	5b                   	pop    %ebx
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	53                   	push   %ebx
  80088b:	83 ec 08             	sub    $0x8,%esp
  80088e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800891:	89 1c 24             	mov    %ebx,(%esp)
  800894:	e8 97 ff ff ff       	call   800830 <strlen>
	strcpy(dst + len, src);
  800899:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089c:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008a0:	01 d8                	add    %ebx,%eax
  8008a2:	89 04 24             	mov    %eax,(%esp)
  8008a5:	e8 bd ff ff ff       	call   800867 <strcpy>
	return dst;
}
  8008aa:	89 d8                	mov    %ebx,%eax
  8008ac:	83 c4 08             	add    $0x8,%esp
  8008af:	5b                   	pop    %ebx
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	56                   	push   %esi
  8008b6:	53                   	push   %ebx
  8008b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008bd:	89 f3                	mov    %esi,%ebx
  8008bf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c2:	89 f2                	mov    %esi,%edx
  8008c4:	eb 0f                	jmp    8008d5 <strncpy+0x23>
		*dst++ = *src;
  8008c6:	83 c2 01             	add    $0x1,%edx
  8008c9:	0f b6 01             	movzbl (%ecx),%eax
  8008cc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008cf:	80 39 01             	cmpb   $0x1,(%ecx)
  8008d2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d5:	39 da                	cmp    %ebx,%edx
  8008d7:	75 ed                	jne    8008c6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008d9:	89 f0                	mov    %esi,%eax
  8008db:	5b                   	pop    %ebx
  8008dc:	5e                   	pop    %esi
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	56                   	push   %esi
  8008e3:	53                   	push   %ebx
  8008e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008ed:	89 f0                	mov    %esi,%eax
  8008ef:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f3:	85 c9                	test   %ecx,%ecx
  8008f5:	75 0b                	jne    800902 <strlcpy+0x23>
  8008f7:	eb 1d                	jmp    800916 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008f9:	83 c0 01             	add    $0x1,%eax
  8008fc:	83 c2 01             	add    $0x1,%edx
  8008ff:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800902:	39 d8                	cmp    %ebx,%eax
  800904:	74 0b                	je     800911 <strlcpy+0x32>
  800906:	0f b6 0a             	movzbl (%edx),%ecx
  800909:	84 c9                	test   %cl,%cl
  80090b:	75 ec                	jne    8008f9 <strlcpy+0x1a>
  80090d:	89 c2                	mov    %eax,%edx
  80090f:	eb 02                	jmp    800913 <strlcpy+0x34>
  800911:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800913:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800916:	29 f0                	sub    %esi,%eax
}
  800918:	5b                   	pop    %ebx
  800919:	5e                   	pop    %esi
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800922:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800925:	eb 06                	jmp    80092d <strcmp+0x11>
		p++, q++;
  800927:	83 c1 01             	add    $0x1,%ecx
  80092a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80092d:	0f b6 01             	movzbl (%ecx),%eax
  800930:	84 c0                	test   %al,%al
  800932:	74 04                	je     800938 <strcmp+0x1c>
  800934:	3a 02                	cmp    (%edx),%al
  800936:	74 ef                	je     800927 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800938:	0f b6 c0             	movzbl %al,%eax
  80093b:	0f b6 12             	movzbl (%edx),%edx
  80093e:	29 d0                	sub    %edx,%eax
}
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	53                   	push   %ebx
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094c:	89 c3                	mov    %eax,%ebx
  80094e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800951:	eb 06                	jmp    800959 <strncmp+0x17>
		n--, p++, q++;
  800953:	83 c0 01             	add    $0x1,%eax
  800956:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800959:	39 d8                	cmp    %ebx,%eax
  80095b:	74 15                	je     800972 <strncmp+0x30>
  80095d:	0f b6 08             	movzbl (%eax),%ecx
  800960:	84 c9                	test   %cl,%cl
  800962:	74 04                	je     800968 <strncmp+0x26>
  800964:	3a 0a                	cmp    (%edx),%cl
  800966:	74 eb                	je     800953 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800968:	0f b6 00             	movzbl (%eax),%eax
  80096b:	0f b6 12             	movzbl (%edx),%edx
  80096e:	29 d0                	sub    %edx,%eax
  800970:	eb 05                	jmp    800977 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800972:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800977:	5b                   	pop    %ebx
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800984:	eb 07                	jmp    80098d <strchr+0x13>
		if (*s == c)
  800986:	38 ca                	cmp    %cl,%dl
  800988:	74 0f                	je     800999 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80098a:	83 c0 01             	add    $0x1,%eax
  80098d:	0f b6 10             	movzbl (%eax),%edx
  800990:	84 d2                	test   %dl,%dl
  800992:	75 f2                	jne    800986 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800994:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a5:	eb 07                	jmp    8009ae <strfind+0x13>
		if (*s == c)
  8009a7:	38 ca                	cmp    %cl,%dl
  8009a9:	74 0a                	je     8009b5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009ab:	83 c0 01             	add    $0x1,%eax
  8009ae:	0f b6 10             	movzbl (%eax),%edx
  8009b1:	84 d2                	test   %dl,%dl
  8009b3:	75 f2                	jne    8009a7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	57                   	push   %edi
  8009bb:	56                   	push   %esi
  8009bc:	53                   	push   %ebx
  8009bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c3:	85 c9                	test   %ecx,%ecx
  8009c5:	74 36                	je     8009fd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009c7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009cd:	75 28                	jne    8009f7 <memset+0x40>
  8009cf:	f6 c1 03             	test   $0x3,%cl
  8009d2:	75 23                	jne    8009f7 <memset+0x40>
		c &= 0xFF;
  8009d4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009d8:	89 d3                	mov    %edx,%ebx
  8009da:	c1 e3 08             	shl    $0x8,%ebx
  8009dd:	89 d6                	mov    %edx,%esi
  8009df:	c1 e6 18             	shl    $0x18,%esi
  8009e2:	89 d0                	mov    %edx,%eax
  8009e4:	c1 e0 10             	shl    $0x10,%eax
  8009e7:	09 f0                	or     %esi,%eax
  8009e9:	09 c2                	or     %eax,%edx
  8009eb:	89 d0                	mov    %edx,%eax
  8009ed:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009ef:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009f2:	fc                   	cld    
  8009f3:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f5:	eb 06                	jmp    8009fd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fa:	fc                   	cld    
  8009fb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009fd:	89 f8                	mov    %edi,%eax
  8009ff:	5b                   	pop    %ebx
  800a00:	5e                   	pop    %esi
  800a01:	5f                   	pop    %edi
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    

00800a04 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	57                   	push   %edi
  800a08:	56                   	push   %esi
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a12:	39 c6                	cmp    %eax,%esi
  800a14:	73 35                	jae    800a4b <memmove+0x47>
  800a16:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a19:	39 d0                	cmp    %edx,%eax
  800a1b:	73 2e                	jae    800a4b <memmove+0x47>
		s += n;
		d += n;
  800a1d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a20:	89 d6                	mov    %edx,%esi
  800a22:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a24:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a2a:	75 13                	jne    800a3f <memmove+0x3b>
  800a2c:	f6 c1 03             	test   $0x3,%cl
  800a2f:	75 0e                	jne    800a3f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a31:	83 ef 04             	sub    $0x4,%edi
  800a34:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a37:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a3a:	fd                   	std    
  800a3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3d:	eb 09                	jmp    800a48 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a3f:	83 ef 01             	sub    $0x1,%edi
  800a42:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a45:	fd                   	std    
  800a46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a48:	fc                   	cld    
  800a49:	eb 1d                	jmp    800a68 <memmove+0x64>
  800a4b:	89 f2                	mov    %esi,%edx
  800a4d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4f:	f6 c2 03             	test   $0x3,%dl
  800a52:	75 0f                	jne    800a63 <memmove+0x5f>
  800a54:	f6 c1 03             	test   $0x3,%cl
  800a57:	75 0a                	jne    800a63 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a59:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a5c:	89 c7                	mov    %eax,%edi
  800a5e:	fc                   	cld    
  800a5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a61:	eb 05                	jmp    800a68 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a63:	89 c7                	mov    %eax,%edi
  800a65:	fc                   	cld    
  800a66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a68:	5e                   	pop    %esi
  800a69:	5f                   	pop    %edi
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a72:	8b 45 10             	mov    0x10(%ebp),%eax
  800a75:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	89 04 24             	mov    %eax,(%esp)
  800a86:	e8 79 ff ff ff       	call   800a04 <memmove>
}
  800a8b:	c9                   	leave  
  800a8c:	c3                   	ret    

00800a8d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	56                   	push   %esi
  800a91:	53                   	push   %ebx
  800a92:	8b 55 08             	mov    0x8(%ebp),%edx
  800a95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a98:	89 d6                	mov    %edx,%esi
  800a9a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a9d:	eb 1a                	jmp    800ab9 <memcmp+0x2c>
		if (*s1 != *s2)
  800a9f:	0f b6 02             	movzbl (%edx),%eax
  800aa2:	0f b6 19             	movzbl (%ecx),%ebx
  800aa5:	38 d8                	cmp    %bl,%al
  800aa7:	74 0a                	je     800ab3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800aa9:	0f b6 c0             	movzbl %al,%eax
  800aac:	0f b6 db             	movzbl %bl,%ebx
  800aaf:	29 d8                	sub    %ebx,%eax
  800ab1:	eb 0f                	jmp    800ac2 <memcmp+0x35>
		s1++, s2++;
  800ab3:	83 c2 01             	add    $0x1,%edx
  800ab6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab9:	39 f2                	cmp    %esi,%edx
  800abb:	75 e2                	jne    800a9f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800abd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  800acc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800acf:	89 c2                	mov    %eax,%edx
  800ad1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ad4:	eb 07                	jmp    800add <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad6:	38 08                	cmp    %cl,(%eax)
  800ad8:	74 07                	je     800ae1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ada:	83 c0 01             	add    $0x1,%eax
  800add:	39 d0                	cmp    %edx,%eax
  800adf:	72 f5                	jb     800ad6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	57                   	push   %edi
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
  800ae9:	8b 55 08             	mov    0x8(%ebp),%edx
  800aec:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aef:	eb 03                	jmp    800af4 <strtol+0x11>
		s++;
  800af1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af4:	0f b6 0a             	movzbl (%edx),%ecx
  800af7:	80 f9 09             	cmp    $0x9,%cl
  800afa:	74 f5                	je     800af1 <strtol+0xe>
  800afc:	80 f9 20             	cmp    $0x20,%cl
  800aff:	74 f0                	je     800af1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b01:	80 f9 2b             	cmp    $0x2b,%cl
  800b04:	75 0a                	jne    800b10 <strtol+0x2d>
		s++;
  800b06:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b09:	bf 00 00 00 00       	mov    $0x0,%edi
  800b0e:	eb 11                	jmp    800b21 <strtol+0x3e>
  800b10:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b15:	80 f9 2d             	cmp    $0x2d,%cl
  800b18:	75 07                	jne    800b21 <strtol+0x3e>
		s++, neg = 1;
  800b1a:	8d 52 01             	lea    0x1(%edx),%edx
  800b1d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b21:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b26:	75 15                	jne    800b3d <strtol+0x5a>
  800b28:	80 3a 30             	cmpb   $0x30,(%edx)
  800b2b:	75 10                	jne    800b3d <strtol+0x5a>
  800b2d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b31:	75 0a                	jne    800b3d <strtol+0x5a>
		s += 2, base = 16;
  800b33:	83 c2 02             	add    $0x2,%edx
  800b36:	b8 10 00 00 00       	mov    $0x10,%eax
  800b3b:	eb 10                	jmp    800b4d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800b3d:	85 c0                	test   %eax,%eax
  800b3f:	75 0c                	jne    800b4d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b41:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b43:	80 3a 30             	cmpb   $0x30,(%edx)
  800b46:	75 05                	jne    800b4d <strtol+0x6a>
		s++, base = 8;
  800b48:	83 c2 01             	add    $0x1,%edx
  800b4b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800b4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b52:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b55:	0f b6 0a             	movzbl (%edx),%ecx
  800b58:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b5b:	89 f0                	mov    %esi,%eax
  800b5d:	3c 09                	cmp    $0x9,%al
  800b5f:	77 08                	ja     800b69 <strtol+0x86>
			dig = *s - '0';
  800b61:	0f be c9             	movsbl %cl,%ecx
  800b64:	83 e9 30             	sub    $0x30,%ecx
  800b67:	eb 20                	jmp    800b89 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b69:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b6c:	89 f0                	mov    %esi,%eax
  800b6e:	3c 19                	cmp    $0x19,%al
  800b70:	77 08                	ja     800b7a <strtol+0x97>
			dig = *s - 'a' + 10;
  800b72:	0f be c9             	movsbl %cl,%ecx
  800b75:	83 e9 57             	sub    $0x57,%ecx
  800b78:	eb 0f                	jmp    800b89 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800b7a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b7d:	89 f0                	mov    %esi,%eax
  800b7f:	3c 19                	cmp    $0x19,%al
  800b81:	77 16                	ja     800b99 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800b83:	0f be c9             	movsbl %cl,%ecx
  800b86:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b89:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b8c:	7d 0f                	jge    800b9d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800b8e:	83 c2 01             	add    $0x1,%edx
  800b91:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800b95:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800b97:	eb bc                	jmp    800b55 <strtol+0x72>
  800b99:	89 d8                	mov    %ebx,%eax
  800b9b:	eb 02                	jmp    800b9f <strtol+0xbc>
  800b9d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800b9f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba3:	74 05                	je     800baa <strtol+0xc7>
		*endptr = (char *) s;
  800ba5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800baa:	f7 d8                	neg    %eax
  800bac:	85 ff                	test   %edi,%edi
  800bae:	0f 44 c3             	cmove  %ebx,%eax
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	57                   	push   %edi
  800bba:	56                   	push   %esi
  800bbb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc7:	89 c3                	mov    %eax,%ebx
  800bc9:	89 c7                	mov    %eax,%edi
  800bcb:	89 c6                	mov    %eax,%esi
  800bcd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bda:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdf:	b8 01 00 00 00       	mov    $0x1,%eax
  800be4:	89 d1                	mov    %edx,%ecx
  800be6:	89 d3                	mov    %edx,%ebx
  800be8:	89 d7                	mov    %edx,%edi
  800bea:	89 d6                	mov    %edx,%esi
  800bec:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	57                   	push   %edi
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
  800bf9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c01:	b8 03 00 00 00       	mov    $0x3,%eax
  800c06:	8b 55 08             	mov    0x8(%ebp),%edx
  800c09:	89 cb                	mov    %ecx,%ebx
  800c0b:	89 cf                	mov    %ecx,%edi
  800c0d:	89 ce                	mov    %ecx,%esi
  800c0f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c11:	85 c0                	test   %eax,%eax
  800c13:	7e 28                	jle    800c3d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c15:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c19:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c20:	00 
  800c21:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800c28:	00 
  800c29:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c30:	00 
  800c31:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800c38:	e8 04 f5 ff ff       	call   800141 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c3d:	83 c4 2c             	add    $0x2c,%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c50:	b8 02 00 00 00       	mov    $0x2,%eax
  800c55:	89 d1                	mov    %edx,%ecx
  800c57:	89 d3                	mov    %edx,%ebx
  800c59:	89 d7                	mov    %edx,%edi
  800c5b:	89 d6                	mov    %edx,%esi
  800c5d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <sys_yield>:

void
sys_yield(void)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c74:	89 d1                	mov    %edx,%ecx
  800c76:	89 d3                	mov    %edx,%ebx
  800c78:	89 d7                	mov    %edx,%edi
  800c7a:	89 d6                	mov    %edx,%esi
  800c7c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	be 00 00 00 00       	mov    $0x0,%esi
  800c91:	b8 04 00 00 00       	mov    $0x4,%eax
  800c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c99:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9f:	89 f7                	mov    %esi,%edi
  800ca1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	7e 28                	jle    800ccf <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cab:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cb2:	00 
  800cb3:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800cba:	00 
  800cbb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc2:	00 
  800cc3:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800cca:	e8 72 f4 ff ff       	call   800141 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ccf:	83 c4 2c             	add    $0x2c,%esp
  800cd2:	5b                   	pop    %ebx
  800cd3:	5e                   	pop    %esi
  800cd4:	5f                   	pop    %edi
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    

00800cd7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	57                   	push   %edi
  800cdb:	56                   	push   %esi
  800cdc:	53                   	push   %ebx
  800cdd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ce5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ceb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cee:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf1:	8b 75 18             	mov    0x18(%ebp),%esi
  800cf4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	7e 28                	jle    800d22 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfa:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cfe:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d05:	00 
  800d06:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800d0d:	00 
  800d0e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d15:	00 
  800d16:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800d1d:	e8 1f f4 ff ff       	call   800141 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d22:	83 c4 2c             	add    $0x2c,%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d38:	b8 06 00 00 00       	mov    $0x6,%eax
  800d3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d40:	8b 55 08             	mov    0x8(%ebp),%edx
  800d43:	89 df                	mov    %ebx,%edi
  800d45:	89 de                	mov    %ebx,%esi
  800d47:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	7e 28                	jle    800d75 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d51:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d58:	00 
  800d59:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800d60:	00 
  800d61:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d68:	00 
  800d69:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800d70:	e8 cc f3 ff ff       	call   800141 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d75:	83 c4 2c             	add    $0x2c,%esp
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	57                   	push   %edi
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
  800d83:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d86:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d93:	8b 55 08             	mov    0x8(%ebp),%edx
  800d96:	89 df                	mov    %ebx,%edi
  800d98:	89 de                	mov    %ebx,%esi
  800d9a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d9c:	85 c0                	test   %eax,%eax
  800d9e:	7e 28                	jle    800dc8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dab:	00 
  800dac:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800db3:	00 
  800db4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dbb:	00 
  800dbc:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800dc3:	e8 79 f3 ff ff       	call   800141 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dc8:	83 c4 2c             	add    $0x2c,%esp
  800dcb:	5b                   	pop    %ebx
  800dcc:	5e                   	pop    %esi
  800dcd:	5f                   	pop    %edi
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	57                   	push   %edi
  800dd4:	56                   	push   %esi
  800dd5:	53                   	push   %ebx
  800dd6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dde:	b8 09 00 00 00       	mov    $0x9,%eax
  800de3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de6:	8b 55 08             	mov    0x8(%ebp),%edx
  800de9:	89 df                	mov    %ebx,%edi
  800deb:	89 de                	mov    %ebx,%esi
  800ded:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800def:	85 c0                	test   %eax,%eax
  800df1:	7e 28                	jle    800e1b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dfe:	00 
  800dff:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800e06:	00 
  800e07:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e0e:	00 
  800e0f:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800e16:	e8 26 f3 ff ff       	call   800141 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e1b:	83 c4 2c             	add    $0x2c,%esp
  800e1e:	5b                   	pop    %ebx
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	57                   	push   %edi
  800e27:	56                   	push   %esi
  800e28:	53                   	push   %ebx
  800e29:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e31:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e39:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3c:	89 df                	mov    %ebx,%edi
  800e3e:	89 de                	mov    %ebx,%esi
  800e40:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e42:	85 c0                	test   %eax,%eax
  800e44:	7e 28                	jle    800e6e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e46:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e51:	00 
  800e52:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800e59:	00 
  800e5a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e61:	00 
  800e62:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800e69:	e8 d3 f2 ff ff       	call   800141 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e6e:	83 c4 2c             	add    $0x2c,%esp
  800e71:	5b                   	pop    %ebx
  800e72:	5e                   	pop    %esi
  800e73:	5f                   	pop    %edi
  800e74:	5d                   	pop    %ebp
  800e75:	c3                   	ret    

00800e76 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
  800e79:	57                   	push   %edi
  800e7a:	56                   	push   %esi
  800e7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7c:	be 00 00 00 00       	mov    $0x0,%esi
  800e81:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e89:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e8f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e92:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e94:	5b                   	pop    %ebx
  800e95:	5e                   	pop    %esi
  800e96:	5f                   	pop    %edi
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    

00800e99 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	57                   	push   %edi
  800e9d:	56                   	push   %esi
  800e9e:	53                   	push   %ebx
  800e9f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eac:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaf:	89 cb                	mov    %ecx,%ebx
  800eb1:	89 cf                	mov    %ecx,%edi
  800eb3:	89 ce                	mov    %ecx,%esi
  800eb5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	7e 28                	jle    800ee3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ebf:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ec6:	00 
  800ec7:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800ece:	00 
  800ecf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed6:	00 
  800ed7:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800ede:	e8 5e f2 ff ff       	call   800141 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ee3:	83 c4 2c             	add    $0x2c,%esp
  800ee6:	5b                   	pop    %ebx
  800ee7:	5e                   	pop    %esi
  800ee8:	5f                   	pop    %edi
  800ee9:	5d                   	pop    %ebp
  800eea:	c3                   	ret    

00800eeb <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	57                   	push   %edi
  800eef:	56                   	push   %esi
  800ef0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef6:	b8 0e 00 00 00       	mov    $0xe,%eax
  800efb:	89 d1                	mov    %edx,%ecx
  800efd:	89 d3                	mov    %edx,%ebx
  800eff:	89 d7                	mov    %edx,%edi
  800f01:	89 d6                	mov    %edx,%esi
  800f03:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f05:	5b                   	pop    %ebx
  800f06:	5e                   	pop    %esi
  800f07:	5f                   	pop    %edi
  800f08:	5d                   	pop    %ebp
  800f09:	c3                   	ret    

00800f0a <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  800f0a:	55                   	push   %ebp
  800f0b:	89 e5                	mov    %esp,%ebp
  800f0d:	57                   	push   %edi
  800f0e:	56                   	push   %esi
  800f0f:	53                   	push   %ebx
  800f10:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f18:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f20:	8b 55 08             	mov    0x8(%ebp),%edx
  800f23:	89 df                	mov    %ebx,%edi
  800f25:	89 de                	mov    %ebx,%esi
  800f27:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f29:	85 c0                	test   %eax,%eax
  800f2b:	7e 28                	jle    800f55 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f31:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800f38:	00 
  800f39:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800f40:	00 
  800f41:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f48:	00 
  800f49:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800f50:	e8 ec f1 ff ff       	call   800141 <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  800f55:	83 c4 2c             	add    $0x2c,%esp
  800f58:	5b                   	pop    %ebx
  800f59:	5e                   	pop    %esi
  800f5a:	5f                   	pop    %edi
  800f5b:	5d                   	pop    %ebp
  800f5c:	c3                   	ret    

00800f5d <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  800f5d:	55                   	push   %ebp
  800f5e:	89 e5                	mov    %esp,%ebp
  800f60:	57                   	push   %edi
  800f61:	56                   	push   %esi
  800f62:	53                   	push   %ebx
  800f63:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f66:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f6b:	b8 10 00 00 00       	mov    $0x10,%eax
  800f70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f73:	8b 55 08             	mov    0x8(%ebp),%edx
  800f76:	89 df                	mov    %ebx,%edi
  800f78:	89 de                	mov    %ebx,%esi
  800f7a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	7e 28                	jle    800fa8 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f80:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f84:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  800f8b:	00 
  800f8c:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800f93:	00 
  800f94:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f9b:	00 
  800f9c:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800fa3:	e8 99 f1 ff ff       	call   800141 <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  800fa8:	83 c4 2c             	add    $0x2c,%esp
  800fab:	5b                   	pop    %ebx
  800fac:	5e                   	pop    %esi
  800fad:	5f                   	pop    %edi
  800fae:	5d                   	pop    %ebp
  800faf:	c3                   	ret    

00800fb0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	53                   	push   %ebx
  800fb4:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  800fb7:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800fbe:	75 2f                	jne    800fef <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  800fc0:	e8 80 fc ff ff       	call   800c45 <sys_getenvid>
  800fc5:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P);
  800fc7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fce:	00 
  800fcf:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800fd6:	ee 
  800fd7:	89 04 24             	mov    %eax,(%esp)
  800fda:	e8 a4 fc ff ff       	call   800c83 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *)_pgfault_upcall);
  800fdf:	c7 44 24 04 fd 0f 80 	movl   $0x800ffd,0x4(%esp)
  800fe6:	00 
  800fe7:	89 1c 24             	mov    %ebx,(%esp)
  800fea:	e8 34 fe ff ff       	call   800e23 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800fef:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff2:	a3 0c 40 80 00       	mov    %eax,0x80400c
}
  800ff7:	83 c4 14             	add    $0x14,%esp
  800ffa:	5b                   	pop    %ebx
  800ffb:	5d                   	pop    %ebp
  800ffc:	c3                   	ret    

00800ffd <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800ffd:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800ffe:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  801003:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801005:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	// 0x30(%esp) points to trap-time stack pointer
	// 0x28(%esp) points to trap-time eip
	subl $4, 0x30(%esp)
  801008:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax 
  80100d:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebp
  801011:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %ebp, (%eax)
  801015:	89 28                	mov    %ebp,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801017:	83 c4 08             	add    $0x8,%esp
	popal
  80101a:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp //pop eip - we already stored it
  80101b:	83 c4 04             	add    $0x4,%esp
	popfl
  80101e:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80101f:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801020:	c3                   	ret    
  801021:	66 90                	xchg   %ax,%ax
  801023:	66 90                	xchg   %ax,%ax
  801025:	66 90                	xchg   %ax,%ax
  801027:	66 90                	xchg   %ax,%ax
  801029:	66 90                	xchg   %ax,%ax
  80102b:	66 90                	xchg   %ax,%ax
  80102d:	66 90                	xchg   %ax,%ax
  80102f:	90                   	nop

00801030 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801033:	8b 45 08             	mov    0x8(%ebp),%eax
  801036:	05 00 00 00 30       	add    $0x30000000,%eax
  80103b:	c1 e8 0c             	shr    $0xc,%eax
}
  80103e:	5d                   	pop    %ebp
  80103f:	c3                   	ret    

00801040 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801043:	8b 45 08             	mov    0x8(%ebp),%eax
  801046:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80104b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801050:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    

00801057 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80105d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801062:	89 c2                	mov    %eax,%edx
  801064:	c1 ea 16             	shr    $0x16,%edx
  801067:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80106e:	f6 c2 01             	test   $0x1,%dl
  801071:	74 11                	je     801084 <fd_alloc+0x2d>
  801073:	89 c2                	mov    %eax,%edx
  801075:	c1 ea 0c             	shr    $0xc,%edx
  801078:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80107f:	f6 c2 01             	test   $0x1,%dl
  801082:	75 09                	jne    80108d <fd_alloc+0x36>
			*fd_store = fd;
  801084:	89 01                	mov    %eax,(%ecx)
			return 0;
  801086:	b8 00 00 00 00       	mov    $0x0,%eax
  80108b:	eb 17                	jmp    8010a4 <fd_alloc+0x4d>
  80108d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801092:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801097:	75 c9                	jne    801062 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801099:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80109f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    

008010a6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010ac:	83 f8 1f             	cmp    $0x1f,%eax
  8010af:	77 36                	ja     8010e7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010b1:	c1 e0 0c             	shl    $0xc,%eax
  8010b4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010b9:	89 c2                	mov    %eax,%edx
  8010bb:	c1 ea 16             	shr    $0x16,%edx
  8010be:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010c5:	f6 c2 01             	test   $0x1,%dl
  8010c8:	74 24                	je     8010ee <fd_lookup+0x48>
  8010ca:	89 c2                	mov    %eax,%edx
  8010cc:	c1 ea 0c             	shr    $0xc,%edx
  8010cf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010d6:	f6 c2 01             	test   $0x1,%dl
  8010d9:	74 1a                	je     8010f5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010de:	89 02                	mov    %eax,(%edx)
	return 0;
  8010e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e5:	eb 13                	jmp    8010fa <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010ec:	eb 0c                	jmp    8010fa <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010f3:	eb 05                	jmp    8010fa <fd_lookup+0x54>
  8010f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010fa:	5d                   	pop    %ebp
  8010fb:	c3                   	ret    

008010fc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	83 ec 18             	sub    $0x18,%esp
  801102:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801105:	ba 00 00 00 00       	mov    $0x0,%edx
  80110a:	eb 13                	jmp    80111f <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  80110c:	39 08                	cmp    %ecx,(%eax)
  80110e:	75 0c                	jne    80111c <dev_lookup+0x20>
			*dev = devtab[i];
  801110:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801113:	89 01                	mov    %eax,(%ecx)
			return 0;
  801115:	b8 00 00 00 00       	mov    $0x0,%eax
  80111a:	eb 38                	jmp    801154 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80111c:	83 c2 01             	add    $0x1,%edx
  80111f:	8b 04 95 28 2b 80 00 	mov    0x802b28(,%edx,4),%eax
  801126:	85 c0                	test   %eax,%eax
  801128:	75 e2                	jne    80110c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80112a:	a1 08 40 80 00       	mov    0x804008,%eax
  80112f:	8b 40 48             	mov    0x48(%eax),%eax
  801132:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801136:	89 44 24 04          	mov    %eax,0x4(%esp)
  80113a:	c7 04 24 ac 2a 80 00 	movl   $0x802aac,(%esp)
  801141:	e8 f4 f0 ff ff       	call   80023a <cprintf>
	*dev = 0;
  801146:	8b 45 0c             	mov    0xc(%ebp),%eax
  801149:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80114f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801154:	c9                   	leave  
  801155:	c3                   	ret    

00801156 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	56                   	push   %esi
  80115a:	53                   	push   %ebx
  80115b:	83 ec 20             	sub    $0x20,%esp
  80115e:	8b 75 08             	mov    0x8(%ebp),%esi
  801161:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801164:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801167:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80116b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801171:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801174:	89 04 24             	mov    %eax,(%esp)
  801177:	e8 2a ff ff ff       	call   8010a6 <fd_lookup>
  80117c:	85 c0                	test   %eax,%eax
  80117e:	78 05                	js     801185 <fd_close+0x2f>
	    || fd != fd2)
  801180:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801183:	74 0c                	je     801191 <fd_close+0x3b>
		return (must_exist ? r : 0);
  801185:	84 db                	test   %bl,%bl
  801187:	ba 00 00 00 00       	mov    $0x0,%edx
  80118c:	0f 44 c2             	cmove  %edx,%eax
  80118f:	eb 3f                	jmp    8011d0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801191:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801194:	89 44 24 04          	mov    %eax,0x4(%esp)
  801198:	8b 06                	mov    (%esi),%eax
  80119a:	89 04 24             	mov    %eax,(%esp)
  80119d:	e8 5a ff ff ff       	call   8010fc <dev_lookup>
  8011a2:	89 c3                	mov    %eax,%ebx
  8011a4:	85 c0                	test   %eax,%eax
  8011a6:	78 16                	js     8011be <fd_close+0x68>
		if (dev->dev_close)
  8011a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ab:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011ae:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	74 07                	je     8011be <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8011b7:	89 34 24             	mov    %esi,(%esp)
  8011ba:	ff d0                	call   *%eax
  8011bc:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011be:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011c9:	e8 5c fb ff ff       	call   800d2a <sys_page_unmap>
	return r;
  8011ce:	89 d8                	mov    %ebx,%eax
}
  8011d0:	83 c4 20             	add    $0x20,%esp
  8011d3:	5b                   	pop    %ebx
  8011d4:	5e                   	pop    %esi
  8011d5:	5d                   	pop    %ebp
  8011d6:	c3                   	ret    

008011d7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
  8011da:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e7:	89 04 24             	mov    %eax,(%esp)
  8011ea:	e8 b7 fe ff ff       	call   8010a6 <fd_lookup>
  8011ef:	89 c2                	mov    %eax,%edx
  8011f1:	85 d2                	test   %edx,%edx
  8011f3:	78 13                	js     801208 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8011f5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011fc:	00 
  8011fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801200:	89 04 24             	mov    %eax,(%esp)
  801203:	e8 4e ff ff ff       	call   801156 <fd_close>
}
  801208:	c9                   	leave  
  801209:	c3                   	ret    

0080120a <close_all>:

void
close_all(void)
{
  80120a:	55                   	push   %ebp
  80120b:	89 e5                	mov    %esp,%ebp
  80120d:	53                   	push   %ebx
  80120e:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801211:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801216:	89 1c 24             	mov    %ebx,(%esp)
  801219:	e8 b9 ff ff ff       	call   8011d7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80121e:	83 c3 01             	add    $0x1,%ebx
  801221:	83 fb 20             	cmp    $0x20,%ebx
  801224:	75 f0                	jne    801216 <close_all+0xc>
		close(i);
}
  801226:	83 c4 14             	add    $0x14,%esp
  801229:	5b                   	pop    %ebx
  80122a:	5d                   	pop    %ebp
  80122b:	c3                   	ret    

0080122c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	57                   	push   %edi
  801230:	56                   	push   %esi
  801231:	53                   	push   %ebx
  801232:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801235:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801238:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123c:	8b 45 08             	mov    0x8(%ebp),%eax
  80123f:	89 04 24             	mov    %eax,(%esp)
  801242:	e8 5f fe ff ff       	call   8010a6 <fd_lookup>
  801247:	89 c2                	mov    %eax,%edx
  801249:	85 d2                	test   %edx,%edx
  80124b:	0f 88 e1 00 00 00    	js     801332 <dup+0x106>
		return r;
	close(newfdnum);
  801251:	8b 45 0c             	mov    0xc(%ebp),%eax
  801254:	89 04 24             	mov    %eax,(%esp)
  801257:	e8 7b ff ff ff       	call   8011d7 <close>

	newfd = INDEX2FD(newfdnum);
  80125c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80125f:	c1 e3 0c             	shl    $0xc,%ebx
  801262:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801268:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80126b:	89 04 24             	mov    %eax,(%esp)
  80126e:	e8 cd fd ff ff       	call   801040 <fd2data>
  801273:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801275:	89 1c 24             	mov    %ebx,(%esp)
  801278:	e8 c3 fd ff ff       	call   801040 <fd2data>
  80127d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80127f:	89 f0                	mov    %esi,%eax
  801281:	c1 e8 16             	shr    $0x16,%eax
  801284:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80128b:	a8 01                	test   $0x1,%al
  80128d:	74 43                	je     8012d2 <dup+0xa6>
  80128f:	89 f0                	mov    %esi,%eax
  801291:	c1 e8 0c             	shr    $0xc,%eax
  801294:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80129b:	f6 c2 01             	test   $0x1,%dl
  80129e:	74 32                	je     8012d2 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012a0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012a7:	25 07 0e 00 00       	and    $0xe07,%eax
  8012ac:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012b0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012b4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012bb:	00 
  8012bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012c7:	e8 0b fa ff ff       	call   800cd7 <sys_page_map>
  8012cc:	89 c6                	mov    %eax,%esi
  8012ce:	85 c0                	test   %eax,%eax
  8012d0:	78 3e                	js     801310 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012d5:	89 c2                	mov    %eax,%edx
  8012d7:	c1 ea 0c             	shr    $0xc,%edx
  8012da:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012e1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8012e7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012f6:	00 
  8012f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801302:	e8 d0 f9 ff ff       	call   800cd7 <sys_page_map>
  801307:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801309:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80130c:	85 f6                	test   %esi,%esi
  80130e:	79 22                	jns    801332 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801310:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801314:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80131b:	e8 0a fa ff ff       	call   800d2a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801320:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801324:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80132b:	e8 fa f9 ff ff       	call   800d2a <sys_page_unmap>
	return r;
  801330:	89 f0                	mov    %esi,%eax
}
  801332:	83 c4 3c             	add    $0x3c,%esp
  801335:	5b                   	pop    %ebx
  801336:	5e                   	pop    %esi
  801337:	5f                   	pop    %edi
  801338:	5d                   	pop    %ebp
  801339:	c3                   	ret    

0080133a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80133a:	55                   	push   %ebp
  80133b:	89 e5                	mov    %esp,%ebp
  80133d:	53                   	push   %ebx
  80133e:	83 ec 24             	sub    $0x24,%esp
  801341:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801344:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801347:	89 44 24 04          	mov    %eax,0x4(%esp)
  80134b:	89 1c 24             	mov    %ebx,(%esp)
  80134e:	e8 53 fd ff ff       	call   8010a6 <fd_lookup>
  801353:	89 c2                	mov    %eax,%edx
  801355:	85 d2                	test   %edx,%edx
  801357:	78 6d                	js     8013c6 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801359:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801360:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801363:	8b 00                	mov    (%eax),%eax
  801365:	89 04 24             	mov    %eax,(%esp)
  801368:	e8 8f fd ff ff       	call   8010fc <dev_lookup>
  80136d:	85 c0                	test   %eax,%eax
  80136f:	78 55                	js     8013c6 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801371:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801374:	8b 50 08             	mov    0x8(%eax),%edx
  801377:	83 e2 03             	and    $0x3,%edx
  80137a:	83 fa 01             	cmp    $0x1,%edx
  80137d:	75 23                	jne    8013a2 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80137f:	a1 08 40 80 00       	mov    0x804008,%eax
  801384:	8b 40 48             	mov    0x48(%eax),%eax
  801387:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80138b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138f:	c7 04 24 ed 2a 80 00 	movl   $0x802aed,(%esp)
  801396:	e8 9f ee ff ff       	call   80023a <cprintf>
		return -E_INVAL;
  80139b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013a0:	eb 24                	jmp    8013c6 <read+0x8c>
	}
	if (!dev->dev_read)
  8013a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013a5:	8b 52 08             	mov    0x8(%edx),%edx
  8013a8:	85 d2                	test   %edx,%edx
  8013aa:	74 15                	je     8013c1 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013ac:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013af:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013b6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013ba:	89 04 24             	mov    %eax,(%esp)
  8013bd:	ff d2                	call   *%edx
  8013bf:	eb 05                	jmp    8013c6 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8013c6:	83 c4 24             	add    $0x24,%esp
  8013c9:	5b                   	pop    %ebx
  8013ca:	5d                   	pop    %ebp
  8013cb:	c3                   	ret    

008013cc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
  8013cf:	57                   	push   %edi
  8013d0:	56                   	push   %esi
  8013d1:	53                   	push   %ebx
  8013d2:	83 ec 1c             	sub    $0x1c,%esp
  8013d5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013d8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013e0:	eb 23                	jmp    801405 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013e2:	89 f0                	mov    %esi,%eax
  8013e4:	29 d8                	sub    %ebx,%eax
  8013e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013ea:	89 d8                	mov    %ebx,%eax
  8013ec:	03 45 0c             	add    0xc(%ebp),%eax
  8013ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f3:	89 3c 24             	mov    %edi,(%esp)
  8013f6:	e8 3f ff ff ff       	call   80133a <read>
		if (m < 0)
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	78 10                	js     80140f <readn+0x43>
			return m;
		if (m == 0)
  8013ff:	85 c0                	test   %eax,%eax
  801401:	74 0a                	je     80140d <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801403:	01 c3                	add    %eax,%ebx
  801405:	39 f3                	cmp    %esi,%ebx
  801407:	72 d9                	jb     8013e2 <readn+0x16>
  801409:	89 d8                	mov    %ebx,%eax
  80140b:	eb 02                	jmp    80140f <readn+0x43>
  80140d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80140f:	83 c4 1c             	add    $0x1c,%esp
  801412:	5b                   	pop    %ebx
  801413:	5e                   	pop    %esi
  801414:	5f                   	pop    %edi
  801415:	5d                   	pop    %ebp
  801416:	c3                   	ret    

00801417 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801417:	55                   	push   %ebp
  801418:	89 e5                	mov    %esp,%ebp
  80141a:	53                   	push   %ebx
  80141b:	83 ec 24             	sub    $0x24,%esp
  80141e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801421:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801424:	89 44 24 04          	mov    %eax,0x4(%esp)
  801428:	89 1c 24             	mov    %ebx,(%esp)
  80142b:	e8 76 fc ff ff       	call   8010a6 <fd_lookup>
  801430:	89 c2                	mov    %eax,%edx
  801432:	85 d2                	test   %edx,%edx
  801434:	78 68                	js     80149e <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801436:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801439:	89 44 24 04          	mov    %eax,0x4(%esp)
  80143d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801440:	8b 00                	mov    (%eax),%eax
  801442:	89 04 24             	mov    %eax,(%esp)
  801445:	e8 b2 fc ff ff       	call   8010fc <dev_lookup>
  80144a:	85 c0                	test   %eax,%eax
  80144c:	78 50                	js     80149e <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80144e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801451:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801455:	75 23                	jne    80147a <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801457:	a1 08 40 80 00       	mov    0x804008,%eax
  80145c:	8b 40 48             	mov    0x48(%eax),%eax
  80145f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801463:	89 44 24 04          	mov    %eax,0x4(%esp)
  801467:	c7 04 24 09 2b 80 00 	movl   $0x802b09,(%esp)
  80146e:	e8 c7 ed ff ff       	call   80023a <cprintf>
		return -E_INVAL;
  801473:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801478:	eb 24                	jmp    80149e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80147a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80147d:	8b 52 0c             	mov    0xc(%edx),%edx
  801480:	85 d2                	test   %edx,%edx
  801482:	74 15                	je     801499 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801484:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801487:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80148b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80148e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801492:	89 04 24             	mov    %eax,(%esp)
  801495:	ff d2                	call   *%edx
  801497:	eb 05                	jmp    80149e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801499:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80149e:	83 c4 24             	add    $0x24,%esp
  8014a1:	5b                   	pop    %ebx
  8014a2:	5d                   	pop    %ebp
  8014a3:	c3                   	ret    

008014a4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014a4:	55                   	push   %ebp
  8014a5:	89 e5                	mov    %esp,%ebp
  8014a7:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014aa:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b4:	89 04 24             	mov    %eax,(%esp)
  8014b7:	e8 ea fb ff ff       	call   8010a6 <fd_lookup>
  8014bc:	85 c0                	test   %eax,%eax
  8014be:	78 0e                	js     8014ce <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8014c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014c6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ce:	c9                   	leave  
  8014cf:	c3                   	ret    

008014d0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	53                   	push   %ebx
  8014d4:	83 ec 24             	sub    $0x24,%esp
  8014d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e1:	89 1c 24             	mov    %ebx,(%esp)
  8014e4:	e8 bd fb ff ff       	call   8010a6 <fd_lookup>
  8014e9:	89 c2                	mov    %eax,%edx
  8014eb:	85 d2                	test   %edx,%edx
  8014ed:	78 61                	js     801550 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f9:	8b 00                	mov    (%eax),%eax
  8014fb:	89 04 24             	mov    %eax,(%esp)
  8014fe:	e8 f9 fb ff ff       	call   8010fc <dev_lookup>
  801503:	85 c0                	test   %eax,%eax
  801505:	78 49                	js     801550 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801507:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80150e:	75 23                	jne    801533 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801510:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801515:	8b 40 48             	mov    0x48(%eax),%eax
  801518:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80151c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801520:	c7 04 24 cc 2a 80 00 	movl   $0x802acc,(%esp)
  801527:	e8 0e ed ff ff       	call   80023a <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80152c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801531:	eb 1d                	jmp    801550 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801533:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801536:	8b 52 18             	mov    0x18(%edx),%edx
  801539:	85 d2                	test   %edx,%edx
  80153b:	74 0e                	je     80154b <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80153d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801540:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801544:	89 04 24             	mov    %eax,(%esp)
  801547:	ff d2                	call   *%edx
  801549:	eb 05                	jmp    801550 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80154b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801550:	83 c4 24             	add    $0x24,%esp
  801553:	5b                   	pop    %ebx
  801554:	5d                   	pop    %ebp
  801555:	c3                   	ret    

00801556 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
  801559:	53                   	push   %ebx
  80155a:	83 ec 24             	sub    $0x24,%esp
  80155d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801560:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801563:	89 44 24 04          	mov    %eax,0x4(%esp)
  801567:	8b 45 08             	mov    0x8(%ebp),%eax
  80156a:	89 04 24             	mov    %eax,(%esp)
  80156d:	e8 34 fb ff ff       	call   8010a6 <fd_lookup>
  801572:	89 c2                	mov    %eax,%edx
  801574:	85 d2                	test   %edx,%edx
  801576:	78 52                	js     8015ca <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801578:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80157f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801582:	8b 00                	mov    (%eax),%eax
  801584:	89 04 24             	mov    %eax,(%esp)
  801587:	e8 70 fb ff ff       	call   8010fc <dev_lookup>
  80158c:	85 c0                	test   %eax,%eax
  80158e:	78 3a                	js     8015ca <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801590:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801593:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801597:	74 2c                	je     8015c5 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801599:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80159c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015a3:	00 00 00 
	stat->st_isdir = 0;
  8015a6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015ad:	00 00 00 
	stat->st_dev = dev;
  8015b0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015ba:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015bd:	89 14 24             	mov    %edx,(%esp)
  8015c0:	ff 50 14             	call   *0x14(%eax)
  8015c3:	eb 05                	jmp    8015ca <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015c5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015ca:	83 c4 24             	add    $0x24,%esp
  8015cd:	5b                   	pop    %ebx
  8015ce:	5d                   	pop    %ebp
  8015cf:	c3                   	ret    

008015d0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	56                   	push   %esi
  8015d4:	53                   	push   %ebx
  8015d5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015d8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015df:	00 
  8015e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e3:	89 04 24             	mov    %eax,(%esp)
  8015e6:	e8 28 02 00 00       	call   801813 <open>
  8015eb:	89 c3                	mov    %eax,%ebx
  8015ed:	85 db                	test   %ebx,%ebx
  8015ef:	78 1b                	js     80160c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8015f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f8:	89 1c 24             	mov    %ebx,(%esp)
  8015fb:	e8 56 ff ff ff       	call   801556 <fstat>
  801600:	89 c6                	mov    %eax,%esi
	close(fd);
  801602:	89 1c 24             	mov    %ebx,(%esp)
  801605:	e8 cd fb ff ff       	call   8011d7 <close>
	return r;
  80160a:	89 f0                	mov    %esi,%eax
}
  80160c:	83 c4 10             	add    $0x10,%esp
  80160f:	5b                   	pop    %ebx
  801610:	5e                   	pop    %esi
  801611:	5d                   	pop    %ebp
  801612:	c3                   	ret    

00801613 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801613:	55                   	push   %ebp
  801614:	89 e5                	mov    %esp,%ebp
  801616:	56                   	push   %esi
  801617:	53                   	push   %ebx
  801618:	83 ec 10             	sub    $0x10,%esp
  80161b:	89 c6                	mov    %eax,%esi
  80161d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80161f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801626:	75 11                	jne    801639 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801628:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80162f:	e8 a1 0d 00 00       	call   8023d5 <ipc_find_env>
  801634:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801639:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801640:	00 
  801641:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801648:	00 
  801649:	89 74 24 04          	mov    %esi,0x4(%esp)
  80164d:	a1 00 40 80 00       	mov    0x804000,%eax
  801652:	89 04 24             	mov    %eax,(%esp)
  801655:	e8 10 0d 00 00       	call   80236a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80165a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801661:	00 
  801662:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801666:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80166d:	e8 7e 0c 00 00       	call   8022f0 <ipc_recv>
}
  801672:	83 c4 10             	add    $0x10,%esp
  801675:	5b                   	pop    %ebx
  801676:	5e                   	pop    %esi
  801677:	5d                   	pop    %ebp
  801678:	c3                   	ret    

00801679 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801679:	55                   	push   %ebp
  80167a:	89 e5                	mov    %esp,%ebp
  80167c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80167f:	8b 45 08             	mov    0x8(%ebp),%eax
  801682:	8b 40 0c             	mov    0xc(%eax),%eax
  801685:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80168a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80168d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801692:	ba 00 00 00 00       	mov    $0x0,%edx
  801697:	b8 02 00 00 00       	mov    $0x2,%eax
  80169c:	e8 72 ff ff ff       	call   801613 <fsipc>
}
  8016a1:	c9                   	leave  
  8016a2:	c3                   	ret    

008016a3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016a3:	55                   	push   %ebp
  8016a4:	89 e5                	mov    %esp,%ebp
  8016a6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ac:	8b 40 0c             	mov    0xc(%eax),%eax
  8016af:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b9:	b8 06 00 00 00       	mov    $0x6,%eax
  8016be:	e8 50 ff ff ff       	call   801613 <fsipc>
}
  8016c3:	c9                   	leave  
  8016c4:	c3                   	ret    

008016c5 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	53                   	push   %ebx
  8016c9:	83 ec 14             	sub    $0x14,%esp
  8016cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d2:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016da:	ba 00 00 00 00       	mov    $0x0,%edx
  8016df:	b8 05 00 00 00       	mov    $0x5,%eax
  8016e4:	e8 2a ff ff ff       	call   801613 <fsipc>
  8016e9:	89 c2                	mov    %eax,%edx
  8016eb:	85 d2                	test   %edx,%edx
  8016ed:	78 2b                	js     80171a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016ef:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8016f6:	00 
  8016f7:	89 1c 24             	mov    %ebx,(%esp)
  8016fa:	e8 68 f1 ff ff       	call   800867 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016ff:	a1 80 50 80 00       	mov    0x805080,%eax
  801704:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80170a:	a1 84 50 80 00       	mov    0x805084,%eax
  80170f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801715:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80171a:	83 c4 14             	add    $0x14,%esp
  80171d:	5b                   	pop    %ebx
  80171e:	5d                   	pop    %ebp
  80171f:	c3                   	ret    

00801720 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	83 ec 18             	sub    $0x18,%esp
  801726:	8b 45 10             	mov    0x10(%ebp),%eax
  801729:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80172e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801733:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801736:	8b 55 08             	mov    0x8(%ebp),%edx
  801739:	8b 52 0c             	mov    0xc(%edx),%edx
  80173c:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801742:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801747:	89 44 24 08          	mov    %eax,0x8(%esp)
  80174b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80174e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801752:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801759:	e8 a6 f2 ff ff       	call   800a04 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  80175e:	ba 00 00 00 00       	mov    $0x0,%edx
  801763:	b8 04 00 00 00       	mov    $0x4,%eax
  801768:	e8 a6 fe ff ff       	call   801613 <fsipc>
}
  80176d:	c9                   	leave  
  80176e:	c3                   	ret    

0080176f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80176f:	55                   	push   %ebp
  801770:	89 e5                	mov    %esp,%ebp
  801772:	56                   	push   %esi
  801773:	53                   	push   %ebx
  801774:	83 ec 10             	sub    $0x10,%esp
  801777:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80177a:	8b 45 08             	mov    0x8(%ebp),%eax
  80177d:	8b 40 0c             	mov    0xc(%eax),%eax
  801780:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801785:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80178b:	ba 00 00 00 00       	mov    $0x0,%edx
  801790:	b8 03 00 00 00       	mov    $0x3,%eax
  801795:	e8 79 fe ff ff       	call   801613 <fsipc>
  80179a:	89 c3                	mov    %eax,%ebx
  80179c:	85 c0                	test   %eax,%eax
  80179e:	78 6a                	js     80180a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8017a0:	39 c6                	cmp    %eax,%esi
  8017a2:	73 24                	jae    8017c8 <devfile_read+0x59>
  8017a4:	c7 44 24 0c 3c 2b 80 	movl   $0x802b3c,0xc(%esp)
  8017ab:	00 
  8017ac:	c7 44 24 08 43 2b 80 	movl   $0x802b43,0x8(%esp)
  8017b3:	00 
  8017b4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8017bb:	00 
  8017bc:	c7 04 24 58 2b 80 00 	movl   $0x802b58,(%esp)
  8017c3:	e8 79 e9 ff ff       	call   800141 <_panic>
	assert(r <= PGSIZE);
  8017c8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017cd:	7e 24                	jle    8017f3 <devfile_read+0x84>
  8017cf:	c7 44 24 0c 63 2b 80 	movl   $0x802b63,0xc(%esp)
  8017d6:	00 
  8017d7:	c7 44 24 08 43 2b 80 	movl   $0x802b43,0x8(%esp)
  8017de:	00 
  8017df:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8017e6:	00 
  8017e7:	c7 04 24 58 2b 80 00 	movl   $0x802b58,(%esp)
  8017ee:	e8 4e e9 ff ff       	call   800141 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017f7:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8017fe:	00 
  8017ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801802:	89 04 24             	mov    %eax,(%esp)
  801805:	e8 fa f1 ff ff       	call   800a04 <memmove>
	return r;
}
  80180a:	89 d8                	mov    %ebx,%eax
  80180c:	83 c4 10             	add    $0x10,%esp
  80180f:	5b                   	pop    %ebx
  801810:	5e                   	pop    %esi
  801811:	5d                   	pop    %ebp
  801812:	c3                   	ret    

00801813 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801813:	55                   	push   %ebp
  801814:	89 e5                	mov    %esp,%ebp
  801816:	53                   	push   %ebx
  801817:	83 ec 24             	sub    $0x24,%esp
  80181a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80181d:	89 1c 24             	mov    %ebx,(%esp)
  801820:	e8 0b f0 ff ff       	call   800830 <strlen>
  801825:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80182a:	7f 60                	jg     80188c <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80182c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182f:	89 04 24             	mov    %eax,(%esp)
  801832:	e8 20 f8 ff ff       	call   801057 <fd_alloc>
  801837:	89 c2                	mov    %eax,%edx
  801839:	85 d2                	test   %edx,%edx
  80183b:	78 54                	js     801891 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80183d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801841:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801848:	e8 1a f0 ff ff       	call   800867 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80184d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801850:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801855:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801858:	b8 01 00 00 00       	mov    $0x1,%eax
  80185d:	e8 b1 fd ff ff       	call   801613 <fsipc>
  801862:	89 c3                	mov    %eax,%ebx
  801864:	85 c0                	test   %eax,%eax
  801866:	79 17                	jns    80187f <open+0x6c>
		fd_close(fd, 0);
  801868:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80186f:	00 
  801870:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801873:	89 04 24             	mov    %eax,(%esp)
  801876:	e8 db f8 ff ff       	call   801156 <fd_close>
		return r;
  80187b:	89 d8                	mov    %ebx,%eax
  80187d:	eb 12                	jmp    801891 <open+0x7e>
	}

	return fd2num(fd);
  80187f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801882:	89 04 24             	mov    %eax,(%esp)
  801885:	e8 a6 f7 ff ff       	call   801030 <fd2num>
  80188a:	eb 05                	jmp    801891 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80188c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801891:	83 c4 24             	add    $0x24,%esp
  801894:	5b                   	pop    %ebx
  801895:	5d                   	pop    %ebp
  801896:	c3                   	ret    

00801897 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801897:	55                   	push   %ebp
  801898:	89 e5                	mov    %esp,%ebp
  80189a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80189d:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a2:	b8 08 00 00 00       	mov    $0x8,%eax
  8018a7:	e8 67 fd ff ff       	call   801613 <fsipc>
}
  8018ac:	c9                   	leave  
  8018ad:	c3                   	ret    
  8018ae:	66 90                	xchg   %ax,%ax

008018b0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  8018b6:	c7 44 24 04 6f 2b 80 	movl   $0x802b6f,0x4(%esp)
  8018bd:	00 
  8018be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c1:	89 04 24             	mov    %eax,(%esp)
  8018c4:	e8 9e ef ff ff       	call   800867 <strcpy>
	return 0;
}
  8018c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ce:	c9                   	leave  
  8018cf:	c3                   	ret    

008018d0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	53                   	push   %ebx
  8018d4:	83 ec 14             	sub    $0x14,%esp
  8018d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8018da:	89 1c 24             	mov    %ebx,(%esp)
  8018dd:	e8 2b 0b 00 00       	call   80240d <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8018e2:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8018e7:	83 f8 01             	cmp    $0x1,%eax
  8018ea:	75 0d                	jne    8018f9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  8018ec:	8b 43 0c             	mov    0xc(%ebx),%eax
  8018ef:	89 04 24             	mov    %eax,(%esp)
  8018f2:	e8 29 03 00 00       	call   801c20 <nsipc_close>
  8018f7:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  8018f9:	89 d0                	mov    %edx,%eax
  8018fb:	83 c4 14             	add    $0x14,%esp
  8018fe:	5b                   	pop    %ebx
  8018ff:	5d                   	pop    %ebp
  801900:	c3                   	ret    

00801901 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801901:	55                   	push   %ebp
  801902:	89 e5                	mov    %esp,%ebp
  801904:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801907:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80190e:	00 
  80190f:	8b 45 10             	mov    0x10(%ebp),%eax
  801912:	89 44 24 08          	mov    %eax,0x8(%esp)
  801916:	8b 45 0c             	mov    0xc(%ebp),%eax
  801919:	89 44 24 04          	mov    %eax,0x4(%esp)
  80191d:	8b 45 08             	mov    0x8(%ebp),%eax
  801920:	8b 40 0c             	mov    0xc(%eax),%eax
  801923:	89 04 24             	mov    %eax,(%esp)
  801926:	e8 f0 03 00 00       	call   801d1b <nsipc_send>
}
  80192b:	c9                   	leave  
  80192c:	c3                   	ret    

0080192d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80192d:	55                   	push   %ebp
  80192e:	89 e5                	mov    %esp,%ebp
  801930:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801933:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80193a:	00 
  80193b:	8b 45 10             	mov    0x10(%ebp),%eax
  80193e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801942:	8b 45 0c             	mov    0xc(%ebp),%eax
  801945:	89 44 24 04          	mov    %eax,0x4(%esp)
  801949:	8b 45 08             	mov    0x8(%ebp),%eax
  80194c:	8b 40 0c             	mov    0xc(%eax),%eax
  80194f:	89 04 24             	mov    %eax,(%esp)
  801952:	e8 44 03 00 00       	call   801c9b <nsipc_recv>
}
  801957:	c9                   	leave  
  801958:	c3                   	ret    

00801959 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801959:	55                   	push   %ebp
  80195a:	89 e5                	mov    %esp,%ebp
  80195c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80195f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801962:	89 54 24 04          	mov    %edx,0x4(%esp)
  801966:	89 04 24             	mov    %eax,(%esp)
  801969:	e8 38 f7 ff ff       	call   8010a6 <fd_lookup>
  80196e:	85 c0                	test   %eax,%eax
  801970:	78 17                	js     801989 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801972:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801975:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80197b:	39 08                	cmp    %ecx,(%eax)
  80197d:	75 05                	jne    801984 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80197f:	8b 40 0c             	mov    0xc(%eax),%eax
  801982:	eb 05                	jmp    801989 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801984:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801989:	c9                   	leave  
  80198a:	c3                   	ret    

0080198b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80198b:	55                   	push   %ebp
  80198c:	89 e5                	mov    %esp,%ebp
  80198e:	56                   	push   %esi
  80198f:	53                   	push   %ebx
  801990:	83 ec 20             	sub    $0x20,%esp
  801993:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801995:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801998:	89 04 24             	mov    %eax,(%esp)
  80199b:	e8 b7 f6 ff ff       	call   801057 <fd_alloc>
  8019a0:	89 c3                	mov    %eax,%ebx
  8019a2:	85 c0                	test   %eax,%eax
  8019a4:	78 21                	js     8019c7 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8019a6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8019ad:	00 
  8019ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019bc:	e8 c2 f2 ff ff       	call   800c83 <sys_page_alloc>
  8019c1:	89 c3                	mov    %eax,%ebx
  8019c3:	85 c0                	test   %eax,%eax
  8019c5:	79 0c                	jns    8019d3 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  8019c7:	89 34 24             	mov    %esi,(%esp)
  8019ca:	e8 51 02 00 00       	call   801c20 <nsipc_close>
		return r;
  8019cf:	89 d8                	mov    %ebx,%eax
  8019d1:	eb 20                	jmp    8019f3 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8019d3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019dc:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8019de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019e1:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  8019e8:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  8019eb:	89 14 24             	mov    %edx,(%esp)
  8019ee:	e8 3d f6 ff ff       	call   801030 <fd2num>
}
  8019f3:	83 c4 20             	add    $0x20,%esp
  8019f6:	5b                   	pop    %ebx
  8019f7:	5e                   	pop    %esi
  8019f8:	5d                   	pop    %ebp
  8019f9:	c3                   	ret    

008019fa <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a00:	8b 45 08             	mov    0x8(%ebp),%eax
  801a03:	e8 51 ff ff ff       	call   801959 <fd2sockid>
		return r;
  801a08:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a0a:	85 c0                	test   %eax,%eax
  801a0c:	78 23                	js     801a31 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a0e:	8b 55 10             	mov    0x10(%ebp),%edx
  801a11:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a15:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a18:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a1c:	89 04 24             	mov    %eax,(%esp)
  801a1f:	e8 45 01 00 00       	call   801b69 <nsipc_accept>
		return r;
  801a24:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a26:	85 c0                	test   %eax,%eax
  801a28:	78 07                	js     801a31 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  801a2a:	e8 5c ff ff ff       	call   80198b <alloc_sockfd>
  801a2f:	89 c1                	mov    %eax,%ecx
}
  801a31:	89 c8                	mov    %ecx,%eax
  801a33:	c9                   	leave  
  801a34:	c3                   	ret    

00801a35 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3e:	e8 16 ff ff ff       	call   801959 <fd2sockid>
  801a43:	89 c2                	mov    %eax,%edx
  801a45:	85 d2                	test   %edx,%edx
  801a47:	78 16                	js     801a5f <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  801a49:	8b 45 10             	mov    0x10(%ebp),%eax
  801a4c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a50:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a53:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a57:	89 14 24             	mov    %edx,(%esp)
  801a5a:	e8 60 01 00 00       	call   801bbf <nsipc_bind>
}
  801a5f:	c9                   	leave  
  801a60:	c3                   	ret    

00801a61 <shutdown>:

int
shutdown(int s, int how)
{
  801a61:	55                   	push   %ebp
  801a62:	89 e5                	mov    %esp,%ebp
  801a64:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a67:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6a:	e8 ea fe ff ff       	call   801959 <fd2sockid>
  801a6f:	89 c2                	mov    %eax,%edx
  801a71:	85 d2                	test   %edx,%edx
  801a73:	78 0f                	js     801a84 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801a75:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a78:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a7c:	89 14 24             	mov    %edx,(%esp)
  801a7f:	e8 7a 01 00 00       	call   801bfe <nsipc_shutdown>
}
  801a84:	c9                   	leave  
  801a85:	c3                   	ret    

00801a86 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a86:	55                   	push   %ebp
  801a87:	89 e5                	mov    %esp,%ebp
  801a89:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8f:	e8 c5 fe ff ff       	call   801959 <fd2sockid>
  801a94:	89 c2                	mov    %eax,%edx
  801a96:	85 d2                	test   %edx,%edx
  801a98:	78 16                	js     801ab0 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  801a9a:	8b 45 10             	mov    0x10(%ebp),%eax
  801a9d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801aa1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa8:	89 14 24             	mov    %edx,(%esp)
  801aab:	e8 8a 01 00 00       	call   801c3a <nsipc_connect>
}
  801ab0:	c9                   	leave  
  801ab1:	c3                   	ret    

00801ab2 <listen>:

int
listen(int s, int backlog)
{
  801ab2:	55                   	push   %ebp
  801ab3:	89 e5                	mov    %esp,%ebp
  801ab5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  801abb:	e8 99 fe ff ff       	call   801959 <fd2sockid>
  801ac0:	89 c2                	mov    %eax,%edx
  801ac2:	85 d2                	test   %edx,%edx
  801ac4:	78 0f                	js     801ad5 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801ac6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801acd:	89 14 24             	mov    %edx,(%esp)
  801ad0:	e8 a4 01 00 00       	call   801c79 <nsipc_listen>
}
  801ad5:	c9                   	leave  
  801ad6:	c3                   	ret    

00801ad7 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801ad7:	55                   	push   %ebp
  801ad8:	89 e5                	mov    %esp,%ebp
  801ada:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801add:	8b 45 10             	mov    0x10(%ebp),%eax
  801ae0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ae4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  801aee:	89 04 24             	mov    %eax,(%esp)
  801af1:	e8 98 02 00 00       	call   801d8e <nsipc_socket>
  801af6:	89 c2                	mov    %eax,%edx
  801af8:	85 d2                	test   %edx,%edx
  801afa:	78 05                	js     801b01 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  801afc:	e8 8a fe ff ff       	call   80198b <alloc_sockfd>
}
  801b01:	c9                   	leave  
  801b02:	c3                   	ret    

00801b03 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b03:	55                   	push   %ebp
  801b04:	89 e5                	mov    %esp,%ebp
  801b06:	53                   	push   %ebx
  801b07:	83 ec 14             	sub    $0x14,%esp
  801b0a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b0c:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801b13:	75 11                	jne    801b26 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b15:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801b1c:	e8 b4 08 00 00       	call   8023d5 <ipc_find_env>
  801b21:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b26:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b2d:	00 
  801b2e:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801b35:	00 
  801b36:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b3a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b3f:	89 04 24             	mov    %eax,(%esp)
  801b42:	e8 23 08 00 00       	call   80236a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b47:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b4e:	00 
  801b4f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b56:	00 
  801b57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b5e:	e8 8d 07 00 00       	call   8022f0 <ipc_recv>
}
  801b63:	83 c4 14             	add    $0x14,%esp
  801b66:	5b                   	pop    %ebx
  801b67:	5d                   	pop    %ebp
  801b68:	c3                   	ret    

00801b69 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	56                   	push   %esi
  801b6d:	53                   	push   %ebx
  801b6e:	83 ec 10             	sub    $0x10,%esp
  801b71:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801b74:	8b 45 08             	mov    0x8(%ebp),%eax
  801b77:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801b7c:	8b 06                	mov    (%esi),%eax
  801b7e:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801b83:	b8 01 00 00 00       	mov    $0x1,%eax
  801b88:	e8 76 ff ff ff       	call   801b03 <nsipc>
  801b8d:	89 c3                	mov    %eax,%ebx
  801b8f:	85 c0                	test   %eax,%eax
  801b91:	78 23                	js     801bb6 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801b93:	a1 10 60 80 00       	mov    0x806010,%eax
  801b98:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b9c:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801ba3:	00 
  801ba4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba7:	89 04 24             	mov    %eax,(%esp)
  801baa:	e8 55 ee ff ff       	call   800a04 <memmove>
		*addrlen = ret->ret_addrlen;
  801baf:	a1 10 60 80 00       	mov    0x806010,%eax
  801bb4:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801bb6:	89 d8                	mov    %ebx,%eax
  801bb8:	83 c4 10             	add    $0x10,%esp
  801bbb:	5b                   	pop    %ebx
  801bbc:	5e                   	pop    %esi
  801bbd:	5d                   	pop    %ebp
  801bbe:	c3                   	ret    

00801bbf <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bbf:	55                   	push   %ebp
  801bc0:	89 e5                	mov    %esp,%ebp
  801bc2:	53                   	push   %ebx
  801bc3:	83 ec 14             	sub    $0x14,%esp
  801bc6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcc:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801bd1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bd5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bd8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bdc:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801be3:	e8 1c ee ff ff       	call   800a04 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801be8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801bee:	b8 02 00 00 00       	mov    $0x2,%eax
  801bf3:	e8 0b ff ff ff       	call   801b03 <nsipc>
}
  801bf8:	83 c4 14             	add    $0x14,%esp
  801bfb:	5b                   	pop    %ebx
  801bfc:	5d                   	pop    %ebp
  801bfd:	c3                   	ret    

00801bfe <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801bfe:	55                   	push   %ebp
  801bff:	89 e5                	mov    %esp,%ebp
  801c01:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c04:	8b 45 08             	mov    0x8(%ebp),%eax
  801c07:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c0f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c14:	b8 03 00 00 00       	mov    $0x3,%eax
  801c19:	e8 e5 fe ff ff       	call   801b03 <nsipc>
}
  801c1e:	c9                   	leave  
  801c1f:	c3                   	ret    

00801c20 <nsipc_close>:

int
nsipc_close(int s)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c26:	8b 45 08             	mov    0x8(%ebp),%eax
  801c29:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c2e:	b8 04 00 00 00       	mov    $0x4,%eax
  801c33:	e8 cb fe ff ff       	call   801b03 <nsipc>
}
  801c38:	c9                   	leave  
  801c39:	c3                   	ret    

00801c3a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
  801c3d:	53                   	push   %ebx
  801c3e:	83 ec 14             	sub    $0x14,%esp
  801c41:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c44:	8b 45 08             	mov    0x8(%ebp),%eax
  801c47:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c4c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c50:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c53:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c57:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801c5e:	e8 a1 ed ff ff       	call   800a04 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801c63:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801c69:	b8 05 00 00 00       	mov    $0x5,%eax
  801c6e:	e8 90 fe ff ff       	call   801b03 <nsipc>
}
  801c73:	83 c4 14             	add    $0x14,%esp
  801c76:	5b                   	pop    %ebx
  801c77:	5d                   	pop    %ebp
  801c78:	c3                   	ret    

00801c79 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c82:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801c87:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c8a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801c8f:	b8 06 00 00 00       	mov    $0x6,%eax
  801c94:	e8 6a fe ff ff       	call   801b03 <nsipc>
}
  801c99:	c9                   	leave  
  801c9a:	c3                   	ret    

00801c9b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801c9b:	55                   	push   %ebp
  801c9c:	89 e5                	mov    %esp,%ebp
  801c9e:	56                   	push   %esi
  801c9f:	53                   	push   %ebx
  801ca0:	83 ec 10             	sub    $0x10,%esp
  801ca3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801ca6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801cae:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801cb4:	8b 45 14             	mov    0x14(%ebp),%eax
  801cb7:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801cbc:	b8 07 00 00 00       	mov    $0x7,%eax
  801cc1:	e8 3d fe ff ff       	call   801b03 <nsipc>
  801cc6:	89 c3                	mov    %eax,%ebx
  801cc8:	85 c0                	test   %eax,%eax
  801cca:	78 46                	js     801d12 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801ccc:	39 f0                	cmp    %esi,%eax
  801cce:	7f 07                	jg     801cd7 <nsipc_recv+0x3c>
  801cd0:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801cd5:	7e 24                	jle    801cfb <nsipc_recv+0x60>
  801cd7:	c7 44 24 0c 7b 2b 80 	movl   $0x802b7b,0xc(%esp)
  801cde:	00 
  801cdf:	c7 44 24 08 43 2b 80 	movl   $0x802b43,0x8(%esp)
  801ce6:	00 
  801ce7:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801cee:	00 
  801cef:	c7 04 24 90 2b 80 00 	movl   $0x802b90,(%esp)
  801cf6:	e8 46 e4 ff ff       	call   800141 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801cfb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cff:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801d06:	00 
  801d07:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d0a:	89 04 24             	mov    %eax,(%esp)
  801d0d:	e8 f2 ec ff ff       	call   800a04 <memmove>
	}

	return r;
}
  801d12:	89 d8                	mov    %ebx,%eax
  801d14:	83 c4 10             	add    $0x10,%esp
  801d17:	5b                   	pop    %ebx
  801d18:	5e                   	pop    %esi
  801d19:	5d                   	pop    %ebp
  801d1a:	c3                   	ret    

00801d1b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	53                   	push   %ebx
  801d1f:	83 ec 14             	sub    $0x14,%esp
  801d22:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d25:	8b 45 08             	mov    0x8(%ebp),%eax
  801d28:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d2d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d33:	7e 24                	jle    801d59 <nsipc_send+0x3e>
  801d35:	c7 44 24 0c 9c 2b 80 	movl   $0x802b9c,0xc(%esp)
  801d3c:	00 
  801d3d:	c7 44 24 08 43 2b 80 	movl   $0x802b43,0x8(%esp)
  801d44:	00 
  801d45:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801d4c:	00 
  801d4d:	c7 04 24 90 2b 80 00 	movl   $0x802b90,(%esp)
  801d54:	e8 e8 e3 ff ff       	call   800141 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d60:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d64:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801d6b:	e8 94 ec ff ff       	call   800a04 <memmove>
	nsipcbuf.send.req_size = size;
  801d70:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801d76:	8b 45 14             	mov    0x14(%ebp),%eax
  801d79:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801d7e:	b8 08 00 00 00       	mov    $0x8,%eax
  801d83:	e8 7b fd ff ff       	call   801b03 <nsipc>
}
  801d88:	83 c4 14             	add    $0x14,%esp
  801d8b:	5b                   	pop    %ebx
  801d8c:	5d                   	pop    %ebp
  801d8d:	c3                   	ret    

00801d8e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d94:	8b 45 08             	mov    0x8(%ebp),%eax
  801d97:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801d9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d9f:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801da4:	8b 45 10             	mov    0x10(%ebp),%eax
  801da7:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801dac:	b8 09 00 00 00       	mov    $0x9,%eax
  801db1:	e8 4d fd ff ff       	call   801b03 <nsipc>
}
  801db6:	c9                   	leave  
  801db7:	c3                   	ret    

00801db8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801db8:	55                   	push   %ebp
  801db9:	89 e5                	mov    %esp,%ebp
  801dbb:	56                   	push   %esi
  801dbc:	53                   	push   %ebx
  801dbd:	83 ec 10             	sub    $0x10,%esp
  801dc0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801dc3:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc6:	89 04 24             	mov    %eax,(%esp)
  801dc9:	e8 72 f2 ff ff       	call   801040 <fd2data>
  801dce:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801dd0:	c7 44 24 04 a8 2b 80 	movl   $0x802ba8,0x4(%esp)
  801dd7:	00 
  801dd8:	89 1c 24             	mov    %ebx,(%esp)
  801ddb:	e8 87 ea ff ff       	call   800867 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801de0:	8b 46 04             	mov    0x4(%esi),%eax
  801de3:	2b 06                	sub    (%esi),%eax
  801de5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801deb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801df2:	00 00 00 
	stat->st_dev = &devpipe;
  801df5:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801dfc:	30 80 00 
	return 0;
}
  801dff:	b8 00 00 00 00       	mov    $0x0,%eax
  801e04:	83 c4 10             	add    $0x10,%esp
  801e07:	5b                   	pop    %ebx
  801e08:	5e                   	pop    %esi
  801e09:	5d                   	pop    %ebp
  801e0a:	c3                   	ret    

00801e0b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e0b:	55                   	push   %ebp
  801e0c:	89 e5                	mov    %esp,%ebp
  801e0e:	53                   	push   %ebx
  801e0f:	83 ec 14             	sub    $0x14,%esp
  801e12:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e15:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e19:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e20:	e8 05 ef ff ff       	call   800d2a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e25:	89 1c 24             	mov    %ebx,(%esp)
  801e28:	e8 13 f2 ff ff       	call   801040 <fd2data>
  801e2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e38:	e8 ed ee ff ff       	call   800d2a <sys_page_unmap>
}
  801e3d:	83 c4 14             	add    $0x14,%esp
  801e40:	5b                   	pop    %ebx
  801e41:	5d                   	pop    %ebp
  801e42:	c3                   	ret    

00801e43 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e43:	55                   	push   %ebp
  801e44:	89 e5                	mov    %esp,%ebp
  801e46:	57                   	push   %edi
  801e47:	56                   	push   %esi
  801e48:	53                   	push   %ebx
  801e49:	83 ec 2c             	sub    $0x2c,%esp
  801e4c:	89 c6                	mov    %eax,%esi
  801e4e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e51:	a1 08 40 80 00       	mov    0x804008,%eax
  801e56:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e59:	89 34 24             	mov    %esi,(%esp)
  801e5c:	e8 ac 05 00 00       	call   80240d <pageref>
  801e61:	89 c7                	mov    %eax,%edi
  801e63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e66:	89 04 24             	mov    %eax,(%esp)
  801e69:	e8 9f 05 00 00       	call   80240d <pageref>
  801e6e:	39 c7                	cmp    %eax,%edi
  801e70:	0f 94 c2             	sete   %dl
  801e73:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801e76:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801e7c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801e7f:	39 fb                	cmp    %edi,%ebx
  801e81:	74 21                	je     801ea4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801e83:	84 d2                	test   %dl,%dl
  801e85:	74 ca                	je     801e51 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e87:	8b 51 58             	mov    0x58(%ecx),%edx
  801e8a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e8e:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e92:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e96:	c7 04 24 af 2b 80 00 	movl   $0x802baf,(%esp)
  801e9d:	e8 98 e3 ff ff       	call   80023a <cprintf>
  801ea2:	eb ad                	jmp    801e51 <_pipeisclosed+0xe>
	}
}
  801ea4:	83 c4 2c             	add    $0x2c,%esp
  801ea7:	5b                   	pop    %ebx
  801ea8:	5e                   	pop    %esi
  801ea9:	5f                   	pop    %edi
  801eaa:	5d                   	pop    %ebp
  801eab:	c3                   	ret    

00801eac <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801eac:	55                   	push   %ebp
  801ead:	89 e5                	mov    %esp,%ebp
  801eaf:	57                   	push   %edi
  801eb0:	56                   	push   %esi
  801eb1:	53                   	push   %ebx
  801eb2:	83 ec 1c             	sub    $0x1c,%esp
  801eb5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801eb8:	89 34 24             	mov    %esi,(%esp)
  801ebb:	e8 80 f1 ff ff       	call   801040 <fd2data>
  801ec0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ec2:	bf 00 00 00 00       	mov    $0x0,%edi
  801ec7:	eb 45                	jmp    801f0e <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ec9:	89 da                	mov    %ebx,%edx
  801ecb:	89 f0                	mov    %esi,%eax
  801ecd:	e8 71 ff ff ff       	call   801e43 <_pipeisclosed>
  801ed2:	85 c0                	test   %eax,%eax
  801ed4:	75 41                	jne    801f17 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ed6:	e8 89 ed ff ff       	call   800c64 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801edb:	8b 43 04             	mov    0x4(%ebx),%eax
  801ede:	8b 0b                	mov    (%ebx),%ecx
  801ee0:	8d 51 20             	lea    0x20(%ecx),%edx
  801ee3:	39 d0                	cmp    %edx,%eax
  801ee5:	73 e2                	jae    801ec9 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ee7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801eea:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801eee:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ef1:	99                   	cltd   
  801ef2:	c1 ea 1b             	shr    $0x1b,%edx
  801ef5:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801ef8:	83 e1 1f             	and    $0x1f,%ecx
  801efb:	29 d1                	sub    %edx,%ecx
  801efd:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801f01:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801f05:	83 c0 01             	add    $0x1,%eax
  801f08:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f0b:	83 c7 01             	add    $0x1,%edi
  801f0e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f11:	75 c8                	jne    801edb <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f13:	89 f8                	mov    %edi,%eax
  801f15:	eb 05                	jmp    801f1c <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f17:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f1c:	83 c4 1c             	add    $0x1c,%esp
  801f1f:	5b                   	pop    %ebx
  801f20:	5e                   	pop    %esi
  801f21:	5f                   	pop    %edi
  801f22:	5d                   	pop    %ebp
  801f23:	c3                   	ret    

00801f24 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f24:	55                   	push   %ebp
  801f25:	89 e5                	mov    %esp,%ebp
  801f27:	57                   	push   %edi
  801f28:	56                   	push   %esi
  801f29:	53                   	push   %ebx
  801f2a:	83 ec 1c             	sub    $0x1c,%esp
  801f2d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f30:	89 3c 24             	mov    %edi,(%esp)
  801f33:	e8 08 f1 ff ff       	call   801040 <fd2data>
  801f38:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f3a:	be 00 00 00 00       	mov    $0x0,%esi
  801f3f:	eb 3d                	jmp    801f7e <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f41:	85 f6                	test   %esi,%esi
  801f43:	74 04                	je     801f49 <devpipe_read+0x25>
				return i;
  801f45:	89 f0                	mov    %esi,%eax
  801f47:	eb 43                	jmp    801f8c <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f49:	89 da                	mov    %ebx,%edx
  801f4b:	89 f8                	mov    %edi,%eax
  801f4d:	e8 f1 fe ff ff       	call   801e43 <_pipeisclosed>
  801f52:	85 c0                	test   %eax,%eax
  801f54:	75 31                	jne    801f87 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f56:	e8 09 ed ff ff       	call   800c64 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f5b:	8b 03                	mov    (%ebx),%eax
  801f5d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f60:	74 df                	je     801f41 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f62:	99                   	cltd   
  801f63:	c1 ea 1b             	shr    $0x1b,%edx
  801f66:	01 d0                	add    %edx,%eax
  801f68:	83 e0 1f             	and    $0x1f,%eax
  801f6b:	29 d0                	sub    %edx,%eax
  801f6d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801f72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f75:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801f78:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f7b:	83 c6 01             	add    $0x1,%esi
  801f7e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f81:	75 d8                	jne    801f5b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f83:	89 f0                	mov    %esi,%eax
  801f85:	eb 05                	jmp    801f8c <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f87:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f8c:	83 c4 1c             	add    $0x1c,%esp
  801f8f:	5b                   	pop    %ebx
  801f90:	5e                   	pop    %esi
  801f91:	5f                   	pop    %edi
  801f92:	5d                   	pop    %ebp
  801f93:	c3                   	ret    

00801f94 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f94:	55                   	push   %ebp
  801f95:	89 e5                	mov    %esp,%ebp
  801f97:	56                   	push   %esi
  801f98:	53                   	push   %ebx
  801f99:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f9f:	89 04 24             	mov    %eax,(%esp)
  801fa2:	e8 b0 f0 ff ff       	call   801057 <fd_alloc>
  801fa7:	89 c2                	mov    %eax,%edx
  801fa9:	85 d2                	test   %edx,%edx
  801fab:	0f 88 4d 01 00 00    	js     8020fe <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fb1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fb8:	00 
  801fb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fc0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fc7:	e8 b7 ec ff ff       	call   800c83 <sys_page_alloc>
  801fcc:	89 c2                	mov    %eax,%edx
  801fce:	85 d2                	test   %edx,%edx
  801fd0:	0f 88 28 01 00 00    	js     8020fe <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801fd6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fd9:	89 04 24             	mov    %eax,(%esp)
  801fdc:	e8 76 f0 ff ff       	call   801057 <fd_alloc>
  801fe1:	89 c3                	mov    %eax,%ebx
  801fe3:	85 c0                	test   %eax,%eax
  801fe5:	0f 88 fe 00 00 00    	js     8020e9 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801feb:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ff2:	00 
  801ff3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ff6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ffa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802001:	e8 7d ec ff ff       	call   800c83 <sys_page_alloc>
  802006:	89 c3                	mov    %eax,%ebx
  802008:	85 c0                	test   %eax,%eax
  80200a:	0f 88 d9 00 00 00    	js     8020e9 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802010:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802013:	89 04 24             	mov    %eax,(%esp)
  802016:	e8 25 f0 ff ff       	call   801040 <fd2data>
  80201b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80201d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802024:	00 
  802025:	89 44 24 04          	mov    %eax,0x4(%esp)
  802029:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802030:	e8 4e ec ff ff       	call   800c83 <sys_page_alloc>
  802035:	89 c3                	mov    %eax,%ebx
  802037:	85 c0                	test   %eax,%eax
  802039:	0f 88 97 00 00 00    	js     8020d6 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80203f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802042:	89 04 24             	mov    %eax,(%esp)
  802045:	e8 f6 ef ff ff       	call   801040 <fd2data>
  80204a:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802051:	00 
  802052:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802056:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80205d:	00 
  80205e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802062:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802069:	e8 69 ec ff ff       	call   800cd7 <sys_page_map>
  80206e:	89 c3                	mov    %eax,%ebx
  802070:	85 c0                	test   %eax,%eax
  802072:	78 52                	js     8020c6 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802074:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80207a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80207d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80207f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802082:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802089:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80208f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802092:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802094:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802097:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80209e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a1:	89 04 24             	mov    %eax,(%esp)
  8020a4:	e8 87 ef ff ff       	call   801030 <fd2num>
  8020a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020ac:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020b1:	89 04 24             	mov    %eax,(%esp)
  8020b4:	e8 77 ef ff ff       	call   801030 <fd2num>
  8020b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020bc:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8020c4:	eb 38                	jmp    8020fe <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  8020c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020d1:	e8 54 ec ff ff       	call   800d2a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8020d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020e4:	e8 41 ec ff ff       	call   800d2a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8020e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020f7:	e8 2e ec ff ff       	call   800d2a <sys_page_unmap>
  8020fc:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  8020fe:	83 c4 30             	add    $0x30,%esp
  802101:	5b                   	pop    %ebx
  802102:	5e                   	pop    %esi
  802103:	5d                   	pop    %ebp
  802104:	c3                   	ret    

00802105 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802105:	55                   	push   %ebp
  802106:	89 e5                	mov    %esp,%ebp
  802108:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80210b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80210e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802112:	8b 45 08             	mov    0x8(%ebp),%eax
  802115:	89 04 24             	mov    %eax,(%esp)
  802118:	e8 89 ef ff ff       	call   8010a6 <fd_lookup>
  80211d:	89 c2                	mov    %eax,%edx
  80211f:	85 d2                	test   %edx,%edx
  802121:	78 15                	js     802138 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802123:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802126:	89 04 24             	mov    %eax,(%esp)
  802129:	e8 12 ef ff ff       	call   801040 <fd2data>
	return _pipeisclosed(fd, p);
  80212e:	89 c2                	mov    %eax,%edx
  802130:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802133:	e8 0b fd ff ff       	call   801e43 <_pipeisclosed>
}
  802138:	c9                   	leave  
  802139:	c3                   	ret    
  80213a:	66 90                	xchg   %ax,%ax
  80213c:	66 90                	xchg   %ax,%ax
  80213e:	66 90                	xchg   %ax,%ax

00802140 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802140:	55                   	push   %ebp
  802141:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802143:	b8 00 00 00 00       	mov    $0x0,%eax
  802148:	5d                   	pop    %ebp
  802149:	c3                   	ret    

0080214a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80214a:	55                   	push   %ebp
  80214b:	89 e5                	mov    %esp,%ebp
  80214d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802150:	c7 44 24 04 c7 2b 80 	movl   $0x802bc7,0x4(%esp)
  802157:	00 
  802158:	8b 45 0c             	mov    0xc(%ebp),%eax
  80215b:	89 04 24             	mov    %eax,(%esp)
  80215e:	e8 04 e7 ff ff       	call   800867 <strcpy>
	return 0;
}
  802163:	b8 00 00 00 00       	mov    $0x0,%eax
  802168:	c9                   	leave  
  802169:	c3                   	ret    

0080216a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80216a:	55                   	push   %ebp
  80216b:	89 e5                	mov    %esp,%ebp
  80216d:	57                   	push   %edi
  80216e:	56                   	push   %esi
  80216f:	53                   	push   %ebx
  802170:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802176:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80217b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802181:	eb 31                	jmp    8021b4 <devcons_write+0x4a>
		m = n - tot;
  802183:	8b 75 10             	mov    0x10(%ebp),%esi
  802186:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802188:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80218b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802190:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802193:	89 74 24 08          	mov    %esi,0x8(%esp)
  802197:	03 45 0c             	add    0xc(%ebp),%eax
  80219a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80219e:	89 3c 24             	mov    %edi,(%esp)
  8021a1:	e8 5e e8 ff ff       	call   800a04 <memmove>
		sys_cputs(buf, m);
  8021a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021aa:	89 3c 24             	mov    %edi,(%esp)
  8021ad:	e8 04 ea ff ff       	call   800bb6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021b2:	01 f3                	add    %esi,%ebx
  8021b4:	89 d8                	mov    %ebx,%eax
  8021b6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8021b9:	72 c8                	jb     802183 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021bb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8021c1:	5b                   	pop    %ebx
  8021c2:	5e                   	pop    %esi
  8021c3:	5f                   	pop    %edi
  8021c4:	5d                   	pop    %ebp
  8021c5:	c3                   	ret    

008021c6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021c6:	55                   	push   %ebp
  8021c7:	89 e5                	mov    %esp,%ebp
  8021c9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8021cc:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8021d1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021d5:	75 07                	jne    8021de <devcons_read+0x18>
  8021d7:	eb 2a                	jmp    802203 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021d9:	e8 86 ea ff ff       	call   800c64 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021de:	66 90                	xchg   %ax,%ax
  8021e0:	e8 ef e9 ff ff       	call   800bd4 <sys_cgetc>
  8021e5:	85 c0                	test   %eax,%eax
  8021e7:	74 f0                	je     8021d9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8021e9:	85 c0                	test   %eax,%eax
  8021eb:	78 16                	js     802203 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021ed:	83 f8 04             	cmp    $0x4,%eax
  8021f0:	74 0c                	je     8021fe <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  8021f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021f5:	88 02                	mov    %al,(%edx)
	return 1;
  8021f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8021fc:	eb 05                	jmp    802203 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021fe:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802203:	c9                   	leave  
  802204:	c3                   	ret    

00802205 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802205:	55                   	push   %ebp
  802206:	89 e5                	mov    %esp,%ebp
  802208:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80220b:	8b 45 08             	mov    0x8(%ebp),%eax
  80220e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802211:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802218:	00 
  802219:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80221c:	89 04 24             	mov    %eax,(%esp)
  80221f:	e8 92 e9 ff ff       	call   800bb6 <sys_cputs>
}
  802224:	c9                   	leave  
  802225:	c3                   	ret    

00802226 <getchar>:

int
getchar(void)
{
  802226:	55                   	push   %ebp
  802227:	89 e5                	mov    %esp,%ebp
  802229:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80222c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802233:	00 
  802234:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802237:	89 44 24 04          	mov    %eax,0x4(%esp)
  80223b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802242:	e8 f3 f0 ff ff       	call   80133a <read>
	if (r < 0)
  802247:	85 c0                	test   %eax,%eax
  802249:	78 0f                	js     80225a <getchar+0x34>
		return r;
	if (r < 1)
  80224b:	85 c0                	test   %eax,%eax
  80224d:	7e 06                	jle    802255 <getchar+0x2f>
		return -E_EOF;
	return c;
  80224f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802253:	eb 05                	jmp    80225a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802255:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80225a:	c9                   	leave  
  80225b:	c3                   	ret    

0080225c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80225c:	55                   	push   %ebp
  80225d:	89 e5                	mov    %esp,%ebp
  80225f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802262:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802265:	89 44 24 04          	mov    %eax,0x4(%esp)
  802269:	8b 45 08             	mov    0x8(%ebp),%eax
  80226c:	89 04 24             	mov    %eax,(%esp)
  80226f:	e8 32 ee ff ff       	call   8010a6 <fd_lookup>
  802274:	85 c0                	test   %eax,%eax
  802276:	78 11                	js     802289 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802278:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80227b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802281:	39 10                	cmp    %edx,(%eax)
  802283:	0f 94 c0             	sete   %al
  802286:	0f b6 c0             	movzbl %al,%eax
}
  802289:	c9                   	leave  
  80228a:	c3                   	ret    

0080228b <opencons>:

int
opencons(void)
{
  80228b:	55                   	push   %ebp
  80228c:	89 e5                	mov    %esp,%ebp
  80228e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802291:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802294:	89 04 24             	mov    %eax,(%esp)
  802297:	e8 bb ed ff ff       	call   801057 <fd_alloc>
		return r;
  80229c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80229e:	85 c0                	test   %eax,%eax
  8022a0:	78 40                	js     8022e2 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022a2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022a9:	00 
  8022aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022b8:	e8 c6 e9 ff ff       	call   800c83 <sys_page_alloc>
		return r;
  8022bd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022bf:	85 c0                	test   %eax,%eax
  8022c1:	78 1f                	js     8022e2 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022c3:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022cc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022d1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022d8:	89 04 24             	mov    %eax,(%esp)
  8022db:	e8 50 ed ff ff       	call   801030 <fd2num>
  8022e0:	89 c2                	mov    %eax,%edx
}
  8022e2:	89 d0                	mov    %edx,%eax
  8022e4:	c9                   	leave  
  8022e5:	c3                   	ret    
  8022e6:	66 90                	xchg   %ax,%ax
  8022e8:	66 90                	xchg   %ax,%ax
  8022ea:	66 90                	xchg   %ax,%ax
  8022ec:	66 90                	xchg   %ax,%ax
  8022ee:	66 90                	xchg   %ax,%ax

008022f0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022f0:	55                   	push   %ebp
  8022f1:	89 e5                	mov    %esp,%ebp
  8022f3:	56                   	push   %esi
  8022f4:	53                   	push   %ebx
  8022f5:	83 ec 10             	sub    $0x10,%esp
  8022f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8022fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  802301:	85 c0                	test   %eax,%eax
  802303:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802308:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  80230b:	89 04 24             	mov    %eax,(%esp)
  80230e:	e8 86 eb ff ff       	call   800e99 <sys_ipc_recv>

	if(ret < 0) {
  802313:	85 c0                	test   %eax,%eax
  802315:	79 16                	jns    80232d <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  802317:	85 f6                	test   %esi,%esi
  802319:	74 06                	je     802321 <ipc_recv+0x31>
  80231b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  802321:	85 db                	test   %ebx,%ebx
  802323:	74 3e                	je     802363 <ipc_recv+0x73>
  802325:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80232b:	eb 36                	jmp    802363 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  80232d:	e8 13 e9 ff ff       	call   800c45 <sys_getenvid>
  802332:	25 ff 03 00 00       	and    $0x3ff,%eax
  802337:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80233a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80233f:	a3 08 40 80 00       	mov    %eax,0x804008

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802344:	85 f6                	test   %esi,%esi
  802346:	74 05                	je     80234d <ipc_recv+0x5d>
  802348:	8b 40 74             	mov    0x74(%eax),%eax
  80234b:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80234d:	85 db                	test   %ebx,%ebx
  80234f:	74 0a                	je     80235b <ipc_recv+0x6b>
  802351:	a1 08 40 80 00       	mov    0x804008,%eax
  802356:	8b 40 78             	mov    0x78(%eax),%eax
  802359:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  80235b:	a1 08 40 80 00       	mov    0x804008,%eax
  802360:	8b 40 70             	mov    0x70(%eax),%eax
}
  802363:	83 c4 10             	add    $0x10,%esp
  802366:	5b                   	pop    %ebx
  802367:	5e                   	pop    %esi
  802368:	5d                   	pop    %ebp
  802369:	c3                   	ret    

0080236a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80236a:	55                   	push   %ebp
  80236b:	89 e5                	mov    %esp,%ebp
  80236d:	57                   	push   %edi
  80236e:	56                   	push   %esi
  80236f:	53                   	push   %ebx
  802370:	83 ec 1c             	sub    $0x1c,%esp
  802373:	8b 7d 08             	mov    0x8(%ebp),%edi
  802376:	8b 75 0c             	mov    0xc(%ebp),%esi
  802379:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  80237c:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  80237e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802383:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  802386:	8b 45 14             	mov    0x14(%ebp),%eax
  802389:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80238d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802391:	89 74 24 04          	mov    %esi,0x4(%esp)
  802395:	89 3c 24             	mov    %edi,(%esp)
  802398:	e8 d9 ea ff ff       	call   800e76 <sys_ipc_try_send>

		if(ret >= 0) break;
  80239d:	85 c0                	test   %eax,%eax
  80239f:	79 2c                	jns    8023cd <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  8023a1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023a4:	74 20                	je     8023c6 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  8023a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023aa:	c7 44 24 08 d4 2b 80 	movl   $0x802bd4,0x8(%esp)
  8023b1:	00 
  8023b2:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8023b9:	00 
  8023ba:	c7 04 24 04 2c 80 00 	movl   $0x802c04,(%esp)
  8023c1:	e8 7b dd ff ff       	call   800141 <_panic>
		}
		sys_yield();
  8023c6:	e8 99 e8 ff ff       	call   800c64 <sys_yield>
	}
  8023cb:	eb b9                	jmp    802386 <ipc_send+0x1c>
}
  8023cd:	83 c4 1c             	add    $0x1c,%esp
  8023d0:	5b                   	pop    %ebx
  8023d1:	5e                   	pop    %esi
  8023d2:	5f                   	pop    %edi
  8023d3:	5d                   	pop    %ebp
  8023d4:	c3                   	ret    

008023d5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023d5:	55                   	push   %ebp
  8023d6:	89 e5                	mov    %esp,%ebp
  8023d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8023db:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8023e0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8023e3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023e9:	8b 52 50             	mov    0x50(%edx),%edx
  8023ec:	39 ca                	cmp    %ecx,%edx
  8023ee:	75 0d                	jne    8023fd <ipc_find_env+0x28>
			return envs[i].env_id;
  8023f0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8023f3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8023f8:	8b 40 40             	mov    0x40(%eax),%eax
  8023fb:	eb 0e                	jmp    80240b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023fd:	83 c0 01             	add    $0x1,%eax
  802400:	3d 00 04 00 00       	cmp    $0x400,%eax
  802405:	75 d9                	jne    8023e0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802407:	66 b8 00 00          	mov    $0x0,%ax
}
  80240b:	5d                   	pop    %ebp
  80240c:	c3                   	ret    

0080240d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80240d:	55                   	push   %ebp
  80240e:	89 e5                	mov    %esp,%ebp
  802410:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802413:	89 d0                	mov    %edx,%eax
  802415:	c1 e8 16             	shr    $0x16,%eax
  802418:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80241f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802424:	f6 c1 01             	test   $0x1,%cl
  802427:	74 1d                	je     802446 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802429:	c1 ea 0c             	shr    $0xc,%edx
  80242c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802433:	f6 c2 01             	test   $0x1,%dl
  802436:	74 0e                	je     802446 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802438:	c1 ea 0c             	shr    $0xc,%edx
  80243b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802442:	ef 
  802443:	0f b7 c0             	movzwl %ax,%eax
}
  802446:	5d                   	pop    %ebp
  802447:	c3                   	ret    
  802448:	66 90                	xchg   %ax,%ax
  80244a:	66 90                	xchg   %ax,%ax
  80244c:	66 90                	xchg   %ax,%ax
  80244e:	66 90                	xchg   %ax,%ax

00802450 <__udivdi3>:
  802450:	55                   	push   %ebp
  802451:	57                   	push   %edi
  802452:	56                   	push   %esi
  802453:	83 ec 0c             	sub    $0xc,%esp
  802456:	8b 44 24 28          	mov    0x28(%esp),%eax
  80245a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80245e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802462:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802466:	85 c0                	test   %eax,%eax
  802468:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80246c:	89 ea                	mov    %ebp,%edx
  80246e:	89 0c 24             	mov    %ecx,(%esp)
  802471:	75 2d                	jne    8024a0 <__udivdi3+0x50>
  802473:	39 e9                	cmp    %ebp,%ecx
  802475:	77 61                	ja     8024d8 <__udivdi3+0x88>
  802477:	85 c9                	test   %ecx,%ecx
  802479:	89 ce                	mov    %ecx,%esi
  80247b:	75 0b                	jne    802488 <__udivdi3+0x38>
  80247d:	b8 01 00 00 00       	mov    $0x1,%eax
  802482:	31 d2                	xor    %edx,%edx
  802484:	f7 f1                	div    %ecx
  802486:	89 c6                	mov    %eax,%esi
  802488:	31 d2                	xor    %edx,%edx
  80248a:	89 e8                	mov    %ebp,%eax
  80248c:	f7 f6                	div    %esi
  80248e:	89 c5                	mov    %eax,%ebp
  802490:	89 f8                	mov    %edi,%eax
  802492:	f7 f6                	div    %esi
  802494:	89 ea                	mov    %ebp,%edx
  802496:	83 c4 0c             	add    $0xc,%esp
  802499:	5e                   	pop    %esi
  80249a:	5f                   	pop    %edi
  80249b:	5d                   	pop    %ebp
  80249c:	c3                   	ret    
  80249d:	8d 76 00             	lea    0x0(%esi),%esi
  8024a0:	39 e8                	cmp    %ebp,%eax
  8024a2:	77 24                	ja     8024c8 <__udivdi3+0x78>
  8024a4:	0f bd e8             	bsr    %eax,%ebp
  8024a7:	83 f5 1f             	xor    $0x1f,%ebp
  8024aa:	75 3c                	jne    8024e8 <__udivdi3+0x98>
  8024ac:	8b 74 24 04          	mov    0x4(%esp),%esi
  8024b0:	39 34 24             	cmp    %esi,(%esp)
  8024b3:	0f 86 9f 00 00 00    	jbe    802558 <__udivdi3+0x108>
  8024b9:	39 d0                	cmp    %edx,%eax
  8024bb:	0f 82 97 00 00 00    	jb     802558 <__udivdi3+0x108>
  8024c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024c8:	31 d2                	xor    %edx,%edx
  8024ca:	31 c0                	xor    %eax,%eax
  8024cc:	83 c4 0c             	add    $0xc,%esp
  8024cf:	5e                   	pop    %esi
  8024d0:	5f                   	pop    %edi
  8024d1:	5d                   	pop    %ebp
  8024d2:	c3                   	ret    
  8024d3:	90                   	nop
  8024d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024d8:	89 f8                	mov    %edi,%eax
  8024da:	f7 f1                	div    %ecx
  8024dc:	31 d2                	xor    %edx,%edx
  8024de:	83 c4 0c             	add    $0xc,%esp
  8024e1:	5e                   	pop    %esi
  8024e2:	5f                   	pop    %edi
  8024e3:	5d                   	pop    %ebp
  8024e4:	c3                   	ret    
  8024e5:	8d 76 00             	lea    0x0(%esi),%esi
  8024e8:	89 e9                	mov    %ebp,%ecx
  8024ea:	8b 3c 24             	mov    (%esp),%edi
  8024ed:	d3 e0                	shl    %cl,%eax
  8024ef:	89 c6                	mov    %eax,%esi
  8024f1:	b8 20 00 00 00       	mov    $0x20,%eax
  8024f6:	29 e8                	sub    %ebp,%eax
  8024f8:	89 c1                	mov    %eax,%ecx
  8024fa:	d3 ef                	shr    %cl,%edi
  8024fc:	89 e9                	mov    %ebp,%ecx
  8024fe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802502:	8b 3c 24             	mov    (%esp),%edi
  802505:	09 74 24 08          	or     %esi,0x8(%esp)
  802509:	89 d6                	mov    %edx,%esi
  80250b:	d3 e7                	shl    %cl,%edi
  80250d:	89 c1                	mov    %eax,%ecx
  80250f:	89 3c 24             	mov    %edi,(%esp)
  802512:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802516:	d3 ee                	shr    %cl,%esi
  802518:	89 e9                	mov    %ebp,%ecx
  80251a:	d3 e2                	shl    %cl,%edx
  80251c:	89 c1                	mov    %eax,%ecx
  80251e:	d3 ef                	shr    %cl,%edi
  802520:	09 d7                	or     %edx,%edi
  802522:	89 f2                	mov    %esi,%edx
  802524:	89 f8                	mov    %edi,%eax
  802526:	f7 74 24 08          	divl   0x8(%esp)
  80252a:	89 d6                	mov    %edx,%esi
  80252c:	89 c7                	mov    %eax,%edi
  80252e:	f7 24 24             	mull   (%esp)
  802531:	39 d6                	cmp    %edx,%esi
  802533:	89 14 24             	mov    %edx,(%esp)
  802536:	72 30                	jb     802568 <__udivdi3+0x118>
  802538:	8b 54 24 04          	mov    0x4(%esp),%edx
  80253c:	89 e9                	mov    %ebp,%ecx
  80253e:	d3 e2                	shl    %cl,%edx
  802540:	39 c2                	cmp    %eax,%edx
  802542:	73 05                	jae    802549 <__udivdi3+0xf9>
  802544:	3b 34 24             	cmp    (%esp),%esi
  802547:	74 1f                	je     802568 <__udivdi3+0x118>
  802549:	89 f8                	mov    %edi,%eax
  80254b:	31 d2                	xor    %edx,%edx
  80254d:	e9 7a ff ff ff       	jmp    8024cc <__udivdi3+0x7c>
  802552:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802558:	31 d2                	xor    %edx,%edx
  80255a:	b8 01 00 00 00       	mov    $0x1,%eax
  80255f:	e9 68 ff ff ff       	jmp    8024cc <__udivdi3+0x7c>
  802564:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802568:	8d 47 ff             	lea    -0x1(%edi),%eax
  80256b:	31 d2                	xor    %edx,%edx
  80256d:	83 c4 0c             	add    $0xc,%esp
  802570:	5e                   	pop    %esi
  802571:	5f                   	pop    %edi
  802572:	5d                   	pop    %ebp
  802573:	c3                   	ret    
  802574:	66 90                	xchg   %ax,%ax
  802576:	66 90                	xchg   %ax,%ax
  802578:	66 90                	xchg   %ax,%ax
  80257a:	66 90                	xchg   %ax,%ax
  80257c:	66 90                	xchg   %ax,%ax
  80257e:	66 90                	xchg   %ax,%ax

00802580 <__umoddi3>:
  802580:	55                   	push   %ebp
  802581:	57                   	push   %edi
  802582:	56                   	push   %esi
  802583:	83 ec 14             	sub    $0x14,%esp
  802586:	8b 44 24 28          	mov    0x28(%esp),%eax
  80258a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80258e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802592:	89 c7                	mov    %eax,%edi
  802594:	89 44 24 04          	mov    %eax,0x4(%esp)
  802598:	8b 44 24 30          	mov    0x30(%esp),%eax
  80259c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8025a0:	89 34 24             	mov    %esi,(%esp)
  8025a3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025a7:	85 c0                	test   %eax,%eax
  8025a9:	89 c2                	mov    %eax,%edx
  8025ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8025af:	75 17                	jne    8025c8 <__umoddi3+0x48>
  8025b1:	39 fe                	cmp    %edi,%esi
  8025b3:	76 4b                	jbe    802600 <__umoddi3+0x80>
  8025b5:	89 c8                	mov    %ecx,%eax
  8025b7:	89 fa                	mov    %edi,%edx
  8025b9:	f7 f6                	div    %esi
  8025bb:	89 d0                	mov    %edx,%eax
  8025bd:	31 d2                	xor    %edx,%edx
  8025bf:	83 c4 14             	add    $0x14,%esp
  8025c2:	5e                   	pop    %esi
  8025c3:	5f                   	pop    %edi
  8025c4:	5d                   	pop    %ebp
  8025c5:	c3                   	ret    
  8025c6:	66 90                	xchg   %ax,%ax
  8025c8:	39 f8                	cmp    %edi,%eax
  8025ca:	77 54                	ja     802620 <__umoddi3+0xa0>
  8025cc:	0f bd e8             	bsr    %eax,%ebp
  8025cf:	83 f5 1f             	xor    $0x1f,%ebp
  8025d2:	75 5c                	jne    802630 <__umoddi3+0xb0>
  8025d4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8025d8:	39 3c 24             	cmp    %edi,(%esp)
  8025db:	0f 87 e7 00 00 00    	ja     8026c8 <__umoddi3+0x148>
  8025e1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8025e5:	29 f1                	sub    %esi,%ecx
  8025e7:	19 c7                	sbb    %eax,%edi
  8025e9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025ed:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8025f1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025f5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8025f9:	83 c4 14             	add    $0x14,%esp
  8025fc:	5e                   	pop    %esi
  8025fd:	5f                   	pop    %edi
  8025fe:	5d                   	pop    %ebp
  8025ff:	c3                   	ret    
  802600:	85 f6                	test   %esi,%esi
  802602:	89 f5                	mov    %esi,%ebp
  802604:	75 0b                	jne    802611 <__umoddi3+0x91>
  802606:	b8 01 00 00 00       	mov    $0x1,%eax
  80260b:	31 d2                	xor    %edx,%edx
  80260d:	f7 f6                	div    %esi
  80260f:	89 c5                	mov    %eax,%ebp
  802611:	8b 44 24 04          	mov    0x4(%esp),%eax
  802615:	31 d2                	xor    %edx,%edx
  802617:	f7 f5                	div    %ebp
  802619:	89 c8                	mov    %ecx,%eax
  80261b:	f7 f5                	div    %ebp
  80261d:	eb 9c                	jmp    8025bb <__umoddi3+0x3b>
  80261f:	90                   	nop
  802620:	89 c8                	mov    %ecx,%eax
  802622:	89 fa                	mov    %edi,%edx
  802624:	83 c4 14             	add    $0x14,%esp
  802627:	5e                   	pop    %esi
  802628:	5f                   	pop    %edi
  802629:	5d                   	pop    %ebp
  80262a:	c3                   	ret    
  80262b:	90                   	nop
  80262c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802630:	8b 04 24             	mov    (%esp),%eax
  802633:	be 20 00 00 00       	mov    $0x20,%esi
  802638:	89 e9                	mov    %ebp,%ecx
  80263a:	29 ee                	sub    %ebp,%esi
  80263c:	d3 e2                	shl    %cl,%edx
  80263e:	89 f1                	mov    %esi,%ecx
  802640:	d3 e8                	shr    %cl,%eax
  802642:	89 e9                	mov    %ebp,%ecx
  802644:	89 44 24 04          	mov    %eax,0x4(%esp)
  802648:	8b 04 24             	mov    (%esp),%eax
  80264b:	09 54 24 04          	or     %edx,0x4(%esp)
  80264f:	89 fa                	mov    %edi,%edx
  802651:	d3 e0                	shl    %cl,%eax
  802653:	89 f1                	mov    %esi,%ecx
  802655:	89 44 24 08          	mov    %eax,0x8(%esp)
  802659:	8b 44 24 10          	mov    0x10(%esp),%eax
  80265d:	d3 ea                	shr    %cl,%edx
  80265f:	89 e9                	mov    %ebp,%ecx
  802661:	d3 e7                	shl    %cl,%edi
  802663:	89 f1                	mov    %esi,%ecx
  802665:	d3 e8                	shr    %cl,%eax
  802667:	89 e9                	mov    %ebp,%ecx
  802669:	09 f8                	or     %edi,%eax
  80266b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80266f:	f7 74 24 04          	divl   0x4(%esp)
  802673:	d3 e7                	shl    %cl,%edi
  802675:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802679:	89 d7                	mov    %edx,%edi
  80267b:	f7 64 24 08          	mull   0x8(%esp)
  80267f:	39 d7                	cmp    %edx,%edi
  802681:	89 c1                	mov    %eax,%ecx
  802683:	89 14 24             	mov    %edx,(%esp)
  802686:	72 2c                	jb     8026b4 <__umoddi3+0x134>
  802688:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80268c:	72 22                	jb     8026b0 <__umoddi3+0x130>
  80268e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802692:	29 c8                	sub    %ecx,%eax
  802694:	19 d7                	sbb    %edx,%edi
  802696:	89 e9                	mov    %ebp,%ecx
  802698:	89 fa                	mov    %edi,%edx
  80269a:	d3 e8                	shr    %cl,%eax
  80269c:	89 f1                	mov    %esi,%ecx
  80269e:	d3 e2                	shl    %cl,%edx
  8026a0:	89 e9                	mov    %ebp,%ecx
  8026a2:	d3 ef                	shr    %cl,%edi
  8026a4:	09 d0                	or     %edx,%eax
  8026a6:	89 fa                	mov    %edi,%edx
  8026a8:	83 c4 14             	add    $0x14,%esp
  8026ab:	5e                   	pop    %esi
  8026ac:	5f                   	pop    %edi
  8026ad:	5d                   	pop    %ebp
  8026ae:	c3                   	ret    
  8026af:	90                   	nop
  8026b0:	39 d7                	cmp    %edx,%edi
  8026b2:	75 da                	jne    80268e <__umoddi3+0x10e>
  8026b4:	8b 14 24             	mov    (%esp),%edx
  8026b7:	89 c1                	mov    %eax,%ecx
  8026b9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8026bd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8026c1:	eb cb                	jmp    80268e <__umoddi3+0x10e>
  8026c3:	90                   	nop
  8026c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026c8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8026cc:	0f 82 0f ff ff ff    	jb     8025e1 <__umoddi3+0x61>
  8026d2:	e9 1a ff ff ff       	jmp    8025f1 <__umoddi3+0x71>
