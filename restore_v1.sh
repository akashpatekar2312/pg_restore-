#!/bin/bash
# set -x
export PGPASSFILE="/var/lib/postgresql/.pgpass"
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
check=$(cat /etc/postgresql/9.6/main/pg_hba.conf | grep "host   pgtms             tms             127.0.0.1/24            trust")
status=$?
if [ ${status} != "0" ]; then 
    echo " Entry not found so making one " 
    echo " host   pgtms             tms             127.0.0.1/24            trust" >> /etc/postgresql/9.6/main/pg_hba.conf
    systemctl daemon-reload
    systemctl reload postgresql
fi
msg()
{
    message=$1
    echo
    # Bold and green font
    echo -e "\e[1m\e[92m$message\e[39m\e[0m"
    echo
}
systemctl daemon-reload
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

echo "Which dump you want to restore ?"
echo "1) Daily"
echo "2) Monthly"
echo "3) Both"
read -p "Enter your choice: " choice

zcat /home/akash/recovery/rec.sql.gz | sudo -u postgres psql
if [ ${choice} = 1 ]; then
    read -e -p "Enter the name of the daily dump file followed by the path : " dump
    read -e -p "Enter the name of the daily structure file followed by the path: " str
    ddump="pg_restore -U tms -d pgtms -h 127.0.0.1 -Fc $dump" 
    structure="pg_restore -U tms -d pgtms -h 127.0.0.1 -Fc $str"
    msg "Restoring Daily Backup and This may take a while"
    sudo -u postgres $ddump > /dev/null 2>&1
    msg "Rstoring Structure and This may take a while"
    sudo -u postgres $structure > /dev/null 2>&1
elif
 [ ${choice} = 2 ]; then
    read -e -p "Enter the name of the Monthly dump file followed by the path : " img
    msg "Restoring Monthly Backup and This may take a while"
    mdump="pg_restore -U tms -d pgtms -h 127.0.0.1 -Fc $img"
    sudo -u postgres $mdump > /dev/null 2>&1 
elif
 [ ${choice} = 3 ]; then
    read -e -p "Enter the name of the daily dump file followed by the path : " dump
    read -e -p "Enter the name of the daily structure file followed by the path: " str
    read -e -p "Enter the name of the Monthly dump file followed by the path : " img
    msg "Restoring Daily Backup and This may take a while"
    ddump="pg_restore -U tms -d pgtms -h 127.0.0.1 -Fc $dump" 
    msg "Restoring Monthly Backup and This may take a while"
    mdump="pg_restore -U tms -d pgtms -h 127.0.0.1 -Fc $img"
    msg "Rstoring Structure and This may take a while"
    structure="pg_restore -U tms -d pgtms -h 127.0.0.1 -Fc $str"
    
    sudo -u postgres $ddump > /dev/null 2>&1
    sudo -u postgres $mdump > /dev/null 2>&1
    sudo -u postgres $structure > /dev/null 2>&1
else 
    echo "Invalid choice"
fi
# # Execute the dump command
# sudo -u postgres $dump > /dev/null 2>&1

# # Execute the structure command
# sudo -u postgres $structure > /dev/null 2>&1
unset PGPASSFILE

sed -i '/host   pgtms             tms             127.0.0.1\/24            trust/d' "/etc/postgresql/9.6/main/pg_hba.conf"
