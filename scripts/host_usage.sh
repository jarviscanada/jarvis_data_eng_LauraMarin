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

#server usage stats
vmstat_mb=$(vmstat --unit M)
hostname=$(hostname -f)

#parse memory
memory_free=$(echo "$vmstat_mb" | awk '{print $4}'| tail -n1 | xargs)
cpu_idle=$(echo "$vmstat_mb"  | awk '{print $15}' | tail -n1 | xargs)
cpu_kernel=$(echo "$vmstat_mb" | awk '{print $14}' | tail -n1 | xargs)

#parse disk io and space availability
disk_io=$(vmstat -d | awk '{print $10}' | tail -n1 | xargs)
disk_available=$(df -BM / | awk 'NR==2 {print $4}' | tr -d 'M')

#get current time
timestamp=$(vmstat -t | awk 'END {print $(NF-1), $NF}')

#find matching id
host_id="(SELECT id FROM host_info WHERE hostname='$hostname')";

#construct insert statement
insert_stmt="INSERT INTO host_usage (\"timestamp\", host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available) VALUES ('$timestamp', $host_id, $memory_free, $cpu_idle, $cpu_kernel, $disk_io, $disk_available)"

#connect to postgres and execute insert
export PGPASSWORD=$psql_password
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"
exit $?