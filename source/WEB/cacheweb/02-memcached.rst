memcached
=====================================


memcached安装
--------------------------------

.. code-block:: bash 

    [root@centos-151 ~]# yum install memcached 
    [root@centos-151 ~]# cat /etc/sysconfig/memcached 
    [root@centos-151 ~]# man memcached
    [root@centos-151 ~]# systemctl restart memcached
    [root@centos-151 ~]# ss -tunl |grep 11211
    udp    UNCONN     0      0         *:11211                 *:*                  
    udp    UNCONN     0      0        :::11211                :::*                  
    tcp    LISTEN     0      128       *:11211                 *:*                  
    tcp    LISTEN     0      128      :::11211                :::*                  


memcached主要样例
--------------------------------

.. code-block:: bash

    # 使用telnet连上去11211
    [root@centos-151 ~]# telnet 127.0.0.1 11211
    Trying 127.0.0.1...
    Connected to 127.0.0.1.
    Escape character is '^]'.
    # 获取状态信息
    stats 
    STAT pid 35307
    STAT uptime 397
    STAT time 1522544989
    STAT version 1.4.15
    STAT libevent 2.0.21-stable
    STAT pointer_size 64
    STAT rusage_user 0.008725
    STAT rusage_system 0.017451
    STAT curr_connections 10
    STAT total_connections 11
    STAT connection_structures 11
    STAT reserved_fds 20
    STAT cmd_get 0
    STAT cmd_set 0
    STAT cmd_flush 0
    STAT cmd_touch 0
    STAT get_hits 0
    STAT get_misses 0
    STAT delete_misses 0
    STAT delete_hits 0
    STAT incr_misses 0
    STAT incr_hits 0
    STAT decr_misses 0
    STAT decr_hits 0
    STAT cas_misses 0
    STAT cas_hits 0
    STAT cas_badval 0
    STAT touch_hits 0
    STAT touch_misses 0
    STAT auth_cmds 0
    STAT auth_errors 0
    STAT bytes_read 8
    STAT bytes_written 0
    STAT limit_maxbytes 67108864
    STAT accepting_conns 1
    STAT listen_disabled_num 0
    STAT threads 4
    STAT conn_yields 0
    STAT hash_power_level 16
    STAT hash_bytes 524288
    STAT hash_is_expanding 0
    STAT bytes 0
    STAT curr_items 0
    STAT total_items 0
    STAT expired_unfetched 0
    STAT evicted_unfetched 0
    STAT evictions 0
    STAT reclaimed 0
    END

    # 添加key
    add mykey 0 60 9  
    ilinux.io
    STORED
    # 获取value
    get mykey
    VALUE mykey 0 9
    ilinux.io
    END

    # 手工启动memcached
    [root@centos-151 ~]# memcached -u memcached -m 128 -vvv
    slab class   1: chunk size        96 perslab   10922
    slab class   2: chunk size       120 perslab    8738
    slab class   3: chunk size       152 perslab    6898
    slab class   4: chunk size       192 perslab    5461
    slab class   5: chunk size       240 perslab    4369
    slab class   6: chunk size       304 perslab    3449
    slab class   7: chunk size       384 perslab    2730
    slab class   8: chunk size       480 perslab    2184
    slab class   9: chunk size       600 perslab    1747
    slab class  10: chunk size       752 perslab    1394
    slab class  11: chunk size       944 perslab    1110
    slab class  12: chunk size      1184 perslab     885
    slab class  13: chunk size      1480 perslab     708
    slab class  14: chunk size      1856 perslab     564
    slab class  15: chunk size      2320 perslab     451
    slab class  16: chunk size      2904 perslab     361
    slab class  17: chunk size      3632 perslab     288
    slab class  18: chunk size      4544 perslab     230
    slab class  19: chunk size      5680 perslab     184
    slab class  20: chunk size      7104 perslab     147
    slab class  21: chunk size      8880 perslab     118
    slab class  22: chunk size     11104 perslab      94
    slab class  23: chunk size     13880 perslab      75
    slab class  24: chunk size     17352 perslab      60
    slab class  25: chunk size     21696 perslab      48
    slab class  26: chunk size     27120 perslab      38
    slab class  27: chunk size     33904 perslab      30
    slab class  28: chunk size     42384 perslab      24
    slab class  29: chunk size     52984 perslab      19
    slab class  30: chunk size     66232 perslab      15
    slab class  31: chunk size     82792 perslab      12
    slab class  32: chunk size    103496 perslab      10
    slab class  33: chunk size    129376 perslab       8
    slab class  34: chunk size    161720 perslab       6
    slab class  35: chunk size    202152 perslab       5
    slab class  36: chunk size    252696 perslab       4
    slab class  37: chunk size    315872 perslab       3
    slab class  38: chunk size    394840 perslab       2
    slab class  39: chunk size    493552 perslab       2
    slab class  40: chunk size    616944 perslab       1
    slab class  41: chunk size    771184 perslab       1
    slab class  42: chunk size   1048576 perslab       1
    <26 server listening (auto-negotiate)
    <27 server listening (auto-negotiate)
    <28 send buffer was 212992, now 268435456
    <29 send buffer was 212992, now 268435456
    <28 server listening (udp)
    <29 server listening (udp)
    <28 server listening (udp)
    <29 server listening (udp)
    <28 server listening (udp)
    <29 server listening (udp)
    <28 server listening (udp)
    <29 server listening (udp)

