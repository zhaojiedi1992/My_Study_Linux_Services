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

--print-default     默认选项
--verbose           显示详细信息
-u                  指定用户
-p                  指定密码
-h                  服务器主机

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

.. code-block:: sql

    show character set;
    show collation;

创建表

.. code-block:: sql

    create table student(id int primary key AUTO_INCREMENT , age int unsigned ,name varchar(30), sex enum('m','f') default 'm'); 

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

.. code-block:: sql

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


