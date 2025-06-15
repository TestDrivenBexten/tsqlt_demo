CREATE PROCEDURE spCalculateRequirementCounts_Procedural
    @recipeId INT
AS BEGIN
    DECLARE @ColumnList NVARCHAR(MAX);
    SELECT
        @ColumnList = STRING_AGG(COLUMN_NAME, ',')
    FROM
        INFORMATION_SCHEMA.COLUMNS
    WHERE
        TABLE_NAME = 'Recipe'
            AND COLUMN_NAME LIKE 'RecipeRequirement_ID_%';

    DECLARE @SqlQuery NVARCHAR(MAX) = '
    SELECT
            RequirementID,
            COUNT(*) AS RequirementCount
        FROM (
            SELECT
            ' + @ColumnList + '
            FROM
                Recipe
            WHERE
                Recipe.Recipe_ID = 1
        ) p
        UNPIVOT (
            RequirementID
            FOR RequirementName IN (' + @ColumnList + ')
        ) AS PivotTable
        GROUP BY
        RequirementID
    '
    EXEC sp_executeSQL @SqlQuery;
END;
GO