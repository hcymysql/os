# os
centos6/7 系统初始化脚本

定制安装软件包，关闭服务，文件描述符，硬盘优化，系统内核优化，开机启动，时间校对

-------------------------------------------
最近CentOS 6已经停止更新支持，同时官方也把yum源删除了，目前CentOS 6系统使用yum命令安装软件包基本都是失败，因此需要更换yum源。

操作方法：

在ssh界面执行以下命令即可一键更换yum源为CentOS的Vault源（包括CentOS官方和阿里云的源）：

wget -O /etc/yum.repos.d/CentOS-Base.repo http://files.tttidc.com/centos6/Centos-6.repo
wget -O /etc/yum.repos.d/epel.repo http://files.tttidc.com/centos6/epel-6.repo
yum makecache
