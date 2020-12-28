	.data
KEYBOARD_EVENT_PENDING:
	.word	0x0
KEYBOARD_EVENT:
	.word   0x0
KEYBOARD_COUNTS:
	.space  128
NEWLINE:
	.asciiz "\n"
SPACE:
	.asciiz " "
	
	
	.eqv 	LETTER_a 97
	.eqv	LETTER_b 98
	.eqv	LETTER_c 99
	.eqv 	LETTER_d 100
	.eqv 	LETTER_space 32
	
	
	.text  
main:
# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

#set interrupts on
check:
	#code from lab to allow interrupts
	la $s0, 0xffff0000	# control register for MMIO Simulator "Receiver"
	lb $s1, 0($s0)
	ori $s1, $s1, 0x02	# Set bit 1 to enable "Receiver" interrupts (i.e., keyboard)
	sb $s1, 0($s0)

check_for_event:
	addi $sp, $sp, -4
	sw $t0, 0($sp)
	
	lw $t0, KEYBOARD_EVENT_PENDING
	bne $zero, $t0, event	
	
	lw $t0, 0($sp)
	addi $sp, $sp, 4
	beq $zero, $zero, check_for_event
	
event:
	addi $sp, $sp, -4
	sw $t0, 0($sp)
	
	lw $t0, KEYBOARD_EVENT_PENDING 
	sw $t0, KEYBOARD_EVENT #event is being handled
	sw $zero, KEYBOARD_EVENT_PENDING #set pending back to zero
	
	beq $t0, LETTER_a, pressed_a 
	beq $t0, LETTER_b, pressed_b
	beq $t0, LETTER_c, pressed_c 
	beq $t0, LETTER_d, pressed_d 
	beq $t0, LETTER_space, pressed_space
	
	lw $t0, 0($sp)
	addi $sp, $sp, 4
	beq $zero, $zero, check_for_event	
	
pressed_a:
	addi $sp, $sp, -8
	sw $t1, 4($sp)
	sw $t0, 0($sp)

	la $t0, KEYBOARD_COUNTS #load address to t0
	lw $t1, 0($t0) #set t1 to number stored at first int (letter a count)
	addi $t1, $t1, 1 #increment t1 by one
	sw $t1, 0($t0) #store t1 back into address at t0
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	addi $sp, $sp, 8
	beq $zero, $zero, check_for_event
pressed_b:
	addi $sp, $sp, -8
	sw $t1, 4($sp)
	sw $t0, 0($sp)

	la $t0, KEYBOARD_COUNTS #load address to t0
	lw $t1, 4($t0) #set t1 to number stored at second int (letter b count)
	addi $t1, $t1, 1 #increment t1 by one
	sw $t1, 4($t0) #store t1 back into address at t0
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	addi $sp, $sp, 8
	beq $zero, $zero, check_for_event
pressed_c:
	addi $sp, $sp, -8
	sw $t1, 4($sp)
	sw $t0, 0($sp)

	la $t0, KEYBOARD_COUNTS #load address to t0
	lw $t1, 8($t0) #set t1 to number stored at third int (letter c count)
	addi $t1, $t1, 1 #increment t1 by one
	sw $t1, 8($t0) #store t1 back into address at t0
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	addi $sp, $sp, 8
	beq $zero, $zero, check_for_event		
pressed_d:
	addi $sp, $sp, -8
	sw $t1, 4($sp)
	sw $t0, 0($sp)

	la $t0, KEYBOARD_COUNTS #load address to t0
	lw $t1, 12($t0) #set t1 to number stored at fourth int (letter d count)
	addi $t1, $t1, 1 #increment t1 by one
	sw $t1, 12($t0) #store t1 back into address at t0
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	addi $sp, $sp, 8
	beq $zero, $zero, check_for_event	

pressed_space:
	#t0 = count, t1 = int
	addi $sp, $sp, -8
	sw $t1, 4($sp)
	sw $t0, 0($sp)
	add $t0, $zero, $zero 
	la $a1, KEYBOARD_COUNTS	#load in counts
	
pressed_space_loop:
	beq $t0, 4, exit_space #exit loop 
	
	lw $t1, 0($a1) #load in first int
	addi $a1, $a1, 4 #next int
	add $a0, $zero, $t1 #store int in a0 to print out
	addi $v0,$zero, 1 #syscall
	syscall 
	la $a0, SPACE
	addi $v0, $zero, 4
	syscall
	addi $t0, $t0, 1 #increment 
	beq $zero, $zero, pressed_space_loop
		
exit_space:
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	addi $sp, $sp, 8 #back to normal
	la $a0, NEWLINE
	addi $v0, $zero, 4
	syscall
	beq $zero, $zero, check_for_event	
	  
	.kdata

	.ktext 0x80000180
#code from lab to allow interrupts	
__kernel_entry:
	mfc0 $k0, $13		# $13 is the "cause" register in Coproc0
	andi $k1, $k0, 0x7c	# bits 2 to 6 are the ExcCode field (0 for interrupts)
	srl  $k1, $k1, 2	# shift ExcCode bits for easier comparison
	beq $zero, $k1, __is_interrupt
	
__is_exception:
	# Something of a placeholder...
	# ... just in case we can't escape the need for handling some exceptions.
	beq $zero, $zero, __exit_exception
	
__is_interrupt:
	andi $k1, $k0, 0x0100	# examine bit 8
	bne $k1, $zero, __is_keyboard_interrupt	 # if bit 8 set, then we have a keyboard interrupt.
	
	beq $zero, $zero, __exit_exception	# otherwise, we return exit kernel
	
__is_keyboard_interrupt:
	la $k0, 0xffff0004
	lw $k1, 0($k0)	
	la $k0, KEYBOARD_EVENT_PENDING
	sw $k1, 0($k0)
	
	beq $zero, $zero, __exit_exception	# Kept here in case we add more handlers.
	
__exit_exception:
	eret
	
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE

	
