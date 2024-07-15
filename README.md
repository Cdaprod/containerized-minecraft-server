# Unified Minecraft Server Setup

[Link to bedrock server](https://www.minecraft.net/en-us/download/server/bedrock)

This project sets up a unified Docker container that runs MineOS for managing Minecraft servers, a Bedrock translator for cross-platform play, and a Python script for downloading awesome maps. The services are exposed on different ports and share the same IP address.

## Features
- **MineOS**: Manage your Minecraft Java Edition servers.
- **Bedrock Translator**: Allow Bedrock Edition clients (Windows 10, Xbox, mobile) to connect.
- **Map Downloader**: Automatically download and set up Minecraft maps.

## Prerequisites
- Docker
- Docker Compose

## Directory Structure
```
unified-minecraft-server/
├── Dockerfile
├── download_maps.py
├── entrypoint.sh
├── docker-compose.yml
└── maps/
```

## Setup Instructions

### Step 1: Clone Forked Repository
```sh
git clone https://github.com/yourusername/unified-minecraft-server.git
cd unified-minecraft-server
```

### Step 2: Build the Docker Image
```sh
docker-compose build
```

### Step 3: Run the Docker Containers
```sh
docker-compose up -d
```

## Services

### MineOS Web UI
- **Access**: [https://localhost:8443](https://localhost:8443)
- **Default Credentials**:
  - Username: `admin`
  - Password: `admin`

### Minecraft Java Server
- **Port**: `25565`

### Minecraft Bedrock Server
- **Port**: `19132` (UDP)

## Configuration

### Environment Variables
- `MINEOS_USERNAME`: The username for MineOS (default: `admin`)
- `MINEOS_PASSWORD`: The password for MineOS (default: `admin`)

## Volumes
- `mineos-data`: Stores Minecraft server data managed by MineOS
- `bedrock-data`: Stores Bedrock server data
- `maps`: Stores downloaded maps

## Usage
- Access the MineOS web UI to manage your Minecraft Java servers.
- Use the Bedrock server to allow Bedrock Edition clients to connect.
- The Python script automatically downloads and sets up new maps.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements
- [MineOS](https://github.com/hexparrot/mineos-node) for server management.
- [Bedrock Translator](https://github.com/itzg/docker-minecraft-bedrock-server) for cross-platform play.
- [Python Requests](https://requests.readthedocs.io/en/master/) for downloading maps.

## Troubleshooting
If you encounter any issues, check the logs using:
```sh
docker-compose logs -f
```
For further assistance, refer to the documentation for each component used in this setup.