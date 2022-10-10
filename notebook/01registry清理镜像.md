# Readme
### 本地镜像仓库

```
docker image rm $(docker image ls -f dangling=true -q)
```

### 镜像仓库服务
registry自带的API接口删除是软删除，无法清理磁盘空间。
所以使用第三方工具 delete_docker_registry_image
地址：https://github.com/burnettk/delete-docker-registry-image

```
export REGISTRY_DATA_DIR=/opt/docker_data/registry/docker/registry/v2
delete_docker_registry_image --image oa -u
```


