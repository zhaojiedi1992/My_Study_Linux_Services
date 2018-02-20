centos6lamp的yum安装
==============================================

安装软件
--------------------------------------------------

.. code-block:: bash

    [root@localhost ~]$yum install mysql-server mysql php-fpm php-mysql httpd mod_proxy_fcgi

启动服务
-------------------------------------------------------------

.. code-block:: bash

    [root@localhost ~]$service php-fpm start
    [root@localhost ~]$chkconfig php-fpm on
    [root@localhost ~]$service mysqld start
    [root@localhost ~]$chkconfig mysqld on
    [root@localhost ~]$service httpd restart
    [root@localhost ~]$chkconfig httpd on
    
    [root@localhost ~]$netstat -tunlp
    Active Internet connections (only servers)
    Proto Recv-Q Send-Q Local Address               Foreign Address             State       PID/Program name   
    tcp        0      0 127.0.0.1:9000              0.0.0.0:*                   LISTEN      47172/php-fpm       
    tcp        0      0 0.0.0.0:3306                0.0.0.0:*                   LISTEN      47373/mysqld        
    tcp        0      0 0.0.0.0:22                  0.0.0.0:*                   LISTEN      1833/sshd           
    tcp        0      0 127.0.0.1:25                0.0.0.0:*                   LISTEN      1347/master         
    tcp        0      0 :::80                       :::*                        LISTEN      47415/httpd         
    tcp        0      0 :::22                       :::*                        LISTEN      1833/sshd           
    tcp        0      0 ::1:25                      :::*                        LISTEN      1347/master

关联http和php
----------------------------------------------------

.. code-block:: bash

    [root@localhost httpd]$vim conf.d/fcgi.conf 
    [root@localhost httpd]$cat conf.d/fcgi.conf
    DirectoryIndex index.php
    ProxyRequests Off
    ProxyPassMatch ^/(.*\.php)$ fcgi://127.0.0.1:9000/var/www/html/$1
    [root@localhost httpd]$service httpd restart
    [root@localhost httpd]$cd /var/www/html/
    [root@localhost html]$ls
    [root@localhost html]$vim index.php
    [root@localhost html]$cat index.php 
    <?php

    phpinfo();

    ?>
    [root@localhost conf]$curl localhost

应用测试
------------------------------------------------------------------------------------

.. code-block:: bash

    [root@localhost ~]$cd /var/www/html/
    [root@localhost html]$git clone https://gitee.com/ComsenzDiscuz/DiscuzX
    Initialized empty Git repository in /var/www/html/DiscuzX/.git/
    remote: Counting objects: 7071, done.
    remote: Compressing objects: 100% (4813/4813), done.
    remote: Total 7071 (delta 2496), reused 6604 (delta 2209)
    Receiving objects: 100% (7071/7071), 11.96 MiB | 955 KiB/s, done.
    Resolving deltas: 100% (2496/2496), done.
    [root@localhost html]$ls
    a.html  DiscuzX  index.php
    [root@localhost html]$cd DiscuzX/
    [root@localhost DiscuzX]$ls
    readme  README.md  upload  utility
    [root@localhost DiscuzX]$cd upload/
    [root@localhost upload]$pwd
    /var/www/html/DiscuzX/upload
    [root@localhost upload]$cd ..
    [root@localhost DiscuzX]$ls
    readme  README.md  upload  utility
    [root@localhost DiscuzX]$setfacl -R -m "u:apache:rwx" ./
    [root@localhost DiscuzX]$mysql_secure_installation 

打开浏览器输入如下地址： http://192.168.1.107/DiscuzX/upload/ 进行制定就可以了。不需要创建数据库，自动创建的。效果图：

.. image:: /images/web/discuz.png

清除权限
------------------------------------------------------------------------------------

.. code-block:: bash

    [root@localhost DiscuzX]$setfacl -R -b ./

测试性能
----------------------------------------------------------------

.. code-block:: bash

    [root@localhost DiscuzX]$ab -c 100 -n 1000 http://192.168.1.107/DiscuzX/upload/
    Requests per second:    41.67 [#/sec] (mean)

xcache加速
----------------------------------------------------------------

.. code-block:: bash

    [root@localhost DiscuzX]$yum search xcache-admin
    [root@localhost DiscuzX]$service httpd restart 
    [root@localhost DiscuzX]$service php-fpm restart
    [root@localhost DiscuzX]$ab -c 100 -n 1000 http://192.168.1.107/DiscuzX/upload/
    Requests per second:    126.14 [#/sec] (mean)

