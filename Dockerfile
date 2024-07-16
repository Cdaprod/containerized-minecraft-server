# Use an official Python runtime as a parent image
FROM python:3.9-slim AS python-base

# Install necessary packages for Python
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    screen \
    build-essential \
    python3-dev \
    g++ \
    make \
    libssl1.1 \
    rsync \
    rdiff-backup \
    libjpeg-dev \
    zlib1g-dev \
    libpng-dev \
    libtiff-dev \
    libnotify-dev \
    freeglut3-dev \
    pkg-config \
    libgtk2.0-dev \
    libwxgtk3.0-gtk3-dev \
    libgtk-3-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    && apt-get clean

# Install Amulet-Map-Editor
RUN pip install amulet-map-editor

# Use Eclipse Temurin for Java
FROM eclipse-temurin:17-jre AS java-base

# Switch to Debian-based layer
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    software-properties-common \
    && apt-get clean

# Install necessary dependencies in the java-base stage
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    libjpeg-dev \
    zlib1g-dev \
    libpng-dev \
    libtiff-dev \
    libnotify-dev \
    freeglut3-dev \
    pkg-config \
    libgtk2.0-dev \
    libwxgtk3.0-gtk3-dev \
    libgtk-3-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    && apt-get clean

# Copy the Python environment with Amulet-Map-Editor from the previous stage
COPY --from=python-base /usr/local/lib/python3.9 /usr/local/lib/python3.9
COPY --from=python-base /usr/local/bin /usr/local/bin

# Create necessary directories with proper permissions
RUN mkdir -p /bedrock_translator /maps && \
    chmod -R 777 /bedrock_translator /maps

# Download and install libssl1.1 manually
RUN wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.22_amd64.deb && \
    dpkg -i libssl1.1_1.1.1f-1ubuntu2.22_amd64.deb && \
    rm libssl1.1_1.1.1f-1ubuntu2.22_amd64.deb

# Copy the Bedrock server ZIP file from the repository
COPY maps/bedrock-server-1.21.3.01.zip /bedrock_translator/bedrock-server.zip

# Unzip the Bedrock server
RUN unzip /bedrock_translator/bedrock-server.zip -d /bedrock_translator && \
    chmod +x /bedrock_translator/bedrock_server && \
    rm /bedrock_translator/bedrock-server.zip

# Copy server.properties to the correct location
COPY config/server.properties /bedrock_translator/server.properties

# Copy the Python scripts to the container
COPY download_maps.py /usr/local/bin/download_maps.py
COPY download_mods.py /usr/local/bin/download_mods.py

# Ensure the Python scripts are executable
RUN chmod +x /usr/local/bin/download_maps.py
RUN chmod +x /usr/local/bin/download_mods.py

# Run the map and mod download scripts
RUN python3 /usr/local/bin/download_maps.py
RUN python3 /usr/local/bin/download_mods.py

# Copy switch world script to container
COPY switch_world.sh /usr/local/bin/switch_world.sh
RUN chmod +x /usr/local/bin/switch_world.sh

# Copy and set the entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose necessary ports
EXPOSE 19132/udp 19133/udp 19134/udp 19135/udp 19136/udp 19137/udp

# Run the entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]