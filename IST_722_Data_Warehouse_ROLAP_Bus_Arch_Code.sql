/****** Object:  Database ist722_hhkhan_oa2_dw    Script Date: 3/1/2019 9:16:14 PM ******/


USE ist722_hhkhan_oa2_dw
;

-- Create the schema if it does not exist
IF (NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'FudgeMartInc')) 
BEGIN
    EXEC ('CREATE SCHEMA [FudgeMartInc] AUTHORIZATION [dbo]')
	PRINT 'CREATE SCHEMA [FudgeMartInc] AUTHORIZATION [dbo]'
END
go 

-- delete all the fact tables in the schema
DECLARE @fact_table_name varchar(100)
DECLARE cursor_loop CURSOR FAST_FORWARD READ_ONLY FOR 
	select TABLE_NAME from INFORMATION_SCHEMA.TABLES 
		where TABLE_SCHEMA='FudgeMartInc' and TABLE_NAME like 'Fact%'
OPEN cursor_loop
FETCH NEXT FROM cursor_loop  INTO @fact_table_name
WHILE @@FETCH_STATUS= 0
BEGIN
	EXEC ('DROP TABLE [FudgeMartInc].[' + @fact_table_name + ']')
	PRINT 'DROP TABLE [FudgeMartInc].[' + @fact_table_name + ']'
	FETCH NEXT FROM cursor_loop  INTO @fact_table_name
END
CLOSE cursor_loop
DEALLOCATE cursor_loop
go

-- delete all the other tables in the schema
DECLARE @table_name varchar(100)
DECLARE cursor_loop CURSOR FAST_FORWARD READ_ONLY FOR 
	select TABLE_NAME from INFORMATION_SCHEMA.TABLES 
		where TABLE_SCHEMA='FudgeMartInc' and TABLE_TYPE = 'BASE TABLE'
OPEN cursor_loop
FETCH NEXT FROM cursor_loop INTO @table_name
WHILE @@FETCH_STATUS= 0
BEGIN
	EXEC ('DROP TABLE [FudgeMartInc].[' + @table_name + ']')
	PRINT 'DROP TABLE [FudgeMartInc].[' + @table_name + ']'
	FETCH NEXT FROM cursor_loop  INTO @table_name
END
CLOSE cursor_loop
DEALLOCATE cursor_loop
go


-- Create a schema to hold  (set schema name on home page of workbook).
-- It would be good to do this only if the schema doesn't exist already.
/*
GO
CREATE SCHEMA FudgeMartInc
GO
*/


/* Create table FudgeMartInc.DimDate dimension */
PRINT 'CREATE TABLE FudgeMartInc.DimDate'
CREATE TABLE FudgeMartInc.DimDate (
   [DateKey]  int   NOT NULL
,  [Date]  datetime   NULL
,  [FullDateUSA]  nchar(11)   NOT NULL
,  [DayOfWeek]  tinyint   NOT NULL
,  [DayName]  nchar(10)   NOT NULL
,  [DayOfMonth]  tinyint   NOT NULL
,  [DayOfYear]  int   NOT NULL
,  [WeekOfYear]  tinyint   NOT NULL
,  [MonthName]  nchar(10)   NOT NULL
,  [MonthOfYear]  tinyint   NOT NULL
,  [Quarter]  tinyint   NOT NULL
,  [QuarterName]  nchar(10)   NOT NULL
,  [Year]  int   NOT NULL
, [IsAWeekday] varchar(1) NOT NULL DEFAULT (('N')),
	constraint pkFudgeMartIncDimDate PRIMARY KEY ([DateKey])
)
;


/* Create table FudgeMartInc.DimProduct dimension */
PRINT 'CREATE TABLE FudgeMartInc.DimProduct'
CREATE TABLE FudgeMartInc.DimProduct (
   [ProductKey]  int IDENTITY  NOT NULL
,  [ProductID]  int   NOT NULL
,  [Subsidiary]  nvarchar(15)   NOT NULL
,  [ProductName]  nvarchar(50)   NOT NULL
,  [SupplierName]  nvarchar(20)   NOT NULL
,  [ProductCategory]  nvarchar(50)   NOT NULL
,  [Discontinued]  nchar(1)  DEFAULT 'N' NOT NULL
,  [RowIsCurrent]  nchar(5)  DEFAULT 'True' NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200) default ('N/A') NOT NULL
, CONSTRAINT [pkFudgeMartIncDimProduct] PRIMARY KEY ( [ProductKey] )
) 
;



/* Create table FudgeMartInc.DimCustomer dimension */
PRINT 'CREATE TABLE FudgeMartInc.DimCustomer'
CREATE TABLE FudgeMartInc.DimCustomer (
   [CustomerKey]  int IDENTITY  NOT NULL
,  [CustomerID]  int   NOT NULL
,  [Subsidiary]  nvarchar(15)   NOT NULL
,  [CustomerEmail]  nvarchar(200)   NOT NULL
,  [CustomerLastName]  nvarchar(50)   NOT NULL
,  [CustomerFirstName]  nvarchar(50)   NOT NULL
,  [CustomerNameFirstLast]  nvarchar(101)   NOT NULL
,  [CustomerCity]  nvarchar(50)   NOT NULL
,  [CustomerState]  nvarchar(12)   NOT NULL
,  [CustomerZipcode]  nvarchar(20)   NOT NULL
,  [CustomerPhone]  nvarchar(12)   NOT NULL
,  [RowIsCurrent]  nchar(5)  DEFAULT 'True' NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)  default ('N/A') NOT NULL
, CONSTRAINT [pkFudgeMartIncDimCustomer] PRIMARY KEY( [CustomerKey] )
) 
;

/* Create table FudgeMartInc.FactFudgemartReviews fact table */
PRINT 'CREATE TABLE FudgeMartInc.FactFudgemartReviews'
CREATE TABLE FudgeMartInc.FactFudgemartReviews (
   [ProductKey]  int  NOT NULL
,  [CustomerKey]  int  NOT NULL
,  [ReviewDateKey]  int NOT NULL
,  [ReviewStars]  int NOT NULL
, CONSTRAINT [pkFudgeMartIncFactFudgemartReviews] PRIMARY KEY( [ProductKey], [CustomerKey] )
, CONSTRAINT [fkFudgeMartIncFactFudgemartReviewsProductKey] FOREIGN KEY ([ProductKey])
	REFERENCES FudgeMartInc.DimProduct(ProductKey)
, CONSTRAINT [fkFudgeMartIncFactFudgemartReviewsCustomerKey] FOREIGN KEY ([CustomerKey])
	REFERENCES FudgeMartInc.DimCustomer(CustomerKey)
, CONSTRAINT [fkFudgeMartIncFactFudgemartReviewsReviewDateKey] FOREIGN KEY ([ReviewDateKey])
	REFERENCES FudgeMartInc.DimDate(DateKey)
)
;

/* Create table FudgeMartInc.FactTotalSales fact table */
PRINT 'CREATE TABLE FudgeMartInc.FactTotalSales'
CREATE TABLE FudgeMartInc.FactTotalSales (
   [ProductKey]  int NOT NULL
,  [CustomerKey]  int NOT NULL
,  [TransactionDateKey]  int NOT NULL
,  [TransactionID]  int   NOT NULL
,  [Subsidiary]  nvarchar(15)   NOT NULL
,  [SoldAmount]  money   NOT NULL
,  [SoldQuantity]  int   NOT NULL
,  [UnitPrice]  money   NOT NULL
, CONSTRAINT [pkFudgeMartIncFactTotalSales] PRIMARY KEY ([ProductKey], [TransactionID] )
, CONSTRAINT [fkFudgeMartIncFactTotalSalesProductKey] FOREIGN KEY ([ProductKey])
	REFERENCES FudgeMartInc.DimProduct(ProductKey)
, CONSTRAINT [fkFudgeMartIncFactTotalSalesCustomerKey] FOREIGN KEY ([CustomerKey])
	REFERENCES FudgeMartInc.DimCustomer(CustomerKey)
, CONSTRAINT [fkFudgeMartIncFactTotalSalesTransactionDateKey] FOREIGN KEY ([TransactionDateKey])
	REFERENCES FudgeMartInc.DimDate(DateKey)
)
;



PRINT 'Insert special dimension values for null'

GO
SET IDENTITY_INSERT [FudgeMartInc].[DimProduct] ON
GO

-- Unknown Product
INSERT INTO [FudgeMartInc].[DimProduct]
           ([ProductKey]
		   ,[ProductID]
		   ,[Subsidiary]
           ,[ProductName]
		   ,[SupplierName]
		   ,[ProductCategory]
           ,[Discontinued])
     VALUES
           (-1
		   ,-1
           ,'Unk Subsid'
           ,'Unk Prod name'
           ,'Unk Supplier'
           ,'Unk Prod cat'
		   , '?')
GO
SET IDENTITY_INSERT [FudgeMartInc].[DimProduct] OFF

go
-- Unknown Customer
SET IDENTITY_INSERT [FudgeMartInc].[DimCustomer] ON
GO
INSERT INTO [FudgeMartInc].[DimCustomer]
			([CustomerKey]
		,  [CustomerID]
		,  [Subsidiary] 
		,  [CustomerEmail]  
		,  [CustomerLastName]  
		,  [CustomerFirstName]  
		,  [CustomerNameFirstLast]  
		,  [CustomerCity]  
		,  [CustomerState] 
		,  [CustomerZipcode] 
		,  [CustomerPhone]
			)
	VALUES 
		(-1, 
		-1, 
		'Unk Subsid',
		'Unk Email', 
		'Unk Last Name',
		'Unk First Name',
		'Unk Name',
		'Unk City',
		'Unk State',
		'Unk Zipcode', 
		'Unk Phone')
GO
SET IDENTITY_INSERT FudgeMartInc.DimCustomer OFF
GO


-- Unknown Date Value
INSERT INTO [FudgeMartInc].[DimDate]
           ([DateKey]
           ,[Date]
           ,[FullDateUSA]
           ,[DayOfWeek]
           ,[DayName]
           ,[DayOfMonth]
           ,[DayOfYear]
           ,[WeekOfYear]
           ,[MonthName]
           ,[MonthOfYear]
           ,[Quarter]
           ,[QuarterName]
           ,[Year]
           ,[IsAWeekday])
     VALUES
           (-1
           ,null
           ,'Unk date'
           ,0
           ,'Unk date'
           ,0
           ,0
           ,0
           ,'Unk month'
           ,0
           ,0
           ,'Unk qtr'
           ,0
           ,'?')
