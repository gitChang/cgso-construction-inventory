#!/bin/bash

clear
database_date="$(date +'%m%d%Y')"
target_file="$HOME/DatabaseBackup/cgso_construction/cgsois_construction_prod_db_$database_date.sql"

echo "Performing psql database dump..."
sleep .3
PGPASSWORD="pwd_cgsoisc" pg_dump --format=c --verbose -d cgsois_construction_prod_db -U cgsois_construction -h 127.0.0.1  --file $target_file

if [ ! -f $target_file ]; then
  echo "pg_dump file not found!"
  exit 1
fi

echo "Database backup complete!"
ls $HOME/DatabaseBackup/cgso_construction/ | grep $database_date

sleep .3
echo "Sending a copy of backup to Developer's Machine..."
scp $HOME/DatabaseBackup/cgso_construction/cgsois_construction_prod_db_$database_date.sql charlie.pandacan@192.168.1.40:~/DatabaseBackup/cgso_construction/
echo "Sending complete. Please check the dump file manually."
