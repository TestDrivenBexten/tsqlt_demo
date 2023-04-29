EXEC tSQLt.NewTestClass 'spDeleteLowQualityItemTest';
GO

CREATE PROCEDURE spDeleteLowQualityItemTest.[test should not delete above threshold]
AS BEGIN
    -- Arrange
    DECLARE @rowCount INT;
    EXEC tSQLt.FakeTable 'Item';
    INSERT INTO Item (Item_ID, ItemType_ID, Item_Quality)
    VALUES (10, 20, 50);

    -- Act
    EXEC spDeleteLowQualityItem 40, 20;

    -- Assert
    SELECT
        @rowCount = COUNT(*)
    FROM
        Item;
    EXEC tSQLt.assertEquals 1, @rowCount;
END;
GO

CREATE PROCEDURE spDeleteLowQualityItemTest.[test should delete below threshold]
AS BEGIN
    -- Arrange
    DECLARE @rowCount INT;
    EXEC tSQLt.FakeTable 'Item';
    INSERT INTO Item (Item_ID, ItemType_ID, Item_Quality)
    VALUES (10, 20, 30);

    -- Act
    EXEC spDeleteLowQualityItem 40, 20;

    -- Assert
    SELECT
        @rowCount = COUNT(*)
    FROM
        Item;
    EXEC tSQLt.assertEquals 0, @rowCount;
END;
GO

CREATE PROCEDURE spDeleteLowQualityItemTest.[test should not delete item of different type]
AS BEGIN
    -- Arrange
    DECLARE @rowCount INT;
    EXEC tSQLt.FakeTable 'Item';
    INSERT INTO Item (Item_ID, ItemType_ID, Item_Quality)
    VALUES (10, 123, 30);

    -- Act
    EXEC spDeleteLowQualityItem 40, 20;

    -- Assert
    SELECT
        @rowCount = COUNT(*)
    FROM
        Item;
    EXEC tSQLt.assertEquals 1, @rowCount;
END;
GO
