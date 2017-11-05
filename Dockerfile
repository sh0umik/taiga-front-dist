FROM nginx

# Based in work of Hylke Visser <htdvisser@gmail.com>
MAINTAINER Claudio Ferreira <filhocf@gmail.com>

# For proxy, use as --build-arg in docker build command:
# --build-arg PKG_PROXY='Acquire::http { Proxy "http://<proxy_ip>:<port>"; };'
ARG PKG_PROXY

# Install Git
RUN \
    # Set a package proxy in next line
    echo ${PKG_PROXY} > /etc/apt/apt.conf; \
    apt-get update && apt-get install -y git wget && rm -rf /var/lib/apt/lists/*

# NginX Configuration
ADD nginx.conf /etc/nginx/nginx.conf
ADD mime.types /etc/nginx/mime.types
ADD web-http.conf /etc/nginx/web-http.conf
ADD web-https.conf /etc/nginx/web-https.conf

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

# Install taiga-front-dist
RUN \
  mkdir -p /usr/local/taiga/taiga-front-dist && \
  # git clone https://github.com/taigaio/taiga-front-dist.git /usr/local/taiga/taiga-front-dist && \
  wget -qO- https://github.com/taigaio/taiga-front-dist/archive/stable.tar.gz | tar xvz --strip-components=1 -C /usr/local/taiga/taiga-front-dist
  # cd /usr/local/taiga/taiga-front-dist && \
  # git checkout stable

# Configuration and Start scripts
ADD ./configure /usr/local/taiga/configure
ADD ./start /usr/local/taiga/start
RUN chmod +x /usr/local/taiga/configure /usr/local/taiga/start

EXPOSE 80 443

CMD ["/usr/local/taiga/start"]

# docker run -it --rm --name taiga-front --link taiga-back -p 80:80 -p 443:443 -e DEFAULT_LANG=pt-br -e LOGIN_TYPE='ldap' filhocf/taiga-front bash
