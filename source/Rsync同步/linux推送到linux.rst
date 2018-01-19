linux同步到linux
============================================================

linux同步到linux这个情况相对其他情况是最简单的。 

环境介绍
-----------------------------------------------------------

-   2个机器
-   centos7(172.18.46.7),centos6(172.18.46.6)
-   centos7(/app/web)===>centos6(/app/web)

我们要完成的功能是centos7开发人员生成的web数据放到centos7的/app/web目录后，centos6能自动拉取centos7的目录保持一致。

rsync我们知道是分客户端和服务端的，那具体对于上面的情况可以怎么安排呢？

方案1： 我们在centos7上搭建服务端，centos6作为客户端，然后centos6去主动拉取centos7的数据。

方案2： 我们在centos6上搭建服务端，centos7作为客户端，然后centos7主动把自己的文件推送到centos6上去。

我们下面的文章主要按照方案2来实施。


.. note:: 不管如何，拉取和推送都是在客户端完成的。


服务端的配置
--------------------------------------------------------------------------

安装rsync软件
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

查看是否安装

.. code-block:: bash

    [root@centos74 ~]$ rpm -ql rsync
    [root@centos74 ~]$ yum -y install rsync

    [root@centos69 ~]$ rpm -ql rsync
    [root@centos69 ~]$ yum -y install rsync

启用rsync
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

在centos7上启用rsyncd(服务端进程)

.. code-block:: bash

    [root@centos74 ~]$ systemctl status rsyncd
    ● rsyncd.service - fast remote file copy program daemon
    Loaded: loaded (/usr/lib/systemd/system/rsyncd.service; disabled; vendor preset: disabled)
    Active: inactive (dead)
    [root@centos74 ~]$ systemctl enable rsyncd
    Created symlink from /etc/systemd/system/multi-user.target.wants/rsyncd.service to /usr/lib/systemd/system/rsyncd.service.
    [root@centos74 ~]$ systemctl start rsyncd
    [root@centos74 ~]$ systemctl status rsyncd
    ● rsyncd.service - fast remote file copy program daemon
    Loaded: loaded (/usr/lib/systemd/system/rsyncd.service; enabled; vendor preset: disabled)
    Active: active (running) since Sun 2018-01-07 19:04:02 CST; 6s ago
    Main PID: 38913 (rsync)
    CGroup: /system.slice/rsyncd.service
            └─38913 /usr/bin/rsync --daemon --no-detach
    [root@centos74 ~]$ netstat -tunlp  |grep 873
    tcp        0      0 0.0.0.0:873             0.0.0.0:*               LISTEN      38913/rsync         
    tcp6       0      0 :::873                  :::*                    LISTEN      38913/rsync   

.. attention:: rsyncd服务监听在873端口，如果有防火墙请放行或者关闭。

编辑rsyncd的配置文件
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

编辑rsyncd的配置文件(可能没有)

.. code-block:: bash

    [root@centos74 ~]$ vim /etc/rsyncd.conf
    [root@centos74 ~]$ cat /etc/rsyncd.conf 
    uid = root
    gid = root
    user chroot = no
    max connections = 200
    timeout = 600
    pid file = /var/run/rsyncd.pid
    lock file = /var/run/rsyncd.lock
    log file = /var/run/rsyncd.log

    [web]
    path = /app/web/
    ignore errors
    read only = no
    list = no
    hosts allow = 172.18.0.0/16
    auth users = web
    secrets file = /etc/rsyncd.pass


创建服务器密码文件
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

密码文件的格式是：username:password

.. code-block:: bash

    [root@centos74 ~]$ (umask 266; echo "web:web" > /etc/rsyncd.pass)
    [root@centos74 ~]$ cat /etc/rsyncd.pass 
    web:web
    [root@centos74 ~]$ ll /etc/rsyncd.pass 
    -r--------. 1 root root 8 Jan  7 19:16 /etc/rsyncd.pass

创建一个同步目录
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

这个目录用于后面客户端给推送

.. code-block:: bash

    [root@centos74 ~]$ mkdir /app/web

这个目录注意权限问题。

重启服务
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@centos74 ~]$ systemctl restart rsyncd
    [root@centos74 ~]$ systemctl status rsyncd
    ● rsyncd.service - fast remote file copy program daemon
    Loaded: loaded (/usr/lib/systemd/system/rsyncd.service; enabled; vendor preset: disabled)
    Active: active (running) since Sun 2018-01-07 19:30:12 CST; 9s ago
    Main PID: 39375 (rsync)
    CGroup: /system.slice/rsyncd.service
            └─39375 /usr/bin/rsync --daemon --no-detach

客户端端的配置
--------------------------------------------------------------------------

安装rsync软件
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

查看是否安装

.. code-block:: bash

    [root@centos69 ~]$ rpm -ql rsync
    [root@centos69 ~]$ yum -y install rsync

创建同步密码文件
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

由于我们的服务端有密码配置，客户端需要密码才能同步我们服务端的数据，且ip在服务端的运行范围内。

密码文件格式： passwd

.. code-block:: bash

    [root@centos66 ~]$ (umask 066; echo "web" > /etc/rsync.pass)
    [root@centos66 ~]$ cat /etc/rsync.pass 
    web
    [root@centos66 ~]$ ll /etc/rsync.pass 
    -rw------- 1 root root 4 Dec 26 08:23 /etc/rsync.pass

.. note:: 这里我们只需要指定密码即可，不用用户名。

初步测试同步
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@centos66 app]$ rsync -avz web@72.18.46.7::web --password-file=/etc/rsync.pass  /app/web
    receiving incremental file list
    ./
    sysconfig/
    sysconfig/.zip
    sysconfig/anaconda
    sysconfig/atd
    .................这里省去了很多文件..................................
    sysconfig/rhn/clientCaps.d/

    sent 1934 bytes  received 1170218 bytes  2344304.00 bytes/sec
    total size is 1322779  speedup is 1.13

写脚本完成自动拉取服务器数据
------------------------------------------------------------------

安装inotify-tool工具

.. code-block:: bash

    [root@centos66 yum.repos.d]$ yum install inotify-tools

编写rsync脚本

.. code-block:: bash


    #!/bin/bash

    user=web
    remote_module=web
    local_dir=/app/web/
    ip=72.18.46.7
    password_file=/etc/rsync.pass

    /usr/bin/inotifywait -mrq --timefmt '%d/%m/%y%H:%M' --format '%T %w %f' -e modify,delete,create,attrib $local_dir | while read DATE TIME DIR FILE;do
            filechange=${DIR}${FILE}
            # 拉取服务器数据
            #/usr/bin/rsync -avz --delete --progress --password-file=$password_file    $user@$ip::$remote_module   $local_dir &
            # 推送本机的数据
            /usr/bin/rsync -avz --delete --progress --password-file=$password_file     $local_dir $user@$ip::$remote_module   &

            date_str=/var/log/rsync_$(date "+%F").log
            echo "At ${TIME} on ${DATE}, file $filechange was backed up via rsynce" >> $date_str 2>&1
    done

配置计划任务
----------------------------------------------------------------

将上面的脚本放到while true里面即可，或者修改脚本为sysv脚本。