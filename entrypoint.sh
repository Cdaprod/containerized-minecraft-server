#!/bin/sh

# Function to start the Bedrock server
start_server() {
    cd /bedrock_translator
    LD_LIBRARY_PATH=. ./bedrock_server &
}

# Function to stop the Bedrock server
stop_server() {
    pkill -f bedrock_server
}

# Check if a world name was provided
if [ ! -z "$WORLD_NAME" ]; then
    stop_server
    WORLD_DIR="/bedrock_translator/worlds/$WORLD_NAME"

    # Check if the specified world directory exists
    if [ ! -d "$WORLD_DIR" ]; then
        echo "World $WORLD_NAME does not exist!"
        exit 1
    fi

    # Replace the current world with the specified one
    rm -rf /bedrock_translator/world
    cp -r "$WORLD_DIR" /bedrock_translator/world

    start_server
else
    start_server
fi

# Wait for any process to exit
while :; do
  for job in $(jobs -p); do
    wait "$job" || exit 1
  done
  sleep 1
done

# Keep the script running
tail -f /dev/null