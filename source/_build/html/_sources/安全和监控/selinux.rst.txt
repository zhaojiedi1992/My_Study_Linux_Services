selinux
========================================

selinux使用委任式访问控制（Mandatory Access Control,MAC）,它可以针对特定的程序
域特定的文件资源来进行权限的管理。

selinux的工作模式
------------------------------------

selinux采用委任式访问控制来管理程序，它控制的主体是程序，目标是文件资源。

主体
    selinux主要管理的是程序
目标
    主体程序访问的目标资源一般就是文件系统
策略
    不同策略有详细的规则来指定不同的服务开放某些资源的访问与否
安全上下文
    主体与目标的安全性环境必须一致才能顺利访问目标

安全性环境
-----------------------------------------------------

.. code-block:: bash 

    [root@centos-150 ~]# ll -Z anaconda-ks.cfg 
    -rw-------. root root system_u:object_r:admin_home_t:s0 anaconda-ks.cfg

安全性环境主要用冒号分割三个字段

.. code-block:: text 

    Identify：role:type
    身份识别:角色:类型

    身份识别： 
        root: 表示root的账号身份
        system_u: 表示系统程序方便的识别，通常是程序。
        user_u: 代表一般用户的相关的身份
    
    角色：
        object_r: 代表的是文件或者目录等文件资源
        system_r: 代表的是程序
    
    类型： 
        一个程序能不能读取到文件资源，主要和类型字段有关。


selinux的启动、关闭和查看
-----------------------------------------------------

selinux有三种模式。

- enforcing: 强制模式
- permissive: 宽容模式
- disabled： 关闭

查看
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    [root@centos-150 ~]# getenforce 
    Disabled

设置
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


.. code-block:: bash 

    [root@centos-150 ~]# setenforce 1

.. note:: setenforce无法在disabled模式切换到其他模式

永久修改
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    [root@centos-150 ~]# vim /etc/sysconfig/selinux 

selinux 类型的修改
-----------------------------------------------------

chcon
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^



restorecon
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


semanage
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


练习_ 

.. _练习: http://linux.linuxpanda.tech/%E7%BB%83%E4%B9%A0%E9%A2%98/2017-12-28-%E7%BB%83%E4%B9%A0selinux.html#selinux