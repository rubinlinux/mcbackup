mcbackup
========

Quick and handy bash script to keep incrimental backups of your minecraft server

This script makes use of rsync's HARD LINK functionality to create incrimental backups of your Minecraft server. Because of the hard links, keeping 10 or 100 copies of your map only uses disk space to store the changed region files, resulting in very low disk usage.  You can use "cp -r" to copy the backups back for use (which wont preserve the hard-linkyness).




See comments in top of script for directions and to set the backup directory. 


tldr;
Just drop it in your mc server directory
finds your map automatically
edit it to specify your backup directory
run it regularly from cron.


