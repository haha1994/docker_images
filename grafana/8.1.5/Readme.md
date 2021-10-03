# Readme
### 官网地址
```
https://grafana.com
https://github.com/grafana/grafana
https://grafana.com/docs/grafana/latest/administration/configuration/
```
### port
```
3000
```

### 配置文件
```
/usr/share/grafana/conf/defaults.ini
```
### 说明
先创建/opt/docker_data/grafana，并修改权限为775

如果要启用grafana的alert，就需要安装插件grafana-image-renderer。而在目前是无法直接在容器中安装这个插件的。所以，官方提供了一种解决方案，就是自己构建grafana-custom镜像。
构建方法如下：

```
下载源码
cd packaging/docker/custom
docker build --build-arg "GRAFANA_VERSION=8.1.5" --build-arg "GF_INSTALL_IMAGE_RENDERER_PLUGIN=true" -t grafana-custom:8.1.5 -f Dockerfile .
```
### 模版

模板号 |  监控对象              | URL地址
----- | -------------- | --- 
3119 | k8s cadvisor(POD-cpu, memory, network,IO)  | host:10255/metrics/cadvisor
6417 | k8s 资源对象      | kube-state-metrics
9276 | 主机 性能参数（CPU、内存、硬盘、网络） | node-exporter host:9100/metrics
4701 | JVM           | -

