; this program demonstrates how to look for files. It prints
; out the names of all the files in the c:\drive and names of
; the sub-directories

.model small
.stack
.data

FileName db "c:\*.*",0 ;file name
DTA 	 db 128 dup(?) ;buffer to store the DTA 
ErrorMsg db "An Error has occurred - exiting.$"

.code

mov ax,@data 	; set up ds to be equal to the 
mov ds,a 	; data segment
mov es,ax 	; also es

mov dx,OFFSET DTA 	; DS:DX points to DTA 
mov ah,1AH 		; function 1Ah - set DTA
int 21h 		; call DOS service

mov cx,3Fh 		; attribute mask - all files
mov dx,OFFSET FileName 	; DS:DX points ASCIZ filename
mov ah,4Eh 		; function 4Eh - find first
int 21h 		; call DOS service

jc error 	; jump if carry flag is set

LoopCycle:

mov dx,OFFSET FileName 	; DS:DX points to file name
mov ah,4Fh 		; function 4fh - find next
int 21h 		; call DOS service

jc exit 	; exit if carry flag is set

mov cx,13 		; length of filename
mov si,OFFSET DTA+30 	; DS:SI points to filename in DTA
xor bh,bh 		; video page - 0
mov ah,0Eh 		; function 0Eh - write character

NextChar:

lodsb 		; AL = next character in string
int 10h 	; call BIOS service

loop NextChar

mov di,OFFSET DTA+30 	; ES:DI points to DTA
mov cx,13 		; length of filename
xor al,al 		; fill with zeros
rep stosb 		; erase DTA

jmp LoopCycle 	; continue searching

error: 

mov dx,OFFSET ErrorMsg 	; display error message
mov ah,9
int 21h

exit:

mov ax,4C00h 	; exit to DOS
int 21h

end