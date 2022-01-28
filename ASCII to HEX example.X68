*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program


        MOVE.B  #5,D0            Primed to ask for a single character
        TRAP    #15              Allows user to input 1 character
        MOVE.B  D1,D2            Move character to D2 to be compared
        BRA     AtoH             Goes to conversion
        

* Put program code here
AtoH               
        CMP.B   #$30,D2          If D2 smaller than $30, not an HEX character based on table
        BLT.B   ERROR            Throws error if smaller
        CMP.B   #$39,D2          If D2 smaller than $39, may be A-F
        BGT.B   A                Tries to see if it's A-F
        SUBI.B  #$30,D2          Subtracts to turn ASCII hex code to HEX value hex code
        LEA     GOODMESSAGE,A1   Throws message that all good
        MOVE.B  #14,D0
        TRAP    #15

        BRA     END              End program
        
ERROR   MOVE.B  #14,D0              Primes for error message
        LEA     ERRORMESSAGE,A1     Primes for error message
        TRAP    #15                 Throws error message
        BRA     END
        
        
A       CMPI.B  #$41,D2             Does the same thing for AtoH, but only checks for A-F
        BLT.B   ERROR
        CMPI.B  #$46,D2
        BGT.B   ERROR
        SUBI.B  #$37,D2
        LEA     GOODMESSAGE,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     END
        
END
    MOVE.B  #9,D0
    TRAP    #15

    

* Put variables and constants here
ERRORMESSAGE DC.B    CR,LF,'This ASCII character is not a hex character',CR,LF,0
GOODMESSAGE  DC.B    CR,LF,'This ASCII character is a hex character',CR,LF,0

CR  EQU $0D
LF  EQU $0A


    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
