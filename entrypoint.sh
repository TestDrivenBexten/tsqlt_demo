#!/bin/bash
# Example taken from https://github.com/microsoft/mssql-docker/blob/master/linux/preview/examples/mssql-customize/configure-db.sh
/opt/mssql/bin/sqlservr
DBSTATUS=1
ERRCODE=1
i=0

while [[ $DBSTATUS -ne 0 ]] && [[ $i -lt 60 ]] && [[ $ERRCODE -ne 0 ]]; do
	i=$i+1
	DBSTATUS=$(/opt/mssql-tools/bin/sqlcmd -h -1 -t 1 -U sa -P "Password123!" -Q "SET NOCOUNT ON; Select SUM(state) from sys.databases")
	ERRCODE=$?
	sleep 1
done

/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "Password123!" -i PrepareServer.sql
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "Password123!" -i tSQLt.class.sql
