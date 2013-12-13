tagwatch
========

Auto-update ctags files via kernel-level filesystem events.

Tagwatch watches a directory recursively for file changes and
automatically updates your exuberant-ctags `tags` file.

It subscribes to filesystem events via python's
[`watchmedo`](http://pythonhosted.org/watchdog/) and should impose
very little overhead. It is aware of file changes spawned by
anything--your editor, your source control system, etc. It will not
update more than once a second.

Installation
============

### On Mac OS X

Tagwatch is available through [homebrew](http://brew.sh/).

FIXME: installation instructions?

### On Linux

Tagwatch is available as a Debian package.

FIXME: installation instructions?

If you're not on a Debian-derivative, you can also install tagwatch
manually. Tagwatch depends on exuberant-ctags and watchmedo. Install
`exuberant-ctags` through your package manager and run `pip install
watchdog` to install watchmedo, then copy `tagwatch` and
`tagwatch_all_git_repos` to `/usr/local/bin` (or your local bin
directory, if you prefer).

Usage
=====

    $ cd ~/code/my_project
    $ tagwatch

### Options

* `-h`: display help/usage.
* `-v`: verbose--display additional log output. "." are ignored events
      because they occurred too quickly after the last update.
* `-d`: the directory to watch (the "tags" file is written here, too).
      Defaults to the current directory.
* `-e`: A shell glob pattern that defines what files or directories to
      ignore. Defaults to:
      `"*/tags.*;*/log/*;*/tmp/*;*/.git/*;*/coverage/*;*/doc/*;*/public/*"`
* `-c`: Options passed to the exuberant-ctags command. The defaults
      are fairly rails-specific. Defaults to: `"-R --exclude=*.js
      --langmap=ruby:+.rake.builder.rjs --languages=-javascript"`

### Customization

Watched directories can contain a file named `.tagwatch.rc`, which
will be sourced when tagwatch starts. This allows you to configure
default options. Currently, you can configure `-e` and `-c`.

For example, the `.tagwatch.rc` for a Rails project without Javascript
might look like:

    # ~/code/my_project/.tagwatch.rc

    EXCLUDE_GLOB="*/tags.*;*/log/*;*/tmp/*;*/.git/*;*/coverage/*;*/doc/*"
    CTAGS_DEFAULT_OPTIONS="-R --exclude='*.js' --langmap='ruby:+.rake.builder.rjs' --languages=-javascript"
