mysql主从加密
====================================================

证书信息准备
----------------------------------------

.. code-block:: bash 

    [root@localhost ~]# mkdir /etc/my.cnf.d/ssl
    [root@localhost ~]# cd /etc/my.cnf.d/ssl

    [root@localhost ssl]# openssl genrsa -out cakey.pem  2048
    [root@localhost ssl]# ll
    total 4
    -rw-r--r-- 1 root root 1675 Feb 25 17:44 cakey.pem
    [root@localhost ssl]# chmod 600 cakey.pem 
    [root@localhost ssl]# openssl  req -new -x509 -key cakey.pem -days 3650 -out cacert.pem

    [root@localhost ssl]# openssl req -newkey  rsa:1024 -nodes -days 365 -keyout master.key -out master.csr
    [root@localhost ssl]# openssl x509 -req -in master.csr -CA cacert.pem -CAkey cakey.pem -set_serial  01 -out master.crt
    Signature ok
    subject=/C=cn/ST=beijing/L=beijing/O=linuxpanda.tech/OU=dev/CN=master.linuxpanda.tech
    Getting CA Private Key
    [root@localhost ssl]# openssl req -newkey  rsa:1024 -nodes -days 365 -keyout slave.key -out slave.csr
    [root@localhost ssl]# openssl x509 -req -in slave.csr -CA cacert.pem -CAkey cakey.pem -set_serial  02 -out slave.crt
    [root@localhost ssl]# ll
    total 32
    -rw-r--r-- 1 root root 1359 Feb 25 17:45 cacert.pem
    -rw------- 1 root root 1675 Feb 25 17:44 cakey.pem
    -rw-r--r-- 1 root root 1058 Feb 25 17:53 master.crt
    -rw-r--r-- 1 root root  676 Feb 25 17:50 master.csr
    -rw-r--r-- 1 root root  916 Feb 25 17:50 master.key
    -rw-r--r-- 1 root root 1058 Feb 25 17:57 slave.crt
    -rw-r--r-- 1 root root  676 Feb 25 17:56 slave.csr
    -rw-r--r-- 1 root root  916 Feb 25 17:56 slave.key

                                                                                                                                    
    [root@localhost ssl]# scp -r -p /etc/my.cnf.d/ssl 192.168.46.152:/etc/my.cnf.d
    [root@localhost ssl]# scp -r -p /etc/my.cnf.d/ssl 192.168.46.153:/etc/my.cnf.d

主服务器配置
----------------------------------------

.. code-block:: bash 

    [root@centos-152 ~]# yum install mariadb-server 
    [root@centos-152 ~]# vim /etc/my.cnf
    # 添加如下几行到mysqld片段
    log-bin
    innodb_file_per_table
    server_id =1
    ssl
    ssl-ca=/etc/my.cnf.d/ssl/cacert.pem
    ssl-cert=/etc/my.cnf.d/ssl/master.crt
    ssl-key=/etc/my.cnf.d/ssl/master.key
    [root@centos-152 ~]# systemctl start mariadb

    MariaDB [(none)]> show variables like '%ssl%'
        -> ;
    +---------------+------------------------------+
    | Variable_name | Value                        |
    +---------------+------------------------------+
    | have_openssl  | YES                          |
    | have_ssl      | YES                          |
    | ssl_ca        | /etc/my.cnf.d/ssl/cacert.pem |
    | ssl_capath    |                              |
    | ssl_cert      | /etc/my.cnf.d/ssl/master.crt |
    | ssl_cipher    |                              |
    | ssl_key       | /etc/my.cnf.d/ssl/master.key |
    +---------------+------------------------------+
    7 rows in set (0.00 sec)

    MariaDB [(none)]> grant replication slave on *.* to repluser@'192.168.46.%' identified by 'centos' require ssl;
    Query OK, 0 rows affected (0.00 sec)


从服务器配置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    [root@localhost ~]# yum install mariadb-server 
    [root@localhost ~]# vim /etc/my.cnf

    innodb_file_per_table
    log-bin
    server_id=2

    ssl 
    ssl-ca=/etc/my.cnf.d/cacert.pem
    ssl-key=/etc/my.cnf.d/slave.key
    ssl-cert=/etc/my.cnf.d/slave.crt

    [root@localhost ~]# systemctl start mariadb

    MariaDB [(none)]> change master to  master_host='192.168.46.152', master_user='repluser', master_password='centos', master_log_file='mariadb-bin.000001', master_log_pos=245, master_ssl=1;
    Query OK, 0 rows affected (0.00 sec)

    MariaDB [(none)]> start slave;
    Query OK, 0 rows affected (0.00 sec)

    MariaDB [(none)]> show slave status\G

测试
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    # 主测试
    MariaDB [(none)]> create database db1;
    Query OK, 1 row affected (0.00 sec)

    # 从测试
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
    5 rows in set (0.00 sec)

    # 测试下

    [root@localhost ~]# mysql --ssl-ca=/etc/my.cnf.d/ssl/cacert.pem  --ssl-cert=/etc/my.cnf.d/ssl/slave.crt  --ssl-key=/etc/my.cnf.d/ssl/slave.key  -h 192.168.46.152 -u repluser -p
    Enter password: 
    Welcome to the MariaDB monitor.  Commands end with ; or \g.
    Your MariaDB connection id is 4
    Server version: 5.5.56-MariaDB MariaDB Server

    Copyright (c) 2000, 2017, Oracle, MariaDB Corporation Ab and others.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

    MariaDB [(none)]> 
