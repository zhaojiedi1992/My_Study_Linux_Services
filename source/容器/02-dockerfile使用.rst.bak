dockerfile使用
===========================

dockerfile官方参考_ 

.. _dockerfile官方参考: https://docs.docker.com/engine/reference/builder/#escape


主要命令
-------------------------------------------------

.. code-block:: text 

    FROM            指明镜像的从那个镜像的基础上。 
    ARG:            指明build阶段的变量
    ENV:            指明run阶段的变量
    LABEL:          指明当前指向的一些元数据信息，如果作者信息，镜像生成日期。
    COPY:           复制工作目录的内容到容器中。
    ADD:            COPY的加强版本，支持网络资源和自动tar解包
    WORKDIR:        命令的设定工作目录
    VOLUME:         定义卷
    EXPOSE:         用于给容器打开外部通信端口
    RUN:            build构建阶段运行的命令
    CMD:            run阶段运行的命令，通常只是ENTRYPOINT的参数
    ENTRYPOINT:     程序的默认的运行进入点程序，通常需要容器cmd程序设置些环境准备工作。 
    USER:           指定程序运行的用户和用户组
    STOPSIGNAL:     终止信号
    HEALTHCHECK:    健康检查
    SHELL:          指定解释器
    ONBUILD:        在别人FROM你的这个镜像的时候执行

制作nginx镜像
--------------------------------------------------

我们从centos镜像的基础上面制作nginx的镜像

.. code-block:: bash 

    [root@centos-151 ~]# docker pull centos
    [root@centos-151 ~]# docker image ls 
    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    docker.io/centos    latest              e934aafc2206        11 hours ago        199 MB

    [root@centos-151 ~]# mkdir images 
    [root@centos-151 ~]# cd images/
    [root@centos-151 images]# mkdir nginx
    [root@centos-151 images]# cd nginx/
    [root@centos-151 nginx]# ls
    [root@centos-151 nginx]# pwd
    /root/images/nginx

    [root@centos-151 nginx]# cat Dockerfile 
    ######################################################################
    #name: zhaojiedi1992
    #created: 2018-04-07
    #github:  https//github.com/zhaojiedi1992/nginx
    ######################################################################
    FROM centos:latest

    LABEL maintainer="LinuxPanda <zhaojiedi1992@outlook.com>"
    ADD  http://download2.linuxpanda.tech/yum/epel-7.repo /etc/yum.repos.d/epel-7.repo 
    ADD  http://download2.linuxpanda.tech/yum/ali-7.repo  /etc/yum.repos.d/ali-7.repo

    RUN     mkdir "/etc/yum.repos.d/bak" \
        && mv /etc/yum.repos.d/Cent*.repo /etc/yum.repos.d/bak/ \
        && yum  clean all \
    #	&& rm -rf /var/cache/yum \
        && yum install nginx  -y -q \
        && echo "daemon off;" >> /etc/nginx/nginx.conf 

    #VOLUME [ "/var/www/html"]
    ADD     entrypoint.sh   /bin/enterpoint.sh
    ENTRYPOINT [ "/bin/enterpoint.sh" ]
    CMD ["nginx"]

    EXPOSE 80
    #EXPOSE 443/tcp 

    HEALTHCHECK --interval=10s --timeout=20s  --retries=3 CMD kill -0 nginx && exit 0 || exit 1

    [root@centos-151 nginx]# cat entrypoint.sh 
    #!/bin/bash 

    PORT=${PORT:-80}
    sed -r -i "s@(.*listen.*)80(.*)@\1${PORT}\2@g" /etc/nginx/nginx.conf
    exec "$@"

    [root@centos-151 nginx]# docker build -t nginx:v2 . 
    [root@centos-151 nginx]# docker image ls 
    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    nginx               v2                  6d458ae074a1        10 seconds ago      388 MB
    docker.io/centos    latest              e934aafc2206        15 hours ago        199 MB
    [root@centos-151 nginx]# docker run -d  -P --name nginxv2-01 nginx:v2 
    81a995340911b5776429144fbd5ea94f335c2b6b01a3a9610f7114d601cd5a25
    [root@centos-151 nginx]# docker inspect nginxv2-01 |grep -i ipa 
                "SecondaryIPAddresses": null,
                "IPAddress": "172.17.0.2",
                        "IPAMConfig": null,
                        "IPAddress": "172.17.0.2",
    [root@centos-151 nginx]# curl 172.17.0.2
