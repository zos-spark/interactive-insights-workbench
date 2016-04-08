#!/bin/bash
# (c) Copyright IBM Corp. 2016.  All Rights Reserved.
# Distributed under the terms of the Modified BSD License.

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

USAGE="Usage: `basename $0` [--secure | --letsencrypt] [--password PASSWORD] [--secrets SECRETS_VOLUME]"

SECURE=${SECURE:=no}
LETSENCRYPT=${LETSENCRYPT:=no}
CONFIG=notebook.yml

# Parse args to determine security settings
while [[ $# > 0 ]]
do
key="$1"
case $key in
    --secure)
    SECURE=yes
    CONFIG=secure-notebook.yml
    ;;
    --letsencrypt)
    LETSENCRYPT=yes
    CONFIG=letsencrypt-notebook.yml
    ;;
    --secrets)
    SECRETS_VOLUME="$2"
    shift # past argument
    ;;
    --password)
    PASSWORD="$2"
    shift # past argument
    ;;
    *) # unknown option
    ;;
esac
shift # past argument or value
done

if [[ "$LETSENCRYPT" == yes || "$SECURE" == yes ]]; then
  if [ -z "${PASSWORD:+x}" ]; then
    echo "ERROR: Must set PASSWORD if running in secure mode"
    echo "$USAGE"
    exit 1
  fi
  if [ "$LETSENCRYPT" == yes ]; then
    if [ -z "${SECRETS_VOLUME:+x}" ]; then
      echo "ERROR: Must set SECRETS_VOLUME if running in letsencrypt mode"
      echo "$USAGE"
      exit 1
    fi
  fi
  PORT=${PORT:=443}
fi

# Setup environment
source "$DIR/env.sh"

# Create a Docker volume to store notebooks
docker volume create --name "$WORK_VOLUME"

# Bring up a notebook container, using container name as project name
echo "Bringing up notebook '$NAME'"
exec docker-compose -f "$DIR/$CONFIG" -p "$NAME" up -d
echo "Notebook $NAME is up"
