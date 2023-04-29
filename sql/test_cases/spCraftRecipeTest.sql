EXEC tSQLt.NewTestClass 'spCraftRecipeTest';
GO

CREATE FUNCTION spCraftRecipeTest.Fake_CanCraftRecipe_False(
    @recipeId INT,
    @itemId1 INT,
    @itemId2 INT,
    @itemId3 INT)
RETURNS INT
AS BEGIN
    RETURN 0;
END;
GO

CREATE PROCEDURE spCraftRecipeTest.[test should expect exception if recipe can not be crafted]
AS BEGIN
    -- Arrange
    EXEC tSQLt.ExpectException @ExpectedMessage = 'Recipe 1 cannot be crafted';
    EXEC tSQLt.FakeFunction 'fnCanCraftRecipe', 'spCraftRecipeTest.Fake_CanCraftRecipe_False';

    -- Act & Assert
    EXEC spCraftRecipe 1, 10, 11, 12; -- Values do not matter
END;
GO
