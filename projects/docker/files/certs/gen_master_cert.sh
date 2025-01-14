./gen_master_csr.sh $1 > $1-csr.json
cfssl gencert -ca=./search.20201124/ca.pem -ca-key=./search/ca-key.pem -config=ca-config.json -profile=kubernetes \
  $1-csr.json | cfssljson -bare $1
