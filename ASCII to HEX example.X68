*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program


        MOVE.B  #5,D0
        TRAP    #15
        MOVE.B  D1,D2
        BRA     AtoH
        

* Put program code here
AtoH    MOVE.B  #0,D3
        CMP.B   #$30,D2
        BLT.B   ERROR
        CMP.B   #$39,D2
        BGT.B   A
        SUBI.B  #$30,D2
        LEA     GOODMESSAGE,A1
        MOVE.B  #14,D0
        TRAP    #15

        BRA     END
        
ERROR   MOVE.B  #14,D0
        LEA     ERRORMESSAGE,A1
        TRAP    #15
        MOVE.B  #1,D3
        BRA     END
        
        
A       CMPI.B  #$41,D2
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
