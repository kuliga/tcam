#include <stdio.h>
#include "platform.h"
#include "tcam.h"
#include "xil_printf.h"
#include <xparameters.h>
#include <xtmrctr.h>

static XTmrCtr timer0;

#define INST_NUM		(16U)

struct test_bin {
	u32 key;
	u32 misc[4];
};

struct test_bin bins[INST_NUM];

void test_bins_init(void)
{
	for (int i = 0; i < INST_NUM; ++i) {
		bins[i].key = i;

		__tcam_set_entry(i, bins[i].key, 0xffffffff, (u32) &bins[i], 0);
	}
}

int binary_search(struct test_bin *arr, int val, size_t n)
{
        short l, r, k; //lewa prawa granica, kolejny indeks
        l = 0;
        r = n - 1;
        k = n / 2;
        u32 tmp;
        while (l <= r) {
                k = (l + r) / 2;
                tmp = arr[k].key;
                if (tmp == val)
                        return k;

                if (tmp < val)
                        l = k + 1;
                else
                        r  = k - 1;
        }
        return 0;
}

void test_bins_sw(u32 mask)
{
	volatile u32 val;
	xil_printf("SOFTWARE\r\n");

	for (int i = 0; i < INST_NUM; ++i) {
		/* enable timer */
		XTmrCtr_Start(&timer0, 0);
//		val = XTmrCtr_GetValue(&timer0, 0);
//		xil_printf("timer value; %u\r\n", val);

		/* mask key */
		i &= mask;

		/* search */
		int k = binary_search(bins, i, INST_NUM);

		/* disable timer */
		val = XTmrCtr_GetValue(&timer0, 0);
		xil_printf("addr: %x   timer value; %u\r\n", (u32) &bins[k],
																val);
		XTmrCtr_Stop(&timer0, 0);
	}
}

void test_bins_tcam(u32 mask)
{
	volatile u32 val;
	xil_printf("TCAM\r\n");

	for (int i = 0; i < INST_NUM; ++i) {
		/* enable timer */
		XTmrCtr_Start(&timer0, 0);
//		val = XTmrCtr_GetValue(&timer0, 0);
//		xil_printf("timer value; %u\r\n", val);
		/* mask key */
//		i &= mask;

		/* search */
		int k = __tcam_get_entry(i, 0);

		/* disable timer */
		val = XTmrCtr_GetValue(&timer0, 0);
		xil_printf("addr: %x   timer value; %u\r\n", k,
													val);
		XTmrCtr_Stop(&timer0, 0);
	}
}

int main()
{
    init_platform();

    int status = XTmrCtr_Initialize(&timer0, XPAR_AXI_TIMER_0_DEVICE_ID);
	XTmrCtr_SetOptions(&timer0, 0,
				XTC_AUTO_RELOAD_OPTION);
	status = XTmrCtr_SelfTest(&timer0, 0);

    test_bins_init();

    test_bins_sw(0xffffffff);

    test_bins_tcam(0xffffffff);

    print("Hello World\n\r");

    cleanup_platform();
    return 0;
}
