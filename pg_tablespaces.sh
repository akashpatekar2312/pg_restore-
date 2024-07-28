#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
check=$(cat /etc/postgresql/9.6/main/pg_hba.conf | grep "host   all             all             127.0.0.1/24            trust")
status=$?
if [ ${status} != "0" ]; then 
    echo " Entry not found so making one " 
    sed -i '/host   all             all             127.0.0.1\/32            trust/d' "/etc/postgresql/9.6/main/pg_hba.conf"
    echo "host   pgtms             tms             127.0.0.1/24            trust" >> /etc/postgresql/9.6/main/pg_hba.conf
    echo "host   pgtms             tms             ::1/128            trust" >> /etc/postgresql/9.6/main/pg_hba.conf
    systemctl daemon-reload
    systemctl reload postgresql
fi

table_spaces=("DFAPPL" "UTAPPL" "SEAPPL" "LODEVI" "TRAPPL" "ALAPPL" "IMLANE" "POAPPL" "EDFILE" "LOAPPL" "IMPLAZ" "CCFILE" 
"INDAPP" "IMGLDS" "CCHBLT" "BLTHST" "IMGBTH" "IMGDOC" "IDXBLT" "TBLBLT" "CCHTXN" "CCHIDX" "IDX_BLTHIST" "TBL_BLTHIST")

for tablespace in table_spaces :
sudo -u postgres psql -c "DROP TABLESPACE ${tablespace}"
