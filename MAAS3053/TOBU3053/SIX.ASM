dosseg
.model small
.stack
.code
write   proc        
        mov ah,2h
        mov dl,2ah
        int 21h
        mov ah,4ch
        int 21h
write  endp

        end  write
