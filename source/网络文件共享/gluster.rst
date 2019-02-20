glusterfs 
==========================


.. code-block:: language


# 安装gluster服务
  wget -P /etc/yum.repos.d http://download.gluster.org/pub/gluster/glusterfs/LATEST/EPEL.repo/glusterfs-epel.rep
   61  yum install centos-release-gluster
   62  yum install -y glusterfs glusterfs-server glusterfs-fuse glusterfs-rdma
   63  systemctl start glusterd.service
   64  systemctl enable glusterd.service'
   65  systemctl enable glusterd.service
   # 探测节点
   66  gluster peer probe node02 
   # 查看状态
   67  gluster peer status 
   # 准备数据
   68   mkdir -p /data/gluster/data
   69   mkdir /data/gluster/data   -pv 
   # 查看卷信息
   70  gluster volume info 
   # 创建卷
   72  gluster volume create models replica 2 node01:/data/gluster/data node02:/data/gluster/data force
   73  gluster volume info 
   # 启动卷
   74  gluster volume start models 
   # 客户端安装驱动
   75  yum install -y glusterfs glusterfs-fuse
   # 挂载测试
    mount -t glusterfs node01:models /mnt/gfs


    