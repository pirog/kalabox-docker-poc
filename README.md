Kalastack Docker
===================

This repo contains the source for a [Kalastack-like](https://github.com/kalamuna/kalastack/) Drupal stack using [Docker](http://docker.io) container technology for Drupal. It was
built specifically for the [Kalabox](http://kalabox.kalamuna.com) project and for use with [boot2docker-cli](https://github.com/boot2docker/boot2docker-cli).

## Installation

### Install boot2docker-cli

Start by [installing boot2docker-cli](https://github.com/boot2docker/boot2docker-cli).

### Pull/build container

You can either pull the container pre-built from the [Docker Index](https://index.docker.io/) or you can build the container from source.

First SSH into boot2docker by running `boot2docker ssh`

To pull from the Docker Index simply run

`docker pull pirog/kalastack-docker`

To build from source run the following

```
$ git clone https://github.com/kalamuna/kalastack-docker.git
$ cd kalastack-docker
$ docker build --tag="kalastack-docker" . #may need sudo?
```

### Start your container
```
$ docker run -d -p :22 -p :80 -p :3306 --name="sumptinawesome" kalastack-docker
```

## Service and IP discovery
In order to use most of the services inside your container you are going to want to know the IP address of the docker VM and also the ports to access them.

### Your VM IP address

Generally you can find this by `ifconfig` inside your docker vm. If you aren't doing anything weird this will usually be something like 192.168.59.103. You may also wish to check your boot2docker config
to see if an alternate IP address is being used. You can do that by running `boot2docker config` on your host machine.

### Service Discovery

You can run `docker ps` on your host machine to see what ports are doing in your container. This will help you access your services.

```
CONTAINER ID        IMAGE                     COMMAND               CREATED             STATUS              PORTS                                                                   NAMES
c69959c355ae        kalastack-docker:latest   /bin/bash /start.sh   2 seconds ago       Up 1 seconds        0.0.0.0:49171->22/tcp, 0.0.0.0:49172->3306/tcp, 0.0.0.0:49173->80/tcp   sumptinawesome
```

In the above example the following service mappings apply

```
SSH   -> 22   -> 49171
HTTP  -> 80   -> 49173
MYSQL -> 3306 -> 49172
```

Meaning you can connect to these services on your host machine in the following ways:

1. HTTP  -> Navigate to 192.168.59.103:49173 in your browser
2. SSH   -> Run `ssh -p 49171 root@192.168.59.103` (the default password should be kala)
3. MYSQL -> Using your favorite mysql client use host: 192.168.59.103, port: 49172, user: root, pass: root.

We are assuming your VM IP address is 192.168.59.103 in the above example.

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
