# Base image for Python
FROM python:3.9 AS python-base
RUN mkdir -p /usr/local/bin

# Base image for Node.js
FROM node:14 AS node-base
RUN mkdir -p /usr/local/bin

# Base image for Java
FROM openjdk:17-jre-slim AS java-base
RUN mkdir -p /opt/openjdk-17
RUN echo "Contents of /opt/openjdk-17:" && ls -la /opt/openjdk-17

# Main build stage
FROM ubuntu:20.04

# Install necessary packages
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    git \
    rdiff-backup \
    screen \
    build-essential \
    python3 \
    python3-pip \
    python3-dev \
    g++ \
    make

# Copy from base images
COPY --from=python-base /usr/local/bin /usr/local/bin
COPY --from=node-base /usr/local/bin /usr/local/bin
COPY --from=java-base /opt/openjdk-17 /opt/openjdk-17

# Install npm and node-gyp
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest && \
    npm install -g node-gyp

# Download and set up MineOS
RUN mkdir -p /usr/games && \
    cd /usr/games && \
    git clone https://github.com/hexparrot/mineos-node.git minecraft && \
    cd minecraft && \
    chmod +x generate-sslcert.sh mineos_console.js webui.js && \
    cp mineos.conf /etc/mineos.conf && \
    npm install --legacy-peer-deps --unsafe-perm && \
    ./generate-sslcert.sh

# Create necessary directories
RUN mkdir -p /var/games/minecraft/servers /mineos /bedrock_translator

# Download Bedrock server wrapper
RUN wget -O /bedrock_translator/bedrock-server.zip https://minecraft.azureedge.net/bin-linux/bedrock-server-1.18.11.01.zip && \
    unzip /bedrock_translator/bedrock-server.zip -d /bedrock_translator && \
    chmod +x /bedrock_translator/bedrock_server && \
    rm /bedrock_translator/bedrock-server.zip

# Copy the Python script to the container
COPY download_maps.py /usr/local/bin/download_maps.py

# Expose necessary ports
EXPOSE 8443 25565 25575 19132/udp 19133/udp

# Copy and set the entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Run the entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]