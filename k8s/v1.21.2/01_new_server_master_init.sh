#!/bin/sh
# 新服务器配置脚本
# 关闭防火墙
systemctl stop firewalld
systemctl disable firewalld

# 安装iptables
yum -y install iptables-services && systemctl start iptables && systemctl enable iptables && iptables -F && service iptables save

# 关闭 SELINUX
swapoff -a && sed -i 's/.*swap.*/#&/' /etc/fstab
setenforce 0 && sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

# 设置时间同步
yum -y install ntpdate
ntpdate pool.ntp.org

# centos7
cd /home/k8s
cp ./etc_modules-load.d_k8s.conf /etc/modules-load.d/k8s.conf
cp ./etc_sysctl.d_k8s.conf /etc/sysctl.d/k8s.conf

sysctl --system

cp ./etc_yum.repos.d_kubernetes.repo /etc/yum.repos.d/kubernetes.repo

# master上执行：
yum -y install kubeadm-1.21.2 kubelet-1.21.2 kubectl-1.21.2
systemctl enable --now kubelet && systemctl start kubelet

#注：如何更换kubeadm版本
#yum list installed | grep kube
#yum remove kubeadm kubectl kubelet -y
#yum -y install kubelet-1.18.0 kubeadm-1.18.0 kubectl-1.18.0（版本随意）

# 安装docker-ce
yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
curl -fsSL get.docker.com -o get-docker.sh
# 确定安装版本20.10
VERSION=20.10 sh get-docker.sh --mirror Aliyun

# 配置 daemon.json
# 修改docker的cgroup属性为systemd，与k8s保持一致
cp ./etc_docker_daemon.json /etc/docker/daemon.json

mkdir -p /etc/systemd/system/docker.service.d

# 重启docker服务
systemctl daemon-reload
systemctl restart docker
systemctl enable docker
#sudo service docker status

# k8s中，如果用户没有在 KubeletConfiguration 中设置 cgroupDriver 字段， kubeadm init 会将它设置为默认值 systemd

# 需要管理员输入本机IP
read -p "Please enter the IP address of this machine:" youripaddress

#打印kubeadm初始化配置
#kubeadm config print init-defaults > kubeadm-config.yaml
##修改其中信息
#advertiseAddress: 192.168.127.10 #master节点的IP
#name: 192.168.137.10 #修改为IP地址，如果使用域名，必须保证解析正常
#imageRepository: registry.cn-hangzhou.aliyuncs.com/fxhaha
#kubernetesVersion: 1.21.2 #Kubernetes软件版本
#podSubnet: 10.244.0.0/16 #networking下添加这个内容

# 替换IP地址
sed -i "s/youripaddress/${youripaddress}/g" kubeadm-config.yaml

# 预先下载镜像
kubeadm config images pull --config kubeadm-config.yaml

# 初始化节点，如果kubeadm初始化失败了，一定要kubeadm reset
kubeadm init --config=kubeadm-config.yaml | tee kubeadm-init.log

# 将k8s配置路径添加到环境变量
export KUBECONFIG=/etc/kubernetes/admin.conf
echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >> /etc/profile

# 将主节点做为工作节点
kubectl taint nodes --all node-role.kubernetes.io/master-

# 安装网络插件flannel v0.14.0，官网地址https://github.com/flannel-io/flannel
# 官方Readme中的地址也写错了，没有更新为最新地址（如下）
# wget https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
# wget https://raw.githubusercontent.com/haha1994/docker_images/main/kube-flannel/v0.14.0/kube-flannel.yml
kubectl apply -f kube-flannel.yml

# 安装ingress-nginx-controller v0.47.0
# 官网 wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/deploy.yaml
# 修改 ingress-nginx-controller 的 Deployment
#kind: DaemonSet # modify
#spec:
#  template:
#    spec:
#      hostNetwork: true # add 
#      dnsPolicy: ClusterFirstWithHostNet # modify
# wget https://raw.githubusercontent.com/haha1994/docker_images/main/nginx-ingress-controller/v0.47.0/ingress-nginx.yaml

kubectl apply -f ingress-nginx.yaml
kubectl delete -A validatingwebhookconfiguration ingress-nginx-admission
