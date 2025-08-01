FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    nginx \
    curl \
    gnupg \
    lsb-release \
    mysql-server \
    nodejs \
    npm

# Fix MySQL startup issues
RUN mkdir -p /var/run/mysqld && chown mysql:mysql /var/run/mysqld

# Copy backend code
COPY backend /app/backend
WORKDIR /app/backend
RUN npm install

# Initialize MySQL database
COPY init.sql /docker-entrypoint-initdb.d/init.sql

# Copy frontend files
COPY frontend/index.html /usr/share/nginx/html/index.html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose backend, frontend, and MySQL ports
EXPOSE 80 8080 3306

# Start all services
CMD bash -c "\
    service mysql start && \
    mysql -e \"
      CREATE DATABASE IF NOT EXISTS bks;
      CREATE USER IF NOT EXISTS 'bks'@'%' IDENTIFIED BY 'Bks#13';
      GRANT ALL PRIVILEGES ON bks.* TO 'bks'@'%';
      FLUSH PRIVILEGES;\" && \
    node /app/backend/index.js & \
    nginx -g 'daemon off;'"
