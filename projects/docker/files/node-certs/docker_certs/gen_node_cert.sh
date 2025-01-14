./gen_node_csr.sh $1  > $1-csr.json
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubelet \
  $1-csr.json | cfssljson -bare $1
rm $1-csr.json
