	.include "display.asm"
	
	.data
	
GEN_A:	.space 256
GEN_B:	.space 256
GEN_Z:	.space 256

# Students may modify the ".data" and "main" section temporarily
# for their testing. However, when evaluating your submission, all
# code from lines 1 to 58 will be replaced by other testing code
# (i.e., we will only keep code from lines 59 onward). If your
# solution breaks because you have ignored this note, then a mark
# of zero for Part 4 of the assignment is possible.

PATTERN_GLIDER:
	.word   0x0000 0x0000 0x0000 0x0000 0x0000 0x0000 0x0000 0x0000
        	0x0000 0x0000 0x0000 0x0000 0x0e00 0x0200 0x0400 0x0000
        	
PATTERN_PULSAR:
	.word 	0x0000 0x0e38 0x0000 0x2142 0x2142 0x2142 0x0e38 0x0000
		0x0e38 0x2142 0x2142 0x2142 0x0000 0x0e38 0x0000 0x0000
		
PATTERN_PIPSQUIRTER:
	.word   0x0000 0x0020 0x0020 0x0000 0x0088 0x03ae 0x0431 0x0acd
        	0x0b32 0x6acc 0x6a90 0x06f0 0x0100 0x0140 0x00c0 0x0000
	
PATTERN_HONEYCOMB:
	.word   0x0000 0x0000 0x0000 0x0000 0x0000 0x0180 0x0240 0x05a0
        	0x0240 0x0180 0x0000 0x0000 0x0000 0x0000 0x0000 0x0000
       
PATTERN_EATER:
	.word   0x0000 0x0000 0x1800 0x24c0 0x2848 0x1054 0x0348 0x0240
        	0x1080 0x1f00 0x0000 0x0400 0x0a00 0x0407 0x0004 0x0002
        
	.globl main
	
	
	.text
main:
	la $a0, GEN_A
	la $a1, PATTERN_EATER
	jal bitmap_to_16x16		# Convert bitmap pattern...
	
	la $a0, GEN_A
	jal draw_16x16			# ... and draw it.
	
next_gen:
	jal life_next_generation	# Procedure uses 16x16 0/1 "dead/alive" data in GEN_A ...
	la $a0, GEN_A			# ... and then proceeds to draw the result ...
	jal draw_16x16
	
	addi $a0, $zero, 750		# 750 milliseconds (three-quarters of a second)
	addi $v0, $zero, 32		# sleep system call
	syscall
	
	#beq $zero, $zero, next_gen	# ... over and over again. Comment out this line if
					# you just want to try life_next_generation once during testing.

	addi $v0, $zero, 10
	syscall


# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

	.data
	
# Available for any extra `.eqv` or data needed for your solution.

	.text

		
# life_next_generation:
#
# This procedure HAS NO PARAMETERS.
#
# Use GEN_A as the generation to draw
#
# Use GEN_B as a scratch array to compute the
# next generation (i.e., compute the value
# of the next generation in GEN_B, and once
# completed, copy over GEN_B into GEN_A

life_next_generation:
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	
	add $s1, $zero, $zero
life_next_row:
	add $s2, $zero, $zero
life_next_col:
	la $a0, GEN_A
	add $a1, $zero, $s1
	add $a2, $zero, $s2
	jal sum_neighbours
	add $s0, $zero, $v0	# Number of live neighbours around row $s1, col $s2
	
	la $a0, GEN_A
	add $a1, $zero, $s1
	add $a2, $zero, $s2
	jal get_16x16		# Determine whether row $s1, col $s2 is currently alive
	beq $v0, $zero, life_check_for_birth	# Not alive -- so check if a birth may happen...
	
	# At this point, we have a live cell.
	# But should the cell stay alive?
	beq $s0, 2, life_staying_alive_staying_alive
	beq $s0, 3, life_staying_alive_staying_alive
	
	# At this point, we have a cell that must die
	beq $zero, $zero, life_cell_is_dead
	
life_staying_alive_staying_alive:
	la $a0, GEN_B
	add $a1, $zero, $s1
	add $a2, $zero, $s2
	addi $a3, $zero, 1
	jal set_16x16
	beq $zero, $zero, life_next_element
	
life_check_for_birth:
	bne $s0, 3, life_cell_is_dead
	la $a0, GEN_B
	add $a1, $zero, $s1
	add $a2, $zero, $s2
	addi $a3, $zero, 1
	jal set_16x16
	beq $zero, $zero, life_next_element
	
life_cell_is_dead:	
	la $a0, GEN_B
	add $a1, $zero, $s1
	add $a2, $zero, $s2
	add $a3, $zero, $zero
	jal set_16x16
	beq $zero, $zero, life_next_element

life_next_element:
	add $s2, $s2, 1			# DEBUG Z
	blt $s2, 16, life_next_col	
	add $s1, $s1, 1
	blt $s1, 16, life_next_row
	
	la $a0, GEN_A
	la $a1, GEN_B
	jal copy_16x16		# Copy scratch array back into main array
	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 16
	jr $ra



# Use here your solution to Part A for this function
# (i.e., copy-and-paste your code).
set_16x16:
	
	#check the numbers are between 0 and 15
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
	
	sb $a3, ($a0) #storing byte at correct location
	
	
	
	
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $t0, 8($sp)
	addi $sp, $sp, 12
	#going home
	jr $ra
	
	
	
# Use here your solution to Part A for this function
# (i.e., copy-and-paste your code).
get_16x16:
	#check the numbers are between 0 and 15
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
	
	lb $v0, ($a0) #load correct byte into $v0 
	
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $t0, 8($sp)
	addi $sp, $sp, 12
	jr $ra
	

# Use here your solution to Part A for this function
# (i.e., copy-and-paste your code).
copy_16x16:
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $t1, 12($sp)
	sw $t0, 8($sp)
	sw $a0, 4($sp)
	sw $a1, 16($sp)
	
	
	addi $t0, $a1, 255 #making sure we loop through entire array
loop:
	lw $t1, 0($a1) #load source
	sw $t1, 0($a0) #store into new array
		
	addi $a0, $a0, 4 #move up to next byte
	addi $a1, $a1, 4 #move up to next byte
	blt $a0, $t0, loop #until we're at the last number do it again!
	
	lw $ra, 0($sp)
	lw $a1, 16($sp)
	lw $a0, 4($sp)
	lw $t0, 8($sp)
	lw $t1, 12($sp)
	
	addi $sp, $sp, 20
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
	

# Use here your solution to Part C for this function
# (i.e., copy-and-paste your code).	
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
	
# Use here your solution to Part C for this function
# (i.e., copy-and-paste your code).		
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
	
exit:
	jr $ra

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE
