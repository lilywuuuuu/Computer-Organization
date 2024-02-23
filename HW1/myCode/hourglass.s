.data
msg1:	.asciiz "Enter the number n = "
sp:	.asciiz " " 	# space
star: 	.asciiz "*"
nl:	.asciiz "\n" 	# newline
.text
.globl main

#------------------------- main -----------------------------
main:
# make room for $s on stack
		addi 	$sp, $sp, -16		# make room on stack for 4 registers
		sw 	$s3, 12($sp)		# save $s3 = temp on stack
		sw	$s2, 8($sp) 		# save $s2 = n on stack 
		sw 	$s1, 4($sp)		# save $s1 = j on stack
		sw	$s0, 0($sp)		# save $s0 = i on stack

# print msg1 on the console interface
		li      $v0, 4			# call system call: print string
		la      $a0, msg1		# load address of string into $a0
		syscall                 	# run the syscall
		
# read the input integer in $v0
 		li      $v0, 5          	# call system call: read integer
  		syscall                 	# run the syscall
  		move    $s2, $v0      		# store input n in $s2 

# temp = (n+1)/2, save temp in $a1
  		add	$s3, $s2, $zero		# temp = n
  		addi	$s3, $s3, 1		# temp = n+1
  		addi	$t0, $zero, 2		# $t0 = 2
  		div	$s3, $t0		# (n+1)/2
  		mflo	$s3			# save quotient in temp 
  		
# if(n%2 == 1) temp--
		div 	$s2, $t0 		# n/2
		mfhi	$t1			# $t1 = n%2
		beq	$t1, $zero, L1		# if $t1 == 0 go to L1
 		addi 	$s3, $s3, -1 		# temp - 1
  		
# upper half of the hourglass
L1:		move 	$s0, $zero		# i = 0
outerloop1: 	slt 	$t1, $s0, $s3 		# $t1 = 0 if i ≥ temp
		beq	$t1, $zero, exit1	# go to exit 1 if i ≥ temp
		
		move	$s1, $zero		# j = 0
innerloop1_1: 	slt	$t1, $s0, $s1		# $t1 = 1 if j > i
		bne 	$t1, $zero, exit1_1 	# go to exit 1_1 if j > i
		li 	$v0, 4 			# call system call: print string
		la	$a0, sp			# load address of 'space' into $a0
		syscall				# run the syscall
		addi	$s1, $s1, 1 		# j++
		j	innerloop1_1		# go back to innerloop1_1
		
# finished innerloop1_1		
exit1_1: 	move 	$s1, $zero 		# j = 0
		mul 	$t2, $s0, $t0 		# $t2 = i*2
		sub 	$t2, $s2, $t2		# $t2 = n - i*2
innerloop1_2: 	slt	$t1, $s1, $t2		# $t1 = 0 if j ≥ (n - i*2)
		beq	$t1, $zero, exit1_2	# go to exit 3 if j ≥ (n - i*2) 
		li 	$v0, 4 			# call system call: print string
		la 	$a0, star		# load address of 'star' into $a0
		syscall				# run the syscall
		addi	$s1, $s1, 1 		# j++
		j	innerloop1_2		# go back to innerloop1_2
		
# finished innerloop1_2
exit1_2: 	li 	$v0, 4 			# call system call: print string
		la 	$a0, nl			# load address of 'newline' into $a0
		syscall				# run the syscall
		addi	$s0, $s0, 1		# i++
		j	outerloop1		# go back to outerloop1

# finished outerloop1
# lower half of the hourglass	
exit1: 		addi	$t2, $s2, 1		# $t2 = n+1
		div	$t2, $t0		# (n+1)/2
		mflo	$t2			# move quotient to $t2 = (n+1)/2
		addi 	$t2, $t2, -1		# $t2 = (n+1)/2 - 1
		add 	$s0, $t2, $zero		# i = (n+1)/2 - 1
outerloop2: 	slt 	$t1, $s0, $zero		# $t1 = 1 if i < 0
		bne 	$t1, $zero, exit2	# go to exit2 if i < 0
		
		move	$s1, $zero		# j = 0
innerloop2_1: 	slt	$t1, $s0, $s1		# $t1 = 1 if j > i
		bne 	$t1, $zero, exit2_1 	# go to exit 2_1 if j > i
		li 	$v0, 4 			# call system call: print string
		la	$a0, sp			# load address of 'space' into $a0
		syscall				# run the syscall
		addi	$s1, $s1, 1 		# j++
		j	innerloop2_1		# go back to innerloop2_1
		
# finished innerloop2_1		
exit2_1: 	move 	$s1, $zero 		# j = 0
		mul 	$t2, $s0, $t0 		# $t2 = i*2
		sub 	$t2, $s2, $t2		# $t2 = n - i*2
innerloop2_2: 	slt	$t1, $s1, $t2		# $t1 = 0 if j ≥ (n - i*2)
		beq	$t1, $zero, exit2_2	# go to exit 3 if j ≥ (n - i*2) 
		li 	$v0, 4 			# call system call: print string
		la 	$a0, star		# load address of 'star' into $a0
		syscall				# run the syscall
		addi	$s1, $s1, 1 		# j++
		j	innerloop2_2		# go back to innerloop2_2
		
# finished innerloop2_2
exit2_2: 	li 	$v0, 4 			# call system call: print string
		la 	$a0, nl			# load address of 'newline' into $a0
		syscall				# run the syscall
		addi	$s0, $s0, -1		# i--
		j	outerloop2		# go back to outerloop2

# finished outerloop1	
exit2:		lw	$s0, 0($sp)		# restore $s0 from stack
		lw 	$s1, 4($sp)		# restore $s1 from stack
		lw	$s2, 8($sp)		# restore $s2 from stack
		lw	$s3, 12($sp)		# restore $s3 from stack
		addi	$sp, $sp, 16		# restore stack pointer

# exit
		li $v0, 10			# call system call: exit
  		syscall				# run the syscall
