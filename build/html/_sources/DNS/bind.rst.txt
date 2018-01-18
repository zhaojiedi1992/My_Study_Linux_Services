bind
============================================

dns简介
---------------------------------------------------------

DNS（domain name service ）是域名解析服务，工作在应用层，是c/s结构，监听于53端口。

- tcp 53: 用于区域传输
- ucp 53: 用于查询

BIND(Bekerley Internet Name Domain) 是伯克利互联网名称域。提供了DNS服务。

DNS查询类型： 

- 递归查询
- 迭代查询

服务器类型： 

- 主dns:      管理和为何负责解析域的服务器
- 从dns：     从服务器从主服务器复制库
- 缓存dns：    转发dns

区域传输： 

- 完全传输：   传输整个库
- 增量传输：    传递变化的部分内容

解析流程： 

client->hosts->local dns cache->dns server -> server cache-> root -> 二级域

解析答案： 

- 肯定答案： 
- 否定答案： 
- 权威答案： 
- 非权威答案： 

资源记录
---------------------------------------------------------

资源记录类型 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

- A:            ipv4
- AAAA:         ipv6
- PTR:          ip->fqdn
- SOA:          起始授权记录
- NS:           域名
- CNAME:        别名
- MX:           邮件  

资源记录格式： 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text

    name [ttl] IN rr_type value
    # ttl可以从全局继承
    # @引用当前区域的名字。
    # 同一个名字可以通过多条记录定义多个值，dns会轮训响应

SOA记录： 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

name: 就是当前域的名字， 例如“linuxpanda.tech.”

value: 这个value由多个部分组成，当前的fqdn,邮箱地址，还有相关设置。

样例： 

.. code-block:: text

    linuxpanda.tech. 866400 IN SOA ns.linuxpanda.tech. nsadmin.linuxpanda.tech. (
                                                        20180117 ; 序列号
                                                        2H       ; 刷新时间
                                                        10M      ; 重试时间
                                                        1W       ; 过期时间
                                                        1D       ; 否定答案的ttl时间
                                                        )

.. warning:: SOA记录必须是第一条记录。

MX记录
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

样例： 

.. code-block:: text

    linuxpanda.tech. 86400 IN MX 10 mx1.linuxpanda.tech.
    linuxpanda.tech. 86400 IN MX 20 mx2.linuxpanda.tech.

mx是有优先级的，数值越大优先级越低

A记录
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

样例： 

.. code-block:: text

    www            IN                A        1.1.1.1
    www            IN                A        2.2.2.2

上面的www是主机名，完成的名字是www.linuxpanda.tech. 因为我们的域是linuxpanda.tech. 可以省去后面的不写，只写主机名即可。

如果主机过多，可以使用生成器

.. code-block:: text

    $GENERATE 10-20   www$        A           192.168.46.$

上面的相当于www10对应10，www11对应11等等。

如果避免用户写错主机名导致无法访问的问题，可以考虑使用泛域名解析

.. code-block:: text

    *.linuxpanda.tech.              IN      A        192.168.46.1

PTR记录
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

需要将ip反过来写的。

样例： 

.. code-block:: text

    1.46.168.192.in-addr.arpa.    IN       PTR     www.linuxpanda.tech.

别名记录
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text

    www.linxupanda.com.       IN   CNAME          web.linuxpanda.tech.

DNS软件安装
---------------------------------------------------------

.. code-block:: bash

    [root@localhost ~]# yum install bind bind-utils
    [root@localhost ~]# rpm -ql bind 
    [root@localhost ~]# rpm -ql bind-utils

正向解析
---------------------------------------------------------

编辑默认配置文件
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@localhost ~]# vim /etc/named.conf
    #注释以下行，使用//注释
    //      listen-on port 53 { 127.0.0.1; };
    //      allow-query     { localhost; };
    # 修改下面2项为no
    dns no;
    dnssec-validation no;

    [root@localhost ~]# vim /etc/named.rfc1912.zones 
    # 添加如下几行
    zone "linuxpanda.tech" IN {
            type master;
            file "linuxpanda.tech.zone";
    }

主要配置含义： 

- listen-on：是监听配置，我们注释掉之后就是监听本机所有ip了，
- allow-query: 这个是允许那个主机查询，注释掉就是允许所有的，如果只是想本网使用可以修改为192.168.46.0/24即可。


如果不修改listen-on选项，默认只是鉴定在127.0.0.1上的。

添加区域文件
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@localhost named]# cp named.localhost linuxpanda.tech.zone -p
    [root@localhost named]# ll 
    total 20
    drwxrwx---. 2 named named    6 Aug  4 16:13 data
    drwxrwx---. 2 named named    6 Aug  4 16:13 dynamic
    -rw-r-----. 1 root  named  152 Jun 21  2007 linuxpanda.tech.zone
    -rw-r-----. 1 root  named 2281 May 22  2017 named.ca
    -rw-r-----. 1 root  named  152 Dec 15  2009 named.empty
    -rw-r-----. 1 root  named  152 Jun 21  2007 named.localhost
    -rw-r-----. 1 root  named  168 Dec 15  2009 named.loopback
    drwxrwx---. 2 named named    6 Aug  4 16:13 slaves
    [root@localhost named]# vim linuxpanda.tech.zone 
    [root@localhost named]# cat linuxpanda.tech.zone 
    $TTL 1D
    @	IN SOA	ns1 nsadmin (
                        0	    ; serial
                        1D	    ; refresh
                        1H	    ; retry
                        1W	    ; expire
                        3H )	; minimum
        NS	ns1
    ns1	A       192.168.46.7	
    www     A       192.168.46.7

“@”代表的是域名“linuxpanda.tech.” 这个实在rfc1912.conf文件里面设置的。 

第二行没有指定的项，会从上面一行继承下来。

检查配置文件
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@localhost named]# named-check
    named-checkconf  named-checkzone  
    [root@localhost named]# named-checkzone linuxpanda.tech linuxpanda.tech.zone 
    zone linuxpanda.tech/IN: loaded serial 0
    OK

重启下dns服务
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@localhost named]# systemctl restart named

测试
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

host方式测试

.. code-block:: bash

    [root@localhost named]# host www.linuxpanda.tech localhost
    Using domain server:
    Name: localhost
    Address: ::1#53
    Aliases: 

    www.linuxpanda.tech has address 192.168.46.7

dig方式测试

.. code-block:: bash

    [root@localhost named]# dig ns1.linuxpanda.tech @localhost

    ; <<>> DiG 9.9.4-RedHat-9.9.4-50.el7 <<>> ns1.linuxpanda.tech @localhost
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 35168
    ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 1

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;ns1.linuxpanda.tech.		IN	A

    ;; ANSWER SECTION:
    ns1.linuxpanda.tech.	86400	IN	A	192.168.46.7

    ;; AUTHORITY SECTION:
    linuxpanda.tech.	86400	IN	NS	ns1.linuxpanda.tech.

    ;; Query time: 0 msec
    ;; SERVER: ::1#53(::1)
    ;; WHEN: Wed Jan 17 20:30:04 CST 2018
    ;; MSG SIZE  rcvd: 78

nslookup测试

.. code-block:: bash

    [root@localhost named]# nslookup 
    > server localhost
    Default server: localhost
    Address: ::1#53
    Default server: localhost
    Address: 127.0.0.1#53
    > www.linuxpanda.tech
    Server:		localhost
    Address:	::1#53

    Name:	www.linuxpanda.tech
    Address: 192.168.46.7
    > exit




.. note:: 自己创建的zone文件，请确保named用户有读取权限。

反向解析
---------------------------------------------------------

在主配置文件中区域

.. code-block:: bash

    [root@localhost named]# vim /etc/named.rfc1912.zones 
    zone "46.168.192.in-addr.arpa" IN {
            type master;
            file "192.168.46.zone";
    };

.. warning:: 一定注意{}后面的;号了。最容易忘记了。


添加区域文件

.. code-block:: bash

    [root@localhost named]# cp named.loopback  192.168.46.zone -p
    [root@localhost named]# vim 192.168.46.zone 
    [root@localhost named]# cat 192.168.46.zone 
    $TTL 1D
    @       IN SOA  ns1.linuxpanda.tech. nsadmin.linuxpanda.tech. (
                                            0       ; serial
                                            1D      ; refresh
                                            1H      ; retry
                                            1W      ; expire
                                            3H )    ; minimum
            IN NS      ns1.linuxpanda.tech.
    7       IN PTR     ns1.linuxpanda.tech.
    7       IN PTR     www.linuxpanda.tech.

检查配置文件

.. code-block:: bash

    [root@localhost named]# named-checkconf 
    [root@localhost named]# named-checkzone  46.168.192.in-addr.arpa 192.168.46.zone 

测试

.. code-block:: bash

    [root@localhost named]# rndc reload
    server reload successful

    [root@localhost named]# host 192.168.46.7 192.168.46.7
    Using domain server:
    Name: 192.168.46.7
    Address: 192.168.46.7#53
    Aliases: 

    7.46.168.192.in-addr.arpa domain name pointer ns1.linuxpanda.tech.
    7.46.168.192.in-addr.arpa domain name pointer www.linuxpanda.tech.

    [root@7 named]# dig -t ptr www.linuxpanda.tech @192.168.46.7

    ; <<>> DiG 9.9.4-RedHat-9.9.4-50.el7 <<>> -t ptr www.linuxpanda.tech @192.168.46.7
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 2709
    ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;www.linuxpanda.tech.		IN	PTR

    ;; AUTHORITY SECTION:
    linuxpanda.tech.	10800	IN	SOA	ns1.linuxpanda.tech. nsadmin.linuxpanda.tech. 0 86400 3600 604800 10800

    ;; Query time: 3 msec
    ;; SERVER: 192.168.46.7#53(192.168.46.7)
    ;; WHEN: Thu Jan 18 13:35:24 CST 2018
    ;; MSG SIZE  rcvd: 96

    # 另一个主机测试
    [root@101 ~]# dig -t axfr linuxpanda.tech @192.168.46.7

    ; <<>> DiG 9.9.4-RedHat-9.9.4-50.el7 <<>> -t axfr linuxpanda.tech @192.168.46.7
    ;; global options: +cmd
    linuxpanda.tech.	86400	IN	SOA	ns1.linuxpanda.tech. nsadmin.linuxpanda.tech. 0 86400 3600 604800 10800
    linuxpanda.tech.	86400	IN	NS	ns1.linuxpanda.tech.
    ns1.linuxpanda.tech.	86400	IN	A	192.168.46.7
    www.linuxpanda.tech.	86400	IN	A	192.168.46.7
    linuxpanda.tech.	86400	IN	SOA	ns1.linuxpanda.tech. nsadmin.linuxpanda.tech. 0 86400 3600 604800 10800
    ;; Query time: 1 msec
    ;; SERVER: 192.168.46.7#53(192.168.46.7)
    ;; WHEN: Thu Jan 18 00:44:18 EST 2018
    ;; XFR size: 5 records (messages 1, bytes 167)

主从
--------------------------------------------------------------------------------------------

上面我们在192.168.46.7的服务器上面配置了dns，下面以192.168.46.101作为7的从dns来完整dns的主从配置

.. note:: 在选择主从服务器的时候，注意服务器版本问题，不同版本安装的bind可能会导致不同情况，无法同步问题。


编辑配置文件
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: bash

    [root@localhost ~]# vim /etc/named.conf
    #注释以下行，使用//注释
    //      listen-on port 53 { 127.0.0.1; };
    //      allow-query     { localhost; };
    # 修改下面2项为no
    dns no;
    dnssec-validation no;
    # 添加如下配置
    allow-transfer { 192.168.46.101;};

添加区域文件
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    # 主服务器修改

    [root@7 named]# cat linuxpanda.tech.zone 
    $TTL 1D
    @	IN SOA	ns1 nsadmin (
                        0	; serial
                        1D	; refresh
                        1H	; retry
                        1W	; expire
                        3H )	; minimum
        NS	ns1
        NS      ns2
    ns1	A       192.168.46.7	
    ns2     A       192.168.46.101
    www     A       192.168.46.7

    # 从服务器修改
    [root@101 ~]# vim /etc/named.rfc1912.zones 
    zone "linuxpanda.tech" IN { 
            type slave;
            master { 192.168.46.7;}
            file "slaves/linuxpanda.tech.slave.zone";
    };

.. note:: 从服务器的必须要在主dns添加记录的。

重启服务
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    
    [root@101 named]# systemctl restart named               # 重启服务
    [root@101 named]# ll slaves/                            # 发现文件已经同步过来了。
    total 4
    -rw-r--r--. 1 named named 283 Jan 18 01:36 linuxpanda.tech.slave.zone
    [root@101 named]# file slaves/linuxpanda.tech.slave.zone 
    slaves/linuxpanda.tech.slave.zone: data

.. note:: centos7环境下从文件都是data的了，不再是文本了。

测试
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@101 named]# dig -t axfr linuxpanda.tech  @192.168.46.101          # 测试下，发下不对啊。

    ; <<>> DiG 9.9.4-RedHat-9.9.4-50.el7 <<>> -t axfr linuxpanda.tech @192.168.46.101
    ;; global options: +cmd
    linuxpanda.tech.	86400	IN	SOA	ns1.linuxpanda.tech. nsadmin.linuxpanda.tech. 0 86400 3600 604800 10800
    linuxpanda.tech.	86400	IN	NS	ns1.linuxpanda.tech.
    ns1.linuxpanda.tech.	86400	IN	A	192.168.46.7
    www.linuxpanda.tech.	86400	IN	A	192.168.46.7
    linuxpanda.tech.	86400	IN	SOA	ns1.linuxpanda.tech. nsadmin.linuxpanda.tech. 0 86400 3600 604800 10800
    ;; Query time: 1 msec
    ;; SERVER: 192.168.46.101#53(192.168.46.101)
    ;; WHEN: Thu Jan 18 01:44:01 EST 2018
    ;; XFR size: 5 records (messages 1, bytes 167)

    [root@7 named]# rndc reload                                             #    这个在主机器上执行下。 
    [root@101 named]# rndc reload                                           #    这个在从服务器执行
    server reload successful
    [root@101 named]# dig -t axfr linuxpanda.tech  @192.168.46.101

    ; <<>> DiG 9.9.4-RedHat-9.9.4-50.el7 <<>> -t axfr linuxpanda.tech @192.168.46.101
    ;; global options: +cmd
    linuxpanda.tech.	86400	IN	SOA	ns1.linuxpanda.tech. nsadmin.linuxpanda.tech. 1 86400 3600 604800 10800
    linuxpanda.tech.	86400	IN	NS	ns1.linuxpanda.tech.
    linuxpanda.tech.	86400	IN	NS	ns2.linuxpanda.tech.
    ns1.linuxpanda.tech.	86400	IN	A	192.168.46.7
    ns2.linuxpanda.tech.	86400	IN	A	192.168.46.101
    www.linuxpanda.tech.	86400	IN	A	192.168.46.7
    linuxpanda.tech.	86400	IN	SOA	ns1.linuxpanda.tech. nsadmin.linuxpanda.tech. 1 86400 3600 604800 10800
    ;; Query time: 0 msec
    ;; SERVER: 192.168.46.101#53(192.168.46.101)
    ;; WHEN: Thu Jan 18 01:45:02 EST 2018
    ;; XFR size: 7 records (messages 1, bytes 201)

进一步测试
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

主服务器修改下

.. code-block:: bash

        [root@7 named]# !vim 
        vim linuxpanda.tech.zone   
        [root@7 named]# cat linuxpanda.tech.zone        # 添加了blog记录并修改了序号为2（原有基础上+1）
        $TTL 1D
        @	IN SOA	ns1 nsadmin (
                            2	; serial
                            1D	; refresh
                            1H	; retry
                            1W	; expire
                            3H )	; minimum
            NS	ns1
            NS      ns2
        ns1	A       192.168.46.7	
        ns2     A       192.168.46.101
        www     A       192.168.46.7
        blog    A       192.168.46.101
        [root@7 named]# rndc reload                     # 重新加载配置文件
        server reload successful


从服务器测试

.. code-block:: bash

    [root@101 named]# dig -t axfr linuxpanda.tech  @192.168.46.101                                  # 查询测试，发现我们在主dns上的blog记录已经添加进来了

    ; <<>> DiG 9.9.4-RedHat-9.9.4-50.el7 <<>> -t axfr linuxpanda.tech @192.168.46.101
    ;; global options: +cmd
    linuxpanda.tech.	86400	IN	SOA	ns1.linuxpanda.tech. nsadmin.linuxpanda.tech. 2 86400 3600 604800 10800
    linuxpanda.tech.	86400	IN	NS	ns1.linuxpanda.tech.
    linuxpanda.tech.	86400	IN	NS	ns2.linuxpanda.tech.
    blog.linuxpanda.tech.	86400	IN	A	192.168.46.101
    ns1.linuxpanda.tech.	86400	IN	A	192.168.46.7
    ns2.linuxpanda.tech.	86400	IN	A	192.168.46.101
    www.linuxpanda.tech.	86400	IN	A	192.168.46.7
    linuxpanda.tech.	86400	IN	SOA	ns1.linuxpanda.tech. nsadmin.linuxpanda.tech. 2 86400 3600 604800 10800
    ;; Query time: 1 msec
    ;; SERVER: 192.168.46.101#53(192.168.46.101)
    ;; WHEN: Thu Jan 18 01:50:21 EST 2018
    ;; XFR size: 8 records (messages 1, bytes 222)



    [root@101 named]# cat /var/log/messages                                                         # 查看下日志关于named的信息
    --------------------------省去一部分-----------------------------------------------------------
    Jan 18 01:48:49 station named[7809]: client 192.168.46.7#43665: received notify for zone 'linuxpanda.tech'
    Jan 18 01:48:49 station named[7809]: zone linuxpanda.tech/IN: Transfer started.
    Jan 18 01:48:49 station named[7809]: transfer of 'linuxpanda.tech/IN' from 192.168.46.7#53: connected using 192.168.46.101#48087
    Jan 18 01:48:49 station named[7809]: zone linuxpanda.tech/IN: transferred serial 2
    Jan 18 01:48:49 station named[7809]: transfer of 'linuxpanda.tech/IN' from 192.168.46.7#53: Transfer completed: 1 messages, 8 records, 222 bytes, 0.010 secs (22200 bytes/sec)
    Jan 18 01:48:49 station named[7809]: zone linuxpanda.tech/IN: sending notifies (serial 2)
    Jan 18 01:49:23 station named[7809]: client 192.168.46.101#59454 (linuxpanda.tech): transfer of 'linuxpanda.tech/IN': AXFR started
    Jan 18 01:49:23 station named[7809]: client 192.168.46.101#59454 (linuxpanda.tech): transfer of 'linuxpanda.tech/IN': AXFR ended

.. note:: 如果从DNS服务器没法同步，请检查服务器配置和2个服务器的日志信息

允许远程动态更新
---------------------------------------------------------

主服务器修改
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
   
.. code-block:: bash

    [root@7 named]# vim /etc/named.rfc1912.zones       # 添加允许更新
    zone "linuxpanda.tech" IN {
            type master;
            file "linuxpanda.tech.zone";
            allow-update { 192.168.46.101;} ;
    };
    [root@7 named]# chmod g+w /var/named/                # 给named添加目录写权限，
    [root@7 named]# systemctl restart named              # 重启服务

从服务器来更新
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@101 named]# nsupdate 
    > server 192.168.46.7
    > zone linuxpanda.tech
    > update add ftp.linuxpanda.tech. 9000 IN A 192.168.46.101
    > send
    > quit

主服务器测试
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@7 named]# ll -t                                                    # 查看文件
    total 28
    -rw-r--r--. 1 named named  757 Jan 18 16:02 linuxpanda.tech.zone.jnl
    -rw-r-----. 1 root  named  256 Jan 18 14:47 linuxpanda.tech.zone
    -rw-r-----. 1 root  named  258 Jan 18 12:32 192.168.46.zone
    drwxrwx---. 2 named named   31 Jan 17 20:43 dynamic
    drwxrwx---. 2 named named   23 Jan 17 20:23 data
    drwxrwx---. 2 named named    6 Aug  4 16:13 slaves
    -rw-r-----. 1 root  named 2281 May 22  2017 named.ca
    -rw-r-----. 1 root  named  152 Dec 15  2009 named.empty
    -rw-r-----. 1 root  named  168 Dec 15  2009 named.loopback
    -rw-r-----. 1 root  named  152 Jun 21  2007 named.localhost
    [root@7 named]# cat linuxpanda.tech.zone.jnl                            # 查看下这个是啥
    [root@7 named]# dig -t axfr linuxpanda.tech. @192.168.46.7 |grep ftp    # 查看添加的记录
    ftp.linuxpanda.tech.	9000	IN	A	192.168.46.101

.. note:: 动态更新后，从服务器也会自动更新的，但是序号是没有增加的。

启用查询日志记录
---------------------------------------------------------

这个启用dns查询日志记录功能， 不建议开启的（大量日志操作），只有在调试dns配置的时候开启。

.. code-block:: bash

    [root@7 named]# rndc status
    version: 9.9.4-RedHat-9.9.4-50.el7 <id:8f9657aa>
    CPUs found: 1
    worker threads: 1
    UDP listeners per interface: 1
    number of zones: 103
    debug level: 0
    xfers running: 0
    xfers deferred: 0
    soa queries in progress: 0
    query logging is OFF
    recursive clients: 0/0/1000
    tcp clients: 0/100
    server is up and running
    [root@7 named]# rndc querylog
    [root@7 named]# rndc status |grep logging
    query logging is ON
    [root@7 named]# rndc querylog
    [root@7 named]# rndc status |grep logging
    query logging is OFF


子域配置
---------------------------------------------------------

配置子域需要的服务器也比较多。 简单规划下。

- 192.168.46.7 : linuxpanda.tech
- 192.168.46.101 : henan.linuxpanda.tech
- 192.168.46.102 : zhengzhou.henan.linuxpanda.tech

我这里linuxpanda.tech 就认为是我自己的顶级域。 henan就是二级域，zhengzhou就是三级域。

环境配置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

前面我使用了192.168.46.7和192.168.46.101两个机器，这个实验，我就重新安装下bind来覆盖原有设置了。

.. code-block:: bash

    # 192.168.46.7 机器上操作
    [root@7 named]# rm -rf /etc/named*
    [root@7 named]# rm -rf /var/named
    [root@7 named]# yum reinstall bind

    # 192.168.46.101 机器上操作
    [root@101 named]# rm -rf /etc/named*
    [root@102 named]# rm -rf /var/named
    [root@102 named]# yum reinstall bind

顶级域配置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@7 named]# vim /etc/named.conf 
    [root@localhost ~]# vim /etc/named.conf
    #注释以下行，使用//注释
    //      listen-on port 53 { 127.0.0.1; };
    //      allow-query     { localhost; };
    # 修改下面2项为no
    dnssec-enable no;
    dnssec-validation no;

    # 添加如下配置
    [root@7 named]# vim /etc/named.rfc1912.zones 
    zone "linuxpanda.tech" IN {
            type master;
            file "linuxpanda.tech.zone";
    }
    ;

    # 添加区域文件
    [root@7 named]# cd /var/named/
    [root@7 named]# ls
    data  dynamic  named.ca  named.empty  named.localhost  named.loopback  slaves
    [root@7 named]# cp named.localhost  linuxpanda.tech.zone -p
    [root@7 named]# vim linuxpanda.tech.zone 
    [root@7 named]# cat linuxpanda.tech.zone 
    $TTL 1D
    @       IN SOA  ns1 nsadmin (
                                            0       ; serial
                                            1D      ; refresh
                                            1H      ; retry
                                            1W      ; expire
                                            3H )    ; minimum
            NS      ns1
    henan   NS      ns2
    ns1     A       192.168.46.7
    ns2   A         192.168.46.101
    www     A       192.168.46.7



    # 配置测试
    [root@7 named]# named-checkconf 
    [root@7 named]# named-checkzone  linuxpanda.tech linuxpanda.tech.zone 
    # 启动服务
    [root@7 named]# systemctl restart named

一级域配置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


.. code-block:: bash

    [root@7 named]# vim /etc/named.conf 
    [root@localhost ~]# vim /etc/named.conf
    #注释以下行，使用//注释
    //      listen-on port 53 { 127.0.0.1; };
    //      allow-query     { localhost; };
    # 修改下面2项为no
    dnssec-enable no;
    dnssec-validation no;

    # 添加如下配置
    [root@7 named]# vim /etc/named.rfc1912.zones 
    zone "henan.linuxpanda.tech" IN {
            type master;
            file "henan.linuxpanda.tech.zone";
    };


    # 添加区域文件
    [root@7 named]# cd /var/named/
    [root@7 named]# ls
    data  dynamic  named.ca  named.empty  named.localhost  named.loopback  slaves
    [root@7 named]# cp -p named.localhost  henan.linuxpanda.tech.zone 
    [root@7 named]# vim henan.linuxpanda.tech.zone 
    [root@7 named]# cat henan.linuxpanda.tech.zone 
    $TTL 1D
    @       IN SOA  ns1 nsadmin (
                                            0       ; serial
                                            1D      ; refresh
                                            1H      ; retry
                                            1W      ; expire
                                            3H )    ; minimum
                    NS       ns1
    zhengzhou       NS       ns2
    ns1     A       192.168.46.101
    ns2  A   192.168.46.102
    www        A    192.168.46.101

    # 配置测试
    [root@7 named]# named-checkconf 
    [root@7 named]# named-checkzone  henan.linuxpanda.tech henan.linuxpanda.tech.zone 
    # 启动服务
    [root@7 named]# systemctl restart named

二级域配置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@7 named]# vim /etc/named.conf 
    [root@localhost ~]# vim /etc/named.conf
    #注释以下行，使用//注释
    //      listen-on port 53 { 127.0.0.1; };
    //      allow-query     { localhost; };
    # 修改下面2项为no
    dnssec-enable no;
    dnssec-validation no;

    # 添加如下配置
    [root@7 named]# vim /etc/named.rfc1912.zones 
    zone "zhengzhou.henan.linuxpanda.tech" IN {
            type master;
            file "zhengzhou.henan.linuxpanda.tech.zone";
    };


    # 添加区域文件
    [root@7 named]# cd /var/named/
    [root@7 named]# ls
    data  dynamic  named.ca  named.empty  named.localhost  named.loopback  slaves
    [root@7 named]# cp -p named.localhost  linuxpanda.tech.zone 
    [root@7 named]# vim zhengzhou.henan.linuxpanda.tech.zone 
    [root@7 named]# cat zhengzhou.henan.linuxpanda.tech.zone 
    $TTL 1D
    @	IN SOA	ns1 nsadmin (
                        0	    ; serial
                        1D	    ; refresh
                        1H	    ; retry
                        1W	    ; expire
                        3H )	; minimum
        NS       ns1	
        NS       zhengzhou
    ns1	A	192.168.46.101
    zhengzhou  A   192.168.46.102
    www        A    192.168.46.101
    web     CNAME   www

    # 配置测试
    [root@7 named]# named-checkconf 
    [root@7 named]# named-checkzone  zhengzhou.henan.linuxpanda.tech zhengzhou.henan.linuxpanda.tech.zone 
    # 启动服务
    [root@7 named]# systemctl restart named

测试下

在192.168.46.7上面验证下： 

.. code-block:: bash

    [root@7 named]# host web.zhengzhou.henan.linuxpanda.tech 192.168.46.7
    Using domain server:
    Name: 192.168.46.7
    Address: 192.168.46.7#53
    Aliases: 

    web.zhengzhou.henan.linuxpanda.tech is an alias for www.zhengzhou.henan.linuxpanda.tech.
    www.zhengzhou.henan.linuxpanda.tech has address 192.168.46.102


转发服务器
---------------------------------------------------------

转发分为2种： 

- 全局转发： 全局配置文件设置
- 特定域转发： 特定域内配置

转发类型2种： 

- first： 转发给特定服务器，如果他没有就在找自己找根。
- only: 抓饭给特定服务器，如果他找不到自己不继续找。

.. note:: 请关闭dnssec功能。

我这里接着上面的实验基础上的， 上面我做了3级别的域 linuxpanda.tech ,henan.linuxpanda.tech ,zhengzhou.henan.linuxpanda.tech 

给henan.linxupanda.tech配置特定域转发

.. code-block:: bash

    [root@101 ~]# vim /etc/named.rfc1912.zones 
    # 添加如何内容
    zone "linuxpanda.tech" IN {
            type forward;
            forward first;
            forwarders { 192.168.46.7; };

给zhengzhou.henan.linxupanda.tech配置特定域转发

.. code-block:: bash

    [root@102 ~]# vim /etc/named.rfc1912.zones 
    # 添加如何内容
    zone "henan.linuxpanda.tech" IN {
            type forward;
            forward first;
            forwarders { 192.168.46.101; };
    };
    zone "linuxpanda.tech" IN {
            type forward;
            forward first;
            forwarders { 192.168.46.101; };
    };

.. note:: 修改配置文件后需要重启服务或者使用rndc reload重新加载配置文件。

测试

.. code-block:: bash

    # 我们先测试我内部的服务器的dns主机

    [root@102 ~]$ host ns2.linuxpanda.tech 192.168.46.102
    Using domain server:
    Name: 192.168.46.102
    Address: 192.168.46.102#53
    Aliases: 

    ns2.linuxpanda.tech has address 192.168.46.101
    # 上面可以看到，我们的都给转发了。
    # 下面测试一个内部dns没有的主机wwwxx,结构跑到互联网上给我们解析了，如果forward 设置only，就不会在去解析了。
    [root@102 ~]$ host wwwxx.linuxpanda.tech 
    wwwxx.linuxpanda.tech has address 39.106.157.220
    # 这个ip就是我买的云服务器ip，域名解析到这个ip了。

view
---------------------------------------------------------

压力测试
---------------------------------------------------------

排错
---------------------------------------------------------
