pssh
====================================================

pssh简介
----------------------------------------------------------

pssh命令是一个python编写可以在多台服务器上执行命令的工具，同时支持拷贝文件，
使用必须在各个服务器上配置好密钥认证访问。

pssh的安装
----------------------------------------------------------
.. code-block:: bash

    [root@7 ~]# yum install pssh
    [root@7 ~]# rpm -ql pssh |grep bin
    /usr/bin/pnuke                      # 并行在远程主机杀进程
    /usr/bin/prsync                     # 使用rsync协议从本地同步数据
    /usr/bin/pscp.pssh                  # 本地文件复制到多个主机上
    /usr/bin/pslurp                     # 把多个远程主机的问题拉到本机
    /usr/bin/pssh                       # 多主机并行运行命令

准备工作
---------------------------------------------------------------

主机信任
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

我这里测试有3个机器，ip分别是192.168.46.7，192.168.46.101，192.168.46.102,
我想在7的机器上可以控制这三个机器，包括自己的机器。

.. code-block:: bash

    [root@7 ~]# ssh-keygen                   # 这个命令在3个主机上面都执行一次
    [root@7 ~]# ssh-copy-id  -i /root/.ssh/id_rsa.pub 192.168.46.7   # 添加信任，可以免密码到7
    [root@7 ~]# ssh-copy-id  -i /root/.ssh/id_rsa.pub 192.168.46.101 # 添加信任，可以免密码到101
    [root@7 ~]# ssh-copy-id  -i /root/.ssh/id_rsa.pub 192.168.46.102 # 添加信任，可以免密码到102

新建主机配置文件

.. code-block:: bash

    [root@7 ~]# echo 192.168.46.7 >>/root/hosts.txt
    [root@7 ~]# echo 192.168.46.101 >>/root/hosts.txt
    [root@7 ~]# echo 192.168.46.102 >>/root/hosts.txt
    [root@7 ~]# cat /root/hosts.txt 
    192.168.46.7
    192.168.46.101
    192.168.46.102

命令的使用
----------------------------------------------------

pssh  
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

命令使用：

.. code-block:: bash

    [root@7 ~]# pssh --help
    Usage: pssh [OPTIONS] command [...]

    Options:
    --version                                       # 显示程序版本并退出
    --help                                          # 获取帮助信息
    -h HOST_FILE, --hosts=HOST_FILE                 # 主机文件，每行是"[user@]host[:port]"，如果有主机互信，只要ip即可。
    -H HOST_STRING, --host=HOST_STRING              # 主机字符串
    -l USER, --user=USER  username (OPTIONAL)       # 指定用户
    -p PAR, --par=PAR                               # 最大并行度
    -o OUTDIR, --outdir=OUTDIR                      # 标准输出目录
    -e ERRDIR, --errdir=ERRDIR                      # 错误输出目录
    -t TIMEOUT, --timeout=TIMEOUT                   # 超时时间
    -O OPTION, --option=OPTION                      # ssh选项
    -v, --verbose                                   # 信息详细
    -A, --askpass                                   # 询问密码，如果没有配置主机信任，这个就需要指定
    -i,--inline                                     # 每个服务器内部处理信息输出

    样例使用: pssh -h hosts.txt -l irb2 -o /tmp/foo uptime

.. code-block:: bash

    # -H ,-i使用
    [root@7 ~]# pssh -H "192.168.46.101" -i ls              # 
    [1] 22:30:42 [SUCCESS] 192.168.46.101
    anaconda-ks.cfg
    backup.tar.bz2
    findresults
    foo.sh
    kernel-3.10.0-693.11.1.el7.x86_64.rpm
    mkusers
    userlist
    # -h，-O使用
    [root@7 ~]# mkdir pssh
    [root@7 ~]# pssh -h /root/hosts.txt -o /root/pssh/  'uptime' 
    [1] 22:36:04 [SUCCESS] 192.168.46.101
    [2] 22:36:04 [SUCCESS] 192.168.46.7
    [3] 22:36:14 [SUCCESS] 192.168.46.102
    [root@7 ~]# tree /root/pssh/
    /root/pssh/
    ├── 192.168.46.101
    ├── 192.168.46.102
    └── 192.168.46.7
    [root@7 ~]# cat /root/pssh/192.168.46.101 
    09:36:04 up 14:29,  2 users,  load average: 0.05, 0.04, 0.05

pscp.pssh
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

命令使用

.. code-block:: bash

    [root@7 ~]# pscp.pssh  --help
    Usage: pscp.pssh [OPTIONS] local remote

样例： 

.. code-block:: bash

    [root@7 ~]# pscp.pssh  -h /root/hosts.txt file1 /root    # 文件复制到远程

pslurp
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
命令使用

.. code-block:: bash

    [root@7 ~]# pslurp --help
    Usage: pslurp [OPTIONS] remote local

样例： 

.. code-block:: bash

    [root@7 ~]# pslurp -h /root/hosts.txt  /var/log/messages .       # 复制远程的日志文件到当前目录
    [1] 22:46:36 [SUCCESS] 192.168.46.101
    [2] 22:46:36 [FAILURE] 192.168.46.7 Exited with error code 1
    [3] 22:46:46 [SUCCESS] 192.168.46.102
    [root@7 ~]# tree 192.168.46.*                                   # 查看下
    192.168.46.101
    └── messages
    192.168.46.102
    └── messages
    192.168.46.7 [error opening dir]

0 directories, 2 files

prsync 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

命令使用

.. code-block:: bash

    [root@7 ~]# prsync --help
    Usage: prsync [OPTIONS] local remote

样例： 

.. code-block:: bash

    [root@7 ~]# pssh -h /root/hosts.txt  -P 'mkdir /tmp/etc'                 # 远程创建目录
    [1] 22:51:08 [SUCCESS] 192.168.46.101
    [2] 22:51:08 [SUCCESS] 192.168.46.7
    [3] 22:51:18 [SUCCESS] 192.168.46.102
    [root@7 ~]# prsync -h /root/hosts.txt  -a -r  /etc/sysconfig /tmp/etc   # 推送过去
    [1] 22:51:57 [FAILURE] 192.168.46.101 Exited with error code 127
    [2] 22:51:57 [SUCCESS] 192.168.46.7
    [3] 22:52:07 [SUCCESS] 192.168.46.102

pnuke
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

命令使用

.. code-block:: bash

    [root@7 ~]# pnuke --help
    Usage: pnuke [OPTIONS] pattern

样例： 

.. code-block:: bash

    [root@7 ~]# pnuke -h /root/hosts.txt  httpd                     # 关闭所有httpd进程
    [1] 22:48:26 [FAILURE] 192.168.46.7 Exited with error code 1
    [2] 22:48:26 [SUCCESS] 192.168.46.101
    [3] 22:48:36 [FAILURE] 192.168.46.102 Exited with error code 1
