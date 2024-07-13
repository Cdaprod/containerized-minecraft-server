# Use an official Python runtime as a parent image
FROM python:3.9 AS python-base

# Install necessary packages for Python
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    git \
    build-essential \
    python3 \
    python3-pip \
    python3-dev \
    g++ \
    make \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Use an official Node.js runtime as a parent image
FROM node:14 AS node-base

# Install necessary global packages for Node.js
RUN npm install -g npm@latest \
    && npm install -g node-gyp

# Use an official OpenJDK runtime as a parent image
FROM openjdk:17-jre AS java-base

# Copy the installed JDK to the final image
COPY --from=java-base /opt/openjdk-17 /opt/openjdk-17

# Final image for Minecraft server
FROM python-base

# Install Node.js
COPY --from=node-base /usr/local/bin/node /usr/local/bin/
COPY --from=node-base /usr/local/lib/node_modules /usr/local/lib/node_modules

# Set environment variables for NVM and Node.js
ENV NVM_DIR /root/.nvm
ENV NODE_VERSION 14

# Install NVM and Node.js
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash \
    && . "$NVM_DIR/nvm.sh" && nvm install $NODE_VERSION

# Install MineOS
RUN mkdir -p /usr/games \
    && cd /usr/games \
    && git clone https://github.com/hexparrot/mineos-node.git minecraft \
    && cd minecraft \
    && chmod +x generate-sslcert.sh mineos_console.js webui.js \
    && cp mineos.conf /etc/mineos.conf \
    && . "$NVM_DIR/nvm.sh" && npm install --legacy-peer-deps --unsafe-perm \
    && ./generate-sslcert.sh

# Create necessary directories
RUN mkdir -p /var/games/minecraft/servers /mineos /bedrock_translator

# Download Bedrock server wrapper
RUN wget -O /bedrock_translator/bedrock-server.zip https://minecraft.azureedge.net/bin-linux/bedrock-server-1.18.11.01.zip \
    && unzip /bedrock_translator/bedrock-server.zip -d /bedrock_translator \
    && chmod +x /bedrock_translator/bedrock_server \
    && rm /bedrock_translator/bedrock-server.zip

# Copy the Python script to the container
COPY download_maps.py /usr/local/bin/download_maps.py

# Expose necessary ports
EXPOSE 8443 25565 25575 19132/udp 19133/udp

# Copy and set the entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Run the entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]