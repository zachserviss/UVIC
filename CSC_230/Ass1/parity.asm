# UVic CSC 230, Summer 2020
# Assignment #1, part A

# Student name: Zach Serviss
# Student number: V00950002


# Compute even parity of word that must be in register $8
# Value of even parity (0 or 1) must be in register $15


.text

start:
	lw $8, testcase3  # STUDENTS MAY MODIFY THE TESTCASE GIVEN IN THIS LINE
	
# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	
	#set register 9 as 0
	addi $9, $9, 0
loop:
	#count the number of bits set in register 8 until that register is empty
	beq $8,$0, mod
	andi $10, $8, 1
	add $9, $9, $10
	srl $8,$8,1
	beq, $0, $0, loop
	
mod:
	#return the modulo of register 9 and 2 (even number of bits are 0, odd is 1)
	and $15, $9, 1
	beq, $0, $0, exit

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE


exit:
	add $2, $0, 10
	syscall
		

.data

testcase1:
	.word	0x00200020    # even parity is 0

testcase2:
	.word 	0x00300020    # even parity is 1
	
testcase3:
	.word  0x1234fedc     # even parity is is 1

