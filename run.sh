#!/usr/bin/env bash

thefile="BigBuckBunny.mp4"

mkdir ./tmp
mkdir ./out

# ffmpeg -i "./video/$thefile" -c:v libx264 -c:a aac ./tmp/tmp.mp4 -y

# with auto scaling down to maxwidth 1280 (https://stackoverflow.com/a/54064036)
ffmpeg -i "./video/$thefile" -c:v libx264 -c:a aac -vf 'scale=if(gte(iw\,ih)\,min(1280\,iw)\,-2):if(lt(iw\,ih)\,min(1280\,ih)\,-2)' ./tmp/tmp.mp4 -y

# ffmpeg -i ./tmp/tmp.mp4 -codec: copy -start_number 0 -hls_time 10 -hls_list_size 0 -f hls ./out/playlist.m3u8

ffmpeg -i "./tmp/tmp.mp4" \
  -map 0:v:0 -map 0:a:0 -map 0:v:0 -map 0:a:0 -map 0:v:0 -map 0:a:0 \
  -c:v libx264 -crf 22 -c:a copy \
  -filter:v:0 scale=w=480:h=360 -maxrate:v:0 1M \
  -filter:v:1 scale=w=640:h=480 -maxrate:v:1 2M \
  -filter:v:2 scale=w=1280:h=720 -maxrate:v:2 5M \
  -var_stream_map "v:0,a:0,name:360p v:1,a:1,name:480p v:2,a:2,name:720p" \
  -preset fast -hls_list_size 10 -threads 0 -f hls \
  -hls_time 3 -hls_flags independent_segments \
  -master_pl_name "playlist.m3u8" \
  -y "./out/playlist-%v.m3u8"


# create thumbnail
ffmpeg -ss 00:00:00 -i ./tmp/tmp.mp4 -frames:v 1 -q:v 2 ./out/thumbnail.jpg -y
convert -quality 65% ./out/thumbnail.jpg ./out/thumbnail.jpg