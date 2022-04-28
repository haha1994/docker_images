# 新服务器搭建K8S集群过程(CentOS7)

--
##组件选择
以下组件选型仅供参考，暂未在各个类型下进行严谨的调研对比


### 网络

- flannel:v0.17.0
- iptable
- ingress-controller:v1.1.3

### 监控报警

- node-exporter
- prometheus
- grafana
- actuator

### CICD

- Gerrit
- Jenkins
- SonarQube

### 存储

- 暂无

### Dashboard

- kubernetesui/dashboard:v2.5.1
- kubernetesui/metrics-scraper:v1.0.7
- metrics-server/metrics-server:v0.6.1

--
## 操作步骤
### 关闭防火墙
```
systemctl stop firewalld
systemctl disable firewalld
```
### 安装iptables
```
yum -y install iptables-services && systemctl start iptables && systemctl enable iptables && iptables -F && service iptables save
```
### 关闭 SELINUX
```
swapoff -a && sed -i 's/.*swap.*/#&/' /etc/fstab
setenforce 0 && sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
```
### 设置时间同步
```
yum -y install ntpdate
ntpdate pool.ntp.org
```

## 需要中转的镜像
### K8S
k8s.gcr.io/kube-apiserver:v1.23.5
k8s.gcr.io/kube-controller-manager:v1.23.5
k8s.gcr.io/kube-scheduler:v1.23.5
k8s.gcr.io/kube-proxy:v1.23.5
k8s.gcr.io/pause:3.6
k8s.gcr.io/etcd:3.5.1-0
k8s.gcr.io/coredns/coredns:v1.8.6
### ingress
k8s.gcr.io/ingress-nginx/controller:v1.1.3
k8s.gcr.io/ingress-nginx/kube-webhook-certgen:v1.1.1
### dashboard
k8s.gcr.io/metrics-server/metrics-server:v0.6.1