*********************************************************
************ I have used Azure Data Studio **************
*********************************************************

CREATE TABLE [dbo].[cateory] (
    [Category]     NVARCHAR (50) NOT NULL,
    [Sub_Category] NVARCHAR (50) NOT NULL
);

CREATE TABLE [dbo].[shipment] (
    [Order_ID]  NVARCHAR (50) NOT NULL,
    [Ship_Date] DATE          NOT NULL,
    [Ship_Mode] NVARCHAR (50) NOT NULL
);

CREATE TABLE [dbo].[superstore] (
    [Row_ID]        SMALLINT      NOT NULL,
    [Order_ID]      NVARCHAR (50) NULL,
    [Order_Date]    DATE          NOT NULL,
    [Customer_ID]   NVARCHAR (50) NOT NULL,
    [Customer_Name] NVARCHAR (50) NOT NULL,
    [Segment]       NVARCHAR (50) NOT NULL,
    [Country]       NVARCHAR (50) NOT NULL,
    [City]          NVARCHAR (50) NOT NULL,
    [State]         NVARCHAR (50) NOT NULL,
    [Postal_Code]   INT           NOT NULL,
    [Region]        NVARCHAR (50) NOT NULL,
    [Product_ID]    NVARCHAR (50) NOT NULL,
    [Sub_Category]  NVARCHAR (50) NOT NULL,
    [Product_Name]  VARCHAR (MAX) NOT NULL,
    [Sales]         FLOAT (53)    NOT NULL,
    [Quantity]      TINYINT       NOT NULL,
    [Discount]      FLOAT (53)    NOT NULL,
    [Profit]        FLOAT (53)    NULL
);

