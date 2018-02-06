ftp基于文件的验证
==========================================

安装vsftpd
--------------------------------------------------------

.. code-block:: bash

    [root@centos-7 vsftpd]$yum install vsftpd
    [root@centos-7 vsftpd]$yum install libdb-utils

制作db文件
--------------------------------------------------------

.. code-block:: bash

    root@centos-7 certs]$cd /etc/vsftpd/
    # 用户一行是用户一行是密码。
    [root@centos-7 vsftpd]$vim dbusers.txt 
    [root@centos-7 vsftpd]$cat dbusers.txt 
    panda1
    p1
    panda2
    p2
    panda3
    p3
    [root@centos-7 vsftpd]$db_load -T -t hash -f dbusers.txt  dbusers.db
    [root@centos-7 vsftpd]$ll
    total 32
    -rw-r--r--. 1 root root 12288 Feb  3 18:29 dbusers.db
    -rw-r--r--. 1 root root    21 Feb  3 18:29 dbusers.txt
    -rw-------. 1 root root   125 Aug  3  2017 ftpusers
    -rw-------. 1 root root   361 Aug  3  2017 user_list
    -rw-------. 1 root root  5214 Feb  3 18:27 vsftpd.conf
    -rwxr--r--. 1 root root   338 Aug  3  2017 vsftpd_conf_migrate.sh
    [root@centos-7 vsftpd]$chmod 600 dbusers.*

添加虚拟映射用户
--------------------------------------------------------

.. code-block:: bash

    [root@centos-7 vsftpd]$useradd -d /data/dbuser -s /sbin/nologin dbuser
    [root@centos-7 vsftpd]$chmod a-w /data/dbuser/
    [root@centos-7 vsftpd]$mkdir /data/dbuser/{pub,upload}
    [root@centos-7 vsftpd]$setfacl -m u:dbuser:rwx /data/dbuser/dupload
    setfacl: /data/dbuser/dupload: No such file or directory
    [root@centos-7 vsftpd]$setfacl -m u:dbuser:rwx /data/dbuser/upload
    [root@centos-7 vsftpd]$setfacl -m u:dbuser:rx /data/dbuser/pub

编辑配置文件
--------------------------------------------------------

添加pam配置文件

.. code-block:: bash

    [root@centos-7 vsftpd]$vim /etc/pam.d/vsftpd.db
    [root@centos-7 vsftpd]$cat /etc/pam.d/vsftpd.db
    auth required pam_userdb.so db=/etc/vsftpd/dbusers 
    account required pam_userdb.so db=/etc/vsftpd/dbusers

vsftpd配置文件

.. code-block:: bash

    [root@centos-7 vsftpd]$vim vsftpd.conf 
    # 添加如下3行
    pam_service_name=vsftpd.db
    guest_enable=YES
    guest_username=dbuser

测试
--------------------------------------------------------

重启服务

.. code-block:: bash

    [root@centos-7 vsftpd]$systemctl restart vsftpd

虚拟用户登陆

.. code-block:: bash

    [root@centos-7 vsftpd]$ftp 172.18.46.7
    Connected to 172.18.46.7 (172.18.46.7).
    220 (vsFTPd 3.0.2)
    Name (172.18.46.7:root): panda1
    331 Please specify the password.
    Password:
    230 Login successful.
    Remote system type is UNIX.
    Using binary mode to transfer files.
    ftp> quit
    221 Goodbye.

用户单独配置
--------------------------------------------------------

编辑配置文件

.. code-block:: bash

    [root@centos-7 vsftpd]$vim vsftpd.conf 
    # 添加下面一行
    user_config_dir=/etc/vsftpd/dbuser.conf.d

    [root@centos-7 vsftpd]$mkdir /etc/vsftpd/dbuser.conf.d
    [root@centos-7 vsftpd]$cd /etc/vsftpd/dbuser.conf.d
    [root@centos-7 dbuser.conf.d]$vim panda1
    [root@centos-7 dbuser.conf.d]$cat panda1 
    anon_upload_enable=YES
    anon_mkdir_write_enable=YES

重启服务

.. code-block:: bash

    [root@centos-7 dbuser.conf.d]$systemctl restart vsftpd

测试panda1用户

.. code-block:: bash

    [root@centos-7 dbuser.conf.d]$ftp 172.18.46.7
    Connected to 172.18.46.7 (172.18.46.7).
    220 (vsFTPd 3.0.2)
    Name (172.18.46.7:root): panda1
    331 Please specify the password.
    Password:
    230 Login successful.
    Remote system type is UNIX.
    Using binary mode to transfer files.
    ftp> ls
    227 Entering Passive Mode (172,18,46,7,56,108).
    150 Here comes the directory listing.
    drwxr-xr-x    2 0        0            4096 Feb 03 10:57 pub
    drwxrwxr-x    2 0        0            4096 Feb 03 10:57 upload
    226 Directory send OK.
    ftp> cd upload
    250 Directory successfully changed.
    ftp> !ls
    panda1
    ftp> !lcd /root
    +bash: lcd: command not found
    ftp> lcd /root
    Local directory now /root
    ftp> !ls
    11.txt	11.txt.gpg  1gb.file  20-nproc.conf  abc.awk  anaconda-ks.cfg  app  a.txt  bin	centos74.magedu.com.txt  Desktop  Documents  Downloads	file1  file2  Music  Pictures  Public  Templates  test.sh  test.txt  usr  Videos
    ftp> put 11.txt
    local: 11.txt remote: 11.txt
    227 Entering Passive Mode (172,18,46,7,28,173).
    150 Ok to send data.
    226 Transfer complete.
    4 bytes sent in 0.0351 secs (0.11 Kbytes/sec)
    ftp> quit
    221 Goodbye.

测试panda1用户

.. code-block:: bash

    [root@centos-7 dbuser.conf.d]$ftp 172.18.46.7
    Connected to 172.18.46.7 (172.18.46.7).
    220 (vsFTPd 3.0.2)
    Name (172.18.46.7:root): panda2
    331 Please specify the password.
    Password:
    230 Login successful.
    Remote system type is UNIX.
    Using binary mode to transfer files.
    ftp> cd upload
    250 Directory successfully changed.
    ftp> lcd /root
    Local directory now /root
    ftp> !ls
    11.txt	11.txt.gpg  1gb.file  20-nproc.conf  abc.awk  anaconda-ks.cfg  app  a.txt  bin	centos74.magedu.com.txt  Desktop  Documents  Downloads	file1  file2  Music  Pictures  Public  Templates  test.sh  test.txt  usr  Videos
    ftp> put 11.txt
    local: 11.txt remote: 11.txt
    227 Entering Passive Mode (172,18,46,7,23,214).
    550 Permission denied.
    ftp> quit
    221 Goodbye.

可以看出来，panda1是因为有了特定的配置就具有了上传权限，panda2没有特定的配置，使用默认的配置没有上传权限。
