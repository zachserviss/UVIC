# UVic CSC 230, Summer 2020
#
# Howdy, world!

	.data
howdy_string:
	.asciiz	"\nHello! My name is Zach Serviss!\n\n"
howdy_number:
	.asciiz "V00950002\n"
	
	
	.text
main:
	li	$v0, 4
	la	$a0, howdy_string
	syscall
	
	li	$v0, 4
	la	$a0, howdy_number
	syscall
	
	li	$v0, 10
	syscall
