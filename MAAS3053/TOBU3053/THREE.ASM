;exam15
.model small
.stack
.code

TEST_WRITE_DECIMAL    PROC
        MOV DX,12345   ;moves the decimal number  12345 to register DX
        CALL WRITE_DECIMAL ;Calls the procedure
        MOV AH,4CH   ;4Ch function
        INT 21h      ;21h interruption
TEST_WRITE_DECIMAL ENDP    ;Finishes the procedure

        PUBLIC WRITE_DECIMAL
;.................................................................;
;This procedure writes 16 bit number is a unsigned number in decimal notation ;
;Use: WRITE_HEX_DIGT                                          ;
;.................................................................;

WRITE_DECIMAL    PROC
        PUSH AX   ;Pushes the value of the register AX to the stack memory
        PUSH CX; Pushes the value of the register CX to the stack memory
        PUSH DX; Pushes the value of the register DX to the stack memory
        PUSH SI; Pushes the value of the register SI to the stack memory
        MOV AX,DX ;moves the value of the register DX to AX
        MOV SI,10 ;moves the value 10 to register SI
        XOR CX,CX ;clears the register  CX
NON_ZERO:
        XOR DX,DX ;clears the register DX
        DIV SI    ;divides operation between SI
        PUSH DX   ;Pushes one digit number in the stack memory
        INC CX    ;increases CX
        OR AX,AX  ;no zero
        JNE NON_ZERO  ; jumps  NON_ZERO
WRITE_DIGIT_LOOP:
        POP DX    ;Returns the value in reverse mode
        CALL WRITE_HEX_DIGIT  ;Calls the procedure
        LOOP WRITE_DIGIT_LOOP ;loop
END_DECIMAL:
        POP SI;pops the value of the register SI to register SI
        POP DX;pops the value of the register DX to register DX
        POP CX;pops the value of the register CX to register CX
        POP AX; pops the value of the register AX to register AX
        RET       ;Returns the control to procedure called
WRITE_DECIMAL   ENDP ;Finishes the procedure

        PUBLIC WRITE_HEX_DIGIT
;......................................................................;
;                                                                      ;
; This procedure converts the lower 4 bits  of the register DL into;
;hexadecimal number and print them out ;
;Use: WRITE_CHAR                                                   ;
;......................................................................;

WRITE_HEX_DIGIT    PROC
        PUSH DX     ;Pushes the value of the register DX to the stack memory
        CMP DL,10   ;Compares the value 10 with the value of the register DL
        JAE HEX_LETTER  ;No , jump HEX_LETER
        ADD DL,"0"  ;yes, converts into digit number
        JMP Short WRITE_DIGIT ;writes the character
HEX_LETTER:
        ADD DL,"A"-10 ;converts a character to hexadecimal number
WRITE_DIGIT:
        CALL WRITE_CHAR ;shows the character on the computer screen
        POP DX      ;Returns the initial value to register DL
        RET         ;Returns the control the procedure called
WRITE_HEX_DIGIT   ENDP

        PUBLIC WRITE_CHAR
;......................................................................;
;This procedure prints on the computer screen a character using D.O.S. function ;
;......................................................................;

WRITE_CHAR   PROC
        PUSH AX   ;Pushes the value of the register AX to the stack memory
        MOV AH,2  ;2 function
        INT 21h   ;21 Interruption
        POP AX    ;Pops the initial value of the register AX
        RET       ;Returns the control to the procedure called
WRITE_CHAR   ENDP

        END TEST_WRITE_DECIMAL ;finishes the program code

