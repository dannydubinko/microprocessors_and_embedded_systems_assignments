#include "nios2_control.h"

/* place additional #define macros here */
#define HEX_DISPLAY (volatile unsigned int *) 0x10000020

/* define global program variables here */
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

	/* do one or more checks for different sources using ipending value */

	/* remember to clear interrupt sources */
}

/*-----------------------------------------------------------------*/

void Init (void)
{
	/* initialize software variables */

	/* set up each hardware interface */

	/* set up ienable */

	/* enable global recognition of interrupts in procr. status reg. */
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
