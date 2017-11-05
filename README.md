# filhocf/taiga-front-dist

[Taiga](https://taiga.io/) is a project management platform for startups and agile developers & designers who want a simple, beautiful tool that makes work truly enjoyable.

This Docker image can be used for running the Taiga frontend. It works together with the [filhocf/taiga-back](https://registry.hub.docker.com/u/filhocf/taiga-back/) image.

[![GitHub stars](https://img.shields.io/github/stars/filhocf/taiga-docker.svg?style=flat-square)](https://github.com/filhocf/taiga-docker)
[![GitHub forks](https://img.shields.io/github/forks/filhocf/taiga-docker.svg?style=flat-square)](https://github.com/filhocf/taiga-docker)
[![GitHub issues](https://img.shields.io/github/issues/filhocf/taiga-docker.svg?style=flat-square)](https://github.com/filhocf/taiga-docker/issues)

## Running

A [filhocf/taiga-back](https://registry.hub.docker.com/u/filhocf/taiga-back/) container should be linked to the taiga-front-dist container. Also connect the volumes of this the taiga-back container if you want to serve the static files for the admin panel.

```
docker run --name taiga_front_dist_container_name --link taiga_back_container_name:taigaback filhocf/taiga-front-dist
```

## Docker-compose

For a complete taiga installation (``filhocf/taiga-back`` and ``filhocf/taiga-front``) you can use this docker-compose configuration:

```
data:
  image: tianon/true
  volumes:
    - /var/lib/postgresql/data
    - /usr/local/taiga/media
    - /usr/local/taiga/static
    - /usr/local/taiga/logs
db:
  image: postgres
  environment:
    POSTGRES_USER: taiga
    POSTGRES_PASSWORD: password
  volumes_from:
    - data
taigaback:
  image: filhocf/taiga-back:stable
  hostname: dev.example.com
  environment:
    SECRET_KEY: examplesecretkey
    EMAIL_USE_TLS: True
    EMAIL_HOST: smtp.gmail.com
    EMAIL_PORT: 587
    EMAIL_HOST_USER: youremail@gmail.com
    EMAIL_HOST_PASSWORD: yourpassword
  links:
    - db:postgres
  volumes_from:
    - data
taigafront:
  image: filhocf/taiga-front-dist:stable
  hostname: dev.example.com
  links:
    - taigaback
  volumes_from:
    - data
  ports:
    - 0.0.0.0:80:80
```

## SSL Support

HTTPS can be enabled by setting ``SCHEME`` to ``https`` and filling ``SSL_CRT``
and ``SSL_KEY`` env variables (see Environment section below). *http* (port 80)
requests will be redirected to *https* (port 443).

Example:

```
data:
  ...
db:
  ...
taigaback:
  image: filhocf/taiga-back:stable
  hostname: dev.example.com
  environment:
    ...
    API_SCHEME: https
    FRONT_SCHEME: https
  links:
    - db:postgres
  volumes_from:
    - data
taigafront:
  image: filhocf/taiga-front-dist:stable
  hostname: dev.example.com
  environment:
    SCHEME: https
    SSL_CRT: |
        -----BEGIN CERTIFICATE-----
        ...
        -----END CERTIFICATE-----
    SSL_KEY: |
        -----BEGIN RSA PRIVATE KEY-----
        ...
        -----END RSA PRIVATE KEY-----
  links:
    - taigaback
  volumes_from:
    - data
  ports:
    - 0.0.0.0:80:80
    - 0.0.0.0:443:443
```

## Environment

* ``PUBLIC_REGISTER_ENABLED`` defaults to ``true``
* ``API`` defaults to ``"/api/v1"``
* ``DEBUG`` defaults to ``false``
* ``SCHEME`` defaults to ``http``. If ``https`` is used either
  * ``SSL_CRT`` and ``SSL_KEY`` needs to be set **or**
  * ``/etc/nginx/ssl/`` volume attached with ``ssl.crt`` and ``ssl.key`` files
* ``SSL_CRT`` SSL certificate value. Valid only when ``SCHEME`` set to https.
* ``SSL_KEY`` SSL certificate key. Valid only when ``SCHEME`` set to https.
