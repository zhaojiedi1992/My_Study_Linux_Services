.. _topics-rsync:   

rsync入门
==================================================

rsync简介
------------------------------------------------------------------------

Rsync是一个很棒的小工具，在你的机器上很容易设置。而不是有一个脚本的FTP会话，或其他形式的文件传输脚本  rsync只复制文件的差异，实际上差异就是已经改变的文件，如果你想要的安全可以通过ssh。但它的意思是：

-   区别 - 只传输实际更改的文件，而不是整个文件。这使得更新速度更快，尤其是在像调制解调器这样的慢速链路上。即使只更改了一个字节，FTP也会传输整个文件。
-   压缩 - 差异的细小部分随即进行压缩，进一步节省文件传输时间并减少网络负载。
-   安全外壳 - 你的安全意识就是这样，你应该都使用它。来自rsync的流通过ssh协议来加密会话，而不是rsh，这也是一个选项。

作为备份/镜像工具，rsync是相当通用的，提供了超出上述的许多功能。以下是一些rsync的其他主要功能：

-   支持复制链接，设备，所有者，组和权限
-   排除和排除类似于GNU tar的选项
-   CVS排除模式，用于忽略CVS将忽略的相同文件
-   不需要root权限
-   管理文件传输以最小化延迟成本
-   支持匿名或认证的rsync服务器(理想的镜像)

rsync是如何工作的
------------------------------------------------------------------------

rsync是cs架构的，也就是必须有客户端和服务端的，您必须通过以守护进程模式运行rsync(命令行中的"rsync --daemon")并设置一个简短易用的配置文件（/etc/rsyncd.conf）来将一台或另一台机器设置为"rsync服务器" ）。

任何安装了rsync的机器都可以与运行rsync守护进程的机器同步。您可以使用它来进行备份，镜像文件系统，分发文件或任意数量的类似操作。通过使用只传输文件之间的差异（类似于补丁文件）的"rsync算法"，然后压缩它们 - 您将得到一个非常高效的系统。



rsyncd的主要参数设置
------------------------------------------------------------------------

我们使用一天服务器指定为rsync的服务器，需要运行rsync指定--daemon以守护进程运行并且需要给它提供一个配置文件，这个配置就是、/etc/rsyncd.conf文件。

主要的全局的参数

.. code-block:: text

    motd file                # 这个是欢迎提示信息，指定的是文件名，把内容写到这个文件里面
    pid file                 # 守护进程的运行pid文件
    port                     # 运行端口，默认是873
    address                  # 默认是监听在所有ip上的，有时候我们只需要监听在内部ip上就需要改变这个值

主要的模块参数

.. code-block:: text

    comment              # 注释信息
    path                 # 需要同步的路径，这个参数必须指定的。
    use chroot           # 如果为true，rsync守护进程将在与客户端开始文件传输的时候切换到指定路径运行，提供更高的安全性。
    charset              # 存储文件名的字符集
    max connections      # 指定最大连接数
    log file             # 日志文件路径
    syslog facility      # 运行你指定系统日志工具名称的，默认是daemon,你可以设置其他值，比如auth, authpriv, cron, daemon, ftp, 
                            kern, lpr, mail, news, security, syslog, user, uucp, local0-7.
    max verbosity        # 这个参数是控制日志级别的，数值范围1-4，默认1，越大日志信息越丰富。同步文件夹大的时候，建议设置默认值1，避免日志文件过大。
    lock file            # 锁文件，默认是/var/run/rsyncd.lock.
    read only            # 这个是只读的，默认都是只读的。
    write only           # 这个参数控制客户端是否可以下载的，默认是可以下载的，不建议修改。
    list                 # 此参数确定当客户要求提供可用模块列表时，是否列出此模块
    uid                  # 守护进程以那个用户身份运行
    gid                  # 守护进程以那个用户组运行
    exclude              # 该参数采用空格分隔的守护进程排除模式列表
    include              # 该参数采用空格分隔的守护进程包含模式列表
    exclude from         # 类似exclude，不过需要写到文件里面，每行一个，这个参数写文件名
    include from         # 类似include，不过需要写到文件里面，每行一个，这个参数写文件名
    incoming chmod       # 对进入文件chmod修改权限的
    outgoing chmod       # 对出去的文件chmod修改权限的。
    auth users           # 认证的用户
    secrets file         # 密码文件，配合auth users使用，格式为"username:password" 或者 "@groupname:password"
    strict modes         # 是否检查密码文件的权限，默认值true,适应windows操作系统运行rsync
    hosts allow          # 运行的主机，格式直接也是比较多的。常用格式如下
                            192.168.2.2
                            192.168.2.2/24
                            192.168.2.2/255.255.255.0
                            主机名
    hosts deny           # 不允许的主机
    ignore errors        # 忽略i/o错误
    ignore nonoreadable  # 这告诉rsync守护程序完全忽略用户不可读的文件
    transfer logging     # 这个参数使得每个文件的日志记录下载和上传的格式有点类似于ftp守护进程所使用的格式
    log format           # 日志格式的，特别多，参考https://rsync.samba.org/ftp/rsync/rsyncd.conf.html
    timeout              # 此参数允许您覆盖客户端选择此模块的I / O超时。 使用这个参数你可以确保rsync不会永远等待死客户端，默认600s
    dont compress        # 不压缩
    

样例的配置文件
------------------------------------------------------------------------

.. code-block:: bash

    uid = root
    gid = root
    use chroot = yes
    max connections = 4
    syslog facility = local5
    pid file = /var/run/rsyncd.pid

    [ftp]
            path = /var/ftp/pub
            comment = whole ftp area (approx 6.1 GB)

    [sambaftp]
            path = /var/ftp/./pub/samba
            comment = Samba ftp area (approx 300 MB)

    [rsyncftp]
            path = /var/ftp/./pub/rsync
            comment = rsync ftp area (approx 6 MB)

    [sambawww]
            path = /public_html/samba
            comment = Samba WWW pages (approx 240 MB)

    [cvs]
            path = /data/cvs
            comment = CVS repository (requires authentication)
            auth users = tridge, susan
            secrets file = /etc/rsyncd.secrets

密码文件样例： 

.. code-block:: text

    tridge:mypass
    susan:herpass

.. attention:: 密码文件格式为username:password,且这个用户不必要在系统存在，密码文件权限为600。
