# Stage 1: Python environment setup
FROM python:3.9-slim AS python-base

# Install necessary packages for Python and other dependencies
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

# Stage 2: Node.js environment setup
FROM node:14 AS node-base

# Install global Node.js packages
RUN npm install -g npm@latest \
    && npm install -g node-gyp

# Stage 3: Java environment setup
FROM openjdk:17-jre-slim AS java-base

# Final image setup
FROM python-base

# Copy Node.js from node-base
COPY --from=node-base /usr/local/bin/node /usr/local/bin/
COPY --from=node-base /usr/local/lib/node_modules /usr/local/lib/node_modules

# Set environment variables for NVM and Node.js
ENV NVM_DIR /root/.nvm
ENV NODE_VERSION 14

# Install NVM and Node.js
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash \
    && . "$NVM_DIR/nvm.sh" && nvm install $NODE_VERSION

# Copy Java from java-base
COPY --from=java-base /opt/openjdk-17 /opt/openjdk-17

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