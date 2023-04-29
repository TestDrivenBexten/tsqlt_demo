CREATE PROCEDURE spDeleteLowQualityItem
    @qualityThreshold INT,
    @materialId INT
AS BEGIN
    DELETE FROM
        Item
    WHERE
        Item_Quality < @qualityThreshold
        AND Material_ID = @materialId;
END;
GO