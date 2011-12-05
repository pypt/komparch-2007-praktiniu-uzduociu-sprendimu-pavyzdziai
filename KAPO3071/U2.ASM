.286
.model tiny
.stack 1000
include stdio.asm
include strings.asm

duomenys segment
  stdfiles

  f file <I_HANDLE,,,,,>
  t file <O_HANDLE,,,,,>

  aprasymas db 'Uýduotis nr 2: Darbas su eilutemis',13,10
            db 'Daroma taip:',13,10,13,10
            db 'I÷ duotos eilutós reikia i÷mesti pasikartojancius ýodýius',13,10
            db 'Darbas baigiamas kaip pasiekiama failo pabaiga', 13, 10
            db '(i÷ klavetûvos tai bus ctrl-z arba F6)', 13, 10, 13, 10
            db 'Copyrigth (c) By Irmantas Naujikas'     ,13,10,13,10,'$'
  end_msg   db 13,10,'Darbo Pabaiga ..... exiting to os....',13,10,13,10,'$'
  prasymas  db 'ôveskite eilute: ',13,10,'$'
  pertvarkiau db 'Pertvarkyta eilute: ',13,10,'$'
  ok        db '  ok  ', 13, 10, '$'
  eil       string
  zodis     string
  ilgis     dw 0
  i         dw 0   
  j         dw 0
duomenys ends

kodas segment
  assume cs: kodas, ds: duomenys
  begin:
    mov ax, duomenys
    mov ds, ax

    write aprasymas
    cik_pr:

     write prasymas
     writemsg ">" 
     stdreadln eil

     cmp byte ptr eil, 1
     ja ras
     jmp neras
     ras:  
       writeln
       call pertvarkymas
       writeln
       write pertvarkiau
     neras:
     writemsg ">" 
     stdwrite eil
     writeln    
     writeln
     noweof stdin, cik_pr, cik_pab
    cik_pab:
    write end_msg
    halt

proc pertvarkymas near
  convertstr eil, eil

  xor ah, ah
  mov al, byte ptr eil
  inc ax
  lea di, eil
  add di, ax  
  mov byte ptr ds:[di], ' ' 
  mov eil, al
  
  mov ilgis, ax
  mov i, 1
  cik:
    mov ax, ilgis
    cmp i, ax
    jb iter
    je iter
    jmp cikpab
    iter:
;----iteracijos pradzia
    copyword eil, zodis, i
    cmp byte ptr zodis, 1
    ja rastas
    jmp iterpab
    rastas:
      writemsg "  ?? Is eilutes salinu pasikartojancius zodius: '"
      stdwrite zodis
      writemsg "'"
      writeln
        mov ax, i
        inc ax
        mov j, ax 
        for2:
          lea di, eil
          add di, j
          dec di
          cmp byte ptr ds:[di], ' '
          je gal
          jmp nelygu
          gal:
          
          mov ax, j
          mov bx, ilgis
          xor ch, ch
          mov cl, zodis
          sub bx, cx
          inc bx

          cmp ax, bx
          jb iter2
          je iter2
          jmp endfor2
          iter2: 
            lygu eil, zodis, j, taiplygu, nelygu
            taiplygu:
              writemsg " ++ radau  dar viena '"
              stdwrite zodis
              writemsg "'"
              writeln
              xor dh, dh
              mov dl, zodis
              deletepart eil, j, dx
              xor ah, ah
              mov al, byte ptr eil
              mov ilgis, ax
              jmp for2
            nelygu:
            inc j
            jmp for2
        endfor2:
      mov bl, zodis
      xor bh, bh
      dec bx
      mov ax, i
      add ax, bx
      mov i, ax
;----iteracijos pabaiga
    iterpab:
    inc i
    jmp cik
  cikpab:

  mov ax, ilgis
  dec ax
  mov byte ptr eil, al
  ret
endp 

kodas ends

end begin


