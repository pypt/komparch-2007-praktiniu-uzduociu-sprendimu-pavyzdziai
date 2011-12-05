title vaido3
.model small
.stack 1000
.data

   zinute db 'Iveskite skaiciu, kurio faktoriala norite suskaiciuoti', 13, 10, '$'
   zinute1 db '        (Sveikas skaicius is intervalo [2; 34])', 13, 10, '$'
   zinute2 db 'Skaiciaus $'
   zinute3 db '             faktorialas: ', 13, 10, '$'

   apie db  '----------Vaidas Adomauskas, MIF, programu sistemos, I kuras. 2 grupe----------', 10, 13, '$'
   apie1 db '----------------Programa skaiciuoja dideliu skaiciu faktorialus----------------', 13, 10,  13, 10,'$'

   klaida db 'Jus ivedete neteisinga skaiciu arba jo visai neivedete. Bandykite dar karta:)', 13, 10, '$'
   klaida1 db '                  Nutraukti darba spauskite "b" klavisa', 13, 10, '$'
   
   ivsk db 4, 5 dup(0)
   
   skaicius1 db 200 dup(0)
   skaicius2 db 101 dup(0)

   zenklas db '$'

   ilgis dw 40
   max dw 34

  
   galas dw 0
   faktsk dw 0
   desim dW 10

.code

main proc

   mov ax, @data
   mov ds, ax

   mov ah, 62h
   int 21h
   
   mov es, bx
   mov si, 80h

   mov ah, es:[si]
   cmp ah, 3
   jne tesiam

   inc si
   mov ah, es:[si]
   cmp ah, ' '
   jne tesiam


   inc si
   mov ah, es:[si]
   cmp ah, '/'
   jne tesiam

   inc si
   mov ah, es:[si]
   cmp ah, '?'
   jne tesiam

   call kitaeil

   mov ah, 09h
   mov dx, offset apie
   int 21h

   mov ah, 09h
   mov dx, offset apie1
   int 21h   


tesiam:

   call kitaeil
   mov dx, offset zinute
   mov ah, 09h
   int 21h
 
   mov dx, offset zinute1
   int 21h

   call kitaeil

   mov dx, offset zinute2
   int 21h

   call fskaicius


tesiam1:

   mov faktsk, ax

   call kitaeil

   mov dx, offset zinute3
   mov ah, 09h
   int 21h
 


   call kitaeil
   
 

   mov di, offset skaicius1
   mov si, offset skaicius2
   mov cx, ilgis   		
   mov ah, 'a'

   valymas:
 
	inc di
	inc si
	mov [si], ah
	mov [di], ah
	dec cx

	cmp cx, 1
	jg valymas


   inc si
   mov ah, 0
   mov [si], ah

   inc di
   mov ah, 1
   mov [di], ah

   mov al, zenklas
   mov [di+1], al
   mov [si+1], al

   mov cx, 2

   faktorialas:
	call  fakt
	inc cx
	mov bx, 1	
	push si
        push di

	perrasymas:

	   
	   mov ah, [si]
	   mov [di], ah
	   dec si
	   dec di
	   inc bx
	   
	
	   cmp bx, ilgis 		
	   jle perrasymas	
	
	pop di
 	pop si
	cmp cx, faktsk		;faktorialas keiciamas cia:)
	jle faktorialas



   mov bx, 1
    
	
konvertavimas:

	mov ah, [si]

	cmp ah, 'a'
	je raide

	jne skaicius
	
konv:
	
	cmp bx, ilgis		
	jle konvertavimas
	




        mov dx, offset skaicius2	;spausdinimas
	mov ah, 09h
	int 21h

pabaiga:

   mov ah, 4ch
   int 21h

skaicius:
	add ah, 30h
	mov [si], ah
	dec si
	inc bx
	jmp konv


raide:
	mov ah, ' '
	mov [si], ah
	dec si
	inc bx
	jmp konv   

neskaicius:

   cmp dx, 62h
   je pabaiga   

   call kitaeil
   call kitaeil

   mov dx, offset klaida
   mov ah, 09h
   int 21h

   mov dx, offset klaida1
   int 21h

   mov dx, offset zinute2
   mov ah, 09h
   int 21h  

   call fskaicius

   jmp tesiam1
endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

fskaicius proc

   mov dx, offset ivsk
   mov ah, 0ah
   int 21h

   mov si, offset ivsk
   inc si
   mov cl, [si]
   mov ch, 0

   cmp cx, 0
   je neskaicius


   mov ax, 0

   formuosim:
	mov dx, 0
	inc si
	mov dl, [si]
	
	cmp dl, '0'
	jl neskaicius

	cmp dl, '9'
  	jg neskaicius

	sub dl, '0'
	mov bx, dx
	mul desim
	add ax, bx	

	loop formuosim

   cmp ax, max
   jg neskaicius

   cmp ax, 2
   jl neskaicius

ret
endp



fakt proc
   
   push di
   push si
   mov bl, 0


   dar:
	

   	mov al, [di]

	cmp al, 'a'
	je raide1

tol:
	mov ah, 0
   	mul cx


	mov dx, 0
	div desim
	add dl, bl	;paskutinis skaitmuo
	
 	cmp dl, 9
	jg skaidymas	

toliau:
	mov bl, al	;kas liko
	
	mov [si], dl
	dec di
	dec si

	cmp al, 0
	jg dar


 	mov al, [di]

	cmp al, 'a'
	jne dar
	
   pop si
   pop di

ret


raide1:
   sub al, 61h
jmp tol


perrasom:
   
   mov [di], al
   mov [si], al
   dec si
   dec di
jmp dar

skaidymas:

   push ax
   mov al, dl
   mov ah, 0
   mov dx, 0
   div desim
   mov bx, ax
   pop ax

   add ax, bx

   jmp toliau


endp

kitaeil proc
 
   push ax
   push dx

   mov dl, 0ah
   mov ah, 06h
   int 21h
 
   mov dl, 0dh
   int 21h
   
   pop dx
   pop ax

ret

endp


end

