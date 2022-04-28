# metrics-server
供dashboard使用

原镜像地址：k8s.gcr.io/metrics-server/metrics-server:v0.6.1

## 部署metrics-server
https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.6.1/components.yaml

```
kubectl apply -f download/components.yaml
```
如果出现http就绪探针问题，官网安装说明中有提及需要kubelet证书（在Deployment中增加arg --kubelet-insecure-tls）