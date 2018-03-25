redis安装和常用类型
========================================

redis安装
-------------------------

.. code-block:: bash 

    [root@centos-151 ~]# yum install redis 

    [root@centos-151 ~]# rpm -ql redis     
    /etc/logrotate.d/redis                          # 日志滚动的
    /etc/redis-sentinel.conf                        # 高可用相关配置
    /etc/redis.conf                                 # redis主配置文件
    /etc/systemd/system/redis-sentinel.service.d    
    /etc/systemd/system/redis-sentinel.service.d/limit.conf
    /etc/systemd/system/redis.service.d
    /etc/systemd/system/redis.service.d/limit.conf
    /usr/bin/redis-benchmark
    /usr/bin/redis-check-aof                        # 检查aof
    /usr/bin/redis-check-rdb                        # 检查快照文件
    /usr/bin/redis-cli                              # 命令终端
    /usr/bin/redis-sentinel
    /usr/bin/redis-server                           
    /usr/lib/systemd/system/redis-sentinel.service
    /usr/lib/systemd/system/redis.service
    /usr/libexec/redis-shutdown
    /usr/share/doc/redis-3.2.10
    /usr/share/doc/redis-3.2.10/00-RELEASENOTES
    /usr/share/doc/redis-3.2.10/BUGS
    /usr/share/doc/redis-3.2.10/CONTRIBUTING
    /usr/share/doc/redis-3.2.10/MANIFESTO
    /usr/share/doc/redis-3.2.10/README.md
    /usr/share/licenses/redis-3.2.10
    /usr/share/licenses/redis-3.2.10/COPYING
    /usr/share/man/man1/redis-benchmark.1.gz
    /usr/share/man/man1/redis-check-aof.1.gz
    /usr/share/man/man1/redis-check-rdb.1.gz
    /usr/share/man/man1/redis-cli.1.gz
    /usr/share/man/man1/redis-sentinel.1.gz
    /usr/share/man/man1/redis-server.1.gz
    /usr/share/man/man5/redis-sentinel.conf.5.gz
    /usr/share/man/man5/redis.conf.5.gz
    /var/lib/redis                                      # redis数据库文件位置
    /var/log/redis                                      # redis日志文件位置
    /var/run/redis


redis-cli使用
--------------------------

.. code-block:: bash 

    [root@centos-151 ~]# systemctl restart redis 
    [root@centos-151 ~]#  redis-cli 
    127.0.0.1:6379> help
    redis-cli 3.2.10
    To get help about Redis commands type:
        "help @<group>" to get a list of commands in <group>
        "help <command>" for help on <command>
        "help <tab>" to get a list of possible help topics
        "quit" to exit

    To set redis-cli perferences:
        ":set hints" enable online hints
        ":set nohints" disable online hints
    Set your preferences in ~/.redisclirc

.. note:: redis-cli的只能提示是非常完美的。

redis常用数据类型
---------------------------------

string类型
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    127.0.0.1:6379> help @string

    APPEND key value
    summary: Append a value to a key  # 给特定key追加一个值
    since: 2.0.0

    BITCOUNT key [start end]
    summary: Count set bits in a string # 字符串的bits个数
    since: 2.6.0

    BITFIELD key [GET type offset] [SET type offset value] [INCRBY type offset increment] [OVERFLOW WRAP|SAT|FAIL]
    summary: Perform arbitrary bitfield integer operations on strings
    since: 3.2.0

    BITOP operation destkey key [key ...]
    summary: Perform bitwise operations between strings  #2个字符串之间指定操作运算
    since: 2.6.0

    BITPOS key bit [start] [end]
    summary: Find first bit set or clear in a string    # 查找位置
    since: 2.8.7

    DECR key
    summary: Decrement the integer value of a key by one    # 减少值
    since: 1.0.0

    DECRBY key decrement
    summary: Decrement the integer value of a key by the given number # 减少特定值
    since: 1.0.0

    GET key
    summary: Get the value of a key     # 获取特定的key对应值
    since: 1.0.0

    GETBIT key offset
    summary: Returns the bit value at offset in the string value stored at key # 
    since: 2.2.0

    GETRANGE key start end
    summary: Get a substring of the string stored at a key    # 
    since: 2.4.0

    GETSET key value
    summary: Set the string value of a key and return its old value
    since: 1.0.0

    INCR key
    summary: Increment the integer value of a key by one
    since: 1.0.0

    INCRBY key increment
    summary: Increment the integer value of a key by the given amount
    since: 1.0.0

    INCRBYFLOAT key increment
    summary: Increment the float value of a key by the given amount
    since: 2.6.0

    MGET key [key ...]
    summary: Get the values of all the given keys
    since: 1.0.0

    MSET key value [key value ...]
    summary: Set multiple keys to multiple values
    since: 1.0.1

    MSETNX key value [key value ...]
    summary: Set multiple keys to multiple values, only if none of the keys exist
    since: 1.0.1

    PSETEX key milliseconds value
    summary: Set the value and expiration in milliseconds of a key
    since: 2.6.0

    SET key value [EX seconds] [PX milliseconds] [NX|XX]
    summary: Set the string value of a key
    since: 1.0.0

    SETBIT key offset value
    summary: Sets or clears the bit at offset in the string value stored at key
    since: 2.2.0

    SETEX key seconds value
    summary: Set the value and expiration of a key
    since: 2.0.0

    SETNX key value
    summary: Set the value of a key, only if the key does not exist
    since: 1.0.0

    SETRANGE key offset value
    summary: Overwrite part of a string at key starting at the specified offset
    since: 2.2.0

    STRLEN key
    summary: Get the length of the value stored in a key
    since: 2.2.0


list类型
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    127.0.0.1:6379> help @list

    BLPOP key [key ...] timeout
    summary: Remove and get the first element in a list, or block until one is available
    since: 2.0.0

    BRPOP key [key ...] timeout
    summary: Remove and get the last element in a list, or block until one is available
    since: 2.0.0

    BRPOPLPUSH source destination timeout
    summary: Pop a value from a list, push it to another list and return it; or block until one is available
    since: 2.2.0

    LINDEX key index
    summary: Get an element from a list by its index
    since: 1.0.0

    LINSERT key BEFORE|AFTER pivot value
    summary: Insert an element before or after another element in a list
    since: 2.2.0

    LLEN key
    summary: Get the length of a list
    since: 1.0.0

    LPOP key
    summary: Remove and get the first element in a list
    since: 1.0.0

    LPUSH key value [value ...]
    summary: Prepend one or multiple values to a list
    since: 1.0.0

    LPUSHX key value
    summary: Prepend a value to a list, only if the list exists
    since: 2.2.0

    LRANGE key start stop
    summary: Get a range of elements from a list
    since: 1.0.0

    LREM key count value
    summary: Remove elements from a list
    since: 1.0.0

    LSET key index value
    summary: Set the value of an element in a list by its index
    since: 1.0.0

    LTRIM key start stop
    summary: Trim a list to the specified range
    since: 1.0.0

    RPOP key
    summary: Remove and get the last element in a list
    since: 1.0.0

    RPOPLPUSH source destination
    summary: Remove the last element in a list, prepend it to another list and return it
    since: 1.2.0

    RPUSH key value [value ...]
    summary: Append one or multiple values to a list
    since: 1.0.0

    RPUSHX key value
    summary: Append a value to a list, only if the list exists
    since: 2.2.0

generic类型
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 


    127.0.0.1:6379> help @generic

    DEL key [key ...]
    summary: Delete a key
    since: 1.0.0

    DUMP key
    summary: Return a serialized version of the value stored at the specified key.
    since: 2.6.0

    EXISTS key [key ...]
    summary: Determine if a key exists
    since: 1.0.0

    EXPIRE key seconds
    summary: Set a key's time to live in seconds
    since: 1.0.0

    EXPIREAT key timestamp
    summary: Set the expiration for a key as a UNIX timestamp
    since: 1.2.0

    KEYS pattern
    summary: Find all keys matching the given pattern
    since: 1.0.0

    MIGRATE host port key| destination-db timeout [COPY] [REPLACE] [KEYS key]
    summary: Atomically transfer a key from a Redis instance to another one.
    since: 2.6.0

    MOVE key db
    summary: Move a key to another database
    since: 1.0.0

    OBJECT subcommand [arguments [arguments ...]]
    summary: Inspect the internals of Redis objects
    since: 2.2.3

    PERSIST key
    summary: Remove the expiration from a key
    since: 2.2.0

    PEXPIRE key milliseconds
    summary: Set a key's time to live in milliseconds
    since: 2.6.0

    PEXPIREAT key milliseconds-timestamp
    summary: Set the expiration for a key as a UNIX timestamp specified in milliseconds
    since: 2.6.0

    PTTL key
    summary: Get the time to live for a key in milliseconds
    since: 2.6.0

    RANDOMKEY -
    summary: Return a random key from the keyspace
    since: 1.0.0

    RENAME key newkey
    summary: Rename a key
    since: 1.0.0

    RENAMENX key newkey
    summary: Rename a key, only if the new key does not exist
    since: 1.0.0

    RESTORE key ttl serialized-value [REPLACE]
    summary: Create a key using the provided serialized value, previously obtained using DUMP.
    since: 2.6.0

    SCAN cursor [MATCH pattern] [COUNT count]
    summary: Incrementally iterate the keys space
    since: 2.8.0

    SORT key [BY pattern] [LIMIT offset count] [GET pattern [GET pattern ...]] [ASC|DESC] [ALPHA] [STORE destination]
    summary: Sort the elements in a list, set or sorted set
    since: 1.0.0

    TTL key
    summary: Get the time to live for a key
    since: 1.0.0

    TYPE key
    summary: Determine the type stored at key
    since: 1.0.0

    WAIT numslaves timeout
    summary: Wait for the synchronous replication of all the write commands sent in the context of the current connection
    since: 3.0.0

    PFSELFTEST arg 
    summary: Help not available
    since: not known

    HOST: arg ...options...
    summary: Help not available
    since: not known

    GEORADIUSBYMEMBER_RO key arg arg arg arg ...options...
    summary: Help not available
    since: not known

    REPLCONF arg ...options...
    summary: Help not available
    since: not known

    ASKING arg 
    summary: Help not available
    since: not known

    PSYNC arg arg arg 
    summary: Help not available
    since: not known

    RESTORE-ASKING key arg arg arg ...options...
    summary: Help not available
    since: not known

    LATENCY arg arg ...options...
    summary: Help not available
    since: not known

    GEORADIUS_RO key arg arg arg arg arg ...options...
    summary: Help not available
    since: not known

    TOUCH key arg ...options...
    summary: Help not available
    since: not known

    POST arg ...options...
    summary: Help not available
    since: not known

    SUBSTR key arg arg arg 
    summary: Help not available
    since: not known

    PFDEBUG arg arg arg ...options...
    summary: Help not available
    since: not known


generic类型
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    127.0.0.1:6379> help @hash

    HDEL key field [field ...]
    summary: Delete one or more hash fields
    since: 2.0.0

    HEXISTS key field
    summary: Determine if a hash field exists
    since: 2.0.0

    HGET key field
    summary: Get the value of a hash field
    since: 2.0.0

    HGETALL key
    summary: Get all the fields and values in a hash
    since: 2.0.0

    HINCRBY key field increment
    summary: Increment the integer value of a hash field by the given number
    since: 2.0.0

    HINCRBYFLOAT key field increment
    summary: Increment the float value of a hash field by the given amount
    since: 2.6.0

    HKEYS key
    summary: Get all the fields in a hash
    since: 2.0.0

    HLEN key
    summary: Get the number of fields in a hash
    since: 2.0.0

    HMGET key field [field ...]
    summary: Get the values of all the given hash fields
    since: 2.0.0

    HMSET key field value [field value ...]
    summary: Set multiple hash fields to multiple values
    since: 2.0.0

    HSCAN key cursor [MATCH pattern] [COUNT count]
    summary: Incrementally iterate hash fields and associated values
    since: 2.8.0

    HSET key field value
    summary: Set the string value of a hash field
    since: 2.0.0

    HSETNX key field value
    summary: Set the value of a hash field, only if the field does not exist
    since: 2.0.0

    HSTRLEN key field
    summary: Get the length of the value of a hash field
    since: 3.2.0

    HVALS key
    summary: Get all the values in a hash
    since: 2.0.0



sorted_set类型
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    127.0.0.1:6379> help @sorted_set

    ZADD key [NX|XX] [CH] [INCR] score member [score member ...]
    summary: Add one or more members to a sorted set, or update its score if it already exists
    since: 1.2.0

    ZCARD key
    summary: Get the number of members in a sorted set
    since: 1.2.0

    ZCOUNT key min max
    summary: Count the members in a sorted set with scores within the given values
    since: 2.0.0

    ZINCRBY key increment member
    summary: Increment the score of a member in a sorted set
    since: 1.2.0

    ZINTERSTORE destination numkeys key [key ...] [WEIGHTS weight] [AGGREGATE SUM|MIN|MAX]
    summary: Intersect multiple sorted sets and store the resulting sorted set in a new key
    since: 2.0.0

    ZLEXCOUNT key min max
    summary: Count the number of members in a sorted set between a given lexicographical range
    since: 2.8.9

    ZRANGE key start stop [WITHSCORES]
    summary: Return a range of members in a sorted set, by index
    since: 1.2.0

    ZRANGEBYLEX key min max [LIMIT offset count]
    summary: Return a range of members in a sorted set, by lexicographical range
    since: 2.8.9

    ZRANGEBYSCORE key min max [WITHSCORES] [LIMIT offset count]
    summary: Return a range of members in a sorted set, by score
    since: 1.0.5

    ZRANK key member
    summary: Determine the index of a member in a sorted set
    since: 2.0.0

    ZREM key member [member ...]
    summary: Remove one or more members from a sorted set
    since: 1.2.0

    ZREMRANGEBYLEX key min max
    summary: Remove all members in a sorted set between the given lexicographical range
    since: 2.8.9

    ZREMRANGEBYRANK key start stop
    summary: Remove all members in a sorted set within the given indexes
    since: 2.0.0

    ZREMRANGEBYSCORE key min max
    summary: Remove all members in a sorted set within the given scores
    since: 1.2.0

    ZREVRANGE key start stop [WITHSCORES]
    summary: Return a range of members in a sorted set, by index, with scores ordered from high to low
    since: 1.2.0

    ZREVRANGEBYLEX key max min [LIMIT offset count]
    summary: Return a range of members in a sorted set, by lexicographical range, ordered from higher to lower strings.
    since: 2.8.9

    ZREVRANGEBYSCORE key max min [WITHSCORES] [LIMIT offset count]
    summary: Return a range of members in a sorted set, by score, with scores ordered from high to low
    since: 2.2.0

    ZREVRANK key member
    summary: Determine the index of a member in a sorted set, with scores ordered from high to low
    since: 2.0.0

    ZSCAN key cursor [MATCH pattern] [COUNT count]
    summary: Incrementally iterate sorted sets elements and associated scores
    since: 2.8.0

    ZSCORE key member
    summary: Get the score associated with the given member in a sorted set
    since: 1.2.0

    ZUNIONSTORE destination numkeys key [key ...] [WEIGHTS weight] [AGGREGATE SUM|MIN|MAX]
    summary: Add multiple sorted sets and store the resulting sorted set in a new key
    since: 2.0.0



set类型
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 


    127.0.0.1:6379> help @set

    SADD key member [member ...]
    summary: Add one or more members to a set
    since: 1.0.0

    SCARD key
    summary: Get the number of members in a set
    since: 1.0.0

    SDIFF key [key ...]
    summary: Subtract multiple sets
    since: 1.0.0

    SDIFFSTORE destination key [key ...]
    summary: Subtract multiple sets and store the resulting set in a key
    since: 1.0.0

    SINTER key [key ...]
    summary: Intersect multiple sets
    since: 1.0.0

    SINTERSTORE destination key [key ...]
    summary: Intersect multiple sets and store the resulting set in a key
    since: 1.0.0

    SISMEMBER key member
    summary: Determine if a given value is a member of a set
    since: 1.0.0

    SMEMBERS key
    summary: Get all the members in a set
    since: 1.0.0

    SMOVE source destination member
    summary: Move a member from one set to another
    since: 1.0.0

    SPOP key [count]
    summary: Remove and return one or multiple random members from a set
    since: 1.0.0

    SRANDMEMBER key [count]
    summary: Get one or multiple random members from a set
    since: 1.0.0

    SREM key member [member ...]
    summary: Remove one or more members from a set
    since: 1.0.0

    SSCAN key cursor [MATCH pattern] [COUNT count]
    summary: Incrementally iterate Set elements
    since: 2.8.0

    SUNION key [key ...]
    summary: Add multiple sets
    since: 1.0.0

    SUNIONSTORE destination key [key ...]
    summary: Add multiple sets and store the resulting set in a key
    since: 1.0.0


pubsub类型
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text 

    127.0.0.1:6379> help @pubsub

    PSUBSCRIBE pattern [pattern ...]
    summary: Listen for messages published to channels matching the given patterns
    since: 2.0.0

    PUBLISH channel message
    summary: Post a message to a channel
    since: 2.0.0

    PUBSUB subcommand [argument [argument ...]]
    summary: Inspect the state of the Pub/Sub subsystem
    since: 2.8.0

    PUNSUBSCRIBE [pattern [pattern ...]]
    summary: Stop listening for messages posted to channels matching the given patterns
    since: 2.0.0

    SUBSCRIBE channel [channel ...]
    summary: Listen for messages published to the given channels
    since: 2.0.0

    UNSUBSCRIBE [channel [channel ...]]
    summary: Stop listening for messages posted to the given channels
    since: 2.0.0
