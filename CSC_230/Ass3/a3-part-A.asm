
	.data
ARRAY_A:
	.word	21, 210, 49, 4
ARRAY_B:
	.word	21, -314159, 0x1000, 0x7fffffff, 3, 1, 4, 1, 5, 9, 2
ARRAY_Z:
	.space	28
NEWLINE:
	.asciiz "\n"
SPACE:
	.asciiz " "
		
	
	.text  
main:	
	la $a0, ARRAY_A
	addi $a1, $zero, 4
	jal dump_array
	
	la $a0, ARRAY_B
	addi $a1, $zero, 11
	jal dump_array
	
	la $a0, ARRAY_Z
	lw $t0, 0($a0)
	addi $t0, $t0, 1
	sw $t0, 0($a0)
	addi $a1, $zero, 9
	jal dump_array
		
	addi $v0, $zero, 10
	syscall

# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	
	
dump_array:
	bge $t7, $a1, exit #counter, print new line and reset counter when at the end of the array 
	addi $sp, $sp, -4
	sw $a0, 0($sp) #to not mix up arguments as they're passed
	
	lw $a0, 0($a0) #store int in $a0 to ping out
	addi $v0, $zero, 1
	syscall
	
	la $a0, SPACE #pring a space
	addi $v0, $zero, 4
	syscall
	
	lw $a0, 0($sp) #load back og argument (array address)
	addi $a0, $a0, 4 #increment to next int
	addi $t7, $t7, 1 #increment counter
	addi $sp, $sp, 4 #beam me up scotty
	beq $zero, $zero, dump_array	
exit:
	add $t7, $zero, $zero
	la $a0, NEWLINE
	addi $v0, $zero, 4
	syscall
	jr  $ra
	
	
	
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE
