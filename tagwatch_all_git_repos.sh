#!/bin/bash

# trap "echo 'EXIT!'; exit" SIGINT SIGTERM EXIT

DIR="$( cd "$( dirname "$0" )" && pwd )"

start_tagwatch() {
  GIT_REPOS=`find $1 -type d -name '.git' -print0 | xargs -0 -I'{}' echo "{}" | sed 's/\.git$//'`

  for REPO in $GIT_REPOS; do
    echo "watching $REPO"
    $DIR/tagwatch.sh -d "$REPO" &
  done
}

stop_tagwatch() {
  echo 'Stopping. . .'
  pkill -u $USER 'tagwatch.sh'
  pkill -u $USER 'inotifywait'
}

status_tagwatch() {
  echo 'Watching repos:'
  pgrep -u $USER tagwatch -a | cut -f 5 -d ' ' | sort | uniq
}

usage() {
  echo "do stuff"
}

ACTION=$1
ROOT_DIR=$2

ROOT_DIR=${ROOT_DIR:-$HOME/code}

case $ACTION in
  start) start_tagwatch $ROOT_DIR ;;
  stop) stop_tagwatch ;;
  status) status_tagwatch ;;
  *) usage ;;
esac
