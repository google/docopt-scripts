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
coalesce them based on the value of a `$SCRIPTS_PATH` environment variable.
This environment variable (as well as any others) can be set in a special
`.<exec>config` file in the users home directory (e.g. `~/.akconfig`).
Putting variables in this file (as opposed to your standard `~/.bashrc` keeps
them from being set on a system wide basis and only available during the
running of this tool.

Scripts are written with the following naming convention so that they can sit
along other files in the `$SCRIPTS_PATH`:

`<exec>-<script_name>.sh`

When invoked, they are called as:

`$ <exec> <script_name>`

Instructions on how to write these scripts is forthcoming. For a (very) simple
example, see the `print-scripts-path.sh` script in the `scripts` folder of the
repo.

Installation
------------

1. Clone the repo
2. Run `make EXEC=<exec> install`
3. Follow the onscreen instructions

Contributing
------------
See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

**This is not an official Google product**
