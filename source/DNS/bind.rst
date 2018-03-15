bind
============================================

dns简介
---------------------------------------------------------

DNS（domain name service ）是域名解析服务，工作在应用层，是c/s结构，监听于53端口。

- tcp 53: 用于区域传输
- ucp 53: 用于查询



常见概念
---------------------------------------------------------

BIND(Bekerley Internet Name Domain) 是伯克利互联网名称域。提供了DNS服务。

DNS查询类型： 

- 递归查询
- 迭代查询

服务器类型： 

- 主dns:      管理和负责解析域的服务器
- 从dns：     从服务器从主服务器复制库
- 缓存dns：   缓存dns

区域传输： 

- 完全传输：   传输整个库
- 增量传输：    传递变化的部分内容

解析流程： 

client->hosts->local dns cache->dns server -> server cache-> root -> 二级域

解析答案： 

- 肯定答案： 有对应条目
- 否定答案： 没有对应条目
- 权威答案： 请求的主机就有对应的条目
- 非权威答案： 请求的主机没有，通过迭代找到的答案

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
    # 一条记录的对应位置没有写，会自动集成上一行的对应设置。

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
 	dnssec-enable no;
	dnssec-validation no;

    # 在主配置文件添加对应的区域
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


    [root@localhost named]# cp named.localhost linuxpanda.tech.zone -p      # -p选项保留权限信息，权限不对dns是没法工作的。
    [root@localhost named]# ll                                              # 检查下权限
    total 20
    drwxrwx---. 2 named named    6 Aug  4 16:13 data
    drwxrwx---. 2 named named    6 Aug  4 16:13 dynamic
    -rw-r-----. 1 root  named  152 Jun 21  2007 linuxpanda.tech.zone
    -rw-r-----. 1 root  named 2281 May 22  2017 named.ca
    -rw-r-----. 1 root  named  152 Dec 15  2009 named.empty
    -rw-r-----. 1 root  named  152 Jun 21  2007 named.localhost
    -rw-r-----. 1 root  named  168 Dec 15  2009 named.loopback
    drwxrwx---. 2 named named    6 Aug  4 16:13 slaves
    [root@localhost named]# vim linuxpanda.tech.zone                        # 编辑区域文件
    [root@localhost named]# cat linuxpanda.tech.zone                        # 检查下区域文件
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

    [root@localhost named]# named-checkconf                                         # 检查主配置文件
    [root@localhost named]# named-checkzone linuxpanda.tech linuxpanda.tech.zone    # 检查区域文件
    zone linuxpanda.tech/IN: loaded serial 0
    OK

重启下dns服务
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@localhost named]# systemctl restart named                                 # 重启服务

测试
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

host方式测试

.. code-block:: bash

    [root@localhost named]# host www.linuxpanda.tech localhost                      # 通过localhost作为dns来测试。
    Using domain server:
    Name: localhost
    Address: ::1#53
    Aliases: 

    www.linuxpanda.tech has address 192.168.46.7

.. note:: 这里指定了localhost做为dns，如果不想指定，在/etc/resolve.conf文件添加ip即可。

dig方式测试

.. code-block:: bash

    [root@localhost named]# dig ns1.linuxpanda.tech @localhost                      # 使用dig测试

    ; <<>> DiG 9.9.4-RedHat-9.9.4-50.el7 <<>> ns1.linuxpanda.tech @localhost
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 35168
    ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 1        # aa代表权威答案。

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

    [root@localhost named]# nslookup                                                # nslookup测试，这个工具和windows环境的使用是一样的。
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

    [root@localhost named]# vim /etc/named.rfc1912.zones                            # 添加区域配置
    zone "46.168.192.in-addr.arpa" IN {
            type master;
            file "192.168.46.zone";
    };

.. warning:: 一定注意{}后面的;号了。最容易忘记了。


添加区域文件

.. code-block:: bash

    [root@localhost named]# cp named.loopback  192.168.46.zone -p               # 创建一个区域文件
    [root@localhost named]# vim 192.168.46.zone                                 # 编辑
    [root@localhost named]# cat 192.168.46.zone                                 # 检查
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

    [root@localhost named]# named-checkconf                                          # 检查配置文件
    [root@localhost named]# named-checkzone  46.168.192.in-addr.arpa 192.168.46.zone # 检查区域文件

测试

.. code-block:: bash

    [root@localhost named]# rndc reload                                             # 重新加载dns配置文件
    server reload successful

    [root@localhost named]# host 192.168.46.7 192.168.46.7                          # 测试
    Using domain server:
    Name: 192.168.46.7
    Address: 192.168.46.7#53
    Aliases: 

    7.46.168.192.in-addr.arpa domain name pointer ns1.linuxpanda.tech.
    7.46.168.192.in-addr.arpa domain name pointer www.linuxpanda.tech.

    # 另一个主机测试
    [root@101 ~]# dig -t axfr linuxpanda.tech @192.168.46.7                         # 完全区域传输，走的tcp协议，普通查询走的udp协议

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

主从服务器
--------------------------------------------------------------------------------------------

上面我们在192.168.46.7的服务器上面配置了dns，下面以192.168.46.101作为7的从dns来完成dns的主从配置

.. note:: 在选择主从服务器的时候，注意服务器版本问题，不同版本安装的bind可能会导致不同情况，无法同步问题。


编辑配置文件
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: bash

    [root@localhost ~]# vim /etc/named.conf                 # 编辑主配置文件
    #注释以下行，使用//注释
    //      listen-on port 53 { 127.0.0.1; };
    //      allow-query     { localhost; };
    # 修改下面2项为no
	dnssec-enable no;
	dnssec-validation no;
    # 添加如下配置
    allow-transfer { 192.168.46.101;};

添加区域文件
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    # 主服务器修改

    [root@7 named]# cat linuxpanda.tech.zone           # 编辑区域文件
    [root@7 named]# cat linuxpanda.tech.zone           # 检查区域文件，确保有从服务器的ns记录和对应的a记录
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
    [root@101 ~]# vim /etc/named.rfc1912.zones      # 从服务器添加区域，设置与主服务器的关联配置
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

    [root@101 named]# dig -t axfr linuxpanda.tech  @192.168.46.101          # 测试下，发现不对啊。

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

    [root@7 named]# rndc reload                                             #    这个在主服务器上执行下。 
    [root@101 named]# rndc reload                                           #    这个在从服务器上执行
    server reload successful
    [root@101 named]# dig -t axfr linuxpanda.tech  @192.168.46.101          # 再次测试

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
        [root@7 named]# cat linuxpanda.tech.zone        # 添加了blog记录并修改了序号为2（原有基础上+1），这个必须比原有的数值大，才有效。
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

    [root@101 named]# dig -t axfr linuxpanda.tech  @192.168.46.101            # 查询测试，发现我们在主dns上的blog记录已经添加进来了

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



    [root@101 named]# cat /var/log/messages                        # 查看下日志关于named的信息
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

    [root@101 named]# nsupdate                           # 这个命令是交互的
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

    [root@7 named]# rndc status                             # 查看dns状态信息
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
    [root@7 named]# rndc querylog                           # 日志切换命令，off->on,on->off
    [root@7 named]# rndc status |grep logging               # 查看
    query logging is ON
    [root@7 named]# rndc querylog                           # 日志切换      
    [root@7 named]# rndc status |grep logging               # 查看
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
    [root@7 named]# cp named.localhost  linuxpanda.tech.zone -p             # 保留权限
    [root@7 named]# vim linuxpanda.tech.zone                                # 添加区域
    [root@7 named]# cat linuxpanda.tech.zone                                # 检查区域
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
    [root@7 named]# named-checkconf                                         # 检查配置
    [root@7 named]# named-checkzone  linuxpanda.tech linuxpanda.tech.zone   # 检查区域
    # 启动服务
    [root@7 named]# systemctl restart named                                 # 重启服务

一级域配置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


.. code-block:: bash

    [root@7 named]# vim /etc/named.conf                                     # 编辑主配置              
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
    [root@7 named]# cp -p named.localhost  henan.linuxpanda.tech.zone   # 保留权限
    [root@7 named]# vim henan.linuxpanda.tech.zone                      # 编辑区域文件
    [root@7 named]# cat henan.linuxpanda.tech.zone                      # 检查区域文件
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
    [root@7 named]# named-checkconf                                                      # 检查主配置文件
    [root@7 named]# named-checkzone  henan.linuxpanda.tech henan.linuxpanda.tech.zone    # 检查区域文件
    # 启动服务
    [root@7 named]# systemctl restart named                                              # 重启服务

二级域配置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@7 named]# vim /etc/named.conf                             # 编辑主配置文件
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
    [root@7 named]# cp -p named.localhost  linuxpanda.tech.zone         # 保留权限
    [root@7 named]# vim zhengzhou.henan.linuxpanda.tech.zone            # 编辑配置文件
    [root@7 named]# cat zhengzhou.henan.linuxpanda.tech.zone            # 检查配置文件
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
    [root@7 named]# named-checkconf                                                                       # 配置文件检查
    [root@7 named]# named-checkzone  zhengzhou.henan.linuxpanda.tech zhengzhou.henan.linuxpanda.tech.zone # 区域文件检查
    # 启动服务
    [root@7 named]# systemctl restart named                                                               # 重启

测试下

在192.168.46.7上面验证下： 

.. code-block:: bash

    [root@7 named]# host web.zhengzhou.henan.linuxpanda.tech 192.168.46.7                               # 测试
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
- only: 抓发给特定服务器，如果他找不到自己不继续找。

.. note:: 请关闭dnssec功能。

我这里接着上面的实验基础上的， 上面我做了3级别的域 linuxpanda.tech ,henan.linuxpanda.tech ,zhengzhou.henan.linuxpanda.tech 

给henan.linxupanda.tech配置特定域转发

.. code-block:: bash

    [root@101 ~]# vim /etc/named.rfc1912.zones              # 编辑主配置文件
    # 添加如何内容
    zone "linuxpanda.tech" IN {
            type forward;
            forward first;
            forwarders { 192.168.46.7; };

给zhengzhou.henan.linxupanda.tech配置特定域转发

.. code-block:: bash

    [root@102 ~]# vim /etc/named.rfc1912.zones            # 编辑主配置文件
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

    [root@102 ~]$ host ns2.linuxpanda.tech 192.168.46.102           # 测试192.168.46.7机器上面有的服务器。
    Using domain server:
    Name: 192.168.46.102
    Address: 192.168.46.102#53
    Aliases: 

    ns2.linuxpanda.tech has address 192.168.46.101
    # 上面可以看到，我们的都给转发了。
    # 下面测试一个内部dns没有的主机wwwxx,结构跑到互联网上给我们解析了，如果forward 设置only，就不会在去解析了。
    [root@102 ~]$ host wwwxx.linuxpanda.tech                        # 测试一个192.168.46.7机器上面没有的服务器
    wwwxx.linuxpanda.tech has address 39.106.157.220
    # 这个ip就是我买的云服务器ip，域名解析到这个ip了。

view
---------------------------------------------------------

定义acl
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@centos7 ~]# vim /etc/named.conf 
    acl netdianxin { 192.168.1.0/24;};
    acl netyidong { 192.168.46.0/24;};
    acl netother { any;};

迁移根区域
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: bash

    [root@centos7 ~]# !vim /etc/named.conf 
    # 删除下面的4行数据
    zone "." IN {
            type hint;
            file "named.ca";
    };
    [root@centos7 ~]# vim /etc/named.rfc1912.zones 
    # 添加上面删除的4行数据
    zone "." IN {
            type hint;
            file "named.ca";
    };

配置view
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text

    [root@centos7 ~]# cat /etc/named.conf 
    //
    // named.conf
    //
    // Provided by Red Hat bind package to configure the ISC BIND named(8) DNS
    // server as a caching only nameserver (as a localhost DNS resolver only).
    //
    // See /usr/share/doc/bind*/sample/ for example named configuration files.
    //
    // See the BIND Administrator's Reference Manual (ARM) for details about the
    // configuration located in /usr/share/doc/bind-{version}/Bv9ARM.html
    acl netdianxin { 192.168.46.0/24;};
    acl netyidong { 192.168.1.0/24;};
    acl netother { any;};
    options {
    //	listen-on port 53 { 127.0.0.1; };
        listen-on-v6 port 53 { ::1; };
        directory 	"/var/named";
        dump-file 	"/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
    //	allow-query     { localhost; };

        /* 
        - If you are building an AUTHORITATIVE DNS server, do NOT enable recursion.
        - If you are building a RECURSIVE (caching) DNS server, you need to enable 
        recursion. 
        - If your recursive DNS server has a public IP address, you MUST enable access 
        control to limit queries to your legitimate users. Failing to do so will
        cause your server to become part of large scale DNS amplification 
        attacks. Implementing BCP38 within your network would greatly
        reduce such attack surface 
        */
        recursion yes;

        dnssec-enable no;
        dnssec-validation no;

        /* Path to ISC DLV key */
        bindkeys-file "/etc/named.iscdlv.key";

        managed-keys-directory "/var/named/dynamic";

        pid-file "/run/named/named.pid";
        session-keyfile "/run/named/session.key";
    };

    logging {
            channel default_debug {
                    file "data/named.run";
                    severity dynamic;
            };
    };

    view viewdianxin {
        match-clients {netdianxin;};
        zone "linuxpanda.tech" {
            type master;
            file "linuxpanda.tech.netdianxin.zone";	
        };
        include "/etc/named.rfc1912.zones";

    };
    view viewyidong{
        match-clients {netyidong;};
        zone "linuxpanda.tech" {
            type master;
            file "linuxpanda.tech.netyidong.zone";	
        };
        include "/etc/named.rfc1912.zones";

    };

    include "/etc/named.root.key";

添加文件
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@centos7 named]# mv  linuxpanda.tech.zone linuxpanda.tech.netdianxin.zone
    [root@centos7 named]# cp linuxpanda.tech.netdianxin.zone linuxpanda.tech.netyidong.zone 
    [root@centos7 named]# vim linuxpanda.tech.netdianxin.zone 
    [root@centos7 named]# cp linuxpanda.tech.netdianxin.zone linuxpanda.tech.netyidong.zone 
    cp: overwrite ‘linuxpanda.tech.netyidong.zone’? y
    [root@centos7 named]# vim linuxpanda.tech.netyidong.zone 
    [root@centos7 named]# cat linuxpanda.tech.netdianxin.zone 
    $TTL 1D
    @	IN SOA	ns1 nsadmin (
                        0	; serial
                        1D	; refresh
                        1H	; retry
                        1W	; expire
                        3H )	; minimum
        NS      ns1	
    ns1	A       192.168.46.7
    www	A       192.168.46.7
    [root@centos7 named]# cat linuxpanda.tech.netyidong.zone 
    $TTL 1D
    @	IN SOA	ns1 nsadmin (
                        0	; serial
                        1D	; refresh
                        1H	; retry
                        1W	; expire
                        3H )	; minimum
        NS      ns1	
    ns1	A       192.168.1.103
    www	A       192.168.1.103

验证
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

第一个网段测试

.. code-block:: bash

    [root@102 ~]$ dig www.linuxpanda.tech @192.168.46.7

    ; <<>> DiG 9.9.4-RedHat-9.9.4-51.el7_4.1 <<>> www.linuxpanda.tech @192.168.46.7
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 33006
    ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 2

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;www.linuxpanda.tech.		IN	A

    ;; ANSWER SECTION:
    www.linuxpanda.tech.	86400	IN	A	192.168.46.7

    ;; AUTHORITY SECTION:
    linuxpanda.tech.	86400	IN	NS	ns1.linuxpanda.tech.

    ;; ADDITIONAL SECTION:
    ns1.linuxpanda.tech.	86400	IN	A	192.168.46.7

    ;; Query time: 0 msec
    ;; SERVER: 192.168.46.7#53(192.168.46.7)
    ;; WHEN: Sat Jan 20 17:13:13 CST 2018
    ;; MSG SIZE  rcvd: 98

第二个网段测试

.. code-block:: bash

    [root@101 ~]# dig www.linuxpanda.tech @192.168.1.103

    ; <<>> DiG 9.9.4-RedHat-9.9.4-50.el7 <<>> www.linuxpanda.tech @192.168.1.103
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 158
    ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 2

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;www.linuxpanda.tech.		IN	A

    ;; ANSWER SECTION:
    www.linuxpanda.tech.	86400	IN	A	192.168.1.103

    ;; AUTHORITY SECTION:
    linuxpanda.tech.	86400	IN	NS	ns1.linuxpanda.tech.

    ;; ADDITIONAL SECTION:
    ns1.linuxpanda.tech.	86400	IN	A	192.168.1.103

    ;; Query time: 0 msec
    ;; SERVER: 192.168.1.103#53(192.168.1.103)
    ;; WHEN: Sat Jan 20 04:13:29 EST 2018
    ;; MSG SIZE  rcvd: 98

互联网dns实现
----------------------------------------------------------

绘制架构图
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

这个实现情况布局比较复杂，需要先构思一个草图，简单如下： 

.. image:: /images/dns/互联网dns.png

服务器规划
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

为了方便后续配置简单设置下主机名如下

.. code-block:: text

    主根： root1
    从根： root2
    tech域： tech
    com域：   com
    linuxpanda: linuxpanda
    www1:www1
    www2:www2
    运营商：dianxin
    client:client

ip配置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

根据上面的配置设置ip信息。 

.. code-block:: bash

    #  nmcli con del ens33 ; 
    #  nmcli con add con-name ens33 ifname ens33 type ethernet ipv4.method manual \
        ivp4.ipaddress 192.168.46.151/24 ipv4.gateway 192.168.46.1
    #  nmcli con up ens33
    主机名字配置。
    # hostnamectl set-hostname centos-151

安装bind软件
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

给所有主机安装bind.

我这里使用ansible批量安装了。

.. code-block:: bash

    # 给所有主机安装下bind,bind_utils工具
    [root@centos7 ansible]# ansible dns -m yum -a 'name=bind,bind-utils'
    # 编辑下配置文件， 然后copy配置文件到所有目标主机上去，省去后续配置麻烦。
    [root@centos7 ~]# vim /etc/named.conf 
    [root@centos7 ~]# ansible dns -m copy -a 'src=/etc/named.conf dest=/etc/named.conf'

主根配置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    # 自身是根了， 所有就不能有所有的互联网上的根了。替换掉。
    # 修改前的
    zone "." IN {
            type hint;
            file "named.ca";
    };
    # 修改后的
    zone "." IN {
            type master;
            file "root.zone";
    };

    [root@151 named]# cat root.zone 
    $TTL 1D
    @	IN SOA	ns1 admin (
                        0	; serial
                        1D	; refresh
                        1H	; retry
                        1W	; expire
                        3H )	; minimum
        NS      ns1	
        NS      ns2
    tech    NS      nstech
    com     NS      nscom
    ns1     A      192.168.46.151
    ns2     A	192.168.46.152
    nstech  A      192.168.46.153
    nscom   A      192.168.46.154

    # 主的配置给从发送一份
    [root@centos-151 named]# scp /etc/named.conf  192.168.46.152:/etc/
    [root@centos-151 named]# systemctl restart named

从根配置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

上面已经copy过来一个named.conf文件， 修改下。

.. code-block:: bash

    zone "." IN {
        type slave;
        masters { 192.168.46.151; };
        file "slaves/root.zone";
    };

主从根测试
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@centos-151 named]# dig nstech  @localhost
    ; <<>> DiG 9.9.4-RedHat-9.9.4-50.el7 <<>> nstech @localhost
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 32324
    ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;nstech.				IN	A

    ;; ANSWER SECTION:
    nstech.			86400	IN	A	192.168.46.153

    ;; AUTHORITY SECTION:
    .			86400	IN	NS	ns2.
    .			86400	IN	NS	ns1.

    ;; ADDITIONAL SECTION:
    ns1.			86400	IN	A	192.168.46.151
    ns2.			86400	IN	A	192.168.46.152

    ;; Query time: 0 msec
    ;; SERVER: ::1#53(::1)
    ;; WHEN: Sun Jan 21 03:41:58 CST 2018
    ;; MSG SIZE  rcvd: 115

运营商配置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

运营商为客户提供dns服务，默认的根是13个网络上的，配置在named.ca文件中， 我们修改为我们自己的2个根。

.. code-block:: bash

    [root@centos-158 named]# vim named.ca
    [root@centos-158 named]# cat named.ca 

    .			518400	IN	NS	a.root-servers.net.
    .			518400	IN	NS	b.root-servers.net.
    a.root-servers.net.	3600000	IN	A	192.168.46.151
    b.root-servers.net.	3600000	IN	A	192.168.46.152

上面我们配置2个根， 一主一丛，这里需要对应的记录直接写入文件中去。

运营商测试
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
运营商的dns设置自身ip即可

.. code-block:: bash

    [root@centos-158 named]# dig ns1

    ; <<>> DiG 9.9.4-RedHat-9.9.4-50.el7 <<>> ns1
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 8276
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 2

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;ns1.				IN	A

    ;; ANSWER SECTION:
    ns1.			86400	IN	A	192.168.46.151

    ;; AUTHORITY SECTION:
    .			86400	IN	NS	ns2.
    .			86400	IN	NS	ns1.

    ;; ADDITIONAL SECTION:
    ns2.			86400	IN	A	192.168.46.152

    ;; Query time: 1 msec
    ;; SERVER: 192.168.46.158#53(192.168.46.158)
    ;; WHEN: Sun Jan 21 04:11:21 CST 2018
    ;; MSG SIZE  rcvd: 93


客户端配置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

客户端的dns设置为运营商的dns即可


客户端修改dns为运营商的ip即可

.. code-block:: bash

    [root@centos-159 ~]# nmcli con modify ens33 ipv4.gateway 192.168.46.158 ipv4.dns 192.168.46.158
    [root@centos-159 ~]# nmcli con up ens33

测试下

.. code-block:: bash

    [root@centos-159 ~]# dig nstech 

    ; <<>> DiG 9.9.4-RedHat-9.9.4-50.el7 <<>> nstech
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 64966
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;nstech.				IN	A

    ;; ANSWER SECTION:
    nstech.			86400	IN	A	192.168.46.153

    ;; AUTHORITY SECTION:
    .			86343	IN	NS	ns2.
    .			86343	IN	NS	ns1.

    ;; ADDITIONAL SECTION:
    ns2.			86343	IN	A	192.168.46.152
    ns1.			86343	IN	A	192.168.46.151

    ;; Query time: 1 msec
    ;; SERVER: 192.168.46.158#53(192.168.46.158)
    ;; WHEN: Sun Jan 21 04:12:18 CST 2018
    ;; MSG SIZE  rcvd: 115

一级域的配置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

一级域有2个，tech和com域的，

先配置tech域

.. code-block:: bash

    [root@centos-153 ~]# vim /etc/named.conf 
    [root@centos-153 ~]# vim /etc/named.rfc1912.zones 
    [root@centos-153 ~]# tail -n 5 /etc/named.rfc1912.zones 

    zone "tech" IN { 
        type master;
        file "tech.zone";
    } ; 

    [root@centos-153 ~]# cd /var/named/
    [root@centos-153 named]# ls
    data  dynamic  named.ca  named.empty  named.localhost  named.loopback  slaves
    [root@centos-153 named]# cp named.localhost  tech.zone -p
    [root@centos-153 named]# vim tech.zone 
    [root@centos-153 named]# cat tech.zone 
    $TTL 1D
    @	IN SOA	ns1 admin (
                        0	; serial
                        1D	; refresh
                        1H	; retry
                        1W	; expire
                        3H )	; minimum
        NS       ns1
    linuxpanda NS    nslinuxpanda
    ns1      A       192.168.46.153
    nslinuxpanda A    192.168.46.155
    [root@centos-153 named]# systemctl restart named
    [root@centos-153 named]# systemctl status named
    [root@centos-153 named]# dig ns1.tech 

在配置com域

.. code-block:: bash

    [root@centos-154 ~]# vim /etc/named.conf 
    [root@centos-154 ~]# vim /etc/named.rfc1912.zones 
    [root@centos-154 ~]# tail -n 5 /etc/named.rfc1912.zones 
    };
    zone "com" {  
        type master;
        file "com.zone";
    };
    [root@centos-154 ~]# cd /var/named/
    [root@centos-154 named]# cp named.localhost  com.zone -p
    [root@centos-154 named]# vim com.zone 
    [root@centos-154 named]# cat com.zone 
    $TTL 1D
    @	IN SOA	ns1 admin (
                        0	; serial
                        1D	; refresh
                        1H	; retry
                        1W	; expire
                        3H )	; minimum
        NS      ns1	
    ns1     A       192.168.46.154
    [root@centos-154 named]# dig ns1.com


顶级域测试
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

上面已经在顶级域的自己机器上面测试了，这次直接在客户端测试下，确保没错误

.. code-block:: bash

    [root@centos-159 ~]# dig ns1.tech 

    ; <<>> DiG 9.9.4-RedHat-9.9.4-50.el7 <<>> ns1.tech
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 24895
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 1

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;ns1.tech.			IN	A

    ;; ANSWER SECTION:
    ns1.tech.		86400	IN	A	192.168.46.153

    ;; AUTHORITY SECTION:
    tech.			86400	IN	NS	ns1.tech.

    ;; Query time: 1 msec
    ;; SERVER: 192.168.46.158#53(192.168.46.158)
    ;; WHEN: Sun Jan 21 04:27:50 CST 2018
    ;; MSG SIZE  rcvd: 67

    [root@centos-159 ~]# dig ns1.com

    ; <<>> DiG 9.9.4-RedHat-9.9.4-50.el7 <<>> ns1.com
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 63104
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 1

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;ns1.com.			IN	A

    ;; ANSWER SECTION:
    ns1.com.		86400	IN	A	192.168.46.154

    ;; AUTHORITY SECTION:
    com.			86078	IN	NS	ns1.com.

    ;; Query time: 1 msec
    ;; SERVER: 192.168.46.158#53(192.168.46.158)
    ;; WHEN: Sun Jan 21 04:28:01 CST 2018
    ;; MSG SIZE  rcvd: 66


二级域配置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

二级域里面我只有tech下的linuxpanda域，

.. code-block:: bash

    [root@centos-155 ~]# vim /etc/named.conf 
    [root@centos-155 named]# vim /etc/named.rfc1912.zones 
    [root@centos-155 named]# tail -n 5 /etc/named.rfc1912.zones 
    };
    zone "linuxpanda.tech" {
        type master;
        file "linuxpanda.tech.zone";
    };
    [root@centos-155 named]# cd /var/named/
    [root@centos-155 named]# cp named.localhost  linuxpanda.tech.zone -p
    [root@centos-155 named]# vim linuxpanda.tech.zone 
    [root@centos-155 named]# cat linuxpanda.tech.zone 
    $TTL 1D
    @	IN SOA	ns1 admin (
                        0	; serial
                        1D	; refresh
                        1H	; retry
                        1W	; expire
                        3H )	; minimum
        NS      ns1	
    ns1     A       192.168.46.155
    www     A       192.168.46.156
    www     A       192.168.46.157
    
    [root@centos-155 named]# dig www.linuxpanda.tech 

    ; <<>> DiG 9.9.4-RedHat-9.9.4-50.el7 <<>> www.linuxpanda.tech
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 20201
    ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 1, ADDITIONAL: 2

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;www.linuxpanda.tech.		IN	A

    ;; ANSWER SECTION:
    www.linuxpanda.tech.	86400	IN	A	192.168.46.157
    www.linuxpanda.tech.	86400	IN	A	192.168.46.156

    ;; AUTHORITY SECTION:
    linuxpanda.tech.	86400	IN	NS	ns1.linuxpanda.tech.

    ;; ADDITIONAL SECTION:
    ns1.linuxpanda.tech.	86400	IN	A	192.168.46.155

    ;; Query time: 0 msec
    ;; SERVER: 127.0.0.1#53(127.0.0.1)
    ;; WHEN: Sun Jan 21 04:34:38 CST 2018
    ;; MSG SIZE  rcvd: 114

三级域配置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

上面在三级域配置的自己主机上测试过了，我们在在客户机上测试下

.. code-block:: bash

    [root@centos-159 ~]# dig www.linuxpanda.tech

    ; <<>> DiG 9.9.4-RedHat-9.9.4-50.el7 <<>> www.linuxpanda.tech
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 25268
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 1, ADDITIONAL: 2

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;www.linuxpanda.tech.		IN	A

    ;; ANSWER SECTION:
    www.linuxpanda.tech.	86400	IN	A	192.168.46.157
    www.linuxpanda.tech.	86400	IN	A	192.168.46.156

    ;; AUTHORITY SECTION:
    linuxpanda.tech.	86400	IN	NS	ns1.linuxpanda.tech.

    ;; ADDITIONAL SECTION:
    ns1.linuxpanda.tech.	86400	IN	A	192.168.46.155

    ;; Query time: 2 msec
    ;; SERVER: 192.168.46.158#53(192.168.46.158)
    ;; WHEN: Sun Jan 21 04:36:10 CST 2018
    ;; MSG SIZE  rcvd: 114

web配置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

马上就要结束了，哈哈。 

www1主机配置下web 

.. code-block:: bash

    [root@centos-156 ~]#  echo "this is 192.168.46.156" > /var/www/html/index.html
    [root@centos-156 ~]# systemctl restart httpd
    [root@centos-156 ~]# curl localhost
    this is 192.168.46.156

www2主机配置下web 

.. code-block:: bash

    [root@centos-157 ~]#  echo "this is 192.168.46.157" > /var/www/html/index.html
    [root@centos-157 ~]# systemctl restart httpd
    [root@centos-157 ~]# curl localhost
    this is 192.168.46.157

客户端最终测试
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

dns测试

.. code-block:: bash

    [root@centos-159 ~]# dig www.linuxpanda.tech 

    ; <<>> DiG 9.9.4-RedHat-9.9.4-50.el7 <<>> www.linuxpanda.tech
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 22715
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 1, ADDITIONAL: 2

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;www.linuxpanda.tech.		IN	A

    ;; ANSWER SECTION:
    www.linuxpanda.tech.	85972	IN	A	192.168.46.156
    www.linuxpanda.tech.	85972	IN	A	192.168.46.157

    ;; AUTHORITY SECTION:
    linuxpanda.tech.	85972	IN	NS	ns1.linuxpanda.tech.

    ;; ADDITIONAL SECTION:
    ns1.linuxpanda.tech.	85972	IN	A	192.168.46.155

    ;; Query time: 0 msec
    ;; SERVER: 192.168.46.158#53(192.168.46.158)
    ;; WHEN: Sun Jan 21 04:43:18 CST 2018
    ;; MSG SIZE  rcvd: 114

web服务测试

.. code-block:: bash

    [root@centos-159 ~]# for i in `seq 1 20 ` ; do curl http://www.linuxpanda.tech ; done
    this is 192.168.46.157
    this is 192.168.46.157
    this is 192.168.46.157
    this is 192.168.46.157
    this is 192.168.46.157
    this is 192.168.46.156
    this is 192.168.46.156
    this is 192.168.46.156
    this is 192.168.46.156
    this is 192.168.46.157
    this is 192.168.46.156
    this is 192.168.46.157
    this is 192.168.46.157
    this is 192.168.46.156
    this is 192.168.46.157
    this is 192.168.46.156
    this is 192.168.46.157
    this is 192.168.46.157
    this is 192.168.46.156
    this is 192.168.46.156


压力测试
---------------------------------------------------------

.. code-block:: bash

    queryperf -d test.txt -s 127.0.0.1

排错思路
---------------------------------------------------------

#. 查看日志信息
#. rndc querylog 启动日志临时获取查询详细信息
#. 查看监听
#. 查看zone权限配置
#. 查看named.conf文件的allow-query和安全设置
#. 使用named-checkconf和named-checkzone工具
#. dns配置是否正确。


编译安装主要步骤
---------------------------------------------------------

.. code-block:: text 

   1. 账号创建，文件下载，解压
   2. 查看readme，install文档
   3. dig -t NS . @a.root-servers.net. >named.ca 。640 
   4. ./configure && make && make install 
   5. PATH , source path
   6. named.conf文件，named.rfc1912.conf文件
   7. rndc-confgen -r /dev/urandom
   8. named -u named -f -g  -d 3 启动服务
   9. cd contrib/queryperf
   10. ./configure && make  cp queryperf /user/local/bind9/bin/
   11. queryperf -h 
   12. 做文件，www.linuxpandata.tech A 每行这样。
   13. queryperf -d test.txt -s 127.0.0.1