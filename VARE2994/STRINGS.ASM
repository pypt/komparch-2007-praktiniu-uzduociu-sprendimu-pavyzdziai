.model small
.stack
.code 

mov ax,@data 		; ax points to of data segment
mov ds,ax 		; put it into ds
mov es,ax 		; put it in es too
mov ah,9 		; function 9 - display string
mov dx,OFFSET Message1 	; ds:dx points to message
int 21h 		; call dos function

cld 			; clear direction flag
mov si,OFFSET String1 	; make ds:si point to String1
mov di,OFFSET String2 	; make es:di point to String2
mov cx,18 		; length of strings
rep movsb 		; copy string1 into string2

mov ah,9 		; function 9 - display string
mov dx,OFFSET Message2 	; ds:dx points to message
int 21h 		; call dos function

mov dx,OFFSET String1 	; display String1
int 21h 		; call DOS service

mov dx,OFFSET Message3 	; ds:dx points to message
int 21h 		; call dos function

mov dx,OFFSET String2 	; display String2
int 21h 		; call DOS service

mov si,OFFSET Diff1 	; make ds:si point to Diff1 
mov di,OFFSET Diff2 	; make es:di point to Diff2 
mov cx,39 		; length of strings
repz cmpsb 		; compare strings
jnz Not_Equal 		; jump if they are not the same

mov ah,9 		; function 9 - display string
mov dx,OFFSET Message4 	; ds:dx points to message
int 21h 		; call dos function

jmp Next_Operation

Not_Equal:
mov ah,9 		; function 9 - display string
mov dx,OFFSET Message5  ; ds:dx points to message
int 21h 		; call dos function

Next_Operation:
mov di,OFFSET SearchString 	; make es:di point to string
mov cx,36 		; length of string
mov al,'H' 		; character to search for
repne scasb 		; find first match
jnz Not_Found

mov ah,9 		; function 9 - display string
mov dx,OFFSET Message6 	; ds:dx points to message
int 21h 		; call dos function
jmp Lodsb_Example

Not_Found:
mov ah,9 		; function 9 - display string
mov dx,OFFSET Message7 	; ds:dx points to message
int 21h 		; call dos function

Lodsb_Example:
mov ah,9 		; function 9 - display string
mov dx,OFFSET NewLine 	; ds:dx points to message
int 21h 		; call dos function

mov cx,17 		; length of string
mov si,OFFSET Message 	; DS:SI - address of string
xor bh,bh 		; video page - 0
mov ah,0Eh 		; function 0Eh - write character

NextChar:
lodsb 			; AL = next character in string
int 10h 		; call BIOS service
loop NextChar

mov ax,4C00h 		; return to DOS
int 21h 

.data
CR equ 13
LF equ 10
NewLine db CR,LF,"$"

String1  db "This is a string!$"
String2  db 18 dup(0)
Diff1    db "This string is nearly the same as Diff2$"
Diff2    db "This string is nearly the same as Diff1$"
Equal1   db "The strings are equal$"
Equal2   db "The strings are not equal$"
Message  db "This is a message"
SearchString db "1293ijdkfjiu938uHello983fjkfjsi98934$"

Message1 db "Using String instructions example program.$"
Message2 db CR,LF,"String1 is now: $"
Message3 db CR,LF,"String2 is now: $"
Message4 db CR,LF,"Strings are equal!$"
Message5 db CR,LF,"Strings are not equal!$"
Message6 db CR,LF,"Character was found.$"
Message7 db CR,LF,"Character was not found.$"

end 