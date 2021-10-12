# Noteme
### 报警配置 alert
需安装插件Grafana Image Renderer

```
grafana-cli plugins install grafana-image-renderer
```

截至当前版本8.1.5，如果grafana运行在docker容器中，是无法安装该插件的。官网提供的解决方案为：

1. 运行为独立的远程服务，官方也提供了docker镜像grafana/grafana-image-renderer

2. Build with Grafana Image Renderer plugin pre-installed

> Only available in Grafana v6.5 and later. This is experimental.

The Grafana Image Renderer plugin does not currently work if it is installed in a Grafana Docker image. You can build a custom Docker image by using the GF\_INSTALL\_IMAGE\_RENDERER\_PLUGIN build argument. This installs additional dependencies needed for the Grafana Image Renderer plugin to run.

Example of how to build and run:

```
cd packaging/docker/custom
docker build \
  --build-arg "GRAFANA_VERSION=latest" \
  --build-arg "GF_INSTALL_IMAGE_RENDERER_PLUGIN=true" \
  -t grafana-custom -f Dockerfile .

docker run -d -p 3000:3000 --name=grafana grafana-custom
```





