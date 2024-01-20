#!/usr/bin/env bash

thefile="forest-stream-010 (Original).mp4"

mkdir ./tmp
mkdir ./out

# ffmpeg -i "./video/$thefile" -c:v libx264 -c:a aac ./tmp/tmp.mp4 -y

# with auto scaling down to maxwidth 1280 (https://stackoverflow.com/a/54064036)
ffmpeg -i "./video/$thefile" -c:v libx264 -c:a aac -vf 'scale=if(gte(iw\,ih)\,min(1280\,iw)\,-2):if(lt(iw\,ih)\,min(1280\,ih)\,-2)' ./tmp/tmp.mp4 -y

ffmpeg -i ./tmp/tmp.mp4  -codec: copy -start_number 0 -hls_time 10 -hls_list_size 0 -f hls ./out/playlist.m3u8