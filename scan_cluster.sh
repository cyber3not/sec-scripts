#!/usr/bin/env bash
# Scans a network, finds active hosts, and groups them by open ports.

ARG2=${2:-"1-90"}

if [[ $# -lt 1 ]]; then
    echo "Usage:   $0 <NETWORK/CIDR> <PORTS>"
    echo "Example: $0 192.168.1.0/24 1-1024"
    exit
fi

# nmap commands - change or customize here the nmap Flags
HOST_SCAN_CMD="nmap -sn -PS"        # Host Discovery
PORT_SCAN_CMD="nmap -p"             # PortScan

# Create scan directory
DIRNAME=$(date +"scan_%d%m%y_%H%M%S")
mkdir -p "$DIRNAME"

#Host Discovery
IP_ALIVE=$($HOST_SCAN_CMD "$1" | grep -i 'scan report' | awk '{print $NF}')

echo "+------| Hosts alive |------+"
echo "$IP_ALIVE" | tee "$DIRNAME/hosts.txt"

#PortScan
for host in $IP_ALIVE;do
    echo "+------| Scan $host |------+"
    result=$($PORT_SCAN_CMD "$ARG2"  "$host"  | grep -i open | cut -d '/' -f 1)
    echo $result | sed 's/ /\n/g'

    for port in $result; do
        touch $DIRNAME/$port-hosts.txt
        echo $host >> $DIRNAME/$port-hosts.txt
    done
done
