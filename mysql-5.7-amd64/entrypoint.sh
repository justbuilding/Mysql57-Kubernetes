#!/bin/bash
set -e

# Initialize MySQL data directory if it's empty
if [ -z "$(ls -A /var/lib/mysql)" ]; then
    echo "Initializing MySQL data directory..."
    
    # Initialize MySQL
    mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql
    
    # Start MySQL temporarily
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
    MYSQL_PID=$!
    
    # Wait for MySQL to start
    echo "Waiting for MySQL to start..."
    while ! mysqladmin ping -h localhost --silent; do
        sleep 1
    done
    
    # Set root password
    echo "Setting root password..."
    mysql -h localhost -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
    
    # Create database if specified
    if [ -n "$MYSQL_DATABASE" ]; then
        echo "Creating database: $MYSQL_DATABASE"
        mysql -h localhost -u root -p$MYSQL_ROOT_PASSWORD <<EOF
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
EOF
    fi
    
    # Create user if specified
    if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
        echo "Creating user: $MYSQL_USER"
        mysql -h localhost -u root -p$MYSQL_ROOT_PASSWORD <<EOF
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
EOF
    fi
    
    # Stop temporary MySQL server
    echo "Stopping temporary MySQL server..."
    kill $MYSQL_PID
    wait $MYSQL_PID
    
    echo "MySQL initialization complete!"
fi

# Start MySQL
if [ "$1" = "mysqld" ]; then
    echo "Starting MySQL server..."
    exec mysqld --user=mysql --datadir=/var/lib/mysql
else
    exec "$@"
fi
