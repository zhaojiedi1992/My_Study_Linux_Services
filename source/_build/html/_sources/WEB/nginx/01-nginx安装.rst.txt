nginx安装
===============================================

yum安装
--------------------------------

.. code-block:: bash 

    yum install nginx


编译安装
--------------------------------

    useradd nginx -r -s /sbin/nologin
    wget http://nginx.org/download/nginx-1.12.2.tar.gz
    tar xf nginx-1.12.2.tar.gz
    cd nginx-1.12.2
    ./configure --prefix=/usr/local/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --user=nginx --group=nginx   \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_dav_module \
    --with-http_stub_status_module \
    --with-threads --with-file-aio

    make && make install 