#!/bin/bash
# Example taken from https://github.com/microsoft/mssql-docker/blob/master/linux/preview/examples/mssql-customize/configure-db.sh
DBSTATUS=1
ERRCODE=1
i=0

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

/opt/mssql-tools/bin/bcp Category in category.csv -S localhost -U sa -P $SA_PASSWORD -d Inventory -q -c -t "," -F 2
/opt/mssql-tools/bin/bcp Material in material.csv -S localhost -U sa -P $SA_PASSWORD -d Inventory -q -c -t "," -F 2

/opt/mssql-tools/bin/bcp Item in item.csv -S localhost -U sa -P $SA_PASSWORD -d Inventory -q -c -t "," -F 2
/opt/mssql-tools/bin/bcp MaterialCategory in material-category.csv -S localhost -U sa -P $SA_PASSWORD -d Inventory -q -c -t "," -F 2

/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -d Inventory -i PrepareServer.sql
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -d Inventory -i tSQLt.class.sql