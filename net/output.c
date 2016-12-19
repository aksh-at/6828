#include "ns.h"

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
	binaryname = "ns_output";

	// LAB 6: Your code here:
	// 	- read a packet from the network server
	//	- send the packet to the device driver
	envid_t srcenv;
	int perm;
	int i;

	while(true) {
		ipc_recv(&srcenv, &nsipcbuf, &perm);

		if(srcenv != ns_envid) continue;

		for(i = 0; i < 50; i++) {
			if(sys_try_send_packet(nsipcbuf.pkt.jp_data, nsipcbuf.pkt.jp_len) == 0) break;
			sys_yield();
		}

		if(i == 50) {
			cprintf("Packet failed to send after 50 tries\n");
		}
	}
}
