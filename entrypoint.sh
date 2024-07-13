#!/bin/sh
# Start the MineOS server
cd /usr/games/minecraft
npm start &

# Start the Bedrock server
cd /bedrock_translator
./bedrock_server &

# Wait for any process to exit
while :; do
  for job in $(jobs -p); do
    wait "$job" || exit 1
  done
  sleep 1
done