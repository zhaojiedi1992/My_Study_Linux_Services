saltstack
======================================================

部署
------------------------------------------

主机规划
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. csv-table::
   :header: "服务器名称", "操作系统版本", "内网IP","Hostname","部署模块"
   :widths: 15, 10, 30,30,30

   "salt100",	"CentOS7.5",	"172.16.1.100", "salt100",	"salt-master、salt-minion"
   "salt01",	"CentOS7.5",	"172.16.1.11",	 "salt01",	"salt-minion"
   "salt02",	"CentOS7.5",	"172.16.1.12",	 "salt02",	"salt-minion"
   "salt03",	"CentOS7.5",	"172.16.1.13",	 "salt03",	"salt-minion"

同步host文件
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    cat  /etc/hosts
    127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
    ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
    salt100 192.168.89.100
    salt01  192.168.89.201
    salt02  192.168.89.202
    salt03  192.168.89.203

设置管理账户
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    useradd -u 1050 yun && echo "oracle" | passwd --stdin yun 
    echo "yun  ALL=(ALL)       NOPASSWD: ALL" >>  /etc/sudoers

设置主机名
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    hostnamectl  set-hostname master
    hostnamectl  set-hostname salt01
    hostnamectl  set-hostname salt02
    hostnamectl  set-hostname salt03


安装salt
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

管理节点安装 salt-master,salt-minion，普通节点安装salt-minion即可。 

.. code-block:: bash 

    yum install -y salt-master salt-minion 
    yum install -y salt-minion  

    [root@localhost ~]# salt --version 
    salt 2019.2.0 (Fluorine)
    [root@localhost ~]# salt-minion  --version 
    salt-minion 2019.2.0 (Fluorine)

    systemctl start salt-master.service 
    systemctl enable salt-master.service

配置salt-minion
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    vim /etc/salt/minion
    修改 master : salt100 

    systemctl start salt-minion.service  
    systemctl enable salt-minion.service

salt目录结构

.. code-block:: bash 

    [root@master salt]# pwd
    /etc/salt
    [root@master salt]# tree 
    .
    ├── cloud
    ├── cloud.conf.d
    ├── cloud.deploy.d
    ├── cloud.maps.d
    ├── cloud.profiles.d
    ├── cloud.providers.d
    ├── master
    ├── master.d
    ├── minion
    ├── minion.d
    ├── pki
    │   ├── master
    │   │   ├── master.pem
    │   │   ├── master.pub
    │   │   ├── minions
    │   │   ├── minions_autosign
    │   │   ├── minions_denied
    │   │   ├── minions_pre
    │   │   └── minions_rejected
    │   └── minion
    ├── proxy
    ├── proxy.d
    └── roster

    16 directories, 7 files

    [root@master salt]# salt-key 
        Accepted Keys:
        Denied Keys:
        Unaccepted Keys:
        salt01
        salt02
        salt03
        Rejected Keys:

    # 发现3个节点都是在待确认的key中， 接收下。

    # 接收
    [root@master salt]#  salt-key -a salt0*
    The following keys are going to be accepted:
    Unaccepted Keys:
    salt01
    salt02
    salt03
    Proceed? [n/Y] y
    Key for minion salt01 accepted.
    Key for minion salt02 accepted.
    Key for minion salt03 accepted.

    # -A 接收所有  -a  可以统配接收，可以指定单个

测试部署
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    [root@salt100 salt]# salt '*' test.ping 
    salt01:
        True
    master:
        True
    salt02:
        True
    salt03:
        True

远程执行
------------------------------------------
    
.. code-block:: bash 

    salt '*' cmd.run 'w'
    salt '*' cmd.run 'mkdir /tmp/aa && ls -l /tmp/aa'

配置管理
------------------------------------------

配置修改
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

salt master的配置文件在 /etc/salt/master 

.. code-block:: bash 

    vim /etc/salt/master 
    # 取消如下注释行
    file_roots:
    base:
        - /srv/salt

    systemctl restart salt-master 
    mkdir /srv/salt 

安装httpd
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    cd /srv/salt/ && mkdir web 
    vim apache.sls
    [root@salt100 salt]# cat apache.sls 
        apache-install:
        pkg.installed: 
            - names: 
            - httpd
            - httpd-devel
            - httpd-tools
        apache-enable:
        service.running:
            - name: httpd
            - enable: True

    [root@salt100 web]# salt 'salt01' state.sls web.apache
    其中 salt01 表示应用的主机
    state.sls 表示使用的state模块的sls方式， 
    web.apache 表示使用的/srv/base/web/apache.sls文件

编写top.sls文件   
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    [root@salt100 salt]# cat top.sls 
    base: 
    'salt0*':
        - web.apache
    'salt03':
        - web.apache

    salt 'salt01' state.highstate test=True    

数据系统
------------------------------------------

grains文档 https://docs.saltstack.com/en/latest/topics/grains/index.html

grains 优先级
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. salt系统自带信息  【优先级最低】
2. 自编写Python脚本  备注：在指定目录下存放py脚本
3. /etc/salt/grains  备注：该文件不存在，需要自己创建
4. /etc/salt/minion  【优先级最高】

查看grains 

.. code-block:: bash 

    salt 'salt01' grains.ls
    salt 'salt01' grains.items
    salt 'salt01' grains.item os


编写py定义grains 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^



在/etc/salt/grains 中定义grains
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block::

    在salt01节点修改文件/etc/salt/grains
    [root@salt01 minion]# cat /etc/salt/grains 
    roles:
    - webserver02
    - memcache02
    os: redhat02
    [root@salt100 salt]# salt '*' saltutil.sync_grains
    salt03:
    salt02:
    salt01:
    master:
    [root@salt100 salt]# salt '*' grains.item roles   
    master:
        ----------
        roles:
    salt03:
        ----------
        roles:
    salt01:
        ----------
        roles:
            - webserver02
            - memcache02
    salt02:
        ----------
        roles:

在/etc/salt/minion 中定义grains
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
这个不建议使用， 定义和配置写在一起，不合适，不利于后期的管理维护。



通过grains 过滤查询

.. code-block:: bash 

    salt -G 'os:centos' cmd.run 'uptime'

数据系统-Pillar
---------------------------------------------

pillar文档 https://docs.saltstack.com/en/latest/topics/pillar/index.html

grains 是静态的的， pillar是动态的，

Pillar刷新 salt '*' saltutil.refresh_pillar  

显示默认的pillar
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    vim /etc/salt/master
    取消注释行
    pillar_opts: True
    systemctl restart salt-master 

pillar文件存放位置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    vim /etc/salt/master
    取消注释行
    pillar_roots:
    base:
        - /srv/pillar
    systemctl restart salt-master 


通过pillar查询信息
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    salt -I 'role:production' cmd.run 'w' 


远程执行-指定目标
-----------------------------

salt 指定目标的方式有很多种。 

名字方式： 
    salt 'salt01' 这种是指定minion的名字方式
统配方式： 
    salt 'salt0*' 这种是统配方式
正则表达式方式： 
    salt -E 'web1-(prod|devel)' test.ping 
列表匹配： 
    salt -L 'web1,web2,web3' test.ping 
使用grains指定:
    salt -G  'os:centos' test.ping 
使用pillar执行
    salt  -I 'somekey:specialvalue' test.ping
使用组
    salt -N group1 test.ping 

远程执行-模块
-----------------------------

模块的官方文档： https://docs.saltstack.com/en/latest/ref/modules/all/index.html#all-salt-modules	

模块位置： 

.. code-block:: bash 

    [root@salt100 salt]# cd /usr/lib/python2.7/site-packages/salt/modules
    [root@salt100 modules]# ll network.py
    -rw-r--r-- 1 root root 57562 Feb 16 01:14 network.py

模块说明
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

salt内置好多模块， 列出所有的模块： salt '*' sys.doc 

执行shell   salt '*' cmd.run 'ps aux ' 


cp模块

.. code-block:: bash 

    salt -L 'salt01,salt02' cp.get_file salt://a.txt /tmp/a.txt 
    salt-cp  -L 'salt01,salt02' /etc/hosts /tmp/kkk 


远程执行-返回程序
-----------------------------

参考： https://blog.csdn.net/woshizhangliang999/article/details/89349246
returner文档： https://docs.saltstack.com/en/latest/ref/returners/all/index.html#all-salt-returners

获取返回值： `salt '*' test.ping --return mysql`  


自编写module
-----------------------------

自编写module需要放置在/srv/salt/_modules位置上， 文件名字就是模块名字，刷新模块是用 salt '*' saltutil.sync_modules 

.. code-block:: bash 

    mkdir _modules 
    cd _modules/
    vim my_disk.py
    cat my_disk.py
    #!/usr/bin/env python
    # -*- coding:utf-8 -*-
    def list():
    cmd = 'df -h'
    ret = __salt__['cmd.run'](cmd)
    return ret

    # 同步到minion上
    salt '*' saltutil.sync_modules
    # 执行自定义的模块方法
    salt '*' my_disk.list 


状态文件
------------------------------------------------

常用状态模块有states.pkg , states.file , states.service 。 

通过状态文件搭建一个集群版本的lamp环境。
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

主机规划

.. csv-table::
   :header: "服务器名称", "操作系统版本", "内网IP","Hostname","部署模块"
   :widths: 15, 10, 30,30,30

   "salt100",	"CentOS7.5",	"172.16.1.100", "salt100",	"mariadb"
   "salt01",	"CentOS7.5",	"172.16.1.11",	 "salt01",	"httpd,php"
   "salt02",	"CentOS7.5",	"172.16.1.12",	 "salt02",	"httpd,php"
   "salt03",	"CentOS7.5",	"172.16.1.13",	 "salt03",	"httpd,php"

构思

- 软件包： 使用states.pkg 
- 配置文件： 使用states.file 
- 启动服务： 使用states.service 


lamp 系统 对于mariab来说只需要一个， 我们规划在salt100服务器上面， 就需要单独写一个sls文件。 
对于php和httpd环境， 我们需要在三个节点服务器都部署， 编写一个apache_and_php的。

.. code-block:: bash 

    [root@salt100 lamp]# tree 
    .
    ├── apache_and_php.sls
    ├── file
    │   ├── httpd.conf
    │   ├── my.cnf
    │   └── php.ini
    └── mariadb.sls

    [root@salt100 lamp]# cat apache_and_php.sls 
    install-mariadb: 
    pkg.installed: 
    - name: mariadb

    install-apache: 
    pkg.installed: 
    - name: httpd

    install-php:
    pkg.installed: 
    - name: php
    - name: php-devel
    - name: php-mysql
    - name: php-cli
    - name: php-mbstring

    config-apache:
    file.managed: 
    - name: /etc/httpd/conf/httpd.conf
        source: salt://lamp/file/httpd.conf
        user: root
        group: root
        mode: 644 
        backup: minion

    config-php:
    file.managed: 
    - name: /etc/php.ini
        source: salt://lamp/file/php.ini
        user: root
        group: root
        mode: 644 
        backup: minion

    start-apache:
    service.running:
    - name: httpd
        enalbe: True 
        reload: True
        watch: 
        - file : config-apache

    [root@salt100 lamp]# cat mariadb.sls 
    install-mariadb:
    pkg.installed: 
    - name: mariadb 
    - name: mariadb-server
    - name: mariadb-devel
    config-mariadb: 
    file.managed: 
    - name: /etc/my.cnf
        source: salt://lamp/file/my.cnf
        user: root 
        group: root 
        mode: 644
        backup: minion
    start-mariadb:
    service.running: 
    - name: mariadb.service
        enable: True
        restart: True
        watch: 
        - file: config-mariadb


    salt 'master' state.sls lamp.mariadb test=True 
    salt 'master' state.sls lamp.mariadb 
    salt 'salt03' state.sls lamp.apache_and_php test=True
    salt 'salt03' state.sls lamp.apache_and_php


状态依赖
---------------------------------------

- 我依赖谁   require 
- 谁依赖我   require_in 
- 我监控谁   watch 
- 谁监控我   watch_in 
- 我引用谁   include 
- 我扩展谁   extend

salt jinja 
----------------------------------------------

salt的jinja 参考： https://docs.saltstack.com/en/latest/topics/jinja/index.html

jinja在状态中的使用方式， 在file模块使用指定template为jinja 表示使用jinja作为模板， 在sls文件种需要设置一些变量， 在模板中需要引用这些变量。 

做如下修改

.. code-block:: bash 


    # 模块配置
    vim file/httpd.conf  
    # 修改为如下内容 
    Listen {{ listen_port }}

    # sls文件配置
    # 添加如下2行在file模块里面
        - template: jinja
        - defaults:
            listen_port: 81


salt run 
--------------------------------------------

查看job相关的

.. code-block:: bash 
 
    # 返回正在活动中的jobs信息
    salt-run jobs.active
    # 返回素有可检测的jobs和活动信息
    salt-run jobs.list_jobs	
    # 根据jid列出指定的job
    salt-run jobs.list_job 20190111160734604439	
    # 返回以前执行job的打印输出
    salt-run jobs.lookup_jid 20190111170928354082


查看manage相关的

.. code-block:: bash 

    salt-run manage.list_state
    salt-run manage.alived 
    salt-run manage.status
    salt-run manage.down
    salt-run manage.up
    salt-run manage.versions

saltutil模块

.. code-block:: bash 

    # 返回minion正在执行salt进程的数据
    salt '*' saltutil.running
    # 杀死指定jid进程
    salt '*' saltutil.kill_job 20190111180228662382

无master 
----------------------------------------------

当salt处于无master模式的时候，不要运行salt-minionde 守护进程，否认salt-minion将尝试去连接master并失败， slat-call命令独立存储，不需要slat-minion守护进程。 

.. code-block:: bash 

    #  安装master端
    yum install -y salt-master 

    # 拷贝的秘钥
    scp /etc/salt/pki/master/{master.pem,master.pub} root@salt01:/etc/salt/pki/master/
    # 拷贝主master的配置
    scp /etc/salt/master root@salt01:/etc/salt/master
    # 拷贝主master的目录
    scp -r /srv root@salt01:/srv

    # 开机自启
    systemctl enable salt-master.service
    systemctl start salt-master.service

    # 配置minion端（所有都操作）

    vim /etc/salt/minion
    master:
    - salt100
    - salt01
    systemctl restart salt-minion.service 

    # 在salt01上面接收所有的key文件
    salt-key  -A  

    # 在salt01尝试下
    salt '*' test.ping 
    salt03:
        True
    salt02:
        True
    salt01:
        True
    master:
        True


salt-syndic
-------------------------------------

salt-syncdic 文档： https://docs.saltstack.com/en/latest/topics/topology/syndic.html

Syndic 节点可以看作是一个特殊的直通minion节点， syndic节点是由salt-syndic和salt-master组成，其中salt-master用于控制更低级的minion节点， salt-syndic用户去连接更高级的master节点。


salt-ssh 
-----------------------------------------

salt-ssh 文档： https://docs.saltstack.com/en/latest/topics/ssh/index.html

.. code-block:: bash 

    yum install -y salt-ssh	

    在master节点的创建一个ssh默认的配置文件

    [root@salt100 lamp]# cat  /etc/salt/master.d/roster    
    # 创建一个默认的ssh配置文件， 指定sudo用户名和密码。
    roster_defaults:
    user: yun
    sudo: True
    passwd: oracle
    tty: True

    [root@salt100 lamp]# cat /etc/salt/roster 
    salt01: 
    host: salt01

    # 测试salt-ssh
    [root@salt100 lamp]# salt-ssh  '*' cmd.run 'w'
    salt01:
        07:16:38 up 1 day,  5:25,  2 users,  load average: 0.01, 0.03, 0.05
        USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
        root     tty1                      Wed01   29:23m  0.02s  0.02s -bash
        root     pts/0    192.168.88.214   02:11   31:34   0.01s  0.01s -bash

    # 使用raw shell
    [root@salt100 lamp]# salt-ssh  '*' -r  'echo $PATH'
    salt01:
        ----------
        retcode:
            0
        stderr:
        stdout:
            /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin


salt api
--------------------------------------------------------------------

.. code-block:: bash 

    # 安装python3.7 

    wget https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tar.xz
    tar xf Python-3.7.3.tar.xz
    cd Python-3.7.3
    yum install gcc
    ./configure --prefix=/usr/local/python37
    make && make install 
    vim /etc/profile.d/python.sh
    cat /etc/profile.d/python.sh
    PATH=/usr/local/python37/bin:$PATH
    source /etc/profile.d/python.sh 
    which python3 

    # 安装salt api 
    yum install -y salt-api
    systemctl enable salt-api.service

    # 添加用户
    useradd -M -s /sbin/nologin -u 1010 saltapi && echo 'oracle' | passwd --stdin saltapi
    # 安装cherrypy
    pip3 install CherryPy==3.2.6 -i http://pypi.doubanio.com/simple/ --trusted-host pypi.doubanio.com

    # 添加证书
    [root@salt100 certs]# make testcert 
    umask 77 ; \
    /usr/bin/openssl genrsa -aes128 2048 > /etc/pki/tls/private/localhost.key
    Generating RSA private key, 2048 bit long modulus
    ..................................+++
    .......................................+++
    e is 65537 (0x10001)
    Enter pass phrase:
    139859159766928:error:28069065:lib(40):UI_set_result:result too small:ui_lib.c:831:You must type in 4 to 1023 characters
    Enter pass phrase:
    139859159766928:error:28069065:lib(40):UI_set_result:result too small:ui_lib.c:831:You must type in 4 to 1023 characters
    Enter pass phrase:
    139859159766928:error:28069065:lib(40):UI_set_result:result too small:ui_lib.c:831:You must type in 4 to 1023 characters
    Enter pass phrase:
    Verifying - Enter pass phrase:
    umask 77 ; \
    /usr/bin/openssl req -utf8 -new -key /etc/pki/tls/private/localhost.key -x509 -days 365 -out /etc/pki/tls/certs/localhost.crt 
    Enter pass phrase for /etc/pki/tls/private/localhost.key:
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
    Organization Name (eg, company) [Default Company Ltd]:limikeji.com
    Organizational Unit Name (eg, section) []:opt
    Common Name (eg, your name or your server's hostname) []:www
    Email Address []:

    [root@salt100 certs]# ll ../private/localhost.key  localhost.crt 
    -rw------- 1 root root 1310 Jun 13 10:04 localhost.crt
    -rw------- 1 root root 1766 Jun 13 10:04 ../private/localhost.key

    # 去掉密码
    [root@salt100 certs]# openssl  rsa -in ../private/localhost.key  -out ../private/localhost_nopass.key
    Enter pass phrase for ../private/localhost.key:
    writing RSA key
    [root@salt100 certs]# mv ../private/localhost_nopass.key ../private/localhost.key
    mv: overwrite ‘../private/localhost.key’? y

    # 给master配置
    [root@salt100 master.d]# cat eauth.conf 
    external_auth:
    pam:
        saltapi:
        - .*
        - '@wheel'   # to allow access to all wheel modules
        - '@runner'  # to allow access to all runner modules
        - '@jobs'    # to allow access to the jobs runner and/or wheel module
    [root@salt100 master.d]# cat api.conf 
    rest_cherrypy:
    port: 8000
    ssl_crt: /etc/pki/tls/certs/localhost.crt
    ssl_key: /etc/pki/tls/private/localhost.key


    # 重启master, 启动salt-api 
    systemctl restart salt-master.service
    systemctl start salt-api.service
    netstat -tunlp |grep salt-api  
    tcp        0      0 0.0.0.0:8000            0.0.0.0:*               LISTEN      130229/salt-api   

    # 进行测试
    [root@salt100 master.d]# curl -k https://salt100:8000/login  -H 'Accept: application/x-yaml'  -d username='saltapi'  -d password='oracle'  -d eauth='pam'            
    return:
    - eauth: pam
    expire: 1560478341.170163
    perms:
    - .*
    - '@wheel'
    - '@runner'
    - '@jobs'
    start: 1560435141.170162
    token: 9650ce783f8b04e15b8f2042d83c2de532c0bf4e
    user: saltapi

    yum install jq 
    curl -k https://salt100:8000/minions/salt01 -H 'Accept: application/json' -H 'X-Auth-Token: 9650ce783f8b04e15b8f2042d83c2de532c0bf4e' |jq 













