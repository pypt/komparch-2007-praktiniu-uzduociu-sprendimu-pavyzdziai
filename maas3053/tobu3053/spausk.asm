.model small
.stack
.code
 call procas
 Procas proc
    Mov ah,02h
    Mov dl,'*'
    Int 21h
    Mov ah,00h
    Int 16h
 endp
 
 Mov ah,4ch
 Int 21h
end