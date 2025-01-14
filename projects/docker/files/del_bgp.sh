#! /bin/bash

if [ $# -ne 3 ]; then
    echo "Usage: tor.sh IDC IP MAC"
    exit 1
fi

IDC=$1
IP=$2
MAC=$(echo $3 |sed 's/://g')

echo "Update TOR: $IDC $IP $MAC"

CODE=$(curl -w '%{http_code}' -X DELETE \
  'https://wz.net/network/docker_bgp_peer/' \
  -H 'Authorization: Token xxxx' \
  -H 'Content-Type: application/json' \
  -d "{\"idc\":\"$IDC\",\"ip\":\"$IP\",\"mac\":\"0x$MAC\"}" \
  -o /dev/null 2>/dev/null)

echo $CODE

if [ "$CODE" -ne "200" ]; then
    echo "Failed $CODE"
    exit 1
fi

