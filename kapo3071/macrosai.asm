write Macro eilute
  mov ah, 09h
  lea dx, eilute
  int 21h
endm

writeln Macro
  mov dl, 13
  mov ah, 02h
  int 21h
  mov dl, 10
  int 21h
endm

halt Macro
  mov ah, 4ch
  int 21h
endm

fileerror Macro
  write fileerrormsg
  halt
endM

stderror Macro pav
  jnc pav
  fileerror
  pav:
endM

openfileread Macro name, handle
  mov ah, 3dh
  lea dx, name
  xor al, al
  int 21h
  stderror exop
  mov handle, ax
endM

closefile Macro handle
  mov ah, 03eh
  mov bx, handle
  int 21h
  stderror excl
endm

readbuf Macro Handle, buf, from, size, pab
  mov ah, 3fh
  mov bx, handle
  lea dx, buf
  add dx, from
  mov cx, size
  int 21h
  stderror exrb
  cmp ax, 0
  jne exrbm
  mov word ptr pab, 1
  exrbm:
endm

readln Macro handle, buf, rodb, rode, pab, bufsize, eil
  mov cx, rode
  mov dx, rodb
  sub cx, dx
  cmp cx, 200
  jl  read
  jmp exread
 read:
  cmp word ptr pab, 1
  je exread

  mov ax, rodb
  mov cx, rode
  sub cx, ax
  inc cx
  mov dx, cx
  lea di, buf
  mov si, di
  add si, rodb
  dec si
  rep movsb
  mov cx, dx
  mov rodb, 1
  mov rode, cx
  dec cx
  mov rode, 5000
  readbuf handle, buf, cx,rode, pab
  mov rode, ax

 exread:
  clc
  cld

  mov al, 10
  mov bx, rodb
  dec bx
  mov cx, rode
  sub cx, bx
  inc cx
  mov dx, cx
  lea di, buf
  add di, bx
  mov si, di

  cmp cx, 200
  jl gerai
  mov cx, 200
  gerai:
            
  repe scasb

  mov ax, dx
  sub ax, cx

  mov byte ptr eil, al


  lea si, buf
  add si, rodb
  dec si
  mov cx, ax
  lea di, eil
  inc di
  rep movsb
endm



