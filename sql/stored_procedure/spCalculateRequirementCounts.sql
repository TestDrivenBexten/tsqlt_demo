CREATE PROCEDURE spCalculateRequirementCounts
    @recipeId INT
AS BEGIN
    SELECT
        RequirementID,
        COUNT(*) AS RequirementCount
    FROM (
        SELECT
            RecipeRequirement_ID_1,
            RecipeRequirement_ID_2,
            RecipeRequirement_ID_3
        FROM
            Recipe
        WHERE
            Recipe.Recipe_ID = @RecipeId
    ) p
    UNPIVOT (
        RequirementID
        FOR RequirementName IN (RecipeRequirement_ID_1, RecipeRequirement_ID_2, RecipeRequirement_ID_3)
    ) AS PivotTable
    GROUP BY
    RequirementID
END;
GO
