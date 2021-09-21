# Readme

由于我们要获取到的数据是主机的监控指标数据，而我们的 node-exporter 是运行在容器中的，所以我们在 Pod 中需要配置一些 Pod 的安全策略，这里我们就添加了hostPID: true、hostIPC: true、hostNetwork: true3个策略，用来使用主机的 PID namespace、IPC namespace 以及主机网络，这些 namespace 就是用于容器隔离的关键技术，要注意这里的 namespace 和集群中的 namespace 是两个完全不相同的概念。

另外我们还将主机的/dev、/proc、/sys这些目录挂载到容器中，这些因为我们采集的很多节点数据都是通过这些文件夹下面的文件来获取到的，比如我们在使用top命令可以查看当前cpu使用情况，数据就来源于文件/proc/stat，使用free命令可以查看当前内存使用情况，其数据来源是来自/proc/meminfo文件。