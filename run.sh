#!/usr/bin/env bash

thefile="BigBuckBunny.mp4"

rm -rf ./tmp ./out
mkdir ./tmp
mkdir ./out

# ffmpeg -i "./video/$thefile" -c:v libx264 -c:a aac ./tmp/tmp.mp4 -y

# with auto scaling down to maxwidth 1280 (https://stackoverflow.com/a/54064036)
# ffmpeg -i "./video/$thefile" -c:v libx264 -c:a aac -vf 'scale=if(gte(iw\,ih)\,min(1280\,iw)\,-2):if(lt(iw\,ih)\,min(1280\,ih)\,-2)' ./tmp/tmp.mp4 -y

  #  -filter:v:0 scale=w=480:h=360 -maxrate:v:0 1M \
# create hls
ffmpeg -i "./video/$thefile" \
  -c:v libx264 -c:a aac -pix_fmt yuv420p -crf 25 \
  -map 0:v:0 -map 0:a:0 -map 0:v:0 -map 0:a:0 -map 0:v:0 -map 0:a:0 -map 0:v:0 -map 0:a:0 \
  -filter:v:0 "fps=14.99, scale=480:270" -b:v:0 400k -maxrate:0 428k -bufsize:0 600k -b:a:0 64k -crf:v:0 36 \
  -filter:v:1 "fps=29.97, scale=640:360" -b:v:1 800k -maxrate:1 856 -bufsize:1 1200k -crf:v:0 36 \
  -filter:v:2 "fps=29.97, scale=960:540" -b:v:2 1350k -maxrate:2 1444k -bufsize:2 2025k \
  -filter:v:3 "fps=29.97, scale=1280:720" -b:v:3 3000k -maxrate:3 3210k -bufsize:3 4500k \
  -var_stream_map "v:0,a:0,name:270p v:1,a:1,name:360p v:2,a:2,name:540p v:3,a:3,name:720p" \
  -preset fast -threads 0 \
  -f hls \
  -hls_time 4 \
  -hls_playlist_type vod \
  -hls_flags independent_segments \
  -hls_segment_type mpegts \
  -master_pl_name "playlist.m3u8" \
  -y "./out/playlist-%v.m3u8"

# create thumbnail
ffmpeg -ss 00:00:10 -i "./video/$thefile" -frames:v 1 -q:v 2 ./out/thumbnail.jpg -y
convert -quality 65% ./out/thumbnail.jpg ./out/thumbnail.jpg