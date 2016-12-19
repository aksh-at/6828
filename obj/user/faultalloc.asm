
obj/user/faultalloc.debug:     file format elf32-i386


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
  80002c:	e8 c3 00 00 00       	call   8000f4 <libmain>
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
  800043:	c7 04 24 00 27 80 00 	movl   $0x802700,(%esp)
  80004a:	e8 ff 01 00 00       	call   80024e <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800056:	00 
  800057:	89 d8                	mov    %ebx,%eax
  800059:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800062:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800069:	e8 25 0c 00 00       	call   800c93 <sys_page_alloc>
  80006e:	85 c0                	test   %eax,%eax
  800070:	79 24                	jns    800096 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800072:	89 44 24 10          	mov    %eax,0x10(%esp)
  800076:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007a:	c7 44 24 08 20 27 80 	movl   $0x802720,0x8(%esp)
  800081:	00 
  800082:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  800089:	00 
  80008a:	c7 04 24 0a 27 80 00 	movl   $0x80270a,(%esp)
  800091:	e8 bf 00 00 00       	call   800155 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800096:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009a:	c7 44 24 08 4c 27 80 	movl   $0x80274c,0x8(%esp)
  8000a1:	00 
  8000a2:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000a9:	00 
  8000aa:	89 1c 24             	mov    %ebx,(%esp)
  8000ad:	e8 58 07 00 00       	call   80080a <snprintf>
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
  8000c5:	e8 f6 0e 00 00       	call   800fc0 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000ca:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  8000d1:	de 
  8000d2:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  8000d9:	e8 70 01 00 00       	call   80024e <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000de:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  8000e5:	ca 
  8000e6:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  8000ed:	e8 5c 01 00 00       	call   80024e <cprintf>
}
  8000f2:	c9                   	leave  
  8000f3:	c3                   	ret    

008000f4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 10             	sub    $0x10,%esp
  8000fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ff:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  800102:	e8 4e 0b 00 00       	call   800c55 <sys_getenvid>
  800107:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800114:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800119:	85 db                	test   %ebx,%ebx
  80011b:	7e 07                	jle    800124 <libmain+0x30>
		binaryname = argv[0];
  80011d:	8b 06                	mov    (%esi),%eax
  80011f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800124:	89 74 24 04          	mov    %esi,0x4(%esp)
  800128:	89 1c 24             	mov    %ebx,(%esp)
  80012b:	e8 88 ff ff ff       	call   8000b8 <umain>

	// exit gracefully
	exit();
  800130:	e8 07 00 00 00       	call   80013c <exit>
}
  800135:	83 c4 10             	add    $0x10,%esp
  800138:	5b                   	pop    %ebx
  800139:	5e                   	pop    %esi
  80013a:	5d                   	pop    %ebp
  80013b:	c3                   	ret    

0080013c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800142:	e8 d3 10 00 00       	call   80121a <close_all>
	sys_env_destroy(0);
  800147:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80014e:	e8 b0 0a 00 00       	call   800c03 <sys_env_destroy>
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	56                   	push   %esi
  800159:	53                   	push   %ebx
  80015a:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80015d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800160:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800166:	e8 ea 0a 00 00       	call   800c55 <sys_getenvid>
  80016b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80016e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800172:	8b 55 08             	mov    0x8(%ebp),%edx
  800175:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800179:	89 74 24 08          	mov    %esi,0x8(%esp)
  80017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800181:	c7 04 24 78 27 80 00 	movl   $0x802778,(%esp)
  800188:	e8 c1 00 00 00       	call   80024e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80018d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800191:	8b 45 10             	mov    0x10(%ebp),%eax
  800194:	89 04 24             	mov    %eax,(%esp)
  800197:	e8 51 00 00 00       	call   8001ed <vcprintf>
	cprintf("\n");
  80019c:	c7 04 24 e0 2b 80 00 	movl   $0x802be0,(%esp)
  8001a3:	e8 a6 00 00 00       	call   80024e <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a8:	cc                   	int3   
  8001a9:	eb fd                	jmp    8001a8 <_panic+0x53>

008001ab <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 14             	sub    $0x14,%esp
  8001b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b5:	8b 13                	mov    (%ebx),%edx
  8001b7:	8d 42 01             	lea    0x1(%edx),%eax
  8001ba:	89 03                	mov    %eax,(%ebx)
  8001bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001bf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001c3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c8:	75 19                	jne    8001e3 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001ca:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001d1:	00 
  8001d2:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d5:	89 04 24             	mov    %eax,(%esp)
  8001d8:	e8 e9 09 00 00       	call   800bc6 <sys_cputs>
		b->idx = 0;
  8001dd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e7:	83 c4 14             	add    $0x14,%esp
  8001ea:	5b                   	pop    %ebx
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    

008001ed <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001fd:	00 00 00 
	b.cnt = 0;
  800200:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800207:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80020a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800211:	8b 45 08             	mov    0x8(%ebp),%eax
  800214:	89 44 24 08          	mov    %eax,0x8(%esp)
  800218:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800222:	c7 04 24 ab 01 80 00 	movl   $0x8001ab,(%esp)
  800229:	e8 b0 01 00 00       	call   8003de <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800234:	89 44 24 04          	mov    %eax,0x4(%esp)
  800238:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023e:	89 04 24             	mov    %eax,(%esp)
  800241:	e8 80 09 00 00       	call   800bc6 <sys_cputs>

	return b.cnt;
}
  800246:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024c:	c9                   	leave  
  80024d:	c3                   	ret    

0080024e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800254:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800257:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025b:	8b 45 08             	mov    0x8(%ebp),%eax
  80025e:	89 04 24             	mov    %eax,(%esp)
  800261:	e8 87 ff ff ff       	call   8001ed <vcprintf>
	va_end(ap);

	return cnt;
}
  800266:	c9                   	leave  
  800267:	c3                   	ret    
  800268:	66 90                	xchg   %ax,%ax
  80026a:	66 90                	xchg   %ax,%ax
  80026c:	66 90                	xchg   %ax,%ax
  80026e:	66 90                	xchg   %ax,%ax

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
  8002df:	e8 7c 21 00 00       	call   802460 <__udivdi3>
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
  80033f:	e8 4c 22 00 00       	call   802590 <__umoddi3>
  800344:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800348:	0f be 80 9b 27 80 00 	movsbl 0x80279b(%eax),%eax
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
  800463:	ff 24 8d e0 28 80 00 	jmp    *0x8028e0(,%ecx,4)
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
  800500:	8b 14 85 40 2a 80 00 	mov    0x802a40(,%eax,4),%edx
  800507:	85 d2                	test   %edx,%edx
  800509:	75 20                	jne    80052b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80050b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80050f:	c7 44 24 08 b3 27 80 	movl   $0x8027b3,0x8(%esp)
  800516:	00 
  800517:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80051b:	8b 45 08             	mov    0x8(%ebp),%eax
  80051e:	89 04 24             	mov    %eax,(%esp)
  800521:	e8 90 fe ff ff       	call   8003b6 <printfmt>
  800526:	e9 d8 fe ff ff       	jmp    800403 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80052b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80052f:	c7 44 24 08 75 2b 80 	movl   $0x802b75,0x8(%esp)
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
  800561:	b8 ac 27 80 00       	mov    $0x8027ac,%eax
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
  800c31:	c7 44 24 08 9f 2a 80 	movl   $0x802a9f,0x8(%esp)
  800c38:	00 
  800c39:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c40:	00 
  800c41:	c7 04 24 bc 2a 80 00 	movl   $0x802abc,(%esp)
  800c48:	e8 08 f5 ff ff       	call   800155 <_panic>

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
  800cc3:	c7 44 24 08 9f 2a 80 	movl   $0x802a9f,0x8(%esp)
  800cca:	00 
  800ccb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd2:	00 
  800cd3:	c7 04 24 bc 2a 80 00 	movl   $0x802abc,(%esp)
  800cda:	e8 76 f4 ff ff       	call   800155 <_panic>

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
  800d16:	c7 44 24 08 9f 2a 80 	movl   $0x802a9f,0x8(%esp)
  800d1d:	00 
  800d1e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d25:	00 
  800d26:	c7 04 24 bc 2a 80 00 	movl   $0x802abc,(%esp)
  800d2d:	e8 23 f4 ff ff       	call   800155 <_panic>

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
  800d69:	c7 44 24 08 9f 2a 80 	movl   $0x802a9f,0x8(%esp)
  800d70:	00 
  800d71:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d78:	00 
  800d79:	c7 04 24 bc 2a 80 00 	movl   $0x802abc,(%esp)
  800d80:	e8 d0 f3 ff ff       	call   800155 <_panic>

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
  800dbc:	c7 44 24 08 9f 2a 80 	movl   $0x802a9f,0x8(%esp)
  800dc3:	00 
  800dc4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dcb:	00 
  800dcc:	c7 04 24 bc 2a 80 00 	movl   $0x802abc,(%esp)
  800dd3:	e8 7d f3 ff ff       	call   800155 <_panic>

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
  800e0f:	c7 44 24 08 9f 2a 80 	movl   $0x802a9f,0x8(%esp)
  800e16:	00 
  800e17:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e1e:	00 
  800e1f:	c7 04 24 bc 2a 80 00 	movl   $0x802abc,(%esp)
  800e26:	e8 2a f3 ff ff       	call   800155 <_panic>

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
  800e62:	c7 44 24 08 9f 2a 80 	movl   $0x802a9f,0x8(%esp)
  800e69:	00 
  800e6a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e71:	00 
  800e72:	c7 04 24 bc 2a 80 00 	movl   $0x802abc,(%esp)
  800e79:	e8 d7 f2 ff ff       	call   800155 <_panic>

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
  800ed7:	c7 44 24 08 9f 2a 80 	movl   $0x802a9f,0x8(%esp)
  800ede:	00 
  800edf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee6:	00 
  800ee7:	c7 04 24 bc 2a 80 00 	movl   $0x802abc,(%esp)
  800eee:	e8 62 f2 ff ff       	call   800155 <_panic>

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
  800f49:	c7 44 24 08 9f 2a 80 	movl   $0x802a9f,0x8(%esp)
  800f50:	00 
  800f51:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f58:	00 
  800f59:	c7 04 24 bc 2a 80 00 	movl   $0x802abc,(%esp)
  800f60:	e8 f0 f1 ff ff       	call   800155 <_panic>

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
  800f9c:	c7 44 24 08 9f 2a 80 	movl   $0x802a9f,0x8(%esp)
  800fa3:	00 
  800fa4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fab:	00 
  800fac:	c7 04 24 bc 2a 80 00 	movl   $0x802abc,(%esp)
  800fb3:	e8 9d f1 ff ff       	call   800155 <_panic>

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

00800fc0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	53                   	push   %ebx
  800fc4:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  800fc7:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800fce:	75 2f                	jne    800fff <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  800fd0:	e8 80 fc ff ff       	call   800c55 <sys_getenvid>
  800fd5:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P);
  800fd7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fde:	00 
  800fdf:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800fe6:	ee 
  800fe7:	89 04 24             	mov    %eax,(%esp)
  800fea:	e8 a4 fc ff ff       	call   800c93 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *)_pgfault_upcall);
  800fef:	c7 44 24 04 0d 10 80 	movl   $0x80100d,0x4(%esp)
  800ff6:	00 
  800ff7:	89 1c 24             	mov    %ebx,(%esp)
  800ffa:	e8 34 fe ff ff       	call   800e33 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800fff:	8b 45 08             	mov    0x8(%ebp),%eax
  801002:	a3 0c 40 80 00       	mov    %eax,0x80400c
}
  801007:	83 c4 14             	add    $0x14,%esp
  80100a:	5b                   	pop    %ebx
  80100b:	5d                   	pop    %ebp
  80100c:	c3                   	ret    

0080100d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80100d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80100e:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  801013:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801015:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	// 0x30(%esp) points to trap-time stack pointer
	// 0x28(%esp) points to trap-time eip
	subl $4, 0x30(%esp)
  801018:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax 
  80101d:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebp
  801021:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %ebp, (%eax)
  801025:	89 28                	mov    %ebp,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801027:	83 c4 08             	add    $0x8,%esp
	popal
  80102a:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp //pop eip - we already stored it
  80102b:	83 c4 04             	add    $0x4,%esp
	popfl
  80102e:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80102f:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801030:	c3                   	ret    
  801031:	66 90                	xchg   %ax,%ax
  801033:	66 90                	xchg   %ax,%ax
  801035:	66 90                	xchg   %ax,%ax
  801037:	66 90                	xchg   %ax,%ax
  801039:	66 90                	xchg   %ax,%ax
  80103b:	66 90                	xchg   %ax,%ax
  80103d:	66 90                	xchg   %ax,%ax
  80103f:	90                   	nop

00801040 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801043:	8b 45 08             	mov    0x8(%ebp),%eax
  801046:	05 00 00 00 30       	add    $0x30000000,%eax
  80104b:	c1 e8 0c             	shr    $0xc,%eax
}
  80104e:	5d                   	pop    %ebp
  80104f:	c3                   	ret    

00801050 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801053:	8b 45 08             	mov    0x8(%ebp),%eax
  801056:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80105b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801060:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801065:	5d                   	pop    %ebp
  801066:	c3                   	ret    

00801067 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801067:	55                   	push   %ebp
  801068:	89 e5                	mov    %esp,%ebp
  80106a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80106d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801072:	89 c2                	mov    %eax,%edx
  801074:	c1 ea 16             	shr    $0x16,%edx
  801077:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80107e:	f6 c2 01             	test   $0x1,%dl
  801081:	74 11                	je     801094 <fd_alloc+0x2d>
  801083:	89 c2                	mov    %eax,%edx
  801085:	c1 ea 0c             	shr    $0xc,%edx
  801088:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80108f:	f6 c2 01             	test   $0x1,%dl
  801092:	75 09                	jne    80109d <fd_alloc+0x36>
			*fd_store = fd;
  801094:	89 01                	mov    %eax,(%ecx)
			return 0;
  801096:	b8 00 00 00 00       	mov    $0x0,%eax
  80109b:	eb 17                	jmp    8010b4 <fd_alloc+0x4d>
  80109d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010a2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010a7:	75 c9                	jne    801072 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010a9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010af:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010b4:	5d                   	pop    %ebp
  8010b5:	c3                   	ret    

008010b6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010b6:	55                   	push   %ebp
  8010b7:	89 e5                	mov    %esp,%ebp
  8010b9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010bc:	83 f8 1f             	cmp    $0x1f,%eax
  8010bf:	77 36                	ja     8010f7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010c1:	c1 e0 0c             	shl    $0xc,%eax
  8010c4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010c9:	89 c2                	mov    %eax,%edx
  8010cb:	c1 ea 16             	shr    $0x16,%edx
  8010ce:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010d5:	f6 c2 01             	test   $0x1,%dl
  8010d8:	74 24                	je     8010fe <fd_lookup+0x48>
  8010da:	89 c2                	mov    %eax,%edx
  8010dc:	c1 ea 0c             	shr    $0xc,%edx
  8010df:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010e6:	f6 c2 01             	test   $0x1,%dl
  8010e9:	74 1a                	je     801105 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ee:	89 02                	mov    %eax,(%edx)
	return 0;
  8010f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f5:	eb 13                	jmp    80110a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010fc:	eb 0c                	jmp    80110a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801103:	eb 05                	jmp    80110a <fd_lookup+0x54>
  801105:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80110a:	5d                   	pop    %ebp
  80110b:	c3                   	ret    

0080110c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
  80110f:	83 ec 18             	sub    $0x18,%esp
  801112:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801115:	ba 00 00 00 00       	mov    $0x0,%edx
  80111a:	eb 13                	jmp    80112f <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  80111c:	39 08                	cmp    %ecx,(%eax)
  80111e:	75 0c                	jne    80112c <dev_lookup+0x20>
			*dev = devtab[i];
  801120:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801123:	89 01                	mov    %eax,(%ecx)
			return 0;
  801125:	b8 00 00 00 00       	mov    $0x0,%eax
  80112a:	eb 38                	jmp    801164 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80112c:	83 c2 01             	add    $0x1,%edx
  80112f:	8b 04 95 48 2b 80 00 	mov    0x802b48(,%edx,4),%eax
  801136:	85 c0                	test   %eax,%eax
  801138:	75 e2                	jne    80111c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80113a:	a1 08 40 80 00       	mov    0x804008,%eax
  80113f:	8b 40 48             	mov    0x48(%eax),%eax
  801142:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801146:	89 44 24 04          	mov    %eax,0x4(%esp)
  80114a:	c7 04 24 cc 2a 80 00 	movl   $0x802acc,(%esp)
  801151:	e8 f8 f0 ff ff       	call   80024e <cprintf>
	*dev = 0;
  801156:	8b 45 0c             	mov    0xc(%ebp),%eax
  801159:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80115f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801164:	c9                   	leave  
  801165:	c3                   	ret    

00801166 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	56                   	push   %esi
  80116a:	53                   	push   %ebx
  80116b:	83 ec 20             	sub    $0x20,%esp
  80116e:	8b 75 08             	mov    0x8(%ebp),%esi
  801171:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801174:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801177:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80117b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801181:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801184:	89 04 24             	mov    %eax,(%esp)
  801187:	e8 2a ff ff ff       	call   8010b6 <fd_lookup>
  80118c:	85 c0                	test   %eax,%eax
  80118e:	78 05                	js     801195 <fd_close+0x2f>
	    || fd != fd2)
  801190:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801193:	74 0c                	je     8011a1 <fd_close+0x3b>
		return (must_exist ? r : 0);
  801195:	84 db                	test   %bl,%bl
  801197:	ba 00 00 00 00       	mov    $0x0,%edx
  80119c:	0f 44 c2             	cmove  %edx,%eax
  80119f:	eb 3f                	jmp    8011e0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a8:	8b 06                	mov    (%esi),%eax
  8011aa:	89 04 24             	mov    %eax,(%esp)
  8011ad:	e8 5a ff ff ff       	call   80110c <dev_lookup>
  8011b2:	89 c3                	mov    %eax,%ebx
  8011b4:	85 c0                	test   %eax,%eax
  8011b6:	78 16                	js     8011ce <fd_close+0x68>
		if (dev->dev_close)
  8011b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011bb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011be:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	74 07                	je     8011ce <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8011c7:	89 34 24             	mov    %esi,(%esp)
  8011ca:	ff d0                	call   *%eax
  8011cc:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011d9:	e8 5c fb ff ff       	call   800d3a <sys_page_unmap>
	return r;
  8011de:	89 d8                	mov    %ebx,%eax
}
  8011e0:	83 c4 20             	add    $0x20,%esp
  8011e3:	5b                   	pop    %ebx
  8011e4:	5e                   	pop    %esi
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
  8011ea:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f7:	89 04 24             	mov    %eax,(%esp)
  8011fa:	e8 b7 fe ff ff       	call   8010b6 <fd_lookup>
  8011ff:	89 c2                	mov    %eax,%edx
  801201:	85 d2                	test   %edx,%edx
  801203:	78 13                	js     801218 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801205:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80120c:	00 
  80120d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801210:	89 04 24             	mov    %eax,(%esp)
  801213:	e8 4e ff ff ff       	call   801166 <fd_close>
}
  801218:	c9                   	leave  
  801219:	c3                   	ret    

0080121a <close_all>:

void
close_all(void)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	53                   	push   %ebx
  80121e:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801221:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801226:	89 1c 24             	mov    %ebx,(%esp)
  801229:	e8 b9 ff ff ff       	call   8011e7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80122e:	83 c3 01             	add    $0x1,%ebx
  801231:	83 fb 20             	cmp    $0x20,%ebx
  801234:	75 f0                	jne    801226 <close_all+0xc>
		close(i);
}
  801236:	83 c4 14             	add    $0x14,%esp
  801239:	5b                   	pop    %ebx
  80123a:	5d                   	pop    %ebp
  80123b:	c3                   	ret    

0080123c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
  80123f:	57                   	push   %edi
  801240:	56                   	push   %esi
  801241:	53                   	push   %ebx
  801242:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801245:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801248:	89 44 24 04          	mov    %eax,0x4(%esp)
  80124c:	8b 45 08             	mov    0x8(%ebp),%eax
  80124f:	89 04 24             	mov    %eax,(%esp)
  801252:	e8 5f fe ff ff       	call   8010b6 <fd_lookup>
  801257:	89 c2                	mov    %eax,%edx
  801259:	85 d2                	test   %edx,%edx
  80125b:	0f 88 e1 00 00 00    	js     801342 <dup+0x106>
		return r;
	close(newfdnum);
  801261:	8b 45 0c             	mov    0xc(%ebp),%eax
  801264:	89 04 24             	mov    %eax,(%esp)
  801267:	e8 7b ff ff ff       	call   8011e7 <close>

	newfd = INDEX2FD(newfdnum);
  80126c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80126f:	c1 e3 0c             	shl    $0xc,%ebx
  801272:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801278:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80127b:	89 04 24             	mov    %eax,(%esp)
  80127e:	e8 cd fd ff ff       	call   801050 <fd2data>
  801283:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801285:	89 1c 24             	mov    %ebx,(%esp)
  801288:	e8 c3 fd ff ff       	call   801050 <fd2data>
  80128d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80128f:	89 f0                	mov    %esi,%eax
  801291:	c1 e8 16             	shr    $0x16,%eax
  801294:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80129b:	a8 01                	test   $0x1,%al
  80129d:	74 43                	je     8012e2 <dup+0xa6>
  80129f:	89 f0                	mov    %esi,%eax
  8012a1:	c1 e8 0c             	shr    $0xc,%eax
  8012a4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012ab:	f6 c2 01             	test   $0x1,%dl
  8012ae:	74 32                	je     8012e2 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012b0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012b7:	25 07 0e 00 00       	and    $0xe07,%eax
  8012bc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012c0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012cb:	00 
  8012cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012d7:	e8 0b fa ff ff       	call   800ce7 <sys_page_map>
  8012dc:	89 c6                	mov    %eax,%esi
  8012de:	85 c0                	test   %eax,%eax
  8012e0:	78 3e                	js     801320 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012e5:	89 c2                	mov    %eax,%edx
  8012e7:	c1 ea 0c             	shr    $0xc,%edx
  8012ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012f1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8012f7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012ff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801306:	00 
  801307:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801312:	e8 d0 f9 ff ff       	call   800ce7 <sys_page_map>
  801317:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801319:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80131c:	85 f6                	test   %esi,%esi
  80131e:	79 22                	jns    801342 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801320:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801324:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80132b:	e8 0a fa ff ff       	call   800d3a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801330:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801334:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80133b:	e8 fa f9 ff ff       	call   800d3a <sys_page_unmap>
	return r;
  801340:	89 f0                	mov    %esi,%eax
}
  801342:	83 c4 3c             	add    $0x3c,%esp
  801345:	5b                   	pop    %ebx
  801346:	5e                   	pop    %esi
  801347:	5f                   	pop    %edi
  801348:	5d                   	pop    %ebp
  801349:	c3                   	ret    

0080134a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
  80134d:	53                   	push   %ebx
  80134e:	83 ec 24             	sub    $0x24,%esp
  801351:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801354:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801357:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135b:	89 1c 24             	mov    %ebx,(%esp)
  80135e:	e8 53 fd ff ff       	call   8010b6 <fd_lookup>
  801363:	89 c2                	mov    %eax,%edx
  801365:	85 d2                	test   %edx,%edx
  801367:	78 6d                	js     8013d6 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801369:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801370:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801373:	8b 00                	mov    (%eax),%eax
  801375:	89 04 24             	mov    %eax,(%esp)
  801378:	e8 8f fd ff ff       	call   80110c <dev_lookup>
  80137d:	85 c0                	test   %eax,%eax
  80137f:	78 55                	js     8013d6 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801381:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801384:	8b 50 08             	mov    0x8(%eax),%edx
  801387:	83 e2 03             	and    $0x3,%edx
  80138a:	83 fa 01             	cmp    $0x1,%edx
  80138d:	75 23                	jne    8013b2 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80138f:	a1 08 40 80 00       	mov    0x804008,%eax
  801394:	8b 40 48             	mov    0x48(%eax),%eax
  801397:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80139b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139f:	c7 04 24 0d 2b 80 00 	movl   $0x802b0d,(%esp)
  8013a6:	e8 a3 ee ff ff       	call   80024e <cprintf>
		return -E_INVAL;
  8013ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013b0:	eb 24                	jmp    8013d6 <read+0x8c>
	}
	if (!dev->dev_read)
  8013b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013b5:	8b 52 08             	mov    0x8(%edx),%edx
  8013b8:	85 d2                	test   %edx,%edx
  8013ba:	74 15                	je     8013d1 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013bf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013c6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013ca:	89 04 24             	mov    %eax,(%esp)
  8013cd:	ff d2                	call   *%edx
  8013cf:	eb 05                	jmp    8013d6 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013d1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8013d6:	83 c4 24             	add    $0x24,%esp
  8013d9:	5b                   	pop    %ebx
  8013da:	5d                   	pop    %ebp
  8013db:	c3                   	ret    

008013dc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	57                   	push   %edi
  8013e0:	56                   	push   %esi
  8013e1:	53                   	push   %ebx
  8013e2:	83 ec 1c             	sub    $0x1c,%esp
  8013e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013e8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013f0:	eb 23                	jmp    801415 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013f2:	89 f0                	mov    %esi,%eax
  8013f4:	29 d8                	sub    %ebx,%eax
  8013f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013fa:	89 d8                	mov    %ebx,%eax
  8013fc:	03 45 0c             	add    0xc(%ebp),%eax
  8013ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801403:	89 3c 24             	mov    %edi,(%esp)
  801406:	e8 3f ff ff ff       	call   80134a <read>
		if (m < 0)
  80140b:	85 c0                	test   %eax,%eax
  80140d:	78 10                	js     80141f <readn+0x43>
			return m;
		if (m == 0)
  80140f:	85 c0                	test   %eax,%eax
  801411:	74 0a                	je     80141d <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801413:	01 c3                	add    %eax,%ebx
  801415:	39 f3                	cmp    %esi,%ebx
  801417:	72 d9                	jb     8013f2 <readn+0x16>
  801419:	89 d8                	mov    %ebx,%eax
  80141b:	eb 02                	jmp    80141f <readn+0x43>
  80141d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80141f:	83 c4 1c             	add    $0x1c,%esp
  801422:	5b                   	pop    %ebx
  801423:	5e                   	pop    %esi
  801424:	5f                   	pop    %edi
  801425:	5d                   	pop    %ebp
  801426:	c3                   	ret    

00801427 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	53                   	push   %ebx
  80142b:	83 ec 24             	sub    $0x24,%esp
  80142e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801431:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801434:	89 44 24 04          	mov    %eax,0x4(%esp)
  801438:	89 1c 24             	mov    %ebx,(%esp)
  80143b:	e8 76 fc ff ff       	call   8010b6 <fd_lookup>
  801440:	89 c2                	mov    %eax,%edx
  801442:	85 d2                	test   %edx,%edx
  801444:	78 68                	js     8014ae <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801446:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801449:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801450:	8b 00                	mov    (%eax),%eax
  801452:	89 04 24             	mov    %eax,(%esp)
  801455:	e8 b2 fc ff ff       	call   80110c <dev_lookup>
  80145a:	85 c0                	test   %eax,%eax
  80145c:	78 50                	js     8014ae <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80145e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801461:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801465:	75 23                	jne    80148a <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801467:	a1 08 40 80 00       	mov    0x804008,%eax
  80146c:	8b 40 48             	mov    0x48(%eax),%eax
  80146f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801473:	89 44 24 04          	mov    %eax,0x4(%esp)
  801477:	c7 04 24 29 2b 80 00 	movl   $0x802b29,(%esp)
  80147e:	e8 cb ed ff ff       	call   80024e <cprintf>
		return -E_INVAL;
  801483:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801488:	eb 24                	jmp    8014ae <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80148a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80148d:	8b 52 0c             	mov    0xc(%edx),%edx
  801490:	85 d2                	test   %edx,%edx
  801492:	74 15                	je     8014a9 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801494:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801497:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80149b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80149e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014a2:	89 04 24             	mov    %eax,(%esp)
  8014a5:	ff d2                	call   *%edx
  8014a7:	eb 05                	jmp    8014ae <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014a9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8014ae:	83 c4 24             	add    $0x24,%esp
  8014b1:	5b                   	pop    %ebx
  8014b2:	5d                   	pop    %ebp
  8014b3:	c3                   	ret    

008014b4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014b4:	55                   	push   %ebp
  8014b5:	89 e5                	mov    %esp,%ebp
  8014b7:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014ba:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c4:	89 04 24             	mov    %eax,(%esp)
  8014c7:	e8 ea fb ff ff       	call   8010b6 <fd_lookup>
  8014cc:	85 c0                	test   %eax,%eax
  8014ce:	78 0e                	js     8014de <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8014d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014d6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014de:	c9                   	leave  
  8014df:	c3                   	ret    

008014e0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	53                   	push   %ebx
  8014e4:	83 ec 24             	sub    $0x24,%esp
  8014e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f1:	89 1c 24             	mov    %ebx,(%esp)
  8014f4:	e8 bd fb ff ff       	call   8010b6 <fd_lookup>
  8014f9:	89 c2                	mov    %eax,%edx
  8014fb:	85 d2                	test   %edx,%edx
  8014fd:	78 61                	js     801560 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801502:	89 44 24 04          	mov    %eax,0x4(%esp)
  801506:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801509:	8b 00                	mov    (%eax),%eax
  80150b:	89 04 24             	mov    %eax,(%esp)
  80150e:	e8 f9 fb ff ff       	call   80110c <dev_lookup>
  801513:	85 c0                	test   %eax,%eax
  801515:	78 49                	js     801560 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801517:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80151e:	75 23                	jne    801543 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801520:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801525:	8b 40 48             	mov    0x48(%eax),%eax
  801528:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80152c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801530:	c7 04 24 ec 2a 80 00 	movl   $0x802aec,(%esp)
  801537:	e8 12 ed ff ff       	call   80024e <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80153c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801541:	eb 1d                	jmp    801560 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801543:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801546:	8b 52 18             	mov    0x18(%edx),%edx
  801549:	85 d2                	test   %edx,%edx
  80154b:	74 0e                	je     80155b <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80154d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801550:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801554:	89 04 24             	mov    %eax,(%esp)
  801557:	ff d2                	call   *%edx
  801559:	eb 05                	jmp    801560 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80155b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801560:	83 c4 24             	add    $0x24,%esp
  801563:	5b                   	pop    %ebx
  801564:	5d                   	pop    %ebp
  801565:	c3                   	ret    

00801566 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801566:	55                   	push   %ebp
  801567:	89 e5                	mov    %esp,%ebp
  801569:	53                   	push   %ebx
  80156a:	83 ec 24             	sub    $0x24,%esp
  80156d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801570:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801573:	89 44 24 04          	mov    %eax,0x4(%esp)
  801577:	8b 45 08             	mov    0x8(%ebp),%eax
  80157a:	89 04 24             	mov    %eax,(%esp)
  80157d:	e8 34 fb ff ff       	call   8010b6 <fd_lookup>
  801582:	89 c2                	mov    %eax,%edx
  801584:	85 d2                	test   %edx,%edx
  801586:	78 52                	js     8015da <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801588:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801592:	8b 00                	mov    (%eax),%eax
  801594:	89 04 24             	mov    %eax,(%esp)
  801597:	e8 70 fb ff ff       	call   80110c <dev_lookup>
  80159c:	85 c0                	test   %eax,%eax
  80159e:	78 3a                	js     8015da <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8015a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015a7:	74 2c                	je     8015d5 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015a9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015ac:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015b3:	00 00 00 
	stat->st_isdir = 0;
  8015b6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015bd:	00 00 00 
	stat->st_dev = dev;
  8015c0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015ca:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015cd:	89 14 24             	mov    %edx,(%esp)
  8015d0:	ff 50 14             	call   *0x14(%eax)
  8015d3:	eb 05                	jmp    8015da <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015d5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015da:	83 c4 24             	add    $0x24,%esp
  8015dd:	5b                   	pop    %ebx
  8015de:	5d                   	pop    %ebp
  8015df:	c3                   	ret    

008015e0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015e0:	55                   	push   %ebp
  8015e1:	89 e5                	mov    %esp,%ebp
  8015e3:	56                   	push   %esi
  8015e4:	53                   	push   %ebx
  8015e5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015e8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015ef:	00 
  8015f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f3:	89 04 24             	mov    %eax,(%esp)
  8015f6:	e8 28 02 00 00       	call   801823 <open>
  8015fb:	89 c3                	mov    %eax,%ebx
  8015fd:	85 db                	test   %ebx,%ebx
  8015ff:	78 1b                	js     80161c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801601:	8b 45 0c             	mov    0xc(%ebp),%eax
  801604:	89 44 24 04          	mov    %eax,0x4(%esp)
  801608:	89 1c 24             	mov    %ebx,(%esp)
  80160b:	e8 56 ff ff ff       	call   801566 <fstat>
  801610:	89 c6                	mov    %eax,%esi
	close(fd);
  801612:	89 1c 24             	mov    %ebx,(%esp)
  801615:	e8 cd fb ff ff       	call   8011e7 <close>
	return r;
  80161a:	89 f0                	mov    %esi,%eax
}
  80161c:	83 c4 10             	add    $0x10,%esp
  80161f:	5b                   	pop    %ebx
  801620:	5e                   	pop    %esi
  801621:	5d                   	pop    %ebp
  801622:	c3                   	ret    

00801623 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801623:	55                   	push   %ebp
  801624:	89 e5                	mov    %esp,%ebp
  801626:	56                   	push   %esi
  801627:	53                   	push   %ebx
  801628:	83 ec 10             	sub    $0x10,%esp
  80162b:	89 c6                	mov    %eax,%esi
  80162d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80162f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801636:	75 11                	jne    801649 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801638:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80163f:	e8 a1 0d 00 00       	call   8023e5 <ipc_find_env>
  801644:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801649:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801650:	00 
  801651:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801658:	00 
  801659:	89 74 24 04          	mov    %esi,0x4(%esp)
  80165d:	a1 00 40 80 00       	mov    0x804000,%eax
  801662:	89 04 24             	mov    %eax,(%esp)
  801665:	e8 10 0d 00 00       	call   80237a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80166a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801671:	00 
  801672:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801676:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80167d:	e8 7e 0c 00 00       	call   802300 <ipc_recv>
}
  801682:	83 c4 10             	add    $0x10,%esp
  801685:	5b                   	pop    %ebx
  801686:	5e                   	pop    %esi
  801687:	5d                   	pop    %ebp
  801688:	c3                   	ret    

00801689 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801689:	55                   	push   %ebp
  80168a:	89 e5                	mov    %esp,%ebp
  80168c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80168f:	8b 45 08             	mov    0x8(%ebp),%eax
  801692:	8b 40 0c             	mov    0xc(%eax),%eax
  801695:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80169a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80169d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a7:	b8 02 00 00 00       	mov    $0x2,%eax
  8016ac:	e8 72 ff ff ff       	call   801623 <fsipc>
}
  8016b1:	c9                   	leave  
  8016b2:	c3                   	ret    

008016b3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016b3:	55                   	push   %ebp
  8016b4:	89 e5                	mov    %esp,%ebp
  8016b6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8016bf:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c9:	b8 06 00 00 00       	mov    $0x6,%eax
  8016ce:	e8 50 ff ff ff       	call   801623 <fsipc>
}
  8016d3:	c9                   	leave  
  8016d4:	c3                   	ret    

008016d5 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	53                   	push   %ebx
  8016d9:	83 ec 14             	sub    $0x14,%esp
  8016dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016df:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ef:	b8 05 00 00 00       	mov    $0x5,%eax
  8016f4:	e8 2a ff ff ff       	call   801623 <fsipc>
  8016f9:	89 c2                	mov    %eax,%edx
  8016fb:	85 d2                	test   %edx,%edx
  8016fd:	78 2b                	js     80172a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016ff:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801706:	00 
  801707:	89 1c 24             	mov    %ebx,(%esp)
  80170a:	e8 68 f1 ff ff       	call   800877 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80170f:	a1 80 50 80 00       	mov    0x805080,%eax
  801714:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80171a:	a1 84 50 80 00       	mov    0x805084,%eax
  80171f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801725:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80172a:	83 c4 14             	add    $0x14,%esp
  80172d:	5b                   	pop    %ebx
  80172e:	5d                   	pop    %ebp
  80172f:	c3                   	ret    

00801730 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	83 ec 18             	sub    $0x18,%esp
  801736:	8b 45 10             	mov    0x10(%ebp),%eax
  801739:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80173e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801743:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801746:	8b 55 08             	mov    0x8(%ebp),%edx
  801749:	8b 52 0c             	mov    0xc(%edx),%edx
  80174c:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801752:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801757:	89 44 24 08          	mov    %eax,0x8(%esp)
  80175b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80175e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801762:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801769:	e8 a6 f2 ff ff       	call   800a14 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  80176e:	ba 00 00 00 00       	mov    $0x0,%edx
  801773:	b8 04 00 00 00       	mov    $0x4,%eax
  801778:	e8 a6 fe ff ff       	call   801623 <fsipc>
}
  80177d:	c9                   	leave  
  80177e:	c3                   	ret    

0080177f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80177f:	55                   	push   %ebp
  801780:	89 e5                	mov    %esp,%ebp
  801782:	56                   	push   %esi
  801783:	53                   	push   %ebx
  801784:	83 ec 10             	sub    $0x10,%esp
  801787:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80178a:	8b 45 08             	mov    0x8(%ebp),%eax
  80178d:	8b 40 0c             	mov    0xc(%eax),%eax
  801790:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801795:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80179b:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a0:	b8 03 00 00 00       	mov    $0x3,%eax
  8017a5:	e8 79 fe ff ff       	call   801623 <fsipc>
  8017aa:	89 c3                	mov    %eax,%ebx
  8017ac:	85 c0                	test   %eax,%eax
  8017ae:	78 6a                	js     80181a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8017b0:	39 c6                	cmp    %eax,%esi
  8017b2:	73 24                	jae    8017d8 <devfile_read+0x59>
  8017b4:	c7 44 24 0c 5c 2b 80 	movl   $0x802b5c,0xc(%esp)
  8017bb:	00 
  8017bc:	c7 44 24 08 63 2b 80 	movl   $0x802b63,0x8(%esp)
  8017c3:	00 
  8017c4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8017cb:	00 
  8017cc:	c7 04 24 78 2b 80 00 	movl   $0x802b78,(%esp)
  8017d3:	e8 7d e9 ff ff       	call   800155 <_panic>
	assert(r <= PGSIZE);
  8017d8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017dd:	7e 24                	jle    801803 <devfile_read+0x84>
  8017df:	c7 44 24 0c 83 2b 80 	movl   $0x802b83,0xc(%esp)
  8017e6:	00 
  8017e7:	c7 44 24 08 63 2b 80 	movl   $0x802b63,0x8(%esp)
  8017ee:	00 
  8017ef:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8017f6:	00 
  8017f7:	c7 04 24 78 2b 80 00 	movl   $0x802b78,(%esp)
  8017fe:	e8 52 e9 ff ff       	call   800155 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801803:	89 44 24 08          	mov    %eax,0x8(%esp)
  801807:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80180e:	00 
  80180f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801812:	89 04 24             	mov    %eax,(%esp)
  801815:	e8 fa f1 ff ff       	call   800a14 <memmove>
	return r;
}
  80181a:	89 d8                	mov    %ebx,%eax
  80181c:	83 c4 10             	add    $0x10,%esp
  80181f:	5b                   	pop    %ebx
  801820:	5e                   	pop    %esi
  801821:	5d                   	pop    %ebp
  801822:	c3                   	ret    

00801823 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	53                   	push   %ebx
  801827:	83 ec 24             	sub    $0x24,%esp
  80182a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80182d:	89 1c 24             	mov    %ebx,(%esp)
  801830:	e8 0b f0 ff ff       	call   800840 <strlen>
  801835:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80183a:	7f 60                	jg     80189c <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80183c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80183f:	89 04 24             	mov    %eax,(%esp)
  801842:	e8 20 f8 ff ff       	call   801067 <fd_alloc>
  801847:	89 c2                	mov    %eax,%edx
  801849:	85 d2                	test   %edx,%edx
  80184b:	78 54                	js     8018a1 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80184d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801851:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801858:	e8 1a f0 ff ff       	call   800877 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80185d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801860:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801865:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801868:	b8 01 00 00 00       	mov    $0x1,%eax
  80186d:	e8 b1 fd ff ff       	call   801623 <fsipc>
  801872:	89 c3                	mov    %eax,%ebx
  801874:	85 c0                	test   %eax,%eax
  801876:	79 17                	jns    80188f <open+0x6c>
		fd_close(fd, 0);
  801878:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80187f:	00 
  801880:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801883:	89 04 24             	mov    %eax,(%esp)
  801886:	e8 db f8 ff ff       	call   801166 <fd_close>
		return r;
  80188b:	89 d8                	mov    %ebx,%eax
  80188d:	eb 12                	jmp    8018a1 <open+0x7e>
	}

	return fd2num(fd);
  80188f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801892:	89 04 24             	mov    %eax,(%esp)
  801895:	e8 a6 f7 ff ff       	call   801040 <fd2num>
  80189a:	eb 05                	jmp    8018a1 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80189c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018a1:	83 c4 24             	add    $0x24,%esp
  8018a4:	5b                   	pop    %ebx
  8018a5:	5d                   	pop    %ebp
  8018a6:	c3                   	ret    

008018a7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b2:	b8 08 00 00 00       	mov    $0x8,%eax
  8018b7:	e8 67 fd ff ff       	call   801623 <fsipc>
}
  8018bc:	c9                   	leave  
  8018bd:	c3                   	ret    
  8018be:	66 90                	xchg   %ax,%ax

008018c0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  8018c6:	c7 44 24 04 8f 2b 80 	movl   $0x802b8f,0x4(%esp)
  8018cd:	00 
  8018ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d1:	89 04 24             	mov    %eax,(%esp)
  8018d4:	e8 9e ef ff ff       	call   800877 <strcpy>
	return 0;
}
  8018d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8018de:	c9                   	leave  
  8018df:	c3                   	ret    

008018e0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	53                   	push   %ebx
  8018e4:	83 ec 14             	sub    $0x14,%esp
  8018e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8018ea:	89 1c 24             	mov    %ebx,(%esp)
  8018ed:	e8 2b 0b 00 00       	call   80241d <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8018f2:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8018f7:	83 f8 01             	cmp    $0x1,%eax
  8018fa:	75 0d                	jne    801909 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  8018fc:	8b 43 0c             	mov    0xc(%ebx),%eax
  8018ff:	89 04 24             	mov    %eax,(%esp)
  801902:	e8 29 03 00 00       	call   801c30 <nsipc_close>
  801907:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  801909:	89 d0                	mov    %edx,%eax
  80190b:	83 c4 14             	add    $0x14,%esp
  80190e:	5b                   	pop    %ebx
  80190f:	5d                   	pop    %ebp
  801910:	c3                   	ret    

00801911 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801917:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80191e:	00 
  80191f:	8b 45 10             	mov    0x10(%ebp),%eax
  801922:	89 44 24 08          	mov    %eax,0x8(%esp)
  801926:	8b 45 0c             	mov    0xc(%ebp),%eax
  801929:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192d:	8b 45 08             	mov    0x8(%ebp),%eax
  801930:	8b 40 0c             	mov    0xc(%eax),%eax
  801933:	89 04 24             	mov    %eax,(%esp)
  801936:	e8 f0 03 00 00       	call   801d2b <nsipc_send>
}
  80193b:	c9                   	leave  
  80193c:	c3                   	ret    

0080193d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80193d:	55                   	push   %ebp
  80193e:	89 e5                	mov    %esp,%ebp
  801940:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801943:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80194a:	00 
  80194b:	8b 45 10             	mov    0x10(%ebp),%eax
  80194e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801952:	8b 45 0c             	mov    0xc(%ebp),%eax
  801955:	89 44 24 04          	mov    %eax,0x4(%esp)
  801959:	8b 45 08             	mov    0x8(%ebp),%eax
  80195c:	8b 40 0c             	mov    0xc(%eax),%eax
  80195f:	89 04 24             	mov    %eax,(%esp)
  801962:	e8 44 03 00 00       	call   801cab <nsipc_recv>
}
  801967:	c9                   	leave  
  801968:	c3                   	ret    

00801969 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801969:	55                   	push   %ebp
  80196a:	89 e5                	mov    %esp,%ebp
  80196c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80196f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801972:	89 54 24 04          	mov    %edx,0x4(%esp)
  801976:	89 04 24             	mov    %eax,(%esp)
  801979:	e8 38 f7 ff ff       	call   8010b6 <fd_lookup>
  80197e:	85 c0                	test   %eax,%eax
  801980:	78 17                	js     801999 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801982:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801985:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80198b:	39 08                	cmp    %ecx,(%eax)
  80198d:	75 05                	jne    801994 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80198f:	8b 40 0c             	mov    0xc(%eax),%eax
  801992:	eb 05                	jmp    801999 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801994:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801999:	c9                   	leave  
  80199a:	c3                   	ret    

0080199b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80199b:	55                   	push   %ebp
  80199c:	89 e5                	mov    %esp,%ebp
  80199e:	56                   	push   %esi
  80199f:	53                   	push   %ebx
  8019a0:	83 ec 20             	sub    $0x20,%esp
  8019a3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8019a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a8:	89 04 24             	mov    %eax,(%esp)
  8019ab:	e8 b7 f6 ff ff       	call   801067 <fd_alloc>
  8019b0:	89 c3                	mov    %eax,%ebx
  8019b2:	85 c0                	test   %eax,%eax
  8019b4:	78 21                	js     8019d7 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8019b6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8019bd:	00 
  8019be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019cc:	e8 c2 f2 ff ff       	call   800c93 <sys_page_alloc>
  8019d1:	89 c3                	mov    %eax,%ebx
  8019d3:	85 c0                	test   %eax,%eax
  8019d5:	79 0c                	jns    8019e3 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  8019d7:	89 34 24             	mov    %esi,(%esp)
  8019da:	e8 51 02 00 00       	call   801c30 <nsipc_close>
		return r;
  8019df:	89 d8                	mov    %ebx,%eax
  8019e1:	eb 20                	jmp    801a03 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8019e3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ec:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8019ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019f1:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  8019f8:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  8019fb:	89 14 24             	mov    %edx,(%esp)
  8019fe:	e8 3d f6 ff ff       	call   801040 <fd2num>
}
  801a03:	83 c4 20             	add    $0x20,%esp
  801a06:	5b                   	pop    %ebx
  801a07:	5e                   	pop    %esi
  801a08:	5d                   	pop    %ebp
  801a09:	c3                   	ret    

00801a0a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a10:	8b 45 08             	mov    0x8(%ebp),%eax
  801a13:	e8 51 ff ff ff       	call   801969 <fd2sockid>
		return r;
  801a18:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	78 23                	js     801a41 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a1e:	8b 55 10             	mov    0x10(%ebp),%edx
  801a21:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a25:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a28:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a2c:	89 04 24             	mov    %eax,(%esp)
  801a2f:	e8 45 01 00 00       	call   801b79 <nsipc_accept>
		return r;
  801a34:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a36:	85 c0                	test   %eax,%eax
  801a38:	78 07                	js     801a41 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  801a3a:	e8 5c ff ff ff       	call   80199b <alloc_sockfd>
  801a3f:	89 c1                	mov    %eax,%ecx
}
  801a41:	89 c8                	mov    %ecx,%eax
  801a43:	c9                   	leave  
  801a44:	c3                   	ret    

00801a45 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4e:	e8 16 ff ff ff       	call   801969 <fd2sockid>
  801a53:	89 c2                	mov    %eax,%edx
  801a55:	85 d2                	test   %edx,%edx
  801a57:	78 16                	js     801a6f <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  801a59:	8b 45 10             	mov    0x10(%ebp),%eax
  801a5c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a63:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a67:	89 14 24             	mov    %edx,(%esp)
  801a6a:	e8 60 01 00 00       	call   801bcf <nsipc_bind>
}
  801a6f:	c9                   	leave  
  801a70:	c3                   	ret    

00801a71 <shutdown>:

int
shutdown(int s, int how)
{
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a77:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7a:	e8 ea fe ff ff       	call   801969 <fd2sockid>
  801a7f:	89 c2                	mov    %eax,%edx
  801a81:	85 d2                	test   %edx,%edx
  801a83:	78 0f                	js     801a94 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801a85:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a88:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8c:	89 14 24             	mov    %edx,(%esp)
  801a8f:	e8 7a 01 00 00       	call   801c0e <nsipc_shutdown>
}
  801a94:	c9                   	leave  
  801a95:	c3                   	ret    

00801a96 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a96:	55                   	push   %ebp
  801a97:	89 e5                	mov    %esp,%ebp
  801a99:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9f:	e8 c5 fe ff ff       	call   801969 <fd2sockid>
  801aa4:	89 c2                	mov    %eax,%edx
  801aa6:	85 d2                	test   %edx,%edx
  801aa8:	78 16                	js     801ac0 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  801aaa:	8b 45 10             	mov    0x10(%ebp),%eax
  801aad:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ab1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab8:	89 14 24             	mov    %edx,(%esp)
  801abb:	e8 8a 01 00 00       	call   801c4a <nsipc_connect>
}
  801ac0:	c9                   	leave  
  801ac1:	c3                   	ret    

00801ac2 <listen>:

int
listen(int s, int backlog)
{
  801ac2:	55                   	push   %ebp
  801ac3:	89 e5                	mov    %esp,%ebp
  801ac5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ac8:	8b 45 08             	mov    0x8(%ebp),%eax
  801acb:	e8 99 fe ff ff       	call   801969 <fd2sockid>
  801ad0:	89 c2                	mov    %eax,%edx
  801ad2:	85 d2                	test   %edx,%edx
  801ad4:	78 0f                	js     801ae5 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801ad6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ad9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801add:	89 14 24             	mov    %edx,(%esp)
  801ae0:	e8 a4 01 00 00       	call   801c89 <nsipc_listen>
}
  801ae5:	c9                   	leave  
  801ae6:	c3                   	ret    

00801ae7 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801ae7:	55                   	push   %ebp
  801ae8:	89 e5                	mov    %esp,%ebp
  801aea:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801aed:	8b 45 10             	mov    0x10(%ebp),%eax
  801af0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801af4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801afb:	8b 45 08             	mov    0x8(%ebp),%eax
  801afe:	89 04 24             	mov    %eax,(%esp)
  801b01:	e8 98 02 00 00       	call   801d9e <nsipc_socket>
  801b06:	89 c2                	mov    %eax,%edx
  801b08:	85 d2                	test   %edx,%edx
  801b0a:	78 05                	js     801b11 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  801b0c:	e8 8a fe ff ff       	call   80199b <alloc_sockfd>
}
  801b11:	c9                   	leave  
  801b12:	c3                   	ret    

00801b13 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	53                   	push   %ebx
  801b17:	83 ec 14             	sub    $0x14,%esp
  801b1a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b1c:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801b23:	75 11                	jne    801b36 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b25:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801b2c:	e8 b4 08 00 00       	call   8023e5 <ipc_find_env>
  801b31:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b36:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b3d:	00 
  801b3e:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801b45:	00 
  801b46:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b4a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b4f:	89 04 24             	mov    %eax,(%esp)
  801b52:	e8 23 08 00 00       	call   80237a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b57:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b5e:	00 
  801b5f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b66:	00 
  801b67:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b6e:	e8 8d 07 00 00       	call   802300 <ipc_recv>
}
  801b73:	83 c4 14             	add    $0x14,%esp
  801b76:	5b                   	pop    %ebx
  801b77:	5d                   	pop    %ebp
  801b78:	c3                   	ret    

00801b79 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b79:	55                   	push   %ebp
  801b7a:	89 e5                	mov    %esp,%ebp
  801b7c:	56                   	push   %esi
  801b7d:	53                   	push   %ebx
  801b7e:	83 ec 10             	sub    $0x10,%esp
  801b81:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801b84:	8b 45 08             	mov    0x8(%ebp),%eax
  801b87:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801b8c:	8b 06                	mov    (%esi),%eax
  801b8e:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801b93:	b8 01 00 00 00       	mov    $0x1,%eax
  801b98:	e8 76 ff ff ff       	call   801b13 <nsipc>
  801b9d:	89 c3                	mov    %eax,%ebx
  801b9f:	85 c0                	test   %eax,%eax
  801ba1:	78 23                	js     801bc6 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801ba3:	a1 10 60 80 00       	mov    0x806010,%eax
  801ba8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bac:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801bb3:	00 
  801bb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb7:	89 04 24             	mov    %eax,(%esp)
  801bba:	e8 55 ee ff ff       	call   800a14 <memmove>
		*addrlen = ret->ret_addrlen;
  801bbf:	a1 10 60 80 00       	mov    0x806010,%eax
  801bc4:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801bc6:	89 d8                	mov    %ebx,%eax
  801bc8:	83 c4 10             	add    $0x10,%esp
  801bcb:	5b                   	pop    %ebx
  801bcc:	5e                   	pop    %esi
  801bcd:	5d                   	pop    %ebp
  801bce:	c3                   	ret    

00801bcf <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bcf:	55                   	push   %ebp
  801bd0:	89 e5                	mov    %esp,%ebp
  801bd2:	53                   	push   %ebx
  801bd3:	83 ec 14             	sub    $0x14,%esp
  801bd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801bd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdc:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801be1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801be5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bec:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801bf3:	e8 1c ee ff ff       	call   800a14 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801bf8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801bfe:	b8 02 00 00 00       	mov    $0x2,%eax
  801c03:	e8 0b ff ff ff       	call   801b13 <nsipc>
}
  801c08:	83 c4 14             	add    $0x14,%esp
  801c0b:	5b                   	pop    %ebx
  801c0c:	5d                   	pop    %ebp
  801c0d:	c3                   	ret    

00801c0e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c0e:	55                   	push   %ebp
  801c0f:	89 e5                	mov    %esp,%ebp
  801c11:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c14:	8b 45 08             	mov    0x8(%ebp),%eax
  801c17:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c1f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c24:	b8 03 00 00 00       	mov    $0x3,%eax
  801c29:	e8 e5 fe ff ff       	call   801b13 <nsipc>
}
  801c2e:	c9                   	leave  
  801c2f:	c3                   	ret    

00801c30 <nsipc_close>:

int
nsipc_close(int s)
{
  801c30:	55                   	push   %ebp
  801c31:	89 e5                	mov    %esp,%ebp
  801c33:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c36:	8b 45 08             	mov    0x8(%ebp),%eax
  801c39:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c3e:	b8 04 00 00 00       	mov    $0x4,%eax
  801c43:	e8 cb fe ff ff       	call   801b13 <nsipc>
}
  801c48:	c9                   	leave  
  801c49:	c3                   	ret    

00801c4a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c4a:	55                   	push   %ebp
  801c4b:	89 e5                	mov    %esp,%ebp
  801c4d:	53                   	push   %ebx
  801c4e:	83 ec 14             	sub    $0x14,%esp
  801c51:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c54:	8b 45 08             	mov    0x8(%ebp),%eax
  801c57:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c5c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c63:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c67:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801c6e:	e8 a1 ed ff ff       	call   800a14 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801c73:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801c79:	b8 05 00 00 00       	mov    $0x5,%eax
  801c7e:	e8 90 fe ff ff       	call   801b13 <nsipc>
}
  801c83:	83 c4 14             	add    $0x14,%esp
  801c86:	5b                   	pop    %ebx
  801c87:	5d                   	pop    %ebp
  801c88:	c3                   	ret    

00801c89 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801c89:	55                   	push   %ebp
  801c8a:	89 e5                	mov    %esp,%ebp
  801c8c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c92:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801c97:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c9a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801c9f:	b8 06 00 00 00       	mov    $0x6,%eax
  801ca4:	e8 6a fe ff ff       	call   801b13 <nsipc>
}
  801ca9:	c9                   	leave  
  801caa:	c3                   	ret    

00801cab <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801cab:	55                   	push   %ebp
  801cac:	89 e5                	mov    %esp,%ebp
  801cae:	56                   	push   %esi
  801caf:	53                   	push   %ebx
  801cb0:	83 ec 10             	sub    $0x10,%esp
  801cb3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801cb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801cbe:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801cc4:	8b 45 14             	mov    0x14(%ebp),%eax
  801cc7:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ccc:	b8 07 00 00 00       	mov    $0x7,%eax
  801cd1:	e8 3d fe ff ff       	call   801b13 <nsipc>
  801cd6:	89 c3                	mov    %eax,%ebx
  801cd8:	85 c0                	test   %eax,%eax
  801cda:	78 46                	js     801d22 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801cdc:	39 f0                	cmp    %esi,%eax
  801cde:	7f 07                	jg     801ce7 <nsipc_recv+0x3c>
  801ce0:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801ce5:	7e 24                	jle    801d0b <nsipc_recv+0x60>
  801ce7:	c7 44 24 0c 9b 2b 80 	movl   $0x802b9b,0xc(%esp)
  801cee:	00 
  801cef:	c7 44 24 08 63 2b 80 	movl   $0x802b63,0x8(%esp)
  801cf6:	00 
  801cf7:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801cfe:	00 
  801cff:	c7 04 24 b0 2b 80 00 	movl   $0x802bb0,(%esp)
  801d06:	e8 4a e4 ff ff       	call   800155 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d0b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d0f:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801d16:	00 
  801d17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d1a:	89 04 24             	mov    %eax,(%esp)
  801d1d:	e8 f2 ec ff ff       	call   800a14 <memmove>
	}

	return r;
}
  801d22:	89 d8                	mov    %ebx,%eax
  801d24:	83 c4 10             	add    $0x10,%esp
  801d27:	5b                   	pop    %ebx
  801d28:	5e                   	pop    %esi
  801d29:	5d                   	pop    %ebp
  801d2a:	c3                   	ret    

00801d2b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d2b:	55                   	push   %ebp
  801d2c:	89 e5                	mov    %esp,%ebp
  801d2e:	53                   	push   %ebx
  801d2f:	83 ec 14             	sub    $0x14,%esp
  801d32:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d35:	8b 45 08             	mov    0x8(%ebp),%eax
  801d38:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d3d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d43:	7e 24                	jle    801d69 <nsipc_send+0x3e>
  801d45:	c7 44 24 0c bc 2b 80 	movl   $0x802bbc,0xc(%esp)
  801d4c:	00 
  801d4d:	c7 44 24 08 63 2b 80 	movl   $0x802b63,0x8(%esp)
  801d54:	00 
  801d55:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801d5c:	00 
  801d5d:	c7 04 24 b0 2b 80 00 	movl   $0x802bb0,(%esp)
  801d64:	e8 ec e3 ff ff       	call   800155 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d70:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d74:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801d7b:	e8 94 ec ff ff       	call   800a14 <memmove>
	nsipcbuf.send.req_size = size;
  801d80:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801d86:	8b 45 14             	mov    0x14(%ebp),%eax
  801d89:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801d8e:	b8 08 00 00 00       	mov    $0x8,%eax
  801d93:	e8 7b fd ff ff       	call   801b13 <nsipc>
}
  801d98:	83 c4 14             	add    $0x14,%esp
  801d9b:	5b                   	pop    %ebx
  801d9c:	5d                   	pop    %ebp
  801d9d:	c3                   	ret    

00801d9e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801d9e:	55                   	push   %ebp
  801d9f:	89 e5                	mov    %esp,%ebp
  801da1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801da4:	8b 45 08             	mov    0x8(%ebp),%eax
  801da7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801dac:	8b 45 0c             	mov    0xc(%ebp),%eax
  801daf:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801db4:	8b 45 10             	mov    0x10(%ebp),%eax
  801db7:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801dbc:	b8 09 00 00 00       	mov    $0x9,%eax
  801dc1:	e8 4d fd ff ff       	call   801b13 <nsipc>
}
  801dc6:	c9                   	leave  
  801dc7:	c3                   	ret    

00801dc8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801dc8:	55                   	push   %ebp
  801dc9:	89 e5                	mov    %esp,%ebp
  801dcb:	56                   	push   %esi
  801dcc:	53                   	push   %ebx
  801dcd:	83 ec 10             	sub    $0x10,%esp
  801dd0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801dd3:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd6:	89 04 24             	mov    %eax,(%esp)
  801dd9:	e8 72 f2 ff ff       	call   801050 <fd2data>
  801dde:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801de0:	c7 44 24 04 c8 2b 80 	movl   $0x802bc8,0x4(%esp)
  801de7:	00 
  801de8:	89 1c 24             	mov    %ebx,(%esp)
  801deb:	e8 87 ea ff ff       	call   800877 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801df0:	8b 46 04             	mov    0x4(%esi),%eax
  801df3:	2b 06                	sub    (%esi),%eax
  801df5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801dfb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e02:	00 00 00 
	stat->st_dev = &devpipe;
  801e05:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e0c:	30 80 00 
	return 0;
}
  801e0f:	b8 00 00 00 00       	mov    $0x0,%eax
  801e14:	83 c4 10             	add    $0x10,%esp
  801e17:	5b                   	pop    %ebx
  801e18:	5e                   	pop    %esi
  801e19:	5d                   	pop    %ebp
  801e1a:	c3                   	ret    

00801e1b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e1b:	55                   	push   %ebp
  801e1c:	89 e5                	mov    %esp,%ebp
  801e1e:	53                   	push   %ebx
  801e1f:	83 ec 14             	sub    $0x14,%esp
  801e22:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e25:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e29:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e30:	e8 05 ef ff ff       	call   800d3a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e35:	89 1c 24             	mov    %ebx,(%esp)
  801e38:	e8 13 f2 ff ff       	call   801050 <fd2data>
  801e3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e48:	e8 ed ee ff ff       	call   800d3a <sys_page_unmap>
}
  801e4d:	83 c4 14             	add    $0x14,%esp
  801e50:	5b                   	pop    %ebx
  801e51:	5d                   	pop    %ebp
  801e52:	c3                   	ret    

00801e53 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e53:	55                   	push   %ebp
  801e54:	89 e5                	mov    %esp,%ebp
  801e56:	57                   	push   %edi
  801e57:	56                   	push   %esi
  801e58:	53                   	push   %ebx
  801e59:	83 ec 2c             	sub    $0x2c,%esp
  801e5c:	89 c6                	mov    %eax,%esi
  801e5e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e61:	a1 08 40 80 00       	mov    0x804008,%eax
  801e66:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e69:	89 34 24             	mov    %esi,(%esp)
  801e6c:	e8 ac 05 00 00       	call   80241d <pageref>
  801e71:	89 c7                	mov    %eax,%edi
  801e73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e76:	89 04 24             	mov    %eax,(%esp)
  801e79:	e8 9f 05 00 00       	call   80241d <pageref>
  801e7e:	39 c7                	cmp    %eax,%edi
  801e80:	0f 94 c2             	sete   %dl
  801e83:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801e86:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801e8c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801e8f:	39 fb                	cmp    %edi,%ebx
  801e91:	74 21                	je     801eb4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801e93:	84 d2                	test   %dl,%dl
  801e95:	74 ca                	je     801e61 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e97:	8b 51 58             	mov    0x58(%ecx),%edx
  801e9a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e9e:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ea2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ea6:	c7 04 24 cf 2b 80 00 	movl   $0x802bcf,(%esp)
  801ead:	e8 9c e3 ff ff       	call   80024e <cprintf>
  801eb2:	eb ad                	jmp    801e61 <_pipeisclosed+0xe>
	}
}
  801eb4:	83 c4 2c             	add    $0x2c,%esp
  801eb7:	5b                   	pop    %ebx
  801eb8:	5e                   	pop    %esi
  801eb9:	5f                   	pop    %edi
  801eba:	5d                   	pop    %ebp
  801ebb:	c3                   	ret    

00801ebc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ebc:	55                   	push   %ebp
  801ebd:	89 e5                	mov    %esp,%ebp
  801ebf:	57                   	push   %edi
  801ec0:	56                   	push   %esi
  801ec1:	53                   	push   %ebx
  801ec2:	83 ec 1c             	sub    $0x1c,%esp
  801ec5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ec8:	89 34 24             	mov    %esi,(%esp)
  801ecb:	e8 80 f1 ff ff       	call   801050 <fd2data>
  801ed0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ed2:	bf 00 00 00 00       	mov    $0x0,%edi
  801ed7:	eb 45                	jmp    801f1e <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ed9:	89 da                	mov    %ebx,%edx
  801edb:	89 f0                	mov    %esi,%eax
  801edd:	e8 71 ff ff ff       	call   801e53 <_pipeisclosed>
  801ee2:	85 c0                	test   %eax,%eax
  801ee4:	75 41                	jne    801f27 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ee6:	e8 89 ed ff ff       	call   800c74 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801eeb:	8b 43 04             	mov    0x4(%ebx),%eax
  801eee:	8b 0b                	mov    (%ebx),%ecx
  801ef0:	8d 51 20             	lea    0x20(%ecx),%edx
  801ef3:	39 d0                	cmp    %edx,%eax
  801ef5:	73 e2                	jae    801ed9 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ef7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801efa:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801efe:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f01:	99                   	cltd   
  801f02:	c1 ea 1b             	shr    $0x1b,%edx
  801f05:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801f08:	83 e1 1f             	and    $0x1f,%ecx
  801f0b:	29 d1                	sub    %edx,%ecx
  801f0d:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801f11:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801f15:	83 c0 01             	add    $0x1,%eax
  801f18:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f1b:	83 c7 01             	add    $0x1,%edi
  801f1e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f21:	75 c8                	jne    801eeb <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f23:	89 f8                	mov    %edi,%eax
  801f25:	eb 05                	jmp    801f2c <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f27:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f2c:	83 c4 1c             	add    $0x1c,%esp
  801f2f:	5b                   	pop    %ebx
  801f30:	5e                   	pop    %esi
  801f31:	5f                   	pop    %edi
  801f32:	5d                   	pop    %ebp
  801f33:	c3                   	ret    

00801f34 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f34:	55                   	push   %ebp
  801f35:	89 e5                	mov    %esp,%ebp
  801f37:	57                   	push   %edi
  801f38:	56                   	push   %esi
  801f39:	53                   	push   %ebx
  801f3a:	83 ec 1c             	sub    $0x1c,%esp
  801f3d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f40:	89 3c 24             	mov    %edi,(%esp)
  801f43:	e8 08 f1 ff ff       	call   801050 <fd2data>
  801f48:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f4a:	be 00 00 00 00       	mov    $0x0,%esi
  801f4f:	eb 3d                	jmp    801f8e <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f51:	85 f6                	test   %esi,%esi
  801f53:	74 04                	je     801f59 <devpipe_read+0x25>
				return i;
  801f55:	89 f0                	mov    %esi,%eax
  801f57:	eb 43                	jmp    801f9c <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f59:	89 da                	mov    %ebx,%edx
  801f5b:	89 f8                	mov    %edi,%eax
  801f5d:	e8 f1 fe ff ff       	call   801e53 <_pipeisclosed>
  801f62:	85 c0                	test   %eax,%eax
  801f64:	75 31                	jne    801f97 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f66:	e8 09 ed ff ff       	call   800c74 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f6b:	8b 03                	mov    (%ebx),%eax
  801f6d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f70:	74 df                	je     801f51 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f72:	99                   	cltd   
  801f73:	c1 ea 1b             	shr    $0x1b,%edx
  801f76:	01 d0                	add    %edx,%eax
  801f78:	83 e0 1f             	and    $0x1f,%eax
  801f7b:	29 d0                	sub    %edx,%eax
  801f7d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801f82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f85:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801f88:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f8b:	83 c6 01             	add    $0x1,%esi
  801f8e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f91:	75 d8                	jne    801f6b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f93:	89 f0                	mov    %esi,%eax
  801f95:	eb 05                	jmp    801f9c <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f97:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f9c:	83 c4 1c             	add    $0x1c,%esp
  801f9f:	5b                   	pop    %ebx
  801fa0:	5e                   	pop    %esi
  801fa1:	5f                   	pop    %edi
  801fa2:	5d                   	pop    %ebp
  801fa3:	c3                   	ret    

00801fa4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fa4:	55                   	push   %ebp
  801fa5:	89 e5                	mov    %esp,%ebp
  801fa7:	56                   	push   %esi
  801fa8:	53                   	push   %ebx
  801fa9:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801faf:	89 04 24             	mov    %eax,(%esp)
  801fb2:	e8 b0 f0 ff ff       	call   801067 <fd_alloc>
  801fb7:	89 c2                	mov    %eax,%edx
  801fb9:	85 d2                	test   %edx,%edx
  801fbb:	0f 88 4d 01 00 00    	js     80210e <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fc1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fc8:	00 
  801fc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fcc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fd7:	e8 b7 ec ff ff       	call   800c93 <sys_page_alloc>
  801fdc:	89 c2                	mov    %eax,%edx
  801fde:	85 d2                	test   %edx,%edx
  801fe0:	0f 88 28 01 00 00    	js     80210e <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801fe6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fe9:	89 04 24             	mov    %eax,(%esp)
  801fec:	e8 76 f0 ff ff       	call   801067 <fd_alloc>
  801ff1:	89 c3                	mov    %eax,%ebx
  801ff3:	85 c0                	test   %eax,%eax
  801ff5:	0f 88 fe 00 00 00    	js     8020f9 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ffb:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802002:	00 
  802003:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802006:	89 44 24 04          	mov    %eax,0x4(%esp)
  80200a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802011:	e8 7d ec ff ff       	call   800c93 <sys_page_alloc>
  802016:	89 c3                	mov    %eax,%ebx
  802018:	85 c0                	test   %eax,%eax
  80201a:	0f 88 d9 00 00 00    	js     8020f9 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802020:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802023:	89 04 24             	mov    %eax,(%esp)
  802026:	e8 25 f0 ff ff       	call   801050 <fd2data>
  80202b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80202d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802034:	00 
  802035:	89 44 24 04          	mov    %eax,0x4(%esp)
  802039:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802040:	e8 4e ec ff ff       	call   800c93 <sys_page_alloc>
  802045:	89 c3                	mov    %eax,%ebx
  802047:	85 c0                	test   %eax,%eax
  802049:	0f 88 97 00 00 00    	js     8020e6 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80204f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802052:	89 04 24             	mov    %eax,(%esp)
  802055:	e8 f6 ef ff ff       	call   801050 <fd2data>
  80205a:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802061:	00 
  802062:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802066:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80206d:	00 
  80206e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802072:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802079:	e8 69 ec ff ff       	call   800ce7 <sys_page_map>
  80207e:	89 c3                	mov    %eax,%ebx
  802080:	85 c0                	test   %eax,%eax
  802082:	78 52                	js     8020d6 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802084:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80208a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80208d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80208f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802092:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802099:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80209f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020a2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020a7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b1:	89 04 24             	mov    %eax,(%esp)
  8020b4:	e8 87 ef ff ff       	call   801040 <fd2num>
  8020b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020bc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020c1:	89 04 24             	mov    %eax,(%esp)
  8020c4:	e8 77 ef ff ff       	call   801040 <fd2num>
  8020c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020cc:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8020d4:	eb 38                	jmp    80210e <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  8020d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020e1:	e8 54 ec ff ff       	call   800d3a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8020e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020f4:	e8 41 ec ff ff       	call   800d3a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8020f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  802100:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802107:	e8 2e ec ff ff       	call   800d3a <sys_page_unmap>
  80210c:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  80210e:	83 c4 30             	add    $0x30,%esp
  802111:	5b                   	pop    %ebx
  802112:	5e                   	pop    %esi
  802113:	5d                   	pop    %ebp
  802114:	c3                   	ret    

00802115 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802115:	55                   	push   %ebp
  802116:	89 e5                	mov    %esp,%ebp
  802118:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80211b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80211e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802122:	8b 45 08             	mov    0x8(%ebp),%eax
  802125:	89 04 24             	mov    %eax,(%esp)
  802128:	e8 89 ef ff ff       	call   8010b6 <fd_lookup>
  80212d:	89 c2                	mov    %eax,%edx
  80212f:	85 d2                	test   %edx,%edx
  802131:	78 15                	js     802148 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802133:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802136:	89 04 24             	mov    %eax,(%esp)
  802139:	e8 12 ef ff ff       	call   801050 <fd2data>
	return _pipeisclosed(fd, p);
  80213e:	89 c2                	mov    %eax,%edx
  802140:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802143:	e8 0b fd ff ff       	call   801e53 <_pipeisclosed>
}
  802148:	c9                   	leave  
  802149:	c3                   	ret    
  80214a:	66 90                	xchg   %ax,%ax
  80214c:	66 90                	xchg   %ax,%ax
  80214e:	66 90                	xchg   %ax,%ax

00802150 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802150:	55                   	push   %ebp
  802151:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802153:	b8 00 00 00 00       	mov    $0x0,%eax
  802158:	5d                   	pop    %ebp
  802159:	c3                   	ret    

0080215a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80215a:	55                   	push   %ebp
  80215b:	89 e5                	mov    %esp,%ebp
  80215d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802160:	c7 44 24 04 e7 2b 80 	movl   $0x802be7,0x4(%esp)
  802167:	00 
  802168:	8b 45 0c             	mov    0xc(%ebp),%eax
  80216b:	89 04 24             	mov    %eax,(%esp)
  80216e:	e8 04 e7 ff ff       	call   800877 <strcpy>
	return 0;
}
  802173:	b8 00 00 00 00       	mov    $0x0,%eax
  802178:	c9                   	leave  
  802179:	c3                   	ret    

0080217a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80217a:	55                   	push   %ebp
  80217b:	89 e5                	mov    %esp,%ebp
  80217d:	57                   	push   %edi
  80217e:	56                   	push   %esi
  80217f:	53                   	push   %ebx
  802180:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802186:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80218b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802191:	eb 31                	jmp    8021c4 <devcons_write+0x4a>
		m = n - tot;
  802193:	8b 75 10             	mov    0x10(%ebp),%esi
  802196:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802198:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80219b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8021a0:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021a3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8021a7:	03 45 0c             	add    0xc(%ebp),%eax
  8021aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021ae:	89 3c 24             	mov    %edi,(%esp)
  8021b1:	e8 5e e8 ff ff       	call   800a14 <memmove>
		sys_cputs(buf, m);
  8021b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ba:	89 3c 24             	mov    %edi,(%esp)
  8021bd:	e8 04 ea ff ff       	call   800bc6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021c2:	01 f3                	add    %esi,%ebx
  8021c4:	89 d8                	mov    %ebx,%eax
  8021c6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8021c9:	72 c8                	jb     802193 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021cb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8021d1:	5b                   	pop    %ebx
  8021d2:	5e                   	pop    %esi
  8021d3:	5f                   	pop    %edi
  8021d4:	5d                   	pop    %ebp
  8021d5:	c3                   	ret    

008021d6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021d6:	55                   	push   %ebp
  8021d7:	89 e5                	mov    %esp,%ebp
  8021d9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8021dc:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8021e1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021e5:	75 07                	jne    8021ee <devcons_read+0x18>
  8021e7:	eb 2a                	jmp    802213 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021e9:	e8 86 ea ff ff       	call   800c74 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021ee:	66 90                	xchg   %ax,%ax
  8021f0:	e8 ef e9 ff ff       	call   800be4 <sys_cgetc>
  8021f5:	85 c0                	test   %eax,%eax
  8021f7:	74 f0                	je     8021e9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8021f9:	85 c0                	test   %eax,%eax
  8021fb:	78 16                	js     802213 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021fd:	83 f8 04             	cmp    $0x4,%eax
  802200:	74 0c                	je     80220e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802202:	8b 55 0c             	mov    0xc(%ebp),%edx
  802205:	88 02                	mov    %al,(%edx)
	return 1;
  802207:	b8 01 00 00 00       	mov    $0x1,%eax
  80220c:	eb 05                	jmp    802213 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80220e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802213:	c9                   	leave  
  802214:	c3                   	ret    

00802215 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802215:	55                   	push   %ebp
  802216:	89 e5                	mov    %esp,%ebp
  802218:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80221b:	8b 45 08             	mov    0x8(%ebp),%eax
  80221e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802221:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802228:	00 
  802229:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80222c:	89 04 24             	mov    %eax,(%esp)
  80222f:	e8 92 e9 ff ff       	call   800bc6 <sys_cputs>
}
  802234:	c9                   	leave  
  802235:	c3                   	ret    

00802236 <getchar>:

int
getchar(void)
{
  802236:	55                   	push   %ebp
  802237:	89 e5                	mov    %esp,%ebp
  802239:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80223c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802243:	00 
  802244:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802247:	89 44 24 04          	mov    %eax,0x4(%esp)
  80224b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802252:	e8 f3 f0 ff ff       	call   80134a <read>
	if (r < 0)
  802257:	85 c0                	test   %eax,%eax
  802259:	78 0f                	js     80226a <getchar+0x34>
		return r;
	if (r < 1)
  80225b:	85 c0                	test   %eax,%eax
  80225d:	7e 06                	jle    802265 <getchar+0x2f>
		return -E_EOF;
	return c;
  80225f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802263:	eb 05                	jmp    80226a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802265:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80226a:	c9                   	leave  
  80226b:	c3                   	ret    

0080226c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80226c:	55                   	push   %ebp
  80226d:	89 e5                	mov    %esp,%ebp
  80226f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802272:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802275:	89 44 24 04          	mov    %eax,0x4(%esp)
  802279:	8b 45 08             	mov    0x8(%ebp),%eax
  80227c:	89 04 24             	mov    %eax,(%esp)
  80227f:	e8 32 ee ff ff       	call   8010b6 <fd_lookup>
  802284:	85 c0                	test   %eax,%eax
  802286:	78 11                	js     802299 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802288:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80228b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802291:	39 10                	cmp    %edx,(%eax)
  802293:	0f 94 c0             	sete   %al
  802296:	0f b6 c0             	movzbl %al,%eax
}
  802299:	c9                   	leave  
  80229a:	c3                   	ret    

0080229b <opencons>:

int
opencons(void)
{
  80229b:	55                   	push   %ebp
  80229c:	89 e5                	mov    %esp,%ebp
  80229e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022a4:	89 04 24             	mov    %eax,(%esp)
  8022a7:	e8 bb ed ff ff       	call   801067 <fd_alloc>
		return r;
  8022ac:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022ae:	85 c0                	test   %eax,%eax
  8022b0:	78 40                	js     8022f2 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022b2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022b9:	00 
  8022ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022c8:	e8 c6 e9 ff ff       	call   800c93 <sys_page_alloc>
		return r;
  8022cd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022cf:	85 c0                	test   %eax,%eax
  8022d1:	78 1f                	js     8022f2 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022d3:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022dc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022e1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022e8:	89 04 24             	mov    %eax,(%esp)
  8022eb:	e8 50 ed ff ff       	call   801040 <fd2num>
  8022f0:	89 c2                	mov    %eax,%edx
}
  8022f2:	89 d0                	mov    %edx,%eax
  8022f4:	c9                   	leave  
  8022f5:	c3                   	ret    
  8022f6:	66 90                	xchg   %ax,%ax
  8022f8:	66 90                	xchg   %ax,%ax
  8022fa:	66 90                	xchg   %ax,%ax
  8022fc:	66 90                	xchg   %ax,%ax
  8022fe:	66 90                	xchg   %ax,%ax

00802300 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802300:	55                   	push   %ebp
  802301:	89 e5                	mov    %esp,%ebp
  802303:	56                   	push   %esi
  802304:	53                   	push   %ebx
  802305:	83 ec 10             	sub    $0x10,%esp
  802308:	8b 75 08             	mov    0x8(%ebp),%esi
  80230b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80230e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  802311:	85 c0                	test   %eax,%eax
  802313:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802318:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  80231b:	89 04 24             	mov    %eax,(%esp)
  80231e:	e8 86 eb ff ff       	call   800ea9 <sys_ipc_recv>

	if(ret < 0) {
  802323:	85 c0                	test   %eax,%eax
  802325:	79 16                	jns    80233d <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  802327:	85 f6                	test   %esi,%esi
  802329:	74 06                	je     802331 <ipc_recv+0x31>
  80232b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  802331:	85 db                	test   %ebx,%ebx
  802333:	74 3e                	je     802373 <ipc_recv+0x73>
  802335:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80233b:	eb 36                	jmp    802373 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  80233d:	e8 13 e9 ff ff       	call   800c55 <sys_getenvid>
  802342:	25 ff 03 00 00       	and    $0x3ff,%eax
  802347:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80234a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80234f:	a3 08 40 80 00       	mov    %eax,0x804008

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802354:	85 f6                	test   %esi,%esi
  802356:	74 05                	je     80235d <ipc_recv+0x5d>
  802358:	8b 40 74             	mov    0x74(%eax),%eax
  80235b:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80235d:	85 db                	test   %ebx,%ebx
  80235f:	74 0a                	je     80236b <ipc_recv+0x6b>
  802361:	a1 08 40 80 00       	mov    0x804008,%eax
  802366:	8b 40 78             	mov    0x78(%eax),%eax
  802369:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  80236b:	a1 08 40 80 00       	mov    0x804008,%eax
  802370:	8b 40 70             	mov    0x70(%eax),%eax
}
  802373:	83 c4 10             	add    $0x10,%esp
  802376:	5b                   	pop    %ebx
  802377:	5e                   	pop    %esi
  802378:	5d                   	pop    %ebp
  802379:	c3                   	ret    

0080237a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80237a:	55                   	push   %ebp
  80237b:	89 e5                	mov    %esp,%ebp
  80237d:	57                   	push   %edi
  80237e:	56                   	push   %esi
  80237f:	53                   	push   %ebx
  802380:	83 ec 1c             	sub    $0x1c,%esp
  802383:	8b 7d 08             	mov    0x8(%ebp),%edi
  802386:	8b 75 0c             	mov    0xc(%ebp),%esi
  802389:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  80238c:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  80238e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802393:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  802396:	8b 45 14             	mov    0x14(%ebp),%eax
  802399:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80239d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023a5:	89 3c 24             	mov    %edi,(%esp)
  8023a8:	e8 d9 ea ff ff       	call   800e86 <sys_ipc_try_send>

		if(ret >= 0) break;
  8023ad:	85 c0                	test   %eax,%eax
  8023af:	79 2c                	jns    8023dd <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  8023b1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023b4:	74 20                	je     8023d6 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  8023b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023ba:	c7 44 24 08 f4 2b 80 	movl   $0x802bf4,0x8(%esp)
  8023c1:	00 
  8023c2:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8023c9:	00 
  8023ca:	c7 04 24 24 2c 80 00 	movl   $0x802c24,(%esp)
  8023d1:	e8 7f dd ff ff       	call   800155 <_panic>
		}
		sys_yield();
  8023d6:	e8 99 e8 ff ff       	call   800c74 <sys_yield>
	}
  8023db:	eb b9                	jmp    802396 <ipc_send+0x1c>
}
  8023dd:	83 c4 1c             	add    $0x1c,%esp
  8023e0:	5b                   	pop    %ebx
  8023e1:	5e                   	pop    %esi
  8023e2:	5f                   	pop    %edi
  8023e3:	5d                   	pop    %ebp
  8023e4:	c3                   	ret    

008023e5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023e5:	55                   	push   %ebp
  8023e6:	89 e5                	mov    %esp,%ebp
  8023e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8023eb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8023f0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8023f3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023f9:	8b 52 50             	mov    0x50(%edx),%edx
  8023fc:	39 ca                	cmp    %ecx,%edx
  8023fe:	75 0d                	jne    80240d <ipc_find_env+0x28>
			return envs[i].env_id;
  802400:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802403:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802408:	8b 40 40             	mov    0x40(%eax),%eax
  80240b:	eb 0e                	jmp    80241b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80240d:	83 c0 01             	add    $0x1,%eax
  802410:	3d 00 04 00 00       	cmp    $0x400,%eax
  802415:	75 d9                	jne    8023f0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802417:	66 b8 00 00          	mov    $0x0,%ax
}
  80241b:	5d                   	pop    %ebp
  80241c:	c3                   	ret    

0080241d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80241d:	55                   	push   %ebp
  80241e:	89 e5                	mov    %esp,%ebp
  802420:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802423:	89 d0                	mov    %edx,%eax
  802425:	c1 e8 16             	shr    $0x16,%eax
  802428:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80242f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802434:	f6 c1 01             	test   $0x1,%cl
  802437:	74 1d                	je     802456 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802439:	c1 ea 0c             	shr    $0xc,%edx
  80243c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802443:	f6 c2 01             	test   $0x1,%dl
  802446:	74 0e                	je     802456 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802448:	c1 ea 0c             	shr    $0xc,%edx
  80244b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802452:	ef 
  802453:	0f b7 c0             	movzwl %ax,%eax
}
  802456:	5d                   	pop    %ebp
  802457:	c3                   	ret    
  802458:	66 90                	xchg   %ax,%ax
  80245a:	66 90                	xchg   %ax,%ax
  80245c:	66 90                	xchg   %ax,%ax
  80245e:	66 90                	xchg   %ax,%ax

00802460 <__udivdi3>:
  802460:	55                   	push   %ebp
  802461:	57                   	push   %edi
  802462:	56                   	push   %esi
  802463:	83 ec 0c             	sub    $0xc,%esp
  802466:	8b 44 24 28          	mov    0x28(%esp),%eax
  80246a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80246e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802472:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802476:	85 c0                	test   %eax,%eax
  802478:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80247c:	89 ea                	mov    %ebp,%edx
  80247e:	89 0c 24             	mov    %ecx,(%esp)
  802481:	75 2d                	jne    8024b0 <__udivdi3+0x50>
  802483:	39 e9                	cmp    %ebp,%ecx
  802485:	77 61                	ja     8024e8 <__udivdi3+0x88>
  802487:	85 c9                	test   %ecx,%ecx
  802489:	89 ce                	mov    %ecx,%esi
  80248b:	75 0b                	jne    802498 <__udivdi3+0x38>
  80248d:	b8 01 00 00 00       	mov    $0x1,%eax
  802492:	31 d2                	xor    %edx,%edx
  802494:	f7 f1                	div    %ecx
  802496:	89 c6                	mov    %eax,%esi
  802498:	31 d2                	xor    %edx,%edx
  80249a:	89 e8                	mov    %ebp,%eax
  80249c:	f7 f6                	div    %esi
  80249e:	89 c5                	mov    %eax,%ebp
  8024a0:	89 f8                	mov    %edi,%eax
  8024a2:	f7 f6                	div    %esi
  8024a4:	89 ea                	mov    %ebp,%edx
  8024a6:	83 c4 0c             	add    $0xc,%esp
  8024a9:	5e                   	pop    %esi
  8024aa:	5f                   	pop    %edi
  8024ab:	5d                   	pop    %ebp
  8024ac:	c3                   	ret    
  8024ad:	8d 76 00             	lea    0x0(%esi),%esi
  8024b0:	39 e8                	cmp    %ebp,%eax
  8024b2:	77 24                	ja     8024d8 <__udivdi3+0x78>
  8024b4:	0f bd e8             	bsr    %eax,%ebp
  8024b7:	83 f5 1f             	xor    $0x1f,%ebp
  8024ba:	75 3c                	jne    8024f8 <__udivdi3+0x98>
  8024bc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8024c0:	39 34 24             	cmp    %esi,(%esp)
  8024c3:	0f 86 9f 00 00 00    	jbe    802568 <__udivdi3+0x108>
  8024c9:	39 d0                	cmp    %edx,%eax
  8024cb:	0f 82 97 00 00 00    	jb     802568 <__udivdi3+0x108>
  8024d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024d8:	31 d2                	xor    %edx,%edx
  8024da:	31 c0                	xor    %eax,%eax
  8024dc:	83 c4 0c             	add    $0xc,%esp
  8024df:	5e                   	pop    %esi
  8024e0:	5f                   	pop    %edi
  8024e1:	5d                   	pop    %ebp
  8024e2:	c3                   	ret    
  8024e3:	90                   	nop
  8024e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024e8:	89 f8                	mov    %edi,%eax
  8024ea:	f7 f1                	div    %ecx
  8024ec:	31 d2                	xor    %edx,%edx
  8024ee:	83 c4 0c             	add    $0xc,%esp
  8024f1:	5e                   	pop    %esi
  8024f2:	5f                   	pop    %edi
  8024f3:	5d                   	pop    %ebp
  8024f4:	c3                   	ret    
  8024f5:	8d 76 00             	lea    0x0(%esi),%esi
  8024f8:	89 e9                	mov    %ebp,%ecx
  8024fa:	8b 3c 24             	mov    (%esp),%edi
  8024fd:	d3 e0                	shl    %cl,%eax
  8024ff:	89 c6                	mov    %eax,%esi
  802501:	b8 20 00 00 00       	mov    $0x20,%eax
  802506:	29 e8                	sub    %ebp,%eax
  802508:	89 c1                	mov    %eax,%ecx
  80250a:	d3 ef                	shr    %cl,%edi
  80250c:	89 e9                	mov    %ebp,%ecx
  80250e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802512:	8b 3c 24             	mov    (%esp),%edi
  802515:	09 74 24 08          	or     %esi,0x8(%esp)
  802519:	89 d6                	mov    %edx,%esi
  80251b:	d3 e7                	shl    %cl,%edi
  80251d:	89 c1                	mov    %eax,%ecx
  80251f:	89 3c 24             	mov    %edi,(%esp)
  802522:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802526:	d3 ee                	shr    %cl,%esi
  802528:	89 e9                	mov    %ebp,%ecx
  80252a:	d3 e2                	shl    %cl,%edx
  80252c:	89 c1                	mov    %eax,%ecx
  80252e:	d3 ef                	shr    %cl,%edi
  802530:	09 d7                	or     %edx,%edi
  802532:	89 f2                	mov    %esi,%edx
  802534:	89 f8                	mov    %edi,%eax
  802536:	f7 74 24 08          	divl   0x8(%esp)
  80253a:	89 d6                	mov    %edx,%esi
  80253c:	89 c7                	mov    %eax,%edi
  80253e:	f7 24 24             	mull   (%esp)
  802541:	39 d6                	cmp    %edx,%esi
  802543:	89 14 24             	mov    %edx,(%esp)
  802546:	72 30                	jb     802578 <__udivdi3+0x118>
  802548:	8b 54 24 04          	mov    0x4(%esp),%edx
  80254c:	89 e9                	mov    %ebp,%ecx
  80254e:	d3 e2                	shl    %cl,%edx
  802550:	39 c2                	cmp    %eax,%edx
  802552:	73 05                	jae    802559 <__udivdi3+0xf9>
  802554:	3b 34 24             	cmp    (%esp),%esi
  802557:	74 1f                	je     802578 <__udivdi3+0x118>
  802559:	89 f8                	mov    %edi,%eax
  80255b:	31 d2                	xor    %edx,%edx
  80255d:	e9 7a ff ff ff       	jmp    8024dc <__udivdi3+0x7c>
  802562:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802568:	31 d2                	xor    %edx,%edx
  80256a:	b8 01 00 00 00       	mov    $0x1,%eax
  80256f:	e9 68 ff ff ff       	jmp    8024dc <__udivdi3+0x7c>
  802574:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802578:	8d 47 ff             	lea    -0x1(%edi),%eax
  80257b:	31 d2                	xor    %edx,%edx
  80257d:	83 c4 0c             	add    $0xc,%esp
  802580:	5e                   	pop    %esi
  802581:	5f                   	pop    %edi
  802582:	5d                   	pop    %ebp
  802583:	c3                   	ret    
  802584:	66 90                	xchg   %ax,%ax
  802586:	66 90                	xchg   %ax,%ax
  802588:	66 90                	xchg   %ax,%ax
  80258a:	66 90                	xchg   %ax,%ax
  80258c:	66 90                	xchg   %ax,%ax
  80258e:	66 90                	xchg   %ax,%ax

00802590 <__umoddi3>:
  802590:	55                   	push   %ebp
  802591:	57                   	push   %edi
  802592:	56                   	push   %esi
  802593:	83 ec 14             	sub    $0x14,%esp
  802596:	8b 44 24 28          	mov    0x28(%esp),%eax
  80259a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80259e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8025a2:	89 c7                	mov    %eax,%edi
  8025a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025a8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8025ac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8025b0:	89 34 24             	mov    %esi,(%esp)
  8025b3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025b7:	85 c0                	test   %eax,%eax
  8025b9:	89 c2                	mov    %eax,%edx
  8025bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8025bf:	75 17                	jne    8025d8 <__umoddi3+0x48>
  8025c1:	39 fe                	cmp    %edi,%esi
  8025c3:	76 4b                	jbe    802610 <__umoddi3+0x80>
  8025c5:	89 c8                	mov    %ecx,%eax
  8025c7:	89 fa                	mov    %edi,%edx
  8025c9:	f7 f6                	div    %esi
  8025cb:	89 d0                	mov    %edx,%eax
  8025cd:	31 d2                	xor    %edx,%edx
  8025cf:	83 c4 14             	add    $0x14,%esp
  8025d2:	5e                   	pop    %esi
  8025d3:	5f                   	pop    %edi
  8025d4:	5d                   	pop    %ebp
  8025d5:	c3                   	ret    
  8025d6:	66 90                	xchg   %ax,%ax
  8025d8:	39 f8                	cmp    %edi,%eax
  8025da:	77 54                	ja     802630 <__umoddi3+0xa0>
  8025dc:	0f bd e8             	bsr    %eax,%ebp
  8025df:	83 f5 1f             	xor    $0x1f,%ebp
  8025e2:	75 5c                	jne    802640 <__umoddi3+0xb0>
  8025e4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8025e8:	39 3c 24             	cmp    %edi,(%esp)
  8025eb:	0f 87 e7 00 00 00    	ja     8026d8 <__umoddi3+0x148>
  8025f1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8025f5:	29 f1                	sub    %esi,%ecx
  8025f7:	19 c7                	sbb    %eax,%edi
  8025f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025fd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802601:	8b 44 24 08          	mov    0x8(%esp),%eax
  802605:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802609:	83 c4 14             	add    $0x14,%esp
  80260c:	5e                   	pop    %esi
  80260d:	5f                   	pop    %edi
  80260e:	5d                   	pop    %ebp
  80260f:	c3                   	ret    
  802610:	85 f6                	test   %esi,%esi
  802612:	89 f5                	mov    %esi,%ebp
  802614:	75 0b                	jne    802621 <__umoddi3+0x91>
  802616:	b8 01 00 00 00       	mov    $0x1,%eax
  80261b:	31 d2                	xor    %edx,%edx
  80261d:	f7 f6                	div    %esi
  80261f:	89 c5                	mov    %eax,%ebp
  802621:	8b 44 24 04          	mov    0x4(%esp),%eax
  802625:	31 d2                	xor    %edx,%edx
  802627:	f7 f5                	div    %ebp
  802629:	89 c8                	mov    %ecx,%eax
  80262b:	f7 f5                	div    %ebp
  80262d:	eb 9c                	jmp    8025cb <__umoddi3+0x3b>
  80262f:	90                   	nop
  802630:	89 c8                	mov    %ecx,%eax
  802632:	89 fa                	mov    %edi,%edx
  802634:	83 c4 14             	add    $0x14,%esp
  802637:	5e                   	pop    %esi
  802638:	5f                   	pop    %edi
  802639:	5d                   	pop    %ebp
  80263a:	c3                   	ret    
  80263b:	90                   	nop
  80263c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802640:	8b 04 24             	mov    (%esp),%eax
  802643:	be 20 00 00 00       	mov    $0x20,%esi
  802648:	89 e9                	mov    %ebp,%ecx
  80264a:	29 ee                	sub    %ebp,%esi
  80264c:	d3 e2                	shl    %cl,%edx
  80264e:	89 f1                	mov    %esi,%ecx
  802650:	d3 e8                	shr    %cl,%eax
  802652:	89 e9                	mov    %ebp,%ecx
  802654:	89 44 24 04          	mov    %eax,0x4(%esp)
  802658:	8b 04 24             	mov    (%esp),%eax
  80265b:	09 54 24 04          	or     %edx,0x4(%esp)
  80265f:	89 fa                	mov    %edi,%edx
  802661:	d3 e0                	shl    %cl,%eax
  802663:	89 f1                	mov    %esi,%ecx
  802665:	89 44 24 08          	mov    %eax,0x8(%esp)
  802669:	8b 44 24 10          	mov    0x10(%esp),%eax
  80266d:	d3 ea                	shr    %cl,%edx
  80266f:	89 e9                	mov    %ebp,%ecx
  802671:	d3 e7                	shl    %cl,%edi
  802673:	89 f1                	mov    %esi,%ecx
  802675:	d3 e8                	shr    %cl,%eax
  802677:	89 e9                	mov    %ebp,%ecx
  802679:	09 f8                	or     %edi,%eax
  80267b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80267f:	f7 74 24 04          	divl   0x4(%esp)
  802683:	d3 e7                	shl    %cl,%edi
  802685:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802689:	89 d7                	mov    %edx,%edi
  80268b:	f7 64 24 08          	mull   0x8(%esp)
  80268f:	39 d7                	cmp    %edx,%edi
  802691:	89 c1                	mov    %eax,%ecx
  802693:	89 14 24             	mov    %edx,(%esp)
  802696:	72 2c                	jb     8026c4 <__umoddi3+0x134>
  802698:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80269c:	72 22                	jb     8026c0 <__umoddi3+0x130>
  80269e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8026a2:	29 c8                	sub    %ecx,%eax
  8026a4:	19 d7                	sbb    %edx,%edi
  8026a6:	89 e9                	mov    %ebp,%ecx
  8026a8:	89 fa                	mov    %edi,%edx
  8026aa:	d3 e8                	shr    %cl,%eax
  8026ac:	89 f1                	mov    %esi,%ecx
  8026ae:	d3 e2                	shl    %cl,%edx
  8026b0:	89 e9                	mov    %ebp,%ecx
  8026b2:	d3 ef                	shr    %cl,%edi
  8026b4:	09 d0                	or     %edx,%eax
  8026b6:	89 fa                	mov    %edi,%edx
  8026b8:	83 c4 14             	add    $0x14,%esp
  8026bb:	5e                   	pop    %esi
  8026bc:	5f                   	pop    %edi
  8026bd:	5d                   	pop    %ebp
  8026be:	c3                   	ret    
  8026bf:	90                   	nop
  8026c0:	39 d7                	cmp    %edx,%edi
  8026c2:	75 da                	jne    80269e <__umoddi3+0x10e>
  8026c4:	8b 14 24             	mov    (%esp),%edx
  8026c7:	89 c1                	mov    %eax,%ecx
  8026c9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8026cd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8026d1:	eb cb                	jmp    80269e <__umoddi3+0x10e>
  8026d3:	90                   	nop
  8026d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026d8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8026dc:	0f 82 0f ff ff ff    	jb     8025f1 <__umoddi3+0x61>
  8026e2:	e9 1a ff ff ff       	jmp    802601 <__umoddi3+0x71>
