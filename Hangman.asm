;*****************************************************************************
;  Author: Pamela Thompson
;  Date: 4/24/2026
;  Revision: 1.0
;
;  Description: Hangman game
;     
;  Notes:
;     - Welcome screen
;     - Draw hangman body parts
;     - Guess words
;     - Wrong letters count
;     - Display dashes for hidden word
;     - Win/ Lose
;
;  Register Usage:
;     R0 Used for TRAP
;     R1 counter for wrong letter guess and index
;****************************** MAIN *******************************************/
    .ORIG       x3000
;------ Display welcome screen -------------------    
    JSR WelcomeScreen
    
;------ Initialize word index to 0 -------------
    AND R0, R0, #0
    ST R0, IndexWord    
    
;------ Select word to guess from list -----------
    JSR SelectWord

;------ Initialize secret word to (_ _ _ ) -------
    JSR InitWord
;------------------------ GAME LOOP ---------------------------------------------    
GameLoop
;   Display board
    JSR DrawHangman
    
;   Print dashes for word to guess
    JSR DisplayGuessingWord

;   Ask user for a letter to guess
    LEA R0, MESSAGE
    TRAP x22
    
;   Read user input
    TRAP x20
    OUT

;   Compare guess to letter of word to guess
    JSR checkGuess

;   Check if player won
    JSR CheckWin
    ADD R2, R2, #0
    BRp PlayerWon

;   Check if player lost
    LEA R5, WrongGuess
    LDR R1, R5, #0
    ADD R1, R1, #-6
    BRz PlayerLost

;   Loop again
    BR GameLoop

;--------------- Player won ------------------------
PlayerWon
    ; Increment index
    LD R1, IndexWord
    ADD R1, R1, #1      ;index++
    ST R1, IndexWord
    
    ; Reset wrong guess if word guessed
    AND R1, R1, #0
    ST R1, WrongGuess
    
    LEA R0, WinMsg
    TRAP x22
    
;   Print correct word
    LEA R0, Word
    TRAP x22
    ;   Display correct word
    LD R0, CurrentWord
    TRAP x22
    
    ; move to next word
    JSR SelectWord
    JSR InitWord
    
    BR GameLoop

;--------------- Player lost ------------------------
PlayerLost
;  Display final hangman
    JSR DrawHangman
    
    LEA R0, LostMsg
    TRAP x22

;   Display correct word
    LD R0, CurrentWord
    TRAP x22
    
GAMEOVER    HALT

;******************************************************************************    
MESSAGE .STRINGZ "\nPlease enter a letter to guess: "
WinMsg  .STRINGZ "\nCongrats! you won!"
Word    .STRINGZ "\nYou have guessed: "
LostMsg .STRINGZ "\n GAME OVER! The word was: "

IndexWord   .BLKW #1

;********************** Subroutine1: Welcome screen****************************
;  Description: Display welcome screen to user
;
;  Register Usage:
;     R0 Used for TRAP
;     R7 
;****************************************************************************/
WelcomeScreen
;   Save Registers
    ST R7, SAVER7_WELCOME
    
;   Load strings for welcome screen
    LEA R0, WELCOME1
    TRAP X22
    
    LEA R0, WELCOME2
    TRAP X22

    LEA R0, WELCOME3
    TRAP X22
    
;   read ENTER
    TRAP X20
    
;   Restore Registers
    LD R7, SAVER7_WELCOME
    RET
;****************************************************************************/
SAVER7_WELCOME  .BLKW 1

WELCOME1    .STRINGZ "Welcome to Hangman!\n"
WELCOME2    .STRINGZ "By: Pamela Thompson\n"
WELCOME3    .STRINGZ "\nPress ENTER to start the game"

;********************** Subroutine2: Select Word ****************************
;  Description: This subroutine Selects a word to guess
;     
;  Register Usage:
;     R1 holds starting address of list 
;     R2 return word
;     R7 
;****************************************************************************/
SelectWord
    ST R7, SAVER7_SELECT
    ST R1, SAVER1_SELECT
    
    LEA R1, List        ; load list starting address
    LD R3, IndexWord    ; R3 = current index
    ADD R1, R1, R3      ; list[index]
    
    LDR R2, R1, #0      ; load word address
    ST R2, CurrentWord  ; return word
    
    LD R1, SAVER1_SELECT
    LD R7, SAVER7_SELECT
    RET
;****************************************************************************    
SAVER1_SELECT .BLKW #1
SAVER7_SELECT .BLKW #1

WrongGuess   .BLKW #1

CurrentWord   .BLKW #1
;-------Word list ------------------------------
List
    .FILL DOG
    .FILL APPLE
    .FILL STAR
    .FILL BANANA
    .FILL GIRAFFE
    .FILL ROBOT
    .FILL DRAGON
    .FILL PIZZA


DOG         .STRINGZ "dog"
APPLE       .STRINGZ "apple"
STAR        .STRINGZ "star"
BANANA      .STRINGZ "banana"
GIRAFFE     .STRINGZ "giraffe"
ROBOT       .STRINGZ "robot"
DRAGON      .STRINGZ "dragon"
PIZZA       .STRINGZ "pizza"
;*************************************************************************
;********************** Subroutine3: InitWord ****************************
;  Description: This subroutine initializes word to guess to all underscores
;     
;  Notes:
;     - Loop through the string and count how many letter are in the 
;       word to guess and 
;
;  Register Usage:
;     R0 contains blah as a calling parm; returns blah
;     R1 holds current word address
;     R2 holds hidden word in underscores
;     R3 reads each char of the string
;     R4 hold underscores
;     R5 counter for letters
;     R7 Reserved for blah
;****************************************************************************/
InitWord
    ST R7, SAVER7_INIT
    ST R5, SAVER5_INIT
    ST R4, SAVER4_INIT
    ST R3, SAVER3_INIT
    ST R2, SAVER2_INIT
    
    LD R1, CurrentWord  ; R1 = current word address
    
    LEA R2, HiddenWord  ; R2 = hidden word
    
    AND R5, R5, #0      ; Counter for number of letters in the string
    
loopInit
    LDR R3, R1, #0      ; load char
    BRz initDone        
    
    ADD R5, R5, #1      ; counter++
    
    LD R4, UNDERSCORE   ; store _
    STR R4, R2, #0
    
    ADD R2, R2, #1      ; Move pointer to next space
    
    LD R4, SPACE        ; store blank space
    STR R4, R2, #0
    
    ; Update pointers
    ADD R2, R2, #1
    ADD R1, R1, #1
    
    BR loopInit
    
initDone
    ; Add null terminator
    AND R4, R4, #0
    STR R4, R2, #0
    ST R5, COUNTER_LETTERS
    
    
    LD R7, SAVER7_INIT
    LD R5, SAVER5_INIT
    LD R4, SAVER4_INIT
    LD R3, SAVER3_INIT
    LD R2, SAVER2_INIT
    RET
;****************************************************************************
SAVER2_INIT .BLKW #1
SAVER3_INIT .BLKW #1
SAVER4_INIT .BLKW #1
SAVER5_INIT .BLKW #1
SAVER7_INIT .BLKW #1

HiddenWord  .BLKW #15

UNDERSCORE  .FILL x005F
SPACE       .FILL x0020

;********************** Subroutine4: DisplayGuessingWord **********************
;  Description: This subroutines displays word initialized to all underscores
;     
;  Register Usage:
;     R0 Used for TRAP
;     R1 holds ASCII val of letter count
;     R7 
;****************************************************************************/
DisplayGuessingWord
    ST R7, SAVER7_PRINT
    ST R1, SAVER1_PRINT
    ST R0, SAVER0_PRINT
    
    LEA R0, PROMPT_LETTERS
    TRAP X22
    
;   Convert decimal val to ascii val
    LD R0, COUNTER_LETTERS
    LD R1, ASCII
    ADD R0, R0, R1
    TRAP x21
    
    LEA R0, LETTERS
    TRAP X22
    
    LEA R0, HiddenWord
    TRAP X22
    
    LEA R0, NEWLINE
    TRAP X22
    
    LD R7, SAVER7_PRINT
    LD R1, SAVER1_PRINT
    LD R0, SAVER0_PRINT
    RET

;****************************************************************************    
SAVER0_PRINT    .BLKW #1
SAVER1_PRINT    .BLKW #1
SAVER7_PRINT    .BLKW #1

COUNTER_LETTERS .BLKW #1

ASCII           .FILL x0030

NEWLINE         .STRINGZ "\n"
PROMPT_LETTERS  .STRINGZ "\nThe word to guess has "
LETTERS         .STRINGZ " letters!\n"

;********************** Subroutine5: checkGuess *****************************
;  Description: This subroutine checks if letter entered matches any of the
;               word to guess.
;     
;  Notes:
;     - If it matches then display it in the all dashes string
;
;  Register Usage:
;     R0 Used for TRAP
;     R1 Pointer to current word
;     R2 Pointer to hidden word
;     R3 current char form word to guess
;     R4 holds negative value of letter to compare
;     R5 Pointer to wrong guess counter
;     R6 Flag to find letter match
;     R7 return address
;****************************************************************************/
checkGuess
    ST R7, SAVER7_GUESS
    ST R6, SAVER6_GUESS
    ST R5, SAVER5_GUESS
    ST R4, SAVER4_GUESS
    ST R3, SAVER3_GUESS
    ST R2, SAVER2_GUESS
    ST R1, SAVER1_GUESS
    
    LD R1, CurrentWord  ; R1 = word to guess
    
    LEA R2, HiddenWord  ; R2 = hidden word
    
    AND R6, R6, #0      ; Flag to find letter match

loopCheck
    LDR R3, R1, #0
    BRz doneCheck
    
;   Compare letters
    NOT R4, R3
    ADD R4, R4, #1      ; 2's complement of char to compare
    
    ADD R4, R0, R4      ; Compare current char in string with user input
    BRnp NotMatch
    
;   Store correct letter
    STR R0, R2, #0      ; R2 = right char
;   Letter match
    ADD R6, R6, #1      ; Flag letter found
    
NotMatch
;   Move to next char
    ADD R1, R1, #1
    
;   Skip "_ "
    ADD R2, R2, #2
    BR loopCheck
    
doneCheck
    ADD R6, R6, #0
    BRp FinishCheck
    
    ; If there is no match then increment counter
    LEA R5, WrongGuess
    LDR R1, R5, #0
    ADD R1, R1, #1
    STR R1, R5, #0
    
FinishCheck
    LD R1, SAVER1_GUESS
    LD R2, SAVER2_GUESS
    LD R3, SAVER3_GUESS
    LD R4, SAVER4_GUESS
    LD R5, SAVER5_GUESS
    LD R6, SAVER6_GUESS
    LD R7, SAVER7_GUESS
    RET
;****************************************************************************    
SAVER1_GUESS    .BLKW #1
SAVER2_GUESS    .BLKW #1
SAVER3_GUESS    .BLKW #1
SAVER4_GUESS    .BLKW #1
SAVER5_GUESS    .BLKW #1
SAVER6_GUESS    .BLKW #1
SAVER7_GUESS    .BLKW #1

;********************** Subroutine6: CheckWin****************************
;  Description: This subroutines check if player guessed the secret word
;               (no underscores remain).
;     
;  Notes:
;     If no underscores are found then R2 returns 1 to indicate a win
;
;  Register Usage:
;     R1 Pointer to hidden word
;     R2 Return 1 if user won
;     R3 current char from hidden word
;     R4 use for operations
;     R7 Return address
;****************************************************************************/
CheckWin
    ST R7, SAVER7_WIN
    ST R4, SAVER4_WIN
    ST R3, SAVER3_WIN
    ST R1, SAVER1_WIN
    
    AND R2, R2, #0      ;R2 = 0
    LEA R1, HiddenWord
    
loopWin
    LDR R3, R1, #0
    
    BRz playerWin
    
;   look for underscore
    LD R4, UNDERSCORE
    NOT R4, R4
    ADD R4, R4, #1
    ADD R4, R3, R4
    
    BRz notWin
    
    ADD R1, R1, #1
    BR loopWin
    
playerWin
    ADD R2, R2, #1
    
notWin 
    LD R1, SAVER1_WIN
    LD R3, SAVER3_WIN
    LD R4, SAVER4_WIN
    LD R7, SAVER7_WIN
    RET
;****************************************************************************    
SAVER1_WIN .BLKW #1
SAVER3_WIN .BLKW #1
SAVER4_WIN .BLKW #1
SAVER7_WIN .BLKW #1

;********************** Subroutine7: DrawHangman****************************
;  Description: This subroutine displays hangman on the screen and updates it 
;               bassed on the number of incorrect guesses stored in WrongGuess.
;  Notes:
;    Each wrong guess adds part of the hangman like:
;   -1   =  O   -> head
;   -2   =  |   -> body
;   -3,4 = /|\  -> arms
;   -5,6 =  /\  -> legs
;
;  Register Usage:
;     R0 Used for TRAP
;     R1 holds wrong guess counter
;     R2 used for operations
;     R7 returns address
;****************************************************************************/
DrawHangman
    ST R7, SAVER7_DRAW
    ST R2, SAVER2_DRAW
    ST R1, SAVER1_DRAW
    ST R0, SAVER0_DRAW
    
    LEA R0, TOP1
    TRAP x22
    
    LEA R0, TOP2
    TRAP x22
    
    LD R1, WrongGuess   ; R1 = counter for wrong guesses

;---------- Display head ---------------------
    ADD R2, R1, #-1
    BRn noHead
    
    LEA R0, HEAD
    TRAP x22
    BR checkBody
    
noHead
    LEA R0, EMPTY
    TRAP x22

;---------- Body ------------------------------
checkBody
    ADD R2, R1, #-2
    BRn noBody
    
    ADD R2, R1, #-3
    BRn bodyOnly

    ADD R2, R1, #-4
    BRn leftArm    

    LEA R0, RIGHTARM
    TRAP x22
    BR checkLegs
    
bodyOnly
    LEA R0, BODY
    TRAP x22
    BR checkLegs
    
leftArm
    LEA R0, ONEARM
    TRAP x22
    BR checkLegs

noBody
    LEA R0, EMPTY
    TRAP x22
    
;---------- Legs ------------------------------
checkLegs
    ADD R2, R1, #-5
    BRn NoLegs
    
    ADD R2, R1, #-6
    BRn OneLeg
    
    LEA R0, RIGHTLEG
    TRAP x22
    BR drawCompleted

NoLegs
    LEA R0, EMPTY
    TRAP x22
    BR drawCompleted
    
OneLeg
    LEA R0, LEFTLEG
    TRAP X22
    BR drawCompleted

drawCompleted
    LEA R0, BOTTOM
    TRAP x22

    LD R0, SAVER0_DRAW
    LD R1, SAVER1_DRAW
    LD R2, SAVER2_DRAW
    LD R7, SAVER7_DRAW
    RET
    
;****************************************************************************    
SAVER0_DRAW .BLKW #1
SAVER1_DRAW .BLKW #1
SAVER2_DRAW .BLKW #1
SAVER7_DRAW .BLKW #1

TOP1     .STRINGZ "\n_________"
TOP2     .STRINGZ "\n|       |"

HEAD     .STRINGZ "\n|       O"
BODY     .STRINGZ "\n|       |"
ONEARM   .STRINGZ "\n|      /|"
RIGHTARM .STRINGZ "\n|      /|\\ "
LEFTLEG  .STRINGZ "\n|      /"
RIGHTLEG .STRINGZ "\n|      / \\ "

EMPTY    .STRINGZ "\n|"
BOTTOM   .STRINGZ "\n---\n"


.END

