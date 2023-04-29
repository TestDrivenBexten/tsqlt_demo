CREATE DATABASE Inventory
GO

USE [Inventory];
GO

CREATE TABLE [Material](
	[Material_ID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[Material_Name] [nchar](25) NULL
);
GO

CREATE TABLE [Category](
	[Category_ID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[Category_Name] [nchar](25) NULL
);
GO

CREATE TABLE [MaterialCategory](
	[Category_ID] INT NOT NULL,
	[Material_ID] INT NOT NULL,
    CONSTRAINT FK_Category FOREIGN KEY (Category_ID) REFERENCES Category (Category_ID),
    CONSTRAINT FK_Material FOREIGN KEY (Material_ID) REFERENCES Material (Material_ID)
);
GO