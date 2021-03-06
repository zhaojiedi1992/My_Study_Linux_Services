.. _topics-pxe:

pxe+kickstart自动化安装
==========================================

pxe的工作原理：

#.  Client向PXE Server上的DHCP发送IP地址请求消息，DHCP检测Client是否合法
    （主要是检测Client的网卡MAC地址），如果合法则返回Client的IP地址，
    同时将启动文件pxelinux.0的位置信息一并传送给Client
#.  Client向PXE Server上的TFTP发送获取pxelinux.0请求消息，TFTP接收到消息之后
    再向Client发送pxelinux.0大小信息，试探Client是否满意，当TFTP收到Client发回的同意大小信息之后，
    正式向Client发送pxelinux.0
#.  Client执行接收到的pxelinux.0文件
#.  Client向TFTP Server发送针对本机的配置信息文件（在TFTP 服务的pxelinux.cfg目录下），
    TFTP将配置文件发回Client，继而Client根据配置文件执行后续操作。
#.  Client向TFTP发送Linux内核请求信息，TFTP接收到消息之后将内核文件发送给Client
#.  Client向TFTP发送根文件请求信息，TFTP接收到消息之后返回Linux根文件系统
#.  Client启动Linux内核
#.  Client下载安装源文件，读取自动化安装脚本

配置dhcp服务器
-----------------------------------------------------------------

详细的可以参考 :ref:`topics-dhcp` 

我们需要在原有的dhcp的配置稍作修改，最终dhcp配置如下 ：

.. code-block:: bash

    [root@localhost tftpboot]# vim /etc/dhcp/dhcpd.conf 
    [root@localhost tftpboot]# cat /etc/dhcp/dhcpd.conf 
    # dhcpd.conf
    #
    # Sample configuration file for ISC dhcpd
    #

    # option definitions common to all supported networks...
    option domain-name "linuxpanda.tech";
    option domain-name-servers ns1.linuxpanda.tech, ns2.linuxpanda.tech;

    default-lease-time 86400;
    max-lease-time 864000;

    subnet 192.168.46.0 netmask 255.255.255.0 {
    range dynamic-bootp 192.168.46.100 192.168.46.200 ;
    option routers 192.168.46.6 ;
    filename "pxelinux.0";
    next-server 192.168.46.6;
    }

    host boss {
    hardware ethernet 08:00:07:26:c0:a5;
    fixed-address 192.168.46.2 ;
    }

    [root@localhost tftpboot]# service dhcpd restart
    Shutting down dhcpd:                                       [  OK  ]
    Starting dhcpd:                                            [  OK  ]

其中filename指明了引导文件名称，next-server提供了文件服务器的地址。

tfp-server的下载安装
-------------------------------------------------------------------

.. code-block:: bash

    [root@localhost ~]# yum install tftp-server -y 
    [root@localhost ~]# rpm -ql tftp-server 
    /etc/xinetd.d/tftp
    /usr/sbin/in.tftpd
    ............其他文件.................
    /var/lib/tftpboot
    [root@localhost ~]# service xinetd start
    Starting xinetd:                                           [  OK  ]
    [root@localhost ~]# chkconfig tftp on
    [root@localhost ~]# ss -tunl |grep 69
    udp    UNCONN     0      0                      *:69   

tftp依赖于xinet的，我们需要启动下xinetd 。

.. warning:: 这个地方只能使用tftp-server，不能使用其他的ftp软件。

安装httpd服务
--------------------------------------------------------------------

.. code-block:: bash

    [root@localhost tftpboot]# yum install httpd
    [root@localhost tftpboot]# mkdir /var/www/html/centos/{6,7} -pv
    [root@localhost tftpboot]# chkconfig  httpd on
    [root@localhost tftpboot]# service httpd start

.. note:: 上面提示域名有点问题，暂时不用关心。

挂载光盘
--------------------------------------------------------------------------------------

我们之前添加过centos6的光盘，这里再添加一个centos7的光盘。

.. code-block:: bash

    [root@localhost tftpboot]# ls /dev/sr*                                   # 查看我们添加的光盘
    /dev/sr0
    [root@localhost tftpboot]# find /sys/devices/ -name scan                # 找scan文件
    /sys/devices/pci0000:00/0000:00:07.1/host1/scsi_host/host1/scan
    /sys/devices/pci0000:00/0000:00:07.1/host2/scsi_host/host2/scan
    /sys/devices/pci0000:00/0000:00:10.0/host0/scsi_host/host0/scan
    [root@localhost tftpboot]# for i in `find /sys/devices/ -name scan` ; do echo "- - -" > $i ; done # 启用下硬件识别
    [root@localhost tftpboot]# ls /dev/sr*                                  # 再次查看光盘信息，发现光盘已经被识别出来了。
    /dev/sr0  /dev/sr1
    [root@localhost tftpboot]# mount /dev/sr0 /var/www/html/centos/6/       # 挂载centos6
    mount: block device /dev/sr0 is write-protected, mounting read-only
    [root@localhost tftpboot]# mount /dev/sr1 /var/www/html/centos/7/       # 挂载centos7
    mount: block device /dev/sr1 is write-protected, mounting read-only

我们这里都挂载好了，需要在宿主机上测试下httpd服务，宿主机测试http://192.168.46.6/centos/是否能访问。


构建ks文件
--------------------------------------------------------------------------------------

我这里需要构建4个ks文件， centos6系统2个，centos7系统2个。

我这里在centos6操作,centos7的ks文件需要在centos7上制作，远程复制到这个机器上来。


.. code-block:: bash

    [root@localhost ks]# cat ks6-mini.cfg 
    # Kickstart file automatically generated by anaconda.

    #version=DEVEL
    install
    url --url=http://192.168.46.6/centos/6
    reboot
    text
    #xconfig  --startxonboot
    #eula --agreed
    lang en_US.UTF-8
    firstboot --disable
    keyboard us
    network --onboot no --device eth0 --bootproto dhcp --noipv6
    rootpw  --iscrypted $6$NE46h0OLL1e8dgDc$6Kpz4orvUP87oYdbaHefWtUbD12ITS5RIJPouwHn.LrluP2T9280aoFf9Cs5yvnJ9XIZJHnlV26oa1ECe39Bs1
    firewall --disabled
    authconfig --enableshadow --passalgo=sha512
    selinux --disabled
    timezone Asia/Shanghai
    bootloader --location=mbr --driveorder=sda --append="crashkernel=auto rhgb quiet"
    # The following is the partition information you requested
    # Note that any partitions you deleted are not expressed
    # here so unless you clear all partitions first, this is
    # not guaranteed to work
    clearpart --all --drives=sda
    zerombr

    part /boot --fstype=ext4 --size=500
    part pv.008002  --size=200000
    volgroup VolGroup --pesize=4096 pv.008002
    logvol /home --fstype=ext4 --name=lv_home --vgname=VolGroup --grow --size=100
    logvol / --fstype=ext4 --name=lv_root --vgname=VolGroup --grow --size=1024 --maxsize=51200
    logvol swap --name=lv_swap --vgname=VolGroup --grow --size=1984 --maxsize=1984


    #repo --name="CentOS"  --baseurl=cdrom:sr0 --cost=100

    %packages
    @core
    @server-policy
    @workstation-policy
    %end

    %post
    touch /root/post.file 
    %end


    [root@localhost ks]# cat ks6-desktop.cfg 
    # Kickstart file automatically generated by anaconda.

    #version=DEVEL
    install
    url --url=http://192.168.46.6/centos/6
    reboot
    text
    xconfig  --startxonboot
    #eula --agreed
    lang en_US.UTF-8
    firstboot --disable
    keyboard us
    network --onboot no --device eth0 --bootproto dhcp --noipv6
    rootpw  --iscrypted $6$NE46h0OLL1e8dgDc$6Kpz4orvUP87oYdbaHefWtUbD12ITS5RIJPouwHn.LrluP2T9280aoFf9Cs5yvnJ9XIZJHnlV26oa1ECe39Bs1
    firewall --disabled
    authconfig --enableshadow --passalgo=sha512
    selinux --disabled
    timezone Asia/Shanghai
    bootloader --location=mbr --driveorder=sda --append="crashkernel=auto rhgb quiet"
    # The following is the partition information you requested
    # Note that any partitions you deleted are not expressed
    # here so unless you clear all partitions first, this is
    # not guaranteed to work
    clearpart --all --drives=sda
    zerombr

    part /boot --fstype=ext4 --size=500
    part pv.008002  --size=200000
    volgroup VolGroup --pesize=4096 pv.008002
    logvol /home --fstype=ext4 --name=lv_home --vgname=VolGroup --grow --size=100
    logvol / --fstype=ext4 --name=lv_root --vgname=VolGroup --grow --size=1024 --maxsize=51200
    logvol swap --name=lv_swap --vgname=VolGroup --grow --size=1984 --maxsize=1984


    #repo --name="CentOS"  --baseurl=cdrom:sr0 --cost=100

    %packages
    @base
    @core
    @debugging
    @basic-desktop
    @desktop-platform
    @directory-client
    @fonts
    @general-desktop
    @graphical-admin-tools
    @input-methods
    @internet-applications
    @internet-browser
    @legacy-x
    @network-file-system-client
    @x11
    %end

    %post
    touch /root/post.file 
    %end

    [root@localhost ks]# cat ks7-mini.cfg 
    #version=DEVEL
    # System authorization information
    auth --enableshadow --passalgo=sha512
    # Use CDROM installation media
    url --url=http://192.168.46.6/centos/7
    # Use graphical install
    firewall --disabled
    selinux --disabled
    text
    reboot
    # Run the Setup Agent on first boot
    firstboot --disable
    ignoredisk --only-use=sda
    # Keyboard layouts
    keyboard --vckeymap=us --xlayouts='us'
    # System language
    lang en_US.UTF-8

    # Network information
    network  --bootproto=dhcp --device=ens33 --onboot=on --ipv6=auto --activate
    network  --hostname=centos7.magedu.com

    # Root password
    rootpw --iscrypted $6$pjgOq.zzypK4qeve$KrCLntLJyyvUPWElz5BIVztGXDov8Vj.gJaNTQ6gzeUHeC0KTeiMLPzScbCja37wJ58mzGgKeGooAMqZD7A2h/
    # System services
    services --disabled="chronyd"
    # System timezone
    timezone Asia/Shanghai --isUtc --nontp
    user --name=zhao --password=$6$4FY9k21GGia3q98C$p8NRwX2/9w/MEqi03ASVe9aoyehDLRsnqV6QrkM3o38nLQW5Ox7cRvFWg8weQYoyPz85ro8D000tnVgGz225q0 --iscrypted --gecos="zhao"
    # X Window System configuration information
    xconfig  --startxonboot
    # System bootloader configuration
    bootloader --location=mbr --boot-drive=sda
    # Partition clearing information
    zerombr
    clearpart --all --initlabel
    autopart --type=lvm
    # Disk partitioning information
    #part swap --fstype="swap" --ondisk=sda --size=2048
    #part /boot --fstype="xfs" --ondisk=sda --size=1024
    #part / --fstype="xfs" --ondisk=sda --size=51200
    #part /app --fstype="xfs" --ondisk=sda --size=20480
    eula --agreed
    %packages
    @^minimal
    @core
    %end

    %addon com_redhat_kdump --disable --reserve-mb='auto'

    %end

    %anaconda
    pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
    pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
    pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
    %end

    [root@localhost ks]# cat ks7-desktop.cfg 
    #version=DEVEL
    # System authorization information
    auth --enableshadow --passalgo=sha512
    # Use CDROM installation media
    url --url=http://192.168.46.6/centos/7
    # Use graphical install
    firewall --disabled
    selinux --disabled
    text
    reboot
    # Run the Setup Agent on first boot
    firstboot --disable
    ignoredisk --only-use=sda
    # Keyboard layouts
    keyboard --vckeymap=us --xlayouts='us'
    # System language
    lang en_US.UTF-8

    # Network information
    network  --bootproto=dhcp --device=ens33 --onboot=on --ipv6=auto --activate
    network  --hostname=centos7.magedu.com

    # Root password
    rootpw --iscrypted $6$pjgOq.zzypK4qeve$KrCLntLJyyvUPWElz5BIVztGXDov8Vj.gJaNTQ6gzeUHeC0KTeiMLPzScbCja37wJ58mzGgKeGooAMqZD7A2h/
    # System services
    services --disabled="chronyd"
    # System timezone
    timezone Asia/Shanghai --isUtc --nontp
    user --name=zhao --password=$6$4FY9k21GGia3q98C$p8NRwX2/9w/MEqi03ASVe9aoyehDLRsnqV6QrkM3o38nLQW5Ox7cRvFWg8weQYoyPz85ro8D000tnVgGz225q0 --iscrypted --gecos="zhao"
    # X Window System configuration information
    xconfig  --startxonboot
    # System bootloader configuration
    bootloader --location=mbr --boot-drive=sda
    # Partition clearing information
    zerombr
    clearpart --all --initlabel
    autopart --type=lvm
    # Disk partitioning information
    #part swap --fstype="swap" --ondisk=sda --size=2048
    #part /boot --fstype="xfs" --ondisk=sda --size=1024
    #part / --fstype="xfs" --ondisk=sda --size=51200
    #part /app --fstype="xfs" --ondisk=sda --size=20480
    eula --agreed
    %packages
    @base
    @core
    @dial-up
    @fonts
    @gnome-desktop
    @guest-agents
    @guest-desktop-agents
    @internet-browser
    @multimedia
    @network-file-system-client
    @networkmanager-submodules
    @x11
    %end

    %addon com_redhat_kdump --disable --reserve-mb='auto'

    %end

    %anaconda
    pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
    pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
    pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
    %end

    %post
    systemctl set-default multi-user.target
    systemctl disable initial-setup-graphical.service
    %end

    [root@localhost ks]# ll                                    # 这里发现权限有点问题，400的文件权限apache是无法访问的，修改下。
    total 16
    -rw-------. 1 root root 1479 Jan 10 23:14 ks6-desktop.cfg
    -rw-------. 1 root root 1300 Jan 10 22:51 ks6-mini.cfg
    -rw-r--r--. 1 root root 1927 Jan 10 23:13 ks7-desktop.cfg
    -rw-r--r--. 1 root root 1774 Jan 10 23:10 ks7-mini.cfg
    [root@localhost ks]# chmod 644 *
    
一共四个文件。

.. note:: ks文件的编写可以手工编写的，建议是使用system-config-kickstart图形界面加载/root/anaconda-ks.cfg修改另存。

填充tftp目录内容
--------------------------------------------------------------------------------------

pxe的配置需要几个文件的：

.. code-block:: text

  initrd.img              # 根文件系统
  vmlinuz                 # 内核
  menu.c32                # 启动菜单
  pxelinux.0              # pxelinux
  pxelinux.cfg/default    # pxelinux配置文件

.. code-block:: bash

  [root@localhost ks]# cd /var/lib/tftpboot/
  [root@localhost tftpboot]# mkdir {6,7}
  [root@localhost tftpboot]# cp /var/www/html/centos/6/isolinux/{vmlinuz,initrd.img} 6/
  [root@localhost tftpboot]# cp /var/www/html/centos/7/isolinux/{vmlinuz,initrd.img} 7/

  [root@localhost tftpboot]# mkdir pxelinux.cfg
  [root@localhost tftpboot]# cp /var/www/html/centos/7/isolinux/isolinux.cfg ./pxelinux.cfg/default
  [root@localhost tftpboot]# vim pxelinux.cfg/default 
  [root@localhost tftpboot]# cat pxelinux.cfg/default 
  default menu.c32
  timeout 600

  menu title CentOS 6 or 7 | made by zhaojiedi1992@linuxpanda.tech

  label centos7-mini
    menu label Install CentOS 7-mini
    kernel 6/vmlinuz
    append initrd=7/initrd.img ks=http://192.168.46.6/ks/ks7-mini.cfg

  label centos7-Desktop
    menu label Install CentOS 7-desktop
    kernel 6/vmlinuz
    append initrd=7/initrd.img ks=http://192.168.46.6/ks/ks7-desktop.cfg

  label centos6-mini
    menu label Install CentOS 6-mini
    kernel 6/vmlinuz
    append initrd=6/initrd.img ks=http:192.168.46.6//ks/ks6-mini.cfg

  label centos6-desktop
    menu label Install CentOS 6-desktop
    kernel 6/vmlinuz
    append initrd=6/initrd.img ks=http://192.168.46.6/ks/ks6-desktop.cfg

  label local
    menu default
    menu label Boot from ^local drive
    localboot 0xffff


  [root@localhost tftpboot]# cp /usr/share/syslinux/pxelinux.0 .
  [root@localhost tftpboot]# cp /usr/share/syslinux/menu.c32 .
  [root@localhost tftpboot]# tree
  .
  ├── 6
  │   ├── initrd.img
  │   └── vmlinuz
  ├── 7
  │   ├── initrd.img
  │   └── vmlinuz
  ├── menu.c32
  ├── pxelinux.0
  └── pxelinux.cfg
      └── default

  3 directories, 7 files

系统网络安装
----------------------------------------------------------------------

进入bios设置启动项目硬盘第一个，cdrom第二个，网络第三个即可。


安装菜单页面： 

.. image:: /images/自动化安装/安装centos6图形.png

.. warning:: 如果你要选择图形化安装，建议内存调整为1.2G
