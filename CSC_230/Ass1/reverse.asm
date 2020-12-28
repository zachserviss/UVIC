# UVic CSC 230, Summer 2020
# Assignment #1, part B

# Student name: Zach Serviss
# Student number: V00950002



# Compute the reverse of the input bit sequence that must be stored
# in register $8, and the reverse must be in register $15.


.text
start:
	lw $8, testcase2   # STUDENTS MAY MODIFY THE TESTCASE GIVEN IN THIS LINE
	
# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	#set register 9 as counter(for all 32 bits)
	addi $9, $9, 32
	addi $15, $15, 0
	
loop:
	#loop through adding least significant bit to r15 most significant
	beq $9,$0, exit
	sll $15, $15, 1
	and $16, $8, 1
	add $15, $15, $16
	srl $8, $8, 1
	addi $9, $9, -1
	beq, $0, $0, loop

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE

exit:
	add $2, $0, 10
	syscall
	
	

.data

testcase1:
	.word	0x00200020    # reverse is 0x04000400

testcase2:
	.word 	0x00300020    # reverse is 0x04000c00
	
testcase3:
	.word	0x1234fedc     # reverse is 0x3b7f2c48
