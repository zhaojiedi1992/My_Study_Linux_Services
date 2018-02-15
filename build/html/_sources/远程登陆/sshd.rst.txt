sshd
=========================================

sshd服务简介
------------------------------------------

sshd的安装
--------------------------------------------

.. code-block:: bash

    [root@localhost ssh]# rpm -q openssh-server 
    openssh-server-7.4p1-11.el7.x86_64
    [root@localhost ssh]# yum install openssh-server
    [root@localhost ssh]# rpm -qc openssh-server 
    /etc/pam.d/sshd                 # pam 相关的
    /etc/ssh/sshd_config            # sshd的配置文件
    /etc/sysconfig/sshd             # sshd配置文件的参数文件

.. note:: 默认情况下大部分linux机器都会安装这个软件来提供sshd功能的。

sshd的主要配置
-----------------------------------------------

配置比较多， 这里只列出重要配置

.. csv-table:: 
   :header: "参数","默认值","描述"
   :widths: 30,50,50

    "Port","22","指定监听端口，这个配置可以写多行，用于监听多个端口"
    "Protocol","2","ssh协议的版本，可以修改2,1来支持1和2两个版本"
    "ListenAddress","0.0.0.0","指定简单的ip地址，默认是主机上所有的ip地址"
    "PidFile","/var/run/sshd.pid","pid文件"
    "LoginGraceTime","2m","输入密码阶段，多少时间没有输入就终端的时间"
    "Compression","delayed","指定合适开始使用压缩数据模式进行传输"
    "HostKey","/etc/ssh/ssh_host_key","ssh v1的私钥"
    "HostKey","/etc/ssh/ssh_host_rsa_key","ssh v2 rsa的私钥"
    "HostKey","/etc/ssh/ssh_host_dsa_key","ssh v2 dsa的私钥"
    "SyslogFacility","AuthPRIV","日志记录的设施，可以修改为LOCAL1-6,"
    "LogLevel","INFO","日志级别"
    "PermitRootLogin","yes","是否运行root登陆"
    "StrictMode","yes","如果用户家目录的.ssh目录权限不对，可能无法登陆"
    "Pubkeyauthentication","yes","支持公钥认证"
    "AuthorizedKeysFile",".ssh/autorized_keys","授权的keys"
    "PasswordAuthentication","yes","支持密码认证"
    "PermitEmptyPasswords","no","空密码支持"
    "RhostaAuthtication","no","不使用.rhosts认证"
    "IgnoreRhosts","yes","是否取消.rhosts认证"
    "RhostsRSAAUthentication","no","配合rsa使用的，这个不用了"
    "HostbaseAuthentication","no","配合rsa使用，这个参数不用了"
    "IgnoreUserKnowHosts","no","是否忽略用户的家目录的know_hosts文件"
    "CallengeResponseAuthentication","no","是否login.conf规定的认证都可以，建议no,"
    "UsePam","yes","使用pam认证"
    "PrintMotd","yes","登陆成功后是否有提示信息，默认是打印/etc/motd文件"
    "PrintLastLog","yes","打印上一次登陆信息"
    "TCPKeepAlive","yes","发送tcp包连接判断"
    "UserPrivilegeSeparation","yes","是否使用较低的权限用户来启动sshd"
    "MaxStartups","10","同时运行的尚未登陆的连接界面个数"
    "DenyUses","\-","限制特定用户，\*代表所有用户，含root"
    "DenyGroup","\-","限制特定的组"
    "UserDns","yes","dns反差客户端的主机名，内网设置no连接更快"

免密码登陆
---------------------------------------------

.. note::  你想用那个机器A的用户A远程到机器B的用户B,只需要copy机器A的用户A的公钥追加到机器B的
            用户B的.ssh/autorized_keys文件中去。

详细的免密码登陆_

.. _详细的免密码登陆: http://www.cnblogs.com/zhaojiedi1992/p/zhaojiedi_linux_023_sshgenkey.html


样例： 

.. code-block:: bash

    [root@node1 ~]# ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa         #生成rsa
    [root@node1 ~]# ssh-copy-id -i  ~/.ssh/id_rsa.pub root@192.168.168.202  #复制201的公钥到202机器上，这样就可以使用在201机器上免密码登录202机器了(root用户)。
