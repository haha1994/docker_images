# 集群证书更新

出于安全性的考虑，使用kubeadm搭建的Kubernetes集群，默认生成的ca证书的有效期是10年，其他证书有效期均为1年

--
## 证书
默认位置： /etc/kubernetes/pki/

```
apiserver.crt
apiserver-etcd-client.crt
apiserver-kubelet-client.crt
ca.crt
front-proxy-ca.crt
/etcd/ca.crt
/etcd/healthcheck-client.crt
/etcd/peer.crt
/etcd/server.crt
```

## 过期解决办法

1. 定期手动更新证书
2. 定期升级集群，升级时证书也会被更新
3. 修改kubeadm代码，把生成的证书的有效期设置为10年，重新编译后替换原kubeadm

Kubernetes官方建议：kubeadm方式搭建的集群，采用方法1 。

## 更新步骤

### 检查是否过期

```
kubectl certs check-expiration
```

### 更新证书

```
kubectl certs renew all # 更新所有证书
kubectl certs renew apiserver # 仅更新apiserver证书
```

### 再次检查

```
kubectl certs check-expiration
```

### 更新kubectl配置

设置了kubernetes config 环境变量的可跳过此步骤

```
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
```

### 推荐重启kubelet和docker




