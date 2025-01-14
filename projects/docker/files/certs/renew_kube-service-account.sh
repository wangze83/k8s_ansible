# !/bin/bash

# https://www.jianshu.com/p/6d8410443c3c

# 1. 生成新的 CSR
./cfssl gencsr -key search/kube-service-account-key.pem kube-service-account-csr.json | ./cfssljson -bare kube-service-account

# 2. 根据生成的 csr 生成证书
cat kube-service-account.csr | ./cfssl sign --ca-key search/ca-key.pem --ca search/ca.pem --config ca-config.json --profile kubernetes - | ./cfssljson --bare kube-service-account