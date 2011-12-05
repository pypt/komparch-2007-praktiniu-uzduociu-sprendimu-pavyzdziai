.286
.model tiny
.stack 1000
include stdio.asm

duomenys segment
  stdfiles

  f file <I_HANDLE,,,,,>
  t file <O_HANDLE,,,,,>

  aprasymas db 'Uýduotis nr 3: Darbas su failais',13,10
            db 'Daroma taip:',13,10,13,10
            db 'Yra input filas ir output filas. Reikia surasti ilgiausia',13,10
            db '(pagal zodziu sk.) input failo eilute ir ja patalpinti i', 13, 10
            db 'n-taja output failo eilute (n=tos eil. zodziu ilgis)', 13, 10, 13, 10
            db 'Copyrigth (c) By Irmantas Naujikas'     ,13,10,13,10,'$'
  end_msg   db 13,10,'Darbo Pabaiga ..... exiting to os....',13,10,13,10,'$'
  msg1      db 'ôveskite input  failo varda: ', '$'
  msg2      db 'ôveskite output failo varda: ', '$'
  skaitau   db 'Dabar vyksta skaitymas .... ', '$'
  rasau     db 'Dabar vyksta naujo failo kurimas .... ', '$'
  ok        db '  ok  ', 13, 10, '$'
  vert      db '-\|/'
  back      db 8,'$'
  temp      db 0,'$'
  i         dw 0
  imod      dw 4
  fn1       string
  fn2       string
  eil       string  
  maxeil    string
  eil_temp  string
  maxnr     dw 0
  eilnr     dw 0
  max       dw 0
  dabar     dw 0
  ismesta   dw 0
  j         dw 0
  rodf      dw 0
  rodt      dw 0
duomenys ends

kodas segment
  assume cs: kodas, ds: duomenys
  begin:
    mov ax, duomenys
    mov ds, ax

    write aprasymas
    write msg1
    stdreadln fn1
    write msg2
    stdreadln fn2
    stdwriteln

    convertstr fn1, fn1
    convertstr fn2, fn2

; cia debuginimiui
;stdwrite fn1
;stdwriteln
;stdwrite fn2
;stdwriteln

    stdwriteln
    write skaitau
    reset fn1, f
    mov eilnr, 0
    sk_pr:
      call vert_update

      readfilestr  f, eil
      cmp byte ptr eil, 0
      jne nene
      jmp galgalas
      nene:


      mov ax, eilnr
      inc ax
      mov eilnr, ax

      convertstr eil, eil_temp
      wordscount eil_temp, dabar
      mov ax, dabar
      cmp ax, max
      ja tinka
      jmp netinka
      tinka:
        mov max, ax
        copystr eil, maxeil
        mov ax, eilnr
        mov maxnr, ax
      netinka:
      galgalas:
      noweof f, sk_pr, sk_pab
    sk_pab: 
    closefile f
    write ok
    stdwriteln
    writemsg 'Ilgiausia eilute (pagal zodziu skaiciu):'
    writeln
    stdwrite maxeil
    writeln
    writeln
    writemsg 'Jos ilgis (zodziais) yra = '
    word2str max, eil_temp
    stdwrite eil_temp
    writeln
    writemsg 'Ji yra eiluteje '
    word2str maxnr, eil_temp
    stdwrite eil_temp
    writeln
    writemsg 'Is viso faile yra eiluciu '
    word2str eilnr, eil_temp
    stdwrite eil_temp
    writeln
    writeln
    write rasau

    reset   fn1, f
    rewrite fn2, t

    mov rodf, 0
    mov rodt, 0

    mov ax, max
    dec ax
    mov max, ax

    ra_pr:     
      call vert_update

      readfilestr  f, eil

      mov ax, rodf
      inc ax
      mov rodf, ax
      
      mov ax, rodt
      cmp max, ax
      je  iterpimas
      jmp toliau
      iterpimas:
        writefilestr t, maxeil
        mov ax, rodt
        inc ax
        mov rodt, ax
      toliau:

      mov ax, maxnr
      cmp rodf, ax
       jne rasyk
       jmp nerasyk
      rasyk:
          writefilestr t, eil
          mov ax, rodt
          inc ax
          mov rodt, ax
          mov al,  byte ptr eil
          xor ah, ah
          lea di, eil
          add di, ax
          cmp byte ptr ds:[di], 10
          je nerasyk
          parasykeoln:
          writefilestr t, streoln
      nerasyk:
      noweof f, ra_pr, ra_pab
    ra_pab:

    arpakanka:
    mov ax, rodt
    mov bx, max
    inc bx
    cmp ax, bx
    jb  nepakanka
    jmp pakanka
    nepakanka:
      mov ax, rodt
      cmp max, ax
      je  iter
      jmp rasyti_eoln
      iter:
        writefilestr t, maxeil
        mov ax, rodt
        inc ax
        mov rodt, ax
        jmp arpakanka
      rasyti_eoln:
        writefilestr t, streoln
        mov ax, rodt
        inc ax
        mov rodt, ax
        jmp arpakanka
    pakanka:

    flushmybuf t
    closefile f
    closefile t 
    write ok

    write end_msg
    halt

  vert_update:
      lea di, vert
      mov bx, i
      mov al, ds:[di+bx]
      mov byte ptr temp, al
      write temp
      write back
      mov ax, i
      inc ax
      xor dx, dx
      div imod
      mov i, dx
      ret

kodas ends

end begin


