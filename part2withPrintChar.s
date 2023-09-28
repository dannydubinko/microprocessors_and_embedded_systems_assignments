.equ		JTAG_UART_BASE,		0x10001000
.equ		DATA_OFFSET,		0
.equ		STATUS_OFFSET,		4
.equ		WSPACE_MASK,		0xFFFF

.text
.global _start
.org 0x0000
_start:

movi sp, 0x7FCC

main:

movi r2, ' '
call PrintChar
loop:
	movi r2, '\b'
    call PrintChar
    movia r2, 0x10000050
    ldwio r2, 0(r2)
	srli r2, r2, 1
    andhi r2, r2, 0x1
    addi r2, r2, '0'
    call PrintChar
    br loop	
	
ret

# ------------------------------------------------------------

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
	
.org	0x1000
.end
