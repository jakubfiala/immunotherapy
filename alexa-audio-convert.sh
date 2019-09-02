#!/usr/bin/env bash
set -o errexit
set -o nounset

input_file=$1
output_file=$2

ffmpeg -i $input_file \
  -ac 2 \
  -codec:a libmp3lame \
  -b:a 48k \
  -ar 16000 \
  $output_file
