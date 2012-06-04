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
	skaitbuf db 255 dup (?)        
	rasbuf db 255 dup(?)
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
	mov bx, [handle1]
	push bx
failo_skaitymas:
	pop bx
	mov ah, 3Fh				;Skaitymas is failo	
	mov cx, 00h
	dec cx
	mov dx, offset skaitbuf
	int 21h
	jc klaidaf2
	cmp cx, ax
	je @@negalas	
	cmp cx, ax
	jne @@galas	
@@negalas:
	push bx
	xor bx, bx
	mov si, offset skaitbuf
	mov di, offset rasbuf
	mov bx, offset (fragm1 + 1)
	mov ah, [bx]	
	cld
	jmp @@dorcikl
@@paruos:
	pop cx
	mov bx, offset (fragm1 + 1)
	mov ah, [bx]
	inc si
@@dorcikl:
	lodsb
	cmp al, ah
	je @@next
	mov [di], al
	inc di
	loop @@dorcikl	
@@next:
	push cx
	xor cx, cx
	mov cl, [fragm1]
	dec si
@@ncik:
	inc bx
	mov al, [si + bx]
	mov ah, [bx]
	cmp al, ah
	jne @@paruos
	loop @@ncik
	pop cx
	push cx
	mov bx, FFh
	sub bx, cx
	
	
@@galas:
Klaidaf2:
	mov ah, 09h
	mov dx, offset klaif2
	int 21h
	jmp galas
Klaidaf3:
	mov ah, 09h
	mov dx, offset klaif3
	int 21h
	
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
endp
end start
