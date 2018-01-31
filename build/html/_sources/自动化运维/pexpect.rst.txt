pexpect
========================================================

pexpect 可以理解成Linux下的expect的python封装，通过pexpect我们可以自动实现对ssh,ftp等
命令行进行自动交互，无需人工干涉。
pexpect官方文档_

.. _pexpect官方文档: http://pexpect.readthedocs.io

pexpect的安装
------------------------------------------------------

.. code-block:: bash

    pip install pexpect
    [root@102 ~]$ python 
    Python 2.7.5 (default, Aug  4 2017, 00:39:18) 
    [GCC 4.8.5 20150623 (Red Hat 4.8.5-16)] on linux2
    Type "help", "copyright", "credits" or "license" for more information.
    >>> import pexpect

spawn类
------------------------------------------------------

spawn是pexpect的主要类接口，功能是启动和控制子应用程序

构造函数

.. code-block:: python

    __init__(command, args=[], timeout=30, maxread=2000, searchwindowsize=None, 
    logfile=None, cwd=None, env=None, ignore_sighup=False, echo=True,
    preexec_fn=None, encoding=None, codec_errors='strict', dimensions=None)

样例使用

.. code-block:: python

    child = pexpect.spawn('/usr/bin/ftp')
    child = pexpect.spawn('/usr/bin/ssh user@example.com')
    child = pexpect.spawn('ls -latr /tmp')

如果bash命令中有重定向符号等特殊符号，需要稍作修改。

.. code-block:: bash

    child = pexpect.spawn('/bin/bash -c "ls -l | grep LOG > logs.txt"')
    child.expect(pexpect.EOF)

run函数
------------------------------------------------------

run函数使用pexpect进行风中的调用外部命令的函数，类似域os.system或者os.popen方法，不同的是
使用run可以同时获取到命令的输出结果和命令的退出状态。

样例

.. code-block:: python

    from pexpect import *
    (command_output, exitstatus) = run('ls -l /bin', withexitstatus=1)
    print(command_output)
    print(exitstatus)

pxssh类
------------------------------------------------------

这个类提供了ssh会话的扩展功能，提供login,logout等方法， 更方便交互提示自动化。

类构造

.. code-block:: python

    class pexpect.pxssh.pxssh(timeout=30, maxread=2000, searchwindowsize=None, logfile=None,
    cwd=None, env=None, ignore_sighup=True, echo=True, options={}, encoding=None,
    codec_errors='strict')

常见样例脚本
------------------------------------------------------

脚本_

.. _脚本: http://pexpect.readthedocs.io/en/stable/examples.html