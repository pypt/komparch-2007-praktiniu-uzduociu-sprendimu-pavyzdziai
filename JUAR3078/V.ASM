;ษออออออออออออออออออออออออออออออออออออออป
;บ	TextViewer 1.00			บÛ
;บ	Autor:  Miroslav Kisly		บÛ
;บ	Data:   2002 10 18		บÛ
;บ					บÛ
;บ	E-mail:	Miroslav@xxx.lt		บÛ
;บ					บÛ
;บ					บÛ
;ศออออออออออออออออออออออออออออออออออออออผÛ
;  ฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
;
;                           konstanty  
UP_KEY          EQU     72; klawisze...
DOWN_KEY        EQU     80;
HOME_KEY        EQU     71;
END_KEY	        EQU     79;
PGDOWN_KEY      EQU     81;
PGUP_KEY        EQU     73;
ESC_KEY         EQU     27;

LEFT_KEY	EQU	75;
RIGTH_KEY	EQU	77;

SEG_A   SEGMENT BYTE PUBLIC;
        ASSUME	CS:SEG_A, DS:SEG_A, ES:SEG_A, SS:SEG_A; 
        ORG     100h;       typiczny dla COM plikow

START:
       	XOR	CX,CX;
        MOV     SI,82H;
        ADD     CL,BYTE PTR [SI-02H];	80h - ilosc symboli parametrow
        JNZ     SHORT JEST_PARAMETR;
PAR_ERROR:
        LEA     DX,NO_PARAM;	nie ma parametrow
        CALL	WRITE_TEXT;
        RET;			isejimas is programos
FILE_ERROR:
	CALL WRITE_ERROR;
	RET;			exit
JEST_PARAMETR:;			jezeli 	jest parametr
	DEC     CX;		musi zmniejszyc, bo nazwa o jeden mniejsza
	MOV     BYTE PTR [NAZWA_LEN],CL;	w Cl bylo zachowane ilosc bajtow
	LEA     DI,NAZWA;	do DI adres, gdzie bedzie nazwa pliku
        MOV     DX,DI;		zachowuje DI;
        REP     MOVSB;		dopuki cx(dlugosc nazwy)<>0 przenos SI>DI, inc SI,DI
        MOV     AX,0D00H;	do nazwy wpisuje 13 -Enter, 00h - koniec nazwy
        STOSW;
OPEN_FILE:
        MOV     AH,3DH;		otwieranie dojscia do pliku, w DX - nazwa pliku
        INT     21H;
        JC      SHORT FILE_ERROR;
READ_FILE:
        MOV	BX,AX;		numer dojscia
        MOV     CX,50000;	ilosc czytania bajtow
        MOV     AH,3FH;		do czytania
        LEA     DX,PLIK;	bufer = 50000B
        INT     21H;
        OR      AX,AX;		jezeli blad
        JZ      SHORT FILE_ERROR;
        MOV     CX,AX;		ilosc przeczytanych bajtow
        MOV     DI,DX;		z dx adres przekazuje na DI
        ADD     DI,AX;		pozniej go zwieksza na ilosc przeczytanych bajtow
        MOV     AL,0DH;		13 -Enter
        STOSB;			na koniec laduje Enter;
CLOSE_FILE:
        MOV     AH,3EH;		zamykanie pliku
        INT     21H;

        MOV     WORD PTR [LINIE],DX;	w DX znajduje sie bufor (OffSet PLIK)
        XOR     BP,BP;		nadajemy 0, w przyszlosci bedzie wskazywac aktalna linijke
        XOR     BX,BX;		szykuje bx do licznika linii
        MOV     DI,DX;		laduje w DI przesuniecie do bufora
        MOV     AL,0DH;		13 - Enter;
LICZ_LINIE:
        REPNE   SCASB;		szukaj al w DI, koniec kiedy znajdzie, albo koncza sie bajty
        JCXZ    SHORT KONIEC_LICZENIA;
        INC     BX;		jezeli jeszcze jest to sie zwieksza 
        MOV     SI,BX;		wpisuje ilosc linii naliczonych
        SHL     SI,01H;
        INC     DI; 		zwieksza DI aby odczytac adres
        MOV     WORD PTR [SI+LINIE],DI;	do linie wpisuje linijke z DI
        DEC     DI;		odstanawia DI do dalszej pracy
        JMP     SHORT LICZ_LINIE; 	przedluza liczenie linii
KONIEC_LICZENIA:
        MOV     WORD PTR [ILE_LINII],BX;ilosc naliczonych linnni
        CALL    VIDEO_INIT;	inicjalizacja video rezimu
HIDE_CURSOR:
        MOV     AH,01H;
        MOV     CH,20H;	5 bit = 0 - hide
        INT     10H;
DRAW_BACKGROUND:
        MOV     AX,02B0H;	AH - kolor (tlo symbol), AL - sybmol
        MOV     ES,WORD PTR [VIDEO_MEMORY];	ES segment pokrywa Video pamiecia
        XOR     DI,DI; 		szykuje DI do uzywania w cyklu zapelnienia
        MOV     CX,1920;	bedzie zapelniono 1920 simboli (80 ostatnich nie trzeba
        REP     STOSW;		zapelnienie (inc DI,2)
DRAW_DOWN_LINE:
        MOV     AX,0020H;	dolna linijka (20h - space)
        MOV     CL,80;		CX byl 0000h
        REP     STOSW;
        MOV     AH,0FH;		kolor  (tla,sybola)
        LEA     SI,DOWN_LINE;	trzesc do pisania
        ADD     CX,10;		poczatek pisania od brzegu
	MOV     DL,24;		na ktorej linijce pisac
        CALL    WRITE_LINE;	pisze dolny tekst
DRAW_NAME_LINE:
        MOV     AX,01020H;	AH - kolor (tlo symbol), BL - sybmol
        MOV     ES,WORD PTR [VIDEO_MEMORY];	ES segment pokrywa Video pamiecia
        MOV     DI,80 SHL 1+2; 	szykuje DI do uzywania w cyklu zapelnienia
        MOV     CX,78;		bedzie zapelniono 1920 simboli (80 ostatnich nie trzeba
        REP     STOSW;		zapelnienie (inc DI,2)
DRAW_FILE_NAME:
        LEA     SI,Nazwa;
        MOV     CL,40;		wyliczanie srodka pisania
        MOV     AL,BYTE PTR [NAZWA_LEN];
	SHR     AL,01H;
        SUB     CL,AL;		koniec wyliczania w cl
        MOV     DL,01H;		linijka do pisania
        MOV     AH,0012H;	kolor
        CALL    WRITE_LINE;	pisze tekst
RYSUJ_TEXT: 
        MOV     CX,4C01H;	4C=76 - dlugosc
        MOV     DX,1402H;	14=20 - ilosc linijek
        PUSH    CX;
        PUSH    DX;
        MOV     AL,80;		AX=80
        MUL     DL;		AX=80*2
        XOR     CH,CH;		CX=0001
        ADD     AX,CX;		AX=80*2+1
        SHL     AX,01h;		AX=(80*2+1)*2
	MOV	DI,AX;		DI=AX
        POP     DX;
        POP     CX;	tu bylo wyliczane poczatkowe miejsce do rysowania (DI)

        MOV     ES,WORD PTR [VIDEO_MEMORY]; 	
	MOV	AH,0Fh;		KOLOR;
	
	MOV	AL,214;		'ษ'201
	STOSW;			laduje do ekranu pod wyliczony adres DI symbol
        SHR     CX,08H;		CH<CL (4C-76)
        SHR     DX,08H;		DH<DL (14-20)

        PUSH    CX;
        MOV     BX,CX;
        SHL     BX,01H;		BX=76*2
        MOV     AL,196;		'อ'205
        REP     STOSW;		dajel zapisuje sie CL(CX) symboli
        MOV     AL,183;		'ป'187
        STOSW;
        POP     CX;
DRAW_LINE_1:
        ADD     DI,156;
        SUB     DI,BX;		DI=DI-8
        DEC     DX;
        JZ      SHORT DRAW_LINE_2;
        PUSH    CX;
        MOV     AL,'บ';		186
        STOSW;
        MOV     AL,20H;		space
        REP     STOSW;		pisze 76 (cl) spacow
        MOV     AL,'บ';		186
        STOSW;
        POP     CX;		cx posiada dlugosc 80-4 potrzebna do rysowania
        JMP     SHORT DRAW_LINE_1
DRAW_LINE_2:;           	rysuje dolna linijke
        MOV     AL,'ศ'; 	200
        STOSW;
        MOV     AL,'อ'; 	205, tu uzywa sie cx=76
        REP     STOSW;
        MOV     AL,'ผ'; 	188
        STOSW;

        MOV     WORD PTR [TERAZ_LINIA],CX;	cx=0
PISZ:
        MOV     BX,BP
        ADD     BX,WORD PTR [TERAZ_LINIA]
        SHL     BX,01H;

        MOV     SI,WORD PTR [LINIE+BX];
        PUSH    CS;	ES<CS
        POP     ES;
        LEA     DI,LINIA
        XOR     DX,DX;
ROZSZERZAJ:
        LODSB;			do al laduje DS:SI
        CMP     AL,0DH;		13 - Enter;
        JE      SHORT KONIEC_ROZSZERZANIA;
        INC     DX;
        CMP     AL,09H;		tabulacja
        JNE     SHORT NIE_TABULACJA;
TABULACJA:
        MOV     CX,DX
        MOV     BL,08H;		jezeli tabulacja to rob 8 odstepow
;			DX posiada pozycje
;			nam trzeba zrobic tabulacje rowna 8 odstepow
;			ale jezeli pozycja nie dzieli sie na 8 to trzeba
;			przesunac wskaznik pozycji na tyle jednostek,
;			zeby bylo podzielne
DO_MNOGOSCI_8:
        MOV     AX,DX;	do ax wpisujemy pozycje dx;
        DIV     BL;	nam trzeba sprawdzic czy podzelne przez 8
        OR      AH,AH;	jezeli tak to ah=0
        JZ      JEST_MNOGOSC_8;	znaczy mozna robic juz tabulacje
        INC     DX;	w przeciwnym wypadku dodajemy o jedynke i cyklujemy
        JMP     SHORT DO_MNOGOSCI_8;
JEST_MNOGOSC_8:
        PUSH    DX;
        SUB     DX,CX;
        MOV     CX,DX;		obliczamy cx - ile razy trzeba przeskoczyc do przodu
        POP     DX;
        MOV     AL,20H;		space
        REP     STOSB;		pisze cx wyliczonych spacow
NIE_TABULACJA:
        STOSB;			al > ES:DI
        JMP     SHORT ROZSZERZAJ;
KONIEC_ROZSZERZANIA:
        STOSB;
        MOV     DX,WORD PTR [TERAZ_LINIA];	jaka teraz aktualna linia[1..21]
        MOV     CL,03H;		poczatek zaczyna sie od 3 linijki
        ADD     DL,CL;		na jakiej linijce pisac
        LEA     SI,LINIA;	adres linijki do pisania
	
	CALL	SHIFT_SI;
        MOV     AH,0FH;		kolor
        CALL    WRITE_LINE;	pisze linijke
        INC     WORD PTR [TERAZ_LINIA]
        MOV     AX,WORD PTR [ILE_LINII]
        CMP     WORD PTR [TERAZ_LINIA],AX
        JA      SHORT CZEKAJ_NA_KLAWISZ
        MOV     AX,WORD PTR [TERAZ_LINIA]
        MOV     CL,19
        DIV     CL
        OR      AH,AH
        JNZ     SHORT PISZ
CZEKAJ_NA_KLAWISZ:
        MOV     AH,07H;		czeka na nacisniecie klawisza
        INT     21H;
        CLI;			czysci IF wskaznik
        CMP     AL,ESC_KEY;	do AL jest wpisany kod klawiszu
        JE      SHORT ZAKONCZ;	Esc - wyjscie
        CMP     AL,UP_KEY;	do gory
        JNE     @@2;		jezeli nie, to patrz nastepny
        OR      BP,BP;		sprawdza czy mozna podjac do gory bp=0
        JZ      SHORT CZEKAJ_NA_KLAWISZ;
        DEC     BP;		jezeli mozna to zmniejsz o 1
SKOK:
        JMP     RYSUJ_TEXT;	rysuje nowy tekst
@@2:
        CMP     AL,DOWN_KEY;	do dolu
        JNE     @@3;		jezeli nie to patrz nastepny
        MOV     AX,BP;		BP ktory teraz jest numer linijki wyswietlany nie na ekranie
        ADD     AX,WORD PTR [TERAZ_LINIA];	Teraz_linia - jaka na ekranie linia
        DEC     AX;
        CMP     AX,WORD PTR [ILE_LINII];	porownuje terazniejszy numer z maksymalnym
        JAE     SHORT CZEKAJ_NA_KLAWISZ;	jezeli nie mozna, to czekaj na klawisz 
        INC     BP;		jezeli mozna to zwieksz o 1
        JMP     SHORT SKOK;	skok do rysowania
@@3:
        CMP     AL,HOME_KEY;	na poczatek
        JNE     @@4;		jezeli nie, to sprawdzaj nastepny klawisz
@@33:
        XOR     BP,BP;		bx=0;
        JMP     SHORT SKOK; 	rysuje poczatkowy
@@4:
        CMP     AL,END_KEY;		na koniec
        JNE     @@5;		jezeli nie, to sprawdzaj nastepnego klawisza
@@44:
        MOV     AX,WORD PTR [ILE_LINII];
        CMP     AX,CX
@@444:
        JBE     SHORT CZEKAJ_NA_KLAWISZ;
WIECEJ_NIZ_19:
	MOV	BP,AX;		idzie na koniec
	SUB	BP,18;
        JMP     SHORT SKOK;	rysowanie
@@5:
        CMP     AL,PGDOWN_KEY;	do dolu strone
        JNE     @@6;		jezeli nie to sprawdzaj nastepny klawisz
        MOV     AX,WORD PTR [ILE_LINII];
        MOV     BX,BP
        ADD     BX,CX
        SUB     AX,BX
        JC      @@444
@@55:
        CMP     AX,CX
        JBE     @@44
        ADD     BP,CX
        JMP     SHORT SKOK;	rysowanie
@@6:
        CMP     AL,PGUP_KEY;	strona do gory
        JNE     @@7;SHORT CZEKAJ_NA_KLAWISZ;	jezeli nie to czekaj dalej na klawisz
        CMP     BP,CX
        JBE     @@33
        SUB     BP,CX
        JMP     SHORT SKOK;	rysowanie
@@7:
	CMP	AL,LEFT_KEY;
	JNE	@@8;
	CMP	HOR_POS,0;
	JE	SHORT CZEKAJ_NA_KLAWISZ;
	DEC	WORD PTR [HOR_POS];
	JMP	SHORT SKOK;
@@8:
	CMP	AL,RIGTH_KEY;
	JNE	SHORT CZEKAJ_NA_KLAWISZ;
	INC	WORD PTR [HOR_POS];
	JMP	SHORT SKOK;
ZAKONCZ:

;procedura sluzaca do inicjalizacji VIDEO
;funkcja 0F
;AH - ilosc stronic
;AL - aktualny rezim
;BH - aktualna strona
VIDEO_INIT      PROC;
        MOV	AX,0003h;
	INT     10H;
	RET;
VIDEO_INIT      ENDP;

;procedura poprawnie przesuwa SI przesuniecie
SHIFT_SI	PROC;
	PUSH	CX;
	MOV	CX,HOR_POS;
RE:
	CMP	HOR_POS,0;	sprawdza czy trzeba cis robic
	JE	SHORT OUT;		
	MOV	AL,[SI];	jezeli tak to sprawdzamy
	CMP	AL,0DH;
	JE	SHORT OUT;		jezeli Enter to zatrzymujemy przesuwanie
	INC	SI;		w innym wypadku przedluzamy prace
	LOOP	RE;
OUT:	
	POP	CX;
	RET;
ENDP;

;wyprowadza na ekran linijke
;DL - na jakiej linijce pisac
;CL - na jakim rzedzie
;DS:SI - adres lancuchu
;AH - kolor tekstu
WRITE_LINE      PROC;
	PUSH    AX;	zachowuje ax, gdyz bedzie zmieniany
	MOV     AL,80;
	MUL     DL;	szukanie odpowiedniego miejsca
	XOR     CH,CH;
	ADD     AX,CX;	dodawanie rzedu
	SHL     AX,01H;	zwiekszenie na 2 razy
	mov di,ax;
        POP     AX;	odnowa ax;
        MOV     ES,WORD PTR [VIDEO_MEMORY];
        MOV     CX,74;	ilosc pisanych symboli
WRITE_LINE_1:
        LODSB;		do al pakuje kolejny symbol (DS:SI)
        CMP     AL,0DH;		13 - Enter
        JE      SHORT WRITE_LINE_2;	jezeli Enter to wyjscie
        STOSW;	laduje sybmol AX(ES:DI)
        LOOP    WRITE_LINE_1;	przedluza pisanie
WRITE_LINE_2:
        PUSH    CS; ES<CS
        POP     ES; gdyz w ES byl segment VIDEO 
        RET;	exit
WRITE_LINE      ENDP;

;pisze tekst na ekranie
;dx - jego przesuniecie
WRITE_TEXT PROC;
	MOV AH,09H;
	INT 21H;
	RET;
ENDP;

;wyprowadza error
WRITE_ERROR PROC;
	LEA DX,MSG_ERROR;
	CALL WRITE_TEXT;
	RET;
ENDP

NO_PARAM	DB	'      *   *   *', 13, 10;
		DB      'TextViewer version 1.00', 13, 10;
		DB	'Autor:   Miroslav Kisly', 13, 10;
		DB	'Data:    2002 10 12', 13, 10;
		DB	'      *   *   *', 13, 10;
		DB	'Ussage:  TxtView [FileName]', 13, 10;
		DB	'Example: TxtView ReadMe.txt', 13 , 10, '$';
		
MSG_Error	DB	'Sorry, I don''t find your file!', 13, 10, '$';

DOWN_LINE       DB      27, 26, ' ', 24, '', 25, ', PageDown, PageUp, Home, End  ';
                DB      'Text Scroll, ESC - Exit', 0Dh;
VIDEO_MEMORY    DW      0B800H;   pamiec ekranu
NAZWA_LEN       DB      ?;
LINIA           DB      256*2 DUP (?);
NAZWA           DB      160 DUP (?);
ILE_LINII       DW      ?;
HOR_POS		DW	0;
TERAZ_LINIA     DW      ?;
LINIE           DW      4000 DUP (?);
PLIK            DB      50000 DUP (?);

SEG_A   ENDS
END     START
