dropbear
==============================================
dropbear是一款基于ssh协议的轻量sshd服务器，与OpenSSH相比，他更简洁，
更小巧，运行起来占用的内存也更少。每一个普通用户登录，OpenSSH会开两个sshd进程，
而dropbear只开一个进程，所以其对硬件要求更低，也更利于系统的运行。Dropbear特别用于
“嵌入”式的Linux（或其他Unix）系统 。

编译环境安装
----------------------------------------------------------

.. code-block:: bash

    [root@localhost ~]# yum groupinstall "development tools"
    [root@localhost ~]# yum install bzip2 zlib-devel

下载并解压
--------------------------------------------------

.. code-block:: bash

    [root@localhost src]# cd /usr/src
    [root@localhost src]# wget http://matt.ucc.asn.au/dropbear/releases/dropbear-2017.75.tar.bz2
    [root@localhost src]# tar xf dropbear-2017.75.tar.bz2


编译
-----------------------------------------------

.. code-block:: bash

    [root@localhost src]# cd dropbear-2017.75/
    [root@localhost dropbear-2017.75]#  ./configure  --prefix=/usr/local/dropbear
    [root@localhost dropbear-2017.75]#  vim INSTALL
    [root@localhost dropbear-2017.75]#  make PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp"
    [root@localhost dropbear-2017.75]#  vim INSTALL
    [root@localhost dropbear-2017.75]#  make PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp" install

make过程中有几个警告，可以忽略。

创建配置文件
-----------------------------------------------

.. code-block:: bash

    [root@localhost dropbear]# cd /usr/local/dropbear/
    [root@localhost dropbear]# tree
    .
    ├── bin
    │   ├── dbclient
    │   ├── dropbearconvert
    │   ├── dropbearkey
    │   └── scp
    ├── sbin
    │   └── dropbear
    └── share
        └── man
            ├── man1
            │   ├── dbclient.1
            │   ├── dropbearconvert.1
            │   └── dropbearkey.1
            └── man8
                └── dropbear.8

    6 directories, 9 files

    [root@localhost dropbear]# echo 'PATH=/usr/local/dropbear/bin:/usr/local/dropbear/sbin:$PATH' > /etc/profile.d/dropbear.sh
    [root@localhost dropbear]# source /etc/profile.d/dropbear.sh
    [root@localhost dropbear]# mkdir /etc/dropbear

    [root@localhost dropbear]# dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key
    [root@localhost dropbear]# dropbearkey -t dss -f /etc/dropbear/dropbear_dss_host_key
    [root@localhost dropbear]# dropbearkey -t ecdsa -f /etc/dropbear/dropbear_ecdsa_host_key

启动dropbear在指定端口
-----------------------------------------------

.. code-block:: bash

    [root@localhost profile.d]# dropbear -p 20022  -FE

.. note:: 我本机安装有openssh,sshd监听在22号端口，所以这个地方换了一个端口。

测试
-----------------------------------------------

.. code-block:: bash

    [root@localhost bin]# dbclient  -p 20022 root@192.168.46.129

    Host '192.168.46.129' is not in the trusted hosts file.
    (ecdsa-sha2-nistp521 fingerprint md5 5e:96:6e:26:f5:30:22:e7:36:33:57:c6:a3:8f:3a:cd)
    Do you want to continue connecting? (y/n) y
    root@192.168.46.129's password: 
    [root@localhost ~]# 

.. note:: 我测试使用的dropbear提供的dbclient，当然使用ssh命令也是可以的。


写一个sysv脚本
-----------------------------------------------

.. code-block:: bash

    #!/bin/bash
    #
    # description: dropbear ssh daemon
    # chkconfig: 2345 66 33
    #
    dsskey=/etc/dropbear/dropbear_dss_host_key
    rsakey=/etc/dropbear/dropbear_rsa_host_key
    lockfile=/var/lock/subsys/dropbear
    pidfile=/var/run/dropbear.pid
    dropbear=/usr/local/dropbear/sbin/dropbear
    dropbearkey=/usr/local/dropbear/bin/dropbearkey
    [ -r /etc/rc.d/init.d/functions ] && . /etc/rc.d/init.d/functions
    [ -r /etc/sysconfig/dropbear ] && . /etc/sysconfig/dropbear
    keysize=${keysize:-1024}
    port=${port:-20022}
    gendsskey() {
        [ -d /etc/dropbear ] || mkdir /etc/dropbear
        echo -n "Starting generate the dss key: "
        $dropbearkey -t dss -f $dsskey &> /dev/null
        RETVAL=$?
    if [ $RETVAL -eq 0 ]; then
                        success
                        echo
                        return 0
    else
                        failure
                        echo
                        return 1
    fi
        }
    genrsakey() {
        [ -d /etc/dropbear ] || mkdir /etc/dropbear
        echo -n "Starting generate the rsa key: "
        $dropbearkey -t rsa -s $keysize -f $rsakey &> /dev/null
        RETVAL=$?
    if [ $RETVAL -eq 0 ]; then
        success
        echo
        return 0
    else
        failure
        echo
        return 1
    fi
    }
    start() {
        [ -e $dsskey ] || gendsskey
        [ -e $rsakey ] || genrsakey
        if [ -e $lockfile ]; then
            echo -n "dropbear daemon is already running: "
            success
            echo
        exit 0
    fi
        echo -n "Starting dropbear: "
        daemon --pidfile="$pidfile" $dropbear -p $port -d $dsskey -r $rsakey
        RETVAL=$?
        echo
    if [ $RETVAL -eq 0 ]; then
        touch $lockfile
        return 0
    else
        rm -f $lockfile $pidfile
        return 1
    fi
    }
    stop() {
        if [ ! -e $lockfile ]; then
            echo -n "dropbear service is stopped: "
            success
            echo
            exit 1
        fi
            echo -n "Stopping dropbear daemon: "
            killproc dropbear
            RETVAL=$?
            echo
                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
        if [ $RETVAL -eq 0 ]; then
            rm -f $lockfile $pidfile
            return 0
        else
            return 1
    fi
    }
    status() {
        if [ -e $lockfile ]; then
            echo "dropbear is running..."
        else
            echo "dropbear is stopped..."
        fi
    }
    usage() {
        echo "Usage: dropbear {start|stop|restart|status|gendsskey|genrsakey}"
    }
    case $1 in
    start)
        start ;;
    stop)
        stop ;;
    restart)
        stop
        start
        ;;
    status)
        status
        ;;
    gendsskey)
        gendsskey
        ;;
    genrsakey)
        genrsakey
        ;;
    *)
        usage
        ;;
    esac

这个脚本来自 小马子不怕鬼_ , 写的比我自己那个更全面，就借用下。

.. _小马子不怕鬼 : http://blog.chinaunix.net/xmlrpc.php?r=blog/article&uid=29584738&id=4234090


:download:`/files/dropbear`