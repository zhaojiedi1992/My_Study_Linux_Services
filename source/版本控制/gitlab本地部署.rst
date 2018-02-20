gitlab本地部署
===========================================

安装和配置必要的依赖
-----------------------------------------------

.. code-block:: bash

    [root@centos-7 ~]# yum install postfix 
    [root@centos-7 ~]# systemctl start postfix
    [root@centos-7 ~]# systemctl enable postfix

如果postfix启动不起来，提示no local interface found for ::1。可以修改下
/etc/postfix/main.cf中inet_interfaces = all。

添加gitlab的仓库并安装包
------------------------------------------------------

执行脚本添加
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    [root@centos-7 ~]# curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash
    [root@centos-7 ~]# yum -y install gitlab-ce

.. note:: 这个包大概440M大小，需要一定的等待时间。

手工添加
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    [root@centos-7 yum.repos.d]# vim gitlab-ce.repo
    [gitlab-ce]
    name=Gitlab CE Repository
    baseurl=https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/
    gpgcheck=0
    enabled=1

这个使用清华的镜像，没有使用国外的，下载可能会快点。

修改配置文件的url
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash 

    [root@centos-7 src]# vim /etc/gitlab/gitlab.rb 
    external_url 'http://localhost'

启动下gitlab
---------------------------------------------------------

启动gitlab

.. code-block:: bash

    [root@centos-7 src]# systemctl enable gitlab-runsvdir.service
    [root@centos-7 src]# gitlab-ctl  reconfigure

这个配置大概需要10多分钟，耐心等待，我是centos7的系统，安装一直有问题。

错误修复

.. code-block:: bash 

    [root@www ~]# yum install gem 
    [root@www ~]# gem sources --add https://gems.ruby-china.org/ --remove https://rubygems.org/
    [root@centos-7 src]# gitlab-ctl  reconfigure

测试
------------------------------------------------------

.. image:: /images/git/gitlab登陆.png

登陆账号root,密码：5iveL!fe

.. image:: /images/git/gitlab修改密码.png

.. image:: /images/git/gitlab登陆2.png

.. image:: /images/git/gitlab主页.png

禁止注册
---------------------------------------------

公司内部是禁止注册的，需要的话练习管理员给开账号。

.. image:: /images/git/gitlab禁止注册.png

参考
---------------------------------------------

官方参考_

.. _官方参考:  https://about.gitlab.com/installation/

