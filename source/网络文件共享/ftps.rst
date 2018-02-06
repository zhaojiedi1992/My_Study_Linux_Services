ftps
=========================================================

安装vsftpd
--------------------------------------------------------

.. code-block:: bash

    [root@centos-7 vsftpd]$yum install vsftpd

修改配置项
--------------------------------------------------------

.. code-block:: bash

    [root@centos-7 vsftpd]$vim vsftpd.con
    ########################################################################
    #  创建完毕后自己的配置
    ########################################################################

    ssl_enable=YES
    allow_anon_ssl=NO
    force_local_logins_ssl=YES
    force_local_data_ssl=YES
    rsa_cert_file=/etc/pki/tls/certs/vsftpd.pem

创建证书和私钥文件
--------------------------------------------------------

.. code-block:: text

    [root@centos-7 certs]$cd /etc/pki/tls/certs/ 
    root@centos-7 certs]$make vsftpd.pem
    umask 77 ; \
    PEM1=`/bin/mktemp /tmp/openssl.XXXXXX` ; \
    PEM2=`/bin/mktemp /tmp/openssl.XXXXXX` ; \
    /usr/bin/openssl req -utf8 -newkey rsa:2048 -keyout $PEM1 -nodes -x509 -days 365 -out $PEM2  ; \
    cat $PEM1 >  vsftpd.pem ; \
    echo ""    >> vsftpd.pem ; \
    cat $PEM2 >> vsftpd.pem ; \
    rm -f $PEM1 $PEM2
    Generating a 2048 bit RSA private key
    ....+++
    ........................................................................................+++
    writing new private key to '/tmp/openssl.x5jCn5'
    -----
    You are about to be asked to enter information that will be incorporated
    into your certificate request.
    What you are about to enter is what is called a Distinguished Name or a DN.
    There are quite a few fields but you can leave some blank
    For some fields there will be a default value,
    If you enter '.', the field will be left blank.
    -----
    Country Name (2 letter code) [XX]:cn
    State or Province Name (full name) []:henan
    Locality Name (eg, city) [Default City]:zhengzhou
    Organization Name (eg, company) [Default Company Ltd]:linuxpanda
    Organizational Unit Name (eg, section) []:opt
    Common Name (eg, your name or your server's hostname) []:*.linuxpanda
    Email Address []:
    [root@centos-7 certs]$ll
    total 20
    lrwxrwxrwx. 1 root root   49 Nov  7 16:08 ca-bundle.crt -> /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
    lrwxrwxrwx. 1 root root   55 Nov  7 16:08 ca-bundle.trust.crt -> /etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt
    -rw-------. 1 root root 1371 Jan 27 17:41 localhost.crt
    -rwxr-xr-x. 1 root root  610 Aug  4  2017 make-dummy-cert
    -rw-r--r--. 1 root root 2516 Aug  4  2017 Makefile
    -rwxr-xr-x. 1 root root  829 Aug  4  2017 renew-dummy-cert
    -rw-------. 1 root root 3035 Feb  3 17:20 vsftpd.pem

测试
---------------------------------------------------------

这里在windows环境下使用 filezilla_ 软件进行测试。

.. _filezilla: https://filezilla-project.org/

.. image:: /images/fileshare/建立站点.png

.. image:: /images/fileshare/证书.png

.. image:: /images/fileshare/filezilla.png