;exam16
.model small
.stack
.code

PRINT_ASCII       PROC
        MOV DL,00h  ;moves the value 00h to register DL
        MOV CX,255   ;moves the value decimal number 255. this decimal number will be 255 times to print out after the character A
PRINT_LOOP:
        CALL WRITE_CHAR ;Prints the characters out
        INC DL          ;Increases the value of the register DL content
        LOOP PRINT_LOOP ;Loop to print out ten characters
        MOV AH,4Ch      ;4Ch function
        INT 21h         ;21h Interruption
PRINT_ASCII       ENDP    ;Finishes the procedure

WRITE_CHAR      PROC
        MOV AH,2h   ;2h function to print character out
        INT 21h     ;Prints out the character in the register DL
        RET         ;Returns the control to the procedure called
WRITE_CHAR      ENDP     ;Finishes the procedure

        END  PRINT_ASCII   ;Finishes the program code

