# Rocket.chat Readme

### 安装说明

mongo 初始化

```
mongo
rs.initiate()

var config = rs.conf()
config.members[0].host=
rs.reconfig(config)
```