#!/bin/bash

EXCLUDE_GLOB_DEFAULT="*/tags.*;*/log/*;*/tmp/*;*/.git/*;*/coverage/*;*/doc/*;*/public/*"
SCRIPTNAME=`basename $0`
CTAGS_DEFAULT_OPTIONS="-R --exclude=*.js --langmap=ruby:+.rake.builder.rjs --languages=-javascript"

help() {
  cat <<Yubnub

ABOUT:

  $SCRIPTNAME - Auto updates ctags files via kernel-level filesystem events.

$SCRIPTNAME watches a directory recursively for file changes and automatically
updates your exuberant-ctags "tags" file.

It subscribes to filesystem events via python's watchmedo and should impose very
little overhead. It is aware of file changes spawned by anything - your editor,
your source control system, etc. It will not update more than once a second.

LINUX:
It requires exuberant-ctags and watchmedo. Install "exuberant-ctags" and run
"pip install watchmedo" on modern debian-derived systems.

OS X:
FIXME

OPTIONS:

  -h: this message
  -v: verbose - additional log output. "." are ignored events because they
      occurred too quickly after the last update.
  -d: the directory to watch (the "tags" file is written here too).
      Defaults to pwd
  -e: A shell glob pattern that defines what files / directories to ignore.
      Defaults to: "$EXCLUDE_GLOB_DEFAULT"
  -c: Options passed to the exuberant-ctags command, the defaults are fairly
      rails specific.
      Defaults to: "$CTAGS_DEFAULT_OPTIONS"

RC Configuration:

Files in the watched_directory named ".tagwatch.rc" are sourced and allow you
to configure default options. Currently, you can configure -e and -c.

  # ./.tagwatch.rc
  EXCLUDE_GLOB="*/tags.*;*/log/*;*/tmp/*;*/.git/*;*/coverage/*;*/doc/*"
  CTAGS_DEFAULT_OPTIONS="-R --exclude='*.js' --langmap='ruby:+.rake.builder.rjs' --languages=-javascript"

USAGE:

  $SCRIPTNAME -v -e "foo|bar"

Yubnub

  exit;
}

log_if_verbose() {
  if [ "$VERBOSE" -eq 1 ]; then
    echo -ne $1
  fi
}

source_rc_optionally() {
  RC_FILE="$1/.tagwatch.rc"
  if [ -e $RC_FILE ]; then
    log_if_verbose "Using RC: $RC_FILE\n"
    . $RC_FILE
  fi
}

while getopts "hvd:e:c:" opt; do
  case $opt in
    h) help ;;
    v) VERBOSE=1 ;;
    d) WATCHED_DIR=$OPTARG ;;
    e) EXCLUDE_GLOB=$OPTARG ;;
    c) CTAGS_OPTIONS=$OPTARG ;;
  esac
done

WATCHED_DIR=${WATCHED_DIR:-`pwd`}
source_rc_optionally $WATCHED_DIR

VERBOSE=${VERBOSE:-0}

EXCLUDE_GLOB=${EXCLUDE_GLOB:-$EXCLUDE_GLOB_DEFAULT}
CTAGS_OPTIONS=${CTAGS_OPTIONS:-$CTAGS_DEFAULT_OPTIONS}

TIME_COMMAND="date +%s"
PREVIOUS_RUN_TIME=`$TIME_COMMAND`

log_if_verbose "EXCLUDE_GLOB: $EXCLUDE_GLOB\n"
log_if_verbose "CTAGS_OPTIONS: $CTAGS_OPTIONS\n"
log_if_verbose "Watching: $WATCHED_DIR, PID: $$\n"

watch_command(){
  watchmedo shell-command --recursive --ignore-pattern="$EXCLUDE_GLOB" $WATCHED_DIR
}

watch_command | while read line; do

  NOW=`$TIME_COMMAND`

  if [ "$NOW" -gt "$PREVIOUS_RUN_TIME" ]; then
    ctags -f $WATCHED_DIR/tags $CTAGS_OPTIONS $WATCHED_DIR/

    log_if_verbose "\nupdated because of $line on `date`\n"

    PREVIOUS_RUN_TIME=`$TIME_COMMAND`
  else
    log_if_verbose '.'
    log_if_verbose "\nignored $line on `date`\n"
  fi

done
