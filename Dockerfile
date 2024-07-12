# Use an official Python runtime as a parent image
FROM python:3.9

# Install necessary packages
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    git \
    rdiff-backup \
    screen \
    build-essential \
    openjdk-17-jre \
    npm

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs

# Install Java
RUN wget https://github.com/AdoptOpenJDK/openjdk16-binaries/releases/download/jdk-16.0.1%2B9/OpenJDK16U-jre_x64_linux_hotspot_16.0.1_9.tar.gz -O openjdk-16-jre.tgz && \
    tar xf openjdk-16-jre.tgz && \
    mv jdk-16.0.* /opt/openjdk-16.0-jre && \
    ln -s /opt/openjdk-16.0-jre/bin/java /usr/bin/java && \
    rm openjdk-16-jre.tgz

# Download and set up MineOS
RUN mkdir -p /usr/games && \
    cd /usr/games && \
    git clone https://github.com/hexparrot/mineos-node.git minecraft && \
    cd minecraft && \
    chmod +x generate-sslcert.sh mineos_console.js webui.js && \
    cp mineos.conf /etc/mineos.conf && \
    npm install && \
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