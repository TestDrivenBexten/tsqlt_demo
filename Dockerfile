FROM mcr.microsoft.com/mssql/server:2022-latest

USER root
WORKDIR /app
COPY PrepareServer.sql PrepareServer.sql
COPY tSQLt.class.sql tSQLt.class.sql
COPY entrypoint.sh entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
# RUN apt update && apt install -y curl
# RUN apt install -y unzip
# RUN curl https://tsqlt.org/download/tsqlt/ > tsqlt.zip
# # RUN unzip -q tsqlt.zip > /dev/null
# # | echo "Unzipped tSQLt"

# RUN /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "Password123!" -i PrepareServer.sql
# RUN /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "Password123!" -i tSQLt.class.sql
