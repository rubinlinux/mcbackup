#!/bin/bash

# Minecraft backup script
# By rubinlinux
# for Simplanet.org
# 2012-06-26
#
# Free to use/modify
#
# Place this script in your minecraft server directory (some place your server.properties file is)
# It will find the map name by itself by looking in server.properties
#
# Use 'crontab -e' to add this to cron. Something like the following (man crontab for help!)
# m h  dom mon dow   command
#00 */12 * * * /home/rubin/minecraft/server/mcbackup.sh
# The above runs a backup every 12 hours

#
# This script will place backups in this directory:
backuppath=/home/you/minecraftbackups
#
# It will keep this many copies going back in time
# (They use hardlinks, so only changed files will take up extra space...)
numbackups=14
#
#
##
## Everything else should be figured out for you automatically!

PATH="/bin:/usr/bin:/usr/local/bin:$PATH"

LOCKFILE=/tmp/mcbackup.pid

if [ -f $LOCKFILE ] && ps -p `cat $LOCKFILE` > /dev/null; then
  echo "genmap.sh lockfile still in place, refusing to run twice. Delete $LOCKFILE to fix this."
  exit 0
else
  [ -f $LOCKFILE ] && rm $LOCKFILE
fi

echo "$$" > $LOCKFILE

#Figure out the paths for you automatially
self=`readlink -f "$0"`
mappath=`dirname "$self"`
properties=`dirname "$self"`"/server.properties"
mapname=`grep '^level-name' $properties|cut -d= -f 2`

# Names of each of the maps we use. You can add more here if you have
# other maps (sky etc)
maps="${mapname}_the_end ${mapname}_nether $mapname"

# Backup each map
for map in $maps; do
    #echo ""
    #echo "#"
    #echo "## Backing up $map ##"

    previ=$(($numbackups-1))
    # Delete oldest
    if [ -d "$backuppath/$map.$previ" ]; then
        rm -rf "$backuppath/$map.$previ"
    fi

    # Rename all the backups one number higher.
    for ((i = $(($numbackups-1)); i>=0; i--)); do
    #for i in {12..0}; do
        if [ -d "$backuppath/$map.$i" ]; then
            mv "$backuppath/$map.$i" "$backuppath/$map.$previ"
        fi
        previ=$i
    done

    #create a new backup called .0 containing only things changed from .1
    rsyncargs="-a --exclude session.lock"
    if [ -d "$backuppath/$map.1" ]; then
        # theres already a backup. Hard link same files to that to save space
        #echo "Doing a 3 way rsync to hardlinks"
        #echo nice -10 rsync $rsyncargs --link-dest="$backuppath/$map.1/" "$mappath/$map/" "$backuppath/$map.0/"
        nice -10 rsync $rsyncargs --link-dest="$backuppath/$map.1/" "$mappath/$map/" "$backuppath/$map.0/"
    else 
        # First time running. Just do a flat rsync
        #echo "First time running, doing a simple rsync to bootstrap"
        #echo nice -10 rsync $rsyncargs "$mappath/$map/" "$backuppath/$map.0/"
        nice -10 rsync $rsyncargs "$mappath/$map/" "$backuppath/$map.0/"
    fi
    echo "Backup created by $self at `date`" > "$backuppath/$map.0/backupinfo.txt"
done

# Tell system we are complete
rm $LOCKFILE
