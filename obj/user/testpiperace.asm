
obj/user/testpiperace.debug:     file format elf32-i386


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
  80002c:	e8 ed 01 00 00       	call   80021e <libmain>
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
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 20             	sub    $0x20,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  800048:	c7 04 24 20 2b 80 00 	movl   $0x802b20,(%esp)
  80004f:	e8 24 03 00 00       	call   800378 <cprintf>
	if ((r = pipe(p)) < 0)
  800054:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800057:	89 04 24             	mov    %eax,(%esp)
  80005a:	e8 65 24 00 00       	call   8024c4 <pipe>
  80005f:	85 c0                	test   %eax,%eax
  800061:	79 20                	jns    800083 <umain+0x43>
		panic("pipe: %e", r);
  800063:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800067:	c7 44 24 08 39 2b 80 	movl   $0x802b39,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  800076:	00 
  800077:	c7 04 24 42 2b 80 00 	movl   $0x802b42,(%esp)
  80007e:	e8 fc 01 00 00       	call   80027f <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800083:	e8 6c 11 00 00       	call   8011f4 <fork>
  800088:	89 c6                	mov    %eax,%esi
  80008a:	85 c0                	test   %eax,%eax
  80008c:	79 20                	jns    8000ae <umain+0x6e>
		panic("fork: %e", r);
  80008e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800092:	c7 44 24 08 56 2b 80 	movl   $0x802b56,0x8(%esp)
  800099:	00 
  80009a:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  8000a1:	00 
  8000a2:	c7 04 24 42 2b 80 00 	movl   $0x802b42,(%esp)
  8000a9:	e8 d1 01 00 00       	call   80027f <_panic>
	if (r == 0) {
  8000ae:	85 c0                	test   %eax,%eax
  8000b0:	75 56                	jne    800108 <umain+0xc8>
		close(p[1]);
  8000b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000b5:	89 04 24             	mov    %eax,(%esp)
  8000b8:	e8 0a 16 00 00       	call   8016c7 <close>
  8000bd:	bb c8 00 00 00       	mov    $0xc8,%ebx
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
			if(pipeisclosed(p[0])){
  8000c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8000c5:	89 04 24             	mov    %eax,(%esp)
  8000c8:	e8 68 25 00 00       	call   802635 <pipeisclosed>
  8000cd:	85 c0                	test   %eax,%eax
  8000cf:	74 11                	je     8000e2 <umain+0xa2>
				cprintf("RACE: pipe appears closed\n");
  8000d1:	c7 04 24 5f 2b 80 00 	movl   $0x802b5f,(%esp)
  8000d8:	e8 9b 02 00 00       	call   800378 <cprintf>
				exit();
  8000dd:	e8 84 01 00 00       	call   800266 <exit>
			}
			sys_yield();
  8000e2:	e8 bd 0c 00 00       	call   800da4 <sys_yield>
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  8000e7:	83 eb 01             	sub    $0x1,%ebx
  8000ea:	75 d6                	jne    8000c2 <umain+0x82>
				exit();
			}
			sys_yield();
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000ec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000f3:	00 
  8000f4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000fb:	00 
  8000fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800103:	e8 f8 12 00 00       	call   801400 <ipc_recv>
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  800108:	89 74 24 04          	mov    %esi,0x4(%esp)
  80010c:	c7 04 24 7a 2b 80 00 	movl   $0x802b7a,(%esp)
  800113:	e8 60 02 00 00       	call   800378 <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  800118:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80011e:	6b f6 7c             	imul   $0x7c,%esi,%esi
	cprintf("kid is %d\n", kid-envs);
  800121:	8d 9e 00 00 c0 ee    	lea    -0x11400000(%esi),%ebx
  800127:	c1 ee 02             	shr    $0x2,%esi
  80012a:	69 f6 df 7b ef bd    	imul   $0xbdef7bdf,%esi,%esi
  800130:	89 74 24 04          	mov    %esi,0x4(%esp)
  800134:	c7 04 24 85 2b 80 00 	movl   $0x802b85,(%esp)
  80013b:	e8 38 02 00 00       	call   800378 <cprintf>
	dup(p[0], 10);
  800140:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  800147:	00 
  800148:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80014b:	89 04 24             	mov    %eax,(%esp)
  80014e:	e8 c9 15 00 00       	call   80171c <dup>
	while (kid->env_status == ENV_RUNNABLE)
  800153:	eb 13                	jmp    800168 <umain+0x128>
		dup(p[0], 10);
  800155:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  80015c:	00 
  80015d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800160:	89 04 24             	mov    %eax,(%esp)
  800163:	e8 b4 15 00 00       	call   80171c <dup>
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800168:	8b 43 54             	mov    0x54(%ebx),%eax
  80016b:	83 f8 02             	cmp    $0x2,%eax
  80016e:	74 e5                	je     800155 <umain+0x115>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800170:	c7 04 24 90 2b 80 00 	movl   $0x802b90,(%esp)
  800177:	e8 fc 01 00 00       	call   800378 <cprintf>
	if (pipeisclosed(p[0]))
  80017c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80017f:	89 04 24             	mov    %eax,(%esp)
  800182:	e8 ae 24 00 00       	call   802635 <pipeisclosed>
  800187:	85 c0                	test   %eax,%eax
  800189:	74 1c                	je     8001a7 <umain+0x167>
		panic("somehow the other end of p[0] got closed!");
  80018b:	c7 44 24 08 ec 2b 80 	movl   $0x802bec,0x8(%esp)
  800192:	00 
  800193:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  80019a:	00 
  80019b:	c7 04 24 42 2b 80 00 	movl   $0x802b42,(%esp)
  8001a2:	e8 d8 00 00 00       	call   80027f <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  8001a7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8001aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001b1:	89 04 24             	mov    %eax,(%esp)
  8001b4:	e8 dd 13 00 00       	call   801596 <fd_lookup>
  8001b9:	85 c0                	test   %eax,%eax
  8001bb:	79 20                	jns    8001dd <umain+0x19d>
		panic("cannot look up p[0]: %e", r);
  8001bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c1:	c7 44 24 08 a6 2b 80 	movl   $0x802ba6,0x8(%esp)
  8001c8:	00 
  8001c9:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  8001d0:	00 
  8001d1:	c7 04 24 42 2b 80 00 	movl   $0x802b42,(%esp)
  8001d8:	e8 a2 00 00 00       	call   80027f <_panic>
	va = fd2data(fd);
  8001dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8001e0:	89 04 24             	mov    %eax,(%esp)
  8001e3:	e8 48 13 00 00       	call   801530 <fd2data>
	if (pageref(va) != 3+1)
  8001e8:	89 04 24             	mov    %eax,(%esp)
  8001eb:	e8 ae 1b 00 00       	call   801d9e <pageref>
  8001f0:	83 f8 04             	cmp    $0x4,%eax
  8001f3:	74 0e                	je     800203 <umain+0x1c3>
		cprintf("\nchild detected race\n");
  8001f5:	c7 04 24 be 2b 80 00 	movl   $0x802bbe,(%esp)
  8001fc:	e8 77 01 00 00       	call   800378 <cprintf>
  800201:	eb 14                	jmp    800217 <umain+0x1d7>
	else
		cprintf("\nrace didn't happen\n", max);
  800203:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
  80020a:	00 
  80020b:	c7 04 24 d4 2b 80 00 	movl   $0x802bd4,(%esp)
  800212:	e8 61 01 00 00       	call   800378 <cprintf>
}
  800217:	83 c4 20             	add    $0x20,%esp
  80021a:	5b                   	pop    %ebx
  80021b:	5e                   	pop    %esi
  80021c:	5d                   	pop    %ebp
  80021d:	c3                   	ret    

0080021e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	56                   	push   %esi
  800222:	53                   	push   %ebx
  800223:	83 ec 10             	sub    $0x10,%esp
  800226:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800229:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  80022c:	e8 54 0b 00 00       	call   800d85 <sys_getenvid>
  800231:	25 ff 03 00 00       	and    $0x3ff,%eax
  800236:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800239:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80023e:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800243:	85 db                	test   %ebx,%ebx
  800245:	7e 07                	jle    80024e <libmain+0x30>
		binaryname = argv[0];
  800247:	8b 06                	mov    (%esi),%eax
  800249:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  80024e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800252:	89 1c 24             	mov    %ebx,(%esp)
  800255:	e8 e6 fd ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  80025a:	e8 07 00 00 00       	call   800266 <exit>
}
  80025f:	83 c4 10             	add    $0x10,%esp
  800262:	5b                   	pop    %ebx
  800263:	5e                   	pop    %esi
  800264:	5d                   	pop    %ebp
  800265:	c3                   	ret    

00800266 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800266:	55                   	push   %ebp
  800267:	89 e5                	mov    %esp,%ebp
  800269:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80026c:	e8 89 14 00 00       	call   8016fa <close_all>
	sys_env_destroy(0);
  800271:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800278:	e8 b6 0a 00 00       	call   800d33 <sys_env_destroy>
}
  80027d:	c9                   	leave  
  80027e:	c3                   	ret    

0080027f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	56                   	push   %esi
  800283:	53                   	push   %ebx
  800284:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800287:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80028a:	8b 35 00 40 80 00    	mov    0x804000,%esi
  800290:	e8 f0 0a 00 00       	call   800d85 <sys_getenvid>
  800295:	8b 55 0c             	mov    0xc(%ebp),%edx
  800298:	89 54 24 10          	mov    %edx,0x10(%esp)
  80029c:	8b 55 08             	mov    0x8(%ebp),%edx
  80029f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002a3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8002a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ab:	c7 04 24 20 2c 80 00 	movl   $0x802c20,(%esp)
  8002b2:	e8 c1 00 00 00       	call   800378 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002bb:	8b 45 10             	mov    0x10(%ebp),%eax
  8002be:	89 04 24             	mov    %eax,(%esp)
  8002c1:	e8 51 00 00 00       	call   800317 <vcprintf>
	cprintf("\n");
  8002c6:	c7 04 24 37 2b 80 00 	movl   $0x802b37,(%esp)
  8002cd:	e8 a6 00 00 00       	call   800378 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002d2:	cc                   	int3   
  8002d3:	eb fd                	jmp    8002d2 <_panic+0x53>

008002d5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	53                   	push   %ebx
  8002d9:	83 ec 14             	sub    $0x14,%esp
  8002dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002df:	8b 13                	mov    (%ebx),%edx
  8002e1:	8d 42 01             	lea    0x1(%edx),%eax
  8002e4:	89 03                	mov    %eax,(%ebx)
  8002e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002ed:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002f2:	75 19                	jne    80030d <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002f4:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002fb:	00 
  8002fc:	8d 43 08             	lea    0x8(%ebx),%eax
  8002ff:	89 04 24             	mov    %eax,(%esp)
  800302:	e8 ef 09 00 00       	call   800cf6 <sys_cputs>
		b->idx = 0;
  800307:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80030d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800311:	83 c4 14             	add    $0x14,%esp
  800314:	5b                   	pop    %ebx
  800315:	5d                   	pop    %ebp
  800316:	c3                   	ret    

00800317 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800317:	55                   	push   %ebp
  800318:	89 e5                	mov    %esp,%ebp
  80031a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800320:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800327:	00 00 00 
	b.cnt = 0;
  80032a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800331:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800334:	8b 45 0c             	mov    0xc(%ebp),%eax
  800337:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80033b:	8b 45 08             	mov    0x8(%ebp),%eax
  80033e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800342:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800348:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034c:	c7 04 24 d5 02 80 00 	movl   $0x8002d5,(%esp)
  800353:	e8 b6 01 00 00       	call   80050e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800358:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80035e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800362:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800368:	89 04 24             	mov    %eax,(%esp)
  80036b:	e8 86 09 00 00       	call   800cf6 <sys_cputs>

	return b.cnt;
}
  800370:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800376:	c9                   	leave  
  800377:	c3                   	ret    

00800378 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80037e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800381:	89 44 24 04          	mov    %eax,0x4(%esp)
  800385:	8b 45 08             	mov    0x8(%ebp),%eax
  800388:	89 04 24             	mov    %eax,(%esp)
  80038b:	e8 87 ff ff ff       	call   800317 <vcprintf>
	va_end(ap);

	return cnt;
}
  800390:	c9                   	leave  
  800391:	c3                   	ret    
  800392:	66 90                	xchg   %ax,%ax
  800394:	66 90                	xchg   %ax,%ax
  800396:	66 90                	xchg   %ax,%ax
  800398:	66 90                	xchg   %ax,%ax
  80039a:	66 90                	xchg   %ax,%ax
  80039c:	66 90                	xchg   %ax,%ax
  80039e:	66 90                	xchg   %ax,%ax

008003a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	57                   	push   %edi
  8003a4:	56                   	push   %esi
  8003a5:	53                   	push   %ebx
  8003a6:	83 ec 3c             	sub    $0x3c,%esp
  8003a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ac:	89 d7                	mov    %edx,%edi
  8003ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b7:	89 c3                	mov    %eax,%ebx
  8003b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8003bf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003cd:	39 d9                	cmp    %ebx,%ecx
  8003cf:	72 05                	jb     8003d6 <printnum+0x36>
  8003d1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8003d4:	77 69                	ja     80043f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003d6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8003d9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8003dd:	83 ee 01             	sub    $0x1,%esi
  8003e0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003e8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8003ec:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8003f0:	89 c3                	mov    %eax,%ebx
  8003f2:	89 d6                	mov    %edx,%esi
  8003f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003f7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8003fa:	89 54 24 08          	mov    %edx,0x8(%esp)
  8003fe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800402:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800405:	89 04 24             	mov    %eax,(%esp)
  800408:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80040b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80040f:	e8 7c 24 00 00       	call   802890 <__udivdi3>
  800414:	89 d9                	mov    %ebx,%ecx
  800416:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80041a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80041e:	89 04 24             	mov    %eax,(%esp)
  800421:	89 54 24 04          	mov    %edx,0x4(%esp)
  800425:	89 fa                	mov    %edi,%edx
  800427:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80042a:	e8 71 ff ff ff       	call   8003a0 <printnum>
  80042f:	eb 1b                	jmp    80044c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800431:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800435:	8b 45 18             	mov    0x18(%ebp),%eax
  800438:	89 04 24             	mov    %eax,(%esp)
  80043b:	ff d3                	call   *%ebx
  80043d:	eb 03                	jmp    800442 <printnum+0xa2>
  80043f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800442:	83 ee 01             	sub    $0x1,%esi
  800445:	85 f6                	test   %esi,%esi
  800447:	7f e8                	jg     800431 <printnum+0x91>
  800449:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80044c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800450:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800454:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800457:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80045a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80045e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800462:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800465:	89 04 24             	mov    %eax,(%esp)
  800468:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80046b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80046f:	e8 4c 25 00 00       	call   8029c0 <__umoddi3>
  800474:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800478:	0f be 80 43 2c 80 00 	movsbl 0x802c43(%eax),%eax
  80047f:	89 04 24             	mov    %eax,(%esp)
  800482:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800485:	ff d0                	call   *%eax
}
  800487:	83 c4 3c             	add    $0x3c,%esp
  80048a:	5b                   	pop    %ebx
  80048b:	5e                   	pop    %esi
  80048c:	5f                   	pop    %edi
  80048d:	5d                   	pop    %ebp
  80048e:	c3                   	ret    

0080048f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80048f:	55                   	push   %ebp
  800490:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800492:	83 fa 01             	cmp    $0x1,%edx
  800495:	7e 0e                	jle    8004a5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800497:	8b 10                	mov    (%eax),%edx
  800499:	8d 4a 08             	lea    0x8(%edx),%ecx
  80049c:	89 08                	mov    %ecx,(%eax)
  80049e:	8b 02                	mov    (%edx),%eax
  8004a0:	8b 52 04             	mov    0x4(%edx),%edx
  8004a3:	eb 22                	jmp    8004c7 <getuint+0x38>
	else if (lflag)
  8004a5:	85 d2                	test   %edx,%edx
  8004a7:	74 10                	je     8004b9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004a9:	8b 10                	mov    (%eax),%edx
  8004ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ae:	89 08                	mov    %ecx,(%eax)
  8004b0:	8b 02                	mov    (%edx),%eax
  8004b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004b7:	eb 0e                	jmp    8004c7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004b9:	8b 10                	mov    (%eax),%edx
  8004bb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004be:	89 08                	mov    %ecx,(%eax)
  8004c0:	8b 02                	mov    (%edx),%eax
  8004c2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004c7:	5d                   	pop    %ebp
  8004c8:	c3                   	ret    

008004c9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004c9:	55                   	push   %ebp
  8004ca:	89 e5                	mov    %esp,%ebp
  8004cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004cf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004d3:	8b 10                	mov    (%eax),%edx
  8004d5:	3b 50 04             	cmp    0x4(%eax),%edx
  8004d8:	73 0a                	jae    8004e4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004da:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004dd:	89 08                	mov    %ecx,(%eax)
  8004df:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e2:	88 02                	mov    %al,(%edx)
}
  8004e4:	5d                   	pop    %ebp
  8004e5:	c3                   	ret    

008004e6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
  8004e9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004ec:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8004f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800501:	8b 45 08             	mov    0x8(%ebp),%eax
  800504:	89 04 24             	mov    %eax,(%esp)
  800507:	e8 02 00 00 00       	call   80050e <vprintfmt>
	va_end(ap);
}
  80050c:	c9                   	leave  
  80050d:	c3                   	ret    

0080050e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80050e:	55                   	push   %ebp
  80050f:	89 e5                	mov    %esp,%ebp
  800511:	57                   	push   %edi
  800512:	56                   	push   %esi
  800513:	53                   	push   %ebx
  800514:	83 ec 3c             	sub    $0x3c,%esp
  800517:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80051a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80051d:	eb 14                	jmp    800533 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80051f:	85 c0                	test   %eax,%eax
  800521:	0f 84 b3 03 00 00    	je     8008da <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800527:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80052b:	89 04 24             	mov    %eax,(%esp)
  80052e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800531:	89 f3                	mov    %esi,%ebx
  800533:	8d 73 01             	lea    0x1(%ebx),%esi
  800536:	0f b6 03             	movzbl (%ebx),%eax
  800539:	83 f8 25             	cmp    $0x25,%eax
  80053c:	75 e1                	jne    80051f <vprintfmt+0x11>
  80053e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800542:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800549:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800550:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800557:	ba 00 00 00 00       	mov    $0x0,%edx
  80055c:	eb 1d                	jmp    80057b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800560:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800564:	eb 15                	jmp    80057b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800566:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800568:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80056c:	eb 0d                	jmp    80057b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80056e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800571:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800574:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80057e:	0f b6 0e             	movzbl (%esi),%ecx
  800581:	0f b6 c1             	movzbl %cl,%eax
  800584:	83 e9 23             	sub    $0x23,%ecx
  800587:	80 f9 55             	cmp    $0x55,%cl
  80058a:	0f 87 2a 03 00 00    	ja     8008ba <vprintfmt+0x3ac>
  800590:	0f b6 c9             	movzbl %cl,%ecx
  800593:	ff 24 8d 80 2d 80 00 	jmp    *0x802d80(,%ecx,4)
  80059a:	89 de                	mov    %ebx,%esi
  80059c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005a1:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8005a4:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8005a8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005ab:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8005ae:	83 fb 09             	cmp    $0x9,%ebx
  8005b1:	77 36                	ja     8005e9 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005b3:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005b6:	eb e9                	jmp    8005a1 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 48 04             	lea    0x4(%eax),%ecx
  8005be:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005c1:	8b 00                	mov    (%eax),%eax
  8005c3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c6:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005c8:	eb 22                	jmp    8005ec <vprintfmt+0xde>
  8005ca:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005cd:	85 c9                	test   %ecx,%ecx
  8005cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d4:	0f 49 c1             	cmovns %ecx,%eax
  8005d7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005da:	89 de                	mov    %ebx,%esi
  8005dc:	eb 9d                	jmp    80057b <vprintfmt+0x6d>
  8005de:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005e0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8005e7:	eb 92                	jmp    80057b <vprintfmt+0x6d>
  8005e9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8005ec:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005f0:	79 89                	jns    80057b <vprintfmt+0x6d>
  8005f2:	e9 77 ff ff ff       	jmp    80056e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005f7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fa:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005fc:	e9 7a ff ff ff       	jmp    80057b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800601:	8b 45 14             	mov    0x14(%ebp),%eax
  800604:	8d 50 04             	lea    0x4(%eax),%edx
  800607:	89 55 14             	mov    %edx,0x14(%ebp)
  80060a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80060e:	8b 00                	mov    (%eax),%eax
  800610:	89 04 24             	mov    %eax,(%esp)
  800613:	ff 55 08             	call   *0x8(%ebp)
			break;
  800616:	e9 18 ff ff ff       	jmp    800533 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8d 50 04             	lea    0x4(%eax),%edx
  800621:	89 55 14             	mov    %edx,0x14(%ebp)
  800624:	8b 00                	mov    (%eax),%eax
  800626:	99                   	cltd   
  800627:	31 d0                	xor    %edx,%eax
  800629:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80062b:	83 f8 0f             	cmp    $0xf,%eax
  80062e:	7f 0b                	jg     80063b <vprintfmt+0x12d>
  800630:	8b 14 85 e0 2e 80 00 	mov    0x802ee0(,%eax,4),%edx
  800637:	85 d2                	test   %edx,%edx
  800639:	75 20                	jne    80065b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80063b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80063f:	c7 44 24 08 5b 2c 80 	movl   $0x802c5b,0x8(%esp)
  800646:	00 
  800647:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80064b:	8b 45 08             	mov    0x8(%ebp),%eax
  80064e:	89 04 24             	mov    %eax,(%esp)
  800651:	e8 90 fe ff ff       	call   8004e6 <printfmt>
  800656:	e9 d8 fe ff ff       	jmp    800533 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80065b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80065f:	c7 44 24 08 cd 30 80 	movl   $0x8030cd,0x8(%esp)
  800666:	00 
  800667:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80066b:	8b 45 08             	mov    0x8(%ebp),%eax
  80066e:	89 04 24             	mov    %eax,(%esp)
  800671:	e8 70 fe ff ff       	call   8004e6 <printfmt>
  800676:	e9 b8 fe ff ff       	jmp    800533 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80067e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800681:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8d 50 04             	lea    0x4(%eax),%edx
  80068a:	89 55 14             	mov    %edx,0x14(%ebp)
  80068d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80068f:	85 f6                	test   %esi,%esi
  800691:	b8 54 2c 80 00       	mov    $0x802c54,%eax
  800696:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800699:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80069d:	0f 84 97 00 00 00    	je     80073a <vprintfmt+0x22c>
  8006a3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8006a7:	0f 8e 9b 00 00 00    	jle    800748 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ad:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006b1:	89 34 24             	mov    %esi,(%esp)
  8006b4:	e8 cf 02 00 00       	call   800988 <strnlen>
  8006b9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006bc:	29 c2                	sub    %eax,%edx
  8006be:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8006c1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8006c5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006c8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ce:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006d1:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d3:	eb 0f                	jmp    8006e4 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8006d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006dc:	89 04 24             	mov    %eax,(%esp)
  8006df:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e1:	83 eb 01             	sub    $0x1,%ebx
  8006e4:	85 db                	test   %ebx,%ebx
  8006e6:	7f ed                	jg     8006d5 <vprintfmt+0x1c7>
  8006e8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006eb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006ee:	85 d2                	test   %edx,%edx
  8006f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f5:	0f 49 c2             	cmovns %edx,%eax
  8006f8:	29 c2                	sub    %eax,%edx
  8006fa:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006fd:	89 d7                	mov    %edx,%edi
  8006ff:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800702:	eb 50                	jmp    800754 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800704:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800708:	74 1e                	je     800728 <vprintfmt+0x21a>
  80070a:	0f be d2             	movsbl %dl,%edx
  80070d:	83 ea 20             	sub    $0x20,%edx
  800710:	83 fa 5e             	cmp    $0x5e,%edx
  800713:	76 13                	jbe    800728 <vprintfmt+0x21a>
					putch('?', putdat);
  800715:	8b 45 0c             	mov    0xc(%ebp),%eax
  800718:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800723:	ff 55 08             	call   *0x8(%ebp)
  800726:	eb 0d                	jmp    800735 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800728:	8b 55 0c             	mov    0xc(%ebp),%edx
  80072b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80072f:	89 04 24             	mov    %eax,(%esp)
  800732:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800735:	83 ef 01             	sub    $0x1,%edi
  800738:	eb 1a                	jmp    800754 <vprintfmt+0x246>
  80073a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80073d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800740:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800743:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800746:	eb 0c                	jmp    800754 <vprintfmt+0x246>
  800748:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80074b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80074e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800751:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800754:	83 c6 01             	add    $0x1,%esi
  800757:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80075b:	0f be c2             	movsbl %dl,%eax
  80075e:	85 c0                	test   %eax,%eax
  800760:	74 27                	je     800789 <vprintfmt+0x27b>
  800762:	85 db                	test   %ebx,%ebx
  800764:	78 9e                	js     800704 <vprintfmt+0x1f6>
  800766:	83 eb 01             	sub    $0x1,%ebx
  800769:	79 99                	jns    800704 <vprintfmt+0x1f6>
  80076b:	89 f8                	mov    %edi,%eax
  80076d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800770:	8b 75 08             	mov    0x8(%ebp),%esi
  800773:	89 c3                	mov    %eax,%ebx
  800775:	eb 1a                	jmp    800791 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800777:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80077b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800782:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800784:	83 eb 01             	sub    $0x1,%ebx
  800787:	eb 08                	jmp    800791 <vprintfmt+0x283>
  800789:	89 fb                	mov    %edi,%ebx
  80078b:	8b 75 08             	mov    0x8(%ebp),%esi
  80078e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800791:	85 db                	test   %ebx,%ebx
  800793:	7f e2                	jg     800777 <vprintfmt+0x269>
  800795:	89 75 08             	mov    %esi,0x8(%ebp)
  800798:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80079b:	e9 93 fd ff ff       	jmp    800533 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007a0:	83 fa 01             	cmp    $0x1,%edx
  8007a3:	7e 16                	jle    8007bb <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  8007a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a8:	8d 50 08             	lea    0x8(%eax),%edx
  8007ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ae:	8b 50 04             	mov    0x4(%eax),%edx
  8007b1:	8b 00                	mov    (%eax),%eax
  8007b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007b6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007b9:	eb 32                	jmp    8007ed <vprintfmt+0x2df>
	else if (lflag)
  8007bb:	85 d2                	test   %edx,%edx
  8007bd:	74 18                	je     8007d7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8007bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c2:	8d 50 04             	lea    0x4(%eax),%edx
  8007c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c8:	8b 30                	mov    (%eax),%esi
  8007ca:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8007cd:	89 f0                	mov    %esi,%eax
  8007cf:	c1 f8 1f             	sar    $0x1f,%eax
  8007d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007d5:	eb 16                	jmp    8007ed <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8007d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007da:	8d 50 04             	lea    0x4(%eax),%edx
  8007dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e0:	8b 30                	mov    (%eax),%esi
  8007e2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8007e5:	89 f0                	mov    %esi,%eax
  8007e7:	c1 f8 1f             	sar    $0x1f,%eax
  8007ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007f3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007f8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007fc:	0f 89 80 00 00 00    	jns    800882 <vprintfmt+0x374>
				putch('-', putdat);
  800802:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800806:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80080d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800810:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800813:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800816:	f7 d8                	neg    %eax
  800818:	83 d2 00             	adc    $0x0,%edx
  80081b:	f7 da                	neg    %edx
			}
			base = 10;
  80081d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800822:	eb 5e                	jmp    800882 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800824:	8d 45 14             	lea    0x14(%ebp),%eax
  800827:	e8 63 fc ff ff       	call   80048f <getuint>
			base = 10;
  80082c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800831:	eb 4f                	jmp    800882 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800833:	8d 45 14             	lea    0x14(%ebp),%eax
  800836:	e8 54 fc ff ff       	call   80048f <getuint>
			base = 8;
  80083b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800840:	eb 40                	jmp    800882 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800842:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800846:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80084d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800850:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800854:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80085b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80085e:	8b 45 14             	mov    0x14(%ebp),%eax
  800861:	8d 50 04             	lea    0x4(%eax),%edx
  800864:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800867:	8b 00                	mov    (%eax),%eax
  800869:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80086e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800873:	eb 0d                	jmp    800882 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800875:	8d 45 14             	lea    0x14(%ebp),%eax
  800878:	e8 12 fc ff ff       	call   80048f <getuint>
			base = 16;
  80087d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800882:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800886:	89 74 24 10          	mov    %esi,0x10(%esp)
  80088a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80088d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800891:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800895:	89 04 24             	mov    %eax,(%esp)
  800898:	89 54 24 04          	mov    %edx,0x4(%esp)
  80089c:	89 fa                	mov    %edi,%edx
  80089e:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a1:	e8 fa fa ff ff       	call   8003a0 <printnum>
			break;
  8008a6:	e9 88 fc ff ff       	jmp    800533 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008ab:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008af:	89 04 24             	mov    %eax,(%esp)
  8008b2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008b5:	e9 79 fc ff ff       	jmp    800533 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008ba:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008be:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008c5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008c8:	89 f3                	mov    %esi,%ebx
  8008ca:	eb 03                	jmp    8008cf <vprintfmt+0x3c1>
  8008cc:	83 eb 01             	sub    $0x1,%ebx
  8008cf:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8008d3:	75 f7                	jne    8008cc <vprintfmt+0x3be>
  8008d5:	e9 59 fc ff ff       	jmp    800533 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8008da:	83 c4 3c             	add    $0x3c,%esp
  8008dd:	5b                   	pop    %ebx
  8008de:	5e                   	pop    %esi
  8008df:	5f                   	pop    %edi
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	83 ec 28             	sub    $0x28,%esp
  8008e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008f1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008f5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008ff:	85 c0                	test   %eax,%eax
  800901:	74 30                	je     800933 <vsnprintf+0x51>
  800903:	85 d2                	test   %edx,%edx
  800905:	7e 2c                	jle    800933 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800907:	8b 45 14             	mov    0x14(%ebp),%eax
  80090a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80090e:	8b 45 10             	mov    0x10(%ebp),%eax
  800911:	89 44 24 08          	mov    %eax,0x8(%esp)
  800915:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800918:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091c:	c7 04 24 c9 04 80 00 	movl   $0x8004c9,(%esp)
  800923:	e8 e6 fb ff ff       	call   80050e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800928:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80092b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80092e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800931:	eb 05                	jmp    800938 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800933:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800938:	c9                   	leave  
  800939:	c3                   	ret    

0080093a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800940:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800943:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800947:	8b 45 10             	mov    0x10(%ebp),%eax
  80094a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80094e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800951:	89 44 24 04          	mov    %eax,0x4(%esp)
  800955:	8b 45 08             	mov    0x8(%ebp),%eax
  800958:	89 04 24             	mov    %eax,(%esp)
  80095b:	e8 82 ff ff ff       	call   8008e2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800960:	c9                   	leave  
  800961:	c3                   	ret    
  800962:	66 90                	xchg   %ax,%ax
  800964:	66 90                	xchg   %ax,%ax
  800966:	66 90                	xchg   %ax,%ax
  800968:	66 90                	xchg   %ax,%ax
  80096a:	66 90                	xchg   %ax,%ax
  80096c:	66 90                	xchg   %ax,%ax
  80096e:	66 90                	xchg   %ax,%ax

00800970 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800976:	b8 00 00 00 00       	mov    $0x0,%eax
  80097b:	eb 03                	jmp    800980 <strlen+0x10>
		n++;
  80097d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800980:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800984:	75 f7                	jne    80097d <strlen+0xd>
		n++;
	return n;
}
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800991:	b8 00 00 00 00       	mov    $0x0,%eax
  800996:	eb 03                	jmp    80099b <strnlen+0x13>
		n++;
  800998:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80099b:	39 d0                	cmp    %edx,%eax
  80099d:	74 06                	je     8009a5 <strnlen+0x1d>
  80099f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009a3:	75 f3                	jne    800998 <strnlen+0x10>
		n++;
	return n;
}
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	53                   	push   %ebx
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009b1:	89 c2                	mov    %eax,%edx
  8009b3:	83 c2 01             	add    $0x1,%edx
  8009b6:	83 c1 01             	add    $0x1,%ecx
  8009b9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009bd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009c0:	84 db                	test   %bl,%bl
  8009c2:	75 ef                	jne    8009b3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009c4:	5b                   	pop    %ebx
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	53                   	push   %ebx
  8009cb:	83 ec 08             	sub    $0x8,%esp
  8009ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009d1:	89 1c 24             	mov    %ebx,(%esp)
  8009d4:	e8 97 ff ff ff       	call   800970 <strlen>
	strcpy(dst + len, src);
  8009d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009dc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009e0:	01 d8                	add    %ebx,%eax
  8009e2:	89 04 24             	mov    %eax,(%esp)
  8009e5:	e8 bd ff ff ff       	call   8009a7 <strcpy>
	return dst;
}
  8009ea:	89 d8                	mov    %ebx,%eax
  8009ec:	83 c4 08             	add    $0x8,%esp
  8009ef:	5b                   	pop    %ebx
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	56                   	push   %esi
  8009f6:	53                   	push   %ebx
  8009f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009fd:	89 f3                	mov    %esi,%ebx
  8009ff:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a02:	89 f2                	mov    %esi,%edx
  800a04:	eb 0f                	jmp    800a15 <strncpy+0x23>
		*dst++ = *src;
  800a06:	83 c2 01             	add    $0x1,%edx
  800a09:	0f b6 01             	movzbl (%ecx),%eax
  800a0c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a0f:	80 39 01             	cmpb   $0x1,(%ecx)
  800a12:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a15:	39 da                	cmp    %ebx,%edx
  800a17:	75 ed                	jne    800a06 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a19:	89 f0                	mov    %esi,%eax
  800a1b:	5b                   	pop    %ebx
  800a1c:	5e                   	pop    %esi
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	56                   	push   %esi
  800a23:	53                   	push   %ebx
  800a24:	8b 75 08             	mov    0x8(%ebp),%esi
  800a27:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a2d:	89 f0                	mov    %esi,%eax
  800a2f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a33:	85 c9                	test   %ecx,%ecx
  800a35:	75 0b                	jne    800a42 <strlcpy+0x23>
  800a37:	eb 1d                	jmp    800a56 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a39:	83 c0 01             	add    $0x1,%eax
  800a3c:	83 c2 01             	add    $0x1,%edx
  800a3f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a42:	39 d8                	cmp    %ebx,%eax
  800a44:	74 0b                	je     800a51 <strlcpy+0x32>
  800a46:	0f b6 0a             	movzbl (%edx),%ecx
  800a49:	84 c9                	test   %cl,%cl
  800a4b:	75 ec                	jne    800a39 <strlcpy+0x1a>
  800a4d:	89 c2                	mov    %eax,%edx
  800a4f:	eb 02                	jmp    800a53 <strlcpy+0x34>
  800a51:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800a53:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800a56:	29 f0                	sub    %esi,%eax
}
  800a58:	5b                   	pop    %ebx
  800a59:	5e                   	pop    %esi
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a62:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a65:	eb 06                	jmp    800a6d <strcmp+0x11>
		p++, q++;
  800a67:	83 c1 01             	add    $0x1,%ecx
  800a6a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a6d:	0f b6 01             	movzbl (%ecx),%eax
  800a70:	84 c0                	test   %al,%al
  800a72:	74 04                	je     800a78 <strcmp+0x1c>
  800a74:	3a 02                	cmp    (%edx),%al
  800a76:	74 ef                	je     800a67 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a78:	0f b6 c0             	movzbl %al,%eax
  800a7b:	0f b6 12             	movzbl (%edx),%edx
  800a7e:	29 d0                	sub    %edx,%eax
}
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	53                   	push   %ebx
  800a86:	8b 45 08             	mov    0x8(%ebp),%eax
  800a89:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8c:	89 c3                	mov    %eax,%ebx
  800a8e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a91:	eb 06                	jmp    800a99 <strncmp+0x17>
		n--, p++, q++;
  800a93:	83 c0 01             	add    $0x1,%eax
  800a96:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a99:	39 d8                	cmp    %ebx,%eax
  800a9b:	74 15                	je     800ab2 <strncmp+0x30>
  800a9d:	0f b6 08             	movzbl (%eax),%ecx
  800aa0:	84 c9                	test   %cl,%cl
  800aa2:	74 04                	je     800aa8 <strncmp+0x26>
  800aa4:	3a 0a                	cmp    (%edx),%cl
  800aa6:	74 eb                	je     800a93 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa8:	0f b6 00             	movzbl (%eax),%eax
  800aab:	0f b6 12             	movzbl (%edx),%edx
  800aae:	29 d0                	sub    %edx,%eax
  800ab0:	eb 05                	jmp    800ab7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ab2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ab7:	5b                   	pop    %ebx
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac4:	eb 07                	jmp    800acd <strchr+0x13>
		if (*s == c)
  800ac6:	38 ca                	cmp    %cl,%dl
  800ac8:	74 0f                	je     800ad9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aca:	83 c0 01             	add    $0x1,%eax
  800acd:	0f b6 10             	movzbl (%eax),%edx
  800ad0:	84 d2                	test   %dl,%dl
  800ad2:	75 f2                	jne    800ac6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ad4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ae5:	eb 07                	jmp    800aee <strfind+0x13>
		if (*s == c)
  800ae7:	38 ca                	cmp    %cl,%dl
  800ae9:	74 0a                	je     800af5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aeb:	83 c0 01             	add    $0x1,%eax
  800aee:	0f b6 10             	movzbl (%eax),%edx
  800af1:	84 d2                	test   %dl,%dl
  800af3:	75 f2                	jne    800ae7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	57                   	push   %edi
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
  800afd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b00:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b03:	85 c9                	test   %ecx,%ecx
  800b05:	74 36                	je     800b3d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b07:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b0d:	75 28                	jne    800b37 <memset+0x40>
  800b0f:	f6 c1 03             	test   $0x3,%cl
  800b12:	75 23                	jne    800b37 <memset+0x40>
		c &= 0xFF;
  800b14:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b18:	89 d3                	mov    %edx,%ebx
  800b1a:	c1 e3 08             	shl    $0x8,%ebx
  800b1d:	89 d6                	mov    %edx,%esi
  800b1f:	c1 e6 18             	shl    $0x18,%esi
  800b22:	89 d0                	mov    %edx,%eax
  800b24:	c1 e0 10             	shl    $0x10,%eax
  800b27:	09 f0                	or     %esi,%eax
  800b29:	09 c2                	or     %eax,%edx
  800b2b:	89 d0                	mov    %edx,%eax
  800b2d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b2f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b32:	fc                   	cld    
  800b33:	f3 ab                	rep stos %eax,%es:(%edi)
  800b35:	eb 06                	jmp    800b3d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3a:	fc                   	cld    
  800b3b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b3d:	89 f8                	mov    %edi,%eax
  800b3f:	5b                   	pop    %ebx
  800b40:	5e                   	pop    %esi
  800b41:	5f                   	pop    %edi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b4f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b52:	39 c6                	cmp    %eax,%esi
  800b54:	73 35                	jae    800b8b <memmove+0x47>
  800b56:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b59:	39 d0                	cmp    %edx,%eax
  800b5b:	73 2e                	jae    800b8b <memmove+0x47>
		s += n;
		d += n;
  800b5d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b60:	89 d6                	mov    %edx,%esi
  800b62:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b64:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b6a:	75 13                	jne    800b7f <memmove+0x3b>
  800b6c:	f6 c1 03             	test   $0x3,%cl
  800b6f:	75 0e                	jne    800b7f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b71:	83 ef 04             	sub    $0x4,%edi
  800b74:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b77:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b7a:	fd                   	std    
  800b7b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b7d:	eb 09                	jmp    800b88 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b7f:	83 ef 01             	sub    $0x1,%edi
  800b82:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b85:	fd                   	std    
  800b86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b88:	fc                   	cld    
  800b89:	eb 1d                	jmp    800ba8 <memmove+0x64>
  800b8b:	89 f2                	mov    %esi,%edx
  800b8d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b8f:	f6 c2 03             	test   $0x3,%dl
  800b92:	75 0f                	jne    800ba3 <memmove+0x5f>
  800b94:	f6 c1 03             	test   $0x3,%cl
  800b97:	75 0a                	jne    800ba3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b99:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b9c:	89 c7                	mov    %eax,%edi
  800b9e:	fc                   	cld    
  800b9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba1:	eb 05                	jmp    800ba8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ba3:	89 c7                	mov    %eax,%edi
  800ba5:	fc                   	cld    
  800ba6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ba8:	5e                   	pop    %esi
  800ba9:	5f                   	pop    %edi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bb2:	8b 45 10             	mov    0x10(%ebp),%eax
  800bb5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc3:	89 04 24             	mov    %eax,(%esp)
  800bc6:	e8 79 ff ff ff       	call   800b44 <memmove>
}
  800bcb:	c9                   	leave  
  800bcc:	c3                   	ret    

00800bcd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
  800bd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd8:	89 d6                	mov    %edx,%esi
  800bda:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bdd:	eb 1a                	jmp    800bf9 <memcmp+0x2c>
		if (*s1 != *s2)
  800bdf:	0f b6 02             	movzbl (%edx),%eax
  800be2:	0f b6 19             	movzbl (%ecx),%ebx
  800be5:	38 d8                	cmp    %bl,%al
  800be7:	74 0a                	je     800bf3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800be9:	0f b6 c0             	movzbl %al,%eax
  800bec:	0f b6 db             	movzbl %bl,%ebx
  800bef:	29 d8                	sub    %ebx,%eax
  800bf1:	eb 0f                	jmp    800c02 <memcmp+0x35>
		s1++, s2++;
  800bf3:	83 c2 01             	add    $0x1,%edx
  800bf6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bf9:	39 f2                	cmp    %esi,%edx
  800bfb:	75 e2                	jne    800bdf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bfd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c0f:	89 c2                	mov    %eax,%edx
  800c11:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c14:	eb 07                	jmp    800c1d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c16:	38 08                	cmp    %cl,(%eax)
  800c18:	74 07                	je     800c21 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c1a:	83 c0 01             	add    $0x1,%eax
  800c1d:	39 d0                	cmp    %edx,%eax
  800c1f:	72 f5                	jb     800c16 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c2f:	eb 03                	jmp    800c34 <strtol+0x11>
		s++;
  800c31:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c34:	0f b6 0a             	movzbl (%edx),%ecx
  800c37:	80 f9 09             	cmp    $0x9,%cl
  800c3a:	74 f5                	je     800c31 <strtol+0xe>
  800c3c:	80 f9 20             	cmp    $0x20,%cl
  800c3f:	74 f0                	je     800c31 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c41:	80 f9 2b             	cmp    $0x2b,%cl
  800c44:	75 0a                	jne    800c50 <strtol+0x2d>
		s++;
  800c46:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c49:	bf 00 00 00 00       	mov    $0x0,%edi
  800c4e:	eb 11                	jmp    800c61 <strtol+0x3e>
  800c50:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c55:	80 f9 2d             	cmp    $0x2d,%cl
  800c58:	75 07                	jne    800c61 <strtol+0x3e>
		s++, neg = 1;
  800c5a:	8d 52 01             	lea    0x1(%edx),%edx
  800c5d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c61:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800c66:	75 15                	jne    800c7d <strtol+0x5a>
  800c68:	80 3a 30             	cmpb   $0x30,(%edx)
  800c6b:	75 10                	jne    800c7d <strtol+0x5a>
  800c6d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c71:	75 0a                	jne    800c7d <strtol+0x5a>
		s += 2, base = 16;
  800c73:	83 c2 02             	add    $0x2,%edx
  800c76:	b8 10 00 00 00       	mov    $0x10,%eax
  800c7b:	eb 10                	jmp    800c8d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800c7d:	85 c0                	test   %eax,%eax
  800c7f:	75 0c                	jne    800c8d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c81:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c83:	80 3a 30             	cmpb   $0x30,(%edx)
  800c86:	75 05                	jne    800c8d <strtol+0x6a>
		s++, base = 8;
  800c88:	83 c2 01             	add    $0x1,%edx
  800c8b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800c8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c92:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c95:	0f b6 0a             	movzbl (%edx),%ecx
  800c98:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c9b:	89 f0                	mov    %esi,%eax
  800c9d:	3c 09                	cmp    $0x9,%al
  800c9f:	77 08                	ja     800ca9 <strtol+0x86>
			dig = *s - '0';
  800ca1:	0f be c9             	movsbl %cl,%ecx
  800ca4:	83 e9 30             	sub    $0x30,%ecx
  800ca7:	eb 20                	jmp    800cc9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800ca9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800cac:	89 f0                	mov    %esi,%eax
  800cae:	3c 19                	cmp    $0x19,%al
  800cb0:	77 08                	ja     800cba <strtol+0x97>
			dig = *s - 'a' + 10;
  800cb2:	0f be c9             	movsbl %cl,%ecx
  800cb5:	83 e9 57             	sub    $0x57,%ecx
  800cb8:	eb 0f                	jmp    800cc9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800cba:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800cbd:	89 f0                	mov    %esi,%eax
  800cbf:	3c 19                	cmp    $0x19,%al
  800cc1:	77 16                	ja     800cd9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800cc3:	0f be c9             	movsbl %cl,%ecx
  800cc6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cc9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800ccc:	7d 0f                	jge    800cdd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800cce:	83 c2 01             	add    $0x1,%edx
  800cd1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800cd5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800cd7:	eb bc                	jmp    800c95 <strtol+0x72>
  800cd9:	89 d8                	mov    %ebx,%eax
  800cdb:	eb 02                	jmp    800cdf <strtol+0xbc>
  800cdd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800cdf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ce3:	74 05                	je     800cea <strtol+0xc7>
		*endptr = (char *) s;
  800ce5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ce8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800cea:	f7 d8                	neg    %eax
  800cec:	85 ff                	test   %edi,%edi
  800cee:	0f 44 c3             	cmove  %ebx,%eax
}
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	57                   	push   %edi
  800cfa:	56                   	push   %esi
  800cfb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfc:	b8 00 00 00 00       	mov    $0x0,%eax
  800d01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d04:	8b 55 08             	mov    0x8(%ebp),%edx
  800d07:	89 c3                	mov    %eax,%ebx
  800d09:	89 c7                	mov    %eax,%edi
  800d0b:	89 c6                	mov    %eax,%esi
  800d0d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d0f:	5b                   	pop    %ebx
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1f:	b8 01 00 00 00       	mov    $0x1,%eax
  800d24:	89 d1                	mov    %edx,%ecx
  800d26:	89 d3                	mov    %edx,%ebx
  800d28:	89 d7                	mov    %edx,%edi
  800d2a:	89 d6                	mov    %edx,%esi
  800d2c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	57                   	push   %edi
  800d37:	56                   	push   %esi
  800d38:	53                   	push   %ebx
  800d39:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d41:	b8 03 00 00 00       	mov    $0x3,%eax
  800d46:	8b 55 08             	mov    0x8(%ebp),%edx
  800d49:	89 cb                	mov    %ecx,%ebx
  800d4b:	89 cf                	mov    %ecx,%edi
  800d4d:	89 ce                	mov    %ecx,%esi
  800d4f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d51:	85 c0                	test   %eax,%eax
  800d53:	7e 28                	jle    800d7d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d55:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d59:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d60:	00 
  800d61:	c7 44 24 08 3f 2f 80 	movl   $0x802f3f,0x8(%esp)
  800d68:	00 
  800d69:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d70:	00 
  800d71:	c7 04 24 5c 2f 80 00 	movl   $0x802f5c,(%esp)
  800d78:	e8 02 f5 ff ff       	call   80027f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d7d:	83 c4 2c             	add    $0x2c,%esp
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	57                   	push   %edi
  800d89:	56                   	push   %esi
  800d8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d90:	b8 02 00 00 00       	mov    $0x2,%eax
  800d95:	89 d1                	mov    %edx,%ecx
  800d97:	89 d3                	mov    %edx,%ebx
  800d99:	89 d7                	mov    %edx,%edi
  800d9b:	89 d6                	mov    %edx,%esi
  800d9d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d9f:	5b                   	pop    %ebx
  800da0:	5e                   	pop    %esi
  800da1:	5f                   	pop    %edi
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <sys_yield>:

void
sys_yield(void)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	57                   	push   %edi
  800da8:	56                   	push   %esi
  800da9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daa:	ba 00 00 00 00       	mov    $0x0,%edx
  800daf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800db4:	89 d1                	mov    %edx,%ecx
  800db6:	89 d3                	mov    %edx,%ebx
  800db8:	89 d7                	mov    %edx,%edi
  800dba:	89 d6                	mov    %edx,%esi
  800dbc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dbe:	5b                   	pop    %ebx
  800dbf:	5e                   	pop    %esi
  800dc0:	5f                   	pop    %edi
  800dc1:	5d                   	pop    %ebp
  800dc2:	c3                   	ret    

00800dc3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	57                   	push   %edi
  800dc7:	56                   	push   %esi
  800dc8:	53                   	push   %ebx
  800dc9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcc:	be 00 00 00 00       	mov    $0x0,%esi
  800dd1:	b8 04 00 00 00       	mov    $0x4,%eax
  800dd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ddf:	89 f7                	mov    %esi,%edi
  800de1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de3:	85 c0                	test   %eax,%eax
  800de5:	7e 28                	jle    800e0f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800deb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800df2:	00 
  800df3:	c7 44 24 08 3f 2f 80 	movl   $0x802f3f,0x8(%esp)
  800dfa:	00 
  800dfb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e02:	00 
  800e03:	c7 04 24 5c 2f 80 00 	movl   $0x802f5c,(%esp)
  800e0a:	e8 70 f4 ff ff       	call   80027f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e0f:	83 c4 2c             	add    $0x2c,%esp
  800e12:	5b                   	pop    %ebx
  800e13:	5e                   	pop    %esi
  800e14:	5f                   	pop    %edi
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    

00800e17 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
  800e1a:	57                   	push   %edi
  800e1b:	56                   	push   %esi
  800e1c:	53                   	push   %ebx
  800e1d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e20:	b8 05 00 00 00       	mov    $0x5,%eax
  800e25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e28:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e2e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e31:	8b 75 18             	mov    0x18(%ebp),%esi
  800e34:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e36:	85 c0                	test   %eax,%eax
  800e38:	7e 28                	jle    800e62 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e45:	00 
  800e46:	c7 44 24 08 3f 2f 80 	movl   $0x802f3f,0x8(%esp)
  800e4d:	00 
  800e4e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e55:	00 
  800e56:	c7 04 24 5c 2f 80 00 	movl   $0x802f5c,(%esp)
  800e5d:	e8 1d f4 ff ff       	call   80027f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e62:	83 c4 2c             	add    $0x2c,%esp
  800e65:	5b                   	pop    %ebx
  800e66:	5e                   	pop    %esi
  800e67:	5f                   	pop    %edi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    

00800e6a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800e78:	b8 06 00 00 00       	mov    $0x6,%eax
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
  800e8b:	7e 28                	jle    800eb5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e91:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e98:	00 
  800e99:	c7 44 24 08 3f 2f 80 	movl   $0x802f3f,0x8(%esp)
  800ea0:	00 
  800ea1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea8:	00 
  800ea9:	c7 04 24 5c 2f 80 00 	movl   $0x802f5c,(%esp)
  800eb0:	e8 ca f3 ff ff       	call   80027f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800eb5:	83 c4 2c             	add    $0x2c,%esp
  800eb8:	5b                   	pop    %ebx
  800eb9:	5e                   	pop    %esi
  800eba:	5f                   	pop    %edi
  800ebb:	5d                   	pop    %ebp
  800ebc:	c3                   	ret    

00800ebd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800ecb:	b8 08 00 00 00       	mov    $0x8,%eax
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
  800ede:	7e 28                	jle    800f08 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800eeb:	00 
  800eec:	c7 44 24 08 3f 2f 80 	movl   $0x802f3f,0x8(%esp)
  800ef3:	00 
  800ef4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800efb:	00 
  800efc:	c7 04 24 5c 2f 80 00 	movl   $0x802f5c,(%esp)
  800f03:	e8 77 f3 ff ff       	call   80027f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f08:	83 c4 2c             	add    $0x2c,%esp
  800f0b:	5b                   	pop    %ebx
  800f0c:	5e                   	pop    %esi
  800f0d:	5f                   	pop    %edi
  800f0e:	5d                   	pop    %ebp
  800f0f:	c3                   	ret    

00800f10 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	57                   	push   %edi
  800f14:	56                   	push   %esi
  800f15:	53                   	push   %ebx
  800f16:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f1e:	b8 09 00 00 00       	mov    $0x9,%eax
  800f23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f26:	8b 55 08             	mov    0x8(%ebp),%edx
  800f29:	89 df                	mov    %ebx,%edi
  800f2b:	89 de                	mov    %ebx,%esi
  800f2d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f2f:	85 c0                	test   %eax,%eax
  800f31:	7e 28                	jle    800f5b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f33:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f37:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f3e:	00 
  800f3f:	c7 44 24 08 3f 2f 80 	movl   $0x802f3f,0x8(%esp)
  800f46:	00 
  800f47:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f4e:	00 
  800f4f:	c7 04 24 5c 2f 80 00 	movl   $0x802f5c,(%esp)
  800f56:	e8 24 f3 ff ff       	call   80027f <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f5b:	83 c4 2c             	add    $0x2c,%esp
  800f5e:	5b                   	pop    %ebx
  800f5f:	5e                   	pop    %esi
  800f60:	5f                   	pop    %edi
  800f61:	5d                   	pop    %ebp
  800f62:	c3                   	ret    

00800f63 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	57                   	push   %edi
  800f67:	56                   	push   %esi
  800f68:	53                   	push   %ebx
  800f69:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f71:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f79:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7c:	89 df                	mov    %ebx,%edi
  800f7e:	89 de                	mov    %ebx,%esi
  800f80:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f82:	85 c0                	test   %eax,%eax
  800f84:	7e 28                	jle    800fae <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f86:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f8a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f91:	00 
  800f92:	c7 44 24 08 3f 2f 80 	movl   $0x802f3f,0x8(%esp)
  800f99:	00 
  800f9a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa1:	00 
  800fa2:	c7 04 24 5c 2f 80 00 	movl   $0x802f5c,(%esp)
  800fa9:	e8 d1 f2 ff ff       	call   80027f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fae:	83 c4 2c             	add    $0x2c,%esp
  800fb1:	5b                   	pop    %ebx
  800fb2:	5e                   	pop    %esi
  800fb3:	5f                   	pop    %edi
  800fb4:	5d                   	pop    %ebp
  800fb5:	c3                   	ret    

00800fb6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fb6:	55                   	push   %ebp
  800fb7:	89 e5                	mov    %esp,%ebp
  800fb9:	57                   	push   %edi
  800fba:	56                   	push   %esi
  800fbb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fbc:	be 00 00 00 00       	mov    $0x0,%esi
  800fc1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fcf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fd2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fd4:	5b                   	pop    %ebx
  800fd5:	5e                   	pop    %esi
  800fd6:	5f                   	pop    %edi
  800fd7:	5d                   	pop    %ebp
  800fd8:	c3                   	ret    

00800fd9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fd9:	55                   	push   %ebp
  800fda:	89 e5                	mov    %esp,%ebp
  800fdc:	57                   	push   %edi
  800fdd:	56                   	push   %esi
  800fde:	53                   	push   %ebx
  800fdf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fec:	8b 55 08             	mov    0x8(%ebp),%edx
  800fef:	89 cb                	mov    %ecx,%ebx
  800ff1:	89 cf                	mov    %ecx,%edi
  800ff3:	89 ce                	mov    %ecx,%esi
  800ff5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	7e 28                	jle    801023 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ffb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fff:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801006:	00 
  801007:	c7 44 24 08 3f 2f 80 	movl   $0x802f3f,0x8(%esp)
  80100e:	00 
  80100f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801016:	00 
  801017:	c7 04 24 5c 2f 80 00 	movl   $0x802f5c,(%esp)
  80101e:	e8 5c f2 ff ff       	call   80027f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801023:	83 c4 2c             	add    $0x2c,%esp
  801026:	5b                   	pop    %ebx
  801027:	5e                   	pop    %esi
  801028:	5f                   	pop    %edi
  801029:	5d                   	pop    %ebp
  80102a:	c3                   	ret    

0080102b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	57                   	push   %edi
  80102f:	56                   	push   %esi
  801030:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801031:	ba 00 00 00 00       	mov    $0x0,%edx
  801036:	b8 0e 00 00 00       	mov    $0xe,%eax
  80103b:	89 d1                	mov    %edx,%ecx
  80103d:	89 d3                	mov    %edx,%ebx
  80103f:	89 d7                	mov    %edx,%edi
  801041:	89 d6                	mov    %edx,%esi
  801043:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801045:	5b                   	pop    %ebx
  801046:	5e                   	pop    %esi
  801047:	5f                   	pop    %edi
  801048:	5d                   	pop    %ebp
  801049:	c3                   	ret    

0080104a <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  80104a:	55                   	push   %ebp
  80104b:	89 e5                	mov    %esp,%ebp
  80104d:	57                   	push   %edi
  80104e:	56                   	push   %esi
  80104f:	53                   	push   %ebx
  801050:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801053:	bb 00 00 00 00       	mov    $0x0,%ebx
  801058:	b8 0f 00 00 00       	mov    $0xf,%eax
  80105d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801060:	8b 55 08             	mov    0x8(%ebp),%edx
  801063:	89 df                	mov    %ebx,%edi
  801065:	89 de                	mov    %ebx,%esi
  801067:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801069:	85 c0                	test   %eax,%eax
  80106b:	7e 28                	jle    801095 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80106d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801071:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801078:	00 
  801079:	c7 44 24 08 3f 2f 80 	movl   $0x802f3f,0x8(%esp)
  801080:	00 
  801081:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801088:	00 
  801089:	c7 04 24 5c 2f 80 00 	movl   $0x802f5c,(%esp)
  801090:	e8 ea f1 ff ff       	call   80027f <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  801095:	83 c4 2c             	add    $0x2c,%esp
  801098:	5b                   	pop    %ebx
  801099:	5e                   	pop    %esi
  80109a:	5f                   	pop    %edi
  80109b:	5d                   	pop    %ebp
  80109c:	c3                   	ret    

0080109d <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
  8010a0:	57                   	push   %edi
  8010a1:	56                   	push   %esi
  8010a2:	53                   	push   %ebx
  8010a3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ab:	b8 10 00 00 00       	mov    $0x10,%eax
  8010b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b6:	89 df                	mov    %ebx,%edi
  8010b8:	89 de                	mov    %ebx,%esi
  8010ba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010bc:	85 c0                	test   %eax,%eax
  8010be:	7e 28                	jle    8010e8 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010c4:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  8010cb:	00 
  8010cc:	c7 44 24 08 3f 2f 80 	movl   $0x802f3f,0x8(%esp)
  8010d3:	00 
  8010d4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010db:	00 
  8010dc:	c7 04 24 5c 2f 80 00 	movl   $0x802f5c,(%esp)
  8010e3:	e8 97 f1 ff ff       	call   80027f <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  8010e8:	83 c4 2c             	add    $0x2c,%esp
  8010eb:	5b                   	pop    %ebx
  8010ec:	5e                   	pop    %esi
  8010ed:	5f                   	pop    %edi
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    

008010f0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	56                   	push   %esi
  8010f4:	53                   	push   %ebx
  8010f5:	83 ec 20             	sub    $0x20,%esp
  8010f8:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8010fb:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if(!(err & FEC_WR)) {
  8010fd:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801101:	75 20                	jne    801123 <pgfault+0x33>
		panic("0x%x Not a write", addr);
  801103:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801107:	c7 44 24 08 6a 2f 80 	movl   $0x802f6a,0x8(%esp)
  80110e:	00 
  80110f:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801116:	00 
  801117:	c7 04 24 7b 2f 80 00 	movl   $0x802f7b,(%esp)
  80111e:	e8 5c f1 ff ff       	call   80027f <_panic>
	}

	if(!(uvpt[PGNUM(addr)] & PTE_COW)) {
  801123:	89 f0                	mov    %esi,%eax
  801125:	c1 e8 0c             	shr    $0xc,%eax
  801128:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80112f:	f6 c4 08             	test   $0x8,%ah
  801132:	75 1c                	jne    801150 <pgfault+0x60>
		panic("Not a COW page");
  801134:	c7 44 24 08 86 2f 80 	movl   $0x802f86,0x8(%esp)
  80113b:	00 
  80113c:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  801143:	00 
  801144:	c7 04 24 7b 2f 80 00 	movl   $0x802f7b,(%esp)
  80114b:	e8 2f f1 ff ff       	call   80027f <_panic>

	// Allocate a new page, map it at a temporary location (PFTEMP), // copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	envid_t envid = sys_getenvid();
  801150:	e8 30 fc ff ff       	call   800d85 <sys_getenvid>
  801155:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, PFTEMP, PTE_W | PTE_U | PTE_P);
  801157:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80115e:	00 
  80115f:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801166:	00 
  801167:	89 04 24             	mov    %eax,(%esp)
  80116a:	e8 54 fc ff ff       	call   800dc3 <sys_page_alloc>
	if(r < 0) {
  80116f:	85 c0                	test   %eax,%eax
  801171:	79 1c                	jns    80118f <pgfault+0x9f>
		panic("couldn't allocate page");
  801173:	c7 44 24 08 95 2f 80 	movl   $0x802f95,0x8(%esp)
  80117a:	00 
  80117b:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801182:	00 
  801183:	c7 04 24 7b 2f 80 00 	movl   $0x802f7b,(%esp)
  80118a:	e8 f0 f0 ff ff       	call   80027f <_panic>
	}

	memmove(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  80118f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  801195:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80119c:	00 
  80119d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011a1:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8011a8:	e8 97 f9 ff ff       	call   800b44 <memmove>

	r = sys_page_map(envid, PFTEMP, envid, ROUNDDOWN(addr,PGSIZE), PTE_P | PTE_U | PTE_W);
  8011ad:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8011b4:	00 
  8011b5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011bd:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8011c4:	00 
  8011c5:	89 1c 24             	mov    %ebx,(%esp)
  8011c8:	e8 4a fc ff ff       	call   800e17 <sys_page_map>
	if(r < 0) {
  8011cd:	85 c0                	test   %eax,%eax
  8011cf:	79 1c                	jns    8011ed <pgfault+0xfd>
		panic("couldn't map page");
  8011d1:	c7 44 24 08 ac 2f 80 	movl   $0x802fac,0x8(%esp)
  8011d8:	00 
  8011d9:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  8011e0:	00 
  8011e1:	c7 04 24 7b 2f 80 00 	movl   $0x802f7b,(%esp)
  8011e8:	e8 92 f0 ff ff       	call   80027f <_panic>
	}
}
  8011ed:	83 c4 20             	add    $0x20,%esp
  8011f0:	5b                   	pop    %ebx
  8011f1:	5e                   	pop    %esi
  8011f2:	5d                   	pop    %ebp
  8011f3:	c3                   	ret    

008011f4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
  8011f7:	57                   	push   %edi
  8011f8:	56                   	push   %esi
  8011f9:	53                   	push   %ebx
  8011fa:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envid;
	uintptr_t addr;
	int r = 0;

	set_pgfault_handler(pgfault);
  8011fd:	c7 04 24 f0 10 80 00 	movl   $0x8010f0,(%esp)
  801204:	e8 0d 16 00 00       	call   802816 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801209:	b8 07 00 00 00       	mov    $0x7,%eax
  80120e:	cd 30                	int    $0x30
  801210:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801213:	89 45 d8             	mov    %eax,-0x28(%ebp)

	envid = sys_exofork();
	if(envid == 0) {
  801216:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80121d:	bf 00 00 00 00       	mov    $0x0,%edi
  801222:	85 c0                	test   %eax,%eax
  801224:	75 21                	jne    801247 <fork+0x53>
		thisenv = &envs[ENVX(sys_getenvid())];
  801226:	e8 5a fb ff ff       	call   800d85 <sys_getenvid>
  80122b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801230:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801233:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801238:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  80123d:	b8 00 00 00 00       	mov    $0x0,%eax
  801242:	e9 8d 01 00 00       	jmp    8013d4 <fork+0x1e0>
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
  801247:	89 f8                	mov    %edi,%eax
  801249:	c1 e8 16             	shr    $0x16,%eax
  80124c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801253:	85 c0                	test   %eax,%eax
  801255:	0f 84 02 01 00 00    	je     80135d <fork+0x169>
  80125b:	89 fa                	mov    %edi,%edx
  80125d:	c1 ea 0c             	shr    $0xc,%edx
  801260:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801267:	85 c0                	test   %eax,%eax
  801269:	0f 84 ee 00 00 00    	je     80135d <fork+0x169>
//
static int
duppage(envid_t envid, unsigned pn)
{

	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P)) return 0;
  80126f:	89 d6                	mov    %edx,%esi
  801271:	c1 e6 0c             	shl    $0xc,%esi
  801274:	89 f0                	mov    %esi,%eax
  801276:	c1 e8 16             	shr    $0x16,%eax
  801279:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  801280:	b8 00 00 00 00       	mov    $0x0,%eax
  801285:	f6 c1 01             	test   $0x1,%cl
  801288:	0f 84 cc 00 00 00    	je     80135a <fork+0x166>

	int all_perms = PTE_U | PTE_P | PTE_AVAIL | PTE_W | PTE_COW;
	int orig_perms = uvpt[pn] & all_perms;
  80128e:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  801295:	89 d8                	mov    %ebx,%eax
  801297:	25 07 0e 00 00       	and    $0xe07,%eax
  80129c:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if(!(orig_perms & PTE_P)) return 0;
  80129f:	89 d8                	mov    %ebx,%eax
  8012a1:	83 e0 01             	and    $0x1,%eax
  8012a4:	0f 84 b0 00 00 00    	je     80135a <fork+0x166>

	int r = 0;
	envid_t curenvid = sys_getenvid();
  8012aa:	e8 d6 fa ff ff       	call   800d85 <sys_getenvid>
  8012af:	89 45 dc             	mov    %eax,-0x24(%ebp)


	if(orig_perms & PTE_SHARE) {
  8012b2:	f7 45 e0 00 04 00 00 	testl  $0x400,-0x20(%ebp)
  8012b9:	74 28                	je     8012e3 <fork+0xef>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms & PTE_SYSCALL));
  8012bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012be:	25 07 0e 00 00       	and    $0xe07,%eax
  8012c3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012c7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8012ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012d6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012d9:	89 04 24             	mov    %eax,(%esp)
  8012dc:	e8 36 fb ff ff       	call   800e17 <sys_page_map>
  8012e1:	eb 77                	jmp    80135a <fork+0x166>

	} else if(((orig_perms) & PTE_COW) || (orig_perms & PTE_W) ) {
  8012e3:	f7 c3 02 08 00 00    	test   $0x802,%ebx
  8012e9:	74 4e                	je     801339 <fork+0x145>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  8012eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012ee:	25 fd f7 ff ff       	and    $0xfffff7fd,%eax
  8012f3:	80 cc 08             	or     $0x8,%ah
  8012f6:	89 c3                	mov    %eax,%ebx
  8012f8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012fc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801300:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801303:	89 44 24 08          	mov    %eax,0x8(%esp)
  801307:	89 74 24 04          	mov    %esi,0x4(%esp)
  80130b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80130e:	89 04 24             	mov    %eax,(%esp)
  801311:	e8 01 fb ff ff       	call   800e17 <sys_page_map>
  801316:	89 45 e0             	mov    %eax,-0x20(%ebp)

		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), curenvid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  801319:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80131d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801321:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801324:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801328:	89 74 24 04          	mov    %esi,0x4(%esp)
  80132c:	89 0c 24             	mov    %ecx,(%esp)
  80132f:	e8 e3 fa ff ff       	call   800e17 <sys_page_map>
  801334:	03 45 e0             	add    -0x20(%ebp),%eax
  801337:	eb 21                	jmp    80135a <fork+0x166>

	} else {
		r = sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), orig_perms);
  801339:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80133c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801340:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801344:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801347:	89 44 24 08          	mov    %eax,0x8(%esp)
  80134b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80134f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801352:	89 04 24             	mov    %eax,(%esp)
  801355:	e8 bd fa ff ff       	call   800e17 <sys_page_map>
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
  80135a:	01 45 e4             	add    %eax,-0x1c(%ebp)
	if(envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
  80135d:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801363:	81 ff 00 f0 bf ee    	cmp    $0xeebff000,%edi
  801369:	0f 85 d8 fe ff ff    	jne    801247 <fork+0x53>
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
		}
	}

	r+=sys_page_alloc(envid, (void*)UXSTACKTOP - PGSIZE, PTE_P|PTE_U|PTE_W);
  80136f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801376:	00 
  801377:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80137e:	ee 
  80137f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801382:	89 34 24             	mov    %esi,(%esp)
  801385:	e8 39 fa ff ff       	call   800dc3 <sys_page_alloc>
  80138a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80138d:	01 c3                	add    %eax,%ebx
	r+=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80138f:	c7 44 24 04 63 28 80 	movl   $0x802863,0x4(%esp)
  801396:	00 
  801397:	89 34 24             	mov    %esi,(%esp)
  80139a:	e8 c4 fb ff ff       	call   800f63 <sys_env_set_pgfault_upcall>
  80139f:	01 c3                	add    %eax,%ebx
	r+= sys_env_set_status(envid, ENV_RUNNABLE);
  8013a1:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8013a8:	00 
  8013a9:	89 34 24             	mov    %esi,(%esp)
  8013ac:	e8 0c fb ff ff       	call   800ebd <sys_env_set_status>

	if(r<0) {
  8013b1:	01 d8                	add    %ebx,%eax
  8013b3:	79 1c                	jns    8013d1 <fork+0x1dd>
	 panic("fork failed!");
  8013b5:	c7 44 24 08 be 2f 80 	movl   $0x802fbe,0x8(%esp)
  8013bc:	00 
  8013bd:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  8013c4:	00 
  8013c5:	c7 04 24 7b 2f 80 00 	movl   $0x802f7b,(%esp)
  8013cc:	e8 ae ee ff ff       	call   80027f <_panic>
	}

	return envid;
  8013d1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  8013d4:	83 c4 3c             	add    $0x3c,%esp
  8013d7:	5b                   	pop    %ebx
  8013d8:	5e                   	pop    %esi
  8013d9:	5f                   	pop    %edi
  8013da:	5d                   	pop    %ebp
  8013db:	c3                   	ret    

008013dc <sfork>:

// Challenge!
int
sfork(void)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8013e2:	c7 44 24 08 cb 2f 80 	movl   $0x802fcb,0x8(%esp)
  8013e9:	00 
  8013ea:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
  8013f1:	00 
  8013f2:	c7 04 24 7b 2f 80 00 	movl   $0x802f7b,(%esp)
  8013f9:	e8 81 ee ff ff       	call   80027f <_panic>
  8013fe:	66 90                	xchg   %ax,%ax

00801400 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
  801403:	56                   	push   %esi
  801404:	53                   	push   %ebx
  801405:	83 ec 10             	sub    $0x10,%esp
  801408:	8b 75 08             	mov    0x8(%ebp),%esi
  80140b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80140e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  801411:	85 c0                	test   %eax,%eax
  801413:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801418:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  80141b:	89 04 24             	mov    %eax,(%esp)
  80141e:	e8 b6 fb ff ff       	call   800fd9 <sys_ipc_recv>

	if(ret < 0) {
  801423:	85 c0                	test   %eax,%eax
  801425:	79 16                	jns    80143d <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  801427:	85 f6                	test   %esi,%esi
  801429:	74 06                	je     801431 <ipc_recv+0x31>
  80142b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  801431:	85 db                	test   %ebx,%ebx
  801433:	74 3e                	je     801473 <ipc_recv+0x73>
  801435:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80143b:	eb 36                	jmp    801473 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  80143d:	e8 43 f9 ff ff       	call   800d85 <sys_getenvid>
  801442:	25 ff 03 00 00       	and    $0x3ff,%eax
  801447:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80144a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80144f:	a3 08 50 80 00       	mov    %eax,0x805008

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801454:	85 f6                	test   %esi,%esi
  801456:	74 05                	je     80145d <ipc_recv+0x5d>
  801458:	8b 40 74             	mov    0x74(%eax),%eax
  80145b:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80145d:	85 db                	test   %ebx,%ebx
  80145f:	74 0a                	je     80146b <ipc_recv+0x6b>
  801461:	a1 08 50 80 00       	mov    0x805008,%eax
  801466:	8b 40 78             	mov    0x78(%eax),%eax
  801469:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  80146b:	a1 08 50 80 00       	mov    0x805008,%eax
  801470:	8b 40 70             	mov    0x70(%eax),%eax
}
  801473:	83 c4 10             	add    $0x10,%esp
  801476:	5b                   	pop    %ebx
  801477:	5e                   	pop    %esi
  801478:	5d                   	pop    %ebp
  801479:	c3                   	ret    

0080147a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80147a:	55                   	push   %ebp
  80147b:	89 e5                	mov    %esp,%ebp
  80147d:	57                   	push   %edi
  80147e:	56                   	push   %esi
  80147f:	53                   	push   %ebx
  801480:	83 ec 1c             	sub    $0x1c,%esp
  801483:	8b 7d 08             	mov    0x8(%ebp),%edi
  801486:	8b 75 0c             	mov    0xc(%ebp),%esi
  801489:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  80148c:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  80148e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801493:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  801496:	8b 45 14             	mov    0x14(%ebp),%eax
  801499:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80149d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014a5:	89 3c 24             	mov    %edi,(%esp)
  8014a8:	e8 09 fb ff ff       	call   800fb6 <sys_ipc_try_send>

		if(ret >= 0) break;
  8014ad:	85 c0                	test   %eax,%eax
  8014af:	79 2c                	jns    8014dd <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  8014b1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8014b4:	74 20                	je     8014d6 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  8014b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014ba:	c7 44 24 08 e4 2f 80 	movl   $0x802fe4,0x8(%esp)
  8014c1:	00 
  8014c2:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8014c9:	00 
  8014ca:	c7 04 24 14 30 80 00 	movl   $0x803014,(%esp)
  8014d1:	e8 a9 ed ff ff       	call   80027f <_panic>
		}
		sys_yield();
  8014d6:	e8 c9 f8 ff ff       	call   800da4 <sys_yield>
	}
  8014db:	eb b9                	jmp    801496 <ipc_send+0x1c>
}
  8014dd:	83 c4 1c             	add    $0x1c,%esp
  8014e0:	5b                   	pop    %ebx
  8014e1:	5e                   	pop    %esi
  8014e2:	5f                   	pop    %edi
  8014e3:	5d                   	pop    %ebp
  8014e4:	c3                   	ret    

008014e5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
  8014e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8014eb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8014f0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8014f3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8014f9:	8b 52 50             	mov    0x50(%edx),%edx
  8014fc:	39 ca                	cmp    %ecx,%edx
  8014fe:	75 0d                	jne    80150d <ipc_find_env+0x28>
			return envs[i].env_id;
  801500:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801503:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801508:	8b 40 40             	mov    0x40(%eax),%eax
  80150b:	eb 0e                	jmp    80151b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80150d:	83 c0 01             	add    $0x1,%eax
  801510:	3d 00 04 00 00       	cmp    $0x400,%eax
  801515:	75 d9                	jne    8014f0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801517:	66 b8 00 00          	mov    $0x0,%ax
}
  80151b:	5d                   	pop    %ebp
  80151c:	c3                   	ret    
  80151d:	66 90                	xchg   %ax,%ax
  80151f:	90                   	nop

00801520 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801520:	55                   	push   %ebp
  801521:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801523:	8b 45 08             	mov    0x8(%ebp),%eax
  801526:	05 00 00 00 30       	add    $0x30000000,%eax
  80152b:	c1 e8 0c             	shr    $0xc,%eax
}
  80152e:	5d                   	pop    %ebp
  80152f:	c3                   	ret    

00801530 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801533:	8b 45 08             	mov    0x8(%ebp),%eax
  801536:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80153b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801540:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801545:	5d                   	pop    %ebp
  801546:	c3                   	ret    

00801547 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801547:	55                   	push   %ebp
  801548:	89 e5                	mov    %esp,%ebp
  80154a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80154d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801552:	89 c2                	mov    %eax,%edx
  801554:	c1 ea 16             	shr    $0x16,%edx
  801557:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80155e:	f6 c2 01             	test   $0x1,%dl
  801561:	74 11                	je     801574 <fd_alloc+0x2d>
  801563:	89 c2                	mov    %eax,%edx
  801565:	c1 ea 0c             	shr    $0xc,%edx
  801568:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80156f:	f6 c2 01             	test   $0x1,%dl
  801572:	75 09                	jne    80157d <fd_alloc+0x36>
			*fd_store = fd;
  801574:	89 01                	mov    %eax,(%ecx)
			return 0;
  801576:	b8 00 00 00 00       	mov    $0x0,%eax
  80157b:	eb 17                	jmp    801594 <fd_alloc+0x4d>
  80157d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801582:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801587:	75 c9                	jne    801552 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801589:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80158f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801594:	5d                   	pop    %ebp
  801595:	c3                   	ret    

00801596 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801596:	55                   	push   %ebp
  801597:	89 e5                	mov    %esp,%ebp
  801599:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80159c:	83 f8 1f             	cmp    $0x1f,%eax
  80159f:	77 36                	ja     8015d7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8015a1:	c1 e0 0c             	shl    $0xc,%eax
  8015a4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8015a9:	89 c2                	mov    %eax,%edx
  8015ab:	c1 ea 16             	shr    $0x16,%edx
  8015ae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8015b5:	f6 c2 01             	test   $0x1,%dl
  8015b8:	74 24                	je     8015de <fd_lookup+0x48>
  8015ba:	89 c2                	mov    %eax,%edx
  8015bc:	c1 ea 0c             	shr    $0xc,%edx
  8015bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015c6:	f6 c2 01             	test   $0x1,%dl
  8015c9:	74 1a                	je     8015e5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8015cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ce:	89 02                	mov    %eax,(%edx)
	return 0;
  8015d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8015d5:	eb 13                	jmp    8015ea <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015dc:	eb 0c                	jmp    8015ea <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015e3:	eb 05                	jmp    8015ea <fd_lookup+0x54>
  8015e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8015ea:	5d                   	pop    %ebp
  8015eb:	c3                   	ret    

008015ec <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	83 ec 18             	sub    $0x18,%esp
  8015f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8015f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015fa:	eb 13                	jmp    80160f <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8015fc:	39 08                	cmp    %ecx,(%eax)
  8015fe:	75 0c                	jne    80160c <dev_lookup+0x20>
			*dev = devtab[i];
  801600:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801603:	89 01                	mov    %eax,(%ecx)
			return 0;
  801605:	b8 00 00 00 00       	mov    $0x0,%eax
  80160a:	eb 38                	jmp    801644 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80160c:	83 c2 01             	add    $0x1,%edx
  80160f:	8b 04 95 a0 30 80 00 	mov    0x8030a0(,%edx,4),%eax
  801616:	85 c0                	test   %eax,%eax
  801618:	75 e2                	jne    8015fc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80161a:	a1 08 50 80 00       	mov    0x805008,%eax
  80161f:	8b 40 48             	mov    0x48(%eax),%eax
  801622:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801626:	89 44 24 04          	mov    %eax,0x4(%esp)
  80162a:	c7 04 24 20 30 80 00 	movl   $0x803020,(%esp)
  801631:	e8 42 ed ff ff       	call   800378 <cprintf>
	*dev = 0;
  801636:	8b 45 0c             	mov    0xc(%ebp),%eax
  801639:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80163f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801644:	c9                   	leave  
  801645:	c3                   	ret    

00801646 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	56                   	push   %esi
  80164a:	53                   	push   %ebx
  80164b:	83 ec 20             	sub    $0x20,%esp
  80164e:	8b 75 08             	mov    0x8(%ebp),%esi
  801651:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801654:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801657:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80165b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801661:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801664:	89 04 24             	mov    %eax,(%esp)
  801667:	e8 2a ff ff ff       	call   801596 <fd_lookup>
  80166c:	85 c0                	test   %eax,%eax
  80166e:	78 05                	js     801675 <fd_close+0x2f>
	    || fd != fd2)
  801670:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801673:	74 0c                	je     801681 <fd_close+0x3b>
		return (must_exist ? r : 0);
  801675:	84 db                	test   %bl,%bl
  801677:	ba 00 00 00 00       	mov    $0x0,%edx
  80167c:	0f 44 c2             	cmove  %edx,%eax
  80167f:	eb 3f                	jmp    8016c0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801681:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801684:	89 44 24 04          	mov    %eax,0x4(%esp)
  801688:	8b 06                	mov    (%esi),%eax
  80168a:	89 04 24             	mov    %eax,(%esp)
  80168d:	e8 5a ff ff ff       	call   8015ec <dev_lookup>
  801692:	89 c3                	mov    %eax,%ebx
  801694:	85 c0                	test   %eax,%eax
  801696:	78 16                	js     8016ae <fd_close+0x68>
		if (dev->dev_close)
  801698:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80169e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8016a3:	85 c0                	test   %eax,%eax
  8016a5:	74 07                	je     8016ae <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8016a7:	89 34 24             	mov    %esi,(%esp)
  8016aa:	ff d0                	call   *%eax
  8016ac:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8016ae:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016b9:	e8 ac f7 ff ff       	call   800e6a <sys_page_unmap>
	return r;
  8016be:	89 d8                	mov    %ebx,%eax
}
  8016c0:	83 c4 20             	add    $0x20,%esp
  8016c3:	5b                   	pop    %ebx
  8016c4:	5e                   	pop    %esi
  8016c5:	5d                   	pop    %ebp
  8016c6:	c3                   	ret    

008016c7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d7:	89 04 24             	mov    %eax,(%esp)
  8016da:	e8 b7 fe ff ff       	call   801596 <fd_lookup>
  8016df:	89 c2                	mov    %eax,%edx
  8016e1:	85 d2                	test   %edx,%edx
  8016e3:	78 13                	js     8016f8 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8016e5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8016ec:	00 
  8016ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f0:	89 04 24             	mov    %eax,(%esp)
  8016f3:	e8 4e ff ff ff       	call   801646 <fd_close>
}
  8016f8:	c9                   	leave  
  8016f9:	c3                   	ret    

008016fa <close_all>:

void
close_all(void)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	53                   	push   %ebx
  8016fe:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801701:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801706:	89 1c 24             	mov    %ebx,(%esp)
  801709:	e8 b9 ff ff ff       	call   8016c7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80170e:	83 c3 01             	add    $0x1,%ebx
  801711:	83 fb 20             	cmp    $0x20,%ebx
  801714:	75 f0                	jne    801706 <close_all+0xc>
		close(i);
}
  801716:	83 c4 14             	add    $0x14,%esp
  801719:	5b                   	pop    %ebx
  80171a:	5d                   	pop    %ebp
  80171b:	c3                   	ret    

0080171c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	57                   	push   %edi
  801720:	56                   	push   %esi
  801721:	53                   	push   %ebx
  801722:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801725:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801728:	89 44 24 04          	mov    %eax,0x4(%esp)
  80172c:	8b 45 08             	mov    0x8(%ebp),%eax
  80172f:	89 04 24             	mov    %eax,(%esp)
  801732:	e8 5f fe ff ff       	call   801596 <fd_lookup>
  801737:	89 c2                	mov    %eax,%edx
  801739:	85 d2                	test   %edx,%edx
  80173b:	0f 88 e1 00 00 00    	js     801822 <dup+0x106>
		return r;
	close(newfdnum);
  801741:	8b 45 0c             	mov    0xc(%ebp),%eax
  801744:	89 04 24             	mov    %eax,(%esp)
  801747:	e8 7b ff ff ff       	call   8016c7 <close>

	newfd = INDEX2FD(newfdnum);
  80174c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80174f:	c1 e3 0c             	shl    $0xc,%ebx
  801752:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801758:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80175b:	89 04 24             	mov    %eax,(%esp)
  80175e:	e8 cd fd ff ff       	call   801530 <fd2data>
  801763:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801765:	89 1c 24             	mov    %ebx,(%esp)
  801768:	e8 c3 fd ff ff       	call   801530 <fd2data>
  80176d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80176f:	89 f0                	mov    %esi,%eax
  801771:	c1 e8 16             	shr    $0x16,%eax
  801774:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80177b:	a8 01                	test   $0x1,%al
  80177d:	74 43                	je     8017c2 <dup+0xa6>
  80177f:	89 f0                	mov    %esi,%eax
  801781:	c1 e8 0c             	shr    $0xc,%eax
  801784:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80178b:	f6 c2 01             	test   $0x1,%dl
  80178e:	74 32                	je     8017c2 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801790:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801797:	25 07 0e 00 00       	and    $0xe07,%eax
  80179c:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017a0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8017a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017ab:	00 
  8017ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017b7:	e8 5b f6 ff ff       	call   800e17 <sys_page_map>
  8017bc:	89 c6                	mov    %eax,%esi
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	78 3e                	js     801800 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017c5:	89 c2                	mov    %eax,%edx
  8017c7:	c1 ea 0c             	shr    $0xc,%edx
  8017ca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017d1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8017d7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8017db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8017df:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017e6:	00 
  8017e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017f2:	e8 20 f6 ff ff       	call   800e17 <sys_page_map>
  8017f7:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8017f9:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017fc:	85 f6                	test   %esi,%esi
  8017fe:	79 22                	jns    801822 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801800:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801804:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80180b:	e8 5a f6 ff ff       	call   800e6a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801810:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801814:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80181b:	e8 4a f6 ff ff       	call   800e6a <sys_page_unmap>
	return r;
  801820:	89 f0                	mov    %esi,%eax
}
  801822:	83 c4 3c             	add    $0x3c,%esp
  801825:	5b                   	pop    %ebx
  801826:	5e                   	pop    %esi
  801827:	5f                   	pop    %edi
  801828:	5d                   	pop    %ebp
  801829:	c3                   	ret    

0080182a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80182a:	55                   	push   %ebp
  80182b:	89 e5                	mov    %esp,%ebp
  80182d:	53                   	push   %ebx
  80182e:	83 ec 24             	sub    $0x24,%esp
  801831:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801834:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801837:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183b:	89 1c 24             	mov    %ebx,(%esp)
  80183e:	e8 53 fd ff ff       	call   801596 <fd_lookup>
  801843:	89 c2                	mov    %eax,%edx
  801845:	85 d2                	test   %edx,%edx
  801847:	78 6d                	js     8018b6 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801849:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801850:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801853:	8b 00                	mov    (%eax),%eax
  801855:	89 04 24             	mov    %eax,(%esp)
  801858:	e8 8f fd ff ff       	call   8015ec <dev_lookup>
  80185d:	85 c0                	test   %eax,%eax
  80185f:	78 55                	js     8018b6 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801861:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801864:	8b 50 08             	mov    0x8(%eax),%edx
  801867:	83 e2 03             	and    $0x3,%edx
  80186a:	83 fa 01             	cmp    $0x1,%edx
  80186d:	75 23                	jne    801892 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80186f:	a1 08 50 80 00       	mov    0x805008,%eax
  801874:	8b 40 48             	mov    0x48(%eax),%eax
  801877:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80187b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187f:	c7 04 24 64 30 80 00 	movl   $0x803064,(%esp)
  801886:	e8 ed ea ff ff       	call   800378 <cprintf>
		return -E_INVAL;
  80188b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801890:	eb 24                	jmp    8018b6 <read+0x8c>
	}
	if (!dev->dev_read)
  801892:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801895:	8b 52 08             	mov    0x8(%edx),%edx
  801898:	85 d2                	test   %edx,%edx
  80189a:	74 15                	je     8018b1 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80189c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80189f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018a6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018aa:	89 04 24             	mov    %eax,(%esp)
  8018ad:	ff d2                	call   *%edx
  8018af:	eb 05                	jmp    8018b6 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8018b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8018b6:	83 c4 24             	add    $0x24,%esp
  8018b9:	5b                   	pop    %ebx
  8018ba:	5d                   	pop    %ebp
  8018bb:	c3                   	ret    

008018bc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	57                   	push   %edi
  8018c0:	56                   	push   %esi
  8018c1:	53                   	push   %ebx
  8018c2:	83 ec 1c             	sub    $0x1c,%esp
  8018c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018c8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018d0:	eb 23                	jmp    8018f5 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018d2:	89 f0                	mov    %esi,%eax
  8018d4:	29 d8                	sub    %ebx,%eax
  8018d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018da:	89 d8                	mov    %ebx,%eax
  8018dc:	03 45 0c             	add    0xc(%ebp),%eax
  8018df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e3:	89 3c 24             	mov    %edi,(%esp)
  8018e6:	e8 3f ff ff ff       	call   80182a <read>
		if (m < 0)
  8018eb:	85 c0                	test   %eax,%eax
  8018ed:	78 10                	js     8018ff <readn+0x43>
			return m;
		if (m == 0)
  8018ef:	85 c0                	test   %eax,%eax
  8018f1:	74 0a                	je     8018fd <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018f3:	01 c3                	add    %eax,%ebx
  8018f5:	39 f3                	cmp    %esi,%ebx
  8018f7:	72 d9                	jb     8018d2 <readn+0x16>
  8018f9:	89 d8                	mov    %ebx,%eax
  8018fb:	eb 02                	jmp    8018ff <readn+0x43>
  8018fd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8018ff:	83 c4 1c             	add    $0x1c,%esp
  801902:	5b                   	pop    %ebx
  801903:	5e                   	pop    %esi
  801904:	5f                   	pop    %edi
  801905:	5d                   	pop    %ebp
  801906:	c3                   	ret    

00801907 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	53                   	push   %ebx
  80190b:	83 ec 24             	sub    $0x24,%esp
  80190e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801911:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801914:	89 44 24 04          	mov    %eax,0x4(%esp)
  801918:	89 1c 24             	mov    %ebx,(%esp)
  80191b:	e8 76 fc ff ff       	call   801596 <fd_lookup>
  801920:	89 c2                	mov    %eax,%edx
  801922:	85 d2                	test   %edx,%edx
  801924:	78 68                	js     80198e <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801926:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801929:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801930:	8b 00                	mov    (%eax),%eax
  801932:	89 04 24             	mov    %eax,(%esp)
  801935:	e8 b2 fc ff ff       	call   8015ec <dev_lookup>
  80193a:	85 c0                	test   %eax,%eax
  80193c:	78 50                	js     80198e <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80193e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801941:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801945:	75 23                	jne    80196a <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801947:	a1 08 50 80 00       	mov    0x805008,%eax
  80194c:	8b 40 48             	mov    0x48(%eax),%eax
  80194f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801953:	89 44 24 04          	mov    %eax,0x4(%esp)
  801957:	c7 04 24 80 30 80 00 	movl   $0x803080,(%esp)
  80195e:	e8 15 ea ff ff       	call   800378 <cprintf>
		return -E_INVAL;
  801963:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801968:	eb 24                	jmp    80198e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80196a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80196d:	8b 52 0c             	mov    0xc(%edx),%edx
  801970:	85 d2                	test   %edx,%edx
  801972:	74 15                	je     801989 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801974:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801977:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80197b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80197e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801982:	89 04 24             	mov    %eax,(%esp)
  801985:	ff d2                	call   *%edx
  801987:	eb 05                	jmp    80198e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801989:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80198e:	83 c4 24             	add    $0x24,%esp
  801991:	5b                   	pop    %ebx
  801992:	5d                   	pop    %ebp
  801993:	c3                   	ret    

00801994 <seek>:

int
seek(int fdnum, off_t offset)
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80199a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80199d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a4:	89 04 24             	mov    %eax,(%esp)
  8019a7:	e8 ea fb ff ff       	call   801596 <fd_lookup>
  8019ac:	85 c0                	test   %eax,%eax
  8019ae:	78 0e                	js     8019be <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8019b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8019b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019b6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8019b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019be:	c9                   	leave  
  8019bf:	c3                   	ret    

008019c0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	53                   	push   %ebx
  8019c4:	83 ec 24             	sub    $0x24,%esp
  8019c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d1:	89 1c 24             	mov    %ebx,(%esp)
  8019d4:	e8 bd fb ff ff       	call   801596 <fd_lookup>
  8019d9:	89 c2                	mov    %eax,%edx
  8019db:	85 d2                	test   %edx,%edx
  8019dd:	78 61                	js     801a40 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019e9:	8b 00                	mov    (%eax),%eax
  8019eb:	89 04 24             	mov    %eax,(%esp)
  8019ee:	e8 f9 fb ff ff       	call   8015ec <dev_lookup>
  8019f3:	85 c0                	test   %eax,%eax
  8019f5:	78 49                	js     801a40 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019fa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019fe:	75 23                	jne    801a23 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801a00:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801a05:	8b 40 48             	mov    0x48(%eax),%eax
  801a08:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a10:	c7 04 24 40 30 80 00 	movl   $0x803040,(%esp)
  801a17:	e8 5c e9 ff ff       	call   800378 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801a1c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a21:	eb 1d                	jmp    801a40 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801a23:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a26:	8b 52 18             	mov    0x18(%edx),%edx
  801a29:	85 d2                	test   %edx,%edx
  801a2b:	74 0e                	je     801a3b <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801a2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a30:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a34:	89 04 24             	mov    %eax,(%esp)
  801a37:	ff d2                	call   *%edx
  801a39:	eb 05                	jmp    801a40 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801a3b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801a40:	83 c4 24             	add    $0x24,%esp
  801a43:	5b                   	pop    %ebx
  801a44:	5d                   	pop    %ebp
  801a45:	c3                   	ret    

00801a46 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a46:	55                   	push   %ebp
  801a47:	89 e5                	mov    %esp,%ebp
  801a49:	53                   	push   %ebx
  801a4a:	83 ec 24             	sub    $0x24,%esp
  801a4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a50:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a53:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a57:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5a:	89 04 24             	mov    %eax,(%esp)
  801a5d:	e8 34 fb ff ff       	call   801596 <fd_lookup>
  801a62:	89 c2                	mov    %eax,%edx
  801a64:	85 d2                	test   %edx,%edx
  801a66:	78 52                	js     801aba <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a72:	8b 00                	mov    (%eax),%eax
  801a74:	89 04 24             	mov    %eax,(%esp)
  801a77:	e8 70 fb ff ff       	call   8015ec <dev_lookup>
  801a7c:	85 c0                	test   %eax,%eax
  801a7e:	78 3a                	js     801aba <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a83:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a87:	74 2c                	je     801ab5 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a89:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a8c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a93:	00 00 00 
	stat->st_isdir = 0;
  801a96:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a9d:	00 00 00 
	stat->st_dev = dev;
  801aa0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801aa6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801aaa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801aad:	89 14 24             	mov    %edx,(%esp)
  801ab0:	ff 50 14             	call   *0x14(%eax)
  801ab3:	eb 05                	jmp    801aba <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801ab5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801aba:	83 c4 24             	add    $0x24,%esp
  801abd:	5b                   	pop    %ebx
  801abe:	5d                   	pop    %ebp
  801abf:	c3                   	ret    

00801ac0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	56                   	push   %esi
  801ac4:	53                   	push   %ebx
  801ac5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801ac8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801acf:	00 
  801ad0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad3:	89 04 24             	mov    %eax,(%esp)
  801ad6:	e8 28 02 00 00       	call   801d03 <open>
  801adb:	89 c3                	mov    %eax,%ebx
  801add:	85 db                	test   %ebx,%ebx
  801adf:	78 1b                	js     801afc <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801ae1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae8:	89 1c 24             	mov    %ebx,(%esp)
  801aeb:	e8 56 ff ff ff       	call   801a46 <fstat>
  801af0:	89 c6                	mov    %eax,%esi
	close(fd);
  801af2:	89 1c 24             	mov    %ebx,(%esp)
  801af5:	e8 cd fb ff ff       	call   8016c7 <close>
	return r;
  801afa:	89 f0                	mov    %esi,%eax
}
  801afc:	83 c4 10             	add    $0x10,%esp
  801aff:	5b                   	pop    %ebx
  801b00:	5e                   	pop    %esi
  801b01:	5d                   	pop    %ebp
  801b02:	c3                   	ret    

00801b03 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801b03:	55                   	push   %ebp
  801b04:	89 e5                	mov    %esp,%ebp
  801b06:	56                   	push   %esi
  801b07:	53                   	push   %ebx
  801b08:	83 ec 10             	sub    $0x10,%esp
  801b0b:	89 c6                	mov    %eax,%esi
  801b0d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801b0f:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801b16:	75 11                	jne    801b29 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801b18:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801b1f:	e8 c1 f9 ff ff       	call   8014e5 <ipc_find_env>
  801b24:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b29:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b30:	00 
  801b31:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801b38:	00 
  801b39:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b3d:	a1 00 50 80 00       	mov    0x805000,%eax
  801b42:	89 04 24             	mov    %eax,(%esp)
  801b45:	e8 30 f9 ff ff       	call   80147a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801b4a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b51:	00 
  801b52:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b56:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b5d:	e8 9e f8 ff ff       	call   801400 <ipc_recv>
}
  801b62:	83 c4 10             	add    $0x10,%esp
  801b65:	5b                   	pop    %ebx
  801b66:	5e                   	pop    %esi
  801b67:	5d                   	pop    %ebp
  801b68:	c3                   	ret    

00801b69 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b72:	8b 40 0c             	mov    0xc(%eax),%eax
  801b75:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801b7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b7d:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b82:	ba 00 00 00 00       	mov    $0x0,%edx
  801b87:	b8 02 00 00 00       	mov    $0x2,%eax
  801b8c:	e8 72 ff ff ff       	call   801b03 <fsipc>
}
  801b91:	c9                   	leave  
  801b92:	c3                   	ret    

00801b93 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b99:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9c:	8b 40 0c             	mov    0xc(%eax),%eax
  801b9f:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801ba4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba9:	b8 06 00 00 00       	mov    $0x6,%eax
  801bae:	e8 50 ff ff ff       	call   801b03 <fsipc>
}
  801bb3:	c9                   	leave  
  801bb4:	c3                   	ret    

00801bb5 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801bb5:	55                   	push   %ebp
  801bb6:	89 e5                	mov    %esp,%ebp
  801bb8:	53                   	push   %ebx
  801bb9:	83 ec 14             	sub    $0x14,%esp
  801bbc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801bbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc2:	8b 40 0c             	mov    0xc(%eax),%eax
  801bc5:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801bca:	ba 00 00 00 00       	mov    $0x0,%edx
  801bcf:	b8 05 00 00 00       	mov    $0x5,%eax
  801bd4:	e8 2a ff ff ff       	call   801b03 <fsipc>
  801bd9:	89 c2                	mov    %eax,%edx
  801bdb:	85 d2                	test   %edx,%edx
  801bdd:	78 2b                	js     801c0a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801bdf:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801be6:	00 
  801be7:	89 1c 24             	mov    %ebx,(%esp)
  801bea:	e8 b8 ed ff ff       	call   8009a7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801bef:	a1 80 60 80 00       	mov    0x806080,%eax
  801bf4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801bfa:	a1 84 60 80 00       	mov    0x806084,%eax
  801bff:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801c05:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c0a:	83 c4 14             	add    $0x14,%esp
  801c0d:	5b                   	pop    %ebx
  801c0e:	5d                   	pop    %ebp
  801c0f:	c3                   	ret    

00801c10 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801c10:	55                   	push   %ebp
  801c11:	89 e5                	mov    %esp,%ebp
  801c13:	83 ec 18             	sub    $0x18,%esp
  801c16:	8b 45 10             	mov    0x10(%ebp),%eax
  801c19:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801c1e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801c23:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801c26:	8b 55 08             	mov    0x8(%ebp),%edx
  801c29:	8b 52 0c             	mov    0xc(%edx),%edx
  801c2c:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801c32:	a3 04 60 80 00       	mov    %eax,0x806004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801c37:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c42:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801c49:	e8 f6 ee ff ff       	call   800b44 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  801c4e:	ba 00 00 00 00       	mov    $0x0,%edx
  801c53:	b8 04 00 00 00       	mov    $0x4,%eax
  801c58:	e8 a6 fe ff ff       	call   801b03 <fsipc>
}
  801c5d:	c9                   	leave  
  801c5e:	c3                   	ret    

00801c5f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c5f:	55                   	push   %ebp
  801c60:	89 e5                	mov    %esp,%ebp
  801c62:	56                   	push   %esi
  801c63:	53                   	push   %ebx
  801c64:	83 ec 10             	sub    $0x10,%esp
  801c67:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6d:	8b 40 0c             	mov    0xc(%eax),%eax
  801c70:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801c75:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c7b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c80:	b8 03 00 00 00       	mov    $0x3,%eax
  801c85:	e8 79 fe ff ff       	call   801b03 <fsipc>
  801c8a:	89 c3                	mov    %eax,%ebx
  801c8c:	85 c0                	test   %eax,%eax
  801c8e:	78 6a                	js     801cfa <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801c90:	39 c6                	cmp    %eax,%esi
  801c92:	73 24                	jae    801cb8 <devfile_read+0x59>
  801c94:	c7 44 24 0c b4 30 80 	movl   $0x8030b4,0xc(%esp)
  801c9b:	00 
  801c9c:	c7 44 24 08 bb 30 80 	movl   $0x8030bb,0x8(%esp)
  801ca3:	00 
  801ca4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801cab:	00 
  801cac:	c7 04 24 d0 30 80 00 	movl   $0x8030d0,(%esp)
  801cb3:	e8 c7 e5 ff ff       	call   80027f <_panic>
	assert(r <= PGSIZE);
  801cb8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801cbd:	7e 24                	jle    801ce3 <devfile_read+0x84>
  801cbf:	c7 44 24 0c db 30 80 	movl   $0x8030db,0xc(%esp)
  801cc6:	00 
  801cc7:	c7 44 24 08 bb 30 80 	movl   $0x8030bb,0x8(%esp)
  801cce:	00 
  801ccf:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801cd6:	00 
  801cd7:	c7 04 24 d0 30 80 00 	movl   $0x8030d0,(%esp)
  801cde:	e8 9c e5 ff ff       	call   80027f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ce3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ce7:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801cee:	00 
  801cef:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf2:	89 04 24             	mov    %eax,(%esp)
  801cf5:	e8 4a ee ff ff       	call   800b44 <memmove>
	return r;
}
  801cfa:	89 d8                	mov    %ebx,%eax
  801cfc:	83 c4 10             	add    $0x10,%esp
  801cff:	5b                   	pop    %ebx
  801d00:	5e                   	pop    %esi
  801d01:	5d                   	pop    %ebp
  801d02:	c3                   	ret    

00801d03 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801d03:	55                   	push   %ebp
  801d04:	89 e5                	mov    %esp,%ebp
  801d06:	53                   	push   %ebx
  801d07:	83 ec 24             	sub    $0x24,%esp
  801d0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801d0d:	89 1c 24             	mov    %ebx,(%esp)
  801d10:	e8 5b ec ff ff       	call   800970 <strlen>
  801d15:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801d1a:	7f 60                	jg     801d7c <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801d1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d1f:	89 04 24             	mov    %eax,(%esp)
  801d22:	e8 20 f8 ff ff       	call   801547 <fd_alloc>
  801d27:	89 c2                	mov    %eax,%edx
  801d29:	85 d2                	test   %edx,%edx
  801d2b:	78 54                	js     801d81 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801d2d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d31:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801d38:	e8 6a ec ff ff       	call   8009a7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801d3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d40:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801d45:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d48:	b8 01 00 00 00       	mov    $0x1,%eax
  801d4d:	e8 b1 fd ff ff       	call   801b03 <fsipc>
  801d52:	89 c3                	mov    %eax,%ebx
  801d54:	85 c0                	test   %eax,%eax
  801d56:	79 17                	jns    801d6f <open+0x6c>
		fd_close(fd, 0);
  801d58:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d5f:	00 
  801d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d63:	89 04 24             	mov    %eax,(%esp)
  801d66:	e8 db f8 ff ff       	call   801646 <fd_close>
		return r;
  801d6b:	89 d8                	mov    %ebx,%eax
  801d6d:	eb 12                	jmp    801d81 <open+0x7e>
	}

	return fd2num(fd);
  801d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d72:	89 04 24             	mov    %eax,(%esp)
  801d75:	e8 a6 f7 ff ff       	call   801520 <fd2num>
  801d7a:	eb 05                	jmp    801d81 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801d7c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801d81:	83 c4 24             	add    $0x24,%esp
  801d84:	5b                   	pop    %ebx
  801d85:	5d                   	pop    %ebp
  801d86:	c3                   	ret    

00801d87 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801d87:	55                   	push   %ebp
  801d88:	89 e5                	mov    %esp,%ebp
  801d8a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d8d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d92:	b8 08 00 00 00       	mov    $0x8,%eax
  801d97:	e8 67 fd ff ff       	call   801b03 <fsipc>
}
  801d9c:	c9                   	leave  
  801d9d:	c3                   	ret    

00801d9e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d9e:	55                   	push   %ebp
  801d9f:	89 e5                	mov    %esp,%ebp
  801da1:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801da4:	89 d0                	mov    %edx,%eax
  801da6:	c1 e8 16             	shr    $0x16,%eax
  801da9:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801db0:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801db5:	f6 c1 01             	test   $0x1,%cl
  801db8:	74 1d                	je     801dd7 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801dba:	c1 ea 0c             	shr    $0xc,%edx
  801dbd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801dc4:	f6 c2 01             	test   $0x1,%dl
  801dc7:	74 0e                	je     801dd7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801dc9:	c1 ea 0c             	shr    $0xc,%edx
  801dcc:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801dd3:	ef 
  801dd4:	0f b7 c0             	movzwl %ax,%eax
}
  801dd7:	5d                   	pop    %ebp
  801dd8:	c3                   	ret    
  801dd9:	66 90                	xchg   %ax,%ax
  801ddb:	66 90                	xchg   %ax,%ax
  801ddd:	66 90                	xchg   %ax,%ax
  801ddf:	90                   	nop

00801de0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801de6:	c7 44 24 04 e7 30 80 	movl   $0x8030e7,0x4(%esp)
  801ded:	00 
  801dee:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df1:	89 04 24             	mov    %eax,(%esp)
  801df4:	e8 ae eb ff ff       	call   8009a7 <strcpy>
	return 0;
}
  801df9:	b8 00 00 00 00       	mov    $0x0,%eax
  801dfe:	c9                   	leave  
  801dff:	c3                   	ret    

00801e00 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	53                   	push   %ebx
  801e04:	83 ec 14             	sub    $0x14,%esp
  801e07:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801e0a:	89 1c 24             	mov    %ebx,(%esp)
  801e0d:	e8 8c ff ff ff       	call   801d9e <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801e12:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801e17:	83 f8 01             	cmp    $0x1,%eax
  801e1a:	75 0d                	jne    801e29 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801e1c:	8b 43 0c             	mov    0xc(%ebx),%eax
  801e1f:	89 04 24             	mov    %eax,(%esp)
  801e22:	e8 29 03 00 00       	call   802150 <nsipc_close>
  801e27:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  801e29:	89 d0                	mov    %edx,%eax
  801e2b:	83 c4 14             	add    $0x14,%esp
  801e2e:	5b                   	pop    %ebx
  801e2f:	5d                   	pop    %ebp
  801e30:	c3                   	ret    

00801e31 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801e31:	55                   	push   %ebp
  801e32:	89 e5                	mov    %esp,%ebp
  801e34:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801e37:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801e3e:	00 
  801e3f:	8b 45 10             	mov    0x10(%ebp),%eax
  801e42:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e46:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e49:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e50:	8b 40 0c             	mov    0xc(%eax),%eax
  801e53:	89 04 24             	mov    %eax,(%esp)
  801e56:	e8 f0 03 00 00       	call   80224b <nsipc_send>
}
  801e5b:	c9                   	leave  
  801e5c:	c3                   	ret    

00801e5d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801e5d:	55                   	push   %ebp
  801e5e:	89 e5                	mov    %esp,%ebp
  801e60:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801e63:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801e6a:	00 
  801e6b:	8b 45 10             	mov    0x10(%ebp),%eax
  801e6e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e72:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e75:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e79:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7c:	8b 40 0c             	mov    0xc(%eax),%eax
  801e7f:	89 04 24             	mov    %eax,(%esp)
  801e82:	e8 44 03 00 00       	call   8021cb <nsipc_recv>
}
  801e87:	c9                   	leave  
  801e88:	c3                   	ret    

00801e89 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801e89:	55                   	push   %ebp
  801e8a:	89 e5                	mov    %esp,%ebp
  801e8c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801e8f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801e92:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e96:	89 04 24             	mov    %eax,(%esp)
  801e99:	e8 f8 f6 ff ff       	call   801596 <fd_lookup>
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	78 17                	js     801eb9 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea5:	8b 0d 20 40 80 00    	mov    0x804020,%ecx
  801eab:	39 08                	cmp    %ecx,(%eax)
  801ead:	75 05                	jne    801eb4 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801eaf:	8b 40 0c             	mov    0xc(%eax),%eax
  801eb2:	eb 05                	jmp    801eb9 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801eb4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801eb9:	c9                   	leave  
  801eba:	c3                   	ret    

00801ebb <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801ebb:	55                   	push   %ebp
  801ebc:	89 e5                	mov    %esp,%ebp
  801ebe:	56                   	push   %esi
  801ebf:	53                   	push   %ebx
  801ec0:	83 ec 20             	sub    $0x20,%esp
  801ec3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801ec5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec8:	89 04 24             	mov    %eax,(%esp)
  801ecb:	e8 77 f6 ff ff       	call   801547 <fd_alloc>
  801ed0:	89 c3                	mov    %eax,%ebx
  801ed2:	85 c0                	test   %eax,%eax
  801ed4:	78 21                	js     801ef7 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801ed6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801edd:	00 
  801ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ee5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eec:	e8 d2 ee ff ff       	call   800dc3 <sys_page_alloc>
  801ef1:	89 c3                	mov    %eax,%ebx
  801ef3:	85 c0                	test   %eax,%eax
  801ef5:	79 0c                	jns    801f03 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  801ef7:	89 34 24             	mov    %esi,(%esp)
  801efa:	e8 51 02 00 00       	call   802150 <nsipc_close>
		return r;
  801eff:	89 d8                	mov    %ebx,%eax
  801f01:	eb 20                	jmp    801f23 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801f03:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801f0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f11:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801f18:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801f1b:	89 14 24             	mov    %edx,(%esp)
  801f1e:	e8 fd f5 ff ff       	call   801520 <fd2num>
}
  801f23:	83 c4 20             	add    $0x20,%esp
  801f26:	5b                   	pop    %ebx
  801f27:	5e                   	pop    %esi
  801f28:	5d                   	pop    %ebp
  801f29:	c3                   	ret    

00801f2a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f2a:	55                   	push   %ebp
  801f2b:	89 e5                	mov    %esp,%ebp
  801f2d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f30:	8b 45 08             	mov    0x8(%ebp),%eax
  801f33:	e8 51 ff ff ff       	call   801e89 <fd2sockid>
		return r;
  801f38:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f3a:	85 c0                	test   %eax,%eax
  801f3c:	78 23                	js     801f61 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801f3e:	8b 55 10             	mov    0x10(%ebp),%edx
  801f41:	89 54 24 08          	mov    %edx,0x8(%esp)
  801f45:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f48:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f4c:	89 04 24             	mov    %eax,(%esp)
  801f4f:	e8 45 01 00 00       	call   802099 <nsipc_accept>
		return r;
  801f54:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801f56:	85 c0                	test   %eax,%eax
  801f58:	78 07                	js     801f61 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  801f5a:	e8 5c ff ff ff       	call   801ebb <alloc_sockfd>
  801f5f:	89 c1                	mov    %eax,%ecx
}
  801f61:	89 c8                	mov    %ecx,%eax
  801f63:	c9                   	leave  
  801f64:	c3                   	ret    

00801f65 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f65:	55                   	push   %ebp
  801f66:	89 e5                	mov    %esp,%ebp
  801f68:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6e:	e8 16 ff ff ff       	call   801e89 <fd2sockid>
  801f73:	89 c2                	mov    %eax,%edx
  801f75:	85 d2                	test   %edx,%edx
  801f77:	78 16                	js     801f8f <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  801f79:	8b 45 10             	mov    0x10(%ebp),%eax
  801f7c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f80:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f83:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f87:	89 14 24             	mov    %edx,(%esp)
  801f8a:	e8 60 01 00 00       	call   8020ef <nsipc_bind>
}
  801f8f:	c9                   	leave  
  801f90:	c3                   	ret    

00801f91 <shutdown>:

int
shutdown(int s, int how)
{
  801f91:	55                   	push   %ebp
  801f92:	89 e5                	mov    %esp,%ebp
  801f94:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f97:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9a:	e8 ea fe ff ff       	call   801e89 <fd2sockid>
  801f9f:	89 c2                	mov    %eax,%edx
  801fa1:	85 d2                	test   %edx,%edx
  801fa3:	78 0f                	js     801fb4 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801fa5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fac:	89 14 24             	mov    %edx,(%esp)
  801faf:	e8 7a 01 00 00       	call   80212e <nsipc_shutdown>
}
  801fb4:	c9                   	leave  
  801fb5:	c3                   	ret    

00801fb6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801fb6:	55                   	push   %ebp
  801fb7:	89 e5                	mov    %esp,%ebp
  801fb9:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801fbf:	e8 c5 fe ff ff       	call   801e89 <fd2sockid>
  801fc4:	89 c2                	mov    %eax,%edx
  801fc6:	85 d2                	test   %edx,%edx
  801fc8:	78 16                	js     801fe0 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  801fca:	8b 45 10             	mov    0x10(%ebp),%eax
  801fcd:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fd1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd8:	89 14 24             	mov    %edx,(%esp)
  801fdb:	e8 8a 01 00 00       	call   80216a <nsipc_connect>
}
  801fe0:	c9                   	leave  
  801fe1:	c3                   	ret    

00801fe2 <listen>:

int
listen(int s, int backlog)
{
  801fe2:	55                   	push   %ebp
  801fe3:	89 e5                	mov    %esp,%ebp
  801fe5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fe8:	8b 45 08             	mov    0x8(%ebp),%eax
  801feb:	e8 99 fe ff ff       	call   801e89 <fd2sockid>
  801ff0:	89 c2                	mov    %eax,%edx
  801ff2:	85 d2                	test   %edx,%edx
  801ff4:	78 0f                	js     802005 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801ff6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ffd:	89 14 24             	mov    %edx,(%esp)
  802000:	e8 a4 01 00 00       	call   8021a9 <nsipc_listen>
}
  802005:	c9                   	leave  
  802006:	c3                   	ret    

00802007 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802007:	55                   	push   %ebp
  802008:	89 e5                	mov    %esp,%ebp
  80200a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80200d:	8b 45 10             	mov    0x10(%ebp),%eax
  802010:	89 44 24 08          	mov    %eax,0x8(%esp)
  802014:	8b 45 0c             	mov    0xc(%ebp),%eax
  802017:	89 44 24 04          	mov    %eax,0x4(%esp)
  80201b:	8b 45 08             	mov    0x8(%ebp),%eax
  80201e:	89 04 24             	mov    %eax,(%esp)
  802021:	e8 98 02 00 00       	call   8022be <nsipc_socket>
  802026:	89 c2                	mov    %eax,%edx
  802028:	85 d2                	test   %edx,%edx
  80202a:	78 05                	js     802031 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  80202c:	e8 8a fe ff ff       	call   801ebb <alloc_sockfd>
}
  802031:	c9                   	leave  
  802032:	c3                   	ret    

00802033 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802033:	55                   	push   %ebp
  802034:	89 e5                	mov    %esp,%ebp
  802036:	53                   	push   %ebx
  802037:	83 ec 14             	sub    $0x14,%esp
  80203a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80203c:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802043:	75 11                	jne    802056 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802045:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80204c:	e8 94 f4 ff ff       	call   8014e5 <ipc_find_env>
  802051:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802056:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80205d:	00 
  80205e:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802065:	00 
  802066:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80206a:	a1 04 50 80 00       	mov    0x805004,%eax
  80206f:	89 04 24             	mov    %eax,(%esp)
  802072:	e8 03 f4 ff ff       	call   80147a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802077:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80207e:	00 
  80207f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802086:	00 
  802087:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80208e:	e8 6d f3 ff ff       	call   801400 <ipc_recv>
}
  802093:	83 c4 14             	add    $0x14,%esp
  802096:	5b                   	pop    %ebx
  802097:	5d                   	pop    %ebp
  802098:	c3                   	ret    

00802099 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802099:	55                   	push   %ebp
  80209a:	89 e5                	mov    %esp,%ebp
  80209c:	56                   	push   %esi
  80209d:	53                   	push   %ebx
  80209e:	83 ec 10             	sub    $0x10,%esp
  8020a1:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8020a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8020ac:	8b 06                	mov    (%esi),%eax
  8020ae:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8020b3:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b8:	e8 76 ff ff ff       	call   802033 <nsipc>
  8020bd:	89 c3                	mov    %eax,%ebx
  8020bf:	85 c0                	test   %eax,%eax
  8020c1:	78 23                	js     8020e6 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8020c3:	a1 10 70 80 00       	mov    0x807010,%eax
  8020c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020cc:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8020d3:	00 
  8020d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d7:	89 04 24             	mov    %eax,(%esp)
  8020da:	e8 65 ea ff ff       	call   800b44 <memmove>
		*addrlen = ret->ret_addrlen;
  8020df:	a1 10 70 80 00       	mov    0x807010,%eax
  8020e4:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  8020e6:	89 d8                	mov    %ebx,%eax
  8020e8:	83 c4 10             	add    $0x10,%esp
  8020eb:	5b                   	pop    %ebx
  8020ec:	5e                   	pop    %esi
  8020ed:	5d                   	pop    %ebp
  8020ee:	c3                   	ret    

008020ef <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8020ef:	55                   	push   %ebp
  8020f0:	89 e5                	mov    %esp,%ebp
  8020f2:	53                   	push   %ebx
  8020f3:	83 ec 14             	sub    $0x14,%esp
  8020f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8020f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8020fc:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802101:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802105:	8b 45 0c             	mov    0xc(%ebp),%eax
  802108:	89 44 24 04          	mov    %eax,0x4(%esp)
  80210c:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802113:	e8 2c ea ff ff       	call   800b44 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802118:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80211e:	b8 02 00 00 00       	mov    $0x2,%eax
  802123:	e8 0b ff ff ff       	call   802033 <nsipc>
}
  802128:	83 c4 14             	add    $0x14,%esp
  80212b:	5b                   	pop    %ebx
  80212c:	5d                   	pop    %ebp
  80212d:	c3                   	ret    

0080212e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80212e:	55                   	push   %ebp
  80212f:	89 e5                	mov    %esp,%ebp
  802131:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802134:	8b 45 08             	mov    0x8(%ebp),%eax
  802137:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80213c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80213f:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802144:	b8 03 00 00 00       	mov    $0x3,%eax
  802149:	e8 e5 fe ff ff       	call   802033 <nsipc>
}
  80214e:	c9                   	leave  
  80214f:	c3                   	ret    

00802150 <nsipc_close>:

int
nsipc_close(int s)
{
  802150:	55                   	push   %ebp
  802151:	89 e5                	mov    %esp,%ebp
  802153:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802156:	8b 45 08             	mov    0x8(%ebp),%eax
  802159:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  80215e:	b8 04 00 00 00       	mov    $0x4,%eax
  802163:	e8 cb fe ff ff       	call   802033 <nsipc>
}
  802168:	c9                   	leave  
  802169:	c3                   	ret    

0080216a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80216a:	55                   	push   %ebp
  80216b:	89 e5                	mov    %esp,%ebp
  80216d:	53                   	push   %ebx
  80216e:	83 ec 14             	sub    $0x14,%esp
  802171:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802174:	8b 45 08             	mov    0x8(%ebp),%eax
  802177:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80217c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802180:	8b 45 0c             	mov    0xc(%ebp),%eax
  802183:	89 44 24 04          	mov    %eax,0x4(%esp)
  802187:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  80218e:	e8 b1 e9 ff ff       	call   800b44 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802193:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802199:	b8 05 00 00 00       	mov    $0x5,%eax
  80219e:	e8 90 fe ff ff       	call   802033 <nsipc>
}
  8021a3:	83 c4 14             	add    $0x14,%esp
  8021a6:	5b                   	pop    %ebx
  8021a7:	5d                   	pop    %ebp
  8021a8:	c3                   	ret    

008021a9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8021a9:	55                   	push   %ebp
  8021aa:	89 e5                	mov    %esp,%ebp
  8021ac:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8021af:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8021b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021ba:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8021bf:	b8 06 00 00 00       	mov    $0x6,%eax
  8021c4:	e8 6a fe ff ff       	call   802033 <nsipc>
}
  8021c9:	c9                   	leave  
  8021ca:	c3                   	ret    

008021cb <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8021cb:	55                   	push   %ebp
  8021cc:	89 e5                	mov    %esp,%ebp
  8021ce:	56                   	push   %esi
  8021cf:	53                   	push   %ebx
  8021d0:	83 ec 10             	sub    $0x10,%esp
  8021d3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8021d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8021de:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8021e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8021e7:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8021ec:	b8 07 00 00 00       	mov    $0x7,%eax
  8021f1:	e8 3d fe ff ff       	call   802033 <nsipc>
  8021f6:	89 c3                	mov    %eax,%ebx
  8021f8:	85 c0                	test   %eax,%eax
  8021fa:	78 46                	js     802242 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8021fc:	39 f0                	cmp    %esi,%eax
  8021fe:	7f 07                	jg     802207 <nsipc_recv+0x3c>
  802200:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802205:	7e 24                	jle    80222b <nsipc_recv+0x60>
  802207:	c7 44 24 0c f3 30 80 	movl   $0x8030f3,0xc(%esp)
  80220e:	00 
  80220f:	c7 44 24 08 bb 30 80 	movl   $0x8030bb,0x8(%esp)
  802216:	00 
  802217:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80221e:	00 
  80221f:	c7 04 24 08 31 80 00 	movl   $0x803108,(%esp)
  802226:	e8 54 e0 ff ff       	call   80027f <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80222b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80222f:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802236:	00 
  802237:	8b 45 0c             	mov    0xc(%ebp),%eax
  80223a:	89 04 24             	mov    %eax,(%esp)
  80223d:	e8 02 e9 ff ff       	call   800b44 <memmove>
	}

	return r;
}
  802242:	89 d8                	mov    %ebx,%eax
  802244:	83 c4 10             	add    $0x10,%esp
  802247:	5b                   	pop    %ebx
  802248:	5e                   	pop    %esi
  802249:	5d                   	pop    %ebp
  80224a:	c3                   	ret    

0080224b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80224b:	55                   	push   %ebp
  80224c:	89 e5                	mov    %esp,%ebp
  80224e:	53                   	push   %ebx
  80224f:	83 ec 14             	sub    $0x14,%esp
  802252:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802255:	8b 45 08             	mov    0x8(%ebp),%eax
  802258:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  80225d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802263:	7e 24                	jle    802289 <nsipc_send+0x3e>
  802265:	c7 44 24 0c 14 31 80 	movl   $0x803114,0xc(%esp)
  80226c:	00 
  80226d:	c7 44 24 08 bb 30 80 	movl   $0x8030bb,0x8(%esp)
  802274:	00 
  802275:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  80227c:	00 
  80227d:	c7 04 24 08 31 80 00 	movl   $0x803108,(%esp)
  802284:	e8 f6 df ff ff       	call   80027f <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802289:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80228d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802290:	89 44 24 04          	mov    %eax,0x4(%esp)
  802294:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  80229b:	e8 a4 e8 ff ff       	call   800b44 <memmove>
	nsipcbuf.send.req_size = size;
  8022a0:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8022a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8022a9:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8022ae:	b8 08 00 00 00       	mov    $0x8,%eax
  8022b3:	e8 7b fd ff ff       	call   802033 <nsipc>
}
  8022b8:	83 c4 14             	add    $0x14,%esp
  8022bb:	5b                   	pop    %ebx
  8022bc:	5d                   	pop    %ebp
  8022bd:	c3                   	ret    

008022be <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8022be:	55                   	push   %ebp
  8022bf:	89 e5                	mov    %esp,%ebp
  8022c1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8022c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8022c7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8022cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022cf:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8022d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8022d7:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8022dc:	b8 09 00 00 00       	mov    $0x9,%eax
  8022e1:	e8 4d fd ff ff       	call   802033 <nsipc>
}
  8022e6:	c9                   	leave  
  8022e7:	c3                   	ret    

008022e8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8022e8:	55                   	push   %ebp
  8022e9:	89 e5                	mov    %esp,%ebp
  8022eb:	56                   	push   %esi
  8022ec:	53                   	push   %ebx
  8022ed:	83 ec 10             	sub    $0x10,%esp
  8022f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8022f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f6:	89 04 24             	mov    %eax,(%esp)
  8022f9:	e8 32 f2 ff ff       	call   801530 <fd2data>
  8022fe:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802300:	c7 44 24 04 20 31 80 	movl   $0x803120,0x4(%esp)
  802307:	00 
  802308:	89 1c 24             	mov    %ebx,(%esp)
  80230b:	e8 97 e6 ff ff       	call   8009a7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802310:	8b 46 04             	mov    0x4(%esi),%eax
  802313:	2b 06                	sub    (%esi),%eax
  802315:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80231b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802322:	00 00 00 
	stat->st_dev = &devpipe;
  802325:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  80232c:	40 80 00 
	return 0;
}
  80232f:	b8 00 00 00 00       	mov    $0x0,%eax
  802334:	83 c4 10             	add    $0x10,%esp
  802337:	5b                   	pop    %ebx
  802338:	5e                   	pop    %esi
  802339:	5d                   	pop    %ebp
  80233a:	c3                   	ret    

0080233b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80233b:	55                   	push   %ebp
  80233c:	89 e5                	mov    %esp,%ebp
  80233e:	53                   	push   %ebx
  80233f:	83 ec 14             	sub    $0x14,%esp
  802342:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802345:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802349:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802350:	e8 15 eb ff ff       	call   800e6a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802355:	89 1c 24             	mov    %ebx,(%esp)
  802358:	e8 d3 f1 ff ff       	call   801530 <fd2data>
  80235d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802361:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802368:	e8 fd ea ff ff       	call   800e6a <sys_page_unmap>
}
  80236d:	83 c4 14             	add    $0x14,%esp
  802370:	5b                   	pop    %ebx
  802371:	5d                   	pop    %ebp
  802372:	c3                   	ret    

00802373 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802373:	55                   	push   %ebp
  802374:	89 e5                	mov    %esp,%ebp
  802376:	57                   	push   %edi
  802377:	56                   	push   %esi
  802378:	53                   	push   %ebx
  802379:	83 ec 2c             	sub    $0x2c,%esp
  80237c:	89 c6                	mov    %eax,%esi
  80237e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802381:	a1 08 50 80 00       	mov    0x805008,%eax
  802386:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802389:	89 34 24             	mov    %esi,(%esp)
  80238c:	e8 0d fa ff ff       	call   801d9e <pageref>
  802391:	89 c7                	mov    %eax,%edi
  802393:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802396:	89 04 24             	mov    %eax,(%esp)
  802399:	e8 00 fa ff ff       	call   801d9e <pageref>
  80239e:	39 c7                	cmp    %eax,%edi
  8023a0:	0f 94 c2             	sete   %dl
  8023a3:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8023a6:	8b 0d 08 50 80 00    	mov    0x805008,%ecx
  8023ac:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8023af:	39 fb                	cmp    %edi,%ebx
  8023b1:	74 21                	je     8023d4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8023b3:	84 d2                	test   %dl,%dl
  8023b5:	74 ca                	je     802381 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8023b7:	8b 51 58             	mov    0x58(%ecx),%edx
  8023ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023be:	89 54 24 08          	mov    %edx,0x8(%esp)
  8023c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8023c6:	c7 04 24 27 31 80 00 	movl   $0x803127,(%esp)
  8023cd:	e8 a6 df ff ff       	call   800378 <cprintf>
  8023d2:	eb ad                	jmp    802381 <_pipeisclosed+0xe>
	}
}
  8023d4:	83 c4 2c             	add    $0x2c,%esp
  8023d7:	5b                   	pop    %ebx
  8023d8:	5e                   	pop    %esi
  8023d9:	5f                   	pop    %edi
  8023da:	5d                   	pop    %ebp
  8023db:	c3                   	ret    

008023dc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8023dc:	55                   	push   %ebp
  8023dd:	89 e5                	mov    %esp,%ebp
  8023df:	57                   	push   %edi
  8023e0:	56                   	push   %esi
  8023e1:	53                   	push   %ebx
  8023e2:	83 ec 1c             	sub    $0x1c,%esp
  8023e5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8023e8:	89 34 24             	mov    %esi,(%esp)
  8023eb:	e8 40 f1 ff ff       	call   801530 <fd2data>
  8023f0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023f2:	bf 00 00 00 00       	mov    $0x0,%edi
  8023f7:	eb 45                	jmp    80243e <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8023f9:	89 da                	mov    %ebx,%edx
  8023fb:	89 f0                	mov    %esi,%eax
  8023fd:	e8 71 ff ff ff       	call   802373 <_pipeisclosed>
  802402:	85 c0                	test   %eax,%eax
  802404:	75 41                	jne    802447 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802406:	e8 99 e9 ff ff       	call   800da4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80240b:	8b 43 04             	mov    0x4(%ebx),%eax
  80240e:	8b 0b                	mov    (%ebx),%ecx
  802410:	8d 51 20             	lea    0x20(%ecx),%edx
  802413:	39 d0                	cmp    %edx,%eax
  802415:	73 e2                	jae    8023f9 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802417:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80241a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80241e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802421:	99                   	cltd   
  802422:	c1 ea 1b             	shr    $0x1b,%edx
  802425:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802428:	83 e1 1f             	and    $0x1f,%ecx
  80242b:	29 d1                	sub    %edx,%ecx
  80242d:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  802431:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  802435:	83 c0 01             	add    $0x1,%eax
  802438:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80243b:	83 c7 01             	add    $0x1,%edi
  80243e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802441:	75 c8                	jne    80240b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802443:	89 f8                	mov    %edi,%eax
  802445:	eb 05                	jmp    80244c <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802447:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80244c:	83 c4 1c             	add    $0x1c,%esp
  80244f:	5b                   	pop    %ebx
  802450:	5e                   	pop    %esi
  802451:	5f                   	pop    %edi
  802452:	5d                   	pop    %ebp
  802453:	c3                   	ret    

00802454 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802454:	55                   	push   %ebp
  802455:	89 e5                	mov    %esp,%ebp
  802457:	57                   	push   %edi
  802458:	56                   	push   %esi
  802459:	53                   	push   %ebx
  80245a:	83 ec 1c             	sub    $0x1c,%esp
  80245d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802460:	89 3c 24             	mov    %edi,(%esp)
  802463:	e8 c8 f0 ff ff       	call   801530 <fd2data>
  802468:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80246a:	be 00 00 00 00       	mov    $0x0,%esi
  80246f:	eb 3d                	jmp    8024ae <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802471:	85 f6                	test   %esi,%esi
  802473:	74 04                	je     802479 <devpipe_read+0x25>
				return i;
  802475:	89 f0                	mov    %esi,%eax
  802477:	eb 43                	jmp    8024bc <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802479:	89 da                	mov    %ebx,%edx
  80247b:	89 f8                	mov    %edi,%eax
  80247d:	e8 f1 fe ff ff       	call   802373 <_pipeisclosed>
  802482:	85 c0                	test   %eax,%eax
  802484:	75 31                	jne    8024b7 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802486:	e8 19 e9 ff ff       	call   800da4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80248b:	8b 03                	mov    (%ebx),%eax
  80248d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802490:	74 df                	je     802471 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802492:	99                   	cltd   
  802493:	c1 ea 1b             	shr    $0x1b,%edx
  802496:	01 d0                	add    %edx,%eax
  802498:	83 e0 1f             	and    $0x1f,%eax
  80249b:	29 d0                	sub    %edx,%eax
  80249d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8024a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024a5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8024a8:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024ab:	83 c6 01             	add    $0x1,%esi
  8024ae:	3b 75 10             	cmp    0x10(%ebp),%esi
  8024b1:	75 d8                	jne    80248b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8024b3:	89 f0                	mov    %esi,%eax
  8024b5:	eb 05                	jmp    8024bc <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8024b7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8024bc:	83 c4 1c             	add    $0x1c,%esp
  8024bf:	5b                   	pop    %ebx
  8024c0:	5e                   	pop    %esi
  8024c1:	5f                   	pop    %edi
  8024c2:	5d                   	pop    %ebp
  8024c3:	c3                   	ret    

008024c4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8024c4:	55                   	push   %ebp
  8024c5:	89 e5                	mov    %esp,%ebp
  8024c7:	56                   	push   %esi
  8024c8:	53                   	push   %ebx
  8024c9:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8024cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024cf:	89 04 24             	mov    %eax,(%esp)
  8024d2:	e8 70 f0 ff ff       	call   801547 <fd_alloc>
  8024d7:	89 c2                	mov    %eax,%edx
  8024d9:	85 d2                	test   %edx,%edx
  8024db:	0f 88 4d 01 00 00    	js     80262e <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024e1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8024e8:	00 
  8024e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024f7:	e8 c7 e8 ff ff       	call   800dc3 <sys_page_alloc>
  8024fc:	89 c2                	mov    %eax,%edx
  8024fe:	85 d2                	test   %edx,%edx
  802500:	0f 88 28 01 00 00    	js     80262e <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802506:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802509:	89 04 24             	mov    %eax,(%esp)
  80250c:	e8 36 f0 ff ff       	call   801547 <fd_alloc>
  802511:	89 c3                	mov    %eax,%ebx
  802513:	85 c0                	test   %eax,%eax
  802515:	0f 88 fe 00 00 00    	js     802619 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80251b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802522:	00 
  802523:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802526:	89 44 24 04          	mov    %eax,0x4(%esp)
  80252a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802531:	e8 8d e8 ff ff       	call   800dc3 <sys_page_alloc>
  802536:	89 c3                	mov    %eax,%ebx
  802538:	85 c0                	test   %eax,%eax
  80253a:	0f 88 d9 00 00 00    	js     802619 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802540:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802543:	89 04 24             	mov    %eax,(%esp)
  802546:	e8 e5 ef ff ff       	call   801530 <fd2data>
  80254b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80254d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802554:	00 
  802555:	89 44 24 04          	mov    %eax,0x4(%esp)
  802559:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802560:	e8 5e e8 ff ff       	call   800dc3 <sys_page_alloc>
  802565:	89 c3                	mov    %eax,%ebx
  802567:	85 c0                	test   %eax,%eax
  802569:	0f 88 97 00 00 00    	js     802606 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80256f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802572:	89 04 24             	mov    %eax,(%esp)
  802575:	e8 b6 ef ff ff       	call   801530 <fd2data>
  80257a:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802581:	00 
  802582:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802586:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80258d:	00 
  80258e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802592:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802599:	e8 79 e8 ff ff       	call   800e17 <sys_page_map>
  80259e:	89 c3                	mov    %eax,%ebx
  8025a0:	85 c0                	test   %eax,%eax
  8025a2:	78 52                	js     8025f6 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8025a4:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8025aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025ad:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8025af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025b2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8025b9:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8025bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8025c2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8025c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8025c7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8025ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025d1:	89 04 24             	mov    %eax,(%esp)
  8025d4:	e8 47 ef ff ff       	call   801520 <fd2num>
  8025d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8025dc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8025de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8025e1:	89 04 24             	mov    %eax,(%esp)
  8025e4:	e8 37 ef ff ff       	call   801520 <fd2num>
  8025e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8025ec:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8025ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8025f4:	eb 38                	jmp    80262e <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  8025f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802601:	e8 64 e8 ff ff       	call   800e6a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802606:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802609:	89 44 24 04          	mov    %eax,0x4(%esp)
  80260d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802614:	e8 51 e8 ff ff       	call   800e6a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802619:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80261c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802620:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802627:	e8 3e e8 ff ff       	call   800e6a <sys_page_unmap>
  80262c:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  80262e:	83 c4 30             	add    $0x30,%esp
  802631:	5b                   	pop    %ebx
  802632:	5e                   	pop    %esi
  802633:	5d                   	pop    %ebp
  802634:	c3                   	ret    

00802635 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802635:	55                   	push   %ebp
  802636:	89 e5                	mov    %esp,%ebp
  802638:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80263b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80263e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802642:	8b 45 08             	mov    0x8(%ebp),%eax
  802645:	89 04 24             	mov    %eax,(%esp)
  802648:	e8 49 ef ff ff       	call   801596 <fd_lookup>
  80264d:	89 c2                	mov    %eax,%edx
  80264f:	85 d2                	test   %edx,%edx
  802651:	78 15                	js     802668 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802653:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802656:	89 04 24             	mov    %eax,(%esp)
  802659:	e8 d2 ee ff ff       	call   801530 <fd2data>
	return _pipeisclosed(fd, p);
  80265e:	89 c2                	mov    %eax,%edx
  802660:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802663:	e8 0b fd ff ff       	call   802373 <_pipeisclosed>
}
  802668:	c9                   	leave  
  802669:	c3                   	ret    
  80266a:	66 90                	xchg   %ax,%ax
  80266c:	66 90                	xchg   %ax,%ax
  80266e:	66 90                	xchg   %ax,%ax

00802670 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802670:	55                   	push   %ebp
  802671:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802673:	b8 00 00 00 00       	mov    $0x0,%eax
  802678:	5d                   	pop    %ebp
  802679:	c3                   	ret    

0080267a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80267a:	55                   	push   %ebp
  80267b:	89 e5                	mov    %esp,%ebp
  80267d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802680:	c7 44 24 04 3f 31 80 	movl   $0x80313f,0x4(%esp)
  802687:	00 
  802688:	8b 45 0c             	mov    0xc(%ebp),%eax
  80268b:	89 04 24             	mov    %eax,(%esp)
  80268e:	e8 14 e3 ff ff       	call   8009a7 <strcpy>
	return 0;
}
  802693:	b8 00 00 00 00       	mov    $0x0,%eax
  802698:	c9                   	leave  
  802699:	c3                   	ret    

0080269a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80269a:	55                   	push   %ebp
  80269b:	89 e5                	mov    %esp,%ebp
  80269d:	57                   	push   %edi
  80269e:	56                   	push   %esi
  80269f:	53                   	push   %ebx
  8026a0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8026a6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8026ab:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8026b1:	eb 31                	jmp    8026e4 <devcons_write+0x4a>
		m = n - tot;
  8026b3:	8b 75 10             	mov    0x10(%ebp),%esi
  8026b6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8026b8:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8026bb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8026c0:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8026c3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8026c7:	03 45 0c             	add    0xc(%ebp),%eax
  8026ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026ce:	89 3c 24             	mov    %edi,(%esp)
  8026d1:	e8 6e e4 ff ff       	call   800b44 <memmove>
		sys_cputs(buf, m);
  8026d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026da:	89 3c 24             	mov    %edi,(%esp)
  8026dd:	e8 14 e6 ff ff       	call   800cf6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8026e2:	01 f3                	add    %esi,%ebx
  8026e4:	89 d8                	mov    %ebx,%eax
  8026e6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8026e9:	72 c8                	jb     8026b3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8026eb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8026f1:	5b                   	pop    %ebx
  8026f2:	5e                   	pop    %esi
  8026f3:	5f                   	pop    %edi
  8026f4:	5d                   	pop    %ebp
  8026f5:	c3                   	ret    

008026f6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8026f6:	55                   	push   %ebp
  8026f7:	89 e5                	mov    %esp,%ebp
  8026f9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8026fc:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802701:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802705:	75 07                	jne    80270e <devcons_read+0x18>
  802707:	eb 2a                	jmp    802733 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802709:	e8 96 e6 ff ff       	call   800da4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80270e:	66 90                	xchg   %ax,%ax
  802710:	e8 ff e5 ff ff       	call   800d14 <sys_cgetc>
  802715:	85 c0                	test   %eax,%eax
  802717:	74 f0                	je     802709 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802719:	85 c0                	test   %eax,%eax
  80271b:	78 16                	js     802733 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80271d:	83 f8 04             	cmp    $0x4,%eax
  802720:	74 0c                	je     80272e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802722:	8b 55 0c             	mov    0xc(%ebp),%edx
  802725:	88 02                	mov    %al,(%edx)
	return 1;
  802727:	b8 01 00 00 00       	mov    $0x1,%eax
  80272c:	eb 05                	jmp    802733 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80272e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802733:	c9                   	leave  
  802734:	c3                   	ret    

00802735 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802735:	55                   	push   %ebp
  802736:	89 e5                	mov    %esp,%ebp
  802738:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80273b:	8b 45 08             	mov    0x8(%ebp),%eax
  80273e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802741:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802748:	00 
  802749:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80274c:	89 04 24             	mov    %eax,(%esp)
  80274f:	e8 a2 e5 ff ff       	call   800cf6 <sys_cputs>
}
  802754:	c9                   	leave  
  802755:	c3                   	ret    

00802756 <getchar>:

int
getchar(void)
{
  802756:	55                   	push   %ebp
  802757:	89 e5                	mov    %esp,%ebp
  802759:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80275c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802763:	00 
  802764:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802767:	89 44 24 04          	mov    %eax,0x4(%esp)
  80276b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802772:	e8 b3 f0 ff ff       	call   80182a <read>
	if (r < 0)
  802777:	85 c0                	test   %eax,%eax
  802779:	78 0f                	js     80278a <getchar+0x34>
		return r;
	if (r < 1)
  80277b:	85 c0                	test   %eax,%eax
  80277d:	7e 06                	jle    802785 <getchar+0x2f>
		return -E_EOF;
	return c;
  80277f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802783:	eb 05                	jmp    80278a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802785:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80278a:	c9                   	leave  
  80278b:	c3                   	ret    

0080278c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80278c:	55                   	push   %ebp
  80278d:	89 e5                	mov    %esp,%ebp
  80278f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802792:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802795:	89 44 24 04          	mov    %eax,0x4(%esp)
  802799:	8b 45 08             	mov    0x8(%ebp),%eax
  80279c:	89 04 24             	mov    %eax,(%esp)
  80279f:	e8 f2 ed ff ff       	call   801596 <fd_lookup>
  8027a4:	85 c0                	test   %eax,%eax
  8027a6:	78 11                	js     8027b9 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8027a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027ab:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8027b1:	39 10                	cmp    %edx,(%eax)
  8027b3:	0f 94 c0             	sete   %al
  8027b6:	0f b6 c0             	movzbl %al,%eax
}
  8027b9:	c9                   	leave  
  8027ba:	c3                   	ret    

008027bb <opencons>:

int
opencons(void)
{
  8027bb:	55                   	push   %ebp
  8027bc:	89 e5                	mov    %esp,%ebp
  8027be:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8027c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8027c4:	89 04 24             	mov    %eax,(%esp)
  8027c7:	e8 7b ed ff ff       	call   801547 <fd_alloc>
		return r;
  8027cc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8027ce:	85 c0                	test   %eax,%eax
  8027d0:	78 40                	js     802812 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8027d2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8027d9:	00 
  8027da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027e8:	e8 d6 e5 ff ff       	call   800dc3 <sys_page_alloc>
		return r;
  8027ed:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8027ef:	85 c0                	test   %eax,%eax
  8027f1:	78 1f                	js     802812 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8027f3:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8027f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027fc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8027fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802801:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802808:	89 04 24             	mov    %eax,(%esp)
  80280b:	e8 10 ed ff ff       	call   801520 <fd2num>
  802810:	89 c2                	mov    %eax,%edx
}
  802812:	89 d0                	mov    %edx,%eax
  802814:	c9                   	leave  
  802815:	c3                   	ret    

00802816 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802816:	55                   	push   %ebp
  802817:	89 e5                	mov    %esp,%ebp
  802819:	53                   	push   %ebx
  80281a:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  80281d:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802824:	75 2f                	jne    802855 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  802826:	e8 5a e5 ff ff       	call   800d85 <sys_getenvid>
  80282b:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P);
  80282d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802834:	00 
  802835:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80283c:	ee 
  80283d:	89 04 24             	mov    %eax,(%esp)
  802840:	e8 7e e5 ff ff       	call   800dc3 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *)_pgfault_upcall);
  802845:	c7 44 24 04 63 28 80 	movl   $0x802863,0x4(%esp)
  80284c:	00 
  80284d:	89 1c 24             	mov    %ebx,(%esp)
  802850:	e8 0e e7 ff ff       	call   800f63 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802855:	8b 45 08             	mov    0x8(%ebp),%eax
  802858:	a3 00 80 80 00       	mov    %eax,0x808000
}
  80285d:	83 c4 14             	add    $0x14,%esp
  802860:	5b                   	pop    %ebx
  802861:	5d                   	pop    %ebp
  802862:	c3                   	ret    

00802863 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802863:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802864:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802869:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80286b:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	// 0x30(%esp) points to trap-time stack pointer
	// 0x28(%esp) points to trap-time eip
	subl $4, 0x30(%esp)
  80286e:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax 
  802873:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebp
  802877:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %ebp, (%eax)
  80287b:	89 28                	mov    %ebp,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  80287d:	83 c4 08             	add    $0x8,%esp
	popal
  802880:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp //pop eip - we already stored it
  802881:	83 c4 04             	add    $0x4,%esp
	popfl
  802884:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802885:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802886:	c3                   	ret    
  802887:	66 90                	xchg   %ax,%ax
  802889:	66 90                	xchg   %ax,%ax
  80288b:	66 90                	xchg   %ax,%ax
  80288d:	66 90                	xchg   %ax,%ax
  80288f:	90                   	nop

00802890 <__udivdi3>:
  802890:	55                   	push   %ebp
  802891:	57                   	push   %edi
  802892:	56                   	push   %esi
  802893:	83 ec 0c             	sub    $0xc,%esp
  802896:	8b 44 24 28          	mov    0x28(%esp),%eax
  80289a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80289e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8028a2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8028a6:	85 c0                	test   %eax,%eax
  8028a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8028ac:	89 ea                	mov    %ebp,%edx
  8028ae:	89 0c 24             	mov    %ecx,(%esp)
  8028b1:	75 2d                	jne    8028e0 <__udivdi3+0x50>
  8028b3:	39 e9                	cmp    %ebp,%ecx
  8028b5:	77 61                	ja     802918 <__udivdi3+0x88>
  8028b7:	85 c9                	test   %ecx,%ecx
  8028b9:	89 ce                	mov    %ecx,%esi
  8028bb:	75 0b                	jne    8028c8 <__udivdi3+0x38>
  8028bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8028c2:	31 d2                	xor    %edx,%edx
  8028c4:	f7 f1                	div    %ecx
  8028c6:	89 c6                	mov    %eax,%esi
  8028c8:	31 d2                	xor    %edx,%edx
  8028ca:	89 e8                	mov    %ebp,%eax
  8028cc:	f7 f6                	div    %esi
  8028ce:	89 c5                	mov    %eax,%ebp
  8028d0:	89 f8                	mov    %edi,%eax
  8028d2:	f7 f6                	div    %esi
  8028d4:	89 ea                	mov    %ebp,%edx
  8028d6:	83 c4 0c             	add    $0xc,%esp
  8028d9:	5e                   	pop    %esi
  8028da:	5f                   	pop    %edi
  8028db:	5d                   	pop    %ebp
  8028dc:	c3                   	ret    
  8028dd:	8d 76 00             	lea    0x0(%esi),%esi
  8028e0:	39 e8                	cmp    %ebp,%eax
  8028e2:	77 24                	ja     802908 <__udivdi3+0x78>
  8028e4:	0f bd e8             	bsr    %eax,%ebp
  8028e7:	83 f5 1f             	xor    $0x1f,%ebp
  8028ea:	75 3c                	jne    802928 <__udivdi3+0x98>
  8028ec:	8b 74 24 04          	mov    0x4(%esp),%esi
  8028f0:	39 34 24             	cmp    %esi,(%esp)
  8028f3:	0f 86 9f 00 00 00    	jbe    802998 <__udivdi3+0x108>
  8028f9:	39 d0                	cmp    %edx,%eax
  8028fb:	0f 82 97 00 00 00    	jb     802998 <__udivdi3+0x108>
  802901:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802908:	31 d2                	xor    %edx,%edx
  80290a:	31 c0                	xor    %eax,%eax
  80290c:	83 c4 0c             	add    $0xc,%esp
  80290f:	5e                   	pop    %esi
  802910:	5f                   	pop    %edi
  802911:	5d                   	pop    %ebp
  802912:	c3                   	ret    
  802913:	90                   	nop
  802914:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802918:	89 f8                	mov    %edi,%eax
  80291a:	f7 f1                	div    %ecx
  80291c:	31 d2                	xor    %edx,%edx
  80291e:	83 c4 0c             	add    $0xc,%esp
  802921:	5e                   	pop    %esi
  802922:	5f                   	pop    %edi
  802923:	5d                   	pop    %ebp
  802924:	c3                   	ret    
  802925:	8d 76 00             	lea    0x0(%esi),%esi
  802928:	89 e9                	mov    %ebp,%ecx
  80292a:	8b 3c 24             	mov    (%esp),%edi
  80292d:	d3 e0                	shl    %cl,%eax
  80292f:	89 c6                	mov    %eax,%esi
  802931:	b8 20 00 00 00       	mov    $0x20,%eax
  802936:	29 e8                	sub    %ebp,%eax
  802938:	89 c1                	mov    %eax,%ecx
  80293a:	d3 ef                	shr    %cl,%edi
  80293c:	89 e9                	mov    %ebp,%ecx
  80293e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802942:	8b 3c 24             	mov    (%esp),%edi
  802945:	09 74 24 08          	or     %esi,0x8(%esp)
  802949:	89 d6                	mov    %edx,%esi
  80294b:	d3 e7                	shl    %cl,%edi
  80294d:	89 c1                	mov    %eax,%ecx
  80294f:	89 3c 24             	mov    %edi,(%esp)
  802952:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802956:	d3 ee                	shr    %cl,%esi
  802958:	89 e9                	mov    %ebp,%ecx
  80295a:	d3 e2                	shl    %cl,%edx
  80295c:	89 c1                	mov    %eax,%ecx
  80295e:	d3 ef                	shr    %cl,%edi
  802960:	09 d7                	or     %edx,%edi
  802962:	89 f2                	mov    %esi,%edx
  802964:	89 f8                	mov    %edi,%eax
  802966:	f7 74 24 08          	divl   0x8(%esp)
  80296a:	89 d6                	mov    %edx,%esi
  80296c:	89 c7                	mov    %eax,%edi
  80296e:	f7 24 24             	mull   (%esp)
  802971:	39 d6                	cmp    %edx,%esi
  802973:	89 14 24             	mov    %edx,(%esp)
  802976:	72 30                	jb     8029a8 <__udivdi3+0x118>
  802978:	8b 54 24 04          	mov    0x4(%esp),%edx
  80297c:	89 e9                	mov    %ebp,%ecx
  80297e:	d3 e2                	shl    %cl,%edx
  802980:	39 c2                	cmp    %eax,%edx
  802982:	73 05                	jae    802989 <__udivdi3+0xf9>
  802984:	3b 34 24             	cmp    (%esp),%esi
  802987:	74 1f                	je     8029a8 <__udivdi3+0x118>
  802989:	89 f8                	mov    %edi,%eax
  80298b:	31 d2                	xor    %edx,%edx
  80298d:	e9 7a ff ff ff       	jmp    80290c <__udivdi3+0x7c>
  802992:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802998:	31 d2                	xor    %edx,%edx
  80299a:	b8 01 00 00 00       	mov    $0x1,%eax
  80299f:	e9 68 ff ff ff       	jmp    80290c <__udivdi3+0x7c>
  8029a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8029a8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8029ab:	31 d2                	xor    %edx,%edx
  8029ad:	83 c4 0c             	add    $0xc,%esp
  8029b0:	5e                   	pop    %esi
  8029b1:	5f                   	pop    %edi
  8029b2:	5d                   	pop    %ebp
  8029b3:	c3                   	ret    
  8029b4:	66 90                	xchg   %ax,%ax
  8029b6:	66 90                	xchg   %ax,%ax
  8029b8:	66 90                	xchg   %ax,%ax
  8029ba:	66 90                	xchg   %ax,%ax
  8029bc:	66 90                	xchg   %ax,%ax
  8029be:	66 90                	xchg   %ax,%ax

008029c0 <__umoddi3>:
  8029c0:	55                   	push   %ebp
  8029c1:	57                   	push   %edi
  8029c2:	56                   	push   %esi
  8029c3:	83 ec 14             	sub    $0x14,%esp
  8029c6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8029ca:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8029ce:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8029d2:	89 c7                	mov    %eax,%edi
  8029d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029d8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8029dc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8029e0:	89 34 24             	mov    %esi,(%esp)
  8029e3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8029e7:	85 c0                	test   %eax,%eax
  8029e9:	89 c2                	mov    %eax,%edx
  8029eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8029ef:	75 17                	jne    802a08 <__umoddi3+0x48>
  8029f1:	39 fe                	cmp    %edi,%esi
  8029f3:	76 4b                	jbe    802a40 <__umoddi3+0x80>
  8029f5:	89 c8                	mov    %ecx,%eax
  8029f7:	89 fa                	mov    %edi,%edx
  8029f9:	f7 f6                	div    %esi
  8029fb:	89 d0                	mov    %edx,%eax
  8029fd:	31 d2                	xor    %edx,%edx
  8029ff:	83 c4 14             	add    $0x14,%esp
  802a02:	5e                   	pop    %esi
  802a03:	5f                   	pop    %edi
  802a04:	5d                   	pop    %ebp
  802a05:	c3                   	ret    
  802a06:	66 90                	xchg   %ax,%ax
  802a08:	39 f8                	cmp    %edi,%eax
  802a0a:	77 54                	ja     802a60 <__umoddi3+0xa0>
  802a0c:	0f bd e8             	bsr    %eax,%ebp
  802a0f:	83 f5 1f             	xor    $0x1f,%ebp
  802a12:	75 5c                	jne    802a70 <__umoddi3+0xb0>
  802a14:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802a18:	39 3c 24             	cmp    %edi,(%esp)
  802a1b:	0f 87 e7 00 00 00    	ja     802b08 <__umoddi3+0x148>
  802a21:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802a25:	29 f1                	sub    %esi,%ecx
  802a27:	19 c7                	sbb    %eax,%edi
  802a29:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a2d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802a31:	8b 44 24 08          	mov    0x8(%esp),%eax
  802a35:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802a39:	83 c4 14             	add    $0x14,%esp
  802a3c:	5e                   	pop    %esi
  802a3d:	5f                   	pop    %edi
  802a3e:	5d                   	pop    %ebp
  802a3f:	c3                   	ret    
  802a40:	85 f6                	test   %esi,%esi
  802a42:	89 f5                	mov    %esi,%ebp
  802a44:	75 0b                	jne    802a51 <__umoddi3+0x91>
  802a46:	b8 01 00 00 00       	mov    $0x1,%eax
  802a4b:	31 d2                	xor    %edx,%edx
  802a4d:	f7 f6                	div    %esi
  802a4f:	89 c5                	mov    %eax,%ebp
  802a51:	8b 44 24 04          	mov    0x4(%esp),%eax
  802a55:	31 d2                	xor    %edx,%edx
  802a57:	f7 f5                	div    %ebp
  802a59:	89 c8                	mov    %ecx,%eax
  802a5b:	f7 f5                	div    %ebp
  802a5d:	eb 9c                	jmp    8029fb <__umoddi3+0x3b>
  802a5f:	90                   	nop
  802a60:	89 c8                	mov    %ecx,%eax
  802a62:	89 fa                	mov    %edi,%edx
  802a64:	83 c4 14             	add    $0x14,%esp
  802a67:	5e                   	pop    %esi
  802a68:	5f                   	pop    %edi
  802a69:	5d                   	pop    %ebp
  802a6a:	c3                   	ret    
  802a6b:	90                   	nop
  802a6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a70:	8b 04 24             	mov    (%esp),%eax
  802a73:	be 20 00 00 00       	mov    $0x20,%esi
  802a78:	89 e9                	mov    %ebp,%ecx
  802a7a:	29 ee                	sub    %ebp,%esi
  802a7c:	d3 e2                	shl    %cl,%edx
  802a7e:	89 f1                	mov    %esi,%ecx
  802a80:	d3 e8                	shr    %cl,%eax
  802a82:	89 e9                	mov    %ebp,%ecx
  802a84:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a88:	8b 04 24             	mov    (%esp),%eax
  802a8b:	09 54 24 04          	or     %edx,0x4(%esp)
  802a8f:	89 fa                	mov    %edi,%edx
  802a91:	d3 e0                	shl    %cl,%eax
  802a93:	89 f1                	mov    %esi,%ecx
  802a95:	89 44 24 08          	mov    %eax,0x8(%esp)
  802a99:	8b 44 24 10          	mov    0x10(%esp),%eax
  802a9d:	d3 ea                	shr    %cl,%edx
  802a9f:	89 e9                	mov    %ebp,%ecx
  802aa1:	d3 e7                	shl    %cl,%edi
  802aa3:	89 f1                	mov    %esi,%ecx
  802aa5:	d3 e8                	shr    %cl,%eax
  802aa7:	89 e9                	mov    %ebp,%ecx
  802aa9:	09 f8                	or     %edi,%eax
  802aab:	8b 7c 24 10          	mov    0x10(%esp),%edi
  802aaf:	f7 74 24 04          	divl   0x4(%esp)
  802ab3:	d3 e7                	shl    %cl,%edi
  802ab5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802ab9:	89 d7                	mov    %edx,%edi
  802abb:	f7 64 24 08          	mull   0x8(%esp)
  802abf:	39 d7                	cmp    %edx,%edi
  802ac1:	89 c1                	mov    %eax,%ecx
  802ac3:	89 14 24             	mov    %edx,(%esp)
  802ac6:	72 2c                	jb     802af4 <__umoddi3+0x134>
  802ac8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  802acc:	72 22                	jb     802af0 <__umoddi3+0x130>
  802ace:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802ad2:	29 c8                	sub    %ecx,%eax
  802ad4:	19 d7                	sbb    %edx,%edi
  802ad6:	89 e9                	mov    %ebp,%ecx
  802ad8:	89 fa                	mov    %edi,%edx
  802ada:	d3 e8                	shr    %cl,%eax
  802adc:	89 f1                	mov    %esi,%ecx
  802ade:	d3 e2                	shl    %cl,%edx
  802ae0:	89 e9                	mov    %ebp,%ecx
  802ae2:	d3 ef                	shr    %cl,%edi
  802ae4:	09 d0                	or     %edx,%eax
  802ae6:	89 fa                	mov    %edi,%edx
  802ae8:	83 c4 14             	add    $0x14,%esp
  802aeb:	5e                   	pop    %esi
  802aec:	5f                   	pop    %edi
  802aed:	5d                   	pop    %ebp
  802aee:	c3                   	ret    
  802aef:	90                   	nop
  802af0:	39 d7                	cmp    %edx,%edi
  802af2:	75 da                	jne    802ace <__umoddi3+0x10e>
  802af4:	8b 14 24             	mov    (%esp),%edx
  802af7:	89 c1                	mov    %eax,%ecx
  802af9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  802afd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802b01:	eb cb                	jmp    802ace <__umoddi3+0x10e>
  802b03:	90                   	nop
  802b04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b08:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  802b0c:	0f 82 0f ff ff ff    	jb     802a21 <__umoddi3+0x61>
  802b12:	e9 1a ff ff ff       	jmp    802a31 <__umoddi3+0x71>
