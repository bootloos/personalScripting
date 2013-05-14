#!/bin/bash

# script to check for complete torrents in transmission folder, then stop and remove them

###Configuration Section###
# Authentication "username:password":
tr_auth='<username>:<password>'
###End of Configuration###

#Transmission Autentication
tr_auth="--auth=$tr_auth"

# use transmission-remote to get torrent list from transmission-remote list using sed to delete first / last line of output, and remove leading spaces
TORRENTLIST=`transmission-remote --list | sed -e '1d;$d;s/^ *//' | cut --only-delimited --delimiter= " " --fields=1`

for TORRENTID in $TORRENTLIST
do
  logger -is -t $0 "Operations on torrent ID $TORRENTID starting."
	transmission-remote $tr_auth --info $TORRENTID
	DL_COMPLETED=`transmission-remote $tr_auth --torrent $TORRENTID --info | grep "Percent Done: 100%"`
	STATE_STOPPED=`transmission-remote $tr_auth --torrent $TORRENTID --info | grep "State: Stopped\|Finished\|Idle"`
	# if the torrent is "Stopped", "Finished", or "Idle" after downloading then remove the torrent from Transmission
	if [ "$DL_COMPLETED" != "" ] && [ "$STATE_STOPPED" != "" ]; then
	logger -is -t $0 "Torrent #$TORRENTID is completed."
	logger -is -t $0 "Removing torrent from list."
	#transmission-remote $tr_auth --torrent $TORRENTID --remove-and-delete
	else
	logger -is -t $0 "Torrent #$TORRENTID is not completed. Ignoring."
	fi
	logger -is -t $0 "Operations on torrent ID $TORRENTID completed."
done
