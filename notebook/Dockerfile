# (c) Copyright IBM Corp. 2016.  All Rights Reserved.
# Distributed under the terms of the Modified BSD License.

# Pin to a known release for sanity
FROM jupyter/all-spark-notebook:2d878db5cbff

# Become root to do the apt-gets
USER root

# Install latest version of node & npm
RUN apt-get update && \
    apt-get install --yes curl && \
    curl --silent --location https://deb.nodesource.com/setup_0.12 | sudo bash - && \
    apt-get install --yes nodejs npm && \
    ln -s /usr/bin/nodejs /usr/bin/node && \
    npm install -g bower

# Do the pip installs as the unprivileged notebook user
USER jovyan

# Install dashboard layout and preview within Jupyter Notebook
RUN pip install jupyter_dashboards && \
    jupyter dashboards install --user --symlink && \
    jupyter dashboards activate

# Install declarative widgets for Jupyter Notebook
RUN pip install jupyter_declarativewidgets && \
    jupyter declarativewidgets install --user --symlink && \
    jupyter declarativewidgets activate

# Install content management to support dashboard bundler options
RUN pip install jupyter_cms && \
    jupyter cms install --user --symlink && \
    jupyter cms activate
RUN pip install jupyter_dashboards_bundlers && \
    jupyter dashboards_bundlers activate

# Install packages needed for demo notebooks (in Python 2 and 3 environments)
RUN pip install \
    pymongo==3.2.1
RUN $CONDA_DIR/envs/python2/bin/pip install \
    requests==2.9.1 \
    pymongo==3.2.1

# Copy sample notebooks into image
USER root
COPY ./samples/ /samples/

# Use custom entrypoint script to copy sample notebooks to notebook directory
# on container start
COPY docker-entrypoint.sh /srv/docker-entrypoint.sh
RUN chmod 755 /srv/docker-entrypoint.sh
ENTRYPOINT ["tini", "--", "/srv/docker-entrypoint.sh"]
CMD ["start-notebook.sh"]

# Stay as jovyan user in the newer docker-stack images
USER jovyan
