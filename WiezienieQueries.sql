-- Zapytanie 1
-- Scenariusz: W wiêzieniu jest coraz mniej miejsca. Dyrektor wiêzienia podpisa³ umowê z innym wiêzieniem na transport najagresywniejszych
--			   (maj¹cych co najmniej 5 kar na koncie) wiêŸniów do innego wiêzienia.
-- Zapytanie: Lista wiêŸniów (dane personalne oraz iloœæ kar), którzy mieli 5 lub wiêcej kar.
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
-- Scenariusz: Centralny Zarz¹d S³u¿by Wiêziennej prosi dyrektora wiêzienia o wys³anie statystyki nt. iloœci pobytów w tym
--			   wiêzieniu, uzasadnieñ wyroków, które ich dotycz¹ oraz œredni wiek wiêŸniów w chwili osadzenia
-- Zapytanie: Pogrupowana lista uzasadnieñ w wyrokach, iloœci pobytów powi¹zanych z nimi oraz œredni wiek wiêŸniów w chwili osadzenia
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
-- Scenariusz: Do wiêzienia przywieziono niebezpiecznego prowadz¹cego z ETI. Aby go osadziæ, trzeba znaleŸæ
--			   bloki w wiêzieniu w których nie
--			   znajduj¹ siê ¿adni wiêŸniowie, gdy¿ prowadz¹cy stanowi zagro¿enie dla innych osadzonych.
-- Zapytanie: Zwróæ wszystkie bloki, w których w celach nie ma ani jednego wiêŸnia od 19 stycznia 2024
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
-- Scenariusz: W nagrodê za spokojny okres organizowany jest turniej pi³ki no¿nej miêdzy wiêŸniami a stra¿nikami,
--			   dyrektor chce dyrektor chce zaprosiæ wszystkich wiêŸniów którzy odbyli zajêcia "Sport"
--			   oraz nie s¹ agresywni.
-- Zapytanie: Lista wszystkich wiêŸniów (Imiona, nazwiska oraz cele w celu zaproszenia), którzy odbyli zajêcia "Sport",
--			  a w uwagach nie maj¹ "Agresywny/a".
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
-- Scenariusz: Wiêzienie dosta³o dofinansowanie na remonty, dyrektor chce znaleŸæ bloki o najstarszej dacie remontu,
--			   aby go zremontowaæ. Jednak remont musi obejmowaæ bloki, które nie mia³y remontu od przynajmniej 36 miesiêcy,
--			   bo tylko takie bloki obejmuje dofinansowanie.
-- Zapytanie: ZnajdŸ bloki o najstarszych datach remontu, które nie by³y remontowane od co najmniej 36 miesiêcy.
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
-- Scenariusz: Sprz¹taczka w wiêzieniu podejrzewa, ¿e w dniu 15 lutego 2023 podczas odwiedzin odwiedzaj¹cy
--             przekaza³ coœ nielegalnie wiêŸniowi. Dodatkowo, sprz¹taczka pamiêta, ¿e widzia³a tego samego wiêŸnia kiedyœ na zajêciach sportowych.
--			   Stra¿nik po rozmowie ze sprz¹taczk¹ chce sprawdziæ, który to by³ wiêzieñ.
-- Zapytanie: Wyœwietl dane (PESEL, imie, nazwisko, ksywê) wszystkich wiêŸniów odwiedzonych w dniu 15 lutego 2023,
--            którzy uczestniczyli w zajêciach sportowych w przesz³oœci
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
-- Scenariusz: Wiêzieñ poinformowa³ stra¿nika, ¿e jego kolega zosta³ pobity w bloku AA przez innego wiêŸnia o ksywie "£ysy",
--			   ale nie wiedzia³, jak on siê nazywa. Stra¿nik, by zaj¹æ siê spraw¹, szuka wiêcej informacji.
-- Zapytanie: Wypisz (PESEL i ksywê) wszystkich wiêŸniów z bloku AA o ksywie "£ysy"
SELECT Wiezniowie.PESEL, Wiezniowie.Ksywa
	FROM Wiezniowie
	JOIN Pobyty ON Wiezniowie.PESEL = Pobyty.PESEL
	JOIN Cele ON Pobyty.Numer_celi = Cele.Numer_celi
	JOIN Bloki ON Cele.ID_Bloku = Bloki.ID_Bloku
		WHERE Bloki.ID_Bloku = 'AA' AND Wiezniowie.Ksywa = '£ysy';


