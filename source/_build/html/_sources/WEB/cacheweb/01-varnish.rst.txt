varnish
==========================================

varnish安装
-------------------------------------------

.. code-block:: bash 

    [root@centos-151 ~]# yum install varnish 
    [root@centos-151 ~]# rpm -ql varnish 
    /etc/logrotate.d/varnish
    /etc/varnish
    /etc/varnish/default.vcl        # 默认vcl配置文件，用于配置线程的缓存策略。
    /etc/varnish/varnish.params     # 用于配置服务工作特性，比如监听地址和端口，缓存机制等。
    /run/varnish.pid
    /usr/bin/varnishadm             # 常用的命令
    /usr/bin/varnishhist
    /usr/bin/varnishlog
    /usr/bin/varnishncsa
    /usr/bin/varnishstat
    /usr/bin/varnishtest
    /usr/bin/varnishtop
    /usr/lib/systemd/system/varnish.service # 服务文件
    /usr/lib/systemd/system/varnishlog.service
    /usr/lib/systemd/system/varnishncsa.service
    /usr/sbin/varnish_reload_vcl           # 重载vcl配置
    /usr/sbin/varnishd
    /usr/share/doc/varnish-4.0.5            # 帮助文档
    /usr/share/doc/varnish-4.0.5/LICENSE
    /usr/share/doc/varnish-4.0.5/README
    /usr/share/doc/varnish-4.0.5/builtin.vcl
    /usr/share/doc/varnish-4.0.5/changes.rst
    /usr/share/doc/varnish-4.0.5/example.vcl
    /usr/share/man/man1/varnishadm.1.gz
    /usr/share/man/man1/varnishd.1.gz
    /usr/share/man/man1/varnishhist.1.gz
    /usr/share/man/man1/varnishlog.1.gz
    /usr/share/man/man1/varnishncsa.1.gz
    /usr/share/man/man1/varnishstat.1.gz
    /usr/share/man/man1/varnishtest.1.gz
    /usr/share/man/man1/varnishtop.1.gz
    /usr/share/man/man3/vmod_directors.3.gz
    /usr/share/man/man3/vmod_std.3.gz
    /usr/share/man/man7/varnish-cli.7.gz
    /usr/share/man/man7/varnish-counters.7.gz
    /usr/share/man/man7/vcl.7.gz
    /usr/share/man/man7/vsl-query.7.gz
    /usr/share/man/man7/vsl.7.gz
    /var/lib/varnish
    /var/log/varnish

vcl简介
--------------------------------------------------------------



varnishadm使用
---------------------------------------------------------

.. code-block:: bash 

    # 连接varnish管理
    [root@centos-151 varnish]# varnishadm  -S /etc/varnish/secret  -T 127.0.0.1:6082
    200        
    -----------------------------
    Varnish Cache CLI 1.0
    -----------------------------
    Linux,3.10.0-693.el7.x86_64,x86_64,-smalloc,-smalloc,-hcritbit
    varnish-4.0.5 revision 07eff4c29

    Type 'help' for command list.
    Type 'quit' to close CLI session.

    help      # 获取帮助
    200        
    help [<command>]                    # 获取特定命令帮助
    ping [<timestamp>]                  # 测试主机
    auth <response>                     # 认证
    quit                                # 退出
    banner                              # 欢迎信息再次显示
    status                              # 状态
    start                               # 启动
    stop                                # 停止
    vcl.load <configname> <filename>    # 加载一个配置，设置一个配置名字
    vcl.inline <configname> <quoted_VCLstring>
    vcl.use <configname>                # 使用特定配置
    vcl.discard <configname>            # 卸载特定配置
    vcl.list                            # 查看vcl列表信息
    param.show [-l] [<param>]           # 参数查看
    param.set <param> <value>           # 参数设置
    panic.show                          # 如果有panic信息，就显示最近的
    panic.clear                         # 清空panic信息
    storage.list                        # 存储查看
    vcl.show [-v] <configname>          # 查看特定配置的信息
    backend.list [<backend_expression>] # 后端列表
    backend.set_health <backend_expression> <state>  # 设置后端的健康检查
    ban <field> <operator> <arg> [&& <field> <oper> <arg>]... # 所有匹配的都会过期
    ban.list                                                  # 查看ban列表

vcl默认配置查看
----------------------------------

.. code-block:: text 

    vcl.show -v boot

    vcl 4.0;

    #######################################################################
    # Client side

    sub vcl_recv {

        // 如果请求方式是pri，直接使用synth构造4.5页面
        if (req.method == "PRI") {
        /* We do not support SPDY or HTTP/2.0 */
        return (synth(405));
        }
        //如果请求方式不是常用的几种请求方法的，直接管道处理
        if (req.method != "GET" &&
        req.method != "HEAD" &&
        req.method != "PUT" &&
        req.method != "POST" &&
        req.method != "TRACE" &&
        req.method != "OPTIONS" &&
        req.method != "DELETE") {
            /* Non-RFC2616 or CONNECT which is weird. */
            return (pipe);
        }

        // 如果请求的方法不是get或者head的话，就转移到pass状态代码处理。
        if (req.method != "GET" && req.method != "HEAD") {
            /* We only deal with GET and HEAD by default */
            return (pass);
        }
        # 如果请求头信息有认证和cookie信息，就转义到pass后台去
        if (req.http.Authorization || req.http.Cookie) {
            /* Not cacheable by default */
            return (pass);
        }
        # 默认执行hash
        return (hash);
    }

    sub vcl_pipe {
        # By default Connection: close is set on all piped requests, to stop
        # connection reuse from sending future requests directly to the
        # (potentially) wrong backend. If you do want this to happen, you can undo
        # it here.
        # unset bereq.http.connection;
        return (pipe);
    }

    // 直接到后面去取数据
    sub vcl_pass {
        return (fetch);
    }

    sub vcl_hash {

        //hash 请求的url,如果请求的头包含host信息，hash下host,否则hash下ip，然后去查找
        hash_data(req.url);
        if (req.http.host) {
            hash_data(req.http.host);
        } else {
            hash_data(server.ip);
        }
        return (lookup);
    }

    sub vcl_purge {
        // 构造一个200状态码的purged页面
        return (synth(200, "Purged"));
    }

    sub vcl_hit {

        // 如果对象的ttl大于0 或者ttl加宽限时间大于0 就直接使用缓存即可，否则就后面取数据
        if (obj.ttl >= 0s) {
            // A pure unadultered hit, deliver it
            return (deliver);
        }
        if (obj.ttl + obj.grace > 0s) {
            // Object is in grace, deliver it
            // Automatically triggers a background fetch
            return (deliver);
        }
        // fetch & deliver once we get the result
        return (fetch);
    }

    sub vcl_miss {
        //miss的到后面找
        return (fetch);
    }

    sub vcl_deliver {
        return (deliver);
    }

    #######################################################################
    # Housekeeping
    // init,fini 这2个是初始化和结束时候执行， init用于启用变量定义等。

    sub vcl_init {
        return (ok);
    }

    sub vcl_fini {
        return (ok);
    }


配置案例
----------------------------------

命中情况
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@centos-151 varnish]# cp default.vcl default.vcl.bak
    [root@centos-151 varnish]# vim default.vcl
    # 修改如下配置
    backend default {
        .host = "192.168.46.152";
        .port = "80";
    }
    # 修改如下deliver片段
    sub vcl_deliver {
        # Happens when we have all the pieces we need, and are about to send the
        # response to the client.
        #
        # You can do accounting or modifying the final object here.
        if (obj.hits > 0 ) {
            set resp.http.X-Cache = "Hit via " + server.ip;
            }
        else {
            set resp.http.X-Cache = "Miss From " + server.ip;
            }
    }

    # 配置生效
    [root@centos-151 varnish]# clear
    [root@centos-151 varnish]# !varnishadm
    varnishadm  -S /etc/varnish/secret  -T 127.0.0.1:6082
    200        
    -----------------------------
    Varnish Cache CLI 1.0
    -----------------------------
    Linux,3.10.0-693.el7.x86_64,x86_64,-smalloc,-smalloc,-hcritbit
    varnish-4.0.5 revision 07eff4c29

    Type 'help' for command list.
    Type 'quit' to close CLI session.

    vcl.load change_hit /etc/varnish/default.vcl
    200        
    VCL compiled.
    vcl.use change_hit
    200        
    VCL 'change_hit' now active

    # 修改下参数，设置下默认监听端口， 这里测试方便设置为80
    [root@centos-151 varnish]# vim varnish.params 
    # 修改下端口
    VARNISH_LISTEN_PORT=80
    [root@centos-151 varnish]# systemctl restart varnish

    # 测试下，第一次是miss,第二次就是hit了。
    [root@centos-151 varnish]# curl -I 192.168.46.151
    HTTP/1.1 200 OK
    Server: nginx/1.12.2
    Date: Fri, 23 Mar 2018 11:05:28 GMT
    Content-Type: text/html
    Content-Length: 27
    Last-Modified: Fri, 23 Mar 2018 10:55:32 GMT
    ETag: "5ab4dd24-1b"
    X-Varnish: 2
    Age: 0
    Via: 1.1 varnish-v4
    X-Cache: Miss From 192.168.46.151
    Connection: keep-alive

    [root@centos-151 varnish]# curl -I 192.168.46.151
    HTTP/1.1 200 OK
    Server: nginx/1.12.2
    Date: Fri, 23 Mar 2018 11:05:28 GMT
    Content-Type: text/html
    Content-Length: 27
    Last-Modified: Fri, 23 Mar 2018 10:55:32 GMT
    ETag: "5ab4dd24-1b"
    X-Varnish: 5 3
    Age: 4
    Via: 1.1 varnish-v4
    X-Cache: Hit via 192.168.46.151
    Connection: keep-alive

禁用特定网页的缓存
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    # 现在后端指定样例页面
    [root@centos-152 ~]# cd /usr/share/nginx/html/
    [root@centos-152 html]# mkdir login
    [root@centos-152 html]# echo "login page from 152" > login/index.html

    # 设置vcl
    [root@centos-151 varnish]# vim default.vcl

    sub vcl_recv {
        # Happens before we check if we have this in cache already.
        #
        # Typically you clean up the request here, removing cookies you don't need,
        # rewriting the request, etc.
        if ( req.url ~ "^/login" ) {
            return (pass);
            }

    }
    # 重启下varnish,重启varnish是很危险的操作。我这里方便测试直接重启了。
    [root@centos-151 varnish]# systemctl restart varnish 

    # 测试下
    [root@centos-151 varnish]# curl 192.168.46.151/login/ -I 
    HTTP/1.1 200 OK
    Server: nginx/1.12.2
    Date: Fri, 23 Mar 2018 11:13:14 GMT
    Content-Type: text/html
    Content-Length: 20
    Last-Modified: Fri, 23 Mar 2018 11:10:20 GMT
    ETag: "5ab4e09c-14"
    Accept-Ranges: bytes
    X-Varnish: 2
    Age: 0
    Via: 1.1 varnish-v4
    X-Cache: Miss From 192.168.46.151
    Connection: keep-alive

    [root@centos-151 varnish]# curl 192.168.46.151/login/ -I 
    HTTP/1.1 200 OK
    Server: nginx/1.12.2
    Date: Fri, 23 Mar 2018 11:13:17 GMT
    Content-Type: text/html
    Content-Length: 20
    Last-Modified: Fri, 23 Mar 2018 11:10:20 GMT
    ETag: "5ab4e09c-14"
    Accept-Ranges: bytes
    X-Varnish: 5
    Age: 0
    Via: 1.1 varnish-v4
    X-Cache: Miss From 192.168.46.151
    Connection: keep-alive

去除一些特定静态资源的cookie信息
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    sub vcl_deliver {
        # Happens when we have all the pieces we need, and are about to send the
        # response to the client.
        #
        # You can do accounting or modifying the final object here.
        if (obj.hits > 0 ) {
            set resp.http.X-Cache = "Hit via " + server.ip;
            }
        else {
            set resp.http.X-Cache = "Miss From " + server.ip;
            }
        if (req.http.cache-control !~ "s-maxage" ) {
            if (bereq.url  ~ "(?i)\.(jpg|jpeg|png|gif|css|js)$") {
                    unset beresq.http.Set-Cookie;
                    set beresp.ttl = 3600s;
                    }
            }
    }

记录并设置客户端ip
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 


    sub vcl_recv {
        # Happens before we check if we have this in cache already.
        #
        # Typically you clean up the request here, removing cookies you don't need,
        # rewriting the request, etc.
        if ( req.url ~ "^/login" ) {
            return (pass);
            }
    
    if (req.restarts ==0 ) {
            if (req.http.X-Forwarded-For) {
                    set req.http.X-Forwarded-For = req.http.X-Forwarded-For + client.ip;

            }else {
                    set req.http.X-Forwarded-For = req.http.X-Forwarded-For + client.ip;
            }

            }

对缓存对象进行修剪
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    [root@centos-151 varnish]# vim default.vcl

        sub vcl_purge {
                return (synth(200,"Purged"));
        }
        sub vcl_recv {
            # Happens before we check if we have this in cache already.
            #
            # Typically you clean up the request here, removing cookies you don't need,
            # rewriting the request, etc.
                if req.method =="PURGE" ) {
                        return(purge);
                }

        }

    # 测试步骤， 先请求下， 是miss的， 在请求是hit的， purge下， 在请求就是miss的了。
    [root@centos-151 varnish]# curl -I 192.168.46.151
    HTTP/1.1 200 OK
    Server: nginx/1.12.2
    Date: Fri, 23 Mar 2018 12:49:47 GMT
    Content-Type: text/html
    Content-Length: 27
    Last-Modified: Fri, 23 Mar 2018 10:55:32 GMT
    ETag: "5ab4dd24-1b"
    X-Varnish: 32772
    Age: 0
    Via: 1.1 varnish-v4
    X-Cache: Miss From 192.168.46.151
    Connection: keep-alive

    [root@centos-151 varnish]# curl -I 192.168.46.151
    HTTP/1.1 200 OK
    Server: nginx/1.12.2
    Date: Fri, 23 Mar 2018 12:49:47 GMT
    Content-Type: text/html
    Content-Length: 27
    Last-Modified: Fri, 23 Mar 2018 10:55:32 GMT
    ETag: "5ab4dd24-1b"
    X-Varnish: 7 32773
    Age: 2
    Via: 1.1 varnish-v4
    X-Cache: Hit via 192.168.46.151
    Connection: keep-alive

    [root@centos-151 varnish]# curl -I -X  "PURGE" 192.168.46.151
    HTTP/1.1 200 Purged
    Date: Fri, 23 Mar 2018 12:49:53 GMT
    Server: Varnish
    X-Varnish: 9
    Content-Type: text/html; charset=utf-8
    Retry-After: 5
    Content-Length: 236
    Connection: keep-alive

    [root@centos-151 varnish]# curl -I 192.168.46.151
    HTTP/1.1 200 OK
    Server: nginx/1.12.2
    Date: Fri, 23 Mar 2018 12:49:58 GMT
    Content-Type: text/html
    Content-Length: 27
    Last-Modified: Fri, 23 Mar 2018 10:55:32 GMT
    ETag: "5ab4dd24-1b"
    X-Varnish: 11
    Age: 0
    Via: 1.1 varnish-v4
    X-Cache: Miss From 192.168.46.151
    Connection: keep-alive

添加权限控制
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    [root@centos-151 varnish]# vim default.vcl

    //定义一个权限，下面vcl_recv去匹配
    acl purges {
            "127.0.0.1"/8;
            "192.168.46.151";
    }       
    sub vcl_purge {
            return (synth(200,"Purged"));
    }
    sub vcl_recv {
        # Happens before we check if we have this in cache already.
        #
        # Typically you clean up the request here, removing cookies you don't need,
        # rewriting the request, etc.
            if (req.method == "PURGE" ) {
                    if (!client.ip ~ purges)
                    {
                            return(synth(405,"not allow form " + client.ip));
                    }
                    return(purge);
            }

    }

    # 测试下
    [root@centos-151 varnish]# curl -I -X "PURGE" 192.168.46.151
    HTTP/1.1 200 Purged
    Date: Fri, 23 Mar 2018 13:00:14 GMT
    Server: Varnish
    X-Varnish: 2
    Content-Type: text/html; charset=utf-8
    Retry-After: 5
    Content-Length: 236
    Connection: keep-alive

    [root@centos-152 html]# curl -I -X "PURGE" 192.168.46.151
    HTTP/1.1 405 not allow form 192.168.46.152
    Date: Fri, 23 Mar 2018 13:00:37 GMT
    Server: Varnish
    X-Varnish: 32770
    Content-Type: text/html; charset=utf-8
    Retry-After: 5
    Content-Length: 309
    Connection: keep-alive


匹配去刷新缓存
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    # 命令行方式
    [root@centos-151 varnish]# varnishadm  -S /etc/varnish/secret  -T 127.0.0.1:6082
    200        
    -----------------------------
    Varnish Cache CLI 1.0
    -----------------------------
    Linux,3.10.0-693.el7.x86_64,x86_64,-smalloc,-smalloc,-hcritbit
    varnish-4.0.5 revision 07eff4c29

    Type 'help' for command list.
    Type 'quit' to close CLI session.

    ban req.url ~ ^/js
    200        

动静分离
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    backend default {
        .host = "192.168.46.152";
        .port = "80";
    }
    backend appsrv {
        .host = "192.168.46.152";
        .port = "80";
    }

    sub vcl_recv {
        # Happens before we check if we have this in cache already.
        #
        # Typically you clean up the request here, removing cookies you don't need,
        # rewriting the request, etc.
        if ( req.url ~ "\.php$" )
            {
                    set req.backend_hint = appsrv;
            }
        else {
                    set req.backend_hint = default;
            }
        }

后端调度
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    import directors;

    backend web152 {
            .host = "192.168.46.152";
            .port ="80";
    }

    backend web153 {
            .host = "192.168.46.153";
            .port ="80";
    }
    sub vcl_init {
            new websrvs = directors.random();
            websrvs.add_backend(web152);
            websrvs.add_backend(web153);
    }

    sub vcl_recv {

            set req.backend_hint = websrvs.backend();
            if (req.method == "PURGE" ) { 
                    if (!client.ip ~ purges)
                    {
                            return(synth(405,"not allow form " + client.ip));
                    }
                    return(purge); 
            }

    }  

    # 测试下   ，这里发现都是152的结果。 这是因为缓存的原有了
    [root@centos-151 varnish]# for i in {1..10} ; do curl 192.168.46.151 ; sleep 1; done
    centos-152.linuxpanda.tech
    centos-152.linuxpanda.tech
    centos-152.linuxpanda.tech
    centos-152.linuxpanda.tech
    centos-152.linuxpanda.tech
    centos-152.linuxpanda.tech
    centos-152.linuxpanda.tech
    centos-152.linuxpanda.tech
    centos-152.linuxpanda.tech
    centos-152.linuxpanda.tech

    # 稍稍修改下配置文件，设置下recv都到pass后端去。这样就不会使用缓存了，这里仅仅是测试。
    sub vcl_recv {
            set req.backend_hint = websrvs.backend();
            return(pass);
    }   

    # 测试
    [root@centos-151 varnish]# systemctl restart varnish     # 危险操作，强烈建议使用load，use操作。
    [root@centos-151 varnish]# for i in {1..10} ; do curl 192.168.46.151 ; sleep 1; done
    centos-153.linuxpanda.tech
    centos-152.linuxpanda.tech
    centos-153.linuxpanda.tech
    centos-152.linuxpanda.tech
    centos-153.linuxpanda.tech
    centos-152.linuxpanda.tech
    centos-153.linuxpanda.tech
    centos-152.linuxpanda.tech
    centos-153.linuxpanda.tech
    centos-152.linuxpanda.tech

基于cookie的会话绑定
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

sub vcl_init { 
    new cookie_hash = directors.hash();
    cookie_hash.add_backend(web152);
    cookie_hash.add_backend(web153);
}

sub vcl_recv { 
    set req.backend_hint = cookie_hash.backend(req.http.cookie);
}


上面的代码如果请求都是有cookie的话还好， 如果没有还不清楚是不是仅仅调度到一个服务器上面去。如果是还是需要加额外的逻辑控制的。
，后面有时间再去查查这个东东。


健康检查
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    [root@centos-151 varnish]# vim default.vcl
    # 修改为如下内容
    probe default_probe {
                    .url="/index.html";
                    .timeout =2s;
                    .interval=1s;
                    .window =5;
                    .threshold=2;
    }
    backend web152 {
            .host = "192.168.46.152";
            .port ="80";
            .probe = default_probe;
    }

    backend web153 {  
            .host = "192.168.46.153"; 
            .port ="80";
            .probe = default_probe;
    }  

    [root@centos-151 varnish]# systemctl restart varnish    # 危险操作，强烈建议使用load，use操作。
    [root@centos-151 varnish]# !for
    for i in {1..10} ; do curl 192.168.46.151 ; sleep 1; done
    centos-153.linuxpanda.tech
    centos-152.linuxpanda.tech
    centos-153.linuxpanda.tech
    centos-152.linuxpanda.tech
    centos-153.linuxpanda.tech
    centos-152.linuxpanda.tech
    centos-153.linuxpanda.tech
    centos-152.linuxpanda.tech
    centos-153.linuxpanda.tech
    centos-152.linuxpanda.tech
    [root@centos-151 varnish]# for i in {1..10} ; do curl 192.168.46.151 ; sleep 1; done
    centos-153.linuxpanda.tech
    centos-153.linuxpanda.tech
    centos-153.linuxpanda.tech
    centos-153.linuxpanda.tech
    centos-153.linuxpanda.tech
    centos-153.linuxpanda.tech
    centos-153.linuxpanda.tech
    centos-153.linuxpanda.tech
    centos-153.linuxpanda.tech
    centos-153.linuxpanda.tech



varnish常用工具
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    # 查看统计信息（非状态信息）
    [root@centos-151 varnish]# varnishstat

    # 查看日志信息， 很原始，且实时的， 非历史数据
    [root@centos-151 varnish]# varnishlog

    # 常用格式查看
    [root@centos-151 varnish]# varnishncsa
    192.168.46.152 - - [24/Mar/2018:18:49:55 +0800] "GET http://192.168.46.151/ HTTP/1.1" 200 27 "-" "curl/7.29.0"

    # 启动ncsa服务，来记录日志，
    [root@centos-151 varnish]# systemctl start varnishncsa
    [root@centos-151 varnish]# cat /var/log/varnish/varnishncsa.log 
    192.168.46.152 - - [24/Mar/2018:18:51:35 +0800] "GET http://192.168.46.151/ HTTP/1.1" 200 27 "-" "curl/7.29.0"

    # varnish top信息查看
    [root@centos-151 varnish]# varnishtop
