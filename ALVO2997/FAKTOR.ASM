stekas segment stack   
	db 128 dup (?)  
stekas ends

duom segment         
        masa 	DB  255 DUP (?)
        masb 	DB  255 DUP (?)
  	pirm_e 	db "Iveskite skaiciu:",13,10,"$"
	maxilg 	db 79
        kiek 	db ?
	txt 	db 80 dup ("$")
        neil 	db 13,10,"$"
	rez 	db "Faktorialas:", 13, 10, "$"
        desimt 	db 10
        ilg	DW 200
        help    DB    13,10,'Created by Alexandr Voronkov' ,13,10

        blpar   DB    'Blogi parametrai, naudokite /?$'   
duom ends

code segment         
	assume cs:code, ds:duom, ss:stekas

isvedimas proc 
          mov ah, 9
          int 21h
          ret
isvedimas endp

simb_isved proc
	   mov ah, 2h
	   int 21h
	   ret
simb_isved endp


start:    mov ax, duom		;nx shito reikia? <MorphiuM>
          mov ds, ax      
        
	 mov si, 81h

iseiles: mov ax, es:[si]
	 cmp al, 0Dh	
	 je jau
	 cmp ax, 3F2Fh
 	 je param
	 cmp al, 20h
	 jne blogai
	 inc si
	 jmp iseiles

 param: lea dx, help
        call isvedimas	
	jmp baigt

blogai: jmp baigt




;================nuskaitome skaiciu====================
jau:
        lea dx, pirm_e
        call isvedimas

	lea dx, maxilg
        mov ah, 0Ah
        int 21h

	lea dx, neil
	call isvedimas
	
        lea dx, rez
	call isvedimas
   
	
	mov cl, kiek
	mov kiek, 0
 	cmp cl, 0
	je kt
	lea bx, txt
        xor ax, ax

l:      mov dl, [bx];              
        CMP  dl, 0Dh
        je galas
        cmp dl, '0'      ;tikriname kad parametras butu skaicius
	jb kt
	cmp dl, '9'
	ja kt
	jmp skk

skk: 	sub dl, '0'      ;perskaityta simboli dedame i ax
	mul desimt
	add al, dl
        cmp ax, ilg
        jg  kt
	jmp lpab

lpab:	inc bx        
	loop l


galas:	mov ilg, ax    ;ilgis = ivestas skaicius
	jmp pr

hlp:    MOV  ah, 09h     ;helpas                      
        lea  dx, help                          
        INT  21h                               
        jmp baigt


kt:     MOV  ah, 09h     ;blogi parametrai                      
        lea  dx, blpar                         
        INT  21h                               
        jmp baigt

;====================ieskome faktorialo==================

tikrinimas proc 

           cmp dl, 9
           ja liekana
           mov [masb + di], dl           
           ret

liekana:   sub dl, desimt
           mov [masb + di], dl
           mov bl, [masb + di-1]
           inc bl
           mov [masb + di-1], bl
           ret

tikrinimas endp

ar_nulis proc
         mov di, -1
nulis:   inc di
         mov dl, [masb + di]
         cmp dl, 0
         je nulis
         ret
ar_nulis endp

lyginimas proc
        mov cx, 254
ll:     mov dl, [masb + di]
        mov [masa + di], dl
        dec di
        loop ll
        ret
  
lyginimas endp

nul:  mov dl, '1'
        call simb_isved
        jmp baigt

pr:     cmp ax, 0
        je nul
        cmp ax, 140
        ja kt
        xor ax, ax
        mov di, 254
        mov [masa + di], 2
        mov [masb + di], 1
        mov cx, 1
        push cx
     
ciklas: 
        call lyginimas   
        mov di, 254
        pop cx
        cmp cx, ilg   
        je isved
        inc cx
        push cx 
        dec cx      
        
mazas:  
        mov dl, [masb + di]
        add dl, [masa + di]
        call tikrinimas          

comp:
        cmp di, 0
        je kitas
        dec di        
        jmp mazas

kitas:  mov di, 254
        loop mazas
        jmp ciklas


isved:  call ar_nulis
is:     mov dl, [masb + di]
        add dl, '0'
        call simb_isved
        inc di
        CMP  di, 255
        je baigt
        jmp is


;============================================================

baigt: 
        mov ah, 4Ch
        mov al, 0
        int 21h
        ret

Code	ENDS
	END Start
