#!/usr/bin/env bash

SITE='ftp.freebsd.org/pub/FreeBSD/snapshots/i386/i386/10.2-STABLE'
DISTFILES=('base.txz' 'kernel.txz' 'doc.txz' 'ports.txz')

for DISTFILE in ${DISTFILES[@]}
do
	if [ ! -f $DISTFILE ]
	then
		wget http://$SITE/$DISTFILE
	fi
done

if [ -f grafana.img ]
then
	echo "File exists"
	FULLNAME=`readlink -f grafana.img`
else
	echo "File doesn't exist"
fi

truncate -s 24G grafana.img
MD_UNIT=`mdconfig -a -f grafana.img`


echo "export ZFSBOOT_DISKS=$MD_UNIT" > installscript
echo "BSDINSTALL_DISTSITE=ftp://$SITE" >> installscript
cat bsdinstall.script >> installscript
#bsdinstall script installscript
mdconfig -d -u $MD_UNIT
