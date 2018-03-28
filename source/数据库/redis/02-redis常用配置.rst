redis常用配置
============================================


配置概述
----------------------------------------------------

.. code-block:: text 

    [root@centos-151 ~]# grep "^####" /etc/redis.conf 
    ################################## INCLUDES ###################################包含其他配置先关
    ################################## NETWORK #####################################网络相关
    ################################# GENERAL #####################################通用相关
    ################################ SNAPSHOTTING  ################################快照先关
    ################################# REPLICATION #################################主从相关
    ################################## SECURITY ###################################安全相关
    ################################### LIMITS ####################################限制相关
    ############################## APPEND ONLY MODE ###############################aof持久化先关
    ################################ LUA SCRIPTING  ###############################lua脚本
    ################################ REDIS CLUSTER  ###############################集群相关
    ################################## SLOW LOG ###################################慢日志
    ################################ LATENCY MONITOR ##############################监控
    ############################# EVENT NOTIFICATION ##############################事件通知
    ############################### ADVANCED CONFIG ###############################高级配置

    通用配置项：
        daemonize, supervised, loglevel, pidfile, logfile, 
        databases：设定数据库数量，默认为16个，每个数据库的名字均为整数，从0开始编号，默认操作的数据库为0；
        切换数据库的方法：SELECT <dbid>
                
    网络配置项：
        bind IP
        port PORT
        protected-mode ，如果没有指定安全和bind配置，且包含模式是yes的话服务启动不起来的
        tcp-backlog      后援队列的大小
        unixsocket 
        timeout：连接的空闲超时时长； 
        
    安全配置：
        requirepass <PASSWORD>   设置密码的，没用用户名只有密码的
        rename-command <COMMAND> <NEW_CMND_NAME>
            在AOF或Replication环境中，不推荐使用；如果在集群中使用，建议统一定义别名，
            
    Limits相关的配置： 
        maxclients    最大客户端数量
        maxmemory <bytes>   redis使用的最大内存空间
        maxmemory-policy noeviction  内存的淘汰策略
            淘汰策略：volatile-lru, allkeys-lru, volatile-random, allkeys-random, volatile-ttl, noeviction
            maxmemory-samples 5
            淘汰算法运行时的采样样本数；
            
    SlowLog相关的配置:
        slowlog-log-slower-than 10000
            单位是微秒；
        slowlog-max-len 128
            SlowLog记录的日志最大条目；
            
    ADVANCED配置：
        hash-max-ziplist-entries 512      
        hash-max-ziplist-value 64	
        
            设置ziplist的键数量最大值，每个值的最大空间，基本默认就可以了。 
        
        client-output-buffer-limit normal 0 0 0
        client-output-buffer-limit slave 256mb 64mb 60    # 正常只能使用64Mb,可以使用到256mb，但是只能持续60s。
        client-output-buffer-limit pubsub 32mb 8mb 60
            <hard-limit>
            <soft-limit>
            <soft-limit seconds>

    Redis的持久化:
    RDB：snapshotting, 二进制格式；按事先定制的策略，周期性地将数据从内存同步至磁盘；数据文件默认为dump.rdb；
        客户端显式使用SAVA或BGSAVE命令来手动启动快照保存机制；
            SAVE：同步，即在主线程中保存快照，此时会阻塞所有客户端请求；
            BGSAVE：异步；
    AOF：Append Only File, fsync
        记录每次写操作至指定的文件尾部实现的持久化；当redis重启时，可通过重新执行文件中的命令在内存中重建出数据库；
            BGREWRITEAOF：AOF文件重写；
                不会读取正在使用AOF文件，而是通过将内存中的数据以命令的方式保存至临时文件中，完成之后替换原来的AOF文件； 
                
    RDB相关的配置：
        *save <seconds> <changes>
        
            save 900 1
            save 300 10
            save 60 10000
            
            表示：三个策略满足其中任意一个均会触发SNAPSHOTTING操作；900s内至少有一个key有变化，300s内至少有10个key有变化，60s内至少有1W个key发生变化；
            
        stop-writes-on-bgsave-error yes
            dump操作出现错误时，是否禁止新的写入操作请求；
            
        rdbcompression yes
        rdbchecksum yes
        
        dbfilename dump.rdb：指定rdb文件名
        *dir /var/lib/redis：rdb文件的存储路径
        
    AOF相关的配置
        *appendonly no
        appendfilename "appendonly.aof"
        
        *appendfsync 
            Redis supports three different modes:
                no：redis不执行主动同步操作，而是OS进行；
                everysec：每秒一次；
                always：每语句一次；
                
        no-appendfsync-on-rewrite no
            是否在后台执行aof重写期间不调用fsync，默认为no，表示调用；
            
        auto-aof-rewrite-percentage 100
        auto-aof-rewrite-min-size 64mb	
            上述两个条件同时满足时，方会触发重写AOF；与上次aof文件大小相比，其增长量超过100%，且大小不少于64MB; 
            
        aof-load-truncated yes
        
    注意：持久机制本身不能取代备份；应该制订备份策略，对redis库定期备份；
    
    RDB与AOF同时启用： 
        (1) BGSAVE和BGREWRITEAOF不会同时进行；
        (2) Redis服务器启动时用持久化的数据文件恢复数据，会优先使用AOF；

    复制：
            特点：
                一个Master可以有多个slave主机，支持链式复制；
                Master以非阻塞方式同步数据至slave主机；
                
            配置slave节点：
                redis-cli> SLAVEOF <MASTER_IP> <MASTER_PORT>
                redis-cli> CONFIG SET masterauth <PASSWORD>
                
            配置参数：
                *slaveof
                *masterauth 
                
                slave-serve-stale-data yes
                slave-read-only yes
                *repl-diskless-sync no
                    no, Disk-backed, Diskless
                
                repl-diskless-sync-delay 5
                repl-ping-slave-period 10
                
                *repl-timeout 60
                
                repl-disable-tcp-nodelay no
                repl-backlog-size 1mb
                
                *slave-priority 100
                
                min-slaves-to-write 3
                min-slaves-max-lag 10
                
        sentinel：
            主要完成三个功能：监控、通知、自动故障转移
            
                选举：流言协议、投票协议
                
            配置项：
                port 26379
                sentinel monitor <master-name> <ip> <redis-port> <quorum>
                sentinel auth-pass <master-name> <password>
                
                    <quorum>表示sentinel集群的quorum机制，即至少有quorum个sentinel节点同时判定主节点故障时，才认为其真的故障；
                        s_down: subjectively down
                        o_down: objectively down
                
                sentinel down-after-milliseconds <master-name> <milliseconds>
                    监控到指定的集群的主节点异常状态持续多久方才将标记为“故障”；
                    
                sentinel parallel-syncs <master-name> <numslaves>
                    指在failover过程中，能够被sentinel并行配置的从节点的数量；
                    
                sentinel failover-timeout <master-na`````me> <milliseconds>
                    sentinel必须在此指定的时长内完成故障转移操作，否则，将视为故障转移操作失败；
                    
                sentinel notification-script <master-name> <script-path>
                    通知脚本，此脚本被自动传递多个参数；
                    
                redis-cli -h SENTINEL_HOST -p SENTINEL_PORT 
                    redis-cli> 
                        SENTINEL masters
                        SENTINEL slaves <MASTER_NAME>
                        SENTINEL failover <MASTER_NAME>
                        SENTINEL get-master-addr-by-name <MASTER_NAME>