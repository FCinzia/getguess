
    .data
min:	   .word 1
max:	   .word 10
num:	   .word 8   
                      
msgintro:  .asciiz "Guess must be a hexadecimal number between "
msgand:    .asciiz " and "
msgend:    .asciiz "\nEnter your guess (or nothing to quit).\n"
msgnl:     .asciiz "\n"
msgwin:    .asciiz "Got it!"
msghigh:   .asciiz "Guess is too high."
msglow:    .asciiz "Guess is too low."
    .text
    .globl main
main:
   
addiu	$sp, $sp, -52
sw	$ra, 48($sp)

la      $a0, msgintro
jal 	PrintString
lw      $a0, min
jal 	PrintInteger
la      $a0, msgand
jal 	PrintString
lw      $a0, max
jal 	PrintInteger

# itoax(min, buffer)            
lw      $a0, min
add 	$a1, $sp, 24 # 24($sp) beginning of buffer
jal     itoax

# char *prompt= strdup2 (msgintro, buffer)
la      $a0, msgintro
add     $a1, $sp, 24
sw      $ra, 44($sp)
jal     strdup2
lw      $ra, 44($sp)
sw      $v0, 20($sp)  #prompt 

# prompt = strdup(prompt, msgend)
lw 	$a0, 20($sp)
la	$a1, msgend
sw      $ra, 44($sp)
jal     strdup2
lw      $ra, 44($sp)
sw      $v0, 20($sp)

# itoax (max, buffer)
lw      $a0, max
add     $a1, $sp, 24
sw      $ra, 44($sp)
jal     itoax
lw      $ra, 44($sp)

# prompt = strdup2(prompt, buffer)
lw      $a0, 20($sp)
add     $a1, $sp, 24
sw      $ra, 44($sp)
jal     strdup2
lw      $ra, 44($sp) 
sw      $v0, 20($sp)

# prompt = strdup2 (prompt, msgend)
lw      $a0, 20($sp)
lw      $a1, msgend
sw      $ra, 44($sp)
jal     strdup2
lw      $ra, 44($sp) 
sw      $v0, 20($sp) 

#int guess = GetGuess(prompt, min, max);
lw 	$a0, 20($sp)
lw      $a1, min
lw      $a2, max
sw      $ra, 44($sp)
jal     GetGuess
sw      $v0, 40($sp)

# if(guess == -1) return
lw      $t0, 40($sp)		       #guess is in $t0
beq     $t0, -1, done1

# if(guess == num) PrintString(msgwin)
lw      $t1, num
la	$a0, msgwin
beq  	$t0, $t1, PrintMsg

#if (guess > num) PrintString(msghigh)
lw      $t0, 40($sp)	
lw 	$t1, num
la 	$a0, msghigh
bgt	$t0, $t1, PrintMsg

# if(guess < num) PrintString(msglow)
lw      $t0, 40($sp)	
lw 	$t1, num
la 	$a0, msglow
blt	$t0, $t1, PrintMsg

PrintMsg:
jal     PrintString

done1:
lw 	$ra, 48($sp)
addiu   $sp, $sp, 52
jr	$ra
    # Step 1: Build prompt.


    # Step 2: Repeatedly use GetGuess to get a guess
    # from the user and report if it is too high, too
    # low, or correct.
# char * strdup2 (char * str1, char * str2)

################################
# GetGuess
################################

#
#
# int GetGuess(char * question, int min, int max)
# -----
# This is your function from assignment 4. It repeatedly
# asks the user for a guess until the guess is a valid
# hexadecimal number between min and max.
    .data
invalid:    .asciiz "Not a valid hexadecimal number.\n"
badrange:   .asciiz "Guess not in range.\n"
    .text
    .globl  GetGuess
GetGuess:

 	addiu   $sp,$sp, -44
        sw      $ra, 40($sp)
        
        sw      $a1, 8($sp)
        move    $t1, $a1
        sw      $a2, 12($sp)
        move    $t2, $a2
        
        loop:
        la      $a0, msgend
        li      $a2, 16
        add 	$a1, $sp, 16
        jal     InputConsoleString
        move    $t0, $v0  #$t0 = bytes_read
        bnez    $t0, return
        j       else
        
        return:
        move    $v0, $zero
        addi    $v0, $zero, 1
        
        else:  
        la      $a0, 32($sp)  
        la      $a1, 16($sp)
        jal     axtoi
        move    $a3, $v0   # $a3 = status
        
        li      $t1, 1
        beq     $a3, $t1, if
        lw      $a0, invalid
        jal     PrintString
        
        if:
        lw      $t2, 32($sp)
        lw      $a1, min
        lw      $a2, max
        blt	$t2, $a1, badrangemsg
        bgt	$t2, $a2, badrangemsg
        j       return2
        
        badrangemsg:
        sw      $ra, 36($sp)
        la      $a0, badrange 
        jal     PrintString
        lw      $a3, 36($sp)
        jal 	loop

        return2:
        lw     $v0, 32($sp)
         
        done:                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
        lw      $ra, 40($sp)
        addiu   $sp, $sp, 44

        jr      $ra


#
# char * strdup2 (char * str1, char * str2)
# -----
# strdup2 takes two strings, allocates new space big enough to hold
# of them concatenated (str1 followed by str2), then copies each
# string to the new space and returns a pointer to the result.
#
# strdup2 assumes neither str1 no str2 is NULL AND that malloc
# returns a valid pointer.
    .globl  strdup2
strdup2:
    # $ra   at 28($sp)
    # len1  at 24($sp)
    # len2  at 20($sp)
    # new   at 16($sp)
    sub     $sp,$sp,32
    sw      $ra,28($sp)

    # save $a0,$a1
    # str1  at 32($sp)
    # str2  at 36($sp)
    sw      $a0,32($sp)
    sw      $a1,36($sp)

    # get the lengths of each string
    jal     strlen
    sw      $v0,24($sp)

    lw      $a0,36($sp)
    jal     strlen
    sw      $v0,20($sp)

    # allocate space for the new concatenated string
    add     $a0,$v0,1
    lw      $t0,24($sp)
    add     $a0,$a0,$t0
    jal     malloc
    
    sw      $v0,16($sp)

    # copy each to the new area
       move    $a0,$v0
    lw      $a1,32($sp)
    jal     strcpy

    lw      $a0,16($sp)
    lw      $t0,24($sp)
    add     $a0,$a0,$t0
    lw      $a1,36($sp)
    jal     strcpy

    # return the new string
    lw      $v0,16($sp)
    lw      $ra,28($sp)
    add     $sp,$sp,32
    jr      $ra

    .include  "./util.s"


