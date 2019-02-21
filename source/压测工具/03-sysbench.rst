sysbench
====================================

sysbench 是一个模块化的、跨平台、多线程基准测试工具，主要用于评估测试各种不同参数下的数据库负载情况，主要包括以下几种方式的测试： 

- cpu
- io
- schedule 
- mem
- thread 
- database 

sysbench的安装
---------------------------------------

.. code-block:: bash 

    yum -y install epel-release
    yum install sysbench

sysbench的命令
-------------------------------------

.. code-block:: bash 

    [root@localhost ~]# sysbench  --help
    Usage:
    sysbench [options]... [testname] [command]

    Commands implemented by most tests: prepare run cleanup help

    # 通用的选项
    General options:
    --threads=N                     使用的线程数量，默认为1
    --events=N                      事件的最大数量，默认为0，不限制
    --time=N                        最大执行时间， 单位是秒，默认为0，不限制
    --forced-shutdown=STRING        超过max-time强制中断，默认是off.
    --thread-stack-size=SIZE        每个线程的堆栈大小
    --rate=N                        平均速率
    --report-interval=N             报告中间统计信息的间隔，0代表禁止。
    --report-checkpoints=[LIST,...] 转储完全统计信息并在指定时间点复位所有计数器，参数是都好分割值的列表，表示从必须执行报告检查点的测试开始所经过的时间，默认是关闭的。
    --debug[=on|off]                打印debug调试信息，默认是off.
    --validate[=on|off]             在可能情况下执行验证检查。
    --help[=on|off]                 输出帮助信息，并退出
    --version[=on|off]              打印版本信息
    --config-file=FILENAME          配置文件
    --tx-rate=N                     deprecated alias for --rate [0]
    --max-requests=N                deprecated alias for --events [0]
    --max-time=N                    deprecated alias for --time [0]
    --num-threads=N                 deprecated alias for --threads [1]


    Pseudo-Random Numbers Generator options:
    --rand-type=STRING 分布的随机数，uniform,gaussian,special。
    --rand-spec-iter=N 产生随机数的迭代次数
    --rand-spec-pct=N  值的百分比，默认是1
    --rand-spec-res=N  special的百分占比
    --rand-seed=N      随机数发生器的种子
    --rand-pareto-h=N  参数h用于pareto分布。

    Log options:
    --verbosity=N 日志级别 默认为3， 5代表调试，0表示仅仅重要

    --percentile=N       在延迟统计数据中计算的百分点。
    --histogram[=on|off] 在报告中打印滞后时间直方图。

    General database options:

    --db-driver=STRING  指定数据库的驱动使用mysql,pgsql
    --db-ps-mode=STRING 
    --db-debug[=on|off] 打印数据库的debug信息。 


    Compiled-in database drivers:
    mysql - MySQL driver
    pgsql - PostgreSQL driver

    mysql options:
    --mysql-host=[LIST,...]          主机
    --mysql-port=[LIST,...]          端口
    --mysql-socket=[LIST,...]        socket文件
    --mysql-user=STRING              用户
    --mysql-password=STRING          密码
    --mysql-db=STRING                数据库名字
    --mysql-ssl[=on|off]             使用ssl连接
    --mysql-ssl-cipher=STRING        use specific cipher for SSL connections []
    --mysql-compression[=on|off]     使用压缩，默认off
    --mysql-debug[=on|off]           追踪客户端库调用，off
    --mysql-ignore-errors=[LIST,...] 指定的错误忽略。
    --mysql-dry-run[=on|off]         Dry run, pretend that all MySQL client API calls are successful without executing them [off]

    pgsql options:
    --pgsql-host=STRING     主机
    --pgsql-port=N          端口
    --pgsql-user=STRING     用户名
    --pgsql-password=STRING 密码
    --pgsql-db=STRING       数据库名字

    Compiled-in tests:
    fileio - 文件io测试    
    cpu -cpu性能测试
    memory - 内存测试
    threads -线程测试
    mutex - Mutex performance test多线程测试

    See 'sysbench <testname> help' for a list of options for each test.

sysbench 测试cpu
-------------------------------

.. code-block:: bash 

    sysbench  --threads=12 --events=10000 --debug=on --cpu-max-prime=20000 cpu run 

    CPU speed:
        events per second:   614.81

    General statistics:
        total time:                          10.0095s    总的时间
        total number of events:              6155        总的

    Latency (ms):
            min:                                  3.01
            avg:                                 19.43
            max:                                125.20
            95th percentile:                     64.47
            sum:                             119613.29   