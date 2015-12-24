#!/usr/bin/env bash

IMAGENAME=grafana.img
SITE='ftp.freebsd.org/pub/FreeBSD/snapshots/i386/i386/10.2-STABLE'
DISTFILES=('base.txz' 'kernel.txz' 'doc.txz' 'ports.txz')

for DISTFILE in ${DISTFILES[@]}
do
	if [ ! -f $DISTFILE ]
	then
		wget http://$SITE/$DISTFILE
	fi
done

if [ -f $IMAGENAME ]
then
	echo "File exists"
	FULLNAME=`readlink -f $IMAGENAME`
	MD_UNIT=`mdconfig -l -v | grep $FULLNAME | cut -f1`
	mdconfig -d -u $MD_UNIT
fi

rm -rf $IMAGENAME
truncate -s 24G $IMAGENAME
MD_UNIT=`mdconfig -a -f $IMAGENAME`

echo "export ZFSBOOT_DISKS=$MD_UNIT" > installscript
echo "BSDINSTALL_DISTSITE=ftp://$SITE" >> installscript
cat bsdinstall.script >> installscript
#bsdinstall script installscript
zpool export zroot
mdconfig -d -u $MD_UNIT
