haproxy
============================================

haproxy的安装
---------------------------------------

.. code-block:: bash 

    [root@centos-151 ~]# yum install haproxy 
    [root@centos-151 ~]# rpm -ql haproxy
    /etc/haproxy               # 主配置目录
    /etc/haproxy/haproxy.cfg   # 主配置文件
    /etc/logrotate.d/haproxy   # 日志滚动
    /etc/sysconfig/haproxy     # 启动参数
    /usr/bin/halog
    /usr/bin/iprange
    /usr/lib/systemd/system/haproxy.service   # 服务脚本
    /usr/sbin/haproxy
    /usr/sbin/haproxy-systemd-wrapper
    /usr/share/doc/haproxy-1.5.18
    /usr/share/doc/haproxy-1.5.18/CHANGELOG
    /usr/share/doc/haproxy-1.5.18/LICENSE
    /usr/share/doc/haproxy-1.5.18/README
    /usr/share/doc/haproxy-1.5.18/ROADMAP
    /usr/share/doc/haproxy-1.5.18/VERSION
    /usr/share/doc/haproxy-1.5.18/acl.fig
    /usr/share/doc/haproxy-1.5.18/architecture.txt
    /usr/share/doc/haproxy-1.5.18/close-options.txt
    /usr/share/doc/haproxy-1.5.18/coding-style.txt
    /usr/share/doc/haproxy-1.5.18/configuration.txt
    /usr/share/doc/haproxy-1.5.18/cookie-options.txt
    /usr/share/doc/haproxy-1.5.18/design-thoughts
    /usr/share/doc/haproxy-1.5.18/design-thoughts/backends-v0.txt
    /usr/share/doc/haproxy-1.5.18/design-thoughts/backends.txt
    /usr/share/doc/haproxy-1.5.18/design-thoughts/be-fe-changes.txt
    /usr/share/doc/haproxy-1.5.18/design-thoughts/binding-possibilities.txt
    /usr/share/doc/haproxy-1.5.18/design-thoughts/buffer-redesign.txt
    /usr/share/doc/haproxy-1.5.18/design-thoughts/buffers.fig
    /usr/share/doc/haproxy-1.5.18/design-thoughts/config-language.txt
    /usr/share/doc/haproxy-1.5.18/design-thoughts/connection-reuse.txt
    /usr/share/doc/haproxy-1.5.18/design-thoughts/cttproxy-changes.txt
    /usr/share/doc/haproxy-1.5.18/design-thoughts/entities-v2.txt
    /usr/share/doc/haproxy-1.5.18/design-thoughts/how-it-works.txt
    /usr/share/doc/haproxy-1.5.18/design-thoughts/http_load_time.url
    /usr/share/doc/haproxy-1.5.18/design-thoughts/rate-shaping.txt
    /usr/share/doc/haproxy-1.5.18/design-thoughts/sess_par_sec.txt
    /usr/share/doc/haproxy-1.5.18/examples                     # 样例配置目录，下面都是一些特定样例
    /usr/share/doc/haproxy-1.5.18/examples/acl-content-sw.cfg
    /usr/share/doc/haproxy-1.5.18/examples/auth.cfg
    /usr/share/doc/haproxy-1.5.18/examples/build.cfg
    /usr/share/doc/haproxy-1.5.18/examples/content-sw-sample.cfg
    /usr/share/doc/haproxy-1.5.18/examples/cttproxy-src.cfg
    /usr/share/doc/haproxy-1.5.18/examples/examples.cfg
    /usr/share/doc/haproxy-1.5.18/examples/haproxy.cfg
    /usr/share/doc/haproxy-1.5.18/examples/option-http_proxy.cfg
    /usr/share/doc/haproxy-1.5.18/examples/ssl.cfg
    /usr/share/doc/haproxy-1.5.18/examples/tarpit.cfg
    /usr/share/doc/haproxy-1.5.18/examples/test-section-kw.cfg
    /usr/share/doc/haproxy-1.5.18/examples/transparent_proxy.cfg
    /usr/share/doc/haproxy-1.5.18/examples/url-switching.cfg
    /usr/share/doc/haproxy-1.5.18/gpl.txt
    /usr/share/doc/haproxy-1.5.18/haproxy-en.txt
    /usr/share/doc/haproxy-1.5.18/haproxy-fr.txt
    /usr/share/doc/haproxy-1.5.18/haproxy.1
    /usr/share/doc/haproxy-1.5.18/internals
    /usr/share/doc/haproxy-1.5.18/internals/acl.txt
    /usr/share/doc/haproxy-1.5.18/internals/body-parsing.txt
    /usr/share/doc/haproxy-1.5.18/internals/buffer-operations.txt
    /usr/share/doc/haproxy-1.5.18/internals/buffer-ops.fig
    /usr/share/doc/haproxy-1.5.18/internals/connect-status.txt
    /usr/share/doc/haproxy-1.5.18/internals/connection-header.txt
    /usr/share/doc/haproxy-1.5.18/internals/connection-scale.txt
    /usr/share/doc/haproxy-1.5.18/internals/entities.fig
    /usr/share/doc/haproxy-1.5.18/internals/entities.pdf
    /usr/share/doc/haproxy-1.5.18/internals/entities.svg
    /usr/share/doc/haproxy-1.5.18/internals/entities.txt
    /usr/share/doc/haproxy-1.5.18/internals/hashing.txt
    /usr/share/doc/haproxy-1.5.18/internals/header-parser-speed.txt
    /usr/share/doc/haproxy-1.5.18/internals/header-tree.txt
    /usr/share/doc/haproxy-1.5.18/internals/http-cookies.txt
    /usr/share/doc/haproxy-1.5.18/internals/http-docs.txt
    /usr/share/doc/haproxy-1.5.18/internals/http-parsing.txt
    /usr/share/doc/haproxy-1.5.18/internals/naming.txt
    /usr/share/doc/haproxy-1.5.18/internals/pattern.dia
    /usr/share/doc/haproxy-1.5.18/internals/pattern.pdf
    /usr/share/doc/haproxy-1.5.18/internals/polling-states.fig
    /usr/share/doc/haproxy-1.5.18/internals/repartition-be-fe-fi.txt
    /usr/share/doc/haproxy-1.5.18/internals/sequence.fig
    /usr/share/doc/haproxy-1.5.18/internals/stats-v2.txt
    /usr/share/doc/haproxy-1.5.18/internals/stream-sock-states.fig
    /usr/share/doc/haproxy-1.5.18/internals/todo.cttproxy
    /usr/share/doc/haproxy-1.5.18/lgpl.txt
    /usr/share/doc/haproxy-1.5.18/proxy-protocol.txt
    /usr/share/doc/haproxy-1.5.18/queuing.fig
    /usr/share/haproxy
    /usr/share/haproxy/400.http          # 主要的几个状态页面
    /usr/share/haproxy/403.http
    /usr/share/haproxy/408.http
    /usr/share/haproxy/500.http
    /usr/share/haproxy/502.http
    /usr/share/haproxy/503.http
    /usr/share/haproxy/504.http
    /usr/share/haproxy/README
    /usr/share/man/man1/halog.1.gz   # 帮助文档类
    /usr/share/man/man1/haproxy.1.gz
    /var/lib/haproxy                # haproxy数据库位置


快速使用案例
--------------------------------

.. code-block:: bash 

    # 备份工作
    [root@centos-151 ~]# cd /etc/haproxy/
    [root@centos-151 haproxy]# ls
    haproxy.cfg
    [root@centos-151 haproxy]# cp haproxy.cfg{,.bak}
    [root@centos-151 haproxy]# ll
    total 8
    -rw-r--r-- 1 root root 3142 May  2  2017 haproxy.cfg
    -rw-r--r-- 1 root root 3142 Mar 21 19:47 haproxy.cfg.bak

    [root@centos-151 haproxy]# vim haproxy.cfg
    # 删除这行（main frontend which proxys to the backends）后面的所有行
    # 添加如下几行配置
    frontend web *:80
            default_backend webservs

    backend webservs
            balance roundrobin
            server web152    192.168.46.152:80 check
            server web153    192.168.46.153:80 check

    # 准备后端的web服务
    [root@centos-152 ~]# yum install nginx
    [root@centos-152 ~]# systemctl restart nginx 
    [root@centos-152 ~]# hostnamectl > /usr/share/nginx/html/index.html
    [root@centos-152 ~]# curl localhost
    Static hostname: centos-152.linuxpanda.tech
            Icon name: computer-vm
            Chassis: vm
            Machine ID: 8522cb29cf77495dbb9c4ad8f7ca02c4
            Boot ID: 6a174ac39912489da3947eb4a2a8bb9a
        Virtualization: vmware
    Operating System: CentOS Linux 7 (Core)
        CPE OS Name: cpe:/o:centos:centos:7
                Kernel: Linux 3.10.0-693.el7.x86_64
        Architecture: x86-64


    [root@centos-153 ~]# yum install nginx
    [root@centos-153 ~]# hostnamectl > /usr/share/nginx/html/index.html
    [root@centos-153 ~]# systemctl restart nginx
    [root@centos-153 ~]# curl localhost
    Static hostname: centos-153.linuxpanda.tech
            Icon name: computer-vm
            Chassis: vm
            Machine ID: 8522cb29cf77495dbb9c4ad8f7ca02c4
            Boot ID: 065ba5421bc9473eab1202cc23e1a5ba
        Virtualization: vmware
    Operating System: CentOS Linux 7 (Core)
        CPE OS Name: cpe:/o:centos:centos:7
                Kernel: Linux 3.10.0-693.el7.x86_64
        Architecture: x86-64

    # 测试

    [root@centos-151 haproxy]# systemctl start haproxy
    [root@centos-151 haproxy]# curl 192.168.46.151
    Static hostname: centos-152.linuxpanda.tech
            Icon name: computer-vm
            Chassis: vm
            Machine ID: 8522cb29cf77495dbb9c4ad8f7ca02c4
            Boot ID: 6a174ac39912489da3947eb4a2a8bb9a
        Virtualization: vmware
    Operating System: CentOS Linux 7 (Core)
        CPE OS Name: cpe:/o:centos:centos:7
                Kernel: Linux 3.10.0-693.el7.x86_64
        Architecture: x86-64
    [root@centos-151 haproxy]# curl 192.168.46.151
    Static hostname: centos-153.linuxpanda.tech
            Icon name: computer-vm
            Chassis: vm
            Machine ID: 8522cb29cf77495dbb9c4ad8f7ca02c4
            Boot ID: 065ba5421bc9473eab1202cc23e1a5ba
        Virtualization: vmware
    Operating System: CentOS Linux 7 (Core)
        CPE OS Name: cpe:/o:centos:centos:7
                Kernel: Linux 3.10.0-693.el7.x86_64
        Architecture: x86-64

日志配置
---------------------------------------------

在haproxy的配置文件中，默认已经绑定到local2上了，我们需要在rsyslog上关联下。

.. code-block:: bash 

    [root@centos-151 haproxy]# vim /etc/rsyslog.conf 

    # 解开如下4行注释内容
    $ModLoad imudp
    $UDPServerRun 514

    # Provides TCP syslog reception
    $ModLoad imtcp
    $InputTCPServerRun 514

    # 添加如下行
    local2.*                                                /var/log/haproxy.log

    # 重启下服务
    [root@centos-151 haproxy]# systemctl restart rsyslog
    [root@centos-151 haproxy]# systemctl restart haproxy

    # 请求一次
    [root@centos-151 haproxy]# !curl
    curl 192.168.46.151
    Static hostname: centos-152.linuxpanda.tech
            Icon name: computer-vm
            Chassis: vm
            Machine ID: 8522cb29cf77495dbb9c4ad8f7ca02c4
            Boot ID: 6a174ac39912489da3947eb4a2a8bb9a
        Virtualization: vmware
    Operating System: CentOS Linux 7 (Core)
        CPE OS Name: cpe:/o:centos:centos:7
                Kernel: Linux 3.10.0-693.el7.x86_64
        Architecture: x86-64
        
    # 查看日志文件
    [root@centos-151 haproxy]# cat /var/log/haproxy.log 
    Mar 21 20:09:06 localhost haproxy[16857]: Proxy web started.
    Mar 21 20:09:06 localhost haproxy[16857]: Proxy webservs started.
    Mar 21 20:09:10 localhost haproxy[16858]: 192.168.46.151:53018 [21/Mar/2018:20:09:10.841] web webservs/web152 0/0/0/0/0 200 628 - - ---- 1/1/0/0/0 0/0 "GET / HTTP/1.1"


主要配置参数
---------------------------------------------

.. code-block:: text 

    global配置项： 

        chroot: 切换根运行目录
        uid,gid: 运行用户和组
        user,group：运行用户和组
        daemon： 是否守护进程
        log:     配置日志和相应的级别
        nbproc:  要启动的haproxy的进程数量
        ulimit:  每个haproxy进程可打开的最大文件数量

        maxconn: 设定每个haproxy进程能接受的最大并发连接数量
        maxconnrate: 每个进程每秒能创建的最大连接数量
        maxsslconn: 每个haproxy进程所能接受的ssl最大并发连接数量
        spread-checks: 散开检查工作

    代理配置项：

        defaults: 默认的
        frontend: 前段
        backend: 后端的
        listen: 监听

        bind： 绑定地址和端口
        balance： 指定调度算法类型和算法参数
                roundrobin: 轮调
                static-rr: 静态轮调
                leastconn: 最小连接
                first: 前面的达到上限在调度下一个
                source： 源地址hash
                uri： 对uri左半部分做hash计算，派发到下面服务器
                url_param: 对参数做hash计算，然后派发
                hdr: 对特定的http首部做hash计算     

        hash-type: hash类型，map-based,consistent
        default_backend： 默认后端
        default_server: 默认服务器
            name: 名字
            address: 地址
            port: 端口
            maxconn:最大连接
            backlog: 后援队列长度
            check 健康检查
                addr: 检查地址
                port: 检查端口
                inter: 检查间隔
                rise: 多少次检查成功认为可用
                fall: 多少次失败标记不可用
            cookie： 设置cookie值
            disabled: 标记不可用
            on-error: 后端服务故障时候的行动策略

    统计接口相关参数
        states enable ,启动后可以通过ip/haproxy？stats访问
            stats uri ： /haproxy?stats
            stats realm: "认证提示"
            stats refresh: 设定自动刷新时间间隔
            stats admin: 启用stats page的管理功能
        配置样例： 
            listen stats
                bind :9090 
                stats enable 
                stats realm " stat page" 
                stats auth admin:admin 
                stats admin if TRUE


    mode: 工作模式，支持tcp,http,health三种

    option forwardfor [except network] :  添加forwardfor信息
    erroffile <code> <file>： 错误文件
    errorloc302  <code> <url>: 指定一个url地址
    reqadd: 请求头添加
    rspdel: 响应头删除
    rspadd: 响应头添加
    option httpchk  uri： 特定uri的http检查
    use_backend <backup>:使用特定后端
    default_backend:默认后端
    http-request {allow,deny} {if 条件}: 如果特定条件就执行特定动作
    http_request set-header X-Forwarded-Port %{dst_port} 

    压缩功能
        compression algo: 指定http压缩了下
        compression type：对特定类型压缩

    连接超时相关
        timout client : 客户端超时
        timeout server： 客户端超时
        timeout http-request: 请求的超时时长
        timeout connect: 连接超时时长
        timout client-fin  等待fin的时间
        timeout server-find 等待fin的时间

    acl设置
        acl invalid_src src ip : 设置一个命名的acl
        block if invalid_src： 如果特定条件满足就403返回



常用配置
---------------------------------------------


后台记录真实的客户端ip方法 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

默认default已经有forwardfor配置了。 可以在后端的服务器上面使用X-Forwarded-For头来记录真实的客户端地址。
可以使用命令 "tcpdump -i ens33 port 80  -nn  -vv" 去抓取调度到后端的服务器的请求头信息，
这里有一个样例的信息（部分的）:

.. code-block:: text 

    tcpdump -i ens33 port 80  -nn  -vv
    192.168.46.151.38294 > 192.168.46.152.80: Flags [P.], cksum 0xf70e (correct), seq 1:517, ack 1, win 457, options [nop,nop,TS val 16990545 ecr 23555307], length 516: HTTP, length: 516
    GET / HTTP/1.1
    Host: 192.168.46.151
    Cache-Control: max-age=0
    Upgrade-Insecure-Requests: 1
    User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.162 Safari/537.36
    Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8
    Accept-Encoding: gzip, deflate
    Accept-Language: zh-CN,zh;q=0.9
    If-None-Match: "5ab2496d-18b"
    If-Modified-Since: Wed, 21 Mar 2018 12:00:45 GMT
    X-Forwarded-For: 192.168.46.1
    Connection: close


剩下的就是在web的日志格式中添加该变量即可。 

动静分离
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 


    frontend web *:80
            acl url_static   path_beg    -i  /static  /images/  /javascript /stylesheets /css /js
            acl url_static   path_end    -i .jpg .gif .png .css .js .html .txt .htm
            use_backend   staticsrvs if url_static
            default_backend webservs

    backend staticsrvs
            balance roundrobin
            server static152 192.168.46.152

    backend webservs
            #balance roundrobin
            cookie BACKENDSRV insert nocache indirect
            server web153    192.168.46.153:80 cookie web153 check addr 192.168.46.152 port 80 inter 2000 rise 2 fall 3

    # 后端的153机器需要构建一个php页面，安装php-fpm包，主要配置如下

        location / {
                fastcgi_pass 127.0.0.1:9000;
                fastcgi_index index.php ;
                fastcgi_param SCRIPT_FILENAME /usr/share/nginx/html$fastcgi_script_name;
                include  fastcgi_params ;
        }
    # php主页设置
    [root@centos-153 ~]# cat /usr/share/nginx/html/index.php 
    <?php
    echo "今天是 " . date("Y/m/d") . "<br>";
    ?>

    # 测试下配置

    [root@centos-151 ~]# for i in {1..10} ; do curl http://192.168.46.151/index.html ; curl http://192.168.46.151/index.php; echo "" ; done
    centos-152.linuxpanda.tech
    今天是 2018/03/22<br>
    centos-152.linuxpanda.tech
    今天是 2018/03/22<br>
    centos-152.linuxpanda.tech
    今天是 2018/03/22<br>
    centos-152.linuxpanda.tech
    今天是 2018/03/22<br>
    centos-152.linuxpanda.tech
    今天是 2018/03/22<br>
    centos-152.linuxpanda.tech
    今天是 2018/03/22<br>
    centos-152.linuxpanda.tech
    今天是 2018/03/22<br>
    centos-152.linuxpanda.tech
    今天是 2018/03/22<br>
    centos-152.linuxpanda.tech
    今天是 2018/03/22<br>
    centos-152.linuxpanda.tech
    今天是 2018/03/22<br>

配置支持https协议
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    # 证书准备
    [root@centos-151 certs]# make haproxy.crt
    umask 77 ; \
    /usr/bin/openssl genrsa -aes128 2048 > haproxy.key
    Generating RSA private key, 2048 bit long modulus
    ............................................+++
    ..........................................................................+++
    e is 65537 (0x10001)
    Enter pass phrase:
    Verifying - Enter pass phrase:
    umask 77 ; \
    /usr/bin/openssl req -utf8 -new -key haproxy.key -x509 -days 365 -out haproxy.crt 
    Enter pass phrase for haproxy.key:
    You are about to be asked to enter information that will be incorporated
    into your certificate request.
    What you are about to enter is what is called a Distinguished Name or a DN.
    There are quite a few fields but you can leave some blank
    For some fields there will be a default value,
    If you enter '.', the field will be left blank.
    -----
    Country Name (2 letter code) [XX]:cn
    State or Province Name (full name) []:beijing
    Locality Name (eg, city) [Default City]:beijing
    Organization Name (eg, company) [Default Company Ltd]:linuxpanda.tech
    Organizational Unit Name (eg, section) []:opt
    Common Name (eg, your name or your server's hostname) []:*.linuxpanda.tech                        
    Email Address []:
    [root@centos-151 certs]# ls
    ca-bundle.crt  ca-bundle.trust.crt  haproxy.crt  haproxy.key  make-dummy-cert  Makefile  renew-dummy-cert
    [root@centos-151 certs]# openssl rsa -in haproxy.key  -out haproxy.key2
    Enter pass phrase for haproxy.key:
    writing RSA key
    [root@centos-151 certs]# cat haproxy.crt haproxy.key2   > haproxy.pem

    # 配置
        frontend web
            bind *:443 ssl crt /etc/pki/tls/certs/haproxy.pem
            bind *:80
            redirect scheme https if !{ ssl_fc }
            #http_request set-header X-Forwarded-Port %{dst_port]
            #http_request set-header X-Forward-Porto https if { ssl_fc }

            acl url_static   path_beg    -i  /static  /images/  /javascript /stylesheets /css /js
            acl url_static   path_end    -i .jpg .gif .png .css .js .html .txt .htm
            use_backend   staticsrvs if url_static
            default_backend webservs

        backend staticsrvs
                balance roundrobin
                server static152 192.168.46.152

        backend webservs
                #balance roundrobin
                cookie BACKENDSRV insert nocache indirect
                server web153    192.168.46.153:80 cookie web153 check addr 192.168.46.152 port 80 inter 2000 rise 2 fall 3

    # 测试下
    [root@centos-152 ~]# curl https://192.168.46.151 -k
    今天是 2018/03/22<br>