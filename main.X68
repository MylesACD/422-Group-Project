*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
input1      EQU     $1000           where input 1 is stored (can be changed if needed)
input2      EQU     $2000           where input 2 is stored (can be changed if needed)
    
    
        ORG    $5000
START:                  ; first instruction of program

* Put program code here
    LEA     INPUT1MESSAGE,A1        loads message 1 to be outputed
    MOVE.B  #14,D0                  primes for task 14
    TRAP    #15                     asks user for first input
    
    MOVE.B  #2,D0                   primes for task 2
    TRAP    #15                     user can input string for address
    BSR     CONVERT                 string converted to hex address
    MOVE.L  D5,input1               moves result into input 1 memory location
    CLR     D5                      clears D5 for future use
    
    LEA     INPUT2MESSAGE,A1        loads message 2 to be outputed
    MOVE.B  #14,D0                  primes for task 14
    TRAP    #15                     asks user for second input
    
    MOVE.B  #2,D0                   primes for task 2
    TRAP    #15                     user can input string for address
    BSR     CONVERT                 string converted to hex address
    MOVE.L  D5,input2               moves result into input 2 memory location
    CLR D5                          clears D5 for future use
    
    
    
CONVERT:
    
AtoH
    MOVE.B  (A1)+,D2                Takes first bit (letter), moves to D2 for testing
    CMP.B   #$39,D2                 Compares to 39, because 39 in ASCII is 9, which is largest number
    BGT     A                       Branches if greater, may or may not be a letter in hex
    CMP.B   #$00,D2                 Compares to 00, since 00 is null (enter)
    BEQ     Finish                  Moves to finish if they are equal (no more input)
    SUBI.B  #$30,D2                 Subtracts 30 to turn it into it's hex format
    BRA     Shift                   Moves to shift when completed
        
A   
    SUBI.B  #$37,D2                 Subtracts 37 to turn it into hex format
    BRA Shift                       Moves to shift when completed
    
   
Shift   
    ADD.B   D2,D5                   D5 will store result during conversion
    ASL.L   #4,D5                   Shifts one hex place to prime for next address
    BRA     AtoH                    Loops back to work on next hex
    
Finish
    ASR.L     #4,D5                 Shifts back 1 to finish
    RTS                             Return from CONVERT
    
END_SIMULATION:
        
    MOVE.B  #9,D0
    TRAP    #15


* Put variables and constants here
INPUT1MESSAGE   DC.B    'Please input the first address you want to dissasemble',CR,LF,0
INPUT2MESSAGE   DC.B    'Please input the second address you want to dissasemble',CR,LF,0

CR  EQU $0D
LF  EQU $0A



    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
