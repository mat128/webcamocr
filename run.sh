#!/bin/sh
SSOCR="/usr/local/bin/ssocr"
FSWEBCAM="/usr/bin/fswebcam"
STREAMER="/usr/bin/streamer"

DATA_DIR="data/"
SAMPLES="samples/"
TOKEN_HTML="token.html"

mkdir -p $DATA_DIR
mkdir -p $SAMPLES

cd $(dirname $0)

if [ "$1" = "fswebcam" ]; then
  IMAGE="data/rsa_$(date +%s).png"
  COMMAND="$FSWEBCAM -d /dev/video0 --resolution 640x480 --png 1 -F 1 $IMAGE"
else
  IMAGE="data/rsa_$(date +%s).jpeg"
  COMMAND="$STREAMER -s 640x480 -d -o $IMAGE"
fi

$COMMAND

$SSOCR --debug-image=data/full.png -d 6 -t 43 crop 235 185 237 74 remove_isolated $IMAGE 1>"$IMAGE.method1.stdout" 2>"$IMAGE.method1.stderr"
$SSOCR --debug-image=data/alt1.png -d 3 -t 43 crop 235 185 120 74 remove_isolated $IMAGE 1>"$IMAGE.method2.stdout" 2>"$IMAGE.method2.stderr"
$SSOCR --debug-image=data/alt2.png -d 3 -t 38 crop 355 185 117 74 remove_isolated $IMAGE 1>>"$IMAGE.method2.stdout" 2>>"$IMAGE.method2.stderr"

TOKEN_METHOD1="$(cat $IMAGE.method1.stdout)"
TOKEN_METHOD2="$(cat $IMAGE.method2.stdout)"

echo "<h1>Method1: $TOKEN_METHOD1</h1><h1>Method2: $TOKEN_METHOD2</h1>" > $TOKEN_HTML
echo "<img src='$IMAGE'><br>" >> $TOKEN_HTML
date >> $TOKEN_HTML
echo "<pre>Method1 stderr:" >> $TOKEN_HTML
cat $IMAGE.method1.stderr >> $TOKEN_HTML
echo "</pre>" >> $TOKEN_HTML
echo "<pre>Method2 stderr:" >> $TOKEN_HTML
cat $IMAGE.method2.stderr >> $TOKEN_HTML
echo "</pre>" >> $TOKEN_HTML
