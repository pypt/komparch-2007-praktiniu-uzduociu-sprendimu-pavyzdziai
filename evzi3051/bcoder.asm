;----- Antraste ----------------------------------------------------------------------
;  Failo uzkodavimas.
;-------------------------------------------------------------------------------------
;  Programa uzkoduoja/atkoduoja nurodyta faila cikliskai pastumdama kiekvieno simbolio
; kodo bitus i viena kuria nors puse koduodama (parametras /c) ir i priesinga puse
; dekoduodama (parametras /d). Pvz.: fcrypt scrfile.txt destfile.txt /c 4
; (UZDUOTIS 2_6)
;------------------------------------------------------------------------------------
; Programu sistemos, 5 grupe
; (c) Romuald Zybailo, MIF, 2002
;------------------------------------------------------------------------------------
	MODEL small
	STACK 100h

;----- Duomenys (kintamieji) --------------------------------------------------------

	DATASEG

  SourF DB 20 dup (?) , "$"
 Handle DW 0
  DestF DB 20 dup (?) , "$"
Handle2 DW 0
    cmd DB 0
 bskaic DB 0
fbuf	DW 0



KlaidaPar    DB "Blogi parametrai!", 13, 10, "$"
KlaidaCreate DB "Nepavyko sukurti laikmenos, KLAIDA!", 13, 10, "$"
KlaidaOpen   DB "Nepavyko atidaryti laikmenos, KLAIDA!", 13, 10, "$"
KlaidaRead   DB "Nepavyko nuskaityti duomenu, KLAIDA!", 13, 10, "$"
KlaidaClose  DB "Nepavyko uzdaryti laikmenos, KLAIDA!", 13, 10, "$"

msgIntro 	DB " /?   - surinkite po programos pavadinimo, kad iskviesti pagalba$"
MsgHelp		DB "=====================================================", 13, 10
		DB "Laikmenu kodavimas/dekodavimas, cikliskai stumdant baito bitus", 13, 10
		DB "Padare: Romuald Zybailo, MIF, 2002", 13, 10
		DB 13, 10
		DB "Naudojimas: BCODER [SourFile] [DestFile] [parametrai] [bit]", 13, 10
		DB "             /?  - pagalbos iskvietimas", 13, 10
		DB "   1) SourceFIle - koduojama ar dekoduojama laikmena", 13, 10
		DB "   2) DestFile   - uzkoduota ar dekoduota laikmena", 13, 10
		DB "   3) parametrai - [/c] koduoja laikmena", 13, 10
		DB "                   [/d] dekoduoja laikmena", 13, 10
		DB "   4) bit        - stumiamu baitu skaicius [1-7]", 13, 10
		DB 13, 10  
		DB "Pavizdziai: BCODER /?", 13, 10
		DB "            BCODER Sour.txt Dest.txt /c 3", 13, 10
		DB "            BCODER Sour.txt Dest.txt /d 3", 13, 10
		DB "=====================================================", 13, 10, "$"

;----- Kodas ------------------------------------------------------------------------

	CODESEG
Strt:
	mov ax,@data
	mov ds,ax

	call TikrPar
	call KmdEilute

	mov dx,OFFSET SourF		; atidarome faila is kurio skaitysime
	mov ax,3d00h
	int 21h				; int 21,3D - atidaryti faila
	jc erOpen			; jei cf=1
	mov [Handle],ax			; save handle
	mov bx,ax	

	mov dx,OFFSET DestF		;sukuriame faila (i kuri rasysime)
	mov ah,3Ch
	xor cx,cx
	int 21h
	jc erCrea
	mov [Handle2],ax
	jmp @@Loop

erOpen: mov dx,OFFSET KlaidaOpen
	call PrintMsg
	jmp exit
erCrea:	mov dx,OFFSET KlaidaCreate
	call PrintMsg
	jmp exit1	
erRead: mov dx,OFFSET KlaidaRead
	call PrintMsg
	jmp exit
erClos: mov dx,OFFSET KlaidaClose
	call PrintMsg
	jmp exit

@@Loop:
	mov ah,3fh
	mov cx,2			;kiek skaitysime
	mov dx,OFFSET fbuf
	int 21h				; int 21,3F - skaityti faila
	jc erRead

	or ax,ax
	jz exit
	mov cx,ax
	call Coding
	call PrintBuf
	jmp SHORT @@Loop	

	mov bx,[Handle2]
	mov ah,3Eh
	int 21h
	jc erClos
Exit1:	mov bx,[Handle]
	mov ah,3Eh
	int 21
	jc erClos
		
Exit:				
	mov ax,04C00h		; int 21,3E - uzdaryti faila
	int 21h
;============PROCEDUROS==============================================
;--------------------------------------------------------------------
; PrintMsg - isveda pranesima
;--------------------------------------------------------------------
PrintMsg PROC
	mov ah, 09h
	int 21h
	ret
PrintMsg EndP
;--------------------------------------------------------------------
; TikrPar - tikrina yra parametru param. eiluteje
;--------------------------------------------------------------------
TikrPar PROC
	mov ah, 02
	mov dl, es:80h	;parametru eilutes ilgis
	cmp dl, 0	;perejimas, jei oper_1 <> oper_2 
	Jne Next

	mov dx,OFFSET MsgIntro    ;jeigu ju nera..
	Call PrintMsg
	Jmp Exit
next:	ret
TikrPar ENDP
;------------------------------------------------------------------
; PralTarp - praleidzia tarpus
;------------------------------------------------------------------
PralTarp PROC
tarpas:
	inc si
	mov al, es:[si]
	cmp al, " "
	Je tarpas
	mov di, 0
	ret
PralTarp ENDP
;-----------------------------------------------------------------
; BadPar - ivykus klaidai isveda pranesima
;-----------------------------------------------------------------
BadPar PROC
	mov dx,OFFSET KlaidaPar
	call PrintMsg
	jmp exit
	ret
BadPar ENDP	
;-----------------------------------------------------------------
; KmdEilute - apdoroja parametru eilute
;-----------------------------------------------------------------
KmdEilute PROC
	mov si, 81h;   
Go2:
	call PralTarp   ;****
	mov al, es:[si]
	cmp al, "/"   
	Je Go2a        
	jmp Do1      
Go2a:	inc si
	mov al,es:[si]
	cmp al, "?"
	je help
	call BadPar
Help:
	mov dx,OFFSET MsgHelp 
	Call PrintMsg
	Jmp Exit

;FileNames
Do1:
	mov SourF[di], al 
	inc si
	inc di
	mov al, es:[si]  
 	cmp al, " "    
	Je Do;          
	Jmp Do1
Do:
	mov SourF[DI], 0
	mov di,0
	xor al,al
	call PralTarp       ;****
name2:	
	mov DestF[di],al
	inc si
	inc di
	mov al,es:[si]
	cmp al, " "
	je dalse
	jmp name2
dalse:
	mov DestF[di],0
	inc di
	call PralTarp       ;****
kom1:
	cmp al, "/"
	je koa
	call BadPar
koa:	inc si
	mov al,es:[si]
	cmp al, "c"
	jne kob
	mov cmd, al
	jmp kom2
kob:	
	cmp al, "d"
	Jne bad	
	mov cmd ,al
kom2:	
	call PralTarp      ;****
	cmp al,0Dh
	je bad

;palyginame ar neuzeina stumiamu bitu skaicius uz nurodytos rybos
;cia klaida bus, jei (al <= 30h) and (al => 38h)
	cmp al,30h      
	jbe m1          ; <=30h
m1:	cmp al,38h      
	jae bad         ; =>38h
	sub al,30h
	mov bskaic,al
	ret
bad:	call BadPar
	
KmdEilute ENDP

;--------------------------------------------------------------------------
; PrintBuf - prints char buffer to file
;	IN
;	  cx - char count
;	  dx - buf
;--------------------------------------------------------------------------
PrintBuf PROC
	push ax
	push bx
	
	mov ah,40h
	mov bx,[Handle2]
	int 21h			; int 21,40 - isvedimas i byla ar irengini
	
	pop bx
	pop ax
	ret
PrintBuf ENDP
;-------------------------------------------------------------------------
; Coding - cikliskai pastumia bitus: ror - desinen, rol - kairen
;-------------------------------------------------------------------------
Coding PROC
	push ax
	push cx
	push bx
	mov al,cmd
	cmp al, "c"
	jne roLL	
		
roRR:	mov al,byte ptr(fbuf)
	mov cl,bskaic
        ror al,cl
        mov byte ptr(fbuf),al

	mov al,byte ptr(fbuf+1)
	mov cl,bskaic
        ror al,cl
        mov byte ptr(fbuf+1),al
	jmp viskas

roLL:	mov al,byte ptr(fbuf)
	mov cl,bskaic
        rol al,cl
        mov byte ptr(fbuf),al

	mov al,byte ptr(fbuf+1)
	mov cl,bskaic
        rol al,cl
        mov byte ptr(fbuf+1),al
viskas:	
	pop bx
	pop cx
	pop ax
	ret
Coding ENDP
;======================================================================
END Strt

