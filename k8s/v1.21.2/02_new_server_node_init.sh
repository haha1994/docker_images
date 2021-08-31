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
mkdir /home/k8s
cd /home/k8s
wget https://raw.githubusercontent.com/haha1994/docker_images/main/k8s/v1.21.2/etc_modules-load.d_k8s.conf
cp ./etc_modules-load.d_k8s.conf /etc/modules-load.d/k8s.conf

wget https://raw.githubusercontent.com/haha1994/docker_images/main/k8s/v1.21.2/etc_sysctl.d_k8s.conf
cp ./etc_sysctl.d_k8s.conf /etc/sysctl.d/k8s.conf

sysctl --system

wget https://raw.githubusercontent.com/haha1994/docker_images/main/k8s/v1.21.2/etc_yum.repos.d_kubernetes.repo
cp ./etc_yum.repos.d_kubernetes.repo /etc/yum.repos.d/kubernetes.repo

# master上执行：
yum -y install kubeadm-1.21.2 kubelet-1.21.2
systemctl enable --now kubelet && systemctl start kubelet

#注：如何更换kubeadm版本
#yum list installed | grep kube
#yum remove kubeadm kubectl kubelet -y
#yum -y install kubelet-1.18.0 kubeadm-1.18.0 kubectl-1.18.0（版本随意）

# 安装docker-ce
mkdir /home/docker
cd /home/docker
yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
curl -fsSL get.docker.com -o get-docker.sh
# 确定安装版本20.10
VERSION=20.10 sh get-docker.sh --mirror Aliyun

# 配置 daemon.json
mkdir /etc/docker

# 修改docker cgroup
wget https://raw.githubusercontent.com/haha1994/docker_images/main/k8s/v1.21.2/etc_docker_daemon.json
cp ./etc_docker_daemon.json /etc/docker/daemon.json

mkdir -p /etc/systemd/system/docker.service.d

# 重启docker服务
systemctl daemon-reload
systemctl restart docker
systemctl enable docker
#sudo service docker status

# k8s中，如果用户没有在 KubeletConfiguration 中设置 cgroupDriver 字段， kubeadm init 会将它设置为默认值 systemd

# 将k8s配置路径添加到环境变量
#export KUBECONFIG=/etc/kubernetes/admin.conf
#echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >> /etc/profile

# node
#加入工作节点
kubeadm join --token <token> <master-ip>:<master-port> --discovery-token-ca-cert-hash sha256:<hash>
#node安装网络插件
# 安装网络插件flannel v0.14.0，官网地址https://github.com/flannel-io/flannel
# 官方Readme中的地址也写错了，没有更新为最新地址（如下）
# wget https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
# kubectl apply -f kube-flannel.yml
# edon
