#!/bin/bash

read -p 'Date backed up: ' date_bu

pg_restore --verbose -U cgsois_construction -h localhost -c -d cgsois_construction_prod_db ~/DatabaseBackup/cgso_construction/cgsois_construction_prod_db_$date_bu.sql
