# Readme
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
- SSH Pipeline Steps
需要明文密码，故不采用

- publish over ssh
在configure中配置连接，可行

### 编写Jenkinsfile

- SSH Pipeline Steps配置方法

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

- publish over ssh 配置

//  todo

## 问题
### 问题一 通过ssh远程执行kubectl命令报错
问题原因：使用ssh执行命令和登陆后执行Linux所加载的环境变量不同，在使用ssh执行命令时没有加载/etc/profile的环境变量

解决方法：将/etc/profile 目录下k8s对应的环境变量添加到/root/.bashrc文件内即可，此时再执行时可以正常。

#### 参考资料

[Linux-两种ssh远程执行命令方式加载环境变量区别](https://www.jianshu.com/p/f24c7445c4db)

### 问题二 Git 无法拉取代码
Git 2.33.1 及其之后的版本使用了OpenSSH8.8 (ssh -V 查看版本)

2021年09月26日发布的OpenSSH 8.8中移除了对RSA-SHA1的支持，在其更新日志中有提到这个不兼容更新，大体意思就是1. SHA-1哈希算法默认禁用，2.用户可以自启用SHA-1算法

解决方法：1、配置～/.ssh/config

```
Host *
    HostKeyAlgorithms +ssh-rsa
    PubkeyAcceptedKeyTypes +ssh-rsa
```

2、使用新的加密方式

```
ssh-keygen -t ed25519 -C 'fengshengjie'
```

#### 参考资料

[解决：git升级之后，pull、push远程库权限校验出错--fatal: Could not read from remote repository](https://blog.csdn.net/weixin_41551266/article/details/123253519)

[OpenSSH ReleaseNote](https://www.openssh.com/releasenotes.html)

