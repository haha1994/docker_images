#!/bin/sh
#新服务器配置脚本
#关闭防火墙
systemctl stop firewalld
systemctl disable firewalld

#安装iptables
yum -y install iptables-services && systemctl start iptables && systemctl enable iptables && iptables -F && service iptables save

#关闭 SELINUX
swapoff -a && sed -i 's/.*swap.*/#&/' /etc/fstab
setenforce 0 && sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

#设置时间同步
yum -y install ntpdate
ntpdate pool.ntp.org

#centos7
wget https://raw.githubusercontent.com/haha1994/docker_images/main/k8s/etc_modules-load.d_k8s.conf
cp ./etc_modules-load.d_k8s.conf /etc/modules-load.d/k8s.conf

wget https://raw.githubusercontent.com/haha1994/docker_images/main/k8s/etc_sysctl.d_k8s.conf
cp ./etc_sysctl.d_k8s.conf /etc/sysctl.d/k8s.conf

sudo sysctl --system

wget https://raw.githubusercontent.com/haha1994/docker_images/main/k8s/etc_yum.repos.d_kubernetes.repo
cp ./etc_yum.repos.d_kubernetes.repo /etc/yum.repos.d/kubernetes.repo

#master上执行：
sudo yum -y install kubeadm-1.21.2 kubelet-1.21.2 kubectl-1.21.2
sudo systemctl enable --now kubelet && systemctl start kubelet

#注：如何更换kubeadm版本
#yum list installed | grep kube
#yum remove kubeadm kubectl kubelet -y
#yum -y install kubelet-1.18.0 kubeadm-1.18.0 kubectl-1.18.0（版本随意）

#node上执行：
yum -y install kubelet kubeadm
sudo systemctl enable --now kubelet && systemctl start kubelet

# 安装docker-ce
mkdir /home/docker
cd /home/docker
curl -fsSL get.docker.com -o get-docker.sh
sudo sh get-docker.sh --mirror Aliyun

#创建 /etc/docker 目录
mkdir /etc/docker

#配置 daemon.json
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  }
}
EOF
mkdir -p /etc/systemd/system/docker.service.d

#重启docker服务
systemctl daemon-reload
systemctl restart docker
systemctl enable docker
sudo service docker status

# k8s中，如果用户没有在 KubeletConfiguration 中设置 cgroupDriver 字段， kubeadm init 会将它设置为默认值 systemd

#打印kubeadm初始化配置
kubeadm config print init-defaults > kubeadm-config.yaml
#修改其中信息
advertiseAddress: 192.168.127.10 #master节点的IP
name: 192.168.137.10 #修改为IP地址，如果使用域名，必须保证解析正常
imageRepository: registry.cn-hangzhou.aliyuncs.com/fxhaha
kubernetesVersion: v1.21.2 #Kubernetes软件版本
podSubnet: 10.244.0.0/16 #networking下添加这个内容

#预先下载镜像
kubeadm config images pull --config kubeadm-config.yaml

#初始化节点，如果kubeadm初始化失败了，一定要kubeadm reset
kubeadm init --config=kubeadm-config.yaml | tee kubeadm-init.log

export KUBECONFIG=/etc/kubernetes/admin.conf

# 安装网络插件flannel，官网地址https://github.com/flannel-io/flannel
# 官方Readme中的地址也写错了，没有更新为最新地址（如下）
wget https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f kube-flannel.yml

#将主节点做为工作节点
kubectl taint nodes --all node-role.kubernetes.io/master-

#加入工作节点
kubeadm join --token <token> <master-ip>:<master-port> --discovery-token-ca-cert-hash sha256:<hash>

#安装网络插件
wget https://github.com/flannel-io/flannel/blob/master/Documentation/kube-flannel.yml

kubectl apply -f kube-flannel.yml

#安装ingress-nginx-controller
// TODO
wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/deploy.yaml

# 修改 ingress-nginx-controller 的 Deployment
kind: DaemonSet # modify
spec:
  template:
    spec:
      hostNetwork: true # add 
      dnsPolicy: ClusterFirstWithHostNet # modify

kubectl apply -f ingress-nginx.yaml
kubectl delete -A validatingwebhookconfiguration ingress-nginx-admission

#附录

# 附录一 记录如何使用阿里云镜像构建的功能，拉取外网镜像
// TODO

# 附录二 coredns 拉取失败的问题
# 实际镜像为：k8s.gcr.io/coredns/coredns:v1.8.0
# 换源后会自动缺省目录，所以换源后的镜像地址应该是 aliyun.com/fxhaha/coredns:v1.8.0，相对与原地址少了一层/coredns