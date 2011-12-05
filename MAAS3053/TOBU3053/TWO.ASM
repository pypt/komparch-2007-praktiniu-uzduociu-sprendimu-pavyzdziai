;example13
.model small
.stack
.code
PRINT_A_J       PROC
        MOV DL,'A'  ;moves the A character to register DL
        MOV CX,10   ;moves the decimal value 10 to register cx
                        ;This number value its the time to print out after the A                                        ;character
PRINT_LOOP:
        CALL WRITE_CHAR ;Prints A character out
        INC DL          ;Increases the value of register DL
        LOOP PRINT_LOOP ;Loop to print out ten characters
        MOV AH,4Ch      ;4Ch function of the 21h interruption
        INT 21h         ;21h interruption
PRINT_A_J       ENDP    ;Finishes the procedure

WRITE_CHAR      PROC
        MOV AH,2h   ;2h function of the 21 interruption
        INT 21h     ;Prints character out from the register DL
        RET         ;Returns the control to procedure called
WRITE_CHAR      ENDP     ;Finishes the procedure
        END  PRINT_A_J   ;Finishes the program code

