#!/bin/sh

EXCLUDE_REGEX_DEFAULT="tags.*|log/|tmp/|\.git/|coverage/|doc"
SCRIPTNAME=`basename $0`

help() {
  cat <<Yubnub

ABOUT:

  $SCRIPTNAME - Auto updates ctags files via linux inotify events.

$SCRIPTNAME watches a directory recursively for file changes and automatically
updates your ctags file when they occur.  

It subscribes to filesystem events via inotifywait and should impose very
little overhead. It is aware of file changes spawned by anything - your editor,
your source control system, etc. It will not update more than once a second.

It requires exuberant-ctags and inotifywait. Install "exuberant-ctags" and
"inotify-tools" on modern debian-derived systems.

OPTIONS:

  -h: this message
  -v: verbose - additional log output. "." are ignored events because they
      occurred too quickly after the last update.
  -d: the directory to watch (the "tags" file is written here too).
      Defaults to pwd
  -e: An extended POSIX regex that defines what files / directories to ignore.
      Defaults to: "$EXCLUDE_REGEX_DEFAULT"

USAGE:

  $SCRIPTNAME -v -e "foo|bar"

Yubnub

  exit;
}

log_if_verbose() {
  if [ "$VERBOSE" -eq 1 ]; then
    echo -n $1
  fi
}

while getopts "hvd:e:" opt; do
  case $opt in
    h) help ;;
    v) VERBOSE=1 ;;
    d) WATCHED_DIR=$OPTARG ;;
    e) EXCLUDE_REGEX=$OPTARG ;;
  esac
done

WATCHED_DIR=${WATCHED_DIR:-`pwd`}
VERBOSE=${VERBOSE:-0}
EXCLUDE_REGEX=${EXCLUDE_REGEX:-$EXCLUDE_REGEX_DEFAULT}

TIME_COMMAND="date +%s"
PREVIOUS_RUN_TIME=`$TIME_COMMAND`

log_if_verbose "Watching: $WATCHED_DIR, PID: $$\n"

inotifywait --exclude="/$EXCLUDE_REGEX/"\
  -m -r -e modify -e move -e create -e delete $WATCHED_DIR | \
  while read line; do

  NOW=`$TIME_COMMAND`

  if [ "$NOW" -gt "$PREVIOUS_RUN_TIME" ]; then
    ctags -f $WATCHED_DIR/tags -R --exclude='*.js' \
      --langmap='ruby:+.rake.builder.rjs' --languages=-javascript $WATCHED_DIR/

    log_if_verbose "\nupdated because of $line on `date`\n"

    PREVIOUS_RUN_TIME=`$TIME_COMMAND`
  else
    log_if_verbose '.'
  fi
done
