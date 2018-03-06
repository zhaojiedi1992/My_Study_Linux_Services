时间服务器-ntp
====================================================================

时间服务器搭建_

.. _时间服务器搭建: http://www.cnblogs.com/zhaojiedi1992/p/zhaojiedi_linux_022_ntp.html

ntp通信协议
---------------------------------------------------------------

linux操作系统计时是从1970年1月1日开机计算的总秒数。

ntp工作原理： 

#. 主机启动ntp这个守护进程
#. client会向ntp server发送出校对时间的message
#. 然后server发送当前的标准时间给client
#. 接受到消息后，调整自己的时间

ntp的安装
--------------------------------------------------------------

.. code-block:: bash

    [root@localhost pam.d]# yum install ntp

ntp的配置
--------------------------------------------------------------

权限控制
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ntp.conf里面使用restrict来控制权限，设置那些用户可以来获取时间信息。

.. code-block:: text 

    restrict [ip地址] mask [掩码] [参数]

    参数：
        ignore: 拒绝所有类型的ntp连接
        nomodify: 客户端不能使用ntpc域ntpq这2个程序来修改服务器的时间参数
        noquery: 客户端不能使用ntpq,ntpc等命令来查询时间服务器，等于不提供ntp网络矫时
        notrap: 不提供trap这个远程事件登陆
        notrust: 拒绝没有认证的客户端

上层nftp服务器
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    server [ip 或者主机名] [prefer]

ntp的启动
----------------------------------------------------------------------------

.. code-block:: bash

    [root@centos-159 etc]# systemctl restart ntpd
    [root@centos-159 etc]# systemctl enable ntpd
    [root@localhost pam.d]# netstat -tunlp  |grep ntp
    udp        0      0 192.168.122.1:123       0.0.0.0:*                           48325/ntpd          
    udp        0      0 192.168.46.129:123      0.0.0.0:*                           48325/ntpd          
    udp        0      0 127.0.0.1:123           0.0.0.0:*                           48325/ntpd          
    udp        0      0 0.0.0.0:123             0.0.0.0:*                           48325/ntpd          
    udp6       0      0 fe80::20c:29ff:fead:123 :::*                                48325/ntpd          
    udp6       0      0 ::1:123                 :::*                                48325/ntpd          
    udp6       0      0 :::123                  :::*                                48325/ntpd          


ntp的客户端
----------------------------------------------------------------------------

.. code-block:: bash

    [root@centos-159 ~]# yum install ntp
    [root@centos-159 etc]# vim /etc/ntp.conf
    # 添加server行，注释原有server行
    server 192.168.46.129 iburst

    [root@centos-159 etc]# systemctl restart ntpd
    [root@centos-159 etc]# systemctl enable ntpd

    [root@centos-159 etc]# ntpq -p
        remote           refid      st t when poll reach   delay   offset  jitter
    ==============================================================================
    nis.linuxpanda. .INIT.          16 u   23   64    0    0.000    0.000   0.000

.. note:: 通常启动ntp之后约15分钟才会和上级ntp服务进行顺利连接，需要耐心等待。


