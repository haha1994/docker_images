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
yum -y install kubeadm-1.23.5 kubelet-1.23.5 kubectl-1.23.5
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

# node 加入工作节点
# token is valid in 24 hours, after 24 hours it will unauthorized
# kubeadm join <master-ip>:<master-port> --token <token> --discovery-token-ca-cert-hash sha256:<hash>
