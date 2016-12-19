
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 8c 02 00 00       	call   8002bd <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 3c             	sub    $0x3c,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  80003f:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800042:	8d 7d d8             	lea    -0x28(%ebp),%edi
{
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800045:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  80004c:	00 
  80004d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800051:	89 1c 24             	mov    %ebx,(%esp)
  800054:	e8 e3 17 00 00       	call   80183c <readn>
  800059:	83 f8 04             	cmp    $0x4,%eax
  80005c:	74 2e                	je     80008c <primeproc+0x59>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  80005e:	85 c0                	test   %eax,%eax
  800060:	ba 00 00 00 00       	mov    $0x0,%edx
  800065:	0f 4e d0             	cmovle %eax,%edx
  800068:	89 54 24 10          	mov    %edx,0x10(%esp)
  80006c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800070:	c7 44 24 08 c0 2b 80 	movl   $0x802bc0,0x8(%esp)
  800077:	00 
  800078:	c7 44 24 04 15 00 00 	movl   $0x15,0x4(%esp)
  80007f:	00 
  800080:	c7 04 24 ef 2b 80 00 	movl   $0x802bef,(%esp)
  800087:	e8 92 02 00 00       	call   80031e <_panic>

	cprintf("%d\n", p);
  80008c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80008f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800093:	c7 04 24 01 2c 80 00 	movl   $0x802c01,(%esp)
  80009a:	e8 78 03 00 00       	call   800417 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  80009f:	89 3c 24             	mov    %edi,(%esp)
  8000a2:	e8 5d 23 00 00       	call   802404 <pipe>
  8000a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000aa:	85 c0                	test   %eax,%eax
  8000ac:	79 20                	jns    8000ce <primeproc+0x9b>
		panic("pipe: %e", i);
  8000ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b2:	c7 44 24 08 05 2c 80 	movl   $0x802c05,0x8(%esp)
  8000b9:	00 
  8000ba:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
  8000c1:	00 
  8000c2:	c7 04 24 ef 2b 80 00 	movl   $0x802bef,(%esp)
  8000c9:	e8 50 02 00 00       	call   80031e <_panic>
	if ((id = fork()) < 0)
  8000ce:	e8 c1 11 00 00       	call   801294 <fork>
  8000d3:	85 c0                	test   %eax,%eax
  8000d5:	79 20                	jns    8000f7 <primeproc+0xc4>
		panic("fork: %e", id);
  8000d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000db:	c7 44 24 08 0e 2c 80 	movl   $0x802c0e,0x8(%esp)
  8000e2:	00 
  8000e3:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  8000ea:	00 
  8000eb:	c7 04 24 ef 2b 80 00 	movl   $0x802bef,(%esp)
  8000f2:	e8 27 02 00 00       	call   80031e <_panic>
	if (id == 0) {
  8000f7:	85 c0                	test   %eax,%eax
  8000f9:	75 1b                	jne    800116 <primeproc+0xe3>
		close(fd);
  8000fb:	89 1c 24             	mov    %ebx,(%esp)
  8000fe:	e8 44 15 00 00       	call   801647 <close>
		close(pfd[1]);
  800103:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800106:	89 04 24             	mov    %eax,(%esp)
  800109:	e8 39 15 00 00       	call   801647 <close>
		fd = pfd[0];
  80010e:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  800111:	e9 2f ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  800116:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800119:	89 04 24             	mov    %eax,(%esp)
  80011c:	e8 26 15 00 00       	call   801647 <close>
	wfd = pfd[1];
  800121:	8b 7d dc             	mov    -0x24(%ebp),%edi

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  800124:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800127:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  80012e:	00 
  80012f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800133:	89 1c 24             	mov    %ebx,(%esp)
  800136:	e8 01 17 00 00       	call   80183c <readn>
  80013b:	83 f8 04             	cmp    $0x4,%eax
  80013e:	74 39                	je     800179 <primeproc+0x146>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800140:	85 c0                	test   %eax,%eax
  800142:	ba 00 00 00 00       	mov    $0x0,%edx
  800147:	0f 4e d0             	cmovle %eax,%edx
  80014a:	89 54 24 18          	mov    %edx,0x18(%esp)
  80014e:	89 44 24 14          	mov    %eax,0x14(%esp)
  800152:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800156:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800159:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80015d:	c7 44 24 08 17 2c 80 	movl   $0x802c17,0x8(%esp)
  800164:	00 
  800165:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  80016c:	00 
  80016d:	c7 04 24 ef 2b 80 00 	movl   $0x802bef,(%esp)
  800174:	e8 a5 01 00 00       	call   80031e <_panic>
		if (i%p)
  800179:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80017c:	99                   	cltd   
  80017d:	f7 7d e0             	idivl  -0x20(%ebp)
  800180:	85 d2                	test   %edx,%edx
  800182:	74 a3                	je     800127 <primeproc+0xf4>
			if ((r=write(wfd, &i, 4)) != 4)
  800184:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  80018b:	00 
  80018c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800190:	89 3c 24             	mov    %edi,(%esp)
  800193:	e8 ef 16 00 00       	call   801887 <write>
  800198:	83 f8 04             	cmp    $0x4,%eax
  80019b:	74 8a                	je     800127 <primeproc+0xf4>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  80019d:	85 c0                	test   %eax,%eax
  80019f:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a4:	0f 4e d0             	cmovle %eax,%edx
  8001a7:	89 54 24 14          	mov    %edx,0x14(%esp)
  8001ab:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001af:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b6:	c7 44 24 08 33 2c 80 	movl   $0x802c33,0x8(%esp)
  8001bd:	00 
  8001be:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8001c5:	00 
  8001c6:	c7 04 24 ef 2b 80 00 	movl   $0x802bef,(%esp)
  8001cd:	e8 4c 01 00 00       	call   80031e <_panic>

008001d2 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	53                   	push   %ebx
  8001d6:	83 ec 34             	sub    $0x34,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  8001d9:	c7 05 00 40 80 00 4d 	movl   $0x802c4d,0x804000
  8001e0:	2c 80 00 

	if ((i=pipe(p)) < 0)
  8001e3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8001e6:	89 04 24             	mov    %eax,(%esp)
  8001e9:	e8 16 22 00 00       	call   802404 <pipe>
  8001ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8001f1:	85 c0                	test   %eax,%eax
  8001f3:	79 20                	jns    800215 <umain+0x43>
		panic("pipe: %e", i);
  8001f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001f9:	c7 44 24 08 05 2c 80 	movl   $0x802c05,0x8(%esp)
  800200:	00 
  800201:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  800208:	00 
  800209:	c7 04 24 ef 2b 80 00 	movl   $0x802bef,(%esp)
  800210:	e8 09 01 00 00       	call   80031e <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  800215:	e8 7a 10 00 00       	call   801294 <fork>
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 20                	jns    80023e <umain+0x6c>
		panic("fork: %e", id);
  80021e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800222:	c7 44 24 08 0e 2c 80 	movl   $0x802c0e,0x8(%esp)
  800229:	00 
  80022a:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  800231:	00 
  800232:	c7 04 24 ef 2b 80 00 	movl   $0x802bef,(%esp)
  800239:	e8 e0 00 00 00       	call   80031e <_panic>

	if (id == 0) {
  80023e:	85 c0                	test   %eax,%eax
  800240:	75 16                	jne    800258 <umain+0x86>
		close(p[1]);
  800242:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800245:	89 04 24             	mov    %eax,(%esp)
  800248:	e8 fa 13 00 00       	call   801647 <close>
		primeproc(p[0]);
  80024d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800250:	89 04 24             	mov    %eax,(%esp)
  800253:	e8 db fd ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  800258:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80025b:	89 04 24             	mov    %eax,(%esp)
  80025e:	e8 e4 13 00 00       	call   801647 <close>

	// feed all the integers through
	for (i=2;; i++)
  800263:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
  80026a:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  80026d:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800274:	00 
  800275:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800279:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80027c:	89 04 24             	mov    %eax,(%esp)
  80027f:	e8 03 16 00 00       	call   801887 <write>
  800284:	83 f8 04             	cmp    $0x4,%eax
  800287:	74 2e                	je     8002b7 <umain+0xe5>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800289:	85 c0                	test   %eax,%eax
  80028b:	ba 00 00 00 00       	mov    $0x0,%edx
  800290:	0f 4e d0             	cmovle %eax,%edx
  800293:	89 54 24 10          	mov    %edx,0x10(%esp)
  800297:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80029b:	c7 44 24 08 58 2c 80 	movl   $0x802c58,0x8(%esp)
  8002a2:	00 
  8002a3:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  8002aa:	00 
  8002ab:	c7 04 24 ef 2b 80 00 	movl   $0x802bef,(%esp)
  8002b2:	e8 67 00 00 00       	call   80031e <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  8002b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
}
  8002bb:	eb b0                	jmp    80026d <umain+0x9b>

008002bd <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	83 ec 10             	sub    $0x10,%esp
  8002c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002c8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  8002cb:	e8 55 0b 00 00       	call   800e25 <sys_getenvid>
  8002d0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002d5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002d8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002dd:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002e2:	85 db                	test   %ebx,%ebx
  8002e4:	7e 07                	jle    8002ed <libmain+0x30>
		binaryname = argv[0];
  8002e6:	8b 06                	mov    (%esi),%eax
  8002e8:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  8002ed:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002f1:	89 1c 24             	mov    %ebx,(%esp)
  8002f4:	e8 d9 fe ff ff       	call   8001d2 <umain>

	// exit gracefully
	exit();
  8002f9:	e8 07 00 00 00       	call   800305 <exit>
}
  8002fe:	83 c4 10             	add    $0x10,%esp
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80030b:	e8 6a 13 00 00       	call   80167a <close_all>
	sys_env_destroy(0);
  800310:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800317:	e8 b7 0a 00 00       	call   800dd3 <sys_env_destroy>
}
  80031c:	c9                   	leave  
  80031d:	c3                   	ret    

0080031e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80031e:	55                   	push   %ebp
  80031f:	89 e5                	mov    %esp,%ebp
  800321:	56                   	push   %esi
  800322:	53                   	push   %ebx
  800323:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800326:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800329:	8b 35 00 40 80 00    	mov    0x804000,%esi
  80032f:	e8 f1 0a 00 00       	call   800e25 <sys_getenvid>
  800334:	8b 55 0c             	mov    0xc(%ebp),%edx
  800337:	89 54 24 10          	mov    %edx,0x10(%esp)
  80033b:	8b 55 08             	mov    0x8(%ebp),%edx
  80033e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800342:	89 74 24 08          	mov    %esi,0x8(%esp)
  800346:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034a:	c7 04 24 7c 2c 80 00 	movl   $0x802c7c,(%esp)
  800351:	e8 c1 00 00 00       	call   800417 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800356:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80035a:	8b 45 10             	mov    0x10(%ebp),%eax
  80035d:	89 04 24             	mov    %eax,(%esp)
  800360:	e8 51 00 00 00       	call   8003b6 <vcprintf>
	cprintf("\n");
  800365:	c7 04 24 03 2c 80 00 	movl   $0x802c03,(%esp)
  80036c:	e8 a6 00 00 00       	call   800417 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800371:	cc                   	int3   
  800372:	eb fd                	jmp    800371 <_panic+0x53>

00800374 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
  800377:	53                   	push   %ebx
  800378:	83 ec 14             	sub    $0x14,%esp
  80037b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80037e:	8b 13                	mov    (%ebx),%edx
  800380:	8d 42 01             	lea    0x1(%edx),%eax
  800383:	89 03                	mov    %eax,(%ebx)
  800385:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800388:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80038c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800391:	75 19                	jne    8003ac <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800393:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80039a:	00 
  80039b:	8d 43 08             	lea    0x8(%ebx),%eax
  80039e:	89 04 24             	mov    %eax,(%esp)
  8003a1:	e8 f0 09 00 00       	call   800d96 <sys_cputs>
		b->idx = 0;
  8003a6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003ac:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003b0:	83 c4 14             	add    $0x14,%esp
  8003b3:	5b                   	pop    %ebx
  8003b4:	5d                   	pop    %ebp
  8003b5:	c3                   	ret    

008003b6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
  8003b9:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8003bf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003c6:	00 00 00 
	b.cnt = 0;
  8003c9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003d0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003da:	8b 45 08             	mov    0x8(%ebp),%eax
  8003dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003eb:	c7 04 24 74 03 80 00 	movl   $0x800374,(%esp)
  8003f2:	e8 b7 01 00 00       	call   8005ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003f7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8003fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800401:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800407:	89 04 24             	mov    %eax,(%esp)
  80040a:	e8 87 09 00 00       	call   800d96 <sys_cputs>

	return b.cnt;
}
  80040f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800415:	c9                   	leave  
  800416:	c3                   	ret    

00800417 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80041d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800420:	89 44 24 04          	mov    %eax,0x4(%esp)
  800424:	8b 45 08             	mov    0x8(%ebp),%eax
  800427:	89 04 24             	mov    %eax,(%esp)
  80042a:	e8 87 ff ff ff       	call   8003b6 <vcprintf>
	va_end(ap);

	return cnt;
}
  80042f:	c9                   	leave  
  800430:	c3                   	ret    
  800431:	66 90                	xchg   %ax,%ax
  800433:	66 90                	xchg   %ax,%ax
  800435:	66 90                	xchg   %ax,%ax
  800437:	66 90                	xchg   %ax,%ax
  800439:	66 90                	xchg   %ax,%ax
  80043b:	66 90                	xchg   %ax,%ax
  80043d:	66 90                	xchg   %ax,%ax
  80043f:	90                   	nop

00800440 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800440:	55                   	push   %ebp
  800441:	89 e5                	mov    %esp,%ebp
  800443:	57                   	push   %edi
  800444:	56                   	push   %esi
  800445:	53                   	push   %ebx
  800446:	83 ec 3c             	sub    $0x3c,%esp
  800449:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80044c:	89 d7                	mov    %edx,%edi
  80044e:	8b 45 08             	mov    0x8(%ebp),%eax
  800451:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800454:	8b 45 0c             	mov    0xc(%ebp),%eax
  800457:	89 c3                	mov    %eax,%ebx
  800459:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80045c:	8b 45 10             	mov    0x10(%ebp),%eax
  80045f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800462:	b9 00 00 00 00       	mov    $0x0,%ecx
  800467:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80046a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80046d:	39 d9                	cmp    %ebx,%ecx
  80046f:	72 05                	jb     800476 <printnum+0x36>
  800471:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800474:	77 69                	ja     8004df <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800476:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800479:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80047d:	83 ee 01             	sub    $0x1,%esi
  800480:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800484:	89 44 24 08          	mov    %eax,0x8(%esp)
  800488:	8b 44 24 08          	mov    0x8(%esp),%eax
  80048c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800490:	89 c3                	mov    %eax,%ebx
  800492:	89 d6                	mov    %edx,%esi
  800494:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800497:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80049a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80049e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8004a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a5:	89 04 24             	mov    %eax,(%esp)
  8004a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004af:	e8 7c 24 00 00       	call   802930 <__udivdi3>
  8004b4:	89 d9                	mov    %ebx,%ecx
  8004b6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8004ba:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004be:	89 04 24             	mov    %eax,(%esp)
  8004c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004c5:	89 fa                	mov    %edi,%edx
  8004c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004ca:	e8 71 ff ff ff       	call   800440 <printnum>
  8004cf:	eb 1b                	jmp    8004ec <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004d5:	8b 45 18             	mov    0x18(%ebp),%eax
  8004d8:	89 04 24             	mov    %eax,(%esp)
  8004db:	ff d3                	call   *%ebx
  8004dd:	eb 03                	jmp    8004e2 <printnum+0xa2>
  8004df:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004e2:	83 ee 01             	sub    $0x1,%esi
  8004e5:	85 f6                	test   %esi,%esi
  8004e7:	7f e8                	jg     8004d1 <printnum+0x91>
  8004e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004f0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004f7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8004fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004fe:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800502:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800505:	89 04 24             	mov    %eax,(%esp)
  800508:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80050b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050f:	e8 4c 25 00 00       	call   802a60 <__umoddi3>
  800514:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800518:	0f be 80 9f 2c 80 00 	movsbl 0x802c9f(%eax),%eax
  80051f:	89 04 24             	mov    %eax,(%esp)
  800522:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800525:	ff d0                	call   *%eax
}
  800527:	83 c4 3c             	add    $0x3c,%esp
  80052a:	5b                   	pop    %ebx
  80052b:	5e                   	pop    %esi
  80052c:	5f                   	pop    %edi
  80052d:	5d                   	pop    %ebp
  80052e:	c3                   	ret    

0080052f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80052f:	55                   	push   %ebp
  800530:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800532:	83 fa 01             	cmp    $0x1,%edx
  800535:	7e 0e                	jle    800545 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800537:	8b 10                	mov    (%eax),%edx
  800539:	8d 4a 08             	lea    0x8(%edx),%ecx
  80053c:	89 08                	mov    %ecx,(%eax)
  80053e:	8b 02                	mov    (%edx),%eax
  800540:	8b 52 04             	mov    0x4(%edx),%edx
  800543:	eb 22                	jmp    800567 <getuint+0x38>
	else if (lflag)
  800545:	85 d2                	test   %edx,%edx
  800547:	74 10                	je     800559 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800549:	8b 10                	mov    (%eax),%edx
  80054b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80054e:	89 08                	mov    %ecx,(%eax)
  800550:	8b 02                	mov    (%edx),%eax
  800552:	ba 00 00 00 00       	mov    $0x0,%edx
  800557:	eb 0e                	jmp    800567 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800559:	8b 10                	mov    (%eax),%edx
  80055b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80055e:	89 08                	mov    %ecx,(%eax)
  800560:	8b 02                	mov    (%edx),%eax
  800562:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800567:	5d                   	pop    %ebp
  800568:	c3                   	ret    

00800569 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800569:	55                   	push   %ebp
  80056a:	89 e5                	mov    %esp,%ebp
  80056c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80056f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800573:	8b 10                	mov    (%eax),%edx
  800575:	3b 50 04             	cmp    0x4(%eax),%edx
  800578:	73 0a                	jae    800584 <sprintputch+0x1b>
		*b->buf++ = ch;
  80057a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80057d:	89 08                	mov    %ecx,(%eax)
  80057f:	8b 45 08             	mov    0x8(%ebp),%eax
  800582:	88 02                	mov    %al,(%edx)
}
  800584:	5d                   	pop    %ebp
  800585:	c3                   	ret    

00800586 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800586:	55                   	push   %ebp
  800587:	89 e5                	mov    %esp,%ebp
  800589:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80058c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80058f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800593:	8b 45 10             	mov    0x10(%ebp),%eax
  800596:	89 44 24 08          	mov    %eax,0x8(%esp)
  80059a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80059d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a4:	89 04 24             	mov    %eax,(%esp)
  8005a7:	e8 02 00 00 00       	call   8005ae <vprintfmt>
	va_end(ap);
}
  8005ac:	c9                   	leave  
  8005ad:	c3                   	ret    

008005ae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005ae:	55                   	push   %ebp
  8005af:	89 e5                	mov    %esp,%ebp
  8005b1:	57                   	push   %edi
  8005b2:	56                   	push   %esi
  8005b3:	53                   	push   %ebx
  8005b4:	83 ec 3c             	sub    $0x3c,%esp
  8005b7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005bd:	eb 14                	jmp    8005d3 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005bf:	85 c0                	test   %eax,%eax
  8005c1:	0f 84 b3 03 00 00    	je     80097a <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  8005c7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005cb:	89 04 24             	mov    %eax,(%esp)
  8005ce:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005d1:	89 f3                	mov    %esi,%ebx
  8005d3:	8d 73 01             	lea    0x1(%ebx),%esi
  8005d6:	0f b6 03             	movzbl (%ebx),%eax
  8005d9:	83 f8 25             	cmp    $0x25,%eax
  8005dc:	75 e1                	jne    8005bf <vprintfmt+0x11>
  8005de:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8005e2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8005e9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8005f0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8005f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8005fc:	eb 1d                	jmp    80061b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fe:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800600:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800604:	eb 15                	jmp    80061b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800606:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800608:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80060c:	eb 0d                	jmp    80061b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80060e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800611:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800614:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80061e:	0f b6 0e             	movzbl (%esi),%ecx
  800621:	0f b6 c1             	movzbl %cl,%eax
  800624:	83 e9 23             	sub    $0x23,%ecx
  800627:	80 f9 55             	cmp    $0x55,%cl
  80062a:	0f 87 2a 03 00 00    	ja     80095a <vprintfmt+0x3ac>
  800630:	0f b6 c9             	movzbl %cl,%ecx
  800633:	ff 24 8d e0 2d 80 00 	jmp    *0x802de0(,%ecx,4)
  80063a:	89 de                	mov    %ebx,%esi
  80063c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800641:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800644:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800648:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80064b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80064e:	83 fb 09             	cmp    $0x9,%ebx
  800651:	77 36                	ja     800689 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800653:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800656:	eb e9                	jmp    800641 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8d 48 04             	lea    0x4(%eax),%ecx
  80065e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800661:	8b 00                	mov    (%eax),%eax
  800663:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800666:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800668:	eb 22                	jmp    80068c <vprintfmt+0xde>
  80066a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80066d:	85 c9                	test   %ecx,%ecx
  80066f:	b8 00 00 00 00       	mov    $0x0,%eax
  800674:	0f 49 c1             	cmovns %ecx,%eax
  800677:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067a:	89 de                	mov    %ebx,%esi
  80067c:	eb 9d                	jmp    80061b <vprintfmt+0x6d>
  80067e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800680:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800687:	eb 92                	jmp    80061b <vprintfmt+0x6d>
  800689:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80068c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800690:	79 89                	jns    80061b <vprintfmt+0x6d>
  800692:	e9 77 ff ff ff       	jmp    80060e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800697:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069a:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80069c:	e9 7a ff ff ff       	jmp    80061b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a4:	8d 50 04             	lea    0x4(%eax),%edx
  8006a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ae:	8b 00                	mov    (%eax),%eax
  8006b0:	89 04 24             	mov    %eax,(%esp)
  8006b3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006b6:	e9 18 ff ff ff       	jmp    8005d3 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006be:	8d 50 04             	lea    0x4(%eax),%edx
  8006c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c4:	8b 00                	mov    (%eax),%eax
  8006c6:	99                   	cltd   
  8006c7:	31 d0                	xor    %edx,%eax
  8006c9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006cb:	83 f8 0f             	cmp    $0xf,%eax
  8006ce:	7f 0b                	jg     8006db <vprintfmt+0x12d>
  8006d0:	8b 14 85 40 2f 80 00 	mov    0x802f40(,%eax,4),%edx
  8006d7:	85 d2                	test   %edx,%edx
  8006d9:	75 20                	jne    8006fb <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  8006db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006df:	c7 44 24 08 b7 2c 80 	movl   $0x802cb7,0x8(%esp)
  8006e6:	00 
  8006e7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ee:	89 04 24             	mov    %eax,(%esp)
  8006f1:	e8 90 fe ff ff       	call   800586 <printfmt>
  8006f6:	e9 d8 fe ff ff       	jmp    8005d3 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8006fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006ff:	c7 44 24 08 ed 30 80 	movl   $0x8030ed,0x8(%esp)
  800706:	00 
  800707:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80070b:	8b 45 08             	mov    0x8(%ebp),%eax
  80070e:	89 04 24             	mov    %eax,(%esp)
  800711:	e8 70 fe ff ff       	call   800586 <printfmt>
  800716:	e9 b8 fe ff ff       	jmp    8005d3 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80071e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800721:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800724:	8b 45 14             	mov    0x14(%ebp),%eax
  800727:	8d 50 04             	lea    0x4(%eax),%edx
  80072a:	89 55 14             	mov    %edx,0x14(%ebp)
  80072d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80072f:	85 f6                	test   %esi,%esi
  800731:	b8 b0 2c 80 00       	mov    $0x802cb0,%eax
  800736:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800739:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80073d:	0f 84 97 00 00 00    	je     8007da <vprintfmt+0x22c>
  800743:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800747:	0f 8e 9b 00 00 00    	jle    8007e8 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80074d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800751:	89 34 24             	mov    %esi,(%esp)
  800754:	e8 cf 02 00 00       	call   800a28 <strnlen>
  800759:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80075c:	29 c2                	sub    %eax,%edx
  80075e:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800761:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800765:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800768:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80076b:	8b 75 08             	mov    0x8(%ebp),%esi
  80076e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800771:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800773:	eb 0f                	jmp    800784 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800775:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800779:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80077c:	89 04 24             	mov    %eax,(%esp)
  80077f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800781:	83 eb 01             	sub    $0x1,%ebx
  800784:	85 db                	test   %ebx,%ebx
  800786:	7f ed                	jg     800775 <vprintfmt+0x1c7>
  800788:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80078b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80078e:	85 d2                	test   %edx,%edx
  800790:	b8 00 00 00 00       	mov    $0x0,%eax
  800795:	0f 49 c2             	cmovns %edx,%eax
  800798:	29 c2                	sub    %eax,%edx
  80079a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80079d:	89 d7                	mov    %edx,%edi
  80079f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8007a2:	eb 50                	jmp    8007f4 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007a8:	74 1e                	je     8007c8 <vprintfmt+0x21a>
  8007aa:	0f be d2             	movsbl %dl,%edx
  8007ad:	83 ea 20             	sub    $0x20,%edx
  8007b0:	83 fa 5e             	cmp    $0x5e,%edx
  8007b3:	76 13                	jbe    8007c8 <vprintfmt+0x21a>
					putch('?', putdat);
  8007b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007bc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007c3:	ff 55 08             	call   *0x8(%ebp)
  8007c6:	eb 0d                	jmp    8007d5 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8007c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007cb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007cf:	89 04 24             	mov    %eax,(%esp)
  8007d2:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007d5:	83 ef 01             	sub    $0x1,%edi
  8007d8:	eb 1a                	jmp    8007f4 <vprintfmt+0x246>
  8007da:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8007dd:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8007e0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8007e3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8007e6:	eb 0c                	jmp    8007f4 <vprintfmt+0x246>
  8007e8:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8007eb:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8007ee:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8007f1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8007f4:	83 c6 01             	add    $0x1,%esi
  8007f7:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  8007fb:	0f be c2             	movsbl %dl,%eax
  8007fe:	85 c0                	test   %eax,%eax
  800800:	74 27                	je     800829 <vprintfmt+0x27b>
  800802:	85 db                	test   %ebx,%ebx
  800804:	78 9e                	js     8007a4 <vprintfmt+0x1f6>
  800806:	83 eb 01             	sub    $0x1,%ebx
  800809:	79 99                	jns    8007a4 <vprintfmt+0x1f6>
  80080b:	89 f8                	mov    %edi,%eax
  80080d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800810:	8b 75 08             	mov    0x8(%ebp),%esi
  800813:	89 c3                	mov    %eax,%ebx
  800815:	eb 1a                	jmp    800831 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800817:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80081b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800822:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800824:	83 eb 01             	sub    $0x1,%ebx
  800827:	eb 08                	jmp    800831 <vprintfmt+0x283>
  800829:	89 fb                	mov    %edi,%ebx
  80082b:	8b 75 08             	mov    0x8(%ebp),%esi
  80082e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800831:	85 db                	test   %ebx,%ebx
  800833:	7f e2                	jg     800817 <vprintfmt+0x269>
  800835:	89 75 08             	mov    %esi,0x8(%ebp)
  800838:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80083b:	e9 93 fd ff ff       	jmp    8005d3 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800840:	83 fa 01             	cmp    $0x1,%edx
  800843:	7e 16                	jle    80085b <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800845:	8b 45 14             	mov    0x14(%ebp),%eax
  800848:	8d 50 08             	lea    0x8(%eax),%edx
  80084b:	89 55 14             	mov    %edx,0x14(%ebp)
  80084e:	8b 50 04             	mov    0x4(%eax),%edx
  800851:	8b 00                	mov    (%eax),%eax
  800853:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800856:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800859:	eb 32                	jmp    80088d <vprintfmt+0x2df>
	else if (lflag)
  80085b:	85 d2                	test   %edx,%edx
  80085d:	74 18                	je     800877 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  80085f:	8b 45 14             	mov    0x14(%ebp),%eax
  800862:	8d 50 04             	lea    0x4(%eax),%edx
  800865:	89 55 14             	mov    %edx,0x14(%ebp)
  800868:	8b 30                	mov    (%eax),%esi
  80086a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80086d:	89 f0                	mov    %esi,%eax
  80086f:	c1 f8 1f             	sar    $0x1f,%eax
  800872:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800875:	eb 16                	jmp    80088d <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800877:	8b 45 14             	mov    0x14(%ebp),%eax
  80087a:	8d 50 04             	lea    0x4(%eax),%edx
  80087d:	89 55 14             	mov    %edx,0x14(%ebp)
  800880:	8b 30                	mov    (%eax),%esi
  800882:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800885:	89 f0                	mov    %esi,%eax
  800887:	c1 f8 1f             	sar    $0x1f,%eax
  80088a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80088d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800890:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800893:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800898:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80089c:	0f 89 80 00 00 00    	jns    800922 <vprintfmt+0x374>
				putch('-', putdat);
  8008a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008a6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008ad:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008b3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008b6:	f7 d8                	neg    %eax
  8008b8:	83 d2 00             	adc    $0x0,%edx
  8008bb:	f7 da                	neg    %edx
			}
			base = 10;
  8008bd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008c2:	eb 5e                	jmp    800922 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008c4:	8d 45 14             	lea    0x14(%ebp),%eax
  8008c7:	e8 63 fc ff ff       	call   80052f <getuint>
			base = 10;
  8008cc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8008d1:	eb 4f                	jmp    800922 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8008d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8008d6:	e8 54 fc ff ff       	call   80052f <getuint>
			base = 8;
  8008db:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8008e0:	eb 40                	jmp    800922 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  8008e2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008e6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008ed:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008f0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008f4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008fb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800901:	8d 50 04             	lea    0x4(%eax),%edx
  800904:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800907:	8b 00                	mov    (%eax),%eax
  800909:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80090e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800913:	eb 0d                	jmp    800922 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800915:	8d 45 14             	lea    0x14(%ebp),%eax
  800918:	e8 12 fc ff ff       	call   80052f <getuint>
			base = 16;
  80091d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800922:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800926:	89 74 24 10          	mov    %esi,0x10(%esp)
  80092a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80092d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800931:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800935:	89 04 24             	mov    %eax,(%esp)
  800938:	89 54 24 04          	mov    %edx,0x4(%esp)
  80093c:	89 fa                	mov    %edi,%edx
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	e8 fa fa ff ff       	call   800440 <printnum>
			break;
  800946:	e9 88 fc ff ff       	jmp    8005d3 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80094b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80094f:	89 04 24             	mov    %eax,(%esp)
  800952:	ff 55 08             	call   *0x8(%ebp)
			break;
  800955:	e9 79 fc ff ff       	jmp    8005d3 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80095a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80095e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800965:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800968:	89 f3                	mov    %esi,%ebx
  80096a:	eb 03                	jmp    80096f <vprintfmt+0x3c1>
  80096c:	83 eb 01             	sub    $0x1,%ebx
  80096f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800973:	75 f7                	jne    80096c <vprintfmt+0x3be>
  800975:	e9 59 fc ff ff       	jmp    8005d3 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  80097a:	83 c4 3c             	add    $0x3c,%esp
  80097d:	5b                   	pop    %ebx
  80097e:	5e                   	pop    %esi
  80097f:	5f                   	pop    %edi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	83 ec 28             	sub    $0x28,%esp
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80098e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800991:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800995:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800998:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80099f:	85 c0                	test   %eax,%eax
  8009a1:	74 30                	je     8009d3 <vsnprintf+0x51>
  8009a3:	85 d2                	test   %edx,%edx
  8009a5:	7e 2c                	jle    8009d3 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8009b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009b5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009bc:	c7 04 24 69 05 80 00 	movl   $0x800569,(%esp)
  8009c3:	e8 e6 fb ff ff       	call   8005ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009cb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009d1:	eb 05                	jmp    8009d8 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009d8:	c9                   	leave  
  8009d9:	c3                   	ret    

008009da <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009e0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009e7:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f8:	89 04 24             	mov    %eax,(%esp)
  8009fb:	e8 82 ff ff ff       	call   800982 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a00:	c9                   	leave  
  800a01:	c3                   	ret    
  800a02:	66 90                	xchg   %ax,%ax
  800a04:	66 90                	xchg   %ax,%ax
  800a06:	66 90                	xchg   %ax,%ax
  800a08:	66 90                	xchg   %ax,%ax
  800a0a:	66 90                	xchg   %ax,%ax
  800a0c:	66 90                	xchg   %ax,%ax
  800a0e:	66 90                	xchg   %ax,%ax

00800a10 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a16:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1b:	eb 03                	jmp    800a20 <strlen+0x10>
		n++;
  800a1d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a20:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a24:	75 f7                	jne    800a1d <strlen+0xd>
		n++;
	return n;
}
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    

00800a28 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a31:	b8 00 00 00 00       	mov    $0x0,%eax
  800a36:	eb 03                	jmp    800a3b <strnlen+0x13>
		n++;
  800a38:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a3b:	39 d0                	cmp    %edx,%eax
  800a3d:	74 06                	je     800a45 <strnlen+0x1d>
  800a3f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a43:	75 f3                	jne    800a38 <strnlen+0x10>
		n++;
	return n;
}
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	53                   	push   %ebx
  800a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a51:	89 c2                	mov    %eax,%edx
  800a53:	83 c2 01             	add    $0x1,%edx
  800a56:	83 c1 01             	add    $0x1,%ecx
  800a59:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a5d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a60:	84 db                	test   %bl,%bl
  800a62:	75 ef                	jne    800a53 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a64:	5b                   	pop    %ebx
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	53                   	push   %ebx
  800a6b:	83 ec 08             	sub    $0x8,%esp
  800a6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a71:	89 1c 24             	mov    %ebx,(%esp)
  800a74:	e8 97 ff ff ff       	call   800a10 <strlen>
	strcpy(dst + len, src);
  800a79:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a80:	01 d8                	add    %ebx,%eax
  800a82:	89 04 24             	mov    %eax,(%esp)
  800a85:	e8 bd ff ff ff       	call   800a47 <strcpy>
	return dst;
}
  800a8a:	89 d8                	mov    %ebx,%eax
  800a8c:	83 c4 08             	add    $0x8,%esp
  800a8f:	5b                   	pop    %ebx
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	56                   	push   %esi
  800a96:	53                   	push   %ebx
  800a97:	8b 75 08             	mov    0x8(%ebp),%esi
  800a9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a9d:	89 f3                	mov    %esi,%ebx
  800a9f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa2:	89 f2                	mov    %esi,%edx
  800aa4:	eb 0f                	jmp    800ab5 <strncpy+0x23>
		*dst++ = *src;
  800aa6:	83 c2 01             	add    $0x1,%edx
  800aa9:	0f b6 01             	movzbl (%ecx),%eax
  800aac:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aaf:	80 39 01             	cmpb   $0x1,(%ecx)
  800ab2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ab5:	39 da                	cmp    %ebx,%edx
  800ab7:	75 ed                	jne    800aa6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ab9:	89 f0                	mov    %esi,%eax
  800abb:	5b                   	pop    %ebx
  800abc:	5e                   	pop    %esi
  800abd:	5d                   	pop    %ebp
  800abe:	c3                   	ret    

00800abf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
  800ac4:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aca:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800acd:	89 f0                	mov    %esi,%eax
  800acf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ad3:	85 c9                	test   %ecx,%ecx
  800ad5:	75 0b                	jne    800ae2 <strlcpy+0x23>
  800ad7:	eb 1d                	jmp    800af6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ad9:	83 c0 01             	add    $0x1,%eax
  800adc:	83 c2 01             	add    $0x1,%edx
  800adf:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ae2:	39 d8                	cmp    %ebx,%eax
  800ae4:	74 0b                	je     800af1 <strlcpy+0x32>
  800ae6:	0f b6 0a             	movzbl (%edx),%ecx
  800ae9:	84 c9                	test   %cl,%cl
  800aeb:	75 ec                	jne    800ad9 <strlcpy+0x1a>
  800aed:	89 c2                	mov    %eax,%edx
  800aef:	eb 02                	jmp    800af3 <strlcpy+0x34>
  800af1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800af3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800af6:	29 f0                	sub    %esi,%eax
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b02:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b05:	eb 06                	jmp    800b0d <strcmp+0x11>
		p++, q++;
  800b07:	83 c1 01             	add    $0x1,%ecx
  800b0a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b0d:	0f b6 01             	movzbl (%ecx),%eax
  800b10:	84 c0                	test   %al,%al
  800b12:	74 04                	je     800b18 <strcmp+0x1c>
  800b14:	3a 02                	cmp    (%edx),%al
  800b16:	74 ef                	je     800b07 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b18:	0f b6 c0             	movzbl %al,%eax
  800b1b:	0f b6 12             	movzbl (%edx),%edx
  800b1e:	29 d0                	sub    %edx,%eax
}
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	53                   	push   %ebx
  800b26:	8b 45 08             	mov    0x8(%ebp),%eax
  800b29:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b2c:	89 c3                	mov    %eax,%ebx
  800b2e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b31:	eb 06                	jmp    800b39 <strncmp+0x17>
		n--, p++, q++;
  800b33:	83 c0 01             	add    $0x1,%eax
  800b36:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b39:	39 d8                	cmp    %ebx,%eax
  800b3b:	74 15                	je     800b52 <strncmp+0x30>
  800b3d:	0f b6 08             	movzbl (%eax),%ecx
  800b40:	84 c9                	test   %cl,%cl
  800b42:	74 04                	je     800b48 <strncmp+0x26>
  800b44:	3a 0a                	cmp    (%edx),%cl
  800b46:	74 eb                	je     800b33 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b48:	0f b6 00             	movzbl (%eax),%eax
  800b4b:	0f b6 12             	movzbl (%edx),%edx
  800b4e:	29 d0                	sub    %edx,%eax
  800b50:	eb 05                	jmp    800b57 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b52:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b57:	5b                   	pop    %ebx
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b60:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b64:	eb 07                	jmp    800b6d <strchr+0x13>
		if (*s == c)
  800b66:	38 ca                	cmp    %cl,%dl
  800b68:	74 0f                	je     800b79 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b6a:	83 c0 01             	add    $0x1,%eax
  800b6d:	0f b6 10             	movzbl (%eax),%edx
  800b70:	84 d2                	test   %dl,%dl
  800b72:	75 f2                	jne    800b66 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b74:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b81:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b85:	eb 07                	jmp    800b8e <strfind+0x13>
		if (*s == c)
  800b87:	38 ca                	cmp    %cl,%dl
  800b89:	74 0a                	je     800b95 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b8b:	83 c0 01             	add    $0x1,%eax
  800b8e:	0f b6 10             	movzbl (%eax),%edx
  800b91:	84 d2                	test   %dl,%dl
  800b93:	75 f2                	jne    800b87 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    

00800b97 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	57                   	push   %edi
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
  800b9d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ba0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ba3:	85 c9                	test   %ecx,%ecx
  800ba5:	74 36                	je     800bdd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ba7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bad:	75 28                	jne    800bd7 <memset+0x40>
  800baf:	f6 c1 03             	test   $0x3,%cl
  800bb2:	75 23                	jne    800bd7 <memset+0x40>
		c &= 0xFF;
  800bb4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bb8:	89 d3                	mov    %edx,%ebx
  800bba:	c1 e3 08             	shl    $0x8,%ebx
  800bbd:	89 d6                	mov    %edx,%esi
  800bbf:	c1 e6 18             	shl    $0x18,%esi
  800bc2:	89 d0                	mov    %edx,%eax
  800bc4:	c1 e0 10             	shl    $0x10,%eax
  800bc7:	09 f0                	or     %esi,%eax
  800bc9:	09 c2                	or     %eax,%edx
  800bcb:	89 d0                	mov    %edx,%eax
  800bcd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bcf:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bd2:	fc                   	cld    
  800bd3:	f3 ab                	rep stos %eax,%es:(%edi)
  800bd5:	eb 06                	jmp    800bdd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bda:	fc                   	cld    
  800bdb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bdd:	89 f8                	mov    %edi,%eax
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bec:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bf2:	39 c6                	cmp    %eax,%esi
  800bf4:	73 35                	jae    800c2b <memmove+0x47>
  800bf6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bf9:	39 d0                	cmp    %edx,%eax
  800bfb:	73 2e                	jae    800c2b <memmove+0x47>
		s += n;
		d += n;
  800bfd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800c00:	89 d6                	mov    %edx,%esi
  800c02:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c04:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c0a:	75 13                	jne    800c1f <memmove+0x3b>
  800c0c:	f6 c1 03             	test   $0x3,%cl
  800c0f:	75 0e                	jne    800c1f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c11:	83 ef 04             	sub    $0x4,%edi
  800c14:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c17:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c1a:	fd                   	std    
  800c1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c1d:	eb 09                	jmp    800c28 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c1f:	83 ef 01             	sub    $0x1,%edi
  800c22:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c25:	fd                   	std    
  800c26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c28:	fc                   	cld    
  800c29:	eb 1d                	jmp    800c48 <memmove+0x64>
  800c2b:	89 f2                	mov    %esi,%edx
  800c2d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c2f:	f6 c2 03             	test   $0x3,%dl
  800c32:	75 0f                	jne    800c43 <memmove+0x5f>
  800c34:	f6 c1 03             	test   $0x3,%cl
  800c37:	75 0a                	jne    800c43 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c39:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c3c:	89 c7                	mov    %eax,%edi
  800c3e:	fc                   	cld    
  800c3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c41:	eb 05                	jmp    800c48 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c43:	89 c7                	mov    %eax,%edi
  800c45:	fc                   	cld    
  800c46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c48:	5e                   	pop    %esi
  800c49:	5f                   	pop    %edi
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c52:	8b 45 10             	mov    0x10(%ebp),%eax
  800c55:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c59:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c60:	8b 45 08             	mov    0x8(%ebp),%eax
  800c63:	89 04 24             	mov    %eax,(%esp)
  800c66:	e8 79 ff ff ff       	call   800be4 <memmove>
}
  800c6b:	c9                   	leave  
  800c6c:	c3                   	ret    

00800c6d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	56                   	push   %esi
  800c71:	53                   	push   %ebx
  800c72:	8b 55 08             	mov    0x8(%ebp),%edx
  800c75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c78:	89 d6                	mov    %edx,%esi
  800c7a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c7d:	eb 1a                	jmp    800c99 <memcmp+0x2c>
		if (*s1 != *s2)
  800c7f:	0f b6 02             	movzbl (%edx),%eax
  800c82:	0f b6 19             	movzbl (%ecx),%ebx
  800c85:	38 d8                	cmp    %bl,%al
  800c87:	74 0a                	je     800c93 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c89:	0f b6 c0             	movzbl %al,%eax
  800c8c:	0f b6 db             	movzbl %bl,%ebx
  800c8f:	29 d8                	sub    %ebx,%eax
  800c91:	eb 0f                	jmp    800ca2 <memcmp+0x35>
		s1++, s2++;
  800c93:	83 c2 01             	add    $0x1,%edx
  800c96:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c99:	39 f2                	cmp    %esi,%edx
  800c9b:	75 e2                	jne    800c7f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ca2:	5b                   	pop    %ebx
  800ca3:	5e                   	pop    %esi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800caf:	89 c2                	mov    %eax,%edx
  800cb1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cb4:	eb 07                	jmp    800cbd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cb6:	38 08                	cmp    %cl,(%eax)
  800cb8:	74 07                	je     800cc1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cba:	83 c0 01             	add    $0x1,%eax
  800cbd:	39 d0                	cmp    %edx,%eax
  800cbf:	72 f5                	jb     800cb6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ccf:	eb 03                	jmp    800cd4 <strtol+0x11>
		s++;
  800cd1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd4:	0f b6 0a             	movzbl (%edx),%ecx
  800cd7:	80 f9 09             	cmp    $0x9,%cl
  800cda:	74 f5                	je     800cd1 <strtol+0xe>
  800cdc:	80 f9 20             	cmp    $0x20,%cl
  800cdf:	74 f0                	je     800cd1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ce1:	80 f9 2b             	cmp    $0x2b,%cl
  800ce4:	75 0a                	jne    800cf0 <strtol+0x2d>
		s++;
  800ce6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ce9:	bf 00 00 00 00       	mov    $0x0,%edi
  800cee:	eb 11                	jmp    800d01 <strtol+0x3e>
  800cf0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cf5:	80 f9 2d             	cmp    $0x2d,%cl
  800cf8:	75 07                	jne    800d01 <strtol+0x3e>
		s++, neg = 1;
  800cfa:	8d 52 01             	lea    0x1(%edx),%edx
  800cfd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d01:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800d06:	75 15                	jne    800d1d <strtol+0x5a>
  800d08:	80 3a 30             	cmpb   $0x30,(%edx)
  800d0b:	75 10                	jne    800d1d <strtol+0x5a>
  800d0d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d11:	75 0a                	jne    800d1d <strtol+0x5a>
		s += 2, base = 16;
  800d13:	83 c2 02             	add    $0x2,%edx
  800d16:	b8 10 00 00 00       	mov    $0x10,%eax
  800d1b:	eb 10                	jmp    800d2d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800d1d:	85 c0                	test   %eax,%eax
  800d1f:	75 0c                	jne    800d2d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d21:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d23:	80 3a 30             	cmpb   $0x30,(%edx)
  800d26:	75 05                	jne    800d2d <strtol+0x6a>
		s++, base = 8;
  800d28:	83 c2 01             	add    $0x1,%edx
  800d2b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800d2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d32:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d35:	0f b6 0a             	movzbl (%edx),%ecx
  800d38:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800d3b:	89 f0                	mov    %esi,%eax
  800d3d:	3c 09                	cmp    $0x9,%al
  800d3f:	77 08                	ja     800d49 <strtol+0x86>
			dig = *s - '0';
  800d41:	0f be c9             	movsbl %cl,%ecx
  800d44:	83 e9 30             	sub    $0x30,%ecx
  800d47:	eb 20                	jmp    800d69 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800d49:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800d4c:	89 f0                	mov    %esi,%eax
  800d4e:	3c 19                	cmp    $0x19,%al
  800d50:	77 08                	ja     800d5a <strtol+0x97>
			dig = *s - 'a' + 10;
  800d52:	0f be c9             	movsbl %cl,%ecx
  800d55:	83 e9 57             	sub    $0x57,%ecx
  800d58:	eb 0f                	jmp    800d69 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800d5a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800d5d:	89 f0                	mov    %esi,%eax
  800d5f:	3c 19                	cmp    $0x19,%al
  800d61:	77 16                	ja     800d79 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800d63:	0f be c9             	movsbl %cl,%ecx
  800d66:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d69:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800d6c:	7d 0f                	jge    800d7d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800d6e:	83 c2 01             	add    $0x1,%edx
  800d71:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800d75:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800d77:	eb bc                	jmp    800d35 <strtol+0x72>
  800d79:	89 d8                	mov    %ebx,%eax
  800d7b:	eb 02                	jmp    800d7f <strtol+0xbc>
  800d7d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800d7f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d83:	74 05                	je     800d8a <strtol+0xc7>
		*endptr = (char *) s;
  800d85:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d88:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800d8a:	f7 d8                	neg    %eax
  800d8c:	85 ff                	test   %edi,%edi
  800d8e:	0f 44 c3             	cmove  %ebx,%eax
}
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5f                   	pop    %edi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	57                   	push   %edi
  800d9a:	56                   	push   %esi
  800d9b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800da1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da4:	8b 55 08             	mov    0x8(%ebp),%edx
  800da7:	89 c3                	mov    %eax,%ebx
  800da9:	89 c7                	mov    %eax,%edi
  800dab:	89 c6                	mov    %eax,%esi
  800dad:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	57                   	push   %edi
  800db8:	56                   	push   %esi
  800db9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dba:	ba 00 00 00 00       	mov    $0x0,%edx
  800dbf:	b8 01 00 00 00       	mov    $0x1,%eax
  800dc4:	89 d1                	mov    %edx,%ecx
  800dc6:	89 d3                	mov    %edx,%ebx
  800dc8:	89 d7                	mov    %edx,%edi
  800dca:	89 d6                	mov    %edx,%esi
  800dcc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800dce:	5b                   	pop    %ebx
  800dcf:	5e                   	pop    %esi
  800dd0:	5f                   	pop    %edi
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	57                   	push   %edi
  800dd7:	56                   	push   %esi
  800dd8:	53                   	push   %ebx
  800dd9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800de1:	b8 03 00 00 00       	mov    $0x3,%eax
  800de6:	8b 55 08             	mov    0x8(%ebp),%edx
  800de9:	89 cb                	mov    %ecx,%ebx
  800deb:	89 cf                	mov    %ecx,%edi
  800ded:	89 ce                	mov    %ecx,%esi
  800def:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800df1:	85 c0                	test   %eax,%eax
  800df3:	7e 28                	jle    800e1d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e00:	00 
  800e01:	c7 44 24 08 9f 2f 80 	movl   $0x802f9f,0x8(%esp)
  800e08:	00 
  800e09:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e10:	00 
  800e11:	c7 04 24 bc 2f 80 00 	movl   $0x802fbc,(%esp)
  800e18:	e8 01 f5 ff ff       	call   80031e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e1d:	83 c4 2c             	add    $0x2c,%esp
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    

00800e25 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	57                   	push   %edi
  800e29:	56                   	push   %esi
  800e2a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e30:	b8 02 00 00 00       	mov    $0x2,%eax
  800e35:	89 d1                	mov    %edx,%ecx
  800e37:	89 d3                	mov    %edx,%ebx
  800e39:	89 d7                	mov    %edx,%edi
  800e3b:	89 d6                	mov    %edx,%esi
  800e3d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e3f:	5b                   	pop    %ebx
  800e40:	5e                   	pop    %esi
  800e41:	5f                   	pop    %edi
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    

00800e44 <sys_yield>:

void
sys_yield(void)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	57                   	push   %edi
  800e48:	56                   	push   %esi
  800e49:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e54:	89 d1                	mov    %edx,%ecx
  800e56:	89 d3                	mov    %edx,%ebx
  800e58:	89 d7                	mov    %edx,%edi
  800e5a:	89 d6                	mov    %edx,%esi
  800e5c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e5e:	5b                   	pop    %ebx
  800e5f:	5e                   	pop    %esi
  800e60:	5f                   	pop    %edi
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    

00800e63 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	57                   	push   %edi
  800e67:	56                   	push   %esi
  800e68:	53                   	push   %ebx
  800e69:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6c:	be 00 00 00 00       	mov    $0x0,%esi
  800e71:	b8 04 00 00 00       	mov    $0x4,%eax
  800e76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e79:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e7f:	89 f7                	mov    %esi,%edi
  800e81:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e83:	85 c0                	test   %eax,%eax
  800e85:	7e 28                	jle    800eaf <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e87:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e8b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e92:	00 
  800e93:	c7 44 24 08 9f 2f 80 	movl   $0x802f9f,0x8(%esp)
  800e9a:	00 
  800e9b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea2:	00 
  800ea3:	c7 04 24 bc 2f 80 00 	movl   $0x802fbc,(%esp)
  800eaa:	e8 6f f4 ff ff       	call   80031e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800eaf:	83 c4 2c             	add    $0x2c,%esp
  800eb2:	5b                   	pop    %ebx
  800eb3:	5e                   	pop    %esi
  800eb4:	5f                   	pop    %edi
  800eb5:	5d                   	pop    %ebp
  800eb6:	c3                   	ret    

00800eb7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	57                   	push   %edi
  800ebb:	56                   	push   %esi
  800ebc:	53                   	push   %ebx
  800ebd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ec5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ece:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ed1:	8b 75 18             	mov    0x18(%ebp),%esi
  800ed4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ed6:	85 c0                	test   %eax,%eax
  800ed8:	7e 28                	jle    800f02 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eda:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ede:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ee5:	00 
  800ee6:	c7 44 24 08 9f 2f 80 	movl   $0x802f9f,0x8(%esp)
  800eed:	00 
  800eee:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef5:	00 
  800ef6:	c7 04 24 bc 2f 80 00 	movl   $0x802fbc,(%esp)
  800efd:	e8 1c f4 ff ff       	call   80031e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f02:	83 c4 2c             	add    $0x2c,%esp
  800f05:	5b                   	pop    %ebx
  800f06:	5e                   	pop    %esi
  800f07:	5f                   	pop    %edi
  800f08:	5d                   	pop    %ebp
  800f09:	c3                   	ret    

00800f0a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800f18:	b8 06 00 00 00       	mov    $0x6,%eax
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
  800f2b:	7e 28                	jle    800f55 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f31:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f38:	00 
  800f39:	c7 44 24 08 9f 2f 80 	movl   $0x802f9f,0x8(%esp)
  800f40:	00 
  800f41:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f48:	00 
  800f49:	c7 04 24 bc 2f 80 00 	movl   $0x802fbc,(%esp)
  800f50:	e8 c9 f3 ff ff       	call   80031e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f55:	83 c4 2c             	add    $0x2c,%esp
  800f58:	5b                   	pop    %ebx
  800f59:	5e                   	pop    %esi
  800f5a:	5f                   	pop    %edi
  800f5b:	5d                   	pop    %ebp
  800f5c:	c3                   	ret    

00800f5d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800f6b:	b8 08 00 00 00       	mov    $0x8,%eax
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
  800f7e:	7e 28                	jle    800fa8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f80:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f84:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f8b:	00 
  800f8c:	c7 44 24 08 9f 2f 80 	movl   $0x802f9f,0x8(%esp)
  800f93:	00 
  800f94:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f9b:	00 
  800f9c:	c7 04 24 bc 2f 80 00 	movl   $0x802fbc,(%esp)
  800fa3:	e8 76 f3 ff ff       	call   80031e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fa8:	83 c4 2c             	add    $0x2c,%esp
  800fab:	5b                   	pop    %ebx
  800fac:	5e                   	pop    %esi
  800fad:	5f                   	pop    %edi
  800fae:	5d                   	pop    %ebp
  800faf:	c3                   	ret    

00800fb0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	57                   	push   %edi
  800fb4:	56                   	push   %esi
  800fb5:	53                   	push   %ebx
  800fb6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fbe:	b8 09 00 00 00       	mov    $0x9,%eax
  800fc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc9:	89 df                	mov    %ebx,%edi
  800fcb:	89 de                	mov    %ebx,%esi
  800fcd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fcf:	85 c0                	test   %eax,%eax
  800fd1:	7e 28                	jle    800ffb <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800fde:	00 
  800fdf:	c7 44 24 08 9f 2f 80 	movl   $0x802f9f,0x8(%esp)
  800fe6:	00 
  800fe7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fee:	00 
  800fef:	c7 04 24 bc 2f 80 00 	movl   $0x802fbc,(%esp)
  800ff6:	e8 23 f3 ff ff       	call   80031e <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ffb:	83 c4 2c             	add    $0x2c,%esp
  800ffe:	5b                   	pop    %ebx
  800fff:	5e                   	pop    %esi
  801000:	5f                   	pop    %edi
  801001:	5d                   	pop    %ebp
  801002:	c3                   	ret    

00801003 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801003:	55                   	push   %ebp
  801004:	89 e5                	mov    %esp,%ebp
  801006:	57                   	push   %edi
  801007:	56                   	push   %esi
  801008:	53                   	push   %ebx
  801009:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80100c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801011:	b8 0a 00 00 00       	mov    $0xa,%eax
  801016:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801019:	8b 55 08             	mov    0x8(%ebp),%edx
  80101c:	89 df                	mov    %ebx,%edi
  80101e:	89 de                	mov    %ebx,%esi
  801020:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801022:	85 c0                	test   %eax,%eax
  801024:	7e 28                	jle    80104e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801026:	89 44 24 10          	mov    %eax,0x10(%esp)
  80102a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801031:	00 
  801032:	c7 44 24 08 9f 2f 80 	movl   $0x802f9f,0x8(%esp)
  801039:	00 
  80103a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801041:	00 
  801042:	c7 04 24 bc 2f 80 00 	movl   $0x802fbc,(%esp)
  801049:	e8 d0 f2 ff ff       	call   80031e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80104e:	83 c4 2c             	add    $0x2c,%esp
  801051:	5b                   	pop    %ebx
  801052:	5e                   	pop    %esi
  801053:	5f                   	pop    %edi
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    

00801056 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	57                   	push   %edi
  80105a:	56                   	push   %esi
  80105b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105c:	be 00 00 00 00       	mov    $0x0,%esi
  801061:	b8 0c 00 00 00       	mov    $0xc,%eax
  801066:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801069:	8b 55 08             	mov    0x8(%ebp),%edx
  80106c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80106f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801072:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801074:	5b                   	pop    %ebx
  801075:	5e                   	pop    %esi
  801076:	5f                   	pop    %edi
  801077:	5d                   	pop    %ebp
  801078:	c3                   	ret    

00801079 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801079:	55                   	push   %ebp
  80107a:	89 e5                	mov    %esp,%ebp
  80107c:	57                   	push   %edi
  80107d:	56                   	push   %esi
  80107e:	53                   	push   %ebx
  80107f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801082:	b9 00 00 00 00       	mov    $0x0,%ecx
  801087:	b8 0d 00 00 00       	mov    $0xd,%eax
  80108c:	8b 55 08             	mov    0x8(%ebp),%edx
  80108f:	89 cb                	mov    %ecx,%ebx
  801091:	89 cf                	mov    %ecx,%edi
  801093:	89 ce                	mov    %ecx,%esi
  801095:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801097:	85 c0                	test   %eax,%eax
  801099:	7e 28                	jle    8010c3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80109b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80109f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8010a6:	00 
  8010a7:	c7 44 24 08 9f 2f 80 	movl   $0x802f9f,0x8(%esp)
  8010ae:	00 
  8010af:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010b6:	00 
  8010b7:	c7 04 24 bc 2f 80 00 	movl   $0x802fbc,(%esp)
  8010be:	e8 5b f2 ff ff       	call   80031e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010c3:	83 c4 2c             	add    $0x2c,%esp
  8010c6:	5b                   	pop    %ebx
  8010c7:	5e                   	pop    %esi
  8010c8:	5f                   	pop    %edi
  8010c9:	5d                   	pop    %ebp
  8010ca:	c3                   	ret    

008010cb <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8010cb:	55                   	push   %ebp
  8010cc:	89 e5                	mov    %esp,%ebp
  8010ce:	57                   	push   %edi
  8010cf:	56                   	push   %esi
  8010d0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d6:	b8 0e 00 00 00       	mov    $0xe,%eax
  8010db:	89 d1                	mov    %edx,%ecx
  8010dd:	89 d3                	mov    %edx,%ebx
  8010df:	89 d7                	mov    %edx,%edi
  8010e1:	89 d6                	mov    %edx,%esi
  8010e3:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8010e5:	5b                   	pop    %ebx
  8010e6:	5e                   	pop    %esi
  8010e7:	5f                   	pop    %edi
  8010e8:	5d                   	pop    %ebp
  8010e9:	c3                   	ret    

008010ea <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	57                   	push   %edi
  8010ee:	56                   	push   %esi
  8010ef:	53                   	push   %ebx
  8010f0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f8:	b8 0f 00 00 00       	mov    $0xf,%eax
  8010fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801100:	8b 55 08             	mov    0x8(%ebp),%edx
  801103:	89 df                	mov    %ebx,%edi
  801105:	89 de                	mov    %ebx,%esi
  801107:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801109:	85 c0                	test   %eax,%eax
  80110b:	7e 28                	jle    801135 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80110d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801111:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801118:	00 
  801119:	c7 44 24 08 9f 2f 80 	movl   $0x802f9f,0x8(%esp)
  801120:	00 
  801121:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801128:	00 
  801129:	c7 04 24 bc 2f 80 00 	movl   $0x802fbc,(%esp)
  801130:	e8 e9 f1 ff ff       	call   80031e <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  801135:	83 c4 2c             	add    $0x2c,%esp
  801138:	5b                   	pop    %ebx
  801139:	5e                   	pop    %esi
  80113a:	5f                   	pop    %edi
  80113b:	5d                   	pop    %ebp
  80113c:	c3                   	ret    

0080113d <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  80113d:	55                   	push   %ebp
  80113e:	89 e5                	mov    %esp,%ebp
  801140:	57                   	push   %edi
  801141:	56                   	push   %esi
  801142:	53                   	push   %ebx
  801143:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801146:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114b:	b8 10 00 00 00       	mov    $0x10,%eax
  801150:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801153:	8b 55 08             	mov    0x8(%ebp),%edx
  801156:	89 df                	mov    %ebx,%edi
  801158:	89 de                	mov    %ebx,%esi
  80115a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80115c:	85 c0                	test   %eax,%eax
  80115e:	7e 28                	jle    801188 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801160:	89 44 24 10          	mov    %eax,0x10(%esp)
  801164:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  80116b:	00 
  80116c:	c7 44 24 08 9f 2f 80 	movl   $0x802f9f,0x8(%esp)
  801173:	00 
  801174:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80117b:	00 
  80117c:	c7 04 24 bc 2f 80 00 	movl   $0x802fbc,(%esp)
  801183:	e8 96 f1 ff ff       	call   80031e <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  801188:	83 c4 2c             	add    $0x2c,%esp
  80118b:	5b                   	pop    %ebx
  80118c:	5e                   	pop    %esi
  80118d:	5f                   	pop    %edi
  80118e:	5d                   	pop    %ebp
  80118f:	c3                   	ret    

00801190 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	56                   	push   %esi
  801194:	53                   	push   %ebx
  801195:	83 ec 20             	sub    $0x20,%esp
  801198:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80119b:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if(!(err & FEC_WR)) {
  80119d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8011a1:	75 20                	jne    8011c3 <pgfault+0x33>
		panic("0x%x Not a write", addr);
  8011a3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011a7:	c7 44 24 08 ca 2f 80 	movl   $0x802fca,0x8(%esp)
  8011ae:	00 
  8011af:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8011b6:	00 
  8011b7:	c7 04 24 db 2f 80 00 	movl   $0x802fdb,(%esp)
  8011be:	e8 5b f1 ff ff       	call   80031e <_panic>
	}

	if(!(uvpt[PGNUM(addr)] & PTE_COW)) {
  8011c3:	89 f0                	mov    %esi,%eax
  8011c5:	c1 e8 0c             	shr    $0xc,%eax
  8011c8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011cf:	f6 c4 08             	test   $0x8,%ah
  8011d2:	75 1c                	jne    8011f0 <pgfault+0x60>
		panic("Not a COW page");
  8011d4:	c7 44 24 08 e6 2f 80 	movl   $0x802fe6,0x8(%esp)
  8011db:	00 
  8011dc:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  8011e3:	00 
  8011e4:	c7 04 24 db 2f 80 00 	movl   $0x802fdb,(%esp)
  8011eb:	e8 2e f1 ff ff       	call   80031e <_panic>

	// Allocate a new page, map it at a temporary location (PFTEMP), // copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	envid_t envid = sys_getenvid();
  8011f0:	e8 30 fc ff ff       	call   800e25 <sys_getenvid>
  8011f5:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, PFTEMP, PTE_W | PTE_U | PTE_P);
  8011f7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011fe:	00 
  8011ff:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801206:	00 
  801207:	89 04 24             	mov    %eax,(%esp)
  80120a:	e8 54 fc ff ff       	call   800e63 <sys_page_alloc>
	if(r < 0) {
  80120f:	85 c0                	test   %eax,%eax
  801211:	79 1c                	jns    80122f <pgfault+0x9f>
		panic("couldn't allocate page");
  801213:	c7 44 24 08 f5 2f 80 	movl   $0x802ff5,0x8(%esp)
  80121a:	00 
  80121b:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801222:	00 
  801223:	c7 04 24 db 2f 80 00 	movl   $0x802fdb,(%esp)
  80122a:	e8 ef f0 ff ff       	call   80031e <_panic>
	}

	memmove(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  80122f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  801235:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80123c:	00 
  80123d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801241:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801248:	e8 97 f9 ff ff       	call   800be4 <memmove>

	r = sys_page_map(envid, PFTEMP, envid, ROUNDDOWN(addr,PGSIZE), PTE_P | PTE_U | PTE_W);
  80124d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801254:	00 
  801255:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801259:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80125d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801264:	00 
  801265:	89 1c 24             	mov    %ebx,(%esp)
  801268:	e8 4a fc ff ff       	call   800eb7 <sys_page_map>
	if(r < 0) {
  80126d:	85 c0                	test   %eax,%eax
  80126f:	79 1c                	jns    80128d <pgfault+0xfd>
		panic("couldn't map page");
  801271:	c7 44 24 08 0c 30 80 	movl   $0x80300c,0x8(%esp)
  801278:	00 
  801279:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  801280:	00 
  801281:	c7 04 24 db 2f 80 00 	movl   $0x802fdb,(%esp)
  801288:	e8 91 f0 ff ff       	call   80031e <_panic>
	}
}
  80128d:	83 c4 20             	add    $0x20,%esp
  801290:	5b                   	pop    %ebx
  801291:	5e                   	pop    %esi
  801292:	5d                   	pop    %ebp
  801293:	c3                   	ret    

00801294 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801294:	55                   	push   %ebp
  801295:	89 e5                	mov    %esp,%ebp
  801297:	57                   	push   %edi
  801298:	56                   	push   %esi
  801299:	53                   	push   %ebx
  80129a:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envid;
	uintptr_t addr;
	int r = 0;

	set_pgfault_handler(pgfault);
  80129d:	c7 04 24 90 11 80 00 	movl   $0x801190,(%esp)
  8012a4:	e8 ad 14 00 00       	call   802756 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8012a9:	b8 07 00 00 00       	mov    $0x7,%eax
  8012ae:	cd 30                	int    $0x30
  8012b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8012b3:	89 45 d8             	mov    %eax,-0x28(%ebp)

	envid = sys_exofork();
	if(envid == 0) {
  8012b6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8012bd:	bf 00 00 00 00       	mov    $0x0,%edi
  8012c2:	85 c0                	test   %eax,%eax
  8012c4:	75 21                	jne    8012e7 <fork+0x53>
		thisenv = &envs[ENVX(sys_getenvid())];
  8012c6:	e8 5a fb ff ff       	call   800e25 <sys_getenvid>
  8012cb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8012d0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012d3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012d8:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8012dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e2:	e9 8d 01 00 00       	jmp    801474 <fork+0x1e0>
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
  8012e7:	89 f8                	mov    %edi,%eax
  8012e9:	c1 e8 16             	shr    $0x16,%eax
  8012ec:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012f3:	85 c0                	test   %eax,%eax
  8012f5:	0f 84 02 01 00 00    	je     8013fd <fork+0x169>
  8012fb:	89 fa                	mov    %edi,%edx
  8012fd:	c1 ea 0c             	shr    $0xc,%edx
  801300:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801307:	85 c0                	test   %eax,%eax
  801309:	0f 84 ee 00 00 00    	je     8013fd <fork+0x169>
//
static int
duppage(envid_t envid, unsigned pn)
{

	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P)) return 0;
  80130f:	89 d6                	mov    %edx,%esi
  801311:	c1 e6 0c             	shl    $0xc,%esi
  801314:	89 f0                	mov    %esi,%eax
  801316:	c1 e8 16             	shr    $0x16,%eax
  801319:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  801320:	b8 00 00 00 00       	mov    $0x0,%eax
  801325:	f6 c1 01             	test   $0x1,%cl
  801328:	0f 84 cc 00 00 00    	je     8013fa <fork+0x166>

	int all_perms = PTE_U | PTE_P | PTE_AVAIL | PTE_W | PTE_COW;
	int orig_perms = uvpt[pn] & all_perms;
  80132e:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  801335:	89 d8                	mov    %ebx,%eax
  801337:	25 07 0e 00 00       	and    $0xe07,%eax
  80133c:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if(!(orig_perms & PTE_P)) return 0;
  80133f:	89 d8                	mov    %ebx,%eax
  801341:	83 e0 01             	and    $0x1,%eax
  801344:	0f 84 b0 00 00 00    	je     8013fa <fork+0x166>

	int r = 0;
	envid_t curenvid = sys_getenvid();
  80134a:	e8 d6 fa ff ff       	call   800e25 <sys_getenvid>
  80134f:	89 45 dc             	mov    %eax,-0x24(%ebp)


	if(orig_perms & PTE_SHARE) {
  801352:	f7 45 e0 00 04 00 00 	testl  $0x400,-0x20(%ebp)
  801359:	74 28                	je     801383 <fork+0xef>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms & PTE_SYSCALL));
  80135b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80135e:	25 07 0e 00 00       	and    $0xe07,%eax
  801363:	89 44 24 10          	mov    %eax,0x10(%esp)
  801367:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80136b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80136e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801372:	89 74 24 04          	mov    %esi,0x4(%esp)
  801376:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801379:	89 04 24             	mov    %eax,(%esp)
  80137c:	e8 36 fb ff ff       	call   800eb7 <sys_page_map>
  801381:	eb 77                	jmp    8013fa <fork+0x166>

	} else if(((orig_perms) & PTE_COW) || (orig_perms & PTE_W) ) {
  801383:	f7 c3 02 08 00 00    	test   $0x802,%ebx
  801389:	74 4e                	je     8013d9 <fork+0x145>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  80138b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80138e:	25 fd f7 ff ff       	and    $0xfffff7fd,%eax
  801393:	80 cc 08             	or     $0x8,%ah
  801396:	89 c3                	mov    %eax,%ebx
  801398:	89 44 24 10          	mov    %eax,0x10(%esp)
  80139c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013a0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8013a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013a7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013ae:	89 04 24             	mov    %eax,(%esp)
  8013b1:	e8 01 fb ff ff       	call   800eb7 <sys_page_map>
  8013b6:	89 45 e0             	mov    %eax,-0x20(%ebp)

		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), curenvid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  8013b9:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8013bd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013c1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8013c4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013c8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013cc:	89 0c 24             	mov    %ecx,(%esp)
  8013cf:	e8 e3 fa ff ff       	call   800eb7 <sys_page_map>
  8013d4:	03 45 e0             	add    -0x20(%ebp),%eax
  8013d7:	eb 21                	jmp    8013fa <fork+0x166>

	} else {
		r = sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), orig_perms);
  8013d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013dc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013e0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8013e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013eb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013ef:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013f2:	89 04 24             	mov    %eax,(%esp)
  8013f5:	e8 bd fa ff ff       	call   800eb7 <sys_page_map>
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
  8013fa:	01 45 e4             	add    %eax,-0x1c(%ebp)
	if(envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
  8013fd:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801403:	81 ff 00 f0 bf ee    	cmp    $0xeebff000,%edi
  801409:	0f 85 d8 fe ff ff    	jne    8012e7 <fork+0x53>
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
		}
	}

	r+=sys_page_alloc(envid, (void*)UXSTACKTOP - PGSIZE, PTE_P|PTE_U|PTE_W);
  80140f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801416:	00 
  801417:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80141e:	ee 
  80141f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801422:	89 34 24             	mov    %esi,(%esp)
  801425:	e8 39 fa ff ff       	call   800e63 <sys_page_alloc>
  80142a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80142d:	01 c3                	add    %eax,%ebx
	r+=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80142f:	c7 44 24 04 a3 27 80 	movl   $0x8027a3,0x4(%esp)
  801436:	00 
  801437:	89 34 24             	mov    %esi,(%esp)
  80143a:	e8 c4 fb ff ff       	call   801003 <sys_env_set_pgfault_upcall>
  80143f:	01 c3                	add    %eax,%ebx
	r+= sys_env_set_status(envid, ENV_RUNNABLE);
  801441:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801448:	00 
  801449:	89 34 24             	mov    %esi,(%esp)
  80144c:	e8 0c fb ff ff       	call   800f5d <sys_env_set_status>

	if(r<0) {
  801451:	01 d8                	add    %ebx,%eax
  801453:	79 1c                	jns    801471 <fork+0x1dd>
	 panic("fork failed!");
  801455:	c7 44 24 08 1e 30 80 	movl   $0x80301e,0x8(%esp)
  80145c:	00 
  80145d:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  801464:	00 
  801465:	c7 04 24 db 2f 80 00 	movl   $0x802fdb,(%esp)
  80146c:	e8 ad ee ff ff       	call   80031e <_panic>
	}

	return envid;
  801471:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  801474:	83 c4 3c             	add    $0x3c,%esp
  801477:	5b                   	pop    %ebx
  801478:	5e                   	pop    %esi
  801479:	5f                   	pop    %edi
  80147a:	5d                   	pop    %ebp
  80147b:	c3                   	ret    

0080147c <sfork>:

// Challenge!
int
sfork(void)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801482:	c7 44 24 08 2b 30 80 	movl   $0x80302b,0x8(%esp)
  801489:	00 
  80148a:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
  801491:	00 
  801492:	c7 04 24 db 2f 80 00 	movl   $0x802fdb,(%esp)
  801499:	e8 80 ee ff ff       	call   80031e <_panic>
  80149e:	66 90                	xchg   %ax,%ax

008014a0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014a0:	55                   	push   %ebp
  8014a1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a6:	05 00 00 00 30       	add    $0x30000000,%eax
  8014ab:	c1 e8 0c             	shr    $0xc,%eax
}
  8014ae:	5d                   	pop    %ebp
  8014af:	c3                   	ret    

008014b0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8014bb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8014c0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014c5:	5d                   	pop    %ebp
  8014c6:	c3                   	ret    

008014c7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014c7:	55                   	push   %ebp
  8014c8:	89 e5                	mov    %esp,%ebp
  8014ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014cd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014d2:	89 c2                	mov    %eax,%edx
  8014d4:	c1 ea 16             	shr    $0x16,%edx
  8014d7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014de:	f6 c2 01             	test   $0x1,%dl
  8014e1:	74 11                	je     8014f4 <fd_alloc+0x2d>
  8014e3:	89 c2                	mov    %eax,%edx
  8014e5:	c1 ea 0c             	shr    $0xc,%edx
  8014e8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014ef:	f6 c2 01             	test   $0x1,%dl
  8014f2:	75 09                	jne    8014fd <fd_alloc+0x36>
			*fd_store = fd;
  8014f4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8014fb:	eb 17                	jmp    801514 <fd_alloc+0x4d>
  8014fd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801502:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801507:	75 c9                	jne    8014d2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801509:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80150f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801514:	5d                   	pop    %ebp
  801515:	c3                   	ret    

00801516 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80151c:	83 f8 1f             	cmp    $0x1f,%eax
  80151f:	77 36                	ja     801557 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801521:	c1 e0 0c             	shl    $0xc,%eax
  801524:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801529:	89 c2                	mov    %eax,%edx
  80152b:	c1 ea 16             	shr    $0x16,%edx
  80152e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801535:	f6 c2 01             	test   $0x1,%dl
  801538:	74 24                	je     80155e <fd_lookup+0x48>
  80153a:	89 c2                	mov    %eax,%edx
  80153c:	c1 ea 0c             	shr    $0xc,%edx
  80153f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801546:	f6 c2 01             	test   $0x1,%dl
  801549:	74 1a                	je     801565 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80154b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80154e:	89 02                	mov    %eax,(%edx)
	return 0;
  801550:	b8 00 00 00 00       	mov    $0x0,%eax
  801555:	eb 13                	jmp    80156a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801557:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80155c:	eb 0c                	jmp    80156a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80155e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801563:	eb 05                	jmp    80156a <fd_lookup+0x54>
  801565:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80156a:	5d                   	pop    %ebp
  80156b:	c3                   	ret    

0080156c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	83 ec 18             	sub    $0x18,%esp
  801572:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801575:	ba 00 00 00 00       	mov    $0x0,%edx
  80157a:	eb 13                	jmp    80158f <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  80157c:	39 08                	cmp    %ecx,(%eax)
  80157e:	75 0c                	jne    80158c <dev_lookup+0x20>
			*dev = devtab[i];
  801580:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801583:	89 01                	mov    %eax,(%ecx)
			return 0;
  801585:	b8 00 00 00 00       	mov    $0x0,%eax
  80158a:	eb 38                	jmp    8015c4 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80158c:	83 c2 01             	add    $0x1,%edx
  80158f:	8b 04 95 c0 30 80 00 	mov    0x8030c0(,%edx,4),%eax
  801596:	85 c0                	test   %eax,%eax
  801598:	75 e2                	jne    80157c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80159a:	a1 08 50 80 00       	mov    0x805008,%eax
  80159f:	8b 40 48             	mov    0x48(%eax),%eax
  8015a2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015aa:	c7 04 24 44 30 80 00 	movl   $0x803044,(%esp)
  8015b1:	e8 61 ee ff ff       	call   800417 <cprintf>
	*dev = 0;
  8015b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8015bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015c4:	c9                   	leave  
  8015c5:	c3                   	ret    

008015c6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015c6:	55                   	push   %ebp
  8015c7:	89 e5                	mov    %esp,%ebp
  8015c9:	56                   	push   %esi
  8015ca:	53                   	push   %ebx
  8015cb:	83 ec 20             	sub    $0x20,%esp
  8015ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8015d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d7:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8015db:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8015e1:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015e4:	89 04 24             	mov    %eax,(%esp)
  8015e7:	e8 2a ff ff ff       	call   801516 <fd_lookup>
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	78 05                	js     8015f5 <fd_close+0x2f>
	    || fd != fd2)
  8015f0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015f3:	74 0c                	je     801601 <fd_close+0x3b>
		return (must_exist ? r : 0);
  8015f5:	84 db                	test   %bl,%bl
  8015f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8015fc:	0f 44 c2             	cmove  %edx,%eax
  8015ff:	eb 3f                	jmp    801640 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801601:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801604:	89 44 24 04          	mov    %eax,0x4(%esp)
  801608:	8b 06                	mov    (%esi),%eax
  80160a:	89 04 24             	mov    %eax,(%esp)
  80160d:	e8 5a ff ff ff       	call   80156c <dev_lookup>
  801612:	89 c3                	mov    %eax,%ebx
  801614:	85 c0                	test   %eax,%eax
  801616:	78 16                	js     80162e <fd_close+0x68>
		if (dev->dev_close)
  801618:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80161e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801623:	85 c0                	test   %eax,%eax
  801625:	74 07                	je     80162e <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801627:	89 34 24             	mov    %esi,(%esp)
  80162a:	ff d0                	call   *%eax
  80162c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80162e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801632:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801639:	e8 cc f8 ff ff       	call   800f0a <sys_page_unmap>
	return r;
  80163e:	89 d8                	mov    %ebx,%eax
}
  801640:	83 c4 20             	add    $0x20,%esp
  801643:	5b                   	pop    %ebx
  801644:	5e                   	pop    %esi
  801645:	5d                   	pop    %ebp
  801646:	c3                   	ret    

00801647 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80164d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801650:	89 44 24 04          	mov    %eax,0x4(%esp)
  801654:	8b 45 08             	mov    0x8(%ebp),%eax
  801657:	89 04 24             	mov    %eax,(%esp)
  80165a:	e8 b7 fe ff ff       	call   801516 <fd_lookup>
  80165f:	89 c2                	mov    %eax,%edx
  801661:	85 d2                	test   %edx,%edx
  801663:	78 13                	js     801678 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801665:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80166c:	00 
  80166d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801670:	89 04 24             	mov    %eax,(%esp)
  801673:	e8 4e ff ff ff       	call   8015c6 <fd_close>
}
  801678:	c9                   	leave  
  801679:	c3                   	ret    

0080167a <close_all>:

void
close_all(void)
{
  80167a:	55                   	push   %ebp
  80167b:	89 e5                	mov    %esp,%ebp
  80167d:	53                   	push   %ebx
  80167e:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801681:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801686:	89 1c 24             	mov    %ebx,(%esp)
  801689:	e8 b9 ff ff ff       	call   801647 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80168e:	83 c3 01             	add    $0x1,%ebx
  801691:	83 fb 20             	cmp    $0x20,%ebx
  801694:	75 f0                	jne    801686 <close_all+0xc>
		close(i);
}
  801696:	83 c4 14             	add    $0x14,%esp
  801699:	5b                   	pop    %ebx
  80169a:	5d                   	pop    %ebp
  80169b:	c3                   	ret    

0080169c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
  80169f:	57                   	push   %edi
  8016a0:	56                   	push   %esi
  8016a1:	53                   	push   %ebx
  8016a2:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016a5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8016af:	89 04 24             	mov    %eax,(%esp)
  8016b2:	e8 5f fe ff ff       	call   801516 <fd_lookup>
  8016b7:	89 c2                	mov    %eax,%edx
  8016b9:	85 d2                	test   %edx,%edx
  8016bb:	0f 88 e1 00 00 00    	js     8017a2 <dup+0x106>
		return r;
	close(newfdnum);
  8016c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c4:	89 04 24             	mov    %eax,(%esp)
  8016c7:	e8 7b ff ff ff       	call   801647 <close>

	newfd = INDEX2FD(newfdnum);
  8016cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016cf:	c1 e3 0c             	shl    $0xc,%ebx
  8016d2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8016d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016db:	89 04 24             	mov    %eax,(%esp)
  8016de:	e8 cd fd ff ff       	call   8014b0 <fd2data>
  8016e3:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8016e5:	89 1c 24             	mov    %ebx,(%esp)
  8016e8:	e8 c3 fd ff ff       	call   8014b0 <fd2data>
  8016ed:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016ef:	89 f0                	mov    %esi,%eax
  8016f1:	c1 e8 16             	shr    $0x16,%eax
  8016f4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016fb:	a8 01                	test   $0x1,%al
  8016fd:	74 43                	je     801742 <dup+0xa6>
  8016ff:	89 f0                	mov    %esi,%eax
  801701:	c1 e8 0c             	shr    $0xc,%eax
  801704:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80170b:	f6 c2 01             	test   $0x1,%dl
  80170e:	74 32                	je     801742 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801710:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801717:	25 07 0e 00 00       	and    $0xe07,%eax
  80171c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801720:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801724:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80172b:	00 
  80172c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801730:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801737:	e8 7b f7 ff ff       	call   800eb7 <sys_page_map>
  80173c:	89 c6                	mov    %eax,%esi
  80173e:	85 c0                	test   %eax,%eax
  801740:	78 3e                	js     801780 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801742:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801745:	89 c2                	mov    %eax,%edx
  801747:	c1 ea 0c             	shr    $0xc,%edx
  80174a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801751:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801757:	89 54 24 10          	mov    %edx,0x10(%esp)
  80175b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80175f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801766:	00 
  801767:	89 44 24 04          	mov    %eax,0x4(%esp)
  80176b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801772:	e8 40 f7 ff ff       	call   800eb7 <sys_page_map>
  801777:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801779:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80177c:	85 f6                	test   %esi,%esi
  80177e:	79 22                	jns    8017a2 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801780:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801784:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80178b:	e8 7a f7 ff ff       	call   800f0a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801790:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801794:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80179b:	e8 6a f7 ff ff       	call   800f0a <sys_page_unmap>
	return r;
  8017a0:	89 f0                	mov    %esi,%eax
}
  8017a2:	83 c4 3c             	add    $0x3c,%esp
  8017a5:	5b                   	pop    %ebx
  8017a6:	5e                   	pop    %esi
  8017a7:	5f                   	pop    %edi
  8017a8:	5d                   	pop    %ebp
  8017a9:	c3                   	ret    

008017aa <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017aa:	55                   	push   %ebp
  8017ab:	89 e5                	mov    %esp,%ebp
  8017ad:	53                   	push   %ebx
  8017ae:	83 ec 24             	sub    $0x24,%esp
  8017b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017bb:	89 1c 24             	mov    %ebx,(%esp)
  8017be:	e8 53 fd ff ff       	call   801516 <fd_lookup>
  8017c3:	89 c2                	mov    %eax,%edx
  8017c5:	85 d2                	test   %edx,%edx
  8017c7:	78 6d                	js     801836 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d3:	8b 00                	mov    (%eax),%eax
  8017d5:	89 04 24             	mov    %eax,(%esp)
  8017d8:	e8 8f fd ff ff       	call   80156c <dev_lookup>
  8017dd:	85 c0                	test   %eax,%eax
  8017df:	78 55                	js     801836 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e4:	8b 50 08             	mov    0x8(%eax),%edx
  8017e7:	83 e2 03             	and    $0x3,%edx
  8017ea:	83 fa 01             	cmp    $0x1,%edx
  8017ed:	75 23                	jne    801812 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017ef:	a1 08 50 80 00       	mov    0x805008,%eax
  8017f4:	8b 40 48             	mov    0x48(%eax),%eax
  8017f7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ff:	c7 04 24 85 30 80 00 	movl   $0x803085,(%esp)
  801806:	e8 0c ec ff ff       	call   800417 <cprintf>
		return -E_INVAL;
  80180b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801810:	eb 24                	jmp    801836 <read+0x8c>
	}
	if (!dev->dev_read)
  801812:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801815:	8b 52 08             	mov    0x8(%edx),%edx
  801818:	85 d2                	test   %edx,%edx
  80181a:	74 15                	je     801831 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80181c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80181f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801823:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801826:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80182a:	89 04 24             	mov    %eax,(%esp)
  80182d:	ff d2                	call   *%edx
  80182f:	eb 05                	jmp    801836 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801831:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801836:	83 c4 24             	add    $0x24,%esp
  801839:	5b                   	pop    %ebx
  80183a:	5d                   	pop    %ebp
  80183b:	c3                   	ret    

0080183c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80183c:	55                   	push   %ebp
  80183d:	89 e5                	mov    %esp,%ebp
  80183f:	57                   	push   %edi
  801840:	56                   	push   %esi
  801841:	53                   	push   %ebx
  801842:	83 ec 1c             	sub    $0x1c,%esp
  801845:	8b 7d 08             	mov    0x8(%ebp),%edi
  801848:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80184b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801850:	eb 23                	jmp    801875 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801852:	89 f0                	mov    %esi,%eax
  801854:	29 d8                	sub    %ebx,%eax
  801856:	89 44 24 08          	mov    %eax,0x8(%esp)
  80185a:	89 d8                	mov    %ebx,%eax
  80185c:	03 45 0c             	add    0xc(%ebp),%eax
  80185f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801863:	89 3c 24             	mov    %edi,(%esp)
  801866:	e8 3f ff ff ff       	call   8017aa <read>
		if (m < 0)
  80186b:	85 c0                	test   %eax,%eax
  80186d:	78 10                	js     80187f <readn+0x43>
			return m;
		if (m == 0)
  80186f:	85 c0                	test   %eax,%eax
  801871:	74 0a                	je     80187d <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801873:	01 c3                	add    %eax,%ebx
  801875:	39 f3                	cmp    %esi,%ebx
  801877:	72 d9                	jb     801852 <readn+0x16>
  801879:	89 d8                	mov    %ebx,%eax
  80187b:	eb 02                	jmp    80187f <readn+0x43>
  80187d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80187f:	83 c4 1c             	add    $0x1c,%esp
  801882:	5b                   	pop    %ebx
  801883:	5e                   	pop    %esi
  801884:	5f                   	pop    %edi
  801885:	5d                   	pop    %ebp
  801886:	c3                   	ret    

00801887 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801887:	55                   	push   %ebp
  801888:	89 e5                	mov    %esp,%ebp
  80188a:	53                   	push   %ebx
  80188b:	83 ec 24             	sub    $0x24,%esp
  80188e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801891:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801894:	89 44 24 04          	mov    %eax,0x4(%esp)
  801898:	89 1c 24             	mov    %ebx,(%esp)
  80189b:	e8 76 fc ff ff       	call   801516 <fd_lookup>
  8018a0:	89 c2                	mov    %eax,%edx
  8018a2:	85 d2                	test   %edx,%edx
  8018a4:	78 68                	js     80190e <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b0:	8b 00                	mov    (%eax),%eax
  8018b2:	89 04 24             	mov    %eax,(%esp)
  8018b5:	e8 b2 fc ff ff       	call   80156c <dev_lookup>
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	78 50                	js     80190e <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018c5:	75 23                	jne    8018ea <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018c7:	a1 08 50 80 00       	mov    0x805008,%eax
  8018cc:	8b 40 48             	mov    0x48(%eax),%eax
  8018cf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d7:	c7 04 24 a1 30 80 00 	movl   $0x8030a1,(%esp)
  8018de:	e8 34 eb ff ff       	call   800417 <cprintf>
		return -E_INVAL;
  8018e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018e8:	eb 24                	jmp    80190e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ed:	8b 52 0c             	mov    0xc(%edx),%edx
  8018f0:	85 d2                	test   %edx,%edx
  8018f2:	74 15                	je     801909 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018f4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018f7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018fe:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801902:	89 04 24             	mov    %eax,(%esp)
  801905:	ff d2                	call   *%edx
  801907:	eb 05                	jmp    80190e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801909:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80190e:	83 c4 24             	add    $0x24,%esp
  801911:	5b                   	pop    %ebx
  801912:	5d                   	pop    %ebp
  801913:	c3                   	ret    

00801914 <seek>:

int
seek(int fdnum, off_t offset)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80191a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80191d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801921:	8b 45 08             	mov    0x8(%ebp),%eax
  801924:	89 04 24             	mov    %eax,(%esp)
  801927:	e8 ea fb ff ff       	call   801516 <fd_lookup>
  80192c:	85 c0                	test   %eax,%eax
  80192e:	78 0e                	js     80193e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801930:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801933:	8b 55 0c             	mov    0xc(%ebp),%edx
  801936:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801939:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80193e:	c9                   	leave  
  80193f:	c3                   	ret    

00801940 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	53                   	push   %ebx
  801944:	83 ec 24             	sub    $0x24,%esp
  801947:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80194a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80194d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801951:	89 1c 24             	mov    %ebx,(%esp)
  801954:	e8 bd fb ff ff       	call   801516 <fd_lookup>
  801959:	89 c2                	mov    %eax,%edx
  80195b:	85 d2                	test   %edx,%edx
  80195d:	78 61                	js     8019c0 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80195f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801962:	89 44 24 04          	mov    %eax,0x4(%esp)
  801966:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801969:	8b 00                	mov    (%eax),%eax
  80196b:	89 04 24             	mov    %eax,(%esp)
  80196e:	e8 f9 fb ff ff       	call   80156c <dev_lookup>
  801973:	85 c0                	test   %eax,%eax
  801975:	78 49                	js     8019c0 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801977:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80197a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80197e:	75 23                	jne    8019a3 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801980:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801985:	8b 40 48             	mov    0x48(%eax),%eax
  801988:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80198c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801990:	c7 04 24 64 30 80 00 	movl   $0x803064,(%esp)
  801997:	e8 7b ea ff ff       	call   800417 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80199c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019a1:	eb 1d                	jmp    8019c0 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8019a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019a6:	8b 52 18             	mov    0x18(%edx),%edx
  8019a9:	85 d2                	test   %edx,%edx
  8019ab:	74 0e                	je     8019bb <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019b0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019b4:	89 04 24             	mov    %eax,(%esp)
  8019b7:	ff d2                	call   *%edx
  8019b9:	eb 05                	jmp    8019c0 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8019bb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8019c0:	83 c4 24             	add    $0x24,%esp
  8019c3:	5b                   	pop    %ebx
  8019c4:	5d                   	pop    %ebp
  8019c5:	c3                   	ret    

008019c6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019c6:	55                   	push   %ebp
  8019c7:	89 e5                	mov    %esp,%ebp
  8019c9:	53                   	push   %ebx
  8019ca:	83 ec 24             	sub    $0x24,%esp
  8019cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019da:	89 04 24             	mov    %eax,(%esp)
  8019dd:	e8 34 fb ff ff       	call   801516 <fd_lookup>
  8019e2:	89 c2                	mov    %eax,%edx
  8019e4:	85 d2                	test   %edx,%edx
  8019e6:	78 52                	js     801a3a <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019f2:	8b 00                	mov    (%eax),%eax
  8019f4:	89 04 24             	mov    %eax,(%esp)
  8019f7:	e8 70 fb ff ff       	call   80156c <dev_lookup>
  8019fc:	85 c0                	test   %eax,%eax
  8019fe:	78 3a                	js     801a3a <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a03:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a07:	74 2c                	je     801a35 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a09:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a0c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a13:	00 00 00 
	stat->st_isdir = 0;
  801a16:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a1d:	00 00 00 
	stat->st_dev = dev;
  801a20:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a26:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a2a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a2d:	89 14 24             	mov    %edx,(%esp)
  801a30:	ff 50 14             	call   *0x14(%eax)
  801a33:	eb 05                	jmp    801a3a <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a35:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a3a:	83 c4 24             	add    $0x24,%esp
  801a3d:	5b                   	pop    %ebx
  801a3e:	5d                   	pop    %ebp
  801a3f:	c3                   	ret    

00801a40 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	56                   	push   %esi
  801a44:	53                   	push   %ebx
  801a45:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a48:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a4f:	00 
  801a50:	8b 45 08             	mov    0x8(%ebp),%eax
  801a53:	89 04 24             	mov    %eax,(%esp)
  801a56:	e8 28 02 00 00       	call   801c83 <open>
  801a5b:	89 c3                	mov    %eax,%ebx
  801a5d:	85 db                	test   %ebx,%ebx
  801a5f:	78 1b                	js     801a7c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801a61:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a64:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a68:	89 1c 24             	mov    %ebx,(%esp)
  801a6b:	e8 56 ff ff ff       	call   8019c6 <fstat>
  801a70:	89 c6                	mov    %eax,%esi
	close(fd);
  801a72:	89 1c 24             	mov    %ebx,(%esp)
  801a75:	e8 cd fb ff ff       	call   801647 <close>
	return r;
  801a7a:	89 f0                	mov    %esi,%eax
}
  801a7c:	83 c4 10             	add    $0x10,%esp
  801a7f:	5b                   	pop    %ebx
  801a80:	5e                   	pop    %esi
  801a81:	5d                   	pop    %ebp
  801a82:	c3                   	ret    

00801a83 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a83:	55                   	push   %ebp
  801a84:	89 e5                	mov    %esp,%ebp
  801a86:	56                   	push   %esi
  801a87:	53                   	push   %ebx
  801a88:	83 ec 10             	sub    $0x10,%esp
  801a8b:	89 c6                	mov    %eax,%esi
  801a8d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a8f:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801a96:	75 11                	jne    801aa9 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a98:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a9f:	e8 11 0e 00 00       	call   8028b5 <ipc_find_env>
  801aa4:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801aa9:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801ab0:	00 
  801ab1:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801ab8:	00 
  801ab9:	89 74 24 04          	mov    %esi,0x4(%esp)
  801abd:	a1 00 50 80 00       	mov    0x805000,%eax
  801ac2:	89 04 24             	mov    %eax,(%esp)
  801ac5:	e8 80 0d 00 00       	call   80284a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801aca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ad1:	00 
  801ad2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ad6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801add:	e8 ee 0c 00 00       	call   8027d0 <ipc_recv>
}
  801ae2:	83 c4 10             	add    $0x10,%esp
  801ae5:	5b                   	pop    %ebx
  801ae6:	5e                   	pop    %esi
  801ae7:	5d                   	pop    %ebp
  801ae8:	c3                   	ret    

00801ae9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ae9:	55                   	push   %ebp
  801aea:	89 e5                	mov    %esp,%ebp
  801aec:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801aef:	8b 45 08             	mov    0x8(%ebp),%eax
  801af2:	8b 40 0c             	mov    0xc(%eax),%eax
  801af5:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801afa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801afd:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b02:	ba 00 00 00 00       	mov    $0x0,%edx
  801b07:	b8 02 00 00 00       	mov    $0x2,%eax
  801b0c:	e8 72 ff ff ff       	call   801a83 <fsipc>
}
  801b11:	c9                   	leave  
  801b12:	c3                   	ret    

00801b13 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b19:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1c:	8b 40 0c             	mov    0xc(%eax),%eax
  801b1f:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b24:	ba 00 00 00 00       	mov    $0x0,%edx
  801b29:	b8 06 00 00 00       	mov    $0x6,%eax
  801b2e:	e8 50 ff ff ff       	call   801a83 <fsipc>
}
  801b33:	c9                   	leave  
  801b34:	c3                   	ret    

00801b35 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	53                   	push   %ebx
  801b39:	83 ec 14             	sub    $0x14,%esp
  801b3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b42:	8b 40 0c             	mov    0xc(%eax),%eax
  801b45:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b4a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b4f:	b8 05 00 00 00       	mov    $0x5,%eax
  801b54:	e8 2a ff ff ff       	call   801a83 <fsipc>
  801b59:	89 c2                	mov    %eax,%edx
  801b5b:	85 d2                	test   %edx,%edx
  801b5d:	78 2b                	js     801b8a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b5f:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801b66:	00 
  801b67:	89 1c 24             	mov    %ebx,(%esp)
  801b6a:	e8 d8 ee ff ff       	call   800a47 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b6f:	a1 80 60 80 00       	mov    0x806080,%eax
  801b74:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b7a:	a1 84 60 80 00       	mov    0x806084,%eax
  801b7f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b85:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b8a:	83 c4 14             	add    $0x14,%esp
  801b8d:	5b                   	pop    %ebx
  801b8e:	5d                   	pop    %ebp
  801b8f:	c3                   	ret    

00801b90 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	83 ec 18             	sub    $0x18,%esp
  801b96:	8b 45 10             	mov    0x10(%ebp),%eax
  801b99:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b9e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801ba3:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ba6:	8b 55 08             	mov    0x8(%ebp),%edx
  801ba9:	8b 52 0c             	mov    0xc(%edx),%edx
  801bac:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801bb2:	a3 04 60 80 00       	mov    %eax,0x806004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801bb7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bbe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc2:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801bc9:	e8 16 f0 ff ff       	call   800be4 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  801bce:	ba 00 00 00 00       	mov    $0x0,%edx
  801bd3:	b8 04 00 00 00       	mov    $0x4,%eax
  801bd8:	e8 a6 fe ff ff       	call   801a83 <fsipc>
}
  801bdd:	c9                   	leave  
  801bde:	c3                   	ret    

00801bdf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	56                   	push   %esi
  801be3:	53                   	push   %ebx
  801be4:	83 ec 10             	sub    $0x10,%esp
  801be7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801bea:	8b 45 08             	mov    0x8(%ebp),%eax
  801bed:	8b 40 0c             	mov    0xc(%eax),%eax
  801bf0:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801bf5:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bfb:	ba 00 00 00 00       	mov    $0x0,%edx
  801c00:	b8 03 00 00 00       	mov    $0x3,%eax
  801c05:	e8 79 fe ff ff       	call   801a83 <fsipc>
  801c0a:	89 c3                	mov    %eax,%ebx
  801c0c:	85 c0                	test   %eax,%eax
  801c0e:	78 6a                	js     801c7a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801c10:	39 c6                	cmp    %eax,%esi
  801c12:	73 24                	jae    801c38 <devfile_read+0x59>
  801c14:	c7 44 24 0c d4 30 80 	movl   $0x8030d4,0xc(%esp)
  801c1b:	00 
  801c1c:	c7 44 24 08 db 30 80 	movl   $0x8030db,0x8(%esp)
  801c23:	00 
  801c24:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801c2b:	00 
  801c2c:	c7 04 24 f0 30 80 00 	movl   $0x8030f0,(%esp)
  801c33:	e8 e6 e6 ff ff       	call   80031e <_panic>
	assert(r <= PGSIZE);
  801c38:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c3d:	7e 24                	jle    801c63 <devfile_read+0x84>
  801c3f:	c7 44 24 0c fb 30 80 	movl   $0x8030fb,0xc(%esp)
  801c46:	00 
  801c47:	c7 44 24 08 db 30 80 	movl   $0x8030db,0x8(%esp)
  801c4e:	00 
  801c4f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801c56:	00 
  801c57:	c7 04 24 f0 30 80 00 	movl   $0x8030f0,(%esp)
  801c5e:	e8 bb e6 ff ff       	call   80031e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c63:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c67:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801c6e:	00 
  801c6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c72:	89 04 24             	mov    %eax,(%esp)
  801c75:	e8 6a ef ff ff       	call   800be4 <memmove>
	return r;
}
  801c7a:	89 d8                	mov    %ebx,%eax
  801c7c:	83 c4 10             	add    $0x10,%esp
  801c7f:	5b                   	pop    %ebx
  801c80:	5e                   	pop    %esi
  801c81:	5d                   	pop    %ebp
  801c82:	c3                   	ret    

00801c83 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c83:	55                   	push   %ebp
  801c84:	89 e5                	mov    %esp,%ebp
  801c86:	53                   	push   %ebx
  801c87:	83 ec 24             	sub    $0x24,%esp
  801c8a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c8d:	89 1c 24             	mov    %ebx,(%esp)
  801c90:	e8 7b ed ff ff       	call   800a10 <strlen>
  801c95:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c9a:	7f 60                	jg     801cfc <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c9f:	89 04 24             	mov    %eax,(%esp)
  801ca2:	e8 20 f8 ff ff       	call   8014c7 <fd_alloc>
  801ca7:	89 c2                	mov    %eax,%edx
  801ca9:	85 d2                	test   %edx,%edx
  801cab:	78 54                	js     801d01 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801cad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cb1:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801cb8:	e8 8a ed ff ff       	call   800a47 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801cbd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc0:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801cc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cc8:	b8 01 00 00 00       	mov    $0x1,%eax
  801ccd:	e8 b1 fd ff ff       	call   801a83 <fsipc>
  801cd2:	89 c3                	mov    %eax,%ebx
  801cd4:	85 c0                	test   %eax,%eax
  801cd6:	79 17                	jns    801cef <open+0x6c>
		fd_close(fd, 0);
  801cd8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801cdf:	00 
  801ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce3:	89 04 24             	mov    %eax,(%esp)
  801ce6:	e8 db f8 ff ff       	call   8015c6 <fd_close>
		return r;
  801ceb:	89 d8                	mov    %ebx,%eax
  801ced:	eb 12                	jmp    801d01 <open+0x7e>
	}

	return fd2num(fd);
  801cef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf2:	89 04 24             	mov    %eax,(%esp)
  801cf5:	e8 a6 f7 ff ff       	call   8014a0 <fd2num>
  801cfa:	eb 05                	jmp    801d01 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801cfc:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801d01:	83 c4 24             	add    $0x24,%esp
  801d04:	5b                   	pop    %ebx
  801d05:	5d                   	pop    %ebp
  801d06:	c3                   	ret    

00801d07 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801d07:	55                   	push   %ebp
  801d08:	89 e5                	mov    %esp,%ebp
  801d0a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d0d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d12:	b8 08 00 00 00       	mov    $0x8,%eax
  801d17:	e8 67 fd ff ff       	call   801a83 <fsipc>
}
  801d1c:	c9                   	leave  
  801d1d:	c3                   	ret    
  801d1e:	66 90                	xchg   %ax,%ax

00801d20 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
  801d23:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801d26:	c7 44 24 04 07 31 80 	movl   $0x803107,0x4(%esp)
  801d2d:	00 
  801d2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d31:	89 04 24             	mov    %eax,(%esp)
  801d34:	e8 0e ed ff ff       	call   800a47 <strcpy>
	return 0;
}
  801d39:	b8 00 00 00 00       	mov    $0x0,%eax
  801d3e:	c9                   	leave  
  801d3f:	c3                   	ret    

00801d40 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	53                   	push   %ebx
  801d44:	83 ec 14             	sub    $0x14,%esp
  801d47:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801d4a:	89 1c 24             	mov    %ebx,(%esp)
  801d4d:	e8 9b 0b 00 00       	call   8028ed <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801d52:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801d57:	83 f8 01             	cmp    $0x1,%eax
  801d5a:	75 0d                	jne    801d69 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801d5c:	8b 43 0c             	mov    0xc(%ebx),%eax
  801d5f:	89 04 24             	mov    %eax,(%esp)
  801d62:	e8 29 03 00 00       	call   802090 <nsipc_close>
  801d67:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  801d69:	89 d0                	mov    %edx,%eax
  801d6b:	83 c4 14             	add    $0x14,%esp
  801d6e:	5b                   	pop    %ebx
  801d6f:	5d                   	pop    %ebp
  801d70:	c3                   	ret    

00801d71 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801d71:	55                   	push   %ebp
  801d72:	89 e5                	mov    %esp,%ebp
  801d74:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801d77:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801d7e:	00 
  801d7f:	8b 45 10             	mov    0x10(%ebp),%eax
  801d82:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d86:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d89:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d90:	8b 40 0c             	mov    0xc(%eax),%eax
  801d93:	89 04 24             	mov    %eax,(%esp)
  801d96:	e8 f0 03 00 00       	call   80218b <nsipc_send>
}
  801d9b:	c9                   	leave  
  801d9c:	c3                   	ret    

00801d9d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801d9d:	55                   	push   %ebp
  801d9e:	89 e5                	mov    %esp,%ebp
  801da0:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801da3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801daa:	00 
  801dab:	8b 45 10             	mov    0x10(%ebp),%eax
  801dae:	89 44 24 08          	mov    %eax,0x8(%esp)
  801db2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801db5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801db9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbc:	8b 40 0c             	mov    0xc(%eax),%eax
  801dbf:	89 04 24             	mov    %eax,(%esp)
  801dc2:	e8 44 03 00 00       	call   80210b <nsipc_recv>
}
  801dc7:	c9                   	leave  
  801dc8:	c3                   	ret    

00801dc9 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801dc9:	55                   	push   %ebp
  801dca:	89 e5                	mov    %esp,%ebp
  801dcc:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801dcf:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801dd2:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dd6:	89 04 24             	mov    %eax,(%esp)
  801dd9:	e8 38 f7 ff ff       	call   801516 <fd_lookup>
  801dde:	85 c0                	test   %eax,%eax
  801de0:	78 17                	js     801df9 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801de2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de5:	8b 0d 20 40 80 00    	mov    0x804020,%ecx
  801deb:	39 08                	cmp    %ecx,(%eax)
  801ded:	75 05                	jne    801df4 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801def:	8b 40 0c             	mov    0xc(%eax),%eax
  801df2:	eb 05                	jmp    801df9 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801df4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801df9:	c9                   	leave  
  801dfa:	c3                   	ret    

00801dfb <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801dfb:	55                   	push   %ebp
  801dfc:	89 e5                	mov    %esp,%ebp
  801dfe:	56                   	push   %esi
  801dff:	53                   	push   %ebx
  801e00:	83 ec 20             	sub    $0x20,%esp
  801e03:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801e05:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e08:	89 04 24             	mov    %eax,(%esp)
  801e0b:	e8 b7 f6 ff ff       	call   8014c7 <fd_alloc>
  801e10:	89 c3                	mov    %eax,%ebx
  801e12:	85 c0                	test   %eax,%eax
  801e14:	78 21                	js     801e37 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801e16:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e1d:	00 
  801e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e21:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e2c:	e8 32 f0 ff ff       	call   800e63 <sys_page_alloc>
  801e31:	89 c3                	mov    %eax,%ebx
  801e33:	85 c0                	test   %eax,%eax
  801e35:	79 0c                	jns    801e43 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  801e37:	89 34 24             	mov    %esi,(%esp)
  801e3a:	e8 51 02 00 00       	call   802090 <nsipc_close>
		return r;
  801e3f:	89 d8                	mov    %ebx,%eax
  801e41:	eb 20                	jmp    801e63 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801e43:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801e49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801e4e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e51:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801e58:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801e5b:	89 14 24             	mov    %edx,(%esp)
  801e5e:	e8 3d f6 ff ff       	call   8014a0 <fd2num>
}
  801e63:	83 c4 20             	add    $0x20,%esp
  801e66:	5b                   	pop    %ebx
  801e67:	5e                   	pop    %esi
  801e68:	5d                   	pop    %ebp
  801e69:	c3                   	ret    

00801e6a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e6a:	55                   	push   %ebp
  801e6b:	89 e5                	mov    %esp,%ebp
  801e6d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e70:	8b 45 08             	mov    0x8(%ebp),%eax
  801e73:	e8 51 ff ff ff       	call   801dc9 <fd2sockid>
		return r;
  801e78:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e7a:	85 c0                	test   %eax,%eax
  801e7c:	78 23                	js     801ea1 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e7e:	8b 55 10             	mov    0x10(%ebp),%edx
  801e81:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e85:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e88:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e8c:	89 04 24             	mov    %eax,(%esp)
  801e8f:	e8 45 01 00 00       	call   801fd9 <nsipc_accept>
		return r;
  801e94:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e96:	85 c0                	test   %eax,%eax
  801e98:	78 07                	js     801ea1 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  801e9a:	e8 5c ff ff ff       	call   801dfb <alloc_sockfd>
  801e9f:	89 c1                	mov    %eax,%ecx
}
  801ea1:	89 c8                	mov    %ecx,%eax
  801ea3:	c9                   	leave  
  801ea4:	c3                   	ret    

00801ea5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ea5:	55                   	push   %ebp
  801ea6:	89 e5                	mov    %esp,%ebp
  801ea8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801eab:	8b 45 08             	mov    0x8(%ebp),%eax
  801eae:	e8 16 ff ff ff       	call   801dc9 <fd2sockid>
  801eb3:	89 c2                	mov    %eax,%edx
  801eb5:	85 d2                	test   %edx,%edx
  801eb7:	78 16                	js     801ecf <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  801eb9:	8b 45 10             	mov    0x10(%ebp),%eax
  801ebc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec7:	89 14 24             	mov    %edx,(%esp)
  801eca:	e8 60 01 00 00       	call   80202f <nsipc_bind>
}
  801ecf:	c9                   	leave  
  801ed0:	c3                   	ret    

00801ed1 <shutdown>:

int
shutdown(int s, int how)
{
  801ed1:	55                   	push   %ebp
  801ed2:	89 e5                	mov    %esp,%ebp
  801ed4:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ed7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eda:	e8 ea fe ff ff       	call   801dc9 <fd2sockid>
  801edf:	89 c2                	mov    %eax,%edx
  801ee1:	85 d2                	test   %edx,%edx
  801ee3:	78 0f                	js     801ef4 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801ee5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eec:	89 14 24             	mov    %edx,(%esp)
  801eef:	e8 7a 01 00 00       	call   80206e <nsipc_shutdown>
}
  801ef4:	c9                   	leave  
  801ef5:	c3                   	ret    

00801ef6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ef6:	55                   	push   %ebp
  801ef7:	89 e5                	mov    %esp,%ebp
  801ef9:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801efc:	8b 45 08             	mov    0x8(%ebp),%eax
  801eff:	e8 c5 fe ff ff       	call   801dc9 <fd2sockid>
  801f04:	89 c2                	mov    %eax,%edx
  801f06:	85 d2                	test   %edx,%edx
  801f08:	78 16                	js     801f20 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  801f0a:	8b 45 10             	mov    0x10(%ebp),%eax
  801f0d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f11:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f14:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f18:	89 14 24             	mov    %edx,(%esp)
  801f1b:	e8 8a 01 00 00       	call   8020aa <nsipc_connect>
}
  801f20:	c9                   	leave  
  801f21:	c3                   	ret    

00801f22 <listen>:

int
listen(int s, int backlog)
{
  801f22:	55                   	push   %ebp
  801f23:	89 e5                	mov    %esp,%ebp
  801f25:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f28:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2b:	e8 99 fe ff ff       	call   801dc9 <fd2sockid>
  801f30:	89 c2                	mov    %eax,%edx
  801f32:	85 d2                	test   %edx,%edx
  801f34:	78 0f                	js     801f45 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801f36:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f39:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f3d:	89 14 24             	mov    %edx,(%esp)
  801f40:	e8 a4 01 00 00       	call   8020e9 <nsipc_listen>
}
  801f45:	c9                   	leave  
  801f46:	c3                   	ret    

00801f47 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801f47:	55                   	push   %ebp
  801f48:	89 e5                	mov    %esp,%ebp
  801f4a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f4d:	8b 45 10             	mov    0x10(%ebp),%eax
  801f50:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f54:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f57:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5e:	89 04 24             	mov    %eax,(%esp)
  801f61:	e8 98 02 00 00       	call   8021fe <nsipc_socket>
  801f66:	89 c2                	mov    %eax,%edx
  801f68:	85 d2                	test   %edx,%edx
  801f6a:	78 05                	js     801f71 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  801f6c:	e8 8a fe ff ff       	call   801dfb <alloc_sockfd>
}
  801f71:	c9                   	leave  
  801f72:	c3                   	ret    

00801f73 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801f73:	55                   	push   %ebp
  801f74:	89 e5                	mov    %esp,%ebp
  801f76:	53                   	push   %ebx
  801f77:	83 ec 14             	sub    $0x14,%esp
  801f7a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801f7c:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801f83:	75 11                	jne    801f96 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801f85:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801f8c:	e8 24 09 00 00       	call   8028b5 <ipc_find_env>
  801f91:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801f96:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801f9d:	00 
  801f9e:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801fa5:	00 
  801fa6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801faa:	a1 04 50 80 00       	mov    0x805004,%eax
  801faf:	89 04 24             	mov    %eax,(%esp)
  801fb2:	e8 93 08 00 00       	call   80284a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801fb7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801fbe:	00 
  801fbf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801fc6:	00 
  801fc7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fce:	e8 fd 07 00 00       	call   8027d0 <ipc_recv>
}
  801fd3:	83 c4 14             	add    $0x14,%esp
  801fd6:	5b                   	pop    %ebx
  801fd7:	5d                   	pop    %ebp
  801fd8:	c3                   	ret    

00801fd9 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801fd9:	55                   	push   %ebp
  801fda:	89 e5                	mov    %esp,%ebp
  801fdc:	56                   	push   %esi
  801fdd:	53                   	push   %ebx
  801fde:	83 ec 10             	sub    $0x10,%esp
  801fe1:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801fe4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801fec:	8b 06                	mov    (%esi),%eax
  801fee:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ff3:	b8 01 00 00 00       	mov    $0x1,%eax
  801ff8:	e8 76 ff ff ff       	call   801f73 <nsipc>
  801ffd:	89 c3                	mov    %eax,%ebx
  801fff:	85 c0                	test   %eax,%eax
  802001:	78 23                	js     802026 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802003:	a1 10 70 80 00       	mov    0x807010,%eax
  802008:	89 44 24 08          	mov    %eax,0x8(%esp)
  80200c:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802013:	00 
  802014:	8b 45 0c             	mov    0xc(%ebp),%eax
  802017:	89 04 24             	mov    %eax,(%esp)
  80201a:	e8 c5 eb ff ff       	call   800be4 <memmove>
		*addrlen = ret->ret_addrlen;
  80201f:	a1 10 70 80 00       	mov    0x807010,%eax
  802024:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  802026:	89 d8                	mov    %ebx,%eax
  802028:	83 c4 10             	add    $0x10,%esp
  80202b:	5b                   	pop    %ebx
  80202c:	5e                   	pop    %esi
  80202d:	5d                   	pop    %ebp
  80202e:	c3                   	ret    

0080202f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80202f:	55                   	push   %ebp
  802030:	89 e5                	mov    %esp,%ebp
  802032:	53                   	push   %ebx
  802033:	83 ec 14             	sub    $0x14,%esp
  802036:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802039:	8b 45 08             	mov    0x8(%ebp),%eax
  80203c:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802041:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802045:	8b 45 0c             	mov    0xc(%ebp),%eax
  802048:	89 44 24 04          	mov    %eax,0x4(%esp)
  80204c:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802053:	e8 8c eb ff ff       	call   800be4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802058:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80205e:	b8 02 00 00 00       	mov    $0x2,%eax
  802063:	e8 0b ff ff ff       	call   801f73 <nsipc>
}
  802068:	83 c4 14             	add    $0x14,%esp
  80206b:	5b                   	pop    %ebx
  80206c:	5d                   	pop    %ebp
  80206d:	c3                   	ret    

0080206e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80206e:	55                   	push   %ebp
  80206f:	89 e5                	mov    %esp,%ebp
  802071:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802074:	8b 45 08             	mov    0x8(%ebp),%eax
  802077:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80207c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80207f:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802084:	b8 03 00 00 00       	mov    $0x3,%eax
  802089:	e8 e5 fe ff ff       	call   801f73 <nsipc>
}
  80208e:	c9                   	leave  
  80208f:	c3                   	ret    

00802090 <nsipc_close>:

int
nsipc_close(int s)
{
  802090:	55                   	push   %ebp
  802091:	89 e5                	mov    %esp,%ebp
  802093:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802096:	8b 45 08             	mov    0x8(%ebp),%eax
  802099:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  80209e:	b8 04 00 00 00       	mov    $0x4,%eax
  8020a3:	e8 cb fe ff ff       	call   801f73 <nsipc>
}
  8020a8:	c9                   	leave  
  8020a9:	c3                   	ret    

008020aa <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020aa:	55                   	push   %ebp
  8020ab:	89 e5                	mov    %esp,%ebp
  8020ad:	53                   	push   %ebx
  8020ae:	83 ec 14             	sub    $0x14,%esp
  8020b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8020b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b7:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8020bc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020c7:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8020ce:	e8 11 eb ff ff       	call   800be4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8020d3:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8020d9:	b8 05 00 00 00       	mov    $0x5,%eax
  8020de:	e8 90 fe ff ff       	call   801f73 <nsipc>
}
  8020e3:	83 c4 14             	add    $0x14,%esp
  8020e6:	5b                   	pop    %ebx
  8020e7:	5d                   	pop    %ebp
  8020e8:	c3                   	ret    

008020e9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8020e9:	55                   	push   %ebp
  8020ea:	89 e5                	mov    %esp,%ebp
  8020ec:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8020ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8020f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020fa:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8020ff:	b8 06 00 00 00       	mov    $0x6,%eax
  802104:	e8 6a fe ff ff       	call   801f73 <nsipc>
}
  802109:	c9                   	leave  
  80210a:	c3                   	ret    

0080210b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80210b:	55                   	push   %ebp
  80210c:	89 e5                	mov    %esp,%ebp
  80210e:	56                   	push   %esi
  80210f:	53                   	push   %ebx
  802110:	83 ec 10             	sub    $0x10,%esp
  802113:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802116:	8b 45 08             	mov    0x8(%ebp),%eax
  802119:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  80211e:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802124:	8b 45 14             	mov    0x14(%ebp),%eax
  802127:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80212c:	b8 07 00 00 00       	mov    $0x7,%eax
  802131:	e8 3d fe ff ff       	call   801f73 <nsipc>
  802136:	89 c3                	mov    %eax,%ebx
  802138:	85 c0                	test   %eax,%eax
  80213a:	78 46                	js     802182 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  80213c:	39 f0                	cmp    %esi,%eax
  80213e:	7f 07                	jg     802147 <nsipc_recv+0x3c>
  802140:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802145:	7e 24                	jle    80216b <nsipc_recv+0x60>
  802147:	c7 44 24 0c 13 31 80 	movl   $0x803113,0xc(%esp)
  80214e:	00 
  80214f:	c7 44 24 08 db 30 80 	movl   $0x8030db,0x8(%esp)
  802156:	00 
  802157:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80215e:	00 
  80215f:	c7 04 24 28 31 80 00 	movl   $0x803128,(%esp)
  802166:	e8 b3 e1 ff ff       	call   80031e <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80216b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80216f:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802176:	00 
  802177:	8b 45 0c             	mov    0xc(%ebp),%eax
  80217a:	89 04 24             	mov    %eax,(%esp)
  80217d:	e8 62 ea ff ff       	call   800be4 <memmove>
	}

	return r;
}
  802182:	89 d8                	mov    %ebx,%eax
  802184:	83 c4 10             	add    $0x10,%esp
  802187:	5b                   	pop    %ebx
  802188:	5e                   	pop    %esi
  802189:	5d                   	pop    %ebp
  80218a:	c3                   	ret    

0080218b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80218b:	55                   	push   %ebp
  80218c:	89 e5                	mov    %esp,%ebp
  80218e:	53                   	push   %ebx
  80218f:	83 ec 14             	sub    $0x14,%esp
  802192:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802195:	8b 45 08             	mov    0x8(%ebp),%eax
  802198:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  80219d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8021a3:	7e 24                	jle    8021c9 <nsipc_send+0x3e>
  8021a5:	c7 44 24 0c 34 31 80 	movl   $0x803134,0xc(%esp)
  8021ac:	00 
  8021ad:	c7 44 24 08 db 30 80 	movl   $0x8030db,0x8(%esp)
  8021b4:	00 
  8021b5:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8021bc:	00 
  8021bd:	c7 04 24 28 31 80 00 	movl   $0x803128,(%esp)
  8021c4:	e8 55 e1 ff ff       	call   80031e <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8021c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021d4:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  8021db:	e8 04 ea ff ff       	call   800be4 <memmove>
	nsipcbuf.send.req_size = size;
  8021e0:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8021e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8021e9:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8021ee:	b8 08 00 00 00       	mov    $0x8,%eax
  8021f3:	e8 7b fd ff ff       	call   801f73 <nsipc>
}
  8021f8:	83 c4 14             	add    $0x14,%esp
  8021fb:	5b                   	pop    %ebx
  8021fc:	5d                   	pop    %ebp
  8021fd:	c3                   	ret    

008021fe <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8021fe:	55                   	push   %ebp
  8021ff:	89 e5                	mov    %esp,%ebp
  802201:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802204:	8b 45 08             	mov    0x8(%ebp),%eax
  802207:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  80220c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80220f:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802214:	8b 45 10             	mov    0x10(%ebp),%eax
  802217:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  80221c:	b8 09 00 00 00       	mov    $0x9,%eax
  802221:	e8 4d fd ff ff       	call   801f73 <nsipc>
}
  802226:	c9                   	leave  
  802227:	c3                   	ret    

00802228 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802228:	55                   	push   %ebp
  802229:	89 e5                	mov    %esp,%ebp
  80222b:	56                   	push   %esi
  80222c:	53                   	push   %ebx
  80222d:	83 ec 10             	sub    $0x10,%esp
  802230:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802233:	8b 45 08             	mov    0x8(%ebp),%eax
  802236:	89 04 24             	mov    %eax,(%esp)
  802239:	e8 72 f2 ff ff       	call   8014b0 <fd2data>
  80223e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802240:	c7 44 24 04 40 31 80 	movl   $0x803140,0x4(%esp)
  802247:	00 
  802248:	89 1c 24             	mov    %ebx,(%esp)
  80224b:	e8 f7 e7 ff ff       	call   800a47 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802250:	8b 46 04             	mov    0x4(%esi),%eax
  802253:	2b 06                	sub    (%esi),%eax
  802255:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80225b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802262:	00 00 00 
	stat->st_dev = &devpipe;
  802265:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  80226c:	40 80 00 
	return 0;
}
  80226f:	b8 00 00 00 00       	mov    $0x0,%eax
  802274:	83 c4 10             	add    $0x10,%esp
  802277:	5b                   	pop    %ebx
  802278:	5e                   	pop    %esi
  802279:	5d                   	pop    %ebp
  80227a:	c3                   	ret    

0080227b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80227b:	55                   	push   %ebp
  80227c:	89 e5                	mov    %esp,%ebp
  80227e:	53                   	push   %ebx
  80227f:	83 ec 14             	sub    $0x14,%esp
  802282:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802285:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802289:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802290:	e8 75 ec ff ff       	call   800f0a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802295:	89 1c 24             	mov    %ebx,(%esp)
  802298:	e8 13 f2 ff ff       	call   8014b0 <fd2data>
  80229d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022a8:	e8 5d ec ff ff       	call   800f0a <sys_page_unmap>
}
  8022ad:	83 c4 14             	add    $0x14,%esp
  8022b0:	5b                   	pop    %ebx
  8022b1:	5d                   	pop    %ebp
  8022b2:	c3                   	ret    

008022b3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8022b3:	55                   	push   %ebp
  8022b4:	89 e5                	mov    %esp,%ebp
  8022b6:	57                   	push   %edi
  8022b7:	56                   	push   %esi
  8022b8:	53                   	push   %ebx
  8022b9:	83 ec 2c             	sub    $0x2c,%esp
  8022bc:	89 c6                	mov    %eax,%esi
  8022be:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8022c1:	a1 08 50 80 00       	mov    0x805008,%eax
  8022c6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8022c9:	89 34 24             	mov    %esi,(%esp)
  8022cc:	e8 1c 06 00 00       	call   8028ed <pageref>
  8022d1:	89 c7                	mov    %eax,%edi
  8022d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022d6:	89 04 24             	mov    %eax,(%esp)
  8022d9:	e8 0f 06 00 00       	call   8028ed <pageref>
  8022de:	39 c7                	cmp    %eax,%edi
  8022e0:	0f 94 c2             	sete   %dl
  8022e3:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8022e6:	8b 0d 08 50 80 00    	mov    0x805008,%ecx
  8022ec:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8022ef:	39 fb                	cmp    %edi,%ebx
  8022f1:	74 21                	je     802314 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8022f3:	84 d2                	test   %dl,%dl
  8022f5:	74 ca                	je     8022c1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8022f7:	8b 51 58             	mov    0x58(%ecx),%edx
  8022fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022fe:	89 54 24 08          	mov    %edx,0x8(%esp)
  802302:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802306:	c7 04 24 47 31 80 00 	movl   $0x803147,(%esp)
  80230d:	e8 05 e1 ff ff       	call   800417 <cprintf>
  802312:	eb ad                	jmp    8022c1 <_pipeisclosed+0xe>
	}
}
  802314:	83 c4 2c             	add    $0x2c,%esp
  802317:	5b                   	pop    %ebx
  802318:	5e                   	pop    %esi
  802319:	5f                   	pop    %edi
  80231a:	5d                   	pop    %ebp
  80231b:	c3                   	ret    

0080231c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80231c:	55                   	push   %ebp
  80231d:	89 e5                	mov    %esp,%ebp
  80231f:	57                   	push   %edi
  802320:	56                   	push   %esi
  802321:	53                   	push   %ebx
  802322:	83 ec 1c             	sub    $0x1c,%esp
  802325:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802328:	89 34 24             	mov    %esi,(%esp)
  80232b:	e8 80 f1 ff ff       	call   8014b0 <fd2data>
  802330:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802332:	bf 00 00 00 00       	mov    $0x0,%edi
  802337:	eb 45                	jmp    80237e <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802339:	89 da                	mov    %ebx,%edx
  80233b:	89 f0                	mov    %esi,%eax
  80233d:	e8 71 ff ff ff       	call   8022b3 <_pipeisclosed>
  802342:	85 c0                	test   %eax,%eax
  802344:	75 41                	jne    802387 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802346:	e8 f9 ea ff ff       	call   800e44 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80234b:	8b 43 04             	mov    0x4(%ebx),%eax
  80234e:	8b 0b                	mov    (%ebx),%ecx
  802350:	8d 51 20             	lea    0x20(%ecx),%edx
  802353:	39 d0                	cmp    %edx,%eax
  802355:	73 e2                	jae    802339 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802357:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80235a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80235e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802361:	99                   	cltd   
  802362:	c1 ea 1b             	shr    $0x1b,%edx
  802365:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802368:	83 e1 1f             	and    $0x1f,%ecx
  80236b:	29 d1                	sub    %edx,%ecx
  80236d:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  802371:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  802375:	83 c0 01             	add    $0x1,%eax
  802378:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80237b:	83 c7 01             	add    $0x1,%edi
  80237e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802381:	75 c8                	jne    80234b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802383:	89 f8                	mov    %edi,%eax
  802385:	eb 05                	jmp    80238c <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802387:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80238c:	83 c4 1c             	add    $0x1c,%esp
  80238f:	5b                   	pop    %ebx
  802390:	5e                   	pop    %esi
  802391:	5f                   	pop    %edi
  802392:	5d                   	pop    %ebp
  802393:	c3                   	ret    

00802394 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802394:	55                   	push   %ebp
  802395:	89 e5                	mov    %esp,%ebp
  802397:	57                   	push   %edi
  802398:	56                   	push   %esi
  802399:	53                   	push   %ebx
  80239a:	83 ec 1c             	sub    $0x1c,%esp
  80239d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8023a0:	89 3c 24             	mov    %edi,(%esp)
  8023a3:	e8 08 f1 ff ff       	call   8014b0 <fd2data>
  8023a8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023aa:	be 00 00 00 00       	mov    $0x0,%esi
  8023af:	eb 3d                	jmp    8023ee <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8023b1:	85 f6                	test   %esi,%esi
  8023b3:	74 04                	je     8023b9 <devpipe_read+0x25>
				return i;
  8023b5:	89 f0                	mov    %esi,%eax
  8023b7:	eb 43                	jmp    8023fc <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8023b9:	89 da                	mov    %ebx,%edx
  8023bb:	89 f8                	mov    %edi,%eax
  8023bd:	e8 f1 fe ff ff       	call   8022b3 <_pipeisclosed>
  8023c2:	85 c0                	test   %eax,%eax
  8023c4:	75 31                	jne    8023f7 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8023c6:	e8 79 ea ff ff       	call   800e44 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8023cb:	8b 03                	mov    (%ebx),%eax
  8023cd:	3b 43 04             	cmp    0x4(%ebx),%eax
  8023d0:	74 df                	je     8023b1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8023d2:	99                   	cltd   
  8023d3:	c1 ea 1b             	shr    $0x1b,%edx
  8023d6:	01 d0                	add    %edx,%eax
  8023d8:	83 e0 1f             	and    $0x1f,%eax
  8023db:	29 d0                	sub    %edx,%eax
  8023dd:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8023e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023e5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8023e8:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023eb:	83 c6 01             	add    $0x1,%esi
  8023ee:	3b 75 10             	cmp    0x10(%ebp),%esi
  8023f1:	75 d8                	jne    8023cb <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8023f3:	89 f0                	mov    %esi,%eax
  8023f5:	eb 05                	jmp    8023fc <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023f7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8023fc:	83 c4 1c             	add    $0x1c,%esp
  8023ff:	5b                   	pop    %ebx
  802400:	5e                   	pop    %esi
  802401:	5f                   	pop    %edi
  802402:	5d                   	pop    %ebp
  802403:	c3                   	ret    

00802404 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802404:	55                   	push   %ebp
  802405:	89 e5                	mov    %esp,%ebp
  802407:	56                   	push   %esi
  802408:	53                   	push   %ebx
  802409:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80240c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80240f:	89 04 24             	mov    %eax,(%esp)
  802412:	e8 b0 f0 ff ff       	call   8014c7 <fd_alloc>
  802417:	89 c2                	mov    %eax,%edx
  802419:	85 d2                	test   %edx,%edx
  80241b:	0f 88 4d 01 00 00    	js     80256e <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802421:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802428:	00 
  802429:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80242c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802430:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802437:	e8 27 ea ff ff       	call   800e63 <sys_page_alloc>
  80243c:	89 c2                	mov    %eax,%edx
  80243e:	85 d2                	test   %edx,%edx
  802440:	0f 88 28 01 00 00    	js     80256e <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802446:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802449:	89 04 24             	mov    %eax,(%esp)
  80244c:	e8 76 f0 ff ff       	call   8014c7 <fd_alloc>
  802451:	89 c3                	mov    %eax,%ebx
  802453:	85 c0                	test   %eax,%eax
  802455:	0f 88 fe 00 00 00    	js     802559 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80245b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802462:	00 
  802463:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802466:	89 44 24 04          	mov    %eax,0x4(%esp)
  80246a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802471:	e8 ed e9 ff ff       	call   800e63 <sys_page_alloc>
  802476:	89 c3                	mov    %eax,%ebx
  802478:	85 c0                	test   %eax,%eax
  80247a:	0f 88 d9 00 00 00    	js     802559 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802480:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802483:	89 04 24             	mov    %eax,(%esp)
  802486:	e8 25 f0 ff ff       	call   8014b0 <fd2data>
  80248b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80248d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802494:	00 
  802495:	89 44 24 04          	mov    %eax,0x4(%esp)
  802499:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024a0:	e8 be e9 ff ff       	call   800e63 <sys_page_alloc>
  8024a5:	89 c3                	mov    %eax,%ebx
  8024a7:	85 c0                	test   %eax,%eax
  8024a9:	0f 88 97 00 00 00    	js     802546 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024b2:	89 04 24             	mov    %eax,(%esp)
  8024b5:	e8 f6 ef ff ff       	call   8014b0 <fd2data>
  8024ba:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8024c1:	00 
  8024c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024c6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8024cd:	00 
  8024ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024d9:	e8 d9 e9 ff ff       	call   800eb7 <sys_page_map>
  8024de:	89 c3                	mov    %eax,%ebx
  8024e0:	85 c0                	test   %eax,%eax
  8024e2:	78 52                	js     802536 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8024e4:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8024ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024ed:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8024ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024f2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8024f9:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8024ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802502:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802504:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802507:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80250e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802511:	89 04 24             	mov    %eax,(%esp)
  802514:	e8 87 ef ff ff       	call   8014a0 <fd2num>
  802519:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80251c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80251e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802521:	89 04 24             	mov    %eax,(%esp)
  802524:	e8 77 ef ff ff       	call   8014a0 <fd2num>
  802529:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80252c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80252f:	b8 00 00 00 00       	mov    $0x0,%eax
  802534:	eb 38                	jmp    80256e <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  802536:	89 74 24 04          	mov    %esi,0x4(%esp)
  80253a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802541:	e8 c4 e9 ff ff       	call   800f0a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802546:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802549:	89 44 24 04          	mov    %eax,0x4(%esp)
  80254d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802554:	e8 b1 e9 ff ff       	call   800f0a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802559:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80255c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802560:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802567:	e8 9e e9 ff ff       	call   800f0a <sys_page_unmap>
  80256c:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  80256e:	83 c4 30             	add    $0x30,%esp
  802571:	5b                   	pop    %ebx
  802572:	5e                   	pop    %esi
  802573:	5d                   	pop    %ebp
  802574:	c3                   	ret    

00802575 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802575:	55                   	push   %ebp
  802576:	89 e5                	mov    %esp,%ebp
  802578:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80257b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80257e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802582:	8b 45 08             	mov    0x8(%ebp),%eax
  802585:	89 04 24             	mov    %eax,(%esp)
  802588:	e8 89 ef ff ff       	call   801516 <fd_lookup>
  80258d:	89 c2                	mov    %eax,%edx
  80258f:	85 d2                	test   %edx,%edx
  802591:	78 15                	js     8025a8 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802593:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802596:	89 04 24             	mov    %eax,(%esp)
  802599:	e8 12 ef ff ff       	call   8014b0 <fd2data>
	return _pipeisclosed(fd, p);
  80259e:	89 c2                	mov    %eax,%edx
  8025a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025a3:	e8 0b fd ff ff       	call   8022b3 <_pipeisclosed>
}
  8025a8:	c9                   	leave  
  8025a9:	c3                   	ret    
  8025aa:	66 90                	xchg   %ax,%ax
  8025ac:	66 90                	xchg   %ax,%ax
  8025ae:	66 90                	xchg   %ax,%ax

008025b0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8025b0:	55                   	push   %ebp
  8025b1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8025b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8025b8:	5d                   	pop    %ebp
  8025b9:	c3                   	ret    

008025ba <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8025ba:	55                   	push   %ebp
  8025bb:	89 e5                	mov    %esp,%ebp
  8025bd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8025c0:	c7 44 24 04 5a 31 80 	movl   $0x80315a,0x4(%esp)
  8025c7:	00 
  8025c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025cb:	89 04 24             	mov    %eax,(%esp)
  8025ce:	e8 74 e4 ff ff       	call   800a47 <strcpy>
	return 0;
}
  8025d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8025d8:	c9                   	leave  
  8025d9:	c3                   	ret    

008025da <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8025da:	55                   	push   %ebp
  8025db:	89 e5                	mov    %esp,%ebp
  8025dd:	57                   	push   %edi
  8025de:	56                   	push   %esi
  8025df:	53                   	push   %ebx
  8025e0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8025e6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8025eb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8025f1:	eb 31                	jmp    802624 <devcons_write+0x4a>
		m = n - tot;
  8025f3:	8b 75 10             	mov    0x10(%ebp),%esi
  8025f6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8025f8:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8025fb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802600:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802603:	89 74 24 08          	mov    %esi,0x8(%esp)
  802607:	03 45 0c             	add    0xc(%ebp),%eax
  80260a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80260e:	89 3c 24             	mov    %edi,(%esp)
  802611:	e8 ce e5 ff ff       	call   800be4 <memmove>
		sys_cputs(buf, m);
  802616:	89 74 24 04          	mov    %esi,0x4(%esp)
  80261a:	89 3c 24             	mov    %edi,(%esp)
  80261d:	e8 74 e7 ff ff       	call   800d96 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802622:	01 f3                	add    %esi,%ebx
  802624:	89 d8                	mov    %ebx,%eax
  802626:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802629:	72 c8                	jb     8025f3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80262b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802631:	5b                   	pop    %ebx
  802632:	5e                   	pop    %esi
  802633:	5f                   	pop    %edi
  802634:	5d                   	pop    %ebp
  802635:	c3                   	ret    

00802636 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802636:	55                   	push   %ebp
  802637:	89 e5                	mov    %esp,%ebp
  802639:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80263c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802641:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802645:	75 07                	jne    80264e <devcons_read+0x18>
  802647:	eb 2a                	jmp    802673 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802649:	e8 f6 e7 ff ff       	call   800e44 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80264e:	66 90                	xchg   %ax,%ax
  802650:	e8 5f e7 ff ff       	call   800db4 <sys_cgetc>
  802655:	85 c0                	test   %eax,%eax
  802657:	74 f0                	je     802649 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802659:	85 c0                	test   %eax,%eax
  80265b:	78 16                	js     802673 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80265d:	83 f8 04             	cmp    $0x4,%eax
  802660:	74 0c                	je     80266e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802662:	8b 55 0c             	mov    0xc(%ebp),%edx
  802665:	88 02                	mov    %al,(%edx)
	return 1;
  802667:	b8 01 00 00 00       	mov    $0x1,%eax
  80266c:	eb 05                	jmp    802673 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80266e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802673:	c9                   	leave  
  802674:	c3                   	ret    

00802675 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802675:	55                   	push   %ebp
  802676:	89 e5                	mov    %esp,%ebp
  802678:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80267b:	8b 45 08             	mov    0x8(%ebp),%eax
  80267e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802681:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802688:	00 
  802689:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80268c:	89 04 24             	mov    %eax,(%esp)
  80268f:	e8 02 e7 ff ff       	call   800d96 <sys_cputs>
}
  802694:	c9                   	leave  
  802695:	c3                   	ret    

00802696 <getchar>:

int
getchar(void)
{
  802696:	55                   	push   %ebp
  802697:	89 e5                	mov    %esp,%ebp
  802699:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80269c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8026a3:	00 
  8026a4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8026a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026b2:	e8 f3 f0 ff ff       	call   8017aa <read>
	if (r < 0)
  8026b7:	85 c0                	test   %eax,%eax
  8026b9:	78 0f                	js     8026ca <getchar+0x34>
		return r;
	if (r < 1)
  8026bb:	85 c0                	test   %eax,%eax
  8026bd:	7e 06                	jle    8026c5 <getchar+0x2f>
		return -E_EOF;
	return c;
  8026bf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8026c3:	eb 05                	jmp    8026ca <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8026c5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8026ca:	c9                   	leave  
  8026cb:	c3                   	ret    

008026cc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8026cc:	55                   	push   %ebp
  8026cd:	89 e5                	mov    %esp,%ebp
  8026cf:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8026d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8026dc:	89 04 24             	mov    %eax,(%esp)
  8026df:	e8 32 ee ff ff       	call   801516 <fd_lookup>
  8026e4:	85 c0                	test   %eax,%eax
  8026e6:	78 11                	js     8026f9 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8026e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026eb:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8026f1:	39 10                	cmp    %edx,(%eax)
  8026f3:	0f 94 c0             	sete   %al
  8026f6:	0f b6 c0             	movzbl %al,%eax
}
  8026f9:	c9                   	leave  
  8026fa:	c3                   	ret    

008026fb <opencons>:

int
opencons(void)
{
  8026fb:	55                   	push   %ebp
  8026fc:	89 e5                	mov    %esp,%ebp
  8026fe:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802701:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802704:	89 04 24             	mov    %eax,(%esp)
  802707:	e8 bb ed ff ff       	call   8014c7 <fd_alloc>
		return r;
  80270c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80270e:	85 c0                	test   %eax,%eax
  802710:	78 40                	js     802752 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802712:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802719:	00 
  80271a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80271d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802721:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802728:	e8 36 e7 ff ff       	call   800e63 <sys_page_alloc>
		return r;
  80272d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80272f:	85 c0                	test   %eax,%eax
  802731:	78 1f                	js     802752 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802733:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802739:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80273c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80273e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802741:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802748:	89 04 24             	mov    %eax,(%esp)
  80274b:	e8 50 ed ff ff       	call   8014a0 <fd2num>
  802750:	89 c2                	mov    %eax,%edx
}
  802752:	89 d0                	mov    %edx,%eax
  802754:	c9                   	leave  
  802755:	c3                   	ret    

00802756 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802756:	55                   	push   %ebp
  802757:	89 e5                	mov    %esp,%ebp
  802759:	53                   	push   %ebx
  80275a:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  80275d:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802764:	75 2f                	jne    802795 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  802766:	e8 ba e6 ff ff       	call   800e25 <sys_getenvid>
  80276b:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P);
  80276d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802774:	00 
  802775:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80277c:	ee 
  80277d:	89 04 24             	mov    %eax,(%esp)
  802780:	e8 de e6 ff ff       	call   800e63 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *)_pgfault_upcall);
  802785:	c7 44 24 04 a3 27 80 	movl   $0x8027a3,0x4(%esp)
  80278c:	00 
  80278d:	89 1c 24             	mov    %ebx,(%esp)
  802790:	e8 6e e8 ff ff       	call   801003 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802795:	8b 45 08             	mov    0x8(%ebp),%eax
  802798:	a3 00 80 80 00       	mov    %eax,0x808000
}
  80279d:	83 c4 14             	add    $0x14,%esp
  8027a0:	5b                   	pop    %ebx
  8027a1:	5d                   	pop    %ebp
  8027a2:	c3                   	ret    

008027a3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8027a3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8027a4:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  8027a9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8027ab:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	// 0x30(%esp) points to trap-time stack pointer
	// 0x28(%esp) points to trap-time eip
	subl $4, 0x30(%esp)
  8027ae:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax 
  8027b3:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebp
  8027b7:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %ebp, (%eax)
  8027bb:	89 28                	mov    %ebp,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8027bd:	83 c4 08             	add    $0x8,%esp
	popal
  8027c0:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp //pop eip - we already stored it
  8027c1:	83 c4 04             	add    $0x4,%esp
	popfl
  8027c4:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8027c5:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8027c6:	c3                   	ret    
  8027c7:	66 90                	xchg   %ax,%ax
  8027c9:	66 90                	xchg   %ax,%ax
  8027cb:	66 90                	xchg   %ax,%ax
  8027cd:	66 90                	xchg   %ax,%ax
  8027cf:	90                   	nop

008027d0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8027d0:	55                   	push   %ebp
  8027d1:	89 e5                	mov    %esp,%ebp
  8027d3:	56                   	push   %esi
  8027d4:	53                   	push   %ebx
  8027d5:	83 ec 10             	sub    $0x10,%esp
  8027d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8027db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027de:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  8027e1:	85 c0                	test   %eax,%eax
  8027e3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8027e8:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  8027eb:	89 04 24             	mov    %eax,(%esp)
  8027ee:	e8 86 e8 ff ff       	call   801079 <sys_ipc_recv>

	if(ret < 0) {
  8027f3:	85 c0                	test   %eax,%eax
  8027f5:	79 16                	jns    80280d <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  8027f7:	85 f6                	test   %esi,%esi
  8027f9:	74 06                	je     802801 <ipc_recv+0x31>
  8027fb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  802801:	85 db                	test   %ebx,%ebx
  802803:	74 3e                	je     802843 <ipc_recv+0x73>
  802805:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80280b:	eb 36                	jmp    802843 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  80280d:	e8 13 e6 ff ff       	call   800e25 <sys_getenvid>
  802812:	25 ff 03 00 00       	and    $0x3ff,%eax
  802817:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80281a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80281f:	a3 08 50 80 00       	mov    %eax,0x805008

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802824:	85 f6                	test   %esi,%esi
  802826:	74 05                	je     80282d <ipc_recv+0x5d>
  802828:	8b 40 74             	mov    0x74(%eax),%eax
  80282b:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80282d:	85 db                	test   %ebx,%ebx
  80282f:	74 0a                	je     80283b <ipc_recv+0x6b>
  802831:	a1 08 50 80 00       	mov    0x805008,%eax
  802836:	8b 40 78             	mov    0x78(%eax),%eax
  802839:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  80283b:	a1 08 50 80 00       	mov    0x805008,%eax
  802840:	8b 40 70             	mov    0x70(%eax),%eax
}
  802843:	83 c4 10             	add    $0x10,%esp
  802846:	5b                   	pop    %ebx
  802847:	5e                   	pop    %esi
  802848:	5d                   	pop    %ebp
  802849:	c3                   	ret    

0080284a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80284a:	55                   	push   %ebp
  80284b:	89 e5                	mov    %esp,%ebp
  80284d:	57                   	push   %edi
  80284e:	56                   	push   %esi
  80284f:	53                   	push   %ebx
  802850:	83 ec 1c             	sub    $0x1c,%esp
  802853:	8b 7d 08             	mov    0x8(%ebp),%edi
  802856:	8b 75 0c             	mov    0xc(%ebp),%esi
  802859:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  80285c:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  80285e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802863:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  802866:	8b 45 14             	mov    0x14(%ebp),%eax
  802869:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80286d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802871:	89 74 24 04          	mov    %esi,0x4(%esp)
  802875:	89 3c 24             	mov    %edi,(%esp)
  802878:	e8 d9 e7 ff ff       	call   801056 <sys_ipc_try_send>

		if(ret >= 0) break;
  80287d:	85 c0                	test   %eax,%eax
  80287f:	79 2c                	jns    8028ad <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  802881:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802884:	74 20                	je     8028a6 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  802886:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80288a:	c7 44 24 08 68 31 80 	movl   $0x803168,0x8(%esp)
  802891:	00 
  802892:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  802899:	00 
  80289a:	c7 04 24 98 31 80 00 	movl   $0x803198,(%esp)
  8028a1:	e8 78 da ff ff       	call   80031e <_panic>
		}
		sys_yield();
  8028a6:	e8 99 e5 ff ff       	call   800e44 <sys_yield>
	}
  8028ab:	eb b9                	jmp    802866 <ipc_send+0x1c>
}
  8028ad:	83 c4 1c             	add    $0x1c,%esp
  8028b0:	5b                   	pop    %ebx
  8028b1:	5e                   	pop    %esi
  8028b2:	5f                   	pop    %edi
  8028b3:	5d                   	pop    %ebp
  8028b4:	c3                   	ret    

008028b5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8028b5:	55                   	push   %ebp
  8028b6:	89 e5                	mov    %esp,%ebp
  8028b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8028bb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8028c0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8028c3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8028c9:	8b 52 50             	mov    0x50(%edx),%edx
  8028cc:	39 ca                	cmp    %ecx,%edx
  8028ce:	75 0d                	jne    8028dd <ipc_find_env+0x28>
			return envs[i].env_id;
  8028d0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8028d3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8028d8:	8b 40 40             	mov    0x40(%eax),%eax
  8028db:	eb 0e                	jmp    8028eb <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8028dd:	83 c0 01             	add    $0x1,%eax
  8028e0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8028e5:	75 d9                	jne    8028c0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8028e7:	66 b8 00 00          	mov    $0x0,%ax
}
  8028eb:	5d                   	pop    %ebp
  8028ec:	c3                   	ret    

008028ed <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8028ed:	55                   	push   %ebp
  8028ee:	89 e5                	mov    %esp,%ebp
  8028f0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8028f3:	89 d0                	mov    %edx,%eax
  8028f5:	c1 e8 16             	shr    $0x16,%eax
  8028f8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8028ff:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802904:	f6 c1 01             	test   $0x1,%cl
  802907:	74 1d                	je     802926 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802909:	c1 ea 0c             	shr    $0xc,%edx
  80290c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802913:	f6 c2 01             	test   $0x1,%dl
  802916:	74 0e                	je     802926 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802918:	c1 ea 0c             	shr    $0xc,%edx
  80291b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802922:	ef 
  802923:	0f b7 c0             	movzwl %ax,%eax
}
  802926:	5d                   	pop    %ebp
  802927:	c3                   	ret    
  802928:	66 90                	xchg   %ax,%ax
  80292a:	66 90                	xchg   %ax,%ax
  80292c:	66 90                	xchg   %ax,%ax
  80292e:	66 90                	xchg   %ax,%ax

00802930 <__udivdi3>:
  802930:	55                   	push   %ebp
  802931:	57                   	push   %edi
  802932:	56                   	push   %esi
  802933:	83 ec 0c             	sub    $0xc,%esp
  802936:	8b 44 24 28          	mov    0x28(%esp),%eax
  80293a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80293e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802942:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802946:	85 c0                	test   %eax,%eax
  802948:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80294c:	89 ea                	mov    %ebp,%edx
  80294e:	89 0c 24             	mov    %ecx,(%esp)
  802951:	75 2d                	jne    802980 <__udivdi3+0x50>
  802953:	39 e9                	cmp    %ebp,%ecx
  802955:	77 61                	ja     8029b8 <__udivdi3+0x88>
  802957:	85 c9                	test   %ecx,%ecx
  802959:	89 ce                	mov    %ecx,%esi
  80295b:	75 0b                	jne    802968 <__udivdi3+0x38>
  80295d:	b8 01 00 00 00       	mov    $0x1,%eax
  802962:	31 d2                	xor    %edx,%edx
  802964:	f7 f1                	div    %ecx
  802966:	89 c6                	mov    %eax,%esi
  802968:	31 d2                	xor    %edx,%edx
  80296a:	89 e8                	mov    %ebp,%eax
  80296c:	f7 f6                	div    %esi
  80296e:	89 c5                	mov    %eax,%ebp
  802970:	89 f8                	mov    %edi,%eax
  802972:	f7 f6                	div    %esi
  802974:	89 ea                	mov    %ebp,%edx
  802976:	83 c4 0c             	add    $0xc,%esp
  802979:	5e                   	pop    %esi
  80297a:	5f                   	pop    %edi
  80297b:	5d                   	pop    %ebp
  80297c:	c3                   	ret    
  80297d:	8d 76 00             	lea    0x0(%esi),%esi
  802980:	39 e8                	cmp    %ebp,%eax
  802982:	77 24                	ja     8029a8 <__udivdi3+0x78>
  802984:	0f bd e8             	bsr    %eax,%ebp
  802987:	83 f5 1f             	xor    $0x1f,%ebp
  80298a:	75 3c                	jne    8029c8 <__udivdi3+0x98>
  80298c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802990:	39 34 24             	cmp    %esi,(%esp)
  802993:	0f 86 9f 00 00 00    	jbe    802a38 <__udivdi3+0x108>
  802999:	39 d0                	cmp    %edx,%eax
  80299b:	0f 82 97 00 00 00    	jb     802a38 <__udivdi3+0x108>
  8029a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8029a8:	31 d2                	xor    %edx,%edx
  8029aa:	31 c0                	xor    %eax,%eax
  8029ac:	83 c4 0c             	add    $0xc,%esp
  8029af:	5e                   	pop    %esi
  8029b0:	5f                   	pop    %edi
  8029b1:	5d                   	pop    %ebp
  8029b2:	c3                   	ret    
  8029b3:	90                   	nop
  8029b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8029b8:	89 f8                	mov    %edi,%eax
  8029ba:	f7 f1                	div    %ecx
  8029bc:	31 d2                	xor    %edx,%edx
  8029be:	83 c4 0c             	add    $0xc,%esp
  8029c1:	5e                   	pop    %esi
  8029c2:	5f                   	pop    %edi
  8029c3:	5d                   	pop    %ebp
  8029c4:	c3                   	ret    
  8029c5:	8d 76 00             	lea    0x0(%esi),%esi
  8029c8:	89 e9                	mov    %ebp,%ecx
  8029ca:	8b 3c 24             	mov    (%esp),%edi
  8029cd:	d3 e0                	shl    %cl,%eax
  8029cf:	89 c6                	mov    %eax,%esi
  8029d1:	b8 20 00 00 00       	mov    $0x20,%eax
  8029d6:	29 e8                	sub    %ebp,%eax
  8029d8:	89 c1                	mov    %eax,%ecx
  8029da:	d3 ef                	shr    %cl,%edi
  8029dc:	89 e9                	mov    %ebp,%ecx
  8029de:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8029e2:	8b 3c 24             	mov    (%esp),%edi
  8029e5:	09 74 24 08          	or     %esi,0x8(%esp)
  8029e9:	89 d6                	mov    %edx,%esi
  8029eb:	d3 e7                	shl    %cl,%edi
  8029ed:	89 c1                	mov    %eax,%ecx
  8029ef:	89 3c 24             	mov    %edi,(%esp)
  8029f2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8029f6:	d3 ee                	shr    %cl,%esi
  8029f8:	89 e9                	mov    %ebp,%ecx
  8029fa:	d3 e2                	shl    %cl,%edx
  8029fc:	89 c1                	mov    %eax,%ecx
  8029fe:	d3 ef                	shr    %cl,%edi
  802a00:	09 d7                	or     %edx,%edi
  802a02:	89 f2                	mov    %esi,%edx
  802a04:	89 f8                	mov    %edi,%eax
  802a06:	f7 74 24 08          	divl   0x8(%esp)
  802a0a:	89 d6                	mov    %edx,%esi
  802a0c:	89 c7                	mov    %eax,%edi
  802a0e:	f7 24 24             	mull   (%esp)
  802a11:	39 d6                	cmp    %edx,%esi
  802a13:	89 14 24             	mov    %edx,(%esp)
  802a16:	72 30                	jb     802a48 <__udivdi3+0x118>
  802a18:	8b 54 24 04          	mov    0x4(%esp),%edx
  802a1c:	89 e9                	mov    %ebp,%ecx
  802a1e:	d3 e2                	shl    %cl,%edx
  802a20:	39 c2                	cmp    %eax,%edx
  802a22:	73 05                	jae    802a29 <__udivdi3+0xf9>
  802a24:	3b 34 24             	cmp    (%esp),%esi
  802a27:	74 1f                	je     802a48 <__udivdi3+0x118>
  802a29:	89 f8                	mov    %edi,%eax
  802a2b:	31 d2                	xor    %edx,%edx
  802a2d:	e9 7a ff ff ff       	jmp    8029ac <__udivdi3+0x7c>
  802a32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802a38:	31 d2                	xor    %edx,%edx
  802a3a:	b8 01 00 00 00       	mov    $0x1,%eax
  802a3f:	e9 68 ff ff ff       	jmp    8029ac <__udivdi3+0x7c>
  802a44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a48:	8d 47 ff             	lea    -0x1(%edi),%eax
  802a4b:	31 d2                	xor    %edx,%edx
  802a4d:	83 c4 0c             	add    $0xc,%esp
  802a50:	5e                   	pop    %esi
  802a51:	5f                   	pop    %edi
  802a52:	5d                   	pop    %ebp
  802a53:	c3                   	ret    
  802a54:	66 90                	xchg   %ax,%ax
  802a56:	66 90                	xchg   %ax,%ax
  802a58:	66 90                	xchg   %ax,%ax
  802a5a:	66 90                	xchg   %ax,%ax
  802a5c:	66 90                	xchg   %ax,%ax
  802a5e:	66 90                	xchg   %ax,%ax

00802a60 <__umoddi3>:
  802a60:	55                   	push   %ebp
  802a61:	57                   	push   %edi
  802a62:	56                   	push   %esi
  802a63:	83 ec 14             	sub    $0x14,%esp
  802a66:	8b 44 24 28          	mov    0x28(%esp),%eax
  802a6a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802a6e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802a72:	89 c7                	mov    %eax,%edi
  802a74:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a78:	8b 44 24 30          	mov    0x30(%esp),%eax
  802a7c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802a80:	89 34 24             	mov    %esi,(%esp)
  802a83:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a87:	85 c0                	test   %eax,%eax
  802a89:	89 c2                	mov    %eax,%edx
  802a8b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802a8f:	75 17                	jne    802aa8 <__umoddi3+0x48>
  802a91:	39 fe                	cmp    %edi,%esi
  802a93:	76 4b                	jbe    802ae0 <__umoddi3+0x80>
  802a95:	89 c8                	mov    %ecx,%eax
  802a97:	89 fa                	mov    %edi,%edx
  802a99:	f7 f6                	div    %esi
  802a9b:	89 d0                	mov    %edx,%eax
  802a9d:	31 d2                	xor    %edx,%edx
  802a9f:	83 c4 14             	add    $0x14,%esp
  802aa2:	5e                   	pop    %esi
  802aa3:	5f                   	pop    %edi
  802aa4:	5d                   	pop    %ebp
  802aa5:	c3                   	ret    
  802aa6:	66 90                	xchg   %ax,%ax
  802aa8:	39 f8                	cmp    %edi,%eax
  802aaa:	77 54                	ja     802b00 <__umoddi3+0xa0>
  802aac:	0f bd e8             	bsr    %eax,%ebp
  802aaf:	83 f5 1f             	xor    $0x1f,%ebp
  802ab2:	75 5c                	jne    802b10 <__umoddi3+0xb0>
  802ab4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802ab8:	39 3c 24             	cmp    %edi,(%esp)
  802abb:	0f 87 e7 00 00 00    	ja     802ba8 <__umoddi3+0x148>
  802ac1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802ac5:	29 f1                	sub    %esi,%ecx
  802ac7:	19 c7                	sbb    %eax,%edi
  802ac9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802acd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802ad1:	8b 44 24 08          	mov    0x8(%esp),%eax
  802ad5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802ad9:	83 c4 14             	add    $0x14,%esp
  802adc:	5e                   	pop    %esi
  802add:	5f                   	pop    %edi
  802ade:	5d                   	pop    %ebp
  802adf:	c3                   	ret    
  802ae0:	85 f6                	test   %esi,%esi
  802ae2:	89 f5                	mov    %esi,%ebp
  802ae4:	75 0b                	jne    802af1 <__umoddi3+0x91>
  802ae6:	b8 01 00 00 00       	mov    $0x1,%eax
  802aeb:	31 d2                	xor    %edx,%edx
  802aed:	f7 f6                	div    %esi
  802aef:	89 c5                	mov    %eax,%ebp
  802af1:	8b 44 24 04          	mov    0x4(%esp),%eax
  802af5:	31 d2                	xor    %edx,%edx
  802af7:	f7 f5                	div    %ebp
  802af9:	89 c8                	mov    %ecx,%eax
  802afb:	f7 f5                	div    %ebp
  802afd:	eb 9c                	jmp    802a9b <__umoddi3+0x3b>
  802aff:	90                   	nop
  802b00:	89 c8                	mov    %ecx,%eax
  802b02:	89 fa                	mov    %edi,%edx
  802b04:	83 c4 14             	add    $0x14,%esp
  802b07:	5e                   	pop    %esi
  802b08:	5f                   	pop    %edi
  802b09:	5d                   	pop    %ebp
  802b0a:	c3                   	ret    
  802b0b:	90                   	nop
  802b0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b10:	8b 04 24             	mov    (%esp),%eax
  802b13:	be 20 00 00 00       	mov    $0x20,%esi
  802b18:	89 e9                	mov    %ebp,%ecx
  802b1a:	29 ee                	sub    %ebp,%esi
  802b1c:	d3 e2                	shl    %cl,%edx
  802b1e:	89 f1                	mov    %esi,%ecx
  802b20:	d3 e8                	shr    %cl,%eax
  802b22:	89 e9                	mov    %ebp,%ecx
  802b24:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b28:	8b 04 24             	mov    (%esp),%eax
  802b2b:	09 54 24 04          	or     %edx,0x4(%esp)
  802b2f:	89 fa                	mov    %edi,%edx
  802b31:	d3 e0                	shl    %cl,%eax
  802b33:	89 f1                	mov    %esi,%ecx
  802b35:	89 44 24 08          	mov    %eax,0x8(%esp)
  802b39:	8b 44 24 10          	mov    0x10(%esp),%eax
  802b3d:	d3 ea                	shr    %cl,%edx
  802b3f:	89 e9                	mov    %ebp,%ecx
  802b41:	d3 e7                	shl    %cl,%edi
  802b43:	89 f1                	mov    %esi,%ecx
  802b45:	d3 e8                	shr    %cl,%eax
  802b47:	89 e9                	mov    %ebp,%ecx
  802b49:	09 f8                	or     %edi,%eax
  802b4b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  802b4f:	f7 74 24 04          	divl   0x4(%esp)
  802b53:	d3 e7                	shl    %cl,%edi
  802b55:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802b59:	89 d7                	mov    %edx,%edi
  802b5b:	f7 64 24 08          	mull   0x8(%esp)
  802b5f:	39 d7                	cmp    %edx,%edi
  802b61:	89 c1                	mov    %eax,%ecx
  802b63:	89 14 24             	mov    %edx,(%esp)
  802b66:	72 2c                	jb     802b94 <__umoddi3+0x134>
  802b68:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  802b6c:	72 22                	jb     802b90 <__umoddi3+0x130>
  802b6e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802b72:	29 c8                	sub    %ecx,%eax
  802b74:	19 d7                	sbb    %edx,%edi
  802b76:	89 e9                	mov    %ebp,%ecx
  802b78:	89 fa                	mov    %edi,%edx
  802b7a:	d3 e8                	shr    %cl,%eax
  802b7c:	89 f1                	mov    %esi,%ecx
  802b7e:	d3 e2                	shl    %cl,%edx
  802b80:	89 e9                	mov    %ebp,%ecx
  802b82:	d3 ef                	shr    %cl,%edi
  802b84:	09 d0                	or     %edx,%eax
  802b86:	89 fa                	mov    %edi,%edx
  802b88:	83 c4 14             	add    $0x14,%esp
  802b8b:	5e                   	pop    %esi
  802b8c:	5f                   	pop    %edi
  802b8d:	5d                   	pop    %ebp
  802b8e:	c3                   	ret    
  802b8f:	90                   	nop
  802b90:	39 d7                	cmp    %edx,%edi
  802b92:	75 da                	jne    802b6e <__umoddi3+0x10e>
  802b94:	8b 14 24             	mov    (%esp),%edx
  802b97:	89 c1                	mov    %eax,%ecx
  802b99:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  802b9d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802ba1:	eb cb                	jmp    802b6e <__umoddi3+0x10e>
  802ba3:	90                   	nop
  802ba4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ba8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  802bac:	0f 82 0f ff ff ff    	jb     802ac1 <__umoddi3+0x61>
  802bb2:	e9 1a ff ff ff       	jmp    802ad1 <__umoddi3+0x71>
