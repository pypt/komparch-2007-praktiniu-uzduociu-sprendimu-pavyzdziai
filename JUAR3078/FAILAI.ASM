.Model small
.stack 256

	cr = 0Dh
	lf = 0Ah
	ekranas = 1h

.Data
	msgh1 db "Antro uzdavinio, dirbancio su failais sprendimas. "
	msgh2 db cr,lf," Programos autorius Justas Arasimavicius "
	msgh3 db cr,lf," "
	msgh4 db cr,lf,"Programos uzdavinys nurodytame faile surasti, nurodyta fragmenta "
	msgh5 db cr,lf,"ir ji pakeisti kaip yra pageidaujama "
	msgh6 db cr,lf,"Programai reiketu pateikti failo saltinio varda, taip pat rezultatu failo varda,"
	msgh7 db cr,lf,"taip pat reikia nurodyti koki teksto fragmenta ir kaip pakeisti. "
	msgh8 db cr,lf,"Pvz.: Failai.exe duom.dat rezul.rez abcd DEF $"
	klai0 db "Klaida, neivesti duomenys! Help iskvieciamas parametru /? $"
	klai1 db "Klaida, Ivestas tik vieno failo vardas! $"
	Klai2 db "Klaida, Neivestas veiksmu aprasymas! $"
	klai3 db "Klaida, Nenurodyta kaip modifikuoti fragmenta! $"
	klai5 db "Klaida, Perdaug parametru! $"
	klaip db "Klaidingas parametru naudojimas (/) naudojamas,"
	klaip2 db cr,lf,"tik Help iskvietimui, parametru /? $"
	klaif0 db "Failo sukurimo klaida! $"
	klaif1 db "Failo atidarymo klaida! $"
	klaif2 db "Skaitymo is failo klaida! $"
	klaif3 db "Rasymo i faila klaida! $"
	klaif4 db "Klaida uzdarant faila! $"
	skaitbuf db 0FEh dup (?)        
	rasbuf db 0FEh dup(?)
	handle1 dw 0
	handle2 dw 0

	fragm1  db 0
		db 128 dup (?)	       	
	fragm2  db 0
		db 128 dup (?)
	       
	param db 129 dup (?)	
.Code
start:
	xor cx, cx
	mov cl, [ds:80h]
	
	push cx
	mov si, 81h
	mov ax, @data
	mov es, ax
	mov di, offset param	
	cld
	rep movsb  	
	mov byte ptr [es:di],00h	
	push ds
	push es
	pop ds
	pop es
	pop cx
	push cx	
	cmp cl, 0h			;Nera duomenu
	je klaida0
	mov si, offset param
	cld
	
nagrin:
	lodsb	
	cmp al, 20h
	je nul
	cmp al, 09h				;Tab
	je nul
	cmp al, 2Fh				;Ar ne /
	je @@antr
	dec cl
	cmp cl, 00h
	je exit
	jmp @@skait
@@antr:	
	inc ch
	mov al, [si]
	cmp al, 3Fh
	je @@pirm
	jmp nagrin	
@@pirm:
	cmp ch, 1h
	je help
@@skait:
	
@@skaityk:
	lodsb
	cmp al, 20h
	je nul
	cmp al, 09h
	je nul
	dec cl
	cmp cl, 0h
	je exit
	jmp @@skaityk
nul:
	mov byte ptr [si - 1],0
	dec cl
	cmp cl, 0
	je exit
	jmp nagrin	
Help:
	mov ah, 09h
	mov dx, offset msgh1
	int 21h
	jmp galas
klaida0:
	mov ah, 09h
	mov dx, offset klai0
	int 21h
	jmp galas
exit:
;Skaiciuoju kiek parametru
	pop cx
	push cx
	cld
	mov si, offset param
	xor bx, bx
	xor ah, ah	
Kiek:						;Kiek parametru
	lodsb
	cmp al, 0h
	je @@nauj
	cmp bl, 1h
	jne @@zym
	jmp @@skip
@@nauj:
	cmp bl, 1h
	jne @@Skip
	
	mov bl, 0h
	jmp @@skip	
@@zym:	
	mov bl, 1h
	inc ah
@@skip:
	loop kiek
	cmp ah, 1h
	je klaida1
	cmp ah, 2h
	je klaida2
	cmp ah, 3h
	je klaida3
	cmp ah, 4h
	ja klaida5
	JMP OK
klaida1:
	mov ah, 09h
	mov dx, offset klai1
	int 21h
	jmp galas
klaida2:
	mov ah, 09h
	mov dx, offset klai2
	int 21h
	jmp galas
klaida3:
	mov ah, 09h
	mov dx, offset klai3
	int 21h
	jmp galas
klaida5:
	mov ah, 09h
	mov dx, offset klai5
	int 21h
	jmp galas
klaidaf0:
	mov ah, 09h
	mov dx, offset klaif0
	int 21h
	jmp galas
klaidaf1:
	mov ah, 09h
	mov dx, offset klaif1
	int 21h
	jmp galas
OK:
	pop cx
	cld
	mov si, offset param
	xor ah, ah
Skaitau:
	lodsb
	cmp al, 00h
	jne @@file1
						;cmp cl, 00h;nereikalingi
						;je @@exit
	jmp skaitau
	
@@file1:	
	mov ah, 3Dh			;Failo atidarymas
	mov al, 00h
	dec si
	mov dx, si
	inc si
	int 21h
	jc klaidaf1
	mov [handle1], ax		;ar pavyks nuskaityti handle is mem
	call prasuk
@@file2:
	push cx
	mov ah, 3Ch			;Failo sukurimas	
	mov dx, si
	mov cx, 20h
	inc si
	int 21h
	jc klaidaf0
	pop cx	
	mov [handle2], ax
	call prasuk
	push cx
	xor cx, cx
	mov di, offset (fragm1 + 1)
@@frag1:
	lodsb 
	cmp al, 00h
	je @@frag1end
	inc cl
	mov byte ptr [di], al
	inc di
	jmp @@frag1
	
@@Frag1end:
	mov [fragm1], cl	
	pop cx
	mov byte ptr [di], 0Dh
	call prasuk

	mov di, offset (fragm2 + 1)
	xor cx, cx
@@frag2:
	lodsb
	cmp al, 00h
	je @@frag2end
	inc cl
	mov byte ptr [di], al
	inc di
	jmp @@frag2
@@frag2end:
	mov [fragm2], cl
	mov byte ptr [di], 0Dh	
	
;Failo duomenu dorojimas ** ** ** ** ** ** ** ** **
	xor bx, bx
	mov di, offset rasbuf
failo_skaitymas:
	push bx
	mov bx, [handle1]
	mov ah, 3Fh				;Skaitymas is failo	
	mov cx, 0FEh	
	mov dx, offset skaitbuf
	int 21h
	pop bx

	jc klaidaf2	
	cmp ax, 00h				;Jei nieko nenuskaityta
	je jaugalas	
	cmp cx, ax
	je negalas
	mov cx, ax	
negalas:	
	mov si, offset skaitbuf	
	cld
	mov ah, [fragm1 + 1]	
@@skaitymas:
	lodsb
	cmp al, ah
	je @@dorok
	mov [di], al
	inc di
	inc bx
        cmp bx, 0FFh
	je @@rasykf 
	loop @@skaitymas
	
	jmp failo_skaitymas
@@dorok: 
	call lygink
	jmp @@skaitymas
@@rasykf:
	call rasykfailan
	jmp @@skaitymas
jaugalas:	
	call rasykfailan
	jmp uzdarykf
Klaidaf2:
	mov ah, 09h
	mov dx, offset klaif2
	int 21h
	jmp galas
Klaidaf4:
	mov ah, 09h
	mov dx, offset klaif4
	int 21h
	jmp galas

Uzdarykf:
	mov ah, 3Eh
	mov bx, [handle1]
	int 21h
	jc Klaidaf4
	mov bx, [handle2]
	int 21h
	jc Klaidaf4
Galas:
	mov ah, 4Ch
	int 21h

prasuk proc
	cld
	cmp al, 0h
	je @@naujas
@@prad:		
	cmp cl, 0h
	je @@exit
	lodsb
	dec cl
	cmp al, 0h
	jne @@prad	
@@naujas:
	cmp cl, 0h
	je @@exit
	lodsb
	dec cl
	cmp al, 0h
	je @@naujas 	
@@exit:
	dec si
	inc cl
	ret
prasuk endp
lygink proc
	push cx
	push ax
	push si
	push bx
	push di
	xor bx, bx
	mov di, offset (fragm1 + 2)		;Kadangi pirmas sutapo
@@procesas:		
	mov ah, [di + bx]
	cmp ah, 0Dh
	je @@baigta
	inc bx
	lodsb
	cmp al, ah
	je @@procesas
        jmp @@endasparuos
@@baigta:
	pop di
	pop bx	
	mov si, offset (fragm2 + 1)
	xor cx, cx
	mov cl, [fragm2]
@@rasym:
        cmp bx, 0FFh
	je @@tustink
	mov al, [si]	
	mov [di], al
	inc bx	 
	inc di
	inc si
	loop @@rasym
        jmp @@Endasp
@@endasparuos:
        pop di        
        pop bx
        pop si
        cmp bx, 0FFh
        je @@valio
        jmp @@Nevalio
@@valio:
        call rasykfailan
@@Nevalio:
        dec si
        mov al, [si]                            ;Cia problema kol kas
        mov [di], al
        inc di
        inc bx
        inc si
        push si
        jmp @@endas
@@tustink:
	call rasykfailan
	jmp @@rasym
@@endasp:
        pop si
        mov al, [fragm1]
        xor ah, ah
        add si, ax
        dec si
        push si
@@endas:
	pop si       
	pop ax
	pop cx
	ret
lygink endp
rasykfailan proc
	push ax
        push cx
        push dx
	mov ah, 40h
	mov cx, bx 
	mov bx, [handle2]
	mov dx, offset rasbuf
	int 21h
	jc @@klaidaf3	
	cmp ax, cx
	jne @@klaidaf3
	jmp @@endrasf
@@Klaidaf3:
	mov ah, 09h
	mov dx, offset klaif3
	int 21h	
	mov ax, 4C00h
	int 21h
@@endrasf:
	xor bx, bx
	mov di, offset rasbuf
        pop dx
        pop cx
	pop ax
	ret
rasykfailan endp
end start
