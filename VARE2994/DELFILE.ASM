; a demonstration of how to delete a file. The file new.txt on
; c: is deleted (this file is created by create.exe). We also 
; check if the file exits before trying to delete it

.model small
.stack
.data

CR equ 13
LF equ 10

File 	db "C:\new.txt",0 
Deleted db "Deleted file c:\new.txt$"
NoFile 	db "c:\new.txt doesn't exits - exiting$"
ErrDel 	db "Can't delete file - probably write protected$"

.code

mov ax,@data 
mov ds,ax 

mov dx,OFFSET File 	; address of filename to look for
mov cx,3Fh 		; file mask 3Fh - any file
mov ah,4Eh 		; function 4Eh - find first file
int 21h 		; call dos service
jc FileDontExist

mov dx,OFFSET File 	; DS:DX points to file to be killed 
mov ah,41h 		; function 41h - delete file
int 21h 		; call DOS service
jc ErrorDeleting 	; jump if there was an error

mov dx,OFFSET Deleted 	; display message 
jmp Endit

ErrorDeleting:
mov dx,OFFSET ErrDel 
jmp Endit

FileDontExist:
mov dx,OFFSET NoFile 

EndIt:
mov ah,9
int 21h
mov ax,4C00h 		; terminate program and exit to DOS
int 21h 		; call DOS service
end