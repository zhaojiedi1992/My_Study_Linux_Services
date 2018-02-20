httpd基础配置说明
===========================================

.. note:: centos6和centos7版本安装的httpd版本有所不同，这里使用centos安装的2.2做实验。

全局环境配置
-----------------------------------------------------

ServerTokens
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

默认值： ServerTokens OS

这个参数是提供一部分http响应头信息的。 

.. code-block:: text

    ServerTokens Prod[uctOnly]
    Server sends (e.g.): Server: Apache
    ServerTokens Major
    Server sends (e.g.): Server: Apache/2
    ServerTokens Minor
    Server sends (e.g.): Server: Apache/2.0
    ServerTokens Min[imal]
    Server sends (e.g.): Server: Apache/2.0.41
    ServerTokens OS
    Server sends (e.g.): Server: Apache/2.0.41 (Unix)
    ServerTokens Full (or not specified)
    Server sends (e.g.): Server: Apache/2.0.41 (Unix) PHP/4.2.2 MyMod/1.2

.. note:: 这个值建议修改为Prod，也就是值显示Apache即可。


ServerRoot 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

默认值： ServerRoot "/etc/httpd"

这个参数是控制httpd的服务配置文件根目录的。后续的pidfile都是相对这个路径的。

.. note:: 这个参数不建议修改，涉及太多。

PidFile
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

默认值： PidFile run/httpd.pid

这个配置项是设置pid文件的位置的， 相对于ServerRoot的路径。

Timeout
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

默认值：  Timeout 60

这个配置项是服务器在请求失败前等待某些事件的时间，单位是秒。

KeepAlive 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

默认值：  KeepAlive Off

这个配置项是服务器是否保持持久连接，默认是off的，一个请求完毕就关闭本次连接了。


MaxKeepAliveRequests
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

默认值：  MaxKeepAliveRequests 100

这个配置项是在最大能持久化连接的个数，只有keepalive启用的时候生效。


KeepAliveTimeout
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

默认值： KeepAliveTimeout 15

这个配置项是在最大能持久化连接的时间，单位是秒，只有keepalive启用的时候生效。


StartServers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

这个配置项是在服务启动的进程数量。

MinSpareServers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

这个配置项是最小空闲的进程数量

MaxSpareServers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

这个配置项是最大空闲的进程数量


ServerLimit
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

这个配置项是最大进程数量

MaxClients
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

这个配置项是最大客户端个数

MaxRequestsPerChild
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
这个配置项是每个进程课可以服务的最大请求数量，超过就杀掉，重新创建进程。

.. note:: 0的代表不限制。

MinSpareThreads
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

这个配置项是最小空闲的线程数量

MaxSpareThreads
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

这个配置项是最大空闲的线程数量

ThreadsPerChild
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

这个配置项是每个进程的线程数量


Listen 80
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

默认值： Listen 80

配置样例：

.. code-block:: text

    # 配置多个监听
    Listen 80
    Listen 8000

    # 监听在指定ip的指定端口上
    Listen 192.170.2.1:80
    Listen 192.170.2.5:8000

    # 监听在ipv6上
    Listen [2001:db8::a00:20ff:fea7:ccea]:80

    # 监听指定的协议
    Listen 192.170.2.1:8443 https

LoadModule
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

这个是用于加载模块的。

Include 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

默认值： Include conf.d/\*.conf

这个就是加载conf.d目录下的所有配置文件

User apache
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

这个配置是httpd服务启动的用户身份

Group apache
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

这个配置是httpd服务启动的组身份

主服务器配置
------------------------------------------------

ServerAdmin 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

这个配置项是服务器出现故障的邮件通知者的邮箱。

ServerName 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

默认值： ServerName www.example.com:80

这个配置项是服务器的fqdn名字。

.. note:: 这项配置建议修改下，不然启动服务老是提示这个问题。

UseCanonicalName Off
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

DocumentRoot "/var/www/html"
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

默认值： DocumentRoot "/var/www/html"

这个配置是设置http文档的根目录的，我们访问的主页默认是这个目录下的index.html。

目录设置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

样例： 

.. code-block:: text

    <Directory />
        Options FollowSymLinks
        AllowOverride None
    </Directory>

.. code-block:: text

FollowSymlinks          是如果目录下有符号连接文件，也是可以访问的。使用-FollowsymLinks禁止符号连接文件查看
AllowOverride           是否收.htaccess文件控制。
Indexes                 是否显示索引文件的方式显示文件，类似ftp方式显示。
Order allow,deny        是设置权限的，那个在后面那个就是默认的，如果下面有特定的设置，按照特定的设置规则走，如果下面的设置规则有冲突，则安装默认的规则来。
Allow from all          是允许所有主机访问，特定主机写ip，ip/prefix，或者ip/netmask，或者172.18这种方式的。
DirectoryIndex          默认主页的名字搜索，有先后顺序的。
AccessFileName .htaccess 默认的权限控制的，放到指定的目录即可。
ErrorLog logs/error_log 错误日志文件
LogLevel warn           日志级别
LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined   定义一种日志格式
LogFormat "%h %l %u %t \"%r\" %>s %b" common                                        定义另一种日志格式
LogFormat "%{Referer}i -> %U" referer
LogFormat "%{User-agent}i" agent
CustomLog logs/access_log combined                                                  使用哪一种日志格式
Alias /icons/ "/var/www/icons/"                         定义一个目录别名，前面是url路径，后面的是物理真实路径
ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"               定义一个脚本别名
ServiceAlias                                            定义一个目录别名

认证
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用户认证

.. code-block:: bash

    # 添加指定目录的认证
    [root@102 html]$ vim /etc/httpd/conf/httpd.conf
    <directory "/var/www/html/dir1">
            options None
            allowoverride none
            authtype basic
            authname "你需要认证下,小伙子"
            authuserfile /etc/httpd/conf.d/.htpasswd
            require user h1
    </directory>

    # 添加密码， 如果有文件了。 不要用-c选项了，命令来自httpd-tools包
    [root@102 html]$ htpasswd -c  /etc/httpd/conf.d/.htpasswd h1
    New password: 
    Re-type new password: 
    Adding password for user h1
    [root@102 html]$ file /etc/httpd/conf.d/.htpasswd
    /etc/httpd/conf.d/.htpasswd: ASCII text
    [root@102 html]$ cat /etc/httpd/conf.d/.htpasswd 
    h1:$apr1$svPCgcpG$gk1miSEUagwrUhrbsSeYn0

组认证

.. code-block:: bash

  # 添加指定目录的认证
    [root@102 html]$ vim /etc/httpd/conf/httpd.conf
    <directory "/var/www/html/dir1">
            options None
            allowoverride none
            authtype basic
            authname "你需要认证下,小伙子"
            authuserfile /etc/httpd/conf.d/.htpasswd
            authgroupfile /etc/httpd/conf.d/.htgroup
            require group admin
    </directory>

    [root@102 html]$ vim /etc/httpd/conf.d/.htgroup
    [root@102 html]$ cat /etc/httpd/conf.d/.htgroup
    admin: h1 h3

    [root@102 html]$ htpasswd  /etc/httpd/conf.d/
    autoindex.conf  .htgroup        .htpasswd       README          userdir.conf    welcome.conf    
    [root@102 html]$ htpasswd  /etc/httpd/conf.d/
    autoindex.conf  .htgroup        .htpasswd       README          userdir.conf    welcome.conf    
    [root@102 html]$ htpasswd  /etc/httpd/conf.d/.htpasswd  h2
    New password: 
    Re-type new password: 
    Adding password for user h2
    [root@102 html]$ htpasswd  /etc/httpd/conf.d/.htpasswd  h3
    New password: 
    Re-type new password: 
    Adding password for user h3

Satisfy
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

这个配置默认Satify All,意思是ip和用户认证2个都要满足才能访问，any是只要一个满足就可以访问。

userdir_module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

查看是否加载了这个模块

.. code-block:: bash

    [root@102 conf.d]$ httpd -M |grep userdir
    userdir_module (shared)

配置

.. code-block:: text

    [root@102 conf.d]$ vim /etc/httpd/conf.d/userdir.conf
    <IfModule mod_userdir.c>
        UserDir enabled zhao
        UserDir public_html
    </IfModule>

    <Directory "/home/*/public_html">
        Require all granted
    </Directory>

    [root@102 conf.d]$ su - zhao
    Last login: Tue Jan  9 09:17:18 CST 2018 on pts/4
    [zhao@102 ~]$ pwd
    /home/zhao
    [zhao@102 ~]$ mkdir public_html
    [zhao@102 ~]$ echo "test usedir" > public/html/a.txt
    [root@102 conf.d]$ setfacl -m "u:apache:x" /home/zhao/

 如果selinux启用中，还需要额外设置

 .. code-block:: bash

    [root@102 conf.d]$ setsebool -P httpd_enable_homedirs true
    [root@102 conf.d]$ setsebool -semanage fcontext  -a -t httpd_sys_content_t '/home(/.*)?/public_html(/.*)?'
    [root@102 conf.d]$ restorecon -Rv /home/zhao/public_html/

    
Status
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

添加httpd状态信息查看

.. code-block:: bash

    [root@102 conf.d]$ vim status.conf 
    [root@102 conf.d]$ cat status.conf 
    <Location "/status">
        SetHandler server-status
        Require ip 172.18
        #Extendedstatus on
    </Location>

mod_deflate
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

启用压缩功能

.. code-block:: bash

    [root@102 conf.d]$ vim deflate.conf 
    Setoutputfilter deflate
    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript

redirect
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

重定向功能

.. code-block:: bash

    [root@102 conf.d]# vim redirect.conf 
    [root@102 conf.d]# cat redirect.conf 
    redirect temp /  https://www.linuxpanda.com/
    [root@102 conf.d]# curl http://www.linuxpanda.tech   -I
    [root@102 conf.d]# curl http://www.linuxpanda.tech   -L -k -I

temp是临时重定向，permanent对应永久重定向

hsts
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

服务端支持hsts后，会给浏览器返回的http头信息中携带hsts字段，浏览器得到这个信息后，在内部做307跳转到https，
无需要任何网络过程。


.. code-block:: bash

    [root@102 conf.d]# !vim 
    vim hsts.conf  
    [root@102 conf.d]# cat hsts.conf 
    Header always set Strict-Transport-Security "max-age = 15768000"
    RewriteEngine on 
    RewriteRule ^(/.*)$    https://%${HTTP_HOST}$1 [redirect=301] 
    [root@102 conf.d]# systemctl restart httpd

    [root@102 conf.d]# curl www.linuxpanda.tech -I 
    HTTP/1.1 301 Moved Permanently
    Date: Sat, 27 Jan 2018 11:11:26 GMT
    Server: Apache/2.4.6 (CentOS) OpenSSL/1.0.2k-fips
    Strict-Transport-Security: max-age = 15768000
    Location: https://www.linuxpanda.tech/
    Content-Type: text/html; charset=iso-8859-1

    [root@102 conf.d]# curl www.linuxpanda.tech -I -L

mpm切换
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

这个是http2.4版本有的，centos7默认就是2.4的。

.. code-block:: bash

    [root@102 conf.d]# vim /etc/httpd/conf.modules.d/00-mpm.conf 

这个文件很简单， 注释一个mpm模块，解注释一个mpm即可完成mpm模块的切换，当然还需要重启下服务。

centos7授权
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

centos7的web目录必须是授权的。

.. code-block:: bash

    # 给提供web的目录如下片段
    <Directory "/var/www/cgi-bin">
    AllowOverride None
    Options None
    Require all granted
    </Directory>

.. code-block:: text

    Require all granted 是允许所有主机
    Require all denied 是拒绝所有主机
    RequireAll是所有条件都匹配
    REquireAny是任何一个条件匹配就可以

运行所有主机，禁止特定的一个主机

.. code-block:: bash

    <Directory "/var/www/cgi-bin">
        <RequireAll>
            Require all granted
            Require not ip 192.168.1.106
        </RequireAll>
    </Directory>

ProxyPass
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

提供反向代理功能

.. code-block:: bash 

    ProxyPass "/" "http://www.example.com/"
    ProxyPassReverse "/" "http://www.example.com/"

