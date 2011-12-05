Title 3 uzduotis

.model small
.stack 1000
.data
  eil     db 'Iveskite skaiciuas 2 laipsni: $'  
  ineil   db 20, 21 dup(0)
  
  outeil  db 50 dup (0)              ;  ats. formavimo buf.
  outeile db '$'                     ;
  buf     db 10 dup(0)
  bufe    db '$'
  ten 	  dw 10

.code

  mov ax,@data
  mov ds, ax

  mov dx, offset eil
  mov ah, 09h
  int 21h

  mov dx, offset ineil      ; ivedam skaiciu
  mov ah, 0ah
  int 21h
    
  mov si, offset ineil	    ; suzinom eilutes ilgi	
  mov al, [si+1]
  mov ah, 0    

  mov si, offset ineil      ; eilute konvertuojam i skaiciu
  add si, 2
  mov dx, 0
   
kartoti:
  cmp dl, 0
  je nedauginti
  mov ax, dx
  mul ten
  mov dx, ax
  nedauginti:
  mov ah, ds:[si]
  sub ah, 30h  
  add dl, ah
  inc si
  loop kartoti    
    
  ;turime ivesta skaiciu registre dx

  mov si, offset ineil
  add si, 2
  mov cx, 19
  ciklas:
  mov es:[si], ' '
  
  loop ciklas
   
  inc 
  mov es:[si], bl
  
  mov dx, offset ineil
  mov ah, 09h
  int 21h
  



galas:
  mov ah, 4ch
  int 21h

;proceduros
writeln proc
  mov dl, 0dh                     ;
  mov ah, 06h                     ; uzrasome ant ekrano #13 #10
  int 21h                         ;
  mov dl, 0ah                     ;
  int 21h                         ;
  ret
  endp

ivedimas proc                     ; nuskaito eilute is klaviaturos
  mov dx, offset ineil            ;
  mov ah, 0ah                     ; skaitome is klaviaturos
  int 21h                         ;
  ret
  endp

writeskaicius proc                 ; isveda ax i ekrana
  lea si, buf			    ; is pradziu isvalom buferi
  mov bl, ' '
  mov bh, 0
  val:
  mov [si], bl
  inc si
  inc bh
  cmp bh, 10
  jl  val
  lea si, bufe                    ; ds:si rodys i bufe
  dar:				    ; repeat ... (ax > 0)	
  xor dx, dx                      ; nuvalomas dx (dx=0)
  div ten                         ; ax := ax div 10
  add dl, 30h                     ; dl := dl + 30h
  dec si                          ; si := si - 1  (si--)
  mov [si], dl                    ; ds:si := dl
  cmp ax, 0                       ; if ax > 0
  jg dar                          ; then goto dar
  lea dx, buf                     ; ds:dx rodys i buf
  mov ah, 9h                      ; spec. funkcija isvedimui
  int 21h                         ; i ekrana
  ret
  endp
;proceduros
END
