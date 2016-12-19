
obj/user/stresssched.debug:     file format elf32-i386


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
  80002c:	e8 e0 00 00 00       	call   800111 <libmain>
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

volatile int counter;

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800048:	e8 28 0c 00 00       	call   800c75 <sys_getenvid>
  80004d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800054:	e8 8b 10 00 00       	call   8010e4 <fork>
  800059:	85 c0                	test   %eax,%eax
  80005b:	74 0a                	je     800067 <umain+0x27>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80005d:	83 c3 01             	add    $0x1,%ebx
  800060:	83 fb 14             	cmp    $0x14,%ebx
  800063:	75 ef                	jne    800054 <umain+0x14>
  800065:	eb 16                	jmp    80007d <umain+0x3d>
		if (fork() == 0)
			break;
	if (i == 20) {
  800067:	83 fb 14             	cmp    $0x14,%ebx
  80006a:	74 11                	je     80007d <umain+0x3d>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800072:	6b d6 7c             	imul   $0x7c,%esi,%edx
  800075:	81 c2 04 00 c0 ee    	add    $0xeec00004,%edx
  80007b:	eb 0c                	jmp    800089 <umain+0x49>
	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
			break;
	if (i == 20) {
		sys_yield();
  80007d:	e8 12 0c 00 00       	call   800c94 <sys_yield>
		return;
  800082:	e9 83 00 00 00       	jmp    80010a <umain+0xca>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800087:	f3 90                	pause  
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800089:	8b 42 50             	mov    0x50(%edx),%eax
  80008c:	85 c0                	test   %eax,%eax
  80008e:	66 90                	xchg   %ax,%ax
  800090:	75 f5                	jne    800087 <umain+0x47>
  800092:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800097:	e8 f8 0b 00 00       	call   800c94 <sys_yield>
  80009c:	b8 10 27 00 00       	mov    $0x2710,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  8000a1:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8000a7:	83 c2 01             	add    $0x1,%edx
  8000aa:	89 15 08 40 80 00    	mov    %edx,0x804008
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000b0:	83 e8 01             	sub    $0x1,%eax
  8000b3:	75 ec                	jne    8000a1 <umain+0x61>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000b5:	83 eb 01             	sub    $0x1,%ebx
  8000b8:	75 dd                	jne    800097 <umain+0x57>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000ba:	a1 08 40 80 00       	mov    0x804008,%eax
  8000bf:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000c4:	74 25                	je     8000eb <umain+0xab>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000c6:	a1 08 40 80 00       	mov    0x804008,%eax
  8000cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000cf:	c7 44 24 08 20 2a 80 	movl   $0x802a20,0x8(%esp)
  8000d6:	00 
  8000d7:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000de:	00 
  8000df:	c7 04 24 48 2a 80 00 	movl   $0x802a48,(%esp)
  8000e6:	e8 87 00 00 00       	call   800172 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000eb:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8000f0:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000f3:	8b 40 48             	mov    0x48(%eax),%eax
  8000f6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000fe:	c7 04 24 5b 2a 80 00 	movl   $0x802a5b,(%esp)
  800105:	e8 61 01 00 00       	call   80026b <cprintf>

}
  80010a:	83 c4 10             	add    $0x10,%esp
  80010d:	5b                   	pop    %ebx
  80010e:	5e                   	pop    %esi
  80010f:	5d                   	pop    %ebp
  800110:	c3                   	ret    

00800111 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800111:	55                   	push   %ebp
  800112:	89 e5                	mov    %esp,%ebp
  800114:	56                   	push   %esi
  800115:	53                   	push   %ebx
  800116:	83 ec 10             	sub    $0x10,%esp
  800119:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80011c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  80011f:	e8 51 0b 00 00       	call   800c75 <sys_getenvid>
  800124:	25 ff 03 00 00       	and    $0x3ff,%eax
  800129:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80012c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800131:	a3 0c 40 80 00       	mov    %eax,0x80400c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800136:	85 db                	test   %ebx,%ebx
  800138:	7e 07                	jle    800141 <libmain+0x30>
		binaryname = argv[0];
  80013a:	8b 06                	mov    (%esi),%eax
  80013c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800141:	89 74 24 04          	mov    %esi,0x4(%esp)
  800145:	89 1c 24             	mov    %ebx,(%esp)
  800148:	e8 f3 fe ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  80014d:	e8 07 00 00 00       	call   800159 <exit>
}
  800152:	83 c4 10             	add    $0x10,%esp
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5d                   	pop    %ebp
  800158:	c3                   	ret    

00800159 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80015f:	e8 66 13 00 00       	call   8014ca <close_all>
	sys_env_destroy(0);
  800164:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80016b:	e8 b3 0a 00 00       	call   800c23 <sys_env_destroy>
}
  800170:	c9                   	leave  
  800171:	c3                   	ret    

00800172 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	56                   	push   %esi
  800176:	53                   	push   %ebx
  800177:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80017a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80017d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800183:	e8 ed 0a 00 00       	call   800c75 <sys_getenvid>
  800188:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80018f:	8b 55 08             	mov    0x8(%ebp),%edx
  800192:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800196:	89 74 24 08          	mov    %esi,0x8(%esp)
  80019a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019e:	c7 04 24 84 2a 80 00 	movl   $0x802a84,(%esp)
  8001a5:	e8 c1 00 00 00       	call   80026b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b1:	89 04 24             	mov    %eax,(%esp)
  8001b4:	e8 51 00 00 00       	call   80020a <vcprintf>
	cprintf("\n");
  8001b9:	c7 04 24 77 2a 80 00 	movl   $0x802a77,(%esp)
  8001c0:	e8 a6 00 00 00       	call   80026b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001c5:	cc                   	int3   
  8001c6:	eb fd                	jmp    8001c5 <_panic+0x53>

008001c8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	53                   	push   %ebx
  8001cc:	83 ec 14             	sub    $0x14,%esp
  8001cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001d2:	8b 13                	mov    (%ebx),%edx
  8001d4:	8d 42 01             	lea    0x1(%edx),%eax
  8001d7:	89 03                	mov    %eax,(%ebx)
  8001d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001dc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001e0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e5:	75 19                	jne    800200 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001e7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001ee:	00 
  8001ef:	8d 43 08             	lea    0x8(%ebx),%eax
  8001f2:	89 04 24             	mov    %eax,(%esp)
  8001f5:	e8 ec 09 00 00       	call   800be6 <sys_cputs>
		b->idx = 0;
  8001fa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800200:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800204:	83 c4 14             	add    $0x14,%esp
  800207:	5b                   	pop    %ebx
  800208:	5d                   	pop    %ebp
  800209:	c3                   	ret    

0080020a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80020a:	55                   	push   %ebp
  80020b:	89 e5                	mov    %esp,%ebp
  80020d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800213:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80021a:	00 00 00 
	b.cnt = 0;
  80021d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800224:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800227:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	89 44 24 08          	mov    %eax,0x8(%esp)
  800235:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80023b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023f:	c7 04 24 c8 01 80 00 	movl   $0x8001c8,(%esp)
  800246:	e8 b3 01 00 00       	call   8003fe <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800251:	89 44 24 04          	mov    %eax,0x4(%esp)
  800255:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025b:	89 04 24             	mov    %eax,(%esp)
  80025e:	e8 83 09 00 00       	call   800be6 <sys_cputs>

	return b.cnt;
}
  800263:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800269:	c9                   	leave  
  80026a:	c3                   	ret    

0080026b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800271:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800274:	89 44 24 04          	mov    %eax,0x4(%esp)
  800278:	8b 45 08             	mov    0x8(%ebp),%eax
  80027b:	89 04 24             	mov    %eax,(%esp)
  80027e:	e8 87 ff ff ff       	call   80020a <vcprintf>
	va_end(ap);

	return cnt;
}
  800283:	c9                   	leave  
  800284:	c3                   	ret    
  800285:	66 90                	xchg   %ax,%ax
  800287:	66 90                	xchg   %ax,%ax
  800289:	66 90                	xchg   %ax,%ax
  80028b:	66 90                	xchg   %ax,%ax
  80028d:	66 90                	xchg   %ax,%ax
  80028f:	90                   	nop

00800290 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	57                   	push   %edi
  800294:	56                   	push   %esi
  800295:	53                   	push   %ebx
  800296:	83 ec 3c             	sub    $0x3c,%esp
  800299:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80029c:	89 d7                	mov    %edx,%edi
  80029e:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a7:	89 c3                	mov    %eax,%ebx
  8002a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8002af:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002bd:	39 d9                	cmp    %ebx,%ecx
  8002bf:	72 05                	jb     8002c6 <printnum+0x36>
  8002c1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002c4:	77 69                	ja     80032f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002c6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002c9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002cd:	83 ee 01             	sub    $0x1,%esi
  8002d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002dc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002e0:	89 c3                	mov    %eax,%ebx
  8002e2:	89 d6                	mov    %edx,%esi
  8002e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002ea:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002f5:	89 04 24             	mov    %eax,(%esp)
  8002f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ff:	e8 7c 24 00 00       	call   802780 <__udivdi3>
  800304:	89 d9                	mov    %ebx,%ecx
  800306:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80030a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80030e:	89 04 24             	mov    %eax,(%esp)
  800311:	89 54 24 04          	mov    %edx,0x4(%esp)
  800315:	89 fa                	mov    %edi,%edx
  800317:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80031a:	e8 71 ff ff ff       	call   800290 <printnum>
  80031f:	eb 1b                	jmp    80033c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800321:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800325:	8b 45 18             	mov    0x18(%ebp),%eax
  800328:	89 04 24             	mov    %eax,(%esp)
  80032b:	ff d3                	call   *%ebx
  80032d:	eb 03                	jmp    800332 <printnum+0xa2>
  80032f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800332:	83 ee 01             	sub    $0x1,%esi
  800335:	85 f6                	test   %esi,%esi
  800337:	7f e8                	jg     800321 <printnum+0x91>
  800339:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80033c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800340:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800344:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800347:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80034a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80034e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800352:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800355:	89 04 24             	mov    %eax,(%esp)
  800358:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80035b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035f:	e8 4c 25 00 00       	call   8028b0 <__umoddi3>
  800364:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800368:	0f be 80 a7 2a 80 00 	movsbl 0x802aa7(%eax),%eax
  80036f:	89 04 24             	mov    %eax,(%esp)
  800372:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800375:	ff d0                	call   *%eax
}
  800377:	83 c4 3c             	add    $0x3c,%esp
  80037a:	5b                   	pop    %ebx
  80037b:	5e                   	pop    %esi
  80037c:	5f                   	pop    %edi
  80037d:	5d                   	pop    %ebp
  80037e:	c3                   	ret    

0080037f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80037f:	55                   	push   %ebp
  800380:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800382:	83 fa 01             	cmp    $0x1,%edx
  800385:	7e 0e                	jle    800395 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800387:	8b 10                	mov    (%eax),%edx
  800389:	8d 4a 08             	lea    0x8(%edx),%ecx
  80038c:	89 08                	mov    %ecx,(%eax)
  80038e:	8b 02                	mov    (%edx),%eax
  800390:	8b 52 04             	mov    0x4(%edx),%edx
  800393:	eb 22                	jmp    8003b7 <getuint+0x38>
	else if (lflag)
  800395:	85 d2                	test   %edx,%edx
  800397:	74 10                	je     8003a9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800399:	8b 10                	mov    (%eax),%edx
  80039b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80039e:	89 08                	mov    %ecx,(%eax)
  8003a0:	8b 02                	mov    (%edx),%eax
  8003a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a7:	eb 0e                	jmp    8003b7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ae:	89 08                	mov    %ecx,(%eax)
  8003b0:	8b 02                	mov    (%edx),%eax
  8003b2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003b7:	5d                   	pop    %ebp
  8003b8:	c3                   	ret    

008003b9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
  8003bc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003bf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003c3:	8b 10                	mov    (%eax),%edx
  8003c5:	3b 50 04             	cmp    0x4(%eax),%edx
  8003c8:	73 0a                	jae    8003d4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ca:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003cd:	89 08                	mov    %ecx,(%eax)
  8003cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d2:	88 02                	mov    %al,(%edx)
}
  8003d4:	5d                   	pop    %ebp
  8003d5:	c3                   	ret    

008003d6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003d6:	55                   	push   %ebp
  8003d7:	89 e5                	mov    %esp,%ebp
  8003d9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003dc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f4:	89 04 24             	mov    %eax,(%esp)
  8003f7:	e8 02 00 00 00       	call   8003fe <vprintfmt>
	va_end(ap);
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	57                   	push   %edi
  800402:	56                   	push   %esi
  800403:	53                   	push   %ebx
  800404:	83 ec 3c             	sub    $0x3c,%esp
  800407:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80040a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80040d:	eb 14                	jmp    800423 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80040f:	85 c0                	test   %eax,%eax
  800411:	0f 84 b3 03 00 00    	je     8007ca <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800417:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80041b:	89 04 24             	mov    %eax,(%esp)
  80041e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800421:	89 f3                	mov    %esi,%ebx
  800423:	8d 73 01             	lea    0x1(%ebx),%esi
  800426:	0f b6 03             	movzbl (%ebx),%eax
  800429:	83 f8 25             	cmp    $0x25,%eax
  80042c:	75 e1                	jne    80040f <vprintfmt+0x11>
  80042e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800432:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800439:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800440:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800447:	ba 00 00 00 00       	mov    $0x0,%edx
  80044c:	eb 1d                	jmp    80046b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800450:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800454:	eb 15                	jmp    80046b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800456:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800458:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80045c:	eb 0d                	jmp    80046b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80045e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800461:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800464:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80046e:	0f b6 0e             	movzbl (%esi),%ecx
  800471:	0f b6 c1             	movzbl %cl,%eax
  800474:	83 e9 23             	sub    $0x23,%ecx
  800477:	80 f9 55             	cmp    $0x55,%cl
  80047a:	0f 87 2a 03 00 00    	ja     8007aa <vprintfmt+0x3ac>
  800480:	0f b6 c9             	movzbl %cl,%ecx
  800483:	ff 24 8d e0 2b 80 00 	jmp    *0x802be0(,%ecx,4)
  80048a:	89 de                	mov    %ebx,%esi
  80048c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800491:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800494:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800498:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80049b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80049e:	83 fb 09             	cmp    $0x9,%ebx
  8004a1:	77 36                	ja     8004d9 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004a3:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004a6:	eb e9                	jmp    800491 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ab:	8d 48 04             	lea    0x4(%eax),%ecx
  8004ae:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004b1:	8b 00                	mov    (%eax),%eax
  8004b3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b6:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004b8:	eb 22                	jmp    8004dc <vprintfmt+0xde>
  8004ba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004bd:	85 c9                	test   %ecx,%ecx
  8004bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c4:	0f 49 c1             	cmovns %ecx,%eax
  8004c7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ca:	89 de                	mov    %ebx,%esi
  8004cc:	eb 9d                	jmp    80046b <vprintfmt+0x6d>
  8004ce:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004d0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004d7:	eb 92                	jmp    80046b <vprintfmt+0x6d>
  8004d9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8004dc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004e0:	79 89                	jns    80046b <vprintfmt+0x6d>
  8004e2:	e9 77 ff ff ff       	jmp    80045e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ea:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004ec:	e9 7a ff ff ff       	jmp    80046b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f4:	8d 50 04             	lea    0x4(%eax),%edx
  8004f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004fe:	8b 00                	mov    (%eax),%eax
  800500:	89 04 24             	mov    %eax,(%esp)
  800503:	ff 55 08             	call   *0x8(%ebp)
			break;
  800506:	e9 18 ff ff ff       	jmp    800423 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80050b:	8b 45 14             	mov    0x14(%ebp),%eax
  80050e:	8d 50 04             	lea    0x4(%eax),%edx
  800511:	89 55 14             	mov    %edx,0x14(%ebp)
  800514:	8b 00                	mov    (%eax),%eax
  800516:	99                   	cltd   
  800517:	31 d0                	xor    %edx,%eax
  800519:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80051b:	83 f8 0f             	cmp    $0xf,%eax
  80051e:	7f 0b                	jg     80052b <vprintfmt+0x12d>
  800520:	8b 14 85 40 2d 80 00 	mov    0x802d40(,%eax,4),%edx
  800527:	85 d2                	test   %edx,%edx
  800529:	75 20                	jne    80054b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80052b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80052f:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  800536:	00 
  800537:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80053b:	8b 45 08             	mov    0x8(%ebp),%eax
  80053e:	89 04 24             	mov    %eax,(%esp)
  800541:	e8 90 fe ff ff       	call   8003d6 <printfmt>
  800546:	e9 d8 fe ff ff       	jmp    800423 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80054b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80054f:	c7 44 24 08 ed 2e 80 	movl   $0x802eed,0x8(%esp)
  800556:	00 
  800557:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80055b:	8b 45 08             	mov    0x8(%ebp),%eax
  80055e:	89 04 24             	mov    %eax,(%esp)
  800561:	e8 70 fe ff ff       	call   8003d6 <printfmt>
  800566:	e9 b8 fe ff ff       	jmp    800423 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80056e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800571:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 50 04             	lea    0x4(%eax),%edx
  80057a:	89 55 14             	mov    %edx,0x14(%ebp)
  80057d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80057f:	85 f6                	test   %esi,%esi
  800581:	b8 b8 2a 80 00       	mov    $0x802ab8,%eax
  800586:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800589:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80058d:	0f 84 97 00 00 00    	je     80062a <vprintfmt+0x22c>
  800593:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800597:	0f 8e 9b 00 00 00    	jle    800638 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80059d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005a1:	89 34 24             	mov    %esi,(%esp)
  8005a4:	e8 cf 02 00 00       	call   800878 <strnlen>
  8005a9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005ac:	29 c2                	sub    %eax,%edx
  8005ae:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8005b1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005b8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8005be:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005c1:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c3:	eb 0f                	jmp    8005d4 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8005c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005cc:	89 04 24             	mov    %eax,(%esp)
  8005cf:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d1:	83 eb 01             	sub    $0x1,%ebx
  8005d4:	85 db                	test   %ebx,%ebx
  8005d6:	7f ed                	jg     8005c5 <vprintfmt+0x1c7>
  8005d8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005db:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005de:	85 d2                	test   %edx,%edx
  8005e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e5:	0f 49 c2             	cmovns %edx,%eax
  8005e8:	29 c2                	sub    %eax,%edx
  8005ea:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005ed:	89 d7                	mov    %edx,%edi
  8005ef:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005f2:	eb 50                	jmp    800644 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005f4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005f8:	74 1e                	je     800618 <vprintfmt+0x21a>
  8005fa:	0f be d2             	movsbl %dl,%edx
  8005fd:	83 ea 20             	sub    $0x20,%edx
  800600:	83 fa 5e             	cmp    $0x5e,%edx
  800603:	76 13                	jbe    800618 <vprintfmt+0x21a>
					putch('?', putdat);
  800605:	8b 45 0c             	mov    0xc(%ebp),%eax
  800608:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800613:	ff 55 08             	call   *0x8(%ebp)
  800616:	eb 0d                	jmp    800625 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800618:	8b 55 0c             	mov    0xc(%ebp),%edx
  80061b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80061f:	89 04 24             	mov    %eax,(%esp)
  800622:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800625:	83 ef 01             	sub    $0x1,%edi
  800628:	eb 1a                	jmp    800644 <vprintfmt+0x246>
  80062a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80062d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800630:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800633:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800636:	eb 0c                	jmp    800644 <vprintfmt+0x246>
  800638:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80063b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80063e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800641:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800644:	83 c6 01             	add    $0x1,%esi
  800647:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80064b:	0f be c2             	movsbl %dl,%eax
  80064e:	85 c0                	test   %eax,%eax
  800650:	74 27                	je     800679 <vprintfmt+0x27b>
  800652:	85 db                	test   %ebx,%ebx
  800654:	78 9e                	js     8005f4 <vprintfmt+0x1f6>
  800656:	83 eb 01             	sub    $0x1,%ebx
  800659:	79 99                	jns    8005f4 <vprintfmt+0x1f6>
  80065b:	89 f8                	mov    %edi,%eax
  80065d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800660:	8b 75 08             	mov    0x8(%ebp),%esi
  800663:	89 c3                	mov    %eax,%ebx
  800665:	eb 1a                	jmp    800681 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800667:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80066b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800672:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800674:	83 eb 01             	sub    $0x1,%ebx
  800677:	eb 08                	jmp    800681 <vprintfmt+0x283>
  800679:	89 fb                	mov    %edi,%ebx
  80067b:	8b 75 08             	mov    0x8(%ebp),%esi
  80067e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800681:	85 db                	test   %ebx,%ebx
  800683:	7f e2                	jg     800667 <vprintfmt+0x269>
  800685:	89 75 08             	mov    %esi,0x8(%ebp)
  800688:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80068b:	e9 93 fd ff ff       	jmp    800423 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800690:	83 fa 01             	cmp    $0x1,%edx
  800693:	7e 16                	jle    8006ab <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8d 50 08             	lea    0x8(%eax),%edx
  80069b:	89 55 14             	mov    %edx,0x14(%ebp)
  80069e:	8b 50 04             	mov    0x4(%eax),%edx
  8006a1:	8b 00                	mov    (%eax),%eax
  8006a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006a6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006a9:	eb 32                	jmp    8006dd <vprintfmt+0x2df>
	else if (lflag)
  8006ab:	85 d2                	test   %edx,%edx
  8006ad:	74 18                	je     8006c7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	8d 50 04             	lea    0x4(%eax),%edx
  8006b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b8:	8b 30                	mov    (%eax),%esi
  8006ba:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006bd:	89 f0                	mov    %esi,%eax
  8006bf:	c1 f8 1f             	sar    $0x1f,%eax
  8006c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006c5:	eb 16                	jmp    8006dd <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8006c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ca:	8d 50 04             	lea    0x4(%eax),%edx
  8006cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d0:	8b 30                	mov    (%eax),%esi
  8006d2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006d5:	89 f0                	mov    %esi,%eax
  8006d7:	c1 f8 1f             	sar    $0x1f,%eax
  8006da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006e3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006ec:	0f 89 80 00 00 00    	jns    800772 <vprintfmt+0x374>
				putch('-', putdat);
  8006f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006f6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006fd:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800700:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800703:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800706:	f7 d8                	neg    %eax
  800708:	83 d2 00             	adc    $0x0,%edx
  80070b:	f7 da                	neg    %edx
			}
			base = 10;
  80070d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800712:	eb 5e                	jmp    800772 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800714:	8d 45 14             	lea    0x14(%ebp),%eax
  800717:	e8 63 fc ff ff       	call   80037f <getuint>
			base = 10;
  80071c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800721:	eb 4f                	jmp    800772 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800723:	8d 45 14             	lea    0x14(%ebp),%eax
  800726:	e8 54 fc ff ff       	call   80037f <getuint>
			base = 8;
  80072b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800730:	eb 40                	jmp    800772 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800732:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800736:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80073d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800740:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800744:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80074b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80074e:	8b 45 14             	mov    0x14(%ebp),%eax
  800751:	8d 50 04             	lea    0x4(%eax),%edx
  800754:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800757:	8b 00                	mov    (%eax),%eax
  800759:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80075e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800763:	eb 0d                	jmp    800772 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800765:	8d 45 14             	lea    0x14(%ebp),%eax
  800768:	e8 12 fc ff ff       	call   80037f <getuint>
			base = 16;
  80076d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800772:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800776:	89 74 24 10          	mov    %esi,0x10(%esp)
  80077a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80077d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800781:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800785:	89 04 24             	mov    %eax,(%esp)
  800788:	89 54 24 04          	mov    %edx,0x4(%esp)
  80078c:	89 fa                	mov    %edi,%edx
  80078e:	8b 45 08             	mov    0x8(%ebp),%eax
  800791:	e8 fa fa ff ff       	call   800290 <printnum>
			break;
  800796:	e9 88 fc ff ff       	jmp    800423 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80079b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80079f:	89 04 24             	mov    %eax,(%esp)
  8007a2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007a5:	e9 79 fc ff ff       	jmp    800423 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ae:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007b5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007b8:	89 f3                	mov    %esi,%ebx
  8007ba:	eb 03                	jmp    8007bf <vprintfmt+0x3c1>
  8007bc:	83 eb 01             	sub    $0x1,%ebx
  8007bf:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007c3:	75 f7                	jne    8007bc <vprintfmt+0x3be>
  8007c5:	e9 59 fc ff ff       	jmp    800423 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8007ca:	83 c4 3c             	add    $0x3c,%esp
  8007cd:	5b                   	pop    %ebx
  8007ce:	5e                   	pop    %esi
  8007cf:	5f                   	pop    %edi
  8007d0:	5d                   	pop    %ebp
  8007d1:	c3                   	ret    

008007d2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	83 ec 28             	sub    $0x28,%esp
  8007d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007db:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007de:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007e1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007e5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ef:	85 c0                	test   %eax,%eax
  8007f1:	74 30                	je     800823 <vsnprintf+0x51>
  8007f3:	85 d2                	test   %edx,%edx
  8007f5:	7e 2c                	jle    800823 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007fe:	8b 45 10             	mov    0x10(%ebp),%eax
  800801:	89 44 24 08          	mov    %eax,0x8(%esp)
  800805:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800808:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080c:	c7 04 24 b9 03 80 00 	movl   $0x8003b9,(%esp)
  800813:	e8 e6 fb ff ff       	call   8003fe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800818:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80081b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80081e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800821:	eb 05                	jmp    800828 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800823:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800828:	c9                   	leave  
  800829:	c3                   	ret    

0080082a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800830:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800833:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800837:	8b 45 10             	mov    0x10(%ebp),%eax
  80083a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80083e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800841:	89 44 24 04          	mov    %eax,0x4(%esp)
  800845:	8b 45 08             	mov    0x8(%ebp),%eax
  800848:	89 04 24             	mov    %eax,(%esp)
  80084b:	e8 82 ff ff ff       	call   8007d2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800850:	c9                   	leave  
  800851:	c3                   	ret    
  800852:	66 90                	xchg   %ax,%ax
  800854:	66 90                	xchg   %ax,%ax
  800856:	66 90                	xchg   %ax,%ax
  800858:	66 90                	xchg   %ax,%ax
  80085a:	66 90                	xchg   %ax,%ax
  80085c:	66 90                	xchg   %ax,%ax
  80085e:	66 90                	xchg   %ax,%ax

00800860 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800866:	b8 00 00 00 00       	mov    $0x0,%eax
  80086b:	eb 03                	jmp    800870 <strlen+0x10>
		n++;
  80086d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800870:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800874:	75 f7                	jne    80086d <strlen+0xd>
		n++;
	return n;
}
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800881:	b8 00 00 00 00       	mov    $0x0,%eax
  800886:	eb 03                	jmp    80088b <strnlen+0x13>
		n++;
  800888:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088b:	39 d0                	cmp    %edx,%eax
  80088d:	74 06                	je     800895 <strnlen+0x1d>
  80088f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800893:	75 f3                	jne    800888 <strnlen+0x10>
		n++;
	return n;
}
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	53                   	push   %ebx
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a1:	89 c2                	mov    %eax,%edx
  8008a3:	83 c2 01             	add    $0x1,%edx
  8008a6:	83 c1 01             	add    $0x1,%ecx
  8008a9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008ad:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008b0:	84 db                	test   %bl,%bl
  8008b2:	75 ef                	jne    8008a3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008b4:	5b                   	pop    %ebx
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	53                   	push   %ebx
  8008bb:	83 ec 08             	sub    $0x8,%esp
  8008be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c1:	89 1c 24             	mov    %ebx,(%esp)
  8008c4:	e8 97 ff ff ff       	call   800860 <strlen>
	strcpy(dst + len, src);
  8008c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008d0:	01 d8                	add    %ebx,%eax
  8008d2:	89 04 24             	mov    %eax,(%esp)
  8008d5:	e8 bd ff ff ff       	call   800897 <strcpy>
	return dst;
}
  8008da:	89 d8                	mov    %ebx,%eax
  8008dc:	83 c4 08             	add    $0x8,%esp
  8008df:	5b                   	pop    %ebx
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	56                   	push   %esi
  8008e6:	53                   	push   %ebx
  8008e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ed:	89 f3                	mov    %esi,%ebx
  8008ef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f2:	89 f2                	mov    %esi,%edx
  8008f4:	eb 0f                	jmp    800905 <strncpy+0x23>
		*dst++ = *src;
  8008f6:	83 c2 01             	add    $0x1,%edx
  8008f9:	0f b6 01             	movzbl (%ecx),%eax
  8008fc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008ff:	80 39 01             	cmpb   $0x1,(%ecx)
  800902:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800905:	39 da                	cmp    %ebx,%edx
  800907:	75 ed                	jne    8008f6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800909:	89 f0                	mov    %esi,%eax
  80090b:	5b                   	pop    %ebx
  80090c:	5e                   	pop    %esi
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	56                   	push   %esi
  800913:	53                   	push   %ebx
  800914:	8b 75 08             	mov    0x8(%ebp),%esi
  800917:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80091d:	89 f0                	mov    %esi,%eax
  80091f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800923:	85 c9                	test   %ecx,%ecx
  800925:	75 0b                	jne    800932 <strlcpy+0x23>
  800927:	eb 1d                	jmp    800946 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800929:	83 c0 01             	add    $0x1,%eax
  80092c:	83 c2 01             	add    $0x1,%edx
  80092f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800932:	39 d8                	cmp    %ebx,%eax
  800934:	74 0b                	je     800941 <strlcpy+0x32>
  800936:	0f b6 0a             	movzbl (%edx),%ecx
  800939:	84 c9                	test   %cl,%cl
  80093b:	75 ec                	jne    800929 <strlcpy+0x1a>
  80093d:	89 c2                	mov    %eax,%edx
  80093f:	eb 02                	jmp    800943 <strlcpy+0x34>
  800941:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800943:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800946:	29 f0                	sub    %esi,%eax
}
  800948:	5b                   	pop    %ebx
  800949:	5e                   	pop    %esi
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800952:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800955:	eb 06                	jmp    80095d <strcmp+0x11>
		p++, q++;
  800957:	83 c1 01             	add    $0x1,%ecx
  80095a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80095d:	0f b6 01             	movzbl (%ecx),%eax
  800960:	84 c0                	test   %al,%al
  800962:	74 04                	je     800968 <strcmp+0x1c>
  800964:	3a 02                	cmp    (%edx),%al
  800966:	74 ef                	je     800957 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800968:	0f b6 c0             	movzbl %al,%eax
  80096b:	0f b6 12             	movzbl (%edx),%edx
  80096e:	29 d0                	sub    %edx,%eax
}
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	53                   	push   %ebx
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097c:	89 c3                	mov    %eax,%ebx
  80097e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800981:	eb 06                	jmp    800989 <strncmp+0x17>
		n--, p++, q++;
  800983:	83 c0 01             	add    $0x1,%eax
  800986:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800989:	39 d8                	cmp    %ebx,%eax
  80098b:	74 15                	je     8009a2 <strncmp+0x30>
  80098d:	0f b6 08             	movzbl (%eax),%ecx
  800990:	84 c9                	test   %cl,%cl
  800992:	74 04                	je     800998 <strncmp+0x26>
  800994:	3a 0a                	cmp    (%edx),%cl
  800996:	74 eb                	je     800983 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800998:	0f b6 00             	movzbl (%eax),%eax
  80099b:	0f b6 12             	movzbl (%edx),%edx
  80099e:	29 d0                	sub    %edx,%eax
  8009a0:	eb 05                	jmp    8009a7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009a2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009a7:	5b                   	pop    %ebx
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b4:	eb 07                	jmp    8009bd <strchr+0x13>
		if (*s == c)
  8009b6:	38 ca                	cmp    %cl,%dl
  8009b8:	74 0f                	je     8009c9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ba:	83 c0 01             	add    $0x1,%eax
  8009bd:	0f b6 10             	movzbl (%eax),%edx
  8009c0:	84 d2                	test   %dl,%dl
  8009c2:	75 f2                	jne    8009b6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d5:	eb 07                	jmp    8009de <strfind+0x13>
		if (*s == c)
  8009d7:	38 ca                	cmp    %cl,%dl
  8009d9:	74 0a                	je     8009e5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009db:	83 c0 01             	add    $0x1,%eax
  8009de:	0f b6 10             	movzbl (%eax),%edx
  8009e1:	84 d2                	test   %dl,%dl
  8009e3:	75 f2                	jne    8009d7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	57                   	push   %edi
  8009eb:	56                   	push   %esi
  8009ec:	53                   	push   %ebx
  8009ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f3:	85 c9                	test   %ecx,%ecx
  8009f5:	74 36                	je     800a2d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009fd:	75 28                	jne    800a27 <memset+0x40>
  8009ff:	f6 c1 03             	test   $0x3,%cl
  800a02:	75 23                	jne    800a27 <memset+0x40>
		c &= 0xFF;
  800a04:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a08:	89 d3                	mov    %edx,%ebx
  800a0a:	c1 e3 08             	shl    $0x8,%ebx
  800a0d:	89 d6                	mov    %edx,%esi
  800a0f:	c1 e6 18             	shl    $0x18,%esi
  800a12:	89 d0                	mov    %edx,%eax
  800a14:	c1 e0 10             	shl    $0x10,%eax
  800a17:	09 f0                	or     %esi,%eax
  800a19:	09 c2                	or     %eax,%edx
  800a1b:	89 d0                	mov    %edx,%eax
  800a1d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a1f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a22:	fc                   	cld    
  800a23:	f3 ab                	rep stos %eax,%es:(%edi)
  800a25:	eb 06                	jmp    800a2d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2a:	fc                   	cld    
  800a2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a2d:	89 f8                	mov    %edi,%eax
  800a2f:	5b                   	pop    %ebx
  800a30:	5e                   	pop    %esi
  800a31:	5f                   	pop    %edi
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	57                   	push   %edi
  800a38:	56                   	push   %esi
  800a39:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a42:	39 c6                	cmp    %eax,%esi
  800a44:	73 35                	jae    800a7b <memmove+0x47>
  800a46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a49:	39 d0                	cmp    %edx,%eax
  800a4b:	73 2e                	jae    800a7b <memmove+0x47>
		s += n;
		d += n;
  800a4d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a50:	89 d6                	mov    %edx,%esi
  800a52:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a54:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a5a:	75 13                	jne    800a6f <memmove+0x3b>
  800a5c:	f6 c1 03             	test   $0x3,%cl
  800a5f:	75 0e                	jne    800a6f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a61:	83 ef 04             	sub    $0x4,%edi
  800a64:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a67:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a6a:	fd                   	std    
  800a6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6d:	eb 09                	jmp    800a78 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a6f:	83 ef 01             	sub    $0x1,%edi
  800a72:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a75:	fd                   	std    
  800a76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a78:	fc                   	cld    
  800a79:	eb 1d                	jmp    800a98 <memmove+0x64>
  800a7b:	89 f2                	mov    %esi,%edx
  800a7d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7f:	f6 c2 03             	test   $0x3,%dl
  800a82:	75 0f                	jne    800a93 <memmove+0x5f>
  800a84:	f6 c1 03             	test   $0x3,%cl
  800a87:	75 0a                	jne    800a93 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a89:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a8c:	89 c7                	mov    %eax,%edi
  800a8e:	fc                   	cld    
  800a8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a91:	eb 05                	jmp    800a98 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a93:	89 c7                	mov    %eax,%edi
  800a95:	fc                   	cld    
  800a96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a98:	5e                   	pop    %esi
  800a99:	5f                   	pop    %edi
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aa2:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aa9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab3:	89 04 24             	mov    %eax,(%esp)
  800ab6:	e8 79 ff ff ff       	call   800a34 <memmove>
}
  800abb:	c9                   	leave  
  800abc:	c3                   	ret    

00800abd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	56                   	push   %esi
  800ac1:	53                   	push   %ebx
  800ac2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac8:	89 d6                	mov    %edx,%esi
  800aca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acd:	eb 1a                	jmp    800ae9 <memcmp+0x2c>
		if (*s1 != *s2)
  800acf:	0f b6 02             	movzbl (%edx),%eax
  800ad2:	0f b6 19             	movzbl (%ecx),%ebx
  800ad5:	38 d8                	cmp    %bl,%al
  800ad7:	74 0a                	je     800ae3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ad9:	0f b6 c0             	movzbl %al,%eax
  800adc:	0f b6 db             	movzbl %bl,%ebx
  800adf:	29 d8                	sub    %ebx,%eax
  800ae1:	eb 0f                	jmp    800af2 <memcmp+0x35>
		s1++, s2++;
  800ae3:	83 c2 01             	add    $0x1,%edx
  800ae6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae9:	39 f2                	cmp    %esi,%edx
  800aeb:	75 e2                	jne    800acf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	8b 45 08             	mov    0x8(%ebp),%eax
  800afc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aff:	89 c2                	mov    %eax,%edx
  800b01:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b04:	eb 07                	jmp    800b0d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b06:	38 08                	cmp    %cl,(%eax)
  800b08:	74 07                	je     800b11 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b0a:	83 c0 01             	add    $0x1,%eax
  800b0d:	39 d0                	cmp    %edx,%eax
  800b0f:	72 f5                	jb     800b06 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	57                   	push   %edi
  800b17:	56                   	push   %esi
  800b18:	53                   	push   %ebx
  800b19:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1f:	eb 03                	jmp    800b24 <strtol+0x11>
		s++;
  800b21:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b24:	0f b6 0a             	movzbl (%edx),%ecx
  800b27:	80 f9 09             	cmp    $0x9,%cl
  800b2a:	74 f5                	je     800b21 <strtol+0xe>
  800b2c:	80 f9 20             	cmp    $0x20,%cl
  800b2f:	74 f0                	je     800b21 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b31:	80 f9 2b             	cmp    $0x2b,%cl
  800b34:	75 0a                	jne    800b40 <strtol+0x2d>
		s++;
  800b36:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b39:	bf 00 00 00 00       	mov    $0x0,%edi
  800b3e:	eb 11                	jmp    800b51 <strtol+0x3e>
  800b40:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b45:	80 f9 2d             	cmp    $0x2d,%cl
  800b48:	75 07                	jne    800b51 <strtol+0x3e>
		s++, neg = 1;
  800b4a:	8d 52 01             	lea    0x1(%edx),%edx
  800b4d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b51:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b56:	75 15                	jne    800b6d <strtol+0x5a>
  800b58:	80 3a 30             	cmpb   $0x30,(%edx)
  800b5b:	75 10                	jne    800b6d <strtol+0x5a>
  800b5d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b61:	75 0a                	jne    800b6d <strtol+0x5a>
		s += 2, base = 16;
  800b63:	83 c2 02             	add    $0x2,%edx
  800b66:	b8 10 00 00 00       	mov    $0x10,%eax
  800b6b:	eb 10                	jmp    800b7d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800b6d:	85 c0                	test   %eax,%eax
  800b6f:	75 0c                	jne    800b7d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b71:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b73:	80 3a 30             	cmpb   $0x30,(%edx)
  800b76:	75 05                	jne    800b7d <strtol+0x6a>
		s++, base = 8;
  800b78:	83 c2 01             	add    $0x1,%edx
  800b7b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800b7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b82:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b85:	0f b6 0a             	movzbl (%edx),%ecx
  800b88:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b8b:	89 f0                	mov    %esi,%eax
  800b8d:	3c 09                	cmp    $0x9,%al
  800b8f:	77 08                	ja     800b99 <strtol+0x86>
			dig = *s - '0';
  800b91:	0f be c9             	movsbl %cl,%ecx
  800b94:	83 e9 30             	sub    $0x30,%ecx
  800b97:	eb 20                	jmp    800bb9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b99:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b9c:	89 f0                	mov    %esi,%eax
  800b9e:	3c 19                	cmp    $0x19,%al
  800ba0:	77 08                	ja     800baa <strtol+0x97>
			dig = *s - 'a' + 10;
  800ba2:	0f be c9             	movsbl %cl,%ecx
  800ba5:	83 e9 57             	sub    $0x57,%ecx
  800ba8:	eb 0f                	jmp    800bb9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800baa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800bad:	89 f0                	mov    %esi,%eax
  800baf:	3c 19                	cmp    $0x19,%al
  800bb1:	77 16                	ja     800bc9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800bb3:	0f be c9             	movsbl %cl,%ecx
  800bb6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bb9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800bbc:	7d 0f                	jge    800bcd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800bbe:	83 c2 01             	add    $0x1,%edx
  800bc1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800bc5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800bc7:	eb bc                	jmp    800b85 <strtol+0x72>
  800bc9:	89 d8                	mov    %ebx,%eax
  800bcb:	eb 02                	jmp    800bcf <strtol+0xbc>
  800bcd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800bcf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd3:	74 05                	je     800bda <strtol+0xc7>
		*endptr = (char *) s;
  800bd5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800bda:	f7 d8                	neg    %eax
  800bdc:	85 ff                	test   %edi,%edi
  800bde:	0f 44 c3             	cmove  %ebx,%eax
}
  800be1:	5b                   	pop    %ebx
  800be2:	5e                   	pop    %esi
  800be3:	5f                   	pop    %edi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	57                   	push   %edi
  800bea:	56                   	push   %esi
  800beb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bec:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf7:	89 c3                	mov    %eax,%ebx
  800bf9:	89 c7                	mov    %eax,%edi
  800bfb:	89 c6                	mov    %eax,%esi
  800bfd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c14:	89 d1                	mov    %edx,%ecx
  800c16:	89 d3                	mov    %edx,%ebx
  800c18:	89 d7                	mov    %edx,%edi
  800c1a:	89 d6                	mov    %edx,%esi
  800c1c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c31:	b8 03 00 00 00       	mov    $0x3,%eax
  800c36:	8b 55 08             	mov    0x8(%ebp),%edx
  800c39:	89 cb                	mov    %ecx,%ebx
  800c3b:	89 cf                	mov    %ecx,%edi
  800c3d:	89 ce                	mov    %ecx,%esi
  800c3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c41:	85 c0                	test   %eax,%eax
  800c43:	7e 28                	jle    800c6d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c45:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c49:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c50:	00 
  800c51:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800c58:	00 
  800c59:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c60:	00 
  800c61:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800c68:	e8 05 f5 ff ff       	call   800172 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c6d:	83 c4 2c             	add    $0x2c,%esp
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c80:	b8 02 00 00 00       	mov    $0x2,%eax
  800c85:	89 d1                	mov    %edx,%ecx
  800c87:	89 d3                	mov    %edx,%ebx
  800c89:	89 d7                	mov    %edx,%edi
  800c8b:	89 d6                	mov    %edx,%esi
  800c8d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <sys_yield>:

void
sys_yield(void)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c9f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ca4:	89 d1                	mov    %edx,%ecx
  800ca6:	89 d3                	mov    %edx,%ebx
  800ca8:	89 d7                	mov    %edx,%edi
  800caa:	89 d6                	mov    %edx,%esi
  800cac:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cae:	5b                   	pop    %ebx
  800caf:	5e                   	pop    %esi
  800cb0:	5f                   	pop    %edi
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    

00800cb3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	57                   	push   %edi
  800cb7:	56                   	push   %esi
  800cb8:	53                   	push   %ebx
  800cb9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbc:	be 00 00 00 00       	mov    $0x0,%esi
  800cc1:	b8 04 00 00 00       	mov    $0x4,%eax
  800cc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ccf:	89 f7                	mov    %esi,%edi
  800cd1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd3:	85 c0                	test   %eax,%eax
  800cd5:	7e 28                	jle    800cff <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cdb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ce2:	00 
  800ce3:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800cea:	00 
  800ceb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf2:	00 
  800cf3:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800cfa:	e8 73 f4 ff ff       	call   800172 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cff:	83 c4 2c             	add    $0x2c,%esp
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d10:	b8 05 00 00 00       	mov    $0x5,%eax
  800d15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d18:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d21:	8b 75 18             	mov    0x18(%ebp),%esi
  800d24:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d26:	85 c0                	test   %eax,%eax
  800d28:	7e 28                	jle    800d52 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d35:	00 
  800d36:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800d3d:	00 
  800d3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d45:	00 
  800d46:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800d4d:	e8 20 f4 ff ff       	call   800172 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d52:	83 c4 2c             	add    $0x2c,%esp
  800d55:	5b                   	pop    %ebx
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	57                   	push   %edi
  800d5e:	56                   	push   %esi
  800d5f:	53                   	push   %ebx
  800d60:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d68:	b8 06 00 00 00       	mov    $0x6,%eax
  800d6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d70:	8b 55 08             	mov    0x8(%ebp),%edx
  800d73:	89 df                	mov    %ebx,%edi
  800d75:	89 de                	mov    %ebx,%esi
  800d77:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	7e 28                	jle    800da5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d81:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d88:	00 
  800d89:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800d90:	00 
  800d91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d98:	00 
  800d99:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800da0:	e8 cd f3 ff ff       	call   800172 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800da5:	83 c4 2c             	add    $0x2c,%esp
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	57                   	push   %edi
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
  800db3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbb:	b8 08 00 00 00       	mov    $0x8,%eax
  800dc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc6:	89 df                	mov    %ebx,%edi
  800dc8:	89 de                	mov    %ebx,%esi
  800dca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dcc:	85 c0                	test   %eax,%eax
  800dce:	7e 28                	jle    800df8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ddb:	00 
  800ddc:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800de3:	00 
  800de4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800deb:	00 
  800dec:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800df3:	e8 7a f3 ff ff       	call   800172 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800df8:	83 c4 2c             	add    $0x2c,%esp
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	57                   	push   %edi
  800e04:	56                   	push   %esi
  800e05:	53                   	push   %ebx
  800e06:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0e:	b8 09 00 00 00       	mov    $0x9,%eax
  800e13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e16:	8b 55 08             	mov    0x8(%ebp),%edx
  800e19:	89 df                	mov    %ebx,%edi
  800e1b:	89 de                	mov    %ebx,%esi
  800e1d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	7e 28                	jle    800e4b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e23:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e27:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e2e:	00 
  800e2f:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800e36:	00 
  800e37:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e3e:	00 
  800e3f:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800e46:	e8 27 f3 ff ff       	call   800172 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e4b:	83 c4 2c             	add    $0x2c,%esp
  800e4e:	5b                   	pop    %ebx
  800e4f:	5e                   	pop    %esi
  800e50:	5f                   	pop    %edi
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    

00800e53 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	57                   	push   %edi
  800e57:	56                   	push   %esi
  800e58:	53                   	push   %ebx
  800e59:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e61:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e69:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6c:	89 df                	mov    %ebx,%edi
  800e6e:	89 de                	mov    %ebx,%esi
  800e70:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e72:	85 c0                	test   %eax,%eax
  800e74:	7e 28                	jle    800e9e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e76:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e81:	00 
  800e82:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800e89:	00 
  800e8a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e91:	00 
  800e92:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800e99:	e8 d4 f2 ff ff       	call   800172 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e9e:	83 c4 2c             	add    $0x2c,%esp
  800ea1:	5b                   	pop    %ebx
  800ea2:	5e                   	pop    %esi
  800ea3:	5f                   	pop    %edi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	57                   	push   %edi
  800eaa:	56                   	push   %esi
  800eab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eac:	be 00 00 00 00       	mov    $0x0,%esi
  800eb1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ebf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ec4:	5b                   	pop    %ebx
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    

00800ec9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
  800ecc:	57                   	push   %edi
  800ecd:	56                   	push   %esi
  800ece:	53                   	push   %ebx
  800ecf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800edc:	8b 55 08             	mov    0x8(%ebp),%edx
  800edf:	89 cb                	mov    %ecx,%ebx
  800ee1:	89 cf                	mov    %ecx,%edi
  800ee3:	89 ce                	mov    %ecx,%esi
  800ee5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee7:	85 c0                	test   %eax,%eax
  800ee9:	7e 28                	jle    800f13 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eeb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eef:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ef6:	00 
  800ef7:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800efe:	00 
  800eff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f06:	00 
  800f07:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800f0e:	e8 5f f2 ff ff       	call   800172 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f13:	83 c4 2c             	add    $0x2c,%esp
  800f16:	5b                   	pop    %ebx
  800f17:	5e                   	pop    %esi
  800f18:	5f                   	pop    %edi
  800f19:	5d                   	pop    %ebp
  800f1a:	c3                   	ret    

00800f1b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
  800f1e:	57                   	push   %edi
  800f1f:	56                   	push   %esi
  800f20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f21:	ba 00 00 00 00       	mov    $0x0,%edx
  800f26:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f2b:	89 d1                	mov    %edx,%ecx
  800f2d:	89 d3                	mov    %edx,%ebx
  800f2f:	89 d7                	mov    %edx,%edi
  800f31:	89 d6                	mov    %edx,%esi
  800f33:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f35:	5b                   	pop    %ebx
  800f36:	5e                   	pop    %esi
  800f37:	5f                   	pop    %edi
  800f38:	5d                   	pop    %ebp
  800f39:	c3                   	ret    

00800f3a <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  800f3a:	55                   	push   %ebp
  800f3b:	89 e5                	mov    %esp,%ebp
  800f3d:	57                   	push   %edi
  800f3e:	56                   	push   %esi
  800f3f:	53                   	push   %ebx
  800f40:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f48:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f50:	8b 55 08             	mov    0x8(%ebp),%edx
  800f53:	89 df                	mov    %ebx,%edi
  800f55:	89 de                	mov    %ebx,%esi
  800f57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f59:	85 c0                	test   %eax,%eax
  800f5b:	7e 28                	jle    800f85 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f61:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800f68:	00 
  800f69:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800f70:	00 
  800f71:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f78:	00 
  800f79:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800f80:	e8 ed f1 ff ff       	call   800172 <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  800f85:	83 c4 2c             	add    $0x2c,%esp
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    

00800f8d <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	57                   	push   %edi
  800f91:	56                   	push   %esi
  800f92:	53                   	push   %ebx
  800f93:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f9b:	b8 10 00 00 00       	mov    $0x10,%eax
  800fa0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa6:	89 df                	mov    %ebx,%edi
  800fa8:	89 de                	mov    %ebx,%esi
  800faa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fac:	85 c0                	test   %eax,%eax
  800fae:	7e 28                	jle    800fd8 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fb4:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  800fbb:	00 
  800fbc:	c7 44 24 08 9f 2d 80 	movl   $0x802d9f,0x8(%esp)
  800fc3:	00 
  800fc4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fcb:	00 
  800fcc:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  800fd3:	e8 9a f1 ff ff       	call   800172 <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  800fd8:	83 c4 2c             	add    $0x2c,%esp
  800fdb:	5b                   	pop    %ebx
  800fdc:	5e                   	pop    %esi
  800fdd:	5f                   	pop    %edi
  800fde:	5d                   	pop    %ebp
  800fdf:	c3                   	ret    

00800fe0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	56                   	push   %esi
  800fe4:	53                   	push   %ebx
  800fe5:	83 ec 20             	sub    $0x20,%esp
  800fe8:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800feb:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if(!(err & FEC_WR)) {
  800fed:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ff1:	75 20                	jne    801013 <pgfault+0x33>
		panic("0x%x Not a write", addr);
  800ff3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ff7:	c7 44 24 08 ca 2d 80 	movl   $0x802dca,0x8(%esp)
  800ffe:	00 
  800fff:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801006:	00 
  801007:	c7 04 24 db 2d 80 00 	movl   $0x802ddb,(%esp)
  80100e:	e8 5f f1 ff ff       	call   800172 <_panic>
	}

	if(!(uvpt[PGNUM(addr)] & PTE_COW)) {
  801013:	89 f0                	mov    %esi,%eax
  801015:	c1 e8 0c             	shr    $0xc,%eax
  801018:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80101f:	f6 c4 08             	test   $0x8,%ah
  801022:	75 1c                	jne    801040 <pgfault+0x60>
		panic("Not a COW page");
  801024:	c7 44 24 08 e6 2d 80 	movl   $0x802de6,0x8(%esp)
  80102b:	00 
  80102c:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  801033:	00 
  801034:	c7 04 24 db 2d 80 00 	movl   $0x802ddb,(%esp)
  80103b:	e8 32 f1 ff ff       	call   800172 <_panic>

	// Allocate a new page, map it at a temporary location (PFTEMP), // copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	envid_t envid = sys_getenvid();
  801040:	e8 30 fc ff ff       	call   800c75 <sys_getenvid>
  801045:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, PFTEMP, PTE_W | PTE_U | PTE_P);
  801047:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80104e:	00 
  80104f:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801056:	00 
  801057:	89 04 24             	mov    %eax,(%esp)
  80105a:	e8 54 fc ff ff       	call   800cb3 <sys_page_alloc>
	if(r < 0) {
  80105f:	85 c0                	test   %eax,%eax
  801061:	79 1c                	jns    80107f <pgfault+0x9f>
		panic("couldn't allocate page");
  801063:	c7 44 24 08 f5 2d 80 	movl   $0x802df5,0x8(%esp)
  80106a:	00 
  80106b:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801072:	00 
  801073:	c7 04 24 db 2d 80 00 	movl   $0x802ddb,(%esp)
  80107a:	e8 f3 f0 ff ff       	call   800172 <_panic>
	}

	memmove(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  80107f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  801085:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80108c:	00 
  80108d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801091:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801098:	e8 97 f9 ff ff       	call   800a34 <memmove>

	r = sys_page_map(envid, PFTEMP, envid, ROUNDDOWN(addr,PGSIZE), PTE_P | PTE_U | PTE_W);
  80109d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8010a4:	00 
  8010a5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010ad:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010b4:	00 
  8010b5:	89 1c 24             	mov    %ebx,(%esp)
  8010b8:	e8 4a fc ff ff       	call   800d07 <sys_page_map>
	if(r < 0) {
  8010bd:	85 c0                	test   %eax,%eax
  8010bf:	79 1c                	jns    8010dd <pgfault+0xfd>
		panic("couldn't map page");
  8010c1:	c7 44 24 08 0c 2e 80 	movl   $0x802e0c,0x8(%esp)
  8010c8:	00 
  8010c9:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  8010d0:	00 
  8010d1:	c7 04 24 db 2d 80 00 	movl   $0x802ddb,(%esp)
  8010d8:	e8 95 f0 ff ff       	call   800172 <_panic>
	}
}
  8010dd:	83 c4 20             	add    $0x20,%esp
  8010e0:	5b                   	pop    %ebx
  8010e1:	5e                   	pop    %esi
  8010e2:	5d                   	pop    %ebp
  8010e3:	c3                   	ret    

008010e4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	57                   	push   %edi
  8010e8:	56                   	push   %esi
  8010e9:	53                   	push   %ebx
  8010ea:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envid;
	uintptr_t addr;
	int r = 0;

	set_pgfault_handler(pgfault);
  8010ed:	c7 04 24 e0 0f 80 00 	movl   $0x800fe0,(%esp)
  8010f4:	e8 ad 14 00 00       	call   8025a6 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010f9:	b8 07 00 00 00       	mov    $0x7,%eax
  8010fe:	cd 30                	int    $0x30
  801100:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801103:	89 45 d8             	mov    %eax,-0x28(%ebp)

	envid = sys_exofork();
	if(envid == 0) {
  801106:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80110d:	bf 00 00 00 00       	mov    $0x0,%edi
  801112:	85 c0                	test   %eax,%eax
  801114:	75 21                	jne    801137 <fork+0x53>
		thisenv = &envs[ENVX(sys_getenvid())];
  801116:	e8 5a fb ff ff       	call   800c75 <sys_getenvid>
  80111b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801120:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801123:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801128:	a3 0c 40 80 00       	mov    %eax,0x80400c
		return 0;
  80112d:	b8 00 00 00 00       	mov    $0x0,%eax
  801132:	e9 8d 01 00 00       	jmp    8012c4 <fork+0x1e0>
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
  801137:	89 f8                	mov    %edi,%eax
  801139:	c1 e8 16             	shr    $0x16,%eax
  80113c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801143:	85 c0                	test   %eax,%eax
  801145:	0f 84 02 01 00 00    	je     80124d <fork+0x169>
  80114b:	89 fa                	mov    %edi,%edx
  80114d:	c1 ea 0c             	shr    $0xc,%edx
  801150:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801157:	85 c0                	test   %eax,%eax
  801159:	0f 84 ee 00 00 00    	je     80124d <fork+0x169>
//
static int
duppage(envid_t envid, unsigned pn)
{

	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P)) return 0;
  80115f:	89 d6                	mov    %edx,%esi
  801161:	c1 e6 0c             	shl    $0xc,%esi
  801164:	89 f0                	mov    %esi,%eax
  801166:	c1 e8 16             	shr    $0x16,%eax
  801169:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  801170:	b8 00 00 00 00       	mov    $0x0,%eax
  801175:	f6 c1 01             	test   $0x1,%cl
  801178:	0f 84 cc 00 00 00    	je     80124a <fork+0x166>

	int all_perms = PTE_U | PTE_P | PTE_AVAIL | PTE_W | PTE_COW;
	int orig_perms = uvpt[pn] & all_perms;
  80117e:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  801185:	89 d8                	mov    %ebx,%eax
  801187:	25 07 0e 00 00       	and    $0xe07,%eax
  80118c:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if(!(orig_perms & PTE_P)) return 0;
  80118f:	89 d8                	mov    %ebx,%eax
  801191:	83 e0 01             	and    $0x1,%eax
  801194:	0f 84 b0 00 00 00    	je     80124a <fork+0x166>

	int r = 0;
	envid_t curenvid = sys_getenvid();
  80119a:	e8 d6 fa ff ff       	call   800c75 <sys_getenvid>
  80119f:	89 45 dc             	mov    %eax,-0x24(%ebp)


	if(orig_perms & PTE_SHARE) {
  8011a2:	f7 45 e0 00 04 00 00 	testl  $0x400,-0x20(%ebp)
  8011a9:	74 28                	je     8011d3 <fork+0xef>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms & PTE_SYSCALL));
  8011ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011ae:	25 07 0e 00 00       	and    $0xe07,%eax
  8011b3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011b7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8011be:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011c9:	89 04 24             	mov    %eax,(%esp)
  8011cc:	e8 36 fb ff ff       	call   800d07 <sys_page_map>
  8011d1:	eb 77                	jmp    80124a <fork+0x166>

	} else if(((orig_perms) & PTE_COW) || (orig_perms & PTE_W) ) {
  8011d3:	f7 c3 02 08 00 00    	test   $0x802,%ebx
  8011d9:	74 4e                	je     801229 <fork+0x145>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  8011db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011de:	25 fd f7 ff ff       	and    $0xfffff7fd,%eax
  8011e3:	80 cc 08             	or     $0x8,%ah
  8011e6:	89 c3                	mov    %eax,%ebx
  8011e8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ec:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8011f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011fe:	89 04 24             	mov    %eax,(%esp)
  801201:	e8 01 fb ff ff       	call   800d07 <sys_page_map>
  801206:	89 45 e0             	mov    %eax,-0x20(%ebp)

		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), curenvid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  801209:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80120d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801211:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801214:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801218:	89 74 24 04          	mov    %esi,0x4(%esp)
  80121c:	89 0c 24             	mov    %ecx,(%esp)
  80121f:	e8 e3 fa ff ff       	call   800d07 <sys_page_map>
  801224:	03 45 e0             	add    -0x20(%ebp),%eax
  801227:	eb 21                	jmp    80124a <fork+0x166>

	} else {
		r = sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), orig_perms);
  801229:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80122c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801230:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801234:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801237:	89 44 24 08          	mov    %eax,0x8(%esp)
  80123b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80123f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801242:	89 04 24             	mov    %eax,(%esp)
  801245:	e8 bd fa ff ff       	call   800d07 <sys_page_map>
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
  80124a:	01 45 e4             	add    %eax,-0x1c(%ebp)
	if(envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
  80124d:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801253:	81 ff 00 f0 bf ee    	cmp    $0xeebff000,%edi
  801259:	0f 85 d8 fe ff ff    	jne    801137 <fork+0x53>
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
		}
	}

	r+=sys_page_alloc(envid, (void*)UXSTACKTOP - PGSIZE, PTE_P|PTE_U|PTE_W);
  80125f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801266:	00 
  801267:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80126e:	ee 
  80126f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801272:	89 34 24             	mov    %esi,(%esp)
  801275:	e8 39 fa ff ff       	call   800cb3 <sys_page_alloc>
  80127a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80127d:	01 c3                	add    %eax,%ebx
	r+=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80127f:	c7 44 24 04 f3 25 80 	movl   $0x8025f3,0x4(%esp)
  801286:	00 
  801287:	89 34 24             	mov    %esi,(%esp)
  80128a:	e8 c4 fb ff ff       	call   800e53 <sys_env_set_pgfault_upcall>
  80128f:	01 c3                	add    %eax,%ebx
	r+= sys_env_set_status(envid, ENV_RUNNABLE);
  801291:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801298:	00 
  801299:	89 34 24             	mov    %esi,(%esp)
  80129c:	e8 0c fb ff ff       	call   800dad <sys_env_set_status>

	if(r<0) {
  8012a1:	01 d8                	add    %ebx,%eax
  8012a3:	79 1c                	jns    8012c1 <fork+0x1dd>
	 panic("fork failed!");
  8012a5:	c7 44 24 08 1e 2e 80 	movl   $0x802e1e,0x8(%esp)
  8012ac:	00 
  8012ad:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  8012b4:	00 
  8012b5:	c7 04 24 db 2d 80 00 	movl   $0x802ddb,(%esp)
  8012bc:	e8 b1 ee ff ff       	call   800172 <_panic>
	}

	return envid;
  8012c1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  8012c4:	83 c4 3c             	add    $0x3c,%esp
  8012c7:	5b                   	pop    %ebx
  8012c8:	5e                   	pop    %esi
  8012c9:	5f                   	pop    %edi
  8012ca:	5d                   	pop    %ebp
  8012cb:	c3                   	ret    

008012cc <sfork>:

// Challenge!
int
sfork(void)
{
  8012cc:	55                   	push   %ebp
  8012cd:	89 e5                	mov    %esp,%ebp
  8012cf:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8012d2:	c7 44 24 08 2b 2e 80 	movl   $0x802e2b,0x8(%esp)
  8012d9:	00 
  8012da:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
  8012e1:	00 
  8012e2:	c7 04 24 db 2d 80 00 	movl   $0x802ddb,(%esp)
  8012e9:	e8 84 ee ff ff       	call   800172 <_panic>
  8012ee:	66 90                	xchg   %ax,%ax

008012f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8012fb:	c1 e8 0c             	shr    $0xc,%eax
}
  8012fe:	5d                   	pop    %ebp
  8012ff:	c3                   	ret    

00801300 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801303:	8b 45 08             	mov    0x8(%ebp),%eax
  801306:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80130b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801310:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801315:	5d                   	pop    %ebp
  801316:	c3                   	ret    

00801317 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801317:	55                   	push   %ebp
  801318:	89 e5                	mov    %esp,%ebp
  80131a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80131d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801322:	89 c2                	mov    %eax,%edx
  801324:	c1 ea 16             	shr    $0x16,%edx
  801327:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80132e:	f6 c2 01             	test   $0x1,%dl
  801331:	74 11                	je     801344 <fd_alloc+0x2d>
  801333:	89 c2                	mov    %eax,%edx
  801335:	c1 ea 0c             	shr    $0xc,%edx
  801338:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80133f:	f6 c2 01             	test   $0x1,%dl
  801342:	75 09                	jne    80134d <fd_alloc+0x36>
			*fd_store = fd;
  801344:	89 01                	mov    %eax,(%ecx)
			return 0;
  801346:	b8 00 00 00 00       	mov    $0x0,%eax
  80134b:	eb 17                	jmp    801364 <fd_alloc+0x4d>
  80134d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801352:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801357:	75 c9                	jne    801322 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801359:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80135f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801364:	5d                   	pop    %ebp
  801365:	c3                   	ret    

00801366 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801366:	55                   	push   %ebp
  801367:	89 e5                	mov    %esp,%ebp
  801369:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80136c:	83 f8 1f             	cmp    $0x1f,%eax
  80136f:	77 36                	ja     8013a7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801371:	c1 e0 0c             	shl    $0xc,%eax
  801374:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801379:	89 c2                	mov    %eax,%edx
  80137b:	c1 ea 16             	shr    $0x16,%edx
  80137e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801385:	f6 c2 01             	test   $0x1,%dl
  801388:	74 24                	je     8013ae <fd_lookup+0x48>
  80138a:	89 c2                	mov    %eax,%edx
  80138c:	c1 ea 0c             	shr    $0xc,%edx
  80138f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801396:	f6 c2 01             	test   $0x1,%dl
  801399:	74 1a                	je     8013b5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80139b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80139e:	89 02                	mov    %eax,(%edx)
	return 0;
  8013a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a5:	eb 13                	jmp    8013ba <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013ac:	eb 0c                	jmp    8013ba <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013b3:	eb 05                	jmp    8013ba <fd_lookup+0x54>
  8013b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013ba:	5d                   	pop    %ebp
  8013bb:	c3                   	ret    

008013bc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	83 ec 18             	sub    $0x18,%esp
  8013c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8013c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ca:	eb 13                	jmp    8013df <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8013cc:	39 08                	cmp    %ecx,(%eax)
  8013ce:	75 0c                	jne    8013dc <dev_lookup+0x20>
			*dev = devtab[i];
  8013d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013d3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8013da:	eb 38                	jmp    801414 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013dc:	83 c2 01             	add    $0x1,%edx
  8013df:	8b 04 95 c0 2e 80 00 	mov    0x802ec0(,%edx,4),%eax
  8013e6:	85 c0                	test   %eax,%eax
  8013e8:	75 e2                	jne    8013cc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013ea:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8013ef:	8b 40 48             	mov    0x48(%eax),%eax
  8013f2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013fa:	c7 04 24 44 2e 80 00 	movl   $0x802e44,(%esp)
  801401:	e8 65 ee ff ff       	call   80026b <cprintf>
	*dev = 0;
  801406:	8b 45 0c             	mov    0xc(%ebp),%eax
  801409:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80140f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801414:	c9                   	leave  
  801415:	c3                   	ret    

00801416 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	56                   	push   %esi
  80141a:	53                   	push   %ebx
  80141b:	83 ec 20             	sub    $0x20,%esp
  80141e:	8b 75 08             	mov    0x8(%ebp),%esi
  801421:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801424:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801427:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80142b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801431:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801434:	89 04 24             	mov    %eax,(%esp)
  801437:	e8 2a ff ff ff       	call   801366 <fd_lookup>
  80143c:	85 c0                	test   %eax,%eax
  80143e:	78 05                	js     801445 <fd_close+0x2f>
	    || fd != fd2)
  801440:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801443:	74 0c                	je     801451 <fd_close+0x3b>
		return (must_exist ? r : 0);
  801445:	84 db                	test   %bl,%bl
  801447:	ba 00 00 00 00       	mov    $0x0,%edx
  80144c:	0f 44 c2             	cmove  %edx,%eax
  80144f:	eb 3f                	jmp    801490 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801451:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801454:	89 44 24 04          	mov    %eax,0x4(%esp)
  801458:	8b 06                	mov    (%esi),%eax
  80145a:	89 04 24             	mov    %eax,(%esp)
  80145d:	e8 5a ff ff ff       	call   8013bc <dev_lookup>
  801462:	89 c3                	mov    %eax,%ebx
  801464:	85 c0                	test   %eax,%eax
  801466:	78 16                	js     80147e <fd_close+0x68>
		if (dev->dev_close)
  801468:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80146e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801473:	85 c0                	test   %eax,%eax
  801475:	74 07                	je     80147e <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801477:	89 34 24             	mov    %esi,(%esp)
  80147a:	ff d0                	call   *%eax
  80147c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80147e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801482:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801489:	e8 cc f8 ff ff       	call   800d5a <sys_page_unmap>
	return r;
  80148e:	89 d8                	mov    %ebx,%eax
}
  801490:	83 c4 20             	add    $0x20,%esp
  801493:	5b                   	pop    %ebx
  801494:	5e                   	pop    %esi
  801495:	5d                   	pop    %ebp
  801496:	c3                   	ret    

00801497 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801497:	55                   	push   %ebp
  801498:	89 e5                	mov    %esp,%ebp
  80149a:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80149d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a7:	89 04 24             	mov    %eax,(%esp)
  8014aa:	e8 b7 fe ff ff       	call   801366 <fd_lookup>
  8014af:	89 c2                	mov    %eax,%edx
  8014b1:	85 d2                	test   %edx,%edx
  8014b3:	78 13                	js     8014c8 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8014b5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8014bc:	00 
  8014bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c0:	89 04 24             	mov    %eax,(%esp)
  8014c3:	e8 4e ff ff ff       	call   801416 <fd_close>
}
  8014c8:	c9                   	leave  
  8014c9:	c3                   	ret    

008014ca <close_all>:

void
close_all(void)
{
  8014ca:	55                   	push   %ebp
  8014cb:	89 e5                	mov    %esp,%ebp
  8014cd:	53                   	push   %ebx
  8014ce:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014d1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014d6:	89 1c 24             	mov    %ebx,(%esp)
  8014d9:	e8 b9 ff ff ff       	call   801497 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014de:	83 c3 01             	add    $0x1,%ebx
  8014e1:	83 fb 20             	cmp    $0x20,%ebx
  8014e4:	75 f0                	jne    8014d6 <close_all+0xc>
		close(i);
}
  8014e6:	83 c4 14             	add    $0x14,%esp
  8014e9:	5b                   	pop    %ebx
  8014ea:	5d                   	pop    %ebp
  8014eb:	c3                   	ret    

008014ec <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014ec:	55                   	push   %ebp
  8014ed:	89 e5                	mov    %esp,%ebp
  8014ef:	57                   	push   %edi
  8014f0:	56                   	push   %esi
  8014f1:	53                   	push   %ebx
  8014f2:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014f5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ff:	89 04 24             	mov    %eax,(%esp)
  801502:	e8 5f fe ff ff       	call   801366 <fd_lookup>
  801507:	89 c2                	mov    %eax,%edx
  801509:	85 d2                	test   %edx,%edx
  80150b:	0f 88 e1 00 00 00    	js     8015f2 <dup+0x106>
		return r;
	close(newfdnum);
  801511:	8b 45 0c             	mov    0xc(%ebp),%eax
  801514:	89 04 24             	mov    %eax,(%esp)
  801517:	e8 7b ff ff ff       	call   801497 <close>

	newfd = INDEX2FD(newfdnum);
  80151c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80151f:	c1 e3 0c             	shl    $0xc,%ebx
  801522:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801528:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80152b:	89 04 24             	mov    %eax,(%esp)
  80152e:	e8 cd fd ff ff       	call   801300 <fd2data>
  801533:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801535:	89 1c 24             	mov    %ebx,(%esp)
  801538:	e8 c3 fd ff ff       	call   801300 <fd2data>
  80153d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80153f:	89 f0                	mov    %esi,%eax
  801541:	c1 e8 16             	shr    $0x16,%eax
  801544:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80154b:	a8 01                	test   $0x1,%al
  80154d:	74 43                	je     801592 <dup+0xa6>
  80154f:	89 f0                	mov    %esi,%eax
  801551:	c1 e8 0c             	shr    $0xc,%eax
  801554:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80155b:	f6 c2 01             	test   $0x1,%dl
  80155e:	74 32                	je     801592 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801560:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801567:	25 07 0e 00 00       	and    $0xe07,%eax
  80156c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801570:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801574:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80157b:	00 
  80157c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801580:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801587:	e8 7b f7 ff ff       	call   800d07 <sys_page_map>
  80158c:	89 c6                	mov    %eax,%esi
  80158e:	85 c0                	test   %eax,%eax
  801590:	78 3e                	js     8015d0 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801592:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801595:	89 c2                	mov    %eax,%edx
  801597:	c1 ea 0c             	shr    $0xc,%edx
  80159a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015a1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8015a7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8015ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8015af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015b6:	00 
  8015b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015c2:	e8 40 f7 ff ff       	call   800d07 <sys_page_map>
  8015c7:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8015c9:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015cc:	85 f6                	test   %esi,%esi
  8015ce:	79 22                	jns    8015f2 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015db:	e8 7a f7 ff ff       	call   800d5a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015e0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8015e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015eb:	e8 6a f7 ff ff       	call   800d5a <sys_page_unmap>
	return r;
  8015f0:	89 f0                	mov    %esi,%eax
}
  8015f2:	83 c4 3c             	add    $0x3c,%esp
  8015f5:	5b                   	pop    %ebx
  8015f6:	5e                   	pop    %esi
  8015f7:	5f                   	pop    %edi
  8015f8:	5d                   	pop    %ebp
  8015f9:	c3                   	ret    

008015fa <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015fa:	55                   	push   %ebp
  8015fb:	89 e5                	mov    %esp,%ebp
  8015fd:	53                   	push   %ebx
  8015fe:	83 ec 24             	sub    $0x24,%esp
  801601:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801604:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801607:	89 44 24 04          	mov    %eax,0x4(%esp)
  80160b:	89 1c 24             	mov    %ebx,(%esp)
  80160e:	e8 53 fd ff ff       	call   801366 <fd_lookup>
  801613:	89 c2                	mov    %eax,%edx
  801615:	85 d2                	test   %edx,%edx
  801617:	78 6d                	js     801686 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801619:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801620:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801623:	8b 00                	mov    (%eax),%eax
  801625:	89 04 24             	mov    %eax,(%esp)
  801628:	e8 8f fd ff ff       	call   8013bc <dev_lookup>
  80162d:	85 c0                	test   %eax,%eax
  80162f:	78 55                	js     801686 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801631:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801634:	8b 50 08             	mov    0x8(%eax),%edx
  801637:	83 e2 03             	and    $0x3,%edx
  80163a:	83 fa 01             	cmp    $0x1,%edx
  80163d:	75 23                	jne    801662 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80163f:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801644:	8b 40 48             	mov    0x48(%eax),%eax
  801647:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80164b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164f:	c7 04 24 85 2e 80 00 	movl   $0x802e85,(%esp)
  801656:	e8 10 ec ff ff       	call   80026b <cprintf>
		return -E_INVAL;
  80165b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801660:	eb 24                	jmp    801686 <read+0x8c>
	}
	if (!dev->dev_read)
  801662:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801665:	8b 52 08             	mov    0x8(%edx),%edx
  801668:	85 d2                	test   %edx,%edx
  80166a:	74 15                	je     801681 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80166c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80166f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801673:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801676:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80167a:	89 04 24             	mov    %eax,(%esp)
  80167d:	ff d2                	call   *%edx
  80167f:	eb 05                	jmp    801686 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801681:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801686:	83 c4 24             	add    $0x24,%esp
  801689:	5b                   	pop    %ebx
  80168a:	5d                   	pop    %ebp
  80168b:	c3                   	ret    

0080168c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	57                   	push   %edi
  801690:	56                   	push   %esi
  801691:	53                   	push   %ebx
  801692:	83 ec 1c             	sub    $0x1c,%esp
  801695:	8b 7d 08             	mov    0x8(%ebp),%edi
  801698:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80169b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016a0:	eb 23                	jmp    8016c5 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016a2:	89 f0                	mov    %esi,%eax
  8016a4:	29 d8                	sub    %ebx,%eax
  8016a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016aa:	89 d8                	mov    %ebx,%eax
  8016ac:	03 45 0c             	add    0xc(%ebp),%eax
  8016af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b3:	89 3c 24             	mov    %edi,(%esp)
  8016b6:	e8 3f ff ff ff       	call   8015fa <read>
		if (m < 0)
  8016bb:	85 c0                	test   %eax,%eax
  8016bd:	78 10                	js     8016cf <readn+0x43>
			return m;
		if (m == 0)
  8016bf:	85 c0                	test   %eax,%eax
  8016c1:	74 0a                	je     8016cd <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016c3:	01 c3                	add    %eax,%ebx
  8016c5:	39 f3                	cmp    %esi,%ebx
  8016c7:	72 d9                	jb     8016a2 <readn+0x16>
  8016c9:	89 d8                	mov    %ebx,%eax
  8016cb:	eb 02                	jmp    8016cf <readn+0x43>
  8016cd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8016cf:	83 c4 1c             	add    $0x1c,%esp
  8016d2:	5b                   	pop    %ebx
  8016d3:	5e                   	pop    %esi
  8016d4:	5f                   	pop    %edi
  8016d5:	5d                   	pop    %ebp
  8016d6:	c3                   	ret    

008016d7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016d7:	55                   	push   %ebp
  8016d8:	89 e5                	mov    %esp,%ebp
  8016da:	53                   	push   %ebx
  8016db:	83 ec 24             	sub    $0x24,%esp
  8016de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e8:	89 1c 24             	mov    %ebx,(%esp)
  8016eb:	e8 76 fc ff ff       	call   801366 <fd_lookup>
  8016f0:	89 c2                	mov    %eax,%edx
  8016f2:	85 d2                	test   %edx,%edx
  8016f4:	78 68                	js     80175e <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801700:	8b 00                	mov    (%eax),%eax
  801702:	89 04 24             	mov    %eax,(%esp)
  801705:	e8 b2 fc ff ff       	call   8013bc <dev_lookup>
  80170a:	85 c0                	test   %eax,%eax
  80170c:	78 50                	js     80175e <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80170e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801711:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801715:	75 23                	jne    80173a <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801717:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80171c:	8b 40 48             	mov    0x48(%eax),%eax
  80171f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801723:	89 44 24 04          	mov    %eax,0x4(%esp)
  801727:	c7 04 24 a1 2e 80 00 	movl   $0x802ea1,(%esp)
  80172e:	e8 38 eb ff ff       	call   80026b <cprintf>
		return -E_INVAL;
  801733:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801738:	eb 24                	jmp    80175e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80173a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80173d:	8b 52 0c             	mov    0xc(%edx),%edx
  801740:	85 d2                	test   %edx,%edx
  801742:	74 15                	je     801759 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801744:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801747:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80174b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80174e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801752:	89 04 24             	mov    %eax,(%esp)
  801755:	ff d2                	call   *%edx
  801757:	eb 05                	jmp    80175e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801759:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80175e:	83 c4 24             	add    $0x24,%esp
  801761:	5b                   	pop    %ebx
  801762:	5d                   	pop    %ebp
  801763:	c3                   	ret    

00801764 <seek>:

int
seek(int fdnum, off_t offset)
{
  801764:	55                   	push   %ebp
  801765:	89 e5                	mov    %esp,%ebp
  801767:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80176a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80176d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801771:	8b 45 08             	mov    0x8(%ebp),%eax
  801774:	89 04 24             	mov    %eax,(%esp)
  801777:	e8 ea fb ff ff       	call   801366 <fd_lookup>
  80177c:	85 c0                	test   %eax,%eax
  80177e:	78 0e                	js     80178e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801780:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801783:	8b 55 0c             	mov    0xc(%ebp),%edx
  801786:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801789:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80178e:	c9                   	leave  
  80178f:	c3                   	ret    

00801790 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	53                   	push   %ebx
  801794:	83 ec 24             	sub    $0x24,%esp
  801797:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80179a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80179d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a1:	89 1c 24             	mov    %ebx,(%esp)
  8017a4:	e8 bd fb ff ff       	call   801366 <fd_lookup>
  8017a9:	89 c2                	mov    %eax,%edx
  8017ab:	85 d2                	test   %edx,%edx
  8017ad:	78 61                	js     801810 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b9:	8b 00                	mov    (%eax),%eax
  8017bb:	89 04 24             	mov    %eax,(%esp)
  8017be:	e8 f9 fb ff ff       	call   8013bc <dev_lookup>
  8017c3:	85 c0                	test   %eax,%eax
  8017c5:	78 49                	js     801810 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ca:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017ce:	75 23                	jne    8017f3 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017d0:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017d5:	8b 40 48             	mov    0x48(%eax),%eax
  8017d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e0:	c7 04 24 64 2e 80 00 	movl   $0x802e64,(%esp)
  8017e7:	e8 7f ea ff ff       	call   80026b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017f1:	eb 1d                	jmp    801810 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8017f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017f6:	8b 52 18             	mov    0x18(%edx),%edx
  8017f9:	85 d2                	test   %edx,%edx
  8017fb:	74 0e                	je     80180b <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801800:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801804:	89 04 24             	mov    %eax,(%esp)
  801807:	ff d2                	call   *%edx
  801809:	eb 05                	jmp    801810 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80180b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801810:	83 c4 24             	add    $0x24,%esp
  801813:	5b                   	pop    %ebx
  801814:	5d                   	pop    %ebp
  801815:	c3                   	ret    

00801816 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801816:	55                   	push   %ebp
  801817:	89 e5                	mov    %esp,%ebp
  801819:	53                   	push   %ebx
  80181a:	83 ec 24             	sub    $0x24,%esp
  80181d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801820:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801823:	89 44 24 04          	mov    %eax,0x4(%esp)
  801827:	8b 45 08             	mov    0x8(%ebp),%eax
  80182a:	89 04 24             	mov    %eax,(%esp)
  80182d:	e8 34 fb ff ff       	call   801366 <fd_lookup>
  801832:	89 c2                	mov    %eax,%edx
  801834:	85 d2                	test   %edx,%edx
  801836:	78 52                	js     80188a <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801838:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80183b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801842:	8b 00                	mov    (%eax),%eax
  801844:	89 04 24             	mov    %eax,(%esp)
  801847:	e8 70 fb ff ff       	call   8013bc <dev_lookup>
  80184c:	85 c0                	test   %eax,%eax
  80184e:	78 3a                	js     80188a <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801850:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801853:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801857:	74 2c                	je     801885 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801859:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80185c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801863:	00 00 00 
	stat->st_isdir = 0;
  801866:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80186d:	00 00 00 
	stat->st_dev = dev;
  801870:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801876:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80187a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80187d:	89 14 24             	mov    %edx,(%esp)
  801880:	ff 50 14             	call   *0x14(%eax)
  801883:	eb 05                	jmp    80188a <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801885:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80188a:	83 c4 24             	add    $0x24,%esp
  80188d:	5b                   	pop    %ebx
  80188e:	5d                   	pop    %ebp
  80188f:	c3                   	ret    

00801890 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	56                   	push   %esi
  801894:	53                   	push   %ebx
  801895:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801898:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80189f:	00 
  8018a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a3:	89 04 24             	mov    %eax,(%esp)
  8018a6:	e8 28 02 00 00       	call   801ad3 <open>
  8018ab:	89 c3                	mov    %eax,%ebx
  8018ad:	85 db                	test   %ebx,%ebx
  8018af:	78 1b                	js     8018cc <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8018b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b8:	89 1c 24             	mov    %ebx,(%esp)
  8018bb:	e8 56 ff ff ff       	call   801816 <fstat>
  8018c0:	89 c6                	mov    %eax,%esi
	close(fd);
  8018c2:	89 1c 24             	mov    %ebx,(%esp)
  8018c5:	e8 cd fb ff ff       	call   801497 <close>
	return r;
  8018ca:	89 f0                	mov    %esi,%eax
}
  8018cc:	83 c4 10             	add    $0x10,%esp
  8018cf:	5b                   	pop    %ebx
  8018d0:	5e                   	pop    %esi
  8018d1:	5d                   	pop    %ebp
  8018d2:	c3                   	ret    

008018d3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018d3:	55                   	push   %ebp
  8018d4:	89 e5                	mov    %esp,%ebp
  8018d6:	56                   	push   %esi
  8018d7:	53                   	push   %ebx
  8018d8:	83 ec 10             	sub    $0x10,%esp
  8018db:	89 c6                	mov    %eax,%esi
  8018dd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018df:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018e6:	75 11                	jne    8018f9 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018e8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8018ef:	e8 11 0e 00 00       	call   802705 <ipc_find_env>
  8018f4:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018f9:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801900:	00 
  801901:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801908:	00 
  801909:	89 74 24 04          	mov    %esi,0x4(%esp)
  80190d:	a1 00 40 80 00       	mov    0x804000,%eax
  801912:	89 04 24             	mov    %eax,(%esp)
  801915:	e8 80 0d 00 00       	call   80269a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80191a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801921:	00 
  801922:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801926:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80192d:	e8 ee 0c 00 00       	call   802620 <ipc_recv>
}
  801932:	83 c4 10             	add    $0x10,%esp
  801935:	5b                   	pop    %ebx
  801936:	5e                   	pop    %esi
  801937:	5d                   	pop    %ebp
  801938:	c3                   	ret    

00801939 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801939:	55                   	push   %ebp
  80193a:	89 e5                	mov    %esp,%ebp
  80193c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80193f:	8b 45 08             	mov    0x8(%ebp),%eax
  801942:	8b 40 0c             	mov    0xc(%eax),%eax
  801945:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80194a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80194d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801952:	ba 00 00 00 00       	mov    $0x0,%edx
  801957:	b8 02 00 00 00       	mov    $0x2,%eax
  80195c:	e8 72 ff ff ff       	call   8018d3 <fsipc>
}
  801961:	c9                   	leave  
  801962:	c3                   	ret    

00801963 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801963:	55                   	push   %ebp
  801964:	89 e5                	mov    %esp,%ebp
  801966:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801969:	8b 45 08             	mov    0x8(%ebp),%eax
  80196c:	8b 40 0c             	mov    0xc(%eax),%eax
  80196f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801974:	ba 00 00 00 00       	mov    $0x0,%edx
  801979:	b8 06 00 00 00       	mov    $0x6,%eax
  80197e:	e8 50 ff ff ff       	call   8018d3 <fsipc>
}
  801983:	c9                   	leave  
  801984:	c3                   	ret    

00801985 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801985:	55                   	push   %ebp
  801986:	89 e5                	mov    %esp,%ebp
  801988:	53                   	push   %ebx
  801989:	83 ec 14             	sub    $0x14,%esp
  80198c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80198f:	8b 45 08             	mov    0x8(%ebp),%eax
  801992:	8b 40 0c             	mov    0xc(%eax),%eax
  801995:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80199a:	ba 00 00 00 00       	mov    $0x0,%edx
  80199f:	b8 05 00 00 00       	mov    $0x5,%eax
  8019a4:	e8 2a ff ff ff       	call   8018d3 <fsipc>
  8019a9:	89 c2                	mov    %eax,%edx
  8019ab:	85 d2                	test   %edx,%edx
  8019ad:	78 2b                	js     8019da <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019af:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8019b6:	00 
  8019b7:	89 1c 24             	mov    %ebx,(%esp)
  8019ba:	e8 d8 ee ff ff       	call   800897 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019bf:	a1 80 50 80 00       	mov    0x805080,%eax
  8019c4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019ca:	a1 84 50 80 00       	mov    0x805084,%eax
  8019cf:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019da:	83 c4 14             	add    $0x14,%esp
  8019dd:	5b                   	pop    %ebx
  8019de:	5d                   	pop    %ebp
  8019df:	c3                   	ret    

008019e0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
  8019e3:	83 ec 18             	sub    $0x18,%esp
  8019e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8019e9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019ee:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8019f3:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8019f9:	8b 52 0c             	mov    0xc(%edx),%edx
  8019fc:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801a02:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801a07:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a12:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801a19:	e8 16 f0 ff ff       	call   800a34 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  801a1e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a23:	b8 04 00 00 00       	mov    $0x4,%eax
  801a28:	e8 a6 fe ff ff       	call   8018d3 <fsipc>
}
  801a2d:	c9                   	leave  
  801a2e:	c3                   	ret    

00801a2f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	56                   	push   %esi
  801a33:	53                   	push   %ebx
  801a34:	83 ec 10             	sub    $0x10,%esp
  801a37:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a40:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a45:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a4b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a50:	b8 03 00 00 00       	mov    $0x3,%eax
  801a55:	e8 79 fe ff ff       	call   8018d3 <fsipc>
  801a5a:	89 c3                	mov    %eax,%ebx
  801a5c:	85 c0                	test   %eax,%eax
  801a5e:	78 6a                	js     801aca <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801a60:	39 c6                	cmp    %eax,%esi
  801a62:	73 24                	jae    801a88 <devfile_read+0x59>
  801a64:	c7 44 24 0c d4 2e 80 	movl   $0x802ed4,0xc(%esp)
  801a6b:	00 
  801a6c:	c7 44 24 08 db 2e 80 	movl   $0x802edb,0x8(%esp)
  801a73:	00 
  801a74:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801a7b:	00 
  801a7c:	c7 04 24 f0 2e 80 00 	movl   $0x802ef0,(%esp)
  801a83:	e8 ea e6 ff ff       	call   800172 <_panic>
	assert(r <= PGSIZE);
  801a88:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a8d:	7e 24                	jle    801ab3 <devfile_read+0x84>
  801a8f:	c7 44 24 0c fb 2e 80 	movl   $0x802efb,0xc(%esp)
  801a96:	00 
  801a97:	c7 44 24 08 db 2e 80 	movl   $0x802edb,0x8(%esp)
  801a9e:	00 
  801a9f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801aa6:	00 
  801aa7:	c7 04 24 f0 2e 80 00 	movl   $0x802ef0,(%esp)
  801aae:	e8 bf e6 ff ff       	call   800172 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ab3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ab7:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801abe:	00 
  801abf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac2:	89 04 24             	mov    %eax,(%esp)
  801ac5:	e8 6a ef ff ff       	call   800a34 <memmove>
	return r;
}
  801aca:	89 d8                	mov    %ebx,%eax
  801acc:	83 c4 10             	add    $0x10,%esp
  801acf:	5b                   	pop    %ebx
  801ad0:	5e                   	pop    %esi
  801ad1:	5d                   	pop    %ebp
  801ad2:	c3                   	ret    

00801ad3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	53                   	push   %ebx
  801ad7:	83 ec 24             	sub    $0x24,%esp
  801ada:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801add:	89 1c 24             	mov    %ebx,(%esp)
  801ae0:	e8 7b ed ff ff       	call   800860 <strlen>
  801ae5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801aea:	7f 60                	jg     801b4c <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801aec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aef:	89 04 24             	mov    %eax,(%esp)
  801af2:	e8 20 f8 ff ff       	call   801317 <fd_alloc>
  801af7:	89 c2                	mov    %eax,%edx
  801af9:	85 d2                	test   %edx,%edx
  801afb:	78 54                	js     801b51 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801afd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b01:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801b08:	e8 8a ed ff ff       	call   800897 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b10:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b15:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b18:	b8 01 00 00 00       	mov    $0x1,%eax
  801b1d:	e8 b1 fd ff ff       	call   8018d3 <fsipc>
  801b22:	89 c3                	mov    %eax,%ebx
  801b24:	85 c0                	test   %eax,%eax
  801b26:	79 17                	jns    801b3f <open+0x6c>
		fd_close(fd, 0);
  801b28:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b2f:	00 
  801b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b33:	89 04 24             	mov    %eax,(%esp)
  801b36:	e8 db f8 ff ff       	call   801416 <fd_close>
		return r;
  801b3b:	89 d8                	mov    %ebx,%eax
  801b3d:	eb 12                	jmp    801b51 <open+0x7e>
	}

	return fd2num(fd);
  801b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b42:	89 04 24             	mov    %eax,(%esp)
  801b45:	e8 a6 f7 ff ff       	call   8012f0 <fd2num>
  801b4a:	eb 05                	jmp    801b51 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b4c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b51:	83 c4 24             	add    $0x24,%esp
  801b54:	5b                   	pop    %ebx
  801b55:	5d                   	pop    %ebp
  801b56:	c3                   	ret    

00801b57 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b57:	55                   	push   %ebp
  801b58:	89 e5                	mov    %esp,%ebp
  801b5a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b5d:	ba 00 00 00 00       	mov    $0x0,%edx
  801b62:	b8 08 00 00 00       	mov    $0x8,%eax
  801b67:	e8 67 fd ff ff       	call   8018d3 <fsipc>
}
  801b6c:	c9                   	leave  
  801b6d:	c3                   	ret    
  801b6e:	66 90                	xchg   %ax,%ax

00801b70 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b70:	55                   	push   %ebp
  801b71:	89 e5                	mov    %esp,%ebp
  801b73:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801b76:	c7 44 24 04 07 2f 80 	movl   $0x802f07,0x4(%esp)
  801b7d:	00 
  801b7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b81:	89 04 24             	mov    %eax,(%esp)
  801b84:	e8 0e ed ff ff       	call   800897 <strcpy>
	return 0;
}
  801b89:	b8 00 00 00 00       	mov    $0x0,%eax
  801b8e:	c9                   	leave  
  801b8f:	c3                   	ret    

00801b90 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	53                   	push   %ebx
  801b94:	83 ec 14             	sub    $0x14,%esp
  801b97:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b9a:	89 1c 24             	mov    %ebx,(%esp)
  801b9d:	e8 9b 0b 00 00       	call   80273d <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801ba2:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801ba7:	83 f8 01             	cmp    $0x1,%eax
  801baa:	75 0d                	jne    801bb9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801bac:	8b 43 0c             	mov    0xc(%ebx),%eax
  801baf:	89 04 24             	mov    %eax,(%esp)
  801bb2:	e8 29 03 00 00       	call   801ee0 <nsipc_close>
  801bb7:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  801bb9:	89 d0                	mov    %edx,%eax
  801bbb:	83 c4 14             	add    $0x14,%esp
  801bbe:	5b                   	pop    %ebx
  801bbf:	5d                   	pop    %ebp
  801bc0:	c3                   	ret    

00801bc1 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801bc1:	55                   	push   %ebp
  801bc2:	89 e5                	mov    %esp,%ebp
  801bc4:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801bc7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801bce:	00 
  801bcf:	8b 45 10             	mov    0x10(%ebp),%eax
  801bd2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bdd:	8b 45 08             	mov    0x8(%ebp),%eax
  801be0:	8b 40 0c             	mov    0xc(%eax),%eax
  801be3:	89 04 24             	mov    %eax,(%esp)
  801be6:	e8 f0 03 00 00       	call   801fdb <nsipc_send>
}
  801beb:	c9                   	leave  
  801bec:	c3                   	ret    

00801bed <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801bed:	55                   	push   %ebp
  801bee:	89 e5                	mov    %esp,%ebp
  801bf0:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801bf3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801bfa:	00 
  801bfb:	8b 45 10             	mov    0x10(%ebp),%eax
  801bfe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c02:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c09:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0c:	8b 40 0c             	mov    0xc(%eax),%eax
  801c0f:	89 04 24             	mov    %eax,(%esp)
  801c12:	e8 44 03 00 00       	call   801f5b <nsipc_recv>
}
  801c17:	c9                   	leave  
  801c18:	c3                   	ret    

00801c19 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c19:	55                   	push   %ebp
  801c1a:	89 e5                	mov    %esp,%ebp
  801c1c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c1f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c22:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c26:	89 04 24             	mov    %eax,(%esp)
  801c29:	e8 38 f7 ff ff       	call   801366 <fd_lookup>
  801c2e:	85 c0                	test   %eax,%eax
  801c30:	78 17                	js     801c49 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c35:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801c3b:	39 08                	cmp    %ecx,(%eax)
  801c3d:	75 05                	jne    801c44 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801c3f:	8b 40 0c             	mov    0xc(%eax),%eax
  801c42:	eb 05                	jmp    801c49 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801c44:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801c49:	c9                   	leave  
  801c4a:	c3                   	ret    

00801c4b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801c4b:	55                   	push   %ebp
  801c4c:	89 e5                	mov    %esp,%ebp
  801c4e:	56                   	push   %esi
  801c4f:	53                   	push   %ebx
  801c50:	83 ec 20             	sub    $0x20,%esp
  801c53:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801c55:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c58:	89 04 24             	mov    %eax,(%esp)
  801c5b:	e8 b7 f6 ff ff       	call   801317 <fd_alloc>
  801c60:	89 c3                	mov    %eax,%ebx
  801c62:	85 c0                	test   %eax,%eax
  801c64:	78 21                	js     801c87 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801c66:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c6d:	00 
  801c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c71:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c75:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c7c:	e8 32 f0 ff ff       	call   800cb3 <sys_page_alloc>
  801c81:	89 c3                	mov    %eax,%ebx
  801c83:	85 c0                	test   %eax,%eax
  801c85:	79 0c                	jns    801c93 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  801c87:	89 34 24             	mov    %esi,(%esp)
  801c8a:	e8 51 02 00 00       	call   801ee0 <nsipc_close>
		return r;
  801c8f:	89 d8                	mov    %ebx,%eax
  801c91:	eb 20                	jmp    801cb3 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801c93:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801c9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ca1:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801ca8:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801cab:	89 14 24             	mov    %edx,(%esp)
  801cae:	e8 3d f6 ff ff       	call   8012f0 <fd2num>
}
  801cb3:	83 c4 20             	add    $0x20,%esp
  801cb6:	5b                   	pop    %ebx
  801cb7:	5e                   	pop    %esi
  801cb8:	5d                   	pop    %ebp
  801cb9:	c3                   	ret    

00801cba <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cba:	55                   	push   %ebp
  801cbb:	89 e5                	mov    %esp,%ebp
  801cbd:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cc0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc3:	e8 51 ff ff ff       	call   801c19 <fd2sockid>
		return r;
  801cc8:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cca:	85 c0                	test   %eax,%eax
  801ccc:	78 23                	js     801cf1 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801cce:	8b 55 10             	mov    0x10(%ebp),%edx
  801cd1:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cd5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cd8:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cdc:	89 04 24             	mov    %eax,(%esp)
  801cdf:	e8 45 01 00 00       	call   801e29 <nsipc_accept>
		return r;
  801ce4:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ce6:	85 c0                	test   %eax,%eax
  801ce8:	78 07                	js     801cf1 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  801cea:	e8 5c ff ff ff       	call   801c4b <alloc_sockfd>
  801cef:	89 c1                	mov    %eax,%ecx
}
  801cf1:	89 c8                	mov    %ecx,%eax
  801cf3:	c9                   	leave  
  801cf4:	c3                   	ret    

00801cf5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cf5:	55                   	push   %ebp
  801cf6:	89 e5                	mov    %esp,%ebp
  801cf8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfe:	e8 16 ff ff ff       	call   801c19 <fd2sockid>
  801d03:	89 c2                	mov    %eax,%edx
  801d05:	85 d2                	test   %edx,%edx
  801d07:	78 16                	js     801d1f <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  801d09:	8b 45 10             	mov    0x10(%ebp),%eax
  801d0c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d10:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d13:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d17:	89 14 24             	mov    %edx,(%esp)
  801d1a:	e8 60 01 00 00       	call   801e7f <nsipc_bind>
}
  801d1f:	c9                   	leave  
  801d20:	c3                   	ret    

00801d21 <shutdown>:

int
shutdown(int s, int how)
{
  801d21:	55                   	push   %ebp
  801d22:	89 e5                	mov    %esp,%ebp
  801d24:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d27:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2a:	e8 ea fe ff ff       	call   801c19 <fd2sockid>
  801d2f:	89 c2                	mov    %eax,%edx
  801d31:	85 d2                	test   %edx,%edx
  801d33:	78 0f                	js     801d44 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801d35:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d38:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d3c:	89 14 24             	mov    %edx,(%esp)
  801d3f:	e8 7a 01 00 00       	call   801ebe <nsipc_shutdown>
}
  801d44:	c9                   	leave  
  801d45:	c3                   	ret    

00801d46 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d46:	55                   	push   %ebp
  801d47:	89 e5                	mov    %esp,%ebp
  801d49:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4f:	e8 c5 fe ff ff       	call   801c19 <fd2sockid>
  801d54:	89 c2                	mov    %eax,%edx
  801d56:	85 d2                	test   %edx,%edx
  801d58:	78 16                	js     801d70 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  801d5a:	8b 45 10             	mov    0x10(%ebp),%eax
  801d5d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d61:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d64:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d68:	89 14 24             	mov    %edx,(%esp)
  801d6b:	e8 8a 01 00 00       	call   801efa <nsipc_connect>
}
  801d70:	c9                   	leave  
  801d71:	c3                   	ret    

00801d72 <listen>:

int
listen(int s, int backlog)
{
  801d72:	55                   	push   %ebp
  801d73:	89 e5                	mov    %esp,%ebp
  801d75:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d78:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7b:	e8 99 fe ff ff       	call   801c19 <fd2sockid>
  801d80:	89 c2                	mov    %eax,%edx
  801d82:	85 d2                	test   %edx,%edx
  801d84:	78 0f                	js     801d95 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801d86:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d89:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d8d:	89 14 24             	mov    %edx,(%esp)
  801d90:	e8 a4 01 00 00       	call   801f39 <nsipc_listen>
}
  801d95:	c9                   	leave  
  801d96:	c3                   	ret    

00801d97 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801d97:	55                   	push   %ebp
  801d98:	89 e5                	mov    %esp,%ebp
  801d9a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d9d:	8b 45 10             	mov    0x10(%ebp),%eax
  801da0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801da4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801da7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dab:	8b 45 08             	mov    0x8(%ebp),%eax
  801dae:	89 04 24             	mov    %eax,(%esp)
  801db1:	e8 98 02 00 00       	call   80204e <nsipc_socket>
  801db6:	89 c2                	mov    %eax,%edx
  801db8:	85 d2                	test   %edx,%edx
  801dba:	78 05                	js     801dc1 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  801dbc:	e8 8a fe ff ff       	call   801c4b <alloc_sockfd>
}
  801dc1:	c9                   	leave  
  801dc2:	c3                   	ret    

00801dc3 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801dc3:	55                   	push   %ebp
  801dc4:	89 e5                	mov    %esp,%ebp
  801dc6:	53                   	push   %ebx
  801dc7:	83 ec 14             	sub    $0x14,%esp
  801dca:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801dcc:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801dd3:	75 11                	jne    801de6 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801dd5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801ddc:	e8 24 09 00 00       	call   802705 <ipc_find_env>
  801de1:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801de6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801ded:	00 
  801dee:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801df5:	00 
  801df6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dfa:	a1 04 40 80 00       	mov    0x804004,%eax
  801dff:	89 04 24             	mov    %eax,(%esp)
  801e02:	e8 93 08 00 00       	call   80269a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801e07:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e0e:	00 
  801e0f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e16:	00 
  801e17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e1e:	e8 fd 07 00 00       	call   802620 <ipc_recv>
}
  801e23:	83 c4 14             	add    $0x14,%esp
  801e26:	5b                   	pop    %ebx
  801e27:	5d                   	pop    %ebp
  801e28:	c3                   	ret    

00801e29 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e29:	55                   	push   %ebp
  801e2a:	89 e5                	mov    %esp,%ebp
  801e2c:	56                   	push   %esi
  801e2d:	53                   	push   %ebx
  801e2e:	83 ec 10             	sub    $0x10,%esp
  801e31:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801e34:	8b 45 08             	mov    0x8(%ebp),%eax
  801e37:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801e3c:	8b 06                	mov    (%esi),%eax
  801e3e:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e43:	b8 01 00 00 00       	mov    $0x1,%eax
  801e48:	e8 76 ff ff ff       	call   801dc3 <nsipc>
  801e4d:	89 c3                	mov    %eax,%ebx
  801e4f:	85 c0                	test   %eax,%eax
  801e51:	78 23                	js     801e76 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e53:	a1 10 60 80 00       	mov    0x806010,%eax
  801e58:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e5c:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e63:	00 
  801e64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e67:	89 04 24             	mov    %eax,(%esp)
  801e6a:	e8 c5 eb ff ff       	call   800a34 <memmove>
		*addrlen = ret->ret_addrlen;
  801e6f:	a1 10 60 80 00       	mov    0x806010,%eax
  801e74:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801e76:	89 d8                	mov    %ebx,%eax
  801e78:	83 c4 10             	add    $0x10,%esp
  801e7b:	5b                   	pop    %ebx
  801e7c:	5e                   	pop    %esi
  801e7d:	5d                   	pop    %ebp
  801e7e:	c3                   	ret    

00801e7f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e7f:	55                   	push   %ebp
  801e80:	89 e5                	mov    %esp,%ebp
  801e82:	53                   	push   %ebx
  801e83:	83 ec 14             	sub    $0x14,%esp
  801e86:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e89:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801e91:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e98:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e9c:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801ea3:	e8 8c eb ff ff       	call   800a34 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801ea8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801eae:	b8 02 00 00 00       	mov    $0x2,%eax
  801eb3:	e8 0b ff ff ff       	call   801dc3 <nsipc>
}
  801eb8:	83 c4 14             	add    $0x14,%esp
  801ebb:	5b                   	pop    %ebx
  801ebc:	5d                   	pop    %ebp
  801ebd:	c3                   	ret    

00801ebe <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801ebe:	55                   	push   %ebp
  801ebf:	89 e5                	mov    %esp,%ebp
  801ec1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ec4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801ecc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ecf:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801ed4:	b8 03 00 00 00       	mov    $0x3,%eax
  801ed9:	e8 e5 fe ff ff       	call   801dc3 <nsipc>
}
  801ede:	c9                   	leave  
  801edf:	c3                   	ret    

00801ee0 <nsipc_close>:

int
nsipc_close(int s)
{
  801ee0:	55                   	push   %ebp
  801ee1:	89 e5                	mov    %esp,%ebp
  801ee3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ee6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee9:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801eee:	b8 04 00 00 00       	mov    $0x4,%eax
  801ef3:	e8 cb fe ff ff       	call   801dc3 <nsipc>
}
  801ef8:	c9                   	leave  
  801ef9:	c3                   	ret    

00801efa <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801efa:	55                   	push   %ebp
  801efb:	89 e5                	mov    %esp,%ebp
  801efd:	53                   	push   %ebx
  801efe:	83 ec 14             	sub    $0x14,%esp
  801f01:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801f04:	8b 45 08             	mov    0x8(%ebp),%eax
  801f07:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801f0c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f10:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f13:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f17:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801f1e:	e8 11 eb ff ff       	call   800a34 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801f23:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801f29:	b8 05 00 00 00       	mov    $0x5,%eax
  801f2e:	e8 90 fe ff ff       	call   801dc3 <nsipc>
}
  801f33:	83 c4 14             	add    $0x14,%esp
  801f36:	5b                   	pop    %ebx
  801f37:	5d                   	pop    %ebp
  801f38:	c3                   	ret    

00801f39 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801f39:	55                   	push   %ebp
  801f3a:	89 e5                	mov    %esp,%ebp
  801f3c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801f3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f42:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801f47:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f4a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801f4f:	b8 06 00 00 00       	mov    $0x6,%eax
  801f54:	e8 6a fe ff ff       	call   801dc3 <nsipc>
}
  801f59:	c9                   	leave  
  801f5a:	c3                   	ret    

00801f5b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801f5b:	55                   	push   %ebp
  801f5c:	89 e5                	mov    %esp,%ebp
  801f5e:	56                   	push   %esi
  801f5f:	53                   	push   %ebx
  801f60:	83 ec 10             	sub    $0x10,%esp
  801f63:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801f66:	8b 45 08             	mov    0x8(%ebp),%eax
  801f69:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801f6e:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801f74:	8b 45 14             	mov    0x14(%ebp),%eax
  801f77:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801f7c:	b8 07 00 00 00       	mov    $0x7,%eax
  801f81:	e8 3d fe ff ff       	call   801dc3 <nsipc>
  801f86:	89 c3                	mov    %eax,%ebx
  801f88:	85 c0                	test   %eax,%eax
  801f8a:	78 46                	js     801fd2 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801f8c:	39 f0                	cmp    %esi,%eax
  801f8e:	7f 07                	jg     801f97 <nsipc_recv+0x3c>
  801f90:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801f95:	7e 24                	jle    801fbb <nsipc_recv+0x60>
  801f97:	c7 44 24 0c 13 2f 80 	movl   $0x802f13,0xc(%esp)
  801f9e:	00 
  801f9f:	c7 44 24 08 db 2e 80 	movl   $0x802edb,0x8(%esp)
  801fa6:	00 
  801fa7:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801fae:	00 
  801faf:	c7 04 24 28 2f 80 00 	movl   $0x802f28,(%esp)
  801fb6:	e8 b7 e1 ff ff       	call   800172 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801fbb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fbf:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801fc6:	00 
  801fc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fca:	89 04 24             	mov    %eax,(%esp)
  801fcd:	e8 62 ea ff ff       	call   800a34 <memmove>
	}

	return r;
}
  801fd2:	89 d8                	mov    %ebx,%eax
  801fd4:	83 c4 10             	add    $0x10,%esp
  801fd7:	5b                   	pop    %ebx
  801fd8:	5e                   	pop    %esi
  801fd9:	5d                   	pop    %ebp
  801fda:	c3                   	ret    

00801fdb <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801fdb:	55                   	push   %ebp
  801fdc:	89 e5                	mov    %esp,%ebp
  801fde:	53                   	push   %ebx
  801fdf:	83 ec 14             	sub    $0x14,%esp
  801fe2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801fe5:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe8:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801fed:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801ff3:	7e 24                	jle    802019 <nsipc_send+0x3e>
  801ff5:	c7 44 24 0c 34 2f 80 	movl   $0x802f34,0xc(%esp)
  801ffc:	00 
  801ffd:	c7 44 24 08 db 2e 80 	movl   $0x802edb,0x8(%esp)
  802004:	00 
  802005:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  80200c:	00 
  80200d:	c7 04 24 28 2f 80 00 	movl   $0x802f28,(%esp)
  802014:	e8 59 e1 ff ff       	call   800172 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802019:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80201d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802020:	89 44 24 04          	mov    %eax,0x4(%esp)
  802024:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  80202b:	e8 04 ea ff ff       	call   800a34 <memmove>
	nsipcbuf.send.req_size = size;
  802030:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  802036:	8b 45 14             	mov    0x14(%ebp),%eax
  802039:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  80203e:	b8 08 00 00 00       	mov    $0x8,%eax
  802043:	e8 7b fd ff ff       	call   801dc3 <nsipc>
}
  802048:	83 c4 14             	add    $0x14,%esp
  80204b:	5b                   	pop    %ebx
  80204c:	5d                   	pop    %ebp
  80204d:	c3                   	ret    

0080204e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80204e:	55                   	push   %ebp
  80204f:	89 e5                	mov    %esp,%ebp
  802051:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802054:	8b 45 08             	mov    0x8(%ebp),%eax
  802057:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80205c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80205f:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802064:	8b 45 10             	mov    0x10(%ebp),%eax
  802067:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80206c:	b8 09 00 00 00       	mov    $0x9,%eax
  802071:	e8 4d fd ff ff       	call   801dc3 <nsipc>
}
  802076:	c9                   	leave  
  802077:	c3                   	ret    

00802078 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802078:	55                   	push   %ebp
  802079:	89 e5                	mov    %esp,%ebp
  80207b:	56                   	push   %esi
  80207c:	53                   	push   %ebx
  80207d:	83 ec 10             	sub    $0x10,%esp
  802080:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802083:	8b 45 08             	mov    0x8(%ebp),%eax
  802086:	89 04 24             	mov    %eax,(%esp)
  802089:	e8 72 f2 ff ff       	call   801300 <fd2data>
  80208e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802090:	c7 44 24 04 40 2f 80 	movl   $0x802f40,0x4(%esp)
  802097:	00 
  802098:	89 1c 24             	mov    %ebx,(%esp)
  80209b:	e8 f7 e7 ff ff       	call   800897 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8020a0:	8b 46 04             	mov    0x4(%esi),%eax
  8020a3:	2b 06                	sub    (%esi),%eax
  8020a5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8020ab:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8020b2:	00 00 00 
	stat->st_dev = &devpipe;
  8020b5:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8020bc:	30 80 00 
	return 0;
}
  8020bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8020c4:	83 c4 10             	add    $0x10,%esp
  8020c7:	5b                   	pop    %ebx
  8020c8:	5e                   	pop    %esi
  8020c9:	5d                   	pop    %ebp
  8020ca:	c3                   	ret    

008020cb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8020cb:	55                   	push   %ebp
  8020cc:	89 e5                	mov    %esp,%ebp
  8020ce:	53                   	push   %ebx
  8020cf:	83 ec 14             	sub    $0x14,%esp
  8020d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8020d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020e0:	e8 75 ec ff ff       	call   800d5a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8020e5:	89 1c 24             	mov    %ebx,(%esp)
  8020e8:	e8 13 f2 ff ff       	call   801300 <fd2data>
  8020ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020f8:	e8 5d ec ff ff       	call   800d5a <sys_page_unmap>
}
  8020fd:	83 c4 14             	add    $0x14,%esp
  802100:	5b                   	pop    %ebx
  802101:	5d                   	pop    %ebp
  802102:	c3                   	ret    

00802103 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802103:	55                   	push   %ebp
  802104:	89 e5                	mov    %esp,%ebp
  802106:	57                   	push   %edi
  802107:	56                   	push   %esi
  802108:	53                   	push   %ebx
  802109:	83 ec 2c             	sub    $0x2c,%esp
  80210c:	89 c6                	mov    %eax,%esi
  80210e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802111:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802116:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802119:	89 34 24             	mov    %esi,(%esp)
  80211c:	e8 1c 06 00 00       	call   80273d <pageref>
  802121:	89 c7                	mov    %eax,%edi
  802123:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802126:	89 04 24             	mov    %eax,(%esp)
  802129:	e8 0f 06 00 00       	call   80273d <pageref>
  80212e:	39 c7                	cmp    %eax,%edi
  802130:	0f 94 c2             	sete   %dl
  802133:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  802136:	8b 0d 0c 40 80 00    	mov    0x80400c,%ecx
  80213c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  80213f:	39 fb                	cmp    %edi,%ebx
  802141:	74 21                	je     802164 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802143:	84 d2                	test   %dl,%dl
  802145:	74 ca                	je     802111 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802147:	8b 51 58             	mov    0x58(%ecx),%edx
  80214a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80214e:	89 54 24 08          	mov    %edx,0x8(%esp)
  802152:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802156:	c7 04 24 47 2f 80 00 	movl   $0x802f47,(%esp)
  80215d:	e8 09 e1 ff ff       	call   80026b <cprintf>
  802162:	eb ad                	jmp    802111 <_pipeisclosed+0xe>
	}
}
  802164:	83 c4 2c             	add    $0x2c,%esp
  802167:	5b                   	pop    %ebx
  802168:	5e                   	pop    %esi
  802169:	5f                   	pop    %edi
  80216a:	5d                   	pop    %ebp
  80216b:	c3                   	ret    

0080216c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80216c:	55                   	push   %ebp
  80216d:	89 e5                	mov    %esp,%ebp
  80216f:	57                   	push   %edi
  802170:	56                   	push   %esi
  802171:	53                   	push   %ebx
  802172:	83 ec 1c             	sub    $0x1c,%esp
  802175:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802178:	89 34 24             	mov    %esi,(%esp)
  80217b:	e8 80 f1 ff ff       	call   801300 <fd2data>
  802180:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802182:	bf 00 00 00 00       	mov    $0x0,%edi
  802187:	eb 45                	jmp    8021ce <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802189:	89 da                	mov    %ebx,%edx
  80218b:	89 f0                	mov    %esi,%eax
  80218d:	e8 71 ff ff ff       	call   802103 <_pipeisclosed>
  802192:	85 c0                	test   %eax,%eax
  802194:	75 41                	jne    8021d7 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802196:	e8 f9 ea ff ff       	call   800c94 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80219b:	8b 43 04             	mov    0x4(%ebx),%eax
  80219e:	8b 0b                	mov    (%ebx),%ecx
  8021a0:	8d 51 20             	lea    0x20(%ecx),%edx
  8021a3:	39 d0                	cmp    %edx,%eax
  8021a5:	73 e2                	jae    802189 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8021a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021aa:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8021ae:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8021b1:	99                   	cltd   
  8021b2:	c1 ea 1b             	shr    $0x1b,%edx
  8021b5:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8021b8:	83 e1 1f             	and    $0x1f,%ecx
  8021bb:	29 d1                	sub    %edx,%ecx
  8021bd:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8021c1:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8021c5:	83 c0 01             	add    $0x1,%eax
  8021c8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021cb:	83 c7 01             	add    $0x1,%edi
  8021ce:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8021d1:	75 c8                	jne    80219b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8021d3:	89 f8                	mov    %edi,%eax
  8021d5:	eb 05                	jmp    8021dc <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021d7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8021dc:	83 c4 1c             	add    $0x1c,%esp
  8021df:	5b                   	pop    %ebx
  8021e0:	5e                   	pop    %esi
  8021e1:	5f                   	pop    %edi
  8021e2:	5d                   	pop    %ebp
  8021e3:	c3                   	ret    

008021e4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021e4:	55                   	push   %ebp
  8021e5:	89 e5                	mov    %esp,%ebp
  8021e7:	57                   	push   %edi
  8021e8:	56                   	push   %esi
  8021e9:	53                   	push   %ebx
  8021ea:	83 ec 1c             	sub    $0x1c,%esp
  8021ed:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8021f0:	89 3c 24             	mov    %edi,(%esp)
  8021f3:	e8 08 f1 ff ff       	call   801300 <fd2data>
  8021f8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021fa:	be 00 00 00 00       	mov    $0x0,%esi
  8021ff:	eb 3d                	jmp    80223e <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802201:	85 f6                	test   %esi,%esi
  802203:	74 04                	je     802209 <devpipe_read+0x25>
				return i;
  802205:	89 f0                	mov    %esi,%eax
  802207:	eb 43                	jmp    80224c <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802209:	89 da                	mov    %ebx,%edx
  80220b:	89 f8                	mov    %edi,%eax
  80220d:	e8 f1 fe ff ff       	call   802103 <_pipeisclosed>
  802212:	85 c0                	test   %eax,%eax
  802214:	75 31                	jne    802247 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802216:	e8 79 ea ff ff       	call   800c94 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80221b:	8b 03                	mov    (%ebx),%eax
  80221d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802220:	74 df                	je     802201 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802222:	99                   	cltd   
  802223:	c1 ea 1b             	shr    $0x1b,%edx
  802226:	01 d0                	add    %edx,%eax
  802228:	83 e0 1f             	and    $0x1f,%eax
  80222b:	29 d0                	sub    %edx,%eax
  80222d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802232:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802235:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802238:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80223b:	83 c6 01             	add    $0x1,%esi
  80223e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802241:	75 d8                	jne    80221b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802243:	89 f0                	mov    %esi,%eax
  802245:	eb 05                	jmp    80224c <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802247:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80224c:	83 c4 1c             	add    $0x1c,%esp
  80224f:	5b                   	pop    %ebx
  802250:	5e                   	pop    %esi
  802251:	5f                   	pop    %edi
  802252:	5d                   	pop    %ebp
  802253:	c3                   	ret    

00802254 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802254:	55                   	push   %ebp
  802255:	89 e5                	mov    %esp,%ebp
  802257:	56                   	push   %esi
  802258:	53                   	push   %ebx
  802259:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80225c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80225f:	89 04 24             	mov    %eax,(%esp)
  802262:	e8 b0 f0 ff ff       	call   801317 <fd_alloc>
  802267:	89 c2                	mov    %eax,%edx
  802269:	85 d2                	test   %edx,%edx
  80226b:	0f 88 4d 01 00 00    	js     8023be <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802271:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802278:	00 
  802279:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80227c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802280:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802287:	e8 27 ea ff ff       	call   800cb3 <sys_page_alloc>
  80228c:	89 c2                	mov    %eax,%edx
  80228e:	85 d2                	test   %edx,%edx
  802290:	0f 88 28 01 00 00    	js     8023be <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802296:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802299:	89 04 24             	mov    %eax,(%esp)
  80229c:	e8 76 f0 ff ff       	call   801317 <fd_alloc>
  8022a1:	89 c3                	mov    %eax,%ebx
  8022a3:	85 c0                	test   %eax,%eax
  8022a5:	0f 88 fe 00 00 00    	js     8023a9 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022ab:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022b2:	00 
  8022b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022c1:	e8 ed e9 ff ff       	call   800cb3 <sys_page_alloc>
  8022c6:	89 c3                	mov    %eax,%ebx
  8022c8:	85 c0                	test   %eax,%eax
  8022ca:	0f 88 d9 00 00 00    	js     8023a9 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8022d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022d3:	89 04 24             	mov    %eax,(%esp)
  8022d6:	e8 25 f0 ff ff       	call   801300 <fd2data>
  8022db:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022dd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022e4:	00 
  8022e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022f0:	e8 be e9 ff ff       	call   800cb3 <sys_page_alloc>
  8022f5:	89 c3                	mov    %eax,%ebx
  8022f7:	85 c0                	test   %eax,%eax
  8022f9:	0f 88 97 00 00 00    	js     802396 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802302:	89 04 24             	mov    %eax,(%esp)
  802305:	e8 f6 ef ff ff       	call   801300 <fd2data>
  80230a:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802311:	00 
  802312:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802316:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80231d:	00 
  80231e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802322:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802329:	e8 d9 e9 ff ff       	call   800d07 <sys_page_map>
  80232e:	89 c3                	mov    %eax,%ebx
  802330:	85 c0                	test   %eax,%eax
  802332:	78 52                	js     802386 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802334:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80233a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80233d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80233f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802342:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802349:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80234f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802352:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802354:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802357:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80235e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802361:	89 04 24             	mov    %eax,(%esp)
  802364:	e8 87 ef ff ff       	call   8012f0 <fd2num>
  802369:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80236c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80236e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802371:	89 04 24             	mov    %eax,(%esp)
  802374:	e8 77 ef ff ff       	call   8012f0 <fd2num>
  802379:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80237c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80237f:	b8 00 00 00 00       	mov    $0x0,%eax
  802384:	eb 38                	jmp    8023be <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  802386:	89 74 24 04          	mov    %esi,0x4(%esp)
  80238a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802391:	e8 c4 e9 ff ff       	call   800d5a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802396:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802399:	89 44 24 04          	mov    %eax,0x4(%esp)
  80239d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023a4:	e8 b1 e9 ff ff       	call   800d5a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8023a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023b7:	e8 9e e9 ff ff       	call   800d5a <sys_page_unmap>
  8023bc:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  8023be:	83 c4 30             	add    $0x30,%esp
  8023c1:	5b                   	pop    %ebx
  8023c2:	5e                   	pop    %esi
  8023c3:	5d                   	pop    %ebp
  8023c4:	c3                   	ret    

008023c5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8023c5:	55                   	push   %ebp
  8023c6:	89 e5                	mov    %esp,%ebp
  8023c8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8023d5:	89 04 24             	mov    %eax,(%esp)
  8023d8:	e8 89 ef ff ff       	call   801366 <fd_lookup>
  8023dd:	89 c2                	mov    %eax,%edx
  8023df:	85 d2                	test   %edx,%edx
  8023e1:	78 15                	js     8023f8 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8023e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023e6:	89 04 24             	mov    %eax,(%esp)
  8023e9:	e8 12 ef ff ff       	call   801300 <fd2data>
	return _pipeisclosed(fd, p);
  8023ee:	89 c2                	mov    %eax,%edx
  8023f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023f3:	e8 0b fd ff ff       	call   802103 <_pipeisclosed>
}
  8023f8:	c9                   	leave  
  8023f9:	c3                   	ret    
  8023fa:	66 90                	xchg   %ax,%ax
  8023fc:	66 90                	xchg   %ax,%ax
  8023fe:	66 90                	xchg   %ax,%ax

00802400 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802400:	55                   	push   %ebp
  802401:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802403:	b8 00 00 00 00       	mov    $0x0,%eax
  802408:	5d                   	pop    %ebp
  802409:	c3                   	ret    

0080240a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80240a:	55                   	push   %ebp
  80240b:	89 e5                	mov    %esp,%ebp
  80240d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802410:	c7 44 24 04 5f 2f 80 	movl   $0x802f5f,0x4(%esp)
  802417:	00 
  802418:	8b 45 0c             	mov    0xc(%ebp),%eax
  80241b:	89 04 24             	mov    %eax,(%esp)
  80241e:	e8 74 e4 ff ff       	call   800897 <strcpy>
	return 0;
}
  802423:	b8 00 00 00 00       	mov    $0x0,%eax
  802428:	c9                   	leave  
  802429:	c3                   	ret    

0080242a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80242a:	55                   	push   %ebp
  80242b:	89 e5                	mov    %esp,%ebp
  80242d:	57                   	push   %edi
  80242e:	56                   	push   %esi
  80242f:	53                   	push   %ebx
  802430:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802436:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80243b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802441:	eb 31                	jmp    802474 <devcons_write+0x4a>
		m = n - tot;
  802443:	8b 75 10             	mov    0x10(%ebp),%esi
  802446:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802448:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80244b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802450:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802453:	89 74 24 08          	mov    %esi,0x8(%esp)
  802457:	03 45 0c             	add    0xc(%ebp),%eax
  80245a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80245e:	89 3c 24             	mov    %edi,(%esp)
  802461:	e8 ce e5 ff ff       	call   800a34 <memmove>
		sys_cputs(buf, m);
  802466:	89 74 24 04          	mov    %esi,0x4(%esp)
  80246a:	89 3c 24             	mov    %edi,(%esp)
  80246d:	e8 74 e7 ff ff       	call   800be6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802472:	01 f3                	add    %esi,%ebx
  802474:	89 d8                	mov    %ebx,%eax
  802476:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802479:	72 c8                	jb     802443 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80247b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802481:	5b                   	pop    %ebx
  802482:	5e                   	pop    %esi
  802483:	5f                   	pop    %edi
  802484:	5d                   	pop    %ebp
  802485:	c3                   	ret    

00802486 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802486:	55                   	push   %ebp
  802487:	89 e5                	mov    %esp,%ebp
  802489:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80248c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802491:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802495:	75 07                	jne    80249e <devcons_read+0x18>
  802497:	eb 2a                	jmp    8024c3 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802499:	e8 f6 e7 ff ff       	call   800c94 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80249e:	66 90                	xchg   %ax,%ax
  8024a0:	e8 5f e7 ff ff       	call   800c04 <sys_cgetc>
  8024a5:	85 c0                	test   %eax,%eax
  8024a7:	74 f0                	je     802499 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8024a9:	85 c0                	test   %eax,%eax
  8024ab:	78 16                	js     8024c3 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8024ad:	83 f8 04             	cmp    $0x4,%eax
  8024b0:	74 0c                	je     8024be <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  8024b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024b5:	88 02                	mov    %al,(%edx)
	return 1;
  8024b7:	b8 01 00 00 00       	mov    $0x1,%eax
  8024bc:	eb 05                	jmp    8024c3 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8024be:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8024c3:	c9                   	leave  
  8024c4:	c3                   	ret    

008024c5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8024c5:	55                   	push   %ebp
  8024c6:	89 e5                	mov    %esp,%ebp
  8024c8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8024cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8024ce:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8024d1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8024d8:	00 
  8024d9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8024dc:	89 04 24             	mov    %eax,(%esp)
  8024df:	e8 02 e7 ff ff       	call   800be6 <sys_cputs>
}
  8024e4:	c9                   	leave  
  8024e5:	c3                   	ret    

008024e6 <getchar>:

int
getchar(void)
{
  8024e6:	55                   	push   %ebp
  8024e7:	89 e5                	mov    %esp,%ebp
  8024e9:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8024ec:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8024f3:	00 
  8024f4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8024f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802502:	e8 f3 f0 ff ff       	call   8015fa <read>
	if (r < 0)
  802507:	85 c0                	test   %eax,%eax
  802509:	78 0f                	js     80251a <getchar+0x34>
		return r;
	if (r < 1)
  80250b:	85 c0                	test   %eax,%eax
  80250d:	7e 06                	jle    802515 <getchar+0x2f>
		return -E_EOF;
	return c;
  80250f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802513:	eb 05                	jmp    80251a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802515:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80251a:	c9                   	leave  
  80251b:	c3                   	ret    

0080251c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80251c:	55                   	push   %ebp
  80251d:	89 e5                	mov    %esp,%ebp
  80251f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802522:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802525:	89 44 24 04          	mov    %eax,0x4(%esp)
  802529:	8b 45 08             	mov    0x8(%ebp),%eax
  80252c:	89 04 24             	mov    %eax,(%esp)
  80252f:	e8 32 ee ff ff       	call   801366 <fd_lookup>
  802534:	85 c0                	test   %eax,%eax
  802536:	78 11                	js     802549 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802538:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80253b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802541:	39 10                	cmp    %edx,(%eax)
  802543:	0f 94 c0             	sete   %al
  802546:	0f b6 c0             	movzbl %al,%eax
}
  802549:	c9                   	leave  
  80254a:	c3                   	ret    

0080254b <opencons>:

int
opencons(void)
{
  80254b:	55                   	push   %ebp
  80254c:	89 e5                	mov    %esp,%ebp
  80254e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802551:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802554:	89 04 24             	mov    %eax,(%esp)
  802557:	e8 bb ed ff ff       	call   801317 <fd_alloc>
		return r;
  80255c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80255e:	85 c0                	test   %eax,%eax
  802560:	78 40                	js     8025a2 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802562:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802569:	00 
  80256a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80256d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802571:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802578:	e8 36 e7 ff ff       	call   800cb3 <sys_page_alloc>
		return r;
  80257d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80257f:	85 c0                	test   %eax,%eax
  802581:	78 1f                	js     8025a2 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802583:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802589:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80258c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80258e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802591:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802598:	89 04 24             	mov    %eax,(%esp)
  80259b:	e8 50 ed ff ff       	call   8012f0 <fd2num>
  8025a0:	89 c2                	mov    %eax,%edx
}
  8025a2:	89 d0                	mov    %edx,%eax
  8025a4:	c9                   	leave  
  8025a5:	c3                   	ret    

008025a6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8025a6:	55                   	push   %ebp
  8025a7:	89 e5                	mov    %esp,%ebp
  8025a9:	53                   	push   %ebx
  8025aa:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  8025ad:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8025b4:	75 2f                	jne    8025e5 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  8025b6:	e8 ba e6 ff ff       	call   800c75 <sys_getenvid>
  8025bb:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P);
  8025bd:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8025c4:	00 
  8025c5:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8025cc:	ee 
  8025cd:	89 04 24             	mov    %eax,(%esp)
  8025d0:	e8 de e6 ff ff       	call   800cb3 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *)_pgfault_upcall);
  8025d5:	c7 44 24 04 f3 25 80 	movl   $0x8025f3,0x4(%esp)
  8025dc:	00 
  8025dd:	89 1c 24             	mov    %ebx,(%esp)
  8025e0:	e8 6e e8 ff ff       	call   800e53 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8025e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8025e8:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8025ed:	83 c4 14             	add    $0x14,%esp
  8025f0:	5b                   	pop    %ebx
  8025f1:	5d                   	pop    %ebp
  8025f2:	c3                   	ret    

008025f3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8025f3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8025f4:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8025f9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8025fb:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	// 0x30(%esp) points to trap-time stack pointer
	// 0x28(%esp) points to trap-time eip
	subl $4, 0x30(%esp)
  8025fe:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax 
  802603:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebp
  802607:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %ebp, (%eax)
  80260b:	89 28                	mov    %ebp,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  80260d:	83 c4 08             	add    $0x8,%esp
	popal
  802610:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp //pop eip - we already stored it
  802611:	83 c4 04             	add    $0x4,%esp
	popfl
  802614:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802615:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802616:	c3                   	ret    
  802617:	66 90                	xchg   %ax,%ax
  802619:	66 90                	xchg   %ax,%ax
  80261b:	66 90                	xchg   %ax,%ax
  80261d:	66 90                	xchg   %ax,%ax
  80261f:	90                   	nop

00802620 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802620:	55                   	push   %ebp
  802621:	89 e5                	mov    %esp,%ebp
  802623:	56                   	push   %esi
  802624:	53                   	push   %ebx
  802625:	83 ec 10             	sub    $0x10,%esp
  802628:	8b 75 08             	mov    0x8(%ebp),%esi
  80262b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80262e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  802631:	85 c0                	test   %eax,%eax
  802633:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802638:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  80263b:	89 04 24             	mov    %eax,(%esp)
  80263e:	e8 86 e8 ff ff       	call   800ec9 <sys_ipc_recv>

	if(ret < 0) {
  802643:	85 c0                	test   %eax,%eax
  802645:	79 16                	jns    80265d <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  802647:	85 f6                	test   %esi,%esi
  802649:	74 06                	je     802651 <ipc_recv+0x31>
  80264b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  802651:	85 db                	test   %ebx,%ebx
  802653:	74 3e                	je     802693 <ipc_recv+0x73>
  802655:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80265b:	eb 36                	jmp    802693 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  80265d:	e8 13 e6 ff ff       	call   800c75 <sys_getenvid>
  802662:	25 ff 03 00 00       	and    $0x3ff,%eax
  802667:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80266a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80266f:	a3 0c 40 80 00       	mov    %eax,0x80400c

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802674:	85 f6                	test   %esi,%esi
  802676:	74 05                	je     80267d <ipc_recv+0x5d>
  802678:	8b 40 74             	mov    0x74(%eax),%eax
  80267b:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80267d:	85 db                	test   %ebx,%ebx
  80267f:	74 0a                	je     80268b <ipc_recv+0x6b>
  802681:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802686:	8b 40 78             	mov    0x78(%eax),%eax
  802689:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  80268b:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802690:	8b 40 70             	mov    0x70(%eax),%eax
}
  802693:	83 c4 10             	add    $0x10,%esp
  802696:	5b                   	pop    %ebx
  802697:	5e                   	pop    %esi
  802698:	5d                   	pop    %ebp
  802699:	c3                   	ret    

0080269a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80269a:	55                   	push   %ebp
  80269b:	89 e5                	mov    %esp,%ebp
  80269d:	57                   	push   %edi
  80269e:	56                   	push   %esi
  80269f:	53                   	push   %ebx
  8026a0:	83 ec 1c             	sub    $0x1c,%esp
  8026a3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8026a6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8026a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  8026ac:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  8026ae:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8026b3:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  8026b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8026b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026bd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026c5:	89 3c 24             	mov    %edi,(%esp)
  8026c8:	e8 d9 e7 ff ff       	call   800ea6 <sys_ipc_try_send>

		if(ret >= 0) break;
  8026cd:	85 c0                	test   %eax,%eax
  8026cf:	79 2c                	jns    8026fd <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  8026d1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8026d4:	74 20                	je     8026f6 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  8026d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026da:	c7 44 24 08 6c 2f 80 	movl   $0x802f6c,0x8(%esp)
  8026e1:	00 
  8026e2:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8026e9:	00 
  8026ea:	c7 04 24 9c 2f 80 00 	movl   $0x802f9c,(%esp)
  8026f1:	e8 7c da ff ff       	call   800172 <_panic>
		}
		sys_yield();
  8026f6:	e8 99 e5 ff ff       	call   800c94 <sys_yield>
	}
  8026fb:	eb b9                	jmp    8026b6 <ipc_send+0x1c>
}
  8026fd:	83 c4 1c             	add    $0x1c,%esp
  802700:	5b                   	pop    %ebx
  802701:	5e                   	pop    %esi
  802702:	5f                   	pop    %edi
  802703:	5d                   	pop    %ebp
  802704:	c3                   	ret    

00802705 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802705:	55                   	push   %ebp
  802706:	89 e5                	mov    %esp,%ebp
  802708:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80270b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802710:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802713:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802719:	8b 52 50             	mov    0x50(%edx),%edx
  80271c:	39 ca                	cmp    %ecx,%edx
  80271e:	75 0d                	jne    80272d <ipc_find_env+0x28>
			return envs[i].env_id;
  802720:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802723:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802728:	8b 40 40             	mov    0x40(%eax),%eax
  80272b:	eb 0e                	jmp    80273b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80272d:	83 c0 01             	add    $0x1,%eax
  802730:	3d 00 04 00 00       	cmp    $0x400,%eax
  802735:	75 d9                	jne    802710 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802737:	66 b8 00 00          	mov    $0x0,%ax
}
  80273b:	5d                   	pop    %ebp
  80273c:	c3                   	ret    

0080273d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80273d:	55                   	push   %ebp
  80273e:	89 e5                	mov    %esp,%ebp
  802740:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802743:	89 d0                	mov    %edx,%eax
  802745:	c1 e8 16             	shr    $0x16,%eax
  802748:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80274f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802754:	f6 c1 01             	test   $0x1,%cl
  802757:	74 1d                	je     802776 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802759:	c1 ea 0c             	shr    $0xc,%edx
  80275c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802763:	f6 c2 01             	test   $0x1,%dl
  802766:	74 0e                	je     802776 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802768:	c1 ea 0c             	shr    $0xc,%edx
  80276b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802772:	ef 
  802773:	0f b7 c0             	movzwl %ax,%eax
}
  802776:	5d                   	pop    %ebp
  802777:	c3                   	ret    
  802778:	66 90                	xchg   %ax,%ax
  80277a:	66 90                	xchg   %ax,%ax
  80277c:	66 90                	xchg   %ax,%ax
  80277e:	66 90                	xchg   %ax,%ax

00802780 <__udivdi3>:
  802780:	55                   	push   %ebp
  802781:	57                   	push   %edi
  802782:	56                   	push   %esi
  802783:	83 ec 0c             	sub    $0xc,%esp
  802786:	8b 44 24 28          	mov    0x28(%esp),%eax
  80278a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80278e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802792:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802796:	85 c0                	test   %eax,%eax
  802798:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80279c:	89 ea                	mov    %ebp,%edx
  80279e:	89 0c 24             	mov    %ecx,(%esp)
  8027a1:	75 2d                	jne    8027d0 <__udivdi3+0x50>
  8027a3:	39 e9                	cmp    %ebp,%ecx
  8027a5:	77 61                	ja     802808 <__udivdi3+0x88>
  8027a7:	85 c9                	test   %ecx,%ecx
  8027a9:	89 ce                	mov    %ecx,%esi
  8027ab:	75 0b                	jne    8027b8 <__udivdi3+0x38>
  8027ad:	b8 01 00 00 00       	mov    $0x1,%eax
  8027b2:	31 d2                	xor    %edx,%edx
  8027b4:	f7 f1                	div    %ecx
  8027b6:	89 c6                	mov    %eax,%esi
  8027b8:	31 d2                	xor    %edx,%edx
  8027ba:	89 e8                	mov    %ebp,%eax
  8027bc:	f7 f6                	div    %esi
  8027be:	89 c5                	mov    %eax,%ebp
  8027c0:	89 f8                	mov    %edi,%eax
  8027c2:	f7 f6                	div    %esi
  8027c4:	89 ea                	mov    %ebp,%edx
  8027c6:	83 c4 0c             	add    $0xc,%esp
  8027c9:	5e                   	pop    %esi
  8027ca:	5f                   	pop    %edi
  8027cb:	5d                   	pop    %ebp
  8027cc:	c3                   	ret    
  8027cd:	8d 76 00             	lea    0x0(%esi),%esi
  8027d0:	39 e8                	cmp    %ebp,%eax
  8027d2:	77 24                	ja     8027f8 <__udivdi3+0x78>
  8027d4:	0f bd e8             	bsr    %eax,%ebp
  8027d7:	83 f5 1f             	xor    $0x1f,%ebp
  8027da:	75 3c                	jne    802818 <__udivdi3+0x98>
  8027dc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8027e0:	39 34 24             	cmp    %esi,(%esp)
  8027e3:	0f 86 9f 00 00 00    	jbe    802888 <__udivdi3+0x108>
  8027e9:	39 d0                	cmp    %edx,%eax
  8027eb:	0f 82 97 00 00 00    	jb     802888 <__udivdi3+0x108>
  8027f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027f8:	31 d2                	xor    %edx,%edx
  8027fa:	31 c0                	xor    %eax,%eax
  8027fc:	83 c4 0c             	add    $0xc,%esp
  8027ff:	5e                   	pop    %esi
  802800:	5f                   	pop    %edi
  802801:	5d                   	pop    %ebp
  802802:	c3                   	ret    
  802803:	90                   	nop
  802804:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802808:	89 f8                	mov    %edi,%eax
  80280a:	f7 f1                	div    %ecx
  80280c:	31 d2                	xor    %edx,%edx
  80280e:	83 c4 0c             	add    $0xc,%esp
  802811:	5e                   	pop    %esi
  802812:	5f                   	pop    %edi
  802813:	5d                   	pop    %ebp
  802814:	c3                   	ret    
  802815:	8d 76 00             	lea    0x0(%esi),%esi
  802818:	89 e9                	mov    %ebp,%ecx
  80281a:	8b 3c 24             	mov    (%esp),%edi
  80281d:	d3 e0                	shl    %cl,%eax
  80281f:	89 c6                	mov    %eax,%esi
  802821:	b8 20 00 00 00       	mov    $0x20,%eax
  802826:	29 e8                	sub    %ebp,%eax
  802828:	89 c1                	mov    %eax,%ecx
  80282a:	d3 ef                	shr    %cl,%edi
  80282c:	89 e9                	mov    %ebp,%ecx
  80282e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802832:	8b 3c 24             	mov    (%esp),%edi
  802835:	09 74 24 08          	or     %esi,0x8(%esp)
  802839:	89 d6                	mov    %edx,%esi
  80283b:	d3 e7                	shl    %cl,%edi
  80283d:	89 c1                	mov    %eax,%ecx
  80283f:	89 3c 24             	mov    %edi,(%esp)
  802842:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802846:	d3 ee                	shr    %cl,%esi
  802848:	89 e9                	mov    %ebp,%ecx
  80284a:	d3 e2                	shl    %cl,%edx
  80284c:	89 c1                	mov    %eax,%ecx
  80284e:	d3 ef                	shr    %cl,%edi
  802850:	09 d7                	or     %edx,%edi
  802852:	89 f2                	mov    %esi,%edx
  802854:	89 f8                	mov    %edi,%eax
  802856:	f7 74 24 08          	divl   0x8(%esp)
  80285a:	89 d6                	mov    %edx,%esi
  80285c:	89 c7                	mov    %eax,%edi
  80285e:	f7 24 24             	mull   (%esp)
  802861:	39 d6                	cmp    %edx,%esi
  802863:	89 14 24             	mov    %edx,(%esp)
  802866:	72 30                	jb     802898 <__udivdi3+0x118>
  802868:	8b 54 24 04          	mov    0x4(%esp),%edx
  80286c:	89 e9                	mov    %ebp,%ecx
  80286e:	d3 e2                	shl    %cl,%edx
  802870:	39 c2                	cmp    %eax,%edx
  802872:	73 05                	jae    802879 <__udivdi3+0xf9>
  802874:	3b 34 24             	cmp    (%esp),%esi
  802877:	74 1f                	je     802898 <__udivdi3+0x118>
  802879:	89 f8                	mov    %edi,%eax
  80287b:	31 d2                	xor    %edx,%edx
  80287d:	e9 7a ff ff ff       	jmp    8027fc <__udivdi3+0x7c>
  802882:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802888:	31 d2                	xor    %edx,%edx
  80288a:	b8 01 00 00 00       	mov    $0x1,%eax
  80288f:	e9 68 ff ff ff       	jmp    8027fc <__udivdi3+0x7c>
  802894:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802898:	8d 47 ff             	lea    -0x1(%edi),%eax
  80289b:	31 d2                	xor    %edx,%edx
  80289d:	83 c4 0c             	add    $0xc,%esp
  8028a0:	5e                   	pop    %esi
  8028a1:	5f                   	pop    %edi
  8028a2:	5d                   	pop    %ebp
  8028a3:	c3                   	ret    
  8028a4:	66 90                	xchg   %ax,%ax
  8028a6:	66 90                	xchg   %ax,%ax
  8028a8:	66 90                	xchg   %ax,%ax
  8028aa:	66 90                	xchg   %ax,%ax
  8028ac:	66 90                	xchg   %ax,%ax
  8028ae:	66 90                	xchg   %ax,%ax

008028b0 <__umoddi3>:
  8028b0:	55                   	push   %ebp
  8028b1:	57                   	push   %edi
  8028b2:	56                   	push   %esi
  8028b3:	83 ec 14             	sub    $0x14,%esp
  8028b6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8028ba:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8028be:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8028c2:	89 c7                	mov    %eax,%edi
  8028c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028c8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8028cc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8028d0:	89 34 24             	mov    %esi,(%esp)
  8028d3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028d7:	85 c0                	test   %eax,%eax
  8028d9:	89 c2                	mov    %eax,%edx
  8028db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8028df:	75 17                	jne    8028f8 <__umoddi3+0x48>
  8028e1:	39 fe                	cmp    %edi,%esi
  8028e3:	76 4b                	jbe    802930 <__umoddi3+0x80>
  8028e5:	89 c8                	mov    %ecx,%eax
  8028e7:	89 fa                	mov    %edi,%edx
  8028e9:	f7 f6                	div    %esi
  8028eb:	89 d0                	mov    %edx,%eax
  8028ed:	31 d2                	xor    %edx,%edx
  8028ef:	83 c4 14             	add    $0x14,%esp
  8028f2:	5e                   	pop    %esi
  8028f3:	5f                   	pop    %edi
  8028f4:	5d                   	pop    %ebp
  8028f5:	c3                   	ret    
  8028f6:	66 90                	xchg   %ax,%ax
  8028f8:	39 f8                	cmp    %edi,%eax
  8028fa:	77 54                	ja     802950 <__umoddi3+0xa0>
  8028fc:	0f bd e8             	bsr    %eax,%ebp
  8028ff:	83 f5 1f             	xor    $0x1f,%ebp
  802902:	75 5c                	jne    802960 <__umoddi3+0xb0>
  802904:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802908:	39 3c 24             	cmp    %edi,(%esp)
  80290b:	0f 87 e7 00 00 00    	ja     8029f8 <__umoddi3+0x148>
  802911:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802915:	29 f1                	sub    %esi,%ecx
  802917:	19 c7                	sbb    %eax,%edi
  802919:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80291d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802921:	8b 44 24 08          	mov    0x8(%esp),%eax
  802925:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802929:	83 c4 14             	add    $0x14,%esp
  80292c:	5e                   	pop    %esi
  80292d:	5f                   	pop    %edi
  80292e:	5d                   	pop    %ebp
  80292f:	c3                   	ret    
  802930:	85 f6                	test   %esi,%esi
  802932:	89 f5                	mov    %esi,%ebp
  802934:	75 0b                	jne    802941 <__umoddi3+0x91>
  802936:	b8 01 00 00 00       	mov    $0x1,%eax
  80293b:	31 d2                	xor    %edx,%edx
  80293d:	f7 f6                	div    %esi
  80293f:	89 c5                	mov    %eax,%ebp
  802941:	8b 44 24 04          	mov    0x4(%esp),%eax
  802945:	31 d2                	xor    %edx,%edx
  802947:	f7 f5                	div    %ebp
  802949:	89 c8                	mov    %ecx,%eax
  80294b:	f7 f5                	div    %ebp
  80294d:	eb 9c                	jmp    8028eb <__umoddi3+0x3b>
  80294f:	90                   	nop
  802950:	89 c8                	mov    %ecx,%eax
  802952:	89 fa                	mov    %edi,%edx
  802954:	83 c4 14             	add    $0x14,%esp
  802957:	5e                   	pop    %esi
  802958:	5f                   	pop    %edi
  802959:	5d                   	pop    %ebp
  80295a:	c3                   	ret    
  80295b:	90                   	nop
  80295c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802960:	8b 04 24             	mov    (%esp),%eax
  802963:	be 20 00 00 00       	mov    $0x20,%esi
  802968:	89 e9                	mov    %ebp,%ecx
  80296a:	29 ee                	sub    %ebp,%esi
  80296c:	d3 e2                	shl    %cl,%edx
  80296e:	89 f1                	mov    %esi,%ecx
  802970:	d3 e8                	shr    %cl,%eax
  802972:	89 e9                	mov    %ebp,%ecx
  802974:	89 44 24 04          	mov    %eax,0x4(%esp)
  802978:	8b 04 24             	mov    (%esp),%eax
  80297b:	09 54 24 04          	or     %edx,0x4(%esp)
  80297f:	89 fa                	mov    %edi,%edx
  802981:	d3 e0                	shl    %cl,%eax
  802983:	89 f1                	mov    %esi,%ecx
  802985:	89 44 24 08          	mov    %eax,0x8(%esp)
  802989:	8b 44 24 10          	mov    0x10(%esp),%eax
  80298d:	d3 ea                	shr    %cl,%edx
  80298f:	89 e9                	mov    %ebp,%ecx
  802991:	d3 e7                	shl    %cl,%edi
  802993:	89 f1                	mov    %esi,%ecx
  802995:	d3 e8                	shr    %cl,%eax
  802997:	89 e9                	mov    %ebp,%ecx
  802999:	09 f8                	or     %edi,%eax
  80299b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80299f:	f7 74 24 04          	divl   0x4(%esp)
  8029a3:	d3 e7                	shl    %cl,%edi
  8029a5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8029a9:	89 d7                	mov    %edx,%edi
  8029ab:	f7 64 24 08          	mull   0x8(%esp)
  8029af:	39 d7                	cmp    %edx,%edi
  8029b1:	89 c1                	mov    %eax,%ecx
  8029b3:	89 14 24             	mov    %edx,(%esp)
  8029b6:	72 2c                	jb     8029e4 <__umoddi3+0x134>
  8029b8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8029bc:	72 22                	jb     8029e0 <__umoddi3+0x130>
  8029be:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8029c2:	29 c8                	sub    %ecx,%eax
  8029c4:	19 d7                	sbb    %edx,%edi
  8029c6:	89 e9                	mov    %ebp,%ecx
  8029c8:	89 fa                	mov    %edi,%edx
  8029ca:	d3 e8                	shr    %cl,%eax
  8029cc:	89 f1                	mov    %esi,%ecx
  8029ce:	d3 e2                	shl    %cl,%edx
  8029d0:	89 e9                	mov    %ebp,%ecx
  8029d2:	d3 ef                	shr    %cl,%edi
  8029d4:	09 d0                	or     %edx,%eax
  8029d6:	89 fa                	mov    %edi,%edx
  8029d8:	83 c4 14             	add    $0x14,%esp
  8029db:	5e                   	pop    %esi
  8029dc:	5f                   	pop    %edi
  8029dd:	5d                   	pop    %ebp
  8029de:	c3                   	ret    
  8029df:	90                   	nop
  8029e0:	39 d7                	cmp    %edx,%edi
  8029e2:	75 da                	jne    8029be <__umoddi3+0x10e>
  8029e4:	8b 14 24             	mov    (%esp),%edx
  8029e7:	89 c1                	mov    %eax,%ecx
  8029e9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8029ed:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8029f1:	eb cb                	jmp    8029be <__umoddi3+0x10e>
  8029f3:	90                   	nop
  8029f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8029f8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8029fc:	0f 82 0f ff ff ff    	jb     802911 <__umoddi3+0x61>
  802a02:	e9 1a ff ff ff       	jmp    802921 <__umoddi3+0x71>
