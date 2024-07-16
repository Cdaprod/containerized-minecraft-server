FROM eclipse-temurin:17-jre AS java-base

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    screen \
    rsync \
    rdiff-backup

# Create necessary directories with proper permissions
RUN mkdir -p /bedrock_translator /maps && \
    chmod -R 777 /bedrock_translator /maps

# Copy the Bedrock server ZIP file from the repository
COPY maps/bedrock-server-1.21.2.01.zip /bedrock_translator/bedrock-server.zip

# Unzip the Bedrock server
RUN unzip /bedrock_translator/bedrock-server.zip -d /bedrock_translator && \
    chmod +x /bedrock_translator/bedrock_server && \
    rm /bedrock_translator/bedrock-server.zip

# Copy server.properties to the correct location
COPY config/server.properties /bedrock_translator/server.properties

# Copy the Python scripts to the container
COPY download_maps.py /usr/local/bin/download_maps.py

# Run the map download script
RUN python3 /usr/local/bin/download_maps.py

# Copy switch world script to container
COPY switch_world.sh /usr/local/bin/switch_world.sh
RUN chmod +x /usr/local/bin/switch_world.sh

# Copy and set the entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose necessary ports
EXPOSE 19132/udp 19133/udp

# Run the entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]