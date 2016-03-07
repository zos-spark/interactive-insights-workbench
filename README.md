# Interactive Insights Workbench

The Interactive Insights Workbench is a software stack that is based on the [Jupyter Notebook](https://jupyter.org/) server.   It provides Jupyter Notebook 4.x with support for the following notebook environments:

* Python 2.7.x and Python 3.x, including libraries that are commonly used for data analysis, e.g., pandas, matplotlib, etc.
* R 3.2.x
* Apache Toree (Scale 2.10.4)

The workbench also bundles several Jupyter Notebook extensions that provide the ability to convert notebooks into interactive dashboards.  These extensions include:

* [Jupyter Declarative Widget Extension](https://github.com/jupyter-incubator/declarativewidgets) for building interactive widgets in notebooks
* [Jupyter Dynamic Dashboards Extension](https://github.com/jupyter-incubator/dashboards) to enable layout and presentation of grid-based dashboards from notebooks

Finally, this repo includes scripts that leverage [Docker](https://www.docker.com/) to make it is easy to build and deploy the workbench for individual users.  

## Prerequisites

To build and deploy the workbench image using the scripts provided, you will need to install the following Docker technologies on your local desktop.

* [Docker Engine](https://docs.docker.com/engine/) 1.10.0+
* [Docker Machine](https://docs.docker.com/machine/) 0.6.0+
* [Docker Compose](https://docs.docker.com/compose/) 1.6.0+

See the [installation instructions](https://docs.docker.com/engine/installation/) for your environment.

## Quickstart

To run the workbench on your local desktop, follow the steps below.  By doing so, you will:

* Create a new VirtualBox virtual machine on your local desktop
* Build the workbench Docker image on the VM
* Run the workbench Docker image as a Docker container on the VM


```
# create a Docker Machine-controlled VirtualBox VM on local desktop
bin/vbox.sh mymachine

# activate the docker machine
eval "$(docker-machine env mymachine)"

# build the notebook image on the machine
notebook/build.sh

# bring up the notebook container
notebook/up.sh
```

To access the workbench, visit `http://<mymachine_ip_address>:8888` in your web browser.

You can retrieve the IP address using:

```
docker-machine ip mymachine
```

To stop and remove the notebook container:

```
notebook/down.sh
```

## Sample Database

To run a [MongoDB](https://www.mongodb.com) Docker container, create a `demo` database, and load the sample data in the `data` directory as collections in the database, run the following:

```
# activate desired docker machine
eval "$(docker-machine env mymachine)"

# run MongoDB container and load sample data
bin/load-mongodb.sh
```

To bring up a MongoDB container:

```
cd mongodb && docker-compose up -d
```

To bring down the MongoDB container:

```
cd mongodb && docker-compose down
```

## FAQ

### Can I deploy to any host?

You can build and run the Docker images in this repo on any host that supports a recent version of [Docker Engine](https://docs.docker.com/engine/).  

This repo assumes that you are using [Docker Machine](https://docs.docker.com/machine/) to provision and manage multiple remote Docker hosts.

To make it easier to get up and running, this repo includes scripts that use Docker Machine to provision new virtual machines on both VirtualBox and IBM SoftLayer.

To create a Docker Machine on a new VirtualBox VM on your local desktop:

```
bin/vbox.sh mymachine
```

To create a Docker Machine on a new virtual device on IBM SoftLayer:

```
# Set SoftLayer credential as environment variables to be
# passed to Docker Machine
export SOFTLAYER_USER=my_softlayer_username
export SOFTLAYER_API_KEY=my_softlayer_api_key
export SOFTLAYER_DOMAIN=my.domain

# Create virtual device
bin/softlayer.sh myhost

# Add DNS entry (SoftLayer DNS zone must exist for SOFTLAYER_DOMAIN)
bin/sl-dns.sh myhost
```

In addition, you can use the scripts in this repo to build and run the workbench image on any other Docker Machine-controlled host.

### How do I deploy to an existing host?

To build and run the Docker images in this repo on an existing host, you simply need to add the host as a Docker machine.   All you need is the server's IP address, and the ability to login to the server using an SSH keypair.

Here's an example of creating a Docker Machine on your local desktop that points to the remote server at `10.0.0.10` using Docker Machine's `generic` driver.  

Be aware: this command will attempt to install Docker Engine on the host if it is not already present.

```
docker-machine create --driver generic \
  --generic-ip-address 10.0.0.10 \
  --generic-ssh-key /path/to/my/ssh/private/key \
  mymachine
```

You should see output similar to this:

```
Running pre-create checks...
Creating machine...
(mymachine) Importing SSH key...
Waiting for machine to be running, this may take a few minutes...
Detecting operating system of created instance...
Waiting for SSH to be available...
Detecting the provisioner...
Provisioning with ubuntu(upstart)...
Installing Docker...
Copying certs to the local machine directory...
Copying certs to the remote machine...
Setting Docker configuration on the remote daemon...
Checking connection to Docker...
Docker is up and running!
To see how to connect your Docker Client to the Docker Engine running on this
  virtual machine, run: docker-machine env mymachine
```

To view the machine details:

```
docker-machine ls

NAME               ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER    ERRORS
softlayer          -        generic      Running   tcp://10.0.0.10:2376               v1.10.1    
```

To run Docker commands on `mymachine`, activate it by running:

```
eval "$(docker-machine env mymachine)"
```

### Can I run multiple notebook containers on the same host?

Yes. Set environment variables to specify unique names and ports when running the `up.sh` command.

```
NAME=my-notebook PORT=9000 notebook/up.sh
NAME=your-notebook PORT=9001 notebook/up.sh
```

To stop and remove the containers:

```
NAME=my-notebook notebook/down.sh
NAME=your-notebook notebook/down.sh
```

### Where are my notebooks stored?

The `up.sh` creates a Docker volume named after the notebook container with a `-work` suffix, e.g., `my-notebook-work`.   Any files in the Jupyter notebook directory are stored in this volume and will persist across container restarts.


### Can multiple notebook containers share the same notebook volume?

Yes. Set the `WORK_VOLUME` environment variable to the same value for each notebook.

```
NAME=my-notebook PORT=9000 WORK_VOLUME=our-work notebook/up.sh
NAME=your-notebook PORT=9001 WORK_VOLUME=our-work notebook/up.sh
```

### How do I run over HTTPS?

To run the notebook server with a self-signed certificate, pass the `--secure` option to the `up.sh` script.  You must also provide a password, which will be used to secure the notebook server.  You can specify the password by setting the `PASSWORD` environment variable, or by passing it to the `up.sh` script.  

```
PASSWORD=a_secret notebook/up.sh --secure

# or
notebook/up.sh --secure --password a_secret
```

### Can I use Let's Encrypt certificate chains?

Sure.  If you want to secure access to publicly addressable notebook containers, you can generate a free certificate using the [Let's Encrypt](https://letsencrypt.org) service.


This example includes the `bin/letsencrypt.sh` script, which runs the `letsencrypt` client to create a full-chain certificate and private key, and stores them in a Docker volume.  _Note:_ The script hard codes several `letsencrypt` options, one of which automatically agrees to the Let's Encrypt Terms of Service.

The following command will create a certificate chain and store it in a Docker volume named `mydomain-secrets`.

```
FQDN=host.mydomain.com EMAIL=myemail@somewhere.com \
  SECRETS_VOLUME=mydomain-secrets \
  bin/letsencrypt.sh
```

Now run `up.sh` with the `--letsencrypt` option.  You must also provide the name of the secrets volume and a password.

```
PASSWORD=a_secret SECRETS_VOLUME=mydomain-secrets notebook/up.sh --letsencrypt

# or
notebook/up.sh --letsencrypt --password a_secret --secrets mydomain-secrets
```

Be aware that Let's Encrypt has a pretty [low rate limit per domain](https://community.letsencrypt.org/t/public-beta-rate-limits/4772/3) at the moment.  You can avoid exhausting your limit by testing against the Let's Encrypt staging servers.  To hit their staging servers, set the environment variable `CERT_SERVER=--staging`.

```
FQDN=host.mydomain.com EMAIL=myemail@somewhere.com \
  CERT_SERVER=--staging \
  bin/letsencrypt.sh
```

Also, be aware that Let's Encrypt certificates are short lived (90 days).  If you need them for a longer period of time, you'll need to manually setup a cron job to run the renewal steps. (You can reuse the command above.)

### Can I customize the workbench image?

Yes.  You can customize the workbench image by modifying the `notebook/Dockerfile`.  For example, you can install the `python-twitter` Python libraries by adding the following lines to the bottom of the Dockerfile:

```
RUN pip install python-twitter
```

Once you modify the Dockerfile, you need to rebuild the image and restart the notebook container before the changes will take effect.

```
# activate the docker machine
eval "$(docker-machine env mymachine)"

# rebuild the notebook image
notebook/build.sh

# restart the notebook container
notebook/down.sh
notebook/up.sh
```


## Troubleshooting

### I'm unable to connect to VirtualBox VM on Mac OS X when using Cisco VPN client.

The Cisco VPN client blocks access to IP addresses that it does not know about, and may block access to a new VM if it is created while the Cisco VPN client is running.

1. Stop Cisco VPN client. (It does not allow modifications to route table).
2. Run `ifconfig` to list `vboxnet` virtual network devices.
3. Run `sudo route -nv add -net 192.168.99 -interface vboxnetX`, where X is the number of the virtual device assigned to the VirtualBox VM.
4. Start Cisco VPN client.

### I'm unable to connect to my remote host using Docker Machine.

Docker Machine uses signed TLS certificates to connect to remote hosts ("machines").  Docker Machine will fail to connect to a remote machine if there is a problem during the TLS handshake.  For example:

```
eval "$(docker-machine env mymachine)"

Error checking TLS connection: Error checking and/or regenerating the certs: There was an error validating certificates for host "<mymachine_ip_address>:2376": x509: certificate signed by unknown authority
You can attempt to regenerate them using 'docker-machine regenerate-certs [name]'.
Be advised that this will trigger a Docker daemon restart which will stop running containers.
```

There may be several causes for this error, such as:

1. The SSH keys on your local or remote host have changed.  Ensure that you can login to the remote host using the SSH key.
2. Multiple people have connected to the same remote host using Docker Machine.  Docker Machine creates certificates in the `~/.docker/machine/certs` directory on the local host, and uses these certificates during the TLS handshake process.  This means that you cannot use Docker Machine to connect to a remote host from multiple clients unless you copy the certs to each client.  See this [enhancement request](https://github.com/docker/machine/issues/1328) for details.
