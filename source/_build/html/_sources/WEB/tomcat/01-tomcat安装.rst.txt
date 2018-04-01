tomcat安装
======================================

jdk安装
---------------------------------------------

yum安装
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    [root@centos-151 ~]# yum search openjdk 
    [root@centos-151 ~]# yum install java-1.8.0-openjdk.x86_64

    [root@centos-151 ~]# java -version
    openjdk version "1.8.0_161"
    OpenJDK Runtime Environment (build 1.8.0_161-b14)
    OpenJDK 64-Bit Server VM (build 25.161-b14, mixed mode)


直接解压包方式
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

包下载地址_

.. _包下载地址: http://www.oracle.com/technetwork/java/javase/downloads/index.html

.. code-block:: bash 

    [root@centos-152 ~]# wget http://download.oracle.com/otn-pub/java/jdk/8u162-b12/0da788060d494f5095bf8624735fa2f1/jdk-8u162-linux-x64.rpm?AuthParam=1522289893_92e84e76f51bb5aa8133b08fcf86150b
    [root@centos-152 ~]# ls
    anaconda-ks.cfg  jdk-8u162-linux-x64.rpm?AuthParam=1522289893_92e84e76f51bb5aa8133b08fcf86150b
    [root@centos-152 ~]# mv jdk-8u162-linux-x64.rpm\?AuthParam\=1522289893_92e84e76f51bb5aa8133b08fcf86150b  jdk-8u162-linux-x64.rpm
    [root@centos-152 ~]# yum install jdk-8u162-linux-x64.rpm 

    [root@centos-152 ~]# cd /usr/java/
    [root@centos-152 java]# ll 
    total 0
    lrwxrwxrwx 1 root root  16 Mar 29 10:19 default -> /usr/java/latest
    drwxr-xr-x 9 root root 268 Mar 29 10:19 jdk1.8.0_162
    lrwxrwxrwx 1 root root  22 Mar 29 10:19 latest -> /usr/java/jdk1.8.0_162

    [root@centos-152 java]# vim /etc/profile.d/java.sh
    [root@centos-152 java]# cat /etc/profile.d/java.sh
    export JAVA_HOME=/usr/java/latest
    export PATH=$PATH:$JAVA_HOME/bin
    [root@centos-152 java]# source /etc/profile.d/java.sh
    [root@centos-152 java]# java -version
    java version "1.8.0_162"
    Java(TM) SE Runtime Environment (build 1.8.0_162-b12)
    Java HotSpot(TM) 64-Bit Server VM (build 25.162-b12, mixed mode)

tomcat安装
---------------------------------------------

yum安装
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    [root@centos-151 ~]# yum install tomcat  tomcat-lib  tomcat-admin-webapps  tomcat-webapps  tomcat-docs-webapp

    [root@centos-151 ~]# systemctl restart tomcat 
    [root@centos-151 ~]# ss -tul
    Netid  State      Recv-Q Send-Q                                       Local Address:Port                                                        Peer Address:Port                
    tcp    LISTEN     0      128                                                      *:ssh                                                                    *:*                    
    tcp    LISTEN     0      100                                              127.0.0.1:smtp                                                                   *:*                    
    tcp    LISTEN     0      128                                                      *:zabbix-trapper                                                         *:*                    
    tcp    LISTEN     0      50                                                       *:mysql                                                                  *:*                    
    tcp    LISTEN     0      128                                                     :::http                                                                  :::*                    
    tcp    LISTEN     0      128                                                     :::ssh                                                                   :::*                    
    tcp    LISTEN     0      100                                                    ::1:smtp                                                                  :::*                    
    tcp    LISTEN     0      128                                                     :::zabbix-trapper                                                        :::*         
