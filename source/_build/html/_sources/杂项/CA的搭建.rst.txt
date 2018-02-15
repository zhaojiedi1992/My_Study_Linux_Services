CA的搭建
================================================================

另一篇关于ca的文章_

.. _另一篇关于ca的文章: http://www.cnblogs.com/zhaojiedi1992/p/zhaojiedi_linux_011_ca.html 

CA服务器的配置
---------------------------------------------------------

.. code-block:: bash

    [root@localhost CA]# cd /etc/pki/CA/

    [root@localhost CA]# sed -r  -i 's@#?countryName_default.*@countryName_default=cn@' /etc/pki/tls/openssl.cnf
    [root@localhost CA]# sed -r  -i 's@#?stateOrProvinceName_default.*@stateOrProvinceName_default=henan@' /etc/pki/tls/openssl.cnf
    [root@localhost CA]# sed -r  -i 's@#?localityName_default.*@localityName_default=zhengzhou@' /etc/pki/tls/openssl.cnf
    [root@localhost CA]# sed -r  -i 's@#?0.organizationName_default.*@0.organizationName_default=linuxpanda@' /etc/pki/tls/openssl.cnf
    [root@localhost CA]# sed -r  -i 's@#?organizationalUnitName_default.*@organizationalUnitName_default=opt@' /etc/pki/tls/openssl.cnf

    # 在CA目录创建一个Makefile
    [root@localhost CA]# wget http://download.linuxpanda.tech/ca/Makefile

    # 先获取make的帮助使用
    [root@localhost CA]# make usage
    This makefile allows you to create:
    make init
    make ca
    make /etc/httpd/ssl/http.key
    make /etc/httpd/ssl/httpd.csr
    make copytoca csr=httpd.csr
    make copytoclient crt=httpd.crt ip=192.168.46.1
    make httpd.csr
    make revoke crt=httpd
    
    # 初始化创建文件
    [root@localhost CA]# make init
    # 创建ca私钥和对应的自签证书
    [root@localhost CA]# make ca
    umask 77 ; \
    /usr/bin/openssl genrsa -out private/cakey.pem 2048 ; \
    /usr/bin/openssl req -utf8 -new -x509 -key private/cakey.pem -out cacert.pem  -days 3650   ; 
    Generating RSA private key, 2048 bit long modulus
    ......................................................+++
    ............+++
    e is 65537 (0x10001)
    You are about to be asked to enter information that will be incorporated
    into your certificate request.
    What you are about to enter is what is called a Distinguished Name or a DN.
    There are quite a few fields but you can leave some blank
    For some fields there will be a default value,
    If you enter '.', the field will be left blank.
    -----
    Country Name (2 letter code) [cn]:
    State or Province Name (full name) [henan]:
    Locality Name (eg, city) [zhengzhou]:
    Organization Name (eg, company) [linuxpanda]:
    Organizational Unit Name (eg, section) [opt]:
    Common Name (eg, your name or your server's hostname) []:ca.linuxpanda.tech
    Email Address []:

客户端的配置
---------------------------------------------------------

这里使用为http配置为例,同样需要那个Makedown文件

.. code-block:: bash

    [root@localhost CA]# wget http://download.linuxpanda.tech/ca/Makefile

    # 先获取make的帮助使用
    [root@localhost CA]# make usage
    This makefile allows you to create:
    make init
    make ca
    make /etc/httpd/ssl/http.key
    make /etc/httpd/ssl/httpd.csr
    make copytoca csr=httpd.csr
    make copytoclient crt=httpd.crt ip=192.168.46.1
    make httpd.csr
    make revoke crt=httpd

    [root@localhost CA]# yum install httpd -y 
    [root@localhost CA]# mkdir /etc/httpd/ssl
    [root@localhost CA]# make /etc/httpd/ssl/httpd.key
    umask 77 ; \
    /usr/bin/openssl genrsa  2048 > /etc/httpd/ssl/httpd.key
    Generating RSA private key, 2048 bit long modulus
    ...........+++
    ...............+++
    e is 65537 (0x10001)
    [root@localhost CA]# make /etc/httpd/ssl/httpd.csr
    umask 77 ; \
    /usr/bin/openssl req -utf8 -new -key /etc/httpd/ssl/httpd.key -out /etc/httpd/ssl/httpd.csr
    You are about to be asked to enter information that will be incorporated
    into your certificate request.
    What you are about to enter is what is called a Distinguished Name or a DN.
    There are quite a few fields but you can leave some blank
    For some fields there will be a default value,
    If you enter '.', the field will be left blank.
    -----
    Country Name (2 letter code) [cn]:
    State or Province Name (full name) [henan]:
    Locality Name (eg, city) [zhengzhou]:
    Organization Name (eg, company) [linuxpanda]:
    Organizational Unit Name (eg, section) [opt]:
    Common Name (eg, your name or your server's hostname) []:www.linuxpanda.tech
    Email Address []:

    Please enter the following 'extra' attributes
    to be sent with your certificate request
    A challenge password []:
    An optional company name []:

    [root@localhost CA]# make copytoca crt=/etc/httpd/ssl/httpd.csr
    scp /etc/httpd/ssl/httpd.csr 192.168.46.129:/etc/pki/CA/csr/
    root@192.168.46.129's password: 
    httpd.csr                                                           100% 1017   319.1KB/s   00:00 

CA颁发证书
------------------------------------------------------------------

.. code-block:: bash

    [root@localhost CA]# make httpd.crt
    /usr/bin/openssl ca -utf8 -days 365 -in csr/httpd.csr -out certs/httpd.crt
    Using configuration from /etc/pki/tls/openssl.cnf
    Check that the request matches the signature
    Signature ok
    Certificate Details:
            Serial Number: 1 (0x1)
            Validity
                Not Before: Feb 13 04:49:57 2018 GMT
                Not After : Feb 13 04:49:57 2019 GMT
            Subject:
                countryName               = cn
                stateOrProvinceName       = henan
                organizationName          = linuxpanda
                organizationalUnitName    = opt
                commonName                = www.linuxpanda.tech
            X509v3 extensions:
                X509v3 Basic Constraints: 
                    CA:FALSE
                Netscape Comment: 
                    OpenSSL Generated Certificate
                X509v3 Subject Key Identifier: 
                    EE:92:FF:A7:15:8F:39:DD:65:AC:B4:F1:59:76:04:32:18:9B:25:8E
                X509v3 Authority Key Identifier: 
                    keyid:B0:9B:0B:62:50:40:E3:00:C6:4D:4F:3E:76:F9:E0:6F:A6:18:20:1C

    Certificate is to be certified until Feb 13 04:49:57 2019 GMT (365 days)
    Sign the certificate? [y/n]:y


    1 out of 1 certificate requests certified, commit? [y/n]y
    Write out database with 1 new entries
    Data Base Updated
    [root@localhost CA]# make copytoclient crt=htttpd.crt ip=192.168.46.2

CA吊销证书
------------------------------------------------------------------

.. code-block:: bash

    [root@localhost CA]# make showcrt crt=certs/httpd.crt 
    /usr/bin/openssl x509  -in certs/httpd.crt -noout -serial -subject  
    serial=01
    subject= /C=cn/ST=henan/O=linuxpanda/OU=opt/CN=www.linuxpanda.tech

    [root@localhost CA]# make revoke crt=certs/httpd.crt
    /usr/bin/openssl ca -revoke certs/httpd.crt ; \
            /usr/bin/openssl ca -gencrl -out crl/ca.crl 
    Using configuration from /etc/pki/tls/openssl.cnf
    Revoking Certificate 01.
    Data Base Updated
    Using configuration from /etc/pki/tls/openssl.cnf
    [root@localhost CA]# make showcrl
    /usr/bin/openssl crl -in crl/ca.crl -noout -text
    Certificate Revocation List (CRL):
            Version 2 (0x1)
        Signature Algorithm: sha256WithRSAEncryption
            Issuer: /C=cn/ST=henan/L=zhengzhou/O=linuxpanda/OU=opt/CN=ca.linuxpanda.tech
            Last Update: Feb 13 04:53:35 2018 GMT
            Next Update: Mar 15 04:53:35 2018 GMT
            CRL extensions:
                X509v3 CRL Number: 
                    1
    Revoked Certificates:
        Serial Number: 01
            Revocation Date: Feb 13 04:53:35 2018 GMT
        Signature Algorithm: sha256WithRSAEncryption
            48:3e:bb:f4:6c:1a:e3:61:5d:c7:68:db:37:2f:97:e4:18:c7:
            dc:40:56:7b:60:13:d7:07:9f:5e:e5:7b:0d:f4:33:fc:5a:a9:
            1d:5f:ee:b9:64:cf:80:bc:a5:0c:fe:e5:ba:9a:f7:cc:1c:54:
            63:53:d9:44:cc:a5:2c:0b:98:b5:c1:4a:2e:ca:27:3c:c9:4e:
            f4:af:8b:7a:13:52:78:e1:84:96:1a:e0:64:4b:6b:a4:f2:c0:
            42:37:f4:23:da:32:04:87:43:aa:97:c7:e9:16:2a:88:df:6a:
            26:45:74:4e:6b:36:d5:6d:d7:13:82:e4:57:8e:31:5d:71:73:
            1a:a9:cb:76:c9:48:b1:ca:6a:b9:00:c2:07:4e:35:5b:18:0b:
            db:e6:0e:df:ef:75:da:ab:58:01:b4:ab:9c:89:85:f5:4c:67:
            2b:61:3e:e3:f0:bd:7d:39:1a:d3:ce:1d:28:55:a1:cb:92:8f:
            73:ed:0e:77:7a:ec:56:97:d4:64:05:c8:05:8f:c8:d8:c5:7c:
            05:24:f8:a4:98:ff:71:48:2d:2d:b3:a5:a2:de:c2:02:62:38:
            a4:88:96:43:84:e2:9b:a4:a5:09:0f:3c:26:57:6b:f5:53:75:
            df:08:c1:8a:ab:a7:26:66:b8:1f:21:26:c8:6c:11:27:10:6e:
            e2:fa:29:7c
