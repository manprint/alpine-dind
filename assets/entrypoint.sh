#!/bin/sh

set -e

if [ -d "/home/alpine" ]
then
	if [ "$(ls -A /home/alpine)" ]; then
		echo
		echo "Directory /home/alpine is not Empty... Skipping copy bashrc files..."
	else
		echo
		echo "Directory /home/alpine is Empty... Copy bashrc files..."
		cp -av /tmp/assets/bashrc/.bashrc /home/alpine/
		cp -av /tmp/assets/bashrc/.bash_profile /home/alpine/
		sudo chown -v -R alpine:alpine /home/alpine/
		cp -avr /tmp/assets/bashrc/.bashrc /root/
		cp -avr /tmp/assets/bashrc/.bash_profile /root/
		sudo -u alpine mkdir -p /home/alpine/.ssh/
		sudo -u alpine ssh-keygen -t rsa -f /home/alpine/.ssh/id_rsa -q -P ""
		sudo -u alpine touch /home/alpine/.ssh/authorized_keys
		sudo -u alpine chmod 600 /home/alpine/.ssh/authorized_keys
		sudo -u alpine cat /home/alpine/.ssh/id_rsa.pub > /home/alpine/.ssh/authorized_keys
		sudo -u alpine cp -a /home/alpine/.ssh/id_rsa /home/alpine/.ssh/alpine-dind.pem
	fi
else
	echo "Directory /home/alpine not found."
fi

/usr/bin/versions

echo "User: alpine - SSH Pem key - copy from: /home/alpine/.ssh/alpine-dind.pem"
echo
cat /home/alpine/.ssh/alpine-dind.pem
echo

echo "Start supervisord...."
echo
exec supervisord -n -c /etc/supervisor.d/supervisord.ini "$@"
