#!/bin/sh

# Function to stop the Bedrock server
stop_server() {
    pkill -f bedrock_server
}

# Function to start the Bedrock server
start_server() {
    cd /bedrock_translator
    LD_LIBRARY_PATH=. ./bedrock_server &
}

# Check if a world name was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <world_name>"
    exit 1
fi

WORLD_NAME=$1
WORLD_DIR="/bedrock_translator/worlds/$WORLD_NAME"

# Check if the specified world directory exists
if [ ! -d "$WORLD_DIR" ]; then
    echo "World $WORLD_NAME does not exist!"
    exit 1
fi

# Stop the server, replace the world, and start the server again
stop_server
rm -rf /bedrock_translator/world
cp -r "$WORLD_DIR" /bedrock_translator/world
start_server

echo "Switched to world $WORLD_NAME"