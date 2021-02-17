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
buffer_size         EQU     64      ;size of buffer
nibble2             EQU     $0F00   ;2nd nibble in code (bits 11-8)
nibble3             EQU     $00F0   ;3rd nibble in code (bits 7-4)
nibble4             EQU     $000F   ;4th nibble in code (bits 3-0)
right1              EQU     1       ;shift 1 time
right2              EQU     2       ;shift 2 times
right3              EQU     3       ;shift 3 times to extract src mode
right4              EQU     4       ;shift 4 times to extract 3rd nibble
right5              EQU     5       ;shift 5 times (unused)
right6              EQU     6       ;shift 6 times to extract dst mode
right7              EQU     7       ;shift 7 times
right8              EQU     8       ;shift 8 to extract 2nd nibble
right9              EQU     9       ;shift 9 times to check 2nd nibble?
right10             EQU     10      ;shift 10
right12             EQU     12      ;shift 12 to extract 3rd byte
right16             EQU     16      ;shift 16 to extract 2nd byte
right24             EQU     24      ;shift 24 to extract 1st byte

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
    
    ;??                             MOVE.L  (A1),D3
    
    ;perform checks (later)
 
;*************************** Get Ending Address ******************************* 
    MOVE.B  #14,D0
    LEA     get_end_address,A1      ;load the get_end_address message into A1  
    TRAP    #15                     ;print get_end_address
    
    LEA     ascii_end,A1            ;store 
    MOVE.B  #2,D0                   ;get user input
    TRAP    #15                     ;another trap to get intput
    JSR ATOI

    ;perform checks (later)


;****************************** Main Loop???? ************************************ 
;get pointer to first given address
;pull hex code from that address and store in A1?
;take hex code and go to OP_TABLE

MAIN:
    JSR     START_OPCODE                   ;get complete line of instruction to decode   



   
    
DONE:
    SIMHALT                                 ; halt simulator


START_OPCODE: 



CLEAR_BUFFER:


;********************************* jump table ****************************************

OP_TABLE:
        JMP         opcode0000              ;ORI (ANDI, SUBI, ADDI, EORI, CMPI)
        JMP         opcode0001              ;MOVE.B
        JMP         opcode0010              ;MOVEA.L, MOVE.L
        JMP         opcode0011              ;MOVEA.W MOVE.W
        JMP         opcode0100              ;NOP, MOVEM, LEA (CLR, NOT, EXT, TRAP, STOP, RTE, RTS, JSR, JMP
        JMP         opcode0101              ;ADDQ (SUBQ)
        JMP         opcode0110              ;BRA.bw, BSR.bw (BEQ)
        JMP         opcode0111              ;MOVEQ.l
        JMP         opcode1000              ;DIVU (DIVS, OR)
        JMP         opcode1001              ;SUB
        JMP         opcode1010              ;not assigned
        JMP         opcode1011              ;CMP (EOR)
        JMP         opcode1100              ;MULU (MULS, AND)
        JMP         opcode1101              ;ADD, ADDA
        JMP         opcode1110              ;ASL, ASR (LSL, LSR, ROL, ROR)
        JMP         opcode1111              ;not assigned


opcode0000:
        MOVE.L      D0,D1
        ANDI.W      #nibble2,D1


opcode0001:




opcode0010:




opcode0011:




opcode0100:




opcode0101:




opcode0110:




opcode0111:




opcode1000:




opcode1001:




opcode1010:




opcode1011:




opcode1100:




opcode1101:




opcode1110:




opcode1111:



;******************************** OP_XXX_TABLES ************************************

OP_0000_TABLE:
           


OP_0001_TABLE:



OP_0010_TABLE:



OP_0011_TABLE:



OP_0100_TABLE:



OP_0101_TABLE:



OP_0110_TABLE:



OP_0111_TABLE:



OP_1000_TABLE:



OP_1001_TABLE:



OP_1010_TABLE:



OP_1011_TABLE:



OP_1100_TABLE:



OP_1101_TABLE:



OP_1110_TABLE:



OP_1111_TABLE:


;******************************** OP_INSTRUCTION_XXXX******************************************

OP_ORI:
;ATUALLY PRINTING CODE
;



OP_ANDI:  ;(optional)




OP_SUBI:  ;(optional)



OP_ADDI:  ;(optional)



OP_EORI:  ;(optional)



OP_CMPI:  ;(optional)



OP_MOVE.B:



OP_MOVEA.L:



OP_MOVE.L:



OP_MOVEA.W:



OP_MOVE.W:



OP_NOP:



OP_MOVEM:



OP_LEA:



OP_CLR:  ;(optional)



OP_NOT:  ;(optional)



OP_EXT:  ;(optional)



OP_TRAP:  ;(optional)


 
OP_STOP:  ;(optional)



OP_RTE:  ;(optional)



OP_RTS:  ;(optional)



OP_JSR:  ;(optional)



OP_JMP:  ;(optional)



OP_ADDQ:



OP_SUBQ:  ;(optional)



OP_BRA:                                     ;???? DO WE DEFINE SIZE HERE OR AFTER????



OP_BSR:



OP_BEQ:



OP_MOVEQ:



OP_DIVU:



OP_DIVS  ;(optional)



OP_OR  ;(optional)



OP_SUB:



OP_CMP:



OP_EOR:  ;(optional)



OP_MULU:



OP_MULS:  ;(optional)



OP_AND:  ;(optional)



OP_ADD:



OP_ADDA:



OP_ASL:



OP_ASR:




OP_LSL:  ;(optional)




OP_LSR:  ;(optional)




OP_ROL:  ;(optional)




OP_ROR:  ;(optional)




OP_UNSUPPORTED_OPCODE:




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
