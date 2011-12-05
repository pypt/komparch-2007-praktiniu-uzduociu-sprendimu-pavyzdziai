.286
.model tiny
.stack 30000
include stdio.asm
include strings.asm

maximum equ 1000

readln macro eil
  lea dx, eil
  mov ah, 0ah   ; skaityti is kbd
  int 21h
endm

upcasestr macro eil
  local pabaiga, pradzia, ne

  lea di, eil
  inc di
  mov cl, eil
  xor ch, ch
  pradzia:
  mov al, byte ptr ds:[di]
  cmp al, 'a'
  jb ne
  cmp al, 'z'
  ja ne
    sub al, 32
    mov byte ptr ds:[di], al
  ne:
  inc di
  loop pradzia
  pabaiga:
endm

cdroot macro
  mov ah, 3bh   ; set cur. dir (cd)
  lea dx, liasas
  inc dx
  int 21h
endm

bin2str macro bin, str
  local galas,pr

  lea si, bin
  lea di, str
  inc di
  mov cx, 0
  pr:
  mov al, byte ptr ds:[si]
  cmp al, 0
  je galas
  inc cx
  mov ds:[di], al
  inc di
  inc si
  jmp pr
  galas:
  mov str, cl
endm
bin2str_r macro r1, r2, str
  local galas,pr
  push es
  mov ax, r1
  mov es, ax
  mov si, r2
  lea di, str
  inc di
  mov cx, 0
  pr:
  mov al, byte ptr es:[si]
  cmp al, 0
  je galas
  inc cx
  mov ds:[di], al
  inc di
  inc si
  jmp pr
  galas:
  mov str, cl
  pop es
endm


paramcount macro count
  local pradzia, pabaiga, cik1, cik11, cik2, cik22
  pradzia:
    push ds
    mov ax, PSP
    mov ds, ax
    xor dx, dx
    mov di, 80h
    xor ch, ch
    mov cl, byte ptr ds:[di]
    inc di

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
      pop ds
endm

paramstr macro n, eil
  local zodzio_p, pabaiga, gal_pabaiga
  push bp
  mov ax, PSP
  mov es, ax
  lea di, eil
  mov cx, n
  mov bp, 1
  mov si, Paramstr_o

  zodzio_p:
  push cx di si
  copyword_r bp
  pop si di cx
  cmp byte ptr eil, 0
  jne gal_pabaiga
  inc bp
  jmp zodzio_p
  gal_pabaiga:
  loop zodzio_p

  pabaiga:
  pop bp
endm


back_dir macro
  mov ah, 3bh
  lea dx, atgal
  int 21h
endm

palyginti macro n ; palygina es:di su ds:si
  PUSHA
  cld
  mov cx, n
  repe cmpsb
  POPA
endm

filedata struc
  fattribute db 0
  ftime      dw 0
  fdate      dw 0
  fsize      db 4 dup(0)
  fname      db 13 dup(0)
ends

insert_str macro eil, zodis, i
  mov ax, ds
  mov es, ax
  mov al, eil
  mov bl, zodis
  xor ah, ah
  xor bh, bh

  std
  lea si, eil
  add si, ax
  mov di, si
  add di, bx
;  inc di
  mov cx, ax
  sub cx, i
  inc cx
  rep movsb

  cld
  lea di, eil
  add di, i
  lea si, zodis
  inc si
  mov cx, bx
  rep movsb

  add ax, bx
  mov eil, al
endm

copymem macro m1, m2, n
  mov ax, ds
  mov es, ax
  mov di, m2
  mov si, m1
  mov cx, n
  cld
  rep movsb
endm

clearmem macro m1, n
  mov ax, ds
  mov es, ax
  mov di, m1
  mov cx, n
  cld
  xor al, al
  rep stosb
endm

set_dta macro dta ;dta = 128 baitai
  lea dx, dta
  mov ah, 1ah
  int 21h
endm

set_dta_r macro s, o
  mov dx, o
  push ds
  mov ax, s
  mov ds, ax
  mov ah, 01ah
  int 21h
  pop ds
endm

get_dta_r macro s, o
  mov ah, 02fh
  int 21h
  mov ax, es
  mov s, ax
  mov o, bx
endm

find_first macro attr, name, nerasta
  local nera, yra
  mov nerasta, 0
  mov cx, attr
  lea dx, name
  inc dx
  mov ah, 04eh
  int 21h
  jc  nera
  jmp short yra
  nera:
  mov nerasta, 1
  yra:
endm

find_next macro
  local nera, yra
  mov ah, 4fh
  int 21h
  jc  nera
  jmp short yra
  nera:
  mov nerasta, 1
  yra:
endm

num2str macro a, eil, kur, kiek
    local dar
    PUSHA

    mov ax, a
    xor bx, bx                       ; kiek tai bus raidziu
    lea si, eil                      ; ds:si rodys õ buf
    add si, kur
    mov cx, kiek
   dar:
    xor dx, dx                      ; nuvalomas dx (dx=0)
    div ten                         ; ax := ax div 10
    add dl, 30h                     ; dl := dl + 30h
    dec si                          ; si := si - 1  (si--)
    mov ds:[si], dl                 ; ds:si := dl
    inc bx
    loop dar
    POPA
endm


fill_str macro eil, kiek, kuo
  push ax di es cx

  mov ax, ds
  mov es, ax
  lea di, eil
  inc di
  mov cx, kiek
  mov al, kuo
  cld
  rep stosb

  pop cx es di ax
endm

convert_time macro k, eil
  pusha
  fill_str eil, 10, ' '
  mov si, k
  add si, 16h
  mov ax, word ptr ds:[si]
  push ax
  lea di, eil
  mov byte ptr ds:[di+3], ':'
  mov byte ptr ds:[di+6], '.'

  and ax, 0f800h
  shr ax, 11
  num2str ax, eil, 3, 2

  pop  ax
  push ax

  and ax, 07e0h
  shr ax, 5
  num2str ax, eil, 6, 2

  pop ax

  and ax, 01fh
  shl ax, 2
  num2str ax, eil, 9, 2

  mov byte ptr eil, 10
  popa
endm

convert_date macro k, eil
  pusha
  fill_str eil, 12, ' '
  mov si, k
  add si, 18h
  mov ax, ds:[si]
  push ax
  lea di, eil
  mov byte ptr ds:[di+5], '-'
  mov byte ptr ds:[di+8], '-'



  and ax, 0f800h
  shr ax, 9
  add ax, 1980
  num2str ax, eil, 5, 4

  pop  ax
  push ax

  and ax, 01e0h
  shr ax, 5
  num2str ax, eil, 8, 2

  pop ax

  and ax, 01fh
  num2str ax, eil, 11, 2

  mov byte ptr eil, 12
  popa
endm

convert_size macro k, eil
    local dar, paz, nedar, div_ciklas, c_b, c_e, l1, l2, l3, DAR_AT
    PUSHA

    fill_str eil, 12, ' '

    mov si, k
    mov dx, ds:[si+1ah]
    mov ax, ds:[si+1ah+2]
    lea si, eil                      ; ds:si rodys õ buf
    add si, 10

   dar:
   xor bx, bx
   xor cx, cx
   ; dx:ax div 10
      mov  di, 32-4
      c_b:

      push ax

      SHL BX, 1
      RCL CX, 1

     DAR_AT:
      mov bp, ax
      and ax, 1111100000000000b
      shr ax, 11



      cmp ax, 1010b
      jb l1
      sub ax, 1010b
      shl ax, 11
      and bp, 0000011111111111b
      or  bp, ax
      pop ax
      mov ax, bp
      push ax

      ADD bx, 1
      adc cx, 0

     ; stc
       JMP DAR_AT
     ; jmp l2
      l1:
     ; clc
     ; l2:
      pop ax

     ; SHL bx, 1
     ; rcl cx, 1

      cmp di, 1
      je  l3
      shl dx, 1
      rcl ax, 1
      l3:

      dec di
      cmp di, 0
      je  c_e
      jmp c_b
      c_e:


    ; end div
    ; uzrasome

;      mov dx, di
;      sub dx, bx

      shr ax, 11
      add al, 30h                     ; dl := dl + 30h
      dec si                          ; si := si - 1  (si--)
      mov ds:[si], al                 ; ds:si := dl

    ; atnaujiname

      mov ax, cx
      mov dx, bx

      cmp ax, 0
      je  paz
      jmp dar
      paz:
      cmp dx, 0
      je  nedar
      jmp dar
      nedar:

    mov byte ptr eil, 12
    POPA
endm

view_filedata macro k
  local cik_p, cik_pab, dalinasi
  push di si

  mov ax, ds
  mov es, ax
  mov ax, k
  push ax

; write name

  mov si, k
  add si, 1eh
  lea di, eil
  inc di
  mov cx, 13
  cld
  rep movsb
  mov byte ptr eil, 13
  ;;stdwrite eil

; write attr

  pop ax
  push ax
  mov si, ax
  add si, 15h
  mov al, byte ptr ds:[si]
  xor ah, ah

  lea di, eil_tmp
  add di, 4
  fill_str eil_tmp, 14, ' '
  mov byte ptr eil_tmp, 14

  lea si, attr

  mov cx, 8
  cik_p:

    div two
    cmp ah, 1
    jne dalinasi
    mov bx, cx
    mov bl,  byte ptr ds:[si+bx]
    mov byte ptr ds:[di], bl
    dalinasi:

    inc di
    loop cik_p
  cik_pab:
  ;;stdwrite eil_tmp

   mov bl, byte ptr eil
   xor bh, bh
   mov bp, bx
   insert_str eil, eil_tmp, bp

  pop ax
  push ax

 ; write time

  convert_time ax, eil_tmp
  mov bl, byte ptr eil
  xor bh, bh
  mov bp, bx
  insert_str eil, eil_tmp, bp
  ;;stdwrite eil

  pop ax
  push ax

; write data


  convert_date ax, eil_tmp
  mov bl, byte ptr eil
  xor bh, bh
  mov bp, bx
  insert_str eil, eil_tmp, bp
  ;;stdwrite eil

  pop ax
; write size

  convert_size ax, eil_tmp
  mov bl, byte ptr eil
  xor bh, bh
  mov bp, bx
  insert_str eil, eil_tmp, bp
  clc
  stdwrite eil

  writeln
pop si di
endm

duomenys segment
  stdfiles


  dabartinis_katalogas filedata maximum dup(?)
  file_count dw 0
  max_file   dw maximum

  my_dta  db 128 dup(0)
  tmp_dta db 128 dup(0)
  dta_size dw 128
  ko db 3, '*.*',0
  ko_attr dw 0ffh
  nerasta dw 0
  rodykle_sar dw 0
  file_data_size dw 22
  eil     string
  eil_tmp string
  eil_temp string
  two  db 2
  fap  db 'File name      Attribute  Time      Date       Size',13, 10, '$'
  fap_ db '-------------  ---------  --------  ---------- ----------',13, 10,'$'
  attr      db '   ADVSHR'
  atgal     db '..',0
  old_dta_r dw 2 dup(0)
  liasas    db 1, '\',0
  Kelias    db 3, "?:\", 100 dup(0)
  Pradinis_kelias db 100 dup(0)
  Pradinio_kelio_ilgis db 0
  Sudisku    db 0
  PSP        dw 0
  Paramstr_o dw 80h
  Taspatsdiskas db 1
  Koksdiskas  db ' '
  eilzon db 2, 2 dup(' ')

  buvesdiskas db 0
  buveskeliasstr db 100 dup(0)
  buveskelias db 100 dup(0)

  aprasymas db 'Uýduotis nr 4: Darbas su katalogais',13,10
            db 'Daroma taip: ',13,10
            db '  Pagal nurodyta kataloga "isvalomas" diskas',13,10
            db '  u4 {katalogas}',13,10,13,10
            db 'Copyrigth (c) By Irmantas Naujikas'     ,13,10,13,10,'$'
  end_msg   db 13,10,'Darbo Pabaiga ..... exiting to os....',13,10,13,10,'$'
  Blogi_param db 13,10,'Blogi parametrai $',13,10
  ok        db '  ok  ', 13, 10, '$'
duomenys ends

kodas segment
  assume cs: kodas, ds: duomenys
  begin:
    mov bx, ES
    mov ax, duomenys
    mov ds, ax
    mov PSP, bx

    write aprasymas

    paramcount ax
    cmp ax, 1
    je  geri_param
    write blogi_param
    jmp prog_pab
    geri_param:

    mov ah, 19h ; get curent disk
    int 21h
    mov buvesdiskas, al
    add al, 'A'
    mov koksdiskas, al
    lea di, kelias
    mov byte ptr ds:[di+1], al

    mov ah, 47h ; get current dir
    mov dl, buvesdiskas
    inc dl
    lea si, buveskelias
    int 21h


    paramstr   1, Pradinis_kelias
    cmp byte ptr pradinis_kelias, 2
    jb  tas_pats
    lea di, pradinis_kelias
    cmp byte ptr ds:[di+2] ,':'
    jne tas_pats
      mov al, byte ptr ds:[di+1]
      cmp al, koksdiskas
      jne t_1
      jmp su_disku
      t_1:
      mov taspatsdiskas, 0
      mov sudisku, 1
      jmp su_disku
    tas_pats:
    bin2str buveskelias, buveskeliasstr
    CMP BUVESKELIASSTR, 0
    JNE GERAS_KELIAS
    JMP BLOGAS_KELIAS
    GERAS_KELIAS:
      MOV AL, PRADINIS_KELIAS
      XOR AH, AH
      LEA SI, PRADINIS_KELIAS
      ADD SI, AX
      CMP BYTE PTR DS:[SI], '\'
      JE NEREIKIA_LIASO
        insert_str pradinis_kelias, liasas, 1
      NEREIKIA_LIASO:
      insert_str pradinis_kelias, buveskeliasstr, 1
      BLOGAS_KELIAS:
      insert_str pradinis_kelias, kelias, 1
    su_disku:
    mov al, pradinis_kelias
;    inc al
    mov pradinio_kelio_ilgis, al
    INC AL

    push bp
      xor ah, ah
      mov bp, ax

      MOV AL, PRADINIS_KELIAS
      XOR AH, AH
      LEA SI, PRADINIS_KELIAS
      ADD SI, AX
      CMP BYTE PTR DS:[SI], '\'
      JE NEREIKIA_LIASO_1
         insert_str pradinis_kelias, liasas, bp
         MOV AX, BP
         inc bp
         mov pradinio_kelio_ilgis, al
      NEREIKIA_LIASO_1:
    insert_str pradinis_kelias, ko, bp
    pop bp

    writeln
    write fap
    write fap_
    call surasyti_kataloga
    write fap_
    writemsg 'Failu kiekis:      '
    word2str file_count, eil
    stdwrite eil
    writeln
    write fap_
    readln eilzon

    cmp file_count, 0
    ja atrodo_geras
      writeln
      writemsg "Atrodo jusu nurodytas katalogas tuscias/ar neegzistuoja !!!!"
      JMP PROG_PAB
    atrodo_geras:

    mov al, pradinio_kelio_ilgis
    mov pradinis_kelias, al
    upcasestr pradinis_kelias

    cdroot
    call apeiti_diska

    atstatyti:
    mov ah, 0eh ; set current disk
    mov dl, koksdiskas
    int 21h

    mov ah, 3bh ; set curent disk
    lea dx, buveskelias
    int 21h

    prog_pab:
    write end_msg
    halt

apeiti_diska proc near ; cia viskas atliekama
  sub sp, 130;/2+1
;  mov ax, sp
;  mul two
  mov bp, SP

  get_dta_r ax, bx
  push ax bx
  set_dta_r ss, bp
  find_first ko_attr, ko, nerasta
  ciklo_pradzia_1:
    cmp nerasta, 1
    jne toliau_1
    jmp ciklo_pabaiga_1
    toliau_1:
;dta paruosiamas kitam uzpildymui
    mov si, bp
    mov di, si
    add si, 01eh

    mov dh, byte ptr ss:[si-9]
    and dh, 00011000b
    cmp dh, 0
    je tinka_1
    jmp netinka_1
    cmp byte ptr ss:[si], '.'
    jne tinka_1
    jmp netinka_1
    tinka_1:
       pusha
       ; copy i tmp_dta
       push ds
       mov ax, ds
       mov es, ax
       mov ax, ss
       mov ds, ax
       lea di, tmp_dta
       mov si, bp
       mov cx, 128
       cld
       rep movsb
       pop ds
       lea di, tmp_dta
       ; - jau copy end

       mov cx, file_count
       lyg_b:
         push cx
         lea di, tmp_dta
         PUSH DI
         add di, 1eh
         lea si, dabartinis_katalogas
         dec cx
         mov ax, cx
         mul file_data_size
         add ax, 9h
         add si, ax
         palyginti 13
         POP DI
         je  radau_faila
         jmp neradau_failo
         radau_faila:
         lygios kelias, pradinis_kelias, neradau_failo, gerai
         gerai:
         ; ar trinti ?
             pop cx
             writeln
             writemsg "Radau panasu faila:"
             writeln
             writemsg "-------------------"
             writeln
             push SI
             view_filedata DI
             pop SI
             push si
             SUB SI, 1eh
             view_filedata SI
             writemsg "-------------------"
             writeln
             writemsg "1) yra kataloge: "
             stdwrite pradinis_kelias
             writeln
             writemsg "2) yra kataloge: "
             stdwrite kelias
             writeln
             lauk_ats:
               writemsg "Trinti (2) ? (T/N)..."
               readln eilzon
               lea di, eilzon
               cmp byte ptr ds:[di+1], 1
               jne kartok
               cmp byte ptr ds:[di+2], 'T'
               je ats
               cmp byte ptr ds:[di+2], 'N'
               je ats
               kartok:
               jmp lauk_ats
             ats:
             writeln
             pop si
             cmp byte ptr ds:[di+2], 'T'
             je trinti
             jmp netrinti
             trinti:
               writemsg "Trinu   !!!"
               mov dx, si
               mov ah, 41h
               int 21h
               jc nepasiseke
               jmp tr_end
               nepasiseke:
                 writemsg "Negaliu istrinti!!!"
                 writeln
             netrinti:
               writemsg "Netrinu !!!"
               writeln
             tr_end:
           jmp lyg_e
         neradau_failo:
         pop cx
         dec cx
         cmp cx, 0
         je  lyg_e
         jmp lyg_b
       lyg_e:

       ;view_filedata di
       popa
  netinka_1:
;patikrinu ar tai ne katalogas
    cmp byte ptr ss:[si], '.'
    jne tai_gerai
    jmp ne_kat
    tai_gerai:
    mov dh, byte ptr ss:[si-9]
    and dh, 00010000b
    cmp dh, 0
    jne kat
    jmp ne_kat
    kat:
       ; dabar pereinu i kita kataloga
      mov al, kelias
      xor ah, ah
      push ax
      push ds

      mov ax, ss
      mov ds, ax
      mov dx, bp
      add dx, 1eh
      mov ah, 3bh
      int 21h
      pop ds

      pop ax
      push ax
      push bp
      mov bp, ax
      inc bp
      bin2str_r ss, dx, eil_temp
      insert_str kelias, eil_temp, bp
      mov al, kelias
      xor ah, ah
      inc ax
      mov bp, ax
      insert_str kelias, liasas, bp
      pop bp

      pusha
      call apeiti_diska
      popa

      pop ax
      mov kelias, al

      back_dir
      mov nerasta, 0
    ne_kat:
 ;clearmem si, 13
    push ds
    mov ax, ss
    mov ds, ax
    mov si, bp
    add si, 1eh
    clearmem si, 13
    pop ds
 ;dta apdorojimas baigtas
  find_next
  jmp ciklo_pradzia_1
  ciklo_pabaiga_1:

;  back_dir
  pop bx ax
  set_dta_r ax, bx
  add sp, 130;/2+1
  ret
endp

surasyti_kataloga proc near
  get_dta_r ds:[old_dta_r], ds:[old_dta_r+2]

  set_dta my_dta

  find_first ko_attr, pradinis_kelias, nerasta

  ciklo_pradzia:
  cmp nerasta, 1
  jne toliau
  jmp ciklo_pabaiga
  toliau:

;my_dta paruosiamas kitam uzpildymui

  lea si, my_dta
  mov di, si
  add si, 01eh

  mov dh, byte ptr ds:[si-9]
  and dh, 00011000b
  cmp dh, 0
  je tinka
  jmp netinka
  cmp byte ptr ds:[si], '.'
  jne tinka
  jmp netinka
  tinka:

  view_filedata di
  inc file_count

  lea di, dabartinis_katalogas
  mov ax, rodykle_sar
  add di, ax
  push si
  sub  si, 9
  copymem si, di, 22
  mov ax, rodykle_sar
  add ax, 22
  mov rodykle_sar, ax
  pop si


  netinka:
  clearmem si, 13

;my_dta apdorojimas baigtas
 ; mov ah, 4fh
 ; int 21h
 ; jc ciklo_pabaiga

  find_next

  jmp ciklo_pradzia
  ciklo_pabaiga:

  set_dta_r ds:[old_dta_r], ds:[old_dta_r+2]

  ret
endp

kodas ends

end begin
