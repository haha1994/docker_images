# 新服务器搭建K8S集群过程(Ubuntu)

--
##组件选择
以下组件选型仅供参考，暂未在各个类型下进行严谨的调研对比


### 网络

- flannel:v0.21.4
- iptable
- ingress-controller:v1.6.4

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

- kubernetesui/dashboard:v2.7.0
- kubernetesui/metrics-scraper:v1.0.8
- metrics-server/metrics-server:v0.6.3

--
## 操作步骤
### 关闭防火墙
```
systemctl stop firewalld
systemctl disable firewalld
```
### 安装iptables
```
apt-get update
apt-get -y install iptables
apt-get -y install iptables-persistent 
systemctl start iptables
systemctl enable iptables
iptables -F
service iptables save
```
### 开启IP转发
```
# 需要加载 br_netfilter 模块，br_netfilter 模块用于将桥接流量转发至iptables链
# 确认是否已经加载了 br_netfilter 模块，lsmod ｜ grep br_netfilter
# 默认是没有该模块的，需要你先安装 bridge-utils
apt-get install -y bridge-utils
modprobe br_netfilter

cp ./etc_modules-load.d_k8s.conf /etc/modules-load.d/k8s.conf
cp ./etc_sysctl.d_k8s.conf /etc/sysctl.d/k8s.conf
sysctl --system
sysctl -a | grep bridge
#注意的是重启之后可能需要重新执行modprobe br_netfilter进行加载

#或者修改sysctl.conf
#vim /etc/sysctl.conf
#net.ipv4.ip_forward=1 #取消注释
#sysctl -P
```
### 关闭 SELINUX
```
swapoff -a && sed -i 's/.*swap.*/#&/' /etc/fstab
setenforce 0 && sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
```
### 设置时间同步
```
apt-get -y install ntpdate
ntpdate pool.ntp.org
```
### 卸载docker
```
apt-get remove docker docker-client docker-client-latest docker-common dockerlatest docker-latest-logrotate docker-logrotate docker-engine docker-ce
rm -rf /var/lib/docker
rm -rf /vat/lib/containerd
```
###安装依赖
```
apt-get -y install ca-certificates curl gnupg lsb-release
apt-get -y install apt-transport-https gnupg2 software-properties-common
```
### 增加docker官方GPG key
```
mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```
```
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

chmod a+r /etc/apt/keyrings/docker.gpg
apt-get update
```
### 安装docker-ce
```
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
### OR 安装containerd
```
apt-get -y install containerd.io=1.6.18-1
systemctl enable containerd
systemctl status containerd
```
### 生成并修改配置，修改SystemCgroup = true
```
containerd config default > /etc/containerd/config.toml
#比如dockerhub要加前缀docker.io
systemctl restart containerd
```
### 安装K8S 1.26.3-00
```
apt-get -y install kubelet=1.26.3-00
apt-get -y install kubeadm=1.26.3-00
apt-get -y install kubectl=1.26.3-00
systemctl enable --now kubelet && systemctl start kubelet
```
## 配置master
### 打印kubeadm初始化配置
```
kubeadm config print init-defaults > kubeadm-config.yaml
#修改其中信息
advertiseAddress: 1.2.3.4 #修改为master节点IP 192.168.0.1
name: master #修改为IP地址，如果使用域名，必须保证解析正常
imageRepository: #可以修改为aliyun...
kubernetesVersion: 1.26.3 #Kuberbete软件版本
podSubnet: 10.244.0.0/16 #networking下添加这个内容
```
### 查看需要的镜像
```
kubeadm config images list --config kubeadm-config.yaml
```
### 创建containerd namespace（K8S用k8s.io）然后拉取镜像
```
ctr namespace create k8s.io
```
```
#拉取镜像
# kubeadm config images pull --config kubeadm-config.yaml
```
### 初始化节点，如果kubeadm初始化失败了，一定要kubeadm reset
```
kubeadm init --config=kubeadm-config.yaml | tee kubeadm-init.log
```
### 将k8s配置路径添加到环境变量
```
export KUBECONFIG=/etc/kubernetes/admin.conf
echo 'export KUBECONFIG=/etc/kubernetes/admin.conf'  >> /etc/frofile
source /etc/profile
echo 'source /etc/profile' >> /etc/bashrc
```
### 将主节点作为工作节点
```
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
kubectl label nodes XXX role=master
```
## 安装网络插件flannel v0.21.4
```
ctr -n k8s.io image pull --plain-http=true docker.io/flannel/flannel:v0.21.4
ctr -n k8s.io image pull --plain-http=true docker.io/flannel/flannel-cni-plugin:v1.1.2
# 官网地址 https://github.com/flannel-io/flannel
# wget https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f kube-flannel.yml
# 此时kubectl get node 应该是ready状态
```

## 安装ingress-nginx-controller v1.6.4
```
# 官网 wget https://
# 修改 ingress-nginx-controller  的 deployment
# kind: DaemonSet # modify
# spec:
# template:
#   spec:
#     hostNetwork: true # add
#     dnsPolicy: ClusterFirstWithHostNet # modify
kubectl apply -f ingress-nginx-controller-deploy.yaml
kubectl delete -A validatingwebhookconfiguration ingress-nginx-admission
```
## 安装metrics-server v0.6.3
```
ctr -n k8s.io image pull --plain-http=true registry.k8s.io/metrics-server/metrics-server:v0.6.3

kubectl apply -f metrics-server-components.yaml
```
## 安装dashboard v2.7.0
```
# https://github.com/kubernetes/dashboard/blob/v2.7.0/aio/deploy/recommended.yaml
kubectl apply -f dashborad-recommended.yaml
```
## 创建登录Token（10年有效）
```
# 新版需要手动创建token
kubectl -n kubernetes-dashboard create token kuberbetes-dashboard-admin --duration=99999h
```
## 给master节点添加标签
```
kubectl label nodes jason.com role=master
```

## 需要中转的镜像

### K8S
registry.k8s.io/kube-apiserver:v1.26.3
registry.k8s.io/kube-controller-manager:v1.26.3
registry.k8s.io/kube-scheduler:v1.26.3
registry.k8s.io/kube-proxy:v1.26.3
registry.k8s.io/pause:3.9
registry.k8s.io/etcd:3.5.6-0
registry.k8s.io/coredns/coredns:v1.9.3
### ingress
registry.k8s.io/ingress-nginx/controller:v1.6.4
registry.k8s.io/ingress-nginx/kube-webhook-certgen:v20220916-gd32f8c343
### dashboard
registry.k8s.io/metrics-server/metrics-server:v0.6.3
### 也可以用
registry.cn-hangzhou.aliyuncs.com/google_containers