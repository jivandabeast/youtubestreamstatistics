#!/bin/bash

#Set variable for file where the script will store the data, update accordingly
file=[DataFile]

#Grabs the date, appends to the end of the file, uncomment other line for MM/DD/YYYY HH:MM:SS
#date +"%m/%d/%Y %T">> $file
date +%s >> $file

#Grabs the current number of viewers on the livestream from the YouTube API, update with the stream ID
curl -X GET "https://www.googleapis.com/youtube/v3/videos?part=liveStreamingDetails&id=[STREAM ID HERE]&key=AIzaSyAzRmWRQKbQpnAIH-Ws0ruzgxafjECdBCg" > temp.json

#Parses the JSON from the YouTube API to pull out the relevant viewer count and appends it to the end of the file
jq .items[0].liveStreamingDetails.concurrentViewers temp.json | cut -d \" -f 2 >> $file
