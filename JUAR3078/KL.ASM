;ideal                           ;Tab = 09h
Model small
Stack 256
dataseg
  buf db 129 dup (?)
codeseg
prad:
 xor ch, ch
 mov cl,[ds:80h]
 
 xor bx, bx
 cld
 mov ax,@data
 mov es,ax
 mov di, offset buf
 mov si, 81h
 rep movsb 
 mov byte ptr [es:di],"$"

 push es
 pop ds
 mov ah, 09h
 mov dx, offset buf
 int 21h

 mov ah, 4Ch
 int 21h
end prad
