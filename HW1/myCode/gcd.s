.data
msg1:	.asciiz "Enter first number: "
msg2:	.asciiz "Enter second number: "
msg3: 	.asciiz "The GCD is: "
.text
.globl main

#------------------------- main -----------------------------
main:
# print msg1 on the console interface
		li      $v0, 4			# call system call: print string
		la      $a0, msg1		# load address of string into $a0
		syscall                 	# run the syscall
		
# read input a in $v0
 		li      $v0, 5          	# call system call: read integer
  		syscall                 	# run the syscall
  		move    $t0, $v0      		# store input a in $t0 
 
# print msg2 on the console interface
		li      $v0, 4			# call system call: print string
		la      $a0, msg2		# load address of string into $a0
		syscall                 	# run the syscall
		
# read the input integer in $v0
 		li      $v0, 5          	# call system call: read integer
  		syscall                 	# run the syscall
  		move    $t1, $v0      		# store input b in $t1 

# jump to procedure gcd
		move $a0, $t0			# $a0 = a
		move $a1, $t1			# $a1 = b
  		jal gcd
		move $t0, $v0			# save return value in t0 (because v0 will be used by system call) 

# print msg2 on the console interface
		li      $v0, 4			# call system call: print string
		la      $a0, msg3		# load address of string into $a0
		syscall                 	# run the syscall

# print the result of procedure factorial on the console interface
		move $a0, $t0			
		li $v0, 1			# call system call: print integer
		syscall 			# run the syscall
		li $v0, 10			# call system call: exit
  		syscall				# run the syscall

#------------------------- procedure gcd -----------------------------

# load argument a in $a0, b in $a1, return value in $v0. 
.text
gcd:		addi 	$sp, $sp, -4		# adjust stack for 1 item
		sw 	$ra, 0($sp)		# save the return address
		div 	$a0, $a1 		# a/b
		mfhi 	$t0 			# $t1 = a%b
		bne 	$t0, $zero, L1		# go to L1 if a%b != 0

# if(a%b == 0)
		move 	$v0, $a1		# return b
		addi 	$sp, $sp, 4		# pop 1 item off stack
		jr 	$ra			# return to caller

# if(a%b != 0)
L1:		div 	$a0, $a1 		# a/b
		mfhi 	$t0 			# $t1 = a%b
		move 	$a0, $a1		# first argument = b
		move 	$a1, $t0		# second argument = a%b
		jal 	gcd			# call gcd(b, a%b)

# return from jal	
		lw 	$ra, 0($sp)		# restore the return address
		addi 	$sp, $sp, 4		# adjust stack pointer to pop 1 item
		jr 	$ra			# return to the caller

