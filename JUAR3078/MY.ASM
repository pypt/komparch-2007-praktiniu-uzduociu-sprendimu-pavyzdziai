.model small

  standout = 1
  cr = 0Dh
  lf = 0Ah

.data
      msg db "Iveskite eilute$"
      tus db cr,lf,"$"
      ivedbuf db 255
              db 0
              db 255 dup ("?")
.code

strt:
  mov ax,@data
  mov ds,ax

  mov ah,09h
  mov dx,offset msg
  int 21h

  mov ah,09h
  mov dx,offset tus
  int 21h

  mov ah,0Ah
  mov dx,offset ivedbuf
  int 21h

  mov ah,40h
  mov bx,standout
  mov cl,[prad]
  mod dx,offset nez
  int 21h

  mov ah,4Ch
  int 21h
end strt
