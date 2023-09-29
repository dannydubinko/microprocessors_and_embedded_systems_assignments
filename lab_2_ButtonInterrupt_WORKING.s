#-----------------------------------------------------------------------------
# This template source file for ELEC 371 Lab 2 experimentation with interrupts
# also serves as the template for all assembly-language-level coding for
# Nios II interrupt-based programs in this course. DO NOT USE the approach
# shown in the vendor documentation for the DE0 Basic (or Media) Computer.
# The approach illustrated in this template file is far simpler for learning.
#
# Dr. N. Manjikian, Dept. of Elec. and Comp. Eng., Queen's University
#-----------------------------------------------------------------------------


	.text		# start a code segment (and we will also have data in it)

	.global	_start	# export _start symbol for linker 

#-----------------------------------------------------------------------------
# Define symbols for memory-mapped I/O register addresses and use them in code
#-----------------------------------------------------------------------------

# mask/edge registers for pushbutton parallel port

	.equ	BUTTON_MASK, 0x10000058
	.equ	BUTTON_EDGE, 0x1000005C

# pattern corresponding to the bit assigned to button1 in the registers above

	.equ	BUTTON1,  0x2

# data register for LED parallel port

	.equ	LEDS, 0x10000010
	
	.equ		JTAG_UART_BASE,		0x10001000
	.equ		DATA_OFFSET,		0
	.equ		STATUS_OFFSET,		4
	.equ		WSPACE_MASK,		0xFFFF
	
# timer directives
	.equ 		TIMER_STATUS, 		0x10002000
	.equ 		TIMER_CONTROL,		0x10002004
	.equ 		TIMER_START_LO, 	0x10002008
	.equ 		TIMER_START_HI, 	0x1000200C

#-----------------------------------------------------------------------------
# Define two branch instructions in specific locations at the start of memory
#-----------------------------------------------------------------------------

	.org	0x0000	# this is the _reset_ address 
_start:
	br	main	# branch to actual start of main() routine 

	.org	0x0020	# this is the _exception/interrupt_ address
 
	br	isr	# branch to start of interrupt service routine 
			#   (rather than placing all of the service code here) 

#-----------------------------------------------------------------------------
# The actual program code (incl. service routine) can be placed immediately
# after the second branch above, or another .org directive could be used
# to place the program code at a desired address (e.g., 0x0080). It does not
# matter because the _start symbol defines where execution begins, and the
# branch at that location simply forces execution to continue where desired.
#-----------------------------------------------------------------------------

main:
	movia sp, 0x7FFFFC		# initialize stack pointer
	movia r2, TEXT
	call PrintString
	

	
	call Init		# call hw/sw initialization subroutine

	movia r3, COUNT		# perform any local initialization of gen.-purpose regs.
	stw r0, 0(r3)					#   before entering main loop 

main_loop:

	ldw  r4, 0(r3)		# body of main loop (reflecting typical embedded
	addi r4, r4, 1		#   software organization where execution does not
	stw  r4, 0(r3)	#   terminate)

	br main_loop

#-----------------------------------------------------------------------------
# This subroutine should encompass preparation of I/O registers as well as
# special processor registers for recognition and processing of interrupt
# requests. Initialization of data variables in memory can also be done here.
#-----------------------------------------------------------------------------

Init:				# Setup for an interrupt to occur

	subi  sp, sp, 8
	stw   r2, 4(sp)
	stw   r3, 0(sp)
	
#turning on the io bits
	movia r2, BUTTON1 	  #move button location into r2
	movia r3, BUTTON_MASK #move button mask address into r3, buttonMask if on allows intterupts go through from button 
	stwio r2, 0(r3)       #stw button location into r3 to turn on button mask that allows for the button to send values

#turning on the processor(enable bit) for io devices
	rdctl  r2, ienable #place ienable into r2
	ori   r2, r2, 3	  #or second bit position to make the bit 1
	wrctl ienable, r2 #write to ienable to change it to accept button input (interrupts)

#turning on the processor for all interrupts 
	rdctl r2, status	#place status value into r2
	ori   r2, r2, 1		#or 1 in hex with status value to turn bit 1 to 1
	wrctl status, r2	#write to status value to allow for accepting all interrupts
	
	# set up timer
	movia 	r16, TIMER_STATUS
	movia 	r12, 0x00BEBC20
	sthio 	r12, 8(r16)
	srli 	r12, r12, 16
	sthio  	r12, 0xC(r16)
	movi 	r5, 7
	stwio 	r5, 4(r16)
	
	
	
	ldw   r2, 4(sp)
	ldw   r3, 0(sp)
	addi  sp, sp, 8
	
	ret

#-----------------------------------------------------------------------------
# The code for the interrupt service routine is below. Note that the branch
# instruction at 0x0020 is executed first upon recognition of interrupts,
# and that branch brings the flow of execution to the code below. Therefore,
# the actual code for this routine can be anywhere in memory for convenience.
# This template involves only hardware-generated interrupts. Therefore, the
# return-address adjustment on the ea register is performed unconditionally.
# Programs with software-generated interrupts must check for hardware sources
# to conditionally adjust the ea register (no adjustment for s/w interrupts).
#-----------------------------------------------------------------------------

isr:
	subi   sp,sp, 16			# save register values, except ea which
	stw  r4, 12(sp)
	stw  r2, 8(sp)			#must be modified for hardware interrupts
	stw  r3, 4(sp)
	stw  ra, 0(sp) 
	
	subi	ea, ea, 4	# ea adjustment required for h/w interrupts

	rdctl r4, ipending			# read ipending
	andi  r3, r4, 2				# check to see if ipending is on by anding
	beq   r3, r0, next			# if ipending is not 0 then move on if it is that means not interrupts are waiting
	
	movia r2, LEDS           #move the address of the LEDS into r2
	ldwio r3, 0(r2)				#load value at address r2 itnto r3. This checks if LED is on or off. The value corresponds to which LED is on
	xori  r3, r3, 1			 # xori 1 with r3 value. If LED is off turn it on and if LED is on Turn it off.
	stwio   r3, 0(r2) 		 #store the value of r3 into the value stored at address r2. Which is LED address
	
	movia r2, BUTTON1
	movia r3, BUTTON_EDGE #reset button edge to reset interrupt back to 0, button edge turns to a 1 when thehardware is pressed, writing to button_mask of the relavent button clears all button interrupts
	stwio r2, 0(r3)



next:
# read the last bit
	
	andi  r3, r4, 1	   
	beq   r3, r0, next_else

    call RunLED
	
	movia r2, 0x1
	movia r3, TIMER_STATUS #reset button edge to reset interrupt back to 0, button edge turns to a 1 when thehardware is pressed, writing to button_mask of the relavent button clears all button interrupts
	stwio r2, 0(r3)
	next_else:
	
	ldw r4, 12(sp)
	ldw r2, 8(sp)				# restore register values
	ldw r3, 4(sp)
	ldw ra, 0(sp)
	addi sp, sp, 16
	

	
	eret			# interrupt service routines end _differently_
				#   than subroutines; execution must return to
				#   to point in main program where interrupt
				#   request invoked service routine
	
#-----------------------------------------------------------------------------
# Definitions for program data, incl. anything shared between main/isr code
#-----------------------------------------------------------------------------

	
PrintChar:
	subi sp, sp, 8		# adjust stack pointer down to reserve space
	stw r3, 4(sp)		# save value of register r3 so it can be a temp
	stw r4, 0(sp)		# save value of register r4 so it can be a temp

	movia r3, JTAG_UART_BASE	# point to fitst memory-mapped I/O register

pc_loop:
	ldwio r4, STATUS_OFFSET(r3)	# read bits from status register
	andhi r4, r4, WSPACE_MASK	# mask off lower bits to isolate upper bits
	beq r4, r0, pc_loop			# if upper bits are zero, loop again
	stwio r2, DATA_OFFSET(r3)	# otherwise, write character to data register

	ldw r3, 4(sp)		# restore value of r3 from stack
	ldw r4, 0(sp)		# restore value of r4 from stack
	addi sp, sp, 8		# readjust stack ptr up to deallocate space

	ret 				# return to calling routine
	
PrintString:			
	subi sp, sp, 8		# adjust stack pointer down to reserve space
	stw r3, 4(sp)		# save value of register r3 so it can be a temp
	stw ra, 0(sp)
	
	mov r3, r2

ps_loop:
	ldb r2, 0(r3)
	beq r2, r0 , ps_else
	call PrintChar
	addi r3, r3, 1
	br ps_loop
ps_else:
	ldw r3, 4(sp)
	ldw ra, 0(sp)# restore value of r3 from stack
	addi sp, sp, 8		# readjust stack ptr up to deallocate space
	ret # return to calling routine
	
RunLED:
	subi sp, sp, 8
	stw 	r2, 4(sp)
	stw 	r3, 0(sp)
	
	movia r2, LEDS
	ldwio r3, 0(r2)
	xori r3, r3, 0x3E0
	stwio r3, 0(r2)
	
	ldw 	r2, 4(sp)
	ldw 	r3, 0(sp)
	addi 	sp, sp, 8
	
	ret
	

       .org	0x1000		# start should be fine for most small programs
	   
COUNT: .skip   4 			#define/reserve storage for program data
TEXT:  .asciz "ELEC 371 Lab 2 by Alistair Barfoot, Matthew Brown, and Daniel Dubinko\n"

	   .end