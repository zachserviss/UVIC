	.data
	
TEST_A_16x16:
	.byte  	9 3 8 5 7 0 8 3 9 3 4 7 3 5 7 1
       		4 3 2 1 7 8 5 3 7 5 3 6 6 3 1 6
       		7 4 3 1 9 5 4 6 6 3 6 1 6 6 0 7
       		3 8 1 5 0 5 5 0 4 9 2 0 6 2 4 1
       		2 6 5 9 7 2 7 8 4 2 8 0 1 1 0 9
       		5 8 7 1 9 9 7 2 2 3 8 7 2 1 2 4
       		5 6 1 0 8 8 5 7 0 3 4 5 1 4 2 4
       		7 3 6 1 8 5 3 1 4 2 0 0 6 9 7 9
       		0 5 3 4 7 3 8 9 8 5 5 0 2 4 5 5
       		6 6 0 3 8 1 3 2 1 2 5 1 5 0 7 3
       		5 8 8 3 2 7 8 8 5 4 4 4 3 6 3 7
       		4 0 3 0 9 5 7 7 0 4 8 3 0 7 9 0
       		0 6 7 4 9 2 7 0 0 4 9 1 1 9 7 5
       		8 1 2 7 6 1 4 0 3 5 3 8 1 3 3 2
       		2 9 3 7 2 0 3 8 8 3 1 9 8 0 5 8
       		2 9 7 2 1 1 0 7 9 9 9 9 1 4 6 2
	
	.text
main:

# Students may modify this "main" section temporarily for their testing.
# However, when evaluating your submission, all code from lines 1
# to 49 will be replaced by other testing code (i.e., we will only
# keep code from lines 50 onward). If your solution breaks because
# you have ignored this note, then a mark of zero for Part 2
# of the assignment is possible.

	#la $a0, TEST_A_16x16
	#addi $a1, $zero, 4
	#addi $a2, $zero, 0
	#jal sum_neighbours		# Test 2a; $v0 should be 30
	
	#la $a0, TEST_A_16x16
	#addi $a1, $zero, 9
	#addi $a2, $zero, 8
	#jal sum_neighbours		# Test 2b; $v0 should be 43
	
	la $a0, TEST_A_16x16
	addi $a1, $zero, 15
	addi $a2, $zero, 15
	jal sum_neighbours		# Test 2c; $v0 should be 19
			
	addi $v0, $zero, 10
	syscall


# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

	.data
	
# Available for any extra `.eqv` or data needed for your solution.

	.text
	
	
# sum_neighbours:
#
# $a0 is 16x16 byte array
# $a1 is row (0 is topmost)
# $a2 is column (0 is leftmost)
#
# $v0 holds the value of the bytes around the row and column
sum_neighbours:
	# sanity check: 0 <= row < 16? 0 <= col < 16?
	bltz $a1, exit
	bge $a1, 16, exit
	bltz $a2, exit
	bge $a2, 16, exit
	#set t0 and v0 to zero if values are already in there
	add $v0, $zero, $zero
	add $t0, $zero, $zero
	
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
	add $t0, $t0, $v0 #add to temp value
	add $v0, $zero, $zero #zero out
	#top middle
	sw $t0, 8($sp)
	sw $a1, 12($sp)
	sw $a2, 16($sp)
	addi $a1, $a1, -1#row
	jal get_16x16
	lw $t0, 8($sp)
	lw $a1, 12($sp)
	lw $a2, 16($sp)
	add $t0, $t0, $v0 #add to temp value
	add $v0, $zero, $zero #zero out
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
	add $t0, $t0, $v0 #add to temp value
	add $v0, $zero, $zero #zero out
	#left
	sw $t0, 8($sp)
	sw $a1, 12($sp)
	sw $a2, 16($sp)
	addi $a2, $a2, -1#col
	jal get_16x16
	lw $t0, 8($sp)
	lw $a1, 12($sp)
	lw $a2, 16($sp)
	add $t0, $t0, $v0 #add to temp value
	add $v0, $zero, $zero #zero out
	#right
	sw $t0, 8($sp)
	sw $a1, 12($sp)
	sw $a2, 16($sp)
	addi $a2, $a2, 1#col
	jal get_16x16
	lw $t0, 8($sp)
	lw $a1, 12($sp)
	lw $a2, 16($sp)
	add $t0, $t0, $v0 #add to temp value
	add $v0, $zero, $zero #zero out
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
	add $t0, $t0, $v0 #add to temp value
	add $v0, $zero, $zero #zero out
	#bottom middle
	sw $t0, 8($sp)
	sw $a1, 12($sp)
	sw $a2, 16($sp)
	addi $a1, $a1, 1#row
	jal get_16x16
	lw $t0, 8($sp)
	lw $a1, 12($sp)
	lw $a2, 16($sp)
	add $t0, $t0, $v0 #add to temp value
	add $v0, $zero, $zero #zero out
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
	add $t0, $t0, $v0 #add to temp value
	add $v0, $zero, $zero #zero out
	
	add $v0, $t0, $zero #store whats in temp value in v0 to send back correct answer
	
	
	
	
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	addi $sp, $sp, 20
	
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
	sw $t1, 12($sp)
	sw $t0, 8($sp)
	sw $a0, 4($sp)
	sw $a1, 16($sp)
	sw $ra, 0($sp)
	
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

exit:
	jr $ra
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE
