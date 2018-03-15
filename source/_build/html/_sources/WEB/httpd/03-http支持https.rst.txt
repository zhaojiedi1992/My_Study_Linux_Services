http支持https
=================================================

安装mod_ssl模块
--------------------------------------

.. code-block:: bash

    [root@102 html]# yum -y install mod_ssl


搭建ca服务器
------------------------------------------------

这一步可以不用做，如果已经有ca服务器的话。

.. code-block:: text

    [root@102 CA]# cat /etc/pki/tls/openssl.cnf  |grep '$dir'
    certs		= $dir/certs		# Where the issued certs are kept
    crl_dir		= $dir/crl		# Where the issued crl are kept
    database	= $dir/index.txt	# database index file.
    new_certs_dir	= $dir/newcerts		# default place for new certs.
    certificate	= $dir/cacert.pem 	# The CA certificate
    serial		= $dir/serial 		# The current serial number
    crlnumber	= $dir/crlnumber	# the current crl number
    crl		= $dir/crl.pem 		# The current CRL
    private_key	= $dir/private/cakey.pem# The private key
    RANDFILE	= $dir/private/.rand	# private random number file
    serial		= $dir/tsaserial	# The current serial number (mandatory)
    signer_cert	= $dir/tsacert.pem 	# The TSA signing certificate
    certs		= $dir/cacert.pem	# Certificate chain to include in reply
    signer_key	= $dir/private/tsakey.pem # The TSA private key (optional)
    [root@102 CA]# touch index.txt
    [root@102 CA]# echo 01 > serial
    [root@102 CA]# (umask 066; openssl genrsa -out private/cakey.pem 2048)
    Generating RSA private key, 2048 bit long modulus
    .....+++
    ...........................................................+++
    e is 65537 (0x10001)
    [root@102 CA]# openssl  req -x509  -new -key private/cakey.pem  -out cacert.pem -days 3650 
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

http服务申请证书
------------------------------------------------------------------------

.. code-block:: text

    [root@102 CA]# cd /etc/httpd/
    [root@102 httpd]# ls
    conf  conf.d  conf.modules.d  logs  modules  run
    [root@102 httpd]# mkdir ssl
    [root@102 httpd]# cd ssl/
    [root@102 ssl]# ls
    [root@102 ssl]# (umask 066; openssl genrsa -out www.linuxpanda.tech.key 1024)
    Generating RSA private key, 1024 bit long modulus
    .................++++++
    .....++++++
    e is 65537 (0x10001)
    [root@102 ssl]# ll
    total 4
    -rw-------. 1 root root 887 Jan 27 18:02 www.linuxpanda.tech.key
    [root@102 ssl]# openssl req -new -key www.linuxpanda.tech.key  -out www.linuxpanda.tech.csr
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
    Organizational Unit Name (eg, section) []:linuxpanda.tech
    Common Name (eg, your name or your server's hostname) []:*.linuxpanda.tech
    Email Address []:

    Please enter the following 'extra' attributes
    to be sent with your certificate request
    A challenge password []:
    An optional company name []:

    [root@102 ssl]# openssl  ca -in www.linuxpanda.tech.csr  -out /etc/pki/CA/certs/www.linuxapnda.tech.crt -days 700
    [root@102 ssl]# cp /etc/pki/CA/certs/www.linuxapnda.tech.crt  .
    [root@102 ssl]# cp /etc/pki/CA/cacert.pem  .

http配置文件修改
------------------------------------------------------------------------

.. code-block:: bash

    [root@102 ssl]# vim /etc/httpd/conf.d/ssl.conf 
    # 修改下面3行内容为对应的文件
    SSLCertificateFile /etc/httpd/ssl/www.linuxapnda.tech.crt
    SSLCertificateKeyFile /etc/httpd/ssl/www.linuxpanda.tech.key
    SSLCertificateChainFile /etc/httpd/ssl/cacert.pem


测试
--------------------------------------------------------------

.. code-block:: bash

    [root@102 ssl]# curl https://www.linuxpanda.tech --cacert /etc/httpd/ssl/cacert.pem 

浏览器模式，需要把对应的ca文件复制到主机上， 修改文件名为crt的，然后双击安装到收信人的根证书机构。
