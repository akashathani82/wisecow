#!/usr/bin/env bash

set -e  # Stop on error

SRVPORT=4499
RSPFILE=response

rm -f $RSPFILE
mkfifo $RSPFILE

get_api() {
    read line || { echo "Failed to read request"; exit 1; }
    echo $line
}

handleRequest() {
    get_api
    mod=`fortune` || { echo "Failed to fetch fortune"; exit 1; }

    cat <<EOF > $RSPFILE
HTTP/1.1 200 OK

<pre>`cowsay $mod`</pre>
EOF
}

prerequisites() {
    command -v cowsay >/dev/null 2>&1 || { echo "cowsay missing"; exit 1; }
    command -v fortune >/dev/null 2>&1 || { echo "fortune missing"; exit 1; }
    command -v nc >/dev/null 2>&1 || { echo "netcat missing"; exit 1; }
}

main() {
    prerequisites
    echo "Wisdom served on port=$SRVPORT..."
    
    while true; do
        cat $RSPFILE | nc -lN $SRVPORT | handleRequest || echo "Request handling failed"
        sleep 0.01
    done
}

main
