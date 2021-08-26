# docker_images
docker images transfer

## CentOS 7 配置方法
https://github.com/haha1994/docker_images/blob/main/k8s/v1.21.2/new-server-config-steps.txt


# 附录

# 附录一 记录如何使用阿里云镜像构建的功能，拉取外网镜像
# TODO

# 附录二 coredns 拉取失败的问题
# 实际镜像为：k8s.gcr.io/coredns/coredns:v1.8.0
# 换源后会自动缺省目录，所以换源后的镜像地址应该是 aliyun.com/fxhaha/coredns:v1.8.0，相对与原地址少了一层/coredns