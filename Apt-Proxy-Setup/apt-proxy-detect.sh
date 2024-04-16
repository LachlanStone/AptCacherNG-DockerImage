#!/bin/bash
# Apt Cacher NG
IP=127.0.0.1
PORT=3142
if $IP == "127.0.0.1"
    echo -n "DIRECT"
elif nc -w1 -z $IP $PORT; then
    echo -n "http://${IP}:${PORT}"
else
    echo -n "DIRECT"
fi