#!/bin/bash
# (c) Copyright IBM Corp. 2016.  All Rights Reserved.
# Distributed under the terms of the Modified BSD License.

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get the MongoDB container ID
CONTAINER_ID=$(docker ps --filter ancestor=mongo:3.2 --format {{.ID}})
if [[ -z "$CONTAINER_ID" ]]; then
  echo "A mongodb container does not appear to be running."
  echo "Please start it before loading the sample data."
  exit 1
fi
echo MongoDB container ID: $CONTAINER_ID

# Get the MongoDB image ID
IMAGE_ID=$(docker inspect --format {{.Config.Image}} $CONTAINER_ID)
echo MongoDB image: $IMAGE_ID

# We don't know if the data is on the host or on a machine controlling the host
# (using docker-machine), so we use some Docker magic to load the data:
#
# Create a temporary container, and have it wait until we feed it a poison pill.
# Have it connect to the MongoDB container network so we can load the data to it
# using 'localhost'.
TMP_CONTAINER=$(docker run -d \
  --net="container:$CONTAINER_ID" \
  $IMAGE_ID \
  /bin/bash -c \
  "mkdir -p /tmp/data && while [ ! -f /tmp/data/.loaded ]; do sleep 1; done")
# Copy the data into the temporary container
docker cp "$DIR"/../data/*.csv $TMP_CONTAINER:/tmp/data
# Run the mongoimport command on the temporary container and stop the container
# by creating the poison pill.
docker exec -it $TMP_CONTAINER \
  /bin/bash -c \
    "for file in /tmp/data/*.csv; do
       echo Importing \$file...
       mongoimport --db demo \
       --drop --file \$file --type csv --headerline; done &&
    touch /tmp/data/.loaded"
# Remove the temporary container
docker rm -f $TMP_CONTAINER >/dev/null
