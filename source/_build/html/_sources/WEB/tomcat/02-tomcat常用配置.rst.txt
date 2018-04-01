tomcat常用配置
====================================

部署
-------------------------------------

.. code-block:: bash 

    [root@centos-151 ~]# mkdir -pv /usr/share/tomcat/webapps/test/{classes,lib,WEB-INF,META-INF}

    [root@centos-151 ~]# cat /usr/share/tomcat/webapps/test/index.jsp
    <%@ page language="java" %>
    <%@ page import="java.util.*" %>
    <html>
        <head>
            <title>Test Page</title>
        </head>
        <body>
            <% out.println("hello world");
            %>
        </body>
    </html>		

    [root@centos-151 test]# curl 192.168.46.151:8080/test/


    <html>
        <head>
            <title>Test Page</title>
        </head>
        <body>
            hello world

        </body>
    </html>	

主机管理启用
---------------------------------

.. code-block:: bash 

    [root@centos-151 tomcat]# vim tomcat-users.xml 
    # 添加如下2行
    <role rolename="admin-gui"/>
    <user username="tomcat" password="tomcat" roles="admin-gui"/>

浏览器访问： http://192.168.46.151:8080/host-manager/

.. image:: /images/web/tomcat-host-manager.png


app管理启用
---------------------------------

.. code-block:: bash 

    [root@centos-151 tomcat]# vim tomcat-users.xml 
    # 添加如下2行
    <role rolename="manager-gui"/>
    <user username="tomcat" password="tomcat" roles="manager-gui"/>

浏览器访问： http://192.168.46.151:8080/manager/

.. image:: /images/web/tomcat-manager.png


nginx代理tomcat
-------------------------------------

.. code-block:: bash 

    [root@centos-151 nginx]# vim nginx.conf
    # 在默认的server中添加如下行
            root          /usr/share/tomcat/webapps/ROOT ;
            index     index.jsp ; 
            location ~* \.(jsp|do)$  {
                    proxy_pass http://127.0.0.1:8080;
            }

浏览器测试：http://192.168.46.151/



httpd代理tomcat
-------------------------------------

.. code-block:: bash 

			<VirtualHost *:80>
				ServerName      www.linuxpanda.tech
				ProxyRequests Off
				ProxyVia        On
				ProxyPreserveHost On
				<Proxy *>
					Require all granted
				</Proxy>
				ProxyPass / http://www.linuxpanda.tech:8080/ 
				ProxyPassReverse / http://www.linuxpanda.tech:8080/
				<Location />
					Require all granted
				</Location>
			</VirtualHost>



nginx负载代理tomcat
-------------------------------------

.. code-block:: bash 

    # 配置后端网页
    [root@centos-152 ~]# mkdir -pv /usr/share/tomcat/webapps/test/{classes,lib,WEB-INF,META-INF}
    [root@centos-152 ~]# vim /usr/share/tomcat/webapps/test/index.jsp
    [root@centos-152 ~]# cat /usr/share/tomcat/webapps/test/index.jsp
                        <%@ page language="java" %>
                        <html>
                            <head><title>TomcatA</title></head>
                            <body>
                                <h1><font color="red">TomcatA.magedu.com</font></h1>
                                <table align="centre" border="1">
                                    <tr>
                                        <td>Session ID</td>
                                    <% session.setAttribute("magedu.com","magedu.com"); %>
                                        <td><%= session.getId() %></td>
                                    </tr>
                                    <tr>
                                        <td>Created on</td>
                                        <td><%= session.getCreationTime() %></td>
                                    </tr>
                                </table>
                            </body>
                        </html>
    [root@centos-152 ~]# scp -rp  /usr/share/tomcat/webapps/test/   192.168.46.153:/usr/share/tomcat/webapps/
    [root@centos-153 ~]# vim /usr/share/tomcat/webapps/test/index.jsp 
    [root@centos-153 ~]# cat /usr/share/tomcat/webapps/test/index.jsp
                        <%@ page language="java" %>
                        <html>
                            <head><title>TomcatB</title></head>
                            <body>
                                <h1><font color="red">TomcatB.linuxpanda.tech</font></h1>
                                <table align="centre" border="1">
                                    <tr>
                                        <td>Session ID</td>
                                    <% session.setAttribute("linuxpanda.tech","linuxpanda.tech"); %>
                                        <td><%= session.getId() %></td>
                                    </tr>
                                    <tr>
                                        <td>Created on</td>
                                        <td><%= session.getCreationTime() %></td>
                                    </tr>
                                </table>
                            </body>
                        </html>

    [root@centos-151 nginx]# vim nginx.conf
    # 在默认的server中添加如下行
    upstream webend {
            server 192.168.46.152:8080 ;
            server 192.168.46.153:8080 ;
        }
        #修改server端配置
        server {
            listen       80 default_server;
            listen       [::]:80 default_server;
            server_name  _;
            index index.jsp ;
            #root         /usr/share/nginx/html;
            root          /usr/share/tomcat/webapps/ROOT ;

            # Load configuration files for the default server block.
            include /etc/nginx/default.d/*.conf;

            location / {
            proxy_pass http://webend    ;
            index   index.jsp index.html ;

            }

浏览器测试：http://192.168.46.151/test

.. image:: /images/web/tomcat-a.png


httpd负载代理tomcat
-------------------------------------

.. code-block:: bash 

    [root@centos-151 conf.d]# systemctl restart httpd 
    [root@centos-151 conf.d]# cat vhost.conf
    <proxy balancer://webend>
        ProxySet   lbmethod=byrequests
        BalancerMember  ajp://192.168.46.152:8009
        BalancerMember  ajp://192.168.46.153:8009
    </proxy>

    <VirtualHost *:80>

        ServerName www.linuxpanda.tech 
        ProxyVia on 
        ProxyRequests off
        ProxyPreserveHost on

        ProxyPass /  balancer://webend/
        ProxyPassReverse /  balance://webend/	
        <Proxy *> 
            Require all granted 
        </Proxy> 
        
        <Location / >
            require all granted 
        </location>
    </VirtualHost>


保持会话
-------------------------------------

.. code-block:: bash 

    [root@centos-151 conf.d]# cat vhost.conf
    Header add Set-Cookie "ROUTEID=.%{BALANCER_WORKER_ROUTE}e; path=/" env=BALANCER_ROUTE_CHANGED
    <proxy balancer://webend>
        ProxySet   lbmethod=byrequests
        ProxySet   stickysession=ROUTEID
        BalancerMember  ajp://192.168.46.152:8009 route=TomcatA
        BalancerMember  ajp://192.168.46.153:8009 route=TomcatB
    </proxy>

    <VirtualHost *:80>

        ServerName www.linuxpanda.tech 
        ProxyVia on 
        ProxyRequests off
        ProxyPreserveHost on

        ProxyPass /  balancer://webend/
        ProxyPassReverse /  balance://webend/	
        <Proxy *> 
            Require all granted 
        </Proxy> 
        
        <Location / >
            require all granted 
        </location>
    </VirtualHost>

    [root@centos-151 conf.d]# systemctl restart httpd 

浏览器测试：http://192.168.46.151/test

.. image:: /images/web/tomcat-b.png

tomcat会话集群
-------------------------------------


.. code-block:: bash 

    [root@centos-153 tomcat]# vim server.xml 
    <Engine name="Catalina" defaultHost="localhost" jvmRoute="TomcatB" >
    # 添加如下到/etc/tomcat/service.xml 的engine片段或者host片段中。
            <Cluster className="org.apache.catalina.ha.tcp.SimpleTcpCluster"
                            channelSendOptions="8">

                        <Manager className="org.apache.catalina.ha.session.DeltaManager"
                            expireSessionsOnShutdown="false"
                            notifyListenersOnReplication="true"/>

                        <Channel className="org.apache.catalina.tribes.group.GroupChannel">
                        <Membership className="org.apache.catalina.tribes.membership.McastService"
                                address="228.0.0.4"
                                port="45564"
                                frequency="500"
                                dropTime="3000"/>
                        <Receiver className="org.apache.catalina.tribes.transport.nio.NioReceiver"
                            address="auto"
                            port="4000"
                            autoBind="100"
                            selectorTimeout="5000"
                            maxThreads="6"/>

                        <Sender className="org.apache.catalina.tribes.transport.ReplicationTransmitter">
                        <Transport className="org.apache.catalina.tribes.transport.nio.PooledParallelSender"/>
                        </Sender>
                        <Interceptor className="org.apache.catalina.tribes.group.interceptors.TcpFailureDetector"/>
                        <Interceptor className="org.apache.catalina.tribes.group.interceptors.MessageDispatch15Interceptor"/>
                        </Channel>

                        <Valve className="org.apache.catalina.ha.tcp.ReplicationValve"
                            filter=""/>
                        <Valve className="org.apache.catalina.ha.session.JvmRouteBinderValve"/>

                        <Deployer className="org.apache.catalina.ha.deploy.FarmWarDeployer"
                            tempDir="/tmp/war-temp/"
                            deployDir="/tmp/war-deploy/"
                            watchDir="/tmp/war-listen/"
                            watchEnabled="false"/>

                        <ClusterListener className="org.apache.catalina.ha.session.JvmRouteSessionIDBinderListener"/>
                        <ClusterListener className="org.apache.catalina.ha.session.ClusterSessionListener"/>
                        </Cluster>	

    [root@centos-152 tomcat]# cp web.xml  /usr/share/tomcat/webapps/test/WEB-INF/
    [root@centos-152 tomcat]# vim /usr/share/tomcat/webapps/test/WEB-INF/web.xml 
    # 添加行
    <distributable/>

浏览器测试：http://192.168.46.151/test

.. image:: /images/web/tomcat-c.png


