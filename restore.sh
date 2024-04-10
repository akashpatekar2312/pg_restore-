#!/bin/bash
# set -x
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
export PGPASSFILE="/root/.pgpass"
read -e -p "Enter the name of the dump file followed by the path : " dump
read -e -p "Enter the name of the structure file followed by the path: " str
echo "Terminating all active sessions..."
sudo -u postgres psql -d pgtms -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='pgtms' AND state='active';"

# Drop the database
echo "Dropping the database..."
sudo -u postgres psql -c "DROP DATABASE IF EXISTS pgtms;"

# Managing permissions of Tablespaces folders :
chmod -R 777 /var/lib/postgresql/datafiles/pgtms/DFAPPL
chmod -R 777 /var/lib/postgresql/datafiles/pgtms/UTAPPL
chmod -R 777 /var/lib/postgresql/datafiles/pgtms/SEAPPL
chmod -R 777 /var/lib/postgresql/datafiles/pgtms/LODEVI
chmod -R 777 /var/lib/postgresql/datafiles/pgtms/TRAPPL
chmod -R 777 /var/lib/postgresql/datafiles/pgtms/ALAPPL
chmod -R 777 /var/lib/postgresql/datafiles/pgtms/IMLANE
chmod -R 777 /var/lib/postgresql/datafiles/pgtms/POAPPL
chmod -R 777 /var/lib/postgresql/datafiles/pgtms/EDFILE
chmod -R 777 /var/lib/postgresql/datafiles/pgtms/LOAPPL
chmod -R 777 /var/lib/postgresql/datafiles/pgtms/IMPLAZ
chmod -R 777 /var/lib/postgresql/datafiles/pgtms/CCFILE
chmod -R 777 /var/lib/postgresql/datafiles/pgtms/INDAPP
chmod -R 777 /var/lib/postgresql/datafiles/pgtms/IMGLDS
chmod -R 777 /var/lib/postgresql/datafiles/pgtms/CCHBLT
chmod -R 777 /var/lib/postgresql/datafiles/pgtms/BLTHST
chmod -R 777 /var/lib/postgresql/datafiles/pgtms/IMGBTH
chmod -R 777 /var/lib/postgresql/datafiles/pgtms/IMGDOC
chmod -R 777 /var/lib/postgresql/datafiles/pgtms/IDXBLT
chmod -R 777 /var/lib/postgresql/datafiles/pgtms/TBLBLT
chmod -R 777 /var/lib/postgresql/datafiles/pgtms/CCHTXN
chmod -R 777 /var/lib/postgresql/datafiles/pgtms/CCHIDX
chmod -R 777 /var/lib/postgresql/datafiles/pgtms/IDX_BLTHIST
chmod -R 777 /var/lib/postgresql/datafiles/pgtms/TBL_BLTHIST

# Managing ownership of Tablespaces
chown postgres: /var/lib/postgresql/datafiles/pgtms/DFAPPL
chown postgres: /var/lib/postgresql/datafiles/pgtms/UTAPPL
chown postgres: /var/lib/postgresql/datafiles/pgtms/SEAPPL
chown postgres: /var/lib/postgresql/datafiles/pgtms/LODEVI
chown postgres: /var/lib/postgresql/datafiles/pgtms/TRAPPL
chown postgres: /var/lib/postgresql/datafiles/pgtms/ALAPPL
chown postgres: /var/lib/postgresql/datafiles/pgtms/IMLANE
chown postgres: /var/lib/postgresql/datafiles/pgtms/POAPPL
chown postgres: /var/lib/postgresql/datafiles/pgtms/EDFILE
chown postgres: /var/lib/postgresql/datafiles/pgtms/LOAPPL
chown postgres: /var/lib/postgresql/datafiles/pgtms/IMPLAZ
chown postgres: /var/lib/postgresql/datafiles/pgtms/CCFILE
chown postgres: /var/lib/postgresql/datafiles/pgtms/INDAPP
chown postgres: /var/lib/postgresql/datafiles/pgtms/IMGLDS
chown postgres:  /var/lib/postgresql/datafiles/pgtms/CCHBLT
chown postgres:  /var/lib/postgresql/datafiles/pgtms/BLTHST
chown postgres:  /var/lib/postgresql/datafiles/pgtms/IMGBTH
chown postgres:  /var/lib/postgresql/datafiles/pgtms/IMGDOC
chown postgres:  /var/lib/postgresql/datafiles/pgtms/TBLBLT
chown postgres:  /var/lib/postgresql/datafiles/pgtms/IDXBLT
chown postgres:  /var/lib/postgresql/datafiles/pgtms/CCHTXN
chown postgres:  /var/lib/postgresql/datafiles/pgtms/CCHIDX
chown postgres:  /var/lib/postgresql/datafiles/pgtms/IDX_BLTHIST
chown postgres:  /var/lib/postgresql/datafiles/pgtms/TBL_BLTHIST

zcat /home/akash/recovery/rec.sql.gz | sudo -u postgres psql
dump="pg_restore -U tms -d pgtms -h 127.0.0.1 -Fc $dump" 
structure="pg_restore -U tms -d pgtms -h 127.0.0.1 -Fc $str"
# Execute the dump command
sudo -u postgres $dump > /dev/null 2>&1

# Execute the structure command
sudo -u postgres $structure > /dev/null 2>&1
unset PGPASSFILE

