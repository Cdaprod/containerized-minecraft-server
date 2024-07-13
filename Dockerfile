# Use Eclipse Temurin for Java as the base image
FROM eclipse-temurin:17-jre AS base

# Install all necessary packages
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
    make \
    libssl1.1 || apt-get install -y libssl3 \
    npm \
    python3-requests

# Use Node.js 18
FROM node:18 AS node-base

# Clean npm cache and install node-gyp
RUN npm cache clean -f && \
    npm install -g npm@latest && \
    npm install -g node-gyp

# Download and set up MineOS
RUN mkdir -p /usr/games && \
    cd /usr/games && \
    git clone https://github.com/hexparrot/mineos-node.git minecraft && \
    cd minecraft && \
    chmod +x generate-sslcert.sh mineos_console.js webui.js && \
    cp mineos.conf /etc/mineos.conf && \
    npm install --legacy-peer-deps && \
    ./generate-sslcert.sh

# Create necessary directories
RUN mkdir -p /var/games/minecraft/servers /mineos /bedrock_translator /maps

# Download Bedrock server wrapper
RUN wget -O /bedrock_translator/bedrock-server.zip https://minecraft.azureedge.net/bin-linux/bedrock-server-1.18.11.01.zip && \
    unzip /bedrock_translator/bedrock-server.zip -d /bedrock_translator && \
    chmod +x /bedrock_translator/bedrock_server && \
    rm /bedrock_translator/bedrock-server.zip

# Copy the Python script to the container
COPY download_maps.py /usr/local/bin/download_maps.py

# Run the map download script
RUN python3 /usr/local/bin/download_maps.py

# Expose necessary ports
EXPOSE 8443 25565 25575 19132/udp 19133/udp

# Copy and set the entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Run the entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]