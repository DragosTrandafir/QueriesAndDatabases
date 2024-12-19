CREATE DATABASE DedemanUpdated;

CREATE TABLE DedemanStore(
Did INT PRIMARY KEY IDENTITY,  -- IDENTITY : 1,2,3...
DName varchar(50) NOT NULL,
City varchar(50) NOT NULL,
NrOfClients int,
NrOfEmplyees int
)

-- 1<-->1

CREATE TABLE Manager(
Mid INT FOREIGN KEY REFERENCES DedemanStore(Did), -- every manager depends on a store through id
CONSTRAINT pk_DedemanStoreManager PRIMARY KEY(Mid), -- one to one relationship

Name varchar(50) NOT NULL,
Experience int
)

-- 1<-->1

CREATE TABLE Salary(
Sid INT FOREIGN KEY REFERENCES Manager(Mid),
CONSTRAINT pk_ManagerSalary PRIMARY KEY(Sid),

TotalValue decimal(10),
Currency varchar(3)
)


-- M<-->N
CREATE TABLE ProductCategory(
PCId INT PRIMARY KEY IDENTITY,
PCName varchar(50) NOT NULL,
)
CREATE TABLE DedemanStoreProductCategory(
Did INT FOREIGN KEY REFERENCES DedemanStore(Did),
PCId INT FOREIGN KEY REFERENCES ProductCategory(PCId),
CONSTRAINT pk_DedemanStoreProductCategory PRIMARY KEY(Did,PCId)
)

CREATE TABLE TileType(
TileTypeId INT PRIMARY KEY IDENTITY,
MaterialType varchar(50) DEFAULT 'Ceramic',
UsedIn varchar(50) DEFAULT 'Indoors'
)

CREATE TABLE BrickType(
BrickTypeId INT PRIMARY KEY IDENTITY,
Type varchar(50) DEFAULT 'Red Burnt'
)

-- m<-->n
create TABLE Product(
ProductId INT PRIMARY KEY IDENTITY,
PName varchar(50) NOT NULL,

Price decimal(10), 
Width int,
Height int,
Depth int,
Quality int CHECK (Quality=1 or Quality=2 or Quality=3),
TileTypeId INT FOREIGN KEY REFERENCES TileType(TileTypeId),
BrickTypeId INT FOREIGN KEY REFERENCES BrickType(BrickTypeId),
AACTypeId int
)

CREATE TABLE ProductCategoryProduct(
ProductId INT FOREIGN KEY REFERENCES Product(ProductId),
PCId INT FOREIGN KEY REFERENCES ProductCategory(PCId),
CONSTRAINT pk_ProductProductCategory PRIMARY KEY(ProductId,PCId)
)


go
create PROCEDURE AddCashOrCardToSalary
AS
    ALTER TABLE Salary
	ADD CashOrCard TINYINT
	PRINT('AddCashOrCardToSalary')
go

create PROCEDURE AddDefaultConstraintToProductWidth
AS
    ALTER TABLE Product
	ADD CONSTRAINT df_0 DEFAULT 0 FOR Width
	PRINT('AddDefaultConstraintToProductWidth')
go

create PROCEDURE CreateTableAACType
AS
    CREATE TABLE AACType(
	AACTypeId INT PRIMARY KEY IDENTITY,
	Type varchar(50) DEFAULT 'Aerocon ',
)
	PRINT('CreateTableAACType')
go

create PROCEDURE AddForeignKeyToProductForAACType
AS
    ALTER TABLE Product
	ADD CONSTRAINT fk_AACType_Product FOREIGN KEY(AACTypeId) REFERENCES AACType(AACTypeId)
	PRINT('AddForeignKeyToProductForAACType')
go




create PROCEDURE RemoveForeignKeyOfProductForAACType
AS
	ALTER TABLE Product
	DROP CONSTRAINT fk_AACType_Product
	PRINT('RemoveForeignKeyOfProductForAACType')
go

create PROCEDURE RemoveTableAACType
AS
    DROP TABLE AACType
	PRINT('RemoveTableAACType')
go

create PROCEDURE RemoveDefaultConstraintFromProductWidth
AS
    ALTER TABLE Product
	DROP CONSTRAINT df_0
	PRINT('RemoveDefaultConstraintFromProductWidth')
go

create PROCEDURE RemoveCashOrCardFromSalary
AS
    ALTER TABLE Salary
	DROP COLUMN CashOrCard
	PRINT('RemoveCashOrCardFromSalary')
go

create table VersionTable(
  VersionNo int primary key default 0
)
go
insert into VersionTable(VersionNo) values(0)
go

CREATE PROCEDURE main @version INT
AS
BEGIN
    DECLARE @currentVersion INT;

    -- Validate the parameter
    IF @version < 0 OR @version > 4
    BEGIN
        RAISERROR('Incorrect version: Allowed versions are between 0 and 4.', 16, 1);
        RETURN;
    END

    SELECT TOP 1 @currentVersion = VersionNo
    FROM VersionTable;

    IF @currentVersion < @version
    BEGIn

        WHILE @currentVersion < @version
        BEGIN
            IF @currentVersion = 0 EXEC AddCashOrCardToSalary;
            IF @currentVersion = 1 EXEC AddDefaultConstraintToProductWidth;
            IF @currentVersion = 2 EXEC CreateTableAACType;
            IF @currentVersion = 3 EXEC AddForeignKeyToProductForAACType;
			
			set @currentVersion = @currentVersion+1
            UPDATE VersionTable SET VersionNo = @currentVersion;

			PRINT 'Went up';
        END
    END
    ELSE IF @currentVersion > @version
    BEGIN

        WHILE @currentVersion > @version
        BEGIN
            IF @currentVersion = 4 EXEC RemoveForeignKeyOfProductForAACType;
			IF @currentVersion = 3 EXEC RemoveTableAACType
			IF @currentVersion = 2 EXEC RemoveDefaultConstraintFromProductWidth
			IF @currentVersion = 1 EXEC RemoveCashOrCardFromSalary

            SET @currentVersion = @currentVersion - 1;
            UPDATE VersionTable SET VersionNo = @currentVersion;

			PRINT 'Went down';
        END
    END
    ELSE
    BEGIN
        PRINT 'Database is at the desired version.';
    END
END;
GO



------HERE YOU SHOULD EXECUTE TO THE DERISRED VERSION---------------------
	
exec main 0

drop procedure main
drop table VersionTable

drop procedure AddCashOrCardToSalary
drop procedure AddDefaultConstraintToProductWidth
drop procedure CreateTableAACType
drop procedure AddForeignKeyToProductForAACType

drop procedure RemoveForeignKeyOfProductForAACType
drop procedure RemoveTableAACType
drop procedure RemoveDefaultConstraintFromProductWidth
drop procedure RemoveCashOrCardFromSalary

drop table ProductCategoryProduct
drop table DedemanStoreProductCategory
drop table Salary
drop table Manager
drop table DedemanStore
drop table Product
drop table BrickType
drop table TileType
drop table ProductCategory
drop table AACType
