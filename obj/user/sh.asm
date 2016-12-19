
obj/user/sh.debug:     file format elf32-i386


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
  80002c:	e8 d5 09 00 00       	call   800a06 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	57                   	push   %edi
  800044:	56                   	push   %esi
  800045:	53                   	push   %ebx
  800046:	83 ec 1c             	sub    $0x1c,%esp
  800049:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int t;

	if (s == 0) {
  80004f:	85 db                	test   %ebx,%ebx
  800051:	75 28                	jne    80007b <_gettoken+0x3b>
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
  800053:	b8 00 00 00 00       	mov    $0x0,%eax
_gettoken(char *s, char **p1, char **p2)
{
	int t;

	if (s == 0) {
		if (debug > 1)
  800058:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  80005f:	0f 8e 33 01 00 00    	jle    800198 <_gettoken+0x158>
			cprintf("GETTOKEN NULL\n");
  800065:	c7 04 24 a0 3b 80 00 	movl   $0x803ba0,(%esp)
  80006c:	e8 ef 0a 00 00       	call   800b60 <cprintf>
		return 0;
  800071:	b8 00 00 00 00       	mov    $0x0,%eax
  800076:	e9 1d 01 00 00       	jmp    800198 <_gettoken+0x158>
	}

	if (debug > 1)
  80007b:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  800082:	7e 10                	jle    800094 <_gettoken+0x54>
		cprintf("GETTOKEN: %s\n", s);
  800084:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800088:	c7 04 24 af 3b 80 00 	movl   $0x803baf,(%esp)
  80008f:	e8 cc 0a 00 00       	call   800b60 <cprintf>

	*p1 = 0;
  800094:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	*p2 = 0;
  80009a:	8b 45 10             	mov    0x10(%ebp),%eax
  80009d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  8000a3:	eb 07                	jmp    8000ac <_gettoken+0x6c>
		*s++ = 0;
  8000a5:	83 c3 01             	add    $0x1,%ebx
  8000a8:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
  8000ac:	0f be 03             	movsbl (%ebx),%eax
  8000af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b3:	c7 04 24 bd 3b 80 00 	movl   $0x803bbd,(%esp)
  8000ba:	e8 cb 12 00 00       	call   80138a <strchr>
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	75 e2                	jne    8000a5 <_gettoken+0x65>
  8000c3:	89 df                	mov    %ebx,%edi
		*s++ = 0;
	if (*s == 0) {
  8000c5:	0f b6 03             	movzbl (%ebx),%eax
  8000c8:	84 c0                	test   %al,%al
  8000ca:	75 28                	jne    8000f4 <_gettoken+0xb4>
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  8000cc:	b8 00 00 00 00       	mov    $0x0,%eax
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
		*s++ = 0;
	if (*s == 0) {
		if (debug > 1)
  8000d1:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  8000d8:	0f 8e ba 00 00 00    	jle    800198 <_gettoken+0x158>
			cprintf("EOL\n");
  8000de:	c7 04 24 c2 3b 80 00 	movl   $0x803bc2,(%esp)
  8000e5:	e8 76 0a 00 00       	call   800b60 <cprintf>
		return 0;
  8000ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ef:	e9 a4 00 00 00       	jmp    800198 <_gettoken+0x158>
	}
	if (strchr(SYMBOLS, *s)) {
  8000f4:	0f be c0             	movsbl %al,%eax
  8000f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000fb:	c7 04 24 d3 3b 80 00 	movl   $0x803bd3,(%esp)
  800102:	e8 83 12 00 00       	call   80138a <strchr>
  800107:	85 c0                	test   %eax,%eax
  800109:	74 2f                	je     80013a <_gettoken+0xfa>
		t = *s;
  80010b:	0f be 1b             	movsbl (%ebx),%ebx
		*p1 = s;
  80010e:	89 3e                	mov    %edi,(%esi)
		*s++ = 0;
  800110:	c6 07 00             	movb   $0x0,(%edi)
  800113:	83 c7 01             	add    $0x1,%edi
  800116:	8b 45 10             	mov    0x10(%ebp),%eax
  800119:	89 38                	mov    %edi,(%eax)
		*p2 = s;
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
  80011b:	89 d8                	mov    %ebx,%eax
	if (strchr(SYMBOLS, *s)) {
		t = *s;
		*p1 = s;
		*s++ = 0;
		*p2 = s;
		if (debug > 1)
  80011d:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  800124:	7e 72                	jle    800198 <_gettoken+0x158>
			cprintf("TOK %c\n", t);
  800126:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80012a:	c7 04 24 c7 3b 80 00 	movl   $0x803bc7,(%esp)
  800131:	e8 2a 0a 00 00       	call   800b60 <cprintf>
		return t;
  800136:	89 d8                	mov    %ebx,%eax
  800138:	eb 5e                	jmp    800198 <_gettoken+0x158>
	}
	*p1 = s;
  80013a:	89 1e                	mov    %ebx,(%esi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80013c:	eb 03                	jmp    800141 <_gettoken+0x101>
		s++;
  80013e:	83 c3 01             	add    $0x1,%ebx
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800141:	0f b6 03             	movzbl (%ebx),%eax
  800144:	84 c0                	test   %al,%al
  800146:	74 17                	je     80015f <_gettoken+0x11f>
  800148:	0f be c0             	movsbl %al,%eax
  80014b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014f:	c7 04 24 cf 3b 80 00 	movl   $0x803bcf,(%esp)
  800156:	e8 2f 12 00 00       	call   80138a <strchr>
  80015b:	85 c0                	test   %eax,%eax
  80015d:	74 df                	je     80013e <_gettoken+0xfe>
		s++;
	*p2 = s;
  80015f:	8b 45 10             	mov    0x10(%ebp),%eax
  800162:	89 18                	mov    %ebx,(%eax)
		t = **p2;
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
  800164:	b8 77 00 00 00       	mov    $0x77,%eax
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
		s++;
	*p2 = s;
	if (debug > 1) {
  800169:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  800170:	7e 26                	jle    800198 <_gettoken+0x158>
		t = **p2;
  800172:	0f b6 3b             	movzbl (%ebx),%edi
		**p2 = 0;
  800175:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  800178:	8b 06                	mov    (%esi),%eax
  80017a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017e:	c7 04 24 db 3b 80 00 	movl   $0x803bdb,(%esp)
  800185:	e8 d6 09 00 00       	call   800b60 <cprintf>
		**p2 = t;
  80018a:	8b 45 10             	mov    0x10(%ebp),%eax
  80018d:	8b 00                	mov    (%eax),%eax
  80018f:	89 fa                	mov    %edi,%edx
  800191:	88 10                	mov    %dl,(%eax)
	}
	return 'w';
  800193:	b8 77 00 00 00       	mov    $0x77,%eax
}
  800198:	83 c4 1c             	add    $0x1c,%esp
  80019b:	5b                   	pop    %ebx
  80019c:	5e                   	pop    %esi
  80019d:	5f                   	pop    %edi
  80019e:	5d                   	pop    %ebp
  80019f:	c3                   	ret    

008001a0 <gettoken>:

int
gettoken(char *s, char **p1)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 18             	sub    $0x18,%esp
  8001a6:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  8001a9:	85 c0                	test   %eax,%eax
  8001ab:	74 24                	je     8001d1 <gettoken+0x31>
		nc = _gettoken(s, &np1, &np2);
  8001ad:	c7 44 24 08 0c 60 80 	movl   $0x80600c,0x8(%esp)
  8001b4:	00 
  8001b5:	c7 44 24 04 10 60 80 	movl   $0x806010,0x4(%esp)
  8001bc:	00 
  8001bd:	89 04 24             	mov    %eax,(%esp)
  8001c0:	e8 7b fe ff ff       	call   800040 <_gettoken>
  8001c5:	a3 08 60 80 00       	mov    %eax,0x806008
		return 0;
  8001ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8001cf:	eb 3c                	jmp    80020d <gettoken+0x6d>
	}
	c = nc;
  8001d1:	a1 08 60 80 00       	mov    0x806008,%eax
  8001d6:	a3 04 60 80 00       	mov    %eax,0x806004
	*p1 = np1;
  8001db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001de:	8b 15 10 60 80 00    	mov    0x806010,%edx
  8001e4:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001e6:	c7 44 24 08 0c 60 80 	movl   $0x80600c,0x8(%esp)
  8001ed:	00 
  8001ee:	c7 44 24 04 10 60 80 	movl   $0x806010,0x4(%esp)
  8001f5:	00 
  8001f6:	a1 0c 60 80 00       	mov    0x80600c,%eax
  8001fb:	89 04 24             	mov    %eax,(%esp)
  8001fe:	e8 3d fe ff ff       	call   800040 <_gettoken>
  800203:	a3 08 60 80 00       	mov    %eax,0x806008
	return c;
  800208:	a1 04 60 80 00       	mov    0x806004,%eax
}
  80020d:	c9                   	leave  
  80020e:	c3                   	ret    

0080020f <runcmd>:
// runcmd() is called in a forked child,
// so it's OK to manipulate file descriptor state.
#define MAXARGS 16
void
runcmd(char* s)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	57                   	push   %edi
  800213:	56                   	push   %esi
  800214:	53                   	push   %ebx
  800215:	81 ec 6c 04 00 00    	sub    $0x46c,%esp
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
	gettoken(s, 0);
  80021b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800222:	00 
  800223:	8b 45 08             	mov    0x8(%ebp),%eax
  800226:	89 04 24             	mov    %eax,(%esp)
  800229:	e8 72 ff ff ff       	call   8001a0 <gettoken>

again:
	argc = 0;
  80022e:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		switch ((c = gettoken(0, &t))) {
  800233:	8d 5d a4             	lea    -0x5c(%ebp),%ebx
  800236:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80023a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800241:	e8 5a ff ff ff       	call   8001a0 <gettoken>
  800246:	83 f8 3e             	cmp    $0x3e,%eax
  800249:	0f 84 d4 00 00 00    	je     800323 <runcmd+0x114>
  80024f:	83 f8 3e             	cmp    $0x3e,%eax
  800252:	7f 13                	jg     800267 <runcmd+0x58>
  800254:	85 c0                	test   %eax,%eax
  800256:	0f 84 55 02 00 00    	je     8004b1 <runcmd+0x2a2>
  80025c:	83 f8 3c             	cmp    $0x3c,%eax
  80025f:	90                   	nop
  800260:	74 3d                	je     80029f <runcmd+0x90>
  800262:	e9 2a 02 00 00       	jmp    800491 <runcmd+0x282>
  800267:	83 f8 77             	cmp    $0x77,%eax
  80026a:	74 0f                	je     80027b <runcmd+0x6c>
  80026c:	83 f8 7c             	cmp    $0x7c,%eax
  80026f:	90                   	nop
  800270:	0f 84 2e 01 00 00    	je     8003a4 <runcmd+0x195>
  800276:	e9 16 02 00 00       	jmp    800491 <runcmd+0x282>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  80027b:	83 fe 10             	cmp    $0x10,%esi
  80027e:	66 90                	xchg   %ax,%ax
  800280:	75 11                	jne    800293 <runcmd+0x84>
				cprintf("too many arguments\n");
  800282:	c7 04 24 e5 3b 80 00 	movl   $0x803be5,(%esp)
  800289:	e8 d2 08 00 00       	call   800b60 <cprintf>
				exit();
  80028e:	e8 bb 07 00 00       	call   800a4e <exit>
			}
			argv[argc++] = t;
  800293:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800296:	89 44 b5 a8          	mov    %eax,-0x58(%ebp,%esi,4)
  80029a:	8d 76 01             	lea    0x1(%esi),%esi
			break;
  80029d:	eb 97                	jmp    800236 <runcmd+0x27>

		case '<':	// Input redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  80029f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002aa:	e8 f1 fe ff ff       	call   8001a0 <gettoken>
  8002af:	83 f8 77             	cmp    $0x77,%eax
  8002b2:	74 11                	je     8002c5 <runcmd+0xb6>
				cprintf("syntax error: < not followed by word\n");
  8002b4:	c7 04 24 24 3d 80 00 	movl   $0x803d24,(%esp)
  8002bb:	e8 a0 08 00 00       	call   800b60 <cprintf>
				exit();
  8002c0:	e8 89 07 00 00       	call   800a4e <exit>
			// then check whether 'fd' is 0.
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			if ((fd = open(t,O_RDONLY)) < 0) {
  8002c5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8002cc:	00 
  8002cd:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  8002d0:	89 04 24             	mov    %eax,(%esp)
  8002d3:	e8 3b 23 00 00       	call   802613 <open>
  8002d8:	89 c7                	mov    %eax,%edi
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	79 1e                	jns    8002fc <runcmd+0xed>
				cprintf("open %s for write: %e", t, fd);
  8002de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e2:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  8002e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e9:	c7 04 24 f9 3b 80 00 	movl   $0x803bf9,(%esp)
  8002f0:	e8 6b 08 00 00       	call   800b60 <cprintf>
				exit();
  8002f5:	e8 54 07 00 00       	call   800a4e <exit>
  8002fa:	eb 0a                	jmp    800306 <runcmd+0xf7>
			}
			if (fd != 0) {
  8002fc:	85 c0                	test   %eax,%eax
  8002fe:	66 90                	xchg   %ax,%ax
  800300:	0f 84 30 ff ff ff    	je     800236 <runcmd+0x27>
				dup(fd, 0);
  800306:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80030d:	00 
  80030e:	89 3c 24             	mov    %edi,(%esp)
  800311:	e8 16 1d 00 00       	call   80202c <dup>
				close(fd);
  800316:	89 3c 24             	mov    %edi,(%esp)
  800319:	e8 b9 1c 00 00       	call   801fd7 <close>
  80031e:	e9 13 ff ff ff       	jmp    800236 <runcmd+0x27>
			}
			break;

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800323:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800327:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80032e:	e8 6d fe ff ff       	call   8001a0 <gettoken>
  800333:	83 f8 77             	cmp    $0x77,%eax
  800336:	74 11                	je     800349 <runcmd+0x13a>
				cprintf("syntax error: > not followed by word\n");
  800338:	c7 04 24 4c 3d 80 00 	movl   $0x803d4c,(%esp)
  80033f:	e8 1c 08 00 00       	call   800b60 <cprintf>
				exit();
  800344:	e8 05 07 00 00       	call   800a4e <exit>
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800349:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
  800350:	00 
  800351:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800354:	89 04 24             	mov    %eax,(%esp)
  800357:	e8 b7 22 00 00       	call   802613 <open>
  80035c:	89 c7                	mov    %eax,%edi
  80035e:	85 c0                	test   %eax,%eax
  800360:	79 1c                	jns    80037e <runcmd+0x16f>
				cprintf("open %s for write: %e", t, fd);
  800362:	89 44 24 08          	mov    %eax,0x8(%esp)
  800366:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800369:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036d:	c7 04 24 f9 3b 80 00 	movl   $0x803bf9,(%esp)
  800374:	e8 e7 07 00 00       	call   800b60 <cprintf>
				exit();
  800379:	e8 d0 06 00 00       	call   800a4e <exit>
			}
			if (fd != 1) {
  80037e:	83 ff 01             	cmp    $0x1,%edi
  800381:	0f 84 af fe ff ff    	je     800236 <runcmd+0x27>
				dup(fd, 1);
  800387:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80038e:	00 
  80038f:	89 3c 24             	mov    %edi,(%esp)
  800392:	e8 95 1c 00 00       	call   80202c <dup>
				close(fd);
  800397:	89 3c 24             	mov    %edi,(%esp)
  80039a:	e8 38 1c 00 00       	call   801fd7 <close>
  80039f:	e9 92 fe ff ff       	jmp    800236 <runcmd+0x27>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  8003a4:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  8003aa:	89 04 24             	mov    %eax,(%esp)
  8003ad:	e8 72 31 00 00       	call   803524 <pipe>
  8003b2:	85 c0                	test   %eax,%eax
  8003b4:	79 15                	jns    8003cb <runcmd+0x1bc>
				cprintf("pipe: %e", r);
  8003b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ba:	c7 04 24 0f 3c 80 00 	movl   $0x803c0f,(%esp)
  8003c1:	e8 9a 07 00 00       	call   800b60 <cprintf>
				exit();
  8003c6:	e8 83 06 00 00       	call   800a4e <exit>
			}
			if (debug)
  8003cb:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8003d2:	74 20                	je     8003f4 <runcmd+0x1e5>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003d4:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  8003da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003de:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  8003e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e8:	c7 04 24 18 3c 80 00 	movl   $0x803c18,(%esp)
  8003ef:	e8 6c 07 00 00       	call   800b60 <cprintf>
			if ((r = fork()) < 0) {
  8003f4:	e8 cb 16 00 00       	call   801ac4 <fork>
  8003f9:	89 c7                	mov    %eax,%edi
  8003fb:	85 c0                	test   %eax,%eax
  8003fd:	79 15                	jns    800414 <runcmd+0x205>
				cprintf("fork: %e", r);
  8003ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800403:	c7 04 24 25 3c 80 00 	movl   $0x803c25,(%esp)
  80040a:	e8 51 07 00 00       	call   800b60 <cprintf>
				exit();
  80040f:	e8 3a 06 00 00       	call   800a4e <exit>
			}
			if (r == 0) {
  800414:	85 ff                	test   %edi,%edi
  800416:	75 40                	jne    800458 <runcmd+0x249>
				if (p[0] != 0) {
  800418:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  80041e:	85 c0                	test   %eax,%eax
  800420:	74 1e                	je     800440 <runcmd+0x231>
					dup(p[0], 0);
  800422:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800429:	00 
  80042a:	89 04 24             	mov    %eax,(%esp)
  80042d:	e8 fa 1b 00 00       	call   80202c <dup>
					close(p[0]);
  800432:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800438:	89 04 24             	mov    %eax,(%esp)
  80043b:	e8 97 1b 00 00       	call   801fd7 <close>
				}
				close(p[1]);
  800440:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800446:	89 04 24             	mov    %eax,(%esp)
  800449:	e8 89 1b 00 00       	call   801fd7 <close>

	pipe_child = 0;
	gettoken(s, 0);

again:
	argc = 0;
  80044e:	be 00 00 00 00       	mov    $0x0,%esi
				if (p[0] != 0) {
					dup(p[0], 0);
					close(p[0]);
				}
				close(p[1]);
				goto again;
  800453:	e9 de fd ff ff       	jmp    800236 <runcmd+0x27>
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  800458:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  80045e:	83 f8 01             	cmp    $0x1,%eax
  800461:	74 1e                	je     800481 <runcmd+0x272>
					dup(p[1], 1);
  800463:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80046a:	00 
  80046b:	89 04 24             	mov    %eax,(%esp)
  80046e:	e8 b9 1b 00 00       	call   80202c <dup>
					close(p[1]);
  800473:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800479:	89 04 24             	mov    %eax,(%esp)
  80047c:	e8 56 1b 00 00       	call   801fd7 <close>
				}
				close(p[0]);
  800481:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800487:	89 04 24             	mov    %eax,(%esp)
  80048a:	e8 48 1b 00 00       	call   801fd7 <close>
				goto runit;
  80048f:	eb 25                	jmp    8004b6 <runcmd+0x2a7>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800491:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800495:	c7 44 24 08 2e 3c 80 	movl   $0x803c2e,0x8(%esp)
  80049c:	00 
  80049d:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  8004a4:	00 
  8004a5:	c7 04 24 4a 3c 80 00 	movl   $0x803c4a,(%esp)
  8004ac:	e8 b6 05 00 00       	call   800a67 <_panic>
runcmd(char* s)
{
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
  8004b1:	bf 00 00 00 00       	mov    $0x0,%edi
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  8004b6:	85 f6                	test   %esi,%esi
  8004b8:	75 1e                	jne    8004d8 <runcmd+0x2c9>
		if (debug)
  8004ba:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8004c1:	0f 84 85 01 00 00    	je     80064c <runcmd+0x43d>
			cprintf("EMPTY COMMAND\n");
  8004c7:	c7 04 24 54 3c 80 00 	movl   $0x803c54,(%esp)
  8004ce:	e8 8d 06 00 00       	call   800b60 <cprintf>
  8004d3:	e9 74 01 00 00       	jmp    80064c <runcmd+0x43d>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  8004d8:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8004db:	80 38 2f             	cmpb   $0x2f,(%eax)
  8004de:	74 22                	je     800502 <runcmd+0x2f3>
		argv0buf[0] = '/';
  8004e0:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  8004e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004eb:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  8004f1:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  8004f7:	89 04 24             	mov    %eax,(%esp)
  8004fa:	e8 78 0d 00 00       	call   801277 <strcpy>
		argv[0] = argv0buf;
  8004ff:	89 5d a8             	mov    %ebx,-0x58(%ebp)
	}
	argv[argc] = 0;
  800502:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  800509:	00 

	// Print the command.
	if (debug) {
  80050a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800511:	74 43                	je     800556 <runcmd+0x347>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  800513:	a1 28 64 80 00       	mov    0x806428,%eax
  800518:	8b 40 48             	mov    0x48(%eax),%eax
  80051b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051f:	c7 04 24 63 3c 80 00 	movl   $0x803c63,(%esp)
  800526:	e8 35 06 00 00       	call   800b60 <cprintf>
  80052b:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  80052e:	eb 10                	jmp    800540 <runcmd+0x331>
			cprintf(" %s", argv[i]);
  800530:	89 44 24 04          	mov    %eax,0x4(%esp)
  800534:	c7 04 24 ee 3c 80 00 	movl   $0x803cee,(%esp)
  80053b:	e8 20 06 00 00       	call   800b60 <cprintf>
  800540:	83 c3 04             	add    $0x4,%ebx
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  800543:	8b 43 fc             	mov    -0x4(%ebx),%eax
  800546:	85 c0                	test   %eax,%eax
  800548:	75 e6                	jne    800530 <runcmd+0x321>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  80054a:	c7 04 24 c0 3b 80 00 	movl   $0x803bc0,(%esp)
  800551:	e8 0a 06 00 00       	call   800b60 <cprintf>
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800556:	8d 45 a8             	lea    -0x58(%ebp),%eax
  800559:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055d:	8b 45 a8             	mov    -0x58(%ebp),%eax
  800560:	89 04 24             	mov    %eax,(%esp)
  800563:	e8 88 22 00 00       	call   8027f0 <spawn>
  800568:	89 c3                	mov    %eax,%ebx
  80056a:	85 c0                	test   %eax,%eax
  80056c:	0f 89 c3 00 00 00    	jns    800635 <runcmd+0x426>
		cprintf("spawn %s: %e\n", argv[0], r);
  800572:	89 44 24 08          	mov    %eax,0x8(%esp)
  800576:	8b 45 a8             	mov    -0x58(%ebp),%eax
  800579:	89 44 24 04          	mov    %eax,0x4(%esp)
  80057d:	c7 04 24 71 3c 80 00 	movl   $0x803c71,(%esp)
  800584:	e8 d7 05 00 00       	call   800b60 <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800589:	e8 7c 1a 00 00       	call   80200a <close_all>
  80058e:	eb 4c                	jmp    8005dc <runcmd+0x3cd>
	if (r >= 0) {
		if (debug)
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800590:	a1 28 64 80 00       	mov    0x806428,%eax
  800595:	8b 40 48             	mov    0x48(%eax),%eax
  800598:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80059c:	8b 55 a8             	mov    -0x58(%ebp),%edx
  80059f:	89 54 24 08          	mov    %edx,0x8(%esp)
  8005a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a7:	c7 04 24 7f 3c 80 00 	movl   $0x803c7f,(%esp)
  8005ae:	e8 ad 05 00 00       	call   800b60 <cprintf>
		wait(r);
  8005b3:	89 1c 24             	mov    %ebx,(%esp)
  8005b6:	e8 0f 31 00 00       	call   8036ca <wait>
		if (debug)
  8005bb:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8005c2:	74 18                	je     8005dc <runcmd+0x3cd>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005c4:	a1 28 64 80 00       	mov    0x806428,%eax
  8005c9:	8b 40 48             	mov    0x48(%eax),%eax
  8005cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d0:	c7 04 24 94 3c 80 00 	movl   $0x803c94,(%esp)
  8005d7:	e8 84 05 00 00       	call   800b60 <cprintf>
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005dc:	85 ff                	test   %edi,%edi
  8005de:	74 4e                	je     80062e <runcmd+0x41f>
		if (debug)
  8005e0:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8005e7:	74 1c                	je     800605 <runcmd+0x3f6>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  8005e9:	a1 28 64 80 00       	mov    0x806428,%eax
  8005ee:	8b 40 48             	mov    0x48(%eax),%eax
  8005f1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8005f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f9:	c7 04 24 aa 3c 80 00 	movl   $0x803caa,(%esp)
  800600:	e8 5b 05 00 00       	call   800b60 <cprintf>
		wait(pipe_child);
  800605:	89 3c 24             	mov    %edi,(%esp)
  800608:	e8 bd 30 00 00       	call   8036ca <wait>
		if (debug)
  80060d:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800614:	74 18                	je     80062e <runcmd+0x41f>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800616:	a1 28 64 80 00       	mov    0x806428,%eax
  80061b:	8b 40 48             	mov    0x48(%eax),%eax
  80061e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800622:	c7 04 24 94 3c 80 00 	movl   $0x803c94,(%esp)
  800629:	e8 32 05 00 00       	call   800b60 <cprintf>
	}

	// Done!
	exit();
  80062e:	e8 1b 04 00 00       	call   800a4e <exit>
  800633:	eb 17                	jmp    80064c <runcmd+0x43d>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
		cprintf("spawn %s: %e\n", argv[0], r);

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800635:	e8 d0 19 00 00       	call   80200a <close_all>
	if (r >= 0) {
		if (debug)
  80063a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800641:	0f 84 6c ff ff ff    	je     8005b3 <runcmd+0x3a4>
  800647:	e9 44 ff ff ff       	jmp    800590 <runcmd+0x381>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// Done!
	exit();
}
  80064c:	81 c4 6c 04 00 00    	add    $0x46c,%esp
  800652:	5b                   	pop    %ebx
  800653:	5e                   	pop    %esi
  800654:	5f                   	pop    %edi
  800655:	5d                   	pop    %ebp
  800656:	c3                   	ret    

00800657 <usage>:
}


void
usage(void)
{
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
  80065a:	83 ec 18             	sub    $0x18,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  80065d:	c7 04 24 74 3d 80 00 	movl   $0x803d74,(%esp)
  800664:	e8 f7 04 00 00       	call   800b60 <cprintf>
	exit();
  800669:	e8 e0 03 00 00       	call   800a4e <exit>
}
  80066e:	c9                   	leave  
  80066f:	c3                   	ret    

00800670 <umain>:

void
umain(int argc, char **argv)
{
  800670:	55                   	push   %ebp
  800671:	89 e5                	mov    %esp,%ebp
  800673:	57                   	push   %edi
  800674:	56                   	push   %esi
  800675:	53                   	push   %ebx
  800676:	83 ec 3c             	sub    $0x3c,%esp
  800679:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  80067c:	8d 45 d8             	lea    -0x28(%ebp),%eax
  80067f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800683:	89 74 24 04          	mov    %esi,0x4(%esp)
  800687:	8d 45 08             	lea    0x8(%ebp),%eax
  80068a:	89 04 24             	mov    %eax,(%esp)
  80068d:	e8 3c 16 00 00       	call   801cce <argstart>
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800692:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  800699:	bf 3f 00 00 00       	mov    $0x3f,%edi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  80069e:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  8006a1:	eb 2f                	jmp    8006d2 <umain+0x62>
		switch (r) {
  8006a3:	83 f8 69             	cmp    $0x69,%eax
  8006a6:	74 0c                	je     8006b4 <umain+0x44>
  8006a8:	83 f8 78             	cmp    $0x78,%eax
  8006ab:	74 1e                	je     8006cb <umain+0x5b>
  8006ad:	83 f8 64             	cmp    $0x64,%eax
  8006b0:	75 12                	jne    8006c4 <umain+0x54>
  8006b2:	eb 07                	jmp    8006bb <umain+0x4b>
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  8006b4:	bf 01 00 00 00       	mov    $0x1,%edi
  8006b9:	eb 17                	jmp    8006d2 <umain+0x62>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  8006bb:	83 05 00 60 80 00 01 	addl   $0x1,0x806000
			break;
  8006c2:	eb 0e                	jmp    8006d2 <umain+0x62>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  8006c4:	e8 8e ff ff ff       	call   800657 <usage>
  8006c9:	eb 07                	jmp    8006d2 <umain+0x62>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  8006cb:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  8006d2:	89 1c 24             	mov    %ebx,(%esp)
  8006d5:	e8 2c 16 00 00       	call   801d06 <argnext>
  8006da:	85 c0                	test   %eax,%eax
  8006dc:	79 c5                	jns    8006a3 <umain+0x33>
  8006de:	89 fb                	mov    %edi,%ebx
			break;
		default:
			usage();
		}

	if (argc > 2)
  8006e0:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006e4:	7e 05                	jle    8006eb <umain+0x7b>
		usage();
  8006e6:	e8 6c ff ff ff       	call   800657 <usage>
	if (argc == 2) {
  8006eb:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006ef:	75 72                	jne    800763 <umain+0xf3>
		close(0);
  8006f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006f8:	e8 da 18 00 00       	call   801fd7 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006fd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800704:	00 
  800705:	8b 46 04             	mov    0x4(%esi),%eax
  800708:	89 04 24             	mov    %eax,(%esp)
  80070b:	e8 03 1f 00 00       	call   802613 <open>
  800710:	85 c0                	test   %eax,%eax
  800712:	79 27                	jns    80073b <umain+0xcb>
			panic("open %s: %e", argv[1], r);
  800714:	89 44 24 10          	mov    %eax,0x10(%esp)
  800718:	8b 46 04             	mov    0x4(%esi),%eax
  80071b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80071f:	c7 44 24 08 ca 3c 80 	movl   $0x803cca,0x8(%esp)
  800726:	00 
  800727:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
  80072e:	00 
  80072f:	c7 04 24 4a 3c 80 00 	movl   $0x803c4a,(%esp)
  800736:	e8 2c 03 00 00       	call   800a67 <_panic>
		assert(r == 0);
  80073b:	85 c0                	test   %eax,%eax
  80073d:	74 24                	je     800763 <umain+0xf3>
  80073f:	c7 44 24 0c d6 3c 80 	movl   $0x803cd6,0xc(%esp)
  800746:	00 
  800747:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  80074e:	00 
  80074f:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
  800756:	00 
  800757:	c7 04 24 4a 3c 80 00 	movl   $0x803c4a,(%esp)
  80075e:	e8 04 03 00 00       	call   800a67 <_panic>
	}
	if (interactive == '?')
  800763:	83 fb 3f             	cmp    $0x3f,%ebx
  800766:	75 0e                	jne    800776 <umain+0x106>
		interactive = iscons(0);
  800768:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80076f:	e8 08 02 00 00       	call   80097c <iscons>
  800774:	89 c7                	mov    %eax,%edi

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  800776:	85 ff                	test   %edi,%edi
  800778:	b8 00 00 00 00       	mov    $0x0,%eax
  80077d:	ba c7 3c 80 00       	mov    $0x803cc7,%edx
  800782:	0f 45 c2             	cmovne %edx,%eax
  800785:	89 04 24             	mov    %eax,(%esp)
  800788:	e8 c3 09 00 00       	call   801150 <readline>
  80078d:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  80078f:	85 c0                	test   %eax,%eax
  800791:	75 1a                	jne    8007ad <umain+0x13d>
			if (debug)
  800793:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80079a:	74 0c                	je     8007a8 <umain+0x138>
				cprintf("EXITING\n");
  80079c:	c7 04 24 f2 3c 80 00 	movl   $0x803cf2,(%esp)
  8007a3:	e8 b8 03 00 00       	call   800b60 <cprintf>
			exit();	// end of file
  8007a8:	e8 a1 02 00 00       	call   800a4e <exit>
		}
		if (debug)
  8007ad:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8007b4:	74 10                	je     8007c6 <umain+0x156>
			cprintf("LINE: %s\n", buf);
  8007b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ba:	c7 04 24 fb 3c 80 00 	movl   $0x803cfb,(%esp)
  8007c1:	e8 9a 03 00 00       	call   800b60 <cprintf>
		if (buf[0] == '#')
  8007c6:	80 3b 23             	cmpb   $0x23,(%ebx)
  8007c9:	74 ab                	je     800776 <umain+0x106>
			continue;
		if (echocmds)
  8007cb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007cf:	74 10                	je     8007e1 <umain+0x171>
			printf("# %s\n", buf);
  8007d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d5:	c7 04 24 05 3d 80 00 	movl   $0x803d05,(%esp)
  8007dc:	e8 e2 1f 00 00       	call   8027c3 <printf>
		if (debug)
  8007e1:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8007e8:	74 0c                	je     8007f6 <umain+0x186>
			cprintf("BEFORE FORK\n");
  8007ea:	c7 04 24 0b 3d 80 00 	movl   $0x803d0b,(%esp)
  8007f1:	e8 6a 03 00 00       	call   800b60 <cprintf>
		if ((r = fork()) < 0)
  8007f6:	e8 c9 12 00 00       	call   801ac4 <fork>
  8007fb:	89 c6                	mov    %eax,%esi
  8007fd:	85 c0                	test   %eax,%eax
  8007ff:	79 20                	jns    800821 <umain+0x1b1>
			panic("fork: %e", r);
  800801:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800805:	c7 44 24 08 25 3c 80 	movl   $0x803c25,0x8(%esp)
  80080c:	00 
  80080d:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
  800814:	00 
  800815:	c7 04 24 4a 3c 80 00 	movl   $0x803c4a,(%esp)
  80081c:	e8 46 02 00 00       	call   800a67 <_panic>
		if (debug)
  800821:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800828:	74 10                	je     80083a <umain+0x1ca>
			cprintf("FORK: %d\n", r);
  80082a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082e:	c7 04 24 18 3d 80 00 	movl   $0x803d18,(%esp)
  800835:	e8 26 03 00 00       	call   800b60 <cprintf>
		if (r == 0) {
  80083a:	85 f6                	test   %esi,%esi
  80083c:	75 12                	jne    800850 <umain+0x1e0>
			runcmd(buf);
  80083e:	89 1c 24             	mov    %ebx,(%esp)
  800841:	e8 c9 f9 ff ff       	call   80020f <runcmd>
			exit();
  800846:	e8 03 02 00 00       	call   800a4e <exit>
  80084b:	e9 26 ff ff ff       	jmp    800776 <umain+0x106>
		} else
			wait(r);
  800850:	89 34 24             	mov    %esi,(%esp)
  800853:	e8 72 2e 00 00       	call   8036ca <wait>
  800858:	e9 19 ff ff ff       	jmp    800776 <umain+0x106>
  80085d:	66 90                	xchg   %ax,%ax
  80085f:	90                   	nop

00800860 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800863:	b8 00 00 00 00       	mov    $0x0,%eax
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800870:	c7 44 24 04 95 3d 80 	movl   $0x803d95,0x4(%esp)
  800877:	00 
  800878:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087b:	89 04 24             	mov    %eax,(%esp)
  80087e:	e8 f4 09 00 00       	call   801277 <strcpy>
	return 0;
}
  800883:	b8 00 00 00 00       	mov    $0x0,%eax
  800888:	c9                   	leave  
  800889:	c3                   	ret    

0080088a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	57                   	push   %edi
  80088e:	56                   	push   %esi
  80088f:	53                   	push   %ebx
  800890:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800896:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80089b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8008a1:	eb 31                	jmp    8008d4 <devcons_write+0x4a>
		m = n - tot;
  8008a3:	8b 75 10             	mov    0x10(%ebp),%esi
  8008a6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8008a8:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8008ab:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8008b0:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8008b3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8008b7:	03 45 0c             	add    0xc(%ebp),%eax
  8008ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008be:	89 3c 24             	mov    %edi,(%esp)
  8008c1:	e8 4e 0b 00 00       	call   801414 <memmove>
		sys_cputs(buf, m);
  8008c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008ca:	89 3c 24             	mov    %edi,(%esp)
  8008cd:	e8 f4 0c 00 00       	call   8015c6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8008d2:	01 f3                	add    %esi,%ebx
  8008d4:	89 d8                	mov    %ebx,%eax
  8008d6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8008d9:	72 c8                	jb     8008a3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8008db:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8008e1:	5b                   	pop    %ebx
  8008e2:	5e                   	pop    %esi
  8008e3:	5f                   	pop    %edi
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8008ec:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8008f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008f5:	75 07                	jne    8008fe <devcons_read+0x18>
  8008f7:	eb 2a                	jmp    800923 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8008f9:	e8 76 0d 00 00       	call   801674 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008fe:	66 90                	xchg   %ax,%ax
  800900:	e8 df 0c 00 00       	call   8015e4 <sys_cgetc>
  800905:	85 c0                	test   %eax,%eax
  800907:	74 f0                	je     8008f9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800909:	85 c0                	test   %eax,%eax
  80090b:	78 16                	js     800923 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80090d:	83 f8 04             	cmp    $0x4,%eax
  800910:	74 0c                	je     80091e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  800912:	8b 55 0c             	mov    0xc(%ebp),%edx
  800915:	88 02                	mov    %al,(%edx)
	return 1;
  800917:	b8 01 00 00 00       	mov    $0x1,%eax
  80091c:	eb 05                	jmp    800923 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80091e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800923:	c9                   	leave  
  800924:	c3                   	ret    

00800925 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800931:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800938:	00 
  800939:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80093c:	89 04 24             	mov    %eax,(%esp)
  80093f:	e8 82 0c 00 00       	call   8015c6 <sys_cputs>
}
  800944:	c9                   	leave  
  800945:	c3                   	ret    

00800946 <getchar>:

int
getchar(void)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80094c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800953:	00 
  800954:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800957:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800962:	e8 d3 17 00 00       	call   80213a <read>
	if (r < 0)
  800967:	85 c0                	test   %eax,%eax
  800969:	78 0f                	js     80097a <getchar+0x34>
		return r;
	if (r < 1)
  80096b:	85 c0                	test   %eax,%eax
  80096d:	7e 06                	jle    800975 <getchar+0x2f>
		return -E_EOF;
	return c;
  80096f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800973:	eb 05                	jmp    80097a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800975:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80097a:	c9                   	leave  
  80097b:	c3                   	ret    

0080097c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800982:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800985:	89 44 24 04          	mov    %eax,0x4(%esp)
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	89 04 24             	mov    %eax,(%esp)
  80098f:	e8 12 15 00 00       	call   801ea6 <fd_lookup>
  800994:	85 c0                	test   %eax,%eax
  800996:	78 11                	js     8009a9 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800998:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099b:	8b 15 00 50 80 00    	mov    0x805000,%edx
  8009a1:	39 10                	cmp    %edx,(%eax)
  8009a3:	0f 94 c0             	sete   %al
  8009a6:	0f b6 c0             	movzbl %al,%eax
}
  8009a9:	c9                   	leave  
  8009aa:	c3                   	ret    

008009ab <opencons>:

int
opencons(void)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8009b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009b4:	89 04 24             	mov    %eax,(%esp)
  8009b7:	e8 9b 14 00 00       	call   801e57 <fd_alloc>
		return r;
  8009bc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8009be:	85 c0                	test   %eax,%eax
  8009c0:	78 40                	js     800a02 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8009c2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8009c9:	00 
  8009ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009d8:	e8 b6 0c 00 00       	call   801693 <sys_page_alloc>
		return r;
  8009dd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8009df:	85 c0                	test   %eax,%eax
  8009e1:	78 1f                	js     800a02 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8009e3:	8b 15 00 50 80 00    	mov    0x805000,%edx
  8009e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009ec:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8009ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009f1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8009f8:	89 04 24             	mov    %eax,(%esp)
  8009fb:	e8 30 14 00 00       	call   801e30 <fd2num>
  800a00:	89 c2                	mov    %eax,%edx
}
  800a02:	89 d0                	mov    %edx,%eax
  800a04:	c9                   	leave  
  800a05:	c3                   	ret    

00800a06 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	56                   	push   %esi
  800a0a:	53                   	push   %ebx
  800a0b:	83 ec 10             	sub    $0x10,%esp
  800a0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a11:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  800a14:	e8 3c 0c 00 00       	call   801655 <sys_getenvid>
  800a19:	25 ff 03 00 00       	and    $0x3ff,%eax
  800a1e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800a21:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800a26:	a3 28 64 80 00       	mov    %eax,0x806428

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800a2b:	85 db                	test   %ebx,%ebx
  800a2d:	7e 07                	jle    800a36 <libmain+0x30>
		binaryname = argv[0];
  800a2f:	8b 06                	mov    (%esi),%eax
  800a31:	a3 1c 50 80 00       	mov    %eax,0x80501c

	// call user main routine
	umain(argc, argv);
  800a36:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a3a:	89 1c 24             	mov    %ebx,(%esp)
  800a3d:	e8 2e fc ff ff       	call   800670 <umain>

	// exit gracefully
	exit();
  800a42:	e8 07 00 00 00       	call   800a4e <exit>
}
  800a47:	83 c4 10             	add    $0x10,%esp
  800a4a:	5b                   	pop    %ebx
  800a4b:	5e                   	pop    %esi
  800a4c:	5d                   	pop    %ebp
  800a4d:	c3                   	ret    

00800a4e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800a54:	e8 b1 15 00 00       	call   80200a <close_all>
	sys_env_destroy(0);
  800a59:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a60:	e8 9e 0b 00 00       	call   801603 <sys_env_destroy>
}
  800a65:	c9                   	leave  
  800a66:	c3                   	ret    

00800a67 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	56                   	push   %esi
  800a6b:	53                   	push   %ebx
  800a6c:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800a6f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a72:	8b 35 1c 50 80 00    	mov    0x80501c,%esi
  800a78:	e8 d8 0b 00 00       	call   801655 <sys_getenvid>
  800a7d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a80:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a84:	8b 55 08             	mov    0x8(%ebp),%edx
  800a87:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a8b:	89 74 24 08          	mov    %esi,0x8(%esp)
  800a8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a93:	c7 04 24 ac 3d 80 00 	movl   $0x803dac,(%esp)
  800a9a:	e8 c1 00 00 00       	call   800b60 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a9f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800aa3:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa6:	89 04 24             	mov    %eax,(%esp)
  800aa9:	e8 51 00 00 00       	call   800aff <vcprintf>
	cprintf("\n");
  800aae:	c7 04 24 c0 3b 80 00 	movl   $0x803bc0,(%esp)
  800ab5:	e8 a6 00 00 00       	call   800b60 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800aba:	cc                   	int3   
  800abb:	eb fd                	jmp    800aba <_panic+0x53>

00800abd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	53                   	push   %ebx
  800ac1:	83 ec 14             	sub    $0x14,%esp
  800ac4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800ac7:	8b 13                	mov    (%ebx),%edx
  800ac9:	8d 42 01             	lea    0x1(%edx),%eax
  800acc:	89 03                	mov    %eax,(%ebx)
  800ace:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800ad5:	3d ff 00 00 00       	cmp    $0xff,%eax
  800ada:	75 19                	jne    800af5 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800adc:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800ae3:	00 
  800ae4:	8d 43 08             	lea    0x8(%ebx),%eax
  800ae7:	89 04 24             	mov    %eax,(%esp)
  800aea:	e8 d7 0a 00 00       	call   8015c6 <sys_cputs>
		b->idx = 0;
  800aef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800af5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800af9:	83 c4 14             	add    $0x14,%esp
  800afc:	5b                   	pop    %ebx
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800b08:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800b0f:	00 00 00 
	b.cnt = 0;
  800b12:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800b19:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800b1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b23:	8b 45 08             	mov    0x8(%ebp),%eax
  800b26:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b2a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800b30:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b34:	c7 04 24 bd 0a 80 00 	movl   $0x800abd,(%esp)
  800b3b:	e8 ae 01 00 00       	call   800cee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800b40:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800b46:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b4a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800b50:	89 04 24             	mov    %eax,(%esp)
  800b53:	e8 6e 0a 00 00       	call   8015c6 <sys_cputs>

	return b.cnt;
}
  800b58:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800b5e:	c9                   	leave  
  800b5f:	c3                   	ret    

00800b60 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800b66:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800b69:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b70:	89 04 24             	mov    %eax,(%esp)
  800b73:	e8 87 ff ff ff       	call   800aff <vcprintf>
	va_end(ap);

	return cnt;
}
  800b78:	c9                   	leave  
  800b79:	c3                   	ret    
  800b7a:	66 90                	xchg   %ax,%ax
  800b7c:	66 90                	xchg   %ax,%ax
  800b7e:	66 90                	xchg   %ax,%ax

00800b80 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	83 ec 3c             	sub    $0x3c,%esp
  800b89:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b8c:	89 d7                	mov    %edx,%edi
  800b8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b91:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b97:	89 c3                	mov    %eax,%ebx
  800b99:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800b9c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b9f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800ba2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800baa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800bad:	39 d9                	cmp    %ebx,%ecx
  800baf:	72 05                	jb     800bb6 <printnum+0x36>
  800bb1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800bb4:	77 69                	ja     800c1f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800bb6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800bb9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800bbd:	83 ee 01             	sub    $0x1,%esi
  800bc0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800bc4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bc8:	8b 44 24 08          	mov    0x8(%esp),%eax
  800bcc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800bd0:	89 c3                	mov    %eax,%ebx
  800bd2:	89 d6                	mov    %edx,%esi
  800bd4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800bd7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800bda:	89 54 24 08          	mov    %edx,0x8(%esp)
  800bde:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800be2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800be5:	89 04 24             	mov    %eax,(%esp)
  800be8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800beb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bef:	e8 0c 2d 00 00       	call   803900 <__udivdi3>
  800bf4:	89 d9                	mov    %ebx,%ecx
  800bf6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800bfa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800bfe:	89 04 24             	mov    %eax,(%esp)
  800c01:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c05:	89 fa                	mov    %edi,%edx
  800c07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c0a:	e8 71 ff ff ff       	call   800b80 <printnum>
  800c0f:	eb 1b                	jmp    800c2c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800c11:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c15:	8b 45 18             	mov    0x18(%ebp),%eax
  800c18:	89 04 24             	mov    %eax,(%esp)
  800c1b:	ff d3                	call   *%ebx
  800c1d:	eb 03                	jmp    800c22 <printnum+0xa2>
  800c1f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800c22:	83 ee 01             	sub    $0x1,%esi
  800c25:	85 f6                	test   %esi,%esi
  800c27:	7f e8                	jg     800c11 <printnum+0x91>
  800c29:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800c2c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c30:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c34:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800c37:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800c3a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c3e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800c42:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c45:	89 04 24             	mov    %eax,(%esp)
  800c48:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800c4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c4f:	e8 dc 2d 00 00       	call   803a30 <__umoddi3>
  800c54:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c58:	0f be 80 cf 3d 80 00 	movsbl 0x803dcf(%eax),%eax
  800c5f:	89 04 24             	mov    %eax,(%esp)
  800c62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c65:	ff d0                	call   *%eax
}
  800c67:	83 c4 3c             	add    $0x3c,%esp
  800c6a:	5b                   	pop    %ebx
  800c6b:	5e                   	pop    %esi
  800c6c:	5f                   	pop    %edi
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800c72:	83 fa 01             	cmp    $0x1,%edx
  800c75:	7e 0e                	jle    800c85 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800c77:	8b 10                	mov    (%eax),%edx
  800c79:	8d 4a 08             	lea    0x8(%edx),%ecx
  800c7c:	89 08                	mov    %ecx,(%eax)
  800c7e:	8b 02                	mov    (%edx),%eax
  800c80:	8b 52 04             	mov    0x4(%edx),%edx
  800c83:	eb 22                	jmp    800ca7 <getuint+0x38>
	else if (lflag)
  800c85:	85 d2                	test   %edx,%edx
  800c87:	74 10                	je     800c99 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800c89:	8b 10                	mov    (%eax),%edx
  800c8b:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c8e:	89 08                	mov    %ecx,(%eax)
  800c90:	8b 02                	mov    (%edx),%eax
  800c92:	ba 00 00 00 00       	mov    $0x0,%edx
  800c97:	eb 0e                	jmp    800ca7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800c99:	8b 10                	mov    (%eax),%edx
  800c9b:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c9e:	89 08                	mov    %ecx,(%eax)
  800ca0:	8b 02                	mov    (%edx),%eax
  800ca2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800caf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800cb3:	8b 10                	mov    (%eax),%edx
  800cb5:	3b 50 04             	cmp    0x4(%eax),%edx
  800cb8:	73 0a                	jae    800cc4 <sprintputch+0x1b>
		*b->buf++ = ch;
  800cba:	8d 4a 01             	lea    0x1(%edx),%ecx
  800cbd:	89 08                	mov    %ecx,(%eax)
  800cbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc2:	88 02                	mov    %al,(%edx)
}
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800ccc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800ccf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cd3:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cdd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ce1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce4:	89 04 24             	mov    %eax,(%esp)
  800ce7:	e8 02 00 00 00       	call   800cee <vprintfmt>
	va_end(ap);
}
  800cec:	c9                   	leave  
  800ced:	c3                   	ret    

00800cee <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
  800cf4:	83 ec 3c             	sub    $0x3c,%esp
  800cf7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800cfa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfd:	eb 14                	jmp    800d13 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800cff:	85 c0                	test   %eax,%eax
  800d01:	0f 84 b3 03 00 00    	je     8010ba <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800d07:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d0b:	89 04 24             	mov    %eax,(%esp)
  800d0e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800d11:	89 f3                	mov    %esi,%ebx
  800d13:	8d 73 01             	lea    0x1(%ebx),%esi
  800d16:	0f b6 03             	movzbl (%ebx),%eax
  800d19:	83 f8 25             	cmp    $0x25,%eax
  800d1c:	75 e1                	jne    800cff <vprintfmt+0x11>
  800d1e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800d22:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800d29:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800d30:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800d37:	ba 00 00 00 00       	mov    $0x0,%edx
  800d3c:	eb 1d                	jmp    800d5b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d3e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800d40:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800d44:	eb 15                	jmp    800d5b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d46:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800d48:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800d4c:	eb 0d                	jmp    800d5b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800d4e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800d51:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800d54:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d5b:	8d 5e 01             	lea    0x1(%esi),%ebx
  800d5e:	0f b6 0e             	movzbl (%esi),%ecx
  800d61:	0f b6 c1             	movzbl %cl,%eax
  800d64:	83 e9 23             	sub    $0x23,%ecx
  800d67:	80 f9 55             	cmp    $0x55,%cl
  800d6a:	0f 87 2a 03 00 00    	ja     80109a <vprintfmt+0x3ac>
  800d70:	0f b6 c9             	movzbl %cl,%ecx
  800d73:	ff 24 8d 20 3f 80 00 	jmp    *0x803f20(,%ecx,4)
  800d7a:	89 de                	mov    %ebx,%esi
  800d7c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800d81:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800d84:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800d88:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800d8b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800d8e:	83 fb 09             	cmp    $0x9,%ebx
  800d91:	77 36                	ja     800dc9 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800d93:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800d96:	eb e9                	jmp    800d81 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800d98:	8b 45 14             	mov    0x14(%ebp),%eax
  800d9b:	8d 48 04             	lea    0x4(%eax),%ecx
  800d9e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800da1:	8b 00                	mov    (%eax),%eax
  800da3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800da6:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800da8:	eb 22                	jmp    800dcc <vprintfmt+0xde>
  800daa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800dad:	85 c9                	test   %ecx,%ecx
  800daf:	b8 00 00 00 00       	mov    $0x0,%eax
  800db4:	0f 49 c1             	cmovns %ecx,%eax
  800db7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dba:	89 de                	mov    %ebx,%esi
  800dbc:	eb 9d                	jmp    800d5b <vprintfmt+0x6d>
  800dbe:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800dc0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800dc7:	eb 92                	jmp    800d5b <vprintfmt+0x6d>
  800dc9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  800dcc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800dd0:	79 89                	jns    800d5b <vprintfmt+0x6d>
  800dd2:	e9 77 ff ff ff       	jmp    800d4e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800dd7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dda:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800ddc:	e9 7a ff ff ff       	jmp    800d5b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800de1:	8b 45 14             	mov    0x14(%ebp),%eax
  800de4:	8d 50 04             	lea    0x4(%eax),%edx
  800de7:	89 55 14             	mov    %edx,0x14(%ebp)
  800dea:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800dee:	8b 00                	mov    (%eax),%eax
  800df0:	89 04 24             	mov    %eax,(%esp)
  800df3:	ff 55 08             	call   *0x8(%ebp)
			break;
  800df6:	e9 18 ff ff ff       	jmp    800d13 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800dfb:	8b 45 14             	mov    0x14(%ebp),%eax
  800dfe:	8d 50 04             	lea    0x4(%eax),%edx
  800e01:	89 55 14             	mov    %edx,0x14(%ebp)
  800e04:	8b 00                	mov    (%eax),%eax
  800e06:	99                   	cltd   
  800e07:	31 d0                	xor    %edx,%eax
  800e09:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800e0b:	83 f8 0f             	cmp    $0xf,%eax
  800e0e:	7f 0b                	jg     800e1b <vprintfmt+0x12d>
  800e10:	8b 14 85 80 40 80 00 	mov    0x804080(,%eax,4),%edx
  800e17:	85 d2                	test   %edx,%edx
  800e19:	75 20                	jne    800e3b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  800e1b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e1f:	c7 44 24 08 e7 3d 80 	movl   $0x803de7,0x8(%esp)
  800e26:	00 
  800e27:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2e:	89 04 24             	mov    %eax,(%esp)
  800e31:	e8 90 fe ff ff       	call   800cc6 <printfmt>
  800e36:	e9 d8 fe ff ff       	jmp    800d13 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800e3b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e3f:	c7 44 24 08 ef 3c 80 	movl   $0x803cef,0x8(%esp)
  800e46:	00 
  800e47:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4e:	89 04 24             	mov    %eax,(%esp)
  800e51:	e8 70 fe ff ff       	call   800cc6 <printfmt>
  800e56:	e9 b8 fe ff ff       	jmp    800d13 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e5b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800e5e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800e61:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800e64:	8b 45 14             	mov    0x14(%ebp),%eax
  800e67:	8d 50 04             	lea    0x4(%eax),%edx
  800e6a:	89 55 14             	mov    %edx,0x14(%ebp)
  800e6d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800e6f:	85 f6                	test   %esi,%esi
  800e71:	b8 e0 3d 80 00       	mov    $0x803de0,%eax
  800e76:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800e79:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800e7d:	0f 84 97 00 00 00    	je     800f1a <vprintfmt+0x22c>
  800e83:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800e87:	0f 8e 9b 00 00 00    	jle    800f28 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800e8d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e91:	89 34 24             	mov    %esi,(%esp)
  800e94:	e8 bf 03 00 00       	call   801258 <strnlen>
  800e99:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800e9c:	29 c2                	sub    %eax,%edx
  800e9e:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800ea1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800ea5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800ea8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800eab:	8b 75 08             	mov    0x8(%ebp),%esi
  800eae:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800eb1:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800eb3:	eb 0f                	jmp    800ec4 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800eb5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800eb9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ebc:	89 04 24             	mov    %eax,(%esp)
  800ebf:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800ec1:	83 eb 01             	sub    $0x1,%ebx
  800ec4:	85 db                	test   %ebx,%ebx
  800ec6:	7f ed                	jg     800eb5 <vprintfmt+0x1c7>
  800ec8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800ecb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800ece:	85 d2                	test   %edx,%edx
  800ed0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed5:	0f 49 c2             	cmovns %edx,%eax
  800ed8:	29 c2                	sub    %eax,%edx
  800eda:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800edd:	89 d7                	mov    %edx,%edi
  800edf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800ee2:	eb 50                	jmp    800f34 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800ee4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ee8:	74 1e                	je     800f08 <vprintfmt+0x21a>
  800eea:	0f be d2             	movsbl %dl,%edx
  800eed:	83 ea 20             	sub    $0x20,%edx
  800ef0:	83 fa 5e             	cmp    $0x5e,%edx
  800ef3:	76 13                	jbe    800f08 <vprintfmt+0x21a>
					putch('?', putdat);
  800ef5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800efc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800f03:	ff 55 08             	call   *0x8(%ebp)
  800f06:	eb 0d                	jmp    800f15 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800f08:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f0b:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f0f:	89 04 24             	mov    %eax,(%esp)
  800f12:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800f15:	83 ef 01             	sub    $0x1,%edi
  800f18:	eb 1a                	jmp    800f34 <vprintfmt+0x246>
  800f1a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800f1d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800f20:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800f23:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800f26:	eb 0c                	jmp    800f34 <vprintfmt+0x246>
  800f28:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800f2b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800f2e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800f31:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800f34:	83 c6 01             	add    $0x1,%esi
  800f37:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800f3b:	0f be c2             	movsbl %dl,%eax
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	74 27                	je     800f69 <vprintfmt+0x27b>
  800f42:	85 db                	test   %ebx,%ebx
  800f44:	78 9e                	js     800ee4 <vprintfmt+0x1f6>
  800f46:	83 eb 01             	sub    $0x1,%ebx
  800f49:	79 99                	jns    800ee4 <vprintfmt+0x1f6>
  800f4b:	89 f8                	mov    %edi,%eax
  800f4d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f50:	8b 75 08             	mov    0x8(%ebp),%esi
  800f53:	89 c3                	mov    %eax,%ebx
  800f55:	eb 1a                	jmp    800f71 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800f57:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f5b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800f62:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800f64:	83 eb 01             	sub    $0x1,%ebx
  800f67:	eb 08                	jmp    800f71 <vprintfmt+0x283>
  800f69:	89 fb                	mov    %edi,%ebx
  800f6b:	8b 75 08             	mov    0x8(%ebp),%esi
  800f6e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f71:	85 db                	test   %ebx,%ebx
  800f73:	7f e2                	jg     800f57 <vprintfmt+0x269>
  800f75:	89 75 08             	mov    %esi,0x8(%ebp)
  800f78:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f7b:	e9 93 fd ff ff       	jmp    800d13 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800f80:	83 fa 01             	cmp    $0x1,%edx
  800f83:	7e 16                	jle    800f9b <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800f85:	8b 45 14             	mov    0x14(%ebp),%eax
  800f88:	8d 50 08             	lea    0x8(%eax),%edx
  800f8b:	89 55 14             	mov    %edx,0x14(%ebp)
  800f8e:	8b 50 04             	mov    0x4(%eax),%edx
  800f91:	8b 00                	mov    (%eax),%eax
  800f93:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f96:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800f99:	eb 32                	jmp    800fcd <vprintfmt+0x2df>
	else if (lflag)
  800f9b:	85 d2                	test   %edx,%edx
  800f9d:	74 18                	je     800fb7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  800f9f:	8b 45 14             	mov    0x14(%ebp),%eax
  800fa2:	8d 50 04             	lea    0x4(%eax),%edx
  800fa5:	89 55 14             	mov    %edx,0x14(%ebp)
  800fa8:	8b 30                	mov    (%eax),%esi
  800faa:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800fad:	89 f0                	mov    %esi,%eax
  800faf:	c1 f8 1f             	sar    $0x1f,%eax
  800fb2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fb5:	eb 16                	jmp    800fcd <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800fb7:	8b 45 14             	mov    0x14(%ebp),%eax
  800fba:	8d 50 04             	lea    0x4(%eax),%edx
  800fbd:	89 55 14             	mov    %edx,0x14(%ebp)
  800fc0:	8b 30                	mov    (%eax),%esi
  800fc2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800fc5:	89 f0                	mov    %esi,%eax
  800fc7:	c1 f8 1f             	sar    $0x1f,%eax
  800fca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800fcd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fd0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800fd3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800fd8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fdc:	0f 89 80 00 00 00    	jns    801062 <vprintfmt+0x374>
				putch('-', putdat);
  800fe2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fe6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800fed:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800ff0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ff3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ff6:	f7 d8                	neg    %eax
  800ff8:	83 d2 00             	adc    $0x0,%edx
  800ffb:	f7 da                	neg    %edx
			}
			base = 10;
  800ffd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801002:	eb 5e                	jmp    801062 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801004:	8d 45 14             	lea    0x14(%ebp),%eax
  801007:	e8 63 fc ff ff       	call   800c6f <getuint>
			base = 10;
  80100c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801011:	eb 4f                	jmp    801062 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  801013:	8d 45 14             	lea    0x14(%ebp),%eax
  801016:	e8 54 fc ff ff       	call   800c6f <getuint>
			base = 8;
  80101b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801020:	eb 40                	jmp    801062 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  801022:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801026:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80102d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801030:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801034:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80103b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80103e:	8b 45 14             	mov    0x14(%ebp),%eax
  801041:	8d 50 04             	lea    0x4(%eax),%edx
  801044:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801047:	8b 00                	mov    (%eax),%eax
  801049:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80104e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801053:	eb 0d                	jmp    801062 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801055:	8d 45 14             	lea    0x14(%ebp),%eax
  801058:	e8 12 fc ff ff       	call   800c6f <getuint>
			base = 16;
  80105d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801062:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  801066:	89 74 24 10          	mov    %esi,0x10(%esp)
  80106a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80106d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801071:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801075:	89 04 24             	mov    %eax,(%esp)
  801078:	89 54 24 04          	mov    %edx,0x4(%esp)
  80107c:	89 fa                	mov    %edi,%edx
  80107e:	8b 45 08             	mov    0x8(%ebp),%eax
  801081:	e8 fa fa ff ff       	call   800b80 <printnum>
			break;
  801086:	e9 88 fc ff ff       	jmp    800d13 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80108b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80108f:	89 04 24             	mov    %eax,(%esp)
  801092:	ff 55 08             	call   *0x8(%ebp)
			break;
  801095:	e9 79 fc ff ff       	jmp    800d13 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80109a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80109e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8010a5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8010a8:	89 f3                	mov    %esi,%ebx
  8010aa:	eb 03                	jmp    8010af <vprintfmt+0x3c1>
  8010ac:	83 eb 01             	sub    $0x1,%ebx
  8010af:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8010b3:	75 f7                	jne    8010ac <vprintfmt+0x3be>
  8010b5:	e9 59 fc ff ff       	jmp    800d13 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8010ba:	83 c4 3c             	add    $0x3c,%esp
  8010bd:	5b                   	pop    %ebx
  8010be:	5e                   	pop    %esi
  8010bf:	5f                   	pop    %edi
  8010c0:	5d                   	pop    %ebp
  8010c1:	c3                   	ret    

008010c2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
  8010c5:	83 ec 28             	sub    $0x28,%esp
  8010c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8010ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8010d1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8010d5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8010d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8010df:	85 c0                	test   %eax,%eax
  8010e1:	74 30                	je     801113 <vsnprintf+0x51>
  8010e3:	85 d2                	test   %edx,%edx
  8010e5:	7e 2c                	jle    801113 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8010e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8010ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8010f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010f5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8010f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010fc:	c7 04 24 a9 0c 80 00 	movl   $0x800ca9,(%esp)
  801103:	e8 e6 fb ff ff       	call   800cee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801108:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80110b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80110e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801111:	eb 05                	jmp    801118 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801113:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801118:	c9                   	leave  
  801119:	c3                   	ret    

0080111a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801120:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801123:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801127:	8b 45 10             	mov    0x10(%ebp),%eax
  80112a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80112e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801131:	89 44 24 04          	mov    %eax,0x4(%esp)
  801135:	8b 45 08             	mov    0x8(%ebp),%eax
  801138:	89 04 24             	mov    %eax,(%esp)
  80113b:	e8 82 ff ff ff       	call   8010c2 <vsnprintf>
	va_end(ap);

	return rc;
}
  801140:	c9                   	leave  
  801141:	c3                   	ret    
  801142:	66 90                	xchg   %ax,%ax
  801144:	66 90                	xchg   %ax,%ax
  801146:	66 90                	xchg   %ax,%ax
  801148:	66 90                	xchg   %ax,%ax
  80114a:	66 90                	xchg   %ax,%ax
  80114c:	66 90                	xchg   %ax,%ax
  80114e:	66 90                	xchg   %ax,%ax

00801150 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	57                   	push   %edi
  801154:	56                   	push   %esi
  801155:	53                   	push   %ebx
  801156:	83 ec 1c             	sub    $0x1c,%esp
  801159:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  80115c:	85 c0                	test   %eax,%eax
  80115e:	74 18                	je     801178 <readline+0x28>
		fprintf(1, "%s", prompt);
  801160:	89 44 24 08          	mov    %eax,0x8(%esp)
  801164:	c7 44 24 04 ef 3c 80 	movl   $0x803cef,0x4(%esp)
  80116b:	00 
  80116c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801173:	e8 2a 16 00 00       	call   8027a2 <fprintf>
#endif

	i = 0;
	echoing = iscons(0);
  801178:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80117f:	e8 f8 f7 ff ff       	call   80097c <iscons>
  801184:	89 c7                	mov    %eax,%edi
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  801186:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  80118b:	e8 b6 f7 ff ff       	call   800946 <getchar>
  801190:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  801192:	85 c0                	test   %eax,%eax
  801194:	79 25                	jns    8011bb <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  801196:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  80119b:	83 fb f8             	cmp    $0xfffffff8,%ebx
  80119e:	0f 84 88 00 00 00    	je     80122c <readline+0xdc>
				cprintf("read error: %e\n", c);
  8011a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011a8:	c7 04 24 df 40 80 00 	movl   $0x8040df,(%esp)
  8011af:	e8 ac f9 ff ff       	call   800b60 <cprintf>
			return NULL;
  8011b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b9:	eb 71                	jmp    80122c <readline+0xdc>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8011bb:	83 f8 7f             	cmp    $0x7f,%eax
  8011be:	74 05                	je     8011c5 <readline+0x75>
  8011c0:	83 f8 08             	cmp    $0x8,%eax
  8011c3:	75 19                	jne    8011de <readline+0x8e>
  8011c5:	85 f6                	test   %esi,%esi
  8011c7:	7e 15                	jle    8011de <readline+0x8e>
			if (echoing)
  8011c9:	85 ff                	test   %edi,%edi
  8011cb:	74 0c                	je     8011d9 <readline+0x89>
				cputchar('\b');
  8011cd:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  8011d4:	e8 4c f7 ff ff       	call   800925 <cputchar>
			i--;
  8011d9:	83 ee 01             	sub    $0x1,%esi
  8011dc:	eb ad                	jmp    80118b <readline+0x3b>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8011de:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8011e4:	7f 1c                	jg     801202 <readline+0xb2>
  8011e6:	83 fb 1f             	cmp    $0x1f,%ebx
  8011e9:	7e 17                	jle    801202 <readline+0xb2>
			if (echoing)
  8011eb:	85 ff                	test   %edi,%edi
  8011ed:	74 08                	je     8011f7 <readline+0xa7>
				cputchar(c);
  8011ef:	89 1c 24             	mov    %ebx,(%esp)
  8011f2:	e8 2e f7 ff ff       	call   800925 <cputchar>
			buf[i++] = c;
  8011f7:	88 9e 20 60 80 00    	mov    %bl,0x806020(%esi)
  8011fd:	8d 76 01             	lea    0x1(%esi),%esi
  801200:	eb 89                	jmp    80118b <readline+0x3b>
		} else if (c == '\n' || c == '\r') {
  801202:	83 fb 0d             	cmp    $0xd,%ebx
  801205:	74 09                	je     801210 <readline+0xc0>
  801207:	83 fb 0a             	cmp    $0xa,%ebx
  80120a:	0f 85 7b ff ff ff    	jne    80118b <readline+0x3b>
			if (echoing)
  801210:	85 ff                	test   %edi,%edi
  801212:	74 0c                	je     801220 <readline+0xd0>
				cputchar('\n');
  801214:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80121b:	e8 05 f7 ff ff       	call   800925 <cputchar>
			buf[i] = 0;
  801220:	c6 86 20 60 80 00 00 	movb   $0x0,0x806020(%esi)
			return buf;
  801227:	b8 20 60 80 00       	mov    $0x806020,%eax
		}
	}
}
  80122c:	83 c4 1c             	add    $0x1c,%esp
  80122f:	5b                   	pop    %ebx
  801230:	5e                   	pop    %esi
  801231:	5f                   	pop    %edi
  801232:	5d                   	pop    %ebp
  801233:	c3                   	ret    
  801234:	66 90                	xchg   %ax,%ax
  801236:	66 90                	xchg   %ax,%ax
  801238:	66 90                	xchg   %ax,%ax
  80123a:	66 90                	xchg   %ax,%ax
  80123c:	66 90                	xchg   %ax,%ax
  80123e:	66 90                	xchg   %ax,%ax

00801240 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801246:	b8 00 00 00 00       	mov    $0x0,%eax
  80124b:	eb 03                	jmp    801250 <strlen+0x10>
		n++;
  80124d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801250:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801254:	75 f7                	jne    80124d <strlen+0xd>
		n++;
	return n;
}
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    

00801258 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80125e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801261:	b8 00 00 00 00       	mov    $0x0,%eax
  801266:	eb 03                	jmp    80126b <strnlen+0x13>
		n++;
  801268:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80126b:	39 d0                	cmp    %edx,%eax
  80126d:	74 06                	je     801275 <strnlen+0x1d>
  80126f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801273:	75 f3                	jne    801268 <strnlen+0x10>
		n++;
	return n;
}
  801275:	5d                   	pop    %ebp
  801276:	c3                   	ret    

00801277 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	53                   	push   %ebx
  80127b:	8b 45 08             	mov    0x8(%ebp),%eax
  80127e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801281:	89 c2                	mov    %eax,%edx
  801283:	83 c2 01             	add    $0x1,%edx
  801286:	83 c1 01             	add    $0x1,%ecx
  801289:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80128d:	88 5a ff             	mov    %bl,-0x1(%edx)
  801290:	84 db                	test   %bl,%bl
  801292:	75 ef                	jne    801283 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801294:	5b                   	pop    %ebx
  801295:	5d                   	pop    %ebp
  801296:	c3                   	ret    

00801297 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
  80129a:	53                   	push   %ebx
  80129b:	83 ec 08             	sub    $0x8,%esp
  80129e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8012a1:	89 1c 24             	mov    %ebx,(%esp)
  8012a4:	e8 97 ff ff ff       	call   801240 <strlen>
	strcpy(dst + len, src);
  8012a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012b0:	01 d8                	add    %ebx,%eax
  8012b2:	89 04 24             	mov    %eax,(%esp)
  8012b5:	e8 bd ff ff ff       	call   801277 <strcpy>
	return dst;
}
  8012ba:	89 d8                	mov    %ebx,%eax
  8012bc:	83 c4 08             	add    $0x8,%esp
  8012bf:	5b                   	pop    %ebx
  8012c0:	5d                   	pop    %ebp
  8012c1:	c3                   	ret    

008012c2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8012c2:	55                   	push   %ebp
  8012c3:	89 e5                	mov    %esp,%ebp
  8012c5:	56                   	push   %esi
  8012c6:	53                   	push   %ebx
  8012c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8012ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012cd:	89 f3                	mov    %esi,%ebx
  8012cf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8012d2:	89 f2                	mov    %esi,%edx
  8012d4:	eb 0f                	jmp    8012e5 <strncpy+0x23>
		*dst++ = *src;
  8012d6:	83 c2 01             	add    $0x1,%edx
  8012d9:	0f b6 01             	movzbl (%ecx),%eax
  8012dc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8012df:	80 39 01             	cmpb   $0x1,(%ecx)
  8012e2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8012e5:	39 da                	cmp    %ebx,%edx
  8012e7:	75 ed                	jne    8012d6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8012e9:	89 f0                	mov    %esi,%eax
  8012eb:	5b                   	pop    %ebx
  8012ec:	5e                   	pop    %esi
  8012ed:	5d                   	pop    %ebp
  8012ee:	c3                   	ret    

008012ef <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8012ef:	55                   	push   %ebp
  8012f0:	89 e5                	mov    %esp,%ebp
  8012f2:	56                   	push   %esi
  8012f3:	53                   	push   %ebx
  8012f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8012f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012fd:	89 f0                	mov    %esi,%eax
  8012ff:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801303:	85 c9                	test   %ecx,%ecx
  801305:	75 0b                	jne    801312 <strlcpy+0x23>
  801307:	eb 1d                	jmp    801326 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801309:	83 c0 01             	add    $0x1,%eax
  80130c:	83 c2 01             	add    $0x1,%edx
  80130f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801312:	39 d8                	cmp    %ebx,%eax
  801314:	74 0b                	je     801321 <strlcpy+0x32>
  801316:	0f b6 0a             	movzbl (%edx),%ecx
  801319:	84 c9                	test   %cl,%cl
  80131b:	75 ec                	jne    801309 <strlcpy+0x1a>
  80131d:	89 c2                	mov    %eax,%edx
  80131f:	eb 02                	jmp    801323 <strlcpy+0x34>
  801321:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801323:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801326:	29 f0                	sub    %esi,%eax
}
  801328:	5b                   	pop    %ebx
  801329:	5e                   	pop    %esi
  80132a:	5d                   	pop    %ebp
  80132b:	c3                   	ret    

0080132c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
  80132f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801332:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801335:	eb 06                	jmp    80133d <strcmp+0x11>
		p++, q++;
  801337:	83 c1 01             	add    $0x1,%ecx
  80133a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80133d:	0f b6 01             	movzbl (%ecx),%eax
  801340:	84 c0                	test   %al,%al
  801342:	74 04                	je     801348 <strcmp+0x1c>
  801344:	3a 02                	cmp    (%edx),%al
  801346:	74 ef                	je     801337 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801348:	0f b6 c0             	movzbl %al,%eax
  80134b:	0f b6 12             	movzbl (%edx),%edx
  80134e:	29 d0                	sub    %edx,%eax
}
  801350:	5d                   	pop    %ebp
  801351:	c3                   	ret    

00801352 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801352:	55                   	push   %ebp
  801353:	89 e5                	mov    %esp,%ebp
  801355:	53                   	push   %ebx
  801356:	8b 45 08             	mov    0x8(%ebp),%eax
  801359:	8b 55 0c             	mov    0xc(%ebp),%edx
  80135c:	89 c3                	mov    %eax,%ebx
  80135e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801361:	eb 06                	jmp    801369 <strncmp+0x17>
		n--, p++, q++;
  801363:	83 c0 01             	add    $0x1,%eax
  801366:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801369:	39 d8                	cmp    %ebx,%eax
  80136b:	74 15                	je     801382 <strncmp+0x30>
  80136d:	0f b6 08             	movzbl (%eax),%ecx
  801370:	84 c9                	test   %cl,%cl
  801372:	74 04                	je     801378 <strncmp+0x26>
  801374:	3a 0a                	cmp    (%edx),%cl
  801376:	74 eb                	je     801363 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801378:	0f b6 00             	movzbl (%eax),%eax
  80137b:	0f b6 12             	movzbl (%edx),%edx
  80137e:	29 d0                	sub    %edx,%eax
  801380:	eb 05                	jmp    801387 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801382:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801387:	5b                   	pop    %ebx
  801388:	5d                   	pop    %ebp
  801389:	c3                   	ret    

0080138a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
  80138d:	8b 45 08             	mov    0x8(%ebp),%eax
  801390:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801394:	eb 07                	jmp    80139d <strchr+0x13>
		if (*s == c)
  801396:	38 ca                	cmp    %cl,%dl
  801398:	74 0f                	je     8013a9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80139a:	83 c0 01             	add    $0x1,%eax
  80139d:	0f b6 10             	movzbl (%eax),%edx
  8013a0:	84 d2                	test   %dl,%dl
  8013a2:	75 f2                	jne    801396 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8013a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013a9:	5d                   	pop    %ebp
  8013aa:	c3                   	ret    

008013ab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
  8013ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8013b5:	eb 07                	jmp    8013be <strfind+0x13>
		if (*s == c)
  8013b7:	38 ca                	cmp    %cl,%dl
  8013b9:	74 0a                	je     8013c5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8013bb:	83 c0 01             	add    $0x1,%eax
  8013be:	0f b6 10             	movzbl (%eax),%edx
  8013c1:	84 d2                	test   %dl,%dl
  8013c3:	75 f2                	jne    8013b7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8013c5:	5d                   	pop    %ebp
  8013c6:	c3                   	ret    

008013c7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8013c7:	55                   	push   %ebp
  8013c8:	89 e5                	mov    %esp,%ebp
  8013ca:	57                   	push   %edi
  8013cb:	56                   	push   %esi
  8013cc:	53                   	push   %ebx
  8013cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8013d3:	85 c9                	test   %ecx,%ecx
  8013d5:	74 36                	je     80140d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8013d7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8013dd:	75 28                	jne    801407 <memset+0x40>
  8013df:	f6 c1 03             	test   $0x3,%cl
  8013e2:	75 23                	jne    801407 <memset+0x40>
		c &= 0xFF;
  8013e4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8013e8:	89 d3                	mov    %edx,%ebx
  8013ea:	c1 e3 08             	shl    $0x8,%ebx
  8013ed:	89 d6                	mov    %edx,%esi
  8013ef:	c1 e6 18             	shl    $0x18,%esi
  8013f2:	89 d0                	mov    %edx,%eax
  8013f4:	c1 e0 10             	shl    $0x10,%eax
  8013f7:	09 f0                	or     %esi,%eax
  8013f9:	09 c2                	or     %eax,%edx
  8013fb:	89 d0                	mov    %edx,%eax
  8013fd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8013ff:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801402:	fc                   	cld    
  801403:	f3 ab                	rep stos %eax,%es:(%edi)
  801405:	eb 06                	jmp    80140d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801407:	8b 45 0c             	mov    0xc(%ebp),%eax
  80140a:	fc                   	cld    
  80140b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80140d:	89 f8                	mov    %edi,%eax
  80140f:	5b                   	pop    %ebx
  801410:	5e                   	pop    %esi
  801411:	5f                   	pop    %edi
  801412:	5d                   	pop    %ebp
  801413:	c3                   	ret    

00801414 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	57                   	push   %edi
  801418:	56                   	push   %esi
  801419:	8b 45 08             	mov    0x8(%ebp),%eax
  80141c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80141f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801422:	39 c6                	cmp    %eax,%esi
  801424:	73 35                	jae    80145b <memmove+0x47>
  801426:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801429:	39 d0                	cmp    %edx,%eax
  80142b:	73 2e                	jae    80145b <memmove+0x47>
		s += n;
		d += n;
  80142d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801430:	89 d6                	mov    %edx,%esi
  801432:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801434:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80143a:	75 13                	jne    80144f <memmove+0x3b>
  80143c:	f6 c1 03             	test   $0x3,%cl
  80143f:	75 0e                	jne    80144f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801441:	83 ef 04             	sub    $0x4,%edi
  801444:	8d 72 fc             	lea    -0x4(%edx),%esi
  801447:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80144a:	fd                   	std    
  80144b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80144d:	eb 09                	jmp    801458 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80144f:	83 ef 01             	sub    $0x1,%edi
  801452:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801455:	fd                   	std    
  801456:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801458:	fc                   	cld    
  801459:	eb 1d                	jmp    801478 <memmove+0x64>
  80145b:	89 f2                	mov    %esi,%edx
  80145d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80145f:	f6 c2 03             	test   $0x3,%dl
  801462:	75 0f                	jne    801473 <memmove+0x5f>
  801464:	f6 c1 03             	test   $0x3,%cl
  801467:	75 0a                	jne    801473 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801469:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80146c:	89 c7                	mov    %eax,%edi
  80146e:	fc                   	cld    
  80146f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801471:	eb 05                	jmp    801478 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801473:	89 c7                	mov    %eax,%edi
  801475:	fc                   	cld    
  801476:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801478:	5e                   	pop    %esi
  801479:	5f                   	pop    %edi
  80147a:	5d                   	pop    %ebp
  80147b:	c3                   	ret    

0080147c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801482:	8b 45 10             	mov    0x10(%ebp),%eax
  801485:	89 44 24 08          	mov    %eax,0x8(%esp)
  801489:	8b 45 0c             	mov    0xc(%ebp),%eax
  80148c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801490:	8b 45 08             	mov    0x8(%ebp),%eax
  801493:	89 04 24             	mov    %eax,(%esp)
  801496:	e8 79 ff ff ff       	call   801414 <memmove>
}
  80149b:	c9                   	leave  
  80149c:	c3                   	ret    

0080149d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80149d:	55                   	push   %ebp
  80149e:	89 e5                	mov    %esp,%ebp
  8014a0:	56                   	push   %esi
  8014a1:	53                   	push   %ebx
  8014a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8014a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014a8:	89 d6                	mov    %edx,%esi
  8014aa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8014ad:	eb 1a                	jmp    8014c9 <memcmp+0x2c>
		if (*s1 != *s2)
  8014af:	0f b6 02             	movzbl (%edx),%eax
  8014b2:	0f b6 19             	movzbl (%ecx),%ebx
  8014b5:	38 d8                	cmp    %bl,%al
  8014b7:	74 0a                	je     8014c3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8014b9:	0f b6 c0             	movzbl %al,%eax
  8014bc:	0f b6 db             	movzbl %bl,%ebx
  8014bf:	29 d8                	sub    %ebx,%eax
  8014c1:	eb 0f                	jmp    8014d2 <memcmp+0x35>
		s1++, s2++;
  8014c3:	83 c2 01             	add    $0x1,%edx
  8014c6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8014c9:	39 f2                	cmp    %esi,%edx
  8014cb:	75 e2                	jne    8014af <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8014cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014d2:	5b                   	pop    %ebx
  8014d3:	5e                   	pop    %esi
  8014d4:	5d                   	pop    %ebp
  8014d5:	c3                   	ret    

008014d6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8014d6:	55                   	push   %ebp
  8014d7:	89 e5                	mov    %esp,%ebp
  8014d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8014df:	89 c2                	mov    %eax,%edx
  8014e1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8014e4:	eb 07                	jmp    8014ed <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8014e6:	38 08                	cmp    %cl,(%eax)
  8014e8:	74 07                	je     8014f1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8014ea:	83 c0 01             	add    $0x1,%eax
  8014ed:	39 d0                	cmp    %edx,%eax
  8014ef:	72 f5                	jb     8014e6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8014f1:	5d                   	pop    %ebp
  8014f2:	c3                   	ret    

008014f3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8014f3:	55                   	push   %ebp
  8014f4:	89 e5                	mov    %esp,%ebp
  8014f6:	57                   	push   %edi
  8014f7:	56                   	push   %esi
  8014f8:	53                   	push   %ebx
  8014f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8014fc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8014ff:	eb 03                	jmp    801504 <strtol+0x11>
		s++;
  801501:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801504:	0f b6 0a             	movzbl (%edx),%ecx
  801507:	80 f9 09             	cmp    $0x9,%cl
  80150a:	74 f5                	je     801501 <strtol+0xe>
  80150c:	80 f9 20             	cmp    $0x20,%cl
  80150f:	74 f0                	je     801501 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801511:	80 f9 2b             	cmp    $0x2b,%cl
  801514:	75 0a                	jne    801520 <strtol+0x2d>
		s++;
  801516:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801519:	bf 00 00 00 00       	mov    $0x0,%edi
  80151e:	eb 11                	jmp    801531 <strtol+0x3e>
  801520:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801525:	80 f9 2d             	cmp    $0x2d,%cl
  801528:	75 07                	jne    801531 <strtol+0x3e>
		s++, neg = 1;
  80152a:	8d 52 01             	lea    0x1(%edx),%edx
  80152d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801531:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801536:	75 15                	jne    80154d <strtol+0x5a>
  801538:	80 3a 30             	cmpb   $0x30,(%edx)
  80153b:	75 10                	jne    80154d <strtol+0x5a>
  80153d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801541:	75 0a                	jne    80154d <strtol+0x5a>
		s += 2, base = 16;
  801543:	83 c2 02             	add    $0x2,%edx
  801546:	b8 10 00 00 00       	mov    $0x10,%eax
  80154b:	eb 10                	jmp    80155d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  80154d:	85 c0                	test   %eax,%eax
  80154f:	75 0c                	jne    80155d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801551:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801553:	80 3a 30             	cmpb   $0x30,(%edx)
  801556:	75 05                	jne    80155d <strtol+0x6a>
		s++, base = 8;
  801558:	83 c2 01             	add    $0x1,%edx
  80155b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  80155d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801562:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801565:	0f b6 0a             	movzbl (%edx),%ecx
  801568:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80156b:	89 f0                	mov    %esi,%eax
  80156d:	3c 09                	cmp    $0x9,%al
  80156f:	77 08                	ja     801579 <strtol+0x86>
			dig = *s - '0';
  801571:	0f be c9             	movsbl %cl,%ecx
  801574:	83 e9 30             	sub    $0x30,%ecx
  801577:	eb 20                	jmp    801599 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  801579:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80157c:	89 f0                	mov    %esi,%eax
  80157e:	3c 19                	cmp    $0x19,%al
  801580:	77 08                	ja     80158a <strtol+0x97>
			dig = *s - 'a' + 10;
  801582:	0f be c9             	movsbl %cl,%ecx
  801585:	83 e9 57             	sub    $0x57,%ecx
  801588:	eb 0f                	jmp    801599 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  80158a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  80158d:	89 f0                	mov    %esi,%eax
  80158f:	3c 19                	cmp    $0x19,%al
  801591:	77 16                	ja     8015a9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  801593:	0f be c9             	movsbl %cl,%ecx
  801596:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801599:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80159c:	7d 0f                	jge    8015ad <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  80159e:	83 c2 01             	add    $0x1,%edx
  8015a1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  8015a5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  8015a7:	eb bc                	jmp    801565 <strtol+0x72>
  8015a9:	89 d8                	mov    %ebx,%eax
  8015ab:	eb 02                	jmp    8015af <strtol+0xbc>
  8015ad:	89 d8                	mov    %ebx,%eax

	if (endptr)
  8015af:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8015b3:	74 05                	je     8015ba <strtol+0xc7>
		*endptr = (char *) s;
  8015b5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8015b8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  8015ba:	f7 d8                	neg    %eax
  8015bc:	85 ff                	test   %edi,%edi
  8015be:	0f 44 c3             	cmove  %ebx,%eax
}
  8015c1:	5b                   	pop    %ebx
  8015c2:	5e                   	pop    %esi
  8015c3:	5f                   	pop    %edi
  8015c4:	5d                   	pop    %ebp
  8015c5:	c3                   	ret    

008015c6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8015c6:	55                   	push   %ebp
  8015c7:	89 e5                	mov    %esp,%ebp
  8015c9:	57                   	push   %edi
  8015ca:	56                   	push   %esi
  8015cb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8015d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8015d7:	89 c3                	mov    %eax,%ebx
  8015d9:	89 c7                	mov    %eax,%edi
  8015db:	89 c6                	mov    %eax,%esi
  8015dd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8015df:	5b                   	pop    %ebx
  8015e0:	5e                   	pop    %esi
  8015e1:	5f                   	pop    %edi
  8015e2:	5d                   	pop    %ebp
  8015e3:	c3                   	ret    

008015e4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8015e4:	55                   	push   %ebp
  8015e5:	89 e5                	mov    %esp,%ebp
  8015e7:	57                   	push   %edi
  8015e8:	56                   	push   %esi
  8015e9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ef:	b8 01 00 00 00       	mov    $0x1,%eax
  8015f4:	89 d1                	mov    %edx,%ecx
  8015f6:	89 d3                	mov    %edx,%ebx
  8015f8:	89 d7                	mov    %edx,%edi
  8015fa:	89 d6                	mov    %edx,%esi
  8015fc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8015fe:	5b                   	pop    %ebx
  8015ff:	5e                   	pop    %esi
  801600:	5f                   	pop    %edi
  801601:	5d                   	pop    %ebp
  801602:	c3                   	ret    

00801603 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801603:	55                   	push   %ebp
  801604:	89 e5                	mov    %esp,%ebp
  801606:	57                   	push   %edi
  801607:	56                   	push   %esi
  801608:	53                   	push   %ebx
  801609:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80160c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801611:	b8 03 00 00 00       	mov    $0x3,%eax
  801616:	8b 55 08             	mov    0x8(%ebp),%edx
  801619:	89 cb                	mov    %ecx,%ebx
  80161b:	89 cf                	mov    %ecx,%edi
  80161d:	89 ce                	mov    %ecx,%esi
  80161f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801621:	85 c0                	test   %eax,%eax
  801623:	7e 28                	jle    80164d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801625:	89 44 24 10          	mov    %eax,0x10(%esp)
  801629:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801630:	00 
  801631:	c7 44 24 08 ef 40 80 	movl   $0x8040ef,0x8(%esp)
  801638:	00 
  801639:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801640:	00 
  801641:	c7 04 24 0c 41 80 00 	movl   $0x80410c,(%esp)
  801648:	e8 1a f4 ff ff       	call   800a67 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80164d:	83 c4 2c             	add    $0x2c,%esp
  801650:	5b                   	pop    %ebx
  801651:	5e                   	pop    %esi
  801652:	5f                   	pop    %edi
  801653:	5d                   	pop    %ebp
  801654:	c3                   	ret    

00801655 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801655:	55                   	push   %ebp
  801656:	89 e5                	mov    %esp,%ebp
  801658:	57                   	push   %edi
  801659:	56                   	push   %esi
  80165a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80165b:	ba 00 00 00 00       	mov    $0x0,%edx
  801660:	b8 02 00 00 00       	mov    $0x2,%eax
  801665:	89 d1                	mov    %edx,%ecx
  801667:	89 d3                	mov    %edx,%ebx
  801669:	89 d7                	mov    %edx,%edi
  80166b:	89 d6                	mov    %edx,%esi
  80166d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80166f:	5b                   	pop    %ebx
  801670:	5e                   	pop    %esi
  801671:	5f                   	pop    %edi
  801672:	5d                   	pop    %ebp
  801673:	c3                   	ret    

00801674 <sys_yield>:

void
sys_yield(void)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	57                   	push   %edi
  801678:	56                   	push   %esi
  801679:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80167a:	ba 00 00 00 00       	mov    $0x0,%edx
  80167f:	b8 0b 00 00 00       	mov    $0xb,%eax
  801684:	89 d1                	mov    %edx,%ecx
  801686:	89 d3                	mov    %edx,%ebx
  801688:	89 d7                	mov    %edx,%edi
  80168a:	89 d6                	mov    %edx,%esi
  80168c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80168e:	5b                   	pop    %ebx
  80168f:	5e                   	pop    %esi
  801690:	5f                   	pop    %edi
  801691:	5d                   	pop    %ebp
  801692:	c3                   	ret    

00801693 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	57                   	push   %edi
  801697:	56                   	push   %esi
  801698:	53                   	push   %ebx
  801699:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80169c:	be 00 00 00 00       	mov    $0x0,%esi
  8016a1:	b8 04 00 00 00       	mov    $0x4,%eax
  8016a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8016ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8016af:	89 f7                	mov    %esi,%edi
  8016b1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8016b3:	85 c0                	test   %eax,%eax
  8016b5:	7e 28                	jle    8016df <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016b7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016bb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8016c2:	00 
  8016c3:	c7 44 24 08 ef 40 80 	movl   $0x8040ef,0x8(%esp)
  8016ca:	00 
  8016cb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8016d2:	00 
  8016d3:	c7 04 24 0c 41 80 00 	movl   $0x80410c,(%esp)
  8016da:	e8 88 f3 ff ff       	call   800a67 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8016df:	83 c4 2c             	add    $0x2c,%esp
  8016e2:	5b                   	pop    %ebx
  8016e3:	5e                   	pop    %esi
  8016e4:	5f                   	pop    %edi
  8016e5:	5d                   	pop    %ebp
  8016e6:	c3                   	ret    

008016e7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8016e7:	55                   	push   %ebp
  8016e8:	89 e5                	mov    %esp,%ebp
  8016ea:	57                   	push   %edi
  8016eb:	56                   	push   %esi
  8016ec:	53                   	push   %ebx
  8016ed:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016f0:	b8 05 00 00 00       	mov    $0x5,%eax
  8016f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8016fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8016fe:	8b 7d 14             	mov    0x14(%ebp),%edi
  801701:	8b 75 18             	mov    0x18(%ebp),%esi
  801704:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801706:	85 c0                	test   %eax,%eax
  801708:	7e 28                	jle    801732 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80170a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80170e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801715:	00 
  801716:	c7 44 24 08 ef 40 80 	movl   $0x8040ef,0x8(%esp)
  80171d:	00 
  80171e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801725:	00 
  801726:	c7 04 24 0c 41 80 00 	movl   $0x80410c,(%esp)
  80172d:	e8 35 f3 ff ff       	call   800a67 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801732:	83 c4 2c             	add    $0x2c,%esp
  801735:	5b                   	pop    %ebx
  801736:	5e                   	pop    %esi
  801737:	5f                   	pop    %edi
  801738:	5d                   	pop    %ebp
  801739:	c3                   	ret    

0080173a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	57                   	push   %edi
  80173e:	56                   	push   %esi
  80173f:	53                   	push   %ebx
  801740:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801743:	bb 00 00 00 00       	mov    $0x0,%ebx
  801748:	b8 06 00 00 00       	mov    $0x6,%eax
  80174d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801750:	8b 55 08             	mov    0x8(%ebp),%edx
  801753:	89 df                	mov    %ebx,%edi
  801755:	89 de                	mov    %ebx,%esi
  801757:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801759:	85 c0                	test   %eax,%eax
  80175b:	7e 28                	jle    801785 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80175d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801761:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801768:	00 
  801769:	c7 44 24 08 ef 40 80 	movl   $0x8040ef,0x8(%esp)
  801770:	00 
  801771:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801778:	00 
  801779:	c7 04 24 0c 41 80 00 	movl   $0x80410c,(%esp)
  801780:	e8 e2 f2 ff ff       	call   800a67 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801785:	83 c4 2c             	add    $0x2c,%esp
  801788:	5b                   	pop    %ebx
  801789:	5e                   	pop    %esi
  80178a:	5f                   	pop    %edi
  80178b:	5d                   	pop    %ebp
  80178c:	c3                   	ret    

0080178d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80178d:	55                   	push   %ebp
  80178e:	89 e5                	mov    %esp,%ebp
  801790:	57                   	push   %edi
  801791:	56                   	push   %esi
  801792:	53                   	push   %ebx
  801793:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801796:	bb 00 00 00 00       	mov    $0x0,%ebx
  80179b:	b8 08 00 00 00       	mov    $0x8,%eax
  8017a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8017a6:	89 df                	mov    %ebx,%edi
  8017a8:	89 de                	mov    %ebx,%esi
  8017aa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8017ac:	85 c0                	test   %eax,%eax
  8017ae:	7e 28                	jle    8017d8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017b0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017b4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8017bb:	00 
  8017bc:	c7 44 24 08 ef 40 80 	movl   $0x8040ef,0x8(%esp)
  8017c3:	00 
  8017c4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8017cb:	00 
  8017cc:	c7 04 24 0c 41 80 00 	movl   $0x80410c,(%esp)
  8017d3:	e8 8f f2 ff ff       	call   800a67 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8017d8:	83 c4 2c             	add    $0x2c,%esp
  8017db:	5b                   	pop    %ebx
  8017dc:	5e                   	pop    %esi
  8017dd:	5f                   	pop    %edi
  8017de:	5d                   	pop    %ebp
  8017df:	c3                   	ret    

008017e0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	57                   	push   %edi
  8017e4:	56                   	push   %esi
  8017e5:	53                   	push   %ebx
  8017e6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017ee:	b8 09 00 00 00       	mov    $0x9,%eax
  8017f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8017f9:	89 df                	mov    %ebx,%edi
  8017fb:	89 de                	mov    %ebx,%esi
  8017fd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8017ff:	85 c0                	test   %eax,%eax
  801801:	7e 28                	jle    80182b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801803:	89 44 24 10          	mov    %eax,0x10(%esp)
  801807:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80180e:	00 
  80180f:	c7 44 24 08 ef 40 80 	movl   $0x8040ef,0x8(%esp)
  801816:	00 
  801817:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80181e:	00 
  80181f:	c7 04 24 0c 41 80 00 	movl   $0x80410c,(%esp)
  801826:	e8 3c f2 ff ff       	call   800a67 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80182b:	83 c4 2c             	add    $0x2c,%esp
  80182e:	5b                   	pop    %ebx
  80182f:	5e                   	pop    %esi
  801830:	5f                   	pop    %edi
  801831:	5d                   	pop    %ebp
  801832:	c3                   	ret    

00801833 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	57                   	push   %edi
  801837:	56                   	push   %esi
  801838:	53                   	push   %ebx
  801839:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80183c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801841:	b8 0a 00 00 00       	mov    $0xa,%eax
  801846:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801849:	8b 55 08             	mov    0x8(%ebp),%edx
  80184c:	89 df                	mov    %ebx,%edi
  80184e:	89 de                	mov    %ebx,%esi
  801850:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801852:	85 c0                	test   %eax,%eax
  801854:	7e 28                	jle    80187e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801856:	89 44 24 10          	mov    %eax,0x10(%esp)
  80185a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801861:	00 
  801862:	c7 44 24 08 ef 40 80 	movl   $0x8040ef,0x8(%esp)
  801869:	00 
  80186a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801871:	00 
  801872:	c7 04 24 0c 41 80 00 	movl   $0x80410c,(%esp)
  801879:	e8 e9 f1 ff ff       	call   800a67 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80187e:	83 c4 2c             	add    $0x2c,%esp
  801881:	5b                   	pop    %ebx
  801882:	5e                   	pop    %esi
  801883:	5f                   	pop    %edi
  801884:	5d                   	pop    %ebp
  801885:	c3                   	ret    

00801886 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801886:	55                   	push   %ebp
  801887:	89 e5                	mov    %esp,%ebp
  801889:	57                   	push   %edi
  80188a:	56                   	push   %esi
  80188b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80188c:	be 00 00 00 00       	mov    $0x0,%esi
  801891:	b8 0c 00 00 00       	mov    $0xc,%eax
  801896:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801899:	8b 55 08             	mov    0x8(%ebp),%edx
  80189c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80189f:	8b 7d 14             	mov    0x14(%ebp),%edi
  8018a2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8018a4:	5b                   	pop    %ebx
  8018a5:	5e                   	pop    %esi
  8018a6:	5f                   	pop    %edi
  8018a7:	5d                   	pop    %ebp
  8018a8:	c3                   	ret    

008018a9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8018a9:	55                   	push   %ebp
  8018aa:	89 e5                	mov    %esp,%ebp
  8018ac:	57                   	push   %edi
  8018ad:	56                   	push   %esi
  8018ae:	53                   	push   %ebx
  8018af:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8018b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018b7:	b8 0d 00 00 00       	mov    $0xd,%eax
  8018bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8018bf:	89 cb                	mov    %ecx,%ebx
  8018c1:	89 cf                	mov    %ecx,%edi
  8018c3:	89 ce                	mov    %ecx,%esi
  8018c5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8018c7:	85 c0                	test   %eax,%eax
  8018c9:	7e 28                	jle    8018f3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8018cb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8018cf:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8018d6:	00 
  8018d7:	c7 44 24 08 ef 40 80 	movl   $0x8040ef,0x8(%esp)
  8018de:	00 
  8018df:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8018e6:	00 
  8018e7:	c7 04 24 0c 41 80 00 	movl   $0x80410c,(%esp)
  8018ee:	e8 74 f1 ff ff       	call   800a67 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8018f3:	83 c4 2c             	add    $0x2c,%esp
  8018f6:	5b                   	pop    %ebx
  8018f7:	5e                   	pop    %esi
  8018f8:	5f                   	pop    %edi
  8018f9:	5d                   	pop    %ebp
  8018fa:	c3                   	ret    

008018fb <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8018fb:	55                   	push   %ebp
  8018fc:	89 e5                	mov    %esp,%ebp
  8018fe:	57                   	push   %edi
  8018ff:	56                   	push   %esi
  801900:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801901:	ba 00 00 00 00       	mov    $0x0,%edx
  801906:	b8 0e 00 00 00       	mov    $0xe,%eax
  80190b:	89 d1                	mov    %edx,%ecx
  80190d:	89 d3                	mov    %edx,%ebx
  80190f:	89 d7                	mov    %edx,%edi
  801911:	89 d6                	mov    %edx,%esi
  801913:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801915:	5b                   	pop    %ebx
  801916:	5e                   	pop    %esi
  801917:	5f                   	pop    %edi
  801918:	5d                   	pop    %ebp
  801919:	c3                   	ret    

0080191a <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  80191a:	55                   	push   %ebp
  80191b:	89 e5                	mov    %esp,%ebp
  80191d:	57                   	push   %edi
  80191e:	56                   	push   %esi
  80191f:	53                   	push   %ebx
  801920:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801923:	bb 00 00 00 00       	mov    $0x0,%ebx
  801928:	b8 0f 00 00 00       	mov    $0xf,%eax
  80192d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801930:	8b 55 08             	mov    0x8(%ebp),%edx
  801933:	89 df                	mov    %ebx,%edi
  801935:	89 de                	mov    %ebx,%esi
  801937:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801939:	85 c0                	test   %eax,%eax
  80193b:	7e 28                	jle    801965 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80193d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801941:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801948:	00 
  801949:	c7 44 24 08 ef 40 80 	movl   $0x8040ef,0x8(%esp)
  801950:	00 
  801951:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801958:	00 
  801959:	c7 04 24 0c 41 80 00 	movl   $0x80410c,(%esp)
  801960:	e8 02 f1 ff ff       	call   800a67 <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  801965:	83 c4 2c             	add    $0x2c,%esp
  801968:	5b                   	pop    %ebx
  801969:	5e                   	pop    %esi
  80196a:	5f                   	pop    %edi
  80196b:	5d                   	pop    %ebp
  80196c:	c3                   	ret    

0080196d <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  80196d:	55                   	push   %ebp
  80196e:	89 e5                	mov    %esp,%ebp
  801970:	57                   	push   %edi
  801971:	56                   	push   %esi
  801972:	53                   	push   %ebx
  801973:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801976:	bb 00 00 00 00       	mov    $0x0,%ebx
  80197b:	b8 10 00 00 00       	mov    $0x10,%eax
  801980:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801983:	8b 55 08             	mov    0x8(%ebp),%edx
  801986:	89 df                	mov    %ebx,%edi
  801988:	89 de                	mov    %ebx,%esi
  80198a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80198c:	85 c0                	test   %eax,%eax
  80198e:	7e 28                	jle    8019b8 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801990:	89 44 24 10          	mov    %eax,0x10(%esp)
  801994:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  80199b:	00 
  80199c:	c7 44 24 08 ef 40 80 	movl   $0x8040ef,0x8(%esp)
  8019a3:	00 
  8019a4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8019ab:	00 
  8019ac:	c7 04 24 0c 41 80 00 	movl   $0x80410c,(%esp)
  8019b3:	e8 af f0 ff ff       	call   800a67 <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  8019b8:	83 c4 2c             	add    $0x2c,%esp
  8019bb:	5b                   	pop    %ebx
  8019bc:	5e                   	pop    %esi
  8019bd:	5f                   	pop    %edi
  8019be:	5d                   	pop    %ebp
  8019bf:	c3                   	ret    

008019c0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	56                   	push   %esi
  8019c4:	53                   	push   %ebx
  8019c5:	83 ec 20             	sub    $0x20,%esp
  8019c8:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8019cb:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if(!(err & FEC_WR)) {
  8019cd:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8019d1:	75 20                	jne    8019f3 <pgfault+0x33>
		panic("0x%x Not a write", addr);
  8019d3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8019d7:	c7 44 24 08 1a 41 80 	movl   $0x80411a,0x8(%esp)
  8019de:	00 
  8019df:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8019e6:	00 
  8019e7:	c7 04 24 2b 41 80 00 	movl   $0x80412b,(%esp)
  8019ee:	e8 74 f0 ff ff       	call   800a67 <_panic>
	}

	if(!(uvpt[PGNUM(addr)] & PTE_COW)) {
  8019f3:	89 f0                	mov    %esi,%eax
  8019f5:	c1 e8 0c             	shr    $0xc,%eax
  8019f8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019ff:	f6 c4 08             	test   $0x8,%ah
  801a02:	75 1c                	jne    801a20 <pgfault+0x60>
		panic("Not a COW page");
  801a04:	c7 44 24 08 36 41 80 	movl   $0x804136,0x8(%esp)
  801a0b:	00 
  801a0c:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  801a13:	00 
  801a14:	c7 04 24 2b 41 80 00 	movl   $0x80412b,(%esp)
  801a1b:	e8 47 f0 ff ff       	call   800a67 <_panic>

	// Allocate a new page, map it at a temporary location (PFTEMP), // copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	envid_t envid = sys_getenvid();
  801a20:	e8 30 fc ff ff       	call   801655 <sys_getenvid>
  801a25:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, PFTEMP, PTE_W | PTE_U | PTE_P);
  801a27:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801a2e:	00 
  801a2f:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801a36:	00 
  801a37:	89 04 24             	mov    %eax,(%esp)
  801a3a:	e8 54 fc ff ff       	call   801693 <sys_page_alloc>
	if(r < 0) {
  801a3f:	85 c0                	test   %eax,%eax
  801a41:	79 1c                	jns    801a5f <pgfault+0x9f>
		panic("couldn't allocate page");
  801a43:	c7 44 24 08 45 41 80 	movl   $0x804145,0x8(%esp)
  801a4a:	00 
  801a4b:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801a52:	00 
  801a53:	c7 04 24 2b 41 80 00 	movl   $0x80412b,(%esp)
  801a5a:	e8 08 f0 ff ff       	call   800a67 <_panic>
	}

	memmove(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  801a5f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  801a65:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801a6c:	00 
  801a6d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a71:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801a78:	e8 97 f9 ff ff       	call   801414 <memmove>

	r = sys_page_map(envid, PFTEMP, envid, ROUNDDOWN(addr,PGSIZE), PTE_P | PTE_U | PTE_W);
  801a7d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801a84:	00 
  801a85:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801a89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a8d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801a94:	00 
  801a95:	89 1c 24             	mov    %ebx,(%esp)
  801a98:	e8 4a fc ff ff       	call   8016e7 <sys_page_map>
	if(r < 0) {
  801a9d:	85 c0                	test   %eax,%eax
  801a9f:	79 1c                	jns    801abd <pgfault+0xfd>
		panic("couldn't map page");
  801aa1:	c7 44 24 08 5c 41 80 	movl   $0x80415c,0x8(%esp)
  801aa8:	00 
  801aa9:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  801ab0:	00 
  801ab1:	c7 04 24 2b 41 80 00 	movl   $0x80412b,(%esp)
  801ab8:	e8 aa ef ff ff       	call   800a67 <_panic>
	}
}
  801abd:	83 c4 20             	add    $0x20,%esp
  801ac0:	5b                   	pop    %ebx
  801ac1:	5e                   	pop    %esi
  801ac2:	5d                   	pop    %ebp
  801ac3:	c3                   	ret    

00801ac4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801ac4:	55                   	push   %ebp
  801ac5:	89 e5                	mov    %esp,%ebp
  801ac7:	57                   	push   %edi
  801ac8:	56                   	push   %esi
  801ac9:	53                   	push   %ebx
  801aca:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envid;
	uintptr_t addr;
	int r = 0;

	set_pgfault_handler(pgfault);
  801acd:	c7 04 24 c0 19 80 00 	movl   $0x8019c0,(%esp)
  801ad4:	e8 51 1c 00 00       	call   80372a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801ad9:	b8 07 00 00 00       	mov    $0x7,%eax
  801ade:	cd 30                	int    $0x30
  801ae0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801ae3:	89 45 d8             	mov    %eax,-0x28(%ebp)

	envid = sys_exofork();
	if(envid == 0) {
  801ae6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801aed:	bf 00 00 00 00       	mov    $0x0,%edi
  801af2:	85 c0                	test   %eax,%eax
  801af4:	75 21                	jne    801b17 <fork+0x53>
		thisenv = &envs[ENVX(sys_getenvid())];
  801af6:	e8 5a fb ff ff       	call   801655 <sys_getenvid>
  801afb:	25 ff 03 00 00       	and    $0x3ff,%eax
  801b00:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b03:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b08:	a3 28 64 80 00       	mov    %eax,0x806428
		return 0;
  801b0d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b12:	e9 8d 01 00 00       	jmp    801ca4 <fork+0x1e0>
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
  801b17:	89 f8                	mov    %edi,%eax
  801b19:	c1 e8 16             	shr    $0x16,%eax
  801b1c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801b23:	85 c0                	test   %eax,%eax
  801b25:	0f 84 02 01 00 00    	je     801c2d <fork+0x169>
  801b2b:	89 fa                	mov    %edi,%edx
  801b2d:	c1 ea 0c             	shr    $0xc,%edx
  801b30:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801b37:	85 c0                	test   %eax,%eax
  801b39:	0f 84 ee 00 00 00    	je     801c2d <fork+0x169>
//
static int
duppage(envid_t envid, unsigned pn)
{

	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P)) return 0;
  801b3f:	89 d6                	mov    %edx,%esi
  801b41:	c1 e6 0c             	shl    $0xc,%esi
  801b44:	89 f0                	mov    %esi,%eax
  801b46:	c1 e8 16             	shr    $0x16,%eax
  801b49:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  801b50:	b8 00 00 00 00       	mov    $0x0,%eax
  801b55:	f6 c1 01             	test   $0x1,%cl
  801b58:	0f 84 cc 00 00 00    	je     801c2a <fork+0x166>

	int all_perms = PTE_U | PTE_P | PTE_AVAIL | PTE_W | PTE_COW;
	int orig_perms = uvpt[pn] & all_perms;
  801b5e:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  801b65:	89 d8                	mov    %ebx,%eax
  801b67:	25 07 0e 00 00       	and    $0xe07,%eax
  801b6c:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if(!(orig_perms & PTE_P)) return 0;
  801b6f:	89 d8                	mov    %ebx,%eax
  801b71:	83 e0 01             	and    $0x1,%eax
  801b74:	0f 84 b0 00 00 00    	je     801c2a <fork+0x166>

	int r = 0;
	envid_t curenvid = sys_getenvid();
  801b7a:	e8 d6 fa ff ff       	call   801655 <sys_getenvid>
  801b7f:	89 45 dc             	mov    %eax,-0x24(%ebp)


	if(orig_perms & PTE_SHARE) {
  801b82:	f7 45 e0 00 04 00 00 	testl  $0x400,-0x20(%ebp)
  801b89:	74 28                	je     801bb3 <fork+0xef>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms & PTE_SYSCALL));
  801b8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b8e:	25 07 0e 00 00       	and    $0xe07,%eax
  801b93:	89 44 24 10          	mov    %eax,0x10(%esp)
  801b97:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801b9b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801b9e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ba2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ba6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801ba9:	89 04 24             	mov    %eax,(%esp)
  801bac:	e8 36 fb ff ff       	call   8016e7 <sys_page_map>
  801bb1:	eb 77                	jmp    801c2a <fork+0x166>

	} else if(((orig_perms) & PTE_COW) || (orig_perms & PTE_W) ) {
  801bb3:	f7 c3 02 08 00 00    	test   $0x802,%ebx
  801bb9:	74 4e                	je     801c09 <fork+0x145>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  801bbb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bbe:	25 fd f7 ff ff       	and    $0xfffff7fd,%eax
  801bc3:	80 cc 08             	or     $0x8,%ah
  801bc6:	89 c3                	mov    %eax,%ebx
  801bc8:	89 44 24 10          	mov    %eax,0x10(%esp)
  801bcc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801bd0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801bd3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bd7:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bdb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801bde:	89 04 24             	mov    %eax,(%esp)
  801be1:	e8 01 fb ff ff       	call   8016e7 <sys_page_map>
  801be6:	89 45 e0             	mov    %eax,-0x20(%ebp)

		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), curenvid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  801be9:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801bed:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801bf1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801bf4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801bf8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bfc:	89 0c 24             	mov    %ecx,(%esp)
  801bff:	e8 e3 fa ff ff       	call   8016e7 <sys_page_map>
  801c04:	03 45 e0             	add    -0x20(%ebp),%eax
  801c07:	eb 21                	jmp    801c2a <fork+0x166>

	} else {
		r = sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), orig_perms);
  801c09:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c0c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c10:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c14:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801c17:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c1b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c1f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801c22:	89 04 24             	mov    %eax,(%esp)
  801c25:	e8 bd fa ff ff       	call   8016e7 <sys_page_map>
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
  801c2a:	01 45 e4             	add    %eax,-0x1c(%ebp)
	if(envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
  801c2d:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801c33:	81 ff 00 f0 bf ee    	cmp    $0xeebff000,%edi
  801c39:	0f 85 d8 fe ff ff    	jne    801b17 <fork+0x53>
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
		}
	}

	r+=sys_page_alloc(envid, (void*)UXSTACKTOP - PGSIZE, PTE_P|PTE_U|PTE_W);
  801c3f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801c46:	00 
  801c47:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801c4e:	ee 
  801c4f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801c52:	89 34 24             	mov    %esi,(%esp)
  801c55:	e8 39 fa ff ff       	call   801693 <sys_page_alloc>
  801c5a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801c5d:	01 c3                	add    %eax,%ebx
	r+=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801c5f:	c7 44 24 04 77 37 80 	movl   $0x803777,0x4(%esp)
  801c66:	00 
  801c67:	89 34 24             	mov    %esi,(%esp)
  801c6a:	e8 c4 fb ff ff       	call   801833 <sys_env_set_pgfault_upcall>
  801c6f:	01 c3                	add    %eax,%ebx
	r+= sys_env_set_status(envid, ENV_RUNNABLE);
  801c71:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801c78:	00 
  801c79:	89 34 24             	mov    %esi,(%esp)
  801c7c:	e8 0c fb ff ff       	call   80178d <sys_env_set_status>

	if(r<0) {
  801c81:	01 d8                	add    %ebx,%eax
  801c83:	79 1c                	jns    801ca1 <fork+0x1dd>
	 panic("fork failed!");
  801c85:	c7 44 24 08 6e 41 80 	movl   $0x80416e,0x8(%esp)
  801c8c:	00 
  801c8d:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  801c94:	00 
  801c95:	c7 04 24 2b 41 80 00 	movl   $0x80412b,(%esp)
  801c9c:	e8 c6 ed ff ff       	call   800a67 <_panic>
	}

	return envid;
  801ca1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  801ca4:	83 c4 3c             	add    $0x3c,%esp
  801ca7:	5b                   	pop    %ebx
  801ca8:	5e                   	pop    %esi
  801ca9:	5f                   	pop    %edi
  801caa:	5d                   	pop    %ebp
  801cab:	c3                   	ret    

00801cac <sfork>:

// Challenge!
int
sfork(void)
{
  801cac:	55                   	push   %ebp
  801cad:	89 e5                	mov    %esp,%ebp
  801caf:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801cb2:	c7 44 24 08 7b 41 80 	movl   $0x80417b,0x8(%esp)
  801cb9:	00 
  801cba:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
  801cc1:	00 
  801cc2:	c7 04 24 2b 41 80 00 	movl   $0x80412b,(%esp)
  801cc9:	e8 99 ed ff ff       	call   800a67 <_panic>

00801cce <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801cce:	55                   	push   %ebp
  801ccf:	89 e5                	mov    %esp,%ebp
  801cd1:	53                   	push   %ebx
  801cd2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cd5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cd8:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801cdb:	89 08                	mov    %ecx,(%eax)
	args->argv = (const char **) argv;
  801cdd:	89 50 04             	mov    %edx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801ce0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ce5:	83 39 01             	cmpl   $0x1,(%ecx)
  801ce8:	7e 0f                	jle    801cf9 <argstart+0x2b>
  801cea:	85 d2                	test   %edx,%edx
  801cec:	ba 00 00 00 00       	mov    $0x0,%edx
  801cf1:	bb c1 3b 80 00       	mov    $0x803bc1,%ebx
  801cf6:	0f 44 da             	cmove  %edx,%ebx
  801cf9:	89 58 08             	mov    %ebx,0x8(%eax)
	args->argvalue = 0;
  801cfc:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801d03:	5b                   	pop    %ebx
  801d04:	5d                   	pop    %ebp
  801d05:	c3                   	ret    

00801d06 <argnext>:

int
argnext(struct Argstate *args)
{
  801d06:	55                   	push   %ebp
  801d07:	89 e5                	mov    %esp,%ebp
  801d09:	53                   	push   %ebx
  801d0a:	83 ec 14             	sub    $0x14,%esp
  801d0d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801d10:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801d17:	8b 43 08             	mov    0x8(%ebx),%eax
  801d1a:	85 c0                	test   %eax,%eax
  801d1c:	74 71                	je     801d8f <argnext+0x89>
		return -1;

	if (!*args->curarg) {
  801d1e:	80 38 00             	cmpb   $0x0,(%eax)
  801d21:	75 50                	jne    801d73 <argnext+0x6d>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801d23:	8b 0b                	mov    (%ebx),%ecx
  801d25:	83 39 01             	cmpl   $0x1,(%ecx)
  801d28:	74 57                	je     801d81 <argnext+0x7b>
		    || args->argv[1][0] != '-'
  801d2a:	8b 53 04             	mov    0x4(%ebx),%edx
  801d2d:	8b 42 04             	mov    0x4(%edx),%eax
  801d30:	80 38 2d             	cmpb   $0x2d,(%eax)
  801d33:	75 4c                	jne    801d81 <argnext+0x7b>
		    || args->argv[1][1] == '\0')
  801d35:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801d39:	74 46                	je     801d81 <argnext+0x7b>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801d3b:	83 c0 01             	add    $0x1,%eax
  801d3e:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801d41:	8b 01                	mov    (%ecx),%eax
  801d43:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801d4a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d4e:	8d 42 08             	lea    0x8(%edx),%eax
  801d51:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d55:	83 c2 04             	add    $0x4,%edx
  801d58:	89 14 24             	mov    %edx,(%esp)
  801d5b:	e8 b4 f6 ff ff       	call   801414 <memmove>
		(*args->argc)--;
  801d60:	8b 03                	mov    (%ebx),%eax
  801d62:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801d65:	8b 43 08             	mov    0x8(%ebx),%eax
  801d68:	80 38 2d             	cmpb   $0x2d,(%eax)
  801d6b:	75 06                	jne    801d73 <argnext+0x6d>
  801d6d:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801d71:	74 0e                	je     801d81 <argnext+0x7b>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801d73:	8b 53 08             	mov    0x8(%ebx),%edx
  801d76:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801d79:	83 c2 01             	add    $0x1,%edx
  801d7c:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801d7f:	eb 13                	jmp    801d94 <argnext+0x8e>

    endofargs:
	args->curarg = 0;
  801d81:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801d88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801d8d:	eb 05                	jmp    801d94 <argnext+0x8e>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801d8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801d94:	83 c4 14             	add    $0x14,%esp
  801d97:	5b                   	pop    %ebx
  801d98:	5d                   	pop    %ebp
  801d99:	c3                   	ret    

00801d9a <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801d9a:	55                   	push   %ebp
  801d9b:	89 e5                	mov    %esp,%ebp
  801d9d:	53                   	push   %ebx
  801d9e:	83 ec 14             	sub    $0x14,%esp
  801da1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801da4:	8b 43 08             	mov    0x8(%ebx),%eax
  801da7:	85 c0                	test   %eax,%eax
  801da9:	74 5a                	je     801e05 <argnextvalue+0x6b>
		return 0;
	if (*args->curarg) {
  801dab:	80 38 00             	cmpb   $0x0,(%eax)
  801dae:	74 0c                	je     801dbc <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801db0:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801db3:	c7 43 08 c1 3b 80 00 	movl   $0x803bc1,0x8(%ebx)
  801dba:	eb 44                	jmp    801e00 <argnextvalue+0x66>
	} else if (*args->argc > 1) {
  801dbc:	8b 03                	mov    (%ebx),%eax
  801dbe:	83 38 01             	cmpl   $0x1,(%eax)
  801dc1:	7e 2f                	jle    801df2 <argnextvalue+0x58>
		args->argvalue = args->argv[1];
  801dc3:	8b 53 04             	mov    0x4(%ebx),%edx
  801dc6:	8b 4a 04             	mov    0x4(%edx),%ecx
  801dc9:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801dcc:	8b 00                	mov    (%eax),%eax
  801dce:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801dd5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dd9:	8d 42 08             	lea    0x8(%edx),%eax
  801ddc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801de0:	83 c2 04             	add    $0x4,%edx
  801de3:	89 14 24             	mov    %edx,(%esp)
  801de6:	e8 29 f6 ff ff       	call   801414 <memmove>
		(*args->argc)--;
  801deb:	8b 03                	mov    (%ebx),%eax
  801ded:	83 28 01             	subl   $0x1,(%eax)
  801df0:	eb 0e                	jmp    801e00 <argnextvalue+0x66>
	} else {
		args->argvalue = 0;
  801df2:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801df9:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801e00:	8b 43 0c             	mov    0xc(%ebx),%eax
  801e03:	eb 05                	jmp    801e0a <argnextvalue+0x70>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801e05:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801e0a:	83 c4 14             	add    $0x14,%esp
  801e0d:	5b                   	pop    %ebx
  801e0e:	5d                   	pop    %ebp
  801e0f:	c3                   	ret    

00801e10 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	83 ec 18             	sub    $0x18,%esp
  801e16:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801e19:	8b 51 0c             	mov    0xc(%ecx),%edx
  801e1c:	89 d0                	mov    %edx,%eax
  801e1e:	85 d2                	test   %edx,%edx
  801e20:	75 08                	jne    801e2a <argvalue+0x1a>
  801e22:	89 0c 24             	mov    %ecx,(%esp)
  801e25:	e8 70 ff ff ff       	call   801d9a <argnextvalue>
}
  801e2a:	c9                   	leave  
  801e2b:	c3                   	ret    
  801e2c:	66 90                	xchg   %ax,%ax
  801e2e:	66 90                	xchg   %ax,%ax

00801e30 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801e30:	55                   	push   %ebp
  801e31:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801e33:	8b 45 08             	mov    0x8(%ebp),%eax
  801e36:	05 00 00 00 30       	add    $0x30000000,%eax
  801e3b:	c1 e8 0c             	shr    $0xc,%eax
}
  801e3e:	5d                   	pop    %ebp
  801e3f:	c3                   	ret    

00801e40 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801e40:	55                   	push   %ebp
  801e41:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801e43:	8b 45 08             	mov    0x8(%ebp),%eax
  801e46:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801e4b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801e50:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801e55:	5d                   	pop    %ebp
  801e56:	c3                   	ret    

00801e57 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801e57:	55                   	push   %ebp
  801e58:	89 e5                	mov    %esp,%ebp
  801e5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e5d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801e62:	89 c2                	mov    %eax,%edx
  801e64:	c1 ea 16             	shr    $0x16,%edx
  801e67:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801e6e:	f6 c2 01             	test   $0x1,%dl
  801e71:	74 11                	je     801e84 <fd_alloc+0x2d>
  801e73:	89 c2                	mov    %eax,%edx
  801e75:	c1 ea 0c             	shr    $0xc,%edx
  801e78:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801e7f:	f6 c2 01             	test   $0x1,%dl
  801e82:	75 09                	jne    801e8d <fd_alloc+0x36>
			*fd_store = fd;
  801e84:	89 01                	mov    %eax,(%ecx)
			return 0;
  801e86:	b8 00 00 00 00       	mov    $0x0,%eax
  801e8b:	eb 17                	jmp    801ea4 <fd_alloc+0x4d>
  801e8d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801e92:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801e97:	75 c9                	jne    801e62 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801e99:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801e9f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801ea4:	5d                   	pop    %ebp
  801ea5:	c3                   	ret    

00801ea6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801ea6:	55                   	push   %ebp
  801ea7:	89 e5                	mov    %esp,%ebp
  801ea9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801eac:	83 f8 1f             	cmp    $0x1f,%eax
  801eaf:	77 36                	ja     801ee7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801eb1:	c1 e0 0c             	shl    $0xc,%eax
  801eb4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801eb9:	89 c2                	mov    %eax,%edx
  801ebb:	c1 ea 16             	shr    $0x16,%edx
  801ebe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801ec5:	f6 c2 01             	test   $0x1,%dl
  801ec8:	74 24                	je     801eee <fd_lookup+0x48>
  801eca:	89 c2                	mov    %eax,%edx
  801ecc:	c1 ea 0c             	shr    $0xc,%edx
  801ecf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801ed6:	f6 c2 01             	test   $0x1,%dl
  801ed9:	74 1a                	je     801ef5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801edb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ede:	89 02                	mov    %eax,(%edx)
	return 0;
  801ee0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee5:	eb 13                	jmp    801efa <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801ee7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801eec:	eb 0c                	jmp    801efa <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801eee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ef3:	eb 05                	jmp    801efa <fd_lookup+0x54>
  801ef5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801efa:	5d                   	pop    %ebp
  801efb:	c3                   	ret    

00801efc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801efc:	55                   	push   %ebp
  801efd:	89 e5                	mov    %esp,%ebp
  801eff:	83 ec 18             	sub    $0x18,%esp
  801f02:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801f05:	ba 00 00 00 00       	mov    $0x0,%edx
  801f0a:	eb 13                	jmp    801f1f <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  801f0c:	39 08                	cmp    %ecx,(%eax)
  801f0e:	75 0c                	jne    801f1c <dev_lookup+0x20>
			*dev = devtab[i];
  801f10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f13:	89 01                	mov    %eax,(%ecx)
			return 0;
  801f15:	b8 00 00 00 00       	mov    $0x0,%eax
  801f1a:	eb 38                	jmp    801f54 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801f1c:	83 c2 01             	add    $0x1,%edx
  801f1f:	8b 04 95 10 42 80 00 	mov    0x804210(,%edx,4),%eax
  801f26:	85 c0                	test   %eax,%eax
  801f28:	75 e2                	jne    801f0c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801f2a:	a1 28 64 80 00       	mov    0x806428,%eax
  801f2f:	8b 40 48             	mov    0x48(%eax),%eax
  801f32:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f36:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f3a:	c7 04 24 94 41 80 00 	movl   $0x804194,(%esp)
  801f41:	e8 1a ec ff ff       	call   800b60 <cprintf>
	*dev = 0;
  801f46:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f49:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801f4f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801f54:	c9                   	leave  
  801f55:	c3                   	ret    

00801f56 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801f56:	55                   	push   %ebp
  801f57:	89 e5                	mov    %esp,%ebp
  801f59:	56                   	push   %esi
  801f5a:	53                   	push   %ebx
  801f5b:	83 ec 20             	sub    $0x20,%esp
  801f5e:	8b 75 08             	mov    0x8(%ebp),%esi
  801f61:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801f64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f67:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801f6b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801f71:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801f74:	89 04 24             	mov    %eax,(%esp)
  801f77:	e8 2a ff ff ff       	call   801ea6 <fd_lookup>
  801f7c:	85 c0                	test   %eax,%eax
  801f7e:	78 05                	js     801f85 <fd_close+0x2f>
	    || fd != fd2)
  801f80:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801f83:	74 0c                	je     801f91 <fd_close+0x3b>
		return (must_exist ? r : 0);
  801f85:	84 db                	test   %bl,%bl
  801f87:	ba 00 00 00 00       	mov    $0x0,%edx
  801f8c:	0f 44 c2             	cmove  %edx,%eax
  801f8f:	eb 3f                	jmp    801fd0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801f91:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f94:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f98:	8b 06                	mov    (%esi),%eax
  801f9a:	89 04 24             	mov    %eax,(%esp)
  801f9d:	e8 5a ff ff ff       	call   801efc <dev_lookup>
  801fa2:	89 c3                	mov    %eax,%ebx
  801fa4:	85 c0                	test   %eax,%eax
  801fa6:	78 16                	js     801fbe <fd_close+0x68>
		if (dev->dev_close)
  801fa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fab:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801fae:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801fb3:	85 c0                	test   %eax,%eax
  801fb5:	74 07                	je     801fbe <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801fb7:	89 34 24             	mov    %esi,(%esp)
  801fba:	ff d0                	call   *%eax
  801fbc:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801fbe:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fc2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fc9:	e8 6c f7 ff ff       	call   80173a <sys_page_unmap>
	return r;
  801fce:	89 d8                	mov    %ebx,%eax
}
  801fd0:	83 c4 20             	add    $0x20,%esp
  801fd3:	5b                   	pop    %ebx
  801fd4:	5e                   	pop    %esi
  801fd5:	5d                   	pop    %ebp
  801fd6:	c3                   	ret    

00801fd7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801fd7:	55                   	push   %ebp
  801fd8:	89 e5                	mov    %esp,%ebp
  801fda:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fdd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe7:	89 04 24             	mov    %eax,(%esp)
  801fea:	e8 b7 fe ff ff       	call   801ea6 <fd_lookup>
  801fef:	89 c2                	mov    %eax,%edx
  801ff1:	85 d2                	test   %edx,%edx
  801ff3:	78 13                	js     802008 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801ff5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ffc:	00 
  801ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802000:	89 04 24             	mov    %eax,(%esp)
  802003:	e8 4e ff ff ff       	call   801f56 <fd_close>
}
  802008:	c9                   	leave  
  802009:	c3                   	ret    

0080200a <close_all>:

void
close_all(void)
{
  80200a:	55                   	push   %ebp
  80200b:	89 e5                	mov    %esp,%ebp
  80200d:	53                   	push   %ebx
  80200e:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802011:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802016:	89 1c 24             	mov    %ebx,(%esp)
  802019:	e8 b9 ff ff ff       	call   801fd7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80201e:	83 c3 01             	add    $0x1,%ebx
  802021:	83 fb 20             	cmp    $0x20,%ebx
  802024:	75 f0                	jne    802016 <close_all+0xc>
		close(i);
}
  802026:	83 c4 14             	add    $0x14,%esp
  802029:	5b                   	pop    %ebx
  80202a:	5d                   	pop    %ebp
  80202b:	c3                   	ret    

0080202c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80202c:	55                   	push   %ebp
  80202d:	89 e5                	mov    %esp,%ebp
  80202f:	57                   	push   %edi
  802030:	56                   	push   %esi
  802031:	53                   	push   %ebx
  802032:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802035:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802038:	89 44 24 04          	mov    %eax,0x4(%esp)
  80203c:	8b 45 08             	mov    0x8(%ebp),%eax
  80203f:	89 04 24             	mov    %eax,(%esp)
  802042:	e8 5f fe ff ff       	call   801ea6 <fd_lookup>
  802047:	89 c2                	mov    %eax,%edx
  802049:	85 d2                	test   %edx,%edx
  80204b:	0f 88 e1 00 00 00    	js     802132 <dup+0x106>
		return r;
	close(newfdnum);
  802051:	8b 45 0c             	mov    0xc(%ebp),%eax
  802054:	89 04 24             	mov    %eax,(%esp)
  802057:	e8 7b ff ff ff       	call   801fd7 <close>

	newfd = INDEX2FD(newfdnum);
  80205c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80205f:	c1 e3 0c             	shl    $0xc,%ebx
  802062:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802068:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80206b:	89 04 24             	mov    %eax,(%esp)
  80206e:	e8 cd fd ff ff       	call   801e40 <fd2data>
  802073:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  802075:	89 1c 24             	mov    %ebx,(%esp)
  802078:	e8 c3 fd ff ff       	call   801e40 <fd2data>
  80207d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80207f:	89 f0                	mov    %esi,%eax
  802081:	c1 e8 16             	shr    $0x16,%eax
  802084:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80208b:	a8 01                	test   $0x1,%al
  80208d:	74 43                	je     8020d2 <dup+0xa6>
  80208f:	89 f0                	mov    %esi,%eax
  802091:	c1 e8 0c             	shr    $0xc,%eax
  802094:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80209b:	f6 c2 01             	test   $0x1,%dl
  80209e:	74 32                	je     8020d2 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8020a0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8020a7:	25 07 0e 00 00       	and    $0xe07,%eax
  8020ac:	89 44 24 10          	mov    %eax,0x10(%esp)
  8020b0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8020b4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020bb:	00 
  8020bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020c7:	e8 1b f6 ff ff       	call   8016e7 <sys_page_map>
  8020cc:	89 c6                	mov    %eax,%esi
  8020ce:	85 c0                	test   %eax,%eax
  8020d0:	78 3e                	js     802110 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8020d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020d5:	89 c2                	mov    %eax,%edx
  8020d7:	c1 ea 0c             	shr    $0xc,%edx
  8020da:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8020e1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8020e7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8020eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020f6:	00 
  8020f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802102:	e8 e0 f5 ff ff       	call   8016e7 <sys_page_map>
  802107:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  802109:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80210c:	85 f6                	test   %esi,%esi
  80210e:	79 22                	jns    802132 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802110:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802114:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80211b:	e8 1a f6 ff ff       	call   80173a <sys_page_unmap>
	sys_page_unmap(0, nva);
  802120:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802124:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80212b:	e8 0a f6 ff ff       	call   80173a <sys_page_unmap>
	return r;
  802130:	89 f0                	mov    %esi,%eax
}
  802132:	83 c4 3c             	add    $0x3c,%esp
  802135:	5b                   	pop    %ebx
  802136:	5e                   	pop    %esi
  802137:	5f                   	pop    %edi
  802138:	5d                   	pop    %ebp
  802139:	c3                   	ret    

0080213a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80213a:	55                   	push   %ebp
  80213b:	89 e5                	mov    %esp,%ebp
  80213d:	53                   	push   %ebx
  80213e:	83 ec 24             	sub    $0x24,%esp
  802141:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802144:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802147:	89 44 24 04          	mov    %eax,0x4(%esp)
  80214b:	89 1c 24             	mov    %ebx,(%esp)
  80214e:	e8 53 fd ff ff       	call   801ea6 <fd_lookup>
  802153:	89 c2                	mov    %eax,%edx
  802155:	85 d2                	test   %edx,%edx
  802157:	78 6d                	js     8021c6 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802159:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80215c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802160:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802163:	8b 00                	mov    (%eax),%eax
  802165:	89 04 24             	mov    %eax,(%esp)
  802168:	e8 8f fd ff ff       	call   801efc <dev_lookup>
  80216d:	85 c0                	test   %eax,%eax
  80216f:	78 55                	js     8021c6 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802171:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802174:	8b 50 08             	mov    0x8(%eax),%edx
  802177:	83 e2 03             	and    $0x3,%edx
  80217a:	83 fa 01             	cmp    $0x1,%edx
  80217d:	75 23                	jne    8021a2 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80217f:	a1 28 64 80 00       	mov    0x806428,%eax
  802184:	8b 40 48             	mov    0x48(%eax),%eax
  802187:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80218b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80218f:	c7 04 24 d5 41 80 00 	movl   $0x8041d5,(%esp)
  802196:	e8 c5 e9 ff ff       	call   800b60 <cprintf>
		return -E_INVAL;
  80219b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8021a0:	eb 24                	jmp    8021c6 <read+0x8c>
	}
	if (!dev->dev_read)
  8021a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021a5:	8b 52 08             	mov    0x8(%edx),%edx
  8021a8:	85 d2                	test   %edx,%edx
  8021aa:	74 15                	je     8021c1 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8021ac:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8021af:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021b6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8021ba:	89 04 24             	mov    %eax,(%esp)
  8021bd:	ff d2                	call   *%edx
  8021bf:	eb 05                	jmp    8021c6 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8021c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8021c6:	83 c4 24             	add    $0x24,%esp
  8021c9:	5b                   	pop    %ebx
  8021ca:	5d                   	pop    %ebp
  8021cb:	c3                   	ret    

008021cc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8021cc:	55                   	push   %ebp
  8021cd:	89 e5                	mov    %esp,%ebp
  8021cf:	57                   	push   %edi
  8021d0:	56                   	push   %esi
  8021d1:	53                   	push   %ebx
  8021d2:	83 ec 1c             	sub    $0x1c,%esp
  8021d5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021d8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8021db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021e0:	eb 23                	jmp    802205 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8021e2:	89 f0                	mov    %esi,%eax
  8021e4:	29 d8                	sub    %ebx,%eax
  8021e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021ea:	89 d8                	mov    %ebx,%eax
  8021ec:	03 45 0c             	add    0xc(%ebp),%eax
  8021ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021f3:	89 3c 24             	mov    %edi,(%esp)
  8021f6:	e8 3f ff ff ff       	call   80213a <read>
		if (m < 0)
  8021fb:	85 c0                	test   %eax,%eax
  8021fd:	78 10                	js     80220f <readn+0x43>
			return m;
		if (m == 0)
  8021ff:	85 c0                	test   %eax,%eax
  802201:	74 0a                	je     80220d <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802203:	01 c3                	add    %eax,%ebx
  802205:	39 f3                	cmp    %esi,%ebx
  802207:	72 d9                	jb     8021e2 <readn+0x16>
  802209:	89 d8                	mov    %ebx,%eax
  80220b:	eb 02                	jmp    80220f <readn+0x43>
  80220d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80220f:	83 c4 1c             	add    $0x1c,%esp
  802212:	5b                   	pop    %ebx
  802213:	5e                   	pop    %esi
  802214:	5f                   	pop    %edi
  802215:	5d                   	pop    %ebp
  802216:	c3                   	ret    

00802217 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802217:	55                   	push   %ebp
  802218:	89 e5                	mov    %esp,%ebp
  80221a:	53                   	push   %ebx
  80221b:	83 ec 24             	sub    $0x24,%esp
  80221e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802221:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802224:	89 44 24 04          	mov    %eax,0x4(%esp)
  802228:	89 1c 24             	mov    %ebx,(%esp)
  80222b:	e8 76 fc ff ff       	call   801ea6 <fd_lookup>
  802230:	89 c2                	mov    %eax,%edx
  802232:	85 d2                	test   %edx,%edx
  802234:	78 68                	js     80229e <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802236:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802239:	89 44 24 04          	mov    %eax,0x4(%esp)
  80223d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802240:	8b 00                	mov    (%eax),%eax
  802242:	89 04 24             	mov    %eax,(%esp)
  802245:	e8 b2 fc ff ff       	call   801efc <dev_lookup>
  80224a:	85 c0                	test   %eax,%eax
  80224c:	78 50                	js     80229e <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80224e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802251:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802255:	75 23                	jne    80227a <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802257:	a1 28 64 80 00       	mov    0x806428,%eax
  80225c:	8b 40 48             	mov    0x48(%eax),%eax
  80225f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802263:	89 44 24 04          	mov    %eax,0x4(%esp)
  802267:	c7 04 24 f1 41 80 00 	movl   $0x8041f1,(%esp)
  80226e:	e8 ed e8 ff ff       	call   800b60 <cprintf>
		return -E_INVAL;
  802273:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802278:	eb 24                	jmp    80229e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80227a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80227d:	8b 52 0c             	mov    0xc(%edx),%edx
  802280:	85 d2                	test   %edx,%edx
  802282:	74 15                	je     802299 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802284:	8b 4d 10             	mov    0x10(%ebp),%ecx
  802287:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80228b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80228e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802292:	89 04 24             	mov    %eax,(%esp)
  802295:	ff d2                	call   *%edx
  802297:	eb 05                	jmp    80229e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802299:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80229e:	83 c4 24             	add    $0x24,%esp
  8022a1:	5b                   	pop    %ebx
  8022a2:	5d                   	pop    %ebp
  8022a3:	c3                   	ret    

008022a4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8022a4:	55                   	push   %ebp
  8022a5:	89 e5                	mov    %esp,%ebp
  8022a7:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022aa:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8022ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b4:	89 04 24             	mov    %eax,(%esp)
  8022b7:	e8 ea fb ff ff       	call   801ea6 <fd_lookup>
  8022bc:	85 c0                	test   %eax,%eax
  8022be:	78 0e                	js     8022ce <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8022c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8022c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022c6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8022c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022ce:	c9                   	leave  
  8022cf:	c3                   	ret    

008022d0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8022d0:	55                   	push   %ebp
  8022d1:	89 e5                	mov    %esp,%ebp
  8022d3:	53                   	push   %ebx
  8022d4:	83 ec 24             	sub    $0x24,%esp
  8022d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8022da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8022dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022e1:	89 1c 24             	mov    %ebx,(%esp)
  8022e4:	e8 bd fb ff ff       	call   801ea6 <fd_lookup>
  8022e9:	89 c2                	mov    %eax,%edx
  8022eb:	85 d2                	test   %edx,%edx
  8022ed:	78 61                	js     802350 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8022ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022f9:	8b 00                	mov    (%eax),%eax
  8022fb:	89 04 24             	mov    %eax,(%esp)
  8022fe:	e8 f9 fb ff ff       	call   801efc <dev_lookup>
  802303:	85 c0                	test   %eax,%eax
  802305:	78 49                	js     802350 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802307:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80230a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80230e:	75 23                	jne    802333 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802310:	a1 28 64 80 00       	mov    0x806428,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802315:	8b 40 48             	mov    0x48(%eax),%eax
  802318:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80231c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802320:	c7 04 24 b4 41 80 00 	movl   $0x8041b4,(%esp)
  802327:	e8 34 e8 ff ff       	call   800b60 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80232c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802331:	eb 1d                	jmp    802350 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  802333:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802336:	8b 52 18             	mov    0x18(%edx),%edx
  802339:	85 d2                	test   %edx,%edx
  80233b:	74 0e                	je     80234b <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80233d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802340:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802344:	89 04 24             	mov    %eax,(%esp)
  802347:	ff d2                	call   *%edx
  802349:	eb 05                	jmp    802350 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80234b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  802350:	83 c4 24             	add    $0x24,%esp
  802353:	5b                   	pop    %ebx
  802354:	5d                   	pop    %ebp
  802355:	c3                   	ret    

00802356 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802356:	55                   	push   %ebp
  802357:	89 e5                	mov    %esp,%ebp
  802359:	53                   	push   %ebx
  80235a:	83 ec 24             	sub    $0x24,%esp
  80235d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802360:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802363:	89 44 24 04          	mov    %eax,0x4(%esp)
  802367:	8b 45 08             	mov    0x8(%ebp),%eax
  80236a:	89 04 24             	mov    %eax,(%esp)
  80236d:	e8 34 fb ff ff       	call   801ea6 <fd_lookup>
  802372:	89 c2                	mov    %eax,%edx
  802374:	85 d2                	test   %edx,%edx
  802376:	78 52                	js     8023ca <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802378:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80237b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80237f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802382:	8b 00                	mov    (%eax),%eax
  802384:	89 04 24             	mov    %eax,(%esp)
  802387:	e8 70 fb ff ff       	call   801efc <dev_lookup>
  80238c:	85 c0                	test   %eax,%eax
  80238e:	78 3a                	js     8023ca <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  802390:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802393:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802397:	74 2c                	je     8023c5 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802399:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80239c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8023a3:	00 00 00 
	stat->st_isdir = 0;
  8023a6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8023ad:	00 00 00 
	stat->st_dev = dev;
  8023b0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8023b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8023ba:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8023bd:	89 14 24             	mov    %edx,(%esp)
  8023c0:	ff 50 14             	call   *0x14(%eax)
  8023c3:	eb 05                	jmp    8023ca <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8023c5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8023ca:	83 c4 24             	add    $0x24,%esp
  8023cd:	5b                   	pop    %ebx
  8023ce:	5d                   	pop    %ebp
  8023cf:	c3                   	ret    

008023d0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8023d0:	55                   	push   %ebp
  8023d1:	89 e5                	mov    %esp,%ebp
  8023d3:	56                   	push   %esi
  8023d4:	53                   	push   %ebx
  8023d5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8023d8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8023df:	00 
  8023e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8023e3:	89 04 24             	mov    %eax,(%esp)
  8023e6:	e8 28 02 00 00       	call   802613 <open>
  8023eb:	89 c3                	mov    %eax,%ebx
  8023ed:	85 db                	test   %ebx,%ebx
  8023ef:	78 1b                	js     80240c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8023f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023f8:	89 1c 24             	mov    %ebx,(%esp)
  8023fb:	e8 56 ff ff ff       	call   802356 <fstat>
  802400:	89 c6                	mov    %eax,%esi
	close(fd);
  802402:	89 1c 24             	mov    %ebx,(%esp)
  802405:	e8 cd fb ff ff       	call   801fd7 <close>
	return r;
  80240a:	89 f0                	mov    %esi,%eax
}
  80240c:	83 c4 10             	add    $0x10,%esp
  80240f:	5b                   	pop    %ebx
  802410:	5e                   	pop    %esi
  802411:	5d                   	pop    %ebp
  802412:	c3                   	ret    

00802413 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802413:	55                   	push   %ebp
  802414:	89 e5                	mov    %esp,%ebp
  802416:	56                   	push   %esi
  802417:	53                   	push   %ebx
  802418:	83 ec 10             	sub    $0x10,%esp
  80241b:	89 c6                	mov    %eax,%esi
  80241d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80241f:	83 3d 20 64 80 00 00 	cmpl   $0x0,0x806420
  802426:	75 11                	jne    802439 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802428:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80242f:	e8 51 14 00 00       	call   803885 <ipc_find_env>
  802434:	a3 20 64 80 00       	mov    %eax,0x806420
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802439:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802440:	00 
  802441:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802448:	00 
  802449:	89 74 24 04          	mov    %esi,0x4(%esp)
  80244d:	a1 20 64 80 00       	mov    0x806420,%eax
  802452:	89 04 24             	mov    %eax,(%esp)
  802455:	e8 c0 13 00 00       	call   80381a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80245a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802461:	00 
  802462:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802466:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80246d:	e8 2e 13 00 00       	call   8037a0 <ipc_recv>
}
  802472:	83 c4 10             	add    $0x10,%esp
  802475:	5b                   	pop    %ebx
  802476:	5e                   	pop    %esi
  802477:	5d                   	pop    %ebp
  802478:	c3                   	ret    

00802479 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802479:	55                   	push   %ebp
  80247a:	89 e5                	mov    %esp,%ebp
  80247c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80247f:	8b 45 08             	mov    0x8(%ebp),%eax
  802482:	8b 40 0c             	mov    0xc(%eax),%eax
  802485:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  80248a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80248d:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802492:	ba 00 00 00 00       	mov    $0x0,%edx
  802497:	b8 02 00 00 00       	mov    $0x2,%eax
  80249c:	e8 72 ff ff ff       	call   802413 <fsipc>
}
  8024a1:	c9                   	leave  
  8024a2:	c3                   	ret    

008024a3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8024a3:	55                   	push   %ebp
  8024a4:	89 e5                	mov    %esp,%ebp
  8024a6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8024a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8024ac:	8b 40 0c             	mov    0xc(%eax),%eax
  8024af:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8024b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8024b9:	b8 06 00 00 00       	mov    $0x6,%eax
  8024be:	e8 50 ff ff ff       	call   802413 <fsipc>
}
  8024c3:	c9                   	leave  
  8024c4:	c3                   	ret    

008024c5 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8024c5:	55                   	push   %ebp
  8024c6:	89 e5                	mov    %esp,%ebp
  8024c8:	53                   	push   %ebx
  8024c9:	83 ec 14             	sub    $0x14,%esp
  8024cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8024cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8024d2:	8b 40 0c             	mov    0xc(%eax),%eax
  8024d5:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8024da:	ba 00 00 00 00       	mov    $0x0,%edx
  8024df:	b8 05 00 00 00       	mov    $0x5,%eax
  8024e4:	e8 2a ff ff ff       	call   802413 <fsipc>
  8024e9:	89 c2                	mov    %eax,%edx
  8024eb:	85 d2                	test   %edx,%edx
  8024ed:	78 2b                	js     80251a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8024ef:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8024f6:	00 
  8024f7:	89 1c 24             	mov    %ebx,(%esp)
  8024fa:	e8 78 ed ff ff       	call   801277 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8024ff:	a1 80 70 80 00       	mov    0x807080,%eax
  802504:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80250a:	a1 84 70 80 00       	mov    0x807084,%eax
  80250f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802515:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80251a:	83 c4 14             	add    $0x14,%esp
  80251d:	5b                   	pop    %ebx
  80251e:	5d                   	pop    %ebp
  80251f:	c3                   	ret    

00802520 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802520:	55                   	push   %ebp
  802521:	89 e5                	mov    %esp,%ebp
  802523:	83 ec 18             	sub    $0x18,%esp
  802526:	8b 45 10             	mov    0x10(%ebp),%eax
  802529:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80252e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  802533:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802536:	8b 55 08             	mov    0x8(%ebp),%edx
  802539:	8b 52 0c             	mov    0xc(%edx),%edx
  80253c:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = n;
  802542:	a3 04 70 80 00       	mov    %eax,0x807004

	memmove(fsipcbuf.write.req_buf, buf, n);
  802547:	89 44 24 08          	mov    %eax,0x8(%esp)
  80254b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80254e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802552:	c7 04 24 08 70 80 00 	movl   $0x807008,(%esp)
  802559:	e8 b6 ee ff ff       	call   801414 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  80255e:	ba 00 00 00 00       	mov    $0x0,%edx
  802563:	b8 04 00 00 00       	mov    $0x4,%eax
  802568:	e8 a6 fe ff ff       	call   802413 <fsipc>
}
  80256d:	c9                   	leave  
  80256e:	c3                   	ret    

0080256f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80256f:	55                   	push   %ebp
  802570:	89 e5                	mov    %esp,%ebp
  802572:	56                   	push   %esi
  802573:	53                   	push   %ebx
  802574:	83 ec 10             	sub    $0x10,%esp
  802577:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80257a:	8b 45 08             	mov    0x8(%ebp),%eax
  80257d:	8b 40 0c             	mov    0xc(%eax),%eax
  802580:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  802585:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80258b:	ba 00 00 00 00       	mov    $0x0,%edx
  802590:	b8 03 00 00 00       	mov    $0x3,%eax
  802595:	e8 79 fe ff ff       	call   802413 <fsipc>
  80259a:	89 c3                	mov    %eax,%ebx
  80259c:	85 c0                	test   %eax,%eax
  80259e:	78 6a                	js     80260a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8025a0:	39 c6                	cmp    %eax,%esi
  8025a2:	73 24                	jae    8025c8 <devfile_read+0x59>
  8025a4:	c7 44 24 0c 24 42 80 	movl   $0x804224,0xc(%esp)
  8025ab:	00 
  8025ac:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  8025b3:	00 
  8025b4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8025bb:	00 
  8025bc:	c7 04 24 2b 42 80 00 	movl   $0x80422b,(%esp)
  8025c3:	e8 9f e4 ff ff       	call   800a67 <_panic>
	assert(r <= PGSIZE);
  8025c8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8025cd:	7e 24                	jle    8025f3 <devfile_read+0x84>
  8025cf:	c7 44 24 0c 36 42 80 	movl   $0x804236,0xc(%esp)
  8025d6:	00 
  8025d7:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  8025de:	00 
  8025df:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8025e6:	00 
  8025e7:	c7 04 24 2b 42 80 00 	movl   $0x80422b,(%esp)
  8025ee:	e8 74 e4 ff ff       	call   800a67 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8025f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025f7:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8025fe:	00 
  8025ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  802602:	89 04 24             	mov    %eax,(%esp)
  802605:	e8 0a ee ff ff       	call   801414 <memmove>
	return r;
}
  80260a:	89 d8                	mov    %ebx,%eax
  80260c:	83 c4 10             	add    $0x10,%esp
  80260f:	5b                   	pop    %ebx
  802610:	5e                   	pop    %esi
  802611:	5d                   	pop    %ebp
  802612:	c3                   	ret    

00802613 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802613:	55                   	push   %ebp
  802614:	89 e5                	mov    %esp,%ebp
  802616:	53                   	push   %ebx
  802617:	83 ec 24             	sub    $0x24,%esp
  80261a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80261d:	89 1c 24             	mov    %ebx,(%esp)
  802620:	e8 1b ec ff ff       	call   801240 <strlen>
  802625:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80262a:	7f 60                	jg     80268c <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80262c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80262f:	89 04 24             	mov    %eax,(%esp)
  802632:	e8 20 f8 ff ff       	call   801e57 <fd_alloc>
  802637:	89 c2                	mov    %eax,%edx
  802639:	85 d2                	test   %edx,%edx
  80263b:	78 54                	js     802691 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80263d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802641:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  802648:	e8 2a ec ff ff       	call   801277 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80264d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802650:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802655:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802658:	b8 01 00 00 00       	mov    $0x1,%eax
  80265d:	e8 b1 fd ff ff       	call   802413 <fsipc>
  802662:	89 c3                	mov    %eax,%ebx
  802664:	85 c0                	test   %eax,%eax
  802666:	79 17                	jns    80267f <open+0x6c>
		fd_close(fd, 0);
  802668:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80266f:	00 
  802670:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802673:	89 04 24             	mov    %eax,(%esp)
  802676:	e8 db f8 ff ff       	call   801f56 <fd_close>
		return r;
  80267b:	89 d8                	mov    %ebx,%eax
  80267d:	eb 12                	jmp    802691 <open+0x7e>
	}

	return fd2num(fd);
  80267f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802682:	89 04 24             	mov    %eax,(%esp)
  802685:	e8 a6 f7 ff ff       	call   801e30 <fd2num>
  80268a:	eb 05                	jmp    802691 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80268c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802691:	83 c4 24             	add    $0x24,%esp
  802694:	5b                   	pop    %ebx
  802695:	5d                   	pop    %ebp
  802696:	c3                   	ret    

00802697 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802697:	55                   	push   %ebp
  802698:	89 e5                	mov    %esp,%ebp
  80269a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80269d:	ba 00 00 00 00       	mov    $0x0,%edx
  8026a2:	b8 08 00 00 00       	mov    $0x8,%eax
  8026a7:	e8 67 fd ff ff       	call   802413 <fsipc>
}
  8026ac:	c9                   	leave  
  8026ad:	c3                   	ret    

008026ae <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  8026ae:	55                   	push   %ebp
  8026af:	89 e5                	mov    %esp,%ebp
  8026b1:	53                   	push   %ebx
  8026b2:	83 ec 14             	sub    $0x14,%esp
  8026b5:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  8026b7:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8026bb:	7e 31                	jle    8026ee <writebuf+0x40>
		ssize_t result = write(b->fd, b->buf, b->idx);
  8026bd:	8b 40 04             	mov    0x4(%eax),%eax
  8026c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026c4:	8d 43 10             	lea    0x10(%ebx),%eax
  8026c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026cb:	8b 03                	mov    (%ebx),%eax
  8026cd:	89 04 24             	mov    %eax,(%esp)
  8026d0:	e8 42 fb ff ff       	call   802217 <write>
		if (result > 0)
  8026d5:	85 c0                	test   %eax,%eax
  8026d7:	7e 03                	jle    8026dc <writebuf+0x2e>
			b->result += result;
  8026d9:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8026dc:	39 43 04             	cmp    %eax,0x4(%ebx)
  8026df:	74 0d                	je     8026ee <writebuf+0x40>
			b->error = (result < 0 ? result : 0);
  8026e1:	85 c0                	test   %eax,%eax
  8026e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8026e8:	0f 4f c2             	cmovg  %edx,%eax
  8026eb:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8026ee:	83 c4 14             	add    $0x14,%esp
  8026f1:	5b                   	pop    %ebx
  8026f2:	5d                   	pop    %ebp
  8026f3:	c3                   	ret    

008026f4 <putch>:

static void
putch(int ch, void *thunk)
{
  8026f4:	55                   	push   %ebp
  8026f5:	89 e5                	mov    %esp,%ebp
  8026f7:	53                   	push   %ebx
  8026f8:	83 ec 04             	sub    $0x4,%esp
  8026fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8026fe:	8b 53 04             	mov    0x4(%ebx),%edx
  802701:	8d 42 01             	lea    0x1(%edx),%eax
  802704:	89 43 04             	mov    %eax,0x4(%ebx)
  802707:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80270a:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80270e:	3d 00 01 00 00       	cmp    $0x100,%eax
  802713:	75 0e                	jne    802723 <putch+0x2f>
		writebuf(b);
  802715:	89 d8                	mov    %ebx,%eax
  802717:	e8 92 ff ff ff       	call   8026ae <writebuf>
		b->idx = 0;
  80271c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  802723:	83 c4 04             	add    $0x4,%esp
  802726:	5b                   	pop    %ebx
  802727:	5d                   	pop    %ebp
  802728:	c3                   	ret    

00802729 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  802729:	55                   	push   %ebp
  80272a:	89 e5                	mov    %esp,%ebp
  80272c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  802732:	8b 45 08             	mov    0x8(%ebp),%eax
  802735:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80273b:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  802742:	00 00 00 
	b.result = 0;
  802745:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80274c:	00 00 00 
	b.error = 1;
  80274f:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  802756:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  802759:	8b 45 10             	mov    0x10(%ebp),%eax
  80275c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802760:	8b 45 0c             	mov    0xc(%ebp),%eax
  802763:	89 44 24 08          	mov    %eax,0x8(%esp)
  802767:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80276d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802771:	c7 04 24 f4 26 80 00 	movl   $0x8026f4,(%esp)
  802778:	e8 71 e5 ff ff       	call   800cee <vprintfmt>
	if (b.idx > 0)
  80277d:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  802784:	7e 0b                	jle    802791 <vfprintf+0x68>
		writebuf(&b);
  802786:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80278c:	e8 1d ff ff ff       	call   8026ae <writebuf>

	return (b.result ? b.result : b.error);
  802791:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  802797:	85 c0                	test   %eax,%eax
  802799:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8027a0:	c9                   	leave  
  8027a1:	c3                   	ret    

008027a2 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8027a2:	55                   	push   %ebp
  8027a3:	89 e5                	mov    %esp,%ebp
  8027a5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8027a8:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8027ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8027af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8027b9:	89 04 24             	mov    %eax,(%esp)
  8027bc:	e8 68 ff ff ff       	call   802729 <vfprintf>
	va_end(ap);

	return cnt;
}
  8027c1:	c9                   	leave  
  8027c2:	c3                   	ret    

008027c3 <printf>:

int
printf(const char *fmt, ...)
{
  8027c3:	55                   	push   %ebp
  8027c4:	89 e5                	mov    %esp,%ebp
  8027c6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8027c9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8027cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8027d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8027d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027d7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8027de:	e8 46 ff ff ff       	call   802729 <vfprintf>
	va_end(ap);

	return cnt;
}
  8027e3:	c9                   	leave  
  8027e4:	c3                   	ret    
  8027e5:	66 90                	xchg   %ax,%ax
  8027e7:	66 90                	xchg   %ax,%ax
  8027e9:	66 90                	xchg   %ax,%ax
  8027eb:	66 90                	xchg   %ax,%ax
  8027ed:	66 90                	xchg   %ax,%ax
  8027ef:	90                   	nop

008027f0 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8027f0:	55                   	push   %ebp
  8027f1:	89 e5                	mov    %esp,%ebp
  8027f3:	57                   	push   %edi
  8027f4:	56                   	push   %esi
  8027f5:	53                   	push   %ebx
  8027f6:	81 ec 9c 02 00 00    	sub    $0x29c,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8027fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802803:	00 
  802804:	8b 45 08             	mov    0x8(%ebp),%eax
  802807:	89 04 24             	mov    %eax,(%esp)
  80280a:	e8 04 fe ff ff       	call   802613 <open>
  80280f:	89 c2                	mov    %eax,%edx
  802811:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  802817:	85 c0                	test   %eax,%eax
  802819:	0f 88 3e 05 00 00    	js     802d5d <spawn+0x56d>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80281f:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  802826:	00 
  802827:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80282d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802831:	89 14 24             	mov    %edx,(%esp)
  802834:	e8 93 f9 ff ff       	call   8021cc <readn>
  802839:	3d 00 02 00 00       	cmp    $0x200,%eax
  80283e:	75 0c                	jne    80284c <spawn+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  802840:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802847:	45 4c 46 
  80284a:	74 36                	je     802882 <spawn+0x92>
		close(fd);
  80284c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802852:	89 04 24             	mov    %eax,(%esp)
  802855:	e8 7d f7 ff ff       	call   801fd7 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80285a:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  802861:	46 
  802862:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  802868:	89 44 24 04          	mov    %eax,0x4(%esp)
  80286c:	c7 04 24 42 42 80 00 	movl   $0x804242,(%esp)
  802873:	e8 e8 e2 ff ff       	call   800b60 <cprintf>
		return -E_NOT_EXEC;
  802878:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  80287d:	e9 3a 05 00 00       	jmp    802dbc <spawn+0x5cc>
  802882:	b8 07 00 00 00       	mov    $0x7,%eax
  802887:	cd 30                	int    $0x30
  802889:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80288f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802895:	85 c0                	test   %eax,%eax
  802897:	0f 88 c8 04 00 00    	js     802d65 <spawn+0x575>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80289d:	89 c6                	mov    %eax,%esi
  80289f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8028a5:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8028a8:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8028ae:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8028b4:	b9 11 00 00 00       	mov    $0x11,%ecx
  8028b9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8028bb:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8028c1:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8028c7:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8028cc:	be 00 00 00 00       	mov    $0x0,%esi
  8028d1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8028d4:	eb 0f                	jmp    8028e5 <spawn+0xf5>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8028d6:	89 04 24             	mov    %eax,(%esp)
  8028d9:	e8 62 e9 ff ff       	call   801240 <strlen>
  8028de:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8028e2:	83 c3 01             	add    $0x1,%ebx
  8028e5:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8028ec:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8028ef:	85 c0                	test   %eax,%eax
  8028f1:	75 e3                	jne    8028d6 <spawn+0xe6>
  8028f3:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  8028f9:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8028ff:	bf 00 10 40 00       	mov    $0x401000,%edi
  802904:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802906:	89 fa                	mov    %edi,%edx
  802908:	83 e2 fc             	and    $0xfffffffc,%edx
  80290b:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  802912:	29 c2                	sub    %eax,%edx
  802914:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80291a:	8d 42 f8             	lea    -0x8(%edx),%eax
  80291d:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  802922:	0f 86 4d 04 00 00    	jbe    802d75 <spawn+0x585>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802928:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80292f:	00 
  802930:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802937:	00 
  802938:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80293f:	e8 4f ed ff ff       	call   801693 <sys_page_alloc>
  802944:	85 c0                	test   %eax,%eax
  802946:	0f 88 70 04 00 00    	js     802dbc <spawn+0x5cc>
  80294c:	be 00 00 00 00       	mov    $0x0,%esi
  802951:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  802957:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80295a:	eb 30                	jmp    80298c <spawn+0x19c>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80295c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802962:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802968:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  80296b:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  80296e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802972:	89 3c 24             	mov    %edi,(%esp)
  802975:	e8 fd e8 ff ff       	call   801277 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80297a:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  80297d:	89 04 24             	mov    %eax,(%esp)
  802980:	e8 bb e8 ff ff       	call   801240 <strlen>
  802985:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802989:	83 c6 01             	add    $0x1,%esi
  80298c:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  802992:	7f c8                	jg     80295c <spawn+0x16c>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  802994:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80299a:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  8029a0:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8029a7:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8029ad:	74 24                	je     8029d3 <spawn+0x1e3>
  8029af:	c7 44 24 0c b8 42 80 	movl   $0x8042b8,0xc(%esp)
  8029b6:	00 
  8029b7:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  8029be:	00 
  8029bf:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  8029c6:	00 
  8029c7:	c7 04 24 5c 42 80 00 	movl   $0x80425c,(%esp)
  8029ce:	e8 94 e0 ff ff       	call   800a67 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8029d3:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8029d9:	89 c8                	mov    %ecx,%eax
  8029db:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8029e0:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  8029e3:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  8029e9:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8029ec:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  8029f2:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8029f8:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8029ff:	00 
  802a00:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  802a07:	ee 
  802a08:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802a0e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802a12:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802a19:	00 
  802a1a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a21:	e8 c1 ec ff ff       	call   8016e7 <sys_page_map>
  802a26:	89 c3                	mov    %eax,%ebx
  802a28:	85 c0                	test   %eax,%eax
  802a2a:	0f 88 76 03 00 00    	js     802da6 <spawn+0x5b6>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802a30:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802a37:	00 
  802a38:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a3f:	e8 f6 ec ff ff       	call   80173a <sys_page_unmap>
  802a44:	89 c3                	mov    %eax,%ebx
  802a46:	85 c0                	test   %eax,%eax
  802a48:	0f 88 58 03 00 00    	js     802da6 <spawn+0x5b6>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802a4e:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  802a54:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  802a5b:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802a61:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  802a68:	00 00 00 
  802a6b:	e9 b6 01 00 00       	jmp    802c26 <spawn+0x436>
		if (ph->p_type != ELF_PROG_LOAD)
  802a70:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802a76:	83 38 01             	cmpl   $0x1,(%eax)
  802a79:	0f 85 99 01 00 00    	jne    802c18 <spawn+0x428>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802a7f:	89 c2                	mov    %eax,%edx
  802a81:	8b 40 18             	mov    0x18(%eax),%eax
  802a84:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  802a87:	83 f8 01             	cmp    $0x1,%eax
  802a8a:	19 c0                	sbb    %eax,%eax
  802a8c:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  802a92:	83 a5 90 fd ff ff fe 	andl   $0xfffffffe,-0x270(%ebp)
  802a99:	83 85 90 fd ff ff 07 	addl   $0x7,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802aa0:	89 d0                	mov    %edx,%eax
  802aa2:	8b 52 04             	mov    0x4(%edx),%edx
  802aa5:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  802aab:	8b 50 10             	mov    0x10(%eax),%edx
  802aae:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)
  802ab4:	8b 48 14             	mov    0x14(%eax),%ecx
  802ab7:	89 8d 8c fd ff ff    	mov    %ecx,-0x274(%ebp)
  802abd:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802ac0:	89 f0                	mov    %esi,%eax
  802ac2:	25 ff 0f 00 00       	and    $0xfff,%eax
  802ac7:	74 14                	je     802add <spawn+0x2ed>
		va -= i;
  802ac9:	29 c6                	sub    %eax,%esi
		memsz += i;
  802acb:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  802ad1:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  802ad7:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802add:	bb 00 00 00 00       	mov    $0x0,%ebx
  802ae2:	e9 23 01 00 00       	jmp    802c0a <spawn+0x41a>
		if (i >= filesz) {
  802ae7:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  802aed:	77 2b                	ja     802b1a <spawn+0x32a>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802aef:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802af5:	89 44 24 08          	mov    %eax,0x8(%esp)
  802af9:	89 74 24 04          	mov    %esi,0x4(%esp)
  802afd:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802b03:	89 04 24             	mov    %eax,(%esp)
  802b06:	e8 88 eb ff ff       	call   801693 <sys_page_alloc>
  802b0b:	85 c0                	test   %eax,%eax
  802b0d:	0f 89 eb 00 00 00    	jns    802bfe <spawn+0x40e>
  802b13:	89 c3                	mov    %eax,%ebx
  802b15:	e9 6c 02 00 00       	jmp    802d86 <spawn+0x596>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802b1a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802b21:	00 
  802b22:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802b29:	00 
  802b2a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b31:	e8 5d eb ff ff       	call   801693 <sys_page_alloc>
  802b36:	85 c0                	test   %eax,%eax
  802b38:	0f 88 3e 02 00 00    	js     802d7c <spawn+0x58c>
  802b3e:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802b44:	01 f8                	add    %edi,%eax
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802b46:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b4a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802b50:	89 04 24             	mov    %eax,(%esp)
  802b53:	e8 4c f7 ff ff       	call   8022a4 <seek>
  802b58:	85 c0                	test   %eax,%eax
  802b5a:	0f 88 20 02 00 00    	js     802d80 <spawn+0x590>
  802b60:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  802b66:	29 f9                	sub    %edi,%ecx
  802b68:	89 c8                	mov    %ecx,%eax
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802b6a:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
  802b70:	b9 00 10 00 00       	mov    $0x1000,%ecx
  802b75:	0f 47 c1             	cmova  %ecx,%eax
  802b78:	89 44 24 08          	mov    %eax,0x8(%esp)
  802b7c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802b83:	00 
  802b84:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802b8a:	89 04 24             	mov    %eax,(%esp)
  802b8d:	e8 3a f6 ff ff       	call   8021cc <readn>
  802b92:	85 c0                	test   %eax,%eax
  802b94:	0f 88 ea 01 00 00    	js     802d84 <spawn+0x594>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802b9a:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802ba0:	89 44 24 10          	mov    %eax,0x10(%esp)
  802ba4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802ba8:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802bae:	89 44 24 08          	mov    %eax,0x8(%esp)
  802bb2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802bb9:	00 
  802bba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802bc1:	e8 21 eb ff ff       	call   8016e7 <sys_page_map>
  802bc6:	85 c0                	test   %eax,%eax
  802bc8:	79 20                	jns    802bea <spawn+0x3fa>
				panic("spawn: sys_page_map data: %e", r);
  802bca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802bce:	c7 44 24 08 68 42 80 	movl   $0x804268,0x8(%esp)
  802bd5:	00 
  802bd6:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  802bdd:	00 
  802bde:	c7 04 24 5c 42 80 00 	movl   $0x80425c,(%esp)
  802be5:	e8 7d de ff ff       	call   800a67 <_panic>
			sys_page_unmap(0, UTEMP);
  802bea:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802bf1:	00 
  802bf2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802bf9:	e8 3c eb ff ff       	call   80173a <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802bfe:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802c04:	81 c6 00 10 00 00    	add    $0x1000,%esi
  802c0a:	89 df                	mov    %ebx,%edi
  802c0c:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  802c12:	0f 87 cf fe ff ff    	ja     802ae7 <spawn+0x2f7>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802c18:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  802c1f:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  802c26:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802c2d:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  802c33:	0f 8c 37 fe ff ff    	jl     802a70 <spawn+0x280>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802c39:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802c3f:	89 04 24             	mov    %eax,(%esp)
  802c42:	e8 90 f3 ff ff       	call   801fd7 <close>
// Copy the mappings for shared pages into the child address space.
static int
copy_shared_pages(envid_t child)
{
	uintptr_t addr;
	int r = 0;
  802c47:	be 00 00 00 00       	mov    $0x0,%esi

	for(addr = 0; addr < UTOP - PGSIZE; addr+=PGSIZE) {
  802c4c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)]) {
  802c51:	89 d8                	mov    %ebx,%eax
  802c53:	c1 e8 16             	shr    $0x16,%eax
  802c56:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802c5d:	85 c0                	test   %eax,%eax
  802c5f:	74 4e                	je     802caf <spawn+0x4bf>
  802c61:	89 d8                	mov    %ebx,%eax
  802c63:	c1 e8 0c             	shr    $0xc,%eax
  802c66:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802c6d:	85 d2                	test   %edx,%edx
  802c6f:	74 3e                	je     802caf <spawn+0x4bf>
			if(uvpt[PGNUM(addr)] & PTE_SHARE) {
  802c71:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802c78:	f6 c6 04             	test   $0x4,%dh
  802c7b:	74 32                	je     802caf <spawn+0x4bf>
				r += sys_page_map(sys_getenvid(), (void*)addr, child, (void*)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL);
  802c7d:	8b 3c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edi
  802c84:	e8 cc e9 ff ff       	call   801655 <sys_getenvid>
  802c89:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  802c8f:	89 7c 24 10          	mov    %edi,0x10(%esp)
  802c93:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802c97:	8b 95 84 fd ff ff    	mov    -0x27c(%ebp),%edx
  802c9d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802ca1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802ca5:	89 04 24             	mov    %eax,(%esp)
  802ca8:	e8 3a ea ff ff       	call   8016e7 <sys_page_map>
  802cad:	01 c6                	add    %eax,%esi
copy_shared_pages(envid_t child)
{
	uintptr_t addr;
	int r = 0;

	for(addr = 0; addr < UTOP - PGSIZE; addr+=PGSIZE) {
  802caf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802cb5:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  802cbb:	75 94                	jne    802c51 <spawn+0x461>
			if(uvpt[PGNUM(addr)] & PTE_SHARE) {
				r += sys_page_map(sys_getenvid(), (void*)addr, child, (void*)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL);
			}
		}
	}
	if(r<0) {
  802cbd:	85 f6                	test   %esi,%esi
  802cbf:	79 1c                	jns    802cdd <spawn+0x4ed>
		panic("Something went wrong in copy_shared_pages");
  802cc1:	c7 44 24 08 e0 42 80 	movl   $0x8042e0,0x8(%esp)
  802cc8:	00 
  802cc9:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
  802cd0:	00 
  802cd1:	c7 04 24 5c 42 80 00 	movl   $0x80425c,(%esp)
  802cd8:	e8 8a dd ff ff       	call   800a67 <_panic>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802cdd:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802ce4:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802ce7:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802ced:	89 44 24 04          	mov    %eax,0x4(%esp)
  802cf1:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802cf7:	89 04 24             	mov    %eax,(%esp)
  802cfa:	e8 e1 ea ff ff       	call   8017e0 <sys_env_set_trapframe>
  802cff:	85 c0                	test   %eax,%eax
  802d01:	79 20                	jns    802d23 <spawn+0x533>
		panic("sys_env_set_trapframe: %e", r);
  802d03:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802d07:	c7 44 24 08 85 42 80 	movl   $0x804285,0x8(%esp)
  802d0e:	00 
  802d0f:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  802d16:	00 
  802d17:	c7 04 24 5c 42 80 00 	movl   $0x80425c,(%esp)
  802d1e:	e8 44 dd ff ff       	call   800a67 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802d23:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  802d2a:	00 
  802d2b:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802d31:	89 04 24             	mov    %eax,(%esp)
  802d34:	e8 54 ea ff ff       	call   80178d <sys_env_set_status>
  802d39:	85 c0                	test   %eax,%eax
  802d3b:	79 30                	jns    802d6d <spawn+0x57d>
		panic("sys_env_set_status: %e", r);
  802d3d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802d41:	c7 44 24 08 9f 42 80 	movl   $0x80429f,0x8(%esp)
  802d48:	00 
  802d49:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  802d50:	00 
  802d51:	c7 04 24 5c 42 80 00 	movl   $0x80425c,(%esp)
  802d58:	e8 0a dd ff ff       	call   800a67 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802d5d:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802d63:	eb 57                	jmp    802dbc <spawn+0x5cc>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802d65:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802d6b:	eb 4f                	jmp    802dbc <spawn+0x5cc>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  802d6d:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802d73:	eb 47                	jmp    802dbc <spawn+0x5cc>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802d75:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  802d7a:	eb 40                	jmp    802dbc <spawn+0x5cc>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802d7c:	89 c3                	mov    %eax,%ebx
  802d7e:	eb 06                	jmp    802d86 <spawn+0x596>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802d80:	89 c3                	mov    %eax,%ebx
  802d82:	eb 02                	jmp    802d86 <spawn+0x596>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802d84:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802d86:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802d8c:	89 04 24             	mov    %eax,(%esp)
  802d8f:	e8 6f e8 ff ff       	call   801603 <sys_env_destroy>
	close(fd);
  802d94:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802d9a:	89 04 24             	mov    %eax,(%esp)
  802d9d:	e8 35 f2 ff ff       	call   801fd7 <close>
	return r;
  802da2:	89 d8                	mov    %ebx,%eax
  802da4:	eb 16                	jmp    802dbc <spawn+0x5cc>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802da6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802dad:	00 
  802dae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802db5:	e8 80 e9 ff ff       	call   80173a <sys_page_unmap>
  802dba:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802dbc:	81 c4 9c 02 00 00    	add    $0x29c,%esp
  802dc2:	5b                   	pop    %ebx
  802dc3:	5e                   	pop    %esi
  802dc4:	5f                   	pop    %edi
  802dc5:	5d                   	pop    %ebp
  802dc6:	c3                   	ret    

00802dc7 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802dc7:	55                   	push   %ebp
  802dc8:	89 e5                	mov    %esp,%ebp
  802dca:	56                   	push   %esi
  802dcb:	53                   	push   %ebx
  802dcc:	83 ec 10             	sub    $0x10,%esp
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802dcf:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802dd2:	ba 00 00 00 00       	mov    $0x0,%edx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802dd7:	eb 03                	jmp    802ddc <spawnl+0x15>
		argc++;
  802dd9:	83 c2 01             	add    $0x1,%edx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802ddc:	83 c0 04             	add    $0x4,%eax
  802ddf:	83 78 fc 00          	cmpl   $0x0,-0x4(%eax)
  802de3:	75 f4                	jne    802dd9 <spawnl+0x12>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802de5:	8d 04 95 1a 00 00 00 	lea    0x1a(,%edx,4),%eax
  802dec:	83 e0 f0             	and    $0xfffffff0,%eax
  802def:	29 c4                	sub    %eax,%esp
  802df1:	8d 44 24 0b          	lea    0xb(%esp),%eax
  802df5:	c1 e8 02             	shr    $0x2,%eax
  802df8:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
  802dff:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802e01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802e04:	89 0c 85 00 00 00 00 	mov    %ecx,0x0(,%eax,4)
	argv[argc+1] = NULL;
  802e0b:	c7 44 96 04 00 00 00 	movl   $0x0,0x4(%esi,%edx,4)
  802e12:	00 

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802e13:	b8 00 00 00 00       	mov    $0x0,%eax
  802e18:	eb 0a                	jmp    802e24 <spawnl+0x5d>
		argv[i+1] = va_arg(vl, const char *);
  802e1a:	83 c0 01             	add    $0x1,%eax
  802e1d:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802e21:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802e24:	39 d0                	cmp    %edx,%eax
  802e26:	75 f2                	jne    802e1a <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802e28:	89 74 24 04          	mov    %esi,0x4(%esp)
  802e2c:	8b 45 08             	mov    0x8(%ebp),%eax
  802e2f:	89 04 24             	mov    %eax,(%esp)
  802e32:	e8 b9 f9 ff ff       	call   8027f0 <spawn>
}
  802e37:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e3a:	5b                   	pop    %ebx
  802e3b:	5e                   	pop    %esi
  802e3c:	5d                   	pop    %ebp
  802e3d:	c3                   	ret    
  802e3e:	66 90                	xchg   %ax,%ax

00802e40 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802e40:	55                   	push   %ebp
  802e41:	89 e5                	mov    %esp,%ebp
  802e43:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  802e46:	c7 44 24 04 0a 43 80 	movl   $0x80430a,0x4(%esp)
  802e4d:	00 
  802e4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e51:	89 04 24             	mov    %eax,(%esp)
  802e54:	e8 1e e4 ff ff       	call   801277 <strcpy>
	return 0;
}
  802e59:	b8 00 00 00 00       	mov    $0x0,%eax
  802e5e:	c9                   	leave  
  802e5f:	c3                   	ret    

00802e60 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802e60:	55                   	push   %ebp
  802e61:	89 e5                	mov    %esp,%ebp
  802e63:	53                   	push   %ebx
  802e64:	83 ec 14             	sub    $0x14,%esp
  802e67:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  802e6a:	89 1c 24             	mov    %ebx,(%esp)
  802e6d:	e8 4b 0a 00 00       	call   8038bd <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  802e72:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  802e77:	83 f8 01             	cmp    $0x1,%eax
  802e7a:	75 0d                	jne    802e89 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  802e7c:	8b 43 0c             	mov    0xc(%ebx),%eax
  802e7f:	89 04 24             	mov    %eax,(%esp)
  802e82:	e8 29 03 00 00       	call   8031b0 <nsipc_close>
  802e87:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  802e89:	89 d0                	mov    %edx,%eax
  802e8b:	83 c4 14             	add    $0x14,%esp
  802e8e:	5b                   	pop    %ebx
  802e8f:	5d                   	pop    %ebp
  802e90:	c3                   	ret    

00802e91 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802e91:	55                   	push   %ebp
  802e92:	89 e5                	mov    %esp,%ebp
  802e94:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802e97:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802e9e:	00 
  802e9f:	8b 45 10             	mov    0x10(%ebp),%eax
  802ea2:	89 44 24 08          	mov    %eax,0x8(%esp)
  802ea6:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ea9:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ead:	8b 45 08             	mov    0x8(%ebp),%eax
  802eb0:	8b 40 0c             	mov    0xc(%eax),%eax
  802eb3:	89 04 24             	mov    %eax,(%esp)
  802eb6:	e8 f0 03 00 00       	call   8032ab <nsipc_send>
}
  802ebb:	c9                   	leave  
  802ebc:	c3                   	ret    

00802ebd <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  802ebd:	55                   	push   %ebp
  802ebe:	89 e5                	mov    %esp,%ebp
  802ec0:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802ec3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802eca:	00 
  802ecb:	8b 45 10             	mov    0x10(%ebp),%eax
  802ece:	89 44 24 08          	mov    %eax,0x8(%esp)
  802ed2:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ed5:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ed9:	8b 45 08             	mov    0x8(%ebp),%eax
  802edc:	8b 40 0c             	mov    0xc(%eax),%eax
  802edf:	89 04 24             	mov    %eax,(%esp)
  802ee2:	e8 44 03 00 00       	call   80322b <nsipc_recv>
}
  802ee7:	c9                   	leave  
  802ee8:	c3                   	ret    

00802ee9 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802ee9:	55                   	push   %ebp
  802eea:	89 e5                	mov    %esp,%ebp
  802eec:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802eef:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802ef2:	89 54 24 04          	mov    %edx,0x4(%esp)
  802ef6:	89 04 24             	mov    %eax,(%esp)
  802ef9:	e8 a8 ef ff ff       	call   801ea6 <fd_lookup>
  802efe:	85 c0                	test   %eax,%eax
  802f00:	78 17                	js     802f19 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f05:	8b 0d 3c 50 80 00    	mov    0x80503c,%ecx
  802f0b:	39 08                	cmp    %ecx,(%eax)
  802f0d:	75 05                	jne    802f14 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802f0f:	8b 40 0c             	mov    0xc(%eax),%eax
  802f12:	eb 05                	jmp    802f19 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  802f14:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  802f19:	c9                   	leave  
  802f1a:	c3                   	ret    

00802f1b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  802f1b:	55                   	push   %ebp
  802f1c:	89 e5                	mov    %esp,%ebp
  802f1e:	56                   	push   %esi
  802f1f:	53                   	push   %ebx
  802f20:	83 ec 20             	sub    $0x20,%esp
  802f23:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802f25:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802f28:	89 04 24             	mov    %eax,(%esp)
  802f2b:	e8 27 ef ff ff       	call   801e57 <fd_alloc>
  802f30:	89 c3                	mov    %eax,%ebx
  802f32:	85 c0                	test   %eax,%eax
  802f34:	78 21                	js     802f57 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802f36:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802f3d:	00 
  802f3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f41:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f45:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f4c:	e8 42 e7 ff ff       	call   801693 <sys_page_alloc>
  802f51:	89 c3                	mov    %eax,%ebx
  802f53:	85 c0                	test   %eax,%eax
  802f55:	79 0c                	jns    802f63 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  802f57:	89 34 24             	mov    %esi,(%esp)
  802f5a:	e8 51 02 00 00       	call   8031b0 <nsipc_close>
		return r;
  802f5f:	89 d8                	mov    %ebx,%eax
  802f61:	eb 20                	jmp    802f83 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802f63:	8b 15 3c 50 80 00    	mov    0x80503c,%edx
  802f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f6c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802f6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802f71:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  802f78:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  802f7b:	89 14 24             	mov    %edx,(%esp)
  802f7e:	e8 ad ee ff ff       	call   801e30 <fd2num>
}
  802f83:	83 c4 20             	add    $0x20,%esp
  802f86:	5b                   	pop    %ebx
  802f87:	5e                   	pop    %esi
  802f88:	5d                   	pop    %ebp
  802f89:	c3                   	ret    

00802f8a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802f8a:	55                   	push   %ebp
  802f8b:	89 e5                	mov    %esp,%ebp
  802f8d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802f90:	8b 45 08             	mov    0x8(%ebp),%eax
  802f93:	e8 51 ff ff ff       	call   802ee9 <fd2sockid>
		return r;
  802f98:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  802f9a:	85 c0                	test   %eax,%eax
  802f9c:	78 23                	js     802fc1 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802f9e:	8b 55 10             	mov    0x10(%ebp),%edx
  802fa1:	89 54 24 08          	mov    %edx,0x8(%esp)
  802fa5:	8b 55 0c             	mov    0xc(%ebp),%edx
  802fa8:	89 54 24 04          	mov    %edx,0x4(%esp)
  802fac:	89 04 24             	mov    %eax,(%esp)
  802faf:	e8 45 01 00 00       	call   8030f9 <nsipc_accept>
		return r;
  802fb4:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802fb6:	85 c0                	test   %eax,%eax
  802fb8:	78 07                	js     802fc1 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  802fba:	e8 5c ff ff ff       	call   802f1b <alloc_sockfd>
  802fbf:	89 c1                	mov    %eax,%ecx
}
  802fc1:	89 c8                	mov    %ecx,%eax
  802fc3:	c9                   	leave  
  802fc4:	c3                   	ret    

00802fc5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802fc5:	55                   	push   %ebp
  802fc6:	89 e5                	mov    %esp,%ebp
  802fc8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802fcb:	8b 45 08             	mov    0x8(%ebp),%eax
  802fce:	e8 16 ff ff ff       	call   802ee9 <fd2sockid>
  802fd3:	89 c2                	mov    %eax,%edx
  802fd5:	85 d2                	test   %edx,%edx
  802fd7:	78 16                	js     802fef <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  802fd9:	8b 45 10             	mov    0x10(%ebp),%eax
  802fdc:	89 44 24 08          	mov    %eax,0x8(%esp)
  802fe0:	8b 45 0c             	mov    0xc(%ebp),%eax
  802fe3:	89 44 24 04          	mov    %eax,0x4(%esp)
  802fe7:	89 14 24             	mov    %edx,(%esp)
  802fea:	e8 60 01 00 00       	call   80314f <nsipc_bind>
}
  802fef:	c9                   	leave  
  802ff0:	c3                   	ret    

00802ff1 <shutdown>:

int
shutdown(int s, int how)
{
  802ff1:	55                   	push   %ebp
  802ff2:	89 e5                	mov    %esp,%ebp
  802ff4:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802ff7:	8b 45 08             	mov    0x8(%ebp),%eax
  802ffa:	e8 ea fe ff ff       	call   802ee9 <fd2sockid>
  802fff:	89 c2                	mov    %eax,%edx
  803001:	85 d2                	test   %edx,%edx
  803003:	78 0f                	js     803014 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  803005:	8b 45 0c             	mov    0xc(%ebp),%eax
  803008:	89 44 24 04          	mov    %eax,0x4(%esp)
  80300c:	89 14 24             	mov    %edx,(%esp)
  80300f:	e8 7a 01 00 00       	call   80318e <nsipc_shutdown>
}
  803014:	c9                   	leave  
  803015:	c3                   	ret    

00803016 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  803016:	55                   	push   %ebp
  803017:	89 e5                	mov    %esp,%ebp
  803019:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80301c:	8b 45 08             	mov    0x8(%ebp),%eax
  80301f:	e8 c5 fe ff ff       	call   802ee9 <fd2sockid>
  803024:	89 c2                	mov    %eax,%edx
  803026:	85 d2                	test   %edx,%edx
  803028:	78 16                	js     803040 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  80302a:	8b 45 10             	mov    0x10(%ebp),%eax
  80302d:	89 44 24 08          	mov    %eax,0x8(%esp)
  803031:	8b 45 0c             	mov    0xc(%ebp),%eax
  803034:	89 44 24 04          	mov    %eax,0x4(%esp)
  803038:	89 14 24             	mov    %edx,(%esp)
  80303b:	e8 8a 01 00 00       	call   8031ca <nsipc_connect>
}
  803040:	c9                   	leave  
  803041:	c3                   	ret    

00803042 <listen>:

int
listen(int s, int backlog)
{
  803042:	55                   	push   %ebp
  803043:	89 e5                	mov    %esp,%ebp
  803045:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803048:	8b 45 08             	mov    0x8(%ebp),%eax
  80304b:	e8 99 fe ff ff       	call   802ee9 <fd2sockid>
  803050:	89 c2                	mov    %eax,%edx
  803052:	85 d2                	test   %edx,%edx
  803054:	78 0f                	js     803065 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  803056:	8b 45 0c             	mov    0xc(%ebp),%eax
  803059:	89 44 24 04          	mov    %eax,0x4(%esp)
  80305d:	89 14 24             	mov    %edx,(%esp)
  803060:	e8 a4 01 00 00       	call   803209 <nsipc_listen>
}
  803065:	c9                   	leave  
  803066:	c3                   	ret    

00803067 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  803067:	55                   	push   %ebp
  803068:	89 e5                	mov    %esp,%ebp
  80306a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80306d:	8b 45 10             	mov    0x10(%ebp),%eax
  803070:	89 44 24 08          	mov    %eax,0x8(%esp)
  803074:	8b 45 0c             	mov    0xc(%ebp),%eax
  803077:	89 44 24 04          	mov    %eax,0x4(%esp)
  80307b:	8b 45 08             	mov    0x8(%ebp),%eax
  80307e:	89 04 24             	mov    %eax,(%esp)
  803081:	e8 98 02 00 00       	call   80331e <nsipc_socket>
  803086:	89 c2                	mov    %eax,%edx
  803088:	85 d2                	test   %edx,%edx
  80308a:	78 05                	js     803091 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  80308c:	e8 8a fe ff ff       	call   802f1b <alloc_sockfd>
}
  803091:	c9                   	leave  
  803092:	c3                   	ret    

00803093 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  803093:	55                   	push   %ebp
  803094:	89 e5                	mov    %esp,%ebp
  803096:	53                   	push   %ebx
  803097:	83 ec 14             	sub    $0x14,%esp
  80309a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80309c:	83 3d 24 64 80 00 00 	cmpl   $0x0,0x806424
  8030a3:	75 11                	jne    8030b6 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8030a5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8030ac:	e8 d4 07 00 00       	call   803885 <ipc_find_env>
  8030b1:	a3 24 64 80 00       	mov    %eax,0x806424
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8030b6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8030bd:	00 
  8030be:	c7 44 24 08 00 80 80 	movl   $0x808000,0x8(%esp)
  8030c5:	00 
  8030c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8030ca:	a1 24 64 80 00       	mov    0x806424,%eax
  8030cf:	89 04 24             	mov    %eax,(%esp)
  8030d2:	e8 43 07 00 00       	call   80381a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8030d7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8030de:	00 
  8030df:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8030e6:	00 
  8030e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8030ee:	e8 ad 06 00 00       	call   8037a0 <ipc_recv>
}
  8030f3:	83 c4 14             	add    $0x14,%esp
  8030f6:	5b                   	pop    %ebx
  8030f7:	5d                   	pop    %ebp
  8030f8:	c3                   	ret    

008030f9 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8030f9:	55                   	push   %ebp
  8030fa:	89 e5                	mov    %esp,%ebp
  8030fc:	56                   	push   %esi
  8030fd:	53                   	push   %ebx
  8030fe:	83 ec 10             	sub    $0x10,%esp
  803101:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  803104:	8b 45 08             	mov    0x8(%ebp),%eax
  803107:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80310c:	8b 06                	mov    (%esi),%eax
  80310e:	a3 04 80 80 00       	mov    %eax,0x808004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  803113:	b8 01 00 00 00       	mov    $0x1,%eax
  803118:	e8 76 ff ff ff       	call   803093 <nsipc>
  80311d:	89 c3                	mov    %eax,%ebx
  80311f:	85 c0                	test   %eax,%eax
  803121:	78 23                	js     803146 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  803123:	a1 10 80 80 00       	mov    0x808010,%eax
  803128:	89 44 24 08          	mov    %eax,0x8(%esp)
  80312c:	c7 44 24 04 00 80 80 	movl   $0x808000,0x4(%esp)
  803133:	00 
  803134:	8b 45 0c             	mov    0xc(%ebp),%eax
  803137:	89 04 24             	mov    %eax,(%esp)
  80313a:	e8 d5 e2 ff ff       	call   801414 <memmove>
		*addrlen = ret->ret_addrlen;
  80313f:	a1 10 80 80 00       	mov    0x808010,%eax
  803144:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  803146:	89 d8                	mov    %ebx,%eax
  803148:	83 c4 10             	add    $0x10,%esp
  80314b:	5b                   	pop    %ebx
  80314c:	5e                   	pop    %esi
  80314d:	5d                   	pop    %ebp
  80314e:	c3                   	ret    

0080314f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80314f:	55                   	push   %ebp
  803150:	89 e5                	mov    %esp,%ebp
  803152:	53                   	push   %ebx
  803153:	83 ec 14             	sub    $0x14,%esp
  803156:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  803159:	8b 45 08             	mov    0x8(%ebp),%eax
  80315c:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  803161:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803165:	8b 45 0c             	mov    0xc(%ebp),%eax
  803168:	89 44 24 04          	mov    %eax,0x4(%esp)
  80316c:	c7 04 24 04 80 80 00 	movl   $0x808004,(%esp)
  803173:	e8 9c e2 ff ff       	call   801414 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  803178:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  80317e:	b8 02 00 00 00       	mov    $0x2,%eax
  803183:	e8 0b ff ff ff       	call   803093 <nsipc>
}
  803188:	83 c4 14             	add    $0x14,%esp
  80318b:	5b                   	pop    %ebx
  80318c:	5d                   	pop    %ebp
  80318d:	c3                   	ret    

0080318e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80318e:	55                   	push   %ebp
  80318f:	89 e5                	mov    %esp,%ebp
  803191:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  803194:	8b 45 08             	mov    0x8(%ebp),%eax
  803197:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  80319c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80319f:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  8031a4:	b8 03 00 00 00       	mov    $0x3,%eax
  8031a9:	e8 e5 fe ff ff       	call   803093 <nsipc>
}
  8031ae:	c9                   	leave  
  8031af:	c3                   	ret    

008031b0 <nsipc_close>:

int
nsipc_close(int s)
{
  8031b0:	55                   	push   %ebp
  8031b1:	89 e5                	mov    %esp,%ebp
  8031b3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8031b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8031b9:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  8031be:	b8 04 00 00 00       	mov    $0x4,%eax
  8031c3:	e8 cb fe ff ff       	call   803093 <nsipc>
}
  8031c8:	c9                   	leave  
  8031c9:	c3                   	ret    

008031ca <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8031ca:	55                   	push   %ebp
  8031cb:	89 e5                	mov    %esp,%ebp
  8031cd:	53                   	push   %ebx
  8031ce:	83 ec 14             	sub    $0x14,%esp
  8031d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8031d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8031d7:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8031dc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8031e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8031e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031e7:	c7 04 24 04 80 80 00 	movl   $0x808004,(%esp)
  8031ee:	e8 21 e2 ff ff       	call   801414 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8031f3:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  8031f9:	b8 05 00 00 00       	mov    $0x5,%eax
  8031fe:	e8 90 fe ff ff       	call   803093 <nsipc>
}
  803203:	83 c4 14             	add    $0x14,%esp
  803206:	5b                   	pop    %ebx
  803207:	5d                   	pop    %ebp
  803208:	c3                   	ret    

00803209 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  803209:	55                   	push   %ebp
  80320a:	89 e5                	mov    %esp,%ebp
  80320c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80320f:	8b 45 08             	mov    0x8(%ebp),%eax
  803212:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  803217:	8b 45 0c             	mov    0xc(%ebp),%eax
  80321a:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  80321f:	b8 06 00 00 00       	mov    $0x6,%eax
  803224:	e8 6a fe ff ff       	call   803093 <nsipc>
}
  803229:	c9                   	leave  
  80322a:	c3                   	ret    

0080322b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80322b:	55                   	push   %ebp
  80322c:	89 e5                	mov    %esp,%ebp
  80322e:	56                   	push   %esi
  80322f:	53                   	push   %ebx
  803230:	83 ec 10             	sub    $0x10,%esp
  803233:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  803236:	8b 45 08             	mov    0x8(%ebp),%eax
  803239:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  80323e:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  803244:	8b 45 14             	mov    0x14(%ebp),%eax
  803247:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80324c:	b8 07 00 00 00       	mov    $0x7,%eax
  803251:	e8 3d fe ff ff       	call   803093 <nsipc>
  803256:	89 c3                	mov    %eax,%ebx
  803258:	85 c0                	test   %eax,%eax
  80325a:	78 46                	js     8032a2 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  80325c:	39 f0                	cmp    %esi,%eax
  80325e:	7f 07                	jg     803267 <nsipc_recv+0x3c>
  803260:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  803265:	7e 24                	jle    80328b <nsipc_recv+0x60>
  803267:	c7 44 24 0c 16 43 80 	movl   $0x804316,0xc(%esp)
  80326e:	00 
  80326f:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  803276:	00 
  803277:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80327e:	00 
  80327f:	c7 04 24 2b 43 80 00 	movl   $0x80432b,(%esp)
  803286:	e8 dc d7 ff ff       	call   800a67 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80328b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80328f:	c7 44 24 04 00 80 80 	movl   $0x808000,0x4(%esp)
  803296:	00 
  803297:	8b 45 0c             	mov    0xc(%ebp),%eax
  80329a:	89 04 24             	mov    %eax,(%esp)
  80329d:	e8 72 e1 ff ff       	call   801414 <memmove>
	}

	return r;
}
  8032a2:	89 d8                	mov    %ebx,%eax
  8032a4:	83 c4 10             	add    $0x10,%esp
  8032a7:	5b                   	pop    %ebx
  8032a8:	5e                   	pop    %esi
  8032a9:	5d                   	pop    %ebp
  8032aa:	c3                   	ret    

008032ab <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8032ab:	55                   	push   %ebp
  8032ac:	89 e5                	mov    %esp,%ebp
  8032ae:	53                   	push   %ebx
  8032af:	83 ec 14             	sub    $0x14,%esp
  8032b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8032b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8032b8:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  8032bd:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8032c3:	7e 24                	jle    8032e9 <nsipc_send+0x3e>
  8032c5:	c7 44 24 0c 37 43 80 	movl   $0x804337,0xc(%esp)
  8032cc:	00 
  8032cd:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  8032d4:	00 
  8032d5:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8032dc:	00 
  8032dd:	c7 04 24 2b 43 80 00 	movl   $0x80432b,(%esp)
  8032e4:	e8 7e d7 ff ff       	call   800a67 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8032e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8032ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8032f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8032f4:	c7 04 24 0c 80 80 00 	movl   $0x80800c,(%esp)
  8032fb:	e8 14 e1 ff ff       	call   801414 <memmove>
	nsipcbuf.send.req_size = size;
  803300:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  803306:	8b 45 14             	mov    0x14(%ebp),%eax
  803309:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  80330e:	b8 08 00 00 00       	mov    $0x8,%eax
  803313:	e8 7b fd ff ff       	call   803093 <nsipc>
}
  803318:	83 c4 14             	add    $0x14,%esp
  80331b:	5b                   	pop    %ebx
  80331c:	5d                   	pop    %ebp
  80331d:	c3                   	ret    

0080331e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80331e:	55                   	push   %ebp
  80331f:	89 e5                	mov    %esp,%ebp
  803321:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  803324:	8b 45 08             	mov    0x8(%ebp),%eax
  803327:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  80332c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80332f:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  803334:	8b 45 10             	mov    0x10(%ebp),%eax
  803337:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  80333c:	b8 09 00 00 00       	mov    $0x9,%eax
  803341:	e8 4d fd ff ff       	call   803093 <nsipc>
}
  803346:	c9                   	leave  
  803347:	c3                   	ret    

00803348 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  803348:	55                   	push   %ebp
  803349:	89 e5                	mov    %esp,%ebp
  80334b:	56                   	push   %esi
  80334c:	53                   	push   %ebx
  80334d:	83 ec 10             	sub    $0x10,%esp
  803350:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  803353:	8b 45 08             	mov    0x8(%ebp),%eax
  803356:	89 04 24             	mov    %eax,(%esp)
  803359:	e8 e2 ea ff ff       	call   801e40 <fd2data>
  80335e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  803360:	c7 44 24 04 43 43 80 	movl   $0x804343,0x4(%esp)
  803367:	00 
  803368:	89 1c 24             	mov    %ebx,(%esp)
  80336b:	e8 07 df ff ff       	call   801277 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  803370:	8b 46 04             	mov    0x4(%esi),%eax
  803373:	2b 06                	sub    (%esi),%eax
  803375:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80337b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803382:	00 00 00 
	stat->st_dev = &devpipe;
  803385:	c7 83 88 00 00 00 58 	movl   $0x805058,0x88(%ebx)
  80338c:	50 80 00 
	return 0;
}
  80338f:	b8 00 00 00 00       	mov    $0x0,%eax
  803394:	83 c4 10             	add    $0x10,%esp
  803397:	5b                   	pop    %ebx
  803398:	5e                   	pop    %esi
  803399:	5d                   	pop    %ebp
  80339a:	c3                   	ret    

0080339b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80339b:	55                   	push   %ebp
  80339c:	89 e5                	mov    %esp,%ebp
  80339e:	53                   	push   %ebx
  80339f:	83 ec 14             	sub    $0x14,%esp
  8033a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8033a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8033a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8033b0:	e8 85 e3 ff ff       	call   80173a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8033b5:	89 1c 24             	mov    %ebx,(%esp)
  8033b8:	e8 83 ea ff ff       	call   801e40 <fd2data>
  8033bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8033c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8033c8:	e8 6d e3 ff ff       	call   80173a <sys_page_unmap>
}
  8033cd:	83 c4 14             	add    $0x14,%esp
  8033d0:	5b                   	pop    %ebx
  8033d1:	5d                   	pop    %ebp
  8033d2:	c3                   	ret    

008033d3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8033d3:	55                   	push   %ebp
  8033d4:	89 e5                	mov    %esp,%ebp
  8033d6:	57                   	push   %edi
  8033d7:	56                   	push   %esi
  8033d8:	53                   	push   %ebx
  8033d9:	83 ec 2c             	sub    $0x2c,%esp
  8033dc:	89 c6                	mov    %eax,%esi
  8033de:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8033e1:	a1 28 64 80 00       	mov    0x806428,%eax
  8033e6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8033e9:	89 34 24             	mov    %esi,(%esp)
  8033ec:	e8 cc 04 00 00       	call   8038bd <pageref>
  8033f1:	89 c7                	mov    %eax,%edi
  8033f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8033f6:	89 04 24             	mov    %eax,(%esp)
  8033f9:	e8 bf 04 00 00       	call   8038bd <pageref>
  8033fe:	39 c7                	cmp    %eax,%edi
  803400:	0f 94 c2             	sete   %dl
  803403:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  803406:	8b 0d 28 64 80 00    	mov    0x806428,%ecx
  80340c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  80340f:	39 fb                	cmp    %edi,%ebx
  803411:	74 21                	je     803434 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  803413:	84 d2                	test   %dl,%dl
  803415:	74 ca                	je     8033e1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803417:	8b 51 58             	mov    0x58(%ecx),%edx
  80341a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80341e:	89 54 24 08          	mov    %edx,0x8(%esp)
  803422:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803426:	c7 04 24 4a 43 80 00 	movl   $0x80434a,(%esp)
  80342d:	e8 2e d7 ff ff       	call   800b60 <cprintf>
  803432:	eb ad                	jmp    8033e1 <_pipeisclosed+0xe>
	}
}
  803434:	83 c4 2c             	add    $0x2c,%esp
  803437:	5b                   	pop    %ebx
  803438:	5e                   	pop    %esi
  803439:	5f                   	pop    %edi
  80343a:	5d                   	pop    %ebp
  80343b:	c3                   	ret    

0080343c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80343c:	55                   	push   %ebp
  80343d:	89 e5                	mov    %esp,%ebp
  80343f:	57                   	push   %edi
  803440:	56                   	push   %esi
  803441:	53                   	push   %ebx
  803442:	83 ec 1c             	sub    $0x1c,%esp
  803445:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  803448:	89 34 24             	mov    %esi,(%esp)
  80344b:	e8 f0 e9 ff ff       	call   801e40 <fd2data>
  803450:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803452:	bf 00 00 00 00       	mov    $0x0,%edi
  803457:	eb 45                	jmp    80349e <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  803459:	89 da                	mov    %ebx,%edx
  80345b:	89 f0                	mov    %esi,%eax
  80345d:	e8 71 ff ff ff       	call   8033d3 <_pipeisclosed>
  803462:	85 c0                	test   %eax,%eax
  803464:	75 41                	jne    8034a7 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  803466:	e8 09 e2 ff ff       	call   801674 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80346b:	8b 43 04             	mov    0x4(%ebx),%eax
  80346e:	8b 0b                	mov    (%ebx),%ecx
  803470:	8d 51 20             	lea    0x20(%ecx),%edx
  803473:	39 d0                	cmp    %edx,%eax
  803475:	73 e2                	jae    803459 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  803477:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80347a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80347e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  803481:	99                   	cltd   
  803482:	c1 ea 1b             	shr    $0x1b,%edx
  803485:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  803488:	83 e1 1f             	and    $0x1f,%ecx
  80348b:	29 d1                	sub    %edx,%ecx
  80348d:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  803491:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  803495:	83 c0 01             	add    $0x1,%eax
  803498:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80349b:	83 c7 01             	add    $0x1,%edi
  80349e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8034a1:	75 c8                	jne    80346b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8034a3:	89 f8                	mov    %edi,%eax
  8034a5:	eb 05                	jmp    8034ac <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8034a7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8034ac:	83 c4 1c             	add    $0x1c,%esp
  8034af:	5b                   	pop    %ebx
  8034b0:	5e                   	pop    %esi
  8034b1:	5f                   	pop    %edi
  8034b2:	5d                   	pop    %ebp
  8034b3:	c3                   	ret    

008034b4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8034b4:	55                   	push   %ebp
  8034b5:	89 e5                	mov    %esp,%ebp
  8034b7:	57                   	push   %edi
  8034b8:	56                   	push   %esi
  8034b9:	53                   	push   %ebx
  8034ba:	83 ec 1c             	sub    $0x1c,%esp
  8034bd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8034c0:	89 3c 24             	mov    %edi,(%esp)
  8034c3:	e8 78 e9 ff ff       	call   801e40 <fd2data>
  8034c8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8034ca:	be 00 00 00 00       	mov    $0x0,%esi
  8034cf:	eb 3d                	jmp    80350e <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8034d1:	85 f6                	test   %esi,%esi
  8034d3:	74 04                	je     8034d9 <devpipe_read+0x25>
				return i;
  8034d5:	89 f0                	mov    %esi,%eax
  8034d7:	eb 43                	jmp    80351c <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8034d9:	89 da                	mov    %ebx,%edx
  8034db:	89 f8                	mov    %edi,%eax
  8034dd:	e8 f1 fe ff ff       	call   8033d3 <_pipeisclosed>
  8034e2:	85 c0                	test   %eax,%eax
  8034e4:	75 31                	jne    803517 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8034e6:	e8 89 e1 ff ff       	call   801674 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8034eb:	8b 03                	mov    (%ebx),%eax
  8034ed:	3b 43 04             	cmp    0x4(%ebx),%eax
  8034f0:	74 df                	je     8034d1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8034f2:	99                   	cltd   
  8034f3:	c1 ea 1b             	shr    $0x1b,%edx
  8034f6:	01 d0                	add    %edx,%eax
  8034f8:	83 e0 1f             	and    $0x1f,%eax
  8034fb:	29 d0                	sub    %edx,%eax
  8034fd:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  803502:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803505:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  803508:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80350b:	83 c6 01             	add    $0x1,%esi
  80350e:	3b 75 10             	cmp    0x10(%ebp),%esi
  803511:	75 d8                	jne    8034eb <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  803513:	89 f0                	mov    %esi,%eax
  803515:	eb 05                	jmp    80351c <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803517:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80351c:	83 c4 1c             	add    $0x1c,%esp
  80351f:	5b                   	pop    %ebx
  803520:	5e                   	pop    %esi
  803521:	5f                   	pop    %edi
  803522:	5d                   	pop    %ebp
  803523:	c3                   	ret    

00803524 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  803524:	55                   	push   %ebp
  803525:	89 e5                	mov    %esp,%ebp
  803527:	56                   	push   %esi
  803528:	53                   	push   %ebx
  803529:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80352c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80352f:	89 04 24             	mov    %eax,(%esp)
  803532:	e8 20 e9 ff ff       	call   801e57 <fd_alloc>
  803537:	89 c2                	mov    %eax,%edx
  803539:	85 d2                	test   %edx,%edx
  80353b:	0f 88 4d 01 00 00    	js     80368e <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803541:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803548:	00 
  803549:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80354c:	89 44 24 04          	mov    %eax,0x4(%esp)
  803550:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803557:	e8 37 e1 ff ff       	call   801693 <sys_page_alloc>
  80355c:	89 c2                	mov    %eax,%edx
  80355e:	85 d2                	test   %edx,%edx
  803560:	0f 88 28 01 00 00    	js     80368e <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  803566:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803569:	89 04 24             	mov    %eax,(%esp)
  80356c:	e8 e6 e8 ff ff       	call   801e57 <fd_alloc>
  803571:	89 c3                	mov    %eax,%ebx
  803573:	85 c0                	test   %eax,%eax
  803575:	0f 88 fe 00 00 00    	js     803679 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80357b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803582:	00 
  803583:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803586:	89 44 24 04          	mov    %eax,0x4(%esp)
  80358a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803591:	e8 fd e0 ff ff       	call   801693 <sys_page_alloc>
  803596:	89 c3                	mov    %eax,%ebx
  803598:	85 c0                	test   %eax,%eax
  80359a:	0f 88 d9 00 00 00    	js     803679 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8035a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8035a3:	89 04 24             	mov    %eax,(%esp)
  8035a6:	e8 95 e8 ff ff       	call   801e40 <fd2data>
  8035ab:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8035ad:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8035b4:	00 
  8035b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8035b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8035c0:	e8 ce e0 ff ff       	call   801693 <sys_page_alloc>
  8035c5:	89 c3                	mov    %eax,%ebx
  8035c7:	85 c0                	test   %eax,%eax
  8035c9:	0f 88 97 00 00 00    	js     803666 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8035cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8035d2:	89 04 24             	mov    %eax,(%esp)
  8035d5:	e8 66 e8 ff ff       	call   801e40 <fd2data>
  8035da:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8035e1:	00 
  8035e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8035e6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8035ed:	00 
  8035ee:	89 74 24 04          	mov    %esi,0x4(%esp)
  8035f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8035f9:	e8 e9 e0 ff ff       	call   8016e7 <sys_page_map>
  8035fe:	89 c3                	mov    %eax,%ebx
  803600:	85 c0                	test   %eax,%eax
  803602:	78 52                	js     803656 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  803604:	8b 15 58 50 80 00    	mov    0x805058,%edx
  80360a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80360d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80360f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803612:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  803619:	8b 15 58 50 80 00    	mov    0x805058,%edx
  80361f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803622:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  803624:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803627:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80362e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803631:	89 04 24             	mov    %eax,(%esp)
  803634:	e8 f7 e7 ff ff       	call   801e30 <fd2num>
  803639:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80363c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80363e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803641:	89 04 24             	mov    %eax,(%esp)
  803644:	e8 e7 e7 ff ff       	call   801e30 <fd2num>
  803649:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80364c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80364f:	b8 00 00 00 00       	mov    $0x0,%eax
  803654:	eb 38                	jmp    80368e <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  803656:	89 74 24 04          	mov    %esi,0x4(%esp)
  80365a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803661:	e8 d4 e0 ff ff       	call   80173a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  803666:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803669:	89 44 24 04          	mov    %eax,0x4(%esp)
  80366d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803674:	e8 c1 e0 ff ff       	call   80173a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  803679:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80367c:	89 44 24 04          	mov    %eax,0x4(%esp)
  803680:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803687:	e8 ae e0 ff ff       	call   80173a <sys_page_unmap>
  80368c:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  80368e:	83 c4 30             	add    $0x30,%esp
  803691:	5b                   	pop    %ebx
  803692:	5e                   	pop    %esi
  803693:	5d                   	pop    %ebp
  803694:	c3                   	ret    

00803695 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  803695:	55                   	push   %ebp
  803696:	89 e5                	mov    %esp,%ebp
  803698:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80369b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80369e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8036a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8036a5:	89 04 24             	mov    %eax,(%esp)
  8036a8:	e8 f9 e7 ff ff       	call   801ea6 <fd_lookup>
  8036ad:	89 c2                	mov    %eax,%edx
  8036af:	85 d2                	test   %edx,%edx
  8036b1:	78 15                	js     8036c8 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8036b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8036b6:	89 04 24             	mov    %eax,(%esp)
  8036b9:	e8 82 e7 ff ff       	call   801e40 <fd2data>
	return _pipeisclosed(fd, p);
  8036be:	89 c2                	mov    %eax,%edx
  8036c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8036c3:	e8 0b fd ff ff       	call   8033d3 <_pipeisclosed>
}
  8036c8:	c9                   	leave  
  8036c9:	c3                   	ret    

008036ca <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8036ca:	55                   	push   %ebp
  8036cb:	89 e5                	mov    %esp,%ebp
  8036cd:	56                   	push   %esi
  8036ce:	53                   	push   %ebx
  8036cf:	83 ec 10             	sub    $0x10,%esp
  8036d2:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8036d5:	85 f6                	test   %esi,%esi
  8036d7:	75 24                	jne    8036fd <wait+0x33>
  8036d9:	c7 44 24 0c 62 43 80 	movl   $0x804362,0xc(%esp)
  8036e0:	00 
  8036e1:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  8036e8:	00 
  8036e9:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  8036f0:	00 
  8036f1:	c7 04 24 6d 43 80 00 	movl   $0x80436d,(%esp)
  8036f8:	e8 6a d3 ff ff       	call   800a67 <_panic>
	e = &envs[ENVX(envid)];
  8036fd:	89 f3                	mov    %esi,%ebx
  8036ff:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  803705:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  803708:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80370e:	eb 05                	jmp    803715 <wait+0x4b>
		sys_yield();
  803710:	e8 5f df ff ff       	call   801674 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  803715:	8b 43 48             	mov    0x48(%ebx),%eax
  803718:	39 f0                	cmp    %esi,%eax
  80371a:	75 07                	jne    803723 <wait+0x59>
  80371c:	8b 43 54             	mov    0x54(%ebx),%eax
  80371f:	85 c0                	test   %eax,%eax
  803721:	75 ed                	jne    803710 <wait+0x46>
		sys_yield();
}
  803723:	83 c4 10             	add    $0x10,%esp
  803726:	5b                   	pop    %ebx
  803727:	5e                   	pop    %esi
  803728:	5d                   	pop    %ebp
  803729:	c3                   	ret    

0080372a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80372a:	55                   	push   %ebp
  80372b:	89 e5                	mov    %esp,%ebp
  80372d:	53                   	push   %ebx
  80372e:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  803731:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  803738:	75 2f                	jne    803769 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  80373a:	e8 16 df ff ff       	call   801655 <sys_getenvid>
  80373f:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P);
  803741:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  803748:	00 
  803749:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  803750:	ee 
  803751:	89 04 24             	mov    %eax,(%esp)
  803754:	e8 3a df ff ff       	call   801693 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *)_pgfault_upcall);
  803759:	c7 44 24 04 77 37 80 	movl   $0x803777,0x4(%esp)
  803760:	00 
  803761:	89 1c 24             	mov    %ebx,(%esp)
  803764:	e8 ca e0 ff ff       	call   801833 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  803769:	8b 45 08             	mov    0x8(%ebp),%eax
  80376c:	a3 00 90 80 00       	mov    %eax,0x809000
}
  803771:	83 c4 14             	add    $0x14,%esp
  803774:	5b                   	pop    %ebx
  803775:	5d                   	pop    %ebp
  803776:	c3                   	ret    

00803777 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  803777:	54                   	push   %esp
	movl _pgfault_handler, %eax
  803778:	a1 00 90 80 00       	mov    0x809000,%eax
	call *%eax
  80377d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80377f:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	// 0x30(%esp) points to trap-time stack pointer
	// 0x28(%esp) points to trap-time eip
	subl $4, 0x30(%esp)
  803782:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax 
  803787:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebp
  80378b:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %ebp, (%eax)
  80378f:	89 28                	mov    %ebp,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  803791:	83 c4 08             	add    $0x8,%esp
	popal
  803794:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp //pop eip - we already stored it
  803795:	83 c4 04             	add    $0x4,%esp
	popfl
  803798:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  803799:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80379a:	c3                   	ret    
  80379b:	66 90                	xchg   %ax,%ax
  80379d:	66 90                	xchg   %ax,%ax
  80379f:	90                   	nop

008037a0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8037a0:	55                   	push   %ebp
  8037a1:	89 e5                	mov    %esp,%ebp
  8037a3:	56                   	push   %esi
  8037a4:	53                   	push   %ebx
  8037a5:	83 ec 10             	sub    $0x10,%esp
  8037a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8037ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8037ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  8037b1:	85 c0                	test   %eax,%eax
  8037b3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8037b8:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  8037bb:	89 04 24             	mov    %eax,(%esp)
  8037be:	e8 e6 e0 ff ff       	call   8018a9 <sys_ipc_recv>

	if(ret < 0) {
  8037c3:	85 c0                	test   %eax,%eax
  8037c5:	79 16                	jns    8037dd <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  8037c7:	85 f6                	test   %esi,%esi
  8037c9:	74 06                	je     8037d1 <ipc_recv+0x31>
  8037cb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  8037d1:	85 db                	test   %ebx,%ebx
  8037d3:	74 3e                	je     803813 <ipc_recv+0x73>
  8037d5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8037db:	eb 36                	jmp    803813 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  8037dd:	e8 73 de ff ff       	call   801655 <sys_getenvid>
  8037e2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8037e7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8037ea:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8037ef:	a3 28 64 80 00       	mov    %eax,0x806428

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8037f4:	85 f6                	test   %esi,%esi
  8037f6:	74 05                	je     8037fd <ipc_recv+0x5d>
  8037f8:	8b 40 74             	mov    0x74(%eax),%eax
  8037fb:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8037fd:	85 db                	test   %ebx,%ebx
  8037ff:	74 0a                	je     80380b <ipc_recv+0x6b>
  803801:	a1 28 64 80 00       	mov    0x806428,%eax
  803806:	8b 40 78             	mov    0x78(%eax),%eax
  803809:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  80380b:	a1 28 64 80 00       	mov    0x806428,%eax
  803810:	8b 40 70             	mov    0x70(%eax),%eax
}
  803813:	83 c4 10             	add    $0x10,%esp
  803816:	5b                   	pop    %ebx
  803817:	5e                   	pop    %esi
  803818:	5d                   	pop    %ebp
  803819:	c3                   	ret    

0080381a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80381a:	55                   	push   %ebp
  80381b:	89 e5                	mov    %esp,%ebp
  80381d:	57                   	push   %edi
  80381e:	56                   	push   %esi
  80381f:	53                   	push   %ebx
  803820:	83 ec 1c             	sub    $0x1c,%esp
  803823:	8b 7d 08             	mov    0x8(%ebp),%edi
  803826:	8b 75 0c             	mov    0xc(%ebp),%esi
  803829:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  80382c:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  80382e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  803833:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  803836:	8b 45 14             	mov    0x14(%ebp),%eax
  803839:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80383d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803841:	89 74 24 04          	mov    %esi,0x4(%esp)
  803845:	89 3c 24             	mov    %edi,(%esp)
  803848:	e8 39 e0 ff ff       	call   801886 <sys_ipc_try_send>

		if(ret >= 0) break;
  80384d:	85 c0                	test   %eax,%eax
  80384f:	79 2c                	jns    80387d <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  803851:	83 f8 f9             	cmp    $0xfffffff9,%eax
  803854:	74 20                	je     803876 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  803856:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80385a:	c7 44 24 08 78 43 80 	movl   $0x804378,0x8(%esp)
  803861:	00 
  803862:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  803869:	00 
  80386a:	c7 04 24 a8 43 80 00 	movl   $0x8043a8,(%esp)
  803871:	e8 f1 d1 ff ff       	call   800a67 <_panic>
		}
		sys_yield();
  803876:	e8 f9 dd ff ff       	call   801674 <sys_yield>
	}
  80387b:	eb b9                	jmp    803836 <ipc_send+0x1c>
}
  80387d:	83 c4 1c             	add    $0x1c,%esp
  803880:	5b                   	pop    %ebx
  803881:	5e                   	pop    %esi
  803882:	5f                   	pop    %edi
  803883:	5d                   	pop    %ebp
  803884:	c3                   	ret    

00803885 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  803885:	55                   	push   %ebp
  803886:	89 e5                	mov    %esp,%ebp
  803888:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80388b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  803890:	6b d0 7c             	imul   $0x7c,%eax,%edx
  803893:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  803899:	8b 52 50             	mov    0x50(%edx),%edx
  80389c:	39 ca                	cmp    %ecx,%edx
  80389e:	75 0d                	jne    8038ad <ipc_find_env+0x28>
			return envs[i].env_id;
  8038a0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8038a3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8038a8:	8b 40 40             	mov    0x40(%eax),%eax
  8038ab:	eb 0e                	jmp    8038bb <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8038ad:	83 c0 01             	add    $0x1,%eax
  8038b0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8038b5:	75 d9                	jne    803890 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8038b7:	66 b8 00 00          	mov    $0x0,%ax
}
  8038bb:	5d                   	pop    %ebp
  8038bc:	c3                   	ret    

008038bd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8038bd:	55                   	push   %ebp
  8038be:	89 e5                	mov    %esp,%ebp
  8038c0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8038c3:	89 d0                	mov    %edx,%eax
  8038c5:	c1 e8 16             	shr    $0x16,%eax
  8038c8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8038cf:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8038d4:	f6 c1 01             	test   $0x1,%cl
  8038d7:	74 1d                	je     8038f6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8038d9:	c1 ea 0c             	shr    $0xc,%edx
  8038dc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8038e3:	f6 c2 01             	test   $0x1,%dl
  8038e6:	74 0e                	je     8038f6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8038e8:	c1 ea 0c             	shr    $0xc,%edx
  8038eb:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8038f2:	ef 
  8038f3:	0f b7 c0             	movzwl %ax,%eax
}
  8038f6:	5d                   	pop    %ebp
  8038f7:	c3                   	ret    
  8038f8:	66 90                	xchg   %ax,%ax
  8038fa:	66 90                	xchg   %ax,%ax
  8038fc:	66 90                	xchg   %ax,%ax
  8038fe:	66 90                	xchg   %ax,%ax

00803900 <__udivdi3>:
  803900:	55                   	push   %ebp
  803901:	57                   	push   %edi
  803902:	56                   	push   %esi
  803903:	83 ec 0c             	sub    $0xc,%esp
  803906:	8b 44 24 28          	mov    0x28(%esp),%eax
  80390a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80390e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  803912:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  803916:	85 c0                	test   %eax,%eax
  803918:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80391c:	89 ea                	mov    %ebp,%edx
  80391e:	89 0c 24             	mov    %ecx,(%esp)
  803921:	75 2d                	jne    803950 <__udivdi3+0x50>
  803923:	39 e9                	cmp    %ebp,%ecx
  803925:	77 61                	ja     803988 <__udivdi3+0x88>
  803927:	85 c9                	test   %ecx,%ecx
  803929:	89 ce                	mov    %ecx,%esi
  80392b:	75 0b                	jne    803938 <__udivdi3+0x38>
  80392d:	b8 01 00 00 00       	mov    $0x1,%eax
  803932:	31 d2                	xor    %edx,%edx
  803934:	f7 f1                	div    %ecx
  803936:	89 c6                	mov    %eax,%esi
  803938:	31 d2                	xor    %edx,%edx
  80393a:	89 e8                	mov    %ebp,%eax
  80393c:	f7 f6                	div    %esi
  80393e:	89 c5                	mov    %eax,%ebp
  803940:	89 f8                	mov    %edi,%eax
  803942:	f7 f6                	div    %esi
  803944:	89 ea                	mov    %ebp,%edx
  803946:	83 c4 0c             	add    $0xc,%esp
  803949:	5e                   	pop    %esi
  80394a:	5f                   	pop    %edi
  80394b:	5d                   	pop    %ebp
  80394c:	c3                   	ret    
  80394d:	8d 76 00             	lea    0x0(%esi),%esi
  803950:	39 e8                	cmp    %ebp,%eax
  803952:	77 24                	ja     803978 <__udivdi3+0x78>
  803954:	0f bd e8             	bsr    %eax,%ebp
  803957:	83 f5 1f             	xor    $0x1f,%ebp
  80395a:	75 3c                	jne    803998 <__udivdi3+0x98>
  80395c:	8b 74 24 04          	mov    0x4(%esp),%esi
  803960:	39 34 24             	cmp    %esi,(%esp)
  803963:	0f 86 9f 00 00 00    	jbe    803a08 <__udivdi3+0x108>
  803969:	39 d0                	cmp    %edx,%eax
  80396b:	0f 82 97 00 00 00    	jb     803a08 <__udivdi3+0x108>
  803971:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803978:	31 d2                	xor    %edx,%edx
  80397a:	31 c0                	xor    %eax,%eax
  80397c:	83 c4 0c             	add    $0xc,%esp
  80397f:	5e                   	pop    %esi
  803980:	5f                   	pop    %edi
  803981:	5d                   	pop    %ebp
  803982:	c3                   	ret    
  803983:	90                   	nop
  803984:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803988:	89 f8                	mov    %edi,%eax
  80398a:	f7 f1                	div    %ecx
  80398c:	31 d2                	xor    %edx,%edx
  80398e:	83 c4 0c             	add    $0xc,%esp
  803991:	5e                   	pop    %esi
  803992:	5f                   	pop    %edi
  803993:	5d                   	pop    %ebp
  803994:	c3                   	ret    
  803995:	8d 76 00             	lea    0x0(%esi),%esi
  803998:	89 e9                	mov    %ebp,%ecx
  80399a:	8b 3c 24             	mov    (%esp),%edi
  80399d:	d3 e0                	shl    %cl,%eax
  80399f:	89 c6                	mov    %eax,%esi
  8039a1:	b8 20 00 00 00       	mov    $0x20,%eax
  8039a6:	29 e8                	sub    %ebp,%eax
  8039a8:	89 c1                	mov    %eax,%ecx
  8039aa:	d3 ef                	shr    %cl,%edi
  8039ac:	89 e9                	mov    %ebp,%ecx
  8039ae:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8039b2:	8b 3c 24             	mov    (%esp),%edi
  8039b5:	09 74 24 08          	or     %esi,0x8(%esp)
  8039b9:	89 d6                	mov    %edx,%esi
  8039bb:	d3 e7                	shl    %cl,%edi
  8039bd:	89 c1                	mov    %eax,%ecx
  8039bf:	89 3c 24             	mov    %edi,(%esp)
  8039c2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8039c6:	d3 ee                	shr    %cl,%esi
  8039c8:	89 e9                	mov    %ebp,%ecx
  8039ca:	d3 e2                	shl    %cl,%edx
  8039cc:	89 c1                	mov    %eax,%ecx
  8039ce:	d3 ef                	shr    %cl,%edi
  8039d0:	09 d7                	or     %edx,%edi
  8039d2:	89 f2                	mov    %esi,%edx
  8039d4:	89 f8                	mov    %edi,%eax
  8039d6:	f7 74 24 08          	divl   0x8(%esp)
  8039da:	89 d6                	mov    %edx,%esi
  8039dc:	89 c7                	mov    %eax,%edi
  8039de:	f7 24 24             	mull   (%esp)
  8039e1:	39 d6                	cmp    %edx,%esi
  8039e3:	89 14 24             	mov    %edx,(%esp)
  8039e6:	72 30                	jb     803a18 <__udivdi3+0x118>
  8039e8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8039ec:	89 e9                	mov    %ebp,%ecx
  8039ee:	d3 e2                	shl    %cl,%edx
  8039f0:	39 c2                	cmp    %eax,%edx
  8039f2:	73 05                	jae    8039f9 <__udivdi3+0xf9>
  8039f4:	3b 34 24             	cmp    (%esp),%esi
  8039f7:	74 1f                	je     803a18 <__udivdi3+0x118>
  8039f9:	89 f8                	mov    %edi,%eax
  8039fb:	31 d2                	xor    %edx,%edx
  8039fd:	e9 7a ff ff ff       	jmp    80397c <__udivdi3+0x7c>
  803a02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803a08:	31 d2                	xor    %edx,%edx
  803a0a:	b8 01 00 00 00       	mov    $0x1,%eax
  803a0f:	e9 68 ff ff ff       	jmp    80397c <__udivdi3+0x7c>
  803a14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803a18:	8d 47 ff             	lea    -0x1(%edi),%eax
  803a1b:	31 d2                	xor    %edx,%edx
  803a1d:	83 c4 0c             	add    $0xc,%esp
  803a20:	5e                   	pop    %esi
  803a21:	5f                   	pop    %edi
  803a22:	5d                   	pop    %ebp
  803a23:	c3                   	ret    
  803a24:	66 90                	xchg   %ax,%ax
  803a26:	66 90                	xchg   %ax,%ax
  803a28:	66 90                	xchg   %ax,%ax
  803a2a:	66 90                	xchg   %ax,%ax
  803a2c:	66 90                	xchg   %ax,%ax
  803a2e:	66 90                	xchg   %ax,%ax

00803a30 <__umoddi3>:
  803a30:	55                   	push   %ebp
  803a31:	57                   	push   %edi
  803a32:	56                   	push   %esi
  803a33:	83 ec 14             	sub    $0x14,%esp
  803a36:	8b 44 24 28          	mov    0x28(%esp),%eax
  803a3a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  803a3e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  803a42:	89 c7                	mov    %eax,%edi
  803a44:	89 44 24 04          	mov    %eax,0x4(%esp)
  803a48:	8b 44 24 30          	mov    0x30(%esp),%eax
  803a4c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  803a50:	89 34 24             	mov    %esi,(%esp)
  803a53:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803a57:	85 c0                	test   %eax,%eax
  803a59:	89 c2                	mov    %eax,%edx
  803a5b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  803a5f:	75 17                	jne    803a78 <__umoddi3+0x48>
  803a61:	39 fe                	cmp    %edi,%esi
  803a63:	76 4b                	jbe    803ab0 <__umoddi3+0x80>
  803a65:	89 c8                	mov    %ecx,%eax
  803a67:	89 fa                	mov    %edi,%edx
  803a69:	f7 f6                	div    %esi
  803a6b:	89 d0                	mov    %edx,%eax
  803a6d:	31 d2                	xor    %edx,%edx
  803a6f:	83 c4 14             	add    $0x14,%esp
  803a72:	5e                   	pop    %esi
  803a73:	5f                   	pop    %edi
  803a74:	5d                   	pop    %ebp
  803a75:	c3                   	ret    
  803a76:	66 90                	xchg   %ax,%ax
  803a78:	39 f8                	cmp    %edi,%eax
  803a7a:	77 54                	ja     803ad0 <__umoddi3+0xa0>
  803a7c:	0f bd e8             	bsr    %eax,%ebp
  803a7f:	83 f5 1f             	xor    $0x1f,%ebp
  803a82:	75 5c                	jne    803ae0 <__umoddi3+0xb0>
  803a84:	8b 7c 24 08          	mov    0x8(%esp),%edi
  803a88:	39 3c 24             	cmp    %edi,(%esp)
  803a8b:	0f 87 e7 00 00 00    	ja     803b78 <__umoddi3+0x148>
  803a91:	8b 7c 24 04          	mov    0x4(%esp),%edi
  803a95:	29 f1                	sub    %esi,%ecx
  803a97:	19 c7                	sbb    %eax,%edi
  803a99:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803a9d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  803aa1:	8b 44 24 08          	mov    0x8(%esp),%eax
  803aa5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  803aa9:	83 c4 14             	add    $0x14,%esp
  803aac:	5e                   	pop    %esi
  803aad:	5f                   	pop    %edi
  803aae:	5d                   	pop    %ebp
  803aaf:	c3                   	ret    
  803ab0:	85 f6                	test   %esi,%esi
  803ab2:	89 f5                	mov    %esi,%ebp
  803ab4:	75 0b                	jne    803ac1 <__umoddi3+0x91>
  803ab6:	b8 01 00 00 00       	mov    $0x1,%eax
  803abb:	31 d2                	xor    %edx,%edx
  803abd:	f7 f6                	div    %esi
  803abf:	89 c5                	mov    %eax,%ebp
  803ac1:	8b 44 24 04          	mov    0x4(%esp),%eax
  803ac5:	31 d2                	xor    %edx,%edx
  803ac7:	f7 f5                	div    %ebp
  803ac9:	89 c8                	mov    %ecx,%eax
  803acb:	f7 f5                	div    %ebp
  803acd:	eb 9c                	jmp    803a6b <__umoddi3+0x3b>
  803acf:	90                   	nop
  803ad0:	89 c8                	mov    %ecx,%eax
  803ad2:	89 fa                	mov    %edi,%edx
  803ad4:	83 c4 14             	add    $0x14,%esp
  803ad7:	5e                   	pop    %esi
  803ad8:	5f                   	pop    %edi
  803ad9:	5d                   	pop    %ebp
  803ada:	c3                   	ret    
  803adb:	90                   	nop
  803adc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803ae0:	8b 04 24             	mov    (%esp),%eax
  803ae3:	be 20 00 00 00       	mov    $0x20,%esi
  803ae8:	89 e9                	mov    %ebp,%ecx
  803aea:	29 ee                	sub    %ebp,%esi
  803aec:	d3 e2                	shl    %cl,%edx
  803aee:	89 f1                	mov    %esi,%ecx
  803af0:	d3 e8                	shr    %cl,%eax
  803af2:	89 e9                	mov    %ebp,%ecx
  803af4:	89 44 24 04          	mov    %eax,0x4(%esp)
  803af8:	8b 04 24             	mov    (%esp),%eax
  803afb:	09 54 24 04          	or     %edx,0x4(%esp)
  803aff:	89 fa                	mov    %edi,%edx
  803b01:	d3 e0                	shl    %cl,%eax
  803b03:	89 f1                	mov    %esi,%ecx
  803b05:	89 44 24 08          	mov    %eax,0x8(%esp)
  803b09:	8b 44 24 10          	mov    0x10(%esp),%eax
  803b0d:	d3 ea                	shr    %cl,%edx
  803b0f:	89 e9                	mov    %ebp,%ecx
  803b11:	d3 e7                	shl    %cl,%edi
  803b13:	89 f1                	mov    %esi,%ecx
  803b15:	d3 e8                	shr    %cl,%eax
  803b17:	89 e9                	mov    %ebp,%ecx
  803b19:	09 f8                	or     %edi,%eax
  803b1b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  803b1f:	f7 74 24 04          	divl   0x4(%esp)
  803b23:	d3 e7                	shl    %cl,%edi
  803b25:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  803b29:	89 d7                	mov    %edx,%edi
  803b2b:	f7 64 24 08          	mull   0x8(%esp)
  803b2f:	39 d7                	cmp    %edx,%edi
  803b31:	89 c1                	mov    %eax,%ecx
  803b33:	89 14 24             	mov    %edx,(%esp)
  803b36:	72 2c                	jb     803b64 <__umoddi3+0x134>
  803b38:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  803b3c:	72 22                	jb     803b60 <__umoddi3+0x130>
  803b3e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803b42:	29 c8                	sub    %ecx,%eax
  803b44:	19 d7                	sbb    %edx,%edi
  803b46:	89 e9                	mov    %ebp,%ecx
  803b48:	89 fa                	mov    %edi,%edx
  803b4a:	d3 e8                	shr    %cl,%eax
  803b4c:	89 f1                	mov    %esi,%ecx
  803b4e:	d3 e2                	shl    %cl,%edx
  803b50:	89 e9                	mov    %ebp,%ecx
  803b52:	d3 ef                	shr    %cl,%edi
  803b54:	09 d0                	or     %edx,%eax
  803b56:	89 fa                	mov    %edi,%edx
  803b58:	83 c4 14             	add    $0x14,%esp
  803b5b:	5e                   	pop    %esi
  803b5c:	5f                   	pop    %edi
  803b5d:	5d                   	pop    %ebp
  803b5e:	c3                   	ret    
  803b5f:	90                   	nop
  803b60:	39 d7                	cmp    %edx,%edi
  803b62:	75 da                	jne    803b3e <__umoddi3+0x10e>
  803b64:	8b 14 24             	mov    (%esp),%edx
  803b67:	89 c1                	mov    %eax,%ecx
  803b69:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  803b6d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  803b71:	eb cb                	jmp    803b3e <__umoddi3+0x10e>
  803b73:	90                   	nop
  803b74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803b78:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  803b7c:	0f 82 0f ff ff ff    	jb     803a91 <__umoddi3+0x61>
  803b82:	e9 1a ff ff ff       	jmp    803aa1 <__umoddi3+0x71>
