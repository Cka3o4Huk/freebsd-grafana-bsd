#!/usr/bin/env bash

DISTFILES=('base.txz' 'kernel.txz' 'doc.txz' 'ports.txz')

for DISTFILE in DISTFILES
do
	if [ ! -f $DISTFILE ]
	then
		wget http://ftp.freebsd.org/pub/FreeBSD/snapshots/i386/i386/10.2-STABLE/$DISTFILE
	fi
done

truncate -s 24G grafana.img
MD_UNIT=`mdconfig -a -f grafana.img`

echo "export ZFSBOOT_DISKS=$MD_UNIT" > installscript
cat bsdinstall.script >> installscript
#bsdinstall script installscript
