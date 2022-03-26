FROM alpine:latest

RUN apk add --no-cache --update bash nano curl wget sudo busybox-suid \
	docker supervisor openssh docker-compose net-tools bash-completion busybox && \
	mkdir -p /var/log/supervisor && \
	mkdir -p /var/run/sshd && \
	sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
	sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
	mkdir /root/.ssh && \
	ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa && \
	addgroup -g 1000 alpine && \
	adduser -u 1000 -G alpine -h /home/alpine -D alpine && \
	sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd && \
	echo "alpine ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
	echo "root":"root" | chpasswd && echo "alpine":"alpine" | chpasswd && \
	adduser alpine wheel && adduser alpine root && adduser alpine docker

COPY assets /tmp/assets

RUN cd /tmp/assets && \
	mkdir -p /etc/supervisor.d/ && \
	cp -a supervisord.ini /etc/supervisor.d/ && \
	mkdir -p /usr/bin/ && \
	cp -a entrypoint.sh /usr/bin/ && \
	mkdir -p /etc/docker/ && \
	cp -a daemon.json /etc/docker/

EXPOSE 22 2375
WORKDIR /home/alpine
VOLUME [ "/var/lib/docker" ]
USER alpine
ENTRYPOINT ["sudo", "/usr/bin/entrypoint.sh"]
