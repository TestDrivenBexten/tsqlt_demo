CREATE PROCEDURE spDeleteItemById
    @itemId INT
AS BEGIN
    DELETE FROM
        Item
    WHERE
        Item_ID = @itemId;
END;
GO