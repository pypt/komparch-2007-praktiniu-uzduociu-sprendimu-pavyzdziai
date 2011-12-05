.MODEL small
.STACK
.DATA
   Eilute DB 13,10,'Iveskite du skaicius (16-aineje sistemoje): ','$'
   Eilut2 DB 13,10,'Veiksmas atliktas','$'
.CODE
   MOV ax,@data
   MOV ds,ax
   MOV ah,9h
   MOV dx,OFFSET Eilute
   INT 21h

   MOV ah,1h
   INT 21h

   MOV dl,al
   SUB dl,30h
   CMP dl,9h
   JLE skaicius1
   SUB dl,7h
   CMP dl,0Fh
   JLE skaicius1
   SUB dl,20h
Skaicius1:
   MOV cl,4h
   SHL dl,cl

   INT 21h

   SUB al,30h
   CMP al,9h
   JLE skaicius2
   SUB al,7h
   CMP al,0Fh
   JLE skaicius2
   SUB al,20h
Skaicius2:
   ADD al,dl
   MOV bl,al
 
   MOV ah,9h
   MOV dx,OFFSET Eilut2
   INT 21h
 
   MOV ah,4ch
   INT 21h
END
   