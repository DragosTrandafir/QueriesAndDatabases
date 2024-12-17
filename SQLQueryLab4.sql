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
BrickTypeId INT FOREIGN KEY REFERENCES BrickType(BrickTypeId)
)

CREATE TABLE ProductCategoryProduct(
ProductId INT FOREIGN KEY REFERENCES Product(ProductId),
PCId INT FOREIGN KEY REFERENCES ProductCategory(PCId),
CONSTRAINT pk_ProductProductCategory PRIMARY KEY(ProductId,PCId)
)






--DROP DATABASE DedemanUpdated;


-- INSERT
insert into DedemanStore(DName,City,NrOfClients,NrOfEmplyees) values ('Dedeman Cluj-Napoca','Cluj-Napoca',120,30)
insert into DedemanStore(DName,City,NrOfClients,NrOfEmplyees) values ('Dedeman Bucharest Nord','Bucharest',137,41),('Dedeman Bucharest South','Bucharest',119,20),('Dedeman Oradea','Oradea',200,37),('Dedeman Iasi','Iasi',210,50)

insert into TileType(MaterialType) values ('Porcelain'),('Mosaic'),('Limestone'), ('Glass')
insert into BrickType(Type) values ('Red Burnt'),('Cement'),('Mortar')

insert into Product(PName,Price,Width,Height,Depth,Quality,TileTypeId) values ('Mosaic White Romania Tile',100.9,15,15,4,1,2)
insert into Product(PName,Price,Width,Height,Depth,Quality,TileTypeId) values ('Mosaic White Hungary Tile',120,15,15,4,1,2)
insert into Product(PName,Price,Width,Height,Depth,Quality,TileTypeId) values ('Limestone Black Marocco Tile',140,30,25,4,2,3)
insert into Product(PName,Price,Width,Height,Depth,Quality,TileTypeId) values ('Limestone Grey Italy Tile',170,25,25,8,1,3)
insert into Product(PName,Price,Width,Height,Depth,Quality,TileTypeId) values ('Mosaic Grey Romania Tile',99,15,15,4,2,2)
insert into Product(PName,Price,Width,Height,Depth,Quality,TileTypeId) values ('Mosaic Grey Bulgary Tile',120,20,15,10,3,2)
insert into Product(PName,Price,Width,Height,Depth,Quality,TileTypeId) values ('Porcelain Blue Spain Tile',140,40,20,4,1,1)
insert into Product(PName,Price,Width,Height,Depth,Quality,BricktypeId) values ('Concrete Romania Brick',170,40,20,4,2,1)


-- ADD COMMENTS TO QUERIES
select * from DedemanStore
select * from Product
select * from TileType


--a
go
create function checkMaterialType(@material varchar(50))
 returns bit as
 begin
          declare @b bit
		  if @material IN ('Cement','Mortar','Stone','Glass','Metal','Ceramic','Porcelain','Mosaic','Limestone')
			set @b=1
		  else
		    set @b=0
		  return @b
 end
 go

create function checkPrice(@price decimal(10))
returns int as
begin
		declare @ok int
		if @price>0 and @price<20000
			set @ok=1
        else
		    set @ok=0
		return @ok
end
go

create function checkUsedIn(@usedIn varchar(50))
 returns bit as
 begin
		declare @ok bit
		if @usedIn LIKE'[A-Z]%[a-z]'
			set @ok=1
		 else
		    set @ok=0
		  return @ok
 end
 go

create function checkWidthHeightDepth(@width int, @height int, @depth int)
returns bit as
begin
		declare @ok bit
		if @width<1000 and @width>0 and @height<2000 and @height>0 and @depth<1500 and @depth>0
			set @ok=1
        else
			set @ok=0
        return @ok
end
go


create procedure addProduct @name varchar(50),@price decimal(10), @width int, @height int, @depth int,@quality int,@tileTypeId int, @brickTypeId int
as
begin
		--validate parameters
		if dbo.checkPrice(@price)=1 and dbo.checkWidthHeightDepth(@width,@height,@depth)=1
		begin
			insert into Product(PName,Price,Width,Height,Depth,Quality,TileTypeId,BrickTypeId) values(@name,@price,@width,@height,@depth,@quality,@tileTypeId, @brickTypeId)
		    select * from Product
		end
		else
		begin
			print 'incorrect price, width, height or depth'
		end
end
go

DECLARE @tileTypeSpecicial INT
SELECT TOP 1 @tileTypeSpecicial=TileTypeId FROM TileType

DECLARE @brickTypeSpecicial INT
SELECT TOP 1 @brickTypeSpecicial=BrickTypeId FROM BrickType

exec addProduct 'Mosaic Black Romania Tile',100.9,15,15,4,1,@tileTypeSpecicial,@brickTypeSpecicial
exec addProduct 'Mosaic Black Romania Tile',100.9,1500000,15,4,1,@tileTypeSpecicial,NULL

go
create procedure addTileType @materialType varchar(50), @usedIn varchar(50)
 as
		begin
		      --validate the parameters from sp
			  if dbo.checkMaterialType(@materialType)=1 and dbo.checkUsedIn(@usedIn)=1
			  begin
					insert into TileType(MaterialType,UsedIn) values (@materialType,@usedIn)
					select * from TileType
			  end
			  else
			  begin
			        print 'wrong parameters'
					select * from TileType
			  end
		end

exec addTileType 'Stone','Outdoors'
exec addTileType 'Stoneskks','Outdoors'



--b


insert into ProductCategory(PCName) values ('Construction'),('Electronics')
INSERT INTO DedemanStoreProductCategory (Did, PCId)
SELECT 
    s.Did, 
    pc.PCId
FROM DedemanStore s, ProductCategory pc
WHERE s.City = 'Bucharest' AND pc.PCName = 'Electronics';

INSERT INTO DedemanStoreProductCategory (Did, PCId)
SELECT 
    s.Did, 
    pc.PCId
FROM DedemanStore s, ProductCategory pc
WHERE not (s.City = 'Bucharest') AND pc.PCName = 'Construction';

INSERT INTO ProductCategoryProduct(ProductId, PCId)
SELECT 
    p.ProductId, 
    pc.PCId
FROM Product p, ProductCategory pc
WHERE pc.PCId=1

select * from DedemanStore
select * from DedemanStoreProductCategory
select * from ProductCategory
select * from ProductCategoryProduct
select * from Product

go
create view viewStoresCategoriesProducts
as
SELECT DISTINCT ds.DName, pc.PCName, p.PName
FROM     DedemanStore AS ds INNER JOIN
                  DedemanStoreProductCategory AS dspc ON dspc.Did = ds.Did INNER JOIN
                  ProductCategory AS pc ON pc.PCId = dspc.PCId INNER JOIN
                  ProductCategoryProduct AS pcp ON pcp.PCId = pc.PCId INNER JOIN
                  Product AS p ON p.ProductId = pcp.ProductId
go

select * from viewStoresCategoriesProducts


--c
CREATE TABLE Logs(
	Lid int PRIMARY KEY IDENTITY,
	TriggerDate datetime,
	TriggerType varchar(50),
	NameAffectedTable varchar(50),
	NoAMDRows int )

CREATE TABLE BrickTypeT(
	BrickTypeId int Primary key identity,
	Type varchar(50))

go
create trigger Add_BrickType on BrickType for
insert as
begin
    insert into Logs(TriggerDate,TriggerType,NameAffectedTable,NoAMDRows)
	values( GETDATE(), 'INSERT', 'BrickType', @@ROWCOUNT);

	insert into BrickTypeT(Type)
	select Type from inserted
end
go

insert into BrickType(Type) values ('Red Medium Burnt')

select * from BrickType
select * from BrickTypeT
select * from Logs




go
create trigger Update_BrickType on BrickType for
update as
begin
    insert into Logs(TriggerDate,TriggerType,NameAffectedTable,NoAMDRows)
	values( GETDATE(), 'UPDATE', 'BrickType', @@ROWCOUNT);

	insert into BrickTypeT(Type)
	select Type from inserted
end
go

update BrickType
set Type='Stone'
where Type like 'Red%'

select * from BrickType
select * from BrickTypeT
select * from Logs



go
create trigger Delete_BrickType on BrickType for
delete as
begin
    insert into Logs(TriggerDate,TriggerType,NameAffectedTable,NoAMDRows)
	values( GETDATE(), 'DELETE', 'BrickType', @@ROWCOUNT);

	DELETE FROM BrickTypeT
    WHERE Type IN (SELECT Type FROM deleted);
end
go

delete from BrickType
where BrickTypeId>3 

select * from BrickType
select * from BrickTypeT
select * from Logs


--d indexes

select * from sys.indexes

----------------------------ORDER BY-----------------------------
-- step 1
--order by -- only what follows after order by matters
select * from TileType
order by MaterialType -- clustered index scan

select * from TileType
order by TileTypeId


-- step 2
-- form nonclustered on MaterialType/ other field which is not p key
IF EXISTS (SELECT NAME FROM sys.indexes WHERE name='Nonclustered_Index_MaterialType')
DROP INDEX Nonclustered_Index_MaterialType ON TileType
CREATE NONCLUSTERED INDEX Nonclustered_Index_MaterialType ON TileType(MaterialType)

--step 3
-- check the nonclustered on teh created field
select * from TileType
order by MaterialType





--------------WHERE-------------------------------
--only select fields matter
-- use CLUSTERED/NONCLUSTERED in select to see that the created nonclustered is useful
select * from TileType

SELECT TileTypeId
from TileType 
where MaterialType like 's%' -- seek when the search is not that accurate
--nonclustered

SELECT TileTypeId
from TileType 
where MaterialType like '%s%' -- scan when the search is more accurate
--nonclustered

SELECT TileTypeId,MaterialType
from TileType 
where MaterialType like '%s%' -- in general, put accurate conditions to use nonclustered, else clustered will be used
--nonclustered

select TileTypeId,UsedIn
from TileType
where MaterialType like '%s%'
--clustered



-------JOIN--------------
--only select matters

--step 1
--clustered index seek & index scan
select *
from TileType tt inner join Product p
on tt.TileTypeId=p.TileTypeId

--step 2
--create nonclustered on foreign key
IF EXISTS (SELECT NAME FROM sys.indexes WHERE name='Nonclustered_idexx_Product_ProductId')
DROP INDEX Nonclustered_idexx_Product_ProductId ON Product
CREATE NONCLUSTERED INDEX Nonclustered_idexx_Product_ProductId ON Product(ProductId)

--step 3
select *
from TileType tt inner join Product p
on tt.TileTypeId=p.TileTypeId -- no difference

--!!!!! AS IN WHERE CLAUSE, we need to use in select ONLY CLUSTERED/NONCLUSTERED ????
select p.ProductId
from TileType tt inner join Product p
on tt.TileTypeId=p.TileTypeId
where p.Quality=2 and tt.MaterialType=''

select * from product
select * from TileType

drop trigger Delete_BrickType
drop trigger Update_BrickType
drop trigger Add_BrickType
drop table BrickTypeT
drop table Logs
drop view viewStoresCategoriesProducts
drop procedure addTileType
drop procedure addProduct
drop function checkWidthHeightDepth
drop function checkUsedIn
drop function checkPrice
drop function checkMaterialType

drop table ProductCategoryProduct
drop table DedemanStoreProductCategory
drop table Salary
drop table Manager
drop table DedemanStore
drop table Product
drop table BrickType
drop table TileType
drop table ProductCategory




