CREATE DATABASE Inventory
GO

USE [Inventory];
GO

CREATE TABLE [ItemType](
	[ItemType_ID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[ItemType_Name] [varchar](25) NOT NULL
);
GO

CREATE TABLE [Category](
	[Category_ID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[Category_Name] [varchar](25) NOT NULL
);
GO

CREATE TABLE [Item](
	[Item_ID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[ItemType_ID] INT NOT NULL,
    [Item_Quality] INT NOT NULL,
    CONSTRAINT FK_Item_ItemType_ID FOREIGN KEY (ItemType_ID) REFERENCES ItemType (ItemType_ID)
);
GO

CREATE TABLE [ItemTypeCategory](
	[Category_ID] INT NOT NULL,
	[ItemType_ID] INT NOT NULL,
    CONSTRAINT FK_ItemTypeCategory_Category_ID FOREIGN KEY (Category_ID) REFERENCES Category (Category_ID),
    CONSTRAINT FK_ItemTypeCategory_ItemType_ID FOREIGN KEY (ItemType_ID) REFERENCES ItemType (ItemType_ID)
);
GO

CREATE TABLE [RecipeRequirement](
	[RecipeRequirement_ID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[ItemType_ID] INT NULL,
	[Category_ID] INT NULL,
    CONSTRAINT FK_RecipeRequirement_ItemType_ID FOREIGN KEY (ItemType_ID) REFERENCES ItemType (ItemType_ID),
    CONSTRAINT FK_RecipeRequirement_Category_ID FOREIGN KEY (Category_ID) REFERENCES Category (Category_ID)
);
GO

CREATE TABLE [Recipe](
	[Recipe_ID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ItemType_ID] [int] NOT NULL,
	[RecipeRequirement_ID_1] INT NOT NULL,
	[RecipeRequirement_ID_2] INT NOT NULL,
	[RecipeRequirement_ID_3] INT NULL,
    CONSTRAINT FK_Recipe_ItemType_ID FOREIGN KEY (ItemType_ID) REFERENCES ItemType (ItemType_ID),
    CONSTRAINT FK_Recipe_RecipeRequirement_ID_1 FOREIGN KEY (RecipeRequirement_ID_1) REFERENCES RecipeRequirement (RecipeRequirement_ID),
    CONSTRAINT FK_Recipe_RecipeRequirement_ID_2 FOREIGN KEY (RecipeRequirement_ID_2) REFERENCES RecipeRequirement (RecipeRequirement_ID),
    CONSTRAINT FK_Recipe_RecipeRequirement_ID_3 FOREIGN KEY (RecipeRequirement_ID_3) REFERENCES RecipeRequirement (RecipeRequirement_ID)
);
GO

/*
    Views
*/
CREATE VIEW vwItemNameQuality AS (
    SELECT
        ItemType.ItemType_Name,
        Item.Item_Quality
    FROM
        Item
        JOIN ItemType ON Item.ItemType_ID = ItemType.ItemType_ID
);
GO

CREATE VIEW vwRecipeRequirementName AS (
    SELECT
        RecipeRequirement.RecipeRequirement_ID,
        CASE
            WHEN RecipeRequirement.ItemType_ID IS NOT NULL THEN ItemType.ItemType_Name
            WHEN RecipeRequirement.Category_ID IS NOT NULL THEN CONCAT('(',RTRIM(Category.Category_Name),')')
            ELSE '?'
        END AS RequirementName
    FROM
        RecipeRequirement
        LEFT JOIN ItemType ON ItemType.ItemType_ID = RecipeRequirement.ItemType_ID
        LEFT JOIN Category ON Category.Category_ID = RecipeRequirement.Category_ID
);
GO

CREATE VIEW vwRecipeInfo AS (
    SELECT
        Recipe.Recipe_ID,
        ItemType.ItemType_Name,
        Require1.RequirementName AS Requirement1,
        Require2.RequirementName AS Requirement2,
        Require3.RequirementName AS Requirement3
    FROM
        Recipe
        JOIN ItemType ON ItemType.ItemType_ID = Recipe.ItemType_ID
        JOIN vwRecipeRequirementName Require1 ON
            Require1.RecipeRequirement_ID = Recipe.RecipeRequirement_ID_1
        JOIN vwRecipeRequirementName Require2 ON
            Require2.RecipeRequirement_ID = Recipe.RecipeRequirement_ID_2
        LEFT JOIN vwRecipeRequirementName Require3 ON
            Require3.RecipeRequirement_ID = Recipe.RecipeRequirement_ID_3
);
GO
