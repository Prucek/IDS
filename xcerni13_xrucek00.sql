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
    sex CHAR(1), --M/F
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
    date_until DATE
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
    isDead CHAR(1), -- 'Y'/'N' 
    birthDay DATE,
    deathDay DATE,
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
    date_until DATE
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
    date_until DATE
);

--ALTERS
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

ALTER TABLE Teritory
ADD ownFK INT;
ALTER TABLE Teritory
ADD FOREIGN KEY (ownFK) REFERENCES Ownership(ownID);

ALTER TABLE Host
ADD ownFK INT;
ALTER TABLE Host
ADD FOREIGN KEY (ownFK) REFERENCES Ownership(ownID);


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
INSERT INTO Teritory (teritoryID, teritoryType, capacity)-- TODO ownFK
    VALUES (seq_ter.nextval, 'Kitchen', 2 );

INSERT INTO Teritory (teritoryID, teritoryType, capacity)-- TODO ownFK
    VALUES (seq_ter.nextval, 'Hall', 10 );

INSERT INTO Teritory (teritoryID, teritoryType, capacity)-- TODO ownFK
    VALUES (seq_ter.nextval, 'Forest', 1024 );

CREATE SEQUENCE seq_life
MINVALUE 1
START WITH 1
INCREMENT BY 1
CACHE 10;
INSERT INTO Life (lifeID, lifeOrder, isDead, birthDay, deathDay, deathCause, catFK, bornIn, killedIn)
    VALUES (seq_life.nextval,
    (SELECT Count(*) FROM (SELECT C.main_name FROM Cat C INNER JOIN Life ON Life.catFK = C.catID) WHERE main_name='Kocur') + 1,
    'Y', DATE '2010-3-15', DATE '2010-3-16', 'Owner was unsatisfied',
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
    'Y', DATE '2019-8-23', DATE '2021-3-23', 'Was Old', 
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




SELECT * FROM Cat;
SELECT * FROM Race;
SELECT * FROM Life;
SELECT * FROM Teritory;
SELECT * FROM LivesIn;
SELECT * FROM Ownership;

-- SELECT * FROM Cat C INNER JOIN Race ON C.raceFK = Race.raceID;