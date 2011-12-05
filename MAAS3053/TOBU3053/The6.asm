.MODEL small
.STACK
.CODE
   MOV bl,0h
   MOV ah,1h

Pradzia:

   INT 21h
   SUB al,60
   MOV dl,al
   CMP al,20h
   JLE Toliau
   INC bl

   Toliau:
   CMP dl,0Dh
   JNZ Pradzia 

   MOV ah,4ch
   INT 21h

END