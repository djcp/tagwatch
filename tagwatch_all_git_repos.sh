#!/bin/bash

# trap "echo 'EXIT!'; exit" SIGINT SIGTERM EXIT

DIR="$( cd "$( dirname "$0" )" && pwd )"
SCRIPTNAME=`basename $0`

start_tagwatch() {
  ROOT_DIR=${1:-$HOME}
  GIT_REPOS=`find $ROOT_DIR -type d -name '.git' -print0 | xargs -0 -I'{}' echo "{}" | sed 's/\.git$//'`

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
  cat <<Yubnub

ABOUT:

  $SCRIPTNAME - Finds git repos to watch for changes.

$SCRIPTNAME is a harness around 'tagwatch.sh' that will recursively find git
repos and watch them for file changes.  Most of the magic is in 'tagwatch.sh',
as all this does is spin up one 'tagwatch.sh' instance per repo found. This
allows for per-project RC configuration.

OPTIONS:

  start ROOT_DIRECTORY: Look for git repositories under ROOT_DIRECTORY. If
                        no ROOT_DIRECTORY is given, start from the user's HOME.
  status: Lists the watched git repos
  stop:   Kill all running 'tagwatch.sh' instances
  usage:  This message
Yubnub

  exit
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
