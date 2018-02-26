mysql入门
============================================

mariadb的特性

- 单进程，多线程
- 插件式存储引擎
- 开源
- 提供较多测试组件

客户端工具
----------------------------------------------

mysql命令的重要选项

--print-default         默认选项
--verbose               显示详细信息
-u                      指定用户
-p                      指定密码
-h                      服务器主机

.. note:: mysql中的用户是username@host构成的支持通配,%代表任意长度任意字符，-匹配任意单个字符。

执行命令
------------------------------------------------------

查看当前用户

.. code-block:: sql

    select user();

查看服务器版本

.. code-block:: sql

    select version()

数据库操作
------------------------------------------------------

创建数据库和删除数据库

.. code-block:: sql

    create database t2;
    drop database t2;

查看字符集和排序规则

.. code-block:: text

    show character set;
    show collation;
    show table status from mysql\G

查看数据库引擎

创建表

.. code-block:: sql

    create table student(id int primary key AUTO_INCREMENT , age int unsigned ,name varchar(30), sex enum('m','f') default 'm'); 
    MariaDB [test]> desc student;
    +-------+------------------+------+-----+---------+----------------+
    | Field | Type             | Null | Key | Default | Extra          |
    +-------+------------------+------+-----+---------+----------------+
    | id    | int(11)          | NO   | PRI | NULL    | auto_increment |
    | age   | int(10) unsigned | YES  |     | NULL    |                |
    | name  | varchar(30)      | YES  |     | NULL    |                |
    | sex   | enum('m','f')    | YES  |     | m       |                |
    +-------+------------------+------+-----+---------+----------------+
    4 rows in set (0.00 sec)

    MariaDB [test]> create tables t2 select * from student;
    ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near 'tables t2 select * from student' at line 1
    MariaDB [test]> create table t2 select * from student;
    Query OK, 0 rows affected (0.01 sec)
    Records: 0  Duplicates: 0  Warnings: 0

    MariaDB [test]> desc t2;
    +-------+------------------+------+-----+---------+-------+
    | Field | Type             | Null | Key | Default | Extra |
    +-------+------------------+------+-----+---------+-------+
    | id    | int(11)          | NO   |     | 0       |       |
    | age   | int(10) unsigned | YES  |     | NULL    |       |
    | name  | varchar(30)      | YES  |     | NULL    |       |
    | sex   | enum('m','f')    | YES  |     | m       |       |
    +-------+------------------+------+-----+---------+-------+
    4 rows in set (0.00 sec)

.. note:: 上面可以发现通过select来去创建一个表会丢失主键和自动增长的。

表查看类

.. code-block:: sql

    MariaDB [test]> show tables;
    +----------------+
    | Tables_in_test |
    +----------------+
    | student        |
    +----------------+
    1 row in set (0.00 sec)

    MariaDB [test]> desc student;
    +-------+------------------+------+-----+---------+----------------+
    | Field | Type             | Null | Key | Default | Extra          |
    +-------+------------------+------+-----+---------+----------------+
    | id    | int(11)          | NO   | PRI | NULL    | auto_increment |
    | age   | int(10) unsigned | YES  |     | NULL    |                |
    | name  | varchar(30)      | YES  |     | NULL    |                |
    | sex   | enum('m','f')    | YES  |     | m       |                |
    +-------+------------------+------+-----+---------+----------------+
    4 rows in set (0.00 sec)

    MariaDB [test]> show create table student;
    +---------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Table   | Create Table                                                                                                                                                                                                                              |
    +---------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | student | CREATE TABLE `student` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `age` int(10) unsigned DEFAULT NULL,
    `name` varchar(30) DEFAULT NULL,
    `sex` enum('m','f') DEFAULT 'm',
    PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=latin1 |
    +---------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    1 row in set (0.01 sec)

    MariaDB [test]> show table status like 'student';

数据类型

.. code-block:: text

    tinyint 
    smallint
    mediumint
    int
    bigint
    float(m,d)
    double(m,d)
    decimal(m,d)
    char(n)
    varchar(n)
    tinytext
    text
    mediumtext
    longtext
    binary(m)
    varbinary(m)
    enum
    blob 
    date 
    time 
    datetime
    timestamp
    year(2)
    year(4)

修饰符

.. code-block:: text

    null 
    not null
    default 
    primary key 
    unique key
    character set name 
    auto_increment 
    unsigned

字段修改

.. code-block:: sql

    MariaDB [test]> desc student;
    +-------+------------------+------+-----+---------+----------------+
    | Field | Type             | Null | Key | Default | Extra          |
    +-------+------------------+------+-----+---------+----------------+
    | id    | int(11)          | NO   | PRI | NULL    | auto_increment |
    | age   | int(10) unsigned | YES  |     | NULL    |                |
    | name  | varchar(30)      | YES  |     | NULL    |                |
    | sex   | enum('m','f')    | YES  |     | m       |                |
    +-------+------------------+------+-----+---------+----------------+
    4 rows in set (0.00 sec)

    MariaDB [test]> alter table student add address varchar(100) after name;
    Query OK, 0 rows affected (0.02 sec)               
    Records: 0  Duplicates: 0  Warnings: 0

    MariaDB [test]> desc student;
    +---------+------------------+------+-----+---------+----------------+
    | Field   | Type             | Null | Key | Default | Extra          |
    +---------+------------------+------+-----+---------+----------------+
    | id      | int(11)          | NO   | PRI | NULL    | auto_increment |
    | age     | int(10) unsigned | YES  |     | NULL    |                |
    | name    | varchar(30)      | YES  |     | NULL    |                |
    | address | varchar(100)     | YES  |     | NULL    |                |
    | sex     | enum('m','f')    | YES  |     | m       |                |
    +---------+------------------+------+-----+---------+----------------+
    5 rows in set (0.00 sec)

    MariaDB [test]> alter table student drop address;
    MariaDB [test]> alter table student change name stuname varchar(200);
    MariaDB [test]> alter table student modify stuname varchar(300);

    MariaDB [test]> desc student;
    +---------+------------------+------+-----+---------+----------------+
    | Field   | Type             | Null | Key | Default | Extra          |
    +---------+------------------+------+-----+---------+----------------+
    | id      | int(11)          | NO   | PRI | NULL    | auto_increment |
    | age     | int(10) unsigned | YES  |     | NULL    |                |
    | stuname | varchar(300)     | YES  |     | NULL    |                |
    | sex     | enum('m','f')    | YES  |     | m       |                |
    +---------+------------------+------+-----+---------+----------------+
    4 rows in set (0.00 sec)

    MariaDB [test]> alter table student rename stu;
    Query OK, 0 rows affected (0.00 sec)

索引

.. code-block:: sql

    MariaDB [test]> create index index_age on stu(age);
    Query OK, 0 rows affected (0.23 sec)
    Records: 0  Duplicates: 0  Warnings: 0

    MariaDB [test]> show index from stu;
    +-------+------------+-----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
    | Table | Non_unique | Key_name  | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
    +-------+------------+-----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
    | stu   |          0 | PRIMARY   |            1 | id          | A         |           0 |     NULL | NULL   |      | BTREE      |         |               |
    | stu   |          1 | index_age |            1 | age         | A         |           0 |     NULL | NULL   | YES  | BTREE      |         |               |
    +-------+------------+-----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
    2 rows in set (0.00 sec)

    MariaDB [test]> drop index index_age on stu;
    Query OK, 0 rows affected (0.00 sec)
    Records: 0  Duplicates: 0  Warnings: 0

dml语句

.. code-block:: sql

    MariaDB [test]> desc stu;
    +---------+------------------+------+-----+---------+----------------+
    | Field   | Type             | Null | Key | Default | Extra          |
    +---------+------------------+------+-----+---------+----------------+
    | id      | int(11)          | NO   | PRI | NULL    | auto_increment |
    | age     | int(10) unsigned | YES  |     | NULL    |                |
    | stuname | varchar(300)     | YES  |     | NULL    |                |
    | sex     | enum('m','f')    | YES  |     | m       |                |
    +---------+------------------+------+-----+---------+----------------+
    4 rows in set (0.00 sec)

    MariaDB [test]> insert into stu(age,stuname) values(20,'zhao');
    Query OK, 1 row affected (0.01 sec)

    MariaDB [test]> insert into stu(age,stuname) values(21,'zhao2'),(22,'zhao3');
    Query OK, 2 rows affected (0.00 sec)
    Records: 2  Duplicates: 0  Warnings: 0

    MariaDB [test]> insert into stu set age=23,stuname='zhao3';
    Query OK, 1 row affected (0.01 sec)

    MariaDB [test]> select * from stu;
    +----+------+---------+------+
    | id | age  | stuname | sex  |
    +----+------+---------+------+
    |  1 |   20 | zhao    | m    |
    |  2 |   21 | zhao2   | m    |
    |  3 |   22 | zhao3   | m    |
    |  4 |   23 | zhao3   | m    |
    +----+------+---------+------+
    4 rows in set (0.00 sec)

    MariaDB [test]> update stu set sex='f' where id =4;

    MariaDB [test]> update stu set sex='f' where id =4;
    Query OK, 1 row affected (0.00 sec)
    Rows matched: 1  Changed: 1  Warnings: 0

    MariaDB [test]> delete from stu where id=1;
    Query OK, 1 row affected (0.00 sec)

    MariaDB [test]> select * from stu;
    +----+------+---------+------+
    | id | age  | stuname | sex  |
    +----+------+---------+------+
    |  2 |   21 | zhao2   | m    |
    |  3 |   22 | zhao3   | m    |
    |  4 |   23 | zhao3   | f    |
    +----+------+---------+------+
    3 rows in set (0.00 sec)

dql语句

.. code-block:: sql

    MariaDB [test]> select * from stu where age between 21 and 22;
    +----+------+---------+------+
    | id | age  | stuname | sex  |
    +----+------+---------+------+
    |  2 |   21 | zhao2   | m    |
    |  3 |   22 | zhao3   | m    |
    +----+------+---------+------+
    2 rows in set (0.00 sec)

    MariaDB [test]> select * from stu where stuname like 'zhao%';
    +----+------+---------+------+
    | id | age  | stuname | sex  |
    +----+------+---------+------+
    |  2 |   21 | zhao2   | m    |
    |  3 |   22 | zhao3   | m    |
    |  4 |   23 | zhao3   | f    |
    +----+------+---------+------+
    3 rows in set (0.00 sec)

    MariaDB [test]> select * from stu where stuname is not null;
    +----+------+---------+------+
    | id | age  | stuname | sex  |
    +----+------+---------+------+
    |  2 |   21 | zhao2   | m    |
    |  3 |   22 | zhao3   | m    |
    |  4 |   23 | zhao3   | f    |
    +----+------+---------+------+
    3 rows in set (0.00 sec)

    MariaDB [test]> select * from stu where age in (21,22);
    +----+------+---------+------+
    | id | age  | stuname | sex  |
    +----+------+---------+------+
    |  2 |   21 | zhao2   | m    |
    |  3 |   22 | zhao3   | m    |
    +----+------+---------+------+
    2 rows in set (0.00 sec)

用户账号

.. code-block:: text

    MariaDB [test]> create user 'zhao'@'%' identified by 'oracle';
    Query OK, 0 rows affected (0.00 sec)

    MariaDB [test]> flush privileges;
    Query OK, 0 rows affected (0.00 sec)

    MariaDB [test]> drop user 'zhao'@'%';
    MariaDB [test]> create user 'zhao'@'%' identified by 'oracle';
    MariaDB [test]> set password for 'zhao'@'%' = password('zhao');
    [root@102 ~]$ mysqladmin -u root -p  password 'newpassword'

授权

.. code-block:: sql

    MariaDB [test]> grant select ,delete on test.* to 'zhao'@'%' identified by 'oracle';
    Query OK, 0 rows affected (0.37 sec)

    MariaDB [test]> revoke delete on test.* from 'zhao'@'%';
    Query OK, 0 rows affected (0.00 sec)

    MariaDB [test]> show grants for 'zhao'@'%';
    +-----------------------------------------------------------------------------------------------------+
    | Grants for zhao@%                                                                                   |
    +-----------------------------------------------------------------------------------------------------+
    | GRANT USAGE ON *.* TO 'zhao'@'%' IDENTIFIED BY PASSWORD '*2447D497B9A6A15F2776055CB2D1E9F86758182F' |
    | GRANT SELECT ON `test`.* TO 'zhao'@'%'                                                              |
    +-----------------------------------------------------------------------------------------------------+
    2 rows in set (0.00 sec)

为了后续的实验，我们导入一个文件，文件内容如下 

:download:`/files/hellodb_InnoDB.sql` 

.. literalinclude:: /files/hellodb_InnoDB.sql
   :encoding: utf-8
   :language: sql
   :linenos:

排序

.. code-block:: sql

    MariaDB [(none)]> use hellodb
    Database changed
    MariaDB [hellodb]> select * from students order by age;
    +-------+---------------+-----+--------+---------+-----------+
    | StuID | Name          | Age | Gender | ClassID | TeacherID |
    +-------+---------------+-----+--------+---------+-----------+
    |     8 | Lin Daiyu     |  17 | F      |       7 |      NULL |
    |    14 | Lu Wushuang   |  17 | F      |       3 |      NULL |
    |    19 | Xue Baochai   |  18 | F      |       6 |      NULL |
    |    12 | Wen Qingqing  |  19 | F      |       1 |      NULL |
    |    10 | Yue Lingshan  |  19 | F      |       3 |      NULL |
    |     7 | Xi Ren        |  19 | F      |       3 |      NULL |
    |    15 | Duan Yu       |  19 | M      |       4 |      NULL |
    |    20 | Diao Chan     |  19 | F      |       7 |      NULL |
    |     9 | Ren Yingying  |  20 | F      |       6 |      NULL |
    |    22 | Xiao Qiao     |  20 | F      |       1 |      NULL |
    |    16 | Xu Zhu        |  21 | M      |       1 |      NULL |
    |     1 | Shi Zhongyu   |  22 | M      |       2 |         3 |
    |    21 | Huang Yueying |  22 | F      |       6 |      NULL |
    |     2 | Shi Potian    |  22 | M      |       1 |         7 |
    |    23 | Ma Chao       |  23 | M      |       4 |      NULL |
    |    18 | Hua Rong      |  23 | M      |       7 |      NULL |
    |    11 | Yuan Chengzhi |  23 | M      |       6 |      NULL |
    |    17 | Lin Chong     |  25 | M      |       4 |      NULL |
    |     5 | Yu Yutong     |  26 | M      |       3 |         1 |
    |    24 | Xu Xian       |  27 | M      |    NULL |      NULL |
    |     4 | Ding Dian     |  32 | M      |       4 |         4 |
    |    13 | Tian Boguang  |  33 | M      |       2 |      NULL |
    |     6 | Shi Qing      |  46 | M      |       5 |      NULL |
    |     3 | Xie Yanke     |  53 | M      |       2 |        16 |
    |    25 | Sun Dasheng   | 100 | M      |    NULL |      NULL |
    +-------+---------------+-----+--------+---------+-----------+
    25 rows in set (0.00 sec)

限制行

.. code-block:: mysql

    MariaDB [hellodb]> select * from students order by age limit 2;
    +-------+-------------+-----+--------+---------+-----------+
    | StuID | Name        | Age | Gender | ClassID | TeacherID |
    +-------+-------------+-----+--------+---------+-----------+
    |    14 | Lu Wushuang |  17 | F      |       3 |      NULL |
    |     8 | Lin Daiyu   |  17 | F      |       7 |      NULL |
    +-------+-------------+-----+--------+---------+-----------+
    2 rows in set (0.00 sec)

    MariaDB [hellodb]> select * from students order by age limit 2,4;
    +-------+--------------+-----+--------+---------+-----------+
    | StuID | Name         | Age | Gender | ClassID | TeacherID |
    +-------+--------------+-----+--------+---------+-----------+
    |    19 | Xue Baochai  |  18 | F      |       6 |      NULL |
    |    15 | Duan Yu      |  19 | M      |       4 |      NULL |
    |    12 | Wen Qingqing |  19 | F      |       1 |      NULL |
    |     7 | Xi Ren       |  19 | F      |       3 |      NULL |
    +-------+--------------+-----+--------+---------+-----------+
    4 rows in set (0.00 sec)

第二种情况是跳过2个取4个。


别名

.. code-block:: text

    MariaDB [hellodb]> select s.name as "姓名" , s.age as "年龄" from students as s  order by age limit 2,4;
    +--------------+--------+
    | 姓名         | 年龄   |
    +--------------+--------+
    | Xue Baochai  |     18 |
    | Duan Yu      |     19 |
    | Wen Qingqing |     19 |
    | Xi Ren       |     19 |
    +--------------+--------+
    4 rows in set (0.00 sec)

模糊匹配

.. code-block:: text

    %通配任意字符任意次数
    _通配单个字符

.. code-block:: sql

    MariaDB [hellodb]> select * from students where name like 'S%'
        -> ;
    +-------+-------------+-----+--------+---------+-----------+
    | StuID | Name        | Age | Gender | ClassID | TeacherID |
    +-------+-------------+-----+--------+---------+-----------+
    |     1 | Shi Zhongyu |  22 | M      |       2 |         3 |
    |     2 | Shi Potian  |  22 | M      |       1 |         7 |
    |     6 | Shi Qing    |  46 | M      |       5 |      NULL |
    |    25 | Sun Dasheng | 100 | M      |    NULL |      NULL |
    +-------+-------------+-----+--------+---------+-----------+
    4 rows in set (0.00 sec)

空值判断

.. code-block:: sql

    MariaDB [hellodb]> select * from students where classid is null;
    +-------+-------------+-----+--------+---------+-----------+
    | StuID | Name        | Age | Gender | ClassID | TeacherID |
    +-------+-------------+-----+--------+---------+-----------+
    |    24 | Xu Xian     |  27 | M      |    NULL |      NULL |
    |    25 | Sun Dasheng | 100 | M      |    NULL |      NULL |
    +-------+-------------+-----+--------+---------+-----------+
    2 rows in set (0.00 sec)

    MariaDB [hellodb]> select * from students where classid is not null;

.. warning:: 空值判断不能使用=。


分组统计

.. code-block:: sql

    MariaDB [hellodb]> select courseid,avg(score) from scores group by courseid;
    +----------+------------+
    | courseid | avg(score) |
    +----------+------------+
    |        1 | 73.6667    |
    |        2 | 75.2500    |
    |        3 | 93.0000    |
    |        4 | 57.0000    |
    |        5 | 84.0000    |
    |        6 | 84.0000    |
    |        7 | 73.0000    |
    +----------+------------+
    7 rows in set (0.00 sec)

分组统计后过滤

.. code-block:: sql

    MariaDB [hellodb]> select courseid,avg(score) from scores group by courseid having avg(score) > 80;
    +----------+------------+
    | courseid | avg(score) |
    +----------+------------+
    |        3 | 93.0000    |
    |        5 | 84.0000    |
    |        6 | 84.0000    |
    +----------+------------+
    3 rows in set (0.00 sec)

连接

.. code-block:: SQL

    MariaDB [hellodb]> select st.name, sc.score from students as st left outer join scores as sc on st.stuid=sc.stuid;
    +---------------+-------+
    | name          | score |
    +---------------+-------+
    | Shi Zhongyu   |    77 |
    | Shi Zhongyu   |    93 |
    | Shi Potian    |    47 |
    | Shi Potian    |    97 |
    | Xie Yanke     |    88 |
    | Xie Yanke     |    75 |
    | Ding Dian     |    71 |
    | Ding Dian     |    89 |
    | Yu Yutong     |    39 |
    | Yu Yutong     |    63 |
    | Shi Qing      |    96 |
    | Xi Ren        |    86 |
    | Xi Ren        |    83 |
    | Lin Daiyu     |    57 |
    | Lin Daiyu     |    93 |
    | Ren Yingying  |  NULL |
    | Yue Lingshan  |  NULL |
    | Yuan Chengzhi |  NULL |
    | Wen Qingqing  |  NULL |
    | Tian Boguang  |  NULL |
    | Lu Wushuang   |  NULL |
    | Duan Yu       |  NULL |
    | Xu Zhu        |  NULL |
    | Lin Chong     |  NULL |
    | Hua Rong      |  NULL |
    | Xue Baochai   |  NULL |
    | Diao Chan     |  NULL |
    | Huang Yueying |  NULL |
    | Xiao Qiao     |  NULL |
    | Ma Chao       |  NULL |
    | Xu Xian       |  NULL |
    | Sun Dasheng   |  NULL |
    +---------------+-------+
    32 rows in set (0.05 sec)

    MariaDB [hellodb]> select st.name, sc.score from students as st right outer join scores as sc on st.stuid=sc.stuid;
    +-------------+-------+
    | name        | score |
    +-------------+-------+
    | Shi Zhongyu |    77 |
    | Shi Zhongyu |    93 |
    | Shi Potian  |    47 |
    | Shi Potian  |    97 |
    | Xie Yanke   |    88 |
    | Xie Yanke   |    75 |
    | Ding Dian   |    71 |
    | Ding Dian   |    89 |
    | Yu Yutong   |    39 |
    | Yu Yutong   |    63 |
    | Shi Qing    |    96 |
    | Xi Ren      |    86 |
    | Xi Ren      |    83 |
    | Lin Daiyu   |    57 |
    | Lin Daiyu   |    93 |
    +-------------+-------+
    15 rows in set (0.00 sec)

    MariaDB [hellodb]> select st.name, sc.score from students as st  inner join scores as sc on st.stuid=sc.stuid;
    +-------------+-------+
    | name        | score |
    +-------------+-------+
    | Shi Zhongyu |    77 |
    | Shi Zhongyu |    93 |
    | Shi Potian  |    47 |
    | Shi Potian  |    97 |
    | Xie Yanke   |    88 |
    | Xie Yanke   |    75 |
    | Ding Dian   |    71 |
    | Ding Dian   |    89 |
    | Yu Yutong   |    39 |
    | Yu Yutong   |    63 |
    | Shi Qing    |    96 |
    | Xi Ren      |    86 |
    | Xi Ren      |    83 |
    | Lin Daiyu   |    57 |
    | Lin Daiyu   |    93 |
    +-------------+-------+
    15 rows in set (0.00 sec)

嵌套查询

.. code-block:: sql

    MariaDB [hellodb]> select * from students where age > (select age from students where name='Xu Xian');
    +-------+--------------+-----+--------+---------+-----------+
    | StuID | Name         | Age | Gender | ClassID | TeacherID |
    +-------+--------------+-----+--------+---------+-----------+
    |     3 | Xie Yanke    |  53 | M      |       2 |        16 |
    |     4 | Ding Dian    |  32 | M      |       4 |         4 |
    |     6 | Shi Qing     |  46 | M      |       5 |      NULL |
    |    13 | Tian Boguang |  33 | M      |       2 |      NULL |
    |    25 | Sun Dasheng  | 100 | M      |    NULL |      NULL |
    +-------+--------------+-----+--------+---------+-----------+
    5 rows in set (0.03 sec)

