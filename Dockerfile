FROM ubuntu:latest

RUN \
  apt-get update && \
  apt-get -y dist-upgrade && \
  apt-get install -y --no-install-recommends \ 
	openssl \
	curl \
	dnsutils \
	openssh-client \
	ca-certificates \
	cron \
	supervisor \
	docker.io && \
  curl --silent https://raw.githubusercontent.com/srvrco/getssl/master/getssl > /usr/sbin/getssl && \ 
  chmod 700 /usr/sbin/getssl && \
  apt-get clean -y && \
  apt-get autoclean -y && \
  apt-get autoremove -y && \
  rm -rf /var/lib/apt/lists/* /var/lib/log/* /tmp/* /var/tmp/*

ADD ./docker/cron/getssl /etc/cron.d/
ADD ./docker/supervisor/supervisord.conf /etc/
ADD ./docker/supervisor/services /etc/supervisord.d/
ADD ./docker/getssl/configure.sh /usr/sbin/
ADD ./docker/getssl/reload.sh /usr/sbin/
ADD ./docker/getssl/template.cfg /root/
ADD ./docker/getssl/base_template.cfg /root/

VOLUME /root/.getssl
VOLUME /root/ssl
VOLUME /root/acme-challenge

WORKDIR /root

CMD ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
