.. _topics-dhcp:

DHCP服务搭建
==================================================================

关闭vmware的dhcp功能
-------------------------------------

默认情况下vmware会提供dhcp功能，为了不影响我们后续的自己搭建dhcp功能，建议先关闭vmware的dhcp功能。

关闭vmwaredhcp功能具体步骤: 【菜单栏】->【编辑】->【虚拟网络编辑器】->【更改设置】,如下图：

.. image:: /images/dhcp/虚拟网络编辑器.png

设置虚拟机的网络方式具体步骤： 【虚拟机右键】->【虚拟机设置】->【网络适配器】，如下图： 

.. image:: /images/dhcp/仅主机模式.png

.. note:: 我这个主机是最小化安装的，环境都没有配置，下面有写环境配置相关的， 自行跳过。

配置yum源、禁用selinux和防火墙
-----------------------------------------------------------

查看网络配置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@localhost network-scripts]# cat ifcfg-eth0
    DEVICE=eth0
    TYPE=Ethernet
    ONBOOT=yes
    NM_CONTROLLED=no
    BOOTPROTO=static
    IPADDR=192.168.46.6
    PREFIX=24
    GATEWAY=192.168.46.1

    [root@localhost network-scripts]# cat ifcfg-eth1
    DEVICE=eth1
    TYPE=Ethernet
    ONBOOT=yes
    NM_CONTROLLED=no
    BOOTPROTO=dhcp


yum 配置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@localhost network-scripts]# cd /etc/yum.repos.d/
    [root@localhost yum.repos.d]# ls
    CentOS-Base.repo  CentOS-Debuginfo.repo  CentOS-fasttrack.repo  CentOS-Media.repo  CentOS-Vault.repo
    [root@localhost yum.repos.d]# cd 
    [root@localhost ~]# cd /etc/yum.repos.d/
    [root@localhost yum.repos.d]# ls
    CentOS-Base.repo  CentOS-Debuginfo.repo  CentOS-fasttrack.repo  CentOS-Media.repo  CentOS-Vault.repo
    [root@localhost yum.repos.d]# mkdir bak                   # 创建备份目录
    [root@localhost yum.repos.d]# mv *.repo bak/              # 备份文件
    [root@localhost yum.repos.d]# ls
    bak
    [root@localhost yum.repos.d]# vim cdrom.repo              # 编辑cdrom.repo
    -bash: vim: command not found
    [root@localhost yum.repos.d]# vi cdrom.repo               # 编辑cdrom.repo
    [root@localhost yum.repos.d]# cat cdrom.repo              # 查看cdrom
    [base]
    name=base
    baseurl=file:///mnt/cdrom
    gpgcheck=0
    enable=1
    [root@localhost yum.repos.d]# mkdir /mnt/cdrom            # 创建挂载点
    [root@localhost yum.repos.d]# mount /dev/cdrom  /mnt/cdrom  # 挂载
    mount: block device /dev/sr0 is write-protected, mounting read-only
    [root@localhost yum.repos.d]# yum clean all                 # 清空缓存
    [root@localhost yum.repos.d]# yum makecache                 # 生成yum缓存

selinux和防火墙关闭
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@localhost yum.repos.d]# sed -i 's@SELINUX=enforcing@SELINUX=disabled@' /etc/sysconfig/selinux  
    [root@localhost yum.repos.d]# setenforce 0                                                            
    [root@localhost yum.repos.d]# service iptables stop                                                    
    [root@localhost yum.repos.d]# chkconfig iptables off

vim安装
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@localhost yum.repos.d]# yum install vim -y            # 安装vim 

dhcp的安装
-----------------------------------------------------------------------

.. code-block:: bash

    [root@localhost yum.repos.d]# yum install dhcp -y           # 安装dhcp
    [root@localhost yum.repos.d]# rpm -ql dhcp                  # 查看dhcp服务

dhcp的配置
-------------------------------------------------------------------------------

dhcp的8种报文

.. image:: /images/dhcp/dhcp报文.png

.. code-block:: bash

    [root@localhost dhcp]# cd /etc/dhcp                         # 进入dhcp工作目录
    [root@localhost dhcp]# cp /usr/share/doc/dhcp-4.1.1/dhcpd.conf.sample dhcpd.conf
    [root@localhost dhcp]# vim dhcpd.conf                       # 编辑主配置文件
    [root@localhost dhcp]# cat dhcpd.conf                       # 查看dhcp文件
    # dhcpd.conf
    #
    # Sample configuration file for ISC dhcpd
    #

    # option definitions common to all supported networks...
    option domain-name "linuxpanda.tech";
    option domain-name-servers ns1.linuxpanda.tech, ns2.linuxpanda.tech;

    default-lease-time 86400;
    max-lease-time 864000;

    # 这个地方配置动态ip范围
    subnet 192.168.46.0 netmask 255.255.255.0 {
    range dynamic-bootp 192.168.46.100 192.168.46.200 ;
    option routers 192.168.46.6 ;
    }

    # 这个地方配置静态的ip
    host boss {
    hardware ethernet 08:00:07:26:c0:a5;
    fixed-address 192.168.46.2 ;
    }

    [root@localhost dhcp]# service dhcpd restart
    Shutting down dhcpd:                                       [  OK  ]
    Starting dhcpd:                                            [  OK  ]

.. note:: 如果dhcpd启动失败，可以从/var/log/message文件的后30行获取帮助信息。

dhcp的测试
-------------------------------------------------------------------------------

在另外一个虚拟机里面测试

.. code-block:: bash

    [root@localhost ~]# dhclient -d                                         # 前台执行dhcp命令
    Internet Systems Consortium DHCP Client 4.2.5
    Copyright 2004-2013 Internet Systems Consortium.
    All rights reserved.
    For info, please visit https://www.isc.org/software/dhcp/

    Listening on LPF/ens37/00:0c:29:ad:b0:fc
    Sending on   LPF/ens37/00:0c:29:ad:b0:fc
    Listening on LPF/ens33/00:0c:29:ad:b0:f2
    Sending on   LPF/ens33/00:0c:29:ad:b0:f2
    Sending on   Socket/fallback
    DHCPDISCOVER on ens37 to 255.255.255.255 port 67 interval 7 (xid=0x5b54a061)
    DHCPDISCOVER on ens33 to 255.255.255.255 port 67 interval 8 (xid=0x3d839dcc)
    DHCPDISCOVER on ens37 to 255.255.255.255 port 67 interval 18 (xid=0x5b54a061)
    DHCPREQUEST on ens37 to 255.255.255.255 port 67 (xid=0x5b54a061)
    DHCPOFFER from 172.18.0.1
    DHCPACK from 172.18.0.1 (xid=0x5b54a061)
    bound to 172.18.102.149 -- renewal in 43001 seconds.
    DHCPDISCOVER on ens33 to 255.255.255.255 port 67 interval 15 (xid=0x3d839dcc)
    DHCPREQUEST on ens33 to 255.255.255.255 port 67 (xid=0x3d839dcc)
    DHCPOFFER from 192.168.46.6
    DHCPACK from 192.168.46.6 (xid=0x3d839dcc)
    bound to 192.168.46.100 -- renewal in 40804 seconds.

从上面的测试中，我们可以看出来ens33这个hostonly网卡的ip绑定了192.168.46.100这个ip,是我们dhcp服务器range的第一个ip。


dhcpd的详细参数
-------------------------------------------------------------------------------

关于dhcpd的详细配置，我们可以使用"man dhcpd.conf"命令快速获取帮助，我这里简单介绍下常用参数


dhcp的主要文件
------------------------------------------------------------------------------

.. code-block:: bash

    [root@localhost ~]# rpm -ql dhcp                                # 查看dhcp server的主要文件
    /etc/dhcp                                                       # dhcp主配置目录
    /etc/dhcp/dhcpd.conf                                            # dhcpd的主配置文件
    /etc/rc.d/init.d/dhcpd                                          # dhcpd的init文件
    /usr/share/doc/dhcp-4.1.1/dhcpd.conf.sample                     # dhcp的样例配置文件
    /var/lib/dhcpd/dhcpd.leases                                     # dhcp分配的ip记录信息文件

    [root@localhost ~]# rpm -ql dhclient                            # dhcp客户端的主要文件
    /sbin/dhclient                                                  # dhcp客户端软件
    /var/lib/dhclient                                               # dhcp获取的ip记录信息文件


