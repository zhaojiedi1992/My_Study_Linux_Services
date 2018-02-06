ftp基于mysql的验证
=========================================

本篇文章主要实现基于mysql的ftp认证，包含3台机器，数据库服务器、ftp服务器、客户机。

数据库服务器配置
---------------------------------------------------------------

安装软件和安全初始化
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@centos-159 yum.repos.d]# yum install mariadb-server
    [root@centos-159 yum.repos.d]# systemctl restart mariadb                                                                             :::3306                                                                                                :::*                  
    [root@centos-159 yum.repos.d]# ss -tunl |grep 3306
    tcp    LISTEN     0      80       :::3306                 :::*       
    [root@centos-159 yum.repos.d]# mysql_secure_installation 

创建数据库对象
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@centos-159 yum.repos.d]# mysql -u root -p
    Enter password: 
    Welcome to the MariaDB monitor.  Commands end with ; or \g.
    Your MariaDB connection id is 27
    Server version: 10.2.12-MariaDB MariaDB Server

    Copyright (c) 2000, 2017, Oracle, MariaDB Corporation Ab and others.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

    MariaDB [(none)]> create database vsftpd;
    Query OK, 1 row affected (0.00 sec)

    MariaDB [(none)]> show databases;
    +--------------------+
    | Database           |
    +--------------------+
    | information_schema |
    | mysql              |
    | performance_schema |
    | vsftpd             |
    +--------------------+
    5 rows in set (0.00 sec)

    MariaDB [(none)]> grant select on vsftpd.* to vsftpd@'192.168.46.%' identified by 'panda';
    Query OK, 0 rows affected (0.00 sec)

    MariaDB [(none)]> flush privileges;
    Query OK, 0 rows affected (0.00 sec)

    MariaDB [(none)]> use vsftpd;
    Database changed

    MariaDB [vsftpd]> create table users ( id int auto_increment primary key , name char(50) binary not null , password char(50) binary not null );
    Query OK, 0 rows affected (0.01 sec)

    MariaDB [vsftpd]> insert into users (name,password) values('panda1' , password('panda1'));
    Query OK, 1 row affected (0.01 sec)

    MariaDB [vsftpd]> insert into users (name,password) values('panda2' , password('panda2'));
    Query OK, 1 row affected (0.00 sec)

    MariaDB [vsftpd]> select * from users;
    +----+--------+-------------------------------------------+
    | id | name   | password                                  |
    +----+--------+-------------------------------------------+
    |  1 | panda1 | *27BA6759E5C46E9564CA47033CA0FA65507DB3D0 |
    |  2 | panda2 | *9D961D6FF5C5B00850EFF7DA36AC400326748EE0 |
    +----+--------+-------------------------------------------+
    2 rows in set (0.00 sec)



ftp服务器配置
---------------------------------------------------------------


安装vsftpd
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@centos-152 src]# yum install vsftpd


编译pam-mysql
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    # 安装必要的环境包
    [root@centos-152 pam_mysql-0.7RC1]# yum install mariadb-devel pam-devel
    [root@centos-152 pam_mysql-0.7RC1]# yum groupinstall "development tools"

    # 下载编译安装
    [root@centos-152 ~]# cd /usr/src
    [root@centos-152 src]# wget https://jaist.dl.sourceforge.net/project/pam-mysql/pam-mysql/0.7RC1/pam_mysql-0.7RC1.tar.gz
    [root@centos-152 src]# tar xf pam_mysql-0.7RC1.tar.gz 
    [root@centos-152 pam_mysql-0.7RC1]# cat README
    [root@centos-152 pam_mysql-0.7RC1]# cat INSTALL 
    [root@centos-152 pam_mysql-0.7RC1]# ./configure  --with-pam-mods-dir=/lib64/security
    [root@centos-152 pam_mysql-0.7RC1]# make && make install

    # 查看模块
    [root@centos-152 pam_mysql-0.7RC1]# ll /lib64/security/ |grep mysql
    -rwxr-xr-x  1 root root    882 Feb  4 06:23 pam_mysql.la
    -rwxr-xr-x  1 root root 141680 Feb  4 06:23 pam_mysql.so


配置文件
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

pam模块配置

.. code-block:: bash

    [root@centos-152 pam_mysql-0.7RC1]# vim /etc/pam.d/vsftpd.mysql
    [root@centos-152 pam_mysql-0.7RC1]# cat /etc/pam.d/vsftpd.mysql
    auth required pam_mysql.so user=vsftpd passwd=panda    host=192.168.46.159 db=vsftpd table=users usercolumn=name passwdcolumn=password crypt=2
    account required pam_mysql.so user=vsftpd passwd=panda host=192.168.46.159 db=vsftpd table=users usercolumn=name passwdcolumn=password crypt=2

vsftpd配置

.. code-block:: bash

    [root@centos-152 pam_mysql-0.7RC1]# vim /etc/vsftpd/vsftpd.conf 
    # 添加如下3行
    guest_enable=YES
    guest_username=ftpuser
    user_config_dir=/etc/vsftpd/mysql.users.conf.d/
    [root@centos-152 vsftpd]# mkdir mysql.users.conf.d
    [root@centos-152 vsftpd]# cd mysql.users.conf.d/
    [root@centos-152 mysql.users.conf.d]# vim panda1
    [rootn@centos-152 mysql.users.conf.d]# cat panda1 
    anon_upload_enable=YES
    anon_mkdir_write_enable=YES


添加虚拟用户的目录

.. code-block:: bash

    [root@centos-152 vsftpd]# useradd -d /data/ftpuser -s /sbin/nologin ftpuser
    [root@centos-152 vsftpd]# chmod a-w /data/ftpuser/
    [root@centos-152 vsftpd]# mkdir /data/ftpuser/{pub,upload}
    [root@centos-152 vsftpd]# setfacl -m u:ftpuser:rwx /data/ftpuser/upload/
    [root@centos-152 vsftpd]# setfacl -m u:ftpuser:rx /data/ftpuser/pub/


测试
--------------------------------------------------------------------

测试前重启服务

.. code-block:: bash

    [root@centos-152 mysql.users.conf.d]# ftp 192.168.46.152
    Connected to 192.168.46.152 (192.168.46.152).
    220 (vsFTPd 3.0.2)
    Name (192.168.46.152:root): panda1
    331 Please specify the password.
    Password:
    230 Login successful.
    Remote system type is UNIX.
    Using binary mode to transfer files.
    ftp> pwd
    257 "/"
    ftp> cd upload
    250 Directory successfully changed.
    ftp> !ls
    panda1
    ftp> lcd /root
    Local directory now /root
    ftp> !ls
    anaconda-ks.cfg  anaconda-ks.cfg.bak  ansible  bigfile	bin  hosts.txt	localhost.localdomain.txt  q  test.sh
    ftp> put bigfile
    local: bigfile remote: bigfile
    227 Entering Passive Mode (192,168,46,152,163,95).
    150 Ok to send data.
    226 Transfer complete.
    1900544 bytes sent in 0.303 secs (6267.05 Kbytes/sec)
    ftp> quit
    221 Goodbye.
    [root@centos-152 mysql.users.conf.d]# ftp 192.168.46.152
    Connected to 192.168.46.152 (192.168.46.152).
    220 (vsFTPd 3.0.2)
    Name (192.168.46.152:root): panda2
    331 Please specify the password.
    Password:
    230 Login successful.
    Remote system type is UNIX.
    Using binary mode to transfer files.
    ftp> cd uploads
    550 Failed to change directory.
    ftp> cd upload
    250 Directory successfully changed.
    ftp> lcd /root
    Local directory now /root
    ftp> !ls
    anaconda-ks.cfg  anaconda-ks.cfg.bak  ansible  bigfile	bin  hosts.txt	localhost.localdomain.txt  q  test.sh
    ftp> put bigfile
    local: bigfile remote: bigfile
    227 Entering Passive Mode (192,168,46,152,46,63).
    550 Permission denied.
    ftp> quit
    221 Goodbye.

可以发现，panda1和panda2都是通过认证成功的用户，只是panda1有自己的额外配置才有了上传权限。
