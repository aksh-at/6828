
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 15 05 00 00       	call   800546 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
  80003f:	8b 75 08             	mov    0x8(%ebp),%esi
  800042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800048:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80004c:	89 34 24             	mov    %esi,(%esp)
  80004f:	e8 40 1b 00 00       	call   801b94 <seek>
	seek(kfd, off);
  800054:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800058:	89 3c 24             	mov    %edi,(%esp)
  80005b:	e8 34 1b 00 00       	call   801b94 <seek>

	cprintf("shell produced incorrect output.\n");
  800060:	c7 04 24 40 33 80 00 	movl   $0x803340,(%esp)
  800067:	e8 34 06 00 00       	call   8006a0 <cprintf>
	cprintf("expected:\n===\n");
  80006c:	c7 04 24 ab 33 80 00 	movl   $0x8033ab,(%esp)
  800073:	e8 28 06 00 00       	call   8006a0 <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800078:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  80007b:	eb 0c                	jmp    800089 <wrong+0x56>
		sys_cputs(buf, n);
  80007d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800081:	89 1c 24             	mov    %ebx,(%esp)
  800084:	e8 8d 0f 00 00       	call   801016 <sys_cputs>
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800089:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  800090:	00 
  800091:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800095:	89 3c 24             	mov    %edi,(%esp)
  800098:	e8 8d 19 00 00       	call   801a2a <read>
  80009d:	85 c0                	test   %eax,%eax
  80009f:	7f dc                	jg     80007d <wrong+0x4a>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  8000a1:	c7 04 24 ba 33 80 00 	movl   $0x8033ba,(%esp)
  8000a8:	e8 f3 05 00 00       	call   8006a0 <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000ad:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000b0:	eb 0c                	jmp    8000be <wrong+0x8b>
		sys_cputs(buf, n);
  8000b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b6:	89 1c 24             	mov    %ebx,(%esp)
  8000b9:	e8 58 0f 00 00       	call   801016 <sys_cputs>
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000be:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  8000c5:	00 
  8000c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ca:	89 34 24             	mov    %esi,(%esp)
  8000cd:	e8 58 19 00 00       	call   801a2a <read>
  8000d2:	85 c0                	test   %eax,%eax
  8000d4:	7f dc                	jg     8000b2 <wrong+0x7f>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000d6:	c7 04 24 b5 33 80 00 	movl   $0x8033b5,(%esp)
  8000dd:	e8 be 05 00 00       	call   8006a0 <cprintf>
	exit();
  8000e2:	e8 a7 04 00 00       	call   80058e <exit>
}
  8000e7:	81 c4 8c 00 00 00    	add    $0x8c,%esp
  8000ed:	5b                   	pop    %ebx
  8000ee:	5e                   	pop    %esi
  8000ef:	5f                   	pop    %edi
  8000f0:	5d                   	pop    %ebp
  8000f1:	c3                   	ret    

008000f2 <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	57                   	push   %edi
  8000f6:	56                   	push   %esi
  8000f7:	53                   	push   %ebx
  8000f8:	83 ec 3c             	sub    $0x3c,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800102:	e8 c0 17 00 00       	call   8018c7 <close>
	close(1);
  800107:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80010e:	e8 b4 17 00 00       	call   8018c7 <close>
	opencons();
  800113:	e8 d3 03 00 00       	call   8004eb <opencons>
	opencons();
  800118:	e8 ce 03 00 00       	call   8004eb <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  80011d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800124:	00 
  800125:	c7 04 24 c8 33 80 00 	movl   $0x8033c8,(%esp)
  80012c:	e8 d2 1d 00 00       	call   801f03 <open>
  800131:	89 c3                	mov    %eax,%ebx
  800133:	85 c0                	test   %eax,%eax
  800135:	79 20                	jns    800157 <umain+0x65>
		panic("open testshell.sh: %e", rfd);
  800137:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80013b:	c7 44 24 08 d5 33 80 	movl   $0x8033d5,0x8(%esp)
  800142:	00 
  800143:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  80014a:	00 
  80014b:	c7 04 24 eb 33 80 00 	movl   $0x8033eb,(%esp)
  800152:	e8 50 04 00 00       	call   8005a7 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  800157:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80015a:	89 04 24             	mov    %eax,(%esp)
  80015d:	e8 72 2b 00 00       	call   802cd4 <pipe>
  800162:	85 c0                	test   %eax,%eax
  800164:	79 20                	jns    800186 <umain+0x94>
		panic("pipe: %e", wfd);
  800166:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80016a:	c7 44 24 08 fc 33 80 	movl   $0x8033fc,0x8(%esp)
  800171:	00 
  800172:	c7 44 24 04 15 00 00 	movl   $0x15,0x4(%esp)
  800179:	00 
  80017a:	c7 04 24 eb 33 80 00 	movl   $0x8033eb,(%esp)
  800181:	e8 21 04 00 00       	call   8005a7 <_panic>
	wfd = pfds[1];
  800186:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  800189:	c7 04 24 64 33 80 00 	movl   $0x803364,(%esp)
  800190:	e8 0b 05 00 00       	call   8006a0 <cprintf>
	if ((r = fork()) < 0)
  800195:	e8 7a 13 00 00       	call   801514 <fork>
  80019a:	85 c0                	test   %eax,%eax
  80019c:	79 20                	jns    8001be <umain+0xcc>
		panic("fork: %e", r);
  80019e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a2:	c7 44 24 08 05 34 80 	movl   $0x803405,0x8(%esp)
  8001a9:	00 
  8001aa:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8001b1:	00 
  8001b2:	c7 04 24 eb 33 80 00 	movl   $0x8033eb,(%esp)
  8001b9:	e8 e9 03 00 00       	call   8005a7 <_panic>
	if (r == 0) {
  8001be:	85 c0                	test   %eax,%eax
  8001c0:	0f 85 9f 00 00 00    	jne    800265 <umain+0x173>
		dup(rfd, 0);
  8001c6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001cd:	00 
  8001ce:	89 1c 24             	mov    %ebx,(%esp)
  8001d1:	e8 46 17 00 00       	call   80191c <dup>
		dup(wfd, 1);
  8001d6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001dd:	00 
  8001de:	89 34 24             	mov    %esi,(%esp)
  8001e1:	e8 36 17 00 00       	call   80191c <dup>
		close(rfd);
  8001e6:	89 1c 24             	mov    %ebx,(%esp)
  8001e9:	e8 d9 16 00 00       	call   8018c7 <close>
		close(wfd);
  8001ee:	89 34 24             	mov    %esi,(%esp)
  8001f1:	e8 d1 16 00 00       	call   8018c7 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001f6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001fd:	00 
  8001fe:	c7 44 24 08 0e 34 80 	movl   $0x80340e,0x8(%esp)
  800205:	00 
  800206:	c7 44 24 04 d2 33 80 	movl   $0x8033d2,0x4(%esp)
  80020d:	00 
  80020e:	c7 04 24 11 34 80 00 	movl   $0x803411,(%esp)
  800215:	e8 5d 23 00 00       	call   802577 <spawnl>
  80021a:	89 c7                	mov    %eax,%edi
  80021c:	85 c0                	test   %eax,%eax
  80021e:	79 20                	jns    800240 <umain+0x14e>
			panic("spawn: %e", r);
  800220:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800224:	c7 44 24 08 15 34 80 	movl   $0x803415,0x8(%esp)
  80022b:	00 
  80022c:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800233:	00 
  800234:	c7 04 24 eb 33 80 00 	movl   $0x8033eb,(%esp)
  80023b:	e8 67 03 00 00       	call   8005a7 <_panic>
		close(0);
  800240:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800247:	e8 7b 16 00 00       	call   8018c7 <close>
		close(1);
  80024c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800253:	e8 6f 16 00 00       	call   8018c7 <close>
		wait(r);
  800258:	89 3c 24             	mov    %edi,(%esp)
  80025b:	e8 1a 2c 00 00       	call   802e7a <wait>
		exit();
  800260:	e8 29 03 00 00       	call   80058e <exit>
	}
	close(rfd);
  800265:	89 1c 24             	mov    %ebx,(%esp)
  800268:	e8 5a 16 00 00       	call   8018c7 <close>
	close(wfd);
  80026d:	89 34 24             	mov    %esi,(%esp)
  800270:	e8 52 16 00 00       	call   8018c7 <close>

	rfd = pfds[0];
  800275:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800278:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  80027b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800282:	00 
  800283:	c7 04 24 1f 34 80 00 	movl   $0x80341f,(%esp)
  80028a:	e8 74 1c 00 00       	call   801f03 <open>
  80028f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800292:	85 c0                	test   %eax,%eax
  800294:	79 20                	jns    8002b6 <umain+0x1c4>
		panic("open testshell.key for reading: %e", kfd);
  800296:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80029a:	c7 44 24 08 88 33 80 	movl   $0x803388,0x8(%esp)
  8002a1:	00 
  8002a2:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8002a9:	00 
  8002aa:	c7 04 24 eb 33 80 00 	movl   $0x8033eb,(%esp)
  8002b1:	e8 f1 02 00 00       	call   8005a7 <_panic>
	}
	close(rfd);
	close(wfd);

	rfd = pfds[0];
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  8002b6:	be 01 00 00 00       	mov    $0x1,%esi
  8002bb:	bf 00 00 00 00       	mov    $0x0,%edi
		panic("open testshell.key for reading: %e", kfd);

	nloff = 0;
	for (off=0;; off++) {
		n1 = read(rfd, &c1, 1);
  8002c0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002c7:	00 
  8002c8:	8d 45 e7             	lea    -0x19(%ebp),%eax
  8002cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cf:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8002d2:	89 04 24             	mov    %eax,(%esp)
  8002d5:	e8 50 17 00 00       	call   801a2a <read>
  8002da:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  8002dc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002e3:	00 
  8002e4:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  8002e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002ee:	89 04 24             	mov    %eax,(%esp)
  8002f1:	e8 34 17 00 00       	call   801a2a <read>
		if (n1 < 0)
  8002f6:	85 db                	test   %ebx,%ebx
  8002f8:	79 20                	jns    80031a <umain+0x228>
			panic("reading testshell.out: %e", n1);
  8002fa:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002fe:	c7 44 24 08 2d 34 80 	movl   $0x80342d,0x8(%esp)
  800305:	00 
  800306:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  80030d:	00 
  80030e:	c7 04 24 eb 33 80 00 	movl   $0x8033eb,(%esp)
  800315:	e8 8d 02 00 00       	call   8005a7 <_panic>
		if (n2 < 0)
  80031a:	85 c0                	test   %eax,%eax
  80031c:	79 20                	jns    80033e <umain+0x24c>
			panic("reading testshell.key: %e", n2);
  80031e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800322:	c7 44 24 08 47 34 80 	movl   $0x803447,0x8(%esp)
  800329:	00 
  80032a:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  800331:	00 
  800332:	c7 04 24 eb 33 80 00 	movl   $0x8033eb,(%esp)
  800339:	e8 69 02 00 00       	call   8005a7 <_panic>
		if (n1 == 0 && n2 == 0)
  80033e:	89 c2                	mov    %eax,%edx
  800340:	09 da                	or     %ebx,%edx
  800342:	74 38                	je     80037c <umain+0x28a>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  800344:	83 fb 01             	cmp    $0x1,%ebx
  800347:	75 0e                	jne    800357 <umain+0x265>
  800349:	83 f8 01             	cmp    $0x1,%eax
  80034c:	75 09                	jne    800357 <umain+0x265>
  80034e:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  800352:	38 45 e7             	cmp    %al,-0x19(%ebp)
  800355:	74 16                	je     80036d <umain+0x27b>
			wrong(rfd, kfd, nloff);
  800357:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80035b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80035e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800362:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800365:	89 04 24             	mov    %eax,(%esp)
  800368:	e8 c6 fc ff ff       	call   800033 <wrong>
		if (c1 == '\n')
			nloff = off+1;
  80036d:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  800371:	0f 44 fe             	cmove  %esi,%edi
  800374:	83 c6 01             	add    $0x1,%esi
	}
  800377:	e9 44 ff ff ff       	jmp    8002c0 <umain+0x1ce>
	cprintf("shell ran correctly\n");
  80037c:	c7 04 24 61 34 80 00 	movl   $0x803461,(%esp)
  800383:	e8 18 03 00 00       	call   8006a0 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  800388:	cc                   	int3   

	breakpoint();
}
  800389:	83 c4 3c             	add    $0x3c,%esp
  80038c:	5b                   	pop    %ebx
  80038d:	5e                   	pop    %esi
  80038e:	5f                   	pop    %edi
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    
  800391:	66 90                	xchg   %ax,%ax
  800393:	66 90                	xchg   %ax,%ax
  800395:	66 90                	xchg   %ax,%ax
  800397:	66 90                	xchg   %ax,%ax
  800399:	66 90                	xchg   %ax,%ax
  80039b:	66 90                	xchg   %ax,%ax
  80039d:	66 90                	xchg   %ax,%ax
  80039f:	90                   	nop

008003a0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8003a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a8:	5d                   	pop    %ebp
  8003a9:	c3                   	ret    

008003aa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
  8003ad:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8003b0:	c7 44 24 04 76 34 80 	movl   $0x803476,0x4(%esp)
  8003b7:	00 
  8003b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003bb:	89 04 24             	mov    %eax,(%esp)
  8003be:	e8 04 09 00 00       	call   800cc7 <strcpy>
	return 0;
}
  8003c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c8:	c9                   	leave  
  8003c9:	c3                   	ret    

008003ca <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	57                   	push   %edi
  8003ce:	56                   	push   %esi
  8003cf:	53                   	push   %ebx
  8003d0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8003d6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8003db:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8003e1:	eb 31                	jmp    800414 <devcons_write+0x4a>
		m = n - tot;
  8003e3:	8b 75 10             	mov    0x10(%ebp),%esi
  8003e6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8003e8:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8003eb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8003f0:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8003f3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003f7:	03 45 0c             	add    0xc(%ebp),%eax
  8003fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003fe:	89 3c 24             	mov    %edi,(%esp)
  800401:	e8 5e 0a 00 00       	call   800e64 <memmove>
		sys_cputs(buf, m);
  800406:	89 74 24 04          	mov    %esi,0x4(%esp)
  80040a:	89 3c 24             	mov    %edi,(%esp)
  80040d:	e8 04 0c 00 00       	call   801016 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800412:	01 f3                	add    %esi,%ebx
  800414:	89 d8                	mov    %ebx,%eax
  800416:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800419:	72 c8                	jb     8003e3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80041b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  800421:	5b                   	pop    %ebx
  800422:	5e                   	pop    %esi
  800423:	5f                   	pop    %edi
  800424:	5d                   	pop    %ebp
  800425:	c3                   	ret    

00800426 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800426:	55                   	push   %ebp
  800427:	89 e5                	mov    %esp,%ebp
  800429:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80042c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  800431:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800435:	75 07                	jne    80043e <devcons_read+0x18>
  800437:	eb 2a                	jmp    800463 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800439:	e8 86 0c 00 00       	call   8010c4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80043e:	66 90                	xchg   %ax,%ax
  800440:	e8 ef 0b 00 00       	call   801034 <sys_cgetc>
  800445:	85 c0                	test   %eax,%eax
  800447:	74 f0                	je     800439 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800449:	85 c0                	test   %eax,%eax
  80044b:	78 16                	js     800463 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80044d:	83 f8 04             	cmp    $0x4,%eax
  800450:	74 0c                	je     80045e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  800452:	8b 55 0c             	mov    0xc(%ebp),%edx
  800455:	88 02                	mov    %al,(%edx)
	return 1;
  800457:	b8 01 00 00 00       	mov    $0x1,%eax
  80045c:	eb 05                	jmp    800463 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80045e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800463:	c9                   	leave  
  800464:	c3                   	ret    

00800465 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800465:	55                   	push   %ebp
  800466:	89 e5                	mov    %esp,%ebp
  800468:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80046b:	8b 45 08             	mov    0x8(%ebp),%eax
  80046e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800471:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800478:	00 
  800479:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80047c:	89 04 24             	mov    %eax,(%esp)
  80047f:	e8 92 0b 00 00       	call   801016 <sys_cputs>
}
  800484:	c9                   	leave  
  800485:	c3                   	ret    

00800486 <getchar>:

int
getchar(void)
{
  800486:	55                   	push   %ebp
  800487:	89 e5                	mov    %esp,%ebp
  800489:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80048c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800493:	00 
  800494:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800497:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8004a2:	e8 83 15 00 00       	call   801a2a <read>
	if (r < 0)
  8004a7:	85 c0                	test   %eax,%eax
  8004a9:	78 0f                	js     8004ba <getchar+0x34>
		return r;
	if (r < 1)
  8004ab:	85 c0                	test   %eax,%eax
  8004ad:	7e 06                	jle    8004b5 <getchar+0x2f>
		return -E_EOF;
	return c;
  8004af:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8004b3:	eb 05                	jmp    8004ba <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8004b5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8004ba:	c9                   	leave  
  8004bb:	c3                   	ret    

008004bc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8004bc:	55                   	push   %ebp
  8004bd:	89 e5                	mov    %esp,%ebp
  8004bf:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004cc:	89 04 24             	mov    %eax,(%esp)
  8004cf:	e8 c2 12 00 00       	call   801796 <fd_lookup>
  8004d4:	85 c0                	test   %eax,%eax
  8004d6:	78 11                	js     8004e9 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8004d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8004db:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8004e1:	39 10                	cmp    %edx,(%eax)
  8004e3:	0f 94 c0             	sete   %al
  8004e6:	0f b6 c0             	movzbl %al,%eax
}
  8004e9:	c9                   	leave  
  8004ea:	c3                   	ret    

008004eb <opencons>:

int
opencons(void)
{
  8004eb:	55                   	push   %ebp
  8004ec:	89 e5                	mov    %esp,%ebp
  8004ee:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8004f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f4:	89 04 24             	mov    %eax,(%esp)
  8004f7:	e8 4b 12 00 00       	call   801747 <fd_alloc>
		return r;
  8004fc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8004fe:	85 c0                	test   %eax,%eax
  800500:	78 40                	js     800542 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800502:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800509:	00 
  80050a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80050d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800511:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800518:	e8 c6 0b 00 00       	call   8010e3 <sys_page_alloc>
		return r;
  80051d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80051f:	85 c0                	test   %eax,%eax
  800521:	78 1f                	js     800542 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800523:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800529:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80052c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80052e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800531:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800538:	89 04 24             	mov    %eax,(%esp)
  80053b:	e8 e0 11 00 00       	call   801720 <fd2num>
  800540:	89 c2                	mov    %eax,%edx
}
  800542:	89 d0                	mov    %edx,%eax
  800544:	c9                   	leave  
  800545:	c3                   	ret    

00800546 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800546:	55                   	push   %ebp
  800547:	89 e5                	mov    %esp,%ebp
  800549:	56                   	push   %esi
  80054a:	53                   	push   %ebx
  80054b:	83 ec 10             	sub    $0x10,%esp
  80054e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800551:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  800554:	e8 4c 0b 00 00       	call   8010a5 <sys_getenvid>
  800559:	25 ff 03 00 00       	and    $0x3ff,%eax
  80055e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800561:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800566:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80056b:	85 db                	test   %ebx,%ebx
  80056d:	7e 07                	jle    800576 <libmain+0x30>
		binaryname = argv[0];
  80056f:	8b 06                	mov    (%esi),%eax
  800571:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  800576:	89 74 24 04          	mov    %esi,0x4(%esp)
  80057a:	89 1c 24             	mov    %ebx,(%esp)
  80057d:	e8 70 fb ff ff       	call   8000f2 <umain>

	// exit gracefully
	exit();
  800582:	e8 07 00 00 00       	call   80058e <exit>
}
  800587:	83 c4 10             	add    $0x10,%esp
  80058a:	5b                   	pop    %ebx
  80058b:	5e                   	pop    %esi
  80058c:	5d                   	pop    %ebp
  80058d:	c3                   	ret    

0080058e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80058e:	55                   	push   %ebp
  80058f:	89 e5                	mov    %esp,%ebp
  800591:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800594:	e8 61 13 00 00       	call   8018fa <close_all>
	sys_env_destroy(0);
  800599:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005a0:	e8 ae 0a 00 00       	call   801053 <sys_env_destroy>
}
  8005a5:	c9                   	leave  
  8005a6:	c3                   	ret    

008005a7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005a7:	55                   	push   %ebp
  8005a8:	89 e5                	mov    %esp,%ebp
  8005aa:	56                   	push   %esi
  8005ab:	53                   	push   %ebx
  8005ac:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8005af:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005b2:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  8005b8:	e8 e8 0a 00 00       	call   8010a5 <sys_getenvid>
  8005bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005c0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8005c7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005cb:	89 74 24 08          	mov    %esi,0x8(%esp)
  8005cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d3:	c7 04 24 8c 34 80 00 	movl   $0x80348c,(%esp)
  8005da:	e8 c1 00 00 00       	call   8006a0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8005df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8005e6:	89 04 24             	mov    %eax,(%esp)
  8005e9:	e8 51 00 00 00       	call   80063f <vcprintf>
	cprintf("\n");
  8005ee:	c7 04 24 b8 33 80 00 	movl   $0x8033b8,(%esp)
  8005f5:	e8 a6 00 00 00       	call   8006a0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8005fa:	cc                   	int3   
  8005fb:	eb fd                	jmp    8005fa <_panic+0x53>

008005fd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8005fd:	55                   	push   %ebp
  8005fe:	89 e5                	mov    %esp,%ebp
  800600:	53                   	push   %ebx
  800601:	83 ec 14             	sub    $0x14,%esp
  800604:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800607:	8b 13                	mov    (%ebx),%edx
  800609:	8d 42 01             	lea    0x1(%edx),%eax
  80060c:	89 03                	mov    %eax,(%ebx)
  80060e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800611:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800615:	3d ff 00 00 00       	cmp    $0xff,%eax
  80061a:	75 19                	jne    800635 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80061c:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800623:	00 
  800624:	8d 43 08             	lea    0x8(%ebx),%eax
  800627:	89 04 24             	mov    %eax,(%esp)
  80062a:	e8 e7 09 00 00       	call   801016 <sys_cputs>
		b->idx = 0;
  80062f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800635:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800639:	83 c4 14             	add    $0x14,%esp
  80063c:	5b                   	pop    %ebx
  80063d:	5d                   	pop    %ebp
  80063e:	c3                   	ret    

0080063f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80063f:	55                   	push   %ebp
  800640:	89 e5                	mov    %esp,%ebp
  800642:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800648:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80064f:	00 00 00 
	b.cnt = 0;
  800652:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800659:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80065c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80065f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800663:	8b 45 08             	mov    0x8(%ebp),%eax
  800666:	89 44 24 08          	mov    %eax,0x8(%esp)
  80066a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800670:	89 44 24 04          	mov    %eax,0x4(%esp)
  800674:	c7 04 24 fd 05 80 00 	movl   $0x8005fd,(%esp)
  80067b:	e8 ae 01 00 00       	call   80082e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800680:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800686:	89 44 24 04          	mov    %eax,0x4(%esp)
  80068a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800690:	89 04 24             	mov    %eax,(%esp)
  800693:	e8 7e 09 00 00       	call   801016 <sys_cputs>

	return b.cnt;
}
  800698:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80069e:	c9                   	leave  
  80069f:	c3                   	ret    

008006a0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006a0:	55                   	push   %ebp
  8006a1:	89 e5                	mov    %esp,%ebp
  8006a3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006a6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b0:	89 04 24             	mov    %eax,(%esp)
  8006b3:	e8 87 ff ff ff       	call   80063f <vcprintf>
	va_end(ap);

	return cnt;
}
  8006b8:	c9                   	leave  
  8006b9:	c3                   	ret    
  8006ba:	66 90                	xchg   %ax,%ax
  8006bc:	66 90                	xchg   %ax,%ax
  8006be:	66 90                	xchg   %ax,%ax

008006c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006c0:	55                   	push   %ebp
  8006c1:	89 e5                	mov    %esp,%ebp
  8006c3:	57                   	push   %edi
  8006c4:	56                   	push   %esi
  8006c5:	53                   	push   %ebx
  8006c6:	83 ec 3c             	sub    $0x3c,%esp
  8006c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006cc:	89 d7                	mov    %edx,%edi
  8006ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d7:	89 c3                	mov    %eax,%ebx
  8006d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8006dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8006df:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006ed:	39 d9                	cmp    %ebx,%ecx
  8006ef:	72 05                	jb     8006f6 <printnum+0x36>
  8006f1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8006f4:	77 69                	ja     80075f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006f6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8006f9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8006fd:	83 ee 01             	sub    $0x1,%esi
  800700:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800704:	89 44 24 08          	mov    %eax,0x8(%esp)
  800708:	8b 44 24 08          	mov    0x8(%esp),%eax
  80070c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800710:	89 c3                	mov    %eax,%ebx
  800712:	89 d6                	mov    %edx,%esi
  800714:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800717:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80071a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80071e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800722:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800725:	89 04 24             	mov    %eax,(%esp)
  800728:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80072b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072f:	e8 7c 29 00 00       	call   8030b0 <__udivdi3>
  800734:	89 d9                	mov    %ebx,%ecx
  800736:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80073a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80073e:	89 04 24             	mov    %eax,(%esp)
  800741:	89 54 24 04          	mov    %edx,0x4(%esp)
  800745:	89 fa                	mov    %edi,%edx
  800747:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80074a:	e8 71 ff ff ff       	call   8006c0 <printnum>
  80074f:	eb 1b                	jmp    80076c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800751:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800755:	8b 45 18             	mov    0x18(%ebp),%eax
  800758:	89 04 24             	mov    %eax,(%esp)
  80075b:	ff d3                	call   *%ebx
  80075d:	eb 03                	jmp    800762 <printnum+0xa2>
  80075f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800762:	83 ee 01             	sub    $0x1,%esi
  800765:	85 f6                	test   %esi,%esi
  800767:	7f e8                	jg     800751 <printnum+0x91>
  800769:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80076c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800770:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800774:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800777:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80077a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80077e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800782:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800785:	89 04 24             	mov    %eax,(%esp)
  800788:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80078b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078f:	e8 4c 2a 00 00       	call   8031e0 <__umoddi3>
  800794:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800798:	0f be 80 af 34 80 00 	movsbl 0x8034af(%eax),%eax
  80079f:	89 04 24             	mov    %eax,(%esp)
  8007a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007a5:	ff d0                	call   *%eax
}
  8007a7:	83 c4 3c             	add    $0x3c,%esp
  8007aa:	5b                   	pop    %ebx
  8007ab:	5e                   	pop    %esi
  8007ac:	5f                   	pop    %edi
  8007ad:	5d                   	pop    %ebp
  8007ae:	c3                   	ret    

008007af <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8007b2:	83 fa 01             	cmp    $0x1,%edx
  8007b5:	7e 0e                	jle    8007c5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8007b7:	8b 10                	mov    (%eax),%edx
  8007b9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007bc:	89 08                	mov    %ecx,(%eax)
  8007be:	8b 02                	mov    (%edx),%eax
  8007c0:	8b 52 04             	mov    0x4(%edx),%edx
  8007c3:	eb 22                	jmp    8007e7 <getuint+0x38>
	else if (lflag)
  8007c5:	85 d2                	test   %edx,%edx
  8007c7:	74 10                	je     8007d9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007c9:	8b 10                	mov    (%eax),%edx
  8007cb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007ce:	89 08                	mov    %ecx,(%eax)
  8007d0:	8b 02                	mov    (%edx),%eax
  8007d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d7:	eb 0e                	jmp    8007e7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007d9:	8b 10                	mov    (%eax),%edx
  8007db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007de:	89 08                	mov    %ecx,(%eax)
  8007e0:	8b 02                	mov    (%edx),%eax
  8007e2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007ef:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007f3:	8b 10                	mov    (%eax),%edx
  8007f5:	3b 50 04             	cmp    0x4(%eax),%edx
  8007f8:	73 0a                	jae    800804 <sprintputch+0x1b>
		*b->buf++ = ch;
  8007fa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007fd:	89 08                	mov    %ecx,(%eax)
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800802:	88 02                	mov    %al,(%edx)
}
  800804:	5d                   	pop    %ebp
  800805:	c3                   	ret    

00800806 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80080c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80080f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800813:	8b 45 10             	mov    0x10(%ebp),%eax
  800816:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80081d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800821:	8b 45 08             	mov    0x8(%ebp),%eax
  800824:	89 04 24             	mov    %eax,(%esp)
  800827:	e8 02 00 00 00       	call   80082e <vprintfmt>
	va_end(ap);
}
  80082c:	c9                   	leave  
  80082d:	c3                   	ret    

0080082e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	57                   	push   %edi
  800832:	56                   	push   %esi
  800833:	53                   	push   %ebx
  800834:	83 ec 3c             	sub    $0x3c,%esp
  800837:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80083a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80083d:	eb 14                	jmp    800853 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80083f:	85 c0                	test   %eax,%eax
  800841:	0f 84 b3 03 00 00    	je     800bfa <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800847:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80084b:	89 04 24             	mov    %eax,(%esp)
  80084e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800851:	89 f3                	mov    %esi,%ebx
  800853:	8d 73 01             	lea    0x1(%ebx),%esi
  800856:	0f b6 03             	movzbl (%ebx),%eax
  800859:	83 f8 25             	cmp    $0x25,%eax
  80085c:	75 e1                	jne    80083f <vprintfmt+0x11>
  80085e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800862:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800869:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800870:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800877:	ba 00 00 00 00       	mov    $0x0,%edx
  80087c:	eb 1d                	jmp    80089b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800880:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800884:	eb 15                	jmp    80089b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800886:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800888:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80088c:	eb 0d                	jmp    80089b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80088e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800891:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800894:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80089b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80089e:	0f b6 0e             	movzbl (%esi),%ecx
  8008a1:	0f b6 c1             	movzbl %cl,%eax
  8008a4:	83 e9 23             	sub    $0x23,%ecx
  8008a7:	80 f9 55             	cmp    $0x55,%cl
  8008aa:	0f 87 2a 03 00 00    	ja     800bda <vprintfmt+0x3ac>
  8008b0:	0f b6 c9             	movzbl %cl,%ecx
  8008b3:	ff 24 8d 00 36 80 00 	jmp    *0x803600(,%ecx,4)
  8008ba:	89 de                	mov    %ebx,%esi
  8008bc:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008c1:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8008c4:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8008c8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8008cb:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8008ce:	83 fb 09             	cmp    $0x9,%ebx
  8008d1:	77 36                	ja     800909 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008d3:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008d6:	eb e9                	jmp    8008c1 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008db:	8d 48 04             	lea    0x4(%eax),%ecx
  8008de:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008e1:	8b 00                	mov    (%eax),%eax
  8008e3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e6:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008e8:	eb 22                	jmp    80090c <vprintfmt+0xde>
  8008ea:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8008ed:	85 c9                	test   %ecx,%ecx
  8008ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f4:	0f 49 c1             	cmovns %ecx,%eax
  8008f7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fa:	89 de                	mov    %ebx,%esi
  8008fc:	eb 9d                	jmp    80089b <vprintfmt+0x6d>
  8008fe:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800900:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800907:	eb 92                	jmp    80089b <vprintfmt+0x6d>
  800909:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80090c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800910:	79 89                	jns    80089b <vprintfmt+0x6d>
  800912:	e9 77 ff ff ff       	jmp    80088e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800917:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091a:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80091c:	e9 7a ff ff ff       	jmp    80089b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800921:	8b 45 14             	mov    0x14(%ebp),%eax
  800924:	8d 50 04             	lea    0x4(%eax),%edx
  800927:	89 55 14             	mov    %edx,0x14(%ebp)
  80092a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80092e:	8b 00                	mov    (%eax),%eax
  800930:	89 04 24             	mov    %eax,(%esp)
  800933:	ff 55 08             	call   *0x8(%ebp)
			break;
  800936:	e9 18 ff ff ff       	jmp    800853 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80093b:	8b 45 14             	mov    0x14(%ebp),%eax
  80093e:	8d 50 04             	lea    0x4(%eax),%edx
  800941:	89 55 14             	mov    %edx,0x14(%ebp)
  800944:	8b 00                	mov    (%eax),%eax
  800946:	99                   	cltd   
  800947:	31 d0                	xor    %edx,%eax
  800949:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80094b:	83 f8 0f             	cmp    $0xf,%eax
  80094e:	7f 0b                	jg     80095b <vprintfmt+0x12d>
  800950:	8b 14 85 60 37 80 00 	mov    0x803760(,%eax,4),%edx
  800957:	85 d2                	test   %edx,%edx
  800959:	75 20                	jne    80097b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80095b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80095f:	c7 44 24 08 c7 34 80 	movl   $0x8034c7,0x8(%esp)
  800966:	00 
  800967:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80096b:	8b 45 08             	mov    0x8(%ebp),%eax
  80096e:	89 04 24             	mov    %eax,(%esp)
  800971:	e8 90 fe ff ff       	call   800806 <printfmt>
  800976:	e9 d8 fe ff ff       	jmp    800853 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80097b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80097f:	c7 44 24 08 0d 39 80 	movl   $0x80390d,0x8(%esp)
  800986:	00 
  800987:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	89 04 24             	mov    %eax,(%esp)
  800991:	e8 70 fe ff ff       	call   800806 <printfmt>
  800996:	e9 b8 fe ff ff       	jmp    800853 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80099b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80099e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8009a1:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a7:	8d 50 04             	lea    0x4(%eax),%edx
  8009aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ad:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8009af:	85 f6                	test   %esi,%esi
  8009b1:	b8 c0 34 80 00       	mov    $0x8034c0,%eax
  8009b6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8009b9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8009bd:	0f 84 97 00 00 00    	je     800a5a <vprintfmt+0x22c>
  8009c3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8009c7:	0f 8e 9b 00 00 00    	jle    800a68 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009cd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009d1:	89 34 24             	mov    %esi,(%esp)
  8009d4:	e8 cf 02 00 00       	call   800ca8 <strnlen>
  8009d9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8009dc:	29 c2                	sub    %eax,%edx
  8009de:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8009e1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8009e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8009e8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8009eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ee:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009f1:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009f3:	eb 0f                	jmp    800a04 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8009f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8009fc:	89 04 24             	mov    %eax,(%esp)
  8009ff:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a01:	83 eb 01             	sub    $0x1,%ebx
  800a04:	85 db                	test   %ebx,%ebx
  800a06:	7f ed                	jg     8009f5 <vprintfmt+0x1c7>
  800a08:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800a0b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a0e:	85 d2                	test   %edx,%edx
  800a10:	b8 00 00 00 00       	mov    $0x0,%eax
  800a15:	0f 49 c2             	cmovns %edx,%eax
  800a18:	29 c2                	sub    %eax,%edx
  800a1a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800a1d:	89 d7                	mov    %edx,%edi
  800a1f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800a22:	eb 50                	jmp    800a74 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a24:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a28:	74 1e                	je     800a48 <vprintfmt+0x21a>
  800a2a:	0f be d2             	movsbl %dl,%edx
  800a2d:	83 ea 20             	sub    $0x20,%edx
  800a30:	83 fa 5e             	cmp    $0x5e,%edx
  800a33:	76 13                	jbe    800a48 <vprintfmt+0x21a>
					putch('?', putdat);
  800a35:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a38:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a3c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a43:	ff 55 08             	call   *0x8(%ebp)
  800a46:	eb 0d                	jmp    800a55 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800a48:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4b:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a4f:	89 04 24             	mov    %eax,(%esp)
  800a52:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a55:	83 ef 01             	sub    $0x1,%edi
  800a58:	eb 1a                	jmp    800a74 <vprintfmt+0x246>
  800a5a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800a5d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800a60:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a63:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800a66:	eb 0c                	jmp    800a74 <vprintfmt+0x246>
  800a68:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800a6b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800a6e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a71:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800a74:	83 c6 01             	add    $0x1,%esi
  800a77:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800a7b:	0f be c2             	movsbl %dl,%eax
  800a7e:	85 c0                	test   %eax,%eax
  800a80:	74 27                	je     800aa9 <vprintfmt+0x27b>
  800a82:	85 db                	test   %ebx,%ebx
  800a84:	78 9e                	js     800a24 <vprintfmt+0x1f6>
  800a86:	83 eb 01             	sub    $0x1,%ebx
  800a89:	79 99                	jns    800a24 <vprintfmt+0x1f6>
  800a8b:	89 f8                	mov    %edi,%eax
  800a8d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a90:	8b 75 08             	mov    0x8(%ebp),%esi
  800a93:	89 c3                	mov    %eax,%ebx
  800a95:	eb 1a                	jmp    800ab1 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a97:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a9b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800aa2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800aa4:	83 eb 01             	sub    $0x1,%ebx
  800aa7:	eb 08                	jmp    800ab1 <vprintfmt+0x283>
  800aa9:	89 fb                	mov    %edi,%ebx
  800aab:	8b 75 08             	mov    0x8(%ebp),%esi
  800aae:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ab1:	85 db                	test   %ebx,%ebx
  800ab3:	7f e2                	jg     800a97 <vprintfmt+0x269>
  800ab5:	89 75 08             	mov    %esi,0x8(%ebp)
  800ab8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800abb:	e9 93 fd ff ff       	jmp    800853 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ac0:	83 fa 01             	cmp    $0x1,%edx
  800ac3:	7e 16                	jle    800adb <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800ac5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac8:	8d 50 08             	lea    0x8(%eax),%edx
  800acb:	89 55 14             	mov    %edx,0x14(%ebp)
  800ace:	8b 50 04             	mov    0x4(%eax),%edx
  800ad1:	8b 00                	mov    (%eax),%eax
  800ad3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ad6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800ad9:	eb 32                	jmp    800b0d <vprintfmt+0x2df>
	else if (lflag)
  800adb:	85 d2                	test   %edx,%edx
  800add:	74 18                	je     800af7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  800adf:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae2:	8d 50 04             	lea    0x4(%eax),%edx
  800ae5:	89 55 14             	mov    %edx,0x14(%ebp)
  800ae8:	8b 30                	mov    (%eax),%esi
  800aea:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800aed:	89 f0                	mov    %esi,%eax
  800aef:	c1 f8 1f             	sar    $0x1f,%eax
  800af2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800af5:	eb 16                	jmp    800b0d <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800af7:	8b 45 14             	mov    0x14(%ebp),%eax
  800afa:	8d 50 04             	lea    0x4(%eax),%edx
  800afd:	89 55 14             	mov    %edx,0x14(%ebp)
  800b00:	8b 30                	mov    (%eax),%esi
  800b02:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800b05:	89 f0                	mov    %esi,%eax
  800b07:	c1 f8 1f             	sar    $0x1f,%eax
  800b0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b0d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b10:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b13:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b18:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b1c:	0f 89 80 00 00 00    	jns    800ba2 <vprintfmt+0x374>
				putch('-', putdat);
  800b22:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b26:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800b2d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800b30:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b33:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b36:	f7 d8                	neg    %eax
  800b38:	83 d2 00             	adc    $0x0,%edx
  800b3b:	f7 da                	neg    %edx
			}
			base = 10;
  800b3d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b42:	eb 5e                	jmp    800ba2 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b44:	8d 45 14             	lea    0x14(%ebp),%eax
  800b47:	e8 63 fc ff ff       	call   8007af <getuint>
			base = 10;
  800b4c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b51:	eb 4f                	jmp    800ba2 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800b53:	8d 45 14             	lea    0x14(%ebp),%eax
  800b56:	e8 54 fc ff ff       	call   8007af <getuint>
			base = 8;
  800b5b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800b60:	eb 40                	jmp    800ba2 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800b62:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b66:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b6d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800b70:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b74:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b7b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b7e:	8b 45 14             	mov    0x14(%ebp),%eax
  800b81:	8d 50 04             	lea    0x4(%eax),%edx
  800b84:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b87:	8b 00                	mov    (%eax),%eax
  800b89:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b8e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b93:	eb 0d                	jmp    800ba2 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b95:	8d 45 14             	lea    0x14(%ebp),%eax
  800b98:	e8 12 fc ff ff       	call   8007af <getuint>
			base = 16;
  800b9d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ba2:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800ba6:	89 74 24 10          	mov    %esi,0x10(%esp)
  800baa:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800bad:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800bb1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800bb5:	89 04 24             	mov    %eax,(%esp)
  800bb8:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bbc:	89 fa                	mov    %edi,%edx
  800bbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc1:	e8 fa fa ff ff       	call   8006c0 <printnum>
			break;
  800bc6:	e9 88 fc ff ff       	jmp    800853 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800bcb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bcf:	89 04 24             	mov    %eax,(%esp)
  800bd2:	ff 55 08             	call   *0x8(%ebp)
			break;
  800bd5:	e9 79 fc ff ff       	jmp    800853 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800bda:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bde:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800be5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800be8:	89 f3                	mov    %esi,%ebx
  800bea:	eb 03                	jmp    800bef <vprintfmt+0x3c1>
  800bec:	83 eb 01             	sub    $0x1,%ebx
  800bef:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800bf3:	75 f7                	jne    800bec <vprintfmt+0x3be>
  800bf5:	e9 59 fc ff ff       	jmp    800853 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800bfa:	83 c4 3c             	add    $0x3c,%esp
  800bfd:	5b                   	pop    %ebx
  800bfe:	5e                   	pop    %esi
  800bff:	5f                   	pop    %edi
  800c00:	5d                   	pop    %ebp
  800c01:	c3                   	ret    

00800c02 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	83 ec 28             	sub    $0x28,%esp
  800c08:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c0e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c11:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c15:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c18:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c1f:	85 c0                	test   %eax,%eax
  800c21:	74 30                	je     800c53 <vsnprintf+0x51>
  800c23:	85 d2                	test   %edx,%edx
  800c25:	7e 2c                	jle    800c53 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c27:	8b 45 14             	mov    0x14(%ebp),%eax
  800c2a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c2e:	8b 45 10             	mov    0x10(%ebp),%eax
  800c31:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c35:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c38:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c3c:	c7 04 24 e9 07 80 00 	movl   $0x8007e9,(%esp)
  800c43:	e8 e6 fb ff ff       	call   80082e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c48:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c4b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c51:	eb 05                	jmp    800c58 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c53:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c58:	c9                   	leave  
  800c59:	c3                   	ret    

00800c5a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c60:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c63:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c67:	8b 45 10             	mov    0x10(%ebp),%eax
  800c6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c71:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c75:	8b 45 08             	mov    0x8(%ebp),%eax
  800c78:	89 04 24             	mov    %eax,(%esp)
  800c7b:	e8 82 ff ff ff       	call   800c02 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c80:	c9                   	leave  
  800c81:	c3                   	ret    
  800c82:	66 90                	xchg   %ax,%ax
  800c84:	66 90                	xchg   %ax,%ax
  800c86:	66 90                	xchg   %ax,%ax
  800c88:	66 90                	xchg   %ax,%ax
  800c8a:	66 90                	xchg   %ax,%ax
  800c8c:	66 90                	xchg   %ax,%ax
  800c8e:	66 90                	xchg   %ax,%ax

00800c90 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c96:	b8 00 00 00 00       	mov    $0x0,%eax
  800c9b:	eb 03                	jmp    800ca0 <strlen+0x10>
		n++;
  800c9d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ca0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ca4:	75 f7                	jne    800c9d <strlen+0xd>
		n++;
	return n;
}
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cae:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb6:	eb 03                	jmp    800cbb <strnlen+0x13>
		n++;
  800cb8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cbb:	39 d0                	cmp    %edx,%eax
  800cbd:	74 06                	je     800cc5 <strnlen+0x1d>
  800cbf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800cc3:	75 f3                	jne    800cb8 <strnlen+0x10>
		n++;
	return n;
}
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	53                   	push   %ebx
  800ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800cd1:	89 c2                	mov    %eax,%edx
  800cd3:	83 c2 01             	add    $0x1,%edx
  800cd6:	83 c1 01             	add    $0x1,%ecx
  800cd9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800cdd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ce0:	84 db                	test   %bl,%bl
  800ce2:	75 ef                	jne    800cd3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ce4:	5b                   	pop    %ebx
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	53                   	push   %ebx
  800ceb:	83 ec 08             	sub    $0x8,%esp
  800cee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800cf1:	89 1c 24             	mov    %ebx,(%esp)
  800cf4:	e8 97 ff ff ff       	call   800c90 <strlen>
	strcpy(dst + len, src);
  800cf9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cfc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d00:	01 d8                	add    %ebx,%eax
  800d02:	89 04 24             	mov    %eax,(%esp)
  800d05:	e8 bd ff ff ff       	call   800cc7 <strcpy>
	return dst;
}
  800d0a:	89 d8                	mov    %ebx,%eax
  800d0c:	83 c4 08             	add    $0x8,%esp
  800d0f:	5b                   	pop    %ebx
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	56                   	push   %esi
  800d16:	53                   	push   %ebx
  800d17:	8b 75 08             	mov    0x8(%ebp),%esi
  800d1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1d:	89 f3                	mov    %esi,%ebx
  800d1f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d22:	89 f2                	mov    %esi,%edx
  800d24:	eb 0f                	jmp    800d35 <strncpy+0x23>
		*dst++ = *src;
  800d26:	83 c2 01             	add    $0x1,%edx
  800d29:	0f b6 01             	movzbl (%ecx),%eax
  800d2c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d2f:	80 39 01             	cmpb   $0x1,(%ecx)
  800d32:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d35:	39 da                	cmp    %ebx,%edx
  800d37:	75 ed                	jne    800d26 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d39:	89 f0                	mov    %esi,%eax
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    

00800d3f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	56                   	push   %esi
  800d43:	53                   	push   %ebx
  800d44:	8b 75 08             	mov    0x8(%ebp),%esi
  800d47:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d4a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800d4d:	89 f0                	mov    %esi,%eax
  800d4f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d53:	85 c9                	test   %ecx,%ecx
  800d55:	75 0b                	jne    800d62 <strlcpy+0x23>
  800d57:	eb 1d                	jmp    800d76 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d59:	83 c0 01             	add    $0x1,%eax
  800d5c:	83 c2 01             	add    $0x1,%edx
  800d5f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d62:	39 d8                	cmp    %ebx,%eax
  800d64:	74 0b                	je     800d71 <strlcpy+0x32>
  800d66:	0f b6 0a             	movzbl (%edx),%ecx
  800d69:	84 c9                	test   %cl,%cl
  800d6b:	75 ec                	jne    800d59 <strlcpy+0x1a>
  800d6d:	89 c2                	mov    %eax,%edx
  800d6f:	eb 02                	jmp    800d73 <strlcpy+0x34>
  800d71:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800d73:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800d76:	29 f0                	sub    %esi,%eax
}
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d82:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d85:	eb 06                	jmp    800d8d <strcmp+0x11>
		p++, q++;
  800d87:	83 c1 01             	add    $0x1,%ecx
  800d8a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d8d:	0f b6 01             	movzbl (%ecx),%eax
  800d90:	84 c0                	test   %al,%al
  800d92:	74 04                	je     800d98 <strcmp+0x1c>
  800d94:	3a 02                	cmp    (%edx),%al
  800d96:	74 ef                	je     800d87 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d98:	0f b6 c0             	movzbl %al,%eax
  800d9b:	0f b6 12             	movzbl (%edx),%edx
  800d9e:	29 d0                	sub    %edx,%eax
}
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    

00800da2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	53                   	push   %ebx
  800da6:	8b 45 08             	mov    0x8(%ebp),%eax
  800da9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dac:	89 c3                	mov    %eax,%ebx
  800dae:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800db1:	eb 06                	jmp    800db9 <strncmp+0x17>
		n--, p++, q++;
  800db3:	83 c0 01             	add    $0x1,%eax
  800db6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800db9:	39 d8                	cmp    %ebx,%eax
  800dbb:	74 15                	je     800dd2 <strncmp+0x30>
  800dbd:	0f b6 08             	movzbl (%eax),%ecx
  800dc0:	84 c9                	test   %cl,%cl
  800dc2:	74 04                	je     800dc8 <strncmp+0x26>
  800dc4:	3a 0a                	cmp    (%edx),%cl
  800dc6:	74 eb                	je     800db3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dc8:	0f b6 00             	movzbl (%eax),%eax
  800dcb:	0f b6 12             	movzbl (%edx),%edx
  800dce:	29 d0                	sub    %edx,%eax
  800dd0:	eb 05                	jmp    800dd7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800dd2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800dd7:	5b                   	pop    %ebx
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  800de0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800de4:	eb 07                	jmp    800ded <strchr+0x13>
		if (*s == c)
  800de6:	38 ca                	cmp    %cl,%dl
  800de8:	74 0f                	je     800df9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dea:	83 c0 01             	add    $0x1,%eax
  800ded:	0f b6 10             	movzbl (%eax),%edx
  800df0:	84 d2                	test   %dl,%dl
  800df2:	75 f2                	jne    800de6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800df4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800e01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e05:	eb 07                	jmp    800e0e <strfind+0x13>
		if (*s == c)
  800e07:	38 ca                	cmp    %cl,%dl
  800e09:	74 0a                	je     800e15 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e0b:	83 c0 01             	add    $0x1,%eax
  800e0e:	0f b6 10             	movzbl (%eax),%edx
  800e11:	84 d2                	test   %dl,%dl
  800e13:	75 f2                	jne    800e07 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    

00800e17 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
  800e1a:	57                   	push   %edi
  800e1b:	56                   	push   %esi
  800e1c:	53                   	push   %ebx
  800e1d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e20:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e23:	85 c9                	test   %ecx,%ecx
  800e25:	74 36                	je     800e5d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e27:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e2d:	75 28                	jne    800e57 <memset+0x40>
  800e2f:	f6 c1 03             	test   $0x3,%cl
  800e32:	75 23                	jne    800e57 <memset+0x40>
		c &= 0xFF;
  800e34:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e38:	89 d3                	mov    %edx,%ebx
  800e3a:	c1 e3 08             	shl    $0x8,%ebx
  800e3d:	89 d6                	mov    %edx,%esi
  800e3f:	c1 e6 18             	shl    $0x18,%esi
  800e42:	89 d0                	mov    %edx,%eax
  800e44:	c1 e0 10             	shl    $0x10,%eax
  800e47:	09 f0                	or     %esi,%eax
  800e49:	09 c2                	or     %eax,%edx
  800e4b:	89 d0                	mov    %edx,%eax
  800e4d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e4f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e52:	fc                   	cld    
  800e53:	f3 ab                	rep stos %eax,%es:(%edi)
  800e55:	eb 06                	jmp    800e5d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5a:	fc                   	cld    
  800e5b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e5d:	89 f8                	mov    %edi,%eax
  800e5f:	5b                   	pop    %ebx
  800e60:	5e                   	pop    %esi
  800e61:	5f                   	pop    %edi
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    

00800e64 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	57                   	push   %edi
  800e68:	56                   	push   %esi
  800e69:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e72:	39 c6                	cmp    %eax,%esi
  800e74:	73 35                	jae    800eab <memmove+0x47>
  800e76:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e79:	39 d0                	cmp    %edx,%eax
  800e7b:	73 2e                	jae    800eab <memmove+0x47>
		s += n;
		d += n;
  800e7d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800e80:	89 d6                	mov    %edx,%esi
  800e82:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e84:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e8a:	75 13                	jne    800e9f <memmove+0x3b>
  800e8c:	f6 c1 03             	test   $0x3,%cl
  800e8f:	75 0e                	jne    800e9f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e91:	83 ef 04             	sub    $0x4,%edi
  800e94:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e97:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e9a:	fd                   	std    
  800e9b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e9d:	eb 09                	jmp    800ea8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e9f:	83 ef 01             	sub    $0x1,%edi
  800ea2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ea5:	fd                   	std    
  800ea6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ea8:	fc                   	cld    
  800ea9:	eb 1d                	jmp    800ec8 <memmove+0x64>
  800eab:	89 f2                	mov    %esi,%edx
  800ead:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eaf:	f6 c2 03             	test   $0x3,%dl
  800eb2:	75 0f                	jne    800ec3 <memmove+0x5f>
  800eb4:	f6 c1 03             	test   $0x3,%cl
  800eb7:	75 0a                	jne    800ec3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800eb9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ebc:	89 c7                	mov    %eax,%edi
  800ebe:	fc                   	cld    
  800ebf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ec1:	eb 05                	jmp    800ec8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ec3:	89 c7                	mov    %eax,%edi
  800ec5:	fc                   	cld    
  800ec6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ec8:	5e                   	pop    %esi
  800ec9:	5f                   	pop    %edi
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    

00800ecc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ed2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ed5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ed9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800edc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ee0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee3:	89 04 24             	mov    %eax,(%esp)
  800ee6:	e8 79 ff ff ff       	call   800e64 <memmove>
}
  800eeb:	c9                   	leave  
  800eec:	c3                   	ret    

00800eed <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800eed:	55                   	push   %ebp
  800eee:	89 e5                	mov    %esp,%ebp
  800ef0:	56                   	push   %esi
  800ef1:	53                   	push   %ebx
  800ef2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef8:	89 d6                	mov    %edx,%esi
  800efa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800efd:	eb 1a                	jmp    800f19 <memcmp+0x2c>
		if (*s1 != *s2)
  800eff:	0f b6 02             	movzbl (%edx),%eax
  800f02:	0f b6 19             	movzbl (%ecx),%ebx
  800f05:	38 d8                	cmp    %bl,%al
  800f07:	74 0a                	je     800f13 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f09:	0f b6 c0             	movzbl %al,%eax
  800f0c:	0f b6 db             	movzbl %bl,%ebx
  800f0f:	29 d8                	sub    %ebx,%eax
  800f11:	eb 0f                	jmp    800f22 <memcmp+0x35>
		s1++, s2++;
  800f13:	83 c2 01             	add    $0x1,%edx
  800f16:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f19:	39 f2                	cmp    %esi,%edx
  800f1b:	75 e2                	jne    800eff <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    

00800f26 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800f2f:	89 c2                	mov    %eax,%edx
  800f31:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f34:	eb 07                	jmp    800f3d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f36:	38 08                	cmp    %cl,(%eax)
  800f38:	74 07                	je     800f41 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f3a:	83 c0 01             	add    $0x1,%eax
  800f3d:	39 d0                	cmp    %edx,%eax
  800f3f:	72 f5                	jb     800f36 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f41:	5d                   	pop    %ebp
  800f42:	c3                   	ret    

00800f43 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	57                   	push   %edi
  800f47:	56                   	push   %esi
  800f48:	53                   	push   %ebx
  800f49:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f4f:	eb 03                	jmp    800f54 <strtol+0x11>
		s++;
  800f51:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f54:	0f b6 0a             	movzbl (%edx),%ecx
  800f57:	80 f9 09             	cmp    $0x9,%cl
  800f5a:	74 f5                	je     800f51 <strtol+0xe>
  800f5c:	80 f9 20             	cmp    $0x20,%cl
  800f5f:	74 f0                	je     800f51 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f61:	80 f9 2b             	cmp    $0x2b,%cl
  800f64:	75 0a                	jne    800f70 <strtol+0x2d>
		s++;
  800f66:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f69:	bf 00 00 00 00       	mov    $0x0,%edi
  800f6e:	eb 11                	jmp    800f81 <strtol+0x3e>
  800f70:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f75:	80 f9 2d             	cmp    $0x2d,%cl
  800f78:	75 07                	jne    800f81 <strtol+0x3e>
		s++, neg = 1;
  800f7a:	8d 52 01             	lea    0x1(%edx),%edx
  800f7d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f81:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800f86:	75 15                	jne    800f9d <strtol+0x5a>
  800f88:	80 3a 30             	cmpb   $0x30,(%edx)
  800f8b:	75 10                	jne    800f9d <strtol+0x5a>
  800f8d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f91:	75 0a                	jne    800f9d <strtol+0x5a>
		s += 2, base = 16;
  800f93:	83 c2 02             	add    $0x2,%edx
  800f96:	b8 10 00 00 00       	mov    $0x10,%eax
  800f9b:	eb 10                	jmp    800fad <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	75 0c                	jne    800fad <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800fa1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fa3:	80 3a 30             	cmpb   $0x30,(%edx)
  800fa6:	75 05                	jne    800fad <strtol+0x6a>
		s++, base = 8;
  800fa8:	83 c2 01             	add    $0x1,%edx
  800fab:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800fad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800fb5:	0f b6 0a             	movzbl (%edx),%ecx
  800fb8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800fbb:	89 f0                	mov    %esi,%eax
  800fbd:	3c 09                	cmp    $0x9,%al
  800fbf:	77 08                	ja     800fc9 <strtol+0x86>
			dig = *s - '0';
  800fc1:	0f be c9             	movsbl %cl,%ecx
  800fc4:	83 e9 30             	sub    $0x30,%ecx
  800fc7:	eb 20                	jmp    800fe9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800fc9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800fcc:	89 f0                	mov    %esi,%eax
  800fce:	3c 19                	cmp    $0x19,%al
  800fd0:	77 08                	ja     800fda <strtol+0x97>
			dig = *s - 'a' + 10;
  800fd2:	0f be c9             	movsbl %cl,%ecx
  800fd5:	83 e9 57             	sub    $0x57,%ecx
  800fd8:	eb 0f                	jmp    800fe9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800fda:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800fdd:	89 f0                	mov    %esi,%eax
  800fdf:	3c 19                	cmp    $0x19,%al
  800fe1:	77 16                	ja     800ff9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800fe3:	0f be c9             	movsbl %cl,%ecx
  800fe6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800fe9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800fec:	7d 0f                	jge    800ffd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800fee:	83 c2 01             	add    $0x1,%edx
  800ff1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800ff5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800ff7:	eb bc                	jmp    800fb5 <strtol+0x72>
  800ff9:	89 d8                	mov    %ebx,%eax
  800ffb:	eb 02                	jmp    800fff <strtol+0xbc>
  800ffd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800fff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801003:	74 05                	je     80100a <strtol+0xc7>
		*endptr = (char *) s;
  801005:	8b 75 0c             	mov    0xc(%ebp),%esi
  801008:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80100a:	f7 d8                	neg    %eax
  80100c:	85 ff                	test   %edi,%edi
  80100e:	0f 44 c3             	cmove  %ebx,%eax
}
  801011:	5b                   	pop    %ebx
  801012:	5e                   	pop    %esi
  801013:	5f                   	pop    %edi
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    

00801016 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801016:	55                   	push   %ebp
  801017:	89 e5                	mov    %esp,%ebp
  801019:	57                   	push   %edi
  80101a:	56                   	push   %esi
  80101b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80101c:	b8 00 00 00 00       	mov    $0x0,%eax
  801021:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801024:	8b 55 08             	mov    0x8(%ebp),%edx
  801027:	89 c3                	mov    %eax,%ebx
  801029:	89 c7                	mov    %eax,%edi
  80102b:	89 c6                	mov    %eax,%esi
  80102d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80102f:	5b                   	pop    %ebx
  801030:	5e                   	pop    %esi
  801031:	5f                   	pop    %edi
  801032:	5d                   	pop    %ebp
  801033:	c3                   	ret    

00801034 <sys_cgetc>:

int
sys_cgetc(void)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	57                   	push   %edi
  801038:	56                   	push   %esi
  801039:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103a:	ba 00 00 00 00       	mov    $0x0,%edx
  80103f:	b8 01 00 00 00       	mov    $0x1,%eax
  801044:	89 d1                	mov    %edx,%ecx
  801046:	89 d3                	mov    %edx,%ebx
  801048:	89 d7                	mov    %edx,%edi
  80104a:	89 d6                	mov    %edx,%esi
  80104c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80104e:	5b                   	pop    %ebx
  80104f:	5e                   	pop    %esi
  801050:	5f                   	pop    %edi
  801051:	5d                   	pop    %ebp
  801052:	c3                   	ret    

00801053 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  80105c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801061:	b8 03 00 00 00       	mov    $0x3,%eax
  801066:	8b 55 08             	mov    0x8(%ebp),%edx
  801069:	89 cb                	mov    %ecx,%ebx
  80106b:	89 cf                	mov    %ecx,%edi
  80106d:	89 ce                	mov    %ecx,%esi
  80106f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801071:	85 c0                	test   %eax,%eax
  801073:	7e 28                	jle    80109d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801075:	89 44 24 10          	mov    %eax,0x10(%esp)
  801079:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801080:	00 
  801081:	c7 44 24 08 bf 37 80 	movl   $0x8037bf,0x8(%esp)
  801088:	00 
  801089:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801090:	00 
  801091:	c7 04 24 dc 37 80 00 	movl   $0x8037dc,(%esp)
  801098:	e8 0a f5 ff ff       	call   8005a7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80109d:	83 c4 2c             	add    $0x2c,%esp
  8010a0:	5b                   	pop    %ebx
  8010a1:	5e                   	pop    %esi
  8010a2:	5f                   	pop    %edi
  8010a3:	5d                   	pop    %ebp
  8010a4:	c3                   	ret    

008010a5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010a5:	55                   	push   %ebp
  8010a6:	89 e5                	mov    %esp,%ebp
  8010a8:	57                   	push   %edi
  8010a9:	56                   	push   %esi
  8010aa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8010b0:	b8 02 00 00 00       	mov    $0x2,%eax
  8010b5:	89 d1                	mov    %edx,%ecx
  8010b7:	89 d3                	mov    %edx,%ebx
  8010b9:	89 d7                	mov    %edx,%edi
  8010bb:	89 d6                	mov    %edx,%esi
  8010bd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010bf:	5b                   	pop    %ebx
  8010c0:	5e                   	pop    %esi
  8010c1:	5f                   	pop    %edi
  8010c2:	5d                   	pop    %ebp
  8010c3:	c3                   	ret    

008010c4 <sys_yield>:

void
sys_yield(void)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	57                   	push   %edi
  8010c8:	56                   	push   %esi
  8010c9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8010cf:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010d4:	89 d1                	mov    %edx,%ecx
  8010d6:	89 d3                	mov    %edx,%ebx
  8010d8:	89 d7                	mov    %edx,%edi
  8010da:	89 d6                	mov    %edx,%esi
  8010dc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010de:	5b                   	pop    %ebx
  8010df:	5e                   	pop    %esi
  8010e0:	5f                   	pop    %edi
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    

008010e3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	57                   	push   %edi
  8010e7:	56                   	push   %esi
  8010e8:	53                   	push   %ebx
  8010e9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ec:	be 00 00 00 00       	mov    $0x0,%esi
  8010f1:	b8 04 00 00 00       	mov    $0x4,%eax
  8010f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010ff:	89 f7                	mov    %esi,%edi
  801101:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801103:	85 c0                	test   %eax,%eax
  801105:	7e 28                	jle    80112f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801107:	89 44 24 10          	mov    %eax,0x10(%esp)
  80110b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801112:	00 
  801113:	c7 44 24 08 bf 37 80 	movl   $0x8037bf,0x8(%esp)
  80111a:	00 
  80111b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801122:	00 
  801123:	c7 04 24 dc 37 80 00 	movl   $0x8037dc,(%esp)
  80112a:	e8 78 f4 ff ff       	call   8005a7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80112f:	83 c4 2c             	add    $0x2c,%esp
  801132:	5b                   	pop    %ebx
  801133:	5e                   	pop    %esi
  801134:	5f                   	pop    %edi
  801135:	5d                   	pop    %ebp
  801136:	c3                   	ret    

00801137 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	57                   	push   %edi
  80113b:	56                   	push   %esi
  80113c:	53                   	push   %ebx
  80113d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801140:	b8 05 00 00 00       	mov    $0x5,%eax
  801145:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801148:	8b 55 08             	mov    0x8(%ebp),%edx
  80114b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80114e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801151:	8b 75 18             	mov    0x18(%ebp),%esi
  801154:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801156:	85 c0                	test   %eax,%eax
  801158:	7e 28                	jle    801182 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80115a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80115e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801165:	00 
  801166:	c7 44 24 08 bf 37 80 	movl   $0x8037bf,0x8(%esp)
  80116d:	00 
  80116e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801175:	00 
  801176:	c7 04 24 dc 37 80 00 	movl   $0x8037dc,(%esp)
  80117d:	e8 25 f4 ff ff       	call   8005a7 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801182:	83 c4 2c             	add    $0x2c,%esp
  801185:	5b                   	pop    %ebx
  801186:	5e                   	pop    %esi
  801187:	5f                   	pop    %edi
  801188:	5d                   	pop    %ebp
  801189:	c3                   	ret    

0080118a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80118a:	55                   	push   %ebp
  80118b:	89 e5                	mov    %esp,%ebp
  80118d:	57                   	push   %edi
  80118e:	56                   	push   %esi
  80118f:	53                   	push   %ebx
  801190:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801193:	bb 00 00 00 00       	mov    $0x0,%ebx
  801198:	b8 06 00 00 00       	mov    $0x6,%eax
  80119d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a3:	89 df                	mov    %ebx,%edi
  8011a5:	89 de                	mov    %ebx,%esi
  8011a7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	7e 28                	jle    8011d5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ad:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011b1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8011b8:	00 
  8011b9:	c7 44 24 08 bf 37 80 	movl   $0x8037bf,0x8(%esp)
  8011c0:	00 
  8011c1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011c8:	00 
  8011c9:	c7 04 24 dc 37 80 00 	movl   $0x8037dc,(%esp)
  8011d0:	e8 d2 f3 ff ff       	call   8005a7 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011d5:	83 c4 2c             	add    $0x2c,%esp
  8011d8:	5b                   	pop    %ebx
  8011d9:	5e                   	pop    %esi
  8011da:	5f                   	pop    %edi
  8011db:	5d                   	pop    %ebp
  8011dc:	c3                   	ret    

008011dd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
  8011e0:	57                   	push   %edi
  8011e1:	56                   	push   %esi
  8011e2:	53                   	push   %ebx
  8011e3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011eb:	b8 08 00 00 00       	mov    $0x8,%eax
  8011f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f6:	89 df                	mov    %ebx,%edi
  8011f8:	89 de                	mov    %ebx,%esi
  8011fa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011fc:	85 c0                	test   %eax,%eax
  8011fe:	7e 28                	jle    801228 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801200:	89 44 24 10          	mov    %eax,0x10(%esp)
  801204:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80120b:	00 
  80120c:	c7 44 24 08 bf 37 80 	movl   $0x8037bf,0x8(%esp)
  801213:	00 
  801214:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80121b:	00 
  80121c:	c7 04 24 dc 37 80 00 	movl   $0x8037dc,(%esp)
  801223:	e8 7f f3 ff ff       	call   8005a7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801228:	83 c4 2c             	add    $0x2c,%esp
  80122b:	5b                   	pop    %ebx
  80122c:	5e                   	pop    %esi
  80122d:	5f                   	pop    %edi
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    

00801230 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	57                   	push   %edi
  801234:	56                   	push   %esi
  801235:	53                   	push   %ebx
  801236:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801239:	bb 00 00 00 00       	mov    $0x0,%ebx
  80123e:	b8 09 00 00 00       	mov    $0x9,%eax
  801243:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801246:	8b 55 08             	mov    0x8(%ebp),%edx
  801249:	89 df                	mov    %ebx,%edi
  80124b:	89 de                	mov    %ebx,%esi
  80124d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80124f:	85 c0                	test   %eax,%eax
  801251:	7e 28                	jle    80127b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801253:	89 44 24 10          	mov    %eax,0x10(%esp)
  801257:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80125e:	00 
  80125f:	c7 44 24 08 bf 37 80 	movl   $0x8037bf,0x8(%esp)
  801266:	00 
  801267:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80126e:	00 
  80126f:	c7 04 24 dc 37 80 00 	movl   $0x8037dc,(%esp)
  801276:	e8 2c f3 ff ff       	call   8005a7 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80127b:	83 c4 2c             	add    $0x2c,%esp
  80127e:	5b                   	pop    %ebx
  80127f:	5e                   	pop    %esi
  801280:	5f                   	pop    %edi
  801281:	5d                   	pop    %ebp
  801282:	c3                   	ret    

00801283 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
  801286:	57                   	push   %edi
  801287:	56                   	push   %esi
  801288:	53                   	push   %ebx
  801289:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80128c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801291:	b8 0a 00 00 00       	mov    $0xa,%eax
  801296:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801299:	8b 55 08             	mov    0x8(%ebp),%edx
  80129c:	89 df                	mov    %ebx,%edi
  80129e:	89 de                	mov    %ebx,%esi
  8012a0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	7e 28                	jle    8012ce <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012a6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012aa:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8012b1:	00 
  8012b2:	c7 44 24 08 bf 37 80 	movl   $0x8037bf,0x8(%esp)
  8012b9:	00 
  8012ba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012c1:	00 
  8012c2:	c7 04 24 dc 37 80 00 	movl   $0x8037dc,(%esp)
  8012c9:	e8 d9 f2 ff ff       	call   8005a7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8012ce:	83 c4 2c             	add    $0x2c,%esp
  8012d1:	5b                   	pop    %ebx
  8012d2:	5e                   	pop    %esi
  8012d3:	5f                   	pop    %edi
  8012d4:	5d                   	pop    %ebp
  8012d5:	c3                   	ret    

008012d6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8012d6:	55                   	push   %ebp
  8012d7:	89 e5                	mov    %esp,%ebp
  8012d9:	57                   	push   %edi
  8012da:	56                   	push   %esi
  8012db:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012dc:	be 00 00 00 00       	mov    $0x0,%esi
  8012e1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012ef:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012f2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8012f4:	5b                   	pop    %ebx
  8012f5:	5e                   	pop    %esi
  8012f6:	5f                   	pop    %edi
  8012f7:	5d                   	pop    %ebp
  8012f8:	c3                   	ret    

008012f9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
  8012fc:	57                   	push   %edi
  8012fd:	56                   	push   %esi
  8012fe:	53                   	push   %ebx
  8012ff:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801302:	b9 00 00 00 00       	mov    $0x0,%ecx
  801307:	b8 0d 00 00 00       	mov    $0xd,%eax
  80130c:	8b 55 08             	mov    0x8(%ebp),%edx
  80130f:	89 cb                	mov    %ecx,%ebx
  801311:	89 cf                	mov    %ecx,%edi
  801313:	89 ce                	mov    %ecx,%esi
  801315:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801317:	85 c0                	test   %eax,%eax
  801319:	7e 28                	jle    801343 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80131b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80131f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801326:	00 
  801327:	c7 44 24 08 bf 37 80 	movl   $0x8037bf,0x8(%esp)
  80132e:	00 
  80132f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801336:	00 
  801337:	c7 04 24 dc 37 80 00 	movl   $0x8037dc,(%esp)
  80133e:	e8 64 f2 ff ff       	call   8005a7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801343:	83 c4 2c             	add    $0x2c,%esp
  801346:	5b                   	pop    %ebx
  801347:	5e                   	pop    %esi
  801348:	5f                   	pop    %edi
  801349:	5d                   	pop    %ebp
  80134a:	c3                   	ret    

0080134b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80134b:	55                   	push   %ebp
  80134c:	89 e5                	mov    %esp,%ebp
  80134e:	57                   	push   %edi
  80134f:	56                   	push   %esi
  801350:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801351:	ba 00 00 00 00       	mov    $0x0,%edx
  801356:	b8 0e 00 00 00       	mov    $0xe,%eax
  80135b:	89 d1                	mov    %edx,%ecx
  80135d:	89 d3                	mov    %edx,%ebx
  80135f:	89 d7                	mov    %edx,%edi
  801361:	89 d6                	mov    %edx,%esi
  801363:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801365:	5b                   	pop    %ebx
  801366:	5e                   	pop    %esi
  801367:	5f                   	pop    %edi
  801368:	5d                   	pop    %ebp
  801369:	c3                   	ret    

0080136a <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  80136a:	55                   	push   %ebp
  80136b:	89 e5                	mov    %esp,%ebp
  80136d:	57                   	push   %edi
  80136e:	56                   	push   %esi
  80136f:	53                   	push   %ebx
  801370:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801373:	bb 00 00 00 00       	mov    $0x0,%ebx
  801378:	b8 0f 00 00 00       	mov    $0xf,%eax
  80137d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801380:	8b 55 08             	mov    0x8(%ebp),%edx
  801383:	89 df                	mov    %ebx,%edi
  801385:	89 de                	mov    %ebx,%esi
  801387:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801389:	85 c0                	test   %eax,%eax
  80138b:	7e 28                	jle    8013b5 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80138d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801391:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801398:	00 
  801399:	c7 44 24 08 bf 37 80 	movl   $0x8037bf,0x8(%esp)
  8013a0:	00 
  8013a1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013a8:	00 
  8013a9:	c7 04 24 dc 37 80 00 	movl   $0x8037dc,(%esp)
  8013b0:	e8 f2 f1 ff ff       	call   8005a7 <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  8013b5:	83 c4 2c             	add    $0x2c,%esp
  8013b8:	5b                   	pop    %ebx
  8013b9:	5e                   	pop    %esi
  8013ba:	5f                   	pop    %edi
  8013bb:	5d                   	pop    %ebp
  8013bc:	c3                   	ret    

008013bd <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
  8013c0:	57                   	push   %edi
  8013c1:	56                   	push   %esi
  8013c2:	53                   	push   %ebx
  8013c3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013cb:	b8 10 00 00 00       	mov    $0x10,%eax
  8013d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8013d6:	89 df                	mov    %ebx,%edi
  8013d8:	89 de                	mov    %ebx,%esi
  8013da:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8013dc:	85 c0                	test   %eax,%eax
  8013de:	7e 28                	jle    801408 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013e0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013e4:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  8013eb:	00 
  8013ec:	c7 44 24 08 bf 37 80 	movl   $0x8037bf,0x8(%esp)
  8013f3:	00 
  8013f4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013fb:	00 
  8013fc:	c7 04 24 dc 37 80 00 	movl   $0x8037dc,(%esp)
  801403:	e8 9f f1 ff ff       	call   8005a7 <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  801408:	83 c4 2c             	add    $0x2c,%esp
  80140b:	5b                   	pop    %ebx
  80140c:	5e                   	pop    %esi
  80140d:	5f                   	pop    %edi
  80140e:	5d                   	pop    %ebp
  80140f:	c3                   	ret    

00801410 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801410:	55                   	push   %ebp
  801411:	89 e5                	mov    %esp,%ebp
  801413:	56                   	push   %esi
  801414:	53                   	push   %ebx
  801415:	83 ec 20             	sub    $0x20,%esp
  801418:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80141b:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if(!(err & FEC_WR)) {
  80141d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801421:	75 20                	jne    801443 <pgfault+0x33>
		panic("0x%x Not a write", addr);
  801423:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801427:	c7 44 24 08 ea 37 80 	movl   $0x8037ea,0x8(%esp)
  80142e:	00 
  80142f:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801436:	00 
  801437:	c7 04 24 fb 37 80 00 	movl   $0x8037fb,(%esp)
  80143e:	e8 64 f1 ff ff       	call   8005a7 <_panic>
	}

	if(!(uvpt[PGNUM(addr)] & PTE_COW)) {
  801443:	89 f0                	mov    %esi,%eax
  801445:	c1 e8 0c             	shr    $0xc,%eax
  801448:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80144f:	f6 c4 08             	test   $0x8,%ah
  801452:	75 1c                	jne    801470 <pgfault+0x60>
		panic("Not a COW page");
  801454:	c7 44 24 08 06 38 80 	movl   $0x803806,0x8(%esp)
  80145b:	00 
  80145c:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  801463:	00 
  801464:	c7 04 24 fb 37 80 00 	movl   $0x8037fb,(%esp)
  80146b:	e8 37 f1 ff ff       	call   8005a7 <_panic>

	// Allocate a new page, map it at a temporary location (PFTEMP), // copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	envid_t envid = sys_getenvid();
  801470:	e8 30 fc ff ff       	call   8010a5 <sys_getenvid>
  801475:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, PFTEMP, PTE_W | PTE_U | PTE_P);
  801477:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80147e:	00 
  80147f:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801486:	00 
  801487:	89 04 24             	mov    %eax,(%esp)
  80148a:	e8 54 fc ff ff       	call   8010e3 <sys_page_alloc>
	if(r < 0) {
  80148f:	85 c0                	test   %eax,%eax
  801491:	79 1c                	jns    8014af <pgfault+0x9f>
		panic("couldn't allocate page");
  801493:	c7 44 24 08 15 38 80 	movl   $0x803815,0x8(%esp)
  80149a:	00 
  80149b:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8014a2:	00 
  8014a3:	c7 04 24 fb 37 80 00 	movl   $0x8037fb,(%esp)
  8014aa:	e8 f8 f0 ff ff       	call   8005a7 <_panic>
	}

	memmove(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  8014af:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  8014b5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8014bc:	00 
  8014bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014c1:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8014c8:	e8 97 f9 ff ff       	call   800e64 <memmove>

	r = sys_page_map(envid, PFTEMP, envid, ROUNDDOWN(addr,PGSIZE), PTE_P | PTE_U | PTE_W);
  8014cd:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8014d4:	00 
  8014d5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8014d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014dd:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8014e4:	00 
  8014e5:	89 1c 24             	mov    %ebx,(%esp)
  8014e8:	e8 4a fc ff ff       	call   801137 <sys_page_map>
	if(r < 0) {
  8014ed:	85 c0                	test   %eax,%eax
  8014ef:	79 1c                	jns    80150d <pgfault+0xfd>
		panic("couldn't map page");
  8014f1:	c7 44 24 08 2c 38 80 	movl   $0x80382c,0x8(%esp)
  8014f8:	00 
  8014f9:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  801500:	00 
  801501:	c7 04 24 fb 37 80 00 	movl   $0x8037fb,(%esp)
  801508:	e8 9a f0 ff ff       	call   8005a7 <_panic>
	}
}
  80150d:	83 c4 20             	add    $0x20,%esp
  801510:	5b                   	pop    %ebx
  801511:	5e                   	pop    %esi
  801512:	5d                   	pop    %ebp
  801513:	c3                   	ret    

00801514 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801514:	55                   	push   %ebp
  801515:	89 e5                	mov    %esp,%ebp
  801517:	57                   	push   %edi
  801518:	56                   	push   %esi
  801519:	53                   	push   %ebx
  80151a:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envid;
	uintptr_t addr;
	int r = 0;

	set_pgfault_handler(pgfault);
  80151d:	c7 04 24 10 14 80 00 	movl   $0x801410,(%esp)
  801524:	e8 b1 19 00 00       	call   802eda <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801529:	b8 07 00 00 00       	mov    $0x7,%eax
  80152e:	cd 30                	int    $0x30
  801530:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801533:	89 45 d8             	mov    %eax,-0x28(%ebp)

	envid = sys_exofork();
	if(envid == 0) {
  801536:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80153d:	bf 00 00 00 00       	mov    $0x0,%edi
  801542:	85 c0                	test   %eax,%eax
  801544:	75 21                	jne    801567 <fork+0x53>
		thisenv = &envs[ENVX(sys_getenvid())];
  801546:	e8 5a fb ff ff       	call   8010a5 <sys_getenvid>
  80154b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801550:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801553:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801558:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  80155d:	b8 00 00 00 00       	mov    $0x0,%eax
  801562:	e9 8d 01 00 00       	jmp    8016f4 <fork+0x1e0>
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
  801567:	89 f8                	mov    %edi,%eax
  801569:	c1 e8 16             	shr    $0x16,%eax
  80156c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801573:	85 c0                	test   %eax,%eax
  801575:	0f 84 02 01 00 00    	je     80167d <fork+0x169>
  80157b:	89 fa                	mov    %edi,%edx
  80157d:	c1 ea 0c             	shr    $0xc,%edx
  801580:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801587:	85 c0                	test   %eax,%eax
  801589:	0f 84 ee 00 00 00    	je     80167d <fork+0x169>
//
static int
duppage(envid_t envid, unsigned pn)
{

	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P)) return 0;
  80158f:	89 d6                	mov    %edx,%esi
  801591:	c1 e6 0c             	shl    $0xc,%esi
  801594:	89 f0                	mov    %esi,%eax
  801596:	c1 e8 16             	shr    $0x16,%eax
  801599:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8015a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8015a5:	f6 c1 01             	test   $0x1,%cl
  8015a8:	0f 84 cc 00 00 00    	je     80167a <fork+0x166>

	int all_perms = PTE_U | PTE_P | PTE_AVAIL | PTE_W | PTE_COW;
	int orig_perms = uvpt[pn] & all_perms;
  8015ae:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  8015b5:	89 d8                	mov    %ebx,%eax
  8015b7:	25 07 0e 00 00       	and    $0xe07,%eax
  8015bc:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if(!(orig_perms & PTE_P)) return 0;
  8015bf:	89 d8                	mov    %ebx,%eax
  8015c1:	83 e0 01             	and    $0x1,%eax
  8015c4:	0f 84 b0 00 00 00    	je     80167a <fork+0x166>

	int r = 0;
	envid_t curenvid = sys_getenvid();
  8015ca:	e8 d6 fa ff ff       	call   8010a5 <sys_getenvid>
  8015cf:	89 45 dc             	mov    %eax,-0x24(%ebp)


	if(orig_perms & PTE_SHARE) {
  8015d2:	f7 45 e0 00 04 00 00 	testl  $0x400,-0x20(%ebp)
  8015d9:	74 28                	je     801603 <fork+0xef>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms & PTE_SYSCALL));
  8015db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8015de:	25 07 0e 00 00       	and    $0xe07,%eax
  8015e3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015e7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8015eb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8015ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8015f9:	89 04 24             	mov    %eax,(%esp)
  8015fc:	e8 36 fb ff ff       	call   801137 <sys_page_map>
  801601:	eb 77                	jmp    80167a <fork+0x166>

	} else if(((orig_perms) & PTE_COW) || (orig_perms & PTE_W) ) {
  801603:	f7 c3 02 08 00 00    	test   $0x802,%ebx
  801609:	74 4e                	je     801659 <fork+0x145>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  80160b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80160e:	25 fd f7 ff ff       	and    $0xfffff7fd,%eax
  801613:	80 cc 08             	or     $0x8,%ah
  801616:	89 c3                	mov    %eax,%ebx
  801618:	89 44 24 10          	mov    %eax,0x10(%esp)
  80161c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801620:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801623:	89 44 24 08          	mov    %eax,0x8(%esp)
  801627:	89 74 24 04          	mov    %esi,0x4(%esp)
  80162b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80162e:	89 04 24             	mov    %eax,(%esp)
  801631:	e8 01 fb ff ff       	call   801137 <sys_page_map>
  801636:	89 45 e0             	mov    %eax,-0x20(%ebp)

		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), curenvid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  801639:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80163d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801641:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801644:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801648:	89 74 24 04          	mov    %esi,0x4(%esp)
  80164c:	89 0c 24             	mov    %ecx,(%esp)
  80164f:	e8 e3 fa ff ff       	call   801137 <sys_page_map>
  801654:	03 45 e0             	add    -0x20(%ebp),%eax
  801657:	eb 21                	jmp    80167a <fork+0x166>

	} else {
		r = sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), orig_perms);
  801659:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80165c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801660:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801664:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801667:	89 44 24 08          	mov    %eax,0x8(%esp)
  80166b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80166f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801672:	89 04 24             	mov    %eax,(%esp)
  801675:	e8 bd fa ff ff       	call   801137 <sys_page_map>
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
  80167a:	01 45 e4             	add    %eax,-0x1c(%ebp)
	if(envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
  80167d:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801683:	81 ff 00 f0 bf ee    	cmp    $0xeebff000,%edi
  801689:	0f 85 d8 fe ff ff    	jne    801567 <fork+0x53>
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
		}
	}

	r+=sys_page_alloc(envid, (void*)UXSTACKTOP - PGSIZE, PTE_P|PTE_U|PTE_W);
  80168f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801696:	00 
  801697:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80169e:	ee 
  80169f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8016a2:	89 34 24             	mov    %esi,(%esp)
  8016a5:	e8 39 fa ff ff       	call   8010e3 <sys_page_alloc>
  8016aa:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8016ad:	01 c3                	add    %eax,%ebx
	r+=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8016af:	c7 44 24 04 27 2f 80 	movl   $0x802f27,0x4(%esp)
  8016b6:	00 
  8016b7:	89 34 24             	mov    %esi,(%esp)
  8016ba:	e8 c4 fb ff ff       	call   801283 <sys_env_set_pgfault_upcall>
  8016bf:	01 c3                	add    %eax,%ebx
	r+= sys_env_set_status(envid, ENV_RUNNABLE);
  8016c1:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8016c8:	00 
  8016c9:	89 34 24             	mov    %esi,(%esp)
  8016cc:	e8 0c fb ff ff       	call   8011dd <sys_env_set_status>

	if(r<0) {
  8016d1:	01 d8                	add    %ebx,%eax
  8016d3:	79 1c                	jns    8016f1 <fork+0x1dd>
	 panic("fork failed!");
  8016d5:	c7 44 24 08 3e 38 80 	movl   $0x80383e,0x8(%esp)
  8016dc:	00 
  8016dd:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  8016e4:	00 
  8016e5:	c7 04 24 fb 37 80 00 	movl   $0x8037fb,(%esp)
  8016ec:	e8 b6 ee ff ff       	call   8005a7 <_panic>
	}

	return envid;
  8016f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  8016f4:	83 c4 3c             	add    $0x3c,%esp
  8016f7:	5b                   	pop    %ebx
  8016f8:	5e                   	pop    %esi
  8016f9:	5f                   	pop    %edi
  8016fa:	5d                   	pop    %ebp
  8016fb:	c3                   	ret    

008016fc <sfork>:

// Challenge!
int
sfork(void)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801702:	c7 44 24 08 4b 38 80 	movl   $0x80384b,0x8(%esp)
  801709:	00 
  80170a:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
  801711:	00 
  801712:	c7 04 24 fb 37 80 00 	movl   $0x8037fb,(%esp)
  801719:	e8 89 ee ff ff       	call   8005a7 <_panic>
  80171e:	66 90                	xchg   %ax,%ax

00801720 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801723:	8b 45 08             	mov    0x8(%ebp),%eax
  801726:	05 00 00 00 30       	add    $0x30000000,%eax
  80172b:	c1 e8 0c             	shr    $0xc,%eax
}
  80172e:	5d                   	pop    %ebp
  80172f:	c3                   	ret    

00801730 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801733:	8b 45 08             	mov    0x8(%ebp),%eax
  801736:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80173b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801740:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801745:	5d                   	pop    %ebp
  801746:	c3                   	ret    

00801747 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801747:	55                   	push   %ebp
  801748:	89 e5                	mov    %esp,%ebp
  80174a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80174d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801752:	89 c2                	mov    %eax,%edx
  801754:	c1 ea 16             	shr    $0x16,%edx
  801757:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80175e:	f6 c2 01             	test   $0x1,%dl
  801761:	74 11                	je     801774 <fd_alloc+0x2d>
  801763:	89 c2                	mov    %eax,%edx
  801765:	c1 ea 0c             	shr    $0xc,%edx
  801768:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80176f:	f6 c2 01             	test   $0x1,%dl
  801772:	75 09                	jne    80177d <fd_alloc+0x36>
			*fd_store = fd;
  801774:	89 01                	mov    %eax,(%ecx)
			return 0;
  801776:	b8 00 00 00 00       	mov    $0x0,%eax
  80177b:	eb 17                	jmp    801794 <fd_alloc+0x4d>
  80177d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801782:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801787:	75 c9                	jne    801752 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801789:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80178f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801794:	5d                   	pop    %ebp
  801795:	c3                   	ret    

00801796 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801796:	55                   	push   %ebp
  801797:	89 e5                	mov    %esp,%ebp
  801799:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80179c:	83 f8 1f             	cmp    $0x1f,%eax
  80179f:	77 36                	ja     8017d7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8017a1:	c1 e0 0c             	shl    $0xc,%eax
  8017a4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8017a9:	89 c2                	mov    %eax,%edx
  8017ab:	c1 ea 16             	shr    $0x16,%edx
  8017ae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8017b5:	f6 c2 01             	test   $0x1,%dl
  8017b8:	74 24                	je     8017de <fd_lookup+0x48>
  8017ba:	89 c2                	mov    %eax,%edx
  8017bc:	c1 ea 0c             	shr    $0xc,%edx
  8017bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017c6:	f6 c2 01             	test   $0x1,%dl
  8017c9:	74 1a                	je     8017e5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8017cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017ce:	89 02                	mov    %eax,(%edx)
	return 0;
  8017d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d5:	eb 13                	jmp    8017ea <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8017d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017dc:	eb 0c                	jmp    8017ea <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8017de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017e3:	eb 05                	jmp    8017ea <fd_lookup+0x54>
  8017e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8017ea:	5d                   	pop    %ebp
  8017eb:	c3                   	ret    

008017ec <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	83 ec 18             	sub    $0x18,%esp
  8017f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8017f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fa:	eb 13                	jmp    80180f <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8017fc:	39 08                	cmp    %ecx,(%eax)
  8017fe:	75 0c                	jne    80180c <dev_lookup+0x20>
			*dev = devtab[i];
  801800:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801803:	89 01                	mov    %eax,(%ecx)
			return 0;
  801805:	b8 00 00 00 00       	mov    $0x0,%eax
  80180a:	eb 38                	jmp    801844 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80180c:	83 c2 01             	add    $0x1,%edx
  80180f:	8b 04 95 e0 38 80 00 	mov    0x8038e0(,%edx,4),%eax
  801816:	85 c0                	test   %eax,%eax
  801818:	75 e2                	jne    8017fc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80181a:	a1 08 50 80 00       	mov    0x805008,%eax
  80181f:	8b 40 48             	mov    0x48(%eax),%eax
  801822:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801826:	89 44 24 04          	mov    %eax,0x4(%esp)
  80182a:	c7 04 24 64 38 80 00 	movl   $0x803864,(%esp)
  801831:	e8 6a ee ff ff       	call   8006a0 <cprintf>
	*dev = 0;
  801836:	8b 45 0c             	mov    0xc(%ebp),%eax
  801839:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80183f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801844:	c9                   	leave  
  801845:	c3                   	ret    

00801846 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	56                   	push   %esi
  80184a:	53                   	push   %ebx
  80184b:	83 ec 20             	sub    $0x20,%esp
  80184e:	8b 75 08             	mov    0x8(%ebp),%esi
  801851:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801854:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801857:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80185b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801861:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801864:	89 04 24             	mov    %eax,(%esp)
  801867:	e8 2a ff ff ff       	call   801796 <fd_lookup>
  80186c:	85 c0                	test   %eax,%eax
  80186e:	78 05                	js     801875 <fd_close+0x2f>
	    || fd != fd2)
  801870:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801873:	74 0c                	je     801881 <fd_close+0x3b>
		return (must_exist ? r : 0);
  801875:	84 db                	test   %bl,%bl
  801877:	ba 00 00 00 00       	mov    $0x0,%edx
  80187c:	0f 44 c2             	cmove  %edx,%eax
  80187f:	eb 3f                	jmp    8018c0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801881:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801884:	89 44 24 04          	mov    %eax,0x4(%esp)
  801888:	8b 06                	mov    (%esi),%eax
  80188a:	89 04 24             	mov    %eax,(%esp)
  80188d:	e8 5a ff ff ff       	call   8017ec <dev_lookup>
  801892:	89 c3                	mov    %eax,%ebx
  801894:	85 c0                	test   %eax,%eax
  801896:	78 16                	js     8018ae <fd_close+0x68>
		if (dev->dev_close)
  801898:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80189e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8018a3:	85 c0                	test   %eax,%eax
  8018a5:	74 07                	je     8018ae <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8018a7:	89 34 24             	mov    %esi,(%esp)
  8018aa:	ff d0                	call   *%eax
  8018ac:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8018ae:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018b9:	e8 cc f8 ff ff       	call   80118a <sys_page_unmap>
	return r;
  8018be:	89 d8                	mov    %ebx,%eax
}
  8018c0:	83 c4 20             	add    $0x20,%esp
  8018c3:	5b                   	pop    %ebx
  8018c4:	5e                   	pop    %esi
  8018c5:	5d                   	pop    %ebp
  8018c6:	c3                   	ret    

008018c7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8018c7:	55                   	push   %ebp
  8018c8:	89 e5                	mov    %esp,%ebp
  8018ca:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d7:	89 04 24             	mov    %eax,(%esp)
  8018da:	e8 b7 fe ff ff       	call   801796 <fd_lookup>
  8018df:	89 c2                	mov    %eax,%edx
  8018e1:	85 d2                	test   %edx,%edx
  8018e3:	78 13                	js     8018f8 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8018e5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8018ec:	00 
  8018ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f0:	89 04 24             	mov    %eax,(%esp)
  8018f3:	e8 4e ff ff ff       	call   801846 <fd_close>
}
  8018f8:	c9                   	leave  
  8018f9:	c3                   	ret    

008018fa <close_all>:

void
close_all(void)
{
  8018fa:	55                   	push   %ebp
  8018fb:	89 e5                	mov    %esp,%ebp
  8018fd:	53                   	push   %ebx
  8018fe:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801901:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801906:	89 1c 24             	mov    %ebx,(%esp)
  801909:	e8 b9 ff ff ff       	call   8018c7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80190e:	83 c3 01             	add    $0x1,%ebx
  801911:	83 fb 20             	cmp    $0x20,%ebx
  801914:	75 f0                	jne    801906 <close_all+0xc>
		close(i);
}
  801916:	83 c4 14             	add    $0x14,%esp
  801919:	5b                   	pop    %ebx
  80191a:	5d                   	pop    %ebp
  80191b:	c3                   	ret    

0080191c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	57                   	push   %edi
  801920:	56                   	push   %esi
  801921:	53                   	push   %ebx
  801922:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801925:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801928:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192c:	8b 45 08             	mov    0x8(%ebp),%eax
  80192f:	89 04 24             	mov    %eax,(%esp)
  801932:	e8 5f fe ff ff       	call   801796 <fd_lookup>
  801937:	89 c2                	mov    %eax,%edx
  801939:	85 d2                	test   %edx,%edx
  80193b:	0f 88 e1 00 00 00    	js     801a22 <dup+0x106>
		return r;
	close(newfdnum);
  801941:	8b 45 0c             	mov    0xc(%ebp),%eax
  801944:	89 04 24             	mov    %eax,(%esp)
  801947:	e8 7b ff ff ff       	call   8018c7 <close>

	newfd = INDEX2FD(newfdnum);
  80194c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80194f:	c1 e3 0c             	shl    $0xc,%ebx
  801952:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801958:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80195b:	89 04 24             	mov    %eax,(%esp)
  80195e:	e8 cd fd ff ff       	call   801730 <fd2data>
  801963:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801965:	89 1c 24             	mov    %ebx,(%esp)
  801968:	e8 c3 fd ff ff       	call   801730 <fd2data>
  80196d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80196f:	89 f0                	mov    %esi,%eax
  801971:	c1 e8 16             	shr    $0x16,%eax
  801974:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80197b:	a8 01                	test   $0x1,%al
  80197d:	74 43                	je     8019c2 <dup+0xa6>
  80197f:	89 f0                	mov    %esi,%eax
  801981:	c1 e8 0c             	shr    $0xc,%eax
  801984:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80198b:	f6 c2 01             	test   $0x1,%dl
  80198e:	74 32                	je     8019c2 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801990:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801997:	25 07 0e 00 00       	and    $0xe07,%eax
  80199c:	89 44 24 10          	mov    %eax,0x10(%esp)
  8019a0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8019a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019ab:	00 
  8019ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019b7:	e8 7b f7 ff ff       	call   801137 <sys_page_map>
  8019bc:	89 c6                	mov    %eax,%esi
  8019be:	85 c0                	test   %eax,%eax
  8019c0:	78 3e                	js     801a00 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8019c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019c5:	89 c2                	mov    %eax,%edx
  8019c7:	c1 ea 0c             	shr    $0xc,%edx
  8019ca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8019d1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8019d7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8019db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8019df:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019e6:	00 
  8019e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019f2:	e8 40 f7 ff ff       	call   801137 <sys_page_map>
  8019f7:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8019f9:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8019fc:	85 f6                	test   %esi,%esi
  8019fe:	79 22                	jns    801a22 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801a00:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a04:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a0b:	e8 7a f7 ff ff       	call   80118a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801a10:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a14:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a1b:	e8 6a f7 ff ff       	call   80118a <sys_page_unmap>
	return r;
  801a20:	89 f0                	mov    %esi,%eax
}
  801a22:	83 c4 3c             	add    $0x3c,%esp
  801a25:	5b                   	pop    %ebx
  801a26:	5e                   	pop    %esi
  801a27:	5f                   	pop    %edi
  801a28:	5d                   	pop    %ebp
  801a29:	c3                   	ret    

00801a2a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801a2a:	55                   	push   %ebp
  801a2b:	89 e5                	mov    %esp,%ebp
  801a2d:	53                   	push   %ebx
  801a2e:	83 ec 24             	sub    $0x24,%esp
  801a31:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a34:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a3b:	89 1c 24             	mov    %ebx,(%esp)
  801a3e:	e8 53 fd ff ff       	call   801796 <fd_lookup>
  801a43:	89 c2                	mov    %eax,%edx
  801a45:	85 d2                	test   %edx,%edx
  801a47:	78 6d                	js     801ab6 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a49:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a50:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a53:	8b 00                	mov    (%eax),%eax
  801a55:	89 04 24             	mov    %eax,(%esp)
  801a58:	e8 8f fd ff ff       	call   8017ec <dev_lookup>
  801a5d:	85 c0                	test   %eax,%eax
  801a5f:	78 55                	js     801ab6 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801a61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a64:	8b 50 08             	mov    0x8(%eax),%edx
  801a67:	83 e2 03             	and    $0x3,%edx
  801a6a:	83 fa 01             	cmp    $0x1,%edx
  801a6d:	75 23                	jne    801a92 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801a6f:	a1 08 50 80 00       	mov    0x805008,%eax
  801a74:	8b 40 48             	mov    0x48(%eax),%eax
  801a77:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a7f:	c7 04 24 a5 38 80 00 	movl   $0x8038a5,(%esp)
  801a86:	e8 15 ec ff ff       	call   8006a0 <cprintf>
		return -E_INVAL;
  801a8b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a90:	eb 24                	jmp    801ab6 <read+0x8c>
	}
	if (!dev->dev_read)
  801a92:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a95:	8b 52 08             	mov    0x8(%edx),%edx
  801a98:	85 d2                	test   %edx,%edx
  801a9a:	74 15                	je     801ab1 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801a9c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a9f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801aa3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aa6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801aaa:	89 04 24             	mov    %eax,(%esp)
  801aad:	ff d2                	call   *%edx
  801aaf:	eb 05                	jmp    801ab6 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801ab1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801ab6:	83 c4 24             	add    $0x24,%esp
  801ab9:	5b                   	pop    %ebx
  801aba:	5d                   	pop    %ebp
  801abb:	c3                   	ret    

00801abc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	57                   	push   %edi
  801ac0:	56                   	push   %esi
  801ac1:	53                   	push   %ebx
  801ac2:	83 ec 1c             	sub    $0x1c,%esp
  801ac5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ac8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801acb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ad0:	eb 23                	jmp    801af5 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801ad2:	89 f0                	mov    %esi,%eax
  801ad4:	29 d8                	sub    %ebx,%eax
  801ad6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ada:	89 d8                	mov    %ebx,%eax
  801adc:	03 45 0c             	add    0xc(%ebp),%eax
  801adf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae3:	89 3c 24             	mov    %edi,(%esp)
  801ae6:	e8 3f ff ff ff       	call   801a2a <read>
		if (m < 0)
  801aeb:	85 c0                	test   %eax,%eax
  801aed:	78 10                	js     801aff <readn+0x43>
			return m;
		if (m == 0)
  801aef:	85 c0                	test   %eax,%eax
  801af1:	74 0a                	je     801afd <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801af3:	01 c3                	add    %eax,%ebx
  801af5:	39 f3                	cmp    %esi,%ebx
  801af7:	72 d9                	jb     801ad2 <readn+0x16>
  801af9:	89 d8                	mov    %ebx,%eax
  801afb:	eb 02                	jmp    801aff <readn+0x43>
  801afd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801aff:	83 c4 1c             	add    $0x1c,%esp
  801b02:	5b                   	pop    %ebx
  801b03:	5e                   	pop    %esi
  801b04:	5f                   	pop    %edi
  801b05:	5d                   	pop    %ebp
  801b06:	c3                   	ret    

00801b07 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	53                   	push   %ebx
  801b0b:	83 ec 24             	sub    $0x24,%esp
  801b0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b11:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b14:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b18:	89 1c 24             	mov    %ebx,(%esp)
  801b1b:	e8 76 fc ff ff       	call   801796 <fd_lookup>
  801b20:	89 c2                	mov    %eax,%edx
  801b22:	85 d2                	test   %edx,%edx
  801b24:	78 68                	js     801b8e <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b26:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b29:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b30:	8b 00                	mov    (%eax),%eax
  801b32:	89 04 24             	mov    %eax,(%esp)
  801b35:	e8 b2 fc ff ff       	call   8017ec <dev_lookup>
  801b3a:	85 c0                	test   %eax,%eax
  801b3c:	78 50                	js     801b8e <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b41:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801b45:	75 23                	jne    801b6a <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801b47:	a1 08 50 80 00       	mov    0x805008,%eax
  801b4c:	8b 40 48             	mov    0x48(%eax),%eax
  801b4f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b53:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b57:	c7 04 24 c1 38 80 00 	movl   $0x8038c1,(%esp)
  801b5e:	e8 3d eb ff ff       	call   8006a0 <cprintf>
		return -E_INVAL;
  801b63:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b68:	eb 24                	jmp    801b8e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801b6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b6d:	8b 52 0c             	mov    0xc(%edx),%edx
  801b70:	85 d2                	test   %edx,%edx
  801b72:	74 15                	je     801b89 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801b74:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801b77:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b7e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b82:	89 04 24             	mov    %eax,(%esp)
  801b85:	ff d2                	call   *%edx
  801b87:	eb 05                	jmp    801b8e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801b89:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801b8e:	83 c4 24             	add    $0x24,%esp
  801b91:	5b                   	pop    %ebx
  801b92:	5d                   	pop    %ebp
  801b93:	c3                   	ret    

00801b94 <seek>:

int
seek(int fdnum, off_t offset)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b9a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801b9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba4:	89 04 24             	mov    %eax,(%esp)
  801ba7:	e8 ea fb ff ff       	call   801796 <fd_lookup>
  801bac:	85 c0                	test   %eax,%eax
  801bae:	78 0e                	js     801bbe <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801bb0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801bb3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bb6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801bb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bbe:	c9                   	leave  
  801bbf:	c3                   	ret    

00801bc0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	53                   	push   %ebx
  801bc4:	83 ec 24             	sub    $0x24,%esp
  801bc7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd1:	89 1c 24             	mov    %ebx,(%esp)
  801bd4:	e8 bd fb ff ff       	call   801796 <fd_lookup>
  801bd9:	89 c2                	mov    %eax,%edx
  801bdb:	85 d2                	test   %edx,%edx
  801bdd:	78 61                	js     801c40 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801bdf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801be9:	8b 00                	mov    (%eax),%eax
  801beb:	89 04 24             	mov    %eax,(%esp)
  801bee:	e8 f9 fb ff ff       	call   8017ec <dev_lookup>
  801bf3:	85 c0                	test   %eax,%eax
  801bf5:	78 49                	js     801c40 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801bf7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bfa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801bfe:	75 23                	jne    801c23 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801c00:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801c05:	8b 40 48             	mov    0x48(%eax),%eax
  801c08:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c10:	c7 04 24 84 38 80 00 	movl   $0x803884,(%esp)
  801c17:	e8 84 ea ff ff       	call   8006a0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801c1c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c21:	eb 1d                	jmp    801c40 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801c23:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c26:	8b 52 18             	mov    0x18(%edx),%edx
  801c29:	85 d2                	test   %edx,%edx
  801c2b:	74 0e                	je     801c3b <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801c2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c30:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801c34:	89 04 24             	mov    %eax,(%esp)
  801c37:	ff d2                	call   *%edx
  801c39:	eb 05                	jmp    801c40 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801c3b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801c40:	83 c4 24             	add    $0x24,%esp
  801c43:	5b                   	pop    %ebx
  801c44:	5d                   	pop    %ebp
  801c45:	c3                   	ret    

00801c46 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801c46:	55                   	push   %ebp
  801c47:	89 e5                	mov    %esp,%ebp
  801c49:	53                   	push   %ebx
  801c4a:	83 ec 24             	sub    $0x24,%esp
  801c4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c50:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c53:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c57:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5a:	89 04 24             	mov    %eax,(%esp)
  801c5d:	e8 34 fb ff ff       	call   801796 <fd_lookup>
  801c62:	89 c2                	mov    %eax,%edx
  801c64:	85 d2                	test   %edx,%edx
  801c66:	78 52                	js     801cba <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c72:	8b 00                	mov    (%eax),%eax
  801c74:	89 04 24             	mov    %eax,(%esp)
  801c77:	e8 70 fb ff ff       	call   8017ec <dev_lookup>
  801c7c:	85 c0                	test   %eax,%eax
  801c7e:	78 3a                	js     801cba <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c83:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801c87:	74 2c                	je     801cb5 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801c89:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801c8c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801c93:	00 00 00 
	stat->st_isdir = 0;
  801c96:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c9d:	00 00 00 
	stat->st_dev = dev;
  801ca0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801ca6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801caa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801cad:	89 14 24             	mov    %edx,(%esp)
  801cb0:	ff 50 14             	call   *0x14(%eax)
  801cb3:	eb 05                	jmp    801cba <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801cb5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801cba:	83 c4 24             	add    $0x24,%esp
  801cbd:	5b                   	pop    %ebx
  801cbe:	5d                   	pop    %ebp
  801cbf:	c3                   	ret    

00801cc0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
  801cc3:	56                   	push   %esi
  801cc4:	53                   	push   %ebx
  801cc5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801cc8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ccf:	00 
  801cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd3:	89 04 24             	mov    %eax,(%esp)
  801cd6:	e8 28 02 00 00       	call   801f03 <open>
  801cdb:	89 c3                	mov    %eax,%ebx
  801cdd:	85 db                	test   %ebx,%ebx
  801cdf:	78 1b                	js     801cfc <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801ce1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ce4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ce8:	89 1c 24             	mov    %ebx,(%esp)
  801ceb:	e8 56 ff ff ff       	call   801c46 <fstat>
  801cf0:	89 c6                	mov    %eax,%esi
	close(fd);
  801cf2:	89 1c 24             	mov    %ebx,(%esp)
  801cf5:	e8 cd fb ff ff       	call   8018c7 <close>
	return r;
  801cfa:	89 f0                	mov    %esi,%eax
}
  801cfc:	83 c4 10             	add    $0x10,%esp
  801cff:	5b                   	pop    %ebx
  801d00:	5e                   	pop    %esi
  801d01:	5d                   	pop    %ebp
  801d02:	c3                   	ret    

00801d03 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801d03:	55                   	push   %ebp
  801d04:	89 e5                	mov    %esp,%ebp
  801d06:	56                   	push   %esi
  801d07:	53                   	push   %ebx
  801d08:	83 ec 10             	sub    $0x10,%esp
  801d0b:	89 c6                	mov    %eax,%esi
  801d0d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801d0f:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801d16:	75 11                	jne    801d29 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801d18:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801d1f:	e8 11 13 00 00       	call   803035 <ipc_find_env>
  801d24:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801d29:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d30:	00 
  801d31:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801d38:	00 
  801d39:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d3d:	a1 00 50 80 00       	mov    0x805000,%eax
  801d42:	89 04 24             	mov    %eax,(%esp)
  801d45:	e8 80 12 00 00       	call   802fca <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801d4a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d51:	00 
  801d52:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d56:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d5d:	e8 ee 11 00 00       	call   802f50 <ipc_recv>
}
  801d62:	83 c4 10             	add    $0x10,%esp
  801d65:	5b                   	pop    %ebx
  801d66:	5e                   	pop    %esi
  801d67:	5d                   	pop    %ebp
  801d68:	c3                   	ret    

00801d69 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801d69:	55                   	push   %ebp
  801d6a:	89 e5                	mov    %esp,%ebp
  801d6c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d72:	8b 40 0c             	mov    0xc(%eax),%eax
  801d75:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801d7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d7d:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801d82:	ba 00 00 00 00       	mov    $0x0,%edx
  801d87:	b8 02 00 00 00       	mov    $0x2,%eax
  801d8c:	e8 72 ff ff ff       	call   801d03 <fsipc>
}
  801d91:	c9                   	leave  
  801d92:	c3                   	ret    

00801d93 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801d93:	55                   	push   %ebp
  801d94:	89 e5                	mov    %esp,%ebp
  801d96:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801d99:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9c:	8b 40 0c             	mov    0xc(%eax),%eax
  801d9f:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801da4:	ba 00 00 00 00       	mov    $0x0,%edx
  801da9:	b8 06 00 00 00       	mov    $0x6,%eax
  801dae:	e8 50 ff ff ff       	call   801d03 <fsipc>
}
  801db3:	c9                   	leave  
  801db4:	c3                   	ret    

00801db5 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801db5:	55                   	push   %ebp
  801db6:	89 e5                	mov    %esp,%ebp
  801db8:	53                   	push   %ebx
  801db9:	83 ec 14             	sub    $0x14,%esp
  801dbc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801dbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc2:	8b 40 0c             	mov    0xc(%eax),%eax
  801dc5:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801dca:	ba 00 00 00 00       	mov    $0x0,%edx
  801dcf:	b8 05 00 00 00       	mov    $0x5,%eax
  801dd4:	e8 2a ff ff ff       	call   801d03 <fsipc>
  801dd9:	89 c2                	mov    %eax,%edx
  801ddb:	85 d2                	test   %edx,%edx
  801ddd:	78 2b                	js     801e0a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ddf:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801de6:	00 
  801de7:	89 1c 24             	mov    %ebx,(%esp)
  801dea:	e8 d8 ee ff ff       	call   800cc7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801def:	a1 80 60 80 00       	mov    0x806080,%eax
  801df4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801dfa:	a1 84 60 80 00       	mov    0x806084,%eax
  801dff:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801e05:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e0a:	83 c4 14             	add    $0x14,%esp
  801e0d:	5b                   	pop    %ebx
  801e0e:	5d                   	pop    %ebp
  801e0f:	c3                   	ret    

00801e10 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	83 ec 18             	sub    $0x18,%esp
  801e16:	8b 45 10             	mov    0x10(%ebp),%eax
  801e19:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801e1e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801e23:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801e26:	8b 55 08             	mov    0x8(%ebp),%edx
  801e29:	8b 52 0c             	mov    0xc(%edx),%edx
  801e2c:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801e32:	a3 04 60 80 00       	mov    %eax,0x806004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801e37:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e42:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801e49:	e8 16 f0 ff ff       	call   800e64 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  801e4e:	ba 00 00 00 00       	mov    $0x0,%edx
  801e53:	b8 04 00 00 00       	mov    $0x4,%eax
  801e58:	e8 a6 fe ff ff       	call   801d03 <fsipc>
}
  801e5d:	c9                   	leave  
  801e5e:	c3                   	ret    

00801e5f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801e5f:	55                   	push   %ebp
  801e60:	89 e5                	mov    %esp,%ebp
  801e62:	56                   	push   %esi
  801e63:	53                   	push   %ebx
  801e64:	83 ec 10             	sub    $0x10,%esp
  801e67:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801e6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6d:	8b 40 0c             	mov    0xc(%eax),%eax
  801e70:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801e75:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801e7b:	ba 00 00 00 00       	mov    $0x0,%edx
  801e80:	b8 03 00 00 00       	mov    $0x3,%eax
  801e85:	e8 79 fe ff ff       	call   801d03 <fsipc>
  801e8a:	89 c3                	mov    %eax,%ebx
  801e8c:	85 c0                	test   %eax,%eax
  801e8e:	78 6a                	js     801efa <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801e90:	39 c6                	cmp    %eax,%esi
  801e92:	73 24                	jae    801eb8 <devfile_read+0x59>
  801e94:	c7 44 24 0c f4 38 80 	movl   $0x8038f4,0xc(%esp)
  801e9b:	00 
  801e9c:	c7 44 24 08 fb 38 80 	movl   $0x8038fb,0x8(%esp)
  801ea3:	00 
  801ea4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801eab:	00 
  801eac:	c7 04 24 10 39 80 00 	movl   $0x803910,(%esp)
  801eb3:	e8 ef e6 ff ff       	call   8005a7 <_panic>
	assert(r <= PGSIZE);
  801eb8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ebd:	7e 24                	jle    801ee3 <devfile_read+0x84>
  801ebf:	c7 44 24 0c 1b 39 80 	movl   $0x80391b,0xc(%esp)
  801ec6:	00 
  801ec7:	c7 44 24 08 fb 38 80 	movl   $0x8038fb,0x8(%esp)
  801ece:	00 
  801ecf:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801ed6:	00 
  801ed7:	c7 04 24 10 39 80 00 	movl   $0x803910,(%esp)
  801ede:	e8 c4 e6 ff ff       	call   8005a7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ee3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ee7:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801eee:	00 
  801eef:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef2:	89 04 24             	mov    %eax,(%esp)
  801ef5:	e8 6a ef ff ff       	call   800e64 <memmove>
	return r;
}
  801efa:	89 d8                	mov    %ebx,%eax
  801efc:	83 c4 10             	add    $0x10,%esp
  801eff:	5b                   	pop    %ebx
  801f00:	5e                   	pop    %esi
  801f01:	5d                   	pop    %ebp
  801f02:	c3                   	ret    

00801f03 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801f03:	55                   	push   %ebp
  801f04:	89 e5                	mov    %esp,%ebp
  801f06:	53                   	push   %ebx
  801f07:	83 ec 24             	sub    $0x24,%esp
  801f0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801f0d:	89 1c 24             	mov    %ebx,(%esp)
  801f10:	e8 7b ed ff ff       	call   800c90 <strlen>
  801f15:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801f1a:	7f 60                	jg     801f7c <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801f1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f1f:	89 04 24             	mov    %eax,(%esp)
  801f22:	e8 20 f8 ff ff       	call   801747 <fd_alloc>
  801f27:	89 c2                	mov    %eax,%edx
  801f29:	85 d2                	test   %edx,%edx
  801f2b:	78 54                	js     801f81 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801f2d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f31:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801f38:	e8 8a ed ff ff       	call   800cc7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801f3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f40:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801f45:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f48:	b8 01 00 00 00       	mov    $0x1,%eax
  801f4d:	e8 b1 fd ff ff       	call   801d03 <fsipc>
  801f52:	89 c3                	mov    %eax,%ebx
  801f54:	85 c0                	test   %eax,%eax
  801f56:	79 17                	jns    801f6f <open+0x6c>
		fd_close(fd, 0);
  801f58:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f5f:	00 
  801f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f63:	89 04 24             	mov    %eax,(%esp)
  801f66:	e8 db f8 ff ff       	call   801846 <fd_close>
		return r;
  801f6b:	89 d8                	mov    %ebx,%eax
  801f6d:	eb 12                	jmp    801f81 <open+0x7e>
	}

	return fd2num(fd);
  801f6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f72:	89 04 24             	mov    %eax,(%esp)
  801f75:	e8 a6 f7 ff ff       	call   801720 <fd2num>
  801f7a:	eb 05                	jmp    801f81 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801f7c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801f81:	83 c4 24             	add    $0x24,%esp
  801f84:	5b                   	pop    %ebx
  801f85:	5d                   	pop    %ebp
  801f86:	c3                   	ret    

00801f87 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801f87:	55                   	push   %ebp
  801f88:	89 e5                	mov    %esp,%ebp
  801f8a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801f8d:	ba 00 00 00 00       	mov    $0x0,%edx
  801f92:	b8 08 00 00 00       	mov    $0x8,%eax
  801f97:	e8 67 fd ff ff       	call   801d03 <fsipc>
}
  801f9c:	c9                   	leave  
  801f9d:	c3                   	ret    
  801f9e:	66 90                	xchg   %ax,%ax

00801fa0 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801fa0:	55                   	push   %ebp
  801fa1:	89 e5                	mov    %esp,%ebp
  801fa3:	57                   	push   %edi
  801fa4:	56                   	push   %esi
  801fa5:	53                   	push   %ebx
  801fa6:	81 ec 9c 02 00 00    	sub    $0x29c,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801fac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801fb3:	00 
  801fb4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb7:	89 04 24             	mov    %eax,(%esp)
  801fba:	e8 44 ff ff ff       	call   801f03 <open>
  801fbf:	89 c2                	mov    %eax,%edx
  801fc1:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801fc7:	85 c0                	test   %eax,%eax
  801fc9:	0f 88 3e 05 00 00    	js     80250d <spawn+0x56d>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801fcf:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801fd6:	00 
  801fd7:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801fdd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe1:	89 14 24             	mov    %edx,(%esp)
  801fe4:	e8 d3 fa ff ff       	call   801abc <readn>
  801fe9:	3d 00 02 00 00       	cmp    $0x200,%eax
  801fee:	75 0c                	jne    801ffc <spawn+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  801ff0:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801ff7:	45 4c 46 
  801ffa:	74 36                	je     802032 <spawn+0x92>
		close(fd);
  801ffc:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802002:	89 04 24             	mov    %eax,(%esp)
  802005:	e8 bd f8 ff ff       	call   8018c7 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80200a:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  802011:	46 
  802012:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  802018:	89 44 24 04          	mov    %eax,0x4(%esp)
  80201c:	c7 04 24 27 39 80 00 	movl   $0x803927,(%esp)
  802023:	e8 78 e6 ff ff       	call   8006a0 <cprintf>
		return -E_NOT_EXEC;
  802028:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  80202d:	e9 3a 05 00 00       	jmp    80256c <spawn+0x5cc>
  802032:	b8 07 00 00 00       	mov    $0x7,%eax
  802037:	cd 30                	int    $0x30
  802039:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80203f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802045:	85 c0                	test   %eax,%eax
  802047:	0f 88 c8 04 00 00    	js     802515 <spawn+0x575>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80204d:	89 c6                	mov    %eax,%esi
  80204f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  802055:	6b f6 7c             	imul   $0x7c,%esi,%esi
  802058:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80205e:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802064:	b9 11 00 00 00       	mov    $0x11,%ecx
  802069:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80206b:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  802071:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802077:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80207c:	be 00 00 00 00       	mov    $0x0,%esi
  802081:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802084:	eb 0f                	jmp    802095 <spawn+0xf5>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  802086:	89 04 24             	mov    %eax,(%esp)
  802089:	e8 02 ec ff ff       	call   800c90 <strlen>
  80208e:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802092:	83 c3 01             	add    $0x1,%ebx
  802095:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80209c:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80209f:	85 c0                	test   %eax,%eax
  8020a1:	75 e3                	jne    802086 <spawn+0xe6>
  8020a3:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  8020a9:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8020af:	bf 00 10 40 00       	mov    $0x401000,%edi
  8020b4:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8020b6:	89 fa                	mov    %edi,%edx
  8020b8:	83 e2 fc             	and    $0xfffffffc,%edx
  8020bb:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8020c2:	29 c2                	sub    %eax,%edx
  8020c4:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8020ca:	8d 42 f8             	lea    -0x8(%edx),%eax
  8020cd:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8020d2:	0f 86 4d 04 00 00    	jbe    802525 <spawn+0x585>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8020d8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8020df:	00 
  8020e0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8020e7:	00 
  8020e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020ef:	e8 ef ef ff ff       	call   8010e3 <sys_page_alloc>
  8020f4:	85 c0                	test   %eax,%eax
  8020f6:	0f 88 70 04 00 00    	js     80256c <spawn+0x5cc>
  8020fc:	be 00 00 00 00       	mov    $0x0,%esi
  802101:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  802107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80210a:	eb 30                	jmp    80213c <spawn+0x19c>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80210c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802112:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802118:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  80211b:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  80211e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802122:	89 3c 24             	mov    %edi,(%esp)
  802125:	e8 9d eb ff ff       	call   800cc7 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80212a:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  80212d:	89 04 24             	mov    %eax,(%esp)
  802130:	e8 5b eb ff ff       	call   800c90 <strlen>
  802135:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802139:	83 c6 01             	add    $0x1,%esi
  80213c:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  802142:	7f c8                	jg     80210c <spawn+0x16c>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  802144:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80214a:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  802150:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802157:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80215d:	74 24                	je     802183 <spawn+0x1e3>
  80215f:	c7 44 24 0c 9c 39 80 	movl   $0x80399c,0xc(%esp)
  802166:	00 
  802167:	c7 44 24 08 fb 38 80 	movl   $0x8038fb,0x8(%esp)
  80216e:	00 
  80216f:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  802176:	00 
  802177:	c7 04 24 41 39 80 00 	movl   $0x803941,(%esp)
  80217e:	e8 24 e4 ff ff       	call   8005a7 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  802183:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  802189:	89 c8                	mov    %ecx,%eax
  80218b:	2d 00 30 80 11       	sub    $0x11803000,%eax
  802190:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  802193:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  802199:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80219c:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  8021a2:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8021a8:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8021af:	00 
  8021b0:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  8021b7:	ee 
  8021b8:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8021be:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021c2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8021c9:	00 
  8021ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021d1:	e8 61 ef ff ff       	call   801137 <sys_page_map>
  8021d6:	89 c3                	mov    %eax,%ebx
  8021d8:	85 c0                	test   %eax,%eax
  8021da:	0f 88 76 03 00 00    	js     802556 <spawn+0x5b6>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8021e0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8021e7:	00 
  8021e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021ef:	e8 96 ef ff ff       	call   80118a <sys_page_unmap>
  8021f4:	89 c3                	mov    %eax,%ebx
  8021f6:	85 c0                	test   %eax,%eax
  8021f8:	0f 88 58 03 00 00    	js     802556 <spawn+0x5b6>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8021fe:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  802204:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  80220b:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802211:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  802218:	00 00 00 
  80221b:	e9 b6 01 00 00       	jmp    8023d6 <spawn+0x436>
		if (ph->p_type != ELF_PROG_LOAD)
  802220:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802226:	83 38 01             	cmpl   $0x1,(%eax)
  802229:	0f 85 99 01 00 00    	jne    8023c8 <spawn+0x428>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80222f:	89 c2                	mov    %eax,%edx
  802231:	8b 40 18             	mov    0x18(%eax),%eax
  802234:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  802237:	83 f8 01             	cmp    $0x1,%eax
  80223a:	19 c0                	sbb    %eax,%eax
  80223c:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  802242:	83 a5 90 fd ff ff fe 	andl   $0xfffffffe,-0x270(%ebp)
  802249:	83 85 90 fd ff ff 07 	addl   $0x7,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802250:	89 d0                	mov    %edx,%eax
  802252:	8b 52 04             	mov    0x4(%edx),%edx
  802255:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  80225b:	8b 50 10             	mov    0x10(%eax),%edx
  80225e:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)
  802264:	8b 48 14             	mov    0x14(%eax),%ecx
  802267:	89 8d 8c fd ff ff    	mov    %ecx,-0x274(%ebp)
  80226d:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802270:	89 f0                	mov    %esi,%eax
  802272:	25 ff 0f 00 00       	and    $0xfff,%eax
  802277:	74 14                	je     80228d <spawn+0x2ed>
		va -= i;
  802279:	29 c6                	sub    %eax,%esi
		memsz += i;
  80227b:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  802281:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  802287:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80228d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802292:	e9 23 01 00 00       	jmp    8023ba <spawn+0x41a>
		if (i >= filesz) {
  802297:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  80229d:	77 2b                	ja     8022ca <spawn+0x32a>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  80229f:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  8022a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022ad:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8022b3:	89 04 24             	mov    %eax,(%esp)
  8022b6:	e8 28 ee ff ff       	call   8010e3 <sys_page_alloc>
  8022bb:	85 c0                	test   %eax,%eax
  8022bd:	0f 89 eb 00 00 00    	jns    8023ae <spawn+0x40e>
  8022c3:	89 c3                	mov    %eax,%ebx
  8022c5:	e9 6c 02 00 00       	jmp    802536 <spawn+0x596>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8022ca:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8022d1:	00 
  8022d2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8022d9:	00 
  8022da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022e1:	e8 fd ed ff ff       	call   8010e3 <sys_page_alloc>
  8022e6:	85 c0                	test   %eax,%eax
  8022e8:	0f 88 3e 02 00 00    	js     80252c <spawn+0x58c>
  8022ee:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8022f4:	01 f8                	add    %edi,%eax
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8022f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022fa:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802300:	89 04 24             	mov    %eax,(%esp)
  802303:	e8 8c f8 ff ff       	call   801b94 <seek>
  802308:	85 c0                	test   %eax,%eax
  80230a:	0f 88 20 02 00 00    	js     802530 <spawn+0x590>
  802310:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  802316:	29 f9                	sub    %edi,%ecx
  802318:	89 c8                	mov    %ecx,%eax
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80231a:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
  802320:	b9 00 10 00 00       	mov    $0x1000,%ecx
  802325:	0f 47 c1             	cmova  %ecx,%eax
  802328:	89 44 24 08          	mov    %eax,0x8(%esp)
  80232c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802333:	00 
  802334:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80233a:	89 04 24             	mov    %eax,(%esp)
  80233d:	e8 7a f7 ff ff       	call   801abc <readn>
  802342:	85 c0                	test   %eax,%eax
  802344:	0f 88 ea 01 00 00    	js     802534 <spawn+0x594>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80234a:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802350:	89 44 24 10          	mov    %eax,0x10(%esp)
  802354:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802358:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  80235e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802362:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802369:	00 
  80236a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802371:	e8 c1 ed ff ff       	call   801137 <sys_page_map>
  802376:	85 c0                	test   %eax,%eax
  802378:	79 20                	jns    80239a <spawn+0x3fa>
				panic("spawn: sys_page_map data: %e", r);
  80237a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80237e:	c7 44 24 08 4d 39 80 	movl   $0x80394d,0x8(%esp)
  802385:	00 
  802386:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  80238d:	00 
  80238e:	c7 04 24 41 39 80 00 	movl   $0x803941,(%esp)
  802395:	e8 0d e2 ff ff       	call   8005a7 <_panic>
			sys_page_unmap(0, UTEMP);
  80239a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8023a1:	00 
  8023a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023a9:	e8 dc ed ff ff       	call   80118a <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8023ae:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8023b4:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8023ba:	89 df                	mov    %ebx,%edi
  8023bc:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  8023c2:	0f 87 cf fe ff ff    	ja     802297 <spawn+0x2f7>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8023c8:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8023cf:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8023d6:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8023dd:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8023e3:	0f 8c 37 fe ff ff    	jl     802220 <spawn+0x280>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8023e9:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8023ef:	89 04 24             	mov    %eax,(%esp)
  8023f2:	e8 d0 f4 ff ff       	call   8018c7 <close>
// Copy the mappings for shared pages into the child address space.
static int
copy_shared_pages(envid_t child)
{
	uintptr_t addr;
	int r = 0;
  8023f7:	be 00 00 00 00       	mov    $0x0,%esi

	for(addr = 0; addr < UTOP - PGSIZE; addr+=PGSIZE) {
  8023fc:	bb 00 00 00 00       	mov    $0x0,%ebx
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)]) {
  802401:	89 d8                	mov    %ebx,%eax
  802403:	c1 e8 16             	shr    $0x16,%eax
  802406:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80240d:	85 c0                	test   %eax,%eax
  80240f:	74 4e                	je     80245f <spawn+0x4bf>
  802411:	89 d8                	mov    %ebx,%eax
  802413:	c1 e8 0c             	shr    $0xc,%eax
  802416:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80241d:	85 d2                	test   %edx,%edx
  80241f:	74 3e                	je     80245f <spawn+0x4bf>
			if(uvpt[PGNUM(addr)] & PTE_SHARE) {
  802421:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802428:	f6 c6 04             	test   $0x4,%dh
  80242b:	74 32                	je     80245f <spawn+0x4bf>
				r += sys_page_map(sys_getenvid(), (void*)addr, child, (void*)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL);
  80242d:	8b 3c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edi
  802434:	e8 6c ec ff ff       	call   8010a5 <sys_getenvid>
  802439:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  80243f:	89 7c 24 10          	mov    %edi,0x10(%esp)
  802443:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802447:	8b 95 84 fd ff ff    	mov    -0x27c(%ebp),%edx
  80244d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802451:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802455:	89 04 24             	mov    %eax,(%esp)
  802458:	e8 da ec ff ff       	call   801137 <sys_page_map>
  80245d:	01 c6                	add    %eax,%esi
copy_shared_pages(envid_t child)
{
	uintptr_t addr;
	int r = 0;

	for(addr = 0; addr < UTOP - PGSIZE; addr+=PGSIZE) {
  80245f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802465:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80246b:	75 94                	jne    802401 <spawn+0x461>
			if(uvpt[PGNUM(addr)] & PTE_SHARE) {
				r += sys_page_map(sys_getenvid(), (void*)addr, child, (void*)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL);
			}
		}
	}
	if(r<0) {
  80246d:	85 f6                	test   %esi,%esi
  80246f:	79 1c                	jns    80248d <spawn+0x4ed>
		panic("Something went wrong in copy_shared_pages");
  802471:	c7 44 24 08 c4 39 80 	movl   $0x8039c4,0x8(%esp)
  802478:	00 
  802479:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
  802480:	00 
  802481:	c7 04 24 41 39 80 00 	movl   $0x803941,(%esp)
  802488:	e8 1a e1 ff ff       	call   8005a7 <_panic>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  80248d:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802494:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802497:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  80249d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024a1:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8024a7:	89 04 24             	mov    %eax,(%esp)
  8024aa:	e8 81 ed ff ff       	call   801230 <sys_env_set_trapframe>
  8024af:	85 c0                	test   %eax,%eax
  8024b1:	79 20                	jns    8024d3 <spawn+0x533>
		panic("sys_env_set_trapframe: %e", r);
  8024b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024b7:	c7 44 24 08 6a 39 80 	movl   $0x80396a,0x8(%esp)
  8024be:	00 
  8024bf:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  8024c6:	00 
  8024c7:	c7 04 24 41 39 80 00 	movl   $0x803941,(%esp)
  8024ce:	e8 d4 e0 ff ff       	call   8005a7 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8024d3:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8024da:	00 
  8024db:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8024e1:	89 04 24             	mov    %eax,(%esp)
  8024e4:	e8 f4 ec ff ff       	call   8011dd <sys_env_set_status>
  8024e9:	85 c0                	test   %eax,%eax
  8024eb:	79 30                	jns    80251d <spawn+0x57d>
		panic("sys_env_set_status: %e", r);
  8024ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024f1:	c7 44 24 08 84 39 80 	movl   $0x803984,0x8(%esp)
  8024f8:	00 
  8024f9:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  802500:	00 
  802501:	c7 04 24 41 39 80 00 	movl   $0x803941,(%esp)
  802508:	e8 9a e0 ff ff       	call   8005a7 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  80250d:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802513:	eb 57                	jmp    80256c <spawn+0x5cc>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802515:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80251b:	eb 4f                	jmp    80256c <spawn+0x5cc>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  80251d:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802523:	eb 47                	jmp    80256c <spawn+0x5cc>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802525:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  80252a:	eb 40                	jmp    80256c <spawn+0x5cc>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80252c:	89 c3                	mov    %eax,%ebx
  80252e:	eb 06                	jmp    802536 <spawn+0x596>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802530:	89 c3                	mov    %eax,%ebx
  802532:	eb 02                	jmp    802536 <spawn+0x596>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802534:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802536:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80253c:	89 04 24             	mov    %eax,(%esp)
  80253f:	e8 0f eb ff ff       	call   801053 <sys_env_destroy>
	close(fd);
  802544:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80254a:	89 04 24             	mov    %eax,(%esp)
  80254d:	e8 75 f3 ff ff       	call   8018c7 <close>
	return r;
  802552:	89 d8                	mov    %ebx,%eax
  802554:	eb 16                	jmp    80256c <spawn+0x5cc>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802556:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80255d:	00 
  80255e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802565:	e8 20 ec ff ff       	call   80118a <sys_page_unmap>
  80256a:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  80256c:	81 c4 9c 02 00 00    	add    $0x29c,%esp
  802572:	5b                   	pop    %ebx
  802573:	5e                   	pop    %esi
  802574:	5f                   	pop    %edi
  802575:	5d                   	pop    %ebp
  802576:	c3                   	ret    

00802577 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802577:	55                   	push   %ebp
  802578:	89 e5                	mov    %esp,%ebp
  80257a:	56                   	push   %esi
  80257b:	53                   	push   %ebx
  80257c:	83 ec 10             	sub    $0x10,%esp
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80257f:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802582:	ba 00 00 00 00       	mov    $0x0,%edx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802587:	eb 03                	jmp    80258c <spawnl+0x15>
		argc++;
  802589:	83 c2 01             	add    $0x1,%edx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80258c:	83 c0 04             	add    $0x4,%eax
  80258f:	83 78 fc 00          	cmpl   $0x0,-0x4(%eax)
  802593:	75 f4                	jne    802589 <spawnl+0x12>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802595:	8d 04 95 1a 00 00 00 	lea    0x1a(,%edx,4),%eax
  80259c:	83 e0 f0             	and    $0xfffffff0,%eax
  80259f:	29 c4                	sub    %eax,%esp
  8025a1:	8d 44 24 0b          	lea    0xb(%esp),%eax
  8025a5:	c1 e8 02             	shr    $0x2,%eax
  8025a8:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
  8025af:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  8025b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025b4:	89 0c 85 00 00 00 00 	mov    %ecx,0x0(,%eax,4)
	argv[argc+1] = NULL;
  8025bb:	c7 44 96 04 00 00 00 	movl   $0x0,0x4(%esi,%edx,4)
  8025c2:	00 

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8025c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8025c8:	eb 0a                	jmp    8025d4 <spawnl+0x5d>
		argv[i+1] = va_arg(vl, const char *);
  8025ca:	83 c0 01             	add    $0x1,%eax
  8025cd:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  8025d1:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8025d4:	39 d0                	cmp    %edx,%eax
  8025d6:	75 f2                	jne    8025ca <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  8025d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8025df:	89 04 24             	mov    %eax,(%esp)
  8025e2:	e8 b9 f9 ff ff       	call   801fa0 <spawn>
}
  8025e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025ea:	5b                   	pop    %ebx
  8025eb:	5e                   	pop    %esi
  8025ec:	5d                   	pop    %ebp
  8025ed:	c3                   	ret    
  8025ee:	66 90                	xchg   %ax,%ax

008025f0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8025f0:	55                   	push   %ebp
  8025f1:	89 e5                	mov    %esp,%ebp
  8025f3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  8025f6:	c7 44 24 04 ee 39 80 	movl   $0x8039ee,0x4(%esp)
  8025fd:	00 
  8025fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  802601:	89 04 24             	mov    %eax,(%esp)
  802604:	e8 be e6 ff ff       	call   800cc7 <strcpy>
	return 0;
}
  802609:	b8 00 00 00 00       	mov    $0x0,%eax
  80260e:	c9                   	leave  
  80260f:	c3                   	ret    

00802610 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802610:	55                   	push   %ebp
  802611:	89 e5                	mov    %esp,%ebp
  802613:	53                   	push   %ebx
  802614:	83 ec 14             	sub    $0x14,%esp
  802617:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80261a:	89 1c 24             	mov    %ebx,(%esp)
  80261d:	e8 4b 0a 00 00       	call   80306d <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  802622:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  802627:	83 f8 01             	cmp    $0x1,%eax
  80262a:	75 0d                	jne    802639 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80262c:	8b 43 0c             	mov    0xc(%ebx),%eax
  80262f:	89 04 24             	mov    %eax,(%esp)
  802632:	e8 29 03 00 00       	call   802960 <nsipc_close>
  802637:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  802639:	89 d0                	mov    %edx,%eax
  80263b:	83 c4 14             	add    $0x14,%esp
  80263e:	5b                   	pop    %ebx
  80263f:	5d                   	pop    %ebp
  802640:	c3                   	ret    

00802641 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802641:	55                   	push   %ebp
  802642:	89 e5                	mov    %esp,%ebp
  802644:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802647:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80264e:	00 
  80264f:	8b 45 10             	mov    0x10(%ebp),%eax
  802652:	89 44 24 08          	mov    %eax,0x8(%esp)
  802656:	8b 45 0c             	mov    0xc(%ebp),%eax
  802659:	89 44 24 04          	mov    %eax,0x4(%esp)
  80265d:	8b 45 08             	mov    0x8(%ebp),%eax
  802660:	8b 40 0c             	mov    0xc(%eax),%eax
  802663:	89 04 24             	mov    %eax,(%esp)
  802666:	e8 f0 03 00 00       	call   802a5b <nsipc_send>
}
  80266b:	c9                   	leave  
  80266c:	c3                   	ret    

0080266d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80266d:	55                   	push   %ebp
  80266e:	89 e5                	mov    %esp,%ebp
  802670:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802673:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80267a:	00 
  80267b:	8b 45 10             	mov    0x10(%ebp),%eax
  80267e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802682:	8b 45 0c             	mov    0xc(%ebp),%eax
  802685:	89 44 24 04          	mov    %eax,0x4(%esp)
  802689:	8b 45 08             	mov    0x8(%ebp),%eax
  80268c:	8b 40 0c             	mov    0xc(%eax),%eax
  80268f:	89 04 24             	mov    %eax,(%esp)
  802692:	e8 44 03 00 00       	call   8029db <nsipc_recv>
}
  802697:	c9                   	leave  
  802698:	c3                   	ret    

00802699 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802699:	55                   	push   %ebp
  80269a:	89 e5                	mov    %esp,%ebp
  80269c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80269f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8026a2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8026a6:	89 04 24             	mov    %eax,(%esp)
  8026a9:	e8 e8 f0 ff ff       	call   801796 <fd_lookup>
  8026ae:	85 c0                	test   %eax,%eax
  8026b0:	78 17                	js     8026c9 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8026b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026b5:	8b 0d 3c 40 80 00    	mov    0x80403c,%ecx
  8026bb:	39 08                	cmp    %ecx,(%eax)
  8026bd:	75 05                	jne    8026c4 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8026bf:	8b 40 0c             	mov    0xc(%eax),%eax
  8026c2:	eb 05                	jmp    8026c9 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8026c4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8026c9:	c9                   	leave  
  8026ca:	c3                   	ret    

008026cb <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8026cb:	55                   	push   %ebp
  8026cc:	89 e5                	mov    %esp,%ebp
  8026ce:	56                   	push   %esi
  8026cf:	53                   	push   %ebx
  8026d0:	83 ec 20             	sub    $0x20,%esp
  8026d3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8026d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026d8:	89 04 24             	mov    %eax,(%esp)
  8026db:	e8 67 f0 ff ff       	call   801747 <fd_alloc>
  8026e0:	89 c3                	mov    %eax,%ebx
  8026e2:	85 c0                	test   %eax,%eax
  8026e4:	78 21                	js     802707 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8026e6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8026ed:	00 
  8026ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026fc:	e8 e2 e9 ff ff       	call   8010e3 <sys_page_alloc>
  802701:	89 c3                	mov    %eax,%ebx
  802703:	85 c0                	test   %eax,%eax
  802705:	79 0c                	jns    802713 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  802707:	89 34 24             	mov    %esi,(%esp)
  80270a:	e8 51 02 00 00       	call   802960 <nsipc_close>
		return r;
  80270f:	89 d8                	mov    %ebx,%eax
  802711:	eb 20                	jmp    802733 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802713:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802719:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80271c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80271e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802721:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  802728:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  80272b:	89 14 24             	mov    %edx,(%esp)
  80272e:	e8 ed ef ff ff       	call   801720 <fd2num>
}
  802733:	83 c4 20             	add    $0x20,%esp
  802736:	5b                   	pop    %ebx
  802737:	5e                   	pop    %esi
  802738:	5d                   	pop    %ebp
  802739:	c3                   	ret    

0080273a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80273a:	55                   	push   %ebp
  80273b:	89 e5                	mov    %esp,%ebp
  80273d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802740:	8b 45 08             	mov    0x8(%ebp),%eax
  802743:	e8 51 ff ff ff       	call   802699 <fd2sockid>
		return r;
  802748:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80274a:	85 c0                	test   %eax,%eax
  80274c:	78 23                	js     802771 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80274e:	8b 55 10             	mov    0x10(%ebp),%edx
  802751:	89 54 24 08          	mov    %edx,0x8(%esp)
  802755:	8b 55 0c             	mov    0xc(%ebp),%edx
  802758:	89 54 24 04          	mov    %edx,0x4(%esp)
  80275c:	89 04 24             	mov    %eax,(%esp)
  80275f:	e8 45 01 00 00       	call   8028a9 <nsipc_accept>
		return r;
  802764:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802766:	85 c0                	test   %eax,%eax
  802768:	78 07                	js     802771 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  80276a:	e8 5c ff ff ff       	call   8026cb <alloc_sockfd>
  80276f:	89 c1                	mov    %eax,%ecx
}
  802771:	89 c8                	mov    %ecx,%eax
  802773:	c9                   	leave  
  802774:	c3                   	ret    

00802775 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802775:	55                   	push   %ebp
  802776:	89 e5                	mov    %esp,%ebp
  802778:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80277b:	8b 45 08             	mov    0x8(%ebp),%eax
  80277e:	e8 16 ff ff ff       	call   802699 <fd2sockid>
  802783:	89 c2                	mov    %eax,%edx
  802785:	85 d2                	test   %edx,%edx
  802787:	78 16                	js     80279f <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  802789:	8b 45 10             	mov    0x10(%ebp),%eax
  80278c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802790:	8b 45 0c             	mov    0xc(%ebp),%eax
  802793:	89 44 24 04          	mov    %eax,0x4(%esp)
  802797:	89 14 24             	mov    %edx,(%esp)
  80279a:	e8 60 01 00 00       	call   8028ff <nsipc_bind>
}
  80279f:	c9                   	leave  
  8027a0:	c3                   	ret    

008027a1 <shutdown>:

int
shutdown(int s, int how)
{
  8027a1:	55                   	push   %ebp
  8027a2:	89 e5                	mov    %esp,%ebp
  8027a4:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8027a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8027aa:	e8 ea fe ff ff       	call   802699 <fd2sockid>
  8027af:	89 c2                	mov    %eax,%edx
  8027b1:	85 d2                	test   %edx,%edx
  8027b3:	78 0f                	js     8027c4 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  8027b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027bc:	89 14 24             	mov    %edx,(%esp)
  8027bf:	e8 7a 01 00 00       	call   80293e <nsipc_shutdown>
}
  8027c4:	c9                   	leave  
  8027c5:	c3                   	ret    

008027c6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8027c6:	55                   	push   %ebp
  8027c7:	89 e5                	mov    %esp,%ebp
  8027c9:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8027cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8027cf:	e8 c5 fe ff ff       	call   802699 <fd2sockid>
  8027d4:	89 c2                	mov    %eax,%edx
  8027d6:	85 d2                	test   %edx,%edx
  8027d8:	78 16                	js     8027f0 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  8027da:	8b 45 10             	mov    0x10(%ebp),%eax
  8027dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8027e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027e8:	89 14 24             	mov    %edx,(%esp)
  8027eb:	e8 8a 01 00 00       	call   80297a <nsipc_connect>
}
  8027f0:	c9                   	leave  
  8027f1:	c3                   	ret    

008027f2 <listen>:

int
listen(int s, int backlog)
{
  8027f2:	55                   	push   %ebp
  8027f3:	89 e5                	mov    %esp,%ebp
  8027f5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8027f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8027fb:	e8 99 fe ff ff       	call   802699 <fd2sockid>
  802800:	89 c2                	mov    %eax,%edx
  802802:	85 d2                	test   %edx,%edx
  802804:	78 0f                	js     802815 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  802806:	8b 45 0c             	mov    0xc(%ebp),%eax
  802809:	89 44 24 04          	mov    %eax,0x4(%esp)
  80280d:	89 14 24             	mov    %edx,(%esp)
  802810:	e8 a4 01 00 00       	call   8029b9 <nsipc_listen>
}
  802815:	c9                   	leave  
  802816:	c3                   	ret    

00802817 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802817:	55                   	push   %ebp
  802818:	89 e5                	mov    %esp,%ebp
  80281a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80281d:	8b 45 10             	mov    0x10(%ebp),%eax
  802820:	89 44 24 08          	mov    %eax,0x8(%esp)
  802824:	8b 45 0c             	mov    0xc(%ebp),%eax
  802827:	89 44 24 04          	mov    %eax,0x4(%esp)
  80282b:	8b 45 08             	mov    0x8(%ebp),%eax
  80282e:	89 04 24             	mov    %eax,(%esp)
  802831:	e8 98 02 00 00       	call   802ace <nsipc_socket>
  802836:	89 c2                	mov    %eax,%edx
  802838:	85 d2                	test   %edx,%edx
  80283a:	78 05                	js     802841 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  80283c:	e8 8a fe ff ff       	call   8026cb <alloc_sockfd>
}
  802841:	c9                   	leave  
  802842:	c3                   	ret    

00802843 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802843:	55                   	push   %ebp
  802844:	89 e5                	mov    %esp,%ebp
  802846:	53                   	push   %ebx
  802847:	83 ec 14             	sub    $0x14,%esp
  80284a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80284c:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802853:	75 11                	jne    802866 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802855:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80285c:	e8 d4 07 00 00       	call   803035 <ipc_find_env>
  802861:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802866:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80286d:	00 
  80286e:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802875:	00 
  802876:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80287a:	a1 04 50 80 00       	mov    0x805004,%eax
  80287f:	89 04 24             	mov    %eax,(%esp)
  802882:	e8 43 07 00 00       	call   802fca <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802887:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80288e:	00 
  80288f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802896:	00 
  802897:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80289e:	e8 ad 06 00 00       	call   802f50 <ipc_recv>
}
  8028a3:	83 c4 14             	add    $0x14,%esp
  8028a6:	5b                   	pop    %ebx
  8028a7:	5d                   	pop    %ebp
  8028a8:	c3                   	ret    

008028a9 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8028a9:	55                   	push   %ebp
  8028aa:	89 e5                	mov    %esp,%ebp
  8028ac:	56                   	push   %esi
  8028ad:	53                   	push   %ebx
  8028ae:	83 ec 10             	sub    $0x10,%esp
  8028b1:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8028b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8028b7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8028bc:	8b 06                	mov    (%esi),%eax
  8028be:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8028c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8028c8:	e8 76 ff ff ff       	call   802843 <nsipc>
  8028cd:	89 c3                	mov    %eax,%ebx
  8028cf:	85 c0                	test   %eax,%eax
  8028d1:	78 23                	js     8028f6 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8028d3:	a1 10 70 80 00       	mov    0x807010,%eax
  8028d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8028dc:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8028e3:	00 
  8028e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028e7:	89 04 24             	mov    %eax,(%esp)
  8028ea:	e8 75 e5 ff ff       	call   800e64 <memmove>
		*addrlen = ret->ret_addrlen;
  8028ef:	a1 10 70 80 00       	mov    0x807010,%eax
  8028f4:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  8028f6:	89 d8                	mov    %ebx,%eax
  8028f8:	83 c4 10             	add    $0x10,%esp
  8028fb:	5b                   	pop    %ebx
  8028fc:	5e                   	pop    %esi
  8028fd:	5d                   	pop    %ebp
  8028fe:	c3                   	ret    

008028ff <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8028ff:	55                   	push   %ebp
  802900:	89 e5                	mov    %esp,%ebp
  802902:	53                   	push   %ebx
  802903:	83 ec 14             	sub    $0x14,%esp
  802906:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802909:	8b 45 08             	mov    0x8(%ebp),%eax
  80290c:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802911:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802915:	8b 45 0c             	mov    0xc(%ebp),%eax
  802918:	89 44 24 04          	mov    %eax,0x4(%esp)
  80291c:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802923:	e8 3c e5 ff ff       	call   800e64 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802928:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80292e:	b8 02 00 00 00       	mov    $0x2,%eax
  802933:	e8 0b ff ff ff       	call   802843 <nsipc>
}
  802938:	83 c4 14             	add    $0x14,%esp
  80293b:	5b                   	pop    %ebx
  80293c:	5d                   	pop    %ebp
  80293d:	c3                   	ret    

0080293e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80293e:	55                   	push   %ebp
  80293f:	89 e5                	mov    %esp,%ebp
  802941:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802944:	8b 45 08             	mov    0x8(%ebp),%eax
  802947:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80294c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80294f:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802954:	b8 03 00 00 00       	mov    $0x3,%eax
  802959:	e8 e5 fe ff ff       	call   802843 <nsipc>
}
  80295e:	c9                   	leave  
  80295f:	c3                   	ret    

00802960 <nsipc_close>:

int
nsipc_close(int s)
{
  802960:	55                   	push   %ebp
  802961:	89 e5                	mov    %esp,%ebp
  802963:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802966:	8b 45 08             	mov    0x8(%ebp),%eax
  802969:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  80296e:	b8 04 00 00 00       	mov    $0x4,%eax
  802973:	e8 cb fe ff ff       	call   802843 <nsipc>
}
  802978:	c9                   	leave  
  802979:	c3                   	ret    

0080297a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80297a:	55                   	push   %ebp
  80297b:	89 e5                	mov    %esp,%ebp
  80297d:	53                   	push   %ebx
  80297e:	83 ec 14             	sub    $0x14,%esp
  802981:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802984:	8b 45 08             	mov    0x8(%ebp),%eax
  802987:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80298c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802990:	8b 45 0c             	mov    0xc(%ebp),%eax
  802993:	89 44 24 04          	mov    %eax,0x4(%esp)
  802997:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  80299e:	e8 c1 e4 ff ff       	call   800e64 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8029a3:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8029a9:	b8 05 00 00 00       	mov    $0x5,%eax
  8029ae:	e8 90 fe ff ff       	call   802843 <nsipc>
}
  8029b3:	83 c4 14             	add    $0x14,%esp
  8029b6:	5b                   	pop    %ebx
  8029b7:	5d                   	pop    %ebp
  8029b8:	c3                   	ret    

008029b9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8029b9:	55                   	push   %ebp
  8029ba:	89 e5                	mov    %esp,%ebp
  8029bc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8029bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8029c2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8029c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029ca:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8029cf:	b8 06 00 00 00       	mov    $0x6,%eax
  8029d4:	e8 6a fe ff ff       	call   802843 <nsipc>
}
  8029d9:	c9                   	leave  
  8029da:	c3                   	ret    

008029db <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8029db:	55                   	push   %ebp
  8029dc:	89 e5                	mov    %esp,%ebp
  8029de:	56                   	push   %esi
  8029df:	53                   	push   %ebx
  8029e0:	83 ec 10             	sub    $0x10,%esp
  8029e3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8029e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8029e9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8029ee:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8029f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8029f7:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8029fc:	b8 07 00 00 00       	mov    $0x7,%eax
  802a01:	e8 3d fe ff ff       	call   802843 <nsipc>
  802a06:	89 c3                	mov    %eax,%ebx
  802a08:	85 c0                	test   %eax,%eax
  802a0a:	78 46                	js     802a52 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802a0c:	39 f0                	cmp    %esi,%eax
  802a0e:	7f 07                	jg     802a17 <nsipc_recv+0x3c>
  802a10:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802a15:	7e 24                	jle    802a3b <nsipc_recv+0x60>
  802a17:	c7 44 24 0c fa 39 80 	movl   $0x8039fa,0xc(%esp)
  802a1e:	00 
  802a1f:	c7 44 24 08 fb 38 80 	movl   $0x8038fb,0x8(%esp)
  802a26:	00 
  802a27:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  802a2e:	00 
  802a2f:	c7 04 24 0f 3a 80 00 	movl   $0x803a0f,(%esp)
  802a36:	e8 6c db ff ff       	call   8005a7 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802a3b:	89 44 24 08          	mov    %eax,0x8(%esp)
  802a3f:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802a46:	00 
  802a47:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a4a:	89 04 24             	mov    %eax,(%esp)
  802a4d:	e8 12 e4 ff ff       	call   800e64 <memmove>
	}

	return r;
}
  802a52:	89 d8                	mov    %ebx,%eax
  802a54:	83 c4 10             	add    $0x10,%esp
  802a57:	5b                   	pop    %ebx
  802a58:	5e                   	pop    %esi
  802a59:	5d                   	pop    %ebp
  802a5a:	c3                   	ret    

00802a5b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802a5b:	55                   	push   %ebp
  802a5c:	89 e5                	mov    %esp,%ebp
  802a5e:	53                   	push   %ebx
  802a5f:	83 ec 14             	sub    $0x14,%esp
  802a62:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802a65:	8b 45 08             	mov    0x8(%ebp),%eax
  802a68:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802a6d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802a73:	7e 24                	jle    802a99 <nsipc_send+0x3e>
  802a75:	c7 44 24 0c 1b 3a 80 	movl   $0x803a1b,0xc(%esp)
  802a7c:	00 
  802a7d:	c7 44 24 08 fb 38 80 	movl   $0x8038fb,0x8(%esp)
  802a84:	00 
  802a85:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  802a8c:	00 
  802a8d:	c7 04 24 0f 3a 80 00 	movl   $0x803a0f,(%esp)
  802a94:	e8 0e db ff ff       	call   8005a7 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802a99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802a9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802aa0:	89 44 24 04          	mov    %eax,0x4(%esp)
  802aa4:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  802aab:	e8 b4 e3 ff ff       	call   800e64 <memmove>
	nsipcbuf.send.req_size = size;
  802ab0:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802ab6:	8b 45 14             	mov    0x14(%ebp),%eax
  802ab9:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802abe:	b8 08 00 00 00       	mov    $0x8,%eax
  802ac3:	e8 7b fd ff ff       	call   802843 <nsipc>
}
  802ac8:	83 c4 14             	add    $0x14,%esp
  802acb:	5b                   	pop    %ebx
  802acc:	5d                   	pop    %ebp
  802acd:	c3                   	ret    

00802ace <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802ace:	55                   	push   %ebp
  802acf:	89 e5                	mov    %esp,%ebp
  802ad1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  802ad7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802adc:	8b 45 0c             	mov    0xc(%ebp),%eax
  802adf:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802ae4:	8b 45 10             	mov    0x10(%ebp),%eax
  802ae7:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802aec:	b8 09 00 00 00       	mov    $0x9,%eax
  802af1:	e8 4d fd ff ff       	call   802843 <nsipc>
}
  802af6:	c9                   	leave  
  802af7:	c3                   	ret    

00802af8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802af8:	55                   	push   %ebp
  802af9:	89 e5                	mov    %esp,%ebp
  802afb:	56                   	push   %esi
  802afc:	53                   	push   %ebx
  802afd:	83 ec 10             	sub    $0x10,%esp
  802b00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802b03:	8b 45 08             	mov    0x8(%ebp),%eax
  802b06:	89 04 24             	mov    %eax,(%esp)
  802b09:	e8 22 ec ff ff       	call   801730 <fd2data>
  802b0e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802b10:	c7 44 24 04 27 3a 80 	movl   $0x803a27,0x4(%esp)
  802b17:	00 
  802b18:	89 1c 24             	mov    %ebx,(%esp)
  802b1b:	e8 a7 e1 ff ff       	call   800cc7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802b20:	8b 46 04             	mov    0x4(%esi),%eax
  802b23:	2b 06                	sub    (%esi),%eax
  802b25:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802b2b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802b32:	00 00 00 
	stat->st_dev = &devpipe;
  802b35:	c7 83 88 00 00 00 58 	movl   $0x804058,0x88(%ebx)
  802b3c:	40 80 00 
	return 0;
}
  802b3f:	b8 00 00 00 00       	mov    $0x0,%eax
  802b44:	83 c4 10             	add    $0x10,%esp
  802b47:	5b                   	pop    %ebx
  802b48:	5e                   	pop    %esi
  802b49:	5d                   	pop    %ebp
  802b4a:	c3                   	ret    

00802b4b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802b4b:	55                   	push   %ebp
  802b4c:	89 e5                	mov    %esp,%ebp
  802b4e:	53                   	push   %ebx
  802b4f:	83 ec 14             	sub    $0x14,%esp
  802b52:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802b55:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802b59:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b60:	e8 25 e6 ff ff       	call   80118a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802b65:	89 1c 24             	mov    %ebx,(%esp)
  802b68:	e8 c3 eb ff ff       	call   801730 <fd2data>
  802b6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b71:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b78:	e8 0d e6 ff ff       	call   80118a <sys_page_unmap>
}
  802b7d:	83 c4 14             	add    $0x14,%esp
  802b80:	5b                   	pop    %ebx
  802b81:	5d                   	pop    %ebp
  802b82:	c3                   	ret    

00802b83 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802b83:	55                   	push   %ebp
  802b84:	89 e5                	mov    %esp,%ebp
  802b86:	57                   	push   %edi
  802b87:	56                   	push   %esi
  802b88:	53                   	push   %ebx
  802b89:	83 ec 2c             	sub    $0x2c,%esp
  802b8c:	89 c6                	mov    %eax,%esi
  802b8e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802b91:	a1 08 50 80 00       	mov    0x805008,%eax
  802b96:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802b99:	89 34 24             	mov    %esi,(%esp)
  802b9c:	e8 cc 04 00 00       	call   80306d <pageref>
  802ba1:	89 c7                	mov    %eax,%edi
  802ba3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802ba6:	89 04 24             	mov    %eax,(%esp)
  802ba9:	e8 bf 04 00 00       	call   80306d <pageref>
  802bae:	39 c7                	cmp    %eax,%edi
  802bb0:	0f 94 c2             	sete   %dl
  802bb3:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  802bb6:	8b 0d 08 50 80 00    	mov    0x805008,%ecx
  802bbc:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  802bbf:	39 fb                	cmp    %edi,%ebx
  802bc1:	74 21                	je     802be4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802bc3:	84 d2                	test   %dl,%dl
  802bc5:	74 ca                	je     802b91 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802bc7:	8b 51 58             	mov    0x58(%ecx),%edx
  802bca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802bce:	89 54 24 08          	mov    %edx,0x8(%esp)
  802bd2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802bd6:	c7 04 24 2e 3a 80 00 	movl   $0x803a2e,(%esp)
  802bdd:	e8 be da ff ff       	call   8006a0 <cprintf>
  802be2:	eb ad                	jmp    802b91 <_pipeisclosed+0xe>
	}
}
  802be4:	83 c4 2c             	add    $0x2c,%esp
  802be7:	5b                   	pop    %ebx
  802be8:	5e                   	pop    %esi
  802be9:	5f                   	pop    %edi
  802bea:	5d                   	pop    %ebp
  802beb:	c3                   	ret    

00802bec <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802bec:	55                   	push   %ebp
  802bed:	89 e5                	mov    %esp,%ebp
  802bef:	57                   	push   %edi
  802bf0:	56                   	push   %esi
  802bf1:	53                   	push   %ebx
  802bf2:	83 ec 1c             	sub    $0x1c,%esp
  802bf5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802bf8:	89 34 24             	mov    %esi,(%esp)
  802bfb:	e8 30 eb ff ff       	call   801730 <fd2data>
  802c00:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c02:	bf 00 00 00 00       	mov    $0x0,%edi
  802c07:	eb 45                	jmp    802c4e <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802c09:	89 da                	mov    %ebx,%edx
  802c0b:	89 f0                	mov    %esi,%eax
  802c0d:	e8 71 ff ff ff       	call   802b83 <_pipeisclosed>
  802c12:	85 c0                	test   %eax,%eax
  802c14:	75 41                	jne    802c57 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802c16:	e8 a9 e4 ff ff       	call   8010c4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802c1b:	8b 43 04             	mov    0x4(%ebx),%eax
  802c1e:	8b 0b                	mov    (%ebx),%ecx
  802c20:	8d 51 20             	lea    0x20(%ecx),%edx
  802c23:	39 d0                	cmp    %edx,%eax
  802c25:	73 e2                	jae    802c09 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802c27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c2a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802c2e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802c31:	99                   	cltd   
  802c32:	c1 ea 1b             	shr    $0x1b,%edx
  802c35:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802c38:	83 e1 1f             	and    $0x1f,%ecx
  802c3b:	29 d1                	sub    %edx,%ecx
  802c3d:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  802c41:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  802c45:	83 c0 01             	add    $0x1,%eax
  802c48:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c4b:	83 c7 01             	add    $0x1,%edi
  802c4e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802c51:	75 c8                	jne    802c1b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802c53:	89 f8                	mov    %edi,%eax
  802c55:	eb 05                	jmp    802c5c <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802c57:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802c5c:	83 c4 1c             	add    $0x1c,%esp
  802c5f:	5b                   	pop    %ebx
  802c60:	5e                   	pop    %esi
  802c61:	5f                   	pop    %edi
  802c62:	5d                   	pop    %ebp
  802c63:	c3                   	ret    

00802c64 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802c64:	55                   	push   %ebp
  802c65:	89 e5                	mov    %esp,%ebp
  802c67:	57                   	push   %edi
  802c68:	56                   	push   %esi
  802c69:	53                   	push   %ebx
  802c6a:	83 ec 1c             	sub    $0x1c,%esp
  802c6d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802c70:	89 3c 24             	mov    %edi,(%esp)
  802c73:	e8 b8 ea ff ff       	call   801730 <fd2data>
  802c78:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c7a:	be 00 00 00 00       	mov    $0x0,%esi
  802c7f:	eb 3d                	jmp    802cbe <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802c81:	85 f6                	test   %esi,%esi
  802c83:	74 04                	je     802c89 <devpipe_read+0x25>
				return i;
  802c85:	89 f0                	mov    %esi,%eax
  802c87:	eb 43                	jmp    802ccc <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802c89:	89 da                	mov    %ebx,%edx
  802c8b:	89 f8                	mov    %edi,%eax
  802c8d:	e8 f1 fe ff ff       	call   802b83 <_pipeisclosed>
  802c92:	85 c0                	test   %eax,%eax
  802c94:	75 31                	jne    802cc7 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802c96:	e8 29 e4 ff ff       	call   8010c4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802c9b:	8b 03                	mov    (%ebx),%eax
  802c9d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802ca0:	74 df                	je     802c81 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802ca2:	99                   	cltd   
  802ca3:	c1 ea 1b             	shr    $0x1b,%edx
  802ca6:	01 d0                	add    %edx,%eax
  802ca8:	83 e0 1f             	and    $0x1f,%eax
  802cab:	29 d0                	sub    %edx,%eax
  802cad:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802cb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802cb5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802cb8:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802cbb:	83 c6 01             	add    $0x1,%esi
  802cbe:	3b 75 10             	cmp    0x10(%ebp),%esi
  802cc1:	75 d8                	jne    802c9b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802cc3:	89 f0                	mov    %esi,%eax
  802cc5:	eb 05                	jmp    802ccc <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802cc7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802ccc:	83 c4 1c             	add    $0x1c,%esp
  802ccf:	5b                   	pop    %ebx
  802cd0:	5e                   	pop    %esi
  802cd1:	5f                   	pop    %edi
  802cd2:	5d                   	pop    %ebp
  802cd3:	c3                   	ret    

00802cd4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802cd4:	55                   	push   %ebp
  802cd5:	89 e5                	mov    %esp,%ebp
  802cd7:	56                   	push   %esi
  802cd8:	53                   	push   %ebx
  802cd9:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802cdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802cdf:	89 04 24             	mov    %eax,(%esp)
  802ce2:	e8 60 ea ff ff       	call   801747 <fd_alloc>
  802ce7:	89 c2                	mov    %eax,%edx
  802ce9:	85 d2                	test   %edx,%edx
  802ceb:	0f 88 4d 01 00 00    	js     802e3e <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802cf1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802cf8:	00 
  802cf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cfc:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d00:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802d07:	e8 d7 e3 ff ff       	call   8010e3 <sys_page_alloc>
  802d0c:	89 c2                	mov    %eax,%edx
  802d0e:	85 d2                	test   %edx,%edx
  802d10:	0f 88 28 01 00 00    	js     802e3e <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802d16:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d19:	89 04 24             	mov    %eax,(%esp)
  802d1c:	e8 26 ea ff ff       	call   801747 <fd_alloc>
  802d21:	89 c3                	mov    %eax,%ebx
  802d23:	85 c0                	test   %eax,%eax
  802d25:	0f 88 fe 00 00 00    	js     802e29 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d2b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802d32:	00 
  802d33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d36:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d3a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802d41:	e8 9d e3 ff ff       	call   8010e3 <sys_page_alloc>
  802d46:	89 c3                	mov    %eax,%ebx
  802d48:	85 c0                	test   %eax,%eax
  802d4a:	0f 88 d9 00 00 00    	js     802e29 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d53:	89 04 24             	mov    %eax,(%esp)
  802d56:	e8 d5 e9 ff ff       	call   801730 <fd2data>
  802d5b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d5d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802d64:	00 
  802d65:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d69:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802d70:	e8 6e e3 ff ff       	call   8010e3 <sys_page_alloc>
  802d75:	89 c3                	mov    %eax,%ebx
  802d77:	85 c0                	test   %eax,%eax
  802d79:	0f 88 97 00 00 00    	js     802e16 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d82:	89 04 24             	mov    %eax,(%esp)
  802d85:	e8 a6 e9 ff ff       	call   801730 <fd2data>
  802d8a:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802d91:	00 
  802d92:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802d96:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802d9d:	00 
  802d9e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802da2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802da9:	e8 89 e3 ff ff       	call   801137 <sys_page_map>
  802dae:	89 c3                	mov    %eax,%ebx
  802db0:	85 c0                	test   %eax,%eax
  802db2:	78 52                	js     802e06 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802db4:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802dbd:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802dbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802dc2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802dc9:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802dcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802dd2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802dd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802dd7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802de1:	89 04 24             	mov    %eax,(%esp)
  802de4:	e8 37 e9 ff ff       	call   801720 <fd2num>
  802de9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802dec:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802dee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802df1:	89 04 24             	mov    %eax,(%esp)
  802df4:	e8 27 e9 ff ff       	call   801720 <fd2num>
  802df9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802dfc:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802dff:	b8 00 00 00 00       	mov    $0x0,%eax
  802e04:	eb 38                	jmp    802e3e <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  802e06:	89 74 24 04          	mov    %esi,0x4(%esp)
  802e0a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802e11:	e8 74 e3 ff ff       	call   80118a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802e16:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e19:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802e24:	e8 61 e3 ff ff       	call   80118a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e30:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802e37:	e8 4e e3 ff ff       	call   80118a <sys_page_unmap>
  802e3c:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  802e3e:	83 c4 30             	add    $0x30,%esp
  802e41:	5b                   	pop    %ebx
  802e42:	5e                   	pop    %esi
  802e43:	5d                   	pop    %ebp
  802e44:	c3                   	ret    

00802e45 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802e45:	55                   	push   %ebp
  802e46:	89 e5                	mov    %esp,%ebp
  802e48:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802e4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e52:	8b 45 08             	mov    0x8(%ebp),%eax
  802e55:	89 04 24             	mov    %eax,(%esp)
  802e58:	e8 39 e9 ff ff       	call   801796 <fd_lookup>
  802e5d:	89 c2                	mov    %eax,%edx
  802e5f:	85 d2                	test   %edx,%edx
  802e61:	78 15                	js     802e78 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e66:	89 04 24             	mov    %eax,(%esp)
  802e69:	e8 c2 e8 ff ff       	call   801730 <fd2data>
	return _pipeisclosed(fd, p);
  802e6e:	89 c2                	mov    %eax,%edx
  802e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e73:	e8 0b fd ff ff       	call   802b83 <_pipeisclosed>
}
  802e78:	c9                   	leave  
  802e79:	c3                   	ret    

00802e7a <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802e7a:	55                   	push   %ebp
  802e7b:	89 e5                	mov    %esp,%ebp
  802e7d:	56                   	push   %esi
  802e7e:	53                   	push   %ebx
  802e7f:	83 ec 10             	sub    $0x10,%esp
  802e82:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802e85:	85 f6                	test   %esi,%esi
  802e87:	75 24                	jne    802ead <wait+0x33>
  802e89:	c7 44 24 0c 46 3a 80 	movl   $0x803a46,0xc(%esp)
  802e90:	00 
  802e91:	c7 44 24 08 fb 38 80 	movl   $0x8038fb,0x8(%esp)
  802e98:	00 
  802e99:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  802ea0:	00 
  802ea1:	c7 04 24 51 3a 80 00 	movl   $0x803a51,(%esp)
  802ea8:	e8 fa d6 ff ff       	call   8005a7 <_panic>
	e = &envs[ENVX(envid)];
  802ead:	89 f3                	mov    %esi,%ebx
  802eaf:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  802eb5:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802eb8:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802ebe:	eb 05                	jmp    802ec5 <wait+0x4b>
		sys_yield();
  802ec0:	e8 ff e1 ff ff       	call   8010c4 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802ec5:	8b 43 48             	mov    0x48(%ebx),%eax
  802ec8:	39 f0                	cmp    %esi,%eax
  802eca:	75 07                	jne    802ed3 <wait+0x59>
  802ecc:	8b 43 54             	mov    0x54(%ebx),%eax
  802ecf:	85 c0                	test   %eax,%eax
  802ed1:	75 ed                	jne    802ec0 <wait+0x46>
		sys_yield();
}
  802ed3:	83 c4 10             	add    $0x10,%esp
  802ed6:	5b                   	pop    %ebx
  802ed7:	5e                   	pop    %esi
  802ed8:	5d                   	pop    %ebp
  802ed9:	c3                   	ret    

00802eda <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802eda:	55                   	push   %ebp
  802edb:	89 e5                	mov    %esp,%ebp
  802edd:	53                   	push   %ebx
  802ede:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  802ee1:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802ee8:	75 2f                	jne    802f19 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  802eea:	e8 b6 e1 ff ff       	call   8010a5 <sys_getenvid>
  802eef:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P);
  802ef1:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802ef8:	00 
  802ef9:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802f00:	ee 
  802f01:	89 04 24             	mov    %eax,(%esp)
  802f04:	e8 da e1 ff ff       	call   8010e3 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *)_pgfault_upcall);
  802f09:	c7 44 24 04 27 2f 80 	movl   $0x802f27,0x4(%esp)
  802f10:	00 
  802f11:	89 1c 24             	mov    %ebx,(%esp)
  802f14:	e8 6a e3 ff ff       	call   801283 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802f19:	8b 45 08             	mov    0x8(%ebp),%eax
  802f1c:	a3 00 80 80 00       	mov    %eax,0x808000
}
  802f21:	83 c4 14             	add    $0x14,%esp
  802f24:	5b                   	pop    %ebx
  802f25:	5d                   	pop    %ebp
  802f26:	c3                   	ret    

00802f27 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802f27:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802f28:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802f2d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802f2f:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	// 0x30(%esp) points to trap-time stack pointer
	// 0x28(%esp) points to trap-time eip
	subl $4, 0x30(%esp)
  802f32:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax 
  802f37:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebp
  802f3b:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %ebp, (%eax)
  802f3f:	89 28                	mov    %ebp,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  802f41:	83 c4 08             	add    $0x8,%esp
	popal
  802f44:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp //pop eip - we already stored it
  802f45:	83 c4 04             	add    $0x4,%esp
	popfl
  802f48:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802f49:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802f4a:	c3                   	ret    
  802f4b:	66 90                	xchg   %ax,%ax
  802f4d:	66 90                	xchg   %ax,%ax
  802f4f:	90                   	nop

00802f50 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802f50:	55                   	push   %ebp
  802f51:	89 e5                	mov    %esp,%ebp
  802f53:	56                   	push   %esi
  802f54:	53                   	push   %ebx
  802f55:	83 ec 10             	sub    $0x10,%esp
  802f58:	8b 75 08             	mov    0x8(%ebp),%esi
  802f5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  802f61:	85 c0                	test   %eax,%eax
  802f63:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802f68:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  802f6b:	89 04 24             	mov    %eax,(%esp)
  802f6e:	e8 86 e3 ff ff       	call   8012f9 <sys_ipc_recv>

	if(ret < 0) {
  802f73:	85 c0                	test   %eax,%eax
  802f75:	79 16                	jns    802f8d <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  802f77:	85 f6                	test   %esi,%esi
  802f79:	74 06                	je     802f81 <ipc_recv+0x31>
  802f7b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  802f81:	85 db                	test   %ebx,%ebx
  802f83:	74 3e                	je     802fc3 <ipc_recv+0x73>
  802f85:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802f8b:	eb 36                	jmp    802fc3 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  802f8d:	e8 13 e1 ff ff       	call   8010a5 <sys_getenvid>
  802f92:	25 ff 03 00 00       	and    $0x3ff,%eax
  802f97:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802f9a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802f9f:	a3 08 50 80 00       	mov    %eax,0x805008

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802fa4:	85 f6                	test   %esi,%esi
  802fa6:	74 05                	je     802fad <ipc_recv+0x5d>
  802fa8:	8b 40 74             	mov    0x74(%eax),%eax
  802fab:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  802fad:	85 db                	test   %ebx,%ebx
  802faf:	74 0a                	je     802fbb <ipc_recv+0x6b>
  802fb1:	a1 08 50 80 00       	mov    0x805008,%eax
  802fb6:	8b 40 78             	mov    0x78(%eax),%eax
  802fb9:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  802fbb:	a1 08 50 80 00       	mov    0x805008,%eax
  802fc0:	8b 40 70             	mov    0x70(%eax),%eax
}
  802fc3:	83 c4 10             	add    $0x10,%esp
  802fc6:	5b                   	pop    %ebx
  802fc7:	5e                   	pop    %esi
  802fc8:	5d                   	pop    %ebp
  802fc9:	c3                   	ret    

00802fca <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802fca:	55                   	push   %ebp
  802fcb:	89 e5                	mov    %esp,%ebp
  802fcd:	57                   	push   %edi
  802fce:	56                   	push   %esi
  802fcf:	53                   	push   %ebx
  802fd0:	83 ec 1c             	sub    $0x1c,%esp
  802fd3:	8b 7d 08             	mov    0x8(%ebp),%edi
  802fd6:	8b 75 0c             	mov    0xc(%ebp),%esi
  802fd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  802fdc:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  802fde:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802fe3:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  802fe6:	8b 45 14             	mov    0x14(%ebp),%eax
  802fe9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802fed:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802ff1:	89 74 24 04          	mov    %esi,0x4(%esp)
  802ff5:	89 3c 24             	mov    %edi,(%esp)
  802ff8:	e8 d9 e2 ff ff       	call   8012d6 <sys_ipc_try_send>

		if(ret >= 0) break;
  802ffd:	85 c0                	test   %eax,%eax
  802fff:	79 2c                	jns    80302d <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  803001:	83 f8 f9             	cmp    $0xfffffff9,%eax
  803004:	74 20                	je     803026 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  803006:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80300a:	c7 44 24 08 5c 3a 80 	movl   $0x803a5c,0x8(%esp)
  803011:	00 
  803012:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  803019:	00 
  80301a:	c7 04 24 8c 3a 80 00 	movl   $0x803a8c,(%esp)
  803021:	e8 81 d5 ff ff       	call   8005a7 <_panic>
		}
		sys_yield();
  803026:	e8 99 e0 ff ff       	call   8010c4 <sys_yield>
	}
  80302b:	eb b9                	jmp    802fe6 <ipc_send+0x1c>
}
  80302d:	83 c4 1c             	add    $0x1c,%esp
  803030:	5b                   	pop    %ebx
  803031:	5e                   	pop    %esi
  803032:	5f                   	pop    %edi
  803033:	5d                   	pop    %ebp
  803034:	c3                   	ret    

00803035 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  803035:	55                   	push   %ebp
  803036:	89 e5                	mov    %esp,%ebp
  803038:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80303b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  803040:	6b d0 7c             	imul   $0x7c,%eax,%edx
  803043:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  803049:	8b 52 50             	mov    0x50(%edx),%edx
  80304c:	39 ca                	cmp    %ecx,%edx
  80304e:	75 0d                	jne    80305d <ipc_find_env+0x28>
			return envs[i].env_id;
  803050:	6b c0 7c             	imul   $0x7c,%eax,%eax
  803053:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  803058:	8b 40 40             	mov    0x40(%eax),%eax
  80305b:	eb 0e                	jmp    80306b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80305d:	83 c0 01             	add    $0x1,%eax
  803060:	3d 00 04 00 00       	cmp    $0x400,%eax
  803065:	75 d9                	jne    803040 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  803067:	66 b8 00 00          	mov    $0x0,%ax
}
  80306b:	5d                   	pop    %ebp
  80306c:	c3                   	ret    

0080306d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80306d:	55                   	push   %ebp
  80306e:	89 e5                	mov    %esp,%ebp
  803070:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803073:	89 d0                	mov    %edx,%eax
  803075:	c1 e8 16             	shr    $0x16,%eax
  803078:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80307f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803084:	f6 c1 01             	test   $0x1,%cl
  803087:	74 1d                	je     8030a6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  803089:	c1 ea 0c             	shr    $0xc,%edx
  80308c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  803093:	f6 c2 01             	test   $0x1,%dl
  803096:	74 0e                	je     8030a6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803098:	c1 ea 0c             	shr    $0xc,%edx
  80309b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8030a2:	ef 
  8030a3:	0f b7 c0             	movzwl %ax,%eax
}
  8030a6:	5d                   	pop    %ebp
  8030a7:	c3                   	ret    
  8030a8:	66 90                	xchg   %ax,%ax
  8030aa:	66 90                	xchg   %ax,%ax
  8030ac:	66 90                	xchg   %ax,%ax
  8030ae:	66 90                	xchg   %ax,%ax

008030b0 <__udivdi3>:
  8030b0:	55                   	push   %ebp
  8030b1:	57                   	push   %edi
  8030b2:	56                   	push   %esi
  8030b3:	83 ec 0c             	sub    $0xc,%esp
  8030b6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8030ba:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8030be:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8030c2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8030c6:	85 c0                	test   %eax,%eax
  8030c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8030cc:	89 ea                	mov    %ebp,%edx
  8030ce:	89 0c 24             	mov    %ecx,(%esp)
  8030d1:	75 2d                	jne    803100 <__udivdi3+0x50>
  8030d3:	39 e9                	cmp    %ebp,%ecx
  8030d5:	77 61                	ja     803138 <__udivdi3+0x88>
  8030d7:	85 c9                	test   %ecx,%ecx
  8030d9:	89 ce                	mov    %ecx,%esi
  8030db:	75 0b                	jne    8030e8 <__udivdi3+0x38>
  8030dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8030e2:	31 d2                	xor    %edx,%edx
  8030e4:	f7 f1                	div    %ecx
  8030e6:	89 c6                	mov    %eax,%esi
  8030e8:	31 d2                	xor    %edx,%edx
  8030ea:	89 e8                	mov    %ebp,%eax
  8030ec:	f7 f6                	div    %esi
  8030ee:	89 c5                	mov    %eax,%ebp
  8030f0:	89 f8                	mov    %edi,%eax
  8030f2:	f7 f6                	div    %esi
  8030f4:	89 ea                	mov    %ebp,%edx
  8030f6:	83 c4 0c             	add    $0xc,%esp
  8030f9:	5e                   	pop    %esi
  8030fa:	5f                   	pop    %edi
  8030fb:	5d                   	pop    %ebp
  8030fc:	c3                   	ret    
  8030fd:	8d 76 00             	lea    0x0(%esi),%esi
  803100:	39 e8                	cmp    %ebp,%eax
  803102:	77 24                	ja     803128 <__udivdi3+0x78>
  803104:	0f bd e8             	bsr    %eax,%ebp
  803107:	83 f5 1f             	xor    $0x1f,%ebp
  80310a:	75 3c                	jne    803148 <__udivdi3+0x98>
  80310c:	8b 74 24 04          	mov    0x4(%esp),%esi
  803110:	39 34 24             	cmp    %esi,(%esp)
  803113:	0f 86 9f 00 00 00    	jbe    8031b8 <__udivdi3+0x108>
  803119:	39 d0                	cmp    %edx,%eax
  80311b:	0f 82 97 00 00 00    	jb     8031b8 <__udivdi3+0x108>
  803121:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803128:	31 d2                	xor    %edx,%edx
  80312a:	31 c0                	xor    %eax,%eax
  80312c:	83 c4 0c             	add    $0xc,%esp
  80312f:	5e                   	pop    %esi
  803130:	5f                   	pop    %edi
  803131:	5d                   	pop    %ebp
  803132:	c3                   	ret    
  803133:	90                   	nop
  803134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803138:	89 f8                	mov    %edi,%eax
  80313a:	f7 f1                	div    %ecx
  80313c:	31 d2                	xor    %edx,%edx
  80313e:	83 c4 0c             	add    $0xc,%esp
  803141:	5e                   	pop    %esi
  803142:	5f                   	pop    %edi
  803143:	5d                   	pop    %ebp
  803144:	c3                   	ret    
  803145:	8d 76 00             	lea    0x0(%esi),%esi
  803148:	89 e9                	mov    %ebp,%ecx
  80314a:	8b 3c 24             	mov    (%esp),%edi
  80314d:	d3 e0                	shl    %cl,%eax
  80314f:	89 c6                	mov    %eax,%esi
  803151:	b8 20 00 00 00       	mov    $0x20,%eax
  803156:	29 e8                	sub    %ebp,%eax
  803158:	89 c1                	mov    %eax,%ecx
  80315a:	d3 ef                	shr    %cl,%edi
  80315c:	89 e9                	mov    %ebp,%ecx
  80315e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  803162:	8b 3c 24             	mov    (%esp),%edi
  803165:	09 74 24 08          	or     %esi,0x8(%esp)
  803169:	89 d6                	mov    %edx,%esi
  80316b:	d3 e7                	shl    %cl,%edi
  80316d:	89 c1                	mov    %eax,%ecx
  80316f:	89 3c 24             	mov    %edi,(%esp)
  803172:	8b 7c 24 04          	mov    0x4(%esp),%edi
  803176:	d3 ee                	shr    %cl,%esi
  803178:	89 e9                	mov    %ebp,%ecx
  80317a:	d3 e2                	shl    %cl,%edx
  80317c:	89 c1                	mov    %eax,%ecx
  80317e:	d3 ef                	shr    %cl,%edi
  803180:	09 d7                	or     %edx,%edi
  803182:	89 f2                	mov    %esi,%edx
  803184:	89 f8                	mov    %edi,%eax
  803186:	f7 74 24 08          	divl   0x8(%esp)
  80318a:	89 d6                	mov    %edx,%esi
  80318c:	89 c7                	mov    %eax,%edi
  80318e:	f7 24 24             	mull   (%esp)
  803191:	39 d6                	cmp    %edx,%esi
  803193:	89 14 24             	mov    %edx,(%esp)
  803196:	72 30                	jb     8031c8 <__udivdi3+0x118>
  803198:	8b 54 24 04          	mov    0x4(%esp),%edx
  80319c:	89 e9                	mov    %ebp,%ecx
  80319e:	d3 e2                	shl    %cl,%edx
  8031a0:	39 c2                	cmp    %eax,%edx
  8031a2:	73 05                	jae    8031a9 <__udivdi3+0xf9>
  8031a4:	3b 34 24             	cmp    (%esp),%esi
  8031a7:	74 1f                	je     8031c8 <__udivdi3+0x118>
  8031a9:	89 f8                	mov    %edi,%eax
  8031ab:	31 d2                	xor    %edx,%edx
  8031ad:	e9 7a ff ff ff       	jmp    80312c <__udivdi3+0x7c>
  8031b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8031b8:	31 d2                	xor    %edx,%edx
  8031ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8031bf:	e9 68 ff ff ff       	jmp    80312c <__udivdi3+0x7c>
  8031c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8031c8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8031cb:	31 d2                	xor    %edx,%edx
  8031cd:	83 c4 0c             	add    $0xc,%esp
  8031d0:	5e                   	pop    %esi
  8031d1:	5f                   	pop    %edi
  8031d2:	5d                   	pop    %ebp
  8031d3:	c3                   	ret    
  8031d4:	66 90                	xchg   %ax,%ax
  8031d6:	66 90                	xchg   %ax,%ax
  8031d8:	66 90                	xchg   %ax,%ax
  8031da:	66 90                	xchg   %ax,%ax
  8031dc:	66 90                	xchg   %ax,%ax
  8031de:	66 90                	xchg   %ax,%ax

008031e0 <__umoddi3>:
  8031e0:	55                   	push   %ebp
  8031e1:	57                   	push   %edi
  8031e2:	56                   	push   %esi
  8031e3:	83 ec 14             	sub    $0x14,%esp
  8031e6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8031ea:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8031ee:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8031f2:	89 c7                	mov    %eax,%edi
  8031f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031f8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8031fc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  803200:	89 34 24             	mov    %esi,(%esp)
  803203:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803207:	85 c0                	test   %eax,%eax
  803209:	89 c2                	mov    %eax,%edx
  80320b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80320f:	75 17                	jne    803228 <__umoddi3+0x48>
  803211:	39 fe                	cmp    %edi,%esi
  803213:	76 4b                	jbe    803260 <__umoddi3+0x80>
  803215:	89 c8                	mov    %ecx,%eax
  803217:	89 fa                	mov    %edi,%edx
  803219:	f7 f6                	div    %esi
  80321b:	89 d0                	mov    %edx,%eax
  80321d:	31 d2                	xor    %edx,%edx
  80321f:	83 c4 14             	add    $0x14,%esp
  803222:	5e                   	pop    %esi
  803223:	5f                   	pop    %edi
  803224:	5d                   	pop    %ebp
  803225:	c3                   	ret    
  803226:	66 90                	xchg   %ax,%ax
  803228:	39 f8                	cmp    %edi,%eax
  80322a:	77 54                	ja     803280 <__umoddi3+0xa0>
  80322c:	0f bd e8             	bsr    %eax,%ebp
  80322f:	83 f5 1f             	xor    $0x1f,%ebp
  803232:	75 5c                	jne    803290 <__umoddi3+0xb0>
  803234:	8b 7c 24 08          	mov    0x8(%esp),%edi
  803238:	39 3c 24             	cmp    %edi,(%esp)
  80323b:	0f 87 e7 00 00 00    	ja     803328 <__umoddi3+0x148>
  803241:	8b 7c 24 04          	mov    0x4(%esp),%edi
  803245:	29 f1                	sub    %esi,%ecx
  803247:	19 c7                	sbb    %eax,%edi
  803249:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80324d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  803251:	8b 44 24 08          	mov    0x8(%esp),%eax
  803255:	8b 54 24 0c          	mov    0xc(%esp),%edx
  803259:	83 c4 14             	add    $0x14,%esp
  80325c:	5e                   	pop    %esi
  80325d:	5f                   	pop    %edi
  80325e:	5d                   	pop    %ebp
  80325f:	c3                   	ret    
  803260:	85 f6                	test   %esi,%esi
  803262:	89 f5                	mov    %esi,%ebp
  803264:	75 0b                	jne    803271 <__umoddi3+0x91>
  803266:	b8 01 00 00 00       	mov    $0x1,%eax
  80326b:	31 d2                	xor    %edx,%edx
  80326d:	f7 f6                	div    %esi
  80326f:	89 c5                	mov    %eax,%ebp
  803271:	8b 44 24 04          	mov    0x4(%esp),%eax
  803275:	31 d2                	xor    %edx,%edx
  803277:	f7 f5                	div    %ebp
  803279:	89 c8                	mov    %ecx,%eax
  80327b:	f7 f5                	div    %ebp
  80327d:	eb 9c                	jmp    80321b <__umoddi3+0x3b>
  80327f:	90                   	nop
  803280:	89 c8                	mov    %ecx,%eax
  803282:	89 fa                	mov    %edi,%edx
  803284:	83 c4 14             	add    $0x14,%esp
  803287:	5e                   	pop    %esi
  803288:	5f                   	pop    %edi
  803289:	5d                   	pop    %ebp
  80328a:	c3                   	ret    
  80328b:	90                   	nop
  80328c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803290:	8b 04 24             	mov    (%esp),%eax
  803293:	be 20 00 00 00       	mov    $0x20,%esi
  803298:	89 e9                	mov    %ebp,%ecx
  80329a:	29 ee                	sub    %ebp,%esi
  80329c:	d3 e2                	shl    %cl,%edx
  80329e:	89 f1                	mov    %esi,%ecx
  8032a0:	d3 e8                	shr    %cl,%eax
  8032a2:	89 e9                	mov    %ebp,%ecx
  8032a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8032a8:	8b 04 24             	mov    (%esp),%eax
  8032ab:	09 54 24 04          	or     %edx,0x4(%esp)
  8032af:	89 fa                	mov    %edi,%edx
  8032b1:	d3 e0                	shl    %cl,%eax
  8032b3:	89 f1                	mov    %esi,%ecx
  8032b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8032b9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8032bd:	d3 ea                	shr    %cl,%edx
  8032bf:	89 e9                	mov    %ebp,%ecx
  8032c1:	d3 e7                	shl    %cl,%edi
  8032c3:	89 f1                	mov    %esi,%ecx
  8032c5:	d3 e8                	shr    %cl,%eax
  8032c7:	89 e9                	mov    %ebp,%ecx
  8032c9:	09 f8                	or     %edi,%eax
  8032cb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8032cf:	f7 74 24 04          	divl   0x4(%esp)
  8032d3:	d3 e7                	shl    %cl,%edi
  8032d5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8032d9:	89 d7                	mov    %edx,%edi
  8032db:	f7 64 24 08          	mull   0x8(%esp)
  8032df:	39 d7                	cmp    %edx,%edi
  8032e1:	89 c1                	mov    %eax,%ecx
  8032e3:	89 14 24             	mov    %edx,(%esp)
  8032e6:	72 2c                	jb     803314 <__umoddi3+0x134>
  8032e8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8032ec:	72 22                	jb     803310 <__umoddi3+0x130>
  8032ee:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8032f2:	29 c8                	sub    %ecx,%eax
  8032f4:	19 d7                	sbb    %edx,%edi
  8032f6:	89 e9                	mov    %ebp,%ecx
  8032f8:	89 fa                	mov    %edi,%edx
  8032fa:	d3 e8                	shr    %cl,%eax
  8032fc:	89 f1                	mov    %esi,%ecx
  8032fe:	d3 e2                	shl    %cl,%edx
  803300:	89 e9                	mov    %ebp,%ecx
  803302:	d3 ef                	shr    %cl,%edi
  803304:	09 d0                	or     %edx,%eax
  803306:	89 fa                	mov    %edi,%edx
  803308:	83 c4 14             	add    $0x14,%esp
  80330b:	5e                   	pop    %esi
  80330c:	5f                   	pop    %edi
  80330d:	5d                   	pop    %ebp
  80330e:	c3                   	ret    
  80330f:	90                   	nop
  803310:	39 d7                	cmp    %edx,%edi
  803312:	75 da                	jne    8032ee <__umoddi3+0x10e>
  803314:	8b 14 24             	mov    (%esp),%edx
  803317:	89 c1                	mov    %eax,%ecx
  803319:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80331d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  803321:	eb cb                	jmp    8032ee <__umoddi3+0x10e>
  803323:	90                   	nop
  803324:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803328:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80332c:	0f 82 0f ff ff ff    	jb     803241 <__umoddi3+0x61>
  803332:	e9 1a ff ff ff       	jmp    803251 <__umoddi3+0x71>
