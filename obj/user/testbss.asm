
obj/user/testbss.debug:     file format elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	c7 04 24 80 26 80 00 	movl   $0x802680,(%esp)
  800040:	e8 13 02 00 00       	call   800258 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
  800045:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004a:	83 3c 85 20 40 80 00 	cmpl   $0x0,0x804020(,%eax,4)
  800051:	00 
  800052:	74 20                	je     800074 <umain+0x41>
			panic("bigarray[%d] isn't cleared!\n", i);
  800054:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800058:	c7 44 24 08 fb 26 80 	movl   $0x8026fb,0x8(%esp)
  80005f:	00 
  800060:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800067:	00 
  800068:	c7 04 24 18 27 80 00 	movl   $0x802718,(%esp)
  80006f:	e8 eb 00 00 00       	call   80015f <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800074:	83 c0 01             	add    $0x1,%eax
  800077:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80007c:	75 cc                	jne    80004a <umain+0x17>
  80007e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800083:	89 04 85 20 40 80 00 	mov    %eax,0x804020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80008a:	83 c0 01             	add    $0x1,%eax
  80008d:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800092:	75 ef                	jne    800083 <umain+0x50>
  800094:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  800099:	39 04 85 20 40 80 00 	cmp    %eax,0x804020(,%eax,4)
  8000a0:	74 20                	je     8000c2 <umain+0x8f>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a6:	c7 44 24 08 a0 26 80 	movl   $0x8026a0,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 18 27 80 00 	movl   $0x802718,(%esp)
  8000bd:	e8 9d 00 00 00       	call   80015f <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000c2:	83 c0 01             	add    $0x1,%eax
  8000c5:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000ca:	75 cd                	jne    800099 <umain+0x66>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000cc:	c7 04 24 c8 26 80 00 	movl   $0x8026c8,(%esp)
  8000d3:	e8 80 01 00 00       	call   800258 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000d8:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000df:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000e2:	c7 44 24 08 27 27 80 	movl   $0x802727,0x8(%esp)
  8000e9:	00 
  8000ea:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8000f1:	00 
  8000f2:	c7 04 24 18 27 80 00 	movl   $0x802718,(%esp)
  8000f9:	e8 61 00 00 00       	call   80015f <_panic>

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	83 ec 10             	sub    $0x10,%esp
  800106:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800109:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  80010c:	e8 54 0b 00 00       	call   800c65 <sys_getenvid>
  800111:	25 ff 03 00 00       	and    $0x3ff,%eax
  800116:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800119:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011e:	a3 20 40 c0 00       	mov    %eax,0xc04020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800123:	85 db                	test   %ebx,%ebx
  800125:	7e 07                	jle    80012e <libmain+0x30>
		binaryname = argv[0];
  800127:	8b 06                	mov    (%esi),%eax
  800129:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800132:	89 1c 24             	mov    %ebx,(%esp)
  800135:	e8 f9 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80013a:	e8 07 00 00 00       	call   800146 <exit>
}
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5d                   	pop    %ebp
  800145:	c3                   	ret    

00800146 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80014c:	e8 59 10 00 00       	call   8011aa <close_all>
	sys_env_destroy(0);
  800151:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800158:	e8 b6 0a 00 00       	call   800c13 <sys_env_destroy>
}
  80015d:	c9                   	leave  
  80015e:	c3                   	ret    

0080015f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
  800164:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800167:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80016a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800170:	e8 f0 0a 00 00       	call   800c65 <sys_getenvid>
  800175:	8b 55 0c             	mov    0xc(%ebp),%edx
  800178:	89 54 24 10          	mov    %edx,0x10(%esp)
  80017c:	8b 55 08             	mov    0x8(%ebp),%edx
  80017f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800183:	89 74 24 08          	mov    %esi,0x8(%esp)
  800187:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018b:	c7 04 24 48 27 80 00 	movl   $0x802748,(%esp)
  800192:	e8 c1 00 00 00       	call   800258 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800197:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80019b:	8b 45 10             	mov    0x10(%ebp),%eax
  80019e:	89 04 24             	mov    %eax,(%esp)
  8001a1:	e8 51 00 00 00       	call   8001f7 <vcprintf>
	cprintf("\n");
  8001a6:	c7 04 24 16 27 80 00 	movl   $0x802716,(%esp)
  8001ad:	e8 a6 00 00 00       	call   800258 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b2:	cc                   	int3   
  8001b3:	eb fd                	jmp    8001b2 <_panic+0x53>

008001b5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b5:	55                   	push   %ebp
  8001b6:	89 e5                	mov    %esp,%ebp
  8001b8:	53                   	push   %ebx
  8001b9:	83 ec 14             	sub    $0x14,%esp
  8001bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001bf:	8b 13                	mov    (%ebx),%edx
  8001c1:	8d 42 01             	lea    0x1(%edx),%eax
  8001c4:	89 03                	mov    %eax,(%ebx)
  8001c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001c9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001cd:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d2:	75 19                	jne    8001ed <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001d4:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001db:	00 
  8001dc:	8d 43 08             	lea    0x8(%ebx),%eax
  8001df:	89 04 24             	mov    %eax,(%esp)
  8001e2:	e8 ef 09 00 00       	call   800bd6 <sys_cputs>
		b->idx = 0;
  8001e7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001ed:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001f1:	83 c4 14             	add    $0x14,%esp
  8001f4:	5b                   	pop    %ebx
  8001f5:	5d                   	pop    %ebp
  8001f6:	c3                   	ret    

008001f7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800200:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800207:	00 00 00 
	b.cnt = 0;
  80020a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800211:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800214:	8b 45 0c             	mov    0xc(%ebp),%eax
  800217:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021b:	8b 45 08             	mov    0x8(%ebp),%eax
  80021e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800222:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800228:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022c:	c7 04 24 b5 01 80 00 	movl   $0x8001b5,(%esp)
  800233:	e8 b6 01 00 00       	call   8003ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800238:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80023e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800242:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800248:	89 04 24             	mov    %eax,(%esp)
  80024b:	e8 86 09 00 00       	call   800bd6 <sys_cputs>

	return b.cnt;
}
  800250:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800256:	c9                   	leave  
  800257:	c3                   	ret    

00800258 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
  80025b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80025e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800261:	89 44 24 04          	mov    %eax,0x4(%esp)
  800265:	8b 45 08             	mov    0x8(%ebp),%eax
  800268:	89 04 24             	mov    %eax,(%esp)
  80026b:	e8 87 ff ff ff       	call   8001f7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800270:	c9                   	leave  
  800271:	c3                   	ret    
  800272:	66 90                	xchg   %ax,%ax
  800274:	66 90                	xchg   %ax,%ax
  800276:	66 90                	xchg   %ax,%ax
  800278:	66 90                	xchg   %ax,%ax
  80027a:	66 90                	xchg   %ax,%ax
  80027c:	66 90                	xchg   %ax,%ax
  80027e:	66 90                	xchg   %ax,%ax

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 3c             	sub    $0x3c,%esp
  800289:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80028c:	89 d7                	mov    %edx,%edi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800294:	8b 45 0c             	mov    0xc(%ebp),%eax
  800297:	89 c3                	mov    %eax,%ebx
  800299:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80029c:	8b 45 10             	mov    0x10(%ebp),%eax
  80029f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002ad:	39 d9                	cmp    %ebx,%ecx
  8002af:	72 05                	jb     8002b6 <printnum+0x36>
  8002b1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002b4:	77 69                	ja     80031f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002b9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002bd:	83 ee 01             	sub    $0x1,%esi
  8002c0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002cc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002d0:	89 c3                	mov    %eax,%ebx
  8002d2:	89 d6                	mov    %edx,%esi
  8002d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002da:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002e5:	89 04 24             	mov    %eax,(%esp)
  8002e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ef:	e8 fc 20 00 00       	call   8023f0 <__udivdi3>
  8002f4:	89 d9                	mov    %ebx,%ecx
  8002f6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002fa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002fe:	89 04 24             	mov    %eax,(%esp)
  800301:	89 54 24 04          	mov    %edx,0x4(%esp)
  800305:	89 fa                	mov    %edi,%edx
  800307:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80030a:	e8 71 ff ff ff       	call   800280 <printnum>
  80030f:	eb 1b                	jmp    80032c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800311:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800315:	8b 45 18             	mov    0x18(%ebp),%eax
  800318:	89 04 24             	mov    %eax,(%esp)
  80031b:	ff d3                	call   *%ebx
  80031d:	eb 03                	jmp    800322 <printnum+0xa2>
  80031f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800322:	83 ee 01             	sub    $0x1,%esi
  800325:	85 f6                	test   %esi,%esi
  800327:	7f e8                	jg     800311 <printnum+0x91>
  800329:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80032c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800330:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800334:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800337:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80033a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80033e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800342:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800345:	89 04 24             	mov    %eax,(%esp)
  800348:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80034b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034f:	e8 cc 21 00 00       	call   802520 <__umoddi3>
  800354:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800358:	0f be 80 6b 27 80 00 	movsbl 0x80276b(%eax),%eax
  80035f:	89 04 24             	mov    %eax,(%esp)
  800362:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800365:	ff d0                	call   *%eax
}
  800367:	83 c4 3c             	add    $0x3c,%esp
  80036a:	5b                   	pop    %ebx
  80036b:	5e                   	pop    %esi
  80036c:	5f                   	pop    %edi
  80036d:	5d                   	pop    %ebp
  80036e:	c3                   	ret    

0080036f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80036f:	55                   	push   %ebp
  800370:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800372:	83 fa 01             	cmp    $0x1,%edx
  800375:	7e 0e                	jle    800385 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800377:	8b 10                	mov    (%eax),%edx
  800379:	8d 4a 08             	lea    0x8(%edx),%ecx
  80037c:	89 08                	mov    %ecx,(%eax)
  80037e:	8b 02                	mov    (%edx),%eax
  800380:	8b 52 04             	mov    0x4(%edx),%edx
  800383:	eb 22                	jmp    8003a7 <getuint+0x38>
	else if (lflag)
  800385:	85 d2                	test   %edx,%edx
  800387:	74 10                	je     800399 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800389:	8b 10                	mov    (%eax),%edx
  80038b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80038e:	89 08                	mov    %ecx,(%eax)
  800390:	8b 02                	mov    (%edx),%eax
  800392:	ba 00 00 00 00       	mov    $0x0,%edx
  800397:	eb 0e                	jmp    8003a7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800399:	8b 10                	mov    (%eax),%edx
  80039b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80039e:	89 08                	mov    %ecx,(%eax)
  8003a0:	8b 02                	mov    (%edx),%eax
  8003a2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003a7:	5d                   	pop    %ebp
  8003a8:	c3                   	ret    

008003a9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003a9:	55                   	push   %ebp
  8003aa:	89 e5                	mov    %esp,%ebp
  8003ac:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003af:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003b3:	8b 10                	mov    (%eax),%edx
  8003b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8003b8:	73 0a                	jae    8003c4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ba:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003bd:	89 08                	mov    %ecx,(%eax)
  8003bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c2:	88 02                	mov    %al,(%edx)
}
  8003c4:	5d                   	pop    %ebp
  8003c5:	c3                   	ret    

008003c6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
  8003c9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003cc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e4:	89 04 24             	mov    %eax,(%esp)
  8003e7:	e8 02 00 00 00       	call   8003ee <vprintfmt>
	va_end(ap);
}
  8003ec:	c9                   	leave  
  8003ed:	c3                   	ret    

008003ee <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	57                   	push   %edi
  8003f2:	56                   	push   %esi
  8003f3:	53                   	push   %ebx
  8003f4:	83 ec 3c             	sub    $0x3c,%esp
  8003f7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003fd:	eb 14                	jmp    800413 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003ff:	85 c0                	test   %eax,%eax
  800401:	0f 84 b3 03 00 00    	je     8007ba <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800407:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80040b:	89 04 24             	mov    %eax,(%esp)
  80040e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800411:	89 f3                	mov    %esi,%ebx
  800413:	8d 73 01             	lea    0x1(%ebx),%esi
  800416:	0f b6 03             	movzbl (%ebx),%eax
  800419:	83 f8 25             	cmp    $0x25,%eax
  80041c:	75 e1                	jne    8003ff <vprintfmt+0x11>
  80041e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800422:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800429:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800430:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800437:	ba 00 00 00 00       	mov    $0x0,%edx
  80043c:	eb 1d                	jmp    80045b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800440:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800444:	eb 15                	jmp    80045b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800446:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800448:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80044c:	eb 0d                	jmp    80045b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80044e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800451:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800454:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80045e:	0f b6 0e             	movzbl (%esi),%ecx
  800461:	0f b6 c1             	movzbl %cl,%eax
  800464:	83 e9 23             	sub    $0x23,%ecx
  800467:	80 f9 55             	cmp    $0x55,%cl
  80046a:	0f 87 2a 03 00 00    	ja     80079a <vprintfmt+0x3ac>
  800470:	0f b6 c9             	movzbl %cl,%ecx
  800473:	ff 24 8d a0 28 80 00 	jmp    *0x8028a0(,%ecx,4)
  80047a:	89 de                	mov    %ebx,%esi
  80047c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800481:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800484:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800488:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80048b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80048e:	83 fb 09             	cmp    $0x9,%ebx
  800491:	77 36                	ja     8004c9 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800493:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800496:	eb e9                	jmp    800481 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800498:	8b 45 14             	mov    0x14(%ebp),%eax
  80049b:	8d 48 04             	lea    0x4(%eax),%ecx
  80049e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004a1:	8b 00                	mov    (%eax),%eax
  8004a3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004a8:	eb 22                	jmp    8004cc <vprintfmt+0xde>
  8004aa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004ad:	85 c9                	test   %ecx,%ecx
  8004af:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b4:	0f 49 c1             	cmovns %ecx,%eax
  8004b7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	89 de                	mov    %ebx,%esi
  8004bc:	eb 9d                	jmp    80045b <vprintfmt+0x6d>
  8004be:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004c0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004c7:	eb 92                	jmp    80045b <vprintfmt+0x6d>
  8004c9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8004cc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004d0:	79 89                	jns    80045b <vprintfmt+0x6d>
  8004d2:	e9 77 ff ff ff       	jmp    80044e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004d7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004da:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004dc:	e9 7a ff ff ff       	jmp    80045b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e4:	8d 50 04             	lea    0x4(%eax),%edx
  8004e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ea:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ee:	8b 00                	mov    (%eax),%eax
  8004f0:	89 04 24             	mov    %eax,(%esp)
  8004f3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004f6:	e9 18 ff ff ff       	jmp    800413 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fe:	8d 50 04             	lea    0x4(%eax),%edx
  800501:	89 55 14             	mov    %edx,0x14(%ebp)
  800504:	8b 00                	mov    (%eax),%eax
  800506:	99                   	cltd   
  800507:	31 d0                	xor    %edx,%eax
  800509:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80050b:	83 f8 0f             	cmp    $0xf,%eax
  80050e:	7f 0b                	jg     80051b <vprintfmt+0x12d>
  800510:	8b 14 85 00 2a 80 00 	mov    0x802a00(,%eax,4),%edx
  800517:	85 d2                	test   %edx,%edx
  800519:	75 20                	jne    80053b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80051b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80051f:	c7 44 24 08 83 27 80 	movl   $0x802783,0x8(%esp)
  800526:	00 
  800527:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80052b:	8b 45 08             	mov    0x8(%ebp),%eax
  80052e:	89 04 24             	mov    %eax,(%esp)
  800531:	e8 90 fe ff ff       	call   8003c6 <printfmt>
  800536:	e9 d8 fe ff ff       	jmp    800413 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80053b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80053f:	c7 44 24 08 35 2b 80 	movl   $0x802b35,0x8(%esp)
  800546:	00 
  800547:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80054b:	8b 45 08             	mov    0x8(%ebp),%eax
  80054e:	89 04 24             	mov    %eax,(%esp)
  800551:	e8 70 fe ff ff       	call   8003c6 <printfmt>
  800556:	e9 b8 fe ff ff       	jmp    800413 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80055e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800561:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800564:	8b 45 14             	mov    0x14(%ebp),%eax
  800567:	8d 50 04             	lea    0x4(%eax),%edx
  80056a:	89 55 14             	mov    %edx,0x14(%ebp)
  80056d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80056f:	85 f6                	test   %esi,%esi
  800571:	b8 7c 27 80 00       	mov    $0x80277c,%eax
  800576:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800579:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80057d:	0f 84 97 00 00 00    	je     80061a <vprintfmt+0x22c>
  800583:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800587:	0f 8e 9b 00 00 00    	jle    800628 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80058d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800591:	89 34 24             	mov    %esi,(%esp)
  800594:	e8 cf 02 00 00       	call   800868 <strnlen>
  800599:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80059c:	29 c2                	sub    %eax,%edx
  80059e:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8005a1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005a5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005a8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ae:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005b1:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b3:	eb 0f                	jmp    8005c4 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8005b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005bc:	89 04 24             	mov    %eax,(%esp)
  8005bf:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c1:	83 eb 01             	sub    $0x1,%ebx
  8005c4:	85 db                	test   %ebx,%ebx
  8005c6:	7f ed                	jg     8005b5 <vprintfmt+0x1c7>
  8005c8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005cb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005ce:	85 d2                	test   %edx,%edx
  8005d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d5:	0f 49 c2             	cmovns %edx,%eax
  8005d8:	29 c2                	sub    %eax,%edx
  8005da:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005dd:	89 d7                	mov    %edx,%edi
  8005df:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005e2:	eb 50                	jmp    800634 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005e4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005e8:	74 1e                	je     800608 <vprintfmt+0x21a>
  8005ea:	0f be d2             	movsbl %dl,%edx
  8005ed:	83 ea 20             	sub    $0x20,%edx
  8005f0:	83 fa 5e             	cmp    $0x5e,%edx
  8005f3:	76 13                	jbe    800608 <vprintfmt+0x21a>
					putch('?', putdat);
  8005f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005fc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800603:	ff 55 08             	call   *0x8(%ebp)
  800606:	eb 0d                	jmp    800615 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800608:	8b 55 0c             	mov    0xc(%ebp),%edx
  80060b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80060f:	89 04 24             	mov    %eax,(%esp)
  800612:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800615:	83 ef 01             	sub    $0x1,%edi
  800618:	eb 1a                	jmp    800634 <vprintfmt+0x246>
  80061a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80061d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800620:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800623:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800626:	eb 0c                	jmp    800634 <vprintfmt+0x246>
  800628:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80062b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80062e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800631:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800634:	83 c6 01             	add    $0x1,%esi
  800637:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80063b:	0f be c2             	movsbl %dl,%eax
  80063e:	85 c0                	test   %eax,%eax
  800640:	74 27                	je     800669 <vprintfmt+0x27b>
  800642:	85 db                	test   %ebx,%ebx
  800644:	78 9e                	js     8005e4 <vprintfmt+0x1f6>
  800646:	83 eb 01             	sub    $0x1,%ebx
  800649:	79 99                	jns    8005e4 <vprintfmt+0x1f6>
  80064b:	89 f8                	mov    %edi,%eax
  80064d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800650:	8b 75 08             	mov    0x8(%ebp),%esi
  800653:	89 c3                	mov    %eax,%ebx
  800655:	eb 1a                	jmp    800671 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800657:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80065b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800662:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800664:	83 eb 01             	sub    $0x1,%ebx
  800667:	eb 08                	jmp    800671 <vprintfmt+0x283>
  800669:	89 fb                	mov    %edi,%ebx
  80066b:	8b 75 08             	mov    0x8(%ebp),%esi
  80066e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800671:	85 db                	test   %ebx,%ebx
  800673:	7f e2                	jg     800657 <vprintfmt+0x269>
  800675:	89 75 08             	mov    %esi,0x8(%ebp)
  800678:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80067b:	e9 93 fd ff ff       	jmp    800413 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800680:	83 fa 01             	cmp    $0x1,%edx
  800683:	7e 16                	jle    80069b <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800685:	8b 45 14             	mov    0x14(%ebp),%eax
  800688:	8d 50 08             	lea    0x8(%eax),%edx
  80068b:	89 55 14             	mov    %edx,0x14(%ebp)
  80068e:	8b 50 04             	mov    0x4(%eax),%edx
  800691:	8b 00                	mov    (%eax),%eax
  800693:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800696:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800699:	eb 32                	jmp    8006cd <vprintfmt+0x2df>
	else if (lflag)
  80069b:	85 d2                	test   %edx,%edx
  80069d:	74 18                	je     8006b7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  80069f:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a2:	8d 50 04             	lea    0x4(%eax),%edx
  8006a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a8:	8b 30                	mov    (%eax),%esi
  8006aa:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006ad:	89 f0                	mov    %esi,%eax
  8006af:	c1 f8 1f             	sar    $0x1f,%eax
  8006b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006b5:	eb 16                	jmp    8006cd <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8006b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ba:	8d 50 04             	lea    0x4(%eax),%edx
  8006bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c0:	8b 30                	mov    (%eax),%esi
  8006c2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006c5:	89 f0                	mov    %esi,%eax
  8006c7:	c1 f8 1f             	sar    $0x1f,%eax
  8006ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006d3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006d8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006dc:	0f 89 80 00 00 00    	jns    800762 <vprintfmt+0x374>
				putch('-', putdat);
  8006e2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006e6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006ed:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006f3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006f6:	f7 d8                	neg    %eax
  8006f8:	83 d2 00             	adc    $0x0,%edx
  8006fb:	f7 da                	neg    %edx
			}
			base = 10;
  8006fd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800702:	eb 5e                	jmp    800762 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800704:	8d 45 14             	lea    0x14(%ebp),%eax
  800707:	e8 63 fc ff ff       	call   80036f <getuint>
			base = 10;
  80070c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800711:	eb 4f                	jmp    800762 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800713:	8d 45 14             	lea    0x14(%ebp),%eax
  800716:	e8 54 fc ff ff       	call   80036f <getuint>
			base = 8;
  80071b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800720:	eb 40                	jmp    800762 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800722:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800726:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80072d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800730:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800734:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80073b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80073e:	8b 45 14             	mov    0x14(%ebp),%eax
  800741:	8d 50 04             	lea    0x4(%eax),%edx
  800744:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800747:	8b 00                	mov    (%eax),%eax
  800749:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80074e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800753:	eb 0d                	jmp    800762 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800755:	8d 45 14             	lea    0x14(%ebp),%eax
  800758:	e8 12 fc ff ff       	call   80036f <getuint>
			base = 16;
  80075d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800762:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800766:	89 74 24 10          	mov    %esi,0x10(%esp)
  80076a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80076d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800771:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800775:	89 04 24             	mov    %eax,(%esp)
  800778:	89 54 24 04          	mov    %edx,0x4(%esp)
  80077c:	89 fa                	mov    %edi,%edx
  80077e:	8b 45 08             	mov    0x8(%ebp),%eax
  800781:	e8 fa fa ff ff       	call   800280 <printnum>
			break;
  800786:	e9 88 fc ff ff       	jmp    800413 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80078b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80078f:	89 04 24             	mov    %eax,(%esp)
  800792:	ff 55 08             	call   *0x8(%ebp)
			break;
  800795:	e9 79 fc ff ff       	jmp    800413 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80079a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80079e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007a5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007a8:	89 f3                	mov    %esi,%ebx
  8007aa:	eb 03                	jmp    8007af <vprintfmt+0x3c1>
  8007ac:	83 eb 01             	sub    $0x1,%ebx
  8007af:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007b3:	75 f7                	jne    8007ac <vprintfmt+0x3be>
  8007b5:	e9 59 fc ff ff       	jmp    800413 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8007ba:	83 c4 3c             	add    $0x3c,%esp
  8007bd:	5b                   	pop    %ebx
  8007be:	5e                   	pop    %esi
  8007bf:	5f                   	pop    %edi
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	83 ec 28             	sub    $0x28,%esp
  8007c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007d1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007d5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007df:	85 c0                	test   %eax,%eax
  8007e1:	74 30                	je     800813 <vsnprintf+0x51>
  8007e3:	85 d2                	test   %edx,%edx
  8007e5:	7e 2c                	jle    800813 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007f5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007fc:	c7 04 24 a9 03 80 00 	movl   $0x8003a9,(%esp)
  800803:	e8 e6 fb ff ff       	call   8003ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800808:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80080b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80080e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800811:	eb 05                	jmp    800818 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800813:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800818:	c9                   	leave  
  800819:	c3                   	ret    

0080081a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800820:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800823:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800827:	8b 45 10             	mov    0x10(%ebp),%eax
  80082a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80082e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800831:	89 44 24 04          	mov    %eax,0x4(%esp)
  800835:	8b 45 08             	mov    0x8(%ebp),%eax
  800838:	89 04 24             	mov    %eax,(%esp)
  80083b:	e8 82 ff ff ff       	call   8007c2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800840:	c9                   	leave  
  800841:	c3                   	ret    
  800842:	66 90                	xchg   %ax,%ax
  800844:	66 90                	xchg   %ax,%ax
  800846:	66 90                	xchg   %ax,%ax
  800848:	66 90                	xchg   %ax,%ax
  80084a:	66 90                	xchg   %ax,%ax
  80084c:	66 90                	xchg   %ax,%ax
  80084e:	66 90                	xchg   %ax,%ax

00800850 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800856:	b8 00 00 00 00       	mov    $0x0,%eax
  80085b:	eb 03                	jmp    800860 <strlen+0x10>
		n++;
  80085d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800860:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800864:	75 f7                	jne    80085d <strlen+0xd>
		n++;
	return n;
}
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800871:	b8 00 00 00 00       	mov    $0x0,%eax
  800876:	eb 03                	jmp    80087b <strnlen+0x13>
		n++;
  800878:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087b:	39 d0                	cmp    %edx,%eax
  80087d:	74 06                	je     800885 <strnlen+0x1d>
  80087f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800883:	75 f3                	jne    800878 <strnlen+0x10>
		n++;
	return n;
}
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	53                   	push   %ebx
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800891:	89 c2                	mov    %eax,%edx
  800893:	83 c2 01             	add    $0x1,%edx
  800896:	83 c1 01             	add    $0x1,%ecx
  800899:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80089d:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008a0:	84 db                	test   %bl,%bl
  8008a2:	75 ef                	jne    800893 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008a4:	5b                   	pop    %ebx
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	53                   	push   %ebx
  8008ab:	83 ec 08             	sub    $0x8,%esp
  8008ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008b1:	89 1c 24             	mov    %ebx,(%esp)
  8008b4:	e8 97 ff ff ff       	call   800850 <strlen>
	strcpy(dst + len, src);
  8008b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008c0:	01 d8                	add    %ebx,%eax
  8008c2:	89 04 24             	mov    %eax,(%esp)
  8008c5:	e8 bd ff ff ff       	call   800887 <strcpy>
	return dst;
}
  8008ca:	89 d8                	mov    %ebx,%eax
  8008cc:	83 c4 08             	add    $0x8,%esp
  8008cf:	5b                   	pop    %ebx
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	56                   	push   %esi
  8008d6:	53                   	push   %ebx
  8008d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008dd:	89 f3                	mov    %esi,%ebx
  8008df:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e2:	89 f2                	mov    %esi,%edx
  8008e4:	eb 0f                	jmp    8008f5 <strncpy+0x23>
		*dst++ = *src;
  8008e6:	83 c2 01             	add    $0x1,%edx
  8008e9:	0f b6 01             	movzbl (%ecx),%eax
  8008ec:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008ef:	80 39 01             	cmpb   $0x1,(%ecx)
  8008f2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f5:	39 da                	cmp    %ebx,%edx
  8008f7:	75 ed                	jne    8008e6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008f9:	89 f0                	mov    %esi,%eax
  8008fb:	5b                   	pop    %ebx
  8008fc:	5e                   	pop    %esi
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	56                   	push   %esi
  800903:	53                   	push   %ebx
  800904:	8b 75 08             	mov    0x8(%ebp),%esi
  800907:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80090d:	89 f0                	mov    %esi,%eax
  80090f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800913:	85 c9                	test   %ecx,%ecx
  800915:	75 0b                	jne    800922 <strlcpy+0x23>
  800917:	eb 1d                	jmp    800936 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800919:	83 c0 01             	add    $0x1,%eax
  80091c:	83 c2 01             	add    $0x1,%edx
  80091f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800922:	39 d8                	cmp    %ebx,%eax
  800924:	74 0b                	je     800931 <strlcpy+0x32>
  800926:	0f b6 0a             	movzbl (%edx),%ecx
  800929:	84 c9                	test   %cl,%cl
  80092b:	75 ec                	jne    800919 <strlcpy+0x1a>
  80092d:	89 c2                	mov    %eax,%edx
  80092f:	eb 02                	jmp    800933 <strlcpy+0x34>
  800931:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800933:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800936:	29 f0                	sub    %esi,%eax
}
  800938:	5b                   	pop    %ebx
  800939:	5e                   	pop    %esi
  80093a:	5d                   	pop    %ebp
  80093b:	c3                   	ret    

0080093c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800942:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800945:	eb 06                	jmp    80094d <strcmp+0x11>
		p++, q++;
  800947:	83 c1 01             	add    $0x1,%ecx
  80094a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80094d:	0f b6 01             	movzbl (%ecx),%eax
  800950:	84 c0                	test   %al,%al
  800952:	74 04                	je     800958 <strcmp+0x1c>
  800954:	3a 02                	cmp    (%edx),%al
  800956:	74 ef                	je     800947 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800958:	0f b6 c0             	movzbl %al,%eax
  80095b:	0f b6 12             	movzbl (%edx),%edx
  80095e:	29 d0                	sub    %edx,%eax
}
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	53                   	push   %ebx
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096c:	89 c3                	mov    %eax,%ebx
  80096e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800971:	eb 06                	jmp    800979 <strncmp+0x17>
		n--, p++, q++;
  800973:	83 c0 01             	add    $0x1,%eax
  800976:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800979:	39 d8                	cmp    %ebx,%eax
  80097b:	74 15                	je     800992 <strncmp+0x30>
  80097d:	0f b6 08             	movzbl (%eax),%ecx
  800980:	84 c9                	test   %cl,%cl
  800982:	74 04                	je     800988 <strncmp+0x26>
  800984:	3a 0a                	cmp    (%edx),%cl
  800986:	74 eb                	je     800973 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800988:	0f b6 00             	movzbl (%eax),%eax
  80098b:	0f b6 12             	movzbl (%edx),%edx
  80098e:	29 d0                	sub    %edx,%eax
  800990:	eb 05                	jmp    800997 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800992:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800997:	5b                   	pop    %ebx
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a4:	eb 07                	jmp    8009ad <strchr+0x13>
		if (*s == c)
  8009a6:	38 ca                	cmp    %cl,%dl
  8009a8:	74 0f                	je     8009b9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009aa:	83 c0 01             	add    $0x1,%eax
  8009ad:	0f b6 10             	movzbl (%eax),%edx
  8009b0:	84 d2                	test   %dl,%dl
  8009b2:	75 f2                	jne    8009a6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c5:	eb 07                	jmp    8009ce <strfind+0x13>
		if (*s == c)
  8009c7:	38 ca                	cmp    %cl,%dl
  8009c9:	74 0a                	je     8009d5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009cb:	83 c0 01             	add    $0x1,%eax
  8009ce:	0f b6 10             	movzbl (%eax),%edx
  8009d1:	84 d2                	test   %dl,%dl
  8009d3:	75 f2                	jne    8009c7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	57                   	push   %edi
  8009db:	56                   	push   %esi
  8009dc:	53                   	push   %ebx
  8009dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009e3:	85 c9                	test   %ecx,%ecx
  8009e5:	74 36                	je     800a1d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009e7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ed:	75 28                	jne    800a17 <memset+0x40>
  8009ef:	f6 c1 03             	test   $0x3,%cl
  8009f2:	75 23                	jne    800a17 <memset+0x40>
		c &= 0xFF;
  8009f4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009f8:	89 d3                	mov    %edx,%ebx
  8009fa:	c1 e3 08             	shl    $0x8,%ebx
  8009fd:	89 d6                	mov    %edx,%esi
  8009ff:	c1 e6 18             	shl    $0x18,%esi
  800a02:	89 d0                	mov    %edx,%eax
  800a04:	c1 e0 10             	shl    $0x10,%eax
  800a07:	09 f0                	or     %esi,%eax
  800a09:	09 c2                	or     %eax,%edx
  800a0b:	89 d0                	mov    %edx,%eax
  800a0d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a0f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a12:	fc                   	cld    
  800a13:	f3 ab                	rep stos %eax,%es:(%edi)
  800a15:	eb 06                	jmp    800a1d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1a:	fc                   	cld    
  800a1b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a1d:	89 f8                	mov    %edi,%eax
  800a1f:	5b                   	pop    %ebx
  800a20:	5e                   	pop    %esi
  800a21:	5f                   	pop    %edi
  800a22:	5d                   	pop    %ebp
  800a23:	c3                   	ret    

00800a24 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	57                   	push   %edi
  800a28:	56                   	push   %esi
  800a29:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a32:	39 c6                	cmp    %eax,%esi
  800a34:	73 35                	jae    800a6b <memmove+0x47>
  800a36:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a39:	39 d0                	cmp    %edx,%eax
  800a3b:	73 2e                	jae    800a6b <memmove+0x47>
		s += n;
		d += n;
  800a3d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a40:	89 d6                	mov    %edx,%esi
  800a42:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a44:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a4a:	75 13                	jne    800a5f <memmove+0x3b>
  800a4c:	f6 c1 03             	test   $0x3,%cl
  800a4f:	75 0e                	jne    800a5f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a51:	83 ef 04             	sub    $0x4,%edi
  800a54:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a57:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a5a:	fd                   	std    
  800a5b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5d:	eb 09                	jmp    800a68 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a5f:	83 ef 01             	sub    $0x1,%edi
  800a62:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a65:	fd                   	std    
  800a66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a68:	fc                   	cld    
  800a69:	eb 1d                	jmp    800a88 <memmove+0x64>
  800a6b:	89 f2                	mov    %esi,%edx
  800a6d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6f:	f6 c2 03             	test   $0x3,%dl
  800a72:	75 0f                	jne    800a83 <memmove+0x5f>
  800a74:	f6 c1 03             	test   $0x3,%cl
  800a77:	75 0a                	jne    800a83 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a79:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a7c:	89 c7                	mov    %eax,%edi
  800a7e:	fc                   	cld    
  800a7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a81:	eb 05                	jmp    800a88 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a83:	89 c7                	mov    %eax,%edi
  800a85:	fc                   	cld    
  800a86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a88:	5e                   	pop    %esi
  800a89:	5f                   	pop    %edi
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a92:	8b 45 10             	mov    0x10(%ebp),%eax
  800a95:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa3:	89 04 24             	mov    %eax,(%esp)
  800aa6:	e8 79 ff ff ff       	call   800a24 <memmove>
}
  800aab:	c9                   	leave  
  800aac:	c3                   	ret    

00800aad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	56                   	push   %esi
  800ab1:	53                   	push   %ebx
  800ab2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab8:	89 d6                	mov    %edx,%esi
  800aba:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800abd:	eb 1a                	jmp    800ad9 <memcmp+0x2c>
		if (*s1 != *s2)
  800abf:	0f b6 02             	movzbl (%edx),%eax
  800ac2:	0f b6 19             	movzbl (%ecx),%ebx
  800ac5:	38 d8                	cmp    %bl,%al
  800ac7:	74 0a                	je     800ad3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ac9:	0f b6 c0             	movzbl %al,%eax
  800acc:	0f b6 db             	movzbl %bl,%ebx
  800acf:	29 d8                	sub    %ebx,%eax
  800ad1:	eb 0f                	jmp    800ae2 <memcmp+0x35>
		s1++, s2++;
  800ad3:	83 c2 01             	add    $0x1,%edx
  800ad6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad9:	39 f2                	cmp    %esi,%edx
  800adb:	75 e2                	jne    800abf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800add:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae2:	5b                   	pop    %ebx
  800ae3:	5e                   	pop    %esi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aef:	89 c2                	mov    %eax,%edx
  800af1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800af4:	eb 07                	jmp    800afd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af6:	38 08                	cmp    %cl,(%eax)
  800af8:	74 07                	je     800b01 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800afa:	83 c0 01             	add    $0x1,%eax
  800afd:	39 d0                	cmp    %edx,%eax
  800aff:	72 f5                	jb     800af6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	57                   	push   %edi
  800b07:	56                   	push   %esi
  800b08:	53                   	push   %ebx
  800b09:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0f:	eb 03                	jmp    800b14 <strtol+0x11>
		s++;
  800b11:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b14:	0f b6 0a             	movzbl (%edx),%ecx
  800b17:	80 f9 09             	cmp    $0x9,%cl
  800b1a:	74 f5                	je     800b11 <strtol+0xe>
  800b1c:	80 f9 20             	cmp    $0x20,%cl
  800b1f:	74 f0                	je     800b11 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b21:	80 f9 2b             	cmp    $0x2b,%cl
  800b24:	75 0a                	jne    800b30 <strtol+0x2d>
		s++;
  800b26:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b29:	bf 00 00 00 00       	mov    $0x0,%edi
  800b2e:	eb 11                	jmp    800b41 <strtol+0x3e>
  800b30:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b35:	80 f9 2d             	cmp    $0x2d,%cl
  800b38:	75 07                	jne    800b41 <strtol+0x3e>
		s++, neg = 1;
  800b3a:	8d 52 01             	lea    0x1(%edx),%edx
  800b3d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b41:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b46:	75 15                	jne    800b5d <strtol+0x5a>
  800b48:	80 3a 30             	cmpb   $0x30,(%edx)
  800b4b:	75 10                	jne    800b5d <strtol+0x5a>
  800b4d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b51:	75 0a                	jne    800b5d <strtol+0x5a>
		s += 2, base = 16;
  800b53:	83 c2 02             	add    $0x2,%edx
  800b56:	b8 10 00 00 00       	mov    $0x10,%eax
  800b5b:	eb 10                	jmp    800b6d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800b5d:	85 c0                	test   %eax,%eax
  800b5f:	75 0c                	jne    800b6d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b61:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b63:	80 3a 30             	cmpb   $0x30,(%edx)
  800b66:	75 05                	jne    800b6d <strtol+0x6a>
		s++, base = 8;
  800b68:	83 c2 01             	add    $0x1,%edx
  800b6b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800b6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b72:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b75:	0f b6 0a             	movzbl (%edx),%ecx
  800b78:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b7b:	89 f0                	mov    %esi,%eax
  800b7d:	3c 09                	cmp    $0x9,%al
  800b7f:	77 08                	ja     800b89 <strtol+0x86>
			dig = *s - '0';
  800b81:	0f be c9             	movsbl %cl,%ecx
  800b84:	83 e9 30             	sub    $0x30,%ecx
  800b87:	eb 20                	jmp    800ba9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b89:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b8c:	89 f0                	mov    %esi,%eax
  800b8e:	3c 19                	cmp    $0x19,%al
  800b90:	77 08                	ja     800b9a <strtol+0x97>
			dig = *s - 'a' + 10;
  800b92:	0f be c9             	movsbl %cl,%ecx
  800b95:	83 e9 57             	sub    $0x57,%ecx
  800b98:	eb 0f                	jmp    800ba9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800b9a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b9d:	89 f0                	mov    %esi,%eax
  800b9f:	3c 19                	cmp    $0x19,%al
  800ba1:	77 16                	ja     800bb9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800ba3:	0f be c9             	movsbl %cl,%ecx
  800ba6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ba9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800bac:	7d 0f                	jge    800bbd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800bae:	83 c2 01             	add    $0x1,%edx
  800bb1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800bb5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800bb7:	eb bc                	jmp    800b75 <strtol+0x72>
  800bb9:	89 d8                	mov    %ebx,%eax
  800bbb:	eb 02                	jmp    800bbf <strtol+0xbc>
  800bbd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800bbf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc3:	74 05                	je     800bca <strtol+0xc7>
		*endptr = (char *) s;
  800bc5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800bca:	f7 d8                	neg    %eax
  800bcc:	85 ff                	test   %edi,%edi
  800bce:	0f 44 c3             	cmove  %ebx,%eax
}
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdc:	b8 00 00 00 00       	mov    $0x0,%eax
  800be1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be4:	8b 55 08             	mov    0x8(%ebp),%edx
  800be7:	89 c3                	mov    %eax,%ebx
  800be9:	89 c7                	mov    %eax,%edi
  800beb:	89 c6                	mov    %eax,%esi
  800bed:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bef:	5b                   	pop    %ebx
  800bf0:	5e                   	pop    %esi
  800bf1:	5f                   	pop    %edi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfa:	ba 00 00 00 00       	mov    $0x0,%edx
  800bff:	b8 01 00 00 00       	mov    $0x1,%eax
  800c04:	89 d1                	mov    %edx,%ecx
  800c06:	89 d3                	mov    %edx,%ebx
  800c08:	89 d7                	mov    %edx,%edi
  800c0a:	89 d6                	mov    %edx,%esi
  800c0c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	5f                   	pop    %edi
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	57                   	push   %edi
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
  800c19:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c21:	b8 03 00 00 00       	mov    $0x3,%eax
  800c26:	8b 55 08             	mov    0x8(%ebp),%edx
  800c29:	89 cb                	mov    %ecx,%ebx
  800c2b:	89 cf                	mov    %ecx,%edi
  800c2d:	89 ce                	mov    %ecx,%esi
  800c2f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c31:	85 c0                	test   %eax,%eax
  800c33:	7e 28                	jle    800c5d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c35:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c39:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c40:	00 
  800c41:	c7 44 24 08 5f 2a 80 	movl   $0x802a5f,0x8(%esp)
  800c48:	00 
  800c49:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c50:	00 
  800c51:	c7 04 24 7c 2a 80 00 	movl   $0x802a7c,(%esp)
  800c58:	e8 02 f5 ff ff       	call   80015f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c5d:	83 c4 2c             	add    $0x2c,%esp
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	57                   	push   %edi
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c70:	b8 02 00 00 00       	mov    $0x2,%eax
  800c75:	89 d1                	mov    %edx,%ecx
  800c77:	89 d3                	mov    %edx,%ebx
  800c79:	89 d7                	mov    %edx,%edi
  800c7b:	89 d6                	mov    %edx,%esi
  800c7d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <sys_yield>:

void
sys_yield(void)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c94:	89 d1                	mov    %edx,%ecx
  800c96:	89 d3                	mov    %edx,%ebx
  800c98:	89 d7                	mov    %edx,%edi
  800c9a:	89 d6                	mov    %edx,%esi
  800c9c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c9e:	5b                   	pop    %ebx
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	57                   	push   %edi
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
  800ca9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cac:	be 00 00 00 00       	mov    $0x0,%esi
  800cb1:	b8 04 00 00 00       	mov    $0x4,%eax
  800cb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbf:	89 f7                	mov    %esi,%edi
  800cc1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc3:	85 c0                	test   %eax,%eax
  800cc5:	7e 28                	jle    800cef <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ccb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cd2:	00 
  800cd3:	c7 44 24 08 5f 2a 80 	movl   $0x802a5f,0x8(%esp)
  800cda:	00 
  800cdb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce2:	00 
  800ce3:	c7 04 24 7c 2a 80 00 	movl   $0x802a7c,(%esp)
  800cea:	e8 70 f4 ff ff       	call   80015f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cef:	83 c4 2c             	add    $0x2c,%esp
  800cf2:	5b                   	pop    %ebx
  800cf3:	5e                   	pop    %esi
  800cf4:	5f                   	pop    %edi
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    

00800cf7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	57                   	push   %edi
  800cfb:	56                   	push   %esi
  800cfc:	53                   	push   %ebx
  800cfd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d00:	b8 05 00 00 00       	mov    $0x5,%eax
  800d05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d08:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d0e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d11:	8b 75 18             	mov    0x18(%ebp),%esi
  800d14:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d16:	85 c0                	test   %eax,%eax
  800d18:	7e 28                	jle    800d42 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d1e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d25:	00 
  800d26:	c7 44 24 08 5f 2a 80 	movl   $0x802a5f,0x8(%esp)
  800d2d:	00 
  800d2e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d35:	00 
  800d36:	c7 04 24 7c 2a 80 00 	movl   $0x802a7c,(%esp)
  800d3d:	e8 1d f4 ff ff       	call   80015f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d42:	83 c4 2c             	add    $0x2c,%esp
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	57                   	push   %edi
  800d4e:	56                   	push   %esi
  800d4f:	53                   	push   %ebx
  800d50:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d58:	b8 06 00 00 00       	mov    $0x6,%eax
  800d5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d60:	8b 55 08             	mov    0x8(%ebp),%edx
  800d63:	89 df                	mov    %ebx,%edi
  800d65:	89 de                	mov    %ebx,%esi
  800d67:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	7e 28                	jle    800d95 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d71:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d78:	00 
  800d79:	c7 44 24 08 5f 2a 80 	movl   $0x802a5f,0x8(%esp)
  800d80:	00 
  800d81:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d88:	00 
  800d89:	c7 04 24 7c 2a 80 00 	movl   $0x802a7c,(%esp)
  800d90:	e8 ca f3 ff ff       	call   80015f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d95:	83 c4 2c             	add    $0x2c,%esp
  800d98:	5b                   	pop    %ebx
  800d99:	5e                   	pop    %esi
  800d9a:	5f                   	pop    %edi
  800d9b:	5d                   	pop    %ebp
  800d9c:	c3                   	ret    

00800d9d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	57                   	push   %edi
  800da1:	56                   	push   %esi
  800da2:	53                   	push   %ebx
  800da3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dab:	b8 08 00 00 00       	mov    $0x8,%eax
  800db0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db3:	8b 55 08             	mov    0x8(%ebp),%edx
  800db6:	89 df                	mov    %ebx,%edi
  800db8:	89 de                	mov    %ebx,%esi
  800dba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbc:	85 c0                	test   %eax,%eax
  800dbe:	7e 28                	jle    800de8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dcb:	00 
  800dcc:	c7 44 24 08 5f 2a 80 	movl   $0x802a5f,0x8(%esp)
  800dd3:	00 
  800dd4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ddb:	00 
  800ddc:	c7 04 24 7c 2a 80 00 	movl   $0x802a7c,(%esp)
  800de3:	e8 77 f3 ff ff       	call   80015f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800de8:	83 c4 2c             	add    $0x2c,%esp
  800deb:	5b                   	pop    %ebx
  800dec:	5e                   	pop    %esi
  800ded:	5f                   	pop    %edi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	57                   	push   %edi
  800df4:	56                   	push   %esi
  800df5:	53                   	push   %ebx
  800df6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfe:	b8 09 00 00 00       	mov    $0x9,%eax
  800e03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e06:	8b 55 08             	mov    0x8(%ebp),%edx
  800e09:	89 df                	mov    %ebx,%edi
  800e0b:	89 de                	mov    %ebx,%esi
  800e0d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	7e 28                	jle    800e3b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e13:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e17:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e1e:	00 
  800e1f:	c7 44 24 08 5f 2a 80 	movl   $0x802a5f,0x8(%esp)
  800e26:	00 
  800e27:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e2e:	00 
  800e2f:	c7 04 24 7c 2a 80 00 	movl   $0x802a7c,(%esp)
  800e36:	e8 24 f3 ff ff       	call   80015f <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e3b:	83 c4 2c             	add    $0x2c,%esp
  800e3e:	5b                   	pop    %ebx
  800e3f:	5e                   	pop    %esi
  800e40:	5f                   	pop    %edi
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    

00800e43 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	57                   	push   %edi
  800e47:	56                   	push   %esi
  800e48:	53                   	push   %ebx
  800e49:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e51:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e59:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5c:	89 df                	mov    %ebx,%edi
  800e5e:	89 de                	mov    %ebx,%esi
  800e60:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e62:	85 c0                	test   %eax,%eax
  800e64:	7e 28                	jle    800e8e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e66:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e6a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e71:	00 
  800e72:	c7 44 24 08 5f 2a 80 	movl   $0x802a5f,0x8(%esp)
  800e79:	00 
  800e7a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e81:	00 
  800e82:	c7 04 24 7c 2a 80 00 	movl   $0x802a7c,(%esp)
  800e89:	e8 d1 f2 ff ff       	call   80015f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e8e:	83 c4 2c             	add    $0x2c,%esp
  800e91:	5b                   	pop    %ebx
  800e92:	5e                   	pop    %esi
  800e93:	5f                   	pop    %edi
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	57                   	push   %edi
  800e9a:	56                   	push   %esi
  800e9b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9c:	be 00 00 00 00       	mov    $0x0,%esi
  800ea1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ea6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea9:	8b 55 08             	mov    0x8(%ebp),%edx
  800eac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eaf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eb2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    

00800eb9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	57                   	push   %edi
  800ebd:	56                   	push   %esi
  800ebe:	53                   	push   %ebx
  800ebf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ec7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ecc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecf:	89 cb                	mov    %ecx,%ebx
  800ed1:	89 cf                	mov    %ecx,%edi
  800ed3:	89 ce                	mov    %ecx,%esi
  800ed5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ed7:	85 c0                	test   %eax,%eax
  800ed9:	7e 28                	jle    800f03 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800edb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800edf:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ee6:	00 
  800ee7:	c7 44 24 08 5f 2a 80 	movl   $0x802a5f,0x8(%esp)
  800eee:	00 
  800eef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef6:	00 
  800ef7:	c7 04 24 7c 2a 80 00 	movl   $0x802a7c,(%esp)
  800efe:	e8 5c f2 ff ff       	call   80015f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f03:	83 c4 2c             	add    $0x2c,%esp
  800f06:	5b                   	pop    %ebx
  800f07:	5e                   	pop    %esi
  800f08:	5f                   	pop    %edi
  800f09:	5d                   	pop    %ebp
  800f0a:	c3                   	ret    

00800f0b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	57                   	push   %edi
  800f0f:	56                   	push   %esi
  800f10:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f11:	ba 00 00 00 00       	mov    $0x0,%edx
  800f16:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f1b:	89 d1                	mov    %edx,%ecx
  800f1d:	89 d3                	mov    %edx,%ebx
  800f1f:	89 d7                	mov    %edx,%edi
  800f21:	89 d6                	mov    %edx,%esi
  800f23:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f25:	5b                   	pop    %ebx
  800f26:	5e                   	pop    %esi
  800f27:	5f                   	pop    %edi
  800f28:	5d                   	pop    %ebp
  800f29:	c3                   	ret    

00800f2a <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  800f2a:	55                   	push   %ebp
  800f2b:	89 e5                	mov    %esp,%ebp
  800f2d:	57                   	push   %edi
  800f2e:	56                   	push   %esi
  800f2f:	53                   	push   %ebx
  800f30:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f38:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f40:	8b 55 08             	mov    0x8(%ebp),%edx
  800f43:	89 df                	mov    %ebx,%edi
  800f45:	89 de                	mov    %ebx,%esi
  800f47:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f49:	85 c0                	test   %eax,%eax
  800f4b:	7e 28                	jle    800f75 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f51:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800f58:	00 
  800f59:	c7 44 24 08 5f 2a 80 	movl   $0x802a5f,0x8(%esp)
  800f60:	00 
  800f61:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f68:	00 
  800f69:	c7 04 24 7c 2a 80 00 	movl   $0x802a7c,(%esp)
  800f70:	e8 ea f1 ff ff       	call   80015f <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  800f75:	83 c4 2c             	add    $0x2c,%esp
  800f78:	5b                   	pop    %ebx
  800f79:	5e                   	pop    %esi
  800f7a:	5f                   	pop    %edi
  800f7b:	5d                   	pop    %ebp
  800f7c:	c3                   	ret    

00800f7d <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	57                   	push   %edi
  800f81:	56                   	push   %esi
  800f82:	53                   	push   %ebx
  800f83:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f86:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f8b:	b8 10 00 00 00       	mov    $0x10,%eax
  800f90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f93:	8b 55 08             	mov    0x8(%ebp),%edx
  800f96:	89 df                	mov    %ebx,%edi
  800f98:	89 de                	mov    %ebx,%esi
  800f9a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	7e 28                	jle    800fc8 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fa0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fa4:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  800fab:	00 
  800fac:	c7 44 24 08 5f 2a 80 	movl   $0x802a5f,0x8(%esp)
  800fb3:	00 
  800fb4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fbb:	00 
  800fbc:	c7 04 24 7c 2a 80 00 	movl   $0x802a7c,(%esp)
  800fc3:	e8 97 f1 ff ff       	call   80015f <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  800fc8:	83 c4 2c             	add    $0x2c,%esp
  800fcb:	5b                   	pop    %ebx
  800fcc:	5e                   	pop    %esi
  800fcd:	5f                   	pop    %edi
  800fce:	5d                   	pop    %ebp
  800fcf:	c3                   	ret    

00800fd0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd6:	05 00 00 00 30       	add    $0x30000000,%eax
  800fdb:	c1 e8 0c             	shr    $0xc,%eax
}
  800fde:	5d                   	pop    %ebp
  800fdf:	c3                   	ret    

00800fe0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fe3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800feb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ff0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ff5:	5d                   	pop    %ebp
  800ff6:	c3                   	ret    

00800ff7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ffd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801002:	89 c2                	mov    %eax,%edx
  801004:	c1 ea 16             	shr    $0x16,%edx
  801007:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80100e:	f6 c2 01             	test   $0x1,%dl
  801011:	74 11                	je     801024 <fd_alloc+0x2d>
  801013:	89 c2                	mov    %eax,%edx
  801015:	c1 ea 0c             	shr    $0xc,%edx
  801018:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80101f:	f6 c2 01             	test   $0x1,%dl
  801022:	75 09                	jne    80102d <fd_alloc+0x36>
			*fd_store = fd;
  801024:	89 01                	mov    %eax,(%ecx)
			return 0;
  801026:	b8 00 00 00 00       	mov    $0x0,%eax
  80102b:	eb 17                	jmp    801044 <fd_alloc+0x4d>
  80102d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801032:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801037:	75 c9                	jne    801002 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801039:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80103f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801044:	5d                   	pop    %ebp
  801045:	c3                   	ret    

00801046 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801046:	55                   	push   %ebp
  801047:	89 e5                	mov    %esp,%ebp
  801049:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80104c:	83 f8 1f             	cmp    $0x1f,%eax
  80104f:	77 36                	ja     801087 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801051:	c1 e0 0c             	shl    $0xc,%eax
  801054:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801059:	89 c2                	mov    %eax,%edx
  80105b:	c1 ea 16             	shr    $0x16,%edx
  80105e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801065:	f6 c2 01             	test   $0x1,%dl
  801068:	74 24                	je     80108e <fd_lookup+0x48>
  80106a:	89 c2                	mov    %eax,%edx
  80106c:	c1 ea 0c             	shr    $0xc,%edx
  80106f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801076:	f6 c2 01             	test   $0x1,%dl
  801079:	74 1a                	je     801095 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80107b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80107e:	89 02                	mov    %eax,(%edx)
	return 0;
  801080:	b8 00 00 00 00       	mov    $0x0,%eax
  801085:	eb 13                	jmp    80109a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801087:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80108c:	eb 0c                	jmp    80109a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80108e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801093:	eb 05                	jmp    80109a <fd_lookup+0x54>
  801095:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80109a:	5d                   	pop    %ebp
  80109b:	c3                   	ret    

0080109c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	83 ec 18             	sub    $0x18,%esp
  8010a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8010a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8010aa:	eb 13                	jmp    8010bf <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8010ac:	39 08                	cmp    %ecx,(%eax)
  8010ae:	75 0c                	jne    8010bc <dev_lookup+0x20>
			*dev = devtab[i];
  8010b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ba:	eb 38                	jmp    8010f4 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8010bc:	83 c2 01             	add    $0x1,%edx
  8010bf:	8b 04 95 08 2b 80 00 	mov    0x802b08(,%edx,4),%eax
  8010c6:	85 c0                	test   %eax,%eax
  8010c8:	75 e2                	jne    8010ac <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8010ca:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8010cf:	8b 40 48             	mov    0x48(%eax),%eax
  8010d2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010da:	c7 04 24 8c 2a 80 00 	movl   $0x802a8c,(%esp)
  8010e1:	e8 72 f1 ff ff       	call   800258 <cprintf>
	*dev = 0;
  8010e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010e9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8010ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010f4:	c9                   	leave  
  8010f5:	c3                   	ret    

008010f6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8010f6:	55                   	push   %ebp
  8010f7:	89 e5                	mov    %esp,%ebp
  8010f9:	56                   	push   %esi
  8010fa:	53                   	push   %ebx
  8010fb:	83 ec 20             	sub    $0x20,%esp
  8010fe:	8b 75 08             	mov    0x8(%ebp),%esi
  801101:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801104:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801107:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80110b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801111:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801114:	89 04 24             	mov    %eax,(%esp)
  801117:	e8 2a ff ff ff       	call   801046 <fd_lookup>
  80111c:	85 c0                	test   %eax,%eax
  80111e:	78 05                	js     801125 <fd_close+0x2f>
	    || fd != fd2)
  801120:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801123:	74 0c                	je     801131 <fd_close+0x3b>
		return (must_exist ? r : 0);
  801125:	84 db                	test   %bl,%bl
  801127:	ba 00 00 00 00       	mov    $0x0,%edx
  80112c:	0f 44 c2             	cmove  %edx,%eax
  80112f:	eb 3f                	jmp    801170 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801131:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801134:	89 44 24 04          	mov    %eax,0x4(%esp)
  801138:	8b 06                	mov    (%esi),%eax
  80113a:	89 04 24             	mov    %eax,(%esp)
  80113d:	e8 5a ff ff ff       	call   80109c <dev_lookup>
  801142:	89 c3                	mov    %eax,%ebx
  801144:	85 c0                	test   %eax,%eax
  801146:	78 16                	js     80115e <fd_close+0x68>
		if (dev->dev_close)
  801148:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80114b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80114e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801153:	85 c0                	test   %eax,%eax
  801155:	74 07                	je     80115e <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801157:	89 34 24             	mov    %esi,(%esp)
  80115a:	ff d0                	call   *%eax
  80115c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80115e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801162:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801169:	e8 dc fb ff ff       	call   800d4a <sys_page_unmap>
	return r;
  80116e:	89 d8                	mov    %ebx,%eax
}
  801170:	83 c4 20             	add    $0x20,%esp
  801173:	5b                   	pop    %ebx
  801174:	5e                   	pop    %esi
  801175:	5d                   	pop    %ebp
  801176:	c3                   	ret    

00801177 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80117d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801180:	89 44 24 04          	mov    %eax,0x4(%esp)
  801184:	8b 45 08             	mov    0x8(%ebp),%eax
  801187:	89 04 24             	mov    %eax,(%esp)
  80118a:	e8 b7 fe ff ff       	call   801046 <fd_lookup>
  80118f:	89 c2                	mov    %eax,%edx
  801191:	85 d2                	test   %edx,%edx
  801193:	78 13                	js     8011a8 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801195:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80119c:	00 
  80119d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a0:	89 04 24             	mov    %eax,(%esp)
  8011a3:	e8 4e ff ff ff       	call   8010f6 <fd_close>
}
  8011a8:	c9                   	leave  
  8011a9:	c3                   	ret    

008011aa <close_all>:

void
close_all(void)
{
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
  8011ad:	53                   	push   %ebx
  8011ae:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011b1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011b6:	89 1c 24             	mov    %ebx,(%esp)
  8011b9:	e8 b9 ff ff ff       	call   801177 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8011be:	83 c3 01             	add    $0x1,%ebx
  8011c1:	83 fb 20             	cmp    $0x20,%ebx
  8011c4:	75 f0                	jne    8011b6 <close_all+0xc>
		close(i);
}
  8011c6:	83 c4 14             	add    $0x14,%esp
  8011c9:	5b                   	pop    %ebx
  8011ca:	5d                   	pop    %ebp
  8011cb:	c3                   	ret    

008011cc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	57                   	push   %edi
  8011d0:	56                   	push   %esi
  8011d1:	53                   	push   %ebx
  8011d2:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011d5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8011df:	89 04 24             	mov    %eax,(%esp)
  8011e2:	e8 5f fe ff ff       	call   801046 <fd_lookup>
  8011e7:	89 c2                	mov    %eax,%edx
  8011e9:	85 d2                	test   %edx,%edx
  8011eb:	0f 88 e1 00 00 00    	js     8012d2 <dup+0x106>
		return r;
	close(newfdnum);
  8011f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011f4:	89 04 24             	mov    %eax,(%esp)
  8011f7:	e8 7b ff ff ff       	call   801177 <close>

	newfd = INDEX2FD(newfdnum);
  8011fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011ff:	c1 e3 0c             	shl    $0xc,%ebx
  801202:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801208:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80120b:	89 04 24             	mov    %eax,(%esp)
  80120e:	e8 cd fd ff ff       	call   800fe0 <fd2data>
  801213:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801215:	89 1c 24             	mov    %ebx,(%esp)
  801218:	e8 c3 fd ff ff       	call   800fe0 <fd2data>
  80121d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80121f:	89 f0                	mov    %esi,%eax
  801221:	c1 e8 16             	shr    $0x16,%eax
  801224:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80122b:	a8 01                	test   $0x1,%al
  80122d:	74 43                	je     801272 <dup+0xa6>
  80122f:	89 f0                	mov    %esi,%eax
  801231:	c1 e8 0c             	shr    $0xc,%eax
  801234:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80123b:	f6 c2 01             	test   $0x1,%dl
  80123e:	74 32                	je     801272 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801240:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801247:	25 07 0e 00 00       	and    $0xe07,%eax
  80124c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801250:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801254:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80125b:	00 
  80125c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801260:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801267:	e8 8b fa ff ff       	call   800cf7 <sys_page_map>
  80126c:	89 c6                	mov    %eax,%esi
  80126e:	85 c0                	test   %eax,%eax
  801270:	78 3e                	js     8012b0 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801272:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801275:	89 c2                	mov    %eax,%edx
  801277:	c1 ea 0c             	shr    $0xc,%edx
  80127a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801281:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801287:	89 54 24 10          	mov    %edx,0x10(%esp)
  80128b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80128f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801296:	00 
  801297:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012a2:	e8 50 fa ff ff       	call   800cf7 <sys_page_map>
  8012a7:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8012a9:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012ac:	85 f6                	test   %esi,%esi
  8012ae:	79 22                	jns    8012d2 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012bb:	e8 8a fa ff ff       	call   800d4a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012cb:	e8 7a fa ff ff       	call   800d4a <sys_page_unmap>
	return r;
  8012d0:	89 f0                	mov    %esi,%eax
}
  8012d2:	83 c4 3c             	add    $0x3c,%esp
  8012d5:	5b                   	pop    %ebx
  8012d6:	5e                   	pop    %esi
  8012d7:	5f                   	pop    %edi
  8012d8:	5d                   	pop    %ebp
  8012d9:	c3                   	ret    

008012da <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	53                   	push   %ebx
  8012de:	83 ec 24             	sub    $0x24,%esp
  8012e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012eb:	89 1c 24             	mov    %ebx,(%esp)
  8012ee:	e8 53 fd ff ff       	call   801046 <fd_lookup>
  8012f3:	89 c2                	mov    %eax,%edx
  8012f5:	85 d2                	test   %edx,%edx
  8012f7:	78 6d                	js     801366 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801300:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801303:	8b 00                	mov    (%eax),%eax
  801305:	89 04 24             	mov    %eax,(%esp)
  801308:	e8 8f fd ff ff       	call   80109c <dev_lookup>
  80130d:	85 c0                	test   %eax,%eax
  80130f:	78 55                	js     801366 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801311:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801314:	8b 50 08             	mov    0x8(%eax),%edx
  801317:	83 e2 03             	and    $0x3,%edx
  80131a:	83 fa 01             	cmp    $0x1,%edx
  80131d:	75 23                	jne    801342 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80131f:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801324:	8b 40 48             	mov    0x48(%eax),%eax
  801327:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80132b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80132f:	c7 04 24 cd 2a 80 00 	movl   $0x802acd,(%esp)
  801336:	e8 1d ef ff ff       	call   800258 <cprintf>
		return -E_INVAL;
  80133b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801340:	eb 24                	jmp    801366 <read+0x8c>
	}
	if (!dev->dev_read)
  801342:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801345:	8b 52 08             	mov    0x8(%edx),%edx
  801348:	85 d2                	test   %edx,%edx
  80134a:	74 15                	je     801361 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80134c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80134f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801353:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801356:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80135a:	89 04 24             	mov    %eax,(%esp)
  80135d:	ff d2                	call   *%edx
  80135f:	eb 05                	jmp    801366 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801361:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801366:	83 c4 24             	add    $0x24,%esp
  801369:	5b                   	pop    %ebx
  80136a:	5d                   	pop    %ebp
  80136b:	c3                   	ret    

0080136c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80136c:	55                   	push   %ebp
  80136d:	89 e5                	mov    %esp,%ebp
  80136f:	57                   	push   %edi
  801370:	56                   	push   %esi
  801371:	53                   	push   %ebx
  801372:	83 ec 1c             	sub    $0x1c,%esp
  801375:	8b 7d 08             	mov    0x8(%ebp),%edi
  801378:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80137b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801380:	eb 23                	jmp    8013a5 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801382:	89 f0                	mov    %esi,%eax
  801384:	29 d8                	sub    %ebx,%eax
  801386:	89 44 24 08          	mov    %eax,0x8(%esp)
  80138a:	89 d8                	mov    %ebx,%eax
  80138c:	03 45 0c             	add    0xc(%ebp),%eax
  80138f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801393:	89 3c 24             	mov    %edi,(%esp)
  801396:	e8 3f ff ff ff       	call   8012da <read>
		if (m < 0)
  80139b:	85 c0                	test   %eax,%eax
  80139d:	78 10                	js     8013af <readn+0x43>
			return m;
		if (m == 0)
  80139f:	85 c0                	test   %eax,%eax
  8013a1:	74 0a                	je     8013ad <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013a3:	01 c3                	add    %eax,%ebx
  8013a5:	39 f3                	cmp    %esi,%ebx
  8013a7:	72 d9                	jb     801382 <readn+0x16>
  8013a9:	89 d8                	mov    %ebx,%eax
  8013ab:	eb 02                	jmp    8013af <readn+0x43>
  8013ad:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013af:	83 c4 1c             	add    $0x1c,%esp
  8013b2:	5b                   	pop    %ebx
  8013b3:	5e                   	pop    %esi
  8013b4:	5f                   	pop    %edi
  8013b5:	5d                   	pop    %ebp
  8013b6:	c3                   	ret    

008013b7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013b7:	55                   	push   %ebp
  8013b8:	89 e5                	mov    %esp,%ebp
  8013ba:	53                   	push   %ebx
  8013bb:	83 ec 24             	sub    $0x24,%esp
  8013be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c8:	89 1c 24             	mov    %ebx,(%esp)
  8013cb:	e8 76 fc ff ff       	call   801046 <fd_lookup>
  8013d0:	89 c2                	mov    %eax,%edx
  8013d2:	85 d2                	test   %edx,%edx
  8013d4:	78 68                	js     80143e <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e0:	8b 00                	mov    (%eax),%eax
  8013e2:	89 04 24             	mov    %eax,(%esp)
  8013e5:	e8 b2 fc ff ff       	call   80109c <dev_lookup>
  8013ea:	85 c0                	test   %eax,%eax
  8013ec:	78 50                	js     80143e <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013f5:	75 23                	jne    80141a <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013f7:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8013fc:	8b 40 48             	mov    0x48(%eax),%eax
  8013ff:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801403:	89 44 24 04          	mov    %eax,0x4(%esp)
  801407:	c7 04 24 e9 2a 80 00 	movl   $0x802ae9,(%esp)
  80140e:	e8 45 ee ff ff       	call   800258 <cprintf>
		return -E_INVAL;
  801413:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801418:	eb 24                	jmp    80143e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80141a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80141d:	8b 52 0c             	mov    0xc(%edx),%edx
  801420:	85 d2                	test   %edx,%edx
  801422:	74 15                	je     801439 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801424:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801427:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80142b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80142e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801432:	89 04 24             	mov    %eax,(%esp)
  801435:	ff d2                	call   *%edx
  801437:	eb 05                	jmp    80143e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801439:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80143e:	83 c4 24             	add    $0x24,%esp
  801441:	5b                   	pop    %ebx
  801442:	5d                   	pop    %ebp
  801443:	c3                   	ret    

00801444 <seek>:

int
seek(int fdnum, off_t offset)
{
  801444:	55                   	push   %ebp
  801445:	89 e5                	mov    %esp,%ebp
  801447:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80144a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80144d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801451:	8b 45 08             	mov    0x8(%ebp),%eax
  801454:	89 04 24             	mov    %eax,(%esp)
  801457:	e8 ea fb ff ff       	call   801046 <fd_lookup>
  80145c:	85 c0                	test   %eax,%eax
  80145e:	78 0e                	js     80146e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801460:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801463:	8b 55 0c             	mov    0xc(%ebp),%edx
  801466:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801469:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80146e:	c9                   	leave  
  80146f:	c3                   	ret    

00801470 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	53                   	push   %ebx
  801474:	83 ec 24             	sub    $0x24,%esp
  801477:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80147a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80147d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801481:	89 1c 24             	mov    %ebx,(%esp)
  801484:	e8 bd fb ff ff       	call   801046 <fd_lookup>
  801489:	89 c2                	mov    %eax,%edx
  80148b:	85 d2                	test   %edx,%edx
  80148d:	78 61                	js     8014f0 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801492:	89 44 24 04          	mov    %eax,0x4(%esp)
  801496:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801499:	8b 00                	mov    (%eax),%eax
  80149b:	89 04 24             	mov    %eax,(%esp)
  80149e:	e8 f9 fb ff ff       	call   80109c <dev_lookup>
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	78 49                	js     8014f0 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014aa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014ae:	75 23                	jne    8014d3 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014b0:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014b5:	8b 40 48             	mov    0x48(%eax),%eax
  8014b8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c0:	c7 04 24 ac 2a 80 00 	movl   $0x802aac,(%esp)
  8014c7:	e8 8c ed ff ff       	call   800258 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014d1:	eb 1d                	jmp    8014f0 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8014d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014d6:	8b 52 18             	mov    0x18(%edx),%edx
  8014d9:	85 d2                	test   %edx,%edx
  8014db:	74 0e                	je     8014eb <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014e0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014e4:	89 04 24             	mov    %eax,(%esp)
  8014e7:	ff d2                	call   *%edx
  8014e9:	eb 05                	jmp    8014f0 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8014eb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8014f0:	83 c4 24             	add    $0x24,%esp
  8014f3:	5b                   	pop    %ebx
  8014f4:	5d                   	pop    %ebp
  8014f5:	c3                   	ret    

008014f6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014f6:	55                   	push   %ebp
  8014f7:	89 e5                	mov    %esp,%ebp
  8014f9:	53                   	push   %ebx
  8014fa:	83 ec 24             	sub    $0x24,%esp
  8014fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801500:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801503:	89 44 24 04          	mov    %eax,0x4(%esp)
  801507:	8b 45 08             	mov    0x8(%ebp),%eax
  80150a:	89 04 24             	mov    %eax,(%esp)
  80150d:	e8 34 fb ff ff       	call   801046 <fd_lookup>
  801512:	89 c2                	mov    %eax,%edx
  801514:	85 d2                	test   %edx,%edx
  801516:	78 52                	js     80156a <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801518:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80151f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801522:	8b 00                	mov    (%eax),%eax
  801524:	89 04 24             	mov    %eax,(%esp)
  801527:	e8 70 fb ff ff       	call   80109c <dev_lookup>
  80152c:	85 c0                	test   %eax,%eax
  80152e:	78 3a                	js     80156a <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801530:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801533:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801537:	74 2c                	je     801565 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801539:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80153c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801543:	00 00 00 
	stat->st_isdir = 0;
  801546:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80154d:	00 00 00 
	stat->st_dev = dev;
  801550:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801556:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80155a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80155d:	89 14 24             	mov    %edx,(%esp)
  801560:	ff 50 14             	call   *0x14(%eax)
  801563:	eb 05                	jmp    80156a <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801565:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80156a:	83 c4 24             	add    $0x24,%esp
  80156d:	5b                   	pop    %ebx
  80156e:	5d                   	pop    %ebp
  80156f:	c3                   	ret    

00801570 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	56                   	push   %esi
  801574:	53                   	push   %ebx
  801575:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801578:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80157f:	00 
  801580:	8b 45 08             	mov    0x8(%ebp),%eax
  801583:	89 04 24             	mov    %eax,(%esp)
  801586:	e8 28 02 00 00       	call   8017b3 <open>
  80158b:	89 c3                	mov    %eax,%ebx
  80158d:	85 db                	test   %ebx,%ebx
  80158f:	78 1b                	js     8015ac <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801591:	8b 45 0c             	mov    0xc(%ebp),%eax
  801594:	89 44 24 04          	mov    %eax,0x4(%esp)
  801598:	89 1c 24             	mov    %ebx,(%esp)
  80159b:	e8 56 ff ff ff       	call   8014f6 <fstat>
  8015a0:	89 c6                	mov    %eax,%esi
	close(fd);
  8015a2:	89 1c 24             	mov    %ebx,(%esp)
  8015a5:	e8 cd fb ff ff       	call   801177 <close>
	return r;
  8015aa:	89 f0                	mov    %esi,%eax
}
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	5b                   	pop    %ebx
  8015b0:	5e                   	pop    %esi
  8015b1:	5d                   	pop    %ebp
  8015b2:	c3                   	ret    

008015b3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015b3:	55                   	push   %ebp
  8015b4:	89 e5                	mov    %esp,%ebp
  8015b6:	56                   	push   %esi
  8015b7:	53                   	push   %ebx
  8015b8:	83 ec 10             	sub    $0x10,%esp
  8015bb:	89 c6                	mov    %eax,%esi
  8015bd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015bf:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015c6:	75 11                	jne    8015d9 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015c8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8015cf:	e8 a1 0d 00 00       	call   802375 <ipc_find_env>
  8015d4:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015d9:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8015e0:	00 
  8015e1:	c7 44 24 08 00 50 c0 	movl   $0xc05000,0x8(%esp)
  8015e8:	00 
  8015e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015ed:	a1 00 40 80 00       	mov    0x804000,%eax
  8015f2:	89 04 24             	mov    %eax,(%esp)
  8015f5:	e8 10 0d 00 00       	call   80230a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015fa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801601:	00 
  801602:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801606:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80160d:	e8 7e 0c 00 00       	call   802290 <ipc_recv>
}
  801612:	83 c4 10             	add    $0x10,%esp
  801615:	5b                   	pop    %ebx
  801616:	5e                   	pop    %esi
  801617:	5d                   	pop    %ebp
  801618:	c3                   	ret    

00801619 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801619:	55                   	push   %ebp
  80161a:	89 e5                	mov    %esp,%ebp
  80161c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80161f:	8b 45 08             	mov    0x8(%ebp),%eax
  801622:	8b 40 0c             	mov    0xc(%eax),%eax
  801625:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  80162a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80162d:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801632:	ba 00 00 00 00       	mov    $0x0,%edx
  801637:	b8 02 00 00 00       	mov    $0x2,%eax
  80163c:	e8 72 ff ff ff       	call   8015b3 <fsipc>
}
  801641:	c9                   	leave  
  801642:	c3                   	ret    

00801643 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801643:	55                   	push   %ebp
  801644:	89 e5                	mov    %esp,%ebp
  801646:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801649:	8b 45 08             	mov    0x8(%ebp),%eax
  80164c:	8b 40 0c             	mov    0xc(%eax),%eax
  80164f:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  801654:	ba 00 00 00 00       	mov    $0x0,%edx
  801659:	b8 06 00 00 00       	mov    $0x6,%eax
  80165e:	e8 50 ff ff ff       	call   8015b3 <fsipc>
}
  801663:	c9                   	leave  
  801664:	c3                   	ret    

00801665 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801665:	55                   	push   %ebp
  801666:	89 e5                	mov    %esp,%ebp
  801668:	53                   	push   %ebx
  801669:	83 ec 14             	sub    $0x14,%esp
  80166c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80166f:	8b 45 08             	mov    0x8(%ebp),%eax
  801672:	8b 40 0c             	mov    0xc(%eax),%eax
  801675:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80167a:	ba 00 00 00 00       	mov    $0x0,%edx
  80167f:	b8 05 00 00 00       	mov    $0x5,%eax
  801684:	e8 2a ff ff ff       	call   8015b3 <fsipc>
  801689:	89 c2                	mov    %eax,%edx
  80168b:	85 d2                	test   %edx,%edx
  80168d:	78 2b                	js     8016ba <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80168f:	c7 44 24 04 00 50 c0 	movl   $0xc05000,0x4(%esp)
  801696:	00 
  801697:	89 1c 24             	mov    %ebx,(%esp)
  80169a:	e8 e8 f1 ff ff       	call   800887 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80169f:	a1 80 50 c0 00       	mov    0xc05080,%eax
  8016a4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016aa:	a1 84 50 c0 00       	mov    0xc05084,%eax
  8016af:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016ba:	83 c4 14             	add    $0x14,%esp
  8016bd:	5b                   	pop    %ebx
  8016be:	5d                   	pop    %ebp
  8016bf:	c3                   	ret    

008016c0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	83 ec 18             	sub    $0x18,%esp
  8016c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8016c9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8016ce:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8016d3:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8016d9:	8b 52 0c             	mov    0xc(%edx),%edx
  8016dc:	89 15 00 50 c0 00    	mov    %edx,0xc05000
	fsipcbuf.write.req_n = n;
  8016e2:	a3 04 50 c0 00       	mov    %eax,0xc05004

	memmove(fsipcbuf.write.req_buf, buf, n);
  8016e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f2:	c7 04 24 08 50 c0 00 	movl   $0xc05008,(%esp)
  8016f9:	e8 26 f3 ff ff       	call   800a24 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  8016fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801703:	b8 04 00 00 00       	mov    $0x4,%eax
  801708:	e8 a6 fe ff ff       	call   8015b3 <fsipc>
}
  80170d:	c9                   	leave  
  80170e:	c3                   	ret    

0080170f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	56                   	push   %esi
  801713:	53                   	push   %ebx
  801714:	83 ec 10             	sub    $0x10,%esp
  801717:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80171a:	8b 45 08             	mov    0x8(%ebp),%eax
  80171d:	8b 40 0c             	mov    0xc(%eax),%eax
  801720:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  801725:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80172b:	ba 00 00 00 00       	mov    $0x0,%edx
  801730:	b8 03 00 00 00       	mov    $0x3,%eax
  801735:	e8 79 fe ff ff       	call   8015b3 <fsipc>
  80173a:	89 c3                	mov    %eax,%ebx
  80173c:	85 c0                	test   %eax,%eax
  80173e:	78 6a                	js     8017aa <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801740:	39 c6                	cmp    %eax,%esi
  801742:	73 24                	jae    801768 <devfile_read+0x59>
  801744:	c7 44 24 0c 1c 2b 80 	movl   $0x802b1c,0xc(%esp)
  80174b:	00 
  80174c:	c7 44 24 08 23 2b 80 	movl   $0x802b23,0x8(%esp)
  801753:	00 
  801754:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80175b:	00 
  80175c:	c7 04 24 38 2b 80 00 	movl   $0x802b38,(%esp)
  801763:	e8 f7 e9 ff ff       	call   80015f <_panic>
	assert(r <= PGSIZE);
  801768:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80176d:	7e 24                	jle    801793 <devfile_read+0x84>
  80176f:	c7 44 24 0c 43 2b 80 	movl   $0x802b43,0xc(%esp)
  801776:	00 
  801777:	c7 44 24 08 23 2b 80 	movl   $0x802b23,0x8(%esp)
  80177e:	00 
  80177f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801786:	00 
  801787:	c7 04 24 38 2b 80 00 	movl   $0x802b38,(%esp)
  80178e:	e8 cc e9 ff ff       	call   80015f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801793:	89 44 24 08          	mov    %eax,0x8(%esp)
  801797:	c7 44 24 04 00 50 c0 	movl   $0xc05000,0x4(%esp)
  80179e:	00 
  80179f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a2:	89 04 24             	mov    %eax,(%esp)
  8017a5:	e8 7a f2 ff ff       	call   800a24 <memmove>
	return r;
}
  8017aa:	89 d8                	mov    %ebx,%eax
  8017ac:	83 c4 10             	add    $0x10,%esp
  8017af:	5b                   	pop    %ebx
  8017b0:	5e                   	pop    %esi
  8017b1:	5d                   	pop    %ebp
  8017b2:	c3                   	ret    

008017b3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	53                   	push   %ebx
  8017b7:	83 ec 24             	sub    $0x24,%esp
  8017ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017bd:	89 1c 24             	mov    %ebx,(%esp)
  8017c0:	e8 8b f0 ff ff       	call   800850 <strlen>
  8017c5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017ca:	7f 60                	jg     80182c <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017cf:	89 04 24             	mov    %eax,(%esp)
  8017d2:	e8 20 f8 ff ff       	call   800ff7 <fd_alloc>
  8017d7:	89 c2                	mov    %eax,%edx
  8017d9:	85 d2                	test   %edx,%edx
  8017db:	78 54                	js     801831 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017e1:	c7 04 24 00 50 c0 00 	movl   $0xc05000,(%esp)
  8017e8:	e8 9a f0 ff ff       	call   800887 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f0:	a3 00 54 c0 00       	mov    %eax,0xc05400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017f8:	b8 01 00 00 00       	mov    $0x1,%eax
  8017fd:	e8 b1 fd ff ff       	call   8015b3 <fsipc>
  801802:	89 c3                	mov    %eax,%ebx
  801804:	85 c0                	test   %eax,%eax
  801806:	79 17                	jns    80181f <open+0x6c>
		fd_close(fd, 0);
  801808:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80180f:	00 
  801810:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801813:	89 04 24             	mov    %eax,(%esp)
  801816:	e8 db f8 ff ff       	call   8010f6 <fd_close>
		return r;
  80181b:	89 d8                	mov    %ebx,%eax
  80181d:	eb 12                	jmp    801831 <open+0x7e>
	}

	return fd2num(fd);
  80181f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801822:	89 04 24             	mov    %eax,(%esp)
  801825:	e8 a6 f7 ff ff       	call   800fd0 <fd2num>
  80182a:	eb 05                	jmp    801831 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80182c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801831:	83 c4 24             	add    $0x24,%esp
  801834:	5b                   	pop    %ebx
  801835:	5d                   	pop    %ebp
  801836:	c3                   	ret    

00801837 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80183d:	ba 00 00 00 00       	mov    $0x0,%edx
  801842:	b8 08 00 00 00       	mov    $0x8,%eax
  801847:	e8 67 fd ff ff       	call   8015b3 <fsipc>
}
  80184c:	c9                   	leave  
  80184d:	c3                   	ret    
  80184e:	66 90                	xchg   %ax,%ax

00801850 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801856:	c7 44 24 04 4f 2b 80 	movl   $0x802b4f,0x4(%esp)
  80185d:	00 
  80185e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801861:	89 04 24             	mov    %eax,(%esp)
  801864:	e8 1e f0 ff ff       	call   800887 <strcpy>
	return 0;
}
  801869:	b8 00 00 00 00       	mov    $0x0,%eax
  80186e:	c9                   	leave  
  80186f:	c3                   	ret    

00801870 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	53                   	push   %ebx
  801874:	83 ec 14             	sub    $0x14,%esp
  801877:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80187a:	89 1c 24             	mov    %ebx,(%esp)
  80187d:	e8 2b 0b 00 00       	call   8023ad <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801882:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801887:	83 f8 01             	cmp    $0x1,%eax
  80188a:	75 0d                	jne    801899 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80188c:	8b 43 0c             	mov    0xc(%ebx),%eax
  80188f:	89 04 24             	mov    %eax,(%esp)
  801892:	e8 29 03 00 00       	call   801bc0 <nsipc_close>
  801897:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  801899:	89 d0                	mov    %edx,%eax
  80189b:	83 c4 14             	add    $0x14,%esp
  80189e:	5b                   	pop    %ebx
  80189f:	5d                   	pop    %ebp
  8018a0:	c3                   	ret    

008018a1 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8018a1:	55                   	push   %ebp
  8018a2:	89 e5                	mov    %esp,%ebp
  8018a4:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8018a7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8018ae:	00 
  8018af:	8b 45 10             	mov    0x10(%ebp),%eax
  8018b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c3:	89 04 24             	mov    %eax,(%esp)
  8018c6:	e8 f0 03 00 00       	call   801cbb <nsipc_send>
}
  8018cb:	c9                   	leave  
  8018cc:	c3                   	ret    

008018cd <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8018cd:	55                   	push   %ebp
  8018ce:	89 e5                	mov    %esp,%ebp
  8018d0:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8018d3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8018da:	00 
  8018db:	8b 45 10             	mov    0x10(%ebp),%eax
  8018de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ec:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ef:	89 04 24             	mov    %eax,(%esp)
  8018f2:	e8 44 03 00 00       	call   801c3b <nsipc_recv>
}
  8018f7:	c9                   	leave  
  8018f8:	c3                   	ret    

008018f9 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8018f9:	55                   	push   %ebp
  8018fa:	89 e5                	mov    %esp,%ebp
  8018fc:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8018ff:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801902:	89 54 24 04          	mov    %edx,0x4(%esp)
  801906:	89 04 24             	mov    %eax,(%esp)
  801909:	e8 38 f7 ff ff       	call   801046 <fd_lookup>
  80190e:	85 c0                	test   %eax,%eax
  801910:	78 17                	js     801929 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801912:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801915:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80191b:	39 08                	cmp    %ecx,(%eax)
  80191d:	75 05                	jne    801924 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80191f:	8b 40 0c             	mov    0xc(%eax),%eax
  801922:	eb 05                	jmp    801929 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801924:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801929:	c9                   	leave  
  80192a:	c3                   	ret    

0080192b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80192b:	55                   	push   %ebp
  80192c:	89 e5                	mov    %esp,%ebp
  80192e:	56                   	push   %esi
  80192f:	53                   	push   %ebx
  801930:	83 ec 20             	sub    $0x20,%esp
  801933:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801935:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801938:	89 04 24             	mov    %eax,(%esp)
  80193b:	e8 b7 f6 ff ff       	call   800ff7 <fd_alloc>
  801940:	89 c3                	mov    %eax,%ebx
  801942:	85 c0                	test   %eax,%eax
  801944:	78 21                	js     801967 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801946:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80194d:	00 
  80194e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801951:	89 44 24 04          	mov    %eax,0x4(%esp)
  801955:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80195c:	e8 42 f3 ff ff       	call   800ca3 <sys_page_alloc>
  801961:	89 c3                	mov    %eax,%ebx
  801963:	85 c0                	test   %eax,%eax
  801965:	79 0c                	jns    801973 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  801967:	89 34 24             	mov    %esi,(%esp)
  80196a:	e8 51 02 00 00       	call   801bc0 <nsipc_close>
		return r;
  80196f:	89 d8                	mov    %ebx,%eax
  801971:	eb 20                	jmp    801993 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801973:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801979:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80197c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80197e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801981:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801988:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  80198b:	89 14 24             	mov    %edx,(%esp)
  80198e:	e8 3d f6 ff ff       	call   800fd0 <fd2num>
}
  801993:	83 c4 20             	add    $0x20,%esp
  801996:	5b                   	pop    %ebx
  801997:	5e                   	pop    %esi
  801998:	5d                   	pop    %ebp
  801999:	c3                   	ret    

0080199a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
  80199d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a3:	e8 51 ff ff ff       	call   8018f9 <fd2sockid>
		return r;
  8019a8:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019aa:	85 c0                	test   %eax,%eax
  8019ac:	78 23                	js     8019d1 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019ae:	8b 55 10             	mov    0x10(%ebp),%edx
  8019b1:	89 54 24 08          	mov    %edx,0x8(%esp)
  8019b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019b8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019bc:	89 04 24             	mov    %eax,(%esp)
  8019bf:	e8 45 01 00 00       	call   801b09 <nsipc_accept>
		return r;
  8019c4:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019c6:	85 c0                	test   %eax,%eax
  8019c8:	78 07                	js     8019d1 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  8019ca:	e8 5c ff ff ff       	call   80192b <alloc_sockfd>
  8019cf:	89 c1                	mov    %eax,%ecx
}
  8019d1:	89 c8                	mov    %ecx,%eax
  8019d3:	c9                   	leave  
  8019d4:	c3                   	ret    

008019d5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8019d5:	55                   	push   %ebp
  8019d6:	89 e5                	mov    %esp,%ebp
  8019d8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019db:	8b 45 08             	mov    0x8(%ebp),%eax
  8019de:	e8 16 ff ff ff       	call   8018f9 <fd2sockid>
  8019e3:	89 c2                	mov    %eax,%edx
  8019e5:	85 d2                	test   %edx,%edx
  8019e7:	78 16                	js     8019ff <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  8019e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8019ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f7:	89 14 24             	mov    %edx,(%esp)
  8019fa:	e8 60 01 00 00       	call   801b5f <nsipc_bind>
}
  8019ff:	c9                   	leave  
  801a00:	c3                   	ret    

00801a01 <shutdown>:

int
shutdown(int s, int how)
{
  801a01:	55                   	push   %ebp
  801a02:	89 e5                	mov    %esp,%ebp
  801a04:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a07:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0a:	e8 ea fe ff ff       	call   8018f9 <fd2sockid>
  801a0f:	89 c2                	mov    %eax,%edx
  801a11:	85 d2                	test   %edx,%edx
  801a13:	78 0f                	js     801a24 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801a15:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a18:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a1c:	89 14 24             	mov    %edx,(%esp)
  801a1f:	e8 7a 01 00 00       	call   801b9e <nsipc_shutdown>
}
  801a24:	c9                   	leave  
  801a25:	c3                   	ret    

00801a26 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a26:	55                   	push   %ebp
  801a27:	89 e5                	mov    %esp,%ebp
  801a29:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2f:	e8 c5 fe ff ff       	call   8018f9 <fd2sockid>
  801a34:	89 c2                	mov    %eax,%edx
  801a36:	85 d2                	test   %edx,%edx
  801a38:	78 16                	js     801a50 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  801a3a:	8b 45 10             	mov    0x10(%ebp),%eax
  801a3d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a41:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a44:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a48:	89 14 24             	mov    %edx,(%esp)
  801a4b:	e8 8a 01 00 00       	call   801bda <nsipc_connect>
}
  801a50:	c9                   	leave  
  801a51:	c3                   	ret    

00801a52 <listen>:

int
listen(int s, int backlog)
{
  801a52:	55                   	push   %ebp
  801a53:	89 e5                	mov    %esp,%ebp
  801a55:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a58:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5b:	e8 99 fe ff ff       	call   8018f9 <fd2sockid>
  801a60:	89 c2                	mov    %eax,%edx
  801a62:	85 d2                	test   %edx,%edx
  801a64:	78 0f                	js     801a75 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801a66:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a69:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a6d:	89 14 24             	mov    %edx,(%esp)
  801a70:	e8 a4 01 00 00       	call   801c19 <nsipc_listen>
}
  801a75:	c9                   	leave  
  801a76:	c3                   	ret    

00801a77 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801a77:	55                   	push   %ebp
  801a78:	89 e5                	mov    %esp,%ebp
  801a7a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a7d:	8b 45 10             	mov    0x10(%ebp),%eax
  801a80:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a84:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a87:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8e:	89 04 24             	mov    %eax,(%esp)
  801a91:	e8 98 02 00 00       	call   801d2e <nsipc_socket>
  801a96:	89 c2                	mov    %eax,%edx
  801a98:	85 d2                	test   %edx,%edx
  801a9a:	78 05                	js     801aa1 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  801a9c:	e8 8a fe ff ff       	call   80192b <alloc_sockfd>
}
  801aa1:	c9                   	leave  
  801aa2:	c3                   	ret    

00801aa3 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801aa3:	55                   	push   %ebp
  801aa4:	89 e5                	mov    %esp,%ebp
  801aa6:	53                   	push   %ebx
  801aa7:	83 ec 14             	sub    $0x14,%esp
  801aaa:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801aac:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801ab3:	75 11                	jne    801ac6 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801ab5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801abc:	e8 b4 08 00 00       	call   802375 <ipc_find_env>
  801ac1:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ac6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801acd:	00 
  801ace:	c7 44 24 08 00 60 c0 	movl   $0xc06000,0x8(%esp)
  801ad5:	00 
  801ad6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ada:	a1 04 40 80 00       	mov    0x804004,%eax
  801adf:	89 04 24             	mov    %eax,(%esp)
  801ae2:	e8 23 08 00 00       	call   80230a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ae7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801aee:	00 
  801aef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801af6:	00 
  801af7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801afe:	e8 8d 07 00 00       	call   802290 <ipc_recv>
}
  801b03:	83 c4 14             	add    $0x14,%esp
  801b06:	5b                   	pop    %ebx
  801b07:	5d                   	pop    %ebp
  801b08:	c3                   	ret    

00801b09 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b09:	55                   	push   %ebp
  801b0a:	89 e5                	mov    %esp,%ebp
  801b0c:	56                   	push   %esi
  801b0d:	53                   	push   %ebx
  801b0e:	83 ec 10             	sub    $0x10,%esp
  801b11:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801b14:	8b 45 08             	mov    0x8(%ebp),%eax
  801b17:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801b1c:	8b 06                	mov    (%esi),%eax
  801b1e:	a3 04 60 c0 00       	mov    %eax,0xc06004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801b23:	b8 01 00 00 00       	mov    $0x1,%eax
  801b28:	e8 76 ff ff ff       	call   801aa3 <nsipc>
  801b2d:	89 c3                	mov    %eax,%ebx
  801b2f:	85 c0                	test   %eax,%eax
  801b31:	78 23                	js     801b56 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801b33:	a1 10 60 c0 00       	mov    0xc06010,%eax
  801b38:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b3c:	c7 44 24 04 00 60 c0 	movl   $0xc06000,0x4(%esp)
  801b43:	00 
  801b44:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b47:	89 04 24             	mov    %eax,(%esp)
  801b4a:	e8 d5 ee ff ff       	call   800a24 <memmove>
		*addrlen = ret->ret_addrlen;
  801b4f:	a1 10 60 c0 00       	mov    0xc06010,%eax
  801b54:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801b56:	89 d8                	mov    %ebx,%eax
  801b58:	83 c4 10             	add    $0x10,%esp
  801b5b:	5b                   	pop    %ebx
  801b5c:	5e                   	pop    %esi
  801b5d:	5d                   	pop    %ebp
  801b5e:	c3                   	ret    

00801b5f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b5f:	55                   	push   %ebp
  801b60:	89 e5                	mov    %esp,%ebp
  801b62:	53                   	push   %ebx
  801b63:	83 ec 14             	sub    $0x14,%esp
  801b66:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801b69:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6c:	a3 00 60 c0 00       	mov    %eax,0xc06000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b71:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b75:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b78:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b7c:	c7 04 24 04 60 c0 00 	movl   $0xc06004,(%esp)
  801b83:	e8 9c ee ff ff       	call   800a24 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b88:	89 1d 14 60 c0 00    	mov    %ebx,0xc06014
	return nsipc(NSREQ_BIND);
  801b8e:	b8 02 00 00 00       	mov    $0x2,%eax
  801b93:	e8 0b ff ff ff       	call   801aa3 <nsipc>
}
  801b98:	83 c4 14             	add    $0x14,%esp
  801b9b:	5b                   	pop    %ebx
  801b9c:	5d                   	pop    %ebp
  801b9d:	c3                   	ret    

00801b9e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b9e:	55                   	push   %ebp
  801b9f:	89 e5                	mov    %esp,%ebp
  801ba1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ba4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba7:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.shutdown.req_how = how;
  801bac:	8b 45 0c             	mov    0xc(%ebp),%eax
  801baf:	a3 04 60 c0 00       	mov    %eax,0xc06004
	return nsipc(NSREQ_SHUTDOWN);
  801bb4:	b8 03 00 00 00       	mov    $0x3,%eax
  801bb9:	e8 e5 fe ff ff       	call   801aa3 <nsipc>
}
  801bbe:	c9                   	leave  
  801bbf:	c3                   	ret    

00801bc0 <nsipc_close>:

int
nsipc_close(int s)
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801bc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc9:	a3 00 60 c0 00       	mov    %eax,0xc06000
	return nsipc(NSREQ_CLOSE);
  801bce:	b8 04 00 00 00       	mov    $0x4,%eax
  801bd3:	e8 cb fe ff ff       	call   801aa3 <nsipc>
}
  801bd8:	c9                   	leave  
  801bd9:	c3                   	ret    

00801bda <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801bda:	55                   	push   %ebp
  801bdb:	89 e5                	mov    %esp,%ebp
  801bdd:	53                   	push   %ebx
  801bde:	83 ec 14             	sub    $0x14,%esp
  801be1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801be4:	8b 45 08             	mov    0x8(%ebp),%eax
  801be7:	a3 00 60 c0 00       	mov    %eax,0xc06000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801bec:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bf0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf7:	c7 04 24 04 60 c0 00 	movl   $0xc06004,(%esp)
  801bfe:	e8 21 ee ff ff       	call   800a24 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801c03:	89 1d 14 60 c0 00    	mov    %ebx,0xc06014
	return nsipc(NSREQ_CONNECT);
  801c09:	b8 05 00 00 00       	mov    $0x5,%eax
  801c0e:	e8 90 fe ff ff       	call   801aa3 <nsipc>
}
  801c13:	83 c4 14             	add    $0x14,%esp
  801c16:	5b                   	pop    %ebx
  801c17:	5d                   	pop    %ebp
  801c18:	c3                   	ret    

00801c19 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801c19:	55                   	push   %ebp
  801c1a:	89 e5                	mov    %esp,%ebp
  801c1c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c22:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.listen.req_backlog = backlog;
  801c27:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c2a:	a3 04 60 c0 00       	mov    %eax,0xc06004
	return nsipc(NSREQ_LISTEN);
  801c2f:	b8 06 00 00 00       	mov    $0x6,%eax
  801c34:	e8 6a fe ff ff       	call   801aa3 <nsipc>
}
  801c39:	c9                   	leave  
  801c3a:	c3                   	ret    

00801c3b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801c3b:	55                   	push   %ebp
  801c3c:	89 e5                	mov    %esp,%ebp
  801c3e:	56                   	push   %esi
  801c3f:	53                   	push   %ebx
  801c40:	83 ec 10             	sub    $0x10,%esp
  801c43:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801c46:	8b 45 08             	mov    0x8(%ebp),%eax
  801c49:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.recv.req_len = len;
  801c4e:	89 35 04 60 c0 00    	mov    %esi,0xc06004
	nsipcbuf.recv.req_flags = flags;
  801c54:	8b 45 14             	mov    0x14(%ebp),%eax
  801c57:	a3 08 60 c0 00       	mov    %eax,0xc06008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801c5c:	b8 07 00 00 00       	mov    $0x7,%eax
  801c61:	e8 3d fe ff ff       	call   801aa3 <nsipc>
  801c66:	89 c3                	mov    %eax,%ebx
  801c68:	85 c0                	test   %eax,%eax
  801c6a:	78 46                	js     801cb2 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801c6c:	39 f0                	cmp    %esi,%eax
  801c6e:	7f 07                	jg     801c77 <nsipc_recv+0x3c>
  801c70:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801c75:	7e 24                	jle    801c9b <nsipc_recv+0x60>
  801c77:	c7 44 24 0c 5b 2b 80 	movl   $0x802b5b,0xc(%esp)
  801c7e:	00 
  801c7f:	c7 44 24 08 23 2b 80 	movl   $0x802b23,0x8(%esp)
  801c86:	00 
  801c87:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801c8e:	00 
  801c8f:	c7 04 24 70 2b 80 00 	movl   $0x802b70,(%esp)
  801c96:	e8 c4 e4 ff ff       	call   80015f <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c9b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c9f:	c7 44 24 04 00 60 c0 	movl   $0xc06000,0x4(%esp)
  801ca6:	00 
  801ca7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801caa:	89 04 24             	mov    %eax,(%esp)
  801cad:	e8 72 ed ff ff       	call   800a24 <memmove>
	}

	return r;
}
  801cb2:	89 d8                	mov    %ebx,%eax
  801cb4:	83 c4 10             	add    $0x10,%esp
  801cb7:	5b                   	pop    %ebx
  801cb8:	5e                   	pop    %esi
  801cb9:	5d                   	pop    %ebp
  801cba:	c3                   	ret    

00801cbb <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801cbb:	55                   	push   %ebp
  801cbc:	89 e5                	mov    %esp,%ebp
  801cbe:	53                   	push   %ebx
  801cbf:	83 ec 14             	sub    $0x14,%esp
  801cc2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801cc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc8:	a3 00 60 c0 00       	mov    %eax,0xc06000
	assert(size < 1600);
  801ccd:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801cd3:	7e 24                	jle    801cf9 <nsipc_send+0x3e>
  801cd5:	c7 44 24 0c 7c 2b 80 	movl   $0x802b7c,0xc(%esp)
  801cdc:	00 
  801cdd:	c7 44 24 08 23 2b 80 	movl   $0x802b23,0x8(%esp)
  801ce4:	00 
  801ce5:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801cec:	00 
  801ced:	c7 04 24 70 2b 80 00 	movl   $0x802b70,(%esp)
  801cf4:	e8 66 e4 ff ff       	call   80015f <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801cf9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cfd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d00:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d04:	c7 04 24 0c 60 c0 00 	movl   $0xc0600c,(%esp)
  801d0b:	e8 14 ed ff ff       	call   800a24 <memmove>
	nsipcbuf.send.req_size = size;
  801d10:	89 1d 04 60 c0 00    	mov    %ebx,0xc06004
	nsipcbuf.send.req_flags = flags;
  801d16:	8b 45 14             	mov    0x14(%ebp),%eax
  801d19:	a3 08 60 c0 00       	mov    %eax,0xc06008
	return nsipc(NSREQ_SEND);
  801d1e:	b8 08 00 00 00       	mov    $0x8,%eax
  801d23:	e8 7b fd ff ff       	call   801aa3 <nsipc>
}
  801d28:	83 c4 14             	add    $0x14,%esp
  801d2b:	5b                   	pop    %ebx
  801d2c:	5d                   	pop    %ebp
  801d2d:	c3                   	ret    

00801d2e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801d2e:	55                   	push   %ebp
  801d2f:	89 e5                	mov    %esp,%ebp
  801d31:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d34:	8b 45 08             	mov    0x8(%ebp),%eax
  801d37:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.socket.req_type = type;
  801d3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d3f:	a3 04 60 c0 00       	mov    %eax,0xc06004
	nsipcbuf.socket.req_protocol = protocol;
  801d44:	8b 45 10             	mov    0x10(%ebp),%eax
  801d47:	a3 08 60 c0 00       	mov    %eax,0xc06008
	return nsipc(NSREQ_SOCKET);
  801d4c:	b8 09 00 00 00       	mov    $0x9,%eax
  801d51:	e8 4d fd ff ff       	call   801aa3 <nsipc>
}
  801d56:	c9                   	leave  
  801d57:	c3                   	ret    

00801d58 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d58:	55                   	push   %ebp
  801d59:	89 e5                	mov    %esp,%ebp
  801d5b:	56                   	push   %esi
  801d5c:	53                   	push   %ebx
  801d5d:	83 ec 10             	sub    $0x10,%esp
  801d60:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d63:	8b 45 08             	mov    0x8(%ebp),%eax
  801d66:	89 04 24             	mov    %eax,(%esp)
  801d69:	e8 72 f2 ff ff       	call   800fe0 <fd2data>
  801d6e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d70:	c7 44 24 04 88 2b 80 	movl   $0x802b88,0x4(%esp)
  801d77:	00 
  801d78:	89 1c 24             	mov    %ebx,(%esp)
  801d7b:	e8 07 eb ff ff       	call   800887 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d80:	8b 46 04             	mov    0x4(%esi),%eax
  801d83:	2b 06                	sub    (%esi),%eax
  801d85:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d8b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d92:	00 00 00 
	stat->st_dev = &devpipe;
  801d95:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801d9c:	30 80 00 
	return 0;
}
  801d9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801da4:	83 c4 10             	add    $0x10,%esp
  801da7:	5b                   	pop    %ebx
  801da8:	5e                   	pop    %esi
  801da9:	5d                   	pop    %ebp
  801daa:	c3                   	ret    

00801dab <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801dab:	55                   	push   %ebp
  801dac:	89 e5                	mov    %esp,%ebp
  801dae:	53                   	push   %ebx
  801daf:	83 ec 14             	sub    $0x14,%esp
  801db2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801db5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801db9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dc0:	e8 85 ef ff ff       	call   800d4a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801dc5:	89 1c 24             	mov    %ebx,(%esp)
  801dc8:	e8 13 f2 ff ff       	call   800fe0 <fd2data>
  801dcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dd8:	e8 6d ef ff ff       	call   800d4a <sys_page_unmap>
}
  801ddd:	83 c4 14             	add    $0x14,%esp
  801de0:	5b                   	pop    %ebx
  801de1:	5d                   	pop    %ebp
  801de2:	c3                   	ret    

00801de3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801de3:	55                   	push   %ebp
  801de4:	89 e5                	mov    %esp,%ebp
  801de6:	57                   	push   %edi
  801de7:	56                   	push   %esi
  801de8:	53                   	push   %ebx
  801de9:	83 ec 2c             	sub    $0x2c,%esp
  801dec:	89 c6                	mov    %eax,%esi
  801dee:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801df1:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801df6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801df9:	89 34 24             	mov    %esi,(%esp)
  801dfc:	e8 ac 05 00 00       	call   8023ad <pageref>
  801e01:	89 c7                	mov    %eax,%edi
  801e03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e06:	89 04 24             	mov    %eax,(%esp)
  801e09:	e8 9f 05 00 00       	call   8023ad <pageref>
  801e0e:	39 c7                	cmp    %eax,%edi
  801e10:	0f 94 c2             	sete   %dl
  801e13:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801e16:	8b 0d 20 40 c0 00    	mov    0xc04020,%ecx
  801e1c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801e1f:	39 fb                	cmp    %edi,%ebx
  801e21:	74 21                	je     801e44 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801e23:	84 d2                	test   %dl,%dl
  801e25:	74 ca                	je     801df1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e27:	8b 51 58             	mov    0x58(%ecx),%edx
  801e2a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e2e:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e32:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e36:	c7 04 24 8f 2b 80 00 	movl   $0x802b8f,(%esp)
  801e3d:	e8 16 e4 ff ff       	call   800258 <cprintf>
  801e42:	eb ad                	jmp    801df1 <_pipeisclosed+0xe>
	}
}
  801e44:	83 c4 2c             	add    $0x2c,%esp
  801e47:	5b                   	pop    %ebx
  801e48:	5e                   	pop    %esi
  801e49:	5f                   	pop    %edi
  801e4a:	5d                   	pop    %ebp
  801e4b:	c3                   	ret    

00801e4c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	57                   	push   %edi
  801e50:	56                   	push   %esi
  801e51:	53                   	push   %ebx
  801e52:	83 ec 1c             	sub    $0x1c,%esp
  801e55:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e58:	89 34 24             	mov    %esi,(%esp)
  801e5b:	e8 80 f1 ff ff       	call   800fe0 <fd2data>
  801e60:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e62:	bf 00 00 00 00       	mov    $0x0,%edi
  801e67:	eb 45                	jmp    801eae <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e69:	89 da                	mov    %ebx,%edx
  801e6b:	89 f0                	mov    %esi,%eax
  801e6d:	e8 71 ff ff ff       	call   801de3 <_pipeisclosed>
  801e72:	85 c0                	test   %eax,%eax
  801e74:	75 41                	jne    801eb7 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e76:	e8 09 ee ff ff       	call   800c84 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e7b:	8b 43 04             	mov    0x4(%ebx),%eax
  801e7e:	8b 0b                	mov    (%ebx),%ecx
  801e80:	8d 51 20             	lea    0x20(%ecx),%edx
  801e83:	39 d0                	cmp    %edx,%eax
  801e85:	73 e2                	jae    801e69 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e8a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e8e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e91:	99                   	cltd   
  801e92:	c1 ea 1b             	shr    $0x1b,%edx
  801e95:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801e98:	83 e1 1f             	and    $0x1f,%ecx
  801e9b:	29 d1                	sub    %edx,%ecx
  801e9d:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801ea1:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801ea5:	83 c0 01             	add    $0x1,%eax
  801ea8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eab:	83 c7 01             	add    $0x1,%edi
  801eae:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801eb1:	75 c8                	jne    801e7b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801eb3:	89 f8                	mov    %edi,%eax
  801eb5:	eb 05                	jmp    801ebc <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801eb7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ebc:	83 c4 1c             	add    $0x1c,%esp
  801ebf:	5b                   	pop    %ebx
  801ec0:	5e                   	pop    %esi
  801ec1:	5f                   	pop    %edi
  801ec2:	5d                   	pop    %ebp
  801ec3:	c3                   	ret    

00801ec4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
  801ec7:	57                   	push   %edi
  801ec8:	56                   	push   %esi
  801ec9:	53                   	push   %ebx
  801eca:	83 ec 1c             	sub    $0x1c,%esp
  801ecd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ed0:	89 3c 24             	mov    %edi,(%esp)
  801ed3:	e8 08 f1 ff ff       	call   800fe0 <fd2data>
  801ed8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eda:	be 00 00 00 00       	mov    $0x0,%esi
  801edf:	eb 3d                	jmp    801f1e <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ee1:	85 f6                	test   %esi,%esi
  801ee3:	74 04                	je     801ee9 <devpipe_read+0x25>
				return i;
  801ee5:	89 f0                	mov    %esi,%eax
  801ee7:	eb 43                	jmp    801f2c <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ee9:	89 da                	mov    %ebx,%edx
  801eeb:	89 f8                	mov    %edi,%eax
  801eed:	e8 f1 fe ff ff       	call   801de3 <_pipeisclosed>
  801ef2:	85 c0                	test   %eax,%eax
  801ef4:	75 31                	jne    801f27 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ef6:	e8 89 ed ff ff       	call   800c84 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801efb:	8b 03                	mov    (%ebx),%eax
  801efd:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f00:	74 df                	je     801ee1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f02:	99                   	cltd   
  801f03:	c1 ea 1b             	shr    $0x1b,%edx
  801f06:	01 d0                	add    %edx,%eax
  801f08:	83 e0 1f             	and    $0x1f,%eax
  801f0b:	29 d0                	sub    %edx,%eax
  801f0d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801f12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f15:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801f18:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f1b:	83 c6 01             	add    $0x1,%esi
  801f1e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f21:	75 d8                	jne    801efb <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f23:	89 f0                	mov    %esi,%eax
  801f25:	eb 05                	jmp    801f2c <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f27:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f2c:	83 c4 1c             	add    $0x1c,%esp
  801f2f:	5b                   	pop    %ebx
  801f30:	5e                   	pop    %esi
  801f31:	5f                   	pop    %edi
  801f32:	5d                   	pop    %ebp
  801f33:	c3                   	ret    

00801f34 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f34:	55                   	push   %ebp
  801f35:	89 e5                	mov    %esp,%ebp
  801f37:	56                   	push   %esi
  801f38:	53                   	push   %ebx
  801f39:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f3c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f3f:	89 04 24             	mov    %eax,(%esp)
  801f42:	e8 b0 f0 ff ff       	call   800ff7 <fd_alloc>
  801f47:	89 c2                	mov    %eax,%edx
  801f49:	85 d2                	test   %edx,%edx
  801f4b:	0f 88 4d 01 00 00    	js     80209e <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f51:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f58:	00 
  801f59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f67:	e8 37 ed ff ff       	call   800ca3 <sys_page_alloc>
  801f6c:	89 c2                	mov    %eax,%edx
  801f6e:	85 d2                	test   %edx,%edx
  801f70:	0f 88 28 01 00 00    	js     80209e <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f76:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f79:	89 04 24             	mov    %eax,(%esp)
  801f7c:	e8 76 f0 ff ff       	call   800ff7 <fd_alloc>
  801f81:	89 c3                	mov    %eax,%ebx
  801f83:	85 c0                	test   %eax,%eax
  801f85:	0f 88 fe 00 00 00    	js     802089 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f8b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f92:	00 
  801f93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f96:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f9a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fa1:	e8 fd ec ff ff       	call   800ca3 <sys_page_alloc>
  801fa6:	89 c3                	mov    %eax,%ebx
  801fa8:	85 c0                	test   %eax,%eax
  801faa:	0f 88 d9 00 00 00    	js     802089 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801fb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb3:	89 04 24             	mov    %eax,(%esp)
  801fb6:	e8 25 f0 ff ff       	call   800fe0 <fd2data>
  801fbb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fbd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fc4:	00 
  801fc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fc9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fd0:	e8 ce ec ff ff       	call   800ca3 <sys_page_alloc>
  801fd5:	89 c3                	mov    %eax,%ebx
  801fd7:	85 c0                	test   %eax,%eax
  801fd9:	0f 88 97 00 00 00    	js     802076 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fe2:	89 04 24             	mov    %eax,(%esp)
  801fe5:	e8 f6 ef ff ff       	call   800fe0 <fd2data>
  801fea:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801ff1:	00 
  801ff2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ff6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ffd:	00 
  801ffe:	89 74 24 04          	mov    %esi,0x4(%esp)
  802002:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802009:	e8 e9 ec ff ff       	call   800cf7 <sys_page_map>
  80200e:	89 c3                	mov    %eax,%ebx
  802010:	85 c0                	test   %eax,%eax
  802012:	78 52                	js     802066 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802014:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80201a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80201d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80201f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802022:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802029:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80202f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802032:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802034:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802037:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80203e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802041:	89 04 24             	mov    %eax,(%esp)
  802044:	e8 87 ef ff ff       	call   800fd0 <fd2num>
  802049:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80204c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80204e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802051:	89 04 24             	mov    %eax,(%esp)
  802054:	e8 77 ef ff ff       	call   800fd0 <fd2num>
  802059:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80205c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80205f:	b8 00 00 00 00       	mov    $0x0,%eax
  802064:	eb 38                	jmp    80209e <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  802066:	89 74 24 04          	mov    %esi,0x4(%esp)
  80206a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802071:	e8 d4 ec ff ff       	call   800d4a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802076:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802079:	89 44 24 04          	mov    %eax,0x4(%esp)
  80207d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802084:	e8 c1 ec ff ff       	call   800d4a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802089:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80208c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802090:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802097:	e8 ae ec ff ff       	call   800d4a <sys_page_unmap>
  80209c:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  80209e:	83 c4 30             	add    $0x30,%esp
  8020a1:	5b                   	pop    %ebx
  8020a2:	5e                   	pop    %esi
  8020a3:	5d                   	pop    %ebp
  8020a4:	c3                   	ret    

008020a5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8020a5:	55                   	push   %ebp
  8020a6:	89 e5                	mov    %esp,%ebp
  8020a8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b5:	89 04 24             	mov    %eax,(%esp)
  8020b8:	e8 89 ef ff ff       	call   801046 <fd_lookup>
  8020bd:	89 c2                	mov    %eax,%edx
  8020bf:	85 d2                	test   %edx,%edx
  8020c1:	78 15                	js     8020d8 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8020c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c6:	89 04 24             	mov    %eax,(%esp)
  8020c9:	e8 12 ef ff ff       	call   800fe0 <fd2data>
	return _pipeisclosed(fd, p);
  8020ce:	89 c2                	mov    %eax,%edx
  8020d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d3:	e8 0b fd ff ff       	call   801de3 <_pipeisclosed>
}
  8020d8:	c9                   	leave  
  8020d9:	c3                   	ret    
  8020da:	66 90                	xchg   %ax,%ax
  8020dc:	66 90                	xchg   %ax,%ax
  8020de:	66 90                	xchg   %ax,%ax

008020e0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020e0:	55                   	push   %ebp
  8020e1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8020e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8020e8:	5d                   	pop    %ebp
  8020e9:	c3                   	ret    

008020ea <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8020ea:	55                   	push   %ebp
  8020eb:	89 e5                	mov    %esp,%ebp
  8020ed:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8020f0:	c7 44 24 04 a7 2b 80 	movl   $0x802ba7,0x4(%esp)
  8020f7:	00 
  8020f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020fb:	89 04 24             	mov    %eax,(%esp)
  8020fe:	e8 84 e7 ff ff       	call   800887 <strcpy>
	return 0;
}
  802103:	b8 00 00 00 00       	mov    $0x0,%eax
  802108:	c9                   	leave  
  802109:	c3                   	ret    

0080210a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80210a:	55                   	push   %ebp
  80210b:	89 e5                	mov    %esp,%ebp
  80210d:	57                   	push   %edi
  80210e:	56                   	push   %esi
  80210f:	53                   	push   %ebx
  802110:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802116:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80211b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802121:	eb 31                	jmp    802154 <devcons_write+0x4a>
		m = n - tot;
  802123:	8b 75 10             	mov    0x10(%ebp),%esi
  802126:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802128:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80212b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802130:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802133:	89 74 24 08          	mov    %esi,0x8(%esp)
  802137:	03 45 0c             	add    0xc(%ebp),%eax
  80213a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80213e:	89 3c 24             	mov    %edi,(%esp)
  802141:	e8 de e8 ff ff       	call   800a24 <memmove>
		sys_cputs(buf, m);
  802146:	89 74 24 04          	mov    %esi,0x4(%esp)
  80214a:	89 3c 24             	mov    %edi,(%esp)
  80214d:	e8 84 ea ff ff       	call   800bd6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802152:	01 f3                	add    %esi,%ebx
  802154:	89 d8                	mov    %ebx,%eax
  802156:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802159:	72 c8                	jb     802123 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80215b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802161:	5b                   	pop    %ebx
  802162:	5e                   	pop    %esi
  802163:	5f                   	pop    %edi
  802164:	5d                   	pop    %ebp
  802165:	c3                   	ret    

00802166 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802166:	55                   	push   %ebp
  802167:	89 e5                	mov    %esp,%ebp
  802169:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80216c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802171:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802175:	75 07                	jne    80217e <devcons_read+0x18>
  802177:	eb 2a                	jmp    8021a3 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802179:	e8 06 eb ff ff       	call   800c84 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80217e:	66 90                	xchg   %ax,%ax
  802180:	e8 6f ea ff ff       	call   800bf4 <sys_cgetc>
  802185:	85 c0                	test   %eax,%eax
  802187:	74 f0                	je     802179 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802189:	85 c0                	test   %eax,%eax
  80218b:	78 16                	js     8021a3 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80218d:	83 f8 04             	cmp    $0x4,%eax
  802190:	74 0c                	je     80219e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802192:	8b 55 0c             	mov    0xc(%ebp),%edx
  802195:	88 02                	mov    %al,(%edx)
	return 1;
  802197:	b8 01 00 00 00       	mov    $0x1,%eax
  80219c:	eb 05                	jmp    8021a3 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80219e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021a3:	c9                   	leave  
  8021a4:	c3                   	ret    

008021a5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8021a5:	55                   	push   %ebp
  8021a6:	89 e5                	mov    %esp,%ebp
  8021a8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8021ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ae:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8021b1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8021b8:	00 
  8021b9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021bc:	89 04 24             	mov    %eax,(%esp)
  8021bf:	e8 12 ea ff ff       	call   800bd6 <sys_cputs>
}
  8021c4:	c9                   	leave  
  8021c5:	c3                   	ret    

008021c6 <getchar>:

int
getchar(void)
{
  8021c6:	55                   	push   %ebp
  8021c7:	89 e5                	mov    %esp,%ebp
  8021c9:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8021cc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8021d3:	00 
  8021d4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021e2:	e8 f3 f0 ff ff       	call   8012da <read>
	if (r < 0)
  8021e7:	85 c0                	test   %eax,%eax
  8021e9:	78 0f                	js     8021fa <getchar+0x34>
		return r;
	if (r < 1)
  8021eb:	85 c0                	test   %eax,%eax
  8021ed:	7e 06                	jle    8021f5 <getchar+0x2f>
		return -E_EOF;
	return c;
  8021ef:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8021f3:	eb 05                	jmp    8021fa <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8021f5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8021fa:	c9                   	leave  
  8021fb:	c3                   	ret    

008021fc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8021fc:	55                   	push   %ebp
  8021fd:	89 e5                	mov    %esp,%ebp
  8021ff:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802202:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802205:	89 44 24 04          	mov    %eax,0x4(%esp)
  802209:	8b 45 08             	mov    0x8(%ebp),%eax
  80220c:	89 04 24             	mov    %eax,(%esp)
  80220f:	e8 32 ee ff ff       	call   801046 <fd_lookup>
  802214:	85 c0                	test   %eax,%eax
  802216:	78 11                	js     802229 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802218:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80221b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802221:	39 10                	cmp    %edx,(%eax)
  802223:	0f 94 c0             	sete   %al
  802226:	0f b6 c0             	movzbl %al,%eax
}
  802229:	c9                   	leave  
  80222a:	c3                   	ret    

0080222b <opencons>:

int
opencons(void)
{
  80222b:	55                   	push   %ebp
  80222c:	89 e5                	mov    %esp,%ebp
  80222e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802231:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802234:	89 04 24             	mov    %eax,(%esp)
  802237:	e8 bb ed ff ff       	call   800ff7 <fd_alloc>
		return r;
  80223c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80223e:	85 c0                	test   %eax,%eax
  802240:	78 40                	js     802282 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802242:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802249:	00 
  80224a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80224d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802251:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802258:	e8 46 ea ff ff       	call   800ca3 <sys_page_alloc>
		return r;
  80225d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80225f:	85 c0                	test   %eax,%eax
  802261:	78 1f                	js     802282 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802263:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802269:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80226c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80226e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802271:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802278:	89 04 24             	mov    %eax,(%esp)
  80227b:	e8 50 ed ff ff       	call   800fd0 <fd2num>
  802280:	89 c2                	mov    %eax,%edx
}
  802282:	89 d0                	mov    %edx,%eax
  802284:	c9                   	leave  
  802285:	c3                   	ret    
  802286:	66 90                	xchg   %ax,%ax
  802288:	66 90                	xchg   %ax,%ax
  80228a:	66 90                	xchg   %ax,%ax
  80228c:	66 90                	xchg   %ax,%ax
  80228e:	66 90                	xchg   %ax,%ax

00802290 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802290:	55                   	push   %ebp
  802291:	89 e5                	mov    %esp,%ebp
  802293:	56                   	push   %esi
  802294:	53                   	push   %ebx
  802295:	83 ec 10             	sub    $0x10,%esp
  802298:	8b 75 08             	mov    0x8(%ebp),%esi
  80229b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80229e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  8022a1:	85 c0                	test   %eax,%eax
  8022a3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8022a8:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  8022ab:	89 04 24             	mov    %eax,(%esp)
  8022ae:	e8 06 ec ff ff       	call   800eb9 <sys_ipc_recv>

	if(ret < 0) {
  8022b3:	85 c0                	test   %eax,%eax
  8022b5:	79 16                	jns    8022cd <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  8022b7:	85 f6                	test   %esi,%esi
  8022b9:	74 06                	je     8022c1 <ipc_recv+0x31>
  8022bb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  8022c1:	85 db                	test   %ebx,%ebx
  8022c3:	74 3e                	je     802303 <ipc_recv+0x73>
  8022c5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8022cb:	eb 36                	jmp    802303 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  8022cd:	e8 93 e9 ff ff       	call   800c65 <sys_getenvid>
  8022d2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8022d7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022da:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8022df:	a3 20 40 c0 00       	mov    %eax,0xc04020

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8022e4:	85 f6                	test   %esi,%esi
  8022e6:	74 05                	je     8022ed <ipc_recv+0x5d>
  8022e8:	8b 40 74             	mov    0x74(%eax),%eax
  8022eb:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8022ed:	85 db                	test   %ebx,%ebx
  8022ef:	74 0a                	je     8022fb <ipc_recv+0x6b>
  8022f1:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8022f6:	8b 40 78             	mov    0x78(%eax),%eax
  8022f9:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  8022fb:	a1 20 40 c0 00       	mov    0xc04020,%eax
  802300:	8b 40 70             	mov    0x70(%eax),%eax
}
  802303:	83 c4 10             	add    $0x10,%esp
  802306:	5b                   	pop    %ebx
  802307:	5e                   	pop    %esi
  802308:	5d                   	pop    %ebp
  802309:	c3                   	ret    

0080230a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80230a:	55                   	push   %ebp
  80230b:	89 e5                	mov    %esp,%ebp
  80230d:	57                   	push   %edi
  80230e:	56                   	push   %esi
  80230f:	53                   	push   %ebx
  802310:	83 ec 1c             	sub    $0x1c,%esp
  802313:	8b 7d 08             	mov    0x8(%ebp),%edi
  802316:	8b 75 0c             	mov    0xc(%ebp),%esi
  802319:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  80231c:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  80231e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802323:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  802326:	8b 45 14             	mov    0x14(%ebp),%eax
  802329:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80232d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802331:	89 74 24 04          	mov    %esi,0x4(%esp)
  802335:	89 3c 24             	mov    %edi,(%esp)
  802338:	e8 59 eb ff ff       	call   800e96 <sys_ipc_try_send>

		if(ret >= 0) break;
  80233d:	85 c0                	test   %eax,%eax
  80233f:	79 2c                	jns    80236d <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  802341:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802344:	74 20                	je     802366 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  802346:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80234a:	c7 44 24 08 b4 2b 80 	movl   $0x802bb4,0x8(%esp)
  802351:	00 
  802352:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  802359:	00 
  80235a:	c7 04 24 e4 2b 80 00 	movl   $0x802be4,(%esp)
  802361:	e8 f9 dd ff ff       	call   80015f <_panic>
		}
		sys_yield();
  802366:	e8 19 e9 ff ff       	call   800c84 <sys_yield>
	}
  80236b:	eb b9                	jmp    802326 <ipc_send+0x1c>
}
  80236d:	83 c4 1c             	add    $0x1c,%esp
  802370:	5b                   	pop    %ebx
  802371:	5e                   	pop    %esi
  802372:	5f                   	pop    %edi
  802373:	5d                   	pop    %ebp
  802374:	c3                   	ret    

00802375 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802375:	55                   	push   %ebp
  802376:	89 e5                	mov    %esp,%ebp
  802378:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80237b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802380:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802383:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802389:	8b 52 50             	mov    0x50(%edx),%edx
  80238c:	39 ca                	cmp    %ecx,%edx
  80238e:	75 0d                	jne    80239d <ipc_find_env+0x28>
			return envs[i].env_id;
  802390:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802393:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802398:	8b 40 40             	mov    0x40(%eax),%eax
  80239b:	eb 0e                	jmp    8023ab <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80239d:	83 c0 01             	add    $0x1,%eax
  8023a0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023a5:	75 d9                	jne    802380 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8023a7:	66 b8 00 00          	mov    $0x0,%ax
}
  8023ab:	5d                   	pop    %ebp
  8023ac:	c3                   	ret    

008023ad <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023ad:	55                   	push   %ebp
  8023ae:	89 e5                	mov    %esp,%ebp
  8023b0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023b3:	89 d0                	mov    %edx,%eax
  8023b5:	c1 e8 16             	shr    $0x16,%eax
  8023b8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023bf:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023c4:	f6 c1 01             	test   $0x1,%cl
  8023c7:	74 1d                	je     8023e6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023c9:	c1 ea 0c             	shr    $0xc,%edx
  8023cc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023d3:	f6 c2 01             	test   $0x1,%dl
  8023d6:	74 0e                	je     8023e6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023d8:	c1 ea 0c             	shr    $0xc,%edx
  8023db:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023e2:	ef 
  8023e3:	0f b7 c0             	movzwl %ax,%eax
}
  8023e6:	5d                   	pop    %ebp
  8023e7:	c3                   	ret    
  8023e8:	66 90                	xchg   %ax,%ax
  8023ea:	66 90                	xchg   %ax,%ax
  8023ec:	66 90                	xchg   %ax,%ax
  8023ee:	66 90                	xchg   %ax,%ax

008023f0 <__udivdi3>:
  8023f0:	55                   	push   %ebp
  8023f1:	57                   	push   %edi
  8023f2:	56                   	push   %esi
  8023f3:	83 ec 0c             	sub    $0xc,%esp
  8023f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8023fa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8023fe:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802402:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802406:	85 c0                	test   %eax,%eax
  802408:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80240c:	89 ea                	mov    %ebp,%edx
  80240e:	89 0c 24             	mov    %ecx,(%esp)
  802411:	75 2d                	jne    802440 <__udivdi3+0x50>
  802413:	39 e9                	cmp    %ebp,%ecx
  802415:	77 61                	ja     802478 <__udivdi3+0x88>
  802417:	85 c9                	test   %ecx,%ecx
  802419:	89 ce                	mov    %ecx,%esi
  80241b:	75 0b                	jne    802428 <__udivdi3+0x38>
  80241d:	b8 01 00 00 00       	mov    $0x1,%eax
  802422:	31 d2                	xor    %edx,%edx
  802424:	f7 f1                	div    %ecx
  802426:	89 c6                	mov    %eax,%esi
  802428:	31 d2                	xor    %edx,%edx
  80242a:	89 e8                	mov    %ebp,%eax
  80242c:	f7 f6                	div    %esi
  80242e:	89 c5                	mov    %eax,%ebp
  802430:	89 f8                	mov    %edi,%eax
  802432:	f7 f6                	div    %esi
  802434:	89 ea                	mov    %ebp,%edx
  802436:	83 c4 0c             	add    $0xc,%esp
  802439:	5e                   	pop    %esi
  80243a:	5f                   	pop    %edi
  80243b:	5d                   	pop    %ebp
  80243c:	c3                   	ret    
  80243d:	8d 76 00             	lea    0x0(%esi),%esi
  802440:	39 e8                	cmp    %ebp,%eax
  802442:	77 24                	ja     802468 <__udivdi3+0x78>
  802444:	0f bd e8             	bsr    %eax,%ebp
  802447:	83 f5 1f             	xor    $0x1f,%ebp
  80244a:	75 3c                	jne    802488 <__udivdi3+0x98>
  80244c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802450:	39 34 24             	cmp    %esi,(%esp)
  802453:	0f 86 9f 00 00 00    	jbe    8024f8 <__udivdi3+0x108>
  802459:	39 d0                	cmp    %edx,%eax
  80245b:	0f 82 97 00 00 00    	jb     8024f8 <__udivdi3+0x108>
  802461:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802468:	31 d2                	xor    %edx,%edx
  80246a:	31 c0                	xor    %eax,%eax
  80246c:	83 c4 0c             	add    $0xc,%esp
  80246f:	5e                   	pop    %esi
  802470:	5f                   	pop    %edi
  802471:	5d                   	pop    %ebp
  802472:	c3                   	ret    
  802473:	90                   	nop
  802474:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802478:	89 f8                	mov    %edi,%eax
  80247a:	f7 f1                	div    %ecx
  80247c:	31 d2                	xor    %edx,%edx
  80247e:	83 c4 0c             	add    $0xc,%esp
  802481:	5e                   	pop    %esi
  802482:	5f                   	pop    %edi
  802483:	5d                   	pop    %ebp
  802484:	c3                   	ret    
  802485:	8d 76 00             	lea    0x0(%esi),%esi
  802488:	89 e9                	mov    %ebp,%ecx
  80248a:	8b 3c 24             	mov    (%esp),%edi
  80248d:	d3 e0                	shl    %cl,%eax
  80248f:	89 c6                	mov    %eax,%esi
  802491:	b8 20 00 00 00       	mov    $0x20,%eax
  802496:	29 e8                	sub    %ebp,%eax
  802498:	89 c1                	mov    %eax,%ecx
  80249a:	d3 ef                	shr    %cl,%edi
  80249c:	89 e9                	mov    %ebp,%ecx
  80249e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8024a2:	8b 3c 24             	mov    (%esp),%edi
  8024a5:	09 74 24 08          	or     %esi,0x8(%esp)
  8024a9:	89 d6                	mov    %edx,%esi
  8024ab:	d3 e7                	shl    %cl,%edi
  8024ad:	89 c1                	mov    %eax,%ecx
  8024af:	89 3c 24             	mov    %edi,(%esp)
  8024b2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8024b6:	d3 ee                	shr    %cl,%esi
  8024b8:	89 e9                	mov    %ebp,%ecx
  8024ba:	d3 e2                	shl    %cl,%edx
  8024bc:	89 c1                	mov    %eax,%ecx
  8024be:	d3 ef                	shr    %cl,%edi
  8024c0:	09 d7                	or     %edx,%edi
  8024c2:	89 f2                	mov    %esi,%edx
  8024c4:	89 f8                	mov    %edi,%eax
  8024c6:	f7 74 24 08          	divl   0x8(%esp)
  8024ca:	89 d6                	mov    %edx,%esi
  8024cc:	89 c7                	mov    %eax,%edi
  8024ce:	f7 24 24             	mull   (%esp)
  8024d1:	39 d6                	cmp    %edx,%esi
  8024d3:	89 14 24             	mov    %edx,(%esp)
  8024d6:	72 30                	jb     802508 <__udivdi3+0x118>
  8024d8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024dc:	89 e9                	mov    %ebp,%ecx
  8024de:	d3 e2                	shl    %cl,%edx
  8024e0:	39 c2                	cmp    %eax,%edx
  8024e2:	73 05                	jae    8024e9 <__udivdi3+0xf9>
  8024e4:	3b 34 24             	cmp    (%esp),%esi
  8024e7:	74 1f                	je     802508 <__udivdi3+0x118>
  8024e9:	89 f8                	mov    %edi,%eax
  8024eb:	31 d2                	xor    %edx,%edx
  8024ed:	e9 7a ff ff ff       	jmp    80246c <__udivdi3+0x7c>
  8024f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024f8:	31 d2                	xor    %edx,%edx
  8024fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8024ff:	e9 68 ff ff ff       	jmp    80246c <__udivdi3+0x7c>
  802504:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802508:	8d 47 ff             	lea    -0x1(%edi),%eax
  80250b:	31 d2                	xor    %edx,%edx
  80250d:	83 c4 0c             	add    $0xc,%esp
  802510:	5e                   	pop    %esi
  802511:	5f                   	pop    %edi
  802512:	5d                   	pop    %ebp
  802513:	c3                   	ret    
  802514:	66 90                	xchg   %ax,%ax
  802516:	66 90                	xchg   %ax,%ax
  802518:	66 90                	xchg   %ax,%ax
  80251a:	66 90                	xchg   %ax,%ax
  80251c:	66 90                	xchg   %ax,%ax
  80251e:	66 90                	xchg   %ax,%ax

00802520 <__umoddi3>:
  802520:	55                   	push   %ebp
  802521:	57                   	push   %edi
  802522:	56                   	push   %esi
  802523:	83 ec 14             	sub    $0x14,%esp
  802526:	8b 44 24 28          	mov    0x28(%esp),%eax
  80252a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80252e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802532:	89 c7                	mov    %eax,%edi
  802534:	89 44 24 04          	mov    %eax,0x4(%esp)
  802538:	8b 44 24 30          	mov    0x30(%esp),%eax
  80253c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802540:	89 34 24             	mov    %esi,(%esp)
  802543:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802547:	85 c0                	test   %eax,%eax
  802549:	89 c2                	mov    %eax,%edx
  80254b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80254f:	75 17                	jne    802568 <__umoddi3+0x48>
  802551:	39 fe                	cmp    %edi,%esi
  802553:	76 4b                	jbe    8025a0 <__umoddi3+0x80>
  802555:	89 c8                	mov    %ecx,%eax
  802557:	89 fa                	mov    %edi,%edx
  802559:	f7 f6                	div    %esi
  80255b:	89 d0                	mov    %edx,%eax
  80255d:	31 d2                	xor    %edx,%edx
  80255f:	83 c4 14             	add    $0x14,%esp
  802562:	5e                   	pop    %esi
  802563:	5f                   	pop    %edi
  802564:	5d                   	pop    %ebp
  802565:	c3                   	ret    
  802566:	66 90                	xchg   %ax,%ax
  802568:	39 f8                	cmp    %edi,%eax
  80256a:	77 54                	ja     8025c0 <__umoddi3+0xa0>
  80256c:	0f bd e8             	bsr    %eax,%ebp
  80256f:	83 f5 1f             	xor    $0x1f,%ebp
  802572:	75 5c                	jne    8025d0 <__umoddi3+0xb0>
  802574:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802578:	39 3c 24             	cmp    %edi,(%esp)
  80257b:	0f 87 e7 00 00 00    	ja     802668 <__umoddi3+0x148>
  802581:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802585:	29 f1                	sub    %esi,%ecx
  802587:	19 c7                	sbb    %eax,%edi
  802589:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80258d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802591:	8b 44 24 08          	mov    0x8(%esp),%eax
  802595:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802599:	83 c4 14             	add    $0x14,%esp
  80259c:	5e                   	pop    %esi
  80259d:	5f                   	pop    %edi
  80259e:	5d                   	pop    %ebp
  80259f:	c3                   	ret    
  8025a0:	85 f6                	test   %esi,%esi
  8025a2:	89 f5                	mov    %esi,%ebp
  8025a4:	75 0b                	jne    8025b1 <__umoddi3+0x91>
  8025a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025ab:	31 d2                	xor    %edx,%edx
  8025ad:	f7 f6                	div    %esi
  8025af:	89 c5                	mov    %eax,%ebp
  8025b1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8025b5:	31 d2                	xor    %edx,%edx
  8025b7:	f7 f5                	div    %ebp
  8025b9:	89 c8                	mov    %ecx,%eax
  8025bb:	f7 f5                	div    %ebp
  8025bd:	eb 9c                	jmp    80255b <__umoddi3+0x3b>
  8025bf:	90                   	nop
  8025c0:	89 c8                	mov    %ecx,%eax
  8025c2:	89 fa                	mov    %edi,%edx
  8025c4:	83 c4 14             	add    $0x14,%esp
  8025c7:	5e                   	pop    %esi
  8025c8:	5f                   	pop    %edi
  8025c9:	5d                   	pop    %ebp
  8025ca:	c3                   	ret    
  8025cb:	90                   	nop
  8025cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025d0:	8b 04 24             	mov    (%esp),%eax
  8025d3:	be 20 00 00 00       	mov    $0x20,%esi
  8025d8:	89 e9                	mov    %ebp,%ecx
  8025da:	29 ee                	sub    %ebp,%esi
  8025dc:	d3 e2                	shl    %cl,%edx
  8025de:	89 f1                	mov    %esi,%ecx
  8025e0:	d3 e8                	shr    %cl,%eax
  8025e2:	89 e9                	mov    %ebp,%ecx
  8025e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025e8:	8b 04 24             	mov    (%esp),%eax
  8025eb:	09 54 24 04          	or     %edx,0x4(%esp)
  8025ef:	89 fa                	mov    %edi,%edx
  8025f1:	d3 e0                	shl    %cl,%eax
  8025f3:	89 f1                	mov    %esi,%ecx
  8025f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025f9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8025fd:	d3 ea                	shr    %cl,%edx
  8025ff:	89 e9                	mov    %ebp,%ecx
  802601:	d3 e7                	shl    %cl,%edi
  802603:	89 f1                	mov    %esi,%ecx
  802605:	d3 e8                	shr    %cl,%eax
  802607:	89 e9                	mov    %ebp,%ecx
  802609:	09 f8                	or     %edi,%eax
  80260b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80260f:	f7 74 24 04          	divl   0x4(%esp)
  802613:	d3 e7                	shl    %cl,%edi
  802615:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802619:	89 d7                	mov    %edx,%edi
  80261b:	f7 64 24 08          	mull   0x8(%esp)
  80261f:	39 d7                	cmp    %edx,%edi
  802621:	89 c1                	mov    %eax,%ecx
  802623:	89 14 24             	mov    %edx,(%esp)
  802626:	72 2c                	jb     802654 <__umoddi3+0x134>
  802628:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80262c:	72 22                	jb     802650 <__umoddi3+0x130>
  80262e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802632:	29 c8                	sub    %ecx,%eax
  802634:	19 d7                	sbb    %edx,%edi
  802636:	89 e9                	mov    %ebp,%ecx
  802638:	89 fa                	mov    %edi,%edx
  80263a:	d3 e8                	shr    %cl,%eax
  80263c:	89 f1                	mov    %esi,%ecx
  80263e:	d3 e2                	shl    %cl,%edx
  802640:	89 e9                	mov    %ebp,%ecx
  802642:	d3 ef                	shr    %cl,%edi
  802644:	09 d0                	or     %edx,%eax
  802646:	89 fa                	mov    %edi,%edx
  802648:	83 c4 14             	add    $0x14,%esp
  80264b:	5e                   	pop    %esi
  80264c:	5f                   	pop    %edi
  80264d:	5d                   	pop    %ebp
  80264e:	c3                   	ret    
  80264f:	90                   	nop
  802650:	39 d7                	cmp    %edx,%edi
  802652:	75 da                	jne    80262e <__umoddi3+0x10e>
  802654:	8b 14 24             	mov    (%esp),%edx
  802657:	89 c1                	mov    %eax,%ecx
  802659:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80265d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802661:	eb cb                	jmp    80262e <__umoddi3+0x10e>
  802663:	90                   	nop
  802664:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802668:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80266c:	0f 82 0f ff ff ff    	jb     802581 <__umoddi3+0x61>
  802672:	e9 1a ff ff ff       	jmp    802591 <__umoddi3+0x71>
