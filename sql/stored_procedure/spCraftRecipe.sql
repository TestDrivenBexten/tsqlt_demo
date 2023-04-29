CREATE PROCEDURE spCraftRecipe
    @recipeId INT,
    @itemId1 INT,
    @itemId2 INT,
    @itemId3 INT
AS BEGIN
    IF dbo.fnCanCraftRecipe(@recipeId, @itemId1, @itemId2, @itemId3) = 0
        THROW 123456, 'Recipe 1 can not be crafted', 1;

    EXEC spDeleteItemById @itemId1;
    EXEC spDeleteItemById @itemId2;
    EXEC spDeleteItemById @itemId3;
    /*
        Insert new item to database
    */
END;
GO