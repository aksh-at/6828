
obj/net/testinput:     file format elf32-i386


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
  80002c:	e8 2c 09 00 00       	call   80095d <libmain>
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
	}
}

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	57                   	push   %edi
  800044:	56                   	push   %esi
  800045:	53                   	push   %ebx
  800046:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	envid_t ns_envid = sys_getenvid();
  80004c:	e8 74 14 00 00       	call   8014c5 <sys_getenvid>
  800051:	89 c3                	mov    %eax,%ebx
	int i, r, first = 1;

	binaryname = "testinput";
  800053:	c7 05 00 40 80 00 60 	movl   $0x803260,0x804000
  80005a:	32 80 00 

	output_envid = fork();
  80005d:	e8 d2 18 00 00       	call   801934 <fork>
  800062:	a3 04 50 80 00       	mov    %eax,0x805004
	if (output_envid < 0)
  800067:	85 c0                	test   %eax,%eax
  800069:	79 1c                	jns    800087 <umain+0x47>
		panic("error forking");
  80006b:	c7 44 24 08 6a 32 80 	movl   $0x80326a,0x8(%esp)
  800072:	00 
  800073:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  80007a:	00 
  80007b:	c7 04 24 78 32 80 00 	movl   $0x803278,(%esp)
  800082:	e8 37 09 00 00       	call   8009be <_panic>
	else if (output_envid == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 0d                	jne    800098 <umain+0x58>
		output(ns_envid);
  80008b:	89 1c 24             	mov    %ebx,(%esp)
  80008e:	e8 2d 05 00 00       	call   8005c0 <output>
		return;
  800093:	e9 a5 03 00 00       	jmp    80043d <umain+0x3fd>
	}

	input_envid = fork();
  800098:	e8 97 18 00 00       	call   801934 <fork>
  80009d:	a3 00 50 80 00       	mov    %eax,0x805000
	if (input_envid < 0)
  8000a2:	85 c0                	test   %eax,%eax
  8000a4:	79 1c                	jns    8000c2 <umain+0x82>
		panic("error forking");
  8000a6:	c7 44 24 08 6a 32 80 	movl   $0x80326a,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 78 32 80 00 	movl   $0x803278,(%esp)
  8000bd:	e8 fc 08 00 00       	call   8009be <_panic>
	else if (input_envid == 0) {
  8000c2:	85 c0                	test   %eax,%eax
  8000c4:	75 0f                	jne    8000d5 <umain+0x95>
		input(ns_envid);
  8000c6:	89 1c 24             	mov    %ebx,(%esp)
  8000c9:	e8 52 04 00 00       	call   800520 <input>
		return;
  8000ce:	66 90                	xchg   %ax,%ax
  8000d0:	e9 68 03 00 00       	jmp    80043d <umain+0x3fd>
	}

	cprintf("Sending ARP announcement...\n");
  8000d5:	c7 04 24 88 32 80 00 	movl   $0x803288,(%esp)
  8000dc:	e8 d6 09 00 00       	call   800ab7 <cprintf>
	// with ARP requests.  Ideally, we would use gratuitous ARP
	// for this, but QEMU's ARP implementation is dumb and only
	// listens for very specific ARP requests, such as requests
	// for the gateway IP.

	uint8_t mac[6] = {0x52, 0x54, 0x00, 0x12, 0x34, 0x56};
  8000e1:	c6 45 98 52          	movb   $0x52,-0x68(%ebp)
  8000e5:	c6 45 99 54          	movb   $0x54,-0x67(%ebp)
  8000e9:	c6 45 9a 00          	movb   $0x0,-0x66(%ebp)
  8000ed:	c6 45 9b 12          	movb   $0x12,-0x65(%ebp)
  8000f1:	c6 45 9c 34          	movb   $0x34,-0x64(%ebp)
  8000f5:	c6 45 9d 56          	movb   $0x56,-0x63(%ebp)
	uint32_t myip = inet_addr(IP);
  8000f9:	c7 04 24 a5 32 80 00 	movl   $0x8032a5,(%esp)
  800100:	e8 20 08 00 00       	call   800925 <inet_addr>
  800105:	89 45 90             	mov    %eax,-0x70(%ebp)
	uint32_t gwip = inet_addr(DEFAULT);
  800108:	c7 04 24 af 32 80 00 	movl   $0x8032af,(%esp)
  80010f:	e8 11 08 00 00       	call   800925 <inet_addr>
  800114:	89 45 94             	mov    %eax,-0x6c(%ebp)
	int r;

	if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  800117:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  800126:	0f 
  800127:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80012e:	e8 d0 13 00 00       	call   801503 <sys_page_alloc>
  800133:	85 c0                	test   %eax,%eax
  800135:	79 20                	jns    800157 <umain+0x117>
		panic("sys_page_map: %e", r);
  800137:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80013b:	c7 44 24 08 b8 32 80 	movl   $0x8032b8,0x8(%esp)
  800142:	00 
  800143:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  80014a:	00 
  80014b:	c7 04 24 78 32 80 00 	movl   $0x803278,(%esp)
  800152:	e8 67 08 00 00       	call   8009be <_panic>

	struct etharp_hdr *arp = (struct etharp_hdr*)pkt->jp_data;
	pkt->jp_len = sizeof(*arp);
  800157:	c7 05 00 b0 fe 0f 2a 	movl   $0x2a,0xffeb000
  80015e:	00 00 00 

	memset(arp->ethhdr.dest.addr, 0xff, ETHARP_HWADDR_LEN);
  800161:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  800168:	00 
  800169:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800170:	00 
  800171:	c7 04 24 04 b0 fe 0f 	movl   $0xffeb004,(%esp)
  800178:	e8 ba 10 00 00       	call   801237 <memset>
	memcpy(arp->ethhdr.src.addr,  mac,  ETHARP_HWADDR_LEN);
  80017d:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  800184:	00 
  800185:	8d 5d 98             	lea    -0x68(%ebp),%ebx
  800188:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80018c:	c7 04 24 0a b0 fe 0f 	movl   $0xffeb00a,(%esp)
  800193:	e8 54 11 00 00       	call   8012ec <memcpy>
	arp->ethhdr.type = htons(ETHTYPE_ARP);
  800198:	c7 04 24 06 08 00 00 	movl   $0x806,(%esp)
  80019f:	e8 52 05 00 00       	call   8006f6 <htons>
  8001a4:	66 a3 10 b0 fe 0f    	mov    %ax,0xffeb010
	arp->hwtype = htons(1); // Ethernet
  8001aa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001b1:	e8 40 05 00 00       	call   8006f6 <htons>
  8001b6:	66 a3 12 b0 fe 0f    	mov    %ax,0xffeb012
	arp->proto = htons(ETHTYPE_IP);
  8001bc:	c7 04 24 00 08 00 00 	movl   $0x800,(%esp)
  8001c3:	e8 2e 05 00 00       	call   8006f6 <htons>
  8001c8:	66 a3 14 b0 fe 0f    	mov    %ax,0xffeb014
	arp->_hwlen_protolen = htons((ETHARP_HWADDR_LEN << 8) | 4);
  8001ce:	c7 04 24 04 06 00 00 	movl   $0x604,(%esp)
  8001d5:	e8 1c 05 00 00       	call   8006f6 <htons>
  8001da:	66 a3 16 b0 fe 0f    	mov    %ax,0xffeb016
	arp->opcode = htons(ARP_REQUEST);
  8001e0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001e7:	e8 0a 05 00 00       	call   8006f6 <htons>
  8001ec:	66 a3 18 b0 fe 0f    	mov    %ax,0xffeb018
	memcpy(arp->shwaddr.addr,  mac,   ETHARP_HWADDR_LEN);
  8001f2:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  8001f9:	00 
  8001fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001fe:	c7 04 24 1a b0 fe 0f 	movl   $0xffeb01a,(%esp)
  800205:	e8 e2 10 00 00       	call   8012ec <memcpy>
	memcpy(arp->sipaddr.addrw, &myip, 4);
  80020a:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800211:	00 
  800212:	8d 45 90             	lea    -0x70(%ebp),%eax
  800215:	89 44 24 04          	mov    %eax,0x4(%esp)
  800219:	c7 04 24 20 b0 fe 0f 	movl   $0xffeb020,(%esp)
  800220:	e8 c7 10 00 00       	call   8012ec <memcpy>
	memset(arp->dhwaddr.addr,  0x00,  ETHARP_HWADDR_LEN);
  800225:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  80022c:	00 
  80022d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800234:	00 
  800235:	c7 04 24 24 b0 fe 0f 	movl   $0xffeb024,(%esp)
  80023c:	e8 f6 0f 00 00       	call   801237 <memset>
	memcpy(arp->dipaddr.addrw, &gwip, 4);
  800241:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800248:	00 
  800249:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80024c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800250:	c7 04 24 2a b0 fe 0f 	movl   $0xffeb02a,(%esp)
  800257:	e8 90 10 00 00       	call   8012ec <memcpy>

	ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  80025c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800263:	00 
  800264:	c7 44 24 08 00 b0 fe 	movl   $0xffeb000,0x8(%esp)
  80026b:	0f 
  80026c:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
  800273:	00 
  800274:	a1 04 50 80 00       	mov    0x805004,%eax
  800279:	89 04 24             	mov    %eax,(%esp)
  80027c:	e8 39 19 00 00       	call   801bba <ipc_send>
	sys_page_unmap(0, pkt);
  800281:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  800288:	0f 
  800289:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800290:	e8 15 13 00 00       	call   8015aa <sys_page_unmap>

void
umain(int argc, char **argv)
{
	envid_t ns_envid = sys_getenvid();
	int i, r, first = 1;
  800295:	c7 85 7c ff ff ff 01 	movl   $0x1,-0x84(%ebp)
  80029c:	00 00 00 

	while (1) {
		envid_t whom;
		int perm;

		int32_t req = ipc_recv((int32_t *)&whom, pkt, &perm);
  80029f:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8002a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a6:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  8002ad:	0f 
  8002ae:	8d 45 90             	lea    -0x70(%ebp),%eax
  8002b1:	89 04 24             	mov    %eax,(%esp)
  8002b4:	e8 87 18 00 00       	call   801b40 <ipc_recv>
		if (req < 0)
  8002b9:	85 c0                	test   %eax,%eax
  8002bb:	79 20                	jns    8002dd <umain+0x29d>
			panic("ipc_recv: %e", req);
  8002bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002c1:	c7 44 24 08 c9 32 80 	movl   $0x8032c9,0x8(%esp)
  8002c8:	00 
  8002c9:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8002d0:	00 
  8002d1:	c7 04 24 78 32 80 00 	movl   $0x803278,(%esp)
  8002d8:	e8 e1 06 00 00       	call   8009be <_panic>
		if (whom != input_envid)
  8002dd:	8b 55 90             	mov    -0x70(%ebp),%edx
  8002e0:	3b 15 00 50 80 00    	cmp    0x805000,%edx
  8002e6:	74 20                	je     800308 <umain+0x2c8>
			panic("IPC from unexpected environment %08x", whom);
  8002e8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002ec:	c7 44 24 08 20 33 80 	movl   $0x803320,0x8(%esp)
  8002f3:	00 
  8002f4:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  8002fb:	00 
  8002fc:	c7 04 24 78 32 80 00 	movl   $0x803278,(%esp)
  800303:	e8 b6 06 00 00       	call   8009be <_panic>
		if (req != NSREQ_INPUT)
  800308:	83 f8 0a             	cmp    $0xa,%eax
  80030b:	74 20                	je     80032d <umain+0x2ed>
			panic("Unexpected IPC %d", req);
  80030d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800311:	c7 44 24 08 d6 32 80 	movl   $0x8032d6,0x8(%esp)
  800318:	00 
  800319:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
  800320:	00 
  800321:	c7 04 24 78 32 80 00 	movl   $0x803278,(%esp)
  800328:	e8 91 06 00 00       	call   8009be <_panic>

		hexdump("input: ", pkt->jp_data, pkt->jp_len);
  80032d:	a1 00 b0 fe 0f       	mov    0xffeb000,%eax
  800332:	89 45 84             	mov    %eax,-0x7c(%ebp)
hexdump(const char *prefix, const void *data, int len)
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
  800335:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < len; i++) {
  80033a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i % 16 == 0)
			out = buf + snprintf(buf, end - buf,
					     "%s%04x   ", prefix, i);
		out += snprintf(out, end - out, "%02x", ((uint8_t*)data)[i]);
		if (i % 16 == 15 || i == len - 1)
  80033f:	83 e8 01             	sub    $0x1,%eax
  800342:	89 45 80             	mov    %eax,-0x80(%ebp)
  800345:	e9 ba 00 00 00       	jmp    800404 <umain+0x3c4>
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
		if (i % 16 == 0)
  80034a:	89 df                	mov    %ebx,%edi
  80034c:	f6 c3 0f             	test   $0xf,%bl
  80034f:	75 2d                	jne    80037e <umain+0x33e>
			out = buf + snprintf(buf, end - buf,
  800351:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800355:	c7 44 24 0c e8 32 80 	movl   $0x8032e8,0xc(%esp)
  80035c:	00 
  80035d:	c7 44 24 08 f0 32 80 	movl   $0x8032f0,0x8(%esp)
  800364:	00 
  800365:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  80036c:	00 
  80036d:	8d 45 98             	lea    -0x68(%ebp),%eax
  800370:	89 04 24             	mov    %eax,(%esp)
  800373:	e8 02 0d 00 00       	call   80107a <snprintf>
  800378:	8d 4d 98             	lea    -0x68(%ebp),%ecx
  80037b:	8d 34 01             	lea    (%ecx,%eax,1),%esi
					     "%s%04x   ", prefix, i);
		out += snprintf(out, end - out, "%02x", ((uint8_t*)data)[i]);
  80037e:	b8 04 b0 fe 0f       	mov    $0xffeb004,%eax
  800383:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
  800387:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80038b:	c7 44 24 08 fa 32 80 	movl   $0x8032fa,0x8(%esp)
  800392:	00 
  800393:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800396:	29 f0                	sub    %esi,%eax
  800398:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039c:	89 34 24             	mov    %esi,(%esp)
  80039f:	e8 d6 0c 00 00       	call   80107a <snprintf>
  8003a4:	01 c6                	add    %eax,%esi
		if (i % 16 == 15 || i == len - 1)
  8003a6:	89 d8                	mov    %ebx,%eax
  8003a8:	c1 f8 1f             	sar    $0x1f,%eax
  8003ab:	c1 e8 1c             	shr    $0x1c,%eax
  8003ae:	8d 3c 03             	lea    (%ebx,%eax,1),%edi
  8003b1:	83 e7 0f             	and    $0xf,%edi
  8003b4:	29 c7                	sub    %eax,%edi
  8003b6:	83 ff 0f             	cmp    $0xf,%edi
  8003b9:	74 05                	je     8003c0 <umain+0x380>
  8003bb:	3b 5d 80             	cmp    -0x80(%ebp),%ebx
  8003be:	75 1e                	jne    8003de <umain+0x39e>
			cprintf("%.*s\n", out - buf, buf);
  8003c0:	8d 45 98             	lea    -0x68(%ebp),%eax
  8003c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003c7:	89 f0                	mov    %esi,%eax
  8003c9:	8d 4d 98             	lea    -0x68(%ebp),%ecx
  8003cc:	29 c8                	sub    %ecx,%eax
  8003ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d2:	c7 04 24 ff 32 80 00 	movl   $0x8032ff,(%esp)
  8003d9:	e8 d9 06 00 00       	call   800ab7 <cprintf>
		if (i % 2 == 1)
  8003de:	89 d8                	mov    %ebx,%eax
  8003e0:	c1 e8 1f             	shr    $0x1f,%eax
  8003e3:	8d 14 03             	lea    (%ebx,%eax,1),%edx
  8003e6:	83 e2 01             	and    $0x1,%edx
  8003e9:	29 c2                	sub    %eax,%edx
  8003eb:	83 fa 01             	cmp    $0x1,%edx
  8003ee:	75 06                	jne    8003f6 <umain+0x3b6>
			*(out++) = ' ';
  8003f0:	c6 06 20             	movb   $0x20,(%esi)
  8003f3:	8d 76 01             	lea    0x1(%esi),%esi
		if (i % 16 == 7)
  8003f6:	83 ff 07             	cmp    $0x7,%edi
  8003f9:	75 06                	jne    800401 <umain+0x3c1>
			*(out++) = ' ';
  8003fb:	c6 06 20             	movb   $0x20,(%esi)
  8003fe:	8d 76 01             	lea    0x1(%esi),%esi
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
  800401:	83 c3 01             	add    $0x1,%ebx
  800404:	39 5d 84             	cmp    %ebx,-0x7c(%ebp)
  800407:	0f 8f 3d ff ff ff    	jg     80034a <umain+0x30a>
			panic("IPC from unexpected environment %08x", whom);
		if (req != NSREQ_INPUT)
			panic("Unexpected IPC %d", req);

		hexdump("input: ", pkt->jp_data, pkt->jp_len);
		cprintf("\n");
  80040d:	c7 04 24 1b 33 80 00 	movl   $0x80331b,(%esp)
  800414:	e8 9e 06 00 00       	call   800ab7 <cprintf>

		// Only indicate that we're waiting for packets once
		// we've received the ARP reply
		if (first)
  800419:	83 bd 7c ff ff ff 00 	cmpl   $0x0,-0x84(%ebp)
  800420:	74 0c                	je     80042e <umain+0x3ee>
			cprintf("Waiting for packets...\n");
  800422:	c7 04 24 05 33 80 00 	movl   $0x803305,(%esp)
  800429:	e8 89 06 00 00       	call   800ab7 <cprintf>
		first = 0;
  80042e:	c7 85 7c ff ff ff 00 	movl   $0x0,-0x84(%ebp)
  800435:	00 00 00 
	}
  800438:	e9 62 fe ff ff       	jmp    80029f <umain+0x25f>
}
  80043d:	81 c4 8c 00 00 00    	add    $0x8c,%esp
  800443:	5b                   	pop    %ebx
  800444:	5e                   	pop    %esi
  800445:	5f                   	pop    %edi
  800446:	5d                   	pop    %ebp
  800447:	c3                   	ret    
  800448:	66 90                	xchg   %ax,%ax
  80044a:	66 90                	xchg   %ax,%ax
  80044c:	66 90                	xchg   %ax,%ax
  80044e:	66 90                	xchg   %ax,%ax

00800450 <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  800450:	55                   	push   %ebp
  800451:	89 e5                	mov    %esp,%ebp
  800453:	57                   	push   %edi
  800454:	56                   	push   %esi
  800455:	53                   	push   %ebx
  800456:	83 ec 2c             	sub    $0x2c,%esp
  800459:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  80045c:	e8 0a 13 00 00       	call   80176b <sys_time_msec>
  800461:	03 45 0c             	add    0xc(%ebp),%eax
  800464:	89 c6                	mov    %eax,%esi

	binaryname = "ns_timer";
  800466:	c7 05 00 40 80 00 45 	movl   $0x803345,0x804000
  80046d:	33 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  800470:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800473:	eb 05                	jmp    80047a <timer+0x2a>

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
			sys_yield();
  800475:	e8 6a 10 00 00       	call   8014e4 <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
  80047a:	e8 ec 12 00 00       	call   80176b <sys_time_msec>
  80047f:	39 c6                	cmp    %eax,%esi
  800481:	76 06                	jbe    800489 <timer+0x39>
  800483:	85 c0                	test   %eax,%eax
  800485:	79 ee                	jns    800475 <timer+0x25>
  800487:	eb 09                	jmp    800492 <timer+0x42>
			sys_yield();
		}
		if (r < 0)
  800489:	85 c0                	test   %eax,%eax
  80048b:	90                   	nop
  80048c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800490:	79 20                	jns    8004b2 <timer+0x62>
			panic("sys_time_msec: %e", r);
  800492:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800496:	c7 44 24 08 4e 33 80 	movl   $0x80334e,0x8(%esp)
  80049d:	00 
  80049e:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8004a5:	00 
  8004a6:	c7 04 24 60 33 80 00 	movl   $0x803360,(%esp)
  8004ad:	e8 0c 05 00 00       	call   8009be <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  8004b2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004b9:	00 
  8004ba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004c1:	00 
  8004c2:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
  8004c9:	00 
  8004ca:	89 1c 24             	mov    %ebx,(%esp)
  8004cd:	e8 e8 16 00 00       	call   801bba <ipc_send>

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8004d2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004d9:	00 
  8004da:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004e1:	00 
  8004e2:	89 3c 24             	mov    %edi,(%esp)
  8004e5:	e8 56 16 00 00       	call   801b40 <ipc_recv>
  8004ea:	89 c6                	mov    %eax,%esi

			if (whom != ns_envid) {
  8004ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004ef:	39 c3                	cmp    %eax,%ebx
  8004f1:	74 12                	je     800505 <timer+0xb5>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  8004f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f7:	c7 04 24 6c 33 80 00 	movl   $0x80336c,(%esp)
  8004fe:	e8 b4 05 00 00       	call   800ab7 <cprintf>
  800503:	eb cd                	jmp    8004d2 <timer+0x82>
				continue;
			}

			stop = sys_time_msec() + to;
  800505:	e8 61 12 00 00       	call   80176b <sys_time_msec>
  80050a:	01 c6                	add    %eax,%esi
  80050c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800510:	e9 65 ff ff ff       	jmp    80047a <timer+0x2a>
  800515:	66 90                	xchg   %ax,%ax
  800517:	66 90                	xchg   %ax,%ax
  800519:	66 90                	xchg   %ax,%ax
  80051b:	66 90                	xchg   %ax,%ax
  80051d:	66 90                	xchg   %ax,%ax
  80051f:	90                   	nop

00800520 <input>:

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
  800520:	55                   	push   %ebp
  800521:	89 e5                	mov    %esp,%ebp
  800523:	57                   	push   %edi
  800524:	56                   	push   %esi
  800525:	53                   	push   %ebx
  800526:	83 ec 2c             	sub    $0x2c,%esp
  800529:	8b 7d 08             	mov    0x8(%ebp),%edi
	binaryname = "ns_input";
  80052c:	c7 05 00 40 80 00 a7 	movl   $0x8033a7,0x804000
  800533:	33 80 00 
	while(true) {
		//sys_yield();
		//continue;

		while(true) {
			if(sys_try_recv_packet(&packet, &size) == 0)  break;
  800536:	8d 75 e0             	lea    -0x20(%ebp),%esi
  800539:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  80053c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800540:	89 1c 24             	mov    %ebx,(%esp)
  800543:	e8 95 12 00 00       	call   8017dd <sys_try_recv_packet>
  800548:	85 c0                	test   %eax,%eax
  80054a:	74 07                	je     800553 <input+0x33>
			sys_yield();
  80054c:	e8 93 0f 00 00       	call   8014e4 <sys_yield>
		}
  800551:	eb e9                	jmp    80053c <input+0x1c>

		sys_page_alloc(0, &nsipcbuf, PTE_U|PTE_W|PTE_P);
  800553:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80055a:	00 
  80055b:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  800562:	00 
  800563:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80056a:	e8 94 0f 00 00       	call   801503 <sys_page_alloc>
		memcpy(nsipcbuf.pkt.jp_data, packet, size);
  80056f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800572:	89 44 24 08          	mov    %eax,0x8(%esp)
  800576:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800579:	89 44 24 04          	mov    %eax,0x4(%esp)
  80057d:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  800584:	e8 63 0d 00 00       	call   8012ec <memcpy>
		nsipcbuf.pkt.jp_len = size;
  800589:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80058c:	a3 00 70 80 00       	mov    %eax,0x807000

		ipc_send(ns_envid, NSREQ_INPUT, &nsipcbuf, PTE_U|PTE_W|PTE_P);
  800591:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800598:	00 
  800599:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  8005a0:	00 
  8005a1:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  8005a8:	00 
  8005a9:	89 3c 24             	mov    %edi,(%esp)
  8005ac:	e8 09 16 00 00       	call   801bba <ipc_send>
	}
  8005b1:	eb 89                	jmp    80053c <input+0x1c>
  8005b3:	66 90                	xchg   %ax,%ax
  8005b5:	66 90                	xchg   %ax,%ax
  8005b7:	66 90                	xchg   %ax,%ax
  8005b9:	66 90                	xchg   %ax,%ax
  8005bb:	66 90                	xchg   %ax,%ax
  8005bd:	66 90                	xchg   %ax,%ax
  8005bf:	90                   	nop

008005c0 <output>:

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  8005c0:	55                   	push   %ebp
  8005c1:	89 e5                	mov    %esp,%ebp
  8005c3:	57                   	push   %edi
  8005c4:	56                   	push   %esi
  8005c5:	53                   	push   %ebx
  8005c6:	83 ec 2c             	sub    $0x2c,%esp
	binaryname = "ns_output";
  8005c9:	c7 05 00 40 80 00 b0 	movl   $0x8033b0,0x804000
  8005d0:	33 80 00 
	envid_t srcenv;
	int perm;
	int i;

	while(true) {
		ipc_recv(&srcenv, &nsipcbuf, &perm);
  8005d3:	8d 7d e0             	lea    -0x20(%ebp),%edi
  8005d6:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8005d9:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8005dd:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8005e4:	00 
  8005e5:	89 34 24             	mov    %esi,(%esp)
  8005e8:	e8 53 15 00 00       	call   801b40 <ipc_recv>

		if(srcenv != ns_envid) continue;
  8005ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8005f3:	75 e4                	jne    8005d9 <output+0x19>
  8005f5:	bb 00 00 00 00       	mov    $0x0,%ebx

		for(i = 0; i < 50; i++) {
			if(sys_try_send_packet(nsipcbuf.pkt.jp_data, nsipcbuf.pkt.jp_len) == 0) break;
  8005fa:	a1 00 70 80 00       	mov    0x807000,%eax
  8005ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800603:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  80060a:	e8 7b 11 00 00       	call   80178a <sys_try_send_packet>
  80060f:	85 c0                	test   %eax,%eax
  800611:	74 0f                	je     800622 <output+0x62>
			sys_yield();
  800613:	e8 cc 0e 00 00       	call   8014e4 <sys_yield>
	while(true) {
		ipc_recv(&srcenv, &nsipcbuf, &perm);

		if(srcenv != ns_envid) continue;

		for(i = 0; i < 50; i++) {
  800618:	83 c3 01             	add    $0x1,%ebx
  80061b:	83 fb 32             	cmp    $0x32,%ebx
  80061e:	75 da                	jne    8005fa <output+0x3a>
  800620:	eb 05                	jmp    800627 <output+0x67>
			if(sys_try_send_packet(nsipcbuf.pkt.jp_data, nsipcbuf.pkt.jp_len) == 0) break;
			sys_yield();
		}

		if(i == 50) {
  800622:	83 fb 32             	cmp    $0x32,%ebx
  800625:	75 b2                	jne    8005d9 <output+0x19>
			cprintf("Packet failed to send after 50 tries\n");
  800627:	c7 04 24 bc 33 80 00 	movl   $0x8033bc,(%esp)
  80062e:	e8 84 04 00 00       	call   800ab7 <cprintf>
  800633:	eb a4                	jmp    8005d9 <output+0x19>
  800635:	66 90                	xchg   %ax,%ax
  800637:	66 90                	xchg   %ax,%ax
  800639:	66 90                	xchg   %ax,%ax
  80063b:	66 90                	xchg   %ax,%ax
  80063d:	66 90                	xchg   %ax,%ax
  80063f:	90                   	nop

00800640 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  800640:	55                   	push   %ebp
  800641:	89 e5                	mov    %esp,%ebp
  800643:	57                   	push   %edi
  800644:	56                   	push   %esi
  800645:	53                   	push   %ebx
  800646:	83 ec 19             	sub    $0x19,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  800649:	8b 45 08             	mov    0x8(%ebp),%eax
  80064c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  80064f:	c6 45 db 00          	movb   $0x0,-0x25(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  800653:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  800656:	c7 45 dc 08 50 80 00 	movl   $0x805008,-0x24(%ebp)
 */
char *
inet_ntoa(struct in_addr addr)
{
  static char str[16];
  u32_t s_addr = addr.s_addr;
  80065d:	be 00 00 00 00       	mov    $0x0,%esi
  800662:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  800665:	eb 02                	jmp    800669 <inet_ntoa+0x29>
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
  800667:	89 ce                	mov    %ecx,%esi
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  800669:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80066c:	0f b6 17             	movzbl (%edi),%edx
      *ap /= (u8_t)10;
  80066f:	0f b6 c2             	movzbl %dl,%eax
  800672:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
  800675:	8d 04 c8             	lea    (%eax,%ecx,8),%eax
  800678:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80067b:	66 c1 e8 0b          	shr    $0xb,%ax
  80067f:	88 07                	mov    %al,(%edi)
      inv[i++] = '0' + rem;
  800681:	8d 4e 01             	lea    0x1(%esi),%ecx
  800684:	89 f3                	mov    %esi,%ebx
  800686:	0f b6 f3             	movzbl %bl,%esi
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  800689:	8d 3c 80             	lea    (%eax,%eax,4),%edi
  80068c:	01 ff                	add    %edi,%edi
  80068e:	89 fb                	mov    %edi,%ebx
  800690:	29 da                	sub    %ebx,%edx
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
  800692:	83 c2 30             	add    $0x30,%edx
  800695:	88 54 35 ed          	mov    %dl,-0x13(%ebp,%esi,1)
    } while(*ap);
  800699:	84 c0                	test   %al,%al
  80069b:	75 ca                	jne    800667 <inet_ntoa+0x27>
  80069d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006a0:	89 c8                	mov    %ecx,%eax
  8006a2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006a5:	89 cf                	mov    %ecx,%edi
  8006a7:	eb 0d                	jmp    8006b6 <inet_ntoa+0x76>
    while(i--)
      *rp++ = inv[i];
  8006a9:	0f b6 f0             	movzbl %al,%esi
  8006ac:	0f b6 4c 35 ed       	movzbl -0x13(%ebp,%esi,1),%ecx
  8006b1:	88 0a                	mov    %cl,(%edx)
  8006b3:	83 c2 01             	add    $0x1,%edx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  8006b6:	83 e8 01             	sub    $0x1,%eax
  8006b9:	3c ff                	cmp    $0xff,%al
  8006bb:	75 ec                	jne    8006a9 <inet_ntoa+0x69>
  8006bd:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  8006c0:	89 f9                	mov    %edi,%ecx
  8006c2:	0f b6 c9             	movzbl %cl,%ecx
  8006c5:	03 4d dc             	add    -0x24(%ebp),%ecx
      *rp++ = inv[i];
    *rp++ = '.';
  8006c8:	8d 41 01             	lea    0x1(%ecx),%eax
  8006cb:	89 45 dc             	mov    %eax,-0x24(%ebp)
    ap++;
  8006ce:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  8006d2:	80 45 db 01          	addb   $0x1,-0x25(%ebp)
  8006d6:	80 7d db 03          	cmpb   $0x3,-0x25(%ebp)
  8006da:	77 0a                	ja     8006e6 <inet_ntoa+0xa6>
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
  8006dc:	c6 01 2e             	movb   $0x2e,(%ecx)
  8006df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e4:	eb 81                	jmp    800667 <inet_ntoa+0x27>
    ap++;
  }
  *--rp = 0;
  8006e6:	c6 01 00             	movb   $0x0,(%ecx)
  return str;
}
  8006e9:	b8 08 50 80 00       	mov    $0x805008,%eax
  8006ee:	83 c4 19             	add    $0x19,%esp
  8006f1:	5b                   	pop    %ebx
  8006f2:	5e                   	pop    %esi
  8006f3:	5f                   	pop    %edi
  8006f4:	5d                   	pop    %ebp
  8006f5:	c3                   	ret    

008006f6 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  8006f9:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8006fd:	66 c1 c0 08          	rol    $0x8,%ax
}
  800701:	5d                   	pop    %ebp
  800702:	c3                   	ret    

00800703 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  800703:	55                   	push   %ebp
  800704:	89 e5                	mov    %esp,%ebp
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800706:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80070a:	66 c1 c0 08          	rol    $0x8,%ax
 */
u16_t
ntohs(u16_t n)
{
  return htons(n);
}
  80070e:	5d                   	pop    %ebp
  80070f:	c3                   	ret    

00800710 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
  800716:	89 d1                	mov    %edx,%ecx
  800718:	c1 e9 18             	shr    $0x18,%ecx
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  return ((n & 0xff) << 24) |
  80071b:	89 d0                	mov    %edx,%eax
  80071d:	c1 e0 18             	shl    $0x18,%eax
  800720:	09 c8                	or     %ecx,%eax
    ((n & 0xff00) << 8) |
  800722:	89 d1                	mov    %edx,%ecx
  800724:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  80072a:	c1 e1 08             	shl    $0x8,%ecx
  80072d:	09 c8                	or     %ecx,%eax
    ((n & 0xff0000UL) >> 8) |
  80072f:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  800735:	c1 ea 08             	shr    $0x8,%edx
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  return ((n & 0xff) << 24) |
  800738:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  80073a:	5d                   	pop    %ebp
  80073b:	c3                   	ret    

0080073c <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	57                   	push   %edi
  800740:	56                   	push   %esi
  800741:	53                   	push   %ebx
  800742:	83 ec 20             	sub    $0x20,%esp
  800745:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  800748:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  80074b:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80074e:	89 75 d8             	mov    %esi,-0x28(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  800751:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800754:	80 f9 09             	cmp    $0x9,%cl
  800757:	0f 87 a6 01 00 00    	ja     800903 <inet_aton+0x1c7>
      return (0);
    val = 0;
    base = 10;
  80075d:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
    if (c == '0') {
  800764:	83 fa 30             	cmp    $0x30,%edx
  800767:	75 2b                	jne    800794 <inet_aton+0x58>
      c = *++cp;
  800769:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  80076d:	89 d1                	mov    %edx,%ecx
  80076f:	83 e1 df             	and    $0xffffffdf,%ecx
  800772:	80 f9 58             	cmp    $0x58,%cl
  800775:	74 0f                	je     800786 <inet_aton+0x4a>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  800777:	83 c0 01             	add    $0x1,%eax
  80077a:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  80077d:	c7 45 e0 08 00 00 00 	movl   $0x8,-0x20(%ebp)
  800784:	eb 0e                	jmp    800794 <inet_aton+0x58>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  800786:	0f be 50 02          	movsbl 0x2(%eax),%edx
  80078a:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  80078d:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  800794:	83 c0 01             	add    $0x1,%eax
  800797:	bf 00 00 00 00       	mov    $0x0,%edi
  80079c:	eb 03                	jmp    8007a1 <inet_aton+0x65>
  80079e:	83 c0 01             	add    $0x1,%eax
  8007a1:	8d 70 ff             	lea    -0x1(%eax),%esi
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  8007a4:	89 d3                	mov    %edx,%ebx
  8007a6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8007a9:	80 f9 09             	cmp    $0x9,%cl
  8007ac:	77 0d                	ja     8007bb <inet_aton+0x7f>
        val = (val * base) + (int)(c - '0');
  8007ae:	0f af 7d e0          	imul   -0x20(%ebp),%edi
  8007b2:	8d 7c 3a d0          	lea    -0x30(%edx,%edi,1),%edi
        c = *++cp;
  8007b6:	0f be 10             	movsbl (%eax),%edx
  8007b9:	eb e3                	jmp    80079e <inet_aton+0x62>
      } else if (base == 16 && isxdigit(c)) {
  8007bb:	83 7d e0 10          	cmpl   $0x10,-0x20(%ebp)
  8007bf:	75 30                	jne    8007f1 <inet_aton+0xb5>
  8007c1:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
  8007c4:	88 4d df             	mov    %cl,-0x21(%ebp)
  8007c7:	89 d1                	mov    %edx,%ecx
  8007c9:	83 e1 df             	and    $0xffffffdf,%ecx
  8007cc:	83 e9 41             	sub    $0x41,%ecx
  8007cf:	80 f9 05             	cmp    $0x5,%cl
  8007d2:	77 23                	ja     8007f7 <inet_aton+0xbb>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  8007d4:	89 fb                	mov    %edi,%ebx
  8007d6:	c1 e3 04             	shl    $0x4,%ebx
  8007d9:	8d 7a 0a             	lea    0xa(%edx),%edi
  8007dc:	80 7d df 1a          	cmpb   $0x1a,-0x21(%ebp)
  8007e0:	19 c9                	sbb    %ecx,%ecx
  8007e2:	83 e1 20             	and    $0x20,%ecx
  8007e5:	83 c1 41             	add    $0x41,%ecx
  8007e8:	29 cf                	sub    %ecx,%edi
  8007ea:	09 df                	or     %ebx,%edi
        c = *++cp;
  8007ec:	0f be 10             	movsbl (%eax),%edx
  8007ef:	eb ad                	jmp    80079e <inet_aton+0x62>
  8007f1:	89 d0                	mov    %edx,%eax
  8007f3:	89 f9                	mov    %edi,%ecx
  8007f5:	eb 04                	jmp    8007fb <inet_aton+0xbf>
  8007f7:	89 d0                	mov    %edx,%eax
  8007f9:	89 f9                	mov    %edi,%ecx
      } else
        break;
    }
    if (c == '.') {
  8007fb:	83 f8 2e             	cmp    $0x2e,%eax
  8007fe:	75 22                	jne    800822 <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  800800:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800803:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  800806:	0f 84 fe 00 00 00    	je     80090a <inet_aton+0x1ce>
        return (0);
      *pp++ = val;
  80080c:	83 45 d8 04          	addl   $0x4,-0x28(%ebp)
  800810:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800813:	89 48 fc             	mov    %ecx,-0x4(%eax)
      c = *++cp;
  800816:	8d 46 01             	lea    0x1(%esi),%eax
  800819:	0f be 56 01          	movsbl 0x1(%esi),%edx
    } else
      break;
  }
  80081d:	e9 2f ff ff ff       	jmp    800751 <inet_aton+0x15>
  800822:	89 f9                	mov    %edi,%ecx
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  800824:	85 d2                	test   %edx,%edx
  800826:	74 27                	je     80084f <inet_aton+0x113>
    return (0);
  800828:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  80082d:	80 fb 1f             	cmp    $0x1f,%bl
  800830:	0f 86 e7 00 00 00    	jbe    80091d <inet_aton+0x1e1>
  800836:	84 d2                	test   %dl,%dl
  800838:	0f 88 d3 00 00 00    	js     800911 <inet_aton+0x1d5>
  80083e:	83 fa 20             	cmp    $0x20,%edx
  800841:	74 0c                	je     80084f <inet_aton+0x113>
  800843:	83 ea 09             	sub    $0x9,%edx
  800846:	83 fa 04             	cmp    $0x4,%edx
  800849:	0f 87 ce 00 00 00    	ja     80091d <inet_aton+0x1e1>
    return (0);
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  80084f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800852:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800855:	29 c2                	sub    %eax,%edx
  800857:	c1 fa 02             	sar    $0x2,%edx
  80085a:	83 c2 01             	add    $0x1,%edx
  switch (n) {
  80085d:	83 fa 02             	cmp    $0x2,%edx
  800860:	74 22                	je     800884 <inet_aton+0x148>
  800862:	83 fa 02             	cmp    $0x2,%edx
  800865:	7f 0f                	jg     800876 <inet_aton+0x13a>

  case 0:
    return (0);       /* initial nondigit */
  800867:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  80086c:	85 d2                	test   %edx,%edx
  80086e:	0f 84 a9 00 00 00    	je     80091d <inet_aton+0x1e1>
  800874:	eb 73                	jmp    8008e9 <inet_aton+0x1ad>
  800876:	83 fa 03             	cmp    $0x3,%edx
  800879:	74 26                	je     8008a1 <inet_aton+0x165>
  80087b:	83 fa 04             	cmp    $0x4,%edx
  80087e:	66 90                	xchg   %ax,%ax
  800880:	74 40                	je     8008c2 <inet_aton+0x186>
  800882:	eb 65                	jmp    8008e9 <inet_aton+0x1ad>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  800884:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  800889:	81 f9 ff ff ff 00    	cmp    $0xffffff,%ecx
  80088f:	0f 87 88 00 00 00    	ja     80091d <inet_aton+0x1e1>
      return (0);
    val |= parts[0] << 24;
  800895:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800898:	c1 e0 18             	shl    $0x18,%eax
  80089b:	89 cf                	mov    %ecx,%edi
  80089d:	09 c7                	or     %eax,%edi
    break;
  80089f:	eb 48                	jmp    8008e9 <inet_aton+0x1ad>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  8008a1:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  8008a6:	81 f9 ff ff 00 00    	cmp    $0xffff,%ecx
  8008ac:	77 6f                	ja     80091d <inet_aton+0x1e1>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  8008ae:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8008b1:	c1 e2 10             	shl    $0x10,%edx
  8008b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008b7:	c1 e0 18             	shl    $0x18,%eax
  8008ba:	09 d0                	or     %edx,%eax
  8008bc:	09 c8                	or     %ecx,%eax
  8008be:	89 c7                	mov    %eax,%edi
    break;
  8008c0:	eb 27                	jmp    8008e9 <inet_aton+0x1ad>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  8008c2:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  8008c7:	81 f9 ff 00 00 00    	cmp    $0xff,%ecx
  8008cd:	77 4e                	ja     80091d <inet_aton+0x1e1>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  8008cf:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8008d2:	c1 e2 10             	shl    $0x10,%edx
  8008d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008d8:	c1 e0 18             	shl    $0x18,%eax
  8008db:	09 c2                	or     %eax,%edx
  8008dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008e0:	c1 e0 08             	shl    $0x8,%eax
  8008e3:	09 d0                	or     %edx,%eax
  8008e5:	09 c8                	or     %ecx,%eax
  8008e7:	89 c7                	mov    %eax,%edi
    break;
  }
  if (addr)
  8008e9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008ed:	74 29                	je     800918 <inet_aton+0x1dc>
    addr->s_addr = htonl(val);
  8008ef:	89 3c 24             	mov    %edi,(%esp)
  8008f2:	e8 19 fe ff ff       	call   800710 <htonl>
  8008f7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008fa:	89 06                	mov    %eax,(%esi)
  return (1);
  8008fc:	b8 01 00 00 00       	mov    $0x1,%eax
  800901:	eb 1a                	jmp    80091d <inet_aton+0x1e1>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  800903:	b8 00 00 00 00       	mov    $0x0,%eax
  800908:	eb 13                	jmp    80091d <inet_aton+0x1e1>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  80090a:	b8 00 00 00 00       	mov    $0x0,%eax
  80090f:	eb 0c                	jmp    80091d <inet_aton+0x1e1>
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
    return (0);
  800911:	b8 00 00 00 00       	mov    $0x0,%eax
  800916:	eb 05                	jmp    80091d <inet_aton+0x1e1>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  800918:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80091d:	83 c4 20             	add    $0x20,%esp
  800920:	5b                   	pop    %ebx
  800921:	5e                   	pop    %esi
  800922:	5f                   	pop    %edi
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	83 ec 18             	sub    $0x18,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  80092b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80092e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800932:	8b 45 08             	mov    0x8(%ebp),%eax
  800935:	89 04 24             	mov    %eax,(%esp)
  800938:	e8 ff fd ff ff       	call   80073c <inet_aton>
  80093d:	85 c0                	test   %eax,%eax
    return (val.s_addr);
  80093f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800944:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  800948:	c9                   	leave  
  800949:	c3                   	ret    

0080094a <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	83 ec 04             	sub    $0x4,%esp
  return htonl(n);
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	89 04 24             	mov    %eax,(%esp)
  800956:	e8 b5 fd ff ff       	call   800710 <htonl>
}
  80095b:	c9                   	leave  
  80095c:	c3                   	ret    

0080095d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	56                   	push   %esi
  800961:	53                   	push   %ebx
  800962:	83 ec 10             	sub    $0x10,%esp
  800965:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800968:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  80096b:	e8 55 0b 00 00       	call   8014c5 <sys_getenvid>
  800970:	25 ff 03 00 00       	and    $0x3ff,%eax
  800975:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800978:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80097d:	a3 20 50 80 00       	mov    %eax,0x805020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800982:	85 db                	test   %ebx,%ebx
  800984:	7e 07                	jle    80098d <libmain+0x30>
		binaryname = argv[0];
  800986:	8b 06                	mov    (%esi),%eax
  800988:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  80098d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800991:	89 1c 24             	mov    %ebx,(%esp)
  800994:	e8 a7 f6 ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  800999:	e8 07 00 00 00       	call   8009a5 <exit>
}
  80099e:	83 c4 10             	add    $0x10,%esp
  8009a1:	5b                   	pop    %ebx
  8009a2:	5e                   	pop    %esi
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8009ab:	e8 8a 14 00 00       	call   801e3a <close_all>
	sys_env_destroy(0);
  8009b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009b7:	e8 b7 0a 00 00       	call   801473 <sys_env_destroy>
}
  8009bc:	c9                   	leave  
  8009bd:	c3                   	ret    

008009be <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	56                   	push   %esi
  8009c2:	53                   	push   %ebx
  8009c3:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8009c6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8009c9:	8b 35 00 40 80 00    	mov    0x804000,%esi
  8009cf:	e8 f1 0a 00 00       	call   8014c5 <sys_getenvid>
  8009d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8009db:	8b 55 08             	mov    0x8(%ebp),%edx
  8009de:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009e2:	89 74 24 08          	mov    %esi,0x8(%esp)
  8009e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ea:	c7 04 24 ec 33 80 00 	movl   $0x8033ec,(%esp)
  8009f1:	e8 c1 00 00 00       	call   800ab7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8009f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8009fd:	89 04 24             	mov    %eax,(%esp)
  800a00:	e8 51 00 00 00       	call   800a56 <vcprintf>
	cprintf("\n");
  800a05:	c7 04 24 1b 33 80 00 	movl   $0x80331b,(%esp)
  800a0c:	e8 a6 00 00 00       	call   800ab7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a11:	cc                   	int3   
  800a12:	eb fd                	jmp    800a11 <_panic+0x53>

00800a14 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	53                   	push   %ebx
  800a18:	83 ec 14             	sub    $0x14,%esp
  800a1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a1e:	8b 13                	mov    (%ebx),%edx
  800a20:	8d 42 01             	lea    0x1(%edx),%eax
  800a23:	89 03                	mov    %eax,(%ebx)
  800a25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a28:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800a2c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a31:	75 19                	jne    800a4c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800a33:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800a3a:	00 
  800a3b:	8d 43 08             	lea    0x8(%ebx),%eax
  800a3e:	89 04 24             	mov    %eax,(%esp)
  800a41:	e8 f0 09 00 00       	call   801436 <sys_cputs>
		b->idx = 0;
  800a46:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800a4c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800a50:	83 c4 14             	add    $0x14,%esp
  800a53:	5b                   	pop    %ebx
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800a5f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800a66:	00 00 00 
	b.cnt = 0;
  800a69:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800a70:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800a73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a76:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a81:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800a87:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a8b:	c7 04 24 14 0a 80 00 	movl   $0x800a14,(%esp)
  800a92:	e8 b7 01 00 00       	call   800c4e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800a97:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800a9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800aa7:	89 04 24             	mov    %eax,(%esp)
  800aaa:	e8 87 09 00 00       	call   801436 <sys_cputs>

	return b.cnt;
}
  800aaf:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800ab5:	c9                   	leave  
  800ab6:	c3                   	ret    

00800ab7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800abd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800ac0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac7:	89 04 24             	mov    %eax,(%esp)
  800aca:	e8 87 ff ff ff       	call   800a56 <vcprintf>
	va_end(ap);

	return cnt;
}
  800acf:	c9                   	leave  
  800ad0:	c3                   	ret    
  800ad1:	66 90                	xchg   %ax,%ax
  800ad3:	66 90                	xchg   %ax,%ax
  800ad5:	66 90                	xchg   %ax,%ax
  800ad7:	66 90                	xchg   %ax,%ax
  800ad9:	66 90                	xchg   %ax,%ax
  800adb:	66 90                	xchg   %ax,%ax
  800add:	66 90                	xchg   %ax,%ax
  800adf:	90                   	nop

00800ae0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	57                   	push   %edi
  800ae4:	56                   	push   %esi
  800ae5:	53                   	push   %ebx
  800ae6:	83 ec 3c             	sub    $0x3c,%esp
  800ae9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800aec:	89 d7                	mov    %edx,%edi
  800aee:	8b 45 08             	mov    0x8(%ebp),%eax
  800af1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800af4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af7:	89 c3                	mov    %eax,%ebx
  800af9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800afc:	8b 45 10             	mov    0x10(%ebp),%eax
  800aff:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b07:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b0a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b0d:	39 d9                	cmp    %ebx,%ecx
  800b0f:	72 05                	jb     800b16 <printnum+0x36>
  800b11:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800b14:	77 69                	ja     800b7f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b16:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800b19:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800b1d:	83 ee 01             	sub    $0x1,%esi
  800b20:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800b24:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b28:	8b 44 24 08          	mov    0x8(%esp),%eax
  800b2c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800b30:	89 c3                	mov    %eax,%ebx
  800b32:	89 d6                	mov    %edx,%esi
  800b34:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b37:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800b3a:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b3e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800b42:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b45:	89 04 24             	mov    %eax,(%esp)
  800b48:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800b4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b4f:	e8 7c 24 00 00       	call   802fd0 <__udivdi3>
  800b54:	89 d9                	mov    %ebx,%ecx
  800b56:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800b5a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800b5e:	89 04 24             	mov    %eax,(%esp)
  800b61:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b65:	89 fa                	mov    %edi,%edx
  800b67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b6a:	e8 71 ff ff ff       	call   800ae0 <printnum>
  800b6f:	eb 1b                	jmp    800b8c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b71:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b75:	8b 45 18             	mov    0x18(%ebp),%eax
  800b78:	89 04 24             	mov    %eax,(%esp)
  800b7b:	ff d3                	call   *%ebx
  800b7d:	eb 03                	jmp    800b82 <printnum+0xa2>
  800b7f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b82:	83 ee 01             	sub    $0x1,%esi
  800b85:	85 f6                	test   %esi,%esi
  800b87:	7f e8                	jg     800b71 <printnum+0x91>
  800b89:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800b8c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b90:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b94:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b97:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800b9a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b9e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ba2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ba5:	89 04 24             	mov    %eax,(%esp)
  800ba8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800bab:	89 44 24 04          	mov    %eax,0x4(%esp)
  800baf:	e8 4c 25 00 00       	call   803100 <__umoddi3>
  800bb4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bb8:	0f be 80 0f 34 80 00 	movsbl 0x80340f(%eax),%eax
  800bbf:	89 04 24             	mov    %eax,(%esp)
  800bc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800bc5:	ff d0                	call   *%eax
}
  800bc7:	83 c4 3c             	add    $0x3c,%esp
  800bca:	5b                   	pop    %ebx
  800bcb:	5e                   	pop    %esi
  800bcc:	5f                   	pop    %edi
  800bcd:	5d                   	pop    %ebp
  800bce:	c3                   	ret    

00800bcf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800bd2:	83 fa 01             	cmp    $0x1,%edx
  800bd5:	7e 0e                	jle    800be5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800bd7:	8b 10                	mov    (%eax),%edx
  800bd9:	8d 4a 08             	lea    0x8(%edx),%ecx
  800bdc:	89 08                	mov    %ecx,(%eax)
  800bde:	8b 02                	mov    (%edx),%eax
  800be0:	8b 52 04             	mov    0x4(%edx),%edx
  800be3:	eb 22                	jmp    800c07 <getuint+0x38>
	else if (lflag)
  800be5:	85 d2                	test   %edx,%edx
  800be7:	74 10                	je     800bf9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800be9:	8b 10                	mov    (%eax),%edx
  800beb:	8d 4a 04             	lea    0x4(%edx),%ecx
  800bee:	89 08                	mov    %ecx,(%eax)
  800bf0:	8b 02                	mov    (%edx),%eax
  800bf2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf7:	eb 0e                	jmp    800c07 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800bf9:	8b 10                	mov    (%eax),%edx
  800bfb:	8d 4a 04             	lea    0x4(%edx),%ecx
  800bfe:	89 08                	mov    %ecx,(%eax)
  800c00:	8b 02                	mov    (%edx),%eax
  800c02:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    

00800c09 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800c0f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800c13:	8b 10                	mov    (%eax),%edx
  800c15:	3b 50 04             	cmp    0x4(%eax),%edx
  800c18:	73 0a                	jae    800c24 <sprintputch+0x1b>
		*b->buf++ = ch;
  800c1a:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c1d:	89 08                	mov    %ecx,(%eax)
  800c1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c22:	88 02                	mov    %al,(%edx)
}
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800c2c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c2f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c33:	8b 45 10             	mov    0x10(%ebp),%eax
  800c36:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c41:	8b 45 08             	mov    0x8(%ebp),%eax
  800c44:	89 04 24             	mov    %eax,(%esp)
  800c47:	e8 02 00 00 00       	call   800c4e <vprintfmt>
	va_end(ap);
}
  800c4c:	c9                   	leave  
  800c4d:	c3                   	ret    

00800c4e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	57                   	push   %edi
  800c52:	56                   	push   %esi
  800c53:	53                   	push   %ebx
  800c54:	83 ec 3c             	sub    $0x3c,%esp
  800c57:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5d:	eb 14                	jmp    800c73 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	0f 84 b3 03 00 00    	je     80101a <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800c67:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c6b:	89 04 24             	mov    %eax,(%esp)
  800c6e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c71:	89 f3                	mov    %esi,%ebx
  800c73:	8d 73 01             	lea    0x1(%ebx),%esi
  800c76:	0f b6 03             	movzbl (%ebx),%eax
  800c79:	83 f8 25             	cmp    $0x25,%eax
  800c7c:	75 e1                	jne    800c5f <vprintfmt+0x11>
  800c7e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800c82:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800c89:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800c90:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800c97:	ba 00 00 00 00       	mov    $0x0,%edx
  800c9c:	eb 1d                	jmp    800cbb <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c9e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800ca0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800ca4:	eb 15                	jmp    800cbb <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ca6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800ca8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800cac:	eb 0d                	jmp    800cbb <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800cae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800cb1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800cb4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cbb:	8d 5e 01             	lea    0x1(%esi),%ebx
  800cbe:	0f b6 0e             	movzbl (%esi),%ecx
  800cc1:	0f b6 c1             	movzbl %cl,%eax
  800cc4:	83 e9 23             	sub    $0x23,%ecx
  800cc7:	80 f9 55             	cmp    $0x55,%cl
  800cca:	0f 87 2a 03 00 00    	ja     800ffa <vprintfmt+0x3ac>
  800cd0:	0f b6 c9             	movzbl %cl,%ecx
  800cd3:	ff 24 8d 60 35 80 00 	jmp    *0x803560(,%ecx,4)
  800cda:	89 de                	mov    %ebx,%esi
  800cdc:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800ce1:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800ce4:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800ce8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800ceb:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800cee:	83 fb 09             	cmp    $0x9,%ebx
  800cf1:	77 36                	ja     800d29 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800cf3:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800cf6:	eb e9                	jmp    800ce1 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800cf8:	8b 45 14             	mov    0x14(%ebp),%eax
  800cfb:	8d 48 04             	lea    0x4(%eax),%ecx
  800cfe:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800d01:	8b 00                	mov    (%eax),%eax
  800d03:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d06:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800d08:	eb 22                	jmp    800d2c <vprintfmt+0xde>
  800d0a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800d0d:	85 c9                	test   %ecx,%ecx
  800d0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d14:	0f 49 c1             	cmovns %ecx,%eax
  800d17:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d1a:	89 de                	mov    %ebx,%esi
  800d1c:	eb 9d                	jmp    800cbb <vprintfmt+0x6d>
  800d1e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800d20:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800d27:	eb 92                	jmp    800cbb <vprintfmt+0x6d>
  800d29:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  800d2c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800d30:	79 89                	jns    800cbb <vprintfmt+0x6d>
  800d32:	e9 77 ff ff ff       	jmp    800cae <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800d37:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d3a:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800d3c:	e9 7a ff ff ff       	jmp    800cbb <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d41:	8b 45 14             	mov    0x14(%ebp),%eax
  800d44:	8d 50 04             	lea    0x4(%eax),%edx
  800d47:	89 55 14             	mov    %edx,0x14(%ebp)
  800d4a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d4e:	8b 00                	mov    (%eax),%eax
  800d50:	89 04 24             	mov    %eax,(%esp)
  800d53:	ff 55 08             	call   *0x8(%ebp)
			break;
  800d56:	e9 18 ff ff ff       	jmp    800c73 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d5b:	8b 45 14             	mov    0x14(%ebp),%eax
  800d5e:	8d 50 04             	lea    0x4(%eax),%edx
  800d61:	89 55 14             	mov    %edx,0x14(%ebp)
  800d64:	8b 00                	mov    (%eax),%eax
  800d66:	99                   	cltd   
  800d67:	31 d0                	xor    %edx,%eax
  800d69:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d6b:	83 f8 0f             	cmp    $0xf,%eax
  800d6e:	7f 0b                	jg     800d7b <vprintfmt+0x12d>
  800d70:	8b 14 85 c0 36 80 00 	mov    0x8036c0(,%eax,4),%edx
  800d77:	85 d2                	test   %edx,%edx
  800d79:	75 20                	jne    800d9b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  800d7b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d7f:	c7 44 24 08 27 34 80 	movl   $0x803427,0x8(%esp)
  800d86:	00 
  800d87:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8e:	89 04 24             	mov    %eax,(%esp)
  800d91:	e8 90 fe ff ff       	call   800c26 <printfmt>
  800d96:	e9 d8 fe ff ff       	jmp    800c73 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800d9b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d9f:	c7 44 24 08 ad 38 80 	movl   $0x8038ad,0x8(%esp)
  800da6:	00 
  800da7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800dab:	8b 45 08             	mov    0x8(%ebp),%eax
  800dae:	89 04 24             	mov    %eax,(%esp)
  800db1:	e8 70 fe ff ff       	call   800c26 <printfmt>
  800db6:	e9 b8 fe ff ff       	jmp    800c73 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dbb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800dbe:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800dc1:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800dc4:	8b 45 14             	mov    0x14(%ebp),%eax
  800dc7:	8d 50 04             	lea    0x4(%eax),%edx
  800dca:	89 55 14             	mov    %edx,0x14(%ebp)
  800dcd:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800dcf:	85 f6                	test   %esi,%esi
  800dd1:	b8 20 34 80 00       	mov    $0x803420,%eax
  800dd6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800dd9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800ddd:	0f 84 97 00 00 00    	je     800e7a <vprintfmt+0x22c>
  800de3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800de7:	0f 8e 9b 00 00 00    	jle    800e88 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800ded:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800df1:	89 34 24             	mov    %esi,(%esp)
  800df4:	e8 cf 02 00 00       	call   8010c8 <strnlen>
  800df9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800dfc:	29 c2                	sub    %eax,%edx
  800dfe:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800e01:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800e05:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e08:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800e0b:	8b 75 08             	mov    0x8(%ebp),%esi
  800e0e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800e11:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e13:	eb 0f                	jmp    800e24 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800e15:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e19:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800e1c:	89 04 24             	mov    %eax,(%esp)
  800e1f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e21:	83 eb 01             	sub    $0x1,%ebx
  800e24:	85 db                	test   %ebx,%ebx
  800e26:	7f ed                	jg     800e15 <vprintfmt+0x1c7>
  800e28:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800e2b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800e2e:	85 d2                	test   %edx,%edx
  800e30:	b8 00 00 00 00       	mov    $0x0,%eax
  800e35:	0f 49 c2             	cmovns %edx,%eax
  800e38:	29 c2                	sub    %eax,%edx
  800e3a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800e3d:	89 d7                	mov    %edx,%edi
  800e3f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800e42:	eb 50                	jmp    800e94 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800e44:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800e48:	74 1e                	je     800e68 <vprintfmt+0x21a>
  800e4a:	0f be d2             	movsbl %dl,%edx
  800e4d:	83 ea 20             	sub    $0x20,%edx
  800e50:	83 fa 5e             	cmp    $0x5e,%edx
  800e53:	76 13                	jbe    800e68 <vprintfmt+0x21a>
					putch('?', putdat);
  800e55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e58:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e5c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800e63:	ff 55 08             	call   *0x8(%ebp)
  800e66:	eb 0d                	jmp    800e75 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800e68:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e6b:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e6f:	89 04 24             	mov    %eax,(%esp)
  800e72:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e75:	83 ef 01             	sub    $0x1,%edi
  800e78:	eb 1a                	jmp    800e94 <vprintfmt+0x246>
  800e7a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800e7d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800e80:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800e83:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800e86:	eb 0c                	jmp    800e94 <vprintfmt+0x246>
  800e88:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800e8b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800e8e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800e91:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800e94:	83 c6 01             	add    $0x1,%esi
  800e97:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800e9b:	0f be c2             	movsbl %dl,%eax
  800e9e:	85 c0                	test   %eax,%eax
  800ea0:	74 27                	je     800ec9 <vprintfmt+0x27b>
  800ea2:	85 db                	test   %ebx,%ebx
  800ea4:	78 9e                	js     800e44 <vprintfmt+0x1f6>
  800ea6:	83 eb 01             	sub    $0x1,%ebx
  800ea9:	79 99                	jns    800e44 <vprintfmt+0x1f6>
  800eab:	89 f8                	mov    %edi,%eax
  800ead:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800eb0:	8b 75 08             	mov    0x8(%ebp),%esi
  800eb3:	89 c3                	mov    %eax,%ebx
  800eb5:	eb 1a                	jmp    800ed1 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800eb7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ebb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800ec2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ec4:	83 eb 01             	sub    $0x1,%ebx
  800ec7:	eb 08                	jmp    800ed1 <vprintfmt+0x283>
  800ec9:	89 fb                	mov    %edi,%ebx
  800ecb:	8b 75 08             	mov    0x8(%ebp),%esi
  800ece:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ed1:	85 db                	test   %ebx,%ebx
  800ed3:	7f e2                	jg     800eb7 <vprintfmt+0x269>
  800ed5:	89 75 08             	mov    %esi,0x8(%ebp)
  800ed8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800edb:	e9 93 fd ff ff       	jmp    800c73 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ee0:	83 fa 01             	cmp    $0x1,%edx
  800ee3:	7e 16                	jle    800efb <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800ee5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ee8:	8d 50 08             	lea    0x8(%eax),%edx
  800eeb:	89 55 14             	mov    %edx,0x14(%ebp)
  800eee:	8b 50 04             	mov    0x4(%eax),%edx
  800ef1:	8b 00                	mov    (%eax),%eax
  800ef3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ef6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800ef9:	eb 32                	jmp    800f2d <vprintfmt+0x2df>
	else if (lflag)
  800efb:	85 d2                	test   %edx,%edx
  800efd:	74 18                	je     800f17 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  800eff:	8b 45 14             	mov    0x14(%ebp),%eax
  800f02:	8d 50 04             	lea    0x4(%eax),%edx
  800f05:	89 55 14             	mov    %edx,0x14(%ebp)
  800f08:	8b 30                	mov    (%eax),%esi
  800f0a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800f0d:	89 f0                	mov    %esi,%eax
  800f0f:	c1 f8 1f             	sar    $0x1f,%eax
  800f12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f15:	eb 16                	jmp    800f2d <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800f17:	8b 45 14             	mov    0x14(%ebp),%eax
  800f1a:	8d 50 04             	lea    0x4(%eax),%edx
  800f1d:	89 55 14             	mov    %edx,0x14(%ebp)
  800f20:	8b 30                	mov    (%eax),%esi
  800f22:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800f25:	89 f0                	mov    %esi,%eax
  800f27:	c1 f8 1f             	sar    $0x1f,%eax
  800f2a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800f2d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f30:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800f33:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800f38:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f3c:	0f 89 80 00 00 00    	jns    800fc2 <vprintfmt+0x374>
				putch('-', putdat);
  800f42:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f46:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800f4d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800f50:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f53:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f56:	f7 d8                	neg    %eax
  800f58:	83 d2 00             	adc    $0x0,%edx
  800f5b:	f7 da                	neg    %edx
			}
			base = 10;
  800f5d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800f62:	eb 5e                	jmp    800fc2 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800f64:	8d 45 14             	lea    0x14(%ebp),%eax
  800f67:	e8 63 fc ff ff       	call   800bcf <getuint>
			base = 10;
  800f6c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800f71:	eb 4f                	jmp    800fc2 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800f73:	8d 45 14             	lea    0x14(%ebp),%eax
  800f76:	e8 54 fc ff ff       	call   800bcf <getuint>
			base = 8;
  800f7b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800f80:	eb 40                	jmp    800fc2 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800f82:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f86:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800f8d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800f90:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f94:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800f9b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f9e:	8b 45 14             	mov    0x14(%ebp),%eax
  800fa1:	8d 50 04             	lea    0x4(%eax),%edx
  800fa4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800fa7:	8b 00                	mov    (%eax),%eax
  800fa9:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800fae:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800fb3:	eb 0d                	jmp    800fc2 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800fb5:	8d 45 14             	lea    0x14(%ebp),%eax
  800fb8:	e8 12 fc ff ff       	call   800bcf <getuint>
			base = 16;
  800fbd:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800fc2:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800fc6:	89 74 24 10          	mov    %esi,0x10(%esp)
  800fca:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800fcd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800fd1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fd5:	89 04 24             	mov    %eax,(%esp)
  800fd8:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fdc:	89 fa                	mov    %edi,%edx
  800fde:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe1:	e8 fa fa ff ff       	call   800ae0 <printnum>
			break;
  800fe6:	e9 88 fc ff ff       	jmp    800c73 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800feb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fef:	89 04 24             	mov    %eax,(%esp)
  800ff2:	ff 55 08             	call   *0x8(%ebp)
			break;
  800ff5:	e9 79 fc ff ff       	jmp    800c73 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ffa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ffe:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801005:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801008:	89 f3                	mov    %esi,%ebx
  80100a:	eb 03                	jmp    80100f <vprintfmt+0x3c1>
  80100c:	83 eb 01             	sub    $0x1,%ebx
  80100f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  801013:	75 f7                	jne    80100c <vprintfmt+0x3be>
  801015:	e9 59 fc ff ff       	jmp    800c73 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  80101a:	83 c4 3c             	add    $0x3c,%esp
  80101d:	5b                   	pop    %ebx
  80101e:	5e                   	pop    %esi
  80101f:	5f                   	pop    %edi
  801020:	5d                   	pop    %ebp
  801021:	c3                   	ret    

00801022 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
  801025:	83 ec 28             	sub    $0x28,%esp
  801028:	8b 45 08             	mov    0x8(%ebp),%eax
  80102b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80102e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801031:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801035:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801038:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80103f:	85 c0                	test   %eax,%eax
  801041:	74 30                	je     801073 <vsnprintf+0x51>
  801043:	85 d2                	test   %edx,%edx
  801045:	7e 2c                	jle    801073 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801047:	8b 45 14             	mov    0x14(%ebp),%eax
  80104a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80104e:	8b 45 10             	mov    0x10(%ebp),%eax
  801051:	89 44 24 08          	mov    %eax,0x8(%esp)
  801055:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80105c:	c7 04 24 09 0c 80 00 	movl   $0x800c09,(%esp)
  801063:	e8 e6 fb ff ff       	call   800c4e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801068:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80106b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80106e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801071:	eb 05                	jmp    801078 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801073:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801078:	c9                   	leave  
  801079:	c3                   	ret    

0080107a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
  80107d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801080:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801083:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801087:	8b 45 10             	mov    0x10(%ebp),%eax
  80108a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80108e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801091:	89 44 24 04          	mov    %eax,0x4(%esp)
  801095:	8b 45 08             	mov    0x8(%ebp),%eax
  801098:	89 04 24             	mov    %eax,(%esp)
  80109b:	e8 82 ff ff ff       	call   801022 <vsnprintf>
	va_end(ap);

	return rc;
}
  8010a0:	c9                   	leave  
  8010a1:	c3                   	ret    
  8010a2:	66 90                	xchg   %ax,%ax
  8010a4:	66 90                	xchg   %ax,%ax
  8010a6:	66 90                	xchg   %ax,%ax
  8010a8:	66 90                	xchg   %ax,%ax
  8010aa:	66 90                	xchg   %ax,%ax
  8010ac:	66 90                	xchg   %ax,%ax
  8010ae:	66 90                	xchg   %ax,%ax

008010b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8010b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8010bb:	eb 03                	jmp    8010c0 <strlen+0x10>
		n++;
  8010bd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8010c0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8010c4:	75 f7                	jne    8010bd <strlen+0xd>
		n++;
	return n;
}
  8010c6:	5d                   	pop    %ebp
  8010c7:	c3                   	ret    

008010c8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
  8010cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ce:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8010d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d6:	eb 03                	jmp    8010db <strnlen+0x13>
		n++;
  8010d8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8010db:	39 d0                	cmp    %edx,%eax
  8010dd:	74 06                	je     8010e5 <strnlen+0x1d>
  8010df:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8010e3:	75 f3                	jne    8010d8 <strnlen+0x10>
		n++;
	return n;
}
  8010e5:	5d                   	pop    %ebp
  8010e6:	c3                   	ret    

008010e7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8010e7:	55                   	push   %ebp
  8010e8:	89 e5                	mov    %esp,%ebp
  8010ea:	53                   	push   %ebx
  8010eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8010f1:	89 c2                	mov    %eax,%edx
  8010f3:	83 c2 01             	add    $0x1,%edx
  8010f6:	83 c1 01             	add    $0x1,%ecx
  8010f9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8010fd:	88 5a ff             	mov    %bl,-0x1(%edx)
  801100:	84 db                	test   %bl,%bl
  801102:	75 ef                	jne    8010f3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801104:	5b                   	pop    %ebx
  801105:	5d                   	pop    %ebp
  801106:	c3                   	ret    

00801107 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	53                   	push   %ebx
  80110b:	83 ec 08             	sub    $0x8,%esp
  80110e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801111:	89 1c 24             	mov    %ebx,(%esp)
  801114:	e8 97 ff ff ff       	call   8010b0 <strlen>
	strcpy(dst + len, src);
  801119:	8b 55 0c             	mov    0xc(%ebp),%edx
  80111c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801120:	01 d8                	add    %ebx,%eax
  801122:	89 04 24             	mov    %eax,(%esp)
  801125:	e8 bd ff ff ff       	call   8010e7 <strcpy>
	return dst;
}
  80112a:	89 d8                	mov    %ebx,%eax
  80112c:	83 c4 08             	add    $0x8,%esp
  80112f:	5b                   	pop    %ebx
  801130:	5d                   	pop    %ebp
  801131:	c3                   	ret    

00801132 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801132:	55                   	push   %ebp
  801133:	89 e5                	mov    %esp,%ebp
  801135:	56                   	push   %esi
  801136:	53                   	push   %ebx
  801137:	8b 75 08             	mov    0x8(%ebp),%esi
  80113a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113d:	89 f3                	mov    %esi,%ebx
  80113f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801142:	89 f2                	mov    %esi,%edx
  801144:	eb 0f                	jmp    801155 <strncpy+0x23>
		*dst++ = *src;
  801146:	83 c2 01             	add    $0x1,%edx
  801149:	0f b6 01             	movzbl (%ecx),%eax
  80114c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80114f:	80 39 01             	cmpb   $0x1,(%ecx)
  801152:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801155:	39 da                	cmp    %ebx,%edx
  801157:	75 ed                	jne    801146 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801159:	89 f0                	mov    %esi,%eax
  80115b:	5b                   	pop    %ebx
  80115c:	5e                   	pop    %esi
  80115d:	5d                   	pop    %ebp
  80115e:	c3                   	ret    

0080115f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80115f:	55                   	push   %ebp
  801160:	89 e5                	mov    %esp,%ebp
  801162:	56                   	push   %esi
  801163:	53                   	push   %ebx
  801164:	8b 75 08             	mov    0x8(%ebp),%esi
  801167:	8b 55 0c             	mov    0xc(%ebp),%edx
  80116a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80116d:	89 f0                	mov    %esi,%eax
  80116f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801173:	85 c9                	test   %ecx,%ecx
  801175:	75 0b                	jne    801182 <strlcpy+0x23>
  801177:	eb 1d                	jmp    801196 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801179:	83 c0 01             	add    $0x1,%eax
  80117c:	83 c2 01             	add    $0x1,%edx
  80117f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801182:	39 d8                	cmp    %ebx,%eax
  801184:	74 0b                	je     801191 <strlcpy+0x32>
  801186:	0f b6 0a             	movzbl (%edx),%ecx
  801189:	84 c9                	test   %cl,%cl
  80118b:	75 ec                	jne    801179 <strlcpy+0x1a>
  80118d:	89 c2                	mov    %eax,%edx
  80118f:	eb 02                	jmp    801193 <strlcpy+0x34>
  801191:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801193:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801196:	29 f0                	sub    %esi,%eax
}
  801198:	5b                   	pop    %ebx
  801199:	5e                   	pop    %esi
  80119a:	5d                   	pop    %ebp
  80119b:	c3                   	ret    

0080119c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
  80119f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8011a5:	eb 06                	jmp    8011ad <strcmp+0x11>
		p++, q++;
  8011a7:	83 c1 01             	add    $0x1,%ecx
  8011aa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8011ad:	0f b6 01             	movzbl (%ecx),%eax
  8011b0:	84 c0                	test   %al,%al
  8011b2:	74 04                	je     8011b8 <strcmp+0x1c>
  8011b4:	3a 02                	cmp    (%edx),%al
  8011b6:	74 ef                	je     8011a7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8011b8:	0f b6 c0             	movzbl %al,%eax
  8011bb:	0f b6 12             	movzbl (%edx),%edx
  8011be:	29 d0                	sub    %edx,%eax
}
  8011c0:	5d                   	pop    %ebp
  8011c1:	c3                   	ret    

008011c2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8011c2:	55                   	push   %ebp
  8011c3:	89 e5                	mov    %esp,%ebp
  8011c5:	53                   	push   %ebx
  8011c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011cc:	89 c3                	mov    %eax,%ebx
  8011ce:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8011d1:	eb 06                	jmp    8011d9 <strncmp+0x17>
		n--, p++, q++;
  8011d3:	83 c0 01             	add    $0x1,%eax
  8011d6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8011d9:	39 d8                	cmp    %ebx,%eax
  8011db:	74 15                	je     8011f2 <strncmp+0x30>
  8011dd:	0f b6 08             	movzbl (%eax),%ecx
  8011e0:	84 c9                	test   %cl,%cl
  8011e2:	74 04                	je     8011e8 <strncmp+0x26>
  8011e4:	3a 0a                	cmp    (%edx),%cl
  8011e6:	74 eb                	je     8011d3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8011e8:	0f b6 00             	movzbl (%eax),%eax
  8011eb:	0f b6 12             	movzbl (%edx),%edx
  8011ee:	29 d0                	sub    %edx,%eax
  8011f0:	eb 05                	jmp    8011f7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8011f2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8011f7:	5b                   	pop    %ebx
  8011f8:	5d                   	pop    %ebp
  8011f9:	c3                   	ret    

008011fa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801200:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801204:	eb 07                	jmp    80120d <strchr+0x13>
		if (*s == c)
  801206:	38 ca                	cmp    %cl,%dl
  801208:	74 0f                	je     801219 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80120a:	83 c0 01             	add    $0x1,%eax
  80120d:	0f b6 10             	movzbl (%eax),%edx
  801210:	84 d2                	test   %dl,%dl
  801212:	75 f2                	jne    801206 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801214:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801219:	5d                   	pop    %ebp
  80121a:	c3                   	ret    

0080121b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	8b 45 08             	mov    0x8(%ebp),%eax
  801221:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801225:	eb 07                	jmp    80122e <strfind+0x13>
		if (*s == c)
  801227:	38 ca                	cmp    %cl,%dl
  801229:	74 0a                	je     801235 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80122b:	83 c0 01             	add    $0x1,%eax
  80122e:	0f b6 10             	movzbl (%eax),%edx
  801231:	84 d2                	test   %dl,%dl
  801233:	75 f2                	jne    801227 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  801235:	5d                   	pop    %ebp
  801236:	c3                   	ret    

00801237 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	57                   	push   %edi
  80123b:	56                   	push   %esi
  80123c:	53                   	push   %ebx
  80123d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801240:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801243:	85 c9                	test   %ecx,%ecx
  801245:	74 36                	je     80127d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801247:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80124d:	75 28                	jne    801277 <memset+0x40>
  80124f:	f6 c1 03             	test   $0x3,%cl
  801252:	75 23                	jne    801277 <memset+0x40>
		c &= 0xFF;
  801254:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801258:	89 d3                	mov    %edx,%ebx
  80125a:	c1 e3 08             	shl    $0x8,%ebx
  80125d:	89 d6                	mov    %edx,%esi
  80125f:	c1 e6 18             	shl    $0x18,%esi
  801262:	89 d0                	mov    %edx,%eax
  801264:	c1 e0 10             	shl    $0x10,%eax
  801267:	09 f0                	or     %esi,%eax
  801269:	09 c2                	or     %eax,%edx
  80126b:	89 d0                	mov    %edx,%eax
  80126d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80126f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801272:	fc                   	cld    
  801273:	f3 ab                	rep stos %eax,%es:(%edi)
  801275:	eb 06                	jmp    80127d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801277:	8b 45 0c             	mov    0xc(%ebp),%eax
  80127a:	fc                   	cld    
  80127b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80127d:	89 f8                	mov    %edi,%eax
  80127f:	5b                   	pop    %ebx
  801280:	5e                   	pop    %esi
  801281:	5f                   	pop    %edi
  801282:	5d                   	pop    %ebp
  801283:	c3                   	ret    

00801284 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801284:	55                   	push   %ebp
  801285:	89 e5                	mov    %esp,%ebp
  801287:	57                   	push   %edi
  801288:	56                   	push   %esi
  801289:	8b 45 08             	mov    0x8(%ebp),%eax
  80128c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80128f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801292:	39 c6                	cmp    %eax,%esi
  801294:	73 35                	jae    8012cb <memmove+0x47>
  801296:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801299:	39 d0                	cmp    %edx,%eax
  80129b:	73 2e                	jae    8012cb <memmove+0x47>
		s += n;
		d += n;
  80129d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8012a0:	89 d6                	mov    %edx,%esi
  8012a2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8012a4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8012aa:	75 13                	jne    8012bf <memmove+0x3b>
  8012ac:	f6 c1 03             	test   $0x3,%cl
  8012af:	75 0e                	jne    8012bf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8012b1:	83 ef 04             	sub    $0x4,%edi
  8012b4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8012b7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8012ba:	fd                   	std    
  8012bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8012bd:	eb 09                	jmp    8012c8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8012bf:	83 ef 01             	sub    $0x1,%edi
  8012c2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8012c5:	fd                   	std    
  8012c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8012c8:	fc                   	cld    
  8012c9:	eb 1d                	jmp    8012e8 <memmove+0x64>
  8012cb:	89 f2                	mov    %esi,%edx
  8012cd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8012cf:	f6 c2 03             	test   $0x3,%dl
  8012d2:	75 0f                	jne    8012e3 <memmove+0x5f>
  8012d4:	f6 c1 03             	test   $0x3,%cl
  8012d7:	75 0a                	jne    8012e3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8012d9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8012dc:	89 c7                	mov    %eax,%edi
  8012de:	fc                   	cld    
  8012df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8012e1:	eb 05                	jmp    8012e8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8012e3:	89 c7                	mov    %eax,%edi
  8012e5:	fc                   	cld    
  8012e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8012e8:	5e                   	pop    %esi
  8012e9:	5f                   	pop    %edi
  8012ea:	5d                   	pop    %ebp
  8012eb:	c3                   	ret    

008012ec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8012ec:	55                   	push   %ebp
  8012ed:	89 e5                	mov    %esp,%ebp
  8012ef:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8012f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8012f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801300:	8b 45 08             	mov    0x8(%ebp),%eax
  801303:	89 04 24             	mov    %eax,(%esp)
  801306:	e8 79 ff ff ff       	call   801284 <memmove>
}
  80130b:	c9                   	leave  
  80130c:	c3                   	ret    

0080130d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80130d:	55                   	push   %ebp
  80130e:	89 e5                	mov    %esp,%ebp
  801310:	56                   	push   %esi
  801311:	53                   	push   %ebx
  801312:	8b 55 08             	mov    0x8(%ebp),%edx
  801315:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801318:	89 d6                	mov    %edx,%esi
  80131a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80131d:	eb 1a                	jmp    801339 <memcmp+0x2c>
		if (*s1 != *s2)
  80131f:	0f b6 02             	movzbl (%edx),%eax
  801322:	0f b6 19             	movzbl (%ecx),%ebx
  801325:	38 d8                	cmp    %bl,%al
  801327:	74 0a                	je     801333 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801329:	0f b6 c0             	movzbl %al,%eax
  80132c:	0f b6 db             	movzbl %bl,%ebx
  80132f:	29 d8                	sub    %ebx,%eax
  801331:	eb 0f                	jmp    801342 <memcmp+0x35>
		s1++, s2++;
  801333:	83 c2 01             	add    $0x1,%edx
  801336:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801339:	39 f2                	cmp    %esi,%edx
  80133b:	75 e2                	jne    80131f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80133d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801342:	5b                   	pop    %ebx
  801343:	5e                   	pop    %esi
  801344:	5d                   	pop    %ebp
  801345:	c3                   	ret    

00801346 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	8b 45 08             	mov    0x8(%ebp),%eax
  80134c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80134f:	89 c2                	mov    %eax,%edx
  801351:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801354:	eb 07                	jmp    80135d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801356:	38 08                	cmp    %cl,(%eax)
  801358:	74 07                	je     801361 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80135a:	83 c0 01             	add    $0x1,%eax
  80135d:	39 d0                	cmp    %edx,%eax
  80135f:	72 f5                	jb     801356 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801361:	5d                   	pop    %ebp
  801362:	c3                   	ret    

00801363 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801363:	55                   	push   %ebp
  801364:	89 e5                	mov    %esp,%ebp
  801366:	57                   	push   %edi
  801367:	56                   	push   %esi
  801368:	53                   	push   %ebx
  801369:	8b 55 08             	mov    0x8(%ebp),%edx
  80136c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80136f:	eb 03                	jmp    801374 <strtol+0x11>
		s++;
  801371:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801374:	0f b6 0a             	movzbl (%edx),%ecx
  801377:	80 f9 09             	cmp    $0x9,%cl
  80137a:	74 f5                	je     801371 <strtol+0xe>
  80137c:	80 f9 20             	cmp    $0x20,%cl
  80137f:	74 f0                	je     801371 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801381:	80 f9 2b             	cmp    $0x2b,%cl
  801384:	75 0a                	jne    801390 <strtol+0x2d>
		s++;
  801386:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801389:	bf 00 00 00 00       	mov    $0x0,%edi
  80138e:	eb 11                	jmp    8013a1 <strtol+0x3e>
  801390:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801395:	80 f9 2d             	cmp    $0x2d,%cl
  801398:	75 07                	jne    8013a1 <strtol+0x3e>
		s++, neg = 1;
  80139a:	8d 52 01             	lea    0x1(%edx),%edx
  80139d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8013a1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  8013a6:	75 15                	jne    8013bd <strtol+0x5a>
  8013a8:	80 3a 30             	cmpb   $0x30,(%edx)
  8013ab:	75 10                	jne    8013bd <strtol+0x5a>
  8013ad:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8013b1:	75 0a                	jne    8013bd <strtol+0x5a>
		s += 2, base = 16;
  8013b3:	83 c2 02             	add    $0x2,%edx
  8013b6:	b8 10 00 00 00       	mov    $0x10,%eax
  8013bb:	eb 10                	jmp    8013cd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  8013bd:	85 c0                	test   %eax,%eax
  8013bf:	75 0c                	jne    8013cd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8013c1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8013c3:	80 3a 30             	cmpb   $0x30,(%edx)
  8013c6:	75 05                	jne    8013cd <strtol+0x6a>
		s++, base = 8;
  8013c8:	83 c2 01             	add    $0x1,%edx
  8013cb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  8013cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013d2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8013d5:	0f b6 0a             	movzbl (%edx),%ecx
  8013d8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  8013db:	89 f0                	mov    %esi,%eax
  8013dd:	3c 09                	cmp    $0x9,%al
  8013df:	77 08                	ja     8013e9 <strtol+0x86>
			dig = *s - '0';
  8013e1:	0f be c9             	movsbl %cl,%ecx
  8013e4:	83 e9 30             	sub    $0x30,%ecx
  8013e7:	eb 20                	jmp    801409 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  8013e9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  8013ec:	89 f0                	mov    %esi,%eax
  8013ee:	3c 19                	cmp    $0x19,%al
  8013f0:	77 08                	ja     8013fa <strtol+0x97>
			dig = *s - 'a' + 10;
  8013f2:	0f be c9             	movsbl %cl,%ecx
  8013f5:	83 e9 57             	sub    $0x57,%ecx
  8013f8:	eb 0f                	jmp    801409 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  8013fa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  8013fd:	89 f0                	mov    %esi,%eax
  8013ff:	3c 19                	cmp    $0x19,%al
  801401:	77 16                	ja     801419 <strtol+0xb6>
			dig = *s - 'A' + 10;
  801403:	0f be c9             	movsbl %cl,%ecx
  801406:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801409:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80140c:	7d 0f                	jge    80141d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  80140e:	83 c2 01             	add    $0x1,%edx
  801411:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801415:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  801417:	eb bc                	jmp    8013d5 <strtol+0x72>
  801419:	89 d8                	mov    %ebx,%eax
  80141b:	eb 02                	jmp    80141f <strtol+0xbc>
  80141d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  80141f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801423:	74 05                	je     80142a <strtol+0xc7>
		*endptr = (char *) s;
  801425:	8b 75 0c             	mov    0xc(%ebp),%esi
  801428:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80142a:	f7 d8                	neg    %eax
  80142c:	85 ff                	test   %edi,%edi
  80142e:	0f 44 c3             	cmove  %ebx,%eax
}
  801431:	5b                   	pop    %ebx
  801432:	5e                   	pop    %esi
  801433:	5f                   	pop    %edi
  801434:	5d                   	pop    %ebp
  801435:	c3                   	ret    

00801436 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801436:	55                   	push   %ebp
  801437:	89 e5                	mov    %esp,%ebp
  801439:	57                   	push   %edi
  80143a:	56                   	push   %esi
  80143b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80143c:	b8 00 00 00 00       	mov    $0x0,%eax
  801441:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801444:	8b 55 08             	mov    0x8(%ebp),%edx
  801447:	89 c3                	mov    %eax,%ebx
  801449:	89 c7                	mov    %eax,%edi
  80144b:	89 c6                	mov    %eax,%esi
  80144d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80144f:	5b                   	pop    %ebx
  801450:	5e                   	pop    %esi
  801451:	5f                   	pop    %edi
  801452:	5d                   	pop    %ebp
  801453:	c3                   	ret    

00801454 <sys_cgetc>:

int
sys_cgetc(void)
{
  801454:	55                   	push   %ebp
  801455:	89 e5                	mov    %esp,%ebp
  801457:	57                   	push   %edi
  801458:	56                   	push   %esi
  801459:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80145a:	ba 00 00 00 00       	mov    $0x0,%edx
  80145f:	b8 01 00 00 00       	mov    $0x1,%eax
  801464:	89 d1                	mov    %edx,%ecx
  801466:	89 d3                	mov    %edx,%ebx
  801468:	89 d7                	mov    %edx,%edi
  80146a:	89 d6                	mov    %edx,%esi
  80146c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80146e:	5b                   	pop    %ebx
  80146f:	5e                   	pop    %esi
  801470:	5f                   	pop    %edi
  801471:	5d                   	pop    %ebp
  801472:	c3                   	ret    

00801473 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	57                   	push   %edi
  801477:	56                   	push   %esi
  801478:	53                   	push   %ebx
  801479:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80147c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801481:	b8 03 00 00 00       	mov    $0x3,%eax
  801486:	8b 55 08             	mov    0x8(%ebp),%edx
  801489:	89 cb                	mov    %ecx,%ebx
  80148b:	89 cf                	mov    %ecx,%edi
  80148d:	89 ce                	mov    %ecx,%esi
  80148f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801491:	85 c0                	test   %eax,%eax
  801493:	7e 28                	jle    8014bd <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801495:	89 44 24 10          	mov    %eax,0x10(%esp)
  801499:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8014a0:	00 
  8014a1:	c7 44 24 08 1f 37 80 	movl   $0x80371f,0x8(%esp)
  8014a8:	00 
  8014a9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014b0:	00 
  8014b1:	c7 04 24 3c 37 80 00 	movl   $0x80373c,(%esp)
  8014b8:	e8 01 f5 ff ff       	call   8009be <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8014bd:	83 c4 2c             	add    $0x2c,%esp
  8014c0:	5b                   	pop    %ebx
  8014c1:	5e                   	pop    %esi
  8014c2:	5f                   	pop    %edi
  8014c3:	5d                   	pop    %ebp
  8014c4:	c3                   	ret    

008014c5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8014c5:	55                   	push   %ebp
  8014c6:	89 e5                	mov    %esp,%ebp
  8014c8:	57                   	push   %edi
  8014c9:	56                   	push   %esi
  8014ca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d0:	b8 02 00 00 00       	mov    $0x2,%eax
  8014d5:	89 d1                	mov    %edx,%ecx
  8014d7:	89 d3                	mov    %edx,%ebx
  8014d9:	89 d7                	mov    %edx,%edi
  8014db:	89 d6                	mov    %edx,%esi
  8014dd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8014df:	5b                   	pop    %ebx
  8014e0:	5e                   	pop    %esi
  8014e1:	5f                   	pop    %edi
  8014e2:	5d                   	pop    %ebp
  8014e3:	c3                   	ret    

008014e4 <sys_yield>:

void
sys_yield(void)
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	57                   	push   %edi
  8014e8:	56                   	push   %esi
  8014e9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ef:	b8 0b 00 00 00       	mov    $0xb,%eax
  8014f4:	89 d1                	mov    %edx,%ecx
  8014f6:	89 d3                	mov    %edx,%ebx
  8014f8:	89 d7                	mov    %edx,%edi
  8014fa:	89 d6                	mov    %edx,%esi
  8014fc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8014fe:	5b                   	pop    %ebx
  8014ff:	5e                   	pop    %esi
  801500:	5f                   	pop    %edi
  801501:	5d                   	pop    %ebp
  801502:	c3                   	ret    

00801503 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801503:	55                   	push   %ebp
  801504:	89 e5                	mov    %esp,%ebp
  801506:	57                   	push   %edi
  801507:	56                   	push   %esi
  801508:	53                   	push   %ebx
  801509:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80150c:	be 00 00 00 00       	mov    $0x0,%esi
  801511:	b8 04 00 00 00       	mov    $0x4,%eax
  801516:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801519:	8b 55 08             	mov    0x8(%ebp),%edx
  80151c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80151f:	89 f7                	mov    %esi,%edi
  801521:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801523:	85 c0                	test   %eax,%eax
  801525:	7e 28                	jle    80154f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801527:	89 44 24 10          	mov    %eax,0x10(%esp)
  80152b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801532:	00 
  801533:	c7 44 24 08 1f 37 80 	movl   $0x80371f,0x8(%esp)
  80153a:	00 
  80153b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801542:	00 
  801543:	c7 04 24 3c 37 80 00 	movl   $0x80373c,(%esp)
  80154a:	e8 6f f4 ff ff       	call   8009be <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80154f:	83 c4 2c             	add    $0x2c,%esp
  801552:	5b                   	pop    %ebx
  801553:	5e                   	pop    %esi
  801554:	5f                   	pop    %edi
  801555:	5d                   	pop    %ebp
  801556:	c3                   	ret    

00801557 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801557:	55                   	push   %ebp
  801558:	89 e5                	mov    %esp,%ebp
  80155a:	57                   	push   %edi
  80155b:	56                   	push   %esi
  80155c:	53                   	push   %ebx
  80155d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801560:	b8 05 00 00 00       	mov    $0x5,%eax
  801565:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801568:	8b 55 08             	mov    0x8(%ebp),%edx
  80156b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80156e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801571:	8b 75 18             	mov    0x18(%ebp),%esi
  801574:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801576:	85 c0                	test   %eax,%eax
  801578:	7e 28                	jle    8015a2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80157a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80157e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801585:	00 
  801586:	c7 44 24 08 1f 37 80 	movl   $0x80371f,0x8(%esp)
  80158d:	00 
  80158e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801595:	00 
  801596:	c7 04 24 3c 37 80 00 	movl   $0x80373c,(%esp)
  80159d:	e8 1c f4 ff ff       	call   8009be <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8015a2:	83 c4 2c             	add    $0x2c,%esp
  8015a5:	5b                   	pop    %ebx
  8015a6:	5e                   	pop    %esi
  8015a7:	5f                   	pop    %edi
  8015a8:	5d                   	pop    %ebp
  8015a9:	c3                   	ret    

008015aa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8015aa:	55                   	push   %ebp
  8015ab:	89 e5                	mov    %esp,%ebp
  8015ad:	57                   	push   %edi
  8015ae:	56                   	push   %esi
  8015af:	53                   	push   %ebx
  8015b0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015b8:	b8 06 00 00 00       	mov    $0x6,%eax
  8015bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8015c3:	89 df                	mov    %ebx,%edi
  8015c5:	89 de                	mov    %ebx,%esi
  8015c7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8015c9:	85 c0                	test   %eax,%eax
  8015cb:	7e 28                	jle    8015f5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015cd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015d1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8015d8:	00 
  8015d9:	c7 44 24 08 1f 37 80 	movl   $0x80371f,0x8(%esp)
  8015e0:	00 
  8015e1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8015e8:	00 
  8015e9:	c7 04 24 3c 37 80 00 	movl   $0x80373c,(%esp)
  8015f0:	e8 c9 f3 ff ff       	call   8009be <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8015f5:	83 c4 2c             	add    $0x2c,%esp
  8015f8:	5b                   	pop    %ebx
  8015f9:	5e                   	pop    %esi
  8015fa:	5f                   	pop    %edi
  8015fb:	5d                   	pop    %ebp
  8015fc:	c3                   	ret    

008015fd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8015fd:	55                   	push   %ebp
  8015fe:	89 e5                	mov    %esp,%ebp
  801600:	57                   	push   %edi
  801601:	56                   	push   %esi
  801602:	53                   	push   %ebx
  801603:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801606:	bb 00 00 00 00       	mov    $0x0,%ebx
  80160b:	b8 08 00 00 00       	mov    $0x8,%eax
  801610:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801613:	8b 55 08             	mov    0x8(%ebp),%edx
  801616:	89 df                	mov    %ebx,%edi
  801618:	89 de                	mov    %ebx,%esi
  80161a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80161c:	85 c0                	test   %eax,%eax
  80161e:	7e 28                	jle    801648 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801620:	89 44 24 10          	mov    %eax,0x10(%esp)
  801624:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80162b:	00 
  80162c:	c7 44 24 08 1f 37 80 	movl   $0x80371f,0x8(%esp)
  801633:	00 
  801634:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80163b:	00 
  80163c:	c7 04 24 3c 37 80 00 	movl   $0x80373c,(%esp)
  801643:	e8 76 f3 ff ff       	call   8009be <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801648:	83 c4 2c             	add    $0x2c,%esp
  80164b:	5b                   	pop    %ebx
  80164c:	5e                   	pop    %esi
  80164d:	5f                   	pop    %edi
  80164e:	5d                   	pop    %ebp
  80164f:	c3                   	ret    

00801650 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
  801653:	57                   	push   %edi
  801654:	56                   	push   %esi
  801655:	53                   	push   %ebx
  801656:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801659:	bb 00 00 00 00       	mov    $0x0,%ebx
  80165e:	b8 09 00 00 00       	mov    $0x9,%eax
  801663:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801666:	8b 55 08             	mov    0x8(%ebp),%edx
  801669:	89 df                	mov    %ebx,%edi
  80166b:	89 de                	mov    %ebx,%esi
  80166d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80166f:	85 c0                	test   %eax,%eax
  801671:	7e 28                	jle    80169b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801673:	89 44 24 10          	mov    %eax,0x10(%esp)
  801677:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80167e:	00 
  80167f:	c7 44 24 08 1f 37 80 	movl   $0x80371f,0x8(%esp)
  801686:	00 
  801687:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80168e:	00 
  80168f:	c7 04 24 3c 37 80 00 	movl   $0x80373c,(%esp)
  801696:	e8 23 f3 ff ff       	call   8009be <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80169b:	83 c4 2c             	add    $0x2c,%esp
  80169e:	5b                   	pop    %ebx
  80169f:	5e                   	pop    %esi
  8016a0:	5f                   	pop    %edi
  8016a1:	5d                   	pop    %ebp
  8016a2:	c3                   	ret    

008016a3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8016a3:	55                   	push   %ebp
  8016a4:	89 e5                	mov    %esp,%ebp
  8016a6:	57                   	push   %edi
  8016a7:	56                   	push   %esi
  8016a8:	53                   	push   %ebx
  8016a9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016b1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8016b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8016bc:	89 df                	mov    %ebx,%edi
  8016be:	89 de                	mov    %ebx,%esi
  8016c0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8016c2:	85 c0                	test   %eax,%eax
  8016c4:	7e 28                	jle    8016ee <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016c6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016ca:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8016d1:	00 
  8016d2:	c7 44 24 08 1f 37 80 	movl   $0x80371f,0x8(%esp)
  8016d9:	00 
  8016da:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8016e1:	00 
  8016e2:	c7 04 24 3c 37 80 00 	movl   $0x80373c,(%esp)
  8016e9:	e8 d0 f2 ff ff       	call   8009be <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8016ee:	83 c4 2c             	add    $0x2c,%esp
  8016f1:	5b                   	pop    %ebx
  8016f2:	5e                   	pop    %esi
  8016f3:	5f                   	pop    %edi
  8016f4:	5d                   	pop    %ebp
  8016f5:	c3                   	ret    

008016f6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	57                   	push   %edi
  8016fa:	56                   	push   %esi
  8016fb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016fc:	be 00 00 00 00       	mov    $0x0,%esi
  801701:	b8 0c 00 00 00       	mov    $0xc,%eax
  801706:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801709:	8b 55 08             	mov    0x8(%ebp),%edx
  80170c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80170f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801712:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801714:	5b                   	pop    %ebx
  801715:	5e                   	pop    %esi
  801716:	5f                   	pop    %edi
  801717:	5d                   	pop    %ebp
  801718:	c3                   	ret    

00801719 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801719:	55                   	push   %ebp
  80171a:	89 e5                	mov    %esp,%ebp
  80171c:	57                   	push   %edi
  80171d:	56                   	push   %esi
  80171e:	53                   	push   %ebx
  80171f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801722:	b9 00 00 00 00       	mov    $0x0,%ecx
  801727:	b8 0d 00 00 00       	mov    $0xd,%eax
  80172c:	8b 55 08             	mov    0x8(%ebp),%edx
  80172f:	89 cb                	mov    %ecx,%ebx
  801731:	89 cf                	mov    %ecx,%edi
  801733:	89 ce                	mov    %ecx,%esi
  801735:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801737:	85 c0                	test   %eax,%eax
  801739:	7e 28                	jle    801763 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80173b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80173f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801746:	00 
  801747:	c7 44 24 08 1f 37 80 	movl   $0x80371f,0x8(%esp)
  80174e:	00 
  80174f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801756:	00 
  801757:	c7 04 24 3c 37 80 00 	movl   $0x80373c,(%esp)
  80175e:	e8 5b f2 ff ff       	call   8009be <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801763:	83 c4 2c             	add    $0x2c,%esp
  801766:	5b                   	pop    %ebx
  801767:	5e                   	pop    %esi
  801768:	5f                   	pop    %edi
  801769:	5d                   	pop    %ebp
  80176a:	c3                   	ret    

0080176b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	57                   	push   %edi
  80176f:	56                   	push   %esi
  801770:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801771:	ba 00 00 00 00       	mov    $0x0,%edx
  801776:	b8 0e 00 00 00       	mov    $0xe,%eax
  80177b:	89 d1                	mov    %edx,%ecx
  80177d:	89 d3                	mov    %edx,%ebx
  80177f:	89 d7                	mov    %edx,%edi
  801781:	89 d6                	mov    %edx,%esi
  801783:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801785:	5b                   	pop    %ebx
  801786:	5e                   	pop    %esi
  801787:	5f                   	pop    %edi
  801788:	5d                   	pop    %ebp
  801789:	c3                   	ret    

0080178a <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	57                   	push   %edi
  80178e:	56                   	push   %esi
  80178f:	53                   	push   %ebx
  801790:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801793:	bb 00 00 00 00       	mov    $0x0,%ebx
  801798:	b8 0f 00 00 00       	mov    $0xf,%eax
  80179d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8017a3:	89 df                	mov    %ebx,%edi
  8017a5:	89 de                	mov    %ebx,%esi
  8017a7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8017a9:	85 c0                	test   %eax,%eax
  8017ab:	7e 28                	jle    8017d5 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017ad:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017b1:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  8017b8:	00 
  8017b9:	c7 44 24 08 1f 37 80 	movl   $0x80371f,0x8(%esp)
  8017c0:	00 
  8017c1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8017c8:	00 
  8017c9:	c7 04 24 3c 37 80 00 	movl   $0x80373c,(%esp)
  8017d0:	e8 e9 f1 ff ff       	call   8009be <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  8017d5:	83 c4 2c             	add    $0x2c,%esp
  8017d8:	5b                   	pop    %ebx
  8017d9:	5e                   	pop    %esi
  8017da:	5f                   	pop    %edi
  8017db:	5d                   	pop    %ebp
  8017dc:	c3                   	ret    

008017dd <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  8017dd:	55                   	push   %ebp
  8017de:	89 e5                	mov    %esp,%ebp
  8017e0:	57                   	push   %edi
  8017e1:	56                   	push   %esi
  8017e2:	53                   	push   %ebx
  8017e3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017eb:	b8 10 00 00 00       	mov    $0x10,%eax
  8017f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8017f6:	89 df                	mov    %ebx,%edi
  8017f8:	89 de                	mov    %ebx,%esi
  8017fa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8017fc:	85 c0                	test   %eax,%eax
  8017fe:	7e 28                	jle    801828 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801800:	89 44 24 10          	mov    %eax,0x10(%esp)
  801804:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  80180b:	00 
  80180c:	c7 44 24 08 1f 37 80 	movl   $0x80371f,0x8(%esp)
  801813:	00 
  801814:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80181b:	00 
  80181c:	c7 04 24 3c 37 80 00 	movl   $0x80373c,(%esp)
  801823:	e8 96 f1 ff ff       	call   8009be <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  801828:	83 c4 2c             	add    $0x2c,%esp
  80182b:	5b                   	pop    %ebx
  80182c:	5e                   	pop    %esi
  80182d:	5f                   	pop    %edi
  80182e:	5d                   	pop    %ebp
  80182f:	c3                   	ret    

00801830 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	56                   	push   %esi
  801834:	53                   	push   %ebx
  801835:	83 ec 20             	sub    $0x20,%esp
  801838:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80183b:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if(!(err & FEC_WR)) {
  80183d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801841:	75 20                	jne    801863 <pgfault+0x33>
		panic("0x%x Not a write", addr);
  801843:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801847:	c7 44 24 08 4a 37 80 	movl   $0x80374a,0x8(%esp)
  80184e:	00 
  80184f:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801856:	00 
  801857:	c7 04 24 5b 37 80 00 	movl   $0x80375b,(%esp)
  80185e:	e8 5b f1 ff ff       	call   8009be <_panic>
	}

	if(!(uvpt[PGNUM(addr)] & PTE_COW)) {
  801863:	89 f0                	mov    %esi,%eax
  801865:	c1 e8 0c             	shr    $0xc,%eax
  801868:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80186f:	f6 c4 08             	test   $0x8,%ah
  801872:	75 1c                	jne    801890 <pgfault+0x60>
		panic("Not a COW page");
  801874:	c7 44 24 08 66 37 80 	movl   $0x803766,0x8(%esp)
  80187b:	00 
  80187c:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  801883:	00 
  801884:	c7 04 24 5b 37 80 00 	movl   $0x80375b,(%esp)
  80188b:	e8 2e f1 ff ff       	call   8009be <_panic>

	// Allocate a new page, map it at a temporary location (PFTEMP), // copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	envid_t envid = sys_getenvid();
  801890:	e8 30 fc ff ff       	call   8014c5 <sys_getenvid>
  801895:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, PFTEMP, PTE_W | PTE_U | PTE_P);
  801897:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80189e:	00 
  80189f:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8018a6:	00 
  8018a7:	89 04 24             	mov    %eax,(%esp)
  8018aa:	e8 54 fc ff ff       	call   801503 <sys_page_alloc>
	if(r < 0) {
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	79 1c                	jns    8018cf <pgfault+0x9f>
		panic("couldn't allocate page");
  8018b3:	c7 44 24 08 75 37 80 	movl   $0x803775,0x8(%esp)
  8018ba:	00 
  8018bb:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8018c2:	00 
  8018c3:	c7 04 24 5b 37 80 00 	movl   $0x80375b,(%esp)
  8018ca:	e8 ef f0 ff ff       	call   8009be <_panic>
	}

	memmove(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  8018cf:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  8018d5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8018dc:	00 
  8018dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018e1:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8018e8:	e8 97 f9 ff ff       	call   801284 <memmove>

	r = sys_page_map(envid, PFTEMP, envid, ROUNDDOWN(addr,PGSIZE), PTE_P | PTE_U | PTE_W);
  8018ed:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8018f4:	00 
  8018f5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8018f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018fd:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801904:	00 
  801905:	89 1c 24             	mov    %ebx,(%esp)
  801908:	e8 4a fc ff ff       	call   801557 <sys_page_map>
	if(r < 0) {
  80190d:	85 c0                	test   %eax,%eax
  80190f:	79 1c                	jns    80192d <pgfault+0xfd>
		panic("couldn't map page");
  801911:	c7 44 24 08 8c 37 80 	movl   $0x80378c,0x8(%esp)
  801918:	00 
  801919:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  801920:	00 
  801921:	c7 04 24 5b 37 80 00 	movl   $0x80375b,(%esp)
  801928:	e8 91 f0 ff ff       	call   8009be <_panic>
	}
}
  80192d:	83 c4 20             	add    $0x20,%esp
  801930:	5b                   	pop    %ebx
  801931:	5e                   	pop    %esi
  801932:	5d                   	pop    %ebp
  801933:	c3                   	ret    

00801934 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801934:	55                   	push   %ebp
  801935:	89 e5                	mov    %esp,%ebp
  801937:	57                   	push   %edi
  801938:	56                   	push   %esi
  801939:	53                   	push   %ebx
  80193a:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envid;
	uintptr_t addr;
	int r = 0;

	set_pgfault_handler(pgfault);
  80193d:	c7 04 24 30 18 80 00 	movl   $0x801830,(%esp)
  801944:	e8 cd 15 00 00       	call   802f16 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801949:	b8 07 00 00 00       	mov    $0x7,%eax
  80194e:	cd 30                	int    $0x30
  801950:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801953:	89 45 d8             	mov    %eax,-0x28(%ebp)

	envid = sys_exofork();
	if(envid == 0) {
  801956:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80195d:	bf 00 00 00 00       	mov    $0x0,%edi
  801962:	85 c0                	test   %eax,%eax
  801964:	75 21                	jne    801987 <fork+0x53>
		thisenv = &envs[ENVX(sys_getenvid())];
  801966:	e8 5a fb ff ff       	call   8014c5 <sys_getenvid>
  80196b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801970:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801973:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801978:	a3 20 50 80 00       	mov    %eax,0x805020
		return 0;
  80197d:	b8 00 00 00 00       	mov    $0x0,%eax
  801982:	e9 8d 01 00 00       	jmp    801b14 <fork+0x1e0>
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
  801987:	89 f8                	mov    %edi,%eax
  801989:	c1 e8 16             	shr    $0x16,%eax
  80198c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801993:	85 c0                	test   %eax,%eax
  801995:	0f 84 02 01 00 00    	je     801a9d <fork+0x169>
  80199b:	89 fa                	mov    %edi,%edx
  80199d:	c1 ea 0c             	shr    $0xc,%edx
  8019a0:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	0f 84 ee 00 00 00    	je     801a9d <fork+0x169>
//
static int
duppage(envid_t envid, unsigned pn)
{

	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P)) return 0;
  8019af:	89 d6                	mov    %edx,%esi
  8019b1:	c1 e6 0c             	shl    $0xc,%esi
  8019b4:	89 f0                	mov    %esi,%eax
  8019b6:	c1 e8 16             	shr    $0x16,%eax
  8019b9:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8019c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c5:	f6 c1 01             	test   $0x1,%cl
  8019c8:	0f 84 cc 00 00 00    	je     801a9a <fork+0x166>

	int all_perms = PTE_U | PTE_P | PTE_AVAIL | PTE_W | PTE_COW;
	int orig_perms = uvpt[pn] & all_perms;
  8019ce:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  8019d5:	89 d8                	mov    %ebx,%eax
  8019d7:	25 07 0e 00 00       	and    $0xe07,%eax
  8019dc:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if(!(orig_perms & PTE_P)) return 0;
  8019df:	89 d8                	mov    %ebx,%eax
  8019e1:	83 e0 01             	and    $0x1,%eax
  8019e4:	0f 84 b0 00 00 00    	je     801a9a <fork+0x166>

	int r = 0;
	envid_t curenvid = sys_getenvid();
  8019ea:	e8 d6 fa ff ff       	call   8014c5 <sys_getenvid>
  8019ef:	89 45 dc             	mov    %eax,-0x24(%ebp)


	if(orig_perms & PTE_SHARE) {
  8019f2:	f7 45 e0 00 04 00 00 	testl  $0x400,-0x20(%ebp)
  8019f9:	74 28                	je     801a23 <fork+0xef>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms & PTE_SYSCALL));
  8019fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019fe:	25 07 0e 00 00       	and    $0xe07,%eax
  801a03:	89 44 24 10          	mov    %eax,0x10(%esp)
  801a07:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801a0b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a0e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a12:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a16:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801a19:	89 04 24             	mov    %eax,(%esp)
  801a1c:	e8 36 fb ff ff       	call   801557 <sys_page_map>
  801a21:	eb 77                	jmp    801a9a <fork+0x166>

	} else if(((orig_perms) & PTE_COW) || (orig_perms & PTE_W) ) {
  801a23:	f7 c3 02 08 00 00    	test   $0x802,%ebx
  801a29:	74 4e                	je     801a79 <fork+0x145>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  801a2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a2e:	25 fd f7 ff ff       	and    $0xfffff7fd,%eax
  801a33:	80 cc 08             	or     $0x8,%ah
  801a36:	89 c3                	mov    %eax,%ebx
  801a38:	89 44 24 10          	mov    %eax,0x10(%esp)
  801a3c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801a40:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a43:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a47:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a4b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801a4e:	89 04 24             	mov    %eax,(%esp)
  801a51:	e8 01 fb ff ff       	call   801557 <sys_page_map>
  801a56:	89 45 e0             	mov    %eax,-0x20(%ebp)

		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), curenvid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  801a59:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801a5d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801a61:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801a64:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a68:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a6c:	89 0c 24             	mov    %ecx,(%esp)
  801a6f:	e8 e3 fa ff ff       	call   801557 <sys_page_map>
  801a74:	03 45 e0             	add    -0x20(%ebp),%eax
  801a77:	eb 21                	jmp    801a9a <fork+0x166>

	} else {
		r = sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), orig_perms);
  801a79:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a7c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801a80:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801a84:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a87:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a8b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a8f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801a92:	89 04 24             	mov    %eax,(%esp)
  801a95:	e8 bd fa ff ff       	call   801557 <sys_page_map>
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
  801a9a:	01 45 e4             	add    %eax,-0x1c(%ebp)
	if(envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
  801a9d:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801aa3:	81 ff 00 f0 bf ee    	cmp    $0xeebff000,%edi
  801aa9:	0f 85 d8 fe ff ff    	jne    801987 <fork+0x53>
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
		}
	}

	r+=sys_page_alloc(envid, (void*)UXSTACKTOP - PGSIZE, PTE_P|PTE_U|PTE_W);
  801aaf:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801ab6:	00 
  801ab7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801abe:	ee 
  801abf:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801ac2:	89 34 24             	mov    %esi,(%esp)
  801ac5:	e8 39 fa ff ff       	call   801503 <sys_page_alloc>
  801aca:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801acd:	01 c3                	add    %eax,%ebx
	r+=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801acf:	c7 44 24 04 63 2f 80 	movl   $0x802f63,0x4(%esp)
  801ad6:	00 
  801ad7:	89 34 24             	mov    %esi,(%esp)
  801ada:	e8 c4 fb ff ff       	call   8016a3 <sys_env_set_pgfault_upcall>
  801adf:	01 c3                	add    %eax,%ebx
	r+= sys_env_set_status(envid, ENV_RUNNABLE);
  801ae1:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801ae8:	00 
  801ae9:	89 34 24             	mov    %esi,(%esp)
  801aec:	e8 0c fb ff ff       	call   8015fd <sys_env_set_status>

	if(r<0) {
  801af1:	01 d8                	add    %ebx,%eax
  801af3:	79 1c                	jns    801b11 <fork+0x1dd>
	 panic("fork failed!");
  801af5:	c7 44 24 08 9e 37 80 	movl   $0x80379e,0x8(%esp)
  801afc:	00 
  801afd:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  801b04:	00 
  801b05:	c7 04 24 5b 37 80 00 	movl   $0x80375b,(%esp)
  801b0c:	e8 ad ee ff ff       	call   8009be <_panic>
	}

	return envid;
  801b11:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  801b14:	83 c4 3c             	add    $0x3c,%esp
  801b17:	5b                   	pop    %ebx
  801b18:	5e                   	pop    %esi
  801b19:	5f                   	pop    %edi
  801b1a:	5d                   	pop    %ebp
  801b1b:	c3                   	ret    

00801b1c <sfork>:

// Challenge!
int
sfork(void)
{
  801b1c:	55                   	push   %ebp
  801b1d:	89 e5                	mov    %esp,%ebp
  801b1f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801b22:	c7 44 24 08 ab 37 80 	movl   $0x8037ab,0x8(%esp)
  801b29:	00 
  801b2a:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
  801b31:	00 
  801b32:	c7 04 24 5b 37 80 00 	movl   $0x80375b,(%esp)
  801b39:	e8 80 ee ff ff       	call   8009be <_panic>
  801b3e:	66 90                	xchg   %ax,%ax

00801b40 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b40:	55                   	push   %ebp
  801b41:	89 e5                	mov    %esp,%ebp
  801b43:	56                   	push   %esi
  801b44:	53                   	push   %ebx
  801b45:	83 ec 10             	sub    $0x10,%esp
  801b48:	8b 75 08             	mov    0x8(%ebp),%esi
  801b4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  801b51:	85 c0                	test   %eax,%eax
  801b53:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b58:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  801b5b:	89 04 24             	mov    %eax,(%esp)
  801b5e:	e8 b6 fb ff ff       	call   801719 <sys_ipc_recv>

	if(ret < 0) {
  801b63:	85 c0                	test   %eax,%eax
  801b65:	79 16                	jns    801b7d <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  801b67:	85 f6                	test   %esi,%esi
  801b69:	74 06                	je     801b71 <ipc_recv+0x31>
  801b6b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  801b71:	85 db                	test   %ebx,%ebx
  801b73:	74 3e                	je     801bb3 <ipc_recv+0x73>
  801b75:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b7b:	eb 36                	jmp    801bb3 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  801b7d:	e8 43 f9 ff ff       	call   8014c5 <sys_getenvid>
  801b82:	25 ff 03 00 00       	and    $0x3ff,%eax
  801b87:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b8a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b8f:	a3 20 50 80 00       	mov    %eax,0x805020

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801b94:	85 f6                	test   %esi,%esi
  801b96:	74 05                	je     801b9d <ipc_recv+0x5d>
  801b98:	8b 40 74             	mov    0x74(%eax),%eax
  801b9b:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801b9d:	85 db                	test   %ebx,%ebx
  801b9f:	74 0a                	je     801bab <ipc_recv+0x6b>
  801ba1:	a1 20 50 80 00       	mov    0x805020,%eax
  801ba6:	8b 40 78             	mov    0x78(%eax),%eax
  801ba9:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801bab:	a1 20 50 80 00       	mov    0x805020,%eax
  801bb0:	8b 40 70             	mov    0x70(%eax),%eax
}
  801bb3:	83 c4 10             	add    $0x10,%esp
  801bb6:	5b                   	pop    %ebx
  801bb7:	5e                   	pop    %esi
  801bb8:	5d                   	pop    %ebp
  801bb9:	c3                   	ret    

00801bba <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bba:	55                   	push   %ebp
  801bbb:	89 e5                	mov    %esp,%ebp
  801bbd:	57                   	push   %edi
  801bbe:	56                   	push   %esi
  801bbf:	53                   	push   %ebx
  801bc0:	83 ec 1c             	sub    $0x1c,%esp
  801bc3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bc6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  801bcc:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  801bce:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801bd3:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  801bd6:	8b 45 14             	mov    0x14(%ebp),%eax
  801bd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bdd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801be1:	89 74 24 04          	mov    %esi,0x4(%esp)
  801be5:	89 3c 24             	mov    %edi,(%esp)
  801be8:	e8 09 fb ff ff       	call   8016f6 <sys_ipc_try_send>

		if(ret >= 0) break;
  801bed:	85 c0                	test   %eax,%eax
  801bef:	79 2c                	jns    801c1d <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  801bf1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bf4:	74 20                	je     801c16 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  801bf6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bfa:	c7 44 24 08 c4 37 80 	movl   $0x8037c4,0x8(%esp)
  801c01:	00 
  801c02:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801c09:	00 
  801c0a:	c7 04 24 f4 37 80 00 	movl   $0x8037f4,(%esp)
  801c11:	e8 a8 ed ff ff       	call   8009be <_panic>
		}
		sys_yield();
  801c16:	e8 c9 f8 ff ff       	call   8014e4 <sys_yield>
	}
  801c1b:	eb b9                	jmp    801bd6 <ipc_send+0x1c>
}
  801c1d:	83 c4 1c             	add    $0x1c,%esp
  801c20:	5b                   	pop    %ebx
  801c21:	5e                   	pop    %esi
  801c22:	5f                   	pop    %edi
  801c23:	5d                   	pop    %ebp
  801c24:	c3                   	ret    

00801c25 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c25:	55                   	push   %ebp
  801c26:	89 e5                	mov    %esp,%ebp
  801c28:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c2b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c30:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c33:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c39:	8b 52 50             	mov    0x50(%edx),%edx
  801c3c:	39 ca                	cmp    %ecx,%edx
  801c3e:	75 0d                	jne    801c4d <ipc_find_env+0x28>
			return envs[i].env_id;
  801c40:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c43:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801c48:	8b 40 40             	mov    0x40(%eax),%eax
  801c4b:	eb 0e                	jmp    801c5b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c4d:	83 c0 01             	add    $0x1,%eax
  801c50:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c55:	75 d9                	jne    801c30 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c57:	66 b8 00 00          	mov    $0x0,%ax
}
  801c5b:	5d                   	pop    %ebp
  801c5c:	c3                   	ret    
  801c5d:	66 90                	xchg   %ax,%ax
  801c5f:	90                   	nop

00801c60 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801c60:	55                   	push   %ebp
  801c61:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801c63:	8b 45 08             	mov    0x8(%ebp),%eax
  801c66:	05 00 00 00 30       	add    $0x30000000,%eax
  801c6b:	c1 e8 0c             	shr    $0xc,%eax
}
  801c6e:	5d                   	pop    %ebp
  801c6f:	c3                   	ret    

00801c70 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801c73:	8b 45 08             	mov    0x8(%ebp),%eax
  801c76:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801c7b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801c80:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801c85:	5d                   	pop    %ebp
  801c86:	c3                   	ret    

00801c87 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801c87:	55                   	push   %ebp
  801c88:	89 e5                	mov    %esp,%ebp
  801c8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c8d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801c92:	89 c2                	mov    %eax,%edx
  801c94:	c1 ea 16             	shr    $0x16,%edx
  801c97:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c9e:	f6 c2 01             	test   $0x1,%dl
  801ca1:	74 11                	je     801cb4 <fd_alloc+0x2d>
  801ca3:	89 c2                	mov    %eax,%edx
  801ca5:	c1 ea 0c             	shr    $0xc,%edx
  801ca8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801caf:	f6 c2 01             	test   $0x1,%dl
  801cb2:	75 09                	jne    801cbd <fd_alloc+0x36>
			*fd_store = fd;
  801cb4:	89 01                	mov    %eax,(%ecx)
			return 0;
  801cb6:	b8 00 00 00 00       	mov    $0x0,%eax
  801cbb:	eb 17                	jmp    801cd4 <fd_alloc+0x4d>
  801cbd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801cc2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801cc7:	75 c9                	jne    801c92 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801cc9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801ccf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801cd4:	5d                   	pop    %ebp
  801cd5:	c3                   	ret    

00801cd6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801cd6:	55                   	push   %ebp
  801cd7:	89 e5                	mov    %esp,%ebp
  801cd9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801cdc:	83 f8 1f             	cmp    $0x1f,%eax
  801cdf:	77 36                	ja     801d17 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801ce1:	c1 e0 0c             	shl    $0xc,%eax
  801ce4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801ce9:	89 c2                	mov    %eax,%edx
  801ceb:	c1 ea 16             	shr    $0x16,%edx
  801cee:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cf5:	f6 c2 01             	test   $0x1,%dl
  801cf8:	74 24                	je     801d1e <fd_lookup+0x48>
  801cfa:	89 c2                	mov    %eax,%edx
  801cfc:	c1 ea 0c             	shr    $0xc,%edx
  801cff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801d06:	f6 c2 01             	test   $0x1,%dl
  801d09:	74 1a                	je     801d25 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801d0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d0e:	89 02                	mov    %eax,(%edx)
	return 0;
  801d10:	b8 00 00 00 00       	mov    $0x0,%eax
  801d15:	eb 13                	jmp    801d2a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801d17:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d1c:	eb 0c                	jmp    801d2a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801d1e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d23:	eb 05                	jmp    801d2a <fd_lookup+0x54>
  801d25:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801d2a:	5d                   	pop    %ebp
  801d2b:	c3                   	ret    

00801d2c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801d2c:	55                   	push   %ebp
  801d2d:	89 e5                	mov    %esp,%ebp
  801d2f:	83 ec 18             	sub    $0x18,%esp
  801d32:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801d35:	ba 00 00 00 00       	mov    $0x0,%edx
  801d3a:	eb 13                	jmp    801d4f <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  801d3c:	39 08                	cmp    %ecx,(%eax)
  801d3e:	75 0c                	jne    801d4c <dev_lookup+0x20>
			*dev = devtab[i];
  801d40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d43:	89 01                	mov    %eax,(%ecx)
			return 0;
  801d45:	b8 00 00 00 00       	mov    $0x0,%eax
  801d4a:	eb 38                	jmp    801d84 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801d4c:	83 c2 01             	add    $0x1,%edx
  801d4f:	8b 04 95 80 38 80 00 	mov    0x803880(,%edx,4),%eax
  801d56:	85 c0                	test   %eax,%eax
  801d58:	75 e2                	jne    801d3c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801d5a:	a1 20 50 80 00       	mov    0x805020,%eax
  801d5f:	8b 40 48             	mov    0x48(%eax),%eax
  801d62:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d66:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d6a:	c7 04 24 00 38 80 00 	movl   $0x803800,(%esp)
  801d71:	e8 41 ed ff ff       	call   800ab7 <cprintf>
	*dev = 0;
  801d76:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d79:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801d7f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801d84:	c9                   	leave  
  801d85:	c3                   	ret    

00801d86 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801d86:	55                   	push   %ebp
  801d87:	89 e5                	mov    %esp,%ebp
  801d89:	56                   	push   %esi
  801d8a:	53                   	push   %ebx
  801d8b:	83 ec 20             	sub    $0x20,%esp
  801d8e:	8b 75 08             	mov    0x8(%ebp),%esi
  801d91:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801d94:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d97:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801d9b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801da1:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801da4:	89 04 24             	mov    %eax,(%esp)
  801da7:	e8 2a ff ff ff       	call   801cd6 <fd_lookup>
  801dac:	85 c0                	test   %eax,%eax
  801dae:	78 05                	js     801db5 <fd_close+0x2f>
	    || fd != fd2)
  801db0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801db3:	74 0c                	je     801dc1 <fd_close+0x3b>
		return (must_exist ? r : 0);
  801db5:	84 db                	test   %bl,%bl
  801db7:	ba 00 00 00 00       	mov    $0x0,%edx
  801dbc:	0f 44 c2             	cmove  %edx,%eax
  801dbf:	eb 3f                	jmp    801e00 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801dc1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dc4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dc8:	8b 06                	mov    (%esi),%eax
  801dca:	89 04 24             	mov    %eax,(%esp)
  801dcd:	e8 5a ff ff ff       	call   801d2c <dev_lookup>
  801dd2:	89 c3                	mov    %eax,%ebx
  801dd4:	85 c0                	test   %eax,%eax
  801dd6:	78 16                	js     801dee <fd_close+0x68>
		if (dev->dev_close)
  801dd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ddb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801dde:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801de3:	85 c0                	test   %eax,%eax
  801de5:	74 07                	je     801dee <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801de7:	89 34 24             	mov    %esi,(%esp)
  801dea:	ff d0                	call   *%eax
  801dec:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801dee:	89 74 24 04          	mov    %esi,0x4(%esp)
  801df2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801df9:	e8 ac f7 ff ff       	call   8015aa <sys_page_unmap>
	return r;
  801dfe:	89 d8                	mov    %ebx,%eax
}
  801e00:	83 c4 20             	add    $0x20,%esp
  801e03:	5b                   	pop    %ebx
  801e04:	5e                   	pop    %esi
  801e05:	5d                   	pop    %ebp
  801e06:	c3                   	ret    

00801e07 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801e07:	55                   	push   %ebp
  801e08:	89 e5                	mov    %esp,%ebp
  801e0a:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e10:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e14:	8b 45 08             	mov    0x8(%ebp),%eax
  801e17:	89 04 24             	mov    %eax,(%esp)
  801e1a:	e8 b7 fe ff ff       	call   801cd6 <fd_lookup>
  801e1f:	89 c2                	mov    %eax,%edx
  801e21:	85 d2                	test   %edx,%edx
  801e23:	78 13                	js     801e38 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801e25:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801e2c:	00 
  801e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e30:	89 04 24             	mov    %eax,(%esp)
  801e33:	e8 4e ff ff ff       	call   801d86 <fd_close>
}
  801e38:	c9                   	leave  
  801e39:	c3                   	ret    

00801e3a <close_all>:

void
close_all(void)
{
  801e3a:	55                   	push   %ebp
  801e3b:	89 e5                	mov    %esp,%ebp
  801e3d:	53                   	push   %ebx
  801e3e:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801e41:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801e46:	89 1c 24             	mov    %ebx,(%esp)
  801e49:	e8 b9 ff ff ff       	call   801e07 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801e4e:	83 c3 01             	add    $0x1,%ebx
  801e51:	83 fb 20             	cmp    $0x20,%ebx
  801e54:	75 f0                	jne    801e46 <close_all+0xc>
		close(i);
}
  801e56:	83 c4 14             	add    $0x14,%esp
  801e59:	5b                   	pop    %ebx
  801e5a:	5d                   	pop    %ebp
  801e5b:	c3                   	ret    

00801e5c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801e5c:	55                   	push   %ebp
  801e5d:	89 e5                	mov    %esp,%ebp
  801e5f:	57                   	push   %edi
  801e60:	56                   	push   %esi
  801e61:	53                   	push   %ebx
  801e62:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801e65:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e68:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6f:	89 04 24             	mov    %eax,(%esp)
  801e72:	e8 5f fe ff ff       	call   801cd6 <fd_lookup>
  801e77:	89 c2                	mov    %eax,%edx
  801e79:	85 d2                	test   %edx,%edx
  801e7b:	0f 88 e1 00 00 00    	js     801f62 <dup+0x106>
		return r;
	close(newfdnum);
  801e81:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e84:	89 04 24             	mov    %eax,(%esp)
  801e87:	e8 7b ff ff ff       	call   801e07 <close>

	newfd = INDEX2FD(newfdnum);
  801e8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e8f:	c1 e3 0c             	shl    $0xc,%ebx
  801e92:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801e98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e9b:	89 04 24             	mov    %eax,(%esp)
  801e9e:	e8 cd fd ff ff       	call   801c70 <fd2data>
  801ea3:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801ea5:	89 1c 24             	mov    %ebx,(%esp)
  801ea8:	e8 c3 fd ff ff       	call   801c70 <fd2data>
  801ead:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801eaf:	89 f0                	mov    %esi,%eax
  801eb1:	c1 e8 16             	shr    $0x16,%eax
  801eb4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ebb:	a8 01                	test   $0x1,%al
  801ebd:	74 43                	je     801f02 <dup+0xa6>
  801ebf:	89 f0                	mov    %esi,%eax
  801ec1:	c1 e8 0c             	shr    $0xc,%eax
  801ec4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801ecb:	f6 c2 01             	test   $0x1,%dl
  801ece:	74 32                	je     801f02 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801ed0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ed7:	25 07 0e 00 00       	and    $0xe07,%eax
  801edc:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ee0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ee4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801eeb:	00 
  801eec:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ef0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ef7:	e8 5b f6 ff ff       	call   801557 <sys_page_map>
  801efc:	89 c6                	mov    %eax,%esi
  801efe:	85 c0                	test   %eax,%eax
  801f00:	78 3e                	js     801f40 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801f02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f05:	89 c2                	mov    %eax,%edx
  801f07:	c1 ea 0c             	shr    $0xc,%edx
  801f0a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801f11:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801f17:	89 54 24 10          	mov    %edx,0x10(%esp)
  801f1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801f1f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f26:	00 
  801f27:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f2b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f32:	e8 20 f6 ff ff       	call   801557 <sys_page_map>
  801f37:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801f39:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801f3c:	85 f6                	test   %esi,%esi
  801f3e:	79 22                	jns    801f62 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801f40:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f4b:	e8 5a f6 ff ff       	call   8015aa <sys_page_unmap>
	sys_page_unmap(0, nva);
  801f50:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f54:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f5b:	e8 4a f6 ff ff       	call   8015aa <sys_page_unmap>
	return r;
  801f60:	89 f0                	mov    %esi,%eax
}
  801f62:	83 c4 3c             	add    $0x3c,%esp
  801f65:	5b                   	pop    %ebx
  801f66:	5e                   	pop    %esi
  801f67:	5f                   	pop    %edi
  801f68:	5d                   	pop    %ebp
  801f69:	c3                   	ret    

00801f6a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801f6a:	55                   	push   %ebp
  801f6b:	89 e5                	mov    %esp,%ebp
  801f6d:	53                   	push   %ebx
  801f6e:	83 ec 24             	sub    $0x24,%esp
  801f71:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f74:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f77:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f7b:	89 1c 24             	mov    %ebx,(%esp)
  801f7e:	e8 53 fd ff ff       	call   801cd6 <fd_lookup>
  801f83:	89 c2                	mov    %eax,%edx
  801f85:	85 d2                	test   %edx,%edx
  801f87:	78 6d                	js     801ff6 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f90:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f93:	8b 00                	mov    (%eax),%eax
  801f95:	89 04 24             	mov    %eax,(%esp)
  801f98:	e8 8f fd ff ff       	call   801d2c <dev_lookup>
  801f9d:	85 c0                	test   %eax,%eax
  801f9f:	78 55                	js     801ff6 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801fa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fa4:	8b 50 08             	mov    0x8(%eax),%edx
  801fa7:	83 e2 03             	and    $0x3,%edx
  801faa:	83 fa 01             	cmp    $0x1,%edx
  801fad:	75 23                	jne    801fd2 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801faf:	a1 20 50 80 00       	mov    0x805020,%eax
  801fb4:	8b 40 48             	mov    0x48(%eax),%eax
  801fb7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fbb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fbf:	c7 04 24 44 38 80 00 	movl   $0x803844,(%esp)
  801fc6:	e8 ec ea ff ff       	call   800ab7 <cprintf>
		return -E_INVAL;
  801fcb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801fd0:	eb 24                	jmp    801ff6 <read+0x8c>
	}
	if (!dev->dev_read)
  801fd2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fd5:	8b 52 08             	mov    0x8(%edx),%edx
  801fd8:	85 d2                	test   %edx,%edx
  801fda:	74 15                	je     801ff1 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801fdc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801fdf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fe3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fe6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801fea:	89 04 24             	mov    %eax,(%esp)
  801fed:	ff d2                	call   *%edx
  801fef:	eb 05                	jmp    801ff6 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801ff1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801ff6:	83 c4 24             	add    $0x24,%esp
  801ff9:	5b                   	pop    %ebx
  801ffa:	5d                   	pop    %ebp
  801ffb:	c3                   	ret    

00801ffc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801ffc:	55                   	push   %ebp
  801ffd:	89 e5                	mov    %esp,%ebp
  801fff:	57                   	push   %edi
  802000:	56                   	push   %esi
  802001:	53                   	push   %ebx
  802002:	83 ec 1c             	sub    $0x1c,%esp
  802005:	8b 7d 08             	mov    0x8(%ebp),%edi
  802008:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80200b:	bb 00 00 00 00       	mov    $0x0,%ebx
  802010:	eb 23                	jmp    802035 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802012:	89 f0                	mov    %esi,%eax
  802014:	29 d8                	sub    %ebx,%eax
  802016:	89 44 24 08          	mov    %eax,0x8(%esp)
  80201a:	89 d8                	mov    %ebx,%eax
  80201c:	03 45 0c             	add    0xc(%ebp),%eax
  80201f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802023:	89 3c 24             	mov    %edi,(%esp)
  802026:	e8 3f ff ff ff       	call   801f6a <read>
		if (m < 0)
  80202b:	85 c0                	test   %eax,%eax
  80202d:	78 10                	js     80203f <readn+0x43>
			return m;
		if (m == 0)
  80202f:	85 c0                	test   %eax,%eax
  802031:	74 0a                	je     80203d <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802033:	01 c3                	add    %eax,%ebx
  802035:	39 f3                	cmp    %esi,%ebx
  802037:	72 d9                	jb     802012 <readn+0x16>
  802039:	89 d8                	mov    %ebx,%eax
  80203b:	eb 02                	jmp    80203f <readn+0x43>
  80203d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80203f:	83 c4 1c             	add    $0x1c,%esp
  802042:	5b                   	pop    %ebx
  802043:	5e                   	pop    %esi
  802044:	5f                   	pop    %edi
  802045:	5d                   	pop    %ebp
  802046:	c3                   	ret    

00802047 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802047:	55                   	push   %ebp
  802048:	89 e5                	mov    %esp,%ebp
  80204a:	53                   	push   %ebx
  80204b:	83 ec 24             	sub    $0x24,%esp
  80204e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802051:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802054:	89 44 24 04          	mov    %eax,0x4(%esp)
  802058:	89 1c 24             	mov    %ebx,(%esp)
  80205b:	e8 76 fc ff ff       	call   801cd6 <fd_lookup>
  802060:	89 c2                	mov    %eax,%edx
  802062:	85 d2                	test   %edx,%edx
  802064:	78 68                	js     8020ce <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802066:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802069:	89 44 24 04          	mov    %eax,0x4(%esp)
  80206d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802070:	8b 00                	mov    (%eax),%eax
  802072:	89 04 24             	mov    %eax,(%esp)
  802075:	e8 b2 fc ff ff       	call   801d2c <dev_lookup>
  80207a:	85 c0                	test   %eax,%eax
  80207c:	78 50                	js     8020ce <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80207e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802081:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802085:	75 23                	jne    8020aa <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802087:	a1 20 50 80 00       	mov    0x805020,%eax
  80208c:	8b 40 48             	mov    0x48(%eax),%eax
  80208f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802093:	89 44 24 04          	mov    %eax,0x4(%esp)
  802097:	c7 04 24 60 38 80 00 	movl   $0x803860,(%esp)
  80209e:	e8 14 ea ff ff       	call   800ab7 <cprintf>
		return -E_INVAL;
  8020a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8020a8:	eb 24                	jmp    8020ce <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8020aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020ad:	8b 52 0c             	mov    0xc(%edx),%edx
  8020b0:	85 d2                	test   %edx,%edx
  8020b2:	74 15                	je     8020c9 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8020b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8020b7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020be:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8020c2:	89 04 24             	mov    %eax,(%esp)
  8020c5:	ff d2                	call   *%edx
  8020c7:	eb 05                	jmp    8020ce <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8020c9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8020ce:	83 c4 24             	add    $0x24,%esp
  8020d1:	5b                   	pop    %ebx
  8020d2:	5d                   	pop    %ebp
  8020d3:	c3                   	ret    

008020d4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8020d4:	55                   	push   %ebp
  8020d5:	89 e5                	mov    %esp,%ebp
  8020d7:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020da:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8020dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e4:	89 04 24             	mov    %eax,(%esp)
  8020e7:	e8 ea fb ff ff       	call   801cd6 <fd_lookup>
  8020ec:	85 c0                	test   %eax,%eax
  8020ee:	78 0e                	js     8020fe <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8020f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8020f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020f6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8020f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020fe:	c9                   	leave  
  8020ff:	c3                   	ret    

00802100 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802100:	55                   	push   %ebp
  802101:	89 e5                	mov    %esp,%ebp
  802103:	53                   	push   %ebx
  802104:	83 ec 24             	sub    $0x24,%esp
  802107:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80210a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80210d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802111:	89 1c 24             	mov    %ebx,(%esp)
  802114:	e8 bd fb ff ff       	call   801cd6 <fd_lookup>
  802119:	89 c2                	mov    %eax,%edx
  80211b:	85 d2                	test   %edx,%edx
  80211d:	78 61                	js     802180 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80211f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802122:	89 44 24 04          	mov    %eax,0x4(%esp)
  802126:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802129:	8b 00                	mov    (%eax),%eax
  80212b:	89 04 24             	mov    %eax,(%esp)
  80212e:	e8 f9 fb ff ff       	call   801d2c <dev_lookup>
  802133:	85 c0                	test   %eax,%eax
  802135:	78 49                	js     802180 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802137:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80213a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80213e:	75 23                	jne    802163 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802140:	a1 20 50 80 00       	mov    0x805020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802145:	8b 40 48             	mov    0x48(%eax),%eax
  802148:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80214c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802150:	c7 04 24 20 38 80 00 	movl   $0x803820,(%esp)
  802157:	e8 5b e9 ff ff       	call   800ab7 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80215c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802161:	eb 1d                	jmp    802180 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  802163:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802166:	8b 52 18             	mov    0x18(%edx),%edx
  802169:	85 d2                	test   %edx,%edx
  80216b:	74 0e                	je     80217b <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80216d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802170:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802174:	89 04 24             	mov    %eax,(%esp)
  802177:	ff d2                	call   *%edx
  802179:	eb 05                	jmp    802180 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80217b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  802180:	83 c4 24             	add    $0x24,%esp
  802183:	5b                   	pop    %ebx
  802184:	5d                   	pop    %ebp
  802185:	c3                   	ret    

00802186 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802186:	55                   	push   %ebp
  802187:	89 e5                	mov    %esp,%ebp
  802189:	53                   	push   %ebx
  80218a:	83 ec 24             	sub    $0x24,%esp
  80218d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802190:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802193:	89 44 24 04          	mov    %eax,0x4(%esp)
  802197:	8b 45 08             	mov    0x8(%ebp),%eax
  80219a:	89 04 24             	mov    %eax,(%esp)
  80219d:	e8 34 fb ff ff       	call   801cd6 <fd_lookup>
  8021a2:	89 c2                	mov    %eax,%edx
  8021a4:	85 d2                	test   %edx,%edx
  8021a6:	78 52                	js     8021fa <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8021a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021b2:	8b 00                	mov    (%eax),%eax
  8021b4:	89 04 24             	mov    %eax,(%esp)
  8021b7:	e8 70 fb ff ff       	call   801d2c <dev_lookup>
  8021bc:	85 c0                	test   %eax,%eax
  8021be:	78 3a                	js     8021fa <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8021c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8021c7:	74 2c                	je     8021f5 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8021c9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8021cc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8021d3:	00 00 00 
	stat->st_isdir = 0;
  8021d6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8021dd:	00 00 00 
	stat->st_dev = dev;
  8021e0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8021e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021ed:	89 14 24             	mov    %edx,(%esp)
  8021f0:	ff 50 14             	call   *0x14(%eax)
  8021f3:	eb 05                	jmp    8021fa <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8021f5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8021fa:	83 c4 24             	add    $0x24,%esp
  8021fd:	5b                   	pop    %ebx
  8021fe:	5d                   	pop    %ebp
  8021ff:	c3                   	ret    

00802200 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802200:	55                   	push   %ebp
  802201:	89 e5                	mov    %esp,%ebp
  802203:	56                   	push   %esi
  802204:	53                   	push   %ebx
  802205:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802208:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80220f:	00 
  802210:	8b 45 08             	mov    0x8(%ebp),%eax
  802213:	89 04 24             	mov    %eax,(%esp)
  802216:	e8 28 02 00 00       	call   802443 <open>
  80221b:	89 c3                	mov    %eax,%ebx
  80221d:	85 db                	test   %ebx,%ebx
  80221f:	78 1b                	js     80223c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  802221:	8b 45 0c             	mov    0xc(%ebp),%eax
  802224:	89 44 24 04          	mov    %eax,0x4(%esp)
  802228:	89 1c 24             	mov    %ebx,(%esp)
  80222b:	e8 56 ff ff ff       	call   802186 <fstat>
  802230:	89 c6                	mov    %eax,%esi
	close(fd);
  802232:	89 1c 24             	mov    %ebx,(%esp)
  802235:	e8 cd fb ff ff       	call   801e07 <close>
	return r;
  80223a:	89 f0                	mov    %esi,%eax
}
  80223c:	83 c4 10             	add    $0x10,%esp
  80223f:	5b                   	pop    %ebx
  802240:	5e                   	pop    %esi
  802241:	5d                   	pop    %ebp
  802242:	c3                   	ret    

00802243 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802243:	55                   	push   %ebp
  802244:	89 e5                	mov    %esp,%ebp
  802246:	56                   	push   %esi
  802247:	53                   	push   %ebx
  802248:	83 ec 10             	sub    $0x10,%esp
  80224b:	89 c6                	mov    %eax,%esi
  80224d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80224f:	83 3d 18 50 80 00 00 	cmpl   $0x0,0x805018
  802256:	75 11                	jne    802269 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802258:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80225f:	e8 c1 f9 ff ff       	call   801c25 <ipc_find_env>
  802264:	a3 18 50 80 00       	mov    %eax,0x805018
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802269:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802270:	00 
  802271:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  802278:	00 
  802279:	89 74 24 04          	mov    %esi,0x4(%esp)
  80227d:	a1 18 50 80 00       	mov    0x805018,%eax
  802282:	89 04 24             	mov    %eax,(%esp)
  802285:	e8 30 f9 ff ff       	call   801bba <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80228a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802291:	00 
  802292:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802296:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80229d:	e8 9e f8 ff ff       	call   801b40 <ipc_recv>
}
  8022a2:	83 c4 10             	add    $0x10,%esp
  8022a5:	5b                   	pop    %ebx
  8022a6:	5e                   	pop    %esi
  8022a7:	5d                   	pop    %ebp
  8022a8:	c3                   	ret    

008022a9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8022a9:	55                   	push   %ebp
  8022aa:	89 e5                	mov    %esp,%ebp
  8022ac:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8022af:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8022b5:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8022ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022bd:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8022c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8022c7:	b8 02 00 00 00       	mov    $0x2,%eax
  8022cc:	e8 72 ff ff ff       	call   802243 <fsipc>
}
  8022d1:	c9                   	leave  
  8022d2:	c3                   	ret    

008022d3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8022d3:	55                   	push   %ebp
  8022d4:	89 e5                	mov    %esp,%ebp
  8022d6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8022d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8022dc:	8b 40 0c             	mov    0xc(%eax),%eax
  8022df:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8022e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8022e9:	b8 06 00 00 00       	mov    $0x6,%eax
  8022ee:	e8 50 ff ff ff       	call   802243 <fsipc>
}
  8022f3:	c9                   	leave  
  8022f4:	c3                   	ret    

008022f5 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8022f5:	55                   	push   %ebp
  8022f6:	89 e5                	mov    %esp,%ebp
  8022f8:	53                   	push   %ebx
  8022f9:	83 ec 14             	sub    $0x14,%esp
  8022fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8022ff:	8b 45 08             	mov    0x8(%ebp),%eax
  802302:	8b 40 0c             	mov    0xc(%eax),%eax
  802305:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80230a:	ba 00 00 00 00       	mov    $0x0,%edx
  80230f:	b8 05 00 00 00       	mov    $0x5,%eax
  802314:	e8 2a ff ff ff       	call   802243 <fsipc>
  802319:	89 c2                	mov    %eax,%edx
  80231b:	85 d2                	test   %edx,%edx
  80231d:	78 2b                	js     80234a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80231f:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802326:	00 
  802327:	89 1c 24             	mov    %ebx,(%esp)
  80232a:	e8 b8 ed ff ff       	call   8010e7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80232f:	a1 80 60 80 00       	mov    0x806080,%eax
  802334:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80233a:	a1 84 60 80 00       	mov    0x806084,%eax
  80233f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802345:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80234a:	83 c4 14             	add    $0x14,%esp
  80234d:	5b                   	pop    %ebx
  80234e:	5d                   	pop    %ebp
  80234f:	c3                   	ret    

00802350 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802350:	55                   	push   %ebp
  802351:	89 e5                	mov    %esp,%ebp
  802353:	83 ec 18             	sub    $0x18,%esp
  802356:	8b 45 10             	mov    0x10(%ebp),%eax
  802359:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80235e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  802363:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802366:	8b 55 08             	mov    0x8(%ebp),%edx
  802369:	8b 52 0c             	mov    0xc(%edx),%edx
  80236c:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  802372:	a3 04 60 80 00       	mov    %eax,0x806004

	memmove(fsipcbuf.write.req_buf, buf, n);
  802377:	89 44 24 08          	mov    %eax,0x8(%esp)
  80237b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80237e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802382:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  802389:	e8 f6 ee ff ff       	call   801284 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  80238e:	ba 00 00 00 00       	mov    $0x0,%edx
  802393:	b8 04 00 00 00       	mov    $0x4,%eax
  802398:	e8 a6 fe ff ff       	call   802243 <fsipc>
}
  80239d:	c9                   	leave  
  80239e:	c3                   	ret    

0080239f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80239f:	55                   	push   %ebp
  8023a0:	89 e5                	mov    %esp,%ebp
  8023a2:	56                   	push   %esi
  8023a3:	53                   	push   %ebx
  8023a4:	83 ec 10             	sub    $0x10,%esp
  8023a7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8023aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8023b0:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8023b5:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8023bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8023c0:	b8 03 00 00 00       	mov    $0x3,%eax
  8023c5:	e8 79 fe ff ff       	call   802243 <fsipc>
  8023ca:	89 c3                	mov    %eax,%ebx
  8023cc:	85 c0                	test   %eax,%eax
  8023ce:	78 6a                	js     80243a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8023d0:	39 c6                	cmp    %eax,%esi
  8023d2:	73 24                	jae    8023f8 <devfile_read+0x59>
  8023d4:	c7 44 24 0c 94 38 80 	movl   $0x803894,0xc(%esp)
  8023db:	00 
  8023dc:	c7 44 24 08 9b 38 80 	movl   $0x80389b,0x8(%esp)
  8023e3:	00 
  8023e4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8023eb:	00 
  8023ec:	c7 04 24 b0 38 80 00 	movl   $0x8038b0,(%esp)
  8023f3:	e8 c6 e5 ff ff       	call   8009be <_panic>
	assert(r <= PGSIZE);
  8023f8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8023fd:	7e 24                	jle    802423 <devfile_read+0x84>
  8023ff:	c7 44 24 0c bb 38 80 	movl   $0x8038bb,0xc(%esp)
  802406:	00 
  802407:	c7 44 24 08 9b 38 80 	movl   $0x80389b,0x8(%esp)
  80240e:	00 
  80240f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  802416:	00 
  802417:	c7 04 24 b0 38 80 00 	movl   $0x8038b0,(%esp)
  80241e:	e8 9b e5 ff ff       	call   8009be <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802423:	89 44 24 08          	mov    %eax,0x8(%esp)
  802427:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80242e:	00 
  80242f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802432:	89 04 24             	mov    %eax,(%esp)
  802435:	e8 4a ee ff ff       	call   801284 <memmove>
	return r;
}
  80243a:	89 d8                	mov    %ebx,%eax
  80243c:	83 c4 10             	add    $0x10,%esp
  80243f:	5b                   	pop    %ebx
  802440:	5e                   	pop    %esi
  802441:	5d                   	pop    %ebp
  802442:	c3                   	ret    

00802443 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802443:	55                   	push   %ebp
  802444:	89 e5                	mov    %esp,%ebp
  802446:	53                   	push   %ebx
  802447:	83 ec 24             	sub    $0x24,%esp
  80244a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80244d:	89 1c 24             	mov    %ebx,(%esp)
  802450:	e8 5b ec ff ff       	call   8010b0 <strlen>
  802455:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80245a:	7f 60                	jg     8024bc <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80245c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80245f:	89 04 24             	mov    %eax,(%esp)
  802462:	e8 20 f8 ff ff       	call   801c87 <fd_alloc>
  802467:	89 c2                	mov    %eax,%edx
  802469:	85 d2                	test   %edx,%edx
  80246b:	78 54                	js     8024c1 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80246d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802471:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  802478:	e8 6a ec ff ff       	call   8010e7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80247d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802480:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802485:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802488:	b8 01 00 00 00       	mov    $0x1,%eax
  80248d:	e8 b1 fd ff ff       	call   802243 <fsipc>
  802492:	89 c3                	mov    %eax,%ebx
  802494:	85 c0                	test   %eax,%eax
  802496:	79 17                	jns    8024af <open+0x6c>
		fd_close(fd, 0);
  802498:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80249f:	00 
  8024a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024a3:	89 04 24             	mov    %eax,(%esp)
  8024a6:	e8 db f8 ff ff       	call   801d86 <fd_close>
		return r;
  8024ab:	89 d8                	mov    %ebx,%eax
  8024ad:	eb 12                	jmp    8024c1 <open+0x7e>
	}

	return fd2num(fd);
  8024af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024b2:	89 04 24             	mov    %eax,(%esp)
  8024b5:	e8 a6 f7 ff ff       	call   801c60 <fd2num>
  8024ba:	eb 05                	jmp    8024c1 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8024bc:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8024c1:	83 c4 24             	add    $0x24,%esp
  8024c4:	5b                   	pop    %ebx
  8024c5:	5d                   	pop    %ebp
  8024c6:	c3                   	ret    

008024c7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8024c7:	55                   	push   %ebp
  8024c8:	89 e5                	mov    %esp,%ebp
  8024ca:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8024cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8024d2:	b8 08 00 00 00       	mov    $0x8,%eax
  8024d7:	e8 67 fd ff ff       	call   802243 <fsipc>
}
  8024dc:	c9                   	leave  
  8024dd:	c3                   	ret    
  8024de:	66 90                	xchg   %ax,%ax

008024e0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8024e0:	55                   	push   %ebp
  8024e1:	89 e5                	mov    %esp,%ebp
  8024e3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  8024e6:	c7 44 24 04 c7 38 80 	movl   $0x8038c7,0x4(%esp)
  8024ed:	00 
  8024ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024f1:	89 04 24             	mov    %eax,(%esp)
  8024f4:	e8 ee eb ff ff       	call   8010e7 <strcpy>
	return 0;
}
  8024f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8024fe:	c9                   	leave  
  8024ff:	c3                   	ret    

00802500 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802500:	55                   	push   %ebp
  802501:	89 e5                	mov    %esp,%ebp
  802503:	53                   	push   %ebx
  802504:	83 ec 14             	sub    $0x14,%esp
  802507:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80250a:	89 1c 24             	mov    %ebx,(%esp)
  80250d:	e8 75 0a 00 00       	call   802f87 <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  802512:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  802517:	83 f8 01             	cmp    $0x1,%eax
  80251a:	75 0d                	jne    802529 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80251c:	8b 43 0c             	mov    0xc(%ebx),%eax
  80251f:	89 04 24             	mov    %eax,(%esp)
  802522:	e8 29 03 00 00       	call   802850 <nsipc_close>
  802527:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  802529:	89 d0                	mov    %edx,%eax
  80252b:	83 c4 14             	add    $0x14,%esp
  80252e:	5b                   	pop    %ebx
  80252f:	5d                   	pop    %ebp
  802530:	c3                   	ret    

00802531 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802531:	55                   	push   %ebp
  802532:	89 e5                	mov    %esp,%ebp
  802534:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802537:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80253e:	00 
  80253f:	8b 45 10             	mov    0x10(%ebp),%eax
  802542:	89 44 24 08          	mov    %eax,0x8(%esp)
  802546:	8b 45 0c             	mov    0xc(%ebp),%eax
  802549:	89 44 24 04          	mov    %eax,0x4(%esp)
  80254d:	8b 45 08             	mov    0x8(%ebp),%eax
  802550:	8b 40 0c             	mov    0xc(%eax),%eax
  802553:	89 04 24             	mov    %eax,(%esp)
  802556:	e8 f0 03 00 00       	call   80294b <nsipc_send>
}
  80255b:	c9                   	leave  
  80255c:	c3                   	ret    

0080255d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80255d:	55                   	push   %ebp
  80255e:	89 e5                	mov    %esp,%ebp
  802560:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802563:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80256a:	00 
  80256b:	8b 45 10             	mov    0x10(%ebp),%eax
  80256e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802572:	8b 45 0c             	mov    0xc(%ebp),%eax
  802575:	89 44 24 04          	mov    %eax,0x4(%esp)
  802579:	8b 45 08             	mov    0x8(%ebp),%eax
  80257c:	8b 40 0c             	mov    0xc(%eax),%eax
  80257f:	89 04 24             	mov    %eax,(%esp)
  802582:	e8 44 03 00 00       	call   8028cb <nsipc_recv>
}
  802587:	c9                   	leave  
  802588:	c3                   	ret    

00802589 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802589:	55                   	push   %ebp
  80258a:	89 e5                	mov    %esp,%ebp
  80258c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80258f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802592:	89 54 24 04          	mov    %edx,0x4(%esp)
  802596:	89 04 24             	mov    %eax,(%esp)
  802599:	e8 38 f7 ff ff       	call   801cd6 <fd_lookup>
  80259e:	85 c0                	test   %eax,%eax
  8025a0:	78 17                	js     8025b9 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8025a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025a5:	8b 0d 20 40 80 00    	mov    0x804020,%ecx
  8025ab:	39 08                	cmp    %ecx,(%eax)
  8025ad:	75 05                	jne    8025b4 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8025af:	8b 40 0c             	mov    0xc(%eax),%eax
  8025b2:	eb 05                	jmp    8025b9 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8025b4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8025b9:	c9                   	leave  
  8025ba:	c3                   	ret    

008025bb <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8025bb:	55                   	push   %ebp
  8025bc:	89 e5                	mov    %esp,%ebp
  8025be:	56                   	push   %esi
  8025bf:	53                   	push   %ebx
  8025c0:	83 ec 20             	sub    $0x20,%esp
  8025c3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8025c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025c8:	89 04 24             	mov    %eax,(%esp)
  8025cb:	e8 b7 f6 ff ff       	call   801c87 <fd_alloc>
  8025d0:	89 c3                	mov    %eax,%ebx
  8025d2:	85 c0                	test   %eax,%eax
  8025d4:	78 21                	js     8025f7 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8025d6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8025dd:	00 
  8025de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025ec:	e8 12 ef ff ff       	call   801503 <sys_page_alloc>
  8025f1:	89 c3                	mov    %eax,%ebx
  8025f3:	85 c0                	test   %eax,%eax
  8025f5:	79 0c                	jns    802603 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  8025f7:	89 34 24             	mov    %esi,(%esp)
  8025fa:	e8 51 02 00 00       	call   802850 <nsipc_close>
		return r;
  8025ff:	89 d8                	mov    %ebx,%eax
  802601:	eb 20                	jmp    802623 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802603:	8b 15 20 40 80 00    	mov    0x804020,%edx
  802609:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80260c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80260e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802611:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  802618:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  80261b:	89 14 24             	mov    %edx,(%esp)
  80261e:	e8 3d f6 ff ff       	call   801c60 <fd2num>
}
  802623:	83 c4 20             	add    $0x20,%esp
  802626:	5b                   	pop    %ebx
  802627:	5e                   	pop    %esi
  802628:	5d                   	pop    %ebp
  802629:	c3                   	ret    

0080262a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80262a:	55                   	push   %ebp
  80262b:	89 e5                	mov    %esp,%ebp
  80262d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802630:	8b 45 08             	mov    0x8(%ebp),%eax
  802633:	e8 51 ff ff ff       	call   802589 <fd2sockid>
		return r;
  802638:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80263a:	85 c0                	test   %eax,%eax
  80263c:	78 23                	js     802661 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80263e:	8b 55 10             	mov    0x10(%ebp),%edx
  802641:	89 54 24 08          	mov    %edx,0x8(%esp)
  802645:	8b 55 0c             	mov    0xc(%ebp),%edx
  802648:	89 54 24 04          	mov    %edx,0x4(%esp)
  80264c:	89 04 24             	mov    %eax,(%esp)
  80264f:	e8 45 01 00 00       	call   802799 <nsipc_accept>
		return r;
  802654:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802656:	85 c0                	test   %eax,%eax
  802658:	78 07                	js     802661 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  80265a:	e8 5c ff ff ff       	call   8025bb <alloc_sockfd>
  80265f:	89 c1                	mov    %eax,%ecx
}
  802661:	89 c8                	mov    %ecx,%eax
  802663:	c9                   	leave  
  802664:	c3                   	ret    

00802665 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802665:	55                   	push   %ebp
  802666:	89 e5                	mov    %esp,%ebp
  802668:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80266b:	8b 45 08             	mov    0x8(%ebp),%eax
  80266e:	e8 16 ff ff ff       	call   802589 <fd2sockid>
  802673:	89 c2                	mov    %eax,%edx
  802675:	85 d2                	test   %edx,%edx
  802677:	78 16                	js     80268f <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  802679:	8b 45 10             	mov    0x10(%ebp),%eax
  80267c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802680:	8b 45 0c             	mov    0xc(%ebp),%eax
  802683:	89 44 24 04          	mov    %eax,0x4(%esp)
  802687:	89 14 24             	mov    %edx,(%esp)
  80268a:	e8 60 01 00 00       	call   8027ef <nsipc_bind>
}
  80268f:	c9                   	leave  
  802690:	c3                   	ret    

00802691 <shutdown>:

int
shutdown(int s, int how)
{
  802691:	55                   	push   %ebp
  802692:	89 e5                	mov    %esp,%ebp
  802694:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802697:	8b 45 08             	mov    0x8(%ebp),%eax
  80269a:	e8 ea fe ff ff       	call   802589 <fd2sockid>
  80269f:	89 c2                	mov    %eax,%edx
  8026a1:	85 d2                	test   %edx,%edx
  8026a3:	78 0f                	js     8026b4 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  8026a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026ac:	89 14 24             	mov    %edx,(%esp)
  8026af:	e8 7a 01 00 00       	call   80282e <nsipc_shutdown>
}
  8026b4:	c9                   	leave  
  8026b5:	c3                   	ret    

008026b6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8026b6:	55                   	push   %ebp
  8026b7:	89 e5                	mov    %esp,%ebp
  8026b9:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8026bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8026bf:	e8 c5 fe ff ff       	call   802589 <fd2sockid>
  8026c4:	89 c2                	mov    %eax,%edx
  8026c6:	85 d2                	test   %edx,%edx
  8026c8:	78 16                	js     8026e0 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  8026ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8026cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026d8:	89 14 24             	mov    %edx,(%esp)
  8026db:	e8 8a 01 00 00       	call   80286a <nsipc_connect>
}
  8026e0:	c9                   	leave  
  8026e1:	c3                   	ret    

008026e2 <listen>:

int
listen(int s, int backlog)
{
  8026e2:	55                   	push   %ebp
  8026e3:	89 e5                	mov    %esp,%ebp
  8026e5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8026e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8026eb:	e8 99 fe ff ff       	call   802589 <fd2sockid>
  8026f0:	89 c2                	mov    %eax,%edx
  8026f2:	85 d2                	test   %edx,%edx
  8026f4:	78 0f                	js     802705 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  8026f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026fd:	89 14 24             	mov    %edx,(%esp)
  802700:	e8 a4 01 00 00       	call   8028a9 <nsipc_listen>
}
  802705:	c9                   	leave  
  802706:	c3                   	ret    

00802707 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802707:	55                   	push   %ebp
  802708:	89 e5                	mov    %esp,%ebp
  80270a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80270d:	8b 45 10             	mov    0x10(%ebp),%eax
  802710:	89 44 24 08          	mov    %eax,0x8(%esp)
  802714:	8b 45 0c             	mov    0xc(%ebp),%eax
  802717:	89 44 24 04          	mov    %eax,0x4(%esp)
  80271b:	8b 45 08             	mov    0x8(%ebp),%eax
  80271e:	89 04 24             	mov    %eax,(%esp)
  802721:	e8 98 02 00 00       	call   8029be <nsipc_socket>
  802726:	89 c2                	mov    %eax,%edx
  802728:	85 d2                	test   %edx,%edx
  80272a:	78 05                	js     802731 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  80272c:	e8 8a fe ff ff       	call   8025bb <alloc_sockfd>
}
  802731:	c9                   	leave  
  802732:	c3                   	ret    

00802733 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802733:	55                   	push   %ebp
  802734:	89 e5                	mov    %esp,%ebp
  802736:	53                   	push   %ebx
  802737:	83 ec 14             	sub    $0x14,%esp
  80273a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80273c:	83 3d 1c 50 80 00 00 	cmpl   $0x0,0x80501c
  802743:	75 11                	jne    802756 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802745:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80274c:	e8 d4 f4 ff ff       	call   801c25 <ipc_find_env>
  802751:	a3 1c 50 80 00       	mov    %eax,0x80501c
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802756:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80275d:	00 
  80275e:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802765:	00 
  802766:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80276a:	a1 1c 50 80 00       	mov    0x80501c,%eax
  80276f:	89 04 24             	mov    %eax,(%esp)
  802772:	e8 43 f4 ff ff       	call   801bba <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802777:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80277e:	00 
  80277f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802786:	00 
  802787:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80278e:	e8 ad f3 ff ff       	call   801b40 <ipc_recv>
}
  802793:	83 c4 14             	add    $0x14,%esp
  802796:	5b                   	pop    %ebx
  802797:	5d                   	pop    %ebp
  802798:	c3                   	ret    

00802799 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802799:	55                   	push   %ebp
  80279a:	89 e5                	mov    %esp,%ebp
  80279c:	56                   	push   %esi
  80279d:	53                   	push   %ebx
  80279e:	83 ec 10             	sub    $0x10,%esp
  8027a1:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8027a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8027a7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8027ac:	8b 06                	mov    (%esi),%eax
  8027ae:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8027b3:	b8 01 00 00 00       	mov    $0x1,%eax
  8027b8:	e8 76 ff ff ff       	call   802733 <nsipc>
  8027bd:	89 c3                	mov    %eax,%ebx
  8027bf:	85 c0                	test   %eax,%eax
  8027c1:	78 23                	js     8027e6 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8027c3:	a1 10 70 80 00       	mov    0x807010,%eax
  8027c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8027cc:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8027d3:	00 
  8027d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027d7:	89 04 24             	mov    %eax,(%esp)
  8027da:	e8 a5 ea ff ff       	call   801284 <memmove>
		*addrlen = ret->ret_addrlen;
  8027df:	a1 10 70 80 00       	mov    0x807010,%eax
  8027e4:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  8027e6:	89 d8                	mov    %ebx,%eax
  8027e8:	83 c4 10             	add    $0x10,%esp
  8027eb:	5b                   	pop    %ebx
  8027ec:	5e                   	pop    %esi
  8027ed:	5d                   	pop    %ebp
  8027ee:	c3                   	ret    

008027ef <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8027ef:	55                   	push   %ebp
  8027f0:	89 e5                	mov    %esp,%ebp
  8027f2:	53                   	push   %ebx
  8027f3:	83 ec 14             	sub    $0x14,%esp
  8027f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8027f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8027fc:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802801:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802805:	8b 45 0c             	mov    0xc(%ebp),%eax
  802808:	89 44 24 04          	mov    %eax,0x4(%esp)
  80280c:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802813:	e8 6c ea ff ff       	call   801284 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802818:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80281e:	b8 02 00 00 00       	mov    $0x2,%eax
  802823:	e8 0b ff ff ff       	call   802733 <nsipc>
}
  802828:	83 c4 14             	add    $0x14,%esp
  80282b:	5b                   	pop    %ebx
  80282c:	5d                   	pop    %ebp
  80282d:	c3                   	ret    

0080282e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80282e:	55                   	push   %ebp
  80282f:	89 e5                	mov    %esp,%ebp
  802831:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802834:	8b 45 08             	mov    0x8(%ebp),%eax
  802837:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80283c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80283f:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802844:	b8 03 00 00 00       	mov    $0x3,%eax
  802849:	e8 e5 fe ff ff       	call   802733 <nsipc>
}
  80284e:	c9                   	leave  
  80284f:	c3                   	ret    

00802850 <nsipc_close>:

int
nsipc_close(int s)
{
  802850:	55                   	push   %ebp
  802851:	89 e5                	mov    %esp,%ebp
  802853:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802856:	8b 45 08             	mov    0x8(%ebp),%eax
  802859:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  80285e:	b8 04 00 00 00       	mov    $0x4,%eax
  802863:	e8 cb fe ff ff       	call   802733 <nsipc>
}
  802868:	c9                   	leave  
  802869:	c3                   	ret    

0080286a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80286a:	55                   	push   %ebp
  80286b:	89 e5                	mov    %esp,%ebp
  80286d:	53                   	push   %ebx
  80286e:	83 ec 14             	sub    $0x14,%esp
  802871:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802874:	8b 45 08             	mov    0x8(%ebp),%eax
  802877:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80287c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802880:	8b 45 0c             	mov    0xc(%ebp),%eax
  802883:	89 44 24 04          	mov    %eax,0x4(%esp)
  802887:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  80288e:	e8 f1 e9 ff ff       	call   801284 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802893:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802899:	b8 05 00 00 00       	mov    $0x5,%eax
  80289e:	e8 90 fe ff ff       	call   802733 <nsipc>
}
  8028a3:	83 c4 14             	add    $0x14,%esp
  8028a6:	5b                   	pop    %ebx
  8028a7:	5d                   	pop    %ebp
  8028a8:	c3                   	ret    

008028a9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8028a9:	55                   	push   %ebp
  8028aa:	89 e5                	mov    %esp,%ebp
  8028ac:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8028af:	8b 45 08             	mov    0x8(%ebp),%eax
  8028b2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8028b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028ba:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8028bf:	b8 06 00 00 00       	mov    $0x6,%eax
  8028c4:	e8 6a fe ff ff       	call   802733 <nsipc>
}
  8028c9:	c9                   	leave  
  8028ca:	c3                   	ret    

008028cb <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8028cb:	55                   	push   %ebp
  8028cc:	89 e5                	mov    %esp,%ebp
  8028ce:	56                   	push   %esi
  8028cf:	53                   	push   %ebx
  8028d0:	83 ec 10             	sub    $0x10,%esp
  8028d3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8028d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8028d9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8028de:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8028e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8028e7:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8028ec:	b8 07 00 00 00       	mov    $0x7,%eax
  8028f1:	e8 3d fe ff ff       	call   802733 <nsipc>
  8028f6:	89 c3                	mov    %eax,%ebx
  8028f8:	85 c0                	test   %eax,%eax
  8028fa:	78 46                	js     802942 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8028fc:	39 f0                	cmp    %esi,%eax
  8028fe:	7f 07                	jg     802907 <nsipc_recv+0x3c>
  802900:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802905:	7e 24                	jle    80292b <nsipc_recv+0x60>
  802907:	c7 44 24 0c d3 38 80 	movl   $0x8038d3,0xc(%esp)
  80290e:	00 
  80290f:	c7 44 24 08 9b 38 80 	movl   $0x80389b,0x8(%esp)
  802916:	00 
  802917:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80291e:	00 
  80291f:	c7 04 24 e8 38 80 00 	movl   $0x8038e8,(%esp)
  802926:	e8 93 e0 ff ff       	call   8009be <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80292b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80292f:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802936:	00 
  802937:	8b 45 0c             	mov    0xc(%ebp),%eax
  80293a:	89 04 24             	mov    %eax,(%esp)
  80293d:	e8 42 e9 ff ff       	call   801284 <memmove>
	}

	return r;
}
  802942:	89 d8                	mov    %ebx,%eax
  802944:	83 c4 10             	add    $0x10,%esp
  802947:	5b                   	pop    %ebx
  802948:	5e                   	pop    %esi
  802949:	5d                   	pop    %ebp
  80294a:	c3                   	ret    

0080294b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80294b:	55                   	push   %ebp
  80294c:	89 e5                	mov    %esp,%ebp
  80294e:	53                   	push   %ebx
  80294f:	83 ec 14             	sub    $0x14,%esp
  802952:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802955:	8b 45 08             	mov    0x8(%ebp),%eax
  802958:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  80295d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802963:	7e 24                	jle    802989 <nsipc_send+0x3e>
  802965:	c7 44 24 0c f4 38 80 	movl   $0x8038f4,0xc(%esp)
  80296c:	00 
  80296d:	c7 44 24 08 9b 38 80 	movl   $0x80389b,0x8(%esp)
  802974:	00 
  802975:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  80297c:	00 
  80297d:	c7 04 24 e8 38 80 00 	movl   $0x8038e8,(%esp)
  802984:	e8 35 e0 ff ff       	call   8009be <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802989:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80298d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802990:	89 44 24 04          	mov    %eax,0x4(%esp)
  802994:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  80299b:	e8 e4 e8 ff ff       	call   801284 <memmove>
	nsipcbuf.send.req_size = size;
  8029a0:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8029a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8029a9:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8029ae:	b8 08 00 00 00       	mov    $0x8,%eax
  8029b3:	e8 7b fd ff ff       	call   802733 <nsipc>
}
  8029b8:	83 c4 14             	add    $0x14,%esp
  8029bb:	5b                   	pop    %ebx
  8029bc:	5d                   	pop    %ebp
  8029bd:	c3                   	ret    

008029be <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8029be:	55                   	push   %ebp
  8029bf:	89 e5                	mov    %esp,%ebp
  8029c1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8029c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8029c7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8029cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029cf:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8029d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8029d7:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8029dc:	b8 09 00 00 00       	mov    $0x9,%eax
  8029e1:	e8 4d fd ff ff       	call   802733 <nsipc>
}
  8029e6:	c9                   	leave  
  8029e7:	c3                   	ret    

008029e8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8029e8:	55                   	push   %ebp
  8029e9:	89 e5                	mov    %esp,%ebp
  8029eb:	56                   	push   %esi
  8029ec:	53                   	push   %ebx
  8029ed:	83 ec 10             	sub    $0x10,%esp
  8029f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8029f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8029f6:	89 04 24             	mov    %eax,(%esp)
  8029f9:	e8 72 f2 ff ff       	call   801c70 <fd2data>
  8029fe:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802a00:	c7 44 24 04 00 39 80 	movl   $0x803900,0x4(%esp)
  802a07:	00 
  802a08:	89 1c 24             	mov    %ebx,(%esp)
  802a0b:	e8 d7 e6 ff ff       	call   8010e7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802a10:	8b 46 04             	mov    0x4(%esi),%eax
  802a13:	2b 06                	sub    (%esi),%eax
  802a15:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802a1b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802a22:	00 00 00 
	stat->st_dev = &devpipe;
  802a25:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802a2c:	40 80 00 
	return 0;
}
  802a2f:	b8 00 00 00 00       	mov    $0x0,%eax
  802a34:	83 c4 10             	add    $0x10,%esp
  802a37:	5b                   	pop    %ebx
  802a38:	5e                   	pop    %esi
  802a39:	5d                   	pop    %ebp
  802a3a:	c3                   	ret    

00802a3b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802a3b:	55                   	push   %ebp
  802a3c:	89 e5                	mov    %esp,%ebp
  802a3e:	53                   	push   %ebx
  802a3f:	83 ec 14             	sub    $0x14,%esp
  802a42:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802a45:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802a49:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a50:	e8 55 eb ff ff       	call   8015aa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802a55:	89 1c 24             	mov    %ebx,(%esp)
  802a58:	e8 13 f2 ff ff       	call   801c70 <fd2data>
  802a5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a68:	e8 3d eb ff ff       	call   8015aa <sys_page_unmap>
}
  802a6d:	83 c4 14             	add    $0x14,%esp
  802a70:	5b                   	pop    %ebx
  802a71:	5d                   	pop    %ebp
  802a72:	c3                   	ret    

00802a73 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802a73:	55                   	push   %ebp
  802a74:	89 e5                	mov    %esp,%ebp
  802a76:	57                   	push   %edi
  802a77:	56                   	push   %esi
  802a78:	53                   	push   %ebx
  802a79:	83 ec 2c             	sub    $0x2c,%esp
  802a7c:	89 c6                	mov    %eax,%esi
  802a7e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802a81:	a1 20 50 80 00       	mov    0x805020,%eax
  802a86:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802a89:	89 34 24             	mov    %esi,(%esp)
  802a8c:	e8 f6 04 00 00       	call   802f87 <pageref>
  802a91:	89 c7                	mov    %eax,%edi
  802a93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802a96:	89 04 24             	mov    %eax,(%esp)
  802a99:	e8 e9 04 00 00       	call   802f87 <pageref>
  802a9e:	39 c7                	cmp    %eax,%edi
  802aa0:	0f 94 c2             	sete   %dl
  802aa3:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  802aa6:	8b 0d 20 50 80 00    	mov    0x805020,%ecx
  802aac:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  802aaf:	39 fb                	cmp    %edi,%ebx
  802ab1:	74 21                	je     802ad4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802ab3:	84 d2                	test   %dl,%dl
  802ab5:	74 ca                	je     802a81 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802ab7:	8b 51 58             	mov    0x58(%ecx),%edx
  802aba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802abe:	89 54 24 08          	mov    %edx,0x8(%esp)
  802ac2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802ac6:	c7 04 24 07 39 80 00 	movl   $0x803907,(%esp)
  802acd:	e8 e5 df ff ff       	call   800ab7 <cprintf>
  802ad2:	eb ad                	jmp    802a81 <_pipeisclosed+0xe>
	}
}
  802ad4:	83 c4 2c             	add    $0x2c,%esp
  802ad7:	5b                   	pop    %ebx
  802ad8:	5e                   	pop    %esi
  802ad9:	5f                   	pop    %edi
  802ada:	5d                   	pop    %ebp
  802adb:	c3                   	ret    

00802adc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802adc:	55                   	push   %ebp
  802add:	89 e5                	mov    %esp,%ebp
  802adf:	57                   	push   %edi
  802ae0:	56                   	push   %esi
  802ae1:	53                   	push   %ebx
  802ae2:	83 ec 1c             	sub    $0x1c,%esp
  802ae5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802ae8:	89 34 24             	mov    %esi,(%esp)
  802aeb:	e8 80 f1 ff ff       	call   801c70 <fd2data>
  802af0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802af2:	bf 00 00 00 00       	mov    $0x0,%edi
  802af7:	eb 45                	jmp    802b3e <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802af9:	89 da                	mov    %ebx,%edx
  802afb:	89 f0                	mov    %esi,%eax
  802afd:	e8 71 ff ff ff       	call   802a73 <_pipeisclosed>
  802b02:	85 c0                	test   %eax,%eax
  802b04:	75 41                	jne    802b47 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802b06:	e8 d9 e9 ff ff       	call   8014e4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802b0b:	8b 43 04             	mov    0x4(%ebx),%eax
  802b0e:	8b 0b                	mov    (%ebx),%ecx
  802b10:	8d 51 20             	lea    0x20(%ecx),%edx
  802b13:	39 d0                	cmp    %edx,%eax
  802b15:	73 e2                	jae    802af9 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802b17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802b1a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802b1e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802b21:	99                   	cltd   
  802b22:	c1 ea 1b             	shr    $0x1b,%edx
  802b25:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802b28:	83 e1 1f             	and    $0x1f,%ecx
  802b2b:	29 d1                	sub    %edx,%ecx
  802b2d:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  802b31:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  802b35:	83 c0 01             	add    $0x1,%eax
  802b38:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802b3b:	83 c7 01             	add    $0x1,%edi
  802b3e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802b41:	75 c8                	jne    802b0b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802b43:	89 f8                	mov    %edi,%eax
  802b45:	eb 05                	jmp    802b4c <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802b47:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802b4c:	83 c4 1c             	add    $0x1c,%esp
  802b4f:	5b                   	pop    %ebx
  802b50:	5e                   	pop    %esi
  802b51:	5f                   	pop    %edi
  802b52:	5d                   	pop    %ebp
  802b53:	c3                   	ret    

00802b54 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802b54:	55                   	push   %ebp
  802b55:	89 e5                	mov    %esp,%ebp
  802b57:	57                   	push   %edi
  802b58:	56                   	push   %esi
  802b59:	53                   	push   %ebx
  802b5a:	83 ec 1c             	sub    $0x1c,%esp
  802b5d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802b60:	89 3c 24             	mov    %edi,(%esp)
  802b63:	e8 08 f1 ff ff       	call   801c70 <fd2data>
  802b68:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802b6a:	be 00 00 00 00       	mov    $0x0,%esi
  802b6f:	eb 3d                	jmp    802bae <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802b71:	85 f6                	test   %esi,%esi
  802b73:	74 04                	je     802b79 <devpipe_read+0x25>
				return i;
  802b75:	89 f0                	mov    %esi,%eax
  802b77:	eb 43                	jmp    802bbc <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802b79:	89 da                	mov    %ebx,%edx
  802b7b:	89 f8                	mov    %edi,%eax
  802b7d:	e8 f1 fe ff ff       	call   802a73 <_pipeisclosed>
  802b82:	85 c0                	test   %eax,%eax
  802b84:	75 31                	jne    802bb7 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802b86:	e8 59 e9 ff ff       	call   8014e4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802b8b:	8b 03                	mov    (%ebx),%eax
  802b8d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802b90:	74 df                	je     802b71 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802b92:	99                   	cltd   
  802b93:	c1 ea 1b             	shr    $0x1b,%edx
  802b96:	01 d0                	add    %edx,%eax
  802b98:	83 e0 1f             	and    $0x1f,%eax
  802b9b:	29 d0                	sub    %edx,%eax
  802b9d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802ba2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802ba5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802ba8:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802bab:	83 c6 01             	add    $0x1,%esi
  802bae:	3b 75 10             	cmp    0x10(%ebp),%esi
  802bb1:	75 d8                	jne    802b8b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802bb3:	89 f0                	mov    %esi,%eax
  802bb5:	eb 05                	jmp    802bbc <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802bb7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802bbc:	83 c4 1c             	add    $0x1c,%esp
  802bbf:	5b                   	pop    %ebx
  802bc0:	5e                   	pop    %esi
  802bc1:	5f                   	pop    %edi
  802bc2:	5d                   	pop    %ebp
  802bc3:	c3                   	ret    

00802bc4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802bc4:	55                   	push   %ebp
  802bc5:	89 e5                	mov    %esp,%ebp
  802bc7:	56                   	push   %esi
  802bc8:	53                   	push   %ebx
  802bc9:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802bcc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802bcf:	89 04 24             	mov    %eax,(%esp)
  802bd2:	e8 b0 f0 ff ff       	call   801c87 <fd_alloc>
  802bd7:	89 c2                	mov    %eax,%edx
  802bd9:	85 d2                	test   %edx,%edx
  802bdb:	0f 88 4d 01 00 00    	js     802d2e <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802be1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802be8:	00 
  802be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802bec:	89 44 24 04          	mov    %eax,0x4(%esp)
  802bf0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802bf7:	e8 07 e9 ff ff       	call   801503 <sys_page_alloc>
  802bfc:	89 c2                	mov    %eax,%edx
  802bfe:	85 d2                	test   %edx,%edx
  802c00:	0f 88 28 01 00 00    	js     802d2e <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802c06:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c09:	89 04 24             	mov    %eax,(%esp)
  802c0c:	e8 76 f0 ff ff       	call   801c87 <fd_alloc>
  802c11:	89 c3                	mov    %eax,%ebx
  802c13:	85 c0                	test   %eax,%eax
  802c15:	0f 88 fe 00 00 00    	js     802d19 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802c1b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802c22:	00 
  802c23:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c26:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c2a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802c31:	e8 cd e8 ff ff       	call   801503 <sys_page_alloc>
  802c36:	89 c3                	mov    %eax,%ebx
  802c38:	85 c0                	test   %eax,%eax
  802c3a:	0f 88 d9 00 00 00    	js     802d19 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802c40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c43:	89 04 24             	mov    %eax,(%esp)
  802c46:	e8 25 f0 ff ff       	call   801c70 <fd2data>
  802c4b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802c4d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802c54:	00 
  802c55:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c59:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802c60:	e8 9e e8 ff ff       	call   801503 <sys_page_alloc>
  802c65:	89 c3                	mov    %eax,%ebx
  802c67:	85 c0                	test   %eax,%eax
  802c69:	0f 88 97 00 00 00    	js     802d06 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802c6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c72:	89 04 24             	mov    %eax,(%esp)
  802c75:	e8 f6 ef ff ff       	call   801c70 <fd2data>
  802c7a:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802c81:	00 
  802c82:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802c86:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802c8d:	00 
  802c8e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802c92:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802c99:	e8 b9 e8 ff ff       	call   801557 <sys_page_map>
  802c9e:	89 c3                	mov    %eax,%ebx
  802ca0:	85 c0                	test   %eax,%eax
  802ca2:	78 52                	js     802cf6 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802ca4:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802caa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cad:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cb2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802cb9:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802cbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cc2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802cc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cc7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cd1:	89 04 24             	mov    %eax,(%esp)
  802cd4:	e8 87 ef ff ff       	call   801c60 <fd2num>
  802cd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802cdc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802cde:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ce1:	89 04 24             	mov    %eax,(%esp)
  802ce4:	e8 77 ef ff ff       	call   801c60 <fd2num>
  802ce9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802cec:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802cef:	b8 00 00 00 00       	mov    $0x0,%eax
  802cf4:	eb 38                	jmp    802d2e <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  802cf6:	89 74 24 04          	mov    %esi,0x4(%esp)
  802cfa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802d01:	e8 a4 e8 ff ff       	call   8015aa <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802d06:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d09:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d0d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802d14:	e8 91 e8 ff ff       	call   8015aa <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d20:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802d27:	e8 7e e8 ff ff       	call   8015aa <sys_page_unmap>
  802d2c:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  802d2e:	83 c4 30             	add    $0x30,%esp
  802d31:	5b                   	pop    %ebx
  802d32:	5e                   	pop    %esi
  802d33:	5d                   	pop    %ebp
  802d34:	c3                   	ret    

00802d35 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802d35:	55                   	push   %ebp
  802d36:	89 e5                	mov    %esp,%ebp
  802d38:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802d3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d42:	8b 45 08             	mov    0x8(%ebp),%eax
  802d45:	89 04 24             	mov    %eax,(%esp)
  802d48:	e8 89 ef ff ff       	call   801cd6 <fd_lookup>
  802d4d:	89 c2                	mov    %eax,%edx
  802d4f:	85 d2                	test   %edx,%edx
  802d51:	78 15                	js     802d68 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d56:	89 04 24             	mov    %eax,(%esp)
  802d59:	e8 12 ef ff ff       	call   801c70 <fd2data>
	return _pipeisclosed(fd, p);
  802d5e:	89 c2                	mov    %eax,%edx
  802d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d63:	e8 0b fd ff ff       	call   802a73 <_pipeisclosed>
}
  802d68:	c9                   	leave  
  802d69:	c3                   	ret    
  802d6a:	66 90                	xchg   %ax,%ax
  802d6c:	66 90                	xchg   %ax,%ax
  802d6e:	66 90                	xchg   %ax,%ax

00802d70 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802d70:	55                   	push   %ebp
  802d71:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802d73:	b8 00 00 00 00       	mov    $0x0,%eax
  802d78:	5d                   	pop    %ebp
  802d79:	c3                   	ret    

00802d7a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802d7a:	55                   	push   %ebp
  802d7b:	89 e5                	mov    %esp,%ebp
  802d7d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802d80:	c7 44 24 04 1f 39 80 	movl   $0x80391f,0x4(%esp)
  802d87:	00 
  802d88:	8b 45 0c             	mov    0xc(%ebp),%eax
  802d8b:	89 04 24             	mov    %eax,(%esp)
  802d8e:	e8 54 e3 ff ff       	call   8010e7 <strcpy>
	return 0;
}
  802d93:	b8 00 00 00 00       	mov    $0x0,%eax
  802d98:	c9                   	leave  
  802d99:	c3                   	ret    

00802d9a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802d9a:	55                   	push   %ebp
  802d9b:	89 e5                	mov    %esp,%ebp
  802d9d:	57                   	push   %edi
  802d9e:	56                   	push   %esi
  802d9f:	53                   	push   %ebx
  802da0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802da6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802dab:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802db1:	eb 31                	jmp    802de4 <devcons_write+0x4a>
		m = n - tot;
  802db3:	8b 75 10             	mov    0x10(%ebp),%esi
  802db6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802db8:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802dbb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802dc0:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802dc3:	89 74 24 08          	mov    %esi,0x8(%esp)
  802dc7:	03 45 0c             	add    0xc(%ebp),%eax
  802dca:	89 44 24 04          	mov    %eax,0x4(%esp)
  802dce:	89 3c 24             	mov    %edi,(%esp)
  802dd1:	e8 ae e4 ff ff       	call   801284 <memmove>
		sys_cputs(buf, m);
  802dd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  802dda:	89 3c 24             	mov    %edi,(%esp)
  802ddd:	e8 54 e6 ff ff       	call   801436 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802de2:	01 f3                	add    %esi,%ebx
  802de4:	89 d8                	mov    %ebx,%eax
  802de6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802de9:	72 c8                	jb     802db3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802deb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802df1:	5b                   	pop    %ebx
  802df2:	5e                   	pop    %esi
  802df3:	5f                   	pop    %edi
  802df4:	5d                   	pop    %ebp
  802df5:	c3                   	ret    

00802df6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802df6:	55                   	push   %ebp
  802df7:	89 e5                	mov    %esp,%ebp
  802df9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  802dfc:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802e01:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802e05:	75 07                	jne    802e0e <devcons_read+0x18>
  802e07:	eb 2a                	jmp    802e33 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802e09:	e8 d6 e6 ff ff       	call   8014e4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802e0e:	66 90                	xchg   %ax,%ax
  802e10:	e8 3f e6 ff ff       	call   801454 <sys_cgetc>
  802e15:	85 c0                	test   %eax,%eax
  802e17:	74 f0                	je     802e09 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802e19:	85 c0                	test   %eax,%eax
  802e1b:	78 16                	js     802e33 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802e1d:	83 f8 04             	cmp    $0x4,%eax
  802e20:	74 0c                	je     802e2e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802e22:	8b 55 0c             	mov    0xc(%ebp),%edx
  802e25:	88 02                	mov    %al,(%edx)
	return 1;
  802e27:	b8 01 00 00 00       	mov    $0x1,%eax
  802e2c:	eb 05                	jmp    802e33 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802e2e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802e33:	c9                   	leave  
  802e34:	c3                   	ret    

00802e35 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802e35:	55                   	push   %ebp
  802e36:	89 e5                	mov    %esp,%ebp
  802e38:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802e3b:	8b 45 08             	mov    0x8(%ebp),%eax
  802e3e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802e41:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802e48:	00 
  802e49:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802e4c:	89 04 24             	mov    %eax,(%esp)
  802e4f:	e8 e2 e5 ff ff       	call   801436 <sys_cputs>
}
  802e54:	c9                   	leave  
  802e55:	c3                   	ret    

00802e56 <getchar>:

int
getchar(void)
{
  802e56:	55                   	push   %ebp
  802e57:	89 e5                	mov    %esp,%ebp
  802e59:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802e5c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802e63:	00 
  802e64:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802e67:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e6b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802e72:	e8 f3 f0 ff ff       	call   801f6a <read>
	if (r < 0)
  802e77:	85 c0                	test   %eax,%eax
  802e79:	78 0f                	js     802e8a <getchar+0x34>
		return r;
	if (r < 1)
  802e7b:	85 c0                	test   %eax,%eax
  802e7d:	7e 06                	jle    802e85 <getchar+0x2f>
		return -E_EOF;
	return c;
  802e7f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802e83:	eb 05                	jmp    802e8a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802e85:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802e8a:	c9                   	leave  
  802e8b:	c3                   	ret    

00802e8c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802e8c:	55                   	push   %ebp
  802e8d:	89 e5                	mov    %esp,%ebp
  802e8f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802e92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e95:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e99:	8b 45 08             	mov    0x8(%ebp),%eax
  802e9c:	89 04 24             	mov    %eax,(%esp)
  802e9f:	e8 32 ee ff ff       	call   801cd6 <fd_lookup>
  802ea4:	85 c0                	test   %eax,%eax
  802ea6:	78 11                	js     802eb9 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802eab:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802eb1:	39 10                	cmp    %edx,(%eax)
  802eb3:	0f 94 c0             	sete   %al
  802eb6:	0f b6 c0             	movzbl %al,%eax
}
  802eb9:	c9                   	leave  
  802eba:	c3                   	ret    

00802ebb <opencons>:

int
opencons(void)
{
  802ebb:	55                   	push   %ebp
  802ebc:	89 e5                	mov    %esp,%ebp
  802ebe:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802ec1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ec4:	89 04 24             	mov    %eax,(%esp)
  802ec7:	e8 bb ed ff ff       	call   801c87 <fd_alloc>
		return r;
  802ecc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802ece:	85 c0                	test   %eax,%eax
  802ed0:	78 40                	js     802f12 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802ed2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802ed9:	00 
  802eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802edd:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ee1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ee8:	e8 16 e6 ff ff       	call   801503 <sys_page_alloc>
		return r;
  802eed:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802eef:	85 c0                	test   %eax,%eax
  802ef1:	78 1f                	js     802f12 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802ef3:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802efc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f01:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802f08:	89 04 24             	mov    %eax,(%esp)
  802f0b:	e8 50 ed ff ff       	call   801c60 <fd2num>
  802f10:	89 c2                	mov    %eax,%edx
}
  802f12:	89 d0                	mov    %edx,%eax
  802f14:	c9                   	leave  
  802f15:	c3                   	ret    

00802f16 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802f16:	55                   	push   %ebp
  802f17:	89 e5                	mov    %esp,%ebp
  802f19:	53                   	push   %ebx
  802f1a:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  802f1d:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802f24:	75 2f                	jne    802f55 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  802f26:	e8 9a e5 ff ff       	call   8014c5 <sys_getenvid>
  802f2b:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P);
  802f2d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802f34:	00 
  802f35:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802f3c:	ee 
  802f3d:	89 04 24             	mov    %eax,(%esp)
  802f40:	e8 be e5 ff ff       	call   801503 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *)_pgfault_upcall);
  802f45:	c7 44 24 04 63 2f 80 	movl   $0x802f63,0x4(%esp)
  802f4c:	00 
  802f4d:	89 1c 24             	mov    %ebx,(%esp)
  802f50:	e8 4e e7 ff ff       	call   8016a3 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802f55:	8b 45 08             	mov    0x8(%ebp),%eax
  802f58:	a3 00 80 80 00       	mov    %eax,0x808000
}
  802f5d:	83 c4 14             	add    $0x14,%esp
  802f60:	5b                   	pop    %ebx
  802f61:	5d                   	pop    %ebp
  802f62:	c3                   	ret    

00802f63 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802f63:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802f64:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802f69:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802f6b:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	// 0x30(%esp) points to trap-time stack pointer
	// 0x28(%esp) points to trap-time eip
	subl $4, 0x30(%esp)
  802f6e:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax 
  802f73:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebp
  802f77:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %ebp, (%eax)
  802f7b:	89 28                	mov    %ebp,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  802f7d:	83 c4 08             	add    $0x8,%esp
	popal
  802f80:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp //pop eip - we already stored it
  802f81:	83 c4 04             	add    $0x4,%esp
	popfl
  802f84:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802f85:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802f86:	c3                   	ret    

00802f87 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802f87:	55                   	push   %ebp
  802f88:	89 e5                	mov    %esp,%ebp
  802f8a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802f8d:	89 d0                	mov    %edx,%eax
  802f8f:	c1 e8 16             	shr    $0x16,%eax
  802f92:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802f99:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802f9e:	f6 c1 01             	test   $0x1,%cl
  802fa1:	74 1d                	je     802fc0 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802fa3:	c1 ea 0c             	shr    $0xc,%edx
  802fa6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802fad:	f6 c2 01             	test   $0x1,%dl
  802fb0:	74 0e                	je     802fc0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802fb2:	c1 ea 0c             	shr    $0xc,%edx
  802fb5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802fbc:	ef 
  802fbd:	0f b7 c0             	movzwl %ax,%eax
}
  802fc0:	5d                   	pop    %ebp
  802fc1:	c3                   	ret    
  802fc2:	66 90                	xchg   %ax,%ax
  802fc4:	66 90                	xchg   %ax,%ax
  802fc6:	66 90                	xchg   %ax,%ax
  802fc8:	66 90                	xchg   %ax,%ax
  802fca:	66 90                	xchg   %ax,%ax
  802fcc:	66 90                	xchg   %ax,%ax
  802fce:	66 90                	xchg   %ax,%ax

00802fd0 <__udivdi3>:
  802fd0:	55                   	push   %ebp
  802fd1:	57                   	push   %edi
  802fd2:	56                   	push   %esi
  802fd3:	83 ec 0c             	sub    $0xc,%esp
  802fd6:	8b 44 24 28          	mov    0x28(%esp),%eax
  802fda:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  802fde:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802fe2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802fe6:	85 c0                	test   %eax,%eax
  802fe8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802fec:	89 ea                	mov    %ebp,%edx
  802fee:	89 0c 24             	mov    %ecx,(%esp)
  802ff1:	75 2d                	jne    803020 <__udivdi3+0x50>
  802ff3:	39 e9                	cmp    %ebp,%ecx
  802ff5:	77 61                	ja     803058 <__udivdi3+0x88>
  802ff7:	85 c9                	test   %ecx,%ecx
  802ff9:	89 ce                	mov    %ecx,%esi
  802ffb:	75 0b                	jne    803008 <__udivdi3+0x38>
  802ffd:	b8 01 00 00 00       	mov    $0x1,%eax
  803002:	31 d2                	xor    %edx,%edx
  803004:	f7 f1                	div    %ecx
  803006:	89 c6                	mov    %eax,%esi
  803008:	31 d2                	xor    %edx,%edx
  80300a:	89 e8                	mov    %ebp,%eax
  80300c:	f7 f6                	div    %esi
  80300e:	89 c5                	mov    %eax,%ebp
  803010:	89 f8                	mov    %edi,%eax
  803012:	f7 f6                	div    %esi
  803014:	89 ea                	mov    %ebp,%edx
  803016:	83 c4 0c             	add    $0xc,%esp
  803019:	5e                   	pop    %esi
  80301a:	5f                   	pop    %edi
  80301b:	5d                   	pop    %ebp
  80301c:	c3                   	ret    
  80301d:	8d 76 00             	lea    0x0(%esi),%esi
  803020:	39 e8                	cmp    %ebp,%eax
  803022:	77 24                	ja     803048 <__udivdi3+0x78>
  803024:	0f bd e8             	bsr    %eax,%ebp
  803027:	83 f5 1f             	xor    $0x1f,%ebp
  80302a:	75 3c                	jne    803068 <__udivdi3+0x98>
  80302c:	8b 74 24 04          	mov    0x4(%esp),%esi
  803030:	39 34 24             	cmp    %esi,(%esp)
  803033:	0f 86 9f 00 00 00    	jbe    8030d8 <__udivdi3+0x108>
  803039:	39 d0                	cmp    %edx,%eax
  80303b:	0f 82 97 00 00 00    	jb     8030d8 <__udivdi3+0x108>
  803041:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803048:	31 d2                	xor    %edx,%edx
  80304a:	31 c0                	xor    %eax,%eax
  80304c:	83 c4 0c             	add    $0xc,%esp
  80304f:	5e                   	pop    %esi
  803050:	5f                   	pop    %edi
  803051:	5d                   	pop    %ebp
  803052:	c3                   	ret    
  803053:	90                   	nop
  803054:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803058:	89 f8                	mov    %edi,%eax
  80305a:	f7 f1                	div    %ecx
  80305c:	31 d2                	xor    %edx,%edx
  80305e:	83 c4 0c             	add    $0xc,%esp
  803061:	5e                   	pop    %esi
  803062:	5f                   	pop    %edi
  803063:	5d                   	pop    %ebp
  803064:	c3                   	ret    
  803065:	8d 76 00             	lea    0x0(%esi),%esi
  803068:	89 e9                	mov    %ebp,%ecx
  80306a:	8b 3c 24             	mov    (%esp),%edi
  80306d:	d3 e0                	shl    %cl,%eax
  80306f:	89 c6                	mov    %eax,%esi
  803071:	b8 20 00 00 00       	mov    $0x20,%eax
  803076:	29 e8                	sub    %ebp,%eax
  803078:	89 c1                	mov    %eax,%ecx
  80307a:	d3 ef                	shr    %cl,%edi
  80307c:	89 e9                	mov    %ebp,%ecx
  80307e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  803082:	8b 3c 24             	mov    (%esp),%edi
  803085:	09 74 24 08          	or     %esi,0x8(%esp)
  803089:	89 d6                	mov    %edx,%esi
  80308b:	d3 e7                	shl    %cl,%edi
  80308d:	89 c1                	mov    %eax,%ecx
  80308f:	89 3c 24             	mov    %edi,(%esp)
  803092:	8b 7c 24 04          	mov    0x4(%esp),%edi
  803096:	d3 ee                	shr    %cl,%esi
  803098:	89 e9                	mov    %ebp,%ecx
  80309a:	d3 e2                	shl    %cl,%edx
  80309c:	89 c1                	mov    %eax,%ecx
  80309e:	d3 ef                	shr    %cl,%edi
  8030a0:	09 d7                	or     %edx,%edi
  8030a2:	89 f2                	mov    %esi,%edx
  8030a4:	89 f8                	mov    %edi,%eax
  8030a6:	f7 74 24 08          	divl   0x8(%esp)
  8030aa:	89 d6                	mov    %edx,%esi
  8030ac:	89 c7                	mov    %eax,%edi
  8030ae:	f7 24 24             	mull   (%esp)
  8030b1:	39 d6                	cmp    %edx,%esi
  8030b3:	89 14 24             	mov    %edx,(%esp)
  8030b6:	72 30                	jb     8030e8 <__udivdi3+0x118>
  8030b8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8030bc:	89 e9                	mov    %ebp,%ecx
  8030be:	d3 e2                	shl    %cl,%edx
  8030c0:	39 c2                	cmp    %eax,%edx
  8030c2:	73 05                	jae    8030c9 <__udivdi3+0xf9>
  8030c4:	3b 34 24             	cmp    (%esp),%esi
  8030c7:	74 1f                	je     8030e8 <__udivdi3+0x118>
  8030c9:	89 f8                	mov    %edi,%eax
  8030cb:	31 d2                	xor    %edx,%edx
  8030cd:	e9 7a ff ff ff       	jmp    80304c <__udivdi3+0x7c>
  8030d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8030d8:	31 d2                	xor    %edx,%edx
  8030da:	b8 01 00 00 00       	mov    $0x1,%eax
  8030df:	e9 68 ff ff ff       	jmp    80304c <__udivdi3+0x7c>
  8030e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8030e8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8030eb:	31 d2                	xor    %edx,%edx
  8030ed:	83 c4 0c             	add    $0xc,%esp
  8030f0:	5e                   	pop    %esi
  8030f1:	5f                   	pop    %edi
  8030f2:	5d                   	pop    %ebp
  8030f3:	c3                   	ret    
  8030f4:	66 90                	xchg   %ax,%ax
  8030f6:	66 90                	xchg   %ax,%ax
  8030f8:	66 90                	xchg   %ax,%ax
  8030fa:	66 90                	xchg   %ax,%ax
  8030fc:	66 90                	xchg   %ax,%ax
  8030fe:	66 90                	xchg   %ax,%ax

00803100 <__umoddi3>:
  803100:	55                   	push   %ebp
  803101:	57                   	push   %edi
  803102:	56                   	push   %esi
  803103:	83 ec 14             	sub    $0x14,%esp
  803106:	8b 44 24 28          	mov    0x28(%esp),%eax
  80310a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80310e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  803112:	89 c7                	mov    %eax,%edi
  803114:	89 44 24 04          	mov    %eax,0x4(%esp)
  803118:	8b 44 24 30          	mov    0x30(%esp),%eax
  80311c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  803120:	89 34 24             	mov    %esi,(%esp)
  803123:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803127:	85 c0                	test   %eax,%eax
  803129:	89 c2                	mov    %eax,%edx
  80312b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80312f:	75 17                	jne    803148 <__umoddi3+0x48>
  803131:	39 fe                	cmp    %edi,%esi
  803133:	76 4b                	jbe    803180 <__umoddi3+0x80>
  803135:	89 c8                	mov    %ecx,%eax
  803137:	89 fa                	mov    %edi,%edx
  803139:	f7 f6                	div    %esi
  80313b:	89 d0                	mov    %edx,%eax
  80313d:	31 d2                	xor    %edx,%edx
  80313f:	83 c4 14             	add    $0x14,%esp
  803142:	5e                   	pop    %esi
  803143:	5f                   	pop    %edi
  803144:	5d                   	pop    %ebp
  803145:	c3                   	ret    
  803146:	66 90                	xchg   %ax,%ax
  803148:	39 f8                	cmp    %edi,%eax
  80314a:	77 54                	ja     8031a0 <__umoddi3+0xa0>
  80314c:	0f bd e8             	bsr    %eax,%ebp
  80314f:	83 f5 1f             	xor    $0x1f,%ebp
  803152:	75 5c                	jne    8031b0 <__umoddi3+0xb0>
  803154:	8b 7c 24 08          	mov    0x8(%esp),%edi
  803158:	39 3c 24             	cmp    %edi,(%esp)
  80315b:	0f 87 e7 00 00 00    	ja     803248 <__umoddi3+0x148>
  803161:	8b 7c 24 04          	mov    0x4(%esp),%edi
  803165:	29 f1                	sub    %esi,%ecx
  803167:	19 c7                	sbb    %eax,%edi
  803169:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80316d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  803171:	8b 44 24 08          	mov    0x8(%esp),%eax
  803175:	8b 54 24 0c          	mov    0xc(%esp),%edx
  803179:	83 c4 14             	add    $0x14,%esp
  80317c:	5e                   	pop    %esi
  80317d:	5f                   	pop    %edi
  80317e:	5d                   	pop    %ebp
  80317f:	c3                   	ret    
  803180:	85 f6                	test   %esi,%esi
  803182:	89 f5                	mov    %esi,%ebp
  803184:	75 0b                	jne    803191 <__umoddi3+0x91>
  803186:	b8 01 00 00 00       	mov    $0x1,%eax
  80318b:	31 d2                	xor    %edx,%edx
  80318d:	f7 f6                	div    %esi
  80318f:	89 c5                	mov    %eax,%ebp
  803191:	8b 44 24 04          	mov    0x4(%esp),%eax
  803195:	31 d2                	xor    %edx,%edx
  803197:	f7 f5                	div    %ebp
  803199:	89 c8                	mov    %ecx,%eax
  80319b:	f7 f5                	div    %ebp
  80319d:	eb 9c                	jmp    80313b <__umoddi3+0x3b>
  80319f:	90                   	nop
  8031a0:	89 c8                	mov    %ecx,%eax
  8031a2:	89 fa                	mov    %edi,%edx
  8031a4:	83 c4 14             	add    $0x14,%esp
  8031a7:	5e                   	pop    %esi
  8031a8:	5f                   	pop    %edi
  8031a9:	5d                   	pop    %ebp
  8031aa:	c3                   	ret    
  8031ab:	90                   	nop
  8031ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8031b0:	8b 04 24             	mov    (%esp),%eax
  8031b3:	be 20 00 00 00       	mov    $0x20,%esi
  8031b8:	89 e9                	mov    %ebp,%ecx
  8031ba:	29 ee                	sub    %ebp,%esi
  8031bc:	d3 e2                	shl    %cl,%edx
  8031be:	89 f1                	mov    %esi,%ecx
  8031c0:	d3 e8                	shr    %cl,%eax
  8031c2:	89 e9                	mov    %ebp,%ecx
  8031c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031c8:	8b 04 24             	mov    (%esp),%eax
  8031cb:	09 54 24 04          	or     %edx,0x4(%esp)
  8031cf:	89 fa                	mov    %edi,%edx
  8031d1:	d3 e0                	shl    %cl,%eax
  8031d3:	89 f1                	mov    %esi,%ecx
  8031d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8031d9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8031dd:	d3 ea                	shr    %cl,%edx
  8031df:	89 e9                	mov    %ebp,%ecx
  8031e1:	d3 e7                	shl    %cl,%edi
  8031e3:	89 f1                	mov    %esi,%ecx
  8031e5:	d3 e8                	shr    %cl,%eax
  8031e7:	89 e9                	mov    %ebp,%ecx
  8031e9:	09 f8                	or     %edi,%eax
  8031eb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8031ef:	f7 74 24 04          	divl   0x4(%esp)
  8031f3:	d3 e7                	shl    %cl,%edi
  8031f5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8031f9:	89 d7                	mov    %edx,%edi
  8031fb:	f7 64 24 08          	mull   0x8(%esp)
  8031ff:	39 d7                	cmp    %edx,%edi
  803201:	89 c1                	mov    %eax,%ecx
  803203:	89 14 24             	mov    %edx,(%esp)
  803206:	72 2c                	jb     803234 <__umoddi3+0x134>
  803208:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80320c:	72 22                	jb     803230 <__umoddi3+0x130>
  80320e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803212:	29 c8                	sub    %ecx,%eax
  803214:	19 d7                	sbb    %edx,%edi
  803216:	89 e9                	mov    %ebp,%ecx
  803218:	89 fa                	mov    %edi,%edx
  80321a:	d3 e8                	shr    %cl,%eax
  80321c:	89 f1                	mov    %esi,%ecx
  80321e:	d3 e2                	shl    %cl,%edx
  803220:	89 e9                	mov    %ebp,%ecx
  803222:	d3 ef                	shr    %cl,%edi
  803224:	09 d0                	or     %edx,%eax
  803226:	89 fa                	mov    %edi,%edx
  803228:	83 c4 14             	add    $0x14,%esp
  80322b:	5e                   	pop    %esi
  80322c:	5f                   	pop    %edi
  80322d:	5d                   	pop    %ebp
  80322e:	c3                   	ret    
  80322f:	90                   	nop
  803230:	39 d7                	cmp    %edx,%edi
  803232:	75 da                	jne    80320e <__umoddi3+0x10e>
  803234:	8b 14 24             	mov    (%esp),%edx
  803237:	89 c1                	mov    %eax,%ecx
  803239:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80323d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  803241:	eb cb                	jmp    80320e <__umoddi3+0x10e>
  803243:	90                   	nop
  803244:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803248:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80324c:	0f 82 0f ff ff ff    	jb     803161 <__umoddi3+0x61>
  803252:	e9 1a ff ff ff       	jmp    803171 <__umoddi3+0x71>
