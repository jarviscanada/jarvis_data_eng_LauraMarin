#!/bin/bash

#assign cli arguments
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

#validate cli arguments
if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

#parse host hardware specs
hostname=$(hostname -f)
lscpu_out=$(lscpu)
cpu_number=$(echo "$lscpu_out" | awk -F: '/^CPU\(s\):/ {print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out" | awk -F: '/^Architecture:/ {print $2}' | xargs)
cpu_model=$(echo "$lscpu_out" | awk -F: '/^Model name:/ {print $2}' | xargs)
cpu_mhz=$(echo "$lscpu_out" | awk -F: '/^CPU MHz:/ {print $2}' | xargs)
l2_cache=$(echo "$lscpu_out" | awk -F: '/^L2 cache:/ {print $2}' | awk '{print $1}' | xargs)
total_mem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
timestamp=$(date -u '+%Y-%m-%d %H:%M:%S')

#construct insert statement
insert_stmt="INSERT INTO host_info (hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, total_mem, \"timestamp\") VALUES ('$hostname', $cpunumber,'$cpu_architecture', '$cpu_model', $cpu_mhz, $l2_cache, $totalmem,'$timestamp')"

#connect to postgres and execute insert
export PGPASSWORD=$psql_password
psql -h "$psqlhost"-p"$psql_port" -d "$dbname"-U"$psql_user" -c "$insert_stmt"
exit $?