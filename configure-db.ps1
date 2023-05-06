Param(
	[Parameter(mandatory=$true)][string]$SA_PASSWORD
)

Install-Module -Force -Name SqlServer

$DBSTATUS=1
# $ERRCODE=$true
# TODO Better error handling
$i=0

while ($DBSTATUS -ne 0) {
	$Row = Invoke-Sqlcmd -QueryTimeout 1 -TrustServerCertificate -Username sa -Password  $SA_PASSWORD -Query "SET NOCOUNT ON; Select SUM(state) AS Count from sys.databases"
	$DBSTATUS = $Row.Item("Count")
	Start-Sleep -Seconds 10
}

if ( $DBSTATUS -ne 0) {
	Write-Output "SQL Server took more than 60 seconds to start up or one or more databases are not in an ONLINE state"
	exit 1
}

/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -d master -i SetupDatabase.sql

/opt/mssql-tools/bin/bcp Category in sample_data/category.csv -S localhost -U sa -P $SA_PASSWORD -d Inventory -q -c -t "," -F 2
/opt/mssql-tools/bin/bcp ItemType in sample_data/item-type.csv -S localhost -U sa -P $SA_PASSWORD -d Inventory -q -c -t "," -F 2

/opt/mssql-tools/bin/bcp Item in sample_data/item.csv -S localhost -U sa -P $SA_PASSWORD -d Inventory -q -c -t "," -F 2
/opt/mssql-tools/bin/bcp ItemTypeCategory in sample_data/item-type-category.csv -S localhost -U sa -P $SA_PASSWORD -d Inventory -q -c -t "," -F 2

/opt/mssql-tools/bin/bcp RecipeRequirement in sample_data/recipe-requirement.csv -S localhost -U sa -P $SA_PASSWORD -d Inventory -q -c -t "," -F 2
/opt/mssql-tools/bin/bcp Recipe in sample_data/recipe.csv -S localhost -U sa -P $SA_PASSWORD -d Inventory -q -c -t "," -F 2

# Create Functions
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -d Inventory -i sql/function/fnCanCraftRecipe.sql

# Create Stored Procedures
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -d Inventory -i sql/stored_procedure/spDeleteItemById.sql
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -d Inventory -i sql/stored_procedure/spCraftRecipe.sql
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -d Inventory -i sql/stored_procedure/spDeleteLowQualityItem.sql

# Prepare tSQLt on Server
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -d Inventory -i sql/tsqlt/PrepareServer.sql
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -d Inventory -i sql/tsqlt/tSQLt.class.sql

# Create test cases
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -d Inventory -i sql/test_cases/spCraftRecipeTest.sql
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -d Inventory -i sql/test_cases/spDeleteLowQualityItemTest.sql

# Run test cases
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -d Inventory -Q "EXEC tSQLt.RunAll;"
