
obj/user/primes.debug:     file format elf32-i386


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
  80002c:	e8 17 01 00 00       	call   800148 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800046:	00 
  800047:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004e:	00 
  80004f:	89 34 24             	mov    %esi,(%esp)
  800052:	e8 c9 12 00 00       	call   801320 <ipc_recv>
  800057:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  800059:	a1 08 40 80 00       	mov    0x804008,%eax
  80005e:	8b 40 5c             	mov    0x5c(%eax),%eax
  800061:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800065:	89 44 24 04          	mov    %eax,0x4(%esp)
  800069:	c7 04 24 40 2a 80 00 	movl   $0x802a40,(%esp)
  800070:	e8 2d 02 00 00       	call   8002a2 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800075:	e8 9a 10 00 00       	call   801114 <fork>
  80007a:	89 c7                	mov    %eax,%edi
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 20                	jns    8000a0 <primeproc+0x6d>
		panic("fork: %e", id);
  800080:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800084:	c7 44 24 08 4c 2a 80 	movl   $0x802a4c,0x8(%esp)
  80008b:	00 
  80008c:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800093:	00 
  800094:	c7 04 24 55 2a 80 00 	movl   $0x802a55,(%esp)
  80009b:	e8 09 01 00 00       	call   8001a9 <_panic>

	if (id == 0)
  8000a0:	85 c0                	test   %eax,%eax
  8000a2:	74 9b                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  8000a4:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	89 34 24             	mov    %esi,(%esp)
  8000ba:	e8 61 12 00 00       	call   801320 <ipc_recv>
  8000bf:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000c1:	99                   	cltd   
  8000c2:	f7 fb                	idiv   %ebx
  8000c4:	85 d2                	test   %edx,%edx
  8000c6:	74 df                	je     8000a7 <primeproc+0x74>
			ipc_send(id, i, 0, 0);
  8000c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000cf:	00 
  8000d0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000d7:	00 
  8000d8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000dc:	89 3c 24             	mov    %edi,(%esp)
  8000df:	e8 b6 12 00 00       	call   80139a <ipc_send>
  8000e4:	eb c1                	jmp    8000a7 <primeproc+0x74>

008000e6 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	56                   	push   %esi
  8000ea:	53                   	push   %ebx
  8000eb:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ee:	e8 21 10 00 00       	call   801114 <fork>
  8000f3:	89 c6                	mov    %eax,%esi
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	79 20                	jns    800119 <umain+0x33>
		panic("fork: %e", id);
  8000f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fd:	c7 44 24 08 4c 2a 80 	movl   $0x802a4c,0x8(%esp)
  800104:	00 
  800105:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  80010c:	00 
  80010d:	c7 04 24 55 2a 80 00 	movl   $0x802a55,(%esp)
  800114:	e8 90 00 00 00       	call   8001a9 <_panic>
	if (id == 0)
  800119:	bb 02 00 00 00       	mov    $0x2,%ebx
  80011e:	85 c0                	test   %eax,%eax
  800120:	75 05                	jne    800127 <umain+0x41>
		primeproc();
  800122:	e8 0c ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  800127:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80012e:	00 
  80012f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800136:	00 
  800137:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80013b:	89 34 24             	mov    %esi,(%esp)
  80013e:	e8 57 12 00 00       	call   80139a <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  800143:	83 c3 01             	add    $0x1,%ebx
  800146:	eb df                	jmp    800127 <umain+0x41>

00800148 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
  80014d:	83 ec 10             	sub    $0x10,%esp
  800150:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800153:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  800156:	e8 4a 0b 00 00       	call   800ca5 <sys_getenvid>
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800163:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800168:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80016d:	85 db                	test   %ebx,%ebx
  80016f:	7e 07                	jle    800178 <libmain+0x30>
		binaryname = argv[0];
  800171:	8b 06                	mov    (%esi),%eax
  800173:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800178:	89 74 24 04          	mov    %esi,0x4(%esp)
  80017c:	89 1c 24             	mov    %ebx,(%esp)
  80017f:	e8 62 ff ff ff       	call   8000e6 <umain>

	// exit gracefully
	exit();
  800184:	e8 07 00 00 00       	call   800190 <exit>
}
  800189:	83 c4 10             	add    $0x10,%esp
  80018c:	5b                   	pop    %ebx
  80018d:	5e                   	pop    %esi
  80018e:	5d                   	pop    %ebp
  80018f:	c3                   	ret    

00800190 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800196:	e8 7f 14 00 00       	call   80161a <close_all>
	sys_env_destroy(0);
  80019b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001a2:	e8 ac 0a 00 00       	call   800c53 <sys_env_destroy>
}
  8001a7:	c9                   	leave  
  8001a8:	c3                   	ret    

008001a9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001b1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001b4:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001ba:	e8 e6 0a 00 00       	call   800ca5 <sys_getenvid>
  8001bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001cd:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d5:	c7 04 24 70 2a 80 00 	movl   $0x802a70,(%esp)
  8001dc:	e8 c1 00 00 00       	call   8002a2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e8:	89 04 24             	mov    %eax,(%esp)
  8001eb:	e8 51 00 00 00       	call   800241 <vcprintf>
	cprintf("\n");
  8001f0:	c7 04 24 98 2f 80 00 	movl   $0x802f98,(%esp)
  8001f7:	e8 a6 00 00 00       	call   8002a2 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001fc:	cc                   	int3   
  8001fd:	eb fd                	jmp    8001fc <_panic+0x53>

008001ff <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	53                   	push   %ebx
  800203:	83 ec 14             	sub    $0x14,%esp
  800206:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800209:	8b 13                	mov    (%ebx),%edx
  80020b:	8d 42 01             	lea    0x1(%edx),%eax
  80020e:	89 03                	mov    %eax,(%ebx)
  800210:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800213:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800217:	3d ff 00 00 00       	cmp    $0xff,%eax
  80021c:	75 19                	jne    800237 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80021e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800225:	00 
  800226:	8d 43 08             	lea    0x8(%ebx),%eax
  800229:	89 04 24             	mov    %eax,(%esp)
  80022c:	e8 e5 09 00 00       	call   800c16 <sys_cputs>
		b->idx = 0;
  800231:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800237:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80023b:	83 c4 14             	add    $0x14,%esp
  80023e:	5b                   	pop    %ebx
  80023f:	5d                   	pop    %ebp
  800240:	c3                   	ret    

00800241 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800241:	55                   	push   %ebp
  800242:	89 e5                	mov    %esp,%ebp
  800244:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80024a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800251:	00 00 00 
	b.cnt = 0;
  800254:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80025b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80025e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800261:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800265:	8b 45 08             	mov    0x8(%ebp),%eax
  800268:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800272:	89 44 24 04          	mov    %eax,0x4(%esp)
  800276:	c7 04 24 ff 01 80 00 	movl   $0x8001ff,(%esp)
  80027d:	e8 ac 01 00 00       	call   80042e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800282:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800288:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800292:	89 04 24             	mov    %eax,(%esp)
  800295:	e8 7c 09 00 00       	call   800c16 <sys_cputs>

	return b.cnt;
}
  80029a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002a0:	c9                   	leave  
  8002a1:	c3                   	ret    

008002a2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002a8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002af:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b2:	89 04 24             	mov    %eax,(%esp)
  8002b5:	e8 87 ff ff ff       	call   800241 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002ba:	c9                   	leave  
  8002bb:	c3                   	ret    
  8002bc:	66 90                	xchg   %ax,%ax
  8002be:	66 90                	xchg   %ax,%ax

008002c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
  8002c6:	83 ec 3c             	sub    $0x3c,%esp
  8002c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002cc:	89 d7                	mov    %edx,%edi
  8002ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002d7:	89 c3                	mov    %eax,%ebx
  8002d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002df:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002ed:	39 d9                	cmp    %ebx,%ecx
  8002ef:	72 05                	jb     8002f6 <printnum+0x36>
  8002f1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002f4:	77 69                	ja     80035f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002f9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002fd:	83 ee 01             	sub    $0x1,%esi
  800300:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800304:	89 44 24 08          	mov    %eax,0x8(%esp)
  800308:	8b 44 24 08          	mov    0x8(%esp),%eax
  80030c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800310:	89 c3                	mov    %eax,%ebx
  800312:	89 d6                	mov    %edx,%esi
  800314:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800317:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80031a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80031e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800322:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800325:	89 04 24             	mov    %eax,(%esp)
  800328:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	e8 7c 24 00 00       	call   8027b0 <__udivdi3>
  800334:	89 d9                	mov    %ebx,%ecx
  800336:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80033a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80033e:	89 04 24             	mov    %eax,(%esp)
  800341:	89 54 24 04          	mov    %edx,0x4(%esp)
  800345:	89 fa                	mov    %edi,%edx
  800347:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80034a:	e8 71 ff ff ff       	call   8002c0 <printnum>
  80034f:	eb 1b                	jmp    80036c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800351:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800355:	8b 45 18             	mov    0x18(%ebp),%eax
  800358:	89 04 24             	mov    %eax,(%esp)
  80035b:	ff d3                	call   *%ebx
  80035d:	eb 03                	jmp    800362 <printnum+0xa2>
  80035f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800362:	83 ee 01             	sub    $0x1,%esi
  800365:	85 f6                	test   %esi,%esi
  800367:	7f e8                	jg     800351 <printnum+0x91>
  800369:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80036c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800370:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800374:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800377:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80037a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800382:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800385:	89 04 24             	mov    %eax,(%esp)
  800388:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80038b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038f:	e8 4c 25 00 00       	call   8028e0 <__umoddi3>
  800394:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800398:	0f be 80 93 2a 80 00 	movsbl 0x802a93(%eax),%eax
  80039f:	89 04 24             	mov    %eax,(%esp)
  8003a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003a5:	ff d0                	call   *%eax
}
  8003a7:	83 c4 3c             	add    $0x3c,%esp
  8003aa:	5b                   	pop    %ebx
  8003ab:	5e                   	pop    %esi
  8003ac:	5f                   	pop    %edi
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    

008003af <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b2:	83 fa 01             	cmp    $0x1,%edx
  8003b5:	7e 0e                	jle    8003c5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003b7:	8b 10                	mov    (%eax),%edx
  8003b9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003bc:	89 08                	mov    %ecx,(%eax)
  8003be:	8b 02                	mov    (%edx),%eax
  8003c0:	8b 52 04             	mov    0x4(%edx),%edx
  8003c3:	eb 22                	jmp    8003e7 <getuint+0x38>
	else if (lflag)
  8003c5:	85 d2                	test   %edx,%edx
  8003c7:	74 10                	je     8003d9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003c9:	8b 10                	mov    (%eax),%edx
  8003cb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ce:	89 08                	mov    %ecx,(%eax)
  8003d0:	8b 02                	mov    (%edx),%eax
  8003d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d7:	eb 0e                	jmp    8003e7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003d9:	8b 10                	mov    (%eax),%edx
  8003db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003de:	89 08                	mov    %ecx,(%eax)
  8003e0:	8b 02                	mov    (%edx),%eax
  8003e2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003e7:	5d                   	pop    %ebp
  8003e8:	c3                   	ret    

008003e9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ef:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f3:	8b 10                	mov    (%eax),%edx
  8003f5:	3b 50 04             	cmp    0x4(%eax),%edx
  8003f8:	73 0a                	jae    800404 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003fa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003fd:	89 08                	mov    %ecx,(%eax)
  8003ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800402:	88 02                	mov    %al,(%edx)
}
  800404:	5d                   	pop    %ebp
  800405:	c3                   	ret    

00800406 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800406:	55                   	push   %ebp
  800407:	89 e5                	mov    %esp,%ebp
  800409:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80040c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80040f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800413:	8b 45 10             	mov    0x10(%ebp),%eax
  800416:	89 44 24 08          	mov    %eax,0x8(%esp)
  80041a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80041d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800421:	8b 45 08             	mov    0x8(%ebp),%eax
  800424:	89 04 24             	mov    %eax,(%esp)
  800427:	e8 02 00 00 00       	call   80042e <vprintfmt>
	va_end(ap);
}
  80042c:	c9                   	leave  
  80042d:	c3                   	ret    

0080042e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
  800431:	57                   	push   %edi
  800432:	56                   	push   %esi
  800433:	53                   	push   %ebx
  800434:	83 ec 3c             	sub    $0x3c,%esp
  800437:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80043a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80043d:	eb 14                	jmp    800453 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80043f:	85 c0                	test   %eax,%eax
  800441:	0f 84 b3 03 00 00    	je     8007fa <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800447:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80044b:	89 04 24             	mov    %eax,(%esp)
  80044e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800451:	89 f3                	mov    %esi,%ebx
  800453:	8d 73 01             	lea    0x1(%ebx),%esi
  800456:	0f b6 03             	movzbl (%ebx),%eax
  800459:	83 f8 25             	cmp    $0x25,%eax
  80045c:	75 e1                	jne    80043f <vprintfmt+0x11>
  80045e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800462:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800469:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800470:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800477:	ba 00 00 00 00       	mov    $0x0,%edx
  80047c:	eb 1d                	jmp    80049b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800480:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800484:	eb 15                	jmp    80049b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800488:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80048c:	eb 0d                	jmp    80049b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80048e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800491:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800494:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80049e:	0f b6 0e             	movzbl (%esi),%ecx
  8004a1:	0f b6 c1             	movzbl %cl,%eax
  8004a4:	83 e9 23             	sub    $0x23,%ecx
  8004a7:	80 f9 55             	cmp    $0x55,%cl
  8004aa:	0f 87 2a 03 00 00    	ja     8007da <vprintfmt+0x3ac>
  8004b0:	0f b6 c9             	movzbl %cl,%ecx
  8004b3:	ff 24 8d e0 2b 80 00 	jmp    *0x802be0(,%ecx,4)
  8004ba:	89 de                	mov    %ebx,%esi
  8004bc:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004c1:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004c4:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8004c8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004cb:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004ce:	83 fb 09             	cmp    $0x9,%ebx
  8004d1:	77 36                	ja     800509 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d3:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004d6:	eb e9                	jmp    8004c1 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004db:	8d 48 04             	lea    0x4(%eax),%ecx
  8004de:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004e1:	8b 00                	mov    (%eax),%eax
  8004e3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e6:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004e8:	eb 22                	jmp    80050c <vprintfmt+0xde>
  8004ea:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004ed:	85 c9                	test   %ecx,%ecx
  8004ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f4:	0f 49 c1             	cmovns %ecx,%eax
  8004f7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fa:	89 de                	mov    %ebx,%esi
  8004fc:	eb 9d                	jmp    80049b <vprintfmt+0x6d>
  8004fe:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800500:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800507:	eb 92                	jmp    80049b <vprintfmt+0x6d>
  800509:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80050c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800510:	79 89                	jns    80049b <vprintfmt+0x6d>
  800512:	e9 77 ff ff ff       	jmp    80048e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800517:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051a:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80051c:	e9 7a ff ff ff       	jmp    80049b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8d 50 04             	lea    0x4(%eax),%edx
  800527:	89 55 14             	mov    %edx,0x14(%ebp)
  80052a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80052e:	8b 00                	mov    (%eax),%eax
  800530:	89 04 24             	mov    %eax,(%esp)
  800533:	ff 55 08             	call   *0x8(%ebp)
			break;
  800536:	e9 18 ff ff ff       	jmp    800453 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8d 50 04             	lea    0x4(%eax),%edx
  800541:	89 55 14             	mov    %edx,0x14(%ebp)
  800544:	8b 00                	mov    (%eax),%eax
  800546:	99                   	cltd   
  800547:	31 d0                	xor    %edx,%eax
  800549:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80054b:	83 f8 0f             	cmp    $0xf,%eax
  80054e:	7f 0b                	jg     80055b <vprintfmt+0x12d>
  800550:	8b 14 85 40 2d 80 00 	mov    0x802d40(,%eax,4),%edx
  800557:	85 d2                	test   %edx,%edx
  800559:	75 20                	jne    80057b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80055b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80055f:	c7 44 24 08 ab 2a 80 	movl   $0x802aab,0x8(%esp)
  800566:	00 
  800567:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80056b:	8b 45 08             	mov    0x8(%ebp),%eax
  80056e:	89 04 24             	mov    %eax,(%esp)
  800571:	e8 90 fe ff ff       	call   800406 <printfmt>
  800576:	e9 d8 fe ff ff       	jmp    800453 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80057b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80057f:	c7 44 24 08 2d 2f 80 	movl   $0x802f2d,0x8(%esp)
  800586:	00 
  800587:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80058b:	8b 45 08             	mov    0x8(%ebp),%eax
  80058e:	89 04 24             	mov    %eax,(%esp)
  800591:	e8 70 fe ff ff       	call   800406 <printfmt>
  800596:	e9 b8 fe ff ff       	jmp    800453 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80059e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005a1:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8d 50 04             	lea    0x4(%eax),%edx
  8005aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ad:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005af:	85 f6                	test   %esi,%esi
  8005b1:	b8 a4 2a 80 00       	mov    $0x802aa4,%eax
  8005b6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8005b9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005bd:	0f 84 97 00 00 00    	je     80065a <vprintfmt+0x22c>
  8005c3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005c7:	0f 8e 9b 00 00 00    	jle    800668 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005d1:	89 34 24             	mov    %esi,(%esp)
  8005d4:	e8 cf 02 00 00       	call   8008a8 <strnlen>
  8005d9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005dc:	29 c2                	sub    %eax,%edx
  8005de:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8005e1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005e8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ee:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005f1:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f3:	eb 0f                	jmp    800604 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8005f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005fc:	89 04 24             	mov    %eax,(%esp)
  8005ff:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800601:	83 eb 01             	sub    $0x1,%ebx
  800604:	85 db                	test   %ebx,%ebx
  800606:	7f ed                	jg     8005f5 <vprintfmt+0x1c7>
  800608:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80060b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80060e:	85 d2                	test   %edx,%edx
  800610:	b8 00 00 00 00       	mov    $0x0,%eax
  800615:	0f 49 c2             	cmovns %edx,%eax
  800618:	29 c2                	sub    %eax,%edx
  80061a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80061d:	89 d7                	mov    %edx,%edi
  80061f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800622:	eb 50                	jmp    800674 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800624:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800628:	74 1e                	je     800648 <vprintfmt+0x21a>
  80062a:	0f be d2             	movsbl %dl,%edx
  80062d:	83 ea 20             	sub    $0x20,%edx
  800630:	83 fa 5e             	cmp    $0x5e,%edx
  800633:	76 13                	jbe    800648 <vprintfmt+0x21a>
					putch('?', putdat);
  800635:	8b 45 0c             	mov    0xc(%ebp),%eax
  800638:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800643:	ff 55 08             	call   *0x8(%ebp)
  800646:	eb 0d                	jmp    800655 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800648:	8b 55 0c             	mov    0xc(%ebp),%edx
  80064b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80064f:	89 04 24             	mov    %eax,(%esp)
  800652:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800655:	83 ef 01             	sub    $0x1,%edi
  800658:	eb 1a                	jmp    800674 <vprintfmt+0x246>
  80065a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80065d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800660:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800663:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800666:	eb 0c                	jmp    800674 <vprintfmt+0x246>
  800668:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80066b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80066e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800671:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800674:	83 c6 01             	add    $0x1,%esi
  800677:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80067b:	0f be c2             	movsbl %dl,%eax
  80067e:	85 c0                	test   %eax,%eax
  800680:	74 27                	je     8006a9 <vprintfmt+0x27b>
  800682:	85 db                	test   %ebx,%ebx
  800684:	78 9e                	js     800624 <vprintfmt+0x1f6>
  800686:	83 eb 01             	sub    $0x1,%ebx
  800689:	79 99                	jns    800624 <vprintfmt+0x1f6>
  80068b:	89 f8                	mov    %edi,%eax
  80068d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800690:	8b 75 08             	mov    0x8(%ebp),%esi
  800693:	89 c3                	mov    %eax,%ebx
  800695:	eb 1a                	jmp    8006b1 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800697:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80069b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006a2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006a4:	83 eb 01             	sub    $0x1,%ebx
  8006a7:	eb 08                	jmp    8006b1 <vprintfmt+0x283>
  8006a9:	89 fb                	mov    %edi,%ebx
  8006ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ae:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006b1:	85 db                	test   %ebx,%ebx
  8006b3:	7f e2                	jg     800697 <vprintfmt+0x269>
  8006b5:	89 75 08             	mov    %esi,0x8(%ebp)
  8006b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006bb:	e9 93 fd ff ff       	jmp    800453 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006c0:	83 fa 01             	cmp    $0x1,%edx
  8006c3:	7e 16                	jle    8006db <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8d 50 08             	lea    0x8(%eax),%edx
  8006cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ce:	8b 50 04             	mov    0x4(%eax),%edx
  8006d1:	8b 00                	mov    (%eax),%eax
  8006d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006d6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006d9:	eb 32                	jmp    80070d <vprintfmt+0x2df>
	else if (lflag)
  8006db:	85 d2                	test   %edx,%edx
  8006dd:	74 18                	je     8006f7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e2:	8d 50 04             	lea    0x4(%eax),%edx
  8006e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e8:	8b 30                	mov    (%eax),%esi
  8006ea:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006ed:	89 f0                	mov    %esi,%eax
  8006ef:	c1 f8 1f             	sar    $0x1f,%eax
  8006f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006f5:	eb 16                	jmp    80070d <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8d 50 04             	lea    0x4(%eax),%edx
  8006fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800700:	8b 30                	mov    (%eax),%esi
  800702:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800705:	89 f0                	mov    %esi,%eax
  800707:	c1 f8 1f             	sar    $0x1f,%eax
  80070a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80070d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800710:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800713:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800718:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80071c:	0f 89 80 00 00 00    	jns    8007a2 <vprintfmt+0x374>
				putch('-', putdat);
  800722:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800726:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80072d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800730:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800733:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800736:	f7 d8                	neg    %eax
  800738:	83 d2 00             	adc    $0x0,%edx
  80073b:	f7 da                	neg    %edx
			}
			base = 10;
  80073d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800742:	eb 5e                	jmp    8007a2 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800744:	8d 45 14             	lea    0x14(%ebp),%eax
  800747:	e8 63 fc ff ff       	call   8003af <getuint>
			base = 10;
  80074c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800751:	eb 4f                	jmp    8007a2 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800753:	8d 45 14             	lea    0x14(%ebp),%eax
  800756:	e8 54 fc ff ff       	call   8003af <getuint>
			base = 8;
  80075b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800760:	eb 40                	jmp    8007a2 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800762:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800766:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80076d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800770:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800774:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80077b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80077e:	8b 45 14             	mov    0x14(%ebp),%eax
  800781:	8d 50 04             	lea    0x4(%eax),%edx
  800784:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800787:	8b 00                	mov    (%eax),%eax
  800789:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80078e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800793:	eb 0d                	jmp    8007a2 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800795:	8d 45 14             	lea    0x14(%ebp),%eax
  800798:	e8 12 fc ff ff       	call   8003af <getuint>
			base = 16;
  80079d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007a2:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8007a6:	89 74 24 10          	mov    %esi,0x10(%esp)
  8007aa:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8007ad:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8007b1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007b5:	89 04 24             	mov    %eax,(%esp)
  8007b8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007bc:	89 fa                	mov    %edi,%edx
  8007be:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c1:	e8 fa fa ff ff       	call   8002c0 <printnum>
			break;
  8007c6:	e9 88 fc ff ff       	jmp    800453 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007cb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007cf:	89 04 24             	mov    %eax,(%esp)
  8007d2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007d5:	e9 79 fc ff ff       	jmp    800453 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007de:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007e5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e8:	89 f3                	mov    %esi,%ebx
  8007ea:	eb 03                	jmp    8007ef <vprintfmt+0x3c1>
  8007ec:	83 eb 01             	sub    $0x1,%ebx
  8007ef:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007f3:	75 f7                	jne    8007ec <vprintfmt+0x3be>
  8007f5:	e9 59 fc ff ff       	jmp    800453 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8007fa:	83 c4 3c             	add    $0x3c,%esp
  8007fd:	5b                   	pop    %ebx
  8007fe:	5e                   	pop    %esi
  8007ff:	5f                   	pop    %edi
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	83 ec 28             	sub    $0x28,%esp
  800808:	8b 45 08             	mov    0x8(%ebp),%eax
  80080b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800811:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800815:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800818:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80081f:	85 c0                	test   %eax,%eax
  800821:	74 30                	je     800853 <vsnprintf+0x51>
  800823:	85 d2                	test   %edx,%edx
  800825:	7e 2c                	jle    800853 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800827:	8b 45 14             	mov    0x14(%ebp),%eax
  80082a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80082e:	8b 45 10             	mov    0x10(%ebp),%eax
  800831:	89 44 24 08          	mov    %eax,0x8(%esp)
  800835:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800838:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083c:	c7 04 24 e9 03 80 00 	movl   $0x8003e9,(%esp)
  800843:	e8 e6 fb ff ff       	call   80042e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800848:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80084b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80084e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800851:	eb 05                	jmp    800858 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800853:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800858:	c9                   	leave  
  800859:	c3                   	ret    

0080085a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800860:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800863:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800867:	8b 45 10             	mov    0x10(%ebp),%eax
  80086a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80086e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800871:	89 44 24 04          	mov    %eax,0x4(%esp)
  800875:	8b 45 08             	mov    0x8(%ebp),%eax
  800878:	89 04 24             	mov    %eax,(%esp)
  80087b:	e8 82 ff ff ff       	call   800802 <vsnprintf>
	va_end(ap);

	return rc;
}
  800880:	c9                   	leave  
  800881:	c3                   	ret    
  800882:	66 90                	xchg   %ax,%ax
  800884:	66 90                	xchg   %ax,%ax
  800886:	66 90                	xchg   %ax,%ax
  800888:	66 90                	xchg   %ax,%ax
  80088a:	66 90                	xchg   %ax,%ax
  80088c:	66 90                	xchg   %ax,%ax
  80088e:	66 90                	xchg   %ax,%ax

00800890 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800896:	b8 00 00 00 00       	mov    $0x0,%eax
  80089b:	eb 03                	jmp    8008a0 <strlen+0x10>
		n++;
  80089d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008a4:	75 f7                	jne    80089d <strlen+0xd>
		n++;
	return n;
}
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ae:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b6:	eb 03                	jmp    8008bb <strnlen+0x13>
		n++;
  8008b8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008bb:	39 d0                	cmp    %edx,%eax
  8008bd:	74 06                	je     8008c5 <strnlen+0x1d>
  8008bf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008c3:	75 f3                	jne    8008b8 <strnlen+0x10>
		n++;
	return n;
}
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	53                   	push   %ebx
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008d1:	89 c2                	mov    %eax,%edx
  8008d3:	83 c2 01             	add    $0x1,%edx
  8008d6:	83 c1 01             	add    $0x1,%ecx
  8008d9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008dd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008e0:	84 db                	test   %bl,%bl
  8008e2:	75 ef                	jne    8008d3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008e4:	5b                   	pop    %ebx
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	53                   	push   %ebx
  8008eb:	83 ec 08             	sub    $0x8,%esp
  8008ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008f1:	89 1c 24             	mov    %ebx,(%esp)
  8008f4:	e8 97 ff ff ff       	call   800890 <strlen>
	strcpy(dst + len, src);
  8008f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800900:	01 d8                	add    %ebx,%eax
  800902:	89 04 24             	mov    %eax,(%esp)
  800905:	e8 bd ff ff ff       	call   8008c7 <strcpy>
	return dst;
}
  80090a:	89 d8                	mov    %ebx,%eax
  80090c:	83 c4 08             	add    $0x8,%esp
  80090f:	5b                   	pop    %ebx
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	56                   	push   %esi
  800916:	53                   	push   %ebx
  800917:	8b 75 08             	mov    0x8(%ebp),%esi
  80091a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091d:	89 f3                	mov    %esi,%ebx
  80091f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800922:	89 f2                	mov    %esi,%edx
  800924:	eb 0f                	jmp    800935 <strncpy+0x23>
		*dst++ = *src;
  800926:	83 c2 01             	add    $0x1,%edx
  800929:	0f b6 01             	movzbl (%ecx),%eax
  80092c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80092f:	80 39 01             	cmpb   $0x1,(%ecx)
  800932:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800935:	39 da                	cmp    %ebx,%edx
  800937:	75 ed                	jne    800926 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800939:	89 f0                	mov    %esi,%eax
  80093b:	5b                   	pop    %ebx
  80093c:	5e                   	pop    %esi
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	56                   	push   %esi
  800943:	53                   	push   %ebx
  800944:	8b 75 08             	mov    0x8(%ebp),%esi
  800947:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80094d:	89 f0                	mov    %esi,%eax
  80094f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800953:	85 c9                	test   %ecx,%ecx
  800955:	75 0b                	jne    800962 <strlcpy+0x23>
  800957:	eb 1d                	jmp    800976 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800959:	83 c0 01             	add    $0x1,%eax
  80095c:	83 c2 01             	add    $0x1,%edx
  80095f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800962:	39 d8                	cmp    %ebx,%eax
  800964:	74 0b                	je     800971 <strlcpy+0x32>
  800966:	0f b6 0a             	movzbl (%edx),%ecx
  800969:	84 c9                	test   %cl,%cl
  80096b:	75 ec                	jne    800959 <strlcpy+0x1a>
  80096d:	89 c2                	mov    %eax,%edx
  80096f:	eb 02                	jmp    800973 <strlcpy+0x34>
  800971:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800973:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800976:	29 f0                	sub    %esi,%eax
}
  800978:	5b                   	pop    %ebx
  800979:	5e                   	pop    %esi
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800982:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800985:	eb 06                	jmp    80098d <strcmp+0x11>
		p++, q++;
  800987:	83 c1 01             	add    $0x1,%ecx
  80098a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80098d:	0f b6 01             	movzbl (%ecx),%eax
  800990:	84 c0                	test   %al,%al
  800992:	74 04                	je     800998 <strcmp+0x1c>
  800994:	3a 02                	cmp    (%edx),%al
  800996:	74 ef                	je     800987 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800998:	0f b6 c0             	movzbl %al,%eax
  80099b:	0f b6 12             	movzbl (%edx),%edx
  80099e:	29 d0                	sub    %edx,%eax
}
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	53                   	push   %ebx
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ac:	89 c3                	mov    %eax,%ebx
  8009ae:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009b1:	eb 06                	jmp    8009b9 <strncmp+0x17>
		n--, p++, q++;
  8009b3:	83 c0 01             	add    $0x1,%eax
  8009b6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009b9:	39 d8                	cmp    %ebx,%eax
  8009bb:	74 15                	je     8009d2 <strncmp+0x30>
  8009bd:	0f b6 08             	movzbl (%eax),%ecx
  8009c0:	84 c9                	test   %cl,%cl
  8009c2:	74 04                	je     8009c8 <strncmp+0x26>
  8009c4:	3a 0a                	cmp    (%edx),%cl
  8009c6:	74 eb                	je     8009b3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c8:	0f b6 00             	movzbl (%eax),%eax
  8009cb:	0f b6 12             	movzbl (%edx),%edx
  8009ce:	29 d0                	sub    %edx,%eax
  8009d0:	eb 05                	jmp    8009d7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009d2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009d7:	5b                   	pop    %ebx
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e4:	eb 07                	jmp    8009ed <strchr+0x13>
		if (*s == c)
  8009e6:	38 ca                	cmp    %cl,%dl
  8009e8:	74 0f                	je     8009f9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ea:	83 c0 01             	add    $0x1,%eax
  8009ed:	0f b6 10             	movzbl (%eax),%edx
  8009f0:	84 d2                	test   %dl,%dl
  8009f2:	75 f2                	jne    8009e6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a05:	eb 07                	jmp    800a0e <strfind+0x13>
		if (*s == c)
  800a07:	38 ca                	cmp    %cl,%dl
  800a09:	74 0a                	je     800a15 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a0b:	83 c0 01             	add    $0x1,%eax
  800a0e:	0f b6 10             	movzbl (%eax),%edx
  800a11:	84 d2                	test   %dl,%dl
  800a13:	75 f2                	jne    800a07 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	57                   	push   %edi
  800a1b:	56                   	push   %esi
  800a1c:	53                   	push   %ebx
  800a1d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a20:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a23:	85 c9                	test   %ecx,%ecx
  800a25:	74 36                	je     800a5d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a27:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a2d:	75 28                	jne    800a57 <memset+0x40>
  800a2f:	f6 c1 03             	test   $0x3,%cl
  800a32:	75 23                	jne    800a57 <memset+0x40>
		c &= 0xFF;
  800a34:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a38:	89 d3                	mov    %edx,%ebx
  800a3a:	c1 e3 08             	shl    $0x8,%ebx
  800a3d:	89 d6                	mov    %edx,%esi
  800a3f:	c1 e6 18             	shl    $0x18,%esi
  800a42:	89 d0                	mov    %edx,%eax
  800a44:	c1 e0 10             	shl    $0x10,%eax
  800a47:	09 f0                	or     %esi,%eax
  800a49:	09 c2                	or     %eax,%edx
  800a4b:	89 d0                	mov    %edx,%eax
  800a4d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a4f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a52:	fc                   	cld    
  800a53:	f3 ab                	rep stos %eax,%es:(%edi)
  800a55:	eb 06                	jmp    800a5d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5a:	fc                   	cld    
  800a5b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a5d:	89 f8                	mov    %edi,%eax
  800a5f:	5b                   	pop    %ebx
  800a60:	5e                   	pop    %esi
  800a61:	5f                   	pop    %edi
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	57                   	push   %edi
  800a68:	56                   	push   %esi
  800a69:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a72:	39 c6                	cmp    %eax,%esi
  800a74:	73 35                	jae    800aab <memmove+0x47>
  800a76:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a79:	39 d0                	cmp    %edx,%eax
  800a7b:	73 2e                	jae    800aab <memmove+0x47>
		s += n;
		d += n;
  800a7d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a80:	89 d6                	mov    %edx,%esi
  800a82:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a84:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a8a:	75 13                	jne    800a9f <memmove+0x3b>
  800a8c:	f6 c1 03             	test   $0x3,%cl
  800a8f:	75 0e                	jne    800a9f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a91:	83 ef 04             	sub    $0x4,%edi
  800a94:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a97:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a9a:	fd                   	std    
  800a9b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a9d:	eb 09                	jmp    800aa8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a9f:	83 ef 01             	sub    $0x1,%edi
  800aa2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aa5:	fd                   	std    
  800aa6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aa8:	fc                   	cld    
  800aa9:	eb 1d                	jmp    800ac8 <memmove+0x64>
  800aab:	89 f2                	mov    %esi,%edx
  800aad:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aaf:	f6 c2 03             	test   $0x3,%dl
  800ab2:	75 0f                	jne    800ac3 <memmove+0x5f>
  800ab4:	f6 c1 03             	test   $0x3,%cl
  800ab7:	75 0a                	jne    800ac3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ab9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800abc:	89 c7                	mov    %eax,%edi
  800abe:	fc                   	cld    
  800abf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac1:	eb 05                	jmp    800ac8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ac3:	89 c7                	mov    %eax,%edi
  800ac5:	fc                   	cld    
  800ac6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ac8:	5e                   	pop    %esi
  800ac9:	5f                   	pop    %edi
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ad2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ad5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ad9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800adc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae3:	89 04 24             	mov    %eax,(%esp)
  800ae6:	e8 79 ff ff ff       	call   800a64 <memmove>
}
  800aeb:	c9                   	leave  
  800aec:	c3                   	ret    

00800aed <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
  800af2:	8b 55 08             	mov    0x8(%ebp),%edx
  800af5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af8:	89 d6                	mov    %edx,%esi
  800afa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afd:	eb 1a                	jmp    800b19 <memcmp+0x2c>
		if (*s1 != *s2)
  800aff:	0f b6 02             	movzbl (%edx),%eax
  800b02:	0f b6 19             	movzbl (%ecx),%ebx
  800b05:	38 d8                	cmp    %bl,%al
  800b07:	74 0a                	je     800b13 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b09:	0f b6 c0             	movzbl %al,%eax
  800b0c:	0f b6 db             	movzbl %bl,%ebx
  800b0f:	29 d8                	sub    %ebx,%eax
  800b11:	eb 0f                	jmp    800b22 <memcmp+0x35>
		s1++, s2++;
  800b13:	83 c2 01             	add    $0x1,%edx
  800b16:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b19:	39 f2                	cmp    %esi,%edx
  800b1b:	75 e2                	jne    800aff <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b22:	5b                   	pop    %ebx
  800b23:	5e                   	pop    %esi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b2f:	89 c2                	mov    %eax,%edx
  800b31:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b34:	eb 07                	jmp    800b3d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b36:	38 08                	cmp    %cl,(%eax)
  800b38:	74 07                	je     800b41 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b3a:	83 c0 01             	add    $0x1,%eax
  800b3d:	39 d0                	cmp    %edx,%eax
  800b3f:	72 f5                	jb     800b36 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
  800b49:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b4f:	eb 03                	jmp    800b54 <strtol+0x11>
		s++;
  800b51:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b54:	0f b6 0a             	movzbl (%edx),%ecx
  800b57:	80 f9 09             	cmp    $0x9,%cl
  800b5a:	74 f5                	je     800b51 <strtol+0xe>
  800b5c:	80 f9 20             	cmp    $0x20,%cl
  800b5f:	74 f0                	je     800b51 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b61:	80 f9 2b             	cmp    $0x2b,%cl
  800b64:	75 0a                	jne    800b70 <strtol+0x2d>
		s++;
  800b66:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b69:	bf 00 00 00 00       	mov    $0x0,%edi
  800b6e:	eb 11                	jmp    800b81 <strtol+0x3e>
  800b70:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b75:	80 f9 2d             	cmp    $0x2d,%cl
  800b78:	75 07                	jne    800b81 <strtol+0x3e>
		s++, neg = 1;
  800b7a:	8d 52 01             	lea    0x1(%edx),%edx
  800b7d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b81:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b86:	75 15                	jne    800b9d <strtol+0x5a>
  800b88:	80 3a 30             	cmpb   $0x30,(%edx)
  800b8b:	75 10                	jne    800b9d <strtol+0x5a>
  800b8d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b91:	75 0a                	jne    800b9d <strtol+0x5a>
		s += 2, base = 16;
  800b93:	83 c2 02             	add    $0x2,%edx
  800b96:	b8 10 00 00 00       	mov    $0x10,%eax
  800b9b:	eb 10                	jmp    800bad <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800b9d:	85 c0                	test   %eax,%eax
  800b9f:	75 0c                	jne    800bad <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ba1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ba3:	80 3a 30             	cmpb   $0x30,(%edx)
  800ba6:	75 05                	jne    800bad <strtol+0x6a>
		s++, base = 8;
  800ba8:	83 c2 01             	add    $0x1,%edx
  800bab:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800bad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bb5:	0f b6 0a             	movzbl (%edx),%ecx
  800bb8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800bbb:	89 f0                	mov    %esi,%eax
  800bbd:	3c 09                	cmp    $0x9,%al
  800bbf:	77 08                	ja     800bc9 <strtol+0x86>
			dig = *s - '0';
  800bc1:	0f be c9             	movsbl %cl,%ecx
  800bc4:	83 e9 30             	sub    $0x30,%ecx
  800bc7:	eb 20                	jmp    800be9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800bc9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800bcc:	89 f0                	mov    %esi,%eax
  800bce:	3c 19                	cmp    $0x19,%al
  800bd0:	77 08                	ja     800bda <strtol+0x97>
			dig = *s - 'a' + 10;
  800bd2:	0f be c9             	movsbl %cl,%ecx
  800bd5:	83 e9 57             	sub    $0x57,%ecx
  800bd8:	eb 0f                	jmp    800be9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800bda:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800bdd:	89 f0                	mov    %esi,%eax
  800bdf:	3c 19                	cmp    $0x19,%al
  800be1:	77 16                	ja     800bf9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800be3:	0f be c9             	movsbl %cl,%ecx
  800be6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800be9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800bec:	7d 0f                	jge    800bfd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800bee:	83 c2 01             	add    $0x1,%edx
  800bf1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800bf5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800bf7:	eb bc                	jmp    800bb5 <strtol+0x72>
  800bf9:	89 d8                	mov    %ebx,%eax
  800bfb:	eb 02                	jmp    800bff <strtol+0xbc>
  800bfd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800bff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c03:	74 05                	je     800c0a <strtol+0xc7>
		*endptr = (char *) s;
  800c05:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c08:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c0a:	f7 d8                	neg    %eax
  800c0c:	85 ff                	test   %edi,%edi
  800c0e:	0f 44 c3             	cmove  %ebx,%eax
}
  800c11:	5b                   	pop    %ebx
  800c12:	5e                   	pop    %esi
  800c13:	5f                   	pop    %edi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	57                   	push   %edi
  800c1a:	56                   	push   %esi
  800c1b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c24:	8b 55 08             	mov    0x8(%ebp),%edx
  800c27:	89 c3                	mov    %eax,%ebx
  800c29:	89 c7                	mov    %eax,%edi
  800c2b:	89 c6                	mov    %eax,%esi
  800c2d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c44:	89 d1                	mov    %edx,%ecx
  800c46:	89 d3                	mov    %edx,%ebx
  800c48:	89 d7                	mov    %edx,%edi
  800c4a:	89 d6                	mov    %edx,%esi
  800c4c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c4e:	5b                   	pop    %ebx
  800c4f:	5e                   	pop    %esi
  800c50:	5f                   	pop    %edi
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    

00800c53 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	57                   	push   %edi
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c61:	b8 03 00 00 00       	mov    $0x3,%eax
  800c66:	8b 55 08             	mov    0x8(%ebp),%edx
  800c69:	89 cb                	mov    %ecx,%ebx
  800c6b:	89 cf                	mov    %ecx,%edi
  800c6d:	89 ce                	mov    %ecx,%esi
  800c6f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c71:	85 c0                	test   %eax,%eax
  800c73:	7e 28                	jle    800c9d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c75:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c79:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c80:	00 
  800c81:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800c88:	00 
  800c89:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c90:	00 
  800c91:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800c98:	e8 0c f5 ff ff       	call   8001a9 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c9d:	83 c4 2c             	add    $0x2c,%esp
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cab:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb0:	b8 02 00 00 00       	mov    $0x2,%eax
  800cb5:	89 d1                	mov    %edx,%ecx
  800cb7:	89 d3                	mov    %edx,%ebx
  800cb9:	89 d7                	mov    %edx,%edi
  800cbb:	89 d6                	mov    %edx,%esi
  800cbd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_yield>:

void
sys_yield(void)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cca:	ba 00 00 00 00       	mov    $0x0,%edx
  800ccf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd4:	89 d1                	mov    %edx,%ecx
  800cd6:	89 d3                	mov    %edx,%ebx
  800cd8:	89 d7                	mov    %edx,%edi
  800cda:	89 d6                	mov    %edx,%esi
  800cdc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	5f                   	pop    %edi
  800ce1:	5d                   	pop    %ebp
  800ce2:	c3                   	ret    

00800ce3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	57                   	push   %edi
  800ce7:	56                   	push   %esi
  800ce8:	53                   	push   %ebx
  800ce9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cec:	be 00 00 00 00       	mov    $0x0,%esi
  800cf1:	b8 04 00 00 00       	mov    $0x4,%eax
  800cf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cff:	89 f7                	mov    %esi,%edi
  800d01:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d03:	85 c0                	test   %eax,%eax
  800d05:	7e 28                	jle    800d2f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d07:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d0b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d12:	00 
  800d13:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800d1a:	00 
  800d1b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d22:	00 
  800d23:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800d2a:	e8 7a f4 ff ff       	call   8001a9 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d2f:	83 c4 2c             	add    $0x2c,%esp
  800d32:	5b                   	pop    %ebx
  800d33:	5e                   	pop    %esi
  800d34:	5f                   	pop    %edi
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    

00800d37 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	57                   	push   %edi
  800d3b:	56                   	push   %esi
  800d3c:	53                   	push   %ebx
  800d3d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d40:	b8 05 00 00 00       	mov    $0x5,%eax
  800d45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d48:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d4e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d51:	8b 75 18             	mov    0x18(%ebp),%esi
  800d54:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d56:	85 c0                	test   %eax,%eax
  800d58:	7e 28                	jle    800d82 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d65:	00 
  800d66:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800d6d:	00 
  800d6e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d75:	00 
  800d76:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800d7d:	e8 27 f4 ff ff       	call   8001a9 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d82:	83 c4 2c             	add    $0x2c,%esp
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
  800d90:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d98:	b8 06 00 00 00       	mov    $0x6,%eax
  800d9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da0:	8b 55 08             	mov    0x8(%ebp),%edx
  800da3:	89 df                	mov    %ebx,%edi
  800da5:	89 de                	mov    %ebx,%esi
  800da7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da9:	85 c0                	test   %eax,%eax
  800dab:	7e 28                	jle    800dd5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dad:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800db8:	00 
  800db9:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800dc0:	00 
  800dc1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc8:	00 
  800dc9:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800dd0:	e8 d4 f3 ff ff       	call   8001a9 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dd5:	83 c4 2c             	add    $0x2c,%esp
  800dd8:	5b                   	pop    %ebx
  800dd9:	5e                   	pop    %esi
  800dda:	5f                   	pop    %edi
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    

00800ddd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	57                   	push   %edi
  800de1:	56                   	push   %esi
  800de2:	53                   	push   %ebx
  800de3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800deb:	b8 08 00 00 00       	mov    $0x8,%eax
  800df0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df3:	8b 55 08             	mov    0x8(%ebp),%edx
  800df6:	89 df                	mov    %ebx,%edi
  800df8:	89 de                	mov    %ebx,%esi
  800dfa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	7e 28                	jle    800e28 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e00:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e04:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e0b:	00 
  800e0c:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800e13:	00 
  800e14:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e1b:	00 
  800e1c:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800e23:	e8 81 f3 ff ff       	call   8001a9 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e28:	83 c4 2c             	add    $0x2c,%esp
  800e2b:	5b                   	pop    %ebx
  800e2c:	5e                   	pop    %esi
  800e2d:	5f                   	pop    %edi
  800e2e:	5d                   	pop    %ebp
  800e2f:	c3                   	ret    

00800e30 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
  800e33:	57                   	push   %edi
  800e34:	56                   	push   %esi
  800e35:	53                   	push   %ebx
  800e36:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e39:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3e:	b8 09 00 00 00       	mov    $0x9,%eax
  800e43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e46:	8b 55 08             	mov    0x8(%ebp),%edx
  800e49:	89 df                	mov    %ebx,%edi
  800e4b:	89 de                	mov    %ebx,%esi
  800e4d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	7e 28                	jle    800e7b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e53:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e57:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e5e:	00 
  800e5f:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800e66:	00 
  800e67:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e6e:	00 
  800e6f:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800e76:	e8 2e f3 ff ff       	call   8001a9 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e7b:	83 c4 2c             	add    $0x2c,%esp
  800e7e:	5b                   	pop    %ebx
  800e7f:	5e                   	pop    %esi
  800e80:	5f                   	pop    %edi
  800e81:	5d                   	pop    %ebp
  800e82:	c3                   	ret    

00800e83 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	57                   	push   %edi
  800e87:	56                   	push   %esi
  800e88:	53                   	push   %ebx
  800e89:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e91:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e99:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9c:	89 df                	mov    %ebx,%edi
  800e9e:	89 de                	mov    %ebx,%esi
  800ea0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea2:	85 c0                	test   %eax,%eax
  800ea4:	7e 28                	jle    800ece <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eaa:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800eb1:	00 
  800eb2:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800eb9:	00 
  800eba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec1:	00 
  800ec2:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800ec9:	e8 db f2 ff ff       	call   8001a9 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ece:	83 c4 2c             	add    $0x2c,%esp
  800ed1:	5b                   	pop    %ebx
  800ed2:	5e                   	pop    %esi
  800ed3:	5f                   	pop    %edi
  800ed4:	5d                   	pop    %ebp
  800ed5:	c3                   	ret    

00800ed6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	57                   	push   %edi
  800eda:	56                   	push   %esi
  800edb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800edc:	be 00 00 00 00       	mov    $0x0,%esi
  800ee1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ee6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee9:	8b 55 08             	mov    0x8(%ebp),%edx
  800eec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eef:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ef2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ef4:	5b                   	pop    %ebx
  800ef5:	5e                   	pop    %esi
  800ef6:	5f                   	pop    %edi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    

00800ef9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	57                   	push   %edi
  800efd:	56                   	push   %esi
  800efe:	53                   	push   %ebx
  800eff:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f07:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0f:	89 cb                	mov    %ecx,%ebx
  800f11:	89 cf                	mov    %ecx,%edi
  800f13:	89 ce                	mov    %ecx,%esi
  800f15:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f17:	85 c0                	test   %eax,%eax
  800f19:	7e 28                	jle    800f43 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f26:	00 
  800f27:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800f2e:	00 
  800f2f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f36:	00 
  800f37:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800f3e:	e8 66 f2 ff ff       	call   8001a9 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f43:	83 c4 2c             	add    $0x2c,%esp
  800f46:	5b                   	pop    %ebx
  800f47:	5e                   	pop    %esi
  800f48:	5f                   	pop    %edi
  800f49:	5d                   	pop    %ebp
  800f4a:	c3                   	ret    

00800f4b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	57                   	push   %edi
  800f4f:	56                   	push   %esi
  800f50:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f51:	ba 00 00 00 00       	mov    $0x0,%edx
  800f56:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f5b:	89 d1                	mov    %edx,%ecx
  800f5d:	89 d3                	mov    %edx,%ebx
  800f5f:	89 d7                	mov    %edx,%edi
  800f61:	89 d6                	mov    %edx,%esi
  800f63:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f65:	5b                   	pop    %ebx
  800f66:	5e                   	pop    %esi
  800f67:	5f                   	pop    %edi
  800f68:	5d                   	pop    %ebp
  800f69:	c3                   	ret    

00800f6a <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	57                   	push   %edi
  800f6e:	56                   	push   %esi
  800f6f:	53                   	push   %ebx
  800f70:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f78:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f80:	8b 55 08             	mov    0x8(%ebp),%edx
  800f83:	89 df                	mov    %ebx,%edi
  800f85:	89 de                	mov    %ebx,%esi
  800f87:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	7e 28                	jle    800fb5 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f91:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800f98:	00 
  800f99:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800fa0:	00 
  800fa1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa8:	00 
  800fa9:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800fb0:	e8 f4 f1 ff ff       	call   8001a9 <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  800fb5:	83 c4 2c             	add    $0x2c,%esp
  800fb8:	5b                   	pop    %ebx
  800fb9:	5e                   	pop    %esi
  800fba:	5f                   	pop    %edi
  800fbb:	5d                   	pop    %ebp
  800fbc:	c3                   	ret    

00800fbd <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  800fbd:	55                   	push   %ebp
  800fbe:	89 e5                	mov    %esp,%ebp
  800fc0:	57                   	push   %edi
  800fc1:	56                   	push   %esi
  800fc2:	53                   	push   %ebx
  800fc3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fcb:	b8 10 00 00 00       	mov    $0x10,%eax
  800fd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd6:	89 df                	mov    %ebx,%edi
  800fd8:	89 de                	mov    %ebx,%esi
  800fda:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	7e 28                	jle    801008 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fe4:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  800feb:	00 
  800fec:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800ff3:	00 
  800ff4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ffb:	00 
  800ffc:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  801003:	e8 a1 f1 ff ff       	call   8001a9 <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  801008:	83 c4 2c             	add    $0x2c,%esp
  80100b:	5b                   	pop    %ebx
  80100c:	5e                   	pop    %esi
  80100d:	5f                   	pop    %edi
  80100e:	5d                   	pop    %ebp
  80100f:	c3                   	ret    

00801010 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	56                   	push   %esi
  801014:	53                   	push   %ebx
  801015:	83 ec 20             	sub    $0x20,%esp
  801018:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80101b:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if(!(err & FEC_WR)) {
  80101d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801021:	75 20                	jne    801043 <pgfault+0x33>
		panic("0x%x Not a write", addr);
  801023:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801027:	c7 44 24 08 ca 2d 80 	movl   $0x802dca,0x8(%esp)
  80102e:	00 
  80102f:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801036:	00 
  801037:	c7 04 24 db 2d 80 00 	movl   $0x802ddb,(%esp)
  80103e:	e8 66 f1 ff ff       	call   8001a9 <_panic>
	}

	if(!(uvpt[PGNUM(addr)] & PTE_COW)) {
  801043:	89 f0                	mov    %esi,%eax
  801045:	c1 e8 0c             	shr    $0xc,%eax
  801048:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80104f:	f6 c4 08             	test   $0x8,%ah
  801052:	75 1c                	jne    801070 <pgfault+0x60>
		panic("Not a COW page");
  801054:	c7 44 24 08 e6 2d 80 	movl   $0x802de6,0x8(%esp)
  80105b:	00 
  80105c:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  801063:	00 
  801064:	c7 04 24 db 2d 80 00 	movl   $0x802ddb,(%esp)
  80106b:	e8 39 f1 ff ff       	call   8001a9 <_panic>

	// Allocate a new page, map it at a temporary location (PFTEMP), // copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	envid_t envid = sys_getenvid();
  801070:	e8 30 fc ff ff       	call   800ca5 <sys_getenvid>
  801075:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, PFTEMP, PTE_W | PTE_U | PTE_P);
  801077:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80107e:	00 
  80107f:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801086:	00 
  801087:	89 04 24             	mov    %eax,(%esp)
  80108a:	e8 54 fc ff ff       	call   800ce3 <sys_page_alloc>
	if(r < 0) {
  80108f:	85 c0                	test   %eax,%eax
  801091:	79 1c                	jns    8010af <pgfault+0x9f>
		panic("couldn't allocate page");
  801093:	c7 44 24 08 f5 2d 80 	movl   $0x802df5,0x8(%esp)
  80109a:	00 
  80109b:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8010a2:	00 
  8010a3:	c7 04 24 db 2d 80 00 	movl   $0x802ddb,(%esp)
  8010aa:	e8 fa f0 ff ff       	call   8001a9 <_panic>
	}

	memmove(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  8010af:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  8010b5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8010bc:	00 
  8010bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010c1:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8010c8:	e8 97 f9 ff ff       	call   800a64 <memmove>

	r = sys_page_map(envid, PFTEMP, envid, ROUNDDOWN(addr,PGSIZE), PTE_P | PTE_U | PTE_W);
  8010cd:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8010d4:	00 
  8010d5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010dd:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010e4:	00 
  8010e5:	89 1c 24             	mov    %ebx,(%esp)
  8010e8:	e8 4a fc ff ff       	call   800d37 <sys_page_map>
	if(r < 0) {
  8010ed:	85 c0                	test   %eax,%eax
  8010ef:	79 1c                	jns    80110d <pgfault+0xfd>
		panic("couldn't map page");
  8010f1:	c7 44 24 08 0c 2e 80 	movl   $0x802e0c,0x8(%esp)
  8010f8:	00 
  8010f9:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  801100:	00 
  801101:	c7 04 24 db 2d 80 00 	movl   $0x802ddb,(%esp)
  801108:	e8 9c f0 ff ff       	call   8001a9 <_panic>
	}
}
  80110d:	83 c4 20             	add    $0x20,%esp
  801110:	5b                   	pop    %ebx
  801111:	5e                   	pop    %esi
  801112:	5d                   	pop    %ebp
  801113:	c3                   	ret    

00801114 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	57                   	push   %edi
  801118:	56                   	push   %esi
  801119:	53                   	push   %ebx
  80111a:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envid;
	uintptr_t addr;
	int r = 0;

	set_pgfault_handler(pgfault);
  80111d:	c7 04 24 10 10 80 00 	movl   $0x801010,(%esp)
  801124:	e8 cd 15 00 00       	call   8026f6 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801129:	b8 07 00 00 00       	mov    $0x7,%eax
  80112e:	cd 30                	int    $0x30
  801130:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801133:	89 45 d8             	mov    %eax,-0x28(%ebp)

	envid = sys_exofork();
	if(envid == 0) {
  801136:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80113d:	bf 00 00 00 00       	mov    $0x0,%edi
  801142:	85 c0                	test   %eax,%eax
  801144:	75 21                	jne    801167 <fork+0x53>
		thisenv = &envs[ENVX(sys_getenvid())];
  801146:	e8 5a fb ff ff       	call   800ca5 <sys_getenvid>
  80114b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801150:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801153:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801158:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  80115d:	b8 00 00 00 00       	mov    $0x0,%eax
  801162:	e9 8d 01 00 00       	jmp    8012f4 <fork+0x1e0>
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
  801167:	89 f8                	mov    %edi,%eax
  801169:	c1 e8 16             	shr    $0x16,%eax
  80116c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801173:	85 c0                	test   %eax,%eax
  801175:	0f 84 02 01 00 00    	je     80127d <fork+0x169>
  80117b:	89 fa                	mov    %edi,%edx
  80117d:	c1 ea 0c             	shr    $0xc,%edx
  801180:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801187:	85 c0                	test   %eax,%eax
  801189:	0f 84 ee 00 00 00    	je     80127d <fork+0x169>
//
static int
duppage(envid_t envid, unsigned pn)
{

	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P)) return 0;
  80118f:	89 d6                	mov    %edx,%esi
  801191:	c1 e6 0c             	shl    $0xc,%esi
  801194:	89 f0                	mov    %esi,%eax
  801196:	c1 e8 16             	shr    $0x16,%eax
  801199:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8011a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a5:	f6 c1 01             	test   $0x1,%cl
  8011a8:	0f 84 cc 00 00 00    	je     80127a <fork+0x166>

	int all_perms = PTE_U | PTE_P | PTE_AVAIL | PTE_W | PTE_COW;
	int orig_perms = uvpt[pn] & all_perms;
  8011ae:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  8011b5:	89 d8                	mov    %ebx,%eax
  8011b7:	25 07 0e 00 00       	and    $0xe07,%eax
  8011bc:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if(!(orig_perms & PTE_P)) return 0;
  8011bf:	89 d8                	mov    %ebx,%eax
  8011c1:	83 e0 01             	and    $0x1,%eax
  8011c4:	0f 84 b0 00 00 00    	je     80127a <fork+0x166>

	int r = 0;
	envid_t curenvid = sys_getenvid();
  8011ca:	e8 d6 fa ff ff       	call   800ca5 <sys_getenvid>
  8011cf:	89 45 dc             	mov    %eax,-0x24(%ebp)


	if(orig_perms & PTE_SHARE) {
  8011d2:	f7 45 e0 00 04 00 00 	testl  $0x400,-0x20(%ebp)
  8011d9:	74 28                	je     801203 <fork+0xef>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms & PTE_SYSCALL));
  8011db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011de:	25 07 0e 00 00       	and    $0xe07,%eax
  8011e3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011e7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011eb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8011ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011f9:	89 04 24             	mov    %eax,(%esp)
  8011fc:	e8 36 fb ff ff       	call   800d37 <sys_page_map>
  801201:	eb 77                	jmp    80127a <fork+0x166>

	} else if(((orig_perms) & PTE_COW) || (orig_perms & PTE_W) ) {
  801203:	f7 c3 02 08 00 00    	test   $0x802,%ebx
  801209:	74 4e                	je     801259 <fork+0x145>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  80120b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80120e:	25 fd f7 ff ff       	and    $0xfffff7fd,%eax
  801213:	80 cc 08             	or     $0x8,%ah
  801216:	89 c3                	mov    %eax,%ebx
  801218:	89 44 24 10          	mov    %eax,0x10(%esp)
  80121c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801220:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801223:	89 44 24 08          	mov    %eax,0x8(%esp)
  801227:	89 74 24 04          	mov    %esi,0x4(%esp)
  80122b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80122e:	89 04 24             	mov    %eax,(%esp)
  801231:	e8 01 fb ff ff       	call   800d37 <sys_page_map>
  801236:	89 45 e0             	mov    %eax,-0x20(%ebp)

		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), curenvid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  801239:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80123d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801241:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801244:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801248:	89 74 24 04          	mov    %esi,0x4(%esp)
  80124c:	89 0c 24             	mov    %ecx,(%esp)
  80124f:	e8 e3 fa ff ff       	call   800d37 <sys_page_map>
  801254:	03 45 e0             	add    -0x20(%ebp),%eax
  801257:	eb 21                	jmp    80127a <fork+0x166>

	} else {
		r = sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), orig_perms);
  801259:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80125c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801260:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801264:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801267:	89 44 24 08          	mov    %eax,0x8(%esp)
  80126b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80126f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801272:	89 04 24             	mov    %eax,(%esp)
  801275:	e8 bd fa ff ff       	call   800d37 <sys_page_map>
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
  80127a:	01 45 e4             	add    %eax,-0x1c(%ebp)
	if(envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
  80127d:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801283:	81 ff 00 f0 bf ee    	cmp    $0xeebff000,%edi
  801289:	0f 85 d8 fe ff ff    	jne    801167 <fork+0x53>
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
		}
	}

	r+=sys_page_alloc(envid, (void*)UXSTACKTOP - PGSIZE, PTE_P|PTE_U|PTE_W);
  80128f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801296:	00 
  801297:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80129e:	ee 
  80129f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8012a2:	89 34 24             	mov    %esi,(%esp)
  8012a5:	e8 39 fa ff ff       	call   800ce3 <sys_page_alloc>
  8012aa:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8012ad:	01 c3                	add    %eax,%ebx
	r+=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8012af:	c7 44 24 04 43 27 80 	movl   $0x802743,0x4(%esp)
  8012b6:	00 
  8012b7:	89 34 24             	mov    %esi,(%esp)
  8012ba:	e8 c4 fb ff ff       	call   800e83 <sys_env_set_pgfault_upcall>
  8012bf:	01 c3                	add    %eax,%ebx
	r+= sys_env_set_status(envid, ENV_RUNNABLE);
  8012c1:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012c8:	00 
  8012c9:	89 34 24             	mov    %esi,(%esp)
  8012cc:	e8 0c fb ff ff       	call   800ddd <sys_env_set_status>

	if(r<0) {
  8012d1:	01 d8                	add    %ebx,%eax
  8012d3:	79 1c                	jns    8012f1 <fork+0x1dd>
	 panic("fork failed!");
  8012d5:	c7 44 24 08 1e 2e 80 	movl   $0x802e1e,0x8(%esp)
  8012dc:	00 
  8012dd:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  8012e4:	00 
  8012e5:	c7 04 24 db 2d 80 00 	movl   $0x802ddb,(%esp)
  8012ec:	e8 b8 ee ff ff       	call   8001a9 <_panic>
	}

	return envid;
  8012f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  8012f4:	83 c4 3c             	add    $0x3c,%esp
  8012f7:	5b                   	pop    %ebx
  8012f8:	5e                   	pop    %esi
  8012f9:	5f                   	pop    %edi
  8012fa:	5d                   	pop    %ebp
  8012fb:	c3                   	ret    

008012fc <sfork>:

// Challenge!
int
sfork(void)
{
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801302:	c7 44 24 08 2b 2e 80 	movl   $0x802e2b,0x8(%esp)
  801309:	00 
  80130a:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
  801311:	00 
  801312:	c7 04 24 db 2d 80 00 	movl   $0x802ddb,(%esp)
  801319:	e8 8b ee ff ff       	call   8001a9 <_panic>
  80131e:	66 90                	xchg   %ax,%ax

00801320 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	56                   	push   %esi
  801324:	53                   	push   %ebx
  801325:	83 ec 10             	sub    $0x10,%esp
  801328:	8b 75 08             	mov    0x8(%ebp),%esi
  80132b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80132e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  801331:	85 c0                	test   %eax,%eax
  801333:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801338:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  80133b:	89 04 24             	mov    %eax,(%esp)
  80133e:	e8 b6 fb ff ff       	call   800ef9 <sys_ipc_recv>

	if(ret < 0) {
  801343:	85 c0                	test   %eax,%eax
  801345:	79 16                	jns    80135d <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  801347:	85 f6                	test   %esi,%esi
  801349:	74 06                	je     801351 <ipc_recv+0x31>
  80134b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  801351:	85 db                	test   %ebx,%ebx
  801353:	74 3e                	je     801393 <ipc_recv+0x73>
  801355:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80135b:	eb 36                	jmp    801393 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  80135d:	e8 43 f9 ff ff       	call   800ca5 <sys_getenvid>
  801362:	25 ff 03 00 00       	and    $0x3ff,%eax
  801367:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80136a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80136f:	a3 08 40 80 00       	mov    %eax,0x804008

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801374:	85 f6                	test   %esi,%esi
  801376:	74 05                	je     80137d <ipc_recv+0x5d>
  801378:	8b 40 74             	mov    0x74(%eax),%eax
  80137b:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80137d:	85 db                	test   %ebx,%ebx
  80137f:	74 0a                	je     80138b <ipc_recv+0x6b>
  801381:	a1 08 40 80 00       	mov    0x804008,%eax
  801386:	8b 40 78             	mov    0x78(%eax),%eax
  801389:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  80138b:	a1 08 40 80 00       	mov    0x804008,%eax
  801390:	8b 40 70             	mov    0x70(%eax),%eax
}
  801393:	83 c4 10             	add    $0x10,%esp
  801396:	5b                   	pop    %ebx
  801397:	5e                   	pop    %esi
  801398:	5d                   	pop    %ebp
  801399:	c3                   	ret    

0080139a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80139a:	55                   	push   %ebp
  80139b:	89 e5                	mov    %esp,%ebp
  80139d:	57                   	push   %edi
  80139e:	56                   	push   %esi
  80139f:	53                   	push   %ebx
  8013a0:	83 ec 1c             	sub    $0x1c,%esp
  8013a3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013a6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  8013ac:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  8013ae:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8013b3:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  8013b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013bd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013c5:	89 3c 24             	mov    %edi,(%esp)
  8013c8:	e8 09 fb ff ff       	call   800ed6 <sys_ipc_try_send>

		if(ret >= 0) break;
  8013cd:	85 c0                	test   %eax,%eax
  8013cf:	79 2c                	jns    8013fd <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  8013d1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013d4:	74 20                	je     8013f6 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  8013d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013da:	c7 44 24 08 44 2e 80 	movl   $0x802e44,0x8(%esp)
  8013e1:	00 
  8013e2:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8013e9:	00 
  8013ea:	c7 04 24 74 2e 80 00 	movl   $0x802e74,(%esp)
  8013f1:	e8 b3 ed ff ff       	call   8001a9 <_panic>
		}
		sys_yield();
  8013f6:	e8 c9 f8 ff ff       	call   800cc4 <sys_yield>
	}
  8013fb:	eb b9                	jmp    8013b6 <ipc_send+0x1c>
}
  8013fd:	83 c4 1c             	add    $0x1c,%esp
  801400:	5b                   	pop    %ebx
  801401:	5e                   	pop    %esi
  801402:	5f                   	pop    %edi
  801403:	5d                   	pop    %ebp
  801404:	c3                   	ret    

00801405 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801405:	55                   	push   %ebp
  801406:	89 e5                	mov    %esp,%ebp
  801408:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80140b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801410:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801413:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801419:	8b 52 50             	mov    0x50(%edx),%edx
  80141c:	39 ca                	cmp    %ecx,%edx
  80141e:	75 0d                	jne    80142d <ipc_find_env+0x28>
			return envs[i].env_id;
  801420:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801423:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801428:	8b 40 40             	mov    0x40(%eax),%eax
  80142b:	eb 0e                	jmp    80143b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80142d:	83 c0 01             	add    $0x1,%eax
  801430:	3d 00 04 00 00       	cmp    $0x400,%eax
  801435:	75 d9                	jne    801410 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801437:	66 b8 00 00          	mov    $0x0,%ax
}
  80143b:	5d                   	pop    %ebp
  80143c:	c3                   	ret    
  80143d:	66 90                	xchg   %ax,%ax
  80143f:	90                   	nop

00801440 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801443:	8b 45 08             	mov    0x8(%ebp),%eax
  801446:	05 00 00 00 30       	add    $0x30000000,%eax
  80144b:	c1 e8 0c             	shr    $0xc,%eax
}
  80144e:	5d                   	pop    %ebp
  80144f:	c3                   	ret    

00801450 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801453:	8b 45 08             	mov    0x8(%ebp),%eax
  801456:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80145b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801460:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801465:	5d                   	pop    %ebp
  801466:	c3                   	ret    

00801467 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801467:	55                   	push   %ebp
  801468:	89 e5                	mov    %esp,%ebp
  80146a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80146d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801472:	89 c2                	mov    %eax,%edx
  801474:	c1 ea 16             	shr    $0x16,%edx
  801477:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80147e:	f6 c2 01             	test   $0x1,%dl
  801481:	74 11                	je     801494 <fd_alloc+0x2d>
  801483:	89 c2                	mov    %eax,%edx
  801485:	c1 ea 0c             	shr    $0xc,%edx
  801488:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80148f:	f6 c2 01             	test   $0x1,%dl
  801492:	75 09                	jne    80149d <fd_alloc+0x36>
			*fd_store = fd;
  801494:	89 01                	mov    %eax,(%ecx)
			return 0;
  801496:	b8 00 00 00 00       	mov    $0x0,%eax
  80149b:	eb 17                	jmp    8014b4 <fd_alloc+0x4d>
  80149d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014a2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014a7:	75 c9                	jne    801472 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014a9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8014af:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014b4:	5d                   	pop    %ebp
  8014b5:	c3                   	ret    

008014b6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014b6:	55                   	push   %ebp
  8014b7:	89 e5                	mov    %esp,%ebp
  8014b9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014bc:	83 f8 1f             	cmp    $0x1f,%eax
  8014bf:	77 36                	ja     8014f7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014c1:	c1 e0 0c             	shl    $0xc,%eax
  8014c4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014c9:	89 c2                	mov    %eax,%edx
  8014cb:	c1 ea 16             	shr    $0x16,%edx
  8014ce:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014d5:	f6 c2 01             	test   $0x1,%dl
  8014d8:	74 24                	je     8014fe <fd_lookup+0x48>
  8014da:	89 c2                	mov    %eax,%edx
  8014dc:	c1 ea 0c             	shr    $0xc,%edx
  8014df:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014e6:	f6 c2 01             	test   $0x1,%dl
  8014e9:	74 1a                	je     801505 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ee:	89 02                	mov    %eax,(%edx)
	return 0;
  8014f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8014f5:	eb 13                	jmp    80150a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014fc:	eb 0c                	jmp    80150a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801503:	eb 05                	jmp    80150a <fd_lookup+0x54>
  801505:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80150a:	5d                   	pop    %ebp
  80150b:	c3                   	ret    

0080150c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80150c:	55                   	push   %ebp
  80150d:	89 e5                	mov    %esp,%ebp
  80150f:	83 ec 18             	sub    $0x18,%esp
  801512:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801515:	ba 00 00 00 00       	mov    $0x0,%edx
  80151a:	eb 13                	jmp    80152f <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  80151c:	39 08                	cmp    %ecx,(%eax)
  80151e:	75 0c                	jne    80152c <dev_lookup+0x20>
			*dev = devtab[i];
  801520:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801523:	89 01                	mov    %eax,(%ecx)
			return 0;
  801525:	b8 00 00 00 00       	mov    $0x0,%eax
  80152a:	eb 38                	jmp    801564 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80152c:	83 c2 01             	add    $0x1,%edx
  80152f:	8b 04 95 00 2f 80 00 	mov    0x802f00(,%edx,4),%eax
  801536:	85 c0                	test   %eax,%eax
  801538:	75 e2                	jne    80151c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80153a:	a1 08 40 80 00       	mov    0x804008,%eax
  80153f:	8b 40 48             	mov    0x48(%eax),%eax
  801542:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801546:	89 44 24 04          	mov    %eax,0x4(%esp)
  80154a:	c7 04 24 80 2e 80 00 	movl   $0x802e80,(%esp)
  801551:	e8 4c ed ff ff       	call   8002a2 <cprintf>
	*dev = 0;
  801556:	8b 45 0c             	mov    0xc(%ebp),%eax
  801559:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80155f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801564:	c9                   	leave  
  801565:	c3                   	ret    

00801566 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801566:	55                   	push   %ebp
  801567:	89 e5                	mov    %esp,%ebp
  801569:	56                   	push   %esi
  80156a:	53                   	push   %ebx
  80156b:	83 ec 20             	sub    $0x20,%esp
  80156e:	8b 75 08             	mov    0x8(%ebp),%esi
  801571:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801574:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801577:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80157b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801581:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801584:	89 04 24             	mov    %eax,(%esp)
  801587:	e8 2a ff ff ff       	call   8014b6 <fd_lookup>
  80158c:	85 c0                	test   %eax,%eax
  80158e:	78 05                	js     801595 <fd_close+0x2f>
	    || fd != fd2)
  801590:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801593:	74 0c                	je     8015a1 <fd_close+0x3b>
		return (must_exist ? r : 0);
  801595:	84 db                	test   %bl,%bl
  801597:	ba 00 00 00 00       	mov    $0x0,%edx
  80159c:	0f 44 c2             	cmove  %edx,%eax
  80159f:	eb 3f                	jmp    8015e0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a8:	8b 06                	mov    (%esi),%eax
  8015aa:	89 04 24             	mov    %eax,(%esp)
  8015ad:	e8 5a ff ff ff       	call   80150c <dev_lookup>
  8015b2:	89 c3                	mov    %eax,%ebx
  8015b4:	85 c0                	test   %eax,%eax
  8015b6:	78 16                	js     8015ce <fd_close+0x68>
		if (dev->dev_close)
  8015b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015bb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8015be:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8015c3:	85 c0                	test   %eax,%eax
  8015c5:	74 07                	je     8015ce <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8015c7:	89 34 24             	mov    %esi,(%esp)
  8015ca:	ff d0                	call   *%eax
  8015cc:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015d9:	e8 ac f7 ff ff       	call   800d8a <sys_page_unmap>
	return r;
  8015de:	89 d8                	mov    %ebx,%eax
}
  8015e0:	83 c4 20             	add    $0x20,%esp
  8015e3:	5b                   	pop    %ebx
  8015e4:	5e                   	pop    %esi
  8015e5:	5d                   	pop    %ebp
  8015e6:	c3                   	ret    

008015e7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015e7:	55                   	push   %ebp
  8015e8:	89 e5                	mov    %esp,%ebp
  8015ea:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f7:	89 04 24             	mov    %eax,(%esp)
  8015fa:	e8 b7 fe ff ff       	call   8014b6 <fd_lookup>
  8015ff:	89 c2                	mov    %eax,%edx
  801601:	85 d2                	test   %edx,%edx
  801603:	78 13                	js     801618 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801605:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80160c:	00 
  80160d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801610:	89 04 24             	mov    %eax,(%esp)
  801613:	e8 4e ff ff ff       	call   801566 <fd_close>
}
  801618:	c9                   	leave  
  801619:	c3                   	ret    

0080161a <close_all>:

void
close_all(void)
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
  80161d:	53                   	push   %ebx
  80161e:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801621:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801626:	89 1c 24             	mov    %ebx,(%esp)
  801629:	e8 b9 ff ff ff       	call   8015e7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80162e:	83 c3 01             	add    $0x1,%ebx
  801631:	83 fb 20             	cmp    $0x20,%ebx
  801634:	75 f0                	jne    801626 <close_all+0xc>
		close(i);
}
  801636:	83 c4 14             	add    $0x14,%esp
  801639:	5b                   	pop    %ebx
  80163a:	5d                   	pop    %ebp
  80163b:	c3                   	ret    

0080163c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	57                   	push   %edi
  801640:	56                   	push   %esi
  801641:	53                   	push   %ebx
  801642:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801645:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801648:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164c:	8b 45 08             	mov    0x8(%ebp),%eax
  80164f:	89 04 24             	mov    %eax,(%esp)
  801652:	e8 5f fe ff ff       	call   8014b6 <fd_lookup>
  801657:	89 c2                	mov    %eax,%edx
  801659:	85 d2                	test   %edx,%edx
  80165b:	0f 88 e1 00 00 00    	js     801742 <dup+0x106>
		return r;
	close(newfdnum);
  801661:	8b 45 0c             	mov    0xc(%ebp),%eax
  801664:	89 04 24             	mov    %eax,(%esp)
  801667:	e8 7b ff ff ff       	call   8015e7 <close>

	newfd = INDEX2FD(newfdnum);
  80166c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80166f:	c1 e3 0c             	shl    $0xc,%ebx
  801672:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801678:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80167b:	89 04 24             	mov    %eax,(%esp)
  80167e:	e8 cd fd ff ff       	call   801450 <fd2data>
  801683:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801685:	89 1c 24             	mov    %ebx,(%esp)
  801688:	e8 c3 fd ff ff       	call   801450 <fd2data>
  80168d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80168f:	89 f0                	mov    %esi,%eax
  801691:	c1 e8 16             	shr    $0x16,%eax
  801694:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80169b:	a8 01                	test   $0x1,%al
  80169d:	74 43                	je     8016e2 <dup+0xa6>
  80169f:	89 f0                	mov    %esi,%eax
  8016a1:	c1 e8 0c             	shr    $0xc,%eax
  8016a4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016ab:	f6 c2 01             	test   $0x1,%dl
  8016ae:	74 32                	je     8016e2 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016b0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016b7:	25 07 0e 00 00       	and    $0xe07,%eax
  8016bc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016c0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8016c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016cb:	00 
  8016cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016d7:	e8 5b f6 ff ff       	call   800d37 <sys_page_map>
  8016dc:	89 c6                	mov    %eax,%esi
  8016de:	85 c0                	test   %eax,%eax
  8016e0:	78 3e                	js     801720 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016e5:	89 c2                	mov    %eax,%edx
  8016e7:	c1 ea 0c             	shr    $0xc,%edx
  8016ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016f1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8016f7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8016fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8016ff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801706:	00 
  801707:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801712:	e8 20 f6 ff ff       	call   800d37 <sys_page_map>
  801717:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801719:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80171c:	85 f6                	test   %esi,%esi
  80171e:	79 22                	jns    801742 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801720:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801724:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80172b:	e8 5a f6 ff ff       	call   800d8a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801730:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801734:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80173b:	e8 4a f6 ff ff       	call   800d8a <sys_page_unmap>
	return r;
  801740:	89 f0                	mov    %esi,%eax
}
  801742:	83 c4 3c             	add    $0x3c,%esp
  801745:	5b                   	pop    %ebx
  801746:	5e                   	pop    %esi
  801747:	5f                   	pop    %edi
  801748:	5d                   	pop    %ebp
  801749:	c3                   	ret    

0080174a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80174a:	55                   	push   %ebp
  80174b:	89 e5                	mov    %esp,%ebp
  80174d:	53                   	push   %ebx
  80174e:	83 ec 24             	sub    $0x24,%esp
  801751:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801754:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801757:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175b:	89 1c 24             	mov    %ebx,(%esp)
  80175e:	e8 53 fd ff ff       	call   8014b6 <fd_lookup>
  801763:	89 c2                	mov    %eax,%edx
  801765:	85 d2                	test   %edx,%edx
  801767:	78 6d                	js     8017d6 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801769:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801770:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801773:	8b 00                	mov    (%eax),%eax
  801775:	89 04 24             	mov    %eax,(%esp)
  801778:	e8 8f fd ff ff       	call   80150c <dev_lookup>
  80177d:	85 c0                	test   %eax,%eax
  80177f:	78 55                	js     8017d6 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801781:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801784:	8b 50 08             	mov    0x8(%eax),%edx
  801787:	83 e2 03             	and    $0x3,%edx
  80178a:	83 fa 01             	cmp    $0x1,%edx
  80178d:	75 23                	jne    8017b2 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80178f:	a1 08 40 80 00       	mov    0x804008,%eax
  801794:	8b 40 48             	mov    0x48(%eax),%eax
  801797:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80179b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80179f:	c7 04 24 c4 2e 80 00 	movl   $0x802ec4,(%esp)
  8017a6:	e8 f7 ea ff ff       	call   8002a2 <cprintf>
		return -E_INVAL;
  8017ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017b0:	eb 24                	jmp    8017d6 <read+0x8c>
	}
	if (!dev->dev_read)
  8017b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017b5:	8b 52 08             	mov    0x8(%edx),%edx
  8017b8:	85 d2                	test   %edx,%edx
  8017ba:	74 15                	je     8017d1 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017bf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017c6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017ca:	89 04 24             	mov    %eax,(%esp)
  8017cd:	ff d2                	call   *%edx
  8017cf:	eb 05                	jmp    8017d6 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017d1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8017d6:	83 c4 24             	add    $0x24,%esp
  8017d9:	5b                   	pop    %ebx
  8017da:	5d                   	pop    %ebp
  8017db:	c3                   	ret    

008017dc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	57                   	push   %edi
  8017e0:	56                   	push   %esi
  8017e1:	53                   	push   %ebx
  8017e2:	83 ec 1c             	sub    $0x1c,%esp
  8017e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017e8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017f0:	eb 23                	jmp    801815 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017f2:	89 f0                	mov    %esi,%eax
  8017f4:	29 d8                	sub    %ebx,%eax
  8017f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017fa:	89 d8                	mov    %ebx,%eax
  8017fc:	03 45 0c             	add    0xc(%ebp),%eax
  8017ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801803:	89 3c 24             	mov    %edi,(%esp)
  801806:	e8 3f ff ff ff       	call   80174a <read>
		if (m < 0)
  80180b:	85 c0                	test   %eax,%eax
  80180d:	78 10                	js     80181f <readn+0x43>
			return m;
		if (m == 0)
  80180f:	85 c0                	test   %eax,%eax
  801811:	74 0a                	je     80181d <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801813:	01 c3                	add    %eax,%ebx
  801815:	39 f3                	cmp    %esi,%ebx
  801817:	72 d9                	jb     8017f2 <readn+0x16>
  801819:	89 d8                	mov    %ebx,%eax
  80181b:	eb 02                	jmp    80181f <readn+0x43>
  80181d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80181f:	83 c4 1c             	add    $0x1c,%esp
  801822:	5b                   	pop    %ebx
  801823:	5e                   	pop    %esi
  801824:	5f                   	pop    %edi
  801825:	5d                   	pop    %ebp
  801826:	c3                   	ret    

00801827 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801827:	55                   	push   %ebp
  801828:	89 e5                	mov    %esp,%ebp
  80182a:	53                   	push   %ebx
  80182b:	83 ec 24             	sub    $0x24,%esp
  80182e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801831:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801834:	89 44 24 04          	mov    %eax,0x4(%esp)
  801838:	89 1c 24             	mov    %ebx,(%esp)
  80183b:	e8 76 fc ff ff       	call   8014b6 <fd_lookup>
  801840:	89 c2                	mov    %eax,%edx
  801842:	85 d2                	test   %edx,%edx
  801844:	78 68                	js     8018ae <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801846:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801849:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801850:	8b 00                	mov    (%eax),%eax
  801852:	89 04 24             	mov    %eax,(%esp)
  801855:	e8 b2 fc ff ff       	call   80150c <dev_lookup>
  80185a:	85 c0                	test   %eax,%eax
  80185c:	78 50                	js     8018ae <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80185e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801861:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801865:	75 23                	jne    80188a <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801867:	a1 08 40 80 00       	mov    0x804008,%eax
  80186c:	8b 40 48             	mov    0x48(%eax),%eax
  80186f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801873:	89 44 24 04          	mov    %eax,0x4(%esp)
  801877:	c7 04 24 e0 2e 80 00 	movl   $0x802ee0,(%esp)
  80187e:	e8 1f ea ff ff       	call   8002a2 <cprintf>
		return -E_INVAL;
  801883:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801888:	eb 24                	jmp    8018ae <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80188a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80188d:	8b 52 0c             	mov    0xc(%edx),%edx
  801890:	85 d2                	test   %edx,%edx
  801892:	74 15                	je     8018a9 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801894:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801897:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80189b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80189e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018a2:	89 04 24             	mov    %eax,(%esp)
  8018a5:	ff d2                	call   *%edx
  8018a7:	eb 05                	jmp    8018ae <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018a9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8018ae:	83 c4 24             	add    $0x24,%esp
  8018b1:	5b                   	pop    %ebx
  8018b2:	5d                   	pop    %ebp
  8018b3:	c3                   	ret    

008018b4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018b4:	55                   	push   %ebp
  8018b5:	89 e5                	mov    %esp,%ebp
  8018b7:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018ba:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c4:	89 04 24             	mov    %eax,(%esp)
  8018c7:	e8 ea fb ff ff       	call   8014b6 <fd_lookup>
  8018cc:	85 c0                	test   %eax,%eax
  8018ce:	78 0e                	js     8018de <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8018d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018de:	c9                   	leave  
  8018df:	c3                   	ret    

008018e0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	53                   	push   %ebx
  8018e4:	83 ec 24             	sub    $0x24,%esp
  8018e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f1:	89 1c 24             	mov    %ebx,(%esp)
  8018f4:	e8 bd fb ff ff       	call   8014b6 <fd_lookup>
  8018f9:	89 c2                	mov    %eax,%edx
  8018fb:	85 d2                	test   %edx,%edx
  8018fd:	78 61                	js     801960 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801902:	89 44 24 04          	mov    %eax,0x4(%esp)
  801906:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801909:	8b 00                	mov    (%eax),%eax
  80190b:	89 04 24             	mov    %eax,(%esp)
  80190e:	e8 f9 fb ff ff       	call   80150c <dev_lookup>
  801913:	85 c0                	test   %eax,%eax
  801915:	78 49                	js     801960 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801917:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80191a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80191e:	75 23                	jne    801943 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801920:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801925:	8b 40 48             	mov    0x48(%eax),%eax
  801928:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80192c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801930:	c7 04 24 a0 2e 80 00 	movl   $0x802ea0,(%esp)
  801937:	e8 66 e9 ff ff       	call   8002a2 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80193c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801941:	eb 1d                	jmp    801960 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801943:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801946:	8b 52 18             	mov    0x18(%edx),%edx
  801949:	85 d2                	test   %edx,%edx
  80194b:	74 0e                	je     80195b <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80194d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801950:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801954:	89 04 24             	mov    %eax,(%esp)
  801957:	ff d2                	call   *%edx
  801959:	eb 05                	jmp    801960 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80195b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801960:	83 c4 24             	add    $0x24,%esp
  801963:	5b                   	pop    %ebx
  801964:	5d                   	pop    %ebp
  801965:	c3                   	ret    

00801966 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	53                   	push   %ebx
  80196a:	83 ec 24             	sub    $0x24,%esp
  80196d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801970:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801973:	89 44 24 04          	mov    %eax,0x4(%esp)
  801977:	8b 45 08             	mov    0x8(%ebp),%eax
  80197a:	89 04 24             	mov    %eax,(%esp)
  80197d:	e8 34 fb ff ff       	call   8014b6 <fd_lookup>
  801982:	89 c2                	mov    %eax,%edx
  801984:	85 d2                	test   %edx,%edx
  801986:	78 52                	js     8019da <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801988:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80198b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801992:	8b 00                	mov    (%eax),%eax
  801994:	89 04 24             	mov    %eax,(%esp)
  801997:	e8 70 fb ff ff       	call   80150c <dev_lookup>
  80199c:	85 c0                	test   %eax,%eax
  80199e:	78 3a                	js     8019da <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8019a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019a7:	74 2c                	je     8019d5 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019a9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019ac:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019b3:	00 00 00 
	stat->st_isdir = 0;
  8019b6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019bd:	00 00 00 
	stat->st_dev = dev;
  8019c0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019ca:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019cd:	89 14 24             	mov    %edx,(%esp)
  8019d0:	ff 50 14             	call   *0x14(%eax)
  8019d3:	eb 05                	jmp    8019da <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019d5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019da:	83 c4 24             	add    $0x24,%esp
  8019dd:	5b                   	pop    %ebx
  8019de:	5d                   	pop    %ebp
  8019df:	c3                   	ret    

008019e0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
  8019e3:	56                   	push   %esi
  8019e4:	53                   	push   %ebx
  8019e5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019e8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019ef:	00 
  8019f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f3:	89 04 24             	mov    %eax,(%esp)
  8019f6:	e8 28 02 00 00       	call   801c23 <open>
  8019fb:	89 c3                	mov    %eax,%ebx
  8019fd:	85 db                	test   %ebx,%ebx
  8019ff:	78 1b                	js     801a1c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801a01:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a04:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a08:	89 1c 24             	mov    %ebx,(%esp)
  801a0b:	e8 56 ff ff ff       	call   801966 <fstat>
  801a10:	89 c6                	mov    %eax,%esi
	close(fd);
  801a12:	89 1c 24             	mov    %ebx,(%esp)
  801a15:	e8 cd fb ff ff       	call   8015e7 <close>
	return r;
  801a1a:	89 f0                	mov    %esi,%eax
}
  801a1c:	83 c4 10             	add    $0x10,%esp
  801a1f:	5b                   	pop    %ebx
  801a20:	5e                   	pop    %esi
  801a21:	5d                   	pop    %ebp
  801a22:	c3                   	ret    

00801a23 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a23:	55                   	push   %ebp
  801a24:	89 e5                	mov    %esp,%ebp
  801a26:	56                   	push   %esi
  801a27:	53                   	push   %ebx
  801a28:	83 ec 10             	sub    $0x10,%esp
  801a2b:	89 c6                	mov    %eax,%esi
  801a2d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a2f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a36:	75 11                	jne    801a49 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a38:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a3f:	e8 c1 f9 ff ff       	call   801405 <ipc_find_env>
  801a44:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a49:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a50:	00 
  801a51:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801a58:	00 
  801a59:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a5d:	a1 00 40 80 00       	mov    0x804000,%eax
  801a62:	89 04 24             	mov    %eax,(%esp)
  801a65:	e8 30 f9 ff ff       	call   80139a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a6a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a71:	00 
  801a72:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a76:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a7d:	e8 9e f8 ff ff       	call   801320 <ipc_recv>
}
  801a82:	83 c4 10             	add    $0x10,%esp
  801a85:	5b                   	pop    %ebx
  801a86:	5e                   	pop    %esi
  801a87:	5d                   	pop    %ebp
  801a88:	c3                   	ret    

00801a89 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a92:	8b 40 0c             	mov    0xc(%eax),%eax
  801a95:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801aa2:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa7:	b8 02 00 00 00       	mov    $0x2,%eax
  801aac:	e8 72 ff ff ff       	call   801a23 <fsipc>
}
  801ab1:	c9                   	leave  
  801ab2:	c3                   	ret    

00801ab3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801ab3:	55                   	push   %ebp
  801ab4:	89 e5                	mov    %esp,%ebp
  801ab6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  801abc:	8b 40 0c             	mov    0xc(%eax),%eax
  801abf:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801ac4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac9:	b8 06 00 00 00       	mov    $0x6,%eax
  801ace:	e8 50 ff ff ff       	call   801a23 <fsipc>
}
  801ad3:	c9                   	leave  
  801ad4:	c3                   	ret    

00801ad5 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ad5:	55                   	push   %ebp
  801ad6:	89 e5                	mov    %esp,%ebp
  801ad8:	53                   	push   %ebx
  801ad9:	83 ec 14             	sub    $0x14,%esp
  801adc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801adf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae2:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801aea:	ba 00 00 00 00       	mov    $0x0,%edx
  801aef:	b8 05 00 00 00       	mov    $0x5,%eax
  801af4:	e8 2a ff ff ff       	call   801a23 <fsipc>
  801af9:	89 c2                	mov    %eax,%edx
  801afb:	85 d2                	test   %edx,%edx
  801afd:	78 2b                	js     801b2a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801aff:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b06:	00 
  801b07:	89 1c 24             	mov    %ebx,(%esp)
  801b0a:	e8 b8 ed ff ff       	call   8008c7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b0f:	a1 80 50 80 00       	mov    0x805080,%eax
  801b14:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b1a:	a1 84 50 80 00       	mov    0x805084,%eax
  801b1f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b25:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b2a:	83 c4 14             	add    $0x14,%esp
  801b2d:	5b                   	pop    %ebx
  801b2e:	5d                   	pop    %ebp
  801b2f:	c3                   	ret    

00801b30 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	83 ec 18             	sub    $0x18,%esp
  801b36:	8b 45 10             	mov    0x10(%ebp),%eax
  801b39:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b3e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b43:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b46:	8b 55 08             	mov    0x8(%ebp),%edx
  801b49:	8b 52 0c             	mov    0xc(%edx),%edx
  801b4c:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801b52:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801b57:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b62:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801b69:	e8 f6 ee ff ff       	call   800a64 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  801b6e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b73:	b8 04 00 00 00       	mov    $0x4,%eax
  801b78:	e8 a6 fe ff ff       	call   801a23 <fsipc>
}
  801b7d:	c9                   	leave  
  801b7e:	c3                   	ret    

00801b7f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b7f:	55                   	push   %ebp
  801b80:	89 e5                	mov    %esp,%ebp
  801b82:	56                   	push   %esi
  801b83:	53                   	push   %ebx
  801b84:	83 ec 10             	sub    $0x10,%esp
  801b87:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8d:	8b 40 0c             	mov    0xc(%eax),%eax
  801b90:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b95:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b9b:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba0:	b8 03 00 00 00       	mov    $0x3,%eax
  801ba5:	e8 79 fe ff ff       	call   801a23 <fsipc>
  801baa:	89 c3                	mov    %eax,%ebx
  801bac:	85 c0                	test   %eax,%eax
  801bae:	78 6a                	js     801c1a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801bb0:	39 c6                	cmp    %eax,%esi
  801bb2:	73 24                	jae    801bd8 <devfile_read+0x59>
  801bb4:	c7 44 24 0c 14 2f 80 	movl   $0x802f14,0xc(%esp)
  801bbb:	00 
  801bbc:	c7 44 24 08 1b 2f 80 	movl   $0x802f1b,0x8(%esp)
  801bc3:	00 
  801bc4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801bcb:	00 
  801bcc:	c7 04 24 30 2f 80 00 	movl   $0x802f30,(%esp)
  801bd3:	e8 d1 e5 ff ff       	call   8001a9 <_panic>
	assert(r <= PGSIZE);
  801bd8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bdd:	7e 24                	jle    801c03 <devfile_read+0x84>
  801bdf:	c7 44 24 0c 3b 2f 80 	movl   $0x802f3b,0xc(%esp)
  801be6:	00 
  801be7:	c7 44 24 08 1b 2f 80 	movl   $0x802f1b,0x8(%esp)
  801bee:	00 
  801bef:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801bf6:	00 
  801bf7:	c7 04 24 30 2f 80 00 	movl   $0x802f30,(%esp)
  801bfe:	e8 a6 e5 ff ff       	call   8001a9 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c03:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c07:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c0e:	00 
  801c0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c12:	89 04 24             	mov    %eax,(%esp)
  801c15:	e8 4a ee ff ff       	call   800a64 <memmove>
	return r;
}
  801c1a:	89 d8                	mov    %ebx,%eax
  801c1c:	83 c4 10             	add    $0x10,%esp
  801c1f:	5b                   	pop    %ebx
  801c20:	5e                   	pop    %esi
  801c21:	5d                   	pop    %ebp
  801c22:	c3                   	ret    

00801c23 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c23:	55                   	push   %ebp
  801c24:	89 e5                	mov    %esp,%ebp
  801c26:	53                   	push   %ebx
  801c27:	83 ec 24             	sub    $0x24,%esp
  801c2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c2d:	89 1c 24             	mov    %ebx,(%esp)
  801c30:	e8 5b ec ff ff       	call   800890 <strlen>
  801c35:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c3a:	7f 60                	jg     801c9c <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c3c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c3f:	89 04 24             	mov    %eax,(%esp)
  801c42:	e8 20 f8 ff ff       	call   801467 <fd_alloc>
  801c47:	89 c2                	mov    %eax,%edx
  801c49:	85 d2                	test   %edx,%edx
  801c4b:	78 54                	js     801ca1 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c4d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c51:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801c58:	e8 6a ec ff ff       	call   8008c7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c60:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c65:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c68:	b8 01 00 00 00       	mov    $0x1,%eax
  801c6d:	e8 b1 fd ff ff       	call   801a23 <fsipc>
  801c72:	89 c3                	mov    %eax,%ebx
  801c74:	85 c0                	test   %eax,%eax
  801c76:	79 17                	jns    801c8f <open+0x6c>
		fd_close(fd, 0);
  801c78:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c7f:	00 
  801c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c83:	89 04 24             	mov    %eax,(%esp)
  801c86:	e8 db f8 ff ff       	call   801566 <fd_close>
		return r;
  801c8b:	89 d8                	mov    %ebx,%eax
  801c8d:	eb 12                	jmp    801ca1 <open+0x7e>
	}

	return fd2num(fd);
  801c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c92:	89 04 24             	mov    %eax,(%esp)
  801c95:	e8 a6 f7 ff ff       	call   801440 <fd2num>
  801c9a:	eb 05                	jmp    801ca1 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c9c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ca1:	83 c4 24             	add    $0x24,%esp
  801ca4:	5b                   	pop    %ebx
  801ca5:	5d                   	pop    %ebp
  801ca6:	c3                   	ret    

00801ca7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ca7:	55                   	push   %ebp
  801ca8:	89 e5                	mov    %esp,%ebp
  801caa:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cad:	ba 00 00 00 00       	mov    $0x0,%edx
  801cb2:	b8 08 00 00 00       	mov    $0x8,%eax
  801cb7:	e8 67 fd ff ff       	call   801a23 <fsipc>
}
  801cbc:	c9                   	leave  
  801cbd:	c3                   	ret    
  801cbe:	66 90                	xchg   %ax,%ax

00801cc0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
  801cc3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801cc6:	c7 44 24 04 47 2f 80 	movl   $0x802f47,0x4(%esp)
  801ccd:	00 
  801cce:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd1:	89 04 24             	mov    %eax,(%esp)
  801cd4:	e8 ee eb ff ff       	call   8008c7 <strcpy>
	return 0;
}
  801cd9:	b8 00 00 00 00       	mov    $0x0,%eax
  801cde:	c9                   	leave  
  801cdf:	c3                   	ret    

00801ce0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	53                   	push   %ebx
  801ce4:	83 ec 14             	sub    $0x14,%esp
  801ce7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801cea:	89 1c 24             	mov    %ebx,(%esp)
  801ced:	e8 75 0a 00 00       	call   802767 <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801cf2:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801cf7:	83 f8 01             	cmp    $0x1,%eax
  801cfa:	75 0d                	jne    801d09 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801cfc:	8b 43 0c             	mov    0xc(%ebx),%eax
  801cff:	89 04 24             	mov    %eax,(%esp)
  801d02:	e8 29 03 00 00       	call   802030 <nsipc_close>
  801d07:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  801d09:	89 d0                	mov    %edx,%eax
  801d0b:	83 c4 14             	add    $0x14,%esp
  801d0e:	5b                   	pop    %ebx
  801d0f:	5d                   	pop    %ebp
  801d10:	c3                   	ret    

00801d11 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801d11:	55                   	push   %ebp
  801d12:	89 e5                	mov    %esp,%ebp
  801d14:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801d17:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801d1e:	00 
  801d1f:	8b 45 10             	mov    0x10(%ebp),%eax
  801d22:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d26:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d29:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d30:	8b 40 0c             	mov    0xc(%eax),%eax
  801d33:	89 04 24             	mov    %eax,(%esp)
  801d36:	e8 f0 03 00 00       	call   80212b <nsipc_send>
}
  801d3b:	c9                   	leave  
  801d3c:	c3                   	ret    

00801d3d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801d3d:	55                   	push   %ebp
  801d3e:	89 e5                	mov    %esp,%ebp
  801d40:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d43:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801d4a:	00 
  801d4b:	8b 45 10             	mov    0x10(%ebp),%eax
  801d4e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d52:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d55:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d59:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5c:	8b 40 0c             	mov    0xc(%eax),%eax
  801d5f:	89 04 24             	mov    %eax,(%esp)
  801d62:	e8 44 03 00 00       	call   8020ab <nsipc_recv>
}
  801d67:	c9                   	leave  
  801d68:	c3                   	ret    

00801d69 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d69:	55                   	push   %ebp
  801d6a:	89 e5                	mov    %esp,%ebp
  801d6c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d6f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d72:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d76:	89 04 24             	mov    %eax,(%esp)
  801d79:	e8 38 f7 ff ff       	call   8014b6 <fd_lookup>
  801d7e:	85 c0                	test   %eax,%eax
  801d80:	78 17                	js     801d99 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d85:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801d8b:	39 08                	cmp    %ecx,(%eax)
  801d8d:	75 05                	jne    801d94 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d8f:	8b 40 0c             	mov    0xc(%eax),%eax
  801d92:	eb 05                	jmp    801d99 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d94:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d99:	c9                   	leave  
  801d9a:	c3                   	ret    

00801d9b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
  801d9e:	56                   	push   %esi
  801d9f:	53                   	push   %ebx
  801da0:	83 ec 20             	sub    $0x20,%esp
  801da3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801da5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da8:	89 04 24             	mov    %eax,(%esp)
  801dab:	e8 b7 f6 ff ff       	call   801467 <fd_alloc>
  801db0:	89 c3                	mov    %eax,%ebx
  801db2:	85 c0                	test   %eax,%eax
  801db4:	78 21                	js     801dd7 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801db6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dbd:	00 
  801dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dc5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dcc:	e8 12 ef ff ff       	call   800ce3 <sys_page_alloc>
  801dd1:	89 c3                	mov    %eax,%ebx
  801dd3:	85 c0                	test   %eax,%eax
  801dd5:	79 0c                	jns    801de3 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  801dd7:	89 34 24             	mov    %esi,(%esp)
  801dda:	e8 51 02 00 00       	call   802030 <nsipc_close>
		return r;
  801ddf:	89 d8                	mov    %ebx,%eax
  801de1:	eb 20                	jmp    801e03 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801de3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dec:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801dee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801df1:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801df8:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801dfb:	89 14 24             	mov    %edx,(%esp)
  801dfe:	e8 3d f6 ff ff       	call   801440 <fd2num>
}
  801e03:	83 c4 20             	add    $0x20,%esp
  801e06:	5b                   	pop    %ebx
  801e07:	5e                   	pop    %esi
  801e08:	5d                   	pop    %ebp
  801e09:	c3                   	ret    

00801e0a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e0a:	55                   	push   %ebp
  801e0b:	89 e5                	mov    %esp,%ebp
  801e0d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e10:	8b 45 08             	mov    0x8(%ebp),%eax
  801e13:	e8 51 ff ff ff       	call   801d69 <fd2sockid>
		return r;
  801e18:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e1a:	85 c0                	test   %eax,%eax
  801e1c:	78 23                	js     801e41 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e1e:	8b 55 10             	mov    0x10(%ebp),%edx
  801e21:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e25:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e28:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e2c:	89 04 24             	mov    %eax,(%esp)
  801e2f:	e8 45 01 00 00       	call   801f79 <nsipc_accept>
		return r;
  801e34:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e36:	85 c0                	test   %eax,%eax
  801e38:	78 07                	js     801e41 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  801e3a:	e8 5c ff ff ff       	call   801d9b <alloc_sockfd>
  801e3f:	89 c1                	mov    %eax,%ecx
}
  801e41:	89 c8                	mov    %ecx,%eax
  801e43:	c9                   	leave  
  801e44:	c3                   	ret    

00801e45 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e45:	55                   	push   %ebp
  801e46:	89 e5                	mov    %esp,%ebp
  801e48:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4e:	e8 16 ff ff ff       	call   801d69 <fd2sockid>
  801e53:	89 c2                	mov    %eax,%edx
  801e55:	85 d2                	test   %edx,%edx
  801e57:	78 16                	js     801e6f <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  801e59:	8b 45 10             	mov    0x10(%ebp),%eax
  801e5c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e63:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e67:	89 14 24             	mov    %edx,(%esp)
  801e6a:	e8 60 01 00 00       	call   801fcf <nsipc_bind>
}
  801e6f:	c9                   	leave  
  801e70:	c3                   	ret    

00801e71 <shutdown>:

int
shutdown(int s, int how)
{
  801e71:	55                   	push   %ebp
  801e72:	89 e5                	mov    %esp,%ebp
  801e74:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e77:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7a:	e8 ea fe ff ff       	call   801d69 <fd2sockid>
  801e7f:	89 c2                	mov    %eax,%edx
  801e81:	85 d2                	test   %edx,%edx
  801e83:	78 0f                	js     801e94 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801e85:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e88:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e8c:	89 14 24             	mov    %edx,(%esp)
  801e8f:	e8 7a 01 00 00       	call   80200e <nsipc_shutdown>
}
  801e94:	c9                   	leave  
  801e95:	c3                   	ret    

00801e96 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e96:	55                   	push   %ebp
  801e97:	89 e5                	mov    %esp,%ebp
  801e99:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9f:	e8 c5 fe ff ff       	call   801d69 <fd2sockid>
  801ea4:	89 c2                	mov    %eax,%edx
  801ea6:	85 d2                	test   %edx,%edx
  801ea8:	78 16                	js     801ec0 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  801eaa:	8b 45 10             	mov    0x10(%ebp),%eax
  801ead:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eb1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb8:	89 14 24             	mov    %edx,(%esp)
  801ebb:	e8 8a 01 00 00       	call   80204a <nsipc_connect>
}
  801ec0:	c9                   	leave  
  801ec1:	c3                   	ret    

00801ec2 <listen>:

int
listen(int s, int backlog)
{
  801ec2:	55                   	push   %ebp
  801ec3:	89 e5                	mov    %esp,%ebp
  801ec5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ec8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ecb:	e8 99 fe ff ff       	call   801d69 <fd2sockid>
  801ed0:	89 c2                	mov    %eax,%edx
  801ed2:	85 d2                	test   %edx,%edx
  801ed4:	78 0f                	js     801ee5 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801ed6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ed9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801edd:	89 14 24             	mov    %edx,(%esp)
  801ee0:	e8 a4 01 00 00       	call   802089 <nsipc_listen>
}
  801ee5:	c9                   	leave  
  801ee6:	c3                   	ret    

00801ee7 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801ee7:	55                   	push   %ebp
  801ee8:	89 e5                	mov    %esp,%ebp
  801eea:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801eed:	8b 45 10             	mov    0x10(%ebp),%eax
  801ef0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ef4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801efb:	8b 45 08             	mov    0x8(%ebp),%eax
  801efe:	89 04 24             	mov    %eax,(%esp)
  801f01:	e8 98 02 00 00       	call   80219e <nsipc_socket>
  801f06:	89 c2                	mov    %eax,%edx
  801f08:	85 d2                	test   %edx,%edx
  801f0a:	78 05                	js     801f11 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  801f0c:	e8 8a fe ff ff       	call   801d9b <alloc_sockfd>
}
  801f11:	c9                   	leave  
  801f12:	c3                   	ret    

00801f13 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801f13:	55                   	push   %ebp
  801f14:	89 e5                	mov    %esp,%ebp
  801f16:	53                   	push   %ebx
  801f17:	83 ec 14             	sub    $0x14,%esp
  801f1a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801f1c:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801f23:	75 11                	jne    801f36 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801f25:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801f2c:	e8 d4 f4 ff ff       	call   801405 <ipc_find_env>
  801f31:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801f36:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801f3d:	00 
  801f3e:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801f45:	00 
  801f46:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f4a:	a1 04 40 80 00       	mov    0x804004,%eax
  801f4f:	89 04 24             	mov    %eax,(%esp)
  801f52:	e8 43 f4 ff ff       	call   80139a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801f57:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f5e:	00 
  801f5f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f66:	00 
  801f67:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f6e:	e8 ad f3 ff ff       	call   801320 <ipc_recv>
}
  801f73:	83 c4 14             	add    $0x14,%esp
  801f76:	5b                   	pop    %ebx
  801f77:	5d                   	pop    %ebp
  801f78:	c3                   	ret    

00801f79 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f79:	55                   	push   %ebp
  801f7a:	89 e5                	mov    %esp,%ebp
  801f7c:	56                   	push   %esi
  801f7d:	53                   	push   %ebx
  801f7e:	83 ec 10             	sub    $0x10,%esp
  801f81:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801f84:	8b 45 08             	mov    0x8(%ebp),%eax
  801f87:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801f8c:	8b 06                	mov    (%esi),%eax
  801f8e:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f93:	b8 01 00 00 00       	mov    $0x1,%eax
  801f98:	e8 76 ff ff ff       	call   801f13 <nsipc>
  801f9d:	89 c3                	mov    %eax,%ebx
  801f9f:	85 c0                	test   %eax,%eax
  801fa1:	78 23                	js     801fc6 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801fa3:	a1 10 60 80 00       	mov    0x806010,%eax
  801fa8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fac:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801fb3:	00 
  801fb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fb7:	89 04 24             	mov    %eax,(%esp)
  801fba:	e8 a5 ea ff ff       	call   800a64 <memmove>
		*addrlen = ret->ret_addrlen;
  801fbf:	a1 10 60 80 00       	mov    0x806010,%eax
  801fc4:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801fc6:	89 d8                	mov    %ebx,%eax
  801fc8:	83 c4 10             	add    $0x10,%esp
  801fcb:	5b                   	pop    %ebx
  801fcc:	5e                   	pop    %esi
  801fcd:	5d                   	pop    %ebp
  801fce:	c3                   	ret    

00801fcf <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801fcf:	55                   	push   %ebp
  801fd0:	89 e5                	mov    %esp,%ebp
  801fd2:	53                   	push   %ebx
  801fd3:	83 ec 14             	sub    $0x14,%esp
  801fd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801fd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801fdc:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801fe1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fe5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fe8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fec:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801ff3:	e8 6c ea ff ff       	call   800a64 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801ff8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801ffe:	b8 02 00 00 00       	mov    $0x2,%eax
  802003:	e8 0b ff ff ff       	call   801f13 <nsipc>
}
  802008:	83 c4 14             	add    $0x14,%esp
  80200b:	5b                   	pop    %ebx
  80200c:	5d                   	pop    %ebp
  80200d:	c3                   	ret    

0080200e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80200e:	55                   	push   %ebp
  80200f:	89 e5                	mov    %esp,%ebp
  802011:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802014:	8b 45 08             	mov    0x8(%ebp),%eax
  802017:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  80201c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80201f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  802024:	b8 03 00 00 00       	mov    $0x3,%eax
  802029:	e8 e5 fe ff ff       	call   801f13 <nsipc>
}
  80202e:	c9                   	leave  
  80202f:	c3                   	ret    

00802030 <nsipc_close>:

int
nsipc_close(int s)
{
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
  802033:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802036:	8b 45 08             	mov    0x8(%ebp),%eax
  802039:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  80203e:	b8 04 00 00 00       	mov    $0x4,%eax
  802043:	e8 cb fe ff ff       	call   801f13 <nsipc>
}
  802048:	c9                   	leave  
  802049:	c3                   	ret    

0080204a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80204a:	55                   	push   %ebp
  80204b:	89 e5                	mov    %esp,%ebp
  80204d:	53                   	push   %ebx
  80204e:	83 ec 14             	sub    $0x14,%esp
  802051:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802054:	8b 45 08             	mov    0x8(%ebp),%eax
  802057:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80205c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802060:	8b 45 0c             	mov    0xc(%ebp),%eax
  802063:	89 44 24 04          	mov    %eax,0x4(%esp)
  802067:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  80206e:	e8 f1 e9 ff ff       	call   800a64 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802073:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  802079:	b8 05 00 00 00       	mov    $0x5,%eax
  80207e:	e8 90 fe ff ff       	call   801f13 <nsipc>
}
  802083:	83 c4 14             	add    $0x14,%esp
  802086:	5b                   	pop    %ebx
  802087:	5d                   	pop    %ebp
  802088:	c3                   	ret    

00802089 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802089:	55                   	push   %ebp
  80208a:	89 e5                	mov    %esp,%ebp
  80208c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80208f:	8b 45 08             	mov    0x8(%ebp),%eax
  802092:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  802097:	8b 45 0c             	mov    0xc(%ebp),%eax
  80209a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80209f:	b8 06 00 00 00       	mov    $0x6,%eax
  8020a4:	e8 6a fe ff ff       	call   801f13 <nsipc>
}
  8020a9:	c9                   	leave  
  8020aa:	c3                   	ret    

008020ab <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8020ab:	55                   	push   %ebp
  8020ac:	89 e5                	mov    %esp,%ebp
  8020ae:	56                   	push   %esi
  8020af:	53                   	push   %ebx
  8020b0:	83 ec 10             	sub    $0x10,%esp
  8020b3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8020b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8020be:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8020c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8020c7:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8020cc:	b8 07 00 00 00       	mov    $0x7,%eax
  8020d1:	e8 3d fe ff ff       	call   801f13 <nsipc>
  8020d6:	89 c3                	mov    %eax,%ebx
  8020d8:	85 c0                	test   %eax,%eax
  8020da:	78 46                	js     802122 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8020dc:	39 f0                	cmp    %esi,%eax
  8020de:	7f 07                	jg     8020e7 <nsipc_recv+0x3c>
  8020e0:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8020e5:	7e 24                	jle    80210b <nsipc_recv+0x60>
  8020e7:	c7 44 24 0c 53 2f 80 	movl   $0x802f53,0xc(%esp)
  8020ee:	00 
  8020ef:	c7 44 24 08 1b 2f 80 	movl   $0x802f1b,0x8(%esp)
  8020f6:	00 
  8020f7:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  8020fe:	00 
  8020ff:	c7 04 24 68 2f 80 00 	movl   $0x802f68,(%esp)
  802106:	e8 9e e0 ff ff       	call   8001a9 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80210b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80210f:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802116:	00 
  802117:	8b 45 0c             	mov    0xc(%ebp),%eax
  80211a:	89 04 24             	mov    %eax,(%esp)
  80211d:	e8 42 e9 ff ff       	call   800a64 <memmove>
	}

	return r;
}
  802122:	89 d8                	mov    %ebx,%eax
  802124:	83 c4 10             	add    $0x10,%esp
  802127:	5b                   	pop    %ebx
  802128:	5e                   	pop    %esi
  802129:	5d                   	pop    %ebp
  80212a:	c3                   	ret    

0080212b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80212b:	55                   	push   %ebp
  80212c:	89 e5                	mov    %esp,%ebp
  80212e:	53                   	push   %ebx
  80212f:	83 ec 14             	sub    $0x14,%esp
  802132:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802135:	8b 45 08             	mov    0x8(%ebp),%eax
  802138:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80213d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802143:	7e 24                	jle    802169 <nsipc_send+0x3e>
  802145:	c7 44 24 0c 74 2f 80 	movl   $0x802f74,0xc(%esp)
  80214c:	00 
  80214d:	c7 44 24 08 1b 2f 80 	movl   $0x802f1b,0x8(%esp)
  802154:	00 
  802155:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  80215c:	00 
  80215d:	c7 04 24 68 2f 80 00 	movl   $0x802f68,(%esp)
  802164:	e8 40 e0 ff ff       	call   8001a9 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802169:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80216d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802170:	89 44 24 04          	mov    %eax,0x4(%esp)
  802174:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  80217b:	e8 e4 e8 ff ff       	call   800a64 <memmove>
	nsipcbuf.send.req_size = size;
  802180:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  802186:	8b 45 14             	mov    0x14(%ebp),%eax
  802189:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  80218e:	b8 08 00 00 00       	mov    $0x8,%eax
  802193:	e8 7b fd ff ff       	call   801f13 <nsipc>
}
  802198:	83 c4 14             	add    $0x14,%esp
  80219b:	5b                   	pop    %ebx
  80219c:	5d                   	pop    %ebp
  80219d:	c3                   	ret    

0080219e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80219e:	55                   	push   %ebp
  80219f:	89 e5                	mov    %esp,%ebp
  8021a1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8021a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8021ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021af:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8021b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8021b7:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8021bc:	b8 09 00 00 00       	mov    $0x9,%eax
  8021c1:	e8 4d fd ff ff       	call   801f13 <nsipc>
}
  8021c6:	c9                   	leave  
  8021c7:	c3                   	ret    

008021c8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8021c8:	55                   	push   %ebp
  8021c9:	89 e5                	mov    %esp,%ebp
  8021cb:	56                   	push   %esi
  8021cc:	53                   	push   %ebx
  8021cd:	83 ec 10             	sub    $0x10,%esp
  8021d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8021d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d6:	89 04 24             	mov    %eax,(%esp)
  8021d9:	e8 72 f2 ff ff       	call   801450 <fd2data>
  8021de:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8021e0:	c7 44 24 04 80 2f 80 	movl   $0x802f80,0x4(%esp)
  8021e7:	00 
  8021e8:	89 1c 24             	mov    %ebx,(%esp)
  8021eb:	e8 d7 e6 ff ff       	call   8008c7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8021f0:	8b 46 04             	mov    0x4(%esi),%eax
  8021f3:	2b 06                	sub    (%esi),%eax
  8021f5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8021fb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802202:	00 00 00 
	stat->st_dev = &devpipe;
  802205:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80220c:	30 80 00 
	return 0;
}
  80220f:	b8 00 00 00 00       	mov    $0x0,%eax
  802214:	83 c4 10             	add    $0x10,%esp
  802217:	5b                   	pop    %ebx
  802218:	5e                   	pop    %esi
  802219:	5d                   	pop    %ebp
  80221a:	c3                   	ret    

0080221b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80221b:	55                   	push   %ebp
  80221c:	89 e5                	mov    %esp,%ebp
  80221e:	53                   	push   %ebx
  80221f:	83 ec 14             	sub    $0x14,%esp
  802222:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802225:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802229:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802230:	e8 55 eb ff ff       	call   800d8a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802235:	89 1c 24             	mov    %ebx,(%esp)
  802238:	e8 13 f2 ff ff       	call   801450 <fd2data>
  80223d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802241:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802248:	e8 3d eb ff ff       	call   800d8a <sys_page_unmap>
}
  80224d:	83 c4 14             	add    $0x14,%esp
  802250:	5b                   	pop    %ebx
  802251:	5d                   	pop    %ebp
  802252:	c3                   	ret    

00802253 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802253:	55                   	push   %ebp
  802254:	89 e5                	mov    %esp,%ebp
  802256:	57                   	push   %edi
  802257:	56                   	push   %esi
  802258:	53                   	push   %ebx
  802259:	83 ec 2c             	sub    $0x2c,%esp
  80225c:	89 c6                	mov    %eax,%esi
  80225e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802261:	a1 08 40 80 00       	mov    0x804008,%eax
  802266:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802269:	89 34 24             	mov    %esi,(%esp)
  80226c:	e8 f6 04 00 00       	call   802767 <pageref>
  802271:	89 c7                	mov    %eax,%edi
  802273:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802276:	89 04 24             	mov    %eax,(%esp)
  802279:	e8 e9 04 00 00       	call   802767 <pageref>
  80227e:	39 c7                	cmp    %eax,%edi
  802280:	0f 94 c2             	sete   %dl
  802283:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  802286:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  80228c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  80228f:	39 fb                	cmp    %edi,%ebx
  802291:	74 21                	je     8022b4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802293:	84 d2                	test   %dl,%dl
  802295:	74 ca                	je     802261 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802297:	8b 51 58             	mov    0x58(%ecx),%edx
  80229a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80229e:	89 54 24 08          	mov    %edx,0x8(%esp)
  8022a2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8022a6:	c7 04 24 87 2f 80 00 	movl   $0x802f87,(%esp)
  8022ad:	e8 f0 df ff ff       	call   8002a2 <cprintf>
  8022b2:	eb ad                	jmp    802261 <_pipeisclosed+0xe>
	}
}
  8022b4:	83 c4 2c             	add    $0x2c,%esp
  8022b7:	5b                   	pop    %ebx
  8022b8:	5e                   	pop    %esi
  8022b9:	5f                   	pop    %edi
  8022ba:	5d                   	pop    %ebp
  8022bb:	c3                   	ret    

008022bc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022bc:	55                   	push   %ebp
  8022bd:	89 e5                	mov    %esp,%ebp
  8022bf:	57                   	push   %edi
  8022c0:	56                   	push   %esi
  8022c1:	53                   	push   %ebx
  8022c2:	83 ec 1c             	sub    $0x1c,%esp
  8022c5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8022c8:	89 34 24             	mov    %esi,(%esp)
  8022cb:	e8 80 f1 ff ff       	call   801450 <fd2data>
  8022d0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022d2:	bf 00 00 00 00       	mov    $0x0,%edi
  8022d7:	eb 45                	jmp    80231e <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8022d9:	89 da                	mov    %ebx,%edx
  8022db:	89 f0                	mov    %esi,%eax
  8022dd:	e8 71 ff ff ff       	call   802253 <_pipeisclosed>
  8022e2:	85 c0                	test   %eax,%eax
  8022e4:	75 41                	jne    802327 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8022e6:	e8 d9 e9 ff ff       	call   800cc4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8022eb:	8b 43 04             	mov    0x4(%ebx),%eax
  8022ee:	8b 0b                	mov    (%ebx),%ecx
  8022f0:	8d 51 20             	lea    0x20(%ecx),%edx
  8022f3:	39 d0                	cmp    %edx,%eax
  8022f5:	73 e2                	jae    8022d9 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8022f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022fa:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8022fe:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802301:	99                   	cltd   
  802302:	c1 ea 1b             	shr    $0x1b,%edx
  802305:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802308:	83 e1 1f             	and    $0x1f,%ecx
  80230b:	29 d1                	sub    %edx,%ecx
  80230d:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  802311:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  802315:	83 c0 01             	add    $0x1,%eax
  802318:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80231b:	83 c7 01             	add    $0x1,%edi
  80231e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802321:	75 c8                	jne    8022eb <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802323:	89 f8                	mov    %edi,%eax
  802325:	eb 05                	jmp    80232c <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802327:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80232c:	83 c4 1c             	add    $0x1c,%esp
  80232f:	5b                   	pop    %ebx
  802330:	5e                   	pop    %esi
  802331:	5f                   	pop    %edi
  802332:	5d                   	pop    %ebp
  802333:	c3                   	ret    

00802334 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802334:	55                   	push   %ebp
  802335:	89 e5                	mov    %esp,%ebp
  802337:	57                   	push   %edi
  802338:	56                   	push   %esi
  802339:	53                   	push   %ebx
  80233a:	83 ec 1c             	sub    $0x1c,%esp
  80233d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802340:	89 3c 24             	mov    %edi,(%esp)
  802343:	e8 08 f1 ff ff       	call   801450 <fd2data>
  802348:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80234a:	be 00 00 00 00       	mov    $0x0,%esi
  80234f:	eb 3d                	jmp    80238e <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802351:	85 f6                	test   %esi,%esi
  802353:	74 04                	je     802359 <devpipe_read+0x25>
				return i;
  802355:	89 f0                	mov    %esi,%eax
  802357:	eb 43                	jmp    80239c <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802359:	89 da                	mov    %ebx,%edx
  80235b:	89 f8                	mov    %edi,%eax
  80235d:	e8 f1 fe ff ff       	call   802253 <_pipeisclosed>
  802362:	85 c0                	test   %eax,%eax
  802364:	75 31                	jne    802397 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802366:	e8 59 e9 ff ff       	call   800cc4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80236b:	8b 03                	mov    (%ebx),%eax
  80236d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802370:	74 df                	je     802351 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802372:	99                   	cltd   
  802373:	c1 ea 1b             	shr    $0x1b,%edx
  802376:	01 d0                	add    %edx,%eax
  802378:	83 e0 1f             	and    $0x1f,%eax
  80237b:	29 d0                	sub    %edx,%eax
  80237d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802382:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802385:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802388:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80238b:	83 c6 01             	add    $0x1,%esi
  80238e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802391:	75 d8                	jne    80236b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802393:	89 f0                	mov    %esi,%eax
  802395:	eb 05                	jmp    80239c <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802397:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80239c:	83 c4 1c             	add    $0x1c,%esp
  80239f:	5b                   	pop    %ebx
  8023a0:	5e                   	pop    %esi
  8023a1:	5f                   	pop    %edi
  8023a2:	5d                   	pop    %ebp
  8023a3:	c3                   	ret    

008023a4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8023a4:	55                   	push   %ebp
  8023a5:	89 e5                	mov    %esp,%ebp
  8023a7:	56                   	push   %esi
  8023a8:	53                   	push   %ebx
  8023a9:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8023ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023af:	89 04 24             	mov    %eax,(%esp)
  8023b2:	e8 b0 f0 ff ff       	call   801467 <fd_alloc>
  8023b7:	89 c2                	mov    %eax,%edx
  8023b9:	85 d2                	test   %edx,%edx
  8023bb:	0f 88 4d 01 00 00    	js     80250e <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023c1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8023c8:	00 
  8023c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023d7:	e8 07 e9 ff ff       	call   800ce3 <sys_page_alloc>
  8023dc:	89 c2                	mov    %eax,%edx
  8023de:	85 d2                	test   %edx,%edx
  8023e0:	0f 88 28 01 00 00    	js     80250e <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8023e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8023e9:	89 04 24             	mov    %eax,(%esp)
  8023ec:	e8 76 f0 ff ff       	call   801467 <fd_alloc>
  8023f1:	89 c3                	mov    %eax,%ebx
  8023f3:	85 c0                	test   %eax,%eax
  8023f5:	0f 88 fe 00 00 00    	js     8024f9 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023fb:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802402:	00 
  802403:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802406:	89 44 24 04          	mov    %eax,0x4(%esp)
  80240a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802411:	e8 cd e8 ff ff       	call   800ce3 <sys_page_alloc>
  802416:	89 c3                	mov    %eax,%ebx
  802418:	85 c0                	test   %eax,%eax
  80241a:	0f 88 d9 00 00 00    	js     8024f9 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802420:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802423:	89 04 24             	mov    %eax,(%esp)
  802426:	e8 25 f0 ff ff       	call   801450 <fd2data>
  80242b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80242d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802434:	00 
  802435:	89 44 24 04          	mov    %eax,0x4(%esp)
  802439:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802440:	e8 9e e8 ff ff       	call   800ce3 <sys_page_alloc>
  802445:	89 c3                	mov    %eax,%ebx
  802447:	85 c0                	test   %eax,%eax
  802449:	0f 88 97 00 00 00    	js     8024e6 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80244f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802452:	89 04 24             	mov    %eax,(%esp)
  802455:	e8 f6 ef ff ff       	call   801450 <fd2data>
  80245a:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802461:	00 
  802462:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802466:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80246d:	00 
  80246e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802472:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802479:	e8 b9 e8 ff ff       	call   800d37 <sys_page_map>
  80247e:	89 c3                	mov    %eax,%ebx
  802480:	85 c0                	test   %eax,%eax
  802482:	78 52                	js     8024d6 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802484:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80248a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80248d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80248f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802492:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802499:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80249f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024a2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8024a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024a7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8024ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024b1:	89 04 24             	mov    %eax,(%esp)
  8024b4:	e8 87 ef ff ff       	call   801440 <fd2num>
  8024b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024bc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8024be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024c1:	89 04 24             	mov    %eax,(%esp)
  8024c4:	e8 77 ef ff ff       	call   801440 <fd2num>
  8024c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024cc:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8024cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8024d4:	eb 38                	jmp    80250e <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  8024d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024e1:	e8 a4 e8 ff ff       	call   800d8a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8024e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024f4:	e8 91 e8 ff ff       	call   800d8a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8024f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  802500:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802507:	e8 7e e8 ff ff       	call   800d8a <sys_page_unmap>
  80250c:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  80250e:	83 c4 30             	add    $0x30,%esp
  802511:	5b                   	pop    %ebx
  802512:	5e                   	pop    %esi
  802513:	5d                   	pop    %ebp
  802514:	c3                   	ret    

00802515 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802515:	55                   	push   %ebp
  802516:	89 e5                	mov    %esp,%ebp
  802518:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80251b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80251e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802522:	8b 45 08             	mov    0x8(%ebp),%eax
  802525:	89 04 24             	mov    %eax,(%esp)
  802528:	e8 89 ef ff ff       	call   8014b6 <fd_lookup>
  80252d:	89 c2                	mov    %eax,%edx
  80252f:	85 d2                	test   %edx,%edx
  802531:	78 15                	js     802548 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802533:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802536:	89 04 24             	mov    %eax,(%esp)
  802539:	e8 12 ef ff ff       	call   801450 <fd2data>
	return _pipeisclosed(fd, p);
  80253e:	89 c2                	mov    %eax,%edx
  802540:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802543:	e8 0b fd ff ff       	call   802253 <_pipeisclosed>
}
  802548:	c9                   	leave  
  802549:	c3                   	ret    
  80254a:	66 90                	xchg   %ax,%ax
  80254c:	66 90                	xchg   %ax,%ax
  80254e:	66 90                	xchg   %ax,%ax

00802550 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802550:	55                   	push   %ebp
  802551:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802553:	b8 00 00 00 00       	mov    $0x0,%eax
  802558:	5d                   	pop    %ebp
  802559:	c3                   	ret    

0080255a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80255a:	55                   	push   %ebp
  80255b:	89 e5                	mov    %esp,%ebp
  80255d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802560:	c7 44 24 04 9f 2f 80 	movl   $0x802f9f,0x4(%esp)
  802567:	00 
  802568:	8b 45 0c             	mov    0xc(%ebp),%eax
  80256b:	89 04 24             	mov    %eax,(%esp)
  80256e:	e8 54 e3 ff ff       	call   8008c7 <strcpy>
	return 0;
}
  802573:	b8 00 00 00 00       	mov    $0x0,%eax
  802578:	c9                   	leave  
  802579:	c3                   	ret    

0080257a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80257a:	55                   	push   %ebp
  80257b:	89 e5                	mov    %esp,%ebp
  80257d:	57                   	push   %edi
  80257e:	56                   	push   %esi
  80257f:	53                   	push   %ebx
  802580:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802586:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80258b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802591:	eb 31                	jmp    8025c4 <devcons_write+0x4a>
		m = n - tot;
  802593:	8b 75 10             	mov    0x10(%ebp),%esi
  802596:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802598:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80259b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8025a0:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8025a3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8025a7:	03 45 0c             	add    0xc(%ebp),%eax
  8025aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025ae:	89 3c 24             	mov    %edi,(%esp)
  8025b1:	e8 ae e4 ff ff       	call   800a64 <memmove>
		sys_cputs(buf, m);
  8025b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025ba:	89 3c 24             	mov    %edi,(%esp)
  8025bd:	e8 54 e6 ff ff       	call   800c16 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8025c2:	01 f3                	add    %esi,%ebx
  8025c4:	89 d8                	mov    %ebx,%eax
  8025c6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8025c9:	72 c8                	jb     802593 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8025cb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8025d1:	5b                   	pop    %ebx
  8025d2:	5e                   	pop    %esi
  8025d3:	5f                   	pop    %edi
  8025d4:	5d                   	pop    %ebp
  8025d5:	c3                   	ret    

008025d6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8025d6:	55                   	push   %ebp
  8025d7:	89 e5                	mov    %esp,%ebp
  8025d9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8025dc:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8025e1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8025e5:	75 07                	jne    8025ee <devcons_read+0x18>
  8025e7:	eb 2a                	jmp    802613 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8025e9:	e8 d6 e6 ff ff       	call   800cc4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8025ee:	66 90                	xchg   %ax,%ax
  8025f0:	e8 3f e6 ff ff       	call   800c34 <sys_cgetc>
  8025f5:	85 c0                	test   %eax,%eax
  8025f7:	74 f0                	je     8025e9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8025f9:	85 c0                	test   %eax,%eax
  8025fb:	78 16                	js     802613 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8025fd:	83 f8 04             	cmp    $0x4,%eax
  802600:	74 0c                	je     80260e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802602:	8b 55 0c             	mov    0xc(%ebp),%edx
  802605:	88 02                	mov    %al,(%edx)
	return 1;
  802607:	b8 01 00 00 00       	mov    $0x1,%eax
  80260c:	eb 05                	jmp    802613 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80260e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802613:	c9                   	leave  
  802614:	c3                   	ret    

00802615 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802615:	55                   	push   %ebp
  802616:	89 e5                	mov    %esp,%ebp
  802618:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80261b:	8b 45 08             	mov    0x8(%ebp),%eax
  80261e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802621:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802628:	00 
  802629:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80262c:	89 04 24             	mov    %eax,(%esp)
  80262f:	e8 e2 e5 ff ff       	call   800c16 <sys_cputs>
}
  802634:	c9                   	leave  
  802635:	c3                   	ret    

00802636 <getchar>:

int
getchar(void)
{
  802636:	55                   	push   %ebp
  802637:	89 e5                	mov    %esp,%ebp
  802639:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80263c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802643:	00 
  802644:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802647:	89 44 24 04          	mov    %eax,0x4(%esp)
  80264b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802652:	e8 f3 f0 ff ff       	call   80174a <read>
	if (r < 0)
  802657:	85 c0                	test   %eax,%eax
  802659:	78 0f                	js     80266a <getchar+0x34>
		return r;
	if (r < 1)
  80265b:	85 c0                	test   %eax,%eax
  80265d:	7e 06                	jle    802665 <getchar+0x2f>
		return -E_EOF;
	return c;
  80265f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802663:	eb 05                	jmp    80266a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802665:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80266a:	c9                   	leave  
  80266b:	c3                   	ret    

0080266c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80266c:	55                   	push   %ebp
  80266d:	89 e5                	mov    %esp,%ebp
  80266f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802672:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802675:	89 44 24 04          	mov    %eax,0x4(%esp)
  802679:	8b 45 08             	mov    0x8(%ebp),%eax
  80267c:	89 04 24             	mov    %eax,(%esp)
  80267f:	e8 32 ee ff ff       	call   8014b6 <fd_lookup>
  802684:	85 c0                	test   %eax,%eax
  802686:	78 11                	js     802699 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802688:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80268b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802691:	39 10                	cmp    %edx,(%eax)
  802693:	0f 94 c0             	sete   %al
  802696:	0f b6 c0             	movzbl %al,%eax
}
  802699:	c9                   	leave  
  80269a:	c3                   	ret    

0080269b <opencons>:

int
opencons(void)
{
  80269b:	55                   	push   %ebp
  80269c:	89 e5                	mov    %esp,%ebp
  80269e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8026a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026a4:	89 04 24             	mov    %eax,(%esp)
  8026a7:	e8 bb ed ff ff       	call   801467 <fd_alloc>
		return r;
  8026ac:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8026ae:	85 c0                	test   %eax,%eax
  8026b0:	78 40                	js     8026f2 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8026b2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8026b9:	00 
  8026ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026c8:	e8 16 e6 ff ff       	call   800ce3 <sys_page_alloc>
		return r;
  8026cd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8026cf:	85 c0                	test   %eax,%eax
  8026d1:	78 1f                	js     8026f2 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8026d3:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8026d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026dc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8026de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026e1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8026e8:	89 04 24             	mov    %eax,(%esp)
  8026eb:	e8 50 ed ff ff       	call   801440 <fd2num>
  8026f0:	89 c2                	mov    %eax,%edx
}
  8026f2:	89 d0                	mov    %edx,%eax
  8026f4:	c9                   	leave  
  8026f5:	c3                   	ret    

008026f6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8026f6:	55                   	push   %ebp
  8026f7:	89 e5                	mov    %esp,%ebp
  8026f9:	53                   	push   %ebx
  8026fa:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  8026fd:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802704:	75 2f                	jne    802735 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  802706:	e8 9a e5 ff ff       	call   800ca5 <sys_getenvid>
  80270b:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P);
  80270d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802714:	00 
  802715:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80271c:	ee 
  80271d:	89 04 24             	mov    %eax,(%esp)
  802720:	e8 be e5 ff ff       	call   800ce3 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *)_pgfault_upcall);
  802725:	c7 44 24 04 43 27 80 	movl   $0x802743,0x4(%esp)
  80272c:	00 
  80272d:	89 1c 24             	mov    %ebx,(%esp)
  802730:	e8 4e e7 ff ff       	call   800e83 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802735:	8b 45 08             	mov    0x8(%ebp),%eax
  802738:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80273d:	83 c4 14             	add    $0x14,%esp
  802740:	5b                   	pop    %ebx
  802741:	5d                   	pop    %ebp
  802742:	c3                   	ret    

00802743 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802743:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802744:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802749:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80274b:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	// 0x30(%esp) points to trap-time stack pointer
	// 0x28(%esp) points to trap-time eip
	subl $4, 0x30(%esp)
  80274e:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax 
  802753:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebp
  802757:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %ebp, (%eax)
  80275b:	89 28                	mov    %ebp,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  80275d:	83 c4 08             	add    $0x8,%esp
	popal
  802760:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp //pop eip - we already stored it
  802761:	83 c4 04             	add    $0x4,%esp
	popfl
  802764:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802765:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802766:	c3                   	ret    

00802767 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802767:	55                   	push   %ebp
  802768:	89 e5                	mov    %esp,%ebp
  80276a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80276d:	89 d0                	mov    %edx,%eax
  80276f:	c1 e8 16             	shr    $0x16,%eax
  802772:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802779:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80277e:	f6 c1 01             	test   $0x1,%cl
  802781:	74 1d                	je     8027a0 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802783:	c1 ea 0c             	shr    $0xc,%edx
  802786:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80278d:	f6 c2 01             	test   $0x1,%dl
  802790:	74 0e                	je     8027a0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802792:	c1 ea 0c             	shr    $0xc,%edx
  802795:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80279c:	ef 
  80279d:	0f b7 c0             	movzwl %ax,%eax
}
  8027a0:	5d                   	pop    %ebp
  8027a1:	c3                   	ret    
  8027a2:	66 90                	xchg   %ax,%ax
  8027a4:	66 90                	xchg   %ax,%ax
  8027a6:	66 90                	xchg   %ax,%ax
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
