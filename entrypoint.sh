#!/bin/bash

# Run the map downloader
python /usr/local/bin/download_maps.py

# Start MineOS
cd /usr/games/minecraft
npm start &

# Start Bedrock server
cd /bedrock_translator
./bedrock_server &

# Keep the container running
tail -f /dev/null