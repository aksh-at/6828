
obj/user/faultregs.debug:     file format elf32-i386


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
  80002c:	e8 6a 05 00 00       	call   80059b <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	8b 45 08             	mov    0x8(%ebp),%eax
  800043:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800047:	89 54 24 08          	mov    %edx,0x8(%esp)
  80004b:	c7 44 24 04 d1 2b 80 	movl   $0x802bd1,0x4(%esp)
  800052:	00 
  800053:	c7 04 24 a0 2b 80 00 	movl   $0x802ba0,(%esp)
  80005a:	e8 96 06 00 00       	call   8006f5 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  80005f:	8b 03                	mov    (%ebx),%eax
  800061:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800065:	8b 06                	mov    (%esi),%eax
  800067:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006b:	c7 44 24 04 b0 2b 80 	movl   $0x802bb0,0x4(%esp)
  800072:	00 
  800073:	c7 04 24 b4 2b 80 00 	movl   $0x802bb4,(%esp)
  80007a:	e8 76 06 00 00       	call   8006f5 <cprintf>
  80007f:	8b 03                	mov    (%ebx),%eax
  800081:	39 06                	cmp    %eax,(%esi)
  800083:	75 13                	jne    800098 <check_regs+0x65>
  800085:	c7 04 24 c4 2b 80 00 	movl   $0x802bc4,(%esp)
  80008c:	e8 64 06 00 00       	call   8006f5 <cprintf>

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  800091:	bf 00 00 00 00       	mov    $0x0,%edi
  800096:	eb 11                	jmp    8000a9 <check_regs+0x76>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800098:	c7 04 24 c8 2b 80 00 	movl   $0x802bc8,(%esp)
  80009f:	e8 51 06 00 00       	call   8006f5 <cprintf>
  8000a4:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000a9:	8b 43 04             	mov    0x4(%ebx),%eax
  8000ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b0:	8b 46 04             	mov    0x4(%esi),%eax
  8000b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b7:	c7 44 24 04 d2 2b 80 	movl   $0x802bd2,0x4(%esp)
  8000be:	00 
  8000bf:	c7 04 24 b4 2b 80 00 	movl   $0x802bb4,(%esp)
  8000c6:	e8 2a 06 00 00       	call   8006f5 <cprintf>
  8000cb:	8b 43 04             	mov    0x4(%ebx),%eax
  8000ce:	39 46 04             	cmp    %eax,0x4(%esi)
  8000d1:	75 0e                	jne    8000e1 <check_regs+0xae>
  8000d3:	c7 04 24 c4 2b 80 00 	movl   $0x802bc4,(%esp)
  8000da:	e8 16 06 00 00       	call   8006f5 <cprintf>
  8000df:	eb 11                	jmp    8000f2 <check_regs+0xbf>
  8000e1:	c7 04 24 c8 2b 80 00 	movl   $0x802bc8,(%esp)
  8000e8:	e8 08 06 00 00       	call   8006f5 <cprintf>
  8000ed:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000f2:	8b 43 08             	mov    0x8(%ebx),%eax
  8000f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f9:	8b 46 08             	mov    0x8(%esi),%eax
  8000fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800100:	c7 44 24 04 d6 2b 80 	movl   $0x802bd6,0x4(%esp)
  800107:	00 
  800108:	c7 04 24 b4 2b 80 00 	movl   $0x802bb4,(%esp)
  80010f:	e8 e1 05 00 00       	call   8006f5 <cprintf>
  800114:	8b 43 08             	mov    0x8(%ebx),%eax
  800117:	39 46 08             	cmp    %eax,0x8(%esi)
  80011a:	75 0e                	jne    80012a <check_regs+0xf7>
  80011c:	c7 04 24 c4 2b 80 00 	movl   $0x802bc4,(%esp)
  800123:	e8 cd 05 00 00       	call   8006f5 <cprintf>
  800128:	eb 11                	jmp    80013b <check_regs+0x108>
  80012a:	c7 04 24 c8 2b 80 00 	movl   $0x802bc8,(%esp)
  800131:	e8 bf 05 00 00       	call   8006f5 <cprintf>
  800136:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  80013b:	8b 43 10             	mov    0x10(%ebx),%eax
  80013e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800142:	8b 46 10             	mov    0x10(%esi),%eax
  800145:	89 44 24 08          	mov    %eax,0x8(%esp)
  800149:	c7 44 24 04 da 2b 80 	movl   $0x802bda,0x4(%esp)
  800150:	00 
  800151:	c7 04 24 b4 2b 80 00 	movl   $0x802bb4,(%esp)
  800158:	e8 98 05 00 00       	call   8006f5 <cprintf>
  80015d:	8b 43 10             	mov    0x10(%ebx),%eax
  800160:	39 46 10             	cmp    %eax,0x10(%esi)
  800163:	75 0e                	jne    800173 <check_regs+0x140>
  800165:	c7 04 24 c4 2b 80 00 	movl   $0x802bc4,(%esp)
  80016c:	e8 84 05 00 00       	call   8006f5 <cprintf>
  800171:	eb 11                	jmp    800184 <check_regs+0x151>
  800173:	c7 04 24 c8 2b 80 00 	movl   $0x802bc8,(%esp)
  80017a:	e8 76 05 00 00       	call   8006f5 <cprintf>
  80017f:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800184:	8b 43 14             	mov    0x14(%ebx),%eax
  800187:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018b:	8b 46 14             	mov    0x14(%esi),%eax
  80018e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800192:	c7 44 24 04 de 2b 80 	movl   $0x802bde,0x4(%esp)
  800199:	00 
  80019a:	c7 04 24 b4 2b 80 00 	movl   $0x802bb4,(%esp)
  8001a1:	e8 4f 05 00 00       	call   8006f5 <cprintf>
  8001a6:	8b 43 14             	mov    0x14(%ebx),%eax
  8001a9:	39 46 14             	cmp    %eax,0x14(%esi)
  8001ac:	75 0e                	jne    8001bc <check_regs+0x189>
  8001ae:	c7 04 24 c4 2b 80 00 	movl   $0x802bc4,(%esp)
  8001b5:	e8 3b 05 00 00       	call   8006f5 <cprintf>
  8001ba:	eb 11                	jmp    8001cd <check_regs+0x19a>
  8001bc:	c7 04 24 c8 2b 80 00 	movl   $0x802bc8,(%esp)
  8001c3:	e8 2d 05 00 00       	call   8006f5 <cprintf>
  8001c8:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001cd:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d4:	8b 46 18             	mov    0x18(%esi),%eax
  8001d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001db:	c7 44 24 04 e2 2b 80 	movl   $0x802be2,0x4(%esp)
  8001e2:	00 
  8001e3:	c7 04 24 b4 2b 80 00 	movl   $0x802bb4,(%esp)
  8001ea:	e8 06 05 00 00       	call   8006f5 <cprintf>
  8001ef:	8b 43 18             	mov    0x18(%ebx),%eax
  8001f2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001f5:	75 0e                	jne    800205 <check_regs+0x1d2>
  8001f7:	c7 04 24 c4 2b 80 00 	movl   $0x802bc4,(%esp)
  8001fe:	e8 f2 04 00 00       	call   8006f5 <cprintf>
  800203:	eb 11                	jmp    800216 <check_regs+0x1e3>
  800205:	c7 04 24 c8 2b 80 00 	movl   $0x802bc8,(%esp)
  80020c:	e8 e4 04 00 00       	call   8006f5 <cprintf>
  800211:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021d:	8b 46 1c             	mov    0x1c(%esi),%eax
  800220:	89 44 24 08          	mov    %eax,0x8(%esp)
  800224:	c7 44 24 04 e6 2b 80 	movl   $0x802be6,0x4(%esp)
  80022b:	00 
  80022c:	c7 04 24 b4 2b 80 00 	movl   $0x802bb4,(%esp)
  800233:	e8 bd 04 00 00       	call   8006f5 <cprintf>
  800238:	8b 43 1c             	mov    0x1c(%ebx),%eax
  80023b:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80023e:	75 0e                	jne    80024e <check_regs+0x21b>
  800240:	c7 04 24 c4 2b 80 00 	movl   $0x802bc4,(%esp)
  800247:	e8 a9 04 00 00       	call   8006f5 <cprintf>
  80024c:	eb 11                	jmp    80025f <check_regs+0x22c>
  80024e:	c7 04 24 c8 2b 80 00 	movl   $0x802bc8,(%esp)
  800255:	e8 9b 04 00 00       	call   8006f5 <cprintf>
  80025a:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  80025f:	8b 43 20             	mov    0x20(%ebx),%eax
  800262:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800266:	8b 46 20             	mov    0x20(%esi),%eax
  800269:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026d:	c7 44 24 04 ea 2b 80 	movl   $0x802bea,0x4(%esp)
  800274:	00 
  800275:	c7 04 24 b4 2b 80 00 	movl   $0x802bb4,(%esp)
  80027c:	e8 74 04 00 00       	call   8006f5 <cprintf>
  800281:	8b 43 20             	mov    0x20(%ebx),%eax
  800284:	39 46 20             	cmp    %eax,0x20(%esi)
  800287:	75 0e                	jne    800297 <check_regs+0x264>
  800289:	c7 04 24 c4 2b 80 00 	movl   $0x802bc4,(%esp)
  800290:	e8 60 04 00 00       	call   8006f5 <cprintf>
  800295:	eb 11                	jmp    8002a8 <check_regs+0x275>
  800297:	c7 04 24 c8 2b 80 00 	movl   $0x802bc8,(%esp)
  80029e:	e8 52 04 00 00       	call   8006f5 <cprintf>
  8002a3:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002a8:	8b 43 24             	mov    0x24(%ebx),%eax
  8002ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002af:	8b 46 24             	mov    0x24(%esi),%eax
  8002b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b6:	c7 44 24 04 ee 2b 80 	movl   $0x802bee,0x4(%esp)
  8002bd:	00 
  8002be:	c7 04 24 b4 2b 80 00 	movl   $0x802bb4,(%esp)
  8002c5:	e8 2b 04 00 00       	call   8006f5 <cprintf>
  8002ca:	8b 43 24             	mov    0x24(%ebx),%eax
  8002cd:	39 46 24             	cmp    %eax,0x24(%esi)
  8002d0:	75 0e                	jne    8002e0 <check_regs+0x2ad>
  8002d2:	c7 04 24 c4 2b 80 00 	movl   $0x802bc4,(%esp)
  8002d9:	e8 17 04 00 00       	call   8006f5 <cprintf>
  8002de:	eb 11                	jmp    8002f1 <check_regs+0x2be>
  8002e0:	c7 04 24 c8 2b 80 00 	movl   $0x802bc8,(%esp)
  8002e7:	e8 09 04 00 00       	call   8006f5 <cprintf>
  8002ec:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002f1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f8:	8b 46 28             	mov    0x28(%esi),%eax
  8002fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ff:	c7 44 24 04 f5 2b 80 	movl   $0x802bf5,0x4(%esp)
  800306:	00 
  800307:	c7 04 24 b4 2b 80 00 	movl   $0x802bb4,(%esp)
  80030e:	e8 e2 03 00 00       	call   8006f5 <cprintf>
  800313:	8b 43 28             	mov    0x28(%ebx),%eax
  800316:	39 46 28             	cmp    %eax,0x28(%esi)
  800319:	75 25                	jne    800340 <check_regs+0x30d>
  80031b:	c7 04 24 c4 2b 80 00 	movl   $0x802bc4,(%esp)
  800322:	e8 ce 03 00 00       	call   8006f5 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800327:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032e:	c7 04 24 f9 2b 80 00 	movl   $0x802bf9,(%esp)
  800335:	e8 bb 03 00 00       	call   8006f5 <cprintf>
	if (!mismatch)
  80033a:	85 ff                	test   %edi,%edi
  80033c:	74 23                	je     800361 <check_regs+0x32e>
  80033e:	eb 2f                	jmp    80036f <check_regs+0x33c>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800340:	c7 04 24 c8 2b 80 00 	movl   $0x802bc8,(%esp)
  800347:	e8 a9 03 00 00       	call   8006f5 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80034c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80034f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800353:	c7 04 24 f9 2b 80 00 	movl   $0x802bf9,(%esp)
  80035a:	e8 96 03 00 00       	call   8006f5 <cprintf>
  80035f:	eb 0e                	jmp    80036f <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  800361:	c7 04 24 c4 2b 80 00 	movl   $0x802bc4,(%esp)
  800368:	e8 88 03 00 00       	call   8006f5 <cprintf>
  80036d:	eb 0c                	jmp    80037b <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  80036f:	c7 04 24 c8 2b 80 00 	movl   $0x802bc8,(%esp)
  800376:	e8 7a 03 00 00       	call   8006f5 <cprintf>
}
  80037b:	83 c4 1c             	add    $0x1c,%esp
  80037e:	5b                   	pop    %ebx
  80037f:	5e                   	pop    %esi
  800380:	5f                   	pop    %edi
  800381:	5d                   	pop    %ebp
  800382:	c3                   	ret    

00800383 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	83 ec 28             	sub    $0x28,%esp
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  80038c:	8b 10                	mov    (%eax),%edx
  80038e:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  800394:	74 27                	je     8003bd <pgfault+0x3a>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  800396:	8b 40 28             	mov    0x28(%eax),%eax
  800399:	89 44 24 10          	mov    %eax,0x10(%esp)
  80039d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a1:	c7 44 24 08 60 2c 80 	movl   $0x802c60,0x8(%esp)
  8003a8:	00 
  8003a9:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8003b0:	00 
  8003b1:	c7 04 24 07 2c 80 00 	movl   $0x802c07,(%esp)
  8003b8:	e8 3f 02 00 00       	call   8005fc <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003bd:	8b 50 08             	mov    0x8(%eax),%edx
  8003c0:	89 15 40 50 80 00    	mov    %edx,0x805040
  8003c6:	8b 50 0c             	mov    0xc(%eax),%edx
  8003c9:	89 15 44 50 80 00    	mov    %edx,0x805044
  8003cf:	8b 50 10             	mov    0x10(%eax),%edx
  8003d2:	89 15 48 50 80 00    	mov    %edx,0x805048
  8003d8:	8b 50 14             	mov    0x14(%eax),%edx
  8003db:	89 15 4c 50 80 00    	mov    %edx,0x80504c
  8003e1:	8b 50 18             	mov    0x18(%eax),%edx
  8003e4:	89 15 50 50 80 00    	mov    %edx,0x805050
  8003ea:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003ed:	89 15 54 50 80 00    	mov    %edx,0x805054
  8003f3:	8b 50 20             	mov    0x20(%eax),%edx
  8003f6:	89 15 58 50 80 00    	mov    %edx,0x805058
  8003fc:	8b 50 24             	mov    0x24(%eax),%edx
  8003ff:	89 15 5c 50 80 00    	mov    %edx,0x80505c
	during.eip = utf->utf_eip;
  800405:	8b 50 28             	mov    0x28(%eax),%edx
  800408:	89 15 60 50 80 00    	mov    %edx,0x805060
	during.eflags = utf->utf_eflags & ~FL_RF;
  80040e:	8b 50 2c             	mov    0x2c(%eax),%edx
  800411:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  800417:	89 15 64 50 80 00    	mov    %edx,0x805064
	during.esp = utf->utf_esp;
  80041d:	8b 40 30             	mov    0x30(%eax),%eax
  800420:	a3 68 50 80 00       	mov    %eax,0x805068
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800425:	c7 44 24 04 1f 2c 80 	movl   $0x802c1f,0x4(%esp)
  80042c:	00 
  80042d:	c7 04 24 2d 2c 80 00 	movl   $0x802c2d,(%esp)
  800434:	b9 40 50 80 00       	mov    $0x805040,%ecx
  800439:	ba 18 2c 80 00       	mov    $0x802c18,%edx
  80043e:	b8 80 50 80 00       	mov    $0x805080,%eax
  800443:	e8 eb fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800448:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80044f:	00 
  800450:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  800457:	00 
  800458:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80045f:	e8 cf 0c 00 00       	call   801133 <sys_page_alloc>
  800464:	85 c0                	test   %eax,%eax
  800466:	79 20                	jns    800488 <pgfault+0x105>
		panic("sys_page_alloc: %e", r);
  800468:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80046c:	c7 44 24 08 34 2c 80 	movl   $0x802c34,0x8(%esp)
  800473:	00 
  800474:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  80047b:	00 
  80047c:	c7 04 24 07 2c 80 00 	movl   $0x802c07,(%esp)
  800483:	e8 74 01 00 00       	call   8005fc <_panic>
}
  800488:	c9                   	leave  
  800489:	c3                   	ret    

0080048a <umain>:

void
umain(int argc, char **argv)
{
  80048a:	55                   	push   %ebp
  80048b:	89 e5                	mov    %esp,%ebp
  80048d:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  800490:	c7 04 24 83 03 80 00 	movl   $0x800383,(%esp)
  800497:	e8 c4 0f 00 00       	call   801460 <set_pgfault_handler>

	asm volatile(
  80049c:	50                   	push   %eax
  80049d:	9c                   	pushf  
  80049e:	58                   	pop    %eax
  80049f:	0d d5 08 00 00       	or     $0x8d5,%eax
  8004a4:	50                   	push   %eax
  8004a5:	9d                   	popf   
  8004a6:	a3 a4 50 80 00       	mov    %eax,0x8050a4
  8004ab:	8d 05 e6 04 80 00    	lea    0x8004e6,%eax
  8004b1:	a3 a0 50 80 00       	mov    %eax,0x8050a0
  8004b6:	58                   	pop    %eax
  8004b7:	89 3d 80 50 80 00    	mov    %edi,0x805080
  8004bd:	89 35 84 50 80 00    	mov    %esi,0x805084
  8004c3:	89 2d 88 50 80 00    	mov    %ebp,0x805088
  8004c9:	89 1d 90 50 80 00    	mov    %ebx,0x805090
  8004cf:	89 15 94 50 80 00    	mov    %edx,0x805094
  8004d5:	89 0d 98 50 80 00    	mov    %ecx,0x805098
  8004db:	a3 9c 50 80 00       	mov    %eax,0x80509c
  8004e0:	89 25 a8 50 80 00    	mov    %esp,0x8050a8
  8004e6:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004ed:	00 00 00 
  8004f0:	89 3d 00 50 80 00    	mov    %edi,0x805000
  8004f6:	89 35 04 50 80 00    	mov    %esi,0x805004
  8004fc:	89 2d 08 50 80 00    	mov    %ebp,0x805008
  800502:	89 1d 10 50 80 00    	mov    %ebx,0x805010
  800508:	89 15 14 50 80 00    	mov    %edx,0x805014
  80050e:	89 0d 18 50 80 00    	mov    %ecx,0x805018
  800514:	a3 1c 50 80 00       	mov    %eax,0x80501c
  800519:	89 25 28 50 80 00    	mov    %esp,0x805028
  80051f:	8b 3d 80 50 80 00    	mov    0x805080,%edi
  800525:	8b 35 84 50 80 00    	mov    0x805084,%esi
  80052b:	8b 2d 88 50 80 00    	mov    0x805088,%ebp
  800531:	8b 1d 90 50 80 00    	mov    0x805090,%ebx
  800537:	8b 15 94 50 80 00    	mov    0x805094,%edx
  80053d:	8b 0d 98 50 80 00    	mov    0x805098,%ecx
  800543:	a1 9c 50 80 00       	mov    0x80509c,%eax
  800548:	8b 25 a8 50 80 00    	mov    0x8050a8,%esp
  80054e:	50                   	push   %eax
  80054f:	9c                   	pushf  
  800550:	58                   	pop    %eax
  800551:	a3 24 50 80 00       	mov    %eax,0x805024
  800556:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800557:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  80055e:	74 0c                	je     80056c <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  800560:	c7 04 24 94 2c 80 00 	movl   $0x802c94,(%esp)
  800567:	e8 89 01 00 00       	call   8006f5 <cprintf>
	after.eip = before.eip;
  80056c:	a1 a0 50 80 00       	mov    0x8050a0,%eax
  800571:	a3 20 50 80 00       	mov    %eax,0x805020

	check_regs(&before, "before", &after, "after", "after page-fault");
  800576:	c7 44 24 04 47 2c 80 	movl   $0x802c47,0x4(%esp)
  80057d:	00 
  80057e:	c7 04 24 58 2c 80 00 	movl   $0x802c58,(%esp)
  800585:	b9 00 50 80 00       	mov    $0x805000,%ecx
  80058a:	ba 18 2c 80 00       	mov    $0x802c18,%edx
  80058f:	b8 80 50 80 00       	mov    $0x805080,%eax
  800594:	e8 9a fa ff ff       	call   800033 <check_regs>
}
  800599:	c9                   	leave  
  80059a:	c3                   	ret    

0080059b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80059b:	55                   	push   %ebp
  80059c:	89 e5                	mov    %esp,%ebp
  80059e:	56                   	push   %esi
  80059f:	53                   	push   %ebx
  8005a0:	83 ec 10             	sub    $0x10,%esp
  8005a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005a6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  8005a9:	e8 47 0b 00 00       	call   8010f5 <sys_getenvid>
  8005ae:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005b3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005b6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005bb:	a3 b4 50 80 00       	mov    %eax,0x8050b4

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005c0:	85 db                	test   %ebx,%ebx
  8005c2:	7e 07                	jle    8005cb <libmain+0x30>
		binaryname = argv[0];
  8005c4:	8b 06                	mov    (%esi),%eax
  8005c6:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  8005cb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005cf:	89 1c 24             	mov    %ebx,(%esp)
  8005d2:	e8 b3 fe ff ff       	call   80048a <umain>

	// exit gracefully
	exit();
  8005d7:	e8 07 00 00 00       	call   8005e3 <exit>
}
  8005dc:	83 c4 10             	add    $0x10,%esp
  8005df:	5b                   	pop    %ebx
  8005e0:	5e                   	pop    %esi
  8005e1:	5d                   	pop    %ebp
  8005e2:	c3                   	ret    

008005e3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005e3:	55                   	push   %ebp
  8005e4:	89 e5                	mov    %esp,%ebp
  8005e6:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8005e9:	e8 cc 10 00 00       	call   8016ba <close_all>
	sys_env_destroy(0);
  8005ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005f5:	e8 a9 0a 00 00       	call   8010a3 <sys_env_destroy>
}
  8005fa:	c9                   	leave  
  8005fb:	c3                   	ret    

008005fc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005fc:	55                   	push   %ebp
  8005fd:	89 e5                	mov    %esp,%ebp
  8005ff:	56                   	push   %esi
  800600:	53                   	push   %ebx
  800601:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800604:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800607:	8b 35 00 40 80 00    	mov    0x804000,%esi
  80060d:	e8 e3 0a 00 00       	call   8010f5 <sys_getenvid>
  800612:	8b 55 0c             	mov    0xc(%ebp),%edx
  800615:	89 54 24 10          	mov    %edx,0x10(%esp)
  800619:	8b 55 08             	mov    0x8(%ebp),%edx
  80061c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800620:	89 74 24 08          	mov    %esi,0x8(%esp)
  800624:	89 44 24 04          	mov    %eax,0x4(%esp)
  800628:	c7 04 24 c0 2c 80 00 	movl   $0x802cc0,(%esp)
  80062f:	e8 c1 00 00 00       	call   8006f5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800634:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800638:	8b 45 10             	mov    0x10(%ebp),%eax
  80063b:	89 04 24             	mov    %eax,(%esp)
  80063e:	e8 51 00 00 00       	call   800694 <vcprintf>
	cprintf("\n");
  800643:	c7 04 24 d0 2b 80 00 	movl   $0x802bd0,(%esp)
  80064a:	e8 a6 00 00 00       	call   8006f5 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80064f:	cc                   	int3   
  800650:	eb fd                	jmp    80064f <_panic+0x53>

00800652 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800652:	55                   	push   %ebp
  800653:	89 e5                	mov    %esp,%ebp
  800655:	53                   	push   %ebx
  800656:	83 ec 14             	sub    $0x14,%esp
  800659:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80065c:	8b 13                	mov    (%ebx),%edx
  80065e:	8d 42 01             	lea    0x1(%edx),%eax
  800661:	89 03                	mov    %eax,(%ebx)
  800663:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800666:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80066a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80066f:	75 19                	jne    80068a <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800671:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800678:	00 
  800679:	8d 43 08             	lea    0x8(%ebx),%eax
  80067c:	89 04 24             	mov    %eax,(%esp)
  80067f:	e8 e2 09 00 00       	call   801066 <sys_cputs>
		b->idx = 0;
  800684:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80068a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80068e:	83 c4 14             	add    $0x14,%esp
  800691:	5b                   	pop    %ebx
  800692:	5d                   	pop    %ebp
  800693:	c3                   	ret    

00800694 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800694:	55                   	push   %ebp
  800695:	89 e5                	mov    %esp,%ebp
  800697:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80069d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006a4:	00 00 00 
	b.cnt = 0;
  8006a7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006ae:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006bf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c9:	c7 04 24 52 06 80 00 	movl   $0x800652,(%esp)
  8006d0:	e8 a9 01 00 00       	call   80087e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006d5:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006df:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006e5:	89 04 24             	mov    %eax,(%esp)
  8006e8:	e8 79 09 00 00       	call   801066 <sys_cputs>

	return b.cnt;
}
  8006ed:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006f3:	c9                   	leave  
  8006f4:	c3                   	ret    

008006f5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006fb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800702:	8b 45 08             	mov    0x8(%ebp),%eax
  800705:	89 04 24             	mov    %eax,(%esp)
  800708:	e8 87 ff ff ff       	call   800694 <vcprintf>
	va_end(ap);

	return cnt;
}
  80070d:	c9                   	leave  
  80070e:	c3                   	ret    
  80070f:	90                   	nop

00800710 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	57                   	push   %edi
  800714:	56                   	push   %esi
  800715:	53                   	push   %ebx
  800716:	83 ec 3c             	sub    $0x3c,%esp
  800719:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80071c:	89 d7                	mov    %edx,%edi
  80071e:	8b 45 08             	mov    0x8(%ebp),%eax
  800721:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800724:	8b 45 0c             	mov    0xc(%ebp),%eax
  800727:	89 c3                	mov    %eax,%ebx
  800729:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80072c:	8b 45 10             	mov    0x10(%ebp),%eax
  80072f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800732:	b9 00 00 00 00       	mov    $0x0,%ecx
  800737:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80073a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80073d:	39 d9                	cmp    %ebx,%ecx
  80073f:	72 05                	jb     800746 <printnum+0x36>
  800741:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800744:	77 69                	ja     8007af <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800746:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800749:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80074d:	83 ee 01             	sub    $0x1,%esi
  800750:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800754:	89 44 24 08          	mov    %eax,0x8(%esp)
  800758:	8b 44 24 08          	mov    0x8(%esp),%eax
  80075c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800760:	89 c3                	mov    %eax,%ebx
  800762:	89 d6                	mov    %edx,%esi
  800764:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800767:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80076a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80076e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800772:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800775:	89 04 24             	mov    %eax,(%esp)
  800778:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80077b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077f:	e8 7c 21 00 00       	call   802900 <__udivdi3>
  800784:	89 d9                	mov    %ebx,%ecx
  800786:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80078a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80078e:	89 04 24             	mov    %eax,(%esp)
  800791:	89 54 24 04          	mov    %edx,0x4(%esp)
  800795:	89 fa                	mov    %edi,%edx
  800797:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80079a:	e8 71 ff ff ff       	call   800710 <printnum>
  80079f:	eb 1b                	jmp    8007bc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007a5:	8b 45 18             	mov    0x18(%ebp),%eax
  8007a8:	89 04 24             	mov    %eax,(%esp)
  8007ab:	ff d3                	call   *%ebx
  8007ad:	eb 03                	jmp    8007b2 <printnum+0xa2>
  8007af:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007b2:	83 ee 01             	sub    $0x1,%esi
  8007b5:	85 f6                	test   %esi,%esi
  8007b7:	7f e8                	jg     8007a1 <printnum+0x91>
  8007b9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007bc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007c0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8007c4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007c7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007d5:	89 04 24             	mov    %eax,(%esp)
  8007d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007df:	e8 4c 22 00 00       	call   802a30 <__umoddi3>
  8007e4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007e8:	0f be 80 e3 2c 80 00 	movsbl 0x802ce3(%eax),%eax
  8007ef:	89 04 24             	mov    %eax,(%esp)
  8007f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007f5:	ff d0                	call   *%eax
}
  8007f7:	83 c4 3c             	add    $0x3c,%esp
  8007fa:	5b                   	pop    %ebx
  8007fb:	5e                   	pop    %esi
  8007fc:	5f                   	pop    %edi
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800802:	83 fa 01             	cmp    $0x1,%edx
  800805:	7e 0e                	jle    800815 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800807:	8b 10                	mov    (%eax),%edx
  800809:	8d 4a 08             	lea    0x8(%edx),%ecx
  80080c:	89 08                	mov    %ecx,(%eax)
  80080e:	8b 02                	mov    (%edx),%eax
  800810:	8b 52 04             	mov    0x4(%edx),%edx
  800813:	eb 22                	jmp    800837 <getuint+0x38>
	else if (lflag)
  800815:	85 d2                	test   %edx,%edx
  800817:	74 10                	je     800829 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800819:	8b 10                	mov    (%eax),%edx
  80081b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80081e:	89 08                	mov    %ecx,(%eax)
  800820:	8b 02                	mov    (%edx),%eax
  800822:	ba 00 00 00 00       	mov    $0x0,%edx
  800827:	eb 0e                	jmp    800837 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800829:	8b 10                	mov    (%eax),%edx
  80082b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80082e:	89 08                	mov    %ecx,(%eax)
  800830:	8b 02                	mov    (%edx),%eax
  800832:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800837:	5d                   	pop    %ebp
  800838:	c3                   	ret    

00800839 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80083f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800843:	8b 10                	mov    (%eax),%edx
  800845:	3b 50 04             	cmp    0x4(%eax),%edx
  800848:	73 0a                	jae    800854 <sprintputch+0x1b>
		*b->buf++ = ch;
  80084a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80084d:	89 08                	mov    %ecx,(%eax)
  80084f:	8b 45 08             	mov    0x8(%ebp),%eax
  800852:	88 02                	mov    %al,(%edx)
}
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80085c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80085f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800863:	8b 45 10             	mov    0x10(%ebp),%eax
  800866:	89 44 24 08          	mov    %eax,0x8(%esp)
  80086a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800871:	8b 45 08             	mov    0x8(%ebp),%eax
  800874:	89 04 24             	mov    %eax,(%esp)
  800877:	e8 02 00 00 00       	call   80087e <vprintfmt>
	va_end(ap);
}
  80087c:	c9                   	leave  
  80087d:	c3                   	ret    

0080087e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	57                   	push   %edi
  800882:	56                   	push   %esi
  800883:	53                   	push   %ebx
  800884:	83 ec 3c             	sub    $0x3c,%esp
  800887:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80088a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80088d:	eb 14                	jmp    8008a3 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80088f:	85 c0                	test   %eax,%eax
  800891:	0f 84 b3 03 00 00    	je     800c4a <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800897:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80089b:	89 04 24             	mov    %eax,(%esp)
  80089e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008a1:	89 f3                	mov    %esi,%ebx
  8008a3:	8d 73 01             	lea    0x1(%ebx),%esi
  8008a6:	0f b6 03             	movzbl (%ebx),%eax
  8008a9:	83 f8 25             	cmp    $0x25,%eax
  8008ac:	75 e1                	jne    80088f <vprintfmt+0x11>
  8008ae:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8008b2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8008b9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8008c0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8008c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8008cc:	eb 1d                	jmp    8008eb <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ce:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8008d0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8008d4:	eb 15                	jmp    8008eb <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008d8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8008dc:	eb 0d                	jmp    8008eb <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8008de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8008e1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8008e4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008eb:	8d 5e 01             	lea    0x1(%esi),%ebx
  8008ee:	0f b6 0e             	movzbl (%esi),%ecx
  8008f1:	0f b6 c1             	movzbl %cl,%eax
  8008f4:	83 e9 23             	sub    $0x23,%ecx
  8008f7:	80 f9 55             	cmp    $0x55,%cl
  8008fa:	0f 87 2a 03 00 00    	ja     800c2a <vprintfmt+0x3ac>
  800900:	0f b6 c9             	movzbl %cl,%ecx
  800903:	ff 24 8d 20 2e 80 00 	jmp    *0x802e20(,%ecx,4)
  80090a:	89 de                	mov    %ebx,%esi
  80090c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800911:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800914:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800918:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80091b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80091e:	83 fb 09             	cmp    $0x9,%ebx
  800921:	77 36                	ja     800959 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800923:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800926:	eb e9                	jmp    800911 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800928:	8b 45 14             	mov    0x14(%ebp),%eax
  80092b:	8d 48 04             	lea    0x4(%eax),%ecx
  80092e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800931:	8b 00                	mov    (%eax),%eax
  800933:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800936:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800938:	eb 22                	jmp    80095c <vprintfmt+0xde>
  80093a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80093d:	85 c9                	test   %ecx,%ecx
  80093f:	b8 00 00 00 00       	mov    $0x0,%eax
  800944:	0f 49 c1             	cmovns %ecx,%eax
  800947:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80094a:	89 de                	mov    %ebx,%esi
  80094c:	eb 9d                	jmp    8008eb <vprintfmt+0x6d>
  80094e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800950:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800957:	eb 92                	jmp    8008eb <vprintfmt+0x6d>
  800959:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80095c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800960:	79 89                	jns    8008eb <vprintfmt+0x6d>
  800962:	e9 77 ff ff ff       	jmp    8008de <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800967:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80096a:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80096c:	e9 7a ff ff ff       	jmp    8008eb <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800971:	8b 45 14             	mov    0x14(%ebp),%eax
  800974:	8d 50 04             	lea    0x4(%eax),%edx
  800977:	89 55 14             	mov    %edx,0x14(%ebp)
  80097a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80097e:	8b 00                	mov    (%eax),%eax
  800980:	89 04 24             	mov    %eax,(%esp)
  800983:	ff 55 08             	call   *0x8(%ebp)
			break;
  800986:	e9 18 ff ff ff       	jmp    8008a3 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80098b:	8b 45 14             	mov    0x14(%ebp),%eax
  80098e:	8d 50 04             	lea    0x4(%eax),%edx
  800991:	89 55 14             	mov    %edx,0x14(%ebp)
  800994:	8b 00                	mov    (%eax),%eax
  800996:	99                   	cltd   
  800997:	31 d0                	xor    %edx,%eax
  800999:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80099b:	83 f8 0f             	cmp    $0xf,%eax
  80099e:	7f 0b                	jg     8009ab <vprintfmt+0x12d>
  8009a0:	8b 14 85 80 2f 80 00 	mov    0x802f80(,%eax,4),%edx
  8009a7:	85 d2                	test   %edx,%edx
  8009a9:	75 20                	jne    8009cb <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  8009ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009af:	c7 44 24 08 fb 2c 80 	movl   $0x802cfb,0x8(%esp)
  8009b6:	00 
  8009b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	89 04 24             	mov    %eax,(%esp)
  8009c1:	e8 90 fe ff ff       	call   800856 <printfmt>
  8009c6:	e9 d8 fe ff ff       	jmp    8008a3 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8009cb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009cf:	c7 44 24 08 b5 30 80 	movl   $0x8030b5,0x8(%esp)
  8009d6:	00 
  8009d7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	89 04 24             	mov    %eax,(%esp)
  8009e1:	e8 70 fe ff ff       	call   800856 <printfmt>
  8009e6:	e9 b8 fe ff ff       	jmp    8008a3 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009eb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8009ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8009f1:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f7:	8d 50 04             	lea    0x4(%eax),%edx
  8009fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8009fd:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8009ff:	85 f6                	test   %esi,%esi
  800a01:	b8 f4 2c 80 00       	mov    $0x802cf4,%eax
  800a06:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800a09:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800a0d:	0f 84 97 00 00 00    	je     800aaa <vprintfmt+0x22c>
  800a13:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800a17:	0f 8e 9b 00 00 00    	jle    800ab8 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a1d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a21:	89 34 24             	mov    %esi,(%esp)
  800a24:	e8 cf 02 00 00       	call   800cf8 <strnlen>
  800a29:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a2c:	29 c2                	sub    %eax,%edx
  800a2e:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800a31:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800a35:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800a38:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800a3b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a3e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a41:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a43:	eb 0f                	jmp    800a54 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800a45:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a49:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a4c:	89 04 24             	mov    %eax,(%esp)
  800a4f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a51:	83 eb 01             	sub    $0x1,%ebx
  800a54:	85 db                	test   %ebx,%ebx
  800a56:	7f ed                	jg     800a45 <vprintfmt+0x1c7>
  800a58:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800a5b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a5e:	85 d2                	test   %edx,%edx
  800a60:	b8 00 00 00 00       	mov    $0x0,%eax
  800a65:	0f 49 c2             	cmovns %edx,%eax
  800a68:	29 c2                	sub    %eax,%edx
  800a6a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800a6d:	89 d7                	mov    %edx,%edi
  800a6f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800a72:	eb 50                	jmp    800ac4 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a74:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a78:	74 1e                	je     800a98 <vprintfmt+0x21a>
  800a7a:	0f be d2             	movsbl %dl,%edx
  800a7d:	83 ea 20             	sub    $0x20,%edx
  800a80:	83 fa 5e             	cmp    $0x5e,%edx
  800a83:	76 13                	jbe    800a98 <vprintfmt+0x21a>
					putch('?', putdat);
  800a85:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a88:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a8c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a93:	ff 55 08             	call   *0x8(%ebp)
  800a96:	eb 0d                	jmp    800aa5 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800a98:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9b:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a9f:	89 04 24             	mov    %eax,(%esp)
  800aa2:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800aa5:	83 ef 01             	sub    $0x1,%edi
  800aa8:	eb 1a                	jmp    800ac4 <vprintfmt+0x246>
  800aaa:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800aad:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800ab0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ab3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800ab6:	eb 0c                	jmp    800ac4 <vprintfmt+0x246>
  800ab8:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800abb:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800abe:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ac1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800ac4:	83 c6 01             	add    $0x1,%esi
  800ac7:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800acb:	0f be c2             	movsbl %dl,%eax
  800ace:	85 c0                	test   %eax,%eax
  800ad0:	74 27                	je     800af9 <vprintfmt+0x27b>
  800ad2:	85 db                	test   %ebx,%ebx
  800ad4:	78 9e                	js     800a74 <vprintfmt+0x1f6>
  800ad6:	83 eb 01             	sub    $0x1,%ebx
  800ad9:	79 99                	jns    800a74 <vprintfmt+0x1f6>
  800adb:	89 f8                	mov    %edi,%eax
  800add:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ae0:	8b 75 08             	mov    0x8(%ebp),%esi
  800ae3:	89 c3                	mov    %eax,%ebx
  800ae5:	eb 1a                	jmp    800b01 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800ae7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aeb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800af2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800af4:	83 eb 01             	sub    $0x1,%ebx
  800af7:	eb 08                	jmp    800b01 <vprintfmt+0x283>
  800af9:	89 fb                	mov    %edi,%ebx
  800afb:	8b 75 08             	mov    0x8(%ebp),%esi
  800afe:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b01:	85 db                	test   %ebx,%ebx
  800b03:	7f e2                	jg     800ae7 <vprintfmt+0x269>
  800b05:	89 75 08             	mov    %esi,0x8(%ebp)
  800b08:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b0b:	e9 93 fd ff ff       	jmp    8008a3 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b10:	83 fa 01             	cmp    $0x1,%edx
  800b13:	7e 16                	jle    800b2b <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800b15:	8b 45 14             	mov    0x14(%ebp),%eax
  800b18:	8d 50 08             	lea    0x8(%eax),%edx
  800b1b:	89 55 14             	mov    %edx,0x14(%ebp)
  800b1e:	8b 50 04             	mov    0x4(%eax),%edx
  800b21:	8b 00                	mov    (%eax),%eax
  800b23:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b26:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800b29:	eb 32                	jmp    800b5d <vprintfmt+0x2df>
	else if (lflag)
  800b2b:	85 d2                	test   %edx,%edx
  800b2d:	74 18                	je     800b47 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  800b2f:	8b 45 14             	mov    0x14(%ebp),%eax
  800b32:	8d 50 04             	lea    0x4(%eax),%edx
  800b35:	89 55 14             	mov    %edx,0x14(%ebp)
  800b38:	8b 30                	mov    (%eax),%esi
  800b3a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800b3d:	89 f0                	mov    %esi,%eax
  800b3f:	c1 f8 1f             	sar    $0x1f,%eax
  800b42:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b45:	eb 16                	jmp    800b5d <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800b47:	8b 45 14             	mov    0x14(%ebp),%eax
  800b4a:	8d 50 04             	lea    0x4(%eax),%edx
  800b4d:	89 55 14             	mov    %edx,0x14(%ebp)
  800b50:	8b 30                	mov    (%eax),%esi
  800b52:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800b55:	89 f0                	mov    %esi,%eax
  800b57:	c1 f8 1f             	sar    $0x1f,%eax
  800b5a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b5d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b60:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b63:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b68:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b6c:	0f 89 80 00 00 00    	jns    800bf2 <vprintfmt+0x374>
				putch('-', putdat);
  800b72:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b76:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800b7d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800b80:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b83:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b86:	f7 d8                	neg    %eax
  800b88:	83 d2 00             	adc    $0x0,%edx
  800b8b:	f7 da                	neg    %edx
			}
			base = 10;
  800b8d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b92:	eb 5e                	jmp    800bf2 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b94:	8d 45 14             	lea    0x14(%ebp),%eax
  800b97:	e8 63 fc ff ff       	call   8007ff <getuint>
			base = 10;
  800b9c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800ba1:	eb 4f                	jmp    800bf2 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800ba3:	8d 45 14             	lea    0x14(%ebp),%eax
  800ba6:	e8 54 fc ff ff       	call   8007ff <getuint>
			base = 8;
  800bab:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800bb0:	eb 40                	jmp    800bf2 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800bb2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bb6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800bbd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800bc0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bc4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800bcb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800bce:	8b 45 14             	mov    0x14(%ebp),%eax
  800bd1:	8d 50 04             	lea    0x4(%eax),%edx
  800bd4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bd7:	8b 00                	mov    (%eax),%eax
  800bd9:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bde:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800be3:	eb 0d                	jmp    800bf2 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800be5:	8d 45 14             	lea    0x14(%ebp),%eax
  800be8:	e8 12 fc ff ff       	call   8007ff <getuint>
			base = 16;
  800bed:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bf2:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800bf6:	89 74 24 10          	mov    %esi,0x10(%esp)
  800bfa:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800bfd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800c01:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c05:	89 04 24             	mov    %eax,(%esp)
  800c08:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c0c:	89 fa                	mov    %edi,%edx
  800c0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c11:	e8 fa fa ff ff       	call   800710 <printnum>
			break;
  800c16:	e9 88 fc ff ff       	jmp    8008a3 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c1b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c1f:	89 04 24             	mov    %eax,(%esp)
  800c22:	ff 55 08             	call   *0x8(%ebp)
			break;
  800c25:	e9 79 fc ff ff       	jmp    8008a3 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c2a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c2e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800c35:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c38:	89 f3                	mov    %esi,%ebx
  800c3a:	eb 03                	jmp    800c3f <vprintfmt+0x3c1>
  800c3c:	83 eb 01             	sub    $0x1,%ebx
  800c3f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800c43:	75 f7                	jne    800c3c <vprintfmt+0x3be>
  800c45:	e9 59 fc ff ff       	jmp    8008a3 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800c4a:	83 c4 3c             	add    $0x3c,%esp
  800c4d:	5b                   	pop    %ebx
  800c4e:	5e                   	pop    %esi
  800c4f:	5f                   	pop    %edi
  800c50:	5d                   	pop    %ebp
  800c51:	c3                   	ret    

00800c52 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	83 ec 28             	sub    $0x28,%esp
  800c58:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c5e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c61:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c65:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c68:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c6f:	85 c0                	test   %eax,%eax
  800c71:	74 30                	je     800ca3 <vsnprintf+0x51>
  800c73:	85 d2                	test   %edx,%edx
  800c75:	7e 2c                	jle    800ca3 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c77:	8b 45 14             	mov    0x14(%ebp),%eax
  800c7a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c7e:	8b 45 10             	mov    0x10(%ebp),%eax
  800c81:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c85:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c88:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c8c:	c7 04 24 39 08 80 00 	movl   $0x800839,(%esp)
  800c93:	e8 e6 fb ff ff       	call   80087e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c98:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c9b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca1:	eb 05                	jmp    800ca8 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ca3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ca8:	c9                   	leave  
  800ca9:	c3                   	ret    

00800caa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cb0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cb3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cb7:	8b 45 10             	mov    0x10(%ebp),%eax
  800cba:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc8:	89 04 24             	mov    %eax,(%esp)
  800ccb:	e8 82 ff ff ff       	call   800c52 <vsnprintf>
	va_end(ap);

	return rc;
}
  800cd0:	c9                   	leave  
  800cd1:	c3                   	ret    
  800cd2:	66 90                	xchg   %ax,%ax
  800cd4:	66 90                	xchg   %ax,%ax
  800cd6:	66 90                	xchg   %ax,%ax
  800cd8:	66 90                	xchg   %ax,%ax
  800cda:	66 90                	xchg   %ax,%ax
  800cdc:	66 90                	xchg   %ax,%ax
  800cde:	66 90                	xchg   %ax,%ax

00800ce0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ce6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ceb:	eb 03                	jmp    800cf0 <strlen+0x10>
		n++;
  800ced:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800cf0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800cf4:	75 f7                	jne    800ced <strlen+0xd>
		n++;
	return n;
}
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cfe:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d01:	b8 00 00 00 00       	mov    $0x0,%eax
  800d06:	eb 03                	jmp    800d0b <strnlen+0x13>
		n++;
  800d08:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d0b:	39 d0                	cmp    %edx,%eax
  800d0d:	74 06                	je     800d15 <strnlen+0x1d>
  800d0f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800d13:	75 f3                	jne    800d08 <strnlen+0x10>
		n++;
	return n;
}
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	53                   	push   %ebx
  800d1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d21:	89 c2                	mov    %eax,%edx
  800d23:	83 c2 01             	add    $0x1,%edx
  800d26:	83 c1 01             	add    $0x1,%ecx
  800d29:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d2d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d30:	84 db                	test   %bl,%bl
  800d32:	75 ef                	jne    800d23 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d34:	5b                   	pop    %ebx
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    

00800d37 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	53                   	push   %ebx
  800d3b:	83 ec 08             	sub    $0x8,%esp
  800d3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d41:	89 1c 24             	mov    %ebx,(%esp)
  800d44:	e8 97 ff ff ff       	call   800ce0 <strlen>
	strcpy(dst + len, src);
  800d49:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d4c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d50:	01 d8                	add    %ebx,%eax
  800d52:	89 04 24             	mov    %eax,(%esp)
  800d55:	e8 bd ff ff ff       	call   800d17 <strcpy>
	return dst;
}
  800d5a:	89 d8                	mov    %ebx,%eax
  800d5c:	83 c4 08             	add    $0x8,%esp
  800d5f:	5b                   	pop    %ebx
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    

00800d62 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	56                   	push   %esi
  800d66:	53                   	push   %ebx
  800d67:	8b 75 08             	mov    0x8(%ebp),%esi
  800d6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6d:	89 f3                	mov    %esi,%ebx
  800d6f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d72:	89 f2                	mov    %esi,%edx
  800d74:	eb 0f                	jmp    800d85 <strncpy+0x23>
		*dst++ = *src;
  800d76:	83 c2 01             	add    $0x1,%edx
  800d79:	0f b6 01             	movzbl (%ecx),%eax
  800d7c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d7f:	80 39 01             	cmpb   $0x1,(%ecx)
  800d82:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d85:	39 da                	cmp    %ebx,%edx
  800d87:	75 ed                	jne    800d76 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d89:	89 f0                	mov    %esi,%eax
  800d8b:	5b                   	pop    %ebx
  800d8c:	5e                   	pop    %esi
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	8b 75 08             	mov    0x8(%ebp),%esi
  800d97:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d9a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800d9d:	89 f0                	mov    %esi,%eax
  800d9f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800da3:	85 c9                	test   %ecx,%ecx
  800da5:	75 0b                	jne    800db2 <strlcpy+0x23>
  800da7:	eb 1d                	jmp    800dc6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800da9:	83 c0 01             	add    $0x1,%eax
  800dac:	83 c2 01             	add    $0x1,%edx
  800daf:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800db2:	39 d8                	cmp    %ebx,%eax
  800db4:	74 0b                	je     800dc1 <strlcpy+0x32>
  800db6:	0f b6 0a             	movzbl (%edx),%ecx
  800db9:	84 c9                	test   %cl,%cl
  800dbb:	75 ec                	jne    800da9 <strlcpy+0x1a>
  800dbd:	89 c2                	mov    %eax,%edx
  800dbf:	eb 02                	jmp    800dc3 <strlcpy+0x34>
  800dc1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800dc3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800dc6:	29 f0                	sub    %esi,%eax
}
  800dc8:	5b                   	pop    %ebx
  800dc9:	5e                   	pop    %esi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800dd5:	eb 06                	jmp    800ddd <strcmp+0x11>
		p++, q++;
  800dd7:	83 c1 01             	add    $0x1,%ecx
  800dda:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ddd:	0f b6 01             	movzbl (%ecx),%eax
  800de0:	84 c0                	test   %al,%al
  800de2:	74 04                	je     800de8 <strcmp+0x1c>
  800de4:	3a 02                	cmp    (%edx),%al
  800de6:	74 ef                	je     800dd7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800de8:	0f b6 c0             	movzbl %al,%eax
  800deb:	0f b6 12             	movzbl (%edx),%edx
  800dee:	29 d0                	sub    %edx,%eax
}
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	53                   	push   %ebx
  800df6:	8b 45 08             	mov    0x8(%ebp),%eax
  800df9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dfc:	89 c3                	mov    %eax,%ebx
  800dfe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e01:	eb 06                	jmp    800e09 <strncmp+0x17>
		n--, p++, q++;
  800e03:	83 c0 01             	add    $0x1,%eax
  800e06:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e09:	39 d8                	cmp    %ebx,%eax
  800e0b:	74 15                	je     800e22 <strncmp+0x30>
  800e0d:	0f b6 08             	movzbl (%eax),%ecx
  800e10:	84 c9                	test   %cl,%cl
  800e12:	74 04                	je     800e18 <strncmp+0x26>
  800e14:	3a 0a                	cmp    (%edx),%cl
  800e16:	74 eb                	je     800e03 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e18:	0f b6 00             	movzbl (%eax),%eax
  800e1b:	0f b6 12             	movzbl (%edx),%edx
  800e1e:	29 d0                	sub    %edx,%eax
  800e20:	eb 05                	jmp    800e27 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e22:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e27:	5b                   	pop    %ebx
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e30:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e34:	eb 07                	jmp    800e3d <strchr+0x13>
		if (*s == c)
  800e36:	38 ca                	cmp    %cl,%dl
  800e38:	74 0f                	je     800e49 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e3a:	83 c0 01             	add    $0x1,%eax
  800e3d:	0f b6 10             	movzbl (%eax),%edx
  800e40:	84 d2                	test   %dl,%dl
  800e42:	75 f2                	jne    800e36 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e49:	5d                   	pop    %ebp
  800e4a:	c3                   	ret    

00800e4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e55:	eb 07                	jmp    800e5e <strfind+0x13>
		if (*s == c)
  800e57:	38 ca                	cmp    %cl,%dl
  800e59:	74 0a                	je     800e65 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e5b:	83 c0 01             	add    $0x1,%eax
  800e5e:	0f b6 10             	movzbl (%eax),%edx
  800e61:	84 d2                	test   %dl,%dl
  800e63:	75 f2                	jne    800e57 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800e65:	5d                   	pop    %ebp
  800e66:	c3                   	ret    

00800e67 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	57                   	push   %edi
  800e6b:	56                   	push   %esi
  800e6c:	53                   	push   %ebx
  800e6d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e70:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e73:	85 c9                	test   %ecx,%ecx
  800e75:	74 36                	je     800ead <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e77:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e7d:	75 28                	jne    800ea7 <memset+0x40>
  800e7f:	f6 c1 03             	test   $0x3,%cl
  800e82:	75 23                	jne    800ea7 <memset+0x40>
		c &= 0xFF;
  800e84:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e88:	89 d3                	mov    %edx,%ebx
  800e8a:	c1 e3 08             	shl    $0x8,%ebx
  800e8d:	89 d6                	mov    %edx,%esi
  800e8f:	c1 e6 18             	shl    $0x18,%esi
  800e92:	89 d0                	mov    %edx,%eax
  800e94:	c1 e0 10             	shl    $0x10,%eax
  800e97:	09 f0                	or     %esi,%eax
  800e99:	09 c2                	or     %eax,%edx
  800e9b:	89 d0                	mov    %edx,%eax
  800e9d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e9f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ea2:	fc                   	cld    
  800ea3:	f3 ab                	rep stos %eax,%es:(%edi)
  800ea5:	eb 06                	jmp    800ead <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ea7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eaa:	fc                   	cld    
  800eab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ead:	89 f8                	mov    %edi,%eax
  800eaf:	5b                   	pop    %ebx
  800eb0:	5e                   	pop    %esi
  800eb1:	5f                   	pop    %edi
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    

00800eb4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	57                   	push   %edi
  800eb8:	56                   	push   %esi
  800eb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ebf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ec2:	39 c6                	cmp    %eax,%esi
  800ec4:	73 35                	jae    800efb <memmove+0x47>
  800ec6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ec9:	39 d0                	cmp    %edx,%eax
  800ecb:	73 2e                	jae    800efb <memmove+0x47>
		s += n;
		d += n;
  800ecd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800ed0:	89 d6                	mov    %edx,%esi
  800ed2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ed4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800eda:	75 13                	jne    800eef <memmove+0x3b>
  800edc:	f6 c1 03             	test   $0x3,%cl
  800edf:	75 0e                	jne    800eef <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ee1:	83 ef 04             	sub    $0x4,%edi
  800ee4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ee7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800eea:	fd                   	std    
  800eeb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800eed:	eb 09                	jmp    800ef8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800eef:	83 ef 01             	sub    $0x1,%edi
  800ef2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ef5:	fd                   	std    
  800ef6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ef8:	fc                   	cld    
  800ef9:	eb 1d                	jmp    800f18 <memmove+0x64>
  800efb:	89 f2                	mov    %esi,%edx
  800efd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eff:	f6 c2 03             	test   $0x3,%dl
  800f02:	75 0f                	jne    800f13 <memmove+0x5f>
  800f04:	f6 c1 03             	test   $0x3,%cl
  800f07:	75 0a                	jne    800f13 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f09:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f0c:	89 c7                	mov    %eax,%edi
  800f0e:	fc                   	cld    
  800f0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f11:	eb 05                	jmp    800f18 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f13:	89 c7                	mov    %eax,%edi
  800f15:	fc                   	cld    
  800f16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f18:	5e                   	pop    %esi
  800f19:	5f                   	pop    %edi
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    

00800f1c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f22:	8b 45 10             	mov    0x10(%ebp),%eax
  800f25:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f30:	8b 45 08             	mov    0x8(%ebp),%eax
  800f33:	89 04 24             	mov    %eax,(%esp)
  800f36:	e8 79 ff ff ff       	call   800eb4 <memmove>
}
  800f3b:	c9                   	leave  
  800f3c:	c3                   	ret    

00800f3d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	56                   	push   %esi
  800f41:	53                   	push   %ebx
  800f42:	8b 55 08             	mov    0x8(%ebp),%edx
  800f45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f48:	89 d6                	mov    %edx,%esi
  800f4a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f4d:	eb 1a                	jmp    800f69 <memcmp+0x2c>
		if (*s1 != *s2)
  800f4f:	0f b6 02             	movzbl (%edx),%eax
  800f52:	0f b6 19             	movzbl (%ecx),%ebx
  800f55:	38 d8                	cmp    %bl,%al
  800f57:	74 0a                	je     800f63 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f59:	0f b6 c0             	movzbl %al,%eax
  800f5c:	0f b6 db             	movzbl %bl,%ebx
  800f5f:	29 d8                	sub    %ebx,%eax
  800f61:	eb 0f                	jmp    800f72 <memcmp+0x35>
		s1++, s2++;
  800f63:	83 c2 01             	add    $0x1,%edx
  800f66:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f69:	39 f2                	cmp    %esi,%edx
  800f6b:	75 e2                	jne    800f4f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f72:	5b                   	pop    %ebx
  800f73:	5e                   	pop    %esi
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    

00800f76 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800f7f:	89 c2                	mov    %eax,%edx
  800f81:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f84:	eb 07                	jmp    800f8d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f86:	38 08                	cmp    %cl,(%eax)
  800f88:	74 07                	je     800f91 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f8a:	83 c0 01             	add    $0x1,%eax
  800f8d:	39 d0                	cmp    %edx,%eax
  800f8f:	72 f5                	jb     800f86 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    

00800f93 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	57                   	push   %edi
  800f97:	56                   	push   %esi
  800f98:	53                   	push   %ebx
  800f99:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f9f:	eb 03                	jmp    800fa4 <strtol+0x11>
		s++;
  800fa1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fa4:	0f b6 0a             	movzbl (%edx),%ecx
  800fa7:	80 f9 09             	cmp    $0x9,%cl
  800faa:	74 f5                	je     800fa1 <strtol+0xe>
  800fac:	80 f9 20             	cmp    $0x20,%cl
  800faf:	74 f0                	je     800fa1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800fb1:	80 f9 2b             	cmp    $0x2b,%cl
  800fb4:	75 0a                	jne    800fc0 <strtol+0x2d>
		s++;
  800fb6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800fb9:	bf 00 00 00 00       	mov    $0x0,%edi
  800fbe:	eb 11                	jmp    800fd1 <strtol+0x3e>
  800fc0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800fc5:	80 f9 2d             	cmp    $0x2d,%cl
  800fc8:	75 07                	jne    800fd1 <strtol+0x3e>
		s++, neg = 1;
  800fca:	8d 52 01             	lea    0x1(%edx),%edx
  800fcd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fd1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800fd6:	75 15                	jne    800fed <strtol+0x5a>
  800fd8:	80 3a 30             	cmpb   $0x30,(%edx)
  800fdb:	75 10                	jne    800fed <strtol+0x5a>
  800fdd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800fe1:	75 0a                	jne    800fed <strtol+0x5a>
		s += 2, base = 16;
  800fe3:	83 c2 02             	add    $0x2,%edx
  800fe6:	b8 10 00 00 00       	mov    $0x10,%eax
  800feb:	eb 10                	jmp    800ffd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800fed:	85 c0                	test   %eax,%eax
  800fef:	75 0c                	jne    800ffd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ff1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ff3:	80 3a 30             	cmpb   $0x30,(%edx)
  800ff6:	75 05                	jne    800ffd <strtol+0x6a>
		s++, base = 8;
  800ff8:	83 c2 01             	add    $0x1,%edx
  800ffb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800ffd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801002:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801005:	0f b6 0a             	movzbl (%edx),%ecx
  801008:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80100b:	89 f0                	mov    %esi,%eax
  80100d:	3c 09                	cmp    $0x9,%al
  80100f:	77 08                	ja     801019 <strtol+0x86>
			dig = *s - '0';
  801011:	0f be c9             	movsbl %cl,%ecx
  801014:	83 e9 30             	sub    $0x30,%ecx
  801017:	eb 20                	jmp    801039 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  801019:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80101c:	89 f0                	mov    %esi,%eax
  80101e:	3c 19                	cmp    $0x19,%al
  801020:	77 08                	ja     80102a <strtol+0x97>
			dig = *s - 'a' + 10;
  801022:	0f be c9             	movsbl %cl,%ecx
  801025:	83 e9 57             	sub    $0x57,%ecx
  801028:	eb 0f                	jmp    801039 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  80102a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  80102d:	89 f0                	mov    %esi,%eax
  80102f:	3c 19                	cmp    $0x19,%al
  801031:	77 16                	ja     801049 <strtol+0xb6>
			dig = *s - 'A' + 10;
  801033:	0f be c9             	movsbl %cl,%ecx
  801036:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801039:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80103c:	7d 0f                	jge    80104d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  80103e:	83 c2 01             	add    $0x1,%edx
  801041:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801045:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  801047:	eb bc                	jmp    801005 <strtol+0x72>
  801049:	89 d8                	mov    %ebx,%eax
  80104b:	eb 02                	jmp    80104f <strtol+0xbc>
  80104d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  80104f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801053:	74 05                	je     80105a <strtol+0xc7>
		*endptr = (char *) s;
  801055:	8b 75 0c             	mov    0xc(%ebp),%esi
  801058:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80105a:	f7 d8                	neg    %eax
  80105c:	85 ff                	test   %edi,%edi
  80105e:	0f 44 c3             	cmove  %ebx,%eax
}
  801061:	5b                   	pop    %ebx
  801062:	5e                   	pop    %esi
  801063:	5f                   	pop    %edi
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    

00801066 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	57                   	push   %edi
  80106a:	56                   	push   %esi
  80106b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80106c:	b8 00 00 00 00       	mov    $0x0,%eax
  801071:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801074:	8b 55 08             	mov    0x8(%ebp),%edx
  801077:	89 c3                	mov    %eax,%ebx
  801079:	89 c7                	mov    %eax,%edi
  80107b:	89 c6                	mov    %eax,%esi
  80107d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80107f:	5b                   	pop    %ebx
  801080:	5e                   	pop    %esi
  801081:	5f                   	pop    %edi
  801082:	5d                   	pop    %ebp
  801083:	c3                   	ret    

00801084 <sys_cgetc>:

int
sys_cgetc(void)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	57                   	push   %edi
  801088:	56                   	push   %esi
  801089:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80108a:	ba 00 00 00 00       	mov    $0x0,%edx
  80108f:	b8 01 00 00 00       	mov    $0x1,%eax
  801094:	89 d1                	mov    %edx,%ecx
  801096:	89 d3                	mov    %edx,%ebx
  801098:	89 d7                	mov    %edx,%edi
  80109a:	89 d6                	mov    %edx,%esi
  80109c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80109e:	5b                   	pop    %ebx
  80109f:	5e                   	pop    %esi
  8010a0:	5f                   	pop    %edi
  8010a1:	5d                   	pop    %ebp
  8010a2:	c3                   	ret    

008010a3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	57                   	push   %edi
  8010a7:	56                   	push   %esi
  8010a8:	53                   	push   %ebx
  8010a9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010b1:	b8 03 00 00 00       	mov    $0x3,%eax
  8010b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b9:	89 cb                	mov    %ecx,%ebx
  8010bb:	89 cf                	mov    %ecx,%edi
  8010bd:	89 ce                	mov    %ecx,%esi
  8010bf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	7e 28                	jle    8010ed <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010c9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8010d0:	00 
  8010d1:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  8010d8:	00 
  8010d9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010e0:	00 
  8010e1:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  8010e8:	e8 0f f5 ff ff       	call   8005fc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010ed:	83 c4 2c             	add    $0x2c,%esp
  8010f0:	5b                   	pop    %ebx
  8010f1:	5e                   	pop    %esi
  8010f2:	5f                   	pop    %edi
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	57                   	push   %edi
  8010f9:	56                   	push   %esi
  8010fa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801100:	b8 02 00 00 00       	mov    $0x2,%eax
  801105:	89 d1                	mov    %edx,%ecx
  801107:	89 d3                	mov    %edx,%ebx
  801109:	89 d7                	mov    %edx,%edi
  80110b:	89 d6                	mov    %edx,%esi
  80110d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80110f:	5b                   	pop    %ebx
  801110:	5e                   	pop    %esi
  801111:	5f                   	pop    %edi
  801112:	5d                   	pop    %ebp
  801113:	c3                   	ret    

00801114 <sys_yield>:

void
sys_yield(void)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	57                   	push   %edi
  801118:	56                   	push   %esi
  801119:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80111a:	ba 00 00 00 00       	mov    $0x0,%edx
  80111f:	b8 0b 00 00 00       	mov    $0xb,%eax
  801124:	89 d1                	mov    %edx,%ecx
  801126:	89 d3                	mov    %edx,%ebx
  801128:	89 d7                	mov    %edx,%edi
  80112a:	89 d6                	mov    %edx,%esi
  80112c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80112e:	5b                   	pop    %ebx
  80112f:	5e                   	pop    %esi
  801130:	5f                   	pop    %edi
  801131:	5d                   	pop    %ebp
  801132:	c3                   	ret    

00801133 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801133:	55                   	push   %ebp
  801134:	89 e5                	mov    %esp,%ebp
  801136:	57                   	push   %edi
  801137:	56                   	push   %esi
  801138:	53                   	push   %ebx
  801139:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113c:	be 00 00 00 00       	mov    $0x0,%esi
  801141:	b8 04 00 00 00       	mov    $0x4,%eax
  801146:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801149:	8b 55 08             	mov    0x8(%ebp),%edx
  80114c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80114f:	89 f7                	mov    %esi,%edi
  801151:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801153:	85 c0                	test   %eax,%eax
  801155:	7e 28                	jle    80117f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801157:	89 44 24 10          	mov    %eax,0x10(%esp)
  80115b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801162:	00 
  801163:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  80116a:	00 
  80116b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801172:	00 
  801173:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  80117a:	e8 7d f4 ff ff       	call   8005fc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80117f:	83 c4 2c             	add    $0x2c,%esp
  801182:	5b                   	pop    %ebx
  801183:	5e                   	pop    %esi
  801184:	5f                   	pop    %edi
  801185:	5d                   	pop    %ebp
  801186:	c3                   	ret    

00801187 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	57                   	push   %edi
  80118b:	56                   	push   %esi
  80118c:	53                   	push   %ebx
  80118d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801190:	b8 05 00 00 00       	mov    $0x5,%eax
  801195:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801198:	8b 55 08             	mov    0x8(%ebp),%edx
  80119b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80119e:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011a1:	8b 75 18             	mov    0x18(%ebp),%esi
  8011a4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011a6:	85 c0                	test   %eax,%eax
  8011a8:	7e 28                	jle    8011d2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ae:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8011b5:	00 
  8011b6:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  8011bd:	00 
  8011be:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011c5:	00 
  8011c6:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  8011cd:	e8 2a f4 ff ff       	call   8005fc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8011d2:	83 c4 2c             	add    $0x2c,%esp
  8011d5:	5b                   	pop    %ebx
  8011d6:	5e                   	pop    %esi
  8011d7:	5f                   	pop    %edi
  8011d8:	5d                   	pop    %ebp
  8011d9:	c3                   	ret    

008011da <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	57                   	push   %edi
  8011de:	56                   	push   %esi
  8011df:	53                   	push   %ebx
  8011e0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e8:	b8 06 00 00 00       	mov    $0x6,%eax
  8011ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f3:	89 df                	mov    %ebx,%edi
  8011f5:	89 de                	mov    %ebx,%esi
  8011f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011f9:	85 c0                	test   %eax,%eax
  8011fb:	7e 28                	jle    801225 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  801201:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801208:	00 
  801209:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  801210:	00 
  801211:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801218:	00 
  801219:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  801220:	e8 d7 f3 ff ff       	call   8005fc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801225:	83 c4 2c             	add    $0x2c,%esp
  801228:	5b                   	pop    %ebx
  801229:	5e                   	pop    %esi
  80122a:	5f                   	pop    %edi
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    

0080122d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	57                   	push   %edi
  801231:	56                   	push   %esi
  801232:	53                   	push   %ebx
  801233:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80123b:	b8 08 00 00 00       	mov    $0x8,%eax
  801240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801243:	8b 55 08             	mov    0x8(%ebp),%edx
  801246:	89 df                	mov    %ebx,%edi
  801248:	89 de                	mov    %ebx,%esi
  80124a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80124c:	85 c0                	test   %eax,%eax
  80124e:	7e 28                	jle    801278 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801250:	89 44 24 10          	mov    %eax,0x10(%esp)
  801254:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80125b:	00 
  80125c:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  801263:	00 
  801264:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80126b:	00 
  80126c:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  801273:	e8 84 f3 ff ff       	call   8005fc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801278:	83 c4 2c             	add    $0x2c,%esp
  80127b:	5b                   	pop    %ebx
  80127c:	5e                   	pop    %esi
  80127d:	5f                   	pop    %edi
  80127e:	5d                   	pop    %ebp
  80127f:	c3                   	ret    

00801280 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	57                   	push   %edi
  801284:	56                   	push   %esi
  801285:	53                   	push   %ebx
  801286:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801289:	bb 00 00 00 00       	mov    $0x0,%ebx
  80128e:	b8 09 00 00 00       	mov    $0x9,%eax
  801293:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801296:	8b 55 08             	mov    0x8(%ebp),%edx
  801299:	89 df                	mov    %ebx,%edi
  80129b:	89 de                	mov    %ebx,%esi
  80129d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80129f:	85 c0                	test   %eax,%eax
  8012a1:	7e 28                	jle    8012cb <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012a3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012a7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8012ae:	00 
  8012af:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  8012b6:	00 
  8012b7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012be:	00 
  8012bf:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  8012c6:	e8 31 f3 ff ff       	call   8005fc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8012cb:	83 c4 2c             	add    $0x2c,%esp
  8012ce:	5b                   	pop    %ebx
  8012cf:	5e                   	pop    %esi
  8012d0:	5f                   	pop    %edi
  8012d1:	5d                   	pop    %ebp
  8012d2:	c3                   	ret    

008012d3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012d3:	55                   	push   %ebp
  8012d4:	89 e5                	mov    %esp,%ebp
  8012d6:	57                   	push   %edi
  8012d7:	56                   	push   %esi
  8012d8:	53                   	push   %ebx
  8012d9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012e1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8012e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ec:	89 df                	mov    %ebx,%edi
  8012ee:	89 de                	mov    %ebx,%esi
  8012f0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012f2:	85 c0                	test   %eax,%eax
  8012f4:	7e 28                	jle    80131e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012f6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012fa:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801301:	00 
  801302:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  801309:	00 
  80130a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801311:	00 
  801312:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  801319:	e8 de f2 ff ff       	call   8005fc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80131e:	83 c4 2c             	add    $0x2c,%esp
  801321:	5b                   	pop    %ebx
  801322:	5e                   	pop    %esi
  801323:	5f                   	pop    %edi
  801324:	5d                   	pop    %ebp
  801325:	c3                   	ret    

00801326 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	57                   	push   %edi
  80132a:	56                   	push   %esi
  80132b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80132c:	be 00 00 00 00       	mov    $0x0,%esi
  801331:	b8 0c 00 00 00       	mov    $0xc,%eax
  801336:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801339:	8b 55 08             	mov    0x8(%ebp),%edx
  80133c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80133f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801342:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801344:	5b                   	pop    %ebx
  801345:	5e                   	pop    %esi
  801346:	5f                   	pop    %edi
  801347:	5d                   	pop    %ebp
  801348:	c3                   	ret    

00801349 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801349:	55                   	push   %ebp
  80134a:	89 e5                	mov    %esp,%ebp
  80134c:	57                   	push   %edi
  80134d:	56                   	push   %esi
  80134e:	53                   	push   %ebx
  80134f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801352:	b9 00 00 00 00       	mov    $0x0,%ecx
  801357:	b8 0d 00 00 00       	mov    $0xd,%eax
  80135c:	8b 55 08             	mov    0x8(%ebp),%edx
  80135f:	89 cb                	mov    %ecx,%ebx
  801361:	89 cf                	mov    %ecx,%edi
  801363:	89 ce                	mov    %ecx,%esi
  801365:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801367:	85 c0                	test   %eax,%eax
  801369:	7e 28                	jle    801393 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80136b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80136f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801376:	00 
  801377:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  80137e:	00 
  80137f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801386:	00 
  801387:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  80138e:	e8 69 f2 ff ff       	call   8005fc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801393:	83 c4 2c             	add    $0x2c,%esp
  801396:	5b                   	pop    %ebx
  801397:	5e                   	pop    %esi
  801398:	5f                   	pop    %edi
  801399:	5d                   	pop    %ebp
  80139a:	c3                   	ret    

0080139b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	57                   	push   %edi
  80139f:	56                   	push   %esi
  8013a0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a6:	b8 0e 00 00 00       	mov    $0xe,%eax
  8013ab:	89 d1                	mov    %edx,%ecx
  8013ad:	89 d3                	mov    %edx,%ebx
  8013af:	89 d7                	mov    %edx,%edi
  8013b1:	89 d6                	mov    %edx,%esi
  8013b3:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8013b5:	5b                   	pop    %ebx
  8013b6:	5e                   	pop    %esi
  8013b7:	5f                   	pop    %edi
  8013b8:	5d                   	pop    %ebp
  8013b9:	c3                   	ret    

008013ba <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  8013ba:	55                   	push   %ebp
  8013bb:	89 e5                	mov    %esp,%ebp
  8013bd:	57                   	push   %edi
  8013be:	56                   	push   %esi
  8013bf:	53                   	push   %ebx
  8013c0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013c8:	b8 0f 00 00 00       	mov    $0xf,%eax
  8013cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8013d3:	89 df                	mov    %ebx,%edi
  8013d5:	89 de                	mov    %ebx,%esi
  8013d7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8013d9:	85 c0                	test   %eax,%eax
  8013db:	7e 28                	jle    801405 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013dd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013e1:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  8013e8:	00 
  8013e9:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  8013f0:	00 
  8013f1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013f8:	00 
  8013f9:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  801400:	e8 f7 f1 ff ff       	call   8005fc <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  801405:	83 c4 2c             	add    $0x2c,%esp
  801408:	5b                   	pop    %ebx
  801409:	5e                   	pop    %esi
  80140a:	5f                   	pop    %edi
  80140b:	5d                   	pop    %ebp
  80140c:	c3                   	ret    

0080140d <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  80140d:	55                   	push   %ebp
  80140e:	89 e5                	mov    %esp,%ebp
  801410:	57                   	push   %edi
  801411:	56                   	push   %esi
  801412:	53                   	push   %ebx
  801413:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801416:	bb 00 00 00 00       	mov    $0x0,%ebx
  80141b:	b8 10 00 00 00       	mov    $0x10,%eax
  801420:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801423:	8b 55 08             	mov    0x8(%ebp),%edx
  801426:	89 df                	mov    %ebx,%edi
  801428:	89 de                	mov    %ebx,%esi
  80142a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80142c:	85 c0                	test   %eax,%eax
  80142e:	7e 28                	jle    801458 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801430:	89 44 24 10          	mov    %eax,0x10(%esp)
  801434:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  80143b:	00 
  80143c:	c7 44 24 08 df 2f 80 	movl   $0x802fdf,0x8(%esp)
  801443:	00 
  801444:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80144b:	00 
  80144c:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  801453:	e8 a4 f1 ff ff       	call   8005fc <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  801458:	83 c4 2c             	add    $0x2c,%esp
  80145b:	5b                   	pop    %ebx
  80145c:	5e                   	pop    %esi
  80145d:	5f                   	pop    %edi
  80145e:	5d                   	pop    %ebp
  80145f:	c3                   	ret    

00801460 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	53                   	push   %ebx
  801464:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  801467:	83 3d b8 50 80 00 00 	cmpl   $0x0,0x8050b8
  80146e:	75 2f                	jne    80149f <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  801470:	e8 80 fc ff ff       	call   8010f5 <sys_getenvid>
  801475:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P);
  801477:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80147e:	00 
  80147f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801486:	ee 
  801487:	89 04 24             	mov    %eax,(%esp)
  80148a:	e8 a4 fc ff ff       	call   801133 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *)_pgfault_upcall);
  80148f:	c7 44 24 04 ad 14 80 	movl   $0x8014ad,0x4(%esp)
  801496:	00 
  801497:	89 1c 24             	mov    %ebx,(%esp)
  80149a:	e8 34 fe ff ff       	call   8012d3 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80149f:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a2:	a3 b8 50 80 00       	mov    %eax,0x8050b8
}
  8014a7:	83 c4 14             	add    $0x14,%esp
  8014aa:	5b                   	pop    %ebx
  8014ab:	5d                   	pop    %ebp
  8014ac:	c3                   	ret    

008014ad <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8014ad:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8014ae:	a1 b8 50 80 00       	mov    0x8050b8,%eax
	call *%eax
  8014b3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8014b5:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	// 0x30(%esp) points to trap-time stack pointer
	// 0x28(%esp) points to trap-time eip
	subl $4, 0x30(%esp)
  8014b8:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax 
  8014bd:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebp
  8014c1:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %ebp, (%eax)
  8014c5:	89 28                	mov    %ebp,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8014c7:	83 c4 08             	add    $0x8,%esp
	popal
  8014ca:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp //pop eip - we already stored it
  8014cb:	83 c4 04             	add    $0x4,%esp
	popfl
  8014ce:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8014cf:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8014d0:	c3                   	ret    
  8014d1:	66 90                	xchg   %ax,%ax
  8014d3:	66 90                	xchg   %ax,%ax
  8014d5:	66 90                	xchg   %ax,%ax
  8014d7:	66 90                	xchg   %ax,%ax
  8014d9:	66 90                	xchg   %ax,%ax
  8014db:	66 90                	xchg   %ax,%ax
  8014dd:	66 90                	xchg   %ax,%ax
  8014df:	90                   	nop

008014e0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8014eb:	c1 e8 0c             	shr    $0xc,%eax
}
  8014ee:	5d                   	pop    %ebp
  8014ef:	c3                   	ret    

008014f0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8014fb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801500:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801505:	5d                   	pop    %ebp
  801506:	c3                   	ret    

00801507 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801507:	55                   	push   %ebp
  801508:	89 e5                	mov    %esp,%ebp
  80150a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80150d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801512:	89 c2                	mov    %eax,%edx
  801514:	c1 ea 16             	shr    $0x16,%edx
  801517:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80151e:	f6 c2 01             	test   $0x1,%dl
  801521:	74 11                	je     801534 <fd_alloc+0x2d>
  801523:	89 c2                	mov    %eax,%edx
  801525:	c1 ea 0c             	shr    $0xc,%edx
  801528:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80152f:	f6 c2 01             	test   $0x1,%dl
  801532:	75 09                	jne    80153d <fd_alloc+0x36>
			*fd_store = fd;
  801534:	89 01                	mov    %eax,(%ecx)
			return 0;
  801536:	b8 00 00 00 00       	mov    $0x0,%eax
  80153b:	eb 17                	jmp    801554 <fd_alloc+0x4d>
  80153d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801542:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801547:	75 c9                	jne    801512 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801549:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80154f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801554:	5d                   	pop    %ebp
  801555:	c3                   	ret    

00801556 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
  801559:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80155c:	83 f8 1f             	cmp    $0x1f,%eax
  80155f:	77 36                	ja     801597 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801561:	c1 e0 0c             	shl    $0xc,%eax
  801564:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801569:	89 c2                	mov    %eax,%edx
  80156b:	c1 ea 16             	shr    $0x16,%edx
  80156e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801575:	f6 c2 01             	test   $0x1,%dl
  801578:	74 24                	je     80159e <fd_lookup+0x48>
  80157a:	89 c2                	mov    %eax,%edx
  80157c:	c1 ea 0c             	shr    $0xc,%edx
  80157f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801586:	f6 c2 01             	test   $0x1,%dl
  801589:	74 1a                	je     8015a5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80158b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80158e:	89 02                	mov    %eax,(%edx)
	return 0;
  801590:	b8 00 00 00 00       	mov    $0x0,%eax
  801595:	eb 13                	jmp    8015aa <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801597:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80159c:	eb 0c                	jmp    8015aa <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80159e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015a3:	eb 05                	jmp    8015aa <fd_lookup+0x54>
  8015a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8015aa:	5d                   	pop    %ebp
  8015ab:	c3                   	ret    

008015ac <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015ac:	55                   	push   %ebp
  8015ad:	89 e5                	mov    %esp,%ebp
  8015af:	83 ec 18             	sub    $0x18,%esp
  8015b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8015b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ba:	eb 13                	jmp    8015cf <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8015bc:	39 08                	cmp    %ecx,(%eax)
  8015be:	75 0c                	jne    8015cc <dev_lookup+0x20>
			*dev = devtab[i];
  8015c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015c3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8015c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ca:	eb 38                	jmp    801604 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015cc:	83 c2 01             	add    $0x1,%edx
  8015cf:	8b 04 95 88 30 80 00 	mov    0x803088(,%edx,4),%eax
  8015d6:	85 c0                	test   %eax,%eax
  8015d8:	75 e2                	jne    8015bc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015da:	a1 b4 50 80 00       	mov    0x8050b4,%eax
  8015df:	8b 40 48             	mov    0x48(%eax),%eax
  8015e2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ea:	c7 04 24 0c 30 80 00 	movl   $0x80300c,(%esp)
  8015f1:	e8 ff f0 ff ff       	call   8006f5 <cprintf>
	*dev = 0;
  8015f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015f9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8015ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801604:	c9                   	leave  
  801605:	c3                   	ret    

00801606 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801606:	55                   	push   %ebp
  801607:	89 e5                	mov    %esp,%ebp
  801609:	56                   	push   %esi
  80160a:	53                   	push   %ebx
  80160b:	83 ec 20             	sub    $0x20,%esp
  80160e:	8b 75 08             	mov    0x8(%ebp),%esi
  801611:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801614:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801617:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80161b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801621:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801624:	89 04 24             	mov    %eax,(%esp)
  801627:	e8 2a ff ff ff       	call   801556 <fd_lookup>
  80162c:	85 c0                	test   %eax,%eax
  80162e:	78 05                	js     801635 <fd_close+0x2f>
	    || fd != fd2)
  801630:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801633:	74 0c                	je     801641 <fd_close+0x3b>
		return (must_exist ? r : 0);
  801635:	84 db                	test   %bl,%bl
  801637:	ba 00 00 00 00       	mov    $0x0,%edx
  80163c:	0f 44 c2             	cmove  %edx,%eax
  80163f:	eb 3f                	jmp    801680 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801641:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801644:	89 44 24 04          	mov    %eax,0x4(%esp)
  801648:	8b 06                	mov    (%esi),%eax
  80164a:	89 04 24             	mov    %eax,(%esp)
  80164d:	e8 5a ff ff ff       	call   8015ac <dev_lookup>
  801652:	89 c3                	mov    %eax,%ebx
  801654:	85 c0                	test   %eax,%eax
  801656:	78 16                	js     80166e <fd_close+0x68>
		if (dev->dev_close)
  801658:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80165e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801663:	85 c0                	test   %eax,%eax
  801665:	74 07                	je     80166e <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801667:	89 34 24             	mov    %esi,(%esp)
  80166a:	ff d0                	call   *%eax
  80166c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80166e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801672:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801679:	e8 5c fb ff ff       	call   8011da <sys_page_unmap>
	return r;
  80167e:	89 d8                	mov    %ebx,%eax
}
  801680:	83 c4 20             	add    $0x20,%esp
  801683:	5b                   	pop    %ebx
  801684:	5e                   	pop    %esi
  801685:	5d                   	pop    %ebp
  801686:	c3                   	ret    

00801687 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80168d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801690:	89 44 24 04          	mov    %eax,0x4(%esp)
  801694:	8b 45 08             	mov    0x8(%ebp),%eax
  801697:	89 04 24             	mov    %eax,(%esp)
  80169a:	e8 b7 fe ff ff       	call   801556 <fd_lookup>
  80169f:	89 c2                	mov    %eax,%edx
  8016a1:	85 d2                	test   %edx,%edx
  8016a3:	78 13                	js     8016b8 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8016a5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8016ac:	00 
  8016ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b0:	89 04 24             	mov    %eax,(%esp)
  8016b3:	e8 4e ff ff ff       	call   801606 <fd_close>
}
  8016b8:	c9                   	leave  
  8016b9:	c3                   	ret    

008016ba <close_all>:

void
close_all(void)
{
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	53                   	push   %ebx
  8016be:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016c1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016c6:	89 1c 24             	mov    %ebx,(%esp)
  8016c9:	e8 b9 ff ff ff       	call   801687 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016ce:	83 c3 01             	add    $0x1,%ebx
  8016d1:	83 fb 20             	cmp    $0x20,%ebx
  8016d4:	75 f0                	jne    8016c6 <close_all+0xc>
		close(i);
}
  8016d6:	83 c4 14             	add    $0x14,%esp
  8016d9:	5b                   	pop    %ebx
  8016da:	5d                   	pop    %ebp
  8016db:	c3                   	ret    

008016dc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	57                   	push   %edi
  8016e0:	56                   	push   %esi
  8016e1:	53                   	push   %ebx
  8016e2:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016e5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ef:	89 04 24             	mov    %eax,(%esp)
  8016f2:	e8 5f fe ff ff       	call   801556 <fd_lookup>
  8016f7:	89 c2                	mov    %eax,%edx
  8016f9:	85 d2                	test   %edx,%edx
  8016fb:	0f 88 e1 00 00 00    	js     8017e2 <dup+0x106>
		return r;
	close(newfdnum);
  801701:	8b 45 0c             	mov    0xc(%ebp),%eax
  801704:	89 04 24             	mov    %eax,(%esp)
  801707:	e8 7b ff ff ff       	call   801687 <close>

	newfd = INDEX2FD(newfdnum);
  80170c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80170f:	c1 e3 0c             	shl    $0xc,%ebx
  801712:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801718:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80171b:	89 04 24             	mov    %eax,(%esp)
  80171e:	e8 cd fd ff ff       	call   8014f0 <fd2data>
  801723:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801725:	89 1c 24             	mov    %ebx,(%esp)
  801728:	e8 c3 fd ff ff       	call   8014f0 <fd2data>
  80172d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80172f:	89 f0                	mov    %esi,%eax
  801731:	c1 e8 16             	shr    $0x16,%eax
  801734:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80173b:	a8 01                	test   $0x1,%al
  80173d:	74 43                	je     801782 <dup+0xa6>
  80173f:	89 f0                	mov    %esi,%eax
  801741:	c1 e8 0c             	shr    $0xc,%eax
  801744:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80174b:	f6 c2 01             	test   $0x1,%dl
  80174e:	74 32                	je     801782 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801750:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801757:	25 07 0e 00 00       	and    $0xe07,%eax
  80175c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801760:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801764:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80176b:	00 
  80176c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801770:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801777:	e8 0b fa ff ff       	call   801187 <sys_page_map>
  80177c:	89 c6                	mov    %eax,%esi
  80177e:	85 c0                	test   %eax,%eax
  801780:	78 3e                	js     8017c0 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801782:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801785:	89 c2                	mov    %eax,%edx
  801787:	c1 ea 0c             	shr    $0xc,%edx
  80178a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801791:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801797:	89 54 24 10          	mov    %edx,0x10(%esp)
  80179b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80179f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017a6:	00 
  8017a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017b2:	e8 d0 f9 ff ff       	call   801187 <sys_page_map>
  8017b7:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8017b9:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017bc:	85 f6                	test   %esi,%esi
  8017be:	79 22                	jns    8017e2 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017cb:	e8 0a fa ff ff       	call   8011da <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017d0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8017d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017db:	e8 fa f9 ff ff       	call   8011da <sys_page_unmap>
	return r;
  8017e0:	89 f0                	mov    %esi,%eax
}
  8017e2:	83 c4 3c             	add    $0x3c,%esp
  8017e5:	5b                   	pop    %ebx
  8017e6:	5e                   	pop    %esi
  8017e7:	5f                   	pop    %edi
  8017e8:	5d                   	pop    %ebp
  8017e9:	c3                   	ret    

008017ea <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017ea:	55                   	push   %ebp
  8017eb:	89 e5                	mov    %esp,%ebp
  8017ed:	53                   	push   %ebx
  8017ee:	83 ec 24             	sub    $0x24,%esp
  8017f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fb:	89 1c 24             	mov    %ebx,(%esp)
  8017fe:	e8 53 fd ff ff       	call   801556 <fd_lookup>
  801803:	89 c2                	mov    %eax,%edx
  801805:	85 d2                	test   %edx,%edx
  801807:	78 6d                	js     801876 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801809:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801810:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801813:	8b 00                	mov    (%eax),%eax
  801815:	89 04 24             	mov    %eax,(%esp)
  801818:	e8 8f fd ff ff       	call   8015ac <dev_lookup>
  80181d:	85 c0                	test   %eax,%eax
  80181f:	78 55                	js     801876 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801821:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801824:	8b 50 08             	mov    0x8(%eax),%edx
  801827:	83 e2 03             	and    $0x3,%edx
  80182a:	83 fa 01             	cmp    $0x1,%edx
  80182d:	75 23                	jne    801852 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80182f:	a1 b4 50 80 00       	mov    0x8050b4,%eax
  801834:	8b 40 48             	mov    0x48(%eax),%eax
  801837:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80183b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183f:	c7 04 24 4d 30 80 00 	movl   $0x80304d,(%esp)
  801846:	e8 aa ee ff ff       	call   8006f5 <cprintf>
		return -E_INVAL;
  80184b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801850:	eb 24                	jmp    801876 <read+0x8c>
	}
	if (!dev->dev_read)
  801852:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801855:	8b 52 08             	mov    0x8(%edx),%edx
  801858:	85 d2                	test   %edx,%edx
  80185a:	74 15                	je     801871 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80185c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80185f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801863:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801866:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80186a:	89 04 24             	mov    %eax,(%esp)
  80186d:	ff d2                	call   *%edx
  80186f:	eb 05                	jmp    801876 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801871:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801876:	83 c4 24             	add    $0x24,%esp
  801879:	5b                   	pop    %ebx
  80187a:	5d                   	pop    %ebp
  80187b:	c3                   	ret    

0080187c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
  80187f:	57                   	push   %edi
  801880:	56                   	push   %esi
  801881:	53                   	push   %ebx
  801882:	83 ec 1c             	sub    $0x1c,%esp
  801885:	8b 7d 08             	mov    0x8(%ebp),%edi
  801888:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80188b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801890:	eb 23                	jmp    8018b5 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801892:	89 f0                	mov    %esi,%eax
  801894:	29 d8                	sub    %ebx,%eax
  801896:	89 44 24 08          	mov    %eax,0x8(%esp)
  80189a:	89 d8                	mov    %ebx,%eax
  80189c:	03 45 0c             	add    0xc(%ebp),%eax
  80189f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a3:	89 3c 24             	mov    %edi,(%esp)
  8018a6:	e8 3f ff ff ff       	call   8017ea <read>
		if (m < 0)
  8018ab:	85 c0                	test   %eax,%eax
  8018ad:	78 10                	js     8018bf <readn+0x43>
			return m;
		if (m == 0)
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	74 0a                	je     8018bd <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018b3:	01 c3                	add    %eax,%ebx
  8018b5:	39 f3                	cmp    %esi,%ebx
  8018b7:	72 d9                	jb     801892 <readn+0x16>
  8018b9:	89 d8                	mov    %ebx,%eax
  8018bb:	eb 02                	jmp    8018bf <readn+0x43>
  8018bd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8018bf:	83 c4 1c             	add    $0x1c,%esp
  8018c2:	5b                   	pop    %ebx
  8018c3:	5e                   	pop    %esi
  8018c4:	5f                   	pop    %edi
  8018c5:	5d                   	pop    %ebp
  8018c6:	c3                   	ret    

008018c7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018c7:	55                   	push   %ebp
  8018c8:	89 e5                	mov    %esp,%ebp
  8018ca:	53                   	push   %ebx
  8018cb:	83 ec 24             	sub    $0x24,%esp
  8018ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d8:	89 1c 24             	mov    %ebx,(%esp)
  8018db:	e8 76 fc ff ff       	call   801556 <fd_lookup>
  8018e0:	89 c2                	mov    %eax,%edx
  8018e2:	85 d2                	test   %edx,%edx
  8018e4:	78 68                	js     80194e <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f0:	8b 00                	mov    (%eax),%eax
  8018f2:	89 04 24             	mov    %eax,(%esp)
  8018f5:	e8 b2 fc ff ff       	call   8015ac <dev_lookup>
  8018fa:	85 c0                	test   %eax,%eax
  8018fc:	78 50                	js     80194e <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801901:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801905:	75 23                	jne    80192a <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801907:	a1 b4 50 80 00       	mov    0x8050b4,%eax
  80190c:	8b 40 48             	mov    0x48(%eax),%eax
  80190f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801913:	89 44 24 04          	mov    %eax,0x4(%esp)
  801917:	c7 04 24 69 30 80 00 	movl   $0x803069,(%esp)
  80191e:	e8 d2 ed ff ff       	call   8006f5 <cprintf>
		return -E_INVAL;
  801923:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801928:	eb 24                	jmp    80194e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80192a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80192d:	8b 52 0c             	mov    0xc(%edx),%edx
  801930:	85 d2                	test   %edx,%edx
  801932:	74 15                	je     801949 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801934:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801937:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80193b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80193e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801942:	89 04 24             	mov    %eax,(%esp)
  801945:	ff d2                	call   *%edx
  801947:	eb 05                	jmp    80194e <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801949:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80194e:	83 c4 24             	add    $0x24,%esp
  801951:	5b                   	pop    %ebx
  801952:	5d                   	pop    %ebp
  801953:	c3                   	ret    

00801954 <seek>:

int
seek(int fdnum, off_t offset)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80195a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80195d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801961:	8b 45 08             	mov    0x8(%ebp),%eax
  801964:	89 04 24             	mov    %eax,(%esp)
  801967:	e8 ea fb ff ff       	call   801556 <fd_lookup>
  80196c:	85 c0                	test   %eax,%eax
  80196e:	78 0e                	js     80197e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801970:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801973:	8b 55 0c             	mov    0xc(%ebp),%edx
  801976:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801979:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80197e:	c9                   	leave  
  80197f:	c3                   	ret    

00801980 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	53                   	push   %ebx
  801984:	83 ec 24             	sub    $0x24,%esp
  801987:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80198a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80198d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801991:	89 1c 24             	mov    %ebx,(%esp)
  801994:	e8 bd fb ff ff       	call   801556 <fd_lookup>
  801999:	89 c2                	mov    %eax,%edx
  80199b:	85 d2                	test   %edx,%edx
  80199d:	78 61                	js     801a00 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80199f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019a9:	8b 00                	mov    (%eax),%eax
  8019ab:	89 04 24             	mov    %eax,(%esp)
  8019ae:	e8 f9 fb ff ff       	call   8015ac <dev_lookup>
  8019b3:	85 c0                	test   %eax,%eax
  8019b5:	78 49                	js     801a00 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019ba:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019be:	75 23                	jne    8019e3 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8019c0:	a1 b4 50 80 00       	mov    0x8050b4,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019c5:	8b 40 48             	mov    0x48(%eax),%eax
  8019c8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d0:	c7 04 24 2c 30 80 00 	movl   $0x80302c,(%esp)
  8019d7:	e8 19 ed ff ff       	call   8006f5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019e1:	eb 1d                	jmp    801a00 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8019e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019e6:	8b 52 18             	mov    0x18(%edx),%edx
  8019e9:	85 d2                	test   %edx,%edx
  8019eb:	74 0e                	je     8019fb <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019f0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019f4:	89 04 24             	mov    %eax,(%esp)
  8019f7:	ff d2                	call   *%edx
  8019f9:	eb 05                	jmp    801a00 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8019fb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801a00:	83 c4 24             	add    $0x24,%esp
  801a03:	5b                   	pop    %ebx
  801a04:	5d                   	pop    %ebp
  801a05:	c3                   	ret    

00801a06 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a06:	55                   	push   %ebp
  801a07:	89 e5                	mov    %esp,%ebp
  801a09:	53                   	push   %ebx
  801a0a:	83 ec 24             	sub    $0x24,%esp
  801a0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a10:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a13:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a17:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1a:	89 04 24             	mov    %eax,(%esp)
  801a1d:	e8 34 fb ff ff       	call   801556 <fd_lookup>
  801a22:	89 c2                	mov    %eax,%edx
  801a24:	85 d2                	test   %edx,%edx
  801a26:	78 52                	js     801a7a <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a32:	8b 00                	mov    (%eax),%eax
  801a34:	89 04 24             	mov    %eax,(%esp)
  801a37:	e8 70 fb ff ff       	call   8015ac <dev_lookup>
  801a3c:	85 c0                	test   %eax,%eax
  801a3e:	78 3a                	js     801a7a <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a43:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a47:	74 2c                	je     801a75 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a49:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a4c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a53:	00 00 00 
	stat->st_isdir = 0;
  801a56:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a5d:	00 00 00 
	stat->st_dev = dev;
  801a60:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a66:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a6a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a6d:	89 14 24             	mov    %edx,(%esp)
  801a70:	ff 50 14             	call   *0x14(%eax)
  801a73:	eb 05                	jmp    801a7a <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a75:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a7a:	83 c4 24             	add    $0x24,%esp
  801a7d:	5b                   	pop    %ebx
  801a7e:	5d                   	pop    %ebp
  801a7f:	c3                   	ret    

00801a80 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	56                   	push   %esi
  801a84:	53                   	push   %ebx
  801a85:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a88:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a8f:	00 
  801a90:	8b 45 08             	mov    0x8(%ebp),%eax
  801a93:	89 04 24             	mov    %eax,(%esp)
  801a96:	e8 28 02 00 00       	call   801cc3 <open>
  801a9b:	89 c3                	mov    %eax,%ebx
  801a9d:	85 db                	test   %ebx,%ebx
  801a9f:	78 1b                	js     801abc <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801aa1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa8:	89 1c 24             	mov    %ebx,(%esp)
  801aab:	e8 56 ff ff ff       	call   801a06 <fstat>
  801ab0:	89 c6                	mov    %eax,%esi
	close(fd);
  801ab2:	89 1c 24             	mov    %ebx,(%esp)
  801ab5:	e8 cd fb ff ff       	call   801687 <close>
	return r;
  801aba:	89 f0                	mov    %esi,%eax
}
  801abc:	83 c4 10             	add    $0x10,%esp
  801abf:	5b                   	pop    %ebx
  801ac0:	5e                   	pop    %esi
  801ac1:	5d                   	pop    %ebp
  801ac2:	c3                   	ret    

00801ac3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
  801ac6:	56                   	push   %esi
  801ac7:	53                   	push   %ebx
  801ac8:	83 ec 10             	sub    $0x10,%esp
  801acb:	89 c6                	mov    %eax,%esi
  801acd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801acf:	83 3d ac 50 80 00 00 	cmpl   $0x0,0x8050ac
  801ad6:	75 11                	jne    801ae9 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ad8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801adf:	e8 a1 0d 00 00       	call   802885 <ipc_find_env>
  801ae4:	a3 ac 50 80 00       	mov    %eax,0x8050ac
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ae9:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801af0:	00 
  801af1:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801af8:	00 
  801af9:	89 74 24 04          	mov    %esi,0x4(%esp)
  801afd:	a1 ac 50 80 00       	mov    0x8050ac,%eax
  801b02:	89 04 24             	mov    %eax,(%esp)
  801b05:	e8 10 0d 00 00       	call   80281a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801b0a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b11:	00 
  801b12:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b16:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b1d:	e8 7e 0c 00 00       	call   8027a0 <ipc_recv>
}
  801b22:	83 c4 10             	add    $0x10,%esp
  801b25:	5b                   	pop    %ebx
  801b26:	5e                   	pop    %esi
  801b27:	5d                   	pop    %ebp
  801b28:	c3                   	ret    

00801b29 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b29:	55                   	push   %ebp
  801b2a:	89 e5                	mov    %esp,%ebp
  801b2c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b32:	8b 40 0c             	mov    0xc(%eax),%eax
  801b35:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801b3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b3d:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b42:	ba 00 00 00 00       	mov    $0x0,%edx
  801b47:	b8 02 00 00 00       	mov    $0x2,%eax
  801b4c:	e8 72 ff ff ff       	call   801ac3 <fsipc>
}
  801b51:	c9                   	leave  
  801b52:	c3                   	ret    

00801b53 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b59:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5c:	8b 40 0c             	mov    0xc(%eax),%eax
  801b5f:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b64:	ba 00 00 00 00       	mov    $0x0,%edx
  801b69:	b8 06 00 00 00       	mov    $0x6,%eax
  801b6e:	e8 50 ff ff ff       	call   801ac3 <fsipc>
}
  801b73:	c9                   	leave  
  801b74:	c3                   	ret    

00801b75 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b75:	55                   	push   %ebp
  801b76:	89 e5                	mov    %esp,%ebp
  801b78:	53                   	push   %ebx
  801b79:	83 ec 14             	sub    $0x14,%esp
  801b7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b82:	8b 40 0c             	mov    0xc(%eax),%eax
  801b85:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b8a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b8f:	b8 05 00 00 00       	mov    $0x5,%eax
  801b94:	e8 2a ff ff ff       	call   801ac3 <fsipc>
  801b99:	89 c2                	mov    %eax,%edx
  801b9b:	85 d2                	test   %edx,%edx
  801b9d:	78 2b                	js     801bca <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b9f:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801ba6:	00 
  801ba7:	89 1c 24             	mov    %ebx,(%esp)
  801baa:	e8 68 f1 ff ff       	call   800d17 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801baf:	a1 80 60 80 00       	mov    0x806080,%eax
  801bb4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801bba:	a1 84 60 80 00       	mov    0x806084,%eax
  801bbf:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801bc5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bca:	83 c4 14             	add    $0x14,%esp
  801bcd:	5b                   	pop    %ebx
  801bce:	5d                   	pop    %ebp
  801bcf:	c3                   	ret    

00801bd0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
  801bd3:	83 ec 18             	sub    $0x18,%esp
  801bd6:	8b 45 10             	mov    0x10(%ebp),%eax
  801bd9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801bde:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801be3:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801be6:	8b 55 08             	mov    0x8(%ebp),%edx
  801be9:	8b 52 0c             	mov    0xc(%edx),%edx
  801bec:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801bf2:	a3 04 60 80 00       	mov    %eax,0x806004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801bf7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bfb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bfe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c02:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801c09:	e8 a6 f2 ff ff       	call   800eb4 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  801c0e:	ba 00 00 00 00       	mov    $0x0,%edx
  801c13:	b8 04 00 00 00       	mov    $0x4,%eax
  801c18:	e8 a6 fe ff ff       	call   801ac3 <fsipc>
}
  801c1d:	c9                   	leave  
  801c1e:	c3                   	ret    

00801c1f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c1f:	55                   	push   %ebp
  801c20:	89 e5                	mov    %esp,%ebp
  801c22:	56                   	push   %esi
  801c23:	53                   	push   %ebx
  801c24:	83 ec 10             	sub    $0x10,%esp
  801c27:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2d:	8b 40 0c             	mov    0xc(%eax),%eax
  801c30:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801c35:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c3b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c40:	b8 03 00 00 00       	mov    $0x3,%eax
  801c45:	e8 79 fe ff ff       	call   801ac3 <fsipc>
  801c4a:	89 c3                	mov    %eax,%ebx
  801c4c:	85 c0                	test   %eax,%eax
  801c4e:	78 6a                	js     801cba <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801c50:	39 c6                	cmp    %eax,%esi
  801c52:	73 24                	jae    801c78 <devfile_read+0x59>
  801c54:	c7 44 24 0c 9c 30 80 	movl   $0x80309c,0xc(%esp)
  801c5b:	00 
  801c5c:	c7 44 24 08 a3 30 80 	movl   $0x8030a3,0x8(%esp)
  801c63:	00 
  801c64:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801c6b:	00 
  801c6c:	c7 04 24 b8 30 80 00 	movl   $0x8030b8,(%esp)
  801c73:	e8 84 e9 ff ff       	call   8005fc <_panic>
	assert(r <= PGSIZE);
  801c78:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c7d:	7e 24                	jle    801ca3 <devfile_read+0x84>
  801c7f:	c7 44 24 0c c3 30 80 	movl   $0x8030c3,0xc(%esp)
  801c86:	00 
  801c87:	c7 44 24 08 a3 30 80 	movl   $0x8030a3,0x8(%esp)
  801c8e:	00 
  801c8f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801c96:	00 
  801c97:	c7 04 24 b8 30 80 00 	movl   $0x8030b8,(%esp)
  801c9e:	e8 59 e9 ff ff       	call   8005fc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ca3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ca7:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801cae:	00 
  801caf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb2:	89 04 24             	mov    %eax,(%esp)
  801cb5:	e8 fa f1 ff ff       	call   800eb4 <memmove>
	return r;
}
  801cba:	89 d8                	mov    %ebx,%eax
  801cbc:	83 c4 10             	add    $0x10,%esp
  801cbf:	5b                   	pop    %ebx
  801cc0:	5e                   	pop    %esi
  801cc1:	5d                   	pop    %ebp
  801cc2:	c3                   	ret    

00801cc3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801cc3:	55                   	push   %ebp
  801cc4:	89 e5                	mov    %esp,%ebp
  801cc6:	53                   	push   %ebx
  801cc7:	83 ec 24             	sub    $0x24,%esp
  801cca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ccd:	89 1c 24             	mov    %ebx,(%esp)
  801cd0:	e8 0b f0 ff ff       	call   800ce0 <strlen>
  801cd5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801cda:	7f 60                	jg     801d3c <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801cdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cdf:	89 04 24             	mov    %eax,(%esp)
  801ce2:	e8 20 f8 ff ff       	call   801507 <fd_alloc>
  801ce7:	89 c2                	mov    %eax,%edx
  801ce9:	85 d2                	test   %edx,%edx
  801ceb:	78 54                	js     801d41 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ced:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cf1:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801cf8:	e8 1a f0 ff ff       	call   800d17 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801cfd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d00:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801d05:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d08:	b8 01 00 00 00       	mov    $0x1,%eax
  801d0d:	e8 b1 fd ff ff       	call   801ac3 <fsipc>
  801d12:	89 c3                	mov    %eax,%ebx
  801d14:	85 c0                	test   %eax,%eax
  801d16:	79 17                	jns    801d2f <open+0x6c>
		fd_close(fd, 0);
  801d18:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d1f:	00 
  801d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d23:	89 04 24             	mov    %eax,(%esp)
  801d26:	e8 db f8 ff ff       	call   801606 <fd_close>
		return r;
  801d2b:	89 d8                	mov    %ebx,%eax
  801d2d:	eb 12                	jmp    801d41 <open+0x7e>
	}

	return fd2num(fd);
  801d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d32:	89 04 24             	mov    %eax,(%esp)
  801d35:	e8 a6 f7 ff ff       	call   8014e0 <fd2num>
  801d3a:	eb 05                	jmp    801d41 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801d3c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801d41:	83 c4 24             	add    $0x24,%esp
  801d44:	5b                   	pop    %ebx
  801d45:	5d                   	pop    %ebp
  801d46:	c3                   	ret    

00801d47 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801d47:	55                   	push   %ebp
  801d48:	89 e5                	mov    %esp,%ebp
  801d4a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d4d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d52:	b8 08 00 00 00       	mov    $0x8,%eax
  801d57:	e8 67 fd ff ff       	call   801ac3 <fsipc>
}
  801d5c:	c9                   	leave  
  801d5d:	c3                   	ret    
  801d5e:	66 90                	xchg   %ax,%ax

00801d60 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801d60:	55                   	push   %ebp
  801d61:	89 e5                	mov    %esp,%ebp
  801d63:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801d66:	c7 44 24 04 cf 30 80 	movl   $0x8030cf,0x4(%esp)
  801d6d:	00 
  801d6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d71:	89 04 24             	mov    %eax,(%esp)
  801d74:	e8 9e ef ff ff       	call   800d17 <strcpy>
	return 0;
}
  801d79:	b8 00 00 00 00       	mov    $0x0,%eax
  801d7e:	c9                   	leave  
  801d7f:	c3                   	ret    

00801d80 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	53                   	push   %ebx
  801d84:	83 ec 14             	sub    $0x14,%esp
  801d87:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801d8a:	89 1c 24             	mov    %ebx,(%esp)
  801d8d:	e8 2b 0b 00 00       	call   8028bd <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801d92:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801d97:	83 f8 01             	cmp    $0x1,%eax
  801d9a:	75 0d                	jne    801da9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801d9c:	8b 43 0c             	mov    0xc(%ebx),%eax
  801d9f:	89 04 24             	mov    %eax,(%esp)
  801da2:	e8 29 03 00 00       	call   8020d0 <nsipc_close>
  801da7:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  801da9:	89 d0                	mov    %edx,%eax
  801dab:	83 c4 14             	add    $0x14,%esp
  801dae:	5b                   	pop    %ebx
  801daf:	5d                   	pop    %ebp
  801db0:	c3                   	ret    

00801db1 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801db1:	55                   	push   %ebp
  801db2:	89 e5                	mov    %esp,%ebp
  801db4:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801db7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801dbe:	00 
  801dbf:	8b 45 10             	mov    0x10(%ebp),%eax
  801dc2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dcd:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd0:	8b 40 0c             	mov    0xc(%eax),%eax
  801dd3:	89 04 24             	mov    %eax,(%esp)
  801dd6:	e8 f0 03 00 00       	call   8021cb <nsipc_send>
}
  801ddb:	c9                   	leave  
  801ddc:	c3                   	ret    

00801ddd <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801ddd:	55                   	push   %ebp
  801dde:	89 e5                	mov    %esp,%ebp
  801de0:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801de3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801dea:	00 
  801deb:	8b 45 10             	mov    0x10(%ebp),%eax
  801dee:	89 44 24 08          	mov    %eax,0x8(%esp)
  801df2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801df9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfc:	8b 40 0c             	mov    0xc(%eax),%eax
  801dff:	89 04 24             	mov    %eax,(%esp)
  801e02:	e8 44 03 00 00       	call   80214b <nsipc_recv>
}
  801e07:	c9                   	leave  
  801e08:	c3                   	ret    

00801e09 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801e09:	55                   	push   %ebp
  801e0a:	89 e5                	mov    %esp,%ebp
  801e0c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801e0f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801e12:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e16:	89 04 24             	mov    %eax,(%esp)
  801e19:	e8 38 f7 ff ff       	call   801556 <fd_lookup>
  801e1e:	85 c0                	test   %eax,%eax
  801e20:	78 17                	js     801e39 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e25:	8b 0d 20 40 80 00    	mov    0x804020,%ecx
  801e2b:	39 08                	cmp    %ecx,(%eax)
  801e2d:	75 05                	jne    801e34 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801e2f:	8b 40 0c             	mov    0xc(%eax),%eax
  801e32:	eb 05                	jmp    801e39 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801e34:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801e39:	c9                   	leave  
  801e3a:	c3                   	ret    

00801e3b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801e3b:	55                   	push   %ebp
  801e3c:	89 e5                	mov    %esp,%ebp
  801e3e:	56                   	push   %esi
  801e3f:	53                   	push   %ebx
  801e40:	83 ec 20             	sub    $0x20,%esp
  801e43:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801e45:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e48:	89 04 24             	mov    %eax,(%esp)
  801e4b:	e8 b7 f6 ff ff       	call   801507 <fd_alloc>
  801e50:	89 c3                	mov    %eax,%ebx
  801e52:	85 c0                	test   %eax,%eax
  801e54:	78 21                	js     801e77 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801e56:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e5d:	00 
  801e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e61:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e6c:	e8 c2 f2 ff ff       	call   801133 <sys_page_alloc>
  801e71:	89 c3                	mov    %eax,%ebx
  801e73:	85 c0                	test   %eax,%eax
  801e75:	79 0c                	jns    801e83 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  801e77:	89 34 24             	mov    %esi,(%esp)
  801e7a:	e8 51 02 00 00       	call   8020d0 <nsipc_close>
		return r;
  801e7f:	89 d8                	mov    %ebx,%eax
  801e81:	eb 20                	jmp    801ea3 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801e83:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801e8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e91:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801e98:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801e9b:	89 14 24             	mov    %edx,(%esp)
  801e9e:	e8 3d f6 ff ff       	call   8014e0 <fd2num>
}
  801ea3:	83 c4 20             	add    $0x20,%esp
  801ea6:	5b                   	pop    %ebx
  801ea7:	5e                   	pop    %esi
  801ea8:	5d                   	pop    %ebp
  801ea9:	c3                   	ret    

00801eaa <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801eaa:	55                   	push   %ebp
  801eab:	89 e5                	mov    %esp,%ebp
  801ead:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801eb0:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb3:	e8 51 ff ff ff       	call   801e09 <fd2sockid>
		return r;
  801eb8:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801eba:	85 c0                	test   %eax,%eax
  801ebc:	78 23                	js     801ee1 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ebe:	8b 55 10             	mov    0x10(%ebp),%edx
  801ec1:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ec5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ec8:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ecc:	89 04 24             	mov    %eax,(%esp)
  801ecf:	e8 45 01 00 00       	call   802019 <nsipc_accept>
		return r;
  801ed4:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ed6:	85 c0                	test   %eax,%eax
  801ed8:	78 07                	js     801ee1 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  801eda:	e8 5c ff ff ff       	call   801e3b <alloc_sockfd>
  801edf:	89 c1                	mov    %eax,%ecx
}
  801ee1:	89 c8                	mov    %ecx,%eax
  801ee3:	c9                   	leave  
  801ee4:	c3                   	ret    

00801ee5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ee5:	55                   	push   %ebp
  801ee6:	89 e5                	mov    %esp,%ebp
  801ee8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801eeb:	8b 45 08             	mov    0x8(%ebp),%eax
  801eee:	e8 16 ff ff ff       	call   801e09 <fd2sockid>
  801ef3:	89 c2                	mov    %eax,%edx
  801ef5:	85 d2                	test   %edx,%edx
  801ef7:	78 16                	js     801f0f <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  801ef9:	8b 45 10             	mov    0x10(%ebp),%eax
  801efc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f00:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f03:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f07:	89 14 24             	mov    %edx,(%esp)
  801f0a:	e8 60 01 00 00       	call   80206f <nsipc_bind>
}
  801f0f:	c9                   	leave  
  801f10:	c3                   	ret    

00801f11 <shutdown>:

int
shutdown(int s, int how)
{
  801f11:	55                   	push   %ebp
  801f12:	89 e5                	mov    %esp,%ebp
  801f14:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f17:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1a:	e8 ea fe ff ff       	call   801e09 <fd2sockid>
  801f1f:	89 c2                	mov    %eax,%edx
  801f21:	85 d2                	test   %edx,%edx
  801f23:	78 0f                	js     801f34 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801f25:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f28:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f2c:	89 14 24             	mov    %edx,(%esp)
  801f2f:	e8 7a 01 00 00       	call   8020ae <nsipc_shutdown>
}
  801f34:	c9                   	leave  
  801f35:	c3                   	ret    

00801f36 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f36:	55                   	push   %ebp
  801f37:	89 e5                	mov    %esp,%ebp
  801f39:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3f:	e8 c5 fe ff ff       	call   801e09 <fd2sockid>
  801f44:	89 c2                	mov    %eax,%edx
  801f46:	85 d2                	test   %edx,%edx
  801f48:	78 16                	js     801f60 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  801f4a:	8b 45 10             	mov    0x10(%ebp),%eax
  801f4d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f51:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f54:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f58:	89 14 24             	mov    %edx,(%esp)
  801f5b:	e8 8a 01 00 00       	call   8020ea <nsipc_connect>
}
  801f60:	c9                   	leave  
  801f61:	c3                   	ret    

00801f62 <listen>:

int
listen(int s, int backlog)
{
  801f62:	55                   	push   %ebp
  801f63:	89 e5                	mov    %esp,%ebp
  801f65:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f68:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6b:	e8 99 fe ff ff       	call   801e09 <fd2sockid>
  801f70:	89 c2                	mov    %eax,%edx
  801f72:	85 d2                	test   %edx,%edx
  801f74:	78 0f                	js     801f85 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801f76:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f79:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f7d:	89 14 24             	mov    %edx,(%esp)
  801f80:	e8 a4 01 00 00       	call   802129 <nsipc_listen>
}
  801f85:	c9                   	leave  
  801f86:	c3                   	ret    

00801f87 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801f87:	55                   	push   %ebp
  801f88:	89 e5                	mov    %esp,%ebp
  801f8a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f8d:	8b 45 10             	mov    0x10(%ebp),%eax
  801f90:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f94:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f97:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9e:	89 04 24             	mov    %eax,(%esp)
  801fa1:	e8 98 02 00 00       	call   80223e <nsipc_socket>
  801fa6:	89 c2                	mov    %eax,%edx
  801fa8:	85 d2                	test   %edx,%edx
  801faa:	78 05                	js     801fb1 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  801fac:	e8 8a fe ff ff       	call   801e3b <alloc_sockfd>
}
  801fb1:	c9                   	leave  
  801fb2:	c3                   	ret    

00801fb3 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801fb3:	55                   	push   %ebp
  801fb4:	89 e5                	mov    %esp,%ebp
  801fb6:	53                   	push   %ebx
  801fb7:	83 ec 14             	sub    $0x14,%esp
  801fba:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801fbc:	83 3d b0 50 80 00 00 	cmpl   $0x0,0x8050b0
  801fc3:	75 11                	jne    801fd6 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801fc5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801fcc:	e8 b4 08 00 00       	call   802885 <ipc_find_env>
  801fd1:	a3 b0 50 80 00       	mov    %eax,0x8050b0
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801fd6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801fdd:	00 
  801fde:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801fe5:	00 
  801fe6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801fea:	a1 b0 50 80 00       	mov    0x8050b0,%eax
  801fef:	89 04 24             	mov    %eax,(%esp)
  801ff2:	e8 23 08 00 00       	call   80281a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ff7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ffe:	00 
  801fff:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802006:	00 
  802007:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80200e:	e8 8d 07 00 00       	call   8027a0 <ipc_recv>
}
  802013:	83 c4 14             	add    $0x14,%esp
  802016:	5b                   	pop    %ebx
  802017:	5d                   	pop    %ebp
  802018:	c3                   	ret    

00802019 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802019:	55                   	push   %ebp
  80201a:	89 e5                	mov    %esp,%ebp
  80201c:	56                   	push   %esi
  80201d:	53                   	push   %ebx
  80201e:	83 ec 10             	sub    $0x10,%esp
  802021:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802024:	8b 45 08             	mov    0x8(%ebp),%eax
  802027:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80202c:	8b 06                	mov    (%esi),%eax
  80202e:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802033:	b8 01 00 00 00       	mov    $0x1,%eax
  802038:	e8 76 ff ff ff       	call   801fb3 <nsipc>
  80203d:	89 c3                	mov    %eax,%ebx
  80203f:	85 c0                	test   %eax,%eax
  802041:	78 23                	js     802066 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802043:	a1 10 70 80 00       	mov    0x807010,%eax
  802048:	89 44 24 08          	mov    %eax,0x8(%esp)
  80204c:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802053:	00 
  802054:	8b 45 0c             	mov    0xc(%ebp),%eax
  802057:	89 04 24             	mov    %eax,(%esp)
  80205a:	e8 55 ee ff ff       	call   800eb4 <memmove>
		*addrlen = ret->ret_addrlen;
  80205f:	a1 10 70 80 00       	mov    0x807010,%eax
  802064:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  802066:	89 d8                	mov    %ebx,%eax
  802068:	83 c4 10             	add    $0x10,%esp
  80206b:	5b                   	pop    %ebx
  80206c:	5e                   	pop    %esi
  80206d:	5d                   	pop    %ebp
  80206e:	c3                   	ret    

0080206f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80206f:	55                   	push   %ebp
  802070:	89 e5                	mov    %esp,%ebp
  802072:	53                   	push   %ebx
  802073:	83 ec 14             	sub    $0x14,%esp
  802076:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802079:	8b 45 08             	mov    0x8(%ebp),%eax
  80207c:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802081:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802085:	8b 45 0c             	mov    0xc(%ebp),%eax
  802088:	89 44 24 04          	mov    %eax,0x4(%esp)
  80208c:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802093:	e8 1c ee ff ff       	call   800eb4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802098:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80209e:	b8 02 00 00 00       	mov    $0x2,%eax
  8020a3:	e8 0b ff ff ff       	call   801fb3 <nsipc>
}
  8020a8:	83 c4 14             	add    $0x14,%esp
  8020ab:	5b                   	pop    %ebx
  8020ac:	5d                   	pop    %ebp
  8020ad:	c3                   	ret    

008020ae <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8020ae:	55                   	push   %ebp
  8020af:	89 e5                	mov    %esp,%ebp
  8020b1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8020b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8020bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020bf:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8020c4:	b8 03 00 00 00       	mov    $0x3,%eax
  8020c9:	e8 e5 fe ff ff       	call   801fb3 <nsipc>
}
  8020ce:	c9                   	leave  
  8020cf:	c3                   	ret    

008020d0 <nsipc_close>:

int
nsipc_close(int s)
{
  8020d0:	55                   	push   %ebp
  8020d1:	89 e5                	mov    %esp,%ebp
  8020d3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8020d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d9:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8020de:	b8 04 00 00 00       	mov    $0x4,%eax
  8020e3:	e8 cb fe ff ff       	call   801fb3 <nsipc>
}
  8020e8:	c9                   	leave  
  8020e9:	c3                   	ret    

008020ea <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020ea:	55                   	push   %ebp
  8020eb:	89 e5                	mov    %esp,%ebp
  8020ed:	53                   	push   %ebx
  8020ee:	83 ec 14             	sub    $0x14,%esp
  8020f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8020f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f7:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8020fc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802100:	8b 45 0c             	mov    0xc(%ebp),%eax
  802103:	89 44 24 04          	mov    %eax,0x4(%esp)
  802107:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  80210e:	e8 a1 ed ff ff       	call   800eb4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802113:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802119:	b8 05 00 00 00       	mov    $0x5,%eax
  80211e:	e8 90 fe ff ff       	call   801fb3 <nsipc>
}
  802123:	83 c4 14             	add    $0x14,%esp
  802126:	5b                   	pop    %ebx
  802127:	5d                   	pop    %ebp
  802128:	c3                   	ret    

00802129 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802129:	55                   	push   %ebp
  80212a:	89 e5                	mov    %esp,%ebp
  80212c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80212f:	8b 45 08             	mov    0x8(%ebp),%eax
  802132:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802137:	8b 45 0c             	mov    0xc(%ebp),%eax
  80213a:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  80213f:	b8 06 00 00 00       	mov    $0x6,%eax
  802144:	e8 6a fe ff ff       	call   801fb3 <nsipc>
}
  802149:	c9                   	leave  
  80214a:	c3                   	ret    

0080214b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80214b:	55                   	push   %ebp
  80214c:	89 e5                	mov    %esp,%ebp
  80214e:	56                   	push   %esi
  80214f:	53                   	push   %ebx
  802150:	83 ec 10             	sub    $0x10,%esp
  802153:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802156:	8b 45 08             	mov    0x8(%ebp),%eax
  802159:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  80215e:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802164:	8b 45 14             	mov    0x14(%ebp),%eax
  802167:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80216c:	b8 07 00 00 00       	mov    $0x7,%eax
  802171:	e8 3d fe ff ff       	call   801fb3 <nsipc>
  802176:	89 c3                	mov    %eax,%ebx
  802178:	85 c0                	test   %eax,%eax
  80217a:	78 46                	js     8021c2 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  80217c:	39 f0                	cmp    %esi,%eax
  80217e:	7f 07                	jg     802187 <nsipc_recv+0x3c>
  802180:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802185:	7e 24                	jle    8021ab <nsipc_recv+0x60>
  802187:	c7 44 24 0c db 30 80 	movl   $0x8030db,0xc(%esp)
  80218e:	00 
  80218f:	c7 44 24 08 a3 30 80 	movl   $0x8030a3,0x8(%esp)
  802196:	00 
  802197:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80219e:	00 
  80219f:	c7 04 24 f0 30 80 00 	movl   $0x8030f0,(%esp)
  8021a6:	e8 51 e4 ff ff       	call   8005fc <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8021ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021af:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8021b6:	00 
  8021b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021ba:	89 04 24             	mov    %eax,(%esp)
  8021bd:	e8 f2 ec ff ff       	call   800eb4 <memmove>
	}

	return r;
}
  8021c2:	89 d8                	mov    %ebx,%eax
  8021c4:	83 c4 10             	add    $0x10,%esp
  8021c7:	5b                   	pop    %ebx
  8021c8:	5e                   	pop    %esi
  8021c9:	5d                   	pop    %ebp
  8021ca:	c3                   	ret    

008021cb <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8021cb:	55                   	push   %ebp
  8021cc:	89 e5                	mov    %esp,%ebp
  8021ce:	53                   	push   %ebx
  8021cf:	83 ec 14             	sub    $0x14,%esp
  8021d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8021d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d8:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8021dd:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8021e3:	7e 24                	jle    802209 <nsipc_send+0x3e>
  8021e5:	c7 44 24 0c fc 30 80 	movl   $0x8030fc,0xc(%esp)
  8021ec:	00 
  8021ed:	c7 44 24 08 a3 30 80 	movl   $0x8030a3,0x8(%esp)
  8021f4:	00 
  8021f5:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8021fc:	00 
  8021fd:	c7 04 24 f0 30 80 00 	movl   $0x8030f0,(%esp)
  802204:	e8 f3 e3 ff ff       	call   8005fc <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802209:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80220d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802210:	89 44 24 04          	mov    %eax,0x4(%esp)
  802214:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  80221b:	e8 94 ec ff ff       	call   800eb4 <memmove>
	nsipcbuf.send.req_size = size;
  802220:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802226:	8b 45 14             	mov    0x14(%ebp),%eax
  802229:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  80222e:	b8 08 00 00 00       	mov    $0x8,%eax
  802233:	e8 7b fd ff ff       	call   801fb3 <nsipc>
}
  802238:	83 c4 14             	add    $0x14,%esp
  80223b:	5b                   	pop    %ebx
  80223c:	5d                   	pop    %ebp
  80223d:	c3                   	ret    

0080223e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80223e:	55                   	push   %ebp
  80223f:	89 e5                	mov    %esp,%ebp
  802241:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802244:	8b 45 08             	mov    0x8(%ebp),%eax
  802247:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  80224c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80224f:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802254:	8b 45 10             	mov    0x10(%ebp),%eax
  802257:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  80225c:	b8 09 00 00 00       	mov    $0x9,%eax
  802261:	e8 4d fd ff ff       	call   801fb3 <nsipc>
}
  802266:	c9                   	leave  
  802267:	c3                   	ret    

00802268 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802268:	55                   	push   %ebp
  802269:	89 e5                	mov    %esp,%ebp
  80226b:	56                   	push   %esi
  80226c:	53                   	push   %ebx
  80226d:	83 ec 10             	sub    $0x10,%esp
  802270:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802273:	8b 45 08             	mov    0x8(%ebp),%eax
  802276:	89 04 24             	mov    %eax,(%esp)
  802279:	e8 72 f2 ff ff       	call   8014f0 <fd2data>
  80227e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802280:	c7 44 24 04 08 31 80 	movl   $0x803108,0x4(%esp)
  802287:	00 
  802288:	89 1c 24             	mov    %ebx,(%esp)
  80228b:	e8 87 ea ff ff       	call   800d17 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802290:	8b 46 04             	mov    0x4(%esi),%eax
  802293:	2b 06                	sub    (%esi),%eax
  802295:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80229b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8022a2:	00 00 00 
	stat->st_dev = &devpipe;
  8022a5:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  8022ac:	40 80 00 
	return 0;
}
  8022af:	b8 00 00 00 00       	mov    $0x0,%eax
  8022b4:	83 c4 10             	add    $0x10,%esp
  8022b7:	5b                   	pop    %ebx
  8022b8:	5e                   	pop    %esi
  8022b9:	5d                   	pop    %ebp
  8022ba:	c3                   	ret    

008022bb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8022bb:	55                   	push   %ebp
  8022bc:	89 e5                	mov    %esp,%ebp
  8022be:	53                   	push   %ebx
  8022bf:	83 ec 14             	sub    $0x14,%esp
  8022c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8022c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8022c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022d0:	e8 05 ef ff ff       	call   8011da <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8022d5:	89 1c 24             	mov    %ebx,(%esp)
  8022d8:	e8 13 f2 ff ff       	call   8014f0 <fd2data>
  8022dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022e8:	e8 ed ee ff ff       	call   8011da <sys_page_unmap>
}
  8022ed:	83 c4 14             	add    $0x14,%esp
  8022f0:	5b                   	pop    %ebx
  8022f1:	5d                   	pop    %ebp
  8022f2:	c3                   	ret    

008022f3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8022f3:	55                   	push   %ebp
  8022f4:	89 e5                	mov    %esp,%ebp
  8022f6:	57                   	push   %edi
  8022f7:	56                   	push   %esi
  8022f8:	53                   	push   %ebx
  8022f9:	83 ec 2c             	sub    $0x2c,%esp
  8022fc:	89 c6                	mov    %eax,%esi
  8022fe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802301:	a1 b4 50 80 00       	mov    0x8050b4,%eax
  802306:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802309:	89 34 24             	mov    %esi,(%esp)
  80230c:	e8 ac 05 00 00       	call   8028bd <pageref>
  802311:	89 c7                	mov    %eax,%edi
  802313:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802316:	89 04 24             	mov    %eax,(%esp)
  802319:	e8 9f 05 00 00       	call   8028bd <pageref>
  80231e:	39 c7                	cmp    %eax,%edi
  802320:	0f 94 c2             	sete   %dl
  802323:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  802326:	8b 0d b4 50 80 00    	mov    0x8050b4,%ecx
  80232c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  80232f:	39 fb                	cmp    %edi,%ebx
  802331:	74 21                	je     802354 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802333:	84 d2                	test   %dl,%dl
  802335:	74 ca                	je     802301 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802337:	8b 51 58             	mov    0x58(%ecx),%edx
  80233a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80233e:	89 54 24 08          	mov    %edx,0x8(%esp)
  802342:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802346:	c7 04 24 0f 31 80 00 	movl   $0x80310f,(%esp)
  80234d:	e8 a3 e3 ff ff       	call   8006f5 <cprintf>
  802352:	eb ad                	jmp    802301 <_pipeisclosed+0xe>
	}
}
  802354:	83 c4 2c             	add    $0x2c,%esp
  802357:	5b                   	pop    %ebx
  802358:	5e                   	pop    %esi
  802359:	5f                   	pop    %edi
  80235a:	5d                   	pop    %ebp
  80235b:	c3                   	ret    

0080235c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80235c:	55                   	push   %ebp
  80235d:	89 e5                	mov    %esp,%ebp
  80235f:	57                   	push   %edi
  802360:	56                   	push   %esi
  802361:	53                   	push   %ebx
  802362:	83 ec 1c             	sub    $0x1c,%esp
  802365:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802368:	89 34 24             	mov    %esi,(%esp)
  80236b:	e8 80 f1 ff ff       	call   8014f0 <fd2data>
  802370:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802372:	bf 00 00 00 00       	mov    $0x0,%edi
  802377:	eb 45                	jmp    8023be <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802379:	89 da                	mov    %ebx,%edx
  80237b:	89 f0                	mov    %esi,%eax
  80237d:	e8 71 ff ff ff       	call   8022f3 <_pipeisclosed>
  802382:	85 c0                	test   %eax,%eax
  802384:	75 41                	jne    8023c7 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802386:	e8 89 ed ff ff       	call   801114 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80238b:	8b 43 04             	mov    0x4(%ebx),%eax
  80238e:	8b 0b                	mov    (%ebx),%ecx
  802390:	8d 51 20             	lea    0x20(%ecx),%edx
  802393:	39 d0                	cmp    %edx,%eax
  802395:	73 e2                	jae    802379 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802397:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80239a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80239e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8023a1:	99                   	cltd   
  8023a2:	c1 ea 1b             	shr    $0x1b,%edx
  8023a5:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8023a8:	83 e1 1f             	and    $0x1f,%ecx
  8023ab:	29 d1                	sub    %edx,%ecx
  8023ad:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8023b1:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8023b5:	83 c0 01             	add    $0x1,%eax
  8023b8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023bb:	83 c7 01             	add    $0x1,%edi
  8023be:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8023c1:	75 c8                	jne    80238b <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8023c3:	89 f8                	mov    %edi,%eax
  8023c5:	eb 05                	jmp    8023cc <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023c7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8023cc:	83 c4 1c             	add    $0x1c,%esp
  8023cf:	5b                   	pop    %ebx
  8023d0:	5e                   	pop    %esi
  8023d1:	5f                   	pop    %edi
  8023d2:	5d                   	pop    %ebp
  8023d3:	c3                   	ret    

008023d4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8023d4:	55                   	push   %ebp
  8023d5:	89 e5                	mov    %esp,%ebp
  8023d7:	57                   	push   %edi
  8023d8:	56                   	push   %esi
  8023d9:	53                   	push   %ebx
  8023da:	83 ec 1c             	sub    $0x1c,%esp
  8023dd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8023e0:	89 3c 24             	mov    %edi,(%esp)
  8023e3:	e8 08 f1 ff ff       	call   8014f0 <fd2data>
  8023e8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023ea:	be 00 00 00 00       	mov    $0x0,%esi
  8023ef:	eb 3d                	jmp    80242e <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8023f1:	85 f6                	test   %esi,%esi
  8023f3:	74 04                	je     8023f9 <devpipe_read+0x25>
				return i;
  8023f5:	89 f0                	mov    %esi,%eax
  8023f7:	eb 43                	jmp    80243c <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8023f9:	89 da                	mov    %ebx,%edx
  8023fb:	89 f8                	mov    %edi,%eax
  8023fd:	e8 f1 fe ff ff       	call   8022f3 <_pipeisclosed>
  802402:	85 c0                	test   %eax,%eax
  802404:	75 31                	jne    802437 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802406:	e8 09 ed ff ff       	call   801114 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80240b:	8b 03                	mov    (%ebx),%eax
  80240d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802410:	74 df                	je     8023f1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802412:	99                   	cltd   
  802413:	c1 ea 1b             	shr    $0x1b,%edx
  802416:	01 d0                	add    %edx,%eax
  802418:	83 e0 1f             	and    $0x1f,%eax
  80241b:	29 d0                	sub    %edx,%eax
  80241d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802422:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802425:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802428:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80242b:	83 c6 01             	add    $0x1,%esi
  80242e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802431:	75 d8                	jne    80240b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802433:	89 f0                	mov    %esi,%eax
  802435:	eb 05                	jmp    80243c <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802437:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80243c:	83 c4 1c             	add    $0x1c,%esp
  80243f:	5b                   	pop    %ebx
  802440:	5e                   	pop    %esi
  802441:	5f                   	pop    %edi
  802442:	5d                   	pop    %ebp
  802443:	c3                   	ret    

00802444 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802444:	55                   	push   %ebp
  802445:	89 e5                	mov    %esp,%ebp
  802447:	56                   	push   %esi
  802448:	53                   	push   %ebx
  802449:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80244c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80244f:	89 04 24             	mov    %eax,(%esp)
  802452:	e8 b0 f0 ff ff       	call   801507 <fd_alloc>
  802457:	89 c2                	mov    %eax,%edx
  802459:	85 d2                	test   %edx,%edx
  80245b:	0f 88 4d 01 00 00    	js     8025ae <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802461:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802468:	00 
  802469:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80246c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802470:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802477:	e8 b7 ec ff ff       	call   801133 <sys_page_alloc>
  80247c:	89 c2                	mov    %eax,%edx
  80247e:	85 d2                	test   %edx,%edx
  802480:	0f 88 28 01 00 00    	js     8025ae <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802486:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802489:	89 04 24             	mov    %eax,(%esp)
  80248c:	e8 76 f0 ff ff       	call   801507 <fd_alloc>
  802491:	89 c3                	mov    %eax,%ebx
  802493:	85 c0                	test   %eax,%eax
  802495:	0f 88 fe 00 00 00    	js     802599 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80249b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8024a2:	00 
  8024a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024b1:	e8 7d ec ff ff       	call   801133 <sys_page_alloc>
  8024b6:	89 c3                	mov    %eax,%ebx
  8024b8:	85 c0                	test   %eax,%eax
  8024ba:	0f 88 d9 00 00 00    	js     802599 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8024c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024c3:	89 04 24             	mov    %eax,(%esp)
  8024c6:	e8 25 f0 ff ff       	call   8014f0 <fd2data>
  8024cb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024cd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8024d4:	00 
  8024d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024e0:	e8 4e ec ff ff       	call   801133 <sys_page_alloc>
  8024e5:	89 c3                	mov    %eax,%ebx
  8024e7:	85 c0                	test   %eax,%eax
  8024e9:	0f 88 97 00 00 00    	js     802586 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024f2:	89 04 24             	mov    %eax,(%esp)
  8024f5:	e8 f6 ef ff ff       	call   8014f0 <fd2data>
  8024fa:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802501:	00 
  802502:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802506:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80250d:	00 
  80250e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802512:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802519:	e8 69 ec ff ff       	call   801187 <sys_page_map>
  80251e:	89 c3                	mov    %eax,%ebx
  802520:	85 c0                	test   %eax,%eax
  802522:	78 52                	js     802576 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802524:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80252a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80252d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80252f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802532:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802539:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80253f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802542:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802544:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802547:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80254e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802551:	89 04 24             	mov    %eax,(%esp)
  802554:	e8 87 ef ff ff       	call   8014e0 <fd2num>
  802559:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80255c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80255e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802561:	89 04 24             	mov    %eax,(%esp)
  802564:	e8 77 ef ff ff       	call   8014e0 <fd2num>
  802569:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80256c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80256f:	b8 00 00 00 00       	mov    $0x0,%eax
  802574:	eb 38                	jmp    8025ae <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  802576:	89 74 24 04          	mov    %esi,0x4(%esp)
  80257a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802581:	e8 54 ec ff ff       	call   8011da <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802586:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802589:	89 44 24 04          	mov    %eax,0x4(%esp)
  80258d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802594:	e8 41 ec ff ff       	call   8011da <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802599:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80259c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025a7:	e8 2e ec ff ff       	call   8011da <sys_page_unmap>
  8025ac:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  8025ae:	83 c4 30             	add    $0x30,%esp
  8025b1:	5b                   	pop    %ebx
  8025b2:	5e                   	pop    %esi
  8025b3:	5d                   	pop    %ebp
  8025b4:	c3                   	ret    

008025b5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8025b5:	55                   	push   %ebp
  8025b6:	89 e5                	mov    %esp,%ebp
  8025b8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8025c5:	89 04 24             	mov    %eax,(%esp)
  8025c8:	e8 89 ef ff ff       	call   801556 <fd_lookup>
  8025cd:	89 c2                	mov    %eax,%edx
  8025cf:	85 d2                	test   %edx,%edx
  8025d1:	78 15                	js     8025e8 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8025d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025d6:	89 04 24             	mov    %eax,(%esp)
  8025d9:	e8 12 ef ff ff       	call   8014f0 <fd2data>
	return _pipeisclosed(fd, p);
  8025de:	89 c2                	mov    %eax,%edx
  8025e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025e3:	e8 0b fd ff ff       	call   8022f3 <_pipeisclosed>
}
  8025e8:	c9                   	leave  
  8025e9:	c3                   	ret    
  8025ea:	66 90                	xchg   %ax,%ax
  8025ec:	66 90                	xchg   %ax,%ax
  8025ee:	66 90                	xchg   %ax,%ax

008025f0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8025f0:	55                   	push   %ebp
  8025f1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8025f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8025f8:	5d                   	pop    %ebp
  8025f9:	c3                   	ret    

008025fa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8025fa:	55                   	push   %ebp
  8025fb:	89 e5                	mov    %esp,%ebp
  8025fd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802600:	c7 44 24 04 27 31 80 	movl   $0x803127,0x4(%esp)
  802607:	00 
  802608:	8b 45 0c             	mov    0xc(%ebp),%eax
  80260b:	89 04 24             	mov    %eax,(%esp)
  80260e:	e8 04 e7 ff ff       	call   800d17 <strcpy>
	return 0;
}
  802613:	b8 00 00 00 00       	mov    $0x0,%eax
  802618:	c9                   	leave  
  802619:	c3                   	ret    

0080261a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80261a:	55                   	push   %ebp
  80261b:	89 e5                	mov    %esp,%ebp
  80261d:	57                   	push   %edi
  80261e:	56                   	push   %esi
  80261f:	53                   	push   %ebx
  802620:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802626:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80262b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802631:	eb 31                	jmp    802664 <devcons_write+0x4a>
		m = n - tot;
  802633:	8b 75 10             	mov    0x10(%ebp),%esi
  802636:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802638:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80263b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802640:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802643:	89 74 24 08          	mov    %esi,0x8(%esp)
  802647:	03 45 0c             	add    0xc(%ebp),%eax
  80264a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80264e:	89 3c 24             	mov    %edi,(%esp)
  802651:	e8 5e e8 ff ff       	call   800eb4 <memmove>
		sys_cputs(buf, m);
  802656:	89 74 24 04          	mov    %esi,0x4(%esp)
  80265a:	89 3c 24             	mov    %edi,(%esp)
  80265d:	e8 04 ea ff ff       	call   801066 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802662:	01 f3                	add    %esi,%ebx
  802664:	89 d8                	mov    %ebx,%eax
  802666:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802669:	72 c8                	jb     802633 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80266b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802671:	5b                   	pop    %ebx
  802672:	5e                   	pop    %esi
  802673:	5f                   	pop    %edi
  802674:	5d                   	pop    %ebp
  802675:	c3                   	ret    

00802676 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802676:	55                   	push   %ebp
  802677:	89 e5                	mov    %esp,%ebp
  802679:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80267c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802681:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802685:	75 07                	jne    80268e <devcons_read+0x18>
  802687:	eb 2a                	jmp    8026b3 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802689:	e8 86 ea ff ff       	call   801114 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80268e:	66 90                	xchg   %ax,%ax
  802690:	e8 ef e9 ff ff       	call   801084 <sys_cgetc>
  802695:	85 c0                	test   %eax,%eax
  802697:	74 f0                	je     802689 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802699:	85 c0                	test   %eax,%eax
  80269b:	78 16                	js     8026b3 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80269d:	83 f8 04             	cmp    $0x4,%eax
  8026a0:	74 0c                	je     8026ae <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  8026a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8026a5:	88 02                	mov    %al,(%edx)
	return 1;
  8026a7:	b8 01 00 00 00       	mov    $0x1,%eax
  8026ac:	eb 05                	jmp    8026b3 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8026ae:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8026b3:	c9                   	leave  
  8026b4:	c3                   	ret    

008026b5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8026b5:	55                   	push   %ebp
  8026b6:	89 e5                	mov    %esp,%ebp
  8026b8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8026bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8026be:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8026c1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8026c8:	00 
  8026c9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8026cc:	89 04 24             	mov    %eax,(%esp)
  8026cf:	e8 92 e9 ff ff       	call   801066 <sys_cputs>
}
  8026d4:	c9                   	leave  
  8026d5:	c3                   	ret    

008026d6 <getchar>:

int
getchar(void)
{
  8026d6:	55                   	push   %ebp
  8026d7:	89 e5                	mov    %esp,%ebp
  8026d9:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8026dc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8026e3:	00 
  8026e4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8026e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026f2:	e8 f3 f0 ff ff       	call   8017ea <read>
	if (r < 0)
  8026f7:	85 c0                	test   %eax,%eax
  8026f9:	78 0f                	js     80270a <getchar+0x34>
		return r;
	if (r < 1)
  8026fb:	85 c0                	test   %eax,%eax
  8026fd:	7e 06                	jle    802705 <getchar+0x2f>
		return -E_EOF;
	return c;
  8026ff:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802703:	eb 05                	jmp    80270a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802705:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80270a:	c9                   	leave  
  80270b:	c3                   	ret    

0080270c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80270c:	55                   	push   %ebp
  80270d:	89 e5                	mov    %esp,%ebp
  80270f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802712:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802715:	89 44 24 04          	mov    %eax,0x4(%esp)
  802719:	8b 45 08             	mov    0x8(%ebp),%eax
  80271c:	89 04 24             	mov    %eax,(%esp)
  80271f:	e8 32 ee ff ff       	call   801556 <fd_lookup>
  802724:	85 c0                	test   %eax,%eax
  802726:	78 11                	js     802739 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802728:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80272b:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802731:	39 10                	cmp    %edx,(%eax)
  802733:	0f 94 c0             	sete   %al
  802736:	0f b6 c0             	movzbl %al,%eax
}
  802739:	c9                   	leave  
  80273a:	c3                   	ret    

0080273b <opencons>:

int
opencons(void)
{
  80273b:	55                   	push   %ebp
  80273c:	89 e5                	mov    %esp,%ebp
  80273e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802741:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802744:	89 04 24             	mov    %eax,(%esp)
  802747:	e8 bb ed ff ff       	call   801507 <fd_alloc>
		return r;
  80274c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80274e:	85 c0                	test   %eax,%eax
  802750:	78 40                	js     802792 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802752:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802759:	00 
  80275a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80275d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802761:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802768:	e8 c6 e9 ff ff       	call   801133 <sys_page_alloc>
		return r;
  80276d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80276f:	85 c0                	test   %eax,%eax
  802771:	78 1f                	js     802792 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802773:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802779:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80277c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80277e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802781:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802788:	89 04 24             	mov    %eax,(%esp)
  80278b:	e8 50 ed ff ff       	call   8014e0 <fd2num>
  802790:	89 c2                	mov    %eax,%edx
}
  802792:	89 d0                	mov    %edx,%eax
  802794:	c9                   	leave  
  802795:	c3                   	ret    
  802796:	66 90                	xchg   %ax,%ax
  802798:	66 90                	xchg   %ax,%ax
  80279a:	66 90                	xchg   %ax,%ax
  80279c:	66 90                	xchg   %ax,%ax
  80279e:	66 90                	xchg   %ax,%ax

008027a0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8027a0:	55                   	push   %ebp
  8027a1:	89 e5                	mov    %esp,%ebp
  8027a3:	56                   	push   %esi
  8027a4:	53                   	push   %ebx
  8027a5:	83 ec 10             	sub    $0x10,%esp
  8027a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8027ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  8027b1:	85 c0                	test   %eax,%eax
  8027b3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8027b8:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  8027bb:	89 04 24             	mov    %eax,(%esp)
  8027be:	e8 86 eb ff ff       	call   801349 <sys_ipc_recv>

	if(ret < 0) {
  8027c3:	85 c0                	test   %eax,%eax
  8027c5:	79 16                	jns    8027dd <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  8027c7:	85 f6                	test   %esi,%esi
  8027c9:	74 06                	je     8027d1 <ipc_recv+0x31>
  8027cb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  8027d1:	85 db                	test   %ebx,%ebx
  8027d3:	74 3e                	je     802813 <ipc_recv+0x73>
  8027d5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8027db:	eb 36                	jmp    802813 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  8027dd:	e8 13 e9 ff ff       	call   8010f5 <sys_getenvid>
  8027e2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8027e7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8027ea:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8027ef:	a3 b4 50 80 00       	mov    %eax,0x8050b4

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8027f4:	85 f6                	test   %esi,%esi
  8027f6:	74 05                	je     8027fd <ipc_recv+0x5d>
  8027f8:	8b 40 74             	mov    0x74(%eax),%eax
  8027fb:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8027fd:	85 db                	test   %ebx,%ebx
  8027ff:	74 0a                	je     80280b <ipc_recv+0x6b>
  802801:	a1 b4 50 80 00       	mov    0x8050b4,%eax
  802806:	8b 40 78             	mov    0x78(%eax),%eax
  802809:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  80280b:	a1 b4 50 80 00       	mov    0x8050b4,%eax
  802810:	8b 40 70             	mov    0x70(%eax),%eax
}
  802813:	83 c4 10             	add    $0x10,%esp
  802816:	5b                   	pop    %ebx
  802817:	5e                   	pop    %esi
  802818:	5d                   	pop    %ebp
  802819:	c3                   	ret    

0080281a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80281a:	55                   	push   %ebp
  80281b:	89 e5                	mov    %esp,%ebp
  80281d:	57                   	push   %edi
  80281e:	56                   	push   %esi
  80281f:	53                   	push   %ebx
  802820:	83 ec 1c             	sub    $0x1c,%esp
  802823:	8b 7d 08             	mov    0x8(%ebp),%edi
  802826:	8b 75 0c             	mov    0xc(%ebp),%esi
  802829:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  80282c:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  80282e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802833:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  802836:	8b 45 14             	mov    0x14(%ebp),%eax
  802839:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80283d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802841:	89 74 24 04          	mov    %esi,0x4(%esp)
  802845:	89 3c 24             	mov    %edi,(%esp)
  802848:	e8 d9 ea ff ff       	call   801326 <sys_ipc_try_send>

		if(ret >= 0) break;
  80284d:	85 c0                	test   %eax,%eax
  80284f:	79 2c                	jns    80287d <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  802851:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802854:	74 20                	je     802876 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  802856:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80285a:	c7 44 24 08 34 31 80 	movl   $0x803134,0x8(%esp)
  802861:	00 
  802862:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  802869:	00 
  80286a:	c7 04 24 64 31 80 00 	movl   $0x803164,(%esp)
  802871:	e8 86 dd ff ff       	call   8005fc <_panic>
		}
		sys_yield();
  802876:	e8 99 e8 ff ff       	call   801114 <sys_yield>
	}
  80287b:	eb b9                	jmp    802836 <ipc_send+0x1c>
}
  80287d:	83 c4 1c             	add    $0x1c,%esp
  802880:	5b                   	pop    %ebx
  802881:	5e                   	pop    %esi
  802882:	5f                   	pop    %edi
  802883:	5d                   	pop    %ebp
  802884:	c3                   	ret    

00802885 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802885:	55                   	push   %ebp
  802886:	89 e5                	mov    %esp,%ebp
  802888:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80288b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802890:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802893:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802899:	8b 52 50             	mov    0x50(%edx),%edx
  80289c:	39 ca                	cmp    %ecx,%edx
  80289e:	75 0d                	jne    8028ad <ipc_find_env+0x28>
			return envs[i].env_id;
  8028a0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8028a3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8028a8:	8b 40 40             	mov    0x40(%eax),%eax
  8028ab:	eb 0e                	jmp    8028bb <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8028ad:	83 c0 01             	add    $0x1,%eax
  8028b0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8028b5:	75 d9                	jne    802890 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8028b7:	66 b8 00 00          	mov    $0x0,%ax
}
  8028bb:	5d                   	pop    %ebp
  8028bc:	c3                   	ret    

008028bd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8028bd:	55                   	push   %ebp
  8028be:	89 e5                	mov    %esp,%ebp
  8028c0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8028c3:	89 d0                	mov    %edx,%eax
  8028c5:	c1 e8 16             	shr    $0x16,%eax
  8028c8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8028cf:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8028d4:	f6 c1 01             	test   $0x1,%cl
  8028d7:	74 1d                	je     8028f6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8028d9:	c1 ea 0c             	shr    $0xc,%edx
  8028dc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8028e3:	f6 c2 01             	test   $0x1,%dl
  8028e6:	74 0e                	je     8028f6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8028e8:	c1 ea 0c             	shr    $0xc,%edx
  8028eb:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8028f2:	ef 
  8028f3:	0f b7 c0             	movzwl %ax,%eax
}
  8028f6:	5d                   	pop    %ebp
  8028f7:	c3                   	ret    
  8028f8:	66 90                	xchg   %ax,%ax
  8028fa:	66 90                	xchg   %ax,%ax
  8028fc:	66 90                	xchg   %ax,%ax
  8028fe:	66 90                	xchg   %ax,%ax

00802900 <__udivdi3>:
  802900:	55                   	push   %ebp
  802901:	57                   	push   %edi
  802902:	56                   	push   %esi
  802903:	83 ec 0c             	sub    $0xc,%esp
  802906:	8b 44 24 28          	mov    0x28(%esp),%eax
  80290a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80290e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802912:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802916:	85 c0                	test   %eax,%eax
  802918:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80291c:	89 ea                	mov    %ebp,%edx
  80291e:	89 0c 24             	mov    %ecx,(%esp)
  802921:	75 2d                	jne    802950 <__udivdi3+0x50>
  802923:	39 e9                	cmp    %ebp,%ecx
  802925:	77 61                	ja     802988 <__udivdi3+0x88>
  802927:	85 c9                	test   %ecx,%ecx
  802929:	89 ce                	mov    %ecx,%esi
  80292b:	75 0b                	jne    802938 <__udivdi3+0x38>
  80292d:	b8 01 00 00 00       	mov    $0x1,%eax
  802932:	31 d2                	xor    %edx,%edx
  802934:	f7 f1                	div    %ecx
  802936:	89 c6                	mov    %eax,%esi
  802938:	31 d2                	xor    %edx,%edx
  80293a:	89 e8                	mov    %ebp,%eax
  80293c:	f7 f6                	div    %esi
  80293e:	89 c5                	mov    %eax,%ebp
  802940:	89 f8                	mov    %edi,%eax
  802942:	f7 f6                	div    %esi
  802944:	89 ea                	mov    %ebp,%edx
  802946:	83 c4 0c             	add    $0xc,%esp
  802949:	5e                   	pop    %esi
  80294a:	5f                   	pop    %edi
  80294b:	5d                   	pop    %ebp
  80294c:	c3                   	ret    
  80294d:	8d 76 00             	lea    0x0(%esi),%esi
  802950:	39 e8                	cmp    %ebp,%eax
  802952:	77 24                	ja     802978 <__udivdi3+0x78>
  802954:	0f bd e8             	bsr    %eax,%ebp
  802957:	83 f5 1f             	xor    $0x1f,%ebp
  80295a:	75 3c                	jne    802998 <__udivdi3+0x98>
  80295c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802960:	39 34 24             	cmp    %esi,(%esp)
  802963:	0f 86 9f 00 00 00    	jbe    802a08 <__udivdi3+0x108>
  802969:	39 d0                	cmp    %edx,%eax
  80296b:	0f 82 97 00 00 00    	jb     802a08 <__udivdi3+0x108>
  802971:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802978:	31 d2                	xor    %edx,%edx
  80297a:	31 c0                	xor    %eax,%eax
  80297c:	83 c4 0c             	add    $0xc,%esp
  80297f:	5e                   	pop    %esi
  802980:	5f                   	pop    %edi
  802981:	5d                   	pop    %ebp
  802982:	c3                   	ret    
  802983:	90                   	nop
  802984:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802988:	89 f8                	mov    %edi,%eax
  80298a:	f7 f1                	div    %ecx
  80298c:	31 d2                	xor    %edx,%edx
  80298e:	83 c4 0c             	add    $0xc,%esp
  802991:	5e                   	pop    %esi
  802992:	5f                   	pop    %edi
  802993:	5d                   	pop    %ebp
  802994:	c3                   	ret    
  802995:	8d 76 00             	lea    0x0(%esi),%esi
  802998:	89 e9                	mov    %ebp,%ecx
  80299a:	8b 3c 24             	mov    (%esp),%edi
  80299d:	d3 e0                	shl    %cl,%eax
  80299f:	89 c6                	mov    %eax,%esi
  8029a1:	b8 20 00 00 00       	mov    $0x20,%eax
  8029a6:	29 e8                	sub    %ebp,%eax
  8029a8:	89 c1                	mov    %eax,%ecx
  8029aa:	d3 ef                	shr    %cl,%edi
  8029ac:	89 e9                	mov    %ebp,%ecx
  8029ae:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8029b2:	8b 3c 24             	mov    (%esp),%edi
  8029b5:	09 74 24 08          	or     %esi,0x8(%esp)
  8029b9:	89 d6                	mov    %edx,%esi
  8029bb:	d3 e7                	shl    %cl,%edi
  8029bd:	89 c1                	mov    %eax,%ecx
  8029bf:	89 3c 24             	mov    %edi,(%esp)
  8029c2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8029c6:	d3 ee                	shr    %cl,%esi
  8029c8:	89 e9                	mov    %ebp,%ecx
  8029ca:	d3 e2                	shl    %cl,%edx
  8029cc:	89 c1                	mov    %eax,%ecx
  8029ce:	d3 ef                	shr    %cl,%edi
  8029d0:	09 d7                	or     %edx,%edi
  8029d2:	89 f2                	mov    %esi,%edx
  8029d4:	89 f8                	mov    %edi,%eax
  8029d6:	f7 74 24 08          	divl   0x8(%esp)
  8029da:	89 d6                	mov    %edx,%esi
  8029dc:	89 c7                	mov    %eax,%edi
  8029de:	f7 24 24             	mull   (%esp)
  8029e1:	39 d6                	cmp    %edx,%esi
  8029e3:	89 14 24             	mov    %edx,(%esp)
  8029e6:	72 30                	jb     802a18 <__udivdi3+0x118>
  8029e8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8029ec:	89 e9                	mov    %ebp,%ecx
  8029ee:	d3 e2                	shl    %cl,%edx
  8029f0:	39 c2                	cmp    %eax,%edx
  8029f2:	73 05                	jae    8029f9 <__udivdi3+0xf9>
  8029f4:	3b 34 24             	cmp    (%esp),%esi
  8029f7:	74 1f                	je     802a18 <__udivdi3+0x118>
  8029f9:	89 f8                	mov    %edi,%eax
  8029fb:	31 d2                	xor    %edx,%edx
  8029fd:	e9 7a ff ff ff       	jmp    80297c <__udivdi3+0x7c>
  802a02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802a08:	31 d2                	xor    %edx,%edx
  802a0a:	b8 01 00 00 00       	mov    $0x1,%eax
  802a0f:	e9 68 ff ff ff       	jmp    80297c <__udivdi3+0x7c>
  802a14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a18:	8d 47 ff             	lea    -0x1(%edi),%eax
  802a1b:	31 d2                	xor    %edx,%edx
  802a1d:	83 c4 0c             	add    $0xc,%esp
  802a20:	5e                   	pop    %esi
  802a21:	5f                   	pop    %edi
  802a22:	5d                   	pop    %ebp
  802a23:	c3                   	ret    
  802a24:	66 90                	xchg   %ax,%ax
  802a26:	66 90                	xchg   %ax,%ax
  802a28:	66 90                	xchg   %ax,%ax
  802a2a:	66 90                	xchg   %ax,%ax
  802a2c:	66 90                	xchg   %ax,%ax
  802a2e:	66 90                	xchg   %ax,%ax

00802a30 <__umoddi3>:
  802a30:	55                   	push   %ebp
  802a31:	57                   	push   %edi
  802a32:	56                   	push   %esi
  802a33:	83 ec 14             	sub    $0x14,%esp
  802a36:	8b 44 24 28          	mov    0x28(%esp),%eax
  802a3a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802a3e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802a42:	89 c7                	mov    %eax,%edi
  802a44:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a48:	8b 44 24 30          	mov    0x30(%esp),%eax
  802a4c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802a50:	89 34 24             	mov    %esi,(%esp)
  802a53:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a57:	85 c0                	test   %eax,%eax
  802a59:	89 c2                	mov    %eax,%edx
  802a5b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802a5f:	75 17                	jne    802a78 <__umoddi3+0x48>
  802a61:	39 fe                	cmp    %edi,%esi
  802a63:	76 4b                	jbe    802ab0 <__umoddi3+0x80>
  802a65:	89 c8                	mov    %ecx,%eax
  802a67:	89 fa                	mov    %edi,%edx
  802a69:	f7 f6                	div    %esi
  802a6b:	89 d0                	mov    %edx,%eax
  802a6d:	31 d2                	xor    %edx,%edx
  802a6f:	83 c4 14             	add    $0x14,%esp
  802a72:	5e                   	pop    %esi
  802a73:	5f                   	pop    %edi
  802a74:	5d                   	pop    %ebp
  802a75:	c3                   	ret    
  802a76:	66 90                	xchg   %ax,%ax
  802a78:	39 f8                	cmp    %edi,%eax
  802a7a:	77 54                	ja     802ad0 <__umoddi3+0xa0>
  802a7c:	0f bd e8             	bsr    %eax,%ebp
  802a7f:	83 f5 1f             	xor    $0x1f,%ebp
  802a82:	75 5c                	jne    802ae0 <__umoddi3+0xb0>
  802a84:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802a88:	39 3c 24             	cmp    %edi,(%esp)
  802a8b:	0f 87 e7 00 00 00    	ja     802b78 <__umoddi3+0x148>
  802a91:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802a95:	29 f1                	sub    %esi,%ecx
  802a97:	19 c7                	sbb    %eax,%edi
  802a99:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a9d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802aa1:	8b 44 24 08          	mov    0x8(%esp),%eax
  802aa5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802aa9:	83 c4 14             	add    $0x14,%esp
  802aac:	5e                   	pop    %esi
  802aad:	5f                   	pop    %edi
  802aae:	5d                   	pop    %ebp
  802aaf:	c3                   	ret    
  802ab0:	85 f6                	test   %esi,%esi
  802ab2:	89 f5                	mov    %esi,%ebp
  802ab4:	75 0b                	jne    802ac1 <__umoddi3+0x91>
  802ab6:	b8 01 00 00 00       	mov    $0x1,%eax
  802abb:	31 d2                	xor    %edx,%edx
  802abd:	f7 f6                	div    %esi
  802abf:	89 c5                	mov    %eax,%ebp
  802ac1:	8b 44 24 04          	mov    0x4(%esp),%eax
  802ac5:	31 d2                	xor    %edx,%edx
  802ac7:	f7 f5                	div    %ebp
  802ac9:	89 c8                	mov    %ecx,%eax
  802acb:	f7 f5                	div    %ebp
  802acd:	eb 9c                	jmp    802a6b <__umoddi3+0x3b>
  802acf:	90                   	nop
  802ad0:	89 c8                	mov    %ecx,%eax
  802ad2:	89 fa                	mov    %edi,%edx
  802ad4:	83 c4 14             	add    $0x14,%esp
  802ad7:	5e                   	pop    %esi
  802ad8:	5f                   	pop    %edi
  802ad9:	5d                   	pop    %ebp
  802ada:	c3                   	ret    
  802adb:	90                   	nop
  802adc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ae0:	8b 04 24             	mov    (%esp),%eax
  802ae3:	be 20 00 00 00       	mov    $0x20,%esi
  802ae8:	89 e9                	mov    %ebp,%ecx
  802aea:	29 ee                	sub    %ebp,%esi
  802aec:	d3 e2                	shl    %cl,%edx
  802aee:	89 f1                	mov    %esi,%ecx
  802af0:	d3 e8                	shr    %cl,%eax
  802af2:	89 e9                	mov    %ebp,%ecx
  802af4:	89 44 24 04          	mov    %eax,0x4(%esp)
  802af8:	8b 04 24             	mov    (%esp),%eax
  802afb:	09 54 24 04          	or     %edx,0x4(%esp)
  802aff:	89 fa                	mov    %edi,%edx
  802b01:	d3 e0                	shl    %cl,%eax
  802b03:	89 f1                	mov    %esi,%ecx
  802b05:	89 44 24 08          	mov    %eax,0x8(%esp)
  802b09:	8b 44 24 10          	mov    0x10(%esp),%eax
  802b0d:	d3 ea                	shr    %cl,%edx
  802b0f:	89 e9                	mov    %ebp,%ecx
  802b11:	d3 e7                	shl    %cl,%edi
  802b13:	89 f1                	mov    %esi,%ecx
  802b15:	d3 e8                	shr    %cl,%eax
  802b17:	89 e9                	mov    %ebp,%ecx
  802b19:	09 f8                	or     %edi,%eax
  802b1b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  802b1f:	f7 74 24 04          	divl   0x4(%esp)
  802b23:	d3 e7                	shl    %cl,%edi
  802b25:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802b29:	89 d7                	mov    %edx,%edi
  802b2b:	f7 64 24 08          	mull   0x8(%esp)
  802b2f:	39 d7                	cmp    %edx,%edi
  802b31:	89 c1                	mov    %eax,%ecx
  802b33:	89 14 24             	mov    %edx,(%esp)
  802b36:	72 2c                	jb     802b64 <__umoddi3+0x134>
  802b38:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  802b3c:	72 22                	jb     802b60 <__umoddi3+0x130>
  802b3e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802b42:	29 c8                	sub    %ecx,%eax
  802b44:	19 d7                	sbb    %edx,%edi
  802b46:	89 e9                	mov    %ebp,%ecx
  802b48:	89 fa                	mov    %edi,%edx
  802b4a:	d3 e8                	shr    %cl,%eax
  802b4c:	89 f1                	mov    %esi,%ecx
  802b4e:	d3 e2                	shl    %cl,%edx
  802b50:	89 e9                	mov    %ebp,%ecx
  802b52:	d3 ef                	shr    %cl,%edi
  802b54:	09 d0                	or     %edx,%eax
  802b56:	89 fa                	mov    %edi,%edx
  802b58:	83 c4 14             	add    $0x14,%esp
  802b5b:	5e                   	pop    %esi
  802b5c:	5f                   	pop    %edi
  802b5d:	5d                   	pop    %ebp
  802b5e:	c3                   	ret    
  802b5f:	90                   	nop
  802b60:	39 d7                	cmp    %edx,%edi
  802b62:	75 da                	jne    802b3e <__umoddi3+0x10e>
  802b64:	8b 14 24             	mov    (%esp),%edx
  802b67:	89 c1                	mov    %eax,%ecx
  802b69:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  802b6d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802b71:	eb cb                	jmp    802b3e <__umoddi3+0x10e>
  802b73:	90                   	nop
  802b74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b78:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  802b7c:	0f 82 0f ff ff ff    	jb     802a91 <__umoddi3+0x61>
  802b82:	e9 1a ff ff ff       	jmp    802aa1 <__umoddi3+0x71>
