;Justas Arasimavicius, Programu sistemos penkta grupe

;---------------Pirmojo uzdavinio spendimas----------------------





;Programa Uzdavinys 1

;*************************** Aprasas ********************************

.model small			;Atminties modelis: 64k  
				;duomenims ir 64k kodui

;************************* Konstantos *******************************
     
	cr = 0Dh		;Kursoriaus atitraukimas i eilutes 
				;pradzia

	lf = 0Ah		;Kursoriaus perkelimas i kita eilute

;*********************** Aprasomas Stekas ***************************

	.stack 256		;Steko dydis 256 baitai

;******************** Pradiniu duomenu aprasas **********************

.data
     msg     db "Iveskite eilute teksto $"	;Salygos eilute

     tus     db cr,lf,"$"			;Tuscia eilute

     ats     db cr,lf,"Atsakymas: $"		;Atsakymo eilute

     ivedbuf db 255				;Ivedimo buferis
             db 0				;duomenu is klaviaturos
             db 255 dup (?)			;ivedimui

;*********************** Programos kodas ****************************    	

.code

start:
     mov ax,@data			;Duomenu priskyrimas duomenu
     mov ds,ax				;segmentui
			
     mov ah,09h				;Procedura 09 spausdina salygos
     mov dx, offset msg			;eilute
     int 21h				;Issaukiamas 21 pertraukimas

     mov ah,09h				;Procedura 09 spausdinama 
     mov dx, offset tus			;tuscia eilute
     int 21h

     mov ah,0Ah				;Procedura 0A nuskaito duomenis
     mov dx,offset ivedbuf		;ivestus is klaviaturos
     int 21h
	
     mov ah,09h				;Procedura 09 spaudina 
     mov dx, offset ats			;atsakymo eilute
     int 21h				

     xor cx,cx				;Cx vertimas 0
?????mov cl,[ivedbuf+1] 		;Apskaiciuojamas eilutes ilgis
     
     mov bx,offset ivedbuf+2		;Nuoroda i duomenis
     xor ax,ax     
     xor dx,dx	
     
	cmp cl, 0h			;Jei eilute ivesta nebuvo
	je exit

ciklas:					;Skaiciavimo ciklas

????????mov dl, byte ptr [bx]		;Tikrinamas pirmas ir antras
????????mov dh, byte ptr [bx + 1]	;eilutes simbolis 

	cmp dl,20h			;Jei simbolis tarpas
	je iras				;Pradeti rasyma

	cmp dh,0Dh			;Jei neliko simboliu, kodas 0Dh 
	je iras1
			
	inc al				;Zodzio ilgio skaiciavimas
	jmp skip

iras1:

	inc al
	jmp iras

iras:	

	cmp al,09h			;Jei zodzio ilgis <= 9 
	jbe rasyk			;spausdinam

	cmp al,63h			;Jei zodzio ilgis > 99 
	ja sim				;Simtu operacija

	cmp al,0Ah			;Jei zodzio ilgis >= 10
	jae des				;Desimciu operacija

sim:	

	push bx				;Issaugomas Bx
	xor bx,bx
??/ar 16-ainis	mov bl, 64h			;Bx = 100 dec
??kaip veikia ir koks max dydis 	div bl				;dalyba is 100
					;Al = dalmuo, Ah = liekana

	pop bx				;Atstatoma Bx reiksme	 
	push ax
	push bx
	
	mov ah,02			;Procedura 02 spausdina viena
					;simboli - cia simtu skaiciu
	add al,30h			;Pridedami 30h, kad pagal ASCII
	mov dl,al			;lentele butu skaitmenys
	int 21h

	pop bx
	pop ax
	mov al,ah			;Al suteikiama liekanos reiksme
	xor ah,ah	

des:

	push bx
	xor bx,bx
	mov bl,0Ah			;Dalyba is 10 dec
	div bl
	pop bx
	push ax
	push bx

	mov ah,02			;Desimciu skaitmens 
	add al,30h			;spaudinimas 02 procedura
	mov dl,al
	int 21h
	xor ax,ax

	pop bx
	pop ax
	mov al,ah
	xor ah,ah
	
rasyk:
	push bx				;Vienetu skaitmens arba 
	mov ah,02			;skaiciaus mazesnio uz 9 
	add al,30h			;spaudinimas
	mov dl,al
	int 21h
	mov ah,02h
	mov dl,20h
	int 21h	
	xor ax,ax
	pop bx
skip: 
????	inc bl				;Didinamas Bl tam kad tikrint 
					;kita baita
loop ciklas

exit:					;Programos pabaiga

     mov ah,4ch
     int 21h
     
end start
     
