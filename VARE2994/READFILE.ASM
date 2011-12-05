; a program to demonstrate creating a file and then reading from
; it

.model small
.stack
.code 

mov ax,@data 		; base address of data segment
mov ds,ax 		; put this in ds

mov dx,OFFSET FileName 	; put address of filename in dx 
mov al,2 		; access mode - read and write
mov ah,3Dh 		; function 3Dh -open a file
int 21h 		; call DOS service

mov Handle,ax 		; save file handle for later
jc ErrorOpening 	; jump if carry flag set - error!

mov dx,offset Buffer 	; address of buffer in dx
mov bx,Handle 		; handle in bx
mov cx,100 		; amount of bytes to be read
mov ah,3Fh 		; function 3Fh - read from file
int 21h 		; call dos service

jc ErrorReading 	; jump if carry flag set - error! 

mov bx,Handle 		; put file handle in bx 
mov ah,3Eh 		; function 3Eh - close a file
int 21h 		; call DOS service

mov cx,100 		; length of string
mov si,OFFSET Buffer 	; DS:SI - address of string
xor bh,bh 		; video page - 0
mov ah,0Eh 		; function 0Eh - write character

NextChar:

lodsb 			; AL = next character in string
int 10h 		; call BIOS service
loop NextChar

mov ax,4C00h 		; terminate program 
int 21h 

ErrorOpening:

mov dx,offset OpenError ; display an error 
mov ah,09h 		; using function 09h
int 21h 		; call DOS service
mov ax,4C01h 		; end program with an errorlevel =1 
int 21h 

ErrorReading:
mov dx,offset ReadError ; display an error 
mov ah,09h 		; using function 09h
int 21h 		; call DOS service
mov ax,4C02h 		; end program with an errorlevel =2 
int 21h

.data
Handle DW ? 			; to store file handle 
FileName DB "C:\test.txt",0 	; file to be opened
OpenError DB "An error has occured(opening)!$"
ReadError DB "An error has occured(reading)!$"
Buffer DB 100 dup (?) 	; buffer to store data

END
