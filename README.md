# Docker PHP-FPM 8.3+ & Nginx 1.26+ on Alpine Linux

Example PHP-FPM 8.3+ & Nginx 1.26+ container image for Docker, built on [Alpine Linux](https://www.alpinelinux.org/).

* Built on the lightweight and secure Alpine Linux distribution
* Multi-platform, supporting AMD4, ARMv6, ARMv7, ARM64
* Small Docker image size (+/-115MB) with composer and Common php extensions.
* Support PHP 8.2 ~ 8.4, low CPU usage & memory footprint
* Optimized for 100 concurrent users
* Optimized to only use resources when there's traffic (by using PHP-FPM's `on-demand` process manager)
* The services Nginx, PHP-FPM and supervisord run under a non-privileged user (nobody) to make it more secure
* The logs of all the services are redirected to the output of the Docker container (visible
  with `docker logs -f <container name>`)
* Follows the KISS principle (Keep It Simple, Stupid) to make it easy to understand and adjust the image to your needs


## Goal of this project

The goal of this container image is to provide a base image for running Nginx and PHP-FPM in a container which follows
the best practices and is easy to understand and modify to your needs.


## Usage

### 1. Build your own image.

```shell
docker build -t alpine-php:latest --rm .
```

Or build your own customized image with args(environment, php version, timezone):

```shell
docker build --build-arg ENV=dev -t alpine-dev:latest --rm .
```

### 2. Start the Docker container using the built images.

```shell
docker run -itd -p 80:8080 --name alpine-php alpine-php:latest
```

Or mount your own code to be served by PHP-FPM & Nginx

```shell
docker run -itd -p 80:8080 --name alpine-php -v ~/my-codebase:/var/www/project alpine-php:latest
```

### 3. Confirm if it works well.
Will See the PHP info on http://localhost if success. Please replace `localhost` by your own IP or domain.


## Configuration

In [config/](config/) you'll find the default configuration files for Nginx, PHP and PHP-FPM.
If you want to extend or customize that you can just modify and change it.


## Documentation and examples

To modify Dockerfile to your specific needs, please see the following examples:

* [Getting the real IP of the client behind a load balancer](docs/real-ip-behind-loadbalancer.md)
* [Enable https support](docs/enable-https.md)
* [Adding xdebug support](docs/xdebug-support.md)

## Thanks

This project is built upon [TrafeX/docker-php-nginx](https://github.com/TrafeX/docker-php-nginx)
and customized to better suit my requirements.