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

# Copy backend
COPY backend /app/backend
WORKDIR /app/backend
RUN npm install

# Setup MySQL
RUN service mysql start && \
    mysql -e "CREATE DATABASE IF NOT EXISTS bks;" && \
    mysql -e "CREATE USER 'bks'@'localhost' IDENTIFIED BY 'Bks#13';" && \
    mysql -e "GRANT ALL PRIVILEGES ON bks.* TO 'bks'@'localhost';" && \
    mysql -e "FLUSH PRIVILEGES;"

# Copy frontend
COPY frontend/index.html /usr/share/nginx/html/index.html

# Copy nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Expose ports
EXPOSE 80 8080 3306

# Start services
CMD service mysql start && \
    node /app/backend/index.js & \
    nginx -g 'daemon off;'
