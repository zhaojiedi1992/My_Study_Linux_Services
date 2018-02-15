vnc
==============================================================================

centos6 vncserver的安装

vncserver的安装_

.. _vncserver的安装: http://www.cnblogs.com/zhaojiedi1992/p/zhaojiedi_linux_030_vncserver.html

图形环境的安装
-------------------------------------------------------------

.. code-block:: bash

    [root@localhost ~]# yum groupinstall "GNOME Desktop"            # 安装gnome桌面环境
    [root@localhost ~]# startx                                      # 启动图形界面
    [root@localhost ~]# systemctl set-default  graphical.target     # 设置默认级别为图形

安装vncserver 
-------------------------------------------------------------

.. code-block:: bash

    [root@localhost ~]# yum install tigervnc-server                 # 安装vncserve
    [root@localhost ~]# rpm -ql tigervnc-server                     # 查看相关文件，没有vncserver对应的服务，只有实例的服务。
    /etc/sysconfig/vncservers
    /usr/bin/vncserver
    /usr/bin/x0vncserver
    /usr/lib/systemd/system/vncserver@.service
    /usr/lib/systemd/system/xvnc.socket
    /usr/lib/systemd/system/xvnc@.service
    /usr/share/man/man1/vncserver.1.gz
    /usr/share/man/man1/x0vncserver.1.gz

配置
-------------------------------------------------------------

.. code-block:: bash

    [root@localhost ~]# cp /usr/lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:1.service
    [root@localhost ~]# vim /usr/lib/systemd/system/vncserver@root.service
    # 修改如下行
    User=root
    PIDFile=/root/.vnc/%H%i.pid
    [root@localhost ~]# vncpasswd

.. note:: @后面跟的一定是:数值,不能写其他的，否则服务启动不起来，如果配置多个用户的，多copy几份修改下。

启动服务
-------------------------------------------------------------

.. code-block:: bash

    [root@localhost ~]# systemctl daemon-reload                     # 重新加载下systemctl配置
    [root@localhost ~]# systemctl enable vncserver@:1               # 开机启动
    [root@localhost ~]# systemctl start vncserver@:1                # 启动服务
    [root@localhost ~]# netstat -tunlp |grep vnc
    tcp        0      0 0.0.0.0:5901            0.0.0.0:*               LISTEN      37817/Xvnc          
    tcp        0      0 0.0.0.0:6001            0.0.0.0:*               LISTEN      37817/Xvnc          
    tcp6       0      0 :::5901                 :::*                    LISTEN      37817/Xvnc          
    tcp6       0      0 :::6001                 :::*                    LISTEN      37817/Xvnc 

测试
---------------------------------------------------------

在测试前，关闭selinux和防火墙

.. code-block:: bash

    systemctl stop firewalld.service

使用window环境下的vncview软件来连接，地址为192.168.46.129:5901

.. image:: /images/远程登陆/vnc.png


不知道啥情况，我的背景是黑的， 有点郁闷。

