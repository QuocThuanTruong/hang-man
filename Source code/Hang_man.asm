.data
	dethiPath:			.asciiz	"dethi.txt"
	nguoichoiPath:			.asciiz	"nguoichoi.txt"
	
	hanging_0:			.asciiz	"_________\n"
	hanging_1:			.asciiz	"|/     | \n"
	hanging_2:			.asciiz	"|        \n"
	hanging_3:			.asciiz	"|        \n"
	hanging_4:			.asciiz	"|        \n"
	hanging_5:			.asciiz	"|        \n"
	hanging_6:			.asciiz	"|        \n"
	hanging_7:			.asciiz	"|        \n"
	hanging_8:			.asciiz	"|        \n"
	hanging_9:			.asciiz	"|        \n"
	
	head:				.asciiz	"|      O \n"
	body:				.asciiz	"|      | \n"
	leftArm:				.asciiz	"|     /| \n"
	rightArm:			.asciiz	"|     /|\\\n"
	leftFoot:			.asciiz	"|     /  \n"
	rightFoot:			.asciiz	"|     / \\\n"
	
	hangingArr:			.space 	40
	heightOfHM:			.word	10
	
	totalGuess:			.word	7
	totalWin:			.word	0
	score:				.word 	0
	word:				.space	100
	encryptWord:			.space	100
	lenOfWord:			.word	0
	bufferDethi:			.space	4096
	buffLen:				.word	0
	numOfWordInBuff: 		.word	0
	name:				.space 	100
	
	isNameExisted:			.word	0
	flagExit:			.word 	1	
	flagGuess:			.word	0
	flagDraw:			.word	0
	flagNewGame:			.word	1
	
	messNameInput:			.asciiz	"Your name is: "
	messInvalidName:			.asciiz	"Invalid name try again\nName must be in [0 - 9], [A - Z], [a - z]"
	messWaringName:			.asciiz	"You must input name to play game"
	messErrInput:			.asciiz	"Some error occur, please try another"
	messWaringInput:			.asciiz	"You must input  to play game"
	messGuessType:			.asciiz	"1. Guessing character - 2. Guessing whole word\n"	
	messPlayerGuess:			.asciiz	"Your guess: "
	messShowName:			.asciiz	"Name: "
	messShowTTScore:			.asciiz	"Total score: "
	messShowTTTurnWin: 		.asciiz	"Total turns win: "
	messTurnPlay:			.asciiz	"Turns play: "
	messWrongRemain:			.asciiz	"Wrong guess remain: "
	messWordGuess:			.asciiz	"The word for you to guess is:"
	messOptionoEnd:			.asciiz	"1. Restart - 2.Exit"
	messPlayerWin:			.asciiz	"------YOU WIN------\n"
	messPlayerLost:			.asciiz	"------YOU LOST------\n"
	messTitleHighScore:		.ascii	"----------LEADER BOARD----------\n"
					.asciiz	"Name - Total score - Total Win\n"
	messWelcome:			.ascii	"---------------------------------------------------------Welcome to Hang man - guessing word in English game---------------------------------------------------------\n\n"
					.ascii	"Game rule:\n"
					.ascii	"The machine will give a word for you to guess in format *****\n"
					.ascii	"You have 2 option to guess it:\n\n"
					.ascii	"1. Guess letter in word: You will enter and letter [a - z] and if it exist in the word, the machine will show it like **a**\n"
					.ascii	"If you guess wrong, the machine will draw one part of hang man and continue draw to completed hang man if you continue wrong.\n"
					.ascii	"You have total 7 wrong guess and if it run out, you will see a hang man and lost the game.\n\n"	
					.ascii	"2. Guess whole word: You will enter a word that you think it will be the result.\n"
					.ascii	"If you guess wrong, the machine will draw a hang man and you lost the game.\n\n"
					.ascii	"At two option above, if you guess all letter of the word, you will win and have a score equivalent the length of the word.\n\n"
					.asciiz	"Good luck!\n\n"
	messPressOK:			.asciiz	"Press OK to continue"
	
.text
	.globl main
main:
	#Show welcome dialog
	la $a0, messWelcome
	la $a1, messPressOK
	li $a2, '\0'
	jal _funcConcatString
	move $a0, $v0
	
	li $v0, 55
	li $a1, 1
	syscall
	
	jal _funcResetHangMan
	jal _funcGetDeThi
	
	#Game loop
gameLoop:
	lw $t0, flagExit
	beq $t0, 0, endGameLoop
	
gameLoop.newGame:
	#Draw
	lw $a0, flagDraw
	jal _funcOnDrawHangMan
	
	#If flagNewGame == 1 -> getPlayerName (if not), getWord
	lw $t0, flagNewGame
	bne $t0, 1, gameLoop.showWordGuess
	
	#Reset total Guess
	li $t0, 7
	sw $t0, totalGuess
	
	#Get name if not existed
	lw $t0, isNameExisted
	bne $t0, 0, gameLoop.newGame.getWord
	jal _funcGetPlayerName
	
gameLoop.newGame.getWord:
	jal _funcGetWord
	
	#For test will be shown in run IO
	la $a0, word
	li $v0, 4
	syscall
	
	#Encrypt word
	li $a0, '*'
	jal _funcEncryptWord	
	
	#Reset flag new game
	li $t0, 0
	sw $t0, flagNewGame
	
gameLoop.showWordGuess:	
	#Show encrypt word
	
	#Conat infor
	lw $a0, totalWin
	jal _funcItoa
	move $a1, $v0
	
	la $a0, messTurnPlay
	li $a2, '\n'
	jal _funcConcatString
	
	move $a0 $v0
	la $a1, messWordGuess	
	li $a2, '\n'
	jal _funcConcatString
	
	move $a0, $v0
	la $a1, encryptWord	
	li $a2, '\n'
	jal _funcConcatString
	
	move $a0, $v0
	
	#Show
	li $v0, 55
	li $a1, 1
	syscall
	
	#Player choosing type guessing
	jal _funcChooseTypeGuess
	move $t0, $v0
	
	#if type == 1 -> guess letter, type != 1 -> guess word
	bne $t0, 1, gameLoop.guessWholeWord
	
	#Guess Letter
	jal _funcGuessLetter
	move $t1, $v0
	sw $t1, flagGuess
	
	j gameLoop.checkFlagGuess_0
	
gameLoop.guessWholeWord:
	jal _funcGuessWholeWord
	move $t1, $v0
	sw $t1, flagGuess
	
gameLoop.checkFlagGuess_0:		
	lw $t0, flagGuess
	#flagGuess == 0 -> Wrong, lost 1 turn guess
	bne $t0, 0, gameLoop.checkFlagGuess_1
	
	#flagDraw++
	lw $t1, flagDraw
	addi $t1, $t1, 1
	sw $t1, flagDraw
	
	#totalGuess--
	lw $t1, totalGuess
	addi $t1, $t1, -1
	sw $t1, totalGuess
	
	#if totalGuess == 0 -> lost game
	bne $t1, 0, gameLoop.checkFlagGuess_1
	
	#flagGuess = 2
	li $t1, 2
	sw $t1, flagGuess
	
gameLoop.checkFlagGuess_1:
	lw $t0, flagGuess
	#flagGuess == 1 -> Right, guess letter is correct
	bne $t0, 1, gameLoop.checkFlagGuess_2
	
	#Check if player win or not (guess whole word)
	jal _funcCheckEncryptWord
	sw $v0, flagGuess

gameLoop.checkFlagGuess_2:
	lw $t0, flagGuess
	#flagGuess == 2 -> guess whole word wrong -> lost game
	bne $t0, 2, gameLoop.checkFlagGuess_3
	
	li $t0, 0
	sw $t0, totalGuess
	jal _funcDrawWholeHangMan
	
	jal _funcShowInfo
	
	jal _funcShowHighScore
	
gameLoop.checkFlagGuess_2.showOptionEndGame:	
	#Show option end game
	li $v0, 51
	la $a0, messOptionoEnd
	syscall
	
	beq $a1, -2, endGameLoop
	bne $a1, 0, gameLoop.checkFlagGuess_2.optionError
	#$a1 == 0 -> received input
	
	bne $a0, 1, endGameLoop
	#$a0 = 1 -> restart game
	#Reset data
	li $t0, 0
	sw $t0, score
	
	li $t0, 0
	sw $t0, totalWin
	
	li $t0, 1
	sw $t0, flagNewGame
	
	li $t0, 0
	sw $t0, flagDraw
	
	jal _funcResetWordData
	jal _funcResetHangMan
	
	j gameLoop
	
gameLoop.checkFlagGuess_2.optionError:	
	#Show dialog error
 	li $v0, 55
	la $a0, messErrInput
	li $a1, 2
	syscall
	
	j gameLoop.checkFlagGuess_2.showOptionEndGame
	
gameLoop.checkFlagGuess_3:	
	#flagGuess == 3 -> player win
	lw $t0, flagGuess
	bne $t0, 3, gameLoop
	
	#score += lenOfWord
	lw $t0, score
	lw $t1, lenOfWord
	add $t0, $t0, $t1
	sw $t0, score
	
	#totalWin++
	lw $t0, totalWin
	addi $t0, $t0, 1
	sw $t0, totalWin
	
	li $t0, 1
	sw $t0, flagNewGame
	
	li $t0, 0
	sw $t0, flagDraw
	
	#Concat  information win
	la $a0, messPlayerWin
	la $a1, messShowTTScore
	li $a2, '\0'
	jal _funcConcatString
	move $t0, $v0
	
	lw $a0, score
	jal _funcItoa
	move $a1, $v0
	
	move $a0, $t0
	li $a2, '\0'
	jal _funcConcatString
	move $a0, $v0
	
	li $v0, 55
	li $a1, 1
	syscall

	jal _funcResetHangMan
	j gameLoop
	
endGameLoop:
	#Exit prograrm
	li $v0, 10
	syscall

#---Func atoi - chuyen chuoi thành so nguyên
#@params
# $a0 - chuoi  can chuyen
#@return
# $v0 - so nguyên
_funcAtoi:
	#Backup reg
	addi $sp, $sp, -20
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $t0, 12($sp)
	sw $t1, 16($sp)
	
	#Init
	move $s0, $a0		
	li $s1, 0			#result
	li $t1, 10			#base
	
_funcAtoi.sumLoop:
	lb $t0, ($s0)
	addi $s0, $s0, 1
	
	beq $t0, '\0', _funcAtoi.endLoop
	beq $t0, '\n', _funcAtoi.endLoop

	mul $s1, $s1, $t1
	subi $t0, $t0, '0'
	add $s1, $s1, $t0
	
	j _funcAtoi.sumLoop
 _funcAtoi.endLoop:
 	#Return value
 	move $v0, $s1	
 	
 	#Resotre rg
 	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $t0, 12($sp)
	lw $t1, 16($sp)
	addi $sp, $sp, 20
	
	jr $ra
#---End func atoi

#---Func itoa - Chuyen so nguyen thanh chuoi
#@params
#$a0 - so nguyen
#@return
#$v0 - chuoi so nguyen
_funcItoa:
	#Backup reg
	addi $sp, $sp, -52
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $t0, 16 ($sp)
	sw $t1, 20($sp)
	sw $t2, 24($sp)
	sw $t3, 28($sp)
	sw $t4, 32($sp)
	sw $t5, 36($sp)
	sw $t6, 40($sp)
	sw $t7, 44($sp)
	sw $t8, 48($sp)
	
	#Init
	move $s0, $a0
	
	#Allocate memory for string
	li $v0, 9
	la $a0, 100
	syscall
	
	move $s1, $v0
	move $s2, $s1
	move $t0, $s0
	
	#if $a0 = 0 return '0'
	bne $t0, 0, _funcItoa.Loop.convert
	addi $t0, $t0, '0'
	sb $t0, ($s2)
	
	addi $s2, $s2, 1
	
	li $t0, '\0'
	sb $t0, ($s2)
	
	j _funcItoa.reverseStr.endLoop
	
_funcItoa.Loop.convert:
	beq $t0, 0, _funcItoa.reverseStr
	
	div $s0, $s0, 10
	mflo $t0			#result
	mfhi $t1			#remainder
	
	move $s0, $t0
	
	addi $t1, $t1, '0'
	sb $t1, ($s2)
	
	addi $s2, $s2, 1
	
	j _funcItoa.Loop.convert
	
_funcItoa.reverseStr:
	li $t0, '\0'
	sb $t0, ($s2)
	
	move $a0, $s1
	jal _funcgetStringLength
	move $t0, $v0
	
	move $s2, $s1	
	
	#(n - 1) /  2 = $t1
	addi $t1, $t0, -1
	div $t1, $t1, 2
	mflo $t1
	
	li $t2, 0	#idx
	 
_funcItoa.reverseStr.Loop:	
	#Load a[i]
	add $t3, $t2, $s2
	lb $t4, ($t3)
	
	#Load a[n - i - 1]
	move $t5, $t0
	sub $t5, $t5, $t2
	subi $t5, $t5, 1
	
	add $t6, $t5, $s2
	lb $t7, ($t6)
	
	#Swap a[i]  a[n - i - 1]
	move $t8, $t4
	move $t4, $t7
	move $t7, $t8
	
	sb $t4, ($t3)
	sb $t7, ($t6)
	
	addi $t2, $t2, 1
	
	blt $t2, $t1,  _funcItoa.reverseStr.Loop
	
_funcItoa.reverseStr.endLoop:	
	
	#Return value
	move $v0, $s1
	
	#Restore reg
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $t0, 16 ($sp)
	lw $t1, 20($sp)
	lw $t2, 24($sp)
	lw $t3, 28($sp)
	lw $t4, 32($sp)
	lw $t5, 36($sp)
	lw $t6, 40($sp)
	lw $t7, 44($sp)
	lw $t8, 48($sp)
	
	addi $sp, $sp, 52
	
	jr $ra
#---End func itoa

#---Func getStringLength - lay chieu dài chuoi
#@params
#$a0 - chuoi can tính
#@return
#$v0 - chieu dài
_funcgetStringLength:
	#Backup reg
	addi $sp, $sp, -16
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $t0, 8($sp)
	sw $t1, 12($sp)
	
	#Init
	move $s0, $a0
	li $t0, 0
	
_funcgetStringLength.Loop:
	lb $t1, ($s0)
	
	beq $t1, '\0', _funcgetStringLength.endLoop
	beq $t1, '\n', _funcgetStringLength.endLoop
	addi $t0, $t0, 1
	addi $s0, $s0, 1
	
	j _funcgetStringLength.Loop
	
_funcgetStringLength.endLoop:
	#Return value
	move $v0, $t0
	
	#Restore reg
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $t0, 8($sp)
	lw $t1, 12($sp)
	addi $sp, $sp, 16
	
	jr $ra
#---End func getStringLength

#---Func concatString - ham noi 2 chuoi
#@params
#$a0 - chuoi thu nhat
#$a1 - chuoi thu hai
#$a2 - ki tu ket thuc chuoi
#@return
#$v0 - chuoi ket qua = chuoi 1 + chuoi 2
_funcConcatString:
	#Backup reg
	addi $sp, $sp, -36
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $t0, 20($sp)
	sw $t1, 24($sp)
	sw $t2, 28($sp)
	sw $t3, 32($sp)
	
	move $s0, $a0
	move $s1, $a1
	
	#Allocate memory for concatenated string stored in $s2
	li $v0, 9
	#move $a0, $t2
	li $a0, 4096
	syscall
	
	move $s2, $v0
	move $s3, $s2
	
_funcConcatString.Loop.concatStr_1:
	lb $t3, ($s0)
	beq $t3, '\0', _funcConcatString.Loop.concatStr_2
	
	sb $t3, ($s3)
	addi $s0, $s0, 1
	addi $s3, $s3, 1
	
	j _funcConcatString.Loop.concatStr_1
	
_funcConcatString.Loop.concatStr_2:
	lb $t3, ($s1)
	beq $t3, '\0', _funcConcatString.concatEndChar
	
	sb $t3, ($s3)
	addi $s1, $s1, 1
	addi $s3, $s3, 1
	
	j _funcConcatString.Loop.concatStr_2
	
_funcConcatString.concatEndChar:
	move $t3, $a2
	sb $t3, ($s3)
	
	#Return value in $v0
	move $v0, $s2
	
	#Restore reg
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $t0, 20($sp)
	lw $t1, 24($sp)
	lw $t2, 28($sp)
	lw $t3, 32($sp)
	
	addi $sp, $sp, 36
	
	jr $ra
#---End func concatString

#---Func getScore - lay diem tu thông tin nguoi choi
#@params
#$a0 - thông tin nguoi choi
#@return
# $v0 - diem
_funcGetScore:
	#Backup reg
	addi $sp, $sp, -20
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $t0, 12($sp)
	sw $t1, 16($sp)
	
	#Init
	move $s0, $a0		
	
	#Allocate memory 
	li $v0, 9           			
	li $a0, 50       
	syscall
	
	move $s1, $v0
	li $t1, 0
	add $t1, $t1, $s1
	
_funcGetScore.Loop:			#ignore player name
	lb $t0, ($s0)
	addi $s0, $s0, 1
	
	beq $t0, '-', _funcGetScore.LoopScore
	j  _funcGetScore.Loop
	
 _funcGetScore.LoopScore:		#get score
 	lb $t0, ($s0)
 	addi $s0, $s0, 1
 	
 	beq $t0, '-', _funcGetScore.endLoopScore 
 
 	sb $t0, ($t1)
 	addi $t1, $t1, 1
 	
 	j _funcGetScore.LoopScore
 	
 _funcGetScore.endLoopScore:
	li $t0, '\0'
	sb $t0, ($t1)
	
	#Convert socre to int (return in $v0)
	move $a0, $s1
	jal _funcAtoi
	
	#Restore reg
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $t0, 12($sp)
	lw $t1, 16($sp)
	
	addi $sp, $sp, 20
	
	jr $ra
#---End func getScore  

#---Func CountWordInBuffer - dem so luong tu có trong buffer bang cách dem dau '-'
#@params
#$a0 -  buffer
#$a1 - chieu dai buffer
#@return
#$v0 - so luong tu trong buffer
_funcCountWordInBuffer:
	#Backup reg
	addi $sp, $sp, -24
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $t0, 12($sp)
	sw $t1, 16($sp)
	sw $t2, 20($sp)
	
	#Init
	move $s0, $a0
	move $s1, $a1
	li $t0, 0			#num of word
	li $t1, 0			#idx of character
	
_funcCountWordInBuffer.Loop:
	bge $t1, $s1, _funcCountWordInBuffer.endLoop		#if index >= len -> end loop
	lb $t2, ($s0)
	addi $s0, $s0, 1
	
	bne $t2, '*', _funcCountWordInBuffer.Loop.continue	
	addi $t0, $t0, 1
	
 _funcCountWordInBuffer.Loop.continue:
	addi $t1, $t1, 1
	j _funcCountWordInBuffer.Loop
	
 _funcCountWordInBuffer.endLoop:
 	#Return value
 	addi $t0, $t0, 1
 	move $v0, $t0
 	
 	#Resotre reg
 	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $t0, 12($sp)
	lw $t1, 16($sp)
	lw $t2, 20($sp)
	addi $sp, $sp, 24
	
 	jr $ra
 #---End func CountWordInBuffer
	
#---Func getDeThi - hàm lay du lieu dethi.txt và luu vào bufferDethi
#@params
#none
#@return
#none
_funcGetDeThi:
	#Backup reg
	addi $sp, $sp, -8
	sw $ra, ($sp)
	sw $s0, 4($sp)
	
	#Open file dethi.txt
	li $v0, 13
	la $a0, dethiPath
	li $a1, 0			#flag read
	li $a2, 0
	syscall
	
	move $s0, $v0			#store file desciptor  in $s0
	
	#Read file dethi.txt
	li $v0, 14
	move $a0, $s0
	la $a1, bufferDethi
	li $a2, 4096
	syscall
	
	#set len of buffer
	sw $v0, buffLen
	
	#Set num of word in buffer
	la $a0, bufferDethi
	lw $a1, buffLen
	jal _funcCountWordInBuffer
	sw $v0, numOfWordInBuff
	
	#Close file
	li $v0, 16
	move $a0, $s0
	syscall
	
	#Restore reg
	lw $ra, ($sp)
	lw $s0, 4($sp)
	addi $sp, $sp, 8
	
	jr $ra
#---End func getDeThi

#---Func counPlayer - Dem so luong nguoi choi co trong file
#@params
#$a0 - buff player
#$a1 - chieu dai buff player
#@return
#$v0 - so luong nguoi choi
_funcCountPlayer:
	#Backup reg
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	#Return value in $v0
	jal _funcCountWordInBuffer
	addi $v0, $v0, -1
	
	#Restore reg
	lw $ra, ($sp)
	addi $sp, $sp 4
	
	jr $ra
#---End func counPlayer

#---Func sortHighScore - Ham sap xep top 10 nguoi choi cao nhat va ghi vao file
#@params
#none
#@return
#none
_funcSortHighScore:
	#Backup reg
	addi $sp, $sp, -68
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $t0, 32 ($sp)
	sw $t1, 36($sp)
	sw $t2, 40($sp)
	sw $t3, 44($sp)
	sw $t4, 48($sp)
	sw $t5, 52($sp)
	sw $t6, 56($sp)
	sw $t7, 60($sp)
	sw $t8, 64($sp)
	
	#Open file nguoichoi.txt
	li $v0, 13
	la $a0, nguoichoiPath
	li $a1, 0					#flag read
	li $a2, 0
	syscall
	
	move $s0, $v0					#store file desciptor in $s0
	
	#Allocate memory stored in $s1
	li $v0, 9           			
	li $a0, 4096  
	syscall
	
	move $s1, $v0
	
	#Read file nguoichoi.txt into $s1
	li $v0, 14
	move $a0, $s0
	move $a1, $s1
	li $a2, 4096
	syscall
	
	move $t0, $v0			#num of character in buff read
	
	move $a0, $s1
	move $a1, $v0
	jal _funcCountPlayer
	
	move $s2, $v0			#nums of player
	
	#Allocate memory for array player infor (11 pointer * 4 byte = 44) stored in $s3
	li $v0, 9
	la $a0, 44
	syscall
	
	move $s3, $v0
	move $s4, $s3
	
	sw $s1, ($s4)
	addi $s4, $s4, 4
	
	li $t1, 0			#idx
_funcSortHighScore.Loop.getPlayerInfo:
	bge $t1, $t0, _funcSortHighScore.sortingPlayerInfo
	lb $t2, ($s1)
	
	addi $s1, $s1, 1
	
	bne $t2, '*', _funcSortHighScore.Loop.continue	
	sw $s1, ($s4)
	add $s4, $s4, 4
	
_funcSortHighScore.Loop.continue:
	addi $t1, $t1, 1
	j _funcSortHighScore.Loop.getPlayerInfo	
	
_funcSortHighScore.sortingPlayerInfo:
	move $s4, $s3		#array
	li $t1, 0 		#i = 0
	move $s5, $s2		#n - 1
	addi $s5, $s5, -1	
	
_funcSortHighScore.sortingPlayerInfo.Loop_i:
	bge $t1, $s5,  _funcSortHighScore.sortingPlayerInfo.endLoop_i 		#if i >= n - 1 -> end loop i
	
	add $t5, $t1, 1		#j = i + 1
	add $s6, $s4, 4
	
_funcSortHighScore.sortingPlayerInfo.Loop_j:
	bge $t5, $s2, _funcSortHighScore.sortingPlayerInfo.endLoop_j 		#if j >= n -> end loop j
	
	#Load array[i]
	lw $t3, ($s4)		#array[i]
	move $a0, $t3
	jal _funcGetScore
	move $t4, $v0		#diem[i]
	
	#Load aray[j]
	lw $t6, ($s6)		#array[j]
	move $a0, $t6
	jal _funcGetScore
	move $t7, $v0		#diem[j]
	
	#if diem[i] < diem[j] -> swap array[i] and array[j]
	bge $t4, $t7, _funcSortHighScore.sortingPlayerInfo.Loop_j.continue
	#swap array[i] and array[j]
	move $t8, $t3
	move $t3, $t6
	move $t6, $t8
	sw $t3, ($s4)
	sw $t6, ($s6)
	
_funcSortHighScore.sortingPlayerInfo.Loop_j.continue:
	addi $t5, $t5, 1
	addi $s6, $s6 , 4
	
	j _funcSortHighScore.sortingPlayerInfo.Loop_j
	
_funcSortHighScore.sortingPlayerInfo.endLoop_j:
	addi $t1, $t1, 1
	addi $s4, $s4, 4	
	
	j _funcSortHighScore.sortingPlayerInfo.Loop_i
	
_funcSortHighScore.sortingPlayerInfo.endLoop_i:
	#Concatenating pointer
	
	#Allocate ordered buff player info stored in $s5
	li $v0, 9
	move $a0, $t0
	syscall
	
	move $s5, $v0
	move $s6, $s5
	li $t1, 0				#idx
	
	#Write top 10 -> if player count > 10 -> player count  = 10
	ble $s2, 10, _funcSortHighScore.Loop.concatenatingPointer
	li $s2, 10
_funcSortHighScore.Loop.concatenatingPointer:
	bge $t1, $s2, _funcSortHighScore.concatenatingPointer.endLoop		#if idx >= nums of player -> end loop
	lw $s4, ($s3)				#get pointer
	
	#Get first player infor in pointer
_funcSortHighScore.Loop.concatenatingPointer.innerLoop.getExpectedInfo:
	lb $t3, ($s4)
	
	beq $t3, '*',  _funcSortHighScore.Loop.concatenatingPointer.endLoop.getExpectedInfo
	beq $t3, '\0',  _funcSortHighScore.Loop.concatenatingPointer.endLoop.getExpectedInfo
	
	sb $t3, ($s6)				#store in $s5
	
	addi $s6, $s6, 1
	addi $s4, $s4, 1
	
	j _funcSortHighScore.Loop.concatenatingPointer.innerLoop.getExpectedInfo
	
_funcSortHighScore.Loop.concatenatingPointer.endLoop.getExpectedInfo:
	addi $t1, $t1, 1
	addi $s3, $s3, 4
	
	#Concat *
	li $t2, '*'
	sb $t2, ($s6)
	addi $s6, $s6, 1
	
	j _funcSortHighScore.Loop.concatenatingPointer
		
_funcSortHighScore.concatenatingPointer.endLoop:	
	#Close file desciptor reading
	li $v0, 16
	move $a0, $s0
	syscall
	
	#Open file nguoichoi.txt
	li $v0, 13
	la $a0, nguoichoiPath
	li $a1, 1				#flag write
	li $a2, 0
	syscall
	
	move $s0, $v0				#store file desciptor in $s0
	
	#Get data length
	move $a0, $s5
	jal _funcgetStringLength
	move $t0, $v0
	
	#Write to file nguoichoi.txt
	li $v0, 15
	move $a0, $s0
	move $a1, $s5
	move $a2, $t0
	syscall
	
	#Close file
	li $v0, 16
	move $a0, $s0
	syscall
	
	#Restore reg
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	lw $t0, 32 ($sp)
	lw $t1, 36($sp)
	lw $t2, 40($sp)
	lw $t3, 44($sp)
	lw $t4, 48($sp)
	lw $t5, 52($sp)
	lw $t6, 56($sp)
	lw $t7, 60($sp)
	lw $t8, 64($sp)
	
	addi $sp, $sp, 68
	
	jr $ra
#---End func sortHighScore

#---Func showInfo - hien thi thong tin nguoi choi va luu vao file nguoichoi.txt theo format "name-score-totalWin*..."
#@params
#none
#@return
#none
_funcShowInfo:
	#Backup reg
	addi $sp, $sp, -32
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $t0, 24($sp)
	sw $t1, 28($sp)
	
	#Allocate temp buffer for player info stored in $s1
	li $v0, 9
	la $a0, 100
	syscall
	
	move $s1, $v0
	move $s2, $s1
	
	la $s3, name
	li $s4, 0			#len of information
	
_funcShowInfo.Loop.setNameInBuff:
	lb $t1, ($s3)
	
	beq $t1, '\0', _funcShowInfo.setScoreInBuff
	beq $t1, '\n', _funcShowInfo.setScoreInBuff
	
	sb $t1, ($s2)
	
	addi $s2, $s2, 1
	addi $s3, $s3, 1
	addi $s4, $s4, 1
	
	j _funcShowInfo.Loop.setNameInBuff

_funcShowInfo.setScoreInBuff:
	#Concat -
	li $t0, '-'
	sb $t0, ($s2)
	
	addi $s2, $s2 ,1
	addi $s4, $s4, 1

	lw $a0, score
	jal _funcItoa
	move $t0, $v0
	
_funcShowInfo.setScoreInBuff.Loop:
	lb $t1, ($t0)
	
	beq $t1, '\0', _funcShowInfo.setTotalWinInBuff
	beq $t1, '\n', _funcShowInfo.setTotalWinInBuff
	
	sb $t1, ($s2)
	
	addi $s2, $s2, 1
	addi $t0, $t0, 1
	addi $s4, $s4, 1
	
	j _funcShowInfo.setScoreInBuff.Loop
	
_funcShowInfo.setTotalWinInBuff:
	#Concat -
	li $t0, '-'
	sb $t0, ($s2)
	
	addi $s2, $s2 ,1
	addi $s4, $s4, 1
	
	lw $a0, totalWin
	jal _funcItoa
	move $t0, $v0
	
_funcShowInfo.setTotalWinInBuff.Loop:
	lb $t1, ($t0)
	
	beq $t1, '\0', _funcShowInfo.Show
	beq $t1, '\n', _funcShowInfo.Show
	
	sb $t1, ($s2)
	
	addi $s2, $s2, 1
	addi $t0, $t0, 1
	addi $s4, $s4, 1
	
	j _funcShowInfo.setTotalWinInBuff.Loop
	
_funcShowInfo.Show:
	#Concat *
	li $t1, '*'
	sb $t1, ($s2)
	addi $s4, $s4, 1
	
	#Open file nguoichoi.txt
	li $v0, 13
	la $a0, nguoichoiPath
	li $a1, 9					#flag write - append
	li $a2, 0
	syscall
	
	move $s0, $v0					#store file desciptor in $s0
	
	#Write to file nguoichoi.txt
	li $v0, 15
	move $a0, $s0
	move $a1, $s1
	move $a2, $s4
	syscall
	
	#Close file
	li $v0, 16
	move $a0, $s0
	syscall
	
	jal _funcSortHighScore
	
	#Concat You lost, Your name: 
	la $a0, messPlayerLost
	la $a1, messShowName
	li $a2, '\0'
	jal _funcConcatString
	
	#Concat player name
	move $a0, $v0
	la $a1, name
	li $a2, '\n'
	jal _funcConcatString
	
	#Concat Total score
	move $a0, $v0
	la $a1, messShowTTScore
	li $a2, '\0' 
	jal _funcConcatString
	
	move $s3, $v0
	
	#Concat score
	lw $a0, score
	jal _funcItoa
	
	move $a1, $v0
	move $a0, $s3
	li $a2, '\n'
	jal _funcConcatString
	
	#Concat Total turns win
	move $a0 $v0
	la $a1, messShowTTTurnWin
	li $a2, '\0'
	jal _funcConcatString
	
	move $s3, $v0
	
	#Concat total Win
	lw $a0, totalWin
	jal _funcItoa
	
	move $a1, $v0
	move $a0, $s3
	li $a2, '\0'
	jal _funcConcatString
	
	#Call dialog
	move $a0, $v0
	li $v0, 55
	li $a1, 1
	syscall
	
	#Restore
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $t0, 24($sp)
	lw $t1, 28($sp)
	
	addi $sp, $sp, 32
	
	jr $ra
#---End func showInfor

#---Func resetHangMan - Ham reset du lieu ve cua hang man
#@params
#none
#@return
#none
_funcResetHangMan:
	#Backup reg
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	#Load address of hangingArr - contain 10 pointer to hanging_x, x = [0:9]
	la $s0, hangingArr
	
	#Store address of hanging_x to hangingArr
	la $t0, hanging_0
	sw $t0, ($s0)
	
	la $t0, hanging_1
	sw $t0, 4($s0)
	
	la $t0, hanging_2
	sw $t0, 8($s0)
	
	la $t0, hanging_3
	sw $t0, 12($s0)
	
	la $t0, hanging_4
	sw $t0, 16($s0)
	
	la $t0, hanging_5
	sw $t0, 20($s0)
	
	la $t0, hanging_6
	sw $t0, 24($s0)
	
	la $t0, hanging_7
	sw $t0, 28($s0)
	
	la $t0, hanging_8
	sw $t0, 32($s0)
	
	la $t0, hanging_9
	sw $t0, 36($s0)
	
	#Restore reg
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	jr $ra
#---End func resetHangMan

#---Func onDrawHangMan - Ve hang man theo co duoc dinh nghia tuy thuoc vao so luot nguoi choi doan sai
#@params
#$a0 - flagDraw - co ve theo so luot doan sai: 1 - ve L, 2 3 4 5 6 7 - ve hang man
#@return
#none
_funcOnDrawHangMan:
	#Backup reg
	addi $sp, $sp, -40
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $t0, 32($sp)
	sw $t1, 36($sp)
	
	move $s0, $a0		#flag Draw
	la $s1, hangingArr
	
	#Check flagDraw
_funcOnDrawHangMan.equal_0:
	bne $s0, 0,  _funcOnDrawHangMan.equal_1
	j _funcOnDrawHangMan.onEndFunc
	
_funcOnDrawHangMan.equal_1:
	bne $s0, 1, _funcOnDrawHangMan.equal_2
	j _funcOnDrawHangMan.onDraw
	
_funcOnDrawHangMan.equal_2:
	bne $s0, 2, _funcOnDrawHangMan.equal_3
	la $t0, head
	sw $t0, 8($s1)
	j _funcOnDrawHangMan.onDraw
	
_funcOnDrawHangMan.equal_3:
	bne $s0, 3, _funcOnDrawHangMan.equal_4
	la $t0, body
	sw $t0, 12($s1)
	j _funcOnDrawHangMan.onDraw
	
_funcOnDrawHangMan.equal_4:
	bne $s0, 4, _funcOnDrawHangMan.equal_5
	la $t0, leftArm
	sw $t0, 12($s1)
	j _funcOnDrawHangMan.onDraw
	
_funcOnDrawHangMan.equal_5:
	bne $s0, 5, _funcOnDrawHangMan.equal_6
	la $t0, rightArm
	sw $t0, 12($s1)
	j _funcOnDrawHangMan.onDraw
	
_funcOnDrawHangMan.equal_6:
	bne $s0, 6, _funcOnDrawHangMan.equal_7
	la $t0, leftFoot
	sw $t0, 16($s1)
	j _funcOnDrawHangMan.onDraw
	
_funcOnDrawHangMan.equal_7:	
	bne $s0, 7, _funcOnDrawHangMan.onDraw
	la $t0, rightFoot
	sw $t0, 16($s1)
	
_funcOnDrawHangMan.onDraw:
	li $t0, 0			#idx
	lw $s2, heightOfHM
	
	move $s3, $s1			#hangingArr
	
	#Allocate temp string to print to dialog
	li $v0, 9
	la $a0, 1024
	syscall
	
	move $s5, $v0			#Store in $s5
	move $s6, $s5
	
_funcOnDrawHangMan.onDraw.loopConcatData:
	bge $t0, $s2, _funcOnDrawHangMan.onPrintData
	lw $s4, ($s3)			#Load pointer
	
_funcOnDrawHangMan.onDraw.loopConcatData.innerLoop:
	lb $t1, ($s4)			#Load data pointer references to
	
	beq $t1, '\0', _funcOnDrawHangMan.onDraw.loopConcatData.endInnerLoop	
	sb $t1, ($s6)
	
	addi $s4, $s4, 1	
	addi $s6, $s6, 1	
	
	j _funcOnDrawHangMan.onDraw.loopConcatData.innerLoop
	
_funcOnDrawHangMan.onDraw.loopConcatData.endInnerLoop:	
	addi $s3, $s3, 4
	addi $t0, $t0, 1
	
	j _funcOnDrawHangMan.onDraw.loopConcatData

_funcOnDrawHangMan.onPrintData:
	#if totalGuess != 0 -> show wrong guess remain
	lw $t0, totalGuess
	beq $t0, 0, _funcOnDrawHangMan.onPrintData.callDlg
	
	#Concat wrong guess remain
	lw $a0, totalGuess
	jal _funcItoa
	move $a1, $v0
	
	la $a0, messWrongRemain
	li $a2, '\n'
	jal _funcConcatString
	move $a0, $v0
	
	#Concat hang man
	move $a1, $s5
	li $a2, '\0'
	jal _funcConcatString
	move $a0, $v0
	
	#Print data to dialog
	li $v0, 55
	li $a1, 0
	syscall
	
	j _funcOnDrawHangMan.onEndFunc
	
_funcOnDrawHangMan.onPrintData.callDlg:	
	#Print hang man
	li $v0, 55
	move $a0, $s5
	li $a1, 0
	syscall
	
_funcOnDrawHangMan.onEndFunc:	
	#Restore reg
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	lw $t0, 32($sp)
	lw $t1, 36($sp)
	
	addi $sp, $sp, 40
		
	jr $ra
#---End func onDrawHangMan

#---Func drawWholeHangMan - Ve toan bo hang man khi nguoi choi ket thuc luot choi
#@params
#none
#@return 
#none	
_funcDrawWholeHangMan:
	#Backup reg
	addi $sp, $sp, -12
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $t0, 8($sp)
	
	#Set data
	la $s0, hangingArr
	
	#Concat You lost
	la $a0, messPlayerLost
	la $a1, hanging_0
	li $a2, '\0'
	jal _funcConcatString
	
	la $t0, ($v0)
	sw $t0, ($s0)
	
	#Replace head
	la $t0, head
	sw $t0, 8($s0)
	
	#Replace full arms
	la $t0, rightArm
	sw $t0, 12($s0)
	
	#Replace full feet
	la $t0, rightFoot
	sw $t0, 16($s0)
	
	#Call draw func
	li $a0, 1
	jal _funcOnDrawHangMan
	
	#Restore reg
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $t0, 8($sp)
	
	addi $sp, $sp, 12
	
	jr $ra
#---End func drawWholeHangMan

#---Func CheckCharacter - hàm kiem tra ki tu
#@params
#a0 - ki tu
#@return
#v0 - 1 neu duoc chap thuan, 0 neu khong duoc chap thuan
_funcCheckCharacter:
        #Backup reg
        addi $sp, $sp, -20
        sw $ra, ($sp)
	sw $t0, 4($sp)
	sw $t1, 8($sp)
	sw $s0, 12($sp)
	sw $s1, 16($sp)

	 # isNumber
	 # c<'0' || c>'9'
	 li $s0, '0'
	 li $s1, '9'
        
       # if (c<'0' || c>'9' ) -> nextStep (isUpper) else return 1 
	 slt $t0, $a0, $s0
	 sgt $t1, $a0, $s1
	 add $t0, $t0, $t1
	
	 bne $t0, $0, _funcCheckCharacter.isUpper
	 j _funcCheckCharacter.Return1
	 
_funcCheckCharacter.isUpper: 
        # if (c<'A' || c>'Z' ) -> nextStep (isLower) else return 1 
        li $s0, 'A'
        li $s1, 'Z'
        slt $t0, $a0, $s0
        sgt $t1, $a0, $s1
        add $t0, $t0, $t1
        
        bne $t0, $0, _funcCheckCharacter.isLower
        j _funcCheckCharacter.Return1
        
_funcCheckCharacter.isLower:
        # if (c<'a' || c>'z') -> return 0 else return 1
        li $s0, 'a'
        li $s1, 'z'
        slt $t0, $a0, $s0
        sgt $t1, $a0, $s1
        add $t0, $t0, $t1
        
        bne $t0, $0, _funcCheckCharacter.Return0
        j _funcCheckCharacter.Return1
        
_funcCheckCharacter.Return1:
        #return
        add $v0, $0, 1
        j _funcCheckCharacter.End
        
_funcCheckCharacter.Return0:
        #return
        add $v0, $0, 0  
        j _funcCheckCharacter.End
        
_funcCheckCharacter.End:
        #Restore reg
        lw $ra, ($sp)
	 lw $t0, 4($sp)
	 lw $t1, 8($sp)
	 lw $s0, 12($sp)
	 lw $s1, 16($sp)
	
	 addi $sp, $sp, 20
        
        jr $ra
#---End func CheckCharacter 
  
#---Func CheckName - ham kiem tra ten
#@params
#a0 - str
#@return
#v0 - 1 neu duoc chap thuan, 0 neu khong duoc chap thuan
_funcCheckName:
        #backup reg
        addi $sp, $sp, -20
        sw $ra, ($sp)
        sw $s0, 4($sp)
        sw $s1, 8($sp)
        sw $t0, 12($sp)
        sw $t1, 16($sp)
        
        move $s0, $a0	 	# addr of string
        jal _funcgetStringLength
        move $s1, $v0	 	# length of string
        
        addi $a0, $0, 0 
        addi $t0, $0, 0	 	# idx
        addi $t1, $0, 0 
        
_funcCheckName.Loop:
        # load, check tung ki tu, neu tat ca ki tu duoc chap nhan thi return 1
        # mat khac neu co 1 ki tuc khong duoc chap nhan thi return 0
        lb $a0, ($s0)
        jal _funcCheckCharacter
        beq $v0, $t1, _funcCheckName.Return0
        addi $t0, $t0, 1		 # i++
        addi $s0, $s0, 1		 # adr ++
        blt $t0, $s1, _funcCheckName.Loop
        
        j _funcCheckName.Return1
        
_funcCheckName.Return0:
        #return
        addi $v0, $0, 0
        j _funcCheckName.End
        
_funcCheckName.Return1:
        #return
        addi $v0, $0, 1
        j _funcCheckName.End
        
_funcCheckName.End:
        #Restore reg
        lw $ra, ($sp)
        lw $s0, 4($sp)
        lw $t0, 8($sp)
        lw $t1, 12($sp)
        lw $s1, 16($sp)
	 addi $sp, $sp , 20
        
        jr $ra    
#---End func CheckName
        
#---Func GetPlayerName - hàm lay ten nguoi choi
#@params
#none
#@return
#none
_funcGetPlayerName:
       # backup reg
       addi $sp, $sp, -16
       sw $ra, ($sp)
       sw $t0, 4($sp)
       sw $t1, 8($sp)
       sw $t2, 12($sp)
        
        li $t0, 0
_funcGetPlayerName.Loop:
      	la $t0, name 
       
      	#dialog input string
	li $v0, 54
	la $a0, messNameInput
	move $a1, $t0
	li $a2, 100		
	syscall
	
	beq $a1, 0, _funcGetPlayerName.Check
	beq $a1, -2, _funcGetPlayerName.Warning
	j _funcGetPlayerName.Error
	
_funcGetPlayerName.Check:
	#Concat '\0'
	move $a0, $t0
	jal _funcgetStringLength
	move $t1, $t0
	
	add $t1, $t1, $v0
	li $t2, '\0'
	sb $t2, ($t1)
	
	#Call check func
       move $a0, $t0 
       jal _funcCheckName
       beq $v0, 0, _funcGetPlayerName.invalidName
        
       j _funcGetPlayerName.End
       
_funcGetPlayerName.Warning:
      	li $v0, 50
	la $a0, messWaringInput
	li $a1, 0
	syscall
	
	#Press OK to re-enter letter
	beq $a0, 0,_funcGetPlayerName.Loop
	#Else -> exit game
	li $v0, 10
	syscall
	
_funcGetPlayerName.Error:
	li $v0, 55
	la $a0, messErrInput
	li $a1, 2
	syscall
	
	j _funcGetPlayerName
	
_funcGetPlayerName.invalidName:
	li $v0, 55
	la $a0, messInvalidName
	li $a1, 2
	syscall
	
	j _funcGetPlayerName
_funcGetPlayerName.End:
        #Return
        li $t1, 1
        sw $t1, isNameExisted
      
        #restore reg
        lw $ra, ($sp)
        lw $t0, 4($sp)
        lw $t1, 8($sp)
        lw $t2, 12($sp)
        addi $sp, $sp, 16
        
        jr $ra    
#---End func GetPlayerName

#---Func encryptWord - ham ma hoa tu
#@params
#$a0 ky tu nguoi choi doan
#@return
#$v0 - 0 - ki tu nhap vao sai, 1 - ki tu nhap vao dung
_funcEncryptWord:
	#Backup reg
	addi $sp, $sp, -28
	sw $ra, ($sp)
	sw $t0, 4($sp) 		#idx
	sw $t1, 8($sp) 		#compare result 
	sw $s0, 12($sp)		#flagExistedChar
	sw $s1, 16($sp) 		#lenOfWord
	sw $s2, 20($sp)		#encryptWord
	sw $s3, 24($sp) 		#word

	#Init
	li $t0, 0
	li $s0, 0
	lw $s1, lenOfWord
	la $s2, encryptWord
	la $s3, word
_funcEncryptWord.loop:
	beq $a0, '*', _funcEncryptWord.loop.continue 		#check guessChar = '*'
	j _funcEncryptWord.loop.checkEqualAsterisk
	
_funcEncryptWord.loop.continue:	
	sb $a0, ($s2) 						#set encryptWord[idx] = charGuess
	j _funcEncryptWord.check		
_funcEncryptWord.loop.checkEqualAsterisk:			#check EqualAsterisk
	lb $t2, ($s3)	
	beq $t2, $a0, _funcEncryptWord.loop.checkEqualcharGuess 
	j _funcEncryptWord.check
_funcEncryptWord.loop.checkEqualcharGuess:			#check equal charGuess
	sb $a0, ($s2)						#set encryptWord[idx] = charGuess
	li $s0, 1						#set value = 1
	j _funcEncryptWord.check
_funcEncryptWord.check:
	addi $t0, $t0, 1			#idx++
	addi $s2, $s2, 1 
	addi $s3, $s3, 1

	#check i < lenOfWord -> Loop
	slt $t1, $t0, $s1
	beq $t1, 1, _funcEncryptWord.loop

	j _funcEncryptWord.endLoop				#return value

_funcEncryptWord.endLoop:
	sb $0, ($s2)						#set null char for encryptWord[]
	move $v0, $s0						#set value into $v0

	#Restore req
	lw $ra, ($sp)
	lw $t0, 4($sp) 
	lw $t1, 8($sp) 
	lw $s0, 12($sp) 
	lw $s1, 16($sp) 
	lw $s2, 20($sp)
	lw $s3, 24($sp) 

	addi $sp, $sp, 28

	jr $ra
#---Endfunc EncryptWord

#---Func guessLetter - ham doan ki tu
#@params
#none
#@return
#$v0 - 0 - nguoi choi doan sai, 1 - nguoi choi doan dung
_funcGuessLetter:
	#Backup reg
	addi $sp, $sp, -8
	sw $ra, ($sp)
	sw $t0, 4($sp)			#charGuess
	
	#Allocate memory for charGuess into $t0
	li $v0, 9
	la $a0,1
	syscall
	move $t0, $v0
	
_funcGuessLetter.Input:
	#dialog input string
	li $v0, 54 
	la $a0, messPlayerGuess
	move $a1, $t0
	li $a2, 4	
	syscall

	beq $a1, 0, _funcGuessLetter.callInnerFunc
	beq $a1, -2, _funcGuessLetter.warning
	j _funcGuessLetter.error

_funcGuessLetter.callInnerFunc:
	lb $a0, ($t0) 				#set params
	jal _funcEncryptWord			#$v0 store return value

	j _funcGuessLetter.return 	
_funcGuessLetter.warning:
	li $v0, 50
	la $a0, messWaringInput
	li $a1, 0
	syscall
	
	#Press OK to re-enter letter
	beq $a0, 0, _funcGuessLetter.Input
	#Else -> exit game
	li $v0, 10
	syscall

_funcGuessLetter.error:
	li $v0, 55
	la $a0, messErrInput 
	li $a1, 2
	syscall
	
	j _funcGuessLetter.Input
_funcGuessLetter.return:
	#Return value in $v0

	#Restore reg
	lw $ra, ($sp)
	lw $t0, 4($sp)
	
	addi $sp, $sp, 8

	jr $ra
#---End func guessLetter

#---Func guessWholeWord - ham doan tu 
#@params
#none
#@return
#$v0 - 2 - nguoi choi doan sai, 3 - nguoi choi doan dung
_funcGuessWholeWord:
	#Backup req
	addi $sp, $sp, -32
	sw $ra, ($sp)
	sw $s0, 4($sp) 			#wordGuess[]
	sw $s1, 8($sp) 			#guessLen
	sw $s2, 12($sp)			#lenOfWord
	sw $s3, 16($sp)			#word[]
	sw $s4, 20($sp)			#return value
	sw $t0, 24($sp)			#count
	sw $t1, 28($sp)			#compare

	#Allocate memory for wordGuess into s0
	li $v0, 9
	li $a0, 100
	syscall
	move $s0, $v0

	#Init
	li $s1, 0
	li $t0, 0
	lw $s2, lenOfWord
	la $s3, word
_funcGuessWholeWord.Input:
	#Dialog input string
	li $v0, 54 
	la $a0, messPlayerGuess
	move $a1, $s0
	li $a2, 100	
	syscall

	beq $a1, 0, _funcGuessWholeWord.checkEqual.lenOfWord
	beq $a1, -2, _funcGuessWholeWord.warning
	j _funcGuessWholeWord.error

_funcGuessWholeWord.warning:
	li $v0, 50
	la $a0, messWaringInput
	li $a1, 0
	syscall
	
	#Press OK to re-enter letter
	beq $a0, 0, _funcGuessWholeWord.Input
	#Else -> exit game
	li $v0, 10
	syscall
	
_funcGuessWholeWord.error:
	li $v0, 55
	la $a0, messErrInput
	li $a1, 0
	syscall
	
	j _funcGuessWholeWord.Input
	
_funcGuessWholeWord.checkEqual.lenOfWord:
	move $a0, $s0				#set params 
	jal _funcgetStringLength			#$v0 store return value
	
	move $s1, $v0
	beq $s1, $s2, _funcGuessWholeWord.loop	#guessLen = lenOfWord -> loop
	j _funcGuessWholeWord.loop.return	#return value

_funcGuessWholeWord.loop:
	lb $t2, ($s3)
	lb $t3, ($s0)
	
	bne $t2, $t3, _funcGuessWholeWord.loop.return
	j _funcGuessWholeWord.loop.check

_funcGuessWholeWord.loop.return:
	li $s4, 2				#set value = 2
	j _funcGuessWholeWord.end
	
_funcGuessWholeWord.loop.check:
	addi $t0, $t0, 1
	addi $s0, $s0, 1
	addi $s3, $s3, 1
	
	slt $t1, $t0, $s2
	beq $t1, 1, _funcGuessWholeWord.loop
	li $s4, 3				#set value = 3

	j _funcGuessWholeWord.end

_funcGuessWholeWord.end:
	#Return value 
	move $v0, $s4
	
	#Restore reg
	lw $ra, ($sp)
	lw $s0, 4($sp) 			
	lw $s1, 8($sp) 			
	lw $s2, 12($sp)			
	lw $s3, 16($sp)			
	lw $s4, 20($sp)
	lw $t0, 24($sp)			
	lw $t1, 28($sp)			

	addi $sp, $sp, 32

	jr $ra
#---End func guessWholeWord

#---Func getWord - ham lay ngau nhien mot tu trong bo de thi da doc len
#@params
#none
#@return
#none
_funcGetWord:
	#Backup reg
	addi $sp, $sp, -36
	sw $ra, ($sp)
	sw $s0, 4($sp) 
	sw $s1, 8($sp)
	sw $t0, 12($sp) 
	sw $t1, 16($sp) 
	sw $t2, 20($sp) 
	sw $t3, 24($sp)
	sw $t4, 28($sp)
	sw $t5, 32($sp)

	#Init
	li $t1, 0 			#lenOfWord
	
	la $t4, word			#adress of word
	la $s0, bufferDethi		#adress of BufferDethi
	lw $s1, buffLen			#length of BufferDethi

	#time
	li $v0, 30
	syscall
	move $t5, $a0

	#set seed
	li $v0, 40
	li $a0, 0
	move $a1, $t5
	syscall
	
	#random mot Word trong buffer trong khoang[0, numOfWordInBuff -1]
	li $v0, 42
	li $a0, 0
	lw $a1, numOfWordInBuff	
	syscall
	
	move $t0, $a0 	#PosofWord

	li $t2, 0

_funcGetWord.loop:
	bge $t2, $s1, _funcGetWord.stop			#index >= BuffLen ->stop

	lb $t3, ($s0)

	beq $t3, '*', _funcGetWord.CheckEqualAteriskSign  #if BufferDethi[index] = '*' -> PosofWord--
	j _funcGetWord.CheckPosOfWordEqualZero

_funcGetWord.CheckEqualAteriskSign:
	addi $t0,$t0, -1
	j _funcGetWord.continue

_funcGetWord.CheckPosOfWordEqualZero:
	beq $t0, 0, _funcGetWord.PosOfWordEqualZero	#if PosofWord==0 -> word[index1++] = BufferDethi[index
	j _funcGetWord.continue

_funcGetWord.PosOfWordEqualZero:
	sb $t3, ($t4)

	addi $t4, $t4, 1
	addi $t1, $t1, 1
_funcGetWord.continue:
	addi $s0, $s0, 1
	addi $t2, $t2, 1
	j _funcGetWord.loop

_funcGetWord.stop:
	#Set ky tu ket thuc Word
	li $t3, '\0'
	sb $t3, ($t4)

	# set lenOfWord
	sw $t1, lenOfWord

	#Restore reg
	lw $ra, ($sp)
	lw $s0, 4($sp) 
	lw $s1, 8($sp)
	lw $t0, 12($sp) 
	lw $t1, 16($sp) 
	lw $t2, 20($sp) 
	lw $t3, 24($sp)
	lw $t4, 28($sp)
	lw $t5, 32($sp)
	addi $sp, $sp, 36

	jr $ra
#---End func getWord

#---Func ChooseTypeGuess - Chon loai de nguoi choi doan
#@params
#none
#@return 	
#$v0 - 1 - guess character, 2 - gess word
_funcChooseTypeGuess:
	#Backup reg
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $t0, 4($sp)
	
_funcChooseTypeGuess.Input:	
	#Xuat lua chon
	li $v0, 51
	la $a0, messGuessType
	syscall

	#Nhap vao so nguyen se return kq
	beq $a1, 0, _funcChooseTypeGuess.return

	#Nhap sai hoac khong nhap se xuat thong bao Error if bang -1, nguoc lai xuat thong bao Warning
	move $t0, $a1

	beq $t0, -1, _funcChooseTypeGuess.messageErr
	j _funcChooseTypeGuess.messageWarning

_funcChooseTypeGuess.messageErr:
	li $v0, 55
	la $a0, messErrInput
	li $a1, 0
	syscall

	j _funcChooseTypeGuess.Input		
	
_funcChooseTypeGuess.messageWarning:
	li $v0, 50
	la $a0, messWaringInput
	li $a1, 2
	syscall

	#Press OK to re-enter letter
	beq $a0, 0, _funcChooseTypeGuess.Input
	#Else -> exit game
	li $v0, 10
	syscall

_funcChooseTypeGuess.return:
	#return type
	move $v0, $a0
	
_funcChooseTypeGuess.stop:
	#Restore reg		
	lw $ra, ($sp)
	lw $t0, 4($sp)
	addi $sp, $sp, 8

	jr $ra
#End Func ChooseTypeGuess

#---Func ResetWordData - xoa du lieu da luu tron word -. chuyen ve '\0'
#@params
#none
#@return
#none
_funcResetWordData:
	#Backup reg
	addi $sp, $sp, -28
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $t0, 8($sp)
	sw $t1, 16($sp)
	sw $t2, 20($sp)
	sw $t3, 24($sp)
	
	li $t0, 0
	li $t3, '\0'

	lw $s0, lenOfWord	#lenofWord
	la $t1, word		#adress of Word
	la $t2, encryptWord	#adress of encryptWord
	
_funcResetWordData.loop:
	bge $t0, $s0, _funcResetWordData.stop	#if index>= lenOfWord -> stop

	#save byte word[index], encryptWord[index]
	sb $t3, ($t1)
	sb $t3, ($t2)

	addi $t1, $t1, 1
	addi $t2, $t2, 1
	addi $t0, $t0, 1
	j _funcResetWordData.loop

_funcResetWordData.stop:
	#Restore reg
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $t0, 8($sp)
	lw $t1, 16($sp)
	lw $t2, 20($sp)
	lw $t3, 24($sp)
	addi $sp, $sp, 28

	jr $ra
#---End func ResetWordData

#---Func ShowHighScore - ham  xuat ra top 10 nguoi choi cao nhat
#@params
#none
#@return
#none
_funcShowHighScore:
	#Backup reg
	addi $sp, $sp, -24
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $t0, 16($sp)
	sw $t1, 20($sp)
	
	#Open file nguoichoi.txt
	li $v0, 13
	la $a0, nguoichoiPath
	li $a1, 0					#flag read
	li $a2, 0
	syscall
	
	move $s0, $v0					#store file desciptor in $s0
	
	#Allocate memory stored in $s1
	li $v0, 9           			
	li $a0, 4096  
	syscall
	
	move $s1, $v0
	
	#Read file nguoichoi.txt into $s1
	li $v0, 14
	move $a0, $s0
	move $a1, $s1
	li $a2, 4096
	syscall
	
	move $s2, $s1
_funcShowHighScore.Loop.replaceAterisk:
	lb $t0, ($s2)
	
	beq $t0, '\0', _funcShowHighScore.Show
	bne $t0, '*', _funcShowHighScore.Loop.replaceAterisk.continue
	
	#if $t0 == '*' -> replace by '\n'
	li $t1, '\n'
	sb $t1, ($s2)
	
_funcShowHighScore.Loop.replaceAterisk.continue:
	addi $s2, $s2, 1
	j _funcShowHighScore.Loop.replaceAterisk
	
_funcShowHighScore.Show:
	#Concat title high score
	la $a0, messTitleHighScore
	move $a1, $s1
	li $a2, '\0'
	jal _funcConcatString
	move $a0, $v0
	
	#Show in mess dlg
	li $v0, 55
	li $a1, 1
	syscall
	
	#Close file
	li $v0, 16
	move $a0, $s0
	syscall
	
	#Restore reg
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $t0, 16($sp)
	lw $t1, 20($sp)
	
	addi $sp, $sp, 24
	
	jr $ra
#---End func showHighScore

#---Func checkEncryptWord - ham kiem tra xem nguoi choi da giai ma het ki tu hay chua
#@params
#none
#@return
#$v0 - 1 - nguoi choi chua chien thang, 3 - nguoi choi chien thang
_funcCheckEncryptWord	:
	#Backup reg
	addi $sp, $sp, -28
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $t0, 16($sp)
	sw $t1, 20($sp)
	sw $t2, 24($sp)
	
	la $s0, encryptWord
	lw $s1, lenOfWord
	
	li $t0, 3			#flag Win
	move $s2, $s0
	li $t1, 0
_funcCheckEncryptWord.Loop:
	bge $t1, $s1, _funcCheckEncryptWord.endLoop			#if idx >= len -> end loop
	
	lb $t2, ($s2)
	bne $t2, '*', _funcCheckEncryptWord.Loop.continue			#if encryptWord[i] == '*' -> chua doan het ki tu
	
	li $t0, 1
	j _funcCheckEncryptWord.endLoop
	
_funcCheckEncryptWord.Loop.continue:
	addi $s2, $s2, 1
	addi $t1, $t1, 1
	
	j _funcCheckEncryptWord.Loop
	
_funcCheckEncryptWord.endLoop:
	#Return value in $v0
	move $v0, $t0
	
	#Restore reg
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $t0, 16($sp)
	lw $t1, 20($sp)
	lw $t2, 24($sp)
	
	addi $sp, $sp, 28
	
	jr $ra
#---End func checkEncyptWord
	
