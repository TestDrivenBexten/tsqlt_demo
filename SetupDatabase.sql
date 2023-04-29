CREATE DATABASE Inventory
GO

USE [Inventory];
GO

CREATE TABLE [Material](
	[Material_ID] [int] IDENTITY(1,1) NOT NULL,
	[Material_Name] [nchar](25) NULL
);
GO

CREATE TABLE [Category](
	[Category_ID] [int] IDENTITY(1,1) NOT NULL,
	[Category_Name] [nchar](25) NULL
);
GO