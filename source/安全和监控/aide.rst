aide
=================================================================

aide简介
-----------------------------------------------------------

AIDE(Adevanced Intrusion Detection Environment,高级入侵检测环境)是个入侵检测工具，主要用途是检查文本的完整性。　

AIDE能够构造一个指定文档的数据库，他使用aide.conf作为其配置文档。AIDE数据库能够保存文档的各种属性，包括：权限(permission)、
索引节点序号(inode number)、所属用户(user)、所属用户组(group)、文档大小、最后修改时间(mtime)、创建时间(ctime)、最后访问时
间(atime)、增加的大小连同连接数。AIDE还能够使用下列算法：sha1、md5、rmd160、tiger，以密文形式建立每个文档的校验码或散列号。

aide的安装
------------------------------------------------------------------

.. code-block:: bash

    [root@centos74 aide]$ yum install aide

aide的配置
------------------------------------------------------------------

.. code-block:: bash

    [root@centos74 aide]$ vim /etc/aide.conf
    这行后面的都删除， 我这里只关注boot目录的变换情况
    /boot/   CONTENT_EX

初始化
------------------------------------------------------------------

.. code-block:: bash

    [root@centos74 aide]$ aide --init

模拟文件变化
------------------------------------------------------------------

.. code-block:: bash

    [root@centos74 boot]$ touch t1 >>/boot/t1.txt
    [root@centos74 boot]$ mkdir t2

检查信息
------------------------------------------------------------------

.. code-block:: bash

    [root@centos74 boot]$ cd /var/lib/aide/
    [root@centos74 aide]$ mv aide.db.new.gz aide.db.gz
    [root@centos74 aide]$ aide --check
    AIDE 0.15.1 found differences between database and filesystem!!
    Start timestamp: 2018-01-08 18:45:46

    Summary:
    Total number of files:      321
    Added files:                        2
    Removed files:              0
    Changed files:              0
    ---------------------------------------------------
    Added files:
    ---------------------------------------------------

    added: /boot/t1.txt
    added: /boot/t2