# docopt-scripts

This tool provides a framework for invoking a collection of bash scripts
through a single command line interface. Its purpose is to ease the development
of these scripts with well-formed usage semantics from
[docopt](http://docopt.org/) and collect them into a single place for easy
access.

The tool itself can be built into an executable with a name of your choice, and
individual scripts are invoked as subcommands of that executable.  For example,
if you build the tool to have the name `ak`, then a script called `launch-qemu`
can be invoked as follows:

`$ ak launch-qemu`

Individual scripts can be spread across the file system and the tool will
coalesce them based on the value of an `$<EXEC>_SCRIPTS_PATH` environment
variable (e.g. `$AK_SCRIPTS_PATH`).  This environment variable (as well as any
others) can be set in a special `.<exec>config` file in the users home
directory (e.g. `~/.akconfig`).  Putting variables in this file (as opposed to
your standard `~/.bashrc` keeps them from being set on a system wide basis and
only available during the running of this tool.

Scripts are written with the following naming convention so that they can sit
along other files in the `$<exec>_SCRIPTS_PATH`:

`<exec>-<script_name>.sh`

When invoked, they are called as:

`$ <exec> <script_name>`

Instructions on how to write these scripts is forthcoming. For a (very) simple
example, see the `print-scripts-path.sh` script in the `scripts` folder of the
repo.

Installation
------------

This installation requires Go. As part of this, Go requires you to set the
value of the GOPATH environment variable in order to download and install third
party packages during go compilation. Your GOPATH should remain set so that
installed scripts can make use of Go as well. Please add the following to your
.bashrc file (or equivalent).

```
export GOPATH=<path_to_third_party_go_stuff>
export PATH=${GOPATH//://bin:}/bin:$PATH
```

For reference:
<https://github.com/golang/go/wiki/GOPATH>

After that, just...

1. Clone the repo
2. Run `make EXEC=<exec> install`
3. Follow the onscreen instructions

Contributing
------------
See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

**This is not an official Google product**
