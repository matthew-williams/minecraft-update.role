#!/bin/bash

#----------------------------------------
# A shell script for updating the minecraft server jar file on Linux Servers
# Written by: Matthew Williams
# Last updated on: 2019.Nov.24
# Distributed under The MIT License (MIT)
#
# Dependencies
# unzip
#
#
#			---- IMPORTANT ----
# 	This script merely updates the minecraft server jar.
# 	Wrap this script in a wrapper script to take care of stopping and
#	starting your server based on your setup.
# 	If you need to change permissions on the final server jar do it from
#	within that warpper script as well.
#
# Example Wrapper Script:
# 	systemctl stop minecraft
#	./updatemcjar.sh -y --jar-path "/srv/minecraft/server.jar"
#	sudo chown minecraft:minecraft "/srv/minecraft/server.jar"
#	sudo chmod 750 "/srv/minecraft/server.jar"
#	sudo chmod +x "/srv/minecraft/server.jar"
#	systemctl start minecraft
#----------------------------------------

# Error out script on errors
set -e

# Default Settings (Can be changed through parameters)
TEMP_DIR='/tmp/updatemc/'
PACK_PATH='/usr/bin/minecraft/server/'

# Output paths
NORMAL_OUT=/dev/stdout
ERROR_OUT=/dev/stderr

# Parameter Flags
FLAG_NEWPACK=
FLAG_CONFIRM=
BACKUP_ONLY='0'
FLAG_TEST='0'

# Help Page
usage()
{
	echo
	echo "----------------------------------------"
	echo "$0 - A tool for unzipping and updating the minecraft server files easily"
	echo "Written by: Matthew Williams - Distributed under The MIT License (MIT)"
	echo
	echo "Dependencies:"
	echo "    cURL                 Included in most major distributions package repositories"
	echo "    jq                   Check your distribution repositories or build from source"
  echo "    unzip                Required in order to unzip the package"
	echo
	echo "Usage: $0 [options]"
	echo
	echo "    -y, --yes            Skip update confirmation"
	echo "    -n, --newpack        Specify the location of the new pack .zip file"
	echo "    -b, --backup         Backup only, no new pack will be installed"
	echo "    --temp-dir           Specify a different temporary directory, default is $TEMP_DIR"
	echo "    --pack-path          Specify a different final pack path folder, where the server is installed you want to update, default is $PACK_PATH"
	echo "    -t                   Tests the script, will not remove current server files or replace them. WILL STILL REMOVE 7 DAY OR OLDER BACKUPS"
	echo "    -h, --help           Print this help message"
	echo
	echo "Examle Usage:"
	echo "    $0                   Run the script normally"
	echo "    $0 -n minecraft.zip -y       Update to the minecraft.zip without asking for confirmation"
	echo
	echo "----------------------------------------"
	echo
}


# Check Script Parameters
while [ "$1" != "" ]; do
	case $1 in
		-n | --newpack )	shift
					FLAG_NEWPACK=$1
					;;
		-y | --yes )		FLAG_CONFIRM='1'
					;;
		-b | --backup )		BACKUP_ONLY='1'
					FLAG_CONFIRM='1'
					;;
		--temp-dir )		shift
					TEMP_DIR=$1
					;;
		--pack-path )		shift
					PACK_PATH=$1
					;;
		-t | --test )		FLAG_TEST='1'
					;;
		-h | --help )		usage
					exit
					;;
		* )			echo "Bad option specified"
					usage
					exit 1
					;;
	esac
	shift
done

DATE='date +%y_%m_%d_%H%M%S'
if [[ "$BACKUP_ONLY" == "1" ]];
then
	echo "----BACK UP ONLY----" > $NORMAL_OUT
fi
mkdir -p $PACK_PATH
mkdir -p $TEMP_DIR
echo "Removing old backups in $TEMP_DIR" > $NORMAL_OUT
find ${TEMP_DIR}/ -type f -mtime +7 -delete
echo "----Done----" > $NORMAL_OUT
echo "Backing up $PACK_PATH" > $NORMAL_OUT
rsync -vph ${PACK_PATH}server.properties ${TEMP_DIR}
if [ -e ${PACK_PATH}ops.json ]
then
	rsync -vph ${PACK_PATH}ops.json ${TEMP_DIR}
	rsync -vph ${PACK_PATH}whitelist.json ${TEMP_DIR}
	rsync -rvph ${PACK_PATH}backups ${TEMP_DIR}
	rsync -rvph ${PACK_PATH}world ${TEMP_DIR}
fi
rsync -vph ${PACK_PATH}*.txt ${TEMP_DIR}
rsync -vph ${PACK_PATH}settings.sh ${TEMP_DIR}
echo "----Done----" > $NORMAL_OUT
if [[ "$BACKUP_ONLY" == "1" ]];
then
	echo "----FINISHED BACKING UP----" > $NORMAL_OUT
	echo "----BACKUP FLAG:$BACKUP_ONLY----" > $NORMAL_OUT
else
	echo "Replacing files from $PACK_PATH" > $NORMAL_OUT
	if [ -e $FLAG_NEWPACK ]
	then
		rm -R $PACK_PATH
		mkdir -p $PACK_PATH
		unzip -oqD $FLAG_NEWPACK -d $PACK_PATH
		echo "----Done----" > $NORMAL_OUT
	  echo "Returning the backup files from $PACK_PATH" > $NORMAL_OUT
		rsync -vph ${TEMP_DIR}server.properties ${PACK_PATH}
		rsync -vph ${TEMP_DIR}*.txt ${PACK_PATH}
		rsync -vph ${TEMP_DIR}settings.sh ${PACK_PATH}
		rsync -vph ${TEMP_DIR}ops.json ${PACK_PATH}
		rsync -vph ${TEMP_DIR}whitelist.json ${PACK_PATH}
		rsync -rvph ${TEMP_DIR}backups ${PACK_PATH}
		rsync -rvph ${TEMP_DIR}world ${PACK_PATH}
		echo "----Done----" > $NORMAL_OUT
		chown -R minecraft:minecraft $PACK_PATH
		echo "----FINISHED UPDATING----" > $NORMAL_OUT
	else
		echo "This: $FLAG_NEWPACK does not exist!!" > $ERROR_OUT
		exit 1
	fi
fi
