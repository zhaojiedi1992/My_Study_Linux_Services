tomcat配合redis会话管理
===================================


这里使用192.168.46.151作为调度器，后端使用192.168.46.152，192.168.46.153作为tomcat服务器。

tomcat安装
--------------------------------

.. code-block:: bash 

    [root@centos-152 ~]# yum search openjdk 
    [root@centos-152 ~]# yum install java-1.8.0-openjdk.x86_64
    [root@centos-152 ~]# java -version
    [root@centos-152 ~]# yum install tomcat  tomcat-lib  tomcat-admin-webapps  tomcat-webapps  tomcat-docs-webapp
    [root@centos-152 ~]# systemctl restart tomcat 
    [root@centos-152 ~]# ss -tul

    [root@centos-153 ~]# yum search openjdk 
    [root@centos-153 ~]# yum install java-1.8.0-openjdk.x86_64
    [root@centos-153 ~]# java -version
    [root@centos-153 ~]# yum install tomcat  tomcat-lib  tomcat-admin-webapps  tomcat-webapps  tomcat-docs-webapp
    [root@centos-153 ~]# systemctl restart tomcat 
    [root@centos-153 ~]# ss -tul

前端调度配置
--------------------------------

.. code-block:: bash

    [root@centos-151 ~]# yum install nginx
    [root@centos-151 ~]# vim /etc/nginx/nginx.conf

        # 添加和修改如下内容
        upstream webend  {
            server 192.168.46.152;
            server 192.168.46.153;
            }

        server {
            listen       80 default_server;
            listen       [::]:80 default_server;
            server_name  _;
            root         /usr/share/nginx/html;

            # Load configuration files for the default server block.
            include /etc/nginx/default.d/*.conf;

            location / {
            proxy_pass http://webend ;
            index index.jsp index.html;
            }
    [root@centos-151 ~]# systemctl restart nginx
    [root@centos-151 ~]# ss -tunl

后端tomcat样例页准备
--------------------------------


.. code-block:: bash 

    [root@centos-152 ~]# mkdir -pv /usr/share/tomcat/webapps/test/{classes,lib,WEB-INF,META-INF}
    [root@centos-152 ~]# vim /usr/share/tomcat/webapps/test/index.jsp
    [root@centos-152 ~]# cat /usr/share/tomcat/webapps/test/index.jsp
    <%@ page language="java" %>
                            <html>
                                <head><title>TomcatA</title></head>
                                <body>
                                    <h1><font color="red">TomcatA.linuxpanda.tech</font></h1>
                                    <table align="centre" border="1">
                                        <tr>
                                            <td>Session ID</td>
                                        <% session.setAttribute("linuxpanda.tech","linuxpanda.tech"); %>
                                            <td><%= session.getId() %></td>
                                        </tr>
                                        <tr>
                                            <td>Created on</td>
                                            <td><%= session.getCreationTime() %></td>
                                        </tr>
                                    </table>
                                </body>
                            </html>
    [root@centos-152 ~]# scp -rp  /usr/share/tomcat/webapps/test/   192.168.46.153:/usr/share/tomcat/webapps/
    [root@centos-153 ~]# vim /usr/share/tomcat/webapps/test/index.jsp 
    [root@centos-153 ~]# cat /usr/share/tomcat/webapps/test/index.jsp
    <%@ page language="java" %>
                            <html>
                                <head><title>TomcatA</title></head>
                                <body>
                                    <h1><font color="red">TomcatB.linuxpanda.tech</font></h1>
                                    <table align="centre" border="1">
                                        <tr>
                                            <td>Session ID</td>
                                        <% session.setAttribute("linuxpanda.tech","linuxpanda.tech"); %>
                                            <td><%= session.getId() %></td>
                                        </tr>
                                        <tr>
                                            <td>Created on</td>
                                            <td><%= session.getCreationTime() %></td>
                                        </tr>
                                    </table>
                                </body>
                            </html>

    # 启动tomcat
    [root@centos-152 ~]# systemctl restart tomcat 
    [root@centos-153 ~]# systemctl restart tomcat 


测试调度情况
--------------------------------

.. image:: /images/web/tomcat-aa.png

不断刷新，发现页面和sesssionId,都会不断变化的，chroom浏览器测试有点问题，建议firefox浏览器测试。


配置tomcat支持memcached会话管理
--------------------------------------

官方地址参考_ 

.. _官方地址参考: https://github.com/magro/memcached-session-manager/wiki/SetupAndConfiguration


.. code-block:: bash 

    # 查看tomcat版本
    [root@centos-152 msm]# yum info tomcat |grep Version
    Version     : 7.0.76

    # 先下载下会话管理对应的包
    [root@centos-152 ~]# wget http://repo1.maven.org/maven2/de/javakaffee/msm/memcached-session-manager/2.3.0/memcached-session-manager-2.3.0.jar
    [root@centos-152 ~]# wget http://repo1.maven.org/maven2/de/javakaffee/msm/memcached-session-manager-tc7/2.3.0/memcached-session-manager-tc7-2.3.0.jar
    [root@centos-152 ~]# wget http://central.maven.org/maven2/redis/clients/jedis/2.9.0/jedis-2.9.0.jar
    # 下载序列化需要的包

    [root@centos-152 ~]# wget http://repo1.maven.org/maven2/org/objenesis/objenesis/2.6/objenesis-2.6.jar
    [root@centos-152 ~]# wget http://repo1.maven.org/maven2/org/ow2/asm/asm/6.1.1/asm-6.1.1.jar
    [root@centos-152 ~]# wget http://repo1.maven.org/maven2/com/esotericsoftware/reflectasm/1.11.3/reflectasm-1.11.3.jar
    [root@centos-152 ~]# wget http://repo1.maven.org/maven2/com/esotericsoftware/minlog/1.3.0/minlog-1.3.0.jar
    [root@centos-152 ~]# wget http://repo1.maven.org/maven2/com/esotericsoftware/kryo/4.0.2/kryo-4.0.2.jar
    [root@centos-152 ~]# wget http://repo1.maven.org/maven2/de/javakaffee/kryo-serializers/0.42/kryo-serializers-0.42.jar
    [root@centos-152 ~]# wget http://repo1.maven.org/maven2/de/javakaffee/msm/msm-kryo-serializer/2.3.0/msm-kryo-serializer-2.3.0.jar
    # 查看下载的包
    [root@centos-152 msm]# ll
    total 1392
    -rw-r--r-- 1 root root 108252 Mar 25 22:20 asm-6.1.1.jar
    -rw-r--r-- 1 root root 553762 Jul 22  2016 jedis-2.9.0.jar
    -rw-r--r-- 1 root root 337512 Mar 21 05:02 kryo-4.0.2.jar
    -rw-r--r-- 1 root root 106032 Jul 17  2017 kryo-serializers-0.42.jar
    -rw-r--r-- 1 root root 167266 Mar 19 06:29 memcached-session-manager-2.3.0.jar
    -rw-r--r-- 1 root root  11704 Mar 19 06:33 memcached-session-manager-tc7-2.3.0.jar
    -rw-r--r-- 1 root root   5711 Jul 21  2014 minlog-1.3.0.jar
    -rw-r--r-- 1 root root  38268 Mar 19 06:37 msm-kryo-serializer-2.3.0.jar
    -rw-r--r-- 1 root root  55684 Jun 20  2017 objenesis-2.6.jar
    -rw-r--r-- 1 root root  20883 May  9  2016 reflectasm-1.11.3.jar


    # 复制到tomcat的lib目录去
    [root@centos-152 msm]# cp *.jar /usr/share/tomcat/lib/
    [root@centos-152 msm]# scp *.jar 192.168.46.153:/usr/share/tomcat/lib/

    [root@centos-152 msm]# vim /etc/tomcat/server.xml 
    # 在默认的Host片段添加如下内容
    <Context path="/test" docBase="/usr/share/tomcat/webapps/test" reloadable="" >
    <Manager className="de.javakaffee.web.msm.MemcachedBackupSessionManager"
        memcachedNodes="redis://redis.linuxpanda.tech"
        sticky="true"
        sessionBackupAsync="false"
        lockingMode="uriPattern:/path1|/path2"
        requestUriIgnorePattern=".*\.(ico|png|gif|jpg|css|js)$"
        transcoderFactoryClass="de.javakaffee.web.msm.serializer.kryo.KryoTranscoderFactory"
        />
    </Context>

    [root@centos-152 msm]# scp /etc/tomcat/server.xml 192.168.46.153:/etc/tomcat/

    # 安装memcached
    [root@centos-152 msm]# yum install redis
    [root@centos-152 msm]# systemctl start redis
    [root@centos-152 msm]# systemctl restart tomcat 
    [root@centos-153 msm]# yum install redis
    [root@centos-153 msm]# systemctl start redis
    [root@centos-153 msm]# systemctl restart tomcat 


上面使用了"redis://redis.linuxpanda.tech"，不像memcached一样可以指定多个节点， 但是redis自身是支持集群的， 我们需要配置redis集群和Sentinel监控迁移即可，
但是这个配置文件写的是redis.linuxpanda.tech 所以就有问题了， 如果一个redis集群节点down掉，即使redis迁移到从节点上去， 我们的配置还是需要修改的，

这里给几种解决方案： 

- 可以使用域名配合dns去做， 
- 或者使用keepalived来做ip漂移。
- 上面2中配合zabbix监控可能更好些。
