addressOutput EQU   $9005
input1      EQU     $8000           where input 1 is stored (can be changed if needed)
input2      EQU     $8004          where input 2 is stored (can be changed if needed)
userInputStored    EQU     $8008   





    ORG    $1000
START:                           *Main

    MOVE.B  #0,(LineCounter)
userInputStart
    BSR     USERINPUT
    
*testing purposes----------------------------------------------------
    MOVE.B #$04, D6
    MOVE.W #$1004, A2
    MOVEQ #10, D6
    MOVEA.L A2, A3
    CMP D1,D3
    SUB.L D2, D6

    BRA here
here
    JSR there
    NOT.L (A3)
    LEA (A1),A3
    OR.L input1, D5
    MOVEM.L D0-D7/A0-A6,-(SP) 
    AND.B D1,D6
    ADD.B D3,D4
* calls-------------------------------------------------------
    MOVE.W #$100C, A2
    BSR     OPCODE * test MOVE.B

    MOVE.W #$1010, A2
    BSR     OPCODE * test MOVEA.W
    
    MOVE.W #$1014, A2
    BSR     OPCODE * test MOVEQ
   
    MOVE.W #$1016, A2
    BSR     OPCODE *test MOVEA.L
    
    MOVE.W #$1018, A2
    BSR     OPCODE *test DATA
    
    
    MOVE.W #$101A, A2
    BSR     OPCODE *test SUB.L
    
    MOVE.W #$101C, A2
    BSR     OPCODE *test BRA
    
    MOVE.W #$1020, A2
    BSR     OPCODE *test JSR
    
    MOVE.W #$1026, A2
    BSR     OPCODE *test NOT
    
    MOVE.W #$1028, A2
    BSR     OPCODE *test LEA
    
    MOVE.W #$102A, A2
    BSR     OPCODE *test OR
    
    MOVE.W #$1030, A2
    BSR     OPCODE *test OR

    MOVE.W #$1034, A2
    BSR     OPCODE *test AND
    
    MOVE.W #$1036, A2
    BSR     OPCODE *test ADD


    MOVE.W #$10B4, A2
    BSR     OPCODE *test RTS


* calls---------------------------------------------------------    
    BRA userInputRepeat
there    
    RTS
* end testing--------------------------------------------------------------
 

     
  

    
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
*D2: used for determing the size
*Paramemeters: A2 the memory address to decode from
**********************************************************
OPCODE:
    CLR D3
    
    CMP #$4E75, (A2) * RTS compare, this has to be done before JSR, LEA, and NOT
    BEQ rts
    
    CMP #$4E71, (A2) *NOP compare
    BEQ nop
    
    Move.W (A2), D3 
    LSR #8,D3 * make D3 only contain the first 4 bits of the instruction as its LSig word
    LSR #4,D3
    
    
    CMP #%1000, D3 * OR compare
    BEQ or
    
    
    CMP #%0011, D3 *MOVE and MOVEA compare
    BLE move
    
    CMP #%0111, D3 *MOVEQ compare
    BEQ moveq
    
    CMP #%1001, D3 *SUB compare
    BEQ sub
    
    CMP #%1100, D3 *AND compare
    BEQ and
    
    CMP #%1101, D3 *ADD compare
    BEQ add

    
    
    Move.W (A2), D3 * reset D3
    ANDI.W #%1111101110000000,D3  * the bits relevant to MOVEM
    CMP #%100100010000000,D3 *MOVEM compare
    BEQ movem

    
    
    Move.W (A2), D3 * reset D3
    LSR #6,D3 * make D3 only contain the first 10 bits of the instruction
    CMP #%0000000100111010, D3 * JSR compare, this has to be done before NOT and LEA
    BEQ jsr

    Move.W (A2), D3 * reset D3
    LSR #8,D3 * make D3 only contain the first 8 bits
    CMP #%01000110,D3 * NOT compare, this has to be done before LEA
    BEQ not
    
    Move.W (A2), D3 * reset D3
    ANDI.W #%1111000111000000,D3 * the bits relevant to LEA
    CMP #%0100000111000000,D3 *LEA compare
    BEQ lea

   
    Move.W (A2), D3 * reset D3
    LSR #8,D3 * make D3 only contain the first 8 bits of the instruction
 
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
    BSR byte *otherwise branch to byte
  
    BSR MOVE_MOVEA_EA
    
    BRA return
    
    
movea
    LEA    moveaout,A1
    MOVE.B  #1,(OutputType)       
    BSR    OUTPUT
    
    *now to print size  
    cmp #2,D2 *if the size is 2 branch to long
    BEQ long
    cmp #3,D2 *if the size is 3 branch to word
    BSR word
    
    BSR MOVE_MOVEA_EA
    
    BRA return
    
moveq
    LEA    moveqout,A1
    MOVE.B  #1,(OutputType)       
    BSR    OUTPUT
    BRA return

    
movem    
    LEA    movemout,A1
    MOVE.B  #1,(OutputType)       
    BSR    OUTPUT
    
    MOVE.W (A2),D2
    ANDI.W #%0000000001000000, D2 * set to only the size bits
    LSR #6,D2 * make the size bits the first two bits in D2 LSig word
    CMP #1, D2 * if the size is 1 branch to long
    BEQ long
    BSR word * otherwise branch to word

    
    BRA return
sub    
    LEA    subout,A1
    MOVE.B  #1,(OutputType)       
    BSR    OUTPUT
    
    MOVE.W (A2),D2
    ANDI.W #%0000000011000000, D2 * set to only the size bits
    LSR #6,D2 * make the size bits the first two bits in D2 LSig word


    
    *now to print size  
    cmp #2,D2 *if the size is 2 branch to long
    BEQ long
    cmp #1,D2 *if the size is 1 branch to word
    BEQ word
    BSR byte *otherwise branch to byte
    
    BRA return
add
    LEA    addout,A1
    MOVE.B  #1,(OutputType)       
    BSR    OUTPUT
    
    MOVE.W (A2),D2
    ANDI.W #%0000000011000000, D2 * set to only the size bits
    LSR #6,D2 * make the size bits the first two bits in D2 LSig word


    
    *now to print size  
    cmp #2,D2 *if the size is 2 branch to long
    BEQ long
    cmp #1,D2 *if the size is 1 branch to word
    BEQ word
    BSR byte *otherwise branch to byte
    
    BRA return

    
rts
    LEA    rtsout,A1
    MOVE.B  #1,(OutputType)       
    BSR    OUTPUT
    BRA return
    
    
jsr    
    LEA    jsrout,A1
    MOVE.B  #1,(OutputType)       
    BSR    OUTPUT
    BRA return
    
    
not   
    LEA    notout,A1
    MOVE.B  #1,(OutputType)       
    BSR    OUTPUT
    
    MOVE.W (A2),D2
    ANDI.W #%0000000011000000, D2 * set to only the size bits
    LSR #6,D2 * make the size bits the first two bits in D2 LSig word

    *now to print size  
    cmp #2,D2 *if the size is 2 branch to long
    BEQ long
    cmp #1,D2 *if the size is 1 branch to word
    BEQ word
    BSR byte *otherwise branch to byte
    

    
    BRA return

lea
    LEA    leaout,A1
    MOVE.B  #1,(OutputType)       
    BSR    OUTPUT
    BRA return
    
or
    LEA    orout,A1
    MOVE.B  #1,(OutputType)       
    BSR    OUTPUT
    
        
    MOVE.W (A2),D2
    ANDI.W #%0000000011000000, D2 * set to only the size bits
    LSR #6,D2 * make the size bits the first two bits in D2 LSig word

    *now to print size  
    cmp #2,D2 *if the size is 2 branch to long
    BEQ long
    cmp #1,D2 *if the size is 1 branch to word
    BEQ word
    BSR byte *otherwise branch to byte
    
    BRA return
    
and
    LEA    andout,A1
    MOVE.B  #1,(OutputType)       
    BSR    OUTPUT
    
        
    MOVE.W (A2),D2
    ANDI.W #%0000000011000000, D2 * set to only the size bits
    LSR #6,D2 * make the size bits the first two bits in D2 LSig word

    *now to print size  
    cmp #2,D2 *if the size is 2 branch to long
    BEQ long
    cmp #1,D2 *if the size is 1 branch to word
    BEQ word
    BSR byte *otherwise branch to byte
    
    BRA return    


bra
    LEA    braout,A1
    MOVE.B  #1,(OutputType)       
    BSR    OUTPUT
    BRA return

data
    LEA    dataout,A1
    MOVE.B  #1,(OutputType)       
    BSR    OUTPUT
    
    MOVE.B  #3,(OutputType)       
    BSR    OUTPUT *TODO fix data output type

    BRA return


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
*Subroutine: EA
*What it does: Outputs parts of opword, moves to new screen if needed
*Registers: Uses register A1, D0,
*A1: Used to store messages and single char
*Paramemeters: A1
*A1: Stores what should be used
*********************************************************************  
BITS0TO5_MASK   EQU %00111111
BITS7TO8_MASK   EQU %11000000
BITS9TO11_MASK  EQU %00000111000000000

FORMAT_IMMEDIATE_DATA   MOVE.B  #10,D7
                        CMP     #0,D6
                        BEQ     IMMEDIATE0
                        BRA     IMMEDIATE_END
IMMEDIATE0              MOVEQ   #8,D6

IMMEDIATE_END           RTS

MOVE_MOVEA_EA   MOVE.W  (A2),D1
                ANDI.B  #BITS0TO5_MASK,D1           * Isolate the source EA bits
                ORI.B   #BITS7TO8_MASK,D1           * Populate the S and D bits
                MOVE.B  D1,D6                   * Pass source EA to print subroutine
                MOVE.W  (A2),D1         
                MOVE.W  (A2),D2 
                ANDI.W  #BITS9TO11_MASK,D1   * Isolate the destination register number
                MOVE.B  #9,D3                   * Prepare shift count
                LSR.W   D3,D1                   * Move destination register bits right
                ANDI.W  #%0000000111000000,D2   * Isolate the destination mode
                LSR.W   #3,D2                  * Move destination mode bits right
                OR.W    D2,D1
                MOVE.B  D1,D5                   * Pass destination EA to print subroutine
                MOVE.B  D6,D1               * Pass source into subroutine
                JSR     CHECK_VALID_EA
                MOVE.B  D5,D1               * Pass destination into subroutine
                JSR     CHECK_VALID_EA
                BSR print_EA
                BSR print_NEWLINE
                
                RTS
*should be for the following opcodes- MOVEA, ADD, SUB, AND, OR 
EA_GROUP1     MOVE.W  (A2),D1                 * Prepare to capture register field
        MOVE.W  (A2),D2                 * Prepare to capture EA field
        ANDI.B  #BITS0TO5_MASK,D1       * Isolate the source EA bits
        
        ANDI.W  #BITS9TO11_MASK,D2      * Isolate the source EA bits
        MOVE.B  #9,D3                   * Prepare shift count
        LSR.W   D3,D2                   * Move register bits right
        ANDI.B  #%11000111,D2           * Set EA mode
        MOVE.W  (A2),D3
        BTST    #8,D3                   * Check opmode
        BEQ     EA1_MODE_ZERO           * Check opmode
        
EA1_MODE_ONE    MOVE.W  D1,D5           * Set EA as destination
                MOVE.W  D2,D6           * Set register as source
                BRA EA1_END             * Complete subroutine
        
EA1_MODE_ZERO   MOVE.W  D1,D6           * Set EA as source
                MOVE.W  D2,D5           * Set register as destination

EA1_END         ORI.B   #BITS7TO8_MASK,D6       * Populate the S and D bits
                MOVE.B  D6,D1               * Pass source into subroutine
                JSR     CHECK_VALID_EA
                MOVE.B  D5,D1               * Pass destination into subroutine
                JSR     CHECK_VALID_EA
                BSR print_EA
                BSR print_NEWLINE

                RTS
*should be for opcode LSL LSR ASL ASR ROL ROR but for register shifts
EA_GROUP2             MOVE.W  (A2),D6         * Prepare to capture source EA
                ANDI.W  #BITS9TO11_MASK,D6      * Isolate the source EA bits
                MOVE.B  #9,D3                   * Prepare shift count
                LSR.W   D3,D6                   * Move register bits right
                MOVE.W  (A2),D3
                BTST    #5,D3           * Check whether shift count is immediate
                BEQ     EA2_IMMEDIATE
 
EA2_REGISTER    ORI.B   #%11000000,D6   * Set S and D bits
                BRA     EA2_END         * Complete subroutine
                
EA2_IMMEDIATE   MOVE.B  #10,D7          * Prepare to pass immediate data to print subroutine
                JSR     FORMAT_IMMEDIATE_DATA
                
EA2_END         MOVE.W  (A2),D5         * Prepare to capture destination EA
                AND.B   #%00000111,D5
                MOVE.B  D6,D1               * Pass source into subroutine
                JSR     CHECK_VALID_EA
                MOVE.B  D5,D1               * Pass destination into subroutine
                JSR     CHECK_VALID_EA
                BSR print_EA
                BSR print_NEWLINE
                RTS   


*should be for opcode LSL LSR ASL ASR ROL ROR but for register shifts
EA_GROUP3     MOVE.W  (A2),D6
        ANDI.B  #BITS0TO5_MASK,D6       * Isolate the source EA bits
        ORI.B   #%10000000,D6
        MOVE.B  D6,D1               * Pass source into subroutine
        JSR     CHECK_VALID_EA
        BSR print_EA
        BSR print_NEWLINE
        RTS

*should be for LEA and ADDA(SHOULD WORK BETTER THEN EA GROUP 1)
EA_GROUP4     MOVE.W  (A2),D1         
        ANDI.B  #BITS0TO5_MASK,D1       * Isolate the source EA bits
        ORI.B   #BITS7TO8_MASK,D1       * Populate the S and D bits
        MOVE.B  D1,D6                   * Pass source EA to print subroutine
        MOVE.W  (A2),D1         
        
        ANDI.W  #BITS9TO11_MASK,D1   * Isolate the destination register number
        MOVE.B  #9,D2                   * Prepare shift count
        LSR.W   D2,D1                   * Move register bits right
        ANDI.B  #%11001111,D1           * Set destination mode
        ORI.B   #%00001000,D1           * Set destination mode
        MOVE.B  D1,D5                   * Pass destination EA to print subroutine
        MOVE.B  D6,D1               * Pass source into subroutine
        JSR     CHECK_VALID_EA
        MOVE.B  D5,D1               * Pass destination into subroutine
        JSR     CHECK_VALID_EA
        BSR print_EA
        BSR print_NEWLINE
        RTS
        
ADDQ_EA MOVE.W  (A2),D6                 * Prepare source data bits
        ANDI.W  #BITS9TO11_MASK,D6      * Isolate source data bits
        MOVE.B  #9,D3                   * Prepare shift count
        LSR.W   D3,D6                  * Move source data bits right            !---
        MOVE.W  (A2),D5                 * Prepare destination bits
        ANDI.B  #BITS0TO5_MASK,D5       * Isolate destination bits
        JSR     FORMAT_IMMEDIATE_DATA
        MOVE.B  D6,D1               * Pass source into subroutine
        JSR     CHECK_VALID_EA
        MOVE.B  D5,D1               * Pass destination into subroutine
        JSR     CHECK_VALID_EA
        RTS                                    !---
        
MOVEQ_EA    MOVE.W  (A2),D6                 * Prepare source data bits          !---
            AND.W   #$00FF,D6                                                   !---
            MOVE.W  (A2),D5                 * Prepare destination regiter bits
            ANDI.W  #BITS9TO11_MASK,D5      * Isolate destination register bits
            MOVE.B  #9,D3                   * Prepare shift count
            LSR.W   D3,D5                   * Move destination register bits right
            MOVE.B  #10,D7
            MOVE.B  D6,D1               * Pass source into subroutine
            JSR     CHECK_VALID_EA
            MOVE.B  D5,D1               * Pass destination into subroutine
            JSR     CHECK_VALID_EA
            RTS                                 !---




MOVEM_EA   MOVE.W (A2),D2
           BTST    #10, D2
           BEQ     Register_to_memory *IF THE DIRCTION BIT IS 0, 
          
           
                
*ELSE IT IS  memory-to-register transfers




   
Memory_to_Register LSR.L #3, D2
                   AND.B #$07, D2
                   CMP.B #$2,D2
                   BEQ   MODE_010
                   CMP.B #$03, D2
                   BEQ   MODE_010  
                   CMP.B #$07,D2
                   BEQ   MODE_010  
                   JMP   WRONG_INSTRUCTION    
   
WRONG_INSTRUCTION            MOVE.B   #5, D7 ; A WRONG INSTRUCTION 'KEY'
                             MOVEA.L  A2, A6 ;MOVING THE MEMORY ADDRESS INTO A6 WHEN INSTRUCTION IS WRONG 
                             MOVE.W  (A2),D6 ;MOVE MEMORY ADDRESS INTO D6, AND INCREMENT A2 BY WORD
                             RTS 
           
MODE_010  MOVE.W    (A2),D2
          AND.B     #$3F,D2
          BSET      #7,D2 *SET THE DESTINATION INDICATOR
          MOVE.B    D2,D6
          RTS

Register_to_memory MOVE.W (A2),D2
                   LSR.L #3, D2
                   AND.B #$07, D2
                   CMP.B #$2,D2
                   BEQ   MODE_01_0
                   CMP.B #$04, D2
                   BEQ   MODE_01_0 
                   CMP.B #$07,D2
                   BEQ   MODE_01_0 
                   JMP   WRONG_INSTRUCTION
                   

MODE_01_0       MOVE.W  (A2),D6
                ANDI.B  #$3F,D6
                RTS
         
CHECK_VALID_EA  MOVE.B  D1,D0
                ANDI.B  #%111000,D0
                LSR     #3,D0
                CMP.B   #%00000101,D0
                BEQ     INVALID_EA
                CMP.B   #%00000110,D0
                BEQ     INVALID_EA
                CMP.B   #%00000111,D0
                BEQ     VALID_EA_PC
                RTS
                
                
VALID_EA_PC     MOVE.B  D1,D0
                ANDI.B  #%000111,D0
                CMP.B   #%00010000,D0
                BEQ     INVALID_EA
                CMP.B   #%00011000,D0
                BEQ     INVALID_EA
                RTS
                
INVALID_EA      JSR     WRONG_INSTRUCTION
                MOVE.W  #5, A5
                RTS
                
PRINT_EA        MOVEM.L A0-A1/A3-A6/D0-D7,-(SP)
                MOVE.B  #$38,D3
                AND.B   D4,D3
                AND.B   #$7, D4
                
                CMP.B   #$0, D3
                BNE     CHECK_EA_AR
                ADD.B   #$D0, D4
                CLR.L   D1
                MOVE.B  D4, D1
                JSR     PRINT_REGISTOR              * DATA REG
                BRA     PRINT_EA_RETURN

CHECK_EA_AR         CMP.B   #$8, D3
                    BNE     CHECK_EA_INDIRECT
                    ADD.B   #$A0, D4
                    CLR.L   D1
                    MOVE.B  D4, D1
                    JSR     PRINT_REGISTOR          * ADDRESS REG
                    BRA     PRINT_EA_RETURN
                    
CHECK_EA_INDIRECT       CMP.B   #$10, D3
                        BNE     CHECK_EA_POST
                        JSR     PRINT_OPEN_PARENTHESIS      * (
                        ADD.B   #$A0, D4
                        CLR.L   D1
                        MOVE.B  D4, D1
                        JSR     PRINT_REGISTOR              * ADDRESS REG
                        JSR     PRINT_CLOSED_PARENTHESIS    * )
                        BRA     PRINT_EA_RETURN
                        
CHECK_EA_POST   CMP.B   #$18,D3
                BNE     CHECK_EA_PRE
                JSR     PRINT_OPEN_PARENTHESIS      * (
                ADD.B   #$A0, D4
                CLR.L   D1
                MOVE.B  D4, D1
                JSR     PRINT_REGISTOR              * ADDRESS REG
                JSR     PRINT_CLOSED_PARENTHESIS    * )
                JSR     PRINT_PLUS                  * +
                BRA     PRINT_EA_RETURN

CHECK_EA_PRE        CMP.B   #$20,D3
                    BNE     CHECK_EA_AB_W
                    JSR     PRINT_MINUS                 * -
                    JSR     PRINT_OPEN_PARENTHESIS      * (
                    ADD.B   #$A0, D4
                    CLR.L   D1
                    MOVE.B  D4, D1
                    JSR     PRINT_REGISTOR              * ADDRESS REG
                    JSR     PRINT_CLOSED_PARENTHESIS    * )
                    BRA     PRINT_EA_RETURN

CHECK_EA_AB_W           ADD.B   D4,D3
                        CMP.B   #$38,D3     
                        BNE     CHECK_EA_AB_L
                        JSR     PRINT_DOLLAR        * $
                        MOVE.W  (A2)+,D5            * PRINTING WORD ABSOLUTE
                        MOVE.B  #2,D3
                        JSR     PRINT_HEX
                        BRA     PRINT_EA_RETURN
                        
CHECK_EA_AB_L       CMP.B   #$39, D3
                    BNE     CHECK_EA_IMM
                    JSR     PRINT_DOLLAR        * $
                    MOVE.L  (A2)+,D5            * PRINTING LONG ABSOLUTE
                    MOVE.B  #4,D3
                    JSR     PRINT_HEX
                    BRA     PRINT_EA_RETURN
                    
CHECK_EA_IMM        CMP.B   #4,D7
                    BNE     READ_WORD_IMM
                    JSR     PRINT_HASH_SIGN     * #
                    JSR     PRINT_DOLLAR        * $
                    MOVE.L  (A2)+,D5            * PRINTING LONG IMMIDIATE
                    MOVE.B  #4,D3
                    JSR     PRINT_HEX
                    BRA     PRINT_EA_RETURN
                    
READ_WORD_IMM       JSR     PRINT_HASH_SIGN     * #
                    JSR     PRINT_DOLLAR        * $
                    MOVE.W  (A2)+,D5            * PRINTING WORD/BYTE IMMIDIATE        
                    MOVE.B  #2,D3
                    JSR     PRINT_HEX

PRINT_EA_RETURN     MOVEM.L     (SP)+,A0-A1/A3-A6/D0-D7   * THE RETURN FOR THE EA PRINTER
                    RTS
ALL_REG     REG     D0-D7/A0-A6         ; all registers
PRINT_BUFFER    DS.B    10
IPUT_BUFFER_EX  DC.B    '00000000'
INPUT_BUFFER    DS.B    15                    
PRINT_HEX       MOVEM.L     ALL_REG,-(SP)
                LEA         PRINT_BUFFER, A1        *SETTING UP PRINT BUFFER
                ADD.L       #10,A1
                MOVE.B      #0,-(A1)                *NULL FOR PRINTER TO STOP
                BRA         POPULATE_BUFFER
                
PRINT_HEX_RETURN    MOVE.B      #14,D0
                    TRAP        #15
                    MOVEM.L     (SP)+,ALL_REG
                    RTS
               
POPULATE_BUFFER     CMP.B       #0,D3
                    BEQ         PRINT_HEX_RETURN
                    MOVE.B      #$0F,D4
                    AND.B       D5,D4
                    ROR.B       #4,D5
                    JSR         HEX_TO_ASCII
                    MOVE.B      D4,-(A1)
                    MOVE.B      D5,D4
                    AND.B       #$0F,D4
                    JSR         HEX_TO_ASCII
                    MOVE.B      D4,-(A1)
                    LSR.L       #8,D5
                    SUB.B       #1,D3
                    BRA         POPULATE_BUFFER

HEX_TO_ASCII            MOVEM.L     A0-A6/D0-D2/D5-D7,-(SP)
                        CMP.B       #9,D4
                        BLE         NUMBER_TO_ASCII
                        ADD.B       #$37,D4
HEX_TO_ASCII_RETURN     MOVEM.L   (SP)+,A0-A6/D0-D2/D5-D7
                        RTS
                
NUMBER_TO_ASCII     ADD.B   #$30,D4
                    BRA     HEX_TO_ASCII_RETURN                    
                    
PRINT_REGISTOR      MOVEM.L     ALL_REG,-(SP)       * keeping old value
                    MOVE.W      #00,-(SP)           *for printing purpose
                    MOVE.W      #$f0,D2             *manipulating each digit
                    AND.W       D1,D2
                    ASR.W       #4,D2
                    JSR         TO_STRING           * converts to the string ASCII val
                    ASL.W       #8,D2
                    
                    AND.W       #$F,D1              * the last digit
                    MOVE.B      D1,D2               
                    JSR         TO_STRING
                    MOVE.W      D2,-(SP)            * puting on the stack to print
                    
                    MOVE.L      SP,A1               * printing
                    MOVE.B      #14,D0
                    TRAP        #15
                    MOVE.L      (SP)+, D5           * Adjesting the sp

PRINT_REGISTOR_RETURN           MOVEM.L     (SP)+,ALL_REG   *returning the original val
                                RTS
                                
TO_STRING   CMP.B   #9,D2               * check if digit or leter
            BGT     LETTERS     
            ADD.B   #$30,D2             * offseting digit
            RTS
LETTERS     ADD.B   #$37,D2             * offseting leter
            RTS   

*________________________________________________________________________________________


*________________ PRINT OPEN PARENTHESIS ________________________________________
        *PARAMENTER     NO PARAMETER NEEDED
OPEN_PAR_TAG        DC.B    '(',0  
CLOSED_PAR_TAG      DC.B    ')',0
HASH_SIGN_TAG       DC.B    '#',0
DOLLAR_TAG          DC.B    '$',0
FORWARD_SLASH_TAG   DC.B    '/',0      
PRINT_OPEN_PARENTHESIS  MOVEM.L     ALL_REG, -(SP)
                        LEA         OPEN_PAR_TAG, A1
                        MOVE.B      #14,D0
                        TRAP        #15
                        MOVEM.L     (SP)+,ALL_REG
                        RTS
*_________________________________________________________________________________

*________________ PRINT CLOSED PARENTHESIS ________________________________________
        *PARAMENTER     NO PARAMETER NEEDED
        
PRINT_CLOSED_PARENTHESIS    MOVEM.L     ALL_REG, -(SP)
                            LEA         CLOSED_PAR_TAG, A1
                            MOVE.B      #14,D0
                            TRAP        #15
                            MOVEM.L     (SP)+,ALL_REG
                            RTS
*__________________________________________________________________________________

*________________ PRINT PLUS SIGN _________________________________________________
        *PARAMENTER     NO PARAMETER NEEDED
PLUS_TAG            DC.B    '+',0
MINUS_TAG           DC.B    '-',0        
PRINT_PLUS      MOVEM.L     ALL_REG, -(SP)
                LEA         PLUS_TAG, A1
                MOVE.B      #14,D0
                TRAP        #15
                MOVEM.L     (SP)+,ALL_REG
                RTS
*_________________________________________________________________________________

*________________ PRINT MINUS SIGN _______________________________________________
        *PARAMENTER     NO PARAMETER NEEDED
        
PRINT_MINUS         MOVEM.L     ALL_REG, -(SP)
                    LEA         MINUS_TAG, A1
                    MOVE.B      #14,D0
                    TRAP        #15
                    MOVEM.L     (SP)+,ALL_REG
                    RTS
*_________________________________________________________________________________

*________________ PRINT COMMA ____________________________________________________
        *PARAMENTER     NO PARAMETER NEEDED
TAB_TAG         DC.B    $9,0
SPACE_TAG       DC.B    ' ',0
COMMA_TAG       DC.B    ',',0        
PRINT_COMMA         MOVEM.L     ALL_REG,-(SP)
                    LEA         COMMA_TAG, A1
                    MOVE.B      #14,D0
                    TRAP        #15
                    MOVEM.L     (SP)+,ALL_REG
                    RTS
*_________________________________________________________________________________

*________________ PRINT TAB ______________________________________________________
        *PARAMENTER     NO PARAMETER NEEDED
        
PRINT_TAB       MOVEM.L     ALL_REG,-(SP)
                LEA         TAB_TAG, A1
                MOVE.B      #14,D0
                TRAP        #15
                MOVEM.L     (SP)+,ALL_REG
                RTS
*_________________________________________________________________________________


*_______________    PRINT NEWLINE   ________________________________________________
        *PARAMETER NO PARAMETER NEEDED
NEWLINE_TAG         DC.B    CR,LF,0        
PRINT_NEWLINE       MOVEM.L     ALL_REG,-(SP)
                    LEA         NEWLINE_TAG, A1
                    MOVE.B      #14,D0
                    TRAP        #15
                    MOVEM.L     (SP)+,ALL_REG
                    RTS

*___________________________________________________________________________________


*_______________    PRINT HASH SIGN   ________________________________________________
        *PARAMETER NO PARAMETER NEEDED
        
PRINT_HASH_SIGN     MOVEM.L     ALL_REG,-(SP)
                    LEA         HASH_SIGN_TAG, A1
                    MOVE.B      #14,D0
                    TRAP        #15
                    MOVEM.L     (SP)+,ALL_REG
                    RTS

*___________________________________________________________________________________



*_______________    PRINT DOLLAR   ________________________________________________
        *PARAMETER NO PARAMETER NEEDED
        
PRINT_DOLLAR        MOVEM.L     ALL_REG,-(SP)
                    LEA         DOLLAR_TAG, A1
                    MOVE.B      #14,D0
                    TRAP        #15
                    MOVEM.L     (SP)+,ALL_REG
                    RTS

*___________________________________________________________________________________



*_______________    PRINT FORWARD SLASH   ________________________________________________
        *PARAMETER NO PARAMETER NEEDED
        
PRINT_FORWARD_SLASH     MOVEM.L     ALL_REG,-(SP)
                        LEA         FORWARD_SLASH_TAG, A1
                        MOVE.B      #14,D0
                        TRAP        #15
                        MOVEM.L     (SP)+,ALL_REG
                        RTS


   
*********************************************************************
*Subroutine: OUTPUT
*What it does: Outputs parts of opword, moves to new screen if needed
*Registers: Uses register A1, D0,
*A1: Used to store messages and single char
*Paramemeters: A1, A2
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
    MOVE.L   #$800,A3
    MOVE.W  (A2),(A3)
    MOVE.L  D6,-(SP)
    MOVE.B  #0,D0
    LEA     addressOutput,A1

outputDataLoop
*check if loop has run 4 times
    CMP.B   #2,D0
    BEQ     outputDataLoopEnd
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
    BRA     outputDataLoop
    
outputDataLoopEnd
    MOVE.B  #$00,(A1)
    MOVE.L  (SP)+,D6
    LEA     addressOutput,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    LEA     NEWLINE,A1
    MOVE.B  #14,D0
    TRAP    #15

    RTS
 
    
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
    
    LEA     spaces,A1
    MOVE.B  #14,D0
    TRAP    #15


    RTS

*********************************************************************
*Subroutine: CONVERTHTOA
*What it does: Converts HEX to ASCII
*Registers: Uses register D6,D0
*D6: Stores hex character to be converted
*Paramemeters: D6
*D6: Stores hex characcter to be converted
*********************************************************************
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
moveqout DC.B   'MOVEQ',0
movemout DC.B   'MOVEM',0

subout    DC.B  'SUB',0
addout    DC.B 'ADD',0
addaout    DC.B 'ADD',0
addqout    DC.B 'ADD',0

leaout    DC.B  'LEA',0

notout    DC.B  'NOT',0
orout DC.B     'OR',0
andout DC.B     'AND',0


lslout    DC.B  'LSL',0
lsrout    DC.B  'LSR',0
aslout    DC.B  'ASL',0
asrout    DC.B  'ASR',0

rolout    DC.B  'ROL',0
rorout    DC.B  'ROR',0

jsrout DC.B     'JSR',0
rtsout DC.B     'RTS',CR,LF,0
braout DC.B     'BRA',0

dataout DC.B    'DATA   ',0



byteout  DC.B    '.B    ',0
wordout  DC.B    '.W    ',0
longout  DC.B    '.L    ',0

empty    DC.B    '',CR,LF,0

CR  EQU $0D
LF  EQU $0A


    END    START        ; last line of source
















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
