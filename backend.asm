#.include "hw4_helpers.asm"

.text

### part 1 functions ###
setCell:
    # your code goes here

    lw $t0, ($sp) # holds int BG
    
    #error check row
    bltz $a0, setCellErr
    bgt $a0, 11, setCellErr
    
    #error check column
    bltz $a1, setCellErr
    bgt $a1, 6, setCellErr
    
    #error check FG
    blt $a3, 0x00, setCellErr
    bgt $a3, 0x0F, setCellErr
    
    #error check BG
    blt $t0, 0x00, setCellErr
    bgt $t0, 0x0F, setCellErr
    
    #bitwise operation to set lower bits to
    sll $t0, $t0, 4 #shitfing BG 4 bits in order to or them together
    add $t2, $t0, $a3 #t2 will hold BG and FG added together
    
    #setting char into the MMIO
    li $t1, 7
    mult $a0, $t1
    mflo $t1
    
    add $t1, $t1, $a1					#storing char into cell
    li $t4, 2						#mult by size in byte
    mult $t4, $t1
    mflo $t1
    addi $t3, $t1, 0xffff0000
    
    bgt $a2, 0x7F, setColor
    
    sb $a2, ($t3)
    
setColor:
    addi $t3, $t3, 1					#storing color into cell
    sb $t2, ($t3)
    
    li $v0, 0
    jr $ra
    
setCellErr:
    li $v0, -1
    jr $ra

getCell:
    # your code goes here

    #error check row
    bltz $a0, getCellErr
    bgt $a0, 11, getCellErr
    
    #error check column
    bltz $a1, getCellErr
    bgt $a1, 6, getCellErr

    li $t1, 7
    mult $a0, $t1
    mflo $t1
    
    add $t1, $t1, $a1					#storing char into cell
    li $t4, 2						#mult by size in byte
    mult $t4, $t1
    mflo $t1
    addi $t3, $t1, 0xffff0000
    
    lb $v1, ($t3)
    
    addi $t3, $t3, 1					#storing color into cell
    lb $v0, ($t3)
    
    jr $ra
    
getCellErr:
    li $v0, 0xFF
    li $v1, 0xFF
    jr $ra
    
    
initDisplay:
    # your code goes here
    addi $sp, $sp, -16
    sw $a1, 0($sp) #BG
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $ra, 12($sp)

    move $s0, $a0 #FG
    move $s1, $a1 #BG
    
    #setting grey border
    li $a1, 0
setTop:
    bgt $a1, 6, setLeft
    li $a0, 0
    li $a2, '\0'
    li $a3, 0
    li $t0, 7
    sw $t0, ($sp)
    jal setCell
    
    addi $a1, $a1, 1
    j setTop
    
setLeft:
    bgt $a0, 6, setRight
    addi $a0, $a0, 1
    li $a1, 0
    li $a2, '\0'
    li $a3, 0
    li $t0, 7
    sw $t0, ($sp)
    jal setCell
    
    j setLeft
setRight:
    li $a0, 1
rightL:
    bgt $a0, 7, setBot
    li $a1, 6
    li $a2, '\0'
    li $a3, 0
    li $t0, 7
    sw $t0, ($sp)
    jal setCell
    
    addi $a0, $a0, 1
    j rightL
    
setBot:
    li $a1, 1
botL: 
    beq $a1, 6, outBot
    li $a0, 7
    li $a2, '\0'
    li $a3, 0
    li $t0, 7
    sw $t0, ($sp)
    jal setCell
    
    addi $a1, $a1, 1
    j botL
    
outBot:
    li $a1, 1
    li $a0, 1
midL:
    bgt $a1, 5, incMid
    bgt $a0, 6, outMid
    li $a2, '?'
    move $a3, $s0
    sw $s1, 0($sp)
    jal setCell
    
    addi $a1, $a1, 1
    
    j midL
    
incMid:
    addi $a0, $a0, 1
    li $a1, 1
    j midL
    
outMid:
    li $a0, 8
    li $a1, 0
    li $a2, 'A'
alphaL:
    bgt $a1, 6, incAlpha
    bgt $a2, 'Z', outAlpha
    li $a3, 0
    li $t0, 0x0F
    sw $t0, 0($sp)
    jal setCell
    
    addi $a1, $a1, 1
    addi $a2, $a2, 1
    j alphaL
    
incAlpha:
    addi $a0, $a0, 1
    li $a1, 0
    j alphaL
    
outAlpha:
    li $a0, 11
    li $a1, 5
    li $a2, '\0'
    li $a3, 0
    li $t0, 0x0F
    sw $t0, 0($sp)
    jal setCell
    
    li $a0, 11
    li $a1, 6
    li $a2, '\0'
    li $a3, 0
    li $t0, 0x0F
    sw $t0, 0($sp)
    jal setCell
    
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    jr $ra


### part 2 functions ###
binarySearch:
    # your code goes here

    addi $sp, $sp, -28
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    sw $s5, 24($sp)
    
    move $s0, $a0 #moving values
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3
    
    bge $s2, $s1, setMid
    
    #else case
    li $v0, -1
    j outSearch
    
setMid:
    sub $s4, $s2, $s1 # (end - start)
    li $t0, 2
    div $s4, $t0 # (end - start)/2
    mflo $s4
    add $s4, $s4, $s1 # start + (end - start)/2 #s4 holds mid
    
    #int check = strcmp
    li $t0, 6
    mult $s4, $t0
    mflo $s5
    add $s5, $s5, $s0
    
    move $a0, $s5
    move $a1, $s3
    jal strcmp
    
    beqz $v0, retMid
    beq $v0, 1, callBin
    
    #else statement
    move $a0, $s0
    move $a1, $s4
    addi $a1, $a1, 1
    move $a2, $s2
    move $a3, $s3
    jal binarySearch
    j outSearch
    
retMid:
    move $v0, $s4
    j outSearch
    
callBin:
    move $a0, $s0
    move $a1, $s1
    move $a2, $s4
    addi $a2, $a2, -1
    move $a3, $s3
    jal binarySearch
    j outSearch
    
outSearch:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    lw $s5, 24($sp)
    addi $sp, $sp, 28
    
    jr $ra



isValid:
    # your code goes herea
    
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    
    #checking if str is 
    move $a0, $s2
    jal strlen
    
    beq $v0, 5, valid
    li $v0, -1
    j returnIsValid
    
valid:
    #making guess all upper case
    move $a0, $s2
    jal toUpper
    move $s2, $v0
    
    #finding start index
    lb $t0, ($s2)
    addi $t0, $t0, -65
    sll $t0, $t0, 2
    
    add $t0, $s1, $t0
    lw $a1, ($t0)
    
    addi $t0, $t0 ,4
    lw $a2, ($t0)
    
    move $a0, $s0
    move $a3, $s2
    jal binarySearch
    
    beq $v0, -1, retIsValidErr
    li $v0, 0
    j returnIsValid
    
retIsValidErr:
    li $v0, -1
    
returnIsValid:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
    jr $ra
    
    
    
### part 3 functions ###
updateGuessPane:
    # your code goes here

    lw $t0, 4($sp) #pos
    lw $t1, 0($sp) #wordAttempt
    
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    
    #err checking
    bge $a2, $a1, retErr
    blt $a3, 0x41, retErr
    bgt $a3, 0x5A, retErr
    blt $t1, 1, retErr
    bgt $t1, 6, retErr
    
    
    sll $t2, $a2, 2
    add $t2, $t2, $a0
    lw $t2, ($t2)
    
    li $t3, 0
checkLetter:
    lb $t4, ($t2)
    beq $t4, $a3, flag
    beq $t4, 0, flag0
    addi $t2, $t2, 1
    addi $t3, $t3, 1
    
    j checkLetter
flag:
    li $s0, 1
    beq $t3, $t0, flag2
    j settingColor
flag2: 
    li $s0, 2
    j settingColor
flag0:  
    li $s0, 0
    
settingColor:
     beq $s0, 1, setYellow #if present within word
     beq $s0, 2, setGreen #if present withint word and correct posistion 
     
     #set gray for 0
     move $a0, $t1
     move $a1, $t0
     addi $a1, $a1, 1
     move $a2, $a3
     li $a3, 0x0F
     li $t5, 8
     addi $sp, $sp, -4
     sw $t5, ($sp)
     jal setCell
     
     addi $sp, $sp, 4
     
     j outUpdate
     
setGreen:
     move $a0, $t1
     move $a1, $t0
     addi $a1, $a1, 1
     move $a2, $a3
     li $a3, 0x0F
     li $t5, 2
     addi $sp, $sp, -4
     sw $t5, ($sp)
     jal setCell
     
     addi $sp, $sp, 4
     
     j outUpdate
     
setYellow:
     move $a0, $t1
     move $a1, $t0
     addi $a1, $a1, 1
     move $a2, $a3
     li $a3, 0
     li $t5, 0x0B
     addi $sp, $sp, -4
     sw $t5, ($sp)
     jal setCell
     
     addi $sp, $sp, 4
         
     j outUpdate
    
outUpdate:
    move $v0, $s0
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra
    
retErr:
    li $v0, -1
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra
    
    
updateAlphabetPane:
    # your code goes here
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    
    move $s0, $a0
    move $s1, $a1
    
    #loading args for getCell
    li $a0, 8
    li $a1, 0
    
    #loop until finds same letter
getCellLoop:
    beq $a1, 7, incA0
    jal getCell
    
    beq $v1, $s0, checkColor
    addi $a1, $a1, 1
    j getCellLoop
    
incA0:
    addi $a0, $a0, 1
    li $a1, 0
    j getCellLoop
    
checkColor:
    beq $s1, 2, green
    beq $s1, 1, yellow
    
    
    # dark gray
    beq $v0, 2, done
    beq $v0, 1, done
    move $a2, $s0
    li $a3, 0x0F
    li $t0, 8
    addi $sp, $sp, -4
    sw $t0, ($sp)
    jal setCell
    
    addi $sp, $sp, 4
    j done

green:
    move $a2, $s0
    li $a3, 0x0F
    li $t0, 2
    addi $sp, $sp, -4
    sw $t0, ($sp)
    jal setCell
    
    addi $sp, $sp, 4
    j done

yellow:
    beq $v0, 2, done
    move $a2, $s0
    li $a3, 0
    li $t0, 0x0B
    addi $sp, $sp, -4
    sw $t0, ($sp)
    jal setCell
    
    addi $sp, $sp, 4
    j done

done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra

### part 4 functions ###
playWord:
    # your code goes here
    lw $t0, 0($sp) #dictIndex
    lw $t1, 4($sp) #dict  
    lw $t2, 8($sp) #guess
    
    addi $sp, $sp, -44
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    sw $s5, 24($sp)
    sw $s6, 28($sp)
    sw $s7, 32($sp)
    
    # using these registers because s reg ran out
    li $t9, 0
    sw $t9, 36($sp)
    sw $t9, 40($sp)
    
    ble $a3, 0, invalid
    bge $a2, $a1, invalid
    
    move $s0, $a0 #puzzles[]
    move $s1, $a1 #puzzleSize
    move $s2, $a2 #puzzleNum
    move $s3, $a3 #word attempt
    move $s4, $t2 #guess
    move $s5, $t1 #dict
    move $s6, $t0 #dictIndex
    
    move $a0, $s5 #dict
    move $a1, $s6 #dictIndex
    move $a2, $s4 #guess
    jal isValid   
    
    beq $v0, -1, invalid
    
    li $s7, 0 #counter for posistion parameter
wordleLoop:
    #loading first char of guess
    lb $t0, ($s4)
    sw $t0, 40($sp)
    #beqz $t0, retPlayWord
    beq  $s7, 5, retPlayWord
    #loading arguments to call UpdateGuessPane
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    move $a3, $t0
    addi $sp, $sp, -8
    sw $s3, 0($sp)
    sw $s7, 4($sp)
    
    jal updateGuessPane
    
    addi $sp, $sp, 8
    
    beq $v0, 2, incCorrectWord
cont:
    #calling update alphabet pane
    lw $a0, 40($sp)
    move $a1, $v0
    jal updateAlphabetPane
    
    addi $s4, $s4, 1
    addi $s7, $s7, 1
    
    j wordleLoop
    
incCorrectWord:
    lw $t1, 36($sp)
    addi $t1, $t1, 1
    sw $t1, 36($sp)
    
    j cont
retPlayWord:
    
    lw $t1, 36($sp)
    beq $t1, 5, retValid
    
    li $v0, 0
    j epilogue

retValid:
    li $v0, 1
    j epilogue
    
invalid:
    li $v0, -1
    j epilogue
    
epilogue:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    lw $s5, 24($sp)
    lw $s6, 28($sp)
    lw $s7, 32($sp)
    
    addi $sp, $sp, 44
    jr $ra
