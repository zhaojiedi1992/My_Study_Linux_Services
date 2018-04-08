keepalived
=================================================

准备工作
----------------------------------------------

主要是selinux 、firewalld和时间同步问题，这些这里就不写了。 

安装配置ip漂移
---------------------------------------------------

.. code-block:: bash

    # 备份原有的
    [root@centos-151 ~]# yum install keepalived 
    [root@centos-151 ~]# cd /etc/keepalived/
    [root@centos-151 keepalived]# ls
    keepalived.conf
    [root@centos-151 keepalived]# cp keepalived.conf{,.bak}
    [root@centos-151 keepalived]# ll
    total 8
    -rw-r--r-- 1 root root 3598 Mar 20 09:38 keepalived.conf
    -rw-r--r-- 1 root root 3598 Mar 20 09:41 keepalived.conf.bak

    # 修改配置
    [root@centos-151 keepalived]# vim keepalived.conf
    [root@centos-151 keepalived]# cat keepalived.conf
    ! Configuration File for keepalived

    global_defs {
    notification_email {
        root@localhost
    }
    notification_email_from keepalived@localhost
    smtp_server 127.0.0.1
    smtp_connect_timeout 30
    router_id LVS_DEVEL
    vrrp_mcast_group4 224.1.1.1
    }

    vrrp_instance VI_1 {
        state MASTER
        interface ens37
        virtual_router_id 51
        priority 100
        advert_int 1
        authentication {
            auth_type PASS
            auth_pass 1111
        }
        virtual_ipaddress {
        172.18.46.100/16
        }

    }

    # 复制到远程主机并修改
    [root@centos-151 keepalived]# cp keepalived.conf 192.168.46.154:/etc/keepalived/
    cp: cannot create regular file ‘192.168.46.154:/etc/keepalived/’: No such file or directory
    [root@centos-151 keepalived]# scp keepalived.conf 192.168.46.154:/etc/keepalived/
    The authenticity of host '192.168.46.154 (192.168.46.154)' can't be established.
    ECDSA key fingerprint is SHA256:CCHUJxa/IGrB0CXKtvPHaiVK+pJAp3xY0djGwCkmQVM.
    ECDSA key fingerprint is MD5:54:dd:11:2f:d4:8d:31:18:39:15:5a:ec:9a:9a:43:da.
    Are you sure you want to continue connecting (yes/no)? yes
    Warning: Permanently added '192.168.46.154' (ECDSA) to the list of known hosts.
    root@192.168.46.154's password: 
    keepalived.conf   

    [root@centos-154 ~]# cat /etc/keepalived/keepalived.conf 
    ! Configuration File for keepalived

    global_defs {
    notification_email {
        root@localhost
    }
    notification_email_from keepalived@localhost
    smtp_server 127.0.0.1
    smtp_connect_timeout 30
    router_id LVS_DEVEL_2
    vrrp_mcast_group4 224.1.1.1
    }

    vrrp_instance VI_1 {
        state BACKUP
        interface ens37
        virtual_router_id 51
        priority 80
        advert_int 1
        authentication {
            auth_type PASS
            auth_pass 1111
        }
        virtual_ipaddress {
        172.18.46.100/16
        }

    }


    # 启动服务并抓包

    # 启动151
    [root@centos-151 keepalived]# systemctl restart keepalived
    [root@centos-154 keepalived]# systemctl restart keepalived

    # 抓包
    [root@centos-151 ~]# tcpdump -i ens37 -nn host 224.1.1.1
    tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
    listening on ens37, link-type EN10MB (Ethernet), capture size 262144 bytes
    09:56:45.609383 IP 172.18.46.151 > 224.1.1.1: igmp v2 report 224.1.1.1
    09:56:46.609380 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:56:47.613899 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:56:48.508630 IP 172.18.46.151 > 224.1.1.1: igmp v2 report 224.1.1.1
    09:56:48.615603 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:56:49.617331 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:56:50.619132 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:56:51.620877 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:56:52.621399 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:56:53.398894 IP 172.18.105.131 > 224.1.1.1: igmp v2 report 224.1.1.1
    09:56:53.623045 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:56:54.624785 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:56:54.902075 IP 172.18.105.131 > 224.1.1.1: igmp v2 report 224.1.1.1
    09:56:55.626201 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:56:56.628140 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:56:57.630579 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:56:58.632492 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:56:59.633962 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:57:00.636156 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:57:01.637809 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:57:02.397616 IP 172.18.105.131 > 224.1.1.1: igmp v2 report 224.1.1.1
    09:57:02.639238 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:57:03.640875 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:57:04.642235 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:57:05.643316 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:57:06.645263 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:57:07.647454 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20

    # 关闭151
    [root@centos-151 keepalived]# systemctl stop keepalived

    # 抓包，可以看到主动关闭151发送0优先级， 154机器的优先级是80，就占有ip了。
    [root@centos-151 ~]# tcpdump -i ens37 -nn host 224.1.1.1
    tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
    listening on ens37, link-type EN10MB (Ethernet), capture size 262144 bytes
    09:59:34.884048 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:59:35.885537 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:59:36.887106 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:59:37.888805 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:59:38.890461 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:59:39.892321 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:59:40.893758 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:59:41.895278 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 100, authtype simple, intvl 1s, length 20
    09:59:42.195050 IP 172.18.46.151 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 0, authtype simple, intvl 1s, length 20
    09:59:42.884235 IP 172.18.105.131 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 80, authtype simple, intvl 1s, length 20
    09:59:43.886181 IP 172.18.105.131 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 80, authtype simple, intvl 1s, length 20
    09:59:44.887932 IP 172.18.105.131 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 80, authtype simple, intvl 1s, length 20
    09:59:45.889441 IP 172.18.105.131 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 80, authtype simple, intvl 1s, length 20
    09:59:46.891284 IP 172.18.105.131 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 80, authtype simple, intvl 1s, length 20
    09:59:47.892750 IP 172.18.105.131 > 224.1.1.1: VRRPv2, Advertisement, vrid 51, prio 80, authtype simple, intvl 1s, length 20


启动日志功能
---------------------------------

.. code-block:: bash 

    # 修改日志设置
    [root@centos-154 ~]# vim /etc/sysconfig/keepalived 
    KEEPALIVED_OPTIONS="-D -S 3"

    # 配置特定local
    [root@centos-154 ~]# vim /etc/rsyslog.conf 
    # 添加一行
    local3.*                                               /var/log/keepalived.log

    # 重启服务
    [root@centos-154 ~]# systemctl keepalived
    [root@centos-154 ~]# systemctl restart  keepalived

    # 查看日志信息
    [root@centos-154 ~]# cat /var/log/keepalived.log 

    Mar 20 10:06:05 centos-154 Keepalived[3097]: Starting Keepalived v1.3.5 (03/19,2017), git commit v1.3.5-6-g6fa32f2
    Mar 20 10:06:05 centos-154 Keepalived[3097]: Unable to resolve default script username 'keepalived_script' - ignoring
    Mar 20 10:06:05 centos-154 Keepalived[3097]: Opening file '/etc/keepalived/keepalived.conf'.
    Mar 20 10:06:05 centos-154 Keepalived[3098]: Starting Healthcheck child process, pid=3099
    Mar 20 10:06:05 centos-154 Keepalived[3098]: Starting VRRP child process, pid=3100
    Mar 20 10:06:05 centos-154 Keepalived_healthcheckers[3099]: Initializing ipvs
    Mar 20 10:06:05 centos-154 Keepalived_healthcheckers[3099]: Opening file '/etc/keepalived/keepalived.conf'.
    Mar 20 10:06:05 centos-154 Keepalived_vrrp[3100]: Registering Kernel netlink reflector
    Mar 20 10:06:05 centos-154 Keepalived_vrrp[3100]: Registering Kernel netlink command channel
    Mar 20 10:06:05 centos-154 Keepalived_vrrp[3100]: Registering gratuitous ARP shared channel
    Mar 20 10:06:05 centos-154 Keepalived_vrrp[3100]: Opening file '/etc/keepalived/keepalived.conf'.
    Mar 20 10:06:05 centos-154 Keepalived_vrrp[3100]: VRRP_Instance(VI_1) removing protocol VIPs.
    Mar 20 10:06:05 centos-154 Keepalived_vrrp[3100]: Using LinkWatch kernel netlink reflector...
    Mar 20 10:06:05 centos-154 Keepalived_vrrp[3100]: VRRP_Instance(VI_1) Entering BACKUP STATE
    Mar 20 10:06:05 centos-154 Keepalived_vrrp[3100]: VRRP sockpool: [ifindex(3), proto(112), unicast(0), fd(10,11)]
    Mar 20 10:06:09 centos-154 Keepalived_vrrp[3100]: VRRP_Instance(VI_1) Transition to MASTER STATE
    Mar 20 10:06:10 centos-154 Keepalived_vrrp[3100]: VRRP_Instance(VI_1) Entering MASTER STATE
    Mar 20 10:06:10 centos-154 Keepalived_vrrp[3100]: VRRP_Instance(VI_1) setting protocol VIPs.
    Mar 20 10:06:10 centos-154 Keepalived_vrrp[3100]: Sending gratuitous ARP on ens37 for 172.18.46.100
    Mar 20 10:06:10 centos-154 Keepalived_vrrp[3100]: VRRP_Instance(VI_1) Sending/queueing gratuitous ARPs on ens37 for 172.18.46.100
    Mar 20 10:06:10 centos-154 Keepalived_vrrp[3100]: Sending gratuitous ARP on ens37 for 172.18.46.100
    Mar 20 10:06:10 centos-154 Keepalived_vrrp[3100]: Sending gratuitous ARP on ens37 for 172.18.46.100
    Mar 20 10:06:10 centos-154 Keepalived_vrrp[3100]: Sending gratuitous ARP on ens37 for 172.18.46.100
    Mar 20 10:06:10 centos-154 Keepalived_vrrp[3100]: Sending gratuitous ARP on ens37 for 172.18.46.100
    Mar 20 10:06:15 centos-154 Keepalived_vrrp[3100]: Sending gratuitous ARP on ens37 for 172.18.46.100
    Mar 20 10:06:15 centos-154 Keepalived_vrrp[3100]: VRRP_Instance(VI_1) Sending/queueing gratuitous ARPs on ens37 for 172.18.46.100
    Mar 20 10:06:15 centos-154 Keepalived_vrrp[3100]: Sending gratuitous ARP on ens37 for 172.18.46.100
    Mar 20 10:06:15 centos-154 Keepalived_vrrp[3100]: Sending gratuitous ARP on ens37 for 172.18.46.100
    Mar 20 10:06:15 centos-154 Keepalived_vrrp[3100]: Sending gratuitous ARP on ens37 for 172.18.46.100
    Mar 20 10:06:15 centos-154 Keepalived_vrrp[3100]: Sending gratuitous ARP on ens37 for 172.18.46.100

    # 查看vip是不是回到151机器上面来了。
    [root@centos-154 ~]# ip a show ens37


状态切换脚本通知
-----------------------------------

.. code-block:: bash 

    # 准备脚本

    [root@centos-151 ~]# cd /root/
    [root@centos-151 ~]# vim notify.sh
    [root@centos-151 ~]# cat notify.sh 
    #!/bin/bash
    contact='root@localhost'
    notify() {
        mailsubject="$(hostname) to be $1, vip floating"
        mailbody="$(date +'%F %T'): vrrp transition, $(hostname) changed to be $1"
        echo "$mailbody" | mail -s "$mailsubject" $contact
    }

    case $1 in
        master)
            notify master
            ;;
        backup)
            notify backup
            ;;
        fault)
            notify fault
            ;;
        *)
            echo "Usage: $(basename $0) {master|backup|fault}"
            exit 1
            ;;
    esac

    # 添加权限
    [root@centos-154 ~]# chmod 755 notify.sh 

    # 测试脚本
    [root@centos-151 ~]# /root/notify.sh master
    [root@centos-151 ~]# mail
    Heirloom Mail version 12.5 7/5/10.  Type ? for help.
    "/var/spool/mail/root": 1 message 1 new
    >N  1 root                  Tue Mar 20 10:43  22/1043  "centos-151.linuxpanda.tech to be master, vip floating"
    & quit

    # 添加通知
    [root@centos-154 ~]# vim /etc/keepalived/keepalived.conf 
    [root@centos-151 ~]# vim /etc/keepalived/keepalived.conf 

    ! Configuration File for keepalived

    global_defs {
    notification_email {
            root@localhost
    }
    notification_email_from keepalived@localhost
    smtp_server 127.0.0.1
    smtp_connect_timeout 30
    router_id LVS_DEVEL_2
    vrrp_mcast_group4 224.1.1.1
    }

    vrrp_instance VI_1 {
        state BACKUP
        interface ens37
        virtual_router_id 51
        priority 80
        advert_int 1
        authentication {
            auth_type PASS
            auth_pass 1111
        }
        virtual_ipaddress {
            172.18.46.100/16
        }
        notify_master "/root/notify.sh master"
        notify_backup "/root/notify.sh backup"
        notify_fault "/root/notify.sh fault"


    }

    # 删除邮件，危险
    [root@centos-151 ~]# rm -rf /var/spool/mail/root

    # 重启151的keepalived服务，发现收到邮件通知。
    [root@centos-151 ~]# mail
    Heirloom Mail version 12.5 7/5/10.  Type ? for help.
    "/var/spool/mail/root": 1 message 1 new
    >N  1 root                  Tue Mar 20 10:54  22/1043  "centos-151.linuxpanda.tech to be master, vip floating"
    & q
    Held 1 message in /var/spool/mail/root
    [root@centos-151 ~]# amil
    bash: amil: command not found
    [root@centos-151 ~]# mail
    Heirloom Mail version 12.5 7/5/10.  Type ? for help.
    "/var/spool/mail/root": 1 message 1 unread
    >U  1 root                  Tue Mar 20 10:54  23/1053  "centos-151.linuxpanda.tech to be master, vip floating"
    & 1
    Message  1:
    From root@centos-151.linuxpanda.tech  Tue Mar 20 10:54:14 2018
    Return-Path: <root@centos-151.linuxpanda.tech>
    X-Original-To: root@centos-151.linuxpanda.tech
    Delivered-To: root@centos-151.linuxpanda.tech
    From: root <root@centos-151.linuxpanda.tech>
    Date: Tue, 20 Mar 2018 10:54:08 +0800
    To: root@centos-151.linuxpanda.tech
    Subject: centos-151.linuxpanda.tech to be master, vip floating
    User-Agent: Heirloom mailx 12.5 7/5/10
    Content-Type: text/plain; charset=us-ascii
    Status: RO

    2018-03-20 10:54:08: vrrp transition, centos-151.linuxpanda.tech changed to be master


lvs+keepalived配合使用
-----------------------------------

拓扑图
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. image:: /images/cluster/keepalived-dr.png


配置2个lvs
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    # 151机器的
    [root@centos-151 keepalived]# cat keepalived.conf
    ! Configuration File for keepalived

    global_defs {
    notification_email {
        root@localhost
    }
    notification_email_from keepalived@localhost
    smtp_server 127.0.0.1
    smtp_connect_timeout 30
    router_id LVS_DEVEL_1
    vrrp_mcast_group4 224.1.1.1
    }

    vrrp_instance VI_1 {
        state MASTER
        interface ens37
        virtual_router_id 51
        priority 100
        advert_int 1
        authentication {
            auth_type PASS
            auth_pass 1111
        }
        virtual_ipaddress {
        172.18.46.100/16
        }
        notify_master "/root/notify.sh master" 
        notify_backup "/root/notify.sh backup" 
        notify_fault "/root/notify.sh fault" 
    
    }
    virtual_server 172.18.46.100 80{
        delay_loop 6
        lb_algo rr
        lb_kind NAT
        persistence_timeout 50
        protocol TCP
        sorry_server 127.0.0.1 80

        real_server 192.168.46.152 80 {
            weight 1
            HTTP_GET {
                url {
                path /
            status_code 200
                }
                connect_timeout 3
                nb_get_retry 3
                delay_before_retry 3
            }
        }
        real_server 192.168.46.153 80 {
            weight 1
            HTTP_GET {
                url {
                path /
            status_code 200
                }
                connect_timeout 3
                nb_get_retry 3
                delay_before_retry 3
            }
        }

    }

    # 154机器的
    [root@centos-154 ~]# cat /etc/keepalived/keepalived.conf
    ! Configuration File for keepalived

    global_defs {
    notification_email {
        root@localhost
    }
    notification_email_from keepalived@localhost
    smtp_server 127.0.0.1
    smtp_connect_timeout 30
    router_id LVS_DEVEL_2
    vrrp_mcast_group4 224.1.1.1
    }

    vrrp_instance VI_1 {
        state BACKUP
        interface ens37
        virtual_router_id 51
        priority 80
        advert_int 1
        authentication {
            auth_type PASS
            auth_pass 1111
        }
        virtual_ipaddress {
        172.18.46.100/16
        }
        notify_master "/root/notify.sh master" 
        notify_backup "/root/notify.sh backup" 
        notify_fault "/root/notify.sh fault" 


    }

    virtual_server 172.18.46.100 80{
        delay_loop 6
        lb_algo rr
        lb_kind NAT
        persistence_timeout 50
        protocol TCP
        sorry_server 127.0.0.1 80

        real_server 192.168.46.152 80 {
            weight 1
            HTTP_GET {
                url {
                path /
                status_code 200
                }
                connect_timeout 3
                nb_get_retry 3
                delay_before_retry 3
            }
        }
        real_server 192.168.46.153 80 {
            weight 1
            HTTP_GET {
                url {
                path /
                status_code 200
                }
                connect_timeout 3
                nb_get_retry 3
                delay_before_retry 3
            }
        }

    }

    # 安装ipvsadm
    [root@centos-151 keepalived]# yum install ipvsadm
    [root@centos-154 keepalived]# yum install ipvsadm

    # 重启keepalived
    [root@centos-151 keepalived]# systemctl restart keepalived
    [root@centos-154 keepalived]# systemctl restart keepalived
    # 查看keepalived自动生成的规则
    [root@centos-151 keepalived]# ipvsadm -ln 
    IP Virtual Server version 1.2.1 (size=4096)
    Prot LocalAddress:Port Scheduler Flags
    -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
    TCP  172.18.46.100:80 rr persistent 50
    -> 192.168.46.152:80            Masq    1      0          0         
    -> 192.168.46.153:80            Masq    1      0          0    

配置2个RS
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    # 在152上执行脚本
    [root@centos-152 ~]# rz 

    [root@centos-152 ~]# ls
    anaconda-ks.cfg  lvs_dr_rs.sh
    [root@centos-152 ~]# vim lvs_dr_rs.sh 
    [root@centos-152 ~]# chmod a+x lvs_dr_rs.sh 
    [root@centos-152 ~]# bash lvs_dr_rs.sh start
    The RS Server is Ready!
    [root@centos-152 ~]# cat lvs_dr_rs.sh 
    #!/bin/bash
    #Author:wangxiaochun
    #Date:2017-08-13
    vip=172.18.46.100
    mask='255.255.255.255'
    dev=lo:1
    case $1 in
    start)
        echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
        echo 1 > /proc/sys/net/ipv4/conf/lo/arp_ignore
        echo 2 > /proc/sys/net/ipv4/conf/all/arp_announce
        echo 2 > /proc/sys/net/ipv4/conf/lo/arp_announce
        ifconfig $dev $vip netmask $mask #broadcast $vip up
        #route add -host $vip dev $dev
        echo "The RS Server is Ready!"
        ;;
    stop)
        ifconfig $dev down
        echo 0 > /proc/sys/net/ipv4/conf/all/arp_ignore
        echo 0 > /proc/sys/net/ipv4/conf/lo/arp_ignore
        echo 0 > /proc/sys/net/ipv4/conf/all/arp_announce
        echo 0 > /proc/sys/net/ipv4/conf/lo/arp_announce
        echo "The RS Server is Canceled!"
        ;;
    *) 
        echo "Usage: $(basename $0) start|stop"
        exit 1
        ;;
    esac

    # 在153上也执行下

    [root@centos-152 ~]# scp lvs_dr_rs.sh  192.168.46.153:/root
    The authenticity of host '192.168.46.153 (192.168.46.153)' can't be established.
    ECDSA key fingerprint is SHA256:CCHUJxa/IGrB0CXKtvPHaiVK+pJAp3xY0djGwCkmQVM.
    ECDSA key fingerprint is MD5:54:dd:11:2f:d4:8d:31:18:39:15:5a:ec:9a:9a:43:da.
    Are you sure you want to continue connecting (yes/no)? yes
    Warning: Permanently added '192.168.46.153' (ECDSA) to the list of known hosts.
    root@192.168.46.153's password: 
    lvs_dr_rs.sh     
    [root@centos-153 ~]# bash lvs_dr_rs.sh start
    The RS Server is Ready!


    # 配置nginx服务
    [root@centos-152 ~]# yum install nginx
    [root@centos-153 ~]# yum install nginx
    [root@centos-152 ~]# systemctl restart nginx
    [root@centos-153 ~]# systemctl restart nginx

    [root@centos-152 ~]# echo "rs152" > /usr/share/nginx/html/index.html
    [root@centos-153 ~]# echo "rs153" > /usr/share/nginx/html/index.html

    [root@centos-151 keepalived]# curl 192.168.46.152
    rs152
    [root@centos-151 keepalived]# curl 192.168.46.153
    rs153

测试
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    [root@localhost ~]# for i in {1..100} ; do sleep 2 ; curl 10.0.46.100; done
    rs152
    rs153
    rs152
    rs153
    rs152
    rs153
    rs152
    rs153
    rs152
    rs153
    rs152
    rs153
    rs152
    rs153
    rs152
    rs153
    rs152
    ^C

    # 停掉151的keepalived服务

    [root@localhost ~]# for i in {1..100} ; do sleep 1 ; curl 10.0.46.100; done
    rs152
    rs153
    rs152
    rs153
    rs152
    rs153
    ^C

    # 继续停掉152的nginx服务，

    [root@localhost ~]# for i in {1..10} ; do sleep 1 ; curl 10.0.46.100; done
    rs153
    curl: (7) Failed connect to 10.0.46.100:80; Connection refused
    rs153
    curl: (7) Failed connect to 10.0.46.100:80; Connection refused
    rs153
    curl: (7) Failed connect to 10.0.46.100:80; Connection refused
    rs153
    rs153
    rs153
    rs153


    # 继续停掉153的nginx服务后测试
    [root@localhost ~]# for i in {1..10} ; do sleep 1 ; curl 10.0.46.100; done
    sorry page
    sorry page
    sorry page
    sorry page
    sorry page
    sorry page
    sorry page
    sorry page
    sorry page
    sorry page

上面的测试，出现连接拒绝问题，是因为我们停掉了nginx服务，keepalived没有及时发现， 需要3次确认才下线。


