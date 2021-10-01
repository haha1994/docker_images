# Readme
https://grafana.com/
https://github.com/grafana/grafana
port: 3000

先创建/opt/docker_data/grafana，并修改权限为775

如果要启用grafana的alert，就需要安装插件grafana-image-renderer。而在目前是无法直接在容器中安装这个插件的。所以，官方提供了一种解决方案，就是自己构建grafana-custom镜像。构建方法如下：

下载源码 
cd packaging/docker/custom
docker build --build-arg "GRAFANA_VERSION=latest" --build-arg "GF_INSTALL_IMAGE_RENDERER_PLUGIN=true" -t grafana-custom:8.1.5 -f Dockerfile .
