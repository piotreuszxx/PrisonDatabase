--SELECT * FROM Osoby

--SELECT * FROM Pracownicy

--SELECT * FROM Wiezniowie

--SELECT * FROM Odwiedzajacy 

--SELECT * FROM Pobyty

--SELECT * FROM Odwiedziny 

SELECT * FROM Cele

--SELECT * FROM Przepustki

--SELECT * FROM Zajecia_Odbyte

--SELECT * FROM Zajecia

--SELECT * FROM Kary_I_Ograniczenia

--SELECT * FROM Wyroki

SELECT * FROM Bloki

SELECT * FROM Pracownicy

SELECT * FROM Osoby WHERE PESEL = '20123456789';

SELECT * FROM Odwiedzajacy WHERE PESEL = '20123456789';

SELECT * FROM Odwiedziny WHERE PESEL_odwiedzajacego = '20123456789';