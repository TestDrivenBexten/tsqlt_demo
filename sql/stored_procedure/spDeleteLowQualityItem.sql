CREATE PROCEDURE spDeleteLowQualityItem
    @qualityThreshold INT,
    @itemTypeId INT
AS BEGIN
    DELETE FROM
        Item
    WHERE
        Item_Quality < @qualityThreshold
        AND ItemType_ID = @itemTypeId;
END;
GO