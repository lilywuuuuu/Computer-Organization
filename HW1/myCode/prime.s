.data
msg1:	.asciiz "Enter the number n = "
msg2:	.asciiz " is a prime number\n"
msg3: 	.asciiz " is not a prime number. The nearest prime is"
sp:	.asciiz " "
.text
.globl main

#------------------------- main -----------------------------
main:
#adjust stack for $s0, $s1, $s2
		addi 	$sp, $sp, -12		# make room on stack for 3 items
		sw 	$s0, 0($sp)		# save $s0 on stack
		sw	$s1, 4($sp)		# save $s1 on stack
		sw	$s2, 8($sp)		# save $s2 on stack

# print msg1 on the console interface
		li      $v0, 4			# call system call: print string
		la      $a0, msg1		# load address of string into $a0
		syscall                 	# run the syscall
		
# read input n in $s0
 		li      $v0, 5          	# call system call: read integer
  		syscall                 	# run the syscall
  		move    $s0, $v0      		# store input n in $s0 
		move	$a0, $v0		# store input n into $a0

# if prime(n)
  		jal 	prime			# go to prime
		move 	$t0, $v0		# save return value in t0 (because v0 will be used by system call) 
		beq	$t0, $zero, notprime	# go to notprime if result of prime(n) is 0
		move 	$a0, $s0 		# move n to $a0
		li 	$v0, 1			# call system call: print integer
		syscall 			# run the syscall
		li	$v0, 4			# call system call: print string
		la 	$a0, msg2		# load address of string into $a0
		syscall				# run the syscall
		li 	$v0, 10			# call system call: exit
		syscall				# run the syscall

# if not prime(n)
notprime: 	move 	$a0, $s0 		# move n to $a0
		li 	$v0, 1			# call system call: print integer
		syscall 			# run the syscall
		li	$v0, 4			# call system call: print string
		la	$a0, msg3		# load address of string into $a0
		syscall				# run the syscall
		
		
		addi	$s1, $zero, 1		# $s1: i=1
loop1:		sub	$t1, $s0, $s1		# $t1 = n-i
		move 	$a0, $t1		# $a0 = n-i
		jal	prime			# prime(n-i)
		move	$t2, $v0		# move the return value to $t2
		beq	$t2, $zero, L3		# go to L3 if prime(n-i) == 0

# if prime(n-i)		
		li	$v0, 4			# print n-i
		la	$a0, sp			# print a space
		syscall
		sub	$a0, $s0, $s1		# $a0 = n-i
		li	$v0, 1
		syscall
		addi	$s2, $zero, 1		# set $s2: flag = 1

# if not prime(n-i)		
L3:		add	$t1, $s0, $s1		# $t1 = n+i
		move 	$a0, $t1		# $a0 = n+i
		jal	prime			# prime(n+i)
		move	$t2, $v0		# move the return value to $t2
		beq	$t2, $zero, L4		# go to L4 if prime(n+i) == 0	
		
# if prime(n+i)
		li	$v0, 4			# print space
		la	$a0, sp
		syscall
		add	$a0, $s0, $s1		# print n+i
		li	$v0, 1
		syscall
		addi	$s2, $zero, 1		# set $t3: flag = 1

# if not prime(n+i)				
L4:		beq	$s2, $zero, L5		# go to L5 if flag == 0
		j	exit1			# break
		
L5:		addi	$s1, $s1, 1		# i++
		j	loop1			# jump to loop1

exit1:		lw	$s0, 0($sp)		# restore $s0 from stack
		lw 	$s1, 4($sp)		# restore $s1 from stack
		lw	$s2, 8($sp)		# restore $s2 from stack
		addi	$sp, $sp, 12		# restore stack pointer
		li 	$v0, 10			# call system call: exit
		syscall				# run the syscall

#------------------------- procedure prime -----------------------------

# load argument n in $a0, return value in $v0. 
.text
prime:		addi 	$sp, $sp, -8		# adjust stack for 2 items
		sw 	$ra, 4($sp)		# save the return address
		sw	$s3, 0($sp)		# save $s3
		move	$s3, $a0		# $s3 = $a0
		addi 	$t0, $zero, 1		# $t0 = 1
		bne	$s3, $t0, L1		# go to L1 if n!= 1

# if(n == 1)
		move 	$v0, $zero		# return 0
		addi 	$sp, $sp, 8		# pop 2 items off stack
		jr 	$ra			# return to caller

# if(n != 1)
L1:		addi	$t0, $zero, 2		# $t0 : i = 2
loop2:		mul 	$t1, $t0, $t0		# $t1 = i*i
		slt	$t2, $s3, $t1		# $t2 = 1 if i*i > n
		bne	$t2, $zero, exit2	# go to exit1 if i*i > n
		div	$s3, $t0		# n/i
		mfhi	$t1			# $t1 = n%i
		bne	$t1, $zero, L2		# go to L2 if n%i != 0
		move	$v0, $zero		# return 0 if n%i == 0
		addi	$sp, $sp, 8		# pop 1 item off stack
		jr	$ra			# return to caller
		
L2:		addi	$t0, $t0, 1		# i++ if n%i != 0
		j	loop2			# jump to loop2
		
		
exit2:		move	$v0, $zero		# $v0 = 0
		addi	$v0, $v0, 1		# return 1
		addi	$sp, $sp, 8		# pop 1 item off stack
		jr 	$ra			# return to caller

