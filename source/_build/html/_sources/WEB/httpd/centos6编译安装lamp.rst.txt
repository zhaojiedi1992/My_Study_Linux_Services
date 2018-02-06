centos6编译安装lamp
===========================================


下载文件
-------------------------------------------------------------------------------------

.. code-block:: bash

    [root@localhost ~]$cd /usr/src
    [root@localhost src]$ls
    debug  kernels
    [root@localhost src]$mkdir lamp
    [root@localhost src]$cd lamp/
    [root@localhost lamp]$pwd
    /usr/src/lamp
    [root@localhost lamp]$wget http://mirrors.tuna.tsinghua.edu.cn/apache//httpd/httpd-2.4.29.tar.bz2
    [root@localhost lamp]$wget http://mirrors.tuna.tsinghua.edu.cn/apache//apr/apr-1.6.3.tar.bz2
    [root@localhost lamp]$wget http://mirrors.tuna.tsinghua.edu.cn/apache//apr/apr-util-1.6.1.tar.bz2
    [root@localhost lamp]$wget http://hk2.php.net/get/php-7.2.1.tar.bz2/from/this/mirror -O php-7.2.1.tar.bz2
    [root@localhost lamp]$wget https://downloads.mariadb.org/interstitial/mariadb-10.2.12/source/mariadb-10.2.12.tar.gz/from/http%3A//mirrors.neusoft.edu.cn/mariadb/ -O mariadb-10.2.12.tar.gz
    [root@localhost lamp]$wget https://files.phpmyadmin.net/phpMyAdmin/4.7.7/phpMyAdmin-4.7.7-all-languages.zip

    [root@localhost lamp]$ll
    total 103312
    -rw-r--r--. 1 root root   854100 Oct 23 01:33 apr-1.6.3.tar.bz2
    -rw-r--r--. 1 root root   428595 Oct 23 01:33 apr-util-1.6.1.tar.bz2
    -rw-r--r--. 1 root root  6567926 Oct 21 03:39 httpd-2.4.29.tar.bz2
    -rw-r--r--. 1 root root 72818636 Jan  3 21:48 mariadb-10.2.12.tar.gz
    -rw-r--r--. 1 root root 14980278 Jan  3 06:50 php-7.2.1.tar.bz2
    -rw-r--r--.  1 root   root  11589684 Jan 30  2018 phpMyAdmin-4.7.7-all-languages.zip


安装必要的包文件
-----------------------------------------------------------------

.. code-block:: bash

    [root@localhost ~]$yum groupinstall "development tools" -y
    [root@localhost yum.repos.d]$yum install pcre-devel openssl-devel expat-devel 
    [root@localhost yum.repos.d]$yum install  ncurses-devel
    [root@localhost yum.repos.d]$yum installl libxml2-devel bzip2-devel libmcrypt-devel

用户的创建
-----------------------------------------------------------------

.. code-block:: bash

    [root@localhost lamp]$useradd apache -r -s /sbin/nologin -c "Apache"
    [root@localhost lamp]$useradd mysql -r -s /sbin/nologin -c "mysql"




httpd编译安装
-----------------------------------------------------------------

.. code-block:: bash

    [root@localhost lamp]$tar xf httpd-2.4.29.tar.bz2 
    [root@localhost lamp]$tar xf apr-1.6.3.tar.bz2 
    [root@localhost lamp]$tar xf apr-util-1.6.1.tar.bz2 
    [root@localhost lamp]$mv apr-1.6.3 httpd-2.4.29/srclib/apr
    [root@localhost lamp]$mv apr-util-1.6.1 httpd-2.4.29/srclib/apr-util
    [root@localhost lamp]$cd httpd-2.4.29
    [root@localhost lamp]$./configure \
    --prefix=/usr/local/httpd24 \
    --enable-so --enable-ssl \
    --enable-cgi \
    --enable-rewrite \
    --with-zlib \
    --with-pcre \
    --with-included-apr \
    --enable-modules=most \
    --enable-mpms-shared=all \
    --with-mpm=prefork

    [root@localhost httpd-2.4.29]$log=/root/apache.make.log ; date >> $log ; make && make install ; date >> $log

.. note:: 这里如果出错，请重点关注缺少.h的包，安装对应的devel包，比如如果报找不到expat.h，
            使用yum search expat先搜索开发包，安装expat-devel即可。

测试http和后续
-----------------------------------------------------------------

.. code-block:: text

    [root@localhost ~]$cd /usr/local/httpd24/bin  
    [root@localhost bin]$echo 'PATH=/usr/local/httpd24/bin:$PATH' >> /etc/profile.d/lamp.sh
    [root@localhost bin]$source /etc/profile.d/lamp.sh
    [root@localhost bin]sed -i 's@User daemon@User apache' ../conf/httpd.conf
    [root@localhost bin]sed -i 's@Group daemon@Group apache' ../conf/httpd.conf
    [root@localhost bin]$apachectl start
    AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using localhost.localdomain. Set the 'ServerName' directive globally to suppress this message
    [root@localhost bin]$ss -tul
    Netid State      Recv-Q Send-Q                           Local Address:Port                               Peer Address:Port   
    tcp   LISTEN     0      128                                         :::http                                         :::*       
    tcp   LISTEN     0      128                                         :::ssh                                          :::*       
    tcp   LISTEN     0      128                                          *:ssh                                           *:*       
    tcp   LISTEN     0      100                                        ::1:smtp                                         :::*       
    tcp   LISTEN     0      100                                  127.0.0.1:smtp                                          *:*       
    [root@localhost httpd24]$ps aux |grep httpd
    root      79586  0.0  0.1  72192  2032 ?        Ss   00:55   0:00 /usr/local/httpd24/bin/httpd -k start
    daemon    79587  0.0  0.0  72192  1416 ?        S    00:55   0:00 /usr/local/httpd24/bin/httpd -k start
    daemon    79588  0.0  0.0  72192  1416 ?        S    00:55   0:00 /usr/local/httpd24/bin/httpd -k start
    daemon    79589  0.0  0.0  72192  1416 ?        S    00:55   0:00 /usr/local/httpd24/bin/httpd -k start
    daemon    79590  0.0  0.0  72192  1416 ?        S    00:55   0:00 /usr/local/httpd24/bin/httpd -k start
    daemon    79591  0.0  0.0  72192  1416 ?        S    00:55   0:00 /usr/local/httpd24/bin/httpd -k start
    root      79621  0.0  0.0 103324   888 pts/2    R+   01:01   0:00 grep --color httpd
    [root@localhost bin]$ss -tunl |grep :80
    tcp    LISTEN     0      128                   :::80                   :::* 
    [root@localhost httpd24]$curl localhost
    <html><body><h1>It works!</h1></body></html>

mariadb编译安装
-----------------------------------------------------------------

.. code-block:: bash

    [root@localhost httpd24]$cd /usr/src/lamp
    [root@localhost lamp]$ls
    apr-1.6.3.tar.bz2       httpd-2.4.29          mariadb-10.2.12.tar.gz  wordpress-4.9.1-zh_CN.tar.gz
    apr-util-1.6.1.tar.bz2  httpd-2.4.29.tar.bz2  php-7.2.1.tar.bz2
    [root@localhost lamp]$tar xf mariadb-10.2.12.tar.gz 
    [root@localhost lamp]$cd mariadb-10.2.12
    [root@localhost lamp]$cmake . \
    -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
    -DMYSQL_DATADIR=/data/mysql/data \
    -DSYSCONFDIR=/etc \
    -DMYSQL_USER=mysql \
    -DWITH_INNOBASE_STORAGE_ENGINE=1 \
    -DWITH_ARCHIVE_STORAGE_ENGINE=1 \
    -DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
    -DWITH_READLINE=1 \
    -DWITH_SSL=system \
    -DWITH_ZLIB=system \
    -DWITH_LIBWRAP=0 \
    -DMYSQL_UNIX_ADDR=/data/mysql/mysql.sock \
    -DDEFAULT_CHARSET=utf8 \
    -DDEFAULT_COLLATION=utf8_general_ci \
    -DENABLED_LOCAL_INFILE=1 \
    -DWITH_PARTITION_STORAGE_ENGINE=1 \
    -DWITH_DEBUG=0 \
    -DWITHOUT_MROONGA_STORAGE_ENGINE=1 

    [root@localhost mariadb-10.2.12]$log=/root/mariadb.make.log ; date >> $log ; make -j 4 && make install ; date >> $log
    [root@localhost mariadb-10.2.12]$cat /root/mariadb.make.log 
    Tue Jan 30 01:33:00 CST 2018
    Tue Jan 30 01:40:50 CST 2018

测试mariadb和后续
-----------------------------------------------------------------

.. code-block:: bash

    [root@localhost mariadb-10.2.12]$echo 'PATH=/usr/local/mysql/bin:$PATH' >> /etc/profile.d/lamp.sh 
    [root@localhost mariadb-10.2.12]$source /etc/profile.d/lamp.sh
    [root@localhost mariadb-10.2.12]$cd /usr/local/mysql/
    [root@localhost mysql]$scripts/mysql_install_db --datadir=/data/mysql/data --basedir=/usr/local/mysql --user=mysql
    [root@localhost mysql]$cp support-files/my-innodb-heavy-4G.cnf /etc/my.cnf 
    [root@localhost mysql]$sed -i '/\[mysqld\]/ adatadir=/data/mysql/data' /etc/my.cnf 
    [root@localhost mysql]$chown mysql.mysql /data/mysql/ -R 
    [root@localhost mysql]$chown mysql.mysql /usr/local/mysql -R
    [root@localhost mysql]$cp support-files/mysql.server  /etc/rc.d/init.d/mysqld
    [root@localhost mysql]$sed -i '/innodb_additional_mem_pool_size/ d' /etc/my.cnf
    [root@localhost mysql]$chkconfig --add mysqld
    [root@localhost mysql]$chkconfig mysqld on 
    [root@localhost mysql]$service mysqld on 
    [root@localhost mysql]$ss -tunl |grep 3306
    tcp    LISTEN     0      50                    :::3306                 :::*   
    [root@localhost mysql]$mysql_secure_installation

mariadb编译安装
-----------------------------------------------------------------

.. code-block:: bash

    [root@localhost php-7.2.1]./configure \
    --prefix=/usr/local/php \
    --enable-mysqlnd \
    --with-mysqli=mysqlnd \
    --with-openssl \
    --with-pdo-mysql=mysqlnd \
    --enable-mbstring \
    --with-freetype-dir \
    --with-jpeg-dir \
    --with-png-dir \
    --with-zlib \
    --with-libxml-dir=/usr \
    --enable-xml \
    --enable-sockets \
    --enable-fpm \
    --with-config-file-path=/etc \
    --with-config-file-scan-dir=/etc/php.d \
    --enable-maintainer-zts \
    --disable-fileinfo
    [root@localhost mysql]$cd /usr/src/lamp/
    [root@localhost lamp]$tar xf php-7.2.1.tar.bz2 
    [root@localhost lamp]$cd php-7.2.1
    [root@localhost php-7.2.1]$log=/root/php.make.log ; date >> $log ; make -j 4 && make install ; date >> $log
    [root@localhost php-7.2.1]$cat /root/php.make.log 
    Tue Jan 30 02:34:26 CST 2018
    Tue Jan 30 02:37:07 CST 2018

测试php和后续
-----------------------------------------------------------------

.. code-block:: bash

    [root@localhost php-7.2.1]$echo 'PATH=/usr/local/php/bin:$PATH' >> /etc/profile.d/lamp.sh 
    [root@localhost php-7.2.1]$source /etc/profile.d/lamp.sh
    [root@localhost php-7.2.1]$cp php.ini-production  /etc/php.ini
    [root@localhost php-7.2.1]$cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
    [root@localhost php-7.2.1]$chmod a+x /etc/init.d/php-fpm
    [root@localhost php-7.2.1]$chkconfig --add php-fpm
    [root@localhost php-7.2.1]$chkconfig php-fpm on
    [root@localhost php-7.2.1]$cd /usr/local/php/etc
    [root@localhost etc]$cp php-fpm.conf.default  php-fpm.conf
    [root@localhost etc]$cp php-fpm.d/www.conf.default  php-fpm.d/www.conf
    [root@localhost etc]$service php-fpm start
    [root@localhost etc]$ss -tunl |grep 9000
    tcp    LISTEN     0      128            127.0.0.1:9000                  *:*     

http集成php并测试
------------------------------------------------------------------------------------

.. code-block:: bash

    [root@localhost httpd24]$sed -r -i  's@#(LoadModule.*mod_proxy.so)@\1@' /usr/local/httpd24/conf/httpd.conf 
    [root@localhost httpd24]$sed -r -i  's@#(LoadModule.*mod_proxy_fcgi.so)@\1@' /usr/local/httpd24/conf/httpd.conf 
    [root@localhost httpd24]$sed -r -i 's@DirectoryIndex index.html@DirectoryIndex index.php index.html@' /usr/local/httpd24/conf/httpd.conf
    [root@localhost php-7.2.1]echo "AddType application/x-httpd-php .php" >> /usr/local/httpd24/conf/httpd.conf
    [root@localhost php-7.2.1]echo "AddType application/x-httpd-php-source .phps" >> /usr/local/httpd24/conf/httpd.conf
    [root@localhost php-7.2.1]echo "ProxyRequests Off" >> /usr/local/httpd24/conf/httpd.conf
    [root@localhost php-7.2.1]echo 'ProxyPassMatch ^/(.*\.php)$ fcgi://127.0.0.1:9000/usr/local/httpd24/htdocs/$1' >> /usr/local/httpd24/conf/httpd.conf

    [root@localhost httpd24]$tail -n 4 /usr/local/httpd24/conf/httpd.conf
    AddType application/x-httpd-php .php
    AddType application/x-httpd-php-source .phps
    ProxyRequests Off
    ProxyPassMatch ^/(.*\.php)$ fcgi://127.0.0.1:9000/usr/local/httpd24/htdocs/$1

    [root@localhost /]$apachectl restart 

    [root@localhost htdocs]$echo -e '<?php\nphpinfo();\n?>' >>index.php
    [root@localhost htdocs]$cat index.php 
    <?php
    phpinfo();
    ?>
    [root@localhost htdocs]$curl localhost |grep "PHP Version" -o


部署php应用软件phpMyAdmin
------------------------------------------------------------------------------------

.. code-block:: bash

    [root@localhost lamp]$unzip phpMyAdmin-4.7.7-all-languages.zip 

    [root@localhost lamp]$
    [root@localhost lamp]$mv phpMyAdmin-4.7.7-all-languages /usr/local/
    bin/     etc/     games/   httpd24/ include/ lib/     lib64/   libexec/ mysql/   php/     sbin/    share/   src/     
    [root@localhost lamp]$mv phpMyAdmin-4.7.7-all-languages/* /usr/local/httpd24/htdocs/  
    [root@localhost lamp]$cd /usr/local/httpd24/htdocs/
    [root@localhost htdocs]$cp config.sample.inc.php  config.inc.php 
    [root@localhost htdocs]$vim config.inc.php 
    # 修改如下行
    $cfg['Servers'][$i]['host'] = '127.0.0.1';


登陆应用
------------------------------------------------------------------------------------

效果图： 

.. image:: /images/web/phpmyadmin.png

