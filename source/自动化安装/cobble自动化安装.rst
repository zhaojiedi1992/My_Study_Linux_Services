.. _topics-cobble:

cobble自动化安装
======================================================

前面2个实验 :ref:`topics-cdrom` 和 :ref:`topics-pxe` 的自动化安装， 不过还是比较麻烦的，
这里使用cobble来自动化安装。

下面的操作在centos7上操作


安装前准备
------------------------------------------------------------------------------------

关闭防火墙和selinux

.. code-block:: bash

    [root@localhost ~]# systemctl stop firewalld 
    [root@localhost ~]# systemctl disable firewalld
    [root@localhost ~]# getenforce
    Enforcing
    [root@localhost ~]# setenforce 0
    [root@localhost ~]# sed -i 's@SELINUX=enforcing@SELINUX=disabled@' /etc/sysconfig/selinux 

配置一个静态ip，我们需要为别的客户机器分发ip的，必须保证自己的ip是静态的。

安装软件包
-----------------------------------------------------------

.. code-block:: bash

    [root@localhost yum.repos.d]# yum install cobbler-web cobbler dhcp -y

    [root@localhost yum.repos.d]# systemctl start cobblerd
    [root@localhost yum.repos.d]# systemctl enable cobblerd
    Created symlink from /etc/systemd/system/multi-user.target.wants/cobblerd.service to /usr/lib/systemd/system/cobblerd.service.
    [root@localhost yum.repos.d]# systemctl start httpd
    [root@localhost yum.repos.d]# systemctl enable httpd
    Created symlink from /etc/systemd/system/multi-user.target.wants/httpd.service to /usr/lib/systemd/system/httpd.service.

.. warning:: centos6系统安装cobbler-web会无法访问的，依赖一些包的。

cobbler目录介绍
-------------------------------------------------------------------

一些cobbler重要目录： 

.. code-block:: text

    /etc/cobbler/dhcp.template                      # dhcp模板文件
    /etc/cobbler/iso                                # iso模板配置文件
    /etc/cobbler/iso/buildiso.template              # 构建iso模板
    /etc/cobbler/modules.conf                       # 模块配置文件
    /etc/cobbler/named.template                     # dns配置文件
    /etc/cobbler/power                              # 电源相关配置
    /etc/cobbler/pxe                                # pxe模板文件
    /etc/cobbler/settings                           # 主配置文件
    /etc/cobbler/tftpd.template                     # tfp配置模板
    /etc/cobbler/users.conf                         # web服务授权配置文件
    /etc/cobbler/users.digest                       # web访问的用户名和密码配置
    /var/lib/cobbler/config                         # 存放distros,system,profile的配置文件
    /var/lib/cobbler/kickstart                      # 用户默认的kickstart文件
    /var/lib/cobbler/loaders                        # 存放各种引导程序
    /var/lib/cobbler/ks_mirror                      # 系统所有数据
    /var/lib/cobbler/images                         # kernel和initrd镜像可用
    /var/www/cobbler/repo_mirror                    # yum仓库存储目录
    /var/log/cobbler/installing                     # 客户端安装日志
    /var/log/cobbler/cobbler.log                    # cobbler日志

cobbler常用命令
----------------------------------------------------------------------------------

.. code-block:: text

    cobbler check               # 核对当前设置是否有问题
    cobbler list                # 列出所有元素
    cobbler report              # 列出元素的详细信息
    cobbler sync                # 同步配置到数据目录
    cobbler reposync            # 同步yum仓库
    cobbler distro              # 查看导入的系统信息
    cobbler system              # 查看添加的系统信息
    cobbler profile             # 查看配置信息

cobbler重要参数设置
--------------------------------------------------------------------------------

.. code-block:: text

    default_password_crypted    # 默认root密码
    manage_dhcp                 # 是否cobbler管理dhcp
    manage_tftpd                # 是否cobbler管理tftpd
    next_server                 # tftp服务器的ip地址
    server                      # cobbler服务器的ip地址


修改配置文件
----------------------------------------------------------------------

.. code-block:: bash

    [root@localhost yum.repos.d]# cobbler check
    The following are potential configuration items that you may want to fix:

    1 : The 'server' field in /etc/cobbler/settings must be set to something other than localhost, or kickstarting features will not work.  This should be a resolvable hostname or IP for the boot server as reachable by all machines that will use it.
    2 : For PXE to be functional, the 'next_server' field in /etc/cobbler/settings must be set to something other than 127.0.0.1, and should match the IP of the boot server on the PXE network.
    3 : SELinux is enabled. Please review the following wiki page for details on ensuring cobbler works correctly in your SELinux environment:
        https://github.com/cobbler/cobbler/wiki/Selinux
    4 : change 'disable' to 'no' in /etc/xinetd.d/tftp
    5 : Some network boot-loaders are missing from /var/lib/cobbler/loaders, you may run 'cobbler get-loaders' to download them, or, if you only want to handle x86/x86_64 netbooting, you may ensure that you have installed a *recent* version of the syslinux package installed and can ignore this message entirely.  Files in this directory, should you want to support all architectures, should include pxelinux.0, menu.c32, elilo.efi, and yaboot. The 'cobbler get-loaders' command is the easiest way to resolve these requirements.
    6 : enable and start rsyncd.service with systemctl
    7 : debmirror package is not installed, it will be required to manage debian deployments and repositories
    8 : The default password used by the sample templates for newly installed machines (default_password_crypted in /etc/cobbler/settings) is still set to 'cobbler' and should be changed, try: "openssl passwd -1 -salt 'random-phrase-here' 'your-password-here'" to generate new one
    9 : fencing tools were not found, and are required to use the (optional) power management features. install cman or fence-agents to use them

    Restart cobblerd and then run 'cobbler sync' to apply changes.

上面提示了几个错误，主要总结下如下

.. code-block:: text

    server字段在/etc/cobbler/settings配置文件没有设置为本机的ip
    next_server字段没有设置为指定ip
    selinux是启用的（这个我们是关闭的，不管他）
    启用tftp服务
    运行cobbler get-loaders命令下载loader文件
    启用rsyncd.service
    debmirror包没有安装(我们不按照deb系统，这个就可以忽略了）
    默认密码没有修改
    fencing工具没有发现
    我们没有自己配置dhcp服务，想让cobbler配置，我们修改manage_dhcp

    修改完毕后重启cobblerd服务，使用cobbler sync同步。

    接下来我们对这个上面的几个错误进行修改。

.. code-block:: bash

    [root@localhost cobbler]# cat settings  |grep "^server"
    server: 127.0.0.1
    [root@localhost cobbler]# ip address show ens33 |grep inet
        inet 192.168.46.7/24 brd 192.168.46.255 scope global ens33
        inet6 fe80::ce21:b5ad:bc87:8642/64 scope link
    [root@localhost cobbler]# sed -i 's@server: 127.0.0.1@server: 192.168.46.7@' settings
    [root@localhost cobbler]# cat settings  |grep "next_server"
    next_server: 192.168.46.7
    [root@localhost cobbler]# systemctl enable tftp
    Created symlink from /etc/systemd/system/sockets.target.wants/tftp.socket to /usr/lib/systemd/system/tftp.socket.
    [root@localhost cobbler]# systemctl start tftp
    [root@localhost cobbler]# cobbler get-loaders
    [root@localhost cobbler]# systemctl start rsyncd.service
    [root@localhost cobbler]# systemctl enable rsyncd
    Created symlink from /etc/systemd/system/multi-user.target.wants/rsyncd.service to /usr/lib/systemd/system/rsyncd.service.
    [root@localhost cobbler]# cat settings  |grep "^default_password_crypted" 
    default_password_crypted: "$1$mF86/UHC$WvcIcX2t6crBz2onWxyac."
    [root@localhost cobbler]# cat settings  |grep "^default_password_crypted"  -B 5
    # default is "cobbler" and cobbler check will warn if
    # this is not changed.
    # The simplest way to change the password is to run 
    # openssl passwd -1
    # and put the output between the "" below.
    default_password_crypted: "$1$mF86/UHC$WvcIcX2t6crBz2onWxyac."
    [root@localhost cobbler]# openssl passwd -1 
    Password: 
    Verifying - Password: 
    $1$bwFRrz9M$sCpsiRXZ2zHzzLLa1nAzD1
    [root@localhost cobbler]# sed -i 's@$1$mF86/UHC$WvcIcX2t6crBz2onWxyac.@$1$bwFRrz9M$sCpsiRXZ2zHzzLLa1nAzD1@' settings 
    [root@localhost cobbler]# cat settings  |grep "^default_password_crypted" 
    default_password_crypted: "$1$bwFRrz9M$sCpsiRXZ2zHzzLLa1nAzD1"
    [root@localhost cobbler]# cat settings  |grep "^manage_dhcp"
    manage_dhcp: 0
    [root@localhost cobbler]# sed -i 's@manage_dhcp: 0@manage_dhcp: 1@' settings 
    [root@localhost cobbler]# systemctl restart cobblerd
    [root@localhost cobbler]# cobbler check
    The following are potential configuration items that you may want to fix:

    1 : SELinux is enabled. Please review the following wiki page for details on ensuring cobbler works correctly in your SELinux environment:
        https://github.com/cobbler/cobbler/wiki/Selinux
    2 : change 'disable' to 'no' in /etc/xinetd.d/tftp
    3 : debmirror package is not installed, it will be required to manage debian deployments and repositories
    4 : fencing tools were not found, and are required to use the (optional) power management features. install cman or fence-agents to use them

    Restart cobblerd and then run 'cobbler sync' to apply changes.

    [root@localhost cobbler]# sed -i 's@192.168.1@192.168.46@' dhcp.template                                       # 这个模板文件根据自己的ip修改即可
    [root@localhost cobbler]# systemctl restart cobblerd
    [root@localhost cobbler]# cobbler sync

导入镜像
----------------------------------------------------------------------

我们在原有centos7光盘的基础上挂载一个centos6 

.. code-block:: bash

    [root@localhost cobbler]# lsblk
    NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
    sda               8:0    0  200G  0 disk 
    ├─sda1            8:1    0    1G  0 part /boot
    └─sda2            8:2    0  199G  0 part 
    ├─centos-root 253:0    0   50G  0 lvm  /
    ├─centos-swap 253:1    0    2G  0 lvm  [SWAP]
    └─centos-home 253:2    0  147G  0 lvm  /home
    sr0              11:0    1  8.1G  0 rom  
    [root@localhost cobbler]# for i in `find /sys/devices -name scan` ; do echo "- - -" > $i ; done 
    [root@localhost cobbler]# lsblk
    NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
    sda               8:0    0  200G  0 disk 
    ├─sda1            8:1    0    1G  0 part /boot
    └─sda2            8:2    0  199G  0 part 
    ├─centos-root 253:0    0   50G  0 lvm  /
    ├─centos-swap 253:1    0    2G  0 lvm  [SWAP]
    └─centos-home 253:2    0  147G  0 lvm  /home
    sr0              11:0    1  8.1G  0 rom  
    sr1              11:1    1  5.8G  0 rom  

    [root@localhost cobbler]# mkdir /mnt/centos{6,7}
    [root@localhost cobbler]# mount /dev/sr0 /mnt/centos7
    mount: /dev/sr0 is write-protected, mounting read-only
    [root@localhost cobbler]# mount /dev/sr1 /mnt/centos6/
    mount: /dev/sr1 is write-protected, mounting read-only

    [root@localhost cobbler]# cobbler import --name centos-6.9-x86_64 --arch=x86_64 --path /mnt/centos6/
    [root@localhost cobbler]# cobbler import --name centos-7.4-x86_64 --arch=x86_64 --path /mnt/centos7/

    [root@localhost cobbler]# cobbler profile list
    centos-6.9-i386
    centos-6.9-x86_64
    centos-7.4-x86_64
    [root@localhost cobbler]# cobbler profile remove centos-6.9-i386
    --name is required
    [root@localhost cobbler]# cobbler profile remove --name centos-6.9-i386
    [root@localhost cobbler]# cobbler profile list
    centos-6.9-x86_64
    centos-7.4-x86_64


.. note:: 如果想使用自己的ks文件，可以在import的时候指定--kickstart=绝对路径的ks位置。

系统网络安装
----------------------------------------------------------------------

进入bios设置启动项目硬盘第一个，cdrom第二个，网络第三个即可。

安装菜单页面： 

.. image:: /images/自动化安装/cobbler启动界面.png


关于web界面的
--------------------------------------------------------------------------

web的额外配置

.. code-block:: bash

    [root@localhost html]# vim /etc/cobbler/modules.conf 
    # 修改如下信息
    module = authn_pam
    [root@localhost html]# yum install cobbler-web
    [root@localhost html]# service cobblerd restart
    [root@localhost html]# useradd cobbler
    [root@localhost html]# passwd cobbler 
    [root@localhost html]# vim /etc/cobbler/users.conf
    # 修改admin=创建的用户
    admin = "cobbler"

访问测试

浏览器输入https://192.168.46.6/cobbler_web

登陆图： 

.. image:: /images/自动化安装/web登陆界面.png

主页： 

.. image:: /images/自动化安装/web主界面.png

