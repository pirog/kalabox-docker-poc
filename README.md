Kalastack Docker
===================

This repo contains the source for a [Kalastack-like](https://github.com/kalamuna/kalastack/) Drupal stack using [Docker](http://docker.io) container technology for Drupal. It was
built specifically for the [Kalabox](http://kalabox.kalamuna.com) project and for use with [boot2docker-cli](https://github.com/boot2docker/boot2docker-cli).

## Installation

### Install boot2docker-cli

We need to instantiate a docker environment in order to get all the docker magix.

Start by [installing boot2docker-cli](https://github.com/boot2docker/boot2docker-cli).

### Install kalabox-proxy

We want users to be able to enter something like "site.local" in their host browsers instead of "192.168.59.103:49173" to access their site. In order to do this we need to set up
a reverse proxy that sits in front of all the docker containers to route requests appropriately.

As such you will need to pull down the kalabox-proxy container and run it. For more
details on how to install the kalabox-proxy go [here](https://github.com/kalamuna/kalabox-proxy)

### Install kaladata-docker

We want users data to be stored outside of the docker container running the webserver so that webservers can be spun down, spun up, upgraded, swapped out, ec. In order to facilitate this
users must instantiate a data-only container built specifically for Kalabox. To do so please follow the [installation instructions](https://github.com/kalamuna/kaladata-docker). You will want to give your data container a name you can remember such as 'sumptinawesome_data.' You will need this later when you mount this onto Kalastack

### Pull/build container

You can either pull the container pre-built from the [Docker Index](https://index.docker.io/) or you can build the container from source.

First SSH into boot2docker by running `boot2docker ssh`

To pull from the Docker Index simply run

`docker pull pirog/kalastack-docker`

To build from source run the following

```
$ git clone https://github.com/kalamuna/kalastack-docker.git
$ cd kalastack-docker
$ docker build --tag="pirog/kalastack-docker" . #may need sudo?
```

### Start your container

VIRTUAL_HOST and VIRTUAL_PORT tell the kalabox-proxy how to route your request. VIRTUAL_HOST should be the address you want to enter into your browser to access your site. VIRTUAL_PORT should almost always be 80. You will want to add an entry into your /etc/hosts file on the host side to facilitate the magic. Please consult "Your VM IP address" below for more details.

```
$ docker run -d -t -e VIRTUAL_HOST=sumptinawesome.kala -e VIRTUAL_PORT=80 -p :22 -p :80 -p :3306 --volumes-from="sumptinawesome_data" --name="sumptinawesome" pirog/kalastack-docker
```

## Service and IP discovery
In order to use most of the services inside your container you are going to want to know the IP address of the docker VM and also the ports to access them.

### Your VM IP address

Generally you can find this by `ifconfig` inside your docker vm. If you aren't doing anything weird this will usually be something like 192.168.59.103. You may also wish to check your boot2docker config
to see if an alternate IP address is being used. You can do that by running `boot2docker config` on your host machine. Once you discover this IP address you want to add an entry into the /etc/hosts file
on you hosts machine like this:

```
192.168.59.103 test.kala
```

Where 192.168.59.103 is the IP of your docker VM and test.kala is the VIRTUAL_HOST you defined when you ran a kalstack-docker container.

### Service Discovery

You can run `docker ps` on your host machine to see what ports are doing in your container. This will help you access your services. I

```
CONTAINER ID        IMAGE                     COMMAND               CREATED             STATUS              PORTS                                                                   NAMES
c69959c355ae        kalastack-docker:latest   /bin/bash /start.sh   2 seconds ago       Up 1 seconds        0.0.0.0:49171->22/tcp, 0.0.0.0:49172->3306/tcp, 0.0.0.0:49173->80/tcp   sumptinawesome
```

In the above example the following service mappings apply

```
SSH   -> 22   -> 49171
HTTP  -> 3306 -> 49173
MYSQL -> 3306 -> 49172
```

Meaning you can connect to these services on your host machine in the following ways:

1. HTTP  -> Navigate to test.kala in your browser
2. SSH   -> Run `ssh -p 49171 root@test.kala` (the default password should be kala)
3. MYSQL -> Using your favorite mysql client use host: test.kala, port: 49172, user: root, pass: root.

In this example we assume that you have set your VIRTUAL_HOST for the container to test.kala and you have also set up the appropriate /etc/hosts entry on your host machine.

## Contributing
Feel free to fork and contribute to this code. :)

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Authors

Forked from/based on the [drupal-docker-nginx](https://github.com/ricardoamaro/docker-drupal-nginx) project by  [Ricardo Amaro](https://github.com/ricardoamaro) (<mail@ricardoamaro.com>)

## License
GPL v3
