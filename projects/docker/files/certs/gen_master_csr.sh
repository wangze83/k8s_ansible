ip=$(dig +short $1)

# 生成不同集群master证书时，需要替换下方的 IP
# API Server VIP: XXXX
# ETCD LVS VIP: XXXX

echo "{ \
  \"CN\": \"$1\", \
  \"hosts\": [ 
    \"127.0.0.1\", \
    \"$1\", \
    \"xxxx\", \
    \"xxxx\",\
    \"xxxx\",\
    \"$ip\" \
  ], \
  \"key\": { \
    \"algo\": \"ecdsa\", \
    \"size\": 384 \
  }, \
  \"names\": [ \
    { \
      \"C\": \"CN\", \
      \"L\": \"Beijing\", \
      \"O\": \"wz wz Technology Co. Ltd.\", \
      \"OU\":\"platform\" \
    } \
  ] \
}"

