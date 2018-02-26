mysql备份和恢复
=======================================


mysqldump备份还原
------------------------------------------

mysqldump主要选项
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

mysqldump备份还原案例
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    # 安装mariadb

    [root@localhost yum.repos.d]# yum install mariadb-server 
    [root@localhost yum.repos.d]# vim /etc/my.cnf
    # 如下2行到mysqld片段
    innodb_file_per_table
    log-bin

    # 启动
    [root@localhost yum.repos.d]# systemctl restart mariadb
    # 导入样例数据库
    [root@localhost ~]# mysql < hellodb_InnoDB.sql 

    # 备份数据
    [root@localhost ~]# mysqldump -A -F -E -R --single-transaction --master-data=1 --flush-privileges --triggers > all$(date +"%F_%T").sql

    # 模拟数据修改
    MariaDB [(none)]> use hellodb;
    MariaDB [hellodb]> delete from students ;
    MariaDB [hellodb]> create table t1(age int);

    # 锁定数据库
    MariaDB [hellodb]> flush tables with read lock;

    # 分析那些日志需要重做

    MariaDB [hellodb]> show master logs;
    +--------------------+-----------+
    | Log_name           | File_size |
    +--------------------+-----------+
    | mariadb-bin.000001 |       264 |
    | mariadb-bin.000002 |      7700 |
    | mariadb-bin.000003 |       290 |
    | mariadb-bin.000004 |       519 |
    +--------------------+-----------+
    4 rows in set (0.00 sec)
    [root@localhost ~]# head -n 25 all2018-02-23_21\:52\:18.sql
    # 25行中有如下一行
    CHANGE MASTER TO MASTER_LOG_FILE='mariadb-bin.000004', MASTER_LOG_POS=245;

    # 刷新日志
    MariaDB [hellodb]> flush logs;
    Query OK, 0 rows affected (0.02 sec)

    # 复制日志到特定的一个目录去
    [root@localhost ~]# mkdir /backup 
    [root@localhost ~]# cp /var/lib/mysql/mariadb-bin.000004 /backup/

    # 导出二进制日志为sql
    [root@localhost backup]# mysqlbinlog  mariadb-bin.000004  --start-position=245  >bin.sql
    [root@localhost backup]# vim bin.sql 
    # 注释掉误操作语句，使用--注释。
    --delete from students

    # 临时关闭日志记录
    MariaDB [hellodb]> set sql_log_bin=0;
    # 解锁
    MariaDB [hellodb]> unlock tables;
    # 恢复
    MariaDB [test]> source /root/all2018-02-23_21:52:18.sql
    MariaDB [test]> source /backup/bin.sql

    # 查看数据

    MariaDB [hellodb]> select * from students;
    +-------+---------------+-----+--------+---------+-----------+
    | StuID | Name          | Age | Gender | ClassID | TeacherID |
    +-------+---------------+-----+--------+---------+-----------+
    |     1 | Shi Zhongyu   |  22 | M      |       2 |         3 |
    |     2 | Shi Potian    |  22 | M      |       1 |         7 |
    |     3 | Xie Yanke     |  53 | M      |       2 |        16 |
    |     4 | Ding Dian     |  32 | M      |       4 |         4 |
    |     5 | Yu Yutong     |  26 | M      |       3 |         1 |
    |     6 | Shi Qing      |  46 | M      |       5 |      NULL |
    |     7 | Xi Ren        |  19 | F      |       3 |      NULL |
    |     8 | Lin Daiyu     |  17 | F      |       7 |      NULL |
    |     9 | Ren Yingying  |  20 | F      |       6 |      NULL |
    |    10 | Yue Lingshan  |  19 | F      |       3 |      NULL |
    |    11 | Yuan Chengzhi |  23 | M      |       6 |      NULL |
    |    12 | Wen Qingqing  |  19 | F      |       1 |      NULL |
    |    13 | Tian Boguang  |  33 | M      |       2 |      NULL |
    |    14 | Lu Wushuang   |  17 | F      |       3 |      NULL |
    |    15 | Duan Yu       |  19 | M      |       4 |      NULL |
    |    16 | Xu Zhu        |  21 | M      |       1 |      NULL |
    |    17 | Lin Chong     |  25 | M      |       4 |      NULL |
    |    18 | Hua Rong      |  23 | M      |       7 |      NULL |
    |    19 | Xue Baochai   |  18 | F      |       6 |      NULL |
    |    20 | Diao Chan     |  19 | F      |       7 |      NULL |
    |    21 | Huang Yueying |  22 | F      |       6 |      NULL |
    |    22 | Xiao Qiao     |  20 | F      |       1 |      NULL |
    |    23 | Ma Chao       |  23 | M      |       4 |      NULL |
    |    24 | Xu Xian       |  27 | M      |    NULL |      NULL |
    |    25 | Sun Dasheng   | 100 | M      |    NULL |      NULL |
    +-------+---------------+-----+--------+---------+-----------+
    25 rows in set (0.00 sec)

    # 启用sql_log_bin

    MariaDB [hellodb]> flush logs;
    MariaDB [hellodb]> set sql_log_bin=1;
    MariaDB [hellodb]> flush logs;


mysqldump恢复步骤整理
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

#. 完全备份
#. 模拟数据破坏
#. 发现问题，初步确定问题位置
#. 只读，并禁止网络访问
#. 查看完全备份位置，当前日志位置。确定出需要的二进制日志文件
#. 根据二进制文件生成sql文件并查找出故障sql语句，修改它。
#. 去除读锁
#. 临时禁用sql_log_bin,执行全备份脚本，执行二进制日志导出的sql语句
#. 开启sql_log_bin，恢复数据库访问
#. 有必要在做一次全备份

逻辑卷备份还原
------------------------------------------

样例： 

.. code-block:: bash 

  # 添加硬盘，添加逻辑卷配置。
  [root@localhost yum.repos.d]# lsblk
  NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
  sda               8:0    0  200G  0 disk 
  ├─sda1            8:1    0    1G  0 part /boot
  └─sda2            8:2    0  199G  0 part 
    ├─centos-root 253:0    0   50G  0 lvm  /
    ├─centos-swap 253:1    0    2G  0 lvm  [SWAP]
    └─centos-home 253:2    0  147G  0 lvm  /home
  sr0              11:0    1  8.1G  0 rom  /mnt/cdrom

  [root@localhost yum.repos.d]# for i in `find /sys/devices -name scan` ; do echo '- - -' > $i ; done;
  [root@localhost yum.repos.d]# lsblk
  NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
  sda               8:0    0  200G  0 disk 
  ├─sda1            8:1    0    1G  0 part /boot
  └─sda2            8:2    0  199G  0 part 
    ├─centos-root 253:0    0   50G  0 lvm  /
    ├─centos-swap 253:1    0    2G  0 lvm  [SWAP]
    └─centos-home 253:2    0  147G  0 lvm  /home
  sdb               8:16   0   10G  0 disk 
  sr0              11:0    1  8.1G  0 rom  /mnt/cdrom
  [root@localhost yum.repos.d]# fdisk /dev/sdb
  Welcome to fdisk (util-linux 2.23.2).

  Changes will remain in memory only, until you decide to write them.
  Be careful before using the write command.

  Device does not contain a recognized partition table
  Building a new DOS disklabel with disk identifier 0x42436c93.

  Command (m for help): n
  Partition type:
    p   primary (0 primary, 0 extended, 4 free)
    e   extended
  Select (default p): p
  Partition number (1-4, default 1): 
  First sector (2048-20971519, default 2048): 
  Using default value 2048
  Last sector, +sectors or +size{K,M,G} (2048-20971519, default 20971519): +2G
  Partition 1 of type Linux and of size 2 GiB is set

  Command (m for help): n  
  Partition type:
    p   primary (1 primary, 0 extended, 3 free)
    e   extended
  Select (default p): p
  Partition number (2-4, default 2): 
  First sector (4196352-20971519, default 4196352): 
  Using default value 4196352
  Last sector, +sectors or +size{K,M,G} (4196352-20971519, default 20971519): +1G
  Partition 2 of type Linux and of size 1 GiB is set

  Command (m for help): p

  Disk /dev/sdb: 10.7 GB, 10737418240 bytes, 20971520 sectors
  Units = sectors of 1 * 512 = 512 bytes
  Sector size (logical/physical): 512 bytes / 512 bytes
  I/O size (minimum/optimal): 512 bytes / 512 bytes
  Disk label type: dos
  Disk identifier: 0x42436c93

    Device Boot      Start         End      Blocks   Id  System
  /dev/sdb1            2048     4196351     2097152   83  Linux
  /dev/sdb2         4196352     6293503     1048576   83  Linux

  Command (m for help): t
  Partition number (1,2, default 2): 2
  Hex code (type L to list all codes): 8e
  Changed type of partition 'Linux' to 'Linux LVM'

  Command (m for help): t
  Partition number (1,2, default 2): 1
  Hex code (type L to list all codes): 8e
  Changed type of partition 'Linux' to 'Linux LVM'

  Command (m for help): w
  The partition table has been altered!

  Calling ioctl() to re-read partition table.
  Syncing disks.
  [root@localhost yum.repos.d]# partprobe
  Warning: Unable to open /dev/sr0 read-write (Read-only file system).  /dev/sr0 has been opened read-only.
  [root@localhost yum.repos.d]# lsblk
  NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
  sda               8:0    0  200G  0 disk 
  ├─sda1            8:1    0    1G  0 part /boot
  └─sda2            8:2    0  199G  0 part 
    ├─centos-root 253:0    0   50G  0 lvm  /
    ├─centos-swap 253:1    0    2G  0 lvm  [SWAP]
    └─centos-home 253:2    0  147G  0 lvm  /home
  sdb               8:16   0   10G  0 disk 
  ├─sdb1            8:17   0    2G  0 part 
  └─sdb2            8:18   0    1G  0 part 
  sr0              11:0    1  8.1G  0 rom  /mnt/cdrom


  [root@localhost yum.repos.d]# lvcreate -L 2G -n lv_mysql_data vg_data
    Logical volume "lv_mysql_data" created.
  [root@localhost yum.repos.d]# lvcreate -l 40%Free -n lv_mysql_log vg_data
    Logical volume "lv_mysql_log" created.

  [root@localhost yum.repos.d]# mkdir /data/{mysqldata,log} -pv 

  [root@localhost yum.repos.d]# mkfs.xfs /dev/mapper/vg_data-lv_mysql_data
  [root@localhost yum.repos.d]# mkfs.xfs /dev/mapper/vg_data-lv_mysql_log

  [root@localhost yum.repos.d]# mount /dev/mapper/vg_data-lv_mysql_data  /data/mysqldata/
  [root@localhost yum.repos.d]# mount /dev/mapper/vg_data-lv_mysql_log /data/mysqllog/
  [root@localhost yum.repos.d]# tail -n 2 /etc/mtab >> /etc/fstab

  [root@localhost yum.repos.d]# chown -R mysql.mysql /data/

  [root@localhost yum.repos.d]# vim /etc/my.cnf
  # 修改如下2行
  datadir=/data/mysqldata
  log-bin=/data/mysqllog/mysql-bin

  # 重启服务
  [root@localhost yum.repos.d]# systemctl restart mariadb

  # 导入样例数据
  [root@localhost ~]# mysql < hellodb_InnoDB.sql 

  # 查看需要的日志文件
  MariaDB [(none)]> show binary logs;
  +------------------+-----------+
  | Log_name         | File_size |
  +------------------+-----------+
  | mysql-bin.000001 |     30379 |
  | mysql-bin.000002 |   1038814 |
  | mysql-bin.000003 |      7655 |
  +------------------+-----------+
  3 rows in set (0.00 sec)

  MariaDB [(none)]> flush tables with read lock;
  Query OK, 0 rows affected (0.00 sec)

  MariaDB [(none)]> flush logs;
  Query OK, 0 rows affected (0.28 sec)

  MariaDB [(none)]> show master logs;
  +------------------+-----------+
  | Log_name         | File_size |
  +------------------+-----------+
  | mysql-bin.000001 |     30379 |
  | mysql-bin.000002 |   1038814 |
  | mysql-bin.000003 |      7698 |
  | mysql-bin.000004 |       245 |
  +------------------+-----------+
  4 rows in set (0.00 sec)
  [root@localhost ~]# mysql -e 'show master logs' >> /backup/master.pos
  [root@localhost ~]# cat /backup/master.pos
  Log_name	File_size
  mysql-bin.000001	30379
  mysql-bin.000002	1038814
  mysql-bin.000003	7698
  mysql-bin.000004	245

  # 创建快照
  [root@localhost ~]# lvcreate -n lv_mysql_data_snap -l 100%Free -s -p r  /dev/mapper/vg_data-lv_mysql_data 

  # 是否读锁 
  MariaDB [(none)]> unlock tables;
  Query OK, 0 rows affected (0.00 sec)

  # 模拟一些操作
  MariaDB [(none)]> delete from hellodb.students;
  Query OK, 25 rows affected (0.07 sec)

  # 挂载快照卷
  [root@localhost ~]# mkdir /mnt/snap 
  [root@localhost ~]# mount -o nouuid,norecovery /dev/vg_data/lv_mysql_data_snap   /mnt/snap
  mount: /dev/mapper/vg_data-lv_mysql_data_snap is write-protected, mounting read-only

  # 开始备份工作，有必要推送到远端。
  [root@localhost ~]# cp -a /mnt/snap/ /backup/

  # 删除快照卷
  [root@localhost ~]# umount /mnt/snap
  [root@localhost ~]# lvremove /dev/vg_data/lv_mysql_data_snap 
  Do you really want to remove active logical volume vg_data/lv_mysql_data_snap? [y/n]: y
    Logical volume "lv_mysql_data_snap" successfully removed

  # 这里数据库被删除的一些模拟操作
  [root@localhost ~]# rm -rf /data/mysqldata/*

  # 复制备份文件回来
  [root@localhost ~]# cp /backup/snap/* /data/mysqldata/ -a
  [root@localhost ~]# chown  mysql.mysql /data/mysqldata/ -R 
  [root@localhost ~]# systemctl start mariadb
  MariaDB [(none)]> flush tables with read lock;
  Query OK, 0 rows affected (0.00 sec)


  # 在使用二进制恢复到最新时间
  MariaDB [(none)]> show master logs;
  +------------------+-----------+
  | Log_name         | File_size |
  +------------------+-----------+
  | mysql-bin.000001 |     30379 |
  | mysql-bin.000002 |   1038814 |
  | mysql-bin.000003 |      7698 |
  | mysql-bin.000004 |       423 |
  +------------------+-----------+
  4 rows in set (0.00 sec)
  [root@localhost ~]# cat /backup/master.pos 
  Log_name	File_size
  mysql-bin.000001	30379
  mysql-bin.000002	1038814
  mysql-bin.000003	7698
  mysql-bin.000004	245

  [root@localhost ~]# mysqlbinlog --start-position=245 /backup/mysql-bin.000004  >bin.sql

  MariaDB [(none)]> unlock tables;
  MariaDB [(none)]> set sql_log_bin=0 
  MariaDB [(none)]> source /backup/bin.sql
  MariaDB [(none)]> set sql_log_bin=1
  #测试正常
  MariaDB [hellodb]> select * from students;

基于逻辑卷的备份还原主要步骤
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

#. 数据和日志分散开到各自的逻辑卷上去,配置文件修改。
#. 锁定表
#. 记录日志文件和位置
#. 创建快照
#. 释放锁 
#. copy文件，删除快照卷
#. 模拟破坏数据
#. copy原有的备份过来，启动服务后里面加读锁
#. 分析日志，set sql_log_bin=0 并提取出需要redo的sql
#. 释放锁，执行sql
#. set sql_log_bin=0 恢复用户访问


基于perconda的mysql备份还原
------------------------------------------

这是使用2个机器， 一个机器备份， 在另一个机器还原。

安装配置mariadb
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

  [root@localhost ~]# yum install mariadb-server 
  [root@localhost ~]# vim /etc/my.cnf
  # 在mysqld片段添加如下2行
  log-bin
  innodb_file_per_table
  [root@localhost ~]# systemctl restart mariadb


XtraBackup下载
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

这个需要在2个机器上都操作。

XtraBackup_

.. _XtraBackup: https://www.percona.com/downloads/XtraBackup/LATEST/

.. code-block:: bash  

  [root@localhost ~]# cd /usr/src
  [root@localhost src]# wget https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-2.4.9/binary/redhat/7/x86_64/percona-xtrabackup-24-2.4.9-1.el7.x86_64.rpm

XtraBackup安装
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

这个需要在2个机器上都操作。

.. code-block:: bash  

  [root@localhost src]# yum install percona-xtrabackup-24-2.4.9-1.el7.x86_64.rpm 
  [root@localhost src]# rpm -ql percona-xtrabackup-24
  /usr/bin/innobackupex
  /usr/bin/xbcloud
  /usr/bin/xbcloud_osenv
  /usr/bin/xbcrypt
  /usr/bin/xbstream
  /usr/bin/xtrabackup
  /usr/share/doc/percona-xtrabackup-24-2.4.9
  /usr/share/doc/percona-xtrabackup-24-2.4.9/COPYING
  /usr/share/man/man1/innobackupex.1.gz
  /usr/share/man/man1/xbcrypt.1.gz
  /usr/share/man/man1/xbstream.1.gz
  /usr/share/man/man1/xtrabackup.1.gz

.. note:: 如果安装失败，请确保配置了epel源。

开始备份
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

  # 查看日志信息
  MariaDB [(none)]> show master logs;
  +--------------------+-----------+
  | Log_name           | File_size |
  +--------------------+-----------+
  | mariadb-bin.000001 |       245 |
  +--------------------+-----------+
  1 row in set (0.00 sec)

  # 备份
  [root@localhost ~]# innobackupex --user=root /backup
  # 查看备份信息
  [root@localhost ~]# ls /backup/2018-02-24_19-37-14/
  backup-my.cnf  ibdata1  mysql  performance_schema  test  xtrabackup_binlog_info  xtrabackup_checkpoints  xtrabackup_info  xtrabackup_logfile

  # 模拟第一天操作
  [root@localhost ~]#  wget http://download.linuxpanda.tech/mysql/hellodb_InnoDB.sql
  MariaDB [hellodb]> source /root/hellodb_InnoDB.sql
  MariaDB [hellodb]> flush logs;
  MariaDB [hellodb]> flush logs;
  MariaDB [hellodb]> flush logs;
  MariaDB [hellodb]> flush logs;
  # 增量备份
  [root@localhost ~]# innobackupex --incremental /backup/day1  --incremental-basedir=/backup/2018-02-24_19-37-14/
  # 模拟第二天操作
  MariaDB [hellodb]> create table t1(id int auto_increment primary key ,name varchar(20));
  MariaDB [hellodb]> insert into t1 (name) values ("zhaojiedi"),("zhaojiedi1992");


  # 复制到远程主机
  [root@localhost ~]# scp -r -p /backup    192.168.46.152:/

  # 在另一个机器恢复

  # 整理第一次的全备份
  [root@localhost ~]# innobackupex  --apply-log  --redo-only /backup/2018-02-24_19-37-14/
  # 整理第二次的增量备份到全备份上去
  [root@localhost ~]# innobackupex  --apply-log  --redo-only  /backup/2018-02-24_19-37-14/ --incremental-dir=/backup/day1/2018-02-24_20-09-38/

  [root@localhost ~]# innobackupex  --copy-back /backup/2018-02-24_19-37-14/
  [root@localhost ~]# chown mysql.mysql /var/lib/mysql/ -R 
  [root@localhost ~]# systemctl restart mariadb

  # 验证下，这个时候只是恢复到增量备份位置，后续日志还没有恢复过来
  [root@localhost ~]# mysql
  Welcome to the MariaDB monitor.  Commands end with ; or \g.
  Your MariaDB connection id is 2
  Server version: 5.5.56-MariaDB MariaDB Server

  Copyright (c) 2000, 2017, Oracle, MariaDB Corporation Ab and others.

  Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

  MariaDB [(none)]> use hellodb;
  Reading table information for completion of table and column names
  You can turn off this feature to get a quicker startup with -A

  Database changed
  MariaDB [hellodb]> show tables;
  +-------------------+
  | Tables_in_hellodb |
  +-------------------+
  | classes           |
  | coc               |
  | courses           |
  | scores            |
  | students          |
  | teachers          |
  | toc               |
  +-------------------+
  7 rows in set (0.00 sec)

  MariaDB [hellodb]> show master logs;
  +--------------------+-----------+
  | Log_name           | File_size |
  +--------------------+-----------+
  | mariadb-bin.000001 |      7700 |
  | mariadb-bin.000002 |       290 |
  | mariadb-bin.000003 |       290 |
  | mariadb-bin.000004 |       290 |
  | mariadb-bin.000005 |       855 |
  +--------------------+-----------+
  5 rows in set (0.00 sec)


  [root@localhost ~]# cat /backup/day1/2018-02-24_20-09-38/xtrabackup_binlog_info 
  mariadb-bin.000005	245

  # 查看日志后， 整理sql文件
  [root@localhost ~]# scp bin.sql 192.168.46.152:/backup/
  # 远程主机指定下
  [root@localhost ~]# mysql < /backup/bin.sql 
  # 测试

  MariaDB [(none)]> use hellodb;
  Reading table information for completion of table and column names
  You can turn off this feature to get a quicker startup with -A

  Database changed
  MariaDB [hellodb]> show tables;
  +-------------------+
  | Tables_in_hellodb |
  +-------------------+
  | classes           |
  | coc               |
  | courses           |
  | scores            |
  | students          |
  | t1                |
  | teachers          |
  | toc               |
  +-------------------+
  8 rows in set (0.00 sec)


单表备份
---------------------------------------------

perconda的单表备份不能在5.5的数据库上使用的。这里使用10系列的数据库。

.. code-block:: bash 

  [root@localhost yum.repos.d]# vim mariadb.repo 
  [root@localhost yum.repos.d]# cat mariadb.repo
  [mariadb]
  name=mariadb
  baseurl=http://mirrors.aliyun.com/mariadb/mariadb-10.2.13/yum/rhel74-amd64/
  enabled=1
  gpgcheck=0

  [root@localhost yum.repos.d]# yum clean && yum makecache;
  [root@localhost yum.repos.d]# yum info MariaDB-server
  [root@localhost yum.repos.d]# yum install MariaDB-server
  [root@localhost network-scripts]# systemctl restart mariadb
  [root@localhost ~]#  wget http://download.linuxpanda.tech/mysql/hellodb_InnoDB.sql

  [root@localhost network-scripts]# mysql < hellodb_InnoDB.sql

  [root@gitlab mysql]# yum install  percona-xtrabackup-24-2.4.9-1.el7.x86_64.rpm 
  [root@localhost network-scripts]# innobackupex  --include='hellodb.students' /backup
  [root@localhost network-scripts]# ll /backup/2018-02-24_22-30-34/
  total 12308
  -rw-r----- 1 root root      424 Feb 24 22:30 backup-my.cnf
  drwxr-x--- 2 root root       46 Feb 24 22:30 hellodb
  -rw-r----- 1 root root     2795 Feb 24 22:30 ib_buffer_pool
  -rw-r----- 1 root root 12582912 Feb 24 22:30 ibdata1
  drwxr-x--- 2 root root       20 Feb 24 22:30 test
  -rw-r----- 1 root root      113 Feb 24 22:30 xtrabackup_checkpoints
  -rw-r----- 1 root root      425 Feb 24 22:30 xtrabackup_info
  -rw-r----- 1 root root     2560 Feb 24 22:30 xtrabackup_logfile
  [root@localhost network-scripts]# mysql -e 'show create table hellodb.students' >>/backup/student.sql
  [root@localhost network-scripts]# cat /backup/student.sql
  Table	Create Table
  students	CREATE TABLE `students` (\n  `StuID` int(10) unsigned NOT NULL AUTO_INCREMENT,\n  `Name` varchar(50) NOT NULL,\n  `Age` tinyint(3) unsigned NOT NULL,\n  `Gender` enum('F','M') NOT NULL,\n  `ClassID` tinyint(3) unsigned DEFAULT NULL,\n  `TeacherID` int(10) unsigned DEFAULT NULL,\n  PRIMARY KEY (`StuID`)\n) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8

  # 模拟破坏表

  MariaDB [(none)]> drop table hellodb.students;
  Query OK, 0 rows affected (0.30 sec)

  # 开始还原
  [root@localhost network-scripts]# innobackupex  --apply-log  --export /backup/2018-02-24_22-30-34/

  [root@localhost network-scripts]# ll /backup/2018-02-24_22-30-34/hellodb/
  total 120
  -rw-r--r-- 1 root root   640 Feb 24 22:35 students.cfg
  -rw-r----- 1 root root 16384 Feb 24 22:35 students.exp
  -rw-r----- 1 root root  1208 Feb 24 22:30 students.frm
  -rw-r----- 1 root root 98304 Feb 24 22:30 students.ibd
  [root@localhost network-scripts]# sed -n -r 's@\\n@@gp' /backup/student.sql 
  CREATE TABLE `students` (  `StuID` int(10) unsigned NOT NULL AUTO_INCREMENT,  `Name` varchar(50) NOT NULL,  `Age` tinyint(3) unsigned NOT NULL,  `Gender` enum('F','M') NOT NULL,  `ClassID` tinyint(3) unsigned DEFAULT NULL,  `TeacherID` int(10) unsigned DEFAULT NULL,  PRIMARY KEY (`StuID`)) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8
  [root@localhost network-scripts]# cat /backup/student.sql 
  use hellodb;
  CREATE TABLE `students` (  `StuID` int(10) unsigned NOT NULL AUTO_INCREMENT,  `Name` varchar(50) NOT NULL,  `Age` tinyint(3) unsigned NOT NULL,  `Gender` enum('F','M') NOT NULL,  `ClassID` tinyint(3) unsigned DEFAULT NULL,  `TeacherID` int(10) unsigned DEFAULT NULL,  PRIMARY KEY (`StuID`)) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8
  [root@localhost network-scripts]# mysql < /backup/student.sql

  MariaDB [hellodb]> alter table students discard tablespace;
  [root@localhost ~]# cp /backup/2018-02-24_22-30-34/hellodb/students.{exp,cfg,ibd} /var/lib/mysql/hellodb/
  [root@localhost ~]# chown -R mysql.mysql /var/lib/mysql/

  MariaDB [hellodb]> alter table students import tablespace;
  # 检查数据
  MariaDB [hellodb]> select * from students;
  +-------+---------------+-----+--------+---------+-----------+
  | StuID | Name          | Age | Gender | ClassID | TeacherID |
  +-------+---------------+-----+--------+---------+-----------+
  |     1 | Shi Zhongyu   |  22 | M      |       2 |         3 |
  |     2 | Shi Potian    |  22 | M      |       1 |         7 |
  |     3 | Xie Yanke     |  53 | M      |       2 |        16 |
  |     4 | Ding Dian     |  32 | M      |       4 |         4 |
  |     5 | Yu Yutong     |  26 | M      |       3 |         1 |
  |     6 | Shi Qing      |  46 | M      |       5 |      NULL |
  |     7 | Xi Ren        |  19 | F      |       3 |      NULL |
  |     8 | Lin Daiyu     |  17 | F      |       7 |      NULL |
  |     9 | Ren Yingying  |  20 | F      |       6 |      NULL |
  |    10 | Yue Lingshan  |  19 | F      |       3 |      NULL |
  |    11 | Yuan Chengzhi |  23 | M      |       6 |      NULL |
  |    12 | Wen Qingqing  |  19 | F      |       1 |      NULL |
  |    13 | Tian Boguang  |  33 | M      |       2 |      NULL |
  |    14 | Lu Wushuang   |  17 | F      |       3 |      NULL |
  |    15 | Duan Yu       |  19 | M      |       4 |      NULL |
  |    16 | Xu Zhu        |  21 | M      |       1 |      NULL |
  |    17 | Lin Chong     |  25 | M      |       4 |      NULL |
  |    18 | Hua Rong      |  23 | M      |       7 |      NULL |
  |    19 | Xue Baochai   |  18 | F      |       6 |      NULL |
  |    20 | Diao Chan     |  19 | F      |       7 |      NULL |
  |    21 | Huang Yueying |  22 | F      |       6 |      NULL |
  |    22 | Xiao Qiao     |  20 | F      |       1 |      NULL |
  |    23 | Ma Chao       |  23 | M      |       4 |      NULL |
  |    24 | Xu Xian       |  27 | M      |    NULL |      NULL |
  |    25 | Sun Dasheng   | 100 | M      |    NULL |      NULL |
  +-------+---------------+-----+--------+---------+-----------+
  25 rows in set (0.00 sec)


