mysql的galera实现
===================================================

galera cluster特点
--------------------------------------------------


安装
--------------------------------------------------------

.. code-block:: bash 

    # yum配置
    [root@centos151 ~]# cat /etc/yum.repos.d/mariadb.repo 
    [mariadb]
    name=mariadb
    baseurl=https://mirrors.tuna.tsinghua.edu.cn/mariadb//mariadb-10.0.34/yum/centos74-amd64
    enabled=1
    gpgcheck=0

    [root@centos151 yum.repos.d]# yum install MariaDB-Galera-server


配置
-----------------------------------------------------------------

.. code-block:: bash 

    [root@centos151 ~]# vim /etc/my.cnf.d/server.cnf
    # 在galera片段添加如下几行
    wsrep_provider=/usr/lib64/galera/libgalera_smm.so
    wsrep_cluster_address="gcomm://192.168.46.151,192.168.46.152,192.168.46.153"
    binlog_format=row
    default_storage_engine=InnoDB
    innodb_autoinc_lock_mode=2
    bind-address=0.0.0.0

    [root@centos151 ~]# scp /etc/my.cnf.d/server.cnf  192.168.46.152:/etc/my.cnf.d/
    [root@centos151 ~]# scp /etc/my.cnf.d/server.cnf  192.168.46.153:/etc/my.cnf.d/

启动
-----------------------------------------------------------------

.. code-block:: bash 

    [root@centos151 ~]# /etc/init.d/mysql start --wsrep-new-cluster 
    Starting MariaDB.180227 14:52:34 mysqld_safe Logging to '/var/lib/mysql/centos151.linuxpanda.tech.err'.
    180227 14:52:34 mysqld_safe Starting mysqld daemon with databases from /var/lib/mysql
    . SUCCESS! 

    [root@centos152 ~]# /etc/rc.d/init.d/mysql  start 
    Starting MariaDB.180227 15:01:47 mysqld_safe Logging to '/var/lib/mysql/centos152.linuxpanda.tech.err'.
    180227 15:01:47 mysqld_safe Starting mysqld daemon with databases from /var/lib/mysql
    ..SST in progress, setting sleep higher.. SUCCESS! 

    [root@centos153 ~]# /etc/rc.d/init.d/mysql  start 
    Starting MariaDB.180227 15:01:47 mysqld_safe Logging to '/var/lib/mysql/centos153.linuxpanda.tech.err'.
    180227 15:01:47 mysqld_safe Starting mysqld daemon with databases from /var/lib/mysql
    ..SST in progress, setting sleep higher.. SUCCESS! 

测试
-----------------------------------------------------------------

.. code-block:: bash 

    MariaDB [(none)]> show variables like '%wsrep%'\G
    MariaDB [(none)]> show status  like '%wsrep%'\G

    # 创建一个数据库
    MariaDB [(none)]> create database db1;
    Query OK, 1 row affected (0.00 sec)

    # 152测试
    MariaDB [(none)]> show databases;
    +--------------------+
    | Database           |
    +--------------------+
    | db1                |
    | information_schema |
    | mysql              |
    | performance_schema |
    | test               |
    +--------------------+
    5 rows in set (0.00 sec)

    # 153测试
    MariaDB [(none)]> show databases;
    +--------------------+
    | Database           |
    +--------------------+
    | db1                |
    | information_schema |
    | mysql              |
    | performance_schema |
    | test               |
    +--------------------+
    5 rows in set (0.00 sec)

    
