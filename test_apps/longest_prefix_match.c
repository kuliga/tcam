#include <stdio.h>
#include "platform.h"
#include "tcam.h"
#include "xil_printf.h"
#include <xparameters.h>
#include <xtmrctr.h>

static XTmrCtr timer0;

#define INST_NUM		(256U)

struct test_bin {
	u32 key;
	u32 misc[4];
};

struct test_bin bins[INST_NUM];

union ipv4 {
	u32 word;
	u8 addr[4];
};

struct iptable {
	union ipv4 ip;
	union ipv4 netmask;
	union {
		u8 misc[4];
		u32 word;
	};
};

struct iptable iptable[3];

void fill_iptable(void)
{
    iptable[0].ip.addr[3] = 10;
    iptable[0].ip.addr[2] = 4;
    iptable[0].ip.addr[1] = 1;
    iptable[0].ip.addr[0] = 32;

    iptable[0].netmask.addr[3] = 255;
    iptable[0].netmask.addr[2] = 255;
    iptable[0].netmask.addr[1] = 255;
    iptable[0].netmask.addr[0] = 224;
    iptable[0].misc[0] = 0xff;
    iptable[0].misc[1] = 0xf0;
    iptable[0].misc[2] = 0xff;
    iptable[0].misc[3] = 0xf0;
    __tcam_set_entry(0,  iptable[0].ip.word,  iptable[0].netmask.word, (u32) &iptable[0], 0);

    iptable[1].ip.addr[3] = 10;
    iptable[1].ip.addr[2] = 4;
    iptable[1].ip.addr[1] = 1;
    iptable[1].ip.addr[0] = 0;

    iptable[1].netmask.addr[3] = 255;
    iptable[1].netmask.addr[2] = 255;
    iptable[1].netmask.addr[1] = 255;
    iptable[1].netmask.addr[0] = 0;
    __tcam_set_entry(1,  iptable[1].ip.word,  iptable[1].netmask.word, (u32) &iptable[1], 0);

    iptable[2].ip.addr[3] = 10;
    iptable[2].ip.addr[2] = 0;
    iptable[2].ip.addr[1] = 0;
    iptable[2].ip.addr[0] = 0;

    iptable[2].netmask.addr[3] = 255;
    iptable[2].netmask.addr[2] = 0;
    iptable[2].netmask.addr[1] = 0;
    iptable[2].netmask.addr[0] = 0;
    __tcam_set_entry(2,  iptable[2].ip.word,  iptable[2].netmask.word, (u32) &iptable[2], 0);
}



int main()
{
    init_platform();

    fill_iptable();

    union ipv4 ip;
    ip.addr[3] = 10;
    ip.addr[2] = 4;
    ip.addr[1] = 1;
    ip.addr[0] = 62;

    u32 volatile val = __tcam_get_entry(ip.word, 0);
    struct iptable *tab = (struct iptable *) val;
    u32 data = tab->word;
    xil_printf("data: %x\n\r", data);

    cleanup_platform();
    return 0;
}
