*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $6000
START:                  ; first instruction of program

* Put program code here

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
    ADDA.W A1,A2
    ADDQ.L #7,D1
    LSL.B #3,D1
    lSR.W #2,D1
    ASL.B #6,D2
    ASR.W #5,D2
    ROL.B #5,D3
    ROR.W #4,D3
    BGT letsgo
    CMP #4,D3 
    BEQ letsgo
    BLE letsgo
    RTS
letsgo

* calls---------------------------------------------------------    
    BRA userInputRepeat
there    
    RTS
* end testing--------------------------------------------------------------
 



    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
