# Use an official Python runtime as a parent image
FROM python:3.9 as python-base

# Use an official Node.js runtime as a parent image
FROM node:14 as node-base

# Use an official OpenJDK runtime as a parent image
FROM openjdk:17-jre as java-base

# Base image setup
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

# Copy Python from python-base image
COPY --from=python-base /usr/local/bin/python3 /usr/local/bin/python3
COPY --from=python-base /usr/local/lib/python3.9 /usr/local/lib/python3.9

# Copy Node.js from node-base image
COPY --from=node-base /usr/local/bin/node /usr/local/bin/node
COPY --from=node-base /usr/local/bin/npm /usr/local/bin/npm
COPY --from=node-base /usr/local/lib/node_modules /usr/local/lib/node_modules

# Copy Java from java-base image
COPY --from=java-base /opt/openjdk-17 /opt/openjdk-17
RUN ln -sf /opt/openjdk-17/bin/java /usr/bin/java

# Clean npm cache and install node-gyp globally
RUN npm cache clean -f && npm install -g node-gyp@latest

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