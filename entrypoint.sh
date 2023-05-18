#!/bin/bash
pwsh -File ./configure-db.ps1 -SA_PASSWORD $SA_PASSWORD &

/opt/mssql/bin/sqlservr
