; This example program creates a file and then writes to it.
.model small
.stack
.code 

mov ax,@data 	; base address of data segment
mov ds,ax 	; put it in ds
mov dx,offset StartMessage 
mov ah,09h 
int 21h 

mov dx,offset FileName 	; put offset of filename in dx 
xor cx,cx 		; clear cx - make ordinary file
mov ah,3Ch 		; function 3Ch - create a file
int 21h 		; call DOS service

jc CreateError 		; jump if there is an error

mov dx,offset FileName 	; put offset of filename in dx
mov al,2 		; access mode -read and write
mov ah,3Dh 		; function 3Dh - open the file
int 21h 		; call dos service

jc OpenError 		; jump if there is an error
mov Handle,ax 		; save value of handle 

mov dx,offset WriteMe 	; address of information to write 
mov bx,Handle 		; file handle for file
mov cx,38 		; 38 bytes to be written
mov ah,40h 		; function 40h - write to file
int 21h 		; call dos service

jc WriteError 		; jump if there is an error
cmp ax,cx 		; was all the data written?
jne WriteError 		; no it wasn't - error!

mov bx,Handle 		; put file handle in bx 
mov ah,3Eh 		; function 3Eh - close a file
int 21h 		; call dos service

mov dx,offset EndMessage 
mov ah,09h 
int 21h 

ReturnToDOS:

mov ax,4C00h 		; terminate program 
int 21h 

WriteError:
mov dx,offset WriteMessage 
jmp EndError

OpenError:
mov dx,offset OpenMessage 
jmp EndError

CreateError:
mov dx,offset CreateMessage 

EndError:
mov ah,09h 
int 21h 
mov ax,4C01h 
int 21h 

.data 
CR equ 13
LF equ 10

StartMessage DB "This program creates a file called NEW.TXT"
	     DB ,"on the C drive.$"

EndMessage DB CR,LF,"File create OK, look at file to"
	   DB ,"be sure.$"

WriteMessage  DB "An error has occurred (WRITING)$"
OpenMessage   DB "An error has occurred (OPENING)$"
CreateMessage DB "An error has occurred (CREATING)$"

WriteMe  DB "HELLO, THIS IS A TEST, HAS IT WORKED?",0
FileName DB "C:\new.txt",0 ; name of file to open 
Handle   DW ? 	; to store file handle 

END
