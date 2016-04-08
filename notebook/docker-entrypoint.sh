#!/bin/bash
# (c) Copyright IBM Corp. 2016.  All Rights Reserved.
# Distributed under the terms of the Modified BSD License.

# If run command is starting the notebook server
cmd=$(which "$1")
if [ "$cmd" = "/usr/local/bin/start-singleuser.sh" ] ||
   [ "$cmd" = "/usr/local/bin/start-notebook.sh" ]; then
  # If notebook directory not explicitly set, use $NB_USER's work directory.
  : ${NOTEBOOK_DIR:=/home/$NB_USER/work}
  # Copy sample notebooks to notebook directory, if we have not already done so.
  I2W_DIR="$NOTEBOOK_DIR/.i2w"
  mkdir -p "$I2W_DIR"
  if [ ! -f "$I2W_DIR/samples" ]; then
    SAMPLES_DIR="$NOTEBOOK_DIR/samples"
    echo Copying sample notebooks from /samples to "$SAMPLES_DIR"
    mkdir -p "$SAMPLES_DIR"
    cp -R /samples/* "$SAMPLES_DIR" && \
      touch "$I2W_DIR/samples"
  fi
fi

# Run the command provided
exec "$@"
