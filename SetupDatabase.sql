CREATE DATABASE Inventory
GO

USE [Inventory];
GO

CREATE TABLE [ItemType](
	[ItemType_ID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[ItemType_Name] [nchar](25) NOT NULL
);
GO

CREATE TABLE [Category](
	[Category_ID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[Category_Name] [nchar](25) NOT NULL
);
GO

CREATE TABLE [Item](
	[Item_ID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[ItemType_ID] INT NOT NULL,
    [Item_Quality] INT NOT NULL,
    CONSTRAINT FK_Item_ItemType_ID FOREIGN KEY (ItemType_ID) REFERENCES ItemType (ItemType_ID)
);
GO

CREATE TABLE [Recipe](
	[Recipe_ID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Recipe_Name] [nchar](25) NOT NULL,
	[ItemType_ID_1] INT NOT NULL,
	[ItemType_ID_2] INT NOT NULL,
	[ItemType_ID_3] INT NULL,
    CONSTRAINT FK_Recipe_ItemType_ID_1 FOREIGN KEY (ItemType_ID_1) REFERENCES ItemType (ItemType_ID),
    CONSTRAINT FK_Recipe_ItemType_ID_2 FOREIGN KEY (ItemType_ID_2) REFERENCES ItemType (ItemType_ID),
    CONSTRAINT FK_Recipe_ItemType_ID_3 FOREIGN KEY (ItemType_ID_3) REFERENCES ItemType (ItemType_ID)
);
GO

CREATE TABLE [ItemTypeCategory](
	[Category_ID] INT NOT NULL,
	[ItemType_ID] INT NOT NULL,
    CONSTRAINT FK_ItemTypeCategory_Category_ID FOREIGN KEY (Category_ID) REFERENCES Category (Category_ID),
    CONSTRAINT FK_ItemTypeCategory_ItemType_ID FOREIGN KEY (ItemType_ID) REFERENCES ItemType (ItemType_ID)
);
GO

/*
    Views
*/
CREATE VIEW vwItemItemTypeNameQuality AS (
    SELECT
        ItemType.ItemType_Name,
        Item.Item_Quality
    FROM
        Item
        JOIN ItemType ON Item.ItemType_ID = ItemType.ItemType_ID
)
