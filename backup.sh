#!/bin/bash

# The path where the backups store.
BackupPath='/vagrant/Backups'

# Server name example in the Cloud: /app/testserver or /testserver
ServerName='testserver'

# Cloud name Dropbox
DropBoxBackup='true'

# Get date
CurrentDay=$(date +"%Y%m%d%H%M%S")
SevenDay=$(date -d -7day +"%Y%m%d")

# Path setting
# example /home/www  20141010-website.tar.gz
FilePath=('/test1' '/test2')
NamePath=('test1' 'test2')

# MYSQL setting
# MYSQL user MYSQL password
MysqlUser='root'
MysqlPass='root'

# MYSQL which database you want to backup?
MysqlDbs=('ec' 'oc')

# CurrentDay MYSQL backup FileName
CurrentDayMysqlFile=$CurrentDay'-mysql.tar.gz'

# MYSQL Path 
MYSQLDUMP=mysqldump
MYSQL=mysql

CurrentPath=$(pwd)

# Root of Dropbox/BaiduYun app  
CloudDir=/$(date +%Y%m%d) 
OldCloudDIR=/$(date -d -30day +%Y%m%d) 

# Config end

chmod +x ./dropbox_uploader.sh

cd /

# Create directory
if [ ! -x "$BackupPath" ]; then 
	mkdir "$BackupPath" 
fi

# Write privilege
if [ ! -w "$BackupPath" ] ; then
    chmod -R 700 $BackupPath 
fi

# Export mysql db 
echo -ne 'Dump mysql...' 
cd $BackupPath
for db in ${MysqlDbs[@]}; do 
	($MYSQLDUMP -u$MysqlUser -p$MysqlPass ${db} > ${db}.sql) 
done 
tar zcf $BackupPath/$CurrentDayMysqlFile *.sql 
tar zcf $BackupPath/$CurrentDayMysqlFile *.sql 
rm -rf $BackupPath/*.sql 
echo -e 'Done'

# Backup files 
echo -ne "Backup website files..." 
TotalPaths=${#FilePath[@]}
for (( i=0; i<$TotalPaths; i++)); do
	cd ${FilePath[$i]}
	TempPath=$(basename `pwd`)
	cd ..
	tar zcf $BackupPath/$CurrentDay'-'${NamePath[$i]}.tar.gz $TempPath/*
done
echo -e "Done" 

# Clean up 7day's backup on server
echo -ne "Delete local data of 7 days old..." 
echo $SevenDay
rm -rf $BackupPath/$SevenDay*
echo -e "Done" 

# Start Dropbox 
if [ $DropBoxBackup == "true"  ]; then
	echo -e "Start uploading(Dropbox)..." 
	cd $CurrentPath

	CurrentFiles=$BackupPath/$CurrentDay*
	for f in ${CurrentFiles[@]}; do 
		./dropbox_uploader.sh upload $f $ServerName/$CloudDir/`basename $f`
	done

	# Clean up 30day's backup on Dropbox 
	echo -e "Start clean up 30day's backup at Dropbox"
	./dropbox_uploader.sh delete $ServerName/$OldCloudDIR/ 
fi

echo -e "Upload done!" 
echo -e "Thank you! All done." 
