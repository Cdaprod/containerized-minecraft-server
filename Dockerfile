# Use an official Python runtime as a parent image
FROM python:3.9 AS python-base

# Install necessary packages for Python
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    git \
    screen \
    build-essential \
    python3 \
    python3-pip \
    python3-dev \
    g++ \
    make \
    libssl1.1 \
    rsync \
    rdiff-backup \
    passwd

# Use Node.js 14
FROM node:14 AS node-base

# Clean npm cache and install node-gyp
RUN npm cache clean -f && \
    npm install -g npm@latest && \
    npm install -g node-gyp

# Use Eclipse Temurin for Java
FROM eclipse-temurin:17-jre AS java-base

# Install necessary dependencies in the java-base stage
RUN apt-get update && apt-get install -y \
    npm \
    git \
    python3-requests \
    unzip \
    screen \
    rsync \
    rdiff-backup \
    libssl-dev

# Download and install libssl1.1 manually
RUN wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.22_amd64.deb && \
    dpkg -i libssl1.1_1.1.1f-1ubuntu2.22_amd64.deb && \
    rm libssl1.1_1.1.1f-1ubuntu2.22_amd64.deb

# Create users and set passwords
RUN useradd -m -s /bin/bash mc && echo 'mc:root' | chpasswd || true
RUN useradd -m -s /bin/bash root && echo 'root:root' | chpasswd || true

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
RUN mkdir -p /var/games/minecraft/servers /mineos /bedrock_translator /maps /var/games/minecraft/logs && \
    chmod -R 777 /var/games/minecraft/logs

# Download the Minecraft server JAR
RUN wget -O /var/games/minecraft/server.jar https://piston-data.mojang.com/v1/objects/450698d1863ab5180c25d7c804ef0fe6369dd1ba/server.jar

# Copy the Bedrock server ZIP file from the repository
COPY maps/bedrock-server-1.21.3.01.zip /bedrock_translator/bedrock-server.zip

# Unzip the Bedrock server
RUN unzip /bedrock_translator/bedrock-server.zip -d /bedrock_translator && \
    chmod +x /bedrock_translator/bedrock_server && \
    rm /bedrock_translator/bedrock-server.zip

# Clone BedrockConnect repository
RUN git clone https://github.com/Cdaprod/BedrockConnect.git /bedrock_connect

# Set up BedrockConnect (adjust these steps based on your BedrockConnect setup)
WORKDIR /bedrock_connect
RUN ./setup.sh

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