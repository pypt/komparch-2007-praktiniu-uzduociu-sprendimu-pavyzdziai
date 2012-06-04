;5.	Failo uþkodavimas. Programa uþkoduoja / atkoduoja nurodytà failà invertuodama kiekvieno simbolio kodo bitus, nurodytus rakte.
;Pvz.: fcrypt srcfile.txt destfile.txt 5A kiekvieno „srcfile.txt“ baito  6, 4, 3 ir 1 bitus (5A=01011010) pakeistø prieðingais.

	.Model small;
	.Data;
SourceFile DB "textfile.txt", 0, "$", "TextFile";
NewFile DB "Dest.txt", 0, "$", "New coded file";

ErrorOpenFile  DB "Negaliu atidaryti bylos", 13, 10, "$";
ErrorReadFile  DB "Negaliu perskaityti duomenu", 13, 10, "$";
ErrorCloseFile DB "Negaliu uzdaryti bylos", 13, 10, "$";
ErrorReadPar       DB "Blogi parametrai", 13, 10, "$";

Msg		DB "Use ? parammeter to help $";
MsgHelp         DB "            ****", 13, 10;
		DB "Files Coder/Decoder utilities 1.00", 13, 10;
		DB "Autor: Miroslav Kisly", 13, 10;
		DB 13, 10;
		DB "Ussage:   CODER [?] [SourceFile] [CodeFile]", 13, 10;
		DB "Examples: CODER ?     - view help", 13, 10;
		DB "          CODER Source.txt Code.txt", 13, 10, "$";  
MsgDec          DB "Decoding buffer.....", 13, 10, "$";
MsgLoa          DB "Loading Buffer.....", 13, 10, "$";
MsgEnd          DB "OK, file is allready overwrite!", 13, 10, "$";
MsgOK           DB "OK", 13, 10, "$";

CodingKey DW 1111H; klucz kodowania
ByteKey   DB 11h; klucz przeksztalcony w bajt 
FileNum  DW ?;
FileNum1 DW ?;   numer dojscia do plikow
FileNum2 DW ?;

Bufor   DB 256 DUP(?); bufor
Counter DW ?;        ilosc przeczytanych bajtow

	.Code;

Start:
	mov ax, @Data;
	mov ds, ax;
Process:
	Call CheckPar;      sprawdza, czy sa parametry
	Call CheckCommands; sprawdza parametry

	lea dx, SourceFile; wyswietla nazwy
	Call WriteString;
	lea dx, NewFile;
	Call WriteString;

	Call HexToByte; 
	
	Call Work;
 
	jmp Exit;           wyjscie z programu
ErrorOpen:       
	lea dx, ErrorOpenFile;
	Call WriteString;
	jmp Exit;
ErrorRead:
	lea dx, ErrorReadFile;
	Call WriteString;
	jmp Exit;
ErrorClose:
	lea dx, ErrorCloseFile;
	Call WriteString;
ErrorPar:
	lea dx, ErrorReadPar;
	Call WriteString;
Exit:
	mov ax, 4c00h;       zzkonczenie programu
	int 21h;

Work proc;
	mov dx, OffSet SourceFile;
	Call OpenFileToRead;
	mov bx, FileNum;
	mov FileNum1, bx;

	mov dx, OffSet NewFile;
	Call OpenFileToWrite;
	mov bx, FileNum;
	mov FileNum2, bx;
                  
Repeat: 
	mov bx, FileNum1;
	mov FileNum, bx; 
	Call ReadBufor;
	
	Cmp Counter, 00h;
	Je EndRepeat;

	Call ConvertBufor;

	mov bx, FileNum2;
	mov FileNum, bx;
	Call WriteBufor;

	Jmp Repeat;
EndRepeat:
	mov bx, FileNum1;
	mov FileNum, bx;
	Call CloseFile;

	mov bx, FileNum2;
	mov FileNum, bx;
	Call CloseFile;

	ret;
EndP;

;przekrztalcenie hex na bajt
;dwa bajty znajduja sie w CodingKey
;przeksztalcony w ByteKey
;algorytm bytI*16+byteII
HexToByte proc
	mov ax, CodingKey;
	
	cmp ah, "A";
	jb J1;
	Sub ah, 7;
J1:
	Sub ah, 30h;

	cmp al, "A";
	jb J2;
	Sub al, 7;
J2:
	Sub al, 30h;

	mov ByteKey, al;
        shl ah, 4;
	Add ByteKey, ah;
	
	ret;
EndP

;otwiera plik do czytania
;w ax(FileNum) - kod dojscia
;dx - nazwa pliku musi byc juz zapisana
OpenFileToRead proc
	mov ah, 3Dh;      otwieranie pliku
	mov al, 00h;      do czytania
	int 21h;
	mov FileNum, ax;  numer dojscia
	Jnc @@Ext1;     sprawdza bledy
	Jmp ErrorOpen;
@@Ext1:
	ret;
EndP;

;otwiera plik do pisania
;w ax(FileNum) - kod dojscia
;dx - nazwa pliku
OpenFileToWrite proc
	mov ah, 3Dh;     otwieranie pliku
	mov al, 01h;     do pisania
	int 21h;
	mov FileNum, ax; numerdojscia
	Jnc @@Ext;
	Jmp ErrorOpen;    sprawdza bledy
@@Ext:
	ret;
EndP;

;NumByte kod dojscia
;czyta bajt do CodingByte
ReadByte proc
	mov ah, 3Fh;
	mov bx, FileNum;          numer dojscia
	mov cx, 2;                ilosc bajtow
	mov dx, OffSet CodingKey; danne
	int 21h;
	Jnc Ext3;
	Jmp ErrorRead;             bledy
	
Ext3:
	ret;
EndP;

;Czyta z pliku do bufora
;Couner - ile przeczytano
ReadBufor proc
	mov ah, 3Fh;
	mov bx, FileNum;        numer dojscia
	mov cx, 255;            ilosc bajtow
	mov dx, OffSet Bufor;
	int 21h;	
	mov Counter, ax;        ilosc przeczytanych bajtow
	Jnc Ext4;
	Jmp ErrorRead;           sprawdza bledy
Ext4:
	ret
EndP

;Zamykanie pliku
CloseFile proc
	mov ah, 3Eh;
	mov bx, FileNum; numer dojscia
	int 21h;
	Jnc Ext5;
	Jmp ErrorClose;   sprawdza bledy
Ext5:
	ret;
EndP;

;konvertuje Bufor
ConvertBufor proc
	mov cx, Counter;

	lea dx, MsgDec;     wyswietla komunikat
	Call WriteString;	
Go:
	mov SI, CX;
	mov dl, Bufor[SI-1];
	xor dl, ByteKey;  kodowanie bitowe bajtu
	mov Bufor[SI-1], dl;
	Loop Go;
	ret;
EndP

;pisze na ekranie byte z dl
WriteByte proc
	mov ah, 02;
	int 21h;
	Ret;
EndP;

;wpisuje do pliku wartosc Bufor
WriteBufor proc
	MOV AH, 40H;
	MOV BX, FileNum;   numer dojscia
	MOV DX, OFFSET Bufor;
	MOV CX, Counter;
	INT 21H;
	ret;
EndP

;pisze lancuch na ekranie
;w dx musi wyc zaladowany juz od razu
WriteString proc
    mov ah, 09h;
    int 21h;
    ret;
EndP;

;sprawdza czy sa parametry ppodane z programem
;jezeli ich nie ma, wyswietla sie komunikat
;w przeciwnym wypadku wyswietla sie ilosc bajtow w par
CheckPar proc
	mov ah, 02;
	mov dl, ES:80h;  ilosc bajtow w paramatrze
	cmp dl, 0;       porownanie z zerem
	Jne Next;

	lea dx, Msg;     jezeli ich nie ma
	Call WriteString;
	Jmp Exit;
Next:
	ADD DL, 30H;     jezeli parametry sa
	int 21h;
	ret;
EndP;

;sprawdza komendy
;jezeli "?", to wyswietla pomoc
;w innym wypadku laduje imiona plikow
;imiona juz istnieja
;na ich miejsce wpisuja sie inne
;nazwy sa zaliczane do znaku "0"
;pozniejszy znak "$" potrzebny aby mozna bylo wyswietlic nazwy
;pozostale bajty sa nie wazne
CheckCommands proc
	mov al, ES:80h; 
	xor cx, cx;
	mov cl, al;     ilosc czytania bajtow
	mov SI, 81h;    poczatek adresu parametru
Go2:
	inc SI;         jest zwiekszane, gdyz 1 bajt " "
	mov al, ES:SI;  ladujemy bajt
	cmp al, "?";    porownanie
	Je Help;        
	jmp Next1;      jezeli nie ma pomocy 
Help:
	lea dx, MsgHelp;  wyswietlana pomoc
	Call WriteString;
    Jmp Exit;             zakonczeni programu
Next1:
    cmp al, " ";
    Je Next2;           jezeli parametrow wciaz nie ma

LoadCommand:
	dec cx;
	mov DI, 0;      poczatkowy adres 1 parametru

Do1:
	mov SourceFile[DI], al;   ladujemy nowy symbol
	inc SI;
	dec CX;
	inc DI;
	mov al, ES:SI;  otrzymyjemy nastepny symbol
 	cmp al, " ";    sprawdza koniec parametru
	Je Do;          wyjscie do tworzenia nastepnej nazwy
	cmp cx, 0;      wyjscie z procedury
	Je Out;
	Jmp Do1;
Do:
	mov SourceFile[DI], 0; tworzenie konca w nazwie
	inc DI;
	mov SourceFile[DI], "$";

Space:
	inc SI;     spawdza kiedy skoncza sie spacy
	dec CX;
	mov al, ES:SI;
	cmp al, " ";
	Je Space;
	mov DI, 00h;
Do2:
	mov NewFile[DI], al;   tworzy druga nazwe
	inc SI;
	dec CX;
	inc DI;
	mov al, ES:SI;
	cmp Cx, 0;
	JE DoEnd;
	cmp al, " ";
	JE DoEnd;
	Jmp Do2;
DoEnd:
	mov NewFile[DI], 0;    tworzy koniec nazwy
	inc DI;
	mov NewFile[DI],"$";
Space2:
	inc SI;     spawdza kiedy skoncza sie spacy
	dec CX;
	mov al, ES:SI;
	cmp al, " ";
	Je Space2;
Do3:
	mov Byte Ptr CodingKey, Al;
	;mov dh, Al;
	inc SI;
	dec CX;
	mov al, ES:SI;
	cmp cx, 00h;
	JE Out;
	mov Byte Ptr CodingKey+1, Al;
	;mov dl, al;
	;mov CodingKey, dx;
	dec CX;
	Jmp Out;
Next2:
;	Loop Go2;              przeskakuje na poczatek
Out:
	lea dx, MsgOK;         wyjscie z procedury
	Call WriteString;      i wyswietlanie komunikatu
	ret;
EndP;

End Start;                     koniec programu