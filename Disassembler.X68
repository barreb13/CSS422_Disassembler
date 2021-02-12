*-----------------------------------------------------------
* Title      : Disassembler
* Written by : Brent and Parker
* Date       : 2/5/2021
* Description: Final Project for CSS 422
*-----------------------------------------------------------

;************************Define Constants**************************** 
CR  EQU     $0D     ;carriage return
LF  EQU     $0a     ;line feed
;buffer size = 64 bytes?






    ORG    $1000
START:                  ; first instruction of program

;************************Welcome Message**************************** 
    LEA     welcome_message,A1  ;load the welcome message into A1
    MOVE.B  #14,D0
    TRAP    #15


 
    
    
;************************Get Starting Address**************************** 






    
    
;************************Get Ending Address**************************** 









;************************Main Loop????**************************** 





   
    

    SIMHALT             ; halt simulator

;jump table


welcome_message     DC.B    'Welcome to 68k disassembler',CR,LF,0

    END    START        ; last line of source









*~Font name~Courier New~
*~Font size~18~
*~Tab type~1~
*~Tab size~4~
