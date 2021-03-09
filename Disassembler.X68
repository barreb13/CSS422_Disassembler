*-----------------------------------------------------------
* Title      : Disassembler V1.8(ish)
* Written by : Brent and Parker
* Date       : 3/4/21
* Description: Final Project for CSS 422
*-----------------------------------------------------------

;************************ Define Constants ********************************* 
CR                  EQU     $0D     ;carriage return
LF                  EQU     $0a     ;line feed
stack               EQU     $000A0000
lines_per_screen    EQU     30
buffer_size         EQU     64      ;size of buffer
nibble1             EQU     $F000   ;1st nibble in code (bits 15-12)
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
dest_mode           EQU     $01C0   ; --> 0000 0001 1100 0000 (used for destination in MOVE/MOVEA
dest_reg            EQU     $0E00   ;destination register (0000 0111 0000 0000)

ea_type_immediate   EQU     0
ea_type_move        EQU     1
ea_type_movea       EQU     2
ea_type_movea6      EQU     12
ea_type_lea         EQU     3
ea_type_destonly    EQU     4
ea_type_ext         EQU     5
ea_type_movem       EQU     6
ea_type_trap        EQU     7
ea_type_quick       EQU     8
ea_type_branch      EQU     9
ea_type_math        EQU     10
ea_type_rotation    EQU     11


;flags???



    ORG    $1000
START:                              ;first instruction of program
    LEA     stack, SP               ;SP @ $A0000



;********************************** Welcome Message ******************************************** 
WELCOME:
    LEA     welcome_message,A1      ;load the welcome message into A1
    MOVE.B  #14,D0
    TRAP    #15                     ;print contents of welcome_message


;*********************************** Get Starting Address *************************************** 
GET_STARTING_ADDRESS:
    ;prompt for address
    MOVE.B  #14,D0    
    LEA     get_start_address,A1    ;load the get_start_address message into A1
    TRAP    #15                     ;print get_start_address
    
    ;get user input address, store, and convert
    LEA     ascii_start,A1          ;store
    MOVE.B  #2,D0                   ;get user input    
    TRAP    #15                     ;another trap to get input
    JSR     ATOI                    ;address is now in hex format in memory location
    
    
    ;at this point our address is in D4 in hex
    ;check if > 0
    CMP.L   #0,D4                       ;compare to D4
    BLE     STARTA_ERROR_LESS_THAN_ZERO ;branch to ERROR_LESS_THAN_ZERO if less than 0
    
    ;?? MOVE.L  (A1),D3
    
    ;address is > 0 so check if even / odd
    ROR.L   #1,D4
    BCS     STARTA_ERROR_NOT_EVEN
    ROL.L   #1,D4    
    
    ;address is > 0 and verified even
    MOVE.l    (ascii_start),D5      ;load into A5
    MOVE.l    D5,A5                ;load into A5


;******************************** Get Ending Address ******************************************** 
GET_ENDING_ADDRESS:
    ;prompt for address 
    MOVE.B  #14,D0
    LEA     get_end_address,A1      ;load the get_end_address message into A1  
    TRAP    #15                     ;print get_end_address
    
    ;get user input address, store, and convert
    LEA     ascii_end,A1            ;store 
    MOVE.B  #2,D0                   ;get user input
    TRAP    #15                     ;another trap to get intput
    JSR ATOI

    ;perform checks:
    ;1.) even
    ROR.L   #1,D4
    BCS     ENDA_ERROR_NOT_EVEN
    ROL.L   #1,D4    
    
    ;2.) less than 00FFFFFF
    CMP.L   #$00FFFFFF,D4
    BGE     ENDA_ERROR_LARGE    
    
    ;3.) greater than starting address
    CMP.L   D4,A5
    BGE     ENDA_ERROR_LESS_THAN_STARTA
    
    ;good --> store in A6
    MOVE.l    (ascii_end),D6      ;load into D6
    MOVE.l    D6,A6               ;load into A6


;************************************ Main Loop???? ***********************************************
;get pointer to first given address
;pull hex code from that address and store in A1?
;take hex code and go to OP_TABLE


;A5 = starting address
;A6 = ending address
START_DECODING:
    ;CLR.L   D2                             ;clear screen line counter

DECODING_LOOP:
    JSR     OP_START                       ;get complete line of instruction to decode   
    

    ;print tot screen
    
    ;check if finished or if screen is filled
    ;handle checks
   
    
DONE:
    SIMHALT                                 ; halt simulator



;************************************ OP Stuff *************************************************************************************************************************** 

;A0 = POINTER TO OP_TABLE???
;A1 = 
;A2 = buffer (this is our decoded string that will print to screen)
;A3 = 
;A4 = current memory address for buffer (used for clearing????)
;A5 = starting address / current address in memory
;A6 = ending address
;A7 = SP

;D0
;D1
;D2 = ?
;D3 = buffer size (used for loop = 64)
;D4 = 
;D5
;D6
;D7

OP_START
    ;get complete line? 
    ;everything happens in here
    
    ;MOVEM.L         D2/A6, -(SP)

    JSR         OP_DATA_CLR         ;clear buffer
    LEA         buffer, A2          ;A2 now points to buffer, which is cleared
    

    ;print out current mem address by putting into buffer and then adding a ' ' (tab)
    MOVE.L      #$0003,D2           ;? BINARY --> 0011 ?
    JSR         ITOA_ADDRESS        ;convert A5 (current address) to ASCII and put in buffer
    MOVE.B      #$09, (A2)+         ;adds a ' ' to buffer
    
    ;at this point buffer has the memory address and a space, ready for op code                     !!TESTED UP UNTIL THIS POINT AND GOOD!!
    
    LEA         OP_TABLE, A0
    CLR.L       D0
    MOVE.W      (A5)+,D0            ;moves opcode from current address into D0
    MOVE.L      D0,D1               ;should move into D1
    MOVE.B      #right12,D2         ;move immediate value 12 into D2
    LSR.W       D2,D1               ;shift D1 by 12 bits, leaving just 4 bits (this is our opcode???)
    MULU        #6,D1               ;computes opcode table jump displacement
    JMP         0(A0,D1)            ;jumps to opcode table entry (A0 = OP_TABLE)

OP_FINISH:
    MOVEM.L     (SP)+, D2/A6
    RTS                             ;returns to DECODING_LOOP !?!?!?!?!?


OP_DATA_CLR:
    CLR.L       D3                  ; ? What is D3????
    ;MOVE.B      #buffer_size,D3     ; put 64 into D3
    MOVE.B      #10,D3     ; put 10 into D3                                                                 ;delete after testing and use 64
    LEA         buffer, A4          ; what address register?

OP_DATA_CLR_LOOP:
    MOVE.B      #0, (A4)+
    SUBI        #1, D3
    BGT         OP_DATA_CLR_LOOP
    RTS                                 ;need RTS to return


;********************************* jump table ****************************************
OP_TABLE:
    JMP         opcode0000              ;ORI (ANDI, SUBI, ADDI, EORI, CMPI)                                 $0
    JMP         opcode0001              ;MOVE.B                                                             $1    
    JMP         opcode0010              ;MOVEA.L, MOVE.L                                                    $2
    JMP         opcode0011              ;MOVEA.W MOVE.W                                                     $3
    JMP         opcode0100              ;NOP, MOVEM, LEA (CLR, NOT, EXT, TRAP, STOP, RTE, RTS, JSR, JMP     $4
    JMP         opcode0101              ;ADDQ (SUBQ)                                                        $5
    JMP         opcode0110              ;BRA.bw, BSR.bw (BEQ)                                               $6
    JMP         opcode0111              ;MOVEQ.l                                                            $7
    JMP         opcode1000              ;DIVU (DIVS, OR)                                                    $8
    JMP         opcode1001              ;SUB                                                                $9
    JMP         opcode1010              ;not assigned                                                       $A
    JMP         opcode1011              ;CMP (EOR)                                                          $B
    JMP         opcode1100              ;MULU (MULS, AND)                                                   $C
    JMP         opcode1101              ;ADD, ADDA                                                          $D
    JMP         opcode1110              ;ASL, ASR (LSL, LSR, ROL, ROR)                                      $E
    JMP         opcode1111              ;not assigned                                                       $F




;A0 = POINTER TO OP_TABLE???
;A1 = 
;A2 = buffer (this is our decoded string that will print to screen)
;A3 = pointer to op_xxx_table
;A4 = current memory address for buffer (used for clearing????)
;A5 = starting address / current address in memory
;A6 = ending address
;A7 = SP

;D0 = full instruction
;D1 = full instruction for manipulating (temporary)
;D2 = will store immediate value for comparing
;D3 = buffer size (used for loop = 64)
;D4 = 
;D5 = 
;D6 = 
;D7 = 



;ORI (ANDI, SUBI, ADDI, EORI, CMPI)                                 $0
opcode0000:                                 
    MOVE.L      D0,D1                   ;D1 has full instruction
    ANDI.W      #nibble2,D1             ;check bits 11,10,9,8
    MOVE.B      #right8, D2             ;store immediate value 8 in D2
    LSR.W       D2, D1                  ;shift to isolate next nibble (bits 11-8)
    MULU        #6, D1                  ;multiply by 6 to get displacement
    LEA         OP_0000_TABLE, A3       ;load op_0000_table into address register
    JMP         0(A3,D1)                ;jumps to opcode table entry (A0 = OP_TABLE)

;MOVE.B                                                             $1
opcode0001:
    JMP         OP_MOVEB                ;no need to break down, only MOVE.B


;MOVEA.L, MOVE.L                                                    $2
opcode0010:
    MOVE.L      D0,D1                   ;D1 has full instruction
    ANDI        #dest_mode, D1          ;0000 0001 1100 0000
    MOVE.B      #right6, D2             ;D2 now 00000111
    LSR.W       D2, D1                  ;shifting destination mode in D1 to far right by 3
    CMP.B       #1,D1                   ;does d1 = 001?
    BEQ         OP_MOVEAL               ;if d1 = 001, go to MOVEA
    JMP         OP_MOVEL                ;else jump to MOVEL
    



;MOVEA.W MOVE.W                                                     $3
opcode0011:
    MOVE.L      D0,D1                   ;D1 has full instruction
    ANDI        #dest_mode, D1          ;0000 0001 1100 0000
    MOVE.B      #right6, D2             ;D2 now 00000111
    LSR.W       D2, D1                  ;shifting destination mode in D1 to far right by 3
    CMP.B       #1,D1                   ;does d1 = 001?
    BEQ         OP_MOVEAW               ;if d1 = 001, go to MOVEAW
    JMP         OP_MOVEW                ;else jump to MOVEW




;NOP, MOVEM, LEA (CLR, NOT, EXT, TRAP, STOP, RTE, RTS, JSR, JMP)     $4
opcode0100:
    MOVE.L      D0,D1                   ;D1 has full instruction
    ANDI.W      #nibble2,D1             ;check bits 11,10,9,8
    MOVE.B      #right8, D2             ;store immediate value 8 in D2
    LSR.W       D2, D1                  ;shift to isolate next nibble (bits 11-8)
    MULU        #6, D1                  ;multiply by 6 to get displacement
    LEA         OP_0100_TABLE, A3       ;load op_0000_table into address register
    JMP         0(A3,D1)                ;jumps to opcode table entry (A0 = OP_TABLE)


;ADDQ (SUBQ)                                                        $5
opcode0101:
    ;JMP         OP_ADDQ
    
    
    ;3/8/21
    MOVE.L      D0,D1
    ANDI.W      #nibble2,D1
    LSR.W       #right8,D1
    ANDI.W      #1,D1
    CMP.B       #0,D1
    BEQ         OP_ADDQ
    CMP.B       #1,D1   
    BEQ         OP_SUBQ
    ;HANDLE ERROR


;EA_ADDQ_SUBQ:
;    ;CHECK BIT 8 FOR ADDQ OR SUBQ
;    CMP.W       #nibble2,D1
;    LSR.W       #right7,D1     
;    ANDI.W      #1,D1
;    CMP.B       #0,D1
;    BEQ         EA_ADDQ
;    CMP.B       #1,D1  
;    BEQ         EA_SUBQ
;    ;HANDLE ERROR      


;BRA.bw, BSR.bw (BEQ)                                               $6
opcode0110:
    MOVE.L      D0,D1                   ;D1 has full instruction
    ANDI.W      #nibble2,D1             ;check bits 11,10,9,8
    MOVE.B      #right8, D2             ;store immediate value 8 in D2
    LSR.W       D2, D1                  ;shift to isolate next nibble (bits 11-8)
    MULU        #6, D1                  ;multiply by 6 to get displacement
    LEA         OP_0110_TABLE, A3       ;load op_0110_table into address register
    JMP         0(A3,D1)                ;jumps to opcode table entry (A0 = OP_TABLE)
    
    ;come back and check when debugging. if this does not work then skip jump table


;MOVEQ                                                            $7
opcode0111:
    JMP         OP_MOVEQ



;DIVU (DIVS, OR)                                                    $8
opcode1000:
    MOVE.L      D0,D1
    ANDI.W      #nibble2,D1
    LSR.W       #8,D1
    ANDI.B      #1,D1
    CMP.B       #0,D1
    BEQ         OP_DIVU
    CMP.B       #1,D1
    BEQ         OP_DIVS
    ;HANDLE ERROR

;SUB                                                                $9
opcode1001:
    JMP         OP_SUB


;not assigned                                                       $A
opcode1010:
    JMP         OP_UNSUPPORTED_OPCODE


;CMP (EOR)                                                          $B
opcode1011:
    JMP         OP_CMP


;MULU (MULS, AND)                                                   $C
opcode1100:
    MOVE.L      D0,D1
    ANDI.W      #nibble2,D1
    LSR.W       #8,D1
    ANDI.B      #1,D1
    CMP.B       #0,D1
    BEQ         OP_MULU
    CMP.B       #1,D1
    BEQ         OP_MULS
    ;HANDLE ERROR

;ADD, ADDA                                                          $D
opcode1101:
    ;ADD and ADDA differ on bits 6,7... ADD will never be 11 for bits 6,7... use as check
    CLR         D1
    CLR         D2
    MOVE.L      D0,D1
    ANDI.W      #nibble3, D1
    MOVE.B      #right6, D2
    LSR.W       D2,D1
    
    ;at this point we have our bits of interest in bits 1,0
    
    CMP         #3,D1                              ;check if bits == 11
    BEQ         OP_ADDA                             ;if yes, branch ADDA
    BRA         OP_ADD                              ;else branch ADD



;ASL, ASR (LSL, LSR, ROL, ROR)                                      $E
opcode1110:
    CLR D1
    CLR D2
    MOVE.L      D0, D1
    ANDI.W      #nibble2, D1
    MOVE.B      #right8, D2
    LSR.W       D2, D1                              ;D1 has 0003 or 0004
    ANDI.W      #0001,D1                           ;isolate single bit
    
    ;at this point we have our single bit of interest in bit 0
    
    CMP         #0,D1                           ;check if bit == 0
    BEQ         OP_ASR                          ;if yes, branch to ASR
    BRA         OP_ASL                          ;else, branch to ASL


;not assigned                                                       $F
opcode1111:
    JMP         OP_UNSUPPORTED_OPCODE


;******************************** OP_XXX_TABLES ************************************
;once in OP_XXX_TABLE , we will use these entries to jump to specific op code to put into buffer

OP_0000_TABLE:
    jmp OP_ORI                                      ;0  
    jmp OP_UNSUPPORTED_OPCODE                       ;1
    jmp OP_ANDI                                     ;2
    jmp OP_UNSUPPORTED_OPCODE                       ;3
    jmp OP_SUBI                                     ;4
    jmp OP_UNSUPPORTED_OPCODE                       ;5
    jmp OP_ADDI                                     ;6
    jmp OP_UNSUPPORTED_OPCODE                       ;7
    jmp OP_UNSUPPORTED_OPCODE                       ;8
    jmp OP_UNSUPPORTED_OPCODE                       ;9
    jmp OP_EORI                                     ;10
    jmp OP_UNSUPPORTED_OPCODE                       ;11
    jmp OP_CMPI                                     ;12
    jmp OP_UNSUPPORTED_OPCODE                       ;13
    jmp OP_UNSUPPORTED_OPCODE                       ;14
    jmp OP_UNSUPPORTED_OPCODE                       ;15

;OP_0001_TABLE:
;    jmp OP_MOVEB


;OP_0010_TABLE:
;   jmp OP_MOVEAL
;   jmp OP_MOVEL


;OP_0011_TABLE:



;NOP, MOVEM, LEA (CLR, NOT, EXT, TRAP, STOP, RTE, RTS, JSR, JMP     $4
;NOP    1110
;MOVEM  1D00
;LEA    AN1
OP_0100_TABLE:
    jmp OP_UNSUPPORTED_OPCODE                           ;0  
    jmp OP_LEA                                          ;1      (address 0001)
    jmp OP_UNSUPPORTED_OPCODE                           ;2
    jmp OP_LEA                                          ;3      (address 0011)
    jmp OP_UNSUPPORTED_OPCODE                           ;4 
    jmp OP_LEA                                          ;5      (address 0101)
    jmp OP_UNSUPPORTED_OPCODE                           ;6 
    jmp OP_LEA                                          ;7      (address 0111) 
    jmp OP_MOVEM                                        ;8                          ;jmp OP_MOVEM_R2M
    jmp OP_LEA                                          ;9      (address 1001) 
    jmp OP_UNSUPPORTED_OPCODE                           ;10 
    jmp OP_LEA                                          ;11     (address 1011) 
    jmp OP_MOVEM                                        ;12                         ;jmp OP_MOVEM_M2R    
    jmp OP_LEA                                          ;13     (address 1101)
    jmp OP_NOP                                          ;14
    jmp OP_LEA                                          ;15     (address 1111)


;OP_0101_TABLE:



;BRA nibble 2 = 0000 (0) , BSR nibble 2 = 0001 (1)
OP_0110_TABLE:
    jmp OP_BRA                                          ;0
    jmp OP_BSR                                          ;1
    jmp OP_UNSUPPORTED_OPCODE                           ;2
    jmp OP_UNSUPPORTED_OPCODE                           ;3
    jmp OP_UNSUPPORTED_OPCODE                           ;4
    jmp OP_UNSUPPORTED_OPCODE                           ;5
    jmp OP_UNSUPPORTED_OPCODE                           ;6
    jmp OP_UNSUPPORTED_OPCODE                           ;7
    jmp OP_UNSUPPORTED_OPCODE                           ;8
    jmp OP_UNSUPPORTED_OPCODE                           ;9
    jmp OP_UNSUPPORTED_OPCODE                           ;10
    jmp OP_UNSUPPORTED_OPCODE                           ;11
    jmp OP_UNSUPPORTED_OPCODE                           ;12
    jmp OP_UNSUPPORTED_OPCODE                           ;13
    jmp OP_UNSUPPORTED_OPCODE                           ;14
    jmp OP_UNSUPPORTED_OPCODE                           ;15


;OP_0111_TABLE:
;implement later if needed


;OP_1000_TABLE:
;implement later if needed


;OP_1001_TABLE:
;implement later if needed


;OP_1010_TABLE:
;implement later if needed


;OP_1011_TABLE:
;implement later if needed


;OP_1100_TABLE:
;implement later if needed


;OP_1101_TABLE:
;implement later if needed


;OP_1110_TABLE:
;implement later if needed


;OP_1111_TABLE:
;implement later if needed




;******************************** OP_INSTRUCTION_XXXX******************************************
;this is where we are putting ascii text into buffer


OP_ORI:
    MOVE.B  #'O', (A2)+
    MOVE.B  #'R', (A2)+
    MOVE.B  #'I', (A2)+
    
    ;call OP_CHECK_SIZE to append a .b/.w/.l
    JSR     OP_CHECK_SIZE
    
    MOVE.L  #ea_type_immediate, D1              ;preps for EA_START and puts 0 into D1

    JSR     EA_START
    JMP     OP_FINISH

OP_ANDI:  ;(optional)
    MOVE.B  #'A', (A2)+
    MOVE.B  #'N', (A2)+
    MOVE.B  #'D', (A2)+
    MOVE.B  #'I', (A2)+
    
    ;call OP_CHECK_SIZE to append a .b/.w/.l
    JSR     OP_CHECK_SIZE
    
    MOVE.L  #ea_type_immediate, D1              ;preps for EA_START and puts 0 into D1

    JSR     EA_START
    JMP     OP_FINISH


OP_SUBI:  ;(optional)
    MOVE.B  #'S', (A2)+
    MOVE.B  #'U', (A2)+
    MOVE.B  #'B', (A2)+
    MOVE.B  #'I', (A2)+
    
    ;call OP_CHECK_SIZE to append a .b/.w/.l
    JSR     OP_CHECK_SIZE
    
    MOVE.L  #ea_type_immediate, D1              ;preps for EA_START and puts 0 into D1

    JSR     EA_START
    JMP     OP_FINISH


OP_ADDI:  ;(optional)
    MOVE.B  #'A', (A2)+
    MOVE.B  #'D', (A2)+
    MOVE.B  #'D', (A2)+
    MOVE.B  #'I', (A2)+
    
    ;call OP_CHECK_SIZE to append a .b/.w/.l
    JSR     OP_CHECK_SIZE
   
    MOVE.L  #ea_type_immediate, D1              ;preps for EA_START and puts 0 into D1

    JSR     EA_START
    JMP     OP_FINISH


OP_EORI:  ;(optional)
    MOVE.B  #'E', (A2)+
    MOVE.B  #'O', (A2)+
    MOVE.B  #'R', (A2)+
    MOVE.B  #'I', (A2)+
    
    ;call OP_CHECK_SIZE to append a .b/.w/.l
    JSR     OP_CHECK_SIZE
    
    MOVE.L  #ea_type_immediate, D1              ;preps for EA_START and puts 0 into D1
    
    JSR     EA_START
    JMP     OP_FINISH


OP_CMPI:  ;(optional)
    MOVE.B  #'C', (A2)+
    MOVE.B  #'M', (A2)+
    MOVE.B  #'P', (A2)+
    MOVE.B  #'I', (A2)+
    
    
    ;call OP_CHECK_SIZE to append a .b/.w/.l
    JSR     OP_CHECK_SIZE

    MOVE.L  #ea_type_immediate, D1              ;preps for EA_START and puts 0 into D1

    JSR     EA_START
    JMP     OP_FINISH


OP_MOVEB:
    MOVE.B  #'M', (A2)+
    MOVE.B  #'O', (A2)+
    MOVE.B  #'V', (A2)+
    MOVE.B  #'E', (A2)+
    MOVE.B  #'.', (A2)+
    MOVE.B  #'B', (A2)+
    
    MOVE.L  #ea_type_move, D1                   ;preps for EA_START and puts 1 into D1
    
    JSR     EA_START
    JMP     OP_FINISH

OP_MOVEAL:
    MOVE.B  #'M', (A2)+
    MOVE.B  #'O', (A2)+
    MOVE.B  #'V', (A2)+
    MOVE.B  #'E', (A2)+
    MOVE.B  #'A', (A2)+
    MOVE.B  #'.', (A2)+
    MOVE.B  #'L', (A2)+
    
    MOVE.L  #ea_type_movea, D1                   ;preps for EA_START and puts 2 into D1
    
    JSR     EA_START
    JMP     OP_FINISH

OP_MOVEL:
    MOVE.B  #'M', (A2)+
    MOVE.B  #'O', (A2)+
    MOVE.B  #'V', (A2)+
    MOVE.B  #'E', (A2)+
    MOVE.B  #'.', (A2)+
    MOVE.B  #'L', (A2)+
    
    MOVE.L  #ea_type_move, D1                   ;preps for EA_START and puts 1 into D1
    
    JSR     EA_START
    JMP     OP_FINISH


OP_MOVEAW:
    MOVE.B  #'M', (A2)+
    MOVE.B  #'O', (A2)+
    MOVE.B  #'V', (A2)+
    MOVE.B  #'E', (A2)+
    MOVE.B  #'A', (A2)+
    MOVE.B  #'.', (A2)+
    MOVE.B  #'W', (A2)+
    
    MOVE.L  #ea_type_movea, D1                   ;preps for EA_START and puts 2 into D1
    
    JSR     EA_START
    JMP     OP_FINISH


OP_MOVEW:
    MOVE.B  #'M', (A2)+
    MOVE.B  #'O', (A2)+
    MOVE.B  #'V', (A2)+
    MOVE.B  #'E', (A2)+
    MOVE.B  #'.', (A2)+
    MOVE.B  #'W', (A2)+
    
    MOVE.L  #ea_type_move, D1                   ;preps for EA_START and puts 1 into D1
    
    JSR     EA_START
    JMP     OP_FINISH


OP_NOP:
    MOVE.B  #'N', (A2)+
    MOVE.B  #'O', (A2)+
    MOVE.B  #'P', (A2)+
    
    ;NO EA
    JMP     OP_FINISH


OP_MOVEM:
    ;see movemd2r or movemr2d... see below at bottom ?????
    
    MOVE.B  #'M', (A2)+
    MOVE.B  #'O', (A2)+
    MOVE.B  #'V', (A2)+
    MOVE.B  #'E', (A2)+
    MOVE.B  #'M', (A2)+
    
    ;call OP_CHECK_SIZE to append a .b/.w/.l
    JSR     OP_CHECK_SIZE
    
    MOVE.L  #ea_type_movem, D1                   ;preps for EA_START and puts 6 into D1
    
    JSR     EA_START
    JMP     OP_FINISH

OP_LEA:
    MOVE.B  #'L', (A2)+
    MOVE.B  #'E', (A2)+
    MOVE.B  #'A', (A2)+
    
    MOVE.L  #ea_type_lea, D1                   ;preps for EA_START and puts 3 into D1
    
    JSR     EA_START
    JMP     OP_FINISH

OP_CLR:  ;(optional)
;implement later if needed


OP_NOT:  ;(optional)
;implement later if needed


OP_EXT:  ;(optional)
;implement later if needed


OP_TRAP:  ;(optional)
;implement later if needed

 
OP_STOP:  ;(optional)
;implement later if needed


OP_RTE:  ;(optional)
;implement later if needed


OP_RTS:  ;(optional)
;implement later if needed


OP_JSR:  ;(optional)
;implement later if needed


OP_JMP:  ;(optional)
;implement later if needed


OP_ADDQ:
    MOVE.B  #'A', (A2)+
    MOVE.B  #'D', (A2)+
    MOVE.B  #'D', (A2)+
    MOVE.B  #'Q', (A2)+
    
    ;call OP_CHECK_SIZE to append a .b/.w/.l
    JSR     OP_CHECK_SIZE

    MOVE.L  #ea_type_quick, D1                   ;preps for EA_START and puts 8 into D1

    JSR     EA_START
    JMP     OP_FINISH

OP_SUBQ:  ;(optional)
    MOVE.B  #'S', (A2)+
    MOVE.B  #'U', (A2)+
    MOVE.B  #'B', (A2)+
    MOVE.B  #'Q', (A2)+
    
    ;call OP_CHECK_SIZE to append a .b/.w/.l
    JSR     OP_CHECK_SIZE
    
    MOVE.L  #ea_type_quick, D1                   ;preps for EA_START and puts 8 into D1

    JSR     EA_START
    JMP     OP_FINISH

OP_BRA:                                     ;???? DO WE DEFINE SIZE HERE OR AFTER????
    MOVE.B  #'B', (A2)+
    MOVE.B  #'R', (A2)+
    MOVE.B  #'A', (A2)+

    MOVE.L  #ea_type_branch,D1
    
    JSR     EA_START
    JMP     OP_FINISH


OP_BSR:
    MOVE.B  #'B', (A2)+
    MOVE.B  #'S', (A2)+
    MOVE.B  #'R', (A2)+
    
    MOVE.L  #ea_type_branch,D1
    
    JSR     EA_START                        ;DO WE HAVE EA?
    JMP     OP_FINISH


OP_BEQ:
;implement later if needed


OP_MOVEQ:
    MOVE.B  #'M', (A2)+
    MOVE.B  #'O', (A2)+
    MOVE.B  #'V', (A2)+
    MOVE.B  #'E', (A2)+
    MOVE.B  #'Q', (A2)+
    
    ;DO WE NEED A .L ?
    
    MOVE.L  #ea_type_quick, D1                   ;preps for EA_START and puts 8 into D1
    
    JSR     EA_START
    JMP     OP_FINISH


OP_DIVU:
    MOVE.B  #'D', (A2)+
    MOVE.B  #'I', (A2)+
    MOVE.B  #'V', (A2)+
    MOVE.B  #'U', (A2)+
  
    MOVE.L  #ea_type_math, D1                   ;preps for EA_START and puts 10 into D1
  
    JSR     EA_START
    JMP     OP_FINISH    


OP_DIVS  ;(optional)
    MOVE.B  #'D', (A2)+
    MOVE.B  #'I', (A2)+
    MOVE.B  #'V', (A2)+
    MOVE.B  #'S', (A2)+
  
    MOVE.L  #ea_type_math, D1                   ;preps for EA_START and puts 10 into D1
  
    JSR     EA_START
    JMP     OP_FINISH   


OP_OR  ;(optional)
;implement later if needed


OP_SUB:
    MOVE.B  #'S', (A2)+
    MOVE.B  #'U', (A2)+
    MOVE.B  #'B', (A2)+

    JSR     OP_CHECK_SIZE                       ;call OP_CHECK_SIZE to append a .b/.w/.l
    
    MOVE.L  #ea_type_math, D1                   ;preps for EA_START and puts 10 into D1
    
    ;at this point it will return with SUB.X and go to EA_START
    JSR     EA_START
    JMP     OP_FINISH    


OP_CMP:
    MOVE.B  #'C', (A2)+
    MOVE.B  #'M', (A2)+
    MOVE.B  #'P', (A2)+
  
    JSR     OP_CHECK_SIZE                       ;call OP_CHECK_SIZE to append a .b/.w/.l  
    
    MOVE.L  #ea_type_math, D1                   ;preps for EA_START and puts 10 into D1
    
    ;at this point it will return with SUB.X and go to EA_START
    JSR     EA_START
    JMP     OP_FINISH    
    


OP_EOR:  ;(optional)
;implement later if needed


OP_MULU:
    MOVE.B  #'M', (A2)+
    MOVE.B  #'U', (A2)+
    MOVE.B  #'L', (A2)+
    MOVE.B  #'U', (A2)+

    MOVE.L  #ea_type_math, D1                   ;preps for EA_START and puts 10 into D1
    
    JSR     EA_START
    JMP     OP_FINISH    

OP_MULS:  ;(optional)
    MOVE.B  #'M', (A2)+
    MOVE.B  #'U', (A2)+
    MOVE.B  #'L', (A2)+
    MOVE.B  #'S', (A2)+

    MOVE.L  #ea_type_math, D1                   ;preps for EA_START and puts 10 into D1

    JSR     EA_START
    JMP     OP_FINISH


OP_AND:  ;(optional)
;implement later if needed


OP_ADD:
    MOVE.B  #'A', (A2)+
    MOVE.B  #'D', (A2)+
    MOVE.B  #'D', (A2)+

    ;call OP_CHECK_SIZE to append a .b/.w/.l
    JSR     OP_CHECK_SIZE
    
    MOVE.L  #ea_type_math, D1                   ;preps for EA_START and puts 10 into D1

    JSR     EA_START
    JMP     OP_FINISH

OP_ADDA:
    MOVE.B  #'A', (A2)+
    MOVE.B  #'D', (A2)+
    MOVE.B  #'D', (A2)+
    MOVE.B  #'A', (A2)+

    ;call OP_CHECK_SIZE to append a .b/.w/.l
    JSR     OP_CHECK_SIZE_ADDA
    
    MOVE.L  #ea_type_math, D1                   ;preps for EA_START and puts 10 into D1

    JSR     EA_START
    JMP     OP_FINISH


OP_ASL:
    MOVE.B  #'A', (A2)+
    MOVE.B  #'S', (A2)+
    MOVE.B  #'L', (A2)+

    ;call OP_CHECK_SIZE to append a .b/.w/.l
    JSR     OP_CHECK_SIZE
    
    MOVE.L  #ea_type_rotation, D1                   ;preps for EA_START and puts 10 into D1
    
    JSR     EA_START
    JMP     OP_FINISH


OP_ASR:
    MOVE.B  #'A', (A2)+
    MOVE.B  #'S', (A2)+
    MOVE.B  #'R', (A2)+

    ;call OP_CHECK_SIZE to append a .b/.w/.l
    JSR     OP_CHECK_SIZE
    
    MOVE.L  #ea_type_rotation, D1                   ;preps for EA_START and puts 10 into D1

    JSR     EA_START
    JMP     OP_FINISH

OP_LSL:  ;(optional)
;implement later if needed



OP_LSR:  ;(optional)
;implement later if needed



OP_ROL:  ;(optional)
;implement later if needed



OP_ROR:  ;(optional)
;implement later if needed



;OP_MOVEM_R2M:
;    MOVE.B  #'M', (A2)+
;    MOVE.B  #'O', (A2)+
;    MOVE.B  #'V', (A2)+
;    MOVE.B  #'E', (A2)+
;    MOVE.B  #'M', (A2)+
    
;    ;call OP_CHECK_SIZE to append a .b/.w/.l
;    JSR     OP_CHECK_SIZE
    
;    MOVE.L  #ea_type_movem, D1                   ;preps for EA_START and puts 6 into D1
    
;    JSR     EA_START
;    JMP     OP_FINISH


;OP_MOVEM_M2R:
;    MOVE.B  #'M', (A2)+
;    MOVE.B  #'O', (A2)+
;    MOVE.B  #'V', (A2)+
;    MOVE.B  #'E', (A2)+
;    MOVE.B  #'M', (A2)+
    
;    ;call OP_CHECK_SIZE to append a .b/.w/.l
;    JSR     OP_CHECK_SIZE
    
;    MOVE.L  #ea_type_movem, D1                   ;preps for EA_START and puts 6 into D1
    
;    JSR     EA_START
;    JMP     OP_FINISH


OP_UNSUPPORTED_OPCODE:
;fill out

;D0 HAS COMPLETE INSTRUCTION
OP_CHECK_SIZE:
    CLR     D1                                  ;CLEAR D1
    CLR     D2                                  ;clear D2
    MOVE.L  D0,D1                               ;D0 and D1 both have complete opcode
    ANDI.W  #nibble3,D1                         ;isolate nibble 3
    MOVE.B  #right6, D2                         ;putting immediate value 6 in D2
    LSR.W   D2, D1                              ;bits 7,6 --> bits 1,0
    
     
    CMP     #00,D1                              ;compare bits 1,0 to 00
    BEQ     OP_SIZE_BYTE                        ;if bits == 00, size byte
    CMP     #01,D1                              ;compare bits to 01
    BEQ     OP_SIZE_WORD                        ;if bits == 01, size word
    BRA     OP_SIZE_LONG                        ;else size long

OP_SIZE_BYTE
    MOVE.B  #'.', (A2)+
    MOVE.B  #'B', (A2)+
    RTS

OP_SIZE_WORD
    MOVE.B  #'.', (A2)+
    MOVE.B  #'W', (A2)+
    RTS


OP_SIZE_LONG
    MOVE.B  #'.', (A2)+
    MOVE.B  #'L', (A2)+
    RTS


OP_CHECK_SIZE_ADDA:
    CLR     D1                                  ;CLEAR D1
    CLR     D2                                  ;clear D2
    MOVE.L  D0,D1                               ;D0 and D1 both have complete opcode
    ANDI.W  #nibble2,D1                         ;isolate nibble 2
    MOVE.B  #right8, D2                         ;putting immediate value 8 in D2
    LSR.W   D2, D1                              ;
    
    ;at this point we have our single bit in bit 0
    
    ANDI.W  #0001,D1                            ;isolate bit 0
    CMP     #0,D1                               ;check if bit == 0
    BEQ     OP_SIZE_WORD                        ;if yes, size = word
    BRA     OP_SIZE_LONG                        ;else, size = long
 

;******************************** ATOI ******************************************************************************************************************************
ATOI:
        MOVE.L      D1,D2                   ;loop variable (size) is in D2
        MOVEA.L     A1,A2                   ;pointer to next char
        CLR.L       D4

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
    

ATOI_DONE 
    MOVE.L         D4,(A1)                      ;at this point, move the new address in D4 to mem location                                
    RTS                                         ;used to RTS after a branch statement

;************************************* ITOA *******************************************************************************************************************
;A0
;A1
;A2 = buffer (this is our decoded string that will print to screen)
;A3
;A4 = current memory address for buffer
;A5 = starting address / current address in memory
;A6 = ending address
;A7 = SP

;D0 = counter
;D1 = 
;D2 = ?
;D3 = buffer size (used for loop = 64)
;D4 = value being converted
;D5 =
;D6 = 
;D7 = 
ITOA:
    MOVE.L         A5,D4                    ;D4 has data to convert to ascii

ITOA_LOOP:
    CMP.B           #0,D5
    BEQ             ITOA_FINISH             ;when 0, branch to finish to complete




ITOA_BYTE:



ITOA_WORD:



ITOA_LONG:



ITOA_ADDRESS:
    CLR.L       D4                          ;D4 = 0000 0000
    MOVE.L      A5,D4                       ;our address is now in D4 and ready to deconstruct
    MOVE.B      #8,D0                       ;counter
    JMP         ITOA_ADDRESS_LOOP
ITOA_ADDRESS_LOOP:
    CMP.B       #0,D0                       ;check if done
    BEQ         ITOA_FINISH                 ;if at 0, branch to ITOA_FINISH
    ROL.L       #4,D4                       ;rotate left 4 bits, to get MSB to beginning 
    MOVE.B      D4,D1                       ;store in D1 (this will be whole byte, we want half)
    ANDI.W      #$000F,D1                   ;character is now isolated
    
    JSR         ITOA_HEX2ASCII              ;JSR to convert
    SUBI        #1,D0                       ;subtract 1 from counter
    JMP         ITOA_ADDRESS_LOOP           ;loop again!

ITOA_HEX2ASCII:
    CMP.B       #$A,D1                      ;compare byte in D1 to hex value A
    BGE         ITOA_LETTER                 ;if greater than/equal A, it is letter
    CMP.B       #$A,D1                      ;compare byte in D1 to hex value A
    BLT         ITOA_NUMBER                 ;if less than, it is number

ITOA_NUMBER:
    ADDI.B      #$30,D1                     ;add $30 to D1 to convert
    MOVE.B      D1,(A2)+                    ;add to buffer and increment to next position
    RTS

ITOA_LETTER:
    ADDI.B      #$37,D1                     ;add 37 to D1 to convert
    MOVE.B      D1,(A2)+                    ;add to buffer and increment to next position
    RTS

ITOA_FINISH:
    RTS


;************************************ Validate Addresses ******************************************

VALIDATE_BEGINNING:
    



;******************************** Message Error Handling ***************************************************************************************************************** 
STARTA_ERROR_LESS_THAN_ZERO:
    MOVE.B  #14,D0
    LEA     error_message_1,A1      ;load the get_end_address message into A1
    TRAP    #15    
    JMP     GET_STARTING_ADDRESS

STARTA_ERROR_NOT_EVEN:
    MOVE.B  #14,D0
    LEA     error_message_2,A1      ;load error_message_2
    TRAP    #15    
    JMP     GET_STARTING_ADDRESS

ENDA_ERROR_NOT_EVEN:
    MOVE.B  #14,D0
    LEA     error_message_3,A1      ;load error_message_3
    TRAP    #15
    JMP     GET_ENDING_ADDRESS

ENDA_ERROR_LARGE:
    MOVE.B  #14,D0
    LEA     error_message_4,A1      ;load error_message_4
    TRAP    #15
    JMP     GET_ENDING_ADDRESS
    
ENDA_ERROR_LESS_THAN_STARTA:
    MOVE.B  #14,D0
    LEA     error_message_5,A1      ;load error_message_5
    TRAP    #15
    JMP     GET_ENDING_ADDRESS

;****************************************** EA Stuff ********************************************************************************************************************* 

EA_START:
    LEA         EA_TYPE_TABLE, A0
    
    MULU        #6,D1               ;computes opcode table jump displacement
    JMP         0(A0,D1)            ;jump to correct table input


EA_TYPE_TABLE:
    JMP         EA_IMMEDIATE        ;0  DONE
    JMP         EA_MOVE             ;1  DONE
    JMP         EA_MOVEA            ;2  DONE
    JMP         EA_LEA              ;3  DONE
    JMP         EA_DESTONLY         ;4  JMP, CLR
    JMP         EA_EXT              ;5
    JMP         EA_MOVEM            ;6
    JMP         EA_TRAP             ;7
    JMP         EA_QUICK            ;8  DONE
    JMP         EA_BRANCH           ;9  DONE
    JMP         EA_MATH             ;10 DONE    DIVU, DIVS, SUB, CMP, MULU, ADD, ADDA
    JMP         EA_ROTATION         ;11         ASL, ASR, ???  
    JMP         EA_FINISH           ;

EA_FINISH:
    RTS ; TAKE OUT LATER
    


;********************************************  EA_TYPE  ****************************************************   

EA_IMMEDIATE:                               ;value 0
    MOVE.B  #$09, (A2)+                     ;adds a ' ' to buffer
    MOVE.B  #'#',(A2)+                      ;add a # to buffer
    MOVE.B  #'$',(A2)+                      ;add a $ to buffer
    
    ;check size which is bits 6,7 and store in D6
    ;get immediate value from memory based off size and store in D7
    JSR     EA_CHECK_SIZE
    
    ;at this point our size is in D6 and data is in D7 and memory has been advanced
    ;convert immediate data to ascii and put on buffer
    JSR     EA_ITOA_IMMEDIATE
    
    LEA     EA_MODE_TABLE,A0                ;load table
    MOVE.B  #',',(A2)+                      ;add a # to buffer
    MOVE.B  #$09, (A2)+                     ;adds a ' ' to buffer
    
    ;source mode are bits 3,4,5   |         ;source register are bits 0,1,2
    
    ;isolate source mode - bits 3,4,5 and store in D4
    MOVE.L  D0,D4
    LSR.W   #3,D4
    ANDI.W  #$7,D4
    MULU    #6,D4
    
    ;isolate source register - bits 0,1,2 and store in D5
    MOVE.L  D0,D5
    ANDI.W  #$7,D5

    JSR     EA_JMP_HELPER
    JMP     EA_FINISH

;D4 = mode      --> source / destination
;D5 = register  --> source / destination   
EA_MOVE:
    MOVE.B  #$09, (A2)+                     ;adds a ' ' to buffer
    LEA     EA_MODE_TABLE,A0                ;load table
    
    ;source mode are bits 3,4,5   |         ;source register are bits 0,1,2
    
    ;isolate source mode
    MOVE.L  D0,D4
    LSR.W   #3,D4
    ANDI.W  #$7,D4
    MULU    #6,D4
        
    ;isolate source register
    MOVE.L  D0,D5
    ANDI.W  #$7,D5
    
    JSR    EA_JMP_HELPER
    MOVE.B  #',',(A2)+                  ;add ',' to buffer  
    
    ;isolate destination mode
    MOVE.L  D0,D4
    LSR.W   #6,D4
    ANDI.W  #$7,D4
    MULU    #6,D4
    
    ;isolate destination register 
    MOVE.L  D0,D5
    LSR.W   #4,D5
    LSR.W   #5,D5                       ;HAVE TO BREAK UP SHIFT TO STAY UNDER 8????
    ANDI.W  #$7,D5   
    JSR     EA_JMP_HELPER

    JMP     EA_FINISH
    

EA_MOVEA:
    MOVE.B  #$09, (A2)+                     ;adds a ' ' to buffer
    LEA     EA_MODE_TABLE,A0                ;load table

    ;source mode are bits 3,4,5   |         ;source register are bits 0,1,2
    
    ;isolate source mode
    MOVE.L  D0,D4
    LSR.W   #3,D4
    ANDI.W  #$7,D4
    MULU    #6,D4
        
    ;isolate source register
    MOVE.L  D0,D5
    ANDI.W  #$7,D5
    
    JSR    EA_JMP_HELPER
    MOVE.B  #',',(A2)+                  ;add ',' to buffer
    
    ;isolate destination mode --> SHOULD ALWAYS BE 001 AND GO TO ADDRESS REGISTER
    MOVE.L  D0,D4
    LSR.W   #6,D4
    ANDI.W  #$7,D4
    MULU    #6,D4
    
    ;isolate destination register 
    MOVE.L  D0,D5
    LSR.W   #4,D5
    LSR.W   #5,D5                       ;HAVE TO BREAK UP SHIFT TO STAY UNDER 8????
    ANDI.W  #$7,D5   
    JSR     EA_JMP_HELPER

    JMP     EA_FINISH

EA_LEA:
    MOVE.B  #$09, (A2)+                     ;adds a ' ' to buffer
    LEA     EA_MODE_TABLE,A0                ;load table
    
    ;source mode are bits 3,4,5   |         ;source register are bits 0,1,2
    
    ;isolate source mode
    MOVE.L  D0,D4
    LSR.W   #3,D4
    ANDI.W  #$7,D4
    MULU    #6,D4
        
    ;isolate source register
    MOVE.L  D0,D5
    ANDI.W  #$7,D5
    
    JSR    EA_JMP_HELPER
    MOVE.B  #',',(A2)+                  ;add ',' to buffer
    
    ;destination always An
    ;MOVE.B  #'A',(A2)+                  ;add 'A' to buffer
    
    ;isolate destination register 
    ;MOVE.L  D0,D5
    ;LSR.W   #4,D5
    ;LSR.W   #5,D5                       ;HAVE TO BREAK UP SHIFT TO STAY UNDER 8????
    ;ANDI.W  #$7,D5

    ;isolate destination mode --> SHOULD ALWAYS BE 001 AND GO TO ADDRESS REGISTER
    MOVE.L  #1,D4
    MULU    #6,D4
    
    ;isolate destination register 
    MOVE.L  D0,D5
    LSR.W   #4,D5
    LSR.W   #5,D5                       ;HAVE TO BREAK UP SHIFT TO STAY UNDER 8????
    ANDI.W  #$7,D5   
    JSR     EA_JMP_HELPER

    JMP     EA_FINISH

EA_DESTONLY:        ;JMP, CLR





EA_EXT:





EA_MOVEM:
    MOVE.B  #$09, (A2)+                     ;adds a ' ' to buffer
    LEA     EA_MODE_TABLE,A0                ;load table
    
    ;source mode are bits 3,4,5   |         ;source register are bits 0,1,2
    
    ;isolate source mode
    MOVE.L  D0,D4
    LSR.W   #3,D4
    ANDI.W  #$7,D4
    MULU    #6,D4
        
    ;isolate source register
    MOVE.L  D0,D5
    ANDI.W  #$7,D5
    
    JSR    EA_JMP_HELPER
    MOVE.B  #',',(A2)+                  ;add ',' to buffer

EA_TRAP:





EA_QUICK:
    ;FIGURE WHAT KIND? (ADDQ,SUBQ,MOVEQ)
    ;ADDQ/SUBQ  -->  opcode = 0101 (stored in D0)
    ;MOVEQ      -->  opcode = 0111 (stored in D0)
    MOVE.B  #$09, (A2)+                 ;adds a ' ' to buffer
    MOVE.B  #'#',(A2)+                  ;add a # to buffer
    MOVE.B  #'$',(A2)+                  ;add a $ to buffer
    
    MOVE.L  D0,D1                       ;should move into D1
    
    ;check for MOVEQ
    LSR.W   #right6,D1
    LSR.W   #right6,D1  
    CMP.W   #$7,D1
    BEQ     EA_QUICK_MOVEQ
    
    CLR     D1                          ;else not MOVEQ, reset D1 and continue with ADDQ / SUBQ
    MOVE.L  D0,D1
    ANDI.W  #dest_reg,D1                ;isolate destination register(11,10,9)
    LSR.W   #right8,D1                  ;shift 8 times
    LSR.W   #right1,D1                  ;shift 1 time for total of 9 times
    
    ;at this point we have our number, so convert to ASCII and put on buffer
    ADDI.B  #$30,D1                     ;convert to ASCII
    MOVE.B  D1,(A2)+                    ;put on buffer
    
    
    ;ready for destination address
    MOVE.B  #',',(A2)+                  ;add ',' to buffer  
    LEA     EA_MODE_TABLE,A0            ;load table
    
    
    ;isolate source mode
    MOVE.L  D0,D4
    LSR.W   #3,D4
    ANDI.W  #$7,D4
    MULU    #6,D4
        
    ;isolate source register
    MOVE.L  D0,D5
    ANDI.W  #$7,D5
    
    JSR    EA_JMP_HELPER
    
    JMP     EA_FINISH
    
    ;LSR.W       #right12,D1         ;shift D1 by 12 bits, leaving just 4 bits      --> gives shift count error
    ;CMP.W       #$5,D1
    ;BEQ         EA_ADDQ_SUBQ
    
EA_QUICK_MOVEQ:
    MOVE.L  D0,D1
    ANDI.W  #$00FF,D1               ;isolate bits 7-0
    
    ;our bits are isolated in D1, move to D7 for ITOA function
    MOVE.L  D1,D7
    JSR     EA_ITOA_BYTE_CONVERT
    
    MOVE.B  #',',(A2)+                  ;add ',' to buffer
    MOVE.B  #'D',(A2)+                  ;add ',' to buffer
    MOVE.L  D0,D1
    ANDI.W  #nibble2,D1
    LSR.W   #8,D1
    LSR.W   #1,D1
    
    ;at this point we have our number, so convert to ASCII and put on buffer
    ADDI.B  #$30,D1                     ;convert to ASCII
    MOVE.B  D1,(A2)+                    ;put on buffer

    JMP     EA_FINISH

EA_BRANCH:
    ;PROGRAM COUNTER @ A5
    ;BRA or BSR
    ;displacement bits are 7-0 
    MOVE.L  D0,D1
    ANDI.W  #$00FF,D1               ;isolate bits 7-0
    ;PERFORM CHECKS 0000 0000 = WORD VALUE, 1111 1111 = LONG VALUE
    
    CMP.B   #$00,D1
    BEQ     EA_BRANCH_16
    BRA     EA_BRANCH_32



EA_BRANCH_16:
    MOVE.W  (A5),D1                    ;CHECK WHERE POINTER IS WHEN HITS HERE
    ;D1 WILL HAVE OUR DISPLACEMENT (0E32)
    ;ADD 0E32 TO PC + 2
    MOVE.W  D1,D7
    ADD.W   A5,D7
    ;SUBI.B  #2,D7
    
    MOVE.B  #$09, (A2)+                 ;adds a ' ' to buffer
    MOVE.B  #'$',(A2)+                  ;add '$' to buffer
    
    ;convert to ASCII and put on buffer
    ;D7 HAS DISPLACEMENT   
    JSR     BRANCH_16_ITOA
    
    JMP     EA_FINISH

EA_BRANCH_32:
    ;come back and implement branch 32



BRANCH_16_ITOA:
    ;D7 HAS OUR DISPLACEMENT... CONVERT TO ASCII!   ;D7 = 1234
    LSR.W   #right8,D7                              ;D7 = 0012
    JSR     EA_ITOA_BYTE_CONVERT                    ;BUFFER WILL HAVE 12
    MOVE.W  (A5)+,D7                                ;D7 = 0E32
    ADD.W   A5,D7                                   ;D7 = 123
    SUBI.B  #2,D7                                   ;SUBI 2 to account for post increment of A5
    ANDI.W  #$00FF,D7                               ;D7 = 0034
    JSR     EA_ITOA_BYTE_CONVERT                    ;BUFFER WILL HAVE 1234
    
    JMP     EA_ITOA_DONE


EA_MATH:
    ;source mode 3, 4, 5 | source register 0, 1, 2 | destination register 11, 10, 9
    MOVE.B  #$09, (A2)+             ;add a ' ' to buffer
    LEA     EA_MODE_TABLE,A0        ;load mode table
    
    ;isolate source mode
    MOVE.L  D0,D4
    LSR.W   #3,D4
    ANDI.W  #$7,D4
    MULU    #6,D4
    
    ;isolate source register
    MOVE.L  D0,D5
    ANDI.W  #$7,D5
    
    JSR     EA_JMP_HELPER
    
    MOVE.B  #',',(A2)+              ;add a ',' to buffer
    
    ;condition for ADDA - opcode == 1101 && bits 7,6 == 11
    ;check for ADDA and leave if yes, otherwise continue
    MOVE.L  D0,D1                   ;complete opcode in D1
    LSR.W   #6,D1                   ;shift right 6
    LSR.W   #6,D1                   ;shift another 6 to = 12 total
    
    CMP     #$D,D1                  ;check if opcode = 1101
    BNE     EA_MATH_CONTINUE        ;if not 1101, skip and go to math
    
    ;if we are here, we know opcode is 1101 and further check
    MOVE.L  D0,D1
    LSR.W   #6,D1
    ANDI.W  #3,D1
    CMP.B   #3,D1
    BNE     EA_MATH_CONTINUE
    
    ;if d1 == 3, both conditions met so process as ADDA
    ;destination mode is 1 (address register)
    MOVE.L  #1,D4
    MULU    #6,D4
    
    ;isolate destination register 
    MOVE.L  D0,D5
    LSR.W   #4,D5
    LSR.W   #5,D5                      
    ANDI.W  #$7,D5   
 
    JSR     EA_JMP_HELPER 
    JMP     EA_FINISH
        
EA_MATH_CONTINUE:       
    ;destination mode is 0 (data register)
    MOVE.L  #0,D4
    MULU    #6,D4
    
    ;isolate destination register 
    MOVE.L  D0,D5
    LSR.W   #4,D5
    LSR.W   #5,D5                      
    ANDI.W  #$7,D5  
    
    JSR     EA_JMP_HELPER 
    JMP     EA_FINISH
    

EA_ROTATION:
    MOVE.B  #$09, (A2)+                 ;adds a ' ' to buffer
    MOVE.L  D0,D1                       ;complete opcode
    LSR.W   #5,D1                       ;shift right 5
    ANDI.W  #1,D1
    
    CMP     #0,D1
    BEQ     EA_ROTATION_IMMEDIATE       ;it is immediate value
    BRA     EA_ROTATION_REGISTER        ;else register 

EA_ROTATION_CONTINUE:
    MOVE.L  D0,D1                       ;get rotation value
    ANDI.W  #nibble2,D1                 ;isolate nibble 2
    LSR.W   #8,D1
    LSR.W   #1,D1                       :total of 9 shifts right
    
    ;at this point we have our number, so convert to ASCII and put on buffer
    ADDI.B  #$30,D1                     ;convert to ASCII
    MOVE.B  D1,(A2)+                    ;put on buffer
    
    MOVE.B  #',',(A2)+                  ;add ',' to buffer 
    MOVE.B  #'D',(A2)+                  ;add 'D' to buffer
    
    MOVE.L  D0,D1                       ;complete opcode
    ANDI.W  #7,D1                       
    
    ADDI.B  #$30,D1                     ;convert to ASCII
    MOVE.B  D1,(A2)+                    ;put on buffer
    
    JMP     EA_FINISH                   ;done

EA_ROTATION_IMMEDIATE:
    MOVE.B  #'#',(A2)+                  ;add '#' to buffer
    BRA     EA_ROTATION_CONTINUE
    
EA_ROTATION_REGISTER:
    MOVE.B  #'D',(A2)+                  ;add '#' to buffer
    BRA     EA_ROTATION_CONTINUE
    
EA_JMP_HELPER
    JMP     0(A0,D4)


;********************************************  EA_MODE_TABLE  ****************************************************  
EA_MODE_TABLE:
    JMP     EA_MODE_000
    JMP     EA_MODE_001
    JMP     EA_MODE_010
    JMP     EA_MODE_011
    JMP     EA_MODE_100
    JMP     EA_MODE_101
    JMP     EA_MODE_110
    JMP     EA_MODE_111
    ;JMP     EA_MODE_FINISH

;********************************************  EA_MODE_XXX  ****************************************************    
EA_MODE_000:                                        ;Data register 'Dn'
    MOVE.B  #'D',(A2)+                              ;put D on buffer
    MOVE.B D5,D3                                    ;move to d3 for conversion
    JSR     EA_HEX_TO_ASCII                         ;puts register on buffer  
    RTS
    
EA_MODE_001:                                        ;Address Register 'An'
    MOVE.B  #'A',(A2)+                              ;put A on buffer
    MOVE.B  D5,D3                                   ;move to d3 for conversion
    JSR     EA_HEX_TO_ASCII                         ;puts register on buffer  
    RTS

EA_MODE_010:                                        ;Address direct --> '(An)'
    MOVE.B  #'(',(A2)+                              ;put ( on buffer
    MOVE.B  #'A',(A2)+                              ;put A on buffer
    MOVE.B  D5,D3                                   ;move to D3 for conversion
    JSR     EA_HEX_TO_ASCII                         ;convert and put on buffer   
    MOVE.B  #')',(A2)+                              ;put ) on buffer
    RTS

EA_MODE_011:                                        ;Address with Postincrement --> '(An)+' 
    MOVE.B  #'(',(A2)+                              ;put ( on buffer
    MOVE.B  #'A',(A2)+                              ;put A on buffer
    MOVE.B  D5,D3                                   ;move to D3 for conversion
    JSR     EA_HEX_TO_ASCII                         ;convert and put on buffer   
    MOVE.B  #')',(A2)+                              ;put ) on buffer
    MOVE.B  #'+',(A2)+                              ;put + on buffer
    RTS

EA_MODE_100:                                        ;Address with Predecrement --> '-(An)'
    MOVE.B  #'-',(A2)+                              ;put - on buffer
    MOVE.B  #'(',(A2)+                              ;put ( on buffer
    MOVE.B  #'A',(A2)+                              ;put A on buffer
    MOVE.B  D5,D3                                   ;move to D3 for conversion
    JSR     EA_HEX_TO_ASCII                         ;convert and put on buffer   
    MOVE.B  #')',(A2)+                              ;put ) on buffer



;unsupported
EA_MODE_101:                                        
;Address with Displacement --> '(d16, An)
    
;unsupported
EA_MODE_110:



;some form of immediate data: short, long, immediate
EA_MODE_111:
    ;D4 = MODE | D5 = register (000, 001, 100)
    ;000 = Absolute Short (xxx).w
    ;001 = Absolute Long (xxx).l
    ;100 = Immediate data
    
    CMP.B   #000,D5
    BEQ     EA_111_ABSOLUTE_SHORT
    CMP.B   #001,D5
    BEQ     EA_111_ABSOLUTE_LONG
    CMP.B   #100,D5
    BEQ     EA_111_IMMEDIATE
    
    ;HANDLE ERROR
            
    
EA_111_ABSOLUTE_SHORT:
    ;A5 is looking at correct spot
    ;ADD WORD VALUE AT A5 ON TO BUFFER AT A2 AND INCREMENT BY WORD
    MOVE.B  #'$',(A2)+                              ;put $ on buffer
    MOVE.W  (A5),D7
    CLR     D6
    MOVE.B  #01,D6                                  ;word size in EA_ITOA_IMMEDIATE
    JSR     EA_ITOA_IMMEDIATE
    RTS

EA_111_ABSOLUTE_LONG:
    MOVE.B  #'$',(A2)+                              ;put $ on buffer
    MOVE.W  (A5),D7
    CLR     D6
    MOVE.B  #02,D6                                  ;long size in EA_ITOA_IMMEDIATE        
    JSR     EA_ITOA_IMMEDIATE
    RTS

EA_111_IMMEDIATE:
    

   
    

EA_HEX_TO_ASCII:
    ADDI.B      #$30,D3                     ;add $30 to D1 to convert
    MOVE.B      D3,(A2)+                    ;add to buffer and increment to next position
    RTS     


EA_CHECK_SIZE:
    CLR     D6
    MOVE.L  D0,D6                           ;complete opcode --> D6
    ANDI.W  #nibble3,D6                     ;isolating nibble 3
    LSR.W   #right6,D6                      ;shifting bits 7,6 --> 1,0
    
    CMP     #00,D6
    BEQ     EA_SIZE_BYTE
    CMP     #01,D6
    BEQ     EA_SIZE_WORD
    BRA     EA_SIZE_LONG

EA_SIZE_BYTE:
    MOVE.W  (A5)+,D7
    ;MOVE.B  #4,D3;                          SET UP COUNTER
    RTS

EA_SIZE_WORD:
    MOVE.W  (A5),D7
    ;MOVE.B  #4,D3;                          SET UP COUNTER
    RTS

EA_SIZE_LONG:
    MOVE.W  (A5),D7
    ;MOVE.B  #8,D3;                          SET UP COUNTER
    RTS



EA_ITOA_IMMEDIATE:
    ;D3 = counter, D7 = value to be converted, D6 = size
    CMP.B   #%00,D6
    BEQ     EA_ITOA_BYTE
    CMP.B   #%01,D6
    BEQ     EA_ITOA_WORD
    CMP.B   #%10,D6     
    BEQ     EA_ITOA_LONG
    

;EA_IT0A_IMMEDIATE_LOOP
;    CMP.B   #0,D3                       ;check if loop done
;    BEQ     EA_ITOA_FINISH              ;if = 0, loop done
    
EA_ITOA_BYTE:
    JSR     EA_ITOA_BYTE_CONVERT
    
    JMP     EA_ITOA_DONE


EA_ITOA_WORD:
    LSR.W   #right8,D7
    JSR     EA_ITOA_BYTE_CONVERT
    MOVE.W  (A5)+,D7
    JSR     EA_ITOA_BYTE_CONVERT
    
    JMP     EA_ITOA_DONE
    
EA_ITOA_LONG:
    LSR.W   #right8,D7
    JSR     EA_ITOA_BYTE_CONVERT
    MOVE.W  (A5)+,D7
    JSR     EA_ITOA_BYTE_CONVERT

    MOVE.W  (A5),D7
    LSR.W   #right8,D7
    JSR     EA_ITOA_BYTE_CONVERT
    MOVE.W  (A5)+,D7
    JSR     EA_ITOA_BYTE_CONVERT

    JMP     EA_ITOA_DONE

EA_ITOA_BYTE_CONVERT:
    MOVE.W  D7,D3
    ANDI.W  #$F0,D3
    LSR.W   #right4,D3
    JSR     EA_ITOA_NIBBLE_CONVERT
    
    MOVE.W  D7,D3
    ANDI.W  #$0F,D3
    JSR     EA_ITOA_NIBBLE_CONVERT
    RTS

EA_ITOA_NIBBLE_CONVERT:
    CMP.B   #9,D3
    BGT     EA_ITOA_LETTER
    BRA     EA_ITOA_NUMBER

EA_ITOA_HEX2ASCII:



EA_ITOA_NUMBER:
    ADDI.B  #$30,D3
    MOVE.B  D3,(A2)+
    RTS

EA_ITOA_LETTER:
    ADDI.B  #$37,D3
    MOVE.B  D3,(A2)+
    RTS

EA_ITOA_DONE
    RTS

    
;****************************************** MESSAGES ***************************************************
welcome_message         DC.B    'Welcome to 68k disassembler',CR,LF,0

get_start_address       DC.B    'Please enter a starting address in hexadecimal',CR,LF,0

get_end_address         DC.B    'Please enter an ending address in hexadecimal',CR,LF,0

atoi_error_invalid      DC.B    'Invalid address, characters must be $0-F',CR,LF,0


error_message_1         DC.B    'Invalid Address: Must be greater than 0',CR,LF,0

error_message_2         DC.B    'Invalid Address: Must be even',CR,LF,0

error_message_3         DC.B    'Invalid Address: Must be even',CR,LF,0

error_message_4         DC.B    'Invalid Address: Must be less than $00FFFFFF',CR,LF,0

error_message_5         DC.B    'Invalid Address: Must be greater than starting address',CR,LF,0


ascii_start:
    DS.w    10          ;specify size later?
    
ascii_end:
    DS.w    10          ;specify size later?

buffer                  ;storing op code
    DS.W    64          ;do we leave as .w or change to .l ?
    

    END    START        ; last line of source

































*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
