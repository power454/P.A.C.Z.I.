/*
Czas operacyjny: do 29.01.2022 EOD (23:59)
Skrypt na mail: l.kosiciarz@wit.edu.pl
Zoptymalizować struktury uwzględaniając poniższe wymagania:

* Klucze (PK, FK) - zrobione
* Constrainty pomocnicze tj. np. Check - zrobione
* Indeksy - zrobione
* Kolumny: not null - zrobione
* Procedura do zapisu zamówienia (zakladamy, że detale bez ID_ZAMOWIENIA są w tabeli jako koszyk)
Zawsze obliczac z brutto wartosc podatku, a potem wyliczyc netto!!!!!!!!!!!!!!!!!!
* procedura do zapisu faktury -
* Zebrane statystyki
* 2 przykładowe zapytania z naszej bazy danych - skomplikowane i optymalnie napisane

*/
drop table ADRES cascade constraints;
drop table FAKTURA cascade constraints;
drop table FAKTURA_SPECYFIKACJA cascade constraints;
drop table KLIENT cascade constraints;
drop table METODY_DOSTAWY cascade constraints;
drop table PRODUKT cascade constraints;
drop table ZAMOWIENIE cascade constraints;
drop table ZAMOWIENIE_DETALE cascade constraints;

--tworzenie tabeli PRODUKT
CREATE TABLE PRODUKT
(
  ID NUMBER GENERATED ALWAYS AS IDENTITY NOT NULL
, NAZWA VARCHAR2(255) NOT NULL
, CENA_JEDNOSTKOWA NUMBER NOT NULL
, CONSTRAINT PRODUKT_PK PRIMARY KEY
  (
    ID
  )
  ENABLE
);

--tworzenie tabeli adres
CREATE TABLE ADRES
(
  ID NUMBER GENERATED ALWAYS AS IDENTITY NOT NULL
, ULICA VARCHAR2(100) NOT NULL
, NR_DOMU VARCHAR2(10) NOT NULL
, NR_MIESZKANIA VARCHAR2(10)
, MIASTO VARCHAR2(100) NOT NULL
, KRAJ VARCHAR2(100) NOT NULL
, KOD_POCZTOWY VARCHAR2(30) NOT NULL
, CONSTRAINT ADRES_PK PRIMARY KEY
  (
    ID
  )
  ENABLE
);

--tworzenie tabeli klient
CREATE TABLE KLIENT
(
  ID NUMBER GENERATED ALWAYS AS IDENTITY NOT NULL
, NAZWA VARCHAR2(20) NOT NULL
, DOMYSLNY_ADRES_ID NUMBER NOT NULL
, NUMER_TELEFONU VARCHAR2(50)
, EMAIL VARCHAR2(150)
, NIP VARCHAR2(10) NOT NULL
, CONSTRAINT KLIENT_PK PRIMARY KEY
  (
    ID
  )
  ENABLE
);

--tworzenie tabeli metody dostawy
CREATE TABLE METODY_DOSTAWY
(
  ID NUMBER GENERATED ALWAYS AS IDENTITY NOT NULL
, NAZWA_FIRMY VARCHAR2(255) NOT NULL
, CONSTRAINT METODY_DOSTAWY_PK PRIMARY KEY
  (
    ID
  )
  ENABLE
);

--Tworzenie tabeli zamowienie
CREATE TABLE ZAMOWIENIE
(
  ID NUMBER GENERATED ALWAYS AS IDENTITY NOT NULL
, ID_KLIENTA NUMBER NOT NULL
, DATA_ZAMOWIENIA DATE NOT NULL
, SUMA_ZAMOWIENIA NUMBER NOT NULL
, CZY_OPLACONE NUMBER NOT NULL
, STATUS VARCHAR2(50) NOT NULL
, ID_ADRESU NUMBER NOT NULL
, ID_METODA_DOSTAWY NUMBER NOT NULL
, NUMER_LISTU_PRZEWOZOWEGO VARCHAR2(255)
, UWAGI VARCHAR2(4000)
, CONSTRAINT ZAMOWIENIE_PK PRIMARY KEY
  (
    ID
  )
  ENABLE
);

--Tworzenie tabeli Zamowienia_Detale
CREATE TABLE ZAMOWIENIE_DETALE
(
  ID NUMBER GENERATED ALWAYS AS IDENTITY NOT NULL
, ID_ZAMOWIENIA NUMBER
, ID_PRODUKTU NUMBER NOT NULL
, ILOSC NUMBER NOT NULL
, CENA_JEDNOSTKOWA NUMBER NOT NULL
, CONSTRAINT ZAMOWIENIE_DETALE_PK PRIMARY KEY
  (
    ID
  )
  ENABLE
);

--tworzenie tabeli faktura
CREATE TABLE FAKTURA
(
  ID NUMBER GENERATED ALWAYS AS IDENTITY NOT NULL
, ID_ZAMOWIENIA NUMBER NOT NULL
, DATA_FAKTURY DATE NOT NULL
, DATA_PLATNOSCI DATE
, FORMA_PLATNOSCI VARCHAR2(100) NOT NULL
, KWOTA_NETTO NUMBER NOT NULL
, KWOTA_VAT NUMBER NOT NULL
, KWOTA_BRUTTO NUMBER NOT NULL
, CONSTRAINT FAKTURA_PK PRIMARY KEY
  (
    ID
  )
  ENABLE
);

--tworzenie tabeli faktura-specyfikacja
CREATE TABLE FAKTURA_SPECYFIKACJA
(
  ID NUMBER GENERATED ALWAYS AS IDENTITY NOT NULL
, ID_FAKTURY NUMBER
, KWOTA_NETTO NUMBER NOT NULL
, KWOTA_VAT NUMBER NOT NULL
, KWOTA_BRUTTO NUMBER NOT NULL
, CONSTRAINT FAKTURA_SPECYFIKACJA_PK PRIMARY KEY
  (
    ID
  )
  ENABLE
);

--constraints
ALTER TABLE ZAMOWIENIE
ADD CONSTRAINT CZY_OPLACONE_CHK1 CHECK
(CZY_OPLACONE IN (1,0))
ENABLE;

ALTER TABLE ZAMOWIENIE
ADD CONSTRAINT STATUS_CHK2 CHECK
(STATUS IN ( 'Przyjete','W trakcie', 'Wyslane','Anulowane','Zakonczone'))
ENABLE;

ALTER TABLE METODY_DOSTAWY
ADD CONSTRAINT METODY_DOSTAWY_CHK1 CHECK
(NAZWA_FIRMY IN ('kurier DPD', 'paczkomat', 'poczta'))
ENABLE;

ALTER TABLE FAKTURA
ADD CONSTRAINT FAKTURA_CHK1 CHECK
(FORMA_PLATNOSCI IN ('przelew','gotowka'))
ENABLE;

--klucze obce

alter table ZAMOWIENIE add constraint klient_fk foreign key("ID_KLIENTA") references "KLIENT"("ID");
alter table ZAMOWIENIE add constraint adres_fk foreign key("ID_ADRESU") references "ADRES"("ID");
alter table ZAMOWIENIE add constraint metoda_dostawy_fk foreign key("ID_METODA_DOSTAWY") references "METODY_DOSTAWY"("ID");
alter table ZAMOWIENIE_DETALE add constraint zamowienie_fk foreign key("ID_ZAMOWIENIA") references "ZAMOWIENIE"("ID");
alter table ZAMOWIENIE_DETALE add constraint produkt_fk foreign key("ID_PRODUKTU") references "PRODUKT"("ID");
alter table FAKTURA add constraint zamowienie_fak_fk foreign key("ID_ZAMOWIENIA") references "ZAMOWIENIE"("ID");
alter table FAKTURA_SPECYFIKACJA add constraint zam_fak_fk foreign key("ID_FAKTURY") references "FAKTURA"("ID");

--Przykladowe dane
INSERT INTO PRODUKT (nazwa,cena_jednostkowa) VALUES ('Paczek z czekolada',4);
INSERT INTO PRODUKT (nazwa,cena_jednostkowa) VALUES ('Paczek z marmolada',3);
INSERT INTO PRODUKT (nazwa,cena_jednostkowa) VALUES ('Paczek z lukrem',2.70);

INSERT INTO adres (ulica,nr_domu,miasto,kraj,kod_pocztowy) VALUES ('Sikorskiego','2','Wroclaw','Polska','15-321');

INSERT INTO klient (nazwa,domyslny_adres_id,numer_telefonu,email,nip) VALUES ('FirmaA',1,'765832','firmaa@example','232432243');

INSERT INTO metody_dostawy (NAZWA_FIRMY) VALUES ('kurier DPD');

INSERT INTO zamowienie_detale (ID_ZAMOWIENIA,id_produktu,ilosc,cena_jednostkowa) VALUES (NULL,(SELECT id from produkt where id=1),10,
(SELECT cena_jednostkowa from produkt where id=1));
INSERT INTO zamowienie_detale (id_produktu,ilosc,cena_jednostkowa) VALUES ((SELECT id from produkt where id=2),8,
(SELECT cena_jednostkowa from produkt where id=2));
INSERT INTO zamowienie_detale (id_produktu,ilosc,cena_jednostkowa) VALUES ((SELECT id from produkt where id=3),17,
(SELECT cena_jednostkowa from produkt where id=3));

--Procedura do zapisu zamówienia (zakladamy, że detale bez ID_ZAMOWIENIA są w tabeli jako koszyk)

SELECT * FROM ZAMOWIENIE_DETALE;
SELECT * FROM ZAMOWIENIE;
SELECT * FROM FAKTURA;
SELECT * FROM FAKTURA_SPECYFIKACJA;
SELECT SUM(cena_jednostkowa*ilosc) FROM zamowienie_detale WHERE ID_ZAMOWIENIA = 1;
SELECT SUM(KWOTA_NETTO), SUM(KWOTA_VAT), SUM(KWOTA_BRUTTO) FROM FAKTURA_SPECYFIKACJA WHERE ID_FAKTURY = 1;
SELECT * FROM ZAMOWIENIE;

SELECT SUM(cena_jednostkowa*ilosc) FROM zamowienie_detale WHERE ID_ZAMOWIENIA IS NULL;


BEGIN
    ZAPIS_ZAMOWIENIA(1,1,1,'gotowka','Prosze o szybka dostawe');
END;

--Tworzenie Procedury
CREATE OR REPLACE PROCEDURE ZAPIS_ZAMOWIENIA
    (p_klient ZAMOWIENIE.ID%type,
    p_adres ZAMOWIENIE.ID_ADRESU%type,
    p_metoda_dostawy METODY_DOSTAWY.ID%type,
    p_forma_platnosci FAKTURA.FORMA_PLATNOSCI%type,
    p_uwagi ZAMOWIENIE.UWAGI%type
    )
IS
    v_zamowienia ZAMOWIENIE.ID%type;
    v_czy_oplacone ZAMOWIENIE.CZY_OPLACONE%type;
    v_suma_zamowienia ZAMOWIENIE.SUMA_ZAMOWIENIA%type;
    v_data_platnosci ZAMOWIENIE.DATA_ZAMOWIENIA%type;
    v_faktura FAKTURA.ID%type;
BEGIN

    INSERT INTO zamowienie
        (id_klienta,
        data_zamowienia,
        suma_zamowienia,
        czy_oplacone,
        status,
        id_adresu,
        id_metoda_dostawy,
        numer_listu_przewozowego,
        uwagi
        )
        VALUES
        (p_klient,
        SYSDATE,
        (SELECT SUM(cena_jednostkowa*ilosc) FROM zamowienie_detale WHERE ID_ZAMOWIENIA IS NULL),
        '0',
        'Przyjete',
        p_adres,
        p_metoda_dostawy,
        NULL,
        p_uwagi
        )
        RETURNING ID,czy_oplacone,suma_zamowienia INTO v_zamowienia,v_czy_oplacone,v_suma_zamowienia;

    UPDATE ZAMOWIENIE_DETALE SET ID_ZAMOWIENIA = v_zamowienia WHERE ID_ZAMOWIENIA IS NULL;
/*    IF p_forma_platnosci = 'przelew'
        THEN
            v_data_platnosci = sysdate;
    END IF; */

    INSERT INTO FAKTURA (ID_ZAMOWIENIA,DATA_FAKTURY,DATA_PLATNOSCI,FORMA_PLATNOSCI,KWOTA_NETTO,KWOTA_VAT,KWOTA_BRUTTO) VALUES
        (v_zamowienia,
        TO_DATE(sysdate,'DD-MM-YYYY'),
        CASE
            WHEN 
                p_forma_platnosci = 'przelew' THEN sysdate
            ELSE 
                NULL
        END,
        p_forma_platnosci,
        v_suma_zamowienia-ROUND(v_suma_zamowienia*0.23,2),
        ROUND(v_suma_zamowienia*0.23,2),
        v_suma_zamowienia
    )
    RETURNING ID INTO v_faktura;

    FOR produkt IN (SELECT CENA_JEDNOSTKOWA,ILOSC FROM ZAMOWIENIE_DETALE WHERE ID_ZAMOWIENIA = v_zamowienia ORDER BY ID)
    LOOP
        INSERT INTO FAKTURA_SPECYFIKACJA (ID_FAKTURY,KWOTA_NETTO, KWOTA_VAT, KWOTA_BRUTTO) VALUES
        (
         v_faktura,
         produkt.CENA_JEDNOSTKOWA*produkt.ILOSC - ROUND(produkt.CENA_JEDNOSTKOWA*produkt.ILOSC*0.23,2),
         ROUND(produkt.CENA_JEDNOSTKOWA*produkt.ILOSC*0.23,2),
         produkt.CENA_JEDNOSTKOWA*produkt.ILOSC
        );
    END LOOP;


    UPDATE FAKTURA_SPECYFIKACJA SET ID_FAKTURY = v_faktura WHERE ID_FAKTURY IS NULL;
    COMMIT;
END ZAPIS_ZAMOWIENIA;

-- Z1
create view zamowienia_klienta as
select k.nazwa, k.NIP, f.id, z.status, f.data_faktury, f.forma_platnosci, f.kwota_netto, f.kwota_brutto
    from faktura f join zamowienie z on f.id_zamowienia = z.id join klient k on k.id = z.id_klienta;

select * from zamowienia_klienta;

-- Z2
create view detale_faktury as
select f.id as numer_faktury, f.data_faktury, f.data_platnosci,
       f.forma_platnosci, f.kwota_brutto, f.kwota_netto, f.kwota_vat, k.nazwa, k.nip, p.nazwa as nazwa_produktu, z_d.cena_jednostkowa, z_d.ilosc
from faktura f
join zamowienie z on f.id_zamowienia = z.id
join zamowienie_detale Z_D on Z_D.ID_ZAMOWIENIA = z.ID
join produkt p on p.id = Z_D.id_produktu
join klient k on k.id = z.id_klienta;

select * from detale_faktury;
--statystyki

--usuwanie

 --EXECUTE dbms_stats.delete_table_stats('ADMIN','ZAMOWIENIE');
 --EXECUTE dbms_stats.delete_table_stats('ADMIN','PRODUKT');
 --EXECUTE dbms_stats.delete_table_stats('ADMIN','ZAMOWIENIE_DETALE');
 --EXECUTE dbms_stats.delete_table_stats('ADMIN','FAKTURA');

--czy_dzialaja?

select client_name,status from DBA_AUTOTASK_CLIENT;

--kiedy ostatnio zebrane?
select owner,table_name,last_analyzed from dba_tab_statistics WHERE TABLE_NAME= 'ZAMOWIENIE';
select owner,table_name,last_analyzed from dba_tab_statistics WHERE TABLE_NAME= 'PRODUKT';
select owner,table_name,last_analyzed from dba_tab_statistics WHERE TABLE_NAME= 'ZAMOWIENIE_DETALE';
select owner,table_name,last_analyzed from dba_tab_statistics WHERE TABLE_NAME= 'FAKTURA';
select owner,table_name,last_analyzed from dba_tab_statistics WHERE TABLE_NAME= 'KLIENT';
select owner,table_name,last_analyzed from dba_tab_statistics WHERE TABLE_NAME= 'FAKTURA_SPECYFIKACJA';

EXECUTE dbms_stats.gather_table_stats('ADMIN','ZAMOWIENIE');
EXECUTE dbms_stats.gather_table_stats('ADMIN','PRODUKT');
EXECUTE dbms_stats.gather_table_stats('ADMIN','ZAMOWIENIE_DETALE');
EXECUTE dbms_stats.gather_table_stats('ADMIN','FAKTURA');
EXECUTE dbms_stats.gather_table_stats('ADMIN','KLIENT');
EXECUTE dbms_stats.gather_table_stats('ADMIN','FAKTURA_SPECYFIKACJA');
