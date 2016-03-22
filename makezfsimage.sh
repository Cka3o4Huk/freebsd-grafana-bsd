#!/usr/bin/env bash

#Global parameters
CURRDIR=`pwd`
IMAGENAME=grafana.img
SITE='ftp.freebsd.org/pub/FreeBSD/snapshots/i386/i386/10.2-STABLE'
DISTFILES=('base.txz' 'kernel.txz' 'doc.txz' 'ports.txz')
DISTFOLDER=$CURRDIR/dist
GENFILES=$CURRDIR/generated
INSTALLSCRIPT=$GENFILES/installscript
USERID=`id -u`

#Check user ID
if [ $USERID -ne 0 ] 
then
	echo "### ===> Script is running as non-root user:" `id -un`
	echo "###  !!! Make sure that user has grants for mdconfig"
	SUDO='sudo '
else
	SUDO=''
fi

#Clean up & create skeleton
#rm -rf $DISTFOLDER
mkdir -p $DISTFOLDER
rm -rf $GENFILES
mkdir -p $GENFILES
rm -rf $GENFILES/etc
mkdir -p $GENFILES/etc

#Fetch FreeBSD distribution files
echo "### Fetching files..."
for DISTFILE in ${DISTFILES[@]}
do
	if [ ! -f $DISTFOLDER/$DISTFILE ]
	then
		wget -P $DISTFOLDER http://$SITE/$DISTFILE 
	fi
done

#Unmount old image
if [ -f $IMAGENAME ]
then
	echo "### Check actual memory drivers..."
	FULLNAME=`readlink -f $IMAGENAME`
	MD_UNIT=`$SUDO mdconfig -l -v | grep $FULLNAME | cut -f1`
	if [ ! -z $MD_UNIT ]
	then 
		echo "### Detach existing image if mdconfiged"
		$SUDO mdconfig -d -u $MD_UNIT
	fi
	echo "### Done"
fi

#Create new image
echo "### Creating and mounting images..."
rm -rf $IMAGENAME
truncate -s 24G $IMAGENAME
MD_UNIT=`$SUDO mdconfig -a -f $IMAGENAME`
echo "### Created unit: $MD_UNIT"

#Install software
echo "export ZFSBOOT_DISKS=$MD_UNIT" > $INSTALLSCRIPT
echo "BSDINSTALL_DISTSITE=ftp://$SITE" >> $INSTALLSCRIPT
echo "BSDINSTALL_DISTDIR=$DISTFOLDER" >> $INSTALLSCRIPT
echo "BSDINSTALL_TMPETC=$GENFILES/etc" >> $INSTALLSCRIPT
echo "BSDINSTALL_CHROOT=$CURRDIR/root" >> $INSTALLSCRIPT
cat bsdinstall.script >> $INSTALLSCRIPT
echo "### Installing..."
env BSDINSTALL_LOG=./installation.log $SUDO bsdinstall script $INSTALLSCRIPT < /dev/null 

#Post-installation cleanup
#$SUDO zpool export zroot
#$SUDO mdconfig -d -u $MD_UNIT
