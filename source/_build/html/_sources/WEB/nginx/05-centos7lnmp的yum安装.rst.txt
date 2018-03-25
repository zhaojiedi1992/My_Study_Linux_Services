centos7 lnmp的yum安装
===========================================

安装
--------------------

.. code-block:: bash 

    [root@localhost ~]# yum install nginx mariadb-server php-fpm php-mbstring mysql-php

下载pma
----------------------------

.. code-block:: bash

    [root@localhost ~]# cd /usr/src/
    [root@localhost src]#wget http://download.linuxpanda.tech/lamp/wordpress-4.9.1-zh_CN.tar.gz
    [root@localhost src]# tar xf wordpress-4.9.1-zh_CN.tar.gz -C /usr/share/nginx/
    [root@localhost src]# ln -s wordpress wp


配置
---------------------------------

.. code-block:: bash

    [root@localhost src]# vim /etc/nginx/conf.d/vhosts.conf 
    [root@localhost src]# cat /etc/nginx/conf.d/vhosts.conf
    server { 
        server_name pma.linuxpanda.tech;
        root /usr/share/nginx/pma;
    }

# 添加扩展
[root@localhost wp]# vim /etc/php.ini
extension=mysql.so

启动服务
---------------------------------

.. code-block:: bash

    [root@localhost src]# systemctl start php-fpm
    [root@localhost src]# systemctl restart nginx

访问配置
---------------------------------

在浏览器输入172.18.46.151/index.php即可访问。需要一些设置的。

