-- Authors: Peter Rucek (xrucek00), Rebeka Cernianska (xcerni13)
-- Date: 14 Apr 2021
-- Project: SQL script for IDS, Kitty Information System (KIS)

DROP TABLE Cat CASCADE CONSTRAINT;
DROP TABLE Race CASCADE CONSTRAINT;
DROP TABLE Host CASCADE CONSTRAINT;
DROP TABLE HostPrefers CASCADE CONSTRAINT;
DROP TABLE HostServes CASCADE CONSTRAINT;
DROP TABLE Life CASCADE CONSTRAINT;
DROP TABLE Teritory CASCADE CONSTRAINT;
DROP TABLE LivesIn CASCADE CONSTRAINT;
DROP TABLE Ownership CASCADE CONSTRAINT;
DROP TABLE CatOwns CASCADE CONSTRAINT;

DROP SEQUENCE seq_cat;
DROP SEQUENCE seq_race;
DROP SEQUENCE seq_life;
DROP SEQUENCE seq_ter;
DROP SEQUENCE seq_own;
DROP SEQUENCE seq_host;

-------------------------- CREATE Queries --------------------------------
CREATE TABLE Race (
    raceID INT PRIMARY KEY,
    race_color_eyes VARCHAR(100),
    origin VARCHAR(100),
    max_teeth_len NUMBER(3),
    specific_features VARCHAR(100)
);

CREATE TABLE Cat (
    catID INT PRIMARY KEY, -- skin sample
    main_name VARCHAR(100),
    color_fur VARCHAR(100),
    color_eyes VARCHAR(100)
);

CREATE TABLE Host (
    hostID INT PRIMARY KEY,
    name VARCHAR(100),
    birth DATE,
    sex CHAR(1),
    CHECK(sex = 'M' OR sex = 'F'),
    city VARCHAR(100)
);

CREATE TABLE HostPrefers(
    hostID INT,
    raceID INT,
    FOREIGN KEY (raceID) REFERENCES Race(raceID),
    FOREIGN KEY (hostID) REFERENCES Host(hostID),
    UNIQUE (raceID, hostID)
);

CREATE TABLE HostServes(
    hostID INT,
    catID INT,
    FOREIGN KEY (catID) REFERENCES Cat(catID),
    FOREIGN KEY (hostID) REFERENCES Host(hostID),
    UNIQUE (catID, hostID),
    name_for_cat VARCHAR(100),
    date_since DATE,
    date_until DATE,
    CHECK(date_since <= date_until)
);

CREATE TABLE Teritory(
    teritoryID INT PRIMARY KEY,
    teritoryType VARCHAR(100),
    capacity INT 
);

CREATE TABLE Life(
    lifeID INT PRIMARY KEY,
    lifeOrder INT,
    CHECK(lifeOrder >= 1 AND lifeOrder <= 9),
    isDead CHAR(1),
    CHECK(isDead = 'Y' OR isDead = 'N'),
    birthDay DATE,
    deathDay DATE, 
    CHECK(deathDay >= birthDay),
    deathCause VARCHAR(100),
    bornIn INT,
    FOREIGN KEY (bornIn) REFERENCES Teritory(teritoryID)
);

CREATE TABLE LivesIn(
    lifeID INT,
    teritoryID INT,
    FOREIGN KEY (teritoryID) REFERENCES Teritory(teritoryID),
    FOREIGN KEY (lifeID) REFERENCES Life(lifeID),
    UNIQUE (teritoryID, lifeID),
    date_since DATE,
    date_until DATE,
    CHECK(date_since <= date_until)
);

CREATE TABLE Ownership(
    ownID INT PRIMARY KEY,
    ownType VARCHAR(100),
    quantity INT
);

CREATE TABLE CatOwns(
    catID INT,
    ownID INT,
    FOREIGN KEY (catID) REFERENCES Cat(catID),
    FOREIGN KEY (ownID) REFERENCES Ownership(ownID),
    UNIQUE (catID, ownID),
    date_since DATE,
    date_until DATE,
    CHECK(date_since <= date_until)
);

-------------------------- ALTER Queries --------------------------------
ALTER TABLE Cat
ADD raceFK INT;
ALTER TABLE Cat 
ADD FOREIGN KEY (raceFK) REFERENCES Race(raceID);

ALTER TABLE Life
ADD catFK INT;
ALTER TABLE Life
ADD FOREIGN KEY (catFK) REFERENCES Cat(catID);

ALTER TABLE Life
ADD killedIn INT;
ALTER TABLE Life
ADD FOREIGN KEY (killedIn) REFERENCES Teritory(teritoryID);

ALTER TABLE Ownership
ADD teritoryFK INT;
ALTER TABLE Ownership
ADD FOREIGN KEY (teritoryFK) REFERENCES Teritory(teritoryID);

ALTER TABLE Ownership
ADD hostFK INT;
ALTER TABLE Ownership
ADD FOREIGN KEY (hostFK) REFERENCES Host(hostID);


-------------------------- INSERT Queries --------------------------------
CREATE SEQUENCE seq_race
MINVALUE 1
START WITH 1
INCREMENT BY 1
CACHE 10;
INSERT INTO Race (raceID, race_color_eyes, origin, max_teeth_len, specific_features)
    VALUES (seq_race.nextval, 'yellow', 'Turkmenistan', 3, 'Scary');
INSERT INTO Race (raceID, race_color_eyes, origin, max_teeth_len, specific_features)
    VALUES (seq_race.nextval, 'blue', 'Angola', 4, 'Long tail');
INSERT INTO Race (raceID, race_color_eyes, origin, max_teeth_len, specific_features)
    VALUES (seq_race.nextval, 'green', 'Mexico', 2, 'Sharp claws');
INSERT INTO Race (raceID, race_color_eyes, origin, max_teeth_len, specific_features)
    VALUES (seq_race.nextval, 'gray', 'Bratislava', 12, 'Saber-tooth ancestor');
INSERT INTO Race (raceID, race_color_eyes, origin, max_teeth_len, specific_features)
    VALUES (seq_race.nextval, 'green', 'Australia', 5, 'Lives in trees');

CREATE SEQUENCE seq_cat
MINVALUE 1
START WITH 1
INCREMENT BY 1
CACHE 10;
INSERT INTO Cat (catID, main_name, color_fur, color_eyes, raceFK)
    VALUES (seq_cat.nextval,'Kocur','red','blue', (SELECT raceID from Race WHERE origin='Angola'));

INSERT INTO Cat (catID, main_name, color_fur, color_eyes, raceFK)
    VALUES (seq_cat.nextval,'Muf', 'gray','green', (SELECT raceID from Race WHERE origin='Mexico'));

INSERT INTO Cat (catID, main_name, color_fur, color_eyes, raceFK)
    VALUES (seq_cat.nextval,'Puf', 'black','yellow', (SELECT raceID from Race WHERE origin='Turkmenistan'));

INSERT INTO Cat (catID, main_name, color_fur, color_eyes, raceFK)
    VALUES (seq_cat.nextval,'Wuff', 'white','green', (SELECT raceID from Race WHERE origin='Mexico'));

INSERT INTO Cat (catID, main_name, color_fur, color_eyes, raceFK)
    VALUES (seq_cat.nextval,'Dunco', 'gray','yellow', (SELECT raceID from Race WHERE origin='Australia'));


CREATE SEQUENCE seq_ter
MINVALUE 1
START WITH 1
INCREMENT BY 1
CACHE 10;
INSERT INTO Teritory (teritoryID, teritoryType, capacity)
    VALUES (seq_ter.nextval, 'Kitchen', 2 );

INSERT INTO Teritory (teritoryID, teritoryType, capacity)
    VALUES (seq_ter.nextval, 'Hall', 10 );

INSERT INTO Teritory (teritoryID, teritoryType, capacity)
    VALUES (seq_ter.nextval, 'Forest', 1024 );


CREATE SEQUENCE seq_life
MINVALUE 1
START WITH 1
INCREMENT BY 1
CACHE 10;
INSERT INTO Life (lifeID, lifeOrder, isDead, birthDay, deathDay, deathCause, catFK, bornIn, killedIn)
    VALUES (seq_life.nextval,
    (SELECT Count(*) FROM (SELECT C.main_name FROM Cat C INNER JOIN Life ON Life.catFK = C.catID) WHERE main_name='Kocur') + 1,
    'Y', DATE '2010-3-15', DATE '2010-3-16', 'owner was unsatisfied',
    (SELECT catID from Cat WHERE main_name='Kocur'), 
    (SELECT teritoryID from Teritory WHERE teritoryType='Kitchen'),
    (SELECT teritoryID from Teritory WHERE teritoryType='Kitchen'));

INSERT INTO Life (lifeID, lifeOrder, isDead, birthDay, deathDay, deathCause, catFK, bornIn, killedIn)
    VALUES (seq_life.nextval, 
    (SELECT Count(*) FROM (SELECT C.main_name FROM Cat C INNER JOIN Life ON Life.catFK = C.catID) WHERE main_name='Kocur') + 1,
    'N', DATE '2010-3-16', NULL, NULL, 
    (SELECT catID from Cat WHERE main_name='Kocur'),
    (SELECT teritoryID from Teritory WHERE teritoryType='Hall'),
    NULL);

INSERT INTO Life (lifeID, lifeOrder, isDead, birthDay, deathDay, deathCause, catFK, bornIn, killedIn)
    VALUES (seq_life.nextval,
    (SELECT Count(*) FROM (SELECT C.main_name FROM Cat C INNER JOIN Life ON Life.catFK = C.catID) WHERE main_name='Muf') + 1,
    'Y', DATE '2019-8-23', DATE '2021-3-23', 'was old', 
    (SELECT catID from Cat WHERE main_name='Muf'),
    (SELECT teritoryID from Teritory WHERE teritoryType='Forest'),
    (SELECT teritoryID from Teritory WHERE teritoryType='Hall'));

INSERT INTO Life (lifeID, lifeOrder, isDead, birthDay, deathDay, deathCause, catFK, bornIn, killedIn)
    VALUES (seq_life.nextval,
    (SELECT Count(*) FROM (SELECT C.main_name FROM Cat C INNER JOIN Life ON Life.catFK = C.catID) WHERE main_name='Dunco') + 1,
    'N', DATE '1952-6-24', NULL, NULL, 
    (SELECT catID from Cat WHERE main_name='Dunco'),
    (SELECT teritoryID from Teritory WHERE teritoryType='Kitchen'),
    NULL);

INSERT INTO LivesIn (lifeID, teritoryID, date_since, date_until)
    VALUES (
        (SELECT lifeID FROM (SELECT Life.lifeID ,C.main_name FROM Cat C INNER JOIN Life ON Life.catFK = C.catID 
                WHERE main_name='Dunco' AND Life.lifeOrder = 1)),
        (SELECT teritoryID from Teritory WHERE teritoryType='Forest'),
         DATE '2019-8-23', DATE '2020-3-23'
    );
INSERT INTO LivesIn (lifeID, teritoryID, date_since, date_until)
    VALUES (
        (SELECT lifeID FROM (SELECT Life.lifeID ,C.main_name FROM Cat C INNER JOIN Life ON Life.catFK = C.catID 
                WHERE main_name='Kocur' AND Life.lifeOrder = 1)),
        (SELECT teritoryID from Teritory WHERE teritoryType='Kitchen'),
         DATE '2010-3-15', DATE '2010-3-16'
    );

CREATE SEQUENCE seq_host
MINVALUE 1
START WITH 1
INCREMENT BY 1
CACHE 10;
INSERT INTO Host (hostID, name, birth, sex, city)
    VALUES(seq_host.nextval,'Herold', DATE '1984-11-1','M','Oxford');
INSERT INTO Host (hostID, name, birth, sex, city)
    VALUES(seq_host.nextval,'Rebecca', DATE '1994-1-31','F','Tokio');
INSERT INTO Host (hostID, name, birth, sex, city)
    VALUES(seq_host.nextval,'Musa', DATE '1924-5-17','M','Capetown');


CREATE SEQUENCE seq_own
MINVALUE 1
START WITH 1
INCREMENT BY 1
CACHE 10;
INSERT INTO Ownership (ownID, ownType, quantity, teritoryFK, hostFK)
    VALUES (seq_own.nextval, 'Toy', 3,
    (SELECT teritoryID from Teritory WHERE teritoryType='Kitchen'),
    (SELECT hostID from Host WHERE name='Rebecca'));
INSERT INTO Ownership (ownID, ownType, quantity, teritoryFK, hostFK)
    VALUES (seq_own.nextval, 'House', 24,
    (SELECT teritoryID from Teritory WHERE teritoryType='Forest'),
    (SELECT hostID from Host WHERE name='Musa'));
INSERT INTO Ownership (ownID, ownType, quantity, teritoryFK, hostFK)
    VALUES (seq_own.nextval, 'Nuclear weapon', 1000,
    (SELECT teritoryID from Teritory WHERE teritoryType='Forest'),
    (SELECT hostID from Host WHERE name='Herold'));
INSERT INTO Ownership (ownID, ownType, quantity, teritoryFK, hostFK)
    VALUES (seq_own.nextval, 'Ball of yarn', 3,
    (SELECT teritoryID from Teritory WHERE teritoryType='Hall'),
    (SELECT hostID from Host WHERE name='Rebecca'));

INSERT INTO HostPrefers (hostID, raceID)
    VALUES ((SELECT hostID from Host WHERE name='Herold'),
    (SELECT raceID from Race WHERE origin='Bratislava'));
INSERT INTO HostPrefers (hostID, raceID)
    VALUES ((SELECT hostID from Host WHERE name='Herold'),
    (SELECT raceID from Race WHERE origin='Mexico'));
INSERT INTO HostPrefers (hostID, raceID)
    VALUES ((SELECT hostID from Host WHERE name='Musa'),
    (SELECT raceID from Race WHERE origin='Angola'));

INSERT INTO HostServes (hostID, catID, name_for_cat, date_since, date_until)
    VALUES (
        (SELECT hostID from Host WHERE name='Musa'),
        (SELECT catID from Cat WHERE main_name='Dunco'),
        'Zlaticko', DATE '2011-2-13', DATE '2013-2-13'
    );
INSERT INTO HostServes (hostID, catID, name_for_cat, date_since, date_until)
    VALUES (
        (SELECT hostID from Host WHERE name='Herold'),
        (SELECT catID from Cat WHERE main_name='Duco'),
        'Junior', DATE '2013-2-13', NULL
    );
INSERT INTO HostServes (hostID, catID, name_for_cat, date_since, date_until)
    VALUES (
        (SELECT hostID from Host WHERE name='Rebecca'),
        (SELECT catID from Cat WHERE main_name='Kocur'),
        'Kocurko', DATE '2016-2-13', DATE '2020-2-13'
    );

INSERT INTO CatOwns (catID, ownID, date_since, date_until)
    VALUES (
        (SELECT catID from Cat WHERE main_name='Kocur'),
        (SELECT ownID from Ownership WHERE ownType='Nuclear weapon'),
        DATE '2016-2-13', DATE '2020-2-13'
    );
INSERT INTO CatOwns (catID, ownID, date_since, date_until)
    VALUES (
        (SELECT catID from Cat WHERE main_name='Muf'),
        (SELECT ownID from Ownership WHERE ownType='Nuclear weapon'),
        DATE '2018-4-24', DATE '2020-4-24'
    );
--------------------------------------------------------------------------

-- SELECT * FROM Cat;
-- SELECT * FROM Race;
-- SELECT * FROM Life;
-- SELECT * FROM Teritory;
-- SELECT * FROM LivesIn;
-- SELECT * FROM Ownership;
-- SELECT * FROM Host;
-- SELECT * FROM HostPrefers;
-- SELECT * FROM HostServes;
-- SELECT * FROM CatOwns;

-------------------------- SELECT Queries --------------------------------

-- Select all Cats with Race.Origin from Mexico
-- SELECT * FROM Cat C INNER JOIN Race R ON R.raceID = C.raceFK WHERE R.origin = 'Mexico';

-- Select all Ownerships, that are in TeritoryType = Kitchen
-- SELECT * FROM Ownership O INNER JOIN Teritory T ON O.teritoryFK = T.teritoryID WHERE T.teritoryType = 'Kitchen';

-- Select all Races that Hosts prefers
-- SELECT H.name as HostName, R.race_color_eyes, R.origin, R.max_teeth_len, R.specific_features 
-- FROM Host H NATURAL JOIN HostPrefers HP  NATURAL JOIN Race R;

-- Select all lives of cats born in kitchen
-- SELECT C.main_name as CatName, L.lifeOrder, L.birthDay FROM Cat C, Life L, Teritory T WHERE C.catID = L.catFK 
-- AND L.bornIN = T.teritoryID AND T.teritoryType = 'Kitchen';

-- Select sum of ownerships in teritory
-- SELECT T.teritoryType, Sum(O.quantity) FROM Teritory T INNER JOIN Ownership O 
-- ON T.teritoryID = O.teritoryFK GROUP BY T.teritoryType;

-- Select all lives born in a teritory
-- SELECT COUNT(*) LivesCount, T.teritoryType FROM Life L INNER JOIN Teritory T ON T.teritoryID = L.bornin GROUP BY T.teritoryType;

-- Select all cats that have corespoding colors of eyes with their race
-- SELECT C.main_name, C.color_eyes FROM Cat C, Race R WHERE R.raceID = C.raceFK AND EXISTS 
-- (SELECT * FROM Race R WHERE R.raceID = C.raceFK AND R.race_color_eyes = C.color_eyes AND C.color_eyes = R.race_color_eyes );

-- Select all cats born in March 2010
-- SELECT * FROM Cat C WHERE C.catID IN 
-- (SELECT L.catFK FROM Life L WHERE L.birthDay BETWEEN DATE '2010-3-1' AND DATE '2010-3-31');

--------------------------  Explain Plan + Index --------------------------------

EXPLAIN PLAN FOR
SELECT Count(*) Num, Cat.main_name
FROM Cat NATURAL JOIN Life
WHERE Life.catFK = Cat.catID
GROUP BY Cat.main_name;
SELECT * FROM TABLE(DBMS_XPLAN.display());

CREATE INDEX my_index ON Life(catFK);

EXPLAIN PLAN FOR
SELECT Count(*) Num, Cat.main_name
FROM Cat NATURAL JOIN Life
WHERE Life.catFK = Cat.catID
GROUP BY Cat.main_name;
SELECT * FROM TABLE(DBMS_XPLAN.display());

----------------------------- Triggers -----------------------------------

-- For PK in Cat table
CREATE OR REPLACE TRIGGER If_Cat_PK_NULL
    BEFORE INSERT ON Cat
    FOR EACH ROW
    BEGIN
        :NEW.catID := seq_cat.nextval;
    END;
/
-- For PK in Race table
CREATE OR REPLACE TRIGGER If_Race_PK_NULL
    BEFORE INSERT ON Race
    FOR EACH ROW
    BEGIN
        :NEW.raceID := seq_race.nextval;
    END;
/
-- For PK, lifeOrder, isDead in Life table
CREATE OR REPLACE TRIGGER If_Life_Attributes_NULL
    BEFORE INSERT ON Life
    FOR EACH ROW
    DECLARE
    num INTEGER;
    BEGIN
        :NEW.lifeID := seq_life.nextval;
        SELECT Count(*) INTO num FROM Life WHERE catFK = :NEW.catFK;
        :NEW.lifeOrder :=  num + 1; -- lifeOrder will be calculated automatically
        -- isDeath will be set if deathDay
        IF (:NEW.deathDay IS NULL) THEN
            :NEW.isDead := 'N';
        ELSE
            :NEW.isDead := 'Y';
        END IF;
       
    END;
/

-- For proper dates insertion in Life table
CREATE OR REPLACE TRIGGER Proper_life_dates
    BEFORE INSERT on Life
    FOR EACH ROW
    DECLARE
    last_birthDate DATE;
    last_deathDate DATE;
    last_date DATE;
    newDeath Life.deathDay%TYPE;
    isNewDead Life.isDead%TYPE;
    BEGIN
        SELECT MAX(L.birthDay) INTO last_birthDate FROM Life L WHERE L.catFK = :NEW.catFK;
        SELECT MAX(L.deathDay) INTO last_deathDate FROM Life L WHERE L.catFK = :NEW.catFK;
        SELECT (CASE WHEN last_birthDate > last_deathDate
                THEN last_birthDate
                ELSE last_deathDate END) INTO last_date
            FROM dual;

        IF (:NEW.birthday < last_date) THEN
            raise_application_error(-1, 'ERROR: new life can start only after previous life');
        END IF; 

        -- IF new life should be created and previous life is not ended yet then instant reincarnation happens
        SELECT deathDay, isDead INTO newDeath, isNewDead FROM Life WHERE catFK = :NEW.catFK AND birthDay = last_birthDate;
        IF newDeath IS NULL AND isNewDead = 'N' THEN
            UPDATE Life
            SET deathDay = :NEW.birthDay,
                isDead = 'Y'
            WHERE catFK = :NEW.catFK AND birthDay = last_birthDate;
        END IF; 
    END;    
/


------------------------ Trying out triggers -----------------------------

INSERT INTO Cat (main_name, color_fur, color_eyes, raceFK)
    VALUES ('John', 'vanilla', 'green', (SELECT raceID from Race WHERE origin='Australia'));

SELECT * FROM Cat;
------
INSERT INTO Race (race_color_eyes, origin, max_teeth_len, specific_features)
    VALUES ('purple', 'UK', 1, 'Likes water');

SELECT * FROM Race;
------

-- To see the differnece
SELECT * FROM Life ORDER BY catFK, lifeOrder;

-- This life will be added as usual
INSERT INTO Life (lifeOrder, isDead, birthDay, deathDay, catFK, bornIn, killedIn)
    VALUES (
    (SELECT Count(*) FROM (SELECT C.main_name FROM Cat C INNER JOIN Life ON Life.catFK = C.catID) WHERE main_name='Kocur') + 1,
    'Y', DATE '2010-3-17', DATE '2010-3-19',
    (SELECT catID from Cat WHERE main_name='Kocur'), 
    (SELECT teritoryID from Teritory WHERE teritoryType='Kitchen'),
    (SELECT teritoryID from Teritory WHERE teritoryType='Kitchen'));

-- This life will occur error beacause deathDay is earlier then birthDay, and will not be added
-- already covered in CHECK 
-- INSERT INTO Life (birthDay, deathDay, catFK, bornIn, killedIn)
--     VALUES ( DATE '2010-3-19', DATE '2010-3-17',
--     (SELECT catID from Cat WHERE main_name='Kocur'), 
--     (SELECT teritoryID from Teritory WHERE teritoryType='Kitchen'),
--     (SELECT teritoryID from Teritory WHERE teritoryType='Kitchen'));

-- This life will occur error beacause it would have start before the end of previous life, and will not be added
-- INSERT INTO Life (birthDay, deathDay, catFK, bornIn, killedIn)
--     VALUES ( DATE '2010-3-14', DATE '2010-3-19',
--     (SELECT catID from Cat WHERE main_name='Kocur'), 
--     (SELECT teritoryID from Teritory WHERE teritoryType='Kitchen'),
--     (SELECT teritoryID from Teritory WHERE teritoryType='Kitchen'));

-- Can insert like this, isDead, life order and PK will be added in the trigger 
INSERT INTO Life (birthDay, catFK, bornIn)
    VALUES ( DATE '2012-4-22',
    (SELECT catID from Cat WHERE main_name='Kocur'), 
    (SELECT teritoryID from Teritory WHERE teritoryType='Forest'));

-- This insert will end the life above with deathDay same as bithDay of this life (instant reincarnation)
INSERT INTO Life (birthDay, catFK, bornIn)
    VALUES ( DATE '2016-8-23',
    (SELECT catID from Cat WHERE main_name='Kocur'), 
    (SELECT teritoryID from Teritory WHERE teritoryType='Forest'));

-- To see the differnece
SELECT * FROM Life ORDER BY catFK, lifeOrder;

----------------------------- Procedures ---------------------------------
SET SERVEROUTPUT ON;
-- Prints detail information about every cat
CREATE OR REPLACE PROCEDURE cat_details
AS
CURSOR cats IS SELECT * FROM Cat;
single_cat cats%ROWTYPE;
cat_origin VARCHAR(100);
cat_life INT;
cat_birth DATE;
CURSOR cats_own IS SELECT * FROM CatOwns;
single_cat_owns cats_own%ROWTYPE;
cat_own_type VARCHAR(100);
cat_own_quantity INT;
cat_subject INT;
BEGIN
    OPEN cats;
    LOOP
        FETCH cats INTO single_cat;
        EXIT WHEN cats%NOTFOUND;
        SELECT origin INTO cat_origin FROM Race WHERE single_cat.raceFK = raceID;
        SELECT COUNT(*) INTO cat_life FROM ( SELECT lifeOrder FROM Life WHERE single_cat.catID = catFK );

        -- Prints cat name, origin and information about lifes
        IF (cat_life <> 0) THEN
            SELECT birthDay INTO cat_birth FROM Life WHERE single_cat.catID = catFK AND lifeOrder = cat_life;
                dbms_output.put_line('Cat "' || single_cat.main_name || '" comes from '|| cat_origin
                || ' lives his/hers ' || cat_life || ' life. This life was born on ' || cat_birth || '.');

            -- Print all ownerships that the cat possesses
            OPEN cats_own;
            LOOP
                FETCH cats_own INTO single_cat_owns;
                EXIT WHEN  cats_own%NOTFOUND;
                IF (single_cat_owns.catID = single_cat.catID) THEN
                    SELECT ownType, quantity INTO cat_own_type, cat_own_quantity 
                    FROM Ownership WHERE single_cat_owns.ownID = ownID;
                    dbms_output.put_line('This cat has owned ' || cat_own_quantity || ' ' || cat_own_type || '.');
                END IF;
            END LOOP;
            CLOSE cats_own;
            -- Print number of hosts / subjects
            SELECT COUNT(*) INTO cat_subject FROM HostServes WHERE single_cat.catID = catID;
            IF (cat_subject <> 0) THEN 
                dbms_output.put_line('This cat has had ' || cat_subject || ' host(s).');
            END IF;
        ELSE 
            dbms_output.put_line('Cat "' || single_cat.main_name || '" comes from '|| cat_origin ||
            ' and was not born yet.');
        END IF;
    END LOOP;
    CLOSE cats;

    EXCEPTION WHEN NO_DATA_FOUND THEN
	BEGIN
		dbms_output.put_line('No data was found!');
	END;
END;
/



CREATE OR REPLACE PROCEDURE teritory_info
AS
CURSOR teritories IS SELECT * FROM Teritory;
teritory teritories%ROWTYPE;
CURSOR ownerships IS SELECT * FROM Ownership;
ownership ownerships%ROWTYPE;
num_of_lives INT;
own_name VARCHAR(100);
BEGIN
    OPEN teritories;
    LOOP
        FETCH teritories INTO teritory;
        EXIT WHEN teritories%NOTFOUND;
        SELECT COUNT(*) INTO num_of_lives FROM Life WHERE Life.bornIn = teritory.teritoryID;
        IF (num_of_lives <> 0) THEN
            dbms_output.put_line('Teritory ' || teritory.teritoryType || ' has ' || num_of_lives || ' lives started in it.');
        ELSE
            dbms_output.put_line('There are no lives that started in teritory ' || teritory.teritoryType || '.');
        END IF;
        OPEN ownerships;
        LOOP
            FETCH ownerships INTO ownership;
            EXIT WHEN ownerships%NOTFOUND;
            IF (ownership.teritoryFK = teritory.teritoryID) THEN
                 dbms_output.put_line('Object ' || ownership.owntype || ' is placed in teritory ' || teritory.teritoryType || '.');
            END IF;
        END LOOP;
        CLOSE ownerships;
    END LOOP;
    CLOSE teritories;

    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
        BEGIN
            dbms_output.put_line('No data was found!');
        END;

        WHEN OTHERS THEN
        BEGIN
            dbms_output.put_line('An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
        END;
END;
/


-- executing procedure
exec cat_details();
exec teritory_info();