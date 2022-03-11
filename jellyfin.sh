#!/bin/bash

#Enter these values manually
URL=""
KEY=""
USER=""
FILE="$(basename "$1")"
DIR="$(dirname "$1")"

[ -z "$URL" ] && echo "Need URL for metadata" && exit 1
[ -z "$KEY" ] && echo "Need API key for metadata" && exit 1
[ -z "$USER" ] && echo "Need username for metadata" && exit 1
[ -z "$FILE" ] && echo "Error: argument missing" && exit 1

LIBRARY=$(echo $DIR | cut -d '/' -f 3)
if [ "$LIBRARY" = "Movies" ]
then
	echo "Duration:$(mediainfo "$FILE" | grep Duration | head -1 | cut -d ':' -f 2)"
else
	USERID=$(curl -sX "GET" "http://$URL/Users?api_key=$KEY" | jq ".[] | select(.Name==\"$USER\") | .Id" | cut -d '"' -f 2)
	LIBRARYID=$(curl -sX "GET" "http://$URL/Items?api_key=$KEY&userID=$USERID" | jq ".Items[] | select(.Name==\"TV Shows\") | .Id" | cut -d '"' -f 2)
	TITLE=$(echo $DIR | cut -d '/' -f 4 | cut -d '(' -f 1 | awk '{gsub(/^ +| +$/,"")} {print $0}')
	TITLEID=$(curl -sX "GET" "http://$URL/Items?api_key=$KEY&userID=$USERID&parentId=$LIBRARYID" | jq ".Items[] | select(.Name==\"$TITLE\") | .Id" | cut -d '"' -f 2)
	SEASON=$(echo $DIR | cut -d '/' -f 5)
	SEASONID=$(curl -sX "GET" "http://$URL/Shows/$TITLEID/Seasons?api_key=$KEY" | jq ".Items[] | select(.Name==\"$SEASON\") | .Id" | cut -d '"' -f 2)
	EPISODE=$((10#$(echo $FILE | awk '{split($1, arr, "[E.]"); print arr[2]}')))
	METADATA=$(curl -sX "GET" "http://$URL/Shows/$TITLEID/Episodes?api_key=$KEY&seasonId=$SEASONID" | jq ".Items[] | select(.IndexNumber==$EPISODE)")
	echo "Title: $(echo $METADATA | jq '.Name' | cut -d '"' -f 2)"
	echo "Duration: $(expr $(echo $METADATA | jq '.RunTimeTicks') / 600000000) mins"
fi
