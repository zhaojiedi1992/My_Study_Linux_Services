nis
=========================================================================

nis简介
--------------------------------------------------------------------------
nis(Network Infomation Services,网络信息服务)主要用来管理账号问题。

nis主从工作原理

#. nis主服务器先将本身的账号密码相关文件制作成数据库文件
#. nis主服务器可以告知nis从服务器进行更新
#. nis主动前往nis主服务器去的更新后的数据库文件
#. 如果出现账号heels密码变动，需要重新制作数据库文件并同步

nis客户端工作原理

#. 如果有登陆需求时候，会先查询本机器的/etc/passwd,/etc/shadow等文件
#. 若在本机找不到数据，才开始向整个nis网络的主机广播查询
#. 每个nis服务器，不管主从，都可以响应，基本上是先响应者优先

.. note:: 从客户端工作原理上可以看出来，先找本机的，我们想集中认证，应该把普通用户从系统拿掉，
            只保留系统的用户。

nis安装
-----------------------------------------------------------------------

.. code-block:: bash

    [root@localhost ~]# yum install yp-tools ypbind ypserv rpcbind


nis案例
----------------------------------------------------------------------------

.. code-block:: text 

    nis的域名为linuxpanda
    整个网络的信任网络为192.168.46.0/24
    nis主服务器的ip为192.168.46.129，主机名为nis.linuxpanda.tech
    nis客户端的ip为192.168.46.159，主机名为centos-159.linuxpanda.tech

设置nis域
---------------------------------------------------------------

.. code-block:: bash

    [root@localhost ~]# vim /etc/sysconfig/network
    # 添加如下2行，用于设置nis域和固定端口
    NISDOMAIN=linuxpanda
    YPSERV_ARGS="-p 1011"

主要配置文件/etc/ypserv.conf
---------------------------------------------------------------

.. code-block:: bash

    [root@localhost ~]# vim /etc/ypserv.conf 
    # 添加行
    dns: no
    192.168.46.0/255.255.255.0    : * : * : none
    * : * : * : deny


设置主机名与ip的对应
---------------------------------------------------------------

.. code-block:: bash

    [root@localhost ~]# vim /etc/hosts
    # 添加如下2行，一台主机和一个客户端的
    192.168.46.129 nis.linuxpanda.tech centos-129.linuxpanda.tech
    192.168.46.159 centos-159.linuxpanda.tech
    # 查看当前的主机名
    [root@localhost ~]# hostname
    localhost.localdomain
    # 修改当前主机名
    [root@localhost ~]# hostnamectl set-hostname nis.linuxpanda.tech
    [root@localhost ~]# hostname
    nis.linuxpanda.tech

启动域查看相关的服务
---------------------------------------------------------------

.. code-block:: bash

    [root@localhost ~]# vim /etc/sysconfig/yppasswdd 
    # 修改内容如下
    YPPASSWDD_ARGS="--port 1012"
    [root@localhost ~]# systemctl start rpcbind ypserv yppasswdd
    [root@localhost ~]# netstat -tunlp |egrep "(yp)|(rpc)"
    tcp        0      0 0.0.0.0:1011            0.0.0.0:*               LISTEN      41283/ypserv        
    udp        0      0 0.0.0.0:1011            0.0.0.0:*                           41283/ypserv        
    udp        0      0 0.0.0.0:1012            0.0.0.0:*                           41286/rpc.yppasswdd 
    udp        0      0 0.0.0.0:111             0.0.0.0:*                           41281/rpcbind       
    udp        0      0 0.0.0.0:752             0.0.0.0:*                           41281/rpcbind       
    udp6       0      0 :::111                  :::*                                41281/rpcbind       
    udp6       0      0 :::752                  :::*                                41281/rpcbind 

    [root@localhost ~]# rpcinfo -p localhost
    program vers proto   port  service
        100000    4   tcp    111  portmapper
        100000    3   tcp    111  portmapper
        100000    2   tcp    111  portmapper
        100000    4   udp    111  portmapper
        100000    3   udp    111  portmapper
        100000    2   udp    111  portmapper
        100004    2   udp   1011  ypserv
        100004    1   udp   1011  ypserv
        100004    2   tcp   1011  ypserv
        100004    1   tcp   1011  ypserv
        100009    1   udp   1012  yppasswdd

创建账号
----------------------------------------------------

.. code-block:: bash

    [root@localhost ~]# useradd -u 1001 nis1
    [root@localhost ~]# useradd -u 1002 nis2
    [root@localhost ~]# useradd -u 1003 nis3
    [root@localhost ~]# echo 'oracle' | passwd --stdin nis1
    Changing password for user nis1.
    passwd: all authentication tokens updated successfully.
    [root@localhost ~]# echo 'oracle' | passwd --stdin nis2
    Changing password for user nis2.
    passwd: all authentication tokens updated successfully.
    [root@localhost ~]# echo 'oracle' | passwd --stdin nis3
    Changing password for user nis3.
    passwd: all authentication tokens updated successfully.

初始化
-----------------------------------------------------------

.. code-block:: bash

    [root@localhost ~]# /usr/lib64/yp/ypinit -m

    At this point, we have to construct a list of the hosts which will run NIS
    servers.  nis.linuxpanda.tech is in the list of NIS server hosts.  Please continue to add
    the names for the other hosts, one per line.  When you are done with the
    list, type a <control D>.
        next host to add:  nis.linuxpanda.tech
        next host to add:  
    The current list of NIS servers looks like this:

    nis.linuxpanda.tech

    Is this correct?  [y/n: y]  y
    We need a few minutes to build the databases...
    Building /var/yp/linuxpanda/ypservers...
    Running /var/yp/Makefile...
    gmake[1]: Entering directory '/var/yp/linuxpanda'
    Updating passwd.byname...
    Updating passwd.byuid...
    Updating group.byname...
    Updating group.bygid...
    Updating hosts.byname...
    Updating hosts.byaddr...
    Updating rpc.byname...
    Updating rpc.bynumber...
    Updating services.byname...
    Updating services.byservicename...
    Updating netid.byname...
    Updating protocols.bynumber...
    Updating protocols.byname...
    Updating mail.aliases...
    gmake[1]: Leaving directory '/var/yp/linuxpanda'

    nis.linuxpanda.tech has been set up as a NIS master server.

    Now you can run ypinit -s nis.linuxpanda.tech on all slave server.

客户端设置
-----------------------------------------------------------

.. code-block:: bash

    # 安装软件包
    [root@centos-159 yum.repos.d]# yum install ypbind yp-tools
    root@centos-159 yum.repos.d]# vim /etc/sysconfig/network
    # 添加1行
    NISDOMAIN=linuxpanda

    # 设置当前域
    /bin/nisdomainname linuxpanda
    # 开机自己加入域
    [root@centos-159 yum.repos.d]# echo /bin/nisdomainname linuxpanda >> /etc/rc.d/rc.local 

    [root@centos-159 yum.repos.d]# vim /etc/yp.conf
    # 添加1行
    domain linuxpanda server 192.168.46.129

    [root@centos-159 yum.repos.d]# vim /etc/nsswitch.conf
    # 修改如下内容
    passwd:     files nis
    shadow:     files nis
    group:      files nis
    hosts:      files nis dns

    # 修改认证
    [root@centos-159 yum.repos.d]# vim /etc/sysconfig/authconfig 
    USENIS=yes
    [root@centos-159 yum.repos.d]# vim /etc/pam.d/system-auth
    # 修改如下行，加入nis
    password    sufficient    pam_unix.so sha512 shadow nis  nullok try_first_pass use_authtok

    # 重启服务
    [root@centos-159 yum.repos.d]# systemctl start rpcbind ypbind

    # 删除本机自己的用户（保留系统的）
    [root@centos-159 yum.repos.d]# usedel zhao 

    # 验证下

    [root@centos-159 yum.repos.d]# yptest 
    Test 1: domainname
    Configured domainname is "linuxpanda"

    Test 2: ypbind
    Used NIS server: nis.linuxpanda.tech

    Test 3: yp_match
    WARNING: No such key in map (Map passwd.byname, key nobody)

    Test 4: yp_first
    nis1 nis1:$6$fVdp4tPK$lVNDuhX./Um7.z2H/UG00kQ0sktrdss6P1pJlZXZ2tR0mdi5QeY3n.M9fDFNjnKllCgxZ0uYQxiWkakumk78W0:1001:1001::/home/nis1:/bin/bash

    Test 5: yp_next
    nis2 nis2:$6$fN8RZT55$9LTScM4G2nTU0irMs2XXo16uFBfxhfoO5IebGEBkbwI129NiiukcQL15THvmHFLp6OmoDcKVLfJU/cZsXFmwI0:1002:1002::/home/nis2:/bin/bash
    nis3 nis3:$6$cWGqh2Ky$7cpiWGtEIOe3/fVCSfIIiu9dNVlw.SbS47IveIAsCSCrsG7g91S9a0EC1cqi8eAZWOxC13ZZ.MF3uWLdrEjQr.:1003:1003::/home/nis3:/bin/bash
    zhao zhao:$6$4FY9k21GGia3q98C$p8NRwX2/9w/MEqi03ASVe9aoyehDLRsnqV6QrkM3o38nLQW5Ox7cRvFWg8weQYoyPz85ro8D000tnVgGz225q0:1000:1000:zhao:/home/zhao:/bin/bash

    Test 6: yp_master
    nis.linuxpanda.tech

    Test 7: yp_order
    1518834773

    Test 8: yp_maplist
    mail.aliases
    protocols.byname
    protocols.bynumber
    netid.byname
    services.byservicename
    services.byname
    rpc.bynumber
    rpc.byname
    hosts.byaddr
    hosts.byname
    group.bygid
    group.byname
    passwd.byuid
    passwd.byname
    ypservers

    Test 9: yp_all
    nis1 nis1:$6$fVdp4tPK$lVNDuhX./Um7.z2H/UG00kQ0sktrdss6P1pJlZXZ2tR0mdi5QeY3n.M9fDFNjnKllCgxZ0uYQxiWkakumk78W0:1001:1001::/home/nis1:/bin/bash
    nis2 nis2:$6$fN8RZT55$9LTScM4G2nTU0irMs2XXo16uFBfxhfoO5IebGEBkbwI129NiiukcQL15THvmHFLp6OmoDcKVLfJU/cZsXFmwI0:1002:1002::/home/nis2:/bin/bash
    nis3 nis3:$6$cWGqh2Ky$7cpiWGtEIOe3/fVCSfIIiu9dNVlw.SbS47IveIAsCSCrsG7g91S9a0EC1cqi8eAZWOxC13ZZ.MF3uWLdrEjQr.:1003:1003::/home/nis3:/bin/bash
    zhao zhao:$6$4FY9k21GGia3q98C$p8NRwX2/9w/MEqi03ASVe9aoyehDLRsnqV6QrkM3o38nLQW5Ox7cRvFWg8weQYoyPz85ro8D000tnVgGz225q0:1000:1000:zhao:/home/zhao:/bin/bash
    1 tests failed

    # ypwhich检查数据库容量
    [root@centos-159 yum.repos.d]# ypwhich -x
    Use "ethers"	for map "ethers.byname"
    Use "aliases"	for map "mail.aliases"
    Use "services"	for map "services.byname"
    Use "protocols"	for map "protocols.bynumber"
    Use "hosts"	for map "hosts.byname"
    Use "networks"	for map "networks.byaddr"
    Use "group"	for map "group.byname"
    Use "passwd"	for map "passwd.byname"

    # 使用ypcat读取数据库内容
    [root@centos-159 yum.repos.d]# ypcat passwd.byname
    nis1:$6$fVdp4tPK$lVNDuhX./Um7.z2H/UG00kQ0sktrdss6P1pJlZXZ2tR0mdi5QeY3n.M9fDFNjnKllCgxZ0uYQxiWkakumk78W0:1001:1001::/home/nis1:/bin/bash
    nis2:$6$fN8RZT55$9LTScM4G2nTU0irMs2XXo16uFBfxhfoO5IebGEBkbwI129NiiukcQL15THvmHFLp6OmoDcKVLfJU/cZsXFmwI0:1002:1002::/home/nis2:/bin/bash
    nis3:$6$cWGqh2Ky$7cpiWGtEIOe3/fVCSfIIiu9dNVlw.SbS47IveIAsCSCrsG7g91S9a0EC1cqi8eAZWOxC13ZZ.MF3uWLdrEjQr.:1003:1003::/home/nis3:/bin/bash
    zhao:$6$4FY9k21GGia3q98C$p8NRwX2/9w/MEqi03ASVe9aoyehDLRsnqV6QrkM3o38nLQW5Ox7cRvFWg8weQYoyPz85ro8D000tnVgGz225q0:1000:1000:zhao:/home/zhao:/bin/bash

    # 验证登陆

    [root@centos-159 yum.repos.d]# su - nis1
    su: warning: cannot change directory to /home/nis1: No such file or directory
    -bash-4.2$ ls
    bak  cdrom.repo
    -bash-4.2$ pwd
    /etc/yum.repos.d
    # 这个提示没有家目录， 我们可以考虑在nis上面提供nfs功能或者samba功能。



参考
---------------------------------------------------

nis-howto_

.. _nis-howto: http://www.linux-nis.org/nis-howto/HOWTO/

鸟哥的私房菜书籍，没法给超链接了。