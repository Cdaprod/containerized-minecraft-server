#!/bin/sh
# Start the MineOS server
cd /usr/games/minecraft
npm start &

# Start the Bedrock server
cd /bedrock_translator
./bedrock_server &
wait -n
exit $?