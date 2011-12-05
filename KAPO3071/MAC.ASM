include system.asm

BUFER_SIZE equ 3000
I_HANDLE   equ 0
O_HANDLE   equ 1


file STRUC
  handle  dw 0
  buf     db BUFER_SIZE-1 dup(0)
  bs      dw BUFER_SIZE
  bb      dw 0
  be      dw 0
  pabaiga dw 0
ENDS

rewrite macro filename, file_
  mov ah, 03ch
  lea dx, filename
  mov cx, 20h
  int 21h
  stderror
  mov file_.handle, ax
endm

writeblock macro file_, size
  local wrex

  mov ah, 040h
  mov bx, file_.handle
  lea dx, file_.buf
  mov cx, size
  push cx
  int 21h
  pop cx
  stderror
  cmp ax, cx
  je wrex
  fileerror
  wrex:
endm
  
writefilestr macro file_, str
  local nereikiafl
  mov cx, file_.bb
  mov ax, file_.bs
  sub ax, cx

  xor ch, ch
  mov cl, byte ptr str
  push cx
  cmp ax, cx
  ja nereikiafl
  flushmybuf file_
  nereikiafl:

  mov ax, ds
  mov es, ax

  lea di, file_.buf
  mov cx, file_.bb
  add di, cx
  lea si, str
  inc si
  pop cx
  push cx
  rep movsb

  pop cx
  mov ax, file_.bb
  add ax, cx
  mov file_.bb, ax

endm

flushmybuf macro file_
  local goodfl

  mov ah, 40h
  mov bx, file_.handle
  lea dx, file_.buf
  mov cx, file_.bb
  int 21h
  stderror
  mov file_.bb, 0
endm

closefile macro file_
  mov ah, 3eh
  mov bx, file_.handle
  int 21h
  stderror
endm

reset macro filename, file_
  mov ah, 3dh
  lea dx, filename
  mov al, 0
  int 21h
  stderror
  mov file_.handle, ax
endm

readblock macro file_, size
  mov ah, 3fh
  mov bx, file_.handle
  lea dx, file_.buf
  add dx, file_.be
  mov cx, size
  int 21h
  stderror

  mov bx, file_.be
  add bx, ax
  mov file_.be, bx
endm        

normalbuf macro file_
  local exnb
  cmp file_.bb, 0
  je exnb

  mov ax, ds
  mov es, ax

  mov ax, file_.bb
  mov cx, file_.be
  sub cx, ax
  push cx

  lea di, file_.buf
  mov si, di
  add si, file_.bb
  cld
  rep movsb 
  pop cx
  xor ax, ax
  mov file_.bb, ax
  mov file_.be, cx

  exnb:
endm

iseof macro file_
  local taip, ne, pabaiga
  CMP AX, 0
  je taip
  jmp ne
  ne:
       mov file_.pabaiga, 0
       cld
       mov ax, ds
       mov es, ax
       mov ax, file_.bb
       mov cx, file_.be
       sub cx, ax

       lea di, file_.buf
       add di, file_.bb
       mov al, 26
       repne scasb
       je taip

       jmp pabaiga
  taip:
       mov file_.pabaiga, 1
  pabaiga:
endm



readfilestr macro file_, eil
  local pabaiga, yra, nera, n_radau, n_neradau, n_geras, n_inc, y_did,y_maz

  cmp file_.pabaiga, 0
  je  yra
  jmp nera

  yra:         ; dar ne failo pabaiga

    mov cx, file_.be
    mov ax, file_.bb
    sub cx, ax
    cmp cx, 0ffh
    jb  y_maz
    jmp y_did
    y_maz:      ; per mazas paieskos buferis

      normalbuf file_
      mov cx, file_.bs
      sub cx, file_.be
      readblock file_, cx
      iseof file_
      jmp nera    ; jau nereikes skaityti

      y_did:
        jmp nera ; nereikia skaityti
      jmp pabaiga

  nera:
    mov dx, ds
    mov es, dx

    mov al, 10 ;ieskome enter
    lea di, file_.buf
    add di, file_.bb
    mov cx, file_.be
    sub cx, file_.bb
    cmp cx, 0ffh
    jb n_geras
      mov cx, 0ffh
    n_geras:
    push cx
    repne scasb
    je n_radau
    n_neradau:
      cld
      lea si, file_.buf
      add si, file_.bb
      lea di, eil
      inc di
      pop cx
      push cx
      rep movsb
      pop cx
      mov byte ptr eil, cl

      mov ax, file_.bb
      add ax, cx
      mov file_.bb, ax

      jmp pabaiga
    n_radau:
      pop cx
      cld
      ;cmp byte ptr es:[di-1], 10
      ;jne n_inc
      ;  inc di
      n_inc:
        lea si, file_.buf
        add si, file_.bb
        sub di, si
        mov cx, di
        lea si, file_.buf
        add si, file_.bb
        lea di, eil
        inc di
        push cx
        rep movsb
        pop cx

        mov ax, file_.bb
        add ax, cx
        mov file_.bb, ax
        mov byte ptr eil, cl
  pabaiga:
endm




