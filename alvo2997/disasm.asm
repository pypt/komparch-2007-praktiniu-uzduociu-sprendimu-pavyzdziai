.Model Small
.Stack 100h
.Data
  eof db '0'
  zero db '0'
  plus db '+'
  minus db '-'
  raide_h db 'h'
  dvitaskis db ':'
  skliaustas1 db '['
  skliaustas2 db ']'
  kablelis db ', '
  visokie db '1$cl$ax$al$'
  tarpas db '     '
  nextln db 13, 10, '$'
  noopk db 'Yra naeatpazintu komandu!$'
  noopkfile db 'Truksta failo AsmOpk.txt$'
  nofile db 'Tokio failo nera!$'
  byteptr db 'byte ptr '
  wordptr db 'word ptr '
  opkfile db 'asmopk.txt', 0
  handler dw ?
  handler2 dw ?
  buffer db ?
  buffer2 dw ?
  byte1 db 8 dup(?)
  byte2 db 8 dup(?)
  byte3 db 8 dup(?)
  bytecount dw 0
  flag db ?
  papildomas db ?              ; gal prireiks
  MODELIS db '.Model Small',13, 10, '.Stack $'
  PRADZIA db '.Code', 13, 10, '   $'
  GALAS db 'End $'
;-------------------------------------------------------------------
  register1 db 3 dup (?)       ;pirmo reg textine israiska
  register2 db 3 dup (?)       ;antro reg textine israiska
  constreg db ?                ;'A'-akamuliatorius 'S' segmento registras
  komanda db 10 dup (?)        ;komandos textine israiska
  poslinkis db 4 dup (?)       ;HEX poslinkio reg textine israiska
  kodadr dw ?                  ;sablono pradzios adresas
  vienetas db ?                ;komandos antras operandas vienetas
  len dw ?
  attrFAR db ?
  addopk db 'n'
  wordopk db 'n'
  direction db '0'             ;sablono laukas d
  wordf db 'n'                 ;sablono laukas w
  sfld db ?                    ;sablono laukas s
  repyyt db ?
  segreg dw ?                  ;prefiksinio baito segmento textinie israiska
  reg1 dw ?                    ;pirmo gegistro BIN israiska
  sndopk db ?                  ;jejgu 1 tai yra mod-reg-r/m baitas
  ofs db ?                     ;poslinkio paskirtis
  skip db ?                    ;kiek baitu reikia praleisti
  reg2 dw ?                    ;antrojo gegistro BIN israiska(adresas)
  adrisraiska db 10 dup (?)    ;adresacijos textine israiska
  adresavimas db ?             ;adresavimo atvejis 0..7
  modf db ?                    ;laukas mod 0..3
  TA db '[bx+si$[bx+di$[bp+si$[bp+di$[si$[di$[bp$[bx$'
  HEX db '00000100012001030011401005010160110701118100091001A1010B1011C1100D1101E1110F1111'
  OPK db 5000 dup (?)
  REGW db 'ax$cx$dx$bx$sp$bp$si$di$'
  REGB db 'al$cl$dl$bl$ah$ch$dh$bh$'
  REGS db 'es$cs$ss$ds$'
.Code
   jmp start
;-------------------------------------------------------------------
 ChkErr proc near
   jc klaida
   ret
 klaida:
   mov ah, 09h
   int 21h
   mov ah, 04Ch
   int 21h
 ChkErr endp
;-------------------------------------------------------------------
 LoadOpk proc near
   mov ah, 03Dh
   xor al, al
   mov dx, offset opkfile
   int 21h
   push ax
   mov dx ,offset noopkfile
   Call ChkErr
   mov ah, 03Fh
   pop bx
   mov dx, offset OPK
   mov cx, 5000
   int 21h
   mov ah, 03Eh
   int 21h
   Call ChkErr
   ret
 LoadOpk endp
;-------------------------------------------------------------------
 OpenFile proc near
   xor ah, ah
   add ax, 81h
   mov di, ax
   mov byte ptr es:[di], 0
   mov ax, es
   mov ds, ax
   mov dx, 82h
   xor al, al
   mov ah, 3Dh
   int 21h
   push ax
   mov ax, @Data
   mov ds, ax
   pop handler
   mov dx, offset nofile
   Call ChkErr
   ret
 OpenFile endp
;-------------------------------------------------------------------
 CreateFile proc near
   xor ah, ah
   mov al, byte ptr es:[80h]
   add ax, 07Ch
   mov di, ax
   mov byte ptr es:[di], '.'
   mov byte ptr es:[di+1], 'a'
   mov byte ptr es:[di+2], 's'
   mov byte ptr es:[di+3], 'm'
   mov byte ptr es:[di+4], 0
   mov ax, es
   mov ds, ax
   mov dx, 82h
   xor cx, cx
   mov ah, 03Ch
   Int 21h
   push ax
   mov ax, @Data
   mov ds, ax
   pop handler2
   Call ChkErr
   ret
 CreateFile endp
;-------------------------------------------------------------------
 WriteBuffer proc near  ; iraso buferi i faila
   mov ah, 40h
   mov bx, handler2
   int 21h
   ret
 WriteBuffer endp
;-------------------------------------------------------------------
 DataExtract proc near
   mov dx, offset MODELIS
   Call GetBufferLen
   Call WriteBuffer
   mov bytecount, 10h
   mov bx, handler
   Call Seek
   mov wordf, '1'
   Call WriteImm
   mov dx, offset nextln
   mov cx, 0002h
   Call WriteBuffer
   mov dx, offset PRADZIA
   Call GetBufferLen
   Call WriteBuffer
   ret
 DataExtract endp
;-------------------------------------------------------------------
 GetBufferLen proc near
   mov si, dx
   xor cx, cx
 more:
   mov al, byte ptr ds:[si]
   inc si
   inc cx
   cmp al, '$'
   jne more
   dec cx
   ret
 GetBufferLen endp
;-------------------------------------------------------------------
 Seek proc near
   mov dx, bytecount
   mov ah, 42h
   mov al, 0
   xor cx, cx
   int 21h
   ret
 Seek endp
;-------------------------------------------------------------------
 Read proc near
   mov ah, 3Fh
   mov bx, handler
   mov dx, offset buffer
   mov cx, 0001h
   int 21h
   cmp ax, 0
   je eofon
   inc bytecount
   ret
 eofon:
   mov eof, '1'
   ret
 Read endp
;-------------------------------------------------------------------
 ClearByte proc near
   mov di, dx
   mov cx, 0008h
 clearloop:
   mov byte ptr ds:[di], '0'
   inc di
 loop clearloop
   ret
 ClearByte endp
;-------------------------------------------------------------------
 ConvertBuff proc near
   Call ClearByte
   mov bl, 02h
   mov di, dx
   add di, 8
   mov al, buffer
 divloop:
   xor ah, ah
   div bl
   dec di
   add ah, 30h
   mov byte ptr ds:[di], ah
   cmp al, 0
 jne divloop
   ret
 ConvertBuff endp
;-------------------------------------------------------------------
 ConvertToChar proc near     ;Is bitu sekos padaro char
   mov ah, 01h               ;(dx=source,cx=bits)
   xor bl, bl
   mov si, dx
   mov di, bx
   add si, cx
 charloop:
   dec si
   mov al, byte ptr ds:[si]
   cmp al, '0'
   je nulis
   add bl, ah
 nulis:
   shl ah, 1
   loop charloop
   ret
 ConvertToChar endp       ; grazina registra bl
;-------------------------------------------------------------------
 FindElem proc near       ;is sekos isrenka nari
   mov si, dx             ;dx=seka, bx= buferis, cx=nario numeris
   inc cx
 nextelem:
   mov di, bx
 nextbyte:
   mov al, byte ptr ds:[si]
   inc si
   cmp al, '$'
   je elemover
   mov byte ptr ds:[di], al
   inc di
   jmp nextbyte
 elemover:
 loop nextelem
   mov byte ptr ds:[di], al
   ret
 FindElem endp
;-------------------------------------------------------------------
 Prefiksinis proc near
   mov segreg, '00'
   mov repyyt, '0'
   mov dl, buffer
   cmp dl, 0F2h
   jne norepnz  
   mov repyyt, '1'
   jmp neprefiksinis 
 norepnz:  
   cmp dl, 0F3h
   jne norep 
   mov repyyt, '1'
   jmp neprefiksinis  
 norep:  
   cmp dl, 026h
   je segm_es
   cmp dl, 02Eh
   je segm_cs
   cmp dl, 036h
   je segm_ss
   cmp dl, 03Eh
   je segm_ds
   jmp neprefiksinis
 segm_es:
   mov segreg, 'se'
   jmp readopk
 segm_cs:
   mov segreg, 'sc'
   jmp readopk
 segm_ds:
   mov segreg, 'sd'
   jmp readopk
 segm_ss:
   mov segreg, 'ss'
   jmp readopk
 readopk:
   Call Read
 neprefiksinis:
   ret
 Prefiksinis endp
;-------------------------------------------------------------------
 ConvertToHex proc near     ;Viena baita pavercia i HEX ir issaugo
   mov si, offset HEX       ;bx=kur padeti HEX
 hexnext:
   mov di, bx
   mov al, byte ptr ds:[si]
   mov byte ptr ds:[di], al;
   inc si
   mov di, dx
   mov cx, 0004h
   mov flag, 01h
 bitkitas:
   mov ah, byte ptr ds:[si]
   mov al, byte ptr ds:[di]
   inc si
   inc di
   cmp ah, al
   je bitastinka
   mov flag, 00h
 bitastinka:
   loop bitkitas
   cmp flag, 00h
   je hexnext
   ret
 ConvertToHex endp
;-------------------------------------------------------------------
 GetKomanda proc near    ;Tiesiog i lauka komanda ikrauna komandos pavedinima
   mov di, offset komanda
 getkomandaloop:
   mov al, byte ptr ds:[si]
   mov byte ptr ds:[di], al
   inc si
   inc di
   cmp al, '$'
   jne getkomandaloop
   ret
 GetKomanda endp
;-------------------------------------------------------------------
 Tikrinimas proc near    ; patikrina ar komandos kodas sutampa su sablonu
 nexttikr:
   mov wordopk, 'n'
   mov addopk, 'n'        ; pradines reiksmes
   mov flag, 0
   xor cx, cx
   mov kodadr, si
 bitu_sk:
   mov al, byte ptr ds:[si]
   inc si
   cmp al, '+'
   jne noplus
   mov wordopk, '1'
   jmp bit_sk_ok
 noplus:
   cmp al, '/'
   jne noslash
   mov al, byte ptr ds:[si]
   inc si
   mov addopk, al
   sub addopk, 30h
   jmp bit_sk_ok
 noslash:
   cmp al, '$'
   je bit_sk_ok
   cmp al, 10
   je endtikrinimas
   cmp al, '1'
   ja bit_sk_ok
   cmp al, '0'
   jb bitu_sk
   inc cx
   jmp bitu_sk
 bit_sk_ok:
   mov len, cx
   cmp addopk, 'n'
   je no_addopk
   Call Read
   mov dx, offset byte2
   Call ConvertBuff
   dec bytecount
   mov bx, handler
   Call Seek
   mov dx, offset byte2 + 2
   mov cx, 0003h
   Call ConvertToChar
   cmp addopk, bl
   jne netinka
 no_addopk:
   mov dx, offset byte1
   mov cx, len
   Call ConvertToChar
   mov papildomas, bl
   mov dx, kodadr
   mov cx, len
   Call ConvertToChar
   cmp papildomas, bl
   je tinka
   jmp netinka
 endtikrinimas:
   ret
 tinka:
   cmp wordopk, 'n'
   je no_wordopk
   Call Read
   mov dx, offset byte2
   Call ConvertBuff
   mov dx, offset byte2
   mov cx, 8
   Call ConvertToChar
   mov papildomas, bl
   mov dx, kodadr
   add dx, 9
   mov cx, 8
   Call ConvertToChar
   cmp papildomas, bl
   je no_wordopk
   dec bytecount
   mov bx, handler
   Call Seek
   jmp netinka
 no_wordopk:
   mov bl, 1
   ret
 netinka:
   mov bl, 0
   mov si, kodadr
 nextcode:
   mov al, byte ptr ds:[si]
   inc si
   cmp al, '$'
   jne nextcode
   jmp nexttikr
 Tikrinimas endp
;-------------------------------------------------------------------
 DefineField proc near   ;iskiria laukus ir priskiria reiksmes
   mov attrFAR, '0'
   mov sndopk, '0'
   mov ofs, '0'
   mov skip, '0'
   mov direction, 'n'
   mov wordf, 'n'
   mov sfld, 'n'
   mov constreg, 'n'
   mov vienetas, 'n'
   mov reg1, 0000h
   mov reg2, 0000h
   mov si, kodadr
   mov di, offset byte1
 defloop:
   mov al, byte ptr ds:[si]
   inc si
   cmp al, '/'
   jne praleisti_nereikia
   inc si
   jmp defloop
 praleisti_nereikia:
   cmp al, 'F'
   jne ne_FAR
   mov attrFAR, '1'
 ne_FAR:
   cmp al, 'd'
   je found_d
   cmp al, 'D'
   je const_d
   cmp al, 'w'
   je found_w
   cmp al, 'W'
   je const_w
   cmp al, 's'
   je found_s
   cmp al, 'r'
   je found_reg1
   cmp al, 'A'
   je accumul
   cmp al, 'S'
   je segmentreg
   cmp al, 'P'
   je found_skip
   cmp al, '>'
   je found_sndopk
   cmp al, 'o'
   je found_ofs
   cmp al, '$'
   je defover
   cmp al, 'V'
   je plus_vienetas
   cmp al,'0'
   jb defloop
   cmp al,'1'
   ja defloop
   inc di
   jmp defloop
 found_d:
   mov al, byte ptr ds:[di]
   inc di
   mov direction, al
   jmp defloop
 const_d:
   mov al, byte ptr ds:[si]
   inc si
   mov direction, al
   jmp defloop
 found_w:
   mov al, byte ptr ds:[di]
   inc di
   mov wordf, al
   jmp defloop
 const_w:
   mov al, byte ptr ds:[si]
   inc si
   mov wordf, al
   jmp defloop
 found_ofs:
   mov al, byte ptr ds:[si]
   inc si
   mov ofs, al
   jmp defloop
 found_sndopk:
   mov sndopk, '1'
   jmp defloop
 found_s:
   mov al, byte ptr ds:[di]
   inc di
   mov sfld, al
   jmp defloop
 found_reg1:
   mov reg1, di
   add di, 3
   jmp defloop
 found_skip:
   mov al, byte ptr ds:[si]
   sub al, 30h
   inc si
   mov skip, al
   jmp defloop
 accumul:
   mov constreg, al
   mov reg1, offset HEX  ;is ten paims pirmus 000 ir gausis akamuliatorius
   jmp defloop
 segmentreg:
   mov constreg, al
   jmp defloop
 plus_vienetas:
   mov al, byte ptr ds:[si]
   inc si
   mov vienetas, al
   jmp defloop
 defover:
   ret
 DefineField endp
;-------------------------------------------------------------------
 Registras proc near    ;atpazysta registra pagal jo koda
   cmp constreg, 'S'
   je segmentinis
   cmp wordf, '0'       ;dx=kodo adresas bx=adresas pavadinimuj padeti
   je baitinis
   mov si, offset REGW
   jmp decodereg
 baitinis:
   mov si, offset REGB
 decodereg:
   push si
   push bx
   xor ch, ch
   mov cl, 0003h
   Call ConvertToChar
   mov cl, bl
   pop bx
   pop dx
   Call FindElem
   ret
 segmentinis:
   mov si, offset REGS
   push si
   push bx
   xor ch, ch
   mov cl, 0003h
   Call ConvertToChar
   mov cl, bl
   pop bx
   pop dx
   Call FindElem
   mov constreg, 'n'
   ret
 Registras endp
;-------------------------------------------------------------------
 GetOpk2 proc near      ; gauna mod  reg ir r/m laukus
   mov dx, offset byte2
   mov cx, 0002h
   Call ConvertToChar
   mov modf, bl
   cmp reg1, 0000h
   jne reg1_yra
   mov ax, offset byte2 + 2
   mov reg1, ax
 reg1_yra:
   mov ax, offset byte2 + 5
   mov reg2, ax
   ret
 GetOpk2 endp
;-------------------------------------------------------------------
 WriteReg1 proc near
   mov dx, reg1
   mov bx, offset register1
   Call Registras
   mov dx, offset register1
   mov cx, 0002h
   Call WriteBuffer
   ret
 WriteReg1 endp
;-------------------------------------------------------------------
 WriteReg2 proc near
   mov dx, reg2
   mov bx, offset register2
   Call Registras
   mov dx, offset register2
   mov cx, 0002h
   Call WriteBuffer
   ret
 WriteReg2 endp
;-------------------------------------------------------------------
 WriteImm proc near
   mov dx, offset zero
   mov cx, 0001h
   Call WriteBuffer
   cmp wordf, '1'
   je imm_word
   Call Read
   mov dx, offset Byte3
   Call ConvertBuff
   mov bx, offset poslinkis
   Call ConvertToHex
   mov bx, offset poslinkis + 1
   mov dx, offset Byte3 + 4
   Call ConvertToHex
   mov dx, offset poslinkis
   mov cx, 0002h
   Call WriteBuffer
   mov dx, offset raide_h
   mov cx, 0001h
   Call WriteBuffer
   jmp imm_ok
 imm_word:
   Call Read
   mov dx, offset Byte3
   Call ConvertBuff
   mov bx, offset poslinkis + 2
   Call ConvertToHex
   mov bx, offset poslinkis + 3
   mov dx, offset Byte3 + 4
   Call ConvertToHex
   Call Read
   mov dx, offset Byte3
   Call ConvertBuff
   mov bx, offset poslinkis
   Call ConvertToHex
   mov bx, offset poslinkis + 1
   mov dx, offset Byte3 + 4
   Call ConvertToHex
   mov dx, offset poslinkis
   mov cx, 0004h
   Call WriteBuffer
   mov dx, offset raide_h
   mov cx, 0001h
   Call WriteBuffer
 imm_ok:
   ret
 WriteImm endp
;-------------------------------------------------------------------
 WriteOffset proc near
   cmp modf, 2
   je offs_word
   Call Read
   mov dx, offset Byte3
   Call ConvertBuff
   mov al, byte ptr ds:[byte3]
   cmp al, '0'
   mov dx, offset plus
   je neinvertuojam1
   neg buffer
   mov dx, offset Byte3
   Call ConvertBuff
   mov dx, offset minus
 neinvertuojam1:
   mov cx, 0001h
   Call WriteBuffer
   mov dx, offset zero
   mov cx, 0001h
   Call WriteBuffer
   mov dx, offset Byte3
   mov bx, offset poslinkis
   Call ConvertToHex
   mov bx, offset poslinkis + 1
   mov dx, offset Byte3 + 4
   Call ConvertToHex
   mov dx, offset poslinkis
   mov cx, 0002h
   Call WriteBuffer
   mov dx, offset raide_h
   mov cx, 0001h
   Call WriteBuffer
   jmp offs_ok
 offs_word:
   mov di, offset buffer2
   Call Read
   mov dl, buffer
   mov [di], dl
   Call Read
   mov dl, buffer
   mov [di+1], dl
   mov dx, offset Byte3
   Call ConvertBuff
   mov cl, byte ptr ds:[byte3]
   cmp cl, '0'
   mov dx, offset plus
   je neinvertuojam2
   neg buffer2
   mov dx, offset minus
 neinvertuojam2:
   mov cx, 0001h
   Call WriteBuffer
   mov dx, offset zero
   mov cx, 0001h
   Call WriteBuffer
   mov ax, buffer2
   mov buffer, al
   mov dx, offset Byte3
   Call ConvertBuff
   mov bx, offset poslinkis + 2
   Call ConvertToHex
   mov bx, offset poslinkis + 3
   mov dx, offset Byte3 + 4
   Call ConvertToHex
   mov ax, buffer2
   mov buffer, ah
   mov dx, offset Byte3
   Call ConvertBuff
   mov bx, offset poslinkis
   Call ConvertToHex
   mov bx, offset poslinkis + 1
   mov dx, offset Byte3 + 4
   Call ConvertToHex
   mov dx, offset poslinkis
   mov cx, 0004h
   Call WriteBuffer
   mov dx, offset raide_h
   mov cx, 0001h
   Call WriteBuffer
 offs_ok:
   ret
 WriteOffset endp
;-------------------------------------------------------------------
 WriteAdr proc near
   mov dx, reg2
   mov cx, 0003h
   Call ConvertToChar
   cmp bl, 6
   je ar_tiesioginis
   xor ch, ch
   mov cl, bl
 netiesioginis:
   cmp wordf, '1'
   je wptr
   mov dx, offset byteptr
   jmp segm
 wptr:
   mov dx, offset wordptr
 segm:
   mov cx, 0009h
   Call WriteBuffer
   cmp segreg, '00'
   je besegmento
   mov dx, offset segreg
   mov cx, 0002h
   Call WriteBuffer
   mov dx, offset dvitaskis
   mov cx, 0001h
   Call WriteBuffer
 besegmento:
   mov dx, reg2
   mov cx, 0003h
   Call ConvertToChar
   xor ch, ch
   mov cl, bl
   mov dx, offset TA
   mov bx, offset adrisraiska
   Call FindElem
   mov dx, offset adrisraiska
   Call GetBufferLen
   Call WriteBuffer
   ret
 ar_tiesioginis:
   cmp modf, 0
   jne netiesioginis
 tiesioginis:
   mov dx, offset skliaustas1
   mov cx, 0001h
   Call WriteBuffer
   mov al, wordf
   push ax
   mov wordf, '1'
   Call WriteImm
   pop ax
   mov wordf, al
   ret
 WriteAdr endp
;-------------------------------------------------------------------
 StructNOSNDOPK proc near   ;veikia kai nera mod-reg-r/m baito
   mov flag, 0
   cmp direction, '0'
   je direction0
   cmp reg1, 0000h
   je reg1_ok
   Call WriteReg1
   mov flag, 1              ;reikia kablelio
 reg1_ok:
   cmp ofs, '0'
   je i_pabaiga
   cmp flag, 1
   jne be_kablelio
   mov dx, offset kablelis
   mov cx, 0002h
   Call WriteBuffer
 be_kablelio:
   cmp ofs, 'i'
   jne su_skliaustais
   Call WriteImm
   ret
 su_skliaustais:
   mov dx, offset skliaustas1
   mov cx, 0001h
   Call WriteBuffer
   mov wordf, '1'           ;nes tiesioginis adresas yra 2 baitai
   Call WriteImm
   mov dx, offset skliaustas2
   mov cx, 0001h
   Call WriteBuffer
   ret
 direction0:
   mov dx, offset skliaustas1
   mov cx, 0001h
   Call WriteBuffer
   mov al, wordf
   push ax
   mov wordf, '1'           ;nes tiesioginis adresas yra 2 baitai
   Call WriteImm
   mov dx, offset skliaustas2
   mov cx, 0001h
   Call WriteBuffer
   mov dx, offset kablelis
   mov cx, 0002h
   Call WriteBuffer
   pop ax
   mov wordf, al
   Call WriteReg1
 i_pabaiga:
   ret
 StructNOSNDOPK endp
;-------------------------------------------------------------------
 StructREGREG proc near
   cmp ofs, 'i'
   je reg2imm
   mov dx, reg1
   mov bx, offset register1
   Call Registras
   mov dx, reg2
   mov bx, offset register2
   Call Registras
   cmp direction, '0'
   je reg2reg1
   mov dx, offset register1
   mov cx, 0002h
   Call WriteBuffer
   mov dx, offset kablelis
   mov cx, 0002h
   Call WriteBuffer
   mov dx, offset register2
   mov cx, 0002h
   Call WriteBuffer
   ret
 reg2reg1:
   mov dx, offset register2
   mov cx, 0002h
   Call WriteBuffer
   cmp addopk, 'n'
   jne bereg1
   mov dx, offset kablelis
   mov cx, 0002h
   Call WriteBuffer
   mov dx, offset register1
   mov cx, 0002h
   Call WriteBuffer
 bereg1:
   ret
 reg2imm:
   mov dx, reg2
   mov bx, offset register2
   Call Registras
   mov dx, offset register2
   mov cx, 0002h
   Call WriteBuffer
   mov dx, offset kablelis
   mov cx, 0002h
   Call WriteBuffer
   cmp sfld, '1'
   jne normal
   mov wordf, '0'
 normal:
   Call Writeimm
   ret
 StructREGREG endp
;-------------------------------------------------------------------
 SegOfs proc near
   cmp attrFAR, '1'
   je writeSegOfs
   ret
 writeSegOfs:
   ret
 SegOfs endp
;-------------------------------------------------------------------
 MabeSkip proc near
   cmp vienetas, 'n'
   jne dedam_kazka
   jmp arFAR
 dedam_kazka:
   mov dx, offset kablelis
   mov cx, 0002h
   Call WriteBuffer
   xor ch, ch
   mov cl, vienetas
   sub cl, 30h
   mov dx, offset visokie
   mov bx, offset register1
   Call FindElem
   mov dx, offset register1
   Call GetBufferLen
   Call WriteBuffer
 arFAR:
   Call SegOfs
  arskip:
   cmp skip, '0'
   je noskip
   xor ch, ch
   mov cl, skip
 doskip:
   push cx
   Call Read
   pop cx
   loop doskip
 noskip:
   ret
 MabeSkip endp
;-------------------------------------------------------------------
 Output proc near
   mov dx, offset komanda
   Call GetBufferLen
   Call WriteBuffer            ; spausdina i faila komanda
   mov dx, offset tarpas
   mov cx, 0001h
   Call WriteBuffer            ; spausdina tarpa
   cmp sndopk, '1'
   je yra_sndopk               ; jejgu turime adresavimo baita jumpinam
   Call StructNOSNDOPK
   ret
 yra_sndopk:
   cmp modf, 3
   je reg_reg                  ;jej mod=11 tai abu operandai registrai
   cmp direction, '0'
   je mem_reg                  ;jej laukas d=0 tai atm<-reg
   Call WriteReg1              ;spausdinam reg1
   mov dx, offset kablelis
   mov cx, 0002h
   Call WriteBuffer            ;spausdinam kableli ir tarpa
   cmp modf, 0
   jne bus_offset              ;jej mod nelygus 00 tai bus poslinkis
   Call WriteAdr               ;spausdinam adresa gauta is r/m lauko
   mov dx, offset skliaustas2
   mov cx, 0001h
   Call WriteBuffer            ;uzdarom skliausta
   ret
 reg_reg:
   Call StructREGREG
   ret
 bus_offset:
   Call WriteAdr               ;irasom adresa
   Call WriteOffset            ;irasom poslinki
   mov dx, offset skliaustas2
   mov cx, 0001h
   Call WriteBuffer            ;uzdarom skliausta
   ret
 mem_reg:
   Call WriteAdr               ;irasom adresa
   cmp modf, 0
   je nebus_offset
   Call WriteOffset            ;irasom poslinki
 nebus_offset:
   mov dx, offset skliaustas2
   mov cx, 0001h
   Call WriteBuffer            ;uzdarom skliausta
   cmp ofs, 'i'
   je mem_imm                  ;antras operandas yra betarpiskas
   cmp addopk, 'n'
   jne reg1_nereikia
   mov dx, offset kablelis
   mov cx, 0002h
   Call WriteBuffer            ;padedam kableli ir tarpa
   Call WriteReg1              ;irasom registra
 reg1_nereikia:
   ret
 mem_imm:                      ;uzrasom betarpiska operanda
   mov dx, offset kablelis
   mov cx, 0002h
   Call WriteBuffer            ;padedam kableli ir tarpa
   cmp sfld, '1'
   jne nosfld
   mov wordf, '0'
 nosfld:
   Call WriteImm
 baigta:
   ret
 Output endp
;-------------------------------------------------------------------
 Analize proc near
   mov si, offset OPK;
 nextkomanda:
   Call GetKomanda            ;i kintamaji komanda ikrauna komandos pavadinima
   Call Tikrinimas;           ;tikrina ar tos komandos kodas atitinka
   mov al, byte ptr ds:[si]
   cmp al, '!'                ;ar komandu sarasas baigesi?
   je nerasta
   cmp bl, 0                  ;ar komanda tiko?
   je nextkomanda
   jmp part2
 nerasta:
   mov ah, 09h
   mov dx, offset noopk
   int 21h
   mov ah, 04Ch
   int 21h
 part2:                       ;etapas analizuojantis komandos formata
   Call DefineField           ;uzpildome laukus
   cmp sndopk, '0'            ;ar turim mod-reg-r/m baita
   je analize_baigta          ;neturim
   Call Read                  ;turim
   mov dx, offset byte2
   Call ConvertBuff           ;iskoduojam ji i binary
   Call GetOpk2
analize_baigta:
   ret
 Analize endp
;-------------------------------------------------------------------
 start:
   mov al, byte ptr es:[80h]
   cmp al, 0
   je exit
   Call OpenFile
   Call CreateFile
   Call LoadOpk
   Call DataExtract
   mov bytecount, 200h
   mov bx, handler
   Call Seek
 sekanti:
   Call Read
   Call Prefiksinis
   cmp eof, '1'
   je exit
   mov dx, offset byte1
   Call ConvertBuff
   Call Analize
   Call Output
   Call MabeSkip
   cmp repyyt, '1'
   je sekanti
   mov dx, offset nextln
   mov cx, 0002h
   Call WriteBuffer
   mov dx, offset tarpas
   mov cx, 0003h   
   Call WriteBuffer            ; spausdina 3 tarpus
   jmp sekanti
 exit:
   mov dx, offset GALAS
   Call GetBufferLen
   Call WriteBuffer
   mov ah, 04Ch
   int 21h
End

