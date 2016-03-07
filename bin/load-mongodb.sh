#!/bin/bash
# (c) Copyright IBM Corp. 2016.  All Rights Reserved.
# Distributed under the terms of the Modified BSD License.

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Bring up a MongoDB container
echo "Bringing up MongoDB container"
cd "$DIR"/../mongodb && docker-compose up -d

# Get the MongoDB container ID
CONTAINER_ID=$(docker ps --filter ancestor=mongo --format {{.ID}})
echo MongoDB container ID: $CONTAINER_ID

# Now get the MongoDB container image ID, network ID, and IP address
IMAGE_ID=$(docker inspect --format {{.Config.Image}} $CONTAINER_ID)
echo MongoDB image: $IMAGE_ID
NETWORK_NAME=$(docker inspect --format '{{range $key, $value := .NetworkSettings.Networks}}{{$key}}{{end}}' $CONTAINER_ID)
echo MongoDB network: $NETWORK_NAME
CONTAINER_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_ID)
echo MongoDB container IP address: $CONTAINER_IP

# Run a new Docker container that volume mounts the sample data directory on
# the host, connects to the running MongoDB container's network, connects to
# the MongoDB container, and imports the sample data as MongoDB collections.
docker run --rm -it \
  --net $NETWORK_NAME \
  -v "$DIR"/../data:/tmp/data \
  $IMAGE_ID \
  /bin/bash -c "for file in /tmp/data/*.csv; do
     echo Importing \$file...
     mongoimport --host $CONTAINER_IP --db demo \
     --upsert --file \$file --type csv --headerline;
   done"
