input1      EQU     $8000           where input 1 is stored (can be changed if needed)
input2      EQU     $8004          where input 2 is stored (can be changed if needed)
userInputStored    EQU     $8008   





    ORG    $1000
START:                           *Main

    BSR     USERINPUT
    MOVE.B #$12, D6
    MOVE.W #$1004, A2
    MOVEQ #10, D6
    MOVEA.L A2, A3

    BSR     OPCODE * test MOVE.B
    MOVE.W #$1008, A2
    BSR     OPCODE * test MOVE.W
    MOVE.W #$100C, A2
    BSR     OPCODE * test MOVEQ
    MOVE.W #$100E, A2
    BSR     OPCODE *test MOVEA.L


    SIMHALT



**********************************************************
*Subroutine: OPCODE
*What it does: Looks at the word pointed to by A2 and determines opcode
*Registers: 
*A1: printing
*A2: parameter with instruction address
*D0: printing
*D3: used for determing the instruction, mostly shifts
*D4: used for determing the size
*Paramemeters: A2 the memory address to decode from
**********************************************************
OPCODE:
    CLR D3
    Move.W (A2), D3 
    LSR #8,D3 * make D3 only contain the first 4 bits of the instruction as its LSig word
    LSR #4,D3
    
    
    cmp #$4E71, (A2) *NOP compare
    BEQ nop
    
    
    Cmp #%0011, D3 *MOVE and MOVEA compare
    BLE move
    
    Cmp #%0111, D3 *MOVEQ compare
    BEQ moveq

    
return
    RTS
byte
    LEA    byteout,A1        
    MOVE.B  #14,D0                  
    TRAP    #15 
    BRA return
word
    LEA    wordout,A1        
    MOVE.B  #14,D0                  
    TRAP    #15 
    BRA return
long
    LEA    longout,A1        
    MOVE.B  #14,D0                  
    TRAP    #15 
    BRA return
    
nop 
    LEA    nopout,A1        
    MOVE.B  #14,D0                  
    TRAP    #15 
    BRA return
    
move
    * put the size of the instruction into D2 to use later
    * since the first two bits of D3 are 00 for move moving the entire word works
    Move.W D3, D2


    * determine if MOVE or MOVEA
    * if bits 8,7,6 = 001 its MOVEA
    MOVE.W (A2),D3
    ANDI.W #%0000000111000000, D3 *extract only bits 8,7,6
    
    CMP #%0000000001000000,D3 * if only the sixth bit is set then instruction is MOVEA
    BEQ movea
    
 
    LEA    moveout,A1     *print the type   
    MOVE.B  #14,D0                  
    TRAP    #15 
    
    *now to print size  
    cmp #2,D2 *if the size is 2 branch to long
    BEQ long
    cmp #3,D2 *if the size is 3 branch to word
    BEQ word
    BRA byte *otherwise branch to byte
  
    BRA return
    
    
movea
    LEA    moveaout,A1       
    MOVE.B  #14,D0                  
    TRAP    #15 
    
    *now to print size  
    cmp #2,D2 *if the size is 2 branch to long
    BEQ long
    cmp #3,D2 *if the size is 3 branch to word
    BEQ word
    
    BRA return
    
moveq
    LEA    moveqout,A1       
    MOVE.B  #14,D0                  
    TRAP    #15 
    BRA return




**********************************************************
*Subroutine: USERINPUT
*What it does: Takes in user input, rejects bad input
*Registers: Uses register A1, D0, D5
*Paramemeters: No parameters
**********************************************************
USERINPUT:

welcomeExplanation
    LEA     STARTMESSAGE,A1         
    MOVE.B  #14,D0
    TRAP    #15

firstInput
    LEA     INPUT1MESSAGE,A1        
    MOVE.B  #14,D0                  
    TRAP    #15                     Asks user for first input
    
    LEA     userInputStored,A1
    MOVE.B  #2,D0                   
    TRAP    #15                     User can input string for address
    
    BSR     CONVERT                 String converted to hex address
    
    CMP.B   #0,(InputQuality)       Checks if bad input flag set
    BEQ     throwInput1CharError        
    
    AND.L   #$00FFFFFF,D5
    MOVE.L  D5,input1               Moves result into input 1 memory location
    CLR.L   D5                      Clears D5 for future use
    BRA     secondInput
    
throwInput1CharError
    LEA     INPUTERRORBADCHAR,A1
    MOVE.B  #14,D0
    TRAP    #15                     Outputs bad character error message
    
    MOVE.B  #1,(InputQuality)       Resets quality flag to default (good)
    CLR.L   D5                      Clears D5 for future use
    
    BRA     firstInput              Tries again for input1

    
secondInput
    LEA     INPUT2MESSAGE,A1        
    MOVE.B  #14,D0                  
    TRAP    #15                     Asks user for second input
    
    LEA     userInputStored,A1
    MOVE.B  #2,D0                   
    TRAP    #15                     Sser can input string for address
    
    BSR     CONVERT                 String converted to hex address

    CMP.B   #0,(InputQuality)       
    BEQ     throwInput2CharError        Checks if bad input flag set
    
    AND.L   #$00FFFFFF,D5
    CMP.L   (input1),D5
    BLT     throwInput2LowerError
    MOVE.L  D5,input2               Moves result into input 2 memory location
    CLR.L   D5                      Clears D5 for future use
    RTS    
    
throwInput2CharError
    LEA     INPUTERRORBADCHAR,A1    
    MOVE.B  #14,D0
    TRAP    #15                     Outputs bad character error message
    
    MOVE.B  #1,(InputQuality)       Resets quality flag to default (good)
    CLR.L   D5                      Clears D5 for future use
    
    BRA     secondInput             Tries again for input2
    
throwInput2LowerError
    LEA     INPUTERROR2SMALLER,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BRA     secondInput


**********************************************************
*Subroutine: CONVERT
*What it does: Converts user input to hex code
*Registers: Uses register A1, D2, D5
*Paramemeters: User input stored in (A1)
********************************************************** 
CONVERT:
    
AtoH
    MOVE.B  (A1)+,D2                Takes first bit (letter), moves to D2 for testing
    
    CMP.B   #$00,D2                 Compares to 00, since 00 is null (enter)
    BEQ     Finish                  Moves to finish if they are equal (no more input)
    
    ASL.L   #4,D5
    
    CMP.B   #$30,D2
    BLT     inputError
    
    CMP.B   #$39,D2                 Compares to 39, because 39 in ASCII is 9, which is largest number
    BGT     uppercase               Branches if greater, may or may not be a letter in hex
    
    SUBI.B  #$30,D2                 Subtracts 30 to turn it into it's hex format
    ADD.B   D2,D5
    
    BRA     AtoH

        
uppercase   
    CMP.B   #$41,D2
    BLT     InputError              Greater than 39 and less than 41 is not part of hex code
    
    CMP.B   #$46,D2                 
    BGT     lowercase               Greater than 46 may be hex code in lowercase
    
    SUBI.B  #$37,D2                 Subtracts 37 to turn it into hex format
    ADD.B   D2,D5
    BRA     AtoH

lowercase
    CMP.B   #$61,D2
    BLT     InputError              Greater than 46 and less than 61 is not part of hex code
    
    CMP.B   #$66,D2
    BGT     InputError              Greater than 66 is not part of hex code
    
    SUBI.B  #$57,D2
    ADD.B   D2,D5
    BRA     AtoH
        
Finish
    RTS                             Return from CONVERT
    
inputError
    MOVE.B  #0,(InputQuality)
    RTS

    
END_SIMULATION:
        
    MOVE.B  #9,D0
    TRAP    #15

    SIMHALT             ; halt simulator

* Put variables and constants here
STARTMESSAGE    DC.B    'Welcome to the CSS 422 dissasembler!',CR,LF
                DC.B    'Some quick rules:',CR,LF
                DC.B    '1) Only the last 6 characters will be saved as the address',CR,LF
                DC.B    '2) The input accepts hexadecimal input, both in upper and lower case',CR,LF
                DC.B    '3) Any part of the input that is not within the hexadecimal range ',CR,LF
                DC.B    '   will be rejected',CR,LF
                DC.B    '4) The first input must be smaller than the second, otherwise it ',CR,LF
                DC.B    '   will be rejected',CR,LF,0      
INPUT1MESSAGE   DC.B    'Please input the lower address edge',CR,LF,0
INPUT2MESSAGE   DC.B    'Please input the upper address edge',CR,LF,0
INPUTERRORBADCHAR   DC.B    CR,LF,'This value is not valid',CR,LF,CR,LF,0
INPUTERROR2SMALLER  DC.B    CR,LF,'Input 2 is smaller than input 1. Input a larger value',CR,LF,CR,LF,0


nopout  DC.B    'NOP',CR,LF,0
moveout  DC.B    'MOVE',0
moveaout DC.B      'MOVEA',0
moveqout DC.B   'MOVEQ',CR,LF,0 * CR and LF is temp on this


byteout  DC.B    '.B',CR,LF,0
wordout  DC.B    '.W',CR,LF,0
longout  DC.B    '.L',CR,LF,0

empty    DC.B    '',CR,LF,0

InputQuality    DC.B    1       Set to 1 for default good

CR  EQU $0D
LF  EQU $0A



    END    START        ; last line of source








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
