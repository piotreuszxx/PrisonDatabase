CREATE TABLE Osoby (
    PESEL CHAR(11) PRIMARY KEY CHECK (
		PESEL LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
	) NOT NULL,

    Imie NVARCHAR(20) CHECK (
		Imie LIKE N'[A-Z¥ÆÊ£ÑÓŒ¯]%' AND
		(Imie NOT LIKE N'%[^A-Z¥ÆÊ£ÑÓŒ¯a-z¹æê³ñóœŸ¿]%') AND
		LEN(Imie) BETWEEN 3 AND 20
	) NOT NULL,

    Nazwisko NVARCHAR(30) CHECK (
		Nazwisko LIKE N'[A-Z¥ÆÊ£ÑÓŒ¯]%' AND
		(Nazwisko NOT LIKE N'%[^A-Z¥ÆÊ£ÑÓŒ¯a-z¹æê³ñóœŸ¿]%') AND
		LEN(Nazwisko) BETWEEN 3 AND 30
	) NOT NULL,

    Data_urodzenia DATE NOT NULL
);


CREATE TABLE Wiezniowie (
    PESEL CHAR(11) PRIMARY KEY NOT NULL,
    Ksywa NVARCHAR(20) CHECK (
        Ksywa LIKE N'[A-Z¥ÆÊ£ÑÓŒ¯]%' AND
		(Ksywa NOT LIKE N'%[^A-Z¥ÆÊ£ÑÓŒ¯a-z¹æê³ñóœŸ¿]%') AND
		LEN(Ksywa) BETWEEN 3 AND 20
	) NOT NULL ,
    
    Zainteresowania NVARCHAR(60) CHECK (
        Zainteresowania LIKE N'[A-Z¥ÆÊ£ÑÓŒ¯]%' AND 
        (Zainteresowania NOT LIKE N'%[^A-Z¥ÆÊ£ÑÓŒ¯a-z¹æê³ñóœŸ¿ ,-]%') AND 
        LEN(Zainteresowania) BETWEEN 3 AND 60
	) NOT NULL,

    FOREIGN KEY (PESEL) REFERENCES Osoby(PESEL)
);

CREATE TABLE Bloki (
    ID_Bloku VARCHAR(2) PRIMARY KEY CHECK (
        ID_Bloku LIKE '[A-Z][A-Z]'
    ) NOT NULL,

    Data_ostatniego_remontu DATE NOT NULL
);


CREATE TABLE Pracownicy (
    PESEL CHAR(11) PRIMARY KEY NOT NULL,

    Email NVARCHAR(50) CHECK(
        (Email LIKE N'%@gmail.com' OR Email LIKE N'%@o2.pl') AND 
        Email NOT LIKE N'%[^a-zA-Z0-9@.]%'
	) NOT NULL,

    Telefon CHAR(9) CHECK (Telefon LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') NOT NULL,

    Miasto NVARCHAR(30) CHECK (
        Miasto LIKE N'[A-Z¥ÆÊ£ÑÓŒ¯]%' AND 
        (Miasto NOT LIKE N'%[^A-Z¥ÆÊ£ÑÓŒ¯a-z¹æê³ñóœŸ¿]%') AND 
        LEN(Miasto) BETWEEN 2 AND 30
	) NOT NULL,

    Ulica NVARCHAR(60) CHECK (
        Ulica LIKE N'[0-9A-Z¥ÆÊ£ÑÓŒ¯]%' AND 
        (Ulica NOT LIKE N'%[^0-9A-Z¥ÆÊ£ÑÓŒ¯a-z¹æê³ñóœŸ¿ ,.-]%') AND 
        LEN(Ulica) BETWEEN 3 AND 60
    ) NOT NULL,

    Stanowisko NVARCHAR(20) CHECK (
        Stanowisko NOT LIKE N'%[^a-z¹æê³ñóœŸ¿]%' AND 
        LEN(Stanowisko) BETWEEN 4 AND 20
	) NOT NULL,

	FOREIGN KEY (PESEL) REFERENCES Osoby(PESEL),

	PESEL_szefa CHAR(11),

    ID_Bloku VARCHAR(2) NOT NULL,

	FOREIGN KEY (PESEL_szefa) REFERENCES Pracownicy(PESEL),

    FOREIGN KEY (ID_Bloku) REFERENCES Bloki(ID_Bloku) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Odwiedzajacy (
    PESEL CHAR(11) PRIMARY KEY NOT NULL,

    Telefon CHAR(9) CHECK (Telefon LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') NOT NULL,

    Miasto NVARCHAR(30) CHECK (
        Miasto LIKE N'[A-Z¥ÆÊ£ÑÓŒ¯]%' AND 
        (Miasto NOT LIKE N'%[^A-Z¥ÆÊ£ÑÓŒ¯a-z¹æê³ñóœŸ¿]%') AND 
        LEN(Miasto) BETWEEN 2 AND 30
    ) NOT NULL,

    Ulica NVARCHAR(60) CHECK (
        Ulica LIKE N'[0-9A-Z¥ÆÊ£ÑÓŒ¯]%' AND 
        (Ulica NOT LIKE N'%[^0-9A-Z¥ÆÊ£ÑÓŒ¯a-z¹æê³ñóœŸ¿ ,.-]%') AND 
        LEN(Ulica) BETWEEN 3 AND 60
    ) NOT NULL,
    
    FOREIGN KEY (PESEL) REFERENCES Osoby(PESEL) ON DELETE CASCADE
);

CREATE TABLE Cele (
    Numer_celi INT PRIMARY KEY CHECK (Numer_celi BETWEEN 0 AND 400) NOT NULL,
    ID_Bloku VARCHAR(2) NOT NULL,
    Ilosc_lozek INT CHECK (Ilosc_lozek BETWEEN 1 AND 10) NOT NULL,
    Metraz INT CHECK (Metraz BETWEEN 3 AND 20) NOT NULL,
    Media BIT NOT NULL,

    FOREIGN KEY (ID_Bloku) REFERENCES Bloki(ID_Bloku) ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE TABLE Pobyty (
    ID_Pobytu INT PRIMARY KEY NOT NULL,
    Data_rozpoczecia DATE NOT NULL,
    Data_zakonczenia DATE NOT NULL,
    Data_mozliwosci_ub_o_zwol_war DATE,
    Wspolpracuje BIT NOT NULL,
    Inne_uwagi NVARCHAR(60) CHECK (
        Inne_uwagi LIKE N'[A-Z¥ÆÊ£ÑÓŒ¯]%' AND 
        (Inne_uwagi NOT LIKE N'%[^A-Z¥ÆÊ£ÑÓŒ¯a-z¹æê³ñóœŸ¿. ,-]%') AND 
        LEN(Inne_uwagi) BETWEEN 3 AND 60
    ),
	PESEL CHAR(11) NOT NULL,
    Numer_celi INT CHECK (Numer_celi BETWEEN 0 AND 400) NOT NULL,

    FOREIGN KEY (PESEL) REFERENCES Wiezniowie(PESEL),
    FOREIGN KEY (Numer_celi) REFERENCES Cele(Numer_celi)
);


CREATE TABLE Odwiedziny (
    ID_odwiedzin INT PRIMARY KEY CHECK (ID_odwiedzin >= 0 AND ID_odwiedzin <= 9999999),
    Data_odwiedzin DATE NOT NULL,
    Godzina TIME NOT NULL,
    PESEL_odwiedzajacego CHAR(11) NOT NULL,
    ID_pobytu INT NOT NULL,
    
    FOREIGN KEY (PESEL_odwiedzajacego) REFERENCES Odwiedzajacy(PESEL) ON DELETE CASCADE,
    FOREIGN KEY (ID_pobytu) REFERENCES Pobyty(ID_Pobytu)
);

CREATE TABLE Kary_I_Ograniczenia (
    ID_kary INT PRIMARY KEY NOT NULL,

    Rodzaj NVARCHAR(25) CHECK (
        Rodzaj LIKE N'[A-Z¥ÆÊ£ÑÓŒ¯]%' AND 
        (Rodzaj NOT LIKE N'%[^A-Z¥ÆÊ£ÑÓŒ¯a-z¹æê³ñóœŸ¿. -]%') AND 
        LEN(Rodzaj) BETWEEN 3 AND 25
    ) NOT NULL,

    Data_rozpoczecia DATE NOT NULL,

    Godzina_rozpoczecia TIME NOT NULL,

    Data_zakonczenia DATE NOT NULL,

    Godzina_zakonczenia TIME NOT NULL,

    ID_pobytu INT NOT NULL,

    FOREIGN KEY (ID_pobytu) REFERENCES Pobyty(ID_Pobytu)
);

CREATE TABLE Wyroki (
    Sygnatura_akt NVARCHAR(30) PRIMARY KEY CHECK (
		Sygnatura_akt NOT LIKE N'%[^A-Z0-9 -/]%' AND
		LEN(Sygnatura_akt) BETWEEN 5 AND 30
	) NOT NULL,

    Sad NVARCHAR(100) CHECK (
        Sad LIKE N'[A-Z¥ÆÊ£ÑÓŒ¯]%' AND
		Sad NOT LIKE N'%[^A-Z¥ÆÊ£ÑÓŒ¯a-z¹æê³ñóœŸ¿ -]%' AND
		LEN(Sad) BETWEEN 10 AND 100
    ) NOT NULL,

    Uzasadnienie NVARCHAR(50) CHECK (
        Uzasadnienie LIKE N'[A-Z¥ÆÊ£ÑÓŒ¯]%' AND
		Uzasadnienie NOT LIKE N'%[^A-Z¥ÆÊ£ÑÓŒ¯a-z¹æê³ñóœŸ¿ -]%' AND
		LEN(Uzasadnienie) BETWEEN 5 AND 50
    ) NOT NULL,

    Dlugosc_kary INT CHECK (
        Dlugosc_kary BETWEEN 1 AND 100
    ) NOT NULL,

    ID_pobytu INT NOT NULL,

    FOREIGN KEY (ID_pobytu) REFERENCES Pobyty(ID_Pobytu)
);

CREATE TABLE Przepustki (
    ID_przepustki INT PRIMARY KEY CHECK (ID_przepustki >= 0 AND ID_przepustki <= 9999999) NOT NULL,
    Data_rozpoczecia DATE NOT NULL,
    Godzina_rozpoczecia TIME NOT NULL,
    Data_zakonczenia DATE NOT NULL,
    Godzina_zakonczenia TIME NOT NULL,
    ID_pobytu INT NOT NULL,

    FOREIGN KEY (ID_pobytu) REFERENCES Pobyty(ID_Pobytu)
);

CREATE TABLE Zajecia (
    ID_zajecia CHAR(7) PRIMARY KEY CHECK (
        ID_zajecia LIKE '[A-Z][A-Z][A-Z][A-Z][A-Z][0-9][0-9]'
    ) NOT NULL,
    Nazwa_zajecia NVARCHAR(25) CHECK (
        Nazwa_zajecia LIKE N'[A-Z¥ÆÊ£ÑÓŒ¯]%' AND 
        (Nazwa_zajecia NOT LIKE N'%[^A-Z¥ÆÊ£ÑÓŒ¯a-z¹æê³ñóœŸ¿ -]%') AND 
        LEN(Nazwa_zajecia) BETWEEN 3 AND 25
    ) NOT NULL,
    Dzien_tygodnia NVARCHAR(20) CHECK (
        Dzien_tygodnia LIKE N'[A-Z¥ÆÊ£ÑÓŒ¯a-z¹æê³ñóœŸ¿ ]%' AND 
        (Dzien_tygodnia NOT LIKE N'%[^A-Z¥ÆÊ£ÑÓŒ¯a-z¹æê³ñóœŸ¿ ]%') AND 
        LEN(Dzien_tygodnia) BETWEEN 3 AND 20
    ) NOT NULL,
    Godzina_rozpoczecia TIME NOT NULL,
    Godzina_zakonczenia TIME NOT NULL
);

CREATE TABLE Zajecia_Odbyte (
    ID_odbytego_zajecia INT PRIMARY KEY CHECK (ID_odbytego_zajecia >= 0 AND ID_odbytego_zajecia <= 9999999) NOT NULL,
    Data_odbycia DATE NOT NULL,
    ID_pobytu INT NOT NULL,
    ID_zajecia CHAR(7) NOT NULL,

    FOREIGN KEY (ID_pobytu) REFERENCES Pobyty(ID_Pobytu),
    FOREIGN KEY (ID_zajecia) REFERENCES Zajecia(ID_zajecia)
);

