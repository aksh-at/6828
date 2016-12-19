
obj/user/httpd.debug:     file format elf32-i386


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
  80002c:	e8 7c 08 00 00       	call   8008ad <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <die>:
	{404, "Not Found"},
};

static void
die(char *m)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
	cprintf("%s\n", m);
  800046:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004a:	c7 04 24 e0 30 80 00 	movl   $0x8030e0,(%esp)
  800051:	e8 b1 09 00 00       	call   800a07 <cprintf>
	exit();
  800056:	e8 9a 08 00 00       	call   8008f5 <exit>
}
  80005b:	c9                   	leave  
  80005c:	c3                   	ret    

0080005d <send_error>:
	return 0;
}

static int
send_error(struct http_request *req, int code)
{
  80005d:	55                   	push   %ebp
  80005e:	89 e5                	mov    %esp,%ebp
  800060:	57                   	push   %edi
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	81 ec 2c 02 00 00    	sub    $0x22c,%esp
  800069:	89 c6                	mov    %eax,%esi
	char buf[512];
	int r;

	struct error_messages *e = errors;
  80006b:	b9 00 40 80 00       	mov    $0x804000,%ecx
	while (e->code != 0 && e->msg != 0) {
  800070:	eb 07                	jmp    800079 <send_error+0x1c>
		if (e->code == code)
  800072:	39 d3                	cmp    %edx,%ebx
  800074:	74 11                	je     800087 <send_error+0x2a>
			break;
		e++;
  800076:	83 c1 08             	add    $0x8,%ecx
{
	char buf[512];
	int r;

	struct error_messages *e = errors;
	while (e->code != 0 && e->msg != 0) {
  800079:	8b 19                	mov    (%ecx),%ebx
  80007b:	85 db                	test   %ebx,%ebx
  80007d:	74 5d                	je     8000dc <send_error+0x7f>
  80007f:	83 79 04 00          	cmpl   $0x0,0x4(%ecx)
  800083:	75 ed                	jne    800072 <send_error+0x15>
  800085:	eb 04                	jmp    80008b <send_error+0x2e>
		if (e->code == code)
			break;
		e++;
	}

	if (e->code == 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	74 58                	je     8000e3 <send_error+0x86>
		return -1;

	r = snprintf(buf, 512, "HTTP/" HTTP_VERSION" %d %s\r\n"
  80008b:	8b 41 04             	mov    0x4(%ecx),%eax
  80008e:	89 44 24 18          	mov    %eax,0x18(%esp)
  800092:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800096:	89 44 24 10          	mov    %eax,0x10(%esp)
  80009a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009e:	c7 44 24 08 9c 31 80 	movl   $0x80319c,0x8(%esp)
  8000a5:	00 
  8000a6:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
  8000ad:	00 
  8000ae:	8d bd e8 fd ff ff    	lea    -0x218(%ebp),%edi
  8000b4:	89 3c 24             	mov    %edi,(%esp)
  8000b7:	e8 0e 0f 00 00       	call   800fca <snprintf>
  8000bc:	89 c3                	mov    %eax,%ebx
			       "Content-type: text/html\r\n"
			       "\r\n"
			       "<html><body><p>%d - %s</p></body></html>\r\n",
			       e->code, e->msg, e->code, e->msg);

	if (write(req->sock, buf, r) != r)
  8000be:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8000c6:	8b 06                	mov    (%esi),%eax
  8000c8:	89 04 24             	mov    %eax,(%esp)
  8000cb:	e8 97 1a 00 00       	call   801b67 <write>
  8000d0:	39 c3                	cmp    %eax,%ebx
  8000d2:	0f 95 c0             	setne  %al
  8000d5:	0f b6 c0             	movzbl %al,%eax
  8000d8:	f7 d8                	neg    %eax
  8000da:	eb 0c                	jmp    8000e8 <send_error+0x8b>
			break;
		e++;
	}

	if (e->code == 0)
		return -1;
  8000dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8000e1:	eb 05                	jmp    8000e8 <send_error+0x8b>
  8000e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	if (write(req->sock, buf, r) != r)
		return -1;

	return 0;
}
  8000e8:	81 c4 2c 02 00 00    	add    $0x22c,%esp
  8000ee:	5b                   	pop    %ebx
  8000ef:	5e                   	pop    %esi
  8000f0:	5f                   	pop    %edi
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <handle_client>:
	return r;
}

static void
handle_client(int sock)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	57                   	push   %edi
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	81 ec 4c 03 00 00    	sub    $0x34c,%esp
  8000ff:	89 c6                	mov    %eax,%esi
	struct http_request *req = &con_d;

	while (1)
	{
		// Receive message
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  800101:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800108:	00 
  800109:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
  80010f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800113:	89 34 24             	mov    %esi,(%esp)
  800116:	e8 6f 19 00 00       	call   801a8a <read>
  80011b:	85 c0                	test   %eax,%eax
  80011d:	79 1c                	jns    80013b <handle_client+0x48>
			panic("failed to read");
  80011f:	c7 44 24 08 e4 30 80 	movl   $0x8030e4,0x8(%esp)
  800126:	00 
  800127:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
  80012e:	00 
  80012f:	c7 04 24 f3 30 80 00 	movl   $0x8030f3,(%esp)
  800136:	e8 d3 07 00 00       	call   80090e <_panic>

		memset(req, 0, sizeof(*req));
  80013b:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
  800142:	00 
  800143:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80014a:	00 
  80014b:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80014e:	89 04 24             	mov    %eax,(%esp)
  800151:	e8 31 10 00 00       	call   801187 <memset>

		req->sock = sock;
  800156:	89 75 dc             	mov    %esi,-0x24(%ebp)
	int url_len, version_len;

	if (!req)
		return -1;

	if (strncmp(request, "GET ", 4) != 0)
  800159:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800160:	00 
  800161:	c7 44 24 04 00 31 80 	movl   $0x803100,0x4(%esp)
  800168:	00 
  800169:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
  80016f:	89 04 24             	mov    %eax,(%esp)
  800172:	e8 9b 0f 00 00       	call   801112 <strncmp>
  800177:	85 c0                	test   %eax,%eax
  800179:	0f 85 b6 02 00 00    	jne    800435 <handle_client+0x342>
		return -E_BAD_REQ;

	// skip GET
	request += 4;
  80017f:	8d 9d e0 fd ff ff    	lea    -0x220(%ebp),%ebx
  800185:	eb 03                	jmp    80018a <handle_client+0x97>

	// get the url
	url = request;
	while (*request && *request != ' ')
		request++;
  800187:	83 c3 01             	add    $0x1,%ebx
	// skip GET
	request += 4;

	// get the url
	url = request;
	while (*request && *request != ' ')
  80018a:	f6 03 df             	testb  $0xdf,(%ebx)
  80018d:	75 f8                	jne    800187 <handle_client+0x94>
		request++;
	url_len = request - url;
  80018f:	89 df                	mov    %ebx,%edi
  800191:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
  800197:	29 c7                	sub    %eax,%edi

	req->url = malloc(url_len + 1);
  800199:	8d 47 01             	lea    0x1(%edi),%eax
  80019c:	89 04 24             	mov    %eax,(%esp)
  80019f:	e8 3e 24 00 00       	call   8025e2 <malloc>
  8001a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
	memmove(req->url, url, url_len);
  8001a7:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8001ab:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  8001b1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8001b5:	89 04 24             	mov    %eax,(%esp)
  8001b8:	e8 17 10 00 00       	call   8011d4 <memmove>
	req->url[url_len] = '\0';
  8001bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001c0:	c6 04 38 00          	movb   $0x0,(%eax,%edi,1)

	// skip space
	request++;
  8001c4:	83 c3 01             	add    $0x1,%ebx
  8001c7:	89 d8                	mov    %ebx,%eax
  8001c9:	eb 03                	jmp    8001ce <handle_client+0xdb>

	version = request;
	while (*request && *request != '\n')
		request++;
  8001cb:	83 c0 01             	add    $0x1,%eax

	// skip space
	request++;

	version = request;
	while (*request && *request != '\n')
  8001ce:	0f b6 10             	movzbl (%eax),%edx
  8001d1:	80 fa 0a             	cmp    $0xa,%dl
  8001d4:	74 04                	je     8001da <handle_client+0xe7>
  8001d6:	84 d2                	test   %dl,%dl
  8001d8:	75 f1                	jne    8001cb <handle_client+0xd8>
		request++;
	version_len = request - version;
  8001da:	29 d8                	sub    %ebx,%eax
  8001dc:	89 c7                	mov    %eax,%edi

	req->version = malloc(version_len + 1);
  8001de:	8d 40 01             	lea    0x1(%eax),%eax
  8001e1:	89 04 24             	mov    %eax,(%esp)
  8001e4:	e8 f9 23 00 00       	call   8025e2 <malloc>
  8001e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	memmove(req->version, version, version_len);
  8001ec:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8001f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001f4:	89 04 24             	mov    %eax,(%esp)
  8001f7:	e8 d8 0f 00 00       	call   8011d4 <memmove>
	req->version[version_len] = '\0';
  8001fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001ff:	c6 04 38 00          	movb   $0x0,(%eax,%edi,1)
}

static int
send_file(struct http_request *req)
{
	cprintf("sending file\n");
  800203:	c7 04 24 05 31 80 00 	movl   $0x803105,(%esp)
  80020a:	e8 f8 07 00 00       	call   800a07 <cprintf>
	// if the file does not exist, send a 404 error using send_error
	// if the file is a directory, send a 404 error using send_error
	// set file_size to the size of the file

	// LAB 6: Your code here.
	if((fd = open(req->url, O_RDONLY)) < 0) {
  80020f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800216:	00 
  800217:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80021a:	89 04 24             	mov    %eax,(%esp)
  80021d:	e8 41 1d 00 00       	call   801f63 <open>
  800222:	89 c3                	mov    %eax,%ebx
  800224:	85 c0                	test   %eax,%eax
  800226:	79 12                	jns    80023a <handle_client+0x147>
		send_error(req, 404);
  800228:	ba 94 01 00 00       	mov    $0x194,%edx
  80022d:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800230:	e8 28 fe ff ff       	call   80005d <send_error>
  800235:	e9 db 01 00 00       	jmp    800415 <handle_client+0x322>
		return -1;
	}

	if((r = fstat(fd, &stat)) < 0) {
  80023a:	8d 85 50 fd ff ff    	lea    -0x2b0(%ebp),%eax
  800240:	89 44 24 04          	mov    %eax,0x4(%esp)
  800244:	89 1c 24             	mov    %ebx,(%esp)
  800247:	e8 5a 1a 00 00       	call   801ca6 <fstat>
  80024c:	85 c0                	test   %eax,%eax
  80024e:	79 12                	jns    800262 <handle_client+0x16f>
		send_error(req, 404);
  800250:	ba 94 01 00 00       	mov    $0x194,%edx
  800255:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800258:	e8 00 fe ff ff       	call   80005d <send_error>
  80025d:	e9 ab 01 00 00       	jmp    80040d <handle_client+0x31a>
		goto end;
	}

	if(stat.st_isdir) {
  800262:	83 bd d4 fd ff ff 00 	cmpl   $0x0,-0x22c(%ebp)
  800269:	74 12                	je     80027d <handle_client+0x18a>
		send_error(req, 404);
  80026b:	ba 94 01 00 00       	mov    $0x194,%edx
  800270:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800273:	e8 e5 fd ff ff       	call   80005d <send_error>
  800278:	e9 90 01 00 00       	jmp    80040d <handle_client+0x31a>
		goto end;
	}

	file_size = stat.st_size;
  80027d:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
  800283:	89 85 c4 fc ff ff    	mov    %eax,-0x33c(%ebp)
}

static int
send_header(struct http_request *req, int code)
{
	struct responce_header *h = headers;
  800289:	bf 10 40 80 00       	mov    $0x804010,%edi
  80028e:	eb 0a                	jmp    80029a <handle_client+0x1a7>
	while (h->code != 0 && h->header!= 0) {
		if (h->code == code)
  800290:	3d c8 00 00 00       	cmp    $0xc8,%eax
  800295:	74 13                	je     8002aa <handle_client+0x1b7>
			break;
		h++;
  800297:	83 c7 08             	add    $0x8,%edi

static int
send_header(struct http_request *req, int code)
{
	struct responce_header *h = headers;
	while (h->code != 0 && h->header!= 0) {
  80029a:	8b 07                	mov    (%edi),%eax
  80029c:	85 c0                	test   %eax,%eax
  80029e:	0f 84 69 01 00 00    	je     80040d <handle_client+0x31a>
  8002a4:	83 7f 04 00          	cmpl   $0x0,0x4(%edi)
  8002a8:	75 e6                	jne    800290 <handle_client+0x19d>
	}

	if (h->code == 0)
		return -1;

	int len = strlen(h->header);
  8002aa:	8b 47 04             	mov    0x4(%edi),%eax
  8002ad:	89 04 24             	mov    %eax,(%esp)
  8002b0:	e8 4b 0d 00 00       	call   801000 <strlen>
	if (write(req->sock, h->header, len) != len) {
  8002b5:	89 85 c0 fc ff ff    	mov    %eax,-0x340(%ebp)
  8002bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002bf:	8b 47 04             	mov    0x4(%edi),%eax
  8002c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002c9:	89 04 24             	mov    %eax,(%esp)
  8002cc:	e8 96 18 00 00       	call   801b67 <write>
  8002d1:	39 85 c0 fc ff ff    	cmp    %eax,-0x340(%ebp)
  8002d7:	0f 84 67 01 00 00    	je     800444 <handle_client+0x351>
		die("Failed to send bytes to client");
  8002dd:	b8 18 32 80 00       	mov    $0x803218,%eax
  8002e2:	e8 59 fd ff ff       	call   800040 <die>
  8002e7:	e9 58 01 00 00       	jmp    800444 <handle_client+0x351>
	char buf[64];
	int r;

	r = snprintf(buf, 64, "Content-Length: %ld\r\n", (long)size);
	if (r > 63)
		panic("buffer too small!");
  8002ec:	c7 44 24 08 13 31 80 	movl   $0x803113,0x8(%esp)
  8002f3:	00 
  8002f4:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8002fb:	00 
  8002fc:	c7 04 24 f3 30 80 00 	movl   $0x8030f3,(%esp)
  800303:	e8 06 06 00 00       	call   80090e <_panic>

	if (write(req->sock, buf, r) != r)
  800308:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80030c:	8d 85 d0 fc ff ff    	lea    -0x330(%ebp),%eax
  800312:	89 44 24 04          	mov    %eax,0x4(%esp)
  800316:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800319:	89 04 24             	mov    %eax,(%esp)
  80031c:	e8 46 18 00 00       	call   801b67 <write>
	file_size = stat.st_size;

	if ((r = send_header(req, 200)) < 0)
		goto end;

	if ((r = send_size(req, file_size)) < 0)
  800321:	39 c7                	cmp    %eax,%edi
  800323:	0f 85 e4 00 00 00    	jne    80040d <handle_client+0x31a>

	type = mime_type(req->url);
	if (!type)
		return -1;

	r = snprintf(buf, 128, "Content-Type: %s\r\n", type);
  800329:	c7 44 24 0c 25 31 80 	movl   $0x803125,0xc(%esp)
  800330:	00 
  800331:	c7 44 24 08 2f 31 80 	movl   $0x80312f,0x8(%esp)
  800338:	00 
  800339:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  800340:	00 
  800341:	8d 85 d0 fc ff ff    	lea    -0x330(%ebp),%eax
  800347:	89 04 24             	mov    %eax,(%esp)
  80034a:	e8 7b 0c 00 00       	call   800fca <snprintf>
  80034f:	89 c7                	mov    %eax,%edi
	if (r > 127)
  800351:	83 f8 7f             	cmp    $0x7f,%eax
  800354:	7e 1c                	jle    800372 <handle_client+0x27f>
		panic("buffer too small!");
  800356:	c7 44 24 08 13 31 80 	movl   $0x803113,0x8(%esp)
  80035d:	00 
  80035e:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  800365:	00 
  800366:	c7 04 24 f3 30 80 00 	movl   $0x8030f3,(%esp)
  80036d:	e8 9c 05 00 00       	call   80090e <_panic>

	if (write(req->sock, buf, r) != r)
  800372:	89 44 24 08          	mov    %eax,0x8(%esp)
  800376:	8d 85 d0 fc ff ff    	lea    -0x330(%ebp),%eax
  80037c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800380:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800383:	89 04 24             	mov    %eax,(%esp)
  800386:	e8 dc 17 00 00       	call   801b67 <write>
		goto end;

	if ((r = send_size(req, file_size)) < 0)
		goto end;

	if ((r = send_content_type(req)) < 0)
  80038b:	39 c7                	cmp    %eax,%edi
  80038d:	75 7e                	jne    80040d <handle_client+0x31a>

static int
send_header_fin(struct http_request *req)
{
	const char *fin = "\r\n";
	int fin_len = strlen(fin);
  80038f:	c7 04 24 63 31 80 00 	movl   $0x803163,(%esp)
  800396:	e8 65 0c 00 00       	call   801000 <strlen>
  80039b:	89 c7                	mov    %eax,%edi

	if (write(req->sock, fin, fin_len) != fin_len)
  80039d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a1:	c7 44 24 04 63 31 80 	movl   $0x803163,0x4(%esp)
  8003a8:	00 
  8003a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003ac:	89 04 24             	mov    %eax,(%esp)
  8003af:	e8 b3 17 00 00       	call   801b67 <write>
		goto end;

	if ((r = send_content_type(req)) < 0)
		goto end;

	if ((r = send_header_fin(req)) < 0)
  8003b4:	39 c7                	cmp    %eax,%edi
  8003b6:	75 55                	jne    80040d <handle_client+0x31a>
static int
send_data(struct http_request *req, int fd)
{
	// LAB 6: Your code here.
	//read a page at a time
	cprintf("sending data\n");
  8003b8:	c7 04 24 42 31 80 00 	movl   $0x803142,(%esp)
  8003bf:	e8 43 06 00 00       	call   800a07 <cprintf>
  8003c4:	eb 27                	jmp    8003ed <handle_client+0x2fa>
	char buf[128];
	int r;
	while ((r = read(fd, (void*)buf, 128)) > 0) {
		if (write(req->sock, buf, r) != r) {
  8003c6:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8003ca:	8d 85 d0 fc ff ff    	lea    -0x330(%ebp),%eax
  8003d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003d7:	89 04 24             	mov    %eax,(%esp)
  8003da:	e8 88 17 00 00       	call   801b67 <write>
  8003df:	39 c7                	cmp    %eax,%edi
  8003e1:	74 0a                	je     8003ed <handle_client+0x2fa>
			die("Failed to send bytes to client");
  8003e3:	b8 18 32 80 00       	mov    $0x803218,%eax
  8003e8:	e8 53 fc ff ff       	call   800040 <die>
	// LAB 6: Your code here.
	//read a page at a time
	cprintf("sending data\n");
	char buf[128];
	int r;
	while ((r = read(fd, (void*)buf, 128)) > 0) {
  8003ed:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
  8003f4:	00 
  8003f5:	8d 85 d0 fc ff ff    	lea    -0x330(%ebp),%eax
  8003fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ff:	89 1c 24             	mov    %ebx,(%esp)
  800402:	e8 83 16 00 00       	call   801a8a <read>
  800407:	89 c7                	mov    %eax,%edi
  800409:	85 c0                	test   %eax,%eax
  80040b:	7f b9                	jg     8003c6 <handle_client+0x2d3>
		goto end;

	r = send_data(req, fd);

end:
	close(fd);
  80040d:	89 1c 24             	mov    %ebx,(%esp)
  800410:	e8 12 15 00 00       	call   801927 <close>
}

static void
req_free(struct http_request *req)
{
	free(req->url);
  800415:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800418:	89 04 24             	mov    %eax,(%esp)
  80041b:	e8 f0 20 00 00       	call   802510 <free>
	free(req->version);
  800420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800423:	89 04 24             	mov    %eax,(%esp)
  800426:	e8 e5 20 00 00       	call   802510 <free>

		// no keep alive
		break;
	}

	close(sock);
  80042b:	89 34 24             	mov    %esi,(%esp)
  80042e:	e8 f4 14 00 00       	call   801927 <close>
  800433:	eb 47                	jmp    80047c <handle_client+0x389>

		req->sock = sock;

		r = http_request_parse(req, buffer);
		if (r == -E_BAD_REQ)
			send_error(req, 400);
  800435:	ba 90 01 00 00       	mov    $0x190,%edx
  80043a:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80043d:	e8 1b fc ff ff       	call   80005d <send_error>
  800442:	eb d1                	jmp    800415 <handle_client+0x322>
send_size(struct http_request *req, off_t size)
{
	char buf[64];
	int r;

	r = snprintf(buf, 64, "Content-Length: %ld\r\n", (long)size);
  800444:	8b 85 c4 fc ff ff    	mov    -0x33c(%ebp),%eax
  80044a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80044e:	c7 44 24 08 50 31 80 	movl   $0x803150,0x8(%esp)
  800455:	00 
  800456:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  80045d:	00 
  80045e:	8d 85 d0 fc ff ff    	lea    -0x330(%ebp),%eax
  800464:	89 04 24             	mov    %eax,(%esp)
  800467:	e8 5e 0b 00 00       	call   800fca <snprintf>
  80046c:	89 c7                	mov    %eax,%edi
	if (r > 63)
  80046e:	83 f8 3f             	cmp    $0x3f,%eax
  800471:	0f 8e 91 fe ff ff    	jle    800308 <handle_client+0x215>
  800477:	e9 70 fe ff ff       	jmp    8002ec <handle_client+0x1f9>
		// no keep alive
		break;
	}

	close(sock);
}
  80047c:	81 c4 4c 03 00 00    	add    $0x34c,%esp
  800482:	5b                   	pop    %ebx
  800483:	5e                   	pop    %esi
  800484:	5f                   	pop    %edi
  800485:	5d                   	pop    %ebp
  800486:	c3                   	ret    

00800487 <umain>:

void
umain(int argc, char **argv)
{
  800487:	55                   	push   %ebp
  800488:	89 e5                	mov    %esp,%ebp
  80048a:	57                   	push   %edi
  80048b:	56                   	push   %esi
  80048c:	53                   	push   %ebx
  80048d:	83 ec 4c             	sub    $0x4c,%esp
	int serversock, clientsock;
	struct sockaddr_in server, client;

	binaryname = "jhttpd";
  800490:	c7 05 20 40 80 00 66 	movl   $0x803166,0x804020
  800497:	31 80 00 

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  80049a:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  8004a1:	00 
  8004a2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8004a9:	00 
  8004aa:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8004b1:	e8 71 1d 00 00       	call   802227 <socket>
  8004b6:	89 c6                	mov    %eax,%esi
  8004b8:	85 c0                	test   %eax,%eax
  8004ba:	79 0a                	jns    8004c6 <umain+0x3f>
		die("Failed to create socket");
  8004bc:	b8 6d 31 80 00       	mov    $0x80316d,%eax
  8004c1:	e8 7a fb ff ff       	call   800040 <die>

	// Construct the server sockaddr_in structure
	memset(&server, 0, sizeof(server));		// Clear struct
  8004c6:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  8004cd:	00 
  8004ce:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004d5:	00 
  8004d6:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  8004d9:	89 1c 24             	mov    %ebx,(%esp)
  8004dc:	e8 a6 0c 00 00       	call   801187 <memset>
	server.sin_family = AF_INET;			// Internet/IP
  8004e1:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	server.sin_addr.s_addr = htonl(INADDR_ANY);	// IP address
  8004e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8004ec:	e8 6f 01 00 00       	call   800660 <htonl>
  8004f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
	server.sin_port = htons(PORT);			// server port
  8004f4:	c7 04 24 50 00 00 00 	movl   $0x50,(%esp)
  8004fb:	e8 46 01 00 00       	call   800646 <htons>
  800500:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &server,
  800504:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  80050b:	00 
  80050c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800510:	89 34 24             	mov    %esi,(%esp)
  800513:	e8 6d 1c 00 00       	call   802185 <bind>
  800518:	85 c0                	test   %eax,%eax
  80051a:	79 0a                	jns    800526 <umain+0x9f>
		 sizeof(server)) < 0)
	{
		die("Failed to bind the server socket");
  80051c:	b8 38 32 80 00       	mov    $0x803238,%eax
  800521:	e8 1a fb ff ff       	call   800040 <die>
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  800526:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  80052d:	00 
  80052e:	89 34 24             	mov    %esi,(%esp)
  800531:	e8 cc 1c 00 00       	call   802202 <listen>
  800536:	85 c0                	test   %eax,%eax
  800538:	79 0a                	jns    800544 <umain+0xbd>
		die("Failed to listen on server socket");
  80053a:	b8 5c 32 80 00       	mov    $0x80325c,%eax
  80053f:	e8 fc fa ff ff       	call   800040 <die>

	cprintf("Waiting for http connections...\n");
  800544:	c7 04 24 80 32 80 00 	movl   $0x803280,(%esp)
  80054b:	e8 b7 04 00 00       	call   800a07 <cprintf>

	while (1) {
		unsigned int clientlen = sizeof(client);
		// Wait for client connection
		if ((clientsock = accept(serversock,
  800550:	8d 7d c4             	lea    -0x3c(%ebp),%edi
		die("Failed to listen on server socket");

	cprintf("Waiting for http connections...\n");

	while (1) {
		unsigned int clientlen = sizeof(client);
  800553:	c7 45 c4 10 00 00 00 	movl   $0x10,-0x3c(%ebp)
		// Wait for client connection
		if ((clientsock = accept(serversock,
  80055a:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80055e:	8d 45 c8             	lea    -0x38(%ebp),%eax
  800561:	89 44 24 04          	mov    %eax,0x4(%esp)
  800565:	89 34 24             	mov    %esi,(%esp)
  800568:	e8 dd 1b 00 00       	call   80214a <accept>
  80056d:	89 c3                	mov    %eax,%ebx
  80056f:	85 c0                	test   %eax,%eax
  800571:	79 0a                	jns    80057d <umain+0xf6>
					 (struct sockaddr *) &client,
					 &clientlen)) < 0)
		{
			die("Failed to accept client connection");
  800573:	b8 a4 32 80 00       	mov    $0x8032a4,%eax
  800578:	e8 c3 fa ff ff       	call   800040 <die>
		}
		handle_client(clientsock);
  80057d:	89 d8                	mov    %ebx,%eax
  80057f:	e8 6f fb ff ff       	call   8000f3 <handle_client>
	}
  800584:	eb cd                	jmp    800553 <umain+0xcc>
  800586:	66 90                	xchg   %ax,%ax
  800588:	66 90                	xchg   %ax,%ax
  80058a:	66 90                	xchg   %ax,%ax
  80058c:	66 90                	xchg   %ax,%ax
  80058e:	66 90                	xchg   %ax,%ax

00800590 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  800590:	55                   	push   %ebp
  800591:	89 e5                	mov    %esp,%ebp
  800593:	57                   	push   %edi
  800594:	56                   	push   %esi
  800595:	53                   	push   %ebx
  800596:	83 ec 19             	sub    $0x19,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  800599:	8b 45 08             	mov    0x8(%ebp),%eax
  80059c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  80059f:	c6 45 db 00          	movb   $0x0,-0x25(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  8005a3:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  8005a6:	c7 45 dc 00 50 80 00 	movl   $0x805000,-0x24(%ebp)
 */
char *
inet_ntoa(struct in_addr addr)
{
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8005ad:	be 00 00 00 00       	mov    $0x0,%esi
  8005b2:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  8005b5:	eb 02                	jmp    8005b9 <inet_ntoa+0x29>
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
  8005b7:	89 ce                	mov    %ecx,%esi
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  8005b9:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005bc:	0f b6 17             	movzbl (%edi),%edx
      *ap /= (u8_t)10;
  8005bf:	0f b6 c2             	movzbl %dl,%eax
  8005c2:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
  8005c5:	8d 04 c8             	lea    (%eax,%ecx,8),%eax
  8005c8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005cb:	66 c1 e8 0b          	shr    $0xb,%ax
  8005cf:	88 07                	mov    %al,(%edi)
      inv[i++] = '0' + rem;
  8005d1:	8d 4e 01             	lea    0x1(%esi),%ecx
  8005d4:	89 f3                	mov    %esi,%ebx
  8005d6:	0f b6 f3             	movzbl %bl,%esi
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  8005d9:	8d 3c 80             	lea    (%eax,%eax,4),%edi
  8005dc:	01 ff                	add    %edi,%edi
  8005de:	89 fb                	mov    %edi,%ebx
  8005e0:	29 da                	sub    %ebx,%edx
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
  8005e2:	83 c2 30             	add    $0x30,%edx
  8005e5:	88 54 35 ed          	mov    %dl,-0x13(%ebp,%esi,1)
    } while(*ap);
  8005e9:	84 c0                	test   %al,%al
  8005eb:	75 ca                	jne    8005b7 <inet_ntoa+0x27>
  8005ed:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005f0:	89 c8                	mov    %ecx,%eax
  8005f2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005f5:	89 cf                	mov    %ecx,%edi
  8005f7:	eb 0d                	jmp    800606 <inet_ntoa+0x76>
    while(i--)
      *rp++ = inv[i];
  8005f9:	0f b6 f0             	movzbl %al,%esi
  8005fc:	0f b6 4c 35 ed       	movzbl -0x13(%ebp,%esi,1),%ecx
  800601:	88 0a                	mov    %cl,(%edx)
  800603:	83 c2 01             	add    $0x1,%edx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  800606:	83 e8 01             	sub    $0x1,%eax
  800609:	3c ff                	cmp    $0xff,%al
  80060b:	75 ec                	jne    8005f9 <inet_ntoa+0x69>
  80060d:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  800610:	89 f9                	mov    %edi,%ecx
  800612:	0f b6 c9             	movzbl %cl,%ecx
  800615:	03 4d dc             	add    -0x24(%ebp),%ecx
      *rp++ = inv[i];
    *rp++ = '.';
  800618:	8d 41 01             	lea    0x1(%ecx),%eax
  80061b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    ap++;
  80061e:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  800622:	80 45 db 01          	addb   $0x1,-0x25(%ebp)
  800626:	80 7d db 03          	cmpb   $0x3,-0x25(%ebp)
  80062a:	77 0a                	ja     800636 <inet_ntoa+0xa6>
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
  80062c:	c6 01 2e             	movb   $0x2e,(%ecx)
  80062f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800634:	eb 81                	jmp    8005b7 <inet_ntoa+0x27>
    ap++;
  }
  *--rp = 0;
  800636:	c6 01 00             	movb   $0x0,(%ecx)
  return str;
}
  800639:	b8 00 50 80 00       	mov    $0x805000,%eax
  80063e:	83 c4 19             	add    $0x19,%esp
  800641:	5b                   	pop    %ebx
  800642:	5e                   	pop    %esi
  800643:	5f                   	pop    %edi
  800644:	5d                   	pop    %ebp
  800645:	c3                   	ret    

00800646 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  800646:	55                   	push   %ebp
  800647:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800649:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80064d:	66 c1 c0 08          	rol    $0x8,%ax
}
  800651:	5d                   	pop    %ebp
  800652:	c3                   	ret    

00800653 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  800653:	55                   	push   %ebp
  800654:	89 e5                	mov    %esp,%ebp
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800656:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80065a:	66 c1 c0 08          	rol    $0x8,%ax
 */
u16_t
ntohs(u16_t n)
{
  return htons(n);
}
  80065e:	5d                   	pop    %ebp
  80065f:	c3                   	ret    

00800660 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  800660:	55                   	push   %ebp
  800661:	89 e5                	mov    %esp,%ebp
  800663:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
  800666:	89 d1                	mov    %edx,%ecx
  800668:	c1 e9 18             	shr    $0x18,%ecx
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  return ((n & 0xff) << 24) |
  80066b:	89 d0                	mov    %edx,%eax
  80066d:	c1 e0 18             	shl    $0x18,%eax
  800670:	09 c8                	or     %ecx,%eax
    ((n & 0xff00) << 8) |
  800672:	89 d1                	mov    %edx,%ecx
  800674:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  80067a:	c1 e1 08             	shl    $0x8,%ecx
  80067d:	09 c8                	or     %ecx,%eax
    ((n & 0xff0000UL) >> 8) |
  80067f:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  800685:	c1 ea 08             	shr    $0x8,%edx
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  return ((n & 0xff) << 24) |
  800688:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  80068a:	5d                   	pop    %ebp
  80068b:	c3                   	ret    

0080068c <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  80068c:	55                   	push   %ebp
  80068d:	89 e5                	mov    %esp,%ebp
  80068f:	57                   	push   %edi
  800690:	56                   	push   %esi
  800691:	53                   	push   %ebx
  800692:	83 ec 20             	sub    $0x20,%esp
  800695:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  800698:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  80069b:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80069e:	89 75 d8             	mov    %esi,-0x28(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  8006a1:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8006a4:	80 f9 09             	cmp    $0x9,%cl
  8006a7:	0f 87 a6 01 00 00    	ja     800853 <inet_aton+0x1c7>
      return (0);
    val = 0;
    base = 10;
  8006ad:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
    if (c == '0') {
  8006b4:	83 fa 30             	cmp    $0x30,%edx
  8006b7:	75 2b                	jne    8006e4 <inet_aton+0x58>
      c = *++cp;
  8006b9:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  8006bd:	89 d1                	mov    %edx,%ecx
  8006bf:	83 e1 df             	and    $0xffffffdf,%ecx
  8006c2:	80 f9 58             	cmp    $0x58,%cl
  8006c5:	74 0f                	je     8006d6 <inet_aton+0x4a>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  8006c7:	83 c0 01             	add    $0x1,%eax
  8006ca:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  8006cd:	c7 45 e0 08 00 00 00 	movl   $0x8,-0x20(%ebp)
  8006d4:	eb 0e                	jmp    8006e4 <inet_aton+0x58>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  8006d6:	0f be 50 02          	movsbl 0x2(%eax),%edx
  8006da:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  8006dd:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  8006e4:	83 c0 01             	add    $0x1,%eax
  8006e7:	bf 00 00 00 00       	mov    $0x0,%edi
  8006ec:	eb 03                	jmp    8006f1 <inet_aton+0x65>
  8006ee:	83 c0 01             	add    $0x1,%eax
  8006f1:	8d 70 ff             	lea    -0x1(%eax),%esi
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  8006f4:	89 d3                	mov    %edx,%ebx
  8006f6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8006f9:	80 f9 09             	cmp    $0x9,%cl
  8006fc:	77 0d                	ja     80070b <inet_aton+0x7f>
        val = (val * base) + (int)(c - '0');
  8006fe:	0f af 7d e0          	imul   -0x20(%ebp),%edi
  800702:	8d 7c 3a d0          	lea    -0x30(%edx,%edi,1),%edi
        c = *++cp;
  800706:	0f be 10             	movsbl (%eax),%edx
  800709:	eb e3                	jmp    8006ee <inet_aton+0x62>
      } else if (base == 16 && isxdigit(c)) {
  80070b:	83 7d e0 10          	cmpl   $0x10,-0x20(%ebp)
  80070f:	75 30                	jne    800741 <inet_aton+0xb5>
  800711:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
  800714:	88 4d df             	mov    %cl,-0x21(%ebp)
  800717:	89 d1                	mov    %edx,%ecx
  800719:	83 e1 df             	and    $0xffffffdf,%ecx
  80071c:	83 e9 41             	sub    $0x41,%ecx
  80071f:	80 f9 05             	cmp    $0x5,%cl
  800722:	77 23                	ja     800747 <inet_aton+0xbb>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  800724:	89 fb                	mov    %edi,%ebx
  800726:	c1 e3 04             	shl    $0x4,%ebx
  800729:	8d 7a 0a             	lea    0xa(%edx),%edi
  80072c:	80 7d df 1a          	cmpb   $0x1a,-0x21(%ebp)
  800730:	19 c9                	sbb    %ecx,%ecx
  800732:	83 e1 20             	and    $0x20,%ecx
  800735:	83 c1 41             	add    $0x41,%ecx
  800738:	29 cf                	sub    %ecx,%edi
  80073a:	09 df                	or     %ebx,%edi
        c = *++cp;
  80073c:	0f be 10             	movsbl (%eax),%edx
  80073f:	eb ad                	jmp    8006ee <inet_aton+0x62>
  800741:	89 d0                	mov    %edx,%eax
  800743:	89 f9                	mov    %edi,%ecx
  800745:	eb 04                	jmp    80074b <inet_aton+0xbf>
  800747:	89 d0                	mov    %edx,%eax
  800749:	89 f9                	mov    %edi,%ecx
      } else
        break;
    }
    if (c == '.') {
  80074b:	83 f8 2e             	cmp    $0x2e,%eax
  80074e:	75 22                	jne    800772 <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  800750:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800753:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  800756:	0f 84 fe 00 00 00    	je     80085a <inet_aton+0x1ce>
        return (0);
      *pp++ = val;
  80075c:	83 45 d8 04          	addl   $0x4,-0x28(%ebp)
  800760:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800763:	89 48 fc             	mov    %ecx,-0x4(%eax)
      c = *++cp;
  800766:	8d 46 01             	lea    0x1(%esi),%eax
  800769:	0f be 56 01          	movsbl 0x1(%esi),%edx
    } else
      break;
  }
  80076d:	e9 2f ff ff ff       	jmp    8006a1 <inet_aton+0x15>
  800772:	89 f9                	mov    %edi,%ecx
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  800774:	85 d2                	test   %edx,%edx
  800776:	74 27                	je     80079f <inet_aton+0x113>
    return (0);
  800778:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  80077d:	80 fb 1f             	cmp    $0x1f,%bl
  800780:	0f 86 e7 00 00 00    	jbe    80086d <inet_aton+0x1e1>
  800786:	84 d2                	test   %dl,%dl
  800788:	0f 88 d3 00 00 00    	js     800861 <inet_aton+0x1d5>
  80078e:	83 fa 20             	cmp    $0x20,%edx
  800791:	74 0c                	je     80079f <inet_aton+0x113>
  800793:	83 ea 09             	sub    $0x9,%edx
  800796:	83 fa 04             	cmp    $0x4,%edx
  800799:	0f 87 ce 00 00 00    	ja     80086d <inet_aton+0x1e1>
    return (0);
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  80079f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8007a2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007a5:	29 c2                	sub    %eax,%edx
  8007a7:	c1 fa 02             	sar    $0x2,%edx
  8007aa:	83 c2 01             	add    $0x1,%edx
  switch (n) {
  8007ad:	83 fa 02             	cmp    $0x2,%edx
  8007b0:	74 22                	je     8007d4 <inet_aton+0x148>
  8007b2:	83 fa 02             	cmp    $0x2,%edx
  8007b5:	7f 0f                	jg     8007c6 <inet_aton+0x13a>

  case 0:
    return (0);       /* initial nondigit */
  8007b7:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8007bc:	85 d2                	test   %edx,%edx
  8007be:	0f 84 a9 00 00 00    	je     80086d <inet_aton+0x1e1>
  8007c4:	eb 73                	jmp    800839 <inet_aton+0x1ad>
  8007c6:	83 fa 03             	cmp    $0x3,%edx
  8007c9:	74 26                	je     8007f1 <inet_aton+0x165>
  8007cb:	83 fa 04             	cmp    $0x4,%edx
  8007ce:	66 90                	xchg   %ax,%ax
  8007d0:	74 40                	je     800812 <inet_aton+0x186>
  8007d2:	eb 65                	jmp    800839 <inet_aton+0x1ad>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  8007d4:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  8007d9:	81 f9 ff ff ff 00    	cmp    $0xffffff,%ecx
  8007df:	0f 87 88 00 00 00    	ja     80086d <inet_aton+0x1e1>
      return (0);
    val |= parts[0] << 24;
  8007e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007e8:	c1 e0 18             	shl    $0x18,%eax
  8007eb:	89 cf                	mov    %ecx,%edi
  8007ed:	09 c7                	or     %eax,%edi
    break;
  8007ef:	eb 48                	jmp    800839 <inet_aton+0x1ad>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  8007f1:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  8007f6:	81 f9 ff ff 00 00    	cmp    $0xffff,%ecx
  8007fc:	77 6f                	ja     80086d <inet_aton+0x1e1>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  8007fe:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800801:	c1 e2 10             	shl    $0x10,%edx
  800804:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800807:	c1 e0 18             	shl    $0x18,%eax
  80080a:	09 d0                	or     %edx,%eax
  80080c:	09 c8                	or     %ecx,%eax
  80080e:	89 c7                	mov    %eax,%edi
    break;
  800810:	eb 27                	jmp    800839 <inet_aton+0x1ad>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  800812:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  800817:	81 f9 ff 00 00 00    	cmp    $0xff,%ecx
  80081d:	77 4e                	ja     80086d <inet_aton+0x1e1>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  80081f:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800822:	c1 e2 10             	shl    $0x10,%edx
  800825:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800828:	c1 e0 18             	shl    $0x18,%eax
  80082b:	09 c2                	or     %eax,%edx
  80082d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800830:	c1 e0 08             	shl    $0x8,%eax
  800833:	09 d0                	or     %edx,%eax
  800835:	09 c8                	or     %ecx,%eax
  800837:	89 c7                	mov    %eax,%edi
    break;
  }
  if (addr)
  800839:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80083d:	74 29                	je     800868 <inet_aton+0x1dc>
    addr->s_addr = htonl(val);
  80083f:	89 3c 24             	mov    %edi,(%esp)
  800842:	e8 19 fe ff ff       	call   800660 <htonl>
  800847:	8b 75 0c             	mov    0xc(%ebp),%esi
  80084a:	89 06                	mov    %eax,(%esi)
  return (1);
  80084c:	b8 01 00 00 00       	mov    $0x1,%eax
  800851:	eb 1a                	jmp    80086d <inet_aton+0x1e1>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  800853:	b8 00 00 00 00       	mov    $0x0,%eax
  800858:	eb 13                	jmp    80086d <inet_aton+0x1e1>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  80085a:	b8 00 00 00 00       	mov    $0x0,%eax
  80085f:	eb 0c                	jmp    80086d <inet_aton+0x1e1>
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
    return (0);
  800861:	b8 00 00 00 00       	mov    $0x0,%eax
  800866:	eb 05                	jmp    80086d <inet_aton+0x1e1>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  800868:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80086d:	83 c4 20             	add    $0x20,%esp
  800870:	5b                   	pop    %ebx
  800871:	5e                   	pop    %esi
  800872:	5f                   	pop    %edi
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	83 ec 18             	sub    $0x18,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  80087b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80087e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800882:	8b 45 08             	mov    0x8(%ebp),%eax
  800885:	89 04 24             	mov    %eax,(%esp)
  800888:	e8 ff fd ff ff       	call   80068c <inet_aton>
  80088d:	85 c0                	test   %eax,%eax
    return (val.s_addr);
  80088f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800894:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  800898:	c9                   	leave  
  800899:	c3                   	ret    

0080089a <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	83 ec 04             	sub    $0x4,%esp
  return htonl(n);
  8008a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a3:	89 04 24             	mov    %eax,(%esp)
  8008a6:	e8 b5 fd ff ff       	call   800660 <htonl>
}
  8008ab:	c9                   	leave  
  8008ac:	c3                   	ret    

008008ad <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	56                   	push   %esi
  8008b1:	53                   	push   %ebx
  8008b2:	83 ec 10             	sub    $0x10,%esp
  8008b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008b8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//cprintf("adjfkadjfk %d\n", sys_getenvid());
	thisenv = &envs[ENVX(sys_getenvid())];
  8008bb:	e8 55 0b 00 00       	call   801415 <sys_getenvid>
  8008c0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8008c5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8008c8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8008cd:	a3 1c 50 80 00       	mov    %eax,0x80501c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8008d2:	85 db                	test   %ebx,%ebx
  8008d4:	7e 07                	jle    8008dd <libmain+0x30>
		binaryname = argv[0];
  8008d6:	8b 06                	mov    (%esi),%eax
  8008d8:	a3 20 40 80 00       	mov    %eax,0x804020

	// call user main routine
	umain(argc, argv);
  8008dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008e1:	89 1c 24             	mov    %ebx,(%esp)
  8008e4:	e8 9e fb ff ff       	call   800487 <umain>

	// exit gracefully
	exit();
  8008e9:	e8 07 00 00 00       	call   8008f5 <exit>
}
  8008ee:	83 c4 10             	add    $0x10,%esp
  8008f1:	5b                   	pop    %ebx
  8008f2:	5e                   	pop    %esi
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8008fb:	e8 5a 10 00 00       	call   80195a <close_all>
	sys_env_destroy(0);
  800900:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800907:	e8 b7 0a 00 00       	call   8013c3 <sys_env_destroy>
}
  80090c:	c9                   	leave  
  80090d:	c3                   	ret    

0080090e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	56                   	push   %esi
  800912:	53                   	push   %ebx
  800913:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800916:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800919:	8b 35 20 40 80 00    	mov    0x804020,%esi
  80091f:	e8 f1 0a 00 00       	call   801415 <sys_getenvid>
  800924:	8b 55 0c             	mov    0xc(%ebp),%edx
  800927:	89 54 24 10          	mov    %edx,0x10(%esp)
  80092b:	8b 55 08             	mov    0x8(%ebp),%edx
  80092e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800932:	89 74 24 08          	mov    %esi,0x8(%esp)
  800936:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093a:	c7 04 24 f8 32 80 00 	movl   $0x8032f8,(%esp)
  800941:	e8 c1 00 00 00       	call   800a07 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800946:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80094a:	8b 45 10             	mov    0x10(%ebp),%eax
  80094d:	89 04 24             	mov    %eax,(%esp)
  800950:	e8 51 00 00 00       	call   8009a6 <vcprintf>
	cprintf("\n");
  800955:	c7 04 24 64 31 80 00 	movl   $0x803164,(%esp)
  80095c:	e8 a6 00 00 00       	call   800a07 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800961:	cc                   	int3   
  800962:	eb fd                	jmp    800961 <_panic+0x53>

00800964 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	53                   	push   %ebx
  800968:	83 ec 14             	sub    $0x14,%esp
  80096b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80096e:	8b 13                	mov    (%ebx),%edx
  800970:	8d 42 01             	lea    0x1(%edx),%eax
  800973:	89 03                	mov    %eax,(%ebx)
  800975:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800978:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80097c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800981:	75 19                	jne    80099c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800983:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80098a:	00 
  80098b:	8d 43 08             	lea    0x8(%ebx),%eax
  80098e:	89 04 24             	mov    %eax,(%esp)
  800991:	e8 f0 09 00 00       	call   801386 <sys_cputs>
		b->idx = 0;
  800996:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80099c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8009a0:	83 c4 14             	add    $0x14,%esp
  8009a3:	5b                   	pop    %ebx
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8009af:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8009b6:	00 00 00 
	b.cnt = 0;
  8009b9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8009c0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8009c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009d1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8009d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009db:	c7 04 24 64 09 80 00 	movl   $0x800964,(%esp)
  8009e2:	e8 b7 01 00 00       	call   800b9e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8009e7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8009ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8009f7:	89 04 24             	mov    %eax,(%esp)
  8009fa:	e8 87 09 00 00       	call   801386 <sys_cputs>

	return b.cnt;
}
  8009ff:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800a05:	c9                   	leave  
  800a06:	c3                   	ret    

00800a07 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800a0d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800a10:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	89 04 24             	mov    %eax,(%esp)
  800a1a:	e8 87 ff ff ff       	call   8009a6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800a1f:	c9                   	leave  
  800a20:	c3                   	ret    
  800a21:	66 90                	xchg   %ax,%ax
  800a23:	66 90                	xchg   %ax,%ax
  800a25:	66 90                	xchg   %ax,%ax
  800a27:	66 90                	xchg   %ax,%ax
  800a29:	66 90                	xchg   %ax,%ax
  800a2b:	66 90                	xchg   %ax,%ax
  800a2d:	66 90                	xchg   %ax,%ax
  800a2f:	90                   	nop

00800a30 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	57                   	push   %edi
  800a34:	56                   	push   %esi
  800a35:	53                   	push   %ebx
  800a36:	83 ec 3c             	sub    $0x3c,%esp
  800a39:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a3c:	89 d7                	mov    %edx,%edi
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a41:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a44:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a47:	89 c3                	mov    %eax,%ebx
  800a49:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800a4c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a4f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800a52:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a57:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a5a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800a5d:	39 d9                	cmp    %ebx,%ecx
  800a5f:	72 05                	jb     800a66 <printnum+0x36>
  800a61:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800a64:	77 69                	ja     800acf <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800a66:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800a69:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800a6d:	83 ee 01             	sub    $0x1,%esi
  800a70:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800a74:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a78:	8b 44 24 08          	mov    0x8(%esp),%eax
  800a7c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800a80:	89 c3                	mov    %eax,%ebx
  800a82:	89 d6                	mov    %edx,%esi
  800a84:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800a87:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800a8a:	89 54 24 08          	mov    %edx,0x8(%esp)
  800a8e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800a92:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a95:	89 04 24             	mov    %eax,(%esp)
  800a98:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800a9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a9f:	e8 9c 23 00 00       	call   802e40 <__udivdi3>
  800aa4:	89 d9                	mov    %ebx,%ecx
  800aa6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800aaa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800aae:	89 04 24             	mov    %eax,(%esp)
  800ab1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ab5:	89 fa                	mov    %edi,%edx
  800ab7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800aba:	e8 71 ff ff ff       	call   800a30 <printnum>
  800abf:	eb 1b                	jmp    800adc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800ac1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ac5:	8b 45 18             	mov    0x18(%ebp),%eax
  800ac8:	89 04 24             	mov    %eax,(%esp)
  800acb:	ff d3                	call   *%ebx
  800acd:	eb 03                	jmp    800ad2 <printnum+0xa2>
  800acf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800ad2:	83 ee 01             	sub    $0x1,%esi
  800ad5:	85 f6                	test   %esi,%esi
  800ad7:	7f e8                	jg     800ac1 <printnum+0x91>
  800ad9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800adc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ae0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ae4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ae7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800aea:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aee:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800af2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800af5:	89 04 24             	mov    %eax,(%esp)
  800af8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800afb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aff:	e8 6c 24 00 00       	call   802f70 <__umoddi3>
  800b04:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b08:	0f be 80 1b 33 80 00 	movsbl 0x80331b(%eax),%eax
  800b0f:	89 04 24             	mov    %eax,(%esp)
  800b12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b15:	ff d0                	call   *%eax
}
  800b17:	83 c4 3c             	add    $0x3c,%esp
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5f                   	pop    %edi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800b22:	83 fa 01             	cmp    $0x1,%edx
  800b25:	7e 0e                	jle    800b35 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800b27:	8b 10                	mov    (%eax),%edx
  800b29:	8d 4a 08             	lea    0x8(%edx),%ecx
  800b2c:	89 08                	mov    %ecx,(%eax)
  800b2e:	8b 02                	mov    (%edx),%eax
  800b30:	8b 52 04             	mov    0x4(%edx),%edx
  800b33:	eb 22                	jmp    800b57 <getuint+0x38>
	else if (lflag)
  800b35:	85 d2                	test   %edx,%edx
  800b37:	74 10                	je     800b49 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800b39:	8b 10                	mov    (%eax),%edx
  800b3b:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b3e:	89 08                	mov    %ecx,(%eax)
  800b40:	8b 02                	mov    (%edx),%eax
  800b42:	ba 00 00 00 00       	mov    $0x0,%edx
  800b47:	eb 0e                	jmp    800b57 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800b49:	8b 10                	mov    (%eax),%edx
  800b4b:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b4e:	89 08                	mov    %ecx,(%eax)
  800b50:	8b 02                	mov    (%edx),%eax
  800b52:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800b5f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800b63:	8b 10                	mov    (%eax),%edx
  800b65:	3b 50 04             	cmp    0x4(%eax),%edx
  800b68:	73 0a                	jae    800b74 <sprintputch+0x1b>
		*b->buf++ = ch;
  800b6a:	8d 4a 01             	lea    0x1(%edx),%ecx
  800b6d:	89 08                	mov    %ecx,(%eax)
  800b6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b72:	88 02                	mov    %al,(%edx)
}
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800b7c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800b7f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b83:	8b 45 10             	mov    0x10(%ebp),%eax
  800b86:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b91:	8b 45 08             	mov    0x8(%ebp),%eax
  800b94:	89 04 24             	mov    %eax,(%esp)
  800b97:	e8 02 00 00 00       	call   800b9e <vprintfmt>
	va_end(ap);
}
  800b9c:	c9                   	leave  
  800b9d:	c3                   	ret    

00800b9e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
  800ba4:	83 ec 3c             	sub    $0x3c,%esp
  800ba7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800baa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bad:	eb 14                	jmp    800bc3 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800baf:	85 c0                	test   %eax,%eax
  800bb1:	0f 84 b3 03 00 00    	je     800f6a <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800bb7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bbb:	89 04 24             	mov    %eax,(%esp)
  800bbe:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800bc1:	89 f3                	mov    %esi,%ebx
  800bc3:	8d 73 01             	lea    0x1(%ebx),%esi
  800bc6:	0f b6 03             	movzbl (%ebx),%eax
  800bc9:	83 f8 25             	cmp    $0x25,%eax
  800bcc:	75 e1                	jne    800baf <vprintfmt+0x11>
  800bce:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800bd2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800bd9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800be0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800be7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bec:	eb 1d                	jmp    800c0b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bee:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800bf0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800bf4:	eb 15                	jmp    800c0b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bf6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800bf8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800bfc:	eb 0d                	jmp    800c0b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800bfe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800c01:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800c04:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c0b:	8d 5e 01             	lea    0x1(%esi),%ebx
  800c0e:	0f b6 0e             	movzbl (%esi),%ecx
  800c11:	0f b6 c1             	movzbl %cl,%eax
  800c14:	83 e9 23             	sub    $0x23,%ecx
  800c17:	80 f9 55             	cmp    $0x55,%cl
  800c1a:	0f 87 2a 03 00 00    	ja     800f4a <vprintfmt+0x3ac>
  800c20:	0f b6 c9             	movzbl %cl,%ecx
  800c23:	ff 24 8d 60 34 80 00 	jmp    *0x803460(,%ecx,4)
  800c2a:	89 de                	mov    %ebx,%esi
  800c2c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800c31:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800c34:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800c38:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800c3b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800c3e:	83 fb 09             	cmp    $0x9,%ebx
  800c41:	77 36                	ja     800c79 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800c43:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800c46:	eb e9                	jmp    800c31 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800c48:	8b 45 14             	mov    0x14(%ebp),%eax
  800c4b:	8d 48 04             	lea    0x4(%eax),%ecx
  800c4e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800c51:	8b 00                	mov    (%eax),%eax
  800c53:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c56:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800c58:	eb 22                	jmp    800c7c <vprintfmt+0xde>
  800c5a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800c5d:	85 c9                	test   %ecx,%ecx
  800c5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c64:	0f 49 c1             	cmovns %ecx,%eax
  800c67:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c6a:	89 de                	mov    %ebx,%esi
  800c6c:	eb 9d                	jmp    800c0b <vprintfmt+0x6d>
  800c6e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800c70:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800c77:	eb 92                	jmp    800c0b <vprintfmt+0x6d>
  800c79:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  800c7c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800c80:	79 89                	jns    800c0b <vprintfmt+0x6d>
  800c82:	e9 77 ff ff ff       	jmp    800bfe <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800c87:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c8a:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800c8c:	e9 7a ff ff ff       	jmp    800c0b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800c91:	8b 45 14             	mov    0x14(%ebp),%eax
  800c94:	8d 50 04             	lea    0x4(%eax),%edx
  800c97:	89 55 14             	mov    %edx,0x14(%ebp)
  800c9a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c9e:	8b 00                	mov    (%eax),%eax
  800ca0:	89 04 24             	mov    %eax,(%esp)
  800ca3:	ff 55 08             	call   *0x8(%ebp)
			break;
  800ca6:	e9 18 ff ff ff       	jmp    800bc3 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800cab:	8b 45 14             	mov    0x14(%ebp),%eax
  800cae:	8d 50 04             	lea    0x4(%eax),%edx
  800cb1:	89 55 14             	mov    %edx,0x14(%ebp)
  800cb4:	8b 00                	mov    (%eax),%eax
  800cb6:	99                   	cltd   
  800cb7:	31 d0                	xor    %edx,%eax
  800cb9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800cbb:	83 f8 0f             	cmp    $0xf,%eax
  800cbe:	7f 0b                	jg     800ccb <vprintfmt+0x12d>
  800cc0:	8b 14 85 c0 35 80 00 	mov    0x8035c0(,%eax,4),%edx
  800cc7:	85 d2                	test   %edx,%edx
  800cc9:	75 20                	jne    800ceb <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  800ccb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ccf:	c7 44 24 08 33 33 80 	movl   $0x803333,0x8(%esp)
  800cd6:	00 
  800cd7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cde:	89 04 24             	mov    %eax,(%esp)
  800ce1:	e8 90 fe ff ff       	call   800b76 <printfmt>
  800ce6:	e9 d8 fe ff ff       	jmp    800bc3 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800ceb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800cef:	c7 44 24 08 f5 36 80 	movl   $0x8036f5,0x8(%esp)
  800cf6:	00 
  800cf7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfe:	89 04 24             	mov    %eax,(%esp)
  800d01:	e8 70 fe ff ff       	call   800b76 <printfmt>
  800d06:	e9 b8 fe ff ff       	jmp    800bc3 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d0b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800d0e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800d11:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d14:	8b 45 14             	mov    0x14(%ebp),%eax
  800d17:	8d 50 04             	lea    0x4(%eax),%edx
  800d1a:	89 55 14             	mov    %edx,0x14(%ebp)
  800d1d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800d1f:	85 f6                	test   %esi,%esi
  800d21:	b8 2c 33 80 00       	mov    $0x80332c,%eax
  800d26:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800d29:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800d2d:	0f 84 97 00 00 00    	je     800dca <vprintfmt+0x22c>
  800d33:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800d37:	0f 8e 9b 00 00 00    	jle    800dd8 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800d3d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d41:	89 34 24             	mov    %esi,(%esp)
  800d44:	e8 cf 02 00 00       	call   801018 <strnlen>
  800d49:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800d4c:	29 c2                	sub    %eax,%edx
  800d4e:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800d51:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800d55:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800d58:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800d5b:	8b 75 08             	mov    0x8(%ebp),%esi
  800d5e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d61:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d63:	eb 0f                	jmp    800d74 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800d65:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d69:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800d6c:	89 04 24             	mov    %eax,(%esp)
  800d6f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d71:	83 eb 01             	sub    $0x1,%ebx
  800d74:	85 db                	test   %ebx,%ebx
  800d76:	7f ed                	jg     800d65 <vprintfmt+0x1c7>
  800d78:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800d7b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800d7e:	85 d2                	test   %edx,%edx
  800d80:	b8 00 00 00 00       	mov    $0x0,%eax
  800d85:	0f 49 c2             	cmovns %edx,%eax
  800d88:	29 c2                	sub    %eax,%edx
  800d8a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800d8d:	89 d7                	mov    %edx,%edi
  800d8f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800d92:	eb 50                	jmp    800de4 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800d94:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d98:	74 1e                	je     800db8 <vprintfmt+0x21a>
  800d9a:	0f be d2             	movsbl %dl,%edx
  800d9d:	83 ea 20             	sub    $0x20,%edx
  800da0:	83 fa 5e             	cmp    $0x5e,%edx
  800da3:	76 13                	jbe    800db8 <vprintfmt+0x21a>
					putch('?', putdat);
  800da5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dac:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800db3:	ff 55 08             	call   *0x8(%ebp)
  800db6:	eb 0d                	jmp    800dc5 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800db8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dbb:	89 54 24 04          	mov    %edx,0x4(%esp)
  800dbf:	89 04 24             	mov    %eax,(%esp)
  800dc2:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800dc5:	83 ef 01             	sub    $0x1,%edi
  800dc8:	eb 1a                	jmp    800de4 <vprintfmt+0x246>
  800dca:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800dcd:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800dd0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800dd3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800dd6:	eb 0c                	jmp    800de4 <vprintfmt+0x246>
  800dd8:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800ddb:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800dde:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800de1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800de4:	83 c6 01             	add    $0x1,%esi
  800de7:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800deb:	0f be c2             	movsbl %dl,%eax
  800dee:	85 c0                	test   %eax,%eax
  800df0:	74 27                	je     800e19 <vprintfmt+0x27b>
  800df2:	85 db                	test   %ebx,%ebx
  800df4:	78 9e                	js     800d94 <vprintfmt+0x1f6>
  800df6:	83 eb 01             	sub    $0x1,%ebx
  800df9:	79 99                	jns    800d94 <vprintfmt+0x1f6>
  800dfb:	89 f8                	mov    %edi,%eax
  800dfd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e00:	8b 75 08             	mov    0x8(%ebp),%esi
  800e03:	89 c3                	mov    %eax,%ebx
  800e05:	eb 1a                	jmp    800e21 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800e07:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e0b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800e12:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e14:	83 eb 01             	sub    $0x1,%ebx
  800e17:	eb 08                	jmp    800e21 <vprintfmt+0x283>
  800e19:	89 fb                	mov    %edi,%ebx
  800e1b:	8b 75 08             	mov    0x8(%ebp),%esi
  800e1e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e21:	85 db                	test   %ebx,%ebx
  800e23:	7f e2                	jg     800e07 <vprintfmt+0x269>
  800e25:	89 75 08             	mov    %esi,0x8(%ebp)
  800e28:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e2b:	e9 93 fd ff ff       	jmp    800bc3 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800e30:	83 fa 01             	cmp    $0x1,%edx
  800e33:	7e 16                	jle    800e4b <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800e35:	8b 45 14             	mov    0x14(%ebp),%eax
  800e38:	8d 50 08             	lea    0x8(%eax),%edx
  800e3b:	89 55 14             	mov    %edx,0x14(%ebp)
  800e3e:	8b 50 04             	mov    0x4(%eax),%edx
  800e41:	8b 00                	mov    (%eax),%eax
  800e43:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800e46:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800e49:	eb 32                	jmp    800e7d <vprintfmt+0x2df>
	else if (lflag)
  800e4b:	85 d2                	test   %edx,%edx
  800e4d:	74 18                	je     800e67 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  800e4f:	8b 45 14             	mov    0x14(%ebp),%eax
  800e52:	8d 50 04             	lea    0x4(%eax),%edx
  800e55:	89 55 14             	mov    %edx,0x14(%ebp)
  800e58:	8b 30                	mov    (%eax),%esi
  800e5a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800e5d:	89 f0                	mov    %esi,%eax
  800e5f:	c1 f8 1f             	sar    $0x1f,%eax
  800e62:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e65:	eb 16                	jmp    800e7d <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800e67:	8b 45 14             	mov    0x14(%ebp),%eax
  800e6a:	8d 50 04             	lea    0x4(%eax),%edx
  800e6d:	89 55 14             	mov    %edx,0x14(%ebp)
  800e70:	8b 30                	mov    (%eax),%esi
  800e72:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800e75:	89 f0                	mov    %esi,%eax
  800e77:	c1 f8 1f             	sar    $0x1f,%eax
  800e7a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800e7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e80:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800e83:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800e88:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e8c:	0f 89 80 00 00 00    	jns    800f12 <vprintfmt+0x374>
				putch('-', putdat);
  800e92:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e96:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800e9d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800ea0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ea3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ea6:	f7 d8                	neg    %eax
  800ea8:	83 d2 00             	adc    $0x0,%edx
  800eab:	f7 da                	neg    %edx
			}
			base = 10;
  800ead:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800eb2:	eb 5e                	jmp    800f12 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800eb4:	8d 45 14             	lea    0x14(%ebp),%eax
  800eb7:	e8 63 fc ff ff       	call   800b1f <getuint>
			base = 10;
  800ebc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800ec1:	eb 4f                	jmp    800f12 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800ec3:	8d 45 14             	lea    0x14(%ebp),%eax
  800ec6:	e8 54 fc ff ff       	call   800b1f <getuint>
			base = 8;
  800ecb:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800ed0:	eb 40                	jmp    800f12 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
  800ed2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ed6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800edd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800ee0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ee4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800eeb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800eee:	8b 45 14             	mov    0x14(%ebp),%eax
  800ef1:	8d 50 04             	lea    0x4(%eax),%edx
  800ef4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800ef7:	8b 00                	mov    (%eax),%eax
  800ef9:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800efe:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800f03:	eb 0d                	jmp    800f12 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800f05:	8d 45 14             	lea    0x14(%ebp),%eax
  800f08:	e8 12 fc ff ff       	call   800b1f <getuint>
			base = 16;
  800f0d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800f12:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800f16:	89 74 24 10          	mov    %esi,0x10(%esp)
  800f1a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800f1d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800f21:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f25:	89 04 24             	mov    %eax,(%esp)
  800f28:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f2c:	89 fa                	mov    %edi,%edx
  800f2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f31:	e8 fa fa ff ff       	call   800a30 <printnum>
			break;
  800f36:	e9 88 fc ff ff       	jmp    800bc3 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800f3b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f3f:	89 04 24             	mov    %eax,(%esp)
  800f42:	ff 55 08             	call   *0x8(%ebp)
			break;
  800f45:	e9 79 fc ff ff       	jmp    800bc3 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800f4a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f4e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800f55:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800f58:	89 f3                	mov    %esi,%ebx
  800f5a:	eb 03                	jmp    800f5f <vprintfmt+0x3c1>
  800f5c:	83 eb 01             	sub    $0x1,%ebx
  800f5f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800f63:	75 f7                	jne    800f5c <vprintfmt+0x3be>
  800f65:	e9 59 fc ff ff       	jmp    800bc3 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800f6a:	83 c4 3c             	add    $0x3c,%esp
  800f6d:	5b                   	pop    %ebx
  800f6e:	5e                   	pop    %esi
  800f6f:	5f                   	pop    %edi
  800f70:	5d                   	pop    %ebp
  800f71:	c3                   	ret    

00800f72 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	83 ec 28             	sub    $0x28,%esp
  800f78:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800f7e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f81:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800f85:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800f88:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800f8f:	85 c0                	test   %eax,%eax
  800f91:	74 30                	je     800fc3 <vsnprintf+0x51>
  800f93:	85 d2                	test   %edx,%edx
  800f95:	7e 2c                	jle    800fc3 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800f97:	8b 45 14             	mov    0x14(%ebp),%eax
  800f9a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f9e:	8b 45 10             	mov    0x10(%ebp),%eax
  800fa1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fa5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800fa8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fac:	c7 04 24 59 0b 80 00 	movl   $0x800b59,(%esp)
  800fb3:	e8 e6 fb ff ff       	call   800b9e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800fb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fbb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc1:	eb 05                	jmp    800fc8 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800fc3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800fc8:	c9                   	leave  
  800fc9:	c3                   	ret    

00800fca <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800fd0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800fd3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fd7:	8b 45 10             	mov    0x10(%ebp),%eax
  800fda:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fde:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fe5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe8:	89 04 24             	mov    %eax,(%esp)
  800feb:	e8 82 ff ff ff       	call   800f72 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ff0:	c9                   	leave  
  800ff1:	c3                   	ret    
  800ff2:	66 90                	xchg   %ax,%ax
  800ff4:	66 90                	xchg   %ax,%ax
  800ff6:	66 90                	xchg   %ax,%ax
  800ff8:	66 90                	xchg   %ax,%ax
  800ffa:	66 90                	xchg   %ax,%ax
  800ffc:	66 90                	xchg   %ax,%ax
  800ffe:	66 90                	xchg   %ax,%ax

00801000 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801006:	b8 00 00 00 00       	mov    $0x0,%eax
  80100b:	eb 03                	jmp    801010 <strlen+0x10>
		n++;
  80100d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801010:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801014:	75 f7                	jne    80100d <strlen+0xd>
		n++;
	return n;
}
  801016:	5d                   	pop    %ebp
  801017:	c3                   	ret    

00801018 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801018:	55                   	push   %ebp
  801019:	89 e5                	mov    %esp,%ebp
  80101b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80101e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801021:	b8 00 00 00 00       	mov    $0x0,%eax
  801026:	eb 03                	jmp    80102b <strnlen+0x13>
		n++;
  801028:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80102b:	39 d0                	cmp    %edx,%eax
  80102d:	74 06                	je     801035 <strnlen+0x1d>
  80102f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801033:	75 f3                	jne    801028 <strnlen+0x10>
		n++;
	return n;
}
  801035:	5d                   	pop    %ebp
  801036:	c3                   	ret    

00801037 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	53                   	push   %ebx
  80103b:	8b 45 08             	mov    0x8(%ebp),%eax
  80103e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801041:	89 c2                	mov    %eax,%edx
  801043:	83 c2 01             	add    $0x1,%edx
  801046:	83 c1 01             	add    $0x1,%ecx
  801049:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80104d:	88 5a ff             	mov    %bl,-0x1(%edx)
  801050:	84 db                	test   %bl,%bl
  801052:	75 ef                	jne    801043 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801054:	5b                   	pop    %ebx
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    

00801057 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	53                   	push   %ebx
  80105b:	83 ec 08             	sub    $0x8,%esp
  80105e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801061:	89 1c 24             	mov    %ebx,(%esp)
  801064:	e8 97 ff ff ff       	call   801000 <strlen>
	strcpy(dst + len, src);
  801069:	8b 55 0c             	mov    0xc(%ebp),%edx
  80106c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801070:	01 d8                	add    %ebx,%eax
  801072:	89 04 24             	mov    %eax,(%esp)
  801075:	e8 bd ff ff ff       	call   801037 <strcpy>
	return dst;
}
  80107a:	89 d8                	mov    %ebx,%eax
  80107c:	83 c4 08             	add    $0x8,%esp
  80107f:	5b                   	pop    %ebx
  801080:	5d                   	pop    %ebp
  801081:	c3                   	ret    

00801082 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	56                   	push   %esi
  801086:	53                   	push   %ebx
  801087:	8b 75 08             	mov    0x8(%ebp),%esi
  80108a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80108d:	89 f3                	mov    %esi,%ebx
  80108f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801092:	89 f2                	mov    %esi,%edx
  801094:	eb 0f                	jmp    8010a5 <strncpy+0x23>
		*dst++ = *src;
  801096:	83 c2 01             	add    $0x1,%edx
  801099:	0f b6 01             	movzbl (%ecx),%eax
  80109c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80109f:	80 39 01             	cmpb   $0x1,(%ecx)
  8010a2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8010a5:	39 da                	cmp    %ebx,%edx
  8010a7:	75 ed                	jne    801096 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8010a9:	89 f0                	mov    %esi,%eax
  8010ab:	5b                   	pop    %ebx
  8010ac:	5e                   	pop    %esi
  8010ad:	5d                   	pop    %ebp
  8010ae:	c3                   	ret    

008010af <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8010af:	55                   	push   %ebp
  8010b0:	89 e5                	mov    %esp,%ebp
  8010b2:	56                   	push   %esi
  8010b3:	53                   	push   %ebx
  8010b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8010b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010bd:	89 f0                	mov    %esi,%eax
  8010bf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8010c3:	85 c9                	test   %ecx,%ecx
  8010c5:	75 0b                	jne    8010d2 <strlcpy+0x23>
  8010c7:	eb 1d                	jmp    8010e6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8010c9:	83 c0 01             	add    $0x1,%eax
  8010cc:	83 c2 01             	add    $0x1,%edx
  8010cf:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8010d2:	39 d8                	cmp    %ebx,%eax
  8010d4:	74 0b                	je     8010e1 <strlcpy+0x32>
  8010d6:	0f b6 0a             	movzbl (%edx),%ecx
  8010d9:	84 c9                	test   %cl,%cl
  8010db:	75 ec                	jne    8010c9 <strlcpy+0x1a>
  8010dd:	89 c2                	mov    %eax,%edx
  8010df:	eb 02                	jmp    8010e3 <strlcpy+0x34>
  8010e1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8010e3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8010e6:	29 f0                	sub    %esi,%eax
}
  8010e8:	5b                   	pop    %ebx
  8010e9:	5e                   	pop    %esi
  8010ea:	5d                   	pop    %ebp
  8010eb:	c3                   	ret    

008010ec <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8010f5:	eb 06                	jmp    8010fd <strcmp+0x11>
		p++, q++;
  8010f7:	83 c1 01             	add    $0x1,%ecx
  8010fa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8010fd:	0f b6 01             	movzbl (%ecx),%eax
  801100:	84 c0                	test   %al,%al
  801102:	74 04                	je     801108 <strcmp+0x1c>
  801104:	3a 02                	cmp    (%edx),%al
  801106:	74 ef                	je     8010f7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801108:	0f b6 c0             	movzbl %al,%eax
  80110b:	0f b6 12             	movzbl (%edx),%edx
  80110e:	29 d0                	sub    %edx,%eax
}
  801110:	5d                   	pop    %ebp
  801111:	c3                   	ret    

00801112 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801112:	55                   	push   %ebp
  801113:	89 e5                	mov    %esp,%ebp
  801115:	53                   	push   %ebx
  801116:	8b 45 08             	mov    0x8(%ebp),%eax
  801119:	8b 55 0c             	mov    0xc(%ebp),%edx
  80111c:	89 c3                	mov    %eax,%ebx
  80111e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801121:	eb 06                	jmp    801129 <strncmp+0x17>
		n--, p++, q++;
  801123:	83 c0 01             	add    $0x1,%eax
  801126:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801129:	39 d8                	cmp    %ebx,%eax
  80112b:	74 15                	je     801142 <strncmp+0x30>
  80112d:	0f b6 08             	movzbl (%eax),%ecx
  801130:	84 c9                	test   %cl,%cl
  801132:	74 04                	je     801138 <strncmp+0x26>
  801134:	3a 0a                	cmp    (%edx),%cl
  801136:	74 eb                	je     801123 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801138:	0f b6 00             	movzbl (%eax),%eax
  80113b:	0f b6 12             	movzbl (%edx),%edx
  80113e:	29 d0                	sub    %edx,%eax
  801140:	eb 05                	jmp    801147 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801142:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801147:	5b                   	pop    %ebx
  801148:	5d                   	pop    %ebp
  801149:	c3                   	ret    

0080114a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80114a:	55                   	push   %ebp
  80114b:	89 e5                	mov    %esp,%ebp
  80114d:	8b 45 08             	mov    0x8(%ebp),%eax
  801150:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801154:	eb 07                	jmp    80115d <strchr+0x13>
		if (*s == c)
  801156:	38 ca                	cmp    %cl,%dl
  801158:	74 0f                	je     801169 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80115a:	83 c0 01             	add    $0x1,%eax
  80115d:	0f b6 10             	movzbl (%eax),%edx
  801160:	84 d2                	test   %dl,%dl
  801162:	75 f2                	jne    801156 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801164:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801169:	5d                   	pop    %ebp
  80116a:	c3                   	ret    

0080116b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80116b:	55                   	push   %ebp
  80116c:	89 e5                	mov    %esp,%ebp
  80116e:	8b 45 08             	mov    0x8(%ebp),%eax
  801171:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801175:	eb 07                	jmp    80117e <strfind+0x13>
		if (*s == c)
  801177:	38 ca                	cmp    %cl,%dl
  801179:	74 0a                	je     801185 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80117b:	83 c0 01             	add    $0x1,%eax
  80117e:	0f b6 10             	movzbl (%eax),%edx
  801181:	84 d2                	test   %dl,%dl
  801183:	75 f2                	jne    801177 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  801185:	5d                   	pop    %ebp
  801186:	c3                   	ret    

00801187 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	57                   	push   %edi
  80118b:	56                   	push   %esi
  80118c:	53                   	push   %ebx
  80118d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801190:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801193:	85 c9                	test   %ecx,%ecx
  801195:	74 36                	je     8011cd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801197:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80119d:	75 28                	jne    8011c7 <memset+0x40>
  80119f:	f6 c1 03             	test   $0x3,%cl
  8011a2:	75 23                	jne    8011c7 <memset+0x40>
		c &= 0xFF;
  8011a4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8011a8:	89 d3                	mov    %edx,%ebx
  8011aa:	c1 e3 08             	shl    $0x8,%ebx
  8011ad:	89 d6                	mov    %edx,%esi
  8011af:	c1 e6 18             	shl    $0x18,%esi
  8011b2:	89 d0                	mov    %edx,%eax
  8011b4:	c1 e0 10             	shl    $0x10,%eax
  8011b7:	09 f0                	or     %esi,%eax
  8011b9:	09 c2                	or     %eax,%edx
  8011bb:	89 d0                	mov    %edx,%eax
  8011bd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8011bf:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8011c2:	fc                   	cld    
  8011c3:	f3 ab                	rep stos %eax,%es:(%edi)
  8011c5:	eb 06                	jmp    8011cd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8011c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ca:	fc                   	cld    
  8011cb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8011cd:	89 f8                	mov    %edi,%eax
  8011cf:	5b                   	pop    %ebx
  8011d0:	5e                   	pop    %esi
  8011d1:	5f                   	pop    %edi
  8011d2:	5d                   	pop    %ebp
  8011d3:	c3                   	ret    

008011d4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8011d4:	55                   	push   %ebp
  8011d5:	89 e5                	mov    %esp,%ebp
  8011d7:	57                   	push   %edi
  8011d8:	56                   	push   %esi
  8011d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011dc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8011e2:	39 c6                	cmp    %eax,%esi
  8011e4:	73 35                	jae    80121b <memmove+0x47>
  8011e6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8011e9:	39 d0                	cmp    %edx,%eax
  8011eb:	73 2e                	jae    80121b <memmove+0x47>
		s += n;
		d += n;
  8011ed:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8011f0:	89 d6                	mov    %edx,%esi
  8011f2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8011f4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8011fa:	75 13                	jne    80120f <memmove+0x3b>
  8011fc:	f6 c1 03             	test   $0x3,%cl
  8011ff:	75 0e                	jne    80120f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801201:	83 ef 04             	sub    $0x4,%edi
  801204:	8d 72 fc             	lea    -0x4(%edx),%esi
  801207:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80120a:	fd                   	std    
  80120b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80120d:	eb 09                	jmp    801218 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80120f:	83 ef 01             	sub    $0x1,%edi
  801212:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801215:	fd                   	std    
  801216:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801218:	fc                   	cld    
  801219:	eb 1d                	jmp    801238 <memmove+0x64>
  80121b:	89 f2                	mov    %esi,%edx
  80121d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80121f:	f6 c2 03             	test   $0x3,%dl
  801222:	75 0f                	jne    801233 <memmove+0x5f>
  801224:	f6 c1 03             	test   $0x3,%cl
  801227:	75 0a                	jne    801233 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801229:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80122c:	89 c7                	mov    %eax,%edi
  80122e:	fc                   	cld    
  80122f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801231:	eb 05                	jmp    801238 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801233:	89 c7                	mov    %eax,%edi
  801235:	fc                   	cld    
  801236:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801238:	5e                   	pop    %esi
  801239:	5f                   	pop    %edi
  80123a:	5d                   	pop    %ebp
  80123b:	c3                   	ret    

0080123c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
  80123f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801242:	8b 45 10             	mov    0x10(%ebp),%eax
  801245:	89 44 24 08          	mov    %eax,0x8(%esp)
  801249:	8b 45 0c             	mov    0xc(%ebp),%eax
  80124c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801250:	8b 45 08             	mov    0x8(%ebp),%eax
  801253:	89 04 24             	mov    %eax,(%esp)
  801256:	e8 79 ff ff ff       	call   8011d4 <memmove>
}
  80125b:	c9                   	leave  
  80125c:	c3                   	ret    

0080125d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	56                   	push   %esi
  801261:	53                   	push   %ebx
  801262:	8b 55 08             	mov    0x8(%ebp),%edx
  801265:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801268:	89 d6                	mov    %edx,%esi
  80126a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80126d:	eb 1a                	jmp    801289 <memcmp+0x2c>
		if (*s1 != *s2)
  80126f:	0f b6 02             	movzbl (%edx),%eax
  801272:	0f b6 19             	movzbl (%ecx),%ebx
  801275:	38 d8                	cmp    %bl,%al
  801277:	74 0a                	je     801283 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801279:	0f b6 c0             	movzbl %al,%eax
  80127c:	0f b6 db             	movzbl %bl,%ebx
  80127f:	29 d8                	sub    %ebx,%eax
  801281:	eb 0f                	jmp    801292 <memcmp+0x35>
		s1++, s2++;
  801283:	83 c2 01             	add    $0x1,%edx
  801286:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801289:	39 f2                	cmp    %esi,%edx
  80128b:	75 e2                	jne    80126f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80128d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801292:	5b                   	pop    %ebx
  801293:	5e                   	pop    %esi
  801294:	5d                   	pop    %ebp
  801295:	c3                   	ret    

00801296 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801296:	55                   	push   %ebp
  801297:	89 e5                	mov    %esp,%ebp
  801299:	8b 45 08             	mov    0x8(%ebp),%eax
  80129c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80129f:	89 c2                	mov    %eax,%edx
  8012a1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8012a4:	eb 07                	jmp    8012ad <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8012a6:	38 08                	cmp    %cl,(%eax)
  8012a8:	74 07                	je     8012b1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8012aa:	83 c0 01             	add    $0x1,%eax
  8012ad:	39 d0                	cmp    %edx,%eax
  8012af:	72 f5                	jb     8012a6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8012b1:	5d                   	pop    %ebp
  8012b2:	c3                   	ret    

008012b3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
  8012b6:	57                   	push   %edi
  8012b7:	56                   	push   %esi
  8012b8:	53                   	push   %ebx
  8012b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8012bc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8012bf:	eb 03                	jmp    8012c4 <strtol+0x11>
		s++;
  8012c1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8012c4:	0f b6 0a             	movzbl (%edx),%ecx
  8012c7:	80 f9 09             	cmp    $0x9,%cl
  8012ca:	74 f5                	je     8012c1 <strtol+0xe>
  8012cc:	80 f9 20             	cmp    $0x20,%cl
  8012cf:	74 f0                	je     8012c1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8012d1:	80 f9 2b             	cmp    $0x2b,%cl
  8012d4:	75 0a                	jne    8012e0 <strtol+0x2d>
		s++;
  8012d6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8012d9:	bf 00 00 00 00       	mov    $0x0,%edi
  8012de:	eb 11                	jmp    8012f1 <strtol+0x3e>
  8012e0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8012e5:	80 f9 2d             	cmp    $0x2d,%cl
  8012e8:	75 07                	jne    8012f1 <strtol+0x3e>
		s++, neg = 1;
  8012ea:	8d 52 01             	lea    0x1(%edx),%edx
  8012ed:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8012f1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  8012f6:	75 15                	jne    80130d <strtol+0x5a>
  8012f8:	80 3a 30             	cmpb   $0x30,(%edx)
  8012fb:	75 10                	jne    80130d <strtol+0x5a>
  8012fd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801301:	75 0a                	jne    80130d <strtol+0x5a>
		s += 2, base = 16;
  801303:	83 c2 02             	add    $0x2,%edx
  801306:	b8 10 00 00 00       	mov    $0x10,%eax
  80130b:	eb 10                	jmp    80131d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  80130d:	85 c0                	test   %eax,%eax
  80130f:	75 0c                	jne    80131d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801311:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801313:	80 3a 30             	cmpb   $0x30,(%edx)
  801316:	75 05                	jne    80131d <strtol+0x6a>
		s++, base = 8;
  801318:	83 c2 01             	add    $0x1,%edx
  80131b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  80131d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801322:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801325:	0f b6 0a             	movzbl (%edx),%ecx
  801328:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80132b:	89 f0                	mov    %esi,%eax
  80132d:	3c 09                	cmp    $0x9,%al
  80132f:	77 08                	ja     801339 <strtol+0x86>
			dig = *s - '0';
  801331:	0f be c9             	movsbl %cl,%ecx
  801334:	83 e9 30             	sub    $0x30,%ecx
  801337:	eb 20                	jmp    801359 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  801339:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80133c:	89 f0                	mov    %esi,%eax
  80133e:	3c 19                	cmp    $0x19,%al
  801340:	77 08                	ja     80134a <strtol+0x97>
			dig = *s - 'a' + 10;
  801342:	0f be c9             	movsbl %cl,%ecx
  801345:	83 e9 57             	sub    $0x57,%ecx
  801348:	eb 0f                	jmp    801359 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  80134a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  80134d:	89 f0                	mov    %esi,%eax
  80134f:	3c 19                	cmp    $0x19,%al
  801351:	77 16                	ja     801369 <strtol+0xb6>
			dig = *s - 'A' + 10;
  801353:	0f be c9             	movsbl %cl,%ecx
  801356:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801359:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80135c:	7d 0f                	jge    80136d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  80135e:	83 c2 01             	add    $0x1,%edx
  801361:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801365:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  801367:	eb bc                	jmp    801325 <strtol+0x72>
  801369:	89 d8                	mov    %ebx,%eax
  80136b:	eb 02                	jmp    80136f <strtol+0xbc>
  80136d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  80136f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801373:	74 05                	je     80137a <strtol+0xc7>
		*endptr = (char *) s;
  801375:	8b 75 0c             	mov    0xc(%ebp),%esi
  801378:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80137a:	f7 d8                	neg    %eax
  80137c:	85 ff                	test   %edi,%edi
  80137e:	0f 44 c3             	cmove  %ebx,%eax
}
  801381:	5b                   	pop    %ebx
  801382:	5e                   	pop    %esi
  801383:	5f                   	pop    %edi
  801384:	5d                   	pop    %ebp
  801385:	c3                   	ret    

00801386 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	57                   	push   %edi
  80138a:	56                   	push   %esi
  80138b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80138c:	b8 00 00 00 00       	mov    $0x0,%eax
  801391:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801394:	8b 55 08             	mov    0x8(%ebp),%edx
  801397:	89 c3                	mov    %eax,%ebx
  801399:	89 c7                	mov    %eax,%edi
  80139b:	89 c6                	mov    %eax,%esi
  80139d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80139f:	5b                   	pop    %ebx
  8013a0:	5e                   	pop    %esi
  8013a1:	5f                   	pop    %edi
  8013a2:	5d                   	pop    %ebp
  8013a3:	c3                   	ret    

008013a4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8013a4:	55                   	push   %ebp
  8013a5:	89 e5                	mov    %esp,%ebp
  8013a7:	57                   	push   %edi
  8013a8:	56                   	push   %esi
  8013a9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8013af:	b8 01 00 00 00       	mov    $0x1,%eax
  8013b4:	89 d1                	mov    %edx,%ecx
  8013b6:	89 d3                	mov    %edx,%ebx
  8013b8:	89 d7                	mov    %edx,%edi
  8013ba:	89 d6                	mov    %edx,%esi
  8013bc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8013be:	5b                   	pop    %ebx
  8013bf:	5e                   	pop    %esi
  8013c0:	5f                   	pop    %edi
  8013c1:	5d                   	pop    %ebp
  8013c2:	c3                   	ret    

008013c3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8013c3:	55                   	push   %ebp
  8013c4:	89 e5                	mov    %esp,%ebp
  8013c6:	57                   	push   %edi
  8013c7:	56                   	push   %esi
  8013c8:	53                   	push   %ebx
  8013c9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013d1:	b8 03 00 00 00       	mov    $0x3,%eax
  8013d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8013d9:	89 cb                	mov    %ecx,%ebx
  8013db:	89 cf                	mov    %ecx,%edi
  8013dd:	89 ce                	mov    %ecx,%esi
  8013df:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8013e1:	85 c0                	test   %eax,%eax
  8013e3:	7e 28                	jle    80140d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013e5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013e9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8013f0:	00 
  8013f1:	c7 44 24 08 1f 36 80 	movl   $0x80361f,0x8(%esp)
  8013f8:	00 
  8013f9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801400:	00 
  801401:	c7 04 24 3c 36 80 00 	movl   $0x80363c,(%esp)
  801408:	e8 01 f5 ff ff       	call   80090e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80140d:	83 c4 2c             	add    $0x2c,%esp
  801410:	5b                   	pop    %ebx
  801411:	5e                   	pop    %esi
  801412:	5f                   	pop    %edi
  801413:	5d                   	pop    %ebp
  801414:	c3                   	ret    

00801415 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	57                   	push   %edi
  801419:	56                   	push   %esi
  80141a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80141b:	ba 00 00 00 00       	mov    $0x0,%edx
  801420:	b8 02 00 00 00       	mov    $0x2,%eax
  801425:	89 d1                	mov    %edx,%ecx
  801427:	89 d3                	mov    %edx,%ebx
  801429:	89 d7                	mov    %edx,%edi
  80142b:	89 d6                	mov    %edx,%esi
  80142d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80142f:	5b                   	pop    %ebx
  801430:	5e                   	pop    %esi
  801431:	5f                   	pop    %edi
  801432:	5d                   	pop    %ebp
  801433:	c3                   	ret    

00801434 <sys_yield>:

void
sys_yield(void)
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	57                   	push   %edi
  801438:	56                   	push   %esi
  801439:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80143a:	ba 00 00 00 00       	mov    $0x0,%edx
  80143f:	b8 0b 00 00 00       	mov    $0xb,%eax
  801444:	89 d1                	mov    %edx,%ecx
  801446:	89 d3                	mov    %edx,%ebx
  801448:	89 d7                	mov    %edx,%edi
  80144a:	89 d6                	mov    %edx,%esi
  80144c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80144e:	5b                   	pop    %ebx
  80144f:	5e                   	pop    %esi
  801450:	5f                   	pop    %edi
  801451:	5d                   	pop    %ebp
  801452:	c3                   	ret    

00801453 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801453:	55                   	push   %ebp
  801454:	89 e5                	mov    %esp,%ebp
  801456:	57                   	push   %edi
  801457:	56                   	push   %esi
  801458:	53                   	push   %ebx
  801459:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80145c:	be 00 00 00 00       	mov    $0x0,%esi
  801461:	b8 04 00 00 00       	mov    $0x4,%eax
  801466:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801469:	8b 55 08             	mov    0x8(%ebp),%edx
  80146c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80146f:	89 f7                	mov    %esi,%edi
  801471:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801473:	85 c0                	test   %eax,%eax
  801475:	7e 28                	jle    80149f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801477:	89 44 24 10          	mov    %eax,0x10(%esp)
  80147b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801482:	00 
  801483:	c7 44 24 08 1f 36 80 	movl   $0x80361f,0x8(%esp)
  80148a:	00 
  80148b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801492:	00 
  801493:	c7 04 24 3c 36 80 00 	movl   $0x80363c,(%esp)
  80149a:	e8 6f f4 ff ff       	call   80090e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80149f:	83 c4 2c             	add    $0x2c,%esp
  8014a2:	5b                   	pop    %ebx
  8014a3:	5e                   	pop    %esi
  8014a4:	5f                   	pop    %edi
  8014a5:	5d                   	pop    %ebp
  8014a6:	c3                   	ret    

008014a7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8014a7:	55                   	push   %ebp
  8014a8:	89 e5                	mov    %esp,%ebp
  8014aa:	57                   	push   %edi
  8014ab:	56                   	push   %esi
  8014ac:	53                   	push   %ebx
  8014ad:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014b0:	b8 05 00 00 00       	mov    $0x5,%eax
  8014b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8014bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8014be:	8b 7d 14             	mov    0x14(%ebp),%edi
  8014c1:	8b 75 18             	mov    0x18(%ebp),%esi
  8014c4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8014c6:	85 c0                	test   %eax,%eax
  8014c8:	7e 28                	jle    8014f2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014ca:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014ce:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8014d5:	00 
  8014d6:	c7 44 24 08 1f 36 80 	movl   $0x80361f,0x8(%esp)
  8014dd:	00 
  8014de:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014e5:	00 
  8014e6:	c7 04 24 3c 36 80 00 	movl   $0x80363c,(%esp)
  8014ed:	e8 1c f4 ff ff       	call   80090e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8014f2:	83 c4 2c             	add    $0x2c,%esp
  8014f5:	5b                   	pop    %ebx
  8014f6:	5e                   	pop    %esi
  8014f7:	5f                   	pop    %edi
  8014f8:	5d                   	pop    %ebp
  8014f9:	c3                   	ret    

008014fa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	57                   	push   %edi
  8014fe:	56                   	push   %esi
  8014ff:	53                   	push   %ebx
  801500:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801503:	bb 00 00 00 00       	mov    $0x0,%ebx
  801508:	b8 06 00 00 00       	mov    $0x6,%eax
  80150d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801510:	8b 55 08             	mov    0x8(%ebp),%edx
  801513:	89 df                	mov    %ebx,%edi
  801515:	89 de                	mov    %ebx,%esi
  801517:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801519:	85 c0                	test   %eax,%eax
  80151b:	7e 28                	jle    801545 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80151d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801521:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801528:	00 
  801529:	c7 44 24 08 1f 36 80 	movl   $0x80361f,0x8(%esp)
  801530:	00 
  801531:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801538:	00 
  801539:	c7 04 24 3c 36 80 00 	movl   $0x80363c,(%esp)
  801540:	e8 c9 f3 ff ff       	call   80090e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801545:	83 c4 2c             	add    $0x2c,%esp
  801548:	5b                   	pop    %ebx
  801549:	5e                   	pop    %esi
  80154a:	5f                   	pop    %edi
  80154b:	5d                   	pop    %ebp
  80154c:	c3                   	ret    

0080154d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80154d:	55                   	push   %ebp
  80154e:	89 e5                	mov    %esp,%ebp
  801550:	57                   	push   %edi
  801551:	56                   	push   %esi
  801552:	53                   	push   %ebx
  801553:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801556:	bb 00 00 00 00       	mov    $0x0,%ebx
  80155b:	b8 08 00 00 00       	mov    $0x8,%eax
  801560:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801563:	8b 55 08             	mov    0x8(%ebp),%edx
  801566:	89 df                	mov    %ebx,%edi
  801568:	89 de                	mov    %ebx,%esi
  80156a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80156c:	85 c0                	test   %eax,%eax
  80156e:	7e 28                	jle    801598 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801570:	89 44 24 10          	mov    %eax,0x10(%esp)
  801574:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80157b:	00 
  80157c:	c7 44 24 08 1f 36 80 	movl   $0x80361f,0x8(%esp)
  801583:	00 
  801584:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80158b:	00 
  80158c:	c7 04 24 3c 36 80 00 	movl   $0x80363c,(%esp)
  801593:	e8 76 f3 ff ff       	call   80090e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801598:	83 c4 2c             	add    $0x2c,%esp
  80159b:	5b                   	pop    %ebx
  80159c:	5e                   	pop    %esi
  80159d:	5f                   	pop    %edi
  80159e:	5d                   	pop    %ebp
  80159f:	c3                   	ret    

008015a0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8015a0:	55                   	push   %ebp
  8015a1:	89 e5                	mov    %esp,%ebp
  8015a3:	57                   	push   %edi
  8015a4:	56                   	push   %esi
  8015a5:	53                   	push   %ebx
  8015a6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015ae:	b8 09 00 00 00       	mov    $0x9,%eax
  8015b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8015b9:	89 df                	mov    %ebx,%edi
  8015bb:	89 de                	mov    %ebx,%esi
  8015bd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	7e 28                	jle    8015eb <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015c3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015c7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8015ce:	00 
  8015cf:	c7 44 24 08 1f 36 80 	movl   $0x80361f,0x8(%esp)
  8015d6:	00 
  8015d7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8015de:	00 
  8015df:	c7 04 24 3c 36 80 00 	movl   $0x80363c,(%esp)
  8015e6:	e8 23 f3 ff ff       	call   80090e <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8015eb:	83 c4 2c             	add    $0x2c,%esp
  8015ee:	5b                   	pop    %ebx
  8015ef:	5e                   	pop    %esi
  8015f0:	5f                   	pop    %edi
  8015f1:	5d                   	pop    %ebp
  8015f2:	c3                   	ret    

008015f3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8015f3:	55                   	push   %ebp
  8015f4:	89 e5                	mov    %esp,%ebp
  8015f6:	57                   	push   %edi
  8015f7:	56                   	push   %esi
  8015f8:	53                   	push   %ebx
  8015f9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801601:	b8 0a 00 00 00       	mov    $0xa,%eax
  801606:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801609:	8b 55 08             	mov    0x8(%ebp),%edx
  80160c:	89 df                	mov    %ebx,%edi
  80160e:	89 de                	mov    %ebx,%esi
  801610:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801612:	85 c0                	test   %eax,%eax
  801614:	7e 28                	jle    80163e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801616:	89 44 24 10          	mov    %eax,0x10(%esp)
  80161a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801621:	00 
  801622:	c7 44 24 08 1f 36 80 	movl   $0x80361f,0x8(%esp)
  801629:	00 
  80162a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801631:	00 
  801632:	c7 04 24 3c 36 80 00 	movl   $0x80363c,(%esp)
  801639:	e8 d0 f2 ff ff       	call   80090e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80163e:	83 c4 2c             	add    $0x2c,%esp
  801641:	5b                   	pop    %ebx
  801642:	5e                   	pop    %esi
  801643:	5f                   	pop    %edi
  801644:	5d                   	pop    %ebp
  801645:	c3                   	ret    

00801646 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	57                   	push   %edi
  80164a:	56                   	push   %esi
  80164b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80164c:	be 00 00 00 00       	mov    $0x0,%esi
  801651:	b8 0c 00 00 00       	mov    $0xc,%eax
  801656:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801659:	8b 55 08             	mov    0x8(%ebp),%edx
  80165c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80165f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801662:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801664:	5b                   	pop    %ebx
  801665:	5e                   	pop    %esi
  801666:	5f                   	pop    %edi
  801667:	5d                   	pop    %ebp
  801668:	c3                   	ret    

00801669 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801669:	55                   	push   %ebp
  80166a:	89 e5                	mov    %esp,%ebp
  80166c:	57                   	push   %edi
  80166d:	56                   	push   %esi
  80166e:	53                   	push   %ebx
  80166f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801672:	b9 00 00 00 00       	mov    $0x0,%ecx
  801677:	b8 0d 00 00 00       	mov    $0xd,%eax
  80167c:	8b 55 08             	mov    0x8(%ebp),%edx
  80167f:	89 cb                	mov    %ecx,%ebx
  801681:	89 cf                	mov    %ecx,%edi
  801683:	89 ce                	mov    %ecx,%esi
  801685:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801687:	85 c0                	test   %eax,%eax
  801689:	7e 28                	jle    8016b3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80168b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80168f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801696:	00 
  801697:	c7 44 24 08 1f 36 80 	movl   $0x80361f,0x8(%esp)
  80169e:	00 
  80169f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8016a6:	00 
  8016a7:	c7 04 24 3c 36 80 00 	movl   $0x80363c,(%esp)
  8016ae:	e8 5b f2 ff ff       	call   80090e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8016b3:	83 c4 2c             	add    $0x2c,%esp
  8016b6:	5b                   	pop    %ebx
  8016b7:	5e                   	pop    %esi
  8016b8:	5f                   	pop    %edi
  8016b9:	5d                   	pop    %ebp
  8016ba:	c3                   	ret    

008016bb <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	57                   	push   %edi
  8016bf:	56                   	push   %esi
  8016c0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c6:	b8 0e 00 00 00       	mov    $0xe,%eax
  8016cb:	89 d1                	mov    %edx,%ecx
  8016cd:	89 d3                	mov    %edx,%ebx
  8016cf:	89 d7                	mov    %edx,%edi
  8016d1:	89 d6                	mov    %edx,%esi
  8016d3:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8016d5:	5b                   	pop    %ebx
  8016d6:	5e                   	pop    %esi
  8016d7:	5f                   	pop    %edi
  8016d8:	5d                   	pop    %ebp
  8016d9:	c3                   	ret    

008016da <sys_try_send_packet>:

int
sys_try_send_packet(void* packetva, int size)
{
  8016da:	55                   	push   %ebp
  8016db:	89 e5                	mov    %esp,%ebp
  8016dd:	57                   	push   %edi
  8016de:	56                   	push   %esi
  8016df:	53                   	push   %ebx
  8016e0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016e8:	b8 0f 00 00 00       	mov    $0xf,%eax
  8016ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8016f3:	89 df                	mov    %ebx,%edi
  8016f5:	89 de                	mov    %ebx,%esi
  8016f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	7e 28                	jle    801725 <sys_try_send_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  801701:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801708:	00 
  801709:	c7 44 24 08 1f 36 80 	movl   $0x80361f,0x8(%esp)
  801710:	00 
  801711:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801718:	00 
  801719:	c7 04 24 3c 36 80 00 	movl   $0x80363c,(%esp)
  801720:	e8 e9 f1 ff ff       	call   80090e <_panic>

int
sys_try_send_packet(void* packetva, int size)
{
	return syscall(SYS_try_send_packet, 1, (uint32_t) packetva, size, 0, 0, 0);
}
  801725:	83 c4 2c             	add    $0x2c,%esp
  801728:	5b                   	pop    %ebx
  801729:	5e                   	pop    %esi
  80172a:	5f                   	pop    %edi
  80172b:	5d                   	pop    %ebp
  80172c:	c3                   	ret    

0080172d <sys_try_recv_packet>:

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	57                   	push   %edi
  801731:	56                   	push   %esi
  801732:	53                   	push   %ebx
  801733:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801736:	bb 00 00 00 00       	mov    $0x0,%ebx
  80173b:	b8 10 00 00 00       	mov    $0x10,%eax
  801740:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801743:	8b 55 08             	mov    0x8(%ebp),%edx
  801746:	89 df                	mov    %ebx,%edi
  801748:	89 de                	mov    %ebx,%esi
  80174a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80174c:	85 c0                	test   %eax,%eax
  80174e:	7e 28                	jle    801778 <sys_try_recv_packet+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801750:	89 44 24 10          	mov    %eax,0x10(%esp)
  801754:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
  80175b:	00 
  80175c:	c7 44 24 08 1f 36 80 	movl   $0x80361f,0x8(%esp)
  801763:	00 
  801764:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80176b:	00 
  80176c:	c7 04 24 3c 36 80 00 	movl   $0x80363c,(%esp)
  801773:	e8 96 f1 ff ff       	call   80090e <_panic>

int
sys_try_recv_packet(void** packet_dst, int* size_store)
{
	return syscall(SYS_try_recv_packet, 1, (uint32_t) packet_dst, (uint32_t)size_store, 0, 0, 0);
}
  801778:	83 c4 2c             	add    $0x2c,%esp
  80177b:	5b                   	pop    %ebx
  80177c:	5e                   	pop    %esi
  80177d:	5f                   	pop    %edi
  80177e:	5d                   	pop    %ebp
  80177f:	c3                   	ret    

00801780 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801783:	8b 45 08             	mov    0x8(%ebp),%eax
  801786:	05 00 00 00 30       	add    $0x30000000,%eax
  80178b:	c1 e8 0c             	shr    $0xc,%eax
}
  80178e:	5d                   	pop    %ebp
  80178f:	c3                   	ret    

00801790 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801793:	8b 45 08             	mov    0x8(%ebp),%eax
  801796:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80179b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8017a0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8017a5:	5d                   	pop    %ebp
  8017a6:	c3                   	ret    

008017a7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8017a7:	55                   	push   %ebp
  8017a8:	89 e5                	mov    %esp,%ebp
  8017aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017ad:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8017b2:	89 c2                	mov    %eax,%edx
  8017b4:	c1 ea 16             	shr    $0x16,%edx
  8017b7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8017be:	f6 c2 01             	test   $0x1,%dl
  8017c1:	74 11                	je     8017d4 <fd_alloc+0x2d>
  8017c3:	89 c2                	mov    %eax,%edx
  8017c5:	c1 ea 0c             	shr    $0xc,%edx
  8017c8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017cf:	f6 c2 01             	test   $0x1,%dl
  8017d2:	75 09                	jne    8017dd <fd_alloc+0x36>
			*fd_store = fd;
  8017d4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8017d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8017db:	eb 17                	jmp    8017f4 <fd_alloc+0x4d>
  8017dd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8017e2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8017e7:	75 c9                	jne    8017b2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8017e9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8017ef:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8017f4:	5d                   	pop    %ebp
  8017f5:	c3                   	ret    

008017f6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8017f6:	55                   	push   %ebp
  8017f7:	89 e5                	mov    %esp,%ebp
  8017f9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8017fc:	83 f8 1f             	cmp    $0x1f,%eax
  8017ff:	77 36                	ja     801837 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801801:	c1 e0 0c             	shl    $0xc,%eax
  801804:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801809:	89 c2                	mov    %eax,%edx
  80180b:	c1 ea 16             	shr    $0x16,%edx
  80180e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801815:	f6 c2 01             	test   $0x1,%dl
  801818:	74 24                	je     80183e <fd_lookup+0x48>
  80181a:	89 c2                	mov    %eax,%edx
  80181c:	c1 ea 0c             	shr    $0xc,%edx
  80181f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801826:	f6 c2 01             	test   $0x1,%dl
  801829:	74 1a                	je     801845 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80182b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80182e:	89 02                	mov    %eax,(%edx)
	return 0;
  801830:	b8 00 00 00 00       	mov    $0x0,%eax
  801835:	eb 13                	jmp    80184a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801837:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80183c:	eb 0c                	jmp    80184a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80183e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801843:	eb 05                	jmp    80184a <fd_lookup+0x54>
  801845:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80184a:	5d                   	pop    %ebp
  80184b:	c3                   	ret    

0080184c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	83 ec 18             	sub    $0x18,%esp
  801852:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801855:	ba 00 00 00 00       	mov    $0x0,%edx
  80185a:	eb 13                	jmp    80186f <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  80185c:	39 08                	cmp    %ecx,(%eax)
  80185e:	75 0c                	jne    80186c <dev_lookup+0x20>
			*dev = devtab[i];
  801860:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801863:	89 01                	mov    %eax,(%ecx)
			return 0;
  801865:	b8 00 00 00 00       	mov    $0x0,%eax
  80186a:	eb 38                	jmp    8018a4 <dev_lookup+0x58>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80186c:	83 c2 01             	add    $0x1,%edx
  80186f:	8b 04 95 c8 36 80 00 	mov    0x8036c8(,%edx,4),%eax
  801876:	85 c0                	test   %eax,%eax
  801878:	75 e2                	jne    80185c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80187a:	a1 1c 50 80 00       	mov    0x80501c,%eax
  80187f:	8b 40 48             	mov    0x48(%eax),%eax
  801882:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801886:	89 44 24 04          	mov    %eax,0x4(%esp)
  80188a:	c7 04 24 4c 36 80 00 	movl   $0x80364c,(%esp)
  801891:	e8 71 f1 ff ff       	call   800a07 <cprintf>
	*dev = 0;
  801896:	8b 45 0c             	mov    0xc(%ebp),%eax
  801899:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80189f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8018a4:	c9                   	leave  
  8018a5:	c3                   	ret    

008018a6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
  8018a9:	56                   	push   %esi
  8018aa:	53                   	push   %ebx
  8018ab:	83 ec 20             	sub    $0x20,%esp
  8018ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8018b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8018b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b7:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8018bb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8018c1:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8018c4:	89 04 24             	mov    %eax,(%esp)
  8018c7:	e8 2a ff ff ff       	call   8017f6 <fd_lookup>
  8018cc:	85 c0                	test   %eax,%eax
  8018ce:	78 05                	js     8018d5 <fd_close+0x2f>
	    || fd != fd2)
  8018d0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8018d3:	74 0c                	je     8018e1 <fd_close+0x3b>
		return (must_exist ? r : 0);
  8018d5:	84 db                	test   %bl,%bl
  8018d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018dc:	0f 44 c2             	cmove  %edx,%eax
  8018df:	eb 3f                	jmp    801920 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8018e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e8:	8b 06                	mov    (%esi),%eax
  8018ea:	89 04 24             	mov    %eax,(%esp)
  8018ed:	e8 5a ff ff ff       	call   80184c <dev_lookup>
  8018f2:	89 c3                	mov    %eax,%ebx
  8018f4:	85 c0                	test   %eax,%eax
  8018f6:	78 16                	js     80190e <fd_close+0x68>
		if (dev->dev_close)
  8018f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018fb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8018fe:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801903:	85 c0                	test   %eax,%eax
  801905:	74 07                	je     80190e <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801907:	89 34 24             	mov    %esi,(%esp)
  80190a:	ff d0                	call   *%eax
  80190c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80190e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801912:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801919:	e8 dc fb ff ff       	call   8014fa <sys_page_unmap>
	return r;
  80191e:	89 d8                	mov    %ebx,%eax
}
  801920:	83 c4 20             	add    $0x20,%esp
  801923:	5b                   	pop    %ebx
  801924:	5e                   	pop    %esi
  801925:	5d                   	pop    %ebp
  801926:	c3                   	ret    

00801927 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801927:	55                   	push   %ebp
  801928:	89 e5                	mov    %esp,%ebp
  80192a:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80192d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801930:	89 44 24 04          	mov    %eax,0x4(%esp)
  801934:	8b 45 08             	mov    0x8(%ebp),%eax
  801937:	89 04 24             	mov    %eax,(%esp)
  80193a:	e8 b7 fe ff ff       	call   8017f6 <fd_lookup>
  80193f:	89 c2                	mov    %eax,%edx
  801941:	85 d2                	test   %edx,%edx
  801943:	78 13                	js     801958 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801945:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80194c:	00 
  80194d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801950:	89 04 24             	mov    %eax,(%esp)
  801953:	e8 4e ff ff ff       	call   8018a6 <fd_close>
}
  801958:	c9                   	leave  
  801959:	c3                   	ret    

0080195a <close_all>:

void
close_all(void)
{
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	53                   	push   %ebx
  80195e:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801961:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801966:	89 1c 24             	mov    %ebx,(%esp)
  801969:	e8 b9 ff ff ff       	call   801927 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80196e:	83 c3 01             	add    $0x1,%ebx
  801971:	83 fb 20             	cmp    $0x20,%ebx
  801974:	75 f0                	jne    801966 <close_all+0xc>
		close(i);
}
  801976:	83 c4 14             	add    $0x14,%esp
  801979:	5b                   	pop    %ebx
  80197a:	5d                   	pop    %ebp
  80197b:	c3                   	ret    

0080197c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80197c:	55                   	push   %ebp
  80197d:	89 e5                	mov    %esp,%ebp
  80197f:	57                   	push   %edi
  801980:	56                   	push   %esi
  801981:	53                   	push   %ebx
  801982:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801985:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801988:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198c:	8b 45 08             	mov    0x8(%ebp),%eax
  80198f:	89 04 24             	mov    %eax,(%esp)
  801992:	e8 5f fe ff ff       	call   8017f6 <fd_lookup>
  801997:	89 c2                	mov    %eax,%edx
  801999:	85 d2                	test   %edx,%edx
  80199b:	0f 88 e1 00 00 00    	js     801a82 <dup+0x106>
		return r;
	close(newfdnum);
  8019a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a4:	89 04 24             	mov    %eax,(%esp)
  8019a7:	e8 7b ff ff ff       	call   801927 <close>

	newfd = INDEX2FD(newfdnum);
  8019ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019af:	c1 e3 0c             	shl    $0xc,%ebx
  8019b2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8019b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019bb:	89 04 24             	mov    %eax,(%esp)
  8019be:	e8 cd fd ff ff       	call   801790 <fd2data>
  8019c3:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8019c5:	89 1c 24             	mov    %ebx,(%esp)
  8019c8:	e8 c3 fd ff ff       	call   801790 <fd2data>
  8019cd:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8019cf:	89 f0                	mov    %esi,%eax
  8019d1:	c1 e8 16             	shr    $0x16,%eax
  8019d4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8019db:	a8 01                	test   $0x1,%al
  8019dd:	74 43                	je     801a22 <dup+0xa6>
  8019df:	89 f0                	mov    %esi,%eax
  8019e1:	c1 e8 0c             	shr    $0xc,%eax
  8019e4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8019eb:	f6 c2 01             	test   $0x1,%dl
  8019ee:	74 32                	je     801a22 <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8019f0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019f7:	25 07 0e 00 00       	and    $0xe07,%eax
  8019fc:	89 44 24 10          	mov    %eax,0x10(%esp)
  801a00:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a04:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a0b:	00 
  801a0c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a10:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a17:	e8 8b fa ff ff       	call   8014a7 <sys_page_map>
  801a1c:	89 c6                	mov    %eax,%esi
  801a1e:	85 c0                	test   %eax,%eax
  801a20:	78 3e                	js     801a60 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801a22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a25:	89 c2                	mov    %eax,%edx
  801a27:	c1 ea 0c             	shr    $0xc,%edx
  801a2a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801a31:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801a37:	89 54 24 10          	mov    %edx,0x10(%esp)
  801a3b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801a3f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a46:	00 
  801a47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a52:	e8 50 fa ff ff       	call   8014a7 <sys_page_map>
  801a57:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801a59:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801a5c:	85 f6                	test   %esi,%esi
  801a5e:	79 22                	jns    801a82 <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801a60:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a64:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a6b:	e8 8a fa ff ff       	call   8014fa <sys_page_unmap>
	sys_page_unmap(0, nva);
  801a70:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a7b:	e8 7a fa ff ff       	call   8014fa <sys_page_unmap>
	return r;
  801a80:	89 f0                	mov    %esi,%eax
}
  801a82:	83 c4 3c             	add    $0x3c,%esp
  801a85:	5b                   	pop    %ebx
  801a86:	5e                   	pop    %esi
  801a87:	5f                   	pop    %edi
  801a88:	5d                   	pop    %ebp
  801a89:	c3                   	ret    

00801a8a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801a8a:	55                   	push   %ebp
  801a8b:	89 e5                	mov    %esp,%ebp
  801a8d:	53                   	push   %ebx
  801a8e:	83 ec 24             	sub    $0x24,%esp
  801a91:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a94:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a97:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a9b:	89 1c 24             	mov    %ebx,(%esp)
  801a9e:	e8 53 fd ff ff       	call   8017f6 <fd_lookup>
  801aa3:	89 c2                	mov    %eax,%edx
  801aa5:	85 d2                	test   %edx,%edx
  801aa7:	78 6d                	js     801b16 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801aa9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aac:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ab3:	8b 00                	mov    (%eax),%eax
  801ab5:	89 04 24             	mov    %eax,(%esp)
  801ab8:	e8 8f fd ff ff       	call   80184c <dev_lookup>
  801abd:	85 c0                	test   %eax,%eax
  801abf:	78 55                	js     801b16 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801ac1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ac4:	8b 50 08             	mov    0x8(%eax),%edx
  801ac7:	83 e2 03             	and    $0x3,%edx
  801aca:	83 fa 01             	cmp    $0x1,%edx
  801acd:	75 23                	jne    801af2 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801acf:	a1 1c 50 80 00       	mov    0x80501c,%eax
  801ad4:	8b 40 48             	mov    0x48(%eax),%eax
  801ad7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801adb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801adf:	c7 04 24 8d 36 80 00 	movl   $0x80368d,(%esp)
  801ae6:	e8 1c ef ff ff       	call   800a07 <cprintf>
		return -E_INVAL;
  801aeb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801af0:	eb 24                	jmp    801b16 <read+0x8c>
	}
	if (!dev->dev_read)
  801af2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801af5:	8b 52 08             	mov    0x8(%edx),%edx
  801af8:	85 d2                	test   %edx,%edx
  801afa:	74 15                	je     801b11 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801afc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801aff:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b06:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b0a:	89 04 24             	mov    %eax,(%esp)
  801b0d:	ff d2                	call   *%edx
  801b0f:	eb 05                	jmp    801b16 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801b11:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801b16:	83 c4 24             	add    $0x24,%esp
  801b19:	5b                   	pop    %ebx
  801b1a:	5d                   	pop    %ebp
  801b1b:	c3                   	ret    

00801b1c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801b1c:	55                   	push   %ebp
  801b1d:	89 e5                	mov    %esp,%ebp
  801b1f:	57                   	push   %edi
  801b20:	56                   	push   %esi
  801b21:	53                   	push   %ebx
  801b22:	83 ec 1c             	sub    $0x1c,%esp
  801b25:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b28:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801b2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b30:	eb 23                	jmp    801b55 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801b32:	89 f0                	mov    %esi,%eax
  801b34:	29 d8                	sub    %ebx,%eax
  801b36:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b3a:	89 d8                	mov    %ebx,%eax
  801b3c:	03 45 0c             	add    0xc(%ebp),%eax
  801b3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b43:	89 3c 24             	mov    %edi,(%esp)
  801b46:	e8 3f ff ff ff       	call   801a8a <read>
		if (m < 0)
  801b4b:	85 c0                	test   %eax,%eax
  801b4d:	78 10                	js     801b5f <readn+0x43>
			return m;
		if (m == 0)
  801b4f:	85 c0                	test   %eax,%eax
  801b51:	74 0a                	je     801b5d <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801b53:	01 c3                	add    %eax,%ebx
  801b55:	39 f3                	cmp    %esi,%ebx
  801b57:	72 d9                	jb     801b32 <readn+0x16>
  801b59:	89 d8                	mov    %ebx,%eax
  801b5b:	eb 02                	jmp    801b5f <readn+0x43>
  801b5d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801b5f:	83 c4 1c             	add    $0x1c,%esp
  801b62:	5b                   	pop    %ebx
  801b63:	5e                   	pop    %esi
  801b64:	5f                   	pop    %edi
  801b65:	5d                   	pop    %ebp
  801b66:	c3                   	ret    

00801b67 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801b67:	55                   	push   %ebp
  801b68:	89 e5                	mov    %esp,%ebp
  801b6a:	53                   	push   %ebx
  801b6b:	83 ec 24             	sub    $0x24,%esp
  801b6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b71:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b74:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b78:	89 1c 24             	mov    %ebx,(%esp)
  801b7b:	e8 76 fc ff ff       	call   8017f6 <fd_lookup>
  801b80:	89 c2                	mov    %eax,%edx
  801b82:	85 d2                	test   %edx,%edx
  801b84:	78 68                	js     801bee <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b89:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b90:	8b 00                	mov    (%eax),%eax
  801b92:	89 04 24             	mov    %eax,(%esp)
  801b95:	e8 b2 fc ff ff       	call   80184c <dev_lookup>
  801b9a:	85 c0                	test   %eax,%eax
  801b9c:	78 50                	js     801bee <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ba1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801ba5:	75 23                	jne    801bca <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801ba7:	a1 1c 50 80 00       	mov    0x80501c,%eax
  801bac:	8b 40 48             	mov    0x48(%eax),%eax
  801baf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb7:	c7 04 24 a9 36 80 00 	movl   $0x8036a9,(%esp)
  801bbe:	e8 44 ee ff ff       	call   800a07 <cprintf>
		return -E_INVAL;
  801bc3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801bc8:	eb 24                	jmp    801bee <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801bca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bcd:	8b 52 0c             	mov    0xc(%edx),%edx
  801bd0:	85 d2                	test   %edx,%edx
  801bd2:	74 15                	je     801be9 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801bd4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801bd7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801bdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bde:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801be2:	89 04 24             	mov    %eax,(%esp)
  801be5:	ff d2                	call   *%edx
  801be7:	eb 05                	jmp    801bee <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801be9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801bee:	83 c4 24             	add    $0x24,%esp
  801bf1:	5b                   	pop    %ebx
  801bf2:	5d                   	pop    %ebp
  801bf3:	c3                   	ret    

00801bf4 <seek>:

int
seek(int fdnum, off_t offset)
{
  801bf4:	55                   	push   %ebp
  801bf5:	89 e5                	mov    %esp,%ebp
  801bf7:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bfa:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801bfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c01:	8b 45 08             	mov    0x8(%ebp),%eax
  801c04:	89 04 24             	mov    %eax,(%esp)
  801c07:	e8 ea fb ff ff       	call   8017f6 <fd_lookup>
  801c0c:	85 c0                	test   %eax,%eax
  801c0e:	78 0e                	js     801c1e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801c10:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801c13:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c16:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801c19:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c1e:	c9                   	leave  
  801c1f:	c3                   	ret    

00801c20 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	53                   	push   %ebx
  801c24:	83 ec 24             	sub    $0x24,%esp
  801c27:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c2a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c31:	89 1c 24             	mov    %ebx,(%esp)
  801c34:	e8 bd fb ff ff       	call   8017f6 <fd_lookup>
  801c39:	89 c2                	mov    %eax,%edx
  801c3b:	85 d2                	test   %edx,%edx
  801c3d:	78 61                	js     801ca0 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c42:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c46:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c49:	8b 00                	mov    (%eax),%eax
  801c4b:	89 04 24             	mov    %eax,(%esp)
  801c4e:	e8 f9 fb ff ff       	call   80184c <dev_lookup>
  801c53:	85 c0                	test   %eax,%eax
  801c55:	78 49                	js     801ca0 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801c57:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c5a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801c5e:	75 23                	jne    801c83 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801c60:	a1 1c 50 80 00       	mov    0x80501c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801c65:	8b 40 48             	mov    0x48(%eax),%eax
  801c68:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c70:	c7 04 24 6c 36 80 00 	movl   $0x80366c,(%esp)
  801c77:	e8 8b ed ff ff       	call   800a07 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801c7c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c81:	eb 1d                	jmp    801ca0 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801c83:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c86:	8b 52 18             	mov    0x18(%edx),%edx
  801c89:	85 d2                	test   %edx,%edx
  801c8b:	74 0e                	je     801c9b <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801c8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c90:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801c94:	89 04 24             	mov    %eax,(%esp)
  801c97:	ff d2                	call   *%edx
  801c99:	eb 05                	jmp    801ca0 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801c9b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801ca0:	83 c4 24             	add    $0x24,%esp
  801ca3:	5b                   	pop    %ebx
  801ca4:	5d                   	pop    %ebp
  801ca5:	c3                   	ret    

00801ca6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801ca6:	55                   	push   %ebp
  801ca7:	89 e5                	mov    %esp,%ebp
  801ca9:	53                   	push   %ebx
  801caa:	83 ec 24             	sub    $0x24,%esp
  801cad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801cb0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cba:	89 04 24             	mov    %eax,(%esp)
  801cbd:	e8 34 fb ff ff       	call   8017f6 <fd_lookup>
  801cc2:	89 c2                	mov    %eax,%edx
  801cc4:	85 d2                	test   %edx,%edx
  801cc6:	78 52                	js     801d1a <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801cc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ccb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ccf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cd2:	8b 00                	mov    (%eax),%eax
  801cd4:	89 04 24             	mov    %eax,(%esp)
  801cd7:	e8 70 fb ff ff       	call   80184c <dev_lookup>
  801cdc:	85 c0                	test   %eax,%eax
  801cde:	78 3a                	js     801d1a <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801ce7:	74 2c                	je     801d15 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801ce9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801cec:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801cf3:	00 00 00 
	stat->st_isdir = 0;
  801cf6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cfd:	00 00 00 
	stat->st_dev = dev;
  801d00:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801d06:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d0a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d0d:	89 14 24             	mov    %edx,(%esp)
  801d10:	ff 50 14             	call   *0x14(%eax)
  801d13:	eb 05                	jmp    801d1a <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801d15:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801d1a:	83 c4 24             	add    $0x24,%esp
  801d1d:	5b                   	pop    %ebx
  801d1e:	5d                   	pop    %ebp
  801d1f:	c3                   	ret    

00801d20 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
  801d23:	56                   	push   %esi
  801d24:	53                   	push   %ebx
  801d25:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801d28:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d2f:	00 
  801d30:	8b 45 08             	mov    0x8(%ebp),%eax
  801d33:	89 04 24             	mov    %eax,(%esp)
  801d36:	e8 28 02 00 00       	call   801f63 <open>
  801d3b:	89 c3                	mov    %eax,%ebx
  801d3d:	85 db                	test   %ebx,%ebx
  801d3f:	78 1b                	js     801d5c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801d41:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d44:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d48:	89 1c 24             	mov    %ebx,(%esp)
  801d4b:	e8 56 ff ff ff       	call   801ca6 <fstat>
  801d50:	89 c6                	mov    %eax,%esi
	close(fd);
  801d52:	89 1c 24             	mov    %ebx,(%esp)
  801d55:	e8 cd fb ff ff       	call   801927 <close>
	return r;
  801d5a:	89 f0                	mov    %esi,%eax
}
  801d5c:	83 c4 10             	add    $0x10,%esp
  801d5f:	5b                   	pop    %ebx
  801d60:	5e                   	pop    %esi
  801d61:	5d                   	pop    %ebp
  801d62:	c3                   	ret    

00801d63 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801d63:	55                   	push   %ebp
  801d64:	89 e5                	mov    %esp,%ebp
  801d66:	56                   	push   %esi
  801d67:	53                   	push   %ebx
  801d68:	83 ec 10             	sub    $0x10,%esp
  801d6b:	89 c6                	mov    %eax,%esi
  801d6d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801d6f:	83 3d 10 50 80 00 00 	cmpl   $0x0,0x805010
  801d76:	75 11                	jne    801d89 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801d78:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801d7f:	e8 41 10 00 00       	call   802dc5 <ipc_find_env>
  801d84:	a3 10 50 80 00       	mov    %eax,0x805010
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801d89:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d90:	00 
  801d91:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801d98:	00 
  801d99:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d9d:	a1 10 50 80 00       	mov    0x805010,%eax
  801da2:	89 04 24             	mov    %eax,(%esp)
  801da5:	e8 b0 0f 00 00       	call   802d5a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801daa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801db1:	00 
  801db2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801db6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dbd:	e8 1e 0f 00 00       	call   802ce0 <ipc_recv>
}
  801dc2:	83 c4 10             	add    $0x10,%esp
  801dc5:	5b                   	pop    %ebx
  801dc6:	5e                   	pop    %esi
  801dc7:	5d                   	pop    %ebp
  801dc8:	c3                   	ret    

00801dc9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801dc9:	55                   	push   %ebp
  801dca:	89 e5                	mov    %esp,%ebp
  801dcc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801dcf:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd2:	8b 40 0c             	mov    0xc(%eax),%eax
  801dd5:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801dda:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ddd:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801de2:	ba 00 00 00 00       	mov    $0x0,%edx
  801de7:	b8 02 00 00 00       	mov    $0x2,%eax
  801dec:	e8 72 ff ff ff       	call   801d63 <fsipc>
}
  801df1:	c9                   	leave  
  801df2:	c3                   	ret    

00801df3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801df3:	55                   	push   %ebp
  801df4:	89 e5                	mov    %esp,%ebp
  801df6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801df9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfc:	8b 40 0c             	mov    0xc(%eax),%eax
  801dff:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801e04:	ba 00 00 00 00       	mov    $0x0,%edx
  801e09:	b8 06 00 00 00       	mov    $0x6,%eax
  801e0e:	e8 50 ff ff ff       	call   801d63 <fsipc>
}
  801e13:	c9                   	leave  
  801e14:	c3                   	ret    

00801e15 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801e15:	55                   	push   %ebp
  801e16:	89 e5                	mov    %esp,%ebp
  801e18:	53                   	push   %ebx
  801e19:	83 ec 14             	sub    $0x14,%esp
  801e1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801e1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e22:	8b 40 0c             	mov    0xc(%eax),%eax
  801e25:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801e2a:	ba 00 00 00 00       	mov    $0x0,%edx
  801e2f:	b8 05 00 00 00       	mov    $0x5,%eax
  801e34:	e8 2a ff ff ff       	call   801d63 <fsipc>
  801e39:	89 c2                	mov    %eax,%edx
  801e3b:	85 d2                	test   %edx,%edx
  801e3d:	78 2b                	js     801e6a <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801e3f:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e46:	00 
  801e47:	89 1c 24             	mov    %ebx,(%esp)
  801e4a:	e8 e8 f1 ff ff       	call   801037 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801e4f:	a1 80 60 80 00       	mov    0x806080,%eax
  801e54:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801e5a:	a1 84 60 80 00       	mov    0x806084,%eax
  801e5f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801e65:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e6a:	83 c4 14             	add    $0x14,%esp
  801e6d:	5b                   	pop    %ebx
  801e6e:	5d                   	pop    %ebp
  801e6f:	c3                   	ret    

00801e70 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801e70:	55                   	push   %ebp
  801e71:	89 e5                	mov    %esp,%ebp
  801e73:	83 ec 18             	sub    $0x18,%esp
  801e76:	8b 45 10             	mov    0x10(%ebp),%eax
  801e79:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801e7e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801e83:	0f 47 c2             	cmova  %edx,%eax
	int r;
	int buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	if(buf_size < n) n = buf_size;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801e86:	8b 55 08             	mov    0x8(%ebp),%edx
  801e89:	8b 52 0c             	mov    0xc(%edx),%edx
  801e8c:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801e92:	a3 04 60 80 00       	mov    %eax,0x806004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801e97:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ea2:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801ea9:	e8 26 f3 ff ff       	call   8011d4 <memmove>

	return fsipc(FSREQ_WRITE, NULL);
  801eae:	ba 00 00 00 00       	mov    $0x0,%edx
  801eb3:	b8 04 00 00 00       	mov    $0x4,%eax
  801eb8:	e8 a6 fe ff ff       	call   801d63 <fsipc>
}
  801ebd:	c9                   	leave  
  801ebe:	c3                   	ret    

00801ebf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801ebf:	55                   	push   %ebp
  801ec0:	89 e5                	mov    %esp,%ebp
  801ec2:	56                   	push   %esi
  801ec3:	53                   	push   %ebx
  801ec4:	83 ec 10             	sub    $0x10,%esp
  801ec7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801eca:	8b 45 08             	mov    0x8(%ebp),%eax
  801ecd:	8b 40 0c             	mov    0xc(%eax),%eax
  801ed0:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801ed5:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801edb:	ba 00 00 00 00       	mov    $0x0,%edx
  801ee0:	b8 03 00 00 00       	mov    $0x3,%eax
  801ee5:	e8 79 fe ff ff       	call   801d63 <fsipc>
  801eea:	89 c3                	mov    %eax,%ebx
  801eec:	85 c0                	test   %eax,%eax
  801eee:	78 6a                	js     801f5a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801ef0:	39 c6                	cmp    %eax,%esi
  801ef2:	73 24                	jae    801f18 <devfile_read+0x59>
  801ef4:	c7 44 24 0c dc 36 80 	movl   $0x8036dc,0xc(%esp)
  801efb:	00 
  801efc:	c7 44 24 08 e3 36 80 	movl   $0x8036e3,0x8(%esp)
  801f03:	00 
  801f04:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801f0b:	00 
  801f0c:	c7 04 24 f8 36 80 00 	movl   $0x8036f8,(%esp)
  801f13:	e8 f6 e9 ff ff       	call   80090e <_panic>
	assert(r <= PGSIZE);
  801f18:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801f1d:	7e 24                	jle    801f43 <devfile_read+0x84>
  801f1f:	c7 44 24 0c 03 37 80 	movl   $0x803703,0xc(%esp)
  801f26:	00 
  801f27:	c7 44 24 08 e3 36 80 	movl   $0x8036e3,0x8(%esp)
  801f2e:	00 
  801f2f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801f36:	00 
  801f37:	c7 04 24 f8 36 80 00 	movl   $0x8036f8,(%esp)
  801f3e:	e8 cb e9 ff ff       	call   80090e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801f43:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f47:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801f4e:	00 
  801f4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f52:	89 04 24             	mov    %eax,(%esp)
  801f55:	e8 7a f2 ff ff       	call   8011d4 <memmove>
	return r;
}
  801f5a:	89 d8                	mov    %ebx,%eax
  801f5c:	83 c4 10             	add    $0x10,%esp
  801f5f:	5b                   	pop    %ebx
  801f60:	5e                   	pop    %esi
  801f61:	5d                   	pop    %ebp
  801f62:	c3                   	ret    

00801f63 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801f63:	55                   	push   %ebp
  801f64:	89 e5                	mov    %esp,%ebp
  801f66:	53                   	push   %ebx
  801f67:	83 ec 24             	sub    $0x24,%esp
  801f6a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801f6d:	89 1c 24             	mov    %ebx,(%esp)
  801f70:	e8 8b f0 ff ff       	call   801000 <strlen>
  801f75:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801f7a:	7f 60                	jg     801fdc <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801f7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f7f:	89 04 24             	mov    %eax,(%esp)
  801f82:	e8 20 f8 ff ff       	call   8017a7 <fd_alloc>
  801f87:	89 c2                	mov    %eax,%edx
  801f89:	85 d2                	test   %edx,%edx
  801f8b:	78 54                	js     801fe1 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801f8d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f91:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801f98:	e8 9a f0 ff ff       	call   801037 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801f9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa0:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801fa5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fa8:	b8 01 00 00 00       	mov    $0x1,%eax
  801fad:	e8 b1 fd ff ff       	call   801d63 <fsipc>
  801fb2:	89 c3                	mov    %eax,%ebx
  801fb4:	85 c0                	test   %eax,%eax
  801fb6:	79 17                	jns    801fcf <open+0x6c>
		fd_close(fd, 0);
  801fb8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801fbf:	00 
  801fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc3:	89 04 24             	mov    %eax,(%esp)
  801fc6:	e8 db f8 ff ff       	call   8018a6 <fd_close>
		return r;
  801fcb:	89 d8                	mov    %ebx,%eax
  801fcd:	eb 12                	jmp    801fe1 <open+0x7e>
	}

	return fd2num(fd);
  801fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd2:	89 04 24             	mov    %eax,(%esp)
  801fd5:	e8 a6 f7 ff ff       	call   801780 <fd2num>
  801fda:	eb 05                	jmp    801fe1 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801fdc:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801fe1:	83 c4 24             	add    $0x24,%esp
  801fe4:	5b                   	pop    %ebx
  801fe5:	5d                   	pop    %ebp
  801fe6:	c3                   	ret    

00801fe7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801fe7:	55                   	push   %ebp
  801fe8:	89 e5                	mov    %esp,%ebp
  801fea:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801fed:	ba 00 00 00 00       	mov    $0x0,%edx
  801ff2:	b8 08 00 00 00       	mov    $0x8,%eax
  801ff7:	e8 67 fd ff ff       	call   801d63 <fsipc>
}
  801ffc:	c9                   	leave  
  801ffd:	c3                   	ret    
  801ffe:	66 90                	xchg   %ax,%ax

00802000 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802000:	55                   	push   %ebp
  802001:	89 e5                	mov    %esp,%ebp
  802003:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  802006:	c7 44 24 04 0f 37 80 	movl   $0x80370f,0x4(%esp)
  80200d:	00 
  80200e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802011:	89 04 24             	mov    %eax,(%esp)
  802014:	e8 1e f0 ff ff       	call   801037 <strcpy>
	return 0;
}
  802019:	b8 00 00 00 00       	mov    $0x0,%eax
  80201e:	c9                   	leave  
  80201f:	c3                   	ret    

00802020 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	53                   	push   %ebx
  802024:	83 ec 14             	sub    $0x14,%esp
  802027:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80202a:	89 1c 24             	mov    %ebx,(%esp)
  80202d:	e8 cb 0d 00 00       	call   802dfd <pageref>
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  802032:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  802037:	83 f8 01             	cmp    $0x1,%eax
  80203a:	75 0d                	jne    802049 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80203c:	8b 43 0c             	mov    0xc(%ebx),%eax
  80203f:	89 04 24             	mov    %eax,(%esp)
  802042:	e8 29 03 00 00       	call   802370 <nsipc_close>
  802047:	89 c2                	mov    %eax,%edx
	else
		return 0;
}
  802049:	89 d0                	mov    %edx,%eax
  80204b:	83 c4 14             	add    $0x14,%esp
  80204e:	5b                   	pop    %ebx
  80204f:	5d                   	pop    %ebp
  802050:	c3                   	ret    

00802051 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802051:	55                   	push   %ebp
  802052:	89 e5                	mov    %esp,%ebp
  802054:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802057:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80205e:	00 
  80205f:	8b 45 10             	mov    0x10(%ebp),%eax
  802062:	89 44 24 08          	mov    %eax,0x8(%esp)
  802066:	8b 45 0c             	mov    0xc(%ebp),%eax
  802069:	89 44 24 04          	mov    %eax,0x4(%esp)
  80206d:	8b 45 08             	mov    0x8(%ebp),%eax
  802070:	8b 40 0c             	mov    0xc(%eax),%eax
  802073:	89 04 24             	mov    %eax,(%esp)
  802076:	e8 f0 03 00 00       	call   80246b <nsipc_send>
}
  80207b:	c9                   	leave  
  80207c:	c3                   	ret    

0080207d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80207d:	55                   	push   %ebp
  80207e:	89 e5                	mov    %esp,%ebp
  802080:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802083:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80208a:	00 
  80208b:	8b 45 10             	mov    0x10(%ebp),%eax
  80208e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802092:	8b 45 0c             	mov    0xc(%ebp),%eax
  802095:	89 44 24 04          	mov    %eax,0x4(%esp)
  802099:	8b 45 08             	mov    0x8(%ebp),%eax
  80209c:	8b 40 0c             	mov    0xc(%eax),%eax
  80209f:	89 04 24             	mov    %eax,(%esp)
  8020a2:	e8 44 03 00 00       	call   8023eb <nsipc_recv>
}
  8020a7:	c9                   	leave  
  8020a8:	c3                   	ret    

008020a9 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8020a9:	55                   	push   %ebp
  8020aa:	89 e5                	mov    %esp,%ebp
  8020ac:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8020af:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8020b2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020b6:	89 04 24             	mov    %eax,(%esp)
  8020b9:	e8 38 f7 ff ff       	call   8017f6 <fd_lookup>
  8020be:	85 c0                	test   %eax,%eax
  8020c0:	78 17                	js     8020d9 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8020c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c5:	8b 0d 40 40 80 00    	mov    0x804040,%ecx
  8020cb:	39 08                	cmp    %ecx,(%eax)
  8020cd:	75 05                	jne    8020d4 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8020cf:	8b 40 0c             	mov    0xc(%eax),%eax
  8020d2:	eb 05                	jmp    8020d9 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8020d4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8020d9:	c9                   	leave  
  8020da:	c3                   	ret    

008020db <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8020db:	55                   	push   %ebp
  8020dc:	89 e5                	mov    %esp,%ebp
  8020de:	56                   	push   %esi
  8020df:	53                   	push   %ebx
  8020e0:	83 ec 20             	sub    $0x20,%esp
  8020e3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8020e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020e8:	89 04 24             	mov    %eax,(%esp)
  8020eb:	e8 b7 f6 ff ff       	call   8017a7 <fd_alloc>
  8020f0:	89 c3                	mov    %eax,%ebx
  8020f2:	85 c0                	test   %eax,%eax
  8020f4:	78 21                	js     802117 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8020f6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020fd:	00 
  8020fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802101:	89 44 24 04          	mov    %eax,0x4(%esp)
  802105:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80210c:	e8 42 f3 ff ff       	call   801453 <sys_page_alloc>
  802111:	89 c3                	mov    %eax,%ebx
  802113:	85 c0                	test   %eax,%eax
  802115:	79 0c                	jns    802123 <alloc_sockfd+0x48>
		nsipc_close(sockid);
  802117:	89 34 24             	mov    %esi,(%esp)
  80211a:	e8 51 02 00 00       	call   802370 <nsipc_close>
		return r;
  80211f:	89 d8                	mov    %ebx,%eax
  802121:	eb 20                	jmp    802143 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802123:	8b 15 40 40 80 00    	mov    0x804040,%edx
  802129:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80212c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80212e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802131:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  802138:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  80213b:	89 14 24             	mov    %edx,(%esp)
  80213e:	e8 3d f6 ff ff       	call   801780 <fd2num>
}
  802143:	83 c4 20             	add    $0x20,%esp
  802146:	5b                   	pop    %ebx
  802147:	5e                   	pop    %esi
  802148:	5d                   	pop    %ebp
  802149:	c3                   	ret    

0080214a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80214a:	55                   	push   %ebp
  80214b:	89 e5                	mov    %esp,%ebp
  80214d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802150:	8b 45 08             	mov    0x8(%ebp),%eax
  802153:	e8 51 ff ff ff       	call   8020a9 <fd2sockid>
		return r;
  802158:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80215a:	85 c0                	test   %eax,%eax
  80215c:	78 23                	js     802181 <accept+0x37>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80215e:	8b 55 10             	mov    0x10(%ebp),%edx
  802161:	89 54 24 08          	mov    %edx,0x8(%esp)
  802165:	8b 55 0c             	mov    0xc(%ebp),%edx
  802168:	89 54 24 04          	mov    %edx,0x4(%esp)
  80216c:	89 04 24             	mov    %eax,(%esp)
  80216f:	e8 45 01 00 00       	call   8022b9 <nsipc_accept>
		return r;
  802174:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802176:	85 c0                	test   %eax,%eax
  802178:	78 07                	js     802181 <accept+0x37>
		return r;
	return alloc_sockfd(r);
  80217a:	e8 5c ff ff ff       	call   8020db <alloc_sockfd>
  80217f:	89 c1                	mov    %eax,%ecx
}
  802181:	89 c8                	mov    %ecx,%eax
  802183:	c9                   	leave  
  802184:	c3                   	ret    

00802185 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802185:	55                   	push   %ebp
  802186:	89 e5                	mov    %esp,%ebp
  802188:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80218b:	8b 45 08             	mov    0x8(%ebp),%eax
  80218e:	e8 16 ff ff ff       	call   8020a9 <fd2sockid>
  802193:	89 c2                	mov    %eax,%edx
  802195:	85 d2                	test   %edx,%edx
  802197:	78 16                	js     8021af <bind+0x2a>
		return r;
	return nsipc_bind(r, name, namelen);
  802199:	8b 45 10             	mov    0x10(%ebp),%eax
  80219c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021a7:	89 14 24             	mov    %edx,(%esp)
  8021aa:	e8 60 01 00 00       	call   80230f <nsipc_bind>
}
  8021af:	c9                   	leave  
  8021b0:	c3                   	ret    

008021b1 <shutdown>:

int
shutdown(int s, int how)
{
  8021b1:	55                   	push   %ebp
  8021b2:	89 e5                	mov    %esp,%ebp
  8021b4:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ba:	e8 ea fe ff ff       	call   8020a9 <fd2sockid>
  8021bf:	89 c2                	mov    %eax,%edx
  8021c1:	85 d2                	test   %edx,%edx
  8021c3:	78 0f                	js     8021d4 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  8021c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021cc:	89 14 24             	mov    %edx,(%esp)
  8021cf:	e8 7a 01 00 00       	call   80234e <nsipc_shutdown>
}
  8021d4:	c9                   	leave  
  8021d5:	c3                   	ret    

008021d6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8021d6:	55                   	push   %ebp
  8021d7:	89 e5                	mov    %esp,%ebp
  8021d9:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8021df:	e8 c5 fe ff ff       	call   8020a9 <fd2sockid>
  8021e4:	89 c2                	mov    %eax,%edx
  8021e6:	85 d2                	test   %edx,%edx
  8021e8:	78 16                	js     802200 <connect+0x2a>
		return r;
	return nsipc_connect(r, name, namelen);
  8021ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8021ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021f8:	89 14 24             	mov    %edx,(%esp)
  8021fb:	e8 8a 01 00 00       	call   80238a <nsipc_connect>
}
  802200:	c9                   	leave  
  802201:	c3                   	ret    

00802202 <listen>:

int
listen(int s, int backlog)
{
  802202:	55                   	push   %ebp
  802203:	89 e5                	mov    %esp,%ebp
  802205:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802208:	8b 45 08             	mov    0x8(%ebp),%eax
  80220b:	e8 99 fe ff ff       	call   8020a9 <fd2sockid>
  802210:	89 c2                	mov    %eax,%edx
  802212:	85 d2                	test   %edx,%edx
  802214:	78 0f                	js     802225 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  802216:	8b 45 0c             	mov    0xc(%ebp),%eax
  802219:	89 44 24 04          	mov    %eax,0x4(%esp)
  80221d:	89 14 24             	mov    %edx,(%esp)
  802220:	e8 a4 01 00 00       	call   8023c9 <nsipc_listen>
}
  802225:	c9                   	leave  
  802226:	c3                   	ret    

00802227 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802227:	55                   	push   %ebp
  802228:	89 e5                	mov    %esp,%ebp
  80222a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80222d:	8b 45 10             	mov    0x10(%ebp),%eax
  802230:	89 44 24 08          	mov    %eax,0x8(%esp)
  802234:	8b 45 0c             	mov    0xc(%ebp),%eax
  802237:	89 44 24 04          	mov    %eax,0x4(%esp)
  80223b:	8b 45 08             	mov    0x8(%ebp),%eax
  80223e:	89 04 24             	mov    %eax,(%esp)
  802241:	e8 98 02 00 00       	call   8024de <nsipc_socket>
  802246:	89 c2                	mov    %eax,%edx
  802248:	85 d2                	test   %edx,%edx
  80224a:	78 05                	js     802251 <socket+0x2a>
		return r;
	return alloc_sockfd(r);
  80224c:	e8 8a fe ff ff       	call   8020db <alloc_sockfd>
}
  802251:	c9                   	leave  
  802252:	c3                   	ret    

00802253 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802253:	55                   	push   %ebp
  802254:	89 e5                	mov    %esp,%ebp
  802256:	53                   	push   %ebx
  802257:	83 ec 14             	sub    $0x14,%esp
  80225a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80225c:	83 3d 14 50 80 00 00 	cmpl   $0x0,0x805014
  802263:	75 11                	jne    802276 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802265:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80226c:	e8 54 0b 00 00       	call   802dc5 <ipc_find_env>
  802271:	a3 14 50 80 00       	mov    %eax,0x805014
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802276:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80227d:	00 
  80227e:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802285:	00 
  802286:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80228a:	a1 14 50 80 00       	mov    0x805014,%eax
  80228f:	89 04 24             	mov    %eax,(%esp)
  802292:	e8 c3 0a 00 00       	call   802d5a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802297:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80229e:	00 
  80229f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8022a6:	00 
  8022a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022ae:	e8 2d 0a 00 00       	call   802ce0 <ipc_recv>
}
  8022b3:	83 c4 14             	add    $0x14,%esp
  8022b6:	5b                   	pop    %ebx
  8022b7:	5d                   	pop    %ebp
  8022b8:	c3                   	ret    

008022b9 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8022b9:	55                   	push   %ebp
  8022ba:	89 e5                	mov    %esp,%ebp
  8022bc:	56                   	push   %esi
  8022bd:	53                   	push   %ebx
  8022be:	83 ec 10             	sub    $0x10,%esp
  8022c1:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8022c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8022c7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8022cc:	8b 06                	mov    (%esi),%eax
  8022ce:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8022d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8022d8:	e8 76 ff ff ff       	call   802253 <nsipc>
  8022dd:	89 c3                	mov    %eax,%ebx
  8022df:	85 c0                	test   %eax,%eax
  8022e1:	78 23                	js     802306 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8022e3:	a1 10 70 80 00       	mov    0x807010,%eax
  8022e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022ec:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8022f3:	00 
  8022f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022f7:	89 04 24             	mov    %eax,(%esp)
  8022fa:	e8 d5 ee ff ff       	call   8011d4 <memmove>
		*addrlen = ret->ret_addrlen;
  8022ff:	a1 10 70 80 00       	mov    0x807010,%eax
  802304:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  802306:	89 d8                	mov    %ebx,%eax
  802308:	83 c4 10             	add    $0x10,%esp
  80230b:	5b                   	pop    %ebx
  80230c:	5e                   	pop    %esi
  80230d:	5d                   	pop    %ebp
  80230e:	c3                   	ret    

0080230f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80230f:	55                   	push   %ebp
  802310:	89 e5                	mov    %esp,%ebp
  802312:	53                   	push   %ebx
  802313:	83 ec 14             	sub    $0x14,%esp
  802316:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802319:	8b 45 08             	mov    0x8(%ebp),%eax
  80231c:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802321:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802325:	8b 45 0c             	mov    0xc(%ebp),%eax
  802328:	89 44 24 04          	mov    %eax,0x4(%esp)
  80232c:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802333:	e8 9c ee ff ff       	call   8011d4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802338:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80233e:	b8 02 00 00 00       	mov    $0x2,%eax
  802343:	e8 0b ff ff ff       	call   802253 <nsipc>
}
  802348:	83 c4 14             	add    $0x14,%esp
  80234b:	5b                   	pop    %ebx
  80234c:	5d                   	pop    %ebp
  80234d:	c3                   	ret    

0080234e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80234e:	55                   	push   %ebp
  80234f:	89 e5                	mov    %esp,%ebp
  802351:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802354:	8b 45 08             	mov    0x8(%ebp),%eax
  802357:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80235c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80235f:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802364:	b8 03 00 00 00       	mov    $0x3,%eax
  802369:	e8 e5 fe ff ff       	call   802253 <nsipc>
}
  80236e:	c9                   	leave  
  80236f:	c3                   	ret    

00802370 <nsipc_close>:

int
nsipc_close(int s)
{
  802370:	55                   	push   %ebp
  802371:	89 e5                	mov    %esp,%ebp
  802373:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802376:	8b 45 08             	mov    0x8(%ebp),%eax
  802379:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  80237e:	b8 04 00 00 00       	mov    $0x4,%eax
  802383:	e8 cb fe ff ff       	call   802253 <nsipc>
}
  802388:	c9                   	leave  
  802389:	c3                   	ret    

0080238a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80238a:	55                   	push   %ebp
  80238b:	89 e5                	mov    %esp,%ebp
  80238d:	53                   	push   %ebx
  80238e:	83 ec 14             	sub    $0x14,%esp
  802391:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802394:	8b 45 08             	mov    0x8(%ebp),%eax
  802397:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80239c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023a7:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8023ae:	e8 21 ee ff ff       	call   8011d4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8023b3:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8023b9:	b8 05 00 00 00       	mov    $0x5,%eax
  8023be:	e8 90 fe ff ff       	call   802253 <nsipc>
}
  8023c3:	83 c4 14             	add    $0x14,%esp
  8023c6:	5b                   	pop    %ebx
  8023c7:	5d                   	pop    %ebp
  8023c8:	c3                   	ret    

008023c9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8023c9:	55                   	push   %ebp
  8023ca:	89 e5                	mov    %esp,%ebp
  8023cc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8023cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8023d2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8023d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023da:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8023df:	b8 06 00 00 00       	mov    $0x6,%eax
  8023e4:	e8 6a fe ff ff       	call   802253 <nsipc>
}
  8023e9:	c9                   	leave  
  8023ea:	c3                   	ret    

008023eb <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8023eb:	55                   	push   %ebp
  8023ec:	89 e5                	mov    %esp,%ebp
  8023ee:	56                   	push   %esi
  8023ef:	53                   	push   %ebx
  8023f0:	83 ec 10             	sub    $0x10,%esp
  8023f3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8023f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8023fe:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802404:	8b 45 14             	mov    0x14(%ebp),%eax
  802407:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80240c:	b8 07 00 00 00       	mov    $0x7,%eax
  802411:	e8 3d fe ff ff       	call   802253 <nsipc>
  802416:	89 c3                	mov    %eax,%ebx
  802418:	85 c0                	test   %eax,%eax
  80241a:	78 46                	js     802462 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  80241c:	39 f0                	cmp    %esi,%eax
  80241e:	7f 07                	jg     802427 <nsipc_recv+0x3c>
  802420:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802425:	7e 24                	jle    80244b <nsipc_recv+0x60>
  802427:	c7 44 24 0c 1b 37 80 	movl   $0x80371b,0xc(%esp)
  80242e:	00 
  80242f:	c7 44 24 08 e3 36 80 	movl   $0x8036e3,0x8(%esp)
  802436:	00 
  802437:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80243e:	00 
  80243f:	c7 04 24 30 37 80 00 	movl   $0x803730,(%esp)
  802446:	e8 c3 e4 ff ff       	call   80090e <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80244b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80244f:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802456:	00 
  802457:	8b 45 0c             	mov    0xc(%ebp),%eax
  80245a:	89 04 24             	mov    %eax,(%esp)
  80245d:	e8 72 ed ff ff       	call   8011d4 <memmove>
	}

	return r;
}
  802462:	89 d8                	mov    %ebx,%eax
  802464:	83 c4 10             	add    $0x10,%esp
  802467:	5b                   	pop    %ebx
  802468:	5e                   	pop    %esi
  802469:	5d                   	pop    %ebp
  80246a:	c3                   	ret    

0080246b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80246b:	55                   	push   %ebp
  80246c:	89 e5                	mov    %esp,%ebp
  80246e:	53                   	push   %ebx
  80246f:	83 ec 14             	sub    $0x14,%esp
  802472:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802475:	8b 45 08             	mov    0x8(%ebp),%eax
  802478:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  80247d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802483:	7e 24                	jle    8024a9 <nsipc_send+0x3e>
  802485:	c7 44 24 0c 3c 37 80 	movl   $0x80373c,0xc(%esp)
  80248c:	00 
  80248d:	c7 44 24 08 e3 36 80 	movl   $0x8036e3,0x8(%esp)
  802494:	00 
  802495:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  80249c:	00 
  80249d:	c7 04 24 30 37 80 00 	movl   $0x803730,(%esp)
  8024a4:	e8 65 e4 ff ff       	call   80090e <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8024a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024b4:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  8024bb:	e8 14 ed ff ff       	call   8011d4 <memmove>
	nsipcbuf.send.req_size = size;
  8024c0:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8024c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8024c9:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8024ce:	b8 08 00 00 00       	mov    $0x8,%eax
  8024d3:	e8 7b fd ff ff       	call   802253 <nsipc>
}
  8024d8:	83 c4 14             	add    $0x14,%esp
  8024db:	5b                   	pop    %ebx
  8024dc:	5d                   	pop    %ebp
  8024dd:	c3                   	ret    

008024de <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8024de:	55                   	push   %ebp
  8024df:	89 e5                	mov    %esp,%ebp
  8024e1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8024e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8024e7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8024ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024ef:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8024f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8024f7:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8024fc:	b8 09 00 00 00       	mov    $0x9,%eax
  802501:	e8 4d fd ff ff       	call   802253 <nsipc>
}
  802506:	c9                   	leave  
  802507:	c3                   	ret    
  802508:	66 90                	xchg   %ax,%ax
  80250a:	66 90                	xchg   %ax,%ax
  80250c:	66 90                	xchg   %ax,%ax
  80250e:	66 90                	xchg   %ax,%ax

00802510 <free>:
	return v;
}

void
free(void *v)
{
  802510:	55                   	push   %ebp
  802511:	89 e5                	mov    %esp,%ebp
  802513:	53                   	push   %ebx
  802514:	83 ec 14             	sub    $0x14,%esp
  802517:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint8_t *c;
	uint32_t *ref;

	if (v == 0)
  80251a:	85 db                	test   %ebx,%ebx
  80251c:	0f 84 ba 00 00 00    	je     8025dc <free+0xcc>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);
  802522:	81 fb ff ff ff 07    	cmp    $0x7ffffff,%ebx
  802528:	76 08                	jbe    802532 <free+0x22>
  80252a:	81 fb ff ff ff 0f    	cmp    $0xfffffff,%ebx
  802530:	76 24                	jbe    802556 <free+0x46>
  802532:	c7 44 24 0c 48 37 80 	movl   $0x803748,0xc(%esp)
  802539:	00 
  80253a:	c7 44 24 08 e3 36 80 	movl   $0x8036e3,0x8(%esp)
  802541:	00 
  802542:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  802549:	00 
  80254a:	c7 04 24 76 37 80 00 	movl   $0x803776,(%esp)
  802551:	e8 b8 e3 ff ff       	call   80090e <_panic>

	c = ROUNDDOWN(v, PGSIZE);
  802556:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

	while (uvpt[PGNUM(c)] & PTE_CONTINUED) {
  80255c:	eb 4a                	jmp    8025a8 <free+0x98>
		sys_page_unmap(0, c);
  80255e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802562:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802569:	e8 8c ef ff ff       	call   8014fa <sys_page_unmap>
		c += PGSIZE;
  80256e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		assert(mbegin <= c && c < mend);
  802574:	81 fb ff ff ff 07    	cmp    $0x7ffffff,%ebx
  80257a:	76 08                	jbe    802584 <free+0x74>
  80257c:	81 fb ff ff ff 0f    	cmp    $0xfffffff,%ebx
  802582:	76 24                	jbe    8025a8 <free+0x98>
  802584:	c7 44 24 0c 83 37 80 	movl   $0x803783,0xc(%esp)
  80258b:	00 
  80258c:	c7 44 24 08 e3 36 80 	movl   $0x8036e3,0x8(%esp)
  802593:	00 
  802594:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
  80259b:	00 
  80259c:	c7 04 24 76 37 80 00 	movl   $0x803776,(%esp)
  8025a3:	e8 66 e3 ff ff       	call   80090e <_panic>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);

	c = ROUNDDOWN(v, PGSIZE);

	while (uvpt[PGNUM(c)] & PTE_CONTINUED) {
  8025a8:	89 d8                	mov    %ebx,%eax
  8025aa:	c1 e8 0c             	shr    $0xc,%eax
  8025ad:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8025b4:	f6 c4 02             	test   $0x2,%ah
  8025b7:	75 a5                	jne    80255e <free+0x4e>
	/*
	 * c is just a piece of this page, so dec the ref count
	 * and maybe free the page.
	 */
	ref = (uint32_t*) (c + PGSIZE - 4);
	if (--(*ref) == 0)
  8025b9:	8b 83 fc 0f 00 00    	mov    0xffc(%ebx),%eax
  8025bf:	83 e8 01             	sub    $0x1,%eax
  8025c2:	89 83 fc 0f 00 00    	mov    %eax,0xffc(%ebx)
  8025c8:	85 c0                	test   %eax,%eax
  8025ca:	75 10                	jne    8025dc <free+0xcc>
		sys_page_unmap(0, c);
  8025cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8025d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025d7:	e8 1e ef ff ff       	call   8014fa <sys_page_unmap>
}
  8025dc:	83 c4 14             	add    $0x14,%esp
  8025df:	5b                   	pop    %ebx
  8025e0:	5d                   	pop    %ebp
  8025e1:	c3                   	ret    

008025e2 <malloc>:
	return 1;
}

void*
malloc(size_t n)
{
  8025e2:	55                   	push   %ebp
  8025e3:	89 e5                	mov    %esp,%ebp
  8025e5:	57                   	push   %edi
  8025e6:	56                   	push   %esi
  8025e7:	53                   	push   %ebx
  8025e8:	83 ec 2c             	sub    $0x2c,%esp
	int i, cont;
	int nwrap;
	uint32_t *ref;
	void *v;

	if (mptr == 0)
  8025eb:	83 3d 18 50 80 00 00 	cmpl   $0x0,0x805018
  8025f2:	75 0a                	jne    8025fe <malloc+0x1c>
		mptr = mbegin;
  8025f4:	c7 05 18 50 80 00 00 	movl   $0x8000000,0x805018
  8025fb:	00 00 08 

	n = ROUNDUP(n, 4);
  8025fe:	8b 45 08             	mov    0x8(%ebp),%eax
  802601:	83 c0 03             	add    $0x3,%eax
  802604:	83 e0 fc             	and    $0xfffffffc,%eax
  802607:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if (n >= MAXMALLOC)
  80260a:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
  80260f:	0f 87 64 01 00 00    	ja     802779 <malloc+0x197>
		return 0;

	if ((uintptr_t) mptr % PGSIZE){
  802615:	a1 18 50 80 00       	mov    0x805018,%eax
  80261a:	a9 ff 0f 00 00       	test   $0xfff,%eax
  80261f:	75 15                	jne    802636 <malloc+0x54>
  802621:	8b 35 18 50 80 00    	mov    0x805018,%esi
	return 1;
}

void*
malloc(size_t n)
{
  802627:	c7 45 dc 02 00 00 00 	movl   $0x2,-0x24(%ebp)
	 * runs of more than a page can't have ref counts so we
	 * flag the PTE entries instead.
	 */
	nwrap = 0;
	while (1) {
		if (isfree(mptr, n + 4))
  80262e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802631:	8d 78 04             	lea    0x4(%eax),%edi
  802634:	eb 50                	jmp    802686 <malloc+0xa4>
		 * we're in the middle of a partially
		 * allocated page - can we add this chunk?
		 * the +4 below is for the ref count.
		 */
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
  802636:	89 c1                	mov    %eax,%ecx
  802638:	c1 e9 0c             	shr    $0xc,%ecx
  80263b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80263e:	8d 54 18 03          	lea    0x3(%eax,%ebx,1),%edx
  802642:	c1 ea 0c             	shr    $0xc,%edx
  802645:	39 d1                	cmp    %edx,%ecx
  802647:	75 1f                	jne    802668 <malloc+0x86>
		/*
		 * we're in the middle of a partially
		 * allocated page - can we add this chunk?
		 * the +4 below is for the ref count.
		 */
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
  802649:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  80264f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
			(*ref)++;
  802655:	83 42 fc 01          	addl   $0x1,-0x4(%edx)
			v = mptr;
			mptr += n;
  802659:	89 da                	mov    %ebx,%edx
  80265b:	01 c2                	add    %eax,%edx
  80265d:	89 15 18 50 80 00    	mov    %edx,0x805018
			return v;
  802663:	e9 2f 01 00 00       	jmp    802797 <malloc+0x1b5>
		}
		/*
		 * stop working on this page and move on.
		 */
		free(mptr);	/* drop reference to this page */
  802668:	89 04 24             	mov    %eax,(%esp)
  80266b:	e8 a0 fe ff ff       	call   802510 <free>
		mptr = ROUNDDOWN(mptr + PGSIZE, PGSIZE);
  802670:	a1 18 50 80 00       	mov    0x805018,%eax
  802675:	05 00 10 00 00       	add    $0x1000,%eax
  80267a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80267f:	a3 18 50 80 00       	mov    %eax,0x805018
  802684:	eb 9b                	jmp    802621 <malloc+0x3f>
  802686:	89 75 e4             	mov    %esi,-0x1c(%ebp)
	 * runs of more than a page can't have ref counts so we
	 * flag the PTE entries instead.
	 */
	nwrap = 0;
	while (1) {
		if (isfree(mptr, n + 4))
  802689:	89 fb                	mov    %edi,%ebx
  80268b:	8d 0c 37             	lea    (%edi,%esi,1),%ecx
static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  80268e:	89 f0                	mov    %esi,%eax
  802690:	eb 36                	jmp    8026c8 <malloc+0xe6>
		if (va >= (uintptr_t) mend
  802692:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
  802697:	0f 87 e3 00 00 00    	ja     802780 <malloc+0x19e>
		    || ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P)))
  80269d:	89 c2                	mov    %eax,%edx
  80269f:	c1 ea 16             	shr    $0x16,%edx
  8026a2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8026a9:	f6 c2 01             	test   $0x1,%dl
  8026ac:	74 15                	je     8026c3 <malloc+0xe1>
  8026ae:	89 c2                	mov    %eax,%edx
  8026b0:	c1 ea 0c             	shr    $0xc,%edx
  8026b3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8026ba:	f6 c2 01             	test   $0x1,%dl
  8026bd:	0f 85 bd 00 00 00    	jne    802780 <malloc+0x19e>
static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  8026c3:	05 00 10 00 00       	add    $0x1000,%eax
  8026c8:	39 c1                	cmp    %eax,%ecx
  8026ca:	77 c6                	ja     802692 <malloc+0xb0>
  8026cc:	eb 7e                	jmp    80274c <malloc+0x16a>
		if (isfree(mptr, n + 4))
			break;
		mptr += PGSIZE;
		if (mptr == mend) {
			mptr = mbegin;
			if (++nwrap == 2)
  8026ce:	83 6d dc 01          	subl   $0x1,-0x24(%ebp)
  8026d2:	74 07                	je     8026db <malloc+0xf9>
	while (1) {
		if (isfree(mptr, n + 4))
			break;
		mptr += PGSIZE;
		if (mptr == mend) {
			mptr = mbegin;
  8026d4:	be 00 00 00 08       	mov    $0x8000000,%esi
  8026d9:	eb ab                	jmp    802686 <malloc+0xa4>
  8026db:	c7 05 18 50 80 00 00 	movl   $0x8000000,0x805018
  8026e2:	00 00 08 
			if (++nwrap == 2)
				return 0;	/* out of address space */
  8026e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8026ea:	e9 a8 00 00 00       	jmp    802797 <malloc+0x1b5>

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
  8026ef:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
  8026f5:	39 df                	cmp    %ebx,%edi
  8026f7:	19 c0                	sbb    %eax,%eax
  8026f9:	25 00 02 00 00       	and    $0x200,%eax
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
  8026fe:	83 c8 07             	or     $0x7,%eax
  802701:	89 44 24 08          	mov    %eax,0x8(%esp)
  802705:	03 15 18 50 80 00    	add    0x805018,%edx
  80270b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80270f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802716:	e8 38 ed ff ff       	call   801453 <sys_page_alloc>
  80271b:	85 c0                	test   %eax,%eax
  80271d:	78 22                	js     802741 <malloc+0x15f>
	}

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
  80271f:	89 fe                	mov    %edi,%esi
  802721:	eb 36                	jmp    802759 <malloc+0x177>
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
			for (; i >= 0; i -= PGSIZE)
				sys_page_unmap(0, mptr + i);
  802723:	89 f0                	mov    %esi,%eax
  802725:	03 05 18 50 80 00    	add    0x805018,%eax
  80272b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80272f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802736:	e8 bf ed ff ff       	call   8014fa <sys_page_unmap>
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
			for (; i >= 0; i -= PGSIZE)
  80273b:	81 ee 00 10 00 00    	sub    $0x1000,%esi
  802741:	85 f6                	test   %esi,%esi
  802743:	79 de                	jns    802723 <malloc+0x141>
				sys_page_unmap(0, mptr + i);
			return 0;	/* out of physical memory */
  802745:	b8 00 00 00 00       	mov    $0x0,%eax
  80274a:	eb 4b                	jmp    802797 <malloc+0x1b5>
  80274c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80274f:	a3 18 50 80 00       	mov    %eax,0x805018
static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  802754:	be 00 00 00 00       	mov    $0x0,%esi
	}

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
  802759:	89 f2                	mov    %esi,%edx
  80275b:	39 de                	cmp    %ebx,%esi
  80275d:	72 90                	jb     8026ef <malloc+0x10d>
				sys_page_unmap(0, mptr + i);
			return 0;	/* out of physical memory */
		}
	}

	ref = (uint32_t*) (mptr + i - 4);
  80275f:	a1 18 50 80 00       	mov    0x805018,%eax
	*ref = 2;	/* reference for mptr, reference for returned block */
  802764:	c7 44 30 fc 02 00 00 	movl   $0x2,-0x4(%eax,%esi,1)
  80276b:	00 
	v = mptr;
	mptr += n;
  80276c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80276f:	01 c2                	add    %eax,%edx
  802771:	89 15 18 50 80 00    	mov    %edx,0x805018
	return v;
  802777:	eb 1e                	jmp    802797 <malloc+0x1b5>
		mptr = mbegin;

	n = ROUNDUP(n, 4);

	if (n >= MAXMALLOC)
		return 0;
  802779:	b8 00 00 00 00       	mov    $0x0,%eax
  80277e:	eb 17                	jmp    802797 <malloc+0x1b5>
  802780:	81 c6 00 10 00 00    	add    $0x1000,%esi
	nwrap = 0;
	while (1) {
		if (isfree(mptr, n + 4))
			break;
		mptr += PGSIZE;
		if (mptr == mend) {
  802786:	81 fe 00 00 00 10    	cmp    $0x10000000,%esi
  80278c:	0f 84 3c ff ff ff    	je     8026ce <malloc+0xec>
  802792:	e9 ef fe ff ff       	jmp    802686 <malloc+0xa4>
	ref = (uint32_t*) (mptr + i - 4);
	*ref = 2;	/* reference for mptr, reference for returned block */
	v = mptr;
	mptr += n;
	return v;
}
  802797:	83 c4 2c             	add    $0x2c,%esp
  80279a:	5b                   	pop    %ebx
  80279b:	5e                   	pop    %esi
  80279c:	5f                   	pop    %edi
  80279d:	5d                   	pop    %ebp
  80279e:	c3                   	ret    

0080279f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80279f:	55                   	push   %ebp
  8027a0:	89 e5                	mov    %esp,%ebp
  8027a2:	56                   	push   %esi
  8027a3:	53                   	push   %ebx
  8027a4:	83 ec 10             	sub    $0x10,%esp
  8027a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8027aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8027ad:	89 04 24             	mov    %eax,(%esp)
  8027b0:	e8 db ef ff ff       	call   801790 <fd2data>
  8027b5:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8027b7:	c7 44 24 04 9b 37 80 	movl   $0x80379b,0x4(%esp)
  8027be:	00 
  8027bf:	89 1c 24             	mov    %ebx,(%esp)
  8027c2:	e8 70 e8 ff ff       	call   801037 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8027c7:	8b 46 04             	mov    0x4(%esi),%eax
  8027ca:	2b 06                	sub    (%esi),%eax
  8027cc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8027d2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8027d9:	00 00 00 
	stat->st_dev = &devpipe;
  8027dc:	c7 83 88 00 00 00 5c 	movl   $0x80405c,0x88(%ebx)
  8027e3:	40 80 00 
	return 0;
}
  8027e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8027eb:	83 c4 10             	add    $0x10,%esp
  8027ee:	5b                   	pop    %ebx
  8027ef:	5e                   	pop    %esi
  8027f0:	5d                   	pop    %ebp
  8027f1:	c3                   	ret    

008027f2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8027f2:	55                   	push   %ebp
  8027f3:	89 e5                	mov    %esp,%ebp
  8027f5:	53                   	push   %ebx
  8027f6:	83 ec 14             	sub    $0x14,%esp
  8027f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8027fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802800:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802807:	e8 ee ec ff ff       	call   8014fa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80280c:	89 1c 24             	mov    %ebx,(%esp)
  80280f:	e8 7c ef ff ff       	call   801790 <fd2data>
  802814:	89 44 24 04          	mov    %eax,0x4(%esp)
  802818:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80281f:	e8 d6 ec ff ff       	call   8014fa <sys_page_unmap>
}
  802824:	83 c4 14             	add    $0x14,%esp
  802827:	5b                   	pop    %ebx
  802828:	5d                   	pop    %ebp
  802829:	c3                   	ret    

0080282a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80282a:	55                   	push   %ebp
  80282b:	89 e5                	mov    %esp,%ebp
  80282d:	57                   	push   %edi
  80282e:	56                   	push   %esi
  80282f:	53                   	push   %ebx
  802830:	83 ec 2c             	sub    $0x2c,%esp
  802833:	89 c6                	mov    %eax,%esi
  802835:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802838:	a1 1c 50 80 00       	mov    0x80501c,%eax
  80283d:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802840:	89 34 24             	mov    %esi,(%esp)
  802843:	e8 b5 05 00 00       	call   802dfd <pageref>
  802848:	89 c7                	mov    %eax,%edi
  80284a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80284d:	89 04 24             	mov    %eax,(%esp)
  802850:	e8 a8 05 00 00       	call   802dfd <pageref>
  802855:	39 c7                	cmp    %eax,%edi
  802857:	0f 94 c2             	sete   %dl
  80285a:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  80285d:	8b 0d 1c 50 80 00    	mov    0x80501c,%ecx
  802863:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  802866:	39 fb                	cmp    %edi,%ebx
  802868:	74 21                	je     80288b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80286a:	84 d2                	test   %dl,%dl
  80286c:	74 ca                	je     802838 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80286e:	8b 51 58             	mov    0x58(%ecx),%edx
  802871:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802875:	89 54 24 08          	mov    %edx,0x8(%esp)
  802879:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80287d:	c7 04 24 a2 37 80 00 	movl   $0x8037a2,(%esp)
  802884:	e8 7e e1 ff ff       	call   800a07 <cprintf>
  802889:	eb ad                	jmp    802838 <_pipeisclosed+0xe>
	}
}
  80288b:	83 c4 2c             	add    $0x2c,%esp
  80288e:	5b                   	pop    %ebx
  80288f:	5e                   	pop    %esi
  802890:	5f                   	pop    %edi
  802891:	5d                   	pop    %ebp
  802892:	c3                   	ret    

00802893 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802893:	55                   	push   %ebp
  802894:	89 e5                	mov    %esp,%ebp
  802896:	57                   	push   %edi
  802897:	56                   	push   %esi
  802898:	53                   	push   %ebx
  802899:	83 ec 1c             	sub    $0x1c,%esp
  80289c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80289f:	89 34 24             	mov    %esi,(%esp)
  8028a2:	e8 e9 ee ff ff       	call   801790 <fd2data>
  8028a7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8028a9:	bf 00 00 00 00       	mov    $0x0,%edi
  8028ae:	eb 45                	jmp    8028f5 <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8028b0:	89 da                	mov    %ebx,%edx
  8028b2:	89 f0                	mov    %esi,%eax
  8028b4:	e8 71 ff ff ff       	call   80282a <_pipeisclosed>
  8028b9:	85 c0                	test   %eax,%eax
  8028bb:	75 41                	jne    8028fe <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8028bd:	e8 72 eb ff ff       	call   801434 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8028c2:	8b 43 04             	mov    0x4(%ebx),%eax
  8028c5:	8b 0b                	mov    (%ebx),%ecx
  8028c7:	8d 51 20             	lea    0x20(%ecx),%edx
  8028ca:	39 d0                	cmp    %edx,%eax
  8028cc:	73 e2                	jae    8028b0 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8028ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8028d1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8028d5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8028d8:	99                   	cltd   
  8028d9:	c1 ea 1b             	shr    $0x1b,%edx
  8028dc:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8028df:	83 e1 1f             	and    $0x1f,%ecx
  8028e2:	29 d1                	sub    %edx,%ecx
  8028e4:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8028e8:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8028ec:	83 c0 01             	add    $0x1,%eax
  8028ef:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8028f2:	83 c7 01             	add    $0x1,%edi
  8028f5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8028f8:	75 c8                	jne    8028c2 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8028fa:	89 f8                	mov    %edi,%eax
  8028fc:	eb 05                	jmp    802903 <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8028fe:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802903:	83 c4 1c             	add    $0x1c,%esp
  802906:	5b                   	pop    %ebx
  802907:	5e                   	pop    %esi
  802908:	5f                   	pop    %edi
  802909:	5d                   	pop    %ebp
  80290a:	c3                   	ret    

0080290b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80290b:	55                   	push   %ebp
  80290c:	89 e5                	mov    %esp,%ebp
  80290e:	57                   	push   %edi
  80290f:	56                   	push   %esi
  802910:	53                   	push   %ebx
  802911:	83 ec 1c             	sub    $0x1c,%esp
  802914:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802917:	89 3c 24             	mov    %edi,(%esp)
  80291a:	e8 71 ee ff ff       	call   801790 <fd2data>
  80291f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802921:	be 00 00 00 00       	mov    $0x0,%esi
  802926:	eb 3d                	jmp    802965 <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802928:	85 f6                	test   %esi,%esi
  80292a:	74 04                	je     802930 <devpipe_read+0x25>
				return i;
  80292c:	89 f0                	mov    %esi,%eax
  80292e:	eb 43                	jmp    802973 <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802930:	89 da                	mov    %ebx,%edx
  802932:	89 f8                	mov    %edi,%eax
  802934:	e8 f1 fe ff ff       	call   80282a <_pipeisclosed>
  802939:	85 c0                	test   %eax,%eax
  80293b:	75 31                	jne    80296e <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80293d:	e8 f2 ea ff ff       	call   801434 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802942:	8b 03                	mov    (%ebx),%eax
  802944:	3b 43 04             	cmp    0x4(%ebx),%eax
  802947:	74 df                	je     802928 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802949:	99                   	cltd   
  80294a:	c1 ea 1b             	shr    $0x1b,%edx
  80294d:	01 d0                	add    %edx,%eax
  80294f:	83 e0 1f             	and    $0x1f,%eax
  802952:	29 d0                	sub    %edx,%eax
  802954:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802959:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80295c:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80295f:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802962:	83 c6 01             	add    $0x1,%esi
  802965:	3b 75 10             	cmp    0x10(%ebp),%esi
  802968:	75 d8                	jne    802942 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80296a:	89 f0                	mov    %esi,%eax
  80296c:	eb 05                	jmp    802973 <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80296e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802973:	83 c4 1c             	add    $0x1c,%esp
  802976:	5b                   	pop    %ebx
  802977:	5e                   	pop    %esi
  802978:	5f                   	pop    %edi
  802979:	5d                   	pop    %ebp
  80297a:	c3                   	ret    

0080297b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80297b:	55                   	push   %ebp
  80297c:	89 e5                	mov    %esp,%ebp
  80297e:	56                   	push   %esi
  80297f:	53                   	push   %ebx
  802980:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802983:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802986:	89 04 24             	mov    %eax,(%esp)
  802989:	e8 19 ee ff ff       	call   8017a7 <fd_alloc>
  80298e:	89 c2                	mov    %eax,%edx
  802990:	85 d2                	test   %edx,%edx
  802992:	0f 88 4d 01 00 00    	js     802ae5 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802998:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80299f:	00 
  8029a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8029ae:	e8 a0 ea ff ff       	call   801453 <sys_page_alloc>
  8029b3:	89 c2                	mov    %eax,%edx
  8029b5:	85 d2                	test   %edx,%edx
  8029b7:	0f 88 28 01 00 00    	js     802ae5 <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8029bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8029c0:	89 04 24             	mov    %eax,(%esp)
  8029c3:	e8 df ed ff ff       	call   8017a7 <fd_alloc>
  8029c8:	89 c3                	mov    %eax,%ebx
  8029ca:	85 c0                	test   %eax,%eax
  8029cc:	0f 88 fe 00 00 00    	js     802ad0 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8029d2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8029d9:	00 
  8029da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8029dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8029e8:	e8 66 ea ff ff       	call   801453 <sys_page_alloc>
  8029ed:	89 c3                	mov    %eax,%ebx
  8029ef:	85 c0                	test   %eax,%eax
  8029f1:	0f 88 d9 00 00 00    	js     802ad0 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8029f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029fa:	89 04 24             	mov    %eax,(%esp)
  8029fd:	e8 8e ed ff ff       	call   801790 <fd2data>
  802a02:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802a04:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802a0b:	00 
  802a0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a10:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a17:	e8 37 ea ff ff       	call   801453 <sys_page_alloc>
  802a1c:	89 c3                	mov    %eax,%ebx
  802a1e:	85 c0                	test   %eax,%eax
  802a20:	0f 88 97 00 00 00    	js     802abd <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802a26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802a29:	89 04 24             	mov    %eax,(%esp)
  802a2c:	e8 5f ed ff ff       	call   801790 <fd2data>
  802a31:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802a38:	00 
  802a39:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802a3d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802a44:	00 
  802a45:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a49:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a50:	e8 52 ea ff ff       	call   8014a7 <sys_page_map>
  802a55:	89 c3                	mov    %eax,%ebx
  802a57:	85 c0                	test   %eax,%eax
  802a59:	78 52                	js     802aad <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802a5b:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  802a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a64:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a69:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802a70:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  802a76:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802a79:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802a7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802a7e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a88:	89 04 24             	mov    %eax,(%esp)
  802a8b:	e8 f0 ec ff ff       	call   801780 <fd2num>
  802a90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802a93:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802a95:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802a98:	89 04 24             	mov    %eax,(%esp)
  802a9b:	e8 e0 ec ff ff       	call   801780 <fd2num>
  802aa0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802aa3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802aa6:	b8 00 00 00 00       	mov    $0x0,%eax
  802aab:	eb 38                	jmp    802ae5 <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  802aad:	89 74 24 04          	mov    %esi,0x4(%esp)
  802ab1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ab8:	e8 3d ea ff ff       	call   8014fa <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802abd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ac0:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ac4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802acb:	e8 2a ea ff ff       	call   8014fa <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ad3:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ad7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ade:	e8 17 ea ff ff       	call   8014fa <sys_page_unmap>
  802ae3:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  802ae5:	83 c4 30             	add    $0x30,%esp
  802ae8:	5b                   	pop    %ebx
  802ae9:	5e                   	pop    %esi
  802aea:	5d                   	pop    %ebp
  802aeb:	c3                   	ret    

00802aec <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802aec:	55                   	push   %ebp
  802aed:	89 e5                	mov    %esp,%ebp
  802aef:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802af2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802af5:	89 44 24 04          	mov    %eax,0x4(%esp)
  802af9:	8b 45 08             	mov    0x8(%ebp),%eax
  802afc:	89 04 24             	mov    %eax,(%esp)
  802aff:	e8 f2 ec ff ff       	call   8017f6 <fd_lookup>
  802b04:	89 c2                	mov    %eax,%edx
  802b06:	85 d2                	test   %edx,%edx
  802b08:	78 15                	js     802b1f <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b0d:	89 04 24             	mov    %eax,(%esp)
  802b10:	e8 7b ec ff ff       	call   801790 <fd2data>
	return _pipeisclosed(fd, p);
  802b15:	89 c2                	mov    %eax,%edx
  802b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b1a:	e8 0b fd ff ff       	call   80282a <_pipeisclosed>
}
  802b1f:	c9                   	leave  
  802b20:	c3                   	ret    
  802b21:	66 90                	xchg   %ax,%ax
  802b23:	66 90                	xchg   %ax,%ax
  802b25:	66 90                	xchg   %ax,%ax
  802b27:	66 90                	xchg   %ax,%ax
  802b29:	66 90                	xchg   %ax,%ax
  802b2b:	66 90                	xchg   %ax,%ax
  802b2d:	66 90                	xchg   %ax,%ax
  802b2f:	90                   	nop

00802b30 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802b30:	55                   	push   %ebp
  802b31:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802b33:	b8 00 00 00 00       	mov    $0x0,%eax
  802b38:	5d                   	pop    %ebp
  802b39:	c3                   	ret    

00802b3a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802b3a:	55                   	push   %ebp
  802b3b:	89 e5                	mov    %esp,%ebp
  802b3d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802b40:	c7 44 24 04 ba 37 80 	movl   $0x8037ba,0x4(%esp)
  802b47:	00 
  802b48:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b4b:	89 04 24             	mov    %eax,(%esp)
  802b4e:	e8 e4 e4 ff ff       	call   801037 <strcpy>
	return 0;
}
  802b53:	b8 00 00 00 00       	mov    $0x0,%eax
  802b58:	c9                   	leave  
  802b59:	c3                   	ret    

00802b5a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802b5a:	55                   	push   %ebp
  802b5b:	89 e5                	mov    %esp,%ebp
  802b5d:	57                   	push   %edi
  802b5e:	56                   	push   %esi
  802b5f:	53                   	push   %ebx
  802b60:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802b66:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802b6b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802b71:	eb 31                	jmp    802ba4 <devcons_write+0x4a>
		m = n - tot;
  802b73:	8b 75 10             	mov    0x10(%ebp),%esi
  802b76:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802b78:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802b7b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802b80:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802b83:	89 74 24 08          	mov    %esi,0x8(%esp)
  802b87:	03 45 0c             	add    0xc(%ebp),%eax
  802b8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b8e:	89 3c 24             	mov    %edi,(%esp)
  802b91:	e8 3e e6 ff ff       	call   8011d4 <memmove>
		sys_cputs(buf, m);
  802b96:	89 74 24 04          	mov    %esi,0x4(%esp)
  802b9a:	89 3c 24             	mov    %edi,(%esp)
  802b9d:	e8 e4 e7 ff ff       	call   801386 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802ba2:	01 f3                	add    %esi,%ebx
  802ba4:	89 d8                	mov    %ebx,%eax
  802ba6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802ba9:	72 c8                	jb     802b73 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802bab:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802bb1:	5b                   	pop    %ebx
  802bb2:	5e                   	pop    %esi
  802bb3:	5f                   	pop    %edi
  802bb4:	5d                   	pop    %ebp
  802bb5:	c3                   	ret    

00802bb6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802bb6:	55                   	push   %ebp
  802bb7:	89 e5                	mov    %esp,%ebp
  802bb9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  802bbc:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802bc1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802bc5:	75 07                	jne    802bce <devcons_read+0x18>
  802bc7:	eb 2a                	jmp    802bf3 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802bc9:	e8 66 e8 ff ff       	call   801434 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802bce:	66 90                	xchg   %ax,%ax
  802bd0:	e8 cf e7 ff ff       	call   8013a4 <sys_cgetc>
  802bd5:	85 c0                	test   %eax,%eax
  802bd7:	74 f0                	je     802bc9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802bd9:	85 c0                	test   %eax,%eax
  802bdb:	78 16                	js     802bf3 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802bdd:	83 f8 04             	cmp    $0x4,%eax
  802be0:	74 0c                	je     802bee <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802be2:	8b 55 0c             	mov    0xc(%ebp),%edx
  802be5:	88 02                	mov    %al,(%edx)
	return 1;
  802be7:	b8 01 00 00 00       	mov    $0x1,%eax
  802bec:	eb 05                	jmp    802bf3 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802bee:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802bf3:	c9                   	leave  
  802bf4:	c3                   	ret    

00802bf5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802bf5:	55                   	push   %ebp
  802bf6:	89 e5                	mov    %esp,%ebp
  802bf8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802bfb:	8b 45 08             	mov    0x8(%ebp),%eax
  802bfe:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802c01:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802c08:	00 
  802c09:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802c0c:	89 04 24             	mov    %eax,(%esp)
  802c0f:	e8 72 e7 ff ff       	call   801386 <sys_cputs>
}
  802c14:	c9                   	leave  
  802c15:	c3                   	ret    

00802c16 <getchar>:

int
getchar(void)
{
  802c16:	55                   	push   %ebp
  802c17:	89 e5                	mov    %esp,%ebp
  802c19:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802c1c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802c23:	00 
  802c24:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802c27:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c2b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802c32:	e8 53 ee ff ff       	call   801a8a <read>
	if (r < 0)
  802c37:	85 c0                	test   %eax,%eax
  802c39:	78 0f                	js     802c4a <getchar+0x34>
		return r;
	if (r < 1)
  802c3b:	85 c0                	test   %eax,%eax
  802c3d:	7e 06                	jle    802c45 <getchar+0x2f>
		return -E_EOF;
	return c;
  802c3f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802c43:	eb 05                	jmp    802c4a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802c45:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802c4a:	c9                   	leave  
  802c4b:	c3                   	ret    

00802c4c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802c4c:	55                   	push   %ebp
  802c4d:	89 e5                	mov    %esp,%ebp
  802c4f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802c52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c55:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c59:	8b 45 08             	mov    0x8(%ebp),%eax
  802c5c:	89 04 24             	mov    %eax,(%esp)
  802c5f:	e8 92 eb ff ff       	call   8017f6 <fd_lookup>
  802c64:	85 c0                	test   %eax,%eax
  802c66:	78 11                	js     802c79 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c6b:	8b 15 78 40 80 00    	mov    0x804078,%edx
  802c71:	39 10                	cmp    %edx,(%eax)
  802c73:	0f 94 c0             	sete   %al
  802c76:	0f b6 c0             	movzbl %al,%eax
}
  802c79:	c9                   	leave  
  802c7a:	c3                   	ret    

00802c7b <opencons>:

int
opencons(void)
{
  802c7b:	55                   	push   %ebp
  802c7c:	89 e5                	mov    %esp,%ebp
  802c7e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802c81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c84:	89 04 24             	mov    %eax,(%esp)
  802c87:	e8 1b eb ff ff       	call   8017a7 <fd_alloc>
		return r;
  802c8c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802c8e:	85 c0                	test   %eax,%eax
  802c90:	78 40                	js     802cd2 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802c92:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802c99:	00 
  802c9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ca1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ca8:	e8 a6 e7 ff ff       	call   801453 <sys_page_alloc>
		return r;
  802cad:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802caf:	85 c0                	test   %eax,%eax
  802cb1:	78 1f                	js     802cd2 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802cb3:	8b 15 78 40 80 00    	mov    0x804078,%edx
  802cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cbc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cc1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802cc8:	89 04 24             	mov    %eax,(%esp)
  802ccb:	e8 b0 ea ff ff       	call   801780 <fd2num>
  802cd0:	89 c2                	mov    %eax,%edx
}
  802cd2:	89 d0                	mov    %edx,%eax
  802cd4:	c9                   	leave  
  802cd5:	c3                   	ret    
  802cd6:	66 90                	xchg   %ax,%ax
  802cd8:	66 90                	xchg   %ax,%ax
  802cda:	66 90                	xchg   %ax,%ax
  802cdc:	66 90                	xchg   %ax,%ax
  802cde:	66 90                	xchg   %ax,%ax

00802ce0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802ce0:	55                   	push   %ebp
  802ce1:	89 e5                	mov    %esp,%ebp
  802ce3:	56                   	push   %esi
  802ce4:	53                   	push   %ebx
  802ce5:	83 ec 10             	sub    $0x10,%esp
  802ce8:	8b 75 08             	mov    0x8(%ebp),%esi
  802ceb:	8b 45 0c             	mov    0xc(%ebp),%eax
  802cee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
		pg = (void *) UTOP;
  802cf1:	85 c0                	test   %eax,%eax
  802cf3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802cf8:	0f 44 c2             	cmove  %edx,%eax
	}

	int ret = sys_ipc_recv(pg);
  802cfb:	89 04 24             	mov    %eax,(%esp)
  802cfe:	e8 66 e9 ff ff       	call   801669 <sys_ipc_recv>

	if(ret < 0) {
  802d03:	85 c0                	test   %eax,%eax
  802d05:	79 16                	jns    802d1d <ipc_recv+0x3d>
		if(from_env_store) *from_env_store = 0;
  802d07:	85 f6                	test   %esi,%esi
  802d09:	74 06                	je     802d11 <ipc_recv+0x31>
  802d0b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store = 0;
  802d11:	85 db                	test   %ebx,%ebx
  802d13:	74 3e                	je     802d53 <ipc_recv+0x73>
  802d15:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802d1b:	eb 36                	jmp    802d53 <ipc_recv+0x73>
		return ret;
	}

	thisenv = &envs[ENVX(sys_getenvid())];
  802d1d:	e8 f3 e6 ff ff       	call   801415 <sys_getenvid>
  802d22:	25 ff 03 00 00       	and    $0x3ff,%eax
  802d27:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802d2a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802d2f:	a3 1c 50 80 00       	mov    %eax,0x80501c

	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802d34:	85 f6                	test   %esi,%esi
  802d36:	74 05                	je     802d3d <ipc_recv+0x5d>
  802d38:	8b 40 74             	mov    0x74(%eax),%eax
  802d3b:	89 06                	mov    %eax,(%esi)
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  802d3d:	85 db                	test   %ebx,%ebx
  802d3f:	74 0a                	je     802d4b <ipc_recv+0x6b>
  802d41:	a1 1c 50 80 00       	mov    0x80501c,%eax
  802d46:	8b 40 78             	mov    0x78(%eax),%eax
  802d49:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  802d4b:	a1 1c 50 80 00       	mov    0x80501c,%eax
  802d50:	8b 40 70             	mov    0x70(%eax),%eax
}
  802d53:	83 c4 10             	add    $0x10,%esp
  802d56:	5b                   	pop    %ebx
  802d57:	5e                   	pop    %esi
  802d58:	5d                   	pop    %ebp
  802d59:	c3                   	ret    

00802d5a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802d5a:	55                   	push   %ebp
  802d5b:	89 e5                	mov    %esp,%ebp
  802d5d:	57                   	push   %edi
  802d5e:	56                   	push   %esi
  802d5f:	53                   	push   %ebx
  802d60:	83 ec 1c             	sub    $0x1c,%esp
  802d63:	8b 7d 08             	mov    0x8(%ebp),%edi
  802d66:	8b 75 0c             	mov    0xc(%ebp),%esi
  802d69:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if(pg == NULL) {
  802d6c:	85 db                	test   %ebx,%ebx
		pg = (void *) UTOP;
  802d6e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802d73:	0f 44 d8             	cmove  %eax,%ebx
	}

	while(true) {
		int ret = sys_ipc_try_send(to_env, val, pg, (unsigned) perm);
  802d76:	8b 45 14             	mov    0x14(%ebp),%eax
  802d79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802d7d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802d81:	89 74 24 04          	mov    %esi,0x4(%esp)
  802d85:	89 3c 24             	mov    %edi,(%esp)
  802d88:	e8 b9 e8 ff ff       	call   801646 <sys_ipc_try_send>

		if(ret >= 0) break;
  802d8d:	85 c0                	test   %eax,%eax
  802d8f:	79 2c                	jns    802dbd <ipc_send+0x63>

		if(ret != -E_IPC_NOT_RECV) {
  802d91:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802d94:	74 20                	je     802db6 <ipc_send+0x5c>
			panic("Invalid error returned by sys_ipc_try_send %e \n", ret);
  802d96:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802d9a:	c7 44 24 08 c8 37 80 	movl   $0x8037c8,0x8(%esp)
  802da1:	00 
  802da2:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  802da9:	00 
  802daa:	c7 04 24 f8 37 80 00 	movl   $0x8037f8,(%esp)
  802db1:	e8 58 db ff ff       	call   80090e <_panic>
		}
		sys_yield();
  802db6:	e8 79 e6 ff ff       	call   801434 <sys_yield>
	}
  802dbb:	eb b9                	jmp    802d76 <ipc_send+0x1c>
}
  802dbd:	83 c4 1c             	add    $0x1c,%esp
  802dc0:	5b                   	pop    %ebx
  802dc1:	5e                   	pop    %esi
  802dc2:	5f                   	pop    %edi
  802dc3:	5d                   	pop    %ebp
  802dc4:	c3                   	ret    

00802dc5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802dc5:	55                   	push   %ebp
  802dc6:	89 e5                	mov    %esp,%ebp
  802dc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802dcb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802dd0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802dd3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802dd9:	8b 52 50             	mov    0x50(%edx),%edx
  802ddc:	39 ca                	cmp    %ecx,%edx
  802dde:	75 0d                	jne    802ded <ipc_find_env+0x28>
			return envs[i].env_id;
  802de0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802de3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802de8:	8b 40 40             	mov    0x40(%eax),%eax
  802deb:	eb 0e                	jmp    802dfb <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802ded:	83 c0 01             	add    $0x1,%eax
  802df0:	3d 00 04 00 00       	cmp    $0x400,%eax
  802df5:	75 d9                	jne    802dd0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802df7:	66 b8 00 00          	mov    $0x0,%ax
}
  802dfb:	5d                   	pop    %ebp
  802dfc:	c3                   	ret    

00802dfd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802dfd:	55                   	push   %ebp
  802dfe:	89 e5                	mov    %esp,%ebp
  802e00:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802e03:	89 d0                	mov    %edx,%eax
  802e05:	c1 e8 16             	shr    $0x16,%eax
  802e08:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802e0f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802e14:	f6 c1 01             	test   $0x1,%cl
  802e17:	74 1d                	je     802e36 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802e19:	c1 ea 0c             	shr    $0xc,%edx
  802e1c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802e23:	f6 c2 01             	test   $0x1,%dl
  802e26:	74 0e                	je     802e36 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802e28:	c1 ea 0c             	shr    $0xc,%edx
  802e2b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802e32:	ef 
  802e33:	0f b7 c0             	movzwl %ax,%eax
}
  802e36:	5d                   	pop    %ebp
  802e37:	c3                   	ret    
  802e38:	66 90                	xchg   %ax,%ax
  802e3a:	66 90                	xchg   %ax,%ax
  802e3c:	66 90                	xchg   %ax,%ax
  802e3e:	66 90                	xchg   %ax,%ax

00802e40 <__udivdi3>:
  802e40:	55                   	push   %ebp
  802e41:	57                   	push   %edi
  802e42:	56                   	push   %esi
  802e43:	83 ec 0c             	sub    $0xc,%esp
  802e46:	8b 44 24 28          	mov    0x28(%esp),%eax
  802e4a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  802e4e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802e52:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802e56:	85 c0                	test   %eax,%eax
  802e58:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802e5c:	89 ea                	mov    %ebp,%edx
  802e5e:	89 0c 24             	mov    %ecx,(%esp)
  802e61:	75 2d                	jne    802e90 <__udivdi3+0x50>
  802e63:	39 e9                	cmp    %ebp,%ecx
  802e65:	77 61                	ja     802ec8 <__udivdi3+0x88>
  802e67:	85 c9                	test   %ecx,%ecx
  802e69:	89 ce                	mov    %ecx,%esi
  802e6b:	75 0b                	jne    802e78 <__udivdi3+0x38>
  802e6d:	b8 01 00 00 00       	mov    $0x1,%eax
  802e72:	31 d2                	xor    %edx,%edx
  802e74:	f7 f1                	div    %ecx
  802e76:	89 c6                	mov    %eax,%esi
  802e78:	31 d2                	xor    %edx,%edx
  802e7a:	89 e8                	mov    %ebp,%eax
  802e7c:	f7 f6                	div    %esi
  802e7e:	89 c5                	mov    %eax,%ebp
  802e80:	89 f8                	mov    %edi,%eax
  802e82:	f7 f6                	div    %esi
  802e84:	89 ea                	mov    %ebp,%edx
  802e86:	83 c4 0c             	add    $0xc,%esp
  802e89:	5e                   	pop    %esi
  802e8a:	5f                   	pop    %edi
  802e8b:	5d                   	pop    %ebp
  802e8c:	c3                   	ret    
  802e8d:	8d 76 00             	lea    0x0(%esi),%esi
  802e90:	39 e8                	cmp    %ebp,%eax
  802e92:	77 24                	ja     802eb8 <__udivdi3+0x78>
  802e94:	0f bd e8             	bsr    %eax,%ebp
  802e97:	83 f5 1f             	xor    $0x1f,%ebp
  802e9a:	75 3c                	jne    802ed8 <__udivdi3+0x98>
  802e9c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802ea0:	39 34 24             	cmp    %esi,(%esp)
  802ea3:	0f 86 9f 00 00 00    	jbe    802f48 <__udivdi3+0x108>
  802ea9:	39 d0                	cmp    %edx,%eax
  802eab:	0f 82 97 00 00 00    	jb     802f48 <__udivdi3+0x108>
  802eb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802eb8:	31 d2                	xor    %edx,%edx
  802eba:	31 c0                	xor    %eax,%eax
  802ebc:	83 c4 0c             	add    $0xc,%esp
  802ebf:	5e                   	pop    %esi
  802ec0:	5f                   	pop    %edi
  802ec1:	5d                   	pop    %ebp
  802ec2:	c3                   	ret    
  802ec3:	90                   	nop
  802ec4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ec8:	89 f8                	mov    %edi,%eax
  802eca:	f7 f1                	div    %ecx
  802ecc:	31 d2                	xor    %edx,%edx
  802ece:	83 c4 0c             	add    $0xc,%esp
  802ed1:	5e                   	pop    %esi
  802ed2:	5f                   	pop    %edi
  802ed3:	5d                   	pop    %ebp
  802ed4:	c3                   	ret    
  802ed5:	8d 76 00             	lea    0x0(%esi),%esi
  802ed8:	89 e9                	mov    %ebp,%ecx
  802eda:	8b 3c 24             	mov    (%esp),%edi
  802edd:	d3 e0                	shl    %cl,%eax
  802edf:	89 c6                	mov    %eax,%esi
  802ee1:	b8 20 00 00 00       	mov    $0x20,%eax
  802ee6:	29 e8                	sub    %ebp,%eax
  802ee8:	89 c1                	mov    %eax,%ecx
  802eea:	d3 ef                	shr    %cl,%edi
  802eec:	89 e9                	mov    %ebp,%ecx
  802eee:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802ef2:	8b 3c 24             	mov    (%esp),%edi
  802ef5:	09 74 24 08          	or     %esi,0x8(%esp)
  802ef9:	89 d6                	mov    %edx,%esi
  802efb:	d3 e7                	shl    %cl,%edi
  802efd:	89 c1                	mov    %eax,%ecx
  802eff:	89 3c 24             	mov    %edi,(%esp)
  802f02:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802f06:	d3 ee                	shr    %cl,%esi
  802f08:	89 e9                	mov    %ebp,%ecx
  802f0a:	d3 e2                	shl    %cl,%edx
  802f0c:	89 c1                	mov    %eax,%ecx
  802f0e:	d3 ef                	shr    %cl,%edi
  802f10:	09 d7                	or     %edx,%edi
  802f12:	89 f2                	mov    %esi,%edx
  802f14:	89 f8                	mov    %edi,%eax
  802f16:	f7 74 24 08          	divl   0x8(%esp)
  802f1a:	89 d6                	mov    %edx,%esi
  802f1c:	89 c7                	mov    %eax,%edi
  802f1e:	f7 24 24             	mull   (%esp)
  802f21:	39 d6                	cmp    %edx,%esi
  802f23:	89 14 24             	mov    %edx,(%esp)
  802f26:	72 30                	jb     802f58 <__udivdi3+0x118>
  802f28:	8b 54 24 04          	mov    0x4(%esp),%edx
  802f2c:	89 e9                	mov    %ebp,%ecx
  802f2e:	d3 e2                	shl    %cl,%edx
  802f30:	39 c2                	cmp    %eax,%edx
  802f32:	73 05                	jae    802f39 <__udivdi3+0xf9>
  802f34:	3b 34 24             	cmp    (%esp),%esi
  802f37:	74 1f                	je     802f58 <__udivdi3+0x118>
  802f39:	89 f8                	mov    %edi,%eax
  802f3b:	31 d2                	xor    %edx,%edx
  802f3d:	e9 7a ff ff ff       	jmp    802ebc <__udivdi3+0x7c>
  802f42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802f48:	31 d2                	xor    %edx,%edx
  802f4a:	b8 01 00 00 00       	mov    $0x1,%eax
  802f4f:	e9 68 ff ff ff       	jmp    802ebc <__udivdi3+0x7c>
  802f54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802f58:	8d 47 ff             	lea    -0x1(%edi),%eax
  802f5b:	31 d2                	xor    %edx,%edx
  802f5d:	83 c4 0c             	add    $0xc,%esp
  802f60:	5e                   	pop    %esi
  802f61:	5f                   	pop    %edi
  802f62:	5d                   	pop    %ebp
  802f63:	c3                   	ret    
  802f64:	66 90                	xchg   %ax,%ax
  802f66:	66 90                	xchg   %ax,%ax
  802f68:	66 90                	xchg   %ax,%ax
  802f6a:	66 90                	xchg   %ax,%ax
  802f6c:	66 90                	xchg   %ax,%ax
  802f6e:	66 90                	xchg   %ax,%ax

00802f70 <__umoddi3>:
  802f70:	55                   	push   %ebp
  802f71:	57                   	push   %edi
  802f72:	56                   	push   %esi
  802f73:	83 ec 14             	sub    $0x14,%esp
  802f76:	8b 44 24 28          	mov    0x28(%esp),%eax
  802f7a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802f7e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802f82:	89 c7                	mov    %eax,%edi
  802f84:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f88:	8b 44 24 30          	mov    0x30(%esp),%eax
  802f8c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802f90:	89 34 24             	mov    %esi,(%esp)
  802f93:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802f97:	85 c0                	test   %eax,%eax
  802f99:	89 c2                	mov    %eax,%edx
  802f9b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802f9f:	75 17                	jne    802fb8 <__umoddi3+0x48>
  802fa1:	39 fe                	cmp    %edi,%esi
  802fa3:	76 4b                	jbe    802ff0 <__umoddi3+0x80>
  802fa5:	89 c8                	mov    %ecx,%eax
  802fa7:	89 fa                	mov    %edi,%edx
  802fa9:	f7 f6                	div    %esi
  802fab:	89 d0                	mov    %edx,%eax
  802fad:	31 d2                	xor    %edx,%edx
  802faf:	83 c4 14             	add    $0x14,%esp
  802fb2:	5e                   	pop    %esi
  802fb3:	5f                   	pop    %edi
  802fb4:	5d                   	pop    %ebp
  802fb5:	c3                   	ret    
  802fb6:	66 90                	xchg   %ax,%ax
  802fb8:	39 f8                	cmp    %edi,%eax
  802fba:	77 54                	ja     803010 <__umoddi3+0xa0>
  802fbc:	0f bd e8             	bsr    %eax,%ebp
  802fbf:	83 f5 1f             	xor    $0x1f,%ebp
  802fc2:	75 5c                	jne    803020 <__umoddi3+0xb0>
  802fc4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802fc8:	39 3c 24             	cmp    %edi,(%esp)
  802fcb:	0f 87 e7 00 00 00    	ja     8030b8 <__umoddi3+0x148>
  802fd1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802fd5:	29 f1                	sub    %esi,%ecx
  802fd7:	19 c7                	sbb    %eax,%edi
  802fd9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802fdd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802fe1:	8b 44 24 08          	mov    0x8(%esp),%eax
  802fe5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802fe9:	83 c4 14             	add    $0x14,%esp
  802fec:	5e                   	pop    %esi
  802fed:	5f                   	pop    %edi
  802fee:	5d                   	pop    %ebp
  802fef:	c3                   	ret    
  802ff0:	85 f6                	test   %esi,%esi
  802ff2:	89 f5                	mov    %esi,%ebp
  802ff4:	75 0b                	jne    803001 <__umoddi3+0x91>
  802ff6:	b8 01 00 00 00       	mov    $0x1,%eax
  802ffb:	31 d2                	xor    %edx,%edx
  802ffd:	f7 f6                	div    %esi
  802fff:	89 c5                	mov    %eax,%ebp
  803001:	8b 44 24 04          	mov    0x4(%esp),%eax
  803005:	31 d2                	xor    %edx,%edx
  803007:	f7 f5                	div    %ebp
  803009:	89 c8                	mov    %ecx,%eax
  80300b:	f7 f5                	div    %ebp
  80300d:	eb 9c                	jmp    802fab <__umoddi3+0x3b>
  80300f:	90                   	nop
  803010:	89 c8                	mov    %ecx,%eax
  803012:	89 fa                	mov    %edi,%edx
  803014:	83 c4 14             	add    $0x14,%esp
  803017:	5e                   	pop    %esi
  803018:	5f                   	pop    %edi
  803019:	5d                   	pop    %ebp
  80301a:	c3                   	ret    
  80301b:	90                   	nop
  80301c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803020:	8b 04 24             	mov    (%esp),%eax
  803023:	be 20 00 00 00       	mov    $0x20,%esi
  803028:	89 e9                	mov    %ebp,%ecx
  80302a:	29 ee                	sub    %ebp,%esi
  80302c:	d3 e2                	shl    %cl,%edx
  80302e:	89 f1                	mov    %esi,%ecx
  803030:	d3 e8                	shr    %cl,%eax
  803032:	89 e9                	mov    %ebp,%ecx
  803034:	89 44 24 04          	mov    %eax,0x4(%esp)
  803038:	8b 04 24             	mov    (%esp),%eax
  80303b:	09 54 24 04          	or     %edx,0x4(%esp)
  80303f:	89 fa                	mov    %edi,%edx
  803041:	d3 e0                	shl    %cl,%eax
  803043:	89 f1                	mov    %esi,%ecx
  803045:	89 44 24 08          	mov    %eax,0x8(%esp)
  803049:	8b 44 24 10          	mov    0x10(%esp),%eax
  80304d:	d3 ea                	shr    %cl,%edx
  80304f:	89 e9                	mov    %ebp,%ecx
  803051:	d3 e7                	shl    %cl,%edi
  803053:	89 f1                	mov    %esi,%ecx
  803055:	d3 e8                	shr    %cl,%eax
  803057:	89 e9                	mov    %ebp,%ecx
  803059:	09 f8                	or     %edi,%eax
  80305b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80305f:	f7 74 24 04          	divl   0x4(%esp)
  803063:	d3 e7                	shl    %cl,%edi
  803065:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  803069:	89 d7                	mov    %edx,%edi
  80306b:	f7 64 24 08          	mull   0x8(%esp)
  80306f:	39 d7                	cmp    %edx,%edi
  803071:	89 c1                	mov    %eax,%ecx
  803073:	89 14 24             	mov    %edx,(%esp)
  803076:	72 2c                	jb     8030a4 <__umoddi3+0x134>
  803078:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80307c:	72 22                	jb     8030a0 <__umoddi3+0x130>
  80307e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803082:	29 c8                	sub    %ecx,%eax
  803084:	19 d7                	sbb    %edx,%edi
  803086:	89 e9                	mov    %ebp,%ecx
  803088:	89 fa                	mov    %edi,%edx
  80308a:	d3 e8                	shr    %cl,%eax
  80308c:	89 f1                	mov    %esi,%ecx
  80308e:	d3 e2                	shl    %cl,%edx
  803090:	89 e9                	mov    %ebp,%ecx
  803092:	d3 ef                	shr    %cl,%edi
  803094:	09 d0                	or     %edx,%eax
  803096:	89 fa                	mov    %edi,%edx
  803098:	83 c4 14             	add    $0x14,%esp
  80309b:	5e                   	pop    %esi
  80309c:	5f                   	pop    %edi
  80309d:	5d                   	pop    %ebp
  80309e:	c3                   	ret    
  80309f:	90                   	nop
  8030a0:	39 d7                	cmp    %edx,%edi
  8030a2:	75 da                	jne    80307e <__umoddi3+0x10e>
  8030a4:	8b 14 24             	mov    (%esp),%edx
  8030a7:	89 c1                	mov    %eax,%ecx
  8030a9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8030ad:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8030b1:	eb cb                	jmp    80307e <__umoddi3+0x10e>
  8030b3:	90                   	nop
  8030b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8030b8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8030bc:	0f 82 0f ff ff ff    	jb     802fd1 <__umoddi3+0x61>
  8030c2:	e9 1a ff ff ff       	jmp    802fe1 <__umoddi3+0x71>
