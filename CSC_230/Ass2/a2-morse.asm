.text


main:	



# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

	## Test code that calls procedure for part A
	#jal save_our_souls

	## morse_flash test for part B
	#addi $a0, $zero, 0x42   # dot dot dash dot
	#jal morse_flash
	
	## morse_flash test for part B
	#addi $a0, $zero, 0x37   # dash dash dash
	#jal morse_flash
		
	## morse_flash test for part B
	#addi $a0, $zero, 0x32  	# dot dash dot
	#jal morse_flash
			
	## morse_flash test for part B
	#addi $a0, $zero, 0x11   # dash
	#jal morse_flash
	
	#addi $a0, $zero, 0xff   # dash
	#jal morse_flash	
	
	# flash_message test for part C
	#la $a0, test_buffer
	#jal flash_message
	
	# letter_to_code test for part D
	# the letter 'P' is properly encoded as 0x46.
	#addi $a0, $zero, 'P'
	#jal letter_to_code
	
	# letter_to_code test for part D
	# the letter 'A' is properly encoded as 0x21
	#addi $a0, $zero, 'A'
	#jal letter_to_code
	
	# letter_to_code test for part D
	# the space' is properly encoded as 0xff
	#addi $a0, $zero, ' '
	#jal letter_to_code
	
	# encode_message test for part E
	# The outcome of the procedure is here
	# immediately used by flash_message
	la $a0, message01
	la $a1, buffer01
	jal encode_message
	la $a0, buffer01
	jal flash_message

	
	# Proper exit from the program.
	addi $v0, $zero, 10
	syscall

	
###########
# PROCEDURE
save_our_souls:
	addi $sp, $sp, -4 #to get back home
	sw $ra, 0($sp)
	jal dot 
	jal dot
	jal dot
	jal dash
	jal dash 
	jal dash
	jal dot
	jal dot
	jal dot
	lw $ra, 0($sp) 
	addi $sp, $sp, 4
	jr $ra


# PROCEDURE
morse_flash:
	addi $sp, $sp, -8 #to get back home
	sw $a0, 4($sp)
	sw $ra, 0($sp)
	
	beq $a0, 0xff, leds_off_morse_flash #if ff, wait, then do nothing

	
	jal length #get length 
	jal morse_code #reverses bits so its easier to read off
	jal flash# you got the stuff, now FLASH
	
leds_off_morse_flash:
	jal leds_off	
	
	
	lw $ra, 0($sp) 
	lw $a0, 4($sp)
	addi $sp, $sp, 8 #headin home
	jr $ra

###########
# PROCEDURE
flash_message:
	addi $sp, $sp, -12 #to get back home
	sw $a0, 8($sp)
	sw $ra, 4($sp)
	
flash_message_loop:	
	lbu $s0, 0($a0) #load first byte
	beq $s0, $0, flash_message_finish #if at the end, head home
	sw $a0, 0($sp) #to not lose track of orginal message
	add $a0, $zero, $s0 #store single byte as argument
	
	jal morse_flash #pass to flash message with byte as argument
	lw $a0, 0($sp)# back to normal message
	addi $a0, $a0, 1#next byte
	beq $0, $0, flash_message_loop #do it again!
	
	
flash_message_finish:
	lw $ra, 4($sp)	
	lw $a0, 8($sp) 
	addi $sp, $sp, 12 #heding home
	jr $ra
	
	
###########
# PROCEDURE
letter_to_code:
	addi $sp, $sp, -12 #to get back home
	sw $a0, 8($sp)
	sw $ra, 4($sp)
	la $s1, codes #store array in s1
	add $s0, $a0, $0 #store letter in s0
	addi $t7, $0, 0 #reset variables to zero for next time its called
	addi $s4, $0, 0
	addi $s3, $0, 0
	addi $t7, $t7, 26 #outloop count(all 26 letters)
letter_to_code_loop:	
	lb  $t0, 0($s1) #store letter in t0
	beq $0, $t7, no_match #gone through entire alphabet, no match
	beq $t0, $s0, match #found the letter, go to match
	addi $s1, $s1, 8 #get next letter from alphabet
	addi $t7, $t7, -1 #decrement letter count
	beq $0, $0, letter_to_code_loop #do it again!
match:
	addi $s4, $s4, 1 #increment size
	addi $s1, $s1, 1 #increment bit position
	
	lbu $t0, 0($s1) #load dot or dash from codes
	beq $0, $t0, letter_to_code_exit #exit when bit is 0
	sw $s1, 0($sp) #to keep track of morse code
	
	beq $t0, '.', dot_letter #add 0 in the bit place
	beq $t0, '-', dash_letter #add 1 to the bit place
	
	lw $s1, 0($sp)
	beq $0, $0, match
no_match:
	addi $v0, $0, 0xff #no match, therefore its a space
	lw $ra, 4($sp)	 
	lw $a0, 8($sp) 
	addi $sp, $sp, 12 #beam me up scottie 
	jr $ra

letter_to_code_exit:
	addi $s4, $s4, -1 # started at one so minus one for length of code
	sll $s4, $s4, 4 #shift over to add in the 4 code bits
	add $v0, $s3, $s4 #adding bits to the length
	lw $ra, 4($sp)	 
	lw $a0, 8($sp) 
	addi $sp, $sp, 12 #beam me up scottie 
	jr $ra	

dash_letter: #adds 1 to the appropriate bit place
	sll $s3, $s3, 1
	addi $s3, $s3, 1
	beq $0, $0, match
dot_letter:#adds 0 to the appropriate bit place
	sll $s3, $s3, 1
	addi $s3, $s3, 0
	beq $0, $0, match


###########
# PROCEDURE
encode_message:
	addi $sp, $sp, -16 #to get back home
	sw $a0, 12($sp)
	sw $ra, 8($sp)
	sw $a1, 4($sp)
	
encode_message_loop:
	
	lb $s0, 0($a0) #load first letter
	beq $s0, $0, encode_message_finish #got to the end of the message
	sw $a0, 0($sp) #storing orginal argument
	
	add $a0, $zero, $s0 #sending the one letter to be coded
	
	jal letter_to_code #coding that one letter
	
	
	lw $a0, 0($sp)# load orginal message back
	addi $a0, $a0, 1 #next byte in message
	sb $v0, 0($a1) #storing hex code in buffer array 
	add $v0, $0, $0 #zero our v0 for next value
	addi $a1, $a1, 1 #next empty slot in buffer
	beq $0, $0, encode_message_loop #loop-de-loop
	
	
encode_message_finish:
	lw $a1, 4($sp)
	lw $ra, 8($sp)	 
	lw $a0, 12($sp) 
	add $a0, $0, $a1
	addi $sp, $sp, 16 #i wanna go home
	jr $ra

###########
# PROCEDUREs/helpers
dot:	#makes a dot
	addi $sp, $sp, -4 #to get back home
	sw $ra, 0($sp)
	jal seven_segment_on 
	jal delay_short
	jal seven_segment_off 
	jal delay_long
	lw $ra, 0($sp) 
	addi $sp, $sp, 4
	jr $ra

dash:	#makes a dash
	addi $sp, $sp, -4 
	sw $ra, 0($sp)
	jal seven_segment_on 
	jal delay_long
	jal seven_segment_off 
	jal delay_long
	lw $ra, 0($sp) 
	addi $sp, $sp, 4
	jr $ra

leds_off:#i bet you can guess what this does (hint:turns off the leds)
	addi $sp, $sp, -4 
	sw $ra, 0($sp)
	
	jal seven_segment_off 
	jal delay_long 
	jal delay_long
	jal delay_long
	
	lw $ra, 0($sp) 
	addi $sp, $sp, 4
	jr $ra

					
ff_check:
	addi $sp, $sp, -4 
	sw $ra, 0($sp)
	
	beq $a0, -1, leds_off
	beq $a0, 0xff, leds_off
	
	lw $ra, 0($sp) 
	addi $sp, $sp, 4
	jr $ra					

length:	#get length by deleting first 4 bits of a number
	addi $sp, $sp, -8 #to get back home
	sw $ra, 4($sp)
	sw $a0, 0($sp)

	srl $s0, $a0, 4 #shift rights by 4 bits to obtain length of code and store in s0
		
	

	lw $a0, 0($sp) 
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	jr $ra

morse_code: #reverse bits to properly read in the morse code
	addi $sp, $sp, -12 #to get back home
	sw $a0, 8($sp)
	sw $ra, 4($sp)
	sw $s0, 0($sp)
	
	beq $a0, -1, return
loop:	#reverse first $s0-bits 
	beq $s0,$0,return
	sll $s1, $s1, 1 #shift new number left
	and $t0, $a0, 1 #and number with one  (stored in $t0)
	add $s1, $s1, $t0 #add result of and op to the number
	srl $a0, $a0, 1 #shift right one to store in next bit
	addi $s0, $s0, -1 #increment
	beq, $0, $0, loop
return:	
	lw $s0, 0($sp) 
	lw $ra, 4($sp)
	lw $a0, 8($sp)
	addi $sp, $sp, 12#going home
	jr $ra		
	
	
flash:	
	addi $sp, $sp, -8 #to get back home
	sw $ra, 4($sp)
	beq $a0, 0xff, leds_off_flash#special off hex number
flash_loop:	
	beq $s0,$0,exit
	and $t0, $s1, 1 #dot or dash
	beq $t0, $0, dot_flash
	beq $t0, 1, dash_flash
increment:	
	srl $s1, $s1, 1 #shift to get next bit
	addi $s0, $s0, -1 #decrement length
	beq $0, $0, flash_loop #do it again please
leds_off_flash:
	jal leds_off	
exit:
	lw $ra, 4($sp)
	addi $sp, $sp, 8 #time to head back to once we came from
	jr $ra
			
dash_flash:
	jal dash
	beq $0, $0, increment
dot_flash:
	jal dot
	beq $0, $0, increment	
				
	
		

	

	
		

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE

#############################################
# DO NOT MODIFY ANY OF THE CODE / LINES BELOW

###########
# PROCEDURE
seven_segment_on:
	la $t1, 0xffff0010     # location of bits for right digit
	addi $t2, $zero, 0xff  # All bits in byte are set, turning on all segments
	sb $t2, 0($t1)         # "Make it so!"
	jr $31


###########
# PROCEDURE
seven_segment_off:
	la $t1, 0xffff0010	# location of bits for right digit
	sb $zero, 0($t1)	# All bits in byte are unset, turning off all segments
	jr $31			# "Make it so!"
	

###########
# PROCEDURE
delay_long:
	add $sp, $sp, -4	# Reserve 
	sw $a0, 0($sp)
	addi $a0, $zero, 600
	addi $v0, $zero, 32
	syscall
	lw $a0, 0($sp)
	add $sp, $sp, 4
	jr $31

	
###########
# PROCEDURE			
delay_short:
	add $sp, $sp, -4
	sw $a0, 0($sp)
	addi $a0, $zero, 200
	addi $v0, $zero, 32
	syscall
	lw $a0, 0($sp)
	add $sp, $sp, 4
	jr $31




#############
# DATA MEMORY
.data
codes:
	.byte 'A', '.', '-', 0, 0, 0, 0, 0
	.byte 'B', '-', '.', '.', '.', 0, 0, 0
	.byte 'C', '-', '.', '-', '.', 0, 0, 0
	.byte 'D', '-', '.', '.', 0, 0, 0, 0
	.byte 'E', '.', 0, 0, 0, 0, 0, 0
	.byte 'F', '.', '.', '-', '.', 0, 0, 0
	.byte 'G', '-', '-', '.', 0, 0, 0, 0
	.byte 'H', '.', '.', '.', '.', 0, 0, 0
	.byte 'I', '.', '.', 0, 0, 0, 0, 0
	.byte 'J', '.', '-', '-', '-', 0, 0, 0
	.byte 'K', '-', '.', '-', 0, 0, 0, 0
	.byte 'L', '.', '-', '.', '.', 0, 0, 0
	.byte 'M', '-', '-', 0, 0, 0, 0, 0
	.byte 'N', '-', '.', 0, 0, 0, 0, 0
	.byte 'O', '-', '-', '-', 0, 0, 0, 0
	.byte 'P', '.', '-', '-', '.', 0, 0, 0
	.byte 'Q', '-', '-', '.', '-', 0, 0, 0
	.byte 'R', '.', '-', '.', 0, 0, 0, 0
	.byte 'S', '.', '.', '.', 0, 0, 0, 0
	.byte 'T', '-', 0, 0, 0, 0, 0, 0
	.byte 'U', '.', '.', '-', 0, 0, 0, 0
	.byte 'V', '.', '.', '.', '-', 0, 0, 0
	.byte 'W', '.', '-', '-', 0, 0, 0, 0
	.byte 'X', '-', '.', '.', '-', 0, 0, 0
	.byte 'Y', '-', '.', '-', '-', 0, 0, 0
	.byte 'Z', '-', '-', '.', '.', 0, 0, 0
	
message01:	.asciiz "AAAAAAA"
message02:	.asciiz "SOS"
message03:	.asciiz "WATERLOO"
message04:	.asciiz "DANCING QUEEN"
message05:	.asciiz "CHIQUITITA"
message06:	.asciiz "THE WINNER TAKES IT ALL"
message07:	.asciiz "MAMMA MIA"
message08:	.asciiz "TAKE A CHANCE ON ME"
message09:	.asciiz "KNOWING ME KNOWING YOU"
message10:	.asciiz "FERNANDO"

buffer01:	.space 128
buffer02:	.space 128
test_buffer:	.byte 0x30 0x37 0x30 0x00    # This is SOS
