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

# 安装MySQL5.7
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
bind-address=0.0.0.0
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
ExecStart=/opt/mysql/bin/mysqld --defaults-file=/opt/mysql/etc/my.cnf --daemonize --pid-file=/opt/mysql/mysqld.pid $MYSQLD_OPTS

# Use this to switch malloc implementation
EnvironmentFile=-/etc/sysconfig/mysql

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

# 安装MySQL8.2
## https://dev.mysql.com/doc/mysql-secure-deployment-guide/8.0/en/secure-deployment-post-install.html
```bash
apt install libncurses5
wget https://downloads.mysql.com/archives/get/p/23/file/mysql-8.2.0-linux-glibc2.28-x86_64.tar.xz
tar zxvf mysql-8.2.0-linux-glibc2.28-x86_64.tar.gz
mv mysql-8.2.0-linux-glibc2.28-x86_64 /opt/mysql
mkdir /opt/mysql/{data,mysql-files,etc,log}

cat <<EOF >/opt/mysql/etc/my.cnf
[mysqld]
datadir=/opt/mysql/data
socket=/tmp/mysql.sock
port=33306
log-error=/opt/mysql/log/localhost.localdomain.err
user=root
secure_file_priv=/opt/mysql/mysql-files
bind-address=0.0.0.0
EOF

cat <<EOF >/usr/lib/systemd/system/mysqld.service
[Unit]
Description=MySQL Server
Documentation=man:mysqld(8)
Documentation=http://dev.mysql.com/doc/refman/en/using-systemd.html
After=network.target
After=syslog.target

[Install]
WantedBy=multi-user.target

[Service]
User=root
Group=root

# Have mysqld write its state to the systemd notify socket
Type=notify

# Disable service start and stop timeout logic of systemd for mysqld service.
TimeoutSec=0

# Start main service
ExecStart=/opt/mysql/bin/mysqld --defaults-file=/opt/mysql/etc/my.cnf $MYSQLD_OPTS 

# Use this to switch malloc implementation
EnvironmentFile=-/etc/sysconfig/mysql

# Sets open_files_limit
LimitNOFILE = 10000
Restart=on-failure
RestartPreventExitStatus=1

# Set environment variable MYSQLD_PARENT_PID. This is required for restart.
Environment=MYSQLD_PARENT_PID=1
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

# 安装PHP8.3
## https://php.watch/
## https://docs.phpmyadmin.net/zh-cn/latest/setup.html
```bash
add-apt-repository ppa:ondrej/php
apt install -y php8.3-fpm
systemctl enable --now php8.3-fpm
mkdir /opt/www

cat <<EOF >/opt/www/phpinfo.php
<?php
phpinfo();
?>
EOF

## nginx 配置
server {
  listen 80;
  server_name localhost;
  root /opt/www;
  access_log /var/log/nginx/defaults.log;
  location / {
    autoindex on;
    autoindex_exact_size on;
    autoindex_localtime on;
  }
  location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/run/php/php8.3-fpm.sock;
  }
}

## 配置phpMyAdmin
wget https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip
unzip phpMyAdmin-5.2.1-all-languages.zip
mv phpMyAdmin-5.2.1-all-languages /opt/www/phpMyAdmin
apt install -y php8.3-mysql php8.3-bz2 php8.3-zip php8.3-mbstring
## 注意不能使用localhost，要使用127.0.0.1
```

# 安装Tomcat
## https://www.oracle.com/cn/java/technologies/downloads/archive/
## https://tomcat.apache.org/
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

## 配置用户权限
vim /opt/tomcat/conf/tomcat-users.xml
## 添加下面字段
  <role rolename="tomcat"/>
  <role rolename="role1"/>
  <role rolename="manager-script"/>
  <role rolename="manager-gui"/>
  <role rolename="manager-status"/>
  <role rolename="admin-gui"/>
  <role rolename="admin-script"/>
  <user username="root" password="root" roles="manager-gui,manager-script,tomcat,admin-gui,admin-script"/>

## 允许外部访问
vim /opt/tomcat/webapps/manager/META-INF/context.xml
## 注释下面这行，webapps下其他目录也需要修改
<!--   <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" /> -->

## 配置根目录访问应用
## Host标签添加一行
      <Host name="localhost"  appBase="webapps"
            unpackWARs="true" autoDeploy="true">
        <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
               prefix="localhost_access_log" suffix=".txt"
               pattern="%h %l %u %t &quot;%r&quot; %s %b" />
            <Context docBase="/opt/tomcat/webapps/jenkins" path="/" reloadable="true"/>            
      </Host>
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

# 安装Gitlab
```bash
apt install -y curl openssh-server ca-certificates postfix
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
apt install -y gitlab-ce
gitlab-ctl reconfigure
systemctl enable --now gitlab-runsvdir
## 修改Gitlab登录用户root的密码，最少8位密码
gitlab-rails console
user = User.where(id: 1).first
user.password = 'password'
user.password_confirmation = 'password'
user.save!
exit
## 修改域名
vim /etc/gitlab/gitlab.rb
vim /opt/gitlab/embedded/service/gitlab-rails/config/gitlab.yml
```

## 查看使用的端口
```bash
netstat -tunlp
tcp        0      0 127.0.0.1:9229          0.0.0.0:*               LISTEN      2304/gitlab-workhor 
tcp        0      0 127.0.0.1:9236          0.0.0.0:*               LISTEN      2295/gitaly          
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      2317/nginx: master  
tcp        0      0 127.0.0.1:9121          0.0.0.0:*               LISTEN      2347/redis_exporter 
tcp        0      0 127.0.0.1:9090          0.0.0.0:*               LISTEN      2357/prometheus     
tcp        0      0 127.0.0.1:9093          0.0.0.0:*               LISTEN      2372/alertmanager   
tcp        0      0 127.0.0.1:9100          0.0.0.0:*               LISTEN      2335/node_exporter  
tcp        0      0 127.0.0.1:9187          0.0.0.0:*               LISTEN      2382/postgres_expor 
tcp        0      0 127.0.0.1:9168          0.0.0.0:*               LISTEN      2342/ruby           
tcp        0      0 127.0.0.1:8080          0.0.0.0:*               LISTEN      1884/puma 6.4.0 (un 
tcp        0      0 127.0.0.1:8082          0.0.0.0:*               LISTEN      1915/sidekiq_export 
tcp        0      0 127.0.0.1:8092          0.0.0.0:*               LISTEN      1913/sidekiq 7.1.6  
tcp        0      0 127.0.0.1:8150          0.0.0.0:*               LISTEN      1818/gitlab-kas     
tcp        0      0 127.0.0.1:8151          0.0.0.0:*               LISTEN      1818/gitlab-kas     
tcp        0      0 127.0.0.1:8153          0.0.0.0:*               LISTEN      1818/gitlab-kas     
tcp        0      0 127.0.0.1:8154          0.0.0.0:*               LISTEN      1818/gitlab-kas     
tcp        0      0 127.0.0.1:8155          0.0.0.0:*               LISTEN      1818/gitlab-kas     
tcp        0      0 0.0.0.0:8060            0.0.0.0:*               LISTEN      2317/nginx: master  
tcp6       0      0 :::9094                 :::*                    LISTEN      2372/alertmanager   
udp6       0      0 :::9094                 :::*                                2372/alertmanager
```

# 安装Prometheus
## https://prometheus.io/download/
```bash
cd /opt/prometheus

cat <<EOF >/usr/lib/systemd/system/prometheus.service
[Unit]
Description=Prometheus Server
Documentation=https://prometheus.io/docs/introduction/overview/
After=network.target

[Service]
Type=simple
ExecStart=/opt/prometheus/prometheus --config.file=/opt/prometheus/prometheus.yml --web.listen-address=:39090
Restart=always

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF >/usr/lib/systemd/system/alertmanager.service
[Unit]
Description=Alertmanager
After=network.target

[Service]
User=root
ExecStart=/opt/prometheus/alertmanager/alertmanager --config.file=/opt/prometheus/alertmanager/alertmanager.yml --cluster.listen-address="0.0.0.0:39094" --web.listen-address=:39093

[Install]
WantedBy=default.target
EOF

cat <<EOF >/usr/lib/systemd/system/blackbox_exporter.service
[Unit]
Description=Blackbox Exporter
After=network.target

[Service]
User=root
ExecStart=/opt/prometheus/blackbox_exporter/blackbox_exporter --config.file=/opt/prometheus/blackbox_exporter/blackbox.yml --web.listen-address=:39115

[Install]
WantedBy=default.target
EOF

cat <<EOF >/usr/lib/systemd/system/consul_exporter.service
[Unit]
Description=Consul Exporter
After=network.target

[Service]
User=root
ExecStart=/opt/prometheus/consul_exporter/consul_exporter --web.listen-address=:39107

[Install]
WantedBy=default.target
EOF

cat <<EOF >/usr/lib/systemd/system/graphite_exporter.service
[Unit]
Description=Graphite Exporter
After=network.target

[Service]
User=root
ExecStart=/opt/prometheus/graphite_exporter/graphite_exporter --graphite.listen-address=":39109" --web.listen-address=:39108

[Install]
WantedBy=default.target
EOF

cat <<EOF >/usr/lib/systemd/system/memcached_exporter.service
[Unit]
Description=Memcached Exporter
After=network.target

[Service]
User=root
ExecStart=/opt/prometheus/memcached_exporter/memcached_exporter --web.listen-address=:39150

[Install]
WantedBy=default.target
EOF

cat <<EOF >/usr/lib/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=root
ExecStart=/opt/prometheus/node_exporter/node_exporter --web.listen-address=:39100

[Install]
WantedBy=default.target
EOF

cat <<EOF >/usr/lib/systemd/system/statsd_exporter.service
[Unit]
Description=Statsd Exporter
After=network.target

[Service]
User=root
ExecStart=/opt/prometheus/statsd_exporter/statsd_exporter --statsd.listen-udp=":39125" --statsd.listen-tcp=":39125" --web.listen-address=:39102

[Install]
WantedBy=default.target
EOF

vim /opt/prometheus/prometheus.yml
# 添加监控
# my global config
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
           - alertmanager:39093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "prometheus"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["192.168.254.100:39090"]

  - job_name: 'blackbox_exporter'
    static_configs:
      - targets: ['192.168.254.100:39115']
  - job_name: 'consul_exporter'
    static_configs:
      - targets: ['192.168.254.100:39107']
  - job_name: 'graphite_exporter'
    static_configs:
      - targets: ['192.168.254.100:39108']
  - job_name: 'memcached_exporter'
    static_configs:
      - targets: ['192.168.254.100:39150']
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['192.168.254.100:39100']
  - job_name: 'statsd_exporter'
    static_configs:
      - targets: ['192.168.254.100:39102']

systemctl enable --now prometheus
systemctl enable --now alertmanager
systemctl enable --now blackbox_exporter
systemctl enable --now consul_exporter
systemctl enable --now graphite_exporter
systemctl enable --now memcached_exporter
systemctl enable --now node_exporter
systemctl enable --now statsd_exporter

systemctl restart prometheus

```
