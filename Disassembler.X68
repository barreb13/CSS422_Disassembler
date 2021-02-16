    *-----------------------------------------------------------
* Title      : Disassembler V1.2
* Written by : Brent and Parker
* Date       : 2/5/2021
* Description: Final Project for CSS 422
*-----------------------------------------------------------

;************************ Define Constants ********************************* 
CR                  EQU     $0D     ;carriage return
LF                  EQU     $0a     ;line feed
stack               EQU     $000A0000
lines_per_screen    EQU     30
buffer_size         EQU     64


    ORG    $1000
START:                              ;first instruction of program

;***************************** Welcome Message ********************************** 
    LEA     welcome_message,A1      ;load the welcome message into A1
    MOVE.B  #14,D0
    TRAP    #15                     ;print contents of welcome_message
    


;****************************** Get Starting Address ***************************** 
    MOVE.B  #14,D0    
    LEA     get_start_address,A1    ;load the get_start_address message into A1
    TRAP    #15                     ;print get_start_address
    
    LEA     ascii_start,A1          ;store
    MOVE.B  #2,D0                   ;get user input    
    TRAP    #15                     ;another trap to get input
    JSR     ATOI                    ;address is now in hex format in memory location
    
    MOVE.L  (A1),D3
    



    
    
;*************************** Get Ending Address ******************************* 
    MOVE.B  #14,D0
    LEA     get_end_address,A1      ;load the get_end_address message into A1  
    TRAP    #15                     ;print get_end_address
    
    LEA     ascii_end,A1            ;store 
    MOVE.B  #2,D0                   ;get user input
    TRAP    #15                     ;another trap to get intput
    JSR ATOI




;****************************** Main Loop???? ************************************ 





   
    
DONE:
    SIMHALT                                 ; halt simulator

;jump table

;******************************** ATOI *********************************************
ATOI:
        MOVE.L      D1,D2                   ;loop variable (size) is in D2
        MOVEA.L     A1,A2                   ;pointer to next char
        CLR         D4

ATOI_LOOP  
        CLR         D3                      ;clear d3
        ;CMP.B       #0,D2
        ;BEQ         ATOI_DONE               ;DONE
        SUBI.L      #1,D2                   ;subtract 1 from loop counter
        MOVE.B      (A2)+,D3                 ;move current byte to D3, then increment to next
        CMP.B       #$2F,D3
        BLE         ATOI_ERROR              ;if less than 30, not a number, branch to error
        CMP.B       #$39,D3                 ;check byte to see if number or letter
        BLE         ATOI_NUMBER             ;30<x<39 --> number
        CMP.B       #$40,D3
        BLE         ATOI_ERROR
        CMP.B       #$46,D3
        BLE         ATOI_UPPERCASE_LETTER   ;less than 47, it is uppercase letter
        CMP.B       #$60,D3
        BLE         ATOI_ERROR
        CMP.B       #$66,D3
        BLE         ATOI_LOWERCASE_LETTER
        CMP.B       #$67,D3
        BGE         ATOI_ERROR
        
        ;BNE         ATOI_LOOP                    ;run loop
    

ATOI_NUMBER
;number --> d1 = d1 - $30
    SUBI.B          #$30, D3                    ;subtract 30 if number
    ;MOVE.B          D3,(A2)+                    ;move into A2 and post increment pointer
    JMP             ATOI_FORMAT                 ;testing
    ;JMP            ATOI_LOOP                   ;loop

ATOI_UPPERCASE_LETTER
;letter --> d1 = d1 - $37
    SUBI.B          #$37,D3                     ;subtract 37 if UPPER case letter
    ;MOVE.B          D3,(A2)+                    ;move into A2 and post increment pointer
    JMP             ATOI_FORMAT                 ;testing
    ;JMP            ATOI_LOOP                   ;loop

ATOI_LOWERCASE_LETTER
    SUBI.B          #$57,D3                     ;subtract 57(20 + 37)
    ;MOVE.B          D3,(A2)+                    ;move into A2 and post increment pointer
    JMP             ATOI_FORMAT                 ;testing
    ;JMP            ATOI_LOOP                  ;loop


ATOI_FORMAT
    ADD.B           D3,D4                       ;add the byte to D4 so can add later   
    CMP.B           #0,D2                       
    BEQ             ATOI_DONE                   ;check if done (loop counter D2 is at 0)
    ASL.L           #4,D4                       ;logical shift left to make room
    JMP             ATOI_LOOP                   ;go back to loop

ATOI_ERROR
    ;come back to handle error when out of range
    


;****************************** Validate Addresses **************************************

VALIDATE_BEGINNING:
    

ATOI_DONE 
    MOVE.L         D4,(A1)                      ;at this point, move the new address in D4 to mem location                                
    RTS                                         ;used to RTS after a branch statement

    
;******************** MESSAGES ***************************************
welcome_message         DC.B    'Welcome to 68k disassembler',CR,LF,0

get_start_address       DC.B    'Please enter a starting address in hexadecimal',CR,LF,0

get_end_address         DC.B    'Please enter an ending address in hexadecimal',CR,LF,0

atoi_error_invalid      DC.B    'Invalid address, characters must be $0-F',CR,LF,0

ascii_start:
    DS.w    10          ;specify size later?
    
ascii_end:
    DS.w    10          ;specify size later?

    

    END    START        ; last line of source












*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
