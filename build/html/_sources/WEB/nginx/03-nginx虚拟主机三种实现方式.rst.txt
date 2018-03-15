nginx虚拟主机三种实现方式
=======================================================

虚拟主机的实现方式有三种。

- 基于多ip
- 基于多端口
- 基于多虚拟主机名


安装nginx
--------------------------------------

.. code-block:: bash 

    [root@localhost ~]# yum install nginx 

方案1-基于多ip
--------------------------------------

.. code-block:: bash 

    # 查看ip信息
    [root@localhost ~]# ip a 
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
        inet 127.0.0.1/8 scope host lo
        valid_lft forever preferred_lft forever
        inet6 ::1/128 scope host 
        valid_lft forever preferred_lft forever
    2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
        link/ether 00:0c:29:b3:02:e2 brd ff:ff:ff:ff:ff:ff
        inet 192.168.46.151/24 brd 192.168.46.255 scope global ens33
        valid_lft forever preferred_lft forever
        inet6 fe80::df7e:1d50:d858:d479/64 scope link 
        valid_lft forever preferred_lft forever
    3: ens37: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
        link/ether 00:0c:29:b3:02:ec brd ff:ff:ff:ff:ff:ff
        inet 172.18.46.151/16 brd 172.18.255.255 scope global ens37
        valid_lft forever preferred_lft forever
        inet6 fe80::f0f5:59a9:d186:e6a7/64 scope link 
        valid_lft forever preferred_lft forever

    # 构建主页
    [root@localhost nginx]# pwd
    /usr/share/nginx
    [root@localhost nginx]# mkdir multi_ip_1
    [root@localhost nginx]# mkdir multi_ip_2
    [root@localhost nginx]# echo multi_ip_1 >> multi_ip_1/index.html
    [root@localhost nginx]# echo multi_ip_2 >> multi_ip_2/index.html

    # 编辑配置文件
    [root@localhost ~]# cd /etc/nginx/conf.d/
    [root@localhost conf.d]# ls
    [root@localhost conf.d]# vim multi_ip.conf
    [root@localhost conf.d]# cat multi_ip.conf 
    server    { 
        listen 172.18.46.151:80;
        root   /usr/share/nginx/multi_ip_1;
    }
    server    { 
        listen 192.168.46.151:80;
        root   /usr/share/nginx/multi_ip_2;
    }

    # 测试下
    [root@localhost conf.d]# systemctl restart nginx
    [root@localhost conf.d]# curl 172.18.46.151
    multi_ip_1
    [root@localhost conf.d]# curl 192.168.46.151
    multi_ip_2


方案1-基于多port
-----------------------------------------

.. code-block:: bash 

    # 编辑配置文件
    [root@localhost conf.d]# cp multi_ip.conf multi_port.conf
    [root@localhost conf.d]# vim multi_port.conf 
    [root@localhost conf.d]# cat multi_port.conf
    server    { 
        listen 172.18.46.151:81;
        root   /usr/share/nginx/multi_port_1;
    }
    server    { 
        listen 172.18.46.151:82;
        root   /usr/share/nginx/multi_port_2;
    }

    # 构建主页

    [root@localhost conf.d]# cd /usr/share/nginx/
    [root@localhost nginx]# ls
    html  modules  multi_ip_1  multi_ip_2
    [root@localhost nginx]# mkdir multi_port_1
    [root@localhost nginx]# mkdir multi_port_2
    [root@localhost nginx]# echo "multi_port_1" > multi_port_1/index.html
    [root@localhost nginx]# echo "multi_port_2" > multi_port_2/index.html

    # 测试下
    [root@localhost nginx]# systemctl restart nginx
    [root@localhost nginx]# curl 172.18.46.151:81
    multi_port_1
    [root@localhost nginx]# curl 172.18.46.151:82
    multi_port_2

方案1-基于多虚拟主机名
-----------------------------------------

这种方式是用的比较多的。

.. code-block:: bash 

    # 其他影响的配置文件备份下
    [root@localhost conf.d]# mv multi_host.conf{,.bak}
    [root@localhost conf.d]# mv multi_ip.conf{,.bak}

    # 编辑配置文件
    [root@localhost conf.d]# cp multi_ip.conf multi_host.conf
    [root@localhost conf.d]# vim multi_host.conf 
    [root@localhost conf.d]# cat multi_host.conf 
    server    { 
        listen 80;
        server_name www.linuxpanda.tech;
        root   /usr/share/nginx/multi_host_1;
    }
    server    { 
        listen 80;
        server_name blog.linuxpanda.tech;
        root   /usr/share/nginx/multi_host_2;
    }

    # 创建主页
    [root@localhost conf.d]# cd /usr/share/nginx/
    [root@localhost nginx]# ls
    html  modules  multi_ip_1  multi_ip_2  multi_port_1  multi_port_2
    [root@localhost nginx]# mkdir multi_host_1
    [root@localhost nginx]# mkdir multi_host_2
    [root@localhost nginx]# echo "multi_host_1" > multi_host_1/index.html
    [root@localhost nginx]# echo "multi_host_2" > multi_host_2/index.html

    # 测试
    虚拟主机需要配合dns解析使用的， 我这里就简单点使用hosts文件解析了。
    [root@localhost conf.d]# cat /etc/hosts
    127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
    ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
    192.168.46.151 www.linuxpanda.tech blog.linuxpanda.tech

    [root@localhost conf.d]# systemctl restart nginx
    [root@localhost conf.d]# curl www.linuxpanda.tech
    multi_host_1
    [root@localhost conf.d]# curl blog.linuxpanda.tech
    multi_host_2
