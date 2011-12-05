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

     xor cx,cx
     mov cl,[ivedbuf+1] 
     xor ch,ch	
     mov bx,offset ivedbuf+2			
     xor ax,ax     
     xor dx,dx	     
	cmp cl, 0h
	je exit
ciklas:				
	mov dl, byte ptr [bx]	
	mov dh, byte ptr [bx + 1]
	cmp dl,20h		;Jei simbolis tarpas
	je iras
	cmp dh,0Dh
	je iras1
			
	inc al	
	jmp skip
iras1:
	inc al
	jmp iras
iras:	
	cmp al,09h
	jbe rasyk	
	cmp al,63h
	ja sim
	cmp al,0Ah
	jae des
sim:	
	push bx
	xor bx,bx
	mov bl, 64h
	div bl
	pop bx
	 
	push ax
	push bx

	mov ah,02
	add al,30h
	mov dl,al
	int 21h
	xor ax,ax

	pop bx
	pop ax
	mov al,ah
	xor ah,ah	
des:
	push bx
	xor bx,bx
	mov bl,0Ah
	div bl
	pop bx
	push ax
	push bx

	mov ah,02
	add al,30h
	mov dl,al
	int 21h
	xor ax,ax

	pop bx
	pop ax
	mov al,ah
	xor ah,ah
	
rasyk:
	push bx
	mov ah,02
	add al,30h
	mov dl,al
	int 21h
	mov ah,02h
	mov dl,20h
	int 21h	
	xor ax,ax
	pop bx
skip: 
	inc bl
loop ciklas
exit:

     mov ah,4ch
     int 21h
     
end start
     
