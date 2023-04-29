FROM mcr.microsoft.com/mssql/server:2022-latest

USER root
WORKDIR /app
COPY PrepareServer.sql PrepareServer.sql
COPY tSQLt.class.sql tSQLt.class.sql
COPY entrypoint.sh entrypoint.sh

EXPOSE 1433
ENTRYPOINT ["./entrypoint.sh"]
