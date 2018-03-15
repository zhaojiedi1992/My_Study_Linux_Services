nginx支持https
===================================================


安装nginx
--------------------------------------

.. code-block:: bash 

    [root@localhost ~]# yum install nginx 


配置
--------------------------------------

.. code-block:: bash 

    [root@localhost conf.d]# cd /etc/pki/tls/certs/
    [root@localhost certs]# ls
    ca-bundle.crt  ca-bundle.trust.crt  make-dummy-cert  Makefile  renew-dummy-cert
    [root@localhost certs]# make www.crt
    umask 77 ; \
    /usr/bin/openssl genrsa -aes128 2048 > www.key
    Generating RSA private key, 2048 bit long modulus
    ...................................+++
    ..........................+++
    e is 65537 (0x10001)
    Enter pass phrase:
    Verifying - Enter pass phrase:
    umask 77 ; \
    /usr/bin/openssl req -utf8 -new -key www.key -x509 -days 365 -out www.crt 
    Enter pass phrase for www.key:
    You are about to be asked to enter information that will be incorporated
    into your certificate request.
    What you are about to enter is what is called a Distinguished Name or a DN.
    There are quite a few fields but you can leave some blank
    For some fields there will be a default value,
    If you enter '.', the field will be left blank.
    -----
    Country Name (2 letter code) [XX]:cn
    State or Province Name (full name) []:henan
    Locality Name (eg, city) [Default City]:zhenzhou
    Organization Name (eg, company) [Default Company Ltd]:linuxpanda.tech
    Organizational Unit Name (eg, section) []:opt
    Common Name (eg, your name or your server's hostname) []:www.linuxpanda.tech
    Email Address []:
    [root@localhost certs]# ll
    total 20
    lrwxrwxrwx. 1 root root   49 Jan 11 01:00 ca-bundle.crt -> /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
    lrwxrwxrwx. 1 root root   55 Jan 11 01:00 ca-bundle.trust.crt -> /etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt
    -rwxr-xr-x. 1 root root  610 Aug  4  2017 make-dummy-cert
    -rw-r--r--. 1 root root 2516 Aug  4  2017 Makefile
    -rwxr-xr-x. 1 root root  829 Aug  4  2017 renew-dummy-cert
    -rw-------  1 root root 1359 Mar 15 18:00 www.crt
    -rw-------  1 root root 1766 Mar 15 17:59 www.key
    [root@localhost certs]# openssl rsa -in www.key -out www2.key
    Enter pass phrase for www.key:
    writing RSA key
    [root@localhost certs]# ll
    total 24
    lrwxrwxrwx. 1 root root   49 Jan 11 01:00 ca-bundle.crt -> /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
    lrwxrwxrwx. 1 root root   55 Jan 11 01:00 ca-bundle.trust.crt -> /etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt
    -rwxr-xr-x. 1 root root  610 Aug  4  2017 make-dummy-cert
    -rw-r--r--. 1 root root 2516 Aug  4  2017 Makefile
    -rwxr-xr-x. 1 root root  829 Aug  4  2017 renew-dummy-cert
    -rw-r--r--  1 root root 1675 Mar 15 18:00 www2.key
    -rw-------  1 root root 1359 Mar 15 18:00 www.crt
    -rw-------  1 root root 1766 Mar 15 17:59 www.key
    [root@localhost certs]# mkdir /etc/nginx/conf.d/ssl
    [root@localhost certs]# cp www2.key /etc/nginx/conf.d/ssl/www.key
    [root@localhost certs]# cp www.crt /etc/nginx/conf.d/ssl/
    [root@localhost certs]# cd /etc/nginx/conf.d/
    [root@localhost conf.d]# ls
    bak  ssl  vhosts.conf
    [root@localhost conf.d]# vim vhosts.conf 
    [root@localhost conf.d]# cat vhosts.conf 
    server { 
        listen 443 ssl;
        server_name www.linuxpanda.tech;
        root /usr/share/nginx/multi_host_1;
        
        ssl on ;
        ssl_certificate /etc/nginx/conf.d/ssl/www.crt;
        ssl_certificate_key /etc/nginx/conf.d/ssl/www.key;
        ssl_session_cache  shared:sslcache:20m;
        ssl_session_timeout 10m;

    }

测试
----------------------------------------------

.. code-block:: bash

    [root@localhost conf.d]# curl https://www.linuxpanda.tech -k
    multi_host_1

