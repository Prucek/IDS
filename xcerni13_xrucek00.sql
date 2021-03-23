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

CREATE TABLE Race (
    raceID INT PRIMARY KEY,
    color_eyes VARCHAR(100),
    origin VARCHAR(100),
    max_teeth_len NUMBER(3),
    specific_features VARCHAR(100)
);

CREATE TABLE Cat (
    catID INT PRIMARY KEY,
    -- main_name VARCHAR(100),
    skin VARCHAR(100),
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
    FOREIGN KEY (bornIn) REFERENCES Teritory(teritoryID),
    UNIQUE (bornIn)
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
ALTER TABLE Cat
ADD lifeFK INT;
ALTER TABLE Cat
ADD FOREIGN KEY (lifeFK) REFERENCES Life(lifeID);
ALTER TABLE Teritory
ADD lifeFK INT;
ALTER TABLE Teritory
ADD FOREIGN KEY (lifeFK) REFERENCES Life(lifeID);
ALTER TABLE Teritory
ADD ownFK INT;
ALTER TABLE Teritory
ADD FOREIGN KEY (ownFK) REFERENCES Ownership(ownID);
ALTER TABLE Host
ADD ownFK INT;
ALTER TABLE Host
ADD FOREIGN KEY (ownFK) REFERENCES Ownership(ownID);