#!/bin/bash
#This script checks for completed torrents and removes them

###Configuration Section###
tr_auth='<username>:<password>'
###End of configuration###

###Setting Variables###
tr_auth="--auth=$tr_auth"
TORRENTLIST=`transmission-remote $tr_auth --list | sed -e '1d;$d;s/^ *//' | cut --only-delimited -d" " -f1`
###End of variables###

###MAIN###
for TORRENTID in $TORRENTLIST
do
	TORRENTNAME=`transmission-remote $tr_auth --torrent $TORRENTID --info| sed -e 's/^ *//' | grep "^Name:"|cut -d: -f2`	
	DL_COMPLETED=`transmission-remote $tr_auth --torrent $TORRENTID --info | grep "Percent Done: 100%"|cut -d: -f2`
	STATE_STOPPED=`transmission-remote $tr_auth --torrent $TORRENTID --info | grep "State: Finished"|cut -d: -f2`
	#if the torrent is Finished, remove it from Transmission
	if test -n "$DL_COMPLETED" && test -n "$STATE_STOPPED"; then
		logger -is -t $0 "Torrent $TORRENTNAME (#$TORRENTID) is completed, removing"
		transmission-remote $tr_auth --torrent $TORRENTID --remove_and_delete
	else
		logger -is -t $0 "Torrent $TORRENTNAME (#$TORRENTID) is not completed, ignoring"
	fi
done
