/* for standalone testing of this file by itself using the simulator,
   keep the following line, but for in-lab activity with the Monitor Program
   to have a multi-file project, comment out the following line */

#define TEST_CHARIO


/* no #include statements should be required, as the character I/O functions
   do not rely on any other code or definitions (the .h file for these
   functions would be included in _other_ .c files) */

#define JTAG_UART_DATA (volatile unsigned int *)0x10001000
#define JTAG_UART_STATUS (volatile unsigned int *)0x10001004

/* because all character-I/O code is in this file, the #define statements
   for the JTAG UART pointers can be placed here; they should not be needed
   in any other file */
	
#define JTAG_UART_DATA (volatile unsigned int *)0x10001000
#define JTAG_UART_STATUS (volatile unsigned int *)0x10001004

/* place the full function definitions for the character-I/O routines here */

// This function will print a given character to the UART with a polling loop
void PrintChar(unsigned int input){
	unsigned int status;
	
	// polling loop - check if the UART is ready
	do {
		status = *JTAG_UART_STATUS;
		status = (status & 0xFFFF0000);
	} while (status == 0);
	
	// write character to UART
	*JTAG_UART_DATA = input;
}

// This function will print a string to the UART given a pointer to a starting address
void PrintString(char *str){
	char character;
	
	while(1){
        character = *str; // read the current character
        if(character == '\0'){
            break;
        } else {
            PrintChar(character);
            str = str + 1;
        }
	}
}

// This function will print a given hex integer eg 10 --> A
void PrintHex(unsigned int input){
    
    // If the input is 10-15, convert to hex
    if (input >= 10){
        input = input - 10 + 'A';
    // otherwise, convert to ascii
    } else {
        input = input + '0';
    }
    PrintChar(input);
}

// This function will print a given hex string eg 65363 --> 0xFF53
void PrintHexString(char *hex){
    // print the leading 0x
    PrintChar('0');
    PrintChar('x');

    // use PrintHex character-by-character
    for(int i = 0; i < 7; i++){
        PrintHex(*hex & 0xF);
        hex = hex + 1;
    }
    PrintChar('\n');
}

// unsigned int GetChar(){
//     unsigned int uart, state;
//     // polling loop
//     do {
//         uart = JTAG_UART_DATA; // check the register
//         state = info & 0x8000;
//     } while(state == 0);
//     return info & 0xFF; // return the character
// }

// unsigned int CheckChar(){
//     unsigned int info, result;
//     info =JTAG_UART_DATA; //retrive from data register
//     if(info&0x8000) //if the status bit is 1, bring in the new character
//         result = info&0xFF;
//     else //no new character, return 0
//         result = 0;
//     return result;
// }

#ifdef TEST_CHARIO

/* this portion is conditionally compiled based on whether or not
   the symbol exists; it is only for standalone testing of the routines
   using the simulator; there is a main() routine in lab4.c, so
   for the in-lab activity, the following code would conflict with it */

int main (void)
{

  /* place calls here to the various character-I/O routines
     to test their behavior, e.g., PrintString("hello\n");  */
    PrintChar('L');
    PrintChar('\n');
    PrintString("Last ever Manji lab\n");
    PrintHex(12);
    PrintChar('\n');
    PrintHexString(0x55BEBC20);

  return 0;
} 

#endif /* TEST_CHARIO */
