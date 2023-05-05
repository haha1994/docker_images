# CentOS安装中文字体

## 步骤
### 1.安装字体库
```
yum install fontconfig
```
### 2.安装更新字体命令
```
yum instll mkfontscale
```
### 3.新建目录、上传中文字体
```
mkdir /usr/share/fonts/Chinese
# 切换到中文目录下 将windows中文字体上传
cd /usr/share/fonts/Chinese
# 该目录及其下所有文件需要有执行权限
chmod -R 755 /usr/share/fonts/Chinese
```
### 4.重新建立字体索引、更新缓存
```
mkfontscale
mkfontdir
fc-cache
```
### 5.查看字体是否安装成功
```
fc-list :lang=zh
```



