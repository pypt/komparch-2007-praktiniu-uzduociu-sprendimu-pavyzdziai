include stdio.asm

word2str macro a, eil                 ; word(A) vercia i eil
    local dar
    mov ax, ds
    mov es, ax
    lea di, eil
    mov cx, 7
    mov al, 0
    rep stosb 
   
    mov ax, a
    xor bx, bx                       ; kiek tai bus raidziu
    lea si, eil                      ; ds:si rodys õ buf
    add si, 6
   dar:
    xor dx, dx                      ; nuvalomas dx (dx=0)
    div ten                          ; ax := ax div 10
    add dl, 30h                     ; dl := dl + 30h
    dec si                          ; si := si - 1  (si--)
    mov ds:[si], dl                 ; ds:si := dl
    inc bx
    cmp ax, 0                       ; if ax > 0
    ja dar                          ; then goto dar

    mov byte ptr eil, 6
endm

convertstr macro str, binstr
  local taip, ne, taip13, ne13
  mov ax, ds
  mov es, ax

  xor ch, ch
  mov cl, byte ptr str
  lea di, str
  inc di
  cld
  mov al, 10
  repne scasb
  je taip
  jmp ne
  taip:
  sub di, 2
  cmp byte ptr ds:[di], 13
  je taip13
  jmp ne
  taip13:
  sub di, 1
  jmp ne
  ne13:
  ne:
  mov cx, di
  lea di, str
  sub cx, di
  mov dx, cx

  lea di, binstr
  lea si, str
  inc di
  inc si
  rep movsb
  mov byte ptr ds:[di], 0
  mov byte ptr binstr, dl
endm

copystr macro str1, str2
  mov ax, ds
  mov es, ax

  lea si, str1
  lea di, str2
;  mov cx, (0ffh+2)/2
  mov cl, str1
  xor ch, ch
  inc cx
  cld
  rep movsb
endm

wordscount macro eil, count
  local pradzia, pabaiga, cik1, cik11, cik2, cik22
  pradzia:
    xor dx, dx
    lea di, eil
    inc di
    xor ch, ch
    mov cl, byte ptr eil
    inc cx

    cik1: ;praleidziu tarpus
      cmp cx, 0
      je pabaiga
      cmp byte ptr ds:[di], ' '
      je cik11
      inc dx
      jmp short cik2
      cik11:
      inc di
      dec cx
      jmp short cik1

    cik2: ;praleidziu zodi      
      cmp cx, 0
      je pabaiga
      cmp byte ptr ds:[di], ' '
      jne cik22
      jmp short cik1
      cik22:
      inc di
      dec cx
      jmp short cik2

  pabaiga:
  mov count, dx
endm

normalstr macro str
  xor ah, ah
  mov al, byte ptr str
  inc ax
  lea di, str
  add di, ax
  mov byte ptr ds:[di], 0
endm

copypart macro eil1, eil2, n, m
  mov ax, ds
  mov es, ax

  lea si, eil1
  lea di, eil2
  add si, n

  mov cx, m
  mov dx, m
  rep movsb
  mov byte ptr eil2, dl
endm

deletepart macro eil, n, m
  local cik
  mov ax, ds
  mov es, ax

  mov cx, m
  mov al, eil
  xor ah, ah

  cik:
    dec ax
   
    push cx
    mov cl, eil
    xor ch, ch
    sub cx, n

    lea di, eil
    add di, n
    mov si, di
    inc si
    rep movsb    
   
    pop cx
    loop cik
  mov eil, al     
endm

strlength macro eil, a
  mov al, byte ptr eil
  xor ah, ah
  mov a, ax
endm

copyword macro eil1, eil2, n
  local prad, pad
  mov ax, ds
  mov es, ax
  
  lea si, eil1
  lea di, eil2
  inc di
  add si, n
  mov cx, 1
  xor dh, dh
  mov dl, byte ptr eil1
  prad:
    cmp dx, 0
    je  pab
    mov al, byte ptr ds:[si]
    cmp al, ' '
    je  pab
      inc cx 
      mov byte ptr ds:[di], al
      inc di
      inc si
      dec dx
    jmp short prad
  pab:
  mov byte ptr ds:[di], ' '
  mov byte ptr eil2, cl
endm

copyword_r macro n
  local prad, pad

  push di
  inc di
  mov cx, 0
  xor dh, dh
  mov dl, es:[si]
  dec dl
  add si, n
  prad:
    cmp dx, 0
    je  pab
    mov al, byte ptr es:[si]
    cmp al, ' '
    je  pab
      inc cx 
      mov byte ptr ds:[di], al
      inc di
      inc si
      dec dx
    jmp short prad
  pab:
  mov byte ptr ds:[di], ' '
  pop di
  mov byte ptr ds:[di], cl
endm


lygu macro eil1, eil2, i, lab1, lab2
  local taip, ne
  mov ax, ds
  mov es, ax

  mov cl, eil2
  xor ch, ch

  lea di, eil1  
  lea si, eil2
  inc si 
  add di, i
  cld 
  repe cmpsb
  jne ne
  jmp lab1
  ne:
  jmp lab2
endm

lygios macro eil1, eil2, lab1, lab2
  local taip, ne
  mov ax, ds
  mov es, ax

  mov dl, eil1
  xor dh, dh
  mov cl, eil2
  xor ch, ch

  cmp cx, dx
  jne ne

  lea di, eil1  
  lea si, eil2
  inc si 
  inc di
  cld 
  repe cmpsb
  jne ne
  jmp lab1
  ne:
  jmp lab2
endm


insertstr macro eil, zodis, i
  local cik1
  mov ax, ds
  mov es, ax
  cld
  mov al, eil
  xor ah, ah
  xor bh, bh
  mov bl, zodis

  mov cl, al
  add cl, bl
  mov eil, cl
;  
  std
  lea di, eil
  add di, ax
  mov si, di
  add di, bx

 ; lea si, eil
 ; add si, i
 ; add si, bx
  mov cx, ax
  sub cx, bx
  inc cx
  rep movsb
;  
  cld

  lea di, eil
  add di, i
  lea si, zodis
  inc si
  mov cx, bx
  rep movsb
endm
