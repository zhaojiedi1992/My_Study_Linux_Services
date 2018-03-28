redis高可用
===============================

redis的高可用使用sentinel实现的， 建议sentinel安装在独立的服务器上。

需要先配置主从的 :ref:`topics-redisslave` 


配置sentinel
-------------------------------------

.. code-block:: bash 

    [root@centos-151 ~]# vim /etc/redis-sentinel.conf 
    # 修改如下3行
    bind 0.0.0.0
    sentinel monitor mymaster 192.168.46.151 6379 2
    sentinel auth-pass  mymaster linuxpanda

    [root@centos-151 ~]# scp /etc/redis-sentinel.conf 192.168.46.152:/etc/
    [root@centos-151 ~]# scp /etc/redis-sentinel.conf 192.168.46.153:/etc/

    [root@centos-151 ~]# systemctl restart redis-sentinel
    [root@centos-152 ~]# systemctl restart redis-sentinel
    [root@centos-153 ~]# systemctl restart redis-sentinel

测试
------------------------------------------------------


.. code-block:: bash 


    [root@centos-151 ~]# redis-cli -p 26379 

    127.0.0.1:26379> sentinel masters
    1)  1) "name"
        2) "mymaster"
        3) "ip"
        4) "192.168.46.151"
        5) "port"
        6) "6379"
        7) "runid"
        8) "817bed45028e27aad78aaf82380041943a2fedb3"
        9) "flags"
    10) "master"
    11) "link-pending-commands"
    12) "0"
    13) "link-refcount"
    14) "1"
    15) "last-ping-sent"
    16) "0"
    17) "last-ok-ping-reply"
    18) "953"
    19) "last-ping-reply"
    20) "953"
    21) "down-after-milliseconds"
    22) "30000"
    23) "info-refresh"
    24) "7374"
    25) "role-reported"
    26) "master"
    27) "role-reported-time"
    28) "338609"
    29) "config-epoch"
    30) "0"
    31) "num-slaves"
    32) "2"
    33) "num-other-sentinels"
    34) "2"
    35) "quorum"
    36) "2"
    37) "failover-timeout"
    38) "180000"
    39) "parallel-syncs"
    40) "1"

    127.0.0.1:26379> sentinel slaves mymaster
    1)  1) "name"
        2) "192.168.46.153:6379"
        3) "ip"
        4) "192.168.46.153"
        5) "port"
        6) "6379"
        7) "runid"
        8) "0d47a46a0297fde064159b79aba7cc6c7937e6ac"
        9) "flags"
    10) "slave"
    11) "link-pending-commands"
    12) "0"
    13) "link-refcount"
    14) "1"
    15) "last-ping-sent"
    16) "0"
    17) "last-ok-ping-reply"
    18) "181"
    19) "last-ping-reply"
    20) "181"
    21) "down-after-milliseconds"
    22) "30000"
    23) "info-refresh"
    24) "8016"
    25) "role-reported"
    26) "slave"
    27) "role-reported-time"
    28) "289131"
    29) "master-link-down-time"
    30) "0"
    31) "master-link-status"
    32) "ok"
    33) "master-host"
    34) "192.168.46.151"
    35) "master-port"
    36) "6379"
    37) "slave-priority"
    38) "100"
    39) "slave-repl-offset"
    40) "57222"
    2)  1) "name"
        2) "192.168.46.152:6379"
        3) "ip"
        4) "192.168.46.152"
        5) "port"
        6) "6379"
        7) "runid"
        8) "6f247282dab66ec3c6d9923ed8e1641a8f26fa26"
        9) "flags"
    10) "slave"
    11) "link-pending-commands"
    12) "0"
    13) "link-refcount"
    14) "1"
    15) "last-ping-sent"
    16) "0"
    17) "last-ok-ping-reply"
    18) "181"
    19) "last-ping-reply"
    20) "181"
    21) "down-after-milliseconds"
    22) "30000"
    23) "info-refresh"
    24) "8016"
    25) "role-reported"
    26) "slave"
    27) "role-reported-time"
    28) "289132"
    29) "master-link-down-time"
    30) "0"
    31) "master-link-status"
    32) "ok"
    33) "master-host"
    34) "192.168.46.151"
    35) "master-port"
    36) "6379"
    37) "slave-priority"
    38) "100"
    39) "slave-repl-offset"
    40) "57222"

模拟破坏
---------------------------------------------------

.. code-block:: bash 

    [root@centos-151 ~]# systemctl stop redis 

查看是否转移 
-----------------------------------------------

.. code-block:: bash

    [root@centos-152 ~]# redis-cli -p 26379
    127.0.0.1:26379> sentinel masters
    1)  1) "name"
        2) "mymaster"
        3) "ip"
        4) "192.168.46.151"
        5) "port"
        6) "6379"
        7) "runid"
        8) "817bed45028e27aad78aaf82380041943a2fedb3"
        9) "flags"
    10) "master,disconnected"
    11) "link-pending-commands"
    12) "2"
    13) "link-refcount"
    14) "1"
    15) "last-ping-sent"
    16) "74034"
    17) "last-ok-ping-reply"
    18) "74131"
    19) "last-ping-reply"
    20) "74131"
    21) "down-after-milliseconds"
    22) "30000"
    23) "info-refresh"
    24) "84056"
    25) "role-reported"
    26) "master"
    27) "role-reported-time"
    28) "435933"
    29) "config-epoch"
    30) "0"
    31) "num-slaves"
    32) "2"
    33) "num-other-sentinels"
    34) "2"
    35) "quorum"
    36) "2"
    37) "failover-timeout"
    38) "180000"
    39) "parallel-syncs"
    40) "1"
    127.0.0.1:26379> sentinel masters
    1)  1) "name"
        2) "mymaster"
        3) "ip"
        4) "192.168.46.153"
        5) "port"
        6) "6379"
        7) "runid"
        8) "0d47a46a0297fde064159b79aba7cc6c7937e6ac"
        9) "flags"
    10) "master"
    11) "link-pending-commands"
    12) "0"
    13) "link-refcount"
    14) "1"
    15) "last-ping-sent"
    16) "0"
    17) "last-ok-ping-reply"
    18) "101"
    19) "last-ping-reply"
    20) "101"
    21) "down-after-milliseconds"
    22) "30000"
    23) "info-refresh"
    24) "4385"
    25) "role-reported"
    26) "master"
    27) "role-reported-time"
    28) "4812"
    29) "config-epoch"
    30) "1"
    31) "num-slaves"
    32) "2"
    33) "num-other-sentinels"
    34) "2"
    35) "quorum"
    36) "2"
    37) "failover-timeout"
    38) "180000"
    39) "parallel-syncs"
    40) "1"

