	.include "display.asm"
	.data
	
GEN_A:	.space 256
GEN_B:	.space 256
GEN_Z:	.space 256


# Students may modify the ".data" and "main" section temporarily
# for their testing. However, when evaluating your submission, all
# code from lines 1 to 33 will be replaced by other testing code
# (i.e., we will only keep code from lines 34 onward). If your
# solution breaks because you have ignored this note, then a mark
# of zero for Part 3 of the assignment is possible.

TEST_PATTERN:
	.word   0x0000 0x0000 0x0ff8 0x1004 0x0000 0x0630 0x0000 0x0080
        	0x0080 0x2002 0x1004 0x0808 0x0630 0x01c0 0x0000 0x0000

		
	.text
main:
	la $a0, GEN_A
	la $a1, TEST_PATTERN
	jal bitmap_to_16x16
	
	la $a0, GEN_A
	jal draw_16x16
			
	addi $v0, $zero, 10
	syscall
	

# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

	.data
	
# Available for any extra `.eqv` or data needed for your solution.

	.text
	

# bitmap_to_16x16:
#	
# $a0 is destination 16x16 byte array
# $a1 is the start address of the pattern as encoded in a 16-word
#     sequence of row bitmaps.
#
# $v0 holds the value of the bytes around the row and column
# 
# Please see the assignment description for more
# information regarding the expected behavior of
# this function.

bitmap_to_16x16:
	addi $sp, $sp, -24
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	
	add $s0, $zero, $a0	# $s0 is the 16x16 byte array we're initializing
	add $s4, $zero, $a1	# $s4 is the address of the pattern in memory
	
	add $s1, $zero, $zero	# $s1 is the current row
bitmap_to_16x16_row:
	lw $s3, 0($s4)		# $s3 is the pattern value of the current row
	add $s2, $zero, $zero	# $s2 is the current column
bitmap_to_16x16_column:
	add $a0, $zero, $s0
	add $a1, $zero, $s1	
	add $a2, $zero, $s2
	andi $a3, $s3, 0x01	# take advantage of the fact we store 0 or 1 in 16x16 byte array	
	jal set_16x16
	
	addi $s2, $s2, 1	# next column ...
	srl $s3, $s3, 1		# ... but make sure to advance to next bit in pattern for current row.
	blt $s2, 16, bitmap_to_16x16_column	# I give up. Time to use more pseudo-instructions...
	
	addi $s1, $s1, 1	# next row...
	addi $s4, $s4, 4	# ... and advance to address of next row's pattern
	blt $s1, 16, bitmap_to_16x16_row
	
	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)	
	addi $sp, $sp, 24
	jr $ra
	
	
# draw_16x16:
#
# $a0 holds the start address of the 16x16 byte array 
# holding the pattern for the Bitmap Display tool.
#
# Assumption: A value of 0 at a specific row and column means
# the pixel at the row & column in the bitmap display is
# off (i.e., black). A value of 1 at a specific row and column
# means the pixel at the row & column in the bitmap display
# is on (i.e., white). All other values (i.e., 2 and greater)
# are ignored.

draw_16x16:
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	
	add $s0, $zero, $a0	# $s0 is the location of source 16x16 byte array
	
	add $s1, $zero, $zero	# $s1 is the current row
draw_16x16_row:
	add $s2, $zero, $zero	# $s2 is the current column
draw_16x16_col:
	add $a0, $zero, $s0
	add $a1, $zero, $s1
	add $a2, $zero, $s2
	jal get_16x16

	add $a0, $zero, $s1
	add $a1, $zero, $s2
	sub $a2, $zero, $v0	# Converting 0x01 to 0xffffffff, and leaving 0x0 as 0x00000000
	jal set_pixel

	addi $s2, $s2, 1
	blt $s2, 16, draw_16x16_col
	addi $s1, $s1, 1
	blt $s1, 16, draw_16x16_row
	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)	
	addi $sp, $sp, 16
	jr $ra


# Use here your solution to Part B for this function
# (i.e., copy-and-paste your code).
sum_neighbours:
	# sanity check: 0 <= row < 16? 0 <= col < 16?
	bltz $a1, exit
	bge $a1, 16, exit
	bltz $a2, exit
	bge $a2, 16, exit
	
	addi $sp, $sp, -20
	
	sw $a0, 4($sp)
	sw $ra, 0($sp)
	
	#top left
	sw $t0, 8($sp)
	sw $a1, 12($sp)
	sw $a2, 16($sp)
	addi $a1, $a1, -1#row
	addi $a2, $a2, -1#col
	jal get_16x16
	lw $t0, 8($sp)
	lw $a1, 12($sp)
	lw $a2, 16($sp)
	add $t0, $t0, $v0
	add $v0, $zero, $zero
	#top middle
	sw $t0, 8($sp)
	sw $a1, 12($sp)
	sw $a2, 16($sp)
	addi $a1, $a1, -1#row
	jal get_16x16
	lw $t0, 8($sp)
	lw $a1, 12($sp)
	lw $a2, 16($sp)
	add $t0, $t0, $v0
	add $v0, $zero, $zero
	#top right
	sw $t0, 8($sp)
	sw $a1, 12($sp)
	sw $a2, 16($sp)
	addi $a1, $a1, -1#row
	addi $a2, $a2, 1#col
	jal get_16x16
	lw $t0, 8($sp)
	lw $a1, 12($sp)
	lw $a2, 16($sp)
	add $t0, $t0, $v0
	add $v0, $zero, $zero
	#left
	sw $t0, 8($sp)
	sw $a1, 12($sp)
	sw $a2, 16($sp)
	addi $a2, $a2, -1#col
	jal get_16x16
	lw $t0, 8($sp)
	lw $a1, 12($sp)
	lw $a2, 16($sp)
	add $t0, $t0, $v0
	add $v0, $zero, $zero
	#right
	sw $t0, 8($sp)
	sw $a1, 12($sp)
	sw $a2, 16($sp)
	addi $a2, $a2, 1#col
	jal get_16x16
	lw $t0, 8($sp)
	lw $a1, 12($sp)
	lw $a2, 16($sp)
	add $t0, $t0, $v0
	add $v0, $zero, $zero
	#bottom left
	sw $t0, 8($sp)
	sw $a1, 12($sp)
	sw $a2, 16($sp)
	addi $a1, $a1, 1#row
	addi $a2, $a2, -1#col
	jal get_16x16
	lw $t0, 8($sp)
	lw $a1, 12($sp)
	lw $a2, 16($sp)
	add $t0, $t0, $v0
	add $v0, $zero, $zero
	#bottom middle
	sw $t0, 8($sp)
	sw $a1, 12($sp)
	sw $a2, 16($sp)
	addi $a1, $a1, 1#row
	jal get_16x16
	lw $t0, 8($sp)
	lw $a1, 12($sp)
	lw $a2, 16($sp)
	add $t0, $t0, $v0
	add $v0, $zero, $zero
	#bottom right
	sw $t0, 8($sp)
	sw $a1, 12($sp)
	sw $a2, 16($sp)
	addi $a1, $a1, 1#row
	addi $a2, $a2, 1#col
	jal get_16x16
	lw $t0, 8($sp)
	lw $a1, 12($sp)
	lw $a2, 16($sp)
	add $t0, $t0, $v0
	add $v0, $zero, $zero
	
	add $v0, $t0, $zero
	
	
	
	
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	sw $t0, 8($sp)
	addi $sp, $sp, 12
	
	jr $ra
	
	
# Use here your solution to Part A for this function
# (i.e., copy-and-paste your code).
set_16x16:
	# sanity check: 0 <= row < 16? 0 <= col < 16?
	bltz $a1, exit
	bge $a1, 16, exit
	bltz $a2, exit
	bge $a2, 16, exit
	
	addi $sp, $sp, -12
	sw $t0, 8($sp)
	sw $a0, 4($sp)
	sw $ra, 0($sp)
	
	
	sll $t0, $a1, 4 #times row by 16
	add $t0, $t0, $a2 #add col value to number
	add $a0, $a0, $t0 #adding offset 
	
	sb $a3, ($a0) 
	
	
	
	
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	sw $t0, 8($sp)
	addi $sp, $sp, 12
	jr $ra
	
	
	
# Use here your solution to Part A for this function
# (i.e., copy-and-paste your code).
get_16x16:
	# sanity check: 0 <= row < 16? 0 <= col < 16?
	bltz $a1, exit
	bge $a1, 16, exit
	bltz $a2, exit
	bge $a2, 16, exit
	
	addi $sp, $sp, -12
	sw $t0, 8($sp)
	sw $a0, 4($sp)
	sw $ra, 0($sp)
	
	
	sll $t0, $a1, 4 #times row by 16
	add $t0, $t0, $a2 #add col value to number
	add $a0, $a0, $t0 #adding offset 
	
	lb $v0, ($a0) 
	
	
	
	
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	sw $t0, 8($sp)
	addi $sp, $sp, 12
	jr $ra
	

# Use here your solution to Part A for this function
# (i.e., copy-and-paste your code).
copy_16x16:

	addi $t0, $a1, 255
loop:
	lw $at, 0($a1)
	sw $at, 0($a0)
		
	addi $a0, $a0, 4 
	addi $a1, $a1, 4 
	blt $a0, $t0, loop
	
	jr $ra

exit:
	jr $ra	
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE
