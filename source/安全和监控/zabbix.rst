zabbix
======================================


安装
----------------------------------------

zabbix安装参考_

.. _zabbix安装参考: https://www.zabbix.com/download


.. code-block:: bash 

# 安装配置数据库
[root@centos-151 ~]# yum install mariadb-server  

[root@centos-151 ~]# systemctl start mariadb
[root@centos-151 ~]# mysql_secure_installation 

[root@centos-151 ~]# mysql -uroot -ppanda 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 10
Server version: 5.5.56-MariaDB MariaDB Server

Copyright (c) 2000, 2017, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> create database zabbix character set utf8 collate utf8_bin;
Query OK, 1 row affected (0.00 sec)

MariaDB [(none)]> grant all privileges on zabbix.* to zabbix@localhost identified by 'password';
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> exit
Bye

# 安装zabbix
[root@centos-151 ~]# rpm -i http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm
[root@centos-151 ~]# yum install zabbix-server-mysql zabbix-web-mysql zabbix-agent

# 导库
[root@centos-151 ~]# zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -ppassword zabbix

# 配置文件添加密码
[root@centos-151 ~]# vim /etc/zabbix/zabbix_server.conf 
DBPassword=password
# 修改时区信息
[root@centos-151 ~]# vim /etc/httpd/conf.d/zabbix.conf 
php_value date.timezone Asia/Shanghai
# 重启web
[root@centos-151 ~]# systemctl start httpd


图形安装配置
----------------------------------------

.. image:: /images/secure/zabbix-step1.png

.. image:: /images/secure/zabbix-step2.png

.. image:: /images/secure/zabbix-step3.png

.. image:: /images/secure/zabbix-step4.png

.. image:: /images/secure/zabbix-step5.png

.. image:: /images/secure/zabbix-step6.png
