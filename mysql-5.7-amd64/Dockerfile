FROM ubuntu:26.04

LABEL jiajun 13415145594@163.com
LABEL architecture amd64
LABEL maintainer MySQL 5.7 Builder

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    MYSQL_ROOT_PASSWORD=123456 \
    MYSQL_USER=mysql \
    MYSQL_DATABASE=mysql

RUN set -eux; \
    # Update sources and install dependencies \
    sed -i "s@ports.ubuntu.com@mirrors.aliyun.com@g" /etc/apt/sources.list.d/ubuntu.sources; \
    apt update -y; \
    apt install -y --no-install-recommends \
        tcptraceroute tzdata locales net-tools curl vim \
        gnupg2 wget ca-certificates \
        libaio1; \
    \
    # Configure locales and timezone \
    locale-gen en_US.UTF-8; \
    dpkg-reconfigure -f noninteractive locales; \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
    echo "Asia/Shanghai" > /etc/timezone; \
    dpkg-reconfigure -f noninteractive tzdata; \
    \
    # Add MySQL GPG key and repository \
    wget -O /tmp/mysql.gpg https://repo.mysql.com/RPM-GPG-KEY-mysql; \
    gpg --dearmor -o /etc/apt/trusted.gpg.d/mysql.gpg /tmp/mysql.gpg; \
    echo "deb http://repo.mysql.com/apt/ubuntu/ jammy mysql-5.7" > /etc/apt/sources.list.d/mysql.list; \
    \
    # Install MySQL 5.7 \
    apt update -y; \
    apt install -y --no-install-recommends mysql-server-5.7; \
    \
    # Clean up \
    apt clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
    \
    # Configure MySQL \
    mkdir -p /var/run/mysqld; \
    chown -R mysql:mysql /var/run/mysqld; \
    chmod 755 /var/run/mysqld; \
    \
    # Remove default MySQL data directory \
    rm -rf /var/lib/mysql/*

# Add MySQL configuration file
ADD my.cnf /etc/mysql/my.cnf

# Expose port
EXPOSE 3306

# Volumes
VOLUME /var/lib/mysql

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD mysqladmin ping -u root -p${MYSQL_ROOT_PASSWORD} || exit 1

# Entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["mysqld"]
