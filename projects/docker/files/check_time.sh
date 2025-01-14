#!/bin/sh

if ! [ `command -v jq` ];then
    yum install -y jq
fi

taobao_timestamp=$(curl -s 'http://api.m.taobao.com/rest/api3.do?api=mtop.common.getTimestamp' | jq  ".data.t" | awk -F'"' '{if ($2 > 0) {print $2} else {print 0}}')
self_timestamp=$(date +%s%3N)

diff=$(expr $self_timestamp - $taobao_timestamp)

if [ $diff -gt 5000 ];then
  echo "本地时间与标准时间差异过大, 超过 5000 ms"
  echo "差异：$diff ms "
  exit 1
fi

exit 0