.. _topics-time:

时间服务器-chrony
====================================================================

服务端配置
--------------------------------------------------------------------

.. code-block:: bash 

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

客户端配置
--------------------------------------------------------------------

.. code-block:: bash 

    [root@centos-158 ~]# yum install chrony 
    [root@centos-158 ~]# vim /etc/chrony.conf 
    # 添加行
    server 192.168.46.151 iburst
    # 删除其它server 行

    [root@centos-158 ~]# systemctl restart chronyd 

客户端测试
--------------------------------------------------------------------

.. code-block:: bash 

    [root@centos-158 ~]# chronyc  sources  -V
    210 Number of sources = 1
    MS Name/IP address         Stratum Poll Reach LastRx Last sample               
    ===============================================================================
    ^? 192.168.46.151                0   8     0     -     +0ns[   +0ns] +/-    0ns
    [root@centos-158 ~]# date 
    Mon Mar  5 09:59:02 CST 2018
