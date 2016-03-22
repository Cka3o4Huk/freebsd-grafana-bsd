#/usr/bin/env sh 

/usr/share/examples/bhyve/vmrun.sh -c 1 -m 1024M -t tap0 -d grafana.img $1 $2 freebsd
