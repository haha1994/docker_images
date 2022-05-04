# Reademe
## Jenkins 远程部署

### 配置服务器间免密传输

在服务器A上生成密钥对，并将公钥传输到部署服务器

```
ssh-keygen -t rsa
scp /root/.ssh/id_rsa.pub root@target_ip:/root
```
登陆B服务器，将公钥文件写入到服务器B的.ssh目录下的authorized_keys文件中

```
cat /root/id_rsa.pub >> .ssh/authorized_keys
```

### 安装插件
SSH Pipeline Steps

### 编写Jenkinsfile

```
def getHost(){
    def remote = [:]
    remote.name = 'hostname'
    remote.host = 'host'
    remote.user = 'root'
    remote.password = 'admin'
    remote.port = 22
    remote.allowAnyHosts = true
    return remote
}

stage("deploy") {
    agent any
    steps {
        script {
            server = getHost()
        }
        sshCommand remote: server, command: "kubectl apply -f deployment.yaml"
    }
}
```

## 问题
### 问题一 通过ssh远程执行kubectl命令报错
问题原因：使用ssh执行命令和登陆后执行Linux所加载的环境变量不同，在使用ssh执行命令时没有加载/etc/profile的环境变量

解决方法：将/etc/profile 目录下k8s对应的环境变量添加到/root/.bashrc文件内即可，此时再执行时可以正常。

### 参考资料

[Linux-两种ssh远程执行命令方式加载环境变量区别](https://www.jianshu.com/p/f24c7445c4db)





