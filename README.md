# docker_images
docker images transfer

## CentOS 7 配置方法
https://github.com/haha1994/docker_images/blob/main/k8s/v1.21.2/new-server-config-steps.txt


# 附录

# 附录一 记录如何使用阿里云镜像构建的功能，拉取外网镜像
- 登陆阿里云，找到容器镜像服务ACR
- 点击管理控制台
- 进入个人版实例
- 创建命名空间
- 创建镜像仓库，设置仓库代码源，选择Github，注意需要勾选海外机器构建
- 进入该镜像仓库，选择构建，添加构建规则设置
- 添加构建规则完成后，构建该镜像，当看到成功的构建日志时，即可通过镜像仓库的公网地址拉取该镜像

# 附录二 coredns 拉取失败的问题
实际镜像为：k8s.gcr.io/coredns/coredns:v1.8.0
换源后会自动缺省目录，所以换源后的镜像地址应该是 aliyun.com/fxhaha/coredns:v1.8.0，相对与原地址少了一层/coredns