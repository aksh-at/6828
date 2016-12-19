
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 b9 01 00 00       	call   8001ea <libmain>
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
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003c:	c7 04 24 e0 2a 80 00 	movl   $0x802ae0,(%esp)
  800043:	e8 fc 02 00 00       	call   800344 <cprintf>
	if ((r = pipe(p)) < 0)
  800048:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80004b:	89 04 24             	mov    %eax,(%esp)
  80004e:	e8 d1 22 00 00       	call   802324 <pipe>
  800053:	85 c0                	test   %eax,%eax
  800055:	79 20                	jns    800077 <umain+0x44>
		panic("pipe: %e", r);
  800057:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005b:	c7 44 24 08 2e 2b 80 	movl   $0x802b2e,0x8(%esp)
  800062:	00 
  800063:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  80006a:	00 
  80006b:	c7 04 24 37 2b 80 00 	movl   $0x802b37,(%esp)
  800072:	e8 d4 01 00 00       	call   80024b <_panic>
	if ((r = fork()) < 0)
  800077:	e8 38 11 00 00       	call   8011b4 <fork>
  80007c:	89 c7                	mov    %eax,%edi
  80007e:	85 c0                	test   %eax,%eax
  800080:	79 20                	jns    8000a2 <umain+0x6f>
		panic("fork: %e", r);
  800082:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800086:	c7 44 24 08 4c 2b 80 	movl   $0x802b4c,0x8(%esp)
  80008d:	00 
  80008e:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800095:	00 
  800096:	c7 04 24 37 2b 80 00 	movl   $0x802b37,(%esp)
  80009d:	e8 a9 01 00 00       	call   80024b <_panic>
	if (r == 0) {
  8000a2:	85 c0                	test   %eax,%eax
  8000a4:	75 75                	jne    80011b <umain+0xe8>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  8000a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000a9:	89 04 24             	mov    %eax,(%esp)
  8000ac:	e8 b6 14 00 00       	call   801567 <close>
		for (i = 0; i < 200; i++) {
  8000b1:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (i % 10 == 0)
  8000b6:	be 67 66 66 66       	mov    $0x66666667,%esi
  8000bb:	89 d8                	mov    %ebx,%eax
  8000bd:	f7 ee                	imul   %esi
  8000bf:	c1 fa 02             	sar    $0x2,%edx
  8000c2:	89 d8                	mov    %ebx,%eax
  8000c4:	c1 f8 1f             	sar    $0x1f,%eax
  8000c7:	29 c2                	sub    %eax,%edx
  8000c9:	8d 04 92             	lea    (%edx,%edx,4),%eax
  8000cc:	01 c0                	add    %eax,%eax
  8000ce:	39 c3                	cmp    %eax,%ebx
  8000d0:	75 10                	jne    8000e2 <umain+0xaf>
				cprintf("%d.", i);
  8000d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d6:	c7 04 24 55 2b 80 00 	movl   $0x802b55,(%esp)
  8000dd:	e8 62 02 00 00       	call   800344 <cprintf>
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000e2:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  8000e9:	00 
  8000ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8000ed:	89 04 24             	mov    %eax,(%esp)
  8000f0:	e8 c7 14 00 00       	call   8015bc <dup>
			sys_yield();
  8000f5:	e8 6a 0c 00 00       	call   800d64 <sys_yield>
			close(10);
  8000fa:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800101:	e8 61 14 00 00       	call   801567 <close>
			sys_yield();
  800106:	e8 59 0c 00 00       	call   800d64 <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  80010b:	83 c3 01             	add    $0x1,%ebx
  80010e:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  800114:	75 a5                	jne    8000bb <umain+0x88>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  800116:	e8 17 01 00 00       	call   800232 <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  80011b:	89 fb                	mov    %edi,%ebx
  80011d:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  800123:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  800126:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (kid->env_status == ENV_RUNNABLE)
  80012c:	eb 28                	jmp    800156 <umain+0x123>
		if (pipeisclosed(p[0]) != 0) {
  80012e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800131:	89 04 24             	mov    %eax,(%esp)
  800134:	e8 5c 23 00 00       	call   802495 <pipeisclosed>
  800139:	85 c0                	test   %eax,%eax
  80013b:	74 19                	je     800156 <umain+0x123>
			cprintf("\nRACE: pipe appears closed\n");
  80013d:	c7 04 24 59 2b 80 00 	movl   $0x802b59,(%esp)
  800144:	e8 fb 01 00 00       	call   800344 <cprintf>
			sys_env_destroy(r);
  800149:	89 3c 24             	mov    %edi,(%esp)
  80014c:	e8 a2 0b 00 00       	call   800cf3 <sys_env_destroy>
			exit();
  800151:	e8 dc 00 00 00       	call   800232 <exit>
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800156:	8b 43 54             	mov    0x54(%ebx),%eax
  800159:	83 f8 02             	cmp    $0x2,%eax
  80015c:	74 d0                	je     80012e <umain+0xfb>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  80015e:	c7 04 24 75 2b 80 00 	movl   $0x802b75,(%esp)
  800165:	e8 da 01 00 00       	call   800344 <cprintf>
	if (pipeisclosed(p[0]))
  80016a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80016d:	89 04 24             	mov    %eax,(%esp)
  800170:	e8 20 23 00 00       	call   802495 <pipeisclosed>
  800175:	85 c0                	test   %eax,%eax
  800177:	74 1c                	je     800195 <umain+0x162>
		panic("somehow the other end of p[0] got closed!");
  800179:	c7 44 24 08 04 2b 80 	movl   $0x802b04,0x8(%esp)
  800180:	00 
  800181:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  800188:	00 
  800189:	c7 04 24 37 2b 80 00 	movl   $0x802b37,(%esp)
  800190:	e8 b6 00 00 00       	call   80024b <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800195:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800198:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80019f:	89 04 24             	mov    %eax,(%esp)
  8001a2:	e8 8f 12 00 00       	call   801436 <fd_lookup>
  8001a7:	85 c0                	test   %eax,%eax
  8001a9:	79 20                	jns    8001cb <umain+0x198>
		panic("cannot look up p[0]: %e", r);
  8001ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001af:	c7 44 24 08 8b 2b 80 	movl   $0x802b8b,0x8(%esp)
  8001b6:	00 
  8001b7:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
  8001be:	00 
  8001bf:	c7 04 24 37 2b 80 00 	movl   $0x802b37,(%esp)
  8001c6:	e8 80 00 00 00       	call   80024b <_panic>
	(void) fd2data(fd);
  8001cb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001ce:	89 04 24             	mov    %eax,(%esp)
  8001d1:	e8 fa 11 00 00       	call   8013d0 <fd2data>
	cprintf("race didn't happen\n");
  8001d6:	c7 04 24 a3 2b 80 00 	movl   $0x802ba3,(%esp)
  8001dd:	e8 62 01 00 00       	call   800344 <cprintf>
}
  8001e2:	83 c4 2c             	add    $0x2c,%esp
  8001e5:	5b                   	pop    %ebx
  8001e6:	5e                   	pop    %esi
  8001e7:	5f                   	pop    %edi
  8001e8:	5d                   	pop    %ebp
  8001e9:	c3                   	ret    

008001ea <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	56                   	push   %esi
  8001ee:	53                   	push   %ebx
  8001ef:	83 ec 10             	sub    $0x10,%esp
  8001f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  8001f8:	e8 48 0b 00 00       	call   800d45 <sys_getenvid>
  8001fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800202:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800205:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80020a:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80020f:	85 db                	test   %ebx,%ebx
  800211:	7e 07                	jle    80021a <libmain+0x30>
		binaryname = argv[0];
  800213:	8b 06                	mov    (%esi),%eax
  800215:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  80021a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80021e:	89 1c 24             	mov    %ebx,(%esp)
  800221:	e8 0d fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800226:	e8 07 00 00 00       	call   800232 <exit>
}
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	5b                   	pop    %ebx
  80022f:	5e                   	pop    %esi
  800230:	5d                   	pop    %ebp
  800231:	c3                   	ret    

00800232 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800238:	e8 5d 13 00 00       	call   80159a <close_all>
	sys_env_destroy(0);
  80023d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800244:	e8 aa 0a 00 00       	call   800cf3 <sys_env_destroy>
}
  800249:	c9                   	leave  
  80024a:	c3                   	ret    

0080024b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	56                   	push   %esi
  80024f:	53                   	push   %ebx
  800250:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800253:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800256:	8b 35 00 40 80 00    	mov    0x804000,%esi
  80025c:	e8 e4 0a 00 00       	call   800d45 <sys_getenvid>
  800261:	8b 55 0c             	mov    0xc(%ebp),%edx
  800264:	89 54 24 10          	mov    %edx,0x10(%esp)
  800268:	8b 55 08             	mov    0x8(%ebp),%edx
  80026b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80026f:	89 74 24 08          	mov    %esi,0x8(%esp)
  800273:	89 44 24 04          	mov    %eax,0x4(%esp)
  800277:	c7 04 24 c4 2b 80 00 	movl   $0x802bc4,(%esp)
  80027e:	e8 c1 00 00 00       	call   800344 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800283:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800287:	8b 45 10             	mov    0x10(%ebp),%eax
  80028a:	89 04 24             	mov    %eax,(%esp)
  80028d:	e8 51 00 00 00       	call   8002e3 <vcprintf>
	cprintf("\n");
  800292:	c7 04 24 98 30 80 00 	movl   $0x803098,(%esp)
  800299:	e8 a6 00 00 00       	call   800344 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80029e:	cc                   	int3   
  80029f:	eb fd                	jmp    80029e <_panic+0x53>

008002a1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	53                   	push   %ebx
  8002a5:	83 ec 14             	sub    $0x14,%esp
  8002a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002ab:	8b 13                	mov    (%ebx),%edx
  8002ad:	8d 42 01             	lea    0x1(%edx),%eax
  8002b0:	89 03                	mov    %eax,(%ebx)
  8002b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002b9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002be:	75 19                	jne    8002d9 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002c0:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002c7:	00 
  8002c8:	8d 43 08             	lea    0x8(%ebx),%eax
  8002cb:	89 04 24             	mov    %eax,(%esp)
  8002ce:	e8 e3 09 00 00       	call   800cb6 <sys_cputs>
		b->idx = 0;
  8002d3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002d9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002dd:	83 c4 14             	add    $0x14,%esp
  8002e0:	5b                   	pop    %ebx
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002ec:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002f3:	00 00 00 
	b.cnt = 0;
  8002f6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002fd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800300:	8b 45 0c             	mov    0xc(%ebp),%eax
  800303:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800307:	8b 45 08             	mov    0x8(%ebp),%eax
  80030a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800314:	89 44 24 04          	mov    %eax,0x4(%esp)
  800318:	c7 04 24 a1 02 80 00 	movl   $0x8002a1,(%esp)
  80031f:	e8 aa 01 00 00       	call   8004ce <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800324:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80032a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800334:	89 04 24             	mov    %eax,(%esp)
  800337:	e8 7a 09 00 00       	call   800cb6 <sys_cputs>

	return b.cnt;
}
  80033c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800342:	c9                   	leave  
  800343:	c3                   	ret    

00800344 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80034a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80034d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800351:	8b 45 08             	mov    0x8(%ebp),%eax
  800354:	89 04 24             	mov    %eax,(%esp)
  800357:	e8 87 ff ff ff       	call   8002e3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80035c:	c9                   	leave  
  80035d:	c3                   	ret    
  80035e:	66 90                	xchg   %ax,%ax

00800360 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	57                   	push   %edi
  800364:	56                   	push   %esi
  800365:	53                   	push   %ebx
  800366:	83 ec 3c             	sub    $0x3c,%esp
  800369:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036c:	89 d7                	mov    %edx,%edi
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800374:	8b 45 0c             	mov    0xc(%ebp),%eax
  800377:	89 c3                	mov    %eax,%ebx
  800379:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80037c:	8b 45 10             	mov    0x10(%ebp),%eax
  80037f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800382:	b9 00 00 00 00       	mov    $0x0,%ecx
  800387:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80038a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80038d:	39 d9                	cmp    %ebx,%ecx
  80038f:	72 05                	jb     800396 <printnum+0x36>
  800391:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800394:	77 69                	ja     8003ff <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800396:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800399:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80039d:	83 ee 01             	sub    $0x1,%esi
  8003a0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8003ac:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8003b0:	89 c3                	mov    %eax,%ebx
  8003b2:	89 d6                	mov    %edx,%esi
  8003b4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003b7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8003ba:	89 54 24 08          	mov    %edx,0x8(%esp)
  8003be:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8003c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c5:	89 04 24             	mov    %eax,(%esp)
  8003c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003cf:	e8 7c 24 00 00       	call   802850 <__udivdi3>
  8003d4:	89 d9                	mov    %ebx,%ecx
  8003d6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003da:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003de:	89 04 24             	mov    %eax,(%esp)
  8003e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003e5:	89 fa                	mov    %edi,%edx
  8003e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003ea:	e8 71 ff ff ff       	call   800360 <printnum>
  8003ef:	eb 1b                	jmp    80040c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003f5:	8b 45 18             	mov    0x18(%ebp),%eax
  8003f8:	89 04 24             	mov    %eax,(%esp)
  8003fb:	ff d3                	call   *%ebx
  8003fd:	eb 03                	jmp    800402 <printnum+0xa2>
  8003ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800402:	83 ee 01             	sub    $0x1,%esi
  800405:	85 f6                	test   %esi,%esi
  800407:	7f e8                	jg     8003f1 <printnum+0x91>
  800409:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80040c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800410:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800414:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800417:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80041a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80041e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800422:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800425:	89 04 24             	mov    %eax,(%esp)
  800428:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80042b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80042f:	e8 4c 25 00 00       	call   802980 <__umoddi3>
  800434:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800438:	0f be 80 e7 2b 80 00 	movsbl 0x802be7(%eax),%eax
  80043f:	89 04 24             	mov    %eax,(%esp)
  800442:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800445:	ff d0                	call   *%eax
}
  800447:	83 c4 3c             	add    $0x3c,%esp
  80044a:	5b                   	pop    %ebx
  80044b:	5e                   	pop    %esi
  80044c:	5f                   	pop    %edi
  80044d:	5d                   	pop    %ebp
  80044e:	c3                   	ret    

0080044f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80044f:	55                   	push   %ebp
  800450:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800452:	83 fa 01             	cmp    $0x1,%edx
  800455:	7e 0e                	jle    800465 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800457:	8b 10                	mov    (%eax),%edx
  800459:	8d 4a 08             	lea    0x8(%edx),%ecx
  80045c:	89 08                	mov    %ecx,(%eax)
  80045e:	8b 02                	mov    (%edx),%eax
  800460:	8b 52 04             	mov    0x4(%edx),%edx
  800463:	eb 22                	jmp    800487 <getuint+0x38>
	else if (lflag)
  800465:	85 d2                	test   %edx,%edx
  800467:	74 10                	je     800479 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800469:	8b 10                	mov    (%eax),%edx
  80046b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80046e:	89 08                	mov    %ecx,(%eax)
  800470:	8b 02                	mov    (%edx),%eax
  800472:	ba 00 00 00 00       	mov    $0x0,%edx
  800477:	eb 0e                	jmp    800487 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800479:	8b 10                	mov    (%eax),%edx
  80047b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80047e:	89 08                	mov    %ecx,(%eax)
  800480:	8b 02                	mov    (%edx),%eax
  800482:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800487:	5d                   	pop    %ebp
  800488:	c3                   	ret    

00800489 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800489:	55                   	push   %ebp
  80048a:	89 e5                	mov    %esp,%ebp
  80048c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80048f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800493:	8b 10                	mov    (%eax),%edx
  800495:	3b 50 04             	cmp    0x4(%eax),%edx
  800498:	73 0a                	jae    8004a4 <sprintputch+0x1b>
		*b->buf++ = ch;
  80049a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80049d:	89 08                	mov    %ecx,(%eax)
  80049f:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a2:	88 02                	mov    %al,(%edx)
}
  8004a4:	5d                   	pop    %ebp
  8004a5:	c3                   	ret    

008004a6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004a6:	55                   	push   %ebp
  8004a7:	89 e5                	mov    %esp,%ebp
  8004a9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8004b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c4:	89 04 24             	mov    %eax,(%esp)
  8004c7:	e8 02 00 00 00       	call   8004ce <vprintfmt>
	va_end(ap);
}
  8004cc:	c9                   	leave  
  8004cd:	c3                   	ret    

008004ce <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004ce:	55                   	push   %ebp
  8004cf:	89 e5                	mov    %esp,%ebp
  8004d1:	57                   	push   %edi
  8004d2:	56                   	push   %esi
  8004d3:	53                   	push   %ebx
  8004d4:	83 ec 3c             	sub    $0x3c,%esp
  8004d7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004dd:	eb 14                	jmp    8004f3 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004df:	85 c0                	test   %eax,%eax
  8004e1:	0f 84 b3 03 00 00    	je     80089a <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  8004e7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004eb:	89 04 24             	mov    %eax,(%esp)
  8004ee:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004f1:	89 f3                	mov    %esi,%ebx
  8004f3:	8d 73 01             	lea    0x1(%ebx),%esi
  8004f6:	0f b6 03             	movzbl (%ebx),%eax
  8004f9:	83 f8 25             	cmp    $0x25,%eax
  8004fc:	75 e1                	jne    8004df <vprintfmt+0x11>
  8004fe:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800502:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800509:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800510:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800517:	ba 00 00 00 00       	mov    $0x0,%edx
  80051c:	eb 1d                	jmp    80053b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800520:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800524:	eb 15                	jmp    80053b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800528:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80052c:	eb 0d                	jmp    80053b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80052e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800531:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800534:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80053e:	0f b6 0e             	movzbl (%esi),%ecx
  800541:	0f b6 c1             	movzbl %cl,%eax
  800544:	83 e9 23             	sub    $0x23,%ecx
  800547:	80 f9 55             	cmp    $0x55,%cl
  80054a:	0f 87 2a 03 00 00    	ja     80087a <vprintfmt+0x3ac>
  800550:	0f b6 c9             	movzbl %cl,%ecx
  800553:	ff 24 8d 20 2d 80 00 	jmp    *0x802d20(,%ecx,4)
  80055a:	89 de                	mov    %ebx,%esi
  80055c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800561:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800564:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800568:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80056b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80056e:	83 fb 09             	cmp    $0x9,%ebx
  800571:	77 36                	ja     8005a9 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800573:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800576:	eb e9                	jmp    800561 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8d 48 04             	lea    0x4(%eax),%ecx
  80057e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800581:	8b 00                	mov    (%eax),%eax
  800583:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800586:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800588:	eb 22                	jmp    8005ac <vprintfmt+0xde>
  80058a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80058d:	85 c9                	test   %ecx,%ecx
  80058f:	b8 00 00 00 00       	mov    $0x0,%eax
  800594:	0f 49 c1             	cmovns %ecx,%eax
  800597:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059a:	89 de                	mov    %ebx,%esi
  80059c:	eb 9d                	jmp    80053b <vprintfmt+0x6d>
  80059e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005a0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8005a7:	eb 92                	jmp    80053b <vprintfmt+0x6d>
  8005a9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8005ac:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b0:	79 89                	jns    80053b <vprintfmt+0x6d>
  8005b2:	e9 77 ff ff ff       	jmp    80052e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005b7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ba:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005bc:	e9 7a ff ff ff       	jmp    80053b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8d 50 04             	lea    0x4(%eax),%edx
  8005c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ce:	8b 00                	mov    (%eax),%eax
  8005d0:	89 04 24             	mov    %eax,(%esp)
  8005d3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005d6:	e9 18 ff ff ff       	jmp    8004f3 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8d 50 04             	lea    0x4(%eax),%edx
  8005e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e4:	8b 00                	mov    (%eax),%eax
  8005e6:	99                   	cltd   
  8005e7:	31 d0                	xor    %edx,%eax
  8005e9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005eb:	83 f8 0f             	cmp    $0xf,%eax
  8005ee:	7f 0b                	jg     8005fb <vprintfmt+0x12d>
  8005f0:	8b 14 85 80 2e 80 00 	mov    0x802e80(,%eax,4),%edx
  8005f7:	85 d2                	test   %edx,%edx
  8005f9:	75 20                	jne    80061b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  8005fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005ff:	c7 44 24 08 ff 2b 80 	movl   $0x802bff,0x8(%esp)
  800606:	00 
  800607:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80060b:	8b 45 08             	mov    0x8(%ebp),%eax
  80060e:	89 04 24             	mov    %eax,(%esp)
  800611:	e8 90 fe ff ff       	call   8004a6 <printfmt>
  800616:	e9 d8 fe ff ff       	jmp    8004f3 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80061b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80061f:	c7 44 24 08 2d 30 80 	movl   $0x80302d,0x8(%esp)
  800626:	00 
  800627:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80062b:	8b 45 08             	mov    0x8(%ebp),%eax
  80062e:	89 04 24             	mov    %eax,(%esp)
  800631:	e8 70 fe ff ff       	call   8004a6 <printfmt>
  800636:	e9 b8 fe ff ff       	jmp    8004f3 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80063e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800641:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8d 50 04             	lea    0x4(%eax),%edx
  80064a:	89 55 14             	mov    %edx,0x14(%ebp)
  80064d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80064f:	85 f6                	test   %esi,%esi
  800651:	b8 f8 2b 80 00       	mov    $0x802bf8,%eax
  800656:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800659:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80065d:	0f 84 97 00 00 00    	je     8006fa <vprintfmt+0x22c>
  800663:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800667:	0f 8e 9b 00 00 00    	jle    800708 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80066d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800671:	89 34 24             	mov    %esi,(%esp)
  800674:	e8 cf 02 00 00       	call   800948 <strnlen>
  800679:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80067c:	29 c2                	sub    %eax,%edx
  80067e:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800681:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800685:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800688:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80068b:	8b 75 08             	mov    0x8(%ebp),%esi
  80068e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800691:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800693:	eb 0f                	jmp    8006a4 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800695:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800699:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80069c:	89 04 24             	mov    %eax,(%esp)
  80069f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a1:	83 eb 01             	sub    $0x1,%ebx
  8006a4:	85 db                	test   %ebx,%ebx
  8006a6:	7f ed                	jg     800695 <vprintfmt+0x1c7>
  8006a8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006ab:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006ae:	85 d2                	test   %edx,%edx
  8006b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b5:	0f 49 c2             	cmovns %edx,%eax
  8006b8:	29 c2                	sub    %eax,%edx
  8006ba:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006bd:	89 d7                	mov    %edx,%edi
  8006bf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006c2:	eb 50                	jmp    800714 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006c4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006c8:	74 1e                	je     8006e8 <vprintfmt+0x21a>
  8006ca:	0f be d2             	movsbl %dl,%edx
  8006cd:	83 ea 20             	sub    $0x20,%edx
  8006d0:	83 fa 5e             	cmp    $0x5e,%edx
  8006d3:	76 13                	jbe    8006e8 <vprintfmt+0x21a>
					putch('?', putdat);
  8006d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006dc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006e3:	ff 55 08             	call   *0x8(%ebp)
  8006e6:	eb 0d                	jmp    8006f5 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8006e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006ef:	89 04 24             	mov    %eax,(%esp)
  8006f2:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006f5:	83 ef 01             	sub    $0x1,%edi
  8006f8:	eb 1a                	jmp    800714 <vprintfmt+0x246>
  8006fa:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006fd:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800700:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800703:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800706:	eb 0c                	jmp    800714 <vprintfmt+0x246>
  800708:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80070b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80070e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800711:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800714:	83 c6 01             	add    $0x1,%esi
  800717:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80071b:	0f be c2             	movsbl %dl,%eax
  80071e:	85 c0                	test   %eax,%eax
  800720:	74 27                	je     800749 <vprintfmt+0x27b>
  800722:	85 db                	test   %ebx,%ebx
  800724:	78 9e                	js     8006c4 <vprintfmt+0x1f6>
  800726:	83 eb 01             	sub    $0x1,%ebx
  800729:	79 99                	jns    8006c4 <vprintfmt+0x1f6>
  80072b:	89 f8                	mov    %edi,%eax
  80072d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800730:	8b 75 08             	mov    0x8(%ebp),%esi
  800733:	89 c3                	mov    %eax,%ebx
  800735:	eb 1a                	jmp    800751 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800737:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80073b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800742:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800744:	83 eb 01             	sub    $0x1,%ebx
  800747:	eb 08                	jmp    800751 <vprintfmt+0x283>
  800749:	89 fb                	mov    %edi,%ebx
  80074b:	8b 75 08             	mov    0x8(%ebp),%esi
  80074e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800751:	85 db                	test   %ebx,%ebx
  800753:	7f e2                	jg     800737 <vprintfmt+0x269>
  800755:	89 75 08             	mov    %esi,0x8(%ebp)
  800758:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80075b:	e9 93 fd ff ff       	jmp    8004f3 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800760:	83 fa 01             	cmp    $0x1,%edx
  800763:	7e 16                	jle    80077b <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800765:	8b 45 14             	mov    0x14(%ebp),%eax
  800768:	8d 50 08             	lea    0x8(%eax),%edx
  80076b:	89 55 14             	mov    %edx,0x14(%ebp)
  80076e:	8b 50 04             	mov    0x4(%eax),%edx
  800771:	8b 00                	mov    (%eax),%eax
  800773:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800776:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800779:	eb 32                	jmp    8007ad <vprintfmt+0x2df>
	else if (lflag)
  80077b:	85 d2                	test   %edx,%edx
  80077d:	74 18                	je     800797 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  80077f:	8b 45 14             	mov    0x14(%ebp),%eax
  800782:	8d 50 04             	lea    0x4(%eax),%edx
  800785:	89 55 14             	mov    %edx,0x14(%ebp)
  800788:	8b 30                	mov    (%eax),%esi
  80078a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80078d:	89 f0                	mov    %esi,%eax
  80078f:	c1 f8 1f             	sar    $0x1f,%eax
  800792:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800795:	eb 16                	jmp    8007ad <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800797:	8b 45 14             	mov    0x14(%ebp),%eax
  80079a:	8d 50 04             	lea    0x4(%eax),%edx
  80079d:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a0:	8b 30                	mov    (%eax),%esi
  8007a2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8007a5:	89 f0                	mov    %esi,%eax
  8007a7:	c1 f8 1f             	sar    $0x1f,%eax
  8007aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007b3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007b8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007bc:	0f 89 80 00 00 00    	jns    800842 <vprintfmt+0x374>
				putch('-', putdat);
  8007c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007c6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007cd:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007d3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007d6:	f7 d8                	neg    %eax
  8007d8:	83 d2 00             	adc    $0x0,%edx
  8007db:	f7 da                	neg    %edx
			}
			base = 10;
  8007dd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007e2:	eb 5e                	jmp    800842 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007e4:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e7:	e8 63 fc ff ff       	call   80044f <getuint>
			base = 10;
  8007ec:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007f1:	eb 4f                	jmp    800842 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8007f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f6:	e8 54 fc ff ff       	call   80044f <getuint>
			base = 8;
  8007fb:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800800:	eb 40                	jmp    800842 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800802:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800806:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80080d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800810:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800814:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80081b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80081e:	8b 45 14             	mov    0x14(%ebp),%eax
  800821:	8d 50 04             	lea    0x4(%eax),%edx
  800824:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800827:	8b 00                	mov    (%eax),%eax
  800829:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80082e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800833:	eb 0d                	jmp    800842 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800835:	8d 45 14             	lea    0x14(%ebp),%eax
  800838:	e8 12 fc ff ff       	call   80044f <getuint>
			base = 16;
  80083d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800842:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800846:	89 74 24 10          	mov    %esi,0x10(%esp)
  80084a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80084d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800851:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800855:	89 04 24             	mov    %eax,(%esp)
  800858:	89 54 24 04          	mov    %edx,0x4(%esp)
  80085c:	89 fa                	mov    %edi,%edx
  80085e:	8b 45 08             	mov    0x8(%ebp),%eax
  800861:	e8 fa fa ff ff       	call   800360 <printnum>
			break;
  800866:	e9 88 fc ff ff       	jmp    8004f3 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80086b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80086f:	89 04 24             	mov    %eax,(%esp)
  800872:	ff 55 08             	call   *0x8(%ebp)
			break;
  800875:	e9 79 fc ff ff       	jmp    8004f3 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80087a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80087e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800885:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800888:	89 f3                	mov    %esi,%ebx
  80088a:	eb 03                	jmp    80088f <vprintfmt+0x3c1>
  80088c:	83 eb 01             	sub    $0x1,%ebx
  80088f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800893:	75 f7                	jne    80088c <vprintfmt+0x3be>
  800895:	e9 59 fc ff ff       	jmp    8004f3 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  80089a:	83 c4 3c             	add    $0x3c,%esp
  80089d:	5b                   	pop    %ebx
  80089e:	5e                   	pop    %esi
  80089f:	5f                   	pop    %edi
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	83 ec 28             	sub    $0x28,%esp
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008b1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008b5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008bf:	85 c0                	test   %eax,%eax
  8008c1:	74 30                	je     8008f3 <vsnprintf+0x51>
  8008c3:	85 d2                	test   %edx,%edx
  8008c5:	7e 2c                	jle    8008f3 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8008d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008d5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008dc:	c7 04 24 89 04 80 00 	movl   $0x800489,(%esp)
  8008e3:	e8 e6 fb ff ff       	call   8004ce <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008eb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008f1:	eb 05                	jmp    8008f8 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008f8:	c9                   	leave  
  8008f9:	c3                   	ret    

008008fa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800900:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800903:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800907:	8b 45 10             	mov    0x10(%ebp),%eax
  80090a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80090e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800911:	89 44 24 04          	mov    %eax,0x4(%esp)
  800915:	8b 45 08             	mov    0x8(%ebp),%eax
  800918:	89 04 24             	mov    %eax,(%esp)
  80091b:	e8 82 ff ff ff       	call   8008a2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800920:	c9                   	leave  
  800921:	c3                   	ret    
  800922:	66 90                	xchg   %ax,%ax
  800924:	66 90                	xchg   %ax,%ax
  800926:	66 90                	xchg   %ax,%ax
  800928:	66 90                	xchg   %ax,%ax
  80092a:	66 90                	xchg   %ax,%ax
  80092c:	66 90                	xchg   %ax,%ax
  80092e:	66 90                	xchg   %ax,%ax

00800930 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800936:	b8 00 00 00 00       	mov    $0x0,%eax
  80093b:	eb 03                	jmp    800940 <strlen+0x10>
		n++;
  80093d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800940:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800944:	75 f7                	jne    80093d <strlen+0xd>
		n++;
	return n;
}
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80094e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800951:	b8 00 00 00 00       	mov    $0x0,%eax
  800956:	eb 03                	jmp    80095b <strnlen+0x13>
		n++;
  800958:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80095b:	39 d0                	cmp    %edx,%eax
  80095d:	74 06                	je     800965 <strnlen+0x1d>
  80095f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800963:	75 f3                	jne    800958 <strnlen+0x10>
		n++;
	return n;
}
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	53                   	push   %ebx
  80096b:	8b 45 08             	mov    0x8(%ebp),%eax
  80096e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800971:	89 c2                	mov    %eax,%edx
  800973:	83 c2 01             	add    $0x1,%edx
  800976:	83 c1 01             	add    $0x1,%ecx
  800979:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80097d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800980:	84 db                	test   %bl,%bl
  800982:	75 ef                	jne    800973 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800984:	5b                   	pop    %ebx
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	53                   	push   %ebx
  80098b:	83 ec 08             	sub    $0x8,%esp
  80098e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800991:	89 1c 24             	mov    %ebx,(%esp)
  800994:	e8 97 ff ff ff       	call   800930 <strlen>
	strcpy(dst + len, src);
  800999:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099c:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009a0:	01 d8                	add    %ebx,%eax
  8009a2:	89 04 24             	mov    %eax,(%esp)
  8009a5:	e8 bd ff ff ff       	call   800967 <strcpy>
	return dst;
}
  8009aa:	89 d8                	mov    %ebx,%eax
  8009ac:	83 c4 08             	add    $0x8,%esp
  8009af:	5b                   	pop    %ebx
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	56                   	push   %esi
  8009b6:	53                   	push   %ebx
  8009b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009bd:	89 f3                	mov    %esi,%ebx
  8009bf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c2:	89 f2                	mov    %esi,%edx
  8009c4:	eb 0f                	jmp    8009d5 <strncpy+0x23>
		*dst++ = *src;
  8009c6:	83 c2 01             	add    $0x1,%edx
  8009c9:	0f b6 01             	movzbl (%ecx),%eax
  8009cc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009cf:	80 39 01             	cmpb   $0x1,(%ecx)
  8009d2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d5:	39 da                	cmp    %ebx,%edx
  8009d7:	75 ed                	jne    8009c6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009d9:	89 f0                	mov    %esi,%eax
  8009db:	5b                   	pop    %ebx
  8009dc:	5e                   	pop    %esi
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	56                   	push   %esi
  8009e3:	53                   	push   %ebx
  8009e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8009e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009ed:	89 f0                	mov    %esi,%eax
  8009ef:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009f3:	85 c9                	test   %ecx,%ecx
  8009f5:	75 0b                	jne    800a02 <strlcpy+0x23>
  8009f7:	eb 1d                	jmp    800a16 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009f9:	83 c0 01             	add    $0x1,%eax
  8009fc:	83 c2 01             	add    $0x1,%edx
  8009ff:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a02:	39 d8                	cmp    %ebx,%eax
  800a04:	74 0b                	je     800a11 <strlcpy+0x32>
  800a06:	0f b6 0a             	movzbl (%edx),%ecx
  800a09:	84 c9                	test   %cl,%cl
  800a0b:	75 ec                	jne    8009f9 <strlcpy+0x1a>
  800a0d:	89 c2                	mov    %eax,%edx
  800a0f:	eb 02                	jmp    800a13 <strlcpy+0x34>
  800a11:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800a13:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800a16:	29 f0                	sub    %esi,%eax
}
  800a18:	5b                   	pop    %ebx
  800a19:	5e                   	pop    %esi
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a22:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a25:	eb 06                	jmp    800a2d <strcmp+0x11>
		p++, q++;
  800a27:	83 c1 01             	add    $0x1,%ecx
  800a2a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a2d:	0f b6 01             	movzbl (%ecx),%eax
  800a30:	84 c0                	test   %al,%al
  800a32:	74 04                	je     800a38 <strcmp+0x1c>
  800a34:	3a 02                	cmp    (%edx),%al
  800a36:	74 ef                	je     800a27 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a38:	0f b6 c0             	movzbl %al,%eax
  800a3b:	0f b6 12             	movzbl (%edx),%edx
  800a3e:	29 d0                	sub    %edx,%eax
}
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    

00800a42 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	53                   	push   %ebx
  800a46:	8b 45 08             	mov    0x8(%ebp),%eax
  800a49:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4c:	89 c3                	mov    %eax,%ebx
  800a4e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a51:	eb 06                	jmp    800a59 <strncmp+0x17>
		n--, p++, q++;
  800a53:	83 c0 01             	add    $0x1,%eax
  800a56:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a59:	39 d8                	cmp    %ebx,%eax
  800a5b:	74 15                	je     800a72 <strncmp+0x30>
  800a5d:	0f b6 08             	movzbl (%eax),%ecx
  800a60:	84 c9                	test   %cl,%cl
  800a62:	74 04                	je     800a68 <strncmp+0x26>
  800a64:	3a 0a                	cmp    (%edx),%cl
  800a66:	74 eb                	je     800a53 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a68:	0f b6 00             	movzbl (%eax),%eax
  800a6b:	0f b6 12             	movzbl (%edx),%edx
  800a6e:	29 d0                	sub    %edx,%eax
  800a70:	eb 05                	jmp    800a77 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a72:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a77:	5b                   	pop    %ebx
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a80:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a84:	eb 07                	jmp    800a8d <strchr+0x13>
		if (*s == c)
  800a86:	38 ca                	cmp    %cl,%dl
  800a88:	74 0f                	je     800a99 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a8a:	83 c0 01             	add    $0x1,%eax
  800a8d:	0f b6 10             	movzbl (%eax),%edx
  800a90:	84 d2                	test   %dl,%dl
  800a92:	75 f2                	jne    800a86 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a94:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa5:	eb 07                	jmp    800aae <strfind+0x13>
		if (*s == c)
  800aa7:	38 ca                	cmp    %cl,%dl
  800aa9:	74 0a                	je     800ab5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aab:	83 c0 01             	add    $0x1,%eax
  800aae:	0f b6 10             	movzbl (%eax),%edx
  800ab1:	84 d2                	test   %dl,%dl
  800ab3:	75 f2                	jne    800aa7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800ab5:	5d                   	pop    %ebp
  800ab6:	c3                   	ret    

00800ab7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	57                   	push   %edi
  800abb:	56                   	push   %esi
  800abc:	53                   	push   %ebx
  800abd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ac0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ac3:	85 c9                	test   %ecx,%ecx
  800ac5:	74 36                	je     800afd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ac7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800acd:	75 28                	jne    800af7 <memset+0x40>
  800acf:	f6 c1 03             	test   $0x3,%cl
  800ad2:	75 23                	jne    800af7 <memset+0x40>
		c &= 0xFF;
  800ad4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ad8:	89 d3                	mov    %edx,%ebx
  800ada:	c1 e3 08             	shl    $0x8,%ebx
  800add:	89 d6                	mov    %edx,%esi
  800adf:	c1 e6 18             	shl    $0x18,%esi
  800ae2:	89 d0                	mov    %edx,%eax
  800ae4:	c1 e0 10             	shl    $0x10,%eax
  800ae7:	09 f0                	or     %esi,%eax
  800ae9:	09 c2                	or     %eax,%edx
  800aeb:	89 d0                	mov    %edx,%eax
  800aed:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800aef:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800af2:	fc                   	cld    
  800af3:	f3 ab                	rep stos %eax,%es:(%edi)
  800af5:	eb 06                	jmp    800afd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800af7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afa:	fc                   	cld    
  800afb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800afd:	89 f8                	mov    %edi,%eax
  800aff:	5b                   	pop    %ebx
  800b00:	5e                   	pop    %esi
  800b01:	5f                   	pop    %edi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b12:	39 c6                	cmp    %eax,%esi
  800b14:	73 35                	jae    800b4b <memmove+0x47>
  800b16:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b19:	39 d0                	cmp    %edx,%eax
  800b1b:	73 2e                	jae    800b4b <memmove+0x47>
		s += n;
		d += n;
  800b1d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b20:	89 d6                	mov    %edx,%esi
  800b22:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b24:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b2a:	75 13                	jne    800b3f <memmove+0x3b>
  800b2c:	f6 c1 03             	test   $0x3,%cl
  800b2f:	75 0e                	jne    800b3f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b31:	83 ef 04             	sub    $0x4,%edi
  800b34:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b37:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b3a:	fd                   	std    
  800b3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b3d:	eb 09                	jmp    800b48 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b3f:	83 ef 01             	sub    $0x1,%edi
  800b42:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b45:	fd                   	std    
  800b46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b48:	fc                   	cld    
  800b49:	eb 1d                	jmp    800b68 <memmove+0x64>
  800b4b:	89 f2                	mov    %esi,%edx
  800b4d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b4f:	f6 c2 03             	test   $0x3,%dl
  800b52:	75 0f                	jne    800b63 <memmove+0x5f>
  800b54:	f6 c1 03             	test   $0x3,%cl
  800b57:	75 0a                	jne    800b63 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b59:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b5c:	89 c7                	mov    %eax,%edi
  800b5e:	fc                   	cld    
  800b5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b61:	eb 05                	jmp    800b68 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b63:	89 c7                	mov    %eax,%edi
  800b65:	fc                   	cld    
  800b66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b68:	5e                   	pop    %esi
  800b69:	5f                   	pop    %edi
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b72:	8b 45 10             	mov    0x10(%ebp),%eax
  800b75:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b80:	8b 45 08             	mov    0x8(%ebp),%eax
  800b83:	89 04 24             	mov    %eax,(%esp)
  800b86:	e8 79 ff ff ff       	call   800b04 <memmove>
}
  800b8b:	c9                   	leave  
  800b8c:	c3                   	ret    

00800b8d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	56                   	push   %esi
  800b91:	53                   	push   %ebx
  800b92:	8b 55 08             	mov    0x8(%ebp),%edx
  800b95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b98:	89 d6                	mov    %edx,%esi
  800b9a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b9d:	eb 1a                	jmp    800bb9 <memcmp+0x2c>
		if (*s1 != *s2)
  800b9f:	0f b6 02             	movzbl (%edx),%eax
  800ba2:	0f b6 19             	movzbl (%ecx),%ebx
  800ba5:	38 d8                	cmp    %bl,%al
  800ba7:	74 0a                	je     800bb3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ba9:	0f b6 c0             	movzbl %al,%eax
  800bac:	0f b6 db             	movzbl %bl,%ebx
  800baf:	29 d8                	sub    %ebx,%eax
  800bb1:	eb 0f                	jmp    800bc2 <memcmp+0x35>
		s1++, s2++;
  800bb3:	83 c2 01             	add    $0x1,%edx
  800bb6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bb9:	39 f2                	cmp    %esi,%edx
  800bbb:	75 e2                	jne    800b9f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc2:	5b                   	pop    %ebx
  800bc3:	5e                   	pop    %esi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bcf:	89 c2                	mov    %eax,%edx
  800bd1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bd4:	eb 07                	jmp    800bdd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd6:	38 08                	cmp    %cl,(%eax)
  800bd8:	74 07                	je     800be1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bda:	83 c0 01             	add    $0x1,%eax
  800bdd:	39 d0                	cmp    %edx,%eax
  800bdf:	72 f5                	jb     800bd6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bec:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bef:	eb 03                	jmp    800bf4 <strtol+0x11>
		s++;
  800bf1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf4:	0f b6 0a             	movzbl (%edx),%ecx
  800bf7:	80 f9 09             	cmp    $0x9,%cl
  800bfa:	74 f5                	je     800bf1 <strtol+0xe>
  800bfc:	80 f9 20             	cmp    $0x20,%cl
  800bff:	74 f0                	je     800bf1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c01:	80 f9 2b             	cmp    $0x2b,%cl
  800c04:	75 0a                	jne    800c10 <strtol+0x2d>
		s++;
  800c06:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c09:	bf 00 00 00 00       	mov    $0x0,%edi
  800c0e:	eb 11                	jmp    800c21 <strtol+0x3e>
  800c10:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c15:	80 f9 2d             	cmp    $0x2d,%cl
  800c18:	75 07                	jne    800c21 <strtol+0x3e>
		s++, neg = 1;
  800c1a:	8d 52 01             	lea    0x1(%edx),%edx
  800c1d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c21:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800c26:	75 15                	jne    800c3d <strtol+0x5a>
  800c28:	80 3a 30             	cmpb   $0x30,(%edx)
  800c2b:	75 10                	jne    800c3d <strtol+0x5a>
  800c2d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c31:	75 0a                	jne    800c3d <strtol+0x5a>
		s += 2, base = 16;
  800c33:	83 c2 02             	add    $0x2,%edx
  800c36:	b8 10 00 00 00       	mov    $0x10,%eax
  800c3b:	eb 10                	jmp    800c4d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	75 0c                	jne    800c4d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c41:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c43:	80 3a 30             	cmpb   $0x30,(%edx)
  800c46:	75 05                	jne    800c4d <strtol+0x6a>
		s++, base = 8;
  800c48:	83 c2 01             	add    $0x1,%edx
  800c4b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800c4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c52:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c55:	0f b6 0a             	movzbl (%edx),%ecx
  800c58:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c5b:	89 f0                	mov    %esi,%eax
  800c5d:	3c 09                	cmp    $0x9,%al
  800c5f:	77 08                	ja     800c69 <strtol+0x86>
			dig = *s - '0';
  800c61:	0f be c9             	movsbl %cl,%ecx
  800c64:	83 e9 30             	sub    $0x30,%ecx
  800c67:	eb 20                	jmp    800c89 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800c69:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c6c:	89 f0                	mov    %esi,%eax
  800c6e:	3c 19                	cmp    $0x19,%al
  800c70:	77 08                	ja     800c7a <strtol+0x97>
			dig = *s - 'a' + 10;
  800c72:	0f be c9             	movsbl %cl,%ecx
  800c75:	83 e9 57             	sub    $0x57,%ecx
  800c78:	eb 0f                	jmp    800c89 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800c7a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c7d:	89 f0                	mov    %esi,%eax
  800c7f:	3c 19                	cmp    $0x19,%al
  800c81:	77 16                	ja     800c99 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800c83:	0f be c9             	movsbl %cl,%ecx
  800c86:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c89:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c8c:	7d 0f                	jge    800c9d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800c8e:	83 c2 01             	add    $0x1,%edx
  800c91:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c95:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800c97:	eb bc                	jmp    800c55 <strtol+0x72>
  800c99:	89 d8                	mov    %ebx,%eax
  800c9b:	eb 02                	jmp    800c9f <strtol+0xbc>
  800c9d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800c9f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ca3:	74 05                	je     800caa <strtol+0xc7>
		*endptr = (char *) s;
  800ca5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800caa:	f7 d8                	neg    %eax
  800cac:	85 ff                	test   %edi,%edi
  800cae:	0f 44 c3             	cmove  %ebx,%eax
}
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    

00800cb6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc7:	89 c3                	mov    %eax,%ebx
  800cc9:	89 c7                	mov    %eax,%edi
  800ccb:	89 c6                	mov    %eax,%esi
  800ccd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cda:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdf:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce4:	89 d1                	mov    %edx,%ecx
  800ce6:	89 d3                	mov    %edx,%ebx
  800ce8:	89 d7                	mov    %edx,%edi
  800cea:	89 d6                	mov    %edx,%esi
  800cec:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cee:	5b                   	pop    %ebx
  800cef:	5e                   	pop    %esi
  800cf0:	5f                   	pop    %edi
  800cf1:	5d                   	pop    %ebp
  800cf2:	c3                   	ret    

00800cf3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	57                   	push   %edi
  800cf7:	56                   	push   %esi
  800cf8:	53                   	push   %ebx
  800cf9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d01:	b8 03 00 00 00       	mov    $0x3,%eax
  800d06:	8b 55 08             	mov    0x8(%ebp),%edx
  800d09:	89 cb                	mov    %ecx,%ebx
  800d0b:	89 cf                	mov    %ecx,%edi
  800d0d:	89 ce                	mov    %ecx,%esi
  800d0f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d11:	85 c0                	test   %eax,%eax
  800d13:	7e 28                	jle    800d3d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d15:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d19:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d20:	00 
  800d21:	c7 44 24 08 df 2e 80 	movl   $0x802edf,0x8(%esp)
  800d28:	00 
  800d29:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d30:	00 
  800d31:	c7 04 24 fc 2e 80 00 	movl   $0x802efc,(%esp)
  800d38:	e8 0e f5 ff ff       	call   80024b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d3d:	83 c4 2c             	add    $0x2c,%esp
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	57                   	push   %edi
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d50:	b8 02 00 00 00       	mov    $0x2,%eax
  800d55:	89 d1                	mov    %edx,%ecx
  800d57:	89 d3                	mov    %edx,%ebx
  800d59:	89 d7                	mov    %edx,%edi
  800d5b:	89 d6                	mov    %edx,%esi
  800d5d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d5f:	5b                   	pop    %ebx
  800d60:	5e                   	pop    %esi
  800d61:	5f                   	pop    %edi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <sys_yield>:

void
sys_yield(void)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	57                   	push   %edi
  800d68:	56                   	push   %esi
  800d69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d6f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d74:	89 d1                	mov    %edx,%ecx
  800d76:	89 d3                	mov    %edx,%ebx
  800d78:	89 d7                	mov    %edx,%edi
  800d7a:	89 d6                	mov    %edx,%esi
  800d7c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d7e:	5b                   	pop    %ebx
  800d7f:	5e                   	pop    %esi
  800d80:	5f                   	pop    %edi
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    

00800d83 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800d8c:	be 00 00 00 00       	mov    $0x0,%esi
  800d91:	b8 04 00 00 00       	mov    $0x4,%eax
  800d96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d99:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9f:	89 f7                	mov    %esi,%edi
  800da1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da3:	85 c0                	test   %eax,%eax
  800da5:	7e 28                	jle    800dcf <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dab:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800db2:	00 
  800db3:	c7 44 24 08 df 2e 80 	movl   $0x802edf,0x8(%esp)
  800dba:	00 
  800dbb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc2:	00 
  800dc3:	c7 04 24 fc 2e 80 00 	movl   $0x802efc,(%esp)
  800dca:	e8 7c f4 ff ff       	call   80024b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dcf:	83 c4 2c             	add    $0x2c,%esp
  800dd2:	5b                   	pop    %ebx
  800dd3:	5e                   	pop    %esi
  800dd4:	5f                   	pop    %edi
  800dd5:	5d                   	pop    %ebp
  800dd6:	c3                   	ret    

00800dd7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dd7:	55                   	push   %ebp
  800dd8:	89 e5                	mov    %esp,%ebp
  800dda:	57                   	push   %edi
  800ddb:	56                   	push   %esi
  800ddc:	53                   	push   %ebx
  800ddd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de0:	b8 05 00 00 00       	mov    $0x5,%eax
  800de5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de8:	8b 55 08             	mov    0x8(%ebp),%edx
  800deb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dee:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df1:	8b 75 18             	mov    0x18(%ebp),%esi
  800df4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800df6:	85 c0                	test   %eax,%eax
  800df8:	7e 28                	jle    800e22 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfa:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dfe:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e05:	00 
  800e06:	c7 44 24 08 df 2e 80 	movl   $0x802edf,0x8(%esp)
  800e0d:	00 
  800e0e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e15:	00 
  800e16:	c7 04 24 fc 2e 80 00 	movl   $0x802efc,(%esp)
  800e1d:	e8 29 f4 ff ff       	call   80024b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e22:	83 c4 2c             	add    $0x2c,%esp
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	57                   	push   %edi
  800e2e:	56                   	push   %esi
  800e2f:	53                   	push   %ebx
  800e30:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e38:	b8 06 00 00 00       	mov    $0x6,%eax
  800e3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e40:	8b 55 08             	mov    0x8(%ebp),%edx
  800e43:	89 df                	mov    %ebx,%edi
  800e45:	89 de                	mov    %ebx,%esi
  800e47:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	7e 28                	jle    800e75 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e51:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e58:	00 
  800e59:	c7 44 24 08 df 2e 80 	movl   $0x802edf,0x8(%esp)
  800e60:	00 
  800e61:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e68:	00 
  800e69:	c7 04 24 fc 2e 80 00 	movl   $0x802efc,(%esp)
  800e70:	e8 d6 f3 ff ff       	call   80024b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e75:	83 c4 2c             	add    $0x2c,%esp
  800e78:	5b                   	pop    %ebx
  800e79:	5e                   	pop    %esi
  800e7a:	5f                   	pop    %edi
  800e7b:	5d                   	pop    %ebp
  800e7c:	c3                   	ret    

00800e7d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
  800e80:	57                   	push   %edi
  800e81:	56                   	push   %esi
  800e82:	53                   	push   %ebx
  800e83:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e86:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e93:	8b 55 08             	mov    0x8(%ebp),%edx
  800e96:	89 df                	mov    %ebx,%edi
  800e98:	89 de                	mov    %ebx,%esi
  800e9a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e9c:	85 c0                	test   %eax,%eax
  800e9e:	7e 28                	jle    800ec8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800eab:	00 
  800eac:	c7 44 24 08 df 2e 80 	movl   $0x802edf,0x8(%esp)
  800eb3:	00 
  800eb4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ebb:	00 
  800ebc:	c7 04 24 fc 2e 80 00 	movl   $0x802efc,(%esp)
  800ec3:	e8 83 f3 ff ff       	call   80024b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ec8:	83 c4 2c             	add    $0x2c,%esp
  800ecb:	5b                   	pop    %ebx
  800ecc:	5e                   	pop    %esi
  800ecd:	5f                   	pop    %edi
  800ece:	5d                   	pop    %ebp
  800ecf:	c3                   	ret    

00800ed0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	57                   	push   %edi
  800ed4:	56                   	push   %esi
  800ed5:	53                   	push   %ebx
  800ed6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ede:	b8 09 00 00 00       	mov    $0x9,%eax
  800ee3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee9:	89 df                	mov    %ebx,%edi
  800eeb:	89 de                	mov    %ebx,%esi
  800eed:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eef:	85 c0                	test   %eax,%eax
  800ef1:	7e 28                	jle    800f1b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ef7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800efe:	00 
  800eff:	c7 44 24 08 df 2e 80 	movl   $0x802edf,0x8(%esp)
  800f06:	00 
  800f07:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f0e:	00 
  800f0f:	c7 04 24 fc 2e 80 00 	movl   $0x802efc,(%esp)
  800f16:	e8 30 f3 ff ff       	call   80024b <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f1b:	83 c4 2c             	add    $0x2c,%esp
  800f1e:	5b                   	pop    %ebx
  800f1f:	5e                   	pop    %esi
  800f20:	5f                   	pop    %edi
  800f21:	5d                   	pop    %ebp
  800f22:	c3                   	ret    

00800f23 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	57                   	push   %edi
  800f27:	56                   	push   %esi
  800f28:	53                   	push   %ebx
  800f29:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f31:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f39:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3c:	89 df                	mov    %ebx,%edi
  800f3e:	89 de                	mov    %ebx,%esi
  800f40:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f42:	85 c0                	test   %eax,%eax
  800f44:	7e 28                	jle    800f6e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f46:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f4a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f51:	00 
  800f52:	c7 44 24 08 df 2e 80 	movl   $0x802edf,0x8(%esp)
  800f59:	00 
  800f5a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f61:	00 
  800f62:	c7 04 24 fc 2e 80 00 	movl   $0x802efc,(%esp)
  800f69:	e8 dd f2 ff ff       	call   80024b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f6e:	83 c4 2c             	add    $0x2c,%esp
  800f71:	5b                   	pop    %ebx
  800f72:	5e                   	pop    %esi
  800f73:	5f                   	pop    %edi
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    

00800f76 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	57                   	push   %edi
  800f7a:	56                   	push   %esi
  800f7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7c:	be 00 00 00 00       	mov    $0x0,%esi
  800f81:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f89:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f8f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f92:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f94:	5b                   	pop    %ebx
  800f95:	5e                   	pop    %esi
  800f96:	5f                   	pop    %edi
  800f97:	5d                   	pop    %ebp
  800f98:	c3                   	ret    

00800f99 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	57                   	push   %edi
  800f9d:	56                   	push   %esi
  800f9e:	53                   	push   %ebx
  800f9f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fa7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fac:	8b 55 08             	mov    0x8(%ebp),%edx
  800faf:	89 cb                	mov    %ecx,%ebx
  800fb1:	89 cf                	mov    %ecx,%edi
  800fb3:	89 ce                	mov    %ecx,%esi
  800fb5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fb7:	85 c0                	test   %eax,%eax
  800fb9:	7e 28                	jle    800fe3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fbb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fbf:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800fc6:	00 
  800fc7:	c7 44 24 08 df 2e 80 	movl   $0x802edf,0x8(%esp)
  800fce:	00 
  800fcf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fd6:	00 
  800fd7:	c7 04 24 fc 2e 80 00 	movl   $0x802efc,(%esp)
  800fde:	e8 68 f2 ff ff       	call   80024b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fe3:	83 c4 2c             	add    $0x2c,%esp
  800fe6:	5b                   	pop    %ebx
  800fe7:	5e                   	pop    %esi
  800fe8:	5f                   	pop    %edi
  800fe9:	5d                   	pop    %ebp
  800fea:	c3                   	ret    

00800feb <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800feb:	55                   	push   %ebp
  800fec:	89 e5                	mov    %esp,%ebp
  800fee:	57                   	push   %edi
  800fef:	56                   	push   %esi
  800ff0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff6:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ffb:	89 d1                	mov    %edx,%ecx
  800ffd:	89 d3                	mov    %edx,%ebx
  800fff:	89 d7                	mov    %edx,%edi
  801001:	89 d6                	mov    %edx,%esi
  801003:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801005:	5b                   	pop    %ebx
  801006:	5e                   	pop    %esi
  801007:	5f                   	pop    %edi
  801008:	5d                   	pop    %ebp
  801009:	c3                   	ret    

0080100a <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  80100a:	55                   	push   %ebp
  80100b:	89 e5                	mov    %esp,%ebp
  80100d:	57                   	push   %edi
  80100e:	56                   	push   %esi
  80100f:	53                   	push   %ebx
  801010:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801013:	bb 00 00 00 00       	mov    $0x0,%ebx
  801018:	b8 0f 00 00 00       	mov    $0xf,%eax
  80101d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801020:	8b 55 08             	mov    0x8(%ebp),%edx
  801023:	89 df                	mov    %ebx,%edi
  801025:	89 de                	mov    %ebx,%esi
  801027:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801029:	85 c0                	test   %eax,%eax
  80102b:	7e 28                	jle    801055 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80102d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801031:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801038:	00 
  801039:	c7 44 24 08 df 2e 80 	movl   $0x802edf,0x8(%esp)
  801040:	00 
  801041:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801048:	00 
  801049:	c7 04 24 fc 2e 80 00 	movl   $0x802efc,(%esp)
  801050:	e8 f6 f1 ff ff       	call   80024b <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  801055:	83 c4 2c             	add    $0x2c,%esp
  801058:	5b                   	pop    %ebx
  801059:	5e                   	pop    %esi
  80105a:	5f                   	pop    %edi
  80105b:	5d                   	pop    %ebp
  80105c:	c3                   	ret    

0080105d <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	57                   	push   %edi
  801061:	56                   	push   %esi
  801062:	53                   	push   %ebx
  801063:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801066:	bb 00 00 00 00       	mov    $0x0,%ebx
  80106b:	b8 10 00 00 00       	mov    $0x10,%eax
  801070:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801073:	8b 55 08             	mov    0x8(%ebp),%edx
  801076:	89 df                	mov    %ebx,%edi
  801078:	89 de                	mov    %ebx,%esi
  80107a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80107c:	85 c0                	test   %eax,%eax
  80107e:	7e 28                	jle    8010a8 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801080:	89 44 24 10          	mov    %eax,0x10(%esp)
  801084:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  80108b:	00 
  80108c:	c7 44 24 08 df 2e 80 	movl   $0x802edf,0x8(%esp)
  801093:	00 
  801094:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80109b:	00 
  80109c:	c7 04 24 fc 2e 80 00 	movl   $0x802efc,(%esp)
  8010a3:	e8 a3 f1 ff ff       	call   80024b <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  8010a8:	83 c4 2c             	add    $0x2c,%esp
  8010ab:	5b                   	pop    %ebx
  8010ac:	5e                   	pop    %esi
  8010ad:	5f                   	pop    %edi
  8010ae:	5d                   	pop    %ebp
  8010af:	c3                   	ret    

008010b0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	56                   	push   %esi
  8010b4:	53                   	push   %ebx
  8010b5:	83 ec 20             	sub    $0x20,%esp
  8010b8:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8010bb:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if(!(err & FEC_WR)) {
  8010bd:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8010c1:	75 20                	jne    8010e3 <pgfault+0x33>
		panic("0x%x Not a write", addr);
  8010c3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010c7:	c7 44 24 08 0a 2f 80 	movl   $0x802f0a,0x8(%esp)
  8010ce:	00 
  8010cf:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8010d6:	00 
  8010d7:	c7 04 24 1b 2f 80 00 	movl   $0x802f1b,(%esp)
  8010de:	e8 68 f1 ff ff       	call   80024b <_panic>
	}

	if(!(uvpt[PGNUM(addr)] & PTE_COW)) {
  8010e3:	89 f0                	mov    %esi,%eax
  8010e5:	c1 e8 0c             	shr    $0xc,%eax
  8010e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ef:	f6 c4 08             	test   $0x8,%ah
  8010f2:	75 1c                	jne    801110 <pgfault+0x60>
		panic("Not a COW page");
  8010f4:	c7 44 24 08 26 2f 80 	movl   $0x802f26,0x8(%esp)
  8010fb:	00 
  8010fc:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  801103:	00 
  801104:	c7 04 24 1b 2f 80 00 	movl   $0x802f1b,(%esp)
  80110b:	e8 3b f1 ff ff       	call   80024b <_panic>

	// Allocate a new page, map it at a temporary location (PFTEMP), // copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	envid_t envid = sys_getenvid();
  801110:	e8 30 fc ff ff       	call   800d45 <sys_getenvid>
  801115:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, PFTEMP, PTE_W | PTE_U | PTE_P);
  801117:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80111e:	00 
  80111f:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801126:	00 
  801127:	89 04 24             	mov    %eax,(%esp)
  80112a:	e8 54 fc ff ff       	call   800d83 <sys_page_alloc>
	if(r < 0) {
  80112f:	85 c0                	test   %eax,%eax
  801131:	79 1c                	jns    80114f <pgfault+0x9f>
		panic("couldn't allocate page");
  801133:	c7 44 24 08 35 2f 80 	movl   $0x802f35,0x8(%esp)
  80113a:	00 
  80113b:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801142:	00 
  801143:	c7 04 24 1b 2f 80 00 	movl   $0x802f1b,(%esp)
  80114a:	e8 fc f0 ff ff       	call   80024b <_panic>
	}

	memmove(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  80114f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  801155:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80115c:	00 
  80115d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801161:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801168:	e8 97 f9 ff ff       	call   800b04 <memmove>

	r = sys_page_map(envid, PFTEMP, envid, ROUNDDOWN(addr,PGSIZE), PTE_P | PTE_U | PTE_W);
  80116d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801174:	00 
  801175:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801179:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80117d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801184:	00 
  801185:	89 1c 24             	mov    %ebx,(%esp)
  801188:	e8 4a fc ff ff       	call   800dd7 <sys_page_map>
	if(r < 0) {
  80118d:	85 c0                	test   %eax,%eax
  80118f:	79 1c                	jns    8011ad <pgfault+0xfd>
		panic("couldn't map page");
  801191:	c7 44 24 08 4c 2f 80 	movl   $0x802f4c,0x8(%esp)
  801198:	00 
  801199:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  8011a0:	00 
  8011a1:	c7 04 24 1b 2f 80 00 	movl   $0x802f1b,(%esp)
  8011a8:	e8 9e f0 ff ff       	call   80024b <_panic>
	}
}
  8011ad:	83 c4 20             	add    $0x20,%esp
  8011b0:	5b                   	pop    %ebx
  8011b1:	5e                   	pop    %esi
  8011b2:	5d                   	pop    %ebp
  8011b3:	c3                   	ret    

008011b4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
  8011b7:	57                   	push   %edi
  8011b8:	56                   	push   %esi
  8011b9:	53                   	push   %ebx
  8011ba:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envid;
	uintptr_t addr;
	int r = 0;

	set_pgfault_handler(pgfault);
  8011bd:	c7 04 24 b0 10 80 00 	movl   $0x8010b0,(%esp)
  8011c4:	e8 ad 14 00 00       	call   802676 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8011c9:	b8 07 00 00 00       	mov    $0x7,%eax
  8011ce:	cd 30                	int    $0x30
  8011d0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8011d3:	89 45 d8             	mov    %eax,-0x28(%ebp)

	envid = sys_exofork();
	if(envid == 0) {
  8011d6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8011dd:	bf 00 00 00 00       	mov    $0x0,%edi
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	75 21                	jne    801207 <fork+0x53>
		thisenv = &envs[ENVX(sys_getenvid())];
  8011e6:	e8 5a fb ff ff       	call   800d45 <sys_getenvid>
  8011eb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011f0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011f3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011f8:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8011fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801202:	e9 8d 01 00 00       	jmp    801394 <fork+0x1e0>
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
  801207:	89 f8                	mov    %edi,%eax
  801209:	c1 e8 16             	shr    $0x16,%eax
  80120c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801213:	85 c0                	test   %eax,%eax
  801215:	0f 84 02 01 00 00    	je     80131d <fork+0x169>
  80121b:	89 fa                	mov    %edi,%edx
  80121d:	c1 ea 0c             	shr    $0xc,%edx
  801220:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801227:	85 c0                	test   %eax,%eax
  801229:	0f 84 ee 00 00 00    	je     80131d <fork+0x169>
//
static int
duppage(envid_t envid, unsigned pn)
{

	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P)) return 0;
  80122f:	89 d6                	mov    %edx,%esi
  801231:	c1 e6 0c             	shl    $0xc,%esi
  801234:	89 f0                	mov    %esi,%eax
  801236:	c1 e8 16             	shr    $0x16,%eax
  801239:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  801240:	b8 00 00 00 00       	mov    $0x0,%eax
  801245:	f6 c1 01             	test   $0x1,%cl
  801248:	0f 84 cc 00 00 00    	je     80131a <fork+0x166>

	int all_perms = PTE_U | PTE_P | PTE_AVAIL | PTE_W | PTE_COW;
	int orig_perms = uvpt[pn] & all_perms;
  80124e:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  801255:	89 d8                	mov    %ebx,%eax
  801257:	25 07 0e 00 00       	and    $0xe07,%eax
  80125c:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if(!(orig_perms & PTE_P)) return 0;
  80125f:	89 d8                	mov    %ebx,%eax
  801261:	83 e0 01             	and    $0x1,%eax
  801264:	0f 84 b0 00 00 00    	je     80131a <fork+0x166>

	int r = 0;
	envid_t curenvid = sys_getenvid();
  80126a:	e8 d6 fa ff ff       	call   800d45 <sys_getenvid>
  80126f:	89 45 dc             	mov    %eax,-0x24(%ebp)


	if(orig_perms & PTE_SHARE) {
  801272:	f7 45 e0 00 04 00 00 	testl  $0x400,-0x20(%ebp)
  801279:	74 28                	je     8012a3 <fork+0xef>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms & PTE_SYSCALL));
  80127b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80127e:	25 07 0e 00 00       	and    $0xe07,%eax
  801283:	89 44 24 10          	mov    %eax,0x10(%esp)
  801287:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80128b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80128e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801292:	89 74 24 04          	mov    %esi,0x4(%esp)
  801296:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801299:	89 04 24             	mov    %eax,(%esp)
  80129c:	e8 36 fb ff ff       	call   800dd7 <sys_page_map>
  8012a1:	eb 77                	jmp    80131a <fork+0x166>

	} else if(((orig_perms) & PTE_COW) || (orig_perms & PTE_W) ) {
  8012a3:	f7 c3 02 08 00 00    	test   $0x802,%ebx
  8012a9:	74 4e                	je     8012f9 <fork+0x145>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  8012ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012ae:	25 fd f7 ff ff       	and    $0xfffff7fd,%eax
  8012b3:	80 cc 08             	or     $0x8,%ah
  8012b6:	89 c3                	mov    %eax,%ebx
  8012b8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012bc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8012c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012c7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012cb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012ce:	89 04 24             	mov    %eax,(%esp)
  8012d1:	e8 01 fb ff ff       	call   800dd7 <sys_page_map>
  8012d6:	89 45 e0             	mov    %eax,-0x20(%ebp)

		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), curenvid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  8012d9:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8012dd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012e1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8012e4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012e8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012ec:	89 0c 24             	mov    %ecx,(%esp)
  8012ef:	e8 e3 fa ff ff       	call   800dd7 <sys_page_map>
  8012f4:	03 45 e0             	add    -0x20(%ebp),%eax
  8012f7:	eb 21                	jmp    80131a <fork+0x166>

	} else {
		r = sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), orig_perms);
  8012f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012fc:	89 44 24 10          	mov    %eax,0x10(%esp)
  801300:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801304:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801307:	89 44 24 08          	mov    %eax,0x8(%esp)
  80130b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80130f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801312:	89 04 24             	mov    %eax,(%esp)
  801315:	e8 bd fa ff ff       	call   800dd7 <sys_page_map>
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
  80131a:	01 45 e4             	add    %eax,-0x1c(%ebp)
	if(envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
  80131d:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801323:	81 ff 00 f0 bf ee    	cmp    $0xeebff000,%edi
  801329:	0f 85 d8 fe ff ff    	jne    801207 <fork+0x53>
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
		}
	}

	r+=sys_page_alloc(envid, (void*)UXSTACKTOP - PGSIZE, PTE_P|PTE_U|PTE_W);
  80132f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801336:	00 
  801337:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80133e:	ee 
  80133f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801342:	89 34 24             	mov    %esi,(%esp)
  801345:	e8 39 fa ff ff       	call   800d83 <sys_page_alloc>
  80134a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80134d:	01 c3                	add    %eax,%ebx
	r+=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80134f:	c7 44 24 04 c3 26 80 	movl   $0x8026c3,0x4(%esp)
  801356:	00 
  801357:	89 34 24             	mov    %esi,(%esp)
  80135a:	e8 c4 fb ff ff       	call   800f23 <sys_env_set_pgfault_upcall>
  80135f:	01 c3                	add    %eax,%ebx
	r+= sys_env_set_status(envid, ENV_RUNNABLE);
  801361:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801368:	00 
  801369:	89 34 24             	mov    %esi,(%esp)
  80136c:	e8 0c fb ff ff       	call   800e7d <sys_env_set_status>

	if(r<0) {
  801371:	01 d8                	add    %ebx,%eax
  801373:	79 1c                	jns    801391 <fork+0x1dd>
	 panic("fork failed!");
  801375:	c7 44 24 08 5e 2f 80 	movl   $0x802f5e,0x8(%esp)
  80137c:	00 
  80137d:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  801384:	00 
  801385:	c7 04 24 1b 2f 80 00 	movl   $0x802f1b,(%esp)
  80138c:	e8 ba ee ff ff       	call   80024b <_panic>
	}

	return envid;
  801391:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  801394:	83 c4 3c             	add    $0x3c,%esp
  801397:	5b                   	pop    %ebx
  801398:	5e                   	pop    %esi
  801399:	5f                   	pop    %edi
  80139a:	5d                   	pop    %ebp
  80139b:	c3                   	ret    

0080139c <sfork>:

// Challenge!
int
sfork(void)
{
  80139c:	55                   	push   %ebp
  80139d:	89 e5                	mov    %esp,%ebp
  80139f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8013a2:	c7 44 24 08 6b 2f 80 	movl   $0x802f6b,0x8(%esp)
  8013a9:	00 
  8013aa:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
  8013b1:	00 
  8013b2:	c7 04 24 1b 2f 80 00 	movl   $0x802f1b,(%esp)
  8013b9:	e8 8d ee ff ff       	call   80024b <_panic>
  8013be:	66 90                	xchg   %ax,%ax

008013c0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c6:	05 00 00 00 30       	add    $0x30000000,%eax
  8013cb:	c1 e8 0c             	shr    $0xc,%eax
}
  8013ce:	5d                   	pop    %ebp
  8013cf:	c3                   	ret    

008013d0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8013db:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013e0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013e5:	5d                   	pop    %ebp
  8013e6:	c3                   	ret    

008013e7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013e7:	55                   	push   %ebp
  8013e8:	89 e5                	mov    %esp,%ebp
  8013ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ed:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013f2:	89 c2                	mov    %eax,%edx
  8013f4:	c1 ea 16             	shr    $0x16,%edx
  8013f7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013fe:	f6 c2 01             	test   $0x1,%dl
  801401:	74 11                	je     801414 <fd_alloc+0x2d>
  801403:	89 c2                	mov    %eax,%edx
  801405:	c1 ea 0c             	shr    $0xc,%edx
  801408:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80140f:	f6 c2 01             	test   $0x1,%dl
  801412:	75 09                	jne    80141d <fd_alloc+0x36>
			*fd_store = fd;
  801414:	89 01                	mov    %eax,(%ecx)
			return 0;
  801416:	b8 00 00 00 00       	mov    $0x0,%eax
  80141b:	eb 17                	jmp    801434 <fd_alloc+0x4d>
  80141d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801422:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801427:	75 c9                	jne    8013f2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801429:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80142f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801434:	5d                   	pop    %ebp
  801435:	c3                   	ret    

00801436 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801436:	55                   	push   %ebp
  801437:	89 e5                	mov    %esp,%ebp
  801439:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80143c:	83 f8 1f             	cmp    $0x1f,%eax
  80143f:	77 36                	ja     801477 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801441:	c1 e0 0c             	shl    $0xc,%eax
  801444:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801449:	89 c2                	mov    %eax,%edx
  80144b:	c1 ea 16             	shr    $0x16,%edx
  80144e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801455:	f6 c2 01             	test   $0x1,%dl
  801458:	74 24                	je     80147e <fd_lookup+0x48>
  80145a:	89 c2                	mov    %eax,%edx
  80145c:	c1 ea 0c             	shr    $0xc,%edx
  80145f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801466:	f6 c2 01             	test   $0x1,%dl
  801469:	74 1a                	je     801485 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80146b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80146e:	89 02                	mov    %eax,(%edx)
	return 0;
  801470:	b8 00 00 00 00       	mov    $0x0,%eax
  801475:	eb 13                	jmp    80148a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801477:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80147c:	eb 0c                	jmp    80148a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80147e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801483:	eb 05                	jmp    80148a <fd_lookup+0x54>
  801485:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80148a:	5d                   	pop    %ebp
  80148b:	c3                   	ret    

0080148c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80148c:	55                   	push   %ebp
  80148d:	89 e5                	mov    %esp,%ebp
  80148f:	83 ec 18             	sub    $0x18,%esp
  801492:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801495:	ba 00 00 00 00       	mov    $0x0,%edx
  80149a:	eb 13                	jmp    8014af <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  80149c:	39 08                	cmp    %ecx,(%eax)
  80149e:	75 0c                	jne    8014ac <dev_lookup+0x20>
			*dev = devtab[i];
  8014a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014a3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8014aa:	eb 38                	jmp    8014e4 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014ac:	83 c2 01             	add    $0x1,%edx
  8014af:	8b 04 95 00 30 80 00 	mov    0x803000(,%edx,4),%eax
  8014b6:	85 c0                	test   %eax,%eax
  8014b8:	75 e2                	jne    80149c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014ba:	a1 08 50 80 00       	mov    0x805008,%eax
  8014bf:	8b 40 48             	mov    0x48(%eax),%eax
  8014c2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ca:	c7 04 24 84 2f 80 00 	movl   $0x802f84,(%esp)
  8014d1:	e8 6e ee ff ff       	call   800344 <cprintf>
	*dev = 0;
  8014d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014e4:	c9                   	leave  
  8014e5:	c3                   	ret    

008014e6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014e6:	55                   	push   %ebp
  8014e7:	89 e5                	mov    %esp,%ebp
  8014e9:	56                   	push   %esi
  8014ea:	53                   	push   %ebx
  8014eb:	83 ec 20             	sub    $0x20,%esp
  8014ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8014f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f7:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014fb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801501:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801504:	89 04 24             	mov    %eax,(%esp)
  801507:	e8 2a ff ff ff       	call   801436 <fd_lookup>
  80150c:	85 c0                	test   %eax,%eax
  80150e:	78 05                	js     801515 <fd_close+0x2f>
	    || fd != fd2)
  801510:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801513:	74 0c                	je     801521 <fd_close+0x3b>
		return (must_exist ? r : 0);
  801515:	84 db                	test   %bl,%bl
  801517:	ba 00 00 00 00       	mov    $0x0,%edx
  80151c:	0f 44 c2             	cmove  %edx,%eax
  80151f:	eb 3f                	jmp    801560 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801521:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801524:	89 44 24 04          	mov    %eax,0x4(%esp)
  801528:	8b 06                	mov    (%esi),%eax
  80152a:	89 04 24             	mov    %eax,(%esp)
  80152d:	e8 5a ff ff ff       	call   80148c <dev_lookup>
  801532:	89 c3                	mov    %eax,%ebx
  801534:	85 c0                	test   %eax,%eax
  801536:	78 16                	js     80154e <fd_close+0x68>
		if (dev->dev_close)
  801538:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80153e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801543:	85 c0                	test   %eax,%eax
  801545:	74 07                	je     80154e <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801547:	89 34 24             	mov    %esi,(%esp)
  80154a:	ff d0                	call   *%eax
  80154c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80154e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801552:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801559:	e8 cc f8 ff ff       	call   800e2a <sys_page_unmap>
	return r;
  80155e:	89 d8                	mov    %ebx,%eax
}
  801560:	83 c4 20             	add    $0x20,%esp
  801563:	5b                   	pop    %ebx
  801564:	5e                   	pop    %esi
  801565:	5d                   	pop    %ebp
  801566:	c3                   	ret    

00801567 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801567:	55                   	push   %ebp
  801568:	89 e5                	mov    %esp,%ebp
  80156a:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80156d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801570:	89 44 24 04          	mov    %eax,0x4(%esp)
  801574:	8b 45 08             	mov    0x8(%ebp),%eax
  801577:	89 04 24             	mov    %eax,(%esp)
  80157a:	e8 b7 fe ff ff       	call   801436 <fd_lookup>
  80157f:	89 c2                	mov    %eax,%edx
  801581:	85 d2                	test   %edx,%edx
  801583:	78 13                	js     801598 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801585:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80158c:	00 
  80158d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801590:	89 04 24             	mov    %eax,(%esp)
  801593:	e8 4e ff ff ff       	call   8014e6 <fd_close>
}
  801598:	c9                   	leave  
  801599:	c3                   	ret    

0080159a <close_all>:

void
close_all(void)
{
  80159a:	55                   	push   %ebp
  80159b:	89 e5                	mov    %esp,%ebp
  80159d:	53                   	push   %ebx
  80159e:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015a1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015a6:	89 1c 24             	mov    %ebx,(%esp)
  8015a9:	e8 b9 ff ff ff       	call   801567 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015ae:	83 c3 01             	add    $0x1,%ebx
  8015b1:	83 fb 20             	cmp    $0x20,%ebx
  8015b4:	75 f0                	jne    8015a6 <close_all+0xc>
		close(i);
}
  8015b6:	83 c4 14             	add    $0x14,%esp
  8015b9:	5b                   	pop    %ebx
  8015ba:	5d                   	pop    %ebp
  8015bb:	c3                   	ret    

008015bc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015bc:	55                   	push   %ebp
  8015bd:	89 e5                	mov    %esp,%ebp
  8015bf:	57                   	push   %edi
  8015c0:	56                   	push   %esi
  8015c1:	53                   	push   %ebx
  8015c2:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015c5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8015cf:	89 04 24             	mov    %eax,(%esp)
  8015d2:	e8 5f fe ff ff       	call   801436 <fd_lookup>
  8015d7:	89 c2                	mov    %eax,%edx
  8015d9:	85 d2                	test   %edx,%edx
  8015db:	0f 88 e1 00 00 00    	js     8016c2 <dup+0x106>
		return r;
	close(newfdnum);
  8015e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015e4:	89 04 24             	mov    %eax,(%esp)
  8015e7:	e8 7b ff ff ff       	call   801567 <close>

	newfd = INDEX2FD(newfdnum);
  8015ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015ef:	c1 e3 0c             	shl    $0xc,%ebx
  8015f2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015fb:	89 04 24             	mov    %eax,(%esp)
  8015fe:	e8 cd fd ff ff       	call   8013d0 <fd2data>
  801603:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801605:	89 1c 24             	mov    %ebx,(%esp)
  801608:	e8 c3 fd ff ff       	call   8013d0 <fd2data>
  80160d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80160f:	89 f0                	mov    %esi,%eax
  801611:	c1 e8 16             	shr    $0x16,%eax
  801614:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80161b:	a8 01                	test   $0x1,%al
  80161d:	74 43                	je     801662 <dup+0xa6>
  80161f:	89 f0                	mov    %esi,%eax
  801621:	c1 e8 0c             	shr    $0xc,%eax
  801624:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80162b:	f6 c2 01             	test   $0x1,%dl
  80162e:	74 32                	je     801662 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801630:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801637:	25 07 0e 00 00       	and    $0xe07,%eax
  80163c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801640:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801644:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80164b:	00 
  80164c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801650:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801657:	e8 7b f7 ff ff       	call   800dd7 <sys_page_map>
  80165c:	89 c6                	mov    %eax,%esi
  80165e:	85 c0                	test   %eax,%eax
  801660:	78 3e                	js     8016a0 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801662:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801665:	89 c2                	mov    %eax,%edx
  801667:	c1 ea 0c             	shr    $0xc,%edx
  80166a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801671:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801677:	89 54 24 10          	mov    %edx,0x10(%esp)
  80167b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80167f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801686:	00 
  801687:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801692:	e8 40 f7 ff ff       	call   800dd7 <sys_page_map>
  801697:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801699:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80169c:	85 f6                	test   %esi,%esi
  80169e:	79 22                	jns    8016c2 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016ab:	e8 7a f7 ff ff       	call   800e2a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016b0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8016b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016bb:	e8 6a f7 ff ff       	call   800e2a <sys_page_unmap>
	return r;
  8016c0:	89 f0                	mov    %esi,%eax
}
  8016c2:	83 c4 3c             	add    $0x3c,%esp
  8016c5:	5b                   	pop    %ebx
  8016c6:	5e                   	pop    %esi
  8016c7:	5f                   	pop    %edi
  8016c8:	5d                   	pop    %ebp
  8016c9:	c3                   	ret    

008016ca <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	53                   	push   %ebx
  8016ce:	83 ec 24             	sub    $0x24,%esp
  8016d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016db:	89 1c 24             	mov    %ebx,(%esp)
  8016de:	e8 53 fd ff ff       	call   801436 <fd_lookup>
  8016e3:	89 c2                	mov    %eax,%edx
  8016e5:	85 d2                	test   %edx,%edx
  8016e7:	78 6d                	js     801756 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f3:	8b 00                	mov    (%eax),%eax
  8016f5:	89 04 24             	mov    %eax,(%esp)
  8016f8:	e8 8f fd ff ff       	call   80148c <dev_lookup>
  8016fd:	85 c0                	test   %eax,%eax
  8016ff:	78 55                	js     801756 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801701:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801704:	8b 50 08             	mov    0x8(%eax),%edx
  801707:	83 e2 03             	and    $0x3,%edx
  80170a:	83 fa 01             	cmp    $0x1,%edx
  80170d:	75 23                	jne    801732 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80170f:	a1 08 50 80 00       	mov    0x805008,%eax
  801714:	8b 40 48             	mov    0x48(%eax),%eax
  801717:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80171b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80171f:	c7 04 24 c5 2f 80 00 	movl   $0x802fc5,(%esp)
  801726:	e8 19 ec ff ff       	call   800344 <cprintf>
		return -E_INVAL;
  80172b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801730:	eb 24                	jmp    801756 <read+0x8c>
	}
	if (!dev->dev_read)
  801732:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801735:	8b 52 08             	mov    0x8(%edx),%edx
  801738:	85 d2                	test   %edx,%edx
  80173a:	74 15                	je     801751 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80173c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80173f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801743:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801746:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80174a:	89 04 24             	mov    %eax,(%esp)
  80174d:	ff d2                	call   *%edx
  80174f:	eb 05                	jmp    801756 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801751:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801756:	83 c4 24             	add    $0x24,%esp
  801759:	5b                   	pop    %ebx
  80175a:	5d                   	pop    %ebp
  80175b:	c3                   	ret    

0080175c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	57                   	push   %edi
  801760:	56                   	push   %esi
  801761:	53                   	push   %ebx
  801762:	83 ec 1c             	sub    $0x1c,%esp
  801765:	8b 7d 08             	mov    0x8(%ebp),%edi
  801768:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80176b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801770:	eb 23                	jmp    801795 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801772:	89 f0                	mov    %esi,%eax
  801774:	29 d8                	sub    %ebx,%eax
  801776:	89 44 24 08          	mov    %eax,0x8(%esp)
  80177a:	89 d8                	mov    %ebx,%eax
  80177c:	03 45 0c             	add    0xc(%ebp),%eax
  80177f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801783:	89 3c 24             	mov    %edi,(%esp)
  801786:	e8 3f ff ff ff       	call   8016ca <read>
		if (m < 0)
  80178b:	85 c0                	test   %eax,%eax
  80178d:	78 10                	js     80179f <readn+0x43>
			return m;
		if (m == 0)
  80178f:	85 c0                	test   %eax,%eax
  801791:	74 0a                	je     80179d <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801793:	01 c3                	add    %eax,%ebx
  801795:	39 f3                	cmp    %esi,%ebx
  801797:	72 d9                	jb     801772 <readn+0x16>
  801799:	89 d8                	mov    %ebx,%eax
  80179b:	eb 02                	jmp    80179f <readn+0x43>
  80179d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80179f:	83 c4 1c             	add    $0x1c,%esp
  8017a2:	5b                   	pop    %ebx
  8017a3:	5e                   	pop    %esi
  8017a4:	5f                   	pop    %edi
  8017a5:	5d                   	pop    %ebp
  8017a6:	c3                   	ret    

008017a7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017a7:	55                   	push   %ebp
  8017a8:	89 e5                	mov    %esp,%ebp
  8017aa:	53                   	push   %ebx
  8017ab:	83 ec 24             	sub    $0x24,%esp
  8017ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b8:	89 1c 24             	mov    %ebx,(%esp)
  8017bb:	e8 76 fc ff ff       	call   801436 <fd_lookup>
  8017c0:	89 c2                	mov    %eax,%edx
  8017c2:	85 d2                	test   %edx,%edx
  8017c4:	78 68                	js     80182e <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d0:	8b 00                	mov    (%eax),%eax
  8017d2:	89 04 24             	mov    %eax,(%esp)
  8017d5:	e8 b2 fc ff ff       	call   80148c <dev_lookup>
  8017da:	85 c0                	test   %eax,%eax
  8017dc:	78 50                	js     80182e <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017e5:	75 23                	jne    80180a <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017e7:	a1 08 50 80 00       	mov    0x805008,%eax
  8017ec:	8b 40 48             	mov    0x48(%eax),%eax
  8017ef:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f7:	c7 04 24 e1 2f 80 00 	movl   $0x802fe1,(%esp)
  8017fe:	e8 41 eb ff ff       	call   800344 <cprintf>
		return -E_INVAL;
  801803:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801808:	eb 24                	jmp    80182e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80180a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80180d:	8b 52 0c             	mov    0xc(%edx),%edx
  801810:	85 d2                	test   %edx,%edx
  801812:	74 15                	je     801829 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801814:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801817:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80181b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80181e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801822:	89 04 24             	mov    %eax,(%esp)
  801825:	ff d2                	call   *%edx
  801827:	eb 05                	jmp    80182e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801829:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80182e:	83 c4 24             	add    $0x24,%esp
  801831:	5b                   	pop    %ebx
  801832:	5d                   	pop    %ebp
  801833:	c3                   	ret    

00801834 <seek>:

int
seek(int fdnum, off_t offset)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80183a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80183d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801841:	8b 45 08             	mov    0x8(%ebp),%eax
  801844:	89 04 24             	mov    %eax,(%esp)
  801847:	e8 ea fb ff ff       	call   801436 <fd_lookup>
  80184c:	85 c0                	test   %eax,%eax
  80184e:	78 0e                	js     80185e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801850:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801853:	8b 55 0c             	mov    0xc(%ebp),%edx
  801856:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801859:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80185e:	c9                   	leave  
  80185f:	c3                   	ret    

00801860 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	53                   	push   %ebx
  801864:	83 ec 24             	sub    $0x24,%esp
  801867:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80186a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80186d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801871:	89 1c 24             	mov    %ebx,(%esp)
  801874:	e8 bd fb ff ff       	call   801436 <fd_lookup>
  801879:	89 c2                	mov    %eax,%edx
  80187b:	85 d2                	test   %edx,%edx
  80187d:	78 61                	js     8018e0 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80187f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801882:	89 44 24 04          	mov    %eax,0x4(%esp)
  801886:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801889:	8b 00                	mov    (%eax),%eax
  80188b:	89 04 24             	mov    %eax,(%esp)
  80188e:	e8 f9 fb ff ff       	call   80148c <dev_lookup>
  801893:	85 c0                	test   %eax,%eax
  801895:	78 49                	js     8018e0 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801897:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80189e:	75 23                	jne    8018c3 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018a0:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018a5:	8b 40 48             	mov    0x48(%eax),%eax
  8018a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b0:	c7 04 24 a4 2f 80 00 	movl   $0x802fa4,(%esp)
  8018b7:	e8 88 ea ff ff       	call   800344 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018c1:	eb 1d                	jmp    8018e0 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8018c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c6:	8b 52 18             	mov    0x18(%edx),%edx
  8018c9:	85 d2                	test   %edx,%edx
  8018cb:	74 0e                	je     8018db <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018d0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018d4:	89 04 24             	mov    %eax,(%esp)
  8018d7:	ff d2                	call   *%edx
  8018d9:	eb 05                	jmp    8018e0 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018db:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8018e0:	83 c4 24             	add    $0x24,%esp
  8018e3:	5b                   	pop    %ebx
  8018e4:	5d                   	pop    %ebp
  8018e5:	c3                   	ret    

008018e6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018e6:	55                   	push   %ebp
  8018e7:	89 e5                	mov    %esp,%ebp
  8018e9:	53                   	push   %ebx
  8018ea:	83 ec 24             	sub    $0x24,%esp
  8018ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fa:	89 04 24             	mov    %eax,(%esp)
  8018fd:	e8 34 fb ff ff       	call   801436 <fd_lookup>
  801902:	89 c2                	mov    %eax,%edx
  801904:	85 d2                	test   %edx,%edx
  801906:	78 52                	js     80195a <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801908:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801912:	8b 00                	mov    (%eax),%eax
  801914:	89 04 24             	mov    %eax,(%esp)
  801917:	e8 70 fb ff ff       	call   80148c <dev_lookup>
  80191c:	85 c0                	test   %eax,%eax
  80191e:	78 3a                	js     80195a <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801920:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801923:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801927:	74 2c                	je     801955 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801929:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80192c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801933:	00 00 00 
	stat->st_isdir = 0;
  801936:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80193d:	00 00 00 
	stat->st_dev = dev;
  801940:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801946:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80194a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80194d:	89 14 24             	mov    %edx,(%esp)
  801950:	ff 50 14             	call   *0x14(%eax)
  801953:	eb 05                	jmp    80195a <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801955:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80195a:	83 c4 24             	add    $0x24,%esp
  80195d:	5b                   	pop    %ebx
  80195e:	5d                   	pop    %ebp
  80195f:	c3                   	ret    

00801960 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801960:	55                   	push   %ebp
  801961:	89 e5                	mov    %esp,%ebp
  801963:	56                   	push   %esi
  801964:	53                   	push   %ebx
  801965:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801968:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80196f:	00 
  801970:	8b 45 08             	mov    0x8(%ebp),%eax
  801973:	89 04 24             	mov    %eax,(%esp)
  801976:	e8 28 02 00 00       	call   801ba3 <open>
  80197b:	89 c3                	mov    %eax,%ebx
  80197d:	85 db                	test   %ebx,%ebx
  80197f:	78 1b                	js     80199c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801981:	8b 45 0c             	mov    0xc(%ebp),%eax
  801984:	89 44 24 04          	mov    %eax,0x4(%esp)
  801988:	89 1c 24             	mov    %ebx,(%esp)
  80198b:	e8 56 ff ff ff       	call   8018e6 <fstat>
  801990:	89 c6                	mov    %eax,%esi
	close(fd);
  801992:	89 1c 24             	mov    %ebx,(%esp)
  801995:	e8 cd fb ff ff       	call   801567 <close>
	return r;
  80199a:	89 f0                	mov    %esi,%eax
}
  80199c:	83 c4 10             	add    $0x10,%esp
  80199f:	5b                   	pop    %ebx
  8019a0:	5e                   	pop    %esi
  8019a1:	5d                   	pop    %ebp
  8019a2:	c3                   	ret    

008019a3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	56                   	push   %esi
  8019a7:	53                   	push   %ebx
  8019a8:	83 ec 10             	sub    $0x10,%esp
  8019ab:	89 c6                	mov    %eax,%esi
  8019ad:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019af:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8019b6:	75 11                	jne    8019c9 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019b8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8019bf:	e8 11 0e 00 00       	call   8027d5 <ipc_find_env>
  8019c4:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019c9:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8019d0:	00 
  8019d1:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8019d8:	00 
  8019d9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019dd:	a1 00 50 80 00       	mov    0x805000,%eax
  8019e2:	89 04 24             	mov    %eax,(%esp)
  8019e5:	e8 80 0d 00 00       	call   80276a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019ea:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019f1:	00 
  8019f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019fd:	e8 ee 0c 00 00       	call   8026f0 <ipc_recv>
}
  801a02:	83 c4 10             	add    $0x10,%esp
  801a05:	5b                   	pop    %ebx
  801a06:	5e                   	pop    %esi
  801a07:	5d                   	pop    %ebp
  801a08:	c3                   	ret    

00801a09 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a09:	55                   	push   %ebp
  801a0a:	89 e5                	mov    %esp,%ebp
  801a0c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a12:	8b 40 0c             	mov    0xc(%eax),%eax
  801a15:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801a1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1d:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a22:	ba 00 00 00 00       	mov    $0x0,%edx
  801a27:	b8 02 00 00 00       	mov    $0x2,%eax
  801a2c:	e8 72 ff ff ff       	call   8019a3 <fsipc>
}
  801a31:	c9                   	leave  
  801a32:	c3                   	ret    

00801a33 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a39:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3c:	8b 40 0c             	mov    0xc(%eax),%eax
  801a3f:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801a44:	ba 00 00 00 00       	mov    $0x0,%edx
  801a49:	b8 06 00 00 00       	mov    $0x6,%eax
  801a4e:	e8 50 ff ff ff       	call   8019a3 <fsipc>
}
  801a53:	c9                   	leave  
  801a54:	c3                   	ret    

00801a55 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a55:	55                   	push   %ebp
  801a56:	89 e5                	mov    %esp,%ebp
  801a58:	53                   	push   %ebx
  801a59:	83 ec 14             	sub    $0x14,%esp
  801a5c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a62:	8b 40 0c             	mov    0xc(%eax),%eax
  801a65:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a6a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6f:	b8 05 00 00 00       	mov    $0x5,%eax
  801a74:	e8 2a ff ff ff       	call   8019a3 <fsipc>
  801a79:	89 c2                	mov    %eax,%edx
  801a7b:	85 d2                	test   %edx,%edx
  801a7d:	78 2b                	js     801aaa <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a7f:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801a86:	00 
  801a87:	89 1c 24             	mov    %ebx,(%esp)
  801a8a:	e8 d8 ee ff ff       	call   800967 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a8f:	a1 80 60 80 00       	mov    0x806080,%eax
  801a94:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a9a:	a1 84 60 80 00       	mov    0x806084,%eax
  801a9f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801aa5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aaa:	83 c4 14             	add    $0x14,%esp
  801aad:	5b                   	pop    %ebx
  801aae:	5d                   	pop    %ebp
  801aaf:	c3                   	ret    

00801ab0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
  801ab3:	83 ec 18             	sub    $0x18,%esp
  801ab6:	8b 45 10             	mov    0x10(%ebp),%eax
  801ab9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801abe:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801ac3:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ac6:	8b 55 08             	mov    0x8(%ebp),%edx
  801ac9:	8b 52 0c             	mov    0xc(%edx),%edx
  801acc:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801ad2:	a3 04 60 80 00       	mov    %eax,0x806004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801ad7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801adb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ade:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae2:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801ae9:	e8 16 f0 ff ff       	call   800b04 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  801aee:	ba 00 00 00 00       	mov    $0x0,%edx
  801af3:	b8 04 00 00 00       	mov    $0x4,%eax
  801af8:	e8 a6 fe ff ff       	call   8019a3 <fsipc>
}
  801afd:	c9                   	leave  
  801afe:	c3                   	ret    

00801aff <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	56                   	push   %esi
  801b03:	53                   	push   %ebx
  801b04:	83 ec 10             	sub    $0x10,%esp
  801b07:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0d:	8b 40 0c             	mov    0xc(%eax),%eax
  801b10:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b15:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b20:	b8 03 00 00 00       	mov    $0x3,%eax
  801b25:	e8 79 fe ff ff       	call   8019a3 <fsipc>
  801b2a:	89 c3                	mov    %eax,%ebx
  801b2c:	85 c0                	test   %eax,%eax
  801b2e:	78 6a                	js     801b9a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801b30:	39 c6                	cmp    %eax,%esi
  801b32:	73 24                	jae    801b58 <devfile_read+0x59>
  801b34:	c7 44 24 0c 14 30 80 	movl   $0x803014,0xc(%esp)
  801b3b:	00 
  801b3c:	c7 44 24 08 1b 30 80 	movl   $0x80301b,0x8(%esp)
  801b43:	00 
  801b44:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801b4b:	00 
  801b4c:	c7 04 24 30 30 80 00 	movl   $0x803030,(%esp)
  801b53:	e8 f3 e6 ff ff       	call   80024b <_panic>
	assert(r <= PGSIZE);
  801b58:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b5d:	7e 24                	jle    801b83 <devfile_read+0x84>
  801b5f:	c7 44 24 0c 3b 30 80 	movl   $0x80303b,0xc(%esp)
  801b66:	00 
  801b67:	c7 44 24 08 1b 30 80 	movl   $0x80301b,0x8(%esp)
  801b6e:	00 
  801b6f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801b76:	00 
  801b77:	c7 04 24 30 30 80 00 	movl   $0x803030,(%esp)
  801b7e:	e8 c8 e6 ff ff       	call   80024b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b83:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b87:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801b8e:	00 
  801b8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b92:	89 04 24             	mov    %eax,(%esp)
  801b95:	e8 6a ef ff ff       	call   800b04 <memmove>
	return r;
}
  801b9a:	89 d8                	mov    %ebx,%eax
  801b9c:	83 c4 10             	add    $0x10,%esp
  801b9f:	5b                   	pop    %ebx
  801ba0:	5e                   	pop    %esi
  801ba1:	5d                   	pop    %ebp
  801ba2:	c3                   	ret    

00801ba3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ba3:	55                   	push   %ebp
  801ba4:	89 e5                	mov    %esp,%ebp
  801ba6:	53                   	push   %ebx
  801ba7:	83 ec 24             	sub    $0x24,%esp
  801baa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bad:	89 1c 24             	mov    %ebx,(%esp)
  801bb0:	e8 7b ed ff ff       	call   800930 <strlen>
  801bb5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bba:	7f 60                	jg     801c1c <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bbf:	89 04 24             	mov    %eax,(%esp)
  801bc2:	e8 20 f8 ff ff       	call   8013e7 <fd_alloc>
  801bc7:	89 c2                	mov    %eax,%edx
  801bc9:	85 d2                	test   %edx,%edx
  801bcb:	78 54                	js     801c21 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bcd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bd1:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801bd8:	e8 8a ed ff ff       	call   800967 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bdd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be0:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801be5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801be8:	b8 01 00 00 00       	mov    $0x1,%eax
  801bed:	e8 b1 fd ff ff       	call   8019a3 <fsipc>
  801bf2:	89 c3                	mov    %eax,%ebx
  801bf4:	85 c0                	test   %eax,%eax
  801bf6:	79 17                	jns    801c0f <open+0x6c>
		fd_close(fd, 0);
  801bf8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bff:	00 
  801c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c03:	89 04 24             	mov    %eax,(%esp)
  801c06:	e8 db f8 ff ff       	call   8014e6 <fd_close>
		return r;
  801c0b:	89 d8                	mov    %ebx,%eax
  801c0d:	eb 12                	jmp    801c21 <open+0x7e>
	}

	return fd2num(fd);
  801c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c12:	89 04 24             	mov    %eax,(%esp)
  801c15:	e8 a6 f7 ff ff       	call   8013c0 <fd2num>
  801c1a:	eb 05                	jmp    801c21 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c1c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c21:	83 c4 24             	add    $0x24,%esp
  801c24:	5b                   	pop    %ebx
  801c25:	5d                   	pop    %ebp
  801c26:	c3                   	ret    

00801c27 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c27:	55                   	push   %ebp
  801c28:	89 e5                	mov    %esp,%ebp
  801c2a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c2d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c32:	b8 08 00 00 00       	mov    $0x8,%eax
  801c37:	e8 67 fd ff ff       	call   8019a3 <fsipc>
}
  801c3c:	c9                   	leave  
  801c3d:	c3                   	ret    
  801c3e:	66 90                	xchg   %ax,%ax

00801c40 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801c46:	c7 44 24 04 47 30 80 	movl   $0x803047,0x4(%esp)
  801c4d:	00 
  801c4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c51:	89 04 24             	mov    %eax,(%esp)
  801c54:	e8 0e ed ff ff       	call   800967 <strcpy>
	return 0;
}
  801c59:	b8 00 00 00 00       	mov    $0x0,%eax
  801c5e:	c9                   	leave  
  801c5f:	c3                   	ret    

00801c60 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c60:	55                   	push   %ebp
  801c61:	89 e5                	mov    %esp,%ebp
  801c63:	53                   	push   %ebx
  801c64:	83 ec 14             	sub    $0x14,%esp
  801c67:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c6a:	89 1c 24             	mov    %ebx,(%esp)
  801c6d:	e8 9b 0b 00 00       	call   80280d <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801c72:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801c77:	83 f8 01             	cmp    $0x1,%eax
  801c7a:	75 0d                	jne    801c89 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801c7c:	8b 43 0c             	mov    0xc(%ebx),%eax
  801c7f:	89 04 24             	mov    %eax,(%esp)
  801c82:	e8 29 03 00 00       	call   801fb0 <nsipc_close>
  801c87:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  801c89:	89 d0                	mov    %edx,%eax
  801c8b:	83 c4 14             	add    $0x14,%esp
  801c8e:	5b                   	pop    %ebx
  801c8f:	5d                   	pop    %ebp
  801c90:	c3                   	ret    

00801c91 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
  801c94:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c97:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801c9e:	00 
  801c9f:	8b 45 10             	mov    0x10(%ebp),%eax
  801ca2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ca6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ca9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cad:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb0:	8b 40 0c             	mov    0xc(%eax),%eax
  801cb3:	89 04 24             	mov    %eax,(%esp)
  801cb6:	e8 f0 03 00 00       	call   8020ab <nsipc_send>
}
  801cbb:	c9                   	leave  
  801cbc:	c3                   	ret    

00801cbd <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801cbd:	55                   	push   %ebp
  801cbe:	89 e5                	mov    %esp,%ebp
  801cc0:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801cc3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801cca:	00 
  801ccb:	8b 45 10             	mov    0x10(%ebp),%eax
  801cce:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdc:	8b 40 0c             	mov    0xc(%eax),%eax
  801cdf:	89 04 24             	mov    %eax,(%esp)
  801ce2:	e8 44 03 00 00       	call   80202b <nsipc_recv>
}
  801ce7:	c9                   	leave  
  801ce8:	c3                   	ret    

00801ce9 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801ce9:	55                   	push   %ebp
  801cea:	89 e5                	mov    %esp,%ebp
  801cec:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801cef:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801cf2:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cf6:	89 04 24             	mov    %eax,(%esp)
  801cf9:	e8 38 f7 ff ff       	call   801436 <fd_lookup>
  801cfe:	85 c0                	test   %eax,%eax
  801d00:	78 17                	js     801d19 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d05:	8b 0d 20 40 80 00    	mov    0x804020,%ecx
  801d0b:	39 08                	cmp    %ecx,(%eax)
  801d0d:	75 05                	jne    801d14 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d0f:	8b 40 0c             	mov    0xc(%eax),%eax
  801d12:	eb 05                	jmp    801d19 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d14:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d19:	c9                   	leave  
  801d1a:	c3                   	ret    

00801d1b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	56                   	push   %esi
  801d1f:	53                   	push   %ebx
  801d20:	83 ec 20             	sub    $0x20,%esp
  801d23:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801d25:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d28:	89 04 24             	mov    %eax,(%esp)
  801d2b:	e8 b7 f6 ff ff       	call   8013e7 <fd_alloc>
  801d30:	89 c3                	mov    %eax,%ebx
  801d32:	85 c0                	test   %eax,%eax
  801d34:	78 21                	js     801d57 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d36:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d3d:	00 
  801d3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d41:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d45:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d4c:	e8 32 f0 ff ff       	call   800d83 <sys_page_alloc>
  801d51:	89 c3                	mov    %eax,%ebx
  801d53:	85 c0                	test   %eax,%eax
  801d55:	79 0c                	jns    801d63 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  801d57:	89 34 24             	mov    %esi,(%esp)
  801d5a:	e8 51 02 00 00       	call   801fb0 <nsipc_close>
		return r;
  801d5f:	89 d8                	mov    %ebx,%eax
  801d61:	eb 20                	jmp    801d83 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d63:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801d69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d71:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801d78:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801d7b:	89 14 24             	mov    %edx,(%esp)
  801d7e:	e8 3d f6 ff ff       	call   8013c0 <fd2num>
}
  801d83:	83 c4 20             	add    $0x20,%esp
  801d86:	5b                   	pop    %ebx
  801d87:	5e                   	pop    %esi
  801d88:	5d                   	pop    %ebp
  801d89:	c3                   	ret    

00801d8a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d8a:	55                   	push   %ebp
  801d8b:	89 e5                	mov    %esp,%ebp
  801d8d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d90:	8b 45 08             	mov    0x8(%ebp),%eax
  801d93:	e8 51 ff ff ff       	call   801ce9 <fd2sockid>
		return r;
  801d98:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d9a:	85 c0                	test   %eax,%eax
  801d9c:	78 23                	js     801dc1 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d9e:	8b 55 10             	mov    0x10(%ebp),%edx
  801da1:	89 54 24 08          	mov    %edx,0x8(%esp)
  801da5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801da8:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dac:	89 04 24             	mov    %eax,(%esp)
  801daf:	e8 45 01 00 00       	call   801ef9 <nsipc_accept>
		return r;
  801db4:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801db6:	85 c0                	test   %eax,%eax
  801db8:	78 07                	js     801dc1 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  801dba:	e8 5c ff ff ff       	call   801d1b <alloc_sockfd>
  801dbf:	89 c1                	mov    %eax,%ecx
}
  801dc1:	89 c8                	mov    %ecx,%eax
  801dc3:	c9                   	leave  
  801dc4:	c3                   	ret    

00801dc5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
  801dc8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dcb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dce:	e8 16 ff ff ff       	call   801ce9 <fd2sockid>
  801dd3:	89 c2                	mov    %eax,%edx
  801dd5:	85 d2                	test   %edx,%edx
  801dd7:	78 16                	js     801def <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  801dd9:	8b 45 10             	mov    0x10(%ebp),%eax
  801ddc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801de0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801de7:	89 14 24             	mov    %edx,(%esp)
  801dea:	e8 60 01 00 00       	call   801f4f <nsipc_bind>
}
  801def:	c9                   	leave  
  801df0:	c3                   	ret    

00801df1 <shutdown>:

int
shutdown(int s, int how)
{
  801df1:	55                   	push   %ebp
  801df2:	89 e5                	mov    %esp,%ebp
  801df4:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801df7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfa:	e8 ea fe ff ff       	call   801ce9 <fd2sockid>
  801dff:	89 c2                	mov    %eax,%edx
  801e01:	85 d2                	test   %edx,%edx
  801e03:	78 0f                	js     801e14 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801e05:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e08:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e0c:	89 14 24             	mov    %edx,(%esp)
  801e0f:	e8 7a 01 00 00       	call   801f8e <nsipc_shutdown>
}
  801e14:	c9                   	leave  
  801e15:	c3                   	ret    

00801e16 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e16:	55                   	push   %ebp
  801e17:	89 e5                	mov    %esp,%ebp
  801e19:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1f:	e8 c5 fe ff ff       	call   801ce9 <fd2sockid>
  801e24:	89 c2                	mov    %eax,%edx
  801e26:	85 d2                	test   %edx,%edx
  801e28:	78 16                	js     801e40 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  801e2a:	8b 45 10             	mov    0x10(%ebp),%eax
  801e2d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e31:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e34:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e38:	89 14 24             	mov    %edx,(%esp)
  801e3b:	e8 8a 01 00 00       	call   801fca <nsipc_connect>
}
  801e40:	c9                   	leave  
  801e41:	c3                   	ret    

00801e42 <listen>:

int
listen(int s, int backlog)
{
  801e42:	55                   	push   %ebp
  801e43:	89 e5                	mov    %esp,%ebp
  801e45:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e48:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4b:	e8 99 fe ff ff       	call   801ce9 <fd2sockid>
  801e50:	89 c2                	mov    %eax,%edx
  801e52:	85 d2                	test   %edx,%edx
  801e54:	78 0f                	js     801e65 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801e56:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e59:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e5d:	89 14 24             	mov    %edx,(%esp)
  801e60:	e8 a4 01 00 00       	call   802009 <nsipc_listen>
}
  801e65:	c9                   	leave  
  801e66:	c3                   	ret    

00801e67 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e67:	55                   	push   %ebp
  801e68:	89 e5                	mov    %esp,%ebp
  801e6a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e6d:	8b 45 10             	mov    0x10(%ebp),%eax
  801e70:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e74:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e77:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7e:	89 04 24             	mov    %eax,(%esp)
  801e81:	e8 98 02 00 00       	call   80211e <nsipc_socket>
  801e86:	89 c2                	mov    %eax,%edx
  801e88:	85 d2                	test   %edx,%edx
  801e8a:	78 05                	js     801e91 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  801e8c:	e8 8a fe ff ff       	call   801d1b <alloc_sockfd>
}
  801e91:	c9                   	leave  
  801e92:	c3                   	ret    

00801e93 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e93:	55                   	push   %ebp
  801e94:	89 e5                	mov    %esp,%ebp
  801e96:	53                   	push   %ebx
  801e97:	83 ec 14             	sub    $0x14,%esp
  801e9a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801e9c:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801ea3:	75 11                	jne    801eb6 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801ea5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801eac:	e8 24 09 00 00       	call   8027d5 <ipc_find_env>
  801eb1:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801eb6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801ebd:	00 
  801ebe:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801ec5:	00 
  801ec6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801eca:	a1 04 50 80 00       	mov    0x805004,%eax
  801ecf:	89 04 24             	mov    %eax,(%esp)
  801ed2:	e8 93 08 00 00       	call   80276a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ed7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ede:	00 
  801edf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ee6:	00 
  801ee7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eee:	e8 fd 07 00 00       	call   8026f0 <ipc_recv>
}
  801ef3:	83 c4 14             	add    $0x14,%esp
  801ef6:	5b                   	pop    %ebx
  801ef7:	5d                   	pop    %ebp
  801ef8:	c3                   	ret    

00801ef9 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ef9:	55                   	push   %ebp
  801efa:	89 e5                	mov    %esp,%ebp
  801efc:	56                   	push   %esi
  801efd:	53                   	push   %ebx
  801efe:	83 ec 10             	sub    $0x10,%esp
  801f01:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801f04:	8b 45 08             	mov    0x8(%ebp),%eax
  801f07:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801f0c:	8b 06                	mov    (%esi),%eax
  801f0e:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f13:	b8 01 00 00 00       	mov    $0x1,%eax
  801f18:	e8 76 ff ff ff       	call   801e93 <nsipc>
  801f1d:	89 c3                	mov    %eax,%ebx
  801f1f:	85 c0                	test   %eax,%eax
  801f21:	78 23                	js     801f46 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f23:	a1 10 70 80 00       	mov    0x807010,%eax
  801f28:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f2c:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801f33:	00 
  801f34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f37:	89 04 24             	mov    %eax,(%esp)
  801f3a:	e8 c5 eb ff ff       	call   800b04 <memmove>
		*addrlen = ret->ret_addrlen;
  801f3f:	a1 10 70 80 00       	mov    0x807010,%eax
  801f44:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801f46:	89 d8                	mov    %ebx,%eax
  801f48:	83 c4 10             	add    $0x10,%esp
  801f4b:	5b                   	pop    %ebx
  801f4c:	5e                   	pop    %esi
  801f4d:	5d                   	pop    %ebp
  801f4e:	c3                   	ret    

00801f4f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f4f:	55                   	push   %ebp
  801f50:	89 e5                	mov    %esp,%ebp
  801f52:	53                   	push   %ebx
  801f53:	83 ec 14             	sub    $0x14,%esp
  801f56:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f59:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5c:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f61:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f65:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f68:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f6c:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  801f73:	e8 8c eb ff ff       	call   800b04 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f78:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801f7e:	b8 02 00 00 00       	mov    $0x2,%eax
  801f83:	e8 0b ff ff ff       	call   801e93 <nsipc>
}
  801f88:	83 c4 14             	add    $0x14,%esp
  801f8b:	5b                   	pop    %ebx
  801f8c:	5d                   	pop    %ebp
  801f8d:	c3                   	ret    

00801f8e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f8e:	55                   	push   %ebp
  801f8f:	89 e5                	mov    %esp,%ebp
  801f91:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f94:	8b 45 08             	mov    0x8(%ebp),%eax
  801f97:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801f9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f9f:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801fa4:	b8 03 00 00 00       	mov    $0x3,%eax
  801fa9:	e8 e5 fe ff ff       	call   801e93 <nsipc>
}
  801fae:	c9                   	leave  
  801faf:	c3                   	ret    

00801fb0 <nsipc_close>:

int
nsipc_close(int s)
{
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
  801fb3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801fb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb9:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801fbe:	b8 04 00 00 00       	mov    $0x4,%eax
  801fc3:	e8 cb fe ff ff       	call   801e93 <nsipc>
}
  801fc8:	c9                   	leave  
  801fc9:	c3                   	ret    

00801fca <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801fca:	55                   	push   %ebp
  801fcb:	89 e5                	mov    %esp,%ebp
  801fcd:	53                   	push   %ebx
  801fce:	83 ec 14             	sub    $0x14,%esp
  801fd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801fd4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd7:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801fdc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fe0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fe3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe7:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  801fee:	e8 11 eb ff ff       	call   800b04 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ff3:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801ff9:	b8 05 00 00 00       	mov    $0x5,%eax
  801ffe:	e8 90 fe ff ff       	call   801e93 <nsipc>
}
  802003:	83 c4 14             	add    $0x14,%esp
  802006:	5b                   	pop    %ebx
  802007:	5d                   	pop    %ebp
  802008:	c3                   	ret    

00802009 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802009:	55                   	push   %ebp
  80200a:	89 e5                	mov    %esp,%ebp
  80200c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80200f:	8b 45 08             	mov    0x8(%ebp),%eax
  802012:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802017:	8b 45 0c             	mov    0xc(%ebp),%eax
  80201a:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  80201f:	b8 06 00 00 00       	mov    $0x6,%eax
  802024:	e8 6a fe ff ff       	call   801e93 <nsipc>
}
  802029:	c9                   	leave  
  80202a:	c3                   	ret    

0080202b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80202b:	55                   	push   %ebp
  80202c:	89 e5                	mov    %esp,%ebp
  80202e:	56                   	push   %esi
  80202f:	53                   	push   %ebx
  802030:	83 ec 10             	sub    $0x10,%esp
  802033:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802036:	8b 45 08             	mov    0x8(%ebp),%eax
  802039:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  80203e:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802044:	8b 45 14             	mov    0x14(%ebp),%eax
  802047:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80204c:	b8 07 00 00 00       	mov    $0x7,%eax
  802051:	e8 3d fe ff ff       	call   801e93 <nsipc>
  802056:	89 c3                	mov    %eax,%ebx
  802058:	85 c0                	test   %eax,%eax
  80205a:	78 46                	js     8020a2 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  80205c:	39 f0                	cmp    %esi,%eax
  80205e:	7f 07                	jg     802067 <nsipc_recv+0x3c>
  802060:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802065:	7e 24                	jle    80208b <nsipc_recv+0x60>
  802067:	c7 44 24 0c 53 30 80 	movl   $0x803053,0xc(%esp)
  80206e:	00 
  80206f:	c7 44 24 08 1b 30 80 	movl   $0x80301b,0x8(%esp)
  802076:	00 
  802077:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80207e:	00 
  80207f:	c7 04 24 68 30 80 00 	movl   $0x803068,(%esp)
  802086:	e8 c0 e1 ff ff       	call   80024b <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80208b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80208f:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802096:	00 
  802097:	8b 45 0c             	mov    0xc(%ebp),%eax
  80209a:	89 04 24             	mov    %eax,(%esp)
  80209d:	e8 62 ea ff ff       	call   800b04 <memmove>
	}

	return r;
}
  8020a2:	89 d8                	mov    %ebx,%eax
  8020a4:	83 c4 10             	add    $0x10,%esp
  8020a7:	5b                   	pop    %ebx
  8020a8:	5e                   	pop    %esi
  8020a9:	5d                   	pop    %ebp
  8020aa:	c3                   	ret    

008020ab <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8020ab:	55                   	push   %ebp
  8020ac:	89 e5                	mov    %esp,%ebp
  8020ae:	53                   	push   %ebx
  8020af:	83 ec 14             	sub    $0x14,%esp
  8020b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8020b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b8:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8020bd:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8020c3:	7e 24                	jle    8020e9 <nsipc_send+0x3e>
  8020c5:	c7 44 24 0c 74 30 80 	movl   $0x803074,0xc(%esp)
  8020cc:	00 
  8020cd:	c7 44 24 08 1b 30 80 	movl   $0x80301b,0x8(%esp)
  8020d4:	00 
  8020d5:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8020dc:	00 
  8020dd:	c7 04 24 68 30 80 00 	movl   $0x803068,(%esp)
  8020e4:	e8 62 e1 ff ff       	call   80024b <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8020e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020f4:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  8020fb:	e8 04 ea ff ff       	call   800b04 <memmove>
	nsipcbuf.send.req_size = size;
  802100:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802106:	8b 45 14             	mov    0x14(%ebp),%eax
  802109:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  80210e:	b8 08 00 00 00       	mov    $0x8,%eax
  802113:	e8 7b fd ff ff       	call   801e93 <nsipc>
}
  802118:	83 c4 14             	add    $0x14,%esp
  80211b:	5b                   	pop    %ebx
  80211c:	5d                   	pop    %ebp
  80211d:	c3                   	ret    

0080211e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80211e:	55                   	push   %ebp
  80211f:	89 e5                	mov    %esp,%ebp
  802121:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802124:	8b 45 08             	mov    0x8(%ebp),%eax
  802127:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  80212c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80212f:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802134:	8b 45 10             	mov    0x10(%ebp),%eax
  802137:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  80213c:	b8 09 00 00 00       	mov    $0x9,%eax
  802141:	e8 4d fd ff ff       	call   801e93 <nsipc>
}
  802146:	c9                   	leave  
  802147:	c3                   	ret    

00802148 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802148:	55                   	push   %ebp
  802149:	89 e5                	mov    %esp,%ebp
  80214b:	56                   	push   %esi
  80214c:	53                   	push   %ebx
  80214d:	83 ec 10             	sub    $0x10,%esp
  802150:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802153:	8b 45 08             	mov    0x8(%ebp),%eax
  802156:	89 04 24             	mov    %eax,(%esp)
  802159:	e8 72 f2 ff ff       	call   8013d0 <fd2data>
  80215e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802160:	c7 44 24 04 80 30 80 	movl   $0x803080,0x4(%esp)
  802167:	00 
  802168:	89 1c 24             	mov    %ebx,(%esp)
  80216b:	e8 f7 e7 ff ff       	call   800967 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802170:	8b 46 04             	mov    0x4(%esi),%eax
  802173:	2b 06                	sub    (%esi),%eax
  802175:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80217b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802182:	00 00 00 
	stat->st_dev = &devpipe;
  802185:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  80218c:	40 80 00 
	return 0;
}
  80218f:	b8 00 00 00 00       	mov    $0x0,%eax
  802194:	83 c4 10             	add    $0x10,%esp
  802197:	5b                   	pop    %ebx
  802198:	5e                   	pop    %esi
  802199:	5d                   	pop    %ebp
  80219a:	c3                   	ret    

0080219b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80219b:	55                   	push   %ebp
  80219c:	89 e5                	mov    %esp,%ebp
  80219e:	53                   	push   %ebx
  80219f:	83 ec 14             	sub    $0x14,%esp
  8021a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8021a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021b0:	e8 75 ec ff ff       	call   800e2a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8021b5:	89 1c 24             	mov    %ebx,(%esp)
  8021b8:	e8 13 f2 ff ff       	call   8013d0 <fd2data>
  8021bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021c8:	e8 5d ec ff ff       	call   800e2a <sys_page_unmap>
}
  8021cd:	83 c4 14             	add    $0x14,%esp
  8021d0:	5b                   	pop    %ebx
  8021d1:	5d                   	pop    %ebp
  8021d2:	c3                   	ret    

008021d3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8021d3:	55                   	push   %ebp
  8021d4:	89 e5                	mov    %esp,%ebp
  8021d6:	57                   	push   %edi
  8021d7:	56                   	push   %esi
  8021d8:	53                   	push   %ebx
  8021d9:	83 ec 2c             	sub    $0x2c,%esp
  8021dc:	89 c6                	mov    %eax,%esi
  8021de:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8021e1:	a1 08 50 80 00       	mov    0x805008,%eax
  8021e6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8021e9:	89 34 24             	mov    %esi,(%esp)
  8021ec:	e8 1c 06 00 00       	call   80280d <pageref>
  8021f1:	89 c7                	mov    %eax,%edi
  8021f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021f6:	89 04 24             	mov    %eax,(%esp)
  8021f9:	e8 0f 06 00 00       	call   80280d <pageref>
  8021fe:	39 c7                	cmp    %eax,%edi
  802200:	0f 94 c2             	sete   %dl
  802203:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  802206:	8b 0d 08 50 80 00    	mov    0x805008,%ecx
  80220c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  80220f:	39 fb                	cmp    %edi,%ebx
  802211:	74 21                	je     802234 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802213:	84 d2                	test   %dl,%dl
  802215:	74 ca                	je     8021e1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802217:	8b 51 58             	mov    0x58(%ecx),%edx
  80221a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80221e:	89 54 24 08          	mov    %edx,0x8(%esp)
  802222:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802226:	c7 04 24 87 30 80 00 	movl   $0x803087,(%esp)
  80222d:	e8 12 e1 ff ff       	call   800344 <cprintf>
  802232:	eb ad                	jmp    8021e1 <_pipeisclosed+0xe>
	}
}
  802234:	83 c4 2c             	add    $0x2c,%esp
  802237:	5b                   	pop    %ebx
  802238:	5e                   	pop    %esi
  802239:	5f                   	pop    %edi
  80223a:	5d                   	pop    %ebp
  80223b:	c3                   	ret    

0080223c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80223c:	55                   	push   %ebp
  80223d:	89 e5                	mov    %esp,%ebp
  80223f:	57                   	push   %edi
  802240:	56                   	push   %esi
  802241:	53                   	push   %ebx
  802242:	83 ec 1c             	sub    $0x1c,%esp
  802245:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802248:	89 34 24             	mov    %esi,(%esp)
  80224b:	e8 80 f1 ff ff       	call   8013d0 <fd2data>
  802250:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802252:	bf 00 00 00 00       	mov    $0x0,%edi
  802257:	eb 45                	jmp    80229e <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802259:	89 da                	mov    %ebx,%edx
  80225b:	89 f0                	mov    %esi,%eax
  80225d:	e8 71 ff ff ff       	call   8021d3 <_pipeisclosed>
  802262:	85 c0                	test   %eax,%eax
  802264:	75 41                	jne    8022a7 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802266:	e8 f9 ea ff ff       	call   800d64 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80226b:	8b 43 04             	mov    0x4(%ebx),%eax
  80226e:	8b 0b                	mov    (%ebx),%ecx
  802270:	8d 51 20             	lea    0x20(%ecx),%edx
  802273:	39 d0                	cmp    %edx,%eax
  802275:	73 e2                	jae    802259 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802277:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80227a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80227e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802281:	99                   	cltd   
  802282:	c1 ea 1b             	shr    $0x1b,%edx
  802285:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802288:	83 e1 1f             	and    $0x1f,%ecx
  80228b:	29 d1                	sub    %edx,%ecx
  80228d:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  802291:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  802295:	83 c0 01             	add    $0x1,%eax
  802298:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80229b:	83 c7 01             	add    $0x1,%edi
  80229e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8022a1:	75 c8                	jne    80226b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8022a3:	89 f8                	mov    %edi,%eax
  8022a5:	eb 05                	jmp    8022ac <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022a7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8022ac:	83 c4 1c             	add    $0x1c,%esp
  8022af:	5b                   	pop    %ebx
  8022b0:	5e                   	pop    %esi
  8022b1:	5f                   	pop    %edi
  8022b2:	5d                   	pop    %ebp
  8022b3:	c3                   	ret    

008022b4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022b4:	55                   	push   %ebp
  8022b5:	89 e5                	mov    %esp,%ebp
  8022b7:	57                   	push   %edi
  8022b8:	56                   	push   %esi
  8022b9:	53                   	push   %ebx
  8022ba:	83 ec 1c             	sub    $0x1c,%esp
  8022bd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8022c0:	89 3c 24             	mov    %edi,(%esp)
  8022c3:	e8 08 f1 ff ff       	call   8013d0 <fd2data>
  8022c8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022ca:	be 00 00 00 00       	mov    $0x0,%esi
  8022cf:	eb 3d                	jmp    80230e <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8022d1:	85 f6                	test   %esi,%esi
  8022d3:	74 04                	je     8022d9 <devpipe_read+0x25>
				return i;
  8022d5:	89 f0                	mov    %esi,%eax
  8022d7:	eb 43                	jmp    80231c <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8022d9:	89 da                	mov    %ebx,%edx
  8022db:	89 f8                	mov    %edi,%eax
  8022dd:	e8 f1 fe ff ff       	call   8021d3 <_pipeisclosed>
  8022e2:	85 c0                	test   %eax,%eax
  8022e4:	75 31                	jne    802317 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8022e6:	e8 79 ea ff ff       	call   800d64 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8022eb:	8b 03                	mov    (%ebx),%eax
  8022ed:	3b 43 04             	cmp    0x4(%ebx),%eax
  8022f0:	74 df                	je     8022d1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8022f2:	99                   	cltd   
  8022f3:	c1 ea 1b             	shr    $0x1b,%edx
  8022f6:	01 d0                	add    %edx,%eax
  8022f8:	83 e0 1f             	and    $0x1f,%eax
  8022fb:	29 d0                	sub    %edx,%eax
  8022fd:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802302:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802305:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802308:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80230b:	83 c6 01             	add    $0x1,%esi
  80230e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802311:	75 d8                	jne    8022eb <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802313:	89 f0                	mov    %esi,%eax
  802315:	eb 05                	jmp    80231c <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802317:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80231c:	83 c4 1c             	add    $0x1c,%esp
  80231f:	5b                   	pop    %ebx
  802320:	5e                   	pop    %esi
  802321:	5f                   	pop    %edi
  802322:	5d                   	pop    %ebp
  802323:	c3                   	ret    

00802324 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802324:	55                   	push   %ebp
  802325:	89 e5                	mov    %esp,%ebp
  802327:	56                   	push   %esi
  802328:	53                   	push   %ebx
  802329:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80232c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80232f:	89 04 24             	mov    %eax,(%esp)
  802332:	e8 b0 f0 ff ff       	call   8013e7 <fd_alloc>
  802337:	89 c2                	mov    %eax,%edx
  802339:	85 d2                	test   %edx,%edx
  80233b:	0f 88 4d 01 00 00    	js     80248e <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802341:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802348:	00 
  802349:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80234c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802350:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802357:	e8 27 ea ff ff       	call   800d83 <sys_page_alloc>
  80235c:	89 c2                	mov    %eax,%edx
  80235e:	85 d2                	test   %edx,%edx
  802360:	0f 88 28 01 00 00    	js     80248e <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802366:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802369:	89 04 24             	mov    %eax,(%esp)
  80236c:	e8 76 f0 ff ff       	call   8013e7 <fd_alloc>
  802371:	89 c3                	mov    %eax,%ebx
  802373:	85 c0                	test   %eax,%eax
  802375:	0f 88 fe 00 00 00    	js     802479 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80237b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802382:	00 
  802383:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802386:	89 44 24 04          	mov    %eax,0x4(%esp)
  80238a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802391:	e8 ed e9 ff ff       	call   800d83 <sys_page_alloc>
  802396:	89 c3                	mov    %eax,%ebx
  802398:	85 c0                	test   %eax,%eax
  80239a:	0f 88 d9 00 00 00    	js     802479 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8023a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023a3:	89 04 24             	mov    %eax,(%esp)
  8023a6:	e8 25 f0 ff ff       	call   8013d0 <fd2data>
  8023ab:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023ad:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8023b4:	00 
  8023b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023c0:	e8 be e9 ff ff       	call   800d83 <sys_page_alloc>
  8023c5:	89 c3                	mov    %eax,%ebx
  8023c7:	85 c0                	test   %eax,%eax
  8023c9:	0f 88 97 00 00 00    	js     802466 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023d2:	89 04 24             	mov    %eax,(%esp)
  8023d5:	e8 f6 ef ff ff       	call   8013d0 <fd2data>
  8023da:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8023e1:	00 
  8023e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023e6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8023ed:	00 
  8023ee:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023f9:	e8 d9 e9 ff ff       	call   800dd7 <sys_page_map>
  8023fe:	89 c3                	mov    %eax,%ebx
  802400:	85 c0                	test   %eax,%eax
  802402:	78 52                	js     802456 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802404:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80240a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80240d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80240f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802412:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802419:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80241f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802422:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802424:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802427:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80242e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802431:	89 04 24             	mov    %eax,(%esp)
  802434:	e8 87 ef ff ff       	call   8013c0 <fd2num>
  802439:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80243c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80243e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802441:	89 04 24             	mov    %eax,(%esp)
  802444:	e8 77 ef ff ff       	call   8013c0 <fd2num>
  802449:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80244c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80244f:	b8 00 00 00 00       	mov    $0x0,%eax
  802454:	eb 38                	jmp    80248e <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  802456:	89 74 24 04          	mov    %esi,0x4(%esp)
  80245a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802461:	e8 c4 e9 ff ff       	call   800e2a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802466:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802469:	89 44 24 04          	mov    %eax,0x4(%esp)
  80246d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802474:	e8 b1 e9 ff ff       	call   800e2a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802479:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80247c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802480:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802487:	e8 9e e9 ff ff       	call   800e2a <sys_page_unmap>
  80248c:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  80248e:	83 c4 30             	add    $0x30,%esp
  802491:	5b                   	pop    %ebx
  802492:	5e                   	pop    %esi
  802493:	5d                   	pop    %ebp
  802494:	c3                   	ret    

00802495 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802495:	55                   	push   %ebp
  802496:	89 e5                	mov    %esp,%ebp
  802498:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80249b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80249e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8024a5:	89 04 24             	mov    %eax,(%esp)
  8024a8:	e8 89 ef ff ff       	call   801436 <fd_lookup>
  8024ad:	89 c2                	mov    %eax,%edx
  8024af:	85 d2                	test   %edx,%edx
  8024b1:	78 15                	js     8024c8 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8024b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024b6:	89 04 24             	mov    %eax,(%esp)
  8024b9:	e8 12 ef ff ff       	call   8013d0 <fd2data>
	return _pipeisclosed(fd, p);
  8024be:	89 c2                	mov    %eax,%edx
  8024c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024c3:	e8 0b fd ff ff       	call   8021d3 <_pipeisclosed>
}
  8024c8:	c9                   	leave  
  8024c9:	c3                   	ret    
  8024ca:	66 90                	xchg   %ax,%ax
  8024cc:	66 90                	xchg   %ax,%ax
  8024ce:	66 90                	xchg   %ax,%ax

008024d0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8024d0:	55                   	push   %ebp
  8024d1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8024d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8024d8:	5d                   	pop    %ebp
  8024d9:	c3                   	ret    

008024da <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8024da:	55                   	push   %ebp
  8024db:	89 e5                	mov    %esp,%ebp
  8024dd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8024e0:	c7 44 24 04 9f 30 80 	movl   $0x80309f,0x4(%esp)
  8024e7:	00 
  8024e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024eb:	89 04 24             	mov    %eax,(%esp)
  8024ee:	e8 74 e4 ff ff       	call   800967 <strcpy>
	return 0;
}
  8024f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8024f8:	c9                   	leave  
  8024f9:	c3                   	ret    

008024fa <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8024fa:	55                   	push   %ebp
  8024fb:	89 e5                	mov    %esp,%ebp
  8024fd:	57                   	push   %edi
  8024fe:	56                   	push   %esi
  8024ff:	53                   	push   %ebx
  802500:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802506:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80250b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802511:	eb 31                	jmp    802544 <devcons_write+0x4a>
		m = n - tot;
  802513:	8b 75 10             	mov    0x10(%ebp),%esi
  802516:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802518:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80251b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802520:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802523:	89 74 24 08          	mov    %esi,0x8(%esp)
  802527:	03 45 0c             	add    0xc(%ebp),%eax
  80252a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80252e:	89 3c 24             	mov    %edi,(%esp)
  802531:	e8 ce e5 ff ff       	call   800b04 <memmove>
		sys_cputs(buf, m);
  802536:	89 74 24 04          	mov    %esi,0x4(%esp)
  80253a:	89 3c 24             	mov    %edi,(%esp)
  80253d:	e8 74 e7 ff ff       	call   800cb6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802542:	01 f3                	add    %esi,%ebx
  802544:	89 d8                	mov    %ebx,%eax
  802546:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802549:	72 c8                	jb     802513 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80254b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802551:	5b                   	pop    %ebx
  802552:	5e                   	pop    %esi
  802553:	5f                   	pop    %edi
  802554:	5d                   	pop    %ebp
  802555:	c3                   	ret    

00802556 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802556:	55                   	push   %ebp
  802557:	89 e5                	mov    %esp,%ebp
  802559:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80255c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802561:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802565:	75 07                	jne    80256e <devcons_read+0x18>
  802567:	eb 2a                	jmp    802593 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802569:	e8 f6 e7 ff ff       	call   800d64 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80256e:	66 90                	xchg   %ax,%ax
  802570:	e8 5f e7 ff ff       	call   800cd4 <sys_cgetc>
  802575:	85 c0                	test   %eax,%eax
  802577:	74 f0                	je     802569 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802579:	85 c0                	test   %eax,%eax
  80257b:	78 16                	js     802593 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80257d:	83 f8 04             	cmp    $0x4,%eax
  802580:	74 0c                	je     80258e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802582:	8b 55 0c             	mov    0xc(%ebp),%edx
  802585:	88 02                	mov    %al,(%edx)
	return 1;
  802587:	b8 01 00 00 00       	mov    $0x1,%eax
  80258c:	eb 05                	jmp    802593 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80258e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802593:	c9                   	leave  
  802594:	c3                   	ret    

00802595 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802595:	55                   	push   %ebp
  802596:	89 e5                	mov    %esp,%ebp
  802598:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80259b:	8b 45 08             	mov    0x8(%ebp),%eax
  80259e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8025a1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8025a8:	00 
  8025a9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8025ac:	89 04 24             	mov    %eax,(%esp)
  8025af:	e8 02 e7 ff ff       	call   800cb6 <sys_cputs>
}
  8025b4:	c9                   	leave  
  8025b5:	c3                   	ret    

008025b6 <getchar>:

int
getchar(void)
{
  8025b6:	55                   	push   %ebp
  8025b7:	89 e5                	mov    %esp,%ebp
  8025b9:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8025bc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8025c3:	00 
  8025c4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8025c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025d2:	e8 f3 f0 ff ff       	call   8016ca <read>
	if (r < 0)
  8025d7:	85 c0                	test   %eax,%eax
  8025d9:	78 0f                	js     8025ea <getchar+0x34>
		return r;
	if (r < 1)
  8025db:	85 c0                	test   %eax,%eax
  8025dd:	7e 06                	jle    8025e5 <getchar+0x2f>
		return -E_EOF;
	return c;
  8025df:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8025e3:	eb 05                	jmp    8025ea <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8025e5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8025ea:	c9                   	leave  
  8025eb:	c3                   	ret    

008025ec <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8025ec:	55                   	push   %ebp
  8025ed:	89 e5                	mov    %esp,%ebp
  8025ef:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8025fc:	89 04 24             	mov    %eax,(%esp)
  8025ff:	e8 32 ee ff ff       	call   801436 <fd_lookup>
  802604:	85 c0                	test   %eax,%eax
  802606:	78 11                	js     802619 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802608:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80260b:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802611:	39 10                	cmp    %edx,(%eax)
  802613:	0f 94 c0             	sete   %al
  802616:	0f b6 c0             	movzbl %al,%eax
}
  802619:	c9                   	leave  
  80261a:	c3                   	ret    

0080261b <opencons>:

int
opencons(void)
{
  80261b:	55                   	push   %ebp
  80261c:	89 e5                	mov    %esp,%ebp
  80261e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802621:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802624:	89 04 24             	mov    %eax,(%esp)
  802627:	e8 bb ed ff ff       	call   8013e7 <fd_alloc>
		return r;
  80262c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80262e:	85 c0                	test   %eax,%eax
  802630:	78 40                	js     802672 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802632:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802639:	00 
  80263a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80263d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802641:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802648:	e8 36 e7 ff ff       	call   800d83 <sys_page_alloc>
		return r;
  80264d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80264f:	85 c0                	test   %eax,%eax
  802651:	78 1f                	js     802672 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802653:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802659:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80265c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80265e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802661:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802668:	89 04 24             	mov    %eax,(%esp)
  80266b:	e8 50 ed ff ff       	call   8013c0 <fd2num>
  802670:	89 c2                	mov    %eax,%edx
}
  802672:	89 d0                	mov    %edx,%eax
  802674:	c9                   	leave  
  802675:	c3                   	ret    

00802676 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802676:	55                   	push   %ebp
  802677:	89 e5                	mov    %esp,%ebp
  802679:	53                   	push   %ebx
  80267a:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  80267d:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802684:	75 2f                	jne    8026b5 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  802686:	e8 ba e6 ff ff       	call   800d45 <sys_getenvid>
  80268b:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P);
  80268d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802694:	00 
  802695:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80269c:	ee 
  80269d:	89 04 24             	mov    %eax,(%esp)
  8026a0:	e8 de e6 ff ff       	call   800d83 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *)_pgfault_upcall);
  8026a5:	c7 44 24 04 c3 26 80 	movl   $0x8026c3,0x4(%esp)
  8026ac:	00 
  8026ad:	89 1c 24             	mov    %ebx,(%esp)
  8026b0:	e8 6e e8 ff ff       	call   800f23 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8026b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8026b8:	a3 00 80 80 00       	mov    %eax,0x808000
}
  8026bd:	83 c4 14             	add    $0x14,%esp
  8026c0:	5b                   	pop    %ebx
  8026c1:	5d                   	pop    %ebp
  8026c2:	c3                   	ret    

008026c3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8026c3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8026c4:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  8026c9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8026cb:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	// 0x30(%esp) points to trap-time stack pointer
	// 0x28(%esp) points to trap-time eip
	subl $4, 0x30(%esp)
  8026ce:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax 
  8026d3:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebp
  8026d7:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %ebp, (%eax)
  8026db:	89 28                	mov    %ebp,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8026dd:	83 c4 08             	add    $0x8,%esp
	popal
  8026e0:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp //pop eip - we already stored it
  8026e1:	83 c4 04             	add    $0x4,%esp
	popfl
  8026e4:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8026e5:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8026e6:	c3                   	ret    
  8026e7:	66 90                	xchg   %ax,%ax
  8026e9:	66 90                	xchg   %ax,%ax
  8026eb:	66 90                	xchg   %ax,%ax
  8026ed:	66 90                	xchg   %ax,%ax
  8026ef:	90                   	nop

008026f0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8026f0:	55                   	push   %ebp
  8026f1:	89 e5                	mov    %esp,%ebp
  8026f3:	56                   	push   %esi
  8026f4:	53                   	push   %ebx
  8026f5:	83 ec 10             	sub    $0x10,%esp
  8026f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8026fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  802701:	85 c0                	test   %eax,%eax
  802703:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802708:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  80270b:	89 04 24             	mov    %eax,(%esp)
  80270e:	e8 86 e8 ff ff       	call   800f99 <sys_ipc_recv>

	if(ret < 0) {
  802713:	85 c0                	test   %eax,%eax
  802715:	79 16                	jns    80272d <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  802717:	85 f6                	test   %esi,%esi
  802719:	74 06                	je     802721 <ipc_recv+0x31>
  80271b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  802721:	85 db                	test   %ebx,%ebx
  802723:	74 3e                	je     802763 <ipc_recv+0x73>
  802725:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80272b:	eb 36                	jmp    802763 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  80272d:	e8 13 e6 ff ff       	call   800d45 <sys_getenvid>
  802732:	25 ff 03 00 00       	and    $0x3ff,%eax
  802737:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80273a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80273f:	a3 08 50 80 00       	mov    %eax,0x805008

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802744:	85 f6                	test   %esi,%esi
  802746:	74 05                	je     80274d <ipc_recv+0x5d>
  802748:	8b 40 74             	mov    0x74(%eax),%eax
  80274b:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80274d:	85 db                	test   %ebx,%ebx
  80274f:	74 0a                	je     80275b <ipc_recv+0x6b>
  802751:	a1 08 50 80 00       	mov    0x805008,%eax
  802756:	8b 40 78             	mov    0x78(%eax),%eax
  802759:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  80275b:	a1 08 50 80 00       	mov    0x805008,%eax
  802760:	8b 40 70             	mov    0x70(%eax),%eax
}
  802763:	83 c4 10             	add    $0x10,%esp
  802766:	5b                   	pop    %ebx
  802767:	5e                   	pop    %esi
  802768:	5d                   	pop    %ebp
  802769:	c3                   	ret    

0080276a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80276a:	55                   	push   %ebp
  80276b:	89 e5                	mov    %esp,%ebp
  80276d:	57                   	push   %edi
  80276e:	56                   	push   %esi
  80276f:	53                   	push   %ebx
  802770:	83 ec 1c             	sub    $0x1c,%esp
  802773:	8b 7d 08             	mov    0x8(%ebp),%edi
  802776:	8b 75 0c             	mov    0xc(%ebp),%esi
  802779:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  80277c:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  80277e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802783:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  802786:	8b 45 14             	mov    0x14(%ebp),%eax
  802789:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80278d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802791:	89 74 24 04          	mov    %esi,0x4(%esp)
  802795:	89 3c 24             	mov    %edi,(%esp)
  802798:	e8 d9 e7 ff ff       	call   800f76 <sys_ipc_try_send>

		if(ret >= 0) break;
  80279d:	85 c0                	test   %eax,%eax
  80279f:	79 2c                	jns    8027cd <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  8027a1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8027a4:	74 20                	je     8027c6 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  8027a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8027aa:	c7 44 24 08 ac 30 80 	movl   $0x8030ac,0x8(%esp)
  8027b1:	00 
  8027b2:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8027b9:	00 
  8027ba:	c7 04 24 dc 30 80 00 	movl   $0x8030dc,(%esp)
  8027c1:	e8 85 da ff ff       	call   80024b <_panic>
		}
		sys_yield();
  8027c6:	e8 99 e5 ff ff       	call   800d64 <sys_yield>
	}
  8027cb:	eb b9                	jmp    802786 <ipc_send+0x1c>
}
  8027cd:	83 c4 1c             	add    $0x1c,%esp
  8027d0:	5b                   	pop    %ebx
  8027d1:	5e                   	pop    %esi
  8027d2:	5f                   	pop    %edi
  8027d3:	5d                   	pop    %ebp
  8027d4:	c3                   	ret    

008027d5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8027d5:	55                   	push   %ebp
  8027d6:	89 e5                	mov    %esp,%ebp
  8027d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8027db:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8027e0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8027e3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8027e9:	8b 52 50             	mov    0x50(%edx),%edx
  8027ec:	39 ca                	cmp    %ecx,%edx
  8027ee:	75 0d                	jne    8027fd <ipc_find_env+0x28>
			return envs[i].env_id;
  8027f0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8027f3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8027f8:	8b 40 40             	mov    0x40(%eax),%eax
  8027fb:	eb 0e                	jmp    80280b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8027fd:	83 c0 01             	add    $0x1,%eax
  802800:	3d 00 04 00 00       	cmp    $0x400,%eax
  802805:	75 d9                	jne    8027e0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802807:	66 b8 00 00          	mov    $0x0,%ax
}
  80280b:	5d                   	pop    %ebp
  80280c:	c3                   	ret    

0080280d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80280d:	55                   	push   %ebp
  80280e:	89 e5                	mov    %esp,%ebp
  802810:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802813:	89 d0                	mov    %edx,%eax
  802815:	c1 e8 16             	shr    $0x16,%eax
  802818:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80281f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802824:	f6 c1 01             	test   $0x1,%cl
  802827:	74 1d                	je     802846 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802829:	c1 ea 0c             	shr    $0xc,%edx
  80282c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802833:	f6 c2 01             	test   $0x1,%dl
  802836:	74 0e                	je     802846 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802838:	c1 ea 0c             	shr    $0xc,%edx
  80283b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802842:	ef 
  802843:	0f b7 c0             	movzwl %ax,%eax
}
  802846:	5d                   	pop    %ebp
  802847:	c3                   	ret    
  802848:	66 90                	xchg   %ax,%ax
  80284a:	66 90                	xchg   %ax,%ax
  80284c:	66 90                	xchg   %ax,%ax
  80284e:	66 90                	xchg   %ax,%ax

00802850 <__udivdi3>:
  802850:	55                   	push   %ebp
  802851:	57                   	push   %edi
  802852:	56                   	push   %esi
  802853:	83 ec 0c             	sub    $0xc,%esp
  802856:	8b 44 24 28          	mov    0x28(%esp),%eax
  80285a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80285e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802862:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802866:	85 c0                	test   %eax,%eax
  802868:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80286c:	89 ea                	mov    %ebp,%edx
  80286e:	89 0c 24             	mov    %ecx,(%esp)
  802871:	75 2d                	jne    8028a0 <__udivdi3+0x50>
  802873:	39 e9                	cmp    %ebp,%ecx
  802875:	77 61                	ja     8028d8 <__udivdi3+0x88>
  802877:	85 c9                	test   %ecx,%ecx
  802879:	89 ce                	mov    %ecx,%esi
  80287b:	75 0b                	jne    802888 <__udivdi3+0x38>
  80287d:	b8 01 00 00 00       	mov    $0x1,%eax
  802882:	31 d2                	xor    %edx,%edx
  802884:	f7 f1                	div    %ecx
  802886:	89 c6                	mov    %eax,%esi
  802888:	31 d2                	xor    %edx,%edx
  80288a:	89 e8                	mov    %ebp,%eax
  80288c:	f7 f6                	div    %esi
  80288e:	89 c5                	mov    %eax,%ebp
  802890:	89 f8                	mov    %edi,%eax
  802892:	f7 f6                	div    %esi
  802894:	89 ea                	mov    %ebp,%edx
  802896:	83 c4 0c             	add    $0xc,%esp
  802899:	5e                   	pop    %esi
  80289a:	5f                   	pop    %edi
  80289b:	5d                   	pop    %ebp
  80289c:	c3                   	ret    
  80289d:	8d 76 00             	lea    0x0(%esi),%esi
  8028a0:	39 e8                	cmp    %ebp,%eax
  8028a2:	77 24                	ja     8028c8 <__udivdi3+0x78>
  8028a4:	0f bd e8             	bsr    %eax,%ebp
  8028a7:	83 f5 1f             	xor    $0x1f,%ebp
  8028aa:	75 3c                	jne    8028e8 <__udivdi3+0x98>
  8028ac:	8b 74 24 04          	mov    0x4(%esp),%esi
  8028b0:	39 34 24             	cmp    %esi,(%esp)
  8028b3:	0f 86 9f 00 00 00    	jbe    802958 <__udivdi3+0x108>
  8028b9:	39 d0                	cmp    %edx,%eax
  8028bb:	0f 82 97 00 00 00    	jb     802958 <__udivdi3+0x108>
  8028c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028c8:	31 d2                	xor    %edx,%edx
  8028ca:	31 c0                	xor    %eax,%eax
  8028cc:	83 c4 0c             	add    $0xc,%esp
  8028cf:	5e                   	pop    %esi
  8028d0:	5f                   	pop    %edi
  8028d1:	5d                   	pop    %ebp
  8028d2:	c3                   	ret    
  8028d3:	90                   	nop
  8028d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028d8:	89 f8                	mov    %edi,%eax
  8028da:	f7 f1                	div    %ecx
  8028dc:	31 d2                	xor    %edx,%edx
  8028de:	83 c4 0c             	add    $0xc,%esp
  8028e1:	5e                   	pop    %esi
  8028e2:	5f                   	pop    %edi
  8028e3:	5d                   	pop    %ebp
  8028e4:	c3                   	ret    
  8028e5:	8d 76 00             	lea    0x0(%esi),%esi
  8028e8:	89 e9                	mov    %ebp,%ecx
  8028ea:	8b 3c 24             	mov    (%esp),%edi
  8028ed:	d3 e0                	shl    %cl,%eax
  8028ef:	89 c6                	mov    %eax,%esi
  8028f1:	b8 20 00 00 00       	mov    $0x20,%eax
  8028f6:	29 e8                	sub    %ebp,%eax
  8028f8:	89 c1                	mov    %eax,%ecx
  8028fa:	d3 ef                	shr    %cl,%edi
  8028fc:	89 e9                	mov    %ebp,%ecx
  8028fe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802902:	8b 3c 24             	mov    (%esp),%edi
  802905:	09 74 24 08          	or     %esi,0x8(%esp)
  802909:	89 d6                	mov    %edx,%esi
  80290b:	d3 e7                	shl    %cl,%edi
  80290d:	89 c1                	mov    %eax,%ecx
  80290f:	89 3c 24             	mov    %edi,(%esp)
  802912:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802916:	d3 ee                	shr    %cl,%esi
  802918:	89 e9                	mov    %ebp,%ecx
  80291a:	d3 e2                	shl    %cl,%edx
  80291c:	89 c1                	mov    %eax,%ecx
  80291e:	d3 ef                	shr    %cl,%edi
  802920:	09 d7                	or     %edx,%edi
  802922:	89 f2                	mov    %esi,%edx
  802924:	89 f8                	mov    %edi,%eax
  802926:	f7 74 24 08          	divl   0x8(%esp)
  80292a:	89 d6                	mov    %edx,%esi
  80292c:	89 c7                	mov    %eax,%edi
  80292e:	f7 24 24             	mull   (%esp)
  802931:	39 d6                	cmp    %edx,%esi
  802933:	89 14 24             	mov    %edx,(%esp)
  802936:	72 30                	jb     802968 <__udivdi3+0x118>
  802938:	8b 54 24 04          	mov    0x4(%esp),%edx
  80293c:	89 e9                	mov    %ebp,%ecx
  80293e:	d3 e2                	shl    %cl,%edx
  802940:	39 c2                	cmp    %eax,%edx
  802942:	73 05                	jae    802949 <__udivdi3+0xf9>
  802944:	3b 34 24             	cmp    (%esp),%esi
  802947:	74 1f                	je     802968 <__udivdi3+0x118>
  802949:	89 f8                	mov    %edi,%eax
  80294b:	31 d2                	xor    %edx,%edx
  80294d:	e9 7a ff ff ff       	jmp    8028cc <__udivdi3+0x7c>
  802952:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802958:	31 d2                	xor    %edx,%edx
  80295a:	b8 01 00 00 00       	mov    $0x1,%eax
  80295f:	e9 68 ff ff ff       	jmp    8028cc <__udivdi3+0x7c>
  802964:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802968:	8d 47 ff             	lea    -0x1(%edi),%eax
  80296b:	31 d2                	xor    %edx,%edx
  80296d:	83 c4 0c             	add    $0xc,%esp
  802970:	5e                   	pop    %esi
  802971:	5f                   	pop    %edi
  802972:	5d                   	pop    %ebp
  802973:	c3                   	ret    
  802974:	66 90                	xchg   %ax,%ax
  802976:	66 90                	xchg   %ax,%ax
  802978:	66 90                	xchg   %ax,%ax
  80297a:	66 90                	xchg   %ax,%ax
  80297c:	66 90                	xchg   %ax,%ax
  80297e:	66 90                	xchg   %ax,%ax

00802980 <__umoddi3>:
  802980:	55                   	push   %ebp
  802981:	57                   	push   %edi
  802982:	56                   	push   %esi
  802983:	83 ec 14             	sub    $0x14,%esp
  802986:	8b 44 24 28          	mov    0x28(%esp),%eax
  80298a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80298e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802992:	89 c7                	mov    %eax,%edi
  802994:	89 44 24 04          	mov    %eax,0x4(%esp)
  802998:	8b 44 24 30          	mov    0x30(%esp),%eax
  80299c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8029a0:	89 34 24             	mov    %esi,(%esp)
  8029a3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8029a7:	85 c0                	test   %eax,%eax
  8029a9:	89 c2                	mov    %eax,%edx
  8029ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8029af:	75 17                	jne    8029c8 <__umoddi3+0x48>
  8029b1:	39 fe                	cmp    %edi,%esi
  8029b3:	76 4b                	jbe    802a00 <__umoddi3+0x80>
  8029b5:	89 c8                	mov    %ecx,%eax
  8029b7:	89 fa                	mov    %edi,%edx
  8029b9:	f7 f6                	div    %esi
  8029bb:	89 d0                	mov    %edx,%eax
  8029bd:	31 d2                	xor    %edx,%edx
  8029bf:	83 c4 14             	add    $0x14,%esp
  8029c2:	5e                   	pop    %esi
  8029c3:	5f                   	pop    %edi
  8029c4:	5d                   	pop    %ebp
  8029c5:	c3                   	ret    
  8029c6:	66 90                	xchg   %ax,%ax
  8029c8:	39 f8                	cmp    %edi,%eax
  8029ca:	77 54                	ja     802a20 <__umoddi3+0xa0>
  8029cc:	0f bd e8             	bsr    %eax,%ebp
  8029cf:	83 f5 1f             	xor    $0x1f,%ebp
  8029d2:	75 5c                	jne    802a30 <__umoddi3+0xb0>
  8029d4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8029d8:	39 3c 24             	cmp    %edi,(%esp)
  8029db:	0f 87 e7 00 00 00    	ja     802ac8 <__umoddi3+0x148>
  8029e1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8029e5:	29 f1                	sub    %esi,%ecx
  8029e7:	19 c7                	sbb    %eax,%edi
  8029e9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8029ed:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8029f1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8029f5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8029f9:	83 c4 14             	add    $0x14,%esp
  8029fc:	5e                   	pop    %esi
  8029fd:	5f                   	pop    %edi
  8029fe:	5d                   	pop    %ebp
  8029ff:	c3                   	ret    
  802a00:	85 f6                	test   %esi,%esi
  802a02:	89 f5                	mov    %esi,%ebp
  802a04:	75 0b                	jne    802a11 <__umoddi3+0x91>
  802a06:	b8 01 00 00 00       	mov    $0x1,%eax
  802a0b:	31 d2                	xor    %edx,%edx
  802a0d:	f7 f6                	div    %esi
  802a0f:	89 c5                	mov    %eax,%ebp
  802a11:	8b 44 24 04          	mov    0x4(%esp),%eax
  802a15:	31 d2                	xor    %edx,%edx
  802a17:	f7 f5                	div    %ebp
  802a19:	89 c8                	mov    %ecx,%eax
  802a1b:	f7 f5                	div    %ebp
  802a1d:	eb 9c                	jmp    8029bb <__umoddi3+0x3b>
  802a1f:	90                   	nop
  802a20:	89 c8                	mov    %ecx,%eax
  802a22:	89 fa                	mov    %edi,%edx
  802a24:	83 c4 14             	add    $0x14,%esp
  802a27:	5e                   	pop    %esi
  802a28:	5f                   	pop    %edi
  802a29:	5d                   	pop    %ebp
  802a2a:	c3                   	ret    
  802a2b:	90                   	nop
  802a2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a30:	8b 04 24             	mov    (%esp),%eax
  802a33:	be 20 00 00 00       	mov    $0x20,%esi
  802a38:	89 e9                	mov    %ebp,%ecx
  802a3a:	29 ee                	sub    %ebp,%esi
  802a3c:	d3 e2                	shl    %cl,%edx
  802a3e:	89 f1                	mov    %esi,%ecx
  802a40:	d3 e8                	shr    %cl,%eax
  802a42:	89 e9                	mov    %ebp,%ecx
  802a44:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a48:	8b 04 24             	mov    (%esp),%eax
  802a4b:	09 54 24 04          	or     %edx,0x4(%esp)
  802a4f:	89 fa                	mov    %edi,%edx
  802a51:	d3 e0                	shl    %cl,%eax
  802a53:	89 f1                	mov    %esi,%ecx
  802a55:	89 44 24 08          	mov    %eax,0x8(%esp)
  802a59:	8b 44 24 10          	mov    0x10(%esp),%eax
  802a5d:	d3 ea                	shr    %cl,%edx
  802a5f:	89 e9                	mov    %ebp,%ecx
  802a61:	d3 e7                	shl    %cl,%edi
  802a63:	89 f1                	mov    %esi,%ecx
  802a65:	d3 e8                	shr    %cl,%eax
  802a67:	89 e9                	mov    %ebp,%ecx
  802a69:	09 f8                	or     %edi,%eax
  802a6b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  802a6f:	f7 74 24 04          	divl   0x4(%esp)
  802a73:	d3 e7                	shl    %cl,%edi
  802a75:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802a79:	89 d7                	mov    %edx,%edi
  802a7b:	f7 64 24 08          	mull   0x8(%esp)
  802a7f:	39 d7                	cmp    %edx,%edi
  802a81:	89 c1                	mov    %eax,%ecx
  802a83:	89 14 24             	mov    %edx,(%esp)
  802a86:	72 2c                	jb     802ab4 <__umoddi3+0x134>
  802a88:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  802a8c:	72 22                	jb     802ab0 <__umoddi3+0x130>
  802a8e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802a92:	29 c8                	sub    %ecx,%eax
  802a94:	19 d7                	sbb    %edx,%edi
  802a96:	89 e9                	mov    %ebp,%ecx
  802a98:	89 fa                	mov    %edi,%edx
  802a9a:	d3 e8                	shr    %cl,%eax
  802a9c:	89 f1                	mov    %esi,%ecx
  802a9e:	d3 e2                	shl    %cl,%edx
  802aa0:	89 e9                	mov    %ebp,%ecx
  802aa2:	d3 ef                	shr    %cl,%edi
  802aa4:	09 d0                	or     %edx,%eax
  802aa6:	89 fa                	mov    %edi,%edx
  802aa8:	83 c4 14             	add    $0x14,%esp
  802aab:	5e                   	pop    %esi
  802aac:	5f                   	pop    %edi
  802aad:	5d                   	pop    %ebp
  802aae:	c3                   	ret    
  802aaf:	90                   	nop
  802ab0:	39 d7                	cmp    %edx,%edi
  802ab2:	75 da                	jne    802a8e <__umoddi3+0x10e>
  802ab4:	8b 14 24             	mov    (%esp),%edx
  802ab7:	89 c1                	mov    %eax,%ecx
  802ab9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  802abd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802ac1:	eb cb                	jmp    802a8e <__umoddi3+0x10e>
  802ac3:	90                   	nop
  802ac4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ac8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  802acc:	0f 82 0f ff ff ff    	jb     8029e1 <__umoddi3+0x61>
  802ad2:	e9 1a ff ff ff       	jmp    8029f1 <__umoddi3+0x71>
