.model small
    .stack
    .code
    mov AH,1h       ;Selects the 1  D.O.S. function
    Int 21h         ;reads character and return ASCII code to register AL
    mov DL,AL       ;moves the ASCII code to register DL
    sub DL,30h      ;makes the operation minus 30h to convert 0-9 digit number
    cmp DL,9h       ;compares if digit number it was between 0-9
    jle digit1      ;If it true gets the first number digit (4 bits long)
    sub DL,7h       ;If it false, makes operation minus 7h to convert letter A-F
    digit1:
    mov CL,4h       ;prepares to multiply by 16
    shl DL,CL       ; multiplies to convert into four bits upper
    int 21h         ;gets the next character
    sub AL,30h      ;repeats the conversion operation
    cmp AL,9h       ;compares the value 9h with the content of register AL
    jle digit2      ;If true, gets the second digit number
    sub AL,7h       ;If no, makes the minus operation 7h
    digit2:
    add DL,AL       ;adds the second number digit
    mov AH,4CH
    Int 21h         ;21h interruption
    End; finishs the program code
