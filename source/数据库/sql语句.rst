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

delete
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

select 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
