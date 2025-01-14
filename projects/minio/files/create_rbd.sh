#!/bin/bash

USAGE="Usage: `basename $0` [-n nodes number] [-i images number] [-c IDC name] [-s image size]"

while getopts 'n:i:c:s:' OPT; do
    case $OPT in
        n) NODES="$OPTARG";;
        i) IMGS="$OPTARG";;
        c) IDC="$OPTARG";;
        s) SIZE="$OPTARG";;
        ?) echo $USAGE;exit 0;;
    esac
done

if test $OPTIND -lt 9
then
    echo "Args not enough, got $OPTIND args, need 9."
    echo $USAGE
    exit 0
fi

echo "Will create: ${IMGS}x${NODES} rbd images at: ${IDC}, size: ${SIZE}"

# echo "OPTIND: $OPTIND"
# shift $(($OPTIND - 1))

for((n=1;n<=$NODES;n++));
do
    for((i=1;i<=$IMGS;i++));
    do
        sudo rbd --id search --pool k8s_pool create --image minio_${IDC}_node${n}_${SIZE}-${i} --size ${SIZE}
    done
done
