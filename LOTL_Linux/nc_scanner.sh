#!/usr/bin/env bash

# Menu
if [[ "$#" -eq 0 ]]; then
    echo -e "Usage: $0 <IP> <PORTRANGE>\n"

    echo "Example IP-Single: $0 192.168.1.1 1-1024"
    echo "Example IP-Range:  $0 192.168.1.1-10 1-1024"
    echo "Example IP-Multi:  $0 192.168.1.1 192.168.1.128 192.168.1.254 1-1024"
    echo "Example Mixed:     $0 192.168.1.1 192.168.1.10-100 192.168.1.254 1-1024"
    exit 1
fi

# Functions
scan_single(){
    echo -e "\n+ ---[ Scan IP:  $1 | Ports:  $2 ]---+"
    nc -z -v $1 $2 2>&1 | grep succeeded | cut -d ' ' -f 4,5,6
}

scan_range(){
    echo -e "\n+ ---[ Scan IP-Range:  $1 Ports: $2 ]---+"

    ip_start=$(echo $1 | cut -d '.' -f 4 | cut -d '-' -f 1)
    ip_stop=$(echo $1 | cut -d '-' -f 2)
    ip_net=$(echo $1 | cut -d '.' -f 1,2,3)

    for ip_suffix in $(seq $ip_start $ip_stop); do
        ip=$ip_net"."$ip_suffix

        echo -e "\n+ ---[ Scan IP:  $1 | Ports:  $2 ]---+"
        nc -z -v $ip $2 2>&1 | grep succeeded | cut -d ' ' -f 4,5,6
    done
}

# Main
start=$(echo ${!#} | cut -d '-' -f 1)
stop=$(echo ${!#} | cut -d '-' -f 2)

if [[ "$stop" -lt "$start" ]]; then
    echo "Invalid Portrange!"
    exit 1
fi

ARGS=("$@")
TARGET_NUM=$[$#-1]
for ((i=0; i<$TARGET_NUM; i++)); do
    TARGET="${ARGS[$i]}"

    if [[ $TARGET =~ "-" ]]; then
      scan_range $TARGET ${!#}
    else
      scan_single $TARGET ${!#}
    fi
done
