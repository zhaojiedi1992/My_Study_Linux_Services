mariadb多实例安装
===============================================

mariadb多实例实现方式: 

mysqld_multi
    这个是使用单独的配置文件来配置多个实例，不过管理实例还是很方便的。
多个sysv配置
    这个方式相当于每个mairadb实例为一个不同的服务而已，每个实例一套sysv脚本。
    配置起来比较简单，如果实例过多管理起来比较麻烦。
systemd
    这个是systemd管理的特有的。

配置前规划
---------------------------------------------------------

上面mairadb的多实例有多种配置方法， 我们先规划如下：

.. csv-table:: 
   :header: "方案", "主目录", "端口规划","其他"
   :widths: 30, 30, 30,30

   "方案1", "/data/scheme1/mysql/", "3307,3308",""
   "方案2", "/data/scheme2/mysql/", "4307,4308",""
   "方案3", "/data/scheme3/mysql/", "5307,5308",""

配置前的环境设置
---------------------------------------------------------

关闭selinux

.. code-block:: bash

    [root@centos-158 ~]# setenforce 0
    [root@centos-158 ~]# sed -i 's@SELINUX=.*@SELINUX=disabled@' /etc/sysconfig/selinux

关闭防火墙

.. code-block:: bash

    [root@centos-158 ~]# systemctl stop firewalld
    [root@centos-158 ~]# systemctl disable firewalld

安装mariadb
---------------------------------------------------------

这里我不使用centos默认的版本，使用最新稳定版本10.2。

上面的基础规划完毕，需要配置下 mariadb的yum源_。

.. _mariadb的yum源: https://downloads.mariadb.org/mariadb/repositories/#mirror=neusoft&distro=CentOS&distro_release=centos7-amd64--centos7&version=10.2

.. code-block:: bash

    [root@centos-158 yum.repos.d]# vim mariadb.repo                             # 添加/etc/yum.repos.d/mariadb.repo文件
    [root@centos-158 yum.repos.d]# cat mariadb.repo                             # 检查这个文件
    [root@centos-158 yum.repos.d]# cat mariadb.repo 
    # MariaDB 10.2 CentOS repository list - created 2018-01-27 14:09 UTC
    # http://downloads.mariadb.org/mariadb/repositories/
    [mariadb]
    name = MariaDB
    #这个地方的配置是国外的，下载太慢了。 我给改成清华镜像站点的了，这样下载会快点。
    baseurl =https://mirrors.tuna.tsinghua.edu.cn/mariadb//mariadb-10.2.12/yum/centos/7Server/x86_64/
    gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
    gpgcheck=1

    [root@centos-158 yum.repos.d]# yum install MariaDB-server MariaDB-client -y # 安装server和client

.. note:: 这个包名是区分大小写的，使用rpm查询包提供文件的时候注意大小写。

方案1-mysqld_multi
----------------------------------------------------------

创建目录并修改权限
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: bash

    [root@centos-158 ~]# mkdir -pv /data/scheme1/mysql/{3307,3308}/data         # 创建目录
    [root@centos-158 ~]# chown mysql.mysql /data/scheme1/mysql/330{7,8} -R      # 修改权限

安装数据库
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: bash

    [root@centos-158 ~]# mysql_install_db  --datadir=/data/scheme1/mysql/3308/data --basedir=/usr --user=mysql  # 安装到数据目录
    [root@centos-158 ~]# mysql_install_db  --datadir=/data/scheme1/mysql/3308/data --basedir=/usr --user=mysql  # 安装到数据目录

配置文件
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: bash

    [root@centos-158 ~]# mv /etc/my.conf /etc/my.conf.yumbak                # 重命名文件，别影响接下来的实验，其实不必要的
    [root@centos-158 ~]# vim /etc/my.conf                                   # 编辑
    [root@centos-158 ~]# cat /etc/my.conf                                   # 查看
    [mysqld_multi]
    mysqld     = /usr/bin/mysqld_safe
    mysqladmin = /usr/bin/mysqladmin
    user       = multi_admin
    password   = zhaojiedi

    [mysqld3307]
    socket     = /data/scheme1/mysql/3307/mariadb.sock
    port       = 3307
    pid-file   = /data/scheme1/mysql/3307/mariadb.pid 
    datadir    = /data/scheme1/mysql/3307/data 
    user       = mysql

    [mysqld3308]
    socket     = /data/scheme1/mysql/3308/mariadb.sock
    port       = 3308
    pid-file   = /data/scheme1/mysql/3308/mariadb.pid 
    datadir    = /data/scheme1/mysql/3308/data 
    user       = mysql

.. note:: 更多的参数官方文档。

启动实例
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: bash

    [root@centos-158 ~]# mysqld_multi start 3307                        # 启动指定的实例，这个是在配置mysqld3307片段，实例名字就是3307
    [root@centos-158 ~]# mysqld_multi start 3308                        # 启动指定的实例，这个是在配置mysqld3307片段，实例名字就是3307

    [root@centos-158 ~]# netstat -tunlp |grep 330*                      # 查看服务
    tcp6       0      0 :::3307                 :::*                    LISTEN      2631/mysqld         
    tcp6       0      0 :::3308                 :::*                    LISTEN      2746/mysqld 

.. note:: mysqld_multi start 3307-3308来批量启动，多个矢量还可以逗号分割。

安全初始化脚本运行
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: bash

    [root@centos-158 ~]# mysql_secure_installation -S /data/scheme1/mysql/3307/mariadb.sock  # 使用socket连接3307实例
    # 下面内容只跳出重要的输入项列出
    Enter current password for root (enter for none):              # 默认密码空，直接回车即可
    Set root password? [Y/n] y                                     # 输入y
    New password:                                                  # 输入root用户密码，注意不是系统密码，是数据库密码
    Re-enter new password:                                         # 再次确认
    Remove anonymous users? [Y/n] y                                # 移除匿名用户
    Disallow root login remotely? [Y/n] y                          # 禁止root用户远程登陆，这个看你具体情况设置
    Remove test database and access to it? [Y/n] y                 # 移除test数据库
    Reload privilege tables now? [Y/n] y                           # 刷新权限表
    [root@centos-158 ~]# mysql_secure_installation -S /data/scheme1/mysql/3308/mariadb.sock  # 使用socket连接3308实例

添加多实例管理用户
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: bash

    [root@centos-158 ~]# vim create_user.sql                        # 添加用户脚本
    [root@centos-158 ~]# cat create_user.sql                        # 检查
    CREATE USER 'multi_admin'@'localhost' IDENTIFIED BY 'multi_admin';
    GRANT SHUTDOWN ON *.* TO 'multi_admin'@'localhost';
    flush privileges; 

    [root@centos-158 ~]# cat create_user.sql | mysql -u root -S /data/scheme1/mysql/3307/mariadb.sock -p #执行脚本
    Enter password: 
    [root@centos-158 ~]# cat create_user.sql | mysql -u root -S /data/scheme1/mysql/3308/mariadb.sock -p # 执行脚本
    Enter password: 

更多 mysqld-multi_ 使用帮助。

.. _mysqld-multi: https://dev.mysql.com/doc/refman/5.7/en/mysqld-multi.html

查看和关闭实例
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: bash

    [root@centos-158 ~]# mysqld_multi report                        # 查看服务状态
    Reporting MariaDB servers
    MariaDB server from group: mysqld3307 is running
    MariaDB server from group: mysqld3308 is running
    [root@centos-158 ~]# mysqld_multi stop 3307                     # 关闭一个实例
    [root@centos-158 ~]# mysqld_multi report                        # 查看服务状态
    Reporting MariaDB servers
    MariaDB server from group: mysqld3307 is not running
    MariaDB server from group: mysqld3308 is running

开机启动
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

直接加入到rc.local中

.. code-block:: bash

    [root@centos-158 ~]# echo `which mysqld_multi` start 3307-3308  >> /etc/rc.local        # 开机执行
    [root@centos-158 ~]# tail -n 1 /etc/rc.local 
    /usr/bin/mysqld_multi start 3307-3308

上面的加入rc.local方式管理上容易混乱，还是写个sysv脚本好些。

.. code-block:: bash

    [root@centos-158 init.d]# cd /etc/rc.d/init.d/
    [root@centos-158 init.d]# vim mysqld_multi 
    [root@centos-158 init.d]# cat mysqld_multi 
    #! /bin/bash
    # chkconfig: 2345 90 10
    # description: mysqld_multi

    # See how we were called.
    mysqld_multi=/usr/local/mysql/bin/mysqld_multi
    # 实例列表
    instance_list="3307-3308"
    #instance_list="3307,3308,3309-3310"
    start(){
        $mysqld_multi start $instance_list	
    }
    stop(){
        $mysqld_multi stop $instance_list
    }
    status(){
        $mysqld_multi report
    }
    case "$1" in
    start)
        start
            ;;
    stop)
        stop
            ;;
    status)
        status
            ;;
    restart)
        start
        stop
            ;;
    *)
        echo $"Usage: $0 {start|stop|status}"
        exit 2
    esac

    [root@centos-158 init.d]# chkconfig --add mysqld_multi                  # 添加sysv
    [root@centos-158 init.d]# chkconfig mysqld_multi on                     # 启用mysqld_multi


方案2-多sysv脚本
------------------------------------------------------------------------------

创建目录并修改权限
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

这种方式，需要每个配置文件都要单独存放，可以给目录更详细的规划下

.. code-block:: bash

    [root@centos-158 ~]#  mkdir -pv /data/scheme2/mysql/{4307,4308}/{data,etc,log,socket,pid,service}       # 创建目录
    [root@centos-158 ~]# chown mysql.mysql /data/scheme2/mysql/4307 -R                                      # 修改所有者
    [root@centos-158 ~]# chown mysql.mysql /data/scheme2/mysql/4308 -R                                      # 修改所有者


安装数据库
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@centos-158 ~]# mysql_install_db  --datadir=/data/scheme2/mysql/4307/data --basedir=/usr --user=mysql  # 安装数据库
    [root@centos-158 ~]# mysql_install_db  --datadir=/data/scheme2/mysql/4308/data --basedir=/usr --user=mysql  # 安装数据库

配置配置文件
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@centos-158 ~]# cd /data/scheme2/mysql/4307/etc/                           # 进入配置目录
    [root@centos-158 etc]# vim my.cnf                                               # 编辑单独的配置文件              
    [root@centos-158 etc]# cat my.cnf                                               # 检查
    [mysqld]
    port=4307
    datadir=/data/scheme2/mysql/4307/data
    socket=/data/scheme2/mysql/4307/socket/mariadb.sock
    [mysqld-safe]
    log-error=/data/scheme2/mysql/4307/log/mariadb.log
    pid-file=/data/scheme2/mysql/4308/pid/mariadb.pid

    [root@centos-158 etc]# cp my.cnf ../../4308/etc/my.cnf                          # 复制到另一个实例中去
    [root@centos-158 etc]# sed -i 's@4307@4308@' ../../4308/etc/my.cnf              # 修改配置的端口
    [root@centos-158 etc]# cat ../../4308/etc/my.cnf                                # 检查
    [mysqld]
    port=4308
    datadir=/data/scheme2/mysql/4308/data
    socket=/data/scheme2/mysql/4308/socket/mariadb.sock
    [mysqld-safe]
    log-error=/data/scheme2/mysql/4308/log/mariadb.log
    pid-file=/data/scheme2/mysql/4308/pid/mariadb.pid

配置服务文件
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@centos-158 4307]# vim service/mysqld.sh                                   # 编辑sysv脚本
    [root@centos-158 4307]# cat service/mysqld.sh                                   # 检查
    #!/bin/bash
    # chkconfig: 2345 91 19
    # description: manage mariadb 

    port=4307
    mysql_user="root"
    mysql_pwd=""
    mysql_basedir="/data/scheme2/mysql"
    #cmd_path="${mysql_basedir}/${port}/bin"
    cmd_path="/usr/bin"
    mysql_sock="${mysql_basedir}/${port}/socket/mariadb.sock"

    function_start_mysql()
    {
        if [ ! -e "$mysql_sock" ];then
        printf "Starting MySQL...\n"
        cmd="${cmd_path}/mysqld_safe --defaults-file=${mysql_basedir}/${port}/etc/my.cnf"
        printf "$cmd\n"
        ${cmd_path}/mysqld_safe --defaults-file=${mysql_basedir}/${port}/etc/my.cnf  &> /dev/null  &
        else
        printf "MySQL is running...\n"
        exit
        fi
    }
    function_status_mysql(){
            if [ -e "$mysql_sock" ] ; then
                    printf "MySql is running...\n"
            else
                    printf "MySql is stopped...\n"
            fi
    }

    function_stop_mysql()
    {
        if [ ! -e "$mysql_sock" ];then
        printf "MySQL is stopped...\n"
        exit
        else
        printf "Stoping MySQL...\n"
        ${cmd_path}/mysqladmin -u ${mysql_user} -p${mysql_pwd} -S ${mysql_sock} shutdown
    fi
    }


    function_restart_mysql()
    {
        printf "Restarting MySQL...\n"
        function_stop_mysql
        sleep 2
        function_start_mysql
    }

    case $1 in
    start)
            function_start_mysql
            ;;
    stop)
            function_stop_mysql
            ;;
    restart)
            function_restart_mysql
            ;;
    status)
            function_status_mysql
            ;;
    *)
        printf "Usage: ${cmd_path}/mysqld {start|stop|restart|status}\n"
    esac


    [root@centos-158 4307]# cp service/mysqld.sh  ../4308/service/mysqld.sh     # 复制一份
    [root@centos-158 4307]# sed -i 's@4307@4308@' ../4308/service/mysqld.sh     # 修改端口
    [root@centos-158 4307]# cat ../4308/service/mysqld.sh                       # 检查
    #!/bin/bash
    # chkconfig: 2345 91 19
    # description: manage mariadb 

    port=4308
    mysql_user="root"
    mysql_pwd=""
    mysql_basedir="/data/scheme2/mysql"
    #cmd_path="${mysql_basedir}/${port}/bin"
    cmd_path="/usr/bin"
    mysql_sock="${mysql_basedir}/${port}/socket/mariadb.sock"

    function_start_mysql()
    {
        if [ ! -e "$mysql_sock" ];then
        printf "Starting MySQL...\n"
        cmd="${cmd_path}/mysqld_safe --defaults-file=${mysql_basedir}/${port}/etc/my.cnf"
        printf "$cmd\n"
        ${cmd_path}/mysqld_safe --defaults-file=${mysql_basedir}/${port}/etc/my.cnf  &> /dev/null  &
        else
        printf "MySQL is running...\n"
        exit
        fi
    }
    function_status_mysql(){
            if [ -e "$mysql_sock" ] ; then
                    printf "MySql is running...\n"
            else
                    printf "MySql is stopped...\n"
            fi
    }

    function_stop_mysql()
    {
        if [ ! -e "$mysql_sock" ];then
        printf "MySQL is stopped...\n"
        exit
        else
        printf "Stoping MySQL...\n"
        ${cmd_path}/mysqladmin -u ${mysql_user} -p${mysql_pwd} -S ${mysql_sock} shutdown
    fi
    }


    function_restart_mysql()
    {
        printf "Restarting MySQL...\n"
        function_stop_mysql
        sleep 2
        function_start_mysql
    }

    case $1 in
    start)
            function_start_mysql
            ;;
    stop)
            function_stop_mysql
            ;;
    restart)
            function_restart_mysql
            ;;
    status)
            function_status_mysql
            ;;
    *)
        printf "Usage: ${cmd_path}/mysqld {start|stop|restart|status}\n"
    esac

    # 添加执行权限
    [root@centos-158 4307]# chmod a+x /data/scheme2/mysql/4307/service/mysqld.sh 
    [root@centos-158 4307]# chmod a+x /data/scheme2/mysql/4308/service/mysqld.sh

开机启动
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@centos-158 4307]# ln -s /data/scheme2/mysql/4307/service/mysqld.sh /etc/rc.d/init.d/mysql4307     # 添加到init.d目录
    [root@centos-158 4307]# chkconfig --add mysql4307                                                       # 添加到sysv
    [root@centos-158 4307]# chkconfig mysql4307 on                                                          # 开机启动

    [root@centos-158 4307]# cd ../4308

    [root@centos-158 4308]# ln -s /data/scheme2/mysql/4308/service/mysqld.sh /etc/rc.d/init.d/mysql4308     # 添加到init.d目录
    [root@centos-158 4308]# chkconfig --add mysql4308                                                       # 添加到sysv
    [root@centos-158 4308]# chkconfig mysql4308 on                                                          # 开机启动

启动服务和查看状态
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@centos-158 4307]# service mysql4307 start                     # 启动实例
    [root@centos-158 4307]# service mysql4308 start                     # 启动实例      
    [root@centos-158 4307]# netstat -tunlp |grep 430                    # 查看状态
    tcp6       0      0 :::4307                 :::*                    LISTEN      8221/mysqld         
    tcp6       0      0 :::4308                 :::*                    LISTEN      8369/mysqld 

安全初始化
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@centos-158 4307]# mysql_secure_installation  -u root  -S /data/scheme2/mysql/4307/socket/mariadb.sock # 安全初始化，参考方案1
    [root@centos-158 4307]# mysql_secure_installation  -u root  -S /data/scheme2/mysql/4308/socket/mariadb.sock # 安全初始化，参考方案1

服务文件修改密码
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@centos-158 4307]# vim service/mysqld.sh               # 修改文件的密码项为上面的安装初始化指定的密码
    mysql_pwd="xxxxx"
    [root@centos-158 4307]# chmod 750 service/mysqld.sh         # 带有密码设置下权限
    [root@centos-158 4307]# cd ../4308                          
    [root@centos-158 4308]# vim service/mysqld.sh               # 修改文件的密码项为上面的安装初始化指定的密码
    mysql_pwd="xxxxx"
    [root@centos-158 4308]# chmod 750 service/mysqld.sh         # 带有密码设置下权限

方案3-systemd
---------------------------------------------------------------------

创建目录并修改权限
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

这种方式，需要每个配置文件都要单独存放，可以给目录更详细的规划下

.. code-block:: bash

    [root@centos-158 ~]# mkdir -pv /data/scheme3/mysql/{5307,5308}/{data,log,socket,pid}        # 创建目录
    [root@centos-158 ~]# chown mysql.mysql /data/scheme3/mysql/5307 -R                          # 所有者修改
    [root@centos-158 ~]# chown mysql.mysql /data/scheme3/mysql/5308 -R                          # 所有者修改

安装数据库
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: bash

    [root@centos-158 ~]# mysql_install_db  --datadir=/data/scheme3/mysql/5307/data --basedir=/usr --user=mysql  # 安装数据库
    [root@centos-158 ~]# mysql_install_db  --datadir=/data/scheme3/mysql/5308/data --basedir=/usr --user=mysql  # 安装数据库

配置配置文件
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@centos-158 ~]# mv /etc/my.cnf /etc/my.cnf.multi                       # 原有配置文件重名
    [root@centos-158 system]# cd /etc/my.cnf.d/                                 # 进入conf.d目录
                
    [root@centos-158 my.cnf.d]# vim my5307.cnf                                  # 编辑这个文件，名字为my<instance_nam>.cnf
    [root@centos-158 my.cnf.d]# cat my5307.cnf                                  # 检查
    [mysqld]
    datadir=/data/scheme3/mysql/5307/data
    socket=/data/scheme3/mysql/5307/socket/mariadb.sock
    port=5307
    log-error=/data/scheme3/mysql/5307/log/mariadb.log
    pid-file=/data/scheme3/mysql/5307/pid/mariadb.pid
    [root@centos-158 my.cnf.d]# vim my5308.cnf                                  # 编辑这个文件
    [root@centos-158 my.cnf.d]# cat my5308.cnf                                  # 检查
    [mysql]
    datadir=/data/scheme3/mysql/5308/data
    socket=/data/scheme3/mysql/5308/socket/mariadb.sock
    port=5308
    log-error=/data/scheme3/mysql/5308/log/mariadb.log
    pid-file=/data/scheme3/mysql/5308/pid/mariadb.pid

配置systemd
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@centos-158 my.cnf.d]# vim /usr/lib/systemd/system/mariadb@.service        # 修改mariadb@service文件默认项
    # 修改如下内容
    ConditionPathExists=/etc/my.cnf.d/my%I.cnf

    ExecStartPre=/bin/sh -c "[ ! -e /usr/bin/galera_recovery ] && VAR= || \
    VAR=`/usr/bin/galera_recovery --defaults-file=/etc/my.cnf.d/my%I.cnf`; [ $? -eq 0 ] \
    && systemctl set-environment _WSREP_START_POSITION%I=$VAR || exit 1"

    ExecStart=/usr/sbin/mysqld --defaults-file=/etc/my.cnf.d/my%I.cnf \
    $_WSREP_NEW_CLUSTER $_WSREP_START_POSITION%I $MYSQLD_OPTS

上面的简单的说就是说明下mysqld命令的路径，指定你的实例所在的路径%I代表实例名字。后续启动的systemctl start mariadb@5307这个命令中，5307就是实例名字。

这个文件有点多， 提供一个下载参考吧。

:download:`/files/mariadb@.service` 

启动服务和查看状态
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@centos-158 my.cnf.d]# systemctl daemon-reload                 # 重载systemd
    [root@centos-158 my.cnf.d]# systemctl start mariadb@5307            # 启动实例
    [root@centos-158 my.cnf.d]# systemctl start mariadb@5308            # 启动实例
    [root@centos-158 my.cnf.d]# netstat -tunlp |grep 530                # 查看服务状态
    tcp6       0      0 :::5307                 :::*                    LISTEN      10267/mysqld        
    tcp6       0      0 :::5308                 :::*                    LISTEN      10595/mysqld  

开机启动
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@centos-158 my.cnf.d]# systemctl enable  mariadb@5307           # 开机启动这个实例
    Created symlink from /etc/systemd/system/multi-user.target.wants/mariadb@5307.service to /usr/lib/systemd/system/mariadb@.service.
    [root@centos-158 my.cnf.d]# systemctl enable  mariadb@5308           # 开机启动这个实例
    Created symlink from /etc/systemd/system/multi-user.target.wants/mariadb@5308.service to /usr/lib/systemd/system/mariadb@.service.

安全初始化
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@centos-158 ~]# mysql_secure_installation  -u root  -S /data/scheme3/mysql/5307/socket/mariadb.sock    # 安全设置
    [root@centos-158 ~]# mysql_secure_installation  -u root  -S /data/scheme3/mysql/5308/socket/mariadb.sock    # 安全设置
