# Use an official Python runtime as a parent image
FROM python:3.9

# Install necessary packages
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    openjdk-17-jre \
    npm

# Create necessary directories
RUN mkdir -p /var/games/minecraft/servers /mineos /bedrock_translator

# Download MineOS
RUN wget -O /mineos/mineos-node.tar.gz https://github.com/hexparrot/mineos-node/archive/refs/tags/v1.0.0.tar.gz && \
    tar -xzvf /mineos/mineos-node.tar.gz -C /mineos && \
    rm /mineos/mineos-node.tar.gz && \
    cd /mineos/mineos-node-1.0.0 && \
    npm install

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