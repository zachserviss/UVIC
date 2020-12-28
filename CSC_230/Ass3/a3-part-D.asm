# This code assumes the use of the "Bitmap Display" tool.
#
# Tool settings must be:
#   Unit Width in Pixels: 32
#   Unit Height in Pixels: 32
#   Display Width in Pixels: 512
#   Display Height in Pixels: 512
#   Based Address for display: 0x10010000 (static data)
#
# In effect, this produces a bitmap display of 16x16 pixels.


	.include "bitmap-routines.asm"

	.data
TELL_TALE:
	.word 0x12345678 0x9abcdef0	# Helps us visually detect where our part starts in .data section
KEYBOARD_EVENT_PENDING:
	.word	0x0
KEYBOARD_EVENT:
	.word   0x0
BOX_ROW:
	.word	0x0
BOX_COLUMN:
	.word	0x0

	.eqv LETTER_a 97
	.eqv LETTER_d 100
	.eqv LETTER_w 119
	.eqv LETTER_x 120 
	.eqv BOX_COLOUR 0x0099ff33
	
	.globl main
	
	.text	
main: 
# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	# initialize variables
	lw $a0, BOX_COLUMN
	lw $a1, BOX_ROW
	addi $a2, $zero, BOX_COLOUR
	#code from lab to allow interrupts
	la $s0, 0xffff0000	# control register for MMIO Simulator "Receiver"
	lb $s1, 0($s0)
	ori $s1, $s1, 0x02	# Set bit 1 to enable "Receiver" interrupts (i.e., keyboard)
	sb $s1, 0($s0)
	#draw first box
	jal draw_bitmap_box
	
	
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
	beq $t0, LETTER_w, pressed_w
	beq $t0, LETTER_x, pressed_x 
	beq $t0, LETTER_d, pressed_d
	
	lw $t0, 0($sp)
	addi $sp, $sp, 4
	beq $zero, $zero, check_for_event		
	
pressed_a:
	addi $sp, $sp, -4
	sw $ra,0($sp)
	add $a2, $zero, $zero #set origninal cube to black
	jal draw_bitmap_box
	lw $a1, BOX_ROW #load in row number
	addi $a1, $a1, -1 #move left one
	sw $a1, BOX_ROW #store new row value
	addi $a2, $zero, BOX_COLOUR #pretty colour again
	jal draw_bitmap_box #make it so!
	lw $ra,0($sp)
	addi $sp, $sp, 4
	beq $zero, $zero, check_for_event
	
pressed_w:
	addi $sp, $sp, -4
	sw $ra,0($sp)
	add $a2, $zero, $zero
	jal draw_bitmap_box #make og box black
	lw $a0, BOX_COLUMN #load in column number
	addi $a0, $a0, -1 #move up one
	sw $a0, BOX_COLUMN #store new column 
	addi $a2, $zero, BOX_COLOUR
	jal draw_bitmap_box
	lw $ra,0($sp)
	addi $sp, $sp, 4
	beq $zero, $zero, check_for_event
	
pressed_x:
	addi $sp, $sp, -4
	sw $ra,0($sp)
	add $a2, $zero, $zero
	jal draw_bitmap_box #make og box black
	lw $a0, BOX_COLUMN #load in column number
	addi $a0, $a0, 1 #move down one
	sw $a0, BOX_COLUMN #store new column
	addi $a2, $zero, BOX_COLOUR
	jal draw_bitmap_box
	lw $ra,0($sp)
	addi $sp, $sp, 4
	beq $zero, $zero, check_for_event
	
pressed_d:
	addi $sp, $sp, -4
	sw $ra,0($sp) 
	add $a2, $zero, $zero
	jal draw_bitmap_box #turn old blx black
	lw $a1, BOX_ROW #load in row number
	addi $a1, $a1, 1 #move right one
	sw $a1, BOX_ROW #store new row number
	addi $a2, $zero, BOX_COLOUR
	jal draw_bitmap_box
	lw $ra,0($sp)
	addi $sp, $sp, 4
	beq $zero, $zero, check_for_event
		
	# Should never, *ever* arrive at this point
	# in the code.	

	addi $v0, $zero, 10
	syscall



# Draws a 4x4 pixel box in the "Bitmap Display" tool
# $a0: row of box's upper-left corner
# $a1: column of box's upper-left corner
# $a2: colour of box

draw_bitmap_box:
	#stack to save variables
	addi $sp, $sp, -16
	sw $a0,12($sp)
	sw $a1,8($sp)
	sw $a2,4($sp)
	sw $ra,0($sp)
	#counters for looping (4x4)=16
	addi $t0, $zero, 4
	addi $t1, $zero, 4
	#start drawing
	jal loop_col
	#load back original values
	lw $ra,0($sp)
	lw $a2,4($sp)
	lw $a1,8($sp)
	lw $a0,12($sp)
	addi $sp, $sp, 16
	#return from whence you came 
	jr $ra

loop_col:
	#exit if looped 4 times
	beq $t1, $zero, exit
	#save variables for new jump
	addi $sp, $sp, -20
	sw $a1, 16($sp)
	sw $a0, 12($sp)
	sw $t0,8($sp)
	sw $t1,4($sp)
	sw $ra,0($sp)
	#drawing row by row
	jal loop_row
	
	lw $ra,0($sp)
	lw $t1,4($sp)
	lw $t0,8($sp)
	lw $a0,12($sp)
	sw $a1,16($sp)
	addi $sp, $sp, 20
	#increment/decrement
	addi $a1, $a1, 1
	addi $t1, $t1, -1
	#loop-dee-loop	
	beq $zero, $zero, loop_col
	
loop_row:
	#exit when looped 4 times
	beq $t0, $zero, exit
	#save current variables
	addi $sp, $sp, -20
	sw $a1, 16($sp)
	sw $a0, 12($sp)
	sw $t0,8($sp)
	sw $t1,4($sp)
	sw $ra,0($sp)
	#actually do the thing
	jal set_pixel
	#getting og variables
	lw $ra,0($sp)
	lw $t1,4($sp)
	lw $t0,8($sp)
	lw $a0,12($sp)
	sw $a1,16($sp)
	addi $sp, $sp, 20
	#increment/decrement
	addi $a0, $a0, 1
	addi $t0, $t0, -1
	#loop-dee-loop	
	beq $zero, $zero, loop_row
exit:
	#return from whence you came 
	jr $ra


	.kdata

	.ktext 0x80000180
#
# You can copy-and-paste some of your code from part (a)
# to provide elements of the interrupt handler.
#
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


.data

# Any additional .text area "variables" that you need can
# be added in this spot. The assembler will ensure that whatever
# directives appear here will be placed in memory following the
# data items at the top of this file.

	
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE
	
