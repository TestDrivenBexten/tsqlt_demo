#!/bin/bash
./configure-db.sh &

/opt/mssql/bin/sqlservr
