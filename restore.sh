#!/bin/bash
# set -x
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
check=$(cat /etc/postgresql/9.6/main/pg_hba.conf | grep "host   all             all             127.0.0.1/24            trust")
status=$?
if [ ${status} != "0" ]; then 
    echo " Entry not found so making one " 
    sed -i '/host   all             all             127.0.0.1\/32            trust/d' "/etc/postgresql/9.6/main/pg_hba.conf"
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
export PGPASSFILE="/root/.pgpass:/var/lib/postgresql/.pgpass"
systemctl daemon-reload
echo "Terminating all active sessions..."
sudo -u postgres psql -d pgtms -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='pgtms' AND state='active';"

# Drop the database
echo "Dropping the database..."
sudo -u postgres psql -c "DROP DATABASE IF EXISTS pgtms;"

# Managing permissions of Tablespaces folders :
a=0
tblspc=("DFAPPL" "UTAPPL" "SEAPPL" "LODEVI" "TRAPPL" "ALAPPL" "IMLANE" "POAPPL" "EDFILE" "LOAPPL" "IMPLAZ" "CCFILE" 
"INDAPP" "IMGLDS" "CCHBLT" "BLTHST" "IMGBTH" "IMGDOC" "IDXBLT" "TBLBLT" "CCHTXN" "CCHIDX" "IDX_BLTHIST" "TBL_BLTHIST")
while [ ${a} -le 23 ]
do
    mkdir -p /var/lib/postgresql/datafiles/pgtms/${tblspc[a]} 2> /dev/null
    chmod -R 777 /var/lib/postgresql/datafiles/pgtms/${tblspc[a]} 2> /dev/null
    chown postgres: /var/lib/postgresql/datafiles/pgtms/${tblspc[a]} 2> /dev/null
    ((a++))
done

echo "Which dump you want to restore ?"
echo "1) Daily"
echo "2) Monthly"
echo "3) Both"
read -p "Enter your choice: " choice

zcat /home/rec.sql.gz | sudo -u postgres psql
if [ ${choice} = 1 ]; then
    read -e -p "Enter the name of the daily dump file followed by the path : " dump
    read -e -p "Enter the name of the daily structure file followed by the path: " str
    ddump="pg_restore -U tms -d pgtms -h 127.0.0.1 -Fc -w $dump" 
    structure="pg_restore -U tms -d pgtms -h 127.0.0.1 -Fc -w $str"
    msg "Restoring Daily Backup and This may take a while"
    sudo -u postgres $ddump > /dev/null 2>&1
    msg "Rstoring Structure and This may take a while"
    sudo -u postgres $structure > /dev/null 2>&1
elif
 [ ${choice} = 2 ]; then
    read -e -p "Enter the name of the Monthly dump file followed by the path : " img
    msg "Restoring Monthly Backup and This may take a while"
    mdump="pg_restore -U tms -d pgtms -h 127.0.0.1 -Fc -w $img"
    sudo -u postgres $mdump > /dev/null 2>&1 
elif
 [ ${choice} = 3 ]; then
    read -e -p "Enter the name of the daily dump file followed by the path : " dump
    read -e -p "Enter the name of the daily structure file followed by the path: " str
    read -e -p "Enter the name of the Monthly dump file followed by the path : " img
    msg "Restoring Daily Backup and This may take a while"
    ddump="pg_restore -U tms -d pgtms -h 127.0.0.1 -Fc -w $dump" 
    msg "Restoring Monthly Backup and This may take a while"
    mdump="pg_restore -U tms -d pgtms -h 127.0.0.1 -Fc -w $img"
    msg "Rstoring Structure and This may take a while"
    structure="pg_restore -U tms -d pgtms -h 127.0.0.1 -Fc -w $str"
    
    sudo -u postgres $ddump > /dev/null 2>&1
    sudo -u postgres $structure > /dev/null 2>&1
    sudo -u postgres $mdump > /dev/null 2>&1
    
else 
    echo "Invalid choice"
fi
unset PGPASSFILE
sed -i '/host   pgtms             tms             127.0.0.1\/24            trust/d' "/etc/postgresql/9.6/main/pg_hba.conf"
