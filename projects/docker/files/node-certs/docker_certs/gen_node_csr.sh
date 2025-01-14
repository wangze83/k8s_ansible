ip=$(dig +short $1)

echo "{ \
  \"CN\": \"$1\", \
  \"hosts\": [ 
    \"$1\", \
    \"XXXX\", \
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
      \"OU\":\"Search\" \
    } \
  ] \
}"

