mysql主从
====================================================

mysql一主一从
-------------------------------------------------------------

主服务器设置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    [root@localhost yum.repos.d]# yum install mariadb-server 
    [root@localhost yum.repos.d]# vim /etc/my.cnf
    # 添加如下3行到mysqld片段
    log-bin
    innodb_file_per_table
    server_id=1

    [root@localhost yum.repos.d]# mysql 
    MariaDB [(none)]> show master logs;
    +--------------------+-----------+
    | Log_name           | File_size |
    +--------------------+-----------+
    | mariadb-bin.000001 |       245 |
    +--------------------+-----------+
    1 row in set (0.01 sec)

    # 创建用户
    MariaDB [(none)]> grant replication slave on *.* to repluser@'192.168.46.%' identified by 'centos' ; 
    Query OK, 0 rows affected (0.00 sec)


从服务器设置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    [root@localhost yum.repos.d]# yum install mariadb-server 
    [root@localhost yum.repos.d]# vim /etc/my.cnf
    # 添加如下3行到mysqld片段
    log-bin
    innodb_file_per_table
    server_id=2

    [root@localhost yum.repos.d]# mysql 
    # 使用这个帮助命令获取到样例，对着样例修改下。
    MariaDB [(none)]> help change master to 
    MariaDB [(none)]> change master to
        -> master_host='192.168.46.151',
        -> master_user='repluser',
        -> master_password='centos',
        -> master_port=3306,
        -> master_log_file='mariadb-bin.000001',
        -> master_log_pos=245;

    # 查看状态
    MariaDB [(none)]> show slave status\G
    *************************** 1. row ***************************
                Slave_IO_State: 
                    Master_Host: 192.168.46.151
                    Master_User: repluser
                    Master_Port: 3306
                    Connect_Retry: 60
                Master_Log_File: mariadb-bin.000001
            Read_Master_Log_Pos: 245
                Relay_Log_File: mariadb-relay-bin.000001
                    Relay_Log_Pos: 4
            Relay_Master_Log_File: mariadb-bin.000001
                Slave_IO_Running: No
                Slave_SQL_Running: No
                Replicate_Do_DB: 
            Replicate_Ignore_DB: 
            Replicate_Do_Table: 
        Replicate_Ignore_Table: 
        Replicate_Wild_Do_Table: 
    Replicate_Wild_Ignore_Table: 
                    Last_Errno: 0
                    Last_Error: 
                    Skip_Counter: 0
            Exec_Master_Log_Pos: 245
                Relay_Log_Space: 245
                Until_Condition: None
                Until_Log_File: 
                    Until_Log_Pos: 0
            Master_SSL_Allowed: No
            Master_SSL_CA_File: 
            Master_SSL_CA_Path: 
                Master_SSL_Cert: 
                Master_SSL_Cipher: 
                Master_SSL_Key: 
            Seconds_Behind_Master: NULL
    Master_SSL_Verify_Server_Cert: No
                    Last_IO_Errno: 0
                    Last_IO_Error: 
                Last_SQL_Errno: 0
                Last_SQL_Error: 
    Replicate_Ignore_Server_Ids: 
                Master_Server_Id: 0

    # 启动线程
    MariaDB [(none)]> start slave;
    Query OK, 0 rows affected (0.00 sec)

    # 再次查看
    MariaDB [(none)]> show slave status\G
    *************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                    Master_Host: 192.168.46.151
                    Master_User: repluser
                    Master_Port: 3306
                    Connect_Retry: 60
                Master_Log_File: mariadb-bin.000001
            Read_Master_Log_Pos: 400
                Relay_Log_File: mariadb-relay-bin.000002
                    Relay_Log_Pos: 686
            Relay_Master_Log_File: mariadb-bin.000001
                Slave_IO_Running: Yes
                Slave_SQL_Running: Yes
                Replicate_Do_DB: 
            Replicate_Ignore_DB: 
            Replicate_Do_Table: 
        Replicate_Ignore_Table: 
        Replicate_Wild_Do_Table: 
    Replicate_Wild_Ignore_Table: 
                    Last_Errno: 0
                    Last_Error: 
                    Skip_Counter: 0
            Exec_Master_Log_Pos: 400
                Relay_Log_Space: 982
                Until_Condition: None
                Until_Log_File: 
                    Until_Log_Pos: 0
            Master_SSL_Allowed: No
            Master_SSL_CA_File: 
            Master_SSL_CA_Path: 
                Master_SSL_Cert: 
                Master_SSL_Cipher: 
                Master_SSL_Key: 
            Seconds_Behind_Master: 0
    Master_SSL_Verify_Server_Cert: No
                    Last_IO_Errno: 0
                    Last_IO_Error: 
                Last_SQL_Errno: 0
                Last_SQL_Error: 
    Replicate_Ignore_Server_Ids: 
                Master_Server_Id: 1

测试
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    # 在主上创建一个表
    MariaDB [(none)]> use test;
    Database changed
    MariaDB [test]> create table t1(id int primary key ,name varchar(20));
    Query OK, 0 rows affected (0.31 sec)

    # 在从上查看是否有同步
    MariaDB [test]> show tables;
    +----------------+
    | Tables_in_test |
    +----------------+
    | t1             |
    +----------------+
    1 row in set (0.00 sec)


mysql一主多从
-------------------------------------------------------------

一主多从，我们在上面的基础上在添加一台从服务器。

这里有一个问题， 如果原有的主从运行很长时间了， 如果给新的从让他从很久前的日志来恢复是不是需要很久的时间啊，
我们可以考虑使用主库的最新备份来快速还原， 然后change log到备份的位置就可以了。

主服务器备份
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    [root@localhost yum.repos.d]# innobackupex /backup
    [root@localhost yum.repos.d]# scp -r -p /backup/ 192.168.46.153:/

从服务器设置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    [root@localhost yum.repos.d]# yum install mariadb-server 

    [root@localhost yum.repos.d]# vim /etc/my.cnf
    # 添加如下3行到mysqld片段
    log-bin
    innodb_file_per_table
    server_id=2

    # 利用备份恢复下数据
    [root@localhost ~]# innobackupex  --apply-log /backup/2018-02-25_10-54-41/
    [root@localhost ~]# rm -rf /var/lib/mysql/
    [root@localhost ~]# innobackupex  --copy-back /backup/2018-02-25_10-54-41/
    [root@localhost ~]# chown mysql.mysql /var/lib/mysql/ -R
    [root@localhost ~]# cat /backup/2018-02-25_10-54-41/xtrabackup_binlog_info 
    mariadb-bin.000001	516
    [root@localhost ~]# systemctl restart mariadb

    [root@localhost yum.repos.d]# mysql 
    # 使用这个帮助命令获取到样例，对着样例修改下。
    MariaDB [(none)]> help change master to 
    MariaDB [(none)]> change master to
        -> master_host='192.168.46.151',
        -> master_user='repluser',
        -> master_password='centos',
        -> master_port=3306,
        -> master_log_file='mariadb-bin.000001',
        -> master_log_pos=516;

    # 查看状态
    MariaDB [(none)]> show slave status\G

    # 启动线程
    MariaDB [(none)]> start slave;
    Query OK, 0 rows affected (0.00 sec)

    # 再次查看
    MariaDB [(none)]> show slave status\G

测试
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    
.. code-block:: bash

    # 主服务器添加个表
    MariaDB [test]> create table t2 as select * from t1;
    # 从服务器测试
    MariaDB [test]> show tables;
    +----------------+
    | Tables_in_test |
    +----------------+
    | t1             |
    | t2             |
    +----------------+
    2 rows in set (0.00 sec)


mysql级联复制
-------------------------------------------------------------

上面是2个服务器作为主服务器的从， 如果从服务器过多会影响主的工作的， 我们可以第二个从该从第一个从那里同步数据，
而不是第一个从那里获取数据。

第一个从的配置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    [root@localhost ~]# vim /etc/my.cnf
    # 添加如下1行到mysqld片段
    log_slave_updates
    [root@localhost ~]# systemctl restart mariadb


第二个从的配置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

MariaDB [(none)]> change master to  master_host='192.168.46.152', master_user='repluser', master_password='centos', master_log_file='mariadb-bin.000001', master_log_pos=245;
MariaDB [(none)]> start slave;
MariaDB [(none)]> show slave status\G

测试
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

# 主服务器测试
MariaDB [test]> create table t3(id int primary key);
Query OK, 0 rows affected (0.07 sec)

# 从服务器测试
MariaDB [test]> show tables;
+----------------+
| Tables_in_test |
+----------------+
| t3             |
+----------------+
1 row in set (0.00 sec)


发现表只有t3，没有原有的t1,t2的。也就是和主数据库不一致的， 原因是我们没有开始就给第一个从服务器开启log_slave_updates，
导致我们的主服务器给第一个从原有推送的数据（t1表，t2表，没有记录日志）,我们后来开启了log_slave_updates也就只能获取后续的同步，
前面的数据都是缺失的。

正确做法应该是从第一个从上做个完全备份，在第二个从上还原下，然后在指定masterlog 就可以了。

修复问题
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    [root@localhost ~]# innobackupex  /backup
    [root@localhost ~]# scp /backup/ 192.168.46.153:/

    [root@localhost ~]# innobackupex  --apply-log /backup/2018-02-25_10-54-41/

    [root@localhost ~]# systemctl stop mariadb
    [root@localhost ~]# rm -rf /var/lib/mysql/*
    [root@localhost ~]# innobackupex  --copy-back /backup/2018-02-25_10-54-41/

    [root@localhost ~]# chown mysql.mysql /var/lib/mysql/ -R 
    [root@localhost ~]# systemctl start mariadb

    MariaDB [(none)]> change master to 
        -> master_host='192.168.46.152',
        -> master_user='repluser',
        -> master_password='centos',
        -> master_log_file='mariadb-bin.000001',
        -> master_log_pos=516;

    # 开启
    MariaDB [(none)]> start slave;

    # 主服务器创建表
    MariaDB [test]> create table t5(id int primary key);
    Query OK, 0 rows affected (0.07 sec)

    # 第二个从测试
    MariaDB [test]> show tables;
    +----------------+
    | Tables_in_test |
    +----------------+
    | t1             |
    | t2             |
    | t3             |
    | t4             |
    | t5             |
    +----------------+
    5 rows in set (0.00 sec)

mysql主主复制
-------------------------------------------------------------

第一个主配置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@centos-151 ~]# yum install mariadb-server 
    [root@centos-151 ~]# vim /etc/my.cnf
    # 在mysqld片段添加如下5行
    innodb_file_per_table
    log-bin
    server_id=1
    auto_increment_offset=1
    auto_increment_increment=2

    [root@centos-151 ~]# systemctl start mariadb
    MariaDB [(none)]> grant replication slave on *.* to repluser@'192.168.46.%' identified by 'centos';
    [root@centos-152 ~]# yum install http://download2.linuxpanda.tech/mysql/percona-xtrabackup-24-2.4.9-1.el7.x86_64.rpm
    [root@centos-151 ~]# innobackupex  /backup
    [root@centos-151 ~]# scp -r -p /backup 192.168.46.152:/

第二个主配置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    [root@centos-152 ~]# yum install mariadb-server 
    [root@centos-152 ~]# vim /etc/my.cnf
    # 在mysqld片段添加如下5行
    innodb_file_per_table
    log-bin
    server_id=2
    auto_increment_offset=2
    auto_increment_increment=2

    [root@centos-152 ~]# yum install http://download2.linuxpanda.tech/mysql/percona-xtrabackup-24-2.4.9-1.el7.x86_64.rpm
    [root@centos-152 ~]# innobackupex  --apply-log /backup/2018-02-25_15-15-26/

    [root@centos-152 ~]# innobackupex  --copy-back /backup/2018-02-25_15-15-26/

    [root@centos-152 ~]# chown mysql.mysql /var/lib/mysql/ -R
    [root@centos-152 ~]# systemctl start mariadb
    [root@centos-152 ~]# cat /backup/2018-02-25_15-15-26/xtrabackup_binlog_info 
    mariadb-bin.000001	405
    MariaDB [(none)]> change master to master_host='192.168.46.151',master_user='repluser',master_password='centos',master_log_file='mariadb-bin.000001',master_log_pos=405;
    MariaDB [(none)]> start slave;
    MariaDB [(none)]> show slave status\G

    MariaDB [(none)]> show master logs;
    +--------------------+-----------+
    | Log_name           | File_size |
    +--------------------+-----------+
    | mariadb-bin.000001 |       245 |
    +--------------------+-----------+
    1 row in set (0.00 sec)

第一个主再配置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

上面已经看到第二个主的日志位置了。

.. code-block:: bash 

    MariaDB [(none)]> change master to master_host='192.168.46.152',master_user='repluser',master_password='centos',master_log_file='mariadb-bin.000001',master_log_pos=245;
    MariaDB [(none)]> start slave;
    MariaDB [(none)]> show slave status\G

测试
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    ## 在第一个机器上操作。
    MariaDB [test]> create table t1(id int auto_increment  primary key , name varchar(20));
    MariaDB [test]> insert into t1(name) values ('zhaojiedi'), ('zhaojiedi1992') ,('zhao');
    # 查看结果
    MariaDB [test]> select * from t1;
    +----+---------------+
    | id | name          |
    +----+---------------+
    |  1 | zhaojiedi     |
    |  3 | zhaojiedi1992 |
    |  5 | zhao          |
    +----+---------------+
    3 rows in set (0.00 sec)

    ## 在第二个机器上操作
    MariaDB [test]> insert into t1(name) values ('zhaojiedi1'), ('zhaojiedi19921') ,('zhao1');
    MariaDB [test]> select * from t1;
    +----+----------------+
    | id | name           |
    +----+----------------+
    |  1 | zhaojiedi      |
    |  3 | zhaojiedi1992  |
    |  5 | zhao           |
    |  6 | zhaojiedi1     |
    |  8 | zhaojiedi19921 |
    | 10 | zhao1          |
    +----+----------------+
    6 rows in set (0.00 sec)


mysql半同步复制
-------------------------------------------------------------

半同步复制需要先搭建一个主从架构的。

主服务器配置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@localhost ~]# yum install mariadb-server 
    [root@localhost ~]# vim /etc/my.cnf
    # 在mysqld片段添加如下5行
    innodb_file_per_table
    log-bin
    server_id=2
    [root@localhost ~]# systemctl start mairadb
    Failed to start mairadb.service: Unit not found.
    [root@localhost ~]# systemctl start mariadb
    [root@localhost ~]# yum install http://download2.linuxpanda.tech/mysql/percona-xtrabackup-24-2.4.9-1.el7.x86_64.rpm
    [root@localhost ~]# innobackupex  /backup
    [root@localhost ~]# scp -r -p /backup 192.168.46.152:/

主服务器配置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@centos-152 ~]# yum install http://download2.linuxpanda.tech/mysql/percona-xtrabackup-24-2.4.9-1.el7.x86_64.rpm

    [root@centos-152 ~]# yum install mariadb-server 
    [root@centos-152 ~]# vim /etc/my.cnf
    # 在mysqld片段添加如下5行
    innodb_file_per_table
    log-bin
    server_id=2
    [root@centos-152 ~]# innobackupex  --apply-log /backup/2018-02-25_16-27-54/
    [root@centos-152 ~]# innobackupex  --copy-back /backup/2018-02-25_16-27-54/
    [root@centos-152 ~]# chown mysql.mysql /var/lib/mysql/ -R 
    [root@centos-152 ~]# cat /backup/2018-02-25_16-27-54/xtrabackup_binlog_info 
    mariadb-bin.000001	400
    [root@centos-152 ~]# systemctl start mariadb
    MariaDB [(none)]> change master to master_host='192.168.46.151',master_user='repluser',master_password='centos',master_log_file='mariadb-bin.000001',master_log_pos=400;
    MariaDB [(none)]> start slave;
    MariaDB [(none)]> show slave status\G


安装插件
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    # 主服务器安装插件

    MariaDB [(none)]> install plugin rpl_semi_sync_master SONAME 'semisync_master.so';
    MariaDB [(none)]> set global rpl_semi_sync_master_enabled=1;
    Query OK, 0 rows affected (0.00 sec)

    MariaDB [(none)]> show global variables like '%semi%';
    +------------------------------------+-------+
    | Variable_name                      | Value |
    +------------------------------------+-------+
    | rpl_semi_sync_master_enabled       | ON    |
    | rpl_semi_sync_master_timeout       | 10000 |
    | rpl_semi_sync_master_trace_level   | 32    |
    | rpl_semi_sync_master_wait_no_slave | ON    |
    +------------------------------------+-------+
    4 rows in set (0.00 sec)

    # 从服务器安装插件
    MariaDB [(none)]> install plugin rpl_semi_sync_slave SONAME 'semisync_slave.so';
    Query OK, 0 rows affected (0.00 sec)

    MariaDB [(none)]> show global variables like '%semi%';

    MariaDB [(none)]> set global rpl_semi_sync_slave_enabled=1;
    Query OK, 0 rows affected (0.00 sec)

    MariaDB [(none)]> show global variables like '%semi%';
    +---------------------------------+-------+
    | Variable_name                   | Value |
    +---------------------------------+-------+
    | rpl_semi_sync_slave_enabled     | ON    |
    | rpl_semi_sync_slave_trace_level | 32    |
    +---------------------------------+-------+
    2 rows in set (0.00 sec)


测试
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    # 主服务器测试
    MariaDB [(none)]> create database db1;
    Query OK, 1 row affected (10.01 sec)

    # 从服务器测试
    MariaDB [(none)]> show databases;
    +--------------------+
    | Database           |
    +--------------------+
    | information_schema |
    | db1                |
    | mysql              |
    | performance_schema |
    | test               |
    +--------------------+
    5 rows in set (0.05 sec)

mysql复制过滤
-----------------------------------------------

复制过滤用于复制特定的对象而不是全部对象。

支持2种模式， 白名单模式是只复制指定的对象，黑名单是除了这些对象意外的复制。

实验在上面的半同步的基础上做。

.. code-block:: bash 

    MariaDB [db2]> set global replicate_do_db='test';
    ERROR 1198 (HY000): This operation cannot be performed with a running slave; run STOP SLAVE first
    MariaDB [db2]> stop slave;
    Query OK, 0 rows affected (0.28 sec)

    MariaDB [db2]> set global replicate_do_db='test';
    Query OK, 0 rows affected (0.00 sec)

    MariaDB [db2]> start slave;
    Query OK, 0 rows affected (0.00 sec)

.. note:: replicate_do_db需要在配置文件中设置下。


测试
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    # 在主上测试
    MariaDB [db2]> create database db5;
    Query OK, 1 row affected (0.00 sec)
    # 在从上查看
    MariaDB [db2]> show databases;
    +--------------------+
    | Database           |
    +--------------------+
    | information_schema |
    | db1                |
    | db2                |
    | db3                |
    | db4                |
    | mysql              |
    | performance_schema |
    | test               |
    +--------------------+
    8 rows in set (0.01 sec)


