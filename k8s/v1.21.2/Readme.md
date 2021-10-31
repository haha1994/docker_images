# 新服务器搭建K8S集群过程(CentOS7)

--
##组件选择
以下组件选型仅供参考，暂未在各个类型下进行严谨的调研对比


### 网络

- flannel
- iptable

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
