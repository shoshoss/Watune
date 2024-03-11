#!/bin/bash
set -e

# Railsサーバーが前回の起動時に生成したserver.pidファイルを削除します。
# これはサーバーが正常に起動するために必要です。
rm -f /app/tmp/pids/server.pid

# コンテナのメインプロセスを実行します。(DockerfileのCMDに設定されています。)
exec "$@"
