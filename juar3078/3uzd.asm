; ----- Antraste --------------------------------------------------------------

; Programa 'UZD.3'
; Programa demonstruoja dalybos is nulio apdorojima

; (c) Mindaugs Lieponis, MIF, 2002
; -----------------------------------------------------------------------------
	.MODEL small		; Atminties modelis: 64K kodui ir 64K duomenims
	.STACK 100h

; ----- Duomenys (kintamieji) -------------------------------------------------
	
	.DATA
	
Msg	DB "Dalybos is nulio pertraukimas!",0dh,0ah,"$"
msg1    DB "Pertraukimo adresas:   $"
msg2    DB ":$"
msg3    DB 0dh,0ah,"Pertraukima sukelusi operacija: $"
msg4    DB " DX:AX div $"
msg5    DB " AX div $"   
msg6    DB " DIV $"
msg7    DB " IDIV $"
msg11   DB 0dh,0ah,"Operandai: $"
msg8    DB " DX:AX idiv $ "
msg9    DB " AX idiv $"
msg10   DB 0dh,0ah,"Operandu reiksmes: $"
r_m000_mod11_w0 DB "AL$"
r_m001_mod11_w0 DB "CL$"
r_m010_mod11_w0 DB "DL$"
r_m011_mod11_w0 DB "BL$"
r_m100_mod11_w0 DB "AH$"
r_m101_mod11_w0 DB "CH$"
r_m110_mod11_w0 DB "DH$"
r_m111_mod11_w0 DB "BH$"

r_m000_mod11_w1 DB "AX$"
r_m001_mod11_w1 DB "CX$"
r_m010_mod11_w1 DB "DX$"
r_m011_mod11_w1 DB "BX$"
r_m100_mod11_w1 DB "SP$"
r_m101_mod11_w1 DB "BP$"
r_m110_mod11_w1 DB "SI$"
r_m111_mod11_w1 DB "DI$"

r_m000_mod00 DB "BX + SI$"
r_m001_mod00 DB "BX + DI$"
r_m010_mod00 DB "BP + SI$"
r_m011_mod00 DB "BP + DI$"
r_m100_mod00 DB "SI$"
r_m101_mod00 DB "DI$"
r_m110_mod00 DB "BP$"    
r_m111_mod00 DB "BX$"

adr DB "[$"
adr1 DB "]$"

pliusas DB " + $"
minusas DB "-$"
daugyba DB "*FFFF+$"
poslinkis DW 1
operandas DW 1
r_m     DB 1
reg     DB 1
mode    DB 1
reg_ax Dw 1
reg_bx DW 1
reg_cx Dw 1
reg_dx DW 1
reg_si Dw 1
reg_di DW 1
reg_sp Dw 1
reg_bp DW 1
as Db 5 dup (0)
testing Db 5 dup (0)
; ----- Kodas -----------------------------------------------------------------

	.CODE

OrigISRSeg	DW ?
OrigISROfs	DW ?
	
Strt:
	mov ax,@data
	mov ds,ax
	
	; --- es <- 0
	mov ax, 0
	mov es, ax
	
	; --- Issaugome senos pertraukimo apdorojimo proceduros adresa
	mov ax,es:[0]
	mov cs:[OrigISROfs],ax
	mov ax,es:[2]
	mov cs:[OrigISRSeg],ax
	
	; --- Instaliuojame nauja pertraukimu apdorojimo procedura
	pushf
	cli
	mov word ptr es:[0],offset ISRProcedure
	mov word ptr es:[2],seg ISRProcedure
	popf
       
        mov dx,-10000
        mov ax,255
        mov [testing+2],-3
        mov bx,offset testing
        xor si,si
        ;mov bx,-3
        idiv [bx+2]
	
	; --- Atstatome sena pertraukimu apdorojimo procedura
	push ds
	mov ax,cs:[OrigISRSeg]
	mov ds,ax
	mov dx,cs:[OrigISROfs]
	mov ah,25h
	mov al,0
	int 21h
        pop ds
       	
	mov ax,04C00h
	int 21h			; int 21,4C - programos pabaiga

;--------------------------------------------------------------------------
ISRProcedure PROC
	
        call save_reg

        pop cx        ;IP
        pop es        ;CS 
    
        mov si,cx
        mov bx,es:[si]
        mov ax,es:[si+2]         ;poslinkis, jei jo reikes
        xor si,si 
        mov [poslinkis],ax      
        push bx 
       
        shr bl,1                 ;postumis i desine per viena pozicija
    
        cmp bl,123               ;dvetetainiu tai 1111011
        jz ok               ;jei pertraukiams kilo ne del dalybos is nulio
        jmp no_div
ok:              
        mov dx,offset msg
        call printstr
        mov dx,offset msg1
        call printstr
        
        mov bx,es
        call Hexconvert      ;print CS 
        
  	mov dx,offset msg2
        call printstr

	mov bx,cx            ;Print IP 
        call hexconvert 
         
        mov dx,offset msg3
        call printstr

        pop ax                  ;atstatoma bx reiksme i ax
        test al,1               ;nustatoma w reiksme
        jnz zodis    
        xor di,di  
        jmp operacija
zodis:
        mov di,1
operacija:
        push di
        call lauku_reiksmes
        cmp [reg],6                 ;dvejetainiu 110 - div  
        jnz idiv_as
        mov dx, offset msg6
        call printstr
        mov dx,offset msg11
        call printstr
        cmp di,1
        jz zodis_div
        mov dx,offset msg5
        call printstr
        jmp kitas
zodis_div:
        mov dx,offset msg4
        call printstr 
        jmp kitas
idiv_as:
        mov dx,offset msg7
        call printstr
        mov dx,offset msg11
        call printstr
        cmp di,1
        jz zodis_idiv
        mov dx,offset msg9
        call printstr
        jmp kitas
zodis_idiv:
        mov dx,offset msg8
        call printstr
kitas:                       ;ieskoma, is ko buvo dalinta
        pop di 
        cmp [mode],3         ;mod=11
        jnz poslink
        cmp di,1
        jnz baitas
        push di
        call mod11_w1 
        jmp reiksmes
baitas:                    
        call mod11_w0
        jmp reiksmes
poslink:                      
        call mod00
reiksmes:      
        mov dx,offset msg10
        call printstr
        
        pop di
        call reiksme              ;operandu reiksmes        
no_div: 
	push es
        add cx,2
	push cx
	iret
ISRProcedure ENDP
;-------------------------------------------------------------------------
HexConvert proc
        push cx 
        push es
	push ax
        mov di,4
        mov [as+di],"$"
        dec di
        mov cx,16
        xor ch,ch
        mov si,1
        xor ax,ax
ciklas:    
        test bx,1
        jz nulis
        cmp si,3
        jnz tikrink
        add ax,4
        jmp nulis
tikrink:
        cmp si,4
        jnz pridek
        add ax,8 
        jmp nulis  
pridek:
        add ax,si
nulis: 
        cmp si,4
        jnz toliau1
        call intobuf
        xor si,si
        xor ax,ax
toliau1:
        inc si
        ror bx,1
        loop ciklas
       
        mov dx,offset as
        call printstr
        
	pop ax
        pop es
        pop cx
        ret
HexConvert endp
;--------------------------------------------------------------------------
PrintStr PROC	    
	push ax    
	mov ah,09h
	int 21h
	pop ax
        ret
PrintStr ENDP
;------------------------------------------------------------------------
intobuf Proc
      cmp ax,9
      ja @@pridek
      add ax,30h
      jmp @@toliau
@@pridek:
      add ax,37h
@@toliau:
       mov [as+di],al
       dec di
       ret
intobuf endp
;-----------------------------------------------------------
lauku_reiksmes PROC
        xor al,al
        xchg al,ah      ;apkeiciame vietomis 
        mov bl,8
        div bl          ;atskiriami trys paskutiniai bitai i ah
        mov [r_m],ah
        xor ah,ah
        div bl          ;op kodo ispletimas
        mov [reg],ah
        mov [mode],al   ;laukas mod
        ret
lauku_reiksmes ENDP
;--------------------------------------------------------------
Save_reg  PROC
        mov [reg_ax],ax
        mov [reg_bx],bx
	mov [reg_cx],cx
	mov [reg_dx],dx
	mov [reg_si],si
	mov [reg_di],di
	mov [reg_sp],sp
	mov [reg_bp],bp
	ret
Save_reg  ENDP

;------------------------------------------------------------
Mod11_W1  PROC
        push ax
        cmp [r_m],0
        jnz @@next
        mov dx,offset r_m000_mod11_w1
        mov ax,[reg_ax]
        jmp @@spausdink
@@next:
        cmp [r_m],1
        jnz @@next1
        mov dx,offset r_m001_mod11_w1
        mov ax,[reg_cx]
        jmp @@spausdink
@@next1: 
        cmp [r_m],2
        jnz @@next2
        mov dx,offset r_m010_mod11_w1
	mov ax,[reg_dx]
        jmp @@spausdink
@@next2:  
	cmp [r_m],3
        jnz @@next3
        mov dx,offset r_m011_mod11_w1
	mov ax,[reg_bx]
        jmp @@spausdink
@@next3:
	cmp [r_m],4
        jnz @@next4
        mov dx,offset r_m100_mod11_w1
	mov ax,[reg_sp]
        jmp @@spausdink
@@next4: 
	cmp [r_m],5
        jnz @@next5
        mov dx,offset r_m101_mod11_w1
	mov ax,[reg_bp]
        jmp @@spausdink
@@next5: 
	cmp [r_m],6
        jnz @@next6
        mov dx,offset r_m110_mod11_w1
	mov ax,[reg_si]
        jmp @@spausdink
@@next6: 
        mov dx,offset r_m111_mod11_w1
	mov ax,[reg_di]
@@spausdink:
        mov [operandas],ax
        call printstr
        pop ax
        ret
Mod11_W1 ENDP
;----------------------------------------------------------- 
Mod11_W0 PROC
        push ax
        cmp [r_m],0
        jnz @@kitas
        mov ax,[reg_ax]
        xor ah,ah
        mov dx,offset r_m000_mod11_w0
        jmp @@spausdinti
@@kitas:
        cmp [r_m],1
        jnz @@kitas1
        mov dx,offset r_m001_mod11_w0
	mov ax,[reg_cx]
        xor ah,ah
        jmp @@spausdinti
@@kitas1: 
        cmp [r_m],2
        jnz @@kitas2
        mov dx,offset r_m010_mod11_w0
        mov ax,[reg_dx]
        xor ah,ah
        jmp @@spausdinti
@@kitas2:  
	cmp [r_m],3
        jnz @@kitas3
        mov dx,offset r_m011_mod11_w0
	mov ax,[reg_bx]
        xor ah,ah
        jmp @@spausdinti
@@kitas3:
	cmp [r_m],4
        jnz @@kitas4
        mov dx,offset r_m100_mod11_w0
	mov ax,[reg_ax]
        xor al,al
        xchg al,ah
        jmp @@spausdinti
@@kitas4: 
	cmp [r_m],5
        jnz @@kitas5
        mov dx,offset r_m101_mod11_w0
	mov ax,[reg_cx]
        xor al,al
        xchg al,ah
        jmp @@spausdinti
@@kitas5: 
	cmp [r_m],6
        jnz @@kitas6
        mov dx,offset r_m110_mod11_w0
	mov ax,[reg_dx]
        xor al,al
        xchg al,ah
        jmp @@spausdinti
@@kitas6: 
        mov dx,offset r_m111_mod11_w0
        mov ax,[reg_bx]
        xor al,al
        xchg al,ah
@@spausdinti:
        mov [operandas],ax
        call printstr
        pop ax
        ret
Mod11_W0 ENDP
;----------------------------------------------------------
Mod00  PROC
        push si
        push ax
        push bx
        xor ax,ax
        mov dx,offset adr
        call printstr
        cmp [r_m],0
        jnz @@dar
        mov dx,offset r_m000_mod00
        mov ax,[reg_bx]
        mov bx,[reg_si]
        add ax,bx
        jmp @@print
@@dar:
        cmp [r_m],1
        jnz @@dar1
        mov dx,offset r_m001_mod00
        mov ax,[reg_bx]
        mov bx,[reg_di]
        add ax,bx
        jmp @@print
@@dar1: 
        cmp [r_m],2
        jnz @@dar2
        mov dx,offset r_m010_mod00
	mov ax,[reg_bp]
        mov bx,[reg_si]
        add ax,bx
        jmp @@print
@@dar2:  
	cmp [r_m],3
        jnz @@dar3
        mov dx,offset r_m011_mod00
	mov ax,[reg_bp]
        mov bx,[reg_di]
        add ax,bx
        jmp @@print
@@dar3:
	cmp [r_m],4
        jnz @@dar4
        mov dx,offset r_m100_mod00
	mov ax,[reg_si]
        jmp @@print
@@dar4: 
	cmp [r_m],5
        jnz @@dar5
        mov dx,offset r_m101_mod00
	mov ax,[reg_di]
        jmp @@print
@@dar5: 
	cmp [r_m],6
        jnz @@dar6      
        cmp [mode],0
        jz @@print1
        mov dx,offset r_m110_mod00
	mov ax,[reg_bp]
        jmp @@print
@@dar6: 
        mov dx,offset r_m111_mod00
	mov ax,[reg_bx]
@@print:
        call printstr 
        cmp [mode],0
        jz @@baigta
        mov dx,offset pliusas
        call printstr
@@print1:
        mov bx,[poslinkis]           ;vieno ar 2 baitu poslinkis
        cmp [mode],1  
        jz @@vienas
        add ax,bx
        jmp @@convert
@@vienas:
        xor bh,bh
        add ax,bx
@@convert:
        call hexconvert
@@baigta:
	mov bx,ax
        mov ax,[bx]
        mov [operandas],ax 

        mov dx,offset adr1
        call printstr
        pop bx
        pop ax
        pop si
        ret
Mod00 ENDP
;---------------------------------------------------------
Reiksme PROC
         push cx
         push es
         cmp [reg],6
         jnz @@sveik_dal       ;idiv
         cmp di,1
         jnz @@byte_dalyba          
         mov bx,[reg_dx]	;word
         call hexconvert
         mov dx,offset daugyba
         call printstr       
@@byte_dalyba: 			;byte
         mov bx,[reg_ax]
         call hexconvert
         mov dx,offset msg6
         call printstr
         mov bx,[operandas]
         call hexconvert
         jmp @@galas
@@sveik_dal:
         xor si,si
         cmp di,1                    ;ar su word ar su byte
         jnz @@byte_sveik_dal
         mov bx,[reg_dx]
         test bh,128                 ;ar paskutinis bitas 1 (neigiami), ar 0 (teigiami)
         jz @@byte_sveik_dal
         inc si                      ;pozymis,kad vienas neigiamas
         neg (bx)                        
@@byte_sveik_dal:
         mov ax,[reg_ax]
         test ah,128
         jz @@teigiam1
         neg (ax)
         inc si
@@teigiam1:
         cmp si,1                             ;jei vienas buvo neigiamas
         jnz @@gerai
         mov dx,offset minusas
         call printstr        
@@gerai:       
         cmp di,1
         jnz @@baitas
         call hexconvert                      ;print dx
	 mov dx,offset daugyba
         call printstr 
@@baitas:
	 mov bx,ax			      ;print ax
         call hexconvert	  
         mov dx,offset msg7
         call printstr
@@antras:
         mov bx,[operandas]
         or bh,bh 
         jz @@byte
         test bh,128 
         jz @@teigiam2
	 neg (bx)
  	 jmp @@minus
@@byte:
         test bl,128
         jz @@teigiam2
         neg (bl)
@@minus:
         mov dx,offset minusas
         call printstr 
@@teigiam2:
         call hexconvert
@@galas:         
         pop es
         pop cx
         ret
Reiksme ENDP
;--------------------------------------------------------
END Strt
