Param(
	[Parameter(mandatory=$true)][string]$SA_PASSWORD
)

Install-Module -Force -Name SqlServer

$DBSTATUS=1
# $ERRCODE=$true
# TODO Better error handling
$i=0

function ExecuteSqlQuery {
	param (
		[Parameter(Position=0)][hashtable] $sqlParameters,
		[Parameter(Position=1)][string] $query
	)
	Invoke-Sqlcmd @sqlParameters -Query $query -TrustServerCertificate
}

function ExecuteSqlFile {
	param (
		[Parameter(Position=0)][hashtable] $sqlParameters,
		[Parameter(Position=1)][string] $inputFile
	)
	Invoke-Sqlcmd @sqlParameters -InputFile $inputFile -TrustServerCertificate
}

function Copy-HashTable-WithKey {
	param (
		[Parameter(Position=0,Mandatory=$true)][hashtable] $hashTable,
		[Parameter(Position=1,Mandatory=$true)][string] $hashKey,
		[Parameter(Position=2,Mandatory=$true)][string] $hashValue
	)
	$newHashTable = $hashTable.Clone()
	$newHashTable[$hashKey] = $hashValue
	$newHashTable
}

$sqlParameters = @{
	Username = "sa"
	Password = $SA_PASSWORD
	Server = "localhost"
	# QueryTimeout = 1
}

while ($DBSTATUS -ne 0) {
	$Row = ExecuteSqlQuery $sqlParameters "SET NOCOUNT ON; Select SUM(state) AS Count from sys.databases"
	$DBSTATUS = $Row.Item("Count")
	Start-Sleep -Seconds 10
}

if ( $DBSTATUS -ne 0) {
	Write-Output "SQL Server took more than 60 seconds to start up or one or more databases are not in an ONLINE state"
	exit 1
}

$masterSqlParameters = Copy-HashTable-WithKey $sqlParameters "Database" "master"
ExecuteSqlFile $masterSqlParameters "SetupDatabase.sql"

/opt/mssql-tools/bin/bcp Category in sample_data/category.csv -S localhost -U sa -P $SA_PASSWORD -d Inventory -q -c -t "," -F 2
/opt/mssql-tools/bin/bcp ItemType in sample_data/item-type.csv -S localhost -U sa -P $SA_PASSWORD -d Inventory -q -c -t "," -F 2

/opt/mssql-tools/bin/bcp Item in sample_data/item.csv -S localhost -U sa -P $SA_PASSWORD -d Inventory -q -c -t "," -F 2
/opt/mssql-tools/bin/bcp ItemTypeCategory in sample_data/item-type-category.csv -S localhost -U sa -P $SA_PASSWORD -d Inventory -q -c -t "," -F 2

/opt/mssql-tools/bin/bcp RecipeRequirement in sample_data/recipe-requirement.csv -S localhost -U sa -P $SA_PASSWORD -d Inventory -q -c -t "," -F 2
/opt/mssql-tools/bin/bcp Recipe in sample_data/recipe.csv -S localhost -U sa -P $SA_PASSWORD -d Inventory -q -c -t "," -F 2

$inventorySqlParameters = Copy-HashTable-WithKey $sqlParameters "Database" "Inventory"

# Create Functions
ExecuteSqlFile $inventorySqlParameters "sql/function/fnCanCraftRecipe.sql"

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
