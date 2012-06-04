.model small
.stack
.code

EEL:    MOV AH,01
        INT 21h
        CMP AL,0Dh
        JNZ EEL
        MOV AH,2
        MOV DL,AL
        INT 21h
        MOV AH,4CH
        INT 21h
        
        END
