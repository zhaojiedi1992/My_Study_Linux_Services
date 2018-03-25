nginx常用案例
===============================

反向代理http
------------------------------------


.. code-block:: bash 

    [root@localhost conf.d]# vim vhosts.conf 

        upstream backend {
            server 172.18.46.152    weight=5;
            server 172.18.46.153;

        }

        server {
            listen 172.18.46.151:80;
            location / {
                proxy_pass http://backend;
            }
        }

    [root@localhost conf.d]# for i in {1..10} ; do curl 172.18.46.151; done;
    153
    152
    152
    152
    152
    152
    153
    152
    152
    152

反向代理mysql
------------------------------------

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

动静分离
--------------------------------------------

.. code-block:: text 

    server {
            listen 80;
            server_name www.linuxpanda.tech.com;
            root /data/web1/;
            location / {
                    proxy_pass http://172.18.46.152;
            }
            location ~* \.php$ {
                    proxy_pass http://172.18.46.153;
            }
    }

防盗链
--------------------------------------------

.. code-block:: bash 

    server {
            server_name www.b.com;
            root /data/web2;
            valid_referers none block server_names *.b.com  b.*  ~\.baidu\.;
            if ($invalid_referer) {
                    return 403 http://www.magedu.com/;
            }
    }

代理服务器的缓存功能
------------------------------------------------------------

.. code-block:: text 

    server {
            listen 80;
            server_name www.linuxpanda.tech;
            root /data/web1/;

            proxy_cache proxycache;
            proxy_cache_key $request_uri;
            proxy_cache_valid 200 302 301 1h;
            proxy_cache_valid any 1m;

            add_header X-Via $server_addr;
            add_header X-Cache $upstream_cache_status;
            add_header X-Accel $server_name;

            location / {
                    proxy_pass http://192.168.27.17;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            }

            location ~* \.php$ {
                    proxy_pass http://192.168.27.6;
            }
    }