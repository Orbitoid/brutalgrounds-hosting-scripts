#!/bin/bash

# This setup has been running fine for almost a year with regular updates via crontab job
# I'm using a t2.micro EC2 instance on AWS in the Sydney region and it seems to be able to handle at least 10 people at once. 

# STEAM ID to use as admin in server.
# Use the steamID64 (Dec) value: https://steamidfinder.com/

ADMIN_RCON_STEAM_ID="12345678901234567"
ADMIN_USERNAME="Your_Steam_Username"
ADMIN_USER_PASSWORD="yourSteamUserNamesPassword"
CURRENT_TIME=$(date +%F_%H-%M-%S)
CURRENT_USER_ID=$(id -u)
CURRENT_USER_GROUP_ID=$(id -g)
BRUTAL_GROUNDS_APP_ID="1123110"
SERVER_NAME="A descriptive name that players will see"
HOST_NAME="Who is hosting this server?"
HOSTING_PORT="7777"
SEARCH_QUERY_PORT="27015"
BRUTAL_GROUNDS_USER_DIR="/home/ubuntu/docker_home_dir"
SSL_CERT_DIR="/etc/ssl/certs/"
STEAM_DATA_DIR="/home/ubuntu/data/"

#Guide:
#https://github.com/AGOG-Entertainment/brutal-grounds-dedicated-server/

#Update and validate the server:
docker run \
        --rm \
        -v "${STEAM_DATA_DIR}":/data \
        steamcmd/steamcmd:latest +login "${ADMIN_USERNAME}" "${ADMIN_USER_PASSWORD}" +force_install_dir /data/brutal_grounds_ds +app_update "${BRUTAL_GROUNDS_APP_ID}" validate +quit

docker run \
        -v "${STEAM_DATA_DIR}"brutal_grounds_ds:/data \
        --rm \
        ubuntu chown -R "${CURRENT_USER_ID}:${CURRENT_USER_GROUP_ID}" /data

# run the server
docker run \
--rm \
-v "${STEAM_DATA_DIR}":/data \
-v "${SSL_CERT_DIR}":/etc/ssl/certs/ \
-v "${BRUTAL_GROUNDS_USER_DIR}":/home/bg_user \
-u ${CURRENT_USER_ID}:${CURRENT_USER_GROUP_ID} \
-p 7777:7777/udp \
-p 27015:27015/udp \
-e HOME=/home/bg_user \
ubuntu /data/brutal_grounds_ds/BrutalGroundsServer.sh \
Arena \
-log \
-nullrhi \
-AdminId="${ADMIN_RCON_STEAM_ID}" \
-SteamServerName="${SERVER_NAME}" \
-HostName="${HOST_NAME}" \
-Port="${HOSTING_PORT}" \
-QueryPort="${SEARCH_QUERY_PORT}"