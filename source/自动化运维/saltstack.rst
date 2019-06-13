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

获取返回值： salt '*' test.ping --return mysql  


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















































