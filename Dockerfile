FROM mcr.microsoft.com/mssql/server:2022-latest

USER root
RUN apt update && apt install -y curl
RUN curl https://tsqlt.org/download/tsqlt/ > tsqlt.zip
