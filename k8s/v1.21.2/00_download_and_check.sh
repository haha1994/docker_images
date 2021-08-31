#!/bin/sh

baseUrl=https://raw.githubusercontent.com/haha1994/docker_images/main/

checkCount=0

if [ ! -d '/etc/docker' ];then
	mkdir '/etc/docker'
fi

if [ ! -d '/home/docker' ];then
	mkdir '/home/docker'
fi

if [ ! -d '/home/k8s' ];then
	mkdir '/home/k8s'
fi

cd /home/k8s

# check and download

if [ ! -f 'etc_modules-load.d_k8s.conf' ];then
    wget "${baseUrl}k8s/v1.21.2/etc_modules-load.d_k8s.conf"
fi

if [ ! -f 'etc_sysctl.d_k8s.conf' ];then
    wget "${baseUrl}k8s/v1.21.2/etc_sysctl.d_k8s.conf"
fi

if [ ! -f 'etc_yum.repos.d_kubernetes.repo' ];then
    wget "${baseUrl}k8s/v1.21.2/etc_yum.repos.d_kubernetes.repo"
fi

if [ ! -f 'etc_docker_daemon.json' ];then
    wget "${baseUrl}k8s/v1.21.2/etc_docker_daemon.json"
fi

if [ ! -f 'kubeadm-config.yaml' ];then
    wget "${baseUrl}k8s/v1.21.2/kubeadm-config.yaml"
fi

if [ ! -f 'kube-flannel.yml' ];then
    wget "${baseUrl}kube-flannel/v0.14.0/kube-flannel.yml"
fi

if [ ! -f 'ingress-nginx.yaml' ];then
    wget "${baseUrl}nginx-ingress-controller/v0.47.0/ingress-nginx.yaml"
fi

if [ ! -f '01_new_server_master_init.sh' ];then
    wget "${baseUrl}k8s/v1.21.2/01_new_server_master_init.sh"
fi

if [ ! -f '02_new_server_node_init.sh' ];then
    wget "${baseUrl}k8s/v1.21.2/02_new_server_node_init.sh"
fi

# check

if [ ! -f 'etc_modules-load.d_k8s.conf' ];then
    echo 'etc_modules-load.d_k8s.conf NOT FOUND!'
    exit 1
fi

if [ ! -f 'etc_sysctl.d_k8s.conf' ];then
    echo 'etc_sysctl.d_k8s.conf NOT FOUND!'
    exit 1
fi

if [ ! -f 'etc_yum.repos.d_kubernetes.repo' ];then
    echo 'etc_yum.repos.d_kubernetes.repo NOT FOUND!'
    exit 1
fi

if [ ! -f 'etc_docker_daemon.json' ];then
    echo 'etc_docker_daemon.json NOT FOUND!'
    exit 1
fi

if [ ! -f 'kubeadm-config.yaml' ];then
    echo 'kubeadm-config.yaml NOT FOUND!'
    exit 1
fi

if [ ! -f 'kube-flannel.yml' ];then
    echo 'kube-flannel.yml NOT FOUND!'
    exit 1
fi

if [ ! -f 'ingress-nginx.yaml' ];then
    echo 'ingress-nginx.yaml NOT FOUND!'
    exit 1
fi

if [ ! -f '01_new_server_master_init.sh' ];then
    echo '01_new_server_master_init.sh NOT FOUND!'
    exit 1
fi

if [ ! -f '01_new_server_node_init.sh' ];then
    echo '01_new_server_node_init.sh NOT FOUND!'
    exit 1
fi

echo 'Download and check finished successfully!'
exit 0
