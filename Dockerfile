FROM alpine:latest

RUN apk add --no-cache --update bash nano curl wget sudo \
	busybox-suid git xz pigz fuse-overlayfs py3-pip \
	docker supervisor openssh docker-compose net-tools \
	bash-completion busybox fuse unzip sshpass make && \
	mkdir -p /var/log/supervisor && \
	mkdir -p /var/run/sshd && \
	mkdir /root/.ssh && \
	ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa && \
	addgroup -g 1000 alpine && \
	adduser -u 1000 -G alpine -h /home/alpine -D alpine && \
	sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd && \
	echo "alpine ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
	echo "root":"root" | chpasswd && echo "alpine":"alpine" | chpasswd && \
	adduser alpine wheel && adduser alpine root && adduser alpine docker && \
	curl https://rclone.org/install.sh | sudo bash && \
	curl -O https://releases.hashicorp.com/terraform/1.1.7/terraform_1.1.7_linux_amd64.zip && \
	unzip terraform_1.1.7_linux_amd64.zip && mv terraform /usr/bin/ && \
	chmod +x /usr/bin/terraform && rm -f terraform_1.1.7_linux_amd64.zip && \
	pip3 install --no-cache-dir runlike

COPY assets /tmp/assets

RUN cd /tmp/assets && \
	mkdir -p /etc/supervisor.d/ && \
	cp -a supervisord.ini /etc/supervisor.d/ && \
	mkdir -p /usr/bin/ && \
	cp -a entrypoint.sh /usr/bin/ && \
	mkdir -p /etc/docker/ && \
	cp -a daemon.json /etc/docker && \
	rm -f /etc/motd && \
	cp -a motd /etc && chmod 644 /etc/motd && \
	touch /etc/fuse.conf && \
	echo "user_allow_other" > /etc/fuse.conf && chmod 775 /etc/fuse.conf && \
	cp -a versions /usr/bin && \
	cp -a sshd_config /etc/ssh

EXPOSE 22 2375
WORKDIR /home/alpine
VOLUME [ "/var/lib/docker" ]
USER alpine
ENTRYPOINT ["sudo", "/usr/bin/entrypoint.sh"]
