SELECT * FROM client_table;
SELECT * FROM stock_table;
SELECT * FROM clientstock_table;
SELECT * FROM mutual_table;
SELECT * FROM family_table;
SELECT * FROM clientmutual_table;

--DROPING TABLES
DROP TABLE client_table;
DROP TABLE stock_table;
DROP TABLE clientstock_table;
DROP TABLE mutual_table;
DROP TABLE family_table;
DROP TABLE clientmutual_table;

--CREATING TABLE
--CREATING CLIENT TABLE
CREATE TABLE client_table (
TaxpayerID INT NOT NULL,
FirstName VARCHAR (255) NOT NULL,
LastName VARCHAR (255) NOT NULL,
Street VARCHAR  (255) NOT NULL,
City VARCHAR (255) NOT NULL,
State VARCHAR (255) NOT NULL,
Zip INT NOT NULL, 
Country VARCHAR (255) NOT NULL,
CONSTRAINT TaxpayerID_pk PRIMARY KEY (TaxpayerID)
);

----INSERTING VALUES IN CLIENT TABLE
INSERT INTO client_table (
TaxpayerID, 
Firstname ,
Lastname ,
Street ,
City ,
State ,
Zip ,
Country) 
VALUES
(545786625,
'Henry',
'King',
'1234 Fake Street',
'Los Angeles',
'CA', 
91754, 
'USA'
); 

INSERT INTO client_table (
TaxpayerID, 
Firstname ,
Lastname ,
Street ,
City ,
State ,
Zip ,
Country) 
VALUES
(123456789,
'Geroge',
'Hill',
'1324 No Street',
'Los Angeles',
'CA', 
91753, 
'USA'
); 

INSERT INTO client_table (
TaxpayerID, 
Firstname ,
Lastname ,
Street ,
City ,
State ,
Zip ,
Country) 
VALUES
(987654321,
'King',
'Pin',
'1673 Narrow Street',
'Miami',
'FL', 
12345, 
'USA'
); 

INSERT INTO client_table (
TaxpayerID, 
Firstname ,
Lastname ,
Street ,
City ,
State ,
Zip ,
Country) 
VALUES
(128765930,
'Bob',
'Marley',
'666 High Blvd',
'Compton',
'CA', 
66660, 
'USA'
); 

INSERT INTO client_table (
TaxpayerID, 
Firstname ,
Lastname ,
Street ,
City ,
State ,
Zip ,
Country) 
VALUES
(943270000,
'Nick',
'Sanders',
'123 Green Blvd',
'Seatlle',
'WA', 
88765, 
'USA'
); 

INSERT INTO client_table (
TaxpayerID, 
Firstname ,
Lastname ,
Street ,
City ,
State ,
Zip ,
Country) 
VALUES
(987765401,
'Donald',
'Bautista',
'556 Tall Ave',
'Tampa',
'FL', 
98987, 
'USA'
); 


SELECT * FROM client_table;

--CREATING STOCK TABLE
CREATE TABLE stock_table (
StockID VARCHAR(255) NOT NULL,
IssueName VARCHAR (255) NOT NULL,
Rating VARCHAR (100) NOT NULL, 
PrincipalBuiness VARCHAR (255) NOT NULL, 
PriceRangeHigh Decimal(38,2) NOT NULL, 
PrinceRangeLow Decimal(38,2) NOT NULL, 
CurrentPrice Decimal(38,2) NOT NULL, 
PriorYearReturn Decimal(38,2), 
FiveYearPeriodReturn Decimal(38,2), 
CONSTRAINT StockID_pk PRIMARY KEY (StockID)
);

SELECT * FROM stock_table;

--adding PLSQL (Not commited)
CREATE OR REPLACE PROCEDURE raise_currentprice
		 (v_id in stock_table.CurrentPrice%type)
		 IS
		 BEGIN
  			 UPDATE stock_table
  			 SET CurrentPrice = CurrentPrice *.80
   			WHERE CurrentPrice =v_id;
		 END raise_currentprice;

EXECUTE raise_currentprice (102);
         
         
--INSERTING VALUES IN STOCK TABLE
INSERT INTO stock_table 
VALUES
('12345',
'ABC',
'7',
'Retail',
123,
100, 
102, 
109,
108
);

INSERT INTO stock_table 
VALUES
('67890',
'MNO',
'4',
'Wholeseller',
787,
710, 
778, 
750,
767
);

INSERT INTO stock_table 
VALUES
('11234',
'PQR',
'6',
'Restraunt',
500,
400, 
450, 
455,
480
);

INSERT INTO stock_table 
VALUES
('56789',
'STU',
'2',
'Stockist',
900,
700, 
800, 
702,
710
);

INSERT INTO stock_table 
VALUES
('21345',
'XYZ',
'1',
'Cold Storage',
1100,
1050, 
1090, 
1080,
1093
);

SELECT * FROM stock_table;

--CREATING CLIENTSTOCK TABLE
CREATE TABLE clientstock_table (
TaxpayerID INT NOT NULL,
StockID VARCHAR (255) NOT NULL,
Quantity VARCHAR(255) NOT NULL, 
CONSTRAINT TaxpayerID_fk FOREIGN KEY (TaxpayerID) REFERENCES client_table (TaxPayerID),
CONSTRAINT StockID_fk FOREIGN KEY (StockID) REFERENCES stock_table (StockId) );

--INSERTING VALUES INTO CLIENTSTOCK TABLE
INSERT INTO clientstock_table (
TaxpayerID,
StockID,
Quantity)
VALUES
((SELECT TaxpayerID 
FROM client_table WHERE TaxpayerID = 545786625), 
(SELECT StockID 
FROM stock_table WHERE StockID = 12345), 
'400');

INSERT INTO clientstock_table (
TaxpayerID,
StockID,
Quantity)
VALUES
((SELECT TaxpayerID 
FROM client_table WHERE TaxpayerID = 123456789), 
(SELECT StockID 
FROM stock_table WHERE StockID = 67890), 
'200');

INSERT INTO clientstock_table (
TaxpayerID,
StockID,
Quantity)
VALUES
((SELECT TaxpayerID 
FROM client_table WHERE TaxpayerID = 987654321), 
(SELECT StockID 
FROM stock_table WHERE StockID = 11234), 
'350');

INSERT INTO clientstock_table (
TaxpayerID,
StockID,
Quantity)
VALUES
((SELECT TaxpayerID 
FROM client_table WHERE TaxpayerID = 128765930), 
(SELECT StockID 
FROM stock_table WHERE StockID = 56789), 
'660');

INSERT INTO clientstock_table (
TaxpayerID,
StockID,
Quantity)
VALUES
((SELECT TaxpayerID 
FROM client_table WHERE TaxpayerID = 943270000), 
(SELECT StockID 
FROM stock_table WHERE StockID = 21345), 
'450');

SELECT * FROM clientstock_table;

--CREATING MUTUAL TABLE
CREATE TABLE mutual_table (
MutualFundID VARCHAR(255) NOT NULL,
FundName VARCHAR (255) NOT NULL,
PrincipalObjective VARCHAR (1) NOT NULL,  
PriceRangeHigh Decimal(38,2) NOT NULL, 
PrinceRangeLow Decimal(38,2) NOT NULL, 
CurrentOffering Decimal(38,2) NOT NULL, 
Yield Decimal(38,2) NOT NULL, 
FamilyFundID INT,
CONSTRAINT MutualFundID_pk PRIMARY KEY (MutualFundID),
CONSTRAINT PrincipalObjective_Check CHECK (PrincipalObjective='G' OR PrincipalObjective='I'  OR PrincipalObjective='G') );

--INSERTING VALUES INTO MUTUAL TABLE
INSERT INTO mutual_table (
MutualFundID,
FundName, 
PrincipalObjective,  
PriceRangeHigh, 
PrinceRangeLow, 
CurrentOffering, 
Yield, 
FamilyFundID ) 
VALUES
('2345',
'ABC Fund',
'G',
5500.67,
1100.89,
4700.11, 
12,
110
); 

INSERT INTO mutual_table (
MutualFundID,
FundName, 
PrincipalObjective,  
PriceRangeHigh, 
PrinceRangeLow, 
CurrentOffering, 
Yield, 
FamilyFundID ) 
VALUES
('7675',
'DEF Fund',
'G',
6500.77,
1700.19,
3400.19, 
14, 
111
); 

INSERT INTO mutual_table (
MutualFundID,
FundName, 
PrincipalObjective,  
PriceRangeHigh, 
PrinceRangeLow, 
CurrentOffering, 
Yield, 
FamilyFundID ) 
VALUES
('8765',
'GHI Fund',
'I',
2200,
1900,
2050, 
58, 
112
); 

INSERT INTO mutual_table (
MutualFundID,
FundName, 
PrincipalObjective,  
PriceRangeHigh, 
PrinceRangeLow, 
CurrentOffering, 
Yield, 
FamilyFundID ) 
VALUES
('5456',
'JKL Fund',
'I',
1200,
1050,
1050, 
87, 
113
);

INSERT INTO mutual_table (
MutualFundID,
FundName, 
PrincipalObjective,  
PriceRangeHigh, 
PrinceRangeLow, 
CurrentOffering, 
Yield, 
FamilyFundID ) 
VALUES
('4956',
'XYZ Fund',
'G',
8200,
7600,
7900, 
80, 
114
);

SELECT * FROM mutual_table;

--CREATING FAMILY TABLE
CREATE TABLE family_table (
FamilyFundID INT NOT NULL,
MutualFundID VARCHAR (255) NOT NULL,
FullName VARCHAR (255) NOT NULL,
Street VARCHAR  (255) NOT NULL,
City VARCHAR (255) NOT NULL,
State VARCHAR (255) NOT NULL,
Zip INT NOT NULL, 
Country VARCHAR (255) NOT NULL,
CONSTRAINT FamilyFundID_pk PRIMARY KEY (FamilyFundID),
CONSTRAINT MutualFundID_fk FOREIGN KEY (MutualFundID) REFERENCES mutual_table (MutualFundID) );

--INSERTING VALUES IN FAMILY TABLE
INSERT INTO family_table (
FamilyFundID,
MutualFundID,
FullName,
Street,
City,
State,
Zip,
Country
)
VALUES
((SELECT FamilyFundID
FROM mutual_table WHERE FamilyFundID = 110),
(SELECT MutualFundID 
FROM mutual_table WHERE MutualFundID = 2345),
'Jose Ulloa',
'435 Fake Street',
'Los Angeles',
'CA',
'12345',
'USA');

INSERT INTO family_table (
FamilyFundID,
MutualFundID,
FullName,
Street,
City,
State,
Zip,
Country
)
VALUES
((SELECT FamilyFundID
FROM mutual_table WHERE FamilyFundID = 111),
(SELECT MutualFundID 
FROM mutual_table WHERE MutualFundID = 7675),
'Mike Smith',
'1878 Noreal Blvd',
'Los Angeles',
'CA',
'45678',
'USA');

INSERT INTO family_table (
FamilyFundID,
MutualFundID,
FullName,
Street,
City,
State,
Zip,
Country
)
VALUES
((SELECT FamilyFundID
FROM mutual_table WHERE FamilyFundID = 112),
(SELECT MutualFundID 
FROM mutual_table WHERE MutualFundID = 8765),
'Eric Zhu',
'9898 Happy Dr',
'Miami',
'FL',
'76543',
'USA');

INSERT INTO family_table (
FamilyFundID,
MutualFundID,
FullName,
Street,
City,
State,
Zip,
Country
)
VALUES
((SELECT FamilyFundID
FROM mutual_table WHERE FamilyFundID = 113),
(SELECT MutualFundID 
FROM mutual_table WHERE MutualFundID = 5456),
'Aron Mejia',
'95 Spark Street',
'Seattle',
'WA',
'88765',
'USA');

INSERT INTO family_table (
FamilyFundID,
MutualFundID,
FullName,
Street,
City,
State,
Zip,
Country
)
VALUES
((SELECT FamilyFundID
FROM mutual_table WHERE FamilyFundID = 114),
(SELECT MutualFundID 
FROM mutual_table WHERE MutualFundID = 4956),
'Wendy Xiong',
'765 High Street',
'Austin',
'TX',
'12342',
'USA');

SELECT * FROM family_table;

--ALTERING MUTUAL TABLE 
ALTER TABLE mutual_table 
ADD CONSTRAINT FamilyFundID_fk
FOREIGN KEY (FamilyFundID)
REFERENCES family_table (FamilyFundID) ;

--CREATING CLIENTMUTUAL TABLE
CREATE TABLE clientmutual_table (
TaxpayerID INT NOT NULL,
MutualFundID VARCHAR (255) NOT NULL,
Quantity VARCHAR(255) NOT NULL, 
CONSTRAINT TaxpayerID_fk1 FOREIGN KEY (TaxpayerID) REFERENCES client_table (TaxPayerID),
CONSTRAINT MutualFundID_fk1 FOREIGN KEY (MutualFundID) REFERENCES mutual_table (MutualFundId) );

--INSERTING VALUES IN CLIENTMUTUAL TABLE
INSERT INTO clientmutual_table
(TaxpayerID,
MutualFundID,
Quantity)
VALUES
((SELECT TaxPayerID 
FROM client_table WHERE TaxPayerID = 545786625),
(SELECT MutualFundID 
FROM mutual_table WHERE MutualFundID = 2345),
100);

INSERT INTO clientmutual_table
(TaxpayerID,
MutualFundID,
Quantity)
VALUES
((SELECT TaxPayerID 
FROM client_table WHERE TaxPayerID = 123456789),
(SELECT MutualFundID 
FROM mutual_table WHERE MutualFundID = 7675),
150);

INSERT INTO clientmutual_table
(TaxpayerID,
MutualFundID,
Quantity)
VALUES
((SELECT TaxPayerID 
FROM client_table WHERE TaxPayerID = 987654321),
(SELECT MutualFundID 
FROM mutual_table WHERE MutualFundID = 8765),
200);

INSERT INTO clientmutual_table
(TaxpayerID,
MutualFundID,
Quantity)
VALUES
((SELECT TaxPayerID 
FROM client_table WHERE TaxPayerID = 128765930),
(SELECT MutualFundID 
FROM mutual_table WHERE MutualFundID = 5456),
250);

INSERT INTO clientmutual_table
(TaxpayerID,
MutualFundID,
Quantity)
VALUES
((SELECT TaxPayerID 
FROM client_table WHERE TaxPayerID = 943270000),
(SELECT MutualFundID 
FROM mutual_table WHERE MutualFundID = 4956),
300);

SELECT * FROM clientmutual_table;


--PLSQL
CREATE OR REPLACE PROCEDURE raise_salary
		 (v_id in emp.empno%type)
		 IS
		 BEGIN
  			 UPDATE emp
  			 SET sal = sal *1.10
   			WHERE empno =v_id;
		 END raise_salary;