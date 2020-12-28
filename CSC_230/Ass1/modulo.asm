# UVic CSC 230, Summer 2020
# Assignment #1, part A

# Student name: Zach Serviss
# Student number: V00950002


# Compute M % N, where M must be in $8, N must be in $9,
# and M % N must be in $15.


.text
start:
	lw $8, testcase2_M
	lw $9, testcase2_N

# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	#check if M or N is 0 or negative, check N for being less than 128
	#addi $11, $11, 128
	#slt $10, $9, $11
	blez $8, error
	blez $9, error
	#blez $10, error
loop:
	#subtract until negative
	sub $8, $8, $9
	bltz $8, mod
	beq, $0, $0, loop
	
error:
	
	addi $15, $15, -1
	beq, $0, $0, exit
mod:
	#add back one N to get modulo
	add $15, $9, $8

	

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE

exit:
	add $2, $0, 10
	syscall
		

.data

# testcase1: 370 % 120 = 10
#
testcase1_M:
	.word	370
testcase1_N:
	.word 	120
	
# testcase2: 24156 % 77 = 55
#
testcase2_M:
	.word	123456
testcase2_N:
	.word 	1179

# testcase3: 21 % 0 = -1
#
testcase3_M:
	.word	21
testcase3_N:
	.word 	0
	
# testcase4: 33 % 120 = 33
#
testcase4_M:
	.word	33
testcase4_N:
	.word 	120
