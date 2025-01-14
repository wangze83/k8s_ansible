
./cfssl gencert -ca=./search/ca.pem -ca-key=./search/ca-key.pem -config=ca-config.json -profile=kube-service-account kube-service-account-csr.json | ./cfssljson -bare kube-service-account
