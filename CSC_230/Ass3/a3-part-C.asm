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
	
	.globl main
	.text	
main:
	addi $a0, $zero, 0
	addi $a1, $zero, 0
	addi $a2, $zero, 0x00ff0000
	jal draw_bitmap_box
	
	addi $a0, $zero, 11
	addi $a1, $zero, 6
	addi $a2, $zero, 0x00ffff00
	jal draw_bitmap_box
	
	addi $a0, $zero, 8
	addi $a1, $zero, 8
	addi $a2, $zero, 0x0099ff33
	jal draw_bitmap_box
	
	addi $a0, $zero, 2
	addi $a1, $zero, 3
	addi $a2, $zero, 0x00000000
	jal draw_bitmap_box

	addi $v0, $zero, 10
	syscall
	
# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv


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
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE
