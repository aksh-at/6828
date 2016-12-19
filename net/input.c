#include "ns.h"

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
	binaryname = "ns_input";

	// LAB 6: Your code here:
	// 	- read a packet from the device driver
	//	- send it to the network server
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
	int i;
	void* packet;
	int size;

	while(true) {
		//sys_yield();
		//continue;

		while(true) {
			if(sys_try_recv_packet(&packet, &size) == 0)  break;
			sys_yield();
		}

		sys_page_alloc(0, &nsipcbuf, PTE_U|PTE_W|PTE_P);
		memcpy(nsipcbuf.pkt.jp_data, packet, size);
		nsipcbuf.pkt.jp_len = size;

		ipc_send(ns_envid, NSREQ_INPUT, &nsipcbuf, PTE_U|PTE_W|PTE_P);
	}
}
