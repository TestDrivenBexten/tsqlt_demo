EXEC tSQLt.NewTestClass 'spDeleteLowQualityItemTest';
GO

CREATE PROCEDURE spDeleteLowQualityItemTest.[test should not delete above threshold]
AS BEGIN
    -- Arrange
    DECLARE @rowCount INT;
    EXEC tSQLt.FakeTable 'Item';
    INSERT INTO Item (Item_ID, Material_ID, Item_Quality)
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
