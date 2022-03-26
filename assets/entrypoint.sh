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
	fi
else
	echo "Directory /home/alpine not found."
fi

/usr/bin/versions

echo "Start supervisord...."
echo
exec supervisord -n -c /etc/supervisor.d/supervisord.ini "$@"