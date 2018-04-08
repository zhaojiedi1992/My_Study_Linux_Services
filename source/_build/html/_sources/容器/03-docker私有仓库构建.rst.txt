docker私有仓库构建
======================================

github:  habor_ 

.. _habor: https://github.com/vmware/harbor

habor安装
---------------------------------------

.. code-block:: bash 

    [root@centos-151 harbor]# yum install docker-compose docker 
    [root@centos-151 ~]# wget https://storage.googleapis.com/harbor-releases/release-1.4.0/harbor-offline-installer-v1.4.0.tgz
    [root@centos-151 ~]# tar xf harbor-offline-installer-v1.4.0.tgz 
    [root@centos-151 harbor]# vim harbor.cfg 
    # 修改如下4行
    hostname = registry.linuxpanda.tech
    customize_crt = off
    harbor_admin_password =  harbor
    db_password = harbor

    [root@centos-151 harbor]# ./install.sh 

web访问
----------------------------------------------------

.. image:: /images/docker/harbor登陆.png

.. image:: /images/docker/harbor管理主页.png

.. image:: /images/docker/harbor注册账号.png

.. image:: /images/docker/harbor新建项目.png
