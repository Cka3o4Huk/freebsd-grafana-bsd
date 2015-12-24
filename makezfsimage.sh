#!/usr/bin/env bash

CURRDIR=`pwd`
IMAGENAME=grafana.img
SITE='ftp.freebsd.org/pub/FreeBSD/snapshots/i386/i386/10.2-STABLE'
DISTFILES=('base.txz' 'kernel.txz' 'doc.txz' 'ports.txz')

echo "### Fetching files..."
for DISTFILE in ${DISTFILES[@]}
do
	if [ ! -f $DISTFILE ]
	then
		wget http://$SITE/$DISTFILE
	fi
done

if [ -f $IMAGENAME ]
then
	FULLNAME=`readlink -f $IMAGENAME`
	MD_UNIT=`mdconfig -l -v | grep $FULLNAME | cut -f1`
	mdconfig -d -u $MD_UNIT
fi

echo "### Creating and mounting images..."
rm -rf $IMAGENAME
truncate -s 24G $IMAGENAME
MD_UNIT=`mdconfig -a -f $IMAGENAME`

echo "export ZFSBOOT_DISKS=$MD_UNIT" > installscript
echo "BSDINSTALL_DISTSITE=ftp://$SITE" >> installscript
echo "BSDINSTALL_DISTDIR=$CURRDIR" >> installscript
cat bsdinstall.script >> installscript
echo "### Installing..."
bsdinstall script installscript < /dev/null 
zpool export zroot
mdconfig -d -u $MD_UNIT
