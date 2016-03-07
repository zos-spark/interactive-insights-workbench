#!/bin/bash
# (c) Copyright IBM Corp. 2016.  All Rights Reserved.
# Distributed under the terms of the Modified BSD License.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Setup environment
source "$DIR/env.sh"

# Build the notebook image
docker-compose -f "$DIR/notebook.yml" build
