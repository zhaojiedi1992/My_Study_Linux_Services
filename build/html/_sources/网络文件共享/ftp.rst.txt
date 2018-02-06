ftp
================================

ftp安装
------------------------------------

.. code-block:: bash

    [root@centos-7 ~]$yum install vsftpd

ftp的配置项
---------------------------------------

布尔选项
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. csv-table:: 
   :header: "名称","默认值","描述"
   :widths: 30,30,50

   "allow_annon_ssl","NO","匿名用户被允许使用安装的ssl连接，需要ssl_enable启用"
   "anon_mkdir_write_enable","NO","匿名用户被允许在一定条件下创建新目录，需要write_enable启用，且匿名ftp用户对父目录有写权限"
   "anon_other_write_anble","NO","匿名用于被允许写入和创建目录，删除其他用户上传的文件"
   "anon_upload_enable","NO","匿名用户将被运行上传文件，需要write_enable激活，且在指定目录有写权限"
   "anon_world_readable_only","YES","匿名用户只能下载所有人都能读取的文件"
   "anonmous_enable","YES","是否启用匿名用户"
   "ascii_download_enable","NO","启用文本模式下载"
   "ascii_upload_enable","NO","启用文本模式上传"
   "async_abor_enable","NO","异步abor命令启用"
   "background","YES","启用后vsftpd是监听模式"
    "check_shell","YES","是使用pam_shell模块，只有在/etc/shells中指定的shell类型用户才能登陆"
    "chmod_enable","YES","运行使用SITE chmod命令，只适用于本地用户"
    "chown_uploads","No","如果启用，所有匿名上传的文件将编程chown_username所有者"
    "chroot_list_enable","NO","默认是列表文件是/etc/vsftpd/chroot_list,可以使用chroot_list_file重写"
    "chroot_local_user","yes","本地用户被禁锢在自己的家目录"
    "connect_from_port_20","NO","主动模式启用20端口来数据连接，可以配合其他命令修改20端口"
    "debug_ssl","NO","将openssl的诊断信息写到日志文件去"
    "delete_failed_uploads","NO","任何上传失败的文件被删除"
    "deny_email_enable","NO","拒绝登陆的电子邮件恢复，默认列表是/etc/vsftpd/banned_emails,可以使用banned_email_file覆盖设置"
    "dirlist_enable","YES","如果设置no,所有目录列表命令被拒绝"
    "dirmessage_enable","no","如果启用,进入目录扫描目录.message内容给用户显示"
    "download_enable","Yes","如果设置为NO,下载请求都被拒绝"
    "dual_log_enable","no","如果yes,两种风格日志都写,/var/log/xferlog和/var/log/vsftpd.log"
    "force_dot_file","NO","如果激活，目录列表不显示..,.这些内容"
    "force_annon_data_ssl","NO","只有ssl_enable启用的时候，所有匿名用户必须使用ssl数据传输"
    "force_anon_logins_ssl","NO","你有ssl_enable启用的时候，匿名用户强制使用登陆"
    "force_local_data_ssl","YES","只有ssl_enable启用的时候，本地用户数据传输使用ssl数据传输"
    "force_local_logins_ssl","YES","你有ssl_enable启用的时候，本地用户强制使用登陆"
    "guest_enable","NO","如果启用，将所有非匿名用户归为来宾，映射为guest_username用户"
    "hide_ids","NO","如果启用，目录列表的所有用户和组信息显示为ftp"
    "implicit_ssl","NO","如果启用，ssl握手第一件事情是希望所有连接支持ssl"
    "listen_ipv6","NO","监听ipv6地址，和ipv4互斥的"
    "local_enable","No","控制本地用户是否能登陆"
    "lock_upload_files","yes","启用后，所有上传者对上传文件写锁，所有下载者对下载文件共享读锁"
    "log_ftp_protocol","no","启用后，所有ftp请求和响应记录日志记录，非常有用的调试选项"
    "ls_recurse_enable","no","启用ls -R命令，来递归访问你的目录"
    "mdtm_write","YES","该设置允许使用MDTM设置文件的修改时间"
    "no_anon_password","NO","匿名用户将直接登陆"
    "no_log_lock","no","当启用时，可以方式vsftpd的从写日志文件采取文件锁定"
    "one_process_model","NO","每个连接一个进程安全模式"
    "password_chroot_enable","no","如果启用，根据chroot_local_user，然后根据/etc/passwd的家目录来限制"
    "pasv_addr_resolve","NO","如果使用主机名，设置YES"  
    "pasv_enable","YES","支持被动模式"  
    "pasv_promiscuous","yes","设置yes禁用安全检查" 
    "require_cert","no","如果启用，所有客户端需要提供客户端证书"  
    "require_ssl_reuse","YES","要求ssl会话重用"  
    "reverse_lookup_enable","yes","方向查找，将ip转为主机名"
    "run_as_launching_user","No",""
    "secure_email_list_enable","NO",""
    "session_support","no","会话支持，保持会话"
    "set_proctitle_enable","No","如果启用，将尝试和显示系统进程列表中的会话状态信息"  
    "ssl_enable","NO","设置yes，启用ssl"   
    "ssl_request_cert","YES","如果启用"
    "ssl_sslv2","No","只有ssl_enable启用，启用此项，允许sslv2协议"
    "ssl_sslv3","NO","只有ssl_enable启用，启用此项，允许sslv3协议"
    "ssl_tlsv1","YES","只有ssl_enable启用，启用此项，允许TLSV1协议"
    "strict_ssl_read_eof","NO","如果启用，需要ssl数据上传通过ssl终止，而不是eof终止"
    "strict_ssl_write_shutdown","NO","如果启用，需要ssl下载通过ssl终止，"
    "syslog_enable","NO","如果启用，使用系统日志来代替/var/log/vsftpd.log"
    "text_userdb_names","NO","默认情况下数字id显示目录列表的用户和组字段，开启这个参数得到文本"
    "tilde_user","NO","如果启用，解析路径带有~username这样的路径"
    "use_localtime","NO","启用后使用本地时区信息，默认是utc时间的"
    "use_sendfile","YES","减少内核和应用数据交换"
    "userlist_deny","YES","如果userlist_enable是激活的，userlist_file是拒绝用户的"
    "userlist_enable","NO","如果启用，userlist_file中的用户能登陆"
    "validate_cert","NO","收到的所有ssl客户端证书必须验证确定"
    "userlist_log","NO","如果userlist_enable启用了，可以uselist_log记录失败登陆"
    "virtual_use_local_privs","NO","如果启用，虚拟用户将是哦那个相同的权限作为本地用户"
    "write_enable","NO","写权限启用"
    "xferlog_enable","NO","如果启用，文件被防止到/var/log/vsftpd.log,可以使用vsftpd_log_file来覆盖"
    "xferlog_std_format","YES","如果启用，日志文件是哦那个标准的xferlog格式记录，可以修改xferlog_file来修改日志位置，默认是/var/log/xferlog"
    "isoate_network","YES","如果启用使用clone_newnet隔离不可信进程"


数值选项
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. csv-table:: 
   :header: "名称","默认值","描述"
   :widths: 30,30,50

    "accpet_timeout","60","超时时间，客户端建立被动数据连接的超时时间"
    "anon_max_rate","0","匿名客户端的最大速率"
    "anon_umask","077","匿名用户创建危机的umask"
    "chmod_upload_mode","0600","修改上传文件的mode"
    "connect_timeout","60","客户端相应主动连接的数据连接超时时间"
    "data_connection_timeout","300","数据传输的连接超时时间"
    "delay_failed_login","1","报告登陆失败秒数"
    "delay_successful_log","0","报告登陆成功的描述"
    "file_open_mode","0666",""
    "ftp_data_port","20","指定主动模式的连接端口，需要connect_form_port_20启用"
    "idle_session_timeout","300","空闲会话超时时间"
    "listen_port","21","监听端口"
    "local_max_rate","0","本地最大速率"
    "local_umask","077","本地用户的umask设置"
    "max_clients","2000","支持的最大客户端个数"
    "max_login_fails","3","登陆的失败的最大次数，超过次数被杀掉"
    "max_per_ip","50","每个ip最大连接个数"
    "pasv_max_port","0","被动模式的最大端口"
    "pasv_min_port","0","被动模式的最小端口"
    "trans_chunk_size","0","传输chunck大小"

字符串选项
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. csv-table:: 
   :header: "名称","默认值","描述"
   :widths: 30,30,50

    "anon_root","-","表示一个目录，匿名用户登陆后的根目录"
    "banned_email_file","/etc/vsftpd/banned_emails","不允许匿名的电子邮件文件路径，需要deny_email_enable启用"
    "banner_file","-","欢迎文件路径"
    "ca_certs_file","-","ca证书文件"
    "chown_username","root","匿名用户上传的所有者的用户名称，需要chown_uploads配合"
    "chown_list_file","/etc/vsftpd.conf/vsftpd.chroot_list",""
    "cmds_allowed","-","指定ftp使用的命令"
    "cmds_denied","-","不能使用的ftp命令，allowed优先"
    "deny_file","-","设置文件名或者目录名不能任何方式访问"
    "dsa_cert_file","-","dsa证书文件"
    "dsa_private_key_file","-","如果没有指定，使用dsa证书文件"
    "email_password_file","/etc/vsftpd/email_passwords",""
    "ftp_username","ftp","用户的主目录是匿名的根"
    "ftpd_banner","-","ftp的提示信息"
    "guest_username","ftp","来宾映射名字"
    "hide_file","-","指定隐藏文件hide_file = {* MP3，.hidden}"
    "listen_address","-","提供一个地址"
    "listen_address6","-","ip6地址"
    "local_root","-","代表该目录的vsftpd将试图改变成后本地（即非匿名）登录"
    "message_file",".message","需要配合dirmessage_enable配合使用"
    "pam_service_name","ftp","pam名字"
    "pasv_address","-","被动模式地址"
    "rsa_cert_file","/usr/share/ssl/certs/vsftpd.pem","rsa证书文件"
    "ra_private_key_file","-","如果没有指定去rsa-cert_file里面找私钥"
    "secure_chroot_dir","/usr/share/empty",""
    "user_config_dir","-","将用户的配置文件定义到/etc/vsftpd/user_conf文件中"
    "user_sub_token","-","配合虚拟用户使用，自动为每个虚拟用户的主目录，记录模板"
    "userlist_file","/etc/vsftpd/user_list","需要userlist_enable启用"
    "vsftpd_log_file","/var/log/vsftpd.log","日志文件"
    "xferlog_file","/var/log/xferlog","日志文件"


配置样例
----------------------------------------------------------

修改默认端口和被动模式的端口范围
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@centos-7 vsftpd]$vim vsftpd.conf
    # 添加3行
    listen_port=20021
    pasv_max_port=20080
    pasv_min_port=20050
    [root@centos-7 vsftpd]$systemctl restart vsftpd

    # 另一个机器测试
    [root@centos-152 ~]# ftp 172.18.46.7 20021
    Connected to 172.18.46.7 (172.18.46.7).
    220 (vsFTPd 3.0.2)
    Name (172.18.46.7:root): ftp
    331 Please specify the password.
    Password:
    230 Login successful.
    Remote system type is UNIX.
    Using binary mode to transfer files.
    ftp> cd pub
    250 Directory successfully changed.
    ftp> git bigfile 
    ?Invalid command
    ftp> get bigfile
    local: bigfile remote: bigfile
    227 Entering Passive Mode (172,18,46,7,78,83).
    150 Opening BINARY mode data connection for bigfile (1025507328 bytes).
    226 Transfer complete.
    1025507328 bytes received in 7.68 secs (133606.18 Kbytes/sec)
    ftp> quit
    221 Goodbye.

    # 服务端查看
    [root@centos-7 vsftpd]$ss -tun 
    Netid  State      Recv-Q Send-Q                          Local Address:Port                                         Peer Address:Port             
    tcp    ESTAB      0      52                                172.18.46.7:22                                          172.18.101.69:49932            
    tcp    ESTAB      0      0                          ::ffff:172.18.46.7:20021                               ::ffff:172.18.104.253:56238            
    tcp    ESTAB      0      3363872                     ::ffff:172.18.46.7:20051                               ::ffff:172.18.104.253:54037   

映射user1,user2为comm
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

[root@centos-7 vsftpd]$vim vsftpd.conf  

    # 添加如下行
    guest_enable=YES
    guest_username=comm
    local_root=/home/comm
    #这个默认就有，确认下
    local_enable=YES

    # 添加用户
    [root@centos-7 vsftpd]$useradd user1
    [root@centos-7 vsftpd]$useradd user2
    [root@centos-7 vsftpd]$useradd comm
    [root@centos-7 vsftpd]$mkdir /home/comm/pub
    [root@centos-7 vsftpd]$ll -d /var/ftp/pub
    drwxr-xr-x. 3 root root 4096 Feb  3 12:40 /var/ftp/pub
    [root@centos-7 vsftpd]$ll -d /var/ftp
    drwxr-xr-x. 3 root root 4096 Aug  3  2017 /var/ftp
    [root@centos-7 vsftpd]$chmod 555 /home/comm
    [root@centos-7 vsftpd]$chmod 755 /home/comm/pub

    # 测试
    [root@centos-152 ~]# ftp 172.18.46.7 
    Connected to 172.18.46.7 (172.18.46.7).
    220 (vsFTPd 3.0.2)
    Name (172.18.46.7:root): user1
    331 Please specify the password.
    Password:
    230 Login successful.
    Remote system type is UNIX.
    Using binary mode to transfer files.
    ftp> ls
    227 Entering Passive Mode (172,18,46,7,78,94).
    150 Here comes the directory listing.
    drwxr-xr-x    2 1037     0            4096 Feb 03 13:55 pub
    226 Directory send 

禁锢用户只能在自己家目录,但是除了user1
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@centos-7 vsftpd]$!vim
    vim vsftpd.conf     
    [root@centos-7 vsftpd]$tail -n 2 vsftpd.conf
    chroot_list_enable=YES
    chroot_list_file=/etc/vsftpd/chroot_list

    # 添加用户
    [root@centos-7 vsftpd]$vim /etc/vsftpd/chroot_list
    [root@centos-7 vsftpd]$cat /etc/vsftpd/chroot_list
    user1

    # 测试
    [root@centos-152 ~]# ftp 172.18.46.7 
    Connected to 172.18.46.7 (172.18.46.7).
    220 (vsFTPd 3.0.2)
    Name (172.18.46.7:root): user1
    331 Please specify the password.
    Password:
    500 OOPS: vsftpd: refusing to run with writable root inside chroot()
    Login failed.
    421 Service not available, remote server has closed connection
    ftp> ls
    Not connected.
    ftp> quit
    [root@centos-152 ~]# ftp 172.18.46.7 
    Connected to 172.18.46.7 (172.18.46.7).
    220 (vsFTPd 3.0.2)
    Name (172.18.46.7:root): user2
    331 Please specify the password.
    Password:
    230 Login successful.
    Remote system type is UNIX.
    Using binary mode to transfer files.
    ftp> ls
    227 Entering Passive Mode (172,18,46,7,78,89).
    150 Here comes the directory listing.
    226 Directory send OK.
    ftp> pwd
    257 "/home/user2"

这样就可以让在chroot_list文件中的用户禁锢了

禁止系统特定用户登陆ftp
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@centos-7 vsftpd]$echo "user1" >> /etc/vsftpd/user_list

限制每个ip连接的个数为5个，下载速度为100k.最多支持10个连接
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@centos-7 vsftpd]$vim vsftpd.conf
    [root@centos-7 vsftpd]$tail -n 4  vsftpd.conf 
    max_clients=100
    max_per_ip=5
    anon_max_rate=102400

