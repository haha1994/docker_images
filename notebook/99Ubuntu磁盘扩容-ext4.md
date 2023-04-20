# Ubuntu磁盘扩容-ext4
## 一、名词解释
### 1.pv 
```
physical volume 即物理卷，就是物理磁盘，可以通过fdisk -l查看操作系统有几块硬盘
```
### 2.lv
```
logical volume 即逻辑卷，就是在vg（指定的物理磁盘组）里面划分出来的
```
### 3.vg
```
volume group 即卷组，就是一组物理磁盘的组合，里面可以有一块也可以有多块硬盘
```

## 二、步骤
### 1.lsblk 查看可用磁盘
```
lsblk
```
### 2.pvcreate /dev/sdb 创建pv
```
pvcreate /dev/sdb
```
### 3.lvdisplay 查看要扩容的lv所在的vg
```
lvdisplay
```
### 4.vgextend 拓展vg
```
vgextend ubuntu-vg /dev/sdb
```
### 5.vgdisplay 查看vg，可以看到有新的Free PE/Size
```
vgdisplay
```
### 6.lvdisplay 查看lvpath
```
lvdisplay
```
### 7.lvextend -l 100%FREE lvpath 拓展lv
```
lvextend -l 100%FREE /dev/ubuntu-vg/ubuntu-lv
```
### 8.resize2fs filesystemname
```
resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv
```
### 9.验证
```
df -h   # 或者lsblk
```


