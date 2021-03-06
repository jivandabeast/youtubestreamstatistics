#!/bin/bash

#Set variables for mySQL (username, password, database name); updaate accordingly
user=[mySQL Username]
pass=[mySQL Password]
db=[mySQL Database Name]

#Grab the information for the stream from the YouTube API & store it in JSON format; update accordingly
curl -X GET "https://www.googleapis.com/youtube/v3/videos?part=liveStreamingDetails&id=[YouTube Stream ID]&key=AIzaSyAzRmWRQKbQpnAIH-Ws0ruzgxafjECdBCg" > temp.json

#Grab the current time in Epoch format for use in the database
EpochTime=`date +%s`

#Filter out the JSON for the livestream viewer count
ViewCount=`jq .items[0].liveStreamingDetails.concurrentViewers temp.json | cut -d \" -f 2`

#Import this information into the mysql database
mysql -u $user -p$pass -D $db -e "INSERT INTO ViewCount (Time, Viewers) VALUES ($EpochTime, $ViewCount)"
