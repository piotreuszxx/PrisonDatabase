-- Zapytanie 1
-- Scenariusz: W wi�zieniu jest coraz mniej miejsca. Dyrektor wi�zienia podpisa� umow� z innym wi�zieniem na transport najagresywniejszych
--			   (maj�cych co najmniej 5 kar na koncie) wi�ni�w do innego wi�zienia.
-- Zapytanie: Lista wi�ni�w (dane personalne oraz ilo�� kar), kt�rzy mieli 5 lub wi�cej kar.
DROP VIEW IF EXISTS Wiezniowie_5_kar;
GO
CREATE VIEW Wiezniowie_5_kar AS
SELECT 
    Wiezniowie.PESEL,  
    Osoby.Imie, 
    Osoby.Nazwisko,
    COUNT(Kary_I_Ograniczenia.ID_kary) AS Ilosc_kar
		FROM Wiezniowie
		JOIN Pobyty ON Wiezniowie.PESEL = Pobyty.PESEL
		JOIN Kary_I_Ograniczenia ON Pobyty.ID_Pobytu = Kary_I_Ograniczenia.ID_pobytu
		JOIN Osoby ON Wiezniowie.PESEL = Osoby.PESEL
			GROUP BY Wiezniowie.PESEL, Osoby.Imie, Osoby.Nazwisko
			HAVING COUNT(Kary_I_Ograniczenia.ID_kary) >= 5;
GO
SELECT * FROM Wiezniowie_5_kar
ORDER BY Ilosc_kar DESC;
----------------------------------------------------------------------------------------------------------------------------------------------------
-- Zapytanie 2
-- Scenariusz: Centralny Zarz�d S�u�by Wi�ziennej prosi dyrektora wi�zienia o wys�anie statystyki nt. ilo�ci pobyt�w w tym
--			   wi�zieniu, uzasadnie� wyrok�w, kt�re ich dotycz� oraz �redni wiek wi�ni�w w chwili osadzenia
-- Zapytanie: Pogrupowana lista uzasadnie� w wyrokach, ilo�ci pobyt�w powi�zanych z nimi oraz �redni wiek wi�ni�w w chwili osadzenia
SELECT 
    Wyroki.Uzasadnienie,
    COUNT(Pobyty.ID_Pobytu) AS Ilosc_Pobytow,
    AVG(DATEDIFF(YEAR, Osoby.Data_urodzenia, Pobyty.Data_rozpoczecia)) AS Sredni_Wiek_Osadzonego
		FROM Wyroki
		JOIN Pobyty ON Wyroki.ID_pobytu = Pobyty.ID_Pobytu
		JOIN Wiezniowie ON Pobyty.PESEL = Wiezniowie.PESEL
		JOIN Osoby ON Wiezniowie.PESEL = Osoby.PESEL
			GROUP BY  Wyroki.Uzasadnienie
			ORDER BY Ilosc_Pobytow DESC;
----------------------------------------------------------------------------------------------------------------------------------------------------
-- Zapytanie 3
-- Scenariusz: Do wi�zienia przywieziono niebezpiecznego prowadz�cego z ETI. Aby go osadzi�, trzeba znale��
--			   bloki w wi�zieniu w kt�rych nie
--			   znajduj� si� �adni wi�niowie, gdy� prowadz�cy stanowi zagro�enie dla innych osadzonych.
-- Zapytanie: Zwr�� wszystkie bloki, w kt�rych w celach nie ma ani jednego wi�nia od 19 stycznia 2024
SELECT Bloki.ID_Bloku AS Kandydaci_Do_Remontu
	FROM Bloki
	WHERE NOT EXISTS
	(
		SELECT 1 FROM Cele
		JOIN Pobyty ON Cele.Numer_celi = Pobyty.Numer_celi
			WHERE Bloki.ID_Bloku = Cele.ID_Bloku AND
			(Pobyty.ID_Pobytu IS NULL OR Pobyty.Data_zakonczenia < '2024-01-19')
	);
----------------------------------------------------------------------------------------------------------------------------------------------------
-- Zapytanie 4
-- Scenariusz: W nagrod� za spokojny okres organizowany jest turniej pi�ki no�nej mi�dzy wi�niami a stra�nikami,
--			   dyrektor chce dyrektor chce zaprosi� wszystkich wi�ni�w kt�rzy odbyli zaj�cia "Sport"
--			   oraz nie s� agresywni.
-- Zapytanie: Lista wszystkich wi�ni�w (Imiona, nazwiska oraz cele w celu zaproszenia), kt�rzy odbyli zaj�cia "Sport",
--			  a w uwagach nie maj� "Agresywny/a".
SELECT DISTINCT
    Osoby.Imie, 
    Osoby.Nazwisko, 
	Wiezniowie.Ksywa,
    Cele.Numer_celi
		FROM Wiezniowie
			JOIN Osoby ON Wiezniowie.PESEL = Osoby.PESEL
			JOIN Pobyty ON Wiezniowie.PESEL = Pobyty.PESEL
			JOIN Zajecia_Odbyte ON Pobyty.ID_Pobytu = Zajecia_Odbyte.ID_pobytu
			JOIN Zajecia ON Zajecia_Odbyte.ID_zajecia = Zajecia.ID_zajecia
			JOIN Cele ON Pobyty.Numer_celi = Cele.Numer_celi
				WHERE Zajecia.Nazwa_zajecia = 'Sport' AND
				Wiezniowie.PESEL NOT IN (SELECT PESEL FROM Pobyty WHERE Inne_uwagi LIKE '%Agresywn%');

----------------------------------------------------------------------------------------------------------------------------------------------------
-- Zapytanie 5
-- Scenariusz: Wi�zienie dosta�o dofinansowanie na remonty, dyrektor chce znale�� bloki o najstarszej dacie remontu,
--			   aby go zremontowa�. Jednak remont musi obejmowa� bloki, kt�re nie mia�y remontu od przynajmniej 36 miesi�cy,
--			   bo tylko takie bloki obejmuje dofinansowanie.
-- Zapytanie: Znajd� bloki o najstarszych datach remontu, kt�re nie by�y remontowane od co najmniej 36 miesi�cy.
SELECT ID_Bloku, Data_ostatniego_remontu
FROM Bloki
WHERE ID_Bloku IN
	(
    SELECT ID_Bloku
		FROM Bloki
			GROUP BY ID_Bloku
			HAVING DATEDIFF(MONTH, MAX(Data_ostatniego_remontu), GETDATE()) >= 36
	)
GROUP BY ID_Bloku, Data_ostatniego_remontu
ORDER BY Data_ostatniego_remontu;
----------------------------------------------------------------------------------------------------------------------------------------------------
-- Zapytanie 6
-- Scenariusz: Sprz�taczka w wi�zieniu podejrzewa, �e w dniu 15 lutego 2023 podczas odwiedzin odwiedzaj�cy
--             przekaza� co� nielegalnie wi�niowi. Dodatkowo, sprz�taczka pami�ta, �e widzia�a tego samego wi�nia kiedy� na zaj�ciach sportowych.
--			   Stra�nik po rozmowie ze sprz�taczk� chce sprawdzi�, kt�ry to by� wi�zie�.
-- Zapytanie: Wy�wietl dane (PESEL, imie, nazwisko, ksyw�) wszystkich wi�ni�w odwiedzonych w dniu 15 lutego 2023,
--            kt�rzy uczestniczyli w zaj�ciach sportowych w przesz�o�ci
SELECT Wiezniowie.PESEL,
	   Osoby.Imie,
	   Osoby.Nazwisko,
	   Wiezniowie.Ksywa
		FROM Wiezniowie
		JOIN Osoby ON Wiezniowie.PESEL = Osoby.PESEL
		JOIN Pobyty ON Wiezniowie.PESEL = Pobyty.PESEL
		JOIN Odwiedziny ON Pobyty.ID_Pobytu = Odwiedziny.ID_pobytu
			WHERE Odwiedziny.Data_odwiedzin = '2023-02-15'
			AND Pobyty.ID_Pobytu IN
			(
				SELECT DISTINCT Zajecia_Odbyte.ID_pobytu
					FROM Zajecia_Odbyte
					JOIN Zajecia ON Zajecia_Odbyte.ID_zajecia = Zajecia.ID_zajecia
						WHERE Zajecia.Nazwa_zajecia = 'Sport'
			);

----------------------------------------------------------------------------------------------------------------------------------------------------
-- Zapytanie 7
-- Scenariusz: Wi�zie� poinformowa� stra�nika, �e jego kolega zosta� pobity w bloku AA przez innego wi�nia o ksywie "�ysy",
--			   ale nie wiedzia�, jak on si� nazywa. Stra�nik, by zaj�� si� spraw�, szuka wi�cej informacji.
-- Zapytanie: Wypisz (PESEL i ksyw�) wszystkich wi�ni�w z bloku AA o ksywie "�ysy"
SELECT Wiezniowie.PESEL, Wiezniowie.Ksywa
	FROM Wiezniowie
	JOIN Pobyty ON Wiezniowie.PESEL = Pobyty.PESEL
	JOIN Cele ON Pobyty.Numer_celi = Cele.Numer_celi
	JOIN Bloki ON Cele.ID_Bloku = Bloki.ID_Bloku
		WHERE Bloki.ID_Bloku = 'AA' AND Wiezniowie.Ksywa = '�ysy';


