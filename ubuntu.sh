#!/bin/bash

# ssh
apt install -y openssh-server
sed -i "s/#Port 22/Port 31011/g" /etc/ssh/sshd_config
sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config
sed -i "s/#PasswordAuthentication yes/PasswordAuthentication yes/g" /etc/ssh/sshd_config
systemctl restart ssh && systemctl enable ssh

# mysql
apt install -y mysql-server-5.7
sed -i "s/3306/31012/g" /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql && systemctl enable mysql

# cat /etc/mysql/debian.cnf|grep password
# mysql -udebian-sys-maint -p
# mysql> update mysql.user set authentication_string=password('root') where user='root'and Host = 'localhost';
# mysql> update mysql.user set plugin="mysql_native_password";
# mysql> GRANT ALL PRIVILEGES ON *.* TO mysql@'%' IDENTIFIED BY 'mysql';


# rabbitmq
apt install -y rabbitmq-server

cat <<EOF >/etc/rabbitmq/rabbitmq.config
[
 {rabbit,
  [%%
  %% Network Connectivity
  %% ====================
  %%
  %% By default, RabbitMQ will listen on all interfaces, using
  %% the standard (reserved) AMQP port.
  %%
  {tcp_listeners, [5672]},
  {loopback_users, ["guest"]}
  ]}
].
EOF

rabbitmq-plugins enable rabbitmq_management
systemctl restart rabbitmq-server && systemctl enable rabbitmq-server


# nginx
apt install -y nginx
rm -rf /etc/nginx/sites-enabled/*

cat <<EOF >/etc/nginx/conf.d/web.conf
upstream your_front {
  server 127.0.0.1:38080;
}

upstream your_back {
  server 127.0.0.1:8080;
}

server {
  listen 80;
  server_name frontdomain.com;

  location /yourstatic {
    root /opt/static/;
  }

  location ~* \.(txt)$ {
    root /opt/static/weixin;
  }

  location / {
    proxy_http_version 1.1;
    proxy_redirect off;
    proxy_pass http://your_front;
  }
  access_log /var/log/nginx/your_front.log;
}

server {
  listen 80;
  server_name backdomain.com;

  location ~^/favicon.ico$ {
    root /opt/tomcat/apps/your_back;
  }

  location / {
    proxy_http_version 1.1;
    proxy_redirect     off;
    proxy_pass http://your_back;
  }
  access_log /var/log/nginx/your_back.log;
}
EOF

systemctl restart nginx && systemctl enable nginx

# tomcat
wget http://www.monsterk.cn/file/apache-tomcat-8.5.37.tar.gz
tar zxvf apache-tomcat-8.5.37.tar.gz
mv apache-tomcat-8.5.37 /opt/tomcat
rm -rf /opt/tomcat/webapps/*
mkdir /opt/tomcat/apps

wget http://www.monsterk.cn/file/jre-8u191-linux-x64.tar.gz
tar zxvf jre-8u191-linux-x64.tar.gz
mv jre1.8.0_191 /usr/local/jre

cat <<EOF >/etc/profile.d/jre.sh
export JRE_HOME=/usr/local/jre
export CLASSPATH=.:$JRE_HOME/lib
export PATH=$PATH:$JRE_HOME/bin
EOF

source /etc/profile.d/jre.sh


# redis
apt install -y redis
sed -i "s/bind 127.0.0.1/# bind 127.0.0.1/g" /etc/redis/redis.conf
sed -i "s/6379/31013/g" /etc/redis/redis.conf
sed -i "s/# requirepass foobared/requirepass 123456/g" /etc/redis/redis.conf
sed -i "s/notify-keyspace-events \"\"/notify-keyspace-events Ex/g" /etc/redis/redis.conf

systemctl restart redis && systemctl enable redis


# squid
apt install -y squid

cat <<EOF >/etc/squid/squid.conf
http_port 3128
http_port 3129 intercept
cache_mem 64 MB
maximum_object_size 10 MB
cache_dir ufs /var/spool/squid 100 16 256
access_log /var/log/squid/access.log
acl localnet src 192.168.0.0/24
http_access allow localnet
http_access deny all
EOF

systemctl restart squid && systemctl enable squid


# privoxy
apt install -y privoxy

cat <<EOF >/etc/privoxy/config
user-manual /usr/share/doc/privoxy/user-manual
confdir /etc/privoxy
logdir /var/log/privoxy
actionsfile match-all.action
actionsfile default.action
actionsfile user.action
filterfile default.filter
filterfile user.filter
logfile logfile
toggle 1
enable-remote-toggle 0
enable-remote-http-toggle 0
enable-edit-actions 0
enforce-blocks 0
buffer-limit 4096
enable-proxy-authentication-forwarding 0
forwarded-connect-retries  0
accept-intercepted-requests 0
allow-cgi-request-crunching 0
split-large-forms 0
keep-alive-timeout 5
tolerate-pipelining 1
socket-timeout 300
permit-access 192.168.0.0/24
deny-access www.example.com
listen-address 0.0.0.0:8118
#forward-socks5t / 127.0.0.1:1080 .
EOF

systemctl restart privoxy && systemctl enable privoxy


# shadowsocks
apt install -y shadowsocks

cat <<EOF >/etc/shadowsocks/server.json
{
 "server":"0.0.0.0",
 "server_port":38388,
 "password":"123456",
 "timeout":600,
 "method":"aes-256-cfb"
}
EOF

ssserver -c /etc/shadowsocks/server.json -d start

cat <<EOF >/etc/shadowsocks/local.json
{
 "server":"server_ip",
 "server_port":server_port,
 "local_address": "127.0.0.1",
 "local_port":1080,
 "password":"server_password",
 "timeout":600,
 "method":"aes-256-cfb"
}
EOF

sslocal -c /etc/shadowsocks/local.json -d start


# supervisor
apt install -y supervisor

cat <<EOF >/etc/supervisor/conf.d/shadowsocks.conf
[program:ssserver]
command=ssserver -c /etc/shadowsocks/server.json
redirect_stderr=true
stdout_logfile=/var/log/supervisor/ssserver.log
stdout_logfile_maxbytes=1MB
stdout_logfile_backups=5

[program:sslocal]
command=sslocal -c /etc/shadowsocks/local.json
redirect_stderr=true
stdout_logfile=/var/log/supervisor/sslocal.log
stdout_logfile_maxbytes=1MB
stdout_logfile_backups=5
EOF

systemctl restart supervisor && systemctl enable supervisor