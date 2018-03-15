nginx基础配置说明
===========================================


核心模块
-----------------------------------------------------

user
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	user user [group];
    Default:	
    user nobody nobody;
    Context:	main

默认值是nobody，但是rpm包编译都是指定的nginx了， 即使你没有指定该配置也是nginx。

pid
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	pid file;
    Default:	
    pid logs/nginx.pid;
    Context:	main

这个配置项指定了nginx的master主进程的进程id存储的文件。

include
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	include file | mask;
    Default:	—
    Context:	any

包含特定的配置文件到当前文件中来。 

load_module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	load_module file;
    Default:	—
    Context:	main
    This directive appeared in version 1.9.11.

加载特定的模块进来。

worker_cpu_affinity
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	worker_cpu_affinity cpumask ...;
    worker_cpu_affinity auto [cpumask];
    Default:	—
    Context:	main
    样例： 
        worker_processes    4;
        worker_cpu_affinity 0001 0010 0100 1000;

worker_processes
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	worker_processes number | auto;
    Default:	
    worker_processes 1;
    Context:	main

定义下worker进程的个数， auto的话就是cpu的个数。

worker_priority
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	worker_priority number;
    Default:	
    worker_priority 0;
    Context:	main

指定工作进程的优先级的， 数值越大，优先级越低。

worker_rlimit_nofile
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	worker_rlimit_nofile number;
    Default:	—
    Context:	main

每个worker进程可以打开的文件数量。


worker_connections
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	worker_connections number;
    Default:	
    worker_connections 512;
    Context:	events

工作进程的连接数量。

use
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	use method;
    Default:	—
    Context:	events
    样例： 
        use epoll;

指明并发连接请求的处理方法，默认自动选择最优方法

accept_mutex 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	accept_mutex on | off;
    Default:	
    accept_mutex off;
    Context:	events

处理新连接请求的方法， on代表有新连接的时候，唤醒所有worker进程，但是只有一个获得连接。

daemon
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	daemon on | off;
    Default:	
    daemon on;
    Context:	main

on代表nginx后台运行的，off代表前台运行。

master_process
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	master_process on | off;
    Default:	
    master_process on;
    Context:	main

是否以master/worker模型去运行nginx, 默认为on,off将不启动worker。

error_log
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	error_log file [level];
    Default:	
    error_log logs/error.log error;
    Context:	main, http, mail, stream, server, location


指定错误日志位置的，可以指定到stderr,syslog,memory。


标准模块
-----------------------------------------------------

listen
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	listen address[:port] [default_server] [ssl] [http2 | spdy] [proxy_protocol] [setfib=number] [fastopen=number] [backlog=number] [rcvbuf=size] [sndbuf=size] [accept_filter=filter] [deferred] [bind] [ipv6only=on|off] [reuseport] [so_keepalive=on|off|[keepidle]:[keepintvl]:[keepcnt]];
    listen port [default_server] [ssl] [http2 | spdy] [proxy_protocol] [setfib=number] [fastopen=number] [backlog=number] [rcvbuf=size] [sndbuf=size] [accept_filter=filter] [deferred] [bind] [ipv6only=on|off] [reuseport] [so_keepalive=on|off|[keepidle]:[keepintvl]:[keepcnt]];
    listen unix:path [default_server] [ssl] [http2 | spdy] [proxy_protocol] [backlog=number] [rcvbuf=size] [sndbuf=size] [accept_filter=filter] [deferred] [bind] [so_keepalive=on|off|[keepidle]:[keepintvl]:[keepcnt]];
    Default:	
    listen *:80 | *:8000;
    Context:	server

指定监听地址。

server_name
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	server_name name ...;
    Default:	
    server_name "";
    Context:	server

指定主机名字

匹配优先级机制从高到低：

#. 首先是字符串精确匹配 如：www.magedu.com
#. 左侧*通配符 如：\*.magedu.com
#. 右侧*通配符 如：www.magedu.*
#. 正则表达式 如： ~^.*\.magedu\.com$
#. default_server

root
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text

    Syntax:	root path;
    Default:	
    root html;
    Context:	http, server, location, if in location

指定根位置的


tcp_nodelay
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	tcp_nodelay on | off;
    Default:	
    tcp_nodelay on;
    Context:	http, server, location


keepalived模式下是不是延迟发送，将多个请求合并在发送。

sendfile
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	sendfile on | off;
    Default:	
    sendfile off;
    Context:	http, server, location, if in location


是否开启sendfile功能， 在内核中封装报文直接发送，默认是off的。


server_tokens
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	server_tokens on | off | build | string;
    Default:	
    server_tokens on;
    Context:	http, server, location

是否在响应报文的server首部显示nginx版本信息。


location
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	location [ = | ~ | ~* | ^~ ] uri { ... }
    location @name { ... }
    Default:	—
    Context:	server, location

在一个server中location配置端可以有多个，用于实现从uri到文件系统的路径映射，找到最佳的应用配置。

匹配优先级从高到低： =, ^~, ～/～*, 不带符号

alias
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	alias path;
    Default:	—
    Context:	location


定义路径别名的，文档映射的另外一种机制。


index
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	index file ...;
    Default:	
    index index.html;
    Context:	http, server, location


指定默认网页的，默认值是index.html 


error_page
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	error_page code ... [=[response]] uri;
    Default:	—
    Context:	http, server, location, if in location
    样例配置： 
        error_page 404             /404.html;
        error_page 500 502 503 504 /50x.html;
        error_page 404 =200 /empty.gif;

定义错误页的。

try_files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	try_files file ... uri;
    try_files file ... =code;
    Default:	—
    Context:	server, location
    样例： 
        location / {
            try_files $uri $uri/index.html $uri.html =404;
        }

是否在响应报文的server首部显示nginx版本信息。


keepalive_timeout
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	keepalive_timeout timeout [header_timeout];
    Default:	
    keepalive_timeout 75s;
    Context:	http, server, location


设定保存连接超时时长，0表示禁止长连接，默认是75s。



keepalive_requests
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	keepalive_requests number;
    Default:	
    keepalive_requests 100;
    Context:	http, server, location
    This directive appeared in version 0.8.0.

在一次长连接上所运行请求的资源的最大数量，默认是100。


keepalive_disable
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	keepalive_disable none | browser ...;
    Default:	
    keepalive_disable msie6;
    Context:	http, server, location

对特定浏览器禁用长连接。


send_timeout
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	send_timeout time;
    Default:	
    send_timeout 60s;
    Context:	http, server, location



向客户端发送响应报文的超时时长，此处是指两次写操作之间的间隔时长，而非整个响应过程的传输时长。


client_body_buffer_size
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	client_body_buffer_size size;
    Default:	
    client_body_buffer_size 8k|16k;
    Context:	http, server, location


用于接受每个客户端请求报文的body部分的缓冲区大小，默认为16k,超过这个大小就将其暂存到磁盘上的client_body_temp_path位置。



client_body_temp_path
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	client_body_temp_path path [level1 [level2 [level3]]];
    Default:	
    client_body_temp_path client_body_temp;
    Context:	http, server, location



设定用于存储客户端请求报文的body部分的临时存储路径及子目录结构和数量


limit_rate
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	limit_rate_after size;
    Default:	
    limit_rate_after 0;
    Context:	http, server, location, if in location
    This directive appeared in version 0.8.0.

用于限制响应给客户端的传输速率，单位是bytes,0代表不限制。


limit_except
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	limit_except method ... { ... }
    Default:	—
    Context:	location
    样例： 
        limit_except GET {
        allow 192.168.1.0/24;
        deny all;
        }
    代表处理get,head之外的其他方法，只允许192.168.1.0/24网段访问。

限制客户端使用除了特定的请求方法之外的其他方法。

aio
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	aio on | off | threads[=pool];
    Default:	
    aio off;
    Context:	http, server, location
    This directive appeared in version 0.8.11.

是否启用异步io功能。

directio
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	directio size | off;
    Default:	
    directio off;
    Context:	http, server, location
    This directive appeared in version 0.7.7.


大于给定的文件大小的死后，直接同步到磁盘，而非写文件。

open_file_cache
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	open_file_cache off;
    open_file_cache max=N [inactive=time];
    Default:	
    open_file_cache off;
    Context:	http, server, location

是否打开文件缓存，需要配合open_file_cache max=N使用，可以缓存的信息如下： 

- 文件元数据信息
- 打开的目录结构
- 没有找到的或者没有访问权限的文件的相关信息。


open_file_cache_errors
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	open_file_cache_errors on | off;
    Default:	
    open_file_cache_errors off;
    Context:	http, server, location

是否缓存查找时发生错误的文件一类的信息，默认是off。

open_file_cache_min_uses
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	open_file_cache_min_uses number;
    Default:	
    open_file_cache_min_uses 1;
    Context:	http, server, location

在指定的时常内，至少被明智特定的次数才可以归为活动项。

open_file_cache_valid
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    Syntax:	open_file_cache_valid time;
    Default:	
    open_file_cache_valid 60s;
    Context:	http, server, location

缓存项邮箱型检查的频率，默认是60s。




ngx_http_access_module
-----------------------------------------------------

allow
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： allow address | CIDR | unix: | all;

用于允许特定主机访问

deny
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： deny address | CIDR | unix: | all;

用于禁止特定主机访问

.. attention:: 这里的allow、deny和apache中不一样，如果有一条匹配就返回对应结果。


ngx_http_auth_basic_module
-----------------------------------------------------

auth_basic
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法：auth_basic string | off;

提示认证的信息文本内容

auth_basic_user_file
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法：auth_basic_user_file file;

认证的基本用户文件，口令文件使用htpasswd命令实现（在httpd-tools包里面提供）

样例： 

.. code-block:: text 

    location /admin/ {
    auth_basic "Admin Area";
    auth_basic_user_file /etc/nginx/.ngxpasswd;
    } 

ngx_http_stub_status_module
-------------------------------

auth_basic
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

提示输出nginx的基本状态信息。

样例： 

.. code-block:: text 

    location /status {
    stub_status;
    allow 172.16.0.0/16;
    deny all;
    }


ngx_http_log_module
----------------------------

log_format
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法：log_format name string ...;

日志格式定义

access_log
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法：access_log path [format [buffer=size] [gzip[=level]]
[flush=time] [if=condition]];

访问日志文件路径，格式和相关的缓冲区压缩等相关配置。

样例： 

.. code-block:: text 

    log_format compression '$remote_addr-$remote_user [$time_local] '
    '"$request" $status $bytes_sent '
    '"$http_referer" "$http_user_agent" "$gzip_ratio"';
    access_log /spool/logs/nginx-access.log compression buffer=32k;

open_log_file_cache
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法 open_log_file_cache max=N [inactive=time]
[min_uses=N] [valid=time];

缓存各个日志文件的信息。


ngx_http_gzip_module
---------------------------------

log_format
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法：gzip on | off;

启用或者禁用gzip压缩

gzip_comp_level
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法：gzip_comp_level level;

压缩比，默认是1

gzip_disable
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法：gzip_disable regex ...;

匹配到特定浏览器客户端不执行压缩功能。

gzip_min_length
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法：gzip_min_length length;

启用压缩功能的响应报文的大小阈值，低于特定值就不压缩了。

gzip_http_version
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： gzip_http_version 1.0 | 1.1;

设定启用压缩功能时，协议的最小版本。

gzip_buffers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法：gzip_buffers number size;

支持实现压缩功能时缓冲区熟练及每个缓存区的大小。

gzip_types
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： gzip_types mime-type ...;

那些资源进行压缩

gzip_vary
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法：gzip_vary on | off;

如果启用了压缩，是否在响应报文首部插入“Vary: Accept-Encoding”

gzip_proxied 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法：gzip_proxied off | expired | no-cache | no-store |
private | no_last_modified | no_etag | auth | any ...;

充当代理服务器的时候， 对于后端服务器的响应报文何种条件下启动压缩功能。

样例： 

.. code-block:: text 

    gzip on;
    gzip_comp_level 6;
    gzip_min_length 64;
    gzip_proxied any;
    gzip_types text/xml text/css application/javascript;

ngx_http_ssl_module
------------------------------------

ssl
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法：ssl on | off;

是否启用ssl功能

ssl_certificate
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： ssl_certificate file;

ssl证书文件

ssl_certificate_key
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： ssl_certificate_key file;

证书私钥

ssl_protocols
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： ssl_protocols [SSLv2] [SSLv3] [TLSv1] [TLSv1.1]

支持ssl版本协议，默认为后面3个。

ssl_session_cache
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法：ssl_session_cache off | none | [builtin[:size]] [shared:name:size];

ssl会话缓存

ssl_session_timeout
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： ssl_session_timeout time;

ssl会话超时

样例： 

.. code-block:: text 

    server {
    listen 443 ssl;
    server_name www.linuxpanda.com;
    root /vhosts/ssl/htdocs;
    ssl on;
    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;
    ssl_session_cache shared:sslcache:20m;
    ssl_session_timeout 10m;
    } 


ngx_http_rewrite_module
------------------------------------------------

rewrite
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： rewrite regex replacement [flag]

将用户请求的URI基于regex所描述的模式进行检查，匹配到时将其替换为replacement指定的新的URI


last
    重写完成后停止对当前URI在当前location中后续的其它重写操作，而后对新的URI启动新一轮重写检查；提前重
    启新一轮循环，不建议在location中使用
break
    重写完成后停止对当前URI在当前location中后续的其它重写操作，而后直接跳转至重写规则配置块之后的其它
    配置；结束循环，建议在location中使用。
redirect
    临时重定向，重写完成后以临时重定向方式直接返回重写后生成的新URI给客户端，由客户端重新发起请求；
    使用相对路径,或者http://或https://开头，状态码：302
permanent
    重写完成后以永久重定向方式直接返回重写后生成的新URI给客户端，由客户端重新发起请求，状态码：301

return
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： return code [text]; 或者 return code [text]; 或者 return URL;

停止处理，并返回给客户端指定的响应码。

rewrite_log
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： rewrite_log on | off;

是否开启重写日志，发送到error_log

set
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： set $variable value;

设置自定义变量

if
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： if (condition) { ... }

针对特定条件判定

.. code-block:: text 

    比较操作符：
        = 相同
        != 不同
        ~：模式匹配，区分字符大小写
        ~*：模式匹配，不区分字符大小写
        !~：模式不匹配，区分字符大小写
        !~*：模式不匹配，不区分字符大小写

    文件及目录存在性判断：
        -e, !-e 存在（包括文件，目录，软链接）
        -f, !-f 文件
        -d, !-d 目录
        -x, !-x 执行

ngx_http_referer_module
-------------------------------------

valid_referers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法：  valid_referers none|blocked|server_names|string ...;

定义referer首部的合法可用值，不能匹配的将是非法值。

- node: 报文首部没有referer首部
- blocked: 请求报文没有referer首部，但无有效值
- server_names: 主机名或者主机名模式
- arbitray_string:任意字符串，但可以使用*作为通配符
- regular expression: 正则表达式模式匹配到的字符串，要使用~开头。

样例： 

.. code-block:: text 

    valid_referers none block server_names *.linuxpanda.tech;
    if ($invalid_referer) {
    return 403 http://www.magedu.com;
    }

ngx_http_proxy_module
---------------------------------

proxy_pass
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： proxy_pass URL;

代理的路径，样例： 

.. code-block:: text 

    server {
    ...
    server_name HOSTNAME;
    location /uri/ {
    proxy_pass http://host[:port]; 最后没有/
    }
    ...
    }

使用此功能，可以动静分离， 将静态文件和动态文件分开调度。

proxy_set_header
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： proxy_set_header field value;

设定发往后端主机的请求报文的请求首部的值。

proxy_cache_path
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： proxy_cache_path;

用于定义可用于proxy功能的缓存

proxy_cache 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法：proxy_cache zone | off; 默认off

指定调用的缓存，或关闭缓存机制

proxy_cache_key
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： proxy_cache_key string;

缓存中用于键的内容，默认：  proxy_cache_key $scheme$proxy_host$request_uri;


proxy_cache_valid
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： proxy_cache_valid [code ...] time;

定义对特定响应码的响应内容的缓存时长

样例： 

.. code-block:: text 

    proxy_cache proxycache;
    proxy_cache_key $request_uri;
    proxy_cache_valid 200 302 301 1h;
    proxy_cache_valid any 1m;


proxy_cache_use_stale;
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法：proxy_cache_use_stale error | timeout | invalid_header | updating | http_500 | http_502 |
http_503 | http_504 | http_403 | http_404 | off ...

在被代理的后端服务器出现哪种问题的情况下，可以直接使用过期的响应客户端。



proxy_cache_method
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法：proxy_cache_methods GET | HEAD | POST ...;

对那些客户端的请求方法对应的响应进行缓存，get和head方法总是被缓存的。


proxy_hide_header
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： proxy_hide_header field;

用于隐藏后端服务器的特定的响应首部


proxy_connect_timeout
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： proxy_connect_timeout time;

与后端服务器建立连接的超时时长，超过返回502错误。



proxy_send_timeout
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法：proxy_send_timeout time

将请求发送给后端服务器的超时时长。



proxy_read_timeout
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： proxy_read_timeout time;

等待后端服务器发送响应报文的超时时长

ngx_http_headers_module
-------------------------------------


set
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： set $variable value;

设置自定义变量



add_header 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： add_header name value [always];

添加自定义头信息



add_trailer
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法：add_trailer name value [always];

add_trailer添加自定义响应信息的尾部


ngx_http_fastcgi_module
-------------------------------------

fastcgi_pass
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： fastcgi_pass address;

后端的fastcgi服务器地址

fastcgi_index
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： fastcgi_index name;

fastcgi 默认主页资源


fastcgi_param
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： fastcgi_param parameter value [if_not_empty];

设置传递给 FastCGI服务器的参数值，可以是文本，变量或组合


样例： 

.. code-block:: text 

    location ~* \.php$ {
    fastcgi_pass 后端fpm服务器IP:9000;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME
    /usr/share/nginx/html$fastcgi_script_name;
    include fastcgi_params;
    …
    }


    location ~* ^/(pm_status|ping)$ {
    include fastcgi_params;
    fastcgi_pass 后端fpm服务器IP :9000;
    fastcgi_param SCRIPT_FILENAME $fastcgi_script_name;
    }

fastcgi_cache_path
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法：fastcgi_cache_path path [levels=levels] [use_temp_path=on|off]
keys_zone=name:size [inactive=time] [max_size=size]
[manager_files=number] [manager_sleep=time] [manager_threshold=time]
[loader_files=number] [loader_sleep=time] [loader_threshold=time]
[purger=on|off] [purger_files=number] [purger_sleep=time]
[purger_threshold=time];

缓存路径。


fastcgi_cache
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： fastcgi_cache zone | off;

调用指定的缓存空间来缓存数据

fastcgi_cache_key
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： fastcgi_cache_key string;

定义用作缓存项的key的字符串


fastcgi_cache_method
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： fastcgi_cache_methods GET | HEAD | POST ...;

为哪些请求方法使用缓存


fastcgi_cache_min_uses
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法：fastcgi_cache_min_uses number;

缓存空间中的缓存项在inactive定义的非活动时间内至少要被访问到
此处所指定的次数方可被认作活动项


fastcgi_keep_conn
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： fastcgi_keep_conn on | off;

收到后端服务器响应后，fastcgi服务器是否关闭连接，建议启用长连接

fastcgi_cache_valid
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： fastcgi_cache_valid [code ...] time;

不同的响应码各自的缓存时长

样例： 

.. code-block:: text 

    http {
        fastcgi_cache_path /var/cache/nginx/fcgi_cache
        levels=1:2:1 keys_zone=fcgicache:20m inactive=120s;
        ...
        server {
            location ~* \.php$ {
            ...
            fastcgi_cache fcgicache;
            fastcgi_cache_key $request_uri;
            fastcgi_cache_valid 200 302 10m;
            fastcgi_cache_valid 301 1h;
            fastcgi_cache_valid any 1m; 
            ...
            }
    }

ngx_http_upstream_module
-------------------------------

upstream
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： upstream name { ... }

定义后端服务器组，会引入一个新的上下文。

server
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： server address [parameters];

定义后端服务器成员，weight定义权重，max_conn最大连接数量，max_fails失败尝试最大次数
faile_timeout后端标记不可用状态的时长，backup备用，down不可用。

ip_hash
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： ip_hash

源地址hash调度算法

least_conn
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： least_conn

最小连接调度算法

hash key 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法：hash key [consistent]  

基于特定的key的hash表来实现对请求的调度。

keepalive
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法：keepalive 连接数N

为每个worker进程保留的空闲的长连接数量。

health_check
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： health_check [parameters];

健康性检查，interval检查频率，fails失败次数，passes判定成功次数，uri测试目标，match指定的match配置块。


match
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： match name { ... }

对后端的服务器做健康检查时候，定义其结果判断机制，只能用于http上下文。

fastcgi_cache_valid
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： fastcgi_cache_valid [code ...] time;

不同的响应码各自的缓存时长

ngx_stream_core_module
----------------------------------

stream
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： stream { ... }

不同的响应码各自的缓存时长

样例： 

.. code-block:: text 

    stream {
        upstream mysqlsrvs {
        server 192.168.22.2:3306;
        server 192.168.22.3:3306;
        least_conn;
        }
        server {
        listen 10.1.0.6:3306;
        proxy_pass mysqlsrvs;
        }
    } 


listen
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法： listen address:port [ssl] [udp] [proxy_protocol]
[backlog=number] [bind] [ipv6only=on|off] [reuseport]
[so_keepalive=on|off|[keepidle]:[keepintvl]:[keepcnt]];

定义监听信息

ngx_stream_proxy_module
---------------------------------


proxy_pass
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法：proxy_pass address;

指定后端服务器地址


proxy_timeout
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法：proxy_timeout timeout;

无数据传输时候，保存连接状态的超时时长


porxy_connect_timeout
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

用法：proxy_connect_timeout time;

设置nginx与被代理的服务器尝试建立连接的超时时长默认为60s

样例配置

.. code-block:: text 

    stream {
    
        upstream mysqlsrvs {
        server 192.168.0.10:3306;
        server 192.168.0.11:3306;
        hash $remote_addr consistent;
        }

        server {
        listen 172.16.100.100:3306;
        proxy_pass mysqlsrvs;
        proxy_timeout 60s;
        proxy_connect_timeout 10s;
        }
    }