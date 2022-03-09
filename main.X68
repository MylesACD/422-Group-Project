addressOutput EQU   $9005
input1      EQU     $8000           where input 1 is stored (can be changed if needed)
input2      EQU     $8004          where input 2 is stored (can be changed if needed)
userInputStored    EQU     $8008   





    ORG    $1000
START:                           *Main

    MOVE.B  #0,(LineCounter)
userInputStart
    BSR     USERINPUT
    MOVE.B #$12, D6
    MOVE.W #$1004, A2
    MOVEQ #10, D6
    MOVEA.L A2, A3
    BRA here
here
    MOVE.W #$100C, A2
    BSR     OPCODE * test MOVE.B

    MOVE.W #$1010, A2
    BSR     OPCODE * test MOVEA.W
    
    MOVE.W #$1014, A2
    BSR     OPCODE * test MOVEQ
   
    MOVE.W #$1016, A2
     BSR     OPCODE *test MOVEA.L
     
    MOVE.W #$1018, A2
     BSR     OPCODE *test BRA


    
userInputRepeat
    LEA     INPUTREPEAT,A1
    MOVE.B  #14,D0
    TRAP    #15
    ADD.B   #1,(LineCounter)
    
    LEA     userInputStored,A1
    MOVE.B  #5,D0
    TRAP    #15
    
    CMP.B   #$00,(A1)
    BEQ     userInputStart
 
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
    
    
    CMP #$4E71, (A2) *NOP compare
    BEQ nop
    
    
    CMP #%0011, D3 *MOVE and MOVEA compare
    BLE move
    
    CMP #%0111, D3 *MOVEQ compare
    BEQ moveq





    CMP #$4E75, (A2) * RTS compare
    BEQ rts
    
    Move.W (A2), D3 * reset D3
    LSR #8,D3 * make D3 only contain the first 8 bits of the instruction as its LSig word
    
    CMP #%01100000, D3 *BRA compare
    BEQ bra
    
    
    BRA data
    
return
    RTS
byte
    LEA    byteout,A1        
    MOVE.B  #2,(OutputType)
    BSR     OUTPUT 
    BRA return
word
    LEA    wordout,A1        
    MOVE.B  #2,(OutputType)
    BSR     OUTPUT
    BRA return
long
    LEA    longout,A1        
    MOVE.B  #2,(OutputType)
    BSR     OUTPUT 
    BRA return
    
nop 
    LEA    nopout,A1        
    MOVE.B  #1,(OutputType)
    BSR     OUTPUT
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
    MOVE.B  #1,(OutputType)   
    BSR    OUTPUT
    
    *now to print size  
    cmp #2,D2 *if the size is 2 branch to long
    BEQ long
    cmp #3,D2 *if the size is 3 branch to word
    BEQ word
    BRA byte *otherwise branch to byte
  
    BRA return
    
    
movea
    LEA    moveaout,A1
    MOVE.B  #1,(OutputType)       
    BSR    OUTPUT
    
    *now to print size  
    cmp #2,D2 *if the size is 2 branch to long
    BEQ long
    cmp #3,D2 *if the size is 3 branch to word
    BEQ word
    
    BRA return
    
moveq
    LEA    moveqout,A1
    MOVE.B  #1,(OutputType)       
    BSR    OUTPUT
    BRA return
rts
    LEA    rtsout,A1
    MOVE.B  #1,(OutputType)       
    BSR    OUTPUT
    BRA return

bra
    LEA    braout,A1
    MOVE.B  #1,(OutputType)       
    BSR    OUTPUT
    BRA return

data


**********************************************************
*Subroutine: USERINPUT
*What it does: Takes in user input, rejects bad input
*Registers: Uses register A1, D0, D5
*A1: Stores messages and user input
*D0: Used for TRAP #15
*D5: Temporaraly stores user input to be masked then transfered
*Paramemeters: No parameters
**********************************************************
USERINPUT:

welcomeExplanation
    LEA     STARTMESSAGE,A1         
    MOVE.B  #14,D0
    TRAP    #15
    
    ADD.B   #8,(LineCounter)

firstInput
    LEA     INPUT1MESSAGE,A1        
    MOVE.B  #14,D0                  
    TRAP    #15                     Asks user for first input
    ADD.B   #1,(LineCounter)        Adds 1 to line counter
    
    LEA     userInputStored,A1
    MOVE.B  #2,D0                   
    TRAP    #15                     User can input string for address
    ADD.B   #1,(LineCounter)        Adds 1 to line counter

    
    BSR     CONVERTATOH                 String converted to hex address
    
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
    ADD.B   #3,(LineCounter)        Adds 2 to line counter
    
    MOVE.B  #1,(InputQuality)       Resets quality flag to default (good)
    CLR.L   D5                      Clears D5 for future use
    
    
    
    BRA     firstInput              Tries again for input1

    
secondInput
    LEA     INPUT2MESSAGE,A1        
    MOVE.B  #14,D0                  
    TRAP    #15                     Asks user for second input
    ADD.B   #1,(LineCounter)
    
    LEA     userInputStored,A1
    MOVE.B  #2,D0                   
    TRAP    #15                     User can input string for address
    ADD.B   #1,(LineCounter)

    
    BSR     CONVERTATOH                 String converted to hex address

    CMP.B   #0,(InputQuality)       
    BEQ     throwInput2CharError    Checks if bad input flag set
    
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
    
    ADD.B  #3,(InputQuality)        Resets quality flag to default (good)
    CLR.L   D5                      Clears D5 for future use
    
    ADD.B   #3,(LineCounter)
    
    BRA     secondInput             Tries again for input2
    
throwInput2LowerError
    LEA     INPUTERROR2SMALLER,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    ADD.B   #3,(LineCounter)
    
    BRA     secondInput


**********************************************************
*Subroutine: CONVERTATOH
*What it does: Converts user input to hex code
*Registers: Uses register A1, D2, D5
*Paramemeters: User input stored in (A1)
********************************************************** 
CONVERTATOH:
    
AtoH
    MOVE.B  (A1)+,D2                Takes first bit (letter), moves to D2 for testing
    
    CMP.B   #$00,D2                 Compares to 00, since 00 is null (enter)
    BEQ     Finish                  Moves to finish if they are equal (no more input)
    
    ASL.L   #4,D5
    
    CMP.B   #$30,D2
    BLT     inputError
    
    CMP.B   #$39,D2                 Compares to 39, because 39 in ASCII is 9, which is largest number
    BGT     upperCase               Branches if greater, may or may not be a letter in hex
    
    SUBI.B  #$30,D2                 Subtracts 30 to turn it into it's hex format
    ADD.B   D2,D5
    
    BRA     AtoH

        
upperCase   
    CMP.B   #$41,D2
    BLT     InputError              Greater than 39 and less than 41 is not part of hex code
    
    CMP.B   #$46,D2                 
    BGT     lowerCase               Greater than 46 may be hex code in lowercase
    
    SUBI.B  #$37,D2                 Subtracts 37 to turn it into hex format
    ADD.B   D2,D5
    BRA     AtoH

lowerCase
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



   
*********************************************************************
*Subroutine: OUTPUT
*What it does: Outputs parts of opword, moves to new screen if needed
*Registers: Uses register A1, 
*A1: Used to store messages and single char
*Paramemeters: A1
*A1: Stores what should be used
*********************************************************************  

     OUTPUT:
     
     CMP.B  #1,(OutputType)
     BEQ    outputOpcode
     CMP.B  #2,(OutputType)
     BEQ    OutputSize
     CMP.B  #3,(OutputType)
     BEQ    OutputData
     CMP.B  #4,(OutputType)
     BEQ    OutputAddress
     
outputOpcode    
     CMP.B  #30, (LineCounter)      Console holds 32 lines total, 30 used for dissassembly data
     BGE    outputOpcodeNewScreen
     
     MOVE.B #14,D0
     TRAP   #15
     
     ADD.B  #1,(LineCounter)
     
     RTS
     
     
outputOpcodeNewScreen
     MOVE.L A1,-(SP)                Storing last message to be used later
     
     LEA    OUTPUTNEWSCREEN,A1         
     MOVE.B #14,D0
     TRAP   #15
     
     LEA    userInputStored,A1         Pauses program to show screen full of data
     MOVE.B #2,D0
     TRAP   #15
     
     MOVE.B #0,(LineCounter)        Sets LineCounter to 0 to reset screen
     
     MOVE.L (SP)+,A1                Retriving message to be used
     
     MOVE.B #14,D0                  Outputting decoded message
     TRAP   #15
     
     ADD.B  #1,(LineCounter)        Add to line counter for new screen
     
     RTS
     
outputSize
    MOVE.B  #14,D0
    TRAP    #15
    RTS
outputData
    MOVE.L A1,-(SP)
    LEA    SPACES,A1
    MOVE.B  #14,D0
    TRAP    #15

    MOVE.L  (SP)+,A1
    MOVE.B  #14,D0
    TRAP    #15     
    
outputAddress
    MOVE.L  #$800,A3
    MOVE.L  A2,(A3)
    MOVE.L  D6,-(SP)
    MOVE.B  #0,D0
    LEA     addressOutput,A1
outputAddressLoop
    *check if loop has run 4 times
    CMP.B   #4,D0
    BEQ     outputAddressLoopEnd
    *Grab byte from address, dont increment
    MOVE.B  (A3),D6
    *LSR to isolate left bit
    LSR.B   #4,D6
    *Call converthtoa
    BSR     CONVERTHTOA
    MOVE.B  D6,(A1)+   
    *Grab bye from address, increment
    MOVE.B  (A3)+,D6
    *AND Mask second digit
    AND.B   #$0F,D6
    BSR     CONVERTHTOA
    MOVE.B  D6,(A1)+
    ADD.B   #1,D0
    BRA     outputAddressLoop
    
    
outputAddressLoopEnd
    MOVE.B  #$00,(A1)
    MOVE.L  (SP)+,D6
    LEA     addressOutput,A1
    MOVE.B  #14,D0
    TRAP    #15
    RTS

    CONVERTHTOA:
    
    CMP.B   #9,D6
    BLE     zerotonine
    BRA     AtoF
    
zerotonine    
    ADD.L   #$30,D6
    RTS
AtoF
    ADD.L   #$37,D6
    RTS
    
END_SIMULATION:
        
    MOVE.B  #9,D0
    TRAP    #15

    SIMHALT             ; halt simulator

* Put variables and constants here
STARTMESSAGE    DC.B    'Welcome to the CSS 422 dissasembler!',CR,LF
                DC.B    'Some quick rules:',CR,LF
                DC.B    '1) Only the last 6 characters will be saved as the address',CR,LF
                DC.B    '2) The input only accepts hexadecimal input, both in upper and lower case',CR,LF
                DC.B    '3) Any part of the input that is not within the hexadecimal range ',CR,LF
                DC.B    '   will be rejected',CR,LF
                DC.B    '4) The first input must be smaller than the second, otherwise it ',CR,LF
                DC.B    '   will be rejected',CR,LF,0      
INPUT1MESSAGE   DC.B    'Please input the lower address edge',CR,LF,0
INPUT2MESSAGE   DC.B    'Please input the upper address edge',CR,LF,0

INPUTERRORBADCHAR   DC.B    CR,LF,'This value is not valid',CR,LF,CR,LF,0
INPUTERROR2SMALLER  DC.B    CR,LF,'Input 2 is smaller than input 1. Input a larger value',CR,LF,CR,LF,0

INPUTREPEAT     DC.B    'To repeat the program, press enter. Otherwise, press any button to quit',CR,LF,0

OUTPUTNEWSCREEN     DC.B    'Please press enter for more code',CR,LF,0

NEWLINE     DC.B    CR,LF,0
SPACES      DC.B    '  ',0

InputQuality    DC.B    1       Set to 1 for default good
LineCounter     DC.B    0      Counts the number of lines used per screen (max of 31)
OutputType      DC.B    0      To track what type is being output

nopout  DC.B    'NOP',CR,LF,0
moveout  DC.B    'MOVE',0
moveaout DC.B      'MOVEA',0
moveqout DC.B   'MOVEQ',CR,LF,0 * CR and LF is temp on this

rtsout DC.B     'RTS',CR,LF,0
braout DC.B     'BRA',CR,LF,0


byteout  DC.B    '.B',CR,LF,0
wordout  DC.B    '.W',CR,LF,0
longout  DC.B    '.L',CR,LF,0

empty    DC.B    '',CR,LF,0

CR  EQU $0D
LF  EQU $0A


    END    START        ; last line of source











*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
