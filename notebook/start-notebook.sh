#!/bin/bash
# (c) Copyright IBM Corp. 2016.  All Rights Reserved.
# Distributed under the terms of the Modified BSD License.

# Copy sample notebooks to directory in notebook user's work directory
# IF the directory is empty, and make sure they're owned by the notebook user
SAMPLES_DIR=/home/$NB_USER/work/samples
files=("$SAMPLES_DIR"/*)

if [ -d "$SAMPLES_DIR" ] && [ ${#files[@]} -gt 0 ]; then
  echo "$SAMPLES_DIR" has content.  Skipping copy of sample notebooks.
else
  echo Copying sample notebooks from /samples to "$SAMPLES_DIR"
  cp -R /samples/ "$SAMPLES_DIR" && \
  chown $NB_USER "$SAMPLES_DIR"
fi

# Start jupyter notebook
/usr/local/bin/start-notebook.sh $*
