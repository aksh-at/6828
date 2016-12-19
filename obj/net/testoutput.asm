
obj/net/testoutput:     file format elf32-i386


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
  80002c:	e8 14 03 00 00       	call   800345 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
static struct jif_pkt *pkt = (struct jif_pkt*)REQVA;


void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t ns_envid = sys_getenvid();
  80003b:	e8 65 0e 00 00       	call   800ea5 <sys_getenvid>
  800040:	89 c6                	mov    %eax,%esi
	int i, r;

	binaryname = "testoutput";
  800042:	c7 05 00 40 80 00 40 	movl   $0x802c40,0x804000
  800049:	2c 80 00 

	output_envid = fork();
  80004c:	e8 c3 12 00 00       	call   801314 <fork>
  800051:	a3 00 50 80 00       	mov    %eax,0x805000
	if (output_envid < 0)
  800056:	85 c0                	test   %eax,%eax
  800058:	79 1c                	jns    800076 <umain+0x43>
		panic("error forking");
  80005a:	c7 44 24 08 4b 2c 80 	movl   $0x802c4b,0x8(%esp)
  800061:	00 
  800062:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  800069:	00 
  80006a:	c7 04 24 59 2c 80 00 	movl   $0x802c59,(%esp)
  800071:	e8 30 03 00 00       	call   8003a6 <_panic>
	else if (output_envid == 0) {
  800076:	bb 00 00 00 00       	mov    $0x0,%ebx
  80007b:	85 c0                	test   %eax,%eax
  80007d:	75 0d                	jne    80008c <umain+0x59>
		output(ns_envid);
  80007f:	89 34 24             	mov    %esi,(%esp)
  800082:	e8 49 02 00 00       	call   8002d0 <output>
		return;
  800087:	e9 c6 00 00 00       	jmp    800152 <umain+0x11f>
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
		if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  80008c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  80009b:	0f 
  80009c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a3:	e8 3b 0e 00 00       	call   800ee3 <sys_page_alloc>
  8000a8:	85 c0                	test   %eax,%eax
  8000aa:	79 20                	jns    8000cc <umain+0x99>
			panic("sys_page_alloc: %e", r);
  8000ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b0:	c7 44 24 08 6a 2c 80 	movl   $0x802c6a,0x8(%esp)
  8000b7:	00 
  8000b8:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8000bf:	00 
  8000c0:	c7 04 24 59 2c 80 00 	movl   $0x802c59,(%esp)
  8000c7:	e8 da 02 00 00       	call   8003a6 <_panic>
		pkt->jp_len = snprintf(pkt->jp_data,
  8000cc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000d0:	c7 44 24 08 7d 2c 80 	movl   $0x802c7d,0x8(%esp)
  8000d7:	00 
  8000d8:	c7 44 24 04 fc 0f 00 	movl   $0xffc,0x4(%esp)
  8000df:	00 
  8000e0:	c7 04 24 04 b0 fe 0f 	movl   $0xffeb004,(%esp)
  8000e7:	e8 6e 09 00 00       	call   800a5a <snprintf>
  8000ec:	a3 00 b0 fe 0f       	mov    %eax,0xffeb000
				       PGSIZE - sizeof(pkt->jp_len),
				       "Packet %02d", i);
		cprintf("Transmitting packet %d\n", i);
  8000f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000f5:	c7 04 24 89 2c 80 00 	movl   $0x802c89,(%esp)
  8000fc:	e8 9e 03 00 00       	call   80049f <cprintf>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  800101:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800108:	00 
  800109:	c7 44 24 08 00 b0 fe 	movl   $0xffeb000,0x8(%esp)
  800110:	0f 
  800111:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
  800118:	00 
  800119:	a1 00 50 80 00       	mov    0x805000,%eax
  80011e:	89 04 24             	mov    %eax,(%esp)
  800121:	e8 74 14 00 00       	call   80159a <ipc_send>
		sys_page_unmap(0, pkt);
  800126:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  80012d:	0f 
  80012e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800135:	e8 50 0e 00 00       	call   800f8a <sys_page_unmap>
	else if (output_envid == 0) {
		output(ns_envid);
		return;
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
  80013a:	83 c3 01             	add    $0x1,%ebx
  80013d:	83 fb 0a             	cmp    $0xa,%ebx
  800140:	0f 85 46 ff ff ff    	jne    80008c <umain+0x59>
  800146:	b3 14                	mov    $0x14,%bl
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
		sys_yield();
  800148:	e8 77 0d 00 00       	call   800ec4 <sys_yield>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
  80014d:	83 eb 01             	sub    $0x1,%ebx
  800150:	75 f6                	jne    800148 <umain+0x115>
		sys_yield();
}
  800152:	83 c4 10             	add    $0x10,%esp
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5d                   	pop    %ebp
  800158:	c3                   	ret    
  800159:	66 90                	xchg   %ax,%ax
  80015b:	66 90                	xchg   %ax,%ax
  80015d:	66 90                	xchg   %ax,%ax
  80015f:	90                   	nop

00800160 <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	57                   	push   %edi
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	83 ec 2c             	sub    $0x2c,%esp
  800169:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  80016c:	e8 da 0f 00 00       	call   80114b <sys_time_msec>
  800171:	03 45 0c             	add    0xc(%ebp),%eax
  800174:	89 c6                	mov    %eax,%esi

	binaryname = "ns_timer";
  800176:	c7 05 00 40 80 00 a1 	movl   $0x802ca1,0x804000
  80017d:	2c 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  800180:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800183:	eb 05                	jmp    80018a <timer+0x2a>

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
			sys_yield();
  800185:	e8 3a 0d 00 00       	call   800ec4 <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
  80018a:	e8 bc 0f 00 00       	call   80114b <sys_time_msec>
  80018f:	39 c6                	cmp    %eax,%esi
  800191:	76 06                	jbe    800199 <timer+0x39>
  800193:	85 c0                	test   %eax,%eax
  800195:	79 ee                	jns    800185 <timer+0x25>
  800197:	eb 09                	jmp    8001a2 <timer+0x42>
			sys_yield();
		}
		if (r < 0)
  800199:	85 c0                	test   %eax,%eax
  80019b:	90                   	nop
  80019c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8001a0:	79 20                	jns    8001c2 <timer+0x62>
			panic("sys_time_msec: %e", r);
  8001a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a6:	c7 44 24 08 aa 2c 80 	movl   $0x802caa,0x8(%esp)
  8001ad:	00 
  8001ae:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8001b5:	00 
  8001b6:	c7 04 24 bc 2c 80 00 	movl   $0x802cbc,(%esp)
  8001bd:	e8 e4 01 00 00       	call   8003a6 <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  8001c2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001c9:	00 
  8001ca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001d1:	00 
  8001d2:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
  8001d9:	00 
  8001da:	89 1c 24             	mov    %ebx,(%esp)
  8001dd:	e8 b8 13 00 00       	call   80159a <ipc_send>

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8001e2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001e9:	00 
  8001ea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001f1:	00 
  8001f2:	89 3c 24             	mov    %edi,(%esp)
  8001f5:	e8 26 13 00 00       	call   801520 <ipc_recv>
  8001fa:	89 c6                	mov    %eax,%esi

			if (whom != ns_envid) {
  8001fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001ff:	39 c3                	cmp    %eax,%ebx
  800201:	74 12                	je     800215 <timer+0xb5>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  800203:	89 44 24 04          	mov    %eax,0x4(%esp)
  800207:	c7 04 24 c8 2c 80 00 	movl   $0x802cc8,(%esp)
  80020e:	e8 8c 02 00 00       	call   80049f <cprintf>
  800213:	eb cd                	jmp    8001e2 <timer+0x82>
				continue;
			}

			stop = sys_time_msec() + to;
  800215:	e8 31 0f 00 00       	call   80114b <sys_time_msec>
  80021a:	01 c6                	add    %eax,%esi
  80021c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800220:	e9 65 ff ff ff       	jmp    80018a <timer+0x2a>
  800225:	66 90                	xchg   %ax,%ax
  800227:	66 90                	xchg   %ax,%ax
  800229:	66 90                	xchg   %ax,%ax
  80022b:	66 90                	xchg   %ax,%ax
  80022d:	66 90                	xchg   %ax,%ax
  80022f:	90                   	nop

00800230 <input>:

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	57                   	push   %edi
  800234:	56                   	push   %esi
  800235:	53                   	push   %ebx
  800236:	83 ec 2c             	sub    $0x2c,%esp
  800239:	8b 7d 08             	mov    0x8(%ebp),%edi
	binaryname = "ns_input";
  80023c:	c7 05 00 40 80 00 03 	movl   $0x802d03,0x804000
  800243:	2d 80 00 
	while(true) {
		//sys_yield();
		//continue;

		while(true) {
			if(sys_try_recv_packet(&packet, &size) == 0)  break;
  800246:	8d 75 e0             	lea    -0x20(%ebp),%esi
  800249:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  80024c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800250:	89 1c 24             	mov    %ebx,(%esp)
  800253:	e8 65 0f 00 00       	call   8011bd <sys_try_recv_packet>
  800258:	85 c0                	test   %eax,%eax
  80025a:	74 07                	je     800263 <input+0x33>
			sys_yield();
  80025c:	e8 63 0c 00 00       	call   800ec4 <sys_yield>
		}
  800261:	eb e9                	jmp    80024c <input+0x1c>

		sys_page_alloc(0, &nsipcbuf, PTE_U|PTE_W|PTE_P);
  800263:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80026a:	00 
  80026b:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  800272:	00 
  800273:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80027a:	e8 64 0c 00 00       	call   800ee3 <sys_page_alloc>
		memcpy(nsipcbuf.pkt.jp_data, packet, size);
  80027f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800282:	89 44 24 08          	mov    %eax,0x8(%esp)
  800286:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800289:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028d:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  800294:	e8 33 0a 00 00       	call   800ccc <memcpy>
		nsipcbuf.pkt.jp_len = size;
  800299:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80029c:	a3 00 70 80 00       	mov    %eax,0x807000

		ipc_send(ns_envid, NSREQ_INPUT, &nsipcbuf, PTE_U|PTE_W|PTE_P);
  8002a1:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8002a8:	00 
  8002a9:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  8002b0:	00 
  8002b1:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  8002b8:	00 
  8002b9:	89 3c 24             	mov    %edi,(%esp)
  8002bc:	e8 d9 12 00 00       	call   80159a <ipc_send>
	}
  8002c1:	eb 89                	jmp    80024c <input+0x1c>
  8002c3:	66 90                	xchg   %ax,%ax
  8002c5:	66 90                	xchg   %ax,%ax
  8002c7:	66 90                	xchg   %ax,%ax
  8002c9:	66 90                	xchg   %ax,%ax
  8002cb:	66 90                	xchg   %ax,%ax
  8002cd:	66 90                	xchg   %ax,%ax
  8002cf:	90                   	nop

008002d0 <output>:

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	57                   	push   %edi
  8002d4:	56                   	push   %esi
  8002d5:	53                   	push   %ebx
  8002d6:	83 ec 2c             	sub    $0x2c,%esp
	binaryname = "ns_output";
  8002d9:	c7 05 00 40 80 00 0c 	movl   $0x802d0c,0x804000
  8002e0:	2d 80 00 
	envid_t srcenv;
	int perm;
	int i;

	while(true) {
		ipc_recv(&srcenv, &nsipcbuf, &perm);
  8002e3:	8d 7d e0             	lea    -0x20(%ebp),%edi
  8002e6:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8002e9:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8002ed:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8002f4:	00 
  8002f5:	89 34 24             	mov    %esi,(%esp)
  8002f8:	e8 23 12 00 00       	call   801520 <ipc_recv>

		if(srcenv != ns_envid) continue;
  8002fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800300:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800303:	75 e4                	jne    8002e9 <output+0x19>
  800305:	bb 00 00 00 00       	mov    $0x0,%ebx

		for(i = 0; i < 50; i++) {
			if(sys_try_send_packet(nsipcbuf.pkt.jp_data, nsipcbuf.pkt.jp_len) == 0) break;
  80030a:	a1 00 70 80 00       	mov    0x807000,%eax
  80030f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800313:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  80031a:	e8 4b 0e 00 00       	call   80116a <sys_try_send_packet>
  80031f:	85 c0                	test   %eax,%eax
  800321:	74 0f                	je     800332 <output+0x62>
			sys_yield();
  800323:	e8 9c 0b 00 00       	call   800ec4 <sys_yield>
	while(true) {
		ipc_recv(&srcenv, &nsipcbuf, &perm);

		if(srcenv != ns_envid) continue;

		for(i = 0; i < 50; i++) {
  800328:	83 c3 01             	add    $0x1,%ebx
  80032b:	83 fb 32             	cmp    $0x32,%ebx
  80032e:	75 da                	jne    80030a <output+0x3a>
  800330:	eb 05                	jmp    800337 <output+0x67>
			if(sys_try_send_packet(nsipcbuf.pkt.jp_data, nsipcbuf.pkt.jp_len) == 0) break;
			sys_yield();
		}

		if(i == 50) {
  800332:	83 fb 32             	cmp    $0x32,%ebx
  800335:	75 b2                	jne    8002e9 <output+0x19>
			cprintf("Packet failed to send after 50 tries\n");
  800337:	c7 04 24 18 2d 80 00 	movl   $0x802d18,(%esp)
  80033e:	e8 5c 01 00 00       	call   80049f <cprintf>
  800343:	eb a4                	jmp    8002e9 <output+0x19>

00800345 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	56                   	push   %esi
  800349:	53                   	push   %ebx
  80034a:	83 ec 10             	sub    $0x10,%esp
  80034d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800350:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  800353:	e8 4d 0b 00 00       	call   800ea5 <sys_getenvid>
  800358:	25 ff 03 00 00       	and    $0x3ff,%eax
  80035d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800360:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800365:	a3 0c 50 80 00       	mov    %eax,0x80500c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80036a:	85 db                	test   %ebx,%ebx
  80036c:	7e 07                	jle    800375 <libmain+0x30>
		binaryname = argv[0];
  80036e:	8b 06                	mov    (%esi),%eax
  800370:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  800375:	89 74 24 04          	mov    %esi,0x4(%esp)
  800379:	89 1c 24             	mov    %ebx,(%esp)
  80037c:	e8 b2 fc ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800381:	e8 07 00 00 00       	call   80038d <exit>
}
  800386:	83 c4 10             	add    $0x10,%esp
  800389:	5b                   	pop    %ebx
  80038a:	5e                   	pop    %esi
  80038b:	5d                   	pop    %ebp
  80038c:	c3                   	ret    

0080038d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80038d:	55                   	push   %ebp
  80038e:	89 e5                	mov    %esp,%ebp
  800390:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800393:	e8 82 14 00 00       	call   80181a <close_all>
	sys_env_destroy(0);
  800398:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80039f:	e8 af 0a 00 00       	call   800e53 <sys_env_destroy>
}
  8003a4:	c9                   	leave  
  8003a5:	c3                   	ret    

008003a6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	56                   	push   %esi
  8003aa:	53                   	push   %ebx
  8003ab:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ae:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003b1:	8b 35 00 40 80 00    	mov    0x804000,%esi
  8003b7:	e8 e9 0a 00 00       	call   800ea5 <sys_getenvid>
  8003bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003bf:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003ca:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d2:	c7 04 24 48 2d 80 00 	movl   $0x802d48,(%esp)
  8003d9:	e8 c1 00 00 00       	call   80049f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8003e5:	89 04 24             	mov    %eax,(%esp)
  8003e8:	e8 51 00 00 00       	call   80043e <vcprintf>
	cprintf("\n");
  8003ed:	c7 04 24 9f 2c 80 00 	movl   $0x802c9f,(%esp)
  8003f4:	e8 a6 00 00 00       	call   80049f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003f9:	cc                   	int3   
  8003fa:	eb fd                	jmp    8003f9 <_panic+0x53>

008003fc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
  8003ff:	53                   	push   %ebx
  800400:	83 ec 14             	sub    $0x14,%esp
  800403:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800406:	8b 13                	mov    (%ebx),%edx
  800408:	8d 42 01             	lea    0x1(%edx),%eax
  80040b:	89 03                	mov    %eax,(%ebx)
  80040d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800410:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800414:	3d ff 00 00 00       	cmp    $0xff,%eax
  800419:	75 19                	jne    800434 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80041b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800422:	00 
  800423:	8d 43 08             	lea    0x8(%ebx),%eax
  800426:	89 04 24             	mov    %eax,(%esp)
  800429:	e8 e8 09 00 00       	call   800e16 <sys_cputs>
		b->idx = 0;
  80042e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800434:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800438:	83 c4 14             	add    $0x14,%esp
  80043b:	5b                   	pop    %ebx
  80043c:	5d                   	pop    %ebp
  80043d:	c3                   	ret    

0080043e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
  800441:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800447:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80044e:	00 00 00 
	b.cnt = 0;
  800451:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800458:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80045b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800462:	8b 45 08             	mov    0x8(%ebp),%eax
  800465:	89 44 24 08          	mov    %eax,0x8(%esp)
  800469:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80046f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800473:	c7 04 24 fc 03 80 00 	movl   $0x8003fc,(%esp)
  80047a:	e8 af 01 00 00       	call   80062e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80047f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800485:	89 44 24 04          	mov    %eax,0x4(%esp)
  800489:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80048f:	89 04 24             	mov    %eax,(%esp)
  800492:	e8 7f 09 00 00       	call   800e16 <sys_cputs>

	return b.cnt;
}
  800497:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80049d:	c9                   	leave  
  80049e:	c3                   	ret    

0080049f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80049f:	55                   	push   %ebp
  8004a0:	89 e5                	mov    %esp,%ebp
  8004a2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004a5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8004af:	89 04 24             	mov    %eax,(%esp)
  8004b2:	e8 87 ff ff ff       	call   80043e <vcprintf>
	va_end(ap);

	return cnt;
}
  8004b7:	c9                   	leave  
  8004b8:	c3                   	ret    
  8004b9:	66 90                	xchg   %ax,%ax
  8004bb:	66 90                	xchg   %ax,%ax
  8004bd:	66 90                	xchg   %ax,%ax
  8004bf:	90                   	nop

008004c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
  8004c3:	57                   	push   %edi
  8004c4:	56                   	push   %esi
  8004c5:	53                   	push   %ebx
  8004c6:	83 ec 3c             	sub    $0x3c,%esp
  8004c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004cc:	89 d7                	mov    %edx,%edi
  8004ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d7:	89 c3                	mov    %eax,%ebx
  8004d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8004df:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004ed:	39 d9                	cmp    %ebx,%ecx
  8004ef:	72 05                	jb     8004f6 <printnum+0x36>
  8004f1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8004f4:	77 69                	ja     80055f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004f6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8004f9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8004fd:	83 ee 01             	sub    $0x1,%esi
  800500:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800504:	89 44 24 08          	mov    %eax,0x8(%esp)
  800508:	8b 44 24 08          	mov    0x8(%esp),%eax
  80050c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800510:	89 c3                	mov    %eax,%ebx
  800512:	89 d6                	mov    %edx,%esi
  800514:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800517:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80051a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80051e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800522:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800525:	89 04 24             	mov    %eax,(%esp)
  800528:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80052b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052f:	e8 7c 24 00 00       	call   8029b0 <__udivdi3>
  800534:	89 d9                	mov    %ebx,%ecx
  800536:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80053a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80053e:	89 04 24             	mov    %eax,(%esp)
  800541:	89 54 24 04          	mov    %edx,0x4(%esp)
  800545:	89 fa                	mov    %edi,%edx
  800547:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80054a:	e8 71 ff ff ff       	call   8004c0 <printnum>
  80054f:	eb 1b                	jmp    80056c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800551:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800555:	8b 45 18             	mov    0x18(%ebp),%eax
  800558:	89 04 24             	mov    %eax,(%esp)
  80055b:	ff d3                	call   *%ebx
  80055d:	eb 03                	jmp    800562 <printnum+0xa2>
  80055f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800562:	83 ee 01             	sub    $0x1,%esi
  800565:	85 f6                	test   %esi,%esi
  800567:	7f e8                	jg     800551 <printnum+0x91>
  800569:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80056c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800570:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800574:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800577:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80057a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80057e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800582:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800585:	89 04 24             	mov    %eax,(%esp)
  800588:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80058b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058f:	e8 4c 25 00 00       	call   802ae0 <__umoddi3>
  800594:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800598:	0f be 80 6b 2d 80 00 	movsbl 0x802d6b(%eax),%eax
  80059f:	89 04 24             	mov    %eax,(%esp)
  8005a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005a5:	ff d0                	call   *%eax
}
  8005a7:	83 c4 3c             	add    $0x3c,%esp
  8005aa:	5b                   	pop    %ebx
  8005ab:	5e                   	pop    %esi
  8005ac:	5f                   	pop    %edi
  8005ad:	5d                   	pop    %ebp
  8005ae:	c3                   	ret    

008005af <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005af:	55                   	push   %ebp
  8005b0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005b2:	83 fa 01             	cmp    $0x1,%edx
  8005b5:	7e 0e                	jle    8005c5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005b7:	8b 10                	mov    (%eax),%edx
  8005b9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005bc:	89 08                	mov    %ecx,(%eax)
  8005be:	8b 02                	mov    (%edx),%eax
  8005c0:	8b 52 04             	mov    0x4(%edx),%edx
  8005c3:	eb 22                	jmp    8005e7 <getuint+0x38>
	else if (lflag)
  8005c5:	85 d2                	test   %edx,%edx
  8005c7:	74 10                	je     8005d9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005c9:	8b 10                	mov    (%eax),%edx
  8005cb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ce:	89 08                	mov    %ecx,(%eax)
  8005d0:	8b 02                	mov    (%edx),%eax
  8005d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8005d7:	eb 0e                	jmp    8005e7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005d9:	8b 10                	mov    (%eax),%edx
  8005db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005de:	89 08                	mov    %ecx,(%eax)
  8005e0:	8b 02                	mov    (%edx),%eax
  8005e2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005e7:	5d                   	pop    %ebp
  8005e8:	c3                   	ret    

008005e9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005e9:	55                   	push   %ebp
  8005ea:	89 e5                	mov    %esp,%ebp
  8005ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005ef:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005f3:	8b 10                	mov    (%eax),%edx
  8005f5:	3b 50 04             	cmp    0x4(%eax),%edx
  8005f8:	73 0a                	jae    800604 <sprintputch+0x1b>
		*b->buf++ = ch;
  8005fa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005fd:	89 08                	mov    %ecx,(%eax)
  8005ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800602:	88 02                	mov    %al,(%edx)
}
  800604:	5d                   	pop    %ebp
  800605:	c3                   	ret    

00800606 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800606:	55                   	push   %ebp
  800607:	89 e5                	mov    %esp,%ebp
  800609:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80060c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80060f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800613:	8b 45 10             	mov    0x10(%ebp),%eax
  800616:	89 44 24 08          	mov    %eax,0x8(%esp)
  80061a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80061d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800621:	8b 45 08             	mov    0x8(%ebp),%eax
  800624:	89 04 24             	mov    %eax,(%esp)
  800627:	e8 02 00 00 00       	call   80062e <vprintfmt>
	va_end(ap);
}
  80062c:	c9                   	leave  
  80062d:	c3                   	ret    

0080062e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80062e:	55                   	push   %ebp
  80062f:	89 e5                	mov    %esp,%ebp
  800631:	57                   	push   %edi
  800632:	56                   	push   %esi
  800633:	53                   	push   %ebx
  800634:	83 ec 3c             	sub    $0x3c,%esp
  800637:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80063a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80063d:	eb 14                	jmp    800653 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80063f:	85 c0                	test   %eax,%eax
  800641:	0f 84 b3 03 00 00    	je     8009fa <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800647:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80064b:	89 04 24             	mov    %eax,(%esp)
  80064e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800651:	89 f3                	mov    %esi,%ebx
  800653:	8d 73 01             	lea    0x1(%ebx),%esi
  800656:	0f b6 03             	movzbl (%ebx),%eax
  800659:	83 f8 25             	cmp    $0x25,%eax
  80065c:	75 e1                	jne    80063f <vprintfmt+0x11>
  80065e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800662:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800669:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800670:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800677:	ba 00 00 00 00       	mov    $0x0,%edx
  80067c:	eb 1d                	jmp    80069b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800680:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800684:	eb 15                	jmp    80069b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800686:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800688:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80068c:	eb 0d                	jmp    80069b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80068e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800691:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800694:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80069e:	0f b6 0e             	movzbl (%esi),%ecx
  8006a1:	0f b6 c1             	movzbl %cl,%eax
  8006a4:	83 e9 23             	sub    $0x23,%ecx
  8006a7:	80 f9 55             	cmp    $0x55,%cl
  8006aa:	0f 87 2a 03 00 00    	ja     8009da <vprintfmt+0x3ac>
  8006b0:	0f b6 c9             	movzbl %cl,%ecx
  8006b3:	ff 24 8d a0 2e 80 00 	jmp    *0x802ea0(,%ecx,4)
  8006ba:	89 de                	mov    %ebx,%esi
  8006bc:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006c1:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8006c4:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8006c8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006cb:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8006ce:	83 fb 09             	cmp    $0x9,%ebx
  8006d1:	77 36                	ja     800709 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006d3:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006d6:	eb e9                	jmp    8006c1 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8d 48 04             	lea    0x4(%eax),%ecx
  8006de:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006e1:	8b 00                	mov    (%eax),%eax
  8006e3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e6:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006e8:	eb 22                	jmp    80070c <vprintfmt+0xde>
  8006ea:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006ed:	85 c9                	test   %ecx,%ecx
  8006ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f4:	0f 49 c1             	cmovns %ecx,%eax
  8006f7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fa:	89 de                	mov    %ebx,%esi
  8006fc:	eb 9d                	jmp    80069b <vprintfmt+0x6d>
  8006fe:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800700:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800707:	eb 92                	jmp    80069b <vprintfmt+0x6d>
  800709:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80070c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800710:	79 89                	jns    80069b <vprintfmt+0x6d>
  800712:	e9 77 ff ff ff       	jmp    80068e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800717:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071a:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80071c:	e9 7a ff ff ff       	jmp    80069b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800721:	8b 45 14             	mov    0x14(%ebp),%eax
  800724:	8d 50 04             	lea    0x4(%eax),%edx
  800727:	89 55 14             	mov    %edx,0x14(%ebp)
  80072a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80072e:	8b 00                	mov    (%eax),%eax
  800730:	89 04 24             	mov    %eax,(%esp)
  800733:	ff 55 08             	call   *0x8(%ebp)
			break;
  800736:	e9 18 ff ff ff       	jmp    800653 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80073b:	8b 45 14             	mov    0x14(%ebp),%eax
  80073e:	8d 50 04             	lea    0x4(%eax),%edx
  800741:	89 55 14             	mov    %edx,0x14(%ebp)
  800744:	8b 00                	mov    (%eax),%eax
  800746:	99                   	cltd   
  800747:	31 d0                	xor    %edx,%eax
  800749:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80074b:	83 f8 0f             	cmp    $0xf,%eax
  80074e:	7f 0b                	jg     80075b <vprintfmt+0x12d>
  800750:	8b 14 85 00 30 80 00 	mov    0x803000(,%eax,4),%edx
  800757:	85 d2                	test   %edx,%edx
  800759:	75 20                	jne    80077b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80075b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80075f:	c7 44 24 08 83 2d 80 	movl   $0x802d83,0x8(%esp)
  800766:	00 
  800767:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80076b:	8b 45 08             	mov    0x8(%ebp),%eax
  80076e:	89 04 24             	mov    %eax,(%esp)
  800771:	e8 90 fe ff ff       	call   800606 <printfmt>
  800776:	e9 d8 fe ff ff       	jmp    800653 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80077b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80077f:	c7 44 24 08 ed 31 80 	movl   $0x8031ed,0x8(%esp)
  800786:	00 
  800787:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80078b:	8b 45 08             	mov    0x8(%ebp),%eax
  80078e:	89 04 24             	mov    %eax,(%esp)
  800791:	e8 70 fe ff ff       	call   800606 <printfmt>
  800796:	e9 b8 fe ff ff       	jmp    800653 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80079e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007a1:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a7:	8d 50 04             	lea    0x4(%eax),%edx
  8007aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ad:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8007af:	85 f6                	test   %esi,%esi
  8007b1:	b8 7c 2d 80 00       	mov    $0x802d7c,%eax
  8007b6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8007b9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8007bd:	0f 84 97 00 00 00    	je     80085a <vprintfmt+0x22c>
  8007c3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8007c7:	0f 8e 9b 00 00 00    	jle    800868 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007cd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007d1:	89 34 24             	mov    %esi,(%esp)
  8007d4:	e8 cf 02 00 00       	call   800aa8 <strnlen>
  8007d9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007dc:	29 c2                	sub    %eax,%edx
  8007de:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8007e1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8007e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8007e8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8007eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ee:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8007f1:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007f3:	eb 0f                	jmp    800804 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8007f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007fc:	89 04 24             	mov    %eax,(%esp)
  8007ff:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800801:	83 eb 01             	sub    $0x1,%ebx
  800804:	85 db                	test   %ebx,%ebx
  800806:	7f ed                	jg     8007f5 <vprintfmt+0x1c7>
  800808:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80080b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80080e:	85 d2                	test   %edx,%edx
  800810:	b8 00 00 00 00       	mov    $0x0,%eax
  800815:	0f 49 c2             	cmovns %edx,%eax
  800818:	29 c2                	sub    %eax,%edx
  80081a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80081d:	89 d7                	mov    %edx,%edi
  80081f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800822:	eb 50                	jmp    800874 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800824:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800828:	74 1e                	je     800848 <vprintfmt+0x21a>
  80082a:	0f be d2             	movsbl %dl,%edx
  80082d:	83 ea 20             	sub    $0x20,%edx
  800830:	83 fa 5e             	cmp    $0x5e,%edx
  800833:	76 13                	jbe    800848 <vprintfmt+0x21a>
					putch('?', putdat);
  800835:	8b 45 0c             	mov    0xc(%ebp),%eax
  800838:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800843:	ff 55 08             	call   *0x8(%ebp)
  800846:	eb 0d                	jmp    800855 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800848:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80084f:	89 04 24             	mov    %eax,(%esp)
  800852:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800855:	83 ef 01             	sub    $0x1,%edi
  800858:	eb 1a                	jmp    800874 <vprintfmt+0x246>
  80085a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80085d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800860:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800863:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800866:	eb 0c                	jmp    800874 <vprintfmt+0x246>
  800868:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80086b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80086e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800871:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800874:	83 c6 01             	add    $0x1,%esi
  800877:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80087b:	0f be c2             	movsbl %dl,%eax
  80087e:	85 c0                	test   %eax,%eax
  800880:	74 27                	je     8008a9 <vprintfmt+0x27b>
  800882:	85 db                	test   %ebx,%ebx
  800884:	78 9e                	js     800824 <vprintfmt+0x1f6>
  800886:	83 eb 01             	sub    $0x1,%ebx
  800889:	79 99                	jns    800824 <vprintfmt+0x1f6>
  80088b:	89 f8                	mov    %edi,%eax
  80088d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800890:	8b 75 08             	mov    0x8(%ebp),%esi
  800893:	89 c3                	mov    %eax,%ebx
  800895:	eb 1a                	jmp    8008b1 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800897:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80089b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008a2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008a4:	83 eb 01             	sub    $0x1,%ebx
  8008a7:	eb 08                	jmp    8008b1 <vprintfmt+0x283>
  8008a9:	89 fb                	mov    %edi,%ebx
  8008ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ae:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8008b1:	85 db                	test   %ebx,%ebx
  8008b3:	7f e2                	jg     800897 <vprintfmt+0x269>
  8008b5:	89 75 08             	mov    %esi,0x8(%ebp)
  8008b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8008bb:	e9 93 fd ff ff       	jmp    800653 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008c0:	83 fa 01             	cmp    $0x1,%edx
  8008c3:	7e 16                	jle    8008db <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  8008c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c8:	8d 50 08             	lea    0x8(%eax),%edx
  8008cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ce:	8b 50 04             	mov    0x4(%eax),%edx
  8008d1:	8b 00                	mov    (%eax),%eax
  8008d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008d6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008d9:	eb 32                	jmp    80090d <vprintfmt+0x2df>
	else if (lflag)
  8008db:	85 d2                	test   %edx,%edx
  8008dd:	74 18                	je     8008f7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8008df:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e2:	8d 50 04             	lea    0x4(%eax),%edx
  8008e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e8:	8b 30                	mov    (%eax),%esi
  8008ea:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8008ed:	89 f0                	mov    %esi,%eax
  8008ef:	c1 f8 1f             	sar    $0x1f,%eax
  8008f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008f5:	eb 16                	jmp    80090d <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8008f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fa:	8d 50 04             	lea    0x4(%eax),%edx
  8008fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800900:	8b 30                	mov    (%eax),%esi
  800902:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800905:	89 f0                	mov    %esi,%eax
  800907:	c1 f8 1f             	sar    $0x1f,%eax
  80090a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80090d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800910:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800913:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800918:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80091c:	0f 89 80 00 00 00    	jns    8009a2 <vprintfmt+0x374>
				putch('-', putdat);
  800922:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800926:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80092d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800930:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800933:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800936:	f7 d8                	neg    %eax
  800938:	83 d2 00             	adc    $0x0,%edx
  80093b:	f7 da                	neg    %edx
			}
			base = 10;
  80093d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800942:	eb 5e                	jmp    8009a2 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800944:	8d 45 14             	lea    0x14(%ebp),%eax
  800947:	e8 63 fc ff ff       	call   8005af <getuint>
			base = 10;
  80094c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800951:	eb 4f                	jmp    8009a2 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800953:	8d 45 14             	lea    0x14(%ebp),%eax
  800956:	e8 54 fc ff ff       	call   8005af <getuint>
			base = 8;
  80095b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800960:	eb 40                	jmp    8009a2 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800962:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800966:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80096d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800970:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800974:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80097b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80097e:	8b 45 14             	mov    0x14(%ebp),%eax
  800981:	8d 50 04             	lea    0x4(%eax),%edx
  800984:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800987:	8b 00                	mov    (%eax),%eax
  800989:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80098e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800993:	eb 0d                	jmp    8009a2 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800995:	8d 45 14             	lea    0x14(%ebp),%eax
  800998:	e8 12 fc ff ff       	call   8005af <getuint>
			base = 16;
  80099d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009a2:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8009a6:	89 74 24 10          	mov    %esi,0x10(%esp)
  8009aa:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8009ad:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8009b1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8009b5:	89 04 24             	mov    %eax,(%esp)
  8009b8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009bc:	89 fa                	mov    %edi,%edx
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	e8 fa fa ff ff       	call   8004c0 <printnum>
			break;
  8009c6:	e9 88 fc ff ff       	jmp    800653 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009cb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009cf:	89 04 24             	mov    %eax,(%esp)
  8009d2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8009d5:	e9 79 fc ff ff       	jmp    800653 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009de:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009e5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009e8:	89 f3                	mov    %esi,%ebx
  8009ea:	eb 03                	jmp    8009ef <vprintfmt+0x3c1>
  8009ec:	83 eb 01             	sub    $0x1,%ebx
  8009ef:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8009f3:	75 f7                	jne    8009ec <vprintfmt+0x3be>
  8009f5:	e9 59 fc ff ff       	jmp    800653 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8009fa:	83 c4 3c             	add    $0x3c,%esp
  8009fd:	5b                   	pop    %ebx
  8009fe:	5e                   	pop    %esi
  8009ff:	5f                   	pop    %edi
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    

00800a02 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	83 ec 28             	sub    $0x28,%esp
  800a08:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a0e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a11:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a15:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a18:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a1f:	85 c0                	test   %eax,%eax
  800a21:	74 30                	je     800a53 <vsnprintf+0x51>
  800a23:	85 d2                	test   %edx,%edx
  800a25:	7e 2c                	jle    800a53 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a27:	8b 45 14             	mov    0x14(%ebp),%eax
  800a2a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a2e:	8b 45 10             	mov    0x10(%ebp),%eax
  800a31:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a35:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a38:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a3c:	c7 04 24 e9 05 80 00 	movl   $0x8005e9,(%esp)
  800a43:	e8 e6 fb ff ff       	call   80062e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a48:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a4b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a51:	eb 05                	jmp    800a58 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a53:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a58:	c9                   	leave  
  800a59:	c3                   	ret    

00800a5a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a60:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a63:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a67:	8b 45 10             	mov    0x10(%ebp),%eax
  800a6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a71:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a75:	8b 45 08             	mov    0x8(%ebp),%eax
  800a78:	89 04 24             	mov    %eax,(%esp)
  800a7b:	e8 82 ff ff ff       	call   800a02 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a80:	c9                   	leave  
  800a81:	c3                   	ret    
  800a82:	66 90                	xchg   %ax,%ax
  800a84:	66 90                	xchg   %ax,%ax
  800a86:	66 90                	xchg   %ax,%ax
  800a88:	66 90                	xchg   %ax,%ax
  800a8a:	66 90                	xchg   %ax,%ax
  800a8c:	66 90                	xchg   %ax,%ax
  800a8e:	66 90                	xchg   %ax,%ax

00800a90 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a96:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9b:	eb 03                	jmp    800aa0 <strlen+0x10>
		n++;
  800a9d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800aa0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800aa4:	75 f7                	jne    800a9d <strlen+0xd>
		n++;
	return n;
}
  800aa6:	5d                   	pop    %ebp
  800aa7:	c3                   	ret    

00800aa8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aae:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ab1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab6:	eb 03                	jmp    800abb <strnlen+0x13>
		n++;
  800ab8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800abb:	39 d0                	cmp    %edx,%eax
  800abd:	74 06                	je     800ac5 <strnlen+0x1d>
  800abf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800ac3:	75 f3                	jne    800ab8 <strnlen+0x10>
		n++;
	return n;
}
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	53                   	push   %ebx
  800acb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ace:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ad1:	89 c2                	mov    %eax,%edx
  800ad3:	83 c2 01             	add    $0x1,%edx
  800ad6:	83 c1 01             	add    $0x1,%ecx
  800ad9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800add:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ae0:	84 db                	test   %bl,%bl
  800ae2:	75 ef                	jne    800ad3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ae4:	5b                   	pop    %ebx
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	53                   	push   %ebx
  800aeb:	83 ec 08             	sub    $0x8,%esp
  800aee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800af1:	89 1c 24             	mov    %ebx,(%esp)
  800af4:	e8 97 ff ff ff       	call   800a90 <strlen>
	strcpy(dst + len, src);
  800af9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800afc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b00:	01 d8                	add    %ebx,%eax
  800b02:	89 04 24             	mov    %eax,(%esp)
  800b05:	e8 bd ff ff ff       	call   800ac7 <strcpy>
	return dst;
}
  800b0a:	89 d8                	mov    %ebx,%eax
  800b0c:	83 c4 08             	add    $0x8,%esp
  800b0f:	5b                   	pop    %ebx
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
  800b17:	8b 75 08             	mov    0x8(%ebp),%esi
  800b1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1d:	89 f3                	mov    %esi,%ebx
  800b1f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b22:	89 f2                	mov    %esi,%edx
  800b24:	eb 0f                	jmp    800b35 <strncpy+0x23>
		*dst++ = *src;
  800b26:	83 c2 01             	add    $0x1,%edx
  800b29:	0f b6 01             	movzbl (%ecx),%eax
  800b2c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b2f:	80 39 01             	cmpb   $0x1,(%ecx)
  800b32:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b35:	39 da                	cmp    %ebx,%edx
  800b37:	75 ed                	jne    800b26 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b39:	89 f0                	mov    %esi,%eax
  800b3b:	5b                   	pop    %ebx
  800b3c:	5e                   	pop    %esi
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
  800b44:	8b 75 08             	mov    0x8(%ebp),%esi
  800b47:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b4a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b4d:	89 f0                	mov    %esi,%eax
  800b4f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b53:	85 c9                	test   %ecx,%ecx
  800b55:	75 0b                	jne    800b62 <strlcpy+0x23>
  800b57:	eb 1d                	jmp    800b76 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b59:	83 c0 01             	add    $0x1,%eax
  800b5c:	83 c2 01             	add    $0x1,%edx
  800b5f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b62:	39 d8                	cmp    %ebx,%eax
  800b64:	74 0b                	je     800b71 <strlcpy+0x32>
  800b66:	0f b6 0a             	movzbl (%edx),%ecx
  800b69:	84 c9                	test   %cl,%cl
  800b6b:	75 ec                	jne    800b59 <strlcpy+0x1a>
  800b6d:	89 c2                	mov    %eax,%edx
  800b6f:	eb 02                	jmp    800b73 <strlcpy+0x34>
  800b71:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b73:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b76:	29 f0                	sub    %esi,%eax
}
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b82:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b85:	eb 06                	jmp    800b8d <strcmp+0x11>
		p++, q++;
  800b87:	83 c1 01             	add    $0x1,%ecx
  800b8a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b8d:	0f b6 01             	movzbl (%ecx),%eax
  800b90:	84 c0                	test   %al,%al
  800b92:	74 04                	je     800b98 <strcmp+0x1c>
  800b94:	3a 02                	cmp    (%edx),%al
  800b96:	74 ef                	je     800b87 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b98:	0f b6 c0             	movzbl %al,%eax
  800b9b:	0f b6 12             	movzbl (%edx),%edx
  800b9e:	29 d0                	sub    %edx,%eax
}
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	53                   	push   %ebx
  800ba6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bac:	89 c3                	mov    %eax,%ebx
  800bae:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800bb1:	eb 06                	jmp    800bb9 <strncmp+0x17>
		n--, p++, q++;
  800bb3:	83 c0 01             	add    $0x1,%eax
  800bb6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bb9:	39 d8                	cmp    %ebx,%eax
  800bbb:	74 15                	je     800bd2 <strncmp+0x30>
  800bbd:	0f b6 08             	movzbl (%eax),%ecx
  800bc0:	84 c9                	test   %cl,%cl
  800bc2:	74 04                	je     800bc8 <strncmp+0x26>
  800bc4:	3a 0a                	cmp    (%edx),%cl
  800bc6:	74 eb                	je     800bb3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bc8:	0f b6 00             	movzbl (%eax),%eax
  800bcb:	0f b6 12             	movzbl (%edx),%edx
  800bce:	29 d0                	sub    %edx,%eax
  800bd0:	eb 05                	jmp    800bd7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800bd2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bd7:	5b                   	pop    %ebx
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	8b 45 08             	mov    0x8(%ebp),%eax
  800be0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800be4:	eb 07                	jmp    800bed <strchr+0x13>
		if (*s == c)
  800be6:	38 ca                	cmp    %cl,%dl
  800be8:	74 0f                	je     800bf9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bea:	83 c0 01             	add    $0x1,%eax
  800bed:	0f b6 10             	movzbl (%eax),%edx
  800bf0:	84 d2                	test   %dl,%dl
  800bf2:	75 f2                	jne    800be6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800bf4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800c01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c05:	eb 07                	jmp    800c0e <strfind+0x13>
		if (*s == c)
  800c07:	38 ca                	cmp    %cl,%dl
  800c09:	74 0a                	je     800c15 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c0b:	83 c0 01             	add    $0x1,%eax
  800c0e:	0f b6 10             	movzbl (%eax),%edx
  800c11:	84 d2                	test   %dl,%dl
  800c13:	75 f2                	jne    800c07 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    

00800c17 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	57                   	push   %edi
  800c1b:	56                   	push   %esi
  800c1c:	53                   	push   %ebx
  800c1d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c20:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c23:	85 c9                	test   %ecx,%ecx
  800c25:	74 36                	je     800c5d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c27:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c2d:	75 28                	jne    800c57 <memset+0x40>
  800c2f:	f6 c1 03             	test   $0x3,%cl
  800c32:	75 23                	jne    800c57 <memset+0x40>
		c &= 0xFF;
  800c34:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c38:	89 d3                	mov    %edx,%ebx
  800c3a:	c1 e3 08             	shl    $0x8,%ebx
  800c3d:	89 d6                	mov    %edx,%esi
  800c3f:	c1 e6 18             	shl    $0x18,%esi
  800c42:	89 d0                	mov    %edx,%eax
  800c44:	c1 e0 10             	shl    $0x10,%eax
  800c47:	09 f0                	or     %esi,%eax
  800c49:	09 c2                	or     %eax,%edx
  800c4b:	89 d0                	mov    %edx,%eax
  800c4d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c4f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c52:	fc                   	cld    
  800c53:	f3 ab                	rep stos %eax,%es:(%edi)
  800c55:	eb 06                	jmp    800c5d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c5a:	fc                   	cld    
  800c5b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c5d:	89 f8                	mov    %edi,%eax
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c72:	39 c6                	cmp    %eax,%esi
  800c74:	73 35                	jae    800cab <memmove+0x47>
  800c76:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c79:	39 d0                	cmp    %edx,%eax
  800c7b:	73 2e                	jae    800cab <memmove+0x47>
		s += n;
		d += n;
  800c7d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800c80:	89 d6                	mov    %edx,%esi
  800c82:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c84:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c8a:	75 13                	jne    800c9f <memmove+0x3b>
  800c8c:	f6 c1 03             	test   $0x3,%cl
  800c8f:	75 0e                	jne    800c9f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c91:	83 ef 04             	sub    $0x4,%edi
  800c94:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c97:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c9a:	fd                   	std    
  800c9b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c9d:	eb 09                	jmp    800ca8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c9f:	83 ef 01             	sub    $0x1,%edi
  800ca2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ca5:	fd                   	std    
  800ca6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ca8:	fc                   	cld    
  800ca9:	eb 1d                	jmp    800cc8 <memmove+0x64>
  800cab:	89 f2                	mov    %esi,%edx
  800cad:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800caf:	f6 c2 03             	test   $0x3,%dl
  800cb2:	75 0f                	jne    800cc3 <memmove+0x5f>
  800cb4:	f6 c1 03             	test   $0x3,%cl
  800cb7:	75 0a                	jne    800cc3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cb9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cbc:	89 c7                	mov    %eax,%edi
  800cbe:	fc                   	cld    
  800cbf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cc1:	eb 05                	jmp    800cc8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cc3:	89 c7                	mov    %eax,%edi
  800cc5:	fc                   	cld    
  800cc6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cd2:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cdc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ce0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce3:	89 04 24             	mov    %eax,(%esp)
  800ce6:	e8 79 ff ff ff       	call   800c64 <memmove>
}
  800ceb:	c9                   	leave  
  800cec:	c3                   	ret    

00800ced <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
  800cf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf8:	89 d6                	mov    %edx,%esi
  800cfa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cfd:	eb 1a                	jmp    800d19 <memcmp+0x2c>
		if (*s1 != *s2)
  800cff:	0f b6 02             	movzbl (%edx),%eax
  800d02:	0f b6 19             	movzbl (%ecx),%ebx
  800d05:	38 d8                	cmp    %bl,%al
  800d07:	74 0a                	je     800d13 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d09:	0f b6 c0             	movzbl %al,%eax
  800d0c:	0f b6 db             	movzbl %bl,%ebx
  800d0f:	29 d8                	sub    %ebx,%eax
  800d11:	eb 0f                	jmp    800d22 <memcmp+0x35>
		s1++, s2++;
  800d13:	83 c2 01             	add    $0x1,%edx
  800d16:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d19:	39 f2                	cmp    %esi,%edx
  800d1b:	75 e2                	jne    800cff <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d2f:	89 c2                	mov    %eax,%edx
  800d31:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d34:	eb 07                	jmp    800d3d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d36:	38 08                	cmp    %cl,(%eax)
  800d38:	74 07                	je     800d41 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d3a:	83 c0 01             	add    $0x1,%eax
  800d3d:	39 d0                	cmp    %edx,%eax
  800d3f:	72 f5                	jb     800d36 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	57                   	push   %edi
  800d47:	56                   	push   %esi
  800d48:	53                   	push   %ebx
  800d49:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d4f:	eb 03                	jmp    800d54 <strtol+0x11>
		s++;
  800d51:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d54:	0f b6 0a             	movzbl (%edx),%ecx
  800d57:	80 f9 09             	cmp    $0x9,%cl
  800d5a:	74 f5                	je     800d51 <strtol+0xe>
  800d5c:	80 f9 20             	cmp    $0x20,%cl
  800d5f:	74 f0                	je     800d51 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d61:	80 f9 2b             	cmp    $0x2b,%cl
  800d64:	75 0a                	jne    800d70 <strtol+0x2d>
		s++;
  800d66:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d69:	bf 00 00 00 00       	mov    $0x0,%edi
  800d6e:	eb 11                	jmp    800d81 <strtol+0x3e>
  800d70:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d75:	80 f9 2d             	cmp    $0x2d,%cl
  800d78:	75 07                	jne    800d81 <strtol+0x3e>
		s++, neg = 1;
  800d7a:	8d 52 01             	lea    0x1(%edx),%edx
  800d7d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d81:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800d86:	75 15                	jne    800d9d <strtol+0x5a>
  800d88:	80 3a 30             	cmpb   $0x30,(%edx)
  800d8b:	75 10                	jne    800d9d <strtol+0x5a>
  800d8d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d91:	75 0a                	jne    800d9d <strtol+0x5a>
		s += 2, base = 16;
  800d93:	83 c2 02             	add    $0x2,%edx
  800d96:	b8 10 00 00 00       	mov    $0x10,%eax
  800d9b:	eb 10                	jmp    800dad <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	75 0c                	jne    800dad <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800da1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800da3:	80 3a 30             	cmpb   $0x30,(%edx)
  800da6:	75 05                	jne    800dad <strtol+0x6a>
		s++, base = 8;
  800da8:	83 c2 01             	add    $0x1,%edx
  800dab:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800dad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800db5:	0f b6 0a             	movzbl (%edx),%ecx
  800db8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800dbb:	89 f0                	mov    %esi,%eax
  800dbd:	3c 09                	cmp    $0x9,%al
  800dbf:	77 08                	ja     800dc9 <strtol+0x86>
			dig = *s - '0';
  800dc1:	0f be c9             	movsbl %cl,%ecx
  800dc4:	83 e9 30             	sub    $0x30,%ecx
  800dc7:	eb 20                	jmp    800de9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800dc9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800dcc:	89 f0                	mov    %esi,%eax
  800dce:	3c 19                	cmp    $0x19,%al
  800dd0:	77 08                	ja     800dda <strtol+0x97>
			dig = *s - 'a' + 10;
  800dd2:	0f be c9             	movsbl %cl,%ecx
  800dd5:	83 e9 57             	sub    $0x57,%ecx
  800dd8:	eb 0f                	jmp    800de9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800dda:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800ddd:	89 f0                	mov    %esi,%eax
  800ddf:	3c 19                	cmp    $0x19,%al
  800de1:	77 16                	ja     800df9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800de3:	0f be c9             	movsbl %cl,%ecx
  800de6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800de9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800dec:	7d 0f                	jge    800dfd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800dee:	83 c2 01             	add    $0x1,%edx
  800df1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800df5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800df7:	eb bc                	jmp    800db5 <strtol+0x72>
  800df9:	89 d8                	mov    %ebx,%eax
  800dfb:	eb 02                	jmp    800dff <strtol+0xbc>
  800dfd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800dff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e03:	74 05                	je     800e0a <strtol+0xc7>
		*endptr = (char *) s;
  800e05:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e08:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800e0a:	f7 d8                	neg    %eax
  800e0c:	85 ff                	test   %edi,%edi
  800e0e:	0f 44 c3             	cmove  %ebx,%eax
}
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    

00800e16 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e16:	55                   	push   %ebp
  800e17:	89 e5                	mov    %esp,%ebp
  800e19:	57                   	push   %edi
  800e1a:	56                   	push   %esi
  800e1b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e24:	8b 55 08             	mov    0x8(%ebp),%edx
  800e27:	89 c3                	mov    %eax,%ebx
  800e29:	89 c7                	mov    %eax,%edi
  800e2b:	89 c6                	mov    %eax,%esi
  800e2d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e2f:	5b                   	pop    %ebx
  800e30:	5e                   	pop    %esi
  800e31:	5f                   	pop    %edi
  800e32:	5d                   	pop    %ebp
  800e33:	c3                   	ret    

00800e34 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	57                   	push   %edi
  800e38:	56                   	push   %esi
  800e39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e3f:	b8 01 00 00 00       	mov    $0x1,%eax
  800e44:	89 d1                	mov    %edx,%ecx
  800e46:	89 d3                	mov    %edx,%ebx
  800e48:	89 d7                	mov    %edx,%edi
  800e4a:	89 d6                	mov    %edx,%esi
  800e4c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e4e:	5b                   	pop    %ebx
  800e4f:	5e                   	pop    %esi
  800e50:	5f                   	pop    %edi
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    

00800e53 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800e5c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e61:	b8 03 00 00 00       	mov    $0x3,%eax
  800e66:	8b 55 08             	mov    0x8(%ebp),%edx
  800e69:	89 cb                	mov    %ecx,%ebx
  800e6b:	89 cf                	mov    %ecx,%edi
  800e6d:	89 ce                	mov    %ecx,%esi
  800e6f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e71:	85 c0                	test   %eax,%eax
  800e73:	7e 28                	jle    800e9d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e75:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e79:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e80:	00 
  800e81:	c7 44 24 08 5f 30 80 	movl   $0x80305f,0x8(%esp)
  800e88:	00 
  800e89:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e90:	00 
  800e91:	c7 04 24 7c 30 80 00 	movl   $0x80307c,(%esp)
  800e98:	e8 09 f5 ff ff       	call   8003a6 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e9d:	83 c4 2c             	add    $0x2c,%esp
  800ea0:	5b                   	pop    %ebx
  800ea1:	5e                   	pop    %esi
  800ea2:	5f                   	pop    %edi
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    

00800ea5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	57                   	push   %edi
  800ea9:	56                   	push   %esi
  800eaa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eab:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb0:	b8 02 00 00 00       	mov    $0x2,%eax
  800eb5:	89 d1                	mov    %edx,%ecx
  800eb7:	89 d3                	mov    %edx,%ebx
  800eb9:	89 d7                	mov    %edx,%edi
  800ebb:	89 d6                	mov    %edx,%esi
  800ebd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ebf:	5b                   	pop    %ebx
  800ec0:	5e                   	pop    %esi
  800ec1:	5f                   	pop    %edi
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    

00800ec4 <sys_yield>:

void
sys_yield(void)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	57                   	push   %edi
  800ec8:	56                   	push   %esi
  800ec9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eca:	ba 00 00 00 00       	mov    $0x0,%edx
  800ecf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ed4:	89 d1                	mov    %edx,%ecx
  800ed6:	89 d3                	mov    %edx,%ebx
  800ed8:	89 d7                	mov    %edx,%edi
  800eda:	89 d6                	mov    %edx,%esi
  800edc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ede:	5b                   	pop    %ebx
  800edf:	5e                   	pop    %esi
  800ee0:	5f                   	pop    %edi
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    

00800ee3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	57                   	push   %edi
  800ee7:	56                   	push   %esi
  800ee8:	53                   	push   %ebx
  800ee9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eec:	be 00 00 00 00       	mov    $0x0,%esi
  800ef1:	b8 04 00 00 00       	mov    $0x4,%eax
  800ef6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef9:	8b 55 08             	mov    0x8(%ebp),%edx
  800efc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eff:	89 f7                	mov    %esi,%edi
  800f01:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f03:	85 c0                	test   %eax,%eax
  800f05:	7e 28                	jle    800f2f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f07:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f0b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f12:	00 
  800f13:	c7 44 24 08 5f 30 80 	movl   $0x80305f,0x8(%esp)
  800f1a:	00 
  800f1b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f22:	00 
  800f23:	c7 04 24 7c 30 80 00 	movl   $0x80307c,(%esp)
  800f2a:	e8 77 f4 ff ff       	call   8003a6 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f2f:	83 c4 2c             	add    $0x2c,%esp
  800f32:	5b                   	pop    %ebx
  800f33:	5e                   	pop    %esi
  800f34:	5f                   	pop    %edi
  800f35:	5d                   	pop    %ebp
  800f36:	c3                   	ret    

00800f37 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f37:	55                   	push   %ebp
  800f38:	89 e5                	mov    %esp,%ebp
  800f3a:	57                   	push   %edi
  800f3b:	56                   	push   %esi
  800f3c:	53                   	push   %ebx
  800f3d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f40:	b8 05 00 00 00       	mov    $0x5,%eax
  800f45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f48:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f4e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f51:	8b 75 18             	mov    0x18(%ebp),%esi
  800f54:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f56:	85 c0                	test   %eax,%eax
  800f58:	7e 28                	jle    800f82 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f5e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f65:	00 
  800f66:	c7 44 24 08 5f 30 80 	movl   $0x80305f,0x8(%esp)
  800f6d:	00 
  800f6e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f75:	00 
  800f76:	c7 04 24 7c 30 80 00 	movl   $0x80307c,(%esp)
  800f7d:	e8 24 f4 ff ff       	call   8003a6 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f82:	83 c4 2c             	add    $0x2c,%esp
  800f85:	5b                   	pop    %ebx
  800f86:	5e                   	pop    %esi
  800f87:	5f                   	pop    %edi
  800f88:	5d                   	pop    %ebp
  800f89:	c3                   	ret    

00800f8a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f8a:	55                   	push   %ebp
  800f8b:	89 e5                	mov    %esp,%ebp
  800f8d:	57                   	push   %edi
  800f8e:	56                   	push   %esi
  800f8f:	53                   	push   %ebx
  800f90:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f98:	b8 06 00 00 00       	mov    $0x6,%eax
  800f9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa3:	89 df                	mov    %ebx,%edi
  800fa5:	89 de                	mov    %ebx,%esi
  800fa7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	7e 28                	jle    800fd5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fad:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fb1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800fb8:	00 
  800fb9:	c7 44 24 08 5f 30 80 	movl   $0x80305f,0x8(%esp)
  800fc0:	00 
  800fc1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fc8:	00 
  800fc9:	c7 04 24 7c 30 80 00 	movl   $0x80307c,(%esp)
  800fd0:	e8 d1 f3 ff ff       	call   8003a6 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fd5:	83 c4 2c             	add    $0x2c,%esp
  800fd8:	5b                   	pop    %ebx
  800fd9:	5e                   	pop    %esi
  800fda:	5f                   	pop    %edi
  800fdb:	5d                   	pop    %ebp
  800fdc:	c3                   	ret    

00800fdd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fdd:	55                   	push   %ebp
  800fde:	89 e5                	mov    %esp,%ebp
  800fe0:	57                   	push   %edi
  800fe1:	56                   	push   %esi
  800fe2:	53                   	push   %ebx
  800fe3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800feb:	b8 08 00 00 00       	mov    $0x8,%eax
  800ff0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff6:	89 df                	mov    %ebx,%edi
  800ff8:	89 de                	mov    %ebx,%esi
  800ffa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ffc:	85 c0                	test   %eax,%eax
  800ffe:	7e 28                	jle    801028 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801000:	89 44 24 10          	mov    %eax,0x10(%esp)
  801004:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80100b:	00 
  80100c:	c7 44 24 08 5f 30 80 	movl   $0x80305f,0x8(%esp)
  801013:	00 
  801014:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80101b:	00 
  80101c:	c7 04 24 7c 30 80 00 	movl   $0x80307c,(%esp)
  801023:	e8 7e f3 ff ff       	call   8003a6 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801028:	83 c4 2c             	add    $0x2c,%esp
  80102b:	5b                   	pop    %ebx
  80102c:	5e                   	pop    %esi
  80102d:	5f                   	pop    %edi
  80102e:	5d                   	pop    %ebp
  80102f:	c3                   	ret    

00801030 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	57                   	push   %edi
  801034:	56                   	push   %esi
  801035:	53                   	push   %ebx
  801036:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801039:	bb 00 00 00 00       	mov    $0x0,%ebx
  80103e:	b8 09 00 00 00       	mov    $0x9,%eax
  801043:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801046:	8b 55 08             	mov    0x8(%ebp),%edx
  801049:	89 df                	mov    %ebx,%edi
  80104b:	89 de                	mov    %ebx,%esi
  80104d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80104f:	85 c0                	test   %eax,%eax
  801051:	7e 28                	jle    80107b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801053:	89 44 24 10          	mov    %eax,0x10(%esp)
  801057:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80105e:	00 
  80105f:	c7 44 24 08 5f 30 80 	movl   $0x80305f,0x8(%esp)
  801066:	00 
  801067:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80106e:	00 
  80106f:	c7 04 24 7c 30 80 00 	movl   $0x80307c,(%esp)
  801076:	e8 2b f3 ff ff       	call   8003a6 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80107b:	83 c4 2c             	add    $0x2c,%esp
  80107e:	5b                   	pop    %ebx
  80107f:	5e                   	pop    %esi
  801080:	5f                   	pop    %edi
  801081:	5d                   	pop    %ebp
  801082:	c3                   	ret    

00801083 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	57                   	push   %edi
  801087:	56                   	push   %esi
  801088:	53                   	push   %ebx
  801089:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80108c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801091:	b8 0a 00 00 00       	mov    $0xa,%eax
  801096:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801099:	8b 55 08             	mov    0x8(%ebp),%edx
  80109c:	89 df                	mov    %ebx,%edi
  80109e:	89 de                	mov    %ebx,%esi
  8010a0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010a2:	85 c0                	test   %eax,%eax
  8010a4:	7e 28                	jle    8010ce <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010a6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010aa:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8010b1:	00 
  8010b2:	c7 44 24 08 5f 30 80 	movl   $0x80305f,0x8(%esp)
  8010b9:	00 
  8010ba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010c1:	00 
  8010c2:	c7 04 24 7c 30 80 00 	movl   $0x80307c,(%esp)
  8010c9:	e8 d8 f2 ff ff       	call   8003a6 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010ce:	83 c4 2c             	add    $0x2c,%esp
  8010d1:	5b                   	pop    %ebx
  8010d2:	5e                   	pop    %esi
  8010d3:	5f                   	pop    %edi
  8010d4:	5d                   	pop    %ebp
  8010d5:	c3                   	ret    

008010d6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010d6:	55                   	push   %ebp
  8010d7:	89 e5                	mov    %esp,%ebp
  8010d9:	57                   	push   %edi
  8010da:	56                   	push   %esi
  8010db:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010dc:	be 00 00 00 00       	mov    $0x0,%esi
  8010e1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010ef:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010f2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010f4:	5b                   	pop    %ebx
  8010f5:	5e                   	pop    %esi
  8010f6:	5f                   	pop    %edi
  8010f7:	5d                   	pop    %ebp
  8010f8:	c3                   	ret    

008010f9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
  8010fc:	57                   	push   %edi
  8010fd:	56                   	push   %esi
  8010fe:	53                   	push   %ebx
  8010ff:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801102:	b9 00 00 00 00       	mov    $0x0,%ecx
  801107:	b8 0d 00 00 00       	mov    $0xd,%eax
  80110c:	8b 55 08             	mov    0x8(%ebp),%edx
  80110f:	89 cb                	mov    %ecx,%ebx
  801111:	89 cf                	mov    %ecx,%edi
  801113:	89 ce                	mov    %ecx,%esi
  801115:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801117:	85 c0                	test   %eax,%eax
  801119:	7e 28                	jle    801143 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80111b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80111f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801126:	00 
  801127:	c7 44 24 08 5f 30 80 	movl   $0x80305f,0x8(%esp)
  80112e:	00 
  80112f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801136:	00 
  801137:	c7 04 24 7c 30 80 00 	movl   $0x80307c,(%esp)
  80113e:	e8 63 f2 ff ff       	call   8003a6 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801143:	83 c4 2c             	add    $0x2c,%esp
  801146:	5b                   	pop    %ebx
  801147:	5e                   	pop    %esi
  801148:	5f                   	pop    %edi
  801149:	5d                   	pop    %ebp
  80114a:	c3                   	ret    

0080114b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80114b:	55                   	push   %ebp
  80114c:	89 e5                	mov    %esp,%ebp
  80114e:	57                   	push   %edi
  80114f:	56                   	push   %esi
  801150:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801151:	ba 00 00 00 00       	mov    $0x0,%edx
  801156:	b8 0e 00 00 00       	mov    $0xe,%eax
  80115b:	89 d1                	mov    %edx,%ecx
  80115d:	89 d3                	mov    %edx,%ebx
  80115f:	89 d7                	mov    %edx,%edi
  801161:	89 d6                	mov    %edx,%esi
  801163:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801165:	5b                   	pop    %ebx
  801166:	5e                   	pop    %esi
  801167:	5f                   	pop    %edi
  801168:	5d                   	pop    %ebp
  801169:	c3                   	ret    

0080116a <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  80116a:	55                   	push   %ebp
  80116b:	89 e5                	mov    %esp,%ebp
  80116d:	57                   	push   %edi
  80116e:	56                   	push   %esi
  80116f:	53                   	push   %ebx
  801170:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801173:	bb 00 00 00 00       	mov    $0x0,%ebx
  801178:	b8 0f 00 00 00       	mov    $0xf,%eax
  80117d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801180:	8b 55 08             	mov    0x8(%ebp),%edx
  801183:	89 df                	mov    %ebx,%edi
  801185:	89 de                	mov    %ebx,%esi
  801187:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801189:	85 c0                	test   %eax,%eax
  80118b:	7e 28                	jle    8011b5 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80118d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801191:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801198:	00 
  801199:	c7 44 24 08 5f 30 80 	movl   $0x80305f,0x8(%esp)
  8011a0:	00 
  8011a1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011a8:	00 
  8011a9:	c7 04 24 7c 30 80 00 	movl   $0x80307c,(%esp)
  8011b0:	e8 f1 f1 ff ff       	call   8003a6 <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  8011b5:	83 c4 2c             	add    $0x2c,%esp
  8011b8:	5b                   	pop    %ebx
  8011b9:	5e                   	pop    %esi
  8011ba:	5f                   	pop    %edi
  8011bb:	5d                   	pop    %ebp
  8011bc:	c3                   	ret    

008011bd <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  8011bd:	55                   	push   %ebp
  8011be:	89 e5                	mov    %esp,%ebp
  8011c0:	57                   	push   %edi
  8011c1:	56                   	push   %esi
  8011c2:	53                   	push   %ebx
  8011c3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011cb:	b8 10 00 00 00       	mov    $0x10,%eax
  8011d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d6:	89 df                	mov    %ebx,%edi
  8011d8:	89 de                	mov    %ebx,%esi
  8011da:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	7e 28                	jle    801208 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011e0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011e4:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  8011eb:	00 
  8011ec:	c7 44 24 08 5f 30 80 	movl   $0x80305f,0x8(%esp)
  8011f3:	00 
  8011f4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011fb:	00 
  8011fc:	c7 04 24 7c 30 80 00 	movl   $0x80307c,(%esp)
  801203:	e8 9e f1 ff ff       	call   8003a6 <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  801208:	83 c4 2c             	add    $0x2c,%esp
  80120b:	5b                   	pop    %ebx
  80120c:	5e                   	pop    %esi
  80120d:	5f                   	pop    %edi
  80120e:	5d                   	pop    %ebp
  80120f:	c3                   	ret    

00801210 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	56                   	push   %esi
  801214:	53                   	push   %ebx
  801215:	83 ec 20             	sub    $0x20,%esp
  801218:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80121b:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if(!(err & FEC_WR)) {
  80121d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801221:	75 20                	jne    801243 <pgfault+0x33>
		panic("0x%x Not a write", addr);
  801223:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801227:	c7 44 24 08 8a 30 80 	movl   $0x80308a,0x8(%esp)
  80122e:	00 
  80122f:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801236:	00 
  801237:	c7 04 24 9b 30 80 00 	movl   $0x80309b,(%esp)
  80123e:	e8 63 f1 ff ff       	call   8003a6 <_panic>
	}

	if(!(uvpt[PGNUM(addr)] & PTE_COW)) {
  801243:	89 f0                	mov    %esi,%eax
  801245:	c1 e8 0c             	shr    $0xc,%eax
  801248:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80124f:	f6 c4 08             	test   $0x8,%ah
  801252:	75 1c                	jne    801270 <pgfault+0x60>
		panic("Not a COW page");
  801254:	c7 44 24 08 a6 30 80 	movl   $0x8030a6,0x8(%esp)
  80125b:	00 
  80125c:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  801263:	00 
  801264:	c7 04 24 9b 30 80 00 	movl   $0x80309b,(%esp)
  80126b:	e8 36 f1 ff ff       	call   8003a6 <_panic>

	// Allocate a new page, map it at a temporary location (PFTEMP), // copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	envid_t envid = sys_getenvid();
  801270:	e8 30 fc ff ff       	call   800ea5 <sys_getenvid>
  801275:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, PFTEMP, PTE_W | PTE_U | PTE_P);
  801277:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80127e:	00 
  80127f:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801286:	00 
  801287:	89 04 24             	mov    %eax,(%esp)
  80128a:	e8 54 fc ff ff       	call   800ee3 <sys_page_alloc>
	if(r < 0) {
  80128f:	85 c0                	test   %eax,%eax
  801291:	79 1c                	jns    8012af <pgfault+0x9f>
		panic("couldn't allocate page");
  801293:	c7 44 24 08 b5 30 80 	movl   $0x8030b5,0x8(%esp)
  80129a:	00 
  80129b:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8012a2:	00 
  8012a3:	c7 04 24 9b 30 80 00 	movl   $0x80309b,(%esp)
  8012aa:	e8 f7 f0 ff ff       	call   8003a6 <_panic>
	}

	memmove(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  8012af:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  8012b5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8012bc:	00 
  8012bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012c1:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8012c8:	e8 97 f9 ff ff       	call   800c64 <memmove>

	r = sys_page_map(envid, PFTEMP, envid, ROUNDDOWN(addr,PGSIZE), PTE_P | PTE_U | PTE_W);
  8012cd:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8012d4:	00 
  8012d5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012dd:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8012e4:	00 
  8012e5:	89 1c 24             	mov    %ebx,(%esp)
  8012e8:	e8 4a fc ff ff       	call   800f37 <sys_page_map>
	if(r < 0) {
  8012ed:	85 c0                	test   %eax,%eax
  8012ef:	79 1c                	jns    80130d <pgfault+0xfd>
		panic("couldn't map page");
  8012f1:	c7 44 24 08 cc 30 80 	movl   $0x8030cc,0x8(%esp)
  8012f8:	00 
  8012f9:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  801300:	00 
  801301:	c7 04 24 9b 30 80 00 	movl   $0x80309b,(%esp)
  801308:	e8 99 f0 ff ff       	call   8003a6 <_panic>
	}
}
  80130d:	83 c4 20             	add    $0x20,%esp
  801310:	5b                   	pop    %ebx
  801311:	5e                   	pop    %esi
  801312:	5d                   	pop    %ebp
  801313:	c3                   	ret    

00801314 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801314:	55                   	push   %ebp
  801315:	89 e5                	mov    %esp,%ebp
  801317:	57                   	push   %edi
  801318:	56                   	push   %esi
  801319:	53                   	push   %ebx
  80131a:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envid;
	uintptr_t addr;
	int r = 0;

	set_pgfault_handler(pgfault);
  80131d:	c7 04 24 10 12 80 00 	movl   $0x801210,(%esp)
  801324:	e8 cd 15 00 00       	call   8028f6 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801329:	b8 07 00 00 00       	mov    $0x7,%eax
  80132e:	cd 30                	int    $0x30
  801330:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801333:	89 45 d8             	mov    %eax,-0x28(%ebp)

	envid = sys_exofork();
	if(envid == 0) {
  801336:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80133d:	bf 00 00 00 00       	mov    $0x0,%edi
  801342:	85 c0                	test   %eax,%eax
  801344:	75 21                	jne    801367 <fork+0x53>
		thisenv = &envs[ENVX(sys_getenvid())];
  801346:	e8 5a fb ff ff       	call   800ea5 <sys_getenvid>
  80134b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801350:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801353:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801358:	a3 0c 50 80 00       	mov    %eax,0x80500c
		return 0;
  80135d:	b8 00 00 00 00       	mov    $0x0,%eax
  801362:	e9 8d 01 00 00       	jmp    8014f4 <fork+0x1e0>
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
  801367:	89 f8                	mov    %edi,%eax
  801369:	c1 e8 16             	shr    $0x16,%eax
  80136c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801373:	85 c0                	test   %eax,%eax
  801375:	0f 84 02 01 00 00    	je     80147d <fork+0x169>
  80137b:	89 fa                	mov    %edi,%edx
  80137d:	c1 ea 0c             	shr    $0xc,%edx
  801380:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801387:	85 c0                	test   %eax,%eax
  801389:	0f 84 ee 00 00 00    	je     80147d <fork+0x169>
//
static int
duppage(envid_t envid, unsigned pn)
{

	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P)) return 0;
  80138f:	89 d6                	mov    %edx,%esi
  801391:	c1 e6 0c             	shl    $0xc,%esi
  801394:	89 f0                	mov    %esi,%eax
  801396:	c1 e8 16             	shr    $0x16,%eax
  801399:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8013a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a5:	f6 c1 01             	test   $0x1,%cl
  8013a8:	0f 84 cc 00 00 00    	je     80147a <fork+0x166>

	int all_perms = PTE_U | PTE_P | PTE_AVAIL | PTE_W | PTE_COW;
	int orig_perms = uvpt[pn] & all_perms;
  8013ae:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  8013b5:	89 d8                	mov    %ebx,%eax
  8013b7:	25 07 0e 00 00       	and    $0xe07,%eax
  8013bc:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if(!(orig_perms & PTE_P)) return 0;
  8013bf:	89 d8                	mov    %ebx,%eax
  8013c1:	83 e0 01             	and    $0x1,%eax
  8013c4:	0f 84 b0 00 00 00    	je     80147a <fork+0x166>

	int r = 0;
	envid_t curenvid = sys_getenvid();
  8013ca:	e8 d6 fa ff ff       	call   800ea5 <sys_getenvid>
  8013cf:	89 45 dc             	mov    %eax,-0x24(%ebp)


	if(orig_perms & PTE_SHARE) {
  8013d2:	f7 45 e0 00 04 00 00 	testl  $0x400,-0x20(%ebp)
  8013d9:	74 28                	je     801403 <fork+0xef>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms & PTE_SYSCALL));
  8013db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013de:	25 07 0e 00 00       	and    $0xe07,%eax
  8013e3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013e7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013eb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8013ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013f9:	89 04 24             	mov    %eax,(%esp)
  8013fc:	e8 36 fb ff ff       	call   800f37 <sys_page_map>
  801401:	eb 77                	jmp    80147a <fork+0x166>

	} else if(((orig_perms) & PTE_COW) || (orig_perms & PTE_W) ) {
  801403:	f7 c3 02 08 00 00    	test   $0x802,%ebx
  801409:	74 4e                	je     801459 <fork+0x145>
		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  80140b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80140e:	25 fd f7 ff ff       	and    $0xfffff7fd,%eax
  801413:	80 cc 08             	or     $0x8,%ah
  801416:	89 c3                	mov    %eax,%ebx
  801418:	89 44 24 10          	mov    %eax,0x10(%esp)
  80141c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801420:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801423:	89 44 24 08          	mov    %eax,0x8(%esp)
  801427:	89 74 24 04          	mov    %esi,0x4(%esp)
  80142b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80142e:	89 04 24             	mov    %eax,(%esp)
  801431:	e8 01 fb ff ff       	call   800f37 <sys_page_map>
  801436:	89 45 e0             	mov    %eax,-0x20(%ebp)

		r += sys_page_map(curenvid, (void *) (pn*PGSIZE), curenvid, (void *) (pn*PGSIZE), (orig_perms | PTE_COW) & (~PTE_W));
  801439:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80143d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801441:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801444:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801448:	89 74 24 04          	mov    %esi,0x4(%esp)
  80144c:	89 0c 24             	mov    %ecx,(%esp)
  80144f:	e8 e3 fa ff ff       	call   800f37 <sys_page_map>
  801454:	03 45 e0             	add    -0x20(%ebp),%eax
  801457:	eb 21                	jmp    80147a <fork+0x166>

	} else {
		r = sys_page_map(curenvid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), orig_perms);
  801459:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80145c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801460:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801464:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801467:	89 44 24 08          	mov    %eax,0x8(%esp)
  80146b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80146f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801472:	89 04 24             	mov    %eax,(%esp)
  801475:	e8 bd fa ff ff       	call   800f37 <sys_page_map>
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
  80147a:	01 45 e4             	add    %eax,-0x1c(%ebp)
	if(envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for(addr = 0; addr < UTOP - PGSIZE; addr +=PGSIZE) {
  80147d:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801483:	81 ff 00 f0 bf ee    	cmp    $0xeebff000,%edi
  801489:	0f 85 d8 fe ff ff    	jne    801367 <fork+0x53>
		if(uvpd[PDX(addr)] && PTE_P && uvpt[PGNUM(addr)])  {
			r += duppage(envid, PGNUM(addr));
		}
	}

	r+=sys_page_alloc(envid, (void*)UXSTACKTOP - PGSIZE, PTE_P|PTE_U|PTE_W);
  80148f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801496:	00 
  801497:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80149e:	ee 
  80149f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8014a2:	89 34 24             	mov    %esi,(%esp)
  8014a5:	e8 39 fa ff ff       	call   800ee3 <sys_page_alloc>
  8014aa:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8014ad:	01 c3                	add    %eax,%ebx
	r+=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8014af:	c7 44 24 04 43 29 80 	movl   $0x802943,0x4(%esp)
  8014b6:	00 
  8014b7:	89 34 24             	mov    %esi,(%esp)
  8014ba:	e8 c4 fb ff ff       	call   801083 <sys_env_set_pgfault_upcall>
  8014bf:	01 c3                	add    %eax,%ebx
	r+= sys_env_set_status(envid, ENV_RUNNABLE);
  8014c1:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8014c8:	00 
  8014c9:	89 34 24             	mov    %esi,(%esp)
  8014cc:	e8 0c fb ff ff       	call   800fdd <sys_env_set_status>

	if(r<0) {
  8014d1:	01 d8                	add    %ebx,%eax
  8014d3:	79 1c                	jns    8014f1 <fork+0x1dd>
	 panic("fork failed!");
  8014d5:	c7 44 24 08 de 30 80 	movl   $0x8030de,0x8(%esp)
  8014dc:	00 
  8014dd:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  8014e4:	00 
  8014e5:	c7 04 24 9b 30 80 00 	movl   $0x80309b,(%esp)
  8014ec:	e8 b5 ee ff ff       	call   8003a6 <_panic>
	}

	return envid;
  8014f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  8014f4:	83 c4 3c             	add    $0x3c,%esp
  8014f7:	5b                   	pop    %ebx
  8014f8:	5e                   	pop    %esi
  8014f9:	5f                   	pop    %edi
  8014fa:	5d                   	pop    %ebp
  8014fb:	c3                   	ret    

008014fc <sfork>:

// Challenge!
int
sfork(void)
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801502:	c7 44 24 08 eb 30 80 	movl   $0x8030eb,0x8(%esp)
  801509:	00 
  80150a:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
  801511:	00 
  801512:	c7 04 24 9b 30 80 00 	movl   $0x80309b,(%esp)
  801519:	e8 88 ee ff ff       	call   8003a6 <_panic>
  80151e:	66 90                	xchg   %ax,%ax

00801520 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801520:	55                   	push   %ebp
  801521:	89 e5                	mov    %esp,%ebp
  801523:	56                   	push   %esi
  801524:	53                   	push   %ebx
  801525:	83 ec 10             	sub    $0x10,%esp
  801528:	8b 75 08             	mov    0x8(%ebp),%esi
  80152b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80152e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  801531:	85 c0                	test   %eax,%eax
  801533:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801538:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  80153b:	89 04 24             	mov    %eax,(%esp)
  80153e:	e8 b6 fb ff ff       	call   8010f9 <sys_ipc_recv>

	if(ret < 0) {
  801543:	85 c0                	test   %eax,%eax
  801545:	79 16                	jns    80155d <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  801547:	85 f6                	test   %esi,%esi
  801549:	74 06                	je     801551 <ipc_recv+0x31>
  80154b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  801551:	85 db                	test   %ebx,%ebx
  801553:	74 3e                	je     801593 <ipc_recv+0x73>
  801555:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80155b:	eb 36                	jmp    801593 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  80155d:	e8 43 f9 ff ff       	call   800ea5 <sys_getenvid>
  801562:	25 ff 03 00 00       	and    $0x3ff,%eax
  801567:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80156a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80156f:	a3 0c 50 80 00       	mov    %eax,0x80500c

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801574:	85 f6                	test   %esi,%esi
  801576:	74 05                	je     80157d <ipc_recv+0x5d>
  801578:	8b 40 74             	mov    0x74(%eax),%eax
  80157b:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80157d:	85 db                	test   %ebx,%ebx
  80157f:	74 0a                	je     80158b <ipc_recv+0x6b>
  801581:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801586:	8b 40 78             	mov    0x78(%eax),%eax
  801589:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  80158b:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801590:	8b 40 70             	mov    0x70(%eax),%eax
}
  801593:	83 c4 10             	add    $0x10,%esp
  801596:	5b                   	pop    %ebx
  801597:	5e                   	pop    %esi
  801598:	5d                   	pop    %ebp
  801599:	c3                   	ret    

0080159a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80159a:	55                   	push   %ebp
  80159b:	89 e5                	mov    %esp,%ebp
  80159d:	57                   	push   %edi
  80159e:	56                   	push   %esi
  80159f:	53                   	push   %ebx
  8015a0:	83 ec 1c             	sub    $0x1c,%esp
  8015a3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015a6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8015a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  8015ac:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  8015ae:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8015b3:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  8015b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015bd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015c5:	89 3c 24             	mov    %edi,(%esp)
  8015c8:	e8 09 fb ff ff       	call   8010d6 <sys_ipc_try_send>

		if(ret >= 0) break;
  8015cd:	85 c0                	test   %eax,%eax
  8015cf:	79 2c                	jns    8015fd <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  8015d1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8015d4:	74 20                	je     8015f6 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  8015d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015da:	c7 44 24 08 04 31 80 	movl   $0x803104,0x8(%esp)
  8015e1:	00 
  8015e2:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8015e9:	00 
  8015ea:	c7 04 24 34 31 80 00 	movl   $0x803134,(%esp)
  8015f1:	e8 b0 ed ff ff       	call   8003a6 <_panic>
		}
		sys_yield();
  8015f6:	e8 c9 f8 ff ff       	call   800ec4 <sys_yield>
	}
  8015fb:	eb b9                	jmp    8015b6 <ipc_send+0x1c>
}
  8015fd:	83 c4 1c             	add    $0x1c,%esp
  801600:	5b                   	pop    %ebx
  801601:	5e                   	pop    %esi
  801602:	5f                   	pop    %edi
  801603:	5d                   	pop    %ebp
  801604:	c3                   	ret    

00801605 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801605:	55                   	push   %ebp
  801606:	89 e5                	mov    %esp,%ebp
  801608:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80160b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801610:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801613:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801619:	8b 52 50             	mov    0x50(%edx),%edx
  80161c:	39 ca                	cmp    %ecx,%edx
  80161e:	75 0d                	jne    80162d <ipc_find_env+0x28>
			return envs[i].env_id;
  801620:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801623:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801628:	8b 40 40             	mov    0x40(%eax),%eax
  80162b:	eb 0e                	jmp    80163b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80162d:	83 c0 01             	add    $0x1,%eax
  801630:	3d 00 04 00 00       	cmp    $0x400,%eax
  801635:	75 d9                	jne    801610 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801637:	66 b8 00 00          	mov    $0x0,%ax
}
  80163b:	5d                   	pop    %ebp
  80163c:	c3                   	ret    
  80163d:	66 90                	xchg   %ax,%ax
  80163f:	90                   	nop

00801640 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801640:	55                   	push   %ebp
  801641:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801643:	8b 45 08             	mov    0x8(%ebp),%eax
  801646:	05 00 00 00 30       	add    $0x30000000,%eax
  80164b:	c1 e8 0c             	shr    $0xc,%eax
}
  80164e:	5d                   	pop    %ebp
  80164f:	c3                   	ret    

00801650 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801653:	8b 45 08             	mov    0x8(%ebp),%eax
  801656:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80165b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801660:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801665:	5d                   	pop    %ebp
  801666:	c3                   	ret    

00801667 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801667:	55                   	push   %ebp
  801668:	89 e5                	mov    %esp,%ebp
  80166a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80166d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801672:	89 c2                	mov    %eax,%edx
  801674:	c1 ea 16             	shr    $0x16,%edx
  801677:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80167e:	f6 c2 01             	test   $0x1,%dl
  801681:	74 11                	je     801694 <fd_alloc+0x2d>
  801683:	89 c2                	mov    %eax,%edx
  801685:	c1 ea 0c             	shr    $0xc,%edx
  801688:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80168f:	f6 c2 01             	test   $0x1,%dl
  801692:	75 09                	jne    80169d <fd_alloc+0x36>
			*fd_store = fd;
  801694:	89 01                	mov    %eax,(%ecx)
			return 0;
  801696:	b8 00 00 00 00       	mov    $0x0,%eax
  80169b:	eb 17                	jmp    8016b4 <fd_alloc+0x4d>
  80169d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8016a2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8016a7:	75 c9                	jne    801672 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8016a9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8016af:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8016b4:	5d                   	pop    %ebp
  8016b5:	c3                   	ret    

008016b6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8016bc:	83 f8 1f             	cmp    $0x1f,%eax
  8016bf:	77 36                	ja     8016f7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8016c1:	c1 e0 0c             	shl    $0xc,%eax
  8016c4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8016c9:	89 c2                	mov    %eax,%edx
  8016cb:	c1 ea 16             	shr    $0x16,%edx
  8016ce:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8016d5:	f6 c2 01             	test   $0x1,%dl
  8016d8:	74 24                	je     8016fe <fd_lookup+0x48>
  8016da:	89 c2                	mov    %eax,%edx
  8016dc:	c1 ea 0c             	shr    $0xc,%edx
  8016df:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016e6:	f6 c2 01             	test   $0x1,%dl
  8016e9:	74 1a                	je     801705 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8016eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016ee:	89 02                	mov    %eax,(%edx)
	return 0;
  8016f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8016f5:	eb 13                	jmp    80170a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8016f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016fc:	eb 0c                	jmp    80170a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8016fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801703:	eb 05                	jmp    80170a <fd_lookup+0x54>
  801705:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80170a:	5d                   	pop    %ebp
  80170b:	c3                   	ret    

0080170c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	83 ec 18             	sub    $0x18,%esp
  801712:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801715:	ba 00 00 00 00       	mov    $0x0,%edx
  80171a:	eb 13                	jmp    80172f <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  80171c:	39 08                	cmp    %ecx,(%eax)
  80171e:	75 0c                	jne    80172c <dev_lookup+0x20>
			*dev = devtab[i];
  801720:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801723:	89 01                	mov    %eax,(%ecx)
			return 0;
  801725:	b8 00 00 00 00       	mov    $0x0,%eax
  80172a:	eb 38                	jmp    801764 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80172c:	83 c2 01             	add    $0x1,%edx
  80172f:	8b 04 95 c0 31 80 00 	mov    0x8031c0(,%edx,4),%eax
  801736:	85 c0                	test   %eax,%eax
  801738:	75 e2                	jne    80171c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80173a:	a1 0c 50 80 00       	mov    0x80500c,%eax
  80173f:	8b 40 48             	mov    0x48(%eax),%eax
  801742:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801746:	89 44 24 04          	mov    %eax,0x4(%esp)
  80174a:	c7 04 24 40 31 80 00 	movl   $0x803140,(%esp)
  801751:	e8 49 ed ff ff       	call   80049f <cprintf>
	*dev = 0;
  801756:	8b 45 0c             	mov    0xc(%ebp),%eax
  801759:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80175f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801764:	c9                   	leave  
  801765:	c3                   	ret    

00801766 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801766:	55                   	push   %ebp
  801767:	89 e5                	mov    %esp,%ebp
  801769:	56                   	push   %esi
  80176a:	53                   	push   %ebx
  80176b:	83 ec 20             	sub    $0x20,%esp
  80176e:	8b 75 08             	mov    0x8(%ebp),%esi
  801771:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801774:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801777:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80177b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801781:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801784:	89 04 24             	mov    %eax,(%esp)
  801787:	e8 2a ff ff ff       	call   8016b6 <fd_lookup>
  80178c:	85 c0                	test   %eax,%eax
  80178e:	78 05                	js     801795 <fd_close+0x2f>
	    || fd != fd2)
  801790:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801793:	74 0c                	je     8017a1 <fd_close+0x3b>
		return (must_exist ? r : 0);
  801795:	84 db                	test   %bl,%bl
  801797:	ba 00 00 00 00       	mov    $0x0,%edx
  80179c:	0f 44 c2             	cmove  %edx,%eax
  80179f:	eb 3f                	jmp    8017e0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8017a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a8:	8b 06                	mov    (%esi),%eax
  8017aa:	89 04 24             	mov    %eax,(%esp)
  8017ad:	e8 5a ff ff ff       	call   80170c <dev_lookup>
  8017b2:	89 c3                	mov    %eax,%ebx
  8017b4:	85 c0                	test   %eax,%eax
  8017b6:	78 16                	js     8017ce <fd_close+0x68>
		if (dev->dev_close)
  8017b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017bb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8017be:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8017c3:	85 c0                	test   %eax,%eax
  8017c5:	74 07                	je     8017ce <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8017c7:	89 34 24             	mov    %esi,(%esp)
  8017ca:	ff d0                	call   *%eax
  8017cc:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8017ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017d9:	e8 ac f7 ff ff       	call   800f8a <sys_page_unmap>
	return r;
  8017de:	89 d8                	mov    %ebx,%eax
}
  8017e0:	83 c4 20             	add    $0x20,%esp
  8017e3:	5b                   	pop    %ebx
  8017e4:	5e                   	pop    %esi
  8017e5:	5d                   	pop    %ebp
  8017e6:	c3                   	ret    

008017e7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f7:	89 04 24             	mov    %eax,(%esp)
  8017fa:	e8 b7 fe ff ff       	call   8016b6 <fd_lookup>
  8017ff:	89 c2                	mov    %eax,%edx
  801801:	85 d2                	test   %edx,%edx
  801803:	78 13                	js     801818 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801805:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80180c:	00 
  80180d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801810:	89 04 24             	mov    %eax,(%esp)
  801813:	e8 4e ff ff ff       	call   801766 <fd_close>
}
  801818:	c9                   	leave  
  801819:	c3                   	ret    

0080181a <close_all>:

void
close_all(void)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	53                   	push   %ebx
  80181e:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801821:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801826:	89 1c 24             	mov    %ebx,(%esp)
  801829:	e8 b9 ff ff ff       	call   8017e7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80182e:	83 c3 01             	add    $0x1,%ebx
  801831:	83 fb 20             	cmp    $0x20,%ebx
  801834:	75 f0                	jne    801826 <close_all+0xc>
		close(i);
}
  801836:	83 c4 14             	add    $0x14,%esp
  801839:	5b                   	pop    %ebx
  80183a:	5d                   	pop    %ebp
  80183b:	c3                   	ret    

0080183c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80183c:	55                   	push   %ebp
  80183d:	89 e5                	mov    %esp,%ebp
  80183f:	57                   	push   %edi
  801840:	56                   	push   %esi
  801841:	53                   	push   %ebx
  801842:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801845:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801848:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184c:	8b 45 08             	mov    0x8(%ebp),%eax
  80184f:	89 04 24             	mov    %eax,(%esp)
  801852:	e8 5f fe ff ff       	call   8016b6 <fd_lookup>
  801857:	89 c2                	mov    %eax,%edx
  801859:	85 d2                	test   %edx,%edx
  80185b:	0f 88 e1 00 00 00    	js     801942 <dup+0x106>
		return r;
	close(newfdnum);
  801861:	8b 45 0c             	mov    0xc(%ebp),%eax
  801864:	89 04 24             	mov    %eax,(%esp)
  801867:	e8 7b ff ff ff       	call   8017e7 <close>

	newfd = INDEX2FD(newfdnum);
  80186c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80186f:	c1 e3 0c             	shl    $0xc,%ebx
  801872:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801878:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80187b:	89 04 24             	mov    %eax,(%esp)
  80187e:	e8 cd fd ff ff       	call   801650 <fd2data>
  801883:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801885:	89 1c 24             	mov    %ebx,(%esp)
  801888:	e8 c3 fd ff ff       	call   801650 <fd2data>
  80188d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80188f:	89 f0                	mov    %esi,%eax
  801891:	c1 e8 16             	shr    $0x16,%eax
  801894:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80189b:	a8 01                	test   $0x1,%al
  80189d:	74 43                	je     8018e2 <dup+0xa6>
  80189f:	89 f0                	mov    %esi,%eax
  8018a1:	c1 e8 0c             	shr    $0xc,%eax
  8018a4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8018ab:	f6 c2 01             	test   $0x1,%dl
  8018ae:	74 32                	je     8018e2 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8018b0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018b7:	25 07 0e 00 00       	and    $0xe07,%eax
  8018bc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8018c0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8018c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018cb:	00 
  8018cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018d7:	e8 5b f6 ff ff       	call   800f37 <sys_page_map>
  8018dc:	89 c6                	mov    %eax,%esi
  8018de:	85 c0                	test   %eax,%eax
  8018e0:	78 3e                	js     801920 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8018e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018e5:	89 c2                	mov    %eax,%edx
  8018e7:	c1 ea 0c             	shr    $0xc,%edx
  8018ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8018f1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8018f7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8018fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8018ff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801906:	00 
  801907:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801912:	e8 20 f6 ff ff       	call   800f37 <sys_page_map>
  801917:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801919:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80191c:	85 f6                	test   %esi,%esi
  80191e:	79 22                	jns    801942 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801920:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801924:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80192b:	e8 5a f6 ff ff       	call   800f8a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801930:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801934:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80193b:	e8 4a f6 ff ff       	call   800f8a <sys_page_unmap>
	return r;
  801940:	89 f0                	mov    %esi,%eax
}
  801942:	83 c4 3c             	add    $0x3c,%esp
  801945:	5b                   	pop    %ebx
  801946:	5e                   	pop    %esi
  801947:	5f                   	pop    %edi
  801948:	5d                   	pop    %ebp
  801949:	c3                   	ret    

0080194a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80194a:	55                   	push   %ebp
  80194b:	89 e5                	mov    %esp,%ebp
  80194d:	53                   	push   %ebx
  80194e:	83 ec 24             	sub    $0x24,%esp
  801951:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801954:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801957:	89 44 24 04          	mov    %eax,0x4(%esp)
  80195b:	89 1c 24             	mov    %ebx,(%esp)
  80195e:	e8 53 fd ff ff       	call   8016b6 <fd_lookup>
  801963:	89 c2                	mov    %eax,%edx
  801965:	85 d2                	test   %edx,%edx
  801967:	78 6d                	js     8019d6 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801969:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80196c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801970:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801973:	8b 00                	mov    (%eax),%eax
  801975:	89 04 24             	mov    %eax,(%esp)
  801978:	e8 8f fd ff ff       	call   80170c <dev_lookup>
  80197d:	85 c0                	test   %eax,%eax
  80197f:	78 55                	js     8019d6 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801981:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801984:	8b 50 08             	mov    0x8(%eax),%edx
  801987:	83 e2 03             	and    $0x3,%edx
  80198a:	83 fa 01             	cmp    $0x1,%edx
  80198d:	75 23                	jne    8019b2 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80198f:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801994:	8b 40 48             	mov    0x48(%eax),%eax
  801997:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80199b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199f:	c7 04 24 84 31 80 00 	movl   $0x803184,(%esp)
  8019a6:	e8 f4 ea ff ff       	call   80049f <cprintf>
		return -E_INVAL;
  8019ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019b0:	eb 24                	jmp    8019d6 <read+0x8c>
	}
	if (!dev->dev_read)
  8019b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019b5:	8b 52 08             	mov    0x8(%edx),%edx
  8019b8:	85 d2                	test   %edx,%edx
  8019ba:	74 15                	je     8019d1 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8019bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8019bf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8019c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019c6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019ca:	89 04 24             	mov    %eax,(%esp)
  8019cd:	ff d2                	call   *%edx
  8019cf:	eb 05                	jmp    8019d6 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8019d1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8019d6:	83 c4 24             	add    $0x24,%esp
  8019d9:	5b                   	pop    %ebx
  8019da:	5d                   	pop    %ebp
  8019db:	c3                   	ret    

008019dc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	57                   	push   %edi
  8019e0:	56                   	push   %esi
  8019e1:	53                   	push   %ebx
  8019e2:	83 ec 1c             	sub    $0x1c,%esp
  8019e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019e8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019f0:	eb 23                	jmp    801a15 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8019f2:	89 f0                	mov    %esi,%eax
  8019f4:	29 d8                	sub    %ebx,%eax
  8019f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019fa:	89 d8                	mov    %ebx,%eax
  8019fc:	03 45 0c             	add    0xc(%ebp),%eax
  8019ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a03:	89 3c 24             	mov    %edi,(%esp)
  801a06:	e8 3f ff ff ff       	call   80194a <read>
		if (m < 0)
  801a0b:	85 c0                	test   %eax,%eax
  801a0d:	78 10                	js     801a1f <readn+0x43>
			return m;
		if (m == 0)
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	74 0a                	je     801a1d <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a13:	01 c3                	add    %eax,%ebx
  801a15:	39 f3                	cmp    %esi,%ebx
  801a17:	72 d9                	jb     8019f2 <readn+0x16>
  801a19:	89 d8                	mov    %ebx,%eax
  801a1b:	eb 02                	jmp    801a1f <readn+0x43>
  801a1d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801a1f:	83 c4 1c             	add    $0x1c,%esp
  801a22:	5b                   	pop    %ebx
  801a23:	5e                   	pop    %esi
  801a24:	5f                   	pop    %edi
  801a25:	5d                   	pop    %ebp
  801a26:	c3                   	ret    

00801a27 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801a27:	55                   	push   %ebp
  801a28:	89 e5                	mov    %esp,%ebp
  801a2a:	53                   	push   %ebx
  801a2b:	83 ec 24             	sub    $0x24,%esp
  801a2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a31:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a34:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a38:	89 1c 24             	mov    %ebx,(%esp)
  801a3b:	e8 76 fc ff ff       	call   8016b6 <fd_lookup>
  801a40:	89 c2                	mov    %eax,%edx
  801a42:	85 d2                	test   %edx,%edx
  801a44:	78 68                	js     801aae <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a46:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a49:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a50:	8b 00                	mov    (%eax),%eax
  801a52:	89 04 24             	mov    %eax,(%esp)
  801a55:	e8 b2 fc ff ff       	call   80170c <dev_lookup>
  801a5a:	85 c0                	test   %eax,%eax
  801a5c:	78 50                	js     801aae <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a61:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a65:	75 23                	jne    801a8a <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801a67:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801a6c:	8b 40 48             	mov    0x48(%eax),%eax
  801a6f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a73:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a77:	c7 04 24 a0 31 80 00 	movl   $0x8031a0,(%esp)
  801a7e:	e8 1c ea ff ff       	call   80049f <cprintf>
		return -E_INVAL;
  801a83:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a88:	eb 24                	jmp    801aae <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801a8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a8d:	8b 52 0c             	mov    0xc(%edx),%edx
  801a90:	85 d2                	test   %edx,%edx
  801a92:	74 15                	je     801aa9 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801a94:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a97:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a9e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801aa2:	89 04 24             	mov    %eax,(%esp)
  801aa5:	ff d2                	call   *%edx
  801aa7:	eb 05                	jmp    801aae <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801aa9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801aae:	83 c4 24             	add    $0x24,%esp
  801ab1:	5b                   	pop    %ebx
  801ab2:	5d                   	pop    %ebp
  801ab3:	c3                   	ret    

00801ab4 <seek>:

int
seek(int fdnum, off_t offset)
{
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
  801ab7:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aba:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801abd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac4:	89 04 24             	mov    %eax,(%esp)
  801ac7:	e8 ea fb ff ff       	call   8016b6 <fd_lookup>
  801acc:	85 c0                	test   %eax,%eax
  801ace:	78 0e                	js     801ade <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801ad0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801ad3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ad6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801ad9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ade:	c9                   	leave  
  801adf:	c3                   	ret    

00801ae0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	53                   	push   %ebx
  801ae4:	83 ec 24             	sub    $0x24,%esp
  801ae7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801aea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aed:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af1:	89 1c 24             	mov    %ebx,(%esp)
  801af4:	e8 bd fb ff ff       	call   8016b6 <fd_lookup>
  801af9:	89 c2                	mov    %eax,%edx
  801afb:	85 d2                	test   %edx,%edx
  801afd:	78 61                	js     801b60 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801aff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b02:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b06:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b09:	8b 00                	mov    (%eax),%eax
  801b0b:	89 04 24             	mov    %eax,(%esp)
  801b0e:	e8 f9 fb ff ff       	call   80170c <dev_lookup>
  801b13:	85 c0                	test   %eax,%eax
  801b15:	78 49                	js     801b60 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b17:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b1a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801b1e:	75 23                	jne    801b43 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801b20:	a1 0c 50 80 00       	mov    0x80500c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801b25:	8b 40 48             	mov    0x48(%eax),%eax
  801b28:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b30:	c7 04 24 60 31 80 00 	movl   $0x803160,(%esp)
  801b37:	e8 63 e9 ff ff       	call   80049f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801b3c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b41:	eb 1d                	jmp    801b60 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801b43:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b46:	8b 52 18             	mov    0x18(%edx),%edx
  801b49:	85 d2                	test   %edx,%edx
  801b4b:	74 0e                	je     801b5b <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801b4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b50:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b54:	89 04 24             	mov    %eax,(%esp)
  801b57:	ff d2                	call   *%edx
  801b59:	eb 05                	jmp    801b60 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801b5b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801b60:	83 c4 24             	add    $0x24,%esp
  801b63:	5b                   	pop    %ebx
  801b64:	5d                   	pop    %ebp
  801b65:	c3                   	ret    

00801b66 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801b66:	55                   	push   %ebp
  801b67:	89 e5                	mov    %esp,%ebp
  801b69:	53                   	push   %ebx
  801b6a:	83 ec 24             	sub    $0x24,%esp
  801b6d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b70:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b73:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b77:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7a:	89 04 24             	mov    %eax,(%esp)
  801b7d:	e8 34 fb ff ff       	call   8016b6 <fd_lookup>
  801b82:	89 c2                	mov    %eax,%edx
  801b84:	85 d2                	test   %edx,%edx
  801b86:	78 52                	js     801bda <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b88:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b92:	8b 00                	mov    (%eax),%eax
  801b94:	89 04 24             	mov    %eax,(%esp)
  801b97:	e8 70 fb ff ff       	call   80170c <dev_lookup>
  801b9c:	85 c0                	test   %eax,%eax
  801b9e:	78 3a                	js     801bda <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801ba7:	74 2c                	je     801bd5 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801ba9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801bac:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801bb3:	00 00 00 
	stat->st_isdir = 0;
  801bb6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bbd:	00 00 00 
	stat->st_dev = dev;
  801bc0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801bc6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bca:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bcd:	89 14 24             	mov    %edx,(%esp)
  801bd0:	ff 50 14             	call   *0x14(%eax)
  801bd3:	eb 05                	jmp    801bda <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801bd5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801bda:	83 c4 24             	add    $0x24,%esp
  801bdd:	5b                   	pop    %ebx
  801bde:	5d                   	pop    %ebp
  801bdf:	c3                   	ret    

00801be0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801be0:	55                   	push   %ebp
  801be1:	89 e5                	mov    %esp,%ebp
  801be3:	56                   	push   %esi
  801be4:	53                   	push   %ebx
  801be5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801be8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bef:	00 
  801bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf3:	89 04 24             	mov    %eax,(%esp)
  801bf6:	e8 28 02 00 00       	call   801e23 <open>
  801bfb:	89 c3                	mov    %eax,%ebx
  801bfd:	85 db                	test   %ebx,%ebx
  801bff:	78 1b                	js     801c1c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801c01:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c04:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c08:	89 1c 24             	mov    %ebx,(%esp)
  801c0b:	e8 56 ff ff ff       	call   801b66 <fstat>
  801c10:	89 c6                	mov    %eax,%esi
	close(fd);
  801c12:	89 1c 24             	mov    %ebx,(%esp)
  801c15:	e8 cd fb ff ff       	call   8017e7 <close>
	return r;
  801c1a:	89 f0                	mov    %esi,%eax
}
  801c1c:	83 c4 10             	add    $0x10,%esp
  801c1f:	5b                   	pop    %ebx
  801c20:	5e                   	pop    %esi
  801c21:	5d                   	pop    %ebp
  801c22:	c3                   	ret    

00801c23 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801c23:	55                   	push   %ebp
  801c24:	89 e5                	mov    %esp,%ebp
  801c26:	56                   	push   %esi
  801c27:	53                   	push   %ebx
  801c28:	83 ec 10             	sub    $0x10,%esp
  801c2b:	89 c6                	mov    %eax,%esi
  801c2d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801c2f:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801c36:	75 11                	jne    801c49 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c38:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801c3f:	e8 c1 f9 ff ff       	call   801605 <ipc_find_env>
  801c44:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801c49:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c50:	00 
  801c51:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801c58:	00 
  801c59:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c5d:	a1 04 50 80 00       	mov    0x805004,%eax
  801c62:	89 04 24             	mov    %eax,(%esp)
  801c65:	e8 30 f9 ff ff       	call   80159a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801c6a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c71:	00 
  801c72:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c76:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c7d:	e8 9e f8 ff ff       	call   801520 <ipc_recv>
}
  801c82:	83 c4 10             	add    $0x10,%esp
  801c85:	5b                   	pop    %ebx
  801c86:	5e                   	pop    %esi
  801c87:	5d                   	pop    %ebp
  801c88:	c3                   	ret    

00801c89 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801c89:	55                   	push   %ebp
  801c8a:	89 e5                	mov    %esp,%ebp
  801c8c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801c8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c92:	8b 40 0c             	mov    0xc(%eax),%eax
  801c95:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801c9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c9d:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801ca2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ca7:	b8 02 00 00 00       	mov    $0x2,%eax
  801cac:	e8 72 ff ff ff       	call   801c23 <fsipc>
}
  801cb1:	c9                   	leave  
  801cb2:	c3                   	ret    

00801cb3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801cb3:	55                   	push   %ebp
  801cb4:	89 e5                	mov    %esp,%ebp
  801cb6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801cb9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbc:	8b 40 0c             	mov    0xc(%eax),%eax
  801cbf:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801cc4:	ba 00 00 00 00       	mov    $0x0,%edx
  801cc9:	b8 06 00 00 00       	mov    $0x6,%eax
  801cce:	e8 50 ff ff ff       	call   801c23 <fsipc>
}
  801cd3:	c9                   	leave  
  801cd4:	c3                   	ret    

00801cd5 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
  801cd8:	53                   	push   %ebx
  801cd9:	83 ec 14             	sub    $0x14,%esp
  801cdc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce2:	8b 40 0c             	mov    0xc(%eax),%eax
  801ce5:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801cea:	ba 00 00 00 00       	mov    $0x0,%edx
  801cef:	b8 05 00 00 00       	mov    $0x5,%eax
  801cf4:	e8 2a ff ff ff       	call   801c23 <fsipc>
  801cf9:	89 c2                	mov    %eax,%edx
  801cfb:	85 d2                	test   %edx,%edx
  801cfd:	78 2b                	js     801d2a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801cff:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801d06:	00 
  801d07:	89 1c 24             	mov    %ebx,(%esp)
  801d0a:	e8 b8 ed ff ff       	call   800ac7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d0f:	a1 80 60 80 00       	mov    0x806080,%eax
  801d14:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801d1a:	a1 84 60 80 00       	mov    0x806084,%eax
  801d1f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801d25:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d2a:	83 c4 14             	add    $0x14,%esp
  801d2d:	5b                   	pop    %ebx
  801d2e:	5d                   	pop    %ebp
  801d2f:	c3                   	ret    

00801d30 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801d30:	55                   	push   %ebp
  801d31:	89 e5                	mov    %esp,%ebp
  801d33:	83 ec 18             	sub    $0x18,%esp
  801d36:	8b 45 10             	mov    0x10(%ebp),%eax
  801d39:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801d3e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801d43:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801d46:	8b 55 08             	mov    0x8(%ebp),%edx
  801d49:	8b 52 0c             	mov    0xc(%edx),%edx
  801d4c:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801d52:	a3 04 60 80 00       	mov    %eax,0x806004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801d57:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d62:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801d69:	e8 f6 ee ff ff       	call   800c64 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  801d6e:	ba 00 00 00 00       	mov    $0x0,%edx
  801d73:	b8 04 00 00 00       	mov    $0x4,%eax
  801d78:	e8 a6 fe ff ff       	call   801c23 <fsipc>
}
  801d7d:	c9                   	leave  
  801d7e:	c3                   	ret    

00801d7f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801d7f:	55                   	push   %ebp
  801d80:	89 e5                	mov    %esp,%ebp
  801d82:	56                   	push   %esi
  801d83:	53                   	push   %ebx
  801d84:	83 ec 10             	sub    $0x10,%esp
  801d87:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8d:	8b 40 0c             	mov    0xc(%eax),%eax
  801d90:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801d95:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801d9b:	ba 00 00 00 00       	mov    $0x0,%edx
  801da0:	b8 03 00 00 00       	mov    $0x3,%eax
  801da5:	e8 79 fe ff ff       	call   801c23 <fsipc>
  801daa:	89 c3                	mov    %eax,%ebx
  801dac:	85 c0                	test   %eax,%eax
  801dae:	78 6a                	js     801e1a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801db0:	39 c6                	cmp    %eax,%esi
  801db2:	73 24                	jae    801dd8 <devfile_read+0x59>
  801db4:	c7 44 24 0c d4 31 80 	movl   $0x8031d4,0xc(%esp)
  801dbb:	00 
  801dbc:	c7 44 24 08 db 31 80 	movl   $0x8031db,0x8(%esp)
  801dc3:	00 
  801dc4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801dcb:	00 
  801dcc:	c7 04 24 f0 31 80 00 	movl   $0x8031f0,(%esp)
  801dd3:	e8 ce e5 ff ff       	call   8003a6 <_panic>
	assert(r <= PGSIZE);
  801dd8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ddd:	7e 24                	jle    801e03 <devfile_read+0x84>
  801ddf:	c7 44 24 0c fb 31 80 	movl   $0x8031fb,0xc(%esp)
  801de6:	00 
  801de7:	c7 44 24 08 db 31 80 	movl   $0x8031db,0x8(%esp)
  801dee:	00 
  801def:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801df6:	00 
  801df7:	c7 04 24 f0 31 80 00 	movl   $0x8031f0,(%esp)
  801dfe:	e8 a3 e5 ff ff       	call   8003a6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801e03:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e07:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e0e:	00 
  801e0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e12:	89 04 24             	mov    %eax,(%esp)
  801e15:	e8 4a ee ff ff       	call   800c64 <memmove>
	return r;
}
  801e1a:	89 d8                	mov    %ebx,%eax
  801e1c:	83 c4 10             	add    $0x10,%esp
  801e1f:	5b                   	pop    %ebx
  801e20:	5e                   	pop    %esi
  801e21:	5d                   	pop    %ebp
  801e22:	c3                   	ret    

00801e23 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e23:	55                   	push   %ebp
  801e24:	89 e5                	mov    %esp,%ebp
  801e26:	53                   	push   %ebx
  801e27:	83 ec 24             	sub    $0x24,%esp
  801e2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801e2d:	89 1c 24             	mov    %ebx,(%esp)
  801e30:	e8 5b ec ff ff       	call   800a90 <strlen>
  801e35:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801e3a:	7f 60                	jg     801e9c <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801e3c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e3f:	89 04 24             	mov    %eax,(%esp)
  801e42:	e8 20 f8 ff ff       	call   801667 <fd_alloc>
  801e47:	89 c2                	mov    %eax,%edx
  801e49:	85 d2                	test   %edx,%edx
  801e4b:	78 54                	js     801ea1 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801e4d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e51:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801e58:	e8 6a ec ff ff       	call   800ac7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801e5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e60:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801e65:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e68:	b8 01 00 00 00       	mov    $0x1,%eax
  801e6d:	e8 b1 fd ff ff       	call   801c23 <fsipc>
  801e72:	89 c3                	mov    %eax,%ebx
  801e74:	85 c0                	test   %eax,%eax
  801e76:	79 17                	jns    801e8f <open+0x6c>
		fd_close(fd, 0);
  801e78:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e7f:	00 
  801e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e83:	89 04 24             	mov    %eax,(%esp)
  801e86:	e8 db f8 ff ff       	call   801766 <fd_close>
		return r;
  801e8b:	89 d8                	mov    %ebx,%eax
  801e8d:	eb 12                	jmp    801ea1 <open+0x7e>
	}

	return fd2num(fd);
  801e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e92:	89 04 24             	mov    %eax,(%esp)
  801e95:	e8 a6 f7 ff ff       	call   801640 <fd2num>
  801e9a:	eb 05                	jmp    801ea1 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801e9c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ea1:	83 c4 24             	add    $0x24,%esp
  801ea4:	5b                   	pop    %ebx
  801ea5:	5d                   	pop    %ebp
  801ea6:	c3                   	ret    

00801ea7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ea7:	55                   	push   %ebp
  801ea8:	89 e5                	mov    %esp,%ebp
  801eaa:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ead:	ba 00 00 00 00       	mov    $0x0,%edx
  801eb2:	b8 08 00 00 00       	mov    $0x8,%eax
  801eb7:	e8 67 fd ff ff       	call   801c23 <fsipc>
}
  801ebc:	c9                   	leave  
  801ebd:	c3                   	ret    
  801ebe:	66 90                	xchg   %ax,%ax

00801ec0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ec0:	55                   	push   %ebp
  801ec1:	89 e5                	mov    %esp,%ebp
  801ec3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801ec6:	c7 44 24 04 07 32 80 	movl   $0x803207,0x4(%esp)
  801ecd:	00 
  801ece:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ed1:	89 04 24             	mov    %eax,(%esp)
  801ed4:	e8 ee eb ff ff       	call   800ac7 <strcpy>
	return 0;
}
  801ed9:	b8 00 00 00 00       	mov    $0x0,%eax
  801ede:	c9                   	leave  
  801edf:	c3                   	ret    

00801ee0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ee0:	55                   	push   %ebp
  801ee1:	89 e5                	mov    %esp,%ebp
  801ee3:	53                   	push   %ebx
  801ee4:	83 ec 14             	sub    $0x14,%esp
  801ee7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801eea:	89 1c 24             	mov    %ebx,(%esp)
  801eed:	e8 75 0a 00 00       	call   802967 <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801ef2:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801ef7:	83 f8 01             	cmp    $0x1,%eax
  801efa:	75 0d                	jne    801f09 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801efc:	8b 43 0c             	mov    0xc(%ebx),%eax
  801eff:	89 04 24             	mov    %eax,(%esp)
  801f02:	e8 29 03 00 00       	call   802230 <nsipc_close>
  801f07:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  801f09:	89 d0                	mov    %edx,%eax
  801f0b:	83 c4 14             	add    $0x14,%esp
  801f0e:	5b                   	pop    %ebx
  801f0f:	5d                   	pop    %ebp
  801f10:	c3                   	ret    

00801f11 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801f11:	55                   	push   %ebp
  801f12:	89 e5                	mov    %esp,%ebp
  801f14:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801f17:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f1e:	00 
  801f1f:	8b 45 10             	mov    0x10(%ebp),%eax
  801f22:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f26:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f29:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f30:	8b 40 0c             	mov    0xc(%eax),%eax
  801f33:	89 04 24             	mov    %eax,(%esp)
  801f36:	e8 f0 03 00 00       	call   80232b <nsipc_send>
}
  801f3b:	c9                   	leave  
  801f3c:	c3                   	ret    

00801f3d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801f3d:	55                   	push   %ebp
  801f3e:	89 e5                	mov    %esp,%ebp
  801f40:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801f43:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f4a:	00 
  801f4b:	8b 45 10             	mov    0x10(%ebp),%eax
  801f4e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f52:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f55:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f59:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5c:	8b 40 0c             	mov    0xc(%eax),%eax
  801f5f:	89 04 24             	mov    %eax,(%esp)
  801f62:	e8 44 03 00 00       	call   8022ab <nsipc_recv>
}
  801f67:	c9                   	leave  
  801f68:	c3                   	ret    

00801f69 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801f69:	55                   	push   %ebp
  801f6a:	89 e5                	mov    %esp,%ebp
  801f6c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801f6f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801f72:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f76:	89 04 24             	mov    %eax,(%esp)
  801f79:	e8 38 f7 ff ff       	call   8016b6 <fd_lookup>
  801f7e:	85 c0                	test   %eax,%eax
  801f80:	78 17                	js     801f99 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f85:	8b 0d 20 40 80 00    	mov    0x804020,%ecx
  801f8b:	39 08                	cmp    %ecx,(%eax)
  801f8d:	75 05                	jne    801f94 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801f8f:	8b 40 0c             	mov    0xc(%eax),%eax
  801f92:	eb 05                	jmp    801f99 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801f94:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801f99:	c9                   	leave  
  801f9a:	c3                   	ret    

00801f9b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801f9b:	55                   	push   %ebp
  801f9c:	89 e5                	mov    %esp,%ebp
  801f9e:	56                   	push   %esi
  801f9f:	53                   	push   %ebx
  801fa0:	83 ec 20             	sub    $0x20,%esp
  801fa3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801fa5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa8:	89 04 24             	mov    %eax,(%esp)
  801fab:	e8 b7 f6 ff ff       	call   801667 <fd_alloc>
  801fb0:	89 c3                	mov    %eax,%ebx
  801fb2:	85 c0                	test   %eax,%eax
  801fb4:	78 21                	js     801fd7 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801fb6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fbd:	00 
  801fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fc5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fcc:	e8 12 ef ff ff       	call   800ee3 <sys_page_alloc>
  801fd1:	89 c3                	mov    %eax,%ebx
  801fd3:	85 c0                	test   %eax,%eax
  801fd5:	79 0c                	jns    801fe3 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  801fd7:	89 34 24             	mov    %esi,(%esp)
  801fda:	e8 51 02 00 00       	call   802230 <nsipc_close>
		return r;
  801fdf:	89 d8                	mov    %ebx,%eax
  801fe1:	eb 20                	jmp    802003 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801fe3:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fec:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801fee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ff1:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801ff8:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801ffb:	89 14 24             	mov    %edx,(%esp)
  801ffe:	e8 3d f6 ff ff       	call   801640 <fd2num>
}
  802003:	83 c4 20             	add    $0x20,%esp
  802006:	5b                   	pop    %ebx
  802007:	5e                   	pop    %esi
  802008:	5d                   	pop    %ebp
  802009:	c3                   	ret    

0080200a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80200a:	55                   	push   %ebp
  80200b:	89 e5                	mov    %esp,%ebp
  80200d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802010:	8b 45 08             	mov    0x8(%ebp),%eax
  802013:	e8 51 ff ff ff       	call   801f69 <fd2sockid>
		return r;
  802018:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80201a:	85 c0                	test   %eax,%eax
  80201c:	78 23                	js     802041 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80201e:	8b 55 10             	mov    0x10(%ebp),%edx
  802021:	89 54 24 08          	mov    %edx,0x8(%esp)
  802025:	8b 55 0c             	mov    0xc(%ebp),%edx
  802028:	89 54 24 04          	mov    %edx,0x4(%esp)
  80202c:	89 04 24             	mov    %eax,(%esp)
  80202f:	e8 45 01 00 00       	call   802179 <nsipc_accept>
		return r;
  802034:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802036:	85 c0                	test   %eax,%eax
  802038:	78 07                	js     802041 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  80203a:	e8 5c ff ff ff       	call   801f9b <alloc_sockfd>
  80203f:	89 c1                	mov    %eax,%ecx
}
  802041:	89 c8                	mov    %ecx,%eax
  802043:	c9                   	leave  
  802044:	c3                   	ret    

00802045 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802045:	55                   	push   %ebp
  802046:	89 e5                	mov    %esp,%ebp
  802048:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80204b:	8b 45 08             	mov    0x8(%ebp),%eax
  80204e:	e8 16 ff ff ff       	call   801f69 <fd2sockid>
  802053:	89 c2                	mov    %eax,%edx
  802055:	85 d2                	test   %edx,%edx
  802057:	78 16                	js     80206f <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  802059:	8b 45 10             	mov    0x10(%ebp),%eax
  80205c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802060:	8b 45 0c             	mov    0xc(%ebp),%eax
  802063:	89 44 24 04          	mov    %eax,0x4(%esp)
  802067:	89 14 24             	mov    %edx,(%esp)
  80206a:	e8 60 01 00 00       	call   8021cf <nsipc_bind>
}
  80206f:	c9                   	leave  
  802070:	c3                   	ret    

00802071 <shutdown>:

int
shutdown(int s, int how)
{
  802071:	55                   	push   %ebp
  802072:	89 e5                	mov    %esp,%ebp
  802074:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802077:	8b 45 08             	mov    0x8(%ebp),%eax
  80207a:	e8 ea fe ff ff       	call   801f69 <fd2sockid>
  80207f:	89 c2                	mov    %eax,%edx
  802081:	85 d2                	test   %edx,%edx
  802083:	78 0f                	js     802094 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  802085:	8b 45 0c             	mov    0xc(%ebp),%eax
  802088:	89 44 24 04          	mov    %eax,0x4(%esp)
  80208c:	89 14 24             	mov    %edx,(%esp)
  80208f:	e8 7a 01 00 00       	call   80220e <nsipc_shutdown>
}
  802094:	c9                   	leave  
  802095:	c3                   	ret    

00802096 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802096:	55                   	push   %ebp
  802097:	89 e5                	mov    %esp,%ebp
  802099:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80209c:	8b 45 08             	mov    0x8(%ebp),%eax
  80209f:	e8 c5 fe ff ff       	call   801f69 <fd2sockid>
  8020a4:	89 c2                	mov    %eax,%edx
  8020a6:	85 d2                	test   %edx,%edx
  8020a8:	78 16                	js     8020c0 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  8020aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8020ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020b8:	89 14 24             	mov    %edx,(%esp)
  8020bb:	e8 8a 01 00 00       	call   80224a <nsipc_connect>
}
  8020c0:	c9                   	leave  
  8020c1:	c3                   	ret    

008020c2 <listen>:

int
listen(int s, int backlog)
{
  8020c2:	55                   	push   %ebp
  8020c3:	89 e5                	mov    %esp,%ebp
  8020c5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8020cb:	e8 99 fe ff ff       	call   801f69 <fd2sockid>
  8020d0:	89 c2                	mov    %eax,%edx
  8020d2:	85 d2                	test   %edx,%edx
  8020d4:	78 0f                	js     8020e5 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  8020d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020dd:	89 14 24             	mov    %edx,(%esp)
  8020e0:	e8 a4 01 00 00       	call   802289 <nsipc_listen>
}
  8020e5:	c9                   	leave  
  8020e6:	c3                   	ret    

008020e7 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8020e7:	55                   	push   %ebp
  8020e8:	89 e5                	mov    %esp,%ebp
  8020ea:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8020ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8020f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8020fe:	89 04 24             	mov    %eax,(%esp)
  802101:	e8 98 02 00 00       	call   80239e <nsipc_socket>
  802106:	89 c2                	mov    %eax,%edx
  802108:	85 d2                	test   %edx,%edx
  80210a:	78 05                	js     802111 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  80210c:	e8 8a fe ff ff       	call   801f9b <alloc_sockfd>
}
  802111:	c9                   	leave  
  802112:	c3                   	ret    

00802113 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802113:	55                   	push   %ebp
  802114:	89 e5                	mov    %esp,%ebp
  802116:	53                   	push   %ebx
  802117:	83 ec 14             	sub    $0x14,%esp
  80211a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80211c:	83 3d 08 50 80 00 00 	cmpl   $0x0,0x805008
  802123:	75 11                	jne    802136 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802125:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80212c:	e8 d4 f4 ff ff       	call   801605 <ipc_find_env>
  802131:	a3 08 50 80 00       	mov    %eax,0x805008
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802136:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80213d:	00 
  80213e:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802145:	00 
  802146:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80214a:	a1 08 50 80 00       	mov    0x805008,%eax
  80214f:	89 04 24             	mov    %eax,(%esp)
  802152:	e8 43 f4 ff ff       	call   80159a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802157:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80215e:	00 
  80215f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802166:	00 
  802167:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80216e:	e8 ad f3 ff ff       	call   801520 <ipc_recv>
}
  802173:	83 c4 14             	add    $0x14,%esp
  802176:	5b                   	pop    %ebx
  802177:	5d                   	pop    %ebp
  802178:	c3                   	ret    

00802179 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802179:	55                   	push   %ebp
  80217a:	89 e5                	mov    %esp,%ebp
  80217c:	56                   	push   %esi
  80217d:	53                   	push   %ebx
  80217e:	83 ec 10             	sub    $0x10,%esp
  802181:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802184:	8b 45 08             	mov    0x8(%ebp),%eax
  802187:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80218c:	8b 06                	mov    (%esi),%eax
  80218e:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802193:	b8 01 00 00 00       	mov    $0x1,%eax
  802198:	e8 76 ff ff ff       	call   802113 <nsipc>
  80219d:	89 c3                	mov    %eax,%ebx
  80219f:	85 c0                	test   %eax,%eax
  8021a1:	78 23                	js     8021c6 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8021a3:	a1 10 70 80 00       	mov    0x807010,%eax
  8021a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021ac:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8021b3:	00 
  8021b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021b7:	89 04 24             	mov    %eax,(%esp)
  8021ba:	e8 a5 ea ff ff       	call   800c64 <memmove>
		*addrlen = ret->ret_addrlen;
  8021bf:	a1 10 70 80 00       	mov    0x807010,%eax
  8021c4:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  8021c6:	89 d8                	mov    %ebx,%eax
  8021c8:	83 c4 10             	add    $0x10,%esp
  8021cb:	5b                   	pop    %ebx
  8021cc:	5e                   	pop    %esi
  8021cd:	5d                   	pop    %ebp
  8021ce:	c3                   	ret    

008021cf <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8021cf:	55                   	push   %ebp
  8021d0:	89 e5                	mov    %esp,%ebp
  8021d2:	53                   	push   %ebx
  8021d3:	83 ec 14             	sub    $0x14,%esp
  8021d6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8021d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8021dc:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8021e1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021ec:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8021f3:	e8 6c ea ff ff       	call   800c64 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8021f8:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8021fe:	b8 02 00 00 00       	mov    $0x2,%eax
  802203:	e8 0b ff ff ff       	call   802113 <nsipc>
}
  802208:	83 c4 14             	add    $0x14,%esp
  80220b:	5b                   	pop    %ebx
  80220c:	5d                   	pop    %ebp
  80220d:	c3                   	ret    

0080220e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80220e:	55                   	push   %ebp
  80220f:	89 e5                	mov    %esp,%ebp
  802211:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802214:	8b 45 08             	mov    0x8(%ebp),%eax
  802217:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80221c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80221f:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802224:	b8 03 00 00 00       	mov    $0x3,%eax
  802229:	e8 e5 fe ff ff       	call   802113 <nsipc>
}
  80222e:	c9                   	leave  
  80222f:	c3                   	ret    

00802230 <nsipc_close>:

int
nsipc_close(int s)
{
  802230:	55                   	push   %ebp
  802231:	89 e5                	mov    %esp,%ebp
  802233:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802236:	8b 45 08             	mov    0x8(%ebp),%eax
  802239:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  80223e:	b8 04 00 00 00       	mov    $0x4,%eax
  802243:	e8 cb fe ff ff       	call   802113 <nsipc>
}
  802248:	c9                   	leave  
  802249:	c3                   	ret    

0080224a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80224a:	55                   	push   %ebp
  80224b:	89 e5                	mov    %esp,%ebp
  80224d:	53                   	push   %ebx
  80224e:	83 ec 14             	sub    $0x14,%esp
  802251:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802254:	8b 45 08             	mov    0x8(%ebp),%eax
  802257:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80225c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802260:	8b 45 0c             	mov    0xc(%ebp),%eax
  802263:	89 44 24 04          	mov    %eax,0x4(%esp)
  802267:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  80226e:	e8 f1 e9 ff ff       	call   800c64 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802273:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802279:	b8 05 00 00 00       	mov    $0x5,%eax
  80227e:	e8 90 fe ff ff       	call   802113 <nsipc>
}
  802283:	83 c4 14             	add    $0x14,%esp
  802286:	5b                   	pop    %ebx
  802287:	5d                   	pop    %ebp
  802288:	c3                   	ret    

00802289 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802289:	55                   	push   %ebp
  80228a:	89 e5                	mov    %esp,%ebp
  80228c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80228f:	8b 45 08             	mov    0x8(%ebp),%eax
  802292:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802297:	8b 45 0c             	mov    0xc(%ebp),%eax
  80229a:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  80229f:	b8 06 00 00 00       	mov    $0x6,%eax
  8022a4:	e8 6a fe ff ff       	call   802113 <nsipc>
}
  8022a9:	c9                   	leave  
  8022aa:	c3                   	ret    

008022ab <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8022ab:	55                   	push   %ebp
  8022ac:	89 e5                	mov    %esp,%ebp
  8022ae:	56                   	push   %esi
  8022af:	53                   	push   %ebx
  8022b0:	83 ec 10             	sub    $0x10,%esp
  8022b3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8022b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8022be:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8022c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8022c7:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8022cc:	b8 07 00 00 00       	mov    $0x7,%eax
  8022d1:	e8 3d fe ff ff       	call   802113 <nsipc>
  8022d6:	89 c3                	mov    %eax,%ebx
  8022d8:	85 c0                	test   %eax,%eax
  8022da:	78 46                	js     802322 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8022dc:	39 f0                	cmp    %esi,%eax
  8022de:	7f 07                	jg     8022e7 <nsipc_recv+0x3c>
  8022e0:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8022e5:	7e 24                	jle    80230b <nsipc_recv+0x60>
  8022e7:	c7 44 24 0c 13 32 80 	movl   $0x803213,0xc(%esp)
  8022ee:	00 
  8022ef:	c7 44 24 08 db 31 80 	movl   $0x8031db,0x8(%esp)
  8022f6:	00 
  8022f7:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  8022fe:	00 
  8022ff:	c7 04 24 28 32 80 00 	movl   $0x803228,(%esp)
  802306:	e8 9b e0 ff ff       	call   8003a6 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80230b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80230f:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802316:	00 
  802317:	8b 45 0c             	mov    0xc(%ebp),%eax
  80231a:	89 04 24             	mov    %eax,(%esp)
  80231d:	e8 42 e9 ff ff       	call   800c64 <memmove>
	}

	return r;
}
  802322:	89 d8                	mov    %ebx,%eax
  802324:	83 c4 10             	add    $0x10,%esp
  802327:	5b                   	pop    %ebx
  802328:	5e                   	pop    %esi
  802329:	5d                   	pop    %ebp
  80232a:	c3                   	ret    

0080232b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80232b:	55                   	push   %ebp
  80232c:	89 e5                	mov    %esp,%ebp
  80232e:	53                   	push   %ebx
  80232f:	83 ec 14             	sub    $0x14,%esp
  802332:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802335:	8b 45 08             	mov    0x8(%ebp),%eax
  802338:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  80233d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802343:	7e 24                	jle    802369 <nsipc_send+0x3e>
  802345:	c7 44 24 0c 34 32 80 	movl   $0x803234,0xc(%esp)
  80234c:	00 
  80234d:	c7 44 24 08 db 31 80 	movl   $0x8031db,0x8(%esp)
  802354:	00 
  802355:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  80235c:	00 
  80235d:	c7 04 24 28 32 80 00 	movl   $0x803228,(%esp)
  802364:	e8 3d e0 ff ff       	call   8003a6 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802369:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80236d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802370:	89 44 24 04          	mov    %eax,0x4(%esp)
  802374:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  80237b:	e8 e4 e8 ff ff       	call   800c64 <memmove>
	nsipcbuf.send.req_size = size;
  802380:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802386:	8b 45 14             	mov    0x14(%ebp),%eax
  802389:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  80238e:	b8 08 00 00 00       	mov    $0x8,%eax
  802393:	e8 7b fd ff ff       	call   802113 <nsipc>
}
  802398:	83 c4 14             	add    $0x14,%esp
  80239b:	5b                   	pop    %ebx
  80239c:	5d                   	pop    %ebp
  80239d:	c3                   	ret    

0080239e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80239e:	55                   	push   %ebp
  80239f:	89 e5                	mov    %esp,%ebp
  8023a1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8023a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8023a7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8023ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023af:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8023b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8023b7:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8023bc:	b8 09 00 00 00       	mov    $0x9,%eax
  8023c1:	e8 4d fd ff ff       	call   802113 <nsipc>
}
  8023c6:	c9                   	leave  
  8023c7:	c3                   	ret    

008023c8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8023c8:	55                   	push   %ebp
  8023c9:	89 e5                	mov    %esp,%ebp
  8023cb:	56                   	push   %esi
  8023cc:	53                   	push   %ebx
  8023cd:	83 ec 10             	sub    $0x10,%esp
  8023d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8023d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8023d6:	89 04 24             	mov    %eax,(%esp)
  8023d9:	e8 72 f2 ff ff       	call   801650 <fd2data>
  8023de:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8023e0:	c7 44 24 04 40 32 80 	movl   $0x803240,0x4(%esp)
  8023e7:	00 
  8023e8:	89 1c 24             	mov    %ebx,(%esp)
  8023eb:	e8 d7 e6 ff ff       	call   800ac7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8023f0:	8b 46 04             	mov    0x4(%esi),%eax
  8023f3:	2b 06                	sub    (%esi),%eax
  8023f5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8023fb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802402:	00 00 00 
	stat->st_dev = &devpipe;
  802405:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  80240c:	40 80 00 
	return 0;
}
  80240f:	b8 00 00 00 00       	mov    $0x0,%eax
  802414:	83 c4 10             	add    $0x10,%esp
  802417:	5b                   	pop    %ebx
  802418:	5e                   	pop    %esi
  802419:	5d                   	pop    %ebp
  80241a:	c3                   	ret    

0080241b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80241b:	55                   	push   %ebp
  80241c:	89 e5                	mov    %esp,%ebp
  80241e:	53                   	push   %ebx
  80241f:	83 ec 14             	sub    $0x14,%esp
  802422:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802425:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802429:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802430:	e8 55 eb ff ff       	call   800f8a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802435:	89 1c 24             	mov    %ebx,(%esp)
  802438:	e8 13 f2 ff ff       	call   801650 <fd2data>
  80243d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802441:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802448:	e8 3d eb ff ff       	call   800f8a <sys_page_unmap>
}
  80244d:	83 c4 14             	add    $0x14,%esp
  802450:	5b                   	pop    %ebx
  802451:	5d                   	pop    %ebp
  802452:	c3                   	ret    

00802453 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802453:	55                   	push   %ebp
  802454:	89 e5                	mov    %esp,%ebp
  802456:	57                   	push   %edi
  802457:	56                   	push   %esi
  802458:	53                   	push   %ebx
  802459:	83 ec 2c             	sub    $0x2c,%esp
  80245c:	89 c6                	mov    %eax,%esi
  80245e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802461:	a1 0c 50 80 00       	mov    0x80500c,%eax
  802466:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802469:	89 34 24             	mov    %esi,(%esp)
  80246c:	e8 f6 04 00 00       	call   802967 <pageref>
  802471:	89 c7                	mov    %eax,%edi
  802473:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802476:	89 04 24             	mov    %eax,(%esp)
  802479:	e8 e9 04 00 00       	call   802967 <pageref>
  80247e:	39 c7                	cmp    %eax,%edi
  802480:	0f 94 c2             	sete   %dl
  802483:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  802486:	8b 0d 0c 50 80 00    	mov    0x80500c,%ecx
  80248c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  80248f:	39 fb                	cmp    %edi,%ebx
  802491:	74 21                	je     8024b4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802493:	84 d2                	test   %dl,%dl
  802495:	74 ca                	je     802461 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802497:	8b 51 58             	mov    0x58(%ecx),%edx
  80249a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80249e:	89 54 24 08          	mov    %edx,0x8(%esp)
  8024a2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8024a6:	c7 04 24 47 32 80 00 	movl   $0x803247,(%esp)
  8024ad:	e8 ed df ff ff       	call   80049f <cprintf>
  8024b2:	eb ad                	jmp    802461 <_pipeisclosed+0xe>
	}
}
  8024b4:	83 c4 2c             	add    $0x2c,%esp
  8024b7:	5b                   	pop    %ebx
  8024b8:	5e                   	pop    %esi
  8024b9:	5f                   	pop    %edi
  8024ba:	5d                   	pop    %ebp
  8024bb:	c3                   	ret    

008024bc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8024bc:	55                   	push   %ebp
  8024bd:	89 e5                	mov    %esp,%ebp
  8024bf:	57                   	push   %edi
  8024c0:	56                   	push   %esi
  8024c1:	53                   	push   %ebx
  8024c2:	83 ec 1c             	sub    $0x1c,%esp
  8024c5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8024c8:	89 34 24             	mov    %esi,(%esp)
  8024cb:	e8 80 f1 ff ff       	call   801650 <fd2data>
  8024d0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024d2:	bf 00 00 00 00       	mov    $0x0,%edi
  8024d7:	eb 45                	jmp    80251e <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8024d9:	89 da                	mov    %ebx,%edx
  8024db:	89 f0                	mov    %esi,%eax
  8024dd:	e8 71 ff ff ff       	call   802453 <_pipeisclosed>
  8024e2:	85 c0                	test   %eax,%eax
  8024e4:	75 41                	jne    802527 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8024e6:	e8 d9 e9 ff ff       	call   800ec4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8024eb:	8b 43 04             	mov    0x4(%ebx),%eax
  8024ee:	8b 0b                	mov    (%ebx),%ecx
  8024f0:	8d 51 20             	lea    0x20(%ecx),%edx
  8024f3:	39 d0                	cmp    %edx,%eax
  8024f5:	73 e2                	jae    8024d9 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8024f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024fa:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8024fe:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802501:	99                   	cltd   
  802502:	c1 ea 1b             	shr    $0x1b,%edx
  802505:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802508:	83 e1 1f             	and    $0x1f,%ecx
  80250b:	29 d1                	sub    %edx,%ecx
  80250d:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  802511:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  802515:	83 c0 01             	add    $0x1,%eax
  802518:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80251b:	83 c7 01             	add    $0x1,%edi
  80251e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802521:	75 c8                	jne    8024eb <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802523:	89 f8                	mov    %edi,%eax
  802525:	eb 05                	jmp    80252c <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802527:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80252c:	83 c4 1c             	add    $0x1c,%esp
  80252f:	5b                   	pop    %ebx
  802530:	5e                   	pop    %esi
  802531:	5f                   	pop    %edi
  802532:	5d                   	pop    %ebp
  802533:	c3                   	ret    

00802534 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802534:	55                   	push   %ebp
  802535:	89 e5                	mov    %esp,%ebp
  802537:	57                   	push   %edi
  802538:	56                   	push   %esi
  802539:	53                   	push   %ebx
  80253a:	83 ec 1c             	sub    $0x1c,%esp
  80253d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802540:	89 3c 24             	mov    %edi,(%esp)
  802543:	e8 08 f1 ff ff       	call   801650 <fd2data>
  802548:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80254a:	be 00 00 00 00       	mov    $0x0,%esi
  80254f:	eb 3d                	jmp    80258e <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802551:	85 f6                	test   %esi,%esi
  802553:	74 04                	je     802559 <devpipe_read+0x25>
				return i;
  802555:	89 f0                	mov    %esi,%eax
  802557:	eb 43                	jmp    80259c <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802559:	89 da                	mov    %ebx,%edx
  80255b:	89 f8                	mov    %edi,%eax
  80255d:	e8 f1 fe ff ff       	call   802453 <_pipeisclosed>
  802562:	85 c0                	test   %eax,%eax
  802564:	75 31                	jne    802597 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802566:	e8 59 e9 ff ff       	call   800ec4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80256b:	8b 03                	mov    (%ebx),%eax
  80256d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802570:	74 df                	je     802551 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802572:	99                   	cltd   
  802573:	c1 ea 1b             	shr    $0x1b,%edx
  802576:	01 d0                	add    %edx,%eax
  802578:	83 e0 1f             	and    $0x1f,%eax
  80257b:	29 d0                	sub    %edx,%eax
  80257d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802582:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802585:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802588:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80258b:	83 c6 01             	add    $0x1,%esi
  80258e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802591:	75 d8                	jne    80256b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802593:	89 f0                	mov    %esi,%eax
  802595:	eb 05                	jmp    80259c <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802597:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80259c:	83 c4 1c             	add    $0x1c,%esp
  80259f:	5b                   	pop    %ebx
  8025a0:	5e                   	pop    %esi
  8025a1:	5f                   	pop    %edi
  8025a2:	5d                   	pop    %ebp
  8025a3:	c3                   	ret    

008025a4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8025a4:	55                   	push   %ebp
  8025a5:	89 e5                	mov    %esp,%ebp
  8025a7:	56                   	push   %esi
  8025a8:	53                   	push   %ebx
  8025a9:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8025ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025af:	89 04 24             	mov    %eax,(%esp)
  8025b2:	e8 b0 f0 ff ff       	call   801667 <fd_alloc>
  8025b7:	89 c2                	mov    %eax,%edx
  8025b9:	85 d2                	test   %edx,%edx
  8025bb:	0f 88 4d 01 00 00    	js     80270e <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025c1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8025c8:	00 
  8025c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025d7:	e8 07 e9 ff ff       	call   800ee3 <sys_page_alloc>
  8025dc:	89 c2                	mov    %eax,%edx
  8025de:	85 d2                	test   %edx,%edx
  8025e0:	0f 88 28 01 00 00    	js     80270e <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8025e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8025e9:	89 04 24             	mov    %eax,(%esp)
  8025ec:	e8 76 f0 ff ff       	call   801667 <fd_alloc>
  8025f1:	89 c3                	mov    %eax,%ebx
  8025f3:	85 c0                	test   %eax,%eax
  8025f5:	0f 88 fe 00 00 00    	js     8026f9 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025fb:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802602:	00 
  802603:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802606:	89 44 24 04          	mov    %eax,0x4(%esp)
  80260a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802611:	e8 cd e8 ff ff       	call   800ee3 <sys_page_alloc>
  802616:	89 c3                	mov    %eax,%ebx
  802618:	85 c0                	test   %eax,%eax
  80261a:	0f 88 d9 00 00 00    	js     8026f9 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802620:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802623:	89 04 24             	mov    %eax,(%esp)
  802626:	e8 25 f0 ff ff       	call   801650 <fd2data>
  80262b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80262d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802634:	00 
  802635:	89 44 24 04          	mov    %eax,0x4(%esp)
  802639:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802640:	e8 9e e8 ff ff       	call   800ee3 <sys_page_alloc>
  802645:	89 c3                	mov    %eax,%ebx
  802647:	85 c0                	test   %eax,%eax
  802649:	0f 88 97 00 00 00    	js     8026e6 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80264f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802652:	89 04 24             	mov    %eax,(%esp)
  802655:	e8 f6 ef ff ff       	call   801650 <fd2data>
  80265a:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802661:	00 
  802662:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802666:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80266d:	00 
  80266e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802672:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802679:	e8 b9 e8 ff ff       	call   800f37 <sys_page_map>
  80267e:	89 c3                	mov    %eax,%ebx
  802680:	85 c0                	test   %eax,%eax
  802682:	78 52                	js     8026d6 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802684:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80268a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80268d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80268f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802692:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802699:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80269f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8026a2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8026a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8026a7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8026ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026b1:	89 04 24             	mov    %eax,(%esp)
  8026b4:	e8 87 ef ff ff       	call   801640 <fd2num>
  8026b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8026bc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8026be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8026c1:	89 04 24             	mov    %eax,(%esp)
  8026c4:	e8 77 ef ff ff       	call   801640 <fd2num>
  8026c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8026cc:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8026cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8026d4:	eb 38                	jmp    80270e <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  8026d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026e1:	e8 a4 e8 ff ff       	call   800f8a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8026e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8026e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026f4:	e8 91 e8 ff ff       	call   800f8a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8026f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  802700:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802707:	e8 7e e8 ff ff       	call   800f8a <sys_page_unmap>
  80270c:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  80270e:	83 c4 30             	add    $0x30,%esp
  802711:	5b                   	pop    %ebx
  802712:	5e                   	pop    %esi
  802713:	5d                   	pop    %ebp
  802714:	c3                   	ret    

00802715 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802715:	55                   	push   %ebp
  802716:	89 e5                	mov    %esp,%ebp
  802718:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80271b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80271e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802722:	8b 45 08             	mov    0x8(%ebp),%eax
  802725:	89 04 24             	mov    %eax,(%esp)
  802728:	e8 89 ef ff ff       	call   8016b6 <fd_lookup>
  80272d:	89 c2                	mov    %eax,%edx
  80272f:	85 d2                	test   %edx,%edx
  802731:	78 15                	js     802748 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802733:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802736:	89 04 24             	mov    %eax,(%esp)
  802739:	e8 12 ef ff ff       	call   801650 <fd2data>
	return _pipeisclosed(fd, p);
  80273e:	89 c2                	mov    %eax,%edx
  802740:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802743:	e8 0b fd ff ff       	call   802453 <_pipeisclosed>
}
  802748:	c9                   	leave  
  802749:	c3                   	ret    
  80274a:	66 90                	xchg   %ax,%ax
  80274c:	66 90                	xchg   %ax,%ax
  80274e:	66 90                	xchg   %ax,%ax

00802750 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802750:	55                   	push   %ebp
  802751:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802753:	b8 00 00 00 00       	mov    $0x0,%eax
  802758:	5d                   	pop    %ebp
  802759:	c3                   	ret    

0080275a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80275a:	55                   	push   %ebp
  80275b:	89 e5                	mov    %esp,%ebp
  80275d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802760:	c7 44 24 04 5f 32 80 	movl   $0x80325f,0x4(%esp)
  802767:	00 
  802768:	8b 45 0c             	mov    0xc(%ebp),%eax
  80276b:	89 04 24             	mov    %eax,(%esp)
  80276e:	e8 54 e3 ff ff       	call   800ac7 <strcpy>
	return 0;
}
  802773:	b8 00 00 00 00       	mov    $0x0,%eax
  802778:	c9                   	leave  
  802779:	c3                   	ret    

0080277a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80277a:	55                   	push   %ebp
  80277b:	89 e5                	mov    %esp,%ebp
  80277d:	57                   	push   %edi
  80277e:	56                   	push   %esi
  80277f:	53                   	push   %ebx
  802780:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802786:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80278b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802791:	eb 31                	jmp    8027c4 <devcons_write+0x4a>
		m = n - tot;
  802793:	8b 75 10             	mov    0x10(%ebp),%esi
  802796:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802798:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80279b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8027a0:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8027a3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8027a7:	03 45 0c             	add    0xc(%ebp),%eax
  8027aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027ae:	89 3c 24             	mov    %edi,(%esp)
  8027b1:	e8 ae e4 ff ff       	call   800c64 <memmove>
		sys_cputs(buf, m);
  8027b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027ba:	89 3c 24             	mov    %edi,(%esp)
  8027bd:	e8 54 e6 ff ff       	call   800e16 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8027c2:	01 f3                	add    %esi,%ebx
  8027c4:	89 d8                	mov    %ebx,%eax
  8027c6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8027c9:	72 c8                	jb     802793 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8027cb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8027d1:	5b                   	pop    %ebx
  8027d2:	5e                   	pop    %esi
  8027d3:	5f                   	pop    %edi
  8027d4:	5d                   	pop    %ebp
  8027d5:	c3                   	ret    

008027d6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8027d6:	55                   	push   %ebp
  8027d7:	89 e5                	mov    %esp,%ebp
  8027d9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8027dc:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8027e1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8027e5:	75 07                	jne    8027ee <devcons_read+0x18>
  8027e7:	eb 2a                	jmp    802813 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8027e9:	e8 d6 e6 ff ff       	call   800ec4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8027ee:	66 90                	xchg   %ax,%ax
  8027f0:	e8 3f e6 ff ff       	call   800e34 <sys_cgetc>
  8027f5:	85 c0                	test   %eax,%eax
  8027f7:	74 f0                	je     8027e9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8027f9:	85 c0                	test   %eax,%eax
  8027fb:	78 16                	js     802813 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8027fd:	83 f8 04             	cmp    $0x4,%eax
  802800:	74 0c                	je     80280e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802802:	8b 55 0c             	mov    0xc(%ebp),%edx
  802805:	88 02                	mov    %al,(%edx)
	return 1;
  802807:	b8 01 00 00 00       	mov    $0x1,%eax
  80280c:	eb 05                	jmp    802813 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80280e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802813:	c9                   	leave  
  802814:	c3                   	ret    

00802815 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802815:	55                   	push   %ebp
  802816:	89 e5                	mov    %esp,%ebp
  802818:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80281b:	8b 45 08             	mov    0x8(%ebp),%eax
  80281e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802821:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802828:	00 
  802829:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80282c:	89 04 24             	mov    %eax,(%esp)
  80282f:	e8 e2 e5 ff ff       	call   800e16 <sys_cputs>
}
  802834:	c9                   	leave  
  802835:	c3                   	ret    

00802836 <getchar>:

int
getchar(void)
{
  802836:	55                   	push   %ebp
  802837:	89 e5                	mov    %esp,%ebp
  802839:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80283c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802843:	00 
  802844:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802847:	89 44 24 04          	mov    %eax,0x4(%esp)
  80284b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802852:	e8 f3 f0 ff ff       	call   80194a <read>
	if (r < 0)
  802857:	85 c0                	test   %eax,%eax
  802859:	78 0f                	js     80286a <getchar+0x34>
		return r;
	if (r < 1)
  80285b:	85 c0                	test   %eax,%eax
  80285d:	7e 06                	jle    802865 <getchar+0x2f>
		return -E_EOF;
	return c;
  80285f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802863:	eb 05                	jmp    80286a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802865:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80286a:	c9                   	leave  
  80286b:	c3                   	ret    

0080286c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80286c:	55                   	push   %ebp
  80286d:	89 e5                	mov    %esp,%ebp
  80286f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802872:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802875:	89 44 24 04          	mov    %eax,0x4(%esp)
  802879:	8b 45 08             	mov    0x8(%ebp),%eax
  80287c:	89 04 24             	mov    %eax,(%esp)
  80287f:	e8 32 ee ff ff       	call   8016b6 <fd_lookup>
  802884:	85 c0                	test   %eax,%eax
  802886:	78 11                	js     802899 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802888:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80288b:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802891:	39 10                	cmp    %edx,(%eax)
  802893:	0f 94 c0             	sete   %al
  802896:	0f b6 c0             	movzbl %al,%eax
}
  802899:	c9                   	leave  
  80289a:	c3                   	ret    

0080289b <opencons>:

int
opencons(void)
{
  80289b:	55                   	push   %ebp
  80289c:	89 e5                	mov    %esp,%ebp
  80289e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8028a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028a4:	89 04 24             	mov    %eax,(%esp)
  8028a7:	e8 bb ed ff ff       	call   801667 <fd_alloc>
		return r;
  8028ac:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8028ae:	85 c0                	test   %eax,%eax
  8028b0:	78 40                	js     8028f2 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8028b2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8028b9:	00 
  8028ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028c8:	e8 16 e6 ff ff       	call   800ee3 <sys_page_alloc>
		return r;
  8028cd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8028cf:	85 c0                	test   %eax,%eax
  8028d1:	78 1f                	js     8028f2 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8028d3:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8028d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028dc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8028de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028e1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8028e8:	89 04 24             	mov    %eax,(%esp)
  8028eb:	e8 50 ed ff ff       	call   801640 <fd2num>
  8028f0:	89 c2                	mov    %eax,%edx
}
  8028f2:	89 d0                	mov    %edx,%eax
  8028f4:	c9                   	leave  
  8028f5:	c3                   	ret    

008028f6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8028f6:	55                   	push   %ebp
  8028f7:	89 e5                	mov    %esp,%ebp
  8028f9:	53                   	push   %ebx
  8028fa:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  8028fd:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802904:	75 2f                	jne    802935 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  802906:	e8 9a e5 ff ff       	call   800ea5 <sys_getenvid>
  80290b:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P);
  80290d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802914:	00 
  802915:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80291c:	ee 
  80291d:	89 04 24             	mov    %eax,(%esp)
  802920:	e8 be e5 ff ff       	call   800ee3 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *)_pgfault_upcall);
  802925:	c7 44 24 04 43 29 80 	movl   $0x802943,0x4(%esp)
  80292c:	00 
  80292d:	89 1c 24             	mov    %ebx,(%esp)
  802930:	e8 4e e7 ff ff       	call   801083 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802935:	8b 45 08             	mov    0x8(%ebp),%eax
  802938:	a3 00 80 80 00       	mov    %eax,0x808000
}
  80293d:	83 c4 14             	add    $0x14,%esp
  802940:	5b                   	pop    %ebx
  802941:	5d                   	pop    %ebp
  802942:	c3                   	ret    

00802943 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802943:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802944:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802949:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80294b:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	// 0x30(%esp) points to trap-time stack pointer
	// 0x28(%esp) points to trap-time eip
	subl $4, 0x30(%esp)
  80294e:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax 
  802953:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebp
  802957:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %ebp, (%eax)
  80295b:	89 28                	mov    %ebp,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  80295d:	83 c4 08             	add    $0x8,%esp
	popal
  802960:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp //pop eip - we already stored it
  802961:	83 c4 04             	add    $0x4,%esp
	popfl
  802964:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802965:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802966:	c3                   	ret    

00802967 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802967:	55                   	push   %ebp
  802968:	89 e5                	mov    %esp,%ebp
  80296a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80296d:	89 d0                	mov    %edx,%eax
  80296f:	c1 e8 16             	shr    $0x16,%eax
  802972:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802979:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80297e:	f6 c1 01             	test   $0x1,%cl
  802981:	74 1d                	je     8029a0 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802983:	c1 ea 0c             	shr    $0xc,%edx
  802986:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80298d:	f6 c2 01             	test   $0x1,%dl
  802990:	74 0e                	je     8029a0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802992:	c1 ea 0c             	shr    $0xc,%edx
  802995:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80299c:	ef 
  80299d:	0f b7 c0             	movzwl %ax,%eax
}
  8029a0:	5d                   	pop    %ebp
  8029a1:	c3                   	ret    
  8029a2:	66 90                	xchg   %ax,%ax
  8029a4:	66 90                	xchg   %ax,%ax
  8029a6:	66 90                	xchg   %ax,%ax
  8029a8:	66 90                	xchg   %ax,%ax
  8029aa:	66 90                	xchg   %ax,%ax
  8029ac:	66 90                	xchg   %ax,%ax
  8029ae:	66 90                	xchg   %ax,%ax

008029b0 <__udivdi3>:
  8029b0:	55                   	push   %ebp
  8029b1:	57                   	push   %edi
  8029b2:	56                   	push   %esi
  8029b3:	83 ec 0c             	sub    $0xc,%esp
  8029b6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8029ba:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8029be:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8029c2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8029c6:	85 c0                	test   %eax,%eax
  8029c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8029cc:	89 ea                	mov    %ebp,%edx
  8029ce:	89 0c 24             	mov    %ecx,(%esp)
  8029d1:	75 2d                	jne    802a00 <__udivdi3+0x50>
  8029d3:	39 e9                	cmp    %ebp,%ecx
  8029d5:	77 61                	ja     802a38 <__udivdi3+0x88>
  8029d7:	85 c9                	test   %ecx,%ecx
  8029d9:	89 ce                	mov    %ecx,%esi
  8029db:	75 0b                	jne    8029e8 <__udivdi3+0x38>
  8029dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8029e2:	31 d2                	xor    %edx,%edx
  8029e4:	f7 f1                	div    %ecx
  8029e6:	89 c6                	mov    %eax,%esi
  8029e8:	31 d2                	xor    %edx,%edx
  8029ea:	89 e8                	mov    %ebp,%eax
  8029ec:	f7 f6                	div    %esi
  8029ee:	89 c5                	mov    %eax,%ebp
  8029f0:	89 f8                	mov    %edi,%eax
  8029f2:	f7 f6                	div    %esi
  8029f4:	89 ea                	mov    %ebp,%edx
  8029f6:	83 c4 0c             	add    $0xc,%esp
  8029f9:	5e                   	pop    %esi
  8029fa:	5f                   	pop    %edi
  8029fb:	5d                   	pop    %ebp
  8029fc:	c3                   	ret    
  8029fd:	8d 76 00             	lea    0x0(%esi),%esi
  802a00:	39 e8                	cmp    %ebp,%eax
  802a02:	77 24                	ja     802a28 <__udivdi3+0x78>
  802a04:	0f bd e8             	bsr    %eax,%ebp
  802a07:	83 f5 1f             	xor    $0x1f,%ebp
  802a0a:	75 3c                	jne    802a48 <__udivdi3+0x98>
  802a0c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802a10:	39 34 24             	cmp    %esi,(%esp)
  802a13:	0f 86 9f 00 00 00    	jbe    802ab8 <__udivdi3+0x108>
  802a19:	39 d0                	cmp    %edx,%eax
  802a1b:	0f 82 97 00 00 00    	jb     802ab8 <__udivdi3+0x108>
  802a21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a28:	31 d2                	xor    %edx,%edx
  802a2a:	31 c0                	xor    %eax,%eax
  802a2c:	83 c4 0c             	add    $0xc,%esp
  802a2f:	5e                   	pop    %esi
  802a30:	5f                   	pop    %edi
  802a31:	5d                   	pop    %ebp
  802a32:	c3                   	ret    
  802a33:	90                   	nop
  802a34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a38:	89 f8                	mov    %edi,%eax
  802a3a:	f7 f1                	div    %ecx
  802a3c:	31 d2                	xor    %edx,%edx
  802a3e:	83 c4 0c             	add    $0xc,%esp
  802a41:	5e                   	pop    %esi
  802a42:	5f                   	pop    %edi
  802a43:	5d                   	pop    %ebp
  802a44:	c3                   	ret    
  802a45:	8d 76 00             	lea    0x0(%esi),%esi
  802a48:	89 e9                	mov    %ebp,%ecx
  802a4a:	8b 3c 24             	mov    (%esp),%edi
  802a4d:	d3 e0                	shl    %cl,%eax
  802a4f:	89 c6                	mov    %eax,%esi
  802a51:	b8 20 00 00 00       	mov    $0x20,%eax
  802a56:	29 e8                	sub    %ebp,%eax
  802a58:	89 c1                	mov    %eax,%ecx
  802a5a:	d3 ef                	shr    %cl,%edi
  802a5c:	89 e9                	mov    %ebp,%ecx
  802a5e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802a62:	8b 3c 24             	mov    (%esp),%edi
  802a65:	09 74 24 08          	or     %esi,0x8(%esp)
  802a69:	89 d6                	mov    %edx,%esi
  802a6b:	d3 e7                	shl    %cl,%edi
  802a6d:	89 c1                	mov    %eax,%ecx
  802a6f:	89 3c 24             	mov    %edi,(%esp)
  802a72:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802a76:	d3 ee                	shr    %cl,%esi
  802a78:	89 e9                	mov    %ebp,%ecx
  802a7a:	d3 e2                	shl    %cl,%edx
  802a7c:	89 c1                	mov    %eax,%ecx
  802a7e:	d3 ef                	shr    %cl,%edi
  802a80:	09 d7                	or     %edx,%edi
  802a82:	89 f2                	mov    %esi,%edx
  802a84:	89 f8                	mov    %edi,%eax
  802a86:	f7 74 24 08          	divl   0x8(%esp)
  802a8a:	89 d6                	mov    %edx,%esi
  802a8c:	89 c7                	mov    %eax,%edi
  802a8e:	f7 24 24             	mull   (%esp)
  802a91:	39 d6                	cmp    %edx,%esi
  802a93:	89 14 24             	mov    %edx,(%esp)
  802a96:	72 30                	jb     802ac8 <__udivdi3+0x118>
  802a98:	8b 54 24 04          	mov    0x4(%esp),%edx
  802a9c:	89 e9                	mov    %ebp,%ecx
  802a9e:	d3 e2                	shl    %cl,%edx
  802aa0:	39 c2                	cmp    %eax,%edx
  802aa2:	73 05                	jae    802aa9 <__udivdi3+0xf9>
  802aa4:	3b 34 24             	cmp    (%esp),%esi
  802aa7:	74 1f                	je     802ac8 <__udivdi3+0x118>
  802aa9:	89 f8                	mov    %edi,%eax
  802aab:	31 d2                	xor    %edx,%edx
  802aad:	e9 7a ff ff ff       	jmp    802a2c <__udivdi3+0x7c>
  802ab2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802ab8:	31 d2                	xor    %edx,%edx
  802aba:	b8 01 00 00 00       	mov    $0x1,%eax
  802abf:	e9 68 ff ff ff       	jmp    802a2c <__udivdi3+0x7c>
  802ac4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ac8:	8d 47 ff             	lea    -0x1(%edi),%eax
  802acb:	31 d2                	xor    %edx,%edx
  802acd:	83 c4 0c             	add    $0xc,%esp
  802ad0:	5e                   	pop    %esi
  802ad1:	5f                   	pop    %edi
  802ad2:	5d                   	pop    %ebp
  802ad3:	c3                   	ret    
  802ad4:	66 90                	xchg   %ax,%ax
  802ad6:	66 90                	xchg   %ax,%ax
  802ad8:	66 90                	xchg   %ax,%ax
  802ada:	66 90                	xchg   %ax,%ax
  802adc:	66 90                	xchg   %ax,%ax
  802ade:	66 90                	xchg   %ax,%ax

00802ae0 <__umoddi3>:
  802ae0:	55                   	push   %ebp
  802ae1:	57                   	push   %edi
  802ae2:	56                   	push   %esi
  802ae3:	83 ec 14             	sub    $0x14,%esp
  802ae6:	8b 44 24 28          	mov    0x28(%esp),%eax
  802aea:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802aee:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802af2:	89 c7                	mov    %eax,%edi
  802af4:	89 44 24 04          	mov    %eax,0x4(%esp)
  802af8:	8b 44 24 30          	mov    0x30(%esp),%eax
  802afc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802b00:	89 34 24             	mov    %esi,(%esp)
  802b03:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802b07:	85 c0                	test   %eax,%eax
  802b09:	89 c2                	mov    %eax,%edx
  802b0b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802b0f:	75 17                	jne    802b28 <__umoddi3+0x48>
  802b11:	39 fe                	cmp    %edi,%esi
  802b13:	76 4b                	jbe    802b60 <__umoddi3+0x80>
  802b15:	89 c8                	mov    %ecx,%eax
  802b17:	89 fa                	mov    %edi,%edx
  802b19:	f7 f6                	div    %esi
  802b1b:	89 d0                	mov    %edx,%eax
  802b1d:	31 d2                	xor    %edx,%edx
  802b1f:	83 c4 14             	add    $0x14,%esp
  802b22:	5e                   	pop    %esi
  802b23:	5f                   	pop    %edi
  802b24:	5d                   	pop    %ebp
  802b25:	c3                   	ret    
  802b26:	66 90                	xchg   %ax,%ax
  802b28:	39 f8                	cmp    %edi,%eax
  802b2a:	77 54                	ja     802b80 <__umoddi3+0xa0>
  802b2c:	0f bd e8             	bsr    %eax,%ebp
  802b2f:	83 f5 1f             	xor    $0x1f,%ebp
  802b32:	75 5c                	jne    802b90 <__umoddi3+0xb0>
  802b34:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802b38:	39 3c 24             	cmp    %edi,(%esp)
  802b3b:	0f 87 e7 00 00 00    	ja     802c28 <__umoddi3+0x148>
  802b41:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802b45:	29 f1                	sub    %esi,%ecx
  802b47:	19 c7                	sbb    %eax,%edi
  802b49:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802b4d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802b51:	8b 44 24 08          	mov    0x8(%esp),%eax
  802b55:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802b59:	83 c4 14             	add    $0x14,%esp
  802b5c:	5e                   	pop    %esi
  802b5d:	5f                   	pop    %edi
  802b5e:	5d                   	pop    %ebp
  802b5f:	c3                   	ret    
  802b60:	85 f6                	test   %esi,%esi
  802b62:	89 f5                	mov    %esi,%ebp
  802b64:	75 0b                	jne    802b71 <__umoddi3+0x91>
  802b66:	b8 01 00 00 00       	mov    $0x1,%eax
  802b6b:	31 d2                	xor    %edx,%edx
  802b6d:	f7 f6                	div    %esi
  802b6f:	89 c5                	mov    %eax,%ebp
  802b71:	8b 44 24 04          	mov    0x4(%esp),%eax
  802b75:	31 d2                	xor    %edx,%edx
  802b77:	f7 f5                	div    %ebp
  802b79:	89 c8                	mov    %ecx,%eax
  802b7b:	f7 f5                	div    %ebp
  802b7d:	eb 9c                	jmp    802b1b <__umoddi3+0x3b>
  802b7f:	90                   	nop
  802b80:	89 c8                	mov    %ecx,%eax
  802b82:	89 fa                	mov    %edi,%edx
  802b84:	83 c4 14             	add    $0x14,%esp
  802b87:	5e                   	pop    %esi
  802b88:	5f                   	pop    %edi
  802b89:	5d                   	pop    %ebp
  802b8a:	c3                   	ret    
  802b8b:	90                   	nop
  802b8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b90:	8b 04 24             	mov    (%esp),%eax
  802b93:	be 20 00 00 00       	mov    $0x20,%esi
  802b98:	89 e9                	mov    %ebp,%ecx
  802b9a:	29 ee                	sub    %ebp,%esi
  802b9c:	d3 e2                	shl    %cl,%edx
  802b9e:	89 f1                	mov    %esi,%ecx
  802ba0:	d3 e8                	shr    %cl,%eax
  802ba2:	89 e9                	mov    %ebp,%ecx
  802ba4:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ba8:	8b 04 24             	mov    (%esp),%eax
  802bab:	09 54 24 04          	or     %edx,0x4(%esp)
  802baf:	89 fa                	mov    %edi,%edx
  802bb1:	d3 e0                	shl    %cl,%eax
  802bb3:	89 f1                	mov    %esi,%ecx
  802bb5:	89 44 24 08          	mov    %eax,0x8(%esp)
  802bb9:	8b 44 24 10          	mov    0x10(%esp),%eax
  802bbd:	d3 ea                	shr    %cl,%edx
  802bbf:	89 e9                	mov    %ebp,%ecx
  802bc1:	d3 e7                	shl    %cl,%edi
  802bc3:	89 f1                	mov    %esi,%ecx
  802bc5:	d3 e8                	shr    %cl,%eax
  802bc7:	89 e9                	mov    %ebp,%ecx
  802bc9:	09 f8                	or     %edi,%eax
  802bcb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  802bcf:	f7 74 24 04          	divl   0x4(%esp)
  802bd3:	d3 e7                	shl    %cl,%edi
  802bd5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802bd9:	89 d7                	mov    %edx,%edi
  802bdb:	f7 64 24 08          	mull   0x8(%esp)
  802bdf:	39 d7                	cmp    %edx,%edi
  802be1:	89 c1                	mov    %eax,%ecx
  802be3:	89 14 24             	mov    %edx,(%esp)
  802be6:	72 2c                	jb     802c14 <__umoddi3+0x134>
  802be8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  802bec:	72 22                	jb     802c10 <__umoddi3+0x130>
  802bee:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802bf2:	29 c8                	sub    %ecx,%eax
  802bf4:	19 d7                	sbb    %edx,%edi
  802bf6:	89 e9                	mov    %ebp,%ecx
  802bf8:	89 fa                	mov    %edi,%edx
  802bfa:	d3 e8                	shr    %cl,%eax
  802bfc:	89 f1                	mov    %esi,%ecx
  802bfe:	d3 e2                	shl    %cl,%edx
  802c00:	89 e9                	mov    %ebp,%ecx
  802c02:	d3 ef                	shr    %cl,%edi
  802c04:	09 d0                	or     %edx,%eax
  802c06:	89 fa                	mov    %edi,%edx
  802c08:	83 c4 14             	add    $0x14,%esp
  802c0b:	5e                   	pop    %esi
  802c0c:	5f                   	pop    %edi
  802c0d:	5d                   	pop    %ebp
  802c0e:	c3                   	ret    
  802c0f:	90                   	nop
  802c10:	39 d7                	cmp    %edx,%edi
  802c12:	75 da                	jne    802bee <__umoddi3+0x10e>
  802c14:	8b 14 24             	mov    (%esp),%edx
  802c17:	89 c1                	mov    %eax,%ecx
  802c19:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  802c1d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802c21:	eb cb                	jmp    802bee <__umoddi3+0x10e>
  802c23:	90                   	nop
  802c24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802c28:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  802c2c:	0f 82 0f ff ff ff    	jb     802b41 <__umoddi3+0x61>
  802c32:	e9 1a ff ff ff       	jmp    802b51 <__umoddi3+0x71>
