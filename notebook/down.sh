#!/bin/bash
# (c) Copyright IBM Corp. 2016.  All Rights Reserved.
# Distributed under the terms of the Modified BSD License.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Setup environment
source "$DIR/env.sh"

# Bring down the notebook container, using container name as project name
docker-compose -f "$DIR/notebook.yml" -p "$NAME" down
