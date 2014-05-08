Kalastack Docker
===================

This repo contains the source for a [Kalastack-like](https://github.com/kalamuna/kalastack/) Drupal stack using [Docker](http://docker.io) container technology for Drupal. It was
build specifically for the [Kalabox](http://kalabox.kalamuna.com) project and for use with [boot2docker-cli](https://github.com/boot2docker/boot2docker-cli).

## Prereqs aka install docker via boot2docker-cli:

You can dowload binary releases at https://github.com/boot2docker/boot2docker-cli/releases

### Install from source

You need to have [Go compiler](http://golang.org) installed, and `$GOPATH`
[properly setup](http://golang.org/doc/code.html#GOPATH). Then run

    go get github.com/boot2docker/boot2docker-cli

The binary will be available at `$GOPATH/bin/boot2docker-cli`. However the
binary built this way will have missing version information when you run

    boot2docker-cli version

You can solve the issue by using `make goinstall`

```sh
cd $GOPATH/src/github.com/boot2docker/boot2docker-cli
make goinstall
```

## Installation

```
$ git clone https://github.com/kalamuna/kalastack-docker.git
$ cd kalastack-docker
$ sudo docker build -t="kalastack-docker" .
```

## MORE STUFF ONCE WE ARE g2g
1. Running the container with correct ports
2. Setting up environmental vars
3. Accessing from your host browser

You can find more images using the [Docker Index](https://index.docker.io/).


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
