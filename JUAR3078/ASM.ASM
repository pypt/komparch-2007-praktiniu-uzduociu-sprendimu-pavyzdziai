	.model small;
	.data
Buf     DB 255, 0
	DB 255 dup (?);
Message db 'iveskite skaiciu eilute', 13, 10,  '$';
Enter	DB 13, 10, "$";

Length  DB ?;

	.code
begin:
	mov	AX, @Data;
	mov	DS, AX;
Echo:
	mov	AH, 09h;
	mov	DX, offset message;
	int 	21h;
Read:
	mov	AH, 0Ah;
	mov	dx, OffSet Buf;
	int	21h;

	mov	ah, 09h;
	mov	dx, OffSet Enter;
	int	21h;
	
	mov SI, 02h;
	mov ah, Buf+1;
	mov Length, Ah;
	Xor ax, ax;
Get:
	mov dl, Buf[SI];
	inc SI;

	Cmp	dl, 13;
	je	Exit;
	
	cmp	dl, " ";
	Jne	show;

Ln:
	mov ah, 09h;
	mov dx, OffSet Enter;
	int 21h;
	Jmp Get;
	
Show:
	mov ah, 02;
	int 21h;
	Jmp Get;

Exit:
	mov	ah, 09h;
	mov	dx, OffSet Enter;
	int	21h;

	Call WriteHex; 
	mov	AX, 4C00h;
	int 	21h;

WriteHex proc
	Xor ax, ax;
	Xor dx, dx;
	mov ah, 02h;

	mov dl, Length;
	shr dl, 4;
	add dl, 30h;
	cmp dl, "A"-7;
	Jb J1;
	Add dl, 07h;
J1:
	int 21h;

	mov dl, Length;
	and dl, 00001111B;
	add dl, 30h;
	cmp dl, "A"-7;
	Jb J2;
	Add dl, 07h;
J2:
	int 21h;

	Ret;
EndP;

End begin
