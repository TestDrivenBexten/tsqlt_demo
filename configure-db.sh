#!/bin/bash
# Example taken from https://github.com/microsoft/mssql-docker/blob/master/linux/preview/examples/mssql-customize/configure-db.sh
DBSTATUS=1
ERRCODE=1
i=0

runSqlFile() {
	/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -d Inventory -i $1
}

while [[ $DBSTATUS -ne 0 ]] && [[ $i -lt 60 ]] && [[ $ERRCODE -ne 0 ]]; do
	i=$i+1
	DBSTATUS=$(/opt/mssql-tools/bin/sqlcmd -h -1 -t 1 -U sa -P $SA_PASSWORD -Q "SET NOCOUNT ON; Select SUM(state) from sys.databases")
	ERRCODE=$?
	sleep 1
done

if [ $DBSTATUS -ne 0 ] OR [ $ERRCODE -ne 0 ]; then 
	echo "SQL Server took more than 60 seconds to start up or one or more databases are not in an ONLINE state"
	exit 1
fi

/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -d master -i SetupDatabase.sql

/opt/mssql-tools/bin/bcp Category in sample_data/category.csv -S localhost -U sa -P $SA_PASSWORD -d Inventory -q -c -t "," -F 2 -r "\r\n"
/opt/mssql-tools/bin/bcp ItemType in sample_data/item-type.csv -S localhost -U sa -P $SA_PASSWORD -d Inventory -q -c -t "," -F 2 -r "\r\n"

/opt/mssql-tools/bin/bcp Item in sample_data/item.csv -S localhost -U sa -P $SA_PASSWORD -d Inventory -q -c -t "," -F 2 -r "\r\n"
/opt/mssql-tools/bin/bcp ItemTypeCategory in sample_data/item-type-category.csv -S localhost -U sa -P $SA_PASSWORD -d Inventory -q -c -t "," -F 2 -r "\r\n"

/opt/mssql-tools/bin/bcp RecipeRequirement in sample_data/recipe-requirement.csv -S localhost -U sa -P $SA_PASSWORD -d Inventory -q -c -t "," -F 2 -r "\r\n"
/opt/mssql-tools/bin/bcp Recipe in sample_data/recipe.csv -S localhost -U sa -P $SA_PASSWORD -d Inventory -q -c -t "," -F 2 -r "\r\n"

# Create Functions
runSqlFile sql/function/fnCanCraftRecipe.sql

# Create Stored Procedures
runSqlFile sql/stored_procedure/spCalculateRequirementCounts.sql
runSqlFile sql/stored_procedure/spCalculateRequirementCounts.sql
runSqlFile sql/stored_procedure/spCalculateRequirementCounts_Procedural.sql
runSqlFile sql/stored_procedure/spDeleteItemById.sql
runSqlFile sql/stored_procedure/spCraftRecipe.sql
runSqlFile sql/stored_procedure/spDeleteLowQualityItem.sql

# Prepare tSQLt on Server
runSqlFile sql/tsqlt/PrepareServer.sql
runSqlFile sql/tsqlt/tSQLt.class.sql

# Create test cases
runSqlFile sql/test_cases/spCraftRecipeTest.sql
runSqlFile sql/test_cases/spDeleteLowQualityItemTest.sql

# Run test cases
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -d Inventory -Q "EXEC tSQLt.RunAll;"
