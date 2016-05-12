# Run JupyterHub with Interactive Insights Workbench

Follow these instructions to deploy a multi-user [JupyterHub](https://github.com/jupyterhub/jupyterhub) server that spawns an instance of Interactive Insights Workbench per user, on a **single-host**.

## Deploy JupyterHub

Follow this [README](https://github.com/jupyterhub/jupyterhub-deploy-docker) to deploy JupyterHub on a single host using Docker.

## Build Interactive Insights Workbench

Clone this repo.

```
git clone https://github.com/zos-spark/interactive-insights-workbench.git
```

Build the `zos-spark/i2w-notebook` image.

```
cd interactive-insights-workbench/jupyterhub && \
    docker-compose build
```

## Configure JupyterHub

Configure JupyterHub to spawn single-user notebook servers using the `zos-spark/i2w-notebook` Docker image.

Set the `DOCKER_NOTEBOOK_IMAGE` environment variable in the `.env` file in the root of the `jupyterhub-deploy-docker` directory.

```
DOCKER_NOTEBOOK_IMAGE=zos-spark/i2w-notebook
```

## Run JupyterHub

Launch JupyterHub:

```
cd jupyterhub-deploy-docker && docker-compose up -d
```

## Configure Network

If you are running a MongoDB Docker container on the host, you can add the container to the JupyterHub network to enable the Interactive Insights Workbench instances to connect to it by name.

```
docker network connect jupyterhub-network mongodb
```

Now notebook users can connect to the MongoDB instance using

```python
client = MongoClient('mongodb', 27017)
```
