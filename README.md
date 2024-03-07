# Ubuntu 22.04 常用服务安装


# 配置APT源
```bash
cat <<EOF >/etc/apt/sources.list
deb https://mirrors.ustc.edu.cn/ubuntu/ jammy main restricted
deb https://mirrors.ustc.edu.cn/ubuntu/ jammy-updates main restricted
deb https://mirrors.ustc.edu.cn/ubuntu/ jammy universe
deb https://mirrors.ustc.edu.cn/ubuntu/ jammy-updates universe
deb https://mirrors.ustc.edu.cn/ubuntu/ jammy multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ jammy-updates multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted
deb http://security.ubuntu.com/ubuntu/ jammy-security universe
deb http://security.ubuntu.com/ubuntu/ jammy-security multiverse
EOF

apt update && apt install -y wget
```

# 安装SSH
```bash
apt install -y openssh-server
sed -i "s/#Port 22/Port 30022/g" /etc/ssh/sshd_config
sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config
sed -i "s/#PasswordAuthentication yes/PasswordAuthentication yes/g" /etc/ssh/sshd_config
systemctl enable --now ssh
```

# 安装MySQL
## https://dev.mysql.com/doc/mysql-secure-deployment-guide/5.7/en/secure-deployment-post-install.html
```bash
apt install libncurses5
wget https://downloads.mysql.com/archives/get/p/23/file/mysql-5.7.44-linux-glibc2.12-x86_64.tar.gz
tar zxvf mysql-5.7.44-linux-glibc2.12-x86_64.tar.gz
mv mysql-5.7.44-linux-glibc2.12-x86_64 /opt/mysql
mkdir /opt/mysql/{data,mysql-files,etc,log}

cat <<EOF >/opt/mysql/etc/my.cnf
[mysqld]
datadir=/opt/mysql/data
socket=/tmp/mysql.sock
port=33306
log-error=/opt/mysql/log/localhost.localdomain.err
user=root
secure_file_priv=/opt/mysql/mysql-files
EOF

cat <<EOF >/usr/lib/systemd/system/mysqld.service
[Unit]
Description=MySQL Server
Documentation=man:mysqld(7)
Documentation=http://dev.mysql.com/doc/refman/en/using-systemd.html
After=network.target
After=syslog.target

[Install]
WantedBy=multi-user.target

[Service]
User=root
Group=root
Type=forking
PIDFile=/opt/mysql/mysqld.pid

# Disable service start and stop timeout logic of systemd for mysqld service.
TimeoutSec=0

# Start main service
ExecStart=/opt/mysql/bin/mysqld --defaults-file=/opt/mysql/etc/my.cnf --daemonize --pid-file=/opt/mysql/mysqld.pid

# Sets open_files_limit
LimitNOFILE = 5000
Restart=on-failure
RestartPreventExitStatus=1
PrivateTmp=false
EOF

/opt/mysql/bin/mysqld --defaults-file=/opt/mysql/etc/my.cnf --initialize
systemctl enable --now mysqld
cat /opt/mysql/log/localhost.localdomain.err |grep password
mysql -uroot -p
## 修改默认密码
mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY 'yourpassword';
mysql> use mysql;
## 允许外部访问
mysql> update user set host = '%' where user = 'root';
mysql> FLUSH PRIVILEGES;

## 配置MySQL环境变量
cat <<EOF >/etc/profile.d/mysql.sh
export MYSQL_HOME=/opt/mysql
export PATH=$PATH:$MYSQL_HOME/bin
EOF

source /etc/profile.d/mysql.sh
```

# 安装Rabbitmq
## https://www.rabbitmq.com/docs/install-debian
```bash
apt install -y curl gnupg apt-transport-https
curl -1sLf "https://keys.openpgp.org/vks/v1/by-fingerprint/0A9AF2115F4687BD29803A206B73A36E6026DFCA" | gpg --dearmor | tee /usr/share/keyrings/com.rabbitmq.team.gpg > /dev/null

sudo tee /etc/apt/sources.list.d/rabbitmq.list <<EOF
## Provides modern Erlang/OTP releases
##
deb [signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa1.novemberain.com/rabbitmq/rabbitmq-erlang/deb/ubuntu jammy main
deb-src [signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa1.novemberain.com/rabbitmq/rabbitmq-erlang/deb/ubuntu jammy main

# another mirror for redundancy
deb [signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa2.novemberain.com/rabbitmq/rabbitmq-erlang/deb/ubuntu jammy main
deb-src [signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa2.novemberain.com/rabbitmq/rabbitmq-erlang/deb/ubuntu jammy main

## Provides RabbitMQ
##
deb [signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa1.novemberain.com/rabbitmq/rabbitmq-server/deb/ubuntu jammy main
deb-src [signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa1.novemberain.com/rabbitmq/rabbitmq-server/deb/ubuntu jammy main

# another mirror for redundancy
deb [signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa2.novemberain.com/rabbitmq/rabbitmq-server/deb/ubuntu jammy main
deb-src [signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa2.novemberain.com/rabbitmq/rabbitmq-server/deb/ubuntu jammy main
EOF

apt update
apt install -y erlang-base \
erlang-asn1 erlang-crypto erlang-eldap erlang-ftp erlang-inets \
erlang-mnesia erlang-os-mon erlang-parsetools erlang-public-key \
erlang-runtime-tools erlang-snmp erlang-ssl \
erlang-syntax-tools erlang-tftp erlang-tools erlang-xmerl
apt install -y rabbitmq-server --fix-missing

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
systemctl enable --now rabbitmq-server
```

# 安装Nginx
## https://nginx.org/en/linux_packages.html
```bash
apt install curl gnupg2 ca-certificates lsb-release ubuntu-keyring
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list
apt update
apt install -y nginx

cat <<EOF >/etc/nginx/conf.d/defaults.conf
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

systemctl enable --now nginx
```

# 安装Tomcat
```bash
wget https://dlcdn.apache.org/tomcat/tomcat-8/v8.5.99/bin/apache-tomcat-8.5.99.tar.gz
tar zxvf apache-tomcat-8.5.99.tar.gz
mv apache-tomcat-8.5.99 /opt/tomcat
rm -rf /opt/tomcat/webapps/*
mkdir /opt/tomcat/apps
## 官网下载JRE1.8
https://www.java.com/en/download/manual.jsp jre-8u401-linux-x64.tar.gz
tar zxvf jre-8u401-linux-x64.tar.gz
mv jre1.8.0_401 /opt/jre

## 配置JAVA环境变量
cat <<EOF >/etc/profile.d/java.sh
export JAVA_HOME=/opt/jre
export CLASSPATH=.:$JAVA_HOME/lib
export PATH=$PATH:$JAVA_HOME/bin
EOF

source /etc/profile.d/java.sh
```

# 安装Redis
## https://redis.io/docs/install/install-redis/install-redis-on-linux
```bash
sudo apt install -y lsb-release curl gpg
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
apt update
apt install -y redis
sed -i "s/bind 127.0.0.1/# bind 127.0.0.1/g" /etc/redis/redis.conf
sed -i "s/6379/31013/g" /etc/redis/redis.conf
sed -i "s/# requirepass foobared/requirepass 123456/g" /etc/redis/redis.conf
sed -i "s/notify-keyspace-events \"\"/notify-keyspace-events Ex/g" /etc/redis/redis.conf
systemctl enable --now redis-server
```

# 安装Squid
```bash
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

systemctl enable --now squid
```

# 安装Privoxy
```bash
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

systemctl enable --now privoxy
```

# 安装Shadowsocks-rust
```bash
wget https://github.com/shadowsocks/shadowsocks-rust/releases/download/v1.18.1/shadowsocks-v1.18.1.x86_64-unknown-linux-musl.tar.xz
tar Jxvf shadowsocks-v1.18.1.x86_64-unknown-linux-musl.tar.xz -C /usr/local/bin

## 服务端
cat <<EOF >/usr/local/etc/ssserver.json
{
  "server":"::",
  "server_port":31000,
  "password":"Xjj91oCesEfu2qwbNcMx6ELOoXV3qzYnYKFspgu5CIQ=",
  "timeout":60,
  "method":"2022-blake3-chacha20-poly1305",
  "mode":"tcp_and_udp",
  "fast_open":false,
  "ipv6_only": false,
  "ipv6_first": true
}
EOF

cat <<EOF >/usr/lib/systemd/system/ssserver.service
[Unit]
Description=Shadowsocks-rust Default Server Service
Documentation=https://github.com/shadowsocks/shadowsocks-rust
After=network.target

[Service]
Type=simple
User=root
Group=root
LimitNOFILE=32768
ExecStart=/usr/local/bin/ssserver -c /usr/local/etc/ssserver.json

[Install]
WantedBy=multi-user.target
EOF

systemctl enable --now ssserver

cat <<EOF >/usr/local/etc/sslocal.json
{
  "server":"your_ip",
  "server_port":31000,
  "password":"Xjj91oCesEfu2qwbNcMx6ELOoXV3qzYnYKFspgu5CIQ=",
  "timeout":60,
  "method":"2022-blake3-chacha20-poly1305",
  "mode":"tcp_and_udp",
  "fast_open":false,
  "local_address":"0.0.0.0",
  "local_port":1080
}
EOF

## 客户端
cat <<EOF >/usr/lib/systemd/system/sslocal.service
[Unit]
Description=Shadowsocks-rust Default Server Service
Documentation=https://github.com/shadowsocks/shadowsocks-rust
After=network.target

[Service]
Type=simple
User=root
Group=root
LimitNOFILE=32768
ExecStart=/usr/local/bin/sslocal -c /usr/local/etc/sslocal.json

[Install]
WantedBy=multi-user.target
EOF

systemctl enable --now sslocal

cat <<EOF >proxy.sh
export http_proxy=http://localhost:1080
export https_proxy=http://localhost:1080
EOF

cat <<EOF >unproxy.sh
unset http_proxy
unset https_proxy
EOF

## 启用代理
source proxy.sh
## 禁用代理
source unproxy.sh
```
