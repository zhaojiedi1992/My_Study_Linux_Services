lvs-nat
========================================================

规划图
--------------------------------------------------------

.. image:: /images/cluster/lvs-nat.png


准备工作
--------------------------------------------------------

防火墙和selinux关闭
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    # selinux
    [root@centos-151 ~]# vim /etc/selinux/config 
    SELINUX=disabled
    [root@centos-151 ~]# setenforce 0

    # 防火墙
    [root@centos-151 ~]# systemctl stop firewalld 
    [root@centos-151 ~]# systemctl disable firewalld 

时间同步
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    # 服务端配置
    [root@centos-151 ~]# yum install chrony 
    # 添加如下1行
    server s1b.time.edu.cn       iburst
    # 解注释并修改如下2行
    allow 192.168.46.0/24
    local stratum 10
    [root@centos-151 ~]# systemctl restart chronyd 
    [root@centos-151 ~]# netstat -tunlp |grep ch
    udp        0      0 0.0.0.0:123             0.0.0.0:*                           21886/chronyd       
    udp        0      0 127.0.0.1:323           0.0.0.0:*                           21886/chronyd       
    udp6       0      0 ::1:323                 :::*                                21886/chronyd   

    # 客户端配置
    [root@centos-158 ~]# yum install chrony 
    [root@centos-158 ~]# vim /etc/chrony.conf 
    # 添加行
    server 192.168.46.151 iburst
    # 删除其它server 行

    [root@centos-158 ~]# systemctl restart chronyd 

    # 查看时间 
    [root@centos-158 ~]# chronyc  sources  -V
    210 Number of sources = 1
    MS Name/IP address         Stratum Poll Reach LastRx Last sample               
    ===============================================================================
    ^? 192.168.46.151                0   8     0     -     +0ns[   +0ns] +/-    0ns
    [root@centos-158 ~]# date 
    Mon Mar  5 09:59:02 CST 2018

网关配置
--------------------------------------------------------

需要修改3个web服务器的网关为lvs的地址。

.. code-block:: bash 

    [root@centos-158 ~]# nmcli con modify ens33 ipv4.gateway 192.168.46.151
    [root@centos-158 ~]# nmcli con up ens33 
    [root@centos-159 ~]# nmcli con modify ens33 ipv4.gateway 192.168.46.151
    [root@centos-159 ~]# nmcli con up ens33 
    [root@centos-160 ~]# nmcli con modify ens33 ipv4.gateway 192.168.46.151
    [root@centos-160 ~]# nmcli con up ens33 

启用ip转发功能
--------------------------------------------------------

.. code-block:: bash 

    [root@centos-151 ~]# echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf 
    [root@centos-151 ~]# sysctl -p
    net.ipv4.ip_forward = 1


配置web页面
--------------------------------------------------------

.. code-block:: bash  

    [root@centos-158 ~]# yum install httpd 
    [root@centos-159 ~]# yum install httpd 
    [root@centos-160 ~]# yum install httpd 

    [root@centos-158 ~]# echo linuxpanda-158 > /var/www/html/index.html 
    [root@centos-159 ~]# echo linuxpanda-158 > /var/www/html/index.html 
    [root@centos-160 ~]# echo linuxpanda-158 > /var/www/html/index.html 

    [root@centos-158 ~]# systemctl start httpd 
    [root@centos-159 ~]# systemctl start httpd 
    [root@centos-160 ~]# systemctl start httpd 

    # 测试下
    [root@centos-151 ~]# curl 192.168.46.158
    linuxpanda-158
    [root@centos-151 ~]# curl 192.168.46.159
    linuxpanda-159
    [root@centos-151 ~]# curl 192.168.46.160
    linuxpanda-160

配置lvs
--------------------------------------------------------

.. code-block:: bash 

    [root@centos-151 ~ ]# ipvsadm -A -t 172.18.46.151:80 -s rr 
    [root@centos-151 ~]# ipvsadm -a -t 172.18.46.151:80 -r 192.168.46.158 -m 
    [root@centos-151 ~]# ipvsadm -a -t 172.18.46.151:80 -r 192.168.46.159 -m 
    [root@centos-151 ~]# ipvsadm -a -t 172.18.46.151:80 -r 192.168.46.160 -m 
    [root@centos-151 ~]# ipvsadm -ln 
    IP Virtual Server version 1.2.1 (size=4096)
    Prot LocalAddress:Port Scheduler Flags
    -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
    TCP  172.18.46.151:80 rr
    -> 192.168.46.158:80            Masq    1      0          0         
    -> 192.168.46.159:80            Masq    1      0          0         
    -> 192.168.46.160:80            Masq    1      0          0    

测试
---------------------------------------------------------------

.. code-block:: bash 

    [root@centos-152 ~]# curl 172.18.46.151
    linuxpanda-160
    [root@centos-152 ~]# curl 172.18.46.151
    linuxpanda-159
    [root@centos-152 ~]# curl 172.18.46.151
    linuxpanda-158

保存集群
---------------------------------------------------------------

.. code-block:: bash 

    [root@centos-151 ~]# ipvsadm-save -n  >  /etc/sysconfig/ipvsadm
    [root@centos-151 ~]# cat /etc/sysconfig/ipvsadm
    -A -t 172.18.46.151:80 -s rr
    -a -t 172.18.46.151:80 -r 192.168.46.158:80 -m -w 1
    -a -t 172.18.46.151:80 -r 192.168.46.159:80 -m -w 1
    -a -t 172.18.46.151:80 -r 192.168.46.160:80 -m -w 1

    # 开机启动
    [root@centos-151 ~]# systemctl enable ipvsadm 
    [root@centos-151 ~]# systemctl start ipvsadm 