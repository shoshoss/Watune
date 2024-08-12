#!/bin/bash

# FFmpegのバージョンを確認
ffmpeg -version

# Railsサーバーの起動
rm -f tmp/pids/server.pid
bundle exec rails s -p 3000 -b '0.0.0.0'
