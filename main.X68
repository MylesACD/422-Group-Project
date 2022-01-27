*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
    LEA     INPUT1MESSAGE,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  #4,D0
    TRAP    #4
    
    LEA     INPUT2MESSAGE,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  #4,D0
    TRAP    #4

    SIMHALT             ; halt simulator

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
