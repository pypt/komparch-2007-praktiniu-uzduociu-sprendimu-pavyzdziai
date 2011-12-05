.model small
.Stack 0FFh
        cr = 0Dh
        lf = 0Ah
        standout = 1
.data
        msg db "Iveskite eilute "
            db cr, lf, "$"     
        ats1 db cr, lf, "Eilutes ilgis: $"
        tus  db cr, lf, "$"
        ivedbuf db 0FFh                         ;=255
                db 0
                db 0FFh dup (?)
.code
start:
        mov ax, @data
        mov ds, ax

        mov ah, 09h
        mov dx, offset msg
        int 21h

        mov ah, 0Ah
        mov dx, offset ivedbuf
        int 21h

        mov ah, 09h
        mov dx, offset ats1
        int 21h

        mov al, [ivedbuf + 1]
        xor ah, ah

        mov bl, 100
        div bl
        push ax
        or al, al
        jz next

        add al, 30h
        mov ah, 02h
        mov dl, al
        int 21h
next:
        pop ax
        xor al, al
        xchg al, ah
        mov bl, 10
        div bl
        push ax
        or al, al
        jz next2

        add al, 30h
        mov ah, 02h
        mov dl, al
        int 21h
next2:
        pop ax
        xor al, al
        xchg al, ah
        add al, 30h
        mov ah, 02h
        mov dl, al
        int 21h
;------------------------------------------------------------------
        mov ah, 09h
        mov dx, offset tus
        int 21h

        mov si, offset ivedbuf + 2
        mov di, si
        cld                                     ; pozymis df = 0
        mov cl, [ivedbuf + 1]
        xor ch, ch
        xor ax, ax
        xor bx, bx
ciklas:
        lodsb                                   ; al - priskiriamas baitas
        cmp al, 20h                             ;is adreso ds:si
        je naujas
        cmp al, 0Dh
        je naujas
        inc bl
        loop ciklas                             ; cl mazinamas 1 ir i ciklas
        jmp exit
naujas:
        push cx
        cmp bl, 00h
        je prep
        jmp neprep
prep:
        cmp al, 0Dh
        je exit
        mov di, si
        jmp ciklas
neprep:
        mov ah, 40h
        mov cl, bl
        mov bx, standout
        mov dx, di
        int 21h

        mov ah, 09h
        mov dx, offset tus
        int 21h

        xor bl, bl
        mov di, si
        pop cx
        cmp al, 0Dh
        je exit
        jmp ciklas
exit:
        mov ah, 4Ch
        int 21h
end start
