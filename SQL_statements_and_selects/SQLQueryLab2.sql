CREATE DATABASE DedemanUpdated;

CREATE TABLE DedemanStore(
Did INT PRIMARY KEY IDENTITY,  -- IDENTITY : 1,2,3...
Name varchar(50) NOT NULL,
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
Name varchar(50) NOT NULL,
)
CREATE TABLE DedemanStoreProductCategory(
Did INT FOREIGN KEY REFERENCES DedemanStore(Did),
PCId INT FOREIGN KEY REFERENCES ProductCategory(PCId),
CONSTRAINT pk_DedemanStoreProductCategory PRIMARY KEY(Did,PCId)
)

CREATE TABLE TileType(
TileTypeId INT PRIMARY KEY IDENTITY,
Type varchar(50) DEFAULT 'Ceramic'
)

CREATE TABLE BrickType(
BrickTypeId INT PRIMARY KEY IDENTITY,
Type varchar(50) DEFAULT 'Red Burnt'
)

-- m<-->n
CREATE TABLE Product(
ProductId INT PRIMARY KEY IDENTITY,
Name varchar(50) NOT NULL,

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
insert into DedemanStore(Name,City,NrOfClients,NrOfEmplyees) values ('Dedeman Cluj-Napoca','Cluj-Napoca',120,30)
insert into DedemanStore(Name,City,NrOfClients,NrOfEmplyees) values ('Dedeman Bucharest Nord','Bucharest',137,41),('Dedeman Bucharest South','Bucharest',119,20),('Dedeman Oradea','Oradea',200,37),('Dedeman Iasi','Iasi',210,50)

insert into TileType(Type) values ('Porcelain'),('Mosaic'),('Limestone'), ('Glass')
insert into BrickType(Type) values ('Red Burnt'),('Cement'),('Mortar')

insert into Product(Name,Price,Width,Height,Depth,Quality,TileTypeId) values ('Mosaic White Romania Tile',100.9,15,15,4,1,2)
insert into Product(Name,Price,Width,Height,Depth,Quality,TileTypeId) values ('Mosaic White Hungary Tile',120,15,15,4,1,2)
insert into Product(Name,Price,Width,Height,Depth,Quality,TileTypeId) values ('Limestone Black Marocco Tile',140,30,25,4,2,3)
insert into Product(Name,Price,Width,Height,Depth,Quality,TileTypeId) values ('Limestone Grey Italy Tile',170,25,25,8,1,3)
insert into Product(Name,Price,Width,Height,Depth,Quality,TileTypeId) values ('Mosaic Grey Romania Tile',99,15,15,4,2,2)
insert into Product(Name,Price,Width,Height,Depth,Quality,TileTypeId) values ('Mosaic Grey Bulgary Tile',120,20,15,10,3,2)
insert into Product(Name,Price,Width,Height,Depth,Quality,TileTypeId) values ('Porcelain Blue Spain Tile',140,40,20,4,1,1)
insert into Product(Name,Price,Width,Height,Depth,Quality,BricktypeId) values ('Concrete Romania Brick',170,40,20,4,2,1)


-- ADD COMMENTS TO QUERIES
select * from DedemanStore
select * from Product
select * from TileType

-- UPDATE,DELETE

--set the Price to 230, for all the products with Quality<3 or Height=15
UPDATE Product
SET Price=230
WHERE Quality<3 OR NOT Height<>15

--set the Price to 200 and Quality to 1, for all the products with TileTypeId 2 or 1.
UPDATE Product
SET Quality=1, Price=200
WHERE TileTypeId IN(1,2)

-- delete from DedemanStore all the cities that contain letter 'j'
DELETE FROM DedemanStore
WHERE City LIKE '%j%'

-- delete from DedemanStore all the empty names
DELETE FROM DedemanStore
WHERE Name IS NULL

-- SELECT 
--a. UNION, INTERSECT, EXCEPT

-- all products which contain Romania string in their names or start with L
SELECT *
FROM Product
WHERE Name LIKE 'L_%'
UNION
SELECT *
FROM Product
WHERE Name LIKE '%Romania'

-- select the first 2 ids of products that have height=15 and quality=1 at the same time
SELECT TOP 2 p1.ProductId
FROM Product p1
WHERE Height=15
INTERSECT
SELECT p2.ProductId
FROM Product p2
WHERE Quality=1

-- all the tile names of the products that have depth=4 but without having quality=2
SELECT p1.Name
FROM Product p1
WHERE Depth=4
EXCEPT
SELECT p2.Name
FROM Product p2
WHERE Quality=2

-- b. INNER JOIN, LEFT JOIN, RIGHT JOIN, FULL JOIN

-- add to all the products that have a TileType their tileType 
SELECT *
FROM TileType INNER JOIN Product ON TileType.TileTypeId=Product.TileTypeId

-- add to all the products their tileType and their BrickType
SELECT *
FROM Product
FULL OUTER JOIN 
TileType ON TileType.TileTypeId=Product.TileTypeId 
FULL OUTER JOIN 
BrickType ON BrickType.BrickTypeId=Product.BrickTypeId

-- add to all the products all the corresponding tileType table  (if the product does not correspond to any TileTypeId, put NULL)
SELECT *
FROM Product LEFT JOIN TileType ON Product.TileTypeId=TileType.TileTypeId

-- add to all the brickTypes all the products that they correspond to (if they do not have any products for which they are type, put NULL)
SELECT *
FROM Product RIGHT JOIN BrickType ON Product.BrickTypeId=BrickType.BrickTypeId

-- 2 queries using IN and EXISTS to introduce a subquery in the WHERE clause (one query per operator)

-- print the TileTypeId and the Quality of all products that have Quality1 and that have TileTypeId in the TileType table. Order them ascendingly, by TileTypeId
SELECT p.TileTypeId, p.Quality
FROM Product p
WHERE Quality=1 AND TileTypeId IN(SELECT tt.TileTypeId from TileType tt)
ORDER BY p.TileTypeId 

-- print the TileTypeId and the Quality of all products that have Quality1 and that have TileTypeId in the TileType table. Order them descendingly, by TileTypeId
SELECT p.TileTypeId, p.Quality
FROM Product p
WHERE Quality=1 AND  EXISTS(SELECT* FROM TileType tt WHERE tt.TileTypeId=p.TileTypeId)
ORDER BY p.TileTypeId desc

-- print the DIFFERENT TileTypeId and the Quality of all products that have Quality1 and that have TileTypeId in the TileType table. 
SELECT DISTINCT p.TileTypeId, p.Quality -- WITH DISTINCT
FROM Product p
WHERE Quality=1 AND  EXISTS(SELECT* FROM TileType tt WHERE tt.TileTypeId=p.TileTypeId)

-- 1 query with a subquery in the FROM clause

-- all the cities from the DedemanStores where the NrOfEmployees is >30
SELECT DSSpecial.City
FROM (SELECT d.City, d.NrOfClients
FROM DedemanStore d
WHERE NOT d.NrOfEmplyees<=30) DSSpecial

-- 3 GROUP BY queries

-- 2 having
-- 1 subquery

-- the avarage number of clients for each city
SELECT d.City, AVG(d.NrOfClients) as Average
FROM DedemanStore d
GROUP BY d.City

-- the minimum price for each tile type, having the minimum<230
SELECT tt.Type, MIN(p.Price) as MinimumPrice
FROM Product p INNER JOIN TileType tt ON p.TileTypeId=tt.TileTypeId
GROUP BY tt.Type
HAVING MIN(p.Price)<230


-- the avarage volume of every Product, computed for different qualities. If the qualities are the same, compute for different prices. 
--The avarage volume must be >1000
SELECT p.Quality,p.Price, AVG(p.Width*p.Height*p.Depth) as AvarageVolume
FROM Product p
GROUP BY p.Quality, p.Price
HAVING AVG(p.Width*p.Height*p.Depth)>1000 


-- find the tile types who have height greater that the avarage of all tile heights
SELECT tt.Type, AVG(p.Height) as Height
FROM TileType tt INNER JOIN Product p on p.TileTypeId=tt.TileTypeId
GROUP BY tt.Type,p.Height
having p.Height> (SELECT AVG(p.Height) from Product p)