ldap
=================================================================

ldap简介
----------------------------------------------


ldap名词
----------------------------------------------



选择一个域名
----------------------------------------------

这里我的主机已经有个域名为sonar.aibeike.com 了。 这里就不修改了。 如果你的主机没有可以配置为ldap.aibeike.com。

.. code-block:: bash 

    vim /etc/hosts 
    127.0.0.1 localhost sonar.aibeike.com 
    ping sonar.aibeike.com

安装 OpenLDAP 服务端
----------------------------------------------

.. code-block:: bash 

    yum -y openldap-servers openldap-clients
    cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
    chown ldap.ldap /var/lib/ldap/DB_CONFIG
    systemctl start slapd
    systemctl enable slapd

设置ldap的管理员用户root的密码
----------------------------------------------

.. code-block:: bash 

    [root@ldap ~]# slappasswd
    New password:
    Re-enter new password:
    {SSHA}xxxxxxxxxxxxxxxxxxxxxxxx

    vim chrootpw.ldif
    # 内容如下4行,其中最后一行为上面设定的值
    dn: olcDatabase={0}config,cn=config
    changetype: modify
    add: olcRootPW
    olcRootPW: {SSHA}xxxxxxxxxxxxxxxxxxxxxxxx

    # 导入
    [root@ldap ~]# ldapadd -Y EXTERNAL -H ldapi:/// -f chrootpw.ldif
    SASL/EXTERNAL authentication started
    SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
    SASL SSF: 0
    modifying entry "olcDatabase={0}config,cn=config"

添加基础的schema
----------------------------------------------

.. code-block:: bash

    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

设置根域和数据库超级管理员
----------------------------------------------

这里的“根域”可以和这台服务器 FQDN 中的根域不同，此处我们设置为 dc=aibeike,dc=com。

数据库管理员和上面设置过的 OpenLDAP 超级管理员并非同一管理员，而且这里设置的管理员目前尚未创建。此处的设置同样需要一个用 slappasswd 命令生成的密码，为了方便管理，我们使用刚刚生成的密码，不再重新生成。

.. code-block:: bash 

    vim domain-dbadmin.ldif
    # 添加如下内容
    dn: olcDatabase={1}monitor,cn=config
    changetype: modify
    replace: olcAccess
    olcAccess: {0}to *
    by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" read
    by dn.base="cn=admin,dc=aibeike,dc=com" read
    by * none

    dn: olcDatabase={2}hdb,cn=config
    changetype: modify
    replace: olcSuffix
    olcSuffix: dc=aibeike,dc=com

    dn: olcDatabase={2}hdb,cn=config
    changetype: modify
    replace: olcRootDN
    olcRootDN: cn=admin,dc=aibeike,dc=com

    dn: olcDatabase={2}hdb,cn=config
    changetype: modify
    add: olcRootPW
    olcRootPW: {SSHA}xxxxxxxxxxxxxxxxxxxxxxxx

    dn: olcDatabase={2}hdb,cn=config
    changetype: modify
    add: olcAccess
    olcAccess: {0}to attrs=userPassword,shadowLastChange
    by dn="cn=admin,dc=aibeike,dc=com" write
    by anonymous auth
    by self write
    by * none
    olcAccess: {1}to dn.base=""
    by * read
    olcAccess: {2}to *
    by dn="cn=admin,dc=aibeike,dc=com" write
    by * read


    # 导入
    ldapmodify -Y EXTERNAL -H ldapi:/// -f domain-dbadmin.ldif

创建用户节点、组节点和数据库超级管理员
--------------------------------------------

    vim basedomain.ldif
    # 内容如下
    dn: dc=aibeike,dc=com
    objectClass: top
    objectClass: dcObject
    objectclass: organization
    o: Example Inc.
    dc: aibeike

    dn: ou=user,dc=aibeike,dc=com
    objectClass: organizationalUnit
    ou: user

    dn: ou=group,dc=aibeike,dc=com
    objectClass: organizationalUnit
    ou: group

    dn: cn=admin,dc=aibeike,dc=com
    objectClass: organizationalRole
    cn: admin
    description: Directory Administrator

    # 导入，需要输入数据库超级管理员的密码
    ldapadd -x -D cn=admin,dc=aibeike,dc=com -W -f basedomain.ldif
    Enter LDAP Password:


防火墙设置
--------------------------------------------

.. code-block:: bash 

    firewall-cmd --add-service=ldap --permanent
    success
    firewall-cmd --reload

    # 或者禁用
    systemctl stop firewalld
    systemctl disable firewalld

配置log
------------------------------

.. code-block:: bash 

    vim log.ldif 
    # 添加如下4行
    dn: cn=config
    changetype: modify
    add: olcLogLevel
    olcLogLevel: 32

    # 导入
    ldapmodify -Y EXTERNAL -H ldapi:/// -f log.ldif

    mkdir -p /var/log/slapd
    chown ldap:ldap /var/log/slapd/
    echo "local4.* /var/log/slapd/slapd.log" >> /etc/rsyslog.conf
    systemctl restart rsyslog
    systemctl restart slapd 
    # 查看
    tail -n 4 /var/log/slapd/slapd.log 

使用ldapadmin连接
--------------------------------

.. image:: /images/ladp/连接ldap.png

.. image:: /images/ladp/主页ldap.png






常用查询命令
-----------------------------------------

.. code-block:: bash 

    ldapsearch  -LLL -W -x -H ldap://sonar.aibeike.com -D"cn=admin,dc=aibeike,dc=com" -b "dc=aibeike,dc=com"      
    Enter LDAP Password: 
    dn: dc=aibeike,dc=com
    objectClass: top
    objectClass: dcObject
    objectClass: organization
    o: Example Inc.
    dc: aibeike

    dn: ou=user,dc=aibeike,dc=com
    objectClass: organizationalUnit
    ou: user

    dn: ou=group,dc=aibeike,dc=com
    objectClass: organizationalUnit
    ou: group

    dn: cn=admin,dc=aibeike,dc=com
    objectClass: organizationalRole
    cn: admin
    description: Directory Administrator

    ldapsearch  -LLL -wxxxxxxxxxxx -x -H ldap://sonar.aibeike.com -D"cn=admin,dc=aibeike,dc=com" -b "dc=aibeike,dc=com" "(uid=*)" 

    # 查询特定用户
    ldapsearch  -LLL -W -x -H "ldap://sonar.aibeike.com" -D "cn=admin,dc=aibeike,dc=com" -b "dc=aibeike,dc=com"  "(uid=test4)"

    # 备份
    ldapsearch  -LLL -W -x -H "ldap://sonar.aibeike.com" -D "cn=admin,dc=aibeike,dc=com" -b "dc=aibeike,dc=com"  >/root/ldap.bak