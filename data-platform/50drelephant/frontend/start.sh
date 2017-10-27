#!/bin/bash
function stop {
        /usr/dr-elephant/bin/stop.sh
        exit
}

trap stop EXIT
PID_FILE=/usr/dr-elephant/RUNNING_PID
/usr/dr-elephant/bin/start.sh /usr/dr-elephant/app-conf/

L=0
sleep 5;
until timeout 1 bash -c 'cat < /dev/null > /dev/tcp/localhost/8080' &> /dev/null; do
sleep 1
L=$((L+1))
if [[ $L -ge 10 && ! -f "${PID_FILE}" ]]; then
        stop
fi
done

while [[ -f "${PID_FILE}" ]]; do
	sleep 2
done
