#!/bin/bash

function test_case_1 {
	set -e
	echo "Test suite 1"
	echo "************"
	echo
	docker system df -v || exit 1
	echo
	docker images || exit 1
	echo
	docker run hello-world || exit 1
	echo
	docker ps -a || exit 1
	echo
	docker info || exit 1
	echo
	echo "Test case 1 terminato"
	echo
}

function test_case_2 {
	set -e
	echo "Test suite 1"
	echo "************"
	echo
	sudo sudo ps -a | grep sshd || exit 1
	echo
	sudo sudo ps -a | grep crond || exit 1
	echo
	sudo netstat -taupen | grep "22" || exit 1
	echo
	sudo netstat -taupen | grep "2375" || exit 1
	echo
	echo "Test case 2 terminato"
	echo
}

function test_case_3 {
	set -e
	echo "Test suite 3"
	echo "************"
	echo
	sudo ls -alFh /home/alpine | grep "bash" || exit 1
	echo 
	sudo ls -alFh /root | grep "bash" || exit 1
	echo 
	sudo ls -alFh /etc/supervisor.d | grep "ini" || exit 1
	echo
	sudo ls -alFh /usr/bin | grep "entrypoint" || exit 1
	echo 
	sudo ls -alFh /etc/docker | grep "daemon" || exit 1
	echo
	echo "Test case 3 terminato"
	echo
}

function test_case_4 {
	set -e
	echo "Test suite 4"
	echo "************"
	echo
	docker run -dit --name=alpine alpine:latest /bin/sh || exit 1
	docker ps -a || exit 1
	echo "test" > file.txt || exit 1
	docker cp file.txt alpine:/root/file.txt || exit 1
	docker exec -it alpine sh -c "cat /root/file.txt" || exit 1
	docker stop alpine || exit 1
	docker ps -a || exit 1
	docker start alpine || exit 1
	docker exec -it alpine sh -c "cat /root/file.txt" || exit 1
	docker stop alpine || exit 1
	echo
	echo "Test case 4 terminato"
	echo
}

function execute {
	test_case_1 || return 1
	test_case_2 || return 1
	test_case_3 || return 1
	test_case_4 || return 1
}

execute

RET="$?"

echo "RET: $RET"
if [ $RET == "0" ]; then
	echo "All test succeded..."
else
	echo "Tests Failed..."
fi