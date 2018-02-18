pam
================================================================
Linux-PAM（适用于Linux的可插入认证模块）是一套共享库，可让本地系统管理员选择应用程序如何认证用户。

配置文件用法
---------------------------------------------------------

配置文件为/etc/pam.conf以及/etc/pam.conf.d目录下的文件，每行作为一个记录，

.. code-block:: text 

    记录的格式: 
        service type control module-path moodule-arguments
        服务     类型   控制    模块路径    模块参数

    类型： 
        account：此类型执行基于非认证的账户管理，用于限制或者允许访问服务
        auth: 提供验证用户和授予特定权限
        password: 用户信息更改，比如密码修改
        session: 会话前后需要进行的操作，比如记录日志，挂载特定用户的文件系统等。

    控制： 
        required: 即使某个模块验证失败，还会继续下面的验证。
        resuisite: 如果失败就直接返回失败，一票否决权的
        sufficient: 如果成功就直接返回， 一票通过权。
        optional:   可选的，没有实质作用。
        include:    引入其他文件来验证
    模块路径： 
        直接写文件名就可以

配置文件样例
---------------------------------------------------------

.. code-block:: bash

    [root@localhost ~]# cd /etc/pam.d/
    [root@localhost pam.d]# cat login 
    #%PAM-1.0
    auth [user_unknown=ignore success=ok ignore=ignore default=bad] pam_securetty.so
    auth       substack     system-auth
    auth       include      postlogin
    account    required     pam_nologin.so
    account    include      system-auth
    password   include      system-auth
    # pam_selinux.so close should be the first session rule
    session    required     pam_selinux.so close
    session    required     pam_loginuid.so
    session    optional     pam_console.so
    # pam_selinux.so open should only be followed by sessions to be executed in the user context
    session    required     pam_selinux.so open
    session    required     pam_namespace.so
    session    optional     pam_keyinit.so force revoke
    session    include      system-auth
    session    include      postlogin
    -session   optional     pam_ck_connector.so

.. note:: 在pam.d目录下文件可以不写service的，service就是文件名，文件名不用conf结尾。


常用pam模块
------------------------------------------------------------------------

pam_access 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
模块主要用于访问管理。 它提供了基于登录名，主机或域名，互联网地址或网络号码的logdaemon样式登录访问控制，或者在非联网登录的情况下提供终端线路名称。

pam_cracklib
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
提供密码强壮性检查。

pam_debug
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
旨在作为调试助手来确定PAM堆栈的运行方式。

pam_deny
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
用于设置拒绝访问

pam_echo
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
用于打印文本消息以通知用户关于特殊事物的信息。

pam_env 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
允许设置环境环境变量

pam_exec
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
执行一个外部命令

pam_faildelay 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
可用于设置每个应用程序发生故障时的延迟。

pam_filter
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
旨在成为提供对用户和应用程序之间传递的所有输入/输出进行访问的平台。 它只适用于基于tty和（stdin / stdout）的应用程序。

pam_ftp
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ftp匿名访问插件

pam_group
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
不会对用户进行身份验证，而是会向用户授予组成员资格（在身份验证模块的凭证设置阶段）

pam_issue
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
提示信息

pam_keyinit 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
确保调用进程具有用户默认会话密钥环以外的会话密钥环

pam_lastlog 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
显示上一次登陆信息

pam_limits
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
资源限制

pam_listfile 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
它提供了一种拒绝或允许基于任意文件的服务的方法。

pam_localuser
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
用于帮助实施站点范围的登录策略，通常包括网络用户的子集和一些特定工作站本地的帐户。

pam_loginuid
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
为通过身份验证的进程设置loginuid进程属性。

pam_mail
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
提供提示你有新邮件功能

pam_mkhomedir
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
如果会话开始时不存在，则pam_mkhomedir PAM模块将创建用户主目录

pam_motd 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
显示motd文件信息

pam_namespace 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
为具有多实例目录的会话设置私有名称空间。多实例目录根据用户名或者使用SELinux，用户名，安全上下文或两者时提供了一个不同的自身实例。

pam_nologin
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
阻止非root用户登陆

pam_permit 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
一个始终允许访问的PAM模块

pam_pwhistory
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
保存每个用户的最后密码以强制密码更改历史记录，并防止用户频繁地在相同密码之间交替。

pam_rhosts
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
授权.rhost文件认证

pam_rootok
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
用于在用户的UID为0时对用户进行身份验证

pam_securetty
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
限制root登陆的设备

pam_selinux 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
设置默认的selinux策略

pam_shells
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
检查有效shell

pam_succeed_if
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
旨在根据属于被验证用户的帐户的特性或其他PAM项目的值，验证成功或失败。

pam_tally
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
保持尝试访问的次数，可以重置计数成功，如果尝试失败太多，可以拒绝访问。

pam_tally2
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
pam_tally改进版本

pam_time
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
基于时间的访问控制

pam_timestamp
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
缓存成功的身份验证尝试，并允许您使用最近的成功尝试作为身份验证的基础。

pam_umask
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
设置umask的

pam_unix
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
传统的密码认证

pam_userdb
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
认证用户通过数据库(db)

pam_warn
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
不影响认证过程，只是记录下

pam_wheel
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
用于执行所谓的轮组。 默认情况下，如果申请人用户是wheel组的成员，它允许root权限访问系统。 
如果不存在具有此名称的组，则该模块正在使用组ID为0的组。

pam_xauth
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
用于在用户之间转发xauth密钥（有时称为“cookie”）
