#include "nios2_control.h"

/* place additional #define macros here */
#define HEX_DISPLAY (volatile unsigned int *) 0x10000020
#define JTAG_UART_BASE ((volatile unsigned int *) 0x10001000)
#define LEDS	((volatile unsigned int *) 0x10000010)

// timer1

#define TIMER1_STATUS	((volatile unsigned int *) 0x10004020)

#define TIMER1_CONTROL	((volatile unsigned int *) 0x10004024)

#define TIMER1_START_LO	((volatile unsigned int *) 0x10004028)

#define TIMER1_START_HI	((volatile unsigned int *) 0x1000402C)

#define TIMER1_SNAP_LO	((volatile unsigned int *) 0x10004030)

#define TIMER1_SNAP_HI	((volatile unsigned int *) 0x10004034)

// timer3

#define TIMER2_STATUS	((volatile unsigned int *) 0x10004060)

#define TIMER2_CONTROL	((volatile unsigned int *) 0x10004064)

#define TIMER2_START_LO	((volatile unsigned int *) 0x10004068)

#define TIMER2_START_HI	((volatile unsigned int *) 0x1000406C)

#define TIMER2_SNAP_LO	((volatile unsigned int *) 0x10004070)

#define TIMER2_SNAP_HI	((volatile unsigned int *) 0x10004074)

/* define global program variables here */
int timer_3_flag = 0;
int timer_1_flag = 0;

void ShowDigit (int display, int value){
	int unsigned hex = 0;
	switch(value){
		default:
			break;
		case 0:
			hex = 0x3F;
			break;
		case 1:
			hex = 0x06;
			break;
		case 2:
			hex = 0x5B;
			break;
		case 3:
			hex = 0x4F;
			break;
		case 4:
			hex = 0x66;
			break;
		case 5:
			hex = 0x6D;
			break;
		case 6:
			hex = 0x7D;
			break;
		case 7:
			hex = 0x07;
			break;
		case 8:
			hex = 0x7F;
			break;
		case 9:
			hex = 0x67;
			break;		
	}
	hex = hex << (display * 8);

	unsigned int mask = 0xFF << (display * 8);
	unsigned int curr_disp = *HEX_DISPLAY;

	curr_disp = curr_disp & (curr_disp ^ mask);
	*HEX_DISPLAY = curr_disp | hex;
}

/* place additional functions here */



/*-----------------------------------------------------------------*/

/* this routine is called from the_exception() in exception_handler.c */

void interrupt_handler(void)
{
	unsigned int ipending;

	/* read current value in ipending register */
	ipending = NIOS2_READ_IPENDING();

	/* do one or more checks for different sources using ipending value */
	if ((ipending & 0b1) == 0b1) {
		*TIMER_STATUS = *TIMER_STATUS & 0b10;
		
		//*LEDS = *LEDS ^ 0b1;
		
		
	}

	/* remember to clear interrupt sources */
	if((ipending & 0x4000) == 0x4000) { // timer 1
		*TIMER1_STATUS = *TIMER1_STATUS & 0b10;
		temp = LEDS;
		*temp = *temp ^ 0x707;
	}
	
	if((ipending & 0x2000) == 0x2000) { // timer 3 - CYCLE the lEDS0
		*TIMER3_STATUS = *TIMER3_STATUS & 0b10;
		switch(timer_3_flag){
			default:
				break;
			case 0:
				*LEDS = 0x300;
				break;
			case 1:
				*LEDS = 0x30;
				break;
			case 2:
				*LEDS = 0x3;
				break;
			case 3:
				*LEDS = 0x30;
				break;	
		}
		if(timer_3_flag < 3){
			timer_3_flag = timer_3_flag + 1;
		} else {
			timer_3_flag = 0;
		}
	}
}

/*-----------------------------------------------------------------*/

void Init (void)
{
	/* initialize software variables */

	/* set up each hardware interface */
	*TIMER1_START_LO = 0x7840;
	*TIMER1_START_HI = 0x017D;
	*TIMER1_STATUS = 0b0;
	*TIMER1_CONTROL = 0x7;

	*TIMER3_START_LO = 0xBC20;
	*TIMER3_START_HI = 0x00BE;
	*TIMER3_STATUS = 0b0;
	*TIMER3_CONTROL = 0x7;

	/* set up ienable */
	NIOS2_WRITE_STATUS(0b1);
	/* enable global recognition of interrupts in procr. status reg. */
	NIOS2_WRITE_IENABLE(0b11);
}

/*-----------------------------------------------------------------*/

int main (void)
{
	Init ();	/* perform software/hardware initialization */

	while (1)
	{
		/* fill in body of infinite loop */
	}

	return 0;	/* never reached, but main() must return a value */
}
