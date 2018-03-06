lvs-dr
========================================================

规划图
--------------------------------------------------------

.. image:: /images/cluster/lvs-dr.png


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

    [root@centos-158 ~]# nmcli con modify ens33 ipv4.gateway 192.168.46.153
    [root@centos-158 ~]# nmcli con up ens33 
    [root@centos-159 ~]# nmcli con modify ens33 ipv4.gateway 192.168.46.153
    [root@centos-159 ~]# nmcli con up ens33 
    [root@centos-160 ~]# nmcli con modify ens33 ipv4.gateway 192.168.46.153
    [root@centos-160 ~]# nmcli con up ens33 

启用ip转发功能
--------------------------------------------------------

.. code-block:: bash 

    [root@centos-153 ~]# echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf 
    [root@centos-153 ~]# sysctl -p
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



调度器脚本： 

.. literalinclude:: /files/lvs_dr_vs.sh
   :encoding: utf-8
   :language: bash

rs脚本： 

.. literalinclude:: /files/lvs_dr_rs.sh
   :encoding: utf-8
   :language: bash

在调度器上执行

.. code-block:: bash 

    [root@centos-151 ~]# bash lvs_dr_vs.sh stop && bash lvs_dr_vs.sh start

在三个rs上执行

.. code-block:: bash 

    [root@centos-158 ~]# bash lvs_dr_rs.sh stop && bash lvs_dr_rs.sh start
    [root@centos-159 ~]# bash lvs_dr_rs.sh stop && bash lvs_dr_rs.sh start
    [root@centos-160 ~]# bash lvs_dr_rs.sh stop && bash lvs_dr_rs.sh start

测试
---------------------------------------------------------------

.. code-block:: bash 

    [root@centos-152 ~]# curl 10.0.46.151
    linuxpanda-160
    [root@centos-152 ~]# curl 10.0.46.151
    linuxpanda-159
    [root@centos-152 ~]# curl 10.0.46.151
    linuxpanda-158

保存集群
---------------------------------------------------------------

.. code-block:: bash 

    [root@centos-151 ~]# ipvsadm-save -n  >  /etc/sysconfig/ipvsadm
    [root@centos-151 ~]# cat /etc/sysconfig/ipvsadm
    -A -t 10.0.46.151:80 -s wrr
    -a -t 10.0.46.151:80 -r 192.168.46.158:80 -g -w 1
    -a -t 10.0.46.151:80 -r 192.168.46.159:80 -g -w 1
    -a -t 10.0.46.151:80 -r 192.168.46.160:80 -g -w 1

    # 开机启动
    [root@centos-151 ~]# systemctl enable ipvsadm 
    [root@centos-151 ~]# systemctl start ipvsadm 


整合http和https
---------------------------------------------------

.. code-block:: bash 

    # 在3个集群上安装ssl, 提供https
    [root@centos-158 ~]# yum install mod_ssl
    [root@centos-158 ~]# systemctl restart httpd 
    [root@centos-159 ~]# yum install mod_ssl
    [root@centos-159 ~]# systemctl restart httpd 
    [root@centos-160 ~]# yum install mod_ssl
    [root@centos-160 ~]# systemctl restart httpd 
    [root@centos-151 ~]# iptables -t mangle -A PREROUTING -d 10.0.46.151 -p tcp -m multiport --dports 80,443 -j MARK --set-mark 80

    # 查看原有的配置，并修改
    [root@centos-151 ~]# ipvsadm-save  -n 
    -A -t 10.0.46.151:80 -s wrr
    -a -t 10.0.46.151:80 -r 192.168.46.158:80 -g -w 1
    -a -t 10.0.46.151:80 -r 192.168.46.159:80 -g -w 1
    -a -t 10.0.46.151:80 -r 192.168.46.160:80 -g -w 1
    [root@centos-151 ~]# ipvsadm -C
    [root@centos-151 ~]# ipvsadm -A -f 80 -s wrr 
    [root@centos-151 ~]# ipvsadm -a -f 80 -r 192.168.46.158 -g -w 1
    [root@centos-151 ~]# ipvsadm -a -f 80 -r 192.168.46.159 -g -w 1
    [root@centos-151 ~]# ipvsadm -a -f 80 -r 192.168.46.160 -g -w 1

    # 测试， 看看是不是遍历的。
    [root@centos-152 ~]# for i in {1..10} ; do curl http://10.0.46.151/index.html; curl -k http://10.0.46.151/index.html;done 
    linuxpanda-160
    linuxpanda-159
    linuxpanda-158
    linuxpanda-160
    linuxpanda-159
    linuxpanda-158
    linuxpanda-160
    linuxpanda-159
    linuxpanda-158
    linuxpanda-160
    linuxpanda-159
    linuxpanda-158
    linuxpanda-160
    linuxpanda-159
    linuxpanda-158
    linuxpanda-160
    linuxpanda-159
    linuxpanda-158
    linuxpanda-160
    linuxpanda-159
