.. _topics-redisslave:

redis主从配置
==================================


安装和基础配置
-----------------------------------

.. code-block:: bash 

    # 安装
    [root@centos-151 ~]# yum install redis 
    [root@centos-152 ~]# yum install redis 
    [root@centos-153 ~]# yum install redis 

    # 设置监听和密码
    [root@centos-151 ~]# vim /etc/redis.conf 
    # 修改如下2项 
    bind 0.0.0.0
    requirepass linuxpanda

    # 推送给其他客户端
    [root@centos-151 ~]# scp /etc/redis.conf  192.168.46.152:/etc/
    [root@centos-151 ~]# scp /etc/redis.conf  192.168.46.153:/etc/

    # 启动服务
    [root@centos-151 ~]# systemctl restart redis 
    [root@centos-152 ~]# systemctl restart redis 
    [root@centos-153 ~]# systemctl restart redis 

主从配置
-----------------------------------

.. code-block:: bash 

    # 一个从节点设置下主节点关联
    [root@centos-152 ~]# vim /etc/redis.conf 
    # 修改如下2行
    slaveof 192.168.46.151 6379
    masterauth linuxpanda

    # 推送给153主机
    [root@centos-152 ~]# scp /etc/redis.conf  192.168.46.153:/etc/

    # 重启下redis
    [root@centos-152 ~]# systemctl restart redis 
    [root@centos-153 ~]# systemctl restart redis 

测试下
-----------------------------------

.. code-block:: bash 

    root@centos-151 ~]# redis-cli -a linuxpanda
    127.0.0.1:6379> keys * 
    (empty list or set)
    127.0.0.1:6379> set name zhaojiedi
    OK
    127.0.0.1:6379> keys * 
    1) "name"

    [root@centos-152 ~]# redis-cli -a linuxpanda
    127.0.0.1:6379> keys * 
    1) "name"
    [root@centos-153 ~]# redis-cli -a linuxpanda
    127.0.0.1:6379> keys * 
    1) "name"

