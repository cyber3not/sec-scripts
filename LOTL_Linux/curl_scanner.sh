#!/usr/bin/env bash

if [[ "$#" -ne 2 ]]; then
    echo "Usage: $0 <URL> <PORTRANGE>"
    echo "Example: $0 http://192.168.1.1 1-1024"
    exit 1
fi

start=$(echo $2 | cut -d '-' -f 1)
stop=$(echo $2 | cut -d '-' -f 2)

if [[ "$stop" -lt "$start" ]]; then
    echo "Invalid Portrange!"
    exit 1
fi

echo "[+] Scanning ports from $start to $stop on $1 ..."
for port in $(seq $start $stop); do
    #curl
    curl --max-time 5 $1:$port  &>>/dev/null
    ret_code=$?

    #Validate the result using curls exit codes
    case ${ret_code} in 
     0) 
       echo "Port: $port (Code 0=Success)";; 
     7)
       #echo "Port: $port (Code 7=Closed)"
       ;;
     28) 
       echo "Port: $port (Code 28=Timeout)";; 
     *)
       echo "Port: $port (Code $ret_code=Unknown)";;
    esac    
done
