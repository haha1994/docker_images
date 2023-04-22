# dashboard部署方式
[K8S 安装 Dashboard](https://blog.csdn.net/mshxuyi/article/details/108425487)

本文案例K8S版本v1.26.3，dashboard版本v2.7.0，metrics-server版本v0.6.3

[dashboard 官方](https://github.com/kubernetes/dashboard)
[metrics-server 官方](https://github.com/kubernetes-sigs/metrics-server)

## 部署metrics-server
https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.6.3/components.yaml

```
kubectl apply -f download/components.yaml
```
如果出现http就绪探针问题，官网安装说明中有提及需要kubelet证书（在Deployment中增加arg --kubelet-insecure-tls）

## 下载dashboard部署文件
https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

## 修改service
```
kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  type: NodePort
  ports:
    - port: 443
      targetPort: 8443
      nodePort: 30001
  selector:
    k8s-app: kubernetes-dashboard
```

## 创建管理员角色
```
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard-admin
  namespace: kubernetes-dashboard
  
---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-dashboard-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: kubernetes-dashboard-admin
    namespace: kubernetes-dashboard
```

## 部署后创建登陆token（10年有效）
```
kubectl -n kubernetes-dashboard create token kuberbetes-dashboard-admin --duration=99999h
```


