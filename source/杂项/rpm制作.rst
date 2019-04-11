rpm制作
==============================

制作rpm过程
------------------------------

#. 计划你要构建的计划
#. 收集需要的软件
#. 补丁收集
#. 规划好依赖关系
#. 构建rpm
#. 测试rpm


构建目录
----------------------

1. BUILD 构建目录
2. RPMS  rpm放置目录
3. SOURCES  源码目录
4. SPECS    spec文件目录
5. SRPMS    src rpm 目录

安装工具
---------------------

.. code-block:: bash 
    yum install rpm-build 
    useradd rpm 
    su - rpm 
    rpmbuild  --showrc  |grep topdir
    # -14: _topdir    %{getenv:HOME}/rpmbuild   可以看到默认的topdir 为用户的家目录的rpmbuild目录
    mkdir -pv rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS,BUILDROOT}

准备资料
-------------------------------

.. code-block:: bash 

    # 这里对nginx-1.13.1的源码进行执着rpm
    wget https://nginx.org/download/nginx-1.13.1.tar.gz -O ~/rpmbuild/SOURCES/nginx-1.13.1.tar.gz

编写spec文件
--------------------------------------

    ##########################################
    # 定义用户和组
    %define nginx_user nginx
    %define nginx_group nginx
    %define BASE_CONFIGURE_ARGS $(echo "--prefix=%{_sysconfdir}/nginx --sbin-path=%{_sbindir}/nginx --modules-path=%{_libdir}/nginx/modules --conf-path=%{_sysconfdir}/nginx/nginx.conf --error-log-path=%{_localstatedir}/log/nginx/error.log --http-log-path=%{_localstatedir}/log/nginx/access.log --pid-path=%{_localstatedir}/run/nginx.pid --lock-path=%{_localstatedir}/run/nginx.lock --http-client-body-temp-path=%{_localstatedir}/cache/nginx/client_temp --http-proxy-temp-path=%{_localstatedir}/cache/nginx/proxy_temp --http-fastcgi-temp-path=%{_localstatedir}/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=%{_localstatedir}/cache/nginx/uwsgi_temp --http-scgi-temp-path=%{_localstatedir}/cache/nginx/scgi_temp --user=%{nginx_user} --group=%{nginx_group} --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module")
    ##########################################

    ##########################################
    # 元数据
    Name:   nginx
    Version: 1.13.1
    Release:        1%{?dist}
    Summary: High performance web server

    Group:   System Environment/Daemons
    License: GPL
    URL:     http://nginx.org/
    Source0: http://nginx.org/download/%{name}-%{version}.tar.gz

    BuildRequires: zlib-devel pcre-devel
    Requires(pre): shadow-utils
    Requires: systemd
    Requires: openssl >= 1.0.1

    %description
    nginx [engine x] is an HTTP and reverse proxy server, as well as
    a mail proxy server.

    ##########################################

    %prep
    %setup -q


    %build
    ./configure %{BASE_CONFIGURE_ARGS}

    make %{?_smp_mflags}


    %install
    make install DESTDIR=%{buildroot}


    %files
    %config(noreplace)   /etc/nginx/fastcgi.conf
    %config(noreplace)   /etc/nginx/fastcgi.conf.default
    %config(noreplace)   /etc/nginx/fastcgi_params
    %config(noreplace)   /etc/nginx/fastcgi_params.default
    %config(noreplace)   /etc/nginx/html/50x.html
    %config(noreplace)   /etc/nginx/html/index.html
    %config(noreplace)   /etc/nginx/koi-utf
    %config(noreplace)   /etc/nginx/koi-win
    %config(noreplace)   /etc/nginx/mime.types
    %config(noreplace)   /etc/nginx/mime.types.default
    %config(noreplace)   /etc/nginx/nginx.conf
    %config(noreplace)   /etc/nginx/nginx.conf.default
    %config(noreplace)   /etc/nginx/scgi_params
    %config(noreplace)   /etc/nginx/scgi_params.default
    %config(noreplace)   /etc/nginx/uwsgi_params
    %config(noreplace)   /etc/nginx/uwsgi_params.default
    %config(noreplace)   /etc/nginx/win-utf
    %config(noreplace)   /usr/sbin/nginx
    %doc



    %changelog
    * Sat Oct  1 2019  zhaojiedi1992 <zhaojiedi1992@outlook.com>
    - 1.13.1
    - init

    %pre
    # Add the "nginx" user
    getent group %{nginx_group} >/dev/null || groupadd -r %{nginx_group}
    getent passwd %{nginx_user} >/dev/null || \
        useradd -r -g %{nginx_group} -s /sbin/nologin \
        -c "nginx user"  %{nginx_user}
    exit 0

    %post
    mkdir /var/log/nginx
    mkdir /var/cache/nginx/client_temp -pv
    touch /var/log/nginx/access.log
    touch /var/log/nginx/error.log
    chmod 777 /var/log/nginx/access.log 

测试构建
---------------------------------------------

.. code-block:: bash 

rpmbuild  -bb nginx.spec 
yum reinstall /home/rpm/rpmbuild/RPMS/x86_64/nginx-1.13.1-1.el7.x86_64.rpm -y 
rpm -ql |grep nginx 
netstat -tunlp |grep 80
/usr/sbin/nginx 
netstat -tunlp |grep 80


其他完善
-------------------------------------------

service文件

日志滚动

man文档


