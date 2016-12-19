
obj/user/testpipe.debug:     file format elf32-i386


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
  80002c:	e8 e4 02 00 00       	call   800315 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 c4 80             	add    $0xffffff80,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003b:	c7 05 04 40 80 00 80 	movl   $0x802c80,0x804004
  800042:	2c 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 04 24 00 00       	call   802454 <pipe>
  800050:	89 c6                	mov    %eax,%esi
  800052:	85 c0                	test   %eax,%eax
  800054:	79 20                	jns    800076 <umain+0x43>
		panic("pipe: %e", i);
  800056:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005a:	c7 44 24 08 8c 2c 80 	movl   $0x802c8c,0x8(%esp)
  800061:	00 
  800062:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  800069:	00 
  80006a:	c7 04 24 95 2c 80 00 	movl   $0x802c95,(%esp)
  800071:	e8 00 03 00 00       	call   800376 <_panic>

	if ((pid = fork()) < 0)
  800076:	e8 69 12 00 00       	call   8012e4 <fork>
  80007b:	89 c3                	mov    %eax,%ebx
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 20                	jns    8000a1 <umain+0x6e>
		panic("fork: %e", i);
  800081:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800085:	c7 44 24 08 a5 2c 80 	movl   $0x802ca5,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 95 2c 80 00 	movl   $0x802c95,(%esp)
  80009c:	e8 d5 02 00 00       	call   800376 <_panic>

	if (pid == 0) {
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	0f 85 d5 00 00 00    	jne    80017e <umain+0x14b>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  8000a9:	a1 08 50 80 00       	mov    0x805008,%eax
  8000ae:	8b 40 48             	mov    0x48(%eax),%eax
  8000b1:	8b 55 90             	mov    -0x70(%ebp),%edx
  8000b4:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000bc:	c7 04 24 ae 2c 80 00 	movl   $0x802cae,(%esp)
  8000c3:	e8 a7 03 00 00       	call   80046f <cprintf>
		close(p[1]);
  8000c8:	8b 45 90             	mov    -0x70(%ebp),%eax
  8000cb:	89 04 24             	mov    %eax,(%esp)
  8000ce:	e8 c4 15 00 00       	call   801697 <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000d3:	a1 08 50 80 00       	mov    0x805008,%eax
  8000d8:	8b 40 48             	mov    0x48(%eax),%eax
  8000db:	8b 55 8c             	mov    -0x74(%ebp),%edx
  8000de:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000e6:	c7 04 24 cb 2c 80 00 	movl   $0x802ccb,(%esp)
  8000ed:	e8 7d 03 00 00       	call   80046f <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000f2:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  8000f9:	00 
  8000fa:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800101:	8b 45 8c             	mov    -0x74(%ebp),%eax
  800104:	89 04 24             	mov    %eax,(%esp)
  800107:	e8 80 17 00 00       	call   80188c <readn>
  80010c:	89 c6                	mov    %eax,%esi
		if (i < 0)
  80010e:	85 c0                	test   %eax,%eax
  800110:	79 20                	jns    800132 <umain+0xff>
			panic("read: %e", i);
  800112:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800116:	c7 44 24 08 e8 2c 80 	movl   $0x802ce8,0x8(%esp)
  80011d:	00 
  80011e:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  800125:	00 
  800126:	c7 04 24 95 2c 80 00 	movl   $0x802c95,(%esp)
  80012d:	e8 44 02 00 00       	call   800376 <_panic>
		buf[i] = 0;
  800132:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  800137:	a1 00 40 80 00       	mov    0x804000,%eax
  80013c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800140:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800143:	89 04 24             	mov    %eax,(%esp)
  800146:	e8 01 0a 00 00       	call   800b4c <strcmp>
  80014b:	85 c0                	test   %eax,%eax
  80014d:	75 0e                	jne    80015d <umain+0x12a>
			cprintf("\npipe read closed properly\n");
  80014f:	c7 04 24 f1 2c 80 00 	movl   $0x802cf1,(%esp)
  800156:	e8 14 03 00 00       	call   80046f <cprintf>
  80015b:	eb 17                	jmp    800174 <umain+0x141>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  80015d:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800160:	89 44 24 08          	mov    %eax,0x8(%esp)
  800164:	89 74 24 04          	mov    %esi,0x4(%esp)
  800168:	c7 04 24 0d 2d 80 00 	movl   $0x802d0d,(%esp)
  80016f:	e8 fb 02 00 00       	call   80046f <cprintf>
		exit();
  800174:	e8 e4 01 00 00       	call   80035d <exit>
  800179:	e9 ac 00 00 00       	jmp    80022a <umain+0x1f7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  80017e:	a1 08 50 80 00       	mov    0x805008,%eax
  800183:	8b 40 48             	mov    0x48(%eax),%eax
  800186:	8b 55 8c             	mov    -0x74(%ebp),%edx
  800189:	89 54 24 08          	mov    %edx,0x8(%esp)
  80018d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800191:	c7 04 24 ae 2c 80 00 	movl   $0x802cae,(%esp)
  800198:	e8 d2 02 00 00       	call   80046f <cprintf>
		close(p[0]);
  80019d:	8b 45 8c             	mov    -0x74(%ebp),%eax
  8001a0:	89 04 24             	mov    %eax,(%esp)
  8001a3:	e8 ef 14 00 00       	call   801697 <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  8001a8:	a1 08 50 80 00       	mov    0x805008,%eax
  8001ad:	8b 40 48             	mov    0x48(%eax),%eax
  8001b0:	8b 55 90             	mov    -0x70(%ebp),%edx
  8001b3:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bb:	c7 04 24 20 2d 80 00 	movl   $0x802d20,(%esp)
  8001c2:	e8 a8 02 00 00       	call   80046f <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  8001c7:	a1 00 40 80 00       	mov    0x804000,%eax
  8001cc:	89 04 24             	mov    %eax,(%esp)
  8001cf:	e8 8c 08 00 00       	call   800a60 <strlen>
  8001d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d8:	a1 00 40 80 00       	mov    0x804000,%eax
  8001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e1:	8b 45 90             	mov    -0x70(%ebp),%eax
  8001e4:	89 04 24             	mov    %eax,(%esp)
  8001e7:	e8 eb 16 00 00       	call   8018d7 <write>
  8001ec:	89 c6                	mov    %eax,%esi
  8001ee:	a1 00 40 80 00       	mov    0x804000,%eax
  8001f3:	89 04 24             	mov    %eax,(%esp)
  8001f6:	e8 65 08 00 00       	call   800a60 <strlen>
  8001fb:	39 c6                	cmp    %eax,%esi
  8001fd:	74 20                	je     80021f <umain+0x1ec>
			panic("write: %e", i);
  8001ff:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800203:	c7 44 24 08 3d 2d 80 	movl   $0x802d3d,0x8(%esp)
  80020a:	00 
  80020b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800212:	00 
  800213:	c7 04 24 95 2c 80 00 	movl   $0x802c95,(%esp)
  80021a:	e8 57 01 00 00       	call   800376 <_panic>
		close(p[1]);
  80021f:	8b 45 90             	mov    -0x70(%ebp),%eax
  800222:	89 04 24             	mov    %eax,(%esp)
  800225:	e8 6d 14 00 00       	call   801697 <close>
	}
	wait(pid);
  80022a:	89 1c 24             	mov    %ebx,(%esp)
  80022d:	e8 c8 23 00 00       	call   8025fa <wait>

	binaryname = "pipewriteeof";
  800232:	c7 05 04 40 80 00 47 	movl   $0x802d47,0x804004
  800239:	2d 80 00 
	if ((i = pipe(p)) < 0)
  80023c:	8d 45 8c             	lea    -0x74(%ebp),%eax
  80023f:	89 04 24             	mov    %eax,(%esp)
  800242:	e8 0d 22 00 00       	call   802454 <pipe>
  800247:	89 c6                	mov    %eax,%esi
  800249:	85 c0                	test   %eax,%eax
  80024b:	79 20                	jns    80026d <umain+0x23a>
		panic("pipe: %e", i);
  80024d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800251:	c7 44 24 08 8c 2c 80 	movl   $0x802c8c,0x8(%esp)
  800258:	00 
  800259:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800260:	00 
  800261:	c7 04 24 95 2c 80 00 	movl   $0x802c95,(%esp)
  800268:	e8 09 01 00 00       	call   800376 <_panic>

	if ((pid = fork()) < 0)
  80026d:	e8 72 10 00 00       	call   8012e4 <fork>
  800272:	89 c3                	mov    %eax,%ebx
  800274:	85 c0                	test   %eax,%eax
  800276:	79 20                	jns    800298 <umain+0x265>
		panic("fork: %e", i);
  800278:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80027c:	c7 44 24 08 a5 2c 80 	movl   $0x802ca5,0x8(%esp)
  800283:	00 
  800284:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  80028b:	00 
  80028c:	c7 04 24 95 2c 80 00 	movl   $0x802c95,(%esp)
  800293:	e8 de 00 00 00       	call   800376 <_panic>

	if (pid == 0) {
  800298:	85 c0                	test   %eax,%eax
  80029a:	75 48                	jne    8002e4 <umain+0x2b1>
		close(p[0]);
  80029c:	8b 45 8c             	mov    -0x74(%ebp),%eax
  80029f:	89 04 24             	mov    %eax,(%esp)
  8002a2:	e8 f0 13 00 00       	call   801697 <close>
		while (1) {
			cprintf(".");
  8002a7:	c7 04 24 54 2d 80 00 	movl   $0x802d54,(%esp)
  8002ae:	e8 bc 01 00 00       	call   80046f <cprintf>
			if (write(p[1], "x", 1) != 1)
  8002b3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002ba:	00 
  8002bb:	c7 44 24 04 56 2d 80 	movl   $0x802d56,0x4(%esp)
  8002c2:	00 
  8002c3:	8b 55 90             	mov    -0x70(%ebp),%edx
  8002c6:	89 14 24             	mov    %edx,(%esp)
  8002c9:	e8 09 16 00 00       	call   8018d7 <write>
  8002ce:	83 f8 01             	cmp    $0x1,%eax
  8002d1:	74 d4                	je     8002a7 <umain+0x274>
				break;
		}
		cprintf("\npipe write closed properly\n");
  8002d3:	c7 04 24 58 2d 80 00 	movl   $0x802d58,(%esp)
  8002da:	e8 90 01 00 00       	call   80046f <cprintf>
		exit();
  8002df:	e8 79 00 00 00       	call   80035d <exit>
	}
	close(p[0]);
  8002e4:	8b 45 8c             	mov    -0x74(%ebp),%eax
  8002e7:	89 04 24             	mov    %eax,(%esp)
  8002ea:	e8 a8 13 00 00       	call   801697 <close>
	close(p[1]);
  8002ef:	8b 45 90             	mov    -0x70(%ebp),%eax
  8002f2:	89 04 24             	mov    %eax,(%esp)
  8002f5:	e8 9d 13 00 00       	call   801697 <close>
	wait(pid);
  8002fa:	89 1c 24             	mov    %ebx,(%esp)
  8002fd:	e8 f8 22 00 00       	call   8025fa <wait>

	cprintf("pipe tests passed\n");
  800302:	c7 04 24 75 2d 80 00 	movl   $0x802d75,(%esp)
  800309:	e8 61 01 00 00       	call   80046f <cprintf>
}
  80030e:	83 ec 80             	sub    $0xffffff80,%esp
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5d                   	pop    %ebp
  800314:	c3                   	ret    

00800315 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	56                   	push   %esi
  800319:	53                   	push   %ebx
  80031a:	83 ec 10             	sub    $0x10,%esp
  80031d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800320:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  800323:	e8 4d 0b 00 00       	call   800e75 <sys_getenvid>
  800328:	25 ff 03 00 00       	and    $0x3ff,%eax
  80032d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800330:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800335:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80033a:	85 db                	test   %ebx,%ebx
  80033c:	7e 07                	jle    800345 <libmain+0x30>
		binaryname = argv[0];
  80033e:	8b 06                	mov    (%esi),%eax
  800340:	a3 04 40 80 00       	mov    %eax,0x804004

	// call user main routine
	umain(argc, argv);
  800345:	89 74 24 04          	mov    %esi,0x4(%esp)
  800349:	89 1c 24             	mov    %ebx,(%esp)
  80034c:	e8 e2 fc ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800351:	e8 07 00 00 00       	call   80035d <exit>
}
  800356:	83 c4 10             	add    $0x10,%esp
  800359:	5b                   	pop    %ebx
  80035a:	5e                   	pop    %esi
  80035b:	5d                   	pop    %ebp
  80035c:	c3                   	ret    

0080035d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800363:	e8 62 13 00 00       	call   8016ca <close_all>
	sys_env_destroy(0);
  800368:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80036f:	e8 af 0a 00 00       	call   800e23 <sys_env_destroy>
}
  800374:	c9                   	leave  
  800375:	c3                   	ret    

00800376 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	56                   	push   %esi
  80037a:	53                   	push   %ebx
  80037b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80037e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800381:	8b 35 04 40 80 00    	mov    0x804004,%esi
  800387:	e8 e9 0a 00 00       	call   800e75 <sys_getenvid>
  80038c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80038f:	89 54 24 10          	mov    %edx,0x10(%esp)
  800393:	8b 55 08             	mov    0x8(%ebp),%edx
  800396:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80039a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80039e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a2:	c7 04 24 d8 2d 80 00 	movl   $0x802dd8,(%esp)
  8003a9:	e8 c1 00 00 00       	call   80046f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b5:	89 04 24             	mov    %eax,(%esp)
  8003b8:	e8 51 00 00 00       	call   80040e <vcprintf>
	cprintf("\n");
  8003bd:	c7 04 24 c9 2c 80 00 	movl   $0x802cc9,(%esp)
  8003c4:	e8 a6 00 00 00       	call   80046f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003c9:	cc                   	int3   
  8003ca:	eb fd                	jmp    8003c9 <_panic+0x53>

008003cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003cc:	55                   	push   %ebp
  8003cd:	89 e5                	mov    %esp,%ebp
  8003cf:	53                   	push   %ebx
  8003d0:	83 ec 14             	sub    $0x14,%esp
  8003d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003d6:	8b 13                	mov    (%ebx),%edx
  8003d8:	8d 42 01             	lea    0x1(%edx),%eax
  8003db:	89 03                	mov    %eax,(%ebx)
  8003dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003e4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003e9:	75 19                	jne    800404 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8003eb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003f2:	00 
  8003f3:	8d 43 08             	lea    0x8(%ebx),%eax
  8003f6:	89 04 24             	mov    %eax,(%esp)
  8003f9:	e8 e8 09 00 00       	call   800de6 <sys_cputs>
		b->idx = 0;
  8003fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800404:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800408:	83 c4 14             	add    $0x14,%esp
  80040b:	5b                   	pop    %ebx
  80040c:	5d                   	pop    %ebp
  80040d:	c3                   	ret    

0080040e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80040e:	55                   	push   %ebp
  80040f:	89 e5                	mov    %esp,%ebp
  800411:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800417:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80041e:	00 00 00 
	b.cnt = 0;
  800421:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800428:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80042b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80042e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800432:	8b 45 08             	mov    0x8(%ebp),%eax
  800435:	89 44 24 08          	mov    %eax,0x8(%esp)
  800439:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80043f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800443:	c7 04 24 cc 03 80 00 	movl   $0x8003cc,(%esp)
  80044a:	e8 af 01 00 00       	call   8005fe <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80044f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800455:	89 44 24 04          	mov    %eax,0x4(%esp)
  800459:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80045f:	89 04 24             	mov    %eax,(%esp)
  800462:	e8 7f 09 00 00       	call   800de6 <sys_cputs>

	return b.cnt;
}
  800467:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80046d:	c9                   	leave  
  80046e:	c3                   	ret    

0080046f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80046f:	55                   	push   %ebp
  800470:	89 e5                	mov    %esp,%ebp
  800472:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800475:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800478:	89 44 24 04          	mov    %eax,0x4(%esp)
  80047c:	8b 45 08             	mov    0x8(%ebp),%eax
  80047f:	89 04 24             	mov    %eax,(%esp)
  800482:	e8 87 ff ff ff       	call   80040e <vcprintf>
	va_end(ap);

	return cnt;
}
  800487:	c9                   	leave  
  800488:	c3                   	ret    
  800489:	66 90                	xchg   %ax,%ax
  80048b:	66 90                	xchg   %ax,%ax
  80048d:	66 90                	xchg   %ax,%ax
  80048f:	90                   	nop

00800490 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	57                   	push   %edi
  800494:	56                   	push   %esi
  800495:	53                   	push   %ebx
  800496:	83 ec 3c             	sub    $0x3c,%esp
  800499:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80049c:	89 d7                	mov    %edx,%edi
  80049e:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a7:	89 c3                	mov    %eax,%ebx
  8004a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8004af:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004bd:	39 d9                	cmp    %ebx,%ecx
  8004bf:	72 05                	jb     8004c6 <printnum+0x36>
  8004c1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8004c4:	77 69                	ja     80052f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004c6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8004c9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8004cd:	83 ee 01             	sub    $0x1,%esi
  8004d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004d8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8004dc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8004e0:	89 c3                	mov    %eax,%ebx
  8004e2:	89 d6                	mov    %edx,%esi
  8004e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004ea:	89 54 24 08          	mov    %edx,0x8(%esp)
  8004ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8004f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f5:	89 04 24             	mov    %eax,(%esp)
  8004f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ff:	e8 dc 24 00 00       	call   8029e0 <__udivdi3>
  800504:	89 d9                	mov    %ebx,%ecx
  800506:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80050a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80050e:	89 04 24             	mov    %eax,(%esp)
  800511:	89 54 24 04          	mov    %edx,0x4(%esp)
  800515:	89 fa                	mov    %edi,%edx
  800517:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80051a:	e8 71 ff ff ff       	call   800490 <printnum>
  80051f:	eb 1b                	jmp    80053c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800521:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800525:	8b 45 18             	mov    0x18(%ebp),%eax
  800528:	89 04 24             	mov    %eax,(%esp)
  80052b:	ff d3                	call   *%ebx
  80052d:	eb 03                	jmp    800532 <printnum+0xa2>
  80052f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800532:	83 ee 01             	sub    $0x1,%esi
  800535:	85 f6                	test   %esi,%esi
  800537:	7f e8                	jg     800521 <printnum+0x91>
  800539:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80053c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800540:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800544:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800547:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80054a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80054e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800552:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800555:	89 04 24             	mov    %eax,(%esp)
  800558:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80055b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055f:	e8 ac 25 00 00       	call   802b10 <__umoddi3>
  800564:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800568:	0f be 80 fb 2d 80 00 	movsbl 0x802dfb(%eax),%eax
  80056f:	89 04 24             	mov    %eax,(%esp)
  800572:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800575:	ff d0                	call   *%eax
}
  800577:	83 c4 3c             	add    $0x3c,%esp
  80057a:	5b                   	pop    %ebx
  80057b:	5e                   	pop    %esi
  80057c:	5f                   	pop    %edi
  80057d:	5d                   	pop    %ebp
  80057e:	c3                   	ret    

0080057f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80057f:	55                   	push   %ebp
  800580:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800582:	83 fa 01             	cmp    $0x1,%edx
  800585:	7e 0e                	jle    800595 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800587:	8b 10                	mov    (%eax),%edx
  800589:	8d 4a 08             	lea    0x8(%edx),%ecx
  80058c:	89 08                	mov    %ecx,(%eax)
  80058e:	8b 02                	mov    (%edx),%eax
  800590:	8b 52 04             	mov    0x4(%edx),%edx
  800593:	eb 22                	jmp    8005b7 <getuint+0x38>
	else if (lflag)
  800595:	85 d2                	test   %edx,%edx
  800597:	74 10                	je     8005a9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800599:	8b 10                	mov    (%eax),%edx
  80059b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80059e:	89 08                	mov    %ecx,(%eax)
  8005a0:	8b 02                	mov    (%edx),%eax
  8005a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a7:	eb 0e                	jmp    8005b7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005a9:	8b 10                	mov    (%eax),%edx
  8005ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ae:	89 08                	mov    %ecx,(%eax)
  8005b0:	8b 02                	mov    (%edx),%eax
  8005b2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005b7:	5d                   	pop    %ebp
  8005b8:	c3                   	ret    

008005b9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005b9:	55                   	push   %ebp
  8005ba:	89 e5                	mov    %esp,%ebp
  8005bc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005bf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005c3:	8b 10                	mov    (%eax),%edx
  8005c5:	3b 50 04             	cmp    0x4(%eax),%edx
  8005c8:	73 0a                	jae    8005d4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8005ca:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005cd:	89 08                	mov    %ecx,(%eax)
  8005cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d2:	88 02                	mov    %al,(%edx)
}
  8005d4:	5d                   	pop    %ebp
  8005d5:	c3                   	ret    

008005d6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005d6:	55                   	push   %ebp
  8005d7:	89 e5                	mov    %esp,%ebp
  8005d9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005dc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8005e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f4:	89 04 24             	mov    %eax,(%esp)
  8005f7:	e8 02 00 00 00       	call   8005fe <vprintfmt>
	va_end(ap);
}
  8005fc:	c9                   	leave  
  8005fd:	c3                   	ret    

008005fe <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005fe:	55                   	push   %ebp
  8005ff:	89 e5                	mov    %esp,%ebp
  800601:	57                   	push   %edi
  800602:	56                   	push   %esi
  800603:	53                   	push   %ebx
  800604:	83 ec 3c             	sub    $0x3c,%esp
  800607:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80060a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80060d:	eb 14                	jmp    800623 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80060f:	85 c0                	test   %eax,%eax
  800611:	0f 84 b3 03 00 00    	je     8009ca <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800617:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061b:	89 04 24             	mov    %eax,(%esp)
  80061e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800621:	89 f3                	mov    %esi,%ebx
  800623:	8d 73 01             	lea    0x1(%ebx),%esi
  800626:	0f b6 03             	movzbl (%ebx),%eax
  800629:	83 f8 25             	cmp    $0x25,%eax
  80062c:	75 e1                	jne    80060f <vprintfmt+0x11>
  80062e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800632:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800639:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800640:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800647:	ba 00 00 00 00       	mov    $0x0,%edx
  80064c:	eb 1d                	jmp    80066b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800650:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800654:	eb 15                	jmp    80066b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800656:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800658:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80065c:	eb 0d                	jmp    80066b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80065e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800661:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800664:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80066e:	0f b6 0e             	movzbl (%esi),%ecx
  800671:	0f b6 c1             	movzbl %cl,%eax
  800674:	83 e9 23             	sub    $0x23,%ecx
  800677:	80 f9 55             	cmp    $0x55,%cl
  80067a:	0f 87 2a 03 00 00    	ja     8009aa <vprintfmt+0x3ac>
  800680:	0f b6 c9             	movzbl %cl,%ecx
  800683:	ff 24 8d 40 2f 80 00 	jmp    *0x802f40(,%ecx,4)
  80068a:	89 de                	mov    %ebx,%esi
  80068c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800691:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800694:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800698:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80069b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80069e:	83 fb 09             	cmp    $0x9,%ebx
  8006a1:	77 36                	ja     8006d9 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006a3:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006a6:	eb e9                	jmp    800691 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8d 48 04             	lea    0x4(%eax),%ecx
  8006ae:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006b1:	8b 00                	mov    (%eax),%eax
  8006b3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b6:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006b8:	eb 22                	jmp    8006dc <vprintfmt+0xde>
  8006ba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006bd:	85 c9                	test   %ecx,%ecx
  8006bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c4:	0f 49 c1             	cmovns %ecx,%eax
  8006c7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ca:	89 de                	mov    %ebx,%esi
  8006cc:	eb 9d                	jmp    80066b <vprintfmt+0x6d>
  8006ce:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006d0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8006d7:	eb 92                	jmp    80066b <vprintfmt+0x6d>
  8006d9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8006dc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006e0:	79 89                	jns    80066b <vprintfmt+0x6d>
  8006e2:	e9 77 ff ff ff       	jmp    80065e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006e7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ea:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006ec:	e9 7a ff ff ff       	jmp    80066b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f4:	8d 50 04             	lea    0x4(%eax),%edx
  8006f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006fe:	8b 00                	mov    (%eax),%eax
  800700:	89 04 24             	mov    %eax,(%esp)
  800703:	ff 55 08             	call   *0x8(%ebp)
			break;
  800706:	e9 18 ff ff ff       	jmp    800623 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80070b:	8b 45 14             	mov    0x14(%ebp),%eax
  80070e:	8d 50 04             	lea    0x4(%eax),%edx
  800711:	89 55 14             	mov    %edx,0x14(%ebp)
  800714:	8b 00                	mov    (%eax),%eax
  800716:	99                   	cltd   
  800717:	31 d0                	xor    %edx,%eax
  800719:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80071b:	83 f8 0f             	cmp    $0xf,%eax
  80071e:	7f 0b                	jg     80072b <vprintfmt+0x12d>
  800720:	8b 14 85 a0 30 80 00 	mov    0x8030a0(,%eax,4),%edx
  800727:	85 d2                	test   %edx,%edx
  800729:	75 20                	jne    80074b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80072b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80072f:	c7 44 24 08 13 2e 80 	movl   $0x802e13,0x8(%esp)
  800736:	00 
  800737:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80073b:	8b 45 08             	mov    0x8(%ebp),%eax
  80073e:	89 04 24             	mov    %eax,(%esp)
  800741:	e8 90 fe ff ff       	call   8005d6 <printfmt>
  800746:	e9 d8 fe ff ff       	jmp    800623 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80074b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80074f:	c7 44 24 08 4d 32 80 	movl   $0x80324d,0x8(%esp)
  800756:	00 
  800757:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80075b:	8b 45 08             	mov    0x8(%ebp),%eax
  80075e:	89 04 24             	mov    %eax,(%esp)
  800761:	e8 70 fe ff ff       	call   8005d6 <printfmt>
  800766:	e9 b8 fe ff ff       	jmp    800623 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80076e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800771:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800774:	8b 45 14             	mov    0x14(%ebp),%eax
  800777:	8d 50 04             	lea    0x4(%eax),%edx
  80077a:	89 55 14             	mov    %edx,0x14(%ebp)
  80077d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80077f:	85 f6                	test   %esi,%esi
  800781:	b8 0c 2e 80 00       	mov    $0x802e0c,%eax
  800786:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800789:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80078d:	0f 84 97 00 00 00    	je     80082a <vprintfmt+0x22c>
  800793:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800797:	0f 8e 9b 00 00 00    	jle    800838 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80079d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007a1:	89 34 24             	mov    %esi,(%esp)
  8007a4:	e8 cf 02 00 00       	call   800a78 <strnlen>
  8007a9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007ac:	29 c2                	sub    %eax,%edx
  8007ae:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8007b1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8007b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8007b8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8007bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007be:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8007c1:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007c3:	eb 0f                	jmp    8007d4 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8007c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007cc:	89 04 24             	mov    %eax,(%esp)
  8007cf:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007d1:	83 eb 01             	sub    $0x1,%ebx
  8007d4:	85 db                	test   %ebx,%ebx
  8007d6:	7f ed                	jg     8007c5 <vprintfmt+0x1c7>
  8007d8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8007db:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007de:	85 d2                	test   %edx,%edx
  8007e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e5:	0f 49 c2             	cmovns %edx,%eax
  8007e8:	29 c2                	sub    %eax,%edx
  8007ea:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8007ed:	89 d7                	mov    %edx,%edi
  8007ef:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8007f2:	eb 50                	jmp    800844 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007f4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007f8:	74 1e                	je     800818 <vprintfmt+0x21a>
  8007fa:	0f be d2             	movsbl %dl,%edx
  8007fd:	83 ea 20             	sub    $0x20,%edx
  800800:	83 fa 5e             	cmp    $0x5e,%edx
  800803:	76 13                	jbe    800818 <vprintfmt+0x21a>
					putch('?', putdat);
  800805:	8b 45 0c             	mov    0xc(%ebp),%eax
  800808:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800813:	ff 55 08             	call   *0x8(%ebp)
  800816:	eb 0d                	jmp    800825 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800818:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80081f:	89 04 24             	mov    %eax,(%esp)
  800822:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800825:	83 ef 01             	sub    $0x1,%edi
  800828:	eb 1a                	jmp    800844 <vprintfmt+0x246>
  80082a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80082d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800830:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800833:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800836:	eb 0c                	jmp    800844 <vprintfmt+0x246>
  800838:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80083b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80083e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800841:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800844:	83 c6 01             	add    $0x1,%esi
  800847:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80084b:	0f be c2             	movsbl %dl,%eax
  80084e:	85 c0                	test   %eax,%eax
  800850:	74 27                	je     800879 <vprintfmt+0x27b>
  800852:	85 db                	test   %ebx,%ebx
  800854:	78 9e                	js     8007f4 <vprintfmt+0x1f6>
  800856:	83 eb 01             	sub    $0x1,%ebx
  800859:	79 99                	jns    8007f4 <vprintfmt+0x1f6>
  80085b:	89 f8                	mov    %edi,%eax
  80085d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800860:	8b 75 08             	mov    0x8(%ebp),%esi
  800863:	89 c3                	mov    %eax,%ebx
  800865:	eb 1a                	jmp    800881 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800867:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80086b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800872:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800874:	83 eb 01             	sub    $0x1,%ebx
  800877:	eb 08                	jmp    800881 <vprintfmt+0x283>
  800879:	89 fb                	mov    %edi,%ebx
  80087b:	8b 75 08             	mov    0x8(%ebp),%esi
  80087e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800881:	85 db                	test   %ebx,%ebx
  800883:	7f e2                	jg     800867 <vprintfmt+0x269>
  800885:	89 75 08             	mov    %esi,0x8(%ebp)
  800888:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80088b:	e9 93 fd ff ff       	jmp    800623 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800890:	83 fa 01             	cmp    $0x1,%edx
  800893:	7e 16                	jle    8008ab <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800895:	8b 45 14             	mov    0x14(%ebp),%eax
  800898:	8d 50 08             	lea    0x8(%eax),%edx
  80089b:	89 55 14             	mov    %edx,0x14(%ebp)
  80089e:	8b 50 04             	mov    0x4(%eax),%edx
  8008a1:	8b 00                	mov    (%eax),%eax
  8008a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008a6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008a9:	eb 32                	jmp    8008dd <vprintfmt+0x2df>
	else if (lflag)
  8008ab:	85 d2                	test   %edx,%edx
  8008ad:	74 18                	je     8008c7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8008af:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b2:	8d 50 04             	lea    0x4(%eax),%edx
  8008b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b8:	8b 30                	mov    (%eax),%esi
  8008ba:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8008bd:	89 f0                	mov    %esi,%eax
  8008bf:	c1 f8 1f             	sar    $0x1f,%eax
  8008c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008c5:	eb 16                	jmp    8008dd <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8008c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ca:	8d 50 04             	lea    0x4(%eax),%edx
  8008cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d0:	8b 30                	mov    (%eax),%esi
  8008d2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8008d5:	89 f0                	mov    %esi,%eax
  8008d7:	c1 f8 1f             	sar    $0x1f,%eax
  8008da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008e3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008ec:	0f 89 80 00 00 00    	jns    800972 <vprintfmt+0x374>
				putch('-', putdat);
  8008f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008f6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008fd:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800900:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800903:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800906:	f7 d8                	neg    %eax
  800908:	83 d2 00             	adc    $0x0,%edx
  80090b:	f7 da                	neg    %edx
			}
			base = 10;
  80090d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800912:	eb 5e                	jmp    800972 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800914:	8d 45 14             	lea    0x14(%ebp),%eax
  800917:	e8 63 fc ff ff       	call   80057f <getuint>
			base = 10;
  80091c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800921:	eb 4f                	jmp    800972 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800923:	8d 45 14             	lea    0x14(%ebp),%eax
  800926:	e8 54 fc ff ff       	call   80057f <getuint>
			base = 8;
  80092b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800930:	eb 40                	jmp    800972 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800932:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800936:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80093d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800940:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800944:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80094b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80094e:	8b 45 14             	mov    0x14(%ebp),%eax
  800951:	8d 50 04             	lea    0x4(%eax),%edx
  800954:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800957:	8b 00                	mov    (%eax),%eax
  800959:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80095e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800963:	eb 0d                	jmp    800972 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800965:	8d 45 14             	lea    0x14(%ebp),%eax
  800968:	e8 12 fc ff ff       	call   80057f <getuint>
			base = 16;
  80096d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800972:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800976:	89 74 24 10          	mov    %esi,0x10(%esp)
  80097a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80097d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800981:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800985:	89 04 24             	mov    %eax,(%esp)
  800988:	89 54 24 04          	mov    %edx,0x4(%esp)
  80098c:	89 fa                	mov    %edi,%edx
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	e8 fa fa ff ff       	call   800490 <printnum>
			break;
  800996:	e9 88 fc ff ff       	jmp    800623 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80099b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80099f:	89 04 24             	mov    %eax,(%esp)
  8009a2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8009a5:	e9 79 fc ff ff       	jmp    800623 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009ae:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009b5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009b8:	89 f3                	mov    %esi,%ebx
  8009ba:	eb 03                	jmp    8009bf <vprintfmt+0x3c1>
  8009bc:	83 eb 01             	sub    $0x1,%ebx
  8009bf:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8009c3:	75 f7                	jne    8009bc <vprintfmt+0x3be>
  8009c5:	e9 59 fc ff ff       	jmp    800623 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8009ca:	83 c4 3c             	add    $0x3c,%esp
  8009cd:	5b                   	pop    %ebx
  8009ce:	5e                   	pop    %esi
  8009cf:	5f                   	pop    %edi
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	83 ec 28             	sub    $0x28,%esp
  8009d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009db:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009de:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009e1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009e5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009ef:	85 c0                	test   %eax,%eax
  8009f1:	74 30                	je     800a23 <vsnprintf+0x51>
  8009f3:	85 d2                	test   %edx,%edx
  8009f5:	7e 2c                	jle    800a23 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009fe:	8b 45 10             	mov    0x10(%ebp),%eax
  800a01:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a05:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a08:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0c:	c7 04 24 b9 05 80 00 	movl   $0x8005b9,(%esp)
  800a13:	e8 e6 fb ff ff       	call   8005fe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a18:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a1b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a21:	eb 05                	jmp    800a28 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a23:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a28:	c9                   	leave  
  800a29:	c3                   	ret    

00800a2a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a30:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a33:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a37:	8b 45 10             	mov    0x10(%ebp),%eax
  800a3a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a41:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a45:	8b 45 08             	mov    0x8(%ebp),%eax
  800a48:	89 04 24             	mov    %eax,(%esp)
  800a4b:	e8 82 ff ff ff       	call   8009d2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a50:	c9                   	leave  
  800a51:	c3                   	ret    
  800a52:	66 90                	xchg   %ax,%ax
  800a54:	66 90                	xchg   %ax,%ax
  800a56:	66 90                	xchg   %ax,%ax
  800a58:	66 90                	xchg   %ax,%ax
  800a5a:	66 90                	xchg   %ax,%ax
  800a5c:	66 90                	xchg   %ax,%ax
  800a5e:	66 90                	xchg   %ax,%ax

00800a60 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a66:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6b:	eb 03                	jmp    800a70 <strlen+0x10>
		n++;
  800a6d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a70:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a74:	75 f7                	jne    800a6d <strlen+0xd>
		n++;
	return n;
}
  800a76:	5d                   	pop    %ebp
  800a77:	c3                   	ret    

00800a78 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a7e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a81:	b8 00 00 00 00       	mov    $0x0,%eax
  800a86:	eb 03                	jmp    800a8b <strnlen+0x13>
		n++;
  800a88:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a8b:	39 d0                	cmp    %edx,%eax
  800a8d:	74 06                	je     800a95 <strnlen+0x1d>
  800a8f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a93:	75 f3                	jne    800a88 <strnlen+0x10>
		n++;
	return n;
}
  800a95:	5d                   	pop    %ebp
  800a96:	c3                   	ret    

00800a97 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	53                   	push   %ebx
  800a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800aa1:	89 c2                	mov    %eax,%edx
  800aa3:	83 c2 01             	add    $0x1,%edx
  800aa6:	83 c1 01             	add    $0x1,%ecx
  800aa9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800aad:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ab0:	84 db                	test   %bl,%bl
  800ab2:	75 ef                	jne    800aa3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ab4:	5b                   	pop    %ebx
  800ab5:	5d                   	pop    %ebp
  800ab6:	c3                   	ret    

00800ab7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	53                   	push   %ebx
  800abb:	83 ec 08             	sub    $0x8,%esp
  800abe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ac1:	89 1c 24             	mov    %ebx,(%esp)
  800ac4:	e8 97 ff ff ff       	call   800a60 <strlen>
	strcpy(dst + len, src);
  800ac9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800acc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ad0:	01 d8                	add    %ebx,%eax
  800ad2:	89 04 24             	mov    %eax,(%esp)
  800ad5:	e8 bd ff ff ff       	call   800a97 <strcpy>
	return dst;
}
  800ada:	89 d8                	mov    %ebx,%eax
  800adc:	83 c4 08             	add    $0x8,%esp
  800adf:	5b                   	pop    %ebx
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	56                   	push   %esi
  800ae6:	53                   	push   %ebx
  800ae7:	8b 75 08             	mov    0x8(%ebp),%esi
  800aea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aed:	89 f3                	mov    %esi,%ebx
  800aef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800af2:	89 f2                	mov    %esi,%edx
  800af4:	eb 0f                	jmp    800b05 <strncpy+0x23>
		*dst++ = *src;
  800af6:	83 c2 01             	add    $0x1,%edx
  800af9:	0f b6 01             	movzbl (%ecx),%eax
  800afc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aff:	80 39 01             	cmpb   $0x1,(%ecx)
  800b02:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b05:	39 da                	cmp    %ebx,%edx
  800b07:	75 ed                	jne    800af6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b09:	89 f0                	mov    %esi,%eax
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5d                   	pop    %ebp
  800b0e:	c3                   	ret    

00800b0f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	56                   	push   %esi
  800b13:	53                   	push   %ebx
  800b14:	8b 75 08             	mov    0x8(%ebp),%esi
  800b17:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b1a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b1d:	89 f0                	mov    %esi,%eax
  800b1f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b23:	85 c9                	test   %ecx,%ecx
  800b25:	75 0b                	jne    800b32 <strlcpy+0x23>
  800b27:	eb 1d                	jmp    800b46 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b29:	83 c0 01             	add    $0x1,%eax
  800b2c:	83 c2 01             	add    $0x1,%edx
  800b2f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b32:	39 d8                	cmp    %ebx,%eax
  800b34:	74 0b                	je     800b41 <strlcpy+0x32>
  800b36:	0f b6 0a             	movzbl (%edx),%ecx
  800b39:	84 c9                	test   %cl,%cl
  800b3b:	75 ec                	jne    800b29 <strlcpy+0x1a>
  800b3d:	89 c2                	mov    %eax,%edx
  800b3f:	eb 02                	jmp    800b43 <strlcpy+0x34>
  800b41:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b43:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b46:	29 f0                	sub    %esi,%eax
}
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b52:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b55:	eb 06                	jmp    800b5d <strcmp+0x11>
		p++, q++;
  800b57:	83 c1 01             	add    $0x1,%ecx
  800b5a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b5d:	0f b6 01             	movzbl (%ecx),%eax
  800b60:	84 c0                	test   %al,%al
  800b62:	74 04                	je     800b68 <strcmp+0x1c>
  800b64:	3a 02                	cmp    (%edx),%al
  800b66:	74 ef                	je     800b57 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b68:	0f b6 c0             	movzbl %al,%eax
  800b6b:	0f b6 12             	movzbl (%edx),%edx
  800b6e:	29 d0                	sub    %edx,%eax
}
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    

00800b72 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	53                   	push   %ebx
  800b76:	8b 45 08             	mov    0x8(%ebp),%eax
  800b79:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b7c:	89 c3                	mov    %eax,%ebx
  800b7e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b81:	eb 06                	jmp    800b89 <strncmp+0x17>
		n--, p++, q++;
  800b83:	83 c0 01             	add    $0x1,%eax
  800b86:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b89:	39 d8                	cmp    %ebx,%eax
  800b8b:	74 15                	je     800ba2 <strncmp+0x30>
  800b8d:	0f b6 08             	movzbl (%eax),%ecx
  800b90:	84 c9                	test   %cl,%cl
  800b92:	74 04                	je     800b98 <strncmp+0x26>
  800b94:	3a 0a                	cmp    (%edx),%cl
  800b96:	74 eb                	je     800b83 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b98:	0f b6 00             	movzbl (%eax),%eax
  800b9b:	0f b6 12             	movzbl (%edx),%edx
  800b9e:	29 d0                	sub    %edx,%eax
  800ba0:	eb 05                	jmp    800ba7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ba2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ba7:	5b                   	pop    %ebx
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bb4:	eb 07                	jmp    800bbd <strchr+0x13>
		if (*s == c)
  800bb6:	38 ca                	cmp    %cl,%dl
  800bb8:	74 0f                	je     800bc9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bba:	83 c0 01             	add    $0x1,%eax
  800bbd:	0f b6 10             	movzbl (%eax),%edx
  800bc0:	84 d2                	test   %dl,%dl
  800bc2:	75 f2                	jne    800bb6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800bc4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bd5:	eb 07                	jmp    800bde <strfind+0x13>
		if (*s == c)
  800bd7:	38 ca                	cmp    %cl,%dl
  800bd9:	74 0a                	je     800be5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bdb:	83 c0 01             	add    $0x1,%eax
  800bde:	0f b6 10             	movzbl (%eax),%edx
  800be1:	84 d2                	test   %dl,%dl
  800be3:	75 f2                	jne    800bd7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	57                   	push   %edi
  800beb:	56                   	push   %esi
  800bec:	53                   	push   %ebx
  800bed:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bf0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bf3:	85 c9                	test   %ecx,%ecx
  800bf5:	74 36                	je     800c2d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bf7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bfd:	75 28                	jne    800c27 <memset+0x40>
  800bff:	f6 c1 03             	test   $0x3,%cl
  800c02:	75 23                	jne    800c27 <memset+0x40>
		c &= 0xFF;
  800c04:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c08:	89 d3                	mov    %edx,%ebx
  800c0a:	c1 e3 08             	shl    $0x8,%ebx
  800c0d:	89 d6                	mov    %edx,%esi
  800c0f:	c1 e6 18             	shl    $0x18,%esi
  800c12:	89 d0                	mov    %edx,%eax
  800c14:	c1 e0 10             	shl    $0x10,%eax
  800c17:	09 f0                	or     %esi,%eax
  800c19:	09 c2                	or     %eax,%edx
  800c1b:	89 d0                	mov    %edx,%eax
  800c1d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c1f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c22:	fc                   	cld    
  800c23:	f3 ab                	rep stos %eax,%es:(%edi)
  800c25:	eb 06                	jmp    800c2d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2a:	fc                   	cld    
  800c2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c2d:	89 f8                	mov    %edi,%eax
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c42:	39 c6                	cmp    %eax,%esi
  800c44:	73 35                	jae    800c7b <memmove+0x47>
  800c46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c49:	39 d0                	cmp    %edx,%eax
  800c4b:	73 2e                	jae    800c7b <memmove+0x47>
		s += n;
		d += n;
  800c4d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800c50:	89 d6                	mov    %edx,%esi
  800c52:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c54:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c5a:	75 13                	jne    800c6f <memmove+0x3b>
  800c5c:	f6 c1 03             	test   $0x3,%cl
  800c5f:	75 0e                	jne    800c6f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c61:	83 ef 04             	sub    $0x4,%edi
  800c64:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c67:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c6a:	fd                   	std    
  800c6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c6d:	eb 09                	jmp    800c78 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c6f:	83 ef 01             	sub    $0x1,%edi
  800c72:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c75:	fd                   	std    
  800c76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c78:	fc                   	cld    
  800c79:	eb 1d                	jmp    800c98 <memmove+0x64>
  800c7b:	89 f2                	mov    %esi,%edx
  800c7d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c7f:	f6 c2 03             	test   $0x3,%dl
  800c82:	75 0f                	jne    800c93 <memmove+0x5f>
  800c84:	f6 c1 03             	test   $0x3,%cl
  800c87:	75 0a                	jne    800c93 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c89:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c8c:	89 c7                	mov    %eax,%edi
  800c8e:	fc                   	cld    
  800c8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c91:	eb 05                	jmp    800c98 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c93:	89 c7                	mov    %eax,%edi
  800c95:	fc                   	cld    
  800c96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ca2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ca9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb3:	89 04 24             	mov    %eax,(%esp)
  800cb6:	e8 79 ff ff ff       	call   800c34 <memmove>
}
  800cbb:	c9                   	leave  
  800cbc:	c3                   	ret    

00800cbd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc8:	89 d6                	mov    %edx,%esi
  800cca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ccd:	eb 1a                	jmp    800ce9 <memcmp+0x2c>
		if (*s1 != *s2)
  800ccf:	0f b6 02             	movzbl (%edx),%eax
  800cd2:	0f b6 19             	movzbl (%ecx),%ebx
  800cd5:	38 d8                	cmp    %bl,%al
  800cd7:	74 0a                	je     800ce3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800cd9:	0f b6 c0             	movzbl %al,%eax
  800cdc:	0f b6 db             	movzbl %bl,%ebx
  800cdf:	29 d8                	sub    %ebx,%eax
  800ce1:	eb 0f                	jmp    800cf2 <memcmp+0x35>
		s1++, s2++;
  800ce3:	83 c2 01             	add    $0x1,%edx
  800ce6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ce9:	39 f2                	cmp    %esi,%edx
  800ceb:	75 e2                	jne    800ccf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ced:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cf2:	5b                   	pop    %ebx
  800cf3:	5e                   	pop    %esi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cff:	89 c2                	mov    %eax,%edx
  800d01:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d04:	eb 07                	jmp    800d0d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d06:	38 08                	cmp    %cl,(%eax)
  800d08:	74 07                	je     800d11 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d0a:	83 c0 01             	add    $0x1,%eax
  800d0d:	39 d0                	cmp    %edx,%eax
  800d0f:	72 f5                	jb     800d06 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d1f:	eb 03                	jmp    800d24 <strtol+0x11>
		s++;
  800d21:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d24:	0f b6 0a             	movzbl (%edx),%ecx
  800d27:	80 f9 09             	cmp    $0x9,%cl
  800d2a:	74 f5                	je     800d21 <strtol+0xe>
  800d2c:	80 f9 20             	cmp    $0x20,%cl
  800d2f:	74 f0                	je     800d21 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d31:	80 f9 2b             	cmp    $0x2b,%cl
  800d34:	75 0a                	jne    800d40 <strtol+0x2d>
		s++;
  800d36:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d39:	bf 00 00 00 00       	mov    $0x0,%edi
  800d3e:	eb 11                	jmp    800d51 <strtol+0x3e>
  800d40:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d45:	80 f9 2d             	cmp    $0x2d,%cl
  800d48:	75 07                	jne    800d51 <strtol+0x3e>
		s++, neg = 1;
  800d4a:	8d 52 01             	lea    0x1(%edx),%edx
  800d4d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d51:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800d56:	75 15                	jne    800d6d <strtol+0x5a>
  800d58:	80 3a 30             	cmpb   $0x30,(%edx)
  800d5b:	75 10                	jne    800d6d <strtol+0x5a>
  800d5d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d61:	75 0a                	jne    800d6d <strtol+0x5a>
		s += 2, base = 16;
  800d63:	83 c2 02             	add    $0x2,%edx
  800d66:	b8 10 00 00 00       	mov    $0x10,%eax
  800d6b:	eb 10                	jmp    800d7d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	75 0c                	jne    800d7d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d71:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d73:	80 3a 30             	cmpb   $0x30,(%edx)
  800d76:	75 05                	jne    800d7d <strtol+0x6a>
		s++, base = 8;
  800d78:	83 c2 01             	add    $0x1,%edx
  800d7b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800d7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d82:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d85:	0f b6 0a             	movzbl (%edx),%ecx
  800d88:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800d8b:	89 f0                	mov    %esi,%eax
  800d8d:	3c 09                	cmp    $0x9,%al
  800d8f:	77 08                	ja     800d99 <strtol+0x86>
			dig = *s - '0';
  800d91:	0f be c9             	movsbl %cl,%ecx
  800d94:	83 e9 30             	sub    $0x30,%ecx
  800d97:	eb 20                	jmp    800db9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800d99:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800d9c:	89 f0                	mov    %esi,%eax
  800d9e:	3c 19                	cmp    $0x19,%al
  800da0:	77 08                	ja     800daa <strtol+0x97>
			dig = *s - 'a' + 10;
  800da2:	0f be c9             	movsbl %cl,%ecx
  800da5:	83 e9 57             	sub    $0x57,%ecx
  800da8:	eb 0f                	jmp    800db9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800daa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800dad:	89 f0                	mov    %esi,%eax
  800daf:	3c 19                	cmp    $0x19,%al
  800db1:	77 16                	ja     800dc9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800db3:	0f be c9             	movsbl %cl,%ecx
  800db6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800db9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800dbc:	7d 0f                	jge    800dcd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800dbe:	83 c2 01             	add    $0x1,%edx
  800dc1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800dc5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800dc7:	eb bc                	jmp    800d85 <strtol+0x72>
  800dc9:	89 d8                	mov    %ebx,%eax
  800dcb:	eb 02                	jmp    800dcf <strtol+0xbc>
  800dcd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800dcf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dd3:	74 05                	je     800dda <strtol+0xc7>
		*endptr = (char *) s;
  800dd5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dd8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800dda:	f7 d8                	neg    %eax
  800ddc:	85 ff                	test   %edi,%edi
  800dde:	0f 44 c3             	cmove  %ebx,%eax
}
  800de1:	5b                   	pop    %ebx
  800de2:	5e                   	pop    %esi
  800de3:	5f                   	pop    %edi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	57                   	push   %edi
  800dea:	56                   	push   %esi
  800deb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dec:	b8 00 00 00 00       	mov    $0x0,%eax
  800df1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df4:	8b 55 08             	mov    0x8(%ebp),%edx
  800df7:	89 c3                	mov    %eax,%ebx
  800df9:	89 c7                	mov    %eax,%edi
  800dfb:	89 c6                	mov    %eax,%esi
  800dfd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800dff:	5b                   	pop    %ebx
  800e00:	5e                   	pop    %esi
  800e01:	5f                   	pop    %edi
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	57                   	push   %edi
  800e08:	56                   	push   %esi
  800e09:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e0f:	b8 01 00 00 00       	mov    $0x1,%eax
  800e14:	89 d1                	mov    %edx,%ecx
  800e16:	89 d3                	mov    %edx,%ebx
  800e18:	89 d7                	mov    %edx,%edi
  800e1a:	89 d6                	mov    %edx,%esi
  800e1c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e1e:	5b                   	pop    %ebx
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800e2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e31:	b8 03 00 00 00       	mov    $0x3,%eax
  800e36:	8b 55 08             	mov    0x8(%ebp),%edx
  800e39:	89 cb                	mov    %ecx,%ebx
  800e3b:	89 cf                	mov    %ecx,%edi
  800e3d:	89 ce                	mov    %ecx,%esi
  800e3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e41:	85 c0                	test   %eax,%eax
  800e43:	7e 28                	jle    800e6d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e45:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e49:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e50:	00 
  800e51:	c7 44 24 08 ff 30 80 	movl   $0x8030ff,0x8(%esp)
  800e58:	00 
  800e59:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e60:	00 
  800e61:	c7 04 24 1c 31 80 00 	movl   $0x80311c,(%esp)
  800e68:	e8 09 f5 ff ff       	call   800376 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e6d:	83 c4 2c             	add    $0x2c,%esp
  800e70:	5b                   	pop    %ebx
  800e71:	5e                   	pop    %esi
  800e72:	5f                   	pop    %edi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    

00800e75 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	57                   	push   %edi
  800e79:	56                   	push   %esi
  800e7a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e80:	b8 02 00 00 00       	mov    $0x2,%eax
  800e85:	89 d1                	mov    %edx,%ecx
  800e87:	89 d3                	mov    %edx,%ebx
  800e89:	89 d7                	mov    %edx,%edi
  800e8b:	89 d6                	mov    %edx,%esi
  800e8d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e8f:	5b                   	pop    %ebx
  800e90:	5e                   	pop    %esi
  800e91:	5f                   	pop    %edi
  800e92:	5d                   	pop    %ebp
  800e93:	c3                   	ret    

00800e94 <sys_yield>:

void
sys_yield(void)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	57                   	push   %edi
  800e98:	56                   	push   %esi
  800e99:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e9f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ea4:	89 d1                	mov    %edx,%ecx
  800ea6:	89 d3                	mov    %edx,%ebx
  800ea8:	89 d7                	mov    %edx,%edi
  800eaa:	89 d6                	mov    %edx,%esi
  800eac:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800eae:	5b                   	pop    %ebx
  800eaf:	5e                   	pop    %esi
  800eb0:	5f                   	pop    %edi
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    

00800eb3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	57                   	push   %edi
  800eb7:	56                   	push   %esi
  800eb8:	53                   	push   %ebx
  800eb9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebc:	be 00 00 00 00       	mov    $0x0,%esi
  800ec1:	b8 04 00 00 00       	mov    $0x4,%eax
  800ec6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ecf:	89 f7                	mov    %esi,%edi
  800ed1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	7e 28                	jle    800eff <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800edb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ee2:	00 
  800ee3:	c7 44 24 08 ff 30 80 	movl   $0x8030ff,0x8(%esp)
  800eea:	00 
  800eeb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef2:	00 
  800ef3:	c7 04 24 1c 31 80 00 	movl   $0x80311c,(%esp)
  800efa:	e8 77 f4 ff ff       	call   800376 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800eff:	83 c4 2c             	add    $0x2c,%esp
  800f02:	5b                   	pop    %ebx
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	57                   	push   %edi
  800f0b:	56                   	push   %esi
  800f0c:	53                   	push   %ebx
  800f0d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f10:	b8 05 00 00 00       	mov    $0x5,%eax
  800f15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f18:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f1e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f21:	8b 75 18             	mov    0x18(%ebp),%esi
  800f24:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f26:	85 c0                	test   %eax,%eax
  800f28:	7e 28                	jle    800f52 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f2e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f35:	00 
  800f36:	c7 44 24 08 ff 30 80 	movl   $0x8030ff,0x8(%esp)
  800f3d:	00 
  800f3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f45:	00 
  800f46:	c7 04 24 1c 31 80 00 	movl   $0x80311c,(%esp)
  800f4d:	e8 24 f4 ff ff       	call   800376 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f52:	83 c4 2c             	add    $0x2c,%esp
  800f55:	5b                   	pop    %ebx
  800f56:	5e                   	pop    %esi
  800f57:	5f                   	pop    %edi
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    

00800f5a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f5a:	55                   	push   %ebp
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	57                   	push   %edi
  800f5e:	56                   	push   %esi
  800f5f:	53                   	push   %ebx
  800f60:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f68:	b8 06 00 00 00       	mov    $0x6,%eax
  800f6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f70:	8b 55 08             	mov    0x8(%ebp),%edx
  800f73:	89 df                	mov    %ebx,%edi
  800f75:	89 de                	mov    %ebx,%esi
  800f77:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f79:	85 c0                	test   %eax,%eax
  800f7b:	7e 28                	jle    800fa5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f81:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f88:	00 
  800f89:	c7 44 24 08 ff 30 80 	movl   $0x8030ff,0x8(%esp)
  800f90:	00 
  800f91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f98:	00 
  800f99:	c7 04 24 1c 31 80 00 	movl   $0x80311c,(%esp)
  800fa0:	e8 d1 f3 ff ff       	call   800376 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fa5:	83 c4 2c             	add    $0x2c,%esp
  800fa8:	5b                   	pop    %ebx
  800fa9:	5e                   	pop    %esi
  800faa:	5f                   	pop    %edi
  800fab:	5d                   	pop    %ebp
  800fac:	c3                   	ret    

00800fad <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	57                   	push   %edi
  800fb1:	56                   	push   %esi
  800fb2:	53                   	push   %ebx
  800fb3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fbb:	b8 08 00 00 00       	mov    $0x8,%eax
  800fc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc6:	89 df                	mov    %ebx,%edi
  800fc8:	89 de                	mov    %ebx,%esi
  800fca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fcc:	85 c0                	test   %eax,%eax
  800fce:	7e 28                	jle    800ff8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800fdb:	00 
  800fdc:	c7 44 24 08 ff 30 80 	movl   $0x8030ff,0x8(%esp)
  800fe3:	00 
  800fe4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800feb:	00 
  800fec:	c7 04 24 1c 31 80 00 	movl   $0x80311c,(%esp)
  800ff3:	e8 7e f3 ff ff       	call   800376 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ff8:	83 c4 2c             	add    $0x2c,%esp
  800ffb:	5b                   	pop    %ebx
  800ffc:	5e                   	pop    %esi
  800ffd:	5f                   	pop    %edi
  800ffe:	5d                   	pop    %ebp
  800fff:	c3                   	ret    

00801000 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	57                   	push   %edi
  801004:	56                   	push   %esi
  801005:	53                   	push   %ebx
  801006:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801009:	bb 00 00 00 00       	mov    $0x0,%ebx
  80100e:	b8 09 00 00 00       	mov    $0x9,%eax
  801013:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801016:	8b 55 08             	mov    0x8(%ebp),%edx
  801019:	89 df                	mov    %ebx,%edi
  80101b:	89 de                	mov    %ebx,%esi
  80101d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80101f:	85 c0                	test   %eax,%eax
  801021:	7e 28                	jle    80104b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801023:	89 44 24 10          	mov    %eax,0x10(%esp)
  801027:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80102e:	00 
  80102f:	c7 44 24 08 ff 30 80 	movl   $0x8030ff,0x8(%esp)
  801036:	00 
  801037:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80103e:	00 
  80103f:	c7 04 24 1c 31 80 00 	movl   $0x80311c,(%esp)
  801046:	e8 2b f3 ff ff       	call   800376 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80104b:	83 c4 2c             	add    $0x2c,%esp
  80104e:	5b                   	pop    %ebx
  80104f:	5e                   	pop    %esi
  801050:	5f                   	pop    %edi
  801051:	5d                   	pop    %ebp
  801052:	c3                   	ret    

00801053 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	57                   	push   %edi
  801057:	56                   	push   %esi
  801058:	53                   	push   %ebx
  801059:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801061:	b8 0a 00 00 00       	mov    $0xa,%eax
  801066:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801069:	8b 55 08             	mov    0x8(%ebp),%edx
  80106c:	89 df                	mov    %ebx,%edi
  80106e:	89 de                	mov    %ebx,%esi
  801070:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801072:	85 c0                	test   %eax,%eax
  801074:	7e 28                	jle    80109e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801076:	89 44 24 10          	mov    %eax,0x10(%esp)
  80107a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801081:	00 
  801082:	c7 44 24 08 ff 30 80 	movl   $0x8030ff,0x8(%esp)
  801089:	00 
  80108a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801091:	00 
  801092:	c7 04 24 1c 31 80 00 	movl   $0x80311c,(%esp)
  801099:	e8 d8 f2 ff ff       	call   800376 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80109e:	83 c4 2c             	add    $0x2c,%esp
  8010a1:	5b                   	pop    %ebx
  8010a2:	5e                   	pop    %esi
  8010a3:	5f                   	pop    %edi
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    

008010a6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	57                   	push   %edi
  8010aa:	56                   	push   %esi
  8010ab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ac:	be 00 00 00 00       	mov    $0x0,%esi
  8010b1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010bf:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010c2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010c4:	5b                   	pop    %ebx
  8010c5:	5e                   	pop    %esi
  8010c6:	5f                   	pop    %edi
  8010c7:	5d                   	pop    %ebp
  8010c8:	c3                   	ret    

008010c9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010c9:	55                   	push   %ebp
  8010ca:	89 e5                	mov    %esp,%ebp
  8010cc:	57                   	push   %edi
  8010cd:	56                   	push   %esi
  8010ce:	53                   	push   %ebx
  8010cf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010d7:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8010df:	89 cb                	mov    %ecx,%ebx
  8010e1:	89 cf                	mov    %ecx,%edi
  8010e3:	89 ce                	mov    %ecx,%esi
  8010e5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	7e 28                	jle    801113 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010eb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010ef:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8010f6:	00 
  8010f7:	c7 44 24 08 ff 30 80 	movl   $0x8030ff,0x8(%esp)
  8010fe:	00 
  8010ff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801106:	00 
  801107:	c7 04 24 1c 31 80 00 	movl   $0x80311c,(%esp)
  80110e:	e8 63 f2 ff ff       	call   800376 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801113:	83 c4 2c             	add    $0x2c,%esp
  801116:	5b                   	pop    %ebx
  801117:	5e                   	pop    %esi
  801118:	5f                   	pop    %edi
  801119:	5d                   	pop    %ebp
  80111a:	c3                   	ret    

0080111b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	57                   	push   %edi
  80111f:	56                   	push   %esi
  801120:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801121:	ba 00 00 00 00       	mov    $0x0,%edx
  801126:	b8 0e 00 00 00       	mov    $0xe,%eax
  80112b:	89 d1                	mov    %edx,%ecx
  80112d:	89 d3                	mov    %edx,%ebx
  80112f:	89 d7                	mov    %edx,%edi
  801131:	89 d6                	mov    %edx,%esi
  801133:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801135:	5b                   	pop    %ebx
  801136:	5e                   	pop    %esi
  801137:	5f                   	pop    %edi
  801138:	5d                   	pop    %ebp
  801139:	c3                   	ret    

0080113a <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  80113a:	55                   	push   %ebp
  80113b:	89 e5                	mov    %esp,%ebp
  80113d:	57                   	push   %edi
  80113e:	56                   	push   %esi
  80113f:	53                   	push   %ebx
  801140:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801143:	bb 00 00 00 00       	mov    $0x0,%ebx
  801148:	b8 0f 00 00 00       	mov    $0xf,%eax
  80114d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801150:	8b 55 08             	mov    0x8(%ebp),%edx
  801153:	89 df                	mov    %ebx,%edi
  801155:	89 de                	mov    %ebx,%esi
  801157:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801159:	85 c0                	test   %eax,%eax
  80115b:	7e 28                	jle    801185 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80115d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801161:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801168:	00 
  801169:	c7 44 24 08 ff 30 80 	movl   $0x8030ff,0x8(%esp)
  801170:	00 
  801171:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801178:	00 
  801179:	c7 04 24 1c 31 80 00 	movl   $0x80311c,(%esp)
  801180:	e8 f1 f1 ff ff       	call   800376 <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  801185:	83 c4 2c             	add    $0x2c,%esp
  801188:	5b                   	pop    %ebx
  801189:	5e                   	pop    %esi
  80118a:	5f                   	pop    %edi
  80118b:	5d                   	pop    %ebp
  80118c:	c3                   	ret    

0080118d <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  80118d:	55                   	push   %ebp
  80118e:	89 e5                	mov    %esp,%ebp
  801190:	57                   	push   %edi
  801191:	56                   	push   %esi
  801192:	53                   	push   %ebx
  801193:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801196:	bb 00 00 00 00       	mov    $0x0,%ebx
  80119b:	b8 10 00 00 00       	mov    $0x10,%eax
  8011a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a6:	89 df                	mov    %ebx,%edi
  8011a8:	89 de                	mov    %ebx,%esi
  8011aa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011ac:	85 c0                	test   %eax,%eax
  8011ae:	7e 28                	jle    8011d8 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011b0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011b4:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  8011bb:	00 
  8011bc:	c7 44 24 08 ff 30 80 	movl   $0x8030ff,0x8(%esp)
  8011c3:	00 
  8011c4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011cb:	00 
  8011cc:	c7 04 24 1c 31 80 00 	movl   $0x80311c,(%esp)
  8011d3:	e8 9e f1 ff ff       	call   800376 <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  8011d8:	83 c4 2c             	add    $0x2c,%esp
  8011db:	5b                   	pop    %ebx
  8011dc:	5e                   	pop    %esi
  8011dd:	5f                   	pop    %edi
  8011de:	5d                   	pop    %ebp
  8011df:	c3                   	ret    

008011e0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	56                   	push   %esi
  8011e4:	53                   	push   %ebx
  8011e5:	83 ec 20             	sub    $0x20,%esp
  8011e8:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8011eb:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if(!(err & FEC_WR)) {
  8011ed:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8011f1:	75 20                	jne    801213 <pgfault+0x33>
		panic("0x%x Not a write", addr);
  8011f3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011f7:	c7 44 24 08 2a 31 80 	movl   $0x80312a,0x8(%esp)
  8011fe:	00 
  8011ff:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801206:	00 
  801207:	c7 04 24 3b 31 80 00 	movl   $0x80313b,(%esp)
  80120e:	e8 63 f1 ff ff       	call   800376 <_panic>
	}

	if(!(uvpt[PGNUM(addr)] & PTE_COW)) {
  801213:	89 f0                	mov    %esi,%eax
  801215:	c1 e8 0c             	shr    $0xc,%eax
  801218:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80121f:	f6 c4 08             	test   $0x8,%ah
  801222:	75 1c                	jne    801240 <pgfault+0x60>
		panic("Not a COW page");
  801224:	c7 44 24 08 46 31 80 	movl   $0x803146,0x8(%esp)
  80122b:	00 
  80122c:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  801233:	00 
  801234:	c7 04 24 3b 31 80 00 	movl   $0x80313b,(%esp)
  80123b:	e8 36 f1 ff ff       	call   800376 <_panic>

	// Allocate a new page, map it at a temporary location (PFTEMP), // copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	envid_t envid = sys_getenvid();
  801240:	e8 30 fc ff ff       	call   800e75 <sys_getenvid>
  801245:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, PFTEMP, PTE_W | PTE_U | PTE_P);
  801247:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80124e:	00 
  80124f:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801256:	00 
  801257:	89 04 24             	mov    %eax,(%esp)
  80125a:	e8 54 fc ff ff       	call   800eb3 <sys_page_alloc>
	if(r < 0) {
  80125f:	85 c0                	test   %eax,%eax
  801261:	79 1c                	jns    80127f <pgfault+0x9f>
		panic("couldn't allocate page");
  801263:	c7 44 24 08 55 31 80 	movl   $0x803155,0x8(%esp)
  80126a:	00 
  80126b:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801272:	00 
  801273:	c7 04 24 3b 31 80 00 	movl   $0x80313b,(%esp)
  80127a:	e8 f7 f0 ff ff       	call   800376 <_panic>
	}

	memmove(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  80127f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  801285:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80128c:	00 
  80128d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801291:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801298:	e8 97 f9 ff ff       	call   800c34 <memmove>

	r = sys_page_map(envid, PFTEMP, envid, ROUNDDOWN(addr,PGSIZE), PTE_P | PTE_U | PTE_W);
  80129d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8012a4:	00 
  8012a5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012ad:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8012b4:	00 
  8012b5:	89 1c 24             	mov    %ebx,(%esp)
  8012b8:	e8 4a fc ff ff       	call   800f07 <sys_page_map>
	if(r < 0) {
  8012bd:	85 c0                	test   %eax,%eax
  8012bf:	79 1c                	jns    8012dd <pgfault+0xfd>
		panic("couldn't map page");
  8012c1:	c7 44 24 08 6c 31 80 	movl   $0x80316c,0x8(%esp)
  8012c8:	00 
  8012c9:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  8012d0:	00 
  8012d1:	c7 04 24 3b 31 80 00 	movl   $0x80313b,(%esp)
  8012d8:	e8 99 f0 ff ff       	call   800376 <_panic>
	}
}
  8012dd:	83 c4 20             	add    $0x20,%esp
  8012e0:	5b                   	pop    %ebx
  8012e1:	5e                   	pop    %esi
  8012e2:	5d                   	pop    %ebp
  8012e3:	c3                   	ret    

008012e4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8012e4:	55                   	push   %ebp
  8012e5:	89 e5                	mov    %esp,%ebp
  8012e7:	57                   	push   %edi
  8012e8:	56                   	push   %esi
  8012e9:	53                   	push   %ebx
  8012ea:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envid;
	uintptr_t addr;
	int r = 0;

	set_pgfault_handler(pgfault);
  8012ed:	c7 04 24 e0 11 80 00 	movl   $0x8011e0,(%esp)
  8012f4:	e8 0d 15 00 00       	call   802806 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8012f9:	b8 07 00 00 00       	mov    $0x7,%eax
  8012fe:	cd 30                	int    $0x30
  801300:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801303:	89 45 d8             	mov    %eax,-0x28(%ebp)

	envid = sys_exofork();
	if(envid == 0) {
  801306:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80130d:	bf 00 00 00 00       	mov    $0x0,%edi
  801312:	85 c0                	test   %eax,%eax
  801314:	75 21                	jne    801337 <fork+0x53>
		thisenv = &envs[ENVX(sys_getenvid())];
  801316:	e8 5a fb ff ff       	call   800e75 <sys_getenvid>
  80131b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801320:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801323:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801328:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  80132d:	b8 00 00 00 00       	mov    $0x0,%eax
  801332:	e9 8d 01 00 00       	jmp    8014c4 <fork+0x1e0>
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
  801337:	89 f8                	mov    %edi,%eax
  801339:	c1 e8 16             	shr    $0x16,%eax
  80133c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801343:	85 c0                	test   %eax,%eax
  801345:	0f 84 02 01 00 00    	je     80144d <fork+0x169>
  80134b:	89 fa                	mov    %edi,%edx
  80134d:	c1 ea 0c             	shr    $0xc,%edx
  801350:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801357:	85 c0                	test   %eax,%eax
  801359:	0f 84 ee 00 00 00    	je     80144d <fork+0x169>
//
static int
duppage(envid_t envid, unsigned pn)
{

	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P)) return 0;
  80135f:	89 d6                	mov    %edx,%esi
  801361:	c1 e6 0c             	shl    $0xc,%esi
  801364:	89 f0                	mov    %esi,%eax
  801366:	c1 e8 16             	shr    $0x16,%eax
  801369:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  801370:	b8 00 00 00 00       	mov    $0x0,%eax
  801375:	f6 c1 01             	test   $0x1,%cl
  801378:	0f 84 cc 00 00 00    	je     80144a <fork+0x166>

	int all_perms = PTE_U | PTE_P | PTE_AVAIL | PTE_W | PTE_COW;
	int orig_perms = uvpt[pn] & all_perms;
  80137e:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  801385:	89 d8                	mov    %ebx,%eax
  801387:	25 07 0e 00 00       	and    $0xe07,%eax
  80138c:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if(!(orig_perms & PTE_P)) return 0;
  80138f:	89 d8                	mov    %ebx,%eax
  801391:	83 e0 01             	and    $0x1,%eax
  801394:	0f 84 b0 00 00 00    	je     80144a <fork+0x166>

	int r = 0;
	envid_t curenvid = sys_getenvid();
  80139a:	e8 d6 fa ff ff       	call   800e75 <sys_getenvid>
  80139f:	89 45 dc             	mov    %eax,-0x24(%ebp)


	if(orig_perms & PTE_SHARE) {
  8013a2:	f7 45 e0 00 04 00 00 	testl  $0x400,-0x20(%ebp)
  8013a9:	74 28                	je     8013d3 <fork+0xef>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms & PTE_SYSCALL));
  8013ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013ae:	25 07 0e 00 00       	and    $0xe07,%eax
  8013b3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013b7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8013be:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013c9:	89 04 24             	mov    %eax,(%esp)
  8013cc:	e8 36 fb ff ff       	call   800f07 <sys_page_map>
  8013d1:	eb 77                	jmp    80144a <fork+0x166>

	} else if(((orig_perms) & PTE_COW) || (orig_perms & PTE_W) ) {
  8013d3:	f7 c3 02 08 00 00    	test   $0x802,%ebx
  8013d9:	74 4e                	je     801429 <fork+0x145>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  8013db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013de:	25 fd f7 ff ff       	and    $0xfffff7fd,%eax
  8013e3:	80 cc 08             	or     $0x8,%ah
  8013e6:	89 c3                	mov    %eax,%ebx
  8013e8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013ec:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8013f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013fe:	89 04 24             	mov    %eax,(%esp)
  801401:	e8 01 fb ff ff       	call   800f07 <sys_page_map>
  801406:	89 45 e0             	mov    %eax,-0x20(%ebp)

		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), curenvid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  801409:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80140d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801411:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801414:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801418:	89 74 24 04          	mov    %esi,0x4(%esp)
  80141c:	89 0c 24             	mov    %ecx,(%esp)
  80141f:	e8 e3 fa ff ff       	call   800f07 <sys_page_map>
  801424:	03 45 e0             	add    -0x20(%ebp),%eax
  801427:	eb 21                	jmp    80144a <fork+0x166>

	} else {
		r = sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), orig_perms);
  801429:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80142c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801430:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801434:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801437:	89 44 24 08          	mov    %eax,0x8(%esp)
  80143b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80143f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801442:	89 04 24             	mov    %eax,(%esp)
  801445:	e8 bd fa ff ff       	call   800f07 <sys_page_map>
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
  80144a:	01 45 e4             	add    %eax,-0x1c(%ebp)
	if(envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
  80144d:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801453:	81 ff 00 f0 bf ee    	cmp    $0xeebff000,%edi
  801459:	0f 85 d8 fe ff ff    	jne    801337 <fork+0x53>
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
		}
	}

	r+=sys_page_alloc(envid, (void*)UXSTACKTOP - PGSIZE, PTE_P|PTE_U|PTE_W);
  80145f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801466:	00 
  801467:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80146e:	ee 
  80146f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801472:	89 34 24             	mov    %esi,(%esp)
  801475:	e8 39 fa ff ff       	call   800eb3 <sys_page_alloc>
  80147a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80147d:	01 c3                	add    %eax,%ebx
	r+=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80147f:	c7 44 24 04 53 28 80 	movl   $0x802853,0x4(%esp)
  801486:	00 
  801487:	89 34 24             	mov    %esi,(%esp)
  80148a:	e8 c4 fb ff ff       	call   801053 <sys_env_set_pgfault_upcall>
  80148f:	01 c3                	add    %eax,%ebx
	r+= sys_env_set_status(envid, ENV_RUNNABLE);
  801491:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801498:	00 
  801499:	89 34 24             	mov    %esi,(%esp)
  80149c:	e8 0c fb ff ff       	call   800fad <sys_env_set_status>

	if(r<0) {
  8014a1:	01 d8                	add    %ebx,%eax
  8014a3:	79 1c                	jns    8014c1 <fork+0x1dd>
	 panic("fork failed!");
  8014a5:	c7 44 24 08 7e 31 80 	movl   $0x80317e,0x8(%esp)
  8014ac:	00 
  8014ad:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  8014b4:	00 
  8014b5:	c7 04 24 3b 31 80 00 	movl   $0x80313b,(%esp)
  8014bc:	e8 b5 ee ff ff       	call   800376 <_panic>
	}

	return envid;
  8014c1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  8014c4:	83 c4 3c             	add    $0x3c,%esp
  8014c7:	5b                   	pop    %ebx
  8014c8:	5e                   	pop    %esi
  8014c9:	5f                   	pop    %edi
  8014ca:	5d                   	pop    %ebp
  8014cb:	c3                   	ret    

008014cc <sfork>:

// Challenge!
int
sfork(void)
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8014d2:	c7 44 24 08 8b 31 80 	movl   $0x80318b,0x8(%esp)
  8014d9:	00 
  8014da:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
  8014e1:	00 
  8014e2:	c7 04 24 3b 31 80 00 	movl   $0x80313b,(%esp)
  8014e9:	e8 88 ee ff ff       	call   800376 <_panic>
  8014ee:	66 90                	xchg   %ax,%ax

008014f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8014fb:	c1 e8 0c             	shr    $0xc,%eax
}
  8014fe:	5d                   	pop    %ebp
  8014ff:	c3                   	ret    

00801500 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801503:	8b 45 08             	mov    0x8(%ebp),%eax
  801506:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80150b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801510:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801515:	5d                   	pop    %ebp
  801516:	c3                   	ret    

00801517 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801517:	55                   	push   %ebp
  801518:	89 e5                	mov    %esp,%ebp
  80151a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80151d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801522:	89 c2                	mov    %eax,%edx
  801524:	c1 ea 16             	shr    $0x16,%edx
  801527:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80152e:	f6 c2 01             	test   $0x1,%dl
  801531:	74 11                	je     801544 <fd_alloc+0x2d>
  801533:	89 c2                	mov    %eax,%edx
  801535:	c1 ea 0c             	shr    $0xc,%edx
  801538:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80153f:	f6 c2 01             	test   $0x1,%dl
  801542:	75 09                	jne    80154d <fd_alloc+0x36>
			*fd_store = fd;
  801544:	89 01                	mov    %eax,(%ecx)
			return 0;
  801546:	b8 00 00 00 00       	mov    $0x0,%eax
  80154b:	eb 17                	jmp    801564 <fd_alloc+0x4d>
  80154d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801552:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801557:	75 c9                	jne    801522 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801559:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80155f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801564:	5d                   	pop    %ebp
  801565:	c3                   	ret    

00801566 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801566:	55                   	push   %ebp
  801567:	89 e5                	mov    %esp,%ebp
  801569:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80156c:	83 f8 1f             	cmp    $0x1f,%eax
  80156f:	77 36                	ja     8015a7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801571:	c1 e0 0c             	shl    $0xc,%eax
  801574:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801579:	89 c2                	mov    %eax,%edx
  80157b:	c1 ea 16             	shr    $0x16,%edx
  80157e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801585:	f6 c2 01             	test   $0x1,%dl
  801588:	74 24                	je     8015ae <fd_lookup+0x48>
  80158a:	89 c2                	mov    %eax,%edx
  80158c:	c1 ea 0c             	shr    $0xc,%edx
  80158f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801596:	f6 c2 01             	test   $0x1,%dl
  801599:	74 1a                	je     8015b5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80159b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80159e:	89 02                	mov    %eax,(%edx)
	return 0;
  8015a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8015a5:	eb 13                	jmp    8015ba <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015ac:	eb 0c                	jmp    8015ba <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015b3:	eb 05                	jmp    8015ba <fd_lookup+0x54>
  8015b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8015ba:	5d                   	pop    %ebp
  8015bb:	c3                   	ret    

008015bc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015bc:	55                   	push   %ebp
  8015bd:	89 e5                	mov    %esp,%ebp
  8015bf:	83 ec 18             	sub    $0x18,%esp
  8015c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8015c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ca:	eb 13                	jmp    8015df <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8015cc:	39 08                	cmp    %ecx,(%eax)
  8015ce:	75 0c                	jne    8015dc <dev_lookup+0x20>
			*dev = devtab[i];
  8015d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015d3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8015d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8015da:	eb 38                	jmp    801614 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015dc:	83 c2 01             	add    $0x1,%edx
  8015df:	8b 04 95 20 32 80 00 	mov    0x803220(,%edx,4),%eax
  8015e6:	85 c0                	test   %eax,%eax
  8015e8:	75 e2                	jne    8015cc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015ea:	a1 08 50 80 00       	mov    0x805008,%eax
  8015ef:	8b 40 48             	mov    0x48(%eax),%eax
  8015f2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015fa:	c7 04 24 a4 31 80 00 	movl   $0x8031a4,(%esp)
  801601:	e8 69 ee ff ff       	call   80046f <cprintf>
	*dev = 0;
  801606:	8b 45 0c             	mov    0xc(%ebp),%eax
  801609:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80160f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801614:	c9                   	leave  
  801615:	c3                   	ret    

00801616 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	56                   	push   %esi
  80161a:	53                   	push   %ebx
  80161b:	83 ec 20             	sub    $0x20,%esp
  80161e:	8b 75 08             	mov    0x8(%ebp),%esi
  801621:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801624:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801627:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80162b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801631:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801634:	89 04 24             	mov    %eax,(%esp)
  801637:	e8 2a ff ff ff       	call   801566 <fd_lookup>
  80163c:	85 c0                	test   %eax,%eax
  80163e:	78 05                	js     801645 <fd_close+0x2f>
	    || fd != fd2)
  801640:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801643:	74 0c                	je     801651 <fd_close+0x3b>
		return (must_exist ? r : 0);
  801645:	84 db                	test   %bl,%bl
  801647:	ba 00 00 00 00       	mov    $0x0,%edx
  80164c:	0f 44 c2             	cmove  %edx,%eax
  80164f:	eb 3f                	jmp    801690 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801651:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801654:	89 44 24 04          	mov    %eax,0x4(%esp)
  801658:	8b 06                	mov    (%esi),%eax
  80165a:	89 04 24             	mov    %eax,(%esp)
  80165d:	e8 5a ff ff ff       	call   8015bc <dev_lookup>
  801662:	89 c3                	mov    %eax,%ebx
  801664:	85 c0                	test   %eax,%eax
  801666:	78 16                	js     80167e <fd_close+0x68>
		if (dev->dev_close)
  801668:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80166e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801673:	85 c0                	test   %eax,%eax
  801675:	74 07                	je     80167e <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801677:	89 34 24             	mov    %esi,(%esp)
  80167a:	ff d0                	call   *%eax
  80167c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80167e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801682:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801689:	e8 cc f8 ff ff       	call   800f5a <sys_page_unmap>
	return r;
  80168e:	89 d8                	mov    %ebx,%eax
}
  801690:	83 c4 20             	add    $0x20,%esp
  801693:	5b                   	pop    %ebx
  801694:	5e                   	pop    %esi
  801695:	5d                   	pop    %ebp
  801696:	c3                   	ret    

00801697 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80169d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a7:	89 04 24             	mov    %eax,(%esp)
  8016aa:	e8 b7 fe ff ff       	call   801566 <fd_lookup>
  8016af:	89 c2                	mov    %eax,%edx
  8016b1:	85 d2                	test   %edx,%edx
  8016b3:	78 13                	js     8016c8 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8016b5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8016bc:	00 
  8016bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c0:	89 04 24             	mov    %eax,(%esp)
  8016c3:	e8 4e ff ff ff       	call   801616 <fd_close>
}
  8016c8:	c9                   	leave  
  8016c9:	c3                   	ret    

008016ca <close_all>:

void
close_all(void)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	53                   	push   %ebx
  8016ce:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016d1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016d6:	89 1c 24             	mov    %ebx,(%esp)
  8016d9:	e8 b9 ff ff ff       	call   801697 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016de:	83 c3 01             	add    $0x1,%ebx
  8016e1:	83 fb 20             	cmp    $0x20,%ebx
  8016e4:	75 f0                	jne    8016d6 <close_all+0xc>
		close(i);
}
  8016e6:	83 c4 14             	add    $0x14,%esp
  8016e9:	5b                   	pop    %ebx
  8016ea:	5d                   	pop    %ebp
  8016eb:	c3                   	ret    

008016ec <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016ec:	55                   	push   %ebp
  8016ed:	89 e5                	mov    %esp,%ebp
  8016ef:	57                   	push   %edi
  8016f0:	56                   	push   %esi
  8016f1:	53                   	push   %ebx
  8016f2:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016f5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ff:	89 04 24             	mov    %eax,(%esp)
  801702:	e8 5f fe ff ff       	call   801566 <fd_lookup>
  801707:	89 c2                	mov    %eax,%edx
  801709:	85 d2                	test   %edx,%edx
  80170b:	0f 88 e1 00 00 00    	js     8017f2 <dup+0x106>
		return r;
	close(newfdnum);
  801711:	8b 45 0c             	mov    0xc(%ebp),%eax
  801714:	89 04 24             	mov    %eax,(%esp)
  801717:	e8 7b ff ff ff       	call   801697 <close>

	newfd = INDEX2FD(newfdnum);
  80171c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80171f:	c1 e3 0c             	shl    $0xc,%ebx
  801722:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801728:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80172b:	89 04 24             	mov    %eax,(%esp)
  80172e:	e8 cd fd ff ff       	call   801500 <fd2data>
  801733:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801735:	89 1c 24             	mov    %ebx,(%esp)
  801738:	e8 c3 fd ff ff       	call   801500 <fd2data>
  80173d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80173f:	89 f0                	mov    %esi,%eax
  801741:	c1 e8 16             	shr    $0x16,%eax
  801744:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80174b:	a8 01                	test   $0x1,%al
  80174d:	74 43                	je     801792 <dup+0xa6>
  80174f:	89 f0                	mov    %esi,%eax
  801751:	c1 e8 0c             	shr    $0xc,%eax
  801754:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80175b:	f6 c2 01             	test   $0x1,%dl
  80175e:	74 32                	je     801792 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801760:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801767:	25 07 0e 00 00       	and    $0xe07,%eax
  80176c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801770:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801774:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80177b:	00 
  80177c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801780:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801787:	e8 7b f7 ff ff       	call   800f07 <sys_page_map>
  80178c:	89 c6                	mov    %eax,%esi
  80178e:	85 c0                	test   %eax,%eax
  801790:	78 3e                	js     8017d0 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801792:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801795:	89 c2                	mov    %eax,%edx
  801797:	c1 ea 0c             	shr    $0xc,%edx
  80179a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017a1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8017a7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8017ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8017af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017b6:	00 
  8017b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017c2:	e8 40 f7 ff ff       	call   800f07 <sys_page_map>
  8017c7:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8017c9:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017cc:	85 f6                	test   %esi,%esi
  8017ce:	79 22                	jns    8017f2 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017db:	e8 7a f7 ff ff       	call   800f5a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017e0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8017e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017eb:	e8 6a f7 ff ff       	call   800f5a <sys_page_unmap>
	return r;
  8017f0:	89 f0                	mov    %esi,%eax
}
  8017f2:	83 c4 3c             	add    $0x3c,%esp
  8017f5:	5b                   	pop    %ebx
  8017f6:	5e                   	pop    %esi
  8017f7:	5f                   	pop    %edi
  8017f8:	5d                   	pop    %ebp
  8017f9:	c3                   	ret    

008017fa <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017fa:	55                   	push   %ebp
  8017fb:	89 e5                	mov    %esp,%ebp
  8017fd:	53                   	push   %ebx
  8017fe:	83 ec 24             	sub    $0x24,%esp
  801801:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801804:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801807:	89 44 24 04          	mov    %eax,0x4(%esp)
  80180b:	89 1c 24             	mov    %ebx,(%esp)
  80180e:	e8 53 fd ff ff       	call   801566 <fd_lookup>
  801813:	89 c2                	mov    %eax,%edx
  801815:	85 d2                	test   %edx,%edx
  801817:	78 6d                	js     801886 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801819:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801820:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801823:	8b 00                	mov    (%eax),%eax
  801825:	89 04 24             	mov    %eax,(%esp)
  801828:	e8 8f fd ff ff       	call   8015bc <dev_lookup>
  80182d:	85 c0                	test   %eax,%eax
  80182f:	78 55                	js     801886 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801831:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801834:	8b 50 08             	mov    0x8(%eax),%edx
  801837:	83 e2 03             	and    $0x3,%edx
  80183a:	83 fa 01             	cmp    $0x1,%edx
  80183d:	75 23                	jne    801862 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80183f:	a1 08 50 80 00       	mov    0x805008,%eax
  801844:	8b 40 48             	mov    0x48(%eax),%eax
  801847:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80184b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184f:	c7 04 24 e5 31 80 00 	movl   $0x8031e5,(%esp)
  801856:	e8 14 ec ff ff       	call   80046f <cprintf>
		return -E_INVAL;
  80185b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801860:	eb 24                	jmp    801886 <read+0x8c>
	}
	if (!dev->dev_read)
  801862:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801865:	8b 52 08             	mov    0x8(%edx),%edx
  801868:	85 d2                	test   %edx,%edx
  80186a:	74 15                	je     801881 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80186c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80186f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801873:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801876:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80187a:	89 04 24             	mov    %eax,(%esp)
  80187d:	ff d2                	call   *%edx
  80187f:	eb 05                	jmp    801886 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801881:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801886:	83 c4 24             	add    $0x24,%esp
  801889:	5b                   	pop    %ebx
  80188a:	5d                   	pop    %ebp
  80188b:	c3                   	ret    

0080188c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	57                   	push   %edi
  801890:	56                   	push   %esi
  801891:	53                   	push   %ebx
  801892:	83 ec 1c             	sub    $0x1c,%esp
  801895:	8b 7d 08             	mov    0x8(%ebp),%edi
  801898:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80189b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018a0:	eb 23                	jmp    8018c5 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018a2:	89 f0                	mov    %esi,%eax
  8018a4:	29 d8                	sub    %ebx,%eax
  8018a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018aa:	89 d8                	mov    %ebx,%eax
  8018ac:	03 45 0c             	add    0xc(%ebp),%eax
  8018af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b3:	89 3c 24             	mov    %edi,(%esp)
  8018b6:	e8 3f ff ff ff       	call   8017fa <read>
		if (m < 0)
  8018bb:	85 c0                	test   %eax,%eax
  8018bd:	78 10                	js     8018cf <readn+0x43>
			return m;
		if (m == 0)
  8018bf:	85 c0                	test   %eax,%eax
  8018c1:	74 0a                	je     8018cd <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018c3:	01 c3                	add    %eax,%ebx
  8018c5:	39 f3                	cmp    %esi,%ebx
  8018c7:	72 d9                	jb     8018a2 <readn+0x16>
  8018c9:	89 d8                	mov    %ebx,%eax
  8018cb:	eb 02                	jmp    8018cf <readn+0x43>
  8018cd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8018cf:	83 c4 1c             	add    $0x1c,%esp
  8018d2:	5b                   	pop    %ebx
  8018d3:	5e                   	pop    %esi
  8018d4:	5f                   	pop    %edi
  8018d5:	5d                   	pop    %ebp
  8018d6:	c3                   	ret    

008018d7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018d7:	55                   	push   %ebp
  8018d8:	89 e5                	mov    %esp,%ebp
  8018da:	53                   	push   %ebx
  8018db:	83 ec 24             	sub    $0x24,%esp
  8018de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e8:	89 1c 24             	mov    %ebx,(%esp)
  8018eb:	e8 76 fc ff ff       	call   801566 <fd_lookup>
  8018f0:	89 c2                	mov    %eax,%edx
  8018f2:	85 d2                	test   %edx,%edx
  8018f4:	78 68                	js     80195e <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801900:	8b 00                	mov    (%eax),%eax
  801902:	89 04 24             	mov    %eax,(%esp)
  801905:	e8 b2 fc ff ff       	call   8015bc <dev_lookup>
  80190a:	85 c0                	test   %eax,%eax
  80190c:	78 50                	js     80195e <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80190e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801911:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801915:	75 23                	jne    80193a <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801917:	a1 08 50 80 00       	mov    0x805008,%eax
  80191c:	8b 40 48             	mov    0x48(%eax),%eax
  80191f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801923:	89 44 24 04          	mov    %eax,0x4(%esp)
  801927:	c7 04 24 01 32 80 00 	movl   $0x803201,(%esp)
  80192e:	e8 3c eb ff ff       	call   80046f <cprintf>
		return -E_INVAL;
  801933:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801938:	eb 24                	jmp    80195e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80193a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80193d:	8b 52 0c             	mov    0xc(%edx),%edx
  801940:	85 d2                	test   %edx,%edx
  801942:	74 15                	je     801959 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801944:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801947:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80194b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80194e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801952:	89 04 24             	mov    %eax,(%esp)
  801955:	ff d2                	call   *%edx
  801957:	eb 05                	jmp    80195e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801959:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80195e:	83 c4 24             	add    $0x24,%esp
  801961:	5b                   	pop    %ebx
  801962:	5d                   	pop    %ebp
  801963:	c3                   	ret    

00801964 <seek>:

int
seek(int fdnum, off_t offset)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80196a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80196d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801971:	8b 45 08             	mov    0x8(%ebp),%eax
  801974:	89 04 24             	mov    %eax,(%esp)
  801977:	e8 ea fb ff ff       	call   801566 <fd_lookup>
  80197c:	85 c0                	test   %eax,%eax
  80197e:	78 0e                	js     80198e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801980:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801983:	8b 55 0c             	mov    0xc(%ebp),%edx
  801986:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801989:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80198e:	c9                   	leave  
  80198f:	c3                   	ret    

00801990 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	53                   	push   %ebx
  801994:	83 ec 24             	sub    $0x24,%esp
  801997:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80199a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80199d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a1:	89 1c 24             	mov    %ebx,(%esp)
  8019a4:	e8 bd fb ff ff       	call   801566 <fd_lookup>
  8019a9:	89 c2                	mov    %eax,%edx
  8019ab:	85 d2                	test   %edx,%edx
  8019ad:	78 61                	js     801a10 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019b9:	8b 00                	mov    (%eax),%eax
  8019bb:	89 04 24             	mov    %eax,(%esp)
  8019be:	e8 f9 fb ff ff       	call   8015bc <dev_lookup>
  8019c3:	85 c0                	test   %eax,%eax
  8019c5:	78 49                	js     801a10 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019ca:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019ce:	75 23                	jne    8019f3 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8019d0:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019d5:	8b 40 48             	mov    0x48(%eax),%eax
  8019d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e0:	c7 04 24 c4 31 80 00 	movl   $0x8031c4,(%esp)
  8019e7:	e8 83 ea ff ff       	call   80046f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019f1:	eb 1d                	jmp    801a10 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8019f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019f6:	8b 52 18             	mov    0x18(%edx),%edx
  8019f9:	85 d2                	test   %edx,%edx
  8019fb:	74 0e                	je     801a0b <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a00:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a04:	89 04 24             	mov    %eax,(%esp)
  801a07:	ff d2                	call   *%edx
  801a09:	eb 05                	jmp    801a10 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801a0b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801a10:	83 c4 24             	add    $0x24,%esp
  801a13:	5b                   	pop    %ebx
  801a14:	5d                   	pop    %ebp
  801a15:	c3                   	ret    

00801a16 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a16:	55                   	push   %ebp
  801a17:	89 e5                	mov    %esp,%ebp
  801a19:	53                   	push   %ebx
  801a1a:	83 ec 24             	sub    $0x24,%esp
  801a1d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a20:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a23:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a27:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2a:	89 04 24             	mov    %eax,(%esp)
  801a2d:	e8 34 fb ff ff       	call   801566 <fd_lookup>
  801a32:	89 c2                	mov    %eax,%edx
  801a34:	85 d2                	test   %edx,%edx
  801a36:	78 52                	js     801a8a <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a42:	8b 00                	mov    (%eax),%eax
  801a44:	89 04 24             	mov    %eax,(%esp)
  801a47:	e8 70 fb ff ff       	call   8015bc <dev_lookup>
  801a4c:	85 c0                	test   %eax,%eax
  801a4e:	78 3a                	js     801a8a <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a53:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a57:	74 2c                	je     801a85 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a59:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a5c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a63:	00 00 00 
	stat->st_isdir = 0;
  801a66:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a6d:	00 00 00 
	stat->st_dev = dev;
  801a70:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a76:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a7a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a7d:	89 14 24             	mov    %edx,(%esp)
  801a80:	ff 50 14             	call   *0x14(%eax)
  801a83:	eb 05                	jmp    801a8a <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a85:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a8a:	83 c4 24             	add    $0x24,%esp
  801a8d:	5b                   	pop    %ebx
  801a8e:	5d                   	pop    %ebp
  801a8f:	c3                   	ret    

00801a90 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	56                   	push   %esi
  801a94:	53                   	push   %ebx
  801a95:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a98:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a9f:	00 
  801aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa3:	89 04 24             	mov    %eax,(%esp)
  801aa6:	e8 28 02 00 00       	call   801cd3 <open>
  801aab:	89 c3                	mov    %eax,%ebx
  801aad:	85 db                	test   %ebx,%ebx
  801aaf:	78 1b                	js     801acc <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801ab1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab8:	89 1c 24             	mov    %ebx,(%esp)
  801abb:	e8 56 ff ff ff       	call   801a16 <fstat>
  801ac0:	89 c6                	mov    %eax,%esi
	close(fd);
  801ac2:	89 1c 24             	mov    %ebx,(%esp)
  801ac5:	e8 cd fb ff ff       	call   801697 <close>
	return r;
  801aca:	89 f0                	mov    %esi,%eax
}
  801acc:	83 c4 10             	add    $0x10,%esp
  801acf:	5b                   	pop    %ebx
  801ad0:	5e                   	pop    %esi
  801ad1:	5d                   	pop    %ebp
  801ad2:	c3                   	ret    

00801ad3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	56                   	push   %esi
  801ad7:	53                   	push   %ebx
  801ad8:	83 ec 10             	sub    $0x10,%esp
  801adb:	89 c6                	mov    %eax,%esi
  801add:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801adf:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801ae6:	75 11                	jne    801af9 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ae8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801aef:	e8 71 0e 00 00       	call   802965 <ipc_find_env>
  801af4:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801af9:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b00:	00 
  801b01:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801b08:	00 
  801b09:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b0d:	a1 00 50 80 00       	mov    0x805000,%eax
  801b12:	89 04 24             	mov    %eax,(%esp)
  801b15:	e8 e0 0d 00 00       	call   8028fa <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801b1a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b21:	00 
  801b22:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b26:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b2d:	e8 4e 0d 00 00       	call   802880 <ipc_recv>
}
  801b32:	83 c4 10             	add    $0x10,%esp
  801b35:	5b                   	pop    %ebx
  801b36:	5e                   	pop    %esi
  801b37:	5d                   	pop    %ebp
  801b38:	c3                   	ret    

00801b39 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b42:	8b 40 0c             	mov    0xc(%eax),%eax
  801b45:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801b4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b4d:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b52:	ba 00 00 00 00       	mov    $0x0,%edx
  801b57:	b8 02 00 00 00       	mov    $0x2,%eax
  801b5c:	e8 72 ff ff ff       	call   801ad3 <fsipc>
}
  801b61:	c9                   	leave  
  801b62:	c3                   	ret    

00801b63 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b63:	55                   	push   %ebp
  801b64:	89 e5                	mov    %esp,%ebp
  801b66:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b69:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6c:	8b 40 0c             	mov    0xc(%eax),%eax
  801b6f:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b74:	ba 00 00 00 00       	mov    $0x0,%edx
  801b79:	b8 06 00 00 00       	mov    $0x6,%eax
  801b7e:	e8 50 ff ff ff       	call   801ad3 <fsipc>
}
  801b83:	c9                   	leave  
  801b84:	c3                   	ret    

00801b85 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b85:	55                   	push   %ebp
  801b86:	89 e5                	mov    %esp,%ebp
  801b88:	53                   	push   %ebx
  801b89:	83 ec 14             	sub    $0x14,%esp
  801b8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b92:	8b 40 0c             	mov    0xc(%eax),%eax
  801b95:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b9a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b9f:	b8 05 00 00 00       	mov    $0x5,%eax
  801ba4:	e8 2a ff ff ff       	call   801ad3 <fsipc>
  801ba9:	89 c2                	mov    %eax,%edx
  801bab:	85 d2                	test   %edx,%edx
  801bad:	78 2b                	js     801bda <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801baf:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801bb6:	00 
  801bb7:	89 1c 24             	mov    %ebx,(%esp)
  801bba:	e8 d8 ee ff ff       	call   800a97 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801bbf:	a1 80 60 80 00       	mov    0x806080,%eax
  801bc4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801bca:	a1 84 60 80 00       	mov    0x806084,%eax
  801bcf:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801bd5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bda:	83 c4 14             	add    $0x14,%esp
  801bdd:	5b                   	pop    %ebx
  801bde:	5d                   	pop    %ebp
  801bdf:	c3                   	ret    

00801be0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801be0:	55                   	push   %ebp
  801be1:	89 e5                	mov    %esp,%ebp
  801be3:	83 ec 18             	sub    $0x18,%esp
  801be6:	8b 45 10             	mov    0x10(%ebp),%eax
  801be9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801bee:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801bf3:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801bf6:	8b 55 08             	mov    0x8(%ebp),%edx
  801bf9:	8b 52 0c             	mov    0xc(%edx),%edx
  801bfc:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801c02:	a3 04 60 80 00       	mov    %eax,0x806004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801c07:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c12:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801c19:	e8 16 f0 ff ff       	call   800c34 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  801c1e:	ba 00 00 00 00       	mov    $0x0,%edx
  801c23:	b8 04 00 00 00       	mov    $0x4,%eax
  801c28:	e8 a6 fe ff ff       	call   801ad3 <fsipc>
}
  801c2d:	c9                   	leave  
  801c2e:	c3                   	ret    

00801c2f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c2f:	55                   	push   %ebp
  801c30:	89 e5                	mov    %esp,%ebp
  801c32:	56                   	push   %esi
  801c33:	53                   	push   %ebx
  801c34:	83 ec 10             	sub    $0x10,%esp
  801c37:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3d:	8b 40 0c             	mov    0xc(%eax),%eax
  801c40:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801c45:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c4b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c50:	b8 03 00 00 00       	mov    $0x3,%eax
  801c55:	e8 79 fe ff ff       	call   801ad3 <fsipc>
  801c5a:	89 c3                	mov    %eax,%ebx
  801c5c:	85 c0                	test   %eax,%eax
  801c5e:	78 6a                	js     801cca <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801c60:	39 c6                	cmp    %eax,%esi
  801c62:	73 24                	jae    801c88 <devfile_read+0x59>
  801c64:	c7 44 24 0c 34 32 80 	movl   $0x803234,0xc(%esp)
  801c6b:	00 
  801c6c:	c7 44 24 08 3b 32 80 	movl   $0x80323b,0x8(%esp)
  801c73:	00 
  801c74:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801c7b:	00 
  801c7c:	c7 04 24 50 32 80 00 	movl   $0x803250,(%esp)
  801c83:	e8 ee e6 ff ff       	call   800376 <_panic>
	assert(r <= PGSIZE);
  801c88:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c8d:	7e 24                	jle    801cb3 <devfile_read+0x84>
  801c8f:	c7 44 24 0c 5b 32 80 	movl   $0x80325b,0xc(%esp)
  801c96:	00 
  801c97:	c7 44 24 08 3b 32 80 	movl   $0x80323b,0x8(%esp)
  801c9e:	00 
  801c9f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801ca6:	00 
  801ca7:	c7 04 24 50 32 80 00 	movl   $0x803250,(%esp)
  801cae:	e8 c3 e6 ff ff       	call   800376 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801cb3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cb7:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801cbe:	00 
  801cbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc2:	89 04 24             	mov    %eax,(%esp)
  801cc5:	e8 6a ef ff ff       	call   800c34 <memmove>
	return r;
}
  801cca:	89 d8                	mov    %ebx,%eax
  801ccc:	83 c4 10             	add    $0x10,%esp
  801ccf:	5b                   	pop    %ebx
  801cd0:	5e                   	pop    %esi
  801cd1:	5d                   	pop    %ebp
  801cd2:	c3                   	ret    

00801cd3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801cd3:	55                   	push   %ebp
  801cd4:	89 e5                	mov    %esp,%ebp
  801cd6:	53                   	push   %ebx
  801cd7:	83 ec 24             	sub    $0x24,%esp
  801cda:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801cdd:	89 1c 24             	mov    %ebx,(%esp)
  801ce0:	e8 7b ed ff ff       	call   800a60 <strlen>
  801ce5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801cea:	7f 60                	jg     801d4c <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801cec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cef:	89 04 24             	mov    %eax,(%esp)
  801cf2:	e8 20 f8 ff ff       	call   801517 <fd_alloc>
  801cf7:	89 c2                	mov    %eax,%edx
  801cf9:	85 d2                	test   %edx,%edx
  801cfb:	78 54                	js     801d51 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801cfd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d01:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801d08:	e8 8a ed ff ff       	call   800a97 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801d0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d10:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801d15:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d18:	b8 01 00 00 00       	mov    $0x1,%eax
  801d1d:	e8 b1 fd ff ff       	call   801ad3 <fsipc>
  801d22:	89 c3                	mov    %eax,%ebx
  801d24:	85 c0                	test   %eax,%eax
  801d26:	79 17                	jns    801d3f <open+0x6c>
		fd_close(fd, 0);
  801d28:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d2f:	00 
  801d30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d33:	89 04 24             	mov    %eax,(%esp)
  801d36:	e8 db f8 ff ff       	call   801616 <fd_close>
		return r;
  801d3b:	89 d8                	mov    %ebx,%eax
  801d3d:	eb 12                	jmp    801d51 <open+0x7e>
	}

	return fd2num(fd);
  801d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d42:	89 04 24             	mov    %eax,(%esp)
  801d45:	e8 a6 f7 ff ff       	call   8014f0 <fd2num>
  801d4a:	eb 05                	jmp    801d51 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801d4c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801d51:	83 c4 24             	add    $0x24,%esp
  801d54:	5b                   	pop    %ebx
  801d55:	5d                   	pop    %ebp
  801d56:	c3                   	ret    

00801d57 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801d57:	55                   	push   %ebp
  801d58:	89 e5                	mov    %esp,%ebp
  801d5a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d5d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d62:	b8 08 00 00 00       	mov    $0x8,%eax
  801d67:	e8 67 fd ff ff       	call   801ad3 <fsipc>
}
  801d6c:	c9                   	leave  
  801d6d:	c3                   	ret    
  801d6e:	66 90                	xchg   %ax,%ax

00801d70 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801d70:	55                   	push   %ebp
  801d71:	89 e5                	mov    %esp,%ebp
  801d73:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801d76:	c7 44 24 04 67 32 80 	movl   $0x803267,0x4(%esp)
  801d7d:	00 
  801d7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d81:	89 04 24             	mov    %eax,(%esp)
  801d84:	e8 0e ed ff ff       	call   800a97 <strcpy>
	return 0;
}
  801d89:	b8 00 00 00 00       	mov    $0x0,%eax
  801d8e:	c9                   	leave  
  801d8f:	c3                   	ret    

00801d90 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801d90:	55                   	push   %ebp
  801d91:	89 e5                	mov    %esp,%ebp
  801d93:	53                   	push   %ebx
  801d94:	83 ec 14             	sub    $0x14,%esp
  801d97:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801d9a:	89 1c 24             	mov    %ebx,(%esp)
  801d9d:	e8 fb 0b 00 00       	call   80299d <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801da2:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801da7:	83 f8 01             	cmp    $0x1,%eax
  801daa:	75 0d                	jne    801db9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801dac:	8b 43 0c             	mov    0xc(%ebx),%eax
  801daf:	89 04 24             	mov    %eax,(%esp)
  801db2:	e8 29 03 00 00       	call   8020e0 <nsipc_close>
  801db7:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  801db9:	89 d0                	mov    %edx,%eax
  801dbb:	83 c4 14             	add    $0x14,%esp
  801dbe:	5b                   	pop    %ebx
  801dbf:	5d                   	pop    %ebp
  801dc0:	c3                   	ret    

00801dc1 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801dc1:	55                   	push   %ebp
  801dc2:	89 e5                	mov    %esp,%ebp
  801dc4:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801dc7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801dce:	00 
  801dcf:	8b 45 10             	mov    0x10(%ebp),%eax
  801dd2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  801de0:	8b 40 0c             	mov    0xc(%eax),%eax
  801de3:	89 04 24             	mov    %eax,(%esp)
  801de6:	e8 f0 03 00 00       	call   8021db <nsipc_send>
}
  801deb:	c9                   	leave  
  801dec:	c3                   	ret    

00801ded <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801ded:	55                   	push   %ebp
  801dee:	89 e5                	mov    %esp,%ebp
  801df0:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801df3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801dfa:	00 
  801dfb:	8b 45 10             	mov    0x10(%ebp),%eax
  801dfe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e02:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e09:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0c:	8b 40 0c             	mov    0xc(%eax),%eax
  801e0f:	89 04 24             	mov    %eax,(%esp)
  801e12:	e8 44 03 00 00       	call   80215b <nsipc_recv>
}
  801e17:	c9                   	leave  
  801e18:	c3                   	ret    

00801e19 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801e19:	55                   	push   %ebp
  801e1a:	89 e5                	mov    %esp,%ebp
  801e1c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801e1f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801e22:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e26:	89 04 24             	mov    %eax,(%esp)
  801e29:	e8 38 f7 ff ff       	call   801566 <fd_lookup>
  801e2e:	85 c0                	test   %eax,%eax
  801e30:	78 17                	js     801e49 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e35:	8b 0d 24 40 80 00    	mov    0x804024,%ecx
  801e3b:	39 08                	cmp    %ecx,(%eax)
  801e3d:	75 05                	jne    801e44 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801e3f:	8b 40 0c             	mov    0xc(%eax),%eax
  801e42:	eb 05                	jmp    801e49 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801e44:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801e49:	c9                   	leave  
  801e4a:	c3                   	ret    

00801e4b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801e4b:	55                   	push   %ebp
  801e4c:	89 e5                	mov    %esp,%ebp
  801e4e:	56                   	push   %esi
  801e4f:	53                   	push   %ebx
  801e50:	83 ec 20             	sub    $0x20,%esp
  801e53:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801e55:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e58:	89 04 24             	mov    %eax,(%esp)
  801e5b:	e8 b7 f6 ff ff       	call   801517 <fd_alloc>
  801e60:	89 c3                	mov    %eax,%ebx
  801e62:	85 c0                	test   %eax,%eax
  801e64:	78 21                	js     801e87 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801e66:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e6d:	00 
  801e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e71:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e75:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e7c:	e8 32 f0 ff ff       	call   800eb3 <sys_page_alloc>
  801e81:	89 c3                	mov    %eax,%ebx
  801e83:	85 c0                	test   %eax,%eax
  801e85:	79 0c                	jns    801e93 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  801e87:	89 34 24             	mov    %esi,(%esp)
  801e8a:	e8 51 02 00 00       	call   8020e0 <nsipc_close>
		return r;
  801e8f:	89 d8                	mov    %ebx,%eax
  801e91:	eb 20                	jmp    801eb3 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801e93:	8b 15 24 40 80 00    	mov    0x804024,%edx
  801e99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e9c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801e9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ea1:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801ea8:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801eab:	89 14 24             	mov    %edx,(%esp)
  801eae:	e8 3d f6 ff ff       	call   8014f0 <fd2num>
}
  801eb3:	83 c4 20             	add    $0x20,%esp
  801eb6:	5b                   	pop    %ebx
  801eb7:	5e                   	pop    %esi
  801eb8:	5d                   	pop    %ebp
  801eb9:	c3                   	ret    

00801eba <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801eba:	55                   	push   %ebp
  801ebb:	89 e5                	mov    %esp,%ebp
  801ebd:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ec0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec3:	e8 51 ff ff ff       	call   801e19 <fd2sockid>
		return r;
  801ec8:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801eca:	85 c0                	test   %eax,%eax
  801ecc:	78 23                	js     801ef1 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ece:	8b 55 10             	mov    0x10(%ebp),%edx
  801ed1:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ed5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ed8:	89 54 24 04          	mov    %edx,0x4(%esp)
  801edc:	89 04 24             	mov    %eax,(%esp)
  801edf:	e8 45 01 00 00       	call   802029 <nsipc_accept>
		return r;
  801ee4:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ee6:	85 c0                	test   %eax,%eax
  801ee8:	78 07                	js     801ef1 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  801eea:	e8 5c ff ff ff       	call   801e4b <alloc_sockfd>
  801eef:	89 c1                	mov    %eax,%ecx
}
  801ef1:	89 c8                	mov    %ecx,%eax
  801ef3:	c9                   	leave  
  801ef4:	c3                   	ret    

00801ef5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ef5:	55                   	push   %ebp
  801ef6:	89 e5                	mov    %esp,%ebp
  801ef8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801efb:	8b 45 08             	mov    0x8(%ebp),%eax
  801efe:	e8 16 ff ff ff       	call   801e19 <fd2sockid>
  801f03:	89 c2                	mov    %eax,%edx
  801f05:	85 d2                	test   %edx,%edx
  801f07:	78 16                	js     801f1f <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  801f09:	8b 45 10             	mov    0x10(%ebp),%eax
  801f0c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f10:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f13:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f17:	89 14 24             	mov    %edx,(%esp)
  801f1a:	e8 60 01 00 00       	call   80207f <nsipc_bind>
}
  801f1f:	c9                   	leave  
  801f20:	c3                   	ret    

00801f21 <shutdown>:

int
shutdown(int s, int how)
{
  801f21:	55                   	push   %ebp
  801f22:	89 e5                	mov    %esp,%ebp
  801f24:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f27:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2a:	e8 ea fe ff ff       	call   801e19 <fd2sockid>
  801f2f:	89 c2                	mov    %eax,%edx
  801f31:	85 d2                	test   %edx,%edx
  801f33:	78 0f                	js     801f44 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801f35:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f38:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f3c:	89 14 24             	mov    %edx,(%esp)
  801f3f:	e8 7a 01 00 00       	call   8020be <nsipc_shutdown>
}
  801f44:	c9                   	leave  
  801f45:	c3                   	ret    

00801f46 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f46:	55                   	push   %ebp
  801f47:	89 e5                	mov    %esp,%ebp
  801f49:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4f:	e8 c5 fe ff ff       	call   801e19 <fd2sockid>
  801f54:	89 c2                	mov    %eax,%edx
  801f56:	85 d2                	test   %edx,%edx
  801f58:	78 16                	js     801f70 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  801f5a:	8b 45 10             	mov    0x10(%ebp),%eax
  801f5d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f61:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f64:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f68:	89 14 24             	mov    %edx,(%esp)
  801f6b:	e8 8a 01 00 00       	call   8020fa <nsipc_connect>
}
  801f70:	c9                   	leave  
  801f71:	c3                   	ret    

00801f72 <listen>:

int
listen(int s, int backlog)
{
  801f72:	55                   	push   %ebp
  801f73:	89 e5                	mov    %esp,%ebp
  801f75:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f78:	8b 45 08             	mov    0x8(%ebp),%eax
  801f7b:	e8 99 fe ff ff       	call   801e19 <fd2sockid>
  801f80:	89 c2                	mov    %eax,%edx
  801f82:	85 d2                	test   %edx,%edx
  801f84:	78 0f                	js     801f95 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801f86:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f89:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f8d:	89 14 24             	mov    %edx,(%esp)
  801f90:	e8 a4 01 00 00       	call   802139 <nsipc_listen>
}
  801f95:	c9                   	leave  
  801f96:	c3                   	ret    

00801f97 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801f97:	55                   	push   %ebp
  801f98:	89 e5                	mov    %esp,%ebp
  801f9a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f9d:	8b 45 10             	mov    0x10(%ebp),%eax
  801fa0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fa4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fab:	8b 45 08             	mov    0x8(%ebp),%eax
  801fae:	89 04 24             	mov    %eax,(%esp)
  801fb1:	e8 98 02 00 00       	call   80224e <nsipc_socket>
  801fb6:	89 c2                	mov    %eax,%edx
  801fb8:	85 d2                	test   %edx,%edx
  801fba:	78 05                	js     801fc1 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  801fbc:	e8 8a fe ff ff       	call   801e4b <alloc_sockfd>
}
  801fc1:	c9                   	leave  
  801fc2:	c3                   	ret    

00801fc3 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801fc3:	55                   	push   %ebp
  801fc4:	89 e5                	mov    %esp,%ebp
  801fc6:	53                   	push   %ebx
  801fc7:	83 ec 14             	sub    $0x14,%esp
  801fca:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801fcc:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801fd3:	75 11                	jne    801fe6 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801fd5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801fdc:	e8 84 09 00 00       	call   802965 <ipc_find_env>
  801fe1:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801fe6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801fed:	00 
  801fee:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801ff5:	00 
  801ff6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ffa:	a1 04 50 80 00       	mov    0x805004,%eax
  801fff:	89 04 24             	mov    %eax,(%esp)
  802002:	e8 f3 08 00 00       	call   8028fa <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802007:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80200e:	00 
  80200f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802016:	00 
  802017:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80201e:	e8 5d 08 00 00       	call   802880 <ipc_recv>
}
  802023:	83 c4 14             	add    $0x14,%esp
  802026:	5b                   	pop    %ebx
  802027:	5d                   	pop    %ebp
  802028:	c3                   	ret    

00802029 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802029:	55                   	push   %ebp
  80202a:	89 e5                	mov    %esp,%ebp
  80202c:	56                   	push   %esi
  80202d:	53                   	push   %ebx
  80202e:	83 ec 10             	sub    $0x10,%esp
  802031:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802034:	8b 45 08             	mov    0x8(%ebp),%eax
  802037:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80203c:	8b 06                	mov    (%esi),%eax
  80203e:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802043:	b8 01 00 00 00       	mov    $0x1,%eax
  802048:	e8 76 ff ff ff       	call   801fc3 <nsipc>
  80204d:	89 c3                	mov    %eax,%ebx
  80204f:	85 c0                	test   %eax,%eax
  802051:	78 23                	js     802076 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802053:	a1 10 70 80 00       	mov    0x807010,%eax
  802058:	89 44 24 08          	mov    %eax,0x8(%esp)
  80205c:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802063:	00 
  802064:	8b 45 0c             	mov    0xc(%ebp),%eax
  802067:	89 04 24             	mov    %eax,(%esp)
  80206a:	e8 c5 eb ff ff       	call   800c34 <memmove>
		*addrlen = ret->ret_addrlen;
  80206f:	a1 10 70 80 00       	mov    0x807010,%eax
  802074:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  802076:	89 d8                	mov    %ebx,%eax
  802078:	83 c4 10             	add    $0x10,%esp
  80207b:	5b                   	pop    %ebx
  80207c:	5e                   	pop    %esi
  80207d:	5d                   	pop    %ebp
  80207e:	c3                   	ret    

0080207f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80207f:	55                   	push   %ebp
  802080:	89 e5                	mov    %esp,%ebp
  802082:	53                   	push   %ebx
  802083:	83 ec 14             	sub    $0x14,%esp
  802086:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802089:	8b 45 08             	mov    0x8(%ebp),%eax
  80208c:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802091:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802095:	8b 45 0c             	mov    0xc(%ebp),%eax
  802098:	89 44 24 04          	mov    %eax,0x4(%esp)
  80209c:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8020a3:	e8 8c eb ff ff       	call   800c34 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8020a8:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8020ae:	b8 02 00 00 00       	mov    $0x2,%eax
  8020b3:	e8 0b ff ff ff       	call   801fc3 <nsipc>
}
  8020b8:	83 c4 14             	add    $0x14,%esp
  8020bb:	5b                   	pop    %ebx
  8020bc:	5d                   	pop    %ebp
  8020bd:	c3                   	ret    

008020be <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8020be:	55                   	push   %ebp
  8020bf:	89 e5                	mov    %esp,%ebp
  8020c1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8020c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8020cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020cf:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8020d4:	b8 03 00 00 00       	mov    $0x3,%eax
  8020d9:	e8 e5 fe ff ff       	call   801fc3 <nsipc>
}
  8020de:	c9                   	leave  
  8020df:	c3                   	ret    

008020e0 <nsipc_close>:

int
nsipc_close(int s)
{
  8020e0:	55                   	push   %ebp
  8020e1:	89 e5                	mov    %esp,%ebp
  8020e3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8020e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e9:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8020ee:	b8 04 00 00 00       	mov    $0x4,%eax
  8020f3:	e8 cb fe ff ff       	call   801fc3 <nsipc>
}
  8020f8:	c9                   	leave  
  8020f9:	c3                   	ret    

008020fa <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020fa:	55                   	push   %ebp
  8020fb:	89 e5                	mov    %esp,%ebp
  8020fd:	53                   	push   %ebx
  8020fe:	83 ec 14             	sub    $0x14,%esp
  802101:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802104:	8b 45 08             	mov    0x8(%ebp),%eax
  802107:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80210c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802110:	8b 45 0c             	mov    0xc(%ebp),%eax
  802113:	89 44 24 04          	mov    %eax,0x4(%esp)
  802117:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  80211e:	e8 11 eb ff ff       	call   800c34 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802123:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802129:	b8 05 00 00 00       	mov    $0x5,%eax
  80212e:	e8 90 fe ff ff       	call   801fc3 <nsipc>
}
  802133:	83 c4 14             	add    $0x14,%esp
  802136:	5b                   	pop    %ebx
  802137:	5d                   	pop    %ebp
  802138:	c3                   	ret    

00802139 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802139:	55                   	push   %ebp
  80213a:	89 e5                	mov    %esp,%ebp
  80213c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80213f:	8b 45 08             	mov    0x8(%ebp),%eax
  802142:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802147:	8b 45 0c             	mov    0xc(%ebp),%eax
  80214a:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  80214f:	b8 06 00 00 00       	mov    $0x6,%eax
  802154:	e8 6a fe ff ff       	call   801fc3 <nsipc>
}
  802159:	c9                   	leave  
  80215a:	c3                   	ret    

0080215b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80215b:	55                   	push   %ebp
  80215c:	89 e5                	mov    %esp,%ebp
  80215e:	56                   	push   %esi
  80215f:	53                   	push   %ebx
  802160:	83 ec 10             	sub    $0x10,%esp
  802163:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802166:	8b 45 08             	mov    0x8(%ebp),%eax
  802169:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  80216e:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802174:	8b 45 14             	mov    0x14(%ebp),%eax
  802177:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80217c:	b8 07 00 00 00       	mov    $0x7,%eax
  802181:	e8 3d fe ff ff       	call   801fc3 <nsipc>
  802186:	89 c3                	mov    %eax,%ebx
  802188:	85 c0                	test   %eax,%eax
  80218a:	78 46                	js     8021d2 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  80218c:	39 f0                	cmp    %esi,%eax
  80218e:	7f 07                	jg     802197 <nsipc_recv+0x3c>
  802190:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802195:	7e 24                	jle    8021bb <nsipc_recv+0x60>
  802197:	c7 44 24 0c 73 32 80 	movl   $0x803273,0xc(%esp)
  80219e:	00 
  80219f:	c7 44 24 08 3b 32 80 	movl   $0x80323b,0x8(%esp)
  8021a6:	00 
  8021a7:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  8021ae:	00 
  8021af:	c7 04 24 88 32 80 00 	movl   $0x803288,(%esp)
  8021b6:	e8 bb e1 ff ff       	call   800376 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8021bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021bf:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8021c6:	00 
  8021c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021ca:	89 04 24             	mov    %eax,(%esp)
  8021cd:	e8 62 ea ff ff       	call   800c34 <memmove>
	}

	return r;
}
  8021d2:	89 d8                	mov    %ebx,%eax
  8021d4:	83 c4 10             	add    $0x10,%esp
  8021d7:	5b                   	pop    %ebx
  8021d8:	5e                   	pop    %esi
  8021d9:	5d                   	pop    %ebp
  8021da:	c3                   	ret    

008021db <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8021db:	55                   	push   %ebp
  8021dc:	89 e5                	mov    %esp,%ebp
  8021de:	53                   	push   %ebx
  8021df:	83 ec 14             	sub    $0x14,%esp
  8021e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8021e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e8:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8021ed:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8021f3:	7e 24                	jle    802219 <nsipc_send+0x3e>
  8021f5:	c7 44 24 0c 94 32 80 	movl   $0x803294,0xc(%esp)
  8021fc:	00 
  8021fd:	c7 44 24 08 3b 32 80 	movl   $0x80323b,0x8(%esp)
  802204:	00 
  802205:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  80220c:	00 
  80220d:	c7 04 24 88 32 80 00 	movl   $0x803288,(%esp)
  802214:	e8 5d e1 ff ff       	call   800376 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802219:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80221d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802220:	89 44 24 04          	mov    %eax,0x4(%esp)
  802224:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  80222b:	e8 04 ea ff ff       	call   800c34 <memmove>
	nsipcbuf.send.req_size = size;
  802230:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802236:	8b 45 14             	mov    0x14(%ebp),%eax
  802239:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  80223e:	b8 08 00 00 00       	mov    $0x8,%eax
  802243:	e8 7b fd ff ff       	call   801fc3 <nsipc>
}
  802248:	83 c4 14             	add    $0x14,%esp
  80224b:	5b                   	pop    %ebx
  80224c:	5d                   	pop    %ebp
  80224d:	c3                   	ret    

0080224e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80224e:	55                   	push   %ebp
  80224f:	89 e5                	mov    %esp,%ebp
  802251:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802254:	8b 45 08             	mov    0x8(%ebp),%eax
  802257:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  80225c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80225f:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802264:	8b 45 10             	mov    0x10(%ebp),%eax
  802267:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  80226c:	b8 09 00 00 00       	mov    $0x9,%eax
  802271:	e8 4d fd ff ff       	call   801fc3 <nsipc>
}
  802276:	c9                   	leave  
  802277:	c3                   	ret    

00802278 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802278:	55                   	push   %ebp
  802279:	89 e5                	mov    %esp,%ebp
  80227b:	56                   	push   %esi
  80227c:	53                   	push   %ebx
  80227d:	83 ec 10             	sub    $0x10,%esp
  802280:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802283:	8b 45 08             	mov    0x8(%ebp),%eax
  802286:	89 04 24             	mov    %eax,(%esp)
  802289:	e8 72 f2 ff ff       	call   801500 <fd2data>
  80228e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802290:	c7 44 24 04 a0 32 80 	movl   $0x8032a0,0x4(%esp)
  802297:	00 
  802298:	89 1c 24             	mov    %ebx,(%esp)
  80229b:	e8 f7 e7 ff ff       	call   800a97 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8022a0:	8b 46 04             	mov    0x4(%esi),%eax
  8022a3:	2b 06                	sub    (%esi),%eax
  8022a5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8022ab:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8022b2:	00 00 00 
	stat->st_dev = &devpipe;
  8022b5:	c7 83 88 00 00 00 40 	movl   $0x804040,0x88(%ebx)
  8022bc:	40 80 00 
	return 0;
}
  8022bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8022c4:	83 c4 10             	add    $0x10,%esp
  8022c7:	5b                   	pop    %ebx
  8022c8:	5e                   	pop    %esi
  8022c9:	5d                   	pop    %ebp
  8022ca:	c3                   	ret    

008022cb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8022cb:	55                   	push   %ebp
  8022cc:	89 e5                	mov    %esp,%ebp
  8022ce:	53                   	push   %ebx
  8022cf:	83 ec 14             	sub    $0x14,%esp
  8022d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8022d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8022d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022e0:	e8 75 ec ff ff       	call   800f5a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8022e5:	89 1c 24             	mov    %ebx,(%esp)
  8022e8:	e8 13 f2 ff ff       	call   801500 <fd2data>
  8022ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022f8:	e8 5d ec ff ff       	call   800f5a <sys_page_unmap>
}
  8022fd:	83 c4 14             	add    $0x14,%esp
  802300:	5b                   	pop    %ebx
  802301:	5d                   	pop    %ebp
  802302:	c3                   	ret    

00802303 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802303:	55                   	push   %ebp
  802304:	89 e5                	mov    %esp,%ebp
  802306:	57                   	push   %edi
  802307:	56                   	push   %esi
  802308:	53                   	push   %ebx
  802309:	83 ec 2c             	sub    $0x2c,%esp
  80230c:	89 c6                	mov    %eax,%esi
  80230e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802311:	a1 08 50 80 00       	mov    0x805008,%eax
  802316:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802319:	89 34 24             	mov    %esi,(%esp)
  80231c:	e8 7c 06 00 00       	call   80299d <pageref>
  802321:	89 c7                	mov    %eax,%edi
  802323:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802326:	89 04 24             	mov    %eax,(%esp)
  802329:	e8 6f 06 00 00       	call   80299d <pageref>
  80232e:	39 c7                	cmp    %eax,%edi
  802330:	0f 94 c2             	sete   %dl
  802333:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  802336:	8b 0d 08 50 80 00    	mov    0x805008,%ecx
  80233c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  80233f:	39 fb                	cmp    %edi,%ebx
  802341:	74 21                	je     802364 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802343:	84 d2                	test   %dl,%dl
  802345:	74 ca                	je     802311 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802347:	8b 51 58             	mov    0x58(%ecx),%edx
  80234a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80234e:	89 54 24 08          	mov    %edx,0x8(%esp)
  802352:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802356:	c7 04 24 a7 32 80 00 	movl   $0x8032a7,(%esp)
  80235d:	e8 0d e1 ff ff       	call   80046f <cprintf>
  802362:	eb ad                	jmp    802311 <_pipeisclosed+0xe>
	}
}
  802364:	83 c4 2c             	add    $0x2c,%esp
  802367:	5b                   	pop    %ebx
  802368:	5e                   	pop    %esi
  802369:	5f                   	pop    %edi
  80236a:	5d                   	pop    %ebp
  80236b:	c3                   	ret    

0080236c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80236c:	55                   	push   %ebp
  80236d:	89 e5                	mov    %esp,%ebp
  80236f:	57                   	push   %edi
  802370:	56                   	push   %esi
  802371:	53                   	push   %ebx
  802372:	83 ec 1c             	sub    $0x1c,%esp
  802375:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802378:	89 34 24             	mov    %esi,(%esp)
  80237b:	e8 80 f1 ff ff       	call   801500 <fd2data>
  802380:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802382:	bf 00 00 00 00       	mov    $0x0,%edi
  802387:	eb 45                	jmp    8023ce <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802389:	89 da                	mov    %ebx,%edx
  80238b:	89 f0                	mov    %esi,%eax
  80238d:	e8 71 ff ff ff       	call   802303 <_pipeisclosed>
  802392:	85 c0                	test   %eax,%eax
  802394:	75 41                	jne    8023d7 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802396:	e8 f9 ea ff ff       	call   800e94 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80239b:	8b 43 04             	mov    0x4(%ebx),%eax
  80239e:	8b 0b                	mov    (%ebx),%ecx
  8023a0:	8d 51 20             	lea    0x20(%ecx),%edx
  8023a3:	39 d0                	cmp    %edx,%eax
  8023a5:	73 e2                	jae    802389 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8023a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023aa:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8023ae:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8023b1:	99                   	cltd   
  8023b2:	c1 ea 1b             	shr    $0x1b,%edx
  8023b5:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8023b8:	83 e1 1f             	and    $0x1f,%ecx
  8023bb:	29 d1                	sub    %edx,%ecx
  8023bd:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8023c1:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8023c5:	83 c0 01             	add    $0x1,%eax
  8023c8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023cb:	83 c7 01             	add    $0x1,%edi
  8023ce:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8023d1:	75 c8                	jne    80239b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8023d3:	89 f8                	mov    %edi,%eax
  8023d5:	eb 05                	jmp    8023dc <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023d7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8023dc:	83 c4 1c             	add    $0x1c,%esp
  8023df:	5b                   	pop    %ebx
  8023e0:	5e                   	pop    %esi
  8023e1:	5f                   	pop    %edi
  8023e2:	5d                   	pop    %ebp
  8023e3:	c3                   	ret    

008023e4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8023e4:	55                   	push   %ebp
  8023e5:	89 e5                	mov    %esp,%ebp
  8023e7:	57                   	push   %edi
  8023e8:	56                   	push   %esi
  8023e9:	53                   	push   %ebx
  8023ea:	83 ec 1c             	sub    $0x1c,%esp
  8023ed:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8023f0:	89 3c 24             	mov    %edi,(%esp)
  8023f3:	e8 08 f1 ff ff       	call   801500 <fd2data>
  8023f8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023fa:	be 00 00 00 00       	mov    $0x0,%esi
  8023ff:	eb 3d                	jmp    80243e <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802401:	85 f6                	test   %esi,%esi
  802403:	74 04                	je     802409 <devpipe_read+0x25>
				return i;
  802405:	89 f0                	mov    %esi,%eax
  802407:	eb 43                	jmp    80244c <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802409:	89 da                	mov    %ebx,%edx
  80240b:	89 f8                	mov    %edi,%eax
  80240d:	e8 f1 fe ff ff       	call   802303 <_pipeisclosed>
  802412:	85 c0                	test   %eax,%eax
  802414:	75 31                	jne    802447 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802416:	e8 79 ea ff ff       	call   800e94 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80241b:	8b 03                	mov    (%ebx),%eax
  80241d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802420:	74 df                	je     802401 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802422:	99                   	cltd   
  802423:	c1 ea 1b             	shr    $0x1b,%edx
  802426:	01 d0                	add    %edx,%eax
  802428:	83 e0 1f             	and    $0x1f,%eax
  80242b:	29 d0                	sub    %edx,%eax
  80242d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802432:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802435:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802438:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80243b:	83 c6 01             	add    $0x1,%esi
  80243e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802441:	75 d8                	jne    80241b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802443:	89 f0                	mov    %esi,%eax
  802445:	eb 05                	jmp    80244c <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802447:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80244c:	83 c4 1c             	add    $0x1c,%esp
  80244f:	5b                   	pop    %ebx
  802450:	5e                   	pop    %esi
  802451:	5f                   	pop    %edi
  802452:	5d                   	pop    %ebp
  802453:	c3                   	ret    

00802454 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802454:	55                   	push   %ebp
  802455:	89 e5                	mov    %esp,%ebp
  802457:	56                   	push   %esi
  802458:	53                   	push   %ebx
  802459:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80245c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80245f:	89 04 24             	mov    %eax,(%esp)
  802462:	e8 b0 f0 ff ff       	call   801517 <fd_alloc>
  802467:	89 c2                	mov    %eax,%edx
  802469:	85 d2                	test   %edx,%edx
  80246b:	0f 88 4d 01 00 00    	js     8025be <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802471:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802478:	00 
  802479:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80247c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802480:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802487:	e8 27 ea ff ff       	call   800eb3 <sys_page_alloc>
  80248c:	89 c2                	mov    %eax,%edx
  80248e:	85 d2                	test   %edx,%edx
  802490:	0f 88 28 01 00 00    	js     8025be <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802496:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802499:	89 04 24             	mov    %eax,(%esp)
  80249c:	e8 76 f0 ff ff       	call   801517 <fd_alloc>
  8024a1:	89 c3                	mov    %eax,%ebx
  8024a3:	85 c0                	test   %eax,%eax
  8024a5:	0f 88 fe 00 00 00    	js     8025a9 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024ab:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8024b2:	00 
  8024b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024c1:	e8 ed e9 ff ff       	call   800eb3 <sys_page_alloc>
  8024c6:	89 c3                	mov    %eax,%ebx
  8024c8:	85 c0                	test   %eax,%eax
  8024ca:	0f 88 d9 00 00 00    	js     8025a9 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8024d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024d3:	89 04 24             	mov    %eax,(%esp)
  8024d6:	e8 25 f0 ff ff       	call   801500 <fd2data>
  8024db:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024dd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8024e4:	00 
  8024e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024f0:	e8 be e9 ff ff       	call   800eb3 <sys_page_alloc>
  8024f5:	89 c3                	mov    %eax,%ebx
  8024f7:	85 c0                	test   %eax,%eax
  8024f9:	0f 88 97 00 00 00    	js     802596 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802502:	89 04 24             	mov    %eax,(%esp)
  802505:	e8 f6 ef ff ff       	call   801500 <fd2data>
  80250a:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802511:	00 
  802512:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802516:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80251d:	00 
  80251e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802522:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802529:	e8 d9 e9 ff ff       	call   800f07 <sys_page_map>
  80252e:	89 c3                	mov    %eax,%ebx
  802530:	85 c0                	test   %eax,%eax
  802532:	78 52                	js     802586 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802534:	8b 15 40 40 80 00    	mov    0x804040,%edx
  80253a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80253d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80253f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802542:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802549:	8b 15 40 40 80 00    	mov    0x804040,%edx
  80254f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802552:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802554:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802557:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80255e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802561:	89 04 24             	mov    %eax,(%esp)
  802564:	e8 87 ef ff ff       	call   8014f0 <fd2num>
  802569:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80256c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80256e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802571:	89 04 24             	mov    %eax,(%esp)
  802574:	e8 77 ef ff ff       	call   8014f0 <fd2num>
  802579:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80257c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80257f:	b8 00 00 00 00       	mov    $0x0,%eax
  802584:	eb 38                	jmp    8025be <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  802586:	89 74 24 04          	mov    %esi,0x4(%esp)
  80258a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802591:	e8 c4 e9 ff ff       	call   800f5a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802596:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802599:	89 44 24 04          	mov    %eax,0x4(%esp)
  80259d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025a4:	e8 b1 e9 ff ff       	call   800f5a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8025a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025b7:	e8 9e e9 ff ff       	call   800f5a <sys_page_unmap>
  8025bc:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  8025be:	83 c4 30             	add    $0x30,%esp
  8025c1:	5b                   	pop    %ebx
  8025c2:	5e                   	pop    %esi
  8025c3:	5d                   	pop    %ebp
  8025c4:	c3                   	ret    

008025c5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8025c5:	55                   	push   %ebp
  8025c6:	89 e5                	mov    %esp,%ebp
  8025c8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8025d5:	89 04 24             	mov    %eax,(%esp)
  8025d8:	e8 89 ef ff ff       	call   801566 <fd_lookup>
  8025dd:	89 c2                	mov    %eax,%edx
  8025df:	85 d2                	test   %edx,%edx
  8025e1:	78 15                	js     8025f8 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8025e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025e6:	89 04 24             	mov    %eax,(%esp)
  8025e9:	e8 12 ef ff ff       	call   801500 <fd2data>
	return _pipeisclosed(fd, p);
  8025ee:	89 c2                	mov    %eax,%edx
  8025f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025f3:	e8 0b fd ff ff       	call   802303 <_pipeisclosed>
}
  8025f8:	c9                   	leave  
  8025f9:	c3                   	ret    

008025fa <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8025fa:	55                   	push   %ebp
  8025fb:	89 e5                	mov    %esp,%ebp
  8025fd:	56                   	push   %esi
  8025fe:	53                   	push   %ebx
  8025ff:	83 ec 10             	sub    $0x10,%esp
  802602:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802605:	85 f6                	test   %esi,%esi
  802607:	75 24                	jne    80262d <wait+0x33>
  802609:	c7 44 24 0c bf 32 80 	movl   $0x8032bf,0xc(%esp)
  802610:	00 
  802611:	c7 44 24 08 3b 32 80 	movl   $0x80323b,0x8(%esp)
  802618:	00 
  802619:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  802620:	00 
  802621:	c7 04 24 ca 32 80 00 	movl   $0x8032ca,(%esp)
  802628:	e8 49 dd ff ff       	call   800376 <_panic>
	e = &envs[ENVX(envid)];
  80262d:	89 f3                	mov    %esi,%ebx
  80262f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  802635:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802638:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80263e:	eb 05                	jmp    802645 <wait+0x4b>
		sys_yield();
  802640:	e8 4f e8 ff ff       	call   800e94 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802645:	8b 43 48             	mov    0x48(%ebx),%eax
  802648:	39 f0                	cmp    %esi,%eax
  80264a:	75 07                	jne    802653 <wait+0x59>
  80264c:	8b 43 54             	mov    0x54(%ebx),%eax
  80264f:	85 c0                	test   %eax,%eax
  802651:	75 ed                	jne    802640 <wait+0x46>
		sys_yield();
}
  802653:	83 c4 10             	add    $0x10,%esp
  802656:	5b                   	pop    %ebx
  802657:	5e                   	pop    %esi
  802658:	5d                   	pop    %ebp
  802659:	c3                   	ret    
  80265a:	66 90                	xchg   %ax,%ax
  80265c:	66 90                	xchg   %ax,%ax
  80265e:	66 90                	xchg   %ax,%ax

00802660 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802660:	55                   	push   %ebp
  802661:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802663:	b8 00 00 00 00       	mov    $0x0,%eax
  802668:	5d                   	pop    %ebp
  802669:	c3                   	ret    

0080266a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80266a:	55                   	push   %ebp
  80266b:	89 e5                	mov    %esp,%ebp
  80266d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802670:	c7 44 24 04 d5 32 80 	movl   $0x8032d5,0x4(%esp)
  802677:	00 
  802678:	8b 45 0c             	mov    0xc(%ebp),%eax
  80267b:	89 04 24             	mov    %eax,(%esp)
  80267e:	e8 14 e4 ff ff       	call   800a97 <strcpy>
	return 0;
}
  802683:	b8 00 00 00 00       	mov    $0x0,%eax
  802688:	c9                   	leave  
  802689:	c3                   	ret    

0080268a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80268a:	55                   	push   %ebp
  80268b:	89 e5                	mov    %esp,%ebp
  80268d:	57                   	push   %edi
  80268e:	56                   	push   %esi
  80268f:	53                   	push   %ebx
  802690:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802696:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80269b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8026a1:	eb 31                	jmp    8026d4 <devcons_write+0x4a>
		m = n - tot;
  8026a3:	8b 75 10             	mov    0x10(%ebp),%esi
  8026a6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8026a8:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8026ab:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8026b0:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8026b3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8026b7:	03 45 0c             	add    0xc(%ebp),%eax
  8026ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026be:	89 3c 24             	mov    %edi,(%esp)
  8026c1:	e8 6e e5 ff ff       	call   800c34 <memmove>
		sys_cputs(buf, m);
  8026c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026ca:	89 3c 24             	mov    %edi,(%esp)
  8026cd:	e8 14 e7 ff ff       	call   800de6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8026d2:	01 f3                	add    %esi,%ebx
  8026d4:	89 d8                	mov    %ebx,%eax
  8026d6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8026d9:	72 c8                	jb     8026a3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8026db:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8026e1:	5b                   	pop    %ebx
  8026e2:	5e                   	pop    %esi
  8026e3:	5f                   	pop    %edi
  8026e4:	5d                   	pop    %ebp
  8026e5:	c3                   	ret    

008026e6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8026e6:	55                   	push   %ebp
  8026e7:	89 e5                	mov    %esp,%ebp
  8026e9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8026ec:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8026f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8026f5:	75 07                	jne    8026fe <devcons_read+0x18>
  8026f7:	eb 2a                	jmp    802723 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8026f9:	e8 96 e7 ff ff       	call   800e94 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8026fe:	66 90                	xchg   %ax,%ax
  802700:	e8 ff e6 ff ff       	call   800e04 <sys_cgetc>
  802705:	85 c0                	test   %eax,%eax
  802707:	74 f0                	je     8026f9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802709:	85 c0                	test   %eax,%eax
  80270b:	78 16                	js     802723 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80270d:	83 f8 04             	cmp    $0x4,%eax
  802710:	74 0c                	je     80271e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802712:	8b 55 0c             	mov    0xc(%ebp),%edx
  802715:	88 02                	mov    %al,(%edx)
	return 1;
  802717:	b8 01 00 00 00       	mov    $0x1,%eax
  80271c:	eb 05                	jmp    802723 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80271e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802723:	c9                   	leave  
  802724:	c3                   	ret    

00802725 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802725:	55                   	push   %ebp
  802726:	89 e5                	mov    %esp,%ebp
  802728:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80272b:	8b 45 08             	mov    0x8(%ebp),%eax
  80272e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802731:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802738:	00 
  802739:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80273c:	89 04 24             	mov    %eax,(%esp)
  80273f:	e8 a2 e6 ff ff       	call   800de6 <sys_cputs>
}
  802744:	c9                   	leave  
  802745:	c3                   	ret    

00802746 <getchar>:

int
getchar(void)
{
  802746:	55                   	push   %ebp
  802747:	89 e5                	mov    %esp,%ebp
  802749:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80274c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802753:	00 
  802754:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802757:	89 44 24 04          	mov    %eax,0x4(%esp)
  80275b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802762:	e8 93 f0 ff ff       	call   8017fa <read>
	if (r < 0)
  802767:	85 c0                	test   %eax,%eax
  802769:	78 0f                	js     80277a <getchar+0x34>
		return r;
	if (r < 1)
  80276b:	85 c0                	test   %eax,%eax
  80276d:	7e 06                	jle    802775 <getchar+0x2f>
		return -E_EOF;
	return c;
  80276f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802773:	eb 05                	jmp    80277a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802775:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80277a:	c9                   	leave  
  80277b:	c3                   	ret    

0080277c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80277c:	55                   	push   %ebp
  80277d:	89 e5                	mov    %esp,%ebp
  80277f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802782:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802785:	89 44 24 04          	mov    %eax,0x4(%esp)
  802789:	8b 45 08             	mov    0x8(%ebp),%eax
  80278c:	89 04 24             	mov    %eax,(%esp)
  80278f:	e8 d2 ed ff ff       	call   801566 <fd_lookup>
  802794:	85 c0                	test   %eax,%eax
  802796:	78 11                	js     8027a9 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802798:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80279b:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  8027a1:	39 10                	cmp    %edx,(%eax)
  8027a3:	0f 94 c0             	sete   %al
  8027a6:	0f b6 c0             	movzbl %al,%eax
}
  8027a9:	c9                   	leave  
  8027aa:	c3                   	ret    

008027ab <opencons>:

int
opencons(void)
{
  8027ab:	55                   	push   %ebp
  8027ac:	89 e5                	mov    %esp,%ebp
  8027ae:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8027b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8027b4:	89 04 24             	mov    %eax,(%esp)
  8027b7:	e8 5b ed ff ff       	call   801517 <fd_alloc>
		return r;
  8027bc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8027be:	85 c0                	test   %eax,%eax
  8027c0:	78 40                	js     802802 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8027c2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8027c9:	00 
  8027ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027d8:	e8 d6 e6 ff ff       	call   800eb3 <sys_page_alloc>
		return r;
  8027dd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8027df:	85 c0                	test   %eax,%eax
  8027e1:	78 1f                	js     802802 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8027e3:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  8027e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027ec:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8027ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027f1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8027f8:	89 04 24             	mov    %eax,(%esp)
  8027fb:	e8 f0 ec ff ff       	call   8014f0 <fd2num>
  802800:	89 c2                	mov    %eax,%edx
}
  802802:	89 d0                	mov    %edx,%eax
  802804:	c9                   	leave  
  802805:	c3                   	ret    

00802806 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802806:	55                   	push   %ebp
  802807:	89 e5                	mov    %esp,%ebp
  802809:	53                   	push   %ebx
  80280a:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  80280d:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802814:	75 2f                	jne    802845 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  802816:	e8 5a e6 ff ff       	call   800e75 <sys_getenvid>
  80281b:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P);
  80281d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802824:	00 
  802825:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80282c:	ee 
  80282d:	89 04 24             	mov    %eax,(%esp)
  802830:	e8 7e e6 ff ff       	call   800eb3 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *)_pgfault_upcall);
  802835:	c7 44 24 04 53 28 80 	movl   $0x802853,0x4(%esp)
  80283c:	00 
  80283d:	89 1c 24             	mov    %ebx,(%esp)
  802840:	e8 0e e8 ff ff       	call   801053 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802845:	8b 45 08             	mov    0x8(%ebp),%eax
  802848:	a3 00 80 80 00       	mov    %eax,0x808000
}
  80284d:	83 c4 14             	add    $0x14,%esp
  802850:	5b                   	pop    %ebx
  802851:	5d                   	pop    %ebp
  802852:	c3                   	ret    

00802853 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802853:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802854:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802859:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80285b:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	// 0x30(%esp) points to trap-time stack pointer
	// 0x28(%esp) points to trap-time eip
	subl $4, 0x30(%esp)
  80285e:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax 
  802863:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebp
  802867:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %ebp, (%eax)
  80286b:	89 28                	mov    %ebp,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  80286d:	83 c4 08             	add    $0x8,%esp
	popal
  802870:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp //pop eip - we already stored it
  802871:	83 c4 04             	add    $0x4,%esp
	popfl
  802874:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802875:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802876:	c3                   	ret    
  802877:	66 90                	xchg   %ax,%ax
  802879:	66 90                	xchg   %ax,%ax
  80287b:	66 90                	xchg   %ax,%ax
  80287d:	66 90                	xchg   %ax,%ax
  80287f:	90                   	nop

00802880 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802880:	55                   	push   %ebp
  802881:	89 e5                	mov    %esp,%ebp
  802883:	56                   	push   %esi
  802884:	53                   	push   %ebx
  802885:	83 ec 10             	sub    $0x10,%esp
  802888:	8b 75 08             	mov    0x8(%ebp),%esi
  80288b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80288e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  802891:	85 c0                	test   %eax,%eax
  802893:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802898:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  80289b:	89 04 24             	mov    %eax,(%esp)
  80289e:	e8 26 e8 ff ff       	call   8010c9 <sys_ipc_recv>

	if(ret < 0) {
  8028a3:	85 c0                	test   %eax,%eax
  8028a5:	79 16                	jns    8028bd <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  8028a7:	85 f6                	test   %esi,%esi
  8028a9:	74 06                	je     8028b1 <ipc_recv+0x31>
  8028ab:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  8028b1:	85 db                	test   %ebx,%ebx
  8028b3:	74 3e                	je     8028f3 <ipc_recv+0x73>
  8028b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8028bb:	eb 36                	jmp    8028f3 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  8028bd:	e8 b3 e5 ff ff       	call   800e75 <sys_getenvid>
  8028c2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8028c7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8028ca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8028cf:	a3 08 50 80 00       	mov    %eax,0x805008

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8028d4:	85 f6                	test   %esi,%esi
  8028d6:	74 05                	je     8028dd <ipc_recv+0x5d>
  8028d8:	8b 40 74             	mov    0x74(%eax),%eax
  8028db:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8028dd:	85 db                	test   %ebx,%ebx
  8028df:	74 0a                	je     8028eb <ipc_recv+0x6b>
  8028e1:	a1 08 50 80 00       	mov    0x805008,%eax
  8028e6:	8b 40 78             	mov    0x78(%eax),%eax
  8028e9:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  8028eb:	a1 08 50 80 00       	mov    0x805008,%eax
  8028f0:	8b 40 70             	mov    0x70(%eax),%eax
}
  8028f3:	83 c4 10             	add    $0x10,%esp
  8028f6:	5b                   	pop    %ebx
  8028f7:	5e                   	pop    %esi
  8028f8:	5d                   	pop    %ebp
  8028f9:	c3                   	ret    

008028fa <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8028fa:	55                   	push   %ebp
  8028fb:	89 e5                	mov    %esp,%ebp
  8028fd:	57                   	push   %edi
  8028fe:	56                   	push   %esi
  8028ff:	53                   	push   %ebx
  802900:	83 ec 1c             	sub    $0x1c,%esp
  802903:	8b 7d 08             	mov    0x8(%ebp),%edi
  802906:	8b 75 0c             	mov    0xc(%ebp),%esi
  802909:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  80290c:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  80290e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802913:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  802916:	8b 45 14             	mov    0x14(%ebp),%eax
  802919:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80291d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802921:	89 74 24 04          	mov    %esi,0x4(%esp)
  802925:	89 3c 24             	mov    %edi,(%esp)
  802928:	e8 79 e7 ff ff       	call   8010a6 <sys_ipc_try_send>

		if(ret >= 0) break;
  80292d:	85 c0                	test   %eax,%eax
  80292f:	79 2c                	jns    80295d <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  802931:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802934:	74 20                	je     802956 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  802936:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80293a:	c7 44 24 08 e4 32 80 	movl   $0x8032e4,0x8(%esp)
  802941:	00 
  802942:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  802949:	00 
  80294a:	c7 04 24 14 33 80 00 	movl   $0x803314,(%esp)
  802951:	e8 20 da ff ff       	call   800376 <_panic>
		}
		sys_yield();
  802956:	e8 39 e5 ff ff       	call   800e94 <sys_yield>
	}
  80295b:	eb b9                	jmp    802916 <ipc_send+0x1c>
}
  80295d:	83 c4 1c             	add    $0x1c,%esp
  802960:	5b                   	pop    %ebx
  802961:	5e                   	pop    %esi
  802962:	5f                   	pop    %edi
  802963:	5d                   	pop    %ebp
  802964:	c3                   	ret    

00802965 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802965:	55                   	push   %ebp
  802966:	89 e5                	mov    %esp,%ebp
  802968:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80296b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802970:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802973:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802979:	8b 52 50             	mov    0x50(%edx),%edx
  80297c:	39 ca                	cmp    %ecx,%edx
  80297e:	75 0d                	jne    80298d <ipc_find_env+0x28>
			return envs[i].env_id;
  802980:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802983:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802988:	8b 40 40             	mov    0x40(%eax),%eax
  80298b:	eb 0e                	jmp    80299b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80298d:	83 c0 01             	add    $0x1,%eax
  802990:	3d 00 04 00 00       	cmp    $0x400,%eax
  802995:	75 d9                	jne    802970 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802997:	66 b8 00 00          	mov    $0x0,%ax
}
  80299b:	5d                   	pop    %ebp
  80299c:	c3                   	ret    

0080299d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80299d:	55                   	push   %ebp
  80299e:	89 e5                	mov    %esp,%ebp
  8029a0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8029a3:	89 d0                	mov    %edx,%eax
  8029a5:	c1 e8 16             	shr    $0x16,%eax
  8029a8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8029af:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8029b4:	f6 c1 01             	test   $0x1,%cl
  8029b7:	74 1d                	je     8029d6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8029b9:	c1 ea 0c             	shr    $0xc,%edx
  8029bc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8029c3:	f6 c2 01             	test   $0x1,%dl
  8029c6:	74 0e                	je     8029d6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8029c8:	c1 ea 0c             	shr    $0xc,%edx
  8029cb:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8029d2:	ef 
  8029d3:	0f b7 c0             	movzwl %ax,%eax
}
  8029d6:	5d                   	pop    %ebp
  8029d7:	c3                   	ret    
  8029d8:	66 90                	xchg   %ax,%ax
  8029da:	66 90                	xchg   %ax,%ax
  8029dc:	66 90                	xchg   %ax,%ax
  8029de:	66 90                	xchg   %ax,%ax

008029e0 <__udivdi3>:
  8029e0:	55                   	push   %ebp
  8029e1:	57                   	push   %edi
  8029e2:	56                   	push   %esi
  8029e3:	83 ec 0c             	sub    $0xc,%esp
  8029e6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8029ea:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8029ee:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8029f2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8029f6:	85 c0                	test   %eax,%eax
  8029f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8029fc:	89 ea                	mov    %ebp,%edx
  8029fe:	89 0c 24             	mov    %ecx,(%esp)
  802a01:	75 2d                	jne    802a30 <__udivdi3+0x50>
  802a03:	39 e9                	cmp    %ebp,%ecx
  802a05:	77 61                	ja     802a68 <__udivdi3+0x88>
  802a07:	85 c9                	test   %ecx,%ecx
  802a09:	89 ce                	mov    %ecx,%esi
  802a0b:	75 0b                	jne    802a18 <__udivdi3+0x38>
  802a0d:	b8 01 00 00 00       	mov    $0x1,%eax
  802a12:	31 d2                	xor    %edx,%edx
  802a14:	f7 f1                	div    %ecx
  802a16:	89 c6                	mov    %eax,%esi
  802a18:	31 d2                	xor    %edx,%edx
  802a1a:	89 e8                	mov    %ebp,%eax
  802a1c:	f7 f6                	div    %esi
  802a1e:	89 c5                	mov    %eax,%ebp
  802a20:	89 f8                	mov    %edi,%eax
  802a22:	f7 f6                	div    %esi
  802a24:	89 ea                	mov    %ebp,%edx
  802a26:	83 c4 0c             	add    $0xc,%esp
  802a29:	5e                   	pop    %esi
  802a2a:	5f                   	pop    %edi
  802a2b:	5d                   	pop    %ebp
  802a2c:	c3                   	ret    
  802a2d:	8d 76 00             	lea    0x0(%esi),%esi
  802a30:	39 e8                	cmp    %ebp,%eax
  802a32:	77 24                	ja     802a58 <__udivdi3+0x78>
  802a34:	0f bd e8             	bsr    %eax,%ebp
  802a37:	83 f5 1f             	xor    $0x1f,%ebp
  802a3a:	75 3c                	jne    802a78 <__udivdi3+0x98>
  802a3c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802a40:	39 34 24             	cmp    %esi,(%esp)
  802a43:	0f 86 9f 00 00 00    	jbe    802ae8 <__udivdi3+0x108>
  802a49:	39 d0                	cmp    %edx,%eax
  802a4b:	0f 82 97 00 00 00    	jb     802ae8 <__udivdi3+0x108>
  802a51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a58:	31 d2                	xor    %edx,%edx
  802a5a:	31 c0                	xor    %eax,%eax
  802a5c:	83 c4 0c             	add    $0xc,%esp
  802a5f:	5e                   	pop    %esi
  802a60:	5f                   	pop    %edi
  802a61:	5d                   	pop    %ebp
  802a62:	c3                   	ret    
  802a63:	90                   	nop
  802a64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a68:	89 f8                	mov    %edi,%eax
  802a6a:	f7 f1                	div    %ecx
  802a6c:	31 d2                	xor    %edx,%edx
  802a6e:	83 c4 0c             	add    $0xc,%esp
  802a71:	5e                   	pop    %esi
  802a72:	5f                   	pop    %edi
  802a73:	5d                   	pop    %ebp
  802a74:	c3                   	ret    
  802a75:	8d 76 00             	lea    0x0(%esi),%esi
  802a78:	89 e9                	mov    %ebp,%ecx
  802a7a:	8b 3c 24             	mov    (%esp),%edi
  802a7d:	d3 e0                	shl    %cl,%eax
  802a7f:	89 c6                	mov    %eax,%esi
  802a81:	b8 20 00 00 00       	mov    $0x20,%eax
  802a86:	29 e8                	sub    %ebp,%eax
  802a88:	89 c1                	mov    %eax,%ecx
  802a8a:	d3 ef                	shr    %cl,%edi
  802a8c:	89 e9                	mov    %ebp,%ecx
  802a8e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802a92:	8b 3c 24             	mov    (%esp),%edi
  802a95:	09 74 24 08          	or     %esi,0x8(%esp)
  802a99:	89 d6                	mov    %edx,%esi
  802a9b:	d3 e7                	shl    %cl,%edi
  802a9d:	89 c1                	mov    %eax,%ecx
  802a9f:	89 3c 24             	mov    %edi,(%esp)
  802aa2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802aa6:	d3 ee                	shr    %cl,%esi
  802aa8:	89 e9                	mov    %ebp,%ecx
  802aaa:	d3 e2                	shl    %cl,%edx
  802aac:	89 c1                	mov    %eax,%ecx
  802aae:	d3 ef                	shr    %cl,%edi
  802ab0:	09 d7                	or     %edx,%edi
  802ab2:	89 f2                	mov    %esi,%edx
  802ab4:	89 f8                	mov    %edi,%eax
  802ab6:	f7 74 24 08          	divl   0x8(%esp)
  802aba:	89 d6                	mov    %edx,%esi
  802abc:	89 c7                	mov    %eax,%edi
  802abe:	f7 24 24             	mull   (%esp)
  802ac1:	39 d6                	cmp    %edx,%esi
  802ac3:	89 14 24             	mov    %edx,(%esp)
  802ac6:	72 30                	jb     802af8 <__udivdi3+0x118>
  802ac8:	8b 54 24 04          	mov    0x4(%esp),%edx
  802acc:	89 e9                	mov    %ebp,%ecx
  802ace:	d3 e2                	shl    %cl,%edx
  802ad0:	39 c2                	cmp    %eax,%edx
  802ad2:	73 05                	jae    802ad9 <__udivdi3+0xf9>
  802ad4:	3b 34 24             	cmp    (%esp),%esi
  802ad7:	74 1f                	je     802af8 <__udivdi3+0x118>
  802ad9:	89 f8                	mov    %edi,%eax
  802adb:	31 d2                	xor    %edx,%edx
  802add:	e9 7a ff ff ff       	jmp    802a5c <__udivdi3+0x7c>
  802ae2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802ae8:	31 d2                	xor    %edx,%edx
  802aea:	b8 01 00 00 00       	mov    $0x1,%eax
  802aef:	e9 68 ff ff ff       	jmp    802a5c <__udivdi3+0x7c>
  802af4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802af8:	8d 47 ff             	lea    -0x1(%edi),%eax
  802afb:	31 d2                	xor    %edx,%edx
  802afd:	83 c4 0c             	add    $0xc,%esp
  802b00:	5e                   	pop    %esi
  802b01:	5f                   	pop    %edi
  802b02:	5d                   	pop    %ebp
  802b03:	c3                   	ret    
  802b04:	66 90                	xchg   %ax,%ax
  802b06:	66 90                	xchg   %ax,%ax
  802b08:	66 90                	xchg   %ax,%ax
  802b0a:	66 90                	xchg   %ax,%ax
  802b0c:	66 90                	xchg   %ax,%ax
  802b0e:	66 90                	xchg   %ax,%ax

00802b10 <__umoddi3>:
  802b10:	55                   	push   %ebp
  802b11:	57                   	push   %edi
  802b12:	56                   	push   %esi
  802b13:	83 ec 14             	sub    $0x14,%esp
  802b16:	8b 44 24 28          	mov    0x28(%esp),%eax
  802b1a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802b1e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802b22:	89 c7                	mov    %eax,%edi
  802b24:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b28:	8b 44 24 30          	mov    0x30(%esp),%eax
  802b2c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802b30:	89 34 24             	mov    %esi,(%esp)
  802b33:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802b37:	85 c0                	test   %eax,%eax
  802b39:	89 c2                	mov    %eax,%edx
  802b3b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802b3f:	75 17                	jne    802b58 <__umoddi3+0x48>
  802b41:	39 fe                	cmp    %edi,%esi
  802b43:	76 4b                	jbe    802b90 <__umoddi3+0x80>
  802b45:	89 c8                	mov    %ecx,%eax
  802b47:	89 fa                	mov    %edi,%edx
  802b49:	f7 f6                	div    %esi
  802b4b:	89 d0                	mov    %edx,%eax
  802b4d:	31 d2                	xor    %edx,%edx
  802b4f:	83 c4 14             	add    $0x14,%esp
  802b52:	5e                   	pop    %esi
  802b53:	5f                   	pop    %edi
  802b54:	5d                   	pop    %ebp
  802b55:	c3                   	ret    
  802b56:	66 90                	xchg   %ax,%ax
  802b58:	39 f8                	cmp    %edi,%eax
  802b5a:	77 54                	ja     802bb0 <__umoddi3+0xa0>
  802b5c:	0f bd e8             	bsr    %eax,%ebp
  802b5f:	83 f5 1f             	xor    $0x1f,%ebp
  802b62:	75 5c                	jne    802bc0 <__umoddi3+0xb0>
  802b64:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802b68:	39 3c 24             	cmp    %edi,(%esp)
  802b6b:	0f 87 e7 00 00 00    	ja     802c58 <__umoddi3+0x148>
  802b71:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802b75:	29 f1                	sub    %esi,%ecx
  802b77:	19 c7                	sbb    %eax,%edi
  802b79:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802b7d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802b81:	8b 44 24 08          	mov    0x8(%esp),%eax
  802b85:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802b89:	83 c4 14             	add    $0x14,%esp
  802b8c:	5e                   	pop    %esi
  802b8d:	5f                   	pop    %edi
  802b8e:	5d                   	pop    %ebp
  802b8f:	c3                   	ret    
  802b90:	85 f6                	test   %esi,%esi
  802b92:	89 f5                	mov    %esi,%ebp
  802b94:	75 0b                	jne    802ba1 <__umoddi3+0x91>
  802b96:	b8 01 00 00 00       	mov    $0x1,%eax
  802b9b:	31 d2                	xor    %edx,%edx
  802b9d:	f7 f6                	div    %esi
  802b9f:	89 c5                	mov    %eax,%ebp
  802ba1:	8b 44 24 04          	mov    0x4(%esp),%eax
  802ba5:	31 d2                	xor    %edx,%edx
  802ba7:	f7 f5                	div    %ebp
  802ba9:	89 c8                	mov    %ecx,%eax
  802bab:	f7 f5                	div    %ebp
  802bad:	eb 9c                	jmp    802b4b <__umoddi3+0x3b>
  802baf:	90                   	nop
  802bb0:	89 c8                	mov    %ecx,%eax
  802bb2:	89 fa                	mov    %edi,%edx
  802bb4:	83 c4 14             	add    $0x14,%esp
  802bb7:	5e                   	pop    %esi
  802bb8:	5f                   	pop    %edi
  802bb9:	5d                   	pop    %ebp
  802bba:	c3                   	ret    
  802bbb:	90                   	nop
  802bbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802bc0:	8b 04 24             	mov    (%esp),%eax
  802bc3:	be 20 00 00 00       	mov    $0x20,%esi
  802bc8:	89 e9                	mov    %ebp,%ecx
  802bca:	29 ee                	sub    %ebp,%esi
  802bcc:	d3 e2                	shl    %cl,%edx
  802bce:	89 f1                	mov    %esi,%ecx
  802bd0:	d3 e8                	shr    %cl,%eax
  802bd2:	89 e9                	mov    %ebp,%ecx
  802bd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  802bd8:	8b 04 24             	mov    (%esp),%eax
  802bdb:	09 54 24 04          	or     %edx,0x4(%esp)
  802bdf:	89 fa                	mov    %edi,%edx
  802be1:	d3 e0                	shl    %cl,%eax
  802be3:	89 f1                	mov    %esi,%ecx
  802be5:	89 44 24 08          	mov    %eax,0x8(%esp)
  802be9:	8b 44 24 10          	mov    0x10(%esp),%eax
  802bed:	d3 ea                	shr    %cl,%edx
  802bef:	89 e9                	mov    %ebp,%ecx
  802bf1:	d3 e7                	shl    %cl,%edi
  802bf3:	89 f1                	mov    %esi,%ecx
  802bf5:	d3 e8                	shr    %cl,%eax
  802bf7:	89 e9                	mov    %ebp,%ecx
  802bf9:	09 f8                	or     %edi,%eax
  802bfb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  802bff:	f7 74 24 04          	divl   0x4(%esp)
  802c03:	d3 e7                	shl    %cl,%edi
  802c05:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802c09:	89 d7                	mov    %edx,%edi
  802c0b:	f7 64 24 08          	mull   0x8(%esp)
  802c0f:	39 d7                	cmp    %edx,%edi
  802c11:	89 c1                	mov    %eax,%ecx
  802c13:	89 14 24             	mov    %edx,(%esp)
  802c16:	72 2c                	jb     802c44 <__umoddi3+0x134>
  802c18:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  802c1c:	72 22                	jb     802c40 <__umoddi3+0x130>
  802c1e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802c22:	29 c8                	sub    %ecx,%eax
  802c24:	19 d7                	sbb    %edx,%edi
  802c26:	89 e9                	mov    %ebp,%ecx
  802c28:	89 fa                	mov    %edi,%edx
  802c2a:	d3 e8                	shr    %cl,%eax
  802c2c:	89 f1                	mov    %esi,%ecx
  802c2e:	d3 e2                	shl    %cl,%edx
  802c30:	89 e9                	mov    %ebp,%ecx
  802c32:	d3 ef                	shr    %cl,%edi
  802c34:	09 d0                	or     %edx,%eax
  802c36:	89 fa                	mov    %edi,%edx
  802c38:	83 c4 14             	add    $0x14,%esp
  802c3b:	5e                   	pop    %esi
  802c3c:	5f                   	pop    %edi
  802c3d:	5d                   	pop    %ebp
  802c3e:	c3                   	ret    
  802c3f:	90                   	nop
  802c40:	39 d7                	cmp    %edx,%edi
  802c42:	75 da                	jne    802c1e <__umoddi3+0x10e>
  802c44:	8b 14 24             	mov    (%esp),%edx
  802c47:	89 c1                	mov    %eax,%ecx
  802c49:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  802c4d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802c51:	eb cb                	jmp    802c1e <__umoddi3+0x10e>
  802c53:	90                   	nop
  802c54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802c58:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  802c5c:	0f 82 0f ff ff ff    	jb     802b71 <__umoddi3+0x61>
  802c62:	e9 1a ff ff ff       	jmp    802b81 <__umoddi3+0x71>
