mysql终端入门
==================================================

mysql提示符修改
-----------------------------------------------------

.. code-block:: bash

       [root@iZ2ze640ra8ceysx5817skZ ~]# man mysql # 进入man文档搜索prompt即可找到如下片段内容。
       ┌───────┬──────────────────────────────────────────────────────────┐
       │Option │ Description                                              │
       ├───────┼──────────────────────────────────────────────────────────┤
       │\c     │ A counter that increments for each statement you issue   │
       ├───────┼──────────────────────────────────────────────────────────┤
       │\D     │ The full current date                                    │
       ├───────┼──────────────────────────────────────────────────────────┤
       │\d     │ The default database                                     │
       ├───────┼──────────────────────────────────────────────────────────┤
       │\h     │ The server host                                          │
       ├───────┼──────────────────────────────────────────────────────────┤
       │\l     │ The current delimiter (new in 5.1.12)                    │
       ├───────┼──────────────────────────────────────────────────────────┤
       │\m     │ Minutes of the current time                              │
       ├───────┼──────────────────────────────────────────────────────────┤
       │\n     │ A newline character                                      │
       ├───────┼──────────────────────────────────────────────────────────┤
       │\O     │ The current month in three-letter format (Jan, Feb, ...) │
       ├───────┼──────────────────────────────────────────────────────────┤
       │\o     │ The current month in numeric format                      │
       ├───────┼──────────────────────────────────────────────────────────┤
       │\P     │ am/pm                                                    │
       ├───────┼──────────────────────────────────────────────────────────┤
       │\p     │ The current TCP/IP port or socket file                   │
       ├───────┼──────────────────────────────────────────────────────────┤
       │\R     │ The current time, in 24-hour military time (0–23)        │
       ├───────┼──────────────────────────────────────────────────────────┤
       │\r     │ The current time, standard 12-hour time (1–12)           │
       ├───────┼──────────────────────────────────────────────────────────┤
       │\S     │ Semicolon                                                │
       ├───────┼──────────────────────────────────────────────────────────┤
       │\s     │ Seconds of the current time                              │
       ├───────┼──────────────────────────────────────────────────────────┤
       │\t     │ A tab character                                          │
       ├───────┼──────────────────────────────────────────────────────────┤
       │\U     │                                                          │
       │       │        Your full user_name@host_name account name        │
       ├───────┼──────────────────────────────────────────────────────────┤
       │\u     │ Your user name                                           │
       ├───────┼──────────────────────────────────────────────────────────┤
       │\v     │ The server version                                       │
       ├───────┼──────────────────────────────────────────────────────────┤
       │\w     │ The current day of the week in three-letter format (Mon, │
       │       │ Tue, ...)                                                │
       ├───────┼──────────────────────────────────────────────────────────┤
       │\Y     │ The current year, four digits                            │
       ├───────┼──────────────────────────────────────────────────────────┤
       │\y     │ The current year, two digits                             │
       ├───────┼──────────────────────────────────────────────────────────┤
       │\_     │ A space                                                  │
       ├───────┼──────────────────────────────────────────────────────────┤
       │\      │ A space (a space follows the backslash)                  │
       ├───────┼──────────────────────────────────────────────────────────┤
       │\´     │ Single quote                                             │
       ├───────┼──────────────────────────────────────────────────────────┤
       │\"     │ Double quote                                             │
       ├───────┼──────────────────────────────────────────────────────────┤
       │\\     │ A literal “\” backslash character                        │
       ├───────┼──────────────────────────────────────────────────────────┤
       │\x     │                                                          │
       │       │        x, for any “x” not listed above                   │
       └───────┴──────────────────────────────────────────────────────────┘

       You can set the prompt in several ways:

       ·   Use an environment variable.  You can set the MYSQL_PS1 environment variable to a prompt string. For example:

               shell> export MYSQL_PS1="(\u@\h) [\d]> "

       ·   Use a command-line option.  You can set the --prompt option on the command line to mysql. For example:

               shell> mysql --prompt="(\u@\h) [\d]> "
               (user@host) [database]>

       ·   Use an option file.  You can set the prompt option in the [mysql] group of any MySQL option file, such as /etc/my.cnf or the .my.cnf file in your home directory.
           For example:

               [mysql]
               prompt=(\\u@\\h) [\\d]>\\_

我这里采用永久修改的办法，编辑配置文件方式。

.. code-block:: bash

    [root@iZ2ze640ra8ceysx5817skZ ~]# mysql --prompt="\R:\m:\s (\u@\h)[\d][\c]>" -u root -p
    Enter password: 
    Welcome to the MariaDB monitor.  Commands end with ; or \g.
    Your MariaDB connection id is 426
    Server version: 5.5.56-MariaDB MariaDB Server

    Copyright (c) 2000, 2017, Oracle, MariaDB Corporation Ab and others.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

    10:49:02 (root@localhost)[(none)][1]>use mysql;
    Reading table information for completion of table and column names
    You can turn off this feature to get a quicker startup with -A

    # 写到配置文件中去。
    [root@iZ2ze640ra8ceysx5817skZ ~]# vim /etc/my.cnf.d/mysql-clients.cnf 
    [root@iZ2ze640ra8ceysx5817skZ ~]# cat /etc/my.cnf.d/mysql-clients.cnf
    #
    # These groups are read by MariaDB command-line tools
    # Use it for options that affect only one utility
    #

    [mysql]
    prompt="\\R:\\m:\\s (\u@\h)[\d][\c]>"
    [mysql_upgrade]

    [mysqladmin]

    [mysqlbinlog]

    [mysqlcheck]

    [mysqldump]

    [mysqlimport]

    [mysqlshow]

    [mysqlslap]

    [root@iZ2ze640ra8ceysx5817skZ ~]# !vim
    vim /etc/my.cnf.d/mysql-clients.cnf 
    [root@iZ2ze640ra8ceysx5817skZ ~]# mysql -u root -p
    Enter password: 
    Welcome to the MariaDB monitor.  Commands end with ; or \g.
    Your MariaDB connection id is 429
    Server version: 5.5.56-MariaDB MariaDB Server

    Copyright (c) 2000, 2017, Oracle, MariaDB Corporation Ab and others.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

    10:51:26 (root@localhost)[(none)][1]>use mysql
    Reading table information for completion of table and column names
    You can turn off this feature to get a quicker startup with -A

用户和密码写到配置文件中
-----------------------------------------------------

配置前的连接方式 

.. code-block:: bash

    [root@centos151 init.d]# mysql -u root -p
    Enter password: 
    Welcome to the MariaDB monitor.  Commands end with ; or \g.
    Your MariaDB connection id is 21
    Server version: 10.2.12-MariaDB-log Source distribution

    Copyright (c) 2000, 2017, Oracle, MariaDB Corporation Ab and others.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

    MariaDB [(none)]> quit
    Bye

配置

[root@centos151 init.d]# vim ~/.my.cnf
    # 添加如下行
    [client]
    user=root
    password=oracle

测试

.. code-block:: bash

    [root@centos151 init.d]# mysql
    Welcome to the MariaDB monitor.  Commands end with ; or \g.
    Your MariaDB connection id is 12
    Server version: 10.2.12-MariaDB-log Source distribution

    Copyright (c) 2000, 2017, Oracle, MariaDB Corporation Ab and others.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

    MariaDB [(none)]> 

          