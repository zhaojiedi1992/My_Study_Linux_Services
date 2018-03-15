sql语句
========================================

sql基础
-----------------------------------------------

sql语句分为2个部分，数据操作语言和数据定义语言。

dml语言

#. select 
#. update 
#. delete 
#. insert 

ddl语句

#. create 
#. alter 
#. drop 
#. truncate


select 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

select语句用于从表中选取数据。

语法

.. code-block:: sql

    select 列名称   from   表名称
    select   *      from   表名称

.. note:: "*"代表通配所有列。

样例

.. code-block:: sql

    SELECT LastName,FirstName FROM Persons

distinct
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

distinct用于返回结果集合的唯一不同的值，也就是相同的只显示一次。

语法

.. code-block:: sql

    select distinct 列名称   from   表名称

样例

.. code-block:: sql

    SELECT distinct company FROM Persons

where
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

where语句配合select语句或者其他语句使用，用于有条件的做对应的处理。

语法

.. code-block:: sql

   SELECT 列名称 FROM 表名称 WHERE 列 运算符 值

.. csv-table:: 
   :header: "操作符号","描述"
   :widths: 30,40

    "=",	            等于
    "<>",	            不等于
    ">",	            大于
    "<",	            小于
    ">=",	            大于等于
    "<=",	            小于等于
    "BETWEEN",	        在某个范围内
    "LIKE",	            搜索某种模式

样例

.. code-block:: sql

  SELECT * FROM Persons WHERE City='Beijing'

.. warning:: sql语句中关键才是不区分大小写的，但是指定的字符串是区分大小写的，字符串使用单引号。


and & or
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

and的功能就是把多个where语句组合起来，每个条件都成立才处理后续。

or的功能就是把多个where语句组合起来，任何一个条件成立就处理。

样例

.. code-block:: sql

    SELECT * FROM Persons WHERE FirstName='Thomas' AND LastName='Carter'

    SELECT * FROM Persons WHERE (FirstName='Thomas' OR FirstName='William')
    AND LastName='Carter'

order by 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

order by 语句用于根据指定列来对查询的结果进行排序。

样例

.. code-block:: sql

    -- 按照company字母排序（默认升序）
    SELECT Company, OrderNumber FROM Orders ORDER BY Company
    -- 按照company排序，如果相同在按照ordernumber排序
    SELECT Company, OrderNumber FROM Orders ORDER BY Company, OrderNumber
    -- 按照 company排序，指定为降序排
    SELECT Company, OrderNumber FROM Orders ORDER BY Company DESC
    -- 按照 company降序排，如果相同就在按照ordernumber排序
    SELECT Company, OrderNumber FROM Orders ORDER BY Company DESC, OrderNumber ASC

insert
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

insert 语句用于向表中插入新的数据行

语法： 

.. code-block:: sql

    INSERT INTO 表名称 VALUES (值1, 值2,....)
    INSERT INTO table_name (列1, 列2,...) VALUES (值1, 值2,....)

样例：

.. code-block:: sql

    INSERT INTO Persons VALUES ('Gates', 'Bill', 'Xuanwumen 10', 'Beijing')


update
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
update 语句用于更新表中的数据行

语法： 

.. code-block:: text

    UPDATE 表名称 SET 列名称 = 新值 WHERE 列名称 = 某值
    UPDATE 表名称 SET 列名称1 = 新值1 ,列名称2 = 新值2  WHERE 列名称 = 某值 

样例：

.. code-block:: sql

    UPDATE Person SET Address = 'Zhongshan 23', City = 'Nanjing'
    WHERE LastName = 'Wilson'


delete
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
delete 语句用于删除表中的数据行

语法： 

.. code-block:: text

    DELETE FROM 表名称 WHERE 列名称 = 值

样例：

.. code-block:: sql

    DELETE FROM Person WHERE LastName = 'Wilson' 

.. warning:: 如果不加限定条件，默认是删除所有行数据， 很危险的。

sql中级
-------------------------------------------------------------------------

top
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
top用于从规定的结果集合中去除指定的条数，尤其在大型表来说非常有用

语法： 

.. code-block:: sql

    SELECT TOP number|percent column_name(s) FROM table_name

    -- oralce语法
    SELECT column_name(s)
    FROM table_name
    WHERE ROWNUM <= number

样例：

.. code-block:: sql

    SELECT TOP 2 * FROM Persons
    SELECT TOP 50 PERCENT * FROM Persons

    -- oralce样例
    SELECT * FROM Persons WHERE ROWNUM <= 2

like
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
like操作符用于在where语句中搜索指定模式

.. code-block:: sql

    SELECT column_name(s)
    FROM table_name
    WHERE column_name LIKE pattern

样例：

.. code-block:: sql

    SELECT * FROM Persons WHERE City LIKE 'N%'


通配符
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
上面已经使用了"%"通配符了

.. csv-table:: 
   :header: "通配符","描述"
   :widths: 30,40

   "%",替代一个或多个字符
   "_",仅仅替代一个字符
   "[charlist]",字符列中的任何一个单一字符
   "[^charlist]",不再字符列中的任何字符

样例： 

.. code-block:: sql

    --开头为A,或者L,或者N的
    SELECT * FROM Persons WHERE City LIKE '[ALN]%'
    --包含lond
    SELECT * FROM Persons WHERE City LIKE '%lond%'
    

in
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
IN 操作符允许我们在 WHERE 子句中规定多个值。

语法：

.. code-block:: sql

    SELECT column_name(s)
    FROM table_name
    WHERE column_name IN (value1,value2,...)

样例： 

.. code-block:: sql

    SELECT * FROM Persons WHERE LastName IN ('Adams','Carter')
    --等价于
    SELECT * FROM Persons WHERE LastName = 'Adams' or LastName ='Carter'

between
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
between用于选定介于两个值之间的数据范围，值类型可以是数值的，可以是字符和日期的。

语法： 

.. code-block:: sql

    SELECT column_name(s)
    FROM table_name
    WHERE column_name
    BETWEEN value1 AND value2

样例： 

.. code-block:: sql

    SELECT * FROM Persons
    WHERE LastName
    BETWEEN 'Adams' AND 'Carter'

.. important:: 有些数据对between and 这个语句差异很大的，有些是左开右闭，有些是两个都是闭区间。


aliases
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
表和列都是支持别名的。

语法：

.. code-block:: sql

    --表的
    SELECT column_name(s) FROM table_name AS alias_name
    --列的
    SELECT column_name AS alias_name FROM table_name

样例： 

.. code-block:: sql

    SELECT po.OrderID, p.LastName, p.FirstName
    FROM Persons AS p, Product_Orders AS po
    WHERE p.LastName='Adams' AND p.FirstName='John'

join
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
join用于多表连接，获取多个表的数据。

.. code-block:: sql

    SELECT Persons.LastName, Persons.FirstName, Orders.OrderNo
    FROM Persons, Orders
    WHERE Persons.Id_P = Orders.Id_P 

    SELECT Persons.LastName, Persons.FirstName, Orders.OrderNo
    FROM Persons
    INNER JOIN Orders
    ON Persons.Id_P = Orders.Id_P
    ORDER BY Persons.LastName

下面列出了您可以使用的 JOIN 类型，以及它们之间的差异。

#. JOIN: 如果表中有至少一个匹配，则返回行
#. LEFT JOIN: 即使右表中没有匹配，也从左表返回所有的行
#. RIGHT JOIN: 即使左表中没有匹配，也从右表返回所有的行
#. FULL JOIN: 只要其中一个表中存在匹配，就返回行  

inner join
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

inner join 和join 是一样的。

right join
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
RIGHT JOIN 关键字会右表 (table_name2) 那里返回所有的行，即使在左表 (table_name1) 中没有匹配的行。

样例： 

.. code-block:: sql

    SELECT column_name(s)
    FROM table_name1
    RIGHT JOIN table_name2 
    ON table_name1.column_name=table_name2.column_name

left join
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
LEFT JOIN 关键字会从左表 (table_name1) 那里返回所有的行，即使在右表 (table_name2) 中没有匹配的行。

样例： 

.. code-block:: sql

    SELECT Persons.LastName, Persons.FirstName, Orders.OrderNo
    FROM Persons
    LEFT JOIN Orders
    ON Persons.Id_P=Orders.Id_P
    ORDER BY Persons.LastName

full join 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
只要其中某个表存在匹配，FULL JOIN 关键字就会返回行。

.. code-block:: sql

    SELECT column_name(s)
    FROM table_name1
    FULL JOIN table_name2 
    ON table_name1.column_name=table_name2.column_name

union
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
union 用于合并2个或者多个查询语句的结果集合

.. note:: 多个结果集合需要列数量相同，且对应列数据类型相似。

样例： 

.. code-block:: sql

    SELECT E_Name FROM Employees_China
    UNION
    SELECT E_Name FROM Employees_USA
    -- UNION ALL 不去重复，union去重的。
    SELECT E_Name FROM Employees_China
    UNION ALL
    SELECT E_Name FROM Employees_USA

select into 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
select into 用于从一个表中选取数据，然后插入到另一个表中。

.. code-block:: sql

    SELECT *
    INTO Persons_backup
    FROM Persons

create db   
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
CREATE DATABASE 用于创建数据库。

.. code-block:: sql

    CREATE DATABASE my_db

create table
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
create table 用于创建表

语法： 

.. code-block:: sql

    CREATE TABLE 表名称
    (
        列名称1 数据类型,
        列名称2 数据类型,
        列名称3 数据类型,
        ....
    )

样例： 

.. code-block:: sql

    CREATE TABLE Persons
    (
        Id_P int,
        LastName varchar(255),
        FirstName varchar(255),
        Address varchar(255),
        City varchar(255)
    )


constraints
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
约束用于限制加入表的数据的类型。

可以在创建表时规定约束（通过 CREATE TABLE 语句），或者在表创建之后也可以（通过 ALTER TABLE 语句）。

我们将主要探讨以下几种约束：

- NOT NULL     非空约束
- UNIQUE       唯一约束
- PRIMARY KEY  主键约束
- FOREIGN KEY  外键约束
- CHECK        值检查约束
- DEFAULT      默认值
- not null     非空约束



not null
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
not null 用于约束特定列不能为空。

样例： 

.. code-block:: sql

    CREATE TABLE Persons
    (
    Id_P int NOT NULL,
    LastName varchar(255) NOT NULL,
    FirstName varchar(255),
    Address varchar(255),
    City varchar(255)
    )
    
unique
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
unique用于约束列值是唯一的，但是可以有一个为空，不能有多个空。

.. code-block:: sql

    --mysql
    CREATE TABLE Persons
    (
    Id_P int NOT NULL,
    LastName varchar(255) NOT NULL,
    FirstName varchar(255),
    Address varchar(255),
    City varchar(255),
    UNIQUE (Id_P)
    )
    --SQL Server / Oracle / MS Access
    CREATE TABLE Persons
    (
    Id_P int NOT NULL UNIQUE,
    LastName varchar(255) NOT NULL,
    FirstName varchar(255),
    Address varchar(255),
    City varchar(255)
    )
    --通用方法
    CREATE TABLE Persons
    (
    Id_P int NOT NULL,
    LastName varchar(255) NOT NULL,
    FirstName varchar(255),
    Address varchar(255),
    City varchar(255),
    CONSTRAINT uc_PersonID UNIQUE (Id_P,LastName)
    )

    ALTER TABLE Persons
    ADD CONSTRAINT uc_PersonID UNIQUE (Id_P,LastName)
    ALTER TABLE Persons
    DROP CONSTRAINT uc_PersonID

primary key
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
primary key 用于唯一标示数据库表的每条记录，主键必须是唯一的，不能包含空，只能有一个主键，可以多列组合一个主键。

.. code-block:: sql

    --MySQL
    CREATE TABLE Persons
    (
    Id_P int NOT NULL,
    LastName varchar(255) NOT NULL,
    FirstName varchar(255),
    Address varchar(255),
    City varchar(255),
    PRIMARY KEY (Id_P)
    )
    --SQL Server / Oracle / MS Access:
    CREATE TABLE Persons
    (
    Id_P int NOT NULL PRIMARY KEY,
    LastName varchar(255) NOT NULL,
    FirstName varchar(255),
    Address varchar(255),
    City varchar(255)
    )
    --MySQL / SQL Server / Oracle / MS Access:
    CREATE TABLE Persons
    (
    Id_P int NOT NULL,
    LastName varchar(255) NOT NULL,
    FirstName varchar(255),
    Address varchar(255),
    City varchar(255),
    CONSTRAINT pk_PersonID PRIMARY KEY (Id_P,LastName)
    )
    ALTER TABLE Persons
    ADD CONSTRAINT pk_PersonID PRIMARY KEY (Id_P,LastName)  

foreign key 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
一个表中的 FOREIGN KEY 指向另一个表中的 PRIMARY KEY。

.. code-block:: sql

    --MySQL
    CREATE TABLE Orders
    (
        Id_O int NOT NULL,
        OrderNo int NOT NULL,
        Id_P int,
        PRIMARY KEY (Id_O),
        FOREIGN KEY (Id_P) REFERENCES Persons(Id_P)
    )
    --SQL Server / Oracle / MS Access
    CREATE TABLE Orders
    (
        Id_O int NOT NULL PRIMARY KEY,
        OrderNo int NOT NULL,
        Id_P int FOREIGN KEY REFERENCES Persons(Id_P)
    )

    --MySQL / SQL Server / Oracle / MS Access:
    CREATE TABLE Orders
    (
        Id_O int NOT NULL,
        OrderNo int NOT NULL,
        Id_P int,
        PRIMARY KEY (Id_O),
        CONSTRAINT fk_PerOrders FOREIGN KEY (Id_P)
        REFERENCES Persons(Id_P)
    )

    --MySQL / SQL Server / Oracle / MS Access:
    ALTER TABLE Orders
    ADD FOREIGN KEY (Id_P)
    REFERENCES Persons(Id_P)
    如果需要命名 FOREIGN KEY 约束，以及为多个列定义 FOREIGN KEY 约束，请使用下面的 SQL 语法：

    --MySQL / SQL Server / Oracle / MS Access:
    ALTER TABLE Orders
    ADD CONSTRAINT fk_PerOrders
    FOREIGN KEY (Id_P)
    REFERENCES Persons(Id_P)

    --MySQL:
    ALTER TABLE Orders
    DROP FOREIGN KEY fk_PerOrders
    --SQL Server / Oracle / MS Access:
    ALTER TABLE Orders
    DROP CONSTRAINT fk_PerOrders

check
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
CHECK 约束用于限制列中的值的范围。

.. code-block:: sql

    --My SQL:
    CREATE TABLE Persons
    (
        Id_P int NOT NULL,
        LastName varchar(255) NOT NULL,
        FirstName varchar(255),
        Address varchar(255),
        City varchar(255),
        CHECK (Id_P>0)
    )
    --SQL Server / Oracle / MS Access:
    CREATE TABLE Persons
    (
        Id_P int NOT NULL CHECK (Id_P>0),
        LastName varchar(255) NOT NULL,
        FirstName varchar(255),
        Address varchar(255),
        City varchar(255)
    )

    --MySQL / SQL Server / Oracle / MS Access:
    CREATE TABLE Persons
    (
        Id_P int NOT NULL,
        LastName varchar(255) NOT NULL,
        FirstName varchar(255),
        Address varchar(255),
        City varchar(255),
        CONSTRAINT chk_Person CHECK (Id_P>0 AND City='Sandnes')
    )

    --MySQL / SQL Server / Oracle / MS Access:
    ALTER TABLE Persons
    ADD CHECK (Id_P>0)

    --MySQL / SQL Server / Oracle / MS Access:
    ALTER TABLE Persons
    ADD CONSTRAINT chk_Person CHECK (Id_P>0 AND City='Sandnes')

    --SQL Server / Oracle / MS Access:
    ALTER TABLE Persons
    DROP CONSTRAINT chk_Person
    --MySQL:
    ALTER TABLE Persons
    DROP CHECK chk_Person

default
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
DEFAULT 约束用于向列中插入默认值。

.. code-block:: sql

    --My SQL / SQL Server / Oracle / MS Access:
    CREATE TABLE Persons
    (
    Id_P int NOT NULL,
    LastName varchar(255) NOT NULL,
    FirstName varchar(255),
    Address varchar(255),
    City varchar(255) DEFAULT 'Sandnes'
    )
    --MySQL:
    ALTER TABLE Persons
    ALTER City SET DEFAULT 'SANDNES'
    --SQL Server / Oracle / MS Access:
    ALTER TABLE Persons
    ALTER COLUMN City SET DEFAULT 'SANDNES'

    --MySQL:
    ALTER TABLE Persons
    ALTER City DROP DEFAULT
    --SQL Server / Oracle / MS Access:
    ALTER TABLE Persons
    ALTER COLUMN City DROP DEFAULT

create index
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
create index 语句可以在表中创建索引，加快数据的查找。

.. code-block:: sql

    CREATE INDEX PersonIndex ON Person (LastName) 
    CREATE UNIQUE INDEX PersonIndex ON Person (LastName) 


drop
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
drop 用于删除表中的部分对象

删除索引

.. code-block:: sql

    --用于 Microsoft SQLJet (以及 Microsoft Access) 的语法:
    DROP INDEX index_name ON table_name
    --用于 MS SQL Server 的语法:
    DROP INDEX table_name.index_name
    --用于 IBM DB2 和 Oracle 语法:
    DROP INDEX index_name
    --用于 MySQL 的语法:
    ALTER TABLE table_name DROP INDEX index_name

删除表

.. code-block:: text

    drop table 表名称

删除数据库

.. code-block:: text

    drop database 数据库名字

truncate表

.. code-block:: text

    truncate table 表名称

alter 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ALTER TABLE 语句用于在已有的表中添加、修改或删除列。

.. code-block:: sql

    ALTER TABLE Persons ADD Birthday date
    ALTER TABLE Persons ALTER COLUMN Birthday year
    ALTER TABLE Person DROP COLUMN Birthday

increment
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
自增会在插入记录的时候自动的创建主键字段的值

关于自增各个语言的差异还是很大的。

.. code-block:: sql

    --mysql
    CREATE TABLE Persons
    (
    P_Id int NOT NULL AUTO_INCREMENT,
    LastName varchar(255) NOT NULL,
    FirstName varchar(255),
    Address varchar(255),
    City varchar(255),
    PRIMARY KEY (P_Id)
    )
    --sqlserver 
    CREATE TABLE Persons
    (
    P_Id int PRIMARY KEY IDENTITY,
    LastName varchar(255) NOT NULL,
    FirstName varchar(255),
    Address varchar(255),
    City varchar(255)
    )
    --access 
    CREATE TABLE Persons
    (
    P_Id int PRIMARY KEY AUTOINCREMENT,
    LastName varchar(255) NOT NULL,
    FirstName varchar(255),
    Address varchar(255),
    City varchar(255)
    )
    --Oracle
    CREATE SEQUENCE seq_person
    MINVALUE 1
    START WITH 1
    INCREMENT BY 1
    CACHE 10
    INSERT INTO Persons (P_Id,FirstName,LastName)
    VALUES (seq_person.nextval,'Lars','Monsen')

.. note:: 上面的方法中，oracle最为麻烦，插入数据很不方便，可以考虑使用触发器。


view
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
视图包含行和列，像一个真实的表，

样例： 

.. code-block:: sql

    CREATE VIEW [Current Product List] AS
    SELECT ProductID,ProductName
    FROM Products
    WHERE Discontinued=No

    DROP VIEW view_name

isnull
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
null代表是未知的，不确定的。 

样例： 

.. code-block:: sql

    SELECT LastName,FirstName,Address FROM Persons
    WHERE Address IS NULL

    SELECT LastName,FirstName,Address FROM Persons
    WHERE Address IS NOT NULL

.. warning:: 不能使"列名字=NULL"这种方式的。


数据类型
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

数据类型_

.. _数据类型: http://www.w3school.com.cn/sql/sql_datatypes.asp


