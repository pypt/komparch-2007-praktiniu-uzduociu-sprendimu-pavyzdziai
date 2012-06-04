.model small
      standout = 1
      cr = 0Dh
      lf = 0Ah
.stack 256
.data
     msg     db "Iveskite eilute teksto $"
     tus     db cr,lf,"$"
     tus1    db " $"
     ivedbuf db 255
             db 0
             db 255 dup (?)
     kint    db 10
             db 10 dup (?)	
.code
start:
     mov ax,@data
     mov ds,ax
			
     mov ah,09h
     mov dx, offset msg
     int 21h

     mov ah,09h
     mov dx, offset tus
     int 21h

     mov ah,0Ah
     mov dx,offset ivedbuf
     int 21h
	
     mov ah,09h
     mov dx, offset tus
     int 21h

     mov cl,[ivedbuf+1]	
     xor ch,ch	
     mov bx,offset ivedbuf+2			
     xor ax,ax     
     
ciklas:				;Duomenu nuskaitymas
	mov dl, byte ptr [bx]
	inc bl
	cmp dl,20h
	je iras				
	inc al
atgal:
loop ciklas	
	jmp toliau
iras:
	inc ah
	push ax
	xor al,al
	jmp atgal
toliau: 
	mov ah,4ch
	int 21h



ciklas2:			;Duomenu apdorojimas
	pop ax
	cmp al,0h
	je skip
	cmp al,0Ah
	jge desim

	add al,30h
	mov ah,02h		;Jei maziau uz desimt
	mov dl,al
	int 21h
	jmp skip
desim:
	cmp al,63h	
	jg simtai
	push cx;
	xor cx,cx
	mov cl,09h
	xor bx,bx
ciklas3:	
	mov ah,al
	sub ah,0Ah
	inc bl
	cmp ah,0Ah
	jl baigta
	
loop ciklas3
baigta: 
	mov al,ah
	pop cx
	mov ah,02
	add bl,30h
	mov dl,bl
	int 21h
	add al,30h	
	mov dl,al
	int 21h
	xor al,al
	xor bl,bl
	jmp skip
simtai:
	push cx
	xor cx,cx
	xor bx,bx
	mov cl,09h
	
ciklas4:	
	mov ah,al
	sub ah,64h
	inc bl
	cmp ah,64h
	jl simtras

loop ciklas4
simtras:
	pop cx
	mov al,ah
	mov ah,02
	add bl,30h
	mov dl,bl
	int 21h
	xor bl,bl
	jmp desim
Skip:
	mov ah,09
	mov dx,offset tus1
	int 21h
loop ciklas2

end start










push ax
ciklas2:
	pop ax
	cmp al,0Ah
	jl spaus
	push cx
	mov cl,63h
	xor bx,bx
ciklas3:
	sub al,0Ah
	inc bl
	cmp al,0Ah
	jl spaus
	cmp bl,0Ah
	je keisk
	jmp pral
keisk:
	xor bl,bl
	inc bh
pral:
loop ciklas3		
	pop cx
Spaus:	
	cmp bh,00h
	je simt	
	add bh,30h
	mov ah,02h
	mov dl,bh
simt:
	cmp bl,00h
	je des	
	add bl,30h
	mov ah,02h
	mov dl,bl
	int 21h
des:
	add al,30h
	mov ah,02h
	mov dl,al
	int 21h
loop ciklas2		




ciklas2:	
	cmp al,0Ah		;Jei skaicius mazesnis uz 10
	jl spaus
	push cx
	mov cl,63h
	xor bx,bx
ciklas3:
	sub al,0Ah
	inc bl
	cmp al,0Ah
	jl spaus
	cmp bl,0Ah
	je keisk
	jmp pral
keisk:
	xor bl,bl
	inc bh
pral:
loop ciklas3		
	pop cx
Spaus:	
	cmp bh,00h
	je simt	
	add bh,30h
	mov ah,02h
	mov dl,bh
simt:
	cmp bl,00h
	je des	
	add bl,30h
	mov ah,02h
	mov dl,bl
	int 21h
des:
	add al,30h
	mov ah,02h
	mov dl,al
	int 21h
loop ciklas2		
	pop cx
	jmp atgal
	
toliau: 
	xor bx,bx				
	mov cl,ah	   
iras:	
	push cx
	mov cl,al	



Prefikdai

	xor cx, cx
	mov cl, [ds:80h]		;Kiek simboliu parametrai
	mov dx, 81h
	mov si, dx
	
	mov ax, @data
	mov ds, ax
	mov di, offset param

	push ds
	pop es

	push si
	push di
	push cx
	cld
@@rasyk:
	lodsb	
	stosb

	or cl, cl
	Jz @@Baigta
	jmp short @@rasyk

@@Baigta:
	mov al,"$"
	stosb

	pop cx
	pop di
	pop si
	
	mov ah, 09h
	mov dx, di
	int 21h
	










xor cx, cx
	xor bx, bx		
	mov cl, [ds:80h]	
	or cl, cl
	push cx
	jz klaida0	
@@ciklas:	
	mov al, [81h + bx]
	cmp al, 20h
	jne @@dorok
	jmp @@skip
@@dorok:	
	call dorok 
@@Skip:
	inc bx		
	cmp cl, 00h
	je lauk
loop @@ciklas
lauk:
	jmp exit
Klaida0:
	call initds
	mov ah, 09h
	mov dx, offset klai0
	int 21h
Exit:
	call initds
	pop cx
			
	mov ax,4C00h
	int 21h

dorok proc	
	push ds
	push ax		

	cmp al, "/"	
	je @@tikr2
	jmp @@file1
@@tikr2:
	inc bx
	mov al, [81h + bx]
	cmp al, "?"
	je @@Help	
	mov ch, 0h	
@@file1:	
	push ds
	push ax	
	call initds
	mov si, offset fname1	
	pop ax
	push bx
	xor bx, bx
	mov bl, ch
	mov [si + bx], al	
	pop bx
	inc ch

	pop ds 
	inc bx
	dec cl 
	cmp cl, 00h
	je @@Klaida1
	mov al, [81h + bx]
	cmp al, 20h
	jne @@file1				;Iki cia gerai - turbut
@@file2:
	inc bx
	dec cl 
	cmp cl, 00h
	je @@Klaida2
	mov al, [81h + bx]
	cmp al, 20h
	je @@file2			;Praleidziami tarpai
@@rasyk:
	push ds
	push ax
	call initds
	mov si, offset fname2
	pop ax

	inc bx
	dec cl 
	cmp cl, 00h
	je @@Klaida2
	mov [si + bx], al	
	pop ds
	mov al, [81h + bx]
	cmp al, 20h
	jne @@rasyk		 	
	
@@Frag:
@@Fragkeit:

@@help: 
	call initds
	xor ax, ax
	mov ah, 09h
	mov dx, offset msgh1
	int 21h;
	mov cl, 00h
	jmp @@Exit
@@klaida1:
	call initds
	mov ah, 09h
	mov dx, offset klai1
	int 21h
	jmp @@exit
@@Klaida2:
@@Exit:
	pop ax
	pop ds	
	ret

	
endp

rasyk proc
	push ds
	push ax
	mov ax, @data
	mov ds, ax
	mov si, offset param
	pop ax
	mov [si + bx], al
	pop ds
	ret
endp
Initds proc
	mov ax, @data
	mov ds, ax
	ret
endp