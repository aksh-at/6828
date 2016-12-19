
obj/user/echotest.debug:     file format elf32-i386


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
  80002c:	e8 dc 04 00 00       	call   80050d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <die>:

const char *msg = "Hello world!\n";

static void
die(char *m)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	cprintf("%s\n", m);
  800039:	89 44 24 04          	mov    %eax,0x4(%esp)
  80003d:	c7 04 24 80 2a 80 00 	movl   $0x802a80,(%esp)
  800044:	e8 c8 05 00 00       	call   800611 <cprintf>
	exit();
  800049:	e8 07 05 00 00       	call   800555 <exit>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <umain>:

void umain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	57                   	push   %edi
  800054:	56                   	push   %esi
  800055:	53                   	push   %ebx
  800056:	83 ec 5c             	sub    $0x5c,%esp
	struct sockaddr_in echoserver;
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;

	cprintf("Connecting to:\n");
  800059:	c7 04 24 84 2a 80 00 	movl   $0x802a84,(%esp)
  800060:	e8 ac 05 00 00       	call   800611 <cprintf>
	cprintf("\tip address %s = %x\n", IPADDR, inet_addr(IPADDR));
  800065:	c7 04 24 94 2a 80 00 	movl   $0x802a94,(%esp)
  80006c:	e8 64 04 00 00       	call   8004d5 <inet_addr>
  800071:	89 44 24 08          	mov    %eax,0x8(%esp)
  800075:	c7 44 24 04 94 2a 80 	movl   $0x802a94,0x4(%esp)
  80007c:	00 
  80007d:	c7 04 24 9e 2a 80 00 	movl   $0x802a9e,(%esp)
  800084:	e8 88 05 00 00       	call   800611 <cprintf>

	// Create the TCP socket
	if ((sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  800089:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  800090:	00 
  800091:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800098:	00 
  800099:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8000a0:	e8 82 1d 00 00       	call   801e27 <socket>
  8000a5:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  8000a8:	85 c0                	test   %eax,%eax
  8000aa:	79 0a                	jns    8000b6 <umain+0x66>
		die("Failed to create socket");
  8000ac:	b8 b3 2a 80 00       	mov    $0x802ab3,%eax
  8000b1:	e8 7d ff ff ff       	call   800033 <die>

	cprintf("opened socket\n");
  8000b6:	c7 04 24 cb 2a 80 00 	movl   $0x802acb,(%esp)
  8000bd:	e8 4f 05 00 00       	call   800611 <cprintf>

	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  8000c2:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  8000c9:	00 
  8000ca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000d1:	00 
  8000d2:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  8000d5:	89 1c 24             	mov    %ebx,(%esp)
  8000d8:	e8 aa 0c 00 00       	call   800d87 <memset>
	echoserver.sin_family = AF_INET;                  // Internet/IP
  8000dd:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	echoserver.sin_addr.s_addr = inet_addr(IPADDR);   // IP address
  8000e1:	c7 04 24 94 2a 80 00 	movl   $0x802a94,(%esp)
  8000e8:	e8 e8 03 00 00       	call   8004d5 <inet_addr>
  8000ed:	89 45 dc             	mov    %eax,-0x24(%ebp)
	echoserver.sin_port = htons(PORT);		  // server port
  8000f0:	c7 04 24 10 27 00 00 	movl   $0x2710,(%esp)
  8000f7:	e8 aa 01 00 00       	call   8002a6 <htons>
  8000fc:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	cprintf("trying to connect to server\n");
  800100:	c7 04 24 da 2a 80 00 	movl   $0x802ada,(%esp)
  800107:	e8 05 05 00 00       	call   800611 <cprintf>

	// Establish connection
	if (connect(sock, (struct sockaddr *) &echoserver, sizeof(echoserver)) < 0)
  80010c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  800113:	00 
  800114:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800118:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  80011b:	89 04 24             	mov    %eax,(%esp)
  80011e:	e8 b3 1c 00 00       	call   801dd6 <connect>
  800123:	85 c0                	test   %eax,%eax
  800125:	79 0a                	jns    800131 <umain+0xe1>
		die("Failed to connect with server");
  800127:	b8 f7 2a 80 00       	mov    $0x802af7,%eax
  80012c:	e8 02 ff ff ff       	call   800033 <die>

	cprintf("connected to server\n");
  800131:	c7 04 24 15 2b 80 00 	movl   $0x802b15,(%esp)
  800138:	e8 d4 04 00 00       	call   800611 <cprintf>

	// Send the word to the server
	echolen = strlen(msg);
  80013d:	a1 00 40 80 00       	mov    0x804000,%eax
  800142:	89 04 24             	mov    %eax,(%esp)
  800145:	e8 b6 0a 00 00       	call   800c00 <strlen>
  80014a:	89 c7                	mov    %eax,%edi
  80014c:	89 45 b0             	mov    %eax,-0x50(%ebp)
	if (write(sock, msg, echolen) != echolen)
  80014f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800153:	a1 00 40 80 00       	mov    0x804000,%eax
  800158:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  80015f:	89 04 24             	mov    %eax,(%esp)
  800162:	e8 00 16 00 00       	call   801767 <write>
  800167:	39 f8                	cmp    %edi,%eax
  800169:	74 0a                	je     800175 <umain+0x125>
		die("Mismatch in number of sent bytes");
  80016b:	b8 44 2b 80 00       	mov    $0x802b44,%eax
  800170:	e8 be fe ff ff       	call   800033 <die>

	// Receive the word back from the server
	cprintf("Received: \n");
  800175:	c7 04 24 2a 2b 80 00 	movl   $0x802b2a,(%esp)
  80017c:	e8 90 04 00 00       	call   800611 <cprintf>
{
	int sock;
	struct sockaddr_in echoserver;
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;
  800181:	be 00 00 00 00       	mov    $0x0,%esi

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
		int bytes = 0;
		if ((bytes = read(sock, buffer, BUFFSIZE-1)) < 1) {
  800186:	8d 7d b8             	lea    -0x48(%ebp),%edi
	if (write(sock, msg, echolen) != echolen)
		die("Mismatch in number of sent bytes");

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
  800189:	eb 36                	jmp    8001c1 <umain+0x171>
		int bytes = 0;
		if ((bytes = read(sock, buffer, BUFFSIZE-1)) < 1) {
  80018b:	c7 44 24 08 1f 00 00 	movl   $0x1f,0x8(%esp)
  800192:	00 
  800193:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800197:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  80019a:	89 04 24             	mov    %eax,(%esp)
  80019d:	e8 e8 14 00 00       	call   80168a <read>
  8001a2:	89 c3                	mov    %eax,%ebx
  8001a4:	85 c0                	test   %eax,%eax
  8001a6:	7f 0a                	jg     8001b2 <umain+0x162>
			die("Failed to receive bytes from server");
  8001a8:	b8 68 2b 80 00       	mov    $0x802b68,%eax
  8001ad:	e8 81 fe ff ff       	call   800033 <die>
		}
		received += bytes;
  8001b2:	01 de                	add    %ebx,%esi
		buffer[bytes] = '\0';        // Assure null terminated string
  8001b4:	c6 44 1d b8 00       	movb   $0x0,-0x48(%ebp,%ebx,1)
		cprintf(buffer);
  8001b9:	89 3c 24             	mov    %edi,(%esp)
  8001bc:	e8 50 04 00 00       	call   800611 <cprintf>
	if (write(sock, msg, echolen) != echolen)
		die("Mismatch in number of sent bytes");

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
  8001c1:	39 75 b0             	cmp    %esi,-0x50(%ebp)
  8001c4:	77 c5                	ja     80018b <umain+0x13b>
		}
		received += bytes;
		buffer[bytes] = '\0';        // Assure null terminated string
		cprintf(buffer);
	}
	cprintf("\n");
  8001c6:	c7 04 24 34 2b 80 00 	movl   $0x802b34,(%esp)
  8001cd:	e8 3f 04 00 00       	call   800611 <cprintf>

	close(sock);
  8001d2:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  8001d5:	89 04 24             	mov    %eax,(%esp)
  8001d8:	e8 4a 13 00 00       	call   801527 <close>
}
  8001dd:	83 c4 5c             	add    $0x5c,%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5f                   	pop    %edi
  8001e3:	5d                   	pop    %ebp
  8001e4:	c3                   	ret    
  8001e5:	66 90                	xchg   %ax,%ax
  8001e7:	66 90                	xchg   %ax,%ax
  8001e9:	66 90                	xchg   %ax,%ax
  8001eb:	66 90                	xchg   %ax,%ax
  8001ed:	66 90                	xchg   %ax,%ax
  8001ef:	90                   	nop

008001f0 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	57                   	push   %edi
  8001f4:	56                   	push   %esi
  8001f5:	53                   	push   %ebx
  8001f6:	83 ec 19             	sub    $0x19,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8001f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  8001ff:	c6 45 db 00          	movb   $0x0,-0x25(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  800203:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  800206:	c7 45 dc 00 50 80 00 	movl   $0x805000,-0x24(%ebp)
 */
char *
inet_ntoa(struct in_addr addr)
{
  static char str[16];
  u32_t s_addr = addr.s_addr;
  80020d:	be 00 00 00 00       	mov    $0x0,%esi
  800212:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  800215:	eb 02                	jmp    800219 <inet_ntoa+0x29>
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
  800217:	89 ce                	mov    %ecx,%esi
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  800219:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80021c:	0f b6 17             	movzbl (%edi),%edx
      *ap /= (u8_t)10;
  80021f:	0f b6 c2             	movzbl %dl,%eax
  800222:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
  800225:	8d 04 c8             	lea    (%eax,%ecx,8),%eax
  800228:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80022b:	66 c1 e8 0b          	shr    $0xb,%ax
  80022f:	88 07                	mov    %al,(%edi)
      inv[i++] = '0' + rem;
  800231:	8d 4e 01             	lea    0x1(%esi),%ecx
  800234:	89 f3                	mov    %esi,%ebx
  800236:	0f b6 f3             	movzbl %bl,%esi
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  800239:	8d 3c 80             	lea    (%eax,%eax,4),%edi
  80023c:	01 ff                	add    %edi,%edi
  80023e:	89 fb                	mov    %edi,%ebx
  800240:	29 da                	sub    %ebx,%edx
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
  800242:	83 c2 30             	add    $0x30,%edx
  800245:	88 54 35 ed          	mov    %dl,-0x13(%ebp,%esi,1)
    } while(*ap);
  800249:	84 c0                	test   %al,%al
  80024b:	75 ca                	jne    800217 <inet_ntoa+0x27>
  80024d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800250:	89 c8                	mov    %ecx,%eax
  800252:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800255:	89 cf                	mov    %ecx,%edi
  800257:	eb 0d                	jmp    800266 <inet_ntoa+0x76>
    while(i--)
      *rp++ = inv[i];
  800259:	0f b6 f0             	movzbl %al,%esi
  80025c:	0f b6 4c 35 ed       	movzbl -0x13(%ebp,%esi,1),%ecx
  800261:	88 0a                	mov    %cl,(%edx)
  800263:	83 c2 01             	add    $0x1,%edx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  800266:	83 e8 01             	sub    $0x1,%eax
  800269:	3c ff                	cmp    $0xff,%al
  80026b:	75 ec                	jne    800259 <inet_ntoa+0x69>
  80026d:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  800270:	89 f9                	mov    %edi,%ecx
  800272:	0f b6 c9             	movzbl %cl,%ecx
  800275:	03 4d dc             	add    -0x24(%ebp),%ecx
      *rp++ = inv[i];
    *rp++ = '.';
  800278:	8d 41 01             	lea    0x1(%ecx),%eax
  80027b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    ap++;
  80027e:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  800282:	80 45 db 01          	addb   $0x1,-0x25(%ebp)
  800286:	80 7d db 03          	cmpb   $0x3,-0x25(%ebp)
  80028a:	77 0a                	ja     800296 <inet_ntoa+0xa6>
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
  80028c:	c6 01 2e             	movb   $0x2e,(%ecx)
  80028f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800294:	eb 81                	jmp    800217 <inet_ntoa+0x27>
    ap++;
  }
  *--rp = 0;
  800296:	c6 01 00             	movb   $0x0,(%ecx)
  return str;
}
  800299:	b8 00 50 80 00       	mov    $0x805000,%eax
  80029e:	83 c4 19             	add    $0x19,%esp
  8002a1:	5b                   	pop    %ebx
  8002a2:	5e                   	pop    %esi
  8002a3:	5f                   	pop    %edi
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  8002a9:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8002ad:	66 c1 c0 08          	rol    $0x8,%ax
}
  8002b1:	5d                   	pop    %ebp
  8002b2:	c3                   	ret    

008002b3 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  8002b6:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8002ba:	66 c1 c0 08          	rol    $0x8,%ax
 */
u16_t
ntohs(u16_t n)
{
  return htons(n);
}
  8002be:	5d                   	pop    %ebp
  8002bf:	c3                   	ret    

008002c0 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
  8002c6:	89 d1                	mov    %edx,%ecx
  8002c8:	c1 e9 18             	shr    $0x18,%ecx
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  return ((n & 0xff) << 24) |
  8002cb:	89 d0                	mov    %edx,%eax
  8002cd:	c1 e0 18             	shl    $0x18,%eax
  8002d0:	09 c8                	or     %ecx,%eax
    ((n & 0xff00) << 8) |
  8002d2:	89 d1                	mov    %edx,%ecx
  8002d4:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  8002da:	c1 e1 08             	shl    $0x8,%ecx
  8002dd:	09 c8                	or     %ecx,%eax
    ((n & 0xff0000UL) >> 8) |
  8002df:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  8002e5:	c1 ea 08             	shr    $0x8,%edx
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  return ((n & 0xff) << 24) |
  8002e8:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  8002ea:	5d                   	pop    %ebp
  8002eb:	c3                   	ret    

008002ec <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
  8002ef:	57                   	push   %edi
  8002f0:	56                   	push   %esi
  8002f1:	53                   	push   %ebx
  8002f2:	83 ec 20             	sub    $0x20,%esp
  8002f5:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  8002f8:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  8002fb:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8002fe:	89 75 d8             	mov    %esi,-0x28(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  800301:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800304:	80 f9 09             	cmp    $0x9,%cl
  800307:	0f 87 a6 01 00 00    	ja     8004b3 <inet_aton+0x1c7>
      return (0);
    val = 0;
    base = 10;
  80030d:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
    if (c == '0') {
  800314:	83 fa 30             	cmp    $0x30,%edx
  800317:	75 2b                	jne    800344 <inet_aton+0x58>
      c = *++cp;
  800319:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  80031d:	89 d1                	mov    %edx,%ecx
  80031f:	83 e1 df             	and    $0xffffffdf,%ecx
  800322:	80 f9 58             	cmp    $0x58,%cl
  800325:	74 0f                	je     800336 <inet_aton+0x4a>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  800327:	83 c0 01             	add    $0x1,%eax
  80032a:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  80032d:	c7 45 e0 08 00 00 00 	movl   $0x8,-0x20(%ebp)
  800334:	eb 0e                	jmp    800344 <inet_aton+0x58>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  800336:	0f be 50 02          	movsbl 0x2(%eax),%edx
  80033a:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  80033d:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  800344:	83 c0 01             	add    $0x1,%eax
  800347:	bf 00 00 00 00       	mov    $0x0,%edi
  80034c:	eb 03                	jmp    800351 <inet_aton+0x65>
  80034e:	83 c0 01             	add    $0x1,%eax
  800351:	8d 70 ff             	lea    -0x1(%eax),%esi
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  800354:	89 d3                	mov    %edx,%ebx
  800356:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800359:	80 f9 09             	cmp    $0x9,%cl
  80035c:	77 0d                	ja     80036b <inet_aton+0x7f>
        val = (val * base) + (int)(c - '0');
  80035e:	0f af 7d e0          	imul   -0x20(%ebp),%edi
  800362:	8d 7c 3a d0          	lea    -0x30(%edx,%edi,1),%edi
        c = *++cp;
  800366:	0f be 10             	movsbl (%eax),%edx
  800369:	eb e3                	jmp    80034e <inet_aton+0x62>
      } else if (base == 16 && isxdigit(c)) {
  80036b:	83 7d e0 10          	cmpl   $0x10,-0x20(%ebp)
  80036f:	75 30                	jne    8003a1 <inet_aton+0xb5>
  800371:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
  800374:	88 4d df             	mov    %cl,-0x21(%ebp)
  800377:	89 d1                	mov    %edx,%ecx
  800379:	83 e1 df             	and    $0xffffffdf,%ecx
  80037c:	83 e9 41             	sub    $0x41,%ecx
  80037f:	80 f9 05             	cmp    $0x5,%cl
  800382:	77 23                	ja     8003a7 <inet_aton+0xbb>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  800384:	89 fb                	mov    %edi,%ebx
  800386:	c1 e3 04             	shl    $0x4,%ebx
  800389:	8d 7a 0a             	lea    0xa(%edx),%edi
  80038c:	80 7d df 1a          	cmpb   $0x1a,-0x21(%ebp)
  800390:	19 c9                	sbb    %ecx,%ecx
  800392:	83 e1 20             	and    $0x20,%ecx
  800395:	83 c1 41             	add    $0x41,%ecx
  800398:	29 cf                	sub    %ecx,%edi
  80039a:	09 df                	or     %ebx,%edi
        c = *++cp;
  80039c:	0f be 10             	movsbl (%eax),%edx
  80039f:	eb ad                	jmp    80034e <inet_aton+0x62>
  8003a1:	89 d0                	mov    %edx,%eax
  8003a3:	89 f9                	mov    %edi,%ecx
  8003a5:	eb 04                	jmp    8003ab <inet_aton+0xbf>
  8003a7:	89 d0                	mov    %edx,%eax
  8003a9:	89 f9                	mov    %edi,%ecx
      } else
        break;
    }
    if (c == '.') {
  8003ab:	83 f8 2e             	cmp    $0x2e,%eax
  8003ae:	75 22                	jne    8003d2 <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  8003b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8003b3:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  8003b6:	0f 84 fe 00 00 00    	je     8004ba <inet_aton+0x1ce>
        return (0);
      *pp++ = val;
  8003bc:	83 45 d8 04          	addl   $0x4,-0x28(%ebp)
  8003c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003c3:	89 48 fc             	mov    %ecx,-0x4(%eax)
      c = *++cp;
  8003c6:	8d 46 01             	lea    0x1(%esi),%eax
  8003c9:	0f be 56 01          	movsbl 0x1(%esi),%edx
    } else
      break;
  }
  8003cd:	e9 2f ff ff ff       	jmp    800301 <inet_aton+0x15>
  8003d2:	89 f9                	mov    %edi,%ecx
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8003d4:	85 d2                	test   %edx,%edx
  8003d6:	74 27                	je     8003ff <inet_aton+0x113>
    return (0);
  8003d8:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8003dd:	80 fb 1f             	cmp    $0x1f,%bl
  8003e0:	0f 86 e7 00 00 00    	jbe    8004cd <inet_aton+0x1e1>
  8003e6:	84 d2                	test   %dl,%dl
  8003e8:	0f 88 d3 00 00 00    	js     8004c1 <inet_aton+0x1d5>
  8003ee:	83 fa 20             	cmp    $0x20,%edx
  8003f1:	74 0c                	je     8003ff <inet_aton+0x113>
  8003f3:	83 ea 09             	sub    $0x9,%edx
  8003f6:	83 fa 04             	cmp    $0x4,%edx
  8003f9:	0f 87 ce 00 00 00    	ja     8004cd <inet_aton+0x1e1>
    return (0);
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  8003ff:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800402:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800405:	29 c2                	sub    %eax,%edx
  800407:	c1 fa 02             	sar    $0x2,%edx
  80040a:	83 c2 01             	add    $0x1,%edx
  switch (n) {
  80040d:	83 fa 02             	cmp    $0x2,%edx
  800410:	74 22                	je     800434 <inet_aton+0x148>
  800412:	83 fa 02             	cmp    $0x2,%edx
  800415:	7f 0f                	jg     800426 <inet_aton+0x13a>

  case 0:
    return (0);       /* initial nondigit */
  800417:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  80041c:	85 d2                	test   %edx,%edx
  80041e:	0f 84 a9 00 00 00    	je     8004cd <inet_aton+0x1e1>
  800424:	eb 73                	jmp    800499 <inet_aton+0x1ad>
  800426:	83 fa 03             	cmp    $0x3,%edx
  800429:	74 26                	je     800451 <inet_aton+0x165>
  80042b:	83 fa 04             	cmp    $0x4,%edx
  80042e:	66 90                	xchg   %ax,%ax
  800430:	74 40                	je     800472 <inet_aton+0x186>
  800432:	eb 65                	jmp    800499 <inet_aton+0x1ad>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  800434:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  800439:	81 f9 ff ff ff 00    	cmp    $0xffffff,%ecx
  80043f:	0f 87 88 00 00 00    	ja     8004cd <inet_aton+0x1e1>
      return (0);
    val |= parts[0] << 24;
  800445:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800448:	c1 e0 18             	shl    $0x18,%eax
  80044b:	89 cf                	mov    %ecx,%edi
  80044d:	09 c7                	or     %eax,%edi
    break;
  80044f:	eb 48                	jmp    800499 <inet_aton+0x1ad>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  800451:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  800456:	81 f9 ff ff 00 00    	cmp    $0xffff,%ecx
  80045c:	77 6f                	ja     8004cd <inet_aton+0x1e1>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  80045e:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800461:	c1 e2 10             	shl    $0x10,%edx
  800464:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800467:	c1 e0 18             	shl    $0x18,%eax
  80046a:	09 d0                	or     %edx,%eax
  80046c:	09 c8                	or     %ecx,%eax
  80046e:	89 c7                	mov    %eax,%edi
    break;
  800470:	eb 27                	jmp    800499 <inet_aton+0x1ad>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  800472:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  800477:	81 f9 ff 00 00 00    	cmp    $0xff,%ecx
  80047d:	77 4e                	ja     8004cd <inet_aton+0x1e1>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  80047f:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800482:	c1 e2 10             	shl    $0x10,%edx
  800485:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800488:	c1 e0 18             	shl    $0x18,%eax
  80048b:	09 c2                	or     %eax,%edx
  80048d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800490:	c1 e0 08             	shl    $0x8,%eax
  800493:	09 d0                	or     %edx,%eax
  800495:	09 c8                	or     %ecx,%eax
  800497:	89 c7                	mov    %eax,%edi
    break;
  }
  if (addr)
  800499:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80049d:	74 29                	je     8004c8 <inet_aton+0x1dc>
    addr->s_addr = htonl(val);
  80049f:	89 3c 24             	mov    %edi,(%esp)
  8004a2:	e8 19 fe ff ff       	call   8002c0 <htonl>
  8004a7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004aa:	89 06                	mov    %eax,(%esi)
  return (1);
  8004ac:	b8 01 00 00 00       	mov    $0x1,%eax
  8004b1:	eb 1a                	jmp    8004cd <inet_aton+0x1e1>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  8004b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b8:	eb 13                	jmp    8004cd <inet_aton+0x1e1>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  8004ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bf:	eb 0c                	jmp    8004cd <inet_aton+0x1e1>
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
    return (0);
  8004c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c6:	eb 05                	jmp    8004cd <inet_aton+0x1e1>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  8004c8:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8004cd:	83 c4 20             	add    $0x20,%esp
  8004d0:	5b                   	pop    %ebx
  8004d1:	5e                   	pop    %esi
  8004d2:	5f                   	pop    %edi
  8004d3:	5d                   	pop    %ebp
  8004d4:	c3                   	ret    

008004d5 <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  8004d5:	55                   	push   %ebp
  8004d6:	89 e5                	mov    %esp,%ebp
  8004d8:	83 ec 18             	sub    $0x18,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  8004db:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8004de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e5:	89 04 24             	mov    %eax,(%esp)
  8004e8:	e8 ff fd ff ff       	call   8002ec <inet_aton>
  8004ed:	85 c0                	test   %eax,%eax
    return (val.s_addr);
  8004ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8004f4:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  8004f8:	c9                   	leave  
  8004f9:	c3                   	ret    

008004fa <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  8004fa:	55                   	push   %ebp
  8004fb:	89 e5                	mov    %esp,%ebp
  8004fd:	83 ec 04             	sub    $0x4,%esp
  return htonl(n);
  800500:	8b 45 08             	mov    0x8(%ebp),%eax
  800503:	89 04 24             	mov    %eax,(%esp)
  800506:	e8 b5 fd ff ff       	call   8002c0 <htonl>
}
  80050b:	c9                   	leave  
  80050c:	c3                   	ret    

0080050d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80050d:	55                   	push   %ebp
  80050e:	89 e5                	mov    %esp,%ebp
  800510:	56                   	push   %esi
  800511:	53                   	push   %ebx
  800512:	83 ec 10             	sub    $0x10,%esp
  800515:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800518:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  80051b:	e8 f5 0a 00 00       	call   801015 <sys_getenvid>
  800520:	25 ff 03 00 00       	and    $0x3ff,%eax
  800525:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800528:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80052d:	a3 18 50 80 00       	mov    %eax,0x805018

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800532:	85 db                	test   %ebx,%ebx
  800534:	7e 07                	jle    80053d <libmain+0x30>
		binaryname = argv[0];
  800536:	8b 06                	mov    (%esi),%eax
  800538:	a3 04 40 80 00       	mov    %eax,0x804004

	// call user main routine
	umain(argc, argv);
  80053d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800541:	89 1c 24             	mov    %ebx,(%esp)
  800544:	e8 07 fb ff ff       	call   800050 <umain>

	// exit gracefully
	exit();
  800549:	e8 07 00 00 00       	call   800555 <exit>
}
  80054e:	83 c4 10             	add    $0x10,%esp
  800551:	5b                   	pop    %ebx
  800552:	5e                   	pop    %esi
  800553:	5d                   	pop    %ebp
  800554:	c3                   	ret    

00800555 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800555:	55                   	push   %ebp
  800556:	89 e5                	mov    %esp,%ebp
  800558:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80055b:	e8 fa 0f 00 00       	call   80155a <close_all>
	sys_env_destroy(0);
  800560:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800567:	e8 57 0a 00 00       	call   800fc3 <sys_env_destroy>
}
  80056c:	c9                   	leave  
  80056d:	c3                   	ret    

0080056e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80056e:	55                   	push   %ebp
  80056f:	89 e5                	mov    %esp,%ebp
  800571:	53                   	push   %ebx
  800572:	83 ec 14             	sub    $0x14,%esp
  800575:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800578:	8b 13                	mov    (%ebx),%edx
  80057a:	8d 42 01             	lea    0x1(%edx),%eax
  80057d:	89 03                	mov    %eax,(%ebx)
  80057f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800582:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800586:	3d ff 00 00 00       	cmp    $0xff,%eax
  80058b:	75 19                	jne    8005a6 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80058d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800594:	00 
  800595:	8d 43 08             	lea    0x8(%ebx),%eax
  800598:	89 04 24             	mov    %eax,(%esp)
  80059b:	e8 e6 09 00 00       	call   800f86 <sys_cputs>
		b->idx = 0;
  8005a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8005a6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8005aa:	83 c4 14             	add    $0x14,%esp
  8005ad:	5b                   	pop    %ebx
  8005ae:	5d                   	pop    %ebp
  8005af:	c3                   	ret    

008005b0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8005b0:	55                   	push   %ebp
  8005b1:	89 e5                	mov    %esp,%ebp
  8005b3:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8005b9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8005c0:	00 00 00 
	b.cnt = 0;
  8005c3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8005ca:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8005cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005db:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e5:	c7 04 24 6e 05 80 00 	movl   $0x80056e,(%esp)
  8005ec:	e8 ad 01 00 00       	call   80079e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005f1:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8005f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800601:	89 04 24             	mov    %eax,(%esp)
  800604:	e8 7d 09 00 00       	call   800f86 <sys_cputs>

	return b.cnt;
}
  800609:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80060f:	c9                   	leave  
  800610:	c3                   	ret    

00800611 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800611:	55                   	push   %ebp
  800612:	89 e5                	mov    %esp,%ebp
  800614:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800617:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80061a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061e:	8b 45 08             	mov    0x8(%ebp),%eax
  800621:	89 04 24             	mov    %eax,(%esp)
  800624:	e8 87 ff ff ff       	call   8005b0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800629:	c9                   	leave  
  80062a:	c3                   	ret    
  80062b:	66 90                	xchg   %ax,%ax
  80062d:	66 90                	xchg   %ax,%ax
  80062f:	90                   	nop

00800630 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800630:	55                   	push   %ebp
  800631:	89 e5                	mov    %esp,%ebp
  800633:	57                   	push   %edi
  800634:	56                   	push   %esi
  800635:	53                   	push   %ebx
  800636:	83 ec 3c             	sub    $0x3c,%esp
  800639:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80063c:	89 d7                	mov    %edx,%edi
  80063e:	8b 45 08             	mov    0x8(%ebp),%eax
  800641:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800644:	8b 45 0c             	mov    0xc(%ebp),%eax
  800647:	89 c3                	mov    %eax,%ebx
  800649:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80064c:	8b 45 10             	mov    0x10(%ebp),%eax
  80064f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800652:	b9 00 00 00 00       	mov    $0x0,%ecx
  800657:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80065d:	39 d9                	cmp    %ebx,%ecx
  80065f:	72 05                	jb     800666 <printnum+0x36>
  800661:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800664:	77 69                	ja     8006cf <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800666:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800669:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80066d:	83 ee 01             	sub    $0x1,%esi
  800670:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800674:	89 44 24 08          	mov    %eax,0x8(%esp)
  800678:	8b 44 24 08          	mov    0x8(%esp),%eax
  80067c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800680:	89 c3                	mov    %eax,%ebx
  800682:	89 d6                	mov    %edx,%esi
  800684:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800687:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80068a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80068e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800692:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800695:	89 04 24             	mov    %eax,(%esp)
  800698:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80069b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069f:	e8 4c 21 00 00       	call   8027f0 <__udivdi3>
  8006a4:	89 d9                	mov    %ebx,%ecx
  8006a6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006aa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006ae:	89 04 24             	mov    %eax,(%esp)
  8006b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006b5:	89 fa                	mov    %edi,%edx
  8006b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006ba:	e8 71 ff ff ff       	call   800630 <printnum>
  8006bf:	eb 1b                	jmp    8006dc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8006c1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006c5:	8b 45 18             	mov    0x18(%ebp),%eax
  8006c8:	89 04 24             	mov    %eax,(%esp)
  8006cb:	ff d3                	call   *%ebx
  8006cd:	eb 03                	jmp    8006d2 <printnum+0xa2>
  8006cf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006d2:	83 ee 01             	sub    $0x1,%esi
  8006d5:	85 f6                	test   %esi,%esi
  8006d7:	7f e8                	jg     8006c1 <printnum+0x91>
  8006d9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006e0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8006e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006e7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ee:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006f5:	89 04 24             	mov    %eax,(%esp)
  8006f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ff:	e8 1c 22 00 00       	call   802920 <__umoddi3>
  800704:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800708:	0f be 80 96 2b 80 00 	movsbl 0x802b96(%eax),%eax
  80070f:	89 04 24             	mov    %eax,(%esp)
  800712:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800715:	ff d0                	call   *%eax
}
  800717:	83 c4 3c             	add    $0x3c,%esp
  80071a:	5b                   	pop    %ebx
  80071b:	5e                   	pop    %esi
  80071c:	5f                   	pop    %edi
  80071d:	5d                   	pop    %ebp
  80071e:	c3                   	ret    

0080071f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800722:	83 fa 01             	cmp    $0x1,%edx
  800725:	7e 0e                	jle    800735 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800727:	8b 10                	mov    (%eax),%edx
  800729:	8d 4a 08             	lea    0x8(%edx),%ecx
  80072c:	89 08                	mov    %ecx,(%eax)
  80072e:	8b 02                	mov    (%edx),%eax
  800730:	8b 52 04             	mov    0x4(%edx),%edx
  800733:	eb 22                	jmp    800757 <getuint+0x38>
	else if (lflag)
  800735:	85 d2                	test   %edx,%edx
  800737:	74 10                	je     800749 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800739:	8b 10                	mov    (%eax),%edx
  80073b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80073e:	89 08                	mov    %ecx,(%eax)
  800740:	8b 02                	mov    (%edx),%eax
  800742:	ba 00 00 00 00       	mov    $0x0,%edx
  800747:	eb 0e                	jmp    800757 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800749:	8b 10                	mov    (%eax),%edx
  80074b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80074e:	89 08                	mov    %ecx,(%eax)
  800750:	8b 02                	mov    (%edx),%eax
  800752:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80075f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800763:	8b 10                	mov    (%eax),%edx
  800765:	3b 50 04             	cmp    0x4(%eax),%edx
  800768:	73 0a                	jae    800774 <sprintputch+0x1b>
		*b->buf++ = ch;
  80076a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80076d:	89 08                	mov    %ecx,(%eax)
  80076f:	8b 45 08             	mov    0x8(%ebp),%eax
  800772:	88 02                	mov    %al,(%edx)
}
  800774:	5d                   	pop    %ebp
  800775:	c3                   	ret    

00800776 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80077c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80077f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800783:	8b 45 10             	mov    0x10(%ebp),%eax
  800786:	89 44 24 08          	mov    %eax,0x8(%esp)
  80078a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80078d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800791:	8b 45 08             	mov    0x8(%ebp),%eax
  800794:	89 04 24             	mov    %eax,(%esp)
  800797:	e8 02 00 00 00       	call   80079e <vprintfmt>
	va_end(ap);
}
  80079c:	c9                   	leave  
  80079d:	c3                   	ret    

0080079e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	57                   	push   %edi
  8007a2:	56                   	push   %esi
  8007a3:	53                   	push   %ebx
  8007a4:	83 ec 3c             	sub    $0x3c,%esp
  8007a7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8007aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007ad:	eb 14                	jmp    8007c3 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8007af:	85 c0                	test   %eax,%eax
  8007b1:	0f 84 b3 03 00 00    	je     800b6a <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  8007b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007bb:	89 04 24             	mov    %eax,(%esp)
  8007be:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007c1:	89 f3                	mov    %esi,%ebx
  8007c3:	8d 73 01             	lea    0x1(%ebx),%esi
  8007c6:	0f b6 03             	movzbl (%ebx),%eax
  8007c9:	83 f8 25             	cmp    $0x25,%eax
  8007cc:	75 e1                	jne    8007af <vprintfmt+0x11>
  8007ce:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8007d2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8007d9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8007e0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8007e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ec:	eb 1d                	jmp    80080b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ee:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8007f0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8007f4:	eb 15                	jmp    80080b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8007f8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8007fc:	eb 0d                	jmp    80080b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8007fe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800801:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800804:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80080e:	0f b6 0e             	movzbl (%esi),%ecx
  800811:	0f b6 c1             	movzbl %cl,%eax
  800814:	83 e9 23             	sub    $0x23,%ecx
  800817:	80 f9 55             	cmp    $0x55,%cl
  80081a:	0f 87 2a 03 00 00    	ja     800b4a <vprintfmt+0x3ac>
  800820:	0f b6 c9             	movzbl %cl,%ecx
  800823:	ff 24 8d e0 2c 80 00 	jmp    *0x802ce0(,%ecx,4)
  80082a:	89 de                	mov    %ebx,%esi
  80082c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800831:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800834:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800838:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80083b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80083e:	83 fb 09             	cmp    $0x9,%ebx
  800841:	77 36                	ja     800879 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800843:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800846:	eb e9                	jmp    800831 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800848:	8b 45 14             	mov    0x14(%ebp),%eax
  80084b:	8d 48 04             	lea    0x4(%eax),%ecx
  80084e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800851:	8b 00                	mov    (%eax),%eax
  800853:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800856:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800858:	eb 22                	jmp    80087c <vprintfmt+0xde>
  80085a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80085d:	85 c9                	test   %ecx,%ecx
  80085f:	b8 00 00 00 00       	mov    $0x0,%eax
  800864:	0f 49 c1             	cmovns %ecx,%eax
  800867:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80086a:	89 de                	mov    %ebx,%esi
  80086c:	eb 9d                	jmp    80080b <vprintfmt+0x6d>
  80086e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800870:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800877:	eb 92                	jmp    80080b <vprintfmt+0x6d>
  800879:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80087c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800880:	79 89                	jns    80080b <vprintfmt+0x6d>
  800882:	e9 77 ff ff ff       	jmp    8007fe <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800887:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088a:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80088c:	e9 7a ff ff ff       	jmp    80080b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800891:	8b 45 14             	mov    0x14(%ebp),%eax
  800894:	8d 50 04             	lea    0x4(%eax),%edx
  800897:	89 55 14             	mov    %edx,0x14(%ebp)
  80089a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80089e:	8b 00                	mov    (%eax),%eax
  8008a0:	89 04 24             	mov    %eax,(%esp)
  8008a3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008a6:	e9 18 ff ff ff       	jmp    8007c3 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ae:	8d 50 04             	lea    0x4(%eax),%edx
  8008b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b4:	8b 00                	mov    (%eax),%eax
  8008b6:	99                   	cltd   
  8008b7:	31 d0                	xor    %edx,%eax
  8008b9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8008bb:	83 f8 0f             	cmp    $0xf,%eax
  8008be:	7f 0b                	jg     8008cb <vprintfmt+0x12d>
  8008c0:	8b 14 85 40 2e 80 00 	mov    0x802e40(,%eax,4),%edx
  8008c7:	85 d2                	test   %edx,%edx
  8008c9:	75 20                	jne    8008eb <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  8008cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008cf:	c7 44 24 08 ae 2b 80 	movl   $0x802bae,0x8(%esp)
  8008d6:	00 
  8008d7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	89 04 24             	mov    %eax,(%esp)
  8008e1:	e8 90 fe ff ff       	call   800776 <printfmt>
  8008e6:	e9 d8 fe ff ff       	jmp    8007c3 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8008eb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008ef:	c7 44 24 08 75 2f 80 	movl   $0x802f75,0x8(%esp)
  8008f6:	00 
  8008f7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fe:	89 04 24             	mov    %eax,(%esp)
  800901:	e8 70 fe ff ff       	call   800776 <printfmt>
  800906:	e9 b8 fe ff ff       	jmp    8007c3 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80090b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80090e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800911:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800914:	8b 45 14             	mov    0x14(%ebp),%eax
  800917:	8d 50 04             	lea    0x4(%eax),%edx
  80091a:	89 55 14             	mov    %edx,0x14(%ebp)
  80091d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80091f:	85 f6                	test   %esi,%esi
  800921:	b8 a7 2b 80 00       	mov    $0x802ba7,%eax
  800926:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800929:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80092d:	0f 84 97 00 00 00    	je     8009ca <vprintfmt+0x22c>
  800933:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800937:	0f 8e 9b 00 00 00    	jle    8009d8 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80093d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800941:	89 34 24             	mov    %esi,(%esp)
  800944:	e8 cf 02 00 00       	call   800c18 <strnlen>
  800949:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80094c:	29 c2                	sub    %eax,%edx
  80094e:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800951:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800955:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800958:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80095b:	8b 75 08             	mov    0x8(%ebp),%esi
  80095e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800961:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800963:	eb 0f                	jmp    800974 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800965:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800969:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80096c:	89 04 24             	mov    %eax,(%esp)
  80096f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800971:	83 eb 01             	sub    $0x1,%ebx
  800974:	85 db                	test   %ebx,%ebx
  800976:	7f ed                	jg     800965 <vprintfmt+0x1c7>
  800978:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80097b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80097e:	85 d2                	test   %edx,%edx
  800980:	b8 00 00 00 00       	mov    $0x0,%eax
  800985:	0f 49 c2             	cmovns %edx,%eax
  800988:	29 c2                	sub    %eax,%edx
  80098a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80098d:	89 d7                	mov    %edx,%edi
  80098f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800992:	eb 50                	jmp    8009e4 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800994:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800998:	74 1e                	je     8009b8 <vprintfmt+0x21a>
  80099a:	0f be d2             	movsbl %dl,%edx
  80099d:	83 ea 20             	sub    $0x20,%edx
  8009a0:	83 fa 5e             	cmp    $0x5e,%edx
  8009a3:	76 13                	jbe    8009b8 <vprintfmt+0x21a>
					putch('?', putdat);
  8009a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ac:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8009b3:	ff 55 08             	call   *0x8(%ebp)
  8009b6:	eb 0d                	jmp    8009c5 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8009b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009bf:	89 04 24             	mov    %eax,(%esp)
  8009c2:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009c5:	83 ef 01             	sub    $0x1,%edi
  8009c8:	eb 1a                	jmp    8009e4 <vprintfmt+0x246>
  8009ca:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8009cd:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8009d0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009d3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8009d6:	eb 0c                	jmp    8009e4 <vprintfmt+0x246>
  8009d8:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8009db:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8009de:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009e1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8009e4:	83 c6 01             	add    $0x1,%esi
  8009e7:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  8009eb:	0f be c2             	movsbl %dl,%eax
  8009ee:	85 c0                	test   %eax,%eax
  8009f0:	74 27                	je     800a19 <vprintfmt+0x27b>
  8009f2:	85 db                	test   %ebx,%ebx
  8009f4:	78 9e                	js     800994 <vprintfmt+0x1f6>
  8009f6:	83 eb 01             	sub    $0x1,%ebx
  8009f9:	79 99                	jns    800994 <vprintfmt+0x1f6>
  8009fb:	89 f8                	mov    %edi,%eax
  8009fd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a00:	8b 75 08             	mov    0x8(%ebp),%esi
  800a03:	89 c3                	mov    %eax,%ebx
  800a05:	eb 1a                	jmp    800a21 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a07:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a0b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a12:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a14:	83 eb 01             	sub    $0x1,%ebx
  800a17:	eb 08                	jmp    800a21 <vprintfmt+0x283>
  800a19:	89 fb                	mov    %edi,%ebx
  800a1b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a1e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a21:	85 db                	test   %ebx,%ebx
  800a23:	7f e2                	jg     800a07 <vprintfmt+0x269>
  800a25:	89 75 08             	mov    %esi,0x8(%ebp)
  800a28:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a2b:	e9 93 fd ff ff       	jmp    8007c3 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a30:	83 fa 01             	cmp    $0x1,%edx
  800a33:	7e 16                	jle    800a4b <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800a35:	8b 45 14             	mov    0x14(%ebp),%eax
  800a38:	8d 50 08             	lea    0x8(%eax),%edx
  800a3b:	89 55 14             	mov    %edx,0x14(%ebp)
  800a3e:	8b 50 04             	mov    0x4(%eax),%edx
  800a41:	8b 00                	mov    (%eax),%eax
  800a43:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a46:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a49:	eb 32                	jmp    800a7d <vprintfmt+0x2df>
	else if (lflag)
  800a4b:	85 d2                	test   %edx,%edx
  800a4d:	74 18                	je     800a67 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  800a4f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a52:	8d 50 04             	lea    0x4(%eax),%edx
  800a55:	89 55 14             	mov    %edx,0x14(%ebp)
  800a58:	8b 30                	mov    (%eax),%esi
  800a5a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800a5d:	89 f0                	mov    %esi,%eax
  800a5f:	c1 f8 1f             	sar    $0x1f,%eax
  800a62:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a65:	eb 16                	jmp    800a7d <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800a67:	8b 45 14             	mov    0x14(%ebp),%eax
  800a6a:	8d 50 04             	lea    0x4(%eax),%edx
  800a6d:	89 55 14             	mov    %edx,0x14(%ebp)
  800a70:	8b 30                	mov    (%eax),%esi
  800a72:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800a75:	89 f0                	mov    %esi,%eax
  800a77:	c1 f8 1f             	sar    $0x1f,%eax
  800a7a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a80:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a83:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a88:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a8c:	0f 89 80 00 00 00    	jns    800b12 <vprintfmt+0x374>
				putch('-', putdat);
  800a92:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a96:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a9d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800aa0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800aa3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800aa6:	f7 d8                	neg    %eax
  800aa8:	83 d2 00             	adc    $0x0,%edx
  800aab:	f7 da                	neg    %edx
			}
			base = 10;
  800aad:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800ab2:	eb 5e                	jmp    800b12 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800ab4:	8d 45 14             	lea    0x14(%ebp),%eax
  800ab7:	e8 63 fc ff ff       	call   80071f <getuint>
			base = 10;
  800abc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800ac1:	eb 4f                	jmp    800b12 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800ac3:	8d 45 14             	lea    0x14(%ebp),%eax
  800ac6:	e8 54 fc ff ff       	call   80071f <getuint>
			base = 8;
  800acb:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800ad0:	eb 40                	jmp    800b12 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800ad2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ad6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800add:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800ae0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ae4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800aeb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800aee:	8b 45 14             	mov    0x14(%ebp),%eax
  800af1:	8d 50 04             	lea    0x4(%eax),%edx
  800af4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800af7:	8b 00                	mov    (%eax),%eax
  800af9:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800afe:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b03:	eb 0d                	jmp    800b12 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b05:	8d 45 14             	lea    0x14(%ebp),%eax
  800b08:	e8 12 fc ff ff       	call   80071f <getuint>
			base = 16;
  800b0d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b12:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800b16:	89 74 24 10          	mov    %esi,0x10(%esp)
  800b1a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800b1d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800b21:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800b25:	89 04 24             	mov    %eax,(%esp)
  800b28:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b2c:	89 fa                	mov    %edi,%edx
  800b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b31:	e8 fa fa ff ff       	call   800630 <printnum>
			break;
  800b36:	e9 88 fc ff ff       	jmp    8007c3 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b3b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b3f:	89 04 24             	mov    %eax,(%esp)
  800b42:	ff 55 08             	call   *0x8(%ebp)
			break;
  800b45:	e9 79 fc ff ff       	jmp    8007c3 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b4a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b4e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b55:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b58:	89 f3                	mov    %esi,%ebx
  800b5a:	eb 03                	jmp    800b5f <vprintfmt+0x3c1>
  800b5c:	83 eb 01             	sub    $0x1,%ebx
  800b5f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800b63:	75 f7                	jne    800b5c <vprintfmt+0x3be>
  800b65:	e9 59 fc ff ff       	jmp    8007c3 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800b6a:	83 c4 3c             	add    $0x3c,%esp
  800b6d:	5b                   	pop    %ebx
  800b6e:	5e                   	pop    %esi
  800b6f:	5f                   	pop    %edi
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    

00800b72 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	83 ec 28             	sub    $0x28,%esp
  800b78:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b7e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b81:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b85:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b88:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b8f:	85 c0                	test   %eax,%eax
  800b91:	74 30                	je     800bc3 <vsnprintf+0x51>
  800b93:	85 d2                	test   %edx,%edx
  800b95:	7e 2c                	jle    800bc3 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b97:	8b 45 14             	mov    0x14(%ebp),%eax
  800b9a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b9e:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ba5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ba8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bac:	c7 04 24 59 07 80 00 	movl   $0x800759,(%esp)
  800bb3:	e8 e6 fb ff ff       	call   80079e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bbb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bc1:	eb 05                	jmp    800bc8 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800bc3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800bc8:	c9                   	leave  
  800bc9:	c3                   	ret    

00800bca <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bd0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800bd3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bd7:	8b 45 10             	mov    0x10(%ebp),%eax
  800bda:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bde:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be5:	8b 45 08             	mov    0x8(%ebp),%eax
  800be8:	89 04 24             	mov    %eax,(%esp)
  800beb:	e8 82 ff ff ff       	call   800b72 <vsnprintf>
	va_end(ap);

	return rc;
}
  800bf0:	c9                   	leave  
  800bf1:	c3                   	ret    
  800bf2:	66 90                	xchg   %ax,%ax
  800bf4:	66 90                	xchg   %ax,%ax
  800bf6:	66 90                	xchg   %ax,%ax
  800bf8:	66 90                	xchg   %ax,%ax
  800bfa:	66 90                	xchg   %ax,%ax
  800bfc:	66 90                	xchg   %ax,%ax
  800bfe:	66 90                	xchg   %ax,%ax

00800c00 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c06:	b8 00 00 00 00       	mov    $0x0,%eax
  800c0b:	eb 03                	jmp    800c10 <strlen+0x10>
		n++;
  800c0d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c10:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c14:	75 f7                	jne    800c0d <strlen+0xd>
		n++;
	return n;
}
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c1e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c21:	b8 00 00 00 00       	mov    $0x0,%eax
  800c26:	eb 03                	jmp    800c2b <strnlen+0x13>
		n++;
  800c28:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c2b:	39 d0                	cmp    %edx,%eax
  800c2d:	74 06                	je     800c35 <strnlen+0x1d>
  800c2f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800c33:	75 f3                	jne    800c28 <strnlen+0x10>
		n++;
	return n;
}
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	53                   	push   %ebx
  800c3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c41:	89 c2                	mov    %eax,%edx
  800c43:	83 c2 01             	add    $0x1,%edx
  800c46:	83 c1 01             	add    $0x1,%ecx
  800c49:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800c4d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c50:	84 db                	test   %bl,%bl
  800c52:	75 ef                	jne    800c43 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800c54:	5b                   	pop    %ebx
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	53                   	push   %ebx
  800c5b:	83 ec 08             	sub    $0x8,%esp
  800c5e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c61:	89 1c 24             	mov    %ebx,(%esp)
  800c64:	e8 97 ff ff ff       	call   800c00 <strlen>
	strcpy(dst + len, src);
  800c69:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c6c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c70:	01 d8                	add    %ebx,%eax
  800c72:	89 04 24             	mov    %eax,(%esp)
  800c75:	e8 bd ff ff ff       	call   800c37 <strcpy>
	return dst;
}
  800c7a:	89 d8                	mov    %ebx,%eax
  800c7c:	83 c4 08             	add    $0x8,%esp
  800c7f:	5b                   	pop    %ebx
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
  800c87:	8b 75 08             	mov    0x8(%ebp),%esi
  800c8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8d:	89 f3                	mov    %esi,%ebx
  800c8f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c92:	89 f2                	mov    %esi,%edx
  800c94:	eb 0f                	jmp    800ca5 <strncpy+0x23>
		*dst++ = *src;
  800c96:	83 c2 01             	add    $0x1,%edx
  800c99:	0f b6 01             	movzbl (%ecx),%eax
  800c9c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c9f:	80 39 01             	cmpb   $0x1,(%ecx)
  800ca2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ca5:	39 da                	cmp    %ebx,%edx
  800ca7:	75 ed                	jne    800c96 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ca9:	89 f0                	mov    %esi,%eax
  800cab:	5b                   	pop    %ebx
  800cac:	5e                   	pop    %esi
  800cad:	5d                   	pop    %ebp
  800cae:	c3                   	ret    

00800caf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	56                   	push   %esi
  800cb3:	53                   	push   %ebx
  800cb4:	8b 75 08             	mov    0x8(%ebp),%esi
  800cb7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cba:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800cbd:	89 f0                	mov    %esi,%eax
  800cbf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cc3:	85 c9                	test   %ecx,%ecx
  800cc5:	75 0b                	jne    800cd2 <strlcpy+0x23>
  800cc7:	eb 1d                	jmp    800ce6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800cc9:	83 c0 01             	add    $0x1,%eax
  800ccc:	83 c2 01             	add    $0x1,%edx
  800ccf:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800cd2:	39 d8                	cmp    %ebx,%eax
  800cd4:	74 0b                	je     800ce1 <strlcpy+0x32>
  800cd6:	0f b6 0a             	movzbl (%edx),%ecx
  800cd9:	84 c9                	test   %cl,%cl
  800cdb:	75 ec                	jne    800cc9 <strlcpy+0x1a>
  800cdd:	89 c2                	mov    %eax,%edx
  800cdf:	eb 02                	jmp    800ce3 <strlcpy+0x34>
  800ce1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800ce3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800ce6:	29 f0                	sub    %esi,%eax
}
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800cf5:	eb 06                	jmp    800cfd <strcmp+0x11>
		p++, q++;
  800cf7:	83 c1 01             	add    $0x1,%ecx
  800cfa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800cfd:	0f b6 01             	movzbl (%ecx),%eax
  800d00:	84 c0                	test   %al,%al
  800d02:	74 04                	je     800d08 <strcmp+0x1c>
  800d04:	3a 02                	cmp    (%edx),%al
  800d06:	74 ef                	je     800cf7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d08:	0f b6 c0             	movzbl %al,%eax
  800d0b:	0f b6 12             	movzbl (%edx),%edx
  800d0e:	29 d0                	sub    %edx,%eax
}
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	53                   	push   %ebx
  800d16:	8b 45 08             	mov    0x8(%ebp),%eax
  800d19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d1c:	89 c3                	mov    %eax,%ebx
  800d1e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d21:	eb 06                	jmp    800d29 <strncmp+0x17>
		n--, p++, q++;
  800d23:	83 c0 01             	add    $0x1,%eax
  800d26:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d29:	39 d8                	cmp    %ebx,%eax
  800d2b:	74 15                	je     800d42 <strncmp+0x30>
  800d2d:	0f b6 08             	movzbl (%eax),%ecx
  800d30:	84 c9                	test   %cl,%cl
  800d32:	74 04                	je     800d38 <strncmp+0x26>
  800d34:	3a 0a                	cmp    (%edx),%cl
  800d36:	74 eb                	je     800d23 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d38:	0f b6 00             	movzbl (%eax),%eax
  800d3b:	0f b6 12             	movzbl (%edx),%edx
  800d3e:	29 d0                	sub    %edx,%eax
  800d40:	eb 05                	jmp    800d47 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d42:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d47:	5b                   	pop    %ebx
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d54:	eb 07                	jmp    800d5d <strchr+0x13>
		if (*s == c)
  800d56:	38 ca                	cmp    %cl,%dl
  800d58:	74 0f                	je     800d69 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d5a:	83 c0 01             	add    $0x1,%eax
  800d5d:	0f b6 10             	movzbl (%eax),%edx
  800d60:	84 d2                	test   %dl,%dl
  800d62:	75 f2                	jne    800d56 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800d64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d75:	eb 07                	jmp    800d7e <strfind+0x13>
		if (*s == c)
  800d77:	38 ca                	cmp    %cl,%dl
  800d79:	74 0a                	je     800d85 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d7b:	83 c0 01             	add    $0x1,%eax
  800d7e:	0f b6 10             	movzbl (%eax),%edx
  800d81:	84 d2                	test   %dl,%dl
  800d83:	75 f2                	jne    800d77 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    

00800d87 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	57                   	push   %edi
  800d8b:	56                   	push   %esi
  800d8c:	53                   	push   %ebx
  800d8d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d90:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d93:	85 c9                	test   %ecx,%ecx
  800d95:	74 36                	je     800dcd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d97:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d9d:	75 28                	jne    800dc7 <memset+0x40>
  800d9f:	f6 c1 03             	test   $0x3,%cl
  800da2:	75 23                	jne    800dc7 <memset+0x40>
		c &= 0xFF;
  800da4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800da8:	89 d3                	mov    %edx,%ebx
  800daa:	c1 e3 08             	shl    $0x8,%ebx
  800dad:	89 d6                	mov    %edx,%esi
  800daf:	c1 e6 18             	shl    $0x18,%esi
  800db2:	89 d0                	mov    %edx,%eax
  800db4:	c1 e0 10             	shl    $0x10,%eax
  800db7:	09 f0                	or     %esi,%eax
  800db9:	09 c2                	or     %eax,%edx
  800dbb:	89 d0                	mov    %edx,%eax
  800dbd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800dbf:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800dc2:	fc                   	cld    
  800dc3:	f3 ab                	rep stos %eax,%es:(%edi)
  800dc5:	eb 06                	jmp    800dcd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dca:	fc                   	cld    
  800dcb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800dcd:	89 f8                	mov    %edi,%eax
  800dcf:	5b                   	pop    %ebx
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	57                   	push   %edi
  800dd8:	56                   	push   %esi
  800dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ddf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800de2:	39 c6                	cmp    %eax,%esi
  800de4:	73 35                	jae    800e1b <memmove+0x47>
  800de6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800de9:	39 d0                	cmp    %edx,%eax
  800deb:	73 2e                	jae    800e1b <memmove+0x47>
		s += n;
		d += n;
  800ded:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800df0:	89 d6                	mov    %edx,%esi
  800df2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800df4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800dfa:	75 13                	jne    800e0f <memmove+0x3b>
  800dfc:	f6 c1 03             	test   $0x3,%cl
  800dff:	75 0e                	jne    800e0f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e01:	83 ef 04             	sub    $0x4,%edi
  800e04:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e07:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e0a:	fd                   	std    
  800e0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e0d:	eb 09                	jmp    800e18 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e0f:	83 ef 01             	sub    $0x1,%edi
  800e12:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e15:	fd                   	std    
  800e16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e18:	fc                   	cld    
  800e19:	eb 1d                	jmp    800e38 <memmove+0x64>
  800e1b:	89 f2                	mov    %esi,%edx
  800e1d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e1f:	f6 c2 03             	test   $0x3,%dl
  800e22:	75 0f                	jne    800e33 <memmove+0x5f>
  800e24:	f6 c1 03             	test   $0x3,%cl
  800e27:	75 0a                	jne    800e33 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e29:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e2c:	89 c7                	mov    %eax,%edi
  800e2e:	fc                   	cld    
  800e2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e31:	eb 05                	jmp    800e38 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e33:	89 c7                	mov    %eax,%edi
  800e35:	fc                   	cld    
  800e36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e38:	5e                   	pop    %esi
  800e39:	5f                   	pop    %edi
  800e3a:	5d                   	pop    %ebp
  800e3b:	c3                   	ret    

00800e3c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e42:	8b 45 10             	mov    0x10(%ebp),%eax
  800e45:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e49:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e50:	8b 45 08             	mov    0x8(%ebp),%eax
  800e53:	89 04 24             	mov    %eax,(%esp)
  800e56:	e8 79 ff ff ff       	call   800dd4 <memmove>
}
  800e5b:	c9                   	leave  
  800e5c:	c3                   	ret    

00800e5d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	56                   	push   %esi
  800e61:	53                   	push   %ebx
  800e62:	8b 55 08             	mov    0x8(%ebp),%edx
  800e65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e68:	89 d6                	mov    %edx,%esi
  800e6a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e6d:	eb 1a                	jmp    800e89 <memcmp+0x2c>
		if (*s1 != *s2)
  800e6f:	0f b6 02             	movzbl (%edx),%eax
  800e72:	0f b6 19             	movzbl (%ecx),%ebx
  800e75:	38 d8                	cmp    %bl,%al
  800e77:	74 0a                	je     800e83 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800e79:	0f b6 c0             	movzbl %al,%eax
  800e7c:	0f b6 db             	movzbl %bl,%ebx
  800e7f:	29 d8                	sub    %ebx,%eax
  800e81:	eb 0f                	jmp    800e92 <memcmp+0x35>
		s1++, s2++;
  800e83:	83 c2 01             	add    $0x1,%edx
  800e86:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e89:	39 f2                	cmp    %esi,%edx
  800e8b:	75 e2                	jne    800e6f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e92:	5b                   	pop    %ebx
  800e93:	5e                   	pop    %esi
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800e9f:	89 c2                	mov    %eax,%edx
  800ea1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ea4:	eb 07                	jmp    800ead <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ea6:	38 08                	cmp    %cl,(%eax)
  800ea8:	74 07                	je     800eb1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800eaa:	83 c0 01             	add    $0x1,%eax
  800ead:	39 d0                	cmp    %edx,%eax
  800eaf:	72 f5                	jb     800ea6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    

00800eb3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	57                   	push   %edi
  800eb7:	56                   	push   %esi
  800eb8:	53                   	push   %ebx
  800eb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ebf:	eb 03                	jmp    800ec4 <strtol+0x11>
		s++;
  800ec1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ec4:	0f b6 0a             	movzbl (%edx),%ecx
  800ec7:	80 f9 09             	cmp    $0x9,%cl
  800eca:	74 f5                	je     800ec1 <strtol+0xe>
  800ecc:	80 f9 20             	cmp    $0x20,%cl
  800ecf:	74 f0                	je     800ec1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ed1:	80 f9 2b             	cmp    $0x2b,%cl
  800ed4:	75 0a                	jne    800ee0 <strtol+0x2d>
		s++;
  800ed6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ed9:	bf 00 00 00 00       	mov    $0x0,%edi
  800ede:	eb 11                	jmp    800ef1 <strtol+0x3e>
  800ee0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ee5:	80 f9 2d             	cmp    $0x2d,%cl
  800ee8:	75 07                	jne    800ef1 <strtol+0x3e>
		s++, neg = 1;
  800eea:	8d 52 01             	lea    0x1(%edx),%edx
  800eed:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ef1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800ef6:	75 15                	jne    800f0d <strtol+0x5a>
  800ef8:	80 3a 30             	cmpb   $0x30,(%edx)
  800efb:	75 10                	jne    800f0d <strtol+0x5a>
  800efd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f01:	75 0a                	jne    800f0d <strtol+0x5a>
		s += 2, base = 16;
  800f03:	83 c2 02             	add    $0x2,%edx
  800f06:	b8 10 00 00 00       	mov    $0x10,%eax
  800f0b:	eb 10                	jmp    800f1d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800f0d:	85 c0                	test   %eax,%eax
  800f0f:	75 0c                	jne    800f1d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f11:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f13:	80 3a 30             	cmpb   $0x30,(%edx)
  800f16:	75 05                	jne    800f1d <strtol+0x6a>
		s++, base = 8;
  800f18:	83 c2 01             	add    $0x1,%edx
  800f1b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800f1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f22:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f25:	0f b6 0a             	movzbl (%edx),%ecx
  800f28:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800f2b:	89 f0                	mov    %esi,%eax
  800f2d:	3c 09                	cmp    $0x9,%al
  800f2f:	77 08                	ja     800f39 <strtol+0x86>
			dig = *s - '0';
  800f31:	0f be c9             	movsbl %cl,%ecx
  800f34:	83 e9 30             	sub    $0x30,%ecx
  800f37:	eb 20                	jmp    800f59 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800f39:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800f3c:	89 f0                	mov    %esi,%eax
  800f3e:	3c 19                	cmp    $0x19,%al
  800f40:	77 08                	ja     800f4a <strtol+0x97>
			dig = *s - 'a' + 10;
  800f42:	0f be c9             	movsbl %cl,%ecx
  800f45:	83 e9 57             	sub    $0x57,%ecx
  800f48:	eb 0f                	jmp    800f59 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800f4a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800f4d:	89 f0                	mov    %esi,%eax
  800f4f:	3c 19                	cmp    $0x19,%al
  800f51:	77 16                	ja     800f69 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800f53:	0f be c9             	movsbl %cl,%ecx
  800f56:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f59:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800f5c:	7d 0f                	jge    800f6d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800f5e:	83 c2 01             	add    $0x1,%edx
  800f61:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800f65:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800f67:	eb bc                	jmp    800f25 <strtol+0x72>
  800f69:	89 d8                	mov    %ebx,%eax
  800f6b:	eb 02                	jmp    800f6f <strtol+0xbc>
  800f6d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800f6f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f73:	74 05                	je     800f7a <strtol+0xc7>
		*endptr = (char *) s;
  800f75:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f78:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800f7a:	f7 d8                	neg    %eax
  800f7c:	85 ff                	test   %edi,%edi
  800f7e:	0f 44 c3             	cmove  %ebx,%eax
}
  800f81:	5b                   	pop    %ebx
  800f82:	5e                   	pop    %esi
  800f83:	5f                   	pop    %edi
  800f84:	5d                   	pop    %ebp
  800f85:	c3                   	ret    

00800f86 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	57                   	push   %edi
  800f8a:	56                   	push   %esi
  800f8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f94:	8b 55 08             	mov    0x8(%ebp),%edx
  800f97:	89 c3                	mov    %eax,%ebx
  800f99:	89 c7                	mov    %eax,%edi
  800f9b:	89 c6                	mov    %eax,%esi
  800f9d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f9f:	5b                   	pop    %ebx
  800fa0:	5e                   	pop    %esi
  800fa1:	5f                   	pop    %edi
  800fa2:	5d                   	pop    %ebp
  800fa3:	c3                   	ret    

00800fa4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	57                   	push   %edi
  800fa8:	56                   	push   %esi
  800fa9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800faa:	ba 00 00 00 00       	mov    $0x0,%edx
  800faf:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb4:	89 d1                	mov    %edx,%ecx
  800fb6:	89 d3                	mov    %edx,%ebx
  800fb8:	89 d7                	mov    %edx,%edi
  800fba:	89 d6                	mov    %edx,%esi
  800fbc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fbe:	5b                   	pop    %ebx
  800fbf:	5e                   	pop    %esi
  800fc0:	5f                   	pop    %edi
  800fc1:	5d                   	pop    %ebp
  800fc2:	c3                   	ret    

00800fc3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fc3:	55                   	push   %ebp
  800fc4:	89 e5                	mov    %esp,%ebp
  800fc6:	57                   	push   %edi
  800fc7:	56                   	push   %esi
  800fc8:	53                   	push   %ebx
  800fc9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fcc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fd1:	b8 03 00 00 00       	mov    $0x3,%eax
  800fd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd9:	89 cb                	mov    %ecx,%ebx
  800fdb:	89 cf                	mov    %ecx,%edi
  800fdd:	89 ce                	mov    %ecx,%esi
  800fdf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	7e 28                	jle    80100d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fe9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ff0:	00 
  800ff1:	c7 44 24 08 9f 2e 80 	movl   $0x802e9f,0x8(%esp)
  800ff8:	00 
  800ff9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801000:	00 
  801001:	c7 04 24 bc 2e 80 00 	movl   $0x802ebc,(%esp)
  801008:	e8 29 16 00 00       	call   802636 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80100d:	83 c4 2c             	add    $0x2c,%esp
  801010:	5b                   	pop    %ebx
  801011:	5e                   	pop    %esi
  801012:	5f                   	pop    %edi
  801013:	5d                   	pop    %ebp
  801014:	c3                   	ret    

00801015 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	57                   	push   %edi
  801019:	56                   	push   %esi
  80101a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80101b:	ba 00 00 00 00       	mov    $0x0,%edx
  801020:	b8 02 00 00 00       	mov    $0x2,%eax
  801025:	89 d1                	mov    %edx,%ecx
  801027:	89 d3                	mov    %edx,%ebx
  801029:	89 d7                	mov    %edx,%edi
  80102b:	89 d6                	mov    %edx,%esi
  80102d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80102f:	5b                   	pop    %ebx
  801030:	5e                   	pop    %esi
  801031:	5f                   	pop    %edi
  801032:	5d                   	pop    %ebp
  801033:	c3                   	ret    

00801034 <sys_yield>:

void
sys_yield(void)
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
  80103f:	b8 0b 00 00 00       	mov    $0xb,%eax
  801044:	89 d1                	mov    %edx,%ecx
  801046:	89 d3                	mov    %edx,%ebx
  801048:	89 d7                	mov    %edx,%edi
  80104a:	89 d6                	mov    %edx,%esi
  80104c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80104e:	5b                   	pop    %ebx
  80104f:	5e                   	pop    %esi
  801050:	5f                   	pop    %edi
  801051:	5d                   	pop    %ebp
  801052:	c3                   	ret    

00801053 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  80105c:	be 00 00 00 00       	mov    $0x0,%esi
  801061:	b8 04 00 00 00       	mov    $0x4,%eax
  801066:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801069:	8b 55 08             	mov    0x8(%ebp),%edx
  80106c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80106f:	89 f7                	mov    %esi,%edi
  801071:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801073:	85 c0                	test   %eax,%eax
  801075:	7e 28                	jle    80109f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801077:	89 44 24 10          	mov    %eax,0x10(%esp)
  80107b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801082:	00 
  801083:	c7 44 24 08 9f 2e 80 	movl   $0x802e9f,0x8(%esp)
  80108a:	00 
  80108b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801092:	00 
  801093:	c7 04 24 bc 2e 80 00 	movl   $0x802ebc,(%esp)
  80109a:	e8 97 15 00 00       	call   802636 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80109f:	83 c4 2c             	add    $0x2c,%esp
  8010a2:	5b                   	pop    %ebx
  8010a3:	5e                   	pop    %esi
  8010a4:	5f                   	pop    %edi
  8010a5:	5d                   	pop    %ebp
  8010a6:	c3                   	ret    

008010a7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010a7:	55                   	push   %ebp
  8010a8:	89 e5                	mov    %esp,%ebp
  8010aa:	57                   	push   %edi
  8010ab:	56                   	push   %esi
  8010ac:	53                   	push   %ebx
  8010ad:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b0:	b8 05 00 00 00       	mov    $0x5,%eax
  8010b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010be:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010c1:	8b 75 18             	mov    0x18(%ebp),%esi
  8010c4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010c6:	85 c0                	test   %eax,%eax
  8010c8:	7e 28                	jle    8010f2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ca:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010ce:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8010d5:	00 
  8010d6:	c7 44 24 08 9f 2e 80 	movl   $0x802e9f,0x8(%esp)
  8010dd:	00 
  8010de:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010e5:	00 
  8010e6:	c7 04 24 bc 2e 80 00 	movl   $0x802ebc,(%esp)
  8010ed:	e8 44 15 00 00       	call   802636 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010f2:	83 c4 2c             	add    $0x2c,%esp
  8010f5:	5b                   	pop    %ebx
  8010f6:	5e                   	pop    %esi
  8010f7:	5f                   	pop    %edi
  8010f8:	5d                   	pop    %ebp
  8010f9:	c3                   	ret    

008010fa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010fa:	55                   	push   %ebp
  8010fb:	89 e5                	mov    %esp,%ebp
  8010fd:	57                   	push   %edi
  8010fe:	56                   	push   %esi
  8010ff:	53                   	push   %ebx
  801100:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801103:	bb 00 00 00 00       	mov    $0x0,%ebx
  801108:	b8 06 00 00 00       	mov    $0x6,%eax
  80110d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801110:	8b 55 08             	mov    0x8(%ebp),%edx
  801113:	89 df                	mov    %ebx,%edi
  801115:	89 de                	mov    %ebx,%esi
  801117:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801119:	85 c0                	test   %eax,%eax
  80111b:	7e 28                	jle    801145 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80111d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801121:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801128:	00 
  801129:	c7 44 24 08 9f 2e 80 	movl   $0x802e9f,0x8(%esp)
  801130:	00 
  801131:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801138:	00 
  801139:	c7 04 24 bc 2e 80 00 	movl   $0x802ebc,(%esp)
  801140:	e8 f1 14 00 00       	call   802636 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801145:	83 c4 2c             	add    $0x2c,%esp
  801148:	5b                   	pop    %ebx
  801149:	5e                   	pop    %esi
  80114a:	5f                   	pop    %edi
  80114b:	5d                   	pop    %ebp
  80114c:	c3                   	ret    

0080114d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80114d:	55                   	push   %ebp
  80114e:	89 e5                	mov    %esp,%ebp
  801150:	57                   	push   %edi
  801151:	56                   	push   %esi
  801152:	53                   	push   %ebx
  801153:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801156:	bb 00 00 00 00       	mov    $0x0,%ebx
  80115b:	b8 08 00 00 00       	mov    $0x8,%eax
  801160:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801163:	8b 55 08             	mov    0x8(%ebp),%edx
  801166:	89 df                	mov    %ebx,%edi
  801168:	89 de                	mov    %ebx,%esi
  80116a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80116c:	85 c0                	test   %eax,%eax
  80116e:	7e 28                	jle    801198 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801170:	89 44 24 10          	mov    %eax,0x10(%esp)
  801174:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80117b:	00 
  80117c:	c7 44 24 08 9f 2e 80 	movl   $0x802e9f,0x8(%esp)
  801183:	00 
  801184:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80118b:	00 
  80118c:	c7 04 24 bc 2e 80 00 	movl   $0x802ebc,(%esp)
  801193:	e8 9e 14 00 00       	call   802636 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801198:	83 c4 2c             	add    $0x2c,%esp
  80119b:	5b                   	pop    %ebx
  80119c:	5e                   	pop    %esi
  80119d:	5f                   	pop    %edi
  80119e:	5d                   	pop    %ebp
  80119f:	c3                   	ret    

008011a0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	57                   	push   %edi
  8011a4:	56                   	push   %esi
  8011a5:	53                   	push   %ebx
  8011a6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ae:	b8 09 00 00 00       	mov    $0x9,%eax
  8011b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b9:	89 df                	mov    %ebx,%edi
  8011bb:	89 de                	mov    %ebx,%esi
  8011bd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	7e 28                	jle    8011eb <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011c3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011c7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8011ce:	00 
  8011cf:	c7 44 24 08 9f 2e 80 	movl   $0x802e9f,0x8(%esp)
  8011d6:	00 
  8011d7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011de:	00 
  8011df:	c7 04 24 bc 2e 80 00 	movl   $0x802ebc,(%esp)
  8011e6:	e8 4b 14 00 00       	call   802636 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8011eb:	83 c4 2c             	add    $0x2c,%esp
  8011ee:	5b                   	pop    %ebx
  8011ef:	5e                   	pop    %esi
  8011f0:	5f                   	pop    %edi
  8011f1:	5d                   	pop    %ebp
  8011f2:	c3                   	ret    

008011f3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	57                   	push   %edi
  8011f7:	56                   	push   %esi
  8011f8:	53                   	push   %ebx
  8011f9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801201:	b8 0a 00 00 00       	mov    $0xa,%eax
  801206:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801209:	8b 55 08             	mov    0x8(%ebp),%edx
  80120c:	89 df                	mov    %ebx,%edi
  80120e:	89 de                	mov    %ebx,%esi
  801210:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801212:	85 c0                	test   %eax,%eax
  801214:	7e 28                	jle    80123e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801216:	89 44 24 10          	mov    %eax,0x10(%esp)
  80121a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801221:	00 
  801222:	c7 44 24 08 9f 2e 80 	movl   $0x802e9f,0x8(%esp)
  801229:	00 
  80122a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801231:	00 
  801232:	c7 04 24 bc 2e 80 00 	movl   $0x802ebc,(%esp)
  801239:	e8 f8 13 00 00       	call   802636 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80123e:	83 c4 2c             	add    $0x2c,%esp
  801241:	5b                   	pop    %ebx
  801242:	5e                   	pop    %esi
  801243:	5f                   	pop    %edi
  801244:	5d                   	pop    %ebp
  801245:	c3                   	ret    

00801246 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801246:	55                   	push   %ebp
  801247:	89 e5                	mov    %esp,%ebp
  801249:	57                   	push   %edi
  80124a:	56                   	push   %esi
  80124b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80124c:	be 00 00 00 00       	mov    $0x0,%esi
  801251:	b8 0c 00 00 00       	mov    $0xc,%eax
  801256:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801259:	8b 55 08             	mov    0x8(%ebp),%edx
  80125c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80125f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801262:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801264:	5b                   	pop    %ebx
  801265:	5e                   	pop    %esi
  801266:	5f                   	pop    %edi
  801267:	5d                   	pop    %ebp
  801268:	c3                   	ret    

00801269 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801269:	55                   	push   %ebp
  80126a:	89 e5                	mov    %esp,%ebp
  80126c:	57                   	push   %edi
  80126d:	56                   	push   %esi
  80126e:	53                   	push   %ebx
  80126f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801272:	b9 00 00 00 00       	mov    $0x0,%ecx
  801277:	b8 0d 00 00 00       	mov    $0xd,%eax
  80127c:	8b 55 08             	mov    0x8(%ebp),%edx
  80127f:	89 cb                	mov    %ecx,%ebx
  801281:	89 cf                	mov    %ecx,%edi
  801283:	89 ce                	mov    %ecx,%esi
  801285:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801287:	85 c0                	test   %eax,%eax
  801289:	7e 28                	jle    8012b3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80128b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80128f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801296:	00 
  801297:	c7 44 24 08 9f 2e 80 	movl   $0x802e9f,0x8(%esp)
  80129e:	00 
  80129f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012a6:	00 
  8012a7:	c7 04 24 bc 2e 80 00 	movl   $0x802ebc,(%esp)
  8012ae:	e8 83 13 00 00       	call   802636 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012b3:	83 c4 2c             	add    $0x2c,%esp
  8012b6:	5b                   	pop    %ebx
  8012b7:	5e                   	pop    %esi
  8012b8:	5f                   	pop    %edi
  8012b9:	5d                   	pop    %ebp
  8012ba:	c3                   	ret    

008012bb <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8012bb:	55                   	push   %ebp
  8012bc:	89 e5                	mov    %esp,%ebp
  8012be:	57                   	push   %edi
  8012bf:	56                   	push   %esi
  8012c0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c6:	b8 0e 00 00 00       	mov    $0xe,%eax
  8012cb:	89 d1                	mov    %edx,%ecx
  8012cd:	89 d3                	mov    %edx,%ebx
  8012cf:	89 d7                	mov    %edx,%edi
  8012d1:	89 d6                	mov    %edx,%esi
  8012d3:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8012d5:	5b                   	pop    %ebx
  8012d6:	5e                   	pop    %esi
  8012d7:	5f                   	pop    %edi
  8012d8:	5d                   	pop    %ebp
  8012d9:	c3                   	ret    

008012da <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	57                   	push   %edi
  8012de:	56                   	push   %esi
  8012df:	53                   	push   %ebx
  8012e0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012e8:	b8 0f 00 00 00       	mov    $0xf,%eax
  8012ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8012f3:	89 df                	mov    %ebx,%edi
  8012f5:	89 de                	mov    %ebx,%esi
  8012f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012f9:	85 c0                	test   %eax,%eax
  8012fb:	7e 28                	jle    801325 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  801301:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801308:	00 
  801309:	c7 44 24 08 9f 2e 80 	movl   $0x802e9f,0x8(%esp)
  801310:	00 
  801311:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801318:	00 
  801319:	c7 04 24 bc 2e 80 00 	movl   $0x802ebc,(%esp)
  801320:	e8 11 13 00 00       	call   802636 <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  801325:	83 c4 2c             	add    $0x2c,%esp
  801328:	5b                   	pop    %ebx
  801329:	5e                   	pop    %esi
  80132a:	5f                   	pop    %edi
  80132b:	5d                   	pop    %ebp
  80132c:	c3                   	ret    

0080132d <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  80132d:	55                   	push   %ebp
  80132e:	89 e5                	mov    %esp,%ebp
  801330:	57                   	push   %edi
  801331:	56                   	push   %esi
  801332:	53                   	push   %ebx
  801333:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801336:	bb 00 00 00 00       	mov    $0x0,%ebx
  80133b:	b8 10 00 00 00       	mov    $0x10,%eax
  801340:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801343:	8b 55 08             	mov    0x8(%ebp),%edx
  801346:	89 df                	mov    %ebx,%edi
  801348:	89 de                	mov    %ebx,%esi
  80134a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80134c:	85 c0                	test   %eax,%eax
  80134e:	7e 28                	jle    801378 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801350:	89 44 24 10          	mov    %eax,0x10(%esp)
  801354:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  80135b:	00 
  80135c:	c7 44 24 08 9f 2e 80 	movl   $0x802e9f,0x8(%esp)
  801363:	00 
  801364:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80136b:	00 
  80136c:	c7 04 24 bc 2e 80 00 	movl   $0x802ebc,(%esp)
  801373:	e8 be 12 00 00       	call   802636 <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  801378:	83 c4 2c             	add    $0x2c,%esp
  80137b:	5b                   	pop    %ebx
  80137c:	5e                   	pop    %esi
  80137d:	5f                   	pop    %edi
  80137e:	5d                   	pop    %ebp
  80137f:	c3                   	ret    

00801380 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801383:	8b 45 08             	mov    0x8(%ebp),%eax
  801386:	05 00 00 00 30       	add    $0x30000000,%eax
  80138b:	c1 e8 0c             	shr    $0xc,%eax
}
  80138e:	5d                   	pop    %ebp
  80138f:	c3                   	ret    

00801390 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801393:	8b 45 08             	mov    0x8(%ebp),%eax
  801396:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80139b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013a0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013a5:	5d                   	pop    %ebp
  8013a6:	c3                   	ret    

008013a7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
  8013aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ad:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013b2:	89 c2                	mov    %eax,%edx
  8013b4:	c1 ea 16             	shr    $0x16,%edx
  8013b7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013be:	f6 c2 01             	test   $0x1,%dl
  8013c1:	74 11                	je     8013d4 <fd_alloc+0x2d>
  8013c3:	89 c2                	mov    %eax,%edx
  8013c5:	c1 ea 0c             	shr    $0xc,%edx
  8013c8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013cf:	f6 c2 01             	test   $0x1,%dl
  8013d2:	75 09                	jne    8013dd <fd_alloc+0x36>
			*fd_store = fd;
  8013d4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8013db:	eb 17                	jmp    8013f4 <fd_alloc+0x4d>
  8013dd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013e2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013e7:	75 c9                	jne    8013b2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013e9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013ef:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013f4:	5d                   	pop    %ebp
  8013f5:	c3                   	ret    

008013f6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013fc:	83 f8 1f             	cmp    $0x1f,%eax
  8013ff:	77 36                	ja     801437 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801401:	c1 e0 0c             	shl    $0xc,%eax
  801404:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801409:	89 c2                	mov    %eax,%edx
  80140b:	c1 ea 16             	shr    $0x16,%edx
  80140e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801415:	f6 c2 01             	test   $0x1,%dl
  801418:	74 24                	je     80143e <fd_lookup+0x48>
  80141a:	89 c2                	mov    %eax,%edx
  80141c:	c1 ea 0c             	shr    $0xc,%edx
  80141f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801426:	f6 c2 01             	test   $0x1,%dl
  801429:	74 1a                	je     801445 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80142b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80142e:	89 02                	mov    %eax,(%edx)
	return 0;
  801430:	b8 00 00 00 00       	mov    $0x0,%eax
  801435:	eb 13                	jmp    80144a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801437:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80143c:	eb 0c                	jmp    80144a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80143e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801443:	eb 05                	jmp    80144a <fd_lookup+0x54>
  801445:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80144a:	5d                   	pop    %ebp
  80144b:	c3                   	ret    

0080144c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80144c:	55                   	push   %ebp
  80144d:	89 e5                	mov    %esp,%ebp
  80144f:	83 ec 18             	sub    $0x18,%esp
  801452:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801455:	ba 00 00 00 00       	mov    $0x0,%edx
  80145a:	eb 13                	jmp    80146f <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  80145c:	39 08                	cmp    %ecx,(%eax)
  80145e:	75 0c                	jne    80146c <dev_lookup+0x20>
			*dev = devtab[i];
  801460:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801463:	89 01                	mov    %eax,(%ecx)
			return 0;
  801465:	b8 00 00 00 00       	mov    $0x0,%eax
  80146a:	eb 38                	jmp    8014a4 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80146c:	83 c2 01             	add    $0x1,%edx
  80146f:	8b 04 95 48 2f 80 00 	mov    0x802f48(,%edx,4),%eax
  801476:	85 c0                	test   %eax,%eax
  801478:	75 e2                	jne    80145c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80147a:	a1 18 50 80 00       	mov    0x805018,%eax
  80147f:	8b 40 48             	mov    0x48(%eax),%eax
  801482:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801486:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148a:	c7 04 24 cc 2e 80 00 	movl   $0x802ecc,(%esp)
  801491:	e8 7b f1 ff ff       	call   800611 <cprintf>
	*dev = 0;
  801496:	8b 45 0c             	mov    0xc(%ebp),%eax
  801499:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80149f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014a4:	c9                   	leave  
  8014a5:	c3                   	ret    

008014a6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014a6:	55                   	push   %ebp
  8014a7:	89 e5                	mov    %esp,%ebp
  8014a9:	56                   	push   %esi
  8014aa:	53                   	push   %ebx
  8014ab:	83 ec 20             	sub    $0x20,%esp
  8014ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8014b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b7:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014bb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014c1:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014c4:	89 04 24             	mov    %eax,(%esp)
  8014c7:	e8 2a ff ff ff       	call   8013f6 <fd_lookup>
  8014cc:	85 c0                	test   %eax,%eax
  8014ce:	78 05                	js     8014d5 <fd_close+0x2f>
	    || fd != fd2)
  8014d0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014d3:	74 0c                	je     8014e1 <fd_close+0x3b>
		return (must_exist ? r : 0);
  8014d5:	84 db                	test   %bl,%bl
  8014d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014dc:	0f 44 c2             	cmove  %edx,%eax
  8014df:	eb 3f                	jmp    801520 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e8:	8b 06                	mov    (%esi),%eax
  8014ea:	89 04 24             	mov    %eax,(%esp)
  8014ed:	e8 5a ff ff ff       	call   80144c <dev_lookup>
  8014f2:	89 c3                	mov    %eax,%ebx
  8014f4:	85 c0                	test   %eax,%eax
  8014f6:	78 16                	js     80150e <fd_close+0x68>
		if (dev->dev_close)
  8014f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014fb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8014fe:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801503:	85 c0                	test   %eax,%eax
  801505:	74 07                	je     80150e <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801507:	89 34 24             	mov    %esi,(%esp)
  80150a:	ff d0                	call   *%eax
  80150c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80150e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801512:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801519:	e8 dc fb ff ff       	call   8010fa <sys_page_unmap>
	return r;
  80151e:	89 d8                	mov    %ebx,%eax
}
  801520:	83 c4 20             	add    $0x20,%esp
  801523:	5b                   	pop    %ebx
  801524:	5e                   	pop    %esi
  801525:	5d                   	pop    %ebp
  801526:	c3                   	ret    

00801527 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801527:	55                   	push   %ebp
  801528:	89 e5                	mov    %esp,%ebp
  80152a:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80152d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801530:	89 44 24 04          	mov    %eax,0x4(%esp)
  801534:	8b 45 08             	mov    0x8(%ebp),%eax
  801537:	89 04 24             	mov    %eax,(%esp)
  80153a:	e8 b7 fe ff ff       	call   8013f6 <fd_lookup>
  80153f:	89 c2                	mov    %eax,%edx
  801541:	85 d2                	test   %edx,%edx
  801543:	78 13                	js     801558 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801545:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80154c:	00 
  80154d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801550:	89 04 24             	mov    %eax,(%esp)
  801553:	e8 4e ff ff ff       	call   8014a6 <fd_close>
}
  801558:	c9                   	leave  
  801559:	c3                   	ret    

0080155a <close_all>:

void
close_all(void)
{
  80155a:	55                   	push   %ebp
  80155b:	89 e5                	mov    %esp,%ebp
  80155d:	53                   	push   %ebx
  80155e:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801561:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801566:	89 1c 24             	mov    %ebx,(%esp)
  801569:	e8 b9 ff ff ff       	call   801527 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80156e:	83 c3 01             	add    $0x1,%ebx
  801571:	83 fb 20             	cmp    $0x20,%ebx
  801574:	75 f0                	jne    801566 <close_all+0xc>
		close(i);
}
  801576:	83 c4 14             	add    $0x14,%esp
  801579:	5b                   	pop    %ebx
  80157a:	5d                   	pop    %ebp
  80157b:	c3                   	ret    

0080157c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80157c:	55                   	push   %ebp
  80157d:	89 e5                	mov    %esp,%ebp
  80157f:	57                   	push   %edi
  801580:	56                   	push   %esi
  801581:	53                   	push   %ebx
  801582:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801585:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801588:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158c:	8b 45 08             	mov    0x8(%ebp),%eax
  80158f:	89 04 24             	mov    %eax,(%esp)
  801592:	e8 5f fe ff ff       	call   8013f6 <fd_lookup>
  801597:	89 c2                	mov    %eax,%edx
  801599:	85 d2                	test   %edx,%edx
  80159b:	0f 88 e1 00 00 00    	js     801682 <dup+0x106>
		return r;
	close(newfdnum);
  8015a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015a4:	89 04 24             	mov    %eax,(%esp)
  8015a7:	e8 7b ff ff ff       	call   801527 <close>

	newfd = INDEX2FD(newfdnum);
  8015ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015af:	c1 e3 0c             	shl    $0xc,%ebx
  8015b2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015bb:	89 04 24             	mov    %eax,(%esp)
  8015be:	e8 cd fd ff ff       	call   801390 <fd2data>
  8015c3:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8015c5:	89 1c 24             	mov    %ebx,(%esp)
  8015c8:	e8 c3 fd ff ff       	call   801390 <fd2data>
  8015cd:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015cf:	89 f0                	mov    %esi,%eax
  8015d1:	c1 e8 16             	shr    $0x16,%eax
  8015d4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015db:	a8 01                	test   $0x1,%al
  8015dd:	74 43                	je     801622 <dup+0xa6>
  8015df:	89 f0                	mov    %esi,%eax
  8015e1:	c1 e8 0c             	shr    $0xc,%eax
  8015e4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015eb:	f6 c2 01             	test   $0x1,%dl
  8015ee:	74 32                	je     801622 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015f0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015f7:	25 07 0e 00 00       	and    $0xe07,%eax
  8015fc:	89 44 24 10          	mov    %eax,0x10(%esp)
  801600:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801604:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80160b:	00 
  80160c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801610:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801617:	e8 8b fa ff ff       	call   8010a7 <sys_page_map>
  80161c:	89 c6                	mov    %eax,%esi
  80161e:	85 c0                	test   %eax,%eax
  801620:	78 3e                	js     801660 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801622:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801625:	89 c2                	mov    %eax,%edx
  801627:	c1 ea 0c             	shr    $0xc,%edx
  80162a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801631:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801637:	89 54 24 10          	mov    %edx,0x10(%esp)
  80163b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80163f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801646:	00 
  801647:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801652:	e8 50 fa ff ff       	call   8010a7 <sys_page_map>
  801657:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801659:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80165c:	85 f6                	test   %esi,%esi
  80165e:	79 22                	jns    801682 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801660:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801664:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80166b:	e8 8a fa ff ff       	call   8010fa <sys_page_unmap>
	sys_page_unmap(0, nva);
  801670:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801674:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80167b:	e8 7a fa ff ff       	call   8010fa <sys_page_unmap>
	return r;
  801680:	89 f0                	mov    %esi,%eax
}
  801682:	83 c4 3c             	add    $0x3c,%esp
  801685:	5b                   	pop    %ebx
  801686:	5e                   	pop    %esi
  801687:	5f                   	pop    %edi
  801688:	5d                   	pop    %ebp
  801689:	c3                   	ret    

0080168a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80168a:	55                   	push   %ebp
  80168b:	89 e5                	mov    %esp,%ebp
  80168d:	53                   	push   %ebx
  80168e:	83 ec 24             	sub    $0x24,%esp
  801691:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801694:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801697:	89 44 24 04          	mov    %eax,0x4(%esp)
  80169b:	89 1c 24             	mov    %ebx,(%esp)
  80169e:	e8 53 fd ff ff       	call   8013f6 <fd_lookup>
  8016a3:	89 c2                	mov    %eax,%edx
  8016a5:	85 d2                	test   %edx,%edx
  8016a7:	78 6d                	js     801716 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b3:	8b 00                	mov    (%eax),%eax
  8016b5:	89 04 24             	mov    %eax,(%esp)
  8016b8:	e8 8f fd ff ff       	call   80144c <dev_lookup>
  8016bd:	85 c0                	test   %eax,%eax
  8016bf:	78 55                	js     801716 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c4:	8b 50 08             	mov    0x8(%eax),%edx
  8016c7:	83 e2 03             	and    $0x3,%edx
  8016ca:	83 fa 01             	cmp    $0x1,%edx
  8016cd:	75 23                	jne    8016f2 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016cf:	a1 18 50 80 00       	mov    0x805018,%eax
  8016d4:	8b 40 48             	mov    0x48(%eax),%eax
  8016d7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016df:	c7 04 24 0d 2f 80 00 	movl   $0x802f0d,(%esp)
  8016e6:	e8 26 ef ff ff       	call   800611 <cprintf>
		return -E_INVAL;
  8016eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016f0:	eb 24                	jmp    801716 <read+0x8c>
	}
	if (!dev->dev_read)
  8016f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f5:	8b 52 08             	mov    0x8(%edx),%edx
  8016f8:	85 d2                	test   %edx,%edx
  8016fa:	74 15                	je     801711 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016fc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016ff:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801703:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801706:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80170a:	89 04 24             	mov    %eax,(%esp)
  80170d:	ff d2                	call   *%edx
  80170f:	eb 05                	jmp    801716 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801711:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801716:	83 c4 24             	add    $0x24,%esp
  801719:	5b                   	pop    %ebx
  80171a:	5d                   	pop    %ebp
  80171b:	c3                   	ret    

0080171c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	57                   	push   %edi
  801720:	56                   	push   %esi
  801721:	53                   	push   %ebx
  801722:	83 ec 1c             	sub    $0x1c,%esp
  801725:	8b 7d 08             	mov    0x8(%ebp),%edi
  801728:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80172b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801730:	eb 23                	jmp    801755 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801732:	89 f0                	mov    %esi,%eax
  801734:	29 d8                	sub    %ebx,%eax
  801736:	89 44 24 08          	mov    %eax,0x8(%esp)
  80173a:	89 d8                	mov    %ebx,%eax
  80173c:	03 45 0c             	add    0xc(%ebp),%eax
  80173f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801743:	89 3c 24             	mov    %edi,(%esp)
  801746:	e8 3f ff ff ff       	call   80168a <read>
		if (m < 0)
  80174b:	85 c0                	test   %eax,%eax
  80174d:	78 10                	js     80175f <readn+0x43>
			return m;
		if (m == 0)
  80174f:	85 c0                	test   %eax,%eax
  801751:	74 0a                	je     80175d <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801753:	01 c3                	add    %eax,%ebx
  801755:	39 f3                	cmp    %esi,%ebx
  801757:	72 d9                	jb     801732 <readn+0x16>
  801759:	89 d8                	mov    %ebx,%eax
  80175b:	eb 02                	jmp    80175f <readn+0x43>
  80175d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80175f:	83 c4 1c             	add    $0x1c,%esp
  801762:	5b                   	pop    %ebx
  801763:	5e                   	pop    %esi
  801764:	5f                   	pop    %edi
  801765:	5d                   	pop    %ebp
  801766:	c3                   	ret    

00801767 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801767:	55                   	push   %ebp
  801768:	89 e5                	mov    %esp,%ebp
  80176a:	53                   	push   %ebx
  80176b:	83 ec 24             	sub    $0x24,%esp
  80176e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801771:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801774:	89 44 24 04          	mov    %eax,0x4(%esp)
  801778:	89 1c 24             	mov    %ebx,(%esp)
  80177b:	e8 76 fc ff ff       	call   8013f6 <fd_lookup>
  801780:	89 c2                	mov    %eax,%edx
  801782:	85 d2                	test   %edx,%edx
  801784:	78 68                	js     8017ee <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801786:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801789:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801790:	8b 00                	mov    (%eax),%eax
  801792:	89 04 24             	mov    %eax,(%esp)
  801795:	e8 b2 fc ff ff       	call   80144c <dev_lookup>
  80179a:	85 c0                	test   %eax,%eax
  80179c:	78 50                	js     8017ee <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80179e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017a5:	75 23                	jne    8017ca <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017a7:	a1 18 50 80 00       	mov    0x805018,%eax
  8017ac:	8b 40 48             	mov    0x48(%eax),%eax
  8017af:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b7:	c7 04 24 29 2f 80 00 	movl   $0x802f29,(%esp)
  8017be:	e8 4e ee ff ff       	call   800611 <cprintf>
		return -E_INVAL;
  8017c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017c8:	eb 24                	jmp    8017ee <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017cd:	8b 52 0c             	mov    0xc(%edx),%edx
  8017d0:	85 d2                	test   %edx,%edx
  8017d2:	74 15                	je     8017e9 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017d7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017de:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017e2:	89 04 24             	mov    %eax,(%esp)
  8017e5:	ff d2                	call   *%edx
  8017e7:	eb 05                	jmp    8017ee <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8017ee:	83 c4 24             	add    $0x24,%esp
  8017f1:	5b                   	pop    %ebx
  8017f2:	5d                   	pop    %ebp
  8017f3:	c3                   	ret    

008017f4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017f4:	55                   	push   %ebp
  8017f5:	89 e5                	mov    %esp,%ebp
  8017f7:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017fa:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801801:	8b 45 08             	mov    0x8(%ebp),%eax
  801804:	89 04 24             	mov    %eax,(%esp)
  801807:	e8 ea fb ff ff       	call   8013f6 <fd_lookup>
  80180c:	85 c0                	test   %eax,%eax
  80180e:	78 0e                	js     80181e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801810:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801813:	8b 55 0c             	mov    0xc(%ebp),%edx
  801816:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801819:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80181e:	c9                   	leave  
  80181f:	c3                   	ret    

00801820 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	53                   	push   %ebx
  801824:	83 ec 24             	sub    $0x24,%esp
  801827:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80182a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80182d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801831:	89 1c 24             	mov    %ebx,(%esp)
  801834:	e8 bd fb ff ff       	call   8013f6 <fd_lookup>
  801839:	89 c2                	mov    %eax,%edx
  80183b:	85 d2                	test   %edx,%edx
  80183d:	78 61                	js     8018a0 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80183f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801842:	89 44 24 04          	mov    %eax,0x4(%esp)
  801846:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801849:	8b 00                	mov    (%eax),%eax
  80184b:	89 04 24             	mov    %eax,(%esp)
  80184e:	e8 f9 fb ff ff       	call   80144c <dev_lookup>
  801853:	85 c0                	test   %eax,%eax
  801855:	78 49                	js     8018a0 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801857:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80185a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80185e:	75 23                	jne    801883 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801860:	a1 18 50 80 00       	mov    0x805018,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801865:	8b 40 48             	mov    0x48(%eax),%eax
  801868:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80186c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801870:	c7 04 24 ec 2e 80 00 	movl   $0x802eec,(%esp)
  801877:	e8 95 ed ff ff       	call   800611 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80187c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801881:	eb 1d                	jmp    8018a0 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801883:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801886:	8b 52 18             	mov    0x18(%edx),%edx
  801889:	85 d2                	test   %edx,%edx
  80188b:	74 0e                	je     80189b <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80188d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801890:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801894:	89 04 24             	mov    %eax,(%esp)
  801897:	ff d2                	call   *%edx
  801899:	eb 05                	jmp    8018a0 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80189b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8018a0:	83 c4 24             	add    $0x24,%esp
  8018a3:	5b                   	pop    %ebx
  8018a4:	5d                   	pop    %ebp
  8018a5:	c3                   	ret    

008018a6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
  8018a9:	53                   	push   %ebx
  8018aa:	83 ec 24             	sub    $0x24,%esp
  8018ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ba:	89 04 24             	mov    %eax,(%esp)
  8018bd:	e8 34 fb ff ff       	call   8013f6 <fd_lookup>
  8018c2:	89 c2                	mov    %eax,%edx
  8018c4:	85 d2                	test   %edx,%edx
  8018c6:	78 52                	js     80191a <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d2:	8b 00                	mov    (%eax),%eax
  8018d4:	89 04 24             	mov    %eax,(%esp)
  8018d7:	e8 70 fb ff ff       	call   80144c <dev_lookup>
  8018dc:	85 c0                	test   %eax,%eax
  8018de:	78 3a                	js     80191a <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8018e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018e7:	74 2c                	je     801915 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018e9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018ec:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018f3:	00 00 00 
	stat->st_isdir = 0;
  8018f6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018fd:	00 00 00 
	stat->st_dev = dev;
  801900:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801906:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80190a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80190d:	89 14 24             	mov    %edx,(%esp)
  801910:	ff 50 14             	call   *0x14(%eax)
  801913:	eb 05                	jmp    80191a <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801915:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80191a:	83 c4 24             	add    $0x24,%esp
  80191d:	5b                   	pop    %ebx
  80191e:	5d                   	pop    %ebp
  80191f:	c3                   	ret    

00801920 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	56                   	push   %esi
  801924:	53                   	push   %ebx
  801925:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801928:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80192f:	00 
  801930:	8b 45 08             	mov    0x8(%ebp),%eax
  801933:	89 04 24             	mov    %eax,(%esp)
  801936:	e8 28 02 00 00       	call   801b63 <open>
  80193b:	89 c3                	mov    %eax,%ebx
  80193d:	85 db                	test   %ebx,%ebx
  80193f:	78 1b                	js     80195c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801941:	8b 45 0c             	mov    0xc(%ebp),%eax
  801944:	89 44 24 04          	mov    %eax,0x4(%esp)
  801948:	89 1c 24             	mov    %ebx,(%esp)
  80194b:	e8 56 ff ff ff       	call   8018a6 <fstat>
  801950:	89 c6                	mov    %eax,%esi
	close(fd);
  801952:	89 1c 24             	mov    %ebx,(%esp)
  801955:	e8 cd fb ff ff       	call   801527 <close>
	return r;
  80195a:	89 f0                	mov    %esi,%eax
}
  80195c:	83 c4 10             	add    $0x10,%esp
  80195f:	5b                   	pop    %ebx
  801960:	5e                   	pop    %esi
  801961:	5d                   	pop    %ebp
  801962:	c3                   	ret    

00801963 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801963:	55                   	push   %ebp
  801964:	89 e5                	mov    %esp,%ebp
  801966:	56                   	push   %esi
  801967:	53                   	push   %ebx
  801968:	83 ec 10             	sub    $0x10,%esp
  80196b:	89 c6                	mov    %eax,%esi
  80196d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80196f:	83 3d 10 50 80 00 00 	cmpl   $0x0,0x805010
  801976:	75 11                	jne    801989 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801978:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80197f:	e8 f1 0d 00 00       	call   802775 <ipc_find_env>
  801984:	a3 10 50 80 00       	mov    %eax,0x805010
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801989:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801990:	00 
  801991:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801998:	00 
  801999:	89 74 24 04          	mov    %esi,0x4(%esp)
  80199d:	a1 10 50 80 00       	mov    0x805010,%eax
  8019a2:	89 04 24             	mov    %eax,(%esp)
  8019a5:	e8 60 0d 00 00       	call   80270a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019aa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019b1:	00 
  8019b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019bd:	e8 ce 0c 00 00       	call   802690 <ipc_recv>
}
  8019c2:	83 c4 10             	add    $0x10,%esp
  8019c5:	5b                   	pop    %ebx
  8019c6:	5e                   	pop    %esi
  8019c7:	5d                   	pop    %ebp
  8019c8:	c3                   	ret    

008019c9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019c9:	55                   	push   %ebp
  8019ca:	89 e5                	mov    %esp,%ebp
  8019cc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d2:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d5:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8019da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019dd:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e7:	b8 02 00 00 00       	mov    $0x2,%eax
  8019ec:	e8 72 ff ff ff       	call   801963 <fsipc>
}
  8019f1:	c9                   	leave  
  8019f2:	c3                   	ret    

008019f3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019f3:	55                   	push   %ebp
  8019f4:	89 e5                	mov    %esp,%ebp
  8019f6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fc:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ff:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801a04:	ba 00 00 00 00       	mov    $0x0,%edx
  801a09:	b8 06 00 00 00       	mov    $0x6,%eax
  801a0e:	e8 50 ff ff ff       	call   801963 <fsipc>
}
  801a13:	c9                   	leave  
  801a14:	c3                   	ret    

00801a15 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a15:	55                   	push   %ebp
  801a16:	89 e5                	mov    %esp,%ebp
  801a18:	53                   	push   %ebx
  801a19:	83 ec 14             	sub    $0x14,%esp
  801a1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a22:	8b 40 0c             	mov    0xc(%eax),%eax
  801a25:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a2a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a2f:	b8 05 00 00 00       	mov    $0x5,%eax
  801a34:	e8 2a ff ff ff       	call   801963 <fsipc>
  801a39:	89 c2                	mov    %eax,%edx
  801a3b:	85 d2                	test   %edx,%edx
  801a3d:	78 2b                	js     801a6a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a3f:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801a46:	00 
  801a47:	89 1c 24             	mov    %ebx,(%esp)
  801a4a:	e8 e8 f1 ff ff       	call   800c37 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a4f:	a1 80 60 80 00       	mov    0x806080,%eax
  801a54:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a5a:	a1 84 60 80 00       	mov    0x806084,%eax
  801a5f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a65:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a6a:	83 c4 14             	add    $0x14,%esp
  801a6d:	5b                   	pop    %ebx
  801a6e:	5d                   	pop    %ebp
  801a6f:	c3                   	ret    

00801a70 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	83 ec 18             	sub    $0x18,%esp
  801a76:	8b 45 10             	mov    0x10(%ebp),%eax
  801a79:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a7e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a83:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a86:	8b 55 08             	mov    0x8(%ebp),%edx
  801a89:	8b 52 0c             	mov    0xc(%edx),%edx
  801a8c:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801a92:	a3 04 60 80 00       	mov    %eax,0x806004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801a97:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa2:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801aa9:	e8 26 f3 ff ff       	call   800dd4 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  801aae:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab3:	b8 04 00 00 00       	mov    $0x4,%eax
  801ab8:	e8 a6 fe ff ff       	call   801963 <fsipc>
}
  801abd:	c9                   	leave  
  801abe:	c3                   	ret    

00801abf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	56                   	push   %esi
  801ac3:	53                   	push   %ebx
  801ac4:	83 ec 10             	sub    $0x10,%esp
  801ac7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801aca:	8b 45 08             	mov    0x8(%ebp),%eax
  801acd:	8b 40 0c             	mov    0xc(%eax),%eax
  801ad0:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801ad5:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801adb:	ba 00 00 00 00       	mov    $0x0,%edx
  801ae0:	b8 03 00 00 00       	mov    $0x3,%eax
  801ae5:	e8 79 fe ff ff       	call   801963 <fsipc>
  801aea:	89 c3                	mov    %eax,%ebx
  801aec:	85 c0                	test   %eax,%eax
  801aee:	78 6a                	js     801b5a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801af0:	39 c6                	cmp    %eax,%esi
  801af2:	73 24                	jae    801b18 <devfile_read+0x59>
  801af4:	c7 44 24 0c 5c 2f 80 	movl   $0x802f5c,0xc(%esp)
  801afb:	00 
  801afc:	c7 44 24 08 63 2f 80 	movl   $0x802f63,0x8(%esp)
  801b03:	00 
  801b04:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801b0b:	00 
  801b0c:	c7 04 24 78 2f 80 00 	movl   $0x802f78,(%esp)
  801b13:	e8 1e 0b 00 00       	call   802636 <_panic>
	assert(r <= PGSIZE);
  801b18:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b1d:	7e 24                	jle    801b43 <devfile_read+0x84>
  801b1f:	c7 44 24 0c 83 2f 80 	movl   $0x802f83,0xc(%esp)
  801b26:	00 
  801b27:	c7 44 24 08 63 2f 80 	movl   $0x802f63,0x8(%esp)
  801b2e:	00 
  801b2f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801b36:	00 
  801b37:	c7 04 24 78 2f 80 00 	movl   $0x802f78,(%esp)
  801b3e:	e8 f3 0a 00 00       	call   802636 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b43:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b47:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801b4e:	00 
  801b4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b52:	89 04 24             	mov    %eax,(%esp)
  801b55:	e8 7a f2 ff ff       	call   800dd4 <memmove>
	return r;
}
  801b5a:	89 d8                	mov    %ebx,%eax
  801b5c:	83 c4 10             	add    $0x10,%esp
  801b5f:	5b                   	pop    %ebx
  801b60:	5e                   	pop    %esi
  801b61:	5d                   	pop    %ebp
  801b62:	c3                   	ret    

00801b63 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b63:	55                   	push   %ebp
  801b64:	89 e5                	mov    %esp,%ebp
  801b66:	53                   	push   %ebx
  801b67:	83 ec 24             	sub    $0x24,%esp
  801b6a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b6d:	89 1c 24             	mov    %ebx,(%esp)
  801b70:	e8 8b f0 ff ff       	call   800c00 <strlen>
  801b75:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b7a:	7f 60                	jg     801bdc <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b7f:	89 04 24             	mov    %eax,(%esp)
  801b82:	e8 20 f8 ff ff       	call   8013a7 <fd_alloc>
  801b87:	89 c2                	mov    %eax,%edx
  801b89:	85 d2                	test   %edx,%edx
  801b8b:	78 54                	js     801be1 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b8d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b91:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801b98:	e8 9a f0 ff ff       	call   800c37 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba0:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ba5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ba8:	b8 01 00 00 00       	mov    $0x1,%eax
  801bad:	e8 b1 fd ff ff       	call   801963 <fsipc>
  801bb2:	89 c3                	mov    %eax,%ebx
  801bb4:	85 c0                	test   %eax,%eax
  801bb6:	79 17                	jns    801bcf <open+0x6c>
		fd_close(fd, 0);
  801bb8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bbf:	00 
  801bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc3:	89 04 24             	mov    %eax,(%esp)
  801bc6:	e8 db f8 ff ff       	call   8014a6 <fd_close>
		return r;
  801bcb:	89 d8                	mov    %ebx,%eax
  801bcd:	eb 12                	jmp    801be1 <open+0x7e>
	}

	return fd2num(fd);
  801bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd2:	89 04 24             	mov    %eax,(%esp)
  801bd5:	e8 a6 f7 ff ff       	call   801380 <fd2num>
  801bda:	eb 05                	jmp    801be1 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bdc:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801be1:	83 c4 24             	add    $0x24,%esp
  801be4:	5b                   	pop    %ebx
  801be5:	5d                   	pop    %ebp
  801be6:	c3                   	ret    

00801be7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
  801bea:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bed:	ba 00 00 00 00       	mov    $0x0,%edx
  801bf2:	b8 08 00 00 00       	mov    $0x8,%eax
  801bf7:	e8 67 fd ff ff       	call   801963 <fsipc>
}
  801bfc:	c9                   	leave  
  801bfd:	c3                   	ret    
  801bfe:	66 90                	xchg   %ax,%ax

00801c00 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801c06:	c7 44 24 04 8f 2f 80 	movl   $0x802f8f,0x4(%esp)
  801c0d:	00 
  801c0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c11:	89 04 24             	mov    %eax,(%esp)
  801c14:	e8 1e f0 ff ff       	call   800c37 <strcpy>
	return 0;
}
  801c19:	b8 00 00 00 00       	mov    $0x0,%eax
  801c1e:	c9                   	leave  
  801c1f:	c3                   	ret    

00801c20 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	53                   	push   %ebx
  801c24:	83 ec 14             	sub    $0x14,%esp
  801c27:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c2a:	89 1c 24             	mov    %ebx,(%esp)
  801c2d:	e8 7b 0b 00 00       	call   8027ad <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801c32:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801c37:	83 f8 01             	cmp    $0x1,%eax
  801c3a:	75 0d                	jne    801c49 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801c3c:	8b 43 0c             	mov    0xc(%ebx),%eax
  801c3f:	89 04 24             	mov    %eax,(%esp)
  801c42:	e8 29 03 00 00       	call   801f70 <nsipc_close>
  801c47:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  801c49:	89 d0                	mov    %edx,%eax
  801c4b:	83 c4 14             	add    $0x14,%esp
  801c4e:	5b                   	pop    %ebx
  801c4f:	5d                   	pop    %ebp
  801c50:	c3                   	ret    

00801c51 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801c51:	55                   	push   %ebp
  801c52:	89 e5                	mov    %esp,%ebp
  801c54:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c57:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801c5e:	00 
  801c5f:	8b 45 10             	mov    0x10(%ebp),%eax
  801c62:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c66:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c69:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c70:	8b 40 0c             	mov    0xc(%eax),%eax
  801c73:	89 04 24             	mov    %eax,(%esp)
  801c76:	e8 f0 03 00 00       	call   80206b <nsipc_send>
}
  801c7b:	c9                   	leave  
  801c7c:	c3                   	ret    

00801c7d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801c7d:	55                   	push   %ebp
  801c7e:	89 e5                	mov    %esp,%ebp
  801c80:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801c83:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801c8a:	00 
  801c8b:	8b 45 10             	mov    0x10(%ebp),%eax
  801c8e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c92:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c95:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c99:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9c:	8b 40 0c             	mov    0xc(%eax),%eax
  801c9f:	89 04 24             	mov    %eax,(%esp)
  801ca2:	e8 44 03 00 00       	call   801feb <nsipc_recv>
}
  801ca7:	c9                   	leave  
  801ca8:	c3                   	ret    

00801ca9 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801ca9:	55                   	push   %ebp
  801caa:	89 e5                	mov    %esp,%ebp
  801cac:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801caf:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801cb2:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cb6:	89 04 24             	mov    %eax,(%esp)
  801cb9:	e8 38 f7 ff ff       	call   8013f6 <fd_lookup>
  801cbe:	85 c0                	test   %eax,%eax
  801cc0:	78 17                	js     801cd9 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801cc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc5:	8b 0d 24 40 80 00    	mov    0x804024,%ecx
  801ccb:	39 08                	cmp    %ecx,(%eax)
  801ccd:	75 05                	jne    801cd4 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801ccf:	8b 40 0c             	mov    0xc(%eax),%eax
  801cd2:	eb 05                	jmp    801cd9 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801cd4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801cd9:	c9                   	leave  
  801cda:	c3                   	ret    

00801cdb <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801cdb:	55                   	push   %ebp
  801cdc:	89 e5                	mov    %esp,%ebp
  801cde:	56                   	push   %esi
  801cdf:	53                   	push   %ebx
  801ce0:	83 ec 20             	sub    $0x20,%esp
  801ce3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801ce5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce8:	89 04 24             	mov    %eax,(%esp)
  801ceb:	e8 b7 f6 ff ff       	call   8013a7 <fd_alloc>
  801cf0:	89 c3                	mov    %eax,%ebx
  801cf2:	85 c0                	test   %eax,%eax
  801cf4:	78 21                	js     801d17 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801cf6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801cfd:	00 
  801cfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d01:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d0c:	e8 42 f3 ff ff       	call   801053 <sys_page_alloc>
  801d11:	89 c3                	mov    %eax,%ebx
  801d13:	85 c0                	test   %eax,%eax
  801d15:	79 0c                	jns    801d23 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  801d17:	89 34 24             	mov    %esi,(%esp)
  801d1a:	e8 51 02 00 00       	call   801f70 <nsipc_close>
		return r;
  801d1f:	89 d8                	mov    %ebx,%eax
  801d21:	eb 20                	jmp    801d43 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d23:	8b 15 24 40 80 00    	mov    0x804024,%edx
  801d29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d31:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801d38:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801d3b:	89 14 24             	mov    %edx,(%esp)
  801d3e:	e8 3d f6 ff ff       	call   801380 <fd2num>
}
  801d43:	83 c4 20             	add    $0x20,%esp
  801d46:	5b                   	pop    %ebx
  801d47:	5e                   	pop    %esi
  801d48:	5d                   	pop    %ebp
  801d49:	c3                   	ret    

00801d4a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d4a:	55                   	push   %ebp
  801d4b:	89 e5                	mov    %esp,%ebp
  801d4d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d50:	8b 45 08             	mov    0x8(%ebp),%eax
  801d53:	e8 51 ff ff ff       	call   801ca9 <fd2sockid>
		return r;
  801d58:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d5a:	85 c0                	test   %eax,%eax
  801d5c:	78 23                	js     801d81 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d5e:	8b 55 10             	mov    0x10(%ebp),%edx
  801d61:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d65:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d68:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d6c:	89 04 24             	mov    %eax,(%esp)
  801d6f:	e8 45 01 00 00       	call   801eb9 <nsipc_accept>
		return r;
  801d74:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d76:	85 c0                	test   %eax,%eax
  801d78:	78 07                	js     801d81 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  801d7a:	e8 5c ff ff ff       	call   801cdb <alloc_sockfd>
  801d7f:	89 c1                	mov    %eax,%ecx
}
  801d81:	89 c8                	mov    %ecx,%eax
  801d83:	c9                   	leave  
  801d84:	c3                   	ret    

00801d85 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d85:	55                   	push   %ebp
  801d86:	89 e5                	mov    %esp,%ebp
  801d88:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8e:	e8 16 ff ff ff       	call   801ca9 <fd2sockid>
  801d93:	89 c2                	mov    %eax,%edx
  801d95:	85 d2                	test   %edx,%edx
  801d97:	78 16                	js     801daf <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  801d99:	8b 45 10             	mov    0x10(%ebp),%eax
  801d9c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801da0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801da3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801da7:	89 14 24             	mov    %edx,(%esp)
  801daa:	e8 60 01 00 00       	call   801f0f <nsipc_bind>
}
  801daf:	c9                   	leave  
  801db0:	c3                   	ret    

00801db1 <shutdown>:

int
shutdown(int s, int how)
{
  801db1:	55                   	push   %ebp
  801db2:	89 e5                	mov    %esp,%ebp
  801db4:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801db7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dba:	e8 ea fe ff ff       	call   801ca9 <fd2sockid>
  801dbf:	89 c2                	mov    %eax,%edx
  801dc1:	85 d2                	test   %edx,%edx
  801dc3:	78 0f                	js     801dd4 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801dc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dcc:	89 14 24             	mov    %edx,(%esp)
  801dcf:	e8 7a 01 00 00       	call   801f4e <nsipc_shutdown>
}
  801dd4:	c9                   	leave  
  801dd5:	c3                   	ret    

00801dd6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
  801dd9:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ddc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddf:	e8 c5 fe ff ff       	call   801ca9 <fd2sockid>
  801de4:	89 c2                	mov    %eax,%edx
  801de6:	85 d2                	test   %edx,%edx
  801de8:	78 16                	js     801e00 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  801dea:	8b 45 10             	mov    0x10(%ebp),%eax
  801ded:	89 44 24 08          	mov    %eax,0x8(%esp)
  801df1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801df8:	89 14 24             	mov    %edx,(%esp)
  801dfb:	e8 8a 01 00 00       	call   801f8a <nsipc_connect>
}
  801e00:	c9                   	leave  
  801e01:	c3                   	ret    

00801e02 <listen>:

int
listen(int s, int backlog)
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e08:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0b:	e8 99 fe ff ff       	call   801ca9 <fd2sockid>
  801e10:	89 c2                	mov    %eax,%edx
  801e12:	85 d2                	test   %edx,%edx
  801e14:	78 0f                	js     801e25 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801e16:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e19:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e1d:	89 14 24             	mov    %edx,(%esp)
  801e20:	e8 a4 01 00 00       	call   801fc9 <nsipc_listen>
}
  801e25:	c9                   	leave  
  801e26:	c3                   	ret    

00801e27 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e27:	55                   	push   %ebp
  801e28:	89 e5                	mov    %esp,%ebp
  801e2a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e2d:	8b 45 10             	mov    0x10(%ebp),%eax
  801e30:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3e:	89 04 24             	mov    %eax,(%esp)
  801e41:	e8 98 02 00 00       	call   8020de <nsipc_socket>
  801e46:	89 c2                	mov    %eax,%edx
  801e48:	85 d2                	test   %edx,%edx
  801e4a:	78 05                	js     801e51 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  801e4c:	e8 8a fe ff ff       	call   801cdb <alloc_sockfd>
}
  801e51:	c9                   	leave  
  801e52:	c3                   	ret    

00801e53 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e53:	55                   	push   %ebp
  801e54:	89 e5                	mov    %esp,%ebp
  801e56:	53                   	push   %ebx
  801e57:	83 ec 14             	sub    $0x14,%esp
  801e5a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801e5c:	83 3d 14 50 80 00 00 	cmpl   $0x0,0x805014
  801e63:	75 11                	jne    801e76 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e65:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801e6c:	e8 04 09 00 00       	call   802775 <ipc_find_env>
  801e71:	a3 14 50 80 00       	mov    %eax,0x805014
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801e76:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801e7d:	00 
  801e7e:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801e85:	00 
  801e86:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e8a:	a1 14 50 80 00       	mov    0x805014,%eax
  801e8f:	89 04 24             	mov    %eax,(%esp)
  801e92:	e8 73 08 00 00       	call   80270a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801e97:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e9e:	00 
  801e9f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ea6:	00 
  801ea7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eae:	e8 dd 07 00 00       	call   802690 <ipc_recv>
}
  801eb3:	83 c4 14             	add    $0x14,%esp
  801eb6:	5b                   	pop    %ebx
  801eb7:	5d                   	pop    %ebp
  801eb8:	c3                   	ret    

00801eb9 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801eb9:	55                   	push   %ebp
  801eba:	89 e5                	mov    %esp,%ebp
  801ebc:	56                   	push   %esi
  801ebd:	53                   	push   %ebx
  801ebe:	83 ec 10             	sub    $0x10,%esp
  801ec1:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ec4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ecc:	8b 06                	mov    (%esi),%eax
  801ece:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ed3:	b8 01 00 00 00       	mov    $0x1,%eax
  801ed8:	e8 76 ff ff ff       	call   801e53 <nsipc>
  801edd:	89 c3                	mov    %eax,%ebx
  801edf:	85 c0                	test   %eax,%eax
  801ee1:	78 23                	js     801f06 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801ee3:	a1 10 70 80 00       	mov    0x807010,%eax
  801ee8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eec:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801ef3:	00 
  801ef4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef7:	89 04 24             	mov    %eax,(%esp)
  801efa:	e8 d5 ee ff ff       	call   800dd4 <memmove>
		*addrlen = ret->ret_addrlen;
  801eff:	a1 10 70 80 00       	mov    0x807010,%eax
  801f04:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801f06:	89 d8                	mov    %ebx,%eax
  801f08:	83 c4 10             	add    $0x10,%esp
  801f0b:	5b                   	pop    %ebx
  801f0c:	5e                   	pop    %esi
  801f0d:	5d                   	pop    %ebp
  801f0e:	c3                   	ret    

00801f0f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f0f:	55                   	push   %ebp
  801f10:	89 e5                	mov    %esp,%ebp
  801f12:	53                   	push   %ebx
  801f13:	83 ec 14             	sub    $0x14,%esp
  801f16:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f19:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1c:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f21:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f25:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f28:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f2c:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  801f33:	e8 9c ee ff ff       	call   800dd4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f38:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801f3e:	b8 02 00 00 00       	mov    $0x2,%eax
  801f43:	e8 0b ff ff ff       	call   801e53 <nsipc>
}
  801f48:	83 c4 14             	add    $0x14,%esp
  801f4b:	5b                   	pop    %ebx
  801f4c:	5d                   	pop    %ebp
  801f4d:	c3                   	ret    

00801f4e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f4e:	55                   	push   %ebp
  801f4f:	89 e5                	mov    %esp,%ebp
  801f51:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f54:	8b 45 08             	mov    0x8(%ebp),%eax
  801f57:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801f5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f5f:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801f64:	b8 03 00 00 00       	mov    $0x3,%eax
  801f69:	e8 e5 fe ff ff       	call   801e53 <nsipc>
}
  801f6e:	c9                   	leave  
  801f6f:	c3                   	ret    

00801f70 <nsipc_close>:

int
nsipc_close(int s)
{
  801f70:	55                   	push   %ebp
  801f71:	89 e5                	mov    %esp,%ebp
  801f73:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801f76:	8b 45 08             	mov    0x8(%ebp),%eax
  801f79:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801f7e:	b8 04 00 00 00       	mov    $0x4,%eax
  801f83:	e8 cb fe ff ff       	call   801e53 <nsipc>
}
  801f88:	c9                   	leave  
  801f89:	c3                   	ret    

00801f8a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f8a:	55                   	push   %ebp
  801f8b:	89 e5                	mov    %esp,%ebp
  801f8d:	53                   	push   %ebx
  801f8e:	83 ec 14             	sub    $0x14,%esp
  801f91:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801f94:	8b 45 08             	mov    0x8(%ebp),%eax
  801f97:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801f9c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fa0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa7:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  801fae:	e8 21 ee ff ff       	call   800dd4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801fb3:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801fb9:	b8 05 00 00 00       	mov    $0x5,%eax
  801fbe:	e8 90 fe ff ff       	call   801e53 <nsipc>
}
  801fc3:	83 c4 14             	add    $0x14,%esp
  801fc6:	5b                   	pop    %ebx
  801fc7:	5d                   	pop    %ebp
  801fc8:	c3                   	ret    

00801fc9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801fc9:	55                   	push   %ebp
  801fca:	89 e5                	mov    %esp,%ebp
  801fcc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801fcf:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801fd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fda:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801fdf:	b8 06 00 00 00       	mov    $0x6,%eax
  801fe4:	e8 6a fe ff ff       	call   801e53 <nsipc>
}
  801fe9:	c9                   	leave  
  801fea:	c3                   	ret    

00801feb <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801feb:	55                   	push   %ebp
  801fec:	89 e5                	mov    %esp,%ebp
  801fee:	56                   	push   %esi
  801fef:	53                   	push   %ebx
  801ff0:	83 ec 10             	sub    $0x10,%esp
  801ff3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801ff6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801ffe:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802004:	8b 45 14             	mov    0x14(%ebp),%eax
  802007:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80200c:	b8 07 00 00 00       	mov    $0x7,%eax
  802011:	e8 3d fe ff ff       	call   801e53 <nsipc>
  802016:	89 c3                	mov    %eax,%ebx
  802018:	85 c0                	test   %eax,%eax
  80201a:	78 46                	js     802062 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  80201c:	39 f0                	cmp    %esi,%eax
  80201e:	7f 07                	jg     802027 <nsipc_recv+0x3c>
  802020:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802025:	7e 24                	jle    80204b <nsipc_recv+0x60>
  802027:	c7 44 24 0c 9b 2f 80 	movl   $0x802f9b,0xc(%esp)
  80202e:	00 
  80202f:	c7 44 24 08 63 2f 80 	movl   $0x802f63,0x8(%esp)
  802036:	00 
  802037:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80203e:	00 
  80203f:	c7 04 24 b0 2f 80 00 	movl   $0x802fb0,(%esp)
  802046:	e8 eb 05 00 00       	call   802636 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80204b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80204f:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802056:	00 
  802057:	8b 45 0c             	mov    0xc(%ebp),%eax
  80205a:	89 04 24             	mov    %eax,(%esp)
  80205d:	e8 72 ed ff ff       	call   800dd4 <memmove>
	}

	return r;
}
  802062:	89 d8                	mov    %ebx,%eax
  802064:	83 c4 10             	add    $0x10,%esp
  802067:	5b                   	pop    %ebx
  802068:	5e                   	pop    %esi
  802069:	5d                   	pop    %ebp
  80206a:	c3                   	ret    

0080206b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80206b:	55                   	push   %ebp
  80206c:	89 e5                	mov    %esp,%ebp
  80206e:	53                   	push   %ebx
  80206f:	83 ec 14             	sub    $0x14,%esp
  802072:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802075:	8b 45 08             	mov    0x8(%ebp),%eax
  802078:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  80207d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802083:	7e 24                	jle    8020a9 <nsipc_send+0x3e>
  802085:	c7 44 24 0c bc 2f 80 	movl   $0x802fbc,0xc(%esp)
  80208c:	00 
  80208d:	c7 44 24 08 63 2f 80 	movl   $0x802f63,0x8(%esp)
  802094:	00 
  802095:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  80209c:	00 
  80209d:	c7 04 24 b0 2f 80 00 	movl   $0x802fb0,(%esp)
  8020a4:	e8 8d 05 00 00       	call   802636 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8020a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020b4:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  8020bb:	e8 14 ed ff ff       	call   800dd4 <memmove>
	nsipcbuf.send.req_size = size;
  8020c0:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8020c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8020c9:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8020ce:	b8 08 00 00 00       	mov    $0x8,%eax
  8020d3:	e8 7b fd ff ff       	call   801e53 <nsipc>
}
  8020d8:	83 c4 14             	add    $0x14,%esp
  8020db:	5b                   	pop    %ebx
  8020dc:	5d                   	pop    %ebp
  8020dd:	c3                   	ret    

008020de <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8020de:	55                   	push   %ebp
  8020df:	89 e5                	mov    %esp,%ebp
  8020e1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8020e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8020ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ef:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8020f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8020f7:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8020fc:	b8 09 00 00 00       	mov    $0x9,%eax
  802101:	e8 4d fd ff ff       	call   801e53 <nsipc>
}
  802106:	c9                   	leave  
  802107:	c3                   	ret    

00802108 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802108:	55                   	push   %ebp
  802109:	89 e5                	mov    %esp,%ebp
  80210b:	56                   	push   %esi
  80210c:	53                   	push   %ebx
  80210d:	83 ec 10             	sub    $0x10,%esp
  802110:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802113:	8b 45 08             	mov    0x8(%ebp),%eax
  802116:	89 04 24             	mov    %eax,(%esp)
  802119:	e8 72 f2 ff ff       	call   801390 <fd2data>
  80211e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802120:	c7 44 24 04 c8 2f 80 	movl   $0x802fc8,0x4(%esp)
  802127:	00 
  802128:	89 1c 24             	mov    %ebx,(%esp)
  80212b:	e8 07 eb ff ff       	call   800c37 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802130:	8b 46 04             	mov    0x4(%esi),%eax
  802133:	2b 06                	sub    (%esi),%eax
  802135:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80213b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802142:	00 00 00 
	stat->st_dev = &devpipe;
  802145:	c7 83 88 00 00 00 40 	movl   $0x804040,0x88(%ebx)
  80214c:	40 80 00 
	return 0;
}
  80214f:	b8 00 00 00 00       	mov    $0x0,%eax
  802154:	83 c4 10             	add    $0x10,%esp
  802157:	5b                   	pop    %ebx
  802158:	5e                   	pop    %esi
  802159:	5d                   	pop    %ebp
  80215a:	c3                   	ret    

0080215b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80215b:	55                   	push   %ebp
  80215c:	89 e5                	mov    %esp,%ebp
  80215e:	53                   	push   %ebx
  80215f:	83 ec 14             	sub    $0x14,%esp
  802162:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802165:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802169:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802170:	e8 85 ef ff ff       	call   8010fa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802175:	89 1c 24             	mov    %ebx,(%esp)
  802178:	e8 13 f2 ff ff       	call   801390 <fd2data>
  80217d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802181:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802188:	e8 6d ef ff ff       	call   8010fa <sys_page_unmap>
}
  80218d:	83 c4 14             	add    $0x14,%esp
  802190:	5b                   	pop    %ebx
  802191:	5d                   	pop    %ebp
  802192:	c3                   	ret    

00802193 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802193:	55                   	push   %ebp
  802194:	89 e5                	mov    %esp,%ebp
  802196:	57                   	push   %edi
  802197:	56                   	push   %esi
  802198:	53                   	push   %ebx
  802199:	83 ec 2c             	sub    $0x2c,%esp
  80219c:	89 c6                	mov    %eax,%esi
  80219e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8021a1:	a1 18 50 80 00       	mov    0x805018,%eax
  8021a6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8021a9:	89 34 24             	mov    %esi,(%esp)
  8021ac:	e8 fc 05 00 00       	call   8027ad <pageref>
  8021b1:	89 c7                	mov    %eax,%edi
  8021b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021b6:	89 04 24             	mov    %eax,(%esp)
  8021b9:	e8 ef 05 00 00       	call   8027ad <pageref>
  8021be:	39 c7                	cmp    %eax,%edi
  8021c0:	0f 94 c2             	sete   %dl
  8021c3:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8021c6:	8b 0d 18 50 80 00    	mov    0x805018,%ecx
  8021cc:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8021cf:	39 fb                	cmp    %edi,%ebx
  8021d1:	74 21                	je     8021f4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8021d3:	84 d2                	test   %dl,%dl
  8021d5:	74 ca                	je     8021a1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8021d7:	8b 51 58             	mov    0x58(%ecx),%edx
  8021da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021de:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021e6:	c7 04 24 cf 2f 80 00 	movl   $0x802fcf,(%esp)
  8021ed:	e8 1f e4 ff ff       	call   800611 <cprintf>
  8021f2:	eb ad                	jmp    8021a1 <_pipeisclosed+0xe>
	}
}
  8021f4:	83 c4 2c             	add    $0x2c,%esp
  8021f7:	5b                   	pop    %ebx
  8021f8:	5e                   	pop    %esi
  8021f9:	5f                   	pop    %edi
  8021fa:	5d                   	pop    %ebp
  8021fb:	c3                   	ret    

008021fc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021fc:	55                   	push   %ebp
  8021fd:	89 e5                	mov    %esp,%ebp
  8021ff:	57                   	push   %edi
  802200:	56                   	push   %esi
  802201:	53                   	push   %ebx
  802202:	83 ec 1c             	sub    $0x1c,%esp
  802205:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802208:	89 34 24             	mov    %esi,(%esp)
  80220b:	e8 80 f1 ff ff       	call   801390 <fd2data>
  802210:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802212:	bf 00 00 00 00       	mov    $0x0,%edi
  802217:	eb 45                	jmp    80225e <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802219:	89 da                	mov    %ebx,%edx
  80221b:	89 f0                	mov    %esi,%eax
  80221d:	e8 71 ff ff ff       	call   802193 <_pipeisclosed>
  802222:	85 c0                	test   %eax,%eax
  802224:	75 41                	jne    802267 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802226:	e8 09 ee ff ff       	call   801034 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80222b:	8b 43 04             	mov    0x4(%ebx),%eax
  80222e:	8b 0b                	mov    (%ebx),%ecx
  802230:	8d 51 20             	lea    0x20(%ecx),%edx
  802233:	39 d0                	cmp    %edx,%eax
  802235:	73 e2                	jae    802219 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802237:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80223a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80223e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802241:	99                   	cltd   
  802242:	c1 ea 1b             	shr    $0x1b,%edx
  802245:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802248:	83 e1 1f             	and    $0x1f,%ecx
  80224b:	29 d1                	sub    %edx,%ecx
  80224d:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  802251:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  802255:	83 c0 01             	add    $0x1,%eax
  802258:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80225b:	83 c7 01             	add    $0x1,%edi
  80225e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802261:	75 c8                	jne    80222b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802263:	89 f8                	mov    %edi,%eax
  802265:	eb 05                	jmp    80226c <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802267:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80226c:	83 c4 1c             	add    $0x1c,%esp
  80226f:	5b                   	pop    %ebx
  802270:	5e                   	pop    %esi
  802271:	5f                   	pop    %edi
  802272:	5d                   	pop    %ebp
  802273:	c3                   	ret    

00802274 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802274:	55                   	push   %ebp
  802275:	89 e5                	mov    %esp,%ebp
  802277:	57                   	push   %edi
  802278:	56                   	push   %esi
  802279:	53                   	push   %ebx
  80227a:	83 ec 1c             	sub    $0x1c,%esp
  80227d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802280:	89 3c 24             	mov    %edi,(%esp)
  802283:	e8 08 f1 ff ff       	call   801390 <fd2data>
  802288:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80228a:	be 00 00 00 00       	mov    $0x0,%esi
  80228f:	eb 3d                	jmp    8022ce <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802291:	85 f6                	test   %esi,%esi
  802293:	74 04                	je     802299 <devpipe_read+0x25>
				return i;
  802295:	89 f0                	mov    %esi,%eax
  802297:	eb 43                	jmp    8022dc <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802299:	89 da                	mov    %ebx,%edx
  80229b:	89 f8                	mov    %edi,%eax
  80229d:	e8 f1 fe ff ff       	call   802193 <_pipeisclosed>
  8022a2:	85 c0                	test   %eax,%eax
  8022a4:	75 31                	jne    8022d7 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8022a6:	e8 89 ed ff ff       	call   801034 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8022ab:	8b 03                	mov    (%ebx),%eax
  8022ad:	3b 43 04             	cmp    0x4(%ebx),%eax
  8022b0:	74 df                	je     802291 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8022b2:	99                   	cltd   
  8022b3:	c1 ea 1b             	shr    $0x1b,%edx
  8022b6:	01 d0                	add    %edx,%eax
  8022b8:	83 e0 1f             	and    $0x1f,%eax
  8022bb:	29 d0                	sub    %edx,%eax
  8022bd:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8022c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022c5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8022c8:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022cb:	83 c6 01             	add    $0x1,%esi
  8022ce:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022d1:	75 d8                	jne    8022ab <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8022d3:	89 f0                	mov    %esi,%eax
  8022d5:	eb 05                	jmp    8022dc <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022d7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8022dc:	83 c4 1c             	add    $0x1c,%esp
  8022df:	5b                   	pop    %ebx
  8022e0:	5e                   	pop    %esi
  8022e1:	5f                   	pop    %edi
  8022e2:	5d                   	pop    %ebp
  8022e3:	c3                   	ret    

008022e4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8022e4:	55                   	push   %ebp
  8022e5:	89 e5                	mov    %esp,%ebp
  8022e7:	56                   	push   %esi
  8022e8:	53                   	push   %ebx
  8022e9:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8022ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022ef:	89 04 24             	mov    %eax,(%esp)
  8022f2:	e8 b0 f0 ff ff       	call   8013a7 <fd_alloc>
  8022f7:	89 c2                	mov    %eax,%edx
  8022f9:	85 d2                	test   %edx,%edx
  8022fb:	0f 88 4d 01 00 00    	js     80244e <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802301:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802308:	00 
  802309:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80230c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802310:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802317:	e8 37 ed ff ff       	call   801053 <sys_page_alloc>
  80231c:	89 c2                	mov    %eax,%edx
  80231e:	85 d2                	test   %edx,%edx
  802320:	0f 88 28 01 00 00    	js     80244e <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802326:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802329:	89 04 24             	mov    %eax,(%esp)
  80232c:	e8 76 f0 ff ff       	call   8013a7 <fd_alloc>
  802331:	89 c3                	mov    %eax,%ebx
  802333:	85 c0                	test   %eax,%eax
  802335:	0f 88 fe 00 00 00    	js     802439 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80233b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802342:	00 
  802343:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802346:	89 44 24 04          	mov    %eax,0x4(%esp)
  80234a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802351:	e8 fd ec ff ff       	call   801053 <sys_page_alloc>
  802356:	89 c3                	mov    %eax,%ebx
  802358:	85 c0                	test   %eax,%eax
  80235a:	0f 88 d9 00 00 00    	js     802439 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802360:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802363:	89 04 24             	mov    %eax,(%esp)
  802366:	e8 25 f0 ff ff       	call   801390 <fd2data>
  80236b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80236d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802374:	00 
  802375:	89 44 24 04          	mov    %eax,0x4(%esp)
  802379:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802380:	e8 ce ec ff ff       	call   801053 <sys_page_alloc>
  802385:	89 c3                	mov    %eax,%ebx
  802387:	85 c0                	test   %eax,%eax
  802389:	0f 88 97 00 00 00    	js     802426 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80238f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802392:	89 04 24             	mov    %eax,(%esp)
  802395:	e8 f6 ef ff ff       	call   801390 <fd2data>
  80239a:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8023a1:	00 
  8023a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023a6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8023ad:	00 
  8023ae:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023b9:	e8 e9 ec ff ff       	call   8010a7 <sys_page_map>
  8023be:	89 c3                	mov    %eax,%ebx
  8023c0:	85 c0                	test   %eax,%eax
  8023c2:	78 52                	js     802416 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8023c4:	8b 15 40 40 80 00    	mov    0x804040,%edx
  8023ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023cd:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8023cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023d2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8023d9:	8b 15 40 40 80 00    	mov    0x804040,%edx
  8023df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023e2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8023e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023e7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8023ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023f1:	89 04 24             	mov    %eax,(%esp)
  8023f4:	e8 87 ef ff ff       	call   801380 <fd2num>
  8023f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023fc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8023fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802401:	89 04 24             	mov    %eax,(%esp)
  802404:	e8 77 ef ff ff       	call   801380 <fd2num>
  802409:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80240c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80240f:	b8 00 00 00 00       	mov    $0x0,%eax
  802414:	eb 38                	jmp    80244e <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  802416:	89 74 24 04          	mov    %esi,0x4(%esp)
  80241a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802421:	e8 d4 ec ff ff       	call   8010fa <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802426:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802429:	89 44 24 04          	mov    %eax,0x4(%esp)
  80242d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802434:	e8 c1 ec ff ff       	call   8010fa <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802439:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80243c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802440:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802447:	e8 ae ec ff ff       	call   8010fa <sys_page_unmap>
  80244c:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  80244e:	83 c4 30             	add    $0x30,%esp
  802451:	5b                   	pop    %ebx
  802452:	5e                   	pop    %esi
  802453:	5d                   	pop    %ebp
  802454:	c3                   	ret    

00802455 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802455:	55                   	push   %ebp
  802456:	89 e5                	mov    %esp,%ebp
  802458:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80245b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80245e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802462:	8b 45 08             	mov    0x8(%ebp),%eax
  802465:	89 04 24             	mov    %eax,(%esp)
  802468:	e8 89 ef ff ff       	call   8013f6 <fd_lookup>
  80246d:	89 c2                	mov    %eax,%edx
  80246f:	85 d2                	test   %edx,%edx
  802471:	78 15                	js     802488 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802473:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802476:	89 04 24             	mov    %eax,(%esp)
  802479:	e8 12 ef ff ff       	call   801390 <fd2data>
	return _pipeisclosed(fd, p);
  80247e:	89 c2                	mov    %eax,%edx
  802480:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802483:	e8 0b fd ff ff       	call   802193 <_pipeisclosed>
}
  802488:	c9                   	leave  
  802489:	c3                   	ret    
  80248a:	66 90                	xchg   %ax,%ax
  80248c:	66 90                	xchg   %ax,%ax
  80248e:	66 90                	xchg   %ax,%ax

00802490 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802490:	55                   	push   %ebp
  802491:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802493:	b8 00 00 00 00       	mov    $0x0,%eax
  802498:	5d                   	pop    %ebp
  802499:	c3                   	ret    

0080249a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80249a:	55                   	push   %ebp
  80249b:	89 e5                	mov    %esp,%ebp
  80249d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8024a0:	c7 44 24 04 e7 2f 80 	movl   $0x802fe7,0x4(%esp)
  8024a7:	00 
  8024a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024ab:	89 04 24             	mov    %eax,(%esp)
  8024ae:	e8 84 e7 ff ff       	call   800c37 <strcpy>
	return 0;
}
  8024b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8024b8:	c9                   	leave  
  8024b9:	c3                   	ret    

008024ba <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8024ba:	55                   	push   %ebp
  8024bb:	89 e5                	mov    %esp,%ebp
  8024bd:	57                   	push   %edi
  8024be:	56                   	push   %esi
  8024bf:	53                   	push   %ebx
  8024c0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024c6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8024cb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024d1:	eb 31                	jmp    802504 <devcons_write+0x4a>
		m = n - tot;
  8024d3:	8b 75 10             	mov    0x10(%ebp),%esi
  8024d6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8024d8:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8024db:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8024e0:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8024e3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8024e7:	03 45 0c             	add    0xc(%ebp),%eax
  8024ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024ee:	89 3c 24             	mov    %edi,(%esp)
  8024f1:	e8 de e8 ff ff       	call   800dd4 <memmove>
		sys_cputs(buf, m);
  8024f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024fa:	89 3c 24             	mov    %edi,(%esp)
  8024fd:	e8 84 ea ff ff       	call   800f86 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802502:	01 f3                	add    %esi,%ebx
  802504:	89 d8                	mov    %ebx,%eax
  802506:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802509:	72 c8                	jb     8024d3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80250b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802511:	5b                   	pop    %ebx
  802512:	5e                   	pop    %esi
  802513:	5f                   	pop    %edi
  802514:	5d                   	pop    %ebp
  802515:	c3                   	ret    

00802516 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802516:	55                   	push   %ebp
  802517:	89 e5                	mov    %esp,%ebp
  802519:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80251c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802521:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802525:	75 07                	jne    80252e <devcons_read+0x18>
  802527:	eb 2a                	jmp    802553 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802529:	e8 06 eb ff ff       	call   801034 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80252e:	66 90                	xchg   %ax,%ax
  802530:	e8 6f ea ff ff       	call   800fa4 <sys_cgetc>
  802535:	85 c0                	test   %eax,%eax
  802537:	74 f0                	je     802529 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802539:	85 c0                	test   %eax,%eax
  80253b:	78 16                	js     802553 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80253d:	83 f8 04             	cmp    $0x4,%eax
  802540:	74 0c                	je     80254e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802542:	8b 55 0c             	mov    0xc(%ebp),%edx
  802545:	88 02                	mov    %al,(%edx)
	return 1;
  802547:	b8 01 00 00 00       	mov    $0x1,%eax
  80254c:	eb 05                	jmp    802553 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80254e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802553:	c9                   	leave  
  802554:	c3                   	ret    

00802555 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802555:	55                   	push   %ebp
  802556:	89 e5                	mov    %esp,%ebp
  802558:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80255b:	8b 45 08             	mov    0x8(%ebp),%eax
  80255e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802561:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802568:	00 
  802569:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80256c:	89 04 24             	mov    %eax,(%esp)
  80256f:	e8 12 ea ff ff       	call   800f86 <sys_cputs>
}
  802574:	c9                   	leave  
  802575:	c3                   	ret    

00802576 <getchar>:

int
getchar(void)
{
  802576:	55                   	push   %ebp
  802577:	89 e5                	mov    %esp,%ebp
  802579:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80257c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802583:	00 
  802584:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802587:	89 44 24 04          	mov    %eax,0x4(%esp)
  80258b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802592:	e8 f3 f0 ff ff       	call   80168a <read>
	if (r < 0)
  802597:	85 c0                	test   %eax,%eax
  802599:	78 0f                	js     8025aa <getchar+0x34>
		return r;
	if (r < 1)
  80259b:	85 c0                	test   %eax,%eax
  80259d:	7e 06                	jle    8025a5 <getchar+0x2f>
		return -E_EOF;
	return c;
  80259f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8025a3:	eb 05                	jmp    8025aa <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8025a5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8025aa:	c9                   	leave  
  8025ab:	c3                   	ret    

008025ac <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8025ac:	55                   	push   %ebp
  8025ad:	89 e5                	mov    %esp,%ebp
  8025af:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8025bc:	89 04 24             	mov    %eax,(%esp)
  8025bf:	e8 32 ee ff ff       	call   8013f6 <fd_lookup>
  8025c4:	85 c0                	test   %eax,%eax
  8025c6:	78 11                	js     8025d9 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8025c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025cb:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  8025d1:	39 10                	cmp    %edx,(%eax)
  8025d3:	0f 94 c0             	sete   %al
  8025d6:	0f b6 c0             	movzbl %al,%eax
}
  8025d9:	c9                   	leave  
  8025da:	c3                   	ret    

008025db <opencons>:

int
opencons(void)
{
  8025db:	55                   	push   %ebp
  8025dc:	89 e5                	mov    %esp,%ebp
  8025de:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8025e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025e4:	89 04 24             	mov    %eax,(%esp)
  8025e7:	e8 bb ed ff ff       	call   8013a7 <fd_alloc>
		return r;
  8025ec:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8025ee:	85 c0                	test   %eax,%eax
  8025f0:	78 40                	js     802632 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8025f2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8025f9:	00 
  8025fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  802601:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802608:	e8 46 ea ff ff       	call   801053 <sys_page_alloc>
		return r;
  80260d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80260f:	85 c0                	test   %eax,%eax
  802611:	78 1f                	js     802632 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802613:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  802619:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80261c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80261e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802621:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802628:	89 04 24             	mov    %eax,(%esp)
  80262b:	e8 50 ed ff ff       	call   801380 <fd2num>
  802630:	89 c2                	mov    %eax,%edx
}
  802632:	89 d0                	mov    %edx,%eax
  802634:	c9                   	leave  
  802635:	c3                   	ret    

00802636 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802636:	55                   	push   %ebp
  802637:	89 e5                	mov    %esp,%ebp
  802639:	56                   	push   %esi
  80263a:	53                   	push   %ebx
  80263b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80263e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802641:	8b 35 04 40 80 00    	mov    0x804004,%esi
  802647:	e8 c9 e9 ff ff       	call   801015 <sys_getenvid>
  80264c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80264f:	89 54 24 10          	mov    %edx,0x10(%esp)
  802653:	8b 55 08             	mov    0x8(%ebp),%edx
  802656:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80265a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80265e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802662:	c7 04 24 f4 2f 80 00 	movl   $0x802ff4,(%esp)
  802669:	e8 a3 df ff ff       	call   800611 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80266e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802672:	8b 45 10             	mov    0x10(%ebp),%eax
  802675:	89 04 24             	mov    %eax,(%esp)
  802678:	e8 33 df ff ff       	call   8005b0 <vcprintf>
	cprintf("\n");
  80267d:	c7 04 24 34 2b 80 00 	movl   $0x802b34,(%esp)
  802684:	e8 88 df ff ff       	call   800611 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802689:	cc                   	int3   
  80268a:	eb fd                	jmp    802689 <_panic+0x53>
  80268c:	66 90                	xchg   %ax,%ax
  80268e:	66 90                	xchg   %ax,%ax

00802690 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802690:	55                   	push   %ebp
  802691:	89 e5                	mov    %esp,%ebp
  802693:	56                   	push   %esi
  802694:	53                   	push   %ebx
  802695:	83 ec 10             	sub    $0x10,%esp
  802698:	8b 75 08             	mov    0x8(%ebp),%esi
  80269b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80269e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  8026a1:	85 c0                	test   %eax,%eax
  8026a3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8026a8:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  8026ab:	89 04 24             	mov    %eax,(%esp)
  8026ae:	e8 b6 eb ff ff       	call   801269 <sys_ipc_recv>

	if(ret < 0) {
  8026b3:	85 c0                	test   %eax,%eax
  8026b5:	79 16                	jns    8026cd <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  8026b7:	85 f6                	test   %esi,%esi
  8026b9:	74 06                	je     8026c1 <ipc_recv+0x31>
  8026bb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  8026c1:	85 db                	test   %ebx,%ebx
  8026c3:	74 3e                	je     802703 <ipc_recv+0x73>
  8026c5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8026cb:	eb 36                	jmp    802703 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  8026cd:	e8 43 e9 ff ff       	call   801015 <sys_getenvid>
  8026d2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8026d7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8026da:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8026df:	a3 18 50 80 00       	mov    %eax,0x805018

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8026e4:	85 f6                	test   %esi,%esi
  8026e6:	74 05                	je     8026ed <ipc_recv+0x5d>
  8026e8:	8b 40 74             	mov    0x74(%eax),%eax
  8026eb:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8026ed:	85 db                	test   %ebx,%ebx
  8026ef:	74 0a                	je     8026fb <ipc_recv+0x6b>
  8026f1:	a1 18 50 80 00       	mov    0x805018,%eax
  8026f6:	8b 40 78             	mov    0x78(%eax),%eax
  8026f9:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  8026fb:	a1 18 50 80 00       	mov    0x805018,%eax
  802700:	8b 40 70             	mov    0x70(%eax),%eax
}
  802703:	83 c4 10             	add    $0x10,%esp
  802706:	5b                   	pop    %ebx
  802707:	5e                   	pop    %esi
  802708:	5d                   	pop    %ebp
  802709:	c3                   	ret    

0080270a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80270a:	55                   	push   %ebp
  80270b:	89 e5                	mov    %esp,%ebp
  80270d:	57                   	push   %edi
  80270e:	56                   	push   %esi
  80270f:	53                   	push   %ebx
  802710:	83 ec 1c             	sub    $0x1c,%esp
  802713:	8b 7d 08             	mov    0x8(%ebp),%edi
  802716:	8b 75 0c             	mov    0xc(%ebp),%esi
  802719:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  80271c:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  80271e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802723:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  802726:	8b 45 14             	mov    0x14(%ebp),%eax
  802729:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80272d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802731:	89 74 24 04          	mov    %esi,0x4(%esp)
  802735:	89 3c 24             	mov    %edi,(%esp)
  802738:	e8 09 eb ff ff       	call   801246 <sys_ipc_try_send>

		if(ret >= 0) break;
  80273d:	85 c0                	test   %eax,%eax
  80273f:	79 2c                	jns    80276d <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  802741:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802744:	74 20                	je     802766 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  802746:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80274a:	c7 44 24 08 18 30 80 	movl   $0x803018,0x8(%esp)
  802751:	00 
  802752:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  802759:	00 
  80275a:	c7 04 24 48 30 80 00 	movl   $0x803048,(%esp)
  802761:	e8 d0 fe ff ff       	call   802636 <_panic>
		}
		sys_yield();
  802766:	e8 c9 e8 ff ff       	call   801034 <sys_yield>
	}
  80276b:	eb b9                	jmp    802726 <ipc_send+0x1c>
}
  80276d:	83 c4 1c             	add    $0x1c,%esp
  802770:	5b                   	pop    %ebx
  802771:	5e                   	pop    %esi
  802772:	5f                   	pop    %edi
  802773:	5d                   	pop    %ebp
  802774:	c3                   	ret    

00802775 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802775:	55                   	push   %ebp
  802776:	89 e5                	mov    %esp,%ebp
  802778:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80277b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802780:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802783:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802789:	8b 52 50             	mov    0x50(%edx),%edx
  80278c:	39 ca                	cmp    %ecx,%edx
  80278e:	75 0d                	jne    80279d <ipc_find_env+0x28>
			return envs[i].env_id;
  802790:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802793:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802798:	8b 40 40             	mov    0x40(%eax),%eax
  80279b:	eb 0e                	jmp    8027ab <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80279d:	83 c0 01             	add    $0x1,%eax
  8027a0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8027a5:	75 d9                	jne    802780 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8027a7:	66 b8 00 00          	mov    $0x0,%ax
}
  8027ab:	5d                   	pop    %ebp
  8027ac:	c3                   	ret    

008027ad <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8027ad:	55                   	push   %ebp
  8027ae:	89 e5                	mov    %esp,%ebp
  8027b0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8027b3:	89 d0                	mov    %edx,%eax
  8027b5:	c1 e8 16             	shr    $0x16,%eax
  8027b8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8027bf:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8027c4:	f6 c1 01             	test   $0x1,%cl
  8027c7:	74 1d                	je     8027e6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8027c9:	c1 ea 0c             	shr    $0xc,%edx
  8027cc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8027d3:	f6 c2 01             	test   $0x1,%dl
  8027d6:	74 0e                	je     8027e6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8027d8:	c1 ea 0c             	shr    $0xc,%edx
  8027db:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8027e2:	ef 
  8027e3:	0f b7 c0             	movzwl %ax,%eax
}
  8027e6:	5d                   	pop    %ebp
  8027e7:	c3                   	ret    
  8027e8:	66 90                	xchg   %ax,%ax
  8027ea:	66 90                	xchg   %ax,%ax
  8027ec:	66 90                	xchg   %ax,%ax
  8027ee:	66 90                	xchg   %ax,%ax

008027f0 <__udivdi3>:
  8027f0:	55                   	push   %ebp
  8027f1:	57                   	push   %edi
  8027f2:	56                   	push   %esi
  8027f3:	83 ec 0c             	sub    $0xc,%esp
  8027f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8027fa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8027fe:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802802:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802806:	85 c0                	test   %eax,%eax
  802808:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80280c:	89 ea                	mov    %ebp,%edx
  80280e:	89 0c 24             	mov    %ecx,(%esp)
  802811:	75 2d                	jne    802840 <__udivdi3+0x50>
  802813:	39 e9                	cmp    %ebp,%ecx
  802815:	77 61                	ja     802878 <__udivdi3+0x88>
  802817:	85 c9                	test   %ecx,%ecx
  802819:	89 ce                	mov    %ecx,%esi
  80281b:	75 0b                	jne    802828 <__udivdi3+0x38>
  80281d:	b8 01 00 00 00       	mov    $0x1,%eax
  802822:	31 d2                	xor    %edx,%edx
  802824:	f7 f1                	div    %ecx
  802826:	89 c6                	mov    %eax,%esi
  802828:	31 d2                	xor    %edx,%edx
  80282a:	89 e8                	mov    %ebp,%eax
  80282c:	f7 f6                	div    %esi
  80282e:	89 c5                	mov    %eax,%ebp
  802830:	89 f8                	mov    %edi,%eax
  802832:	f7 f6                	div    %esi
  802834:	89 ea                	mov    %ebp,%edx
  802836:	83 c4 0c             	add    $0xc,%esp
  802839:	5e                   	pop    %esi
  80283a:	5f                   	pop    %edi
  80283b:	5d                   	pop    %ebp
  80283c:	c3                   	ret    
  80283d:	8d 76 00             	lea    0x0(%esi),%esi
  802840:	39 e8                	cmp    %ebp,%eax
  802842:	77 24                	ja     802868 <__udivdi3+0x78>
  802844:	0f bd e8             	bsr    %eax,%ebp
  802847:	83 f5 1f             	xor    $0x1f,%ebp
  80284a:	75 3c                	jne    802888 <__udivdi3+0x98>
  80284c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802850:	39 34 24             	cmp    %esi,(%esp)
  802853:	0f 86 9f 00 00 00    	jbe    8028f8 <__udivdi3+0x108>
  802859:	39 d0                	cmp    %edx,%eax
  80285b:	0f 82 97 00 00 00    	jb     8028f8 <__udivdi3+0x108>
  802861:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802868:	31 d2                	xor    %edx,%edx
  80286a:	31 c0                	xor    %eax,%eax
  80286c:	83 c4 0c             	add    $0xc,%esp
  80286f:	5e                   	pop    %esi
  802870:	5f                   	pop    %edi
  802871:	5d                   	pop    %ebp
  802872:	c3                   	ret    
  802873:	90                   	nop
  802874:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802878:	89 f8                	mov    %edi,%eax
  80287a:	f7 f1                	div    %ecx
  80287c:	31 d2                	xor    %edx,%edx
  80287e:	83 c4 0c             	add    $0xc,%esp
  802881:	5e                   	pop    %esi
  802882:	5f                   	pop    %edi
  802883:	5d                   	pop    %ebp
  802884:	c3                   	ret    
  802885:	8d 76 00             	lea    0x0(%esi),%esi
  802888:	89 e9                	mov    %ebp,%ecx
  80288a:	8b 3c 24             	mov    (%esp),%edi
  80288d:	d3 e0                	shl    %cl,%eax
  80288f:	89 c6                	mov    %eax,%esi
  802891:	b8 20 00 00 00       	mov    $0x20,%eax
  802896:	29 e8                	sub    %ebp,%eax
  802898:	89 c1                	mov    %eax,%ecx
  80289a:	d3 ef                	shr    %cl,%edi
  80289c:	89 e9                	mov    %ebp,%ecx
  80289e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8028a2:	8b 3c 24             	mov    (%esp),%edi
  8028a5:	09 74 24 08          	or     %esi,0x8(%esp)
  8028a9:	89 d6                	mov    %edx,%esi
  8028ab:	d3 e7                	shl    %cl,%edi
  8028ad:	89 c1                	mov    %eax,%ecx
  8028af:	89 3c 24             	mov    %edi,(%esp)
  8028b2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8028b6:	d3 ee                	shr    %cl,%esi
  8028b8:	89 e9                	mov    %ebp,%ecx
  8028ba:	d3 e2                	shl    %cl,%edx
  8028bc:	89 c1                	mov    %eax,%ecx
  8028be:	d3 ef                	shr    %cl,%edi
  8028c0:	09 d7                	or     %edx,%edi
  8028c2:	89 f2                	mov    %esi,%edx
  8028c4:	89 f8                	mov    %edi,%eax
  8028c6:	f7 74 24 08          	divl   0x8(%esp)
  8028ca:	89 d6                	mov    %edx,%esi
  8028cc:	89 c7                	mov    %eax,%edi
  8028ce:	f7 24 24             	mull   (%esp)
  8028d1:	39 d6                	cmp    %edx,%esi
  8028d3:	89 14 24             	mov    %edx,(%esp)
  8028d6:	72 30                	jb     802908 <__udivdi3+0x118>
  8028d8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8028dc:	89 e9                	mov    %ebp,%ecx
  8028de:	d3 e2                	shl    %cl,%edx
  8028e0:	39 c2                	cmp    %eax,%edx
  8028e2:	73 05                	jae    8028e9 <__udivdi3+0xf9>
  8028e4:	3b 34 24             	cmp    (%esp),%esi
  8028e7:	74 1f                	je     802908 <__udivdi3+0x118>
  8028e9:	89 f8                	mov    %edi,%eax
  8028eb:	31 d2                	xor    %edx,%edx
  8028ed:	e9 7a ff ff ff       	jmp    80286c <__udivdi3+0x7c>
  8028f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8028f8:	31 d2                	xor    %edx,%edx
  8028fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8028ff:	e9 68 ff ff ff       	jmp    80286c <__udivdi3+0x7c>
  802904:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802908:	8d 47 ff             	lea    -0x1(%edi),%eax
  80290b:	31 d2                	xor    %edx,%edx
  80290d:	83 c4 0c             	add    $0xc,%esp
  802910:	5e                   	pop    %esi
  802911:	5f                   	pop    %edi
  802912:	5d                   	pop    %ebp
  802913:	c3                   	ret    
  802914:	66 90                	xchg   %ax,%ax
  802916:	66 90                	xchg   %ax,%ax
  802918:	66 90                	xchg   %ax,%ax
  80291a:	66 90                	xchg   %ax,%ax
  80291c:	66 90                	xchg   %ax,%ax
  80291e:	66 90                	xchg   %ax,%ax

00802920 <__umoddi3>:
  802920:	55                   	push   %ebp
  802921:	57                   	push   %edi
  802922:	56                   	push   %esi
  802923:	83 ec 14             	sub    $0x14,%esp
  802926:	8b 44 24 28          	mov    0x28(%esp),%eax
  80292a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80292e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802932:	89 c7                	mov    %eax,%edi
  802934:	89 44 24 04          	mov    %eax,0x4(%esp)
  802938:	8b 44 24 30          	mov    0x30(%esp),%eax
  80293c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802940:	89 34 24             	mov    %esi,(%esp)
  802943:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802947:	85 c0                	test   %eax,%eax
  802949:	89 c2                	mov    %eax,%edx
  80294b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80294f:	75 17                	jne    802968 <__umoddi3+0x48>
  802951:	39 fe                	cmp    %edi,%esi
  802953:	76 4b                	jbe    8029a0 <__umoddi3+0x80>
  802955:	89 c8                	mov    %ecx,%eax
  802957:	89 fa                	mov    %edi,%edx
  802959:	f7 f6                	div    %esi
  80295b:	89 d0                	mov    %edx,%eax
  80295d:	31 d2                	xor    %edx,%edx
  80295f:	83 c4 14             	add    $0x14,%esp
  802962:	5e                   	pop    %esi
  802963:	5f                   	pop    %edi
  802964:	5d                   	pop    %ebp
  802965:	c3                   	ret    
  802966:	66 90                	xchg   %ax,%ax
  802968:	39 f8                	cmp    %edi,%eax
  80296a:	77 54                	ja     8029c0 <__umoddi3+0xa0>
  80296c:	0f bd e8             	bsr    %eax,%ebp
  80296f:	83 f5 1f             	xor    $0x1f,%ebp
  802972:	75 5c                	jne    8029d0 <__umoddi3+0xb0>
  802974:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802978:	39 3c 24             	cmp    %edi,(%esp)
  80297b:	0f 87 e7 00 00 00    	ja     802a68 <__umoddi3+0x148>
  802981:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802985:	29 f1                	sub    %esi,%ecx
  802987:	19 c7                	sbb    %eax,%edi
  802989:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80298d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802991:	8b 44 24 08          	mov    0x8(%esp),%eax
  802995:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802999:	83 c4 14             	add    $0x14,%esp
  80299c:	5e                   	pop    %esi
  80299d:	5f                   	pop    %edi
  80299e:	5d                   	pop    %ebp
  80299f:	c3                   	ret    
  8029a0:	85 f6                	test   %esi,%esi
  8029a2:	89 f5                	mov    %esi,%ebp
  8029a4:	75 0b                	jne    8029b1 <__umoddi3+0x91>
  8029a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8029ab:	31 d2                	xor    %edx,%edx
  8029ad:	f7 f6                	div    %esi
  8029af:	89 c5                	mov    %eax,%ebp
  8029b1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8029b5:	31 d2                	xor    %edx,%edx
  8029b7:	f7 f5                	div    %ebp
  8029b9:	89 c8                	mov    %ecx,%eax
  8029bb:	f7 f5                	div    %ebp
  8029bd:	eb 9c                	jmp    80295b <__umoddi3+0x3b>
  8029bf:	90                   	nop
  8029c0:	89 c8                	mov    %ecx,%eax
  8029c2:	89 fa                	mov    %edi,%edx
  8029c4:	83 c4 14             	add    $0x14,%esp
  8029c7:	5e                   	pop    %esi
  8029c8:	5f                   	pop    %edi
  8029c9:	5d                   	pop    %ebp
  8029ca:	c3                   	ret    
  8029cb:	90                   	nop
  8029cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8029d0:	8b 04 24             	mov    (%esp),%eax
  8029d3:	be 20 00 00 00       	mov    $0x20,%esi
  8029d8:	89 e9                	mov    %ebp,%ecx
  8029da:	29 ee                	sub    %ebp,%esi
  8029dc:	d3 e2                	shl    %cl,%edx
  8029de:	89 f1                	mov    %esi,%ecx
  8029e0:	d3 e8                	shr    %cl,%eax
  8029e2:	89 e9                	mov    %ebp,%ecx
  8029e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029e8:	8b 04 24             	mov    (%esp),%eax
  8029eb:	09 54 24 04          	or     %edx,0x4(%esp)
  8029ef:	89 fa                	mov    %edi,%edx
  8029f1:	d3 e0                	shl    %cl,%eax
  8029f3:	89 f1                	mov    %esi,%ecx
  8029f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8029f9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8029fd:	d3 ea                	shr    %cl,%edx
  8029ff:	89 e9                	mov    %ebp,%ecx
  802a01:	d3 e7                	shl    %cl,%edi
  802a03:	89 f1                	mov    %esi,%ecx
  802a05:	d3 e8                	shr    %cl,%eax
  802a07:	89 e9                	mov    %ebp,%ecx
  802a09:	09 f8                	or     %edi,%eax
  802a0b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  802a0f:	f7 74 24 04          	divl   0x4(%esp)
  802a13:	d3 e7                	shl    %cl,%edi
  802a15:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802a19:	89 d7                	mov    %edx,%edi
  802a1b:	f7 64 24 08          	mull   0x8(%esp)
  802a1f:	39 d7                	cmp    %edx,%edi
  802a21:	89 c1                	mov    %eax,%ecx
  802a23:	89 14 24             	mov    %edx,(%esp)
  802a26:	72 2c                	jb     802a54 <__umoddi3+0x134>
  802a28:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  802a2c:	72 22                	jb     802a50 <__umoddi3+0x130>
  802a2e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802a32:	29 c8                	sub    %ecx,%eax
  802a34:	19 d7                	sbb    %edx,%edi
  802a36:	89 e9                	mov    %ebp,%ecx
  802a38:	89 fa                	mov    %edi,%edx
  802a3a:	d3 e8                	shr    %cl,%eax
  802a3c:	89 f1                	mov    %esi,%ecx
  802a3e:	d3 e2                	shl    %cl,%edx
  802a40:	89 e9                	mov    %ebp,%ecx
  802a42:	d3 ef                	shr    %cl,%edi
  802a44:	09 d0                	or     %edx,%eax
  802a46:	89 fa                	mov    %edi,%edx
  802a48:	83 c4 14             	add    $0x14,%esp
  802a4b:	5e                   	pop    %esi
  802a4c:	5f                   	pop    %edi
  802a4d:	5d                   	pop    %ebp
  802a4e:	c3                   	ret    
  802a4f:	90                   	nop
  802a50:	39 d7                	cmp    %edx,%edi
  802a52:	75 da                	jne    802a2e <__umoddi3+0x10e>
  802a54:	8b 14 24             	mov    (%esp),%edx
  802a57:	89 c1                	mov    %eax,%ecx
  802a59:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  802a5d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802a61:	eb cb                	jmp    802a2e <__umoddi3+0x10e>
  802a63:	90                   	nop
  802a64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a68:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  802a6c:	0f 82 0f ff ff ff    	jb     802981 <__umoddi3+0x61>
  802a72:	e9 1a ff ff ff       	jmp    802991 <__umoddi3+0x71>
