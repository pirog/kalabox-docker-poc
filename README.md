Kalastack Docker
===================

This repo contains the source for a [Kalastack-like](https://github.com/kalamuna/kalastack/) Drupal stack using [Docker](http://docker.io) container technology for Drupal. It was
built specifically for the [Kalabox](http://kalabox.kalamuna.com) project and for use with [boot2docker-cli](https://github.com/boot2docker/boot2docker-cli).

## Quick Start

We have provided a script to help you get started really easily. Right now this startup script has only been tested on MacOSX 1.9+

On your host machine
```
cd ~
# Get a copy of the kalastack-docker project.
git clone https://github.com/kalamuna/kalastack-docker.git
# Perform Mac installation.
cd kalastack-docker/macosx
./setup.sh
```

In order to access your webserver in your browser you wil want to add an entry into your /etc/hosts file. To do this you need to find the docker vm ip address.
Luckily it is really easy to do this now by running `boot2docker ip` Once you discover this IP address you want to add an entry into the /etc/hosts file on you hosts machine like this:

```
1.3.3.7 test.kala
```

## Useful Things

### Connecting to SSH, MySQL and other services

You can run `docker ps` inside the docker vm to see what ports are doing in your container. This will help you access your services.

```
CONTAINER ID        IMAGE                     COMMAND               CREATED             STATUS              PORTS                                                                   NAMES
c69959c355ae        kalastack-docker:latest   /bin/bash /start.sh   2 seconds ago       Up 1 seconds        0.0.0.0:49171->22/tcp, 0.0.0.0:49172->3306/tcp, 0.0.0.0:49173->80/tcp   test.kala
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

### Building a Drupal site

The easiest way to build a Drupal site is to ssh into your container and navigate to your code by running `cd /data/code`. Once you are in here you can build a site from Acquia or Pantheon by
using the [Switchboard](https://github.com/fluxsauce/switchboard) or by pulling a site down with curl, wget or git.

### Sharing Code with your Host

Most people like to use the text-editor or IDE on their host machine. Kalastack-docker does not provide any file sharing with your host out of the box but you can download a copy of your
code onto your host machine and sync it into your container with

With scp
```
scp -rp -P 49171 ~/mycode/* root@test.kala:/data/code/
```

With rsync over ssh
```
rsync -ravz -e "ssh -p 49171 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --delete --progress --exclude 'sites/default/files' ~/mycode/* root@test.kala:/data/code/
```

Remember to use the correct SSH port for your container.


### SSH Key Forwarding

For now the easiest way to forward your keys into any kalastack-docker is to add the following lines to your ~/.ssh/config file

```
Host *.kala
  ForwardAgent yes
```

This assumes that your VIRTUAL_HOST is set to something.kala when you run your container.

### Debugging Code

As long as you use the setup script above or set your boot2docker host-only network host IP to 1.3.3.1 you can use xdebug out of the box with kalastack-docker. Of course, you will
want to follow the normal procedure for setting up debug config for your text editor/IDE. In SublimeText2 the config looks something like this:

```
{
  "folders":
  [
    {
      "path": "/Users/mpirog/mycode"
    }
  ],
  "settings":
  {
    "xdebug":
    {
      "super_globals": true,
      "close_on_stop": true,
      "path_mapping":
      {
        "/data/code/": "/Users/mpirog/mycode/"
      },
      "port": 9000,
      "url": "http://test.kala"
    }
  }
}
```

## Manual Installation

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
users must instantiate a data-only container built specifically for Kalabox. To do so please follow the [installation instructions](https://github.com/kalamuna/kaladata-docker). You will want to give your data container a name you can remember such as 'test_data.' You will need this later when you mount this onto Kalastack

### Pull/build container

You can either pull the container pre-built from the [Docker Index](https://index.docker.io/) or you can build the container from source.

First SSH into boot2docker by running `boot2docker ssh`

To pull from the Docker Index simply run

`docker pull pirog/kalastack-docker`

To build from source run the following

```
git clone https://github.com/kalamuna/kalastack-docker.git
cd kalastack-docker
docker build --tag="pirog/kalastack-docker" .
```

### Start your container

VIRTUAL_HOST and VIRTUAL_PORT tell the kalabox-proxy how to route your request.
VIRTUAL_HOST should be the address you want to enter into your browser to access
your site. VIRTUAL_PORT should almost always be 80. You will want to add an
entry into your /etc/hosts file on the host side to facilitate the magic.
Please consult "Your VM IP address" below for more details.

```
docker run -d -t \
  -e VIRTUAL_HOST=test.kala \
  -e VIRTUAL_PORT=80 -p :22 -p :80 -p :3306 \
  --volumes-from="test_data" \
  --name="test.kala" \
  --hostname="test.kala" \
  pirog/kalastack-docker:latest
```

## Uninstall

The best way to uninstall this whole thing either because you hate it or to try
to reinstall is to use the uninstall script packaged with the repo

```
# Return to where you cloned or downloaded the kalastack-docker code
cd ~
cd kalastack-docker/macosx
./uninstall.sh
```

## Contributing
Feel free to fork and contribute to this code. :)

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Authors

Forked from/based on the [drupal-docker-nginx](https://github.com/ricardoamaro/docker-drupal-nginx) project by [Ricardo Amaro](https://github.com/ricardoamaro) (<mail@ricardoamaro.com>)

## License
GPL v3
