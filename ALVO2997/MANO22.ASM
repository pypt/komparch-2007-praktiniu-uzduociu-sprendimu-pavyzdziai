Title 2 uþduoties pavyzdys (c) 2002 Irmantas Naujikas

.model small	; programos modëlis; "small" - nedidelëm programom
.stack 1000  	; stekas
.data		      ; èia apraðomas duomenø segmentas

  MAX_WIDTH  dw 320
  MAX_HEIGHT dw 200
  par dw 1
  
  eil    db 'Iveskite skaiciu : $'        
  
  about   db  'Created by Alexandr Vronkov. $'
         
         
  blpar  db  'Blogai nurodyti parametrai. $'


  ineil2  db 5,6 dup(?)	      ;  klavet. skait. buferis
  ineil3  db 5,6 dup(?)	
  ineil  db 40, 41 dup(0)            ;  klav. skait. buferis
  fname   db 2 dup (0) 
  ten  dw 10

.code

  main proc
    mov ax,@data                    ; ds registro iniciavimas
    mov ds, ax                      ;
 
   

   ; ---------------- nuskaityti parametru eilute is PSP strukturos.
    mov si,80h
    xor cx,cx
    mov cl,es:[si]         ; es rodo i PSP (Program Segment Prefix) pradzia.
    cmp cl,0
    je  vaziuojam
    lea di,fname
    xor cx,cx
    ; ---------------- parametru nuskaitymas
;pertarp:    
    inc si
    mov al,es:[si]
    
findslash:
    mov [di],al
    inc di
    inc cx                    ; simboliu skaicius
    
    mov al,es:[si]
    cmp al,'/'
    je find
    inc si 
   
    cmp al,0dh
    je perlauk                ; zodis baigesi
    jmp findslash             ; skaityti toliau

perlauk:
    mov [di], byte ptr 0
    cmp cl,0
    je  vaziuojam
    cmp cl,2
    jne  blogai


find:
    inc si
    mov al,es:[si]
    cmp al,'?'
    je enddd 
     

    ; ---------------- blogai nurodyti parametrai

blogai:
    xor dx,dx
    mov dx, offset blpar
    mov ah,09h
    int 21h
    jmp galas

    ; ----------------

enddd:
    xor dx,dx
    ;mov dx, offset outeile
    mov dx, offset about            ; uzrasome ant ekrano about turini
    mov ah, 09h                     ; 09h  spec. int 21h funkcija
    int 21h  
    jmp galas


   
vaziuojam:


    mov dx, offset eil              ; uzrasome ant ekrano eil turini
    mov ah, 09h                     ; 09h  spec. int 21h funkcija
    int 21h

       

   call param 
   mov cx,ax
   push cx


    mov ah, 0			    ; ájungiam 320x200 grafiná reþimà
    mov al, 13h
    int 10h

    mov ax, 0a000h		    ; grafinës atminties segmentas
    mov es, ax

    
   mov cx, 320                    ; statinio ilgis pikseliais
   mov bx, 0			    ; x - pradinë koordinatë
   mov ax, 0			    ; y - pradinë koordinatë
   mov dh, 15			    ; pradinë spalva


ciklas3:
    push cx ax bx dx	
    mov cx, 200
    call Vlinija
    pop dx bx ax cx
    ;inc dh
    inc bx
    loop ciklas3


    ;  paiðom kvadratà

    pop cx
    mov bx, 10
    mov ax, 10
    mov dh, 10

ciklas2:
    push cx ax bx dx	
    mov cx, 100
    call Vlinija
    pop dx bx ax cx
    ;inc dh
    inc bx
    loop ciklas2


    ; laukiam kol bus paspaustas "enter"
    call ivedimas                   ; duomenu ivedimas

    mov ah, 0			      ; ájungiam tekstiná reþimà
    mov al, 3h
    int 10h

galas:
    mov ah, 4ch                     ; baigiam programa ir griztam i os
    int 21h                         ;
  endp

 
param proc                          ; nuskaito parametrus
  
lea dx, ineil2		    ;¿
    mov ah, 0ah 		    ;³skaitome i÷ klavetûros
    int 21h			    ;Ù
    lea si, ineil2 		    ;¿dabar versime i÷ eil õ skaißiù
    inc si			    ;³tai daroma taip:
    xor ax, ax			    ;³ a := ord(s[1]) - ord('0');
    xor bx, bx			    ;³ if a = 0 then exit;
    xor cx, cx			    ;³ i := byte(s[0]);
    mov cl, [si]		    ;³ for i := 2 downto i do
    cmp cl, 0			    ;³	 begin
    je lauk			    ;³	   a := a * 10;
   ci2: 			    ;³	   c := ord(s[i])-ord('0');
    mul ten			    ;³	   a := a + c;
    inc si			    ;³	 end;
    mov dl, [si]		    ;³
    sub dl, '0'                     ;³  a - rezultatas
    add ax, dx			    ;³
    loop ci2			    ;³
   lauk: ret			    ;Ù

  endp


 ivedimas proc                      ; nuskaito eilute is klaviaturos
    mov dx, offset ineil            ;
    mov par,dx
    mov ah, 0ah                     ; skaitome is klaviaturos
    int 21h                         ;
    ret
  endp


  Hlinija proc                      ; bx, ax - x, y koordinates; cx - kiekis; dh - spalva
     push dx

     mul MAX_WIDTH
     add bx, ax
     mov di, bx

     pop dx
     mov al, dh

     rep stosb

     ret
  endp

  Vlinija proc                      ; bx, ax - x, y koordinates; cx - kiekis; dh - spalva
     push dx

     mul MAX_WIDTH
     add bx, ax
     mov di, bx

     pop dx

    vciklas:
     mov es:[di], dh
     add di, MAX_WIDTH
     loop vciklas

     ret
  endp

 
END