
obj/user/echo.debug:     file format elf32-i386


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
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, nflag;

	nflag = 0;
  800042:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800049:	83 ff 01             	cmp    $0x1,%edi
  80004c:	7e 2b                	jle    800079 <umain+0x46>
  80004e:	c7 44 24 04 80 26 80 	movl   $0x802680,0x4(%esp)
  800055:	00 
  800056:	8b 46 04             	mov    0x4(%esi),%eax
  800059:	89 04 24             	mov    %eax,(%esp)
  80005c:	e8 eb 01 00 00       	call   80024c <strcmp>
void
umain(int argc, char **argv)
{
	int i, nflag;

	nflag = 0;
  800061:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800068:	85 c0                	test   %eax,%eax
  80006a:	75 0d                	jne    800079 <umain+0x46>
		nflag = 1;
		argc--;
  80006c:	83 ef 01             	sub    $0x1,%edi
		argv++;
  80006f:	83 c6 04             	add    $0x4,%esi
{
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
  800072:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  800079:	bb 01 00 00 00       	mov    $0x1,%ebx
  80007e:	eb 46                	jmp    8000c6 <umain+0x93>
		if (i > 1)
  800080:	83 fb 01             	cmp    $0x1,%ebx
  800083:	7e 1c                	jle    8000a1 <umain+0x6e>
			write(1, " ", 1);
  800085:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 83 26 80 	movl   $0x802683,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80009c:	e8 26 0c 00 00       	call   800cc7 <write>
		write(1, argv[i], strlen(argv[i]));
  8000a1:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8000a4:	89 04 24             	mov    %eax,(%esp)
  8000a7:	e8 b4 00 00 00       	call   800160 <strlen>
  8000ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b0:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8000b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000be:	e8 04 0c 00 00       	call   800cc7 <write>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  8000c3:	83 c3 01             	add    $0x1,%ebx
  8000c6:	39 df                	cmp    %ebx,%edi
  8000c8:	7f b6                	jg     800080 <umain+0x4d>
		if (i > 1)
			write(1, " ", 1);
		write(1, argv[i], strlen(argv[i]));
	}
	if (!nflag)
  8000ca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000ce:	75 1c                	jne    8000ec <umain+0xb9>
		write(1, "\n", 1);
  8000d0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8000d7:	00 
  8000d8:	c7 44 24 04 d0 27 80 	movl   $0x8027d0,0x4(%esp)
  8000df:	00 
  8000e0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000e7:	e8 db 0b 00 00       	call   800cc7 <write>
}
  8000ec:	83 c4 1c             	add    $0x1c,%esp
  8000ef:	5b                   	pop    %ebx
  8000f0:	5e                   	pop    %esi
  8000f1:	5f                   	pop    %edi
  8000f2:	5d                   	pop    %ebp
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
  800102:	e8 6e 04 00 00       	call   800575 <sys_getenvid>
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
  80012b:	e8 03 ff ff ff       	call   800033 <umain>

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
  800142:	e8 73 09 00 00       	call   800aba <close_all>
	sys_env_destroy(0);
  800147:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80014e:	e8 d0 03 00 00       	call   800523 <sys_env_destroy>
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    
  800155:	66 90                	xchg   %ax,%ax
  800157:	66 90                	xchg   %ax,%ax
  800159:	66 90                	xchg   %ax,%ax
  80015b:	66 90                	xchg   %ax,%ax
  80015d:	66 90                	xchg   %ax,%ax
  80015f:	90                   	nop

00800160 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800166:	b8 00 00 00 00       	mov    $0x0,%eax
  80016b:	eb 03                	jmp    800170 <strlen+0x10>
		n++;
  80016d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800170:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800174:	75 f7                	jne    80016d <strlen+0xd>
		n++;
	return n;
}
  800176:	5d                   	pop    %ebp
  800177:	c3                   	ret    

00800178 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80017e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800181:	b8 00 00 00 00       	mov    $0x0,%eax
  800186:	eb 03                	jmp    80018b <strnlen+0x13>
		n++;
  800188:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80018b:	39 d0                	cmp    %edx,%eax
  80018d:	74 06                	je     800195 <strnlen+0x1d>
  80018f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800193:	75 f3                	jne    800188 <strnlen+0x10>
		n++;
	return n;
}
  800195:	5d                   	pop    %ebp
  800196:	c3                   	ret    

00800197 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	53                   	push   %ebx
  80019b:	8b 45 08             	mov    0x8(%ebp),%eax
  80019e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8001a1:	89 c2                	mov    %eax,%edx
  8001a3:	83 c2 01             	add    $0x1,%edx
  8001a6:	83 c1 01             	add    $0x1,%ecx
  8001a9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8001ad:	88 5a ff             	mov    %bl,-0x1(%edx)
  8001b0:	84 db                	test   %bl,%bl
  8001b2:	75 ef                	jne    8001a3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8001b4:	5b                   	pop    %ebx
  8001b5:	5d                   	pop    %ebp
  8001b6:	c3                   	ret    

008001b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	53                   	push   %ebx
  8001bb:	83 ec 08             	sub    $0x8,%esp
  8001be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8001c1:	89 1c 24             	mov    %ebx,(%esp)
  8001c4:	e8 97 ff ff ff       	call   800160 <strlen>
	strcpy(dst + len, src);
  8001c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001d0:	01 d8                	add    %ebx,%eax
  8001d2:	89 04 24             	mov    %eax,(%esp)
  8001d5:	e8 bd ff ff ff       	call   800197 <strcpy>
	return dst;
}
  8001da:	89 d8                	mov    %ebx,%eax
  8001dc:	83 c4 08             	add    $0x8,%esp
  8001df:	5b                   	pop    %ebx
  8001e0:	5d                   	pop    %ebp
  8001e1:	c3                   	ret    

008001e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	56                   	push   %esi
  8001e6:	53                   	push   %ebx
  8001e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8001ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ed:	89 f3                	mov    %esi,%ebx
  8001ef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001f2:	89 f2                	mov    %esi,%edx
  8001f4:	eb 0f                	jmp    800205 <strncpy+0x23>
		*dst++ = *src;
  8001f6:	83 c2 01             	add    $0x1,%edx
  8001f9:	0f b6 01             	movzbl (%ecx),%eax
  8001fc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8001ff:	80 39 01             	cmpb   $0x1,(%ecx)
  800202:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800205:	39 da                	cmp    %ebx,%edx
  800207:	75 ed                	jne    8001f6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800209:	89 f0                	mov    %esi,%eax
  80020b:	5b                   	pop    %ebx
  80020c:	5e                   	pop    %esi
  80020d:	5d                   	pop    %ebp
  80020e:	c3                   	ret    

0080020f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	56                   	push   %esi
  800213:	53                   	push   %ebx
  800214:	8b 75 08             	mov    0x8(%ebp),%esi
  800217:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80021d:	89 f0                	mov    %esi,%eax
  80021f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800223:	85 c9                	test   %ecx,%ecx
  800225:	75 0b                	jne    800232 <strlcpy+0x23>
  800227:	eb 1d                	jmp    800246 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800229:	83 c0 01             	add    $0x1,%eax
  80022c:	83 c2 01             	add    $0x1,%edx
  80022f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800232:	39 d8                	cmp    %ebx,%eax
  800234:	74 0b                	je     800241 <strlcpy+0x32>
  800236:	0f b6 0a             	movzbl (%edx),%ecx
  800239:	84 c9                	test   %cl,%cl
  80023b:	75 ec                	jne    800229 <strlcpy+0x1a>
  80023d:	89 c2                	mov    %eax,%edx
  80023f:	eb 02                	jmp    800243 <strlcpy+0x34>
  800241:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800243:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800246:	29 f0                	sub    %esi,%eax
}
  800248:	5b                   	pop    %ebx
  800249:	5e                   	pop    %esi
  80024a:	5d                   	pop    %ebp
  80024b:	c3                   	ret    

0080024c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800252:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800255:	eb 06                	jmp    80025d <strcmp+0x11>
		p++, q++;
  800257:	83 c1 01             	add    $0x1,%ecx
  80025a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80025d:	0f b6 01             	movzbl (%ecx),%eax
  800260:	84 c0                	test   %al,%al
  800262:	74 04                	je     800268 <strcmp+0x1c>
  800264:	3a 02                	cmp    (%edx),%al
  800266:	74 ef                	je     800257 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800268:	0f b6 c0             	movzbl %al,%eax
  80026b:	0f b6 12             	movzbl (%edx),%edx
  80026e:	29 d0                	sub    %edx,%eax
}
  800270:	5d                   	pop    %ebp
  800271:	c3                   	ret    

00800272 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	53                   	push   %ebx
  800276:	8b 45 08             	mov    0x8(%ebp),%eax
  800279:	8b 55 0c             	mov    0xc(%ebp),%edx
  80027c:	89 c3                	mov    %eax,%ebx
  80027e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800281:	eb 06                	jmp    800289 <strncmp+0x17>
		n--, p++, q++;
  800283:	83 c0 01             	add    $0x1,%eax
  800286:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800289:	39 d8                	cmp    %ebx,%eax
  80028b:	74 15                	je     8002a2 <strncmp+0x30>
  80028d:	0f b6 08             	movzbl (%eax),%ecx
  800290:	84 c9                	test   %cl,%cl
  800292:	74 04                	je     800298 <strncmp+0x26>
  800294:	3a 0a                	cmp    (%edx),%cl
  800296:	74 eb                	je     800283 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800298:	0f b6 00             	movzbl (%eax),%eax
  80029b:	0f b6 12             	movzbl (%edx),%edx
  80029e:	29 d0                	sub    %edx,%eax
  8002a0:	eb 05                	jmp    8002a7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8002a2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8002a7:	5b                   	pop    %ebx
  8002a8:	5d                   	pop    %ebp
  8002a9:	c3                   	ret    

008002aa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8002b4:	eb 07                	jmp    8002bd <strchr+0x13>
		if (*s == c)
  8002b6:	38 ca                	cmp    %cl,%dl
  8002b8:	74 0f                	je     8002c9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8002ba:	83 c0 01             	add    $0x1,%eax
  8002bd:	0f b6 10             	movzbl (%eax),%edx
  8002c0:	84 d2                	test   %dl,%dl
  8002c2:	75 f2                	jne    8002b6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8002c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    

008002cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8002d5:	eb 07                	jmp    8002de <strfind+0x13>
		if (*s == c)
  8002d7:	38 ca                	cmp    %cl,%dl
  8002d9:	74 0a                	je     8002e5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8002db:	83 c0 01             	add    $0x1,%eax
  8002de:	0f b6 10             	movzbl (%eax),%edx
  8002e1:	84 d2                	test   %dl,%dl
  8002e3:	75 f2                	jne    8002d7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
  8002ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8002f3:	85 c9                	test   %ecx,%ecx
  8002f5:	74 36                	je     80032d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8002f7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8002fd:	75 28                	jne    800327 <memset+0x40>
  8002ff:	f6 c1 03             	test   $0x3,%cl
  800302:	75 23                	jne    800327 <memset+0x40>
		c &= 0xFF;
  800304:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800308:	89 d3                	mov    %edx,%ebx
  80030a:	c1 e3 08             	shl    $0x8,%ebx
  80030d:	89 d6                	mov    %edx,%esi
  80030f:	c1 e6 18             	shl    $0x18,%esi
  800312:	89 d0                	mov    %edx,%eax
  800314:	c1 e0 10             	shl    $0x10,%eax
  800317:	09 f0                	or     %esi,%eax
  800319:	09 c2                	or     %eax,%edx
  80031b:	89 d0                	mov    %edx,%eax
  80031d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80031f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800322:	fc                   	cld    
  800323:	f3 ab                	rep stos %eax,%es:(%edi)
  800325:	eb 06                	jmp    80032d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800327:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032a:	fc                   	cld    
  80032b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80032d:	89 f8                	mov    %edi,%eax
  80032f:	5b                   	pop    %ebx
  800330:	5e                   	pop    %esi
  800331:	5f                   	pop    %edi
  800332:	5d                   	pop    %ebp
  800333:	c3                   	ret    

00800334 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800334:	55                   	push   %ebp
  800335:	89 e5                	mov    %esp,%ebp
  800337:	57                   	push   %edi
  800338:	56                   	push   %esi
  800339:	8b 45 08             	mov    0x8(%ebp),%eax
  80033c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80033f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800342:	39 c6                	cmp    %eax,%esi
  800344:	73 35                	jae    80037b <memmove+0x47>
  800346:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800349:	39 d0                	cmp    %edx,%eax
  80034b:	73 2e                	jae    80037b <memmove+0x47>
		s += n;
		d += n;
  80034d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800350:	89 d6                	mov    %edx,%esi
  800352:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800354:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80035a:	75 13                	jne    80036f <memmove+0x3b>
  80035c:	f6 c1 03             	test   $0x3,%cl
  80035f:	75 0e                	jne    80036f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800361:	83 ef 04             	sub    $0x4,%edi
  800364:	8d 72 fc             	lea    -0x4(%edx),%esi
  800367:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80036a:	fd                   	std    
  80036b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80036d:	eb 09                	jmp    800378 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80036f:	83 ef 01             	sub    $0x1,%edi
  800372:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800375:	fd                   	std    
  800376:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800378:	fc                   	cld    
  800379:	eb 1d                	jmp    800398 <memmove+0x64>
  80037b:	89 f2                	mov    %esi,%edx
  80037d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80037f:	f6 c2 03             	test   $0x3,%dl
  800382:	75 0f                	jne    800393 <memmove+0x5f>
  800384:	f6 c1 03             	test   $0x3,%cl
  800387:	75 0a                	jne    800393 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800389:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80038c:	89 c7                	mov    %eax,%edi
  80038e:	fc                   	cld    
  80038f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800391:	eb 05                	jmp    800398 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800393:	89 c7                	mov    %eax,%edi
  800395:	fc                   	cld    
  800396:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800398:	5e                   	pop    %esi
  800399:	5f                   	pop    %edi
  80039a:	5d                   	pop    %ebp
  80039b:	c3                   	ret    

0080039c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80039c:	55                   	push   %ebp
  80039d:	89 e5                	mov    %esp,%ebp
  80039f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8003a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b3:	89 04 24             	mov    %eax,(%esp)
  8003b6:	e8 79 ff ff ff       	call   800334 <memmove>
}
  8003bb:	c9                   	leave  
  8003bc:	c3                   	ret    

008003bd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	56                   	push   %esi
  8003c1:	53                   	push   %ebx
  8003c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003c8:	89 d6                	mov    %edx,%esi
  8003ca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003cd:	eb 1a                	jmp    8003e9 <memcmp+0x2c>
		if (*s1 != *s2)
  8003cf:	0f b6 02             	movzbl (%edx),%eax
  8003d2:	0f b6 19             	movzbl (%ecx),%ebx
  8003d5:	38 d8                	cmp    %bl,%al
  8003d7:	74 0a                	je     8003e3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8003d9:	0f b6 c0             	movzbl %al,%eax
  8003dc:	0f b6 db             	movzbl %bl,%ebx
  8003df:	29 d8                	sub    %ebx,%eax
  8003e1:	eb 0f                	jmp    8003f2 <memcmp+0x35>
		s1++, s2++;
  8003e3:	83 c2 01             	add    $0x1,%edx
  8003e6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003e9:	39 f2                	cmp    %esi,%edx
  8003eb:	75 e2                	jne    8003cf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8003ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003f2:	5b                   	pop    %ebx
  8003f3:	5e                   	pop    %esi
  8003f4:	5d                   	pop    %ebp
  8003f5:	c3                   	ret    

008003f6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8003f6:	55                   	push   %ebp
  8003f7:	89 e5                	mov    %esp,%ebp
  8003f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8003ff:	89 c2                	mov    %eax,%edx
  800401:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800404:	eb 07                	jmp    80040d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800406:	38 08                	cmp    %cl,(%eax)
  800408:	74 07                	je     800411 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80040a:	83 c0 01             	add    $0x1,%eax
  80040d:	39 d0                	cmp    %edx,%eax
  80040f:	72 f5                	jb     800406 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800411:	5d                   	pop    %ebp
  800412:	c3                   	ret    

00800413 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	57                   	push   %edi
  800417:	56                   	push   %esi
  800418:	53                   	push   %ebx
  800419:	8b 55 08             	mov    0x8(%ebp),%edx
  80041c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80041f:	eb 03                	jmp    800424 <strtol+0x11>
		s++;
  800421:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800424:	0f b6 0a             	movzbl (%edx),%ecx
  800427:	80 f9 09             	cmp    $0x9,%cl
  80042a:	74 f5                	je     800421 <strtol+0xe>
  80042c:	80 f9 20             	cmp    $0x20,%cl
  80042f:	74 f0                	je     800421 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800431:	80 f9 2b             	cmp    $0x2b,%cl
  800434:	75 0a                	jne    800440 <strtol+0x2d>
		s++;
  800436:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800439:	bf 00 00 00 00       	mov    $0x0,%edi
  80043e:	eb 11                	jmp    800451 <strtol+0x3e>
  800440:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800445:	80 f9 2d             	cmp    $0x2d,%cl
  800448:	75 07                	jne    800451 <strtol+0x3e>
		s++, neg = 1;
  80044a:	8d 52 01             	lea    0x1(%edx),%edx
  80044d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800451:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800456:	75 15                	jne    80046d <strtol+0x5a>
  800458:	80 3a 30             	cmpb   $0x30,(%edx)
  80045b:	75 10                	jne    80046d <strtol+0x5a>
  80045d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800461:	75 0a                	jne    80046d <strtol+0x5a>
		s += 2, base = 16;
  800463:	83 c2 02             	add    $0x2,%edx
  800466:	b8 10 00 00 00       	mov    $0x10,%eax
  80046b:	eb 10                	jmp    80047d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  80046d:	85 c0                	test   %eax,%eax
  80046f:	75 0c                	jne    80047d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800471:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800473:	80 3a 30             	cmpb   $0x30,(%edx)
  800476:	75 05                	jne    80047d <strtol+0x6a>
		s++, base = 8;
  800478:	83 c2 01             	add    $0x1,%edx
  80047b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  80047d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800482:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800485:	0f b6 0a             	movzbl (%edx),%ecx
  800488:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80048b:	89 f0                	mov    %esi,%eax
  80048d:	3c 09                	cmp    $0x9,%al
  80048f:	77 08                	ja     800499 <strtol+0x86>
			dig = *s - '0';
  800491:	0f be c9             	movsbl %cl,%ecx
  800494:	83 e9 30             	sub    $0x30,%ecx
  800497:	eb 20                	jmp    8004b9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800499:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80049c:	89 f0                	mov    %esi,%eax
  80049e:	3c 19                	cmp    $0x19,%al
  8004a0:	77 08                	ja     8004aa <strtol+0x97>
			dig = *s - 'a' + 10;
  8004a2:	0f be c9             	movsbl %cl,%ecx
  8004a5:	83 e9 57             	sub    $0x57,%ecx
  8004a8:	eb 0f                	jmp    8004b9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  8004aa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  8004ad:	89 f0                	mov    %esi,%eax
  8004af:	3c 19                	cmp    $0x19,%al
  8004b1:	77 16                	ja     8004c9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  8004b3:	0f be c9             	movsbl %cl,%ecx
  8004b6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8004b9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  8004bc:	7d 0f                	jge    8004cd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  8004be:	83 c2 01             	add    $0x1,%edx
  8004c1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  8004c5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  8004c7:	eb bc                	jmp    800485 <strtol+0x72>
  8004c9:	89 d8                	mov    %ebx,%eax
  8004cb:	eb 02                	jmp    8004cf <strtol+0xbc>
  8004cd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  8004cf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8004d3:	74 05                	je     8004da <strtol+0xc7>
		*endptr = (char *) s;
  8004d5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004d8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  8004da:	f7 d8                	neg    %eax
  8004dc:	85 ff                	test   %edi,%edi
  8004de:	0f 44 c3             	cmove  %ebx,%eax
}
  8004e1:	5b                   	pop    %ebx
  8004e2:	5e                   	pop    %esi
  8004e3:	5f                   	pop    %edi
  8004e4:	5d                   	pop    %ebp
  8004e5:	c3                   	ret    

008004e6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
  8004e9:	57                   	push   %edi
  8004ea:	56                   	push   %esi
  8004eb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8004f7:	89 c3                	mov    %eax,%ebx
  8004f9:	89 c7                	mov    %eax,%edi
  8004fb:	89 c6                	mov    %eax,%esi
  8004fd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8004ff:	5b                   	pop    %ebx
  800500:	5e                   	pop    %esi
  800501:	5f                   	pop    %edi
  800502:	5d                   	pop    %ebp
  800503:	c3                   	ret    

00800504 <sys_cgetc>:

int
sys_cgetc(void)
{
  800504:	55                   	push   %ebp
  800505:	89 e5                	mov    %esp,%ebp
  800507:	57                   	push   %edi
  800508:	56                   	push   %esi
  800509:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80050a:	ba 00 00 00 00       	mov    $0x0,%edx
  80050f:	b8 01 00 00 00       	mov    $0x1,%eax
  800514:	89 d1                	mov    %edx,%ecx
  800516:	89 d3                	mov    %edx,%ebx
  800518:	89 d7                	mov    %edx,%edi
  80051a:	89 d6                	mov    %edx,%esi
  80051c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80051e:	5b                   	pop    %ebx
  80051f:	5e                   	pop    %esi
  800520:	5f                   	pop    %edi
  800521:	5d                   	pop    %ebp
  800522:	c3                   	ret    

00800523 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800523:	55                   	push   %ebp
  800524:	89 e5                	mov    %esp,%ebp
  800526:	57                   	push   %edi
  800527:	56                   	push   %esi
  800528:	53                   	push   %ebx
  800529:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80052c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800531:	b8 03 00 00 00       	mov    $0x3,%eax
  800536:	8b 55 08             	mov    0x8(%ebp),%edx
  800539:	89 cb                	mov    %ecx,%ebx
  80053b:	89 cf                	mov    %ecx,%edi
  80053d:	89 ce                	mov    %ecx,%esi
  80053f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800541:	85 c0                	test   %eax,%eax
  800543:	7e 28                	jle    80056d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800545:	89 44 24 10          	mov    %eax,0x10(%esp)
  800549:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800550:	00 
  800551:	c7 44 24 08 8f 26 80 	movl   $0x80268f,0x8(%esp)
  800558:	00 
  800559:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800560:	00 
  800561:	c7 04 24 ac 26 80 00 	movl   $0x8026ac,(%esp)
  800568:	e8 29 16 00 00       	call   801b96 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80056d:	83 c4 2c             	add    $0x2c,%esp
  800570:	5b                   	pop    %ebx
  800571:	5e                   	pop    %esi
  800572:	5f                   	pop    %edi
  800573:	5d                   	pop    %ebp
  800574:	c3                   	ret    

00800575 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800575:	55                   	push   %ebp
  800576:	89 e5                	mov    %esp,%ebp
  800578:	57                   	push   %edi
  800579:	56                   	push   %esi
  80057a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80057b:	ba 00 00 00 00       	mov    $0x0,%edx
  800580:	b8 02 00 00 00       	mov    $0x2,%eax
  800585:	89 d1                	mov    %edx,%ecx
  800587:	89 d3                	mov    %edx,%ebx
  800589:	89 d7                	mov    %edx,%edi
  80058b:	89 d6                	mov    %edx,%esi
  80058d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80058f:	5b                   	pop    %ebx
  800590:	5e                   	pop    %esi
  800591:	5f                   	pop    %edi
  800592:	5d                   	pop    %ebp
  800593:	c3                   	ret    

00800594 <sys_yield>:

void
sys_yield(void)
{
  800594:	55                   	push   %ebp
  800595:	89 e5                	mov    %esp,%ebp
  800597:	57                   	push   %edi
  800598:	56                   	push   %esi
  800599:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80059a:	ba 00 00 00 00       	mov    $0x0,%edx
  80059f:	b8 0b 00 00 00       	mov    $0xb,%eax
  8005a4:	89 d1                	mov    %edx,%ecx
  8005a6:	89 d3                	mov    %edx,%ebx
  8005a8:	89 d7                	mov    %edx,%edi
  8005aa:	89 d6                	mov    %edx,%esi
  8005ac:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8005ae:	5b                   	pop    %ebx
  8005af:	5e                   	pop    %esi
  8005b0:	5f                   	pop    %edi
  8005b1:	5d                   	pop    %ebp
  8005b2:	c3                   	ret    

008005b3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8005b3:	55                   	push   %ebp
  8005b4:	89 e5                	mov    %esp,%ebp
  8005b6:	57                   	push   %edi
  8005b7:	56                   	push   %esi
  8005b8:	53                   	push   %ebx
  8005b9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005bc:	be 00 00 00 00       	mov    $0x0,%esi
  8005c1:	b8 04 00 00 00       	mov    $0x4,%eax
  8005c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8005cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005cf:	89 f7                	mov    %esi,%edi
  8005d1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8005d3:	85 c0                	test   %eax,%eax
  8005d5:	7e 28                	jle    8005ff <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005d7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005db:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8005e2:	00 
  8005e3:	c7 44 24 08 8f 26 80 	movl   $0x80268f,0x8(%esp)
  8005ea:	00 
  8005eb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8005f2:	00 
  8005f3:	c7 04 24 ac 26 80 00 	movl   $0x8026ac,(%esp)
  8005fa:	e8 97 15 00 00       	call   801b96 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8005ff:	83 c4 2c             	add    $0x2c,%esp
  800602:	5b                   	pop    %ebx
  800603:	5e                   	pop    %esi
  800604:	5f                   	pop    %edi
  800605:	5d                   	pop    %ebp
  800606:	c3                   	ret    

00800607 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800607:	55                   	push   %ebp
  800608:	89 e5                	mov    %esp,%ebp
  80060a:	57                   	push   %edi
  80060b:	56                   	push   %esi
  80060c:	53                   	push   %ebx
  80060d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800610:	b8 05 00 00 00       	mov    $0x5,%eax
  800615:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800618:	8b 55 08             	mov    0x8(%ebp),%edx
  80061b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80061e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800621:	8b 75 18             	mov    0x18(%ebp),%esi
  800624:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800626:	85 c0                	test   %eax,%eax
  800628:	7e 28                	jle    800652 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80062a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80062e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800635:	00 
  800636:	c7 44 24 08 8f 26 80 	movl   $0x80268f,0x8(%esp)
  80063d:	00 
  80063e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800645:	00 
  800646:	c7 04 24 ac 26 80 00 	movl   $0x8026ac,(%esp)
  80064d:	e8 44 15 00 00       	call   801b96 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800652:	83 c4 2c             	add    $0x2c,%esp
  800655:	5b                   	pop    %ebx
  800656:	5e                   	pop    %esi
  800657:	5f                   	pop    %edi
  800658:	5d                   	pop    %ebp
  800659:	c3                   	ret    

0080065a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80065a:	55                   	push   %ebp
  80065b:	89 e5                	mov    %esp,%ebp
  80065d:	57                   	push   %edi
  80065e:	56                   	push   %esi
  80065f:	53                   	push   %ebx
  800660:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800663:	bb 00 00 00 00       	mov    $0x0,%ebx
  800668:	b8 06 00 00 00       	mov    $0x6,%eax
  80066d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800670:	8b 55 08             	mov    0x8(%ebp),%edx
  800673:	89 df                	mov    %ebx,%edi
  800675:	89 de                	mov    %ebx,%esi
  800677:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800679:	85 c0                	test   %eax,%eax
  80067b:	7e 28                	jle    8006a5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80067d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800681:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800688:	00 
  800689:	c7 44 24 08 8f 26 80 	movl   $0x80268f,0x8(%esp)
  800690:	00 
  800691:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800698:	00 
  800699:	c7 04 24 ac 26 80 00 	movl   $0x8026ac,(%esp)
  8006a0:	e8 f1 14 00 00       	call   801b96 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8006a5:	83 c4 2c             	add    $0x2c,%esp
  8006a8:	5b                   	pop    %ebx
  8006a9:	5e                   	pop    %esi
  8006aa:	5f                   	pop    %edi
  8006ab:	5d                   	pop    %ebp
  8006ac:	c3                   	ret    

008006ad <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8006ad:	55                   	push   %ebp
  8006ae:	89 e5                	mov    %esp,%ebp
  8006b0:	57                   	push   %edi
  8006b1:	56                   	push   %esi
  8006b2:	53                   	push   %ebx
  8006b3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006bb:	b8 08 00 00 00       	mov    $0x8,%eax
  8006c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8006c6:	89 df                	mov    %ebx,%edi
  8006c8:	89 de                	mov    %ebx,%esi
  8006ca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8006cc:	85 c0                	test   %eax,%eax
  8006ce:	7e 28                	jle    8006f8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006d0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006d4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8006db:	00 
  8006dc:	c7 44 24 08 8f 26 80 	movl   $0x80268f,0x8(%esp)
  8006e3:	00 
  8006e4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8006eb:	00 
  8006ec:	c7 04 24 ac 26 80 00 	movl   $0x8026ac,(%esp)
  8006f3:	e8 9e 14 00 00       	call   801b96 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8006f8:	83 c4 2c             	add    $0x2c,%esp
  8006fb:	5b                   	pop    %ebx
  8006fc:	5e                   	pop    %esi
  8006fd:	5f                   	pop    %edi
  8006fe:	5d                   	pop    %ebp
  8006ff:	c3                   	ret    

00800700 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	57                   	push   %edi
  800704:	56                   	push   %esi
  800705:	53                   	push   %ebx
  800706:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800709:	bb 00 00 00 00       	mov    $0x0,%ebx
  80070e:	b8 09 00 00 00       	mov    $0x9,%eax
  800713:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800716:	8b 55 08             	mov    0x8(%ebp),%edx
  800719:	89 df                	mov    %ebx,%edi
  80071b:	89 de                	mov    %ebx,%esi
  80071d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80071f:	85 c0                	test   %eax,%eax
  800721:	7e 28                	jle    80074b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800723:	89 44 24 10          	mov    %eax,0x10(%esp)
  800727:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80072e:	00 
  80072f:	c7 44 24 08 8f 26 80 	movl   $0x80268f,0x8(%esp)
  800736:	00 
  800737:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80073e:	00 
  80073f:	c7 04 24 ac 26 80 00 	movl   $0x8026ac,(%esp)
  800746:	e8 4b 14 00 00       	call   801b96 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80074b:	83 c4 2c             	add    $0x2c,%esp
  80074e:	5b                   	pop    %ebx
  80074f:	5e                   	pop    %esi
  800750:	5f                   	pop    %edi
  800751:	5d                   	pop    %ebp
  800752:	c3                   	ret    

00800753 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	57                   	push   %edi
  800757:	56                   	push   %esi
  800758:	53                   	push   %ebx
  800759:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80075c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800761:	b8 0a 00 00 00       	mov    $0xa,%eax
  800766:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800769:	8b 55 08             	mov    0x8(%ebp),%edx
  80076c:	89 df                	mov    %ebx,%edi
  80076e:	89 de                	mov    %ebx,%esi
  800770:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800772:	85 c0                	test   %eax,%eax
  800774:	7e 28                	jle    80079e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800776:	89 44 24 10          	mov    %eax,0x10(%esp)
  80077a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800781:	00 
  800782:	c7 44 24 08 8f 26 80 	movl   $0x80268f,0x8(%esp)
  800789:	00 
  80078a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800791:	00 
  800792:	c7 04 24 ac 26 80 00 	movl   $0x8026ac,(%esp)
  800799:	e8 f8 13 00 00       	call   801b96 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80079e:	83 c4 2c             	add    $0x2c,%esp
  8007a1:	5b                   	pop    %ebx
  8007a2:	5e                   	pop    %esi
  8007a3:	5f                   	pop    %edi
  8007a4:	5d                   	pop    %ebp
  8007a5:	c3                   	ret    

008007a6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	57                   	push   %edi
  8007aa:	56                   	push   %esi
  8007ab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8007ac:	be 00 00 00 00       	mov    $0x0,%esi
  8007b1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8007b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8007bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007bf:	8b 7d 14             	mov    0x14(%ebp),%edi
  8007c2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8007c4:	5b                   	pop    %ebx
  8007c5:	5e                   	pop    %esi
  8007c6:	5f                   	pop    %edi
  8007c7:	5d                   	pop    %ebp
  8007c8:	c3                   	ret    

008007c9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	57                   	push   %edi
  8007cd:	56                   	push   %esi
  8007ce:	53                   	push   %ebx
  8007cf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8007d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d7:	b8 0d 00 00 00       	mov    $0xd,%eax
  8007dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8007df:	89 cb                	mov    %ecx,%ebx
  8007e1:	89 cf                	mov    %ecx,%edi
  8007e3:	89 ce                	mov    %ecx,%esi
  8007e5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8007e7:	85 c0                	test   %eax,%eax
  8007e9:	7e 28                	jle    800813 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8007eb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007ef:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8007f6:	00 
  8007f7:	c7 44 24 08 8f 26 80 	movl   $0x80268f,0x8(%esp)
  8007fe:	00 
  8007ff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800806:	00 
  800807:	c7 04 24 ac 26 80 00 	movl   $0x8026ac,(%esp)
  80080e:	e8 83 13 00 00       	call   801b96 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800813:	83 c4 2c             	add    $0x2c,%esp
  800816:	5b                   	pop    %ebx
  800817:	5e                   	pop    %esi
  800818:	5f                   	pop    %edi
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	57                   	push   %edi
  80081f:	56                   	push   %esi
  800820:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800821:	ba 00 00 00 00       	mov    $0x0,%edx
  800826:	b8 0e 00 00 00       	mov    $0xe,%eax
  80082b:	89 d1                	mov    %edx,%ecx
  80082d:	89 d3                	mov    %edx,%ebx
  80082f:	89 d7                	mov    %edx,%edi
  800831:	89 d6                	mov    %edx,%esi
  800833:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800835:	5b                   	pop    %ebx
  800836:	5e                   	pop    %esi
  800837:	5f                   	pop    %edi
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	57                   	push   %edi
  80083e:	56                   	push   %esi
  80083f:	53                   	push   %ebx
  800840:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800843:	bb 00 00 00 00       	mov    $0x0,%ebx
  800848:	b8 0f 00 00 00       	mov    $0xf,%eax
  80084d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800850:	8b 55 08             	mov    0x8(%ebp),%edx
  800853:	89 df                	mov    %ebx,%edi
  800855:	89 de                	mov    %ebx,%esi
  800857:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800859:	85 c0                	test   %eax,%eax
  80085b:	7e 28                	jle    800885 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80085d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800861:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800868:	00 
  800869:	c7 44 24 08 8f 26 80 	movl   $0x80268f,0x8(%esp)
  800870:	00 
  800871:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800878:	00 
  800879:	c7 04 24 ac 26 80 00 	movl   $0x8026ac,(%esp)
  800880:	e8 11 13 00 00       	call   801b96 <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  800885:	83 c4 2c             	add    $0x2c,%esp
  800888:	5b                   	pop    %ebx
  800889:	5e                   	pop    %esi
  80088a:	5f                   	pop    %edi
  80088b:	5d                   	pop    %ebp
  80088c:	c3                   	ret    

0080088d <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	57                   	push   %edi
  800891:	56                   	push   %esi
  800892:	53                   	push   %ebx
  800893:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800896:	bb 00 00 00 00       	mov    $0x0,%ebx
  80089b:	b8 10 00 00 00       	mov    $0x10,%eax
  8008a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8008a6:	89 df                	mov    %ebx,%edi
  8008a8:	89 de                	mov    %ebx,%esi
  8008aa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8008ac:	85 c0                	test   %eax,%eax
  8008ae:	7e 28                	jle    8008d8 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8008b0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8008b4:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  8008bb:	00 
  8008bc:	c7 44 24 08 8f 26 80 	movl   $0x80268f,0x8(%esp)
  8008c3:	00 
  8008c4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8008cb:	00 
  8008cc:	c7 04 24 ac 26 80 00 	movl   $0x8026ac,(%esp)
  8008d3:	e8 be 12 00 00       	call   801b96 <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  8008d8:	83 c4 2c             	add    $0x2c,%esp
  8008db:	5b                   	pop    %ebx
  8008dc:	5e                   	pop    %esi
  8008dd:	5f                   	pop    %edi
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8008eb:	c1 e8 0c             	shr    $0xc,%eax
}
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8008f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8008fb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800900:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800912:	89 c2                	mov    %eax,%edx
  800914:	c1 ea 16             	shr    $0x16,%edx
  800917:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80091e:	f6 c2 01             	test   $0x1,%dl
  800921:	74 11                	je     800934 <fd_alloc+0x2d>
  800923:	89 c2                	mov    %eax,%edx
  800925:	c1 ea 0c             	shr    $0xc,%edx
  800928:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80092f:	f6 c2 01             	test   $0x1,%dl
  800932:	75 09                	jne    80093d <fd_alloc+0x36>
			*fd_store = fd;
  800934:	89 01                	mov    %eax,(%ecx)
			return 0;
  800936:	b8 00 00 00 00       	mov    $0x0,%eax
  80093b:	eb 17                	jmp    800954 <fd_alloc+0x4d>
  80093d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800942:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800947:	75 c9                	jne    800912 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800949:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80094f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80095c:	83 f8 1f             	cmp    $0x1f,%eax
  80095f:	77 36                	ja     800997 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800961:	c1 e0 0c             	shl    $0xc,%eax
  800964:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800969:	89 c2                	mov    %eax,%edx
  80096b:	c1 ea 16             	shr    $0x16,%edx
  80096e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800975:	f6 c2 01             	test   $0x1,%dl
  800978:	74 24                	je     80099e <fd_lookup+0x48>
  80097a:	89 c2                	mov    %eax,%edx
  80097c:	c1 ea 0c             	shr    $0xc,%edx
  80097f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800986:	f6 c2 01             	test   $0x1,%dl
  800989:	74 1a                	je     8009a5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80098b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098e:	89 02                	mov    %eax,(%edx)
	return 0;
  800990:	b8 00 00 00 00       	mov    $0x0,%eax
  800995:	eb 13                	jmp    8009aa <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800997:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80099c:	eb 0c                	jmp    8009aa <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80099e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009a3:	eb 05                	jmp    8009aa <fd_lookup+0x54>
  8009a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    

008009ac <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	83 ec 18             	sub    $0x18,%esp
  8009b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8009b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ba:	eb 13                	jmp    8009cf <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8009bc:	39 08                	cmp    %ecx,(%eax)
  8009be:	75 0c                	jne    8009cc <dev_lookup+0x20>
			*dev = devtab[i];
  8009c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8009c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ca:	eb 38                	jmp    800a04 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8009cc:	83 c2 01             	add    $0x1,%edx
  8009cf:	8b 04 95 38 27 80 00 	mov    0x802738(,%edx,4),%eax
  8009d6:	85 c0                	test   %eax,%eax
  8009d8:	75 e2                	jne    8009bc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8009da:	a1 08 40 80 00       	mov    0x804008,%eax
  8009df:	8b 40 48             	mov    0x48(%eax),%eax
  8009e2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8009e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ea:	c7 04 24 bc 26 80 00 	movl   $0x8026bc,(%esp)
  8009f1:	e8 99 12 00 00       	call   801c8f <cprintf>
	*dev = 0;
  8009f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8009ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800a04:	c9                   	leave  
  800a05:	c3                   	ret    

00800a06 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	56                   	push   %esi
  800a0a:	53                   	push   %ebx
  800a0b:	83 ec 20             	sub    $0x20,%esp
  800a0e:	8b 75 08             	mov    0x8(%ebp),%esi
  800a11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800a14:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a17:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800a1b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800a21:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800a24:	89 04 24             	mov    %eax,(%esp)
  800a27:	e8 2a ff ff ff       	call   800956 <fd_lookup>
  800a2c:	85 c0                	test   %eax,%eax
  800a2e:	78 05                	js     800a35 <fd_close+0x2f>
	    || fd != fd2)
  800a30:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800a33:	74 0c                	je     800a41 <fd_close+0x3b>
		return (must_exist ? r : 0);
  800a35:	84 db                	test   %bl,%bl
  800a37:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3c:	0f 44 c2             	cmove  %edx,%eax
  800a3f:	eb 3f                	jmp    800a80 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800a41:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a44:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a48:	8b 06                	mov    (%esi),%eax
  800a4a:	89 04 24             	mov    %eax,(%esp)
  800a4d:	e8 5a ff ff ff       	call   8009ac <dev_lookup>
  800a52:	89 c3                	mov    %eax,%ebx
  800a54:	85 c0                	test   %eax,%eax
  800a56:	78 16                	js     800a6e <fd_close+0x68>
		if (dev->dev_close)
  800a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a5b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800a5e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800a63:	85 c0                	test   %eax,%eax
  800a65:	74 07                	je     800a6e <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  800a67:	89 34 24             	mov    %esi,(%esp)
  800a6a:	ff d0                	call   *%eax
  800a6c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800a6e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a72:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a79:	e8 dc fb ff ff       	call   80065a <sys_page_unmap>
	return r;
  800a7e:	89 d8                	mov    %ebx,%eax
}
  800a80:	83 c4 20             	add    $0x20,%esp
  800a83:	5b                   	pop    %ebx
  800a84:	5e                   	pop    %esi
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800a8d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a90:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a94:	8b 45 08             	mov    0x8(%ebp),%eax
  800a97:	89 04 24             	mov    %eax,(%esp)
  800a9a:	e8 b7 fe ff ff       	call   800956 <fd_lookup>
  800a9f:	89 c2                	mov    %eax,%edx
  800aa1:	85 d2                	test   %edx,%edx
  800aa3:	78 13                	js     800ab8 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  800aa5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800aac:	00 
  800aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ab0:	89 04 24             	mov    %eax,(%esp)
  800ab3:	e8 4e ff ff ff       	call   800a06 <fd_close>
}
  800ab8:	c9                   	leave  
  800ab9:	c3                   	ret    

00800aba <close_all>:

void
close_all(void)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	53                   	push   %ebx
  800abe:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ac1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ac6:	89 1c 24             	mov    %ebx,(%esp)
  800ac9:	e8 b9 ff ff ff       	call   800a87 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ace:	83 c3 01             	add    $0x1,%ebx
  800ad1:	83 fb 20             	cmp    $0x20,%ebx
  800ad4:	75 f0                	jne    800ac6 <close_all+0xc>
		close(i);
}
  800ad6:	83 c4 14             	add    $0x14,%esp
  800ad9:	5b                   	pop    %ebx
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	57                   	push   %edi
  800ae0:	56                   	push   %esi
  800ae1:	53                   	push   %ebx
  800ae2:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ae5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ae8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aec:	8b 45 08             	mov    0x8(%ebp),%eax
  800aef:	89 04 24             	mov    %eax,(%esp)
  800af2:	e8 5f fe ff ff       	call   800956 <fd_lookup>
  800af7:	89 c2                	mov    %eax,%edx
  800af9:	85 d2                	test   %edx,%edx
  800afb:	0f 88 e1 00 00 00    	js     800be2 <dup+0x106>
		return r;
	close(newfdnum);
  800b01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b04:	89 04 24             	mov    %eax,(%esp)
  800b07:	e8 7b ff ff ff       	call   800a87 <close>

	newfd = INDEX2FD(newfdnum);
  800b0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b0f:	c1 e3 0c             	shl    $0xc,%ebx
  800b12:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800b18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b1b:	89 04 24             	mov    %eax,(%esp)
  800b1e:	e8 cd fd ff ff       	call   8008f0 <fd2data>
  800b23:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  800b25:	89 1c 24             	mov    %ebx,(%esp)
  800b28:	e8 c3 fd ff ff       	call   8008f0 <fd2data>
  800b2d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800b2f:	89 f0                	mov    %esi,%eax
  800b31:	c1 e8 16             	shr    $0x16,%eax
  800b34:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800b3b:	a8 01                	test   $0x1,%al
  800b3d:	74 43                	je     800b82 <dup+0xa6>
  800b3f:	89 f0                	mov    %esi,%eax
  800b41:	c1 e8 0c             	shr    $0xc,%eax
  800b44:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800b4b:	f6 c2 01             	test   $0x1,%dl
  800b4e:	74 32                	je     800b82 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800b50:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b57:	25 07 0e 00 00       	and    $0xe07,%eax
  800b5c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b60:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800b64:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800b6b:	00 
  800b6c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b77:	e8 8b fa ff ff       	call   800607 <sys_page_map>
  800b7c:	89 c6                	mov    %eax,%esi
  800b7e:	85 c0                	test   %eax,%eax
  800b80:	78 3e                	js     800bc0 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b85:	89 c2                	mov    %eax,%edx
  800b87:	c1 ea 0c             	shr    $0xc,%edx
  800b8a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800b91:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800b97:	89 54 24 10          	mov    %edx,0x10(%esp)
  800b9b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800b9f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ba6:	00 
  800ba7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800bb2:	e8 50 fa ff ff       	call   800607 <sys_page_map>
  800bb7:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  800bb9:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800bbc:	85 f6                	test   %esi,%esi
  800bbe:	79 22                	jns    800be2 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800bc0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bc4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800bcb:	e8 8a fa ff ff       	call   80065a <sys_page_unmap>
	sys_page_unmap(0, nva);
  800bd0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bd4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800bdb:	e8 7a fa ff ff       	call   80065a <sys_page_unmap>
	return r;
  800be0:	89 f0                	mov    %esi,%eax
}
  800be2:	83 c4 3c             	add    $0x3c,%esp
  800be5:	5b                   	pop    %ebx
  800be6:	5e                   	pop    %esi
  800be7:	5f                   	pop    %edi
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    

00800bea <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	53                   	push   %ebx
  800bee:	83 ec 24             	sub    $0x24,%esp
  800bf1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bf4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bf7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bfb:	89 1c 24             	mov    %ebx,(%esp)
  800bfe:	e8 53 fd ff ff       	call   800956 <fd_lookup>
  800c03:	89 c2                	mov    %eax,%edx
  800c05:	85 d2                	test   %edx,%edx
  800c07:	78 6d                	js     800c76 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c09:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c10:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c13:	8b 00                	mov    (%eax),%eax
  800c15:	89 04 24             	mov    %eax,(%esp)
  800c18:	e8 8f fd ff ff       	call   8009ac <dev_lookup>
  800c1d:	85 c0                	test   %eax,%eax
  800c1f:	78 55                	js     800c76 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800c21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c24:	8b 50 08             	mov    0x8(%eax),%edx
  800c27:	83 e2 03             	and    $0x3,%edx
  800c2a:	83 fa 01             	cmp    $0x1,%edx
  800c2d:	75 23                	jne    800c52 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800c2f:	a1 08 40 80 00       	mov    0x804008,%eax
  800c34:	8b 40 48             	mov    0x48(%eax),%eax
  800c37:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800c3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c3f:	c7 04 24 fd 26 80 00 	movl   $0x8026fd,(%esp)
  800c46:	e8 44 10 00 00       	call   801c8f <cprintf>
		return -E_INVAL;
  800c4b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c50:	eb 24                	jmp    800c76 <read+0x8c>
	}
	if (!dev->dev_read)
  800c52:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c55:	8b 52 08             	mov    0x8(%edx),%edx
  800c58:	85 d2                	test   %edx,%edx
  800c5a:	74 15                	je     800c71 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800c5c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c5f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c66:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c6a:	89 04 24             	mov    %eax,(%esp)
  800c6d:	ff d2                	call   *%edx
  800c6f:	eb 05                	jmp    800c76 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800c71:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800c76:	83 c4 24             	add    $0x24,%esp
  800c79:	5b                   	pop    %ebx
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	57                   	push   %edi
  800c80:	56                   	push   %esi
  800c81:	53                   	push   %ebx
  800c82:	83 ec 1c             	sub    $0x1c,%esp
  800c85:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c88:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c90:	eb 23                	jmp    800cb5 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800c92:	89 f0                	mov    %esi,%eax
  800c94:	29 d8                	sub    %ebx,%eax
  800c96:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c9a:	89 d8                	mov    %ebx,%eax
  800c9c:	03 45 0c             	add    0xc(%ebp),%eax
  800c9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ca3:	89 3c 24             	mov    %edi,(%esp)
  800ca6:	e8 3f ff ff ff       	call   800bea <read>
		if (m < 0)
  800cab:	85 c0                	test   %eax,%eax
  800cad:	78 10                	js     800cbf <readn+0x43>
			return m;
		if (m == 0)
  800caf:	85 c0                	test   %eax,%eax
  800cb1:	74 0a                	je     800cbd <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800cb3:	01 c3                	add    %eax,%ebx
  800cb5:	39 f3                	cmp    %esi,%ebx
  800cb7:	72 d9                	jb     800c92 <readn+0x16>
  800cb9:	89 d8                	mov    %ebx,%eax
  800cbb:	eb 02                	jmp    800cbf <readn+0x43>
  800cbd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800cbf:	83 c4 1c             	add    $0x1c,%esp
  800cc2:	5b                   	pop    %ebx
  800cc3:	5e                   	pop    %esi
  800cc4:	5f                   	pop    %edi
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	53                   	push   %ebx
  800ccb:	83 ec 24             	sub    $0x24,%esp
  800cce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800cd1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800cd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd8:	89 1c 24             	mov    %ebx,(%esp)
  800cdb:	e8 76 fc ff ff       	call   800956 <fd_lookup>
  800ce0:	89 c2                	mov    %eax,%edx
  800ce2:	85 d2                	test   %edx,%edx
  800ce4:	78 68                	js     800d4e <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ce6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ce9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ced:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cf0:	8b 00                	mov    (%eax),%eax
  800cf2:	89 04 24             	mov    %eax,(%esp)
  800cf5:	e8 b2 fc ff ff       	call   8009ac <dev_lookup>
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	78 50                	js     800d4e <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800cfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d01:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800d05:	75 23                	jne    800d2a <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800d07:	a1 08 40 80 00       	mov    0x804008,%eax
  800d0c:	8b 40 48             	mov    0x48(%eax),%eax
  800d0f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d13:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d17:	c7 04 24 19 27 80 00 	movl   $0x802719,(%esp)
  800d1e:	e8 6c 0f 00 00       	call   801c8f <cprintf>
		return -E_INVAL;
  800d23:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d28:	eb 24                	jmp    800d4e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800d2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d2d:	8b 52 0c             	mov    0xc(%edx),%edx
  800d30:	85 d2                	test   %edx,%edx
  800d32:	74 15                	je     800d49 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800d34:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800d37:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d42:	89 04 24             	mov    %eax,(%esp)
  800d45:	ff d2                	call   *%edx
  800d47:	eb 05                	jmp    800d4e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800d49:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800d4e:	83 c4 24             	add    $0x24,%esp
  800d51:	5b                   	pop    %ebx
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <seek>:

int
seek(int fdnum, off_t offset)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800d5a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800d5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d61:	8b 45 08             	mov    0x8(%ebp),%eax
  800d64:	89 04 24             	mov    %eax,(%esp)
  800d67:	e8 ea fb ff ff       	call   800956 <fd_lookup>
  800d6c:	85 c0                	test   %eax,%eax
  800d6e:	78 0e                	js     800d7e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800d70:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d73:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d76:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800d79:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d7e:	c9                   	leave  
  800d7f:	c3                   	ret    

00800d80 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	53                   	push   %ebx
  800d84:	83 ec 24             	sub    $0x24,%esp
  800d87:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d8a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d91:	89 1c 24             	mov    %ebx,(%esp)
  800d94:	e8 bd fb ff ff       	call   800956 <fd_lookup>
  800d99:	89 c2                	mov    %eax,%edx
  800d9b:	85 d2                	test   %edx,%edx
  800d9d:	78 61                	js     800e00 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800da2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800da6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800da9:	8b 00                	mov    (%eax),%eax
  800dab:	89 04 24             	mov    %eax,(%esp)
  800dae:	e8 f9 fb ff ff       	call   8009ac <dev_lookup>
  800db3:	85 c0                	test   %eax,%eax
  800db5:	78 49                	js     800e00 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800db7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dba:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800dbe:	75 23                	jne    800de3 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800dc0:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800dc5:	8b 40 48             	mov    0x48(%eax),%eax
  800dc8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800dcc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dd0:	c7 04 24 dc 26 80 00 	movl   $0x8026dc,(%esp)
  800dd7:	e8 b3 0e 00 00       	call   801c8f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800ddc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800de1:	eb 1d                	jmp    800e00 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  800de3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800de6:	8b 52 18             	mov    0x18(%edx),%edx
  800de9:	85 d2                	test   %edx,%edx
  800deb:	74 0e                	je     800dfb <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800ded:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800df4:	89 04 24             	mov    %eax,(%esp)
  800df7:	ff d2                	call   *%edx
  800df9:	eb 05                	jmp    800e00 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800dfb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800e00:	83 c4 24             	add    $0x24,%esp
  800e03:	5b                   	pop    %ebx
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    

00800e06 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	53                   	push   %ebx
  800e0a:	83 ec 24             	sub    $0x24,%esp
  800e0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800e10:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e13:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e17:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1a:	89 04 24             	mov    %eax,(%esp)
  800e1d:	e8 34 fb ff ff       	call   800956 <fd_lookup>
  800e22:	89 c2                	mov    %eax,%edx
  800e24:	85 d2                	test   %edx,%edx
  800e26:	78 52                	js     800e7a <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e32:	8b 00                	mov    (%eax),%eax
  800e34:	89 04 24             	mov    %eax,(%esp)
  800e37:	e8 70 fb ff ff       	call   8009ac <dev_lookup>
  800e3c:	85 c0                	test   %eax,%eax
  800e3e:	78 3a                	js     800e7a <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  800e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e43:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800e47:	74 2c                	je     800e75 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800e49:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800e4c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800e53:	00 00 00 
	stat->st_isdir = 0;
  800e56:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800e5d:	00 00 00 
	stat->st_dev = dev;
  800e60:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800e66:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e6a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e6d:	89 14 24             	mov    %edx,(%esp)
  800e70:	ff 50 14             	call   *0x14(%eax)
  800e73:	eb 05                	jmp    800e7a <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800e75:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800e7a:	83 c4 24             	add    $0x24,%esp
  800e7d:	5b                   	pop    %ebx
  800e7e:	5d                   	pop    %ebp
  800e7f:	c3                   	ret    

00800e80 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	56                   	push   %esi
  800e84:	53                   	push   %ebx
  800e85:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800e88:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e8f:	00 
  800e90:	8b 45 08             	mov    0x8(%ebp),%eax
  800e93:	89 04 24             	mov    %eax,(%esp)
  800e96:	e8 28 02 00 00       	call   8010c3 <open>
  800e9b:	89 c3                	mov    %eax,%ebx
  800e9d:	85 db                	test   %ebx,%ebx
  800e9f:	78 1b                	js     800ebc <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  800ea1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ea8:	89 1c 24             	mov    %ebx,(%esp)
  800eab:	e8 56 ff ff ff       	call   800e06 <fstat>
  800eb0:	89 c6                	mov    %eax,%esi
	close(fd);
  800eb2:	89 1c 24             	mov    %ebx,(%esp)
  800eb5:	e8 cd fb ff ff       	call   800a87 <close>
	return r;
  800eba:	89 f0                	mov    %esi,%eax
}
  800ebc:	83 c4 10             	add    $0x10,%esp
  800ebf:	5b                   	pop    %ebx
  800ec0:	5e                   	pop    %esi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	56                   	push   %esi
  800ec7:	53                   	push   %ebx
  800ec8:	83 ec 10             	sub    $0x10,%esp
  800ecb:	89 c6                	mov    %eax,%esi
  800ecd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800ecf:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800ed6:	75 11                	jne    800ee9 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800ed8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800edf:	e8 81 14 00 00       	call   802365 <ipc_find_env>
  800ee4:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800ee9:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800ef0:	00 
  800ef1:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800ef8:	00 
  800ef9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800efd:	a1 00 40 80 00       	mov    0x804000,%eax
  800f02:	89 04 24             	mov    %eax,(%esp)
  800f05:	e8 f0 13 00 00       	call   8022fa <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800f0a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f11:	00 
  800f12:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f16:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f1d:	e8 5e 13 00 00       	call   802280 <ipc_recv>
}
  800f22:	83 c4 10             	add    $0x10,%esp
  800f25:	5b                   	pop    %ebx
  800f26:	5e                   	pop    %esi
  800f27:	5d                   	pop    %ebp
  800f28:	c3                   	ret    

00800f29 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800f2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f32:	8b 40 0c             	mov    0xc(%eax),%eax
  800f35:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800f3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f3d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800f42:	ba 00 00 00 00       	mov    $0x0,%edx
  800f47:	b8 02 00 00 00       	mov    $0x2,%eax
  800f4c:	e8 72 ff ff ff       	call   800ec3 <fsipc>
}
  800f51:	c9                   	leave  
  800f52:	c3                   	ret    

00800f53 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800f59:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5c:	8b 40 0c             	mov    0xc(%eax),%eax
  800f5f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800f64:	ba 00 00 00 00       	mov    $0x0,%edx
  800f69:	b8 06 00 00 00       	mov    $0x6,%eax
  800f6e:	e8 50 ff ff ff       	call   800ec3 <fsipc>
}
  800f73:	c9                   	leave  
  800f74:	c3                   	ret    

00800f75 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800f75:	55                   	push   %ebp
  800f76:	89 e5                	mov    %esp,%ebp
  800f78:	53                   	push   %ebx
  800f79:	83 ec 14             	sub    $0x14,%esp
  800f7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800f7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f82:	8b 40 0c             	mov    0xc(%eax),%eax
  800f85:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800f8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800f8f:	b8 05 00 00 00       	mov    $0x5,%eax
  800f94:	e8 2a ff ff ff       	call   800ec3 <fsipc>
  800f99:	89 c2                	mov    %eax,%edx
  800f9b:	85 d2                	test   %edx,%edx
  800f9d:	78 2b                	js     800fca <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800f9f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800fa6:	00 
  800fa7:	89 1c 24             	mov    %ebx,(%esp)
  800faa:	e8 e8 f1 ff ff       	call   800197 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800faf:	a1 80 50 80 00       	mov    0x805080,%eax
  800fb4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800fba:	a1 84 50 80 00       	mov    0x805084,%eax
  800fbf:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800fc5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fca:	83 c4 14             	add    $0x14,%esp
  800fcd:	5b                   	pop    %ebx
  800fce:	5d                   	pop    %ebp
  800fcf:	c3                   	ret    

00800fd0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	83 ec 18             	sub    $0x18,%esp
  800fd6:	8b 45 10             	mov    0x10(%ebp),%eax
  800fd9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800fde:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800fe3:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800fe6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe9:	8b 52 0c             	mov    0xc(%edx),%edx
  800fec:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800ff2:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  800ff7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ffb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ffe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801002:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801009:	e8 26 f3 ff ff       	call   800334 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  80100e:	ba 00 00 00 00       	mov    $0x0,%edx
  801013:	b8 04 00 00 00       	mov    $0x4,%eax
  801018:	e8 a6 fe ff ff       	call   800ec3 <fsipc>
}
  80101d:	c9                   	leave  
  80101e:	c3                   	ret    

0080101f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80101f:	55                   	push   %ebp
  801020:	89 e5                	mov    %esp,%ebp
  801022:	56                   	push   %esi
  801023:	53                   	push   %ebx
  801024:	83 ec 10             	sub    $0x10,%esp
  801027:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80102a:	8b 45 08             	mov    0x8(%ebp),%eax
  80102d:	8b 40 0c             	mov    0xc(%eax),%eax
  801030:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801035:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80103b:	ba 00 00 00 00       	mov    $0x0,%edx
  801040:	b8 03 00 00 00       	mov    $0x3,%eax
  801045:	e8 79 fe ff ff       	call   800ec3 <fsipc>
  80104a:	89 c3                	mov    %eax,%ebx
  80104c:	85 c0                	test   %eax,%eax
  80104e:	78 6a                	js     8010ba <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801050:	39 c6                	cmp    %eax,%esi
  801052:	73 24                	jae    801078 <devfile_read+0x59>
  801054:	c7 44 24 0c 4c 27 80 	movl   $0x80274c,0xc(%esp)
  80105b:	00 
  80105c:	c7 44 24 08 53 27 80 	movl   $0x802753,0x8(%esp)
  801063:	00 
  801064:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80106b:	00 
  80106c:	c7 04 24 68 27 80 00 	movl   $0x802768,(%esp)
  801073:	e8 1e 0b 00 00       	call   801b96 <_panic>
	assert(r <= PGSIZE);
  801078:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80107d:	7e 24                	jle    8010a3 <devfile_read+0x84>
  80107f:	c7 44 24 0c 73 27 80 	movl   $0x802773,0xc(%esp)
  801086:	00 
  801087:	c7 44 24 08 53 27 80 	movl   $0x802753,0x8(%esp)
  80108e:	00 
  80108f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801096:	00 
  801097:	c7 04 24 68 27 80 00 	movl   $0x802768,(%esp)
  80109e:	e8 f3 0a 00 00       	call   801b96 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8010a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a7:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8010ae:	00 
  8010af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b2:	89 04 24             	mov    %eax,(%esp)
  8010b5:	e8 7a f2 ff ff       	call   800334 <memmove>
	return r;
}
  8010ba:	89 d8                	mov    %ebx,%eax
  8010bc:	83 c4 10             	add    $0x10,%esp
  8010bf:	5b                   	pop    %ebx
  8010c0:	5e                   	pop    %esi
  8010c1:	5d                   	pop    %ebp
  8010c2:	c3                   	ret    

008010c3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	53                   	push   %ebx
  8010c7:	83 ec 24             	sub    $0x24,%esp
  8010ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8010cd:	89 1c 24             	mov    %ebx,(%esp)
  8010d0:	e8 8b f0 ff ff       	call   800160 <strlen>
  8010d5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8010da:	7f 60                	jg     80113c <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8010dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010df:	89 04 24             	mov    %eax,(%esp)
  8010e2:	e8 20 f8 ff ff       	call   800907 <fd_alloc>
  8010e7:	89 c2                	mov    %eax,%edx
  8010e9:	85 d2                	test   %edx,%edx
  8010eb:	78 54                	js     801141 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8010ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010f1:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8010f8:	e8 9a f0 ff ff       	call   800197 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8010fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801100:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801105:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801108:	b8 01 00 00 00       	mov    $0x1,%eax
  80110d:	e8 b1 fd ff ff       	call   800ec3 <fsipc>
  801112:	89 c3                	mov    %eax,%ebx
  801114:	85 c0                	test   %eax,%eax
  801116:	79 17                	jns    80112f <open+0x6c>
		fd_close(fd, 0);
  801118:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80111f:	00 
  801120:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801123:	89 04 24             	mov    %eax,(%esp)
  801126:	e8 db f8 ff ff       	call   800a06 <fd_close>
		return r;
  80112b:	89 d8                	mov    %ebx,%eax
  80112d:	eb 12                	jmp    801141 <open+0x7e>
	}

	return fd2num(fd);
  80112f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801132:	89 04 24             	mov    %eax,(%esp)
  801135:	e8 a6 f7 ff ff       	call   8008e0 <fd2num>
  80113a:	eb 05                	jmp    801141 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80113c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801141:	83 c4 24             	add    $0x24,%esp
  801144:	5b                   	pop    %ebx
  801145:	5d                   	pop    %ebp
  801146:	c3                   	ret    

00801147 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801147:	55                   	push   %ebp
  801148:	89 e5                	mov    %esp,%ebp
  80114a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80114d:	ba 00 00 00 00       	mov    $0x0,%edx
  801152:	b8 08 00 00 00       	mov    $0x8,%eax
  801157:	e8 67 fd ff ff       	call   800ec3 <fsipc>
}
  80115c:	c9                   	leave  
  80115d:	c3                   	ret    
  80115e:	66 90                	xchg   %ax,%ax

00801160 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801166:	c7 44 24 04 7f 27 80 	movl   $0x80277f,0x4(%esp)
  80116d:	00 
  80116e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801171:	89 04 24             	mov    %eax,(%esp)
  801174:	e8 1e f0 ff ff       	call   800197 <strcpy>
	return 0;
}
  801179:	b8 00 00 00 00       	mov    $0x0,%eax
  80117e:	c9                   	leave  
  80117f:	c3                   	ret    

00801180 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	53                   	push   %ebx
  801184:	83 ec 14             	sub    $0x14,%esp
  801187:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80118a:	89 1c 24             	mov    %ebx,(%esp)
  80118d:	e8 0b 12 00 00       	call   80239d <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801192:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801197:	83 f8 01             	cmp    $0x1,%eax
  80119a:	75 0d                	jne    8011a9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80119c:	8b 43 0c             	mov    0xc(%ebx),%eax
  80119f:	89 04 24             	mov    %eax,(%esp)
  8011a2:	e8 29 03 00 00       	call   8014d0 <nsipc_close>
  8011a7:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  8011a9:	89 d0                	mov    %edx,%eax
  8011ab:	83 c4 14             	add    $0x14,%esp
  8011ae:	5b                   	pop    %ebx
  8011af:	5d                   	pop    %ebp
  8011b0:	c3                   	ret    

008011b1 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
  8011b4:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8011b7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011be:	00 
  8011bf:	8b 45 10             	mov    0x10(%ebp),%eax
  8011c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8011d3:	89 04 24             	mov    %eax,(%esp)
  8011d6:	e8 f0 03 00 00       	call   8015cb <nsipc_send>
}
  8011db:	c9                   	leave  
  8011dc:	c3                   	ret    

008011dd <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
  8011e0:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8011e3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011ea:	00 
  8011eb:	8b 45 10             	mov    0x10(%ebp),%eax
  8011ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fc:	8b 40 0c             	mov    0xc(%eax),%eax
  8011ff:	89 04 24             	mov    %eax,(%esp)
  801202:	e8 44 03 00 00       	call   80154b <nsipc_recv>
}
  801207:	c9                   	leave  
  801208:	c3                   	ret    

00801209 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
  80120c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80120f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801212:	89 54 24 04          	mov    %edx,0x4(%esp)
  801216:	89 04 24             	mov    %eax,(%esp)
  801219:	e8 38 f7 ff ff       	call   800956 <fd_lookup>
  80121e:	85 c0                	test   %eax,%eax
  801220:	78 17                	js     801239 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801222:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801225:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80122b:	39 08                	cmp    %ecx,(%eax)
  80122d:	75 05                	jne    801234 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80122f:	8b 40 0c             	mov    0xc(%eax),%eax
  801232:	eb 05                	jmp    801239 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801234:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801239:	c9                   	leave  
  80123a:	c3                   	ret    

0080123b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80123b:	55                   	push   %ebp
  80123c:	89 e5                	mov    %esp,%ebp
  80123e:	56                   	push   %esi
  80123f:	53                   	push   %ebx
  801240:	83 ec 20             	sub    $0x20,%esp
  801243:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801245:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801248:	89 04 24             	mov    %eax,(%esp)
  80124b:	e8 b7 f6 ff ff       	call   800907 <fd_alloc>
  801250:	89 c3                	mov    %eax,%ebx
  801252:	85 c0                	test   %eax,%eax
  801254:	78 21                	js     801277 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801256:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80125d:	00 
  80125e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801261:	89 44 24 04          	mov    %eax,0x4(%esp)
  801265:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80126c:	e8 42 f3 ff ff       	call   8005b3 <sys_page_alloc>
  801271:	89 c3                	mov    %eax,%ebx
  801273:	85 c0                	test   %eax,%eax
  801275:	79 0c                	jns    801283 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  801277:	89 34 24             	mov    %esi,(%esp)
  80127a:	e8 51 02 00 00       	call   8014d0 <nsipc_close>
		return r;
  80127f:	89 d8                	mov    %ebx,%eax
  801281:	eb 20                	jmp    8012a3 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801283:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801289:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80128c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80128e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801291:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801298:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  80129b:	89 14 24             	mov    %edx,(%esp)
  80129e:	e8 3d f6 ff ff       	call   8008e0 <fd2num>
}
  8012a3:	83 c4 20             	add    $0x20,%esp
  8012a6:	5b                   	pop    %ebx
  8012a7:	5e                   	pop    %esi
  8012a8:	5d                   	pop    %ebp
  8012a9:	c3                   	ret    

008012aa <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8012aa:	55                   	push   %ebp
  8012ab:	89 e5                	mov    %esp,%ebp
  8012ad:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8012b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b3:	e8 51 ff ff ff       	call   801209 <fd2sockid>
		return r;
  8012b8:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8012ba:	85 c0                	test   %eax,%eax
  8012bc:	78 23                	js     8012e1 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8012be:	8b 55 10             	mov    0x10(%ebp),%edx
  8012c1:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012cc:	89 04 24             	mov    %eax,(%esp)
  8012cf:	e8 45 01 00 00       	call   801419 <nsipc_accept>
		return r;
  8012d4:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8012d6:	85 c0                	test   %eax,%eax
  8012d8:	78 07                	js     8012e1 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  8012da:	e8 5c ff ff ff       	call   80123b <alloc_sockfd>
  8012df:	89 c1                	mov    %eax,%ecx
}
  8012e1:	89 c8                	mov    %ecx,%eax
  8012e3:	c9                   	leave  
  8012e4:	c3                   	ret    

008012e5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8012e5:	55                   	push   %ebp
  8012e6:	89 e5                	mov    %esp,%ebp
  8012e8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8012eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ee:	e8 16 ff ff ff       	call   801209 <fd2sockid>
  8012f3:	89 c2                	mov    %eax,%edx
  8012f5:	85 d2                	test   %edx,%edx
  8012f7:	78 16                	js     80130f <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  8012f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8012fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801300:	8b 45 0c             	mov    0xc(%ebp),%eax
  801303:	89 44 24 04          	mov    %eax,0x4(%esp)
  801307:	89 14 24             	mov    %edx,(%esp)
  80130a:	e8 60 01 00 00       	call   80146f <nsipc_bind>
}
  80130f:	c9                   	leave  
  801310:	c3                   	ret    

00801311 <shutdown>:

int
shutdown(int s, int how)
{
  801311:	55                   	push   %ebp
  801312:	89 e5                	mov    %esp,%ebp
  801314:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801317:	8b 45 08             	mov    0x8(%ebp),%eax
  80131a:	e8 ea fe ff ff       	call   801209 <fd2sockid>
  80131f:	89 c2                	mov    %eax,%edx
  801321:	85 d2                	test   %edx,%edx
  801323:	78 0f                	js     801334 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801325:	8b 45 0c             	mov    0xc(%ebp),%eax
  801328:	89 44 24 04          	mov    %eax,0x4(%esp)
  80132c:	89 14 24             	mov    %edx,(%esp)
  80132f:	e8 7a 01 00 00       	call   8014ae <nsipc_shutdown>
}
  801334:	c9                   	leave  
  801335:	c3                   	ret    

00801336 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801336:	55                   	push   %ebp
  801337:	89 e5                	mov    %esp,%ebp
  801339:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80133c:	8b 45 08             	mov    0x8(%ebp),%eax
  80133f:	e8 c5 fe ff ff       	call   801209 <fd2sockid>
  801344:	89 c2                	mov    %eax,%edx
  801346:	85 d2                	test   %edx,%edx
  801348:	78 16                	js     801360 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  80134a:	8b 45 10             	mov    0x10(%ebp),%eax
  80134d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801351:	8b 45 0c             	mov    0xc(%ebp),%eax
  801354:	89 44 24 04          	mov    %eax,0x4(%esp)
  801358:	89 14 24             	mov    %edx,(%esp)
  80135b:	e8 8a 01 00 00       	call   8014ea <nsipc_connect>
}
  801360:	c9                   	leave  
  801361:	c3                   	ret    

00801362 <listen>:

int
listen(int s, int backlog)
{
  801362:	55                   	push   %ebp
  801363:	89 e5                	mov    %esp,%ebp
  801365:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801368:	8b 45 08             	mov    0x8(%ebp),%eax
  80136b:	e8 99 fe ff ff       	call   801209 <fd2sockid>
  801370:	89 c2                	mov    %eax,%edx
  801372:	85 d2                	test   %edx,%edx
  801374:	78 0f                	js     801385 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801376:	8b 45 0c             	mov    0xc(%ebp),%eax
  801379:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137d:	89 14 24             	mov    %edx,(%esp)
  801380:	e8 a4 01 00 00       	call   801529 <nsipc_listen>
}
  801385:	c9                   	leave  
  801386:	c3                   	ret    

00801387 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80138d:	8b 45 10             	mov    0x10(%ebp),%eax
  801390:	89 44 24 08          	mov    %eax,0x8(%esp)
  801394:	8b 45 0c             	mov    0xc(%ebp),%eax
  801397:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139b:	8b 45 08             	mov    0x8(%ebp),%eax
  80139e:	89 04 24             	mov    %eax,(%esp)
  8013a1:	e8 98 02 00 00       	call   80163e <nsipc_socket>
  8013a6:	89 c2                	mov    %eax,%edx
  8013a8:	85 d2                	test   %edx,%edx
  8013aa:	78 05                	js     8013b1 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  8013ac:	e8 8a fe ff ff       	call   80123b <alloc_sockfd>
}
  8013b1:	c9                   	leave  
  8013b2:	c3                   	ret    

008013b3 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8013b3:	55                   	push   %ebp
  8013b4:	89 e5                	mov    %esp,%ebp
  8013b6:	53                   	push   %ebx
  8013b7:	83 ec 14             	sub    $0x14,%esp
  8013ba:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8013bc:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8013c3:	75 11                	jne    8013d6 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8013c5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8013cc:	e8 94 0f 00 00       	call   802365 <ipc_find_env>
  8013d1:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8013d6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8013dd:	00 
  8013de:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8013e5:	00 
  8013e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013ea:	a1 04 40 80 00       	mov    0x804004,%eax
  8013ef:	89 04 24             	mov    %eax,(%esp)
  8013f2:	e8 03 0f 00 00       	call   8022fa <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8013f7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013fe:	00 
  8013ff:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801406:	00 
  801407:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80140e:	e8 6d 0e 00 00       	call   802280 <ipc_recv>
}
  801413:	83 c4 14             	add    $0x14,%esp
  801416:	5b                   	pop    %ebx
  801417:	5d                   	pop    %ebp
  801418:	c3                   	ret    

00801419 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801419:	55                   	push   %ebp
  80141a:	89 e5                	mov    %esp,%ebp
  80141c:	56                   	push   %esi
  80141d:	53                   	push   %ebx
  80141e:	83 ec 10             	sub    $0x10,%esp
  801421:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801424:	8b 45 08             	mov    0x8(%ebp),%eax
  801427:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80142c:	8b 06                	mov    (%esi),%eax
  80142e:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801433:	b8 01 00 00 00       	mov    $0x1,%eax
  801438:	e8 76 ff ff ff       	call   8013b3 <nsipc>
  80143d:	89 c3                	mov    %eax,%ebx
  80143f:	85 c0                	test   %eax,%eax
  801441:	78 23                	js     801466 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801443:	a1 10 60 80 00       	mov    0x806010,%eax
  801448:	89 44 24 08          	mov    %eax,0x8(%esp)
  80144c:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801453:	00 
  801454:	8b 45 0c             	mov    0xc(%ebp),%eax
  801457:	89 04 24             	mov    %eax,(%esp)
  80145a:	e8 d5 ee ff ff       	call   800334 <memmove>
		*addrlen = ret->ret_addrlen;
  80145f:	a1 10 60 80 00       	mov    0x806010,%eax
  801464:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801466:	89 d8                	mov    %ebx,%eax
  801468:	83 c4 10             	add    $0x10,%esp
  80146b:	5b                   	pop    %ebx
  80146c:	5e                   	pop    %esi
  80146d:	5d                   	pop    %ebp
  80146e:	c3                   	ret    

0080146f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80146f:	55                   	push   %ebp
  801470:	89 e5                	mov    %esp,%ebp
  801472:	53                   	push   %ebx
  801473:	83 ec 14             	sub    $0x14,%esp
  801476:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801479:	8b 45 08             	mov    0x8(%ebp),%eax
  80147c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801481:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801485:	8b 45 0c             	mov    0xc(%ebp),%eax
  801488:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148c:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801493:	e8 9c ee ff ff       	call   800334 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801498:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80149e:	b8 02 00 00 00       	mov    $0x2,%eax
  8014a3:	e8 0b ff ff ff       	call   8013b3 <nsipc>
}
  8014a8:	83 c4 14             	add    $0x14,%esp
  8014ab:	5b                   	pop    %ebx
  8014ac:	5d                   	pop    %ebp
  8014ad:	c3                   	ret    

008014ae <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8014ae:	55                   	push   %ebp
  8014af:	89 e5                	mov    %esp,%ebp
  8014b1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8014b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8014bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014bf:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8014c4:	b8 03 00 00 00       	mov    $0x3,%eax
  8014c9:	e8 e5 fe ff ff       	call   8013b3 <nsipc>
}
  8014ce:	c9                   	leave  
  8014cf:	c3                   	ret    

008014d0 <nsipc_close>:

int
nsipc_close(int s)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8014d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d9:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8014de:	b8 04 00 00 00       	mov    $0x4,%eax
  8014e3:	e8 cb fe ff ff       	call   8013b3 <nsipc>
}
  8014e8:	c9                   	leave  
  8014e9:	c3                   	ret    

008014ea <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	53                   	push   %ebx
  8014ee:	83 ec 14             	sub    $0x14,%esp
  8014f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8014f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f7:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8014fc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801500:	8b 45 0c             	mov    0xc(%ebp),%eax
  801503:	89 44 24 04          	mov    %eax,0x4(%esp)
  801507:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  80150e:	e8 21 ee ff ff       	call   800334 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801513:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801519:	b8 05 00 00 00       	mov    $0x5,%eax
  80151e:	e8 90 fe ff ff       	call   8013b3 <nsipc>
}
  801523:	83 c4 14             	add    $0x14,%esp
  801526:	5b                   	pop    %ebx
  801527:	5d                   	pop    %ebp
  801528:	c3                   	ret    

00801529 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801529:	55                   	push   %ebp
  80152a:	89 e5                	mov    %esp,%ebp
  80152c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80152f:	8b 45 08             	mov    0x8(%ebp),%eax
  801532:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801537:	8b 45 0c             	mov    0xc(%ebp),%eax
  80153a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80153f:	b8 06 00 00 00       	mov    $0x6,%eax
  801544:	e8 6a fe ff ff       	call   8013b3 <nsipc>
}
  801549:	c9                   	leave  
  80154a:	c3                   	ret    

0080154b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80154b:	55                   	push   %ebp
  80154c:	89 e5                	mov    %esp,%ebp
  80154e:	56                   	push   %esi
  80154f:	53                   	push   %ebx
  801550:	83 ec 10             	sub    $0x10,%esp
  801553:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801556:	8b 45 08             	mov    0x8(%ebp),%eax
  801559:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80155e:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801564:	8b 45 14             	mov    0x14(%ebp),%eax
  801567:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80156c:	b8 07 00 00 00       	mov    $0x7,%eax
  801571:	e8 3d fe ff ff       	call   8013b3 <nsipc>
  801576:	89 c3                	mov    %eax,%ebx
  801578:	85 c0                	test   %eax,%eax
  80157a:	78 46                	js     8015c2 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  80157c:	39 f0                	cmp    %esi,%eax
  80157e:	7f 07                	jg     801587 <nsipc_recv+0x3c>
  801580:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801585:	7e 24                	jle    8015ab <nsipc_recv+0x60>
  801587:	c7 44 24 0c 8b 27 80 	movl   $0x80278b,0xc(%esp)
  80158e:	00 
  80158f:	c7 44 24 08 53 27 80 	movl   $0x802753,0x8(%esp)
  801596:	00 
  801597:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80159e:	00 
  80159f:	c7 04 24 a0 27 80 00 	movl   $0x8027a0,(%esp)
  8015a6:	e8 eb 05 00 00       	call   801b96 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8015ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015af:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8015b6:	00 
  8015b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015ba:	89 04 24             	mov    %eax,(%esp)
  8015bd:	e8 72 ed ff ff       	call   800334 <memmove>
	}

	return r;
}
  8015c2:	89 d8                	mov    %ebx,%eax
  8015c4:	83 c4 10             	add    $0x10,%esp
  8015c7:	5b                   	pop    %ebx
  8015c8:	5e                   	pop    %esi
  8015c9:	5d                   	pop    %ebp
  8015ca:	c3                   	ret    

008015cb <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8015cb:	55                   	push   %ebp
  8015cc:	89 e5                	mov    %esp,%ebp
  8015ce:	53                   	push   %ebx
  8015cf:	83 ec 14             	sub    $0x14,%esp
  8015d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8015d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d8:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8015dd:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8015e3:	7e 24                	jle    801609 <nsipc_send+0x3e>
  8015e5:	c7 44 24 0c ac 27 80 	movl   $0x8027ac,0xc(%esp)
  8015ec:	00 
  8015ed:	c7 44 24 08 53 27 80 	movl   $0x802753,0x8(%esp)
  8015f4:	00 
  8015f5:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8015fc:	00 
  8015fd:	c7 04 24 a0 27 80 00 	movl   $0x8027a0,(%esp)
  801604:	e8 8d 05 00 00       	call   801b96 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801609:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80160d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801610:	89 44 24 04          	mov    %eax,0x4(%esp)
  801614:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  80161b:	e8 14 ed ff ff       	call   800334 <memmove>
	nsipcbuf.send.req_size = size;
  801620:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801626:	8b 45 14             	mov    0x14(%ebp),%eax
  801629:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  80162e:	b8 08 00 00 00       	mov    $0x8,%eax
  801633:	e8 7b fd ff ff       	call   8013b3 <nsipc>
}
  801638:	83 c4 14             	add    $0x14,%esp
  80163b:	5b                   	pop    %ebx
  80163c:	5d                   	pop    %ebp
  80163d:	c3                   	ret    

0080163e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801644:	8b 45 08             	mov    0x8(%ebp),%eax
  801647:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80164c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80164f:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801654:	8b 45 10             	mov    0x10(%ebp),%eax
  801657:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80165c:	b8 09 00 00 00       	mov    $0x9,%eax
  801661:	e8 4d fd ff ff       	call   8013b3 <nsipc>
}
  801666:	c9                   	leave  
  801667:	c3                   	ret    

00801668 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801668:	55                   	push   %ebp
  801669:	89 e5                	mov    %esp,%ebp
  80166b:	56                   	push   %esi
  80166c:	53                   	push   %ebx
  80166d:	83 ec 10             	sub    $0x10,%esp
  801670:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801673:	8b 45 08             	mov    0x8(%ebp),%eax
  801676:	89 04 24             	mov    %eax,(%esp)
  801679:	e8 72 f2 ff ff       	call   8008f0 <fd2data>
  80167e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801680:	c7 44 24 04 b8 27 80 	movl   $0x8027b8,0x4(%esp)
  801687:	00 
  801688:	89 1c 24             	mov    %ebx,(%esp)
  80168b:	e8 07 eb ff ff       	call   800197 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801690:	8b 46 04             	mov    0x4(%esi),%eax
  801693:	2b 06                	sub    (%esi),%eax
  801695:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80169b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016a2:	00 00 00 
	stat->st_dev = &devpipe;
  8016a5:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8016ac:	30 80 00 
	return 0;
}
  8016af:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b4:	83 c4 10             	add    $0x10,%esp
  8016b7:	5b                   	pop    %ebx
  8016b8:	5e                   	pop    %esi
  8016b9:	5d                   	pop    %ebp
  8016ba:	c3                   	ret    

008016bb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	53                   	push   %ebx
  8016bf:	83 ec 14             	sub    $0x14,%esp
  8016c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016d0:	e8 85 ef ff ff       	call   80065a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016d5:	89 1c 24             	mov    %ebx,(%esp)
  8016d8:	e8 13 f2 ff ff       	call   8008f0 <fd2data>
  8016dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016e8:	e8 6d ef ff ff       	call   80065a <sys_page_unmap>
}
  8016ed:	83 c4 14             	add    $0x14,%esp
  8016f0:	5b                   	pop    %ebx
  8016f1:	5d                   	pop    %ebp
  8016f2:	c3                   	ret    

008016f3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	57                   	push   %edi
  8016f7:	56                   	push   %esi
  8016f8:	53                   	push   %ebx
  8016f9:	83 ec 2c             	sub    $0x2c,%esp
  8016fc:	89 c6                	mov    %eax,%esi
  8016fe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801701:	a1 08 40 80 00       	mov    0x804008,%eax
  801706:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801709:	89 34 24             	mov    %esi,(%esp)
  80170c:	e8 8c 0c 00 00       	call   80239d <pageref>
  801711:	89 c7                	mov    %eax,%edi
  801713:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801716:	89 04 24             	mov    %eax,(%esp)
  801719:	e8 7f 0c 00 00       	call   80239d <pageref>
  80171e:	39 c7                	cmp    %eax,%edi
  801720:	0f 94 c2             	sete   %dl
  801723:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801726:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  80172c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  80172f:	39 fb                	cmp    %edi,%ebx
  801731:	74 21                	je     801754 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801733:	84 d2                	test   %dl,%dl
  801735:	74 ca                	je     801701 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801737:	8b 51 58             	mov    0x58(%ecx),%edx
  80173a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80173e:	89 54 24 08          	mov    %edx,0x8(%esp)
  801742:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801746:	c7 04 24 bf 27 80 00 	movl   $0x8027bf,(%esp)
  80174d:	e8 3d 05 00 00       	call   801c8f <cprintf>
  801752:	eb ad                	jmp    801701 <_pipeisclosed+0xe>
	}
}
  801754:	83 c4 2c             	add    $0x2c,%esp
  801757:	5b                   	pop    %ebx
  801758:	5e                   	pop    %esi
  801759:	5f                   	pop    %edi
  80175a:	5d                   	pop    %ebp
  80175b:	c3                   	ret    

0080175c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	57                   	push   %edi
  801760:	56                   	push   %esi
  801761:	53                   	push   %ebx
  801762:	83 ec 1c             	sub    $0x1c,%esp
  801765:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801768:	89 34 24             	mov    %esi,(%esp)
  80176b:	e8 80 f1 ff ff       	call   8008f0 <fd2data>
  801770:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801772:	bf 00 00 00 00       	mov    $0x0,%edi
  801777:	eb 45                	jmp    8017be <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801779:	89 da                	mov    %ebx,%edx
  80177b:	89 f0                	mov    %esi,%eax
  80177d:	e8 71 ff ff ff       	call   8016f3 <_pipeisclosed>
  801782:	85 c0                	test   %eax,%eax
  801784:	75 41                	jne    8017c7 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801786:	e8 09 ee ff ff       	call   800594 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80178b:	8b 43 04             	mov    0x4(%ebx),%eax
  80178e:	8b 0b                	mov    (%ebx),%ecx
  801790:	8d 51 20             	lea    0x20(%ecx),%edx
  801793:	39 d0                	cmp    %edx,%eax
  801795:	73 e2                	jae    801779 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801797:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80179a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80179e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8017a1:	99                   	cltd   
  8017a2:	c1 ea 1b             	shr    $0x1b,%edx
  8017a5:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8017a8:	83 e1 1f             	and    $0x1f,%ecx
  8017ab:	29 d1                	sub    %edx,%ecx
  8017ad:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8017b1:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8017b5:	83 c0 01             	add    $0x1,%eax
  8017b8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017bb:	83 c7 01             	add    $0x1,%edi
  8017be:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017c1:	75 c8                	jne    80178b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017c3:	89 f8                	mov    %edi,%eax
  8017c5:	eb 05                	jmp    8017cc <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017c7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017cc:	83 c4 1c             	add    $0x1c,%esp
  8017cf:	5b                   	pop    %ebx
  8017d0:	5e                   	pop    %esi
  8017d1:	5f                   	pop    %edi
  8017d2:	5d                   	pop    %ebp
  8017d3:	c3                   	ret    

008017d4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	57                   	push   %edi
  8017d8:	56                   	push   %esi
  8017d9:	53                   	push   %ebx
  8017da:	83 ec 1c             	sub    $0x1c,%esp
  8017dd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017e0:	89 3c 24             	mov    %edi,(%esp)
  8017e3:	e8 08 f1 ff ff       	call   8008f0 <fd2data>
  8017e8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017ea:	be 00 00 00 00       	mov    $0x0,%esi
  8017ef:	eb 3d                	jmp    80182e <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017f1:	85 f6                	test   %esi,%esi
  8017f3:	74 04                	je     8017f9 <devpipe_read+0x25>
				return i;
  8017f5:	89 f0                	mov    %esi,%eax
  8017f7:	eb 43                	jmp    80183c <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017f9:	89 da                	mov    %ebx,%edx
  8017fb:	89 f8                	mov    %edi,%eax
  8017fd:	e8 f1 fe ff ff       	call   8016f3 <_pipeisclosed>
  801802:	85 c0                	test   %eax,%eax
  801804:	75 31                	jne    801837 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801806:	e8 89 ed ff ff       	call   800594 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80180b:	8b 03                	mov    (%ebx),%eax
  80180d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801810:	74 df                	je     8017f1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801812:	99                   	cltd   
  801813:	c1 ea 1b             	shr    $0x1b,%edx
  801816:	01 d0                	add    %edx,%eax
  801818:	83 e0 1f             	and    $0x1f,%eax
  80181b:	29 d0                	sub    %edx,%eax
  80181d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801822:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801825:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801828:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80182b:	83 c6 01             	add    $0x1,%esi
  80182e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801831:	75 d8                	jne    80180b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801833:	89 f0                	mov    %esi,%eax
  801835:	eb 05                	jmp    80183c <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801837:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80183c:	83 c4 1c             	add    $0x1c,%esp
  80183f:	5b                   	pop    %ebx
  801840:	5e                   	pop    %esi
  801841:	5f                   	pop    %edi
  801842:	5d                   	pop    %ebp
  801843:	c3                   	ret    

00801844 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801844:	55                   	push   %ebp
  801845:	89 e5                	mov    %esp,%ebp
  801847:	56                   	push   %esi
  801848:	53                   	push   %ebx
  801849:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80184c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184f:	89 04 24             	mov    %eax,(%esp)
  801852:	e8 b0 f0 ff ff       	call   800907 <fd_alloc>
  801857:	89 c2                	mov    %eax,%edx
  801859:	85 d2                	test   %edx,%edx
  80185b:	0f 88 4d 01 00 00    	js     8019ae <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801861:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801868:	00 
  801869:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80186c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801870:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801877:	e8 37 ed ff ff       	call   8005b3 <sys_page_alloc>
  80187c:	89 c2                	mov    %eax,%edx
  80187e:	85 d2                	test   %edx,%edx
  801880:	0f 88 28 01 00 00    	js     8019ae <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801886:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801889:	89 04 24             	mov    %eax,(%esp)
  80188c:	e8 76 f0 ff ff       	call   800907 <fd_alloc>
  801891:	89 c3                	mov    %eax,%ebx
  801893:	85 c0                	test   %eax,%eax
  801895:	0f 88 fe 00 00 00    	js     801999 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80189b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8018a2:	00 
  8018a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018b1:	e8 fd ec ff ff       	call   8005b3 <sys_page_alloc>
  8018b6:	89 c3                	mov    %eax,%ebx
  8018b8:	85 c0                	test   %eax,%eax
  8018ba:	0f 88 d9 00 00 00    	js     801999 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018c3:	89 04 24             	mov    %eax,(%esp)
  8018c6:	e8 25 f0 ff ff       	call   8008f0 <fd2data>
  8018cb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018cd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8018d4:	00 
  8018d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018e0:	e8 ce ec ff ff       	call   8005b3 <sys_page_alloc>
  8018e5:	89 c3                	mov    %eax,%ebx
  8018e7:	85 c0                	test   %eax,%eax
  8018e9:	0f 88 97 00 00 00    	js     801986 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f2:	89 04 24             	mov    %eax,(%esp)
  8018f5:	e8 f6 ef ff ff       	call   8008f0 <fd2data>
  8018fa:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801901:	00 
  801902:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801906:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80190d:	00 
  80190e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801912:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801919:	e8 e9 ec ff ff       	call   800607 <sys_page_map>
  80191e:	89 c3                	mov    %eax,%ebx
  801920:	85 c0                	test   %eax,%eax
  801922:	78 52                	js     801976 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801924:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80192a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80192d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80192f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801932:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801939:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80193f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801942:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801944:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801947:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80194e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801951:	89 04 24             	mov    %eax,(%esp)
  801954:	e8 87 ef ff ff       	call   8008e0 <fd2num>
  801959:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80195c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80195e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801961:	89 04 24             	mov    %eax,(%esp)
  801964:	e8 77 ef ff ff       	call   8008e0 <fd2num>
  801969:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80196c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80196f:	b8 00 00 00 00       	mov    $0x0,%eax
  801974:	eb 38                	jmp    8019ae <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  801976:	89 74 24 04          	mov    %esi,0x4(%esp)
  80197a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801981:	e8 d4 ec ff ff       	call   80065a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801986:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801989:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801994:	e8 c1 ec ff ff       	call   80065a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801999:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019a7:	e8 ae ec ff ff       	call   80065a <sys_page_unmap>
  8019ac:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  8019ae:	83 c4 30             	add    $0x30,%esp
  8019b1:	5b                   	pop    %ebx
  8019b2:	5e                   	pop    %esi
  8019b3:	5d                   	pop    %ebp
  8019b4:	c3                   	ret    

008019b5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8019b5:	55                   	push   %ebp
  8019b6:	89 e5                	mov    %esp,%ebp
  8019b8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c5:	89 04 24             	mov    %eax,(%esp)
  8019c8:	e8 89 ef ff ff       	call   800956 <fd_lookup>
  8019cd:	89 c2                	mov    %eax,%edx
  8019cf:	85 d2                	test   %edx,%edx
  8019d1:	78 15                	js     8019e8 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8019d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d6:	89 04 24             	mov    %eax,(%esp)
  8019d9:	e8 12 ef ff ff       	call   8008f0 <fd2data>
	return _pipeisclosed(fd, p);
  8019de:	89 c2                	mov    %eax,%edx
  8019e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e3:	e8 0b fd ff ff       	call   8016f3 <_pipeisclosed>
}
  8019e8:	c9                   	leave  
  8019e9:	c3                   	ret    
  8019ea:	66 90                	xchg   %ax,%ax
  8019ec:	66 90                	xchg   %ax,%ax
  8019ee:	66 90                	xchg   %ax,%ax

008019f0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019f0:	55                   	push   %ebp
  8019f1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f8:	5d                   	pop    %ebp
  8019f9:	c3                   	ret    

008019fa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801a00:	c7 44 24 04 d7 27 80 	movl   $0x8027d7,0x4(%esp)
  801a07:	00 
  801a08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0b:	89 04 24             	mov    %eax,(%esp)
  801a0e:	e8 84 e7 ff ff       	call   800197 <strcpy>
	return 0;
}
  801a13:	b8 00 00 00 00       	mov    $0x0,%eax
  801a18:	c9                   	leave  
  801a19:	c3                   	ret    

00801a1a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	57                   	push   %edi
  801a1e:	56                   	push   %esi
  801a1f:	53                   	push   %ebx
  801a20:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a26:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a2b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a31:	eb 31                	jmp    801a64 <devcons_write+0x4a>
		m = n - tot;
  801a33:	8b 75 10             	mov    0x10(%ebp),%esi
  801a36:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801a38:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a3b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a40:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a43:	89 74 24 08          	mov    %esi,0x8(%esp)
  801a47:	03 45 0c             	add    0xc(%ebp),%eax
  801a4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4e:	89 3c 24             	mov    %edi,(%esp)
  801a51:	e8 de e8 ff ff       	call   800334 <memmove>
		sys_cputs(buf, m);
  801a56:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a5a:	89 3c 24             	mov    %edi,(%esp)
  801a5d:	e8 84 ea ff ff       	call   8004e6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a62:	01 f3                	add    %esi,%ebx
  801a64:	89 d8                	mov    %ebx,%eax
  801a66:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a69:	72 c8                	jb     801a33 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a6b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801a71:	5b                   	pop    %ebx
  801a72:	5e                   	pop    %esi
  801a73:	5f                   	pop    %edi
  801a74:	5d                   	pop    %ebp
  801a75:	c3                   	ret    

00801a76 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a76:	55                   	push   %ebp
  801a77:	89 e5                	mov    %esp,%ebp
  801a79:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801a7c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801a81:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a85:	75 07                	jne    801a8e <devcons_read+0x18>
  801a87:	eb 2a                	jmp    801ab3 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a89:	e8 06 eb ff ff       	call   800594 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a8e:	66 90                	xchg   %ax,%ax
  801a90:	e8 6f ea ff ff       	call   800504 <sys_cgetc>
  801a95:	85 c0                	test   %eax,%eax
  801a97:	74 f0                	je     801a89 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a99:	85 c0                	test   %eax,%eax
  801a9b:	78 16                	js     801ab3 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a9d:	83 f8 04             	cmp    $0x4,%eax
  801aa0:	74 0c                	je     801aae <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801aa2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801aa5:	88 02                	mov    %al,(%edx)
	return 1;
  801aa7:	b8 01 00 00 00       	mov    $0x1,%eax
  801aac:	eb 05                	jmp    801ab3 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801aae:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ab3:	c9                   	leave  
  801ab4:	c3                   	ret    

00801ab5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801abb:	8b 45 08             	mov    0x8(%ebp),%eax
  801abe:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ac1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ac8:	00 
  801ac9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801acc:	89 04 24             	mov    %eax,(%esp)
  801acf:	e8 12 ea ff ff       	call   8004e6 <sys_cputs>
}
  801ad4:	c9                   	leave  
  801ad5:	c3                   	ret    

00801ad6 <getchar>:

int
getchar(void)
{
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801adc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801ae3:	00 
  801ae4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ae7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aeb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801af2:	e8 f3 f0 ff ff       	call   800bea <read>
	if (r < 0)
  801af7:	85 c0                	test   %eax,%eax
  801af9:	78 0f                	js     801b0a <getchar+0x34>
		return r;
	if (r < 1)
  801afb:	85 c0                	test   %eax,%eax
  801afd:	7e 06                	jle    801b05 <getchar+0x2f>
		return -E_EOF;
	return c;
  801aff:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b03:	eb 05                	jmp    801b0a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b05:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b0a:	c9                   	leave  
  801b0b:	c3                   	ret    

00801b0c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b15:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b19:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1c:	89 04 24             	mov    %eax,(%esp)
  801b1f:	e8 32 ee ff ff       	call   800956 <fd_lookup>
  801b24:	85 c0                	test   %eax,%eax
  801b26:	78 11                	js     801b39 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801b31:	39 10                	cmp    %edx,(%eax)
  801b33:	0f 94 c0             	sete   %al
  801b36:	0f b6 c0             	movzbl %al,%eax
}
  801b39:	c9                   	leave  
  801b3a:	c3                   	ret    

00801b3b <opencons>:

int
opencons(void)
{
  801b3b:	55                   	push   %ebp
  801b3c:	89 e5                	mov    %esp,%ebp
  801b3e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b44:	89 04 24             	mov    %eax,(%esp)
  801b47:	e8 bb ed ff ff       	call   800907 <fd_alloc>
		return r;
  801b4c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b4e:	85 c0                	test   %eax,%eax
  801b50:	78 40                	js     801b92 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b52:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b59:	00 
  801b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b68:	e8 46 ea ff ff       	call   8005b3 <sys_page_alloc>
		return r;
  801b6d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b6f:	85 c0                	test   %eax,%eax
  801b71:	78 1f                	js     801b92 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b73:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b81:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b88:	89 04 24             	mov    %eax,(%esp)
  801b8b:	e8 50 ed ff ff       	call   8008e0 <fd2num>
  801b90:	89 c2                	mov    %eax,%edx
}
  801b92:	89 d0                	mov    %edx,%eax
  801b94:	c9                   	leave  
  801b95:	c3                   	ret    

00801b96 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	56                   	push   %esi
  801b9a:	53                   	push   %ebx
  801b9b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801b9e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ba1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ba7:	e8 c9 e9 ff ff       	call   800575 <sys_getenvid>
  801bac:	8b 55 0c             	mov    0xc(%ebp),%edx
  801baf:	89 54 24 10          	mov    %edx,0x10(%esp)
  801bb3:	8b 55 08             	mov    0x8(%ebp),%edx
  801bb6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801bba:	89 74 24 08          	mov    %esi,0x8(%esp)
  801bbe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc2:	c7 04 24 e4 27 80 00 	movl   $0x8027e4,(%esp)
  801bc9:	e8 c1 00 00 00       	call   801c8f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801bce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bd2:	8b 45 10             	mov    0x10(%ebp),%eax
  801bd5:	89 04 24             	mov    %eax,(%esp)
  801bd8:	e8 51 00 00 00       	call   801c2e <vcprintf>
	cprintf("\n");
  801bdd:	c7 04 24 d0 27 80 00 	movl   $0x8027d0,(%esp)
  801be4:	e8 a6 00 00 00       	call   801c8f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801be9:	cc                   	int3   
  801bea:	eb fd                	jmp    801be9 <_panic+0x53>

00801bec <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801bec:	55                   	push   %ebp
  801bed:	89 e5                	mov    %esp,%ebp
  801bef:	53                   	push   %ebx
  801bf0:	83 ec 14             	sub    $0x14,%esp
  801bf3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801bf6:	8b 13                	mov    (%ebx),%edx
  801bf8:	8d 42 01             	lea    0x1(%edx),%eax
  801bfb:	89 03                	mov    %eax,(%ebx)
  801bfd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c00:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801c04:	3d ff 00 00 00       	cmp    $0xff,%eax
  801c09:	75 19                	jne    801c24 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  801c0b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801c12:	00 
  801c13:	8d 43 08             	lea    0x8(%ebx),%eax
  801c16:	89 04 24             	mov    %eax,(%esp)
  801c19:	e8 c8 e8 ff ff       	call   8004e6 <sys_cputs>
		b->idx = 0;
  801c1e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801c24:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801c28:	83 c4 14             	add    $0x14,%esp
  801c2b:	5b                   	pop    %ebx
  801c2c:	5d                   	pop    %ebp
  801c2d:	c3                   	ret    

00801c2e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801c2e:	55                   	push   %ebp
  801c2f:	89 e5                	mov    %esp,%ebp
  801c31:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801c37:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801c3e:	00 00 00 
	b.cnt = 0;
  801c41:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801c48:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801c4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c4e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c52:	8b 45 08             	mov    0x8(%ebp),%eax
  801c55:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c59:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801c5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c63:	c7 04 24 ec 1b 80 00 	movl   $0x801bec,(%esp)
  801c6a:	e8 af 01 00 00       	call   801e1e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801c6f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801c75:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c79:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801c7f:	89 04 24             	mov    %eax,(%esp)
  801c82:	e8 5f e8 ff ff       	call   8004e6 <sys_cputs>

	return b.cnt;
}
  801c87:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801c8d:	c9                   	leave  
  801c8e:	c3                   	ret    

00801c8f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801c95:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801c98:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9f:	89 04 24             	mov    %eax,(%esp)
  801ca2:	e8 87 ff ff ff       	call   801c2e <vcprintf>
	va_end(ap);

	return cnt;
}
  801ca7:	c9                   	leave  
  801ca8:	c3                   	ret    
  801ca9:	66 90                	xchg   %ax,%ax
  801cab:	66 90                	xchg   %ax,%ax
  801cad:	66 90                	xchg   %ax,%ax
  801caf:	90                   	nop

00801cb0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	57                   	push   %edi
  801cb4:	56                   	push   %esi
  801cb5:	53                   	push   %ebx
  801cb6:	83 ec 3c             	sub    $0x3c,%esp
  801cb9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801cbc:	89 d7                	mov    %edx,%edi
  801cbe:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801cc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc7:	89 c3                	mov    %eax,%ebx
  801cc9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801ccc:	8b 45 10             	mov    0x10(%ebp),%eax
  801ccf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801cd2:	b9 00 00 00 00       	mov    $0x0,%ecx
  801cd7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801cda:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801cdd:	39 d9                	cmp    %ebx,%ecx
  801cdf:	72 05                	jb     801ce6 <printnum+0x36>
  801ce1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  801ce4:	77 69                	ja     801d4f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801ce6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  801ce9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801ced:	83 ee 01             	sub    $0x1,%esi
  801cf0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801cf4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cf8:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cfc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d00:	89 c3                	mov    %eax,%ebx
  801d02:	89 d6                	mov    %edx,%esi
  801d04:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801d07:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801d0a:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d0e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d12:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d15:	89 04 24             	mov    %eax,(%esp)
  801d18:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801d1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d1f:	e8 bc 06 00 00       	call   8023e0 <__udivdi3>
  801d24:	89 d9                	mov    %ebx,%ecx
  801d26:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d2a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801d2e:	89 04 24             	mov    %eax,(%esp)
  801d31:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d35:	89 fa                	mov    %edi,%edx
  801d37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d3a:	e8 71 ff ff ff       	call   801cb0 <printnum>
  801d3f:	eb 1b                	jmp    801d5c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801d41:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d45:	8b 45 18             	mov    0x18(%ebp),%eax
  801d48:	89 04 24             	mov    %eax,(%esp)
  801d4b:	ff d3                	call   *%ebx
  801d4d:	eb 03                	jmp    801d52 <printnum+0xa2>
  801d4f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801d52:	83 ee 01             	sub    $0x1,%esi
  801d55:	85 f6                	test   %esi,%esi
  801d57:	7f e8                	jg     801d41 <printnum+0x91>
  801d59:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801d5c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d60:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801d64:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801d67:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801d6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d6e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d72:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d75:	89 04 24             	mov    %eax,(%esp)
  801d78:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801d7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d7f:	e8 8c 07 00 00       	call   802510 <__umoddi3>
  801d84:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d88:	0f be 80 07 28 80 00 	movsbl 0x802807(%eax),%eax
  801d8f:	89 04 24             	mov    %eax,(%esp)
  801d92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d95:	ff d0                	call   *%eax
}
  801d97:	83 c4 3c             	add    $0x3c,%esp
  801d9a:	5b                   	pop    %ebx
  801d9b:	5e                   	pop    %esi
  801d9c:	5f                   	pop    %edi
  801d9d:	5d                   	pop    %ebp
  801d9e:	c3                   	ret    

00801d9f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801d9f:	55                   	push   %ebp
  801da0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801da2:	83 fa 01             	cmp    $0x1,%edx
  801da5:	7e 0e                	jle    801db5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801da7:	8b 10                	mov    (%eax),%edx
  801da9:	8d 4a 08             	lea    0x8(%edx),%ecx
  801dac:	89 08                	mov    %ecx,(%eax)
  801dae:	8b 02                	mov    (%edx),%eax
  801db0:	8b 52 04             	mov    0x4(%edx),%edx
  801db3:	eb 22                	jmp    801dd7 <getuint+0x38>
	else if (lflag)
  801db5:	85 d2                	test   %edx,%edx
  801db7:	74 10                	je     801dc9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801db9:	8b 10                	mov    (%eax),%edx
  801dbb:	8d 4a 04             	lea    0x4(%edx),%ecx
  801dbe:	89 08                	mov    %ecx,(%eax)
  801dc0:	8b 02                	mov    (%edx),%eax
  801dc2:	ba 00 00 00 00       	mov    $0x0,%edx
  801dc7:	eb 0e                	jmp    801dd7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801dc9:	8b 10                	mov    (%eax),%edx
  801dcb:	8d 4a 04             	lea    0x4(%edx),%ecx
  801dce:	89 08                	mov    %ecx,(%eax)
  801dd0:	8b 02                	mov    (%edx),%eax
  801dd2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801dd7:	5d                   	pop    %ebp
  801dd8:	c3                   	ret    

00801dd9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801dd9:	55                   	push   %ebp
  801dda:	89 e5                	mov    %esp,%ebp
  801ddc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801ddf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801de3:	8b 10                	mov    (%eax),%edx
  801de5:	3b 50 04             	cmp    0x4(%eax),%edx
  801de8:	73 0a                	jae    801df4 <sprintputch+0x1b>
		*b->buf++ = ch;
  801dea:	8d 4a 01             	lea    0x1(%edx),%ecx
  801ded:	89 08                	mov    %ecx,(%eax)
  801def:	8b 45 08             	mov    0x8(%ebp),%eax
  801df2:	88 02                	mov    %al,(%edx)
}
  801df4:	5d                   	pop    %ebp
  801df5:	c3                   	ret    

00801df6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801df6:	55                   	push   %ebp
  801df7:	89 e5                	mov    %esp,%ebp
  801df9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801dfc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801dff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e03:	8b 45 10             	mov    0x10(%ebp),%eax
  801e06:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e11:	8b 45 08             	mov    0x8(%ebp),%eax
  801e14:	89 04 24             	mov    %eax,(%esp)
  801e17:	e8 02 00 00 00       	call   801e1e <vprintfmt>
	va_end(ap);
}
  801e1c:	c9                   	leave  
  801e1d:	c3                   	ret    

00801e1e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801e1e:	55                   	push   %ebp
  801e1f:	89 e5                	mov    %esp,%ebp
  801e21:	57                   	push   %edi
  801e22:	56                   	push   %esi
  801e23:	53                   	push   %ebx
  801e24:	83 ec 3c             	sub    $0x3c,%esp
  801e27:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e2d:	eb 14                	jmp    801e43 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801e2f:	85 c0                	test   %eax,%eax
  801e31:	0f 84 b3 03 00 00    	je     8021ea <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  801e37:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e3b:	89 04 24             	mov    %eax,(%esp)
  801e3e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801e41:	89 f3                	mov    %esi,%ebx
  801e43:	8d 73 01             	lea    0x1(%ebx),%esi
  801e46:	0f b6 03             	movzbl (%ebx),%eax
  801e49:	83 f8 25             	cmp    $0x25,%eax
  801e4c:	75 e1                	jne    801e2f <vprintfmt+0x11>
  801e4e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  801e52:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801e59:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801e60:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  801e67:	ba 00 00 00 00       	mov    $0x0,%edx
  801e6c:	eb 1d                	jmp    801e8b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e6e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801e70:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  801e74:	eb 15                	jmp    801e8b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e76:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801e78:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  801e7c:	eb 0d                	jmp    801e8b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801e7e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801e81:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801e84:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e8b:	8d 5e 01             	lea    0x1(%esi),%ebx
  801e8e:	0f b6 0e             	movzbl (%esi),%ecx
  801e91:	0f b6 c1             	movzbl %cl,%eax
  801e94:	83 e9 23             	sub    $0x23,%ecx
  801e97:	80 f9 55             	cmp    $0x55,%cl
  801e9a:	0f 87 2a 03 00 00    	ja     8021ca <vprintfmt+0x3ac>
  801ea0:	0f b6 c9             	movzbl %cl,%ecx
  801ea3:	ff 24 8d 40 29 80 00 	jmp    *0x802940(,%ecx,4)
  801eaa:	89 de                	mov    %ebx,%esi
  801eac:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801eb1:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  801eb4:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  801eb8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801ebb:	8d 58 d0             	lea    -0x30(%eax),%ebx
  801ebe:	83 fb 09             	cmp    $0x9,%ebx
  801ec1:	77 36                	ja     801ef9 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801ec3:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801ec6:	eb e9                	jmp    801eb1 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801ec8:	8b 45 14             	mov    0x14(%ebp),%eax
  801ecb:	8d 48 04             	lea    0x4(%eax),%ecx
  801ece:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801ed1:	8b 00                	mov    (%eax),%eax
  801ed3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ed6:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801ed8:	eb 22                	jmp    801efc <vprintfmt+0xde>
  801eda:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801edd:	85 c9                	test   %ecx,%ecx
  801edf:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee4:	0f 49 c1             	cmovns %ecx,%eax
  801ee7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801eea:	89 de                	mov    %ebx,%esi
  801eec:	eb 9d                	jmp    801e8b <vprintfmt+0x6d>
  801eee:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801ef0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  801ef7:	eb 92                	jmp    801e8b <vprintfmt+0x6d>
  801ef9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  801efc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801f00:	79 89                	jns    801e8b <vprintfmt+0x6d>
  801f02:	e9 77 ff ff ff       	jmp    801e7e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801f07:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f0a:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801f0c:	e9 7a ff ff ff       	jmp    801e8b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801f11:	8b 45 14             	mov    0x14(%ebp),%eax
  801f14:	8d 50 04             	lea    0x4(%eax),%edx
  801f17:	89 55 14             	mov    %edx,0x14(%ebp)
  801f1a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f1e:	8b 00                	mov    (%eax),%eax
  801f20:	89 04 24             	mov    %eax,(%esp)
  801f23:	ff 55 08             	call   *0x8(%ebp)
			break;
  801f26:	e9 18 ff ff ff       	jmp    801e43 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801f2b:	8b 45 14             	mov    0x14(%ebp),%eax
  801f2e:	8d 50 04             	lea    0x4(%eax),%edx
  801f31:	89 55 14             	mov    %edx,0x14(%ebp)
  801f34:	8b 00                	mov    (%eax),%eax
  801f36:	99                   	cltd   
  801f37:	31 d0                	xor    %edx,%eax
  801f39:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801f3b:	83 f8 0f             	cmp    $0xf,%eax
  801f3e:	7f 0b                	jg     801f4b <vprintfmt+0x12d>
  801f40:	8b 14 85 a0 2a 80 00 	mov    0x802aa0(,%eax,4),%edx
  801f47:	85 d2                	test   %edx,%edx
  801f49:	75 20                	jne    801f6b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  801f4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f4f:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  801f56:	00 
  801f57:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5e:	89 04 24             	mov    %eax,(%esp)
  801f61:	e8 90 fe ff ff       	call   801df6 <printfmt>
  801f66:	e9 d8 fe ff ff       	jmp    801e43 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  801f6b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801f6f:	c7 44 24 08 65 27 80 	movl   $0x802765,0x8(%esp)
  801f76:	00 
  801f77:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f7e:	89 04 24             	mov    %eax,(%esp)
  801f81:	e8 70 fe ff ff       	call   801df6 <printfmt>
  801f86:	e9 b8 fe ff ff       	jmp    801e43 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f8b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  801f8e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801f91:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801f94:	8b 45 14             	mov    0x14(%ebp),%eax
  801f97:	8d 50 04             	lea    0x4(%eax),%edx
  801f9a:	89 55 14             	mov    %edx,0x14(%ebp)
  801f9d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  801f9f:	85 f6                	test   %esi,%esi
  801fa1:	b8 18 28 80 00       	mov    $0x802818,%eax
  801fa6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  801fa9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  801fad:	0f 84 97 00 00 00    	je     80204a <vprintfmt+0x22c>
  801fb3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  801fb7:	0f 8e 9b 00 00 00    	jle    802058 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  801fbd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801fc1:	89 34 24             	mov    %esi,(%esp)
  801fc4:	e8 af e1 ff ff       	call   800178 <strnlen>
  801fc9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801fcc:	29 c2                	sub    %eax,%edx
  801fce:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  801fd1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801fd5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801fd8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  801fdb:	8b 75 08             	mov    0x8(%ebp),%esi
  801fde:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801fe1:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801fe3:	eb 0f                	jmp    801ff4 <vprintfmt+0x1d6>
					putch(padc, putdat);
  801fe5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801fe9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801fec:	89 04 24             	mov    %eax,(%esp)
  801fef:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801ff1:	83 eb 01             	sub    $0x1,%ebx
  801ff4:	85 db                	test   %ebx,%ebx
  801ff6:	7f ed                	jg     801fe5 <vprintfmt+0x1c7>
  801ff8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801ffb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801ffe:	85 d2                	test   %edx,%edx
  802000:	b8 00 00 00 00       	mov    $0x0,%eax
  802005:	0f 49 c2             	cmovns %edx,%eax
  802008:	29 c2                	sub    %eax,%edx
  80200a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80200d:	89 d7                	mov    %edx,%edi
  80200f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  802012:	eb 50                	jmp    802064 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  802014:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  802018:	74 1e                	je     802038 <vprintfmt+0x21a>
  80201a:	0f be d2             	movsbl %dl,%edx
  80201d:	83 ea 20             	sub    $0x20,%edx
  802020:	83 fa 5e             	cmp    $0x5e,%edx
  802023:	76 13                	jbe    802038 <vprintfmt+0x21a>
					putch('?', putdat);
  802025:	8b 45 0c             	mov    0xc(%ebp),%eax
  802028:	89 44 24 04          	mov    %eax,0x4(%esp)
  80202c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  802033:	ff 55 08             	call   *0x8(%ebp)
  802036:	eb 0d                	jmp    802045 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  802038:	8b 55 0c             	mov    0xc(%ebp),%edx
  80203b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80203f:	89 04 24             	mov    %eax,(%esp)
  802042:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  802045:	83 ef 01             	sub    $0x1,%edi
  802048:	eb 1a                	jmp    802064 <vprintfmt+0x246>
  80204a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80204d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  802050:	89 5d 10             	mov    %ebx,0x10(%ebp)
  802053:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  802056:	eb 0c                	jmp    802064 <vprintfmt+0x246>
  802058:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80205b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80205e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  802061:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  802064:	83 c6 01             	add    $0x1,%esi
  802067:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80206b:	0f be c2             	movsbl %dl,%eax
  80206e:	85 c0                	test   %eax,%eax
  802070:	74 27                	je     802099 <vprintfmt+0x27b>
  802072:	85 db                	test   %ebx,%ebx
  802074:	78 9e                	js     802014 <vprintfmt+0x1f6>
  802076:	83 eb 01             	sub    $0x1,%ebx
  802079:	79 99                	jns    802014 <vprintfmt+0x1f6>
  80207b:	89 f8                	mov    %edi,%eax
  80207d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802080:	8b 75 08             	mov    0x8(%ebp),%esi
  802083:	89 c3                	mov    %eax,%ebx
  802085:	eb 1a                	jmp    8020a1 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  802087:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80208b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  802092:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  802094:	83 eb 01             	sub    $0x1,%ebx
  802097:	eb 08                	jmp    8020a1 <vprintfmt+0x283>
  802099:	89 fb                	mov    %edi,%ebx
  80209b:	8b 75 08             	mov    0x8(%ebp),%esi
  80209e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8020a1:	85 db                	test   %ebx,%ebx
  8020a3:	7f e2                	jg     802087 <vprintfmt+0x269>
  8020a5:	89 75 08             	mov    %esi,0x8(%ebp)
  8020a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8020ab:	e9 93 fd ff ff       	jmp    801e43 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8020b0:	83 fa 01             	cmp    $0x1,%edx
  8020b3:	7e 16                	jle    8020cb <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  8020b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8020b8:	8d 50 08             	lea    0x8(%eax),%edx
  8020bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8020be:	8b 50 04             	mov    0x4(%eax),%edx
  8020c1:	8b 00                	mov    (%eax),%eax
  8020c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8020c6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8020c9:	eb 32                	jmp    8020fd <vprintfmt+0x2df>
	else if (lflag)
  8020cb:	85 d2                	test   %edx,%edx
  8020cd:	74 18                	je     8020e7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8020cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8020d2:	8d 50 04             	lea    0x4(%eax),%edx
  8020d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8020d8:	8b 30                	mov    (%eax),%esi
  8020da:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8020dd:	89 f0                	mov    %esi,%eax
  8020df:	c1 f8 1f             	sar    $0x1f,%eax
  8020e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8020e5:	eb 16                	jmp    8020fd <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8020e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8020ea:	8d 50 04             	lea    0x4(%eax),%edx
  8020ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8020f0:	8b 30                	mov    (%eax),%esi
  8020f2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8020f5:	89 f0                	mov    %esi,%eax
  8020f7:	c1 f8 1f             	sar    $0x1f,%eax
  8020fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8020fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802100:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  802103:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  802108:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80210c:	0f 89 80 00 00 00    	jns    802192 <vprintfmt+0x374>
				putch('-', putdat);
  802112:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802116:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80211d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  802120:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802123:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802126:	f7 d8                	neg    %eax
  802128:	83 d2 00             	adc    $0x0,%edx
  80212b:	f7 da                	neg    %edx
			}
			base = 10;
  80212d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  802132:	eb 5e                	jmp    802192 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  802134:	8d 45 14             	lea    0x14(%ebp),%eax
  802137:	e8 63 fc ff ff       	call   801d9f <getuint>
			base = 10;
  80213c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  802141:	eb 4f                	jmp    802192 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  802143:	8d 45 14             	lea    0x14(%ebp),%eax
  802146:	e8 54 fc ff ff       	call   801d9f <getuint>
			base = 8;
  80214b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  802150:	eb 40                	jmp    802192 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  802152:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802156:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80215d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  802160:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802164:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80216b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80216e:	8b 45 14             	mov    0x14(%ebp),%eax
  802171:	8d 50 04             	lea    0x4(%eax),%edx
  802174:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  802177:	8b 00                	mov    (%eax),%eax
  802179:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80217e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  802183:	eb 0d                	jmp    802192 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  802185:	8d 45 14             	lea    0x14(%ebp),%eax
  802188:	e8 12 fc ff ff       	call   801d9f <getuint>
			base = 16;
  80218d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  802192:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  802196:	89 74 24 10          	mov    %esi,0x10(%esp)
  80219a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80219d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8021a1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021a5:	89 04 24             	mov    %eax,(%esp)
  8021a8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021ac:	89 fa                	mov    %edi,%edx
  8021ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b1:	e8 fa fa ff ff       	call   801cb0 <printnum>
			break;
  8021b6:	e9 88 fc ff ff       	jmp    801e43 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8021bb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8021bf:	89 04 24             	mov    %eax,(%esp)
  8021c2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8021c5:	e9 79 fc ff ff       	jmp    801e43 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8021ca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8021ce:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8021d5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8021d8:	89 f3                	mov    %esi,%ebx
  8021da:	eb 03                	jmp    8021df <vprintfmt+0x3c1>
  8021dc:	83 eb 01             	sub    $0x1,%ebx
  8021df:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8021e3:	75 f7                	jne    8021dc <vprintfmt+0x3be>
  8021e5:	e9 59 fc ff ff       	jmp    801e43 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8021ea:	83 c4 3c             	add    $0x3c,%esp
  8021ed:	5b                   	pop    %ebx
  8021ee:	5e                   	pop    %esi
  8021ef:	5f                   	pop    %edi
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    

008021f2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8021f2:	55                   	push   %ebp
  8021f3:	89 e5                	mov    %esp,%ebp
  8021f5:	83 ec 28             	sub    $0x28,%esp
  8021f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021fb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8021fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802201:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  802205:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802208:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80220f:	85 c0                	test   %eax,%eax
  802211:	74 30                	je     802243 <vsnprintf+0x51>
  802213:	85 d2                	test   %edx,%edx
  802215:	7e 2c                	jle    802243 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  802217:	8b 45 14             	mov    0x14(%ebp),%eax
  80221a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80221e:	8b 45 10             	mov    0x10(%ebp),%eax
  802221:	89 44 24 08          	mov    %eax,0x8(%esp)
  802225:	8d 45 ec             	lea    -0x14(%ebp),%eax
  802228:	89 44 24 04          	mov    %eax,0x4(%esp)
  80222c:	c7 04 24 d9 1d 80 00 	movl   $0x801dd9,(%esp)
  802233:	e8 e6 fb ff ff       	call   801e1e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  802238:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80223b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80223e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802241:	eb 05                	jmp    802248 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  802243:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  802248:	c9                   	leave  
  802249:	c3                   	ret    

0080224a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80224a:	55                   	push   %ebp
  80224b:	89 e5                	mov    %esp,%ebp
  80224d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  802250:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  802253:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802257:	8b 45 10             	mov    0x10(%ebp),%eax
  80225a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80225e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802261:	89 44 24 04          	mov    %eax,0x4(%esp)
  802265:	8b 45 08             	mov    0x8(%ebp),%eax
  802268:	89 04 24             	mov    %eax,(%esp)
  80226b:	e8 82 ff ff ff       	call   8021f2 <vsnprintf>
	va_end(ap);

	return rc;
}
  802270:	c9                   	leave  
  802271:	c3                   	ret    
  802272:	66 90                	xchg   %ax,%ax
  802274:	66 90                	xchg   %ax,%ax
  802276:	66 90                	xchg   %ax,%ax
  802278:	66 90                	xchg   %ax,%ax
  80227a:	66 90                	xchg   %ax,%ax
  80227c:	66 90                	xchg   %ax,%ax
  80227e:	66 90                	xchg   %ax,%ax

00802280 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802280:	55                   	push   %ebp
  802281:	89 e5                	mov    %esp,%ebp
  802283:	56                   	push   %esi
  802284:	53                   	push   %ebx
  802285:	83 ec 10             	sub    $0x10,%esp
  802288:	8b 75 08             	mov    0x8(%ebp),%esi
  80228b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80228e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  802291:	85 c0                	test   %eax,%eax
  802293:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802298:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  80229b:	89 04 24             	mov    %eax,(%esp)
  80229e:	e8 26 e5 ff ff       	call   8007c9 <sys_ipc_recv>

	if(ret < 0) {
  8022a3:	85 c0                	test   %eax,%eax
  8022a5:	79 16                	jns    8022bd <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  8022a7:	85 f6                	test   %esi,%esi
  8022a9:	74 06                	je     8022b1 <ipc_recv+0x31>
  8022ab:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  8022b1:	85 db                	test   %ebx,%ebx
  8022b3:	74 3e                	je     8022f3 <ipc_recv+0x73>
  8022b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8022bb:	eb 36                	jmp    8022f3 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  8022bd:	e8 b3 e2 ff ff       	call   800575 <sys_getenvid>
  8022c2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8022c7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022ca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8022cf:	a3 08 40 80 00       	mov    %eax,0x804008

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8022d4:	85 f6                	test   %esi,%esi
  8022d6:	74 05                	je     8022dd <ipc_recv+0x5d>
  8022d8:	8b 40 74             	mov    0x74(%eax),%eax
  8022db:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8022dd:	85 db                	test   %ebx,%ebx
  8022df:	74 0a                	je     8022eb <ipc_recv+0x6b>
  8022e1:	a1 08 40 80 00       	mov    0x804008,%eax
  8022e6:	8b 40 78             	mov    0x78(%eax),%eax
  8022e9:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  8022eb:	a1 08 40 80 00       	mov    0x804008,%eax
  8022f0:	8b 40 70             	mov    0x70(%eax),%eax
}
  8022f3:	83 c4 10             	add    $0x10,%esp
  8022f6:	5b                   	pop    %ebx
  8022f7:	5e                   	pop    %esi
  8022f8:	5d                   	pop    %ebp
  8022f9:	c3                   	ret    

008022fa <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022fa:	55                   	push   %ebp
  8022fb:	89 e5                	mov    %esp,%ebp
  8022fd:	57                   	push   %edi
  8022fe:	56                   	push   %esi
  8022ff:	53                   	push   %ebx
  802300:	83 ec 1c             	sub    $0x1c,%esp
  802303:	8b 7d 08             	mov    0x8(%ebp),%edi
  802306:	8b 75 0c             	mov    0xc(%ebp),%esi
  802309:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  80230c:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  80230e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802313:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  802316:	8b 45 14             	mov    0x14(%ebp),%eax
  802319:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80231d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802321:	89 74 24 04          	mov    %esi,0x4(%esp)
  802325:	89 3c 24             	mov    %edi,(%esp)
  802328:	e8 79 e4 ff ff       	call   8007a6 <sys_ipc_try_send>

		if(ret >= 0) break;
  80232d:	85 c0                	test   %eax,%eax
  80232f:	79 2c                	jns    80235d <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  802331:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802334:	74 20                	je     802356 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  802336:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80233a:	c7 44 24 08 00 2b 80 	movl   $0x802b00,0x8(%esp)
  802341:	00 
  802342:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  802349:	00 
  80234a:	c7 04 24 30 2b 80 00 	movl   $0x802b30,(%esp)
  802351:	e8 40 f8 ff ff       	call   801b96 <_panic>
		}
		sys_yield();
  802356:	e8 39 e2 ff ff       	call   800594 <sys_yield>
	}
  80235b:	eb b9                	jmp    802316 <ipc_send+0x1c>
}
  80235d:	83 c4 1c             	add    $0x1c,%esp
  802360:	5b                   	pop    %ebx
  802361:	5e                   	pop    %esi
  802362:	5f                   	pop    %edi
  802363:	5d                   	pop    %ebp
  802364:	c3                   	ret    

00802365 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802365:	55                   	push   %ebp
  802366:	89 e5                	mov    %esp,%ebp
  802368:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80236b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802370:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802373:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802379:	8b 52 50             	mov    0x50(%edx),%edx
  80237c:	39 ca                	cmp    %ecx,%edx
  80237e:	75 0d                	jne    80238d <ipc_find_env+0x28>
			return envs[i].env_id;
  802380:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802383:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802388:	8b 40 40             	mov    0x40(%eax),%eax
  80238b:	eb 0e                	jmp    80239b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80238d:	83 c0 01             	add    $0x1,%eax
  802390:	3d 00 04 00 00       	cmp    $0x400,%eax
  802395:	75 d9                	jne    802370 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802397:	66 b8 00 00          	mov    $0x0,%ax
}
  80239b:	5d                   	pop    %ebp
  80239c:	c3                   	ret    

0080239d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80239d:	55                   	push   %ebp
  80239e:	89 e5                	mov    %esp,%ebp
  8023a0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023a3:	89 d0                	mov    %edx,%eax
  8023a5:	c1 e8 16             	shr    $0x16,%eax
  8023a8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023af:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023b4:	f6 c1 01             	test   $0x1,%cl
  8023b7:	74 1d                	je     8023d6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023b9:	c1 ea 0c             	shr    $0xc,%edx
  8023bc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023c3:	f6 c2 01             	test   $0x1,%dl
  8023c6:	74 0e                	je     8023d6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023c8:	c1 ea 0c             	shr    $0xc,%edx
  8023cb:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023d2:	ef 
  8023d3:	0f b7 c0             	movzwl %ax,%eax
}
  8023d6:	5d                   	pop    %ebp
  8023d7:	c3                   	ret    
  8023d8:	66 90                	xchg   %ax,%ax
  8023da:	66 90                	xchg   %ax,%ax
  8023dc:	66 90                	xchg   %ax,%ax
  8023de:	66 90                	xchg   %ax,%ax

008023e0 <__udivdi3>:
  8023e0:	55                   	push   %ebp
  8023e1:	57                   	push   %edi
  8023e2:	56                   	push   %esi
  8023e3:	83 ec 0c             	sub    $0xc,%esp
  8023e6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8023ea:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8023ee:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8023f2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8023f6:	85 c0                	test   %eax,%eax
  8023f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8023fc:	89 ea                	mov    %ebp,%edx
  8023fe:	89 0c 24             	mov    %ecx,(%esp)
  802401:	75 2d                	jne    802430 <__udivdi3+0x50>
  802403:	39 e9                	cmp    %ebp,%ecx
  802405:	77 61                	ja     802468 <__udivdi3+0x88>
  802407:	85 c9                	test   %ecx,%ecx
  802409:	89 ce                	mov    %ecx,%esi
  80240b:	75 0b                	jne    802418 <__udivdi3+0x38>
  80240d:	b8 01 00 00 00       	mov    $0x1,%eax
  802412:	31 d2                	xor    %edx,%edx
  802414:	f7 f1                	div    %ecx
  802416:	89 c6                	mov    %eax,%esi
  802418:	31 d2                	xor    %edx,%edx
  80241a:	89 e8                	mov    %ebp,%eax
  80241c:	f7 f6                	div    %esi
  80241e:	89 c5                	mov    %eax,%ebp
  802420:	89 f8                	mov    %edi,%eax
  802422:	f7 f6                	div    %esi
  802424:	89 ea                	mov    %ebp,%edx
  802426:	83 c4 0c             	add    $0xc,%esp
  802429:	5e                   	pop    %esi
  80242a:	5f                   	pop    %edi
  80242b:	5d                   	pop    %ebp
  80242c:	c3                   	ret    
  80242d:	8d 76 00             	lea    0x0(%esi),%esi
  802430:	39 e8                	cmp    %ebp,%eax
  802432:	77 24                	ja     802458 <__udivdi3+0x78>
  802434:	0f bd e8             	bsr    %eax,%ebp
  802437:	83 f5 1f             	xor    $0x1f,%ebp
  80243a:	75 3c                	jne    802478 <__udivdi3+0x98>
  80243c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802440:	39 34 24             	cmp    %esi,(%esp)
  802443:	0f 86 9f 00 00 00    	jbe    8024e8 <__udivdi3+0x108>
  802449:	39 d0                	cmp    %edx,%eax
  80244b:	0f 82 97 00 00 00    	jb     8024e8 <__udivdi3+0x108>
  802451:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802458:	31 d2                	xor    %edx,%edx
  80245a:	31 c0                	xor    %eax,%eax
  80245c:	83 c4 0c             	add    $0xc,%esp
  80245f:	5e                   	pop    %esi
  802460:	5f                   	pop    %edi
  802461:	5d                   	pop    %ebp
  802462:	c3                   	ret    
  802463:	90                   	nop
  802464:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802468:	89 f8                	mov    %edi,%eax
  80246a:	f7 f1                	div    %ecx
  80246c:	31 d2                	xor    %edx,%edx
  80246e:	83 c4 0c             	add    $0xc,%esp
  802471:	5e                   	pop    %esi
  802472:	5f                   	pop    %edi
  802473:	5d                   	pop    %ebp
  802474:	c3                   	ret    
  802475:	8d 76 00             	lea    0x0(%esi),%esi
  802478:	89 e9                	mov    %ebp,%ecx
  80247a:	8b 3c 24             	mov    (%esp),%edi
  80247d:	d3 e0                	shl    %cl,%eax
  80247f:	89 c6                	mov    %eax,%esi
  802481:	b8 20 00 00 00       	mov    $0x20,%eax
  802486:	29 e8                	sub    %ebp,%eax
  802488:	89 c1                	mov    %eax,%ecx
  80248a:	d3 ef                	shr    %cl,%edi
  80248c:	89 e9                	mov    %ebp,%ecx
  80248e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802492:	8b 3c 24             	mov    (%esp),%edi
  802495:	09 74 24 08          	or     %esi,0x8(%esp)
  802499:	89 d6                	mov    %edx,%esi
  80249b:	d3 e7                	shl    %cl,%edi
  80249d:	89 c1                	mov    %eax,%ecx
  80249f:	89 3c 24             	mov    %edi,(%esp)
  8024a2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8024a6:	d3 ee                	shr    %cl,%esi
  8024a8:	89 e9                	mov    %ebp,%ecx
  8024aa:	d3 e2                	shl    %cl,%edx
  8024ac:	89 c1                	mov    %eax,%ecx
  8024ae:	d3 ef                	shr    %cl,%edi
  8024b0:	09 d7                	or     %edx,%edi
  8024b2:	89 f2                	mov    %esi,%edx
  8024b4:	89 f8                	mov    %edi,%eax
  8024b6:	f7 74 24 08          	divl   0x8(%esp)
  8024ba:	89 d6                	mov    %edx,%esi
  8024bc:	89 c7                	mov    %eax,%edi
  8024be:	f7 24 24             	mull   (%esp)
  8024c1:	39 d6                	cmp    %edx,%esi
  8024c3:	89 14 24             	mov    %edx,(%esp)
  8024c6:	72 30                	jb     8024f8 <__udivdi3+0x118>
  8024c8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024cc:	89 e9                	mov    %ebp,%ecx
  8024ce:	d3 e2                	shl    %cl,%edx
  8024d0:	39 c2                	cmp    %eax,%edx
  8024d2:	73 05                	jae    8024d9 <__udivdi3+0xf9>
  8024d4:	3b 34 24             	cmp    (%esp),%esi
  8024d7:	74 1f                	je     8024f8 <__udivdi3+0x118>
  8024d9:	89 f8                	mov    %edi,%eax
  8024db:	31 d2                	xor    %edx,%edx
  8024dd:	e9 7a ff ff ff       	jmp    80245c <__udivdi3+0x7c>
  8024e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024e8:	31 d2                	xor    %edx,%edx
  8024ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8024ef:	e9 68 ff ff ff       	jmp    80245c <__udivdi3+0x7c>
  8024f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024f8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8024fb:	31 d2                	xor    %edx,%edx
  8024fd:	83 c4 0c             	add    $0xc,%esp
  802500:	5e                   	pop    %esi
  802501:	5f                   	pop    %edi
  802502:	5d                   	pop    %ebp
  802503:	c3                   	ret    
  802504:	66 90                	xchg   %ax,%ax
  802506:	66 90                	xchg   %ax,%ax
  802508:	66 90                	xchg   %ax,%ax
  80250a:	66 90                	xchg   %ax,%ax
  80250c:	66 90                	xchg   %ax,%ax
  80250e:	66 90                	xchg   %ax,%ax

00802510 <__umoddi3>:
  802510:	55                   	push   %ebp
  802511:	57                   	push   %edi
  802512:	56                   	push   %esi
  802513:	83 ec 14             	sub    $0x14,%esp
  802516:	8b 44 24 28          	mov    0x28(%esp),%eax
  80251a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80251e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802522:	89 c7                	mov    %eax,%edi
  802524:	89 44 24 04          	mov    %eax,0x4(%esp)
  802528:	8b 44 24 30          	mov    0x30(%esp),%eax
  80252c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802530:	89 34 24             	mov    %esi,(%esp)
  802533:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802537:	85 c0                	test   %eax,%eax
  802539:	89 c2                	mov    %eax,%edx
  80253b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80253f:	75 17                	jne    802558 <__umoddi3+0x48>
  802541:	39 fe                	cmp    %edi,%esi
  802543:	76 4b                	jbe    802590 <__umoddi3+0x80>
  802545:	89 c8                	mov    %ecx,%eax
  802547:	89 fa                	mov    %edi,%edx
  802549:	f7 f6                	div    %esi
  80254b:	89 d0                	mov    %edx,%eax
  80254d:	31 d2                	xor    %edx,%edx
  80254f:	83 c4 14             	add    $0x14,%esp
  802552:	5e                   	pop    %esi
  802553:	5f                   	pop    %edi
  802554:	5d                   	pop    %ebp
  802555:	c3                   	ret    
  802556:	66 90                	xchg   %ax,%ax
  802558:	39 f8                	cmp    %edi,%eax
  80255a:	77 54                	ja     8025b0 <__umoddi3+0xa0>
  80255c:	0f bd e8             	bsr    %eax,%ebp
  80255f:	83 f5 1f             	xor    $0x1f,%ebp
  802562:	75 5c                	jne    8025c0 <__umoddi3+0xb0>
  802564:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802568:	39 3c 24             	cmp    %edi,(%esp)
  80256b:	0f 87 e7 00 00 00    	ja     802658 <__umoddi3+0x148>
  802571:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802575:	29 f1                	sub    %esi,%ecx
  802577:	19 c7                	sbb    %eax,%edi
  802579:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80257d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802581:	8b 44 24 08          	mov    0x8(%esp),%eax
  802585:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802589:	83 c4 14             	add    $0x14,%esp
  80258c:	5e                   	pop    %esi
  80258d:	5f                   	pop    %edi
  80258e:	5d                   	pop    %ebp
  80258f:	c3                   	ret    
  802590:	85 f6                	test   %esi,%esi
  802592:	89 f5                	mov    %esi,%ebp
  802594:	75 0b                	jne    8025a1 <__umoddi3+0x91>
  802596:	b8 01 00 00 00       	mov    $0x1,%eax
  80259b:	31 d2                	xor    %edx,%edx
  80259d:	f7 f6                	div    %esi
  80259f:	89 c5                	mov    %eax,%ebp
  8025a1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8025a5:	31 d2                	xor    %edx,%edx
  8025a7:	f7 f5                	div    %ebp
  8025a9:	89 c8                	mov    %ecx,%eax
  8025ab:	f7 f5                	div    %ebp
  8025ad:	eb 9c                	jmp    80254b <__umoddi3+0x3b>
  8025af:	90                   	nop
  8025b0:	89 c8                	mov    %ecx,%eax
  8025b2:	89 fa                	mov    %edi,%edx
  8025b4:	83 c4 14             	add    $0x14,%esp
  8025b7:	5e                   	pop    %esi
  8025b8:	5f                   	pop    %edi
  8025b9:	5d                   	pop    %ebp
  8025ba:	c3                   	ret    
  8025bb:	90                   	nop
  8025bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025c0:	8b 04 24             	mov    (%esp),%eax
  8025c3:	be 20 00 00 00       	mov    $0x20,%esi
  8025c8:	89 e9                	mov    %ebp,%ecx
  8025ca:	29 ee                	sub    %ebp,%esi
  8025cc:	d3 e2                	shl    %cl,%edx
  8025ce:	89 f1                	mov    %esi,%ecx
  8025d0:	d3 e8                	shr    %cl,%eax
  8025d2:	89 e9                	mov    %ebp,%ecx
  8025d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025d8:	8b 04 24             	mov    (%esp),%eax
  8025db:	09 54 24 04          	or     %edx,0x4(%esp)
  8025df:	89 fa                	mov    %edi,%edx
  8025e1:	d3 e0                	shl    %cl,%eax
  8025e3:	89 f1                	mov    %esi,%ecx
  8025e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025e9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8025ed:	d3 ea                	shr    %cl,%edx
  8025ef:	89 e9                	mov    %ebp,%ecx
  8025f1:	d3 e7                	shl    %cl,%edi
  8025f3:	89 f1                	mov    %esi,%ecx
  8025f5:	d3 e8                	shr    %cl,%eax
  8025f7:	89 e9                	mov    %ebp,%ecx
  8025f9:	09 f8                	or     %edi,%eax
  8025fb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8025ff:	f7 74 24 04          	divl   0x4(%esp)
  802603:	d3 e7                	shl    %cl,%edi
  802605:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802609:	89 d7                	mov    %edx,%edi
  80260b:	f7 64 24 08          	mull   0x8(%esp)
  80260f:	39 d7                	cmp    %edx,%edi
  802611:	89 c1                	mov    %eax,%ecx
  802613:	89 14 24             	mov    %edx,(%esp)
  802616:	72 2c                	jb     802644 <__umoddi3+0x134>
  802618:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80261c:	72 22                	jb     802640 <__umoddi3+0x130>
  80261e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802622:	29 c8                	sub    %ecx,%eax
  802624:	19 d7                	sbb    %edx,%edi
  802626:	89 e9                	mov    %ebp,%ecx
  802628:	89 fa                	mov    %edi,%edx
  80262a:	d3 e8                	shr    %cl,%eax
  80262c:	89 f1                	mov    %esi,%ecx
  80262e:	d3 e2                	shl    %cl,%edx
  802630:	89 e9                	mov    %ebp,%ecx
  802632:	d3 ef                	shr    %cl,%edi
  802634:	09 d0                	or     %edx,%eax
  802636:	89 fa                	mov    %edi,%edx
  802638:	83 c4 14             	add    $0x14,%esp
  80263b:	5e                   	pop    %esi
  80263c:	5f                   	pop    %edi
  80263d:	5d                   	pop    %ebp
  80263e:	c3                   	ret    
  80263f:	90                   	nop
  802640:	39 d7                	cmp    %edx,%edi
  802642:	75 da                	jne    80261e <__umoddi3+0x10e>
  802644:	8b 14 24             	mov    (%esp),%edx
  802647:	89 c1                	mov    %eax,%ecx
  802649:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80264d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802651:	eb cb                	jmp    80261e <__umoddi3+0x10e>
  802653:	90                   	nop
  802654:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802658:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80265c:	0f 82 0f ff ff ff    	jb     802571 <__umoddi3+0x61>
  802662:	e9 1a ff ff ff       	jmp    802581 <__umoddi3+0x71>
