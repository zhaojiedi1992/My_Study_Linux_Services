ldirectord
===============================================

下载
-------------------------------------------------


.. code-block:: bash 

    # 这个资源，需要科学上网的。
    [root@centos-151 ~]#wget http://download.opensuse.org/repositories/network:/ha-clustering:/Stable/CentOS_CentOS-7/x86_64/
    [root@centos-151 ~]# yum install ldirectord-3.9.6-0rc1.1.2.x86_64.rpm 
    [root@centos-151 ~]# rpm -ql ldirectord 
    /etc/ha.d
    /etc/ha.d/resource.d
    /etc/ha.d/resource.d/ldirectord
    /etc/logrotate.d/ldirectord
    /usr/lib/ocf/resource.d/heartbeat/ldirectord
    /usr/lib/systemd/system/ldirectord.service
    /usr/sbin/ldirectord
    /usr/share/doc/ldirectord-3.9.6
    /usr/share/doc/ldirectord-3.9.6/COPYING
    /usr/share/doc/ldirectord-3.9.6/ldirectord.cf
    /usr/share/man/man8/ldirectord.8.gz

配置
--------------------------------------------------------------


.. code-block:: bash 

    [root@centos-151 ~]# cp /usr/share/doc/ldirectord-3.9.6/ldirectord.cf /etc/ha.d/
    [root@centos-151 ~]# vim /etc/ha.d/ldirectord.cf 
    # 修改为如下内容

    checktimeout=3
    checkinterval=1
    fallback=127.0.0.1:80
    #fallback6=[::1]:80
    autoreload=yes
    #logfile="/var/log/ldirectord.log"
    #logfile="local0"
    #emailalert="admin@x.y.z"
    #emailalertfreq=3600
    #emailalertstatus=all
    quiescent=no

    # Sample for an http virtual service
    virtual=10.0.46.151:80
            real=192.168.46.158:80 gate 1
            real=192.168.46.159:80 gate 2
            real=192.168.46.160:80 gate 3
            service=http
            scheduler=wrr
            #persistent=600
            #netmask=255.255.255.255
            protocol=tcp
            checktype=negotiate
            checkport=80
            request="test.html"
            receive="test"
            #virtualhost=www.x.y.z

    # 添加测试页和sorry页面

    [root@centos-158 ~]# echo "test" > /var/www/html/test.html 
    [root@centos-159 ~]# echo "test" > /var/www/html/test.html 
    [root@centos-160 ~]# echo "test" > /var/www/html/test.html 
    [root@centos-151 ~]# echo "sorry" > /var/www/html/index.html 

    # 重启服务
    [root@centos-151 ~]# ipvsadm -C 
    [root@centos-151 ~]# systemctl enable ldirectord 
    Created symlink from /etc/systemd/system/multi-user.target.wants/ldirectord.service to /usr/lib/systemd/system/ldirectord.service.
    [root@centos-151 ~]# systemctl start ldirectord

    [root@centos-151 ~]# ipvsadm -ln 
    IP Virtual Server version 1.2.1 (size=4096)
    Prot LocalAddress:Port Scheduler Flags
    -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
    TCP  10.0.46.151:80 wrr
    -> 192.168.46.158:80            Route   1      0          0         
    -> 192.168.46.159:80            Route   2      0          0         
    -> 192.168.46.160:80            Route   3      0          0   

    [root@centos-152 ~]# curl 10.0.46.151
    linuxpanda-160
    [root@centos-158 ~]# systemctl stop httpd
    [root@centos-159 ~]# systemctl stop httpd 
    [root@centos-152 ~]# curl 10.0.46.151
    linuxpanda-160
    [root@centos-152 ~]# curl 10.0.46.151
    linuxpanda-160
    [root@centos-152 ~]# curl 10.0.46.151
    linuxpanda-160
    [root@centos-160 ~]# systemctl stop httpd 
    [root@centos-152 ~]# curl 10.0.46.151
    sorry
    [root@centos-158 ~]# systemctl start httpd
    [root@centos-152 ~]# curl 10.0.46.151
    linuxpanda-158
